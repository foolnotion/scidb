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

namespace db {

inline unsigned Game::id() const							{ return m_id; }
inline Board const& Game::currentBoard() const		{ return m_currentBoard; }
inline Board const& Game::startBoard() const			{ return m_startBoard; }
inline Line const& Game::openingLine() const			{ return m_line; }
inline Eco const& Game::ecoCode() const				{ return m_eco; }
inline uint32_t Game::gameFlags() const				{ return m_flags; }
inline edit::Key const& Game::currentKey() const	{ return m_currentKey; }
inline move::Notation Game::moveStyle() const		{ return m_editorOptions.m_moveStyle; }
inline Game::Command Game::rollbackCommand() const	{ return m_rollbackCommand; }

inline bool Game::isMainline() const					{ return m_currentKey.level() == 0; }
inline bool Game::isVariation() const					{ return m_currentKey.level() > 0; }
inline bool Game::atMainlineStart() const				{ return m_currentNode == m_startNode; }
inline bool Game::hasUndo() const						{ return m_undoIndex > 0; }
inline bool Game::hasRedo() const						{ return m_undoIndex < m_undoList.size(); }
inline bool Game::isModified() const					{ return m_isModified || m_undoIndex > 0; }
inline bool Game::hasVariations() const				{ return countVariations() > 0; }

inline unsigned Game::variationLevel() const			{ return m_currentKey.level(); }
inline color::ID Game::sideToMove() const				{ return m_currentBoard.sideToMove(); }
inline TagSet const& Game::tags() const				{ return m_tags; }
inline GameData const& Game::data() const				{ return *this; }
inline unsigned Game::displayStyle() const			{ return m_editorOptions.m_displayStyle; }
inline Game::SubscriberP Game::subscriber() const	{ return m_subscriber; }

inline void Game::setTags(TagSet const& tags)		{ m_tags = tags; }
inline void Game::removeFlags(unsigned flags)		{ m_flags &= ~flags; }

inline Game::LanguageSet const& Game::languageSet() const { return m_languageSet; }


inline
bool
Game::hasMoveInfo(unsigned moveInfoTypes) const
{
	return countMoveInfo(moveInfoTypes) > 0;
}


inline
void
Game::getNextMoves(StringList& result, move::Notation form, unsigned flags) const
{
	const_cast<Game*>(this)->getMoves(result, flags, form);
}


inline
void
Game::getNextKeys(StringList& result) const
{
	const_cast<Game*>(this)->getKeys(result);
}


inline
Board
Game::board(mstl::string const& key) const
{
	M_REQUIRE(edit::Key::isValid(key));
	return board(edit::Key(key));
}

} // namespace db

// vi:set ts=3 sw=3:
