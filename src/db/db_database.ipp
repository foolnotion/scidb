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

#include "db_database_codec.h"

#include "m_assert.h"

namespace db {

inline bool Database::isEmpty() const							{ return m_size == 0; }
inline bool Database::isOpen() const							{ return m_codec; }
inline bool Database::isReadonly() const						{ return m_readOnly; }
inline bool Database::isWritable() const						{ return m_writable; }
inline bool Database::shouldUpgrade() const					{ return m_codec->isExpired(); }
inline bool Database::isMemoryOnly() const					{ return m_memoryOnly; }
inline bool Database::encodingIsBroken() const				{ return !m_encodingOk; }
inline bool Database::encodingFailed() const					{ return m_encodingFailed; }
inline bool Database::hasTemporaryStorage() const			{ return m_temporary; }
inline bool Database::descriptionHasChanged() const		{ return m_descriptionHasChanged; }
inline bool Database::isAdded(unsigned index) const		{ return index >= m_initialSize; }
inline bool Database::isUnsaved() const						{ return m_size < m_gameInfoList.size(); }
inline bool Database::usingAsyncTreeSearchReader() const	{ return m_asyncReader; }

inline unsigned Database::id() const							{ return m_id; }
inline unsigned Database::countGames() const					{ return m_gameInfoList.size(); }
inline unsigned Database::countPlayers() const				{ return m_namebases(Namebase::Player).used(); }
inline unsigned Database::countEvents() const				{ return m_namebases(Namebase::Event).used(); }
inline unsigned Database::countSites() const					{ return m_namebases(Namebase::Site).used(); }
inline unsigned Database::countInitialGames() const		{ return m_initialSize; }
inline mstl::string const& Database::name() const			{ return m_name; }
inline mstl::string const& Database::description() const	{ return m_description; }
inline type::ID Database::type() const							{ return m_type; }
inline Statistic const& Database::statistic() const		{ return m_statistic; }
inline uint64_t Database::lastChange() const					{ return m_lastChange; }
inline DatabaseContent const& Database::content() const	{ return *this; }
inline TreeCache const& Database::treeCache() const		{ return m_treeCache; }
inline TreeCache& Database::treeCache()						{ return m_treeCache; }
inline Namebases& Database::namebases()						{ return m_namebases; }
inline Time Database::created() const							{ return m_created; }
inline uint32_t Database::creationTime() const				{ return m_created; }
inline unsigned Database::size() const							{ return m_size; }

inline void Database::resetInitialSize()						{ resetInitialSize(m_size); }


inline
DatabaseCodec const&
Database::codec() const
{
	M_REQUIRE(isOpen());
	return *m_codec;
}


inline
bool
Database::usingAsyncReader() const
{
	return isOpen() && (bool(m_asyncReader) || m_codec->usingAsyncReader());
}


inline
DatabaseCodec&
Database::codec()
{
	M_REQUIRE(isOpen());
	return *m_codec;
}


inline
NamebasePlayer const&
Database::player(unsigned index) const
{
	M_REQUIRE(index < countPlayers());
	return *m_namebases(Namebase::Player).player(index);
}


inline
mstl::string const&
Database::encoding() const
{
	M_REQUIRE(isOpen());
	return m_encoding;
}


inline
mstl::string const&
Database::usedEncoding() const
{
	M_REQUIRE(isOpen());
	return m_usedEncoding;
}


inline
Time
Database::modified() const
{
	M_REQUIRE(isOpen());
	return m_codec->modified();
}


inline
unsigned
Database::maxDescriptionLength() const
{
	M_REQUIRE(isOpen());
	return m_codec->maxDescriptionLength();
}


inline
format::Type
Database::format() const
{
	return m_codec->format();
}


inline
variant::Type
Database::variant() const
{
	return m_variant;
}


inline
void
Database::setEncodingFailed(bool flag) const
{
	if ((m_encodingFailed = flag))
		m_encodingOk = false;
}


inline
mstl::string const&
Database::extension() const
{
	M_REQUIRE(isOpen());
	return m_codec->extension();
}


inline
GameInfo const&
Database::gameInfo(unsigned index) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	return *m_gameInfoList[index];
}


inline
GameInfo&
Database::gameInfo(unsigned index)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	return *m_gameInfoList[index];
}


inline
NamebaseEntry const*
Database::insertPlayer(mstl::string const& name)
{
	M_REQUIRE(isOpen());
	M_ASSERT(!isReadonly());

	return m_namebases(Namebase::Player).insert(name, m_codec->maxPlayerCount());
}


inline
NamebaseEntry const*
Database::insertEvent(mstl::string const& name)
{
	M_REQUIRE(isOpen());
	M_ASSERT(!isReadonly());

	return m_namebases(Namebase::Event).insert(name, m_codec->maxEventCount());
}


inline
NamebaseEntry const*
Database::insertSite(mstl::string const& name)
{
	M_REQUIRE(isOpen());
	M_ASSERT(!isReadonly());

	return m_namebases(Namebase::Site).insert(name, m_codec->maxSiteCount());
}


inline
NamebaseEntry const*
Database::insertAnnotator(mstl::string const& name)
{
	M_REQUIRE(isOpen());
	M_ASSERT(!isReadonly());

	return m_namebases(Namebase::Annotator).insert(name, m_codec->maxAnnotatorCount());
}


inline
load::State
Database::loadGame(unsigned index, Game& game)
{
	return loadGame(index, game, 0, 0);
}


inline
load::State
Database::loadGame(unsigned index, Game& game, mstl::string& encoding, mstl::string const* fen)
{
	return loadGame(index, game, &encoding, fen);
}

} // namespace db

// vi:set ts=3 sw=3:
