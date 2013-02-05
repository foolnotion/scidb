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

#include "cbf_codec.h"
#include "cbf_decoder.h"

#include "db_tag_set.h"
#include "db_reader.h"
#include "db_exception.h"

#include "u_byte_stream.h"
#include "u_progress.h"
#include "u_misc.h"

#include "sys_utf8_codec.h"
#include "sys_utf8.h"
#include "sys_file.h"

#include "m_vector.h"
#include "m_utility.h"

#include <ctype.h>
#include <stdlib.h>

using namespace db;
using namespace db::cbf;
using namespace util;


static db::tag::TagSet m_infoTags;


static void
xorBuffer(Byte* buf, unsigned bufLen, Byte xorMask)
{
	for (int i = bufLen - 1; i >= 0; --i, xorMask *= 3)
		buf[i] ^= xorMask;
}


static bool
extractRoundNumber(mstl::string& str, unsigned& round, unsigned& subround)
{
	char* s = str.begin();
	char* e = str.end();

	while (s < e)
	{
		if (*s == '(')
		{
			char* anchor = s++;

			bool valid	= true;
			bool mslash	= false;

			// allow "(m/X)"
			if (s[0] == 'm' && s[1] == '/')
			{
				s += 2;
				mslash = true;
			}

			while (s < e && *s != ')')
			{
				char c = *s++;

				if (!isdigit(c) && c != '.' && c != '/' && c != '\\')
				{
					valid = false;
					break;
				}
			}

			if (valid && *s == ')')
			{
				char* end;

				e = s + 1;
				s = anchor;

				if (mslash)
					s += 2;

				// remove the round numbers from between the parathesis and seperators
				while (s < e && !isdigit(*s))
					++s;

				if (s < e)
					round = strtol(s, &end, 10);

				if (end < e)
				{
					s = end;

					while (s < e && !isdigit(*s))
						++s;

					if (s < e)
						subround = strtol(s, &end, 10);
				}

				if (anchor > str.begin() && isspace(s[-1]) && isspace(*e))
					++e;

				str.erase(anchor, e);
				return true;
			}
		}

		s++;
	}

	return false;
}


static bool
extractAnnotator(mstl::string& source, mstl::string& annotator)
{
	char* s = ::strchr(source, '[');

	if (s)
	{
		char* e = ::strchr(s + 1, ']');

		if (e)
		{
			annotator.assign(s + 1, e - 1);
			annotator.trim();

			if (!annotator.empty() && isalpha(annotator[0]))
			{
				if (s > source.begin() && isspace(s[-1]) && isspace(e[1]))
					++e;

				source.erase(s, e);
				return true;
			}
		}
	}

	return false;
}


unsigned Codec::maxGameRecordLength() const	{ return 0xffff; }
unsigned Codec::maxGameCount() const			{ return 0xffff; }
unsigned Codec::maxGameLength() const			{ return (1 << 16) - 1; }
unsigned Codec::maxPlayerCount() const			{ return (1 << 24) - 1; }
unsigned Codec::maxEventCount() const			{ return (1 << 24) - 1; }
unsigned Codec::maxSiteCount() const			{ return (1 << 24) - 1; }
unsigned Codec::maxAnnotatorCount() const		{ return (1 << 24) - 1; }
unsigned Codec::minYear() const					{ return 0; }
unsigned Codec::maxYear() const					{ return uint16_t(2027); }
unsigned Codec::maxDescriptionLength() const	{ return 0; }


unsigned
Codec::gameFlags() const
{
	return 0;
}


Codec::Codec()
	:m_codec(0)
	,m_encoding(::sys::utf8::Codec::dos())
	,m_numGames(0)
{
	if (::m_infoTags.none())
	{
		::m_infoTags.set(tag::Event);
		::m_infoTags.set(tag::Site);
		::m_infoTags.set(tag::Date);
		::m_infoTags.set(tag::Round);
		::m_infoTags.set(tag::White);
		::m_infoTags.set(tag::Black);
		::m_infoTags.set(tag::Result);
		::m_infoTags.set(tag::Annotator);
		::m_infoTags.set(tag::Eco);
		::m_infoTags.set(tag::WhiteElo);
		::m_infoTags.set(tag::BlackElo);
		::m_infoTags.set(tag::EventCountry);
		::m_infoTags.set(tag::Mode);
		::m_infoTags.set(tag::TimeMode);
	}
}


Codec::~Codec() throw()
{
	delete m_codec;
}


bool
Codec::isWriteable() const
{
	return false;
}


bool
Codec::encodingFailed() const
{
	M_ASSERT(m_codec);
	return m_codec->failed();
}


Codec::Format
Codec::format() const
{
	return format::ChessBaseDOS;
}


mstl::string const&
Codec::encoding() const
{
	M_ASSERT(m_codec);
	return m_codec->encoding();
}


mstl::string const&
Codec::extension() const
{
	static mstl::string const Suffix("cbf");
	return Suffix;
}


void
Codec::Report(char const* charset)
{
	if (::sys::utf8::Codec::latin1() == charset)
		m_encoding.assign(::sys::utf8::Codec::dos());
	else if (::sys::utf8::Codec::ascii() != charset)
		m_encoding.assign(charset);
}


void
Codec::setEncoding(mstl::string const& encoding)
{
	if (m_codec == 0)
		m_codec = new ::sys::utf8::Codec(encoding);
	else
		m_codec->reset(encoding);
}


void
Codec::reset()
{
	// no action
}


void
Codec::toUtf8(mstl::string& str)
{
	m_codec->toUtf8(str);

	if (!sys::utf8::validate(str))
		m_codec->forceValidUtf8(str);
}


void
Codec::mapPlayerName(mstl::string& str)
{
	if (str.empty())
	{
		str = '?';
	}
	else
	{
		mstl::vector<unsigned> indices;

		for (unsigned i = 0; i < str.size(); ++i)
		{
			switch (Byte(str[i]))
			{
				case 0xa2: str[i] = 'K'; indices.push_back(i); break;
				case 0xa3: str[i] = 'Q'; indices.push_back(i); break;
				case 0xa4: str[i] = 'N'; indices.push_back(i); break;
				case 0xa5: str[i] = 'B'; indices.push_back(i); break;
				case 0xa6: str[i] = 'R'; indices.push_back(i); break;
				case 0xa7: str[i] = 'P'; indices.push_back(i); break;
			}
		}

		toUtf8(str);

		mstl::string piece;
		unsigned k = 0;

		for (unsigned i = 0; i < indices.size(); ++i)
		{
			switch (str[indices[i] + k])
			{
				case 'K': piece = piece::utf8::asString(piece::King  ); break;
				case 'Q': piece = piece::utf8::asString(piece::Queen ); break;
				case 'R': piece = piece::utf8::asString(piece::Rook  ); break;
				case 'B': piece = piece::utf8::asString(piece::Bishop); break;
				case 'N': piece = piece::utf8::asString(piece::Knight); break;
				case 'P': piece = piece::utf8::asString(piece::Pawn  ); break;
			}

			str.replace(indices[i] + k, 1, piece);
			k += piece.size() - 1;
		}
	}
}


void
Codec::filterTags(TagSet& tags, Section section) const
{
	tag::TagSet infoTags = m_infoTags;

	if (section == InfoTags)
		infoTags.flip(0, tag::ExtraTag - 1);

	tags.remove(infoTags);
}


void
Codec::close()
{
	if (m_gameStream.is_open())
		m_gameStream.close();
}


void
Codec::doOpen(	mstl::string const& rootname,
					mstl::string const& encoding,
					util::Progress& progress)
{
	ProgressWatcher watcher(progress, 0);

	setEncoding(encoding);
	setVariant(variant::Normal);

	mstl::string filename(rootname + ".cbf");
	checkPermissions(filename);
	openFile(m_gameStream, filename, Readonly);

	if (!m_codec->hasEncoding())
	{
		preloadIndexData(rootname, progress);
		DataEnd();

		if (m_encoding == sys::utf8::Codec::automatic())
			m_encoding = sys::utf8::Codec::dos(); // cannot be Latin-1
		m_codec->reset(m_encoding);
		useEncoding(m_encoding);
	}

	progress.message("read-init");
	readIndexData(rootname, progress);
	namebases().setReadonly();

	namebases().setReadonly(false);
	namebases().setModified(false);
	namebases().update();
	namebases().setReadonly();
}


void
Codec::reloadNamebases(mstl::string const& rootname, Progress& progress)
{
	gameInfoList().clear();

	namebases().setReadonly(false);
	namebases().clear();
	readIndexData(rootname, progress);
	namebases().setReadonly(true);
}


void
Codec::preloadIndexData(mstl::string const& rootname, util::Progress& progress)
{
	mstl::string	filename(rootname + ".cbi");
	mstl::fstream	strm;

	Byte record[4];

	openFile(strm, filename, Readonly);
	strm.read(record, sizeof(record));

	if ((m_numGames = ByteStream::uint32(record)) > 0)
		m_numGames -= 1;

	if (m_numGames > 0)
	{
		ProgressWatcher watcher(progress, m_numGames);
		progress.message("preload-namebase");

		unsigned frequency	= progress.frequency(m_numGames, 20000);
		unsigned reportAfter	= frequency;

		for (unsigned i = 0; i < m_numGames; ++i)
		{
			if (reportAfter == i)
			{
				progress.update(i);
				reportAfter += frequency;
			}

			strm.read(record, sizeof(record));
			preloadIndexData(ByteStream::uint32(record) - (i + 2));
		}
	}

	strm.close();
}


void
Codec::preloadIndexData(unsigned offset)
{
	Byte hdr[14];
	Byte buf[126];

	if (!m_gameStream.seekg(offset, mstl::ios_base::beg))
		IO_RAISE(Game, Corrupted, "unexpected end of file");
	if (!m_gameStream.read(hdr, sizeof(hdr)))
		IO_RAISE(Game, Corrupted, "unexpected end of file");

	::xorBuffer(hdr, sizeof(hdr), 101);
	buf[11] ^= 0x0e + (buf[4] & 0x3f) + (buf[5] & 0x3f);

	Byte crc1 = hdr[0]*0x25 + hdr[5] + hdr[9];
	Byte crc2 = hdr[3]*0x1ec1*(hdr[8] + 1)*hdr[0];

	if (crc1 != hdr[13] && crc2 != hdr[13])
		IO_RAISE(Game, Corrupted, "checksum error");

	unsigned playersLen	= hdr[4] & 0x3f;
	unsigned sourceLen	= hdr[5] & 0x3f;
	unsigned totalLen		= playersLen + sourceLen;

	if (!m_gameStream.read(buf, totalLen))
		IO_RAISE(Game, Corrupted, "unexpected end of file");

	::xorBuffer(buf, totalLen, 3*totalLen);
	HandleData(reinterpret_cast<char const*>(buf), totalLen);
}


void
Codec::readIndexData(mstl::string const& rootname, util::Progress& progress)
{
	mstl::string	filename(rootname + ".cbi");
	mstl::fstream	strm;

	Byte record[4];

	openFile(strm, filename, Readonly);

	if (!strm.read(record, sizeof(record)))
		IO_RAISE(Index, Corrupted, "unexpected end of file");

	if ((m_numGames = ByteStream::uint32(record)) > 0)
		m_numGames -= 1;

	if (m_numGames > 0)
	{
		ProgressWatcher watcher(progress, m_numGames);
		progress.message("read-index");

		unsigned frequency	= progress.frequency(m_numGames, 20000);
		unsigned reportAfter	= frequency;

		GameInfoList&	infoList	= gameInfoList();
		NamebaseSite*	site		= namebases()(Namebase::Site).insertSite("?");

		m_recordLengths.resize(m_numGames);
		infoList.reserve(m_numGames);

		unsigned prevOffset = 0;

		for (unsigned i = 0; i < m_numGames; ++i)
		{
			if (reportAfter == i)
			{
				progress.update(i);
				reportAfter += frequency;
			}

			if (!strm.read(record, sizeof(record)))
				IO_RAISE(Index, Corrupted, "unexpected end of file");

			unsigned offset = ByteStream::uint32(record) - (i + 2);

			infoList.push_back(allocGameInfo());
			decodeIndexData(*infoList.back(), offset, site);

			if (i > 0)
				m_recordLengths[i - 1] = offset - prevOffset;

			prevOffset = offset;
		}

		m_recordLengths[m_numGames - 1] = m_gameStream.size() - prevOffset;
	}

	strm.close();

	namebases().setReadonly(false);
	namebases().setModified(false);
	namebases().update();
	namebases().setReadonly();
}


void
Codec::decodeIndexData(GameInfo& info, unsigned offset, NamebaseSite* site)
{
	M_ASSERT(site);

	Byte hdr[14];
	Byte buf[126];

	if (!m_gameStream.seekg(offset, mstl::ios_base::beg))
		IO_RAISE(Game, Corrupted, "unexpected end of file");
	if (!m_gameStream.read(hdr, sizeof(hdr)))
		IO_RAISE(Game, Corrupted, "unexpected end of file");

	::xorBuffer(hdr, sizeof(hdr), 101);
	buf[11] ^= 0x0e + (buf[4] & 0x3f) + (buf[5] & 0x3f);

	Byte crc1 = hdr[0]*0x25 + hdr[5] + hdr[9];
	Byte crc2 = hdr[3]*0x1ec1*(hdr[8] + 1)*hdr[0];

	if (crc1 != hdr[13] && crc2 != hdr[13])
		IO_RAISE(Game, Corrupted, "checksum error");

	if (hdr[0] != 127)
		info.m_dateYear = Date::encodeYearTo10Bits(1900 + char(hdr[0]));

	switch (hdr[1])
	{
		case 0:	info.m_result = result::Black; break;
		case 1:	info.m_result = result::Draw; break;
		case 2:	info.m_result = result::White; break;
		default:	info.m_result = result::Unknown; break;
	}

	info.m_plyCount = hdr[12] << 1; // TODO: count exact number

	if (hdr[8])
	{
		info.m_pd[color::White].elo = 1600 + 5*hdr[8];
		info.m_pd[color::White].ratingType = rating::Elo;
	}
	if (hdr[9])
	{
		info.m_pd[color::Black].elo = 1600 + 5*hdr[9];
		info.m_pd[color::Black].ratingType = rating::Elo;
	}

	if (hdr[10] & 0x01)
	{
		info.m_setup = true;
	}
	else if (hdr[10] & 0x3e)
	{
		int code		= ((hdr[10] & 0x3e) >> 1) | ((hdr[4] & 0xc0) >> 1) | ((hdr[5] & 0xc0) << 1);
		int letter	= (code - 1)/100 + 'A';
		int number	= (code - 1) % 100;

		if ('A' <= letter & letter <= 'E' && number <= 99)
		{
			Eco eco;
			eco.setup(letter, number);
			info.m_eco = eco.code();
		}
	}

	unsigned playersLen	= hdr[4] & 0x3f;
	unsigned sourceLen	= hdr[5] & 0x3f;
	unsigned totalLen		= playersLen + sourceLen;
	unsigned round;
	unsigned subround;

	if (!m_gameStream.read(buf, totalLen))
		IO_RAISE(Game, Corrupted, "unexpected end of file");

	::xorBuffer(buf, totalLen, 3*totalLen);

	mstl::string players(reinterpret_cast<char const*>(buf),
								reinterpret_cast<char const*>(buf) + playersLen);
	mstl::string source(	reinterpret_cast<char const*>(buf) + playersLen,
								reinterpret_cast<char const*>(buf) + totalLen);

	toUtf8(source);

	if (::extractRoundNumber(players, round, subround) || ::extractRoundNumber(source, round, subround))
	{
		info.m_round = round;
		info.m_subround = subround;
	}

	mstl::string annotator;
	if (::extractAnnotator(source, annotator))
		info.m_annotator = namebases()(Namebase::Annotator).insert(annotator);

	mstl::string player[2];

	char const* delim = ::strchr(players, '-');

	if (delim == 0)
	{
		player[color::White].assign(players, playersLen);
	}
	else
	{
		player[color::White].assign(players, delim);
		player[color::Black].assign(delim + 1, playersLen - (delim + 1 - players.begin()));
	}

	player[color::White].trim();
	player[color::Black].trim();

	for (unsigned i = 0; i < 2; ++i)
	{
		color::ID		color		= i ? color::Black : color::White;
		country::Code	country	= country::Unknown;
		title::ID		title		= title::None;
		species::ID		type		= species::Unspecified;
		sex::ID			sex		= sex::Unspecified;
		mstl::string	value;

		while (Reader::Tag tag = Reader::extractPlayerData(player[i], value))
		{
			switch (tag)
			{
				case Reader::Elo:			break; // cannot be used
				case Reader::Country:	country = country::fromString(value); break;
				case Reader::Human:		type = species::Human; break;
				case Reader::Program:	type = species::Program; break;
				case Reader::None:		break;

				case Reader::Title:
					title = title::fromString(value);
					type = species::Human;
					break;

				case Reader::Sex:
					sex = sex::fromChar(*value);
					type = species::Human;
					break;
			}
		}

		mapPlayerName(player[i]);

		NamebasePlayer* p = namebases()(Namebase::Player).
			insertPlayer(player[i], country, title, type, sex, 0, mstl::mul2(m_numGames));

		(info.m_player[color] = p)->ref();
	}

	if (source.empty())
		source.assign("?", 1);

	country::Code	country	= Reader::extractCountryFromSite(source);
	event::Mode		mode		= Reader::getEventMode(source, source);

	(info.m_event = namebases()(Namebase::Event).insertEvent(source, site))->ref();

	switch (int(mode))
	{
		case event::PaperMail:
		case event::Email:
			info.m_event->setTimeMode_(time::Corr);
			break;
	}

	info.m_event->setEventMode_(mode);
	info.m_event->setCountry_(country);
	info.m_gameOffset = offset;
}


void
Codec::prepareDecoding(GameInfo const& info, unsigned gameIndex, ByteStream& strm)
{
	strm.setup(m_buffer, sizeof(m_buffer));
	strm.reserve(m_recordLengths[gameIndex]);
	strm.provide(m_recordLengths[gameIndex]);

	Byte* hdr = strm.base();

	if (!m_gameStream.seekg(info.gameOffset(), mstl::ios_base::beg))
		IO_RAISE(Game, Corrupted, "unexpected end of file");
	if (!m_gameStream.read(hdr, m_recordLengths[gameIndex]))
		IO_RAISE(Game, Corrupted, "unexpected end of file");

	::xorBuffer(hdr, 14, 101);
	hdr[11] ^= 0x0e + (hdr[4] & 0x3f) + (hdr[5] & 0x3f);

	Byte crc1 = hdr[0]*0x25 + hdr[5] + hdr[9];
	Byte crc2 = hdr[3]*0x1ec1*(hdr[8] + 1)*hdr[0];

	if (crc1 != hdr[13] && crc2 != hdr[13])
		IO_RAISE(Game, Corrupted, "checksum error");
}


void
Codec::doDecoding(GameData& data, GameInfo& info, unsigned gameIndex, mstl::string*)
{
	ByteStream bstrm;
	prepareDecoding(info, gameIndex, bstrm);
	Decoder decoder(bstrm, *m_codec);
	decoder.doDecoding(data);
}


save::State
Codec::doDecoding(Consumer& consumer, TagSet& tags, GameInfo const& info, unsigned gameIndex)
{
	ByteStream bstrm;
	prepareDecoding(info, gameIndex, bstrm);
	Decoder decoder(bstrm, *m_codec);
	return decoder.doDecoding(consumer, tags);
}


bool
Codec::getAttributes(mstl::string const& filename,
							int& numGames,
							db::type::ID& type,
							mstl::string* description)
{
	mstl::string fname(util::misc::file::rootname(filename));
	fname.append(".cbi");

	mstl::fstream strm(sys::file::internalName(fname), mstl::ios_base::in | mstl::ios_base::binary);

	if (!strm)
		return false;

	Byte record[4];

	if (!strm.read(record, sizeof(record)))
		return false;

	if ((numGames = ByteStream::uint32(record)) > 0)
		numGames -= 1;

	strm.close();
	return true;
}


void
Codec::getSuffixes(mstl::string const&, StringList& result)
{
	result.push_back("cbf");
	result.push_back("cbi");
	result.push_back("cko");
	result.push_back("cpo");
}

// vi:set ts=3 sw=3:
