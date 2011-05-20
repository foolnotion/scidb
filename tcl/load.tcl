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
# Copyright: (C) 2010-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval load {
namespace eval mc {

set FileIsCorrupt "File %s is corrupt:"

}

variable currentFile {}
variable photoFile {}
variable LastMsg ""


proc source {args} {
	variable LastMsg
	variable currentFile

	if {[llength $args] == 2} {
		lassign $args msg path

		if {$msg ne $LastMsg} {
			::splash::print "${msg}..."
			set LastMsg $msg
		}
	} else {
		set path [lindex $args 0]
		set msg ""
	}

	if {[string match {.sp[ai]} [file extension $path]]} {
		set [namespace current]::photoFile [file rootname $path].spf
	}

	set currentFile $path

	if {[catch {uplevel ::source [list $path]} err]} {
		::log::error [format $mc::FileIsCorrupt $path]
		::log::error $err
	} elseif {[string length $msg]} {
		::log::info "$msg: $path"
	}
}


proc load {msg type path} {
	variable LastMsg

	if {$msg ne $LastMsg} {
		::splash::print "${msg}..."
		set LastMsg $msg
	}

	set currentFile $path

	if {[catch {::scidb::app::load $type $path} err]} {
		set msg [format $mc::FileIsCorrupt $path]
		::log::error $msg
		::log::error $err
		puts "$msg -- $err"
	} else {
		::log::info "$msg: $path"
	}
}

} ;# namespace load


# log will be closed in end.tcl
::log::open "Startup" 0

# --- Load ECO file ----------------------------------------------------
load::load	"Loading ECO file" \
				eco \
				[file join $scidb::dir::data eco.bin] \
				;

# --- Load engines -----------------------------------------------------
load::load	"Loading engine file" \
				comp \
				[file join $scidb::dir::data engines.txt] \
				;

if {[lsearch $argv "--fast"] == -1} {

# --- Load spellcheck files --------------------------------------------
foreach file {ratings_utf8.ssp.zip ratings-additional.ssp} {
	load::load	"Loading spellcheck files" \
					ssp \
					[file join $scidb::dir::data $file] \
					;
}

# --- Load FIDE players ------------------------------------------------
load::load	"Loading FIDE player file" \
				fide \
				[file join $scidb::dir::data players_list.zip] \
				;

if {[lsearch $argv "--elo-only"] == -1} {

# --- Load IPS rating list ---------------------------------------------
load::load	"Loading IPS rating list" \
				ips \
				[file join $scidb::dir::data ips-ratings.txt] \
				;

# --- Load DWZ rating list ---------------------------------------------
load::load	"Loading DWZ rating list" \
				dwz \
				[file join $scidb::dir::data dwz-ratings.txt] \
				;

# --- Load ECF rating list ---------------------------------------------
load::load	"Loading ECF rating list" \
				ecf \
				[file join $scidb::dir::data ecf-ratings.txt] \
				;

# --- Load ICCF rating list ---------------------------------------------
load::load	"Loading ICCF rating list" \
				iccf \
				[file join $scidb::dir::data iccf-ratings.txt] \
				;

} ;# if {[lsearch $argv "--elo-only"] == -1}

# --- Load Wikipedia links ---------------------------------------------
foreach lang {de en} {
	load::load	"Loading Wikipedia links" \
					wiki \
					[file join $scidb::dir::data wikipedia-${lang}.txt] \
					;
}

# --- Load chessgames.com links ----------------------------------------
load::load	"Loading chessgames.com links" \
				cgdc \
				[file join $scidb::dir::data chessgames.com.zip] \
				;

# --- Load cities ------------------------------------------------------
load::load	"Loading cities" \
				site \
				[file join $scidb::dir::data cities.txt] \
				;

# --- Load photo index files -------------------------------------------
if {[lsearch $argv "--no-photos"] == -1} {

foreach basedir [list $::scidb::dir::share $::scidb::dir::user] {
	if {[file isdirectory $basedir]} {
		foreach idx [glob -directory [file join $basedir photos] -nocomplain *.spi] {
			if {[file readable $idx]} {
				if {[file readable [file rootname $idx].spf]} {
					load::source "Loading photo index" $idx
				}
			}
		}
	}
}

proc addPhotoAlias {alias name} {
	set name [string map {. "" " " "" - ""} [string tolower $name]]
	if {[info exists photo_Player($name)]} {
		set alias [string map {. "" " " "" - ""} [string tolower $alias]]
		set photo_Player($alias) $photo_Player($name)
	} elseif {[info exists photo_Engine($name)]} {
		set alias [string map {. "" " " "" - ""} [string tolower $alias]]
		set photo_Engine($alias) $photo_Engine($name)
	}
}
foreach spa [glob -directory [file join $::scidb::dir::share photos] -nocomplain *.spa] {
	if {[file readable $spa]} {
		load::source "Loading photo index" $spa
	}
}

foreach idx [glob -directory [file join $::scidb::dir::user photos] -nocomplain *.spi] {
	if {[file readable $idx]} {
		if {[file readable [file rootname $idx].spf]} {
			load::source "Loading photo index" $idx
		}
	}
}

} ;# if {[lsearch $argv "--no-photos"] == -1}

} ;# if {[lsearch $argv "--fast"] == -1}

# --- Load localization file -------------------------------------------
set file [file join $scidb::dir::share lang localization.tcl]
if {[file readable $file]} {
	source -encoding utf-8 $file
}

# --- Load piece sets --------------------------------------------------
::log::info "Loading piece sets..."

foreach file [glob -directory [file join $::scidb::dir::share pieces] -nocomplain *.tcl] {
	load::source $file
}

# --- Load themes ------------------------------------------------------
::log::info "Loading themes..."

foreach file [glob -directory [file join $::scidb::dir::user themes piece] -nocomplain *.dat] {
	load::source $file
}

foreach file [glob -directory [file join $::scidb::dir::user themes square] -nocomplain *.dat] {
	load::source $file
}

foreach file [glob -directory [file join $::scidb::dir::user themes] -nocomplain *.dat] {
	load::source $file
}

set file [file join $::scidb::dir::share textures preferences.dat]
if {[file readable $file]} { load::source $file }

# --- Load done --------------------------------------------------------
::scidb::app::load done

# vi:set ts=3 sw=3:
