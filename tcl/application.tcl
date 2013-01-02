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

::util::source application

namespace eval application {
namespace eval mc {

set Database				"&Database"
set Board					"&Board"
set MainMenu				"&Main Menu"

set DockWindow				"Dock Window"
set UndockWindow			"Undock Window"
set ChessInfoDatabase	"Chess Information Data Base"
set Shutdown				"Shutdown..."
set QuitAnyway				"Quit anyway?"

set UpdatesAvailable		"Updates available"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::max

array set Attr {
	top,width				900
	top,height				520
	top,minWidth			400
	top,minHeight			300
	top,stretch				always
	top,float				0
	top,before				{}
	top,after				{}
	top,type					panedwindow

	board,width				580
	board,height			520
	board,minWidth			200
	board,minHeight		200
	board,stretch			always
	board,float				0
	board,before			{}
	board,after				{}
	board,type				frame

	right,width				320
	right,height			520
	right,minWidth			280
	right,minHeight		200
	right,stretch			never
	right,float				0
	right,before			{}
	right,after				board
	right,type				frame

	pgn,width				320
	pgn,height				350
	pgn,minWidth			200
	pgn,minHeight			200
	pgn,stretch				always
	pgn,float				1
	pgn,before				{}
	pgn,after				{}
	pgn,type					frame

	bottom,width			900
	bottom,height			200
	bottom,minWidth		400
	bottom,minHeight		150
	bottom,stretch			never
	bottom,float			0
	bottom,before			{}
	bottom,after			top
	bottom,type				panedwindow

	tree,width				400
	tree,height				200
	tree,minWidth			200
	tree,minHeight			150
	tree,stretch			never
	tree,float				1
	tree,before				{}
	tree,after				{}
	tree,type				frame

	games,width				450
	games,height			200
	games,minWidth			200
	games,minHeight		150
	games,stretch			always
	games,float				1
	games,before			{}
	games,after				tree
	games,type				frame

	analysis,width			320
	analysis,height		300
	analysis,minWidth		280
	analysis,minHeight	200
	analysis,stretch		never
	analysis,float			1
	analysis,before		{}
	analysis,after			pgn
	analysis,type			frame
}

array set Vars {
	tabs:changed 0

	menu:locked					0
	menu:state					normal
	menu:background			#c3c3c3
	menu:activebackground	{}

	updates {}
}


proc open {} {
	variable Attr
	variable Vars

	# setup
	::move::setup
	set app .application
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

	set m ".__m__[clock milliseconds]"
	menu $m
	set Vars(menu:activebackground) [$m cget -activebackground]
	destroy $m
	set m [tk::menubutton $nb.menu_main \
		-borderwidth 1 \
		-relief raised \
		-padx 2 \
		-pady 2 \
		-background $Vars(menu:background) \
		-activebackground $Vars(menu:activebackground) \
		-foreground black \
		-activeforeground white \
		-image $icon::16x12::downArrow(black) \
		-compound right \
	]
	SetSettingsText $m
	bind $m <<LanguageChanged>> [namespace code [list SetSettingsText $m]]
	bind $m <Enter> [namespace code [list EnterSettings $m]]
	bind $m <Leave> [namespace code [list LeaveSettings $m]]
	bind $m <<MenuWillPost>> [namespace code [list BuildSettingsMenu $m]]
	bind $m <<MenuWillUnpost>> [namespace code [list FinishSettings $m]]
	bind $m <Configure> [namespace code PlaceMenues]
	set Vars(menu:main) $m
	set Vars(menu:updates) $nb.menu_updates

	::ttk::notebook::enableTraversal $nb
	set db [::ttk::frame $nb.database]
	set main [tk::panedwindow $nb.main -orient vertical -opaqueresize true]
	$nb add $db -sticky nsew
	$nb add $main -sticky nsew
	::widget::notebookTextvarHook $nb $db [namespace current]::mc::Database
	::widget::notebookTextvarHook $nb $main [namespace current]::mc::Board

	bind $main <Configure> [namespace code [list ConfigureEvent main $main %W %w %h]]
#	bind $app <Tab> [namespace code [list SwitchTab $nb +1]]
#	bind $app <Shift-Tab> [namespace code [list SwitchTab $nb -1]]
#	bind $app <ISO_Left_Tab> [namespace code [list SwitchTab $nb -1]]
	pack $nb -fill both -expand yes

	foreach {sub} {top bottom} {
		set $sub [tk::panedwindow $main.$sub -orient horizontal -opaqueresize true]
		$main paneconfigure $main.$sub \
			-sticky nswe \
			-minsize $Attr($sub,minHeight) \
			-stretch $Attr($sub,stretch) \
			;
		bind $main.$sub <Configure> [namespace code [list ConfigureEvent $sub $main.$sub %W %w %h]]
		$main add $main.$sub
	}

	foreach {sub class} {board Board right Frame} {
		set $sub [tk::frame $top.$sub \
						-class $class \
						-width $Attr($sub,width) \
						-height $Attr($sub,height)]
		$top paneconfigure $top.$sub \
			-sticky nswe \
			-minsize $Attr($sub,minWidth) \
			-stretch $Attr($sub,stretch) \
			;
		bind $top.$sub <Configure> [namespace code [list ConfigureEvent $sub $top.$sub %W %w %h]]
		$top add $top.$sub

#		if {$Attr($sub,float)} {
#			set m [menu $top.$sub.popup -tearoff false]
#			$m add command -command [namespace code [list Undock $top.$sub $sub]]
#			::widget::menuTextvarHook $m 0 [namespace current]::mc::UndockWindow
#			bind $top.$sub <ButtonPress-3> [list tk_popup $m %X %Y 0]
#		}
	}

#	set right [tk::panedwindow $right.pw -orient vertical -opaqueresize true]
#	pack $right -fill both -expand yes

#	foreach {sub class} {pgn Frame analysis Frame} {
#		set $sub [tk::frame $right.$sub \
#						-class $class \
#						-width $Attr($sub,width) \
#						-height $Attr($sub,height)]
#		pack [set $sub] -side top -fill both -expand yes
#
#		if {$Attr($sub,float)} {
#			set m [menu $right.$sub.popup -tearoff false]
#			$m add command -command [namespace code [list Undock $right.$sub $sub]]
#			::widget::menuTextvarHook $m 0 [namespace current]::mc::UndockWindow
#			bind $right.$sub <ButtonPress-3> [list tk_popup $m %X %Y 0]
#		}
#	}

	set pgn [tk::frame $right.pgn -class Frame -width $Attr(pgn,width)]

if {[::process::testOption use-analysis]} {
	set analysis [tk::frame $right.analysis -class Frame -width $Attr(analysis,width)]
}

	grid $pgn -row 0 -column 0 -sticky nsew
if {[::process::testOption use-analysis]} {
	grid [::ttk::separator $right.sep -orient horizontal] -row 1 -column 0 -sticky ew
	grid $analysis -row 2 -column 0 -sticky nsew
}
	grid rowconfigure $right 0 -weight 1
	grid columnconfigure $right 0 -weight 1

	foreach {sub class} {tree Frame games Frame} {
		set $sub [tk::frame $bottom.$sub \
						-class $class \
						-width $Attr($sub,width) \
						-height $Attr($sub,height)]
		$bottom paneconfigure $bottom.$sub \
			-sticky nswe \
			-minsize $Attr($sub,minWidth) \
			-stretch $Attr($sub,stretch) \
			;
		if {$sub eq "tree"} { $bottom paneconfigure $bottom.$sub -width 400 }
		bind $bottom.$sub <Configure> [namespace code [list ConfigureEvent $sub $bottom.$sub %W %w %h]]
		$bottom add $bottom.$sub

#		if {$Attr($sub,float)} {
#			set m [menu $bottom.$sub.popup -tearoff false]
#			$m add command -command [namespace code [list Undock $bottom.$sub $sub]]
#			::widget::menuTextvarHook $m 0 [namespace current]::mc::UndockWindow
#			bind $bottom.$sub <ButtonPress-3> [list tk_popup $m %X %Y 0]
#		}
	}

	database::build $db $Attr(board,width) $Attr(board,height)
	board::build $top.board $Attr(board,width) $Attr(board,height)
	pgn::build $right.pgn $Attr(pgn,width) $Attr(pgn,height)
	tree::build $bottom.tree $Attr(tree,width) $Attr(tree,height) $bottom.games
	tree::games::build $bottom.games $Attr(games,width) $Attr(games,height)
if {[::process::testOption use-analysis]} {
	analysis::build $right.analysis $Attr(analysis,width) $Attr(analysis,height)
}
#[winfo parent $bottom] forget $bottom

	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb $app]]
	bind $app <Destroy> [namespace code { Exit %W }]
	ComputeMinSize $main
	::util::place $app center .
	::widget::dialogSetTitle $app [namespace code Title]
	wm deiconify $app
	database::finish $app
	::splash::close
	ChooseLanguage $app
	focus $nb
	TabChanged $nb $app
	::load::writeLog
	update idletasks
	set ::remote::blocked 0

	database::preOpen $app

	foreach file [::process::arguments] {
		database::openBase .application [::util::databasePath $file] yes \
			-encoding $::encoding::autoEncoding
	}

	::game::recover

	if {[::process::testOption show-board]} {
		after idle [namespace code [list switchTab board]]
	}

	after idle [list ::beta::welcomeToScidb $app]
	::util::photos::checkForUpdate [namespace current]::InformAboutUpdates
}


proc shutdown {} {
	variable icon::32x32::shutdown
	variable Vars

	set dlg .application.shutdown
	if {[winfo exists $dlg]} { return }

	if {[::dialog::messagebox::open?] eq "question"} { bell; return }
	if {[llength [grab current]]} { bell; return }

	if {[::util::photos::busy?]} {
		append msg $::util::photos::mc::DownloadStillInProgress "\n\n"
		append msg $mc::QuitAnyway
		set reply [::dialog::question -parent .application -message $msg -default no]
		if {$reply ne "yes"} { return }
		::util::photos::terminateUpdate
	}

	switch [::game::queryCloseApplication .application] {
		restore	{ set backup 1 }
		discard	{ set backup 0 }
		cancel	{ return }
	}

	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	pack [tk::frame $dlg.f -border 2 -relief raised]
	pack [tk::label $dlg.f.text -compound left -image $shutdown -text " $mc::Shutdown"] -padx 10 -pady 10
	wm resizable $dlg no no
	wm transient $dlg .application
	::util::place $dlg center .application
	update idletasks
	::scidb::tk::wm frameless $dlg
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	::widget::busyCursor on

	::remote::cleanup
	database::prepareClose
	::scidb::app::close
	if {$backup} { ::game::backup }
	::scidb::app::finalize

	::widget::busyCursor off
	::ttk::releaseGrab $dlg
	destroy .application
}


