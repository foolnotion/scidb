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

#ifndef _db_pgn_reader_included
#define _db_pgn_reader_included

#include "db_reader.h"
#include "db_annotation.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_move.h"
#include "db_move_list.h"
#include "db_comment.h"

#include "m_string.h"
#include "m_vector.h"
#include "m_map.h"

namespace mstl { class istream; }
namespace mstl { template <typename> class vector; }
namespace util { class Progress; }
namespace sys { namespace utf8 { class Codec; } }

namespace db {

class PgnReader : public Reader
{
public:

	typedef mstl::map<mstl::string,unsigned> Variants;
	typedef unsigned GameCount[variant::NumberOfVariants];
	typedef mstl::vector<unsigned> FileOffsets;

	PgnReader(	mstl::istream& stream,
					variant::Type variant,
					mstl::string const& encoding,
					ReadMode readMode,
					GameCount const* firstGameNumber = 0,
					Modification modification = Normalize,
					ResultMode resultMode = UseResultTag);
	virtual ~PgnReader() throw();

	bool encodingFailed() const override;

	mstl::string const& encoding() const override;
	mstl::string const& description() const;
	uint16_t idn() const override;
	GameCount const& accepted() const;
	GameCount const& rejected() const;
	unsigned accepted(unsigned variant) const;
	unsigned rejected(unsigned variant) const;
	Variants const& unsupportedVariants() const;
	variant::Type detectedVariant() const;

	unsigned process(util::Progress& progress) override;

	void setup(FileOffsets* fileOffsets);
	void setFigurine(mstl::string const& figurine);

	unsigned estimateNumberOfGames() override;
	static unsigned estimateNumberOfGames(unsigned fileSize);

private:

	typedef unsigned Token;

	// return from nextToken()
	static Token const kEoi					= 1 << 0;
	static Token const kStartVariation	= 1 << 1;
	static Token const kEndVariation		= 1 << 2;
	static Token const kTag					= 1 << 3;
	static Token const kSan					= 1 << 4;	// Standard Algebraic Notation
	static Token const kResult				= 1 << 5;
	static Token const kError				= 1 << 6;

	// loop inside nextToken()
	static Token const kNag					= 1 << 7;	// Numeric Annotation Glyph
	static Token const kMovePrefix		= 1 << 8;
	static Token const kComment			= 1 << 9;
	static Token const kOutDated			= 1 << 10;

	// special token
	static Token const PartOfMove			= kSan | kNag | kComment;

	struct Pos
	{
		Pos();

		unsigned line;
		unsigned column;
	};

	struct IllegalMoveWarning
	{
		variant::Type	m_variant;
		Pos				m_pos;
		mstl::string	m_move;
	};

	struct Interruption
	{
		Interruption(Error code, mstl::string const& msg);
		Error error;
		mstl::string message;
	};

	struct Termination {};

	typedef unsigned Count[variant::NumberOfVariants];

	typedef mstl::vector<Comment> Comments;
	typedef mstl::vector<IllegalMoveWarning> Warnings;

	void sendError(Error code, Pos pos, mstl::string const& item = mstl::string::empty_string);
	void sendError(Error code, mstl::string const& item = mstl::string::empty_string);

	void fatalError(Error code, Pos const& pos, mstl::string const& item = mstl::string::empty_string)
		__attribute__((noreturn));
	void fatalError(Error code, mstl::string const& item = mstl::string::empty_string)
		__attribute__((noreturn));

	void sendWarning(Warning code, Pos pos, mstl::string const& item = mstl::string::empty_string);
	void sendWarning(Warning code, mstl::string const& item = mstl::string::empty_string);

	int get(bool allowEndOfInput = false);
	void putback(int c);
	void skipLine();
	void findNextEmptyLine();
	void findNextEmptyLine(mstl::string& str);
	Token skipToEndOfVariation(Token token);
	void setLinePos(char* pos);
	void advanceLinePos(int n = 1);
	variant::Type getVariant() const;

	Token searchTag();
	Token nextToken(Token prevToken);
	Token resultToken(result::ID result);

	bool partOfMove(Token token) const;

	void checkTags();
	void checkFen();
	bool checkTag(tag::ID tag, mstl::string& value);
	void addTag(tag::ID tag, mstl::string const& value);
	void checkVariant();
	bool checkResult();

	void readTags();
	bool readTagName(mstl::string& s);
	void readTagValue(mstl::string& s);
	void stripDiagram(mstl::string& comment);
	bool parseFinalComment(mstl::string const& comment);
	void filterFinalComments();
	bool parseVariant();

	void putNag(nag::ID nag);
	void putNag(nag::ID whiteNag, nag::ID blackNag);
	void putMove(bool lastMove = false);
	void putLastMove();
	void setNullMove();
	void handleError(Error code, mstl::string const& message);
	void finishGame(bool skip = false);
	void checkMode();
	void convertToUtf(mstl::string& s);
	void replaceFigurineSet(char const* fromSet, char const* toSet, mstl::string& str);
	bool testVariant(variant::Type variant) const;
	void setupVariant(variant::Type variant);
	mstl::string inverseFigurineMapping(mstl::string const& str);

	bool doCastling(char const* castle);

	Token endOfInput(Token prevToken, int c);
	Token parseApostrophe(Token prevToken, int c);
	Token parseAtSign(Token prevToken, int c);
	Token parseAsterisk(Token prevToken, int c);
	Token parseBackslash(Token prevToken, int c);
	Token parseCaret(Token prevToken, int c);
	Token parseCastling(Token prevToken, int c);
	Token parseCloseParen(Token prevToken, int c);
	Token parseComment(Token prevToken, int c);
	Token parseEqualsSign(Token prevToken, int c);
	Token parseExclamationMark(Token prevToken, int c);
	Token parseGraveAccent(Token prevToken, int c);
	Token parseGreaterThanSign(Token prevToken, int c);
	Token parseLessThanSign(Token prevToken, int c);
	Token parseLowercaseE(Token prevToken, int c);
	Token parseLowercaseN(Token prevToken, int c);
	Token parseLowercaseO(Token prevToken, int c);
	Token parseLowercaseP(Token prevToken, int c);
	Token parseLowercaseZ(Token prevToken, int c);
	Token parseMate(Token prevToken, int c);
	Token parseMinusSign(Token prevToken, int c);
	Token parseMove(Token prevToken, int c);
	Token parseMoveNumber(Token prevToken, int c);
	Token parseNag(Token prevToken, int c);
	Token parseNumberOne(Token prevToken, int c);
	Token parseNumberZero(Token prevToken, int c);
	Token parsePlusSign(Token prevToken, int c);
	Token parseQuestionMark(Token prevToken, int c);
	Token parseOpenParen(Token prevToken, int c);
	Token parseSlash(Token prevToken, int c);
	Token parseTag(Token prevToken, int c);
	Token parseTilde(Token prevToken, int c);
	Token parseUnderscore(Token prevToken, int c);
	Token parseUppercaseB(Token prevToken, int c);
	Token parseUppercaseD(Token prevToken, int c);
	Token parseUppercaseN(Token prevToken, int c);
	Token parseUppercaseR(Token prevToken, int c);
	Token parseUppercaseZ(Token prevToken, int c);
	Token parseVerticalBar(Token prevToken, int c);
	Token parseWeakPoint(Token prevToken, int c);
	Token skipComment(Token prevToken, int c);
	Token skipDot(Token prevToken, int c);
	Token skipMateSymbol(Token prevToken, int c);
	Token skipWhiteSpace(Token prevToken, int c);
	Token unexpectedSymbol(Token prevToken, int c);

	mstl::istream&		m_stream;
	FileOffsets*		m_fileOffsets;
	unsigned				m_currentOffset;
	unsigned				m_lineOffset;
	unsigned				m_putback;
	char					m_putbackBuf[10];
	mstl::string		m_line;
	mstl::string		m_variantValue;
	Move					m_move;
	char*					m_linePos;
	char*					m_lineEnd;
	Pos					m_currPos;
	Pos					m_prevPos;
	Pos					m_fenPos;
	Pos					m_variantPos;
	unsigned				m_countWarnings[LastWarning + 1];
	unsigned				m_countErrors[LastError + 1];
	ReadMode				m_readMode;
	GameCount			m_gameCount;
	GameCount const*	m_firstGameNumber;
	ResultMode			m_resultMode;
	Comments				m_comments;
	Warnings				m_warnings;
	MarkSet				m_marks;
	country::Code		m_eventCountry;
	Annotation			m_annotation;
	nag::ID				m_prefixAnnotation;
	TagSet				m_tags;
	bool					m_ignoreNags;
	bool					m_noResult;
	result::ID			m_result;
	time::Mode			m_timeMode;
	unsigned				m_significance[2];
	Modification		m_modification;
	bool					m_parsingFirstHdr;
	bool					m_parsingTags;
	bool					m_eof;
	bool					m_hasNote;
	bool					m_atStart;
	bool					m_parsingComment;
	bool					m_sourceIsScidb;
	bool					m_sourceIsPossiblyChessBase;
	bool					m_sourceIsChessOK;
	bool					m_encodingFailed;
	bool					m_ficsGamesDBGameNo;
	bool					m_checkShufflePosition;
	bool					m_isICS;
	bool					m_hasCastled;
	bool					m_resultCorrection;
	unsigned				m_postIndex;
	uint16_t				m_idn;
	variant::Type		m_variant;
	variant::Type		m_givenVariant;
	variant::Type		m_thisVariant;
	mstl::string		m_figurine;
	mstl::string		m_description;
	mstl::string		m_encoding;
	sys::utf8::Codec*	m_codec;
	Count					m_accepted;
	Count					m_rejected;
	Variants				m_variants;
};

} // namespace db

#endif // _db_pgn_reader_included

// vi:set ts=3 sw=3:
