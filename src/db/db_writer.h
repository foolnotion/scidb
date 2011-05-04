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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_writer_included
#define _db_writer_included

#include "db_consumer.h"
#include "db_common.h"

#include "m_string.h"

namespace db {

class Move;
class Annotation;
class MarkSet;
class TagSet;
class Comment;

class Writer : public Consumer
{
public:

	static unsigned const Flag_Include_Variations						= 1 << 0;
	static unsigned const Flag_Include_Comments							= 1 << 1;
	static unsigned const Flag_Include_Annotation						= 1 << 2;
	static unsigned const Flag_Include_Marks								= 1 << 3;
	static unsigned const Flag_Include_Ply_Count_Tag					= 1 << 4;
	static unsigned const Flag_Include_Termination_Tag					= 1 << 5;
	static unsigned const Flag_Include_Mode_Tag							= 1 << 6;
	static unsigned const Flag_Include_Opening_Tag						= 1 << 7;
	static unsigned const Flag_Include_Variation_Tag					= 1 << 8;
	static unsigned const Flag_Include_Sub_Variation_Tag				= 1 << 9;
	static unsigned const Flag_Include_Setup_Tag							= 1 << 10;
	static unsigned const Flag_Include_Variant_Tag						= 1 << 11;
	static unsigned const Flag_Include_Position_Tag						= 1 << 12;
	static unsigned const Flag_Include_Time_Mode_Tag					= 1 << 13;
	static unsigned const Flag_Exclude_Extra_Tags						= 1 << 14;
	static unsigned const Flag_Include_Country_Inside_Player			= 1 << 15;
	static unsigned const Flag_Indent_Variations							= 1 << 16;
	static unsigned const Flag_Indent_Comments							= 1 << 17;
	static unsigned const Flag_Column_Style								= 1 << 18;
	static unsigned const Flag_Symbolic_Annotation_Style				= 1 << 19;
	static unsigned const Flag_Extended_Symbolic_Annotation_Style	= 1 << 20;
	static unsigned const Flag_Convert_Null_Moves_To_Comments		= 1 << 21;
	static unsigned const Flag_Space_After_Move_Number					= 1 << 22;
	static unsigned const Flag_Use_Shredder_FEN							= 1 << 23;
	static unsigned const Flag_Convert_Lost_Result_To_Comment		= 1 << 24;
	static unsigned const Flag_Append_Mode_To_Event_Type				= 1 << 25;
	static unsigned const Flag_Use_ChessBase_Format						= 1 << 26;
	static unsigned const Flag_LAST											= Flag_Use_ChessBase_Format;

	Writer(format::Type srcFormat, unsigned flags, mstl::string const& encoding);

	bool needSpace() const;
	bool insideComment() const;
	bool test(unsigned flags) const;

	unsigned level() const;
	unsigned flags() const;

	bool beginGame(TagSet const& tags);
	save::State endGame(TagSet const& tags);

	void sendComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks);

	bool sendMove(Move const& move);
	bool sendMove(	Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& comment);

	void beginMoveSection();
	void endMoveSection(result::ID result);

	void beginVariation();
	void endVariation();

protected:

	virtual void writeBeginGame(unsigned number) = 0;
	virtual void writeEndGame() = 0;
	virtual void writeComment(Comment const& comment, MarkSet const& marks) = 0;
	virtual void writeTag(mstl::string const& name, mstl::string const& value) = 0;
	virtual void writeTag(tag::ID tag, mstl::string const& value);
	virtual void writeMove(	Move const& move,
									mstl::string const& moveNumber,
									Annotation const& annotation,
									MarkSet const& marks,
									Comment const& comment) = 0;
	virtual void writeBeginMoveSection() = 0;
	virtual void writeEndMoveSection(result::ID result) = 0;
	virtual void writeBeginVariation(unsigned level) = 0;
	virtual void writeEndVariation(unsigned level) = 0;
	virtual void writeBeginComment() = 0;
	virtual void writeEndComment() = 0;

private:

	mstl::string const& conv(mstl::string const& s);

	void writeMove(Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						mstl::string const& comment);

	unsigned			m_flags;
	unsigned			m_count;
	unsigned			m_level;
	unsigned			m_nullLevel;
	mstl::string	m_moveNumber;
	bool				m_needMoveNumber;
	bool				m_needSpace;
	result::ID		m_result;
	mstl::string	m_buf;
};

} // namespace db

#include "db_writer.ipp"

#endif // _db_writer_included

// vi:set ts=3 sw=3:
