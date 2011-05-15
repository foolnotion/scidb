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

# --- Initalization ----------------------------------------------------

if {[tk windowingsystem] eq "x11"} {
	proc NoWindowDecor {w} {
		update idletasks
		::scidb::tk::wm noDecor $w
	}

	proc ::dialog::choosecolor::x11NoWindowDecor {w} { NoWindowDecor $w }
	proc ::toolbar::x11NoWindowDecor {w} { NoWindowDecor $w }
}

set dialog::iconOk			$icon::iconOk
set dialog::iconCancel		$icon::iconCancel
set dialog::iconGoNext		$icon::iconGoNext
set dialog::iconYes			$icon::iconOk

set dialog::choosefont::iconOk		$icon::iconOk
set dialog::choosefont::iconCancel	$icon::iconCancel
set dialog::choosefont::iconApply	$icon::iconApply
set dialog::choosefont::iconReset	$icon::iconReset

proc ::dialog::choosefont::messageBox {parent msg buttons defaultButton} {
	return [::dialog::warning -parent $parent -message $msg -buttons $buttons -default $defaultButton]
}

set dialog::choosecolor::iconOk		$icon::iconOk
set dialog::choosecolor::iconCancel	$icon::iconCancel

proc ::dialog::choosecolor::tooltip {args} { ::tooltip::tooltip {*}$args }

proc ::calendar::tooltip {args} { ::tooltip::tooltip {*}$args }

proc ::scrolledframe::sbset {w first last} { ::widget::sbset $w $first $last }

set ::dialog::fsbox::showHiddenBtn	1
set ::dialog::fsbox::showHiddenVar	0
set ::dialog::fsbox::destroyOnExit	1
set ::dialog::fsbox::iconAdd			$icon::iconAdd
set ::dialog::fsbox::iconRemove		$icon::iconRemove
set ::dialog::fsbox::iconSave			$icon::iconSave
set ::dialog::fsbox::iconCancel		$icon::iconCancel
set ::dialog::fsbox::iconOpen			$icon::iconOpen

proc ::dialog::fsbox::makeStateSpecificIcons {img} { return [::icon::makeStateSpecificIcons $img] }
proc ::dialog::fsbox::tooltip {args} { ::tooltip::tooltip {*}$args }
proc ::dialog::fsbox::messageBox {args} { return [::dialog::messageBox {*}$args] }

dialog::fsbox::setupIcon ".sci"	$::icon::16x16::filetypeScidbBase
dialog::fsbox::setupIcon ".si4"	$::icon::16x16::filetypeScid4Base
dialog::fsbox::setupIcon ".si3"	$::icon::16x16::filetypeScid3Base
dialog::fsbox::setupIcon ".cbh"	$::icon::16x16::filetypeChessBase
dialog::fsbox::setupIcon ".pgn"	$::icon::16x16::filetypePGN
dialog::fsbox::setupIcon ".gz"	$::icon::16x16::filetypePGN
dialog::fsbox::setupIcon ".zip"	$::icon::16x16::filetypeZipFile

proc ::dialog::progressbar::busyCursor {w state} { ::widget::busyCursor $w $state }

proc ::colormenu::tooltip {args} { ::tooltip::tooltip {*}$args }

proc WriteOptions {chan} {
	::options::writeItem $chan ::dialog::choosecolor::UserColorList
	::options::writeItem $chan ::dialog::fsbox::showHiddenBtn
	::options::writeItem $chan ::table::options
	::options::writeItem $chan ::menu::Theme
	puts $chan "::dialog::fsbox::setBookmarks {[::dialog::fsbox::getBookmarks]}"
}
::options::hookWriter [namespace current]::WriteOptions

# --- Read options -----------------------------------------------------

if {[file readable $::scidb::file::options]} {
	::load::source "Reading options file" $::scidb::file::options
	# close log opened in load.tcl
	::log::info "Startup finished"
	::log::close
}

# --- Initalization ----------------------------------------------------

if {[llength $::engine::Engines] == 0} {
	foreach entry {
		{
			Name			Stockfish
			Elo			0
			CCRL			0
			Command		stockfish-191-32-ja
			Parameters	{}
			Logo			stockfish
			Url			http://www.stockfishchess.com/download/all/index.html
			Protocol		UCI
			Options		{}
			Timestamp	0
		}
		{
			Name			Crafty
			Elo			0
			CCRL			0
			Command		crafty
			Parameters	{}
			Logo			crafty
			Url			ftp://ftp.cis.uab.edu/pub/hyatt
			Protocol		WB
			Options		{}
			Timestamp	0
		}
		{
			Name			Fruit
			Elo			0
			CCRL			0
			Command		fruit
			Parameters	{}
			Logo			fruit
			Url			http://www.fruitchess.com
			Protocol		UCI/FRC
			Options		{}
			Timestamp	0
		}
		{
			Name			Phalanx
			Elo			0
			CCRL			0
			Command		phalanx
			Parameters	{}
			Logo			phalanx
			Url			http://phalanx.sourceforge.net
			Protocol		WB
			Options		{}
			Timestamp	0
		}
		{
			Name			{Gullydeckel 2}
			Elo			0
			CCRL			0
			Command		gully2
			Parameters	{}
			Logo			gully2
			Url			http://borriss.com
			Protocol		WB
			Options		{}
			Timestamp	0
		}
		{
			Name			Micro-Max
			Elo			0
			CCRL			0
			Command		micromax
			Parameters	{}
			Logo			micromax
			Url			http://home.hccnet.nl/h.g.muller/max-src2.html
			Protocol		WB
			Options		{}
			Timestamp	0
		}} {

		array set arr $entry
		set arr(Directory) $::scidb::dir::user
		set arr(Command) "[file join $::scidb::dir::share engines $arr(Command)]"

		if {[file executable $arr(Command)]} {
			::engine::engine $entry
		}
	}
}

::theme::setTheme $::menu::Theme
::menu::setup
::board::setupTheme
::tooltip::init
::mc::selectLang
::font::useLanguage $mc::langID

application::open

# vi:set ts=3 sw=3:
