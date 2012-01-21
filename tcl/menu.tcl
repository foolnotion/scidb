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

set File						"&File"
set Game						"&Game"
set View						"&View"
set Help						"&Help"

set FileOpen				"&Open..."
set FileOpenRecent		"Open &Recent"
set FileOpenURL			"Open &URL..."
set FileNew					"&New..."
set FileExport				"E&xport..."
set FileImport				"I&mport PGN files..."
set FileImportOne			"&Import one PGN game..."
set FileClose				"&Close"
set FileQuit				"&Quit"

set GameNew					"&New Game"
set GameNewChess960		"N&ew Game: Chess 960"
set GameNewChess960Sym	"Ne&w Game: Chess 960 (symmetrical only)"
set GameNewShuffle		"New &Game: Shuffle"
set GameSave				"&Save Game"
set GameReplace			"&Replace Game"
set GameReplaceMoves		"Replace &Moves Only"

set HelpAbout				"&About Scidb"
set HelpContents			"&Contents"
set HelpWhatsNew			"&What's New"
set HelpRoadmap			"&Roadmap"
set HelpContactInfo		"C&ontact Information"
set HelpBugReport			"&Bug Report (open in web browser)"
set HelpFeatureRequest	"&Feature Request (open in web browser)"

set ViewShowLog			"Show &Log..."
set ViewFullscreen		"Full-Screen"

set OpenFile				"Open a Scidb File"
set NewFile					"Create a Scidb File"
set ImportFiles			"Import PGN files"

set Theme					"Theme"
set Ctrl						"Ctrl"
set Shift					"Shift"

set AllScidbFiles			"All Scidb files"
set AllScidbBases			"All Scidb databases"
set ScidBases				"Scid databases"
set ScidbBases				"Scidb databases"
set ChessBaseBases		"ChessBase databases"
set PGNFilesArchives		"PGN files/archives"
set PGNFiles				"PGN files"
set PGNArchives			"PGN archives"

set FileNotAllowed		"Filename '%s' not allowed"
set TwoOrMoreDots			"Contains two or more consecutive dots."
set ForbiddenChars		"Contains forbidden character(s)."

set Settings				"&Settings"

# do not need translation
set SettingsEnglish		"&English"

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
variable Entries
variable MenuWidget


# TODO: create menu after Post event


proc CreateViewMenu {menu} {
	variable ::application::Options
	variable Fullscreen
	variable Theme

	if {[::process::testOption full-screen]} { viewFullscreen toggle }

	set m [menu $menu.mIconSize]
	set pos -1

	$menu add cascade -menu $m -label $::toolbar::mc::IconSize
	widget::menuTextvarHook $menu [incr pos] ::toolbar::mc::IconSize
	set index 0
	foreach size $::toolbar::iconSizes {
		set var ::toolbar::mc::[string toupper $size 0 0]
		set text [set $var]
		$m add radiobutton \
			-label $text \
			-variable ::toolbar::Options(icons:size) \
			-value $size \
			;
		::theme::configureRadioEntry $m $text
		widget::menuTextvarHook $m $index $var
		incr index
	}

	set m [menu $menu.mTheme]
	$menu add cascade -menu $m -label $mc::Theme
	widget::menuTextvarHook $menu [incr pos] [namespace current]::mc::Theme
	set Theme [::theme::currentTheme]
	set styles [lsort -dictionary [ttk::style theme names]]
	set i [lsearch $styles default]
	if {$i >= 0} { set styles [linsert [lreplace $styles $i $i] 0 default] }
	foreach style $styles {
		if {$style ne "classic"} {
			$m add radiobutton \
				-label $style \
				-variable [namespace current]::Theme \
				-indicatoron off \
				-value $style \
				-command [list ::theme::setTheme $style]
			::theme::configureRadioEntry $m $style
		}
	}
	
	$menu add separator
	incr pos
	set cmd [list ::log::show]
	$menu add command \
		-compound left \
		-image $::icon::16x16::log \
		-accelerator "${mc::Ctrl}+L" \
		-command $cmd \
		;
	widget::menuTextvarHook $menu [incr pos] [namespace current]::mc::ViewShowLog
	bind .application <Control-l> $cmd

	$menu add separator
	incr pos
	$menu add checkbutton \
		-compound left \
		-image $::icon::16x16::fullscreen \
		-command [namespace code viewFullscreen] \
		-accelerator "F11" \
		-variable [namespace current]::Fullscreen \
		;
	widget::menuTextvarHook $menu [incr pos] [namespace current]::mc::ViewFullscreen
	bind .application <F11> [namespace code [list viewFullscreen toggle]]
}


proc setup {} {
	variable Menu
	variable MenuWidget
	variable Entries

	lappend Menu \
		File	{	New				1	Ctrl+N			docNew			{ ::menu::dbNew .application }
					Open				1	Ctrl+O			docOpen			{ ::menu::dbOpen .application }
					Close				0	Ctrl+W			close				{ ::menu::dbClose .application }
					OpenURL			1	{}					internet			{ ::menu::dbOpenUrl .application }
					Export			1	Ctrl+X			fileExport		{ ::menu::dbExport .application }
					Import			1	Ctrl+P			filetypePGN		{ ::menu::dbImport .application }
					ImportOne		1	Ctrl+I			filetypePGN-1	{ ::menu::dbImportOne .application }
					--------------	-	-------------	--------------	---------------------------------
					Quit				0	Ctrl+Q			exit				{ ::application::shutdown }
				} \
		Game	{	New				1	Ctrl+X			document			{ ::menu::gameNew .application }
					NewChess960		1	Ctrl+Shift+X	dice				{ ::menu::gameNew .application frc }
					NewChess960Sym	1	Ctrl+Shift+Y	dice				{ ::menu::gameNew .application sfrc }
					NewShuffle		1	Ctrl+Shift+Z	dice				{ ::menu::gameNew .application shuffle }
					Save				1	Ctrl+S			save				{ ::game::save .application }
					Replace			1	Ctrl+R			saveAs			{ ::game::replace .application }
					ReplaceMoves	1	Ctrl+Shift+M	saveAs			{ ::game::replaceMoves .application }
				} \
		View	CreateViewMenu

	set lst {}
	foreach lang [lsort [array names ::mc::input]] {
		if {[string length $lang]} {
			set flag ""
			catch { set flag ::country::icon::flag([set ::mc::langToCountry([set ::mc::lang$lang])]) }
			if {[string length $flag] == 0} { set flag none }
			lappend lst $lang 0 "" $flag [list ::mc::selectLang $lang]
		}
	}
	lappend Menu Settings [list {*}$lst]
	unset lst

	lappend Menu \
		Help	{	Contents			1	F1			help		{ ::menu::openHelp .application }
					WhatsNew			1	{}			news		{ ::menu::whatsNew .application }
					Roadmap			1	{}			plan		{ ::menu::roadmap .application }
					ContactInfo		1	{}			contact	{ ::menu::contactInfo .application }
					BugReport		1	{}			bug		{ ::menu::bugReport .application }
					FeatureRequest	1	{}			question	{ ::menu::featureRequest .application }
					About				1	{}			info		{ ::info::openDialog .application }
				}


	set m [menu .application.menu]
	.application configure -menu $m
	set MenuWidget $m

	set count 0
	foreach {menuName cascade} $Menu {
		set c [menu $m.m$menuName]
		$m add cascade -menu $c -label [set [namespace current]::mc::$menuName]
		widget::menuTextvarHook $m $count [namespace current]::mc::$menuName
		incr count
		set index 0

		if {[llength $cascade] == 1} {
			[namespace current]::$cascade $c
		} else {
			foreach {entryName dots acc icon cmd} $cascade {
				if {[string range $entryName 0 0] eq "-"} {
					$c add separator
				} else {
					set Entries($menuName:$entryName) $index
					$c add command -command $cmd
					widget::menuTextvarHook $c $index [namespace current]::mc::$menuName$entryName {*}$dots

					if {[string length $icon]} {
						if {![info exists $icon]} { set icon ::icon::16x16::$icon }
						$c entryconfigure $index -image [set $icon] -compound left
					}

					if {[llength $acc]} {
						set key $acc
						if {[string match Ctrl* $key]} {
							set keys [split $key "+-"]
							set key {}
							set acc {}
							set shift 0
							foreach k $keys {
								if {[string length $key] > 0 && [string index $key end] != "\u2013"} {
									append key "-"
								}
								if {[string length $acc] > 0 && [string index $acc end] != "+"} {
									append acc "+"
								}
								switch $k {
									Ctrl {
										append key "Control"
										append acc $mc::Ctrl
									}
									Shift {
										set shift 1
										append acc $mc::Shift
									}
									default {
										if {$shift} {
											append key $k
										} else {
											append key [string tolower $k]
										}
										append acc $k
									}
								}
							}
						}
						$c entryconfigure $index -accelerator $acc
						bind .application <$key> $cmd
					}
				}
				incr index
			}
		}
	}
}


proc configureCloseBase {state} {
	variable Entries
	.application.menu.mFile entryconfigure $Entries(File:Close) -state $state
}


proc entryconfigure {menu index {var {}} {unused {}} {unused {}}} {
	$menu entryconfigure $index -image $::icon::16x16::none -compound left
}


proc verifyPath {w path} {
	# we do not allow two or more consecutive dots in filename
	if {[string first ".." $path] >= 0} {
		::dialog::error -parent $w -message [format $mc::FileNotAllowed $path] -detail $mc::TwoOrMoreDots
		return ""
	}
	# be sure filename is portable (since we support unix, win32 and mac)
	foreach c $path {
		if {[string is control $c]} {
			::dialog::error \
				-parent $w \
				-message [format $mc::FileNotAllowed $path] \
				-detail $mc::ForbiddenChars
			return ""
		}
	}
	if {[string match {*[\"\*:<>\?\|]*} $path]} {
		::dialog::error -parent $w -message [format $mc::FileNotAllowed $path] -detail $mc::ForbiddenChars
		return ""
	}
	return $path
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
	set filetypes [list                                                       \
		[list $mc::AllScidbFiles		{.sci .si4 .si3 .cbh .pgn .pgn.gz .zip}] \
		[list $mc::AllScidbBases		{.sci .si4 .si3 .cbh}]                   \
		[list $mc::ScidbBases			.sci]                                    \
		[list $mc::ScidBases				{.si4 .si3}]                             \
		[list $mc::ChessBaseBases		.cbh]                                    \
		[list $mc::PGNFilesArchives	{.pgn .pgn.gz .zip}]                     \
		[list $mc::PGNFiles				{.pgn .pgn.gz}]                          \
		[list $mc::PGNArchives			{.zip}]                                  \
	]
	set result [::dialog::openFile \
		-parent $parent \
		-filetypes $filetypes \
		-defaultextension .sci \
		-needencoding 1 \
		-geometry last \
		-title [set [namespace current]::mc::OpenFile] \
	]

	if {[llength $result]} {
		lassign $result file encoding
		::application::database::openBase $parent $file yes $encoding
	}
}


proc dbOpenUrl {parent} {
	::beta::notYetImplemented .application OpenUrl
	# TODO: download a PGN file from the internet (may be zipped)
}


proc dbImport {parent} {
	set filetypes [list	[list $mc::PGNFilesArchives	{.pgn .pgn.gz .zip}] \
								[list $mc::PGNFiles				{.pgn .pgn.gz}] \
								[list $mc::PGNArchives			{.zip}] \
	]
	set title [set [namespace current]::mc::ImportFiles]
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
		set base [::scidb::db::get name]
		lassign $result files encoding
		::import::open $parent $base $files $title $encoding
		::application::database::refreshBase $base
	}
}


proc dbImportOne {parent} {
	set pos [::game::new $parent]
	if {$pos >= 0} {
		::application::switchTab board
		::import::openEdit $parent $pos
	}
}


proc dbClose {parent} {
	::application::database::closeBase $parent
}


proc dbExport {parent} {
	set base [::scidb::db::get name]
	set type [::scidb::db::get type]
	set name [::util::databaseName $base]
	::export::open $parent $base $type $name 0
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


proc openHelp {parent} {
	::help::open $parent
}


proc whatsNew {parent} {
	::help::open $parent Whats-New
}


proc roadmap {parent} {
	::help::open $parent Development-Roadmap
}


proc contactInfo {parent} {
	::help::open $parent Contact-Information
}


# NOTE: currently unused
proc hideMenu {{toggle {}}} {
	variable MenuWidget
	variable HideMenu

	if {[llength $toggle]} { set HideMenu [expr {!$HideMenu}] }
	set geom [winfo geometry .application]

	if {$HideMenu} {
		.application configure -menu {}
	} else {
		.application configure -menu $MenuWidget
	}

	wm geometry .application $geom
	update

	# TODO: configure .application in a way that opening menues will still work
}

} ;# namespace menu

# vi:set ts=3 sw=3:
