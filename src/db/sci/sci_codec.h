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

#ifndef _sci_codec_included
#define _sci_codec_included

#include "db_database_codec.h"
#include "db_common.h"

#include "m_fstream.h"
#include "m_string.h"
#include "m_vector.h"

namespace util
{
	class ByteStream;
	class BlockFile;
	class BlockFileReader;
	class Progress;
}

namespace db {

class GameData;
class GameInfo;
class Namebase;
class Consumer;
class TagSet;
class Time;

namespace sci {

class Codec : public DatabaseCodec
{
public:

	Codec();
	~Codec() throw();

	bool isWriteable() const override;
	bool encodingFailed() const override;

	Format format() const override;

	unsigned maxGameRecordLength() const override;
	unsigned maxGameLength() const override;
	unsigned maxGameCount() const override;
	unsigned maxPlayerCount() const override;
	unsigned maxEventCount() const override;
	unsigned maxSiteCount() const override;
	unsigned maxAnnotatorCount() const override;
	unsigned minYear() const override;
	unsigned maxYear() const override;
	unsigned maxDescriptionLength() const override;

	unsigned gameFlags() const override;

	void filterTag(TagSet& tags, tag::ID tag, Section section) const override;
	mstl::string const& extension() const override;
	mstl::string const& encoding() const override;

	void doOpen(mstl::string const& encoding) override;
	void doOpen(mstl::string const& rootname, mstl::string const& encoding) override;
	void doOpen(mstl::string const& rootname,
					mstl::string const& encoding,
					util::Progress& progress) override;
	void doClear(mstl::string const& rootname) override;

	unsigned putGame(util::ByteStream const& strm) override;
	unsigned putGame(	util::ByteStream const& strm,
							unsigned prevOffset,
							unsigned prevRecordLength) override;
	util::ByteStream getGame(GameInfo const& info) override;
	void save(mstl::string const& rootname, unsigned start, util::Progress& progress) override;
	void attach(mstl::string const& rootname, util::Progress& progress) override;
	void update(mstl::string const& rootname) override;
	void update(mstl::string const& rootname, unsigned index, bool updateNamebase) override;
	void updateHeader(mstl::string const& rootname) override;
	void unlock(mstl::string const& rootname) override;
	void close() override;
	void sync() override;

	save::State doDecoding(db::Consumer& consumer, TagSet& tags, GameInfo const& info) override;
	save::State doDecoding(db::Consumer& consumer, util::ByteStream& strm, TagSet& tags) override;
	void doDecoding(GameData& data, GameInfo& info) override;

	void doEncoding(	util::ByteStream& strm,
							GameData const& data,
							Signature const& signature,
							TagBits const& allowedTags,
							bool allowExtraTags) override;
	Consumer* getConsumer(format::Type srcFormat) override;

	void reset() override;
	void setEncoding(mstl::string const& encoding) override;

	void useAsyncReader(bool flag) override;
	Move findExactPositionAsync(	GameInfo const& info,
											Board const& position,
											bool skipVariations) override;

	static DatabaseCodec* makeCodec(mstl::string const& name);
	static void rename(mstl::string const& oldName, mstl::string const& newName);
	static void remove(mstl::string const& fileName);
	static int getNumberOfGames(mstl::string const& filename);
	static void getSuffixes(mstl::string const& filename, StringList& result);
	static bool upgradeIndexOnly();

private:

	typedef mstl::vector<unsigned> Lookup;

	void encodeIndex(GameInfo const& item, util::ByteStream& buf);

	void decodeIndex(mstl::fstream &fstrm, util::Progress& progress);
	void decodeIndex(util::ByteStream& strm, GameInfo& item);

	void readNamebases(mstl::fstream& stream, util::Progress& progress);
	void readNamebase(util::ByteStream& bstrm, Namebase& base, unsigned count, util::Progress& progress);
	void readSitebase(util::ByteStream& bstrm, Namebase& base, unsigned count, util::Progress& progress);
	void readEventbase(util::ByteStream& bstrm, Namebase& base, unsigned count, util::Progress& progress);
	void readPlayerbase(util::ByteStream& bstrm, Namebase& base, unsigned count, util::Progress& progress);

	void updateIndex(mstl::fstream& fstrm);
	void writeIndex(mstl::fstream& fstrm, unsigned start, util::Progress& progress);
	void writeIndexHeader(mstl::fstream& fstrm);
	void writeNamebases(mstl::string const& filename);
	void writeNamebases(mstl::fstream& stream);
	void writeNamebase(util::ByteStream& bstrm, Namebase& base);
	void writeSitebase(util::ByteStream& bstrm, Namebase& base);
	void writeEventbase(util::ByteStream& bstrm, Namebase& base);
	void writePlayerbase(util::ByteStream& bstrm, Namebase& base);

	void save(mstl::string const& rootname, unsigned start, util::Progress& progress, bool attach);
	uint16_t readIndexHeader(mstl::fstream& fstrm);
	void checkFileVersion(mstl::fstream& fstrm, mstl::string const& magic, uint16_t fileVersion);

	mstl::fstream				m_gameStream;
	util::BlockFile*			m_gameData;
	util::BlockFileReader*	m_asyncReader;
	mstl::string				m_magicGameFile;
	Lookup						m_lookup[4];
	unsigned						m_progressFrequency;
	unsigned						m_progressReportAfter;
	unsigned						m_progressCount;
};

} // namespace sci
} // namespace db

#endif // _sci_codec_included

// vi:set ts=3 sw=3:
