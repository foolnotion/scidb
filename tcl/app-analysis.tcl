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
# Copyright: (C) 2010-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source analysis-pane

namespace eval application {
namespace eval analysis {
namespace eval mc {

set Move						"Move"
set Depth					"Depth"
set Time						"Time"

set Control					"Control"
set Switcher				"Switcher"
set Pause					"Pause"
set Resume					"Resume"
set LockPosition			"Lock current position"
set MultipleVariations	"Multiple Variations"
set Lines					"Lines:"

set LinesPerVariation	"Lines per variation"
set Engine					"Engine"

set Signal(stopped)		"Engine stopped by signal."
set Signal(resumed)		"Engine resumed by signal."
set Signal(killed)		"Engine killed by signal."
set Signal(crashed)		"Engine crashed."
set Signal(closed)		"Engine has closed connection."
set Signal(terminated)	"Engine terminated with exit code %s."

} ;# analysis mc

array set Options {
	background			#ffffee
	info:background	#f5f5e4
	info:foreground	darkgreen
	font					TkTextFont
	engine:current		Stockfish
	engine:nlines		2
}

array set EngineOptions {
	multipv	true
	hash		0
}

array set Vars {
	engine:id		-1
	engine:locked	0
	engine:pause	0
}


proc build {parent width height} {
	variable EngineOptions
	variable Options
	variable Vars

	set engines [::engine::engines]
	if {[lsearch -exact -index 0 $engines $Options(engine:current)] == -1} {
		if {[llength $engines] == 0} {
			set Options(engine:current) ""
		} else {
			set Options(engine:current) [lindex $engines 0]
		}
	}

	array set fopt [font configure $Options(font)]
	set Vars(font:bold) [list $fopt(-family) $fopt(-size) bold]
	set Vars(font:figurine) $::font::figurine(text:normal)
	set Vars(charwidth) [font measure $Options(font) "0"]
	set Vars(minsize) [expr {11*$Vars(charwidth)}]
	set Vars(linespace) [font metrics $Options(font) -linespace]

	set w [ttk::frame $parent.f]

	set info [tk::frame $w.info \
		-background $Options(background) \
		-borderwidth 0 \
	]

	set score [tk::frame $info.score \
		-background $Options(info:background) \
		-borderwidth 1 \
		-relief raised \
	]
	set tscore [tk::text $info.score.t \
		-background $Options(info:background) \
		-foreground $Options(info:foreground) \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
	]
	$tscore tag configure center -justify center
	pack $tscore -padx 2 -pady 2

	set move [tk::frame $info.move \
		-background $Options(info:background) \
		-borderwidth 1 \
		-relief raised \
	]
	set tmove [tk::text $info.move.t \
		-background $Options(info:background) \
		-foreground $Options(info:foreground) \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
	]
	$tmove tag configure figurine -font $Vars(font:figurine)
	$tmove tag configure center -justify center
	pack $tmove -padx 2 -pady 2

	set depth  [tk::frame $info.depth -background $Options(info:background) -borderwidth 1 -relief raised]
	set tdepth [tk::label $info.depth.t \
		-background $Options(info:background) \
		-foreground $Options(info:foreground) \
		-borderwidth 0 \
		-width 0 \
	]
	pack $tdepth -padx 2 -pady 2

	set col 1
	foreach type {score move depth} {
		grid [set $type] -column $col -row 0 -sticky ew -pady 2
		grid columnconfigure [set $type] 0 -weight 1
		grid [set t$type] -column 0 -row 1 -padx 2 -sticky ew
		incr col 2
	}

	grid columnconfigure $score 0 -minsize $Vars(minsize)
	grid columnconfigure $move  0 -minsize $Vars(minsize)
	grid columnconfigure $depth 0 -minsize $Vars(minsize)

	set tree $w.tree
	treectrl $tree \
		-takefocus 0 \
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
	$tree element create elemText text -lines $Options(engine:nlines) \
		-wrap word -font2 $Vars(font:figurine)

	$tree style create style
	$tree style elements style {elemRect elemText}
	$tree style layout style elemRect -detach yes -iexpand xy
	$tree style layout style elemText -padx {4 4} -pady {2 2} -squeeze x -sticky ne

	$tree column create -steady yes -tags Value -width [expr {10*$Vars(charwidth)}] -itemjustify right
	$tree column create -steady yes -tags Moves -expand yes -squeeze yes -weight 1 -itemjustify left

	foreach i {0 1 2 3} {
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

	pack $w -fill both -expand yes
	bind $tmove <Destroy> [namespace code Destroy]

	set Vars(tree) $tree
	set Vars(score) $info.score.t
	set Vars(move) $info.move.t
	set Vars(depth) $info.depth.t

	set tbControl [::toolbar::toolbar $parent \
		-id analysis-control \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control \
		]
	set tbSwitcher [::toolbar::toolbar $parent \
		-id analysis-switch \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Switcher \
		]
	set Vars(button:pause) [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarPause \
		-variable [namespace current]::Vars(engine:pause) \
		-tooltipvar [namespace current]::mc::Pause \
		-command [namespace code [list Pause $tree]] \
	]
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLock \
		-variable [namespace current]::Vars(engine:locked) \
		-tooltipvar [namespace current]::mc::LockPosition \
		;
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLines \
		-variable [namespace current]::EngineOptions(multipv) \
		-onvalue 4 \
		-offvalue 1 \
		-tooltipvar [namespace current]::mc::MultipleVariations \
		-command [namespace code [list Layout $tree]] \
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


proc update {position} {
	variable Vars
	variable Options

	if {$Vars(engine:id) != -1 && !$Vars(engine:locked)} {
		after idle [list :::engine::startAnalysis $Vars(engine:id)]
	}
}


proc startAnalysis {} {
	variable Vars
	variable Options

	set isReadyCmd [namespace current]::IsReady
	set signalCmd [namespace current]::Signal
	set updateCmd [namespace current]::UpdateInfo
	set name $Options(engine:current)

	if {[string length $name]} {
		set Vars(engine:id) [::engine::startEngine $name $isReadyCmd $signalCmd $updateCmd] 
	}
}


proc stopAnalysis {} {
	variable Vars

	::engine::stopAnalysis $Vars(engine:id)
	set Vars(engine:id) -1
}


proc activate {w flag} {
	::toolbar::activate $w $flag
}


proc Pause {tree} {
	variable Vars

	if {$Vars(engine:pause)} {
		::engine::pause $Vars(engine:id)
		::toolbar::childconfigure $Vars(button:pause) \
			-image $::icon::toolbarResume \
			-tooltipvar [namespace current]::mc::Resume \
			;
	} else {
		::engine::resume $Vars(engine:id)
		::toolbar::childconfigure $Vars(button:pause) \
			-image $::icon::toolbarPause \
			-tooltipvar [namespace current]::mc::Pause \
			;
	}
}


proc LinesPerPV {tree} {
	variable Vars
	variable Options

	set Options(engine:nlines) [$Vars(widget:linesPerPV) get]
	Layout $tree
}


proc Layout {tree} {
	variable EngineOptions
	variable Options
	variable Vars

	if {$EngineOptions(multipv) == 4} {
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

	foreach i {1 2 3} {
		$tree item configure Line$i -visible $visible
	}

	set theight [expr {$nlines*$pvcount*$Vars(linespace) + $pvcount*4}]
	set lheight [expr {$nlines*$Vars(linespace)}]
	$tree configure -height $theight
#	$tree style layout style elemText -padx {4 4} -pady {2 2} -squeeze x -sticky ne -minheight $lheight
	$tree style layout style elemText -minheight $lheight
	::toolbar::childconfigure $Vars(widget:linesPerPV) -state $state

	if {$nlines == 1} {
		set lines 0
		set wrap none
	} else {
		set lines $nlines
		set wrap word
	}
	foreach i {0 1 2 3} {
		$tree item element configure Line$i Moves elemText -lines $lines -wrap $wrap
	}
}


proc DisplayPvLines {score mate depth time nodes vars} {
	variable EngineOptions
	variable Vars
	variable Options

	$Vars(score) configure -state normal
	$Vars(score) delete 1.0 end
	$Vars(score) insert end "(0.$score)" center
	$Vars(score) configure -state disabled

	if {$depth} { $Vars(depth) configure -text $depth }

	if {$EngineOptions(multipv)} { set lines {0 1 2 3} } else { set lines 0 }

	foreach i $lines {
		set line [lindex $vars $i]
		$Vars(tree) item element configure Line$i Value elemText -text [lindex $line 0]
		$Vars(tree) item element configure Line$i Moves elemText -text [lrange $line 1 end]
	}
}


proc DisplayCurrentMove {number move} {
	variable Vars

	$Vars(move) configure -state normal
	$Vars(move) delete 1.0 end
	$Vars(move) insert end $move {figurine center}
	$Vars(move) configure -state disabled
}


proc DisplayTime {time depth nodes} {
	variable Vars
}


proc UpdateInfo {id type info} {
	switch $type {
		pv		{ DisplayPvLines {*}$info }
		move	{ DisplayCurrentMove {*}$info }
		line	{}
		best	{}
		depth	{ DisplayTime 0.0 {*}$info }
		time	{ DisplayTime {*}$info }
		hash	{}
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


proc Destroy {} {
	variable Vars

	::engine::kill $Vars(engine:id)
	set Vars(engine:id) -1
}


proc IsReady {id} {
	after idle [list :::engine::startAnalysis $id]
}


proc Signal {id code} {
	variable Vars

	set parent [winfo toplevel $Vars(tree)]

	if {[string is integer $code]} {
		set msg [format $mc::Signal(terminated) $code]
	} else {
		set msg $mc::Signal($code)
	}

	switch $code {
		stopped - resumed {
			after idle [list ::dialog::info -parent $parent -message $msg]
		}
		default {
			after idle [list ::engine::kill $Vars(engine:id)]
			after idle [list ::dialog::error -parent $parent -message $msg]
		}
	}

	set Vars(engine:id) -1
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace analysis
} ;# namespace application

# vi:set ts=3 sw=3:
