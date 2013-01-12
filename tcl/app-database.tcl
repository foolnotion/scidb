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

::util::source database-pane

namespace eval application {
namespace eval database {
namespace eval mc {

set FileOpen						"Open"
set FileOpenRecent				"Open Recent"
set FileNew							"New"
set FileExport						"Export"
set FileImport(pgn)				"Import PGN files"
set FileImport(db)				"Import Databases"
set FileCreate						"Create Archive"
set FileClose						"Close"
set FileMaintenance				"Maintenance"
set FileCompact					"Compact"
set FileStripMoveInfo			"Strip Move Information"
set FileStripPGNTags				"Strip PGN Tags"
set HelpSwitcher					"Help for Database Switcher"

set Games							"&Games"
set Players							"&Players"
set Events							"&Events"
set Sites							"&Sites"
set Annotators						"&Annotators"

set File								"File"
set SymbolSize						"Symbol Size"
set Large							"Large"
set Medium							"Medium"
set Small							"Small"
set Tiny								"Tiny"
set LoadMessage					"Opening database '%s'"
set UpgradeMessage				"Upgrading database '%s'"
set CompactMessage				"Compacting database '%s'"
set CannotOpenFile				"Cannot open file '%s'."
set EncodingFailed				"Encoding %s failed."
set DatabaseAlreadyOpen			"Database '%s' is already open."
set Properties						"Properties"
set Preload							"Preload"
set MissingEncoding				"Missing encoding %s (using %s instead)"
set DescriptionTooLarge			"Description is too large."
set DescrTooLargeDetail			"The entry contains %d characters, but only %d characters are allowed."
set ClipbaseDescription			"Temporary database, not kept on disk."
set HardLinkDetected				"Cannot load file '%file1' because it is already loaded as file '%file2'. This can only happen if hard links are involved."
set HardLinkDetectedDetail		"If we load this database twice the application may crash due to the usage of threads."
set OverwriteExistingFiles		"Overwrite exisiting files in directory '%s'?"
set SelectDatabases				"Select the databases to be opened"
set ExtractArchive				"Extract archive %s"
set CompactDetail					"All games must be closed before a compaction can be done."
set ReallyCompact					"Really compact database '%s'?"
set ReallyCompactDetail(1)		"Only one game will be deleted."
set ReallyCompactDetail(N)		"%s games will be deleted."
set SelectVariant					"Select Variant"

set RecodingDatabase				"Recoding %base from %from to %to"
set RecodedGames					"%s game(s) recoded"

set ChangeIcon						"Change Icon"
set Recode							"Recode"
set EditDescription				"Edit Description"
set EmptyClipbase					"Empty Clipbase"

set T_Unspecific					"Unspecific"
set T_Temporary					"Temporary"
set T_Work							"Work"
set T_Clipbase						"Clipbase"
set T_MyGames						"My Games"
set T_Informant					"Informant"
set T_LargeDatabase				"Large Database"
set T_CorrespondenceChess		"Correspondence Chess"
set T_EmailChess					"Email Chess"
set T_InternetChess				"Internet Chess"
set T_ComputerChess				"Computer Chess"
set T_Chess960						"Chess 960"
set T_PlayerCollection			"Player Collection"
set T_PlayerCollectionFemale	"Player Collection"
set T_Tournament					"Tournament"
set T_TournamentSwiss			"Tournament Swiss"
set T_GMGames						"GM Games"
set T_IMGames						"IM Games"
set T_BlitzGames					"Blitz Games"
set T_Tactics						"Tactics"
set T_Endgames						"Endgames"
set T_Analysis						"Analysis"
set T_Training						"Training"
set T_Match							"Match"
set T_Studies						"Studies"
set T_Jewels						"Jewels"
set T_Problems						"Problems"
set T_Patzer						"Patzer"
set T_Gambit						"Gambit"
set T_Important					"Important"
set T_Openings						"Openings"
set T_OpeningsWhite				"Openings White"
set T_OpeningsBlack				"Openings Black"
set T_PGNFile						"PGN file"
set T_Bughouse						"Bughouse"
set T_Antichess					"Antichess"
set T_ThreeCheck					"Three-check"
set T_Crazyhouse					"Crazyhouse"

set OpenDatabase					"Open Database"
set NewDatabase					"New Database"
set CloseDatabase					"Close Database '%s'"
set SetReadonly					"Set Database '%s' readonly"
set SetWriteable					"Set Database '%s' writeable"

set OpenReadonly					"Open readonly"
set OpenWriteable					"Open writeable"

set UpgradeDatabase				"%s is an old format database that cannot be opened writeable.\n\nUpgrading will create a new version of the database and after that remove the original files.\n\nThis may take a while, but it only needs to be done one time.\n\nDo you want to upgrade this database now?"
set UpgradeDatabaseDetail		"\"No\" will open the database readonly, and you cannot set it writeable."

}

set Variants {Normal ThreeCheck Bughouse Crazyhouse Antichess Losers}

array set Vars {
	pixels			0
	selection		0
	icon				0
	ignore-next		0
	counter			0
	motion			-1
	current			-1
	afterid			{}
	showDisabled	0
	pressed			0
	dragging			0
	taborder			{games players events sites annotators}
}

array set Defaults {
	selected					#ffdd76
	iconsize					48
	symbol-padding			4
	ask-encoding			1
	ask-readonly			1
	si4-readonly			1
	font-symbol-tiny		TkTooltipFont
	font-symbol-normal	TkTextFont
	drop:background		LemonChiffon
}
# lightsteelblue

array set Options {
	visible				10
}

variable PreOpen			{}
variable RecentFiles		{}
variable MaxHistory		10

array set Positions		{}

set Types(sci)				[::scidb::db::get types sci]
set Types(si3)				[::scidb::db::get types si3]
set Types(si4)				[::scidb::db::get types si4]


proc build {tab width height} {
	variable ::scidb::clipbaseName
	variable Variants
	variable Vars

	set ::util::clipbaseName [set [namespace current]::mc::T_Clipbase]

	set main [tk::panedwindow $tab.main \
		-orient vertical \
		-opaqueresize true \
		-borderwidth 0 \
		-sashcmd [namespace code SashCmd] \
	]
	pack $main -fill both -expand yes

	set contents [::ttk::notebook $tab.contents -class UndockingNotebook -takefocus 1]
	::ttk::notebook::enableTraversal $contents
	::theme::configurePanedWindow $main
	set switcher [::database::::switcher $main.switcher \
		-switchcmd [namespace current]::Switch \
		-updatecmd [namespace current]::UpdateVariants \
		-popupcmd [namespace current]::PopupMenu \
		-opencmd [namespace current]::OpenBase \
	]

	$main add $switcher
	$main add $contents

	foreach tab $Vars(taborder) {
		::ttk::frame $contents.$tab -class Scidb
		set var [namespace current]::mc::[string toupper $tab 0 0]
		$contents add $contents.$tab -sticky nsew -compound right
		if {$Vars(showDisabled)} { $contents tab $contents.$tab -image $icon::16x16::undock_disabled }
		::widget::notebookSetLabel $contents $contents.$tab [set $var]
		${tab}::build $contents.$tab
		set Vars($tab) $contents.$tab
		bind $contents.$tab <Destroy> [namespace code [list DestroyTab %W $contents.$tab]]
	}

	$main paneconfigure $switcher -sticky nsew -stretch never
	$main paneconfigure $contents -sticky nsew -stretch always

	bind $contents.games <<TableMinSize>> \
		[namespace code [list TableMinSize $main $contents $switcher %d]]
	bind $contents.games <Configure> [namespace code [list ConfigureList $main $contents $switcher %h]]

	bind $main <Double-Button-1>	{ break }
	bind $main <Double-Button-2>	{ break }

	set tbFile [::toolbar::toolbar $switcher \
		-hide 1 \
		-id database-switcher \
		-tooltipvar [namespace current]::mc::File \
	]

	foreach event {ToolbarShow ToolbarHide ToolbarFlat ToolbarIcon} {
		bind $tbFile <<$event>> [namespace code [list ToolbarShow $switcher]]
	}

	set Vars(button:new) [::toolbar::add $tbFile button \
		-image $::icon::toolbarDocNew \
		-tooltip "$mc::NewDatabase ($::mc::VariantName(Normal))..." \
		-command [list ::menu::dbNew $main Normal] \
	]
	set Vars(button:new...) [::toolbar::add $tbFile button \
		-image $::icon::toolbarDocNewAlt \
		-tooltipvar [::mc::var [namespace current]::mc::NewDatabase "..."] \
		-command [namespace code PopdownFileNew] \
	]
	::toolbar::add $tbFile button \
		-image $::icon::toolbarDocOpen \
		-tooltipvar [::mc::var [namespace current]::mc::OpenDatabase "..."] \
		-command [list ::menu::dbOpen $main] \
		;
	set Vars(button:close) [::toolbar::add $tbFile button \
		-image $::icon::toolbarDocClose \
		-tooltipvar [namespace current]::_CloseDatabase \
		-command [list ::menu::dbClose $main] \
	]
	set Vars(flag:readonly) 0
	set Vars(button:readonly) [::toolbar::add $tbFile checkbutton \
		-image $::icon::toolbarLock \
		-tooltipvar [namespace current]::_Readonly \
		-variable [namespace current]::Vars(flag:readonly) \
		-command [namespace code ToggleReadOnly] \
	]
#	::toolbar::add $tbFile button \
#		-image $::icon::toolbarHelp \
#		-tooltipvar [namespace current]::mc::HelpSwitcher \
#		-command [list ::help::open $sitcher Database-Switcher] \
#		;

	set Vars(switcher) $switcher
	set Vars(contents) $contents
	set Vars(windows) [$contents tabs]
#	set Vars(history) $history
#	set Vars(blank) $blank
	set Vars(current:tab) games
	set Vars(after) {}
	set Vars(lock:minsize) 0
	set Vars(minheight:switcher) 0

	set tbClipbase [::toolbar::toolbar $switcher \
		-id database-clipbase \
		-tooltipvar [namespace current]::mc::SelectVariant \
	]
	foreach variant $Variants {
		switch $variant {
			Losers {
				set tip "$::mc::VariantName(Antichess) - $::mc::VariantName(Losers)"
			}
			Antichess {
				set tip "$::mc::VariantName(Antichess) - "
				append tip "$::mc::VariantName(Suicide)/$::mc::VariantName(Giveaway)"
			}
			default {
				set tip $::mc::VariantName($variant)
			}
		}
		set Vars(widget:$variant) [::toolbar::add $tbClipbase button \
			-image $::icon::toolbarVariant($variant) \
			-command [namespace code [list SwitchVariant $variant]] \
			-variable [namespace current]::Vars(variant) \
			-value $variant \
			-tooltip $tip \
		]
	}

	::scidb::db::subscribe gameList [namespace current]::Update [namespace current]::Close {}
	after idle [namespace code [list ToolbarShow $switcher]]

	bind $contents <<NotebookTabChanged>> [namespace code TabChanged]
	bind $contents <<LanguageChanged>> [namespace code LanguageChanged]

	$Vars(switcher) add $::scidb::clipbaseName [::scidb::db::get clipbase type] no
	$Vars(switcher) current $::scidb::clipbaseName
	SetClipbaseDescription
	bind $contents <<LanguageChanged>> +[namespace code SetClipbaseDescription]
	Switch $clipbaseName Normal
}


proc finish {app} {
	variable Positions
	variable Vars

	foreach w [array names Positions] {
		set tabs [$Vars(contents) tabs]
		for {set i 0} {$i < [llength $tabs] && ![string match *$w [lindex $tabs $i]]} {incr i} {}
		Undock $Vars(contents) $i $Positions($w)
	}

	unset Positions
	array set Positions {}

	# must be done after the toplevel window has been mapped
	after idle [list $Vars(switcher) activate]
}


proc preOpen {parent} {
	variable PreOpen

	if {![::process::testOption re-open]} { return }

	foreach entry $PreOpen {
		lassign $entry type file encoding readonly active
		if {[llength $encoding] && $encoding ni [encoding names]} {
			set encoding $::encoding::defaultEncoding
			::log::error $mc::Preload [format $mc::MissingEncoding $encoding $encoding]
		}
		if {[file readable $file]} {
			::log::hide 1
			openBase $parent $file no -encoding $encoding -readonly $readonly -switchToBase $active
			if {$active} { set current $file }
			::log::hide 0
		} 
	}
}


proc activate {w flag} {
	variable Vars

	set tab [lindex [split [$Vars(contents) select] .] end]
	::toolbar::activate $Vars(switcher) $flag
	[namespace current]::${tab}::activate $Vars($tab) $flag
	::annotation::hide $flag
	::marks::hide $flag
}


proc currentVariant {} {
	return [set [namespace current]::Vars(variant)]
}


proc openBase {parent file byUser args} {
	variable Vars
	variable RecentFiles
	variable Types
	variable Defaults

	set file [file normalize $file]
	if {[string length [set ext [file extension $file]]]} {
		set ext [::scidb::misc::mapExtension $ext]
		set file "[file rootname $file].$ext"
	} else {
		set ext [string range $ext 1 end]
	}
	set ext [string tolower $ext]

	if {![file readable $file]} {
		set i [FindRecentFile $file]
		if {$i >= 0} {
			set RecentFiles [lreplace $RecentFiles $i $i]
			#::menu::configureOpenRecent [GetRecentState]
		}
		::dialog::error -parent $parent -message [format $mc::CannotOpenFile $file]
		return 0
	}

	if {[file type $file] eq "link"} { set file [file normalize [file readlink $file]] }

	if {[file extension $file] eq ".scv"} {
		return [::remote::busyOperation { OpenArchive $parent $file $byUser {*}$args }]
	}

	array set opts { -readonly -1 -encoding "" -switchToBase 1 }
	array set opts $args

	if {$opts(-encoding) eq $::encoding::mc::AutoDetect} {
		set opts(-encoding) $::encoding::autoEncoding
	}
	if {![$Vars(switcher) contains? $file]} {
		foreach base [$Vars(switcher) bases] {
			if {$ext eq [$Vars(switcher) extension $base]} {
				if {[::scidb::misc::hardLinked? $file $base]} {
					set msg [string map [list "%file1" $file "%file2" $base] $mc::HardLinkDetected]
					::dialog::error \
						-parent .application \
						-message $msg \
						-detail $mc::HardLinkDetectedDetail \
						-topmost 1 \
						;
					return 0
				}
			}
		}
		if {[llength $opts(-encoding)] == 0 || $opts(-encoding) eq $::encoding::autoEncoding} {
			set k [FindRecentFile $file]
			if {$k >= 0} { set opts(-encoding) [lindex $RecentFiles $k 2] }
		}
		if {$opts(-readonly) == -1} {
			set k [FindRecentFile $file]
			if {$k >= 0} { set opts(-readonly) [lindex $RecentFiles $k 3] }
		}
		set name [::util::databaseName $file]
		set msg [format $mc::LoadMessage $name]
		if {[llength $opts(-encoding)] == 0} {
			switch $ext {
				sci - si3 - si4 - cbh					{ set opts(-encoding) auto }
				pgn - pgn.gz - bpgn - bpgn.gz - zip	{ set opts(-encoding) $::encoding::defaultEncoding }
			}
		}
		switch $ext {
			sci - si3 - si4 - cbh {
				set args {}
				if {$ext ne "sci"} {
					set opts(-readonly) 1
				} elseif {$opts(-readonly) == -1} {
					set opts(-readonly) 0
				}
				set args [list -readonly $opts(-readonly)]
				if {[llength $opts(-encoding)]} { lappend args -encoding $opts(-encoding) }
				set cmd [list ::scidb::db::load $file]
				set options [list -message $msg -interrupt yes]
				set rc [::util::catchException { ::progress::start $parent $cmd $args $options }]
				if {$rc != 0} { return 0 }
			}
			bpgn - bpgn.gz {
				return -code error "BPGN is not yet supported"
			}
			pgn - pgn.gz - zip {
				set type [lsearch -exact $Types(sci) PGNFile]
				set cmd [list ::import::open $parent $file $msg $opts(-encoding) $type]
				set rc [::util::catchException $cmd]
				if {$rc != 0} {
					catch { ::scidb::db::close $file }
					return 0
				}
				set opts(-readonly) 1
			}
		}
		set readonly $opts(-readonly)
		if {$ext == "sci" && [::scidb::db::get upgrade? $file]} {
			set opts(-readonly) 1
			set rc [::dialog::question \
				-parent $parent \
				-message [format $mc::UpgradeDatabase $name] \
				-detail $mc::UpgradeDatabaseDetail \
			]
			if {$rc eq "yes"} {
				set cmd [list ::scidb::db::upgrade $file]
				set options [list -message [format $mc::UpgradeMessage $name]]
				set rc [::util::catchException { ::progress::start $parent $cmd {} $options }]
				::scidb::db::close $file
				if {$rc != 0} { return 0 }
				set cmd [list ::scidb::db::load $file]
				set options [list -message $msg -interrupt yes]
				set rc [::util::catchException { ::progress::start $parent $cmd {} $options }]
				if {$rc != 0} { return 0 }
				set opts(-readonly) $readonly
			}
		}
		if {![::scidb::db::get writeable? $file]} { set opts(-readonly) 1 }
		::scidb::db::set readonly $file $opts(-readonly)
		set type [::scidb::db::get type $file]
		$Vars(switcher) add $file $type $opts(-readonly) $opts(-encoding)
		AddRecentFile $type $file $opts(-encoding) $readonly
		CheckEncoding $parent $file [::scidb::db::get encoding $file]
	} else {
		$Vars(switcher) see $file
		if {$byUser} {
			set msg [format $mc::DatabaseAlreadyOpen [::util::databaseName $file]]
			::dialog::info -parent $parent -message $msg
		}
	}

	if {$opts(-switchToBase)} { Switch $file }
	return 1
}


proc prepareClose {} {
	variable Vars
	variable PreOpen

	set current [::scidb::db::get name]
	set active ""

	set PreOpen {}

	foreach base [$Vars(switcher) bases] {
		set type [$Vars(switcher) type $base]
		if {$type ne [::scidb::db::get clipbase type]} {
			if {$base eq $current} { set active 1 } else { set active 0 }
			set encoding [$Vars(switcher) encoding $base]
			set readonly [$Vars(switcher) readonly? $base]
			lappend PreOpen [list $type $base $encoding $readonly $active]
		}
	}
}


proc closeBase {parent {file {}}} {
	::remote::busyOperation { CloseBase $parent $file }
}


proc newBase {parent variant file {encoding ""}} {
	variable Vars
	variable Types

	set file [file normalize $file]

	if {[$Vars(switcher) contains? $file]} {
		set msg [format $mc::DatabaseAlreadyOpen [::util::databaseName $file]]
		::dialog::error -parent $parent -message $msg
	} else {
		set type Unspecific
		::widget::busyCursor on
		::scidb::db::new $file $variant [lsearch -exact $Types(sci) $type] {*}$encoding
		::scidb::db::attach $file $file
		set encoding [::scidb::db::get encoding $file]
		$Vars(switcher) add $file $type no $encoding
		AddRecentFile $type $file $encoding no
		::widget::busyCursor off
	}

	Switch $file $variant
}


proc refreshBase {base} {
	variable Vars

	::scidb::db::switch $base [$Vars(switcher) variant?]
	$Vars(switcher) update $base
}


proc selectEvent {base variant index} {
	variable Vars

	events::select $Vars(events) $base $variant $index

	if {[winfo toplevel $Vars(events)] eq $Vars(events)} {
		events::activate $Vars(events) 1
	}
}


proc selectSite {base variant index} {
	variable Vars

	sites::select $Vars(sites) $base $variant $index

	if {[winfo toplevel $Vars(sites)] eq $Vars(sites)} {
		sites::activate $Vars(sites) 1
	}
}


proc selectPlayer {base variant index} {
	variable Vars

	players::select $Vars(players) $base $variant $index

	if {[winfo toplevel $Vars(players)] eq $Vars(players)} {
		players::activate $Vars(players) 1
	}
}


proc setFocus {} {
	focus [set [namespace current]::Vars(switcher)]
}


proc addRecentlyUsedToMenu {parent m} {
	variable RecentFiles
	variable Vars

	set recentFiles {}
	foreach entry $RecentFiles {
		set file [lindex $entry 1]
		if {![$Vars(switcher) contains? $file]} {
			lappend recentFiles $entry
		}
	}

	if {[llength $recentFiles]} {
		foreach entry $recentFiles {
			lassign $entry type file encoding readonly
			if {[string match $::scidb::dir::home* $file]} {
				set file [string replace $file 0 [expr {[string length $::scidb::dir::home] - 1}] "~"]
			}
			set name [::util::databaseName $file]
			set dir [file dirname $file]
			$m add command \
				-label " $name  \u25b8  $dir" \
				-image [set [namespace current]::icons::${type}(16x16)] \
				-compound left \
				-command [namespace code \
					[list openBase $parent $file yes -encoding $encoding -readonly $readonly]] \
				;
		}
		$m add separator
		$m add command \
			-label " $::game::mc::ClearHistory" \
			-image $::icon::16x16::clear \
			-compound left \
			-command [namespace code ClearHistory] \
			;
	}

	return [llength $recentFiles]
}


proc OpenArchive {parent file byUser args} {
	variable _Select

	lassign [::archive::inspect $file] header files
	if {[llength $header] == 0} { return [::log::show] }

	set bases {}
	set overwrite {}

	foreach entry $files {
		foreach pair $entry {
			lassign $pair attr value
			if {$attr eq "FileName"} {
				switch [file extension $value] {
					.sci - .si3 - .si4 - .cbh - .pgn - .pgn.gz - .bpgn - .bpgn.gz {
						lappend bases $value
						if {[file exists $value]} { lappend overwrite "\u26ab [file tail $value]" }
					}
				}
			}
		}
	}

	if {[llength $bases] == 0} { return 1 }
	set dirname [file dirname $file]
	if {[llength $overwrite] > 0} {
		append msg [format $mc::OverwriteExistingFiles $dirname]
		append msg "\n\n"
		append msg [join $overwrite \n]
		set answer [::dialog::question -parent $parent -message $msg -default no]
		if {$answer eq "no"} { return 1 }
	}

	set progress $parent.__progress
	::dialog::progressbar::open $progress \
		-mode indeterminate \
		-message [format $mc::ExtractArchive [file rootname [file tail $file]]] \
		;
	set rc [::archive::unpack $file ::menu::archive::getName $progress $dirname]
	destroy $progress
	if {!$rc} { return [::log::show] }

	if {[llength $bases] == 1} {
		return [openBase $parent [lindex $bases 0] $byUser {*}$args]
	}

	set dlg $parent.__choose__
	toplevel $dlg -class Scidb
	bind $dlg <Escape> [list $dlg.cancel invoke]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg [string trim [format $mc::LoadMessage ""]]
	wm resizable $dlg false false
	set top [ttk::frame $dlg.top]
	pack $top
	ttk::label $top.select -text $mc::SelectDatabases
	grid $top.select -row 1 -column 1
	set r 3
	set n 0
	foreach base $bases {
		set _Select($n) [expr {$n == 0}]
		ttk::checkbutton $top.base$r -text [file tail $base] -variable [namespace current]::_Select($n)
		grid $top.base$r -row $r -column 1 -sticky w
		grid rowconfigure $top [incr r] -minsize $::theme::pady
		incr r
		incr n
	}
	grid rowconfigure $top [list 0 $r] -minsize $::theme::pady
	grid rowconfigure $top 2 -minsize $::theme::padY
	grid columnconfigure $top {0 2} -minsize $::theme::padx
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [namespace code [list OpenBases $parent $dlg $bases $byUser {*}$args]]
	$dlg.cancel configure -command [list destroy $dlg]
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $dlg
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
	return 1
}


proc OpenBases {parent dlg bases byUser args} {
	variable _Select

	array set opts { -readonly -1 -encoding "" -switchToBase 1 }
	array set opts $args
	set opts(-switchToBase) 0

	set n 0
	foreach base $bases {
		if {$_Select($n)} { openBase $parent $base $byUser {*}[array get opts] }
		incr n
	}
	destroy $dlg
}


proc ClearHistory {} {
	variable RecentFiles

	set RecentFiles {}
	#::menu::configureOpenRecent [GetRecentState]
}


proc OpenBase {file readonly} {
	variable Vars
	openBase $Vars(switcher) $file $readonly
}


proc CloseBase {parent file} {
	variable Vars
	variable ::scidb::clipbaseName

	if {[llength $file] == 0} {
		set file [::scidb::db::get name]
		if {$file eq $clipbaseName} { return }
	}

	if {[::game::releaseAll $parent $file]} {
		::widget::busyCursor on
		::scidb::db::close $file
		$Vars(switcher) remove $file
		::widget::busyCursor off
	}
}


proc SwitchVariant {variant} {
	variable Vars

	set Vars(variant) $variant
	$Vars(switcher) variant $variant
	::scidb::db::switch [$Vars(switcher) current?] $variant
}


proc SetClipbaseDescription {} {
	variable ::scidb::clipbaseName
	::scidb::db::set description $clipbaseName $mc::ClipbaseDescription
}


proc TabChanged {} {
	variable Vars

	set tab [lindex [split [$Vars(contents) select] .] end]
	set w $Vars($Vars(current:tab))
	if {$tab ne $Vars(current:tab) && $w ne [winfo toplevel $w]} {
		[namespace current]::[set Vars(current:tab)]::activate $w 0
	}
	[namespace current]::${tab}::activate $Vars($tab) 1
	set Vars(current:tab) $tab

	set tabs [$Vars(contents) tabs]
	foreach t $tabs {
		if {[$Vars(contents) select] eq $t && [llength $tabs] > 2} {
			set icon $icon::16x16::undock
		} elseif {$Vars(showDisabled)} {
			set icon $icon::16x16::undock_disabled
		} else {
			set icon {}
		}
		$Vars(contents) tab $t -image $icon
	}
}


proc SashCmd {w action x y} {
	variable Vars

	switch $action {
		mark {
			set Vars(y) [expr {$y + [games::overhang $Vars(games)]}]
		}

		drag {
			if {$y > $Vars(y)} {
				set y [expr {(($y - $Vars(y))/$Vars(incr))*$Vars(incr) + $Vars(y)}]
			} else {
				set y [expr {$Vars(y) - (($Vars(y) - $y)/$Vars(incr))*$Vars(incr)}]
			}

			set Vars(pixels) 0
		}
	}

	return [list $x $y]
}


proc ToolbarShow {pane} {
	variable Vars

	update idletasks
	set minheight [::toolbar::totalHeight $pane]
	if {$minheight == 1} {
		after idle [namespace code [list ToolbarShow $pane]]
	} else {
		incr minheight [expr {2*[games::borderwidth $Vars(games)]}]
		[winfo parent $pane] paneconfigure $pane -minsize $minheight
	}
}


proc TableMinSize {main pane switcher sizeInfo} {
	variable Vars

	if {[llength $sizeInfo] != 3} { return }
	lassign $sizeInfo minwidth minheight Vars(incr)
	set height [winfo height $pane]
	if {$height == 1} { return }

	incr minheight $height
	incr minheight [expr {-[winfo height $Vars(games)]}]
	incr minheight [expr {2*[games::borderwidth $Vars(games)]}]

	if {!$Vars(lock:minsize)} {
		$main paneconfigure $pane -minsize $minheight
	}

	set h [expr {(($height - $minheight)/$Vars(incr))*$Vars(incr)} + $minheight]
	if {$h > $height} { incr h [expr {-$Vars(incr)}] }
	if {$h < $height} {
		incr Vars(pixels) $height
		incr Vars(pixels) [expr {-$h}]
		if {$Vars(pixels) >= $Vars(incr)} {
			incr h $Vars(incr)
			incr Vars(pixels) [expr {-$Vars(incr)}]
		}
		lassign [$main sash coord 0] x y
		set y [expr {$y + $height - $h}]
		$main sash place 0 $x $y
	}

	after idle [list $Vars(switcher) update]
}


proc LogCopyDb {unused arguments} {
	lassign $arguments type code gameNo
	set line ""

	append line $::import::mc::GameNumber " " [::locale::formatNumber $gameNo]
	append line ": "

	if {[info exists import::mc::$code]} {
		append line [set ::import::mc::$code]
	} else {
		append line $code
	}

	::log::$type $line
	update idletasks
}


proc UpdateVariants {{variant ""}} {
	variable Variants
	variable Vars

	if {[string length $variant]} { set Vars(variant) $variant }

	set usedVariants [::scidb::app::activeVariants]
	foreach variant $Variants {
		if {$variant ni $usedVariants} {
			::toolbar::remove $Vars(widget:$variant)
		} else {
			::toolbar::add $Vars(widget:$variant)
		}
	}

	if {$Vars(variant) ni $usedVariants} {
		SwitchVariant [lindex [::scidb::db::get variants [$Vars(switcher) current?]] 0]
	}
}


proc Switch {filename {variant Undetermined}} {
	variable Vars
	variable Defaults
	variable ::scidb::clipbaseName

	if {$variant eq "Undetermined"} {
		set variant $Vars(variant)
	}

	$Vars(switcher) current $filename
	::scidb::db::switch $filename $Vars(variant)
	set readonly [::scidb::db::get readonly? $filename]

	if {$filename eq $clipbaseName} { set state disabled } else { set state normal }
	if {$filename eq $clipbaseName || ![::scidb::db::get writeable? $filename]} {
		set roState disabled
	} else {
		switch [file extension $filename] {
			.sci 		{ set roState normal }
			default	{ set roState disabled }
		}

		::toolbar::childconfigure $Vars(button:readonly) -tooltip $roState
	}

	#::menu::configureCloseBase $state
	::toolbar::childconfigure $Vars(button:close) -state $state
	::toolbar::childconfigure $Vars(button:readonly) -state $roState

	set Vars(flag:readonly) $readonly
	CheckTabState

	foreach file [$Vars(switcher) bases] {
		if {$file eq $filename} {
			if {$readonly} { set str $mc::SetWriteable } else { set str $mc::SetReadonly }
			set name [::util::databaseName $filename]
			set [namespace current]::_CloseDatabase [format $mc::CloseDatabase $name]
			set [namespace current]::_Readonly [format $str $name]
		}
	}

	foreach tab {players events sites annotators} {
		if {[winfo toplevel $Vars($tab)] eq $Vars($tab)} {
			[namespace current]::${tab}::activate $Vars($tab) 1
		}
	}
}


proc CheckTabState {} {
	variable Vars

	if {[winfo toplevel $Vars(annotators)] ne $Vars(annotators)} {
		set codec [::scidb::db::get codec]
		if {$codec eq "sci" || $codec eq "cbh"} { set state normal } else { set state hidden }
		$Vars(contents) tab $Vars(annotators) -state $state
	}
}


proc Update {path id base variant {view 0} {index -1}} {
	variable Vars

	if {$index >= 0} {
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code { RefreshSwitcher }]]
	}
}


proc RefreshSwitcher {} {
	variable Vars
	$Vars(switcher) update [$Vars(switcher) current?]
}


proc LanguageChanged {} {
	variable Vars
	variable Variants
	variable ::scidb::clipbaseName

	set ::util::clipbaseName [set [namespace current]::mc::T_Clipbase]
	$Vars(switcher) update $clipbaseName [::scidb::db::get variant? $clipbaseName]
	set base [$Vars(switcher) current?]

	if {[::scidb::db::get readonly? $base]} {
		set str $mc::SetWriteable
	} else {
		set str $mc::SetReadonly
	}
	set name [::util::databaseName $base]
	set [namespace current]::_CloseDatabase [format $mc::CloseDatabase $name]
	set [namespace current]::_Readonly [format $str $name]

	foreach t $Vars(windows) {
		set var [namespace current]::mc::[string toupper [lindex [split $t .] end] 0 0]
		if {[winfo toplevel $t] eq $t} {
			wm title $t "$::scidb::app - [::mc::stripAmpersand [set $var]]"
		} else {
			::widget::notebookSetLabel $Vars(contents) $t [set $var]
		}
	}

	::toolbar::childconfigure $Vars(button:new) \
		-tooltip "$mc::NewDatabase ($::mc::VariantName(Normal))..."

	foreach variant $Variants {
		switch $variant {
			Losers {
				set tip "$::mc::VariantName(Antichess) - $::mc::VariantName(Losers)"
			}
			Antichess {
				set tip "$::mc::VariantName(Antichess) - "
				append tip "$::mc::VariantName(Suicide)/$::mc::VariantName(Giveaway)"
			}
			default {
				set tip $::mc::VariantName($variant)
			}
		}
		::toolbar::childconfigure $Vars(widget:$variant) -tooltip $tip
	}
}


proc Close {path base variant} {}


proc ConfigureList {main contents switcher height} {
	variable Vars

	if {[winfo toplevel $Vars(games)] eq $Vars(games)} { return }

	if {[info exists Vars(incr)]} {
		set overhang [games::overhang $Vars(games)]
		set n [expr {($height - $overhang)/$Vars(incr)}]
		set wantedHeight [expr {$n*$Vars(incr) + $overhang + 2}]
		set offset [expr {$height - $wantedHeight}]

		if {$offset != 0 || $Vars(minheight:switcher) == 0} {
			after cancel $Vars(afterid)
			set Vars(afterid) [after 50 [namespace code \
				[list ResizeList $main $contents $switcher $wantedHeight $offset]]]
		}
	}
}


proc ResizeList {main contents switcher wantedHeight offset} {
	variable Vars

	set pixels [expr {$Vars(pixels) + $offset}]
	set n [expr {$pixels/$Vars(incr)}]
	set offset [expr {$offset - $n*$Vars(incr)}]
	set pixels [expr {$pixels - $n*$Vars(incr)}]

	set Vars(pixels) $pixels

	if {$offset != 0 || $Vars(minheight:switcher) == 0} {
		lassign [$main sash coord 0] x y
		incr y $offset

		if {$Vars(minheight:switcher) == 0} {
			set minheight [expr {[$Vars(switcher) minheight] + [::toolbar::totalHeight $switcher] + 2}]
			set Vars(minheight:switcher) $minheight
		}

		while {$Vars(minheight:switcher) > $y} { incr y $Vars(incr) }
		$main sash place 0 $x $y
	}
}


proc PopupMenu {parent x y {base ""}} {
	variable ::scidb::clipbaseName
	variable Defaults
	variable Vars
	variable ::table::options

	if {$Vars(ignore-next)} {
		set Vars(ignore-next) 0
		return
	}

	if {[string length $base] > 0} { set Vars(ignore-next) 1 }
	set menu $parent.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $menu -type popup_menu }
	set top [winfo toplevel $parent]
	set readonly 0
	set isSciFormat 1

	if {[string length $base] > 0 && [$Vars(switcher) active? $base]} {
		set readonly [::scidb::db::get readonly? $base]
		if {$readonly} { set readonlyState disabled } else { set readonlyState normal }
		set ext [$Vars(switcher) extension $base]
		set type [$Vars(switcher) type $base]
		set isSciFormat [expr {$ext eq "sci"}]
		set isClipbase [expr {$base eq $clipbaseName}]
		set name [::util::databaseName $base]
		$menu add command                                    \
			-label " $name"                                   \
			-image $::icon::16x16::none                       \
			-compound left                                    \
			-background $options(menu:headerbackground)       \
			-foreground $options(menu:headerforeground)       \
			-activebackground $options(menu:headerbackground) \
			-activeforeground $options(menu:headerforeground) \
			-font $options(menu:headerfont)                   \
			;
		$menu add separator

		$menu add command \
			-label " $mc::Properties" \
			-image $::icon::16x16::info \
			-compound left \
			-command [namespace code [list $Vars(switcher) show $base]] \
			;
		$menu add command \
			-label " $mc::FileExport..." \
			-image $::icon::16x16::fileExport \
			-compound left \
			-command [list ::export::open $parent $base $Vars(variant) $type $name 0] \
			;
		$menu add command \
			-label " $mc::FileImport(db)..." \
			-image $::icon::16x16::databaseImport \
			-compound left \
			-command [list ::menu::dbImport $top $base db] \
			-state $readonlyState \
			;
		$menu add command \
			-label " $mc::FileImport(pgn)..." \
			-image $::icon::16x16::filetypePGN \
			-compound left \
			-command [list ::menu::dbImport $top $base pgn] \
			-state $readonlyState \
			;

		set maint [menu $menu.maintenance -tearoff no]
		$menu add cascade \
			-menu $maint \
			-label " $mc::FileMaintenance" \
			-image $::icon::16x16::setup \
			-compound left \
			-state $readonlyState \
			;

		if {!$readonly} {
			if {!$isClipbase} {
				$maint add command \
					-label " $mc::ChangeIcon..." \
					-image $::icon::16x16::none \
					-compound left \
					-command [namespace code [list ChangeIcon $top $base]] \
					-state $readonlyState \
					;
				$maint add command \
					-label " $mc::EditDescription..." \
					-image $::icon::16x16::edit \
					-compound left \
					-command [namespace code [list EditDescription $parent $base]] \
					-state $readonlyState \
					;
			}

			if {$isClipbase || $ext eq "sci"} {
				set count [::scidb::db::count games $base $Vars(variant)]
				if {$count} { set state $readonlyState } else { set state disabled }
				$maint add command \
					-label " $mc::FileStripMoveInfo" \
					-image $::icon::16x16::delete \
					-compound left \
					-command [namespace code [list StripMoveInfo $parent $base]] \
					-state $state \
					;
				$maint add command \
					-label " $mc::FileStripPGNTags..." \
					-image $::icon::16x16::delete \
					-compound left \
					-command [namespace code [list StripPGNTags $parent $base]] \
					-state $state \
					;
				if {[::scidb::db::get compress? $base]} { set state normal } else { set state disabled }
				$maint add command \
					-label " $mc::FileCompact..." \
					-image $::icon::16x16::none \
					-compound left \
					-command [namespace code [list Compact $top $base]] \
					-state $state \
			}

			$maint add command \
				-label " $mc::FileCreate..." \
				-image $::icon::16x16::filetypeArchive \
				-compound left \
				-command [list ::menu::dbCreateArchive $top $base] \
				;
		}

		if {!$isClipbase} {
			$menu add command \
				-label " $mc::FileClose" \
				-image $::icon::16x16::close \
				-compound left \
				-command [namespace code [list closeBase $parent $base]] \
				;
		} else {
			set count [::scidb::db::count games $base $Vars(variant)]
			if {$count} { set state normal } else { set state disabled }
			$menu add command \
				-label " $mc::EmptyClipbase" \
				-image $::icon::16x16::trash \
				-compound left \
				-command [namespace code [list EmptyClipbase $parent]] \
				-state $state \
				;
		}
		switch $ext {
			si3 - si4 - cbh - pgn - bpgn {
				if {[file readable $base]} { set state normal } else { set state disabled }
				$menu add command \
					-label " $mc::Recode..." \
					-image $::icon::16x16::none \
					-compound left \
					-command [namespace code [list Recode $base $top]] \
					-state $state
					;
			}
		}

		$menu add separator

		if {!$isClipbase && $ext eq "sci"} {
			if {![::scidb::db::get writeable? $base]} { set state disabled } else { set state normal }
			$menu add checkbutton \
				-label " $::database::switcher::mc::ReadOnly" \
				-image $::icon::16x16::lock \
				-compound left \
				-command [namespace code ToggleReadOnly] \
				-variable [namespace current]::Vars(flag:readonly) \
				-state $state \
				;
			$menu add separator
		}
	}

	$menu add command \
		-label " $mc::FileOpen..." \
		-image $::icon::16x16::databaseOpen \
		-compound left \
		-command [list ::menu::dbOpen $top] \
		;

	set m [menu $menu.mOpenRecent -tearoff false]
	set state normal
	if {[addRecentlyUsedToMenu [winfo parent [winfo parent $parent]] $m] == 0} { set state disabled }
	$menu add cascade \
		-menu $m \
		-label " [::mc::stripAmpersand $mc::FileOpenRecent]" \
		-image $::icon::16x16::databaseOpen \
		-compound left \
		-state $state \
		;

	$menu add command \
		-label " $mc::FileNew ($::mc::VariantName(Normal))..." \
		-image $::icon::16x16::databaseNew \
		-compound left \
		-command [list ::menu::dbNew $top Normal] \
		;

	menu $menu.mFileNew -tearoff 0
	$menu add cascade \
		-menu $menu.mFileNew \
		-label " $mc::FileNew..." \
		-image $::icon::16x16::databaseNewAlt \
		-compound left \
		;
	::menu::addVariantsToMenu $top $menu.mFileNew

#	if {$index == -1 && [::scidb::db::get name] ne $clipbaseName} {
#		$menu add separator
#		set name [::util::databaseName [::scidb::db::get name]]
#		set text [format [set [namespace current]::mc::Close] $name]
#		set cmd [namespace code [list closeBase $parent]]
#		$menu add command -label " $text" -image $::icon::16x16::close -compound left -command $cmd
#	}

	$menu add separator
	set m [menu $menu.mIconSize -tearoff false]
	$menu add cascade              \
		-menu $m                    \
		-label " $mc::SymbolSize"   \
		-image $::icon::16x16::none \
		-compound left              \
		;
	foreach {name size} {Large 48 Medium 32 Small 24 Tiny 16} {
		$m add checkbutton                                   \
			-label [set mc::$name]                            \
			-onvalue $size                                    \
			-offvalue $size                                   \
			-variable ::database::switcher::Options(iconsize) \
			;
	}

	$menu add separator
	$menu add command \
		-label " [::mc::stripAmpersand $mc::HelpSwitcher]..." \
		-image $::icon::16x16::help \
		-compound left \
		-command [list ::help::open .application Database-Switcher] \
		;

	::tooltip::hide
	tk_popup $menu $x $y
}


proc PopdownFileNew {} {
	variable Vars

	set parent $Vars(button:new...)
	set m $parent.dbNew
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	::menu::addVariantsToMenu $parent $m
	tk_popdown $m $parent
}


proc ToggleReadOnly {} {
	variable Vars
	variable RecentFiles

	set file [::scidb::db::get name]
	::scidb::db::set readonly $Vars(flag:readonly)
	$Vars(switcher) readonly $file $Vars(flag:readonly)

	set k [FindRecentFile $file]
	if {$k >= 0} { lset RecentFiles $k 3 $Vars(flag:readonly) }

	if {$Vars(flag:readonly)} { set str $mc::SetWriteable } else { set str $mc::SetReadonly }
	set [namespace current]::_Readonly [format $str [::util::databaseName $file]]
}


proc EmptyClipbase {parent} {
	variable ::scidb::clipbaseName
	variable Vars

	if {[::game::releaseAll $parent $clipbaseName $Vars(variant)]} {
		::widget::busyCursor on
		::scidb::db::clear $clipbaseName $Vars(variant)
		::widget::busyCursor off
	}
}


proc EditDescription {parent file} {
	variable Vars

	set s [::scidb::db::get description $file]
	set s [string map {"\r\n" "\\n"} $s]
	set s [string map {"\t" "\\t" "\n" "\\n" "\r" ""} $s]
	set Vars(description) $s
	set dlg [tk::toplevel $parent.descr -class Dialog]
	set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]
	pack $top -fill both
	::ttk::entry $top.entry -takefocus 1 -width 80 -textvar [namespace current]::Vars(description)
	$top.entry selection range 0 end
	$top.entry icursor end
	pack $top.entry -fill x -padx $::theme::padx -pady $::theme::pady
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [namespace code [list SetDescription $dlg $file]]
	$dlg.cancel configure -command [list destroy $dlg]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg "$mc::EditDescription ([::util::databaseName $file])"
	wm resizable $dlg false false
	::util::place $dlg below $parent
	wm deiconify $dlg
	focus $top.entry
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc SetDescription {dlg file} {
	variable Vars

	set Vars(description) [string trim $Vars(description)]
	set s [string map {"\\t" "\t" "\\n" "\n"} $Vars(description)]
	set length [::scidb::db::set description $file $s]

	if {$length == 0} {
		destroy $dlg
	} else {
		::dialog::error \
			-parent $dlg \
			-message $mc::DescriptionTooLarge \
			-detail [format $mc::DescrTooLargeDetail [string length $Vars(description)] $length] \
			;
	}
}


proc StripMoveInfo {parent file} {
	return [::beta::notYetImplemented $parent strip-move-info]
}


proc StripPGNTags {parent file} {
	return [::beta::notYetImplemented $parent strip-move-tags]
}


proc Compact {parent file} {
	set msg [format $mc::ReallyCompact [::util::databaseName $file]]
	set n [lindex [::scidb::db::get stats $file] 0]
	if {$n == 1} {
		set detail $mc::ReallyCompactDetail(1)
	} else {
		set detail [format $mc::ReallyCompactDetail(N) $n]
	}
	set reply [::dialog::question \
		-parent $parent \
		-title "$::scidb::app: $mc::FileCompact" \
		-message $msg \
		-detail $detail \
		-buttons {yes no} \
		-default no \
	]
	if {$reply eq "yes"} {
		set variant [::scidb::app::variant]

		if {[::game::closeAll $parent $file $variant $mc::FileCompact $mc::CompactDetail]} {
			::browser::closeAll $file $variant
			::overview::closeAll $file $variant
			set cmd [list ::scidb::db::compact $file]
			set name [::util::databaseName $file]
			set options [list -message [format $mc::CompactMessage $name]]
			::util::catchException { ::progress::start $parent $cmd {} $options }
		}
	}
}


proc Recode {file parent} {
	variable RecentFiles
	variable Types
	variable Vars

	set enc [::scidb::db::get encoding $file]
	set ext [$Vars(switcher) extension $file]
	if {$ext eq "cbh"} {
		set defaultEncoding $::encoding::windowsEncoding
	} else {
		set defaultEncoding utf-8
	}
	set encoding [::encoding::choose $parent $enc $defaultEncoding]
	if {[llength $encoding] == 0 || $encoding eq $enc} { return }

	::log::open $mc::Recode
	set name [::util::databaseName $file]
	::log::info [string map [list "%base" $name "%from" $enc "%to" $encoding] $mc::RecodingDatabase]

	switch $ext {
		pgn - bpgn {
			::import::showOnlyEncodingWarnings true
			closeBase $parent $file
			openBase $parent $file no -encoding $encoding -readonly yes
			::import::showOnlyEncodingWarnings false
		}

		default {
			::progress::start $parent [list ::scidb::db::recode $file $encoding] {} {}
		}
	}

	set count [::scidb::db::count total $file]
	::log::info [format $mc::RecodedGames [::locale::formatNumber $count]]
	::log::close

	$Vars(switcher) encoding $file $encoding
	set i [lsearch -exact -index 1 $RecentFiles $file]
	if {$i >= 0} { lset RecentFiles $i 2 $encoding }
}


proc CheckEncoding {parent file encoding} {
	if {[::scidb::db::get encodingState $file] eq "failed"} {
		::dialog::warning -parent $parent -buttons {ok} -message [format $mc::EncodingFailed $encoding]
	}
}


proc ChangeIcon {parent file} {
	variable Types
	variable Options
	variable Vars

	set dlg [tk::toplevel $parent.changeIcon -class Dialog]
	set ext [$Vars(switcher) extension $file]
	if {[winfo screenheight $parent] >= 650} { set rows 10 } else { set rows 9 }
	set cols [expr {([llength $Types($ext)] + $rows - 1)/$rows}]
	set list [::tlistbox $dlg.list \
		-visible $Options(visible) \
		-linespace 48 \
		-skiponeunit no \
		-columns $cols \
		-height $rows \
		-ipady 5 \
	]
	pack $list -expand yes -fill both
	$list addcol image -id image
	$list addcol text -id text

	set typeList {}
	foreach t $Types($ext) { lappend typeList [list $t [set mc::T_$t]] }
	set typeList [lsort -index 1 $typeList]

	foreach entry $typeList {
		lassign $entry t text
		$list insert [list [set [namespace current]::icons::${t}(48x48)] $text]
	}
	$list resize

	set type [$Vars(switcher) type $file]
	set Vars(icon) [lsearch -exact -index 0 $typeList $type]
	bind $list <Configure> [namespace code { ConfigureIconList %W }]
	bind $list <Escape> [list $dlg.cancel invoke]
	bind $list <<ListboxSelect>> [namespace code [list SelectIcon %W %d $typeList $file]]
	$list select $Vars(icon)
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [namespace code [list SetIcon $dlg $typeList $file]]
	$dlg.cancel configure -command [list destroy $dlg]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg "$mc::ChangeIcon ([::util::databaseName $file])"
	wm resizable $dlg false false
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $dlg.list
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc SelectIcon {w data typeList file} {
	variable Vars

	if {$data eq ""} {
		SetIcon $w $typeList $file
	} else {
		set Vars(icon) $data
	}
}


proc SetIcon {w typeList file} {
	variable Vars
	variable Types
	variable Defaults
	variable RecentFiles
	
	set type [lindex $typeList $Vars(icon) 0]
	set selection [lsearch -exact $Types(sci) $type]
	set type [lindex $Types(sci) $selection]
	$Vars(switcher) type $file $type
	::scidb::db::set type $file $selection
	destroy [winfo toplevel $w]
	lset RecentFiles [FindRecentFile $file] 0 $type
}


proc ConfigureIconList {w} {
	variable Options
	set Options(visible) [$w cget -height]
}


proc AddRecentFile {type file encoding readonly} {
	variable RecentFiles
	variable MaxHistory

	set i [FindRecentFile $file]
	if {$i >= 0} { set RecentFiles [lreplace $RecentFiles $i $i] }
	set RecentFiles [linsert $RecentFiles 0 [list $type $file $encoding $readonly]]
	if {[llength $RecentFiles] > $MaxHistory} { set RecentFiles [lrange $RecentFiles 0 9] }
	#::menu::configureOpenRecent [GetRecentState]
}


proc GetRecentState {} {
	variable RecentFiles
	variable Vars

	set count 0

	foreach entry $RecentFiles {
		set file [lindex $entry 1]
		if {![$Vars(switcher) contains? $file]} { incr count }
	}

	if {$count == 0} { return disabled }
	return normal
}


proc FindRecentFile {file} {
	variable RecentFiles
	return [lsearch -index 1 $RecentFiles $file]
}


# proc MakePhoto {path} {
# 	set parent [join [lrange [split $path .] 0 end-1] .]
# 	if {[winfo width $parent] <= 1} { return }
# 	pack [::tk::canvas $path -borderwidth 0]
# 	set src [image create photo -file "SunergosGreyWallpaper-0.0.1-full.jpg"]
# 	set dst [image create photo -width  [winfo width $parent] -height [winfo height $parent]]
# 	::scidb::tk::image copy $src $dst
# 	$path create image 0 0 -anchor nw -image $dst
# 	$path configure -width [image width $dst] -height [image height $dst]
# 	bind [winfo parent $path] <Configure> {#}
# }
# 
# 
# proc MakePhoto {path} {
# 	pack [::tk::canvas $path -borderwidth 0]
# 	set img [::splash::picture]
# 	$path create image 0 0 -anchor nw -image $img
# 	$path configure -width [image width $img] -height [image height $img]
# 	bind [winfo parent $path] <Configure> {#}
# }
# 
# 
# proc MakeBackground {path} {
# 	variable Vars
# 
# 	if {[winfo exists $path]} {
# 		set img $Vars(tile)
# 	} else {
# 		pack [::tk::canvas $path] -fill both -expand yes
# 		set img [image create photo -file "chessboard-tile.png"]
# 		set Vars(tile) $img
# 	}
# 
# 	set ih [image height $img]
# 	set iw [image width  $img]
# 	set ch [winfo height [winfo parent $path]]
# 	set cw [winfo width  [winfo parent $path]]
# 
# 	for {set x 0} {$x < $cw} {incr x $iw} {
# 		for {set y 0} {$y < $ch} {incr y $ih} {
# 			if {[llength [$path find withtag tile:$x:$y]] == 0} {
# 				$path create image $x $y -anchor nw -image $img -tags [list tile tile:$x:$y]
# 			}
# 		}
# 	}
# }


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::RecentFiles
	::options::writeItem $chan [namespace current]::Defaults
	::options::writeList $chan [namespace current]::PreOpen
	::options::writeItem $chan [namespace current]::Positions
}

::options::hookWriter [namespace current]::WriteOptions


proc DestroyTab {w tab} {
	variable Positions

	if {$w eq $tab} {
		if {[winfo toplevel $w] eq $w} {
			set Positions([lindex [split $w .] end]) [wm geometry $w]
		}
	}
}


proc Identify {nb x y} {
	set index [$nb index @$x,$y]
	if {[llength $index] == 0} { return {-1 ""} }
	if {[llength [$nb tab $index -image]] == 0} { return [list $index "label"] }
	if {[$nb identify $x $y] ne "label"} { return [list $index ""] }
	set x1 $x
	while {[$nb identify [expr {$x1 + 1}] $y] eq "label"} { incr x1 +1 }
	incr x1 -16
	if {$x1 <= $x} { return [list $index "icon"] }
	return [list $index "label"]
}


proc Motion {nb x y {showTooltip 1}} {
	variable Vars

	if {[llength [$nb tabs]] == 2} { return }
	lassign [Identify $nb $x $y] index what
	if {$index == -1} { set what "label" }

	switch $what {
		icon {
			if {[$nb tab $index -image] eq $icon::16x16::undock_disabled} { return }
			if {$Vars(pressed)} {
				set icon $icon::16x16::undock_sunken
			} else {
				set icon $icon::16x16::undock_active
				if {$index != $Vars(motion) && $showTooltip} {
					::tooltip::show $nb $::twm::mc::Undock
				}
			}
			set Vars(motion) $index
		}

		label {
			return [Leave $nb]
		}

		default {
			if {$index >= 0} {
				if {[$nb index [$nb select]] == $index} {
					set icon $icon::16x16::undock
				} elseif {$Vars(showDisabled)} {
					set icon $icon::16x16::undock_disabled
				} else {
					set icon {}
				}
			}
			set Vars(motion) -1
			::tooltip::hide
		}
	}

	if {$index >= 0} {
		$nb tab $index -image $icon
	}
}


proc Enter {nb} {
	variable Vars

	if {[llength [$nb tabs]] == 2} { return }

	if {$Vars(motion) >= 0 && $Vars(motion) < [llength [$nb tabs]]} {
		set icon [$nb tab $Vars(motion) -image]

		if {[llength $icon] > 0 && $icon ne $icon::16x16::undock_disabled} {
			$nb tab $Vars(motion) -image $icon::16x16::undock
			set Vars(motion) -1
		}
	}
}


proc Leave {nb} {
	variable Vars

	::tooltip::hide
	if {[llength [$nb tabs]] == 2} { return }

	if {$Vars(motion) >= 0} {
		foreach t [$nb tabs] {
			set icon [$nb tab $t -image]
			if {[llength $icon] > 0 && $icon ne $icon::16x16::undock_disabled} {
				$nb tab $t -image $icon::16x16::undock
			}
		}
		set Vars(motion) -1
	}
}


proc ButtonPress {nb x y} {
	variable Vars

	::tooltip::hide
	lassign [Identify $nb $x $y] index what
	if {$what eq "icon" && [$nb index [$nb select]] != $index} { set what "label" }

	switch $what {
		icon {
			if {[llength [$nb tabs]] == 2} { return }
			if {[$nb tab $index -image] eq $icon::16x16::undock_disabled} { return }
			$nb tab $index -image $icon::16x16::undock_sunken
			set Vars(pressed) 1
	}

		label {
			set Vars(current) $index
			ttk::notebook::Press $nb $x $y
			after idle [namespace code [list Motion $nb $x $y 0]]
		}
	}
}


proc ButtonRelease {nb x y} {
	variable Vars

	set Vars(pressed) 0
	set current $Vars(current)
	set Vars(current) -1

	if {[llength [$nb tabs]] == 2} { return }
	lassign [Identify $nb $x $y] index what
	if {$index == -1} { set index $Vars(motion) }

	if {$index >= 0} {
		if {$current == $index} { return }
		if {[llength [$nb tab $index -image]] == 0} { return }
		if {[$nb tab $index -image] eq $icon::16x16::undock_disabled} { return }
		$nb tab $index -image $icon::16x16::undock
	}

	if {$what eq "icon"} {
		Undock $nb $index
	}

	::tooltip::hide
	after idle [namespace code [list Motion $nb $x $y 0]]
}


proc Undock {nb index {geometry {}}} {
	variable Vars

	set title [$nb tab $index -text]
	set w [lindex [$nb tabs] $index]
	$nb forget $w
	if {[string length $geometry] == 0} {
		set wd [winfo width $w]
		set ht [winfo height $w]
		if {$wd <= 1 || $ht <= 1} {
			set v [lindex [$nb tabs] 0]
			set wd [winfo width $v]
			set ht [winfo height $v]
		}
	}
	::scidb::tk::twm release $w
	update idle ;# is reducing flickering
	if {[string length $geometry] == 0} {
		wm geometry $w ${wd}x${ht}
	} else {
		wm geometry $w $geometry
	}
	set id [lindex [split $w .] end]
	set overhang [${id}::overhang $Vars($id)]
	set linespace [${id}::linespace $Vars($id)]
	set minheight [expr {8*$linespace + $overhang}]
#	wm transient $w [winfo toplevel $nb]
	wm minsize $w 500 $minheight
	wm title $w "$::scidb::app - $title"
	wm state $w normal
	wm protocol $w WM_DELETE_WINDOW [namespace code [list Dock $nb $w]]
}


proc Dock {nb w} {
	variable Vars

	if {[llength [$nb tabs]] == 2} {
		$nb tab [$nb select] -image $icon::16x16::undock
	}
	::scidb::tk::twm capture $w
	set id [lindex [split $w .] end]
	set indices {}
	foreach t [$nb tabs] {
		set i [lsearch -exact $Vars(taborder) [lindex [split $t .] end]]
		lappend indices $i
	}
	set indices [lsort -integer $indices]
	set i [lsearch -exact $Vars(taborder) $id]
	set k 0
	while {$k < [llength $indices] && [lindex $indices $k] < $i} { incr k }
	if {$k == [llength [$nb tabs]]} { set k end }
	if {$Vars(showDisabled)} { set icon $icon::16x16::undock_disabled } else { set icon {} }
	$nb insert $k $w -sticky nsew -compound right -image $icon
	set var [namespace current]::mc::[string toupper $id 0 0]
	::widget::notebookSetLabel $nb $w [set $var]
	${id}::activate $Vars($id) 0
	CheckTabState
}


namespace eval icon {
namespace eval 16x16 {

set undock [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA2FBMVEUAAAAAAAAAAAAAAAAB
	DhcAAAAAAxQ9PT0uLi53d3ZOTk5Tk6tFRUVCQkIQT2hVla08PDw6Ojo3Nzc2NjZAhJ5so7OH
	h4ZycnKJpqJambCLtrcYYn7FxMRHaXeBta99rbbLy8oeY32goJ9xmJShoaC1tbXAwL8qc460
	tLS2tbS3t7ZzjZbIyMiTk5N+pLIAAAAAAAAAAAAAAAAAAACKucK/v77AwL/BwcDExMTKycnR
	0dHj4+Lp6Oft7ezt7e3u7u3u7u7v7+7w8O/w8PDx8fDy8vHz8/L09PQeL5dpAAAAAXRSTlMA
	QObYZgAAAFhJREFUGNNjYCAXGBsaGgMBkoAJCOjDeMZ6EAEDCF8dyDN2tHVwcjHSAQtogwSc
	nF3d3KFmaBrbWBpDgBpYQMPY2srC3NRMF2aDlrGDvb2tHbKdEMBANQAAtIkRPpJ+I/QAAAAA
	SUVORK5CYII=
}]

set undock_active [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA21BMVEUAAAAAAAAAAAAAAAAB
	DhcAAAAAAxQ9PT0uLi53d3ZOTk5Tk6tFRUVCQkIQT2hVla08PDw6Ojo3Nzc2NjZAhJ5so7OH
	h4ZycnKJpqJambCLtrcYYn7FxMRHaXeBta99rbbLy8oeY32goJ9xmJShoaC1tbXAwL8qc460
	tLS2tbS3t7ZzjZbIyMiTk5N+pLIAAAAAAAAAAAAAAAAAAACKucK/v77AwL/BwcDExMTKycnR
	0dHj4+Lp6Oft7ezt7e3u7u3u7u7v7+7w8O/w8PDx8fDy8vHz8/L09PT///8tKC41AAAAAXRS
	TlMAQObYZgAAAGZJREFUGNNj8EADDB4MKEAMl4CxoaExECAJmICAPlTA2FgPImAAEVAH8owd
	bR2cXIx0wALaIAEnZ1c3d6gZmsY2lsYQoAYW0DC2trIwNzXThVmrZexgb29rZ4xwB1Q9fpfi
	FRBDBQA1Mxx0CnVnXwAAAABJRU5ErkJggg==
}]

set undock_sunken [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA2FBMVEUAAAAAAAAAAAABDhcA
	AAAAAxQ9PT0uLi53d3ZOTk5Tk6tFRUVCQkIQT2hVla08PDw6Ojo3Nzc2NjZAhJ5so7OHh4Zy
	cnKJpqJambCLtrcYYn7FxMRHaXeBta99rbbLy8oeY32goJ9xmJShoaC1tbXAwL8qc460tLS2
	tbS3t7ZzjZbIyMiTk5N+pLIAAAAAAAAAAAAAAAAAAACKucK/v77AwL/BwcDExMTKycnR0dHj
	4+Lp6Oft7ezt7e3u7u3u7u7v7+7w8O/w8PDx8fDy8vHz8/L09PT///9HJVJiAAAAAXRSTlMA
	QObYZgAAAGZJREFUGNNjEEUDDKIMKMAdl4CRgYERECAJGIOAHlTAyEgXIqAPEVAD8owcbOwd
	nQ21wQJaIAFHJxdXN6gZGkbWFkYQoAoWUDeysjQ3MzHVgVmraWRvZ2dja4RwB1Q9fpfiFXBH
	BQCaEhuBKwIaLAAAAABJRU5ErkJggg==
}]

set undock_disabled [image create photo -width 16 -height 16]
::scidb::tk::image disable $undock $undock_disabled

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace database
} ;# namespace application

ttk::copyBindings TNotebook UndockingNotebook

bind UndockingNotebook <Motion>				{ application::database::Motion %W %x %y }
bind UndockingNotebook <Enter>				{ application::database::Enter %W }
bind UndockingNotebook <Leave>				{ application::database::Leave %W }
bind UndockingNotebook <ButtonPress-1>		{ application::database::ButtonPress %W %x %y }
bind UndockingNotebook <ButtonRelease-1>	{ application::database::ButtonRelease %W %x %y }

# vi:set ts=3 sw=3:
