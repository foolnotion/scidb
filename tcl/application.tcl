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

::util::source application

namespace eval application {
namespace eval mc {

set Tab(information)			"&Information"
set Tab(database)				"&Database"
set Tab(board)					"&Board"
set MainMenu					"&Main Menu"

set ChessInfoDatabase		"Chess Information Data Base"
set Shutdown					"Shutdown..."
set QuitAnyway					"Quit anyway?"
set CancelLogout				"Cancel Logout"
set AbortWriteOperation		"Abort write operation"
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
	tree		{ -width 500 -height 120 -minwidth 250 -minheight 100 -expand y }
	editor	{ -width 500 -height 520 -minwidth 150 -minheight 200 -expand y }
	games		{ -width 500 -height 520 -minwidth 300 -minheight 100 -expand both }
	analysis	{ -width 500 -height 120 -minwidth 300 -minheight 120 -expand x }
	eco		{ -width 500 -height 520 -minwidth 150 -minheight 100 -expand both }
}

set BoardLayout {
	root { -shrink none -grow none -width 1005 -height 689 } {
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

set FontSizeActive 0

array set Prios		{ analysis 200 board 500 editor 400 games 100 tree 300 eco 90 }
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
	variable BoardLayout
	variable PaneOptions
	variable Defaults
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
	set Vars(notebook) $nb
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

	set Vars(ready) 0
	set Vars(terminal:number) 0
	set Vars(frame:information) $info
	set Vars(frame:database) $db

	# IMPORTANT NOTE: this layout has to be loaded before any other layout will be loaded.
	set twm [twm::make $nb.board board \
		[namespace current]::Prios \
		[array get PaneOptions] \
		$BoardLayout \
		-makepane [namespace current]::MakePane \
		-buildpane [namespace current]::BuildPane \
	]
	bind $twm <<TwmReady>> [namespace code [list Startup $twm %d]]
	bind $twm <<TwmAfter>> [namespace code board::afterTWM]
	twm::load $twm

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

	set incrFontSize { ::font::changeFontSize +1 }
	set decrFontSize { ::font::changeFontSize -1 }

	# TODO: Ctrl-Shift-minus is not working on most keyboards.
	# NOTE: Ctrl-Alt is problematic and cannot be used.
	# Possible workaround: Only bind Control-minus and test whether Caps Lock is on.
	# Possible workaround: Bind function keys instead of Control-Shift.
	bind .application <Control-Shift-plus>				$incrFontSize
	bind .application <Control-Shift-KP_Add>			$incrFontSize
	bind .application <Control-Shift-minus>			$decrFontSize
	bind .application <Control-Shift-KP_Subtract>	$decrFontSize
	bind .application <<FontSizeChanged>>				[namespace code { FontSizeChanged %W %d }]

	::searchentry::bindShortcuts .application
}


proc twm {{id ""}} {
	variable Vars

	if {[string length $id]} { return $Vars($id:twm) }
	set tab [$Vars(notebook) select]
	if {[string match {*.board} $tab]} { return $Vars(board:twm) }
	if {[string match {*.database} $tab]} { return [database::twm] }
	return -code error "[namespace current]::twm: no twm selected"
}


proc nameVarFromUid {uid} {
	set name [NameFromUid $uid]
	if {$name eq "analysis"} {
		variable NameVar
		variable Vars

		set analysisNumber [analysisNumberFromUid $uid]
		set nameVar [namespace current]::NameVar($analysisNumber)
		trace add variable [namespace current]::twm::mc::Pane($name) write \
			[namespace code [list UpdateNameVar $analysisNumber]]
		UpdateAnalysisTitle $analysisNumber
	} else {
		set nameVar [namespace current]::twm::mc::Pane($name)
	}
	return $nameVar
}


proc analysisNumberFromUid {uid} {
	variable MapTerminalToAnalysis
	return $MapTerminalToAnalysis([NumberFromUid $uid])
}


proc NameFromUid {uid}   { return [lindex [split $uid :] 0] }
proc NumberFromUid {uid} { return [lindex [split $uid :] 1] }


proc TabChanged {nb} {
	variable Vars

	set twm $Vars(board:twm)
	if {[string match {*.board} [$nb select]]} { set cmd show } else { set cmd hide }

	foreach w [$twm floats] {
		if {[$twm get! $w hide 0]} { $twm $cmd $w }
	}
}


proc MakePane {twm parent type uid} {
	variable Prios
	variable Vars

	set name [NameFromUid $uid]
	set prio $Prios($name)
	set analysisNumber 0
	set transient 0

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
		set Vars(title:$analysisNumber) ""
		if {$analysisNumber > 1} { set transient 1 }
	}

	set nameVar [nameVarFromUid $uid]
	set takefocus [expr {$uid eq "board"}]
	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus $takefocus]
	set result [list $frame $nameVar $prio $transient [expr {$uid ne "editor"}] yes yes]
	switch $name {
		games   { set ns tree::games }
		editor  { set ns pgn }
		default { set ns $name }
	}
	bind $frame <Map> [list [namespace current]::${ns}::activate $frame 1]
	bind $frame <Unmap> [list [namespace current]::${ns}::activate $frame 0]
	bind $frame <Destroy> [list [namespace current]::${ns}::closed $frame]
	bind $frame <Destroy> +[namespace code [list DestroyPane $twm $uid $analysisNumber]]
	set Vars(frame:$uid) $frame
	set Vars(align:board:$uid) 0
	return $result
}


proc BuildPane {twm frame uid width height} {
	variable Vars

	switch [NameFromUid $uid] {
		analysis	{
			variable MapTerminalToAnalysis
			set analysisNumber $MapTerminalToAnalysis([NumberFromUid $uid])
			set patternNumber 0
			if {!$Vars(loading) && [set patternNumber [expr {$Vars(terminal:number) - 1}]] > 0} {
				set patternNumber $MapTerminalToAnalysis($patternNumber)
			}
			analysis::build $frame $analysisNumber $patternNumber
		}
		eco {
			if {"editor" in [$twm leaves]} {
				lassign [$twm dimension [$twm leaf editor]] width height _ _ _ _
			}
			eco::build $frame -id board
			$frame configure -width $width -height $height
			set Vars(align:board:eco) 1
		}
		tree {
			tree::build $twm $frame $width $height
			set Vars(align:board:tree) 1
		}
		board		{ board::build $frame $width $height }
		editor	{ pgn::build $frame $width $height }
		games		{ tree::games::build $twm $frame $width $height }
		default	{ return -code error "BuildPane: unknown pane $uid" }
	}
}


proc DestroyPane {twm uid analysisNumber} {
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
			set number $MapTerminalToAnalysis($i)
			$twm set [$twm leaf analysis:$i] transient [expr {$newTerminalNumber != 1}]
			$twm changeuid analysis:$i analysis:$newTerminalNumber
			set MapTerminalToAnalysis($newTerminalNumber) $number
			set MapAnalysisToTerminal($number) $newTerminalNumber
			set Vars(frame:analysis:$newTerminalNumber) $vars(frame:analysis:$i)
			UpdateAnalysisTitle $number
		}

		array unset Vars frame:analysis:$Vars(terminal:number)
		array unset MapTerminalToAnalysis $Vars(terminal:number)
		incr Vars(terminal:number) -1
	} else {
		array unset Vars frame:$uid
	}
}


proc UpdateNameVar {analysisNumber args} {
	UpdateAnalysisTitle $analysisNumber
}


proc UpdateAnalysisTitle {analysisNumber {title ""}} {
	variable Vars

	if {[string length $title] == 0} {
		set title $Vars(title:$analysisNumber)
	}
	updateAnalysisTitle $analysisNumber $title
}


proc updateAnalysisTitle {analysisNumber {title ""}} {
	variable MapAnalysisToTerminal
	variable NameVar
	variable Vars

	set Vars(title:$analysisNumber) $title
	if {[string length $title] == 0} { set title $twm::mc::Pane(analysis) }
	if {[info exists MapAnalysisToTerminal($analysisNumber)]} {
		set terminalNumber $MapAnalysisToTerminal($analysisNumber)
		if {$terminalNumber > 1} { append title " ($terminalNumber)" }
	}
	set NameVar($analysisNumber) $title
}


proc newAnalysisPane {analysisNumber} {
	variable MapTerminalToAnalysis
	variable MapAnalysisToTerminal
	variable PaneOptions
	variable Vars

	set highest $Vars(terminal:number)
	set terminalNumber [expr {$highest + 1}]
	set uid analysis:$terminalNumber
	set twm $Vars(board:twm)
	set MapTerminalToAnalysis($terminalNumber) $analysisNumber
	set MapAnalysisToTerminal($analysisNumber) $terminalNumber

	if {$highest > 0} {
		$twm clone analysis:$highest $uid
	} else {
		$twm new frame analysis:1 $PaneOptions(analysis)
	}
}


proc resizePaneHeight {analysisNumber minHeight} {
	variable MapAnalysisToTerminal
	variable Vars

	set twm $Vars(board:twm)
	set uid analysis:$MapAnalysisToTerminal($analysisNumber)
	set pane [$twm leaf $uid]

	lassign [$twm dimension $pane] _ height _ _ _ _
	set height [expr {max($height,$minHeight)}]

	if {[$twm isfloat [$twm toplevel $pane]]} {
		set height $minHeight
		set maxHeight $minHeight
	} else {
		set maxHeight 0
	}
	$twm resize $pane 0 $height 0 $minHeight 0 $maxHeight
}


proc mapToTerminalNumber {analysisNumber} {
	variable MapAnalysisToTerminal

	if {![info exists MapAnalysisToTerminal($analysisNumber)]} { return -1 }
	return $MapAnalysisToTerminal($analysisNumber)
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
	variable twm::Options
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
			-topmost yes \
			-embed [namespace code [list EmbedUnsavedFiles $unsavedFiles]] \
		]
		if {$reply ne "yes"} { return }
	}

	if {![twm::saveLayouts]} { return }

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
	pack [tk::frame $dlg.f -borderwidth 2 -relief raised]
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
		::options::startTransaction
		::options::saveOptionsFile
		twm::saveTableOptions
		::options::endTransaction
		::load::write
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
	set size [expr {abs($font(-size)) + 4}]

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
	set width [expr {$x1 - $x0 + $margins + 10}]
	set height [expr {$y1 - $y0 + $margins}]
	$w configure -width $width -height $height
	$w.t configure -width $width ;# prevent endless loop in Tk lib (Tk bug)
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


proc MouseLeave {w nodes} {
	foreach node $nodes {
		set id [$node attribute -default {} id]
		if {[llength $id]} { return [::tooltip::hide] }
	}
}


proc PlaceMenues {} {
	variable Vars

	set height [expr {[::theme::notebookTabPaneSize $Vars(notebook)] - 2}]

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
	$m configure -height $height
	place $m -x $x -y 0

	# place update menu
	set m $Vars(menu:updates)
	if {[winfo exists $m]} {
		$m configure -height $height
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
		exit
	}
}


proc Startup {main args} {
	variable Vars

	if {$Vars(ready)} { return }

	lassign $args width height
	set app .application
	set nb $app.nb

	information::build $Vars(frame:information) $width $height
	database::build $Vars(frame:database) $width $height

	$nb add $Vars(frame:information) -sticky nsew
	$nb add $Vars(frame:database) -sticky nsew
	$nb add $main -sticky nsew

	::widget::notebookTextvarHook $nb $Vars(frame:information) [namespace current]::mc::Tab(information)
	::widget::notebookTextvarHook $nb $Vars(frame:database) [namespace current]::mc::Tab(database)
	::widget::notebookTextvarHook $nb $main [namespace current]::mc::Tab(board)

	foreach tab {information database board} {
		bind $Vars(frame:$tab) <FocusIn>  [namespace code [list ${tab}::setActive yes]]
		bind $Vars(frame:$tab) <FocusOut> [namespace code [list ${tab}::setActive no]]
	}

	foreach pane {information database} {
		set frame $Vars(frame:$pane)
		bind $frame <Map> [list [namespace current]::${pane}::activate $frame 1]
		bind $frame <Unmap> [list [namespace current]::${pane}::activate $frame 0]
	}

	::util::place $app -position center
	wm deiconify $app
	database::finish $app
	::splash::close
	set Vars(ready) 1

	# we need a small timeout for HTML widget (tab "Information");
	# for any reason "update idletasks" is not sufficient
	after 1 [namespace code Startup2]
}


proc Startup2 {} {
	set app .application
	set nb $app.nb

	ChooseLanguage $app
	::load::writeLog
	update idletasks
	set ::scidb::intern::blocked 0

	database::preOpen $app

	foreach file [::process::arguments] {
		set path [::util::databasePath $file]
		if {![::scidb::db::get open? $path]} {
			database::openBase .application $path yes -encoding $::encoding::autoEncoding
		}
	}
 
	if {[::game::recover $app] + [::game::reopenLockedGames $app] > 0} {
		set tab board
	} elseif {[::process::testOption show-board]} {
		set tab board
	} elseif {[::process::testOption re-open] || [llength [::process::arguments]]} {
		set tab database
	} else {
		set tab information
	}
	$nb select .application.nb.$tab

	after idle [namespace code [list switchTab $tab]]
	after idle { ::tips::show .application }
	#after idle [list ::beta::welcomeToScidb $app]
	#::util::photos::checkForUpdate [namespace current]::InformAboutUpdates
}


proc FontSizeChanged {w value} {
	variable Vars

	if {$w eq ".application"} {
		$Vars(board:twm) headerfontsize [::html::incrFontSize [$Vars(board:twm) headerfontsize] $value]
	}
}


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
	variable ::application::Vars

	if {$Vars(menu:main) eq $menu} {
		set rx [winfo rootx .application]
		set mw [winfo reqwidth $menu]
		set x [expr {min($rx + [winfo width .application] - $mw, $x)}]
	}

	::tk::_PostOverPoint_application $menu $x $y $entry
}

# vi:set ts=3 sw=3:
