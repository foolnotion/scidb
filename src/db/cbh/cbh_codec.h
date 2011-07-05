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

#ifndef _cbh_codec_included
#define _cbh_codec_included

#include "db_database_codec.h"
#include "db_date.h"

#include "m_fstream.h"
#include "m_map.h"
#include "m_vector.h"
#include "m_chunk_allocator.h"

namespace sys { namespace utf8 { class Codec; }; };

namespace util { class ByteStream; };

namespace db {

class NamebaseEntry;
class NamebaseEvent;
class NamebasePlayer;
class TagSet;
class GameInfo;
class Date;

namespace cbh {

class Codec : public DatabaseCodec
{
public:

	Codec();
	~Codec() throw();

	bool encodingFailed() const;

	Format format() const;

	unsigned maxGameRecordLength() const;
	unsigned maxGameLength() const;
	unsigned maxGameCount() const;
	unsigned maxPlayerCount() const;
	unsigned maxEventCount() const;
	unsigned maxSiteCount() const;
	unsigned maxAnnotatorCount() const;
	unsigned minYear() const;
	unsigned maxYear() const;
	unsigned maxDescriptionLength() const;

	unsigned gameFlags() const;

	mstl::string const& extension() const;
	mstl::string const& encoding() const;
	void filterTag(TagSet& tags, tag::ID tag, Section section) const;

	void doOpen(mstl::string const& rootname,
					mstl::string const& encoding,
					util::Progress& progress);
	void reloadDescription(mstl::string const& rootname);
	void reloadNamebases(mstl::string const& rootname, util::Progress& progress);

	void close();

	void doDecoding(GameData& data, GameInfo& info);
	save::State doDecoding(Consumer& consumer, TagSet& tags, GameInfo const& info);

	void reset();
	void setEncoding(mstl::string const& encoding);

	Move findExactPositionAsync(GameInfo const& info, Board const& position, bool skipVariations);

private:

	class Source;

	struct Team
	{
		mstl::string	title;
		country::Code	nation;
	};

	struct Tournament
	{
		Tournament();
		Tournament(Byte cat, Byte nrounds);

		Byte category;
		Byte rounds;
	}
	__attribute__((packed));

	typedef mstl::map<uint32_t,NamebaseEntry*>				BaseMap;
	typedef mstl::map<uint32_t,uint32_t>					AnnotationMap;
	typedef mstl::map<GameInfo const*,Source*>				SourceMap;
	typedef mstl::map<NamebaseEvent const*,Tournament>	TournamentMap;
	typedef mstl::chunk_allocator<NamebaseEvent>			Allocator;
	typedef mstl::vector<Team*>								TeamBase;
	typedef mstl::map<GameInfo const*,unsigned>			GameIndexLookup;

	void startDecoding(	util::ByteStream& gameStream,
								util::ByteStream& annotationStream,
								GameInfo const& info,
								bool& isChess960);
	void decodeIndex(util::ByteStream& strm, GameInfo& info);

	unsigned readHeader(mstl::string const& rootname);

	void readIniData(mstl::string const& rootname);
	void readPlayerData(mstl::string const& rootname, util::Progress& progress);
	void readTournamentData(mstl::string const& rootname, util::Progress& progress);
	void readAnnotatorData(mstl::string const& rootname, util::Progress& progress);
	void readSourceData(mstl::string const& rootname, util::Progress& progress);
	void readTeamData(mstl::string const& rootname, util::Progress& progress);
	void readIndexData(mstl::string const& rootname, util::Progress& progress);
	void reloadPlayerData(mstl::string const& rootname, util::Progress& progress);
	void reloadTournamentData(mstl::string const& rootname, util::Progress& progress);
	void reloadAnnotatorData(mstl::string const& rootname, util::Progress& progress);
	void reloadSourceData(mstl::string const& rootname, util::Progress& progress);
	void reloadTeamData(mstl::string const& rootname, util::Progress& progress);
	void reloadIndexData(mstl::string const& rootname, util::Progress& progress);

	void addSourceTags(TagSet& tags, GameInfo const& info);
	void addEventTags(TagSet& tags, GameInfo const& info);

	NamebasePlayer* getPlayer(uint32_t ref);
	NamebaseEvent* getEvent(uint32_t ref);
	NamebaseEntry* getAnnotator(uint32_t ref);
	Source* getSource(uint32_t ref);

	void addTeamTags(TagSet& tags, GameInfo const& info);
	void mapPlayerName(mstl::string& str);
	void toUtf8(mstl::string& str);

	sys::utf8::Codec*	m_codec;
	mstl::fstream		m_gameStream;
	mstl::fstream		m_annotationStream;
	mstl::fstream		m_teamStream;
	AnnotationMap		m_annotationMap;
	BaseMap				m_playerMap;
	BaseMap				m_eventMap;
	BaseMap				m_annotatorMap;
	SourceMap			m_sourceMap;
	BaseMap				m_sourceMap2;
	TournamentMap		m_tournamentMap;
	TeamBase				m_teamBase;
	GameIndexLookup	m_gameIndexLookup;
	Allocator			m_allocator;
	Namebase				m_sourceBase;
	NamebaseEvent*		m_illegalEvent;
	NamebasePlayer*	m_illegalPlayer;
	unsigned				m_siteId;
	unsigned				m_numGames;
	bool					m_highQuality;
};

} // namespace cbh
} // namespace db

#endif // _cbh_codec_included

// vi:set ts=3 sw=3:
