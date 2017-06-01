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
# Copyright: (C) 2010-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source load-management

namespace eval load {
namespace eval mc {

set SevereError				"Severe error during load of ECO file"
set FileIsCorrupt 			"File %s is corrupt:"
set ProgramAborting			"Program is aborting."
set EngineSetupFailed		"Loading engine configuration failed"

set Loading						"Loading %s"
set StartupFinished			"Startup finished"
set SystemEncoding			"System encoding is '%s'"

set ReadingFile(options)	"Reading options file"
set ReadingFile(engines)	"Reading engines file"

set ECOFile						"ECO file"
set EngineFile					"engine file"
set SpellcheckFile			"spell-check file"
set LocalizationFile			"localization file"
set RatingList					"%s rating list"
set WikipediaLinks			"Wikipedia links"
set ChessgamesComLinks		"chessgames.com links"
set Cities						"cities"
set PieceSet					"piece set"
set Theme						"theme"
set Icons						"icons"

}

variable currentFile {}
variable photoFile {}

variable LastMsg	""
variable Log		{}


proc source {path args} {
	variable LastMsg
	variable Log
	variable currentFile

	array set opts { -message "" -encoding "" -throw 0 }
	array set opts $args
	set msg $opts(-message)

	if {[string length $msg]} {
		if {$msg ne $LastMsg} {
			::splash::print "${msg}..."
			set LastMsg $msg
		}
	}

	set currentFile $path
	set enc {}
	if {[string length $opts(-encoding)]} { set enc [list -encoding $opts(-encoding)] }

	if {$opts(-throw)} {
		uplevel ::source {*}$enc [list $path]
	} elseif {[catch {uplevel ::source {*}$enc [list $path]} err]} {
		lappend Log error [format $mc::FileIsCorrupt $path] error $err
	} elseif {[string length $msg]} {
		lappend Log info "$msg: $path"
	}

	update idletasks
}


proc load {msg type path} {
	variable LastMsg
	variable Log

	if {$msg ne $LastMsg} {
		::splash::print "${msg}..."
		set LastMsg $msg
	}

	set currentFile $path

	if {[catch {::scidb::app::load $type $path} err]} {
		set msg [format $mc::FileIsCorrupt $path]
		if {$type eq "eco"} {
			append str $mc::SevereError .\n $msg \n\n $mc::ProgramAborting
			set detail ""
			if {$type eq "eco"} {
				append detail "This error may occur due to a defect executable, caused by a broken linker."
				append detail "\n\n"
				append detail "Please change to your installation directory of Scidb and invoke"
				append detail "\n   > make check-build\n"
				append detail "for further details."
			}
			dialog::error -message $str -detail $detail
			exit 1
		} else {
			lappend Log error $msg error $err
		}
		puts "$msg -- $err"
	} else {
		lappend Log info "$msg: $path"
	}

	update idletasks
}


proc writeLog {} {
	variable Log

	::log::info [format $mc::SystemEncoding [encoding system]]
	foreach {type msg} $Log { log::$type $msg }
	array unset Log
	::log::info $mc::StartupFinished
	::log::close
}


proc write {} {
	set chan [open [file join $scidb::dir::config load.tcl] w]
	fconfigure $chan -encoding utf-8

	foreach name [info vars ::load::mc::*] {
		if {[array exists $name]} {
			foreach attr [array names $name] {
				puts $chan "set ${name}($attr) \"[set ${name}($attr)]\""
			}
		} else {
			puts $chan "set $name \"[set $name]\""
		}
	}

	close $chan
}

} ;# namespace load


if {[file readable [file join $scidb::dir::config load.tcl]]} {
	catch { source -encoding utf-8 [file join $scidb::dir::config load.tcl] }
}


# log will be closed in end.tcl
::log::open "Startup" 0
#set t [clock microseconds]

# --- Load ECO file ----------------------------------------------------
load::load	[format $load::mc::Loading $load::mc::ECOFile] \
				eco \
				[file join $scidb::dir::data eco.bin] \
				;

if {![::process::testOption fast-load]} {

# --- Load spellcheck files --------------------------------------------
foreach file {ratings_utf8.ssp.zip ratings-additional.ssp} {
	load::load	[format $load::mc::Loading $load::mc::SpellcheckFile] \
					ssp \
					[file join $scidb::dir::data $file] \
					;
}

# --- Load engines -----------------------------------------------------
load::load	[format $load::mc::Loading $load::mc::EngineFile] \
				comp \
				[file join $scidb::dir::data engines.txt] \
				;

# --- Load FIDE players ------------------------------------------------
load::load	[format $load::mc::Loading [format $load::mc::RatingList FIDE]] \
				fide \
				[file join $scidb::dir::data players_list.zip] \
				;

if {![::process::testOption elo-only]} {

# --- Load rating lists ------------------------------------------------
foreach rating {IPS DWZ ECF ICCF} {
	set type [string tolower $rating]
	load::load	[format $load::mc::Loading [format $load::mc::RatingList $rating]] \
					$type \
					[file join $scidb::dir::data $type-ratings.txt] \
					;
}

} ;# if elo-only

# --- Load Wikipedia links ---------------------------------------------
foreach lang {de en} {
	load::load	[format $load::mc::Loading $load::mc::WikipediaLinks] \
					wiki \
					[file join $scidb::dir::data wikipedia-${lang}.txt] \
					;
}

# --- Load chessgames.com links ----------------------------------------
load::load	[format $load::mc::Loading $load::mc::ChessgamesComLinks] \
				cgdc \
				[file join $scidb::dir::data chessgames.com.zip] \
				;

# --- Load cities ------------------------------------------------------
load::load	[format $load::mc::Loading $load::mc::Cities] \
				site \
				[file join $scidb::dir::data cities.txt] \
				;

} ;# if fast-load

# --- Load localization file -------------------------------------------
set file [file join $scidb::dir::share lang localization.tcl]
if {[file readable $file]} {
	load::source $file -message [format $load::mc::Loading $load::mc::LocalizationFile] -encoding utf-8
}

# --- Load piece sets --------------------------------------------------
foreach file [glob -directory [file join $::scidb::dir::share pieces] -nocomplain *.tcl] {
	load::source $file -message [format $load::mc::Loading $load::mc::PieceSet]
}

set msg [format $load::mc::Loading $load::mc::Theme]

# --- Load themes ------------------------------------------------------
### Upgrade #######################################
set update 0
if {	[file exists [file join $::scidb::dir::user themes StonyGlass.dat]]
	|| [file exists [file join $::scidb::dir::user themes Mayan-1.dat]]} {
	file delete [file join $::scidb::dir::user themes BlueMono.dat]
	file delete [file join $::scidb::dir::user themes Blue.dat]
	file delete [file join $::scidb::dir::user themes Glassy&Red.dat]
	file delete [file join $::scidb::dir::user themes Marble.dat]
	file delete [file join $::scidb::dir::user themes Marmor.dat]
	file delete [file join $::scidb::dir::user themes Mayan-1.dat]
	file delete [file join $::scidb::dir::user themes Mayan-2.dat]
	file delete [file join $::scidb::dir::user themes Phoenix.dat]
	file delete [file join $::scidb::dir::user themes StonyGlass.dat]
	file delete [file join $::scidb::dir::user themes Wood.dat]
	file delete [file join $::scidb::dir::user themes square Blue.dat]
	file delete [file join $::scidb::dir::user themes square BlueMono.dat]
	file delete [file join $::scidb::dir::user themes square Marble-Classic.dat]
	file delete [file join $::scidb::dir::user themes square Marble-Red.dat]
	file delete [file join $::scidb::dir::user themes square Wood-Green.dat]
	file delete [file join $::scidb::dir::user themes piece MayanRed.dat]
	file delete [file join $::scidb::dir::user themes piece Yellow.dat]
	set update 1
}
if {[file exists [file join $::scidb::dir::user themes square Brown-Wood.dat]]} {
	file delete [file join $::scidb::dir::user themes square Brown-Wood.dat]
	set update 1
}
if {[file exists [file join $::scidb::dir::user themes BlueTheme.dat]]} {
	file delete [file join $::scidb::dir::user themes BlueTheme.dat]
	file delete [file join $::scidb::dir::user themes square BlueTheme.dat]
	set update 1
}
if {[file exists [file join $::scidb::dir::user themes Virtual.dat]]} {
	file delete [file join $::scidb::dir::user themes Virtual.dat]
	file delete [file join $::scidb::dir::user themes VirtualColored.dat]
}
if {	![file exists [file join $::scidb::dir::user themes Primus.dat]]
	|| ![file exists [file join $::scidb::dir::user themes Country-Style.dat]]
	|| ![file exists [file join $::scidb::dir::user themes Blackjack.dat]]
	|| ![file exists [file join $::scidb::dir::user themes VirtualBlue.dat]]
	|| ![file exists [file join $::scidb::dir::user themes Burnt.dat]]
	|| ![file exists [file join $::scidb::dir::user themes Creepy.dat]]} {
	set update 1
}
if {[::process::testOption first-time]} {
	set update 1
}
if {[::process::testOption update-themes]} {
	set update 1
}
if {$update} { ::scidb::themes::update }
if {[file exists [file join $::scidb::dir::user themes square Wood-Green.dat]]} {
	file delete [file join $::scidb::dir::user themes square Wood-Green.dat]
}
if {[file exists [file join $::scidb::dir::user themes square Brown-Wood.dat]]} {
	file delete [file join $::scidb::dir::user themes square Brown-Wood.dat]
}
unset update
###################################################

foreach subdir {piece square {}} {
	foreach file [glob -directory [file join $::scidb::dir::user themes {*}$subdir] -nocomplain *.dat] {
		load::source $file -message $msg
	}
}
unset msg

set file [file join $::scidb::dir::share textures preferences.dat]
if {[file readable $file]} { load::source $file }
unset file subdir

# --- Load done --------------------------------------------------------
::scidb::app::load done

#puts "[expr {[clock microseconds] - $t}] micro-secs"
#unset t

# Load time with empty cache: 6.76 s
# Load time with full cache:  2.68 s

# Load time of ECO file with empty cache: 0.51 s
# Load time of ECO file with full cache:  0.36 s

# vi:set ts=3 sw=3:
