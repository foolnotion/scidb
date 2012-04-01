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
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval menu {
namespace eval mc {

set Theme						"Theme"
set Ctrl							"Ctrl"
set Shift						"Shift"

set AllScidbFiles				"All Scidb files"
set AllScidbBases				"All Scidb databases"
set ScidBases					"Scid databases"
set ScidbBases					"Scidb databases"
set ChessBaseBases			"ChessBase databases"
set ScidbArchives				"Scidb archives"
set PGNFilesArchives			"PGN files/archives"
set PGNFiles					"PGN files"
set PGNArchives				"PGN archives"

set Language					"&Language"
set Toolbars					"&Toolbars"
set ShowLog						"&Show Log"
set AboutScidb					"&About Scidb"
set Fullscreen					"&Full-Screen"
set LeaveFullscreen			"Leave &Full-Screen"
set Help							"&Help"
set Contact						"&Contact (Web Browser)"
set Quit							"&Quit"

set ContactBugReport			"&Bug Report"
set ContactFeatureRequest	"&Feature Request"

set OpenFile					"Open a Scidb File"
set NewFile						"Create a Scidb File"
set ImportFiles				"Import PGN files..."
set CreateArchive				"Create an archive"

# do not need translation
set SettingsEnglish			"&English"

}


if {[info exists ::i18n::languages]} {
	foreach entry $::i18n::languages {
		set language [lindex $entry 0]
		if {[info exists ::mc::lang$language]} {
			set ::menu::mc::Settings$language "&$language"
		}
	}
}


set BugTracker					"http://sourceforge.net/tracker/?group_id=307371&atid=1294797"
set FeatureRequestTracker	"http://sourceforge.net/tracker/?group_id=307371&atid=1294800"

variable Fullscreen		0
variable HideMenu			0
variable Theme				default
variable Entry
variable SubMenu
variable MenuWidget


proc setup {} {
	bind .application <F1> [list ::menu::openHelp .application]
	bind .application <Control-l> [list ::log::show]
	bind .application <F11> [namespace code [list viewFullscreen toggle]]
	bind .application <Control-q> ::application::shutdown

	if {[::process::testOption full-screen]} { viewFullscreen toggle }
}


proc build {menu} {
	variable ::application::Options
	variable Fullscreen
	variable Theme

	### languages ############################################################
	set m [menu $menu.mLanguages]
	lassign [::tk::UnderlineAmpersand $mc::Language] text ul
	$menu add cascade \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::languages \
		-compound left \
		;
	foreach lang [lsort [array names ::mc::input]] {
		if {[string length $lang]} {
			set flag $::country::icon::flag([set ::mc::langToCountry([set ::mc::lang$lang])])
			$m add command \
				-label " $lang" \
				-image $flag \
				-compound left \
				-command [list ::mc::selectLang $lang] \
				;
		}
	}

	### icon size ############################################################
	set m [menu $menu.mIconSize]
	$menu add cascade \
		-menu $m \
		-label " $::toolbar::mc::IconSize" \
		-image $::icon::16x16::none \
		-compound left \
		;
	foreach size $::toolbar::iconSizes {
		set var ::toolbar::mc::[string toupper $size 0 0]
		set text [set $var]
		$m add radiobutton \
			-label $text \
			-variable ::toolbar::Options(icons:size) \
			-value $size \
			;
		::theme::configureRadioEntry $m $text
	}

	### theme ################################################################
	set m [menu $menu.mTheme]
	$menu add cascade \
		-menu $m \
		-label " $mc::Theme" \
		-image $::icon::16x16::none \
		-compound left \
		;
	set Theme [::theme::currentTheme]
	set styles [lsort -dictionary [ttk::style theme names]]
	set i [lsearch $styles default]
	if {$i >= 0} { set styles [linsert [lreplace $styles $i $i] 0 default] }
	foreach style $styles {
		if {$style ne "classic"} {
			$m add radiobutton \
				-label $style \
				-image $::icon::16x16::none \
				-compound left \
				-variable [namespace current]::Theme \
				-indicatoron off \
				-value $style \
				-command [list ::theme::setTheme $style]
			::theme::configureRadioEntry $m $style
		}
	}

	### toolbars #############################################################
	set m [menu $menu.mToolbars]
	lassign [::tk::UnderlineAmpersand $mc::Toolbars] text ul
	$menu add cascade \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::none \
		-compound left \
		;
	foreach parent [::toolbar::activeParents] {
		::toolbar::addToolbarMenu $m $parent none
	}

	### help #################################################################
	$menu add separator

	lassign [::tk::UnderlineAmpersand $mc::Help] text ul
	$menu add command \
		-compound left \
		-label " $text..." \
		-underline [incr ul] \
		-image $::icon::16x16::help \
		-accelerator "F1" \
		-command [list ::menu::openHelp .application] \
		;

	### about ################################################################
	set cmd [list ::info::openDialog .application]
	lassign [::tk::UnderlineAmpersand $mc::AboutScidb] text ul
	$menu add command \
		-compound left \
		-label " $text..." \
		-underline [incr ul] \
		-image $::icon::16x16::info \
		-command $cmd \
		;

	### show log #############################################################
	lassign [::tk::UnderlineAmpersand $mc::ShowLog] text ul
	$menu add command \
		-compound left \
		-label " $text..." \
		-underline [incr ul] \
		-image $::icon::16x16::log \
		-accelerator "${mc::Ctrl}+L" \
		-command ::log::show \
		;

	### contact ##############################################################
	set m [menu $menu.mContact]
	lassign [::tk::UnderlineAmpersand $mc::Contact] text ul
	$menu add cascade \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::contact \
		-compound left \
		;

	lassign [::tk::UnderlineAmpersand $mc::ContactBugReport] text ul
	$m add command \
		-compound left \
		-label $text \
		-underline $ul \
		-command [namespace code [list bugReport .application]] \
		;

	lassign [::tk::UnderlineAmpersand $mc::ContactFeatureRequest] text ul
	$m add command \
		-compound left \
		-label $text \
		-underline $ul \
		-command [namespace code [list featureRequest .application]] \
		;

	### fullscreen ###########################################################
	$menu add separator
	if {$Fullscreen} { set var LeaveFullscreen } else { set var Fullscreen }
	lassign [::tk::UnderlineAmpersand [set mc::$var]] text ul
	$menu add command \
		-compound left \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::fullscreen \
		-command [namespace code [list viewFullscreen toggle]] \
		-accelerator "F11" \
		;

	### quit #################################################################
	$menu add separator
	lassign [::tk::UnderlineAmpersand $mc::Quit] text ul
	$menu add command \
		-compound left \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::exit \
		-command ::application::shutdown \
		-accelerator "Ctrl+Q" \
		;
}


proc dbNew {parent} {
	set filetypes [list                             \
		[list $mc::ScidbBases		.sci]             \
		[list $mc::ScidBases			{.si4 .si3}]      \
		[list $mc::AllScidbBases	{.sci .si4 .si3}] \
	]
	set result [::dialog::saveFile \
		-parent $parent \
		-filetypes $filetypes \
		-geometry last \
		-defaultextension .sci \
		-defaultencoding utf-8 \
		-needencoding 1 \
		-title [set [namespace current]::mc::NewFile] \
	]

	if {[llength $result]} {
		::application::database::newBase $parent {*}$result
	}
}


proc dbOpen {parent} {
	set filetypes [list                                                            \
		[list $mc::AllScidbFiles		{.sci .si4 .si3 .cbh .scv .pgn .pgn.gz .zip}] \
		[list $mc::AllScidbBases		{.sci .si4 .si3 .cbh .scv}]                   \
		[list $mc::ScidbBases			.sci]                                         \
		[list $mc::ScidBases				{.si4 .si3}]                                  \
		[list $mc::ChessBaseBases		.cbh]                                         \
		[list $mc::ScidbArchives		{.scv}]                                       \
		[list $mc::PGNFilesArchives	{.pgn .pgn.gz .zip}]                          \
		[list $mc::PGNFiles				{.pgn .pgn.gz}]                               \
		[list $mc::PGNArchives			{.zip}]                                       \
	]
	set result [::dialog::openFile \
		-parent $parent \
		-filetypes $filetypes \
		-defaultextension .sci \
		-needencoding 1 \
		-geometry last \
		-title $mc::OpenFile \
	]

	if {[llength $result]} {
		lassign $result file encoding
		::application::database::openBase $parent $file yes $encoding
	}
}


proc dbCreateArchive {parent {base ""}} {
	if {[string length $base] == 0} { set base [::scidb::db::get name] }
	set filetypes [list	[list $mc::ScidbArchives {.scv}]]
	set result [::dialog::saveFile \
		-parent $parent \
		-filetypes $filetypes \
		-defaultextension .scv \
		-needencoding 0 \
		-geometry last \
		-title $mc::CreateArchive \
		-initialfile [file tail [file rootname $base]] \
	]
	if {[llength $result]} {
		set arch [lindex $result 0]
		set progress $parent.__p__
		if {[::scidb::db::get memoryOnly? $base]} {
			::dialog::progressbar::open $progress -mode indeterminate
			set streams {}
			foreach ext [::scidb::misc::suffixes "$base.sci"] { lappend streams "$base.$ext" }
			set cmd [list ::archive::packStreams \
				$arch \
				$streams \
				{sci} \
				zlib \
				[clock seconds] \
				[::scidb::db::count games $base] \
				[namespace current]::archive::Write \
				$progress \
			]
		} else {
			::dialog::progressbar::open $progress -mode determinate
			set files {}
			set rootname [file rootname $base]
			foreach ext [::scidb::misc::suffixes $base] {
				set f "$rootname.$ext"
				if {[file exists $f]} { lappend files $f }
			}
			set cmd [list ::archive::packFiles \
							$arch \
							$files \
							$progress \
							[namespace current]::archive::GetCompressionMethod \
							[namespace current]::archive::GetCount \
							::scidb::misc::mapExtension \
						]
		}
		if {[catch {{*}$cmd} err options]} {
			destroy $progress
			return {*}$options $result
		}
		destroy $progress
	}
}


proc dbImport {parent {base ""}} {
	set filetypes [list	[list $mc::PGNFilesArchives	{.pgn .pgn.gz .zip}] \
								[list $mc::PGNFiles				{.pgn .pgn.gz}] \
								[list $mc::PGNArchives			{.zip}] \
	]
	set title $mc::ImportFiles
	set result [::dialog::openFile \
		-parent $parent \
		-filetypes $filetypes \
		-defaultextension .pgn \
		-needencoding 1 \
		-geometry last \
		-title $title \
		-multiple yes \
	]
	if {[llength $result]} {
		if {[string length $base] == 0} { set base [::scidb::db::get name] }
		lassign $result files encoding
		::import::open $parent $base $files $title $encoding
		::application::database::refreshBase $base
	}
}


#proc dbImportOne {parent} {
#	set pos [::game::new $parent]
#	if {$pos >= 0} {
#		::application::switchTab board
#		::import::openEdit $parent $pos
#	}
#}


proc dbClose {parent} {
	::application::database::closeBase $parent
}


proc gameNew {parent {variant {}}} {
	if {[::game::new $parent] >= 0} {
		if {[string length $variant] == 0} {
			::scidb::game::clear [::scidb::game::query 9 fen]
		} else {
			::scidb::game::clear [::setup::shuffle $variant]
		}

		::application::switchTab board
	}
}


proc bugReport {parent} {
	::web::open $parent [set [namespace current]::BugTracker]
}


proc featureRequest {parent} {
	::web::open $parent [set [namespace current]::FeatureRequestTracker]
}


proc viewFullscreen {{toggle {}}} {
	variable Fullscreen

	if {[llength $toggle]} { set Fullscreen [expr {!$Fullscreen}] }
	wm attributes .application -fullscreen $Fullscreen
}


proc openHelp {parent {topic {}}} {
	::help::open $parent $topic
}

namespace eval archive {

proc GetCompressionMethod {ext} {
	switch $ext {
		gz - zip	{ set method raw  }
		default	{ set method zlib }
	}

	return $method
}


proc GetCount {file} {
	switch [file extension $file] {
		.sci - .si3 - .si4 - .cbh - .pgn - .gz {
			return [::scidb::misc::size $file]
		}
	}
	return 0
}


proc Write {file chan progress} {
	set ext [file extension $file]
	set base [file rootname $file]

	return [::scidb::db::write \
		$base \
		[string range $ext 1 end] \
		$chan \
		[namespace current]::Progress \
		$progress \
	]
}


proc Progress {cmd w {value 0}} {
	switch $cmd {
		start {
			::dialog::progressbar::setMaximum $w $value
			update
		}

		update - finish {
			::dialog::progressbar::tick $w
			update
		}

		ticks {
			return $::dialog::progressbar::ticks
		}

		interrupted? {
			return [::dialog::progressbar::interrupted? $w]
		}
	}
}

} ;# namespace archive
} ;# namespace menu

# vi:set ts=3 sw=3:
