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

#ifndef _app_application_included
#define _app_application_included

#include "app_tree_admin.h"

#include "db_common.h"
#include "db_tree.h"

#include "u_crc.h"
#include "u_rkiss.h"

#include "m_map.h"
#include "m_vector.h"
#include "m_string.h"
#include "m_ref_counted_ptr.h"
#include "m_ref_counter.h"
#include "m_bitfield.h"

namespace util { class Progress; }
namespace util { class PipedProgress; }

namespace mstl { class ostream; }
namespace mstl { class string; }

namespace TeXt { class Environment; }

namespace db {

class Board;
class Game;
class GameInfo;
class MultiBase;
class NamebasePlayer;
class Producer;
class TagSet;
class Tree;
class Query;
class Log;

} // namespace db

namespace app {

class MultiCursor;
class Cursor;
class View;
class Engine;
class FAMService;

class Application
{
public:

	typedef util::crc::checksum_t checksum_t;
	typedef mstl::bitfield<uint32_t> Variants;
	typedef mstl::map<mstl::string,unsigned> TagMap;
	typedef db::Byte NagMap[db::nag::Scidb_Last];
	typedef mstl::string Languages[4];

	static unsigned const InvalidPosition	= unsigned(-1);
	static unsigned const ReservedPosition	= unsigned(-2);

	enum Update
	{
		UpdateGameInfo,
		DontUpdateGameInfo,
	};

	enum ReferenceGames
	{
		UpdateReferenceGames,
		DontUpdateReferenceGames,
	};

	enum FileMode
	{
		Create,
		Append,
	};

	struct Subscriber : public mstl::ref_counter
	{
		virtual ~Subscriber() = 0;

		void updateList(	unsigned id,
								mstl::string const& name,
								db::variant::Type variant);
		void updateList(	unsigned id,
								mstl::string const& name,
								db::variant::Type variant,
								unsigned view);

		virtual void updateList(db::table::Type type,
										unsigned id,
										mstl::string const& name,
										db::variant::Type variant) = 0;
		virtual void updateList(db::table::Type type,
										unsigned id,
										mstl::string const& name,
										db::variant::Type variant,
										unsigned view) = 0;
		virtual void updateList(db::table::Type type,
										unsigned id,
										mstl::string const& name,
										db::variant::Type variant,
										unsigned view,
										unsigned index) = 0;

		virtual void updateDatabaseInfo(mstl::string const& name, db::variant::Type variant) = 0;

		virtual void updateGameInfo(	mstl::string const& name,
												db::variant::Type variant,
												unsigned index) = 0;
		virtual void updateGameInfo(unsigned position) = 0;
		virtual void updateGameData(unsigned position, bool evenMainline) = 0;

		virtual void gameSwitched(unsigned position) = 0;
		virtual void gameClosed(unsigned position) = 0;
		virtual void databaseSwitched(mstl::string const& name, db::variant::Type variant) = 0;
		virtual void closeDatabase(mstl::string const& name, db::variant::Type variant) = 0;
		virtual void updateTree(mstl::string const& name, db::variant::Type variant) = 0;
		virtual void invalidateTreeCache() = 0;
	};

	typedef mstl::ref_counted_ptr<Subscriber> SubscriberP;
	typedef mstl::vector<Cursor*> CursorList;
	typedef mstl::vector<MultiCursor*> MultiCursorList;

	enum CloseMode	{ Except_Clipbase, Including_Clipbase };
	enum Filter		{ None = 0, Players = 1 << 0, Events = 1 << 1, Sites = 1 << 2 };

	Application();
	~Application() throw();

	static bool hasInstance();

	bool isClosed() const;
	bool contains(Cursor& cursor) const;
	bool contains(mstl::string const& name) const;
	bool contains(mstl::string const& name, db::variant::Type variant) const;
	bool contains(char const* name, db::variant::Type variant) const;
	bool containsGameAt(unsigned position) const;
	bool isScratchGame(unsigned position) const;
	bool haveCurrentGame() const;
	bool haveCurrentBase() const;
	bool haveClipbase() const;
	bool haveReferenceBase() const;
	bool hasTrialMode(unsigned position = InvalidPosition) const;
	bool switchReferenceBase() const;
	bool treeIsUpToDate(db::Tree::Key const& key) const;
	bool engineExists(unsigned id) const;
	bool isSingleBase(mstl::string const& name) const;
	bool isWritable(mstl::string const& name) const;
	bool isWriting() const;

	unsigned countBases() const;
	unsigned countGames() const;
	unsigned countGames(mstl::string const& name) const;
	unsigned countModifiedGames() const;
	unsigned countEngines() const;
	unsigned maxEngineId() const;

	sys::Thread& treeThread();

	void enumCursors(CursorList& list, db::variant::Type variant) const;
	void enumCursors(MultiCursorList& list) const;

	Cursor* open(	mstl::string const& name,
						mstl::string const& encoding,
						::db::permission::ReadMode permission,
						::db::process::Mode processMode,
						util::Progress& progress);
	Cursor* create(mstl::string const& name,
						db::variant::Type variant,
						mstl::string const& encoding,
						db::type::ID type = db::type::Unspecific);
	unsigned create(	mstl::string const& name,
							db::type::ID type,
							db::Producer& producer,
							util::Progress& progress);

	void close();
	void close(mstl::string const& name);
	void closeAll(CloseMode mode);
	void closeAllGames(Cursor& cursor);
	void switchBase(Cursor& cursor);
	void refreshGames();
	void refreshGame(unsigned position = InvalidPosition, bool immediate = false);

	Cursor& clipBase();
	Cursor const& clipBase() const;
	Cursor& scratchBase();
	Cursor const& scratchBase() const;
	Cursor& referenceBase();
	Cursor const& referenceBase() const;
	Cursor& cursor();
	Cursor const& cursor() const;
	Cursor& cursor(char const* name);
	Cursor const& cursor(char const* name) const;
	Cursor& cursor(mstl::string const& name);
	Cursor& cursor(mstl::string const& name, db::variant::Type variant);
	Cursor const& cursor(mstl::string const& name) const;
	Cursor const& cursor(mstl::string const& name, db::variant::Type variant) const;
	Cursor const& cursor(unsigned databaseId) const;
	Cursor const& getGameCursor(unsigned position) const;

	int getViewId(unsigned position = InvalidPosition) const;
	int getNextGameIndex(unsigned position = InvalidPosition) const;
	int getPrevGameIndex(unsigned position = InvalidPosition) const;
	int getFirstGameIndex(unsigned position = InvalidPosition) const;
	int getLastGameIndex(unsigned position = InvalidPosition) const;
	int getRandomGameIndex(unsigned position = InvalidPosition) const;

	MultiCursor& multiCursor();
	MultiCursor const& multiCursor() const;
	MultiCursor& multiCursor(mstl::string const& name);
	MultiCursor const& multiCursor(mstl::string const& name) const;
	db::MultiBase& multiBase(mstl::string const& name);
	db::MultiBase const& multiBase(mstl::string const& name) const;

	db::variant::Type currentVariant() const;
	Variants getAllVariants() const;
	Variants getAllVariants(mstl::string const& name) const;

	db::Game& game(unsigned position = InvalidPosition);
	db::Game const& game(unsigned position = InvalidPosition) const;
	mstl::string const& encoding(unsigned position = InvalidPosition) const;
	db::GameInfo const& gameInfo(unsigned index, unsigned view = 0) const;
	db::GameInfo const& gameInfoAt(unsigned position = InvalidPosition) const;
	db::NamebasePlayer const& player(unsigned index, unsigned view = 0) const;
	Subscriber* subscriber() const;
	unsigned gameIndex(unsigned position = InvalidPosition) const;
	unsigned gameNumber(unsigned position = InvalidPosition) const;
	unsigned sourceIndex(unsigned position = InvalidPosition) const;
	checksum_t sourceCrcIndex(unsigned position = InvalidPosition) const;
	checksum_t sourceCrcMoves(unsigned position = InvalidPosition) const;
	db::Database const& database(unsigned position = InvalidPosition) const;
	mstl::string const& databaseName(unsigned position = InvalidPosition) const;
	mstl::string const& sourceName(unsigned position = InvalidPosition) const;
	db::variant::Type variant(unsigned position = InvalidPosition) const;
	unsigned currentPosition() const;
	unsigned indexAt(unsigned position) const;
	checksum_t checksumIndex(unsigned position = InvalidPosition) const;
	checksum_t checksumMoves(unsigned position = InvalidPosition) const;
	mstl::string const& currentlyWriting() const;
	bool verifyGame(unsigned position);

	db::load::State loadGame(unsigned position);
	db::load::State loadGame(	unsigned position,
										Cursor& cursor,
										unsigned index,
										mstl::string const* fen = 0);

	void newGame(unsigned position, db::variant::Type variant = db::variant::Normal);
	void deleteGame(Cursor& cursor, unsigned index, unsigned view = 0, bool flag = true);
	void changeVariant(unsigned position, db::variant::Type variant);
	void swapGamePositions(unsigned position1, unsigned position2);
	void setGameFlags(Cursor& cursor, unsigned index, unsigned view, unsigned flags);
	void releaseGame(unsigned position);
	void switchGame(unsigned position, ReferenceGames updateReferenceGames);
	void clearGame(db::Board const* startPosition = 0);
	void setupGame(db::Board const& startPosition);
	void setSource(unsigned position,
						mstl::string const& name,
						unsigned index,
						checksum_t crcIndex,
						checksum_t crcMoves);
	bool setReadonly(MultiCursor& cursor, bool flag);
	void setIsWriting(mstl::string const& name = mstl::string::empty_string);
	db::save::State writeGame(	unsigned position,
										mstl::string const& filename,
										mstl::string const& encoding,
										mstl::string const& comment,
										unsigned flags,
										FileMode fmode);
	::db::save::State exportGame(	unsigned position,
											mstl::ostream& strm,
											unsigned flags,
											::db::copy::Source source);
	db::save::State saveGame(Cursor& cursor, bool replace);
	db::save::State updateMoves();
	db::save::State updateCharacteristics(Cursor& cursor, unsigned index, db::TagSet const& tags);
	void setupGame(unsigned linebreakThreshold,
						unsigned linebreakMaxLineLengthMain,
						unsigned linebreakMaxLineLengthVar,
						unsigned linebreakMinCommentLength,
						unsigned displayStyle,
						unsigned moveInfoTypes,
						db::move::Notation moveStyle);
	void setupGameUndo(unsigned undoLevel, unsigned combinePredecessingMoves);
	db::load::State importGame(db::Producer& producer, unsigned position, bool trialMode = false);
	void bindGameToDatabase(unsigned position, mstl::string const& name, unsigned index);
	void bindGameToView(unsigned position, int viewId, Update updateMode = UpdateGameInfo);
	void save(mstl::string const& name, util::Progress& progress);
	::db::file::State save(	mstl::string const& name,
									mstl::string const& encoding,
									unsigned flags,
									util::Progress& progress);
	void startUpdateTree(Cursor& cursor);
	unsigned stripMoveInformation(View& view,
											unsigned types,
											util::Progress& progress,
											Update updateMode);
	unsigned stripTags(View& view, TagMap const& tags, util::Progress& progress, Update updateMode);
	void viewClosed(Cursor const& cursor, unsigned viewId);
	void swapGames(unsigned sourcePosition, unsigned destinationPosition);
	void copyGame(MultiCursor& sink, unsigned position, ::db::copy::Source source);
	void duplicateGame(unsigned position, ::db::copy::Source source, unsigned destination);
	void pasteLastClipbaseGame(unsigned position);
	bool mergeGame(unsigned primary,
						unsigned secondary,
						db::position::ID startPosition,
						db::move::Order moveOrder,
						unsigned variationDepth,
						unsigned maximalVariationLength,
						unsigned modificationPosition);
	void pasteGame(unsigned from, unsigned to);
	void printGame(unsigned position,
						TeXt::Environment& environment,
						db::format::Type format,
						unsigned flags,
						unsigned options,
						NagMap const& nagMap,
						Languages const& languages,
						unsigned significantLanguages) const;

	unsigned addEngine(Engine* engine);
	void removeEngine(unsigned id);
	Engine* engine(unsigned id) const;
	mstl::ostream* setEngineLog(mstl::ostream* strm = 0);
	mstl::ostream* engineLog() const;
	bool startAnalysis(unsigned engineId);
	bool stopAnalysis(unsigned engineId);

	void clearBase(Cursor& cursor);
	void clearBase(MultiCursor& cursor);
	void compactBase(Cursor& cursor, ::util::Progress& progress);
	void changeVariant(mstl::string const& name, ::db::variant::Type variant);

	void setReferenceBase(Cursor* cursor);
	void setSwitchReferenceBase(bool flag);

	db::Tree const* currentTree() const;
	bool updateTree(db::tree::Mode mode, db::rating::Type ratingType, util::PipedProgress& progress);
	db::Tree const* finishUpdateTree(db::tree::Mode mode,
												db::rating::Type ratingType,
												db::attribute::tree::ID sortAttr);
	void freezeTree(bool flag);
	void stopUpdateTree();
	void cancelUpdateTree();

	void startTrialMode();
	void endTrialMode();

	void searchGames(Cursor& cursor, db::Query const& query, unsigned view = 0, unsigned filter = None);
	void recode(Cursor& cursor, mstl::string const& encoding, util::Progress& progress);
	void finalize();

	void sort(	Cursor& cursor,
					unsigned view,
					db::attribute::game::ID attr,
					db::order::ID order,
					db::rating::Type ratingType = db::rating::Any);
	void sort(	Cursor& cursor,
					unsigned view,
					db::attribute::player::ID attr,
					db::order::ID order,
					db::rating::Type ratingType = db::rating::Any);
	void sort(	Cursor& cursor,
					unsigned view,
					db::attribute::event::ID attr,
					db::order::ID order);
	void sort(	Cursor& cursor,
					unsigned view,
					db::attribute::site::ID attr,
					db::order::ID order);
	void sort(	Cursor& cursor,
					unsigned view,
					db::attribute::annotator::ID attr,
					db::order::ID order);
	void reverseOrder(Cursor& cursor, unsigned view, db::table::Type type);
	void resetOrder(Cursor& cursor, unsigned view, db::table::Type type);

	void setSubscriber(SubscriberP subscriber);

	uint32_t rand32() const;
	uint32_t rand32(uint32_t n) const;

	bool initialize(mstl::string const& ecoPath);

	static mstl::string const& clipbaseName();
	static mstl::string const& scratchbaseName();

private:

	struct EditGame : public mstl::ref_counter
	{
		struct Data
		{
			Data();
			~Data();

			int				viewId;
			db::Game*		game;
			db::Game*		backup;
			unsigned			refresh;
			mstl::string	encoding;
		};

		struct Sink
		{
			Sink();

			Cursor*			cursor;
			unsigned			index;
			checksum_t		crcIndex;
			checksum_t		crcMoves;
			checksum_t		crcMainline;
		};

		struct Link
		{
			Link();

			mstl::string	databaseName;
			unsigned			index;
			checksum_t		crcIndex;
			checksum_t		crcMoves;
		};

		Sink sink;
		Link link;
		Data data;
	};

	typedef mstl::ref_counted_ptr<EditGame>		GameP;
	typedef mstl::map<unsigned,GameP>				GameMap;
	typedef mstl::map<unsigned,unsigned> 			IndexMap;
	typedef mstl::ref_counted_ptr<MultiCursor>	CursorP;
	typedef mstl::map<mstl::string,CursorP>		CursorMap;
	typedef mstl::vector<Engine*>						EngineList;

	struct Iterator
	{
		Iterator(CursorMap::const_iterator begin, CursorMap::const_iterator end);
		bool operator!=(Iterator const& i) const;
		Iterator& operator++();
		Cursor* operator->();
		Cursor& operator*();

		CursorMap::const_iterator	m_current;
		CursorMap::const_iterator	m_end;
		unsigned							m_variant;
	};

	Iterator begin() const;
	Iterator end() const;

	Cursor* clipbase(db::variant::Type variant) const;
	Cursor* clipbase(unsigned variantInddx) const;
	Cursor* scratchbase(db::variant::Type variant) const;
	Cursor* scratchbase(unsigned variantIndex) const;

	GameP createIntermediateGame(GameP original);
	GameP insertScratchGame(unsigned position, db::variant::Type variant);
	GameP insertGame(unsigned position);
	Cursor* findBase(mstl::string const& name);
	Cursor* findBase(mstl::string const& name, db::variant::Type variant);
	Cursor const* findBase(	mstl::string const& name) const;
	Cursor const* findBase(	mstl::string const& name, db::variant::Type variant) const;
	void setReferenceBase(Cursor* cursor, bool isUserSet);
	void moveGameToScratchbase(GameMap::value_type& entry, bool overtake);
	void moveGamesToScratchbase(Cursor& cursor, bool overtake = false);
	void moveGamesBackToDatabase(Cursor& cursor);
	EditGame* findGame(Cursor* cursor, unsigned index, unsigned* position = 0);
	unsigned findUnusedPosition() const;
	void setActiveBase(Cursor* cursor);
	void stopAnalysis(db::Game const* game);
	void updateGameInfo(Cursor const& cursor, db::Database& database);
	bool compact(Cursor& cursor, util::Progress& progress);
	bool compact(Cursor& cursor);
	void clearTreeCache();
	void invalidateTreeCache(unsigned gameIndex);

	Cursor*			m_current;
	Cursor*			m_clipbase;
	Cursor*			m_referenceBase;
	bool				m_switchReference;
	bool				m_isUserSet;
	unsigned			m_currentPosition;
	unsigned			m_fallbackPosition;
	unsigned			m_updateCount;
	GameMap			m_gameMap;
	CursorMap		m_cursorMap;
	IndexMap			m_indexMap;
	EngineList		m_engineList;
	unsigned			m_numEngines;
	mstl::ostream*	m_engineLog;
	bool				m_isClosed;
	bool				m_treeIsFrozen;
	mstl::string	m_isWriting;
	TreeAdmin		m_treeAdmin;

	mutable util::RKiss m_rand;

	mutable SubscriberP m_subscriber;

	static Application*	m_instance;
	static FAMService*	m_famService;
};

} // namespace app

#include "app_application.ipp"

#endif // _app_application_included

// vi:set ts=3 sw=3:
