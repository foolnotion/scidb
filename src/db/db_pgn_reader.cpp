# // ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//  _/|            __
// // o\         /    )           ,        /    /
// || ._)    ----\---------__----------__-/----/__-
// //__\          \      /   '  /    /   /    /   )
// )___(     _(____/____(___ __/____(___/____(___/_
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

#include "db_pgn_reader.h"
#include "db_consumer.h"
#include "db_player.h"
#include "db_mark_set.h"
#include "db_tag_set.h"
#include "db_date.h"
#include "db_comment.h"
#include "db_eco.h"
#include "db_game_info.h"
#include "db_pgn_aquarium.h"
#include "db_eco_table.h"
#include "db_line.h"
#include "db_exception.h"

#include "nsUniversalDetector.h"

#include "u_progress.h"
#include "u_nul_string.h"

#include "m_algorithm.h"
#include "m_istream.h"
#include "m_stdio.h"

#include "sys_utf8.h"
#include "sys_utf8_codec.h"

#include <ctype.h>
#include <stdlib.h>
#include <math.h>

using namespace db;
using namespace db::tag;
using namespace util;

enum { None, Piece, Fyle, Rank, Capture, Drop };


#define _ None
#define P Piece
#define F Fyle
#define R Rank
#define C Capture
#define D Drop
static char const CharToType[256] =
{
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
//     !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	 _, _, _, _, _, _, _, _, _, _, _, _, _, C, _, _,
//  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	 _, R, R, R, R, R, R, R, R, _, C, _, _, _, _, _,
//  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	 D, _, P, _, _, _, _, _, _, _, _, P, _, _, P, _,
//  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  -
	 P, P, P, _, _, _, _, _, _, _, _, _, _, _, _, _,
//  '  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	 _, F, F, F, F, F, F, F, F, _, _, _, _, _, _, _,
//  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~ DEL
	 _, _, _, _, _, _, _, _, C, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
};
#undef _
#undef F
#undef P
#undef R
#undef C
#undef D

static unsigned const MaxWarnings	= 40;
static unsigned const MaxErrors		= 40;


static bool
matchEndOfSentence(char const* lhs, char const* rhs, unsigned len)
{
	return strncasecmp(lhs, rhs, len) == 0 && (lhs[len] == '\0' || lhs[len + 1] == '\0');
}


static bool
equal(char const* lhs, char const* rhs)
{
	return strcmp(lhs, rhs) == 0;
}


static bool
equal(char const* lhs, char const* rhs, unsigned len)
{
	return strncmp(lhs, rhs, len) == 0;
}


static bool
caseEqual(char const* lhs, char const* rhs, unsigned len)
{
	return strncasecmp(lhs, rhs, len) == 0;
}


static
void
parseChessOkComment(mstl::string& s)
{
	switch (*s.c_str())
	{
		case '<':
			// strip html tags from comments like {<font color=red>-12.13|d11</font>}
			if (equal(s, "<font color=", 11) && equal(s.end() - 7, "</font>", 7))
			{
				mstl::string::size_type n = s.find('>');

				if (n != mstl::string::npos)
				{
					s.replace(0, n + 1, "[%eval ", 7);
					s.replace(s.size() - 7, 7, "]", 1);
				}
			}
			break;

		case '&':
			// strip html tags from comments like {&lt;font color=red&gt;-12.13|d11&lt;/font&gt;}
			if (equal(s, "&lt;font color=", 15) && equal(s.end() - 13, "&lt;/font&gt;", 13))
			{
				mstl::string::size_type n = s.find("&gt;");

				if (n != mstl::string::npos && n < s.size() - 4)
				{
					s.replace(0, n + 4, "[%eval ", 7);
					s.replace(s.size() - 13, 13, "]", 1);
				}
			}
			break;

		case '-':
		case '+':
			// handle evaluations like {-0.78}
			if (isdigit(s[1]) && s[2] == '.' && isdigit(s[3]) && isdigit(s[4]) && s.size() == 5)
			{
				mstl::string t;
				t.append("[%eval ", 7);
				t.append(s);
				t.append(']');
				t.swap(s);
			}
			break;

//		case 'R':
//			// strip comments like {Rybka Aquarium (0:00:08)}
//			if (equal(s, "Rybka Aquarium (", 16))
//			{
//				char const* p = s.c_str() + 16;
//
//				while (*p == ':' || isdigit(*p))
//					++p;
//
//				if (*p == ')')
//				{
//					s.erase(s.begin(), p + 1);
//					s.ltrim();
//				}
//			}
//			break;
	}
}


static
void
join(Comment* first, Comment* last)
{
	for (Comment* next = first + 1; next < last; ++next)
		first->append(*next, ' ');
}


static
unsigned
total(PgnReader::GameCount& count)
{
	unsigned sum = 0;

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
		sum += count[v];

	return sum;
}


static mstl::string
quote(mstl::string const& s)
{
	mstl::string t;

	for (mstl::string::const_iterator i = s.begin(); i != s.end(); ++i)
	{
		if (*i == '"')
			t += '\\';
		t += *i;
	}

	return t;
}


static bool
isMoveToken(char const* s)
{
	while (CharToType[int(*s)] != None)
		++s;

	return !::isalnum(*s);
}


static char const*
skipMoveToken(char const* s)
{
	while (CharToType[int(*s)] != None)
		++s;

	return s;
}


static char const*
skipSpaces(char const* s)
{
	while (isspace(*s))
		++s;
	return s;
}


static char const*
skipWord(char const* s)
{
	while (*s && !isspace(*s))
		++s;
	return s;
}


static mstl::string
trim(mstl::string const& s)
{
	mstl::string t(s);
	t.trim();
	return t;
}


static void
addSpace(mstl::string& s)
{
	if (!s.empty() && !::isspace(s.back()))
		s += ' ';
}


static bool
checkScore(mstl::string const& s)
{
	if (s.find_first_not_of('?') == mstl::string::npos)
		return true;

	for (unsigned i = 0; i < s.size(); ++i)
	{
		if (!::isdigit(s[i]))
			return false;
	}

	return true;
}


static mstl::string
itos(unsigned n)
{
	char buf[32];
	snprintf(buf, sizeof(buf), "%u", n);
	return buf;
}


static bool
isEmpty(char const* s)
{
	while (::isspace(*s))
		++s;

	return *s == '\0';
}


static void
appendSpace(mstl::string& str)
{
	if (!str.empty() && !isspace(str.back()))
		str += ' ';
}


static bool
setTermination(db::TagSet& tags, termination::Reason reason)
{
	tags.set(tag::Termination, termination::toString(reason));
	return false;
}


namespace {

struct CharsetDetector : public nsUniversalDetector
{
	CharsetDetector() :m_encoding(sys::utf8::Codec::latin1()) {}
   void Report(const char* aCharset) override { m_encoding = aCharset; }
	mstl::string m_encoding;
};

} // namespace


PgnReader::Interruption::Interruption(Error code, mstl::string const& msg) :error(code), message(msg) {}
PgnReader::Pos::Pos() : line(0), column(0) {}


PgnReader::PgnReader(mstl::istream& stream,
							variant::Type variant,
							mstl::string const& encoding,
							ReadMode readMode,
							Modification modification,
							ResultMode resultMode)
	:Reader(format::Pgn)
	,m_stream(stream)
	,m_fileOffsets(0)
	,m_gameNumberInFile(0)
	,m_currentOffset(0)
	,m_lineOffset(0)
	,m_putback(0)
	,m_linePos(0)
	,m_lineEnd(0)
	,m_readMode(readMode)
	,m_resultMode(resultMode)
	,m_prefixAnnotation(nag::Null)
	,m_ignoreNags(false)
	,m_noResult(false)
	,m_result(result::Unknown)
	,m_timeMode(time::Unknown)
	,m_modification(modification)
	,m_generalModification(modification)
	,m_parsingFirstHdr(true)
	,m_parsingTags(false)
	,m_eof(false)
	,m_hasNote(false)
	,m_atStart(true)
	,m_parsingComment(false)
	,m_sourceIsPossiblyChessBase(false)
	,m_sourceIsChessOK(false)
	,m_encodingFailed(false)
	,m_ficsGamesDBGameNo(false)
	,m_checkShufflePosition(false)
	,m_isICS(false)
	,m_hasCastled(false)
	,m_resultCorrection(false)
	,m_isAscii(encoding == sys::utf8::Codec::automatic())
	,m_countRejected(0)
	,m_postIndex(0)
	,m_idn(0)
	,m_variant(variant)
	,m_givenVariant(variant)
	,m_encoding(encoding)
	,m_codec(0)
{
	M_REQUIRE(encoding == sys::utf8::Codec::automatic() || sys::utf8::Codec::checkEncoding(encoding));

	::memset(m_accepted, 0, sizeof(m_accepted));
	::memset(m_rejected, 0, sizeof(m_rejected));

	::memset(m_gameCount, 0, sizeof(m_gameCount));

	if (m_readMode == File)
		parseDescription(m_stream, m_description, &m_encoding);

	m_codec = new sys::utf8::Codec(m_isAscii ? sys::utf8::Codec::latin1() : m_encoding);
	convertToUtf(m_description);

	Producer::setVariant(variant);
	::memset(m_countWarnings, 0, sizeof(m_countWarnings));
	::memset(m_countErrors, 0, sizeof(m_countErrors));
}


PgnReader::~PgnReader() throw()
{
	delete m_codec;
}


variant::Type
PgnReader::detectedVariant() const
{
	return m_variant;
}


void
PgnReader::setup(FileOffsets* fileOffsets)
{
	if ((m_fileOffsets = fileOffsets))
		m_fileOffsets->reserve(estimateNumberOfGames());
}


mstl::string const&
PgnReader::description() const
{
	return m_description;
}


bool
PgnReader::encodingFailed() const
{
	return m_codec->failed();
}


mstl::string const&
PgnReader::encoding() const
{
	return m_codec->encoding();
}


uint16_t
PgnReader::idn() const
{
	return m_idn;
}


variant::Type
PgnReader::getVariant() const
{
	variant::Type variant = consumer().variant();

	if (variant == variant::Undetermined)
		variant = variant::Normal;

	return variant::toMainVariant(variant);
}


inline
void
PgnReader::putback(int c)
{
	M_ASSERT(m_putback < sizeof(m_putbackBuf));
	M_ASSERT(c);

	if (c != '\n')
	{
		m_putbackBuf[m_putback++] = c;
		--m_currPos.column;
	}
}


mstl::string
PgnReader::inverseFigurineMapping(mstl::string const& str)
{
	mstl::string result(str);
	if (!m_figurine.empty())
		replaceFigurineSet(m_figurine, "KQRBNP", result);
	return result;
}


unsigned
PgnReader::gameNumber(variant::Type variant) const
{
	if (variant == variant::Undetermined)
		return 0;

	unsigned index = variant::toIndex(variant::toMainVariant(variant));
	return m_gameNumbers[index] + m_gameCount[index] + 1;
}


void
PgnReader::fatalError(save::State state, variant::Type variant)
{
	sendWarnings();
	error(state, m_currPos.line, gameNumber(variant), variant);
	throw Termination();
}


void
PgnReader::sendError(Error code, Pos pos, mstl::string const& item)
{
	if (m_readMode != File && code == UnexpectedEndOfInput)
	{
		putMove(true);
		sendWarnings();
		throw Termination();
	}

	if (m_parsingFirstHdr)
	{
		error(SeemsNotToBePgnText,
				pos.line, 0, 0,
				variant::Undetermined,
				mstl::string::empty_string,
				mstl::string::empty_string,
				mstl::string::empty_string);
		throw Termination();
	}

	if (code == UnsupportedVariant)
	{
		if (!item.empty())
			m_thisVariant = variant::fromString(item);

		if (m_thisVariant == variant::Undetermined)
			++m_variants[item];
		else
			++m_rejected[variant::toIndex(variant::toMainVariant(m_thisVariant))];

		m_move.clear();
		throw Interruption(code, mstl::string::empty_string);
	}

	if (++m_countErrors[code] == MaxErrors)
	{
		warning(	MaximalErrorCountExceeded,
					pos.line, 0, 0,
					variant::Undetermined,
					mstl::string::empty_string,
					mstl::string::empty_string);
	}
	
	if (m_countErrors[code] >= MaxErrors)
		return;

	variant::Type variant = getVariant();
	unsigned gameNumber = this->gameNumber(variant);

	mstl::string myItem = ::quote(item);
	mstl::string msg;

	// TODO i18n
	switch (unsigned(code))
	{
		case InvalidToken:				msg += "Error parsing PGN file: invalid token " + myItem; break;
		case UnexpectedSymbol:			msg += "Error parsing PGN file: unexpected symbol " + myItem; break;
		case UnexpectedEndOfInput:		msg += "Error parsing PGN file: unexpected end of input"; break;
		case UnexpectedTag:				msg += "Error parsing PGN file: unexpected tag inside game";break;
		case UnexpectedEndOfGame:		msg += "Error parsing PGN file: unexpected end of game"; break;
		case UnterminatedVariation:	msg += "Error parsing PGN file: unterminated variation"; break;
		case InvalidMove:					msg += "Error parsing PGN file: illegal move " + myItem; break;
		case InvalidFen:					gameNumber = 0; pos.column = 0; break;
		default:								pos.column = 0; break;
	}

	// do line pos correction
	switch (unsigned(code))
	{
		case InvalidToken:
		case UnexpectedSymbol:
		case InvalidMove:
		case UnexpectedTag:
			if (m_linePos > m_line.begin() && !::equal(item, m_linePos, item.size()))
			{
				advanceLinePos(-1);
				if (m_linePos > m_line.begin() && !::equal(item, m_linePos, item.size()))
					advanceLinePos(-1);
			}
			break;
	}

	mstl::string info;

	if (m_tags.contains(White) && m_tags.contains(Black))
		info = m_tags.value(White) + " - " + m_tags.value(Black);

	error(code, pos.line, pos.column, gameNumber, variant, msg, info, myItem);

	if (code == InvalidMove || !m_move.isLegal())
		m_move.clear();

	if (code != ContinuationsNotSupported)
		throw Interruption(code, msg);
}


void
PgnReader::sendWarning(Warning code, Pos pos, mstl::string const& item)
{
	switch (unsigned(code))
	{
		case InvalidNag:
		case TooManyNags:
		case IllegalCastling:
			break;

		case ResultDidNotMatchHeaderResult:
			if (m_resultCorrection)
				return;
			break;

		case ResultCorrection:
			m_resultCorrection = true;
			break;

		default:
			pos.column = 0;
			break;
	}

	if (m_countWarnings[code] == MaxWarnings)
	{
		warning(	MaximalWarningCountExceeded,
					pos.line, 0, 0,
					variant::Undetermined,
					mstl::string::empty_string,
					mstl::string::empty_string);
		return;
	}
	
	WarningItem& w = m_warnings.push_back();
	w.code = code;
	w.variant = m_variant;
	w.pos = pos;
	w.item = item;
}


void
PgnReader::sendError(Error code, mstl::string const& item)
{
	sendError(code, m_currPos, item);
}


void
PgnReader::sendWarning(Warning code, mstl::string const& item)
{
	sendWarning(code, m_currPos, item);
}


bool
PgnReader::testVariant(variant::Type variant) const
{
	switch (m_variant)
	{
		case variant::Undetermined:
			return !variant::isAntichessExceptLosers(variant) || !m_hasCastled;

		case variant::Normal:
			return variant == variant::Normal;

		case variant::ThreeCheck:
			return variant == variant::ThreeCheck;

		case variant::Crazyhouse:
			return variant == variant::Normal || variant == variant::Crazyhouse;

		case variant::Antichess:
		case variant::Suicide:
		case variant::Giveaway:
			return variant::isAntichessExceptLosers(variant);

		case variant::Losers:
			return variant == variant::Losers;

		case variant::Bughouse:
			return false;
	}

	return true; // satisfies the compiler
}


void
PgnReader::setupVariant(variant::Type variant)
{
	M_ASSERT(variant != variant::Antichess);

	if (!consumer().supportsVariant(variant))
		sendError(UnsupportedVariant, m_currPos, variant::identifier(variant));

	consumer().setVariant(m_variant = variant);
	m_tags.set(tag::Variant, variant::identifier(variant));
}


unsigned
PgnReader::estimateNumberOfGames(unsigned fileSize)
{
	if (fileSize == 0)
		return 0;

	return mstl::max(1u, unsigned(::ceil(fileSize/696.0)));
}


unsigned
PgnReader::estimateNumberOfGames()
{
	return estimateNumberOfGames(m_stream.size());
}


unsigned
PgnReader::process(Progress& progress)
{
	M_REQUIRE(hasConsumer());

	try
	{
		Token		token			= m_readMode == Variation ? kTag : searchTag();
		unsigned	streamSize	= m_stream.size();
		unsigned	numGames		= estimateNumberOfGames(streamSize);
		unsigned	frequency	= mstl::min(35u, progress.frequency(numGames, 1000));
		unsigned	reportAfter	= frequency;

		variant::Type givenVariant = Reader::variant();

		ProgressWatcher watcher(progress, streamSize);

		while (token == kTag)
		{
			if (reportAfter == m_gameNumberInFile++)
			{
				progress.update(m_stream.goffset());

				if (progress.interrupted())
					return ::total(m_gameCount);

				reportAfter += frequency;
			}

			try
			{
				m_noResult = false;
				m_parsingFirstHdr = false;
				m_comments.clear();
				m_marks.clear();
				m_variantValue.clear();
				m_annotation.clear();
				m_timeMode = time::Unknown;
				m_parsingComment = false;
				m_idn = variant::Standard;
				m_ignoreNags = false;
				m_hasNote = false;
				m_atStart = true;
				m_significance[color::White] = 1;
				m_significance[color::Black] = 1;
				m_postIndex = 0;
				m_ficsGamesDBGameNo = false;
				m_checkShufflePosition = false;
				m_isICS = false;
				m_hasCastled = false;
				m_resultCorrection = false;
				m_warnings.clear();
				m_givenVariant = givenVariant;
				m_thisVariant = variant::Undetermined;
				m_sourceIsPossiblyChessBase = false;
				m_sourceIsChessOK = false;
				m_modification = m_generalModification;
				m_eco.clear();

				if ((m_variant = m_givenVariant) == variant::Antichess)
					m_variant = variant::Suicide;

				if (m_readMode != Variation)
				{
					m_parsingTags = true;
					readTags();
					m_parsingTags = false;

					if (	m_modification == Normalize
						&& m_tags.contains(PlyCount)
						&& m_tags.contains(EventCountry))
					{
						m_sourceIsPossiblyChessBase = true;
					}
				}

				if (m_variant != variant::Undetermined && !m_tags.contains(tag::Variant))
					m_tags.set(tag::Variant, variant::identifier(m_givenVariant = m_variant));

				if (m_variant != variant::Undetermined && !consumer().supportsVariant(m_variant))
					sendError(UnsupportedVariant, m_currPos, m_tags.value(tag::Variant));

				consumer().setupVariant(m_variant == variant::Undetermined ? variant::Normal : m_variant);

				if (variant::isAntichessExceptLosers(m_variant) && m_idn <= 960)
					m_idn += 3*960;

				if (!consumer().startGame(m_tags, m_idn))
					sendError(UnsupportedVariant, m_currPos, m_tags.value(tag::Variant));

				if (!m_eco && (m_variant == variant::Undetermined || m_variant == variant::Normal))
					consumer().useVariant(variant::Crazyhouse);

				consumer().startMoveSection();
				if (m_eco)
					setupEcoPosition();

				token = nextToken(kTag);

				unsigned nestedVar = 0;

				while (token == kSan)
				{
					m_ignoreNags = false;
					token = nextToken(token);

					// We want to detect constructions like "((...) (...) ...)".
					// The PGN standard does not forbid such things.
					while (token & (kStartVariation | kEndVariation))
					{
						putMove((token & kEndVariation));

						if (token == kEndVariation)
						{
							if (consumer().variationLevel() == 0)
								sendError(UnexpectedSymbol, m_prevPos, ")");

							if (m_hasNote)
							{
								::join(m_comments.begin(), m_comments.end());

								if (consumer().variationIsEmpty())
								{
									consumer().putPrecedingComment(m_comments[0], m_annotation, m_marks);
									m_comments.clear();
									m_annotation.clear();
									m_marks.clear();
								}
								else if (!m_comments.empty())
								{
									consumer().putTrailingComment(m_comments[0]);
									m_comments.clear();
									m_postIndex = 0;
								}

								m_hasNote = false;
							}

							consumer().finishVariation();

							if (nestedVar)
							{
								token = kStartVariation;
								--nestedVar;
							}
							else
							{
								token = nextToken(kEndVariation);
							}
						}
						else
						{
							consumer().startVariation();
							m_atStart = true;
							token = nextToken(kStartVariation);

							if (token == kStartVariation)
							{
								++nestedVar;
								token = nextToken(kStartVariation);
							}
						}
					}
				}

				putLastMove();
				checkVariant();
				sendWarnings();

				if (token == kError)
					unexpectedSymbol(kError, get());

				if (consumer().variationLevel() > 0)
					sendError(UnterminatedVariation);

				switch (token)
				{
					case kEoi:
						if (m_readMode != File)
						{
							finishGame();
							return 1;
						}
						sendError(UnexpectedEndOfInput);
						break;

					case kTag:
						if (m_readMode != File)
							sendError(UnexpectedTag, m_currPos);

						if (m_currPos.column == 1)
						{
							putback('[');
							sendError(UnexpectedEndOfGame, m_currPos);
						}

						m_prevPos = m_currPos;
						sendError(UnexpectedTag, m_prevPos);
						break;

					case kResult:
						if (m_noResult || m_resultMode == InMoveSection)
						{
							m_tags.set(Result, result::toString(m_result));
							checkResult();
						}
						else if (checkResult())
						{
							result::ID r = result::fromString(m_tags.value(Result));

							if (m_result != r)
							{
								sendWarning(ResultDidNotMatchHeaderResult,
												m_prevPos,
												result::toString(m_result));
								m_result = r;
							}
						}
						break;

					default:
						sendError(UnexpectedSymbol, m_currPos);
						break;
				}

				finishGame();
			}
			catch (Interruption const& exc)
			{
				if (m_parsingTags)
				{
					sendWarnings();
					findNextEmptyLine();
				}
				else
				{
					putLastMove();
					sendWarnings();
					handleError(exc.error, exc.message);
				}

				token = kResult;
			}

			if (token != kTag)
			{
				m_parsingTags = true;
				token = searchTag();
			}
		}
	}
	catch (Termination const&)
	{
	}

	if (m_fileOffsets)
	{
		if (m_countRejected)
			m_fileOffsets->setSkipped(m_countRejected);

		m_fileOffsets->append(m_currentOffset);
	}

	return ::total(m_gameCount);
}


void
PgnReader::sendWarnings()
{
	variant::Type variant = getVariant();

	for (Warnings::const_iterator i = m_warnings.begin(); i != m_warnings.end(); ++i)
	{
		if (	i->code != IllegalMove
			|| !variant::isAntichessExceptLosers(m_variant)
			|| variant::isAntichessExceptLosers(i->variant))
		{
			if (m_tags.contains(White) && m_tags.contains(Black))
			{
				warning(	i->code, i->pos.line, i->pos.column,
							gameNumber(variant),
							variant,
							m_tags.value(White) + " - " + m_tags.value(Black),
							::quote(i->item));
			}
			else
			{
				warning(	i->code, i->pos.line, i->pos.column,
							gameNumber(variant),
							variant,
							mstl::string::empty_string,
							::quote(i->item));
			}
		}
	}

	m_warnings.clear();
}


void
PgnReader::checkVariant()
{
	if (variant::isAntichessExceptLosers(m_variant))
	{
		if (board().checkState(m_variant) & Board::Stalemate)
		{
			result::ID result = result::fromString(m_tags.value(tag::Result));

			switch (int(result))
			{
				case result::White:
				case result::Black:
				{
					color::ID winner = result::color(result);
					color::ID loser  = color::opposite(winner);

					switch (int(m_variant))
					{
						case variant::Suicide:
							if (board().materialCount(winner).total() > board().materialCount(loser).total())
							{
								// the side with less pieces wins (FICS rules),
								// but winner has more pieces than black -> cannot be Suicide
								if (board().sideToMove() == winner)
								{
									// side to move wins (international rules),
									// but side not to move got the point -> cannot be Giveaway
									sendWarning(NotSuicideNotGiveaway);
								}
								else
								{
									if (m_givenVariant != variant::Giveaway)
										sendWarning(VariantChangedToGiveaway);
									setupVariant(variant::Giveaway);
								}
							}
							break;

						case variant::Giveaway:
							if (board().sideToMove() == loser)
							{
								// side to move wins (international rules),
								// but side not to move got the point -> cannot be Giveaway
								if (board().materialCount(winner).total() < board().materialCount(loser).total())
								{
									// the side with less pieces wins (FICS rules)
									if (m_givenVariant != variant::Giveaway)
										sendWarning(VariantChangedToSuicide);
									setupVariant(variant::Suicide);
								}
								else
								{
									sendWarning(NotSuicideNotGiveaway);
								}
							}
							break;
					}
					break;
				}

				case result::Draw:
					if (	m_variant == variant::Giveaway
						&& board().materialCount(color::White).total() ==
								board().materialCount(color::Black).total())
					{
						// must be Suicide
						if (m_givenVariant != variant::Giveaway)
							sendWarning(VariantChangedToSuicide);
						setupVariant(variant::Suicide);
					}
					break;
			}
		}
	}
}


bool
PgnReader::checkResult()
{
	result::ID given = result::fromString(m_tags.value(tag::Result));

	if (given == result::Unknown)
		return true;

	unsigned	state	= board().checkState(m_variant);
	bool		rc		= true;

	if (state & Board::Losing)
	{
		result::ID expected = result::fromColor(board().sideToMove());

		if (given != expected)
		{
			m_tags.set(tag::Result, result::toString(expected));
			sendWarning(ResultCorrection);
			rc = false;
		}
	}
	else if (state & (Board::Checkmate | Board::ThreeChecks))
	{
		result::ID expected = result::fromColor(board().notToMove());

		if (m_variant == variant::Losers)
			expected = result::opponent(expected);

		if (given != expected)
		{
			m_tags.set(tag::Result, result::toString(expected));
			sendWarning(ResultCorrection);
			rc = false;
		}
	}
	else if (state & Board::Stalemate)
	{
		result::ID expected;

		switch (int(m_variant))
		{
			case variant::Suicide:
			{
				unsigned totalW = board().materialCount(color::White).total();
				unsigned totalB = board().materialCount(color::Black).total();

				if (totalW == totalB)
					expected = result::Draw;
				else if (totalW < totalB)
					expected = result::White;
				else
					expected = result::Black;
				break;
			}

			case variant::Giveaway:
				expected = result::fromColor(board().notToMove());
				break;

			case variant::Losers:
				expected = result::fromColor(board().sideToMove());
				break;

			case variant::Normal:
			case variant::ThreeCheck:
			case variant::Crazyhouse:
				expected = result::Draw;
				break;

			case variant::Undetermined:
				// TODO: how should we handle this case?
				// fallthru

			default:
				return true;
		}

		if (given != expected)
		{
			m_tags.set(tag::Result, result::toString(expected));
			sendWarning(ResultCorrection);
			rc = false;
		}
	}

	return rc;
}


void
PgnReader::handleError(Error code, mstl::string const& message)
{
	if (code == UnsupportedVariant)
		return;

	mstl::string msg(message);

	if (code != UnexpectedEndOfGame)
	{
		mstl::string rest;

		if (code == UnexpectedSymbol && m_atStart && consumer().variationLevel() > 0)
			rest += '(';

		searchTag(&rest);
		rest.trim();

		if (!::isEmpty(rest))
		{
			msg += "\nRest of game: \"";

			if (m_move && !board().isValidMove(m_move, m_variant))
			{
				m_move.printSan(msg, protocol::Standard, encoding::Latin1);
				msg += ' ';
			}

			msg += rest;
			msg += '"';
		}
	}

	while (consumer().variationLevel() > 0)
		consumer().finishVariation();

	if (!msg.empty())
	{
		Comment comment(msg, false, false);
		consumer().putTrailingComment(comment);
	}

	finishGame(false);

	if (code == UnexpectedTag)
	{
		skipLine();
		searchTag();
	}
}


void
PgnReader::checkMode()
{
	event::Mode mode = event::Undetermined;

	if (m_tags.contains(Mode))
	{
		mode = event::modeFromString(m_tags.value(Mode));
	}
	else
	{
		mode = getEventMode(m_tags.value(Event), m_tags.value(tag::Site));

		if (mode != event::Undetermined)
			m_tags.add(Mode, event::toString(mode));
	}

	if (!m_tags.contains(TimeMode))
	{
		if (m_timeMode == time::Unknown)
		{
			switch (int(mode))
			{
				case event::PaperMail:
				case event::Email:
					m_timeMode = time::Corr;
					break;
			}
		}

		if (m_timeMode != time::Unknown)
			m_tags.add(TimeMode, time::toString(m_timeMode));
	}
}


void
PgnReader::finishGame(bool skip)
{
	consumer().finishMoveSection(m_result);

	if (m_modification == Normalize)
	{
		checkSite(m_tags, m_eventCountry, m_sourceIsPossiblyChessBase);
		checkMode();
	}

	if (m_variant == variant::Undetermined)
		consumer().setVariant(variant::Normal);

	save::State state;
	unsigned variantIndex = variant::toIndex(variant::toMainVariant(consumer().variant()));

	if (skip)
		state = consumer().skipGame(m_tags);
	else
		state = consumer().finishGame(m_tags);

	if (state == save::UnsupportedVariant)
	{
		if (m_countRejected == 0)
			m_fileOffsets->append(m_currentOffset);

		++m_rejected[variantIndex];
		++m_countRejected;
	}
	else
	{
		++m_accepted[variantIndex];

		if (m_fileOffsets)
		{
			if (m_countRejected)
			{
				m_fileOffsets->setSkipped(m_countRejected);
				m_countRejected = 0;
			}

			m_fileOffsets->append(m_currentOffset, variantIndex, m_gameCount[variantIndex]);
		}
	}

	variant::Type variant = getVariant();

	switch (state)
	{
		case save::Ok:								break;
		case save::UnsupportedVariant:		return; // already handled
		case save::DecodingFailed:				return; // cannot happen
		case save::TooManyGames:				fatalError(save::TooManyGames, variant);
		case save::FileSizeExeeded:			fatalError(save::FileSizeExeeded, variant);
		case save::TooManyPlayerNames:		fatalError(save::TooManyPlayerNames, variant);
		case save::TooManyEventNames:			fatalError(save::TooManyEventNames, variant);
		case save::TooManySiteNames:			fatalError(save::TooManySiteNames, variant);
		case save::TooManyAnnotatorNames:	fatalError(save::TooManyAnnotatorNames, variant);

		case save::TooManyRoundNames:
			error(save::TooManyRoundNames, m_currPos.line, m_gameNumberInFile, variant);
			break;

		case save::GameTooLong:
			error(save::GameTooLong, m_currPos.line, m_gameNumberInFile, variant::Undetermined);
			break;
	}

	++m_gameCount[variantIndex];
}


void
PgnReader::setUtf8Codec()
{
	delete m_codec;
	m_codec = new sys::utf8::Codec(sys::utf8::Codec::utf8());
	m_isAscii = false;
}


void
PgnReader::convertToUtf(mstl::string& s)
{
	if (s.empty() || sys::utf8::Codec::is7BitAscii(s))
		return;

	M_ASSERT(m_codec);

	if (m_isAscii)
	{
		if (m_encoding == sys::utf8::Codec::utf8())
		{
			setUtf8Codec();
		}
		else
		{
			M_ASSERT(m_codec->encoding() == sys::utf8::Codec::latin1());
			M_ASSERT(m_encoding == sys::utf8::Codec::automatic());

			m_isAscii = false;

			CharsetDetector detector;

			detector.HandleData(s, s.size());
			detector.DataEnd();
			
			if (detector.m_encoding == sys::utf8::Codec::utf8())
			{
				setUtf8Codec();
			}
			else
			{
				// the user has to choose the right encoding
			}
		}
	}

	m_codec->convertToUtf8(s, s);

	if (!sys::utf8::validate(s))
	{
		// user has chosen wrong encoding
		m_codec->forceValidUtf8(s);
	}

	if (__builtin_expect(m_codec->failed(), 0))
	{
		if (!m_encodingFailed)
		{
			sendWarning(EncodingFailed, m_prevPos);
			m_codec->reset();
			m_encodingFailed = true;
		}
	}
}


bool
PgnReader::parseFinalComment(mstl::string const& comment)
{
	char const* s = comment;

	switch (::toupper(*s))
	{
		case 'B':
			if (::matchEndOfSentence(s, "Black mates", 11))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "Both players ran out of time", 28))
				return ::setTermination(m_tags, termination::TimeForfeit);
			if (::matchEndOfSentence(s, "Bare king", 9))
				return ::setTermination(m_tags, termination::Normal);
			break;

		case 'D':
			if (::matchEndOfSentence(s, "Draw", 4))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "Draw agreed", 11))
				return ::setTermination(m_tags, termination::Normal);
			if (::equal(s, "Draw claim: ", 12))
			{
				s += 12;

				if (	::equal(s, "50-move rule", 12)
					|| ::equal(s, "3-fold repetition", 17)
					|| ::equal(s, "insufficient mating material", 28))
				{
					return ::setTermination(m_tags, termination::Normal);
				}
			}
			break;

		case 'F':
			if (::matchEndOfSentence(s, "Forfeits on time", 16))
				return ::setTermination(m_tags, termination::TimeForfeit);
			if (::matchEndOfSentence(s, "Forfeits by disconnection", 25))
				return ::setTermination(m_tags, termination::Disconnection);
			break;

		case 'N':
			if (::matchEndOfSentence(s, "Neither player has mating material", 34))
				return ::setTermination(m_tags, termination::Normal);
			break;

		case 'P':
			if (::matchEndOfSentence(s, "Partners' game drawn", 20))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "Partners' game aborted", 20))
				return ::setTermination(m_tags, termination::Abandoned);
			break;

		case 'T':
			if (::matchEndOfSentence(s, "Time forfeits", 13))
				return ::setTermination(m_tags, termination::TimeForfeit);
			break;

		case 'W':
			if (::matchEndOfSentence(s, "White mates", 11))
				return ::setTermination(m_tags, termination::Normal);
			break;

		case 'X':
			if (::equal(s, "Xboard adjudication: ", 21))
				return ::setTermination(m_tags, termination::Normal);
			break;
	}

	while (::isalnum(*s)) ++s;
	while (::isspace(*s)) ++s;

	switch (::tolower(*s))
	{
		case '\'':
			if (::matchEndOfSentence(s, "'s partner won", 14))
				return ::setTermination(m_tags, termination::Normal);
			break;

		case 'a':
			if (::matchEndOfSentence(s, "aborted by adjudication", 23))
				return ::setTermination(m_tags, termination::Adjudication);
			if (::matchEndOfSentence(s, "aborted by mutual agreement", 27))
				return ::setTermination(m_tags, termination::Abandoned);
			if (::matchEndOfSentence(s, "aborted on move 1", 27))
				return ::setTermination(m_tags, termination::Abandoned);
			if (::matchEndOfSentence(s, "aborted by simul holder", 23))
				return ::setTermination(m_tags, termination::Abandoned);
			if (::matchEndOfSentence(s, "aborted by server shutdown", 23))
				return ::setTermination(m_tags, termination::Disconnection);
			if (::matchEndOfSentence(s, "aborted", 7))
				return ::setTermination(m_tags, termination::Abandoned);
			if (::matchEndOfSentence(s, "adjourned by mutual agreement", 34))
				return ::setTermination(m_tags, termination::Unterminated);
			if (::matchEndOfSentence(s, "adjourned by server shutdown", 33))
				return ::setTermination(m_tags, termination::Disconnection);
			if (::matchEndOfSentence(s, "adjourned by simul holder", 25))
				return ::setTermination(m_tags, termination::Unterminated);
			break;

		case 'c':
			if (::matchEndOfSentence(s, "checkmated", 10))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "courtesyaborted by White", 24))
				return ::setTermination(m_tags, termination::Abandoned);
			if (::matchEndOfSentence(s, "courtesyaborted by Black", 24))
				return ::setTermination(m_tags, termination::Abandoned);
			if (::matchEndOfSentence(s, "courtesyaborted by White", 24))
				return ::setTermination(m_tags, termination::Unterminated);
			if (::matchEndOfSentence(s, "courtesyaborted by Black", 24))
				return ::setTermination(m_tags, termination::Unterminated);
			break;

		case 'd':
			if (::matchEndOfSentence(s, "drawn because both players ran out of time", 42))
				return ::setTermination(m_tags, termination::TimeForfeit);
			if (::matchEndOfSentence(s, "drawn by mutual agreement", 25))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn by stalemate", 18))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn by repetition", 19))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn by the 50 move rule", 25))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn by stalemate (equal material)", 35))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn by stalemate (opposite color bishops)", 43))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn by adjudication", 21))
				return ::setTermination(m_tags, termination::Adjudication);
			if (::matchEndOfSentence(s, "drawn by mate on both boards", 28))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "drawn due to length", 28))
				return ::setTermination(m_tags, termination::Normal);
			break;

		case 'f':
			if (::matchEndOfSentence(s, "forfeits on time", 16))
				return ::setTermination(m_tags, termination::TimeForfeit);
			 if (::matchEndOfSentence(s, "forfeits by disconnection", 25))
				return ::setTermination(m_tags, termination::Disconnection);
			break;

		case 'l':
			if (::matchEndOfSentence(s, "lost connection; game adjourned", 13))
				return ::setTermination(m_tags, termination::Disconnection);
			if (::matchEndOfSentence(s, "lost connection and too few moves; game aborted", 47))
				return ::setTermination(m_tags, termination::Disconnection);
			if (::matchEndOfSentence(s, "lost connection", 15))
				return ::setTermination(m_tags, termination::Disconnection);
			break;

		case 'p':
			if (::matchEndOfSentence(s, "Partners' game adjourned", 24))
				return ::setTermination(m_tags, termination::Unterminated);
			break;

		case 'r':
			if (::matchEndOfSentence(s, "resigned", 8))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "resigns", 7))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "ran out of time", 15))
				return ::setTermination(m_tags, termination::TimeForfeit);

			if (::caseEqual(s, "ran out of time and ", 20))
			{
				s += 20;
				while (::isalnum(*s)) ++s;
				while (::isspace(*s)) ++s;

				if (::matchEndOfSentence(s, "has no material to mate", 23))
					return ::setTermination(m_tags, termination::TimeForfeit);
				if (::matchEndOfSentence(s, "has no material to win", 22))
					return ::setTermination(m_tags, termination::TimeForfeit);
			}
			break;

		case 'w':
			if (::matchEndOfSentence(s, "won", 3))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "was drawn", 9))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "was adjourned", 13))
				return ::setTermination(m_tags, termination::Unterminated);
			if (::matchEndOfSentence(s, "was sent for adjudication", 25))
				return ::setTermination(m_tags, termination::Unterminated);
			if (::matchEndOfSentence(s, "wins on time", 12))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "wins by adjudication", 20))
				return ::setTermination(m_tags, termination::Adjudication);
			if (::matchEndOfSentence(s, "wins by stalemate", 17))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "wins by losing all material", 27))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "wins by having less material", 28))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "wins by having less material (stalemate)", 40))
				return ::setTermination(m_tags, termination::Normal);
			if (::matchEndOfSentence(s, "went on to win", 14))
				return ::setTermination(m_tags, termination::Normal);
			break;
	}

	return true;
}


void
PgnReader::filterFinalComments()
{
	if (	m_modification != Raw
		&& (	!m_tags.contains(tag::Termination)
			|| termination::fromString(m_tags.value(tag::Termination)) == termination::Unknown))
	{
		for (Comments::iterator j = m_comments.begin(); j != m_comments.end(); ++j)
		{
			if (!parseFinalComment(j->content()))
				j = m_comments.erase(j) - 1;
		}
	}
}


void
PgnReader::putMove(bool lastMove)
{
	if (__builtin_expect(m_move, 1))
	{
		M_ASSERT(m_hasNote == (!m_comments.empty() || !m_marks.isEmpty() || !m_annotation.isEmpty()));

		if (m_hasNote)
		{
			if (m_postIndex > 0)
			{
				M_ASSERT(m_postIndex <= m_comments.size());

				if (lastMove)
				{
					filterFinalComments();
					if (m_postIndex > m_comments.size())
						--m_postIndex;
				}
				::join(m_comments.begin(), m_comments.begin() + m_postIndex);

				if (m_postIndex == m_comments.size())
				{
					consumer().putMove(m_move, m_annotation, m_comments[0], Comment(), m_marks);
					m_comments.clear();
				}
				else if (!lastMove)
				{
					consumer().putMove(m_move, m_annotation, m_comments[0], m_comments[m_postIndex], m_marks);
					m_comments.erase(m_comments.begin(), m_comments.begin() + m_postIndex + 1);
				}
				else if (m_comments.size() - m_postIndex > 1 && m_modification == Raw)
				{
					::join(m_comments.begin() + m_postIndex, m_comments.end() - 1);
					consumer().putMove(m_move, m_annotation, m_comments[0], m_comments[m_postIndex], m_marks);
					if (!m_comments.back().isEmpty())
						consumer().putTrailingComment(m_comments.back());
					m_comments.clear();
				}
				else
				{
					::join(m_comments.begin() + m_postIndex, m_comments.end());
					consumer().putMove(m_move, m_annotation, m_comments[0], m_comments[m_postIndex], m_marks);
					m_comments.clear();
				}
			}
			else if (!lastMove)
			{
				if (m_comments.empty())
					m_comments.push_back();
				consumer().putMove(m_move, m_annotation, Comment(), m_comments[0], m_marks);
				m_comments.erase(m_comments.begin());
			}
			else if (m_comments.size() > 1 && m_modification == Raw)
			{
				::join(m_comments.begin(), m_comments.end() - 1);
				consumer().putMove(m_move, m_annotation, Comment(), m_comments[0], m_marks);
				if (!m_comments.back().isEmpty())
					consumer().putTrailingComment(m_comments.back());
				m_comments.clear();
			}
			else
			{
				if (lastMove)
					filterFinalComments();
				if (m_comments.empty())
					m_comments.push_back();
				else
					::join(m_comments.begin(), m_comments.end());
				consumer().putMove(m_move, m_annotation, Comment(), m_comments[0], m_marks);
				m_comments.clear();
			}

			m_marks.clear();
			m_annotation.set(m_prefixAnnotation);
			m_prefixAnnotation = nag::Null;
			m_postIndex = m_comments.size();
			m_hasNote = !m_comments.empty();
		}
		else
		{
			consumer().putMove(m_move);
		}

		m_move.clear();
	}
	else
	{
		if (m_atStart)
		{
			if (m_comments.size() > 1)
			{
				if (m_modification == Raw)
				{
					consumer().putPrecedingComment(m_comments[0], m_annotation, m_marks);
					m_comments.erase(m_comments.begin());
				}
				else
				{
					::join(m_comments.begin(), m_comments.end() - 1);
					consumer().putPrecedingComment(m_comments[0], m_annotation, m_marks);
					m_comments.erase(m_comments.begin(), m_comments.end() - 1);
				}
			}
			else if (!m_annotation.isEmpty() || !m_marks.isEmpty())
			{
				consumer().putPrecedingComment(Comment(), m_annotation, m_marks);
			}

			m_marks.clear();
			m_annotation.clear();
			m_hasNote = !m_comments.empty();
			m_atStart = false;
		}

		m_postIndex = m_comments.size();
	}
}


void
PgnReader::putLastMove()
{
	if (m_move)
	{
		if (board().isValidMove(m_move, m_variant))
			putMove(true);
	}
	else if (m_hasNote)
	{
		filterFinalComments();

		if (consumer().variationIsEmpty())
		{
			if (m_comments.size() > 1 && m_modification == Raw)
			{
				::join(m_comments.begin() + 1, m_comments.end());
				consumer().putPrecedingComment(m_comments[0], m_annotation, m_marks);
				if (!m_comments[1].isEmpty())
					consumer().putTrailingComment(m_comments[1]);
			}
			else if (m_comments.size() > 0)
			{
				::join(m_comments.begin(), m_comments.end());
				consumer().putPrecedingComment(m_comments[0], m_annotation, m_marks);
			}
			else if (!m_annotation.isEmpty() || !m_marks.isEmpty())
			{
				consumer().putPrecedingComment(Comment(), m_annotation, m_marks);
			}
		}
		else if (!m_comments.empty())
		{
			// We have a comment after the last variation has finished,
			::join(m_comments.begin(), m_comments.end());
			if (!m_comments[0].isEmpty())
				consumer().putTrailingComment(m_comments[0]);
		}
	}
}


void
PgnReader::setupGameNumbers(GameCount const& gameNumbers)
{
	::memcpy(m_gameNumbers, gameNumbers, sizeof(GameCount));
}


void
PgnReader::setFigurine(mstl::string const& figurine)
{
	M_REQUIRE(figurine.size() == 6);
	M_REQUIRE(	::isalpha(figurine[0]) && ::isupper(figurine[0])
				&& ::isalpha(figurine[1]) && ::isupper(figurine[1])
				&& ::isalpha(figurine[2]) && ::isupper(figurine[2])
				&& ::isalpha(figurine[3]) && ::isupper(figurine[3])
				&& ::isalpha(figurine[4]) && ::isupper(figurine[4])
				&& ::isalpha(figurine[5]) && ::isupper(figurine[5]));

	if (figurine == "KQRBNP")
		m_figurine.clear();
	else
		m_figurine = figurine;
}


void
PgnReader::advanceLinePos(int n)
{
	M_ASSERT(m_linePos + n <= m_lineEnd);
	M_ASSERT(0 <= n || -n <= int(m_currPos.column));

	m_linePos += n;
	m_currPos.column += n;
}


void
PgnReader::setLinePos(char* pos)
{
	M_ASSERT(pos >= m_linePos || m_linePos - pos <= int(m_currPos.column));

	m_currPos.column += pos - m_linePos;
	m_linePos = pos;
}


int
PgnReader::get(bool allowEndOfInput)
{
	if (m_putback)
	{
		++m_currPos.column;
		return m_putbackBuf[--m_putback];
	}

	if (m_lineEnd <= m_linePos)
	{
		m_lineOffset = m_stream.tellg();

		if (m_stream.getline(m_line))
		{
			m_linePos = m_line.begin();
			m_lineEnd = m_line.end();

			if (m_lineEnd > m_linePos && m_lineEnd[-1] == '\r')
			{
				M_ASSERT(m_line.readonly());
				m_line.hook(m_line.data(), m_line.size() - 1);
				m_lineEnd = m_line.end();
				m_lineEnd[0] = '\0';
			}

			if (!m_figurine.empty() && (!m_parsingTags || *m_line.begin() != '['))
				replaceFigurineSet("KQRBNP", m_figurine, m_line);

			m_currPos.column = 0;
			++m_currPos.line;
		}
		else if (m_eof)
		{
			if (!allowEndOfInput)
				sendError(UnexpectedEndOfInput);

			return '\0';
		}
		else
		{
			m_currentOffset = m_stream.tellg();
			m_eof = true;
		}

		return '\n';
	}

	++m_currPos.column;
	return *m_linePos++;
}


void
PgnReader::skipLine(mstl::string* str)
{
	if (str)
	{
		while (m_putback)
			str->append(m_putbackBuf[--m_putback]);

		str->append(m_linePos, m_lineEnd);
	}
	else
	{
		m_putback = 0;
	}

	m_linePos = m_lineEnd;
}


PgnReader::Token
PgnReader::skipToEndOfVariation(Token token)
{
	unsigned level = 1;

	do
	{
		int c = get();

		switch (c)
		{
			case '(':
			{
				Token token = parseOpenParen(kSan, c);

				if (token == kStartVariation)
					++level;

				break;
			}

			case ')':
			{
				Token token = parseCloseParen(kSan, c);

				if (token == kEndVariation)
					--level;

				break;
			}

			case '{':
				while (get() != '}')
					;
				break;

			case '[':
			{
				Token token = parseTag(kSan, c);

				if (token == kTag)
					return kTag;
			}

			case ';':
				skipLine();
				break;
		}
	}
	while (level > 0);

	m_move.clear();

	return token;
}


void
PgnReader::findNextEmptyLine()
{
	while (true)
	{
		int c = get(true);

		switch (c)
		{
			case '\0':
				return;

			case '\n':
				{
					int d = get(true);

					if (d == '\n' || d == '\0')
						return;
				}
				break;
		}
	}
}


PgnReader::Token
PgnReader::searchTag(mstl::string* str)
{
	enum { MaxSize = 2048u };

	static char const* MaxSizeExceeded = "...\n(Maximal size exceeded)";

	while (true)
	{
		int c = get(true);

		while (::isspace(c))
		{
			if (str)
			{
				if (str->size() < MaxSize)
					::addSpace(*str);
				else
					*str += MaxSizeExceeded;
			}

			c = get(true);
		}

		switch (c)
		{
			case '\0':
				return kEoi;

			case '[':
				if (str)
					putback(c);
				else
					m_currentOffset = m_lineOffset + m_currPos.column - 1;
				return kTag;

			case 0xef:
				if ((c = get(true)) == 0xbb)
				{
					if ((c = get(true)) == 0xbf)
						setUtf8Codec(); // UTF-8 BOM detected
					else
						putback(c);
				}
				else
				{
					putback(c);
				}
				break;

			default:
				if (str)
				{
					if (str->size() >= MaxSize)
						*str += MaxSizeExceeded;
					else if (::isspace(c))
						::addSpace(*str);
					else
						*str += c;
				}
				break;
		}

		skipLine(str);
	}

	return kEoi;	// satisfies the compiler
}


void
PgnReader::checkFen()
{
	M_ASSERT(m_tags.contains(Fen));

	mstl::string const& fen = m_tags.value(Fen);

	if (m_idn > 4*960)
	{
		mstl::string const& expectedFen = variant::fen(m_idn);

		// NOTE: FICS games do have wrong castling rights,
		// so we will match FEN w/o castling rights.

		char const* e = ::strchr(expectedFen, ' ');

		M_ASSERT(e && e[1] == 'w');

		if (!::equal(fen, expectedFen, e - expectedFen.c_str() + 2))
			m_idn = 0;
	}

	if (m_idn > 4*960)
	{
		m_tags.remove(Fen);
		m_tags.remove(SetUp);
		m_tags.remove(tag::Eco);
	}
	else
	{
		Board board;

		if (!board.setup(fen, m_variant))
			sendError(InvalidFen, m_fenPos, fen);

		Board::SetupStatus status = board.validate(m_variant);

		if (board.validate(m_variant) != Board::Valid)
		{
			if (status == Board::BadCastlingRights || status == Board::InvalidCastlingRights)
			{
				board.fixBadCastlingRights();

				if ((status = board.validate(m_variant)) == Board::Valid)
				{
					sendWarning(FixedInvalidFen, m_fenPos, fen);
					m_tags.set(Fen, board.toFen(m_variant));
				}
			}

			if (status != Board::Valid)
			{
				if (!m_eco && !m_variantValue.empty())
					sendError(UnsupportedVariant, m_prevPos, m_variantValue);

				sendError(InvalidFen, m_fenPos, fen);
			}
		}

		if (board.isStandardPosition(m_variant))
		{
			m_tags.remove(Fen);
			m_tags.remove(SetUp);
			m_idn = variant::Standard;
		}
		else if (m_idn == 0)
		{
			m_idn = board.computeIdn(m_variant);
			m_tags.remove(tag::Eco);

			if (m_idn == 0)
				m_tags.set(SetUp, "1");
			else
				m_tags.remove(Fen);
		}
		else if (m_eco)
		{
			if (EcoTable::specimen(variant::Index_Normal).getEco(board) == m_eco)
			{
				m_idn = variant::Standard;
				m_tags.remove(SetUp);
				m_tags.remove(Fen);
			}
			else
			{
				m_eco.clear();
			}
		}
	}
}


void
PgnReader::setupEcoPosition()
{
	M_ASSERT(m_eco);
	M_ASSERT(m_variant = variant::Normal);

	Board const&	board	= consumer().board();
	Line const&		line	= EcoTable::specimen(variant::Index_Normal).getLine(m_eco);

	for (unsigned i = 0; i < line.length; ++i)
	{
		m_move = board.makeMove(line[i]);
		putMove();
	}

	m_atStart = true;
}


bool
PgnReader::parseVariant()
{
	if (::equal(m_variantValue, "wild/", 5))
	{
		// wild/0	Reversed queen and king
		// wild/1	Random shuffle different on each side
		// wild/2	Random shuffle mirror sides
		// wild/3	Random pieces
		// wild/4	Random pieces balanced bishops
		// wild/5	Upside down
		// wild/7	Three pawns and a king (Little Game)
		// wild/8	Pawns start on 4th rank
		// wild/8a	Pawns on 5th rank
		// wild/9	Two kings for each side
		// wild/10	Handicap of pawn & move
		// wild/11	handicap of knight
		// wild/12	handicap of rook
		// wild/13	handicap of queen
		// wild/14	handicap of rook (a-pawn on a3)
		// wild/16	Kriegsspiel
		// wild/17	Losers Chess
		// wild/18	Power Chess
		// wild/19	King, Knight, Knight vs. King & Pawn
		// wild/20	Loadgame
		// wild/21	Thematic
		// wild/22	Fischer Random
		// wild/23	Crazyhouse
		// wild/24	Bughouse
		// wild/25	Three-Check Chess
		// wild/26	Giveaway Chess
		// wild/27	Atomic Chess
		// wild/28	Shatranj
		// wild/29	Random Wild
		// wild/fr	Fischer Random

		char const* v = m_variantValue.c_str() + 5;

		switch (*v)
		{
			case '1':
				if (::equal(v, "17")) // Losers
				{
					setupVariant(variant::Losers);
				}
				else if (::equal(v, "19")) // KNN vs. KP
				{
					setupVariant(variant::Normal);
					m_idn = variant::KNNvsKP;
				}
				else
				{
					return false;
				}
				break;

			case '2':
				if (::equal(v, "2")) // Shuffle chess
					setupVariant(variant::Normal);
				else if (::equal(v, "22") || equal(v, "fr")) // Chess 960
					setupVariant(variant::Normal);
				else if (::equal(v, "23")) // Crazyhouse
					setupVariant(variant::Crazyhouse);
				else if (::equal(v, "25")) // Three-check
					setupVariant(variant::ThreeCheck);
				else if (::equal(v, "26")) // Giveaway
					setupVariant(variant::Giveaway);
				else
					return false;
				break;

			case '5':
				if (::equal(v, "5")) // Upside down
				{
					setupVariant(variant::Normal);
					m_idn = variant::UpsideDown;
				}
				else
				{
					return false;
				}
				break;

			case '7':
				if (::equal(v, "7")) // Three pawns and a king (Little Game)
				{
					setupVariant(variant::Normal);
					m_idn = variant::LittleGame;
				}
				else
				{
					return false;
				}
				break;

			case '8':
				if (::equal(v, "8")) // Pawns start on 4th rank
				{
					setupVariant(variant::Normal);
					m_idn = variant::PawnsOn4thRank;
				}
				else
				{
					return false;
				}
				break;

			case 'f':
				if (::equal(v, "fr")) // Chess 960
					setupVariant(variant::Normal);
				else
					return false;
				break;

			default:
				return false;
		}
	}
	else if (::equal(m_variantValue, "misc/", 5))
	{
		// misc/little-game		same as wild/7
		// misc/pyramid			pyramidal pawn formation
		// misc/knights-only		standard position with knights only
		// misc/bishops-only		standard position with bishops only
		// misc/rooks-only		standard position with rooks only
		// misc/queens-only		standard position with queens only
		// misc/no-queens			standard position without queens
		// misc/runaway			standard position with king on 3rd/6th rank
		// misc/queen-rooks		Queen vs. rooks

		char const* v = m_variantValue.c_str() + 5;

		m_idn = 0;

		switch (*v)
		{
			case 'p':
				if (::equal(v, "pawns-only"))
					m_idn = variant::PawnsOnly;
				else if (::equal(v, "pyramid"))
					m_idn = variant::Pyramid;
				break;

			case 'k':
				if (::equal(v, "knights-only"))
					m_idn = variant::KnightsOnly;
				break;

			case 'b':
				if (::equal(v, "bishops-only"))
					m_idn = variant::BishopsOnly;
				break;

			case 'r':
				if (::equal(v, "rooks-only"))
					m_idn = variant::RooksOnly;
				else if (::equal(v, "runaway"))
					m_idn = variant::Runaway;
				break;

			case 'q':
				if (::equal(v, "queens-only"))
					m_idn = variant::QueensOnly;
				else if (::equal(v, "queen-rooks"))
					m_idn = variant::QueenVsRooks;
				break;

			case 'n':
				if (::equal(v, "no-queens"))
					m_idn = variant::NoQueens;
				break;

			case 'l':
				if (::equal(v, "little-game"))
					m_idn = variant::LittleGame;
				break;
		}

		if (m_idn == 0)
			return false;

		setupVariant(variant::Normal);
	}
	else if (::equal(m_variantValue, "odds/", 5))
	{
		setupVariant(variant::Normal);
	}
	else if (::equal(m_variantValue, "pawns/", 6))
	{
		// pawns/little-game		same as wild/7
		// pawns/pawns-only		standard position with pawns only
		// pawns/wild-five		all pawns on opponents pawn rank

		char const* v = m_variantValue.c_str() + 6;

		if (::equal(v, "pawns-only"))
			m_idn = variant::PawnsOnly;
		else if (::equal(v, "wild-five"))
			m_idn = variant::WildFive;
		else if (::equal(v, "little-game"))
			m_idn = variant::LittleGame;
		else
			return false;

		setupVariant(variant::Normal);
	}
	else if (::equal(m_variantValue, "endings/", 8))
	{
		// endings/kbnk	KBN vs. K
		// endibgs/kbbk	KBB vs. K

		char const* v = m_variantValue.c_str() + 8;

		if (::equal(v, "kbnk"))
			m_idn = variant::KBNK;
		else if (::equal(v, "kbbk"))
			m_idn = variant::KBBK;
		else
			return false;

		setupVariant(variant::Normal);
	}
	else if (::equal(m_variantValue, "eco/", 4))
	{
		mstl::string eco(m_variantValue.c_str() + 4);
		eco.toupper();
		m_eco.setup(eco);

		m_idn = 518;
		setupVariant(variant::Normal);
	}
	else if (::equal(m_variantValue, "openings/", 9))
	{
		mstl::string opening(m_variantValue.c_str() + 9, m_variantValue.size() - 9);

		if (::equal(opening, "falkbeer_cg", 11))
			m_eco.setup("C31");
		else if (::equal(opening, "albin_cg", 8))
			m_eco.setup("D08");

		m_idn = 518;
		setupVariant(variant::Normal);
	}
	else if (::equal(m_variantValue, "nic/", 4))
	{
		m_idn = 518;
		setupVariant(variant::Normal);
	}
	else
	{
		return false;
	}

	return true;
}


void
PgnReader::checkTags()
{
	if (m_tags.contains(Fen))
		checkFen();

	if (m_tags.contains(tag::Idn))
		m_tags.remove(tag::Idn);

	if (m_modification == Raw)
		return;

	if (!m_tags.contains(White))
	{
		if (!m_tags.contains(Black))
		{
			m_tags.set(Black, "?");
			sendWarning(MissingPlayerTags, m_prevPos);
		}

		m_tags.set(White, "?");
	}
	else if (!m_tags.contains(Black))
	{
		if (!m_tags.contains(White))
		{
			m_tags.set(White, "?");
			sendWarning(MissingPlayerTags, m_prevPos);
		}

		m_tags.set(Black, "?");
	}

	if (!m_tags.contains(Result))
	{
		sendWarning(MissingResultTag, m_prevPos);
		m_tags.set(Result, "*");
		m_noResult = true;
	}

	if (m_isICS || m_ficsGamesDBGameNo)
	{
		if (m_tags.contains(tag::WhiteElo))
		{
			mstl::string rating(m_tags.value(WhiteElo));
			m_tags.remove(WhiteElo);
			addTag(WhiteRating, rating);
		}
		if (m_tags.contains(tag::BlackElo))
		{
			mstl::string rating(m_tags.value(BlackElo));
			m_tags.remove(BlackElo);
			addTag(BlackRating, rating);
		}

		m_tags.add(WhiteType, species::Human);
		m_tags.add(BlackType, species::Human);

		m_tags.add(EventCountry, country::toString(country::The_Internet));
	}
}


bool
PgnReader::checkTag(ID tag, mstl::string& value)
{
	switch (tag)
	{
		case White:
		case Black:
			if (m_modification == Normalize && !value.empty())
			{
				Player::standardizeNames(value);

				// remove trailing chars
				while (::strchr(" .,", value.back()))
				{
					value.resize(value.size() - 1);

					if (value.empty())
						return true;
				}

				// extract player data
				{
					mstl::string v;

					while (Tag t = extractPlayerData(value, v))
					{
						switch (t)
						{
							case Elo:
								m_tags.add(tag == White ? WhiteElo : BlackElo, mstl::string(v, v.size()));
								break;

							case Country:
								m_tags.add(tag == White ? WhiteCountry : BlackCountry, mstl::string(v, v.size()));
								break;

							case Title:
								m_tags.add(tag == White ? WhiteTitle : BlackTitle, mstl::string(v, v.size()));
								break;

							case Sex:
								m_tags.add(tag == White ? WhiteSex : BlackSex, mstl::string(v, v.size()));
								break;

							case Human:
								m_tags.add(	tag == White ? WhiteType : BlackType,
												species::toString(species::Human));
								break;

							case Program:
								m_tags.add(	tag == White ? WhiteType : BlackType,
												species::toString(species::Program));
								break;

							case None:
								break;
						}

						// remove trailing chars
						while (!value.empty() && ::strchr(" .,", value.back()))
						{
							value.resize(value.size() - 1);

							if (value.empty())
								return true;
						}
					}
				}

				// standardize player names
				{
					mstl::string::size_type k = value.find(',');

					if (k != mstl::string::npos)
					{
						if (::isupper(value[k + 1]))
						{
							value.insert(k + 1, ' ');
						}
						else if (value[k + 1] == ' ' && value[k + 2] == ' ')
						{
							while (value[k + 2] == ' ')
								value.erase(k + 2, 1);
						}

						if (k > 1 && value[k - 1] == ' ' && value[k - 2] != ' ')
							value.erase(k - 1, 1);
					}

					while (value.size() > 1 && value.back() == '.')
						value.resize(value.size() - 1);
				}

				convertToUtf(value);
			}
			break;

		case Event:
			if (::equal(value, "FICS ", 5) || ::equal(value, "ICS ", 4) || ::equal(value, "internet ", 8))
			{
				mstl::string::size_type pos;

				if (value.find_ignore_case(" crazyhouse ") != mstl::string::npos)
				{
					setupVariant(variant::Crazyhouse);
				}
				else if (value.find_ignore_case(" suicide ") != mstl::string::npos)
				{
					setupVariant(variant::Suicide);
				}
				else if (value.find_ignore_case(" losers ") != mstl::string::npos)
				{
					setupVariant(variant::Losers);
				}
				else if (	(pos = value.find(" uwild/")) != mstl::string::npos
							|| (pos = value.find(" wild/")) != mstl::string::npos
							|| (pos = value.find(" pawns/")) != mstl::string::npos
							|| (pos = value.find(" atomic ")) != mstl::string::npos
							|| (pos = value.find(" misc/")) != mstl::string::npos
							|| (pos = value.find(" odds/")) != mstl::string::npos
							|| (pos = value.find(" endings/")) != mstl::string::npos)
				{
					char const *v = value.c_str() + pos + 1;

					m_variantValue.assign(v, ::skipWord(v));

					if (!parseVariant())
						sendError(UnsupportedVariant, m_prevPos, m_variantValue);
				}

				m_isICS = true;
			}
			if (m_modification == Normalize)
				convertToUtf(value);
			break;

		case tag::Site:
			if (m_modification == Normalize)
				convertToUtf(value);
			m_eventCountry = extractCountryFromSite(value);
			m_isICS = ::equal(value, "ICS:", 4);
			break;

		case Round:
			if (consumer().format() == format::Scidb)
			{
				unsigned round;
				unsigned subround;

				if (!parseRound(value, round, subround))
				{
					if (m_modification == Normalize)
						convertToUtf(value);
					sendWarning(InvalidRoundTag, m_prevPos, value);
				}
				else
				{
					value.clear();

					if (subround)
						value.format("%u.%u", round, subround);
					else if (round)
						value.format("%u", round);
					else
						value = '?';
				}
			}
			else if (m_modification == Normalize)
			{
				convertToUtf(value);
			}
			break;

		case WhiteCountry:
		case BlackCountry:
			if (m_modification == Normalize)
			{
				country::Code code = country::fromString(value);

				if (code == country::Unknown)
				{
					sendWarning(InvalidCountryCode, m_prevPos, value);
					return false;
				}

				value = country::toString(code);
			}
			break;

		case EventCountry:
			if (m_modification == Normalize)
			{
				country::Code code = country::fromString(value);

				if (code == country::Unknown)
				{
					sendWarning(InvalidCountryCode, m_prevPos, value);
					return false;
				}

				m_eventCountry = code;
			}
			break;

		case EventType:
			if (m_modification == Normalize && !value.empty())
			{
				if (value.back() == ')')
				{
					char* s = const_cast<char*>(::strchr(value.c_str(), '('));

					if (!s)
						return false;

					util::NulString v(s + 1, (value.end() - 1) - (s + 1));

					switch (time::Mode mode = time::fromString(v))
					{
						case time::Unknown:
							sendWarning(UnknownMode, m_prevPos, v);
							break;

						case time::Corr:
							m_tags.set(Mode, event::PaperMail);
							// fallthru

						default:
							m_tags.set(TimeMode, time::toString(mode));
							break;
					}

					while (s > value.c_str() && ::isspace(s[-1]))
						--s;

					if (s == value.c_str())
						return false;

					value.erase(s, value.end());
				}

				// strip values like "team-" or "team-tourn", but take into account that
				// an entry like "tourn-blitz" contains the time mode.
				mstl::string::size_type n = value.find('-');

				if (n != mstl::string::npos)
				{
					mstl::string v;
					v.hook(value.data() + n + 1, value.size() - n - 1);

					switch (time::Mode mode = time::fromString(v))
					{
						case time::Unknown:
							break;

						case time::Corr:
							m_tags.set(Mode, event::PaperMail);
							// fallthru

						default:
							m_tags.set(TimeMode, time::toString(mode));
							break;
					}

					value.erase(n, mstl::string::npos);
				}

				event::Type type = event::typeFromString(value);

				if (type == event::Unknown)
				{
					// It is not an event type. Then it should be a time mode entry.
					// (Bug or feature in ChessBase?)

					if (value != "?" && value != "-")
					{
						time::Mode mode = time::fromString(value);

						if (mode == time::Unknown)
						{
							sendWarning(UnknownEventType, m_prevPos, value);
							m_tags.setExtra(tag::toName(tag), value);
							return false;
						}

						m_tags.set(TimeMode, time::toString(mode));
					}
				}

				value = event::toString(type);
			}
			break;

		case WhiteTitle:
		case BlackTitle:
			if (m_modification == Normalize)
			{
				// often seen in TWIC files
				if (value == "--")
					return true;
				if (uint8_t(value[0]) == 0xC2) // 0xC2 0xA0 'NO-BREAK SPACE'
					return true;
				if (value == "MF")
					value = "FM"; // in Portuguese it's "MF"
				if (value == "WC")
					value = "WCM";
				if (value == "WF")
					value = "WFM";
				if (value == "NM")
					return true; // NM means National Master, skip silenty

				title::ID title = title::fromString(value);

				if (title == title::None)
				{
					sendWarning(UnknownTitle, m_prevPos, value);
					return false;
				}

				value = title::toString(title);
				m_tags.add(tag == WhiteTitle ? WhiteType : BlackType, "human");
			}
			break;

		case WhiteSex:
		case BlackSex:
			if (m_modification == Normalize)
			{
				sex::ID sex = sex::fromChar(value.c_str()[0]);	// safe access

				if (sex == sex::Unspecified)
				{
					switch (value.c_str()[0])
					{
						case 'c':
						case 'p':
							m_tags.add(tag == WhiteSex ? WhiteType : BlackType, "program");
							break;

						default:
							sendWarning(UnknownSex, m_prevPos, value);
							return false;
					}
				}

				M_ASSERT(value == sex::toString(sex));
			}
			break;

		case SetUp:
			// what should we do? even value "0" doesn't make sense,
			// this stupid "SetUp" tag is superfluous and confusing.
			// we will set this flag later by our own.
			return false;

		case Fen:
			if (m_modification == Normalize)
			{
				// make corrections in first part of FEN:
				// - replace punctuation with '/'
				// - remove zeroes
				for (mstl::string::iterator i = value.begin(); *i && !::isspace(*i); ++i)
				{
					if (::ispunct(*i))
						*i = '/';
					else if (*i == '0')
						i = value.erase(i, 1);
				}
			}
			if (m_variantValue.empty())
				m_idn = 0;
			m_fenPos = m_prevPos;
			break;

		case tag::Date:
			if (m_modification == Normalize)
			{
				if (value.find_first_not_of("?.") != mstl::string::npos)
				{
					Date date;

					if (!date.parseFromString(value))
						sendWarning(InvalidDateTag, m_prevPos, value);

					if (!date)
						return false;

					value = date.asString();
				}
				else
				{
					value.assign("????.??.??", 10);
				}
			}
			break;

		case EventDate:
			if (m_modification == Normalize)
			{
				if (value.find_first_not_of("?.") != mstl::string::npos)
				{
					Date date;

					if (!date.parseFromString(value))
						sendWarning(InvalidEventDateTag, m_prevPos, value);

					if (!date)
						return false;

					value = date.asString();
				}
				else
				{
					value.assign("????.??.??", 10);
				}
			}
			break;

		case TimeControl:
			m_timeMode = getTimeModeFromTimeControl(value);
			break;

		case TimeMode:
			if (value.size() > 1)
			{
				time::Mode timeMode = time::fromString(value);

				if (timeMode == time::Unknown)
				{
					sendWarning(InvalidTimeModeTag, m_prevPos, value);
					m_tags.setExtra(tag::toName(tag), value);
					return false;
				}
			}
			break;

		case tag::Eco:
			{
				Eco eco(value);

				if (!eco)
				{
					sendWarning(InvalidEcoTag, m_prevPos, value);
					return false;
				}
			}
			break;

		case Result:
			if (m_modification == Normalize)
			{
				result::ID res = result::fromString(value);

				if (res == result::Unknown && (value.size() != 1 || value[0] != '*'))
				{
					m_tags.set(Result, "*");
					if (value != "?")
						sendWarning(InvalidResultTag, m_prevPos, value);
					m_noResult = true;
					return false;
				}

				value = result::toString(res);
			}
			break;

		case Variant:
			m_variant = m_thisVariant = variant::fromString(value);

			if (m_variant == variant::Undetermined)
			{
				m_variantValue = value;

				if (!parseVariant())
					sendError(UnsupportedVariant, m_prevPos, value);
			}

			m_variantPos = m_prevPos;
			return false;	// we will set this tag later by our own

		case tag::Termination:
			if (m_modification == Normalize && !value.empty() && value != "?" && value != "-")
			{
				termination::Reason reason = getTerminationReason(value);

				if (reason == termination::Unknown && ::strcasecmp(value, "unknown") == 0)
				{
					sendWarning(UnknownTermination, m_prevPos, value);
					m_tags.setExtra(tag::toName(tag), value);
					return false;
				}
			}
			break;

		case Mode:
			if (m_modification == Normalize)
			{
				event::Mode mode = event::modeFromString(value);

				if (mode == event::Undetermined && value != "?" && value != "-")
				{
					if (::strcasecmp(value, "unknown") != 0)
					{
						sendWarning(UnknownMode, m_prevPos, value);
						m_tags.setExtra(tag::toName(tag), value);
					}

					return false;
				}
			}
			break;

		case FICSGamesDBGameNo:
			m_ficsGamesDBGameNo = true;
			break;

		case WhiteClock:
		case BlackClock:
			if (m_modification == Normalize)
			{
				mstl::string::size_type n = value.find('.');
				if (n != mstl::string::npos)
					value.erase(n);
			}
			break;

		case WhiteElo:
		case BlackElo:
		case WhiteDWZ:
		case BlackDWZ:
		case WhiteECF:
		case BlackECF:
		case WhiteICCF:
		case BlackICCF:
		case WhiteIPS:
		case BlackIPS:
		case WhiteRapid:
		case BlackRapid:
		case WhiteRating:
		case BlackRating:
		case WhiteUSCF:
		case BlackUSCF:
			if (m_modification == Normalize && !value.empty())
			{
				if (rating::isElo(value.begin(), value.end()))
				{
					if (value[0] == '0')
						value.erase(mstl::string::size_type(0), mstl::string::size_type(1));

					int rat = ::strtoul(value, nullptr, 10);

					if (rat == 0)
						return false;

					if (rat > rating::Max_Value)
					{
						sendWarning(RatingTooHigh, m_prevPos, value);
						return false;
					}
				}
				else if (!::checkScore(value))
				{
					sendWarning(InvalidRating, m_prevPos, value);
					return false;
				}
			}
			break;

//		case Opening:
//		case Variation:
//		case SubVariation:
//		case Annotator:
//		case ExtraTag:
//			convertToUtf(value);
//			break;

#if 0
		case WhiteFideId:
		case BlackFideId:
			// TODO: name correction?!
			break;
#endif

		default:
			if (m_modification == Normalize)
				convertToUtf(value);
			break;
	}

	return true;
}


void
PgnReader::addTag(tag::ID tag, mstl::string const& value)
{
	m_tags.set(tag, value);

	if (tag::isRatingTag(tag))
	{
		color::ID color = tag::isWhiteRatingTag(tag) ? color::White : color::Black;

		m_tags.setSignificance(tag, m_significance[color]);

		if (m_significance[color] > 0 && ++m_significance[color] > 2)
			m_significance[color] = 0;
	}
}


void
PgnReader::readTags()
{
	mstl::string name;
	mstl::string value;

	m_tags.clear();
	m_eventCountry = country::Unknown;

	while (true)
	{
		if (readTagName(name))
		{
			M_ASSERT(!name.empty());

			m_prevPos = m_currPos;
			readTagValue(value);
			value.trim();

			if (value.size() > 255)
			{
				sendWarning(ValueTooLong, m_prevPos, value);
				value.set_size(255);
			}

			int c = get();

			while (::isspace(c))
				c = get();

			if (__builtin_expect(c != ']', 0))
				sendError(UnexpectedSymbol);

			if (!value.empty())
			{
				tag::ID tag = fromName(name);

				if (!tag::isMandatory(tag) && (value == "?" || value == "-"))
				{
					// skip tag
				}
				else if (checkTag(tag, value))
				{
					if (isMandatory(tag))
					{
						if (value.empty())
						{
							switch (tag)
							{
								case tag::Date:	value = "????.??.??"; break;
								case Result:		value = "*"; break;
								default:				value = "?"; break;
							}
						}
						m_tags.set(tag, value);
					}
					else if (value.size() > 1 || (value[0] != '?' && value[0] != '-'))
					{
						switch (tag)
						{
							case ExtraTag:
								// we will silently ignore all tags not starting
								// with an upper case character
								if (m_modification == Raw || ::isupper(name[0]))
								{
									bool ignore = false;

									if (m_modification == Normalize)
									{
										switch (name[0])
										{
											// ignore internal flags and other special tags

											case 'G': ignore = (name == "GameID"); break;
											case 'I': ignore = (name == "Input"); break;
											case 'O': ignore = (name == "Owner"); break;
											case 'U': ignore = (name == "UniqID"); break;

											case 'L':
												if ((ignore = (name == "LastMoves")))
													m_sourceIsChessOK = true;
												break;

											case 'S':
												if (name == "ScidbGameFlags")
												{
													consumer().setGameFlags(GameInfo::stringToFlags(value));
													m_modification = Raw;
													ignore = true;
												}
												else
												{
													ignore = (name == "Stamp");
												}
												break;

											// map White/BlackIsComp to White/BlackType
											case 'B':
												if (name == "BlackIsComp")
												{
													species::ID species =
														::caseEqual(value, "yes", 3) ? species::Program : species::Human;
													m_tags.add(tag::BlackType, species);
													ignore = true;
												}
												break;

											case 'W':
												if (name == "WhiteIsComp")
												{
													species::ID species =
														::caseEqual(value, "yes", 3) ? species::Program : species::Human;
													m_tags.add(tag::WhiteType, species);
													ignore = true;
												}
												break;
										}
									}
									else if (name == "ScidbGameFlags")
									{
										consumer().setGameFlags(GameInfo::stringToFlags(value));
										ignore = true;
									}

									if (!ignore)
										m_tags.setExtra(name, value);
								}
								break;

							case WhiteType:
							case BlackType:
								if (m_modification == Normalize)
								{
									if (species::isHuman(value.begin(), value.end()))
										m_tags.set(tag, species::toString(species::Human));
									else if (species::isProgram(value.begin(), value.end()))
										m_tags.set(tag, species::toString(species::Program));
									else
										sendWarning(UnknownPlayerType, m_prevPos, value);
								}
								break;

							default:
								addTag(tag, value);
								break;
						}
					}
				}
			}
		}
		else
		{
			sendWarning(InvalidTagName, m_prevPos, name);
		}

		skipLine();

		int c;

		do
			c = get();
		while (c == '\n');

		if (c != '[')
		{
			putback(c);
			checkTags();
			return;
		}

		name.clear();
		value.clear();
	}
}


bool
PgnReader::readTagName(mstl::string& s)
{
	m_prevPos = m_currPos;

	int c = get();

	while (c == ' ' || c == '[')
		c = get(true);

	while (!::isspace(c) && c != ']' && c != '"')
	{
		s += char(c);
		c = get(true);
	}

	if (c == ']' || c == '"')
		putback(c);

	if (s.empty())
	{
		do
			skipLine();
		while ((c = get(true)) == '[');

		putback(c);
		sendError(TagNameExpected, m_prevPos);
	}

	return validateTagName(s.data(), s.size());
}


void
PgnReader::readTagValue(mstl::string& s)
{
	int c = get();

	while (::isspace(c))
		c = get();

	m_prevPos = m_currPos;

	if (c != '"')
		sendError(TagValueExpected);

	while (true)
	{
		c = get();

		switch (c)
		{
			case '\n':
				sendError(UnterminatedString, m_prevPos);
				// not reached

			case '"':
				putback(c = get());
				if (c == ']')
					return;
				c = '"';
				break;

			case '\\':
				{
					if ((c = get()) == '\n')
						sendError(UnterminatedString, m_prevPos);

					int c2 = get();
					putback(c2);

					if (c2 == ']')
						return;
				}
				break;
		}

		s += char(c);
	}
}


bool
PgnReader::partOfMove(Token token) const
{
	return bool(token & PartOfMove) && !m_move.isEmpty();
}


void
PgnReader::setNullMove()
{
	putMove();
	m_move = Move::null();
}


void
PgnReader::putNag(nag::ID nag)
{
	M_ASSERT(nag < nag::Scidb_Last);

	if (!m_ignoreNags && !m_annotation.contains(nag) && !m_annotation.add(nag))
	{
		m_ignoreNags = true;
		sendWarning(TooManyNags, m_prevPos);
	}

	m_hasNote = true;
}


void
PgnReader::putNag(nag::ID whiteNag, nag::ID blackNag)
{
	putNag(whiteToMove() ? blackNag : whiteNag);
}


PgnReader::Token
PgnReader::resultToken(result::ID result)
{
	if (m_readMode == Variation)
		sendError(UnexpectedResultToken, m_prevPos);

	m_result = result;
	return kResult;
}


void
PgnReader::stripDiagram(mstl::string& comment)
{
	if (comment.empty())
		return;

	char const* s = comment.c_str();

	if (s[0] == '#' && (comment.size() == 1 || ::isspace(s[1])))
	{
		comment.erase(comment.begin(), ::skipSpaces(s + 1));
		m_annotation.add(nag::Diagram);
		m_hasNote = true;
	}
	else if (m_sourceIsPossiblyChessBase)
	{
		// ChessBase does not have any convention for diagram notation. Therefore we look for
		// any sequence "<word> {#}".
		while (::isalpha(*s))
			++s;
		while (*s == ' ' || *s == '\t')
			++s;

		if (!::equal(s, "{#}", 3))
			return;

		comment.erase(comment.begin(), ::skipSpaces(s + 3));
		m_annotation.add(nag::Diagram);
		m_hasNote = true;
	}
}


PgnReader::Token
PgnReader::endOfInput(Token, int)
{
	return kEoi;
}


bool
PgnReader::doCastling(char const* castle)
{
	if (variant::isAntichessExceptLosers(m_variant))
		sendError(UnexpectedCastling, castle);

	putMove();
	board().parseMove(castle, m_move, m_variant, move::DontAllowIllegalMove);

	if (__builtin_expect(!m_move, 0))
	{
		// The most common type of "illegal" move in standard
		// chess is castling when the king or rook have already
		// moved. So if a castling move failed, turn off
		// strict checking of castling rights and try again,
		// but still print a warning if that succeeded.

		Board			board		= this->board();
		color::ID	side		= board.sideToMove();

		castling::Rights rights;
		rights = ::equal(castle, "O-O-O", 5) ? castling::queenSide(side) : castling::kingSide(side);

		if (rights & (castling::WhiteQueenside | castling::BlackQueenside))
		{
//			if (m_tags.contains(tag::Fen))
//				board.setupLongCastlingRook(side, m_tags.value(tag::Fen));
//			else
				board.tryCastleLong(side);
		}
		else
		{
//			if (m_tags.contains(tag::Fen))
//				board.setupShortCastlingRook(side, m_tags.value(tag::Fen));
//			else
				board.tryCastleShort(side);
		}

		board.parseMove(castle, m_move, m_variant, move::AllowIllegalMove);

		if (!m_move)
		{
			Move castling;
			MoveList moves;

			this->board().generateCastlingMoves(moves);
			this->board().filterLegalMoves(moves, m_variant);

			if (moves.size() != 1)
				return false;

			mstl::string msg;

			msg.format("%u.", board.moveNumber());
			if (board.blackToMove())
				msg.append("..");
			msg.append(castle);
			msg.append(" -> ");
			msg.append(moves[0].asString());

			m_move = moves[0];
			m_move.setColor(side);
			sendWarning(CastlingCorrection, msg);
			m_hasCastled = true;
			return true;
		}
//	This fix comes too late, the sci/si3 decoder has already written the FEN
//		else if (m_tags.contains(tag::Fen))
//		{
//			Board startBoard;
//			startBoard.setup(m_tags.value(tag::Fen), m_variant);
//
//			if (rights & (castling::WhiteQueenside | castling::BlackQueenside))
//				startBoard.setupLongCastlingRook(side, m_tags.value(tag::Fen));
//			else
//				startBoard.setupShortCastlingRook(side, m_tags.value(tag::Fen));
//
//			if (!(startBoard.castlingRights(side) & rights))
//				return false;
//
//			mstl::string fen = startBoard.toFen(m_variant);
//			startBoard.setup(fen, m_variant);
//
//			if (startBoard.validate(m_variant) != Board::Valid)
//				return false;
//
//			// we are silently fixing the FEN
//			m_tags.set(tag::Fen, fen);
//			m_move.setColor(side);
//			return true;
//		}

		m_move.setIllegalMove();
		sendWarning(this->board().isInCheck() ? IllegalMove : IllegalCastling, castle);
	}
	else if (!m_move.isLegal())
	{
		sendWarning(IllegalMove, m_currPos, castle);
	}

	m_hasCastled = true;
	return true;
}


PgnReader::Token
PgnReader::parseComment(Token prevToken, int c)
{
	// Comment: '{' ... '}'

	m_content.clear();
	m_prevPos = m_currPos;

	if (c == '{')
	{
		// parse comment until first '}'
		do
			c = get();
		while (::isspace(c));

		while (c != '}')
		{
			if (c == '\n' || c == '\r')
			{
				::appendSpace(m_content);

				do
					c = get();
				while (::isspace(c));
			}
			else
			{
				m_content += c;
				c = get();
			}
		}
	}
	else
	{
#if 1
		skipLine();
#else
		// parse comment until end of line
		do
			c = get();
		while (::isspace(c) && c != '\n' && c != '\r');

		while (c && c != '\n' && c != '\r')
		{
			m_content += c;
			c = get();
		}

		while (c == '\r')
			c = get();

		if (c != '\n')
			putback(c);
#endif
		return prevToken; // skip comment
	}

	bool isEmpty = m_content.empty();

	if (m_marks.extractFromComment(m_content))
		m_hasNote = true;

	if (m_modification == Normalize)
	{
		m_content.trim();
		stripDiagram(m_content);

		switch (m_content.size())
		{
			case 0:
				if (!isEmpty)
					return kComment;
				break;

			case 1:
				switch (m_content[0])
				{
					case 'N':
						if (partOfMove(prevToken))
						{
							putNag(nag::Novelty);
							return kNag;
						}
						break;

					case 'D':
						if (!m_annotation.contains(nag::Diagram))
						{
							putNag(nag::Diagram);
							return kNag;
						}
						break;
				}
				break;

			case 2:
				switch (m_content[0])
				{
					case 'D':
						if (m_content[1] == '\'')
						{
							putNag(nag::DiagramFromBlack);
							return kNag;
						}
						break;

					case 'R':
						if (m_content[1] == 'R')
						{
							putNag(nag::EditorsRemark);
							return kNag;
						}
						break;
				}
				break;
		}

		if (m_sourceIsChessOK)
		{
			::parseChessOkComment(m_content);

			char const* s = m_content;

			while (::isdigit(*s))
				++s;
			while (*s == '.')
				++s;

			char const* p = s + 1;

			switch (*s)
			{
				case 'K': case 'Q': case 'R': case 'B': case 'N': case 'P':
					if (!('a' <= *p && *p <= 'h'))
						break;
					++p;
					// fallthru

				case 'a' ... 'h':
					if ('1' <= *p && *p <= '8' && p[1] == '\0')
					{
						m_buffer.clear();
						m_buffer.append("<xml><:>", 8);
						m_buffer.append(m_content.begin(), s);
						m_buffer.append("<sym>", 5);
						m_buffer.append(*s);
						m_buffer.append("</sym>", 6);
						m_buffer.append(s + 1, m_content.end());
						m_buffer.append('.');
						m_buffer.append("</:></xml>", 10);

						Comment comment(m_buffer, false, false);

						if (!m_comments.empty() && m_postIndex < m_comments.size())
						{
							m_comments.back().append(comment, ' ');
						}
						else if (!comment.isEmpty())
						{
							m_hasNote = true;
							m_comments.push_back();
							m_comments.back().swap(comment);
						}

						return kComment;
					}
					break;
			}
		}

		// Why the hell does Rybka Aquarium use comments for his annotation?
		// Obviously this company is not interested in the PGN standard.
		if (m_content[0] == '$')
		{
			char const* s = m_content.c_str() + 1;

			while (::isdigit(*s))
				++s;

			if (*s == '\0')
			{
				unsigned nag = ::strtoul(m_content.c_str() + 1, nullptr, 10);

				if (nag < nag::Pgn_Last)
				{
					putNag(nag::ID(nag));
					return kNag;
				}

				char const* phrase = 0;

				// Rybka Aquarium is using enumerated phrases.
				if (500 < nag && nag < 500 + U_NUMBER_OF(::Phrases500))
					phrase = ::Phrases500[nag - 500];
				else if (200 < nag && nag < 200 + U_NUMBER_OF(::Phrases200))
					phrase = ::Phrases200[nag - 200];

				if (phrase)
				{
					Comment comment(phrase, true, true);
					m_comments.push_back();
					m_comments.back().swap(comment);
					m_hasNote = true;
					return kComment;
				}
			}
		}
		else if (!::isalpha(m_content[0]) && m_content.size() <= 5)
		{
			unsigned length = 0;
			nag::ID nag = nag::fromSymbol(m_content, &length);

			if (nag != nag::Null && length == m_content.size())
			{
				putNag(nag::ID(nag));
				return kNag;
			}
		}

		// TODO:
		// "(Rd6) +1.85/17 88s"
		// "(Kc3) Draw accepted +0.00/18 510s"

		consumer().preparseComment(m_content);
	}

	if (m_modification == Raw || !m_content.empty() || isEmpty)
	{
		Comment comment;

		if (m_modification != Raw || !comment.fromHtml(m_content))
		{
			convertToUtf(m_content);
			Comment::convertCommentToXml(m_content, comment, encoding::Utf8);
			comment.normalize();
		}

		if (!comment.isEmpty())
		{
			m_hasNote = true;
			m_comments.push_back();
			m_comments.back().swap(comment);
		}
	}

	return kComment;
}


PgnReader::Token
PgnReader::parseAsterisk(Token prevToken, int)
{
	// Null move: "*"	(after '(')
	// Result: "*"		(otherwise)

	m_prevPos = m_currPos;

	if (prevToken == kStartVariation)
	{
		// '*' is interpreted as null move (used in PalView)
		setNullMove();
		return kSan;
	}

	return resultToken(result::Unknown);
}


PgnReader::Token
PgnReader::parseApostrophe(Token prevToken, int c)
{
	// Move suffix: "'"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "'");

	putNag(nag::Without);
	return kNag;
}


PgnReader::Token
PgnReader::parseAtSign(Token prevToken, int c)
{
	// Move suffix: "@"
	// Null move:   "@@@@"
	// Piece drop:  "@b4"

	if (!partOfMove(prevToken))
	{
		if (::isalpha(m_linePos[0]) && ::isdigit(m_linePos[1]))
		{
			if (!variant::isZhouse(m_variant))
			{
				Move m;

				if (	testVariant(variant::Crazyhouse)
					&& board().parseMove(m_linePos - 1, m, variant::Crazyhouse)
					&& m.isLegal())
				{
					if (testVariant(variant::Crazyhouse))
						setupVariant(variant::Crazyhouse);
				}
			}

			if (variant::isZhouse(m_variant))
				return parseMove(prevToken, c);
		}

		if (!equal(m_linePos, "@@@", 3))
			sendError(UnexpectedSymbol, "@");

		advanceLinePos(3);
		setNullMove();
		return kSan;
	}

	putNag(nag::WhiteHasAModerateTimeAdvantage, nag::BlackHasAModerateTimeAdvantage);
	return kNag;
}


PgnReader::Token
PgnReader::parseBackslash(Token prevToken, int c)
{
	// Move suffix: "\/"

	if (!partOfMove(prevToken) || *m_linePos != '/')
		sendError(UnexpectedSymbol, "\\");

	advanceLinePos(1);
	putNag(nag::AimedAgainst);
	return kNag;
}


PgnReader::Token
PgnReader::parseCaret(Token prevToken, int c)
{
	// Move suffix: "^^", "^_", "^=", "^"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "^");

	switch (*m_linePos)
	{
		case '^':
			advanceLinePos(1);
			putNag(nag::WhiteHasAPairOfBishops, nag::BlackHasAPairOfBishops);
			break;

		case '_':
			advanceLinePos(1);
			putNag(nag::BishopsOfOppositeColor);
			break;

		case '=':
			advanceLinePos(1);
			putNag(nag::BishopsOfSameColor);
			break;

		default:
			putNag(nag::WhiteHasTheInitiative, nag::BlackHasTheInitiative);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseCastling(Token prevToken, int c)
{
	// Castling: [0O][-]?[0O]([-]?[0O])?
	// Move suffix: "O"

	char* e = m_linePos;
	char const* castle = 0;

	if (*e == '-')
		e++;

	if (*e == '0' || *e == 'O')
	{
		e++;

		switch (*e++)
		{
			case '0':
			case 'O':
				castle = "O-O-O";
				break;

			case '-':
				switch (*e++)
				{
					case '0':
					case 'O':
						castle = "O-O-O";
						break;

					default:
						castle = "O-O";
						e -= 2;
						break;
				}
				break;

			default:
				castle = "O-O";
				e--;
				break;
		}
	}

	if (__builtin_expect(castle == 0, 0))
	{
		if (partOfMove(prevToken) && c == 'O')
		{
			putNag(nag::WhiteHasAModerateSpaceAdvantage, nag::BlackHasAModerateSpaceAdvantage);
			return kNag;
		}

		sendError(InvalidToken, mstl::string(m_linePos - 1, e));
	}

	if (!doCastling(castle))
		sendError(InvalidMove, mstl::string(m_linePos - 1, e));

	setLinePos(e);
	return kSan;
}


PgnReader::Token
PgnReader::parseCloseParen(Token, int)
{
	// End of variation; ")"

	m_prevPos = m_currPos;
	return kEndVariation;
}


PgnReader::Token
PgnReader::parseEqualsSign(Token prevToken, int)
{
	// Move prefix: "="
	// Move suffix: "=", "==", "=~", "=&", "=+", "=/+", "=/&", "=/~", ""=>", "=>/<="

	if (!partOfMove(prevToken))
	{
		m_prefixAnnotation = nag::EquivalentMove;
		return kMovePrefix;
	}

	switch (m_linePos[0])
	{
		case '=':
			advanceLinePos(1);
			putNag(nag::EqualChancesQuietPosition);
			break;

		case '~':
		case '&':
			advanceLinePos(1);
			putNag(nag::EqualChancesActivePosition);
			break;

		case '+':
			advanceLinePos(1);
			putNag(nag::BlackHasASlightAdvantage);
			break;

		case '/':
			switch (m_linePos[1])
			{
				case '&':
				case '~':
					advanceLinePos(2);
					putNag(	nag::WhiteHasSufficientCompensationForMaterialDeficit,
								nag::BlackHasSufficientCompensationForMaterialDeficit);
					break;

				case '+':
					advanceLinePos(2);
					putNag(nag::BlackHasASlightAdvantage);
					break;

				default:
					putNag(nag::DrawishPosition);
					break;
			}
			break;

		case '>':
			if (::equal(m_linePos, ">/<=", 4))
			{
				advanceLinePos(4);
				putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
				return kNag;
			}
			advanceLinePos(1);
			putNag(nag::WhiteHasTheAttack, nag::BlackHasTheAttack);
			break;

		default:
			putNag(nag::DrawishPosition);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseExclamationMark(Token prevToken, int)
{
	// Move suffix: "!", "!?", "!!"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "!");

	switch (*m_linePos)
	{
		case '!':
			advanceLinePos(1);
			putNag(nag::VeryGoodMove);
			break;

		case '?':
			advanceLinePos(1);
			putNag(nag::SpeculativeMove);
			break;

		default:
			putNag(nag::GoodMove);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseGraveAccent(Token prevToken, int c)
{
	// Move suffix: "`"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "`");

	putNag(nag::Without);
	return kNag;
}


PgnReader::Token
PgnReader::parseGreaterThanSign(Token prevToken, int)
{
	// Move prefix: ">"
	// Move suffix: ">=", ">>", "><"

	if (partOfMove(prevToken))
	{
		switch (*m_linePos)
		{
			case '=':
				advanceLinePos(1);
				m_prefixAnnotation = nag::BetterMove;
				return kNag;

			case '>':
				advanceLinePos(1);
				putNag(	nag::WhiteHasAModerateKingsideControlAdvantage,
							nag::BlackHasAModerateKingsideControlAdvantage);
				return kNag;

			case '<':
				advanceLinePos(1);
				putNag(nag::WeakPoint);
				return kNag;
		}
	}

	m_prefixAnnotation = nag::BetterMove;
	return kMovePrefix;
}


PgnReader::Token
PgnReader::parseLessThanSign(Token prevToken, int)
{
	// Null move: "<>"
	// Move prefix: "<=", "<<"
	// Move suffix: "<=>", "<->", "<=/=>"
	// Skip: '<' ... '>' (but do not skip newlines)

	switch (m_linePos[0])
	{
		case '>':
			// "<>" is interpreted as null move (used in PalView)
			advanceLinePos(1);
			setNullMove();
			return kSan;

		case '=':
			switch (m_linePos[1])
			{
				case '>':
					advanceLinePos(2);
					putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
					return kNag;

				case '/':
					if (::equal(m_linePos, "=>", 2))
					{
						advanceLinePos(2);
						putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
						return kNag;
					}
					break;
			}
			advanceLinePos(1);
			m_prefixAnnotation = nag::WorseMove;
			return kMovePrefix;

		case '<':
			// NOTE: possibly we should use nag::Queenside
			advanceLinePos(1);
			putNag(	nag::WhiteHasAModerateQueensideControlAdvantage,
						nag::BlackHasAModerateQueensideControlAdvantage);
			return kNag;

		case '-':
			if (m_linePos[1] == '>')
			{
				advanceLinePos(2);
				putNag(nag::Line);
				return kNag;
			}
			break;
	}

	if (m_modification == Raw)
	{
		mstl::string str;
		char c;

		while ((c = get()) != '>')
			str += c;

		consumer().preparseComment(str);
		return kComment;
	}

	// The PGN standard says that '<' is a token, although
	// it's reserved for future use.
	// We will skip until first '>', but only in current line.
	while (m_linePos < m_lineEnd && *m_linePos != '>')
		++m_linePos;

	if (*m_linePos == '>')
		setLinePos(m_linePos + 1);
	else
		sendError(UnexpectedSymbol, "<");

	return prevToken;
}


PgnReader::Token
PgnReader::parseLowercaseE(Token prevToken, int c)
{
	// Skip en passant: "ep", "e.p."

	if (partOfMove(prevToken))
	{
		switch (m_linePos[0])
		{
			case 'p':
				if (!::isalnum(m_linePos[1]))
				{
					advanceLinePos(1);
					return prevToken;
				}
				break;

			case '.':
				if (m_linePos[1] == 'p' && m_linePos[2] == '.')
				{
					advanceLinePos(3);
					return prevToken;
				}
				break;
		}
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseLowercaseN(Token, int)
{
	// Null move: "null"

	if (!equal(m_linePos, "ull", 3) || ::isalpha(m_linePos[3]))
		sendError(UnexpectedSymbol, "n");

	advanceLinePos(3);
	setNullMove();
	return kSan;
}


PgnReader::Token
PgnReader::parseLowercaseP(Token, int)
{
	// Null move: "pass"

	if (!equal(m_linePos, "ass", 3) || ::isalpha(m_linePos[3]))
		sendError(UnexpectedSymbol, "p");

	advanceLinePos(3);
	setNullMove();
	return kSan;
}


PgnReader::Token
PgnReader::parseLowercaseO(Token prevToken, int)
{
	// Move suffix: "o^", "oo", "o/o", "o.o", "o..o", "or"
	// Move: "o-o", "o-o-o"

	switch (m_linePos[0])
	{
		case '^':
			advanceLinePos(1);
			putNag(nag::PassedPawn);
			break;

		case 'o':
			advanceLinePos(1);
			putNag(nag::DoublePawns);
			break;

		case 'r':
			advanceLinePos(1);
			putNag(nag::BetterMove);
			break;

		case '/':
			if (m_linePos[1] != 'o')
				sendError(UnexpectedSymbol, "o/");
			advanceLinePos(2);
			putNag(nag::SeparatedPawns);
			break;

		case '.':
			switch (m_linePos[1])
			{
				case 'o':
					advanceLinePos(2);
					putNag(nag::UnitedPawns);
					break;

				case '.':
					if (m_linePos[1] != 'o')
						sendError(UnexpectedSymbol, "o..");
					advanceLinePos(3);
					putNag(nag::UnitedPawns);
					break;

				default:
					sendError(UnexpectedSymbol, "o.");
			}
			break;

		case '-':
			if (::equal(m_linePos, "-o-o", 4))
			{
				if (doCastling("O-O-O"))
				{
					advanceLinePos(4);
					return kSan;
				}
			}
			else if (::equal(m_linePos, "-o", 2))
			{
				if (doCastling("O-O"))
				{
					advanceLinePos(2);
					return kSan;
				}
			}
			// fallthru

		default:
			sendError(UnexpectedSymbol, "o");
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseLowercaseZ(Token prevToken, int)
{
	// kNag: "zz"

	if (*m_linePos != 'z')
		sendError(UnexpectedSymbol, "z");

	advanceLinePos(1);
	putNag(nag::WhiteIsInZugzwang, nag::BlackIsInZugzwang);
	return kNag;
}


PgnReader::Token
PgnReader::parseMate(Token prevToken, int c)
{
	// skip "mate"

	if (!::equal(m_linePos, "ate", 3) || ::isalpha(m_linePos[3]))
		return unexpectedSymbol(prevToken, c);

	advanceLinePos(3);
	return prevToken;
}


PgnReader::Token
PgnReader::parseMinusSign(Token prevToken, int)
{
	// Move suffix: "-+", "--+", "--++" "-/+", "->", "->/<-"
	// Null move: "--" (used in ChessBase)

	switch (m_linePos[0])
	{
		case '-':
			if (partOfMove(prevToken))
			{
				if (::equal(m_linePos, "-++", 3))
				{
					advanceLinePos(3);
					putNag(nag::BlackHasACrushingAdvantage);
					return kNag;
				}
				else if (::equal(m_linePos, "-+", 2))
				{
					advanceLinePos(2);
					putNag(nag::BlackHasADecisiveAdvantage);
					return kNag;
				}
			}
			advanceLinePos(1);
			setNullMove();
			return kSan;

		case '+':
			if (!partOfMove(prevToken))
				sendError(UnexpectedSymbol, "-");
			advanceLinePos(1);
			putNag(nag::BlackHasADecisiveAdvantage);
			return kNag;

		case '/':
			if (!partOfMove(prevToken))
				sendError(UnexpectedSymbol, "/");
			if (m_linePos[1] != '+')
				sendError(InvalidToken, ::trim(mstl::string(m_linePos - 1, 3)));
			advanceLinePos(2);
			putNag(nag::BlackHasAModerateAdvantage);
			return kNag;

		case '>':
			if (!partOfMove(prevToken))
				sendError(UnexpectedSymbol, ">");
			if (::equal(m_linePos, "-/<-", 4))
			{
				advanceLinePos(4);
				putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
				return kNag;
			}
			advanceLinePos(1);
			putNag(nag::WhiteHasTheAttack, nag::BlackHasTheAttack);
			return kNag;
	}

	sendError(UnexpectedSymbol, "-");
	return prevToken;	// satisfies the compiler
}


PgnReader::Token
PgnReader::parseMove(Token prevToken, int c)
{
	m_prevPos = m_currPos;
	putMove();

	char const* e = board().parseMove(m_linePos - 1, m_move, m_variant, move::AllowIllegalMove);

	if (__builtin_expect(e == 0, 0))
	{
		if (	m_linePos[0] == '@'
			&& testVariant(variant::Crazyhouse)
			&& (e = board().parseMove(m_linePos - 1, m_move, variant::Crazyhouse, move::AllowIllegalMove)))
		{
			setupVariant(variant::Crazyhouse);
		}
		else
		{
			// skip "ch", "dbl ch", "check", and "double check"
			switch (c)
			{
				case 'c':
					if (::equal(m_linePos, "heck", 4) && !::isalpha(m_linePos[4]))
					{
						setLinePos(m_linePos + 4);
						return prevToken;
					}
					if (m_linePos[0] == 'h' && !::isalpha(m_linePos[2]))
					{
						setLinePos(m_linePos + 2);
						return prevToken;
					}
					break;

				case 'd':
					if (::equal(m_linePos, "bl ch", 5) && !::isalpha(m_linePos[5]))
					{
						setLinePos(m_linePos + 5);
						return prevToken;
					}
					if (::equal(m_linePos, "ouble check", 11) && !::isalpha(m_linePos[11]))
					{
						setLinePos(m_linePos + 11);
						return prevToken;
					}
					break;
			}

			sendError(	::isMoveToken(m_linePos - 1) ? InvalidMove : InvalidToken,
							m_prevPos,
							inverseFigurineMapping(mstl::string(m_linePos - 1, ::skipMoveToken(m_linePos))));
		}
	}

	if (__builtin_expect(!m_move, 0))
	{
		if (	(	(m_variant == variant::Losers && m_givenVariant == variant::Undetermined)
				/*|| testVariant(variant::Suicide)*/)
			&& (e = board().parseMove(m_linePos - 1, m_move, variant::Suicide)))
		{
			setupVariant(variant::Suicide);
		}

		if (!m_move)
		{
			sendError(	InvalidMove,
							m_prevPos,
							inverseFigurineMapping(mstl::string(m_linePos - 1, e)));
		}
	}

	if (__builtin_expect(!m_move.isLegal(), 0))
	{
		if (!board().isValidMove(m_move, m_variant, move::AllowIllegalMove))
		{
#if 0
			if (	!isAntichessExceptLosers(m_variant)
				&& board().isValidMove(m_move, variant::Suicide, move::DontAllowIllegalMove))
			{
				// TODO: we have to check the move history!
				setupVariant(variant::Suicide);
			}
			else
#endif
			{
				sendError(	InvalidMove,
								m_prevPos,
								inverseFigurineMapping(mstl::string(m_linePos - 1, e)));
			}
		}

		if (!m_move.isLegal())
			sendWarning(IllegalMove, m_prevPos, mstl::string(m_linePos - 1, e));
	}

	setLinePos(const_cast<char*>(e));
	return kSan;
}


PgnReader::Token
PgnReader::parseMoveNumber(Token prevToken, int)
{
	// Move number: [0-9]+[.]*

	if (m_linePos[0] != '0' || m_linePos[1] != '-')
	{
		while (::isdigit(*m_linePos))
			advanceLinePos();

		if (*m_linePos == '.')
			advanceLinePos();
	}

	return kMoveNumber;
}


PgnReader::Token
PgnReader::parseNag(Token prevToken, int)
{
	// Nag value: [$][0-9]+

	if (__builtin_expect(!::isdigit(*m_linePos), 0))
		sendError(InvalidToken, ::trim(mstl::string("$") + *m_linePos));

	unsigned nag = 0;

	do
		nag = nag*10 + get() - '0';
	while (::isdigit(*m_linePos));

	nag::ID myNag = nag::map((prevToken & (kSan | kNag))
										? nag::ID(nag)
										: nag::prefix::map(nag::ID(nag::ID(nag))));

	if (myNag == nag::Null || myNag >= nag::Scidb_Last)
		sendWarning(InvalidNag, mstl::string("$") + ::itos(nag));
	else
		putNag(myNag);

	return kNag;
}


PgnReader::Token
PgnReader::parseNumberZero(Token prevToken, int c)
{
	// Castling: [0O][-]?[0O]([-]?[0O])?
	//	Result: "0-1", "0:1", "0-0", "0:0"

	switch (m_linePos[0])
	{
		case '-':
			switch (m_linePos[1])
			{
				case '1':
					advanceLinePos(1);
					return resultToken(result::Black);

				case '0':
					if (m_linePos[2] == '-')
						return parseCastling(prevToken, '0');

					if (m_tags.value(Result) != "0-0" && doCastling("O-O"))
					{
						advanceLinePos(2);
						return kSan;
					}
					else
					{
						advanceLinePos(2);
						return resultToken(result::Lost);
					}

					sendError(InvalidMove, "O-O");
					break;

				case 'O':
					return parseCastling(prevToken, '0');
			}

			sendError(InvalidToken, mstl::string(m_linePos - 1, m_linePos + 1));
			// not reached

		case ':':
			switch (m_linePos[1])
			{
				case '0':
					advanceLinePos(2);
					return resultToken(result::Lost);

				case '1':
					advanceLinePos(2);
					return resultToken(result::Black);
			}
			sendError(InvalidToken, ::trim(mstl::string(m_linePos - 1, m_linePos + 2)));
			// not reached

		case 'O':
		case '0':
			return parseCastling(prevToken, '0');
	}

	return parseMoveNumber(prevToken, '0');
}


PgnReader::Token
PgnReader::parseNumberOne(Token prevToken, int c)
{
	// Result: "1-0", "1:0", "1/2-1/2", "1/2:1/2", "1/2"
	// Move number: [1][0-9]*[.]*

	switch (m_linePos[0])
	{
		case '-':
		case ':':
			if (m_linePos[1] != '0')
				sendError(InvalidToken, ::trim(mstl::string(m_linePos - 1, 3)));

			advanceLinePos(2);
			return resultToken(result::White);

		case '/':
			if (m_linePos[1] != '2')
				sendError(InvalidToken, ::trim(mstl::string(m_linePos - 1, 3)));

			if (::equal(m_linePos, "/2-1/2", 6) || ::equal(m_linePos, "/2:1/2", 6))
			{
				advanceLinePos(6);
				return resultToken(result::Draw);
			}
			else if (::equal(m_linePos, "/2", 2))
			{
				advanceLinePos(2);
				return resultToken(result::Draw);
			}
			sendError(InvalidToken, ::trim(mstl::string(m_linePos - 1, 3)));
			// not reached
	}

	return parseMoveNumber(prevToken, '1');
}


PgnReader::Token
PgnReader::parsePlusSign(Token prevToken, int c)
{
	// (Double) check sign: "+", "++" (double check will be ignored)
	// Move suffix: "+-", "+--", "++--", "+/-", "+=", "+/="

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "+");

	switch (m_linePos[0])
	{
		case '-':
			advanceLinePos(m_linePos[1] == '-' ? 2 : 1);
			putNag(nag::WhiteHasADecisiveAdvantage);
			prevToken = kNag;
			break;

		case '=':
			advanceLinePos(1);
			putNag(nag::WhiteHasASlightAdvantage);
			prevToken = kNag;
			break;

		case '/':
			switch (m_linePos[1])
			{
				case '-':
					advanceLinePos(2);
					putNag(nag::WhiteHasAModerateAdvantage);
					break;

				case '=':
					advanceLinePos(2);
					putNag(nag::WhiteHasASlightAdvantage);
					break;

				default:
					sendError(InvalidToken, ::trim(mstl::string(m_linePos - 1, 3)));
			}

			prevToken = kNag;
			break;

		case '+':
			if (m_linePos[1] == '-')
			{
				if (m_linePos[2] != '-')
					sendError(InvalidToken, "++-");

				advanceLinePos(3);
				putNag(nag::WhiteHasACrushingAdvantage);
				prevToken = kNag;
			}
			else
			{
				advanceLinePos(1);
				// skip double check
			}
			break;
	}

	// skip check sign
	return prevToken;
}


PgnReader::Token
PgnReader::parseQuestionMark(Token prevToken, int c)
{
	// Move suffix: "?", "??", "?!"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "?");

	switch (*m_linePos)
	{
		case '!':
			advanceLinePos(1);
			putNag(nag::QuestionableMove);
			break;

		case '?':
			advanceLinePos(1);
			putNag(nag::VeryPoorMove);
			break;

		default:
			putNag(nag::PoorMove);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseOpenParen(Token prevToken, int)
{
	// Move suffix: "(ep)", "(e.p.)"
	// Move suffix: "()", "(+)", "(.)", "(?)"
	// Parenthesized symbols: "(<any NAG>)"
	// Start of variation

	if (partOfMove(prevToken))
	{
		if (m_currPos.column > 0)
		{
			unsigned length = 0;
			nag::ID nag = nag::fromSymbol(m_linePos - 1, &length);

			if (nag != nag::Null)
			{
				M_ASSERT(length > 0);
				advanceLinePos(length - 2);
				putNag(nag);
				return kNag;
			}
		}

		char const* e = m_linePos;
		while (e < m_lineEnd && *e != ')')
			++e;

		if (*e == ')' && e - m_linePos <= 5)
		{
			mstl::string str;
			str.hook(m_linePos, e - m_linePos);

			nag::ID nag = nag::fromSymbol(str);

			if (nag != nag::Null)
			{
				advanceLinePos(str.size() + 1);
				putNag(nag);
				return kNag;
			}
		}

		if (::equal(m_linePos, "ep)", 3))
		{
			advanceLinePos(3);
			return prevToken;
		}

		if (::equal(m_linePos, "e.p.)", 5))
		{
			advanceLinePos(5);
			return prevToken;
		}
	}

	if (m_linePos[0] == '*')
	{
		sendError(ContinuationsNotSupported, "/");
		return skipToEndOfVariation(prevToken);
	}

	return kStartVariation;
}


PgnReader::Token
PgnReader::parseSlash(Token prevToken, int)
{
	// Move suffix: "/\", "/^", "//"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "/");

	switch (*m_linePos)
	{
		case '\\':
			advanceLinePos(1);
			putNag(nag::WithTheIdea);
			break;

		case '^': // fallthru
		case '/':
			advanceLinePos(1);
			putNag(nag::Diagonal);
			break;

		default:
			sendError(UnexpectedSymbol, "/");
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseTag(Token prevToken, int)
{
	// Move suffix: "[]", "[+]"
	// Start of Tag

	if (partOfMove(prevToken))
	{
		switch (m_linePos[0])
		{
			case ']':
				advanceLinePos(1);
				putNag(nag::SingularMove);
				return kNag;

			case '+':
				if (m_linePos[1] == ']')
				{
					// NOTE: possibly we should use nag::Center
					advanceLinePos(2);
					putNag(	nag::WhiteHasAModerateCenterControlAdvantage,
								nag::BlackHasAModerateCenterControlAdvantage);
					return kNag;
				}
		}
	}

	m_currentOffset = m_lineOffset + m_currPos.column - 1;
	return kTag;
}


PgnReader::Token
PgnReader::parseTilde(Token prevToken, int c)
{
	// Move suffix: "~", "~~", "~&", "~/=" "&", "&&", "&~", "&/="

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, mstl::string(1, c));

	switch (m_linePos[0])
	{
		case '/':
			if (m_linePos[1] == '=')
			{
				advanceLinePos(2);
				putNag(	nag::WhiteHasSufficientCompensationForMaterialDeficit,
							nag::BlackHasSufficientCompensationForMaterialDeficit);
			}
			break;

		case '~':
			advanceLinePos(1);
			putNag(c == '~' ? nag::UnclearPosition : nag::EqualChancesActivePosition);
			break;

		case '&':
			advanceLinePos(1);
			putNag(c == '&' ? nag::UnclearPosition : nag::EqualChancesActivePosition);
			break;

		default:
			putNag(nag::UnclearPosition);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseUnderscore(Token prevToken, int c)
{
	// Move suffix: "_|_", "_|"

	if (!partOfMove(prevToken) || m_linePos[0] != '|')
		sendError(UnexpectedSymbol, "_");

	if (m_linePos[1] == '_')
	{
		advanceLinePos(2);
		putNag(nag::Endgame);
	}
	else
	{
		advanceLinePos(1);
		putNag(nag::Without);
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseUppercaseB(Token prevToken, int c)
{
	// Move prefix: "BB", "Bb"

	if (partOfMove(prevToken))
	{
		switch (m_linePos[0])
		{
			case 'B':
				if (!::isalnum(m_linePos[1]))
				{
					advanceLinePos(1);
					putNag(nag::BishopsOfSameColor);
					return kNag;
				}
				break;

			case 'b':
				if (!::isalnum(m_linePos[1]))
				{
					advanceLinePos(1);
					putNag(nag::BishopsOfOppositeColor);
					return kNag;
				}
				break;
		}
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseUppercaseD(Token prevToken, int c)
{
	// Diagram symbol "D", "D'"

	if (::isalnum(*m_linePos))
		return parseMove(prevToken, c);

	if (*m_linePos == '\'')
	{
		advanceLinePos(1);
		putNag(nag::DiagramFromBlack);
	}
	else
	{
		putNag(nag::Diagram);
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseUppercaseN(Token prevToken, int c)
{
	// Move prefix: "N"

	if (partOfMove(prevToken) && !::isalnum(m_linePos[0]) && m_linePos[0] != '@')
	{
		putNag(nag::Novelty);
		return kNag;
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseUppercaseR(Token prevToken, int c)
{
	// Move prefix: "RR"

	if (partOfMove(prevToken) && m_linePos[0] == 'R')
	{
		advanceLinePos(1);
		m_prefixAnnotation = nag::EditorsRemark;
		return kMovePrefix;
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseUppercaseZ(Token prevToken, int c)
{
	// Null move: "Z0" (used in Chess Assistant)

	if (m_linePos[0] != '0')
		return unexpectedSymbol(prevToken, c);

	advanceLinePos(1);
	setNullMove();
	return kSan;
}


PgnReader::Token
PgnReader::parseVerticalBar(Token prevToken, int)
{
	// Move suffix: "|^", "||", "|_"

	if (!partOfMove(prevToken))
		sendError(UnexpectedSymbol, "|");

	switch (*m_linePos)
	{
		case '^':
			advanceLinePos(1);
			putNag(nag::WhiteHasTheInitiative, nag::BlackHasTheInitiative);
			break;

		case '/':
			advanceLinePos(1);
			putNag(nag::File);
			break;

		case '_':
			advanceLinePos(1);
			putNag(nag::With);
			break;

		default:
			sendError(UnexpectedSymbol, "|");
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseWeakPoint(Token, int)
{
	putNag(nag::WeakPoint);
	return kNag;
}


PgnReader::Token
PgnReader::skipDot(Token prevToken, int)
{
	// ignore '.'
	return prevToken;
}


PgnReader::Token
PgnReader::skipComment(Token prevToken, int c)
{
	// ignore comment until end of line

	skipLine();
	return prevToken;
}


PgnReader::Token
PgnReader::skipMateSymbol(Token prevToken, int)
{
	if (!(prevToken & kSan))
		sendError(UnexpectedSymbol, "#");

	return prevToken;
}


PgnReader::Token
PgnReader::skipWhiteSpace(Token prevToken, int)
{
	return prevToken;
}


PgnReader::Token
PgnReader::unexpectedSymbol(Token prevToken, int c)
{
	if (c == '}')
	{
		// We will not throw an error because Scid is writing invalid PGN files.
		sendWarning(BraceSeenOutsideComment, m_currPos);
		return prevToken;
	}

	sendError(UnexpectedSymbol, m_currPos, mstl::string(::isprint(c) ? 1 : 0, c));
	putback(c);

	return kError;
}


PgnReader::Token
PgnReader::nextToken(Token prevToken)
{
	typedef Token (PgnReader::*Meth)(Token, int);

	static Meth const Trampolin[128] =
	{
		/*   0    */ &PgnReader::endOfInput,
		/*   1    */ &PgnReader::unexpectedSymbol,
		/*   2    */ &PgnReader::unexpectedSymbol,
		/*   3    */ &PgnReader::unexpectedSymbol,
		/*   4    */ &PgnReader::unexpectedSymbol,
		/*   5    */ &PgnReader::unexpectedSymbol,
		/*   6    */ &PgnReader::unexpectedSymbol,
		/*   7 \a */ &PgnReader::unexpectedSymbol,
		/*   8 \b */ &PgnReader::unexpectedSymbol,
		/*   9 \t */ &PgnReader::skipWhiteSpace,
		/*  10 \n */ &PgnReader::skipWhiteSpace,
		/*  11 \v */ &PgnReader::skipWhiteSpace,
		/*  12 \f */ &PgnReader::skipWhiteSpace,
		/*  13 \r */ &PgnReader::skipWhiteSpace,
		/*  14    */ &PgnReader::unexpectedSymbol,
		/*  15    */ &PgnReader::unexpectedSymbol,
		/*  16    */ &PgnReader::unexpectedSymbol,
		/*  17    */ &PgnReader::unexpectedSymbol,
		/*  18    */ &PgnReader::unexpectedSymbol,
		/*  19    */ &PgnReader::unexpectedSymbol,
		/*  20    */ &PgnReader::unexpectedSymbol,
		/*  21    */ &PgnReader::unexpectedSymbol,
		/*  22    */ &PgnReader::unexpectedSymbol,
		/*  23    */ &PgnReader::unexpectedSymbol,
		/*  24    */ &PgnReader::unexpectedSymbol,
		/*  25    */ &PgnReader::unexpectedSymbol,
		/*  26    */ &PgnReader::unexpectedSymbol,
		/*  27    */ &PgnReader::unexpectedSymbol,
		/*  28    */ &PgnReader::unexpectedSymbol,
		/*  29    */ &PgnReader::unexpectedSymbol,
		/*  30    */ &PgnReader::unexpectedSymbol,
		/*  31    */ &PgnReader::unexpectedSymbol,
		/*  32 SP */ &PgnReader::skipWhiteSpace,
		/*  33 !  */ &PgnReader::parseExclamationMark,
		/*  34 "  */ &PgnReader::unexpectedSymbol,
		/*  35 #  */ &PgnReader::skipMateSymbol,
		/*  36 $  */ &PgnReader::parseNag,
		/*  37 %  */ &PgnReader::skipComment,
		/*  38 &  */ &PgnReader::parseTilde,
		/*  39 '  */ &PgnReader::parseApostrophe,
		/*  40 (  */ &PgnReader::parseOpenParen,
		/*  41 )  */ &PgnReader::parseCloseParen,
		/*  42 *  */ &PgnReader::parseAsterisk,
		/*  43 +  */ &PgnReader::parsePlusSign,
		/*  44 ,  */ &PgnReader::unexpectedSymbol,
		/*  45 -  */ &PgnReader::parseMinusSign,
		/*  46 .  */ &PgnReader::skipDot,
		/*  47 /  */ &PgnReader::parseSlash,
		/*  48 0  */ &PgnReader::parseNumberZero,
		/*  49 1  */ &PgnReader::parseNumberOne,
		/*  50 2  */ &PgnReader::parseMoveNumber,
		/*  51 3  */ &PgnReader::parseMoveNumber,
		/*  52 4  */ &PgnReader::parseMoveNumber,
		/*  53 5  */ &PgnReader::parseMoveNumber,
		/*  54 6  */ &PgnReader::parseMoveNumber,
		/*  55 7  */ &PgnReader::parseMoveNumber,
		/*  56 8  */ &PgnReader::parseMoveNumber,
		/*  57 9  */ &PgnReader::parseMoveNumber,
		/*  58 :  */ &PgnReader::unexpectedSymbol,
		/*  59 ;  */ &PgnReader::parseComment,
		/*  60 <  */ &PgnReader::parseLessThanSign,
		/*  61 =  */ &PgnReader::parseEqualsSign,
		/*  62 >  */ &PgnReader::parseGreaterThanSign,
		/*  63 ?  */ &PgnReader::parseQuestionMark,
		/*  64 @  */ &PgnReader::parseAtSign,
		/*  65 A  */ &PgnReader::unexpectedSymbol,
		/*  66 B  */ &PgnReader::parseUppercaseB,
		/*  67 C  */ &PgnReader::unexpectedSymbol,
		/*  68 D  */ &PgnReader::parseUppercaseD,
		/*  69 E  */ &PgnReader::unexpectedSymbol,
		/*  70 F  */ &PgnReader::unexpectedSymbol,
		/*  71 G  */ &PgnReader::unexpectedSymbol,
		/*  72 H  */ &PgnReader::unexpectedSymbol,
		/*  73 I  */ &PgnReader::unexpectedSymbol,
		/*  74 J  */ &PgnReader::unexpectedSymbol,
		/*  75 K  */ &PgnReader::parseMove,
		/*  76 L  */ &PgnReader::unexpectedSymbol,
		/*  77 M  */ &PgnReader::unexpectedSymbol,
		/*  78 N  */ &PgnReader::parseUppercaseN,
		/*  79 O  */ &PgnReader::parseCastling,
		/*  80 P  */ &PgnReader::parseMove,
		/*  81 Q  */ &PgnReader::parseMove,
		/*  82 R  */ &PgnReader::parseUppercaseR,
		/*  83 S  */ &PgnReader::unexpectedSymbol,
		/*  84 T  */ &PgnReader::unexpectedSymbol,
		/*  85 U  */ &PgnReader::unexpectedSymbol,
		/*  86 V  */ &PgnReader::unexpectedSymbol,
		/*  87 W  */ &PgnReader::unexpectedSymbol,
		/*  88 X  */ &PgnReader::parseWeakPoint,
		/*  89 Y  */ &PgnReader::unexpectedSymbol,
		/*  90 Z  */ &PgnReader::parseUppercaseZ,
		/*  91 [  */ &PgnReader::parseTag,
		/*  92 \  */ &PgnReader::parseBackslash,
		/*  93 ]  */ &PgnReader::unexpectedSymbol,
		/*  94 ^  */ &PgnReader::parseCaret,
		/*  95 _  */ &PgnReader::parseUnderscore,
		/*  96 `  */ &PgnReader::parseGraveAccent,
		/*  97 a  */ &PgnReader::parseMove,
		/*  98 b  */ &PgnReader::parseMove,
		/*  99 c  */ &PgnReader::parseMove,
		/* 100 d  */ &PgnReader::parseMove,
		/* 101 e  */ &PgnReader::parseLowercaseE,
		/* 102 f  */ &PgnReader::parseMove,
		/* 103 g  */ &PgnReader::parseMove,
		/* 104 h  */ &PgnReader::parseMove,
		/* 105 i  */ &PgnReader::unexpectedSymbol,
		/* 106 j  */ &PgnReader::unexpectedSymbol,
		/* 107 k  */ &PgnReader::unexpectedSymbol,
		/* 108 l  */ &PgnReader::unexpectedSymbol,
		/* 109 m  */ &PgnReader::parseMate,
		/* 110 n  */ &PgnReader::parseLowercaseN,
		/* 111 o  */ &PgnReader::parseLowercaseO,
		/* 112 p  */ &PgnReader::parseLowercaseP,
		/* 113 q  */ &PgnReader::unexpectedSymbol,
		/* 114 r  */ &PgnReader::unexpectedSymbol,
		/* 115 s  */ &PgnReader::unexpectedSymbol,
		/* 116 t  */ &PgnReader::unexpectedSymbol,
		/* 117 u  */ &PgnReader::unexpectedSymbol,
		/* 118 v  */ &PgnReader::unexpectedSymbol,
		/* 119 w  */ &PgnReader::unexpectedSymbol,
		/* 120 x  */ &PgnReader::parseWeakPoint,
		/* 121 y  */ &PgnReader::unexpectedSymbol,
		/* 122 z  */ &PgnReader::parseLowercaseZ,
		/* 123 {  */ &PgnReader::parseComment,
		/* 124 |  */ &PgnReader::parseVerticalBar,
		/* 125 }  */ &PgnReader::unexpectedSymbol,
		/* 126 ~  */ &PgnReader::parseTilde,
		/* 127    */ &PgnReader::unexpectedSymbol,
	};

	prevToken |= kOutDated;

	while (true)
	{
		unsigned char c = get(true);

		if (__builtin_expect(c & 0x80, 0))
		{
			if (	c == 194
				&& static_cast<unsigned char>(m_linePos[0]) == 189
				&& m_linePos[1] == '-'
				&& static_cast<unsigned char>(m_linePos[2]) == 194
				&& static_cast<unsigned char>(m_linePos[3]) == 189)
			{
				// catch "½-½"
				advanceLinePos(4);
				return resultToken(result::Draw);
			}

			if ((prevToken = unexpectedSymbol(prevToken, c)) <= kError)
				return prevToken;

			continue;
		}

		m_prevPos = m_currPos;

		if ((prevToken = (this->*Trampolin[c])(prevToken, c)) <= kError)
			return prevToken;
	}

	return kEoi;	// satisfies the compiler
}


void
PgnReader::replaceFigurineSet(char const* fromSet, char const* toSet, mstl::string& str)
{
	char* s = str.begin();
	char* e = str.end();

	while (true)
	{
		if (s == e)
			return;

		switch (*s)
		{
			case '\0':
			case ';':
				return;

			case '{':
				do
					++s;
				while (s < e && *s != '}');
				// fallthru

			default:
				while (!::isalpha(*s) || !::isupper(*s))
				{
					if (++s == e)
						return;
				}
				break;
		}

		char* p = const_cast<char*>(::strchr(toSet, *s));

		if (p && p - toSet < 5)
		{
			// parse: [KQRBN]([a-h][1-8])?[x:-]?[a-h][1-8]
			// parse: [QRBNP][@][a-h][1-8]

			char*	t			= s + 1;
			bool	needFyle	= true;

			if (*t == '@')
			{
				if (::CharToType[Byte(*(t + 1))] == ::Fyle && ::CharToType[Byte(*(t + 2))] == ::Rank)
				{
					*(t - 1) = fromSet[p - toSet];
					s = t + 3;
				}
				else
				{
					++s;
				}
			}
			else
			{
				switch (::CharToType[Byte(*t)])
				{
					case ::Fyle:
						needFyle = false;
						++t;
						break;

					case ::Rank:
						++t;
						break;
				}

				if (::CharToType[Byte(*t)] == ::Capture)
				{
					++t;
					needFyle = true;
				}

				if (::CharToType[Byte(*t)] == ::Fyle)
				{
					++t;
					needFyle = false;
				}

				if (!needFyle && ::CharToType[Byte(*t)] == ::Rank)
				{
					*s = fromSet[p - toSet];
					s = t + 1;
				}
				else
				{
					++s;
				}
			}
		}
		else
		{
			++s;
		}
	}
}


PgnReader::GameCount const&
PgnReader::accepted() const
{
	return m_accepted;
}


PgnReader::GameCount const&
PgnReader::rejected() const
{
	return m_rejected;
}


unsigned
PgnReader::accepted(unsigned variant) const
{
	M_REQUIRE(variant < variant::NumberOfVariants);
	return m_accepted[variant];
}


unsigned
PgnReader::rejected(unsigned variant) const
{
	M_REQUIRE(variant < variant::NumberOfVariants);
	return m_rejected[variant];
}


PgnReader::Variants const&
PgnReader::unsupportedVariants() const
{
	return m_variants;
}

// vi:set ts=3 sw=3:
