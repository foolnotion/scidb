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

#ifndef _eco_id_included
#define _eco_id_included

#include "u_base.h"

#include "m_string.h"

namespace eco {

class Id
{
public:

	enum Group { A, B, C, D, E };

	enum { Bit_Size_Per_Subcode = 20u };
	enum { Sub_Code_Bits = 12u };
	enum { Num_Sub_Codes = 1u << Sub_Code_Bits };
	enum { Num_Basic_Codes = 5u*10u*10u };
	enum { Num_Codes = Num_Basic_Codes*Num_Sub_Codes };
	enum { Max_Code = Num_Basic_Codes*Num_Sub_Codes };
	enum { Num_Groups = unsigned(E) + 1u };

	using Code = uint32_t;

	Id();
	explicit Id(char const* s);
	explicit Id(Code code);
	Id(Code basic, Code extension);

	auto operator=(Code code) -> Id&;

	auto operator< (Id const& eco) const -> bool;
	auto operator==(Id const& eco) const -> bool;
	auto operator!=(Id const& eco) const -> bool;

	operator Code () const;

	auto operator++() -> Id;
	auto operator--() -> Id;

	bool isRoot() const;
	bool isExtendedCode() const;
	bool isBasicCode() const;

	auto code() const -> Code;
	auto basic() const -> Code;
	auto extension() const -> Code;
	auto group() const -> Group;
	auto asShort() const -> uint16_t;

	void convert(char* buf, bool shortForm = false) const;
	void setup(char const* s);
	void setup(char letter, uint16_t number);

	auto asString() const -> mstl::string;
	auto asShortString() const -> mstl::string;

	static auto root() -> Id;
	static auto asShort(char const* s) -> uint16_t;
	static auto fromShort(uint16_t code) -> Id;

private:

	Code m_code;

	static Id const m_root;
};

} // namespace eco

namespace mstl {

template <typename T> struct is_pod;
template <> struct is_pod<eco::Id> { enum { value = 1 }; };

} // namespace mstl

#include "eco_id.ipp"

#endif // _eco_id_included

// vi:set ts=3 sw=3:
