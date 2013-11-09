// ======================================================================
// Author : $Author$
// Version: $Revision: 957 $
// Date   : $Date: 2013-09-30 17:11:24 +0200 (Mon, 30 Sep 2013) $
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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _app_book_included
#define _app_book_included

#include "db_move.h"

#include "m_string.h"
#include "m_pvector.h"

namespace db { class Board; }

namespace app {

class Book
{
public:

	// Format Scidb is an extended Polyglot format (compatible)
	enum Format { Polyglot, Scidb, ChessBase };
	enum Colors { None, Green, Yellow, Blue, Red };
	enum Choice	{ Best, BestFirst, Random };

	struct Entry
	{
		Entry();

		union Info
		{
			struct
			{
				uint16_t	learnPoints;		/// learning points (poylglot)
				uint16_t	learnCount;			/// learning count (polyglot)
			};

			struct
			{
				uint32_t include:1;			/// include flag
				uint32_t exclude:1;			/// exclude flag
				uint32_t mainline:1;			/// mainline flag
				uint32_t bookmark:1;			/// user flag
				uint32_t newline:1;			/// new line flag
				uint32_t white:1;				/// good for White
				uint32_t black:1;				/// good for Black
				uint32_t verify:1;			/// to be verified by further analysis
				uint32_t train:1;				/// to train
				uint32_t remove:1;			/// to remove
				uint32_t color:3;				/// colored square in front of move
				uint32_t annotation:5;		/// move annotation (NAG 0-23)
				uint32_t commentary:8;		/// commentary to position after move
				uint32_t __unused__:6;
			};

			uint32_t __value__;
		};

		struct Item
		{
			Item();

			db::Move			move;
			uint16_t			weight;				/// weight of this move
			uint16_t			avgRatingGames;	/// average rating #games
			uint16_t			avgRatingScore;	/// average rating score
			uint16_t			perfRatingGames;	/// performance rating #games
			uint16_t			perfRatingScore;	/// performance rating score
			mstl::string	comment;
			Info				info;					/// additional information
			unsigned			total;				/// total number of games
			unsigned			wins;					/// number of games won by White
			unsigned			losses;				/// number of games won by Black
			unsigned			draws;				/// number of games drawn
		};

		typedef mstl::pvector<Item> Items;

		Items				items;
		unsigned			totalWeight;
		mstl::string	comment;				/// position comment (scidb)
	};

	virtual ~Book() = 0;

	virtual bool isReadonly() const = 0;
	bool isWriteable() const;
	virtual bool isOpen() const = 0;
	virtual bool isEmpty() const = 0;
	virtual bool isModified() const;
	virtual bool isPersistent() const;

	virtual Format format() const = 0;
	mstl::string const& filename() const;

	virtual db::Move probeMove(db::Board const& position, db::variant::Type variant, Choice choice) = 0;
	virtual bool probePosition(db::Board const& position, db::variant::Type variant, Entry& result) = 0;

	virtual bool remove(db::Board const& position, db::variant::Type variant);
	virtual bool modify(db::Board const& position, db::variant::Type variant, Entry const& entry);
	virtual bool add(db::Board const& position, db::variant::Type variant, Entry const& entry);

	static Book* open(mstl::string const& filename);

private:

	mstl::string m_filename;
};

} // namespace app

#include "app_book.ipp"

#endif // _app_book_included

// vi:set ts=3 sw=3:
