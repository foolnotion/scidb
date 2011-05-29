// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#ifndef _u_block_file_included
#define _u_block_file_included

#include "u_byte_stream.h"

#include "m_string.h"
#include "m_vector.h"

namespace mstl { class fstream; }
namespace mstl { class ofstream; }

namespace util {

class BlockFile;


class BlockFileReader
{
public:

	BlockFile const& blockFile() const;

	unsigned get(ByteStream& result, unsigned offset, unsigned length = 0);

private:

	struct Buffer
	{
		Buffer();

		unsigned	m_capacity;
		unsigned	m_size;
		unsigned	m_number;
		unsigned m_span;

		unsigned char* m_data;
	};

	friend class BlockFile;

	BlockFileReader(BlockFile& blockFile);

	BlockFile&	m_blockFile;
	Buffer		m_buffer;
	unsigned		m_countReads;
};


class BlockFile
{
public:

	typedef BlockFileReader Reader;

	enum Mode { ReadWriteLength, RequireLength };

	static unsigned const MaxFileSize = 1 << 31;	//  2 GB
	static unsigned const MaxSpanSize = 1 << 24; // 16 MB

	static unsigned const MaxFileSizeExceeded	= unsigned(-1);
	static unsigned const WriteFailed			= unsigned(-2);
	static unsigned const SyncFailed				= unsigned(-3);
	static unsigned const ReadError				= unsigned(-4);
	static unsigned const IllegalOffset			= unsigned(-5);

	BlockFile(mstl::fstream* stream, unsigned blockSize, Mode mode);
	BlockFile(mstl::fstream* stream, unsigned blockSize, Mode mode, mstl::string const& magic);
	BlockFile(unsigned blockSize, Mode mode);
	BlockFile(unsigned blockSize, Mode mode, mstl::string const& magic);
	~BlockFile() throw();

	bool isClosed() const;
	bool isOpen() const;
	bool isEmpty() const;
	bool isMemoryOnly() const;
	bool isReadOnly() const;
	bool isReadWrite() const;
	bool isInSyncMode() const;
	bool isInAsyncMode() const;

	Mode mode() const;

	unsigned size() const;
	unsigned blockSize() const;
	unsigned countBlocks() const;
	unsigned countReads() const;
	unsigned countWrites() const;
	unsigned countSpans(unsigned size) const;
	unsigned fileSize();

	bool save(mstl::ofstream& stream);
	bool attach(mstl::fstream* stream);
	bool close();
	bool sync();

	unsigned put(ByteStream const& buf);
	unsigned put(ByteStream const& buf, unsigned offset, unsigned minLength = 0);
	unsigned get(ByteStream& result, unsigned offset, unsigned length = 0);

	Reader& reader();

	Reader* openAsyncReader();
	void closeAsyncReader(Reader*& reader);
	bool viewIsActive(Reader* reader) const;

private:

	friend class BlockFileReader;
	friend class BlockFileReader::Buffer;

	typedef unsigned char	Byte;
	typedef BlockFileReader	View;

	typedef mstl::vector<Byte*>		Cache;
	typedef mstl::vector<unsigned>	SizeInfo;
	typedef mstl::vector<View*>		AsyncViews;

	static unsigned const InvalidBlock = unsigned(-1);

	unsigned put(View& view, ByteStream const& buf);
	unsigned put(View& view, ByteStream const& buf, unsigned offset, unsigned minLength);
	unsigned get(View& view, ByteStream& result, unsigned offset, unsigned length);

	unsigned lastBlockSize() const;
	unsigned blockNumber(unsigned fileOffset) const;
	unsigned blockOffset(unsigned fileOffset) const;
	unsigned fileOffset(unsigned blockNumber) const;

	void computeBlockCount();
	unsigned fetch(View& view, unsigned blockNumber, unsigned span = 1);
	unsigned retrieve(View& view, unsigned blockNumber, unsigned offset);
	bool resize(View& view, unsigned span);
	void deallocate() throw();
	void putMagic(mstl::string const& magic);

	void copy(ByteStream const& buf, unsigned offset, unsigned nbytes);

	BlockFile(BlockFile const&);
	BlockFile& operator=(BlockFile const&);

	mstl::fstream*	m_stream;

	View			m_view;
	Mode			m_mode;
	unsigned		m_blockSize;
	unsigned		m_shift;
	unsigned		m_mask;
	unsigned		m_mtime;
	bool			m_isDirty;
	bool			m_isClosed;
	unsigned		m_countWrites;
	SizeInfo		m_sizeInfo;
	Cache			m_cache;
	AsyncViews	m_asyncViews;
};

} // namespace util

#include "u_block_file.ipp"

#endif // _u_block_file_included

// vi:set ts=3 sw=3:
