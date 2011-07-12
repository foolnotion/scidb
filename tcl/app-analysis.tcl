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
# Copyright: (C) 2010-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval application {
namespace eval analysis {
namespace eval mc {

set Move						"Move"
set Depth					"Depth"
set Time						"Time"

set Control					"Control"
set Pause					"Pause"
set Lock						"Lock"
set MultipleVariations	"Multiple Variations"
set Lines					"Lines:"

set LinesPerVariation	"Lines per variation"
set Engine					"Engine"

} ;# analysis mc

array set Options {
	background			#ffffee
	info:background	#f5f5e4
	info:foreground	darkgreen
	font					TkTextFont
	engine:nlines		2
	engine:multipv		1
	engine:current		Fruit
}

variable Vars


proc build {parent menu width height} {
	variable Options
	variable Vars

	set engines [::engine::engines]
	if {[lsearch -index 0 $engines $Options(engine:current)] == -1} {
		if {[llength $engines] == 0} {
			set Options(engine:current) ""
		} else {
			set Options(engine:current) [lindex $Options(engine:current) 0]
		}
	}

	array set fopt [font configure $Options(font)]
	set Vars(font:bold) [list $fopt(-family) $fopt(-size) bold]
	set Vars(font:figurine) [list $::font::defaultFigurineFont $fopt(-size)]
	set Vars(charwidth) [font measure $Options(font) "0"]
	set Vars(minsize) [expr {11*$Vars(charwidth)}]
	set Vars(linespace) [font metrics $Options(font) -linespace]
	set Vars(engine:pause) 0
	set Vars(engine:lock) 0

	set w [ttk::frame $parent.f]

	set info [tk::frame $w.info -background $Options(background) -borderwidth 0]

	set move  [tk::frame $info.move -background $Options(info:background) -borderwidth 1 -relief raised]
	set lmove [tk::label $info.move.l \
					-font $Vars(font:bold) \
					-background $Options(info:background) \
					-borderwidth 0 \
					]
	set tmove [tk::text $info.move.t \
						-background $Options(info:background) \
						-borderwidth 0 \
						-foreground $Options(info:background) \
						-state disabled \
						-width 0 \
						-height 1 \
						-cursor {} \
					]
	$tmove tag configure figurine -font $Vars(font:figurine)

	set dpth  [tk::frame $info.dpth -background $Options(info:background) -borderwidth 1 -relief raised]
	set ldpth [tk::label $info.dpth.l \
					-font $Vars(font:bold) \
					-background $Options(info:background) \
					-borderwidth 0 \
					]
	set tdpth [tk::label $info.dpth.t \
						-background $Options(info:background) \
						-borderwidth 0 \
						-foreground $Options(info:background) \
						-width 0 \
					]

	set time  [tk::frame $info.time -background $Options(info:background) -borderwidth 1 -relief raised]
	set ltime [tk::label $info.time.l \
					-font $Vars(font:bold) \
					-background $Options(info:background) \
					-borderwidth 0 \
					]
	set ttime [tk::label $info.time.t \
						-background $Options(info:background) \
						-borderwidth 0 \
						-foreground $Options(info:background) \
						-width 0 \
					]

	set col 1
	foreach type {move dpth time} {
		grid [set $type] -column $col -row 0 -sticky ew -pady 2
		grid columnconfigure [set $type] 0 -weight 1
		grid [set l$type] -column 0 -row 0 -padx 2 -sticky w
		grid [set t$type] -column 0 -row 1 -padx 2 -sticky w
		incr col 2
	}
	grid $tmove -column 0 -row 1 -padx 2 -sticky ew
	grid columnconfigure $move 0 -minsize $Vars(minsize)
	grid columnconfigure $dpth 0 -minsize $Vars(minsize)
	grid columnconfigure $time 0 -minsize $Vars(minsize)

#	if {$Options(engine:multipv)} {
#		set pvcount 4
#		set nlines $Options(engine:nlines)
#	} else {
#		set pvcount 1
#		set nlines 4
#	}
#	set theight [expr {$nlines*$pvcount*$Vars(linespace) + $pvcount*4}]
#	set lheight [expr {$nlines*$Vars(linespace)}]

	set tree $w.tree
	treectrl $tree \
		-takefocus 0 \
		-highlightthickness 0 \
		-borderwidth 1 \
		-relief sunken \
		-showheader no \
		-selectmode single \
		-showroot no \
		-showlines no \
		-showrootlines no \
		-background $Options(background) \
		-font $Options(font) \
		;

	$tree element create elemRect rect -open nw -outline gray -outlinewidth 1
	$tree element create elemText text -lines $Options(engine:nlines) -wrap word

	$tree style create style
	$tree style elements style {elemRect elemText}
	$tree style layout style elemRect -detach yes -iexpand xy
	$tree style layout style elemText -padx {4 4} -pady {2 2} -squeeze x -sticky ne

	$tree column create -steady yes -tags Value -width [expr {7*$Vars(charwidth)}] -itemjustify right
	$tree column create -steady yes -tags Moves -expand yes -squeeze yes -weight 1 -itemjustify left

	foreach i {1 2 3 4} {
		set item [$tree item create]
		$tree item lastchild root $item
		$tree item configure $item -tag Line$i
		$tree item style set $item Value style Moves style
	}

	grid $info -column 0 -row 0 -sticky ew
	grid $tree -column 0 -row 1 -sticky ew

	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $info {1 3 5} -weight 1
	grid columnconfigure $info {0 2 4 6} -minsize 2

	$lmove configure -text "$mc::Move: "
	$ldpth configure -text "$mc::Depth: "
	$ltime configure -text "$mc::Time: "

	pack $w -fill both -expand yes

	set Vars(tree) $tree
	set Vars(move) $info.move.t
	set Vars(depth) $info.dpth.t
	set Vars(time) $info.time.t

	set tbControl [::toolbar::toolbar $parent \
		-id control \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control \
		]
	set tbSwitcher [::toolbar::toolbar $parent \
		-id switch \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Switcher \
		]
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarPause \
		-variable [namespace current]::Vars(engine:pause) \
		-tooltipvar [namespace current]::mc::Pause \
		-command [namespace code [list Pause $tree]] \
		;
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLock \
		-variable [namespace current]::Vars(engine:lock) \
		-tooltipvar [namespace current]::mc::Lock \
		-command [namespace code [list Lock $tree]] \
		;
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLines \
		-variable [namespace current]::Options(engine:multipv) \
		-tooltipvar [namespace current]::mc::MultipleVariations \
		-command [namespace code [list MultipleVariations $tree]] \
		;
	::toolbar::addSeparator $tbControl
	::toolbar::add $tbControl label -textvar [namespace current]::mc::Lines
	set lpv [::toolbar::add $tbControl ::ttk::spinbox \
					-tooltipvar [namespace current]::mc::LinesPerVariation \
					-from 1 \
					-to 4 \
					-width 1 \
					-state readonly \
					-cursor {} \
					-takefocus 0 \
					-textvar [namespace current]::Options(engine:nlines) \
					-exportselection no \
					-command [namespace code [list LinesPerPV $tree]] \
				]
	::toolbar::addSeparator $tbControl
	if {[llength [::engine::engines]] == 0} { set state disabled } else { set state readonly }
	set switcher [::toolbar::add $tbSwitcher ::ttk::tcombobox \
		-exportselection no \
		-state $state \
		-width 15 \
		-textvariable [namespace current]::Options(engine:current) \
		-tooltipvar [namespace current]::mc::Engine \
		-showcolumns {name} \
		]
	$switcher addcol text -id name
	$switcher configure -postcommand [namespace code [list FillSwitcher $switcher]]
	::theme::configureSpinbox $lpv
	set Vars(widget:linesPerPV) $lpv
	$lpv set $Options(engine:nlines)
	Layout $tree
}


proc activate {w menu flag} {
	::toolbar::activate $w $flag
}


proc Pause {tree} {
	variable Vars

	set Vars(engine:pause) [expr {!$Vars(engine:pause)}]
	# TODO
}


proc Lock {tree} {
	variable Vars

	set Vars(engine:lock) [expr {!$Vars(engine:lock)}]
	# TODO
}


proc MultipleVariations {tree} {
	variable Options
	variable Vars

	set Options(engine:multipv) [expr {!$Options(engine:multipv)}]
	Layout $tree
}


proc LinesPerPV {tree} {
	variable Vars
	variable Options

	set Options(engine:nlines) [$Vars(widget:linesPerPV) get]
	Layout $tree
}


proc Layout {tree} {
	variable Options
	variable Vars

	if {$Options(engine:multipv)} {
		set pvcount 4
		set visible 1
		set nlines $Options(engine:nlines)
		set state readonly
	} else {
		set pvcount 1
		set visible 0
		set nlines 4
		set state disabled
	}

	foreach i {2 3 4} {
		$tree item configure $i -visible $visible
	}

	set theight [expr {$nlines*$pvcount*$Vars(linespace) + $pvcount*4}]
	set lheight [expr {$nlines*$Vars(linespace)}]
	$tree configure -height $theight
#	$tree style layout style elemText -padx {4 4} -pady {2 2} -squeeze x -sticky ne -minheight $lheight
	$tree style layout style elemText -minheight $lheight
	::toolbar::childconfigure $Vars(widget:linesPerPV) -state $state
}


proc DisplayLines {move depth time vars} {
	variable Vars
	variable Options

	$Vars(move) configure -state normal
	$Vars(move) delete 1.0 end
	$Vars(move) insert end $move figurine
	$Vars(move) configure -state disabled

	$Vars(depth) configure -text $depth
	$Vars(time) configure -text $time)

	if {$Options(engine:multipv)} { set lines {1 2 3 4} } else { set lines 1 }

	foreach i $lines {
		lassign [lindex $vars [expr {$i - 1}]] value line
		$Vars(tree) item element configure Line$i Value elemText -text $value
		$Vars(tree) item element configure Line$i Moves elemText -font2 $Vars(font:figurine) -text $line
	}
}


proc FillSwitcher {w} {
	set w [::toolbar::realpath $w]
	$w clear

	set list [::engine::engines]

	foreach name $list {
		$w listinsert [list $name]
	}

	$w resize
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace analysis
} ;# namespace application

# vi:set ts=3 sw=3:
