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
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _app_application_included
#define _app_application_included

#include "db_common.h"
#include "db_tree.h"

#include "u_crc.h"

#include "m_map.h"
#include "m_vector.h"
#include "m_string.h"
#include "m_ref_counted_ptr.h"
#include "m_ref_counter.h"

namespace util { class Progress; }
namespace util { class PipedProgress; }

namespace db {

class Board;
class Game;
class GameInfo;
class NamebasePlayer;
class Producer;
class TagSet;
class Tree;
class Query;
class Log;

} // namespace db

namespace app {

class Cursor;

class Application
{
public:

	typedef util::crc::checksum_t checksum_t;

	static unsigned const InvalidPosition = unsigned(-1);

	struct Subscriber : public mstl::ref_counter
	{
		virtual ~Subscriber() = 0;

		virtual void setBoard(mstl::string const& position) = 0;

		void updateList(mstl::string const& filename);
		void updateList(mstl::string const& filename, unsigned view);

		virtual void updateDatabaseInfo(mstl::string const& filename) = 0;

		virtual void updateGameList(mstl::string const& filename) = 0;
		virtual void updateGameList(mstl::string const& filename, unsigned view) = 0;
		virtual void updateGameList(mstl::string const& filename, unsigned view, unsigned index) = 0;

		virtual void updatePlayerList(mstl::string const& filename) = 0;
		virtual void updatePlayerList(mstl::string const& filename, unsigned view) = 0;
		virtual void updatePlayerList(mstl::string const& filename, unsigned view, unsigned index) = 0;

		virtual void updateEventList(mstl::string const& filename) = 0;
		virtual void updateEventList(mstl::string const& filename, unsigned view) = 0;
		virtual void updateEventList(mstl::string const& filename, unsigned view, unsigned index) = 0;

		virtual void updateAnnotatorList(mstl::string const& filename) = 0;
		virtual void updateAnnotatorList(mstl::string const& filename, unsigned view) = 0;
		virtual void updateAnnotatorList(mstl::string const& filename, unsigned view, unsigned index) = 0;

		virtual void updateGameInfo(mstl::string const& filename, unsigned index) = 0;
		virtual void updateGameInfo(unsigned position) = 0;
		virtual void gameSwitched(unsigned position) = 0;
		virtual void updateTree(mstl::string const& filename) = 0;
		virtual void closeDatabase(mstl::string const& filename) = 0;
	};

	typedef mstl::ref_counted_ptr<Subscriber> SubscriberP;
	typedef mstl::ref_counted_ptr<db::Tree> TreeP;
	typedef mstl::vector<Cursor*> CursorList;

	enum CloseMode	{ Except_Clipbase, Including_Clipbase };
	enum Filter		{ None = 0, Players = 1, Events = 2 };

	Application();
	~Application() throw();

	static bool hasInstance();

	bool isClosed() const;
	bool contains(Cursor& cursor) const;
	bool contains(mstl::string const& name) const;
	bool containsGameAt(unsigned position) const;
	bool isScratchGame(unsigned position) const;
	bool haveCurrentGame() const;
	bool haveCurrentBase() const;
	bool haveClipbase() const;
	bool haveReferenceBase() const;
	bool hasTrialMode(unsigned position = InvalidPosition) const;
	bool switchReferenceBase() const;
	bool treeIsUpToDate(db::Tree::Key const& key) const;

	unsigned countBases() const;
	unsigned countGames() const;
	unsigned countModifiedGames() const;

	void enumCursors(CursorList& list) const;

	Cursor* open(	mstl::string const& filename,
						mstl::string const& encoding,
						bool readOnly,
						util::Progress& progress);
	Cursor* create(mstl::string const& name,
						mstl::string const& encoding,
						db::type::ID type = db::type::Unspecific);

	void close();
	void close(Cursor& cursor);
	void close(mstl::string const& name);
	void closeAll(CloseMode mode);
	void closeAllGames(Cursor& cursor);
	void switchBase(Cursor& cursor);
	void switchBase(mstl::string const& name);
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
	Cursor const& cursor(mstl::string const& name) const;
	Cursor const& cursor(unsigned databaseId) const;

	db::Game& game(unsigned position = InvalidPosition);
	db::Game const& game(unsigned position = InvalidPosition) const;
	mstl::string const& encoding(unsigned position = InvalidPosition) const;
	db::GameInfo const& gameInfo(unsigned index, unsigned view = 0) const;
	db::GameInfo const& gameInfoAt(unsigned position = InvalidPosition) const;
	db::NamebasePlayer const& player(unsigned index, unsigned view = 0) const;
	Subscriber* subscriber() const;
	unsigned gameIndex(unsigned position = InvalidPosition) const;
	unsigned sourceIndex(unsigned position = InvalidPosition) const;
	db::Database const& database(unsigned position = InvalidPosition) const;
	mstl::string const& databaseName(unsigned position = InvalidPosition) const;
	mstl::string const& sourceName(unsigned position = InvalidPosition) const;
	unsigned currentPosition() const;
	unsigned indexAt(unsigned position) const;
	checksum_t checksumIndex(unsigned position = InvalidPosition) const;
	checksum_t checksumMoves(unsigned position = InvalidPosition) const;

	db::load::State loadGame(unsigned position);
	db::load::State loadGame(unsigned position, Cursor& cursor, unsigned index);

	void newGame(unsigned position);
	void deleteGame(Cursor& cursor, unsigned index, unsigned view = 0, bool flag = true);
	void swapGames(unsigned position1, unsigned position2);
	void setGameFlags(Cursor& cursor, unsigned index, unsigned view, unsigned flags);
	void releaseGame(unsigned position);
	void switchGame(unsigned position);
	void clearGame(db::Board const* startPosition = 0);
	void setSource(unsigned position, mstl::string const& name, unsigned index);
	db::save::State writeGame(	unsigned position,
										mstl::string const& filename,
										mstl::string const& encoding,
										mstl::string const& comment,
										unsigned flags) const;
	db::save::State saveGame(Cursor& cursor, bool replace);
	db::save::State updateMoves();
	db::save::State updateCharacteristics(Cursor& cursor, unsigned index, db::TagSet const& tags);
	void setupGame(unsigned linebreakThreshold,
						unsigned linebreakMaxLineLengthMain,
						unsigned linebreakMaxLineLengthVar,
						unsigned linebreakMinCommentLength,
						unsigned displayStyle,
						db::move::Notation moveStyle);
	void setupGameUndo(unsigned undoLevel, unsigned combinePredecessingMoves);
	db::load::State importGame(db::Producer& producer, unsigned position, bool trialMode = false);

	void clearBase(Cursor& cursor);
	void compactBase(Cursor& cursor, ::util::Progress& progress);

	void setReferenceBase(Cursor* cursor);
	void setSwitchReferenceBase(bool flag);

	db::Tree const* currentTree() const;
	bool updateTree(db::tree::Mode mode, db::rating::Type ratingType, util::PipedProgress& progress);
	db::Tree const* finishUpdateTree(db::tree::Mode mode,
												db::rating::Type ratingType,
												db::attribute::tree::ID sortAttr);
	static void stopUpdateTree();
	static void cancelUpdateTree();

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
					db::attribute::annotator::ID attr,
					db::order::ID order);
	void reverse(Cursor& cursor, unsigned view, db::attribute::game::ID attr);
	void reverse(Cursor& cursor, unsigned view, db::attribute::player::ID attr);
	void reverse(Cursor& cursor, unsigned view, db::attribute::event::ID attr);
	void reverse(Cursor& cursor, unsigned view, db::attribute::annotator::ID attr);

	void setSubscriber(SubscriberP subscriber);

	bool initialize(mstl::string const& ecoPath);

	static mstl::string const& clipbaseName();
	static mstl::string const& scratchbaseName();

private:

	struct EditGame
	{
		Cursor*			cursor;
		unsigned			index;
		db::Game*		game;
		db::Game*		backup;
		checksum_t		crcIndex;
		checksum_t		crcMoves;
		unsigned			refresh;
		mstl::string	sourceBase;
		unsigned			sourceIndex;
		mstl::string	encoding;
	};

	EditGame& insertScratchGame(unsigned position);
	EditGame& insertGame(unsigned position);
	Cursor* findBase(mstl::string const& name);
	Cursor const* findBase(mstl::string const& name) const;
	void setReferenceBase(Cursor* cursor, bool isUserSet);
	void moveGamesToScratchbase(Cursor& cursor);
	EditGame* findGame(Cursor* cursor, unsigned index, unsigned* position = 0);
	unsigned findUnusedPosition() const;

	typedef mstl::map<unsigned,EditGame>		GameMap;
	typedef mstl::map<unsigned,unsigned> 		IndexMap;
	typedef mstl::map<mstl::string,Cursor*>	CursorMap;

	Cursor*		m_current;
	Cursor*		m_clipBase;
	Cursor*		m_scratchBase;
	Cursor*		m_referenceBase;
	bool			m_switchReference;
	bool			m_isUserSet;
	unsigned		m_position;
	unsigned		m_fallbackPosition;
	GameMap		m_gameMap;
	CursorMap	m_cursorMap;
	IndexMap		m_indexMap;
	TreeP			m_currentTree;
	bool			m_isClosed;

	mutable SubscriberP m_subscriber;

	static Application* m_instance;

	static mstl::string m_clipbaseName;
	static mstl::string m_scratchbaseName;
};

} // namespace app

#include "app_application.ipp"

#endif // _app_application_included

// vi:set ts=3 sw=3:
