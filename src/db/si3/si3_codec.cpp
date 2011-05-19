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

#include "si3_codec.h"
#include "si3_stored_line.h"
#include "si3_name_list.h"
#include "si3_decoder.h"
#include "si3_encoder.h"
#include "si3_consumer.h"
#include "si3_common.h"

#include "db_game_data.h"
#include "db_game_info.h"
#include "db_producer.h"
#include "db_eco_table.h"
#include "db_pgn_reader.h"
#include "db_eco_table.h"
#include "db_exception.h"

#include "u_byte_stream.h"
#include "u_block_file.h"
#include "u_progress.h"
#include "u_crc.h"

#include "sys_time.h"
#include "sys_file.h"
#include "sys_utf8_codec.h"

#include "m_fstream.h"
#include "m_utility.h"
#include "m_assert.h"
#include "m_static_check.h"

#include "m_stdio.h"

#include <string.h>

using namespace db;
using namespace db::si3;
using namespace util;


typedef ByteStream::uint24_t uint24_t;


static unsigned const MaxIndexEntrySize	= 47;
static unsigned const MaxIndexHeaderSize	= 174;
static unsigned const MaxFrequency			= 0xffffff;
static unsigned const MaxRoundCount			= (1 << 18) - 1;

static mstl::string const MagicIndexFile("Scid.si\0", 8);
static mstl::string const MagicGameFile("Scid.sg\0", 8);
static mstl::string const MagicNamebase("Scid.sn\0", 8);
static mstl::string const Ext3("si3");
static mstl::string const Ext4("si4");


inline
static void
swapByte(unsigned char& c)
{
	c = ((c & 0x0f) << 4) | ((c & 0xf0) >> 4);
}


static void
swapHomePawnBytes(unsigned char* data)
{
	swapByte(data[0]);
	swapByte(data[1]);
	swapByte(data[2]);
	swapByte(data[3]);
	swapByte(data[4]);
	swapByte(data[5]);
	swapByte(data[6]);
	swapByte(data[7]);
}


template <typename T>
static inline T*
check(T* p)
{
	if (!p)
		IO_RAISE(Index, Corrupted, "pointer is null");
	return p;
}


static void
checkNamebase(unsigned maxFrequency, char const* msg)
{
	if (maxFrequency > MaxFrequency)
		IO_RAISE(Namebase, Encoding_Failed, msg);
}


static unsigned
prefix(char const* s, char const* t)
{
	unsigned count = 0;

	for ( ; *s == *t; ++s, ++t, ++count)
		M_ASSERT(*s);

	return count;
}


static void
writeFrequency(ByteStream& bstrm, unsigned freq, unsigned maxFreq)
{
	M_ASSERT(freq <= ::MaxFrequency);
	M_ASSERT(freq <= maxFreq);

	if (maxFreq < 256)
		bstrm << uint8_t(freq);
	else if (maxFreq < 65536)
		bstrm << uint16_t(freq);
	else
		bstrm << uint24_t(freq);
}


static void
writeId(ByteStream& bstrm, unsigned id, unsigned maxId)
{
	if (maxId >= 65536)
		bstrm << uint24_t(id);
	else
		bstrm << uint16_t(id);
}


struct Codec::ByteIStream : public ByteStream
{
	ByteIStream(mstl::fstream& strm);
	void underflow(unsigned size);
	mstl::istream& m_strm;
};


Codec::ByteIStream::ByteIStream(mstl::fstream& strm)
	:ByteStream(strm.bufsize())
	,m_strm(strm)
{
	skip(strm.bufsize());	// force underflow()
}


void
Codec::ByteIStream::underflow(unsigned size)
{
	M_ASSERT(size <= capacity());

	unsigned remaining = this->remaining();
	::memmove(m_base, m_getp, remaining);
	m_getp = m_base + remaining;
	m_endp = m_getp + m_strm.readsome(reinterpret_cast<char*>(m_getp), capacity() - remaining);
	m_getp -= remaining;

	if (__builtin_expect(m_getp >= m_endp, 0))
		IO_RAISE(Namebase, Corrupted, "unexpected end of stream");
}


struct Codec::ByteOStream : public ByteStream
{
	ByteOStream(mstl::ostream& strm, unsigned char* buf, unsigned size);
	void overflow(unsigned size);
	void flush();
	mstl::ostream& m_strm;
};


Codec::ByteOStream::ByteOStream(mstl::ostream& strm, unsigned char* buf, unsigned size)
	:ByteStream(buf, size)
	,m_strm(strm)
{
}


void
Codec::ByteOStream::overflow(unsigned size)
{
	if (__builtin_expect(!m_strm.write(m_base, m_putp - m_base), 0))
		IO_RAISE(Namebase, Write_Failed, "write failed");

	m_putp = m_base;
}


void
Codec::ByteOStream::flush()
{
	if (__builtin_expect(!m_strm.write(m_base, m_putp - m_base), 0))
		IO_RAISE(Namebase, Write_Failed, "write failed");

	m_putp = m_base;
}


Codec::Codec(CustomFlags* customFlags)
	:m_headerSize(customFlags ? 174 : 120)	// w/o magic
	,m_indexEntrySize(customFlags ? 47 : 46)
	,m_fileVersion(customFlags ? 400 : 300)
	,m_autoLoad(0)
	,m_extIndex(customFlags ? ".si4" : ".si3")
	,m_extGame(customFlags ? ".sg4" : ".sg3")
	,m_extNamebase(customFlags ? ".sn4" : ".sn3")
	,m_blockSize(customFlags ? 131072 : 32768)
	,m_codec(0)
	,m_customFlags(customFlags)
	,m_gameData(0)
	,m_asyncReader(0)
	,m_hasMagic(false)
	,m_playerList(0)
	,m_eventList(0)
	,m_siteList(0)
	,m_roundList(0)
	,m_roundEntry(0)
{
	M_ASSERT(m_indexEntrySize <= MaxIndexEntrySize);

	m_magicGameFile = MagicGameFile;
	m_magicGameFile.resize(MagicGameFile.size() + 2);

	ByteStream strm(m_magicGameFile.data(), m_magicGameFile.size());
	strm.advance(MagicGameFile.size());
	strm << uint16_t(m_fileVersion);

	StoredLine::initialize();
}


Codec::~Codec() throw()
{
	if (m_asyncReader)
		m_gameData->closeAsyncReader(m_asyncReader);

	delete m_gameData;
	delete m_codec;
	delete m_playerList;
	delete m_eventList;
	delete m_siteList;
	delete m_roundList;
}


unsigned Codec::maxGameRecordLength() const	{ return m_blockSize - 1; }
unsigned Codec::maxGameLength() const			{ return (1 << 10) - 1; }
unsigned Codec::maxGameCount() const			{ return 16000000; }
unsigned Codec::maxPlayerCount() const			{ return (1 << 20) - 1; }
unsigned Codec::maxEventCount() const			{ return (1 << 19) - 1; }
unsigned Codec::maxSiteCount() const			{ return (1 << 19) - 1; }
unsigned Codec::maxAnnotatorCount() const		{ return 0; }
unsigned Codec::minYear() const					{ return Date::MinYear; }
unsigned Codec::maxYear() const					{ return mstl::min(uint16_t(2047), Date::MaxYear); }
unsigned Codec::maxDescriptionLength() const	{ return 107; }
mstl::string const& Codec::extension() const	{ return m_customFlags ? Ext4 : Ext3; }


unsigned
Codec::gameFlags() const
{
	enum
	{
		Flags =		GameInfo::Flag_White_Opening
					 | GameInfo::Flag_Black_Opening
					 | GameInfo::Flag_Middle_Game
					 | GameInfo::Flag_End_Game
					 | GameInfo::Flag_Novelty
					 | GameInfo::Flag_Pawn_Structure
					 | GameInfo::Flag_Tactics
					 | GameInfo::Flag_King_Side
					 | GameInfo::Flag_Queen_Side
					 | GameInfo::Flag_Brilliancy
					 | GameInfo::Flag_Blunder
					 | GameInfo::Flag_User,

		UserFlags =	GameInfo::Flag_User1
					 | GameInfo::Flag_User2
					 | GameInfo::Flag_User3
					 | GameInfo::Flag_User4
					 | GameInfo::Flag_User5
					 | GameInfo::Flag_User6
	};

	return m_customFlags ? Flags | UserFlags : Flags;
}


Codec::Format
Codec::format() const
{
	return m_customFlags ? format::Scid4 : format::Scid3;
}


bool
Codec::encodingFailed() const
{
	M_ASSERT(m_codec);
	return m_codec->failed();
}


mstl::string const&
Codec::encoding() const
{
	M_ASSERT(m_codec);
	return m_codec->encoding();
}


void
Codec::filterTag(TagSet& tags, tag::ID tag) const
{
	if (tag == tag::EventDate)
	{
		unsigned dy = Date(tags.value(tag::Date)).year();
		unsigned ey = Date(tags.value(tag::EventDate)).year();

		if (mstl::abs(dy - ey) > 3)
			tags.remove(tag::EventDate);
	}
	else if (!Encoder::skipTag(tag))
	{
		tags.remove(tag);
	}
}


BlockFile*
Codec::newBlockFile() const
{
	return new BlockFile(m_blockSize, BlockFile::RequireLength);
}


void
Codec::reset()
{
	M_ASSERT(m_codec);
	return m_codec->reset();
}


void
Codec::setEncoding(mstl::string const& encoding)
{
	delete m_codec;
	m_codec = new sys::utf8::Codec(encoding);
}


void
Codec::close()
{
	m_gameData->close();
}


util::ByteStream
Codec::getGame(GameInfo const& info)
{
	M_ASSERT(m_gameData);

	ByteStream src;
	getGameRecord(info, m_gameData->reader(), src);
	return src;
}


unsigned
Codec::putGame(ByteStream const& strm)
{
	M_ASSERT(m_gameData);
	return m_gameData->put(strm);
}


save::State
Codec::doDecoding(db::Consumer& consumer, unsigned flags, TagSet& tags, GameInfo const& info)
{
	ByteStream strm;
	getGameRecord(info, m_gameData->reader(), strm);
	Decoder decoder(strm, *m_codec);
	return decoder.doDecoding(consumer, flags, tags);
}


save::State
Codec::doDecoding(db::Consumer& consumer, ByteStream& strm, unsigned flags, TagSet& tags)
{
	Decoder decoder(strm, *m_codec);
	return decoder.doDecoding(consumer, flags, tags);
}


void
Codec::doDecoding(unsigned flags, GameData& data, GameInfo& info)
{
	ByteStream strm;
	getGameRecord(info, m_gameData->reader(), strm);

	Decoder decoder(strm, *m_codec);

	M_ASSERT(strm.size() == info.gameRecordLength());

	data.m_crc = crc::compute(0, strm.data(), strm.size());
	info.m_plyCount = mstl::min(GameInfo::MaxPlyCount, decoder.doDecoding(flags, data));

	if (data.m_tags.contains(tag::EventDate) && !info.m_event->hasDate())
		info.m_event->setDate(Date(data.m_tags.value(tag::EventDate)));

	if (data.m_tags.contains(tag::Termination) && info.terminationReason() == termination::Unknown)
		info.m_termination = termination::fromString(data.m_tags.value(tag::Termination));

	if (data.m_tags.contains(tag::EventType) && info.m_event->type() == event::Unknown)
	{
		mstl::string const& value = data.m_tags.value(tag::EventType);

		event::Type eventType = event::typeFromString(value);

		if (eventType != event::Unknown)
		{
			info.m_event->setType(eventType);
		}
		else if (info.m_event->timeMode() == time::Unknown)
		{
			time::Mode timeMode = time::fromString(value);

			if (timeMode == time::Unknown && value.back() == ')')
			{
				char const* s = ::strchr(value, '(');

				if (s)
				{
					mstl::string str(s + 1, value.end() - 2);
					timeMode = time::fromString(str);
				}
			}

			info.m_event->setTimeMode(timeMode);
		}
	}

	if (data.m_tags.contains(tag::TimeControl) && info.m_event->timeMode() == time::Unknown)
	{
		info.m_event->setTimeMode(
				PgnReader::getTimeModeFromTimeControl(data.m_tags.value(tag::TimeControl)));
	}

	if (data.m_tags.contains(tag::Mode))
	{
		event::Mode eventMode = event::modeFromString(data.m_tags.value(tag::Mode));

		if (info.m_event->eventMode() == event::Undetermined)
			info.m_event->setEventMode(eventMode);

		if (info.m_event->timeMode() == time::Unknown)
		{
			switch (int(eventMode))
			{
				case event::PaperMail:
				case event::Email:
					info.m_event->setTimeMode(time::Corr);
					break;
			}
		}
	}
}


void
Codec::doOpen(mstl::string const& encoding)
{
	M_ASSERT(m_codec == 0 || encoding == m_codec->encoding());
	M_ASSERT(m_gameData == 0);

	m_codec = new sys::utf8::Codec(encoding);
	M_ASSERT(m_codec->hasEncoding());
	m_gameData = new BlockFile(m_blockSize, BlockFile::RequireLength, m_magicGameFile);
	m_hasMagic = true;
}


void
Codec::doOpen(mstl::string const& rootname, mstl::string const& encoding, Progress& progress)
{
	M_ASSERT(m_codec == 0);
	M_ASSERT(m_gameData == 0);

	char buf[8];

	m_codec = new sys::utf8::Codec(encoding);
	M_ASSERT(m_codec->hasEncoding());

	mstl::string indexFilename(rootname + m_extIndex);
	mstl::string gameFilename(rootname + m_extGame);
	mstl::string namebaseFilename(rootname + m_extNamebase);

	checkPermissions(gameFilename);
	checkPermissions(indexFilename);
	checkPermissions(namebaseFilename);

	mstl::fstream indexStream;
	mstl::fstream namebaseStream;

	m_gameStream.set_unbuffered();

	openFile(m_gameStream, gameFilename);
	openFile(namebaseStream, namebaseFilename, MagicNamebase);
	openFile(indexStream, indexFilename, MagicIndexFile);

	if (m_gameStream.size() >= 8 && m_gameStream.read(buf, 8) && ::memcmp(buf, MagicGameFile, 8) == 0)
		m_hasMagic = true;

	readNamebase(namebaseStream, progress);
	readIndex(indexStream, progress);

	// NOTE: we cannot trust the maximal frequency, Scid's value is possibly faulty.
	namebase(Namebase::Player   ).update();
	namebase(Namebase::Site     ).update();
	namebase(Namebase::Event    ).update();
	namebase(Namebase::Annotator).update();
	namebase(Namebase::Round    ).update();

	if (m_hasMagic)
		m_gameData = new BlockFile(&m_gameStream, m_blockSize, BlockFile::RequireLength, m_magicGameFile);
	else
		m_gameData = new BlockFile(&m_gameStream, m_blockSize, BlockFile::RequireLength);
}


void
Codec::doOpen(mstl::string const& rootname, mstl::string const& encoding)
{
	M_ASSERT(m_codec == 0);
	M_ASSERT(m_gameData == 0);

	m_codec = new sys::utf8::Codec(encoding);
	M_ASSERT(m_codec->hasEncoding());

	mstl::string indexFilename(rootname + m_extIndex);
	mstl::string gameFilename(rootname + m_extGame);
	mstl::string namebaseFilename(rootname + m_extNamebase);

	mstl::fstream indexStream;
	mstl::fstream namebaseStream;

	m_gameStream.set_unbuffered();

	openFile(m_gameStream, gameFilename, Truncate);
	openFile(indexStream, indexFilename, MagicIndexFile, Truncate);
	openFile(namebaseStream, namebaseFilename, MagicNamebase, Truncate);

	m_gameData = new BlockFile(&m_gameStream, m_blockSize, BlockFile::RequireLength, m_magicGameFile);
	m_gameData->sync();
	m_hasMagic = true;

	try
	{
		writeNamebase(namebaseStream);
		writeIndexHeader(indexStream);
	}
	catch (...)
	{
		delete m_playerList;
		delete m_eventList;
		delete m_siteList;
		delete m_roundList;

		m_playerList = m_eventList = m_siteList = m_roundList = 0;
		throw;
	}

	delete m_playerList;
	delete m_eventList;
	delete m_siteList;
	delete m_roundList;

	m_playerList = m_eventList = m_siteList = m_roundList = 0;
}


void
Codec::doClear(mstl::string const& rootname)
{
	M_ASSERT(m_codec);
	M_ASSERT(m_gameData);

	mstl::string indexFilename(rootname + m_extIndex);
	mstl::string gameFilename(rootname + m_extGame);
	mstl::string namebaseFilename(rootname + m_extNamebase);

	mstl::fstream indexStream;
	mstl::fstream namebaseStream;

	openFile(m_gameStream, gameFilename, Truncate);
	openFile(indexStream, indexFilename, MagicIndexFile, Truncate);
	openFile(namebaseStream, namebaseFilename, MagicNamebase, Truncate);

	m_gameData->close();
	delete m_gameData;
	m_gameData = new BlockFile(&m_gameStream, m_blockSize, BlockFile::RequireLength, m_magicGameFile);
	m_hasMagic = true;

	try
	{
		writeNamebase(namebaseStream);
		writeIndexHeader(indexStream);
	}
	catch (...)
	{
		delete m_playerList;
		delete m_eventList;
		delete m_siteList;
		delete m_roundList;

		m_playerList = m_eventList = m_siteList = m_roundList = 0;
		throw;
	}

	delete m_playerList;
	delete m_eventList;
	delete m_siteList;
	delete m_roundList;

	m_playerList = m_eventList = m_siteList = m_roundList = 0;
}


void
Codec::save(mstl::string const& rootname, unsigned start, Progress& progress, bool attach)
{
	if (!(m_gameStream.mode() & mstl::ios_base::out))
		IO_RAISE(Game, Read_Only, "game file '%s' is read-only", (rootname + m_extGame).c_str());

	mstl::string indexFilename(rootname + m_extIndex);
	if (!attach)
		checkPermissions(indexFilename);

	if (isReadOnly())
		IO_RAISE(Index, Read_Only, "index file '%s' is read-only", indexFilename.c_str());

	mstl::string namebaseFilename(rootname + m_extNamebase);
	if (!attach)
		checkPermissions(namebaseFilename);

	if (isReadOnly())
		IO_RAISE(Namebase, Read_Only, "name-base file '%s' is read-only", namebaseFilename.c_str());

	mstl::fstream	indexStream;
	mstl::fstream	namebaseStream;
	mstl::string	namebaseTempFilename(namebaseFilename + ".temp.38583276");

	m_gameData->sync();
	openFile(indexStream, indexFilename, MagicIndexFile, attach ? Truncate : 0);
	openFile(namebaseStream, namebaseTempFilename, MagicNamebase, Truncate);

	try
	{
		writeNamebase(namebaseStream);
		sys::file::rename(namebaseTempFilename, namebaseFilename);
		writeIndex(indexStream, start, progress);
	}
	catch (...)
	{
		delete m_playerList;
		delete m_eventList;
		delete m_siteList;
		delete m_roundList;

		sys::file::deleteIt(namebaseTempFilename);
		m_playerList = m_eventList = m_siteList = m_roundList = 0;
		throw;
	}

	delete m_playerList;
	delete m_eventList;
	delete m_siteList;
	delete m_roundList;

	m_playerList = m_eventList = m_siteList = m_roundList = 0;
}


void
Codec::save(mstl::string const& rootname, unsigned start, util::Progress& progress)
{
	save(rootname, start, progress, false);
}


void
Codec::attach(mstl::string const& rootname, util::Progress& progress)
{
	static mstl::ios_base::openmode mode =
		mstl::ios_base::in | mstl::ios_base::out | mstl::ios_base::trunc | mstl::ios_base::binary;

	mstl::string gameFilename(rootname + m_extGame);
	m_gameStream.set_unbuffered();
	m_gameStream.open(gameFilename, mode);
	m_gameData->attach(&m_gameStream);
	save(rootname, 0, progress, true);
}


void
Codec::update(mstl::string const& rootname)
{
	if (!(m_gameStream.mode() & mstl::ios_base::out))
		IO_RAISE(Game, Read_Only, "game file '%s' is read-only", (rootname + ".gi3").c_str());

	mstl::string indexFilename(rootname + m_extIndex);
	checkPermissions(indexFilename);

	if (isReadOnly())
		IO_RAISE(Index, Read_Only, "index file '%s' is read-only", indexFilename.c_str());

	mstl::string namebaseFilename(rootname + m_extNamebase);
	checkPermissions(namebaseFilename);

	if (isReadOnly())
		IO_RAISE(Namebase, Read_Only, "name-base file '%s' is read-only", namebaseFilename.c_str());

	mstl::fstream	indexStream;
	mstl::fstream	namebaseStream;
	mstl::string	namebaseTempFilename(namebaseFilename + ".temp.38583276");

	m_gameData->sync();
	indexStream.open(indexFilename, mstl::ios_base::in | mstl::ios_base::out | mstl::ios_base::binary);
	openFile(namebaseStream, namebaseTempFilename, MagicNamebase, Truncate);

	try
	{
		writeNamebase(namebaseStream);
		sys::file::rename(namebaseTempFilename, namebaseFilename);
		updateIndex(indexStream);
	}
	catch (...)
	{
		delete m_playerList;
		delete m_eventList;
		delete m_siteList;
		delete m_roundList;

		sys::file::deleteIt(namebaseTempFilename);
		m_playerList = m_eventList = m_siteList = m_roundList = 0;
		throw;
	}

	delete m_playerList;
	delete m_eventList;
	delete m_siteList;
	delete m_roundList;

	m_playerList = m_eventList = m_siteList = m_roundList = 0;
}


void
Codec::update(mstl::string const& rootname, unsigned index, bool updateNamebase)
{
	if (!(m_gameStream.mode() & mstl::ios_base::out))
		IO_RAISE(Game, Read_Only, "game file '%s' is read-only", (rootname + m_extGame).c_str());

	mstl::string indexFilename(rootname + m_extIndex);
	checkPermissions(indexFilename);

	if (isReadOnly())
		IO_RAISE(Index, Read_Only, "index file '%s' is read-only", indexFilename.c_str());

	mstl::fstream indexStream;

	m_gameData->sync();
	indexStream.open(indexFilename, mstl::ios_base::in | mstl::ios_base::out | mstl::ios_base::binary);

	if (updateNamebase)
	{
		mstl::fstream namebaseStream;
		mstl::string namebaseFilename(rootname + m_extNamebase);

		mstl::string namebaseTempFilename(namebaseFilename + ".temp.38583276");

		try
		{
			mstl::fstream namebaseStream;
			checkPermissions(namebaseFilename);
			openFile(namebaseStream, namebaseTempFilename, MagicNamebase, Truncate);
			writeNamebase(namebaseStream);
			sys::file::rename(namebaseTempFilename, namebaseFilename);
		}
		catch (...)
		{
			sys::file::deleteIt(namebaseTempFilename);
			throw;
		}
	}

	GameInfo* info = gameInfoList()[index];

	unsigned char buf[m_indexEntrySize];

	ByteStream bstrm(buf, m_indexEntrySize);
	encodeIndex(*info, index, bstrm);

	if (!indexStream.seekp(index*m_indexEntrySize + m_headerSize + 8))
		IO_RAISE(Index, Corrupted, "unexpected end of index file");
	if (!indexStream.write(buf, m_indexEntrySize))
		IO_RAISE(Index, Write_Failed, "error while writing index entry");

	info->setDirty(false);
}


void
Codec::updateHeader(mstl::string const& rootname)
{
	mstl::string indexFilename(rootname + m_extIndex);
	checkPermissions(indexFilename);

	if (isReadOnly())
		IO_RAISE(Index, Read_Only, "index file '%s' is read-only", indexFilename.c_str());

	mstl::fstream indexStream;
	indexStream.open(indexFilename, mstl::ios_base::in | mstl::ios_base::out | mstl::ios_base::binary);
	writeIndexHeader(indexStream);
}


void
Codec::writeIndexHeader(mstl::fstream& fstrm)
{
	// write header (w/o magic)
	unsigned char header[MaxIndexHeaderSize];
	ByteStream strm(header, m_headerSize);

	::memset(header, 0, m_headerSize);
	if (m_customFlags)
		::memcpy(header + 120, m_customFlags, sizeof(CustomFlags));

	unsigned autoLoad = m_autoLoad;

	if (autoLoad == 0 || autoLoad > gameInfoList().size() + 1)
		autoLoad = gameInfoList().empty() ? 1 : 2;

	strm << uint16_t(m_fileVersion);						// Scid version
	strm << uint32_t(Encoder::encodeType(type()));	// base type
	strm << uint24_t(gameInfoList().size());			// number of games
	strm << uint24_t(autoLoad);							// auto load
	strm.put(description(), mstl::min(description().size(), 119 - strm.tellp()));

	if (!fstrm.seekp(8, mstl::ios_base::beg))	// skip magic
		IO_RAISE(Index, Corrupted, "unexpected end of index file");

	if (!fstrm.write(header, m_headerSize))
		IO_RAISE(Index, Write_Failed, "error while writing index entry");
}


void
Codec::writeIndex(mstl::fstream& fstrm, unsigned start, util::Progress& progress)
{
	writeIndexHeader(fstrm);

	if (start > 0 && !fstrm.seekp(start*m_indexEntrySize, mstl::ios_base::cur))
		IO_RAISE(Index, Corrupted, "cannot seek to end of index file");

	GameInfoList& infoList = gameInfoList();

	unsigned frequency	= progress.frequency(infoList.size(), 100000);
	unsigned reportAfter	= frequency + start;

	ProgressWatcher watcher(progress, infoList.size());

	for (unsigned i = start; i < infoList.size(); ++i)
	{
		if (reportAfter == i)
		{
			progress.update(i);
			reportAfter += frequency;
		}

		char buf[MaxIndexEntrySize];

		ByteStream bstrm(buf, m_indexEntrySize);
		encodeIndex(*infoList[i], i, bstrm);

		if (__builtin_expect(!fstrm.write(buf, m_indexEntrySize), 0))
			IO_RAISE(Index, Write_Failed, "error while writing index entry");
	}
}


void
Codec::updateIndex(mstl::fstream& fstrm)
{
	// update header
	{
		if (!fstrm.seekp(14))
			IO_RAISE(Index, Corrupted, "unexpected end of file");

		unsigned char buf[6];
		ByteStream strm(buf, sizeof(buf));

		strm << uint24_t(gameInfoList().size());				// number of games
		strm << uint24_t(gameInfoList().empty() ? 1 : 2);	// auto load

		if (!fstrm.write(buf, sizeof(buf)))
			IO_RAISE(Index, Write_Failed, "error while writing index entry");
	}

	GameInfoList& infoList = gameInfoList();

	for (unsigned i = 0; i < infoList.size(); ++i)
	{
		if (infoList[i]->isDirty())
		{
			unsigned char buf[MaxIndexEntrySize];

			ByteStream bstrm(buf, m_indexEntrySize);
			encodeIndex(*infoList[i], i, bstrm);

			if (!fstrm.seekp(i*m_indexEntrySize + (m_headerSize + 8)))
				IO_RAISE(Index, Corrupted, "unexpected end of file");
			if (!fstrm.write(buf, m_indexEntrySize))
				IO_RAISE(Index, Write_Failed, "error while writing index entry");
		}
	}
}


void
Codec::encodeIndex(GameInfo const& item, unsigned index, ByteStream& buf)
{
	M_ASSERT(item.gameRecordLength() <= maxGameRecordLength());
	M_ASSERT(m_playerList);
	M_ASSERT(m_eventList);
	M_ASSERT(m_siteList);
	M_ASSERT(m_roundList);

	M_STATIC_CHECK(GameInfo::Flag_Deleted == 1 <<  0, Flags_Have_Changed);
	M_STATIC_CHECK(GameInfo::Flag_User1   == 1 << 13, Flags_Have_Changed);
	M_STATIC_CHECK(GameInfo::Flag_User6   == 1 << 18, Flags_Have_Changed);

	char buffer[10] = { '?', '\0' };
	mstl::string round;

	if (item.m_subround)
		round.hook(buffer, ::sprintf(buffer, "%u.%u", unsigned(item.m_round), unsigned(item.m_subround)));
	else if (item.m_round)
		round.hook(buffer, ::sprintf(buffer, "%u", unsigned(item.m_round)));
	else
		round.hook(buffer, 1);

	uint16_t flags = (item.m_gameFlags & ((1 << 13) - 1)) << 3;

	if (!item.hasStandardPosition())	flags |= flags::Non_Standard_Start;
	if (item.hasPromotion())			flags |= flags::Promotion;
	if (item.hasUnderPromotion())		flags |= flags::Under_Promotion;

	uint32_t gameRecordLength = item.gameRecordLength();

	M_ASSERT(gameRecordLength > 0);

	// length of each gamefile record and its offset
	buf << uint32_t(item.m_gameOffset);
	buf << uint16_t(gameRecordLength);
	if (m_customFlags)
		buf << uint8_t(((gameRecordLength >> 16) << 7) | ((item.m_gameFlags >> 13) & 0x3f));
	buf << uint16_t(flags);

	// White and Black player names
	unsigned whiteId = m_playerList->lookup(item.m_player[color::White]->id());
	unsigned blackId = m_playerList->lookup(item.m_player[color::Black]->id());

	buf << uint8_t((((whiteId >> 16) & 0xf) << 4) | (((blackId >> 16) & 0xf)));
	buf << uint16_t(whiteId);
	buf << uint16_t(blackId);

	// Event, Site and Round names
	unsigned eventId	= m_eventList->lookup(item.m_event->id());
	unsigned siteId	= m_siteList->lookup(item.m_event->site()->id());
	unsigned roundId	= m_roundList->lookup(m_roundLookup[index]->id());

	buf << uint8_t(	uint8_t((eventId >> 16) << 5)
						 | uint8_t(((siteId >> 16) & 7) << 2)
						 | uint8_t((roundId >> 16) & 3));
	buf << uint16_t(eventId);
	buf << uint16_t(siteId);
	buf << uint16_t(roundId);

	buf << uint16_t(	uint16_t(item.m_variationCount)
						 | uint16_t(item.m_commentCount << 4)
						 | uint16_t(item.m_annotationCount << 8)
						 | uint16_t((item.m_result & 0x03) << 12));

	buf << uint16_t(item.m_eco ? (item.m_eco - 1)*131 + 1 : 0);

	uint32_t dateYear = Date::decodeYearFrom10Bits(item.m_dateYear);

	if (dateYear && dateYear <= 2047)
	{
		// Date and EventDate are stored in four bytes
		uint32_t date				= (dateYear << 9) | (item.m_dateMonth << 5) | item.m_dateDay;
		uint32_t eventDateYear	= item.m_event->dateYear();

		if (eventDateYear && eventDateYear <= 2047 && mstl::abs(int(eventDateYear) - int(dateYear)) <= 3)
		{
			buf << uint32_t(	date
								 | ((uint32_t(eventDateYear + 4 - dateYear)) << 29)
								 | (uint32_t(item.m_event->dateMonth()) << 25)
								 | (uint32_t(item.m_event->dateDay()) << 20));
		}
		else
		{
			buf << date;
		}
	}
	else
	{
		buf << uint32_t(0);
	}

	// The two Elo ratings and rating types take 2 bytes each
	if (item.m_pd[color::White].elo)
	{
		buf << uint16_t(mstl::min(uint16_t(4000), uint16_t(item.m_pd[color::White].elo)));
	}
	else if (item.m_pd[color::White].ratingType <= 6)
	{
		buf << uint16_t(	mstl::min(uint16_t(4000), uint16_t(item.m_pd[color::White].rating))
							 | uint32_t(item.m_pd[color::White].ratingType << 12));
	}
	else
	{
		buf << uint16_t(0);
	}

	if (item.m_pd[color::Black].elo)
	{
		buf << uint16_t(mstl::min(uint16_t(4000), uint16_t(item.m_pd[color::Black].elo)));
	}
	else if (item.m_pd[color::Black].ratingType <= 6)
	{
		buf << uint16_t(	mstl::min(uint16_t(4000), uint16_t(item.m_pd[color::Black].rating))
							 | uint16_t(item.m_pd[color::Black].ratingType << 12));
	}
	else
	{
		buf << uint16_t(0);
	}

	uint8_t storedLineIndex;

	if (item.idn() == chess960::StandardIdn)
		storedLineIndex = EcoTable::specimen().getStoredLine(Eco(item.m_ecoKey), Eco(item.m_ecoOpening));
	else
		storedLineIndex = 0;

	M_ASSERT(storedLineIndex < 255);

	// what will happen if item.m_numHalfMoves succeeds 1023?
	unsigned plyCount = mstl::min(item.m_plyCount, 0x03ffu);

	buf << storedLineIndex;
	buf << uint24_t(item.material().value);
	buf << uint8_t(plyCount);

	// the first byte of HomePawnData has high bits of the NumHalfMoves counter in its top two bits
	buf << uint8_t(item.m_signature.hpCount() | ((plyCount >> 8) << 6));

	hp::Pawns hp = item.m_signature.homePawnsData();
	::swapHomePawnBytes(hp.bytes);
	buf.put(hp.bytes, 8);
}


void
Codec::readIndex(mstl::fstream& fstrm, Progress& progress)
{
	char header[MaxIndexHeaderSize];

	if (!fstrm.read(header, m_headerSize))
		IO_RAISE(Index, Corrupted, "unexpected end of file");
	if (m_customFlags)
		::memcpy(m_customFlags, header + 120, sizeof(CustomFlags));

	ByteStream bstrm(header, m_headerSize);

	uint16_t version = bstrm.uint16();

	if (version != m_fileVersion)
		IO_RAISE(Index, Unknown_Version, "unsupported Scid version (%u)", unsigned(version));

	setType(Decoder::decodeType(bstrm.uint32()));

	GameInfoList& infoList = gameInfoList();

	unsigned size = bstrm.uint24();
	infoList.resize(size);
	for (unsigned i = 0; i < size; ++i)
		infoList[i] = allocGameInfo();

	m_autoLoad = bstrm.uint24();

	bstrm[119] = '\0';	// to be sure
	setDescription(reinterpret_cast<char const*>(bstrm.data()));

	m_roundLookup.resize(size);
	decodeIndex(fstrm, progress);
	fstrm.close();

	m_lookup[Namebase::Player   ].release();
	m_lookup[Namebase::Event    ].release();
	m_lookup[Namebase::Site     ].release();
	m_lookup[Namebase::Annotator].release();
	m_lookup[Namebase::Round    ].release();
}


void
Codec::decodeIndex(mstl::fstream &fstrm, Progress& progress)
{
	GameInfoList& infoList = gameInfoList();

	unsigned frequency	= progress.frequency(infoList.size(), 20000);
	unsigned reportAfter	= frequency;

	ProgressWatcher watcher(progress, infoList.size());

	for (unsigned i = 0; i < infoList.size(); ++i)
	{
		if (reportAfter == i)
		{
			progress.update(i);
			reportAfter += frequency;
		}

		char buf[MaxIndexEntrySize];

		if (__builtin_expect(!fstrm.read(buf, m_indexEntrySize), 0))
			IO_RAISE(Index, Corrupted, "unexpected end of file");

		ByteStream bstrm(buf, m_indexEntrySize);
		decodeIndex(bstrm, i);
	}
}


void
Codec::decodeIndex(ByteStream& strm, unsigned index)
{
	M_STATIC_CHECK(GameInfo::Flag_Deleted == 1 <<  0, Flags_Have_Changed);
	M_STATIC_CHECK(GameInfo::Flag_User1   == 1 << 13, Flags_Have_Changed);
	M_STATIC_CHECK(GameInfo::Flag_User6   == 1 << 18, Flags_Have_Changed);

	GameInfo& item = gameInfo(index);

	uint32_t flags;
	uint32_t gameRecordLength;

	// length of each gamefile record and its offset
	item.m_gameOffset = strm.uint32();
	gameRecordLength = strm.uint16();

	if (m_customFlags)
	{
		uint32_t byte = strm.uint8();

		gameRecordLength |= uint32_t(byte & 0x80) << 9;
		flags = strm.uint16() | ((byte & 0x3f) << 16);
	}
	else
	{
		flags = strm.uint16();
	}

	item.setGameRecordLength(gameRecordLength);

	item.m_gameFlags			= flags >> 3;
	item.m_positionId			= flags & flags::Non_Standard_Start ? 0 : chess960::StandardIdn;

	// White and Black player names
	uint32_t whiteBlackHigh	= strm.get();
	uint32_t whiteId			= strm.uint16() | (whiteBlackHigh >> 4) << 16;
	uint32_t blackId			= strm.uint16() | (whiteBlackHigh & 0x0f) << 16;

	NamebasePlayer* whitePlayer =
		::check(static_cast<NamebasePlayer*>(m_lookup[Namebase::Player][whiteId]));
	NamebasePlayer* blackPlayer =
		::check(static_cast<NamebasePlayer*>(m_lookup[Namebase::Player][blackId]));

	whitePlayer->ref(); blackPlayer->ref();

	item.m_player[color::White] = whitePlayer;
	item.m_player[color::Black] = blackPlayer;

	// Event, Site and Round names
	uint32_t eventSiteRnd_High	= strm.get();
	uint32_t eventId				= strm.uint16() | ((eventSiteRnd_High >> 5) << 16);
	uint32_t siteId				= strm.uint16() | (((eventSiteRnd_High >> 2) & 7) << 16);
	uint32_t roundId				= strm.uint16() | ((eventSiteRnd_High & 3) << 16);

	NamebaseEvent* event	= ::check(static_cast<NamebaseEvent*>(m_lookup[Namebase::Event][eventId]));
	NamebaseSite*  site	= ::check(static_cast<NamebaseSite* >(m_lookup[Namebase::Site ][siteId ]));
	NamebaseEntry* round	= ::check(static_cast<NamebaseEntry*>(m_lookup[Namebase::Round][roundId]));

	site->ref();
	round->ref();

	m_roundLookup[index] = round;

	unsigned rnd, subrnd;

	if (PgnReader::parseRound(round->name(), rnd, subrnd))
	{
		item.m_round = rnd;
		item.m_subround = subrnd;
	}

	uint16_t varCount	= strm.uint16();
	uint16_t ecoCode	= strm.uint16();

	item.m_result	= varCount >> 12;
	item.m_eco		= ecoCode ? (ecoCode - 1)/131 + 1 : 0;

	item.m_variationCount	= varCount & 15;
	item.m_commentCount		= (varCount >> 4) & 15;
	item.m_annotationCount	= (varCount >> 8) & 15;

	// Date and EventDate are stored in four bytes
	uint32_t d = strm.uint32();
	Date date;

	date.setYMD((d >> 9) & 2047, (d >> 5) & 15, d & 31);
	item.m_dateYear = Date::encodeYearTo10Bits(date.year());
	item.m_dateMonth = date.month();
	item.m_dateDay = date.day();

	if (date.year() && (d >> 29))
		date.setYMD((d >> 29) + date.year() - 4, (d >> 25) & 15, (d >> 20) & 31);
	else
		date.clear();

	bool determineMode = false;

	if (event->site() == NamebaseEvent::emptySite())
	{
		event->setSite(site);
		event->setDate(date);

		determineMode = true;
	}
	else if (event->site() != site || event->date() != date)
	{
		event = namebase(Namebase::Event).insertEvent(	event->name(),
																		namebase(Namebase::Event).size(),
																		date.year(),
																		date.month(),
																		date.day(),
																		event->type(),
																		event->timeMode(),
																		event->eventMode(),
																		maxEventCount(),
																		site);

		if (event == 0)
		{
			gameInfoList().resize(index);
			IO_RAISE(Index, Load_Failed, "too many events; load aborted");
		}

		determineMode = true;
	}

	if (determineMode)
	{
		event::Mode mode = PgnReader::getEventMode(event->name(), site->name());

		event->setEventMode(mode);

		switch (int(mode))
		{
			case event::PaperMail:
			case event::Email:
				event->setTimeMode(time::Corr);
				break;
		}
	}

	event->ref();
	item.m_event = event;

	uint16_t whiteRating = strm.uint16();
	uint16_t blackRating = strm.uint16();

	rating::Type whiteRatingType = rating::Type((whiteRating >> 12) & 7);
	rating::Type blackRatingType = rating::Type((blackRating >> 12) & 7);

	item.m_pd[color::White].ratingType = whiteRatingType;
	item.m_pd[color::Black].ratingType = blackRatingType;

	if (whiteRatingType == rating::Elo)
	{
		item.m_player[color::White]->setElo(
			item.m_pd[color::White].elo = mstl::min(int(rating::Max_Value), whiteRating & 0x0fff));
	}
	else
	{
		item.m_player[color::White]->setRating(
			whiteRatingType,
			item.m_pd[color::White].rating = mstl::min(int(rating::Max_Value), whiteRating & 0x0fff));
	}

	if (blackRatingType == rating::Elo)
	{
		item.m_player[color::Black]->setElo(
			item.m_pd[color::Black].elo = mstl::min(int(rating::Max_Value), blackRating & 0x0fff));
	}
	else
	{
		item.m_player[color::Black]->setRating(
			blackRatingType,
			item.m_pd[color::Black].rating = mstl::min(int(rating::Max_Value), blackRating & 0x0fff));
	}

	if (item.m_positionId == chess960::StandardIdn)
	{
		uint8_t index = strm.get();

		// IMPORTANT NOTE: stored line index is probably broken (Scid bug)
		if (index < StoredLine::count())
		{
			StoredLine const& line = StoredLine::getLine(index);

			item.m_ecoKey = line.ecoKey();
			item.m_ecoOpening = line.opening();
		}
#ifdef DEBUG_SI4
		else
		{
			::fprintf(stderr, "WARNING(%u): invalid stored line value 255\n", index);
		}
#endif
	}
	else
	{
		strm.skip(1);
	}

	// IMPORTANT NOTE: the material signature is possibly faulty
	// (its an overflow bug in Scid; reported as #2992119)
	// This has an significant impact to position search (tree search); some games will
	// probably not be found.
	unsigned materialSignature = strm.uint24();

	item.m_plyCount = strm.get();
	Byte count = strm.get();

	// the first byte of HomePawnData has high bits of the NumHalfMoves counter in its top two bits
	item.m_plyCount |= unsigned((count >> 6)) << 8;
	count &= 63;

	hp::Pawns hp;
	strm.get(hp.bytes, sizeof(hp.bytes));
	::swapHomePawnBytes(hp.bytes);

	// IMPORTANT NOTE: we have to clear garbage data (forgotten memset in Scid)
	::memset(hp.bytes + mstl::div2(count + 1), 0, mstl::div2(16 - count));
	if (mstl::is_odd(count))
		hp.bytes[mstl::div2(count)] &= 0x0f;

	// IMPORTANT NOTE:
	// In some cases the home pawn count is zero although all pawns have moved (Scid bug).
	// This has an significant impact to position search (tree search); some games will
	// probably not be found.
	item.m_signature.setHomePawns(count, hp);
	item.setMaterial(material::si3::Signature(materialSignature));
	item.m_signature.m_promotions	= !!(flags & flags::Promotion);
	item.m_signature.m_underPromotions = !!(flags & flags::Under_Promotion);
	item.m_signature.m_castling = 0; // leave this empty
}


void
Codec::readNamebase(mstl::fstream& stream, Progress& progress)
{
	unsigned count[Namebase::Round + 1];
	unsigned maxFreq[Namebase::Round + 1];

	M_STATIC_CHECK(Namebase::Player < U_NUMBER_OF(count), Index_Out_Of_Range);
	M_STATIC_CHECK(Namebase::Event  < U_NUMBER_OF(count), Index_Out_Of_Range);
	M_STATIC_CHECK(Namebase::Site   < U_NUMBER_OF(count), Index_Out_Of_Range);
	M_STATIC_CHECK(Namebase::Round  < U_NUMBER_OF(count), Index_Out_Of_Range);

	stream.set_bufsize(65536);
	ByteIStream bstrm(stream);

	bstrm.skip(4);	// skip timestamp

	count[Namebase::Player] = bstrm.uint24();
	count[Namebase::Event ] = bstrm.uint24();
	count[Namebase::Site  ] = bstrm.uint24();
	count[Namebase::Round ] = bstrm.uint24();

	maxFreq[Namebase::Player]	= bstrm.uint24();
	maxFreq[Namebase::Event]	= bstrm.uint24();
	maxFreq[Namebase::Site]		= bstrm.uint24();
	maxFreq[Namebase::Round]	= bstrm.uint24();

	progress.start(4);
	readNamebase(	bstrm,
						namebase(Namebase::Player),
						maxFreq[Namebase::Player],
						count[Namebase::Player],
						maxPlayerCount());
	progress.update(1);
	readNamebase(	bstrm,
						namebase(Namebase::Event),
						maxFreq[Namebase::Event],
						count[Namebase::Event],
						maxEventCount());
	progress.update(2);
	readNamebase(	bstrm,
						namebase(Namebase::Site),
						maxFreq[Namebase::Site],
						count[Namebase::Site],
						maxSiteCount());
	progress.update(3);
	readNamebase(	bstrm,
						namebase(Namebase::Round),
						maxFreq[Namebase::Round],
						count[Namebase::Round],
						::MaxRoundCount);
	progress.update(4);
	namebase(Namebase::Annotator).insert();
}


void
Codec::readNamebase(ByteIStream& bstrm, Namebase& base, unsigned maxFreq, unsigned count, unsigned limit)
{
	typedef Namebase::Type Type;

	M_ASSERT(count <= limit);
	M_ASSERT(m_codec);

	if (count == 0)
		return;

	mstl::string name;
	mstl::string str;
	mstl::string in;
	mstl::string out;

	char				buf[1024];
	Type				type			= base.type();
	Lookup&			lookup		= m_lookup[base.type()];
	mstl::bitset&	usedIdSet	= m_usedIdSet[base.type()];

	base.reserve(count, limit);
	lookup.resize(count);
	usedIdSet.resize(count);
	in.hook(buf, 1024);

	for (unsigned i = 0; i < count; ++i)
	{
		unsigned index = (count >= 65536) ? bstrm.uint24() : bstrm.uint16();

		__attribute__((unused))
		unsigned freq = (maxFreq >= 65536)
								? bstrm.uint24()
								: (maxFreq >= 256 ? bstrm.uint16() : bstrm.get());

		if (index >= lookup.size())
			IO_RAISE(Namebase, Corrupted, "namebase file is broken");

		usedIdSet.set(index);

		unsigned length = bstrm.get();

		if (i == 0)
		{
			bstrm.get(buf, length);
		}
		else
		{
			unsigned prefix = bstrm.get();

			if (prefix > length)
				IO_RAISE(Namebase, Corrupted, "namebase file is broken");

			bstrm.get(buf + prefix, length - prefix);
		}

		in.set_size(length);
		m_codec->toUtf8(in, out);

		switch (int(type))
		{
			case Namebase::Player:
				{
					mstl::string	value;
					country::Code	country	= country::Unknown;
					title::ID		title		= title::None;
					species::ID		type		= species::Unspecified;
					sex::ID			sex		= sex::Unspecified;

					str.assign(out);
					str.unhook();

					while (PgnReader::Tag tag = PgnReader::extractPlayerData(str, value))
					{
						switch (tag)
						{
							case PgnReader::Elo:
//									// this is unexpected and will be reversed
//									if (out.size() < (256 - 7))
//									{
//										out += ' ';
//										out += '(';
//										out.append(value, value.size());
//										out += ')';
//									}
								break;

							case PgnReader::Country:	country = country::fromString(value); break;
							case PgnReader::Human:		type = species::Human; break;
							case PgnReader::Program:	type = species::Program; break;
							case PgnReader::None:		break;

							case PgnReader::Title:
								title = title::fromString(value);
								type = species::Human;
								break;

							case PgnReader::Sex:
								sex = sex::fromChar(*value);
								type = species::Human;
								break;
						}
					}

					if (out.size() >= 256)
						out.set_size(255);

					char* s = base.alloc(out.size());
					::memcpy(s, out.c_str(), out.size());
					name.hook(s, out.size());

					// NOTE: we don't trust the frequency value, it is
					// probably faulty due to a bug in Scid.
					lookup[index] = base.insertPlayer(name, index, country, title, type, sex, limit);
				}
				break;

			case Namebase::Site:
				{
					str.assign(out);
					str.unhook();

					country::Code country = PgnReader::extractCountryFromSite(str);

					if (out.size() >= 256)
						out.set_size(255);

					char* s = base.alloc(out.size());
					::memcpy(s, out.c_str(), out.size());
					name.hook(s, out.size());

					lookup[index] = base.insertSite(name, index, country, limit);
				}
				break;

			case Namebase::Event:
				{
					if (out.size() >= 256)
						out.set_size(255);

					char* s = base.alloc(out.size());
					::memcpy(s, out.c_str(), out.size());
					name.hook(s, out.size());

					lookup[index] = base.insertEvent(name, index, limit, NamebaseEvent::emptySite());
				}
				break;

			case Namebase::Round:
				{
					if (out.size() >= 256)
						out.set_size(255);

					char* s = base.alloc(out.size());
					::memcpy(s, out.c_str(), out.size());
					name.hook(s, out.size());

					lookup[index] = base.insert(name, index, limit);
				}
				break;
		}

#ifdef DEBUG_SI4
		lookup[index]->m_orig_freq = freq;
#endif

		M_ASSERT(lookup[index]->id() == index);
	}
}


void
Codec::doEncoding(util::ByteStream& strm, GameData const& data, Signature const& signature)
{
	M_ASSERT(gameInfoList().size() <= maxGameCount());
	M_ASSERT(namebase(Namebase::Player).size() <= maxPlayerCount());
	M_ASSERT(namebase(Namebase::Event).size() <= maxEventCount());
	M_ASSERT(namebase(Namebase::Site).size() <= maxSiteCount());
	M_ASSERT(namebase(Namebase::Round).size() <= ::MaxRoundCount);

	Encoder encoder(strm, *m_codec);
	encoder.doEncoding(signature, data);
}


db::Consumer*
Codec::getConsumer(format::Type srcFormat)
{
	return new Consumer(srcFormat, *this, encoding());
}


void
Codec::writeNamebase(mstl::fstream& stream)
{
	M_ASSERT(m_playerList == 0);
	M_ASSERT(m_eventList == 0);
	M_ASSERT(m_siteList == 0);
	M_ASSERT(m_roundList == 0);

	stream.set_unbuffered();

	unsigned char buf[28];
	ByteStream bstrm(buf, sizeof(buf));

	m_playerList = new NameList(namebase(Namebase::Player), *m_codec, m_usedIdSet[Namebase::Player]);
	m_eventList  = new NameList(namebase(Namebase::Event ), *m_codec, m_usedIdSet[Namebase::Event ]);
	m_siteList   = new NameList(namebase(Namebase::Site  ), *m_codec, m_usedIdSet[Namebase::Site  ]);
	m_roundList  = new NameList(namebase(Namebase::Round ), *m_codec, m_usedIdSet[Namebase::Round ]);

	// ensure that the frequencies do not overflow (but this should be impossible)
	::checkNamebase(m_playerList->maxFrequency(), "maximal frequency exceeded in player base");
	::checkNamebase(m_eventList ->maxFrequency(), "maximal frequency exceeded in event base");
	::checkNamebase(m_siteList  ->maxFrequency(), "maximal frequency exceeded in site base");
	::checkNamebase(m_roundList ->maxFrequency(), "maximal frequency exceeded in round base");

	bstrm << uint32_t(sys::time::time());
	bstrm << uint24_t(m_playerList->size());
	bstrm << uint24_t(m_eventList ->size());
	bstrm << uint24_t(m_siteList  ->size());
	bstrm << uint24_t(m_roundList ->size());
	bstrm << uint24_t(m_playerList->maxFrequency());
	bstrm << uint24_t(m_eventList ->maxFrequency());
	bstrm << uint24_t(m_siteList  ->maxFrequency());
	bstrm << uint24_t(m_roundList ->maxFrequency());

	stream.write(buf, sizeof(buf));

	writeNamebase(stream, *m_playerList);
	writeNamebase(stream, *m_eventList );
	writeNamebase(stream, *m_siteList  );
	writeNamebase(stream, *m_roundList );
}


void
Codec::writeNamebase(mstl::fstream& stream, NameList& base)
{
	if (base.isEmpty())
		return;

	M_ASSERT(base.maxFrequency() <= ::MaxFrequency);

	unsigned char	buf[32768];
	ByteOStream		bstrm(stream, buf, sizeof(buf));

	NameList::Node const* node = base.first();
	NameList::Node const* prev = node;

	M_ASSERT(node->encoded.size() < 256);
	M_ASSERT(node->id < base.size());

	::writeId(bstrm, node->id, base.size());
	::writeFrequency(bstrm, node->frequency, base.maxFrequency());

	bstrm.put(node->encoded.size());
	bstrm.put(node->encoded.c_str(), node->encoded.size());

	for (node = base.next(); node; node = base.next())
	{
		unsigned length = node->encoded.size();
		unsigned prefix = ::prefix(node->encoded, prev->encoded);

		M_ASSERT(length < 256);
		M_ASSERT(prefix <= length);
		M_ASSERT(node->id < base.size());

		::writeId(bstrm, node->id, base.size());
		::writeFrequency(bstrm, node->frequency, base.maxFrequency());

		bstrm.put(length);
		bstrm.put(prefix);
		bstrm.put(node->encoded.c_str() + prefix, length - prefix);

		prev = node;
	}

	bstrm.flush();
}


bool
Codec::saveRoundEntry(unsigned index, mstl::string const& value)
{
	m_roundEntry = 0;

	NamebaseEntry* entry = namebase(Namebase::Round).insert(value, ::MaxRoundCount);

	if (entry == 0)
		return false;

	if (index >= m_roundLookup.size())
		m_roundLookup.resize(index + 1);
	else
		namebase(Namebase::Round).deref(m_roundEntry = m_roundLookup[index]);

	namebase(Namebase::Round).ref(entry);
	m_roundLookup[index] = entry;

	return true;
}


void
Codec::restoreRoundEntry(unsigned index)
{
	if (m_roundEntry)
		namebase(Namebase::Round).ref(m_roundEntry);

	namebase(Namebase::Round).deref(m_roundLookup[index]);
}


void
Codec::useAsyncReader(bool flag)
{
	M_ASSERT(m_gameData);

	if (flag)
	{
		if (m_asyncReader == 0)
			m_asyncReader = m_gameData->openAsyncReader();
	}
	else if (m_asyncReader)
	{
		m_gameData->closeAsyncReader(m_asyncReader);
		m_asyncReader = 0;
	}
}


Move
Codec::findExactPositionAsync(GameInfo const& info, Board const& position, bool skipVariations)
{
	M_ASSERT(m_asyncReader);

	ByteStream src;
	getGameRecord(info, *m_asyncReader, src);
	Decoder decoder(src, *m_codec);
	return decoder.findExactPosition(position, skipVariations);
}


uint32_t
Codec::computeChecksum(unsigned flags, GameInfo const& info, unsigned crc) const
{
	ByteStream strm;
	getGameRecord(info, m_gameData->reader(), strm);
	return crc::compute(crc, strm.data(), strm.size());
}

// vi:set ts=3 sw=3:
