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
# Copyright: (C) 2009-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source application

namespace eval application {
namespace eval mc {

set Information				"&Information"
set Database					"&Database"
set Board						"&Board"
set MainMenu					"&Main Menu"

set Notebook					"Notebook"
set Multiwindow				"Multiwindow"
set FoldTitleBar				"Fold Titlebar"
set FoldAllTitleBars			"Fold all Titlebars"
set UnfoldAllTitleBars		"Unfold all Titlebars"
set MoveWindow					"Move Window"
set StayOnTop					"Stay on Top"
set HideWhenLeavingTab		"Hide When Leaving Tab"
set SaveLayout					"Save Layout"
set RenameLayout				"Rename Layout"
set LoadLayout					"Restore Layout"
set NewLayout					"New Layout"
set ManageLayouts				"Manage Layouts"
set ShowAllDockingPoints	"Show all Docking Points"
set DockingArrowSize			"Docking Arrow Size"
set Windows						"Windows"

set Pane(analysis)			"Analysis"
set Pane(board)				"Board"
set Pane(editor)				"Notation"
set Pane(tree)					"Tree"
set Pane(games)				"Games"

set ChessInfoDatabase		"Chess Information Data Base"
set Shutdown					"Shutdown..."
set QuitAnyway					"Quit anyway?"
set CancelLogout				"Cancel Logout"
set AbortWriteOperation		"Abort write operation"
set ConfirmOverwrite			"Overwrite existing layout '%s'?"
set ConfirmDelete				"Really delete layout '%s'?"
set UpdatesAvailable			"Updates available"

set WriteOperationInProgress "Write operation in progress: currently Scidb is modifying/writing database '%s'."
set LogoutNotPossible		"Logout is currently not possible, the result would be a corrupted database."
set RestartLogout				"Aborting the write operation will restart the logout process."
set UnsavedFiles				"The following PGN files are unsaved:"
set ThrowAwayAllChanges		"Do you really want to throw away all changes?"

set Deleted						"Games deleted: %d"
set Changed						"Games changed: %d"
set Added						"Games added: %d"
set DescriptionHasChanged	"Description has changed"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::max

array set PaneOptions {
	board		{ -width 500 -height 540 -minwidth 300 -minheight 300 -expand both }
	tree		{ -width 500 -height 120 -minwidth 250 -minheight 120 -expand y }
	editor	{ -width 500 -height 520 -minwidth 150 -minheight 150 -expand y }
	games		{ -width 500 -height 520 -minwidth 300 -minheight 150 -expand both }
	analysis	{ -width 500 -height 120 -minwidth 300 -minheight 120 -expand x }
}

set BoardLayout {
	root { -shrink none -grow none } {
		panedwindow { -orient vert } {
			panedwindow { -orient horz } {
				pane board %board%
				multiwindow {} {
					frame editor %editor%
					frame games %games%
				}
			}
			panedwindow { -orient horz } {
				frame tree %tree%
				frame analysis:1 %analysis%
			}
		}
	}
}

array set Prios		{ analysis 200 board 500 editor 400 games 100 tree 300 }
array set Options		{ docking:showall no layout:name "" layout:list {} }
array set Defaults	{ menu:background #c3c3c3 }

array set Vars {
	menu:locked		0
	menu:state		normal
	tabs:changed	0
	exit:save		1
	active			1
	updates			{}
	geometry			{}
	need:maxsize	0
	shutdown			0
}

array set MapTerminalToAnalysis {}
array set MapAnalysisToTerminal {}


proc open {} {
	variable Defaults
	variable Options
	variable Vars

	# setup
	::move::setup
	::tcl::mathfunc::srand [clock milliseconds]
	set app .application
	::widget::dialogWatch $app
	set ::util::place::mainWindow $app
	::widget::dialogSetTitle $app [namespace code Title]
	wm protocol $app WM_DELETE_WINDOW [namespace code shutdown]
	set nb [::ttk::notebook $app.nb -takefocus 0] ;# otherwise board does not have focus
	set Vars(control) [::widget::dialogFullscreenButtons $nb]
	bind $nb <Configure> [namespace code PlaceMenues]
	bind $Vars(control) <Configure> +[namespace code PlaceMenues]
	::theme::configureBackground $Vars(control).minimize
	::theme::configureBackground $Vars(control).restore
	::theme::configureBackground $Vars(control).close
	$Vars(control).minimize configure -command { wm iconify .application }
	$Vars(control).restore configure -command { ::menu::viewFullscreen toggle }
	$Vars(control).close configure -command [namespace code shutdown]

	set m [tk::menubutton $nb.menu_main \
		-borderwidth 1 \
		-relief raised \
		-padx 2 \
		-pady 2 \
		-background $Defaults(menu:background) \
		-activebackground [::dropdownbutton::activebackground] \
		-activeforeground [::dropdownbutton::activeforeground] \
		-foreground black \
		-activeforeground white \
		-image $icon::16x12::downArrow(black) \
		-compound right \
	]
	UpdateSettingsText $m
	bind $m <<LanguageChanged>> [namespace code [list UpdateSettingsText $m]]
	bind $m <Enter> [namespace code [list EnterSettings $m]]
	bind $m <Leave> [namespace code [list LeaveSettings $m]]
	bind $m <<MenuWillPost>> [namespace code [list BuildSettingsMenu $m]]
	bind $m <<MenuWillUnpost>> [namespace code [list FinishSettings $m]]
	bind $m <Configure> [namespace code PlaceMenues]
	set Vars(menu:main) $m
	set Vars(menu:updates) $nb.menu_updates

	::ttk::notebook::enableTraversal $nb
	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb]]
	set info [::ttk::frame $nb.information]
	set db [::ttk::frame $nb.database]
	set main [twm::twm $nb.board \
		-makepane  [namespace current]::MakePane \
		-buildpane [namespace current]::BuildPane \
		-resizing  [namespace current]::Resizing \
		-workarea  [namespace current]::workArea \
	]
	$main showall $Options(docking:showall)
	set Vars(frame:information) $info
	set Vars(frame:database) $db
	set Vars(frame:main) $main
	$nb add $info -sticky nsew
	$nb add $db   -sticky nsew
	$nb add $main -sticky nsew
	::widget::notebookTextvarHook $nb $info [namespace current]::mc::Information
	::widget::notebookTextvarHook $nb $db   [namespace current]::mc::Database
	::widget::notebookTextvarHook $nb $main [namespace current]::mc::Board

#	bind $app <Tab> [namespace code [list SwitchTab $nb +1]]
#	bind $app <Shift-Tab> [namespace code [list SwitchTab $nb -1]]
#	bind $app <ISO_Left_Tab> [namespace code [list SwitchTab $nb -1]]
	pack $nb -fill both -expand yes

	bind $app <Destroy> [namespace code { Exit %W }]

#	bind $app <FocusIn> [namespace code [list Activate $nb]]
#	# Will never be triggered. For any reason Tk does not send <FocusOut>
#	# events anymore to toplevels?!
#	bind $app <FocusOut> [namespace code [list Deactivate $nb]]

	if {[tk windowingsystem] eq "x11"} {
		wm client $app [lindex [split [info hostname] .] 0]
		wm protocol $app WM_SAVE_YOURSELF [namespace code [list WmSaveYourself $app]]
		WmSaveYourself $app 0 ;# initial setup

		::scidb::tk::sm connect \
			-restart no \
			-saveYourself [namespace code SmSaveYourself] \
			-interactRequest [namespace code SmInteractRequest] \
			;
	}

	bind $main <<TwmReady>>    [namespace code [list Startup $main %d]]
	bind $main <<TwmGeometry>> [namespace code [list Geometry %d]]
	bind $main <<TwmMenu>>     [namespace code [list TwmMenu %d %x %y]]
	bind $main <<TwmAfter>>    [namespace code board::afterTWM]

	bind .application <<Fullscreen>> [namespace code { Fullscreen %d }]
	::searchentry::bindShortcuts .application

	set Vars(ready) 0
	set Vars(terminal:number) 0

	if {[::process::testOption initial-layout]} {
		set Options(layout:name) ""
		set Options(layout:list) {}
		set Vars(layout) ""
	} else {
		if {	[string length $Options(layout:name)]
			&& ![file exists [file join $::scidb::dir::layout "$Options(layout:name).layout"]]} {
			set Options(layout:name) ""
		}
		set Vars(layout) $Options(layout:name)
	}

	set Vars(loading) 1
	loadInitialLayout $main
	$main load $Options(layout:list)
	set Vars(loading) 0
}


proc loadInitialLayout {main} {
	variable BoardLayout
	variable PaneOptions

	set layout $BoardLayout
	foreach name [array names PaneOptions] {
		set layout [string map [list %${name}% [list $PaneOptions($name)]] $layout]
	}
	$main init $layout
}


proc nameVarFromUid {uid} {
	set name [NameFromUid $uid]
	if {$name eq "analysis"} {
		variable MapTerminalToAnalysis
		variable NameVar
		variable Vars

		set terminalNumber [NumberFromUid $uid]
		set analysisNumber $MapTerminalToAnalysis($terminalNumber)
		set nameVar [namespace current]::NameVar($analysisNumber)
		trace add variable [namespace current]::mc::Pane($name) write \
			[namespace code [list UpdateNameVar $analysisNumber]]
		UpdateNameVar $analysisNumber
	} else {
		set nameVar [namespace current]::mc::Pane($name)
	}
	return $nameVar
}


proc NameFromUid {uid}   { return [lindex [split $uid :] 0] }
proc NumberFromUid {uid} { return [lindex [split $uid :] 1] }


proc TabChanged {nb} {
	variable Vars

	set main $Vars(frame:main)
	if {[string match {*.board} [$nb select]]} { set cmd show } else { set cmd hide }

	foreach w [$main floats] {
		if {[$main get! $w hide 0]} {
			$main $cmd $w
		}
	}
}


proc MakePane {main parent type uid} {
	variable Prios
	variable Vars

	set name [NameFromUid $uid]
	set prio $Prios($name)
	set analysisNumber 0

	if {[string match {analysis:*} $uid]} {
		variable MapTerminalToAnalysis
		variable MapAnalysisToTerminal

		set number [NumberFromUid $uid]
		incr prio [expr {$number - 1}]
		incr Vars(terminal:number)

		if {![info exists MapTerminalToAnalysis($number)]} {
			set MapTerminalToAnalysis($number) $number
			set MapAnalysisToTerminal($number) $number
		}

		set analysisNumber $MapTerminalToAnalysis($number)
	}

	set nameVar [nameVarFromUid $uid]
	set takefocus [expr {$uid eq "board"}]
	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus $takefocus]
	set result [list $frame $nameVar $prio]
	if {$type ne "pane"} { lappend result [expr {$uid ne "editor"}] yes yes }
	switch $name { games { set ns tree::games } editor { set ns pgn } default { set ns $name } }
	bind $frame <Map> [list [namespace current]::${ns}::activate $frame 1]
	bind $frame <Unmap> [list [namespace current]::${ns}::activate $frame 0]
	bind $frame <Destroy> [list [namespace current]::${ns}::closed $frame]
	bind $frame <Destroy> +[namespace code [list DestroyPane $main $uid $analysisNumber]]
	set Vars(frame:$uid) $frame
	return $result
}


proc BuildPane {main frame uid width height} {
	variable Vars

	switch [NameFromUid $uid] {
		analysis	{
			variable MapTerminalToAnalysis
			set analysisNumber $MapTerminalToAnalysis([NumberFromUid $uid])
			set patterNumber 0
			if {!$Vars(loading) && [set patterNumber [expr {$Vars(terminal:number) - 1}]] > 0} {
				set patterNumber $MapTerminalToAnalysis($patterNumber)
			}
			analysis::build $frame $analysisNumber $patterNumber
		}
		board		{ board::build $frame $width $height }
		editor	{ pgn::build $frame $width $height }
		games		{ tree::games::build $frame $width $height }
		tree		{ tree::build $frame $width $height }
	}
}


proc DestroyPane {main uid analysisNumber} {
	variable Vars

	if {$Vars(shutdown)} { return }

	if {[string match {analysis:*} $uid]} {
		variable MapTerminalToAnalysis
		variable MapAnalysisToTerminal

		set terminalNumber $MapAnalysisToTerminal($analysisNumber)
		array unset MapAnalysisToTerminal $analysisNumber
		array set vars [array get Vars frame:*]

		for {set i [expr {$terminalNumber + 1}]} {$i <= $Vars(terminal:number)} {incr i} {
			set newTerminalNumber [expr {$i - 1}]
			set analysisNumber $MapTerminalToAnalysis($i)
			$main changeuid analysis:$i analysis:$newTerminalNumber
			set MapTerminalToAnalysis($newTerminalNumber) $analysisNumber
			set MapAnalysisToTerminal($analysisNumber) $newTerminalNumber
			set Vars(frame:analysis:$newTerminalNumber) $vars(frame:analysis:$i)
			UpdateNameVar $analysisNumber
		}

		array unset Vars frame:analysis:$Vars(terminal:number)
		array unset MapTerminalToAnalysis $Vars(terminal:number)
		incr Vars(terminal:number) -1
	} else {
		array unset Vars frame:$uid
	}
}


proc UpdateNameVar {analysisNumber args} {
	variable MapAnalysisToTerminal

	if {[info exists MapAnalysisToTerminal($analysisNumber)] && ![analysis::active? $analysisNumber]} {
		variable NameVar

		set terminalNumber $MapAnalysisToTerminal($analysisNumber)
		set NameVar($analysisNumber) $mc::Pane(analysis)
		if {$terminalNumber > 1} { append NameVar($analysisNumber) " ($terminalNumber)" }
	}
}


proc newAnalysisPane {analysisNumber} {
	variable MapTerminalToAnalysis
	variable MapAnalysisToTerminal
	variable PaneOptions
	variable Vars

	set highest $Vars(terminal:number)
	set terminalNumber [expr {$highest + 1}]
	set uid analysis:$terminalNumber
	set main $Vars(frame:main)
	set MapTerminalToAnalysis($terminalNumber) $analysisNumber
	set MapAnalysisToTerminal($analysisNumber) $terminalNumber

	if {$highest > 0} {
		$main clone analysis:$highest $uid
	} else {
		$main new frame analysis:1 $PaneOptions(analysis)
	}
}


proc setAnalysisTitle {analysisNumber title} {
	set [namespace current]::NameVar($analysisNumber) $title
}


proc resizePaneHeight {analysisNumber minHeight} {
	variable MapAnalysisToTerminal
	variable Vars

	set main $Vars(frame:main)
	set uid analysis:$MapAnalysisToTerminal($analysisNumber)
	set pane [$main leaf $uid]

	lassign [$main dimension $pane] _ height _ _ _ _
	set height [expr {max($height,$minHeight)}]

	if {[$main isfloat [$main toplevel $pane]]} {
		set height $minHeight
		set maxHeight $minHeight
	} else {
		set maxHeight 0
	}
	$main resize $pane 0 $height 0 $minHeight 0 $maxHeight
}


proc mapToTerminalNumber {analysisNumber} {
	variable MapAnalysisToTerminal

	if {![info exists MapAnalysisToTerminal($analysisNumber)]} { return -1 }
	return $MapAnalysisToTerminal($analysisNumber)
}


proc restoreLayout {name list} {
	variable Options
	variable Vars

	set Vars(loading) 1
	$Vars(frame:main) load $list
	set Vars(loading) 0
	set Vars(layout) $name
	set Options(layout:name) $name
	set Options(layout:list) $list
}


proc loadLayout {name} {
	variable Vars

	set fh [::open [file join $::scidb::dir::layout "$name.layout"] "r"]
	set list [read $fh]
	::close $fh
	restoreLayout $name $list
}


proc inspectLayout {} {
	variable Vars
	return [$Vars(frame:main) inspect {Extent}]
}


proc currentLayout {} {
	return [set [namespace current]::Vars(layout)]
}


proc activeTab {} {
	return [lindex [split [.application.nb select] .] end]
}


proc exists? {uid} {
	variable Vars
	if {![info exists Vars(frame:$uid)]} { return false }
	return [winfo exists $Vars(frame:$uid)]
}


proc shutdown {} {
	variable icon::32x32::shutdown
	variable ::scidb::mergebaseName
	variable Options
	variable Vars

	set dlg .application.shutdown
	if {[winfo exists $dlg]} { return }

	if {[::dialog::messagebox::open?] eq "question"} { bell; return }
	if {[string match .application* [grab current]]} { bell; return }

	#::widget::dialogRaise .application
	raise .application

	if {[::util::photos::busy?]} {
		append msg $::util::photos::mc::DownloadStillInProgress "\n\n"
		append msg $mc::QuitAnyway
		set reply [::dialog::question -parent .application -message $msg -default no]
		if {$reply ne "yes"} { return }
		::util::photos::terminateUpdate
	}

	set n 0
	set unsavedFiles [::scidb::app::get unsavedFiles]
	if {$mergebaseName in $unsavedFiles} { incr n }

	if {[llength $unsavedFiles] > $n} {
		append msg $mc::UnsavedFiles
		append msg <embed>
		append msg $mc::ThrowAwayAllChanges
	
		set reply [::dialog::question \
			-parent .application \
			-message $msg \
			-default no \
			-embed [namespace code [list EmbedUnsavedFiles $unsavedFiles]] \
		]
		if {$reply ne "yes"} { return }
	}

	switch [::game::queryCloseApplication .application] {
		restore	{ set backup 1 }
		discard	{ set backup 0 }
		cancel	{ return }
	}

	foreach toplevel [winfo children .] {
		if {$toplevel ne ".application"} { destroy $toplevel }
	}

	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	pack [tk::frame $dlg.f -border 2 -relief raised]
	pack [tk::label $dlg.f.text -compound left -image $shutdown -text " $mc::Shutdown"] -padx 10 -pady 10
	wm resizable $dlg no no
	wm transient $dlg .application
	::util::place $dlg -parent .application -position center
	update idletasks
	::scidb::tk::wm frameless $dlg
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	::widget::busyCursor on

	prepareExit $backup
	if {[tk windowingsystem] eq "x11"} { ::scidb::tk::sm disconnect }
	set Options(layout:list) [inspectLayout]

	::widget::busyCursor off
	::ttk::releaseGrab $dlg
	set Vars(shutdown) 1
	destroy .application
}


proc prepareExit {{backup 1}} {
	variable Vars

	if {$Vars(exit:save)} {
		::log::delay
		::remote::cleanup
		database::prepareClose
		::scidb::app::close
		if {$backup} { ::game::backup }
		::scidb::app::finalize
		set Vars(exit:save) 0
	}
}


proc switchTab {which} {
	.application.nb select .application.nb.$which
	update idletasks
	${which}::setFocus
}


proc ready? {} {
	variable Vars
	return $Vars(ready)
}


if {[tk windowingsystem] eq "x11"} {

proc WmSaveYourself {app {shutdown 0}} {
	if {$shutdown} { prepareExit }
	wm command $app [concat [::scidb::tk::sm get -command] [::scidb::tk::sm get -argv]]
}


proc SmSaveYourself {shutdown} {
	if {$shutdown} {
		prepareExit
	}
}


proc SmInteractRequest {shutdown} {
	set base [::scidb::app::writing -background no]

	## Handle foreground process ####################################
	if {[string length $base]} {
		set parent [grab current]
		if {[string length $parent] == 0} { set parent .application }
		set base [::util::databaseName $base]
		set msg [format $mc::WriteOperationInProgress $base]

		if {![::scidb::progress::interruptable?]} {
			set detail $mc::LogoutNotPossible
			dialog::error -parent $parent -message $msg -detail $detail -topmost yes 
		} else {
			set buttons [list [list cancel $mc::CancelLogout] [list abort $mc::AbortWriteOperation]]
			set detail  $mc::RestartLogout
			set reply [::dialog::warning \
				-parent $parent \
				-message $msg \
				-detail $detail \
				-buttons $buttons \
				-topmost yes \
				-centeronscreen yes \
			]
			if {$reply eq "cancel"} { return 0 }
			set cmd [namespace code [list SmCallSaveYourself $shutdown]]
			if {[::scidb::progress::interrupt -inform $cmd]} { return 1 }
		}

		::log::suppress yes
		update
		return 0
	}

	## Handle background process - always interruptable #############
	set base [::scidb::app::writing -background yes]
	if {[string length $base] == 0} { return 1 }
	set base [::util::databaseName $base]
	set msg [format $mc::WriteOperationInProgress $base]
	set buttons [list [list cancel $mc::CancelLogout] [list abort $mc::AbortWriteOperation]]

	set reply [::dialog::warning -parent $parent \
		-message $msg \
		-buttons $buttons \
		-topmost yes \
		-centeronscreen yes \
	]
	if {$reply eq "cancel"} { return 0 }
	::log::suppress yes
	::scidb::progress::interrupt -wait yes
	return 1
}


proc SmCallSaveYourself {shutdown} {
	update
	::log::suppress no
	::scidb::tk::sm saveyourself -shutdown $shutdown
}

} ;# [tk windowingsystem] eq "x11"


proc InformAboutUpdates {item} {
	variable Vars

	lappend Vars(updates) $item
	BuildUpdatesButton
}


# TODO: unused
proc Activate {nb} {
	variable Vars

	if {!$Vars(active)} {
		set Vars(active) 1
		set current [lindex [split [$nb select] .] end]
		${current}::setActive yes
	}
}	


# TODO: unused
proc Deactivate {nb} {
	variable Vars

	if {$Vars(active) && ![string match {.application.*} [focus]]} {
		set Vars(active) 0
		set current [lindex [split [$nb select] .] end]
		${current}::setActive no
	}
}	


proc EnterSettings {w} {
	variable Vars

	set Vars(menu:state) active

	if {!$Vars(menu:locked)} {
		$w configure -state active -image $icon::16x12::downArrow(white)
	}
}


proc LeaveSettings {w} {
	variable Vars

	set Vars(menu:state) normal

	if {!$Vars(menu:locked)} {
		$w configure -state normal -image $icon::16x12::downArrow(black)
	}
}


proc BuildSettingsMenu {m} {
	variable Vars

	catch { destroy $m.entries }
	::menu $m.entries
	::menu::build $m.entries

	$m configure \
		-background [::dropdownbutton::activebackground] \
		-activebackground [::dropdownbutton::activebackground] \
		-foreground white \
		-activeforeground [::dropdownbutton::activeforeground] \
		-image $icon::16x12::downArrow(white) \
		-menu $m.entries \
		-direction below \
		;
	set Vars(menu:locked) 1
}


proc FinishSettings {m} {
	variable Defaults
	variable Vars

	$m configure \
		-background $Defaults(menu:background) \
		-activebackground [::dropdownbutton::activebackground] \
		-foreground black \
		-activeforeground white \
		-image $icon::16x12::downArrow(black) \
		;
	set Vars(menu:locked) 0

	if {$Vars(menu:state) eq "normal"} {
		LeaveSettings $m
	} else {
		EnterSettings $m
	}
}


proc MakeUpdateInfo {} {
	variable Vars

	if {[llength $Vars(updates)]} {
		set Vars(updates:tooltip) "${mc::UpdatesAvailable}:"
		foreach item $Vars(updates) {
			switch $item {
				photos { append Vars(updates:tooltip) \n $::util::photos::mc::PhotoFiles }
			}
		}
	}
}


proc BuildUpdatesButton {} {
	variable Defaults
	variable Vars

	set m $Vars(menu:updates)
	if {[winfo exists $m]} { return }

	tk::menubutton $m \
		-borderwidth 1 \
		-relief raised \
		-padx 2 \
		-pady 2 \
		-background $Defaults(menu:background) \
		-activebackground [::dropdownbutton::activebackground] \
		-foreground black \
		-activeforeground white \
		-image $icon::16x16::softwareUpdate \
		;
	bind $m <<LanguageChanged>> [namespace code MakeUpdateInfo]
	bind $m <Enter> [list set [namespace current]::Vars(menu:state) active]
	bind $m <Leave> [list set [namespace current]::Vars(menu:state) normal]
	bind $m <<MenuWillPost>> [namespace code [list BuildUpdatesMenu $m]]
	bind $m <<MenuWillUnpost>> [namespace code [list FinishUpdates $m]]
	bind $m <Configure> [namespace code PlaceMenues]

	PlaceMenues
	MakeUpdateInfo
	tooltip::tooltip $m [namespace current]::Vars(updates:tooltip)
}


proc BuildUpdatesMenu {m} {
	variable Vars

	catch { destroy $m.updates }
	::menu $m.updates

	foreach item $Vars(updates) {
		switch $item {
			photos { set txt $::util::photos::mc::PhotoFiles }
		}
		$m.updates add command -label $txt -command [namespace code [list InstallUpdate $item]]
	}

	$m configure \
		-background [::dropdownbutton::activebackground] \
		-activebackground [::dropdownbutton::activebackground] \
		-foreground white \
		-activeforeground white \
		-menu $m.updates \
		-direction below \
		;
	set Vars(menu:locked) 1
}


proc FinishUpdates {m} {
	variable Defaults
	variable Vars

	$m configure \
		-background $Defaults(menu:background) \
		-activebackground [::dropdownbutton::activebackground] \
		-foreground black \
		-activeforeground white \
		;
	set Vars(menu:locked) 0
}


proc InstallUpdate {item} {
	variable Vars

	::util::photos::openDialog .application
	set i [lsearch $Vars(updates) $item]
	set Vars(updates) [lreplace $Vars(updates) $i $i]

	if {[llength $Vars(updates)] == 0} {
		destroy $Vars(menu:updates)
	}
}


proc EmbedUnsavedFiles {unsaved w infoFont alertFont} {
	::html $w.t \
		-center no \
		-fittowidth no \
		-borderwidth 0 \
		-doublebuffer no \
		-exportselection yes \
		-imagecmd [namespace code GetImage] \
		-css "html { background: [$w cget -background] }"
		;
	place $w.t -x 10 -y 0

	$w.t onmouseover [list [namespace current]::MouseEnter $w.t]
	$w.t onmouseout  [list [namespace current]::MouseLeave $w.t]

	array set font [font actual $infoFont]
	set family $font(-family)
	set size [expr {abs($font(-size))}]

	append content "<table style='font-family: ${family}; font-size: ${size}px;'>"

	foreach file $unsaved {
		lassign [::scidb::db::get changes $file] added changed deleted descriptionHasChanged
		append content "<tr>"
		append content "<td id='$file'>[::util::databaseName $file]&ensp;</td>"
		if {$deleted > 0} {
			append content "<td id='Deleted' count='$deleted'><img src='deleted'></td>"
		}
		if {$changed > 0} {
			append content "<td id='Changed' count='$changed'><img src='edit'></td>"
		}
		if {$added > 0} {
			append content "<td id='Added' count='$added'><img src='plus'></td>"
		}
		if {$descriptionHasChanged} {
			append content "<td id='DescriptionHasChanged'><img src='info'></td>"
		}
		append content "</tr>"
	}

	append content "</table>"
	lassign [$w.t parse $content] x0 y0 x1 y1
	set margins [expr {2*[$w.t margin]}]
	$w configure -width [expr {$x1 - $x0 + $margins + 10}] -height [expr {$y1 - $y0 + $margins}]
}


proc GetImage {code} {
	return [list [set ::icon::12x12::$code] [namespace code DoNothing]]
}


proc DoNothing {args} {
	# nothing to do
}


proc MouseEnter {w nodes} {
	foreach node $nodes {
		set id [$node attribute -default {} id]
		if {[llength $id]} {
			if {[info exists mc::$id]} {
				set count [$node attribute -default 0 count]
				if {$count} {
					set id [format [set mc::$id] $count]
				} else {
					set id [set mc::$id]
				}
			}
			::tooltip::show $w $id
		}
	}
}


proc MouseLeave {w node} {
	foreach node $nodes {
		set id [$node attribute -default {} id]
		if {[llength $id]} { return [::tooltip::hide] }
	}
}


proc PlaceMenues {} {
	variable Vars

	# place controls
	set w $Vars(control)
	set parent [winfo parent $w]
	if {[::menu::fullscreen?]} {
		set x [expr {[winfo width $parent] - [winfo width $w]}]
		place $w -x $x -y 0 -height [winfo height $Vars(menu:main)]
	} else {
		place forget $w
	}

	# place main menu
	set m $Vars(menu:main)
	set parent [winfo parent $m]
	set x [expr {[winfo width $parent] - [winfo width $m]}]
	if {$Vars(control) in [place slaves $parent]} {
		set x [expr {$x - [winfo width $Vars(control)]}]
	}
	place $m -x $x -y 0

	# place update menu
	set m $Vars(menu:updates)
	if {[winfo exists $m]} {
		$m configure -height [expr {[winfo height $Vars(menu:main)] - 2}]
		set x [expr {$x - [winfo width $m] - 5}]
		place $m -x $x -y 0
	}
}


proc UpdateSettingsText {w} {
	variable Vars

	lassign [::tk::UnderlineAmpersand $mc::MainMenu] text ul
	$w configure -text " $text" -underline [incr ul]
}


proc ChooseLanguage {parent} {
	variable ::country::icon::flag

	if {!$::scidb::dir::setup} { return }
	wm protocol $parent WM_DELETE_WINDOW {#}
	set dlg $parent.lang
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [tk::frame $dlg.top -border 2 -relief raised]
	pack $top
	set r 0
	foreach lang [lsort [array names ::mc::input]] {
		if {[string length $lang]} {
			set icon ""
			catch { set icon $flag([set ::mc::langToCountry([set ::mc::lang$lang])]) }
			if {[string length $icon] == 0} { set icon none }
			set code [set ::mc::lang$lang]
			ttk::button $top.$code \
				-style aligned.TButton \
				-text " $lang" \
				-image $icon \
				-compound left \
				-command [namespace code [list SetupLang $code]] \
				;
			grid $top.$code -column 1 -row [incr r 1]
			bind $top.$code <Return>	{ event generate %W <Key-space>; break }
			bind $top.$code <Down>		{ focus [tk_focusNext [focus]] }
			bind $top.$code <Up>			{ focus [tk_focusPrev [focus]] }
		}
	}
	wm resizable $dlg no no
	wm transient $dlg $parent
	::util::place $dlg -parent $parent -position center
	update idletasks
	::scidb::tk::wm frameless $dlg
	wm deiconify $dlg
	focus $top.en
	::ttk::grabWindow $dlg
	vwait ::mc::langID
	::ttk::releaseGrab $dlg
	catch { destroy $dlg }
	::mc::setLang $mc::langID
	wm protocol $parent WM_DELETE_WINDOW [namespace code shutdown]
	focus -force .application
}


proc SetupLang {langID} {
	pgn::setActiveLang $::mc::langID 0
	set ::mc::langID $langID
	::font::useLanguage $langID
	pgn::setActiveLang $langID 1
}


proc Title {} {
	return "$::scidb::app - $mc::ChessInfoDatabase"
}


proc Exit {w} {
	if {$w eq ".application"} {
		set ::remote::blocking 1
		set ::remote::postponed 0
		::options::write
		::load::write
		exit
	}
}


# proc SwitchTab {nb dir} {
# 	set index [expr {[$nb index [$nb select]] + $dir}]
# 	set num [llength [$nb tabs]]
# 	if {$index == -1} { set index [expr {$num - 1}] }
# 	if {$index == $num} { set index 0 }
# 	$nb select $index
# }


proc Startup {main args} {
	variable Vars

	if {$Vars(ready)} { return }

	lassign $args width height
	set app .application
	set nb $app.nb

	information::build $Vars(frame:information) $width $height
	database::build $Vars(frame:database) $width $height

	foreach tab {information database board} {
		bind $Vars(frame:$tab) <FocusIn>  [namespace code [list ${tab}::setActive yes]]
		bind $Vars(frame:$tab) <FocusOut> [namespace code [list ${tab}::setActive no]]
	}

	foreach pane {information database} {
		set frame $Vars(frame:$pane)
		bind $frame <Map> [list [namespace current]::${pane}::activate $frame 1]
		bind $frame <Unmap> [list [namespace current]::${pane}::activate $frame 0]
	}

	if {[::process::testOption show-board]} {
		set tab board
	} elseif {[::process::testOption re-open] || [llength [::process::arguments]]} {
		set tab database
	} else {
		set tab information
	}

	::util::place $app -position center
	wm deiconify $app
	database::finish $app
	::splash::close
	ChooseLanguage $app
	::load::writeLog
	update idletasks
	set ::scidb::intern::blocked 0
	set Vars(ready) 1

	database::preOpen $app

	foreach file [::process::arguments] {
		database::openBase .application [::util::databasePath $file] yes \
			-encoding $::encoding::autoEncoding
	}
 
	if {[::game::recover $app] + [::game::reopenLockedGames $app] > 0} {
		set tab board
	}
	$nb select .application.nb.$tab

	after idle [namespace code [list switchTab $tab]]
	after idle [list ::beta::welcomeToScidb $app]
	::util::photos::checkForUpdate [namespace current]::InformAboutUpdates
}


proc Fullscreen {flag} {
#	variable Vars
#	if {!$flag && [llength $Vars(geometry)} { Geometry $Vars(geometry) }
}


proc Geometry {data} {
	variable Vars

	set Vars(geometry) $data
	if {[::menu::fullscreen?]} { return }

	lassign $data width height minwidth minheight maxwidth maxheight expand

	set incrH 2
	set incrV [expr {[::theme::notebookTabPaneSize .application.nb] + 2}]
	incr width  $incrH
	incr height $incrV
	if {$minwidth} { incr minwidth $incrH }
	if {$maxwidth} { incr maxwidth $incrH }
	if {$minheight} { incr minheight $incrV }
	if {$maxheight} { incr maxheight $incrV }

	if {[::widget::checkIsKDE]} {
		# IMPORTANT NOTE:
		# Without temporarily disabling the resize behavior some window
		# managers like KDE will not shrink the window in any case.
		wm resizable .application false false
	}

	if {$minwidth || $minheight} {
		wm minsize .application $minwidth $minheight
	}
	if {$maxwidth || $maxheight || $Vars(need:maxsize)} {
		# TODO: does this work with multi-screens?
		if {$maxwidth == 0} {
			set maxwidth [winfo screenwidth .application]
		}
		if {$maxheight == 0} {
			set maxwidth [winfo screenheight .application]
		}
		wm maxsize .application $maxwidth $maxheight
		set Vars(need:maxsize) 1
	}
	wm geometry .application ${width}x${height}

	set resizeW [expr {$minwidth == 0 || $minwidth != $maxwidth}]
	set resizeH [expr {$minheight == 0 || $minheight != $maxheight}]

	if {[::widget::checkIsKDE]} {
		# We need a delay, otherwise resizing may not work, see above.
		after 50 [list wm resizable .application $resizeW $resizeH]
	}
}


proc Resizing {twm toplevel width height} {
	if {[::menu::fullscreen?]} {
		set width [winfo screenwidth .application]
		set height [winfo screenheight .application]
		incr width -2	;# borders
		incr height -2	;# borders
	} else {
		lassign [winfo workarea .application] _ _ ww wh
		lassign [winfo extents .application] ew1 ew2 eh1 eh2
		set width [expr {min($width, $ww - $ew1 - $ew2 - 2)}]	   ;# regard borders
		set height [expr {min($height, $wh - $eh1 - $eh2 - 2)}]	;# regard borders
	}
	return [list $width $height]
}


proc workArea {main} {
	if {[::menu::fullscreen?]} {
		set width [winfo screenwidth .application]
		set height [winfo screenheight .application]
	} else {
		lassign [winfo workarea .application] _ _ ww wh
		lassign [winfo extents .application] ew1 ew2 eh1 eh2
		set width [expr {$ww - $ew1 - $ew2}]
		set height [expr {$wh - $eh1 - $eh2 - [::theme::notebookTabPaneSize .application.nb]}]
	}
	incr width -2	;# borders
	incr height -2	;# borders
	return [list $width $height]
}


proc TwmMenu {w x y} {
	set menu .application.nb.board.__menu__
	# Try to catch accidental double clicks.
	if {[winfo exists $menu]} { return }
	menu $menu
	catch { wm attributes $menu -type popup_menu }
	makeLayoutMenu $menu $w
	bind $menu <<MenuUnpost>> [list after idle [list catch [list destroy $menu]]]
	tk_popup $menu $x $y
}


proc currentLayoutIsEqTo {layout {ignoreFloatPositions false}} {
	variable Options
	variable Vars

	set currentLayout [inspectLayout]
	if {$ignoreFloatPositions} { set opts -all } else { set opts {} }
	set lhs [regsub {*}$opts -- {[-][xy]\s\s*[0-9]*} $currentLayout ""]
	set rhs [regsub {*}$opts -- {[-][xy]\s\s*[0-9]*} $layout ""]
	set lhs [string map {"  " " "} [string trim $lhs]]
	set rhs [string map {"  " " "} [string trim $rhs]]
	return [expr {$lhs eq $rhs}]
}


proc renameLayout {parent name} {
	variable layout_

	SaveLayout $parent [list [namespace current]::RenameLayout $name] $name $mc::RenameLayout
	return $layout_
}


proc deleteLayout {parent name} {
	variable Vars
	variable Options

	if {[::dialog::question \
			-parent $parent \
			-message [format $mc::ConfirmDelete $name] \
			-default no \
		] eq "yes"} {
		set filename [file join $::scidb::dir::layout "$name.layout"]
		file delete -force -- $filename
		if {$Vars(layout) eq $name} { set Vars(layout) "" }
		if {$Options(layout:name) eq $name} { set Options(layout:name) "" }
	}
}


proc makeLayoutMenu {menu {w ""}} {
	variable flat_
	variable ismultiwindow_
	variable stayontop_
	variable hide_
	variable layout_
	variable PaneOptions
	variable Options
	variable Vars

	set main $Vars(frame:main)
	set count 0

	if {[string length $w]} {
		set flat_ [$main get! $w flat -1]

		if {$flat_ != -1 && ![$main ismetachild $w]} {
			$menu add checkbutton \
				-label " $mc::FoldTitleBar" \
				-variable [namespace current]::flat_ \
				-command [list $main togglebar $w] \
				;
			::theme::configureCheckEntry $menu
			incr count
		}

		set v $w
		if {!([$main ismultiwindow $w] || [$main isnotebook $w])} { set v [$main parent $w] }
		if {[$main ismultiwindow $v] || [$main isnotebook $v]} {
			if {$count} { $menu add separator }
			set ismultiwindow_ [$main ismultiwindow $v]
			$menu add radiobutton \
				-label " $mc::Multiwindow" \
				-variable [namespace current]::ismultiwindow_ \
				-value 1 \
				-command [list $main togglenotebook $v] \
				;
			::theme::configureRadioEntry $menu
			$menu add radiobutton \
				-label " $mc::Notebook" \
				-variable [namespace current]::ismultiwindow_ \
				-value 0 \
				-command [list $main togglenotebook $v] \
				;
			::theme::configureRadioEntry $menu
			incr count
		}
	}

	set unfolded [lmap v [$main find flat 0] { expr {[$main ismetachild $v] ? [continue] : $v}}]
	set folded [lmap v [$main find flat 1] { expr {[$main ismetachild $v] ? [continue] : $v}}]
	if {[llength $unfolded] || [llength $folded]} {
		if {$count} { $menu add separator }
		$menu add command \
			-label " $mc::FoldAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list [namespace current]::ToggleTitlebars $main $unfolded] \
			-state [expr {[llength $unfolded] ? "normal" : "disabled"}] \
			;
		$menu add command \
			-label " $mc::UnfoldAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list [namespace current]::ToggleTitlebars $main $folded] \
			-state [expr {[llength $folded] ? "normal" : "disabled"}] \
			;
		incr count
	}

	if {[llength [set floats [$main floats]]]} {
		if {$count} { $menu add separator }
		menu $menu.stayontop
		$menu add cascade \
			-menu $menu.stayontop \
			-label " $mc::StayOnTop" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach v $floats {
			set stayontop_($v) [$main get! $v stayontop 0]
			$menu.stayontop add checkbutton \
				-label [set [$main get [$main leader $v] name]] \
				-variable [namespace current]::stayontop_($v) \
				-command [namespace code [list StayOnTop $main $v]] \
				;
			::theme::configureCheckEntry $menu.stayontop
		}
		menu $menu.hide
		$menu add cascade \
			-menu $menu.hide \
			-label " $mc::HideWhenLeavingTab" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach v $floats {
			set hide_($v) [$main get! $v hide 0]
			$menu.hide add checkbutton \
				-label [set [$main get [$main leader $v] name]] \
				-variable [namespace current]::hide_($v) \
				-command [namespace code [list HideWhenLeavingTab $main $v]] \
				;
			::theme::configureCheckEntry $menu.hide
		}
		set editor [$main leaf editor]
		if {[$main ismetachild $editor]} { set editor [$main parent $editor] }
		set i [lsearch $floats $editor]
		if {$i >= 0} { set floats [lreplace $floats $i $i] }
		if {[llength $floats] > 0} {
			menu $menu.close
			$menu add cascade \
				-menu $menu.close \
				-label " $::mc::Close" \
				-image $::icon::16x16::close \
				-compound left \
				;
			foreach v $floats {
				$menu.close add command \
					-label [set [$main get [$main leader $v] name]] \
					-image $::icon::16x16::none \
					-compound left \
					-command [list $main close $v] \
					;
			}
		}
		incr count
	}

	if {$count} { $menu add separator }
	menu $menu.windows
	$menu add cascade \
		-menu $menu.windows \
		-label " $mc::Windows" \
		-image $::icon::16x16::none \
		-compound left \
		;
	foreach name [array names PaneOptions] {
		if {$name ni {board analysis editor}} {
			variable vis_${name}_ [$main isdocked $name]
			$menu.windows add checkbutton \
				-label $mc::Pane($name) \
				-variable [namespace current]::vis_${name}_ \
				-command [namespace code [list ChangeState $main $name]] \
				;
			::theme::configureCheckEntry $menu.windows
		}
	}
	foreach uid [$main leaves] {
		if {[string match {analysis:*} $uid] && [$main isdocked $uid]} {
			variable MapTerminalToAnalysis
			variable NameVar
			variable vis_${uid}_ 1
			$menu.windows add checkbutton \
				-label $NameVar($MapTerminalToAnalysis([NumberFromUid $uid])) \
				-variable [namespace current]::vis_${uid}_ \
				-command [namespace code [list ChangeState $main $uid]] \
				;
			::theme::configureCheckEntry $menu.windows
		}
	}
	incr count

#	if {[string length $w] && [$main get $w move 0]} {
#		set hidden [$main hidden $w]
#		if {[llength $hidden]} {
#			menu $menu.move
#			$menu add cascade -menu $menu.move -label $mc::MoveWindow
#			foreach v $hidden {
#				$menu.move add command \
#					-label [set [$main get [$main leader $v] name]] \
#					-command [namespace code [list MoveWindow $main $w $v]] \
#					;
#			}
#		}
#		incr count
#	}

	if {$count} { $menu add separator }
	set names [lmap f [glob -nocomplain -directory $::scidb::dir::layout *.layout] {
		file tail [file rootname $f]}]
	if {[llength $names]} {
		menu $menu.load
		$menu add cascade \
			-menu $menu.load \
			-label " $mc::LoadLayout" \
			-image $::icon::16x16::layout \
			-compound left \
			;
		foreach name $names {
			$menu.load add command \
				-label $name \
				-image $::icon::16x16::none \
				-compound left \
				-command [namespace code [list loadLayout $name]] \
				;
		}
	}
	set labelName " $mc::SaveLayout"
	set state "disabled"
	if {[string length $Vars(layout)]} {
		if {$Vars(layout) ni $names} {
			set Vars(layout) ""
			set Options(layout:name) ""
		} else {
			append labelName " \"$Vars(layout)\""
			if {![currentLayoutIsEqTo $Options(layout:list) false]} { set state "normal" }
		}
	}
	set layout_ $Vars(layout)
	if {[string length $Vars(layout)]} {
		$menu add command \
			-label $labelName \
			-image $::icon::16x16::save \
			-compound left \
			-command [namespace code [list DoSaveLayout $main $names]] \
			-state $state \
			;
	}
	$menu add command \
		-label " $mc::SaveLayout..." \
		-image $::icon::16x16::saveAs \
		-compound left \
		-command [namespace code [list SaveLayout \
				$main [namespace current]::DoSaveLayout "" $mc::SaveLayout]]
		;
	$menu add command \
		-label " $mc::ManageLayouts..." \
		-image $::icon::16x16::setup \
		-compound left \
		-command [list [namespace current]::layout::open $main $Vars(layout)] \
		-state [expr {[llength $names] ? "normal" : "disabled"}] \
		;

	$menu add separator
	$menu add checkbutton \
		-label " $mc::ShowAllDockingPoints" \
		-variable [namespace current]::Options(docking:showall) \
		-command [namespace code [list ShowAllDockingPoints $main]] \
		;
	::theme::configureCheckEntry $menu

	$menu add separator
	menu $menu.size
	$menu add cascade \
		-menu $menu.size \
		-label " $mc::DockingArrowSize" \
		-image $::icon::16x16::none \
		-compound left \
		;
	foreach {size pixels} {Small 16 Medium 24 Large 32} {
		$menu.size add radiobutton \
			-label " [set ::toolbar::mc::$size]" \
			-variable ::twm::Defaults(cross:size) \
			-value $pixels \
			;
	}
}


proc ShowAllDockingPoints {main} {
	variable Options
	$main showall $Options(docking:showall)
}


proc MoveWindow {main w recv} {
	$main undock -temporary $w
	$main dock $w $recv left
}


proc ChangeState {main uid} {
	variable PaneOptions

	if {[$main isdocked $uid]} {
		destroy [$main leaf $uid]
	} else {
		$main new frame $uid $PaneOptions($uid)
	}
}


proc SaveLayout {parent cmd name title} {
	variable layout_

	if {[string length $name] == 0} { set name $mc::NewLayout }
	set layout_ $name
	set names [lmap f [glob -nocomplain -directory $::scidb::dir::layout *.layout] {
		file tail [file rootname $f]}]
	set dlg [tk::toplevel $parent.save -class Scidb]
	pack [set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]]
	set cb [ttk::combobox $top.input \
		-height 10 \
		-width 40 \
		-textvariable [namespace current]::layout_ \
		-values $names \
	]
	$cb selection range 0 end

	grid $cb -row 1 -column 1 -sticky nsew
	grid columnconfigure $top {0 2} -minsize $::theme::padX
	grid rowconfigure $top {0 2} -minsize $::theme::padY

	::widget::dialogButtons $dlg {ok cancel} -default ok
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.ok configure -command [namespace code [list Execute \
		[list {*}$cmd $parent $names] \
		[list destroy $dlg] \
	]]

	wm withdraw $dlg
	wm resizable $dlg no no
	wm transient $dlg .application
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg -parent .application -position center
	wm deiconify $dlg
	focus $cb
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc Execute {args} { foreach cmd $args { {*}$cmd } }


proc RenameLayout {oldName parent names} {
	variable Options
	variable Vars
	variable layout_

	if {$layout_ eq $oldName} { return }
	set newName $layout_
	
	if {$newName in $names} {
		if {[::dialog::question \
				-parent $parent \
				-message [format $mc::ConfirmOverwrite $newName] \
				-default no \
			] ne "yes"} {
			set layout_ ""
			return
		}
	}
	set source [file join $::scidb::dir::layout "$oldName.layout"]
	set target [file join $::scidb::dir::layout "$newName.layout"]
	file rename -force -- $source $target
	if {$Vars(layout) eq $oldName} { set Vars(layout) $oldName }
	if {$Options(layout:name) eq $oldName} { set Options(layout:name) $newName }
}


proc DoSaveLayout {parent names} {
	variable layout_
	variable Options
	variable Vars

	if {$layout_ in $names} {
		if {[::dialog::question \
				-parent $parent \
				-message [format $mc::ConfirmOverwrite $layout_] \
				-default no \
			] ne "yes"} {
			set layout_ ""
			return
		}
	}
	set fh [::open [file join $::scidb::dir::layout "$layout_.layout"] "w"]
	puts $fh [inspectLayout]
	close $fh
	set Vars(layout) $layout_
	set Options(layout:name) $layout_
}


proc ToggleTitlebars {main windows} {
	$main togglebar {*}$windows
}


proc HideWhenLeavingTab {main w} {
	variable hide_
	$main set! $w hide $hide_($w)
}


proc StayOnTop {main w} {
	variable stayontop_

	$main set! $w stayontop $stayontop_($w)
	if {$stayontop_($w)} {
		set master [winfo toplevel $main]
		wm transient $w $master
		raise $w $master
		# NOTE: not every window manager is re-decorating the window.
		catch { wm attributes $w -type dialog }
	} else {
		wm transient $w ""
	}
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


wm iconphoto .application -default $::icon::64x64::logo $::icon::16x16::logo


namespace eval icon {
namespace eval 16x12 {

set downArrow(white) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAMAQMAAABRKa/CAAAABlBMVEUAAwD////ieeUNAAAA
	AXRSTlMAQObYZgAAAB9JREFUCNdjYIAB+z8M8j8Y+D8wsD9gYD7AwNgAlwEAZ6cFfe/e8VYA
	AAAASUVORK5CYII=
}]

set downArrow(black) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAMAQMAAABRKa/CAAAABlBMVEUAAwAAAADix8MfAAAA
	AXRSTlMAQObYZgAAAB9JREFUCNdjYIAB+z8M8j8Y+D8wsD9gYD7AwNgAlwEAZ6cFfe/e8VYA
	AAAASUVORK5CYII=
}]

} ;# namespace 16x12
namespace eval 32x32 {

set shutdown [image create photo -data {
	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
}]

} ;# namespace 32x32
} ;# namespace icon
} ;# namespace application

rename ::tk::PostOverPoint ::tk::_PostOverPoint_application

proc ::tk::PostOverPoint {menu x y {entry {}}} {
	if {[string match ".application.nb.menu_*.entries" $menu]} {
		set rx [winfo rootx .application]
		set mw [winfo reqwidth $menu]
		set x [expr {min($rx + [winfo width .application] - $mw, $x)}]
	}

	::tk::_PostOverPoint_application $menu $x $y $entry
}

# vi:set ts=3 sw=3:
