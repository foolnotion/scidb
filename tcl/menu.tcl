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

namespace eval menu {
namespace eval mc {

set File						"&File"
set Game						"&Game"
set View						"&View"
set Help						"&Help"

set FileOpen				"&Open..."
set FileOpenRecent		"Open &Recent"
set FileOpenURL			"Open URL..."
set FileNew					"&New..."
set FileExport				"E&xport..."
set FileImport				"I&mport PGN files..."
set FileImportOne			"&Import one PGN game..."
set FileClose				"&Close"
set FileQuit				"&Quit"

set GameNew					"&New Game"
set GameNewShuffle		"N&ew Game: Shuffle"
set GameNewShuffleSymm	"Ne&w Game: Shuffle (symmetrical only)"
set GameSave				"&Save Game"
set GameReplace			"&Replace Game"
set GameReplaceMoves		"Replace &Moves Only"

set HelpInfo				"&Info..."
set HelpContents			"&Contents"
set HelpBugReport			"&Bug Report (open in web browser)"

set ViewShowLog			"Show &Log..."

set OpenFile				"Open a Scidb File"
set NewFile					"Create a Scidb File"
set ImportFiles			"Import PGN files"

set Theme					"Theme"
set Ctrl						"Ctrl"
set Shift					"Shift"

set AllScidbFiles			"All Scidb files"
set AllScidbBases			"All Scidb databases"
set AllScidBases			"All Scid databases"
set ScidbBases				"Scidb databases"
set Scid4Bases				"Scid 4 databases"
set Scid3Bases				"Scid 3 databases"
set ChessBaseBases		"ChessBase databases"
set PGNFiles				"PGN files"

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


set Defaults(iconsize)	medium
set BugTracker				"http://sourceforge.net/tracker/?group_id=307371&atid=1294797"

variable Theme				default
variable IconSize
variable Entries


# TODO: create menu after Post event


proc CreateViewMenu {menu} {
	variable Defaults
	variable IconSize
	variable Theme

	set m [menu $menu.mIconSize]
	$menu add cascade -menu $m -label $::toolbar::mc::IconSize
	widget::menuTextvarHook $menu 0 ::toolbar::mc::IconSize
	set IconSize $Defaults(iconsize)
	set index 0
	foreach size $::toolbar::iconSizes {
		set var ::toolbar::mc::[string toupper $size 0 0]
		set text [set $var]
		$m add radiobutton \
			-label $text \
			-variable [namespace current]::IconSize \
			-value $size \
			-command [namespace code { SetIconSize }]
			::theme::configureRadioEntry $m $text
		widget::menuTextvarHook $m $index $var
		incr index
	}

	set m [menu $menu.mTheme]
	$menu add cascade -menu $m -label $mc::Theme
	widget::menuTextvarHook $menu 1 [namespace current]::mc::Theme
	set Theme [::theme::currentTheme]
	foreach style [ttk::style theme names] {
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
	set cmd [list ::log::show]
	$menu add command -accelerator "${mc::Ctrl}+L" -command $cmd
	widget::menuTextvarHook $menu 3 [namespace current]::mc::ViewShowLog
	bind .application <Control-l> $cmd
}


proc SetIconSize {} {
	variable Defaults
	variable IconSize

	if {$IconSize == 0} {
		set IconSize $Defaults(iconsize)
	} else {
		set Defaults(iconsize) $IconSize
		::toolbar::setIconSize $IconSize
	}
}


proc setup {} {
	variable Menu
	variable Entries

	lappend Menu \
		File	{	New				1	Ctrl+N			docNew			{ ::menu::dbNew .application }
					Open				1	Ctrl+O			docOpen			{ ::menu::dbOpen .application }
					OpenURL			1	{}					internet			{ ::menu::dbOpenUrl .application }
					Export			1	Ctrl+X			fileExport		{ ::menu::dbExport .application }
					Import			1	Ctrl+P			filetypePGN		{ ::menu::dbImport .application }
					ImportOne		1	Ctrl+I			filetypePGN-1	{ ::menu::dbImportOne .application }
					Close				0	Ctrl+C			close				{ ::menu::dbClose .application }
					--------------	-	-------------	--------------	---------------------------------
					Quit				0	Ctrl+Q			exit				{ ::application::shutdown }
				} \
		Game	{	New				1	Ctrl+X			document			{ ::menu::gameNew .application }
					NewShuffle		1	Ctrl+Shift+X	dice				{ ::menu::gameNew .application frc }
					NewShuffleSymm	1	Ctrl+Shift+Y	symmetric		{ ::menu::gameNew .application sfrc }
					Save				1	Ctrl+S			save				{ ::menu::gameSave .application }
					Replace			1	Ctrl+R			saveAs			{ ::menu::gameReplace .application }
					ReplaceMoves	1	Ctrl+M			saveAs			{ ::menu::gameReplaceMoves .application }
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
		Help	{	Contents			1	F1			help		{ puts "Help contents" }
					BugReport		1	{}			bug		{ ::menu::bugReport .application }
					Info				1	{}			info		{ ::info::openDialog .application }
				}


	set m [menu .application.menu]
	.application configure -menu $m

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
								if {[string length $key] > 0 && [string index $key end] != "-"} {
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


proc verifyDatabaseName {w path} {
	set path [verifyPath $w $path]
#	if {[string length $path]} {
#		set ext [file extension $path]
#		if {[string length $ext] == 0} { set ext . }
#		switch $ext {
#			.sci - .si3 - .si4 {}
#
#			default {
#				if {[string index $path end] ne "."} { append path . }
#				append path sci
#			}
#		}
#	}
	return $path
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
		[list $mc::Scid3Bases		.si3]             \
		[list $mc::Scid4Bases		.si4]             \
		[list $mc::AllScidBases		{.si3 .si4}]      \
		[list $mc::AllScidbBases	{.sci .si3 .si4}] \
	]
	set f [::dialog::saveFile \
				-parent $parent \
				-filetypes $filetypes \
				-geometry lastsize \
				-verifycmd [namespace current]::verifyDatabaseName \
				-defaultextension .sci \
				-title [set [namespace current]::mc::NewFile]]

	set f [string trim $f]
	if {[llength $f]} {
		set f [encoding convertto utf-8 $f]
		::application::database::newBase $parent $f
	}
}


proc dbOpen {parent} {
	set filetypes [list                                                    \
		[list $mc::AllScidbFiles	{.sci .si3 .si4 .cbh .pgn .pgn.gz .zip}] \
		[list $mc::AllScidbBases	{.sci .si3 .si4 .cbh}]                   \
		[list $mc::ScidbBases		.sci]                                    \
		[list $mc::AllScidBases		{.si4 .si3}]                             \
		[list $mc::Scid3Bases		.si3]                                    \
		[list $mc::Scid4Bases		.si4]                                    \
		[list $mc::ChessBaseBases	.cbh]                                    \
		[list $mc::PGNFiles			{.pgn .pgn.gz}]                          \
		[list $mc::PGNFiles			.zip]                                    \
	]
	set f [::dialog::openFile \
				-parent $parent \
				-filetypes $filetypes \
				-defaultextension .sci \
				-geometry lastsize \
				-title [set [namespace current]::mc::OpenFile] \
			]
	
	set f [string trim $f]
	if {[llength $f]} {
		set f [encoding convertto utf-8 $f]
		::application::database::openBase $parent $f
	}
}


proc dbOpenUrl {parent} {
	puts "not yet implemented"
	# TODO: download a PGN file from the internet (may be zipped)
}


proc dbImport {parent} {
	set filetypes [list [list $mc::PGNFiles {.pgn .pgn.gz .zip}]]
	set title [set [namespace current]::mc::ImportFiles]
	set files [::dialog::openFile \
					-parent $parent \
					-filetypes $filetypes \
					-defaultextension .pgn \
					-geometry lastsize \
					-title $title \
					-multiple yes \
				]
	
	if {[llength $files]} {
		set oldfiles $files
		set files {}
		foreach file $oldfiles {
			lappend files [encoding convertto utf-8 $file]
		}
		set base [::scidb::db::get name]
# XXX hack!
set encoding iso8859-1
		::import::open $parent $base $files $title $encoding
		::application::database::refreshBase $base
	}
}


proc dbImportOne {parent} {
	set pos [::game::new $parent]
	if {$pos >= 0} {
		::import::openEdit $parent $pos
	}
}


proc dbClose {parent} { ::application::database::closeBase $parent }
proc dbExport {parent} { ::export::open $parent }


proc gameNew {parent {variant {}}} {
	if {[::game::new $parent] >= 0} {
		if {[string length $variant] == 0} {
			::scidb::game::clear [::scidb::game::query 9 fen]
		} else {
			::scidb::game::clear [::setup::shuffle $variant]
		}
	}
}


proc gameSave {parent} {
	::dialog::save::open $parent [::scidb::db::get name] -1
}


proc gameReplace {parent} {
	::dialog::save::open $parent [::scidb::db::get name] -1 [::scidb::game::number]
}


proc gameReplaceMoves {parent} {
	set base [::scidb::db::get name]

	if {[::scidb::db::get readonly? $base]} {
		::dialog::info \
			-parent $parent \
			-message [format $::dialog::save::mc::CurrentBaseIsReadonly [::util::databaseName $base]] \
			-title "[tk appname] - $::dialog::save::mc::ReplaceGame" \
			;
	} else {
		::scidb::db::update moves $base [expr {[::scidb::game::number] - 1}]
	}
}


proc bugReport {parent} {
	::web::open [set [namespace current]::BugTracker]
}


proc stripAmpersand {text} {
	return [string map {& {}} $text]
}

} ;# namespace menu

# vi:set ts=3 sw=3:
