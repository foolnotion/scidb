// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace eco {

inline Id::Id() :m_code(0) {}
inline Id::Id(char const* s) { setup(s); }
inline Id::Id(Code code) :m_code(code) {}
inline Id::Id(Code basic, Code extension) :m_code((basic << Sub_Code_Bits) + extension + 1) {}

inline auto Id::operator=(Code code) -> Id& { m_code = code; return *this; }

inline auto Id::operator< (Id const& eco) const -> bool { return m_code <  eco.m_code; }
inline auto Id::operator==(Id const& eco) const -> bool { return m_code == eco.m_code; }
inline auto Id::operator!=(Id const& eco) const -> bool { return m_code != eco.m_code; }

inline Id::operator Code () const { return m_code; }

inline auto Id::operator++() -> Id { return Id(++m_code); }
inline auto Id::operator--() -> Id { return Id(--m_code); }

inline auto Id::isRoot() const -> bool			{ return m_code == m_root; }
inline auto Id::isBasicCode() const -> bool	{ return !isExtendedCode(); }

inline auto Id::code() const -> Code			{ return m_code; }
inline auto Id::basic() const -> Code			{ return Code(m_code >> Sub_Code_Bits); }
inline auto Id::extension() const -> Code		{ return m_code ? (m_code - 1) & (Num_Sub_Codes - 1) : 0; }
inline auto Id::group() const -> Group			{ return Group((m_code >> Sub_Code_Bits)/100); }
inline auto Id::root() -> Id						{ return m_root; }


inline
auto Id::asShort() const -> uint16_t
{
	return m_code ? ((m_code - 1) >> Sub_Code_Bits) + 1 : 0;
}


inline
auto Id::isExtendedCode() const -> bool
{
	return m_code && ((m_code - 1) & (Num_Sub_Codes - 1));
}


inline
void Id::setup(char letter, uint16_t number)
{
	m_code = (100*(letter - 'A') + number) << Sub_Code_Bits;
}


inline
auto Id::fromShort(uint16_t code) -> Id
{
	return Id(code ? (uint32_t(code - 1) << Sub_Code_Bits) + 1 : 0);
}

} // namespace eco

// vi:set ts=3 sw=3:
