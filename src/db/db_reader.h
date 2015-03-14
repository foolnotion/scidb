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

#ifndef _db_reader_included
#define _db_reader_included

#include "db_producer.h"

namespace mstl { class string; }
namespace mstl { class istream; }

namespace db {

class TagSet;

class Reader : public Producer
{
public:

	enum ReadMode
	{
		File,
		Game,
		Variation,
	};

	enum ResultMode
	{
		UseResultTag,
		InMoveSection,
	};

	enum Modification
	{
		Normalize,
		Raw,
	};

	enum Tag
	{
		None,
		Elo,
		Country,
		Title,
		Human,
		Sex,
		Program,
	};

	enum Error
	{
		InvalidToken,
		UnexpectedSymbol,
		UnexpectedEndOfInput,
		UnexpectedTag,
		UnexpectedResultToken,
		UnexpectedEndOfGame,
		TagNameExpected,
		TagValueExpected,
		InvalidFen,
		UnterminatedString,
		UnterminatedVariation,
		InvalidMove,
		UnsupportedVariant,
		SeemsNotToBePgnText,
		UnexpectedCastling,
		ContinuationsNotSupported,

		LastError = ContinuationsNotSupported,
	};

	enum Warning
	{
		MissingWhitePlayerTag,
		MissingBlackPlayerTag,
		MissingPlayerTags,
		MissingResult,
		MissingResultTag,
		InvalidRoundTag,
		InvalidResultTag,
		InvalidDateTag,
		InvalidEventDateTag,
		InvalidTimeModeTag,
		InvalidEcoTag,
		InvalidTagName,
		InvalidCountryCode,
		InvalidRating,
		InvalidNag,
		BraceSeenOutsideComment,
		MissingFen,
		FixedInvalidFen,
		UnknownEventType,
		UnknownTitle,
		UnknownPlayerType,
		UnknownSex,
		UnknownTermination,
		RatingTooHigh,
		UnknownMode,
		EncodingFailed,
		TooManyNags,
		ResultDidNotMatchHeaderResult,
		IllegalCastling,
		IllegalMove,
		CastlingCorrection,
		ValueTooLong,
		NotSuicideNotGiveaway,
		VariantChangedToGiveaway,
		VariantChangedToSuicide,
		ResultCorrection,
		MaximalErrorCountExceeded,
		MaximalWarningCountExceeded,

		LastWarning = MaximalWarningCountExceeded,
	};

	Reader(format::Type srcFormat);

	virtual void warning(Warning code,
								unsigned lineNo,
								unsigned column,
								unsigned gameNo,
								variant::Type variant,
								mstl::string const& info,
								mstl::string const& item) = 0;
	virtual void error(	Error code,
								unsigned lineNo,
								unsigned column,
								unsigned gameNo,
								variant::Type variant,
								mstl::string const& message,
								mstl::string const& info,
								mstl::string const& item) = 0;
	virtual void error(	save::State state,
								unsigned lineNo,
								unsigned gameNo,
								variant::Type variant) = 0;

	static bool validateTagName(char* tag, unsigned len);
	static bool validateTagName(char const* s, char const* e);
	static void checkSite(TagSet& tags, country::Code eventCountry, bool sourceIsPossiblyChessBase);

	static event::Mode getEventMode(char const* event, char const* site);
	static country::Code extractCountryFromSite(mstl::string& data);
	static Tag extractPlayerData(mstl::string& data, mstl::string& value);
	static time::Mode getTimeModeFromTimeControl(mstl::string const& value);
	static termination::Reason getTerminationReason(mstl::string const& value);
	static bool parseRound(mstl::string const& data, unsigned& round, unsigned& subround);
	static bool getAttributes(mstl::string const& filename, int& numGames, mstl::string* description = 0);

	virtual unsigned estimateNumberOfGames() = 0;

protected:

	static void parseDescription(mstl::istream& strm, mstl::string& result, mstl::string* encoding = 0);

private:

	static void trimDescription(mstl::string& descr);
};

} // namespace db

#include "db_reader.ipp"

#endif // _db_reader_included

// vi:set ts=3 sw=3:
