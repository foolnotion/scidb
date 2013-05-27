# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

# ======================================================================
# Copyright: (C) 2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source clipboard

namespace eval clipboard {

variable CurrentSelection ""

variable window "."


proc selectText {text {buffer CLIPBOARD}} {
	variable window

	if {[tk windowingsystem] eq "x11"} {
		if {$buffer eq "PRIMARY"} {
			variable CurrentSelection
			set CurrentSelection $text

			selection handle -selection PRIMARY $window [namespace current]::PrimaryTransfer
			selection own -selection PRIMARY -command [namespace current]::LostSelection $window
			return
		}
	}

	clipboard clear -displayof $window
	clipboard append -displayof $window $text
}


proc getSelection {{buffer CLIPBOARD}} {
	variable window

	if {[tk windowingsystem] eq "x11"} {
		if {[catch { selection get -selection $buffer -type UTF8_STRING -timeout 20 } str]} {
			return ""
		}
		return $str
	}

	return [clipboard get -displayof $window]
}


if {[tk windowingsystem] eq "x11"} {

	proc PrimaryTransfer {offset maxChars} {
		variable CurrentSelection
		return [string range $CurrentSelection $offset [expr {$offset + $maxChars - 1}]]
	}


	proc LostSelection {} {
		variable CurrentSelection
		set CurrentSelection ""
	}

}

} ;# namespace clipboard

# vi:set ts=3 sw=3:
