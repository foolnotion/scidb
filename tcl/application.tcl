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

namespace eval application {
namespace eval mc {
	set Database				"&Database"
	set Board					"&Board"

	set DockWindow				"Dock Window"
	set UndockWindow			"Undock Window"
	set ChessInfoDatabase	"Chess Information Data Base"
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

	tree,width				450
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
	tabChanged	0
	fullscreen	0
}


proc open {} {
	global argc
	global argv
	variable Attr

	# setup
	::move::setup

	set app .application
	wm protocol $app WM_DELETE_WINDOW [namespace code quit]
	set nb [::ttk::notebook $app.nb -takefocus 1]
	::ttk::notebook::enableTraversal $nb
	set db [::ttk::frame $nb.database]
	set main [panedwindow $nb.main -orient vertical -opaqueresize true]
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
		set $sub [panedwindow $main.$sub -orient horizontal -opaqueresize true]
		$main paneconfigure $main.$sub \
			-sticky nswe \
			-minsize $Attr($sub,minHeight) \
			-stretch $Attr($sub,stretch) \
			;
		bind $main.$sub <Configure> [namespace code [list ConfigureEvent $sub $main.$sub %W %w %h]]
		$main add $main.$sub
	}

	foreach {sub class} {board Board right Frame} {
		set $sub [frame $top.$sub \
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

#	set right [panedwindow $right.pw -orient vertical -opaqueresize true]
#	pack $right -fill both -expand yes

#	foreach {sub class} {pgn Frame analysis Frame} {
#		set $sub [frame $right.$sub \
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

	set pgn [frame $right.pgn -class Frame -width $Attr(pgn,width)]
#	set analysis [frame $right.analysis -class Frame -width $Attr(analysis,width)]

	grid $pgn -row 0 -column 0 -sticky nsew
#	grid [::ttk::separator $right.sep -orient horizontal] -row 1 -column 0 -sticky ew
#	grid $analysis -row 2 -column 0 -sticky nsew
	grid rowconfigure $right 0 -weight 1
	grid columnconfigure $right 0 -weight 1

	foreach {sub class} {tree Frame games Frame} {
		set $sub [frame $bottom.$sub \
						-class $class \
						-width $Attr($sub,width) \
						-height $Attr($sub,height)]
		$bottom paneconfigure $bottom.$sub \
			-sticky nswe \
			-minsize $Attr($sub,minWidth) \
			-stretch $Attr($sub,stretch) \
			;
		bind $bottom.$sub <Configure> [namespace code [list ConfigureEvent $sub $bottom.$sub %W %w %h]]
		$bottom add $bottom.$sub

#		if {$Attr($sub,float)} {
#			set m [menu $bottom.$sub.popup -tearoff false]
#			$m add command -command [namespace code [list Undock $bottom.$sub $sub]]
#			::widget::menuTextvarHook $m 0 [namespace current]::mc::UndockWindow
#			bind $bottom.$sub <ButtonPress-3> [list tk_popup $m %X %Y 0]
#		}
	}

	database::build $db $app.menu.mSettings $Attr(board,width) $Attr(board,height)
	board::build $top.board $app.menu.mSettings $Attr(board,width) $Attr(board,height)
	pgn::build $right.pgn $app.menu.mSettings $Attr(pgn,width) $Attr(pgn,height)
	tree::build $bottom.tree $app.menu.mSettings $Attr(tree,width) $Attr(tree,height)
	tree::games::build $bottom.games $app.menu.mSettings $Attr(games,width) $Attr(games,height)
#	analysis::build $right.analysis $app.menu.mSettings $Attr(analysis,width) $Attr(analysis,height)

	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb $app]]
	bind $app <Destroy> [namespace code { Exit %W }]
	bind $app <F11> [namespace code [list FullScreen $app]]
	ComputeMinSize $main
	::util::place $app center .
	::widget::dialogSetTitle $app [namespace code Title]
	wm deiconify $app
	::splash::close
	ChooseLanguage $app
	focus $nb
	TabChanged $nb $app
	update

	after idle ::remote::update

	set extensions {.sci .si4 .si3 .cbh .pgn .zip}
	for {set i 0} {$i < $argc} {incr i} {
		set file [lindex $argv $i]
		if {[string index $file 0] ne "-"} {
			set file [::util::databasePath $file]
			set ::remote::blocked 0
			return [::application::database::openBase .application $file]
		}
	}

	set ::remote::blocked 0
}


proc quit {} {
	# TODO
	# check if there are unsaved games
	if {[::remote::pending?]} {
		::remote::update
	} else {
		::widget::busyOperation [namespace current]::database::closeAllBases
		destroy .application
	}
}


proc switchTab {which} {
	switch $which {
		database	{ set which .application.nb.database }
		board		{ set which .application.nb.main }
	}
	.application.nb select $which
}


proc ChooseLanguage {parent} {
	if {!$::scidb::dir::setup} { return }
	set dlg $parent.lang
	toplevel $dlg -class Scidb
	wm withdraw $dlg
	foreach lang [lsort [array names ::mc::input]] {
		if {[string length $lang]} {
			set flag ""
			catch { set flag $::country::icon::flag([set ::mc::langToCountry([set ::mc::lang$lang])]) }
			if {[string length $flag] == 0} { set flag none }
			set code [set ::mc::lang$lang]
			ttk::button $dlg.$code \
				-text $lang \
				-image $flag \
				-compound left \
				-command [list set ::mc::langID $code] \
				;
			pack $dlg.$code -side top -padx $::theme::padx -pady $::theme::pady
		}
	}
	wm title $dlg $::scidb::app
	wm resizable $dlg no no
	wm transient $dlg $parent
	wm protocol $dlg WM_DELETE_WINDOW { set ::mc::langID en }
	::util::place $dlg center $parent
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	vwait ::mc::langID
	::ttk::releaseGrab $dlg
	catch { destroy $dlg }
	::mc::setLang $mc::langID
}


proc FullScreen {app} {
	variable Vars

	set Vars(fullscreen) [expr {!$Vars(fullscreen)}]
	wm attributes $app -fullscreen $Vars(fullscreen)
}


proc Title {} {
	return "$::scidb::app - $mc::ChessInfoDatabase"
}


proc Exit {w} {
	set ::remote::blocking 1
	set ::remote::postponed 0

	if {$w eq ".application"} {
		::options::write
		exit
	}
}


proc TabChanged {nb app} {
	variable Vars

	set current [lindex [split [$nb select] .] end]

	switch $current {
		database	{
			database::activate $nb.database $app.menu.mSettings 1
			board::activate $nb.main.top.board $app.menu.mSettings 0
			tree::activate $nb.main.bottom.tree $app.menu.mSettings 0
#			analysis::activate $nb.main.top.right.analysis $app.menu.mSettings 0
		}

		main {
			database::activate $nb.database $app.menu.mSettings 0
			board::activate $nb.main.top.board $app.menu.mSettings 1
			tree::activate $nb.main.bottom.tree $app.menu.mSettings 1
#			analysis::activate $nb.main.top.right.analysis $app.menu.mSettings 1
		}
	}

	if {$Vars(tabChanged) > 0} {
		# avoid resizing (multicolumn problem)
		wm geometry $app [wm geometry $app]
	}
	incr Vars(tabChanged)
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
	wm iconphoto $w -default $::icon::64x64::logo $::icon::16x16::logo
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

} ;# namespace application

# vi:set ts=3 sw=3:
