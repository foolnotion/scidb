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
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

// ChessBase format description:
// http://talkchess.com/forum/viewtopic.php?t=29468&highlight=cbh
// http://talkchess.com/forum/viewtopic.php?topic_view=threads&p=287896&t=29468&sid=a535ba2e9a17395e2582bdddf57c2425

#include "cbh_game_decoder.h"

#include "db_consumer.h"
#include "db_game_data.h"
#include "db_game_info.h"
#include "db_database_codec.h"
#include "db_move_node.h"
#include "db_mark_set.h"
#include "db_annotation.h"
#include "db_exception.h"

#include "u_byte_stream.h"
#include "u_bit_stream.h"

#include "sys_utf8.h"
#include "sys_utf8_codec.h"

#include "m_vector.h"
#include "m_limits.h"
#include "m_stdio.h"

#include <ctype.h>

using namespace util;
using namespace db;
using namespace db::cbh;


static int const MaxMoveNo = mstl::numeric_limits<int>::max();


# define ____ 0
static char const* LangMap[] =
{
	____, ____, ____, ____, ____, ____, ____, ____, // x00 - x07
	____, ____, ____, ____, ____, ____, ____, ____, // x08 - x0f
	____, ____, ____, ____, ____, ____, ____, ____, // x10 - x17
	____, ____, ____, ____, ____, ____, ____, ____, // x18 - x1f
	____, ____, ____, ____, ____, ____, ____, ____, // x20 - x27
	____, ____, "en", "es", ____, ____, ____, ____, // x28 - x2f
	____, "fr", ____, ____, ____, "de", ____, ____, // x30 - x37
	____, ____, ____, ____, ____, ____, ____, ____, // x38 - x3f
	____, ____, ____, ____, ____, ____, "it", ____, // x40 - x47
	____, ____, ____, ____, ____, ____, ____, ____, // x48 - x4f
	____, ____, ____, ____, ____, ____, ____, ____, // x50 - x57
	____, ____, ____, ____, ____, ____, ____, ____, // x58 - x5f
	____, ____, ____, ____, ____, ____, ____, "nl", // x60 - x67
	____, ____, ____, ____, ____, ____, ____, ____, // x68 - x6f
	____, ____, ____, ____, "pl", "pt", ____, ____, // x70 - x77
	____, ____, ____, ____, ____, ____, ____, ____, // x78 - x7f
};
#undef ____


inline
static Byte
mapSquare(Byte sq)
{
	return sq::make(sq >> 3, sq & 7);
}


static mark::Color
mapColor(Byte c)
{
	switch (c)
	{
		case 2: return mark::Green;
		case 3: return mark::Yellow;
		case 4: return mark::Red;
	}

	return Mark::DefaultColor;
}


GameDecoder::GameDecoder(ByteStream& gStrm, ByteStream& aStrm, sys::utf8::Codec& codec, bool isChess960)
	:Decoder(gStrm, isChess960)
	,m_aStrm(aStrm)
	,m_codec(codec)
	,m_moveNo(MaxMoveNo)
{
	if (!m_aStrm.isEmpty())
	{
		if ((m_moveNo = m_aStrm.uint24()) == 0xffffff)
			m_moveNo = -1;
	}
}


void
GameDecoder::traverse(Consumer& consumer, MoveNode const* node)
{
	M_ASSERT(node);

	if (node->hasNote())
		consumer.putPrecedingComment(node->comment(move::Post), node->annotation(), node->marks());

	for (node = node->next(); node->isBeforeLineEnd(); node = node->next())
	{
		if (node->hasNote())
		{
			consumer.putMove(	node->move(),
									node->annotation(),
									node->comment(move::Ante),
									node->comment(move::Post),
									node->marks());
		}
		else
		{
			consumer.putMove(node->move());
		}

		for (unsigned i = 0; i < node->variationCount(); ++i)
		{
			consumer.startVariation();
			traverse(consumer, node->variation(i));
			consumer.finishVariation();
		}
	}
}


void
GameDecoder::decodeComment(MoveNode* node, unsigned length, move::Position position)
{
	M_ASSERT(node);

	if (length < 2)
	{
		m_aStrm.skip(length);
		return;
	}

	uint16_t country = m_aStrm.uint16();
	length -= 2;

	unsigned char const* p = m_aStrm.data();

	mstl::string str;

	char const* lang = 0;

	if (country < U_NUMBER_OF(::LangMap))
		lang = ::LangMap[country];

	bool useXml = lang != 0 || node->comment(position).isXml();

	// BUG: ChessBase uses country code 0 for ALL and for Pol.
	//      How should we distinguish between these countries?

	str.reserve(length + 200);

	unsigned i = 0;
	while (::isspace(p[i]))
		++i;

	for ( ; i < length; ++i)
	{
		Byte c = p[i];

		if (::isprint(c))
		{
			str += c;
		}
		else
		{
			nag::ID nag = nag::Null;

			switch (c)
			{
				case 0x0d:
					str.append(0x0a);
					if (p[i + 1] == 0x0a)
						++i;
					break;

				case 0xa2: str.append(char(0x01)); useXml = true; break;		// King
				case 0xa3: str.append(char(0x02)); useXml = true; break;		// Queen
				case 0xa4: str.append(char(0x05)); useXml = true; break;		// Knight
				case 0xa5: str.append(char(0x04)); useXml = true; break;		// Bishop
				case 0xa6: str.append(char(0x03)); useXml = true; break;		// Rook
				case 0xa7: str.append(char(0x06)); useXml = true; break;		// Pawn

				case 0x82: nag = nag::Attack; break; 								// "->"
				case 0x83: nag = nag::Initiative; break;							// "|^"
				case 0x84: nag = nag::Counterplay; break;							// "<=>"
				case 0x85: nag = nag::WithTheIdea; break;							// "/\"
				case 0x86: nag = nag::Space; break; 								// "()"
				case 0x87: nag = nag::Zugzwang; break;								// "(.)"
				case 0x90: nag = nag::Development; break;							// "@"
				case 0x91: nag = nag::Line; break; 									// "<->"
				case 0x92: nag = nag::Diagonal; break; 							// "/^"
				case 0x93: nag = nag::Zeitnot; break;								// "(+)"
				case 0x94: nag = nag::Center; break;								// "[+]"
				case 0x99: nag = nag::SingularMove; break;						// "[]"
				case 0xa9: nag = nag::WithCompensationForMaterial; break;	// "~/="
				case 0xaa: nag = nag::With; break; 									// "|_"
				case 0xab: nag = nag::Queenside; break; 							// "<<"
				case 0xac: nag = nag::Endgame; break; 								// "_|_"
				case 0xad: nag = nag::PairOfBishops; break; 						// "^^"
				case 0xae: nag = nag::BishopsOfOppositeColor; break; 			// "^_"
				case 0xaf: nag = nag::BishopsOfSameColor; break;				// "^="
				case 0xb0: nag = nag::WithCompensationForMaterial; break;	// "~/="
				case 0xb1: nag = nag::WhiteHasAModerateAdvantage; break; 	// "+/-"
				case 0xb2: nag = nag::WhiteHasASlightAdvantage; break; 		// "+/="
				case 0xb3: nag = nag::BlackHasASlightAdvantage; break; 		// "=/+"
				case 0xb5: nag = nag::BlackHasAModerateAdvantage; break; 	// "-/+"
				case 0xb9: nag = nag::BetterMove; break; 							// ">="
				case 0xba: nag = nag::Without; break; 								// "_|"
				case 0xbb: nag = nag::Kingside; break; 							// ">>"
				case 0xd7: nag = nag::WeakPoint; break; 							// "><"
				case 0xf7: nag = nag::UnclearPosition; break; 					// "~~"
				case 0xfe: nag = nag::PassedPawn; break; 							// "o^"

				case 0x9e:
					node->addAnnotation(nag::Diagram);								// "#"
					break;

				default:
					if (length == 1)
					{
						m_aStrm.skip(1);
						return; // seems to be a special instruction
					}
					if (Byte(c) > 0x07)
						str += c;
					break;
			}

			if (nag != nag::Null)
			{
				str.append(char(0x07));
				str.append(char(nag));
				useXml = true;
			}
		}
	}

	while (!str.empty() && ::isspace(str.back()) && (str.size() == 1 || *(str.end() - 2) != 0x07))
		str.resize(str.size() - 1);

	if (!str.empty())
	{
		if (useXml)
		{
			mstl::string tmp;
			tmp.swap(str);
			str.reserve(2*tmp.size() + 20);
			str.append("<xml><:", 7);
			if (lang)
				str.append(lang);
			str.append('>');

			for (char const* s = tmp; *s; ++s)
			{
				switch (*s)
				{
					case 0x01:	str.append("<sym>K</sym>", 12); break;
					case 0x02:	str.append("<sym>Q</sym>", 12); break;
					case 0x03:	str.append("<sym>R</sym>", 12); break;
					case 0x04:	str.append("<sym>B</sym>", 12); break;
					case 0x05:	str.append("<sym>N</sym>", 12); break;
					case 0x06:	str.append("<sym>P</sym>", 12); break;
					case 0x07:	str.format("<nag>%u</nag>", unsigned(Byte(*++s))); break;
					case '<':	str.append("&lt;",   4); break;
					case '>':	str.append("&gt;",   4); break;
					case '&':	str.append("&amp;",  5); break;
					case '\'':	str.append("&apos;", 6); break;
					case '"':	str.append("&quot;", 6); break;
					default:		str.append(*s); break;
				}
			}

			str.append("</:", 3);
			if (lang)
				str.append(lang);
			str.append("></xml>", 7);
		}

		// TODO: use character encoding according to language code ?!
		m_codec.toUtf8(str);

		if (!sys::utf8::validate(str))
			m_codec.forceValidUtf8(str);

		unsigned langFlags = 0;

		if (lang)
			langFlags |= (::strcmp(lang, "en") == 0) ? i18n::English : i18n::Other_Lang;

		Comment comment;
		comment.swap(str, langFlags);

		if (node->hasComment(position))
		{
			Comment c;
			node->swapComment(c, position);
			c.append(comment, '\n');
			c.normalize();
			node->swapComment(c, position);
		}
		else
		{
			comment.normalize();
			node->setComment(comment, position);
		}
	}

	m_aStrm.skip(length);
}


void
GameDecoder::decodeSymbols(MoveNode* node, unsigned length)
{
#define NAG(code) wtm ? nag::White##code : nag::Black##code

	static_assert(Annotation::Max_Nags >= 4, "ChessBase need at least four entries");

	if (length == 0)
		return;

	bool wtm = color::isWhite(node->move().color());	// white to move

	switch (m_aStrm.get())
	{
		case 0x01: node->addAnnotation(nag::GoodMove); break;
		case 0x02: node->addAnnotation(nag::PoorMove); break;
		case 0x03: node->addAnnotation(nag::VeryGoodMove); break;
		case 0x04: node->addAnnotation(nag::VeryPoorMove); break;
		case 0x05: node->addAnnotation(nag::SpeculativeMove); break;
		case 0x06: node->addAnnotation(nag::QuestionableMove); break;
		case 0x08: node->addAnnotation(nag::SingularMove); break;
		case 0x16: node->addAnnotation(NAG(IsInZugzwang)); break;
	}

	if (length == 1)
		return;

	switch (m_aStrm.get())
	{
		case 0x0b: node->addAnnotation(nag::DrawishPosition); break;
		case 0x0d: node->addAnnotation(nag::UnclearPosition); break;
		case 0x0e: node->addAnnotation(nag::WhiteHasASlightAdvantage); break;
		case 0x0f: node->addAnnotation(nag::BlackHasASlightAdvantage); break;
		case 0x10: node->addAnnotation(nag::WhiteHasAModerateAdvantage); break;
		case 0x11: node->addAnnotation(nag::BlackHasAModerateAdvantage); break;
		case 0x12: node->addAnnotation(nag::WhiteHasADecisiveAdvantage); break;
		case 0x13: node->addAnnotation(nag::BlackHasADecisiveAdvantage); break;
		case 0x20: node->addAnnotation(NAG(HasAModerateTimeAdvantage)); break;
		case 0x24: node->addAnnotation(NAG(HasTheInitiative )); break;
		case 0x28: node->addAnnotation(NAG(HasTheAttack)); break;
		case 0x2c: node->addAnnotation(NAG(HasSufficientCompensationForMaterialDeficit)); break;
		case 0x84: node->addAnnotation(NAG(HasModerateCounterplay)); break;
		case 0x8a: node->addAnnotation(nag::TimeLimit); break;
		case 0x92: node->addAnnotation(nag::Novelty); break;
	}

	if (length == 2)
		return;

	switch (m_aStrm.get())
	{
		case 0x8C: node->addAnnotation(nag::WithTheIdea); break;
		case 0x8D: node->addAnnotation(nag::AimedAgainst); break;
		case 0x8E: node->addAnnotation(nag::BetterMove); break;
		case 0x8F: node->addAnnotation(nag::WorseMove); break;
		case 0x90: node->addAnnotation(nag::EquivalentMove); break;
		case 0x91: node->addAnnotation(nag::EditorsRemark); break;
	}

#undef NAG
}


void
GameDecoder::decodeSquares(MoveNode* node, unsigned length)
{
	for ( ; length >= 2; length -= 2)
	{
		mark::Color c = ::mapColor(m_aStrm.get());
		Square s = ::mapSquare(m_aStrm.get() - 1);

		if (s <= sq::h8)
			node->addMark(Mark(mark::Full, c, s));
	}

	m_aStrm.skip(length);	// to be sure
}


void
GameDecoder::decodeArrows(MoveNode* node, unsigned length)
{
	for ( ; length >= 3; length -= 3)
	{
		mark::Color c = ::mapColor(m_aStrm.get());
		Square s = ::mapSquare(m_aStrm.get() - 1);
		Square t = ::mapSquare(m_aStrm.get() - 1);

		if (s <= sq::h8 && t <= sq::h8)
			node->addMark(Mark(mark::Arrow, c, s, t));
	}

	m_aStrm.skip(length);	// to be sure
}


void
GameDecoder::getAnnotation(MoveNode* node, int moveNo)
{
	M_ASSERT(moveNo != MaxMoveNo);
	M_ASSERT(node);

	if (moveNo < m_moveNo)
		return;

	if (__m_unlikely(m_aStrm.isEmpty()))
		throw DecodingFailedException("unexpected end of stream");

	while (moveNo == m_moveNo)
	{
		Byte		type		= m_aStrm.get();
		unsigned length	= m_aStrm.uint16() - 6;

		if (length > m_aStrm.remaining())
		{
			m_aStrm.skip(m_aStrm.remaining());
			return;
		}

		switch (type)
		{
			case 0x82:	// text before move
				if (!node->atLineStart())
				{
					decodeComment(node, length, move::Ante);
					break;
				}
				// fallthru

			case 0x02:	// text after move
				decodeComment(node, length, move::Post);
				break;

			case 0x03:	// symbols
				if (__m_unlikely(length > 3))
					throw DecodingFailedException("bad data");
				decodeSymbols(node, length);
				break;

			case 0x04:	// squares
				decodeSquares(node, length);
				break;

			case 0x05:	// arrows
				decodeArrows(node, length);
				break;

			default:
				m_aStrm.skip(length);
				break;
		}

		if (m_aStrm.isEmpty())
			m_moveNo = MaxMoveNo;
		else if ((m_moveNo = m_aStrm.uint24()) == 0xffffff)
			m_moveNo = -1;
	}
}


#if 0
void
GameDecoder::decodeMoves(Consumer& consumer)
{
	MoveNode	node;
	Comment	comment;
	unsigned	count = 0;
	Move		move;

	while (true)
	{
		switch (decodeMove(move, count))
		{
			case ::Move:
				if (!move)
					return;
				getAnnotation(&node, int(count) - 1);
				if (node.hasNote())
				{
					consumer.putMove(move, node.annotation(), comment, comment, node.marks());
					node.clearAnnotation();
					node.clearMarks();
				}
				else
				{
					consumer.putMove(move);
				}
				break;

			case ::Push:
				IO_RAISE(Game, Corrupted, "unexpected PUSH");
				break;

			case ::Pop:
				return;
		}
	}
}
#endif


void
GameDecoder::decodeMoves(MoveNode* root, unsigned& count)
{
	typedef mstl::vector<MoveNode*> Vars;

	Vars varList;
	Move move;

	while (true)
	{
		MoveNode* node;

		switch (decodeMove(move, count))
		{
			case Token_Move:
				if (move)
				{
					node = new MoveNode(move);

					if (varList.empty())
					{
						root->setNext(node);
					}
					else
					{
						// first variation is main line
						// main line is last variation

						MoveNode* main = varList[0];

						if (!main->next())
							IO_RAISE(Game, Corrupted, "bad data");

						root->setNext(main->removeNext());
						root = root->next();

						for (unsigned i = 1; i < varList.size(); ++i)
						{
							MoveNode* var  = varList[i];
							MoveNode* next = var->next();

#ifndef ALLOW_EMPTY_VARS
							if (next->atLineEnd())
							{
								// Scidb does not support empty variations,
								// but we cannot delete the variation if a
								// comment/annotation/mark exists. As a
								// workaround we insert a null move.
								// Note: Possibly it isn't possible to enter
								// empty variations in ChessBase, but we like
								// to handle this case for safety reasons.
								if (var->hasSupplement() || next->hasSupplement())
								{
									Move null(Move::null());
									null.setColor(move.color());
									next = new MoveNode(null);
									next->setNext(var->removeNext());
									var->setNext(next);
								}
							}
#endif

							if (next->isBeforeLineEnd())
								root->addVariation(var);
						}

						root->addVariation(main);
						main->setNext(node);
						varList.clear();
					}

					getAnnotation(node, int(count) - 1);
					root = node;
				}
				else
				{
					throw DecodingFailedException("corrupted data");
				}
				break;

			case Token_Push:
				node = new MoveNode;
				varList.push_back(node);
				decodeMoves(node, count);
				break;

			case Token_Pop:
				root->setNext(new MoveNode);
				return;
		}
	}
}


void
GameDecoder::decodeMoves(MoveNode* root, unsigned& count, MoveNodeAllocator& allocator)
{
	typedef mstl::vector<MoveNode*> Vars;

	Vars varList;
	Move move;

	while (true)
	{
		MoveNode* node;

		switch (decodeMove(move, count))
		{
			case Token_Move:
				if (move)
				{
					(node = allocator.allocate())->setMove(move);

					if (varList.empty())
					{
						M_REQUIRE(root->next() == 0);
						root->setNext(node);
					}
					else
					{
						// first variation is main line
						// main line is last variation

						MoveNode* main = varList[0];

						if (!main->next())
							IO_RAISE(Game, Corrupted, "bad data");

						M_REQUIRE(root->next() == 0);
						root->setNext(main->removeNext());
						root = root->next();

						for (unsigned i = 1; i < varList.size(); ++i)
						{
							MoveNode* var  = varList[i];
							MoveNode* next = var->next();

#ifndef ALLOW_EMPTY_VARS
							if (next->atLineEnd())
							{
								// Scidb does not support empty variations,
								// but we cannot delete the variation if a
								// comment/annotation/mark exists. As a
								// workaround we insert a null move.
								// Note: Possibly it isn't possible to enter
								// empty variations in ChessBase, but we like
								// to handle this case for safety reasons.
								if (var->hasSupplement() || next->hasSupplement())
								{
									Move null(Move::null());
									null.setColor(move.color());
									(next = allocator.allocate())->setMove(null);
									M_REQUIRE(next->next() == 0);
									next->setNext(var->removeNext());
									M_REQUIRE(var->next() == 0);
									var->setNext(next);
								}
							}
#endif

							if (next->isBeforeLineEnd())
								root->addVariation(var);
						}

						root->addVariation(main);
						M_REQUIRE(main->next() == 0);
						main->setNext(node);
						varList.clear();
					}

					getAnnotation(node, int(count) - 1);
					root = node;
				}
				else
				{
					throw DecodingFailedException("corrupted data");
				}
				break;

			case Token_Push:
				node = allocator.allocate();
				varList.push_back(node);
				decodeMoves(node, count, allocator);
				break;

			case Token_Pop:
				M_REQUIRE(root->next() == 0);
				root->setNext(allocator.allocate());
				return;
		}
	}
}


MoveNode*
GameDecoder::decodeMoves(MoveNode* root)
{
	unsigned count = 0;
	decodeMoves(root, count);
	return root;
}


MoveNode*
GameDecoder::decodeMoves(MoveNodeAllocator& allocator)
{
	unsigned		count	= 0;
	MoveNode*	root	= allocator.allocate();

	decodeMoves(root, count, allocator);
	return root;
}


void
GameDecoder::startDecoding(TagSet* tags)
{
	unsigned word = m_gStrm.uint32();

	if (word & 0x40000000)
	{
		unsigned size = m_isChess960 ? 36 : 28;

		BitStream bstrm(m_gStrm.data(), size);
		m_position.setup(bstrm);
		m_gStrm.skip(size);

		if (tags)
		{
			tags->set(tag::SetUp, "1");	// bad PGN design
			tags->set(tag::Fen, m_position.board().toFen(variant::Normal, Board::Shredder));
		}
	}
	else
	{
		m_position.setup();
	}
}


unsigned
GameDecoder::doDecoding(uint16_t* moves, unsigned length, Board& startBoard)
{
	startDecoding();
	startBoard = m_position.board();

	unsigned	count	= 0;
	Move		move;

	for (unsigned i = 0; i < length; ++i)
	{
		switch (decodeMove(move, count))
		{
			case Token_Move:
				moves[i++] = move.index();
				break;

			case Token_Pop:
				return i;
		}
	}

	return length;
}


unsigned
GameDecoder::doDecoding(GameData& data)
{
	startDecoding(&data.m_tags);
	data.m_startBoard = m_position.board();
	unsigned plyNumber = m_position.board().plyNumber();
	decodeMoves(data.m_startNode);
	return m_position.board().plyNumber() - plyNumber;
}


save::State
GameDecoder::doDecoding(Consumer& consumer,
								TagSet& tags,
								GameInfo const& info,
								MoveNodeAllocator& allocator)
{
	startDecoding(&tags);

	if (!consumer.startGame(tags, m_position.board()))
		return save::UnsupportedVariant;

	unsigned plyNumber = m_position.board().plyNumber();
	consumer.startMoveSection();

#if 0
	// Annoying. We cannot use the direct decoding, because the
	// game may contain wrong information about the existence of
	// sub-variations.
	if (info.countVariations() == 0 && info.countComments() == 0)
	{
		// fast decoding
		decodeMoves(consumer);
	}
	else
#endif
	{
		allocator.release();
		allocator.reserve(mstl::mul2(m_gStrm.size()));
		traverse(consumer, decodeMoves(allocator));
	}

	char buf[32];
	::sprintf(buf, "%u", m_position.board().plyNumber() - plyNumber);
	tags.set(tag::PlyCount, buf);

	consumer.finishMoveSection(result::fromString(tags.value(tag::Result)));
	return consumer.finishGame(tags);
}


db::Move
GameDecoder::findExactPosition(Board const& position, bool skipVariations)
{
	startDecoding();

	unsigned	count = 0;
	bool		found	= false;
	Move		move;

	if (m_position.board().isEqualPosition(position))
		found = true;

	while (true)
	{
		unsigned tag = decodeMove(move, count);

		if (found)
			return move;

		switch (tag)
		{
			case Token_Move:
				if (!move || !m_position.board().signature().isReachablePawns(position.signature()))
					return Move::invalid();
				if (m_position.board().isEqualPosition(position))
					found = true;
				break;

			case Token_Pop:
				if (skipVariations)
					return Move::invalid();
				break;
		}
	}

	return move;	// not reached
}

// vi:set ts=3 sw=3:
