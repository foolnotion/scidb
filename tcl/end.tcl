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
# Copyright: (C) 2009-2018 Gregor Cramer
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
		::help::open .application Welcome -center 1
		set Welcome 1
	} elseif {$WhatsNew} {
		::help::open .application Whats-New -center 1
	} else {
		::tips::show .application
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
	::options::writeItem  $chan [namespace current]::Welcome
#	::options::writeItem  $chan [namespace current]::NotYetImplemented
	::options::writeItem  $chan ::theme::useCustomStyleMenuEntries
}
::options::hookWriter [namespace current]::WriteOptions

} ;# namespace beta

# --- Initialization ---------------------------------------------------

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
		proc changeDesktop {w} {
			if {[winfo exists .application]} {
				::scidb::tk::wm desktop .application
			} else {
				::scidb::tk::wm desktop .
			}
		}

		proc ::trash::urlDecode {str} { return [::scidb::misc::url unescape $str] }
		proc ::trash::urlEncode {str} { return [::scidb::misc::url escape $str] }
	}

	proc toolbar::x11MakeToolbar {w} { ::x11::makeToolbar $w }
	proc fsbox::makeFrameless {w} { update idletasks; ::scidb::tk::wm frameless $w }
	proc tooltip::x11DropShadow {args} { ::x11::dropShadow {*}$args }
	proc dialog::messagebox::changeDesktop {w type} { ::x11::changeDesktop $w }
}


proc dialog::messagebox::tokenize {msg} {
	return [scidb::misc::xml tokenize [append expr <xml> $msg </xml>]]
}

proc fsbox::dirIsEmpty {dir} { return [::scidb::misc::dirEmpty? $dir] }
proc fsbox::lookupColor {color} { return [::colors::lookup $color] }

proc tlistbox::lookupColor {color} { return [::colors::lookup $color] }

proc table::lookupColor {color} { return [::colors::lookup $color] }

set clipboard::window .application

set dialog::iconOk		$icon::iconOk
set dialog::iconCancel	$icon::iconCancel
set dialog::iconGoNext	$icon::iconGoNext
set dialog::iconYes		$icon::iconOk

set dialog::choosefont::iconOk		$icon::iconOk
set dialog::choosefont::iconCancel	$icon::iconCancel
set dialog::choosefont::iconApply	$icon::iconApply
set dialog::choosefont::iconReset	$icon::iconReset

set dialog::progressbar::icon::16x16::stop $::icon::16x16::stop

proc searchentry::makeStateSpecificIcons {img} { return [::icon::makeStateSpecificIcons $img] }

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
proc toolbar::configureCheckEntry {args} { return [::theme::configureCheckEntry {*}$args] }
proc toolbar::configureRadioEntry {args} { return [::theme::configureRadioEntry {*}$args] }

proc calendar::tooltip {args} { ::tooltip::tooltip {*}$args }

proc fsbox::makeStateSpecificIcons {img} { return [::icon::makeStateSpecificIcons $img] }
proc fsbox::tooltip {args} { return [::tooltip::tooltip {*}$args] }
proc fsbox::makeStateSpecificIcons {args} { return [::icon::makeStateSpecificIcons {*}$args] }
proc fsbox::busy {args} { ::widget::busyCursor on }
proc fsbox::unbusy {args} { ::widget::busyCursor off }
proc fsbox::mySort {args} { return [::scidb::misc::sort {*}$args] }
proc fsbox::configureRadioEntry {args} { return [::theme::configureRadioEntry {*}$args] }
proc fsbox::configureCheckEntry {args} { return [::theme::configureCheckEntry {*}$args] }

proc table::configureCheckEntry {args} { return [::theme::configureCheckEntry {*}$args] }

proc dialog::progressbar::busyCursor {w state} { ::widget::busyCursor $w $state }

proc colormenu::tooltip {args} { ::tooltip::tooltip {*}$args }

proc WriteOptions {chan} {
	options::writeList $chan ::dialog::choosecolor::userColorList
	options::writeItem $chan ::table::options
	options::writeItem $chan ::menu::Theme
	options::writeItem $chan ::colors::Scheme
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

proc twm::tr {tok} { return [set $tok] }
proc twm::tooltip {args} { ::tooltip::tooltip {*}$args }
proc twm::makeStateSpecificIcons {icon} { return [::icon::makeStateSpecificIcons $icon] }
proc twm::WriteOptions {chan} { ::options::writeItem $chan [twm::nameOfOptionsArray] }
::options::hookWriter twm::WriteOptions

proc ecobox::tooltip {args} { ::tooltip {*}$args }
proc ecobox::openEcoDialog {parent} { return [::application::eco::open $parent ecobox] }

rename ::table::setOptions ::table::setOptions_
# XXX work-around because of a bug in older versions
proc ::table::setOptions {args} {
	lassign $args id options
	setOptions_ $id $options
}

log::finishLayout

# --- Read options -----------------------------------------------------

# XXX preliminary for migration
proc ::gametable::setOptions {id opts} { return [::scrolledtable::setOptions $id $opts] }
proc ::eventtable::setOptions {id opts} { return [::scrolledtable::setOptions $id $opts] }
proc ::playertable::setOptions {id opts} { return [::scrolledtable::setOptions $id $opts] }
proc ::sitetable::setOptions {id opts} { return [::scrolledtable::setOptions $id $opts] }

# prevent errors while parsing old config files (as long as we have a beta version)
proc dialog::fsbox::setBookmarks {args} {}

if {[file readable $::scidb::file::options]} {
#	if {[catch {
			::load::source $::scidb::file::options -message $::load::mc::ReadingFile(options) -encoding utf-8 -throw 1
#		}]} {
#		unset ::setup::board::History
#		set ::setup::board::History {}
#		catch { source -encoding utf-8 $::scidb::file::options }
#	}
}

if {[catch {
	file mkdir [file join $::scidb::dir::user layout] ;# this is new

	if {![array exists ::setup::board::History]} {
		set history_ $::setup::board::History
		unset ::setup::board::History
		set ::setup::board::History(Normal) $history_
		unset history_
	}

	if {[info exists application::analysis::Options(engine:multiPV)]} {
		if {[set application::analysis::Options(engine:multiPV)] == 1} {
			set application::analysis::Options(engine:singlePV) 1
			set application::analysis::Options(engine:multiPV) 4
		}
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

		if {$::scidb::revision < 946} {
			foreach v {::pgn::browser::Colors ::pgn::editor::Colors} {
				foreach {f c} {	background				"#ffffff"
										background:current   "#ffdd76"
										background:nextmove  "#eeff00"
										foreground:bracket   "#0000ee"
										foreground:comment   "#006300"
										foreground:empty     "#666666"
										foreground:illegal   "#ee0000"
										foreground:info      "#b22222"
										foreground:marks     "#6300c6"
										foreground:nag       "#ee0000"
										foreground:nagtext   "#912a2a"
										foreground:numbering "#aa0acd"
										foreground:opening   "#000000"
										foreground:result    "#000000"
										foreground:variation "#0000ee"
										hilite:comment       "#7a5807"
										hilite:info          "#b22222"
										hilite:move          "#ebf4f5" } {
					set var ${v}($f)
					if {[info exists $var]} {
						if {[set $var] eq $c} { set $var pgn,$f }
					}
				}
			}
		}

		if {$::scidb::revision < 1493} {
			foreach attr {docking:showall layout:list layout:name} {
				if {[info exists ::application::Options($attr)]} {
					set ::application::twm::Options(board:$attr) $::application::Options($attr)
					array unset ::application::Options $attr
				}
			}
			set files [glob -directory $::scidb::dir::layout -nocomplain *.layout]
			if {[llength $files]} {
				set dest [file join $::scidb::dir::layout board]
				file mkdir $dest
				foreach file $files {
					set fd [open $file "r"]
					set data [read -nonewline $fd]
					close $fd
					set fd [open [file join $dest [file tail $file]] "w"]
					puts $fd "::application::twm::setup normal [file tail $dest] {$data}"
					close $fd
					file delete -force $file
				}
			}
			if {[info exists application::database::PreOpen]} {
				set list {}
				foreach entry $application::database::PreOpen {
					lappend list [lindex $entry 1]
				}
				set application::database::PreOpen $list
			}
			set ::twm::Options(deiconify:force) 0
		}

		foreach type {board games player event site annotator position} {
			if {[info exists ::application::twm::Options($type:layout:list)]} {
				set ::application::twm::Options($type:layout:list:normal) \
					$::application::twm::Options($type:layout:list)
			}
		}

		::scidb::themes::update
		set ::beta::WhatsNew 1
	}

	if {[llength $::comment::Geometry] == 4} {
		lassign $::comment::Geometry w h x y
		if {$w < 100 || $h < 50} {
			set w [expr {$w*10}]
			set h [expr {$h*10}]
			set ::comment::Geometry [list $w $h $x $y]
		}
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

if {$::application::board::Options(promoted:mark) eq "1"} {
	set ::application::board::Options(promoted:mark) bullet
} elseif {$::application::board::Options(promoted:mark) eq "0"} {
	set ::application::board::Options(promoted:mark) none
}

set ::scidb::revision [::scidb::misc::revision]

# --- Initalization ----------------------------------------------------

::splash::print "$load::mc::Startup..."
::mc::setup
::font::useLanguage $mc::langID
::theme::setTheme $menu::Theme
::menu::setup
::board::setup
::tooltip::init
::font::setupDefaultFonts
::font::setupChessFonts
#if {$beta::Welcome} { ::html::preload $mc::langID }
application::open

# vi:set ts=3 sw=3:
