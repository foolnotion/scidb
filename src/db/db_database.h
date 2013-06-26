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

#ifndef _db_database_included
#define _db_database_included

#include "db_database_content.h"
#include "db_tree_cache.h"
#include "db_consumer.h"
#include "db_time.h"
#include "db_move.h"

#include "u_crc.h"

#include "m_string.h"

namespace mstl { class fstream; }
namespace mstl { class ostream; }
namespace mstl { template <typename T, typename U> class map; }
namespace util { class Progress; }
namespace util { class ByteStream; }
namespace util { class BlockFileReader; }
namespace TeXt { class Receptacle; }

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
class PlayerStats;
class TournamentTable;
class Filter;
class Selector;
class Log;

class Database : private DatabaseContent
{
public:

	typedef type::ID Type;
	typedef format::Type Format;
	typedef Consumer::TagBits TagBits;
	typedef mstl::map<mstl::string,unsigned> TagMap;

	enum Access { GameIndex, MyIndex };

	Database(Database const& db, mstl::string const& name);
	Database(mstl::string const& name,
				mstl::string const& encoding);
	Database(mstl::string const& name,
				mstl::string const& encoding,
				storage::Type storage,
				variant::Type variant,
				Type type = type::Unspecific);
	Database(mstl::string const& name,
				mstl::string const& encoding,
				permission::ReadMode mode,
				util::Progress& progress);
	Database(mstl::string const& name, Producer& producer, util::Progress& progress);
	~Database() throw();

	/// Cast
	DatabaseContent const& content() const;

	/// Returns whether current database is empty.
	bool isEmpty() const;
	/// Returns whether the database is set read-only or not.
	bool isReadonly() const;
	/// Returns whether the database is potentially writable or not.
	bool isWritable() const;
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
	/// Returns whether this database should be compressed.
	bool shouldCompress() const;
	/// Return whether this database is opened with temporary storage.
	bool hasTemporaryStorage() const;
	/// Return whether this database contains unsaved changes.
	bool hasChanged() const;
	/// Return whether specified game is deleted.
	bool isDeleted(unsigned index) const;
	/// Return whether specified game has changed.
	bool hasChanged(unsigned index) const;
	/// Return whether the descriptuon has changed.
	bool descriptionHasChanged() const;
	/// Return whether file is unchanged.
	bool checkFileTime() const;
	/// Return whether game with given index is newly added.
	bool isAdded(unsigned index) const;
	/// Returns whether database is not unsaved.
	bool isUnsaved() const;

	/// Returns an unique database id.
	unsigned id() const;
	/// Count the number of items in table.
	unsigned count(table::Type type) const;
	/// Count the number of initial games in the database.
	unsigned countInitialGames() const;
	/// Count the number of games in the database.
	unsigned countGames() const;
	/// Count the number of players in the database.
	unsigned countPlayers() const;
	/// Count the number of events in the database.
	unsigned countEvents() const;
	/// Count the number of sites in the database.
	unsigned countSites() const;
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
	/// Return the variant of this database (may be undetermined if database is empty)
	variant::Type variant() const;
	/// Return the variant of specified game number
	variant::Type variant(unsigned index) const;
	/// Returns the (decoding) format of database
	Format format() const;
	/// Returns the encoding of database
	mstl::string const& encoding() const;
	/// Returns date of last modification.
	Time modified() const;
	/// Returns time of creation.
	Time created() const;
	/// Return timestamp of creation.
	uint32_t creationTimestamp() const;
	/// Returns statistic of database
	Statistic const& statistic() const;
	/// Returh maximal length of description.
	unsigned maxDescriptionLength() const;
	/// Return timestamp of last change.
	uint64_t lastChange() const;
	/// Compute CRC for given game index.
	util::crc::checksum_t computeChecksum(unsigned index) const;
	/// Return the number of saved games in the database.
	unsigned size() const;

	/// Returns game information at given index.
	GameInfo const& gameInfo(unsigned index) const;
	/// Returns game information at given index.
	GameInfo& gameInfo(unsigned index);
	/// Returns the player at given index.
	NamebasePlayer const& player(unsigned index) const;
	/// Returns the player for given game index and specified side.
	NamebasePlayer const& player(unsigned gameIndex, color::ID side) const;
	/// Returns the event at given index.
	NamebaseEvent const& event(unsigned index, Access access = MyIndex) const;
	/// Returns the site at given index.
	NamebaseSite const& site(unsigned index, Access access = MyIndex) const;
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
	/// Loads a game from the given position.
	load::State loadGame(unsigned index, Game& game, mstl::string& encoding, mstl::string const* fen = 0);
	/// Saves a game at the given position.
	void replaceGame(unsigned index, Game const& game);
	/// Adds a game to the database.
	save::State newGame(Game& game, GameInfo const& info);
	/// Deletes (or undeletes) a game from the database.
	void deleteGame(unsigned index, bool flag = true);
	/// Set the game flags of the specified game.
	void setGameFlags(unsigned index, unsigned flags);
	/// Export one game at the given position.
	save::State exportGame(unsigned index, Consumer& consumer) const;
	/// Export one game at the given position.
	save::State exportGame(unsigned index, Database& destination) const;
	/// Export games into an open database.
	// The destination may be either a producer or a database.
	template <class Destination>
	unsigned exportGames(Destination& destination,
								Filter const& gameFilter,
								Selector const& gameSelector,
								copy::Mode copyMode,
								unsigned& illegalRejected,
								Log& log,
								util::Progress& progress) const;
	// Copy games from this database to the destination database.
	unsigned copyGames(	Database& destination,
								Filter const& gameFilter,
								Selector const& gameSelector,
								TagBits const& allowedTags,
								bool allowExtraTags,
								unsigned& illegalRejected,
								Log& log,
								util::Progress& progress) const;
	/// Add new game to database.
	save::State addGame(Game& game);
	/// Replace game in database.
	save::State updateGame(Game& game);
	/// Update the characteristics of a game
	save::State updateCharacteristics(unsigned index, TagSet const& tags);
	/// Update the move data of a game
	save::State updateMoves(Game& game);

	/// Removes all games from the database.
	void clear();
	/// Re-open the database.
	void reopen(mstl::string const& encoding, util::Progress& progress);
	/// Close database.
	void close();
	/// Sync database (save unsaved data).
	void sync(util::Progress& progress);
	/// Attach database to a file.
	void attach(mstl::string const& filename, util::Progress& progress);
	/// Update database files.
	void save(util::Progress& progress);
	/// Write complete index of database to stream.
	void writeIndex(mstl::ostream& os, util::Progress& progress);
	/// Write complete namebases of database to stream.
	void writeNamebases(mstl::ostream& os, util::Progress& progress);
	/// Write all games of database to stream.
	void writeGames(mstl::ostream& os, util::Progress& progress);
	/// Recode content of database.
	void recode(mstl::string const& encoding, util::Progress& progress);
	/// Rename the database.
	void rename(mstl::string const& name);
	/// Remove database from disk
	void remove();
	/// Reset changed status to unchanged
	void resetChangedStatus();
	/// Reset initial size to current size.
	void resetInitialSize();
	/// Reset initial size to given size.
	void resetInitialSize(unsigned size);

	/// Build tournament table for selected games.
	TournamentTable* makeTournamentTable(Filter const& gameFilter) const;
	/// Generate player dossier from whole database for given player.
	void playerStatistic(NamebasePlayer const& player, PlayerStats& stats) const;
	/// Generate player card information for given player.
	void emitPlayerCard(TeXt::Receptacle& receptacle, NamebasePlayer const& player) const;

	/// Open an asynchronous game stream (block file) reader for findExactPositionAsync() operation.
	void openAsyncReader();
	/// Close asynchronous game stream reader.
	void closeAsyncReader();

	/// Setup tag/value pairs.
	void setupTags(unsigned index, TagSet& tags) const;
	/// Set database type.
	void setType(Type type);
	/// Set variant of database games.
	void setVariant(variant::Type variant);
	/// Set description of database.
	void setupDescription(mstl::string const& description);
	/// Change description of database.
	void updateDescription(mstl::string const& description);
	/// Set/unset read-only flag.
	bool setReadonly(bool flag = true);
	/// Set/unset writable flag.
	void setWritable(bool flag);

	/// Strip move information from all selected games.
	unsigned stripMoveInformation(Filter const& filter, unsigned types, util::Progress& progress);
	/// Strip PGN tags from all selected games.
	unsigned stripTags(Filter const& filter, TagMap const& tags, util::Progress& progress);

	/// Search for givee position and return following move.
	Move findExactPosition(unsigned index, Board const& position, bool skipVariations) const;
	/// Find all used tags in database.
	void findTags(Filter const& filter, TagMap& tags, util::Progress& progress) const;

	/// Import single game.
	unsigned importGame(Producer& producer, unsigned index);
	/// Import whole database.
	unsigned importGames(Producer& producer, util::Progress& progress);
	/// Import whole database.
	unsigned importGames(Database const& src,
								unsigned& illegalRejected,
								Log& log,
								util::Progress& progress);

	Namebases& namebases();
	using DatabaseContent::namebase;

private:

	typedef ::util::BlockFileReader AsyncReader;

	/// Opens the given database.
	bool open(mstl::string const& name, bool readOnly);
	/// Read the given gzipped PGN file
	bool open(mstl::string const& name, mstl::fstream& stream);

	void setEncodingFailed(bool flag) const;
	load::State loadGame(unsigned index, Game& game, mstl::string* encoding, mstl::string const* fen);

	NamebaseEntry const* insertPlayer(mstl::string const& name);
	NamebaseEntry const* insertEvent(mstl::string const& name);
	NamebaseEntry const* insertSite(mstl::string const& name);
	NamebaseEntry const* insertAnnotator(mstl::string const& name);

	DatabaseCodec*	m_codec;
	mstl::string	m_name;
	unsigned			m_id;
	unsigned			m_size;
	unsigned			m_initialSize;
	uint64_t			m_lastChange;
	uint32_t			m_fileTime;
	TreeCache		m_treeCache;
	AsyncReader*	m_asyncReader;
	mutable bool	m_encodingFailed;
	mutable bool	m_encodingOk;
	bool				m_descriptionHasChanged;
	bool				m_usingAsyncReader;
};

} // namespace db

#include "db_database.ipp"

#endif // _db_database_included

// vi:set ts=3 sw=3:
