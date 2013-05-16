// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#ifndef _util_emoticons_included
#define _util_emoticons_included

#include "sys_utf8.h"

namespace mstl { class string; }

namespace util {
namespace emoticons {

enum Emotion
{
	Smile,
	Frown,
	Neutral,
	Grin,
	Gleeful,
	Wink,
	Confuse,
	Shock,
	Grumpy,
	Upset,
	Cry,
	Surprise,
	Red,
	Eek,
	Yell,
	Roll,
	Blink,

	Sweat,
	Razz,
	Sleep,

	Saint,
	Evil,
	Cool,
	Glasses,
	Kiss,
	Kitty,

	LAST = Kitty,
};


mstl::string const& toAscii(Emotion emotion);
bool lookupEmotion(char const* first, char const* last, Emotion& emotion);
char const* parseEmotion(char const*& first, char const* last, Emotion& emotion);

} // emoticons
} // util

#endif // _util_emoticons_included

// vi:set ts=3 sw=3:
