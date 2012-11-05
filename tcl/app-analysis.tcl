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

set Control						"Control"
set Information				"Information"
set Setup						"Setup"
set Pause						"Pause"
set Resume						"Resume"
set LockEngine					"Lock engine to current position"
set MultipleVariations		"Multiple variations"
set HashFullness				"Hash fullness"
set Hash							"Hash:"
set Lines						"Lines:"
set MateIn						"%color mate in %n"
set BestScore					"Best score (of current lines)"
set CurrentMove				"Currently searching this move"
set TimeSearched				"Time searched"
set SearchDepth				"Search depth in plies (Selective search depth)"

set LinesPerVariation		"Lines per variation"
set BestFirstOrder			"Use \"best first\" order"
set Engine						"Engine"

set Seconds						"s"
set Minutes						"m"

set NotSupported(standard)	"This engine does not support standard chess."
set NotSupported(chess960)	"This engine does not support chess 960."
set NotSupported(analyze)	"This engine does not have an analysis mode."

set Signal(stopped)			"Engine stopped by signal."
set Signal(resumed)			"Engine resumed by signal."
set Signal(killed)			"Engine killed by signal."
set Signal(crashed)			"Engine crashed."
set Signal(closed)			"Engine has closed connection."
set Signal(terminated)		"Engine terminated with exit code %s."

} ;# analysis mc

namespace import ::tcl::mathfunc::abs

array set Defaults {
	background			#ffffee
	info:background	#f5f5e4
	info:foreground	darkgreen
	best:foreground	darkgreen
}

array set Options {
	font					TkTextFont
	engine:bestFirst	0
	engine:nlines		2
	engine:multiPV		4
}

array set Vars {
	engine:id		-1
	engine:locked	0
	engine:pause	0
}

# from Scid
array set Informant { !? 0.5 ? 1.5 ?? 3.0 ?! 0.5 }

#                 	   =			+=			+/-		+-
variable ScoreToEval {	45 10		75 14		175 16	400 18 }
# Values from Scid:		50			150		300		550
# Values from CB:			35			70			160


proc build {parent width height} {
	variable Options
	variable Defaults
	variable Vars

	set Vars(best:0) black
	if {$Options(engine:bestFirst)} {
		set Vars(best:1) black
	} else {
		set Vars(best:1) $Defaults(best:foreground)
	}
	set Vars(maxMoves) 0
	set Vars(after) {}
	set Vars(state) normal
	array set fopt [font configure $Options(font)]
#	set Vars(font:bold) [list $fopt(-family) $fopt(-size) bold]
	set Vars(linespace) [font metrics $Options(font) -linespace]
	set charwidth [font measure $Options(font) "0"]
	set minsize [expr {11*$charwidth}]

	set w [ttk::frame $parent.f]

	set info [tk::frame $w.info \
		-background $Defaults(background) \
		-borderwidth 0 \
	]

	set score [tk::frame $info.score \
		-background $Defaults(info:background) \
		-borderwidth 1 \
		-relief raised \
	]
	set tscore [tk::text $info.score.t \
		-font $::font::text(text:normal) \
		-background $Defaults(info:background) \
		-foreground $Defaults(info:foreground) \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
	]
	$tscore tag configure center -justify center
	$tscore tag configure symbol -font $::font::symbol(text:normal)
	pack $tscore -padx 2 -pady 2

	set move [tk::frame $info.move \
		-background $Defaults(info:background) \
		-borderwidth 1 \
		-relief raised \
	]
	set tmove [tk::text $info.move.t \
		-font $::font::text(text:normal) \
		-background $Defaults(info:background) \
		-foreground $Defaults(info:foreground) \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
	]
	$tmove tag configure figurine -font $::font::figurine(text:normal)
	$tmove tag configure center -justify center
	pack $tmove -padx 2 -pady 2

	set time [tk::frame $info.time \
		-background $Defaults(info:background) \
		-borderwidth 1 \
		-relief raised \
	]
	set ttime [tk::label $info.time.t \
		-font $::font::text(text:normal) \
		-background $Defaults(info:background) \
		-foreground $Defaults(info:foreground) \
		-borderwidth 0 \
		-width 0 \
	]
	pack $ttime -padx 2 -pady 2

	set depth [tk::frame $info.depth \
		-background $Defaults(info:background) \
		-borderwidth 1 \
		-relief raised \
	]
	set tdepth [tk::label $info.depth.t \
		-font $::font::text(text:normal) \
		-background $Defaults(info:background) \
		-foreground $Defaults(info:foreground) \
		-borderwidth 0 \
		-width 0 \
	]
	pack $tdepth -padx 2 -pady 2

	set col 1
	foreach type {score move time depth} {
		grid [set $type] -column $col -row 0 -sticky ew -pady 2
		grid columnconfigure [set $type] 0 -weight 1
		grid [set t$type] -column 0 -row 1 -padx 2 -sticky ew
		incr col 2
	}

	::tooltip::tooltip $score  [namespace current]::mc::BestScore
	::tooltip::tooltip $tscore [namespace current]::mc::BestScore
	::tooltip::tooltip $move   [namespace current]::mc::CurrentMove
	::tooltip::tooltip $tmove  [namespace current]::mc::CurrentMove
	::tooltip::tooltip $time   [namespace current]::mc::TimeSearched
	::tooltip::tooltip $ttime  [namespace current]::mc::TimeSearched
	::tooltip::tooltip $depth  [namespace current]::mc::SearchDepth
	::tooltip::tooltip $tdepth [namespace current]::mc::SearchDepth

	grid columnconfigure $score 0 -minsize $minsize
	grid columnconfigure $move  0 -minsize $minsize
	grid columnconfigure $time  0 -minsize $minsize
	grid columnconfigure $depth 0 -minsize $minsize

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
		-background $Defaults(background) \
		-font $Options(font) \
		;

	$tree element create elemRect rect -open nw -outline gray -outlinewidth 1
	$tree element create elemTextFig text -lines $Options(engine:nlines) \
		-wrap word -font2 $::font::figurine(text:normal)
	$tree element create elemTextSym text -lines $Options(engine:nlines) \
		-wrap word -font2 $::font::symbol(text:normal)

	$tree style create styleFig
	$tree style elements styleFig {elemRect elemTextFig}
	$tree style layout styleFig elemRect -detach yes -iexpand xy
	$tree style layout styleFig elemTextFig -padx {4 4} -pady {2 2} -squeeze x -sticky ne

	$tree style create styleSym
	$tree style elements styleSym {elemRect elemTextSym}
	$tree style layout styleSym elemRect -detach yes -iexpand xy
	$tree style layout styleSym elemTextSym -padx {4 4} -pady {2 2} -squeeze x -sticky ne

	$tree column create -steady yes -tags Eval  -width [expr {5*$charwidth}] -itemjustify center
	$tree column create -steady yes -tags Value -width [expr {8*$charwidth}] -itemjustify right
	$tree column create -steady yes -tags Moves -expand yes -squeeze yes -weight 1 -itemjustify left

	foreach i {0 1 2 3} {
		set item [$tree item create]
		$tree item lastchild root $item
		$tree item configure $item -tag Line$i
		$tree item style set $item Eval  styleSym
		$tree item style set $item Value styleFig
		$tree item style set $item Moves styleFig
	}

	grid $info -column 0 -row 0 -sticky ew
	grid $tree -column 0 -row 1 -sticky ew

	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $info {1 3 5 7} -weight 1
	grid columnconfigure $info {0 2 4 6} -minsize 2

	pack $w -fill both -expand yes
	bind $tmove <Destroy> [namespace code Destroy]

	set Vars(tree) $tree
	set Vars(score) $info.score.t
	set Vars(move) $info.move.t
	set Vars(time) $info.time.t
	set Vars(depth) $info.depth.t
	set Vars(toolbar:childs) {}

	set tbControl [::toolbar::toolbar $parent \
		-id analysis-control \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control \
	]
	set Vars(button:pause) [::toolbar::add $tbControl button \
		-image $::icon::toolbarPause \
		-tooltipvar [namespace current]::mc::Pause \
		-command [namespace code [list Pause $tree]] \
	]
	lappend Vars(toolbar:childs) $Vars(button:pause)
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLock \
		-variable [namespace current]::Vars(engine:locked) \
		-tooltipvar [namespace current]::mc::LockEngine \
		-command [namespace code EngineLock] \
		;
	set tbw [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLines \
		-variable [namespace current]::Options(engine:multiPV) \
		-onvalue 4 \
		-offvalue 1 \
		-tooltipvar [namespace current]::mc::MultipleVariations \
		-command [namespace code [list SetMultiPV $tree]] \
	]
	lappend Vars(toolbar:childs) $tbw
	set Vars(widget:ordering) [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarSort(descending) \
		-variable [namespace current]::Options(engine:bestFirst) \
		-tooltipvar [namespace current]::mc::BestFirstOrder \
		-command [namespace code [list SetOrdering $tree]] \
	]
	lappend Vars(toolbar:childs) $Vars(widget:ordering)
	::toolbar::add $tbControl button \
		-image $::icon::toolbarSetup \
		-command [namespace code Setup] \
		-tooltipvar [namespace current]::mc::Setup \
		;
	::toolbar::addSeparator $tbControl
	::toolbar::add $tbControl label -textvar [namespace current]::mc::Lines
	set lpv [::toolbar::add $tbControl ::ttk::spinbox \
		-tooltipvar [namespace current]::mc::LinesPerVariation \
		-from 1 \
		-to 4 \
		-width 2 \
		-justify right \
		-state readonly \
		-cursor {} \
		-takefocus 0 \
		-textvar [namespace current]::Options(engine:nlines) \
		-exportselection no \
		-command [namespace code [list SetLinesPerPV $tree]] \
	]
	$lpv set $Options(engine:nlines)
	::theme::configureSpinbox $lpv
	set Vars(widget:linesPerPV) $lpv
	::toolbar::add $tbControl frame -width 3
	set Vars(toolbar:control) $tbControl

	set tbInfo [::toolbar::toolbar $parent \
		-id analysis-info \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Information \
	]
	::toolbar::add $tbInfo label -textvar [namespace current]::mc::Hash
	set Vars(widget:hashfullness) [::toolbar::add $tbInfo label \
		-width 5 \
		-justify center \
		-background #e0e0e0 \
		-relief raised \
		-borderwidth 1 \
		-tooltipvar [namespace current]::mc::HashFullness \
	]

	SetState disabled
	Layout $tree
}


proc update {args} {
	variable Vars

	if {$Vars(engine:id) != -1 && !$Vars(engine:locked)} {
		after idle [list :::engine::startAnalysis $Vars(engine:id)]
	}
}


proc startAnalysis {dialog} {
	variable Vars
	variable Options

	::engine::kill $Vars(engine:id)

	set isReadyCmd [namespace current]::IsReady
	set signalCmd [namespace current]::Signal
	set updateCmd [namespace current]::UpdateInfo

	set Vars(engine:id) [::engine::startEngine $isReadyCmd $signalCmd $updateCmd]
	wm title $dialog [::engine::engineName $Vars(engine:id)]
	set Vars(dialog) $dialog

	if {$Vars(engine:id) >= 0} {
		if {$Options(engine:bestFirst)} { set order bestFirst } else { set order unordered }
		::scidb::engine::ordering $Vars(engine:id) $order
		::engine::activateEngine $Vars(engine:id) [list multiPV $Options(engine:multiPV)]
	}
}


proc restartAnalysis {} {
	variable Options
	variable Vars
	
	::engine::restartAnalysis $Vars(engine:id) [list multiPV $Options(engine:multiPV)]
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

	set Vars(engine:pause) [expr {!$Vars(engine:pause)}]

	if {$Vars(engine:pause)} {
		::engine::pause $Vars(engine:id)
		::toolbar::childconfigure $Vars(button:pause) \
			-image $::icon::toolbarStart \
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


proc Setup {} {
	::engine::openSetup .application
}


proc SetOrdering {tree} {
	variable Vars
	variable Defaults
	variable Options

	if {$Options(engine:bestFirst)} {
		set Vars(best:1) black
		set order bestFirst
	} else {
		set Vars(best:1) $Defaults(best:foreground)
		set order unordered
	}
	::scidb::engine::ordering $Vars(engine:id) $order
}


proc EngineLock {args} {
	variable Vars

	if {$Vars(engine:id) != -1 && !$Vars(engine:locked)} {
		after idle [list :::engine::startAnalysis $Vars(engine:id)]
	}
}


proc SetMultiPV {tree} {
	variable Vars
	variable Options

	::scidb::engine::multiPV $Vars(engine:id) $Options(engine:multiPV)
	Layout $tree
}


proc SetLinesPerPV {tree} {
	variable Vars
	variable Options

	set Options(engine:nlines) [$Vars(widget:linesPerPV) get]
	Layout $tree
}


proc Layout {tree} {
	variable Options
	variable Vars

	if {$Options(engine:multiPV) == 4} {
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
#	$tree style layout styleFig elemText -padx {4 4} -pady {2 2} -squeeze x -sticky ne -minheight $lheight
	$tree style layout styleFig elemTextFig -minheight $lheight
	$tree style layout styleSym elemTextSym -minheight $lheight
	::toolbar::childconfigure $Vars(widget:linesPerPV) -state $state
#	::toolbar::childconfigure $Vars(widget:ordering) -state $state

	if {$nlines == 1} {
		set lines 0
		set wrap none
	} else {
		set lines $nlines
		set wrap word
	}
	foreach i {0 1 2 3} {
		$tree item element configure Line$i Moves elemTextFig -lines $lines -wrap $wrap
	}
}


proc SetState {state} {
	variable Vars

	after cancel $Vars(after)
	if {![winfo exists $Vars(tree)]} { return }
	if {$Vars(state) eq $state} { return }
	set Vars(state) $state

	foreach child $Vars(toolbar:childs) {
		::toolbar::childconfigure $child -state $state
	}
}


proc GetEvaluation {score mate} {
	variable ScoreToEval

	if {$mate} {
		if {$mate > 0} { set nag 20 } else { set nag 21 }
	} else {
		set value [abs $score]
		set nag 20

		foreach {barrier nagv} $ScoreToEval {
			if {$value < $barrier} {
				set nag $nagv
				break
			}
		}

		if {$score < 0 && $nag != 10} { incr nag }
	}

	return [::font::mapNagToSymbol $nag]
}


proc FormatScore {score} {
	set p [expr {abs($score)/100}]
	set cp [expr {abs($score) % 100}]
	if {$score < 0} {
		set sign -
	} elseif {$score > 0} {
		set sign +
	} else {
		set sign ""
	}
	return [format "$sign%d.%02d" $p $cp]
}


proc Display(state) {state} {
	variable Vars

	switch $state {
		stop		{ set Vars(after) [after idle [namespace code [list SetState disabled]]] }
		start		{ SetState normal }
		pause		{}
		resume	{}
	}
}


proc Display(clear) {} {
	variable Defaults
	variable Vars

	$Vars(score) configure -state normal
	$Vars(score) delete 1.0 end
	$Vars(score) configure -state disabled

	$Vars(move) configure -state normal
	$Vars(move) delete 1.0 end
	$Vars(move) configure -state disabled

	$Vars(depth) configure -text ""
	$Vars(time) configure -text ""

	$Vars(widget:hashfullness) configure -text ""
	set Vars(maxMoves) 0

	set bg $Defaults(background)

	foreach i {0 1 2 3} {
		$Vars(tree) item element configure Line$i Eval  elemTextSym -text "" -fill black
		$Vars(tree) item element configure Line$i Value elemTextFig -text "" -fill black
		$Vars(tree) item element configure Line$i Moves elemTextFig -text "" -fill black
	}
}


proc Display(pv) {score mate depth seldepth time nodes line pv} {
	variable Options
	variable Vars

	Display(time) $time $depth $seldepth $nodes

	if {$mate} {
		if {$mate < 0} { set scoreTxt "-" } else { set scoreTxt "+" }
		set scoreTxt "#[abs $mate]"
	} else {
		set scoreTxt [FormatScore $score]
	}

	set evalTxt [GetEvaluation $score $mate]

	$Vars(tree) item element configure Line$line Eval  elemTextSym -text $evalTxt
	$Vars(tree) item element configure Line$line Value elemTextFig -text $scoreTxt
	$Vars(tree) item element configure Line$line Moves elemTextFig -text $pv
}


proc Display(bestscore) {score mate bestLines} {
	variable Vars

	$Vars(score) configure -state normal
	$Vars(score) delete 1.0 end
	if {$mate} {
		if {$mate < 0} { set stm White } else { set stm Black }
		set color [string index [set ::mc::$stm] 0]
		set scoreTxt [string map [list %color $color %n [abs $mate]] $mc::MateIn]
	} else {
		set scoreTxt "  "
		append scoreTxt [FormatScore $score]
		lassign [::font::splitAnnotation [GetEvaluation $score $mate]] value sym tags
		lappend tags center
		$Vars(score) insert end $sym $tags
	}
	$Vars(score) insert end $scoreTxt center
	$Vars(score) configure -state disabled

	set line 0
	foreach best $bestLines {
		$Vars(tree) item element configure Line$line Eval  elemTextSym -fill $Vars(best:$best)
		$Vars(tree) item element configure Line$line Value elemTextFig -fill $Vars(best:$best)
		if {$best} {
			set evalTxt [GetEvaluation $score $mate]
			$Vars(tree) item element configure Line$line Eval  elemTextSym -text $evalTxt
			$Vars(tree) item element configure Line$line Value elemTextFig -text $scoreTxt
		}
		incr line
	}
}


proc Display(checkmate) {color} {
	variable Vars

	$Vars(score) configure -state normal
	$Vars(score) delete 1.0 end
	$Vars(score) insert end "$color is mate" center
	$Vars(score) configure -state disabled
}


proc Display(stalemate) {color} {
	variable Vars

	$Vars(score) configure -state normal
	$Vars(score) delete 1.0 end
	$Vars(score) insert end "$color is stalemate" center
	$Vars(score) configure -state disabled
}


proc Display(move) {number count move} {
	variable Vars

	if {$count > 0} {
		set Vars(maxMoves) $count
	} elseif {$Vars(maxMoves) < $number} {
		set Vars(maxMoves) $number
	}

	$Vars(move) configure -state normal
	$Vars(move) delete 1.0 end
	$Vars(move) insert end $move {figurine center}
	if {$number > 0} {
		$Vars(move) insert end " ($number/$Vars(maxMoves))"
	}
	$Vars(move) configure -state disabled
}


proc Display(depth) {depth seldepth nodes} {
	Display(time) 0 $depth $seldepth $nodes
}


proc Display(time) {time depth seldepth nodes} {
	variable Vars

	if {$depth} {
		set txt $depth
		if {$seldepth} { append txt " (" $seldepth ")" }
		$Vars(depth) configure -text $txt
	}

	if {$time > 0.0} {
		set txt ""
		set seconds [lindex [split $time .] 0]
		set minutes [expr {$seconds/60}]
		if {$minutes} {
			append txt $minutes " " $mc::Minutes " "
			set seconds [expr {$seconds % 60}]
		}
		if {$seconds} {
			append txt $seconds " " $mc::Seconds
		}
		$Vars(time) configure -text $txt
	}
}


proc Display(bestmove) {move} {
}


proc Display(hash) {fullness} {
	variable Vars
	$Vars(widget:hashfullness) configure -text "[expr {int($fullness/10.0 + 0.5)}]%"
}


proc Display(cpuload) {load} {
#	variable Vars
#	$Vars(widget:cpuload) configure -text "[expr {int($load/10.0 + 0.5)}]%"
}


proc Display(error) {code} {
	variable Vars

	switch $code {
		registration - copyprotection {
			set msg $::engine::mc::ProbeError($code)
		}
		standard - chess960 - analyze {
			set msg $mc::NotSupported($code)
		}
	}

	Display(clear)
	$Vars(tree) item element configure Line0 Moves elemTextFig -text $msg -fill darkred
}


proc UpdateInfo {id type info} {
	Display($type) {*}$info
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
	SetState disabled

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
			after idle [list ::dialog::error -parent $parent -message $msg]
			after idle [list ::engine::kill $Vars(engine:id)]
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
