# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2010-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval widget {
namespace eval progressbar {

proc build {parent} {
	set w $parent._progress_
	tk::canvas $w -width 259 -height 20 -bh white -relief sunken -border 2
	$w create rectangle 0 0 0 16 -fill blue -outline blue -tags bar
	return $w
}


proc update {parent n} {
	$w._progress_ coords bar 0 0 $n 16
}

} ;# namespace progressbar
} ;# namespace widget

# vi:set ts=3 sw=3:
