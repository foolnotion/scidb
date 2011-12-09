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

set revision 83 ;# first revision ever

variable clipbaseName		[::scidb::db::get clipbase name]
variable scratchbaseName	[::scidb::db::get scratchbase name]

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
set photos	[file join $share photos]
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

} ;# namespace file

proc updateThemes {} {
	foreach dir {{} piece square} {
		set themesDir [file join $::scidb::dir::user themes $dir]
		foreach file [glob -nocomplain -directory [file join $::scidb::dir::share themes $dir] *.dat] {
			catch { file copy -force $file $themesDir }
		}
	}
}

} ;# namespace scidb


if {[::process::testOption version]} {
	puts "$::scidb::app version $::scidb::version"
	if {[file readable $::scidb::file::options]} {
		puts "option file: $::scidb::file::options"
	}
	puts "exec directory: $::scidb::dir::exec"
	puts "share directory: $::scidb::dir::share"
	exit 0
}


if {[::process::testOption print-recovery-files]} {
	foreach file [glob -directory $::scidb::dir::backup -nocomplain game-*.pgn] {
		if {[file readable $file]} { puts $file }
	}
	exit 0
}

if {[::process::testOption delete-recovery-files]} {
	foreach file [glob -directory $::scidb::dir::backup -nocomplain game-*.pgn] {
		file rename -force $file $file.bak
	}
	exit 0
}

if {[::process::testOption first-time]} {
	::scidb::updateThemes
	file delete $::scidb::file::options
	::process::setOption dont-recover
	set ::scidb::dir::setup 1
}


namespace eval mc {}

tk appname $scidb::app

toplevel .application -class $::scidb::app
wm withdraw .application

if {[::scidb::misc::debug?]} {
	::process::setOption single-process
	if {[tk windowingsystem] eq "x11"} { ::scidb::tk::wm sync }
	if {![::process::testOption force-grab]} { proc grab {args} {} }
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
namespace eval mc {

set IOErrorOccurred					"I/O Error occurred"

set IOError(OpenFailed)				"open failed"
set IOError(ReadOnly)				"database is read-only"
set IOError(UnknownVersion)		"unknown file version"
set IOError(UnexpectedVersion)	"unexpected file version"
set IOError(Corrupted)				"corrupted file"
set IOError(WriteFailed)			"write operation failed"
set IOError(InvalidData)			"invalid data (file possibly corrupted)"
set IOError(ReadError)				"read error"
set IOError(EncodingFailed)		"cannot write namebase file"
set IOError(MaxFileSizeExceeded)	"maximal file size reached"
set IOError(LoadFailed)				"load failed (too many event entries)"

}

set Extensions		{.sci .si4 .si3 .cbh .pgn .zip}
set clipbaseName	Clipbase

proc databaseName {base} {
	variable clipbaseName

	if {$base eq [::scidb::db::get clipbase name]} {
		return $clipbaseName
	}

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


proc catchIoError {base cmd {resultVar {}}} {
	if {[catch {{*}$cmd} result options]} {
		array set opts $options
		if {[string first %IO-Error% $opts(-errorinfo)] >= 0} {
			lassign $opts(-errorinfo) type file error what
			set descr ""
			if {[info exists mc::IOError($error)]} {
				set descr $mc::IOError($error)
			} else {
				set descr "???"
			}
			set msg $mc::IOErrorOccurred
			if {[string length $descr]} {
				append msg ": "
				append msg $descr
			}
			set what [string toupper $what 0 0]
			set i [string first "=== Backtrace" $what]
			if {$i >= 0} { set what [string range $what 0 [incr i -1]] }
			set what [string trim $what]
			::dialog::error \
				-parent .application \
				-message $msg \
				-detail [string toupper $what 0 0] \
				-topmost 1 \
				;
			return 1
		}
		return -code $opts(-code) -errorcode $opts(-errorcode) -rethrow 1 $result
	}
	if {[llength $resultVar]} {
		uplevel 1 [list set $resultVar $result]
	}
	return 0
}

} ;# namespace util


namespace eval remote {

proc openBase {pathList} {
	raise .application

	if {[llength $pathList]} {
		foreach path $pathList {
			::application::database::openBase .application [::util::databasePath $path] no
		}
	}

	after idle [::remote::update]
}

} ;# namespace remote

# vi:set ts=3 sw=3:
