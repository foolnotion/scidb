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

#ifndef _si3_codec_included
#define _si3_codec_included

#include "db_database_codec.h"
#include "db_namebase.h"
#include "db_common.h"

#include "nsUniversalDetector.h"

#include "u_crc.h"

#include "m_fstream.h"
#include "m_vector.h"
#include "m_string.h"

namespace util
{
	class ByteStream;
	class BlockFile;
}

namespace sys
{
	namespace utf8 { class Codec; }
};

namespace db {

class Consumer;
class GameData;
class GameInfo;
class NamebaseEntry;

namespace si3 {

class StoredLine;
class Consumer;
class NameList;

class Codec : public DatabaseCodec, public nsUniversalDetector
{
public:

	Codec(CustomFlags* customFlags = 0);
	~Codec() throw();

	bool isWritable() const override;
	bool encodingFailed() const override;
	bool usingAsyncReader() const override;
	bool isFormat3() const;
	bool isFormat4() const;

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
	mstl::string const& defaultEncoding() const override;

	unsigned gameFlags() const override;
	unsigned blockSize() const;

	db::tag::TagSet tagFilter(Section section, TagSet const& tags) const override;
	mstl::string const& extension() const override;
	mstl::string const& encoding() const override;

	void doOpen(mstl::string const& encoding) override;
	void doOpen(mstl::string const& rootname, mstl::string const& encoding) override;
	void doOpen(mstl::string const& rootname,
					mstl::string const& originalSuffix,
					mstl::string const& encoding,
					util::Progress& progress) override;
	unsigned doOpenProgressive(mstl::string const& rootname, mstl::string const& encoding) override;
	void doClear(mstl::string const& rootname) override;

	unsigned putGame(util::ByteStream const& strm) override;
	unsigned putGame(	util::ByteStream const& strm,
							unsigned prevOffset,
							unsigned prevRecordLength) override;
	util::ByteStream getGame(GameInfo const& info) override;
	void save(mstl::string const& rootname, unsigned start, util::Progress& progress) override;
	void attach(mstl::string const& rootname, util::Progress& progress) override;
	void update(mstl::string const& rootname);
	void update(mstl::string const& rootname, unsigned index, bool updateNamebase) override;
	void updateHeader(mstl::string const& rootname) override;
	void readIndexProgressive(unsigned index) override;
	void reloadDescription(mstl::string const& rootname) override;
	void reloadNamebases(mstl::string const& rootname,
								mstl::string const& originalSuffix,
								util::Progress& progress) override;
	void close() override;
	void sync() override;
	void removeAllFiles(mstl::string const& rootname) override;
	void writeNamebases(mstl::ostream& stream, util::Progress& progress) override;

	save::State doDecoding(	db::Consumer& consumer,
									TagSet& tags,
									GameInfo const& info,
									unsigned gameIndex) override;
	save::State doDecoding(	db::Consumer& consumer,
									util::ByteStream& strm,
									TagSet& tags) override;
	void doDecoding(GameData& data, GameInfo& info, unsigned gameIndex, mstl::string* encoding) override;
	unsigned doDecoding(	::util::BlockFileReader* asyncReader,
								GameInfo const& info,
								uint16_t* line,
								unsigned length,
								Board& startBoard,
								bool useStartBoard) override;

	void doEncoding(	util::ByteStream& strm,
							GameData const& data,
							Signature const& signature,
							unsigned langFlags,
							TagBits const& allowedTags,
							bool allowExtraTags) override;
	db::Consumer* getConsumer(format::Type srcFormat) override;

	void reset() override;
	void setEncoding(mstl::string const& encoding) override;
	void setWritable() override;

	void releaseRoundEntry(unsigned index);
	bool saveRoundEntry(unsigned index, mstl::string const& value);
	void restoreRoundEntry(unsigned index);
	void useOverflowEntry(unsigned index);
	mstl::string const& getRoundEntry(unsigned index) const;

	sys::utf8::Codec& codec();

	::util::BlockFileReader* getAsyncReader() override;
	void closeAsyncReader(::util::BlockFileReader* reader) override;

	Move findExactPosition(	GameInfo const& info,
									Board const& position,
									bool skipVariations,
									::util::BlockFileReader* reader) override;

	static bool getAttributes(	mstl::string const& filename,
										int& numGames,
										db::type::ID& type,
										mstl::string* description = 0);
	static void getSuffixes(mstl::string const& filename, StringList& result);
	static bool isExtraTag(tag::ID tag);

private:

	class ByteIStream;
	class ByteOStream;

	friend class Consumer;

	typedef mstl::vector<NamebaseEntry*> Lookup;

	void writeIndexEntries(mstl::fstream& fstrm, unsigned start, util::Progress& progress);
	void writeIndexHeader(mstl::fstream& fstrm);
	void updateIndex(mstl::fstream& fstrm);
	void encodeIndex(GameInfo const& item, unsigned index, util::ByteStream& buf);

	void decodeIndex(util::ByteStream& strm, unsigned index);
	void decodeIndex(mstl::fstream &fstrm, util::Progress& progress);

	void readIndex(mstl::fstream& fstrm, util::Progress& progress);
	uint16_t readIndexHeader(mstl::fstream& fstrm, unsigned* retNumGames);

	void readNamebases(mstl::fstream& stream, util::Progress& progress);
	void preloadNamebase(ByteIStream& bstrm,
								unsigned maxFreq,
								unsigned count,
								util::Progress& progress);
	void readNamebase(ByteIStream& stream,
							Namebase& base,
							NameList& shadowBase,
							unsigned maxFreq,
							unsigned count,
							unsigned limit,
							util::Progress& progress);
	void reloadNamebase(	ByteIStream& bstrm,
								Namebase& base,
								NameList& shadowBase,
								unsigned maxFreq,
								unsigned count,
								util::Progress& progress);
	void writeNamebase(mstl::ostream& stream, NameList& base, util::Progress* progress);
	void writeNamebases(mstl::string const& filename);
	void writeNamebases(mstl::ostream& stream, util::Progress* progress = 0);

	void save(mstl::string const& rootname, unsigned start, util::Progress& progress, bool attach);

	void Report(char const* charset) override;

	static void getRecodedDescription(	char const* description,
													mstl::string& result,
													sys::utf8::Codec& codec);

	unsigned				m_headerSize;
	unsigned				m_indexEntrySize;
	unsigned				m_fileVersion;
	unsigned				m_autoLoad;
	mstl::string		m_extIndex;
	mstl::string		m_extGame;
	mstl::string		m_extNamebase;
	unsigned				m_blockSize;
	mstl::fstream		m_gameStream;
	mstl::fstream*		m_progressiveStream;
	Lookup				m_roundLookup;
	sys::utf8::Codec*	m_codec;
	mstl::string		m_encoding;
	CustomFlags*		m_customFlags;
	util::BlockFile*	m_gameData;
	mstl::string		m_magicGameFile;
	bool					m_hasMagic;
	NameList*			m_playerList;
	NameList*			m_eventList;
	NameList*			m_siteList;
	NameList*			m_roundList;
	NamebaseEntry*		m_roundEntry;
	unsigned				m_progressFrequency;
	unsigned				m_progressReportAfter;
	unsigned				m_progressCount;
};

} // namespace si3
} // namespace db

#include "si3_codec.ipp"

#endif // _si3_codec_included

// vi:set ts=3 sw=3:
