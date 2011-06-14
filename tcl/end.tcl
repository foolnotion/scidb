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

# --- Special popups for BETA version only -----------------------------

namespace eval beta {

variable Welcome 0
#array set NotYetImplemented {}


proc welcomeToScidb {parent} {
	variable Welcome

	if {$Welcome} { return }

	set hdr(de) "Willkommen zu Scidb!"
	set hdr(en) "Welcome to Scidb!"
	set hdr(es) "Welcome to Scidb!"
	set hdr(it) "Welcome to Scidb!"

	set msg(de) "Dies ist eine Vorabversion von Scidb zum Ausprobieren und Testen. Die erste Vollversion wird erst nach einer genügend langen Testphase erscheinen. Beim Ausprobieren dieser Version sollte folgendes berücksichtigt werden:

1. Diese Version enthält viele Debugging-Informationen und ist an einigen Stellen noch entsprechend langsam.

2. Die Unterstützung der Scid-Datenbanken (.si3/.si4) erfolgt durch eine recht komplexe Emulation, die noch nicht genügend ausgetestet ist. Also bitte nicht die Original-Scid-Datenbanken mit diesem Programm bearbeiten. Standardmäßig werden die Scid-Datenbanken nur im Lesemodus, der natürlich unkritisch ist, geöffnet.

3. Das aktuelle Scidb-Format (.sci) wird spätestens mit der ersten Vollversion vollendet (d.h. Versionsnummer 1.0 erreichen, die aktuelle Versionsnummer ist 0.9). Das aktuelle Format ist aber bereits einsetzbar und es wird eine Upgrade-Möglichkeit geben.

4. Die Unterstützung des ChessBase-Formats (.cbh) ist noch nicht vollendet. Zur Zeit können z.B. keine Schach-960 Partien gelesen werden.

Viel Freude mit Scidb, dessen Entwicklung bisher bereits drei Jahre in Anspruch genommen hat!"
#-------------------------------------------------------------------------------------------------
	set msg(en) "This is a preliminary version of Scidb for try-out and testing. The first fuill version will be released after a sufficiently long test period. Please consider while experimenting with Scidb:

1. This version contains a lot of debugging information and is accordingly slow at several places.

2. The support of Scid databases (.si3/.si4) is performed by a quite complex emulation which is not yet sufficiently tested. Therefore please do not edit your original Scid databases with this program. Per default the Scid databases will be opened in read-only mode, which is of course uncritical.

3. The current Scidb format (.sci) will be finished at latest with the first full version (i.e. it will reach version 1.0 later, the current version is 0.9). Nevertheless the current format is already usable, and there will be offered an upgrade capability.

4. The support of the ChessBase format (.cbh) is not yet finished. Currently this application cannot open Chess 960 games.

Have a lot of fun with Scidb, whose development has already taken three years!"
#-------------------------------------------------------------------------------------------------
	set msg(es) "This is a preliminary version of Scidb for try-out and testing. The first fuill version will be released after a sufficiently long test period. Please consider while experimenting with Scidb:

1. This version contains a lot of debugging information and is accordingly slow at several places.

2. The support of Scid databases (.si3/.si4) is performed by a quite complex emulation which is not yet sufficiently tested. Therefore please do not edit your original Scid databases with this program. Per default the Scid databases will be opened in read-only mode, which is of course uncritical.

3. The current Scidb format (.sci) will be finished at latest with the first full version (i.e. it will reach version 1.0 later, the current version is 0.9). Nevertheless the current format is already usable, and there will be offered an upgrade capability.

4. The support of the ChessBase format (.cbh) is not yet finished. Currently this application cannot open Chess 960 games.

Have a lot of fun with Scidb, whose development has already taken three years!"
#-------------------------------------------------------------------------------------------------
	set msg(it) "This is a preliminary version of Scidb for try-out and testing. The first fuill version will be released after a sufficiently long test period. Please consider while experimenting with Scidb:

1. This version contains a lot of debugging information and is accordingly slow at several places.

2. The support of Scid databases (.si3/.si4) is performed by a quite complex emulation which is not yet sufficiently tested. Therefore please do not edit your original Scid databases with this program. Per default the Scid databases will be opened in read-only mode, which is of course uncritical.

3. The current Scidb format (.sci) will be finished at latest with the first full version (i.e. it will reach version 1.0 later, the current version is 0.9). Nevertheless the current format is already usable, and there will be offered an upgrade capability.

4. The support of the ChessBase format (.cbh) is not yet finished. Currently this application cannot open Chess 960 games.

Have a lot of fun with Scidb, whose development has already taken three years!"

	set reply [::dialog::info -message $hdr($::mc::langID) -detail $msg($::mc::langID) -parent $parent]
	if {$reply eq "ok"} { set Welcome 1 }
}


proc notYetImplemented {parent what} {
#	variable NotYetImplemented

#	if {[info exists NotYetImplemented($what)]} { return }

	set hdr(de) "Noch nicht implementiert."
	set hdr(en) "Not yet implemented."
	set hdr(es) "Not yet implemented."
	set hdr(it) "Not yet implemented."

	set msg(de) "Diese Funktionalität ist noch nicht implementiert worden, sie dient nur zur Voransicht."
	set msg(en) "This functionality is not yet implemented. This is only a preview."
	set msg(es) "This functionality is not yet implemented. This is only a preview."
	set msg(it) "This functionality is not yet implemented. This is only a preview."

	::dialog::info -message $hdr($::mc::langID) -detail $msg($::mc::langID) -parent $parent
#	set NotYetImplemented($what) 1
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Welcome
#	::options::writeItem $chan [namespace current]::NotYetImplemented
}

::options::hookWriter [namespace current]::WriteOptions

}

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
	::options::writeList $chan ::dialog::choosecolor::UserColorList
	::options::writeItem $chan ::dialog::fsbox::showHiddenBtn
	::options::writeItem $chan ::table::options
	::options::writeItem $chan ::menu::Theme
	puts $chan "::dialog::fsbox::setBookmarks {[::dialog::fsbox::getBookmarks]}"
}
::options::hookWriter [namespace current]::WriteOptions

# --- Read options -----------------------------------------------------

if {[file readable $::scidb::file::options]} {
	::load::source $::scidb::file::options -message $::load::mc::ReadingOptionsFile -encoding utf-8
}

# --- Initalization ----------------------------------------------------

#if {[llength $::engine::Engines] == 0} {
#	foreach entry {
#		{
#			Name			Stockfish
#			Elo			0
#			CCRL			0
#			Command		stockfish-191-32-ja
#			Parameters	{}
#			Logo			stockfish
#			Url			http://www.stockfishchess.com/download/all/index.html
#			Protocol		UCI
#			Options		{}
#			Timestamp	0
#		}
#		{
#			Name			Crafty
#			Elo			0
#			CCRL			0
#			Command		crafty
#			Parameters	{}
#			Logo			crafty
#			Url			ftp://ftp.cis.uab.edu/pub/hyatt
#			Protocol		WB
#			Options		{}
#			Timestamp	0
#		}
#		{
#			Name			Fruit
#			Elo			0
#			CCRL			0
#			Command		fruit
#			Parameters	{}
#			Logo			fruit
#			Url			http://www.fruitchess.com
#			Protocol		UCI/FRC
#			Options		{}
#			Timestamp	0
#		}
#		{
#			Name			Phalanx
#			Elo			0
#			CCRL			0
#			Command		phalanx
#			Parameters	{}
#			Logo			phalanx
#			Url			http://phalanx.sourceforge.net
#			Protocol		WB
#			Options		{}
#			Timestamp	0
#		}
#		{
#			Name			{Gullydeckel 2}
#			Elo			0
#			CCRL			0
#			Command		gully2
#			Parameters	{}
#			Logo			gully2
#			Url			http://borriss.com
#			Protocol		WB
#			Options		{}
#			Timestamp	0
#		}
#		{
#			Name			Micro-Max
#			Elo			0
#			CCRL			0
#			Command		micromax
#			Parameters	{}
#			Logo			micromax
#			Url			http://home.hccnet.nl/h.g.muller/max-src2.html
#			Protocol		WB
#			Options		{}
#			Timestamp	0
#		}} {
#
#		array set arr $entry
#		set arr(Directory) $::scidb::dir::user
#		set arr(Command) "[file join $::scidb::dir::share engines $arr(Command)]"
#
#		if {[file executable $arr(Command)]} {
#			::engine::engine $entry
#		}
#	}
#}

::theme::setTheme $::menu::Theme
::menu::setup
::board::setupTheme
::tooltip::init
::mc::selectLang
::font::useLanguage $mc::langID

application::open

# vi:set ts=3 sw=3:
