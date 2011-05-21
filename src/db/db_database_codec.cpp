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

#include "db_database_codec.h"
#include "db_consumer.h"
#include "db_producer.h"
#include "db_game_info.h"
#include "db_tag_set.h"
#include "db_exception.h"

#include "sci_codec.h"
#include "si3_codec.h"
#include "cbh_codec.h"

#include "u_byte_stream.h"
#include "u_block_file.h"
#include "u_progress.h"

#include "sys_file.h"

#include "m_string.h"
#include "m_fstream.h"
#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_construct.h"
#include "m_utility.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <string.h>

using namespace db;
using namespace util;


struct DatabaseCodec::InfoData
{
	InfoData(TagSet const& tags);

	country::Code	whiteCountry, blackCountry, eventCountry;
	title::ID		whiteTitle, blackTitle;
	species::ID		whiteType, blackType;
	sex::ID			whiteSex, blackSex;
	event::Type		eventType;
	time::Mode		timeMode;
	event::Mode		eventMode;
	Date				eventDate;
};


DatabaseCodec::InfoData::InfoData(TagSet const& tags)
	:whiteCountry(country::Unknown)
	,blackCountry(country::Unknown)
	,eventCountry(country::Unknown)
	,whiteTitle(title::None)
	,blackTitle(title::None)
	,whiteType(species::Unspecified)
	,blackType(species::Unspecified)
	,whiteSex(sex::Unspecified)
	,blackSex(sex::Unspecified)
	,eventType(event::Unknown)
	,timeMode(time::Unknown)
	,eventMode(event::Undetermined)
{
	if (tags.contains(tag::WhiteCountry))
		whiteCountry = country::fromString(tags.value(tag::WhiteCountry));

	if (tags.contains(tag::WhiteTitle))
		whiteTitle = title::fromString(tags.value(tag::WhiteTitle));

	if (tags.contains(tag::WhiteType))
		whiteType = species::fromString(tags.value(tag::WhiteType));

	if (tags.contains(tag::WhiteSex))
		whiteSex = sex::fromChar(*tags.value(tag::WhiteSex));

	if (tags.contains(tag::BlackCountry))
		blackCountry = country::fromString(tags.value(tag::BlackCountry));

	if (tags.contains(tag::BlackTitle))
		blackTitle = title::fromString(tags.value(tag::BlackTitle));

	if (tags.contains(tag::BlackType))
		blackType = species::fromString(tags.value(tag::BlackType));

	if (tags.contains(tag::BlackSex))
		blackSex = sex::fromChar(*tags.value(tag::BlackSex));

	if (tags.contains(tag::EventType))
		eventType = event::typeFromString(tags.value(tag::EventType));

	if (tags.contains(tag::Mode))
		eventMode = event::modeFromString(tags.value(tag::Mode));

	if (tags.contains(tag::TimeMode))
		timeMode = time::fromString(tags.value(tag::TimeMode));

	if (tags.contains(tag::EventCountry))
		eventCountry = country::fromString(tags.value(tag::EventCountry));

	if (tags.contains(tag::EventDate))
		eventDate.fromString(tags.value(tag::EventDate));
}


DatabaseCodec::CustomFlags::CustomFlags() { ::memset(m_text, 0, sizeof(m_text)); }


void
DatabaseCodec::CustomFlags::set(unsigned n, char const* text)
{
	M_REQUIRE(n < 6);

	unsigned len = mstl::min(size_t(8), ::strlen(text));
	::strncpy(m_text[n], text, len);
	m_text[n][len] = '\0';
}


void
DatabaseCodec::CustomFlags::set(unsigned n, mstl::string const& text)
{
	M_REQUIRE(n < 6);

	unsigned len = mstl::min(size_t(8), text.size());
	::memcpy(m_text[n], text, len);
	m_text[n][len] = '\0';
}


DatabaseCodec::DatabaseCodec() : m_db(0), m_customFlags(0), m_storedInfo(new GameInfo) {}

DatabaseCodec* DatabaseCodec::makeCodec()	{ return new sci::Codec; }


GameInfo*
DatabaseCodec::allocGameInfo()
{
	return m_db->m_allocator.alloc();
}


DatabaseCodec::~DatabaseCodec() throw() { delete m_customFlags; }


bool
DatabaseCodec::hasCodecFor(mstl::string const& suffix)
{
	return suffix == "sci" || suffix == "si3" || suffix == "si4" || suffix == "cbh";
}


DatabaseCodec*
DatabaseCodec::makeCodec(mstl::string const& suffix)
{
	if (suffix == "si4")
	{
		CustomFlags* flags = new CustomFlags;
		DatabaseCodec* codec = new si3::Codec(flags);
		codec->m_customFlags = flags;
		return codec;
	}

	if (suffix == "si3")
		return new si3::Codec();

	if (suffix == "cbh")
		return new cbh::Codec();

	return new sci::Codec;
}


void
DatabaseCodec::recode(GameInfo const&, ByteStream&, sys::utf8::Codec&, sys::utf8::Codec&)
{
	M_RAISE("should not be used");
}


unsigned
DatabaseCodec::putGame(ByteStream const&)
{
	M_RAISE("should not be used");
	return 0;
}


util::ByteStream
DatabaseCodec::getGame(GameInfo const&)
{
	M_RAISE("should not be used");
	return ByteStream();
}


void
DatabaseCodec::updateHeader(mstl::string const&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::save(mstl::string const&, unsigned, Progress&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::update(mstl::string const&, unsigned, bool)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::attach(mstl::string const&, Progress&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::doOpen(mstl::string const&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::doOpen(mstl::string const&, mstl::string const&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::doClear(mstl::string const&)
{
	M_RAISE("should not be used");
}


save::State
DatabaseCodec::doDecoding(Consumer&, ByteStream&, unsigned, TagSet&)
{
	M_RAISE("should not be used");
	return save::UnsupportedVariant;
}


Consumer*
DatabaseCodec::getConsumer(format::Type)
{
	M_RAISE("should not be used");
	return 0;
}


void
DatabaseCodec::filterTag(TagSet&, tag::ID) const
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::checkPermissions(mstl::string const& filename)
{
	M_ASSERT(isOpen());

	if (!m_db->m_readOnly && !sys::file::access(filename, sys::file::Writeable))
		m_db->m_readOnly = true;

	if (m_db->m_readOnly && !sys::file::access(filename, sys::file::Readable))
		IO_RAISE(Unspecified, Open_Failed, "cannot open file: %s", filename.c_str());
}


void
DatabaseCodec::openFile(mstl::fstream& stream, mstl::string const& filename, unsigned openMode)
{
	M_ASSERT(isOpen());

	mstl::ios_base::openmode mode = mstl::ios_base::in | mstl::ios_base::binary;

	if (!(openMode & Readonly))
	{
		if (!m_db->m_readOnly)
			mode |= mstl::ios_base::out;
		if (openMode & Truncate)
			mode |= mstl::ios_base::trunc;
	}

	stream.open(filename, mode);
	stream.exceptions(mstl::ios_base::badbit | mstl::ios_base::eofbit | mstl::ios_base::failbit);
}


void
DatabaseCodec::openFile(mstl::fstream& stream,
								mstl::string const& filename,
								mstl::string const& magic,
								unsigned openMode)
{
	M_ASSERT(isOpen());
	M_ASSERT(!magic.empty());

	mstl::ios_base::openmode mode = mstl::ios_base::in | mstl::ios_base::binary;

	if (!m_db->m_readOnly)
		mode |= mstl::ios_base::out;

	if (openMode & Truncate)
	{
		stream.open(filename, mode | mstl::ios_base::trunc);
		stream.exceptions(mstl::ios_base::badbit | mstl::ios_base::eofbit | mstl::ios_base::failbit);

		if (!stream)
			IO_RAISE(Unspecified, Open_Failed, "cannot open file: %s", filename.c_str());

		if (!stream.write(magic.c_str(), magic.size()))
			IO_RAISE(Unspecified, Write_Failed, "unexpected write error: %s", filename.c_str());
	}
	else
	{
		stream.open(filename, mode);
		stream.exceptions(mstl::ios_base::badbit | mstl::ios_base::eofbit | mstl::ios_base::failbit);

		if (!stream)
			IO_RAISE(Unspecified, Open_Failed, "cannot open file: %s", filename.c_str());

		char buf[magic.size()];

		if (!stream.read(buf, magic.size()))
			IO_RAISE(Unspecified, Write_Failed, "unexpected end of file: %s", filename.c_str());

		if (::memcmp(buf, magic.c_str(), magic.size()) != 0)
			IO_RAISE(Unspecified, Open_Failed, "bad magic: %s", filename.c_str());
	}
}


Time
DatabaseCodec::modified(mstl::string const& rootname) const
{
	sys::file::Time tm;
	sys::file::changed(rootname + "." + extension(), tm);
	return Time(tm);
}


uint32_t
DatabaseCodec::computeChecksum(unsigned, GameInfo const&, uint32_t crc) const
{
	return crc == 0 ? 1 : crc;	// do not use zero!
}


void
DatabaseCodec::open(DatabaseContent* db, mstl::string const& encoding)
{
	M_REQUIRE(db);

	m_db = db;
	doOpen(encoding);
}


void
DatabaseCodec::open(DatabaseContent* db, mstl::string const& rootname, mstl::string const& encoding)
{
	M_REQUIRE(db);

	m_db = db;
	doOpen(rootname, encoding);
}


void
DatabaseCodec::open(	DatabaseContent* db,
							mstl::string const& rootname,
							mstl::string const& encoding,
							Progress& progress)
{
	M_REQUIRE(db);

	m_db = db;
	doOpen(rootname, encoding, progress);
}


void
DatabaseCodec::open(	DatabaseContent* db,
							mstl::string const& encoding,
							Producer& producer,
							Progress& progress)
{
	M_REQUIRE(db);

	m_db = db;
	doOpen(encoding);
	importGames(producer, progress);
}


void
DatabaseCodec::clear(mstl::string const& rootname)
{
	M_REQUIRE(isOpen());

	if (rootname.empty())
	{
		close();
		doOpen(encoding());
	}
	else
	{
		doClear(rootname);
	}
}


unsigned
DatabaseCodec::produce(Producer& producer, Consumer& consumer, util::Progress& progress)
{
	M_REQUIRE(producer.hasConsumer());
	M_REQUIRE(producer.consumer().consumer() == 0);

	producer.consumer().setConsumer(&consumer);
	return importGames(producer, progress);
}


void
DatabaseCodec::getGameRecord(GameInfo const& info, util::BlockFileReader& reader, util::ByteStream& src)
{
	switch (reader.get(src, info.gameOffset(), info.gameRecordLength()))
	{
		case util::BlockFile::SyncFailed:		IO_RAISE(Game, Write_Failed, "sync failed (write error)");
		case util::BlockFile::IllegalOffset:	IO_RAISE(Game, Corrupted, "illegal offset");
		case util::BlockFile::ReadError:			IO_RAISE(Game, Read_Error, "read error");
	}
}


void
DatabaseCodec::doEncoding(util::ByteStream&, GameData const&, Signature const&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::replaceBlockFile(util::BlockFile*)
{
	M_RAISE("should not be used");
}


util::BlockFile*
DatabaseCodec::newBlockFile() const
{
	M_RAISE("should not be used");
	return 0;
}


void
DatabaseCodec::useAsyncReader(bool flag)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::decodeGame(unsigned flags, GameData& data, GameInfo& info)
{
	M_REQUIRE(isOpen());
	doDecoding(flags, data, info);
}


void
DatabaseCodec::encodeGame(util::ByteStream& strm, GameData const& data, Signature const& signature)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(format() != format::ChessBase);

	doEncoding(strm, data, signature);
}


save::State
DatabaseCodec::exportGame(Consumer& consumer, ByteStream& strm, unsigned flags, TagSet& tags)
{
	return doDecoding(consumer, strm, flags, tags);
}


save::State
DatabaseCodec::exportGame(Consumer& consumer, unsigned flags, TagSet& tags, GameInfo const& info)
{
	return doDecoding(consumer, flags, tags, info);
}


unsigned
DatabaseCodec::importGames(Producer& producer, Progress& progress, int startIndex)
{
	M_REQUIRE(isOpen());

	mstl::auto_ptr<Consumer> consumer(getConsumer(producer.format()));
	M_ASSERT(consumer);
	producer.setConsumer(consumer.get());
	producer.consumer().setIndex(startIndex);
	return producer.process(progress);
}


save::State
DatabaseCodec::addGame(ByteStream& gameData, TagSet const& tags, Consumer& consumer)
{
	save::State state;

	if (consumer.consumer())
	{
		TagSet myTags(tags);
		GameInfo::setupTags(myTags, consumer);
		state = exportGame(*consumer.consumer(), gameData, DatabaseCodec::Decode_All, myTags);
	}
	else
	{
		int index = consumer.index();

		if (index >= 0)
		{
			if (unsigned(index) < m_db->m_gameInfoList.size())
			{
				state = saveGame(gameData, tags, consumer);
				consumer.setIndex(index + 1);
			}
			else
			{
				consumer.setIndex(-1);
				state = saveGame(gameData, tags, consumer);
			}
		}
		else
		{
			state = saveGame(gameData, tags, consumer);
		}
	}

	return state;
}


save::State
DatabaseCodec::saveGame(ByteStream const& gameData, TagSet const& tags, Provider const& provider)
{
	M_REQUIRE(isOpen());

	typedef Namebase::PlayerEntry*	Player;
	typedef Namebase::EventEntry*		Event;
	typedef Namebase::SiteEntry*		Site;
	typedef Namebase::Entry*			Entry;

	if (gameData.size() > maxGameRecordLength())
		return save::GameTooLong;
	if (provider.plyCount() > maxGameLength())
		return save::GameTooLong;

	GameInfo* info = 0;

	if (provider.index() >= 0)
	{
		info = m_db->m_gameInfoList[provider.index()];
		*m_storedInfo = *info;
		info->reset(m_db->m_namebases);
	}
	else if (m_db->size() == maxGameCount())
	{
		return save::TooManyGames;
	}

	unsigned maxAnnotatorCount	= this->maxAnnotatorCount();
	unsigned maxPlayerCount		= this->maxPlayerCount();

	InfoData data(tags);

	Player	whiteEntry		= namebase(Namebase::Player).insertPlayer(
										tags.value(tag::White),
										data.whiteCountry,
										data.whiteTitle,
										data.whiteType,
										data.whiteSex,
										maxPlayerCount);
	Player	blackEntry		= namebase(Namebase::Player).insertPlayer(
										tags.value(tag::Black),
										data.blackCountry,
										data.blackTitle,
										data.blackType,
										data.blackSex,
										maxPlayerCount);
	Site		siteEntry		= namebase(Namebase::Site).insertSite(
										tags.value(tag::Site),
										data.eventCountry,
										maxSiteCount());
	Event		eventEntry		= namebase(Namebase::Event).insertEvent(
										tags.value(tag::Event),
										data.eventDate,
										data.eventType,
										data.timeMode,
										data.eventMode,
										maxEventCount(),
										siteEntry ? siteEntry : NamebaseEvent::emptySite());
	Entry		annotatorEntry	= 0;

	if (maxAnnotatorCount)
	{
		annotatorEntry = namebase(Namebase::Annotator).insert(tags.value(tag::Annotator),
																				maxAnnotatorCount);
	}

	bool failed =		whiteEntry == 0
						|| blackEntry == 0
						|| eventEntry == 0
						|| siteEntry == 0
						|| (maxAnnotatorCount > 0 && annotatorEntry == 0);

	unsigned index = info ? provider.index() : m_db->m_gameInfoList.size();

	if (format() != format::Scidb)
	{
		M_ASSERT(format() == format::Scid3 || format() == format::Scid4);

		if (!failed)
		{
			if (!static_cast<si3::Codec*>(this)->saveRoundEntry(index, tags.value(tag::Round)))
				failed = true;
		}
	}

	unsigned gameOffset = 0; // shut up compiler

	if (failed || int(gameOffset = putGame(gameData)) < 0)
	{
		if (info)
			info->restore(*m_storedInfo, m_db->m_namebases);

		if (format() != format::Scidb)
			static_cast<si3::Codec*>(this)->restoreRoundEntry(index);

		namebases().update();

		switch (gameOffset)
		{
			case util::BlockFile::MaxFileSizeExceeded:
				IO_RAISE(Game, Max_File_Size_Exceeded, "maximal file size (2 GB) exceeded");

			case util::BlockFile::SyncFailed:
				IO_RAISE(Game, Write_Failed, "sync failed");

			case util::BlockFile::ReadError:
				IO_RAISE(Game, Read_Error, "read error");

			case util::BlockFile::IllegalOffset:
				IO_RAISE(Game, Write_Failed, "offset failure (internal error)");
		}

		if (!whiteEntry)		return save::TooManyPlayerNames;
		if (!blackEntry)		return save::TooManyPlayerNames;
		if (!eventEntry)		return save::TooManyEventNames;
		if (!siteEntry)		return save::TooManySiteNames;
		if (!annotatorEntry)	return save::TooManyAnnotatorNames;

		return save::TooManyRoundNames;
	}

	if (info == 0)
	{
		info = allocGameInfo();
		m_db->m_gameInfoList.push_back(info);
	}

	info->setup(gameOffset,
					gameData.size(),
					whiteEntry,
					blackEntry,
					eventEntry,
					annotatorEntry,
					tags,
					provider,
					m_db->m_namebases);

	return save::Ok;
}


save::State
DatabaseCodec::addGame(ByteStream const& gameData, GameInfo const& info)
{
	M_REQUIRE(isOpen());

	if (m_db->size() == maxGameCount())
		return save::TooManyGames;
	if (gameData.size() > maxGameRecordLength() || info.plyCount() > maxGameLength())
		return save::GameTooLong;

	mstl::string whitePlayer;
	mstl::string blackPlayer;
	mstl::string event;
	mstl::string site;
	mstl::string annotator;

	whitePlayer.hook(info.playerName(color::White));
	blackPlayer.hook(info.playerName(color::Black));
	event.hook(info.event());
	site.hook(info.site());
	annotator.hook(info.annotator());

	unsigned maxAnnotatorCount = this->maxAnnotatorCount();

	NamebasePlayer*	whiteEntry;
	NamebasePlayer*	blackEntry;
	NamebaseSite*		siteEntry;
	NamebaseEvent*		eventEntry;
	NamebaseEntry*		annotatorEntry	= 0;

	unsigned maxPlayerCount = this->maxPlayerCount();

	whiteEntry = namebase(Namebase::Player).insertPlayer(
							whitePlayer,
							info.federation(color::White),
							info.title(color::White),
							info.playerType(color::White),
							info.sex(color::White),
							maxPlayerCount);
	blackEntry = namebase(Namebase::Player).insertPlayer(
							blackPlayer,
							info.federation(color::Black),
							info.title(color::Black),
							info.playerType(color::Black),
							info.sex(color::Black),
							maxPlayerCount);
	siteEntry = namebase(Namebase::Site).insertSite(
							site,
							info.eventCountry(),
							maxSiteCount());
	eventEntry = namebase(Namebase::Event).insertEvent(
							event,
							info.eventDate(),
							info.eventType(),
							info.timeMode(),
							info.eventMode(),
							maxEventCount(),
							siteEntry ?siteEntry : NamebaseEvent::emptySite());

	if (maxAnnotatorCount)
		annotatorEntry = namebase(Namebase::Annotator).insert(annotator, maxAnnotatorCount);

	bool failed =		whiteEntry == 0
						|| blackEntry == 0
						|| eventEntry == 0
						|| siteEntry == 0
						|| (maxAnnotatorCount > 0 && annotatorEntry == 0);

	if (format() != format::Scidb)
	{
		M_ASSERT(format() == format::Scid3 || format() == format::Scid4);

		if (	!failed
			&& !static_cast<si3::Codec*>(this)->saveRoundEntry(m_db->m_gameInfoList.size(),
																				info.roundAsString()))
		{
			failed = true;
		}
	}

	unsigned gameOffset = 0; // shut up compiler

	if (failed || int(gameOffset = putGame(gameData)) < 0)
	{
		if (format() != format::Scidb)
			static_cast<si3::Codec*>(this)->restoreRoundEntry(m_db->m_gameInfoList.size());

		namebases().update();

		switch (gameOffset)
		{
			case util::BlockFile::MaxFileSizeExceeded:
				IO_RAISE(Game, Max_File_Size_Exceeded, "maximal file size (2 GB) exceeded");

			case util::BlockFile::SyncFailed:
				IO_RAISE(Game, Write_Failed, "sync failed");

			case util::BlockFile::ReadError:
				IO_RAISE(Game, Read_Error, "read error");

			case util::BlockFile::IllegalOffset:
				IO_RAISE(Game, Write_Failed, "offset failure (internal error)");
		}

		if (!whiteEntry)		return save::TooManyPlayerNames;
		if (!blackEntry)		return save::TooManyPlayerNames;
		if (!eventEntry)		return save::TooManyEventNames;
		if (!siteEntry)		return save::TooManySiteNames;
		if (!annotatorEntry)	return save::TooManyAnnotatorNames;

		return save::TooManyRoundNames;
	}

	GameInfo* i = allocGameInfo();
	*i = info;

	i->setup(
		gameOffset,
		gameData.size(),
		whiteEntry,
		blackEntry,
		eventEntry,
		annotatorEntry,
		m_db->m_namebases);

	m_db->m_gameInfoList.push_back(i);
	return save::Ok;
}


save::State
DatabaseCodec::updateCharacteristics(unsigned index, TagSet const& tags)
{
	M_REQUIRE(isOpen());

	typedef Namebase::PlayerEntry*	Player;
	typedef Namebase::EventEntry*		Event;
	typedef Namebase::SiteEntry*		Site;
	typedef Namebase::Entry*			Entry;

	GameInfo* info = m_db->m_gameInfoList[index];
	*m_storedInfo = *info;
	info->resetCharacteristics(m_db->m_namebases);

	unsigned maxAnnotatorCount	= this->maxAnnotatorCount();
	unsigned maxPlayerCount		= this->maxPlayerCount();

	InfoData data(tags);

	Player	whiteEntry		= namebase(Namebase::Player).insertPlayer(
										tags.value(tag::White),
										data.whiteCountry,
										data.whiteTitle,
										data.whiteType,
										data.whiteSex,
										maxPlayerCount);
	Player	blackEntry		= namebase(Namebase::Player).insertPlayer(
										tags.value(tag::Black),
										data.blackCountry,
										data.blackTitle,
										data.blackType,
										data.blackSex,
										maxPlayerCount);
	Site		siteEntry		= namebase(Namebase::Site).insertSite(
										tags.value(tag::Site),
										data.eventCountry,
										maxSiteCount());
	Event		eventEntry		= namebase(Namebase::Event).insertEvent(
										tags.value(tag::Event),
										data.eventDate,
										data.eventType,
										data.timeMode,
										data.eventMode,
										maxEventCount(),
										siteEntry ? siteEntry : NamebaseEvent::emptySite());
	Entry		annotatorEntry	= 0;

	if (maxAnnotatorCount)
	{
		annotatorEntry = namebase(Namebase::Annotator).insert(tags.value(tag::Annotator),
																				maxAnnotatorCount);
	}

	bool failed = 		whiteEntry == 0
						|| blackEntry == 0
						|| eventEntry == 0
						|| siteEntry == 0
						|| (maxAnnotatorCount > 0 && annotatorEntry == 0);

	if (format() != format::Scidb)
	{
		M_ASSERT(format() == format::Scid3 || format() == format::Scid4);

		if (	!failed
			&& !static_cast<si3::Codec*>(this)->saveRoundEntry(index, info->roundAsString()))
		{
			failed = true;
		}
	}

	if (failed)
	{
		info->restore(*m_storedInfo, m_db->m_namebases);

		if (format() != format::Scidb)
			static_cast<si3::Codec*>(this)->restoreRoundEntry(index);

		namebases().update();

		if (!whiteEntry)		return save::TooManyPlayerNames;
		if (!blackEntry)		return save::TooManyPlayerNames;
		if (!eventEntry)		return save::TooManyEventNames;
		if (!siteEntry)		return save::TooManySiteNames;
		if (!annotatorEntry)	return save::TooManyAnnotatorNames;

		return save::TooManyRoundNames;
	}

	info->update(	whiteEntry,
						blackEntry,
						eventEntry,
						annotatorEntry,
						tags,
						m_db->m_namebases);

	return save::Ok;
}

// vi:set ts=3 sw=3:
