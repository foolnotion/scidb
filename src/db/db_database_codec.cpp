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
#include "db_database.h"
#include "db_consumer.h"
#include "db_producer.h"
#include "db_game_info.h"
#include "db_tag_set.h"
#include "db_reader.h"
#include "db_exception.h"

#include "sci_codec.h"
#include "si3_codec.h"
#include "cbh_codec.h"
#include "cbf_codec.h"

#include "u_byte_stream.h"
#include "u_block_file.h"
#include "u_progress.h"

#include "sys_file.h"

#include "u_misc.h"

#include "m_string.h"
#include "m_fstream.h"
#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_construct.h"
#include "m_utility.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <string.h>
#include <stdio.h>

using namespace db;
using namespace util;
using namespace sys;


struct DatabaseCodec::InfoData
{
	InfoData(TagSet const& tags);

	mstl::string const& normalizeWhitePlayerName(mstl::string const& name, mstl::string& result);
	mstl::string const& normalizeBlackPlayerName(mstl::string const& name, mstl::string& result);
	mstl::string const& normalizeSiteName(mstl::string const& name, mstl::string& result);

	country::Code	whiteCountry, blackCountry, eventCountry;
	title::ID		whiteTitle, blackTitle;
	species::ID		whiteType, blackType;
	sex::ID			whiteSex, blackSex;
	uint32_t			whiteFideID, blackFideID;
	uint16_t			whiteElo, blackElo;
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
	,whiteFideID(0)
	,blackFideID(0)
	,whiteElo(0)
	,blackElo(0)
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

	if (tags.contains(tag::WhiteFideId))
		whiteFideID = tags.asInt(tag::WhiteFideId);

	if (tags.contains(tag::BlackFideId))
		blackFideID = tags.asInt(tag::BlackFideId);

	if (tags.contains(tag::EventType))
		eventType = event::typeFromString(tags.value(tag::EventType));

	if (tags.contains(tag::Mode))
		eventMode = event::modeFromString(tags.value(tag::Mode));

	if (tags.contains(tag::TimeMode))
		timeMode = time::fromString(tags.value(tag::TimeMode));

	if (tags.contains(tag::EventType))
		eventType = event::typeFromString(tags.value(tag::EventType));

	if (tags.contains(tag::EventCountry))
		eventCountry = country::fromString(tags.value(tag::EventCountry));

	if (tags.contains(tag::EventDate))
		eventDate.fromString(tags.value(tag::EventDate));
}


mstl::string const&
DatabaseCodec::InfoData::normalizeWhitePlayerName(mstl::string const& name, mstl::string& result)
{
	Reader::Tag		tag;
	mstl::string	value;

	result.assign(name.c_str(), name.size());

	while ((tag = Reader::extractPlayerData(result, value)) != Reader::None)
	{
		switch (tag)
		{
			case Reader::Country:
				if (whiteCountry == country::Unknown)
					whiteCountry = country::fromString(value);
				break;

			case Reader::Title:
				if (whiteTitle == title::None)
					whiteTitle = title::fromString(value);
				break;

			case Reader::Human:
				if (whiteType == species::Unspecified)
					whiteType = species::Human;
				break;

			case Reader::Program:
				if (whiteType == species::Unspecified)
					whiteType = species::Program;
				break;

			case Reader::Sex:
				if (whiteSex == sex::Unspecified)
					whiteSex = sex::fromString(value);
				break;

			case Reader::Elo:
				whiteElo = ::atoi(value);
				break;

			case Reader::None:
				break;
		}
	}

	return result;
}


mstl::string const&
DatabaseCodec::InfoData::normalizeBlackPlayerName(mstl::string const& name, mstl::string& result)
{
	Reader::Tag	tag;
	mstl::string	value;

	result.assign(name.c_str(), name.size());

	while ((tag = Reader::extractPlayerData(result, value)) != Reader::None)
	{
		switch (tag)
		{
			case Reader::Country:
				if (blackCountry == country::Unknown)
					blackCountry = country::fromString(value);
				break;

			case Reader::Title:
				if (blackTitle == title::None)
					blackTitle = title::fromString(value);
				break;

			case Reader::Human:
				if (blackType == species::Unspecified)
					blackType = species::Human;
				break;

			case Reader::Program:
				if (blackType == species::Unspecified)
					blackType = species::Program;
				break;

			case Reader::Sex:
				if (blackSex == sex::Unspecified)
					blackSex = sex::fromString(value);
				break;

			case Reader::Elo:
				blackElo = ::atoi(value);
				break;

			case Reader::None:
				break;
		}
	}

	return result;
}


mstl::string const&
DatabaseCodec::InfoData::normalizeSiteName(mstl::string const& name, mstl::string& result)
{
	result.assign(name.c_str(), name.size());
	country::Code country = Reader::extractCountryFromSite(result);
	if (eventCountry == country::Unknown)
		eventCountry = country;
	return result;
}


DatabaseCodec::CustomFlags::CustomFlags() { ::memset(m_text, 0, sizeof(m_text)); }


bool
DatabaseCodec::isExpired() const
{
	return false;
}


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

	unsigned len = mstl::min(mstl::string::size_type(8), text.size());
	::memcpy(m_text[n], text, len);
	m_text[n][len] = '\0';
}


DatabaseCodec::DatabaseCodec() : m_db(0), m_customFlags(0), m_storedInfo(new GameInfo) {}

DatabaseCodec* DatabaseCodec::makeCodec()	{ return new sci::Codec; }


DatabaseCodec::~DatabaseCodec() throw() { delete m_customFlags; }

bool DatabaseCodec::upgradeIndexOnly() { return sci::Codec::upgradeIndexOnly(); }


bool
DatabaseCodec::hasCodecFor(mstl::string const& suffix)
{
	return	suffix == "sci"
			|| suffix == "si3"
			|| suffix == "si4"
			|| suffix == "cbh"
			|| suffix == "cbf"
			|| suffix == "CBF";
}


DatabaseCodec*
DatabaseCodec::makeCodec(mstl::string const& name, Mode mode)
{
	mstl::string ext(misc::file::suffix(name));

	if (ext == "si4")
	{
		CustomFlags* flags = new CustomFlags;
		DatabaseCodec* codec = new si3::Codec(flags);
		codec->m_customFlags = flags;
		return codec;
	}

	if (ext == "si3")
		return new si3::Codec;

	if (ext == "cbh")
		return new cbh::Codec;

	if (ext == "cbf" || ext == "CBF")
		return new cbf::Codec;

	if (ext == "sci" && mode == Existing)
		return sci::Codec::makeCodec(name);

	return new sci::Codec;
}


bool
DatabaseCodec::getAttributes(	mstl::string const& filename,
										int& numGames,
										type::ID& type,
										variant::Type& variant,
										uint32_t& creationTime,
										mstl::string* description)
{
	mstl::string ext(misc::file::suffix(filename));

	type = type::Unspecific;
	variant = variant::Normal;
	creationTime = 0;
	numGames = -1;

	if (description)
		description->clear();

	if (ext == "sci")
		return sci::Codec::getAttributes(filename, numGames, type, variant, creationTime, description);

	if (ext == "cbh")
		return cbh::Codec::getAttributes(filename, numGames, type, description);

	if (ext == "cbf" || ext == "CBF")
		return cbf::Codec::getAttributes(filename, numGames, type, description);

	if (ext == "si3" || ext == "si4")
		return si3::Codec::getAttributes(filename, numGames, type, description);

	return Reader::getAttributes(filename, numGames, description);
}


void
DatabaseCodec::getSuffixes(mstl::string const& filename, StringList& result)
{
	mstl::string ext;

	if (filename.find('.') == mstl::string::npos)
		ext = filename;
	else
		ext = misc::file::suffix(filename);

	if (ext == "sci")
	{
		sci::Codec::getSuffixes(filename, result);
	}
	else if (ext == "cbh")
	{
		cbh::Codec::getSuffixes(filename, result);
	}
	else if (ext == "cbf")
	{
		cbf::Codec::getSuffixes(filename, result);
	}
	else if (ext == "CBF")
	{
		unsigned start = result.size();

		cbf::Codec::getSuffixes(filename, result);

		for (unsigned i = start; i < result.size(); ++i)
			result[i].toupper();
	}
	else if (ext == "si3" || ext == "si4")
	{
		si3::Codec::getSuffixes(filename, result);
	}
	else
	{
		result.push_back(ext);
	}
}


void
DatabaseCodec::useEncoding(mstl::string const& encoding)
{
	M_ASSERT(isOpen());
	m_db->m_encoding = encoding;
}


unsigned
DatabaseCodec::putGame(ByteStream const&)
{
	M_RAISE("should not be used");
	return 0;
}


unsigned
DatabaseCodec::putGame(ByteStream const&, unsigned, unsigned)
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
DatabaseCodec::removeAllFiles(mstl::string const& rootname)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::writeNamebases(mstl::ostream&, util::Progress&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::writeIndex(mstl::ostream&, util::Progress&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::writeGames(mstl::ostream&, util::Progress&)
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
DatabaseCodec::reloadNamebases(mstl::string const&, mstl::string const&, util::Progress&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::reloadDescription(mstl::string const& rootname)
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


unsigned
DatabaseCodec::doOpenProgressive(mstl::string const& rootname, mstl::string const& encoding)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::doClear(mstl::string const&)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::readIndexProgressive(unsigned index)
{
	M_RAISE("should not be used");
}


save::State
DatabaseCodec::doDecoding(Consumer&, ByteStream&/*, unsigned*/, TagSet&)
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


bool
DatabaseCodec::stripMoveInformation(GameInfo const&, unsigned)
{
	M_RAISE("should not be used");
	return false;
}


bool
DatabaseCodec::stripTags(GameInfo const&, TagMap const&)
{
	M_RAISE("should not be used");
	return false;
}


void
DatabaseCodec::findTags(GameInfo const&, TagMap&) const
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::setWritable()
{
	M_RAISE("should not be used");
}


Move
DatabaseCodec::findExactPosition(GameInfo const&, Board const&, bool, BlockFileReader*)
{
	M_RAISE("should not be used");
	return Move();
}


bool
DatabaseCodec::usingAsyncReader() const
{
	return false;
}


BlockFileReader*
DatabaseCodec::getAsyncReader()
{
	return 0;
}


void
DatabaseCodec::closeAsyncReader(::util::BlockFileReader* reader)
{
	M_ASSERT(reader == 0);
}


void
DatabaseCodec::checkPermissions(mstl::string const& filename)
{
	M_ASSERT(isOpen());

	if (!isWritable() || !sys::file::access(filename, sys::file::Writeable))
	{
		m_db->m_readOnly = true;
		m_db->m_writable = false;
	}

	if (!sys::file::access(filename, sys::file::Readable))
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

	stream.open(sys::file::internalName(filename), mode);
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
		stream.open(sys::file::internalName(filename), mode | mstl::ios_base::trunc);

		if (!stream)
			IO_RAISE(Unspecified, Open_Failed, "cannot open file: %s", filename.c_str());

		if (!stream.write(magic.c_str(), magic.size()))
			IO_RAISE(Unspecified, Write_Failed, "unexpected write error: %s", filename.c_str());

		stream.exceptions(mstl::ios_base::badbit | mstl::ios_base::eofbit | mstl::ios_base::failbit);
	}
	else
	{
		stream.open(sys::file::internalName(filename), mode);

		if (!stream)
			IO_RAISE(Unspecified, Open_Failed, "cannot open file: %s", filename.c_str());

		char buf[magic.size()];

		if (!stream.read(buf, magic.size()))
			IO_RAISE(Unspecified, Open_Failed, "unexpected end of file: %s", filename.c_str());

		if (::memcmp(buf, magic.c_str(), magic.size()) != 0)
			IO_RAISE(Unspecified, Open_Failed, "bad magic: %s", filename.c_str());

		stream.exceptions(mstl::ios_base::badbit | mstl::ios_base::eofbit | mstl::ios_base::failbit);
	}
}


void
DatabaseCodec::rename(mstl::string const& oldName, mstl::string const& newName)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(util::misc::file::suffix(oldName) == util::misc::file::suffix(newName));
	M_REQUIRE(format() == format::Scidb || format() == format::Scid3 || format() == format::Scid4);

	mstl::string oldRoot(misc::file::rootname(oldName));
	mstl::string newRoot(misc::file::rootname(newName));

	StringList result;
	getSuffixes(newName, result);

	for (unsigned i = 0; i < result.size(); ++i)
	{
		mstl::string oldFile(oldRoot + "." + result[i]);
		mstl::string newFile(newRoot + "." + result[i]);

		if (sys::file::access(oldFile, sys::file::Existence))
			::sys::file::rename(oldFile, newFile, true);
	}
}


Time
DatabaseCodec::modified() const
{
	uint32_t time;
	sys::file::changed(m_db->m_rootname + "." + m_db->m_suffix, time);
	return Time(time);
}


util::crc::checksum_t
DatabaseCodec::computeChecksum(/*unsigned, */GameInfo const&, util::crc::checksum_t crc) const
{
	return crc == 0 ? 1 : crc;	// do not use zero!
}


void
DatabaseCodec::open(DatabaseContent* db, mstl::string const& encoding)
{
	M_REQUIRE(db);

	m_db = db;

	if (m_db->m_memoryOnly)
		doOpen(encoding);
	else
		doOpen(m_db->m_rootname, encoding);
}


void
DatabaseCodec::open(DatabaseContent* db, mstl::string const& encoding, util::Progress& progress)
{
	M_REQUIRE(db);

	m_db = db;
	doOpen(m_db->m_rootname, m_db->m_suffix, encoding, progress);
}


void
DatabaseCodec::open(	DatabaseContent* db,
							mstl::string const& encoding,
							Producer& producer,
							util::Progress& progress)
{
	M_REQUIRE(db);

	m_db = db;
	doOpen(encoding);
	importGames(producer, progress);
}


unsigned
DatabaseCodec::openProgressive(DatabaseContent* db, mstl::string const& encoding)
{
	M_REQUIRE(db);

	m_db = db;
	return doOpenProgressive(m_db->m_rootname, encoding);
}


void
DatabaseCodec::clear()
{
	M_REQUIRE(isOpen());

	if (m_db->m_memoryOnly)
	{
		close();
		doOpen(encoding());
	}
	else
	{
		doClear(m_db->m_rootname);
	}
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
DatabaseCodec::doEncoding(	util::ByteStream&,
									GameData const&,
									Signature const&,
									unsigned,
									TagBits const&,
									bool)
{
	M_RAISE("should not be used");
}


void
DatabaseCodec::sync()
{
	// no action
}


unsigned
DatabaseCodec::decodeGame(	::util::BlockFileReader* asyncReader,
									GameInfo const& info,
									uint16_t* line,
									unsigned length,
									Board& startBoard,
									bool useStartBoard)
{
	M_REQUIRE(isOpen());
	return doDecoding(asyncReader, info, line, length, startBoard, useStartBoard);
}


void
DatabaseCodec::decodeGame(GameData& data, GameInfo& info, unsigned gameIndex, mstl::string* encoding)
{
	M_REQUIRE(isOpen());
	doDecoding(data, info, gameIndex, encoding);
}


void
DatabaseCodec::encodeGame(	util::ByteStream& strm,
									GameData const& data,
									Signature const& signature,
									unsigned langFlags,
									TagBits const& allowedTags,
									bool allowExtraTags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!format::isChessBaseFormat(format()));

	doEncoding(strm, data, signature, langFlags, allowedTags, allowExtraTags);
}


save::State
DatabaseCodec::exportGame(Consumer& consumer, ByteStream& strm, TagSet& tags)
{
	return doDecoding(consumer, strm, tags);
}


save::State
DatabaseCodec::exportGame(Consumer& consumer, TagSet& tags, GameInfo const& info, unsigned gameIndex)
{
	return doDecoding(consumer, tags, info, gameIndex);
}


unsigned
DatabaseCodec::importGames(Producer& producer, Progress& progress, int startIndex)
{
	M_REQUIRE(isOpen());

	mstl::auto_ptr<Consumer> consumer(getConsumer(producer.format()));
	M_ASSERT(consumer);
	consumer->setupVariant(variant());
	producer.setConsumer(consumer.get());
	producer.consumer().setIndex(startIndex);
	return producer.process(progress);
}


save::State
DatabaseCodec::addGame(ByteStream& gameData, TagSet const& tags, Consumer& consumer)
{
	save::State state;

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

	return state;
}


save::State
DatabaseCodec::saveMoves(util::ByteStream const& gameData, Provider const& provider)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(provider.index() >= 0);

	GameInfo& info = m_db->m_gameInfoList[provider.index()];

	if (gameData.size() > maxGameRecordLength())
		return save::GameTooLong;
	if (provider.plyCount() > maxGameLength())
		return save::GameTooLong;

	unsigned gameOffset = putGame(gameData, info.gameOffset(), info.gameRecordLength());

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

	info.setup(gameOffset, gameData.size());

	if (!m_db->m_memoryOnly)
	{
		update(m_db->m_rootname, provider.index(), false);
		sync();
	}

	return save::Ok;
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

	GameInfo*	info = 0;
	unsigned		index;

	if (provider.index() >= 0)
	{
		index = provider.index();
		info = &m_db->m_gameInfoList[index];
		*m_storedInfo = *info;
		info->reset(m_db->m_namebases);
	}
	else if (m_db->size() == maxGameCount())
	{
		return save::TooManyGames;
	}
	else
	{
		index = m_db->m_gameInfoList.size();
	}

	unsigned maxAnnotatorCount	= this->maxAnnotatorCount();
	unsigned maxPlayerCount		= this->maxPlayerCount();

	InfoData data(tags);

	Player	whiteEntry;
	Player	blackEntry;
	Site		siteEntry;

	if (format::isScidFormat(provider.sourceFormat()) && !format::isScidFormat(format()))
	{
		mstl::string name;

		whiteEntry = namebase(Namebase::Player).insertPlayer(
							data.normalizeWhitePlayerName(tags.value(tag::White), name),
							data.whiteCountry,
							data.whiteTitle,
							data.whiteType,
							data.whiteSex,
							data.whiteFideID,
							maxPlayerCount);
		blackEntry = namebase(Namebase::Player).insertPlayer(
							data.normalizeBlackPlayerName(tags.value(tag::Black), name),
							data.blackCountry,
							data.blackTitle,
							data.blackType,
							data.blackSex,
							data.blackFideID,
							maxPlayerCount);
		siteEntry = namebase(Namebase::Site).insertSite(
							data.normalizeSiteName(tags.value(tag::Site), name),
							data.eventCountry,
							maxSiteCount());
	}
	else
	{
		whiteEntry	= namebase(Namebase::Player).insertPlayer(
								tags.value(tag::White),
								data.whiteCountry,
								data.whiteTitle,
								data.whiteType,
								data.whiteSex,
								data.whiteFideID,
								maxPlayerCount);
		blackEntry	= namebase(Namebase::Player).insertPlayer(
								tags.value(tag::Black),
								data.blackCountry,
								data.blackTitle,
								data.blackType,
								data.blackSex,
								data.blackFideID,
								maxPlayerCount);
		siteEntry	= namebase(Namebase::Site).insertSite(
								tags.value(tag::Site),
								data.eventCountry,
								maxSiteCount());
	}

	Event eventEntry = namebase(Namebase::Event).insertEvent(
								tags.value(tag::Event),
								data.eventDate,
								data.eventType,
								data.timeMode,
								data.eventMode,
								maxEventCount(),
								siteEntry ? siteEntry : namebase(Namebase::Site).emptySite());

	Entry annotatorEntry	= namebase(Namebase::Annotator).emptyAnnotator();

	if (maxAnnotatorCount)
	{
		annotatorEntry =
			namebase(Namebase::Annotator).insert(tags.value(tag::Annotator), maxAnnotatorCount);
	}

	save::State state = save::Ok;

	bool failed =		whiteEntry == 0
						|| blackEntry == 0
						|| eventEntry == 0
						|| siteEntry == 0
						|| annotatorEntry == 0;

	if (!failed && format() != format::Scidb)
	{
		M_ASSERT(isScidFormat(format()));
		M_ASSERT(!m_db->m_memoryOnly);
		M_ASSERT(maxAnnotatorCount == 0);

		if (!info)
		{
			if (!static_cast<si3::Codec*>(this)->saveRoundEntry(index, tags.value(tag::Round)))
			{
				static_cast<si3::Codec*>(this)->useOverflowEntry(index);
				state = save::TooManyRoundNames;
			}
		}
		else if (static_cast<si3::Codec*>(this)->getRoundEntry(index) != tags.value(tag::Round))
		{
			static_cast<si3::Codec*>(this)->releaseRoundEntry(index);

			if (!static_cast<si3::Codec*>(this)->saveRoundEntry(index, tags.value(tag::Round)))
			{
				static_cast<si3::Codec*>(this)->useOverflowEntry(index);
				state = save::TooManyRoundNames;
			}
		}
	}

	unsigned gameOffset = 0; // shut up compiler

	if (!failed)
	{
		if (info)
			gameOffset = putGame(gameData, info->gameOffset(), info->gameRecordLength());
		else
			gameOffset = putGame(gameData);
	}

	if (failed || int(gameOffset) < 0)
	{
		if (info)
			info->restore(*m_storedInfo, m_db->m_namebases);

		if (format() != format::Scidb)
		{
			M_ASSERT(!m_db->m_memoryOnly);
			static_cast<si3::Codec*>(this)->restoreRoundEntry(index);
		}

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

		if (!whiteEntry)	return save::TooManyPlayerNames;
		if (!blackEntry)	return save::TooManyPlayerNames;
		if (!eventEntry)	return save::TooManyEventNames;
		if (!siteEntry)	return save::TooManySiteNames;

		return save::TooManyAnnotatorNames;
	}

	if (info == 0)
		info = &m_db->m_gameInfoList.push_back();

	info->setup(gameOffset,
					gameData.size(),
					whiteEntry,
					blackEntry,
					eventEntry,
					annotatorEntry,
					data.whiteElo,
					data.blackElo,
					tags,
					provider,
					m_db->m_namebases);

	return state;
}


save::State
DatabaseCodec::addGame(ByteStream const& gameData, GameInfo const& info, Allocation allocation)
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

	if (allocation == Alloc)
	{
		namebase(Namebase::Player).copy(whitePlayer, info.playerName(color::White));
		namebase(Namebase::Player).copy(blackPlayer, info.playerName(color::Black));
		namebase(Namebase::Event).copy(event, info.event());
		namebase(Namebase::Site).copy(site, info.site());
		namebase(Namebase::Annotator).copy(annotator, info.annotator());
	}
	else
	{
		whitePlayer.hook(info.playerName(color::White));
		blackPlayer.hook(info.playerName(color::Black));
		event.hook(info.event());
		site.hook(info.site());
		annotator.hook(info.annotator());
	}

	unsigned maxAnnotatorCount = this->maxAnnotatorCount();

	NamebasePlayer*	whiteEntry;
	NamebasePlayer*	blackEntry;
	NamebaseSite*		siteEntry;
	NamebaseEvent*		eventEntry;
	NamebaseEntry*		annotatorEntry	= namebase(Namebase::Annotator).emptyAnnotator();

	unsigned maxPlayerCount = this->maxPlayerCount();

	whiteEntry = namebase(Namebase::Player).insertPlayer(
							whitePlayer,
							info.federation(color::White),
							info.title(color::White),
							info.playerType(color::White),
							info.sex(color::White),
							info.fideID(color::White),
							maxPlayerCount);
	blackEntry = namebase(Namebase::Player).insertPlayer(
							blackPlayer,
							info.federation(color::Black),
							info.title(color::Black),
							info.playerType(color::Black),
							info.sex(color::Black),
							info.fideID(color::Black),
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
							siteEntry ? siteEntry : namebase(Namebase::Site).emptySite());

	if (maxAnnotatorCount)
		annotatorEntry = namebase(Namebase::Annotator).insert(annotator, maxAnnotatorCount);

	bool failed =		whiteEntry == 0
						|| blackEntry == 0
						|| eventEntry == 0
						|| siteEntry == 0
						|| annotatorEntry == 0;

	save::State state = save::Ok;

	if (!failed && format() != format::Scidb)
	{
		M_ASSERT(format() == format::Scid3 || format() == format::Scid4);
		M_ASSERT(!m_db->m_memoryOnly);

		if (!static_cast<si3::Codec*>(this)->saveRoundEntry(	m_db->m_gameInfoList.size(),
																				info.roundAsString()))
		{
			static_cast<si3::Codec*>(this)->useOverflowEntry(m_db->m_gameInfoList.size());
			state = save::TooManyRoundNames;
		}
	}

	unsigned gameOffset = 0; // shut up compiler

	if (failed || int(gameOffset = putGame(gameData)) < 0)
	{
		if (format() != format::Scidb)
		{
			M_ASSERT(!m_db->m_memoryOnly);
			static_cast<si3::Codec*>(this)->restoreRoundEntry(m_db->m_gameInfoList.size());
		}

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

		if (!whiteEntry)	return save::TooManyPlayerNames;
		if (!blackEntry)	return save::TooManyPlayerNames;
		if (!eventEntry)	return save::TooManyEventNames;
		if (!siteEntry)	return save::TooManySiteNames;

		return save::TooManyAnnotatorNames;
	}

	whiteEntry->copyRating(*info.playerEntry(color::White));
	blackEntry->copyRating(*info.playerEntry(color::Black));

	m_db->m_gameInfoList.push_back(info);
	m_db->m_gameInfoList.back().setup(
		gameOffset,
		gameData.size(),
		whiteEntry,
		blackEntry,
		eventEntry,
		annotatorEntry,
		m_db->m_namebases);

	return state;
}


save::State
DatabaseCodec::updateCharacteristics(unsigned index, TagSet const& tags)
{
	M_REQUIRE(isOpen());

	typedef Namebase::PlayerEntry*	Player;
	typedef Namebase::EventEntry*		Event;
	typedef Namebase::SiteEntry*		Site;
	typedef Namebase::Entry*			Entry;

	GameInfo& info = m_db->m_gameInfoList[index];
	*m_storedInfo = info;
	info.resetCharacteristics(m_db->m_namebases);

	unsigned maxAnnotatorCount	= this->maxAnnotatorCount();
	unsigned maxPlayerCount		= this->maxPlayerCount();

	InfoData data(tags);

	Player	whiteEntry		= namebase(Namebase::Player).insertPlayer(
										tags.value(tag::White),
										data.whiteCountry,
										data.whiteTitle,
										data.whiteType,
										data.whiteSex,
										data.whiteFideID,
										maxPlayerCount);
	Player	blackEntry		= namebase(Namebase::Player).insertPlayer(
										tags.value(tag::Black),
										data.blackCountry,
										data.blackTitle,
										data.blackType,
										data.blackSex,
										data.blackFideID,
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
										siteEntry ? siteEntry : namebase(Namebase::Site).emptySite());
	Entry		annotatorEntry	= namebase(Namebase::Annotator).emptyAnnotator();

	if (maxAnnotatorCount)
	{
		annotatorEntry = namebase(Namebase::Annotator).
									insert(tags.value(tag::Annotator), maxAnnotatorCount);
	}

	bool failed = 		whiteEntry == 0
						|| blackEntry == 0
						|| eventEntry == 0
						|| siteEntry == 0
						|| annotatorEntry == 0;

	save::State state = save::Ok;

	if (!failed && format() != format::Scidb)
	{
		M_ASSERT(format() == format::Scid3 || format() == format::Scid4);
		M_ASSERT(!m_db->m_memoryOnly);

		if (static_cast<si3::Codec*>(this)->getRoundEntry(index) != tags.value(tag::Round))
		{
			static_cast<si3::Codec*>(this)->releaseRoundEntry(index);

			if (!static_cast<si3::Codec*>(this)->saveRoundEntry(index, tags.value(tag::Round)))
			{
				static_cast<si3::Codec*>(this)->useOverflowEntry(index);
				state = save::TooManyRoundNames;
			}
		}
	}

	if (failed)
	{
		info.restore(*m_storedInfo, m_db->m_namebases);

		if (format() != format::Scidb)
		{
			M_ASSERT(!m_db->m_memoryOnly);
			static_cast<si3::Codec*>(this)->restoreRoundEntry(index);
		}

		namebases().update();

		if (!whiteEntry)	return save::TooManyPlayerNames;
		if (!blackEntry)	return save::TooManyPlayerNames;
		if (!eventEntry)	return save::TooManyEventNames;
		if (!siteEntry)	return save::TooManySiteNames;

		return save::TooManyAnnotatorNames;
	}

	info.update(whiteEntry,
					blackEntry,
					eventEntry,
					annotatorEntry,
					tags,
					m_db->m_namebases);

	return state;
}

// vi:set ts=3 sw=3:
