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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _cbf_codec_included
#define _cbf_codec_included

#include "db_database_codec.h"

#include "nsUniversalDetector.h"

#include "m_fstream.h"
#include "m_vector.h"

namespace sys  { namespace utf8 { class Codec; }; };
namespace mstl { class fstream; }
namespace util { class ByteStream; };

namespace db {

class NamebaseSite;

namespace cbf {

class Codec : public DatabaseCodec, public nsUniversalDetector
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

	mstl::string const& extension() const override;
	mstl::string const& encoding() const override;
	void filterTags(TagSet& tags, Section section) const override;

	void doOpen(mstl::string const& rootname,
					mstl::string const& originalSuffix,
					mstl::string const& encoding,
					util::Progress& progress) override;
	void reloadNamebases(mstl::string const& rootname,
								mstl::string const& originalSuffix,
								util::Progress& progress) override;
	void reloadDescription(mstl::string const& rootname) override;

	void close() override;

	void doDecoding(GameData& data, GameInfo& info, unsigned gameIndex, mstl::string*) override;
	save::State doDecoding(	Consumer& consumer,
									TagSet& tags,
									GameInfo const& info,
									unsigned gameIndex) override;

	void reset() override;
	void setEncoding(mstl::string const& encoding) override;

	static bool getAttributes(	mstl::string const& filename,
										int& numGames,
										db::type::ID& type,
										mstl::string* description);
	static void getSuffixes(mstl::string const& filename, StringList& result);

private:

	typedef mstl::vector<unsigned> RecordLengths;

	void preloadIndexData(mstl::string const& indexFilename, util::Progress& progress);
	void preloadIndexData(unsigned offset);
	void readIndexData(mstl::string const& indexFilename, util::Progress& progress);
	void decodeIndexData(GameInfo& info, unsigned offset, NamebaseSite* site);
	void prepareDecoding(GameInfo const& info, unsigned gameIndex, util::ByteStream& strm);

	void Report(char const* charset);

	void mapPlayerName(mstl::string& str);
	void toUtf8(mstl::string& str);

	sys::utf8::Codec*	m_codec;
	mstl::fstream		m_gameStream;
	mstl::string		m_encoding;
	unsigned				m_numGames;
	RecordLengths		m_recordLengths;
	Byte					m_buffer[8192];
};

} // namespace cbf
} // namespace db

#endif // _cbf_codec_included

// vi:set ts=3 sw=3:
