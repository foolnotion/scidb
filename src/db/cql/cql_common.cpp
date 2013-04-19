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

#include "cql_common.h"

#include "m_string.h"
#include "m_assert.h"

#include <stdlib.h>
#include <string.h>

using namespace db::country;


namespace {

struct CountryLookup
{
	char const*			code;
	db::country::Code	result;
};

} // namespace


static int
compareCountryCodes(void const* lhs, const void* rhs)
{
	return ::strncasecmp(static_cast<char const*>(lhs), static_cast<CountryLookup const*>(rhs)->code, 2);
}


db::country::Code
cql::country::lookupIso3166_2(mstl::string const& s)
{
	M_REQUIRE(s.size() == 2);

	static ::CountryLookup const Table[] =
	{
		{ "ad", Andorra },
		{ "ae", United_Arab_Emirates },
		{ "af", Afghanistan },
		{ "ag", Antigua },
		{ "ai", Anguilla },
		{ "al", Albania },
		{ "am", Armenia },
		{ "an", Netherlands_Antilles },
		{ "ao", Angola },
		{ "aq", Antarctica },
		{ "ar", Argentina },
		{ "as", American_Samoa },
		{ "at", Austria },
		{ "au", Australia },
		{ "aw", Aruba },
		{ "ax", Aaland_Islands },
		{ "az", Azerbaijan },
		{ "ba", Bosnia_and_Herzegovina },
		{ "bb", Barbados },
		{ "bd", Bangladesh },
		{ "be", Belgium },
		{ "bf", Burkina_Faso },
		{ "bg", Bulgaria },
		{ "bh", Bahrain },
		{ "bi", Burundi },
		{ "bj", Benin },
		{ "bm", Bermuda },
		{ "bn", Brunei },
		{ "bo", Bolivia },
		{ "br", Brazil },
		{ "bs", Bahamas },
		{ "bt", Bhutan },
		{ "bv", Bouvet_Islands },
		{ "bw", Botswana },
		{ "by", Belarus },
		{ "bz", Belize },
		{ "ca", Canada },
		{ "cc", Cocos_Islands },
		{ "cd", DR_Congo },
		{ "cf", Central_African_Republic },
		{ "cg", Congo },
		{ "ch", Switzerland },
		{ "ci", Ivory_Coast },
		{ "ck", Cook_Islands },
		{ "cl", Chile },
		{ "cm", Cameroon },
		{ "cn", China },
		{ "cn", Tibet },
		{ "co", Colombia },
		{ "cr", Costa_Rica },
		{ "cs", Serbia_and_Montenegro },
		{ "cu", Cuba },
		{ "cv", Cape_Verde },
		{ "cx", Christmas_Island },
		{ "cy", Cyprus },
		{ "cz", Czech_Republic },
		{ "de", Germany },
		{ "dj", Djibouti },
		{ "dk", Denmark },
		{ "dm", Dominica },
		{ "do", Dominican_Republic },
		{ "dz", Algeria },
		{ "ec", Ecuador },
		{ "ee", Estonia },
		{ "eg", Egypt },
		{ "eh", Western_Sahara },
		{ "er", Eritrea },
		{ "es", Spain },
		{ "et", Ethiopia },
		{ "fi", Finland },
		{ "fj", Fiji },
		{ "fk", Falkland_Islands },
		{ "fm", Micronesia },
		{ "fo", Faroe_Islands },
		{ "fr", France },
		{ "ga", Gabon },
		{ "gb", Great_Britain },
		{ "gd", Grenada },
		{ "ge", Georgia },
		{ "gf", French_Guiana },
		{ "gg", Guernsey },
		{ "gh", Ghana },
		{ "gi", Gibraltar },
		{ "gl", Greenland },
		{ "gm", Gambia },
		{ "gn", Guinea },
		{ "gp", Guadeloupe },
		{ "gq", Equatorial_Guinea },
		{ "gr", Greece },
		{ "gs", South_Georgia_and_South_Sandwich_Islands },
		{ "gt", Guatemala },
		{ "gu", Guam },
		{ "gw", Guinea_Bissau },
		{ "gy", Guyana },
		{ "hk", Hong_Kong },
		{ "hm", Heard_Island_and_McDonald_Islands },
		{ "hn", Honduras },
		{ "hr", Croatia },
		{ "ht", Haiti },
		{ "hu", Hungary },
		{ "id", Indonesia },
		{ "ie", Ireland },
		{ "il", Israel },
		{ "im", Isle_of_Man },
		{ "in", India },
		{ "io", British_Indian_Ocean_Territory },
		{ "iq", Iraq },
		{ "ir", Iran },
		{ "is", Iceland },
		{ "it", Italy },
		{ "je", Jersey },
		{ "jm", Jamaica },
		{ "jo", Jordan },
		{ "jp", Japan },
		{ "ke", Kenya },
		{ "kg", Kyrgyzstan },
		{ "kh", Cambodia },
		{ "ki", Kiribati },
		{ "km", Comoros },
		{ "kn", Saint_Kitts_and_Nevis },
		{ "kp", North_Korea },
		{ "kr", South_Korea },
		{ "kw", Kuwait },
		{ "ky", Cayman_Islands },
		{ "kz", Kazakhstan },
		{ "la", Laos },
		{ "lb", Lebanon },
		{ "lc", Saint_Lucia },
		{ "li", Liechtenstein },
		{ "lk", Sri_Lanka },
		{ "lr", Liberia },
		{ "ls", Lesotho },
		{ "lt", Lithuania },
		{ "lu", Luxembourg },
		{ "lv", Latvia },
		{ "ly", Libya },
		{ "ma", Morocco },
		{ "mc", Monaco },
		{ "md", Moldova },
		{ "me", Montenegro },
		{ "mg", Madagascar },
		{ "mh", Marshall_Islands },
		{ "mk", Macedonia },
		{ "ml", Mali },
		{ "mm", Myanmar },
		{ "mn", Mongolia },
		{ "mo", Macao },
		{ "mp", Northern_Mariana_Islands },
		{ "mq", Martinique },
		{ "mr", Mauritania },
		{ "ms", Montserrat },
		{ "mt", Malta },
		{ "mu", Mauritius },
		{ "mv", Maldives },
		{ "mw", Malawi },
		{ "mx", Mexico },
		{ "my", Malaysia },
		{ "mz", Mozambique },
		{ "na", Namibia },
		{ "nc", New_Caledonia },
		{ "ne", Niger },
		{ "nf", Norfolk_Island },
		{ "ng", Nigeria },
		{ "ni", Nicaragua },
		{ "nl", Netherlands },
		{ "no", Norway },
		{ "np", Nepal },
		{ "nr", Nauru },
		{ "nu", Niue },
		{ "nz", New_Zealand },
		{ "om", Oman },
		{ "pa", Panama },
		{ "pe", Peru },
		{ "pf", French_Polynesia },
		{ "pg", Papua_New_Guinea },
		{ "ph", Philippines },
		{ "pk", Pakistan },
		{ "pl", Poland },
		{ "pm", Saint_Pierre_and_Miquelon },
		{ "pn", Pitcairn_Islands },
		{ "pr", Puerto_Rico },
		{ "ps", Palestine },
		{ "pt", Portugal },
		{ "pw", Palau },
		{ "py", Paraguay },
		{ "qa", Qatar },
		{ "re", Reunion },
		{ "ro", Romania },
		{ "rs", Serbia },
		{ "ru", Russia },
		{ "rw", Rwanda },
		{ "sa", Saudi_Arabia },
		{ "sb", Solomon_Islands },
		{ "sc", Seychelles },
		{ "sd", Sudan },
		{ "se", Sweden },
		{ "sg", Singapore },
		{ "sh", Saint_Helena },
		{ "si", Slovenia },
		{ "sj", Jan_Mayen_and_Svalbard },
		{ "sk", Slovakia },
		{ "sl", Sierra_Leone },
		{ "sm", San_Marino },
		{ "sn", Senegal },
		{ "so", Somalia },
		{ "sr", Suriname },
		{ "st", Sao_Tome_and_Principe },
		{ "su", Soviet_Union },
		{ "sv", El_Salvador },
		{ "sy", Syria },
		{ "sz", Swaziland },
		{ "tc", Turks_and_Caicos_Islands },
		{ "td", Chad },
		{ "tf", French_Southern_Territories },
		{ "tg", Togo },
		{ "th", Thailand },
		{ "tj", Tajikistan },
		{ "tk", Tokelau },
		{ "tl", Timor_Leste },
		{ "tm", Turkmenistan },
		{ "tn", Tunisia },
		{ "to", Tonga },
		{ "tr", Turkey },
		{ "tt", Trinidad_and_Tobago },
		{ "tv", Tuvalu },
		{ "tw", Chinese_Taipei },
		{ "tz", Tanzania },
		{ "ua", Ukraine },
		{ "ug", Uganda },
		{ "um", United_States_Minor_Outlying_Islands },
		{ "us", United_States_of_America },
		{ "uy", Uruguay },
		{ "uz", Uzbekistan },
		{ "va", Vatican },
		{ "vc", Saint_Vincent_and_the_Grenadines },
		{ "ve", Venezuela },
		{ "vg", British_Virgin_Islands },
		{ "vi", US_Virgin_Islands },
		{ "vn", Vietnam },
		{ "vu", Vanuatu },
		{ "wf", Wallis_and_Futuna },
		{ "ws", Samoa },
		{ "ye", Yemen },
		{ "yt", Mayotte },
		{ "yu", Yugoslavia },
		{ "za", South_Africa },
		{ "zm", Zambia },
		{ "zw", Zimbabwe },
	};

	void const* p = ::bsearch(	s.c_str(),
										Table,
										U_NUMBER_OF(Table),
										sizeof(Table[0]),
										compareCountryCodes);

	if (p && ::strncasecmp(s, static_cast<CountryLookup const*>(p)->code, 2))
		return static_cast<CountryLookup const*>(p)->result;

	return Unknown;
}

// vi:set ts=3 sw=3:
