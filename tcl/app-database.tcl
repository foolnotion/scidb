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

::util::source database-pane

namespace eval application {
namespace eval database {
namespace eval mc {

set FileOpen						"Open..."
set FileOpenRecent				"Open Recent"
set FileNew							"New..."
set FileExport						"Export..."
set FileImport(pgn)				"Import PGN files..."
set FileImport(db)				"Import Databases..."
set FileCreate						"Create Archive..."
set FileClose						"Close"
set FileCompact					"Compact"
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
set Empty							"empty"
set None								"none"
set Failed							"failed"
set LoadMessage					"Opening database %s"
set UpgradeMessage				"Upgrading database %s"
set CompactMessage				"Compacting database %s"
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
set UriRejectedDetail(open)	"Only Scidb databases can be opened:"
set UriRejectedDetail(import)	"Only Scidb databases can be imported:"
set EmptyUriList					"Drop content is empty."
set OverwriteExistingFiles		"Overwrite exisiting files in directory '%s'?"
set SelectDatabases				"Select the databases to be opened"
set ExtractArchive				"Extract archive %s"
set CompactDetail					"All games must be closed before a compaction can be done."
set ReallyCompact					"Really compact database '%s'?"
set ReallyCompactDetail(1)		"Only one game will be deleted."
set ReallyCompactDetail(N)		"%s games will be deleted."
set CopyGames						"Copy games"
set CopyGamesFromTo				"Copy games from '%src' to '%dst'"
set CopiedGames					"%s game(s) copied"
set NoGamesCopied					"No games copied"
set CopyAllGames					"Copy all games (%num) from '%src'"
set CopyFilteredGames			"Copy only filtered games (%num) from '%src'"
set ImportGames					"Import games"
set ImportOneGameTo(0)			"Import one game to '%dst'?"
set ImportOneGameTo(1)			"Import about one game to '%dst'?"
set ImportGamesTo(0)				"Import %num games to '%dst'?"
set ImportGamesTo(1)				"Import about %num games to '%dst'?"
set ImportFiles					"Import Files:"

set RecodingDatabase				"Recoding %base from %from to %to"
set RecodedGames					"%s game(s) recoded"

set GameCount						"Games"
set DatabasePath					"Database path"
set DeletedGames					"Deleted Games"
set Description					"Description"
set Created							"Created"
set LastModified					"Last modified"
set Encoding						"Encoding"
set YearRange						"Year range"
set RatingRange					"Rating range"
set Result							"Result"
set Score							"Score"
set Type								"Type"
set ReadOnly						"Read only"

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
	ignore-button1	0
	dragging			0
	drag-item		-1
	drop-item		-1
	curr-item		-1
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
	prop:background	#aee239
}

variable ClipbaseType	[::scidb::db::get clipbase type]
variable PreOpen			{}
variable RecentFiles		{}
variable MaxHistory		10

array set Positions		{}

set Types(sci)				[::scidb::db::get types sci]
set Types(si3)				[::scidb::db::get types si3]
set Types(si4)				[::scidb::db::get types si4]

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min


proc build {tab width height} {
	variable ::scidb::clipbaseName
	variable ClipbaseType
	variable Vars

	set ::util::clipbaseName [set [namespace current]::mc::T_Clipbase]

	set main [tk::panedwindow $tab.main \
		-orient vertical \
		-opaqueresize true \
		-borderwidth 0 \
		-sashcmd [namespace code SashCmd] \
	]
	pack $main -fill both -expand yes

	set switcher [::ttk::frame $main.switcher -borderwidth 1 -relief sunken]
	set contents [::ttk::notebook $tab.contents -class UndockingNotebook -takefocus 1]
	::ttk::notebook::enableTraversal $contents
	::theme::configurePanedWindow $main
	BuildSwitcher $switcher

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

	::toolbar::add $tbFile button \
		-image $::icon::toolbarDocNew \
		-tooltipvar [namespace current]::mc::NewDatabase \
		-command [list ::menu::dbNew $main] \
		;
	::toolbar::add $tbFile button \
		-image $::icon::toolbarDocOpen \
		-tooltipvar [namespace current]::mc::OpenDatabase \
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

	::scidb::db::subscribe gameList [namespace current]::Update [namespace current]::Close {}
	after idle [namespace code [list ToolbarShow $switcher]]

	set Vars(bases) {}
	set Vars(switcher) $switcher
	set Vars(contents) $contents
	set Vars(windows) [$contents tabs]
#	set Vars(history) $history
#	set Vars(blank) $blank
	set Vars(current:tab) games
	set Vars(selection) 0
	set Vars(after) {}
	set Vars(lock:minsize) 0
	set Vars(minheight:switcher) 0

	bind $contents <<NotebookTabChanged>> [namespace code TabChanged]
	bind $contents <<LanguageChanged>> [namespace code LanguageChanged]

	AddBase $ClipbaseType $::scidb::clipbaseName no
	SetClipbaseDescription
	bind $contents <<LanguageChanged>> +[namespace code SetClipbaseDescription]
	Switch $clipbaseName
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
	after idle [namespace code RegisterDragDropEvents]
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


proc openBase {parent file byUser args} {
	variable Vars
	variable RecentFiles
	variable Types
	variable Defaults

	set file [file normalize $file]

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
		return [::remote::busyOperation { OpenArchive $parent $file $byUser $args }]
	}

	array set opts { -readonly -1 -encoding "" -switchToBase 1 }
	array set opts $args

	if {$opts(-encoding) eq $::encoding::mc::AutoDetect} {
		set opts(-encoding) $::encoding::autoEncoding
	}
	set i [lsearch -exact -index 2 $Vars(bases) $file]
	if {$i == -1} {
		set ext [string range [file extension $file] 1 end]
		foreach entry $Vars(bases) {
			if {$ext eq [lindex $entry 3]} {
				set f [lindex $entry 2]
				if {[::scidb::misc::hardLinked? $file $f]} {
					set msg [string map [list "%file1" $file "%file2" $f] $mc::HardLinkDetected]
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
				sci - si3 - si4 - cbh	{ set opts(-encoding) auto }
				pgn - gz - zip				{ set opts(-encoding) $::encoding::defaultEncoding }
			}
		}
		switch $ext {
			sci - si3 - si4 - cbh {
				set args {}
				if {$opts(-readonly) == -1} {
					switch $ext {
						cbh			{ set opts(-readonly) 1 }
						si3 - si4	{ set opts(-readonly) $Defaults(si4-readonly) }
						default		{ set opts(-readonly) 0 }
					}
				}
				set args {}
				if {[llength $opts(-encoding)]} { lappend args -encoding $opts(-encoding) }
				set cmd [list ::scidb::db::load $file]
				set options [list -message $msg -interrupt yes]
				set rc [::util::catchException { ::progress::start $parent $cmd $args $options }]
				if {$rc != 0} { return 0 }
			}
			pgn - gz - zip {
				set type [lsearch -exact $Types(sci) Temporary]
				set cmd [list ::import::open $parent $file [list $file] $msg $opts(-encoding) $type]
				set rc [::util::catchException $cmd]
				if {$rc != 0} {
					catch { ::scidb::db::close $file }
					return 0
				}
				set opts(-readonly) 1
			}
		}
		set readonly $opts(-readonly)
		if {[::scidb::db::get upgrade? $file]} {
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
		AddBase $type $file $opts(-readonly) $opts(-encoding) $opts(-switchToBase)
		AddRecentFile $type $file $opts(-encoding) $readonly
		CheckEncoding $parent $file [::scidb::db::get encoding $file]
	} else {
		SeeSymbol [lindex $Vars(bases) $i 0]
		if {$byUser} {
			set msg [format $mc::DatabaseAlreadyOpen [::util::databaseName $file]]
			::dialog::info -parent $parent -message $msg
		}
	}

	if {$opts(-switchToBase)} { Switch $file }
	return 1
}


proc switchToBase {base} {
	Switch $base
}


proc prepareClose {} {
	variable Vars
	variable PreOpen
	variable ClipbaseType

	set current [::scidb::db::get name]
	set active ""

	set PreOpen {}
	foreach entry $Vars(bases) {
		lassign $entry i type file ext encoding readonly
		if {$type ne $ClipbaseType} {
			if {$file eq $current} { set active 1 } else { set active 0 }
			lappend PreOpen [list $type $file $encoding $readonly $active]
		}
	}
}


proc closeBase {parent {file {}} {number -1}} {
	::remote::busyOperation { CloseBase $parent $file $number }
}


proc newBase {parent file {encoding ""}} {
	variable Vars
	variable Types

	set file [file normalize $file]
	if {[lsearch -exact -index 2 $Vars(bases) $file] == -1} {
		set type Unspecific
		::widget::busyCursor on
		::scidb::db::new $file [lsearch -exact $Types(sci) $type] {*}$encoding
		::scidb::db::attach $file $file
		set encoding [::scidb::db::get encoding $file]
		AddBase $type $file no $encoding
		AddRecentFile $type $file $encoding no
		::widget::busyCursor off
	} else {
		set msg [format $mc::DatabaseAlreadyOpen  [::util::databaseName $file]]
		::dialog::error -parent $parent -message $msg
	}
	Switch $file
}


proc refreshBase {base} {
	variable Vars

	::scidb::db::switch $base
	set index [lindex $Vars(bases) [lsearch -exact -index 2 $Vars(bases) $base] 0]
	set count [::scidb::db::count games $base]
	if {$count == 0} { set count $mc::Empty } else { set count [::locale::formatNumber $count] }
	$Vars(canvas) itemconfigure size$index -text $count
	LayoutSwitcher
}


proc selectEvent {base index} {
	variable Vars

	events::select $Vars(events) $base $index

	if {[winfo toplevel $Vars(events)] eq $Vars(events)} {
		events::activate $Vars(events) 1
	}
}


proc selectSite {base index} {
	variable Vars

	sites::select $Vars(sites) $base $index

	if {[winfo toplevel $Vars(sites)] eq $Vars(sites)} {
		sites::activate $Vars(sites) 1
	}
}


proc selectPlayer {base index} {
	variable Vars

	players::select $Vars(players) $base $index

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
		if {[lsearch -exact -index 2 $Vars(bases) [lindex $entry 1]] == -1} {
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
					.sci - .si3 - .si4 - .cbh - .pgn - .gz {
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


proc CloseBase {parent file number} {
	variable Vars
	variable ::scidb::clipbaseName

	if {[llength $file] == 0} {
		set file [::scidb::db::get name]
		if {$file eq $clipbaseName} { return }
		set i [lsearch -exact -index 2 $Vars(bases) $file]
		set number [lindex $Vars(bases) $i 0]
	}

	if {[::game::releaseAll $parent $file]} {
		::widget::busyCursor on
		::scidb::db::close $file
		DeleteBase $number
		::widget::busyCursor off
	}
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

	after idle [namespace code [list LayoutSwitcher]]
}


proc BuildSwitcher {pane} {
	variable Vars
	variable Defaults

	set height $Defaults(iconsize)
	incr height 14
	set canv [tk::canvas $pane.canv \
		-takefocus 1 \
		-background white \
		-height $height \
		-yscrollcommand [list $pane.sb set]] \
		;
	set Vars(canvas) $canv
	set Vars(active) 0
	set sb [::ttk::scrollbar $pane.sb -orient vertical -takefocus 0 -command [list $canv yview]]
	pack $canv -fill both -expand yes -side left
	bind $canv <Configure> [namespace code [list LayoutSwitcher %w %h]]
	bind $canv <ButtonPress-3> [namespace code [list PopupMenu $canv %X %Y]]
	bind $canv <ButtonPress-1> [list focus $canv]
	bind $canv <ButtonPress-1> +[list set [namespace current]::Vars(ignore-button1) 0]
	bind $canv <ButtonPress-1> +[list ::tooltip::tooltip hide]
	bind $canv <FocusIn> [namespace code { ActivateSwitcher normal }]
	bind $canv <FocusOut> [namespace code { ActivateSwitcher hidden }]
	bind $canv <Left> [namespace code { Traverse -unit }]
	bind $canv <Right> [namespace code { Traverse +unit }]
	bind $canv <Down> [namespace code { Traverse +line }]
	bind $canv <Up> [namespace code { Traverse -line }]
	bind $canv <space> [namespace code ActivateBase]
	::scidb::db::subscribe dbInfo [namespace current]::UpdateSwitcher {} $canv
}


proc ActivateSwitcher {state} {
	variable Vars

	if {$state eq "normal"} { set Vars(active) $Vars(selection) }
	$Vars(canvas) itemconfigure active$Vars(active) -state $state
}


proc Traverse {move} {
	variable Vars

	$Vars(canvas) itemconfigure active$Vars(active) -state hidden
	set n [lsearch -integer -index 0 $Vars(bases) $Vars(active)]
	set nbases [llength $Vars(bases)]

	switch -- $move {
		+unit	{
			if {[incr n] == $nbases} { set n 0 }
		}
		-unit	{
			if {[incr n -1] < 0} { set n [expr {$nbases - 1}] }
		}
		+line	{
			set ncols $Vars(unitsperline)
			set nrows [expr {($nbases + $ncols - 1)/$ncols}]
			incr n $ncols
			if {$n >= $nrows*$ncols} { set n [expr {$n % $ncols}] }
		}
		-line	{
			set ncols $Vars(unitsperline)
			if {$n < $ncols} {
				set nrows [expr {($nbases + $ncols - 1)/$ncols}]
				set n [expr {($nrows - 1)*$ncols + $n}]
			} else {
				incr n -$ncols
			}
		}
	}

	if {$n >= 0 && $n < [llength $Vars(bases)]} {
		set Vars(active) [lindex $Vars(bases) $n 0]
	}
	$Vars(canvas) itemconfigure active$Vars(active) -state normal
	SeeSymbol $Vars(active)
}


proc RegisterDragDropEvents {} {
	variable Vars

	set canv $Vars(canvas)
	::tkdnd::drop_target register $canv DND_Files
	::tkdnd::drag_source register $canv DND_Files
	bind $canv <<DropEnter>> [namespace code { HandleDropEvent enter %t %X %Y }]
	bind $canv <<DropLeave>> [namespace code { HandleDropEvent leave %t %X %Y }]
	bind $canv <<DropPosition>> [namespace code { HandleDropPosition %X %Y }]
	bind $canv <<Drop>> [namespace code { HandleDropEvent %D %t %X %Y }]
	bind $canv <<DragInitCmd>> [namespace code [list HandleDragEvent %W %t %X %Y]]
	bind $canv <<DragEndCmd>> [namespace code [list FinishDragEvent %W %A]]
	bind $canv <<DragPosition>> [namespace code [list HandleDragPositon %W %X %Y]]
}


proc HandleDragEvent {src types x y} {
	variable Vars

	set num [FindDragItem $x $y]
	if {$num < 0} { return {} }
	set i [lsearch -index 0 -integer $Vars(bases) $num]
	set base [lindex $Vars(bases) $i 2]

	set Vars(drag-item) $num
	array set Vars { drop-item -1 curr-item -1 dragging 1 ignore-button1 1 }

	set ext [file extension $base]
	if {[string length $ext] == 0} { set ext .sci }
	set dragCursors [::dialog::fsbox::dragCursors $ext]
	if {[llength $dragCursors]} {
		::tkdnd::set_drag_cursors $src \
			{copy move link ask private} [lindex $dragCursors 0] \
			refuse_drop [lindex $dragCursors 1] \
			;
	}

	set actionList {copy}
	if {[::scidb::db::get memoryOnly? $base] || $::tcl_platform(platform) ne "windows"} {
		lappend actionList move
	}
	lappend actionList link ask private

	set files {}
	set file [file rootname $base]

	if {$file eq $base} {
		lappend files $file
	} else {
		foreach ext [::scidb::misc::suffixes $base] {
			set f "$file.$ext"
			if {[file exists $f]} { lappend files $f }
		}
	}

	return [list $actionList DND_Files $files]
}


proc HandleDragPositon {src x y} {
	variable Vars

	set w [winfo containing $x $y]
	if {$Vars(drag-item) == 0 && $w ne $Vars(canvas)} { return refuse_drop }
	return ""
}


proc FinishDragEvent {src currentAction} {
	variable Vars

	::tkdnd::set_drag_cursors $src
	set Vars(dragging) 0
}


proc HandleDropEvent {action types x y} {
	variable Vars

	switch $action {
		enter {
			if {!$Vars(dragging)} {
				array set Vars { drop-item -1 drag-item -1 curr-item -1 }
			}
			HighlightDropRegion $x $y enter
			::tooltip::tooltip exclude $Vars(canvas)
		}
		leave {
			HighlightDropRegion $x $y leave
		}
		default {
			if {$Vars(drop-item) >= 0} {
				if {$Vars(drop-item) != $Vars(drag-item)} {
					if {$Vars(dragging)} {
						set cmd [list CopyDatabase $Vars(drag-item) $Vars(drop-item) $x $y]
					} else {
						set cmd [list ImportDatabases $action $Vars(drop-item) $x $y]
					}
					after idle [namespace code $cmd]
				}
			} elseif {!$Vars(dragging)} {
				HighlightDropRegion $x $y leave
				after idle [namespace code [list OpenUri $action]]
			}
			::tooltip::tooltip include all
		}
	}

	return copy
}


proc FindDragItem {x y} {
	variable Vars

	set canv $Vars(canvas)
	set x [expr {$x - [winfo rootx $canv]}]
	set y [expr {$y - [winfo rooty $canv]}]

	if {0 <= $x && $x < [winfo width $canv] && 0 <= $y && $y < [winfo height $canv]} {
		foreach tag [$canv gettags [$canv find closest $x $y]] {
			if {[string match input* $tag]} {
				return [string range $tag 5 end]
			}
		}
	}

	return -1
}


proc HighlightDropRegion {x y action} {
	variable Vars
	variable Defaults

	set num [FindDragItem $x $y]
	set canv $Vars(canvas)

	if {!$Vars(dragging)} {
		switch $action {
			enter {
				if {$num == -1} {
					$canv configure -background $Defaults(drop:background)
				}
			}
			leave {
				if {$Vars(drop-item) == -1} {
					$canv configure -background white
				}
			}
			position {
				if {$Vars(curr-item) != $num} {
					if {$num == -1} { set color $Defaults(drop:background) } else { set color white }
					$canv configure -background $color
				}
			}
		}
	}

	if {$Vars(drop-item) >= 0 && ($action eq "leave" || $Vars(drop-item) ne $num)} {
		$canv itemconfigure content$Vars(drop-item) -fill $Vars(background:item)
		set Vars(drop-item) -1
	}

	if {$action ne "leave"} {
		set i [lsearch -index 0 -integer $Vars(bases) $num]
		if {	$num >= 0
			&& $num != $Vars(drop-item)
			&& $num != $Vars(drag-item)
			&& ![lindex $Vars(bases) $i 5]} {

			set Vars(background:item) [$canv itemcget content$num -fill]
			$canv itemconfigure content$num -fill $Defaults(drop:background)
			set Vars(drop-item) $num
		}
	}

	set Vars(curr-item) $num
	return $num
}


proc HandleDropPosition {x y} {
	variable Vars

	HighlightDropRegion $x $y position
	if {$Vars(curr-item) != $Vars(drop-item) && $Vars(curr-item) != $Vars(drag-item)} {
		return refuse_drop
	}
	return copy
}


proc ParseUriFiles {parent files allowedExtensions action} {
	set errorList {}
	set rejectList {}
	set remoteList {}
	set trashList {}
	set databaseList {}

	foreach {uri file} [::fsbox::parseUriList $files] {
		if {[string equal -length 6 $uri "trash:"]} {
			lappend trashList $uri
		} elseif {[string equal -length 5 $uri "http:"] || [string equal -length 4 $uri "ftp:"]} {
			lappend remoteList $uri
		} elseif {[file exists $file]} {
			if {[string match *.pgn.gz $file] && ".pgn.gz" in $allowedExtensions} {
				if {$file ni $databaseList} { lappend databaseList $file }
			} else {
				set origExt [file extension $file]

				if {[string length $origExt]} {
					set origExt [string range $origExt 1 end]
					set mappedExt [::scidb::misc::mapExtension $origExt]

					if {$origExt ne $mappedExt} {
						set f [file rootname $file]
						append f . $mappedExt
						if {[file exists $f]} {
							set file $f
						}
					}
				}

				if {[file extension $file] in $allowedExtensions} {
					if {$file ni $databaseList} { lappend databaseList $file }
				} else {
					if {$file ni $rejectList} { lappend rejectList $file }
				}
			}
		} elseif {[string equal -length 5 $uri "http:"] || [string equal -length 4 $uri "ftp:"]} {
			# TODO: support .scv and .pgn files in successor versions
			lappend rejectList $uri
		} elseif {$uri ni $errorList} {
			lappend errorList $uri
		}
	}

	if {[llength $errorList]} {
		if {[string match file:* $files] && [llength $databaseList] == 0} {
			set message $::fsbox::mc::CannotOpenUri
			if {[llength $errorList] > 10} {
				append message \n\n [join [lrange $errorList 0 9] \n]
				append message \n...
			} else {
				append message \n\n [join $errorList \n]
			}
		} else {
			set message $::fsbox::mc::InvalidUri
		}
		dialog::error -parent $parent -message $message
	}

	if {[llength $trashList]} {
		set message $::fsbox::mc::CannotOpenTrashFiles
		if {[llength $trashList] > 10} {
			append message \n\n [join [lrange $trashList 0 9] \n]
			append message \n...
		} else {
			append message \n\n [join $trashList \n]
		}
		dialog::info -parent $parent -message $message
	}

	if {[llength $remoteList]} {
		set message $::fsbox::mc::CannotOpenRemoteFiles
		if {[llength $remoteList] > 10} {
			append message \n\n [join [lrange $remoteList 0 9] \n]
			append message \n...
		} else {
			append message \n\n [join $remoteList \n]
		}
		dialog::info -parent $parent -message $message
	}

	if {[llength $rejectList]} {
		set message $::fsbox::mc::UriRejected
		if {[llength $rejectList] > 10} {
			append message \n\n [join [lrange $rejectList 0 9] \n]
			append message \n...
		} else {
			append message \n\n [join $rejectList \n]
		}
		append detail $mc::UriRejectedDetail($action)
		append detail " "
		append detail [join $allowedExtensions ", "]
		dialog::info -parent $parent -message $message -detail $detail
	}
	
	if {	[llength $databaseList] +
			[llength $rejectList] +
			[llength $trashList] +
			[llength $errorList] == 0} {
		set message $mc::EmptyUriList
		dialog::info -parent $parent -message $message
	}

	return $databaseList
}


proc OpenUri {uriFiles} {
	variable Vars

	set parent $Vars(canvas)
	set allowedExtensions {.sci .scv .si3 .si4 .cbh .pgn .pgn.gz .zip}
	set databaseList [ParseUriFiles $parent $uriFiles $allowedExtensions open]

	# take into account that the application is currently loading a database
	if {[::remote::blocked?]} {
		::remote::requestOpenBases $databaseList
	} else {
		foreach file $databaseList {
			openBase $parent $file no -switchToBase [expr {[llength $databaseList] == 1}]
		}
	}
}


proc ImportDatabases {uriFiles to x y} {
	variable Vars

	set to [lsearch -index 0 -integer $Vars(bases) $to]
	set parent $Vars(canvas)
	set allowedExtensions {.sci .si3 .si4 .pgn .pgn.gz .zip}
	set databaseList [ParseUriFiles $parent $uriFiles $allowedExtensions import]
	set reply no

	if {[llength $databaseList] > 0} {
		set dst [lindex $Vars(bases) $to 2]
		set ngames 0
		set estimated 0

		foreach file $databaseList {
			set n [::dialog::fsbox::estimateNumberOfGames $file]
			if {$n < 0} { set estimated 1 }
			set ngames [expr {$ngames + abs($n)}]
		}

		if {$ngames == 1} {
			set msg $mc::ImportOneGameTo($estimated)
		} else {
			set msg $mc::ImportGamesTo($estimated)
		}
		set ngames [::locale::formatNumber $ngames]
		set msg [string map [list %dst [::util::databaseName $dst] %num $ngames] $msg]
		append msg "\n\n"
		append msg $mc::ImportFiles
		set detail [join $databaseList "\n"]
		set reply [::dialog::question \
			-parent $parent \
			-title "$::scidb::app: $mc::ImportGames" \
			-message $msg \
			-detail $detail \
			-buttons {yes no} \
			-default yes \
		]
	}

	HighlightDropRegion $x $y leave

	if {$reply eq "yes"} {
		::import::open $parent $dst $databaseList $mc::ImportGames
	}
}


proc CopyDatabase {from to x y} {
	variable Vars

	set parent $Vars(canvas)

	set from	[lsearch -index 0 -integer $Vars(bases) $from]
	set to	[lsearch -index 0 -integer $Vars(bases) $to]
	set src  [lindex $Vars(bases) $from 2]
	set dst  [lindex $Vars(bases) $to 2]
	set cmd  [list ::scidb::view::copy $src 0 $dst {}]
	set srcN [::util::databaseName $src]
	set dstN [::util::databaseName $dst]
	set msg  [string map [list %src $srcN %dst $dstN] $mc::CopyGamesFromTo]
	set opts [list -message $msg. -interrupt yes]
	set args [list [namespace current]::LogCopyDb {}]

	set m [menu $parent.selection_ -tearoff 0]
	set ngames [::locale::formatNumber [::scidb::view::count games $src 0]]
	if {$ngames eq "0"} {
		set state disabled
		set ngames $::application::database::mc::None
	} else {
		set state normal
	}
	set txt [string map [list %src $srcN %dst $dstN %num $ngames] $mc::CopyAllGames]
	$m add command \
		-label " $txt" \
		-image $::icon::16x16::piechart(complete) \
		-compound left \
		-command [list set [namespace current]::trigger_ all] \
		-state $state \
		;
	set ngames [::locale::formatNumber 0] ;# TODO get number of games from active filter
	if {$ngames eq "0"} {
		set state disabled
		set ngames $::application::database::mc::None
	} else {
		set state normal
	}
	set txt [string map [list %src $srcN %dst $dstN %num $ngames] $mc::CopyFilteredGames]
	$m add command \
		-label " $txt" \
		-image $::icon::16x16::piechart(filter) \
		-compound left \
		-command [list set [namespace current]::trigger_ filter] \
		-state $state \
		;
	$m add separator
	$m add command \
		-label " $::mc::Cancel" \
		-image $::icon::16x16::crossHand \
		-compound left \
		-command [list set [namespace current]::trigger_ cancel] \
		;
	variable trigger_ none
	bind $m <<MenuUnpost>> [list set [namespace current]::trigger_ cancel]
	tk_popup $m {*}[winfo pointerxy $parent]
	vwait [namespace current]::trigger_
	destroy $m
	HighlightDropRegion $x $y leave
	if {$trigger_ eq "cancel"} { return }

	::log::open $mc::CopyGames
	::log::delay
	::log::info $msg

	set ngames [::scidb::db::count games $dst]
	set cmd [list ::progress::start $parent $cmd $args $opts 0]

	if {[catch { ::util::catchException $cmd count } rc opts]} {
		::log::error $::import::mc::AbortedDueToInternalError
		::progress::close
		::log::close
		return {*}$opts -rethrow 1 $ngames
	}

	if {$rc == 1} {
		::log::error $::import::mc::AbortedDueToIoError
		::progress::close
		::log::close
		# show error dialog
		return 0
	}

	if {$rc < 0} {
		::log::warning $::import::mc::UserHasInterrupted
		set count [expr {-$rc - 2}]
		set rc -1
	}

	update idletasks	;# be sure the following will be appended

	if {$count == 0} {
		::log::info $mc::NoGamesCopied
	} else {
		::log::info	[format $mc::CopiedGames [::locale::formatNumber $count]]
	}

	set cmd [list ::scidb::db::save $dst $ngames]
	set rc [::util::catchException { ::progress::start $parent $cmd {} {} 1 } count]
	if {$rc == 1} { ::log::error $::import::mc::AbortedDueToIoError }
	::progress::close
	::log::close
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


proc LogCopyDb {args} {
	puts "LogCopyDb: $args"
}


proc ActivateBase {} {
	variable Vars

	set k [lsearch -integer -index 0 $Vars(bases) $Vars(active)]
	Switch [lindex $Vars(bases) $k 2]
}


proc DeleteBase {number} {
	variable Vars

	set canv $Vars(canvas)
	set k [lsearch -integer -index 0 $Vars(bases) $number]
	set Vars(bases) [lreplace $Vars(bases) $k $k]
	set tags {active filler border1 border2 border3 content name suff type size icon input}
	foreach tag $tags { $canv delete $tag$number }
	if {$Vars(selection) == $number} {
		if {$k == [llength $Vars(bases)]} { incr k -1 }
		Switch [lindex $Vars(bases) $k 2]
	}
	if {$Vars(active) == $number} { set Vars(active) $Vars(selection) }
	LayoutSwitcher
}


proc AddBase {type file readonly {encoding ""} {selectBase yes}} {
	variable Vars
	variable Defaults

	set canv $Vars(canvas)
	set img [set [namespace current]::icons::${type}(${Defaults(iconsize)}x${Defaults(iconsize)})]
	set i $Vars(counter); incr Vars(counter)
	set ext [file extension $file]
	switch $ext { .gz - .zip { set ext .pgn } }
	if {[llength $ext] == 0} { set ext sci } else { set ext [string range $ext 1 end] }
	set Vars(active) $i
#	if {$selectBase} { set Vars(selection) $i }
	if {[llength $encoding] == 0 || $encoding eq $::encoding::autoEncoding} {
		set encoding [::scidb::db::get encoding $file]
	}
	lappend Vars(bases) [list $i $type $file $ext $encoding $readonly]
	set count [::scidb::db::count games $file]
	if {$count == 0} { set count $mc::Empty } else { set count [::locale::formatNumber $count] }
	set count [::locale::formatNumber $count]
	set name [::util::databaseName $file no]

	switch $ext {
		sci { set icon $::icon::16x16::filetypeScidbBase }
		si3 { set icon $::icon::16x16::filetypeScid3Base }
		si4 { set icon $::icon::16x16::filetypeScid4Base }
		cbh { set icon $::icon::16x16::filetypeChessBase }
		pgn { set icon $::icon::16x16::filetypePGN }
	}

	if {$Defaults(iconsize) <= 16} {
		set symFont $Defaults(font-symbol-tiny)
	} else {
		set symFont $Defaults(font-symbol-normal)
	}

	tk::label .tmp; set Vars(background) [.tmp cget -background]; destroy .tmp
	$canv create rectangle 0 0 0 0 -tag active$i -fill black -width 0
	$canv create rectangle 0 0 0 0 -tag filler$i -fill white -width 0
	$canv create rectangle 0 0 0 0 -tag border1$i -fill white -width 0
	$canv create rectangle 0 0 0 0 -tag border2$i -fill gray56 -width 0
	$canv create rectangle 0 0 0 0 -tag border3$i -fill white -width 0
	$canv create rectangle 0 0 0 0 -tag content$i -fill $Vars(background) -width 0
	$canv create text 0 0 -anchor nw -tag name$i -font $symFont -text $name
	$canv create text 0 0 -anchor nw -tag suff$i -font $symFont -text $ext -fill darkgreen
	$canv create text 0 0 -anchor ne -tag size$i -font $symFont -text $count
	$canv create image 0 0 -anchor nw -tag type$i -image $icon
	$canv create image 0 0 -tag icon$i -anchor nw -image $img
	$canv create rectangle 0 0 0 0 -tag input$i -fill {} -width 0

	set cmd [namespace code [list PopupMenu $canv %X %Y $i]]
	$canv bind input$i <ButtonPress-3> "[namespace current]::PopdownProps; $cmd 1"
	$canv bind input$i <ButtonRelease-1> [namespace code [list DoSwitch $file $i %x %y]]
	$canv bind input$i <ButtonPress-2> [namespace code [list Properties $i true]]
	$canv bind input$i <ButtonRelease-2> [namespace code PopdownProps]
	$canv bind input$i <Enter> [namespace code [list ShowDescription $i]]
	$canv bind input$i <Leave> [list ::tooltip::hide]

	$canv yview moveto 1.0
	LayoutSwitcher
	SeeSymbol $i
}


proc UpdateSwitcher {canv base} {
	variable ClipbaseType
	variable Vars

	foreach info $Vars(bases) {
		lassign $info i type file
		if {$file eq $base} {
			set count [::scidb::db::count games $file]
			if {$count == 0} { set count $mc::Empty } else { set count [::locale::formatNumber $count] }
			$canv itemconfigure size$i -text $count
			if {$type eq $ClipbaseType} {
				$canv itemconfigure name$i -text $::util::clipbaseName
			}
		}
	}

	LayoutSwitcher
}


proc SeeSymbol {number} {
	variable Vars
	variable Defaults

	if {![info exists Vars(canv-height)]} { return }
	set pad $Defaults(symbol-padding)
	set canv $Vars(canvas)
	set topFraction [lindex [$canv yview] 0]
	set y3 [expr {$topFraction*$Vars(canv-height)}]
	set y4 [expr {$y3 + [winfo height $canv]}]
	lassign [$canv bbox input$number] x1 y1 x2 y2
	if {$y3 + $pad < $y1 || $y2 < $y4 + $pad} {
		set fraction [expr {double($y1 - $pad)/$Vars(canv-height)}]
		set fraction [min 1.0 [max 0.0 $fraction]]
		$canv yview moveto $fraction
	}
}


proc DoSwitch {filename number x y} {
	variable Vars

	if {$Vars(ignore-button1)} { return }
	lassign [$Vars(canvas) bbox input$number] x1 y1 x2 y2
	if {$x < $x1 || $x2 < $x || $y < $y1 || $y2 < $y} { return }

	$Vars(canvas) itemconfigure active$Vars(active) -state hidden
	set Vars(active) [lindex $Vars(bases) [lsearch -exact -index 2 $Vars(bases) $filename] 0]
	$Vars(canvas) itemconfigure active$Vars(active) -state normal
	Switch $filename
	focus $Vars(canvas)
}


proc Switch {filename} {
	variable Vars
	variable Defaults
	variable ::scidb::clipbaseName

	games::prepareSwitch $Vars(games) [::scidb::db::get codec $filename]
	::scidb::db::switch $filename
	set canv $Vars(canvas)
	set readonly [::scidb::db::get readonly? $filename]

	if {$filename eq $clipbaseName} { set state disabled } else { set state normal }
	if {$filename eq $clipbaseName || ![::scidb::db::get writeable? $filename]} {
		set roState disabled
	} else {
		switch [file extension $filename] {
			.sci - .si3 - .si4	{ set roState normal }
			default					{ set roState disabled }
		}

		::toolbar::childconfigure $Vars(button:readonly) -tooltip $roState
	}

	#::menu::configureCloseBase $state
	::toolbar::childconfigure $Vars(button:close) -state $state
	::toolbar::childconfigure $Vars(button:readonly) -state $roState

	set Vars(flag:readonly) $readonly
	CheckTabState

	foreach base $Vars(bases) {
		lassign $base i type file

		if {$file eq $filename} {
			set Vars(selection) $i
			set background $Defaults(selected)
			if {$readonly} { set str $mc::SetWriteable } else { set str $mc::SetReadonly }
			set name [::util::databaseName $filename]
			set [namespace current]::_CloseDatabase [format $mc::CloseDatabase $name]
			set [namespace current]::_Readonly [format $str $name]
		} else {
			set background $Vars(background)
		}

		$canv itemconfigure content$i -fill $background
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


proc Update {path id base {view 0} {index -1}} {
	variable Vars

	if {$index >= 0} {
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code { RefreshSwitcher }]]
	}
}


proc RefreshSwitcher {} {
	variable Vars

	set i [lsearch -integer -index 0 $Vars(bases) $Vars(selection)]
	lassign [lindex $Vars(bases) $i] i type file
	set count [::scidb::db::count games $file]
	if {$count == 0} { set count $mc::Empty } else { set count [::locale::formatNumber $count] }
	$Vars(canvas) itemconfigure size$i -text $count
	LayoutSwitcher
}


proc LanguageChanged {} {
	variable Vars
	variable ::scidb::clipbaseName

	set ::util::clipbaseName [set [namespace current]::mc::T_Clipbase]
	UpdateSwitcher $Vars(canvas) $clipbaseName

	set i [lsearch -integer -index 0 $Vars(bases) $Vars(selection)]

	if {$i >= 0} {
		if {[::scidb::db::get readonly?]} { set str $mc::SetWriteable } else { set str $mc::SetReadonly }
		set name [::util::databaseName [lindex $Vars(bases) $i 2]]
		set [namespace current]::_CloseDatabase [format $mc::CloseDatabase $name]
		set [namespace current]::_Readonly [format $str $name]
	}

	foreach t $Vars(windows) {
		set var [namespace current]::mc::[string toupper [lindex [split $t .] end] 0 0]
		if {[winfo toplevel $t] eq $t} {
			wm title $t "$::scidb::app - [::mc::stripAmpersand [set $var]]"
		} else {
			::widget::notebookSetLabel $Vars(contents) $t [set $var]
		}
	}
}


proc Close {path base} {}


proc LayoutSwitcher {{w -1} {h -1}} {
	variable Vars
	variable Defaults

	if {[llength $Vars(bases)] == 0} { return }

	set canv $Vars(canvas)
	if {$w == -1} {
		set w [winfo width $canv]
		set h [winfo height $canv]
	}
	if {$w <= 1} { return }

	set pane [winfo parent $canv]
	set sbw [winfo width $pane.sb]
	if {$sbw <= 1} { set sbw 15 }
	if {"$pane.sb" in [pack slaves $pane]} { incr w $sbw }
	$canv itemconfigure size0 -state normal
	lassign [$canv bbox size0] x1 y1 x2 y2
	set textHeight [expr {$y2 - $y1}]
	set padType 3

	set minwidth 0
	foreach base $Vars(bases) {
		set i [lindex $base 0]
		lassign [$canv bbox name$i] x1 y1 x2 y2
		set minwidth [max $minwidth [expr {$x2 - $x1}]]
		if {$Defaults(iconsize) >= 32} { set state normal } else { set state hidden }
		$canv itemconfigure size$i -state $state
		$canv itemconfigure suff$i -state hidden
		$canv itemconfigure type$i -state hidden
		if {$Defaults(iconsize) >= 48} {
			$canv itemconfigure suff$i -state normal
			$canv itemconfigure type$i -state normal
			lassign [$canv bbox size$i] x1 y1 x2 y2
			lassign [$canv bbox suff$i] u1 v1 u2 v2
			lassign [$canv bbox type$i] s1 t1 s2 t2
			set minwidth [max	$minwidth [expr {$x2 - $x1 + $u2 - $u1 + $s2 - $s1 + 5 + $padType}]]
		} elseif {$Defaults(iconsize) >= 32} {
			$canv itemconfigure suff$i -state normal
			lassign [$canv bbox size$i] x1 y1 x2 y2
			lassign [$canv bbox suff$i] s1 t1 s2 t2
			set minwidth [max	$minwidth [expr {$x2 - $x1 + $s2 - $s1 + 5}]]
		} else {
			incr minwidth 3
		}
	}
	set pad $Defaults(symbol-padding)
	set ipad 2
	incr minwidth $Defaults(iconsize)
	incr minwidth $pad
	incr minwidth [expr {3*$ipad + 4}]
	set minheight $Defaults(iconsize)
	incr minheight $pad
	incr minheight [expr {2*$ipad + 4}]
	if {$Defaults(iconsize) < 32} {
		set maxheight [expr {max($minheight, $textHeight + 4)}]
	} else {
		set maxheight [expr {max($minheight, 2*$textHeight + 6)}]
	}
	set shiftY [expr {($maxheight - $minheight)/2}]
	set minheight $maxheight
	set cols [expr {($w - $pad)/$minwidth}]
	set rows [expr {([llength $Vars(bases)] + $cols - 1)/$cols}]
	set minH [expr {$rows*$minheight + $pad}]
	set includesPane [expr {"$pane.sb" in [pack slaves $pane]}]
	if {$h < $minH && !$includesPane} {
		pack $pane.sb -fill y -side left
	} elseif {$minH <= $h && $includesPane} {
		pack forget $pane.sb
	}
	if {$includesPane} { incr w -$sbw }
	set haveFocus [expr {[focus] eq $canv}]
	set cols [expr {($w - $pad)/$minwidth}]
	set minH [expr {$rows*$minheight + $pad}]
	set offsY [expr {($minheight - $pad - 2*$textHeight)/3}]
	set x $pad
	set y $pad
	set r 0

	foreach base $Vars(bases) {
		lassign $base i type file
		set x0 $x
		set y0 $y
		set x1 [expr {$x + $minwidth - $pad}]
		set y1 [expr {$y + $minheight - $pad}]
		$canv coords active$i [expr {$x0 - 1}] [expr {$y0 - 1}] [expr {$x1 + 2}] [expr {$y1 + 2}]
		$canv coords filler$i [expr {$x0 - 0}] [expr {$y0 - 0}] [expr {$x1 + 1}] [expr {$y1 + 1}]
		$canv coords input$i $x0 $y0 $x1 $y1
		$canv coords border1$i $x0 $y0 $x1 $y1
		$canv coords border2$i [incr x0] [incr y0] $x1 $y1
		$canv coords border3$i [incr x0] [incr y0] [incr x1 -1] [incr y1 -1]
		$canv coords content$i $x0 $y0 [incr x1 -1] [incr y1 -1]
		$canv coords icon$i [expr {$x0 + $ipad}] [expr {$y0 + $ipad + $shiftY}]
		switch $Defaults(iconsize) {
			16 - 24 {
				set x0 [expr {$x0 + 2*$ipad + $Defaults(iconsize) + 3}]
				set y0 [expr {$y + ($minheight - $pad - $textHeight)/2}]
				$canv coords name$i $x0 $y0
			}

			32 {
				set x0 [expr {$x0 + 2*$ipad + $Defaults(iconsize)}]
				set y0 [expr {$y + $ipad + $offsY}]
				set x1 [expr {$x + $minwidth - $pad - 3*$ipad}]
				set y1 [expr {$y + $minheight - $pad - $textHeight - $offsY}]
				set y2 [expr {$y + $ipad + $shiftY + $Defaults(iconsize)}]
				$canv coords name$i $x0 $y0
				$canv coords suff$i $x0 $y1
				$canv coords size$i $x1 $y1
			}

			48 {
				lassign [$canv bbox suff$i] u1 v1 u2 v2
				set x0 [expr {$x0 + 2*$ipad + $Defaults(iconsize)}]
				set y0 [expr {$y + $ipad + $offsY}]
				set x1 [expr {$x0 + $u2 - $u1 + $padType}]
				set x2 [expr {$x + $minwidth - $pad - 3*$ipad}]
				set y1 [expr {$y + $minheight - $pad - $textHeight - $offsY}]
				set y2 [expr {$y + $ipad + $shiftY + $Defaults(iconsize)}]
				$canv coords name$i $x0 $y0
				$canv coords type$i $x1 $y1
				$canv coords size$i $x2 $y1
				$canv coords suff$i $x0 $y1
			}
		}
		if {$Vars(selection) == $i} {
			set background $Defaults(selected)
		} else {
			set background $Vars(background)
		}
		if {$Vars(active) == $i && $haveFocus} {
			$canv itemconfigure active$i -state normal
		} else {
			$canv itemconfigure active$i -state hidden
		}
		$canv itemconfigure content$i -fill $background
		if {[incr r] == $cols} {
			incr y $minheight
			set x $pad
			set r 0
		} else {
			incr x $minwidth
		}
	}

	$canv configure -scrollregion [list 0 0 $w [expr {$rows*$minheight + $pad}]]
	set Vars(unitsperline) $cols
	if {$r != $cols} { incr y $minheight }
	set Vars(canv-height) $y
}


proc ComputeMinHeight {} {
	variable Defaults
	variable Vars

	$Vars(canvas) itemconfigure size0 -state normal
	lassign [$Vars(canvas) bbox size0] x1 y1 x2 y2
	set textHeight [expr {$y2 - $y1}]

	set ipad 2
	set minheight $Defaults(iconsize)
	incr minheight $Defaults(symbol-padding)
	incr minheight [expr {2*$ipad + 6}]

	if {$Defaults(iconsize) < 32} {
		set minheight [expr {max($minheight, $textHeight + 4)}]
	} else {
		set minheight [expr {max($minheight, 2*$textHeight + 6)}]
	}

	return $minheight
}


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
			set minheight [expr {[ComputeMinHeight] + [::toolbar::totalHeight $switcher] + 2}]
			set Vars(minheight:switcher) $minheight
		}

		while {$Vars(minheight:switcher) > $y} { incr y $Vars(incr) }
		$main sash place 0 $x $y
	}
}


proc PopupMenu {canv x y {index -1} {ignoreNext 0}} {
	variable ::scidb::clipbaseName
	variable ClipbaseType
	variable Defaults
	variable Vars
	variable ::table::options

	if {$Vars(ignore-next)} {
		set Vars(ignore-next) 0
		return
	}
	if {$ignoreNext} { set Vars(ignore-next) 1 }
	set menu $canv.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $menu -type popup_menu }
	set top [winfo toplevel $canv]
	set specs {}
	set readonly 0
	set isSciFormat 1

	if {$index >= 0} {
		set k [lsearch -integer -index 0 $Vars(bases) $index]
		lassign [lindex $Vars(bases) $k] i type file ext
		set readonly [::scidb::db::get readonly? $file]
		set isSciFormat [expr {$ext eq "sci"}]
		set isClipbase [expr {$type eq $ClipbaseType}]
		set name [::util::databaseName $file]
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
		lappend specs command $mc::Properties [namespace code [list Properties $i false]] 0 0 info {} {}
		lappend specs command $mc::FileExport [list ::export::open $canv $file $type $name 0] \
			0 0 fileExport {} {}
		lappend specs command $mc::FileImport(db) \
			[list ::menu::dbImport $top $file db] 1 0 databaseImport {} {}
		lappend specs command $mc::FileImport(pgn) \
			[list ::menu::dbImport $top $file pgn] 1 0 filetypePGN {} {}
		if {$isClipbase || $ext eq "sci"} {
			if {[::scidb::db::get compress? $file]} { set state normal } else { set state disabled }
			lappend specs command \
				"$mc::FileCompact..." \
				[namespace code [list Compact $top $file]] \
				1 0 {} {} $state \
				;
		}
		lappend specs command "$mc::FileCreate" \
				[list ::menu::dbCreateArchive $top $file] 0 0 filetypeArchive {} {}
		lappend specs separator {} {} {} {} {} {} {}
		if {$file ne $clipbaseName} {
			lappend specs command $mc::FileClose \
				[namespace code [list closeBase $canv $file $i]] 0 0 close {} {}
			lappend specs command "$mc::ChangeIcon..." \
				[list [namespace current]::ChangeIcon $i $top] 1 0 {} {} {}
			lappend specs command "$mc::EditDescription..." \
				[list [namespace current]::EditDescription $canv $i] 1 0 {} {} {}
		} else {
			if {[::scidb::db::count games $file] == 0} { set state disabled } else { set state normal }
			lappend specs command \
				$mc::EmptyClipbase \
				[list [namespace current]::EmptyClipbase $canv] \
				0 0 trash {} $state \
				;
		}
		switch $ext {
			si3 - si4 - cbh - pgn {
				if {[file readable $file]} { set state normal } else { set state disabled }
				lappend specs command \
					"$mc::Recode..." \
					[namespace code [list Recode $i $top]] \
					0 1 {} {} $state \
					;
			}
		}

		# TODO:
		#	if {	[::scidb::view::count games $file 0] == [::scidb::db::count games $file]
		#		&& [::scidb::view::query sorted $file]} {
		#		lappend specs command "Save current order" \
		#			[namespace code [list SaveOrder $i $top]] 1 0 disk {} {}
		#	}
		lappend specs separator {} {} {} {} {} {} {}

		if {!$isClipbase && ($ext eq "sci" || $ext eq "si3" || $ext eq "si4")} {
			lappend specs \
				checkbutton \
				$mc::ReadOnly \
				[namespace code ToggleReadOnly] \
				[expr {![::scidb::db::get writeable? $file]}] \
				0 lock \
				[namespace current]::Vars(flag:readonly) \
				{} \
				;
			lappend specs separator {} {} {} {} {} {} {}
		}
	}
	lappend specs command $mc::FileNew [list ::menu::dbNew $top] 0 0 docNew {} {}
	lappend specs command $mc::FileOpen [list ::menu::dbOpen $top] 0 0 docOpen {} {}

	foreach {type text cmd writableOnly notSci icon var state} $specs {
		if {$type eq "separator"} {
			$menu add separator
		} else {
			if {[llength $icon] == 0} { set icon none }
			if {[llength $state] == 0} {
				if {($writableOnly && $readonly) || ($notSci && $isSciFormat)} {
					set state disabled
				} else {
					set state normal
				}
			}
			set entry {}
			lappend entry $type
			lappend entry -label " [::mc::stripAmpersand $text]"
			lappend entry -image [set ::icon::16x16::$icon]
			lappend entry -compound left
			lappend entry -command [list {*}$cmd]
			lappend entry -state $state
			if {[llength $var]} { lappend entry -variable $var }
			$menu add {*}$entry
		}
	}

	set m [menu $menu.mOpenRecent -tearoff false]
	set state normal
	if {[addRecentlyUsedToMenu [winfo parent [winfo parent $canv]] $m] == 0} { set state disabled }
	$menu add cascade \
		-menu $m \
		-label " [::mc::stripAmpersand $mc::FileOpenRecent]" \
		-image $::icon::16x16::docOpen \
		-compound left \
		-state $state \
		;

#	if {$index == -1 && [::scidb::db::get name] ne $clipbaseName} {
#		$menu add separator
#		set name [::util::databaseName [::scidb::db::get name]]
#		set text [format [set [namespace current]::mc::Close] $name]
#		set cmd [namespace code [list closeBase $canv]]
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
			-variable [namespace current]::Defaults(iconsize) \
			-command [namespace code [list ChangeIconSize $canv]] \
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


proc ToggleReadOnly {} {
	variable Vars
	variable RecentFiles

	set file [::scidb::db::get name]
	::scidb::db::set readonly $Vars(flag:readonly)

	set k [lsearch -exact -index 2 $Vars(bases) $file]
	lset Vars(bases) $k 5 $Vars(flag:readonly)

	set k [FindRecentFile $file]
	if {$k >= 0} { lset RecentFiles $k 3 $Vars(flag:readonly) }

	if {$Vars(flag:readonly)} { set str $mc::SetWriteable } else { set str $mc::SetReadonly }
	set [namespace current]::_Readonly [format $str [::util::databaseName $file]]
}


proc EmptyClipbase {parent} {
	variable ::scidb::clipbaseName

	if {[::game::releaseAll $parent $clipbaseName]} {
		::widget::busyCursor on
		::scidb::db::clear $clipbaseName
		::widget::busyCursor off
	}
}


proc EditDescription {canv index} {
	variable Vars

	set i [lsearch -integer -index 0 $Vars(bases) $index]
	set file [lindex $Vars(bases) $i 2]
	set Vars(description) [::scidb::db::get description $file]

	set dlg [tk::toplevel $canv.descr -class Dialog]
	set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]
	pack $top -fill both
	::ttk::entry $top.entry -takefocus 1 -width 108 -textvar [namespace current]::Vars(description)
	$top.entry selection range 0 end
	$top.entry icursor end
	pack $top.entry -fill x -padx $::theme::padx -pady $::theme::pady
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [namespace code [list SetDescription $dlg $index]]
	$dlg.cancel configure -command [list destroy $dlg]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $canv]
	wm withdraw $dlg
	wm title $dlg "$mc::EditDescription ([::util::databaseName $file])"
	wm resizable $dlg false false
	::util::place $dlg below $canv
	wm deiconify $dlg
	focus $top.entry
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc SetDescription {dlg index} {
	variable Vars

	set i [lsearch -integer -index 0 $Vars(bases) $index]
	set file [lindex $Vars(bases) $i 2]
	set length [::scidb::db::set description $file $Vars(description)]

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


proc ChangeIconSize {canv} {
	variable Vars
	variable Defaults

	set size $Defaults(iconsize)

	if {$size <= 16} {
		set symFont $Defaults(font-symbol-tiny)
	} else {
		set symFont $Defaults(font-symbol-normal)
	}

	foreach base $Vars(bases) {
		lassign $base i type
		set img [set [namespace current]::icons::${type}(${size}x${size})]
		$canv itemconfigure icon$i -image $img
		$canv itemconfigure name$i -font $symFont
		$canv itemconfigure size$i -font $symFont
	}

	update idletasks
	LayoutSwitcher
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
	if {$reply eq "yes" && [::game::closeAll $parent $file $mc::FileCompact $mc::CompactDetail]} {
		::browser::closeAll $file
		::overview::closeAll $file
		set cmd [list ::scidb::db::compact $file]
		set name [::util::databaseName $file]
		set options [list -message [format $mc::CompactMessage $name]]
		::util::catchException { ::progress::start $parent $cmd {} $options }
	}
}


proc Recode {number parent} {
	variable RecentFiles
	variable Types
	variable Vars

	set i [lsearch -integer -index 0 $Vars(bases) $number]
	lassign [lindex $Vars(bases) $i] index type file ext enc

	set enc [::scidb::db::get encoding $file]
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
		pgn {
			::import::showOnlyEncodingWarnings true
			closeBase $parent $file $index
			openBase $parent $file no -encoding $encoding -readonly yes
			::import::showOnlyEncodingWarnings false
		}

		default {
			::progress::start $parent [list ::scidb::db::recode $file $encoding] {} {}
		}
	}

	::log::info [format $mc::RecodedGames [::locale::formatNumber [::scidb::db::count games $file]]]
	::log::close

	lset Vars(bases) $i 4 $encoding
	set i [lsearch -exact -index 1 $RecentFiles $file]
	if {$i >= 0} { lset RecentFiles $i 2 $encoding }
}


proc CheckEncoding {parent file encoding} {
	if {[::scidb::db::get encodingState $file] eq "failed"} {
		::dialog::warning -parent $parent -buttons {ok} -message [format $mc::EncodingFailed $encoding]
	}
}


proc ChangeIcon {number parent} {
	variable Types
	variable Options
	variable Vars

	set dlg [tk::toplevel $parent.changeIcon -class Dialog]
	set i [lsearch -integer -index 0 $Vars(bases) $number]
	lassign [lindex $Vars(bases) $i] index type file ext
	set cols 2
	do {
		set rows [expr {([llength $Types($ext)] + [incr cols] - 1)/$cols}]
	} while {$rows > $cols*$cols}
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

	foreach t $Types($ext) {
		$list insert [list [set [namespace current]::icons::${t}(48x48)] [set mc::T_$t]]
	}
	$list resize

	set Vars(icon) [lsearch -exact $Types($ext) $type]
	bind $list <Configure> [namespace code { ConfigureIconList %W }]
	bind $list <Escape> [list $dlg.cancel invoke]
	bind $list <<ListboxSelect>> [namespace code [list SelectIcon %W %d $index]]
	$list select $Vars(icon)
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [namespace code [list SetIcon $dlg $index]]
	$dlg.cancel configure -command [list destroy $dlg]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg "$mc::ChangeIcon ([::util::databaseName $file])"
	wm resizable $dlg false true
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $dlg.list
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc SelectIcon {w data number} {
	variable Vars

	if {$data eq ""} {
		SetIcon $w $number
	} else {
		set Vars(icon) $data
	}
}


proc SetIcon {w number} {
	variable Vars
	variable Types
	variable Defaults
	variable RecentFiles
	
	set i [lsearch -integer -index 0 $Vars(bases) $number]
	lassign [lindex $Vars(bases) $i] index type file ext
	set selection [lsearch -exact $Types(sci) [lindex $Types($ext) $Vars(icon)]]
	set type [lindex $Types(sci) $selection]
	lset Vars(bases) $i 1 $type
	::scidb::db::set type [lindex $Vars(bases) $i 2] $selection
	destroy [winfo toplevel $w]
	set img [set [namespace current]::icons::${type}(${Defaults(iconsize)}x${Defaults(iconsize)})]
	$Vars(canvas) itemconfigure icon$number -image $img
	lset RecentFiles [FindRecentFile $file] 0 $type
}


proc ConfigureIconList {w} {
	variable Options
	set Options(visible) [$w cget -height]
}


proc ShowDescription {index} {
	variable Vars

	set i [lsearch -integer -index 0 $Vars(bases) $index]
	lassign [lindex $Vars(bases) $i] i type file
	set text [::scidb::db::get description $file]
	if {[llength $text]} { ::tooltip::show $Vars(canvas) $text }
}


proc Properties {index popup} {
	variable Vars
	variable ClipbaseType
	variable Options

	set canv $Vars(canvas)
	set i [lsearch -integer -index 0 $Vars(bases) $index]
	lassign [lindex $Vars(bases) $i] i type file ext encoding

	if {$popup} {
		set dlg $canv.properties
	} else {
		set dlg $canv.prop_[regsub -all {[^[:alnum:]]} $file _]
		if {[winfo exists $dlg]} { return [::widget::dialogRaise $dlg] }
	}

	if {$popup} {
		if {[winfo exists $dlg]} { destroy $dlg }
		set f [::util::makePopup $dlg]
		set label ::tk::label
		set options [list -background [$f cget -background]]
	} else {
		tk::toplevel $dlg -class Scidb
		set f $dlg.f
		tk::frame $f -takefocus 0 -background $Options(prop:background)
		wm title $dlg "$::scidb::app - [::util::databaseName $file]"
		wm resizable $dlg false false
		set label ::ttk::label
		set options {}
		pack $f -fill x -expand yes
	}

	set row 1
	foreach {name var} {	path DatabasePath descr Description type Type readonly ReadOnly
								created Created lastModified LastModified encoding Encoding games
								GameCount deleted DeletedGames yearRange YearRange ratingRange RatingRange
								score Score resWhite {Result 1-0} resBlack {Result 0-1} resDraw {Result 1/2-1/2}
								resLost {Result 0-0} resNone {Result *}} {

		if {[llength $var] == 1} {
			$label $f.l$name -text "[set mc::$var]:" {*}$options
		} else {
			lassign $var v extension
			if {$v eq "Result"} { set extension [::util::formatResult $extension] }
			$label $f.l$name -text "[set mc::$v] $extension:" {*}$options
		}
		$label $f.t$name -justify left {*}$options
		if {!$popup} {
			$f.l$name configure -background $Options(prop:background)
			$f.t$name configure -background $Options(prop:background)
		}
		grid $f.l$name -row $row -column 1 -sticky wn
		grid $f.t$name -row $row -column 3 -sticky wn
		incr row 2
	}

	$f.tpath configure -wraplength 250 -justify left
	$f.tdescr configure -wraplength 250 -justify left
	grid columnconfigure $f {0 2 4} -minsize $::theme::padx
	grid rowconfigure $f [list 0 [expr {$row - 1}]] -minsize $::theme::pady

	set size [::scidb::db::count games $file]
	set readOnly [::scidb::db::get readonly? $file]

	set descr [::scidb::db::get description $file]
	if {[llength $descr] == 0} { set descr "\u2014" }
	grid $f.lpath $f.tpath $f.ldescr $f.tdescr
	$f.tpath configure -text $file
	$f.tdescr configure -text $descr

	if {$type eq $ClipbaseType} {
		foreach name {path readonly created lastModified} {
			grid remove $f.l$name $f.t$name
		}
	} else {
		set created [::scidb::db::get created? $file]
		if {[string length $created] == 0} {
			$f.tcreated configure -text $::mc::NotAvailable
		} else {
			$f.tcreated configure -text [::locale::formatTime $created]
		}
		set lastModified [::scidb::db::get modified? $file]
		if {[string length $lastModified] == 0} {
			$f.tlastModified configure -text $::mc::NotAvailable
		} else {
			$f.tlastModified configure -text [::locale::formatTime $lastModified]
		}
	}
	if {$size == 0} {
		set ngames $mc::None
	} else {
		set ngames [::locale::formatNumber $size]
	}

	$f.ttype			configure -text [set mc::T_$type]
	$f.tgames		configure -text $ngames
	$f.treadonly	configure -text [expr {$readOnly ? $::mc::Yes : $::mc::No}]

	set txt [::scidb::db::get encoding $file]
	if {[::scidb::db::get encodingState $file] ne "ok"} { append txt " ($mc::Failed)" }
	$f.tencoding configure -text $txt

	set slaves [grid slaves $f]

	if {$size == 0} {
		foreach name {deleted yearRange ratingRange score resWhite resBlack resDraw resLost resNone} {
			if {"$f.l$name" in $slaves} { grid remove $f.l$name $f.t$name }
		}
	} else {
		if {$ext eq "pgn"} {
			if {"$f.ldeleted" in $slaves} { grid remove $f.ldeleted $f.tdeleted }
		} else {
			if {"$f.ldeleted" ni $slaves} { grid $f.ldeleted $f.tdeleted }
		}
		if {"$f.lyearRange" ni $slaves} {
			foreach name {yearRange ratingRange score resWhite resBlack resDraw resLost resNone} {
				grid $f.l$name $f.t$name
			}
		}

		lassign [::scidb::db::get stats $file] \
			deleted minYear maxYear avgYear minElo maxElo avgElo resNone resWhite resBlack resDraw resLost
		set total [expr {double($resWhite + $resBlack + $resDraw + $resLost)}]
		set size [expr {double($size)}]
		set score 0

		if {$total != 0.0} {
			set score [expr {round((($resWhite + 0.5*$resDraw)/$total)*100)}]
		}

		set fmtDeleted		[::locale::formatNumber $deleted]
		set fmtScore		[format "%d%%" $score]
		set fmtWhite		[::locale::formatNumber $resWhite]
		set fmtBlack		[::locale::formatNumber $resBlack]
		set fmtDraw			[::locale::formatNumber $resDraw]
		set fmtLost			[::locale::formatNumber $resLost]
		set fmtNone			[::locale::formatNumber $resNone]
		set fmtAvgDeleted	[format "%d" [expr {round((double($deleted)/$size)*100)}]]
		set fmtAvgWhite	[format "%d" [expr {round(($resWhite/$size)*100)}]]
		set fmtAvgBlack	[format "%d" [expr {round(($resBlack/$size)*100)}]]
		set fmtAvgDraw		[format "%d" [expr {round(($resDraw/$size)*100)}]]
		set fmtAvgLost		[format "%d" [expr {round(($resLost/$size)*100)}]]
		set fmtAvgNone		[format "%d" [expr {round(($resNone/$size)*100)}]]

		if {$minYear && $maxYear && $minYear != $maxYear} {
			set yearRange "$minYear-$maxYear ($avgYear)"
		} elseif {$minYear} {
			set yearRange $minYear
		} else {
			set yearRange "\u2014"
		}

		if {$minElo && $maxElo && $minElo != $maxElo} {
			set ratingRange "$minElo-$maxElo ($avgElo)"
		} elseif {$minElo} {
			set ratingRange $minElo
		} else {
			set ratingRange "\u2014"
		}

		$f.tdeleted			configure -text "$fmtDeleted ($fmtAvgDeleted%)"
		$f.tyearRange		configure -text $yearRange
		$f.tratingRange	configure -text $ratingRange
		$f.tscore			configure -text $fmtScore
		$f.tresWhite		configure -text "$fmtWhite ($fmtAvgWhite%)"
		$f.tresBlack		configure -text "$fmtBlack ($fmtAvgBlack%)"
		$f.tresDraw			configure -text "$fmtDraw ($fmtAvgDraw%)"
		$f.tresLost			configure -text "$fmtLost ($fmtAvgLost%)"
		$f.tresNone			configure -text "$fmtNone ($fmtAvgNone%)"
	}

	if {$popup} {
		set Vars(properties) $dlg
		::tooltip::popup $canv $dlg cursor
	} elseif {![winfo exists $dlg.close]} {
		::widget::dialogButtons $dlg close
		$dlg.close configure -command [list destroy $dlg]
		wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
		wm withdraw $dlg
		::util::place $dlg center $canv
		wm deiconify $dlg
	}
}


proc PopdownProps {} {
	variable Vars

	if {[info exists Vars(properties)]} {
		::tooltip::popdown $Vars(properties)
	}
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
		if {[lsearch -exact -index 2 $Vars(bases) [lindex $entry 1]] == -1} { incr count }
	}

	if {$count == 0} { return disabled }
	return normal
}


proc FindRecentFile {file} {
	variable RecentFiles
	return [lsearch -index 1 $RecentFiles $file]
}


#proc MakePhoto {path} {
#	set parent [join [lrange [split $path .] 0 end-1] .]
#	if {[winfo width $parent] <= 1} { return }
#	pack [::tk::canvas $path -borderwidth 0]
#	set src [image create photo -file "SunergosGreyWallpaper-0.0.1-full.jpg"]
#	set dst [image create photo -width  [winfo width $parent] -height [winfo height $parent]]
#	::scidb::tk::image copy $src $dst
#	$path create image 0 0 -anchor nw -image $dst
#	$path configure -width [image width $dst] -height [image height $dst]
#	bind [winfo parent $path] <Configure> {#}
#}
#
#
#proc MakePhoto {path} {
#	pack [::tk::canvas $path -borderwidth 0]
#	set img [::splash::picture]
#	$path create image 0 0 -anchor nw -image $img
#	$path configure -width [image width $img] -height [image height $img]
#	bind [winfo parent $path] <Configure> {#}
#}
#
#
#proc MakeBackground {path} {
#	variable Vars
#
#	if {[winfo exists $path]} {
#		set img $Vars(tile)
#	} else {
#		pack [::tk::canvas $path] -fill both -expand yes
#		set img [image create photo -file "chessboard-tile.png"]
#		set Vars(tile) $img
#	}
#
#	set ih [image height $img]
#	set iw [image width  $img]
#	set ch [winfo height [winfo parent $path]]
#	set cw [winfo width  [winfo parent $path]]
#
#	for {set x 0} {$x < $cw} {incr x $iw} {
#		for {set y 0} {$y < $ch} {incr y $ih} {
#			if {[llength [$path find withtag tile:$x:$y]] == 0} {
#				$path create image $x $y -anchor nw -image $img -tags [list tile tile:$x:$y]
#			}
#		}
#	}
#}


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
	::update idle ;# is reducing flickering
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
