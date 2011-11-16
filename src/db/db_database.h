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

#ifndef _db_database_included
#define _db_database_included

#include "db_database_content.h"
#include "db_tree_cache.h"
#include "db_time.h"
#include "db_move.h"

#include "u_crc.h"

#include "m_string.h"

namespace mstl { class fstream; }
namespace util { class Progress; }
namespace util { class ByteStream; }

namespace db {

class Board;
class Game;
class GameInfo;
class TagSet;
class DatabaseCodec;
class Consumer;
class Producer;
class Statistic;
class NamebaseEntry;
class NamebasePlayer;
class TournamentTable;
class Filter;
class Log;

class Database : private DatabaseContent
{
public:

	typedef type::ID Type;
	typedef format::Type Format;

	enum Storage	{ MemoryOnly, OnDisk };
	enum Mode		{ ReadOnly, ReadWrite };

	Database(mstl::string const& name,
				mstl::string const& encoding,
				Storage storage = MemoryOnly,
				Type type = type::Unspecific);
	Database(mstl::string const& name,
				mstl::string const& encoding,
				Mode mode,
				util::Progress& progress);
	Database(mstl::string const& name, Producer& producer, util::Progress& progress);
	~Database() throw();

	/// Cast
	DatabaseContent const& content() const;

	/// Returns whether the database is set read-only or not.
	bool isReadOnly() const;
	/// Returns whether the database is petentially writeable or not.
	bool isWriteable() const;
	/// Returns whether the database is memory-only or not.
	bool isMemoryOnly() const;
	/// Returns whether the database is open.
	bool isOpen() const;
	/// Returns whether encoding failed.
	bool encodingFailed() const;
	/// Returns whether encoding is broken.
	bool encodingIsBroken() const;
	/// Returns whether asynchronous reader is in use.
	bool usingAsyncReader() const;
	/// Returns whether the database format should be upgraded.
	bool shouldUpgrade() const;

	/// Returns an unique database id.
	unsigned id() const;
	/// Counts the number of games in the database.
	unsigned countGames() const;
	/// Count the number of players in the database.
	unsigned countPlayers() const;
	/// Count the number of events in the database.
	unsigned countEvents() const;
	/// Count the number of annotators in the database.
	unsigned countAnnotators() const;
	/// Count number of attendants of given event.
	unsigned countPlayers(NamebaseEvent const& event, unsigned& averageElo, unsigned& category) const;
	/// Returns name of database (may be a file name)
	mstl::string const& name() const;
	/// Returns extension of database name (codec type)
	mstl::string const& extension() const;
	/// Returns description of database
	mstl::string const& description() const;
	/// Returns the type of database
	Type type() const;
	/// Returns the (decoding) format of database
	Format format() const;
	/// Returns the encoding of database
	mstl::string const& encoding() const;
	/// Returns date of last modification.
	Time modified() const;
	/// Returns date of creation.
	Time created() const;
	/// Returns statistic of database
	Statistic const& statistic() const;
	/// Returh maximal length of description.
	unsigned maxDescriptionLength() const;
	/// Return timestamp of last change.
	uint64_t lastChange() const;
	/// Compute CRC for given game index.
	util::crc::checksum_t computeChecksum(unsigned index) const;

	/// Returns game information at given index.
	GameInfo const& gameInfo(unsigned index) const;
	/// Returns game information at given index.
	GameInfo& gameInfo(unsigned index);
	/// Returns the player at given index.
	NamebasePlayer const& player(unsigned index) const;
	/// Returns the event at given index.
	NamebaseEvent const& event(unsigned index) const;
	/// Returns the annotator at given index.
	NamebaseEntry const& annotator(unsigned index) const;
	/// Collect tags specific for current database format.
	void getInfoTags(unsigned index, TagSet& tags) const;
	/// Collect tags specific for current database format.
	void getGameTags(unsigned index, TagSet& tags) const;

	/// Returns the codec.
	DatabaseCodec& codec();
	/// Returns the codec.
	DatabaseCodec const& codec() const;
	/// Returns the tree cache.
	TreeCache const& treeCache() const;
	/// Returns the tree cache.
	TreeCache& treeCache();

	/// Loads a game from the given position.
	load::State loadGame(unsigned index, Game& game);
	/// Saves a game at the given position.
	void replaceGame(unsigned index, Game const& game);
	/// Adds a game to the database.
	save::State newGame(Game& game, GameInfo const& info);
	/// Deletes (or undeletes) a game from the database.
	void deleteGame(unsigned index, bool flag = true);
	/// Set the game flags of the specified game.
	void setGameFlags(unsigned index, unsigned flags);
	/// Export one game at the given position.
	save::State exportGame(unsigned index, Consumer& consumer);
	/// Export one game at the given position.
	save::State exportGame(unsigned index, Database& destination);
	/// Add new game to database.
	save::State addGame(Game const& game);
	/// Replace game in database.
	save::State updateGame(Game const& game);
	/// Update the characteristics of a game
	save::State updateCharacteristics(unsigned index, TagSet const& tags);
	/// Update the move data of a game
	save::State updateMoves(Game const& game);

	/// Removes all games from the database.
	void clear();
	/// Compacts the database.
	void compact();
	/// Re-open the database.
	void reopen(mstl::string const& encoding, util::Progress& progress);
	/// Close database.
	void close();
	/// Attach database to a file.
	void attach(mstl::string const& filename, util::Progress& progress);
	/// Update database files.
	void save(util::Progress& progress, unsigned start = 0);
	/// Recode content of database.
	void recode(mstl::string const& encoding, util::Progress& progress);

	/// Build tournament table for selected games.
	TournamentTable* makeTournamentTable(Filter const& gameFilter) const;

	/// Open an asynchronous game stream (block file) reader for findExactPositionAsync() operation.
	void openAsyncReader();
	/// Close asynchronous game stream reader.
	void closeAsyncReader();

	/// Setup tag/value pairs.
	void setupTags(unsigned index, TagSet& tags) const;
	/// Set database type.
	void setType(Type type);
	/// Set description of database.
	void setDescription(mstl::string const& description);
	/// Set/unset read-only flag.
	void setReadOnly(bool flag = true);

	/// Search for givee position and return following move.
	Move findExactPositionAsync(unsigned index, Board const& position, bool skipVariations) const;

	/// Import single game.
	unsigned importGame(Producer& producer, unsigned index);
	/// Import whole database.
	unsigned importGames(Producer& producer, util::Progress& progress);

	Namebases& namebases();
	using DatabaseContent::namebase;

private:

	/// Opens the given database.
	bool open(mstl::string const& name, bool readOnly);
	/// Read the given gzipped PGN file
	bool open(mstl::string const& name, mstl::fstream& stream);

	void setEncodingFailed(bool flag);

	NamebaseEntry const* insertPlayer(mstl::string const& name);
	NamebaseEntry const* insertEvent(mstl::string const& name);
	NamebaseEntry const* insertSite(mstl::string const& name);
	NamebaseEntry const* insertAnnotator(mstl::string const& name);

	DatabaseCodec*	m_codec;
	mstl::string	m_name;
	mstl::string	m_rootname;
	unsigned			m_id;
	unsigned			m_size;
	uint64_t			m_lastChange;
	TreeCache		m_treeCache;
	bool				m_encodingFailed;
	bool				m_encodingOk;
	bool				m_usingAsyncReader;
};

} // namespace db

#include "db_database.ipp"

#endif // _db_database_included

// vi:set ts=3 sw=3:
