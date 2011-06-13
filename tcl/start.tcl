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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

#set tcl_traceExec 1

namespace eval scidb {
namespace eval dir {

if {$tcl_platform(platform) eq "windows"} {
	set share $exec
} else {
	# already defined in tkscidb
}

set home		[file nativename "~"]
set exec		[file dirname [info nameofexecutable]]
set user		[file join $home .[string range [file tail [info nameofexecutable]] 2 end]]
set data		[file join $share data]
set backup	[file join $user backup]
set config	[file join $user config]

if {![file isdirectory $user]} {
	set setup 1
	file mkdir $user
	file mkdir [file join $user log]
	file mkdir [file join $user photos]
	file mkdir [file join $user backup]
	file copy  [file join $share themes] $user
} else {
	set setup 0
}

if {![file isdirectory $config]} {
	file mkdir $config
}

} ;# namespace dir

namespace eval file {

set options [file join [set [namespace parent]::dir::config] options.dat]

if {[::process::testOption from-the-scratch]} {
	file delete $options
}

} ;# namespace file
} ;# namespace scidb

namespace eval mc {}

wm withdraw .
tk appname $scidb::app

toplevel .application -class $::scidb::app
wm withdraw .application

if {[::scidb::misc::debug?]} {
#	proc grab {args} {}
	::process::setOption single-process
	if {[tk windowingsystem] eq "x11"} { ::scidb::tk::wm sync }
}

### need to predefine some namespaces ################################

namespace eval menu {}
namespace eval menu::mc {}

### some useful commands #############################################

# 'do {...} while {<condition>}' command
proc do {cmds while expr} {
	uplevel $cmds
	uplevel [list while $expr $cmds]
}


proc require {myNamespace requiredNamespaces} {
	foreach ns $requiredNamespaces {
		if {![namespace exists $ns]} {
			puts "WARNING($myNamespace): namespace ::$ns required"
		}
	}
}


namespace eval util {

set Extensions {.sci .si4 .si3 .cbh .pgn .zip}

proc databaseName {base} {
	set name [lindex [file split $base] end]
	set ext [file extension $name]
	set name [file rootname $name]
	
	switch -- $ext {
		.gz {
			set ext .pgn
			set name [file rootname $name]
		}
		.zip {
			set ext .pgn
		}
	}

	if {[string length $ext]} { append name " $ext" }
	return [string map {" " "\u2002"} $name]
}


proc formatResult {result} {
	if {$result eq "1/2-1/2"} { return "\u00bd-\u00bd" }
	return $result
}


proc doAccelCmd {accel keyState cmd} {
	switch -glob -- $accel {
		Alt-*		{ if {!($keyState & 8)} { return } }
		Ctrl-*	{ if {!($keyState & 4)} { return } }
		default	{ if {$keyState} { return } }
	}

	eval $cmd
}


proc clipboard {} {
	set selection ""
	catch { set selection [selection get] }
	return $selection
}


proc databasePath {file} {
	variable Extensions

	set ext [file extension $file]
	if {$ext ni $Extensions && ![string match {*.pgn.gz} $file]} {
		foreach ext $Extensions {
			set f "$file$ext"
			if {[file readable $f]} {
				return $f
			}
		}
	}

	return $file
}

} ;# namespace util


namespace eval remote {

proc openBase {pathList} {
	raise .application

	if {[llength $pathList]} {
		foreach path $pathList {
			::application::database::openBase .application [::util::databasePath $path]
		}
	}

	after idle [::remote::update]
}

} ;# namespace remote

# vi:set ts=3 sw=3:
