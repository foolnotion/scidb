#!/bin/sh
#\
exec tclsh "$0" "$@"
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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tcl 8.5

if {$argc != 1} {
	puts stderr "Usage: [info script] <new-txt-file>"
	exit 1
}

set file [lindex $argv 0]
set ext [file extension $file]

if {[string length $ext] == 0} {
	append file .txt
} elseif {$ext ne ".txt"} {
	puts stderr "File '$file' should have extension '.txt'."
	exit 1
}

if {[file exists $file]} {
	puts stderr "File '$file' is already existing."
	exit 1
}

set out [open $file w]

puts $out \
"<!-- **********************************************************************
* Author : \$Author\$
* Version: \$Revision\$
* Date   : \$Date\$
* Url    : \$URL\$
*********************************************************************** -->

<!-- **********************************************************************
* Copyright: (C) 2011 Gregor Cramer
*********************************************************************** -->

<!-- **********************************************************************
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*********************************************************************** -->

INDEX Any Index Entry
TITLE Any Title


END

# vi:set ts=2 sw=2 et filetype=html:"

close $out

# vi:set ts=3 sw=3:
