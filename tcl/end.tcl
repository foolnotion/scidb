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
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source initialization

# --- Special popups for BETA version only -----------------------------

namespace eval beta {

variable Welcome	0
variable WhatsNew	0

#array set NotYetImplemented {}


proc welcomeToScidb {parent} {
	variable Welcome
	variable WhatsNew

	if {!$Welcome} {
		::help::open .application Welcome
		set Welcome 1
	} elseif {$WhatsNew} {
		::help::open .application Whats-New
	}
}


proc notYetImplemented {parent what} {
#	variable NotYetImplemented

#	if {[info exists NotYetImplemented($what)]} { return }

	set hdr(de) [Enc "Noch nicht implementiert."]
	set hdr(en) [Enc "Not yet implemented."]
	set hdr(es) [Enc "Aún no implementado."]
	set hdr(it) [Enc "Non ancora implementato."]

	set msg(de) [Enc "Diese Funktionalität ist noch nicht implementiert worden, sie dient nur zur Voransicht."]
	set msg(en) [Enc "This functionality is not yet implemented. This is only a preview."]
	set msg(es) [Enc "Esta función aún no fue implementada. Esta es sólo una muestra preliminar."]
	set msg(it) [Enc "Questa funzione non è ancora implementata. Questa è solo un'anteprima."]

	::dialog::info -message $hdr($::mc::langID) -detail $msg($::mc::langID) -parent $parent
#	set NotYetImplemented($what) 1
}


proc Enc {s} { return [encoding convertfrom utf-8 $s] }


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Welcome
#	::options::writeItem $chan [namespace current]::NotYetImplemented
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace beta

# --- Initalization ----------------------------------------------------

if {[tk windowingsystem] eq "x11"} {
	namespace eval x11 {
		proc makeFrameless {w} {
			update idletasks
			::scidb::tk::wm menu $w
		}
		proc makeToolbar {w} {
			update idletasks
			::scidb::tk::wm toolbar $w
		}
	}

	proc toolbar::x11MakeToolbar {w} { ::x11::makeToolbar $w }
	proc fsbox::x11MakeFrameless {w} { ::x11::makeFrameless $w }
	proc tooltip::x11DropShadow {args} { ::x11::dropShadow {*}$args }
}

set dialog::iconOk		$icon::iconOk
set dialog::iconCancel	$icon::iconCancel
set dialog::iconGoNext	$icon::iconGoNext
set dialog::iconYes		$icon::iconOk

set dialog::choosefont::iconOk		$icon::iconOk
set dialog::choosefont::iconCancel	$icon::iconCancel
set dialog::choosefont::iconApply	$icon::iconApply
set dialog::choosefont::iconReset	$icon::iconReset

set dialog::progressbar::icon::16x16::stop $::icon::16x16::stop

set tk::ShadowOffset $::shadow::offset

proc dialog::choosefont::messageBox {parent title msg buttons defaultButton} {
	return [::dialog::warning \
		-parent $parent \
		-title $title \
		-message $msg \
		-buttons $buttons \
		-default $defaultButton \
	]
}

set dialog::choosecolor::iconOk		$icon::iconOk
set dialog::choosecolor::iconCancel	$icon::iconCancel

proc dialog::choosecolor::tooltip {args} { ::tooltip::tooltip {*}$args }

proc toolbar::makeStateSpecificIcons {img} { return [::icon::makeStateSpecificIcons $img] }

proc calendar::tooltip {args} { ::tooltip::tooltip {*}$args }

proc fsbox::makeStateSpecificIcons {img} { return [::icon::makeStateSpecificIcons $img] }
proc fsbox::tooltip {args} { return [::tooltip::tooltip {*}$args] }
proc fsbox::makeStateSpecificIcons {args} { return [::icon::makeStateSpecificIcons {*}$args] }
proc fsbox::busy {args} { ::widget::busyCursor on }
proc fsbox::unbusy {args} { ::widget::busyCursor off }
proc fsbox::configureRadioEntry {args} { ::theme::configureRadioEntry {*}$args }

proc dialog::progressbar::busyCursor {w state} { ::widget::busyCursor $w $state }

proc colormenu::tooltip {args} { ::tooltip::tooltip {*}$args }

proc WriteOptions {chan} {
	options::writeList $chan ::dialog::choosecolor::userColorList
	options::writeItem $chan ::table::options
	options::writeItem $chan ::menu::Theme
	options::writeItem $chan ::toolbar::Options
	options::writeItem $chan ::fsbox::bookmarks::Bookmarks
	options::writeItem $chan ::fsbox::Options
	options::writeItem $chan ::scidb::revision
}
options::hookWriter [namespace current]::WriteOptions

proc archive::setModTime {file time} { ::scidb::misc::setModTime $file $time }
proc archive::setInformation {progress msg} { ::dialog::progressbar::setInformation $progress ${msg}... }
proc archive::setMaxTick {progress n} { ::dialog::progressbar::setMaximum $progress $n }

proc archive::logError {msg detail} {
	::log::error $::mc::Archive $msg
	if {[string length $detail]} { ::log::info $::mc::Archive $detail }
}

proc archive::tick {progress n} {
	::dialog::progressbar::tick $progress $n
	update
}

proc scrolledframe::MapWindow {w} { ::scidb::misc::mapWindow $w }

log::finishLayout

# --- Read options -----------------------------------------------------

# prevent errors while parsing old config files (as long as we have a beta version)
proc dialog::fsbox::setBookmarks {args} {}

if {[file readable $::scidb::file::options]} {
	if {[catch {
			::load::source $::scidb::file::options -message $::load::mc::ReadingFile(options) -encoding utf-8 -throw 1
		}]} {
		unset ::setup::board::History
		set ::setup::board::History {}
		catch { source -encoding utf-8 $::scidb::file::options }
	}
}

if {[catch {
	if {![array exists ::setup::board::History]} {
		set history_ $::setup::board::History
		unset ::setup::board::History
		set ::setup::board::History(Normal) $history_
		unset history_
	}

	if {$::scidb::revision < [::scidb::misc::revision]} {
		if {$::scidb::revision == 83} {
			set ::export::RecentlyUsedHistory	{}
			set ::export::RecentlyUsedTiebreaks	{}
			set ::application::database::RecentFiles {}
			set ::game::History {}
			array unset ::export::Values
			array set ::export::Values [array get ::export::Defaults]
			set ::export::Values(Type) scidb
			set ::export::Values(pgn,encoding) iso8859-1
			set ::export::Values(scid,encoding) utf-8
			set ::export::Values(scidb,encoding) utf-8
			set ::export::Values(pdf,encoding) iso8859-1
			set ::crosstable::RecentlyUsedHistory {}
			set ::crosstable::MostRecentHistory {}
		}

		if {[::scidb::misc::revision] >= 96} {
			set ::crosstable::RecentlyUsedHistory {}
			set ::crosstable::MostRecentHistory {}
			array unset ::browser::Options font:bold
			array unset ::application::pgn::Options board-size
			array unset ::dialog::fsbox::Priv lastFolder
			array unset ::browser::Options font
			array unset ::browser::Options hilite
			array unset ::browser::Options background:current
			array unset ::browser::Options foreground:result
			array unset ::browser::Options foreground:empty
			array unset ::browser::Options style:*
			array unset ::browser::Options tabstop-*
			set ::browser::Options(board:size:ext) $::browser::Options(board:size)
			array unset ::load::mc::ChessgamesComLinks
			set ::export::Values(html,moves,notation) san
			set ::export::Values(pdf,moves,notation) san
			set ::export::Values(tex,moves,notation) san
			for {set i 0} {$i < [llength $::game::History]} {incr i} {
				set crc [lindex $::game::History $i 2 0]
				if {$crc < 0} { lset ::game::History $i 2 0 [expr {$crc + 4294967296}] }
				set crc [lindex $::game::History $i 2 1]
				if {$crc < 0} { lset ::game::History $i 2 1 [expr {$crc + 4294967296}] }
				set key [lindex $::game::History $i 1]
				lappend key Normal
				lset ::game::History $i 1 $key
			}
			switch $::board::currentTheme {
				Blue|1262882648418|yellow.color|gregor {
					set ::board::currentTheme Ocean|1262882648418|yellow.color|gregor
				}
				{Blue Mono|1354018040763|yellow.color|gregor} {
					set ::board::currentTheme {Blue Theme|1354018040763|yellow.color|gregor}
				}
				Marble|1243532376507|yellow.color|gregor {
					set ::board::currentTheme {Marble - Brown|1243532376507|yellow.color|gregor}
				}
				{Marble - Classic|1296049694406|yellow.color|gregor} {
					set ::board::currentTheme {Marble - Red|1296049745744|yellow.color|gregor}
				}
				Phoenix|1296049187980|yellow.color|gregor {
					set ::board::currentTheme Phoenix|1354101318690|purple|gregor
				}
				{Stony Glass|1243792200845|yellow.color|gregor} {
					set ::board::currentTheme Default
				}
			}
		}

		::scidb::themes::update
		set ::beta::WhatsNew 1
	}
}]} {
	puts "Start-up failed."
	puts "Please try \"[file tail $nameofexecutable] --first-time\"."
	exit 1
}

# migrate to new default theme
if {$scidb::revision < 701} {
	if {$board::currentTheme eq {Blue Theme|1354018040763|yellow.color|gregor}} {
		set board::currentTheme Default
	} elseif {$scidb::revision > 83 && $board::currentTheme eq "Default"} {
		set board::currentTheme {Primus|1368794511290|yellow.color|gregor}
	}
}

set ::scidb::revision [::scidb::misc::revision]

# --- Initalization ----------------------------------------------------

::mc::setup
::font::useLanguage $mc::langID

if {[::process::testOption first-time]} {
	::scidb::themes::update
}

::theme::setTheme $menu::Theme
::menu::setup
::board::setup
::tooltip::init
::font::setupChessFonts
application::open

# vi:set ts=3 sw=3:
