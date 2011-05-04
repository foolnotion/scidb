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

namespace util {

inline bool BlockFile::isClosed() const			{ return m_isClosed; }
inline bool BlockFile::isOpen() const				{ return !m_isClosed; }
inline bool BlockFile::isEmpty() const				{ return m_cache.empty(); }
inline bool BlockFile::isMemoryOnly() const		{ return m_stream == 0; }
inline bool BlockFile::isReadOnly() const			{ return !isReadWrite(); }
inline bool BlockFile::isInSyncMode() const		{ return m_asyncViews.empty(); }
inline bool BlockFile::isInAsyncMode() const		{ return !m_asyncViews.empty(); }

inline BlockFile::Mode BlockFile::mode() const	{ return m_mode; }
inline BlockFileReader& BlockFile::reader()		{ return m_view; }

inline unsigned BlockFile::blockSize() const		{ return m_blockSize; }
inline unsigned BlockFile::countBlocks() const	{ return m_sizeInfo.size(); }
inline unsigned BlockFile::countReads() const	{ return m_view.m_countReads; }
inline unsigned BlockFile::countWrites() const	{ return m_countWrites; }

inline unsigned BlockFile::blockNumber(unsigned fileOffset) const	{ return fileOffset >> m_shift; }
inline unsigned BlockFile::blockOffset(unsigned fileOffset) const	{ return fileOffset & m_mask; }
inline unsigned BlockFile::fileOffset(unsigned blockNumber) const	{ return blockNumber << m_shift; }


inline
unsigned
BlockFile::countSpans(unsigned size) const
{
	return (size + m_blockSize - 1) >> m_shift;
}


inline
unsigned
BlockFile::get(ByteStream& result, unsigned offset, unsigned size)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(size <= MaxSpanSize);
	M_REQUIRE(offset + size <= this->size());
	M_REQUIRE(	(offset + size - 1)/blockSize() == offset/blockSize()	// fits into a single block
				|| offset % blockSize() == 0);									// or starts at block offset 0

	return get(m_view, result, offset, size);
}


inline
BlockFileReader::BlockFileReader(BlockFile& blockFile)
	:m_blockFile(blockFile)
	,m_countReads(0)
{
}


inline BlockFile const& BlockFileReader::blockFile() const { return m_blockFile; }


inline
unsigned
BlockFileReader::get(ByteStream& result, unsigned offset, unsigned size)
{
	M_REQUIRE(m_blockFile.isOpen());
	M_REQUIRE(size <= BlockFile::MaxSpanSize);
	M_REQUIRE(offset + size <= m_blockFile.size());
	M_REQUIRE(	(offset + size - 1)/m_blockFile.blockSize() == offset/m_blockFile.blockSize()
				|| offset % m_blockFile.blockSize() == 0);

	return m_blockFile.get(*this, result, offset, size);
}

} // namespace db

// vi:set ts=3 sw=3:
