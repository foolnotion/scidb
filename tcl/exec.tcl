#!/bin/sh
#! ======================================================================
#! $RCSfile: tk_init.h,v $
#! $Revision$
#! $Date$
#! $Author: gregor $
#! ======================================================================

#! ======================================================================
#!    _/|            __
#!   // o\         /    )           ,        /    /
#!   || ._)    ----\---------__----------__-/----/__-
#!   //__\          \      /   '  /    /   /    /   )
#!   )___(     _(____/____(___ __/____(___/____(___/_
#! ======================================================================

#! ======================================================================
#! Copyright: (C) 2009-2012 Gregor Cramer
#! ======================================================================

#! ======================================================================
#! This program is free software; you can redistribute it and/or modify
#! it under the terms of the GNU General Public License as published by
#! the Free Software Foundation; either version 2 of the License, or
#! (at your option) any later version.
#! ======================================================================

#! The "\" at the end of the comment line below is necessary! It means
#! that the "exec" line is a comment to Tcl/Tk, but not to /bin/sh.
#! The next line restarts using tkscidb: \
exec `dirname $0`/tk`basename $0` "$0" ${1+"$@"}

package require Tcl 8.5
package require Tk  8.5
package require Ttk
package require tkscidb


namespace eval remote {
	variable blocked 1
	variable postponed 0
}


namespace eval scidb {
	set app		Scidb
	set version "1.0 BETA"
}


wm withdraw .


set nameofexecutable [info nameofexecutable]
if {[llength $nameofexecutable] == 0} {
	if {$tcl_platform(platform) eq "unix"} {
		catch { set nameofexecutable [exec readlink /proc/[pid]/exe] }
	}
	if {[llength $nameofexecutable] == 0} {
		# broken Tk library, e.g. 8.6b2
		append msg "You've installed a broken Tcl/Tk library (version [info patchlevel]). "
		append msg "Please change the version (8.5.6 is recommended)."
		tk_messageBox -type ok -icon error -title "$scidb::app: broken library" -message $msg
		exit 1
	}
}
set nameofexecutable [file normalize $nameofexecutable]


if {[::scidb::misc::version] ne $scidb::version} {
	wm withdraw .
	if {$tcl_platform(platform) eq "windows"} {
		append msg "This is $scidb::app version [::scidb::misc::version], but the scidb.gui "
		append msg "data file has the version number $scidb::version."
	} else {
		append msg "This is $scidb::app version '$scidb::version', but the "
		append msg "[file tail $nameofexecutable] program it uses is "
		append msg "version '[::scidb::misc::version]'."
	}
	tk_messageBox -type ok -icon error -title "$scidb::app: version error" -message $msg
	exit 1
}


if {[info patchlevel] eq "8.5.10"} {
	# broken Tk library (e.g. Ubuntu 11.10)
	append msg "You've installed a broken Tk library (patch level [info patchlevel]). "
	append msg "Some crashes may occur with this Tk library.\n\n"
	append msg "It is recommended to use a different patch level of this library."
	append msg "(Version 8.5.6 is recommended.)"
	tk_messageBox -type ok -icon error -title "$scidb::app: broken library" -message $msg
}


namespace eval process {

set ProgramOptions [list                                                                     \
	[list "--"                      "Only file names after this"]                             \
	[list "--help"                  "Print help (this message) and exit"]                     \
	[list "--version"               "Print version information and exit"]                     \
	[list "--full-screen"           "Start program with full-screen modus"]                   \
	[list "--show-board"            "Switch to board tab immediately after startup"]          \
	[list "--re-open"               "Re-open databases from last session"]                    \
	[list "--fast-load"             "Do only load the mandatory files at startup"]            \
	[list "--first-time"            "Delete option file and recovery files at startup"        \
	                                "(starting $::scidb::app as it would be the first time)"] \
	[list "--elo-only"              "Do not load rating files except ELO rating"]             \
	[list "--print-recovery-files"  "Print recovery files from last session and exit"]        \
	[list "--delete-recovery-files" "Delete recovery files and exit"]                         \
	[list "--dont-recover"          "Do not recover unsaved games from last session"]         \
	[list "--recover-old"           "Recover games from older sessions"                       \
	                                "(will skip games from last session)"]                    \
	[list "--single-process"        "Forcing a single process of $::scidb::app"               \
	                                "(you shouldn't use this option; only for testing)"]      \
	[list "--update-player-photos"  "Update/install player photos"]                           \
	[list "--force-grab"            "Do not suppress grabs in debug mode"                     \
	                                "(only for debugging)"]                                   \
]

array set Options {}
variable Arguments {}


proc arguments {} { return [set [namespace current]::Arguments] }


proc testOption {arg} {
	set rc 0
	catch { set rc [set [namespace current]::Options($arg)] }
	return $rc
}


proc setOption {arg {value 1}} {
	set [namespace current]::Options($arg) $value
}


proc ParseArgs {} {
	global argc argv
	variable Options
	variable Arguments
	variable ProgramOptions

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {$arg eq "--"} {
			incr i
			break
		}
		if {[string range $arg 0 1] ne "--"} {
			break
		}

		set option [string range $arg 2 end]
		set Options($option) 1

		if {[lsearch -exact -index 0 $ProgramOptions $arg] == -1} {
			puts stderr "Unrecognized option: $arg"
		}
	}

	if {[::scidb::misc::debug?]} {
		set Options(single-process) 1
	}

	set Arguments [lrange $argv $i end]
}

ParseArgs


if {[testOption help]} {
	puts "$::scidb::app version $::scidb::version"
	puts ""
	puts "Usage: $::argv0 \[options ...] \[database ...]"
	puts ""
	puts "Options:"

	set maxlen 0
	foreach opts $ProgramOptions {
		set maxlen [expr {max($maxlen, [string length [lindex $opts 0]])}]
	}
	foreach opts $ProgramOptions {
		set i 0
		foreach s $opts {
			if {$i == 0} {
				puts -nonewline "  "
				puts -nonewline $s
				set spaces [expr {$maxlen + 1 - [string length $s]}]
			} else {
				puts -nonewline [string repeat " " $spaces]
				puts $s
				set spaces [expr {$maxlen + 3}]
			}
			incr i
		}
	}

	puts ""
	puts "Options recognised by GUI (Tk) library:"
	puts "  -geometry GEOMETRY      Use GEOMETRY for initial geometry"
	puts "  -display DISPLAY        Run $::scidb::app on DISPLAY"
	puts "  -sync                   Use synchronous mode for display server"
	exit 0
}

if {0 && [testOption update-player-photos]} {
	proc inform {what args} {
		switch $what {
			file {
				puts -nonewline .
			}
			timeout {
				puts ""
				puts $::util::photos::mc::TimeoutOut
				puts $::util::photos::mc::UpdateAborted
			}
			error {
				lassign $args file msg
				puts ""
				puts [format $::util::photos::mc::ErrorOccurred $msg]
				puts $::util::photos::mc::UpdateAborted
			}
		}
	}

	lassign [::util::photos::updateFiles [namespace current]::inform] state msg
	if {$state eq "error"} {
		puts [format $::util::photos::mc::ErrorOccurred $msg]
		puts $::util::photos::mc::UpdateAborted
	}
}

unset ProgramOptions

} ;# namespace process


namespace eval remote {
namespace eval mc {

set PostponedMessage "Opening of database \"%s\" is postponed until current operation will be finished."

}


array set Vars {
	after		{}
	pending	{}
	busy		0
}


proc pending? {} {
	variable blocked
	variable postponed
	variable Vars

	return [expr {!$blocked && !$Vars(busy) && $postponed}]
}


proc busyOperation {cmd} {
	variable Vars
	variable postponed

	incr Vars(busy)
	set code [catch {uplevel 1 $cmd} res]
	incr Vars(busy) -1
	if {$postponed} {
		after idle [namespace code update]
	}
	return -code $code $res
}


proc update {} {
	variable Vars

	if {[pending?]} {
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code Update]]
	}
}


proc cleanup {} {
	set [namespace current]::Vars(pending) {}
}


proc requestOpenBases {pathList} {
	variable blocked
	variable postponed
	variable Vars

	if {[llength $pathList]} {
		if {$blocked} {
			foreach path $pathList {
				if {![info exists Vars(infoBox:$path)]} {
					set postponed 1
					lappend Vars(pending) $path
					set msg [format $mc::PostponedMessage $path]
					set Vars(infoBox:$path) \
						[::dialog::info -buttons {} -title $::scidb::app -message $msg -topmost yes]
				}
			}
		} else {
			openBases $pathList
		}
	}
}


proc Update {} {
	variable blocked
	variable postponed
	variable Vars

	if {[llength $Vars(pending)] == 0} { return }

	foreach path $Vars(pending) {
		if {[info exists Vars(infoBox:$path)]} {
			if {[winfo exists $Vars(infoBox:$path)]} {
				destroy $Vars(infoBox:$path)
			}
			unset Vars(infoBox:$path)
		}
	}

	set files $Vars(pending)
	set Vars(pending) {}
	set postponed 0
	openBases $files
}


proc SendPath {port} {
	global argc
	global argv

	set args {}

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]

		if {[string index $arg 0] ne "-"} {
			lappend args $arg
		}
	}
	
	set chan [socket 127.0.0.1 $port]
	puts $chan $args
	flush $chan
	close $chan
}


proc Incoming {chan addr port} {
#	fconfigure $chan -blocking 0
	fileevent $chan readable [namespace code [list IncomingOffered $chan]]
}


proc IncomingOffered {chan} {
	if {[gets $chan pathList] >= 0} {
		fileevent $chan readable {}
#		fconfigure $chan -blocking 1
		after idle [namespace code [list requestOpenBases $pathList]]
	}
}


#proc Vwait {varname} {
#	variable ::remote::blocked
#
#	set blocked 1
#	set code [catch {uplevel 1 [list ::remote::VwaitOrig $varname]} res]
#	set blocked 0
#
#	after idle ::remote::update
#	return -code $code $res
#}
#
#rename ::vwait ::remote::VwaitOrig
#rename ::remote::Vwait ::vwait


if {	![::process::testOption single-process]
	&& ![::process::testOption version]
	&& ![::process::testOption print-recovery-files]} {

	# Pick a port number based on the name of the main script executing
	set port [expr {1024 + [::scidb::misc::crc32 [file normalize $::argv0]] % 30000}]

	if {[catch {socket -server [namespace code Incoming] -myaddr localhost $port} err]} {
		lassign $::errorCode cls name
		if {$cls eq "POSIX" && $name eq "EADDRINUSE"} {
			SendPath $port
			exit 1
		}
	}
}

} ;# namespace remote

# vi:set ts=3 sw=3:
