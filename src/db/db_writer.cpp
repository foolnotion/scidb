// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_writer.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_annotation.h"
#include "db_move.h"
#include "db_comment.h"
#include "db_game_info.h"
#include "db_pgn_aquarium.h"

#include "sys_utf8.h"
#include "sys_utf8_codec.h"

#include "m_string.h"
#include "m_assert.h"
#include "m_utility.h"
#include "m_stdio.h"

#include <string.h>
#include <stdlib.h>

using namespace db;


static void
appendNag(mstl::string& str, nag::ID nag)
{
	if (char const* symbol = nag::toSymbol(nag))
		str.append(symbol);
}


Writer::Writer(format::Type srcFormat,
					unsigned flags,
					mstl::string const& encoding,
					LanguageList const* languages,
					unsigned significantLanguages)
	:Consumer(srcFormat, encoding, TagBits(true), true, languages, significantLanguages)
	,m_flags(flags)
	,m_count(0)
	,m_level(0)
	,m_nullLevel(0)
	,m_needMoveNumber(false)
	,m_needSpace(false)
	,m_result(result::Unknown)
{
	if (test(Flag_Use_ChessBase_Format))
	{
		m_flags &= ~Flag_Convert_Lost_Result_To_Comment;
		m_flags &= ~Flag_Convert_Null_Moves_To_Comments;

		m_flags |= Flag_Use_Shredder_FEN;
		m_flags |= Flag_Append_Mode_To_Event_Type;
	}
}


mstl::string const&
Writer::encode(mstl::string const& comment)
{
	if (codec().isUtf8())
		return comment;
	
	m_stringBuf1.clear();

	for (char const* p = comment; *p; p = sys::utf8::nextChar(p))
	{
		switch (sys::utf8::getChar(p))
		{
			// Figurine
			case 0x2654: m_stringBuf1.append('K'); break;
			case 0x2655: m_stringBuf1.append('Q'); break;
			case 0x2656: m_stringBuf1.append('R'); break;
			case 0x2657: m_stringBuf1.append('B'); break;
			case 0x2658: m_stringBuf1.append('N'); break;
			case 0x2659: m_stringBuf1.append('P'); break;

			// Evaluation
			case 0x203c: ::appendNag(m_stringBuf1, nag::VeryGoodMove); break;
			case 0x2047: ::appendNag(m_stringBuf1, nag::VeryPoorMove); break;
			case 0x2048: ::appendNag(m_stringBuf1, nag::QuestionableMove); break;
			case 0x2049: ::appendNag(m_stringBuf1, nag::SpeculativeMove); break;
			case 0x25a0: ::appendNag(m_stringBuf1, nag::SingularMove); break;
			case 0x25a1: ::appendNag(m_stringBuf1, nag::SingularMove); break;
			case 0x221e: ::appendNag(m_stringBuf1, nag::UnclearPosition); break;
			case 0x2a72: ::appendNag(m_stringBuf1, nag::WhiteHasASlightAdvantage); break;
			case 0x2a71: ::appendNag(m_stringBuf1, nag::BlackHasASlightAdvantage); break;
			case 0x00b1: ::appendNag(m_stringBuf1, nag::WhiteHasAModerateAdvantage); break;
			case 0x2213: ::appendNag(m_stringBuf1, nag::BlackHasAModerateAdvantage); break;

			// Symbols
			case 0x2212: m_stringBuf1.append('-'); break;		// Minus Sign
			case 0x223c: m_stringBuf1.append('~'); break;		// Tilde operator
			case 0x2026: m_stringBuf1.append("..."); break;		// Ellipsis

			default: m_stringBuf1.append(p, sys::utf8::charLength(p)); break;
		}
	}

	codec().fromUtf8(m_stringBuf1, m_stringBuf2);
	return m_stringBuf2;
}


void
Writer::sendPrecedingComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks)
{
	bool hasDiagram = annotation.contains(nag::Diagram) || annotation.contains(nag::DiagramFromBlack);

	if (test(Flag_Include_Comments))
	{
		if (hasDiagram && test(Flag_Use_ChessBase_Format))
		{
			writePrecedingComment(Annotation(), Comment("#", i18n::None), MarkSet());
			m_needSpace = true;

			if (!comment.isEmpty() || !marks.isEmpty())
			{
				writePrecedingComment(Annotation(), comment, marks);
				m_needSpace = true;
			}
		}
		else
		{
			writePrecedingComment(annotation, comment, marks);
			m_needSpace = true;
		}
	}
	else if (hasDiagram)
	{
		if (test(Flag_Use_ChessBase_Format))
			writePrecedingComment(Annotation(), Comment("#", i18n::None), MarkSet());
		else
			writePrecedingComment(annotation, Comment(), MarkSet());

		m_needSpace = true;
	}
}


void
Writer::sendTrailingComment(Comment const& comment, bool variationIsEmpty)
{
	if (test(Flag_Include_Comments) && !comment.isEmpty())
	{
		writeTrailingComment(comment);
		m_needSpace = true;
	}
}



void
Writer::sendComment(Comment const& comment)
{
	// Normally this method shouldn't be called

	if (test(Flag_Include_Comments) && !comment.isEmpty())
	{
		writeTrailingComment(comment);
		m_needSpace = true;
	}
}


void
Writer::sendMoveInfo(MoveInfoSet const& moveInfo)
{
	if (test(Flag_Include_Move_Info) && !moveInfo.isEmpty())
	{
		writeMoveInfo(moveInfo);
		m_needSpace = true;
	}
}


void
Writer::beginVariation()
{
	++m_level;

	if (m_nullLevel)
		++m_nullLevel;

	if (test(Flag_Include_Variations))
	{
		m_needSpace = false;
		writeBeginVariation(m_level);
		m_needMoveNumber = true;
	}
}


void
Writer::endVariation(bool)
{
	M_REQUIRE(level() > 0);

	if (m_flags & Flag_Include_Variations)
	{
		m_needSpace = false;
		writeEndVariation(m_level);
		m_needMoveNumber = true;
		m_needSpace = true;
	}

	--m_level;

	if (m_nullLevel > 0 && --m_nullLevel == 0)
		writeEndComment();
}


void
Writer::writeTag(tag::ID tag, mstl::string const& value)
{
	writeTag(tag::toName(tag), encode(value));
}


bool
Writer::beginGame(TagSet const& tags)
{
	static mstl::string const Date("????.??.??");
	static mstl::string const Query("?");
	static mstl::string const One("1");

	writeBeginGame(++m_count);
	m_needSpace = false;

	bool whiteElo = false;
	bool blackElo = false;

	writeTag(tag::Event, tags.contains(tag::Event) ? tags.value(tag::Event) : Query);
	writeTag(tag::Site,  tags.contains(tag::Site)  ? tags.value(tag::Site)  : Query);
	writeTag(tag::Date,  tags.contains(tag::Date)  ? tags.value(tag::Date)  : Date);
	writeTag(tag::Round, tags.contains(tag::Round) ? tags.value(tag::Round) : Query);
	writeTag(tag::White, tags.contains(tag::White) ? tags.value(tag::White) : Query);
	writeTag(tag::Black, tags.contains(tag::Black) ? tags.value(tag::Black) : Query);

	{
		mstl::string const& value = tags.value(tag::Result);

		m_result = result::fromString(value);

		if (m_result == result::Lost && test(Flag_Convert_Lost_Result_To_Comment))
			writeTag(tag::Result, result::toString(result::Unknown));
		else
			writeTag(tag::Result, value);
	}

	for (unsigned i = 0; i < tag::BughouseTag; ++i)
	{
		tag::ID tag  = test(Flag_Strict_PGN_Standard) ? tag::mapAlphabetic(tag::ID(i)) : tag::ID(i);
		bool isEmpty = !tags.contains(tag);
		mstl::string const& value = tags.value(tag);

		switch (tag)
		{
			case tag::WhiteCountry:
			case tag::BlackCountry:
				if (!isEmpty)
				{
					if (test(Flag_Use_ChessBase_Format))
						writeTag(tag, country::toChessBaseCode(country::fromString(value)));
					else
						writeTag(tag, value);
				}
				break;

			case tag::SetUp:
				if (!isEmpty && test(Flag_Include_Setup_Tag))
					writeTag(tag, value);
				break;

			case tag::Fen:
				if (!isEmpty)
				{
					if (!tags.contains(tag::SetUp) && test(Flag_Include_Setup_Tag))
						writeTag(tag::toName(tag::SetUp), One);

					if (test(Flag_Use_Shredder_FEN))
					{
						mstl::string fen;
						startBoard().toFen(fen, variant(), Board::Shredder);
						writeTag(tag, fen);
					}
					else
					{
						writeTag(tag, value);
					}
				}
				break;

			case tag::Idn:
				if (format() == format::Scidb && !isEmpty && test(Flag_Include_Position_Tag))
				{
					uint16_t idn = ::strtoul(value.c_str(), nullptr, 10);
					mstl::string buf;
					buf.format(	"%s %s", value.c_str(), shuffle::position(idn).c_str());
					writeTag(tag, buf);
				}
				break;

			case tag::TimeMode:
				if (!isEmpty && test(Flag_Include_Time_Mode_Tag))
					writeTag(tag, value);
				break;

			case tag::Variant:
				if (!isEmpty && test(Flag_Include_Variant_Tag))
					writeTag(tag, value);
				break;

			case tag::Termination:
				if (!isEmpty && test(Flag_Include_Termination_Tag))
					writeTag(tag, value);
				break;

			case tag::Mode:
				if (!isEmpty && test(Flag_Include_Mode_Tag))
					writeTag(tag, value);
				break;

			case tag::EventType:
				if (!isEmpty)
				{
					if (test(Flag_Append_Mode_To_Event_Type) && tags.contains(tag::Mode))
					{
						mstl::string v = value;

						if (v.back() != ')')
						{
							v += " (";
							v += tags.value(tag::Mode);
							v += ')';

							writeTag(tag::EventType, v);
						}
					}
					else
					{
						writeTag(tag, value);
					}
				}
				break;

			case tag::Opening:
				if (!isEmpty && test(Flag_Include_Opening_Tag))
					writeTag(tag, value);
				break;

			case tag::Variation:
				if (!isEmpty && test(Flag_Include_Variation_Tag))
					writeTag(tag, value);
				break;

			case tag::SubVariation:
				if (!isEmpty && test(Flag_Include_Sub_Variation_Tag))
					writeTag(tag, value);
				break;

			case tag::PlyCount:
				if (!isEmpty && test(Flag_Use_ChessBase_Format))
					writeTag(tag, value);
				break;

			default:
				if (!isEmpty)
				{
					if (tag::isWhiteRatingTag(tag))
					{
						if (!whiteElo)
						{
							if (	tag == tag::WhiteElo
								|| (	test(Flag_Write_Any_Rating_As_ELO)
									&& !tags.contains(tag::WhiteElo)
									&& (tag == tag::WhiteRating || !tags.contains(tag::WhiteRating))))
							{
								writeTag(tag, value);
								whiteElo = true;
							}
						}
					}
					else if (tag::isBlackRatingTag(tag))
					{
						if (!blackElo)
						{
							if (	tag == tag::BlackElo
								|| (	test(Flag_Write_Any_Rating_As_ELO)
									&& !tags.contains(tag::BlackElo)
									&& (tag == tag::BlackRating || !tags.contains(tag::BlackRating))))
							{
								writeTag(tag, value);
								blackElo = true;
							}
						}
					}
					else if (!tag::isMandatory(tag) && !test(Flag_Exclude_Extra_Tags))
					{
						writeTag(tag, value);
					}
				}
				break;
		}
	}

	// TODO: the PGN standard sasy that additional tags (non-STR tags) have
	// to be exported in ASCII order by tag name.

	if (!test(Flag_Exclude_Extra_Tags))
	{
		for (unsigned i = 0; i < tags.countExtra(); ++i)
			writeTag(tags.extra(i).name, encode(tags.extra(i).value));
	}

	if (test(Flag_Use_Scidb_Import_Format))
	{
		mstl::string buf;
		writeTag("ScidbGameFlags", GameInfo::flagsToString(gameFlags(), buf));
	}

	return true;
}


save::State
Writer::endGame(TagSet const&)
{
	writeEndGame();
	return save::Ok;
}


void
Writer::beginMoveSection()
{
	m_needMoveNumber = true;
	writeBeginMoveSection();
}


void
Writer::endMoveSection(result::ID result)
{
	if (m_nullLevel)
	{
		m_needSpace = false;
		--m_nullLevel;
		writeEndComment();
		m_needSpace = true;
	}

	if (result == result::Lost && test(Flag_Convert_Lost_Result_To_Comment))
	{
		static Comment Phrase(Phrases[0], i18n::English | i18n::Other_Lang | i18n::Multilingual);

		Comment comment;
		preparePhrase(comment, Phrase);
		sendTrailingComment(comment, false);
		result = result::Unknown;
	}

	m_needSpace = false;
	writeEndMoveSection(result);
}


void
Writer::writeMove(Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& preComment,
						Comment const& comment)
{
	if (m_level && !test(Flag_Include_Variations))
		return;
	
	Comment myPreComment;
	Comment myComment;

	if (test(Flag_Include_Comments))
	{
		if (!preComment.isEmpty())
			prepareComment(myPreComment, preComment);
		if (!comment.isEmpty())
			prepareComment(myComment, comment);
	}

	if (!myPreComment.isEmpty())
		m_needMoveNumber = true;

	if (m_needMoveNumber)
	{
		m_moveNumber.resize(32);
		m_moveNumber.resize(::sprintf(m_moveNumber.data(), "%u.", board().moveNumber()));

		if (color::isBlack(move.color()))
			m_moveNumber += "..";
	}
	else
	{
		m_moveNumber.clear();
	}

	if (m_nullLevel == 0 && move.isNull() && test(Flag_Convert_Null_Moves_To_Comments))
	{
		writeBeginComment();
		m_nullLevel = 1;
	}

	if (!move.isPrintable())
	{
		Move m(move);
		board().prepareForPrint(m, variant(), Board::ExternalRepresentation);
		writeMove(m, m_moveNumber, annotation, marks, myPreComment, myComment);
	}
	else
	{
		writeMove(move, m_moveNumber, annotation, marks, myPreComment, myComment);
	}

	m_needSpace = true;
	m_needMoveNumber = color::isBlack(move.color()) || !comment.isEmpty();
}


bool
Writer::sendMove(	Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& preComment,
						Comment const& comment)
{
	writeMove(move, annotation, marks, preComment, comment);
	return true;
}


bool
Writer::sendMove(Move const& move)
{
	writeMove(move, Annotation(), MarkSet(), Comment(), Comment());
	return true;
}

// vi:set ts=3 sw=3:
