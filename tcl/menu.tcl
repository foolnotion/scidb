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

::util::source main-menu

namespace eval menu {
namespace eval mc {

set Theme						"Theme"

set AllScidbFiles				"All Scidb files"
set AllScidbBases				"All Scidb databases"
set ScidBases					"Scid databases"
set ScidbBases					"Scidb databases"
set ChessBaseBases			"ChessBase databases"
set ScidbArchives				"Scidb archives"
set PGNFilesArchives			"PGN files/archives"
set PGNFiles					"PGN files"
set BPGNFilesArchives		"BPGN files/archives"
set BPGNFiles					"BPGN files"
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
set Tools						"&Tools"
set Extras						"&Extras"
set Setup						"Setu&p"
set Engines						"&Engines"

set ContactBugReport			"&Bug Report"
set ContactFeatureRequest	"&Feature Request"
set InstallChessBaseFonts	"Install ChessBase Fonts"
set OpenEngineLog				"Open &Engine Console"
set OpenEngineDictionary	"Open Engine &Dictionary"
set PrivatePlayerCard		"&Private Player Card"

set OpenFile					"Open a Scidb File"
set NewFile						"Create a Scidb File"
set Archiving					"Archiving"
set CreateArchive				"Create Archive"
set BuildArchive				"Create archive %s"
set Data							"%s data"

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

variable Fullscreen			0
variable HideMenu				0
variable Theme					default
variable FileSelBoxInUse	0
variable Entry
variable SubMenu
variable MenuWidget


proc setup {} {
	bind .application <F1> [list ::help::open .application]
	bind .application <Control-l> [list ::log::show]
	bind .application <F11> [namespace code [list viewFullscreen toggle]]
	bind .application <Control-q> ::application::shutdown
	bind .application <Configure> [namespace code { CheckFullscreen %W }]

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
	set i [lsearch -exact $styles default]
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

	### setup ################################################################
	$menu add separator

	set m [menu $menu.mSetup]
	lassign [::tk::UnderlineAmpersand $mc::Setup] text ul
	$menu add cascade \
		-compound left \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::setup \
		;
	lassign [::tk::UnderlineAmpersand $mc::Engines] text ul
	set cmd [namespace code [list ::engine::openAdmininstration .application]]
	$m add command \
		-label " $text" \
		-underline [incr ul] -command $cmd \
		;
if {0} {
	lassign [::tk::UnderlineAmpersand $mc::PrivatePlayerCard] text ul
	set cmd [namespace code [list ::playercard::setupPrivateCard .application]]
	$m add command \
		-label " $text" \
		-underline [incr ul] \
		-command $cmd \
		-image $::icon::16x16::playercard \
		-compound left \
		;
}

	### tools ################################################################
	set m [menu $menu.mTools]
	lassign [::tk::UnderlineAmpersand $mc::Tools] text ul
	$menu add cascade \
		-compound left \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::none \
		;
	lassign [::tk::UnderlineAmpersand $mc::OpenEngineDictionary] text ul
	set cmd [namespace code [list ::engine::showEngineDictionary .application]]
	$m add command \
		-compound left \
		-label " $text..." \
		-underline [incr ul] \
		-image $::icon::16x16::none \
		-command $cmd \
		;

	### extras ###############################################################
	set m [menu $menu.mExtras]
	lassign [::tk::UnderlineAmpersand $mc::Extras] text ul
	$menu add cascade \
		-compound left \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::none \
		;

	if {[::util::photos::busy?]} { set state disabled } else { set state normal }
	lassign [::tk::UnderlineAmpersand $::util::photos::mc::InstallPlayerPhotos] text ul
	set cmd [namespace code [list ::util::photos::openDialog .application]]
	$m add command \
		-compound left \
		-label " $text" \
		-underline $ul \
		-image $::icon::16x16::none \
		-command $cmd \
		-state $state \
		;

	if {[llength [info procs ::font::installChessBaseFonts]]} {
		lassign [::tk::UnderlineAmpersand $mc::InstallChessBaseFonts] text ul
		set cmd [namespace code [list ::font::installChessBaseFonts .application]]
		$m add command \
			-compound left \
			-label " $text" \
			-underline $ul \
			-image $::icon::16x16::fonts \
			-command $cmd \
			;
	}

	lassign [::tk::UnderlineAmpersand $mc::OpenEngineLog] text ul
	set cmd [namespace code [list ::engine::openEngineLog .application]]
	if {[::engine::logIsOpen? .application]} { set state disabled } else { set state normal }
	$m add command \
		-compound left \
		-label " $text..." \
		-underline [incr ul] \
		-image $::icon::16x16::none \
		-command $cmd \
		-state $state \
		;

	### help #################################################################
	$menu add separator

	lassign [::tk::UnderlineAmpersand $mc::Help] text ul
	$menu add command \
		-compound left \
		-label " $text..." \
		-underline [incr ul] \
		-image $::icon::16x16::help \
		-accelerator "F1" \
		-command [list ::help::open .application] \
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
		-accelerator "${::mc::Key(Ctrl)}+L" \
		-command ::log::show \
		;

	### contact ##############################################################
	set m [menu $menu.mContact]
	lassign [::tk::UnderlineAmpersand $mc::Contact] text ul
	$menu add cascade \
		-compound left \
		-menu $m \
		-label " $text" \
		-underline [incr ul] \
		-image $::icon::16x16::contact \
		;

	lassign [::tk::UnderlineAmpersand $mc::ContactBugReport] text ul
	$m add command \
		-label $text \
		-underline $ul \
		-command [namespace code [list bugReport .application]] \
		;

	lassign [::tk::UnderlineAmpersand $mc::ContactFeatureRequest] text ul
	$m add command \
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
		-accelerator "${::mc::Key(Ctrl)}+Q" \
		;
}


proc addVariantsToMenu {parent m} {
	foreach variant {ThreeCheck Crazyhouse} {
		$m add command \
			-label " $::mc::VariantName($variant)" \
			-image $::icon::16x16::variant($variant) \
			-compound left \
			-command [list ::menu::dbNew $parent $variant] \
			;
	}

	set lbl " $::mc::VariantName(Antichess) - $::mc::VariantName(Losers)"
	$m add command  \
		-label $lbl \
		-command [namespace code [list dbNew $parent Losers]] \
		-image $::icon::16x16::variant(Losers) \
		-compound left \
		;
	::tooltip::tooltip $m -index $lbl $::gamebar::mc::Tip(Losers)

	set lbl " $::mc::VariantName(Antichess) - $::mc::VariantName(Suicide)/$::mc::VariantName(Giveaway)"
	$m add command \
		-label $lbl \
		-command [namespace code [list dbNew $parent Antichess]] \
		-image $::icon::16x16::variant(Antichess) \
		-compound left \
		;
	::tooltip::tooltip $m -index $lbl $::gamebar::mc::Tip(Antichess)
}


proc dbNew {parent variant} {
	variable FileSelBoxInUse

	if {$FileSelBoxInUse} { return }
	set FileSelBoxInUse 1

	if {$variant eq "Normal"} {
		set filetypes [list                             \
			[list $mc::ScidbBases		{.sci}]           \
			[list $mc::ScidBases			{.si4 .si3}]      \
			[list $mc::AllScidbBases	{.sci .si4 .si3}] \
		]
	} else {
		set filetypes [list [list $mc::ScidbBases {.sci}]]
	}
	set result [::dialog::saveFile \
		-parent $parent \
		-class database \
		-filetypes $filetypes \
		-geometry last \
		-defaultextension .sci \
		-defaultencoding utf-8 \
		-needencoding 1 \
		-title [set [namespace current]::mc::NewFile] \
		-customicon $::icon::16x16::filetypeArchive \
		-customtooltip $mc::Archiving \
		-customcommand [namespace code [list CreateArchive]] \
		-customfiletypes {.sci .si4 .si3 .cbh .pgn .pgn.gz .bpgn .bpgn.gz .zip} \
	]
	set FileSelBoxInUse 0

	if {[llength $result]} {
		::application::database::newBase $parent $variant {*}$result
	}
}


proc dbOpen {parent} {
	variable FileSelBoxInUse

	if {$FileSelBoxInUse} { return }
	set FileSelBoxInUse 1

	set filetypes [list                                                                              \
		[list $mc::AllScidbFiles			{.sci .si4 .si3 .cbh .scv .pgn .pgn.gz .bpgn .bpgn.gz .zip}] \
		[list $mc::AllScidbBases			{.sci .si4 .si3 .cbh .scv}]                                  \
		[list $mc::ScidbBases				{.sci}]                                                      \
		[list $mc::ScidBases					{.si4 .si3}]                                                 \
		[list $mc::ChessBaseBases			{.cbh}]                                                      \
		[list $mc::ScidbArchives			{.scv}]                                                      \
		[list $mc::PGNFilesArchives		{.pgn .pgn.gz .zip}]                                         \
		[list $mc::BPGNFilesArchives		{.bpgn .bpgn.gz .zip}]                                       \
		[list $mc::PGNArchives				{.zip}]                                                      \
	]
	set result [::dialog::openFile \
		-parent $parent \
		-class database \
		-filetypes $filetypes \
		-defaultextension .sci \
		-needencoding 1 \
		-geometry last \
		-title $mc::OpenFile \
		-customicon $::icon::16x16::filetypeArchive \
		-customtooltip $mc::Archiving \
		-customcommand [namespace code [list CreateArchive]] \
		-customfiletypes {.sci .si4 .si3 .cbh .pgn .pgn.gz .bpgn .bpgn.gz .zip} \
	]
	set FileSelBoxInUse 0

	if {[llength $result]} {
		lassign $result file encoding
		::application::database::openBase $parent $file yes -encoding $encoding
	}
}


proc dbCreateArchive {parent {base ""}} {
	if {[string length $base] == 0} { set base [::scidb::db::get name] }
	if {$base eq $::scidb::clipbaseName} { set name $::util::clipbaseName } else { set name $base}
	set filetypes [list	[list $mc::ScidbArchives {.scv}]]
	set result [::dialog::saveFile \
		-parent $parent \
		-class database \
		-filetypes $filetypes \
		-defaultextension .scv \
		-needencoding 0 \
		-geometry last \
		-title $mc::CreateArchive \
		-initialfile [file tail [file rootname $name]] \
		-customcommand {} \
	]
	if {[llength $result]} {
		set arch [lindex $result 0]
		set progress $parent.__p__
		if {[::scidb::db::get open? $base] && [::scidb::db::get memoryOnly? $base]} {
			::dialog::progressbar::open $progress \
				-mode indeterminate \
				-message [format $mc::BuildArchive [file rootname [file tail $arch]]] \
				;
			set streams {}
			foreach ext [::scidb::misc::suffixes "$base.sci"] { lappend streams "$base.$ext" }
			set cmd [list ::archive::packStreams \
				$arch \
				[file dirname $base] \
				$streams \
				{sci} \
				zlib \
				[clock seconds] \
				[::scidb::db::count total $base] \
				[namespace current]::archive::Write \
				[namespace current]::archive::getName \
				$progress \
			]
		} else {
			::dialog::progressbar::open $progress \
				-mode determinate \
				-message [format $mc::BuildArchive [file rootname [file tail $arch]]] \
				;
			set files {}
			set rootname [file rootname $base]
			foreach ext [::scidb::misc::suffixes $base] {
				set f "$rootname.$ext"
				if {[file exists $f]} { lappend files [file tail $f] }
			}
			set cmd [list ::archive::packFiles \
							$arch \
							[file dirname $base] \
							$files \
							$progress \
							[namespace current]::archive::GetCompressionMethod \
							[namespace current]::archive::getName \
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


proc dbImport {parent base fileTypes} {
	variable FileSelBoxInUse

	if {$FileSelBoxInUse} { return }
	set FileSelBoxInUse 1

	switch $fileTypes {
		db {
			set filetypes [list                                \
				[list $mc::AllScidbBases		{.sci .si4 .si3}] \
				[list $mc::ScidbBases			{.sci}]           \
				[list $mc::ScidBases				{.si4 .si3}]      \
			]
		}
		pgn {
			set filetypes [list                                     \
				[list $mc::PGNFilesArchives	{.pgn .pgn.gz .zip}]   \
				[list $mc::PGNFiles				{.pgn .pgn.gz}]        \
				[list $mc::BPGNFilesArchives	{.bpgn .bpgn.gz .zip}] \
				[list $mc::BPGNFiles				{.bpgn .bpgn.gz}]      \
				[list $mc::PGNArchives			{.zip}]                \
			]
		}
	}
	set title $::application::database::mc::FileImport($fileTypes)
	if {[string match *... $title]} { set title [string range $title 0 end-3] }
	set result [::dialog::openFile \
		-parent $parent \
		-class pgn \
		-filetypes $filetypes \
		-defaultextension .pgn \
		-needencoding 1 \
		-geometry last \
		-title $title \
		-multiple yes \
	]
	set FileSelBoxInUse 0
	if {[llength $result]} {
		lassign $result files encoding
		::import::import $parent $base $files $title $encoding
		if {$base eq [::scidb::db::get name]} {
			::application::database::refreshBase $base
		}
	}
}


proc dbClose {parent} {
	::application::database::closeBase $parent
}


proc gameNew {parent {variant Normal}} {
	if {[::game::new $parent -variant $variant] >= 0} {
		set idn [::scidb::game::query 9 fen]
		::scidb::game::setup $variant $idn
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


proc fullscreen? {} {
	return [set [namespace current]::Fullscreen]
}


proc CheckFullscreen {app} {
	variable Fullscreen

	if {$app eq ".application"} {
		set Fullscreen 0
		if {[scan [wm geometry $app] "%dx%d" wd ht] == 2} {
			if {$wd == [winfo screenwidth $app] && $ht == [winfo screenheight $app]} { set Fullscreen 1 }
		}
	}
}


proc CreateArchive {parent file} {
	dbCreateArchive $parent [file normalize $file]
}

namespace eval archive {
# namespace eval mc {
#
# set Data(index)				"index data"
# set Data(game)				"game data"
# set Data(namebase)			"namebase data"
# set Data(sorting)			"sorting data"
# set Data(team)				"team data"
# set Data(initialization)	"initialization data"
#
# set Index(annotation)		"annotation index"
# set Index(source)			"source index"
# set Index(player)			"player index"
# set Index(annotator)		"annotator index"
# set Index(team)				"team index"
#
# }

proc getName {file} {
	set ext [file extension $file]
#	switch $ext {
#		.sci - .si3 - .si4 - .cbh	{ return $mc::Data(index) }
#		.scg - .sg3 - .sg4 - .cbg	{ return $mc::Data(game) }
#		.scn - .sn3 - .sn4			{ return $mc::Data(namebase) }
#		.ssc								{ return $mc::Data(sorting) }
#		.pgn - .pgn.gz - .zip		{ return $mc::Data(game) }
#		.bpgn - .bpgn.gz				{ return $mc::Data(game) }
#		.cba								{ return $mc::Index(annotation) }
#		.cbs								{ return $mc::Index(source) }
#		.cbp								{ return $mc::Index(player) }
#		.cbc								{ return $mc::Index(annotator) }
#		.cbt								{ return $mc::Index(team) }
#		.cbj								{ return $mc::Data(team) }
#		.ini								{ return $mc::Data(initialization) }
#	}
	return [format [set [namespace parent]::mc::Data] $ext]
}


proc GetCompressionMethod {ext} {
	switch $ext {
		pgn.gz - bpgn.gz - zip	{ set method raw  }
		png - jpg - jpeg - gif	{ set method raw  }
		default						{ set method zlib }
	}

	return $method
}


proc GetCount {file} {
	switch [file extension $file] {
		.sci - .si3 - .si4 - .cbh - .pgn - .pgn.gz - .bpgn - .bpgn.gz {
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