proc switchTab {which} {
	switch $which {
		database	{ set tab .application.nb.database }
		board		{ set tab .application.nb.main }
	}
	.application.nb select $tab
	update idletasks
	${which}::setFocus
}


proc InformAboutUpdates {item} {
	variable Vars

	lappend Vars(updates) $item
	BuildUpdatesButton
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


proc FinishSettings {m} {
	variable Vars

	$m configure \
		-background $Vars(menu:background) \
		-activebackground $Vars(menu:activebackground) \
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
	variable Vars

	set m $Vars(menu:updates)
	if {[winfo exists $m]} { return }

	tk::menubutton $m \
		-borderwidth 1 \
		-relief raised \
		-padx 2 \
		-pady 2 \
		-background $Vars(menu:background) \
		-activebackground $Vars(menu:activebackground) \
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
		-background $Vars(menu:activebackground) \
		-activebackground $Vars(menu:activebackground) \
		-foreground white \
		-activeforeground white \
		-menu $m.updates \
		-direction below \
		;
	set Vars(menu:locked) 1
}


proc FinishUpdates {m} {
	variable Vars

	$m configure \
		-background $Vars(menu:background) \
		-activebackground $Vars(menu:activebackground) \
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


proc SetSettingsText {w} {
	variable Vars

	lassign [::tk::UnderlineAmpersand $mc::MainMenu] text ul
	$w configure -text " $text" -underline [incr ul]
}


proc BuildSettingsMenu {m} {
	variable Vars

	catch { destroy $m.entries }
	::menu $m.entries
	::menu::build $m.entries

	$m configure \
		-background $Vars(menu:activebackground) \
		-activebackground $Vars(menu:activebackground) \
		-foreground white \
		-activeforeground white \
		-image $icon::16x12::downArrow(white) \
		-menu $m.entries \
		-direction below \
		;
	set Vars(menu:locked) 1
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
	::util::place $dlg center $parent
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


proc TabChanged {nb app} {
	variable Vars

	set current [lindex [split [$nb select] .] end]

	switch $current {
		database	{
			database::activate $nb.database 1
			board::activate $nb.main.top.board 0
			tree::activate $nb.main.bottom.tree 0
#			analysis::activate $nb.main.top.right.analysis 0
		}

		main {
			database::activate $nb.database 0
			board::activate $nb.main.top.board 1
			tree::activate $nb.main.bottom.tree 1
#			analysis::activate $nb.main.top.right.analysis 1
		}
	}

	if {$Vars(tabs:changed) > 0} {
		# avoid resizing (multicolumn problem)
		wm geometry $app [wm geometry $app]
	}
	incr Vars(tabs:changed)
}


proc SwitchTab {nb dir} {
	set index [expr {[$nb index [$nb select]] + $dir}]
	set num [llength [$nb tabs]]
	if {$index == -1} { set index [expr {$num - 1}] }
	if {$index == $num} { set index 0 }
	$nb select $index
}


proc ComputeMinSize {main} {
	variable Attr

	set sash [$main cget -sashwidth]
	if {[$main cget -showhandle]} { set sash [max $sash [$main cget -handlesize]] }
	set sash [expr {$sash + 2*[$main cget -sashpad]}]
	set minW [expr {2*[$main cget -borderwidth] - ([llength [$main panes]] > 1 ? $sash : 0)}]
	set minH 0

	foreach sub [$main panes] {
		set which [lindex [split $sub "."] end]
		set minH [max $minH $Attr($which,minHeight)]
		incr minW $Attr($which,minWidth)
		incr minW $sash
	}

	wm minsize [winfo toplevel $main] $minW $minH
}


proc ConfigureEvent {name pane w width height} {
	variable Attr

	if {$pane ne $w || $width <= 1} { return }

	set Attr($name,width) $width
	set Attr($name,height) $height
}


proc Undock {w name} {
	variable Attr

	set x [winfo rootx $w]
	set y [winfo rooty $w]
	set main [winfo parent $w]
	$main forget $w
	$w.popup delete 0
	$w.popup add command -command [namespace code [list Dock $w $name]]
	::widget::menuTextvarHook $w.popup 0 [namespace current]::mc::DockWindow
	$w configure -width $Attr($name,width) -height $Attr($name,height)
	wm manage $w ;# -iconic
	::util::place $w at $x [expr {$y - 22}]
	wm protocol $w WM_DELETE_WINDOW [namespace code [list Dock $w $name]]
#	wm iconphoto $w -default $::icon::64x64::logo $::icon::16x16::logo
	ComputeMinSize $main
}


proc Dock {w name} {
	variable Attr

	set main [winfo parent $w]
	wm forget $w
	$main add $w -minsize $Attr($name,minWidth) -stretch $Attr($name,stretch)
	$w.popup delete 0
	$w.popup add command \
		-label [::mc::translate [namespace current]::mc::UndockWindow] \
		-command [namespace code [list Undock $w $name]]

	if {[llength $Attr($name,before)]} { $main paneconfigure $w -before $main.$Attr($name,before) }
	if {[llength $Attr($name,after)]} { $main paneconfigure $w -after $main.$Attr($name,after) }

	ComputeMinSize $main
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
	if {[string match ".application.nb.menu_*.entries" $menu]} {
		set rx [winfo rootx .application]
		set mw [winfo reqwidth $menu]
		set x [expr {min($rx + [winfo width .application] - $mw, $x)}]
	}

	::tk::_PostOverPoint_application $menu $x $y $entry
}

# vi:set ts=3 sw=3:
