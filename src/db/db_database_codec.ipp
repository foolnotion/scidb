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

#include "m_assert.h"

namespace db {

inline bool DatabaseCodec::isOpen() const								{ return m_db; }
inline bool DatabaseCodec::isReadonly() const						{ return m_db->m_readOnly; }
inline bool DatabaseCodec::shouldCompress() const					{ return m_db->m_shouldCompress; }
inline void DatabaseCodec::setType(DatabaseContent::Type type) { m_db->m_type = type; }
inline void DatabaseCodec::setVariant(variant::Type variant)	{ m_db->m_variant = variant; }
inline void DatabaseCodec::setCreated(uint32_t time)				{ m_db->m_created = time; }
inline void DatabaseCodec::shouldCompress(bool flag)				{ m_db->m_shouldCompress = flag; }
inline mstl::string const& DatabaseCodec::description() const	{ return m_db->m_description; }
inline DatabaseContent::Type DatabaseCodec::type() const			{ return m_db->m_type; }
inline variant::Type DatabaseCodec::variant() const				{ return m_db->m_variant; }
inline uint32_t DatabaseCodec::created() const						{ return m_db->m_created; }
inline Namebases& DatabaseCodec::namebases()							{ return m_db->m_namebases; }
inline void DatabaseCodec::updateHeader()								{ updateHeader(m_db->m_rootname); }
inline void DatabaseCodec::reloadDescription()						{ reloadDescription(m_db->m_rootname); }
inline void DatabaseCodec::removeAllFiles()							{ removeAllFiles(m_db->m_rootname); }

inline void DatabaseCodec::setDescription(char const* description) { m_db->m_description = description; }


inline
Move
DatabaseCodec::findExactPosition(GameInfo const& info, Board const& position, bool skipVariations)
{
	return findExactPosition(info, position, skipVariations, 0);
}


inline
void
DatabaseCodec::save(unsigned start, util::Progress& progress)
{
	save(m_db->m_rootname, start, progress);
}


inline
void
DatabaseCodec::update(unsigned index, bool updateNamebase)
{
	update(m_db->m_rootname, index, updateNamebase);
}


inline
void
DatabaseCodec::attach(util::Progress& progress)
{
	attach(m_db->m_rootname, progress);
}


inline
void
DatabaseCodec::reloadNamebases(util::Progress& progress)
{
	reloadNamebases(m_db->m_rootname, m_db->m_suffix, progress);
}


inline
DatabaseCodec::GameInfoList&
DatabaseCodec::gameInfoList()
{
	return m_db->m_gameInfoList;
}


inline
GameInfo&
DatabaseCodec::gameInfo(unsigned index)
{
	M_REQUIRE(index < gameInfoList().size());
	return *m_db->m_gameInfoList[index];
}


inline
Namebase&
DatabaseCodec::namebase(Namebase::Type type)
{
	return m_db->namebase(type);
}


inline
DatabaseCodec::CustomFlags const&
DatabaseCodec::customFlags() const
{
	M_REQUIRE(format() == format::Scid4);
	M_ASSERT(m_customFlags);

	return *m_customFlags;
}


inline
DatabaseCodec::CustomFlags&
DatabaseCodec::customFlags()
{
	M_REQUIRE(format() == format::Scid4);
	M_ASSERT(m_customFlags);

	return *m_customFlags;
}


inline
char const*
DatabaseCodec::CustomFlags::get(unsigned n) const
{
	M_REQUIRE(n < 6);
	return m_text[n];
}


inline
void
DatabaseCodec::encodeGame(util::ByteStream& strm, GameData const& data, Signature const& signature)
{
	encodeGame(strm, data, signature, TagBits(true), true);
}

} // namespace db

// vi:set ts=3 sw=3:
