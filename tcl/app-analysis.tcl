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
# Copyright: (C) 2010-2013 Gregor Cramer
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
set IllegalPosition			"Illegal position - Cannot analyze"
set IllegalMoves				"Illegal moves in game - Cannot analyze"
set DidNotReceivePong		"Engine is not responding to \"ping\" command - Engine aborted"
set SearchMateNotSupported	"This engine is not supporting search for mate."
set Stopped						"stopped"

set LinesPerVariation		"Lines per variation"
set BestFirstOrder			"Use \"best first\" order"
set Engine						"Engine"

set Ply							"ply"
set Seconds						"sec"
set Minutes						"min"

set Status(checkmate)		"%s is checkmate"
set Status(stalemate)		"%s is stalemate"
set Status(threechecks)		"%s got three checks"
set Status(losing)			"%s lost all pieces"

set NotSupported(standard)	"This engine does not support standard chess."
set NotSupported(chess960)	"This engine does not support chess 960."
set NotSupported(variant)	"This engine does not support variant '%s'."
set NotSupported(analyze)	"This engine does not have an analysis mode."

set Signal(stopped)			"Engine stopped by signal."
set Signal(resumed)			"Engine resumed by signal."
set Signal(killed)			"Engine crashed or killed by signal."
set Signal(crashed)			"Engine crashed."
set Signal(closed)			"Engine has closed connection."
set Signal(terminated)		"Engine terminated with exit code %s."

set Add(move)					"Add move"
set Add(var)					"Add move as new variation"
set Add(line)					"Add variation"
set Add(all)					"Add all variations"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs

array set Defaults {
	background			analysis,background
	info:background	analysis,info:background
	info:foreground	analysis,info:foreground
	best:foreground	analysis,best:foreground
	error:foreground	analysis,error:foreground
	active:background	analysis,active:background
	engine:font			TkTextFont
	engine:delay		250
}

array set EngineMap {}

# from Scid
# array set Informant { !? 0.5 ? 1.5 ?? 3.0 ?! 0.5 }

#                 	   =			+=			+/-		+-
variable ScoreToEval {	45 10		75 14		175 16	400 18 }
# Values from Scid:		50			150		300		550
# Values from CB:			35			70			160


proc build {parent number {patternNumber 0}} {
	variable Defaults
	variable EngineMap

	namespace eval ${number} {}
	variable ${number}::Options

	set mw $parent.mw
	set main $mw.main
	set mesg $mw.mesg
	set tree $main.tree

	namespace eval $tree {}
	variable ${tree}::Vars

	array set Vars { engine:locked 0 engine:pause 0 }

	if {$patternNumber > 0} {
		array set Options [array get ${patternNumber}::Options]
	} elseif {![info exists Options]} {
		array set Options { engine:bestFirst 1 engine:nlines 2 engine:multiPV 4 engine:singlePV 0 }
	}

	set bg [::colors::lookup $Defaults(info:background)]
	set mw [tk::multiwindow $mw -borderwidth 0 -background $bg]

	set Vars(best:0) black
	if {$Options(engine:bestFirst) || $Options(engine:singlePV)} {
		set Vars(best:1) black
	} else {
		set Vars(best:1) $Defaults(best:foreground)
	}
	set Vars(maxMoves) 0
	set Vars(after) {}
	set Vars(after2) {}
	set Vars(state) normal
	set Vars(mode) normal
	set Vars(message) {}
	set Vars(title) ""
	set Vars(number) $number
	array set fopt [font configure $Defaults(engine:font)]
#	set Vars(font:bold) [list $fopt(-family) $fopt(-size) bold]
	set Vars(linespace) [font metrics $Defaults(engine:font) -linespace]
	set Vars(keepActive) 0
	set Vars(current:item) 0
	set Vars(main) $main
	set Vars(mesg) $mesg
	set Vars(mw) $mw

	set charwidth [font measure $Defaults(engine:font) "0"]
	set minsize [expr {12*$charwidth}]

	set main [tk::frame $main \
		-borderwidth 0 \
		-background [::colors::lookup $Defaults(info:background)] \
	]
	set mesg [tk::label $mw.mesg \
		-borderwidth 0 \
		-background [::colors::lookup $Defaults(background)] \
	]
	bind $mesg <<LanguageChanged>> [namespace code LanguageChanged]

	$mw add $main -sticky nsew
	$mw add $mesg

	set info [tk::frame $main.info \
		-background [::colors::lookup $Defaults(background)] \
		-borderwidth 0 \
	]
	set score [tk::frame $info.score \
		-background [::colors::lookup $Defaults(info:background)] \
		-borderwidth 1 \
		-relief raised \
	]
	set tscore [tk::text $info.score.t \
		-font $::font::text(text:normal) \
		-background [::colors::lookup $Defaults(info:background)] \
		-foreground [::colors::lookup $Defaults(info:foreground)] \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
	]
	$tscore tag configure center -justify center
	$tscore tag configure symbol -font $::font::symbol(text:normal)
	pack $tscore -padx 2 -pady 2
	set Vars(info) $main.info

	set move [tk::frame $info.move \
		-background [::colors::lookup $Defaults(info:background)] \
		-borderwidth 1 \
		-relief raised \
	]
	set tmove [tk::text $info.move.t \
		-font $::font::text(text:normal) \
		-background [::colors::lookup $Defaults(info:background)] \
		-foreground [::colors::lookup $Defaults(info:foreground)] \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
	]
	$tmove tag configure figurine -font $::font::figurine(text:normal)
	$tmove tag configure center -justify center
	$tmove tag configure stopped -foreground darkred
	pack $tmove -padx 2 -pady 2

	set time [tk::frame $info.time \
		-background [::colors::lookup $Defaults(info:background)] \
		-borderwidth 1 \
		-relief raised \
	]
	set ttime [tk::label $info.time.t \
		-font $::font::text(text:normal) \
		-background [::colors::lookup $Defaults(info:background)] \
		-foreground [::colors::lookup $Defaults(info:foreground)] \
		-borderwidth 0 \
		-width 0 \
	]
	pack $ttime -padx 2 -pady 2

	set depth [tk::frame $info.depth \
		-background [::colors::lookup $Defaults(info:background)] \
		-borderwidth 1 \
		-relief raised \
	]
	set tdepth [tk::label $info.depth.t \
		-font $::font::text(text:normal) \
		-background [::colors::lookup $Defaults(info:background)] \
		-foreground [::colors::lookup $Defaults(info:foreground)] \
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
		bind [set  $type] <ButtonPress-3> [namespace code [list PopupMenu $tree $number]]
		bind [set t$type] <ButtonPress-3> [namespace code [list PopupMenu $tree $number]]
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

	treectrl $tree \
		-takefocus 0 \
		-borderwidth 1 \
		-relief sunken \
		-showheader no \
		-selectmode single \
		-showroot no \
		-showlines no \
		-showrootlines no \
		-background [::colors::lookup $Defaults(background)] \
		-font $Defaults(engine:font) \
		;
	bind $tree <ButtonPress-3> [namespace code [list PopupMenu $tree $number %x %y]]
	bind $tree <ButtonPress-1> [namespace code [list AddMoves $tree %x %y]]

	$tree notify install <Item-enter>
	$tree notify install <Item-leave>
	$tree notify bind Table <Item-enter> [namespace code [list VisitItem $tree enter %C %I %x %y]]
	$tree notify bind Table <Item-leave> [namespace code [list VisitItem $tree leave %C %I]]

	$tree element create elemRect rect \
		-open nw \
		-outline gray \
		-outlinewidth 1 \
		-fill [list [::colors::lookup $Defaults(active:background)] active] \
		;
	$tree element create elemTextFig text \
		-lines $Options(engine:nlines) \
		-wrap word \
		-specialfont [list [list $::font::figurine(text:normal) 9812 9823]] \
		;
	$tree element create elemTextSym text \
		-lines $Options(engine:nlines) \
		-wrap word \
		-font $::font::symbol(text:normal) \
		;

	$tree style create styleFig
	$tree style elements styleFig {elemRect elemTextFig}
	$tree style layout styleFig elemRect -detach yes -iexpand xy
	$tree style layout styleFig elemTextFig -padx {4 4} -pady {2 2} -squeeze x -sticky ne

	$tree style create styleSym
	$tree style elements styleSym {elemRect elemTextSym}
	$tree style layout styleSym elemRect -detach yes -iexpand xy
	$tree style layout styleSym elemTextSym -padx {4 4} -pady {2 2} -squeeze x -sticky ne

	$tree column create -steady yes -tags Eval  -width [expr {6*$charwidth}] -itemjustify center
	$tree column create -steady yes -tags Value -width [expr {8*$charwidth}] -itemjustify right
	$tree column create -steady yes -tags Moves -expand yes -squeeze yes -weight 1 -itemjustify left

	foreach i {0 1 2 3 4 5 6 7} {
		set item [$tree item create]
		$tree item lastchild root $item
		$tree item configure $item -tag Line$i
		$tree item style set $item Eval  styleSym
		$tree item style set $item Value styleFig
		$tree item style set $item Moves styleFig
	}

	grid $info -column 0 -row 0 -sticky ew
	grid $tree -column 0 -row 1 -sticky ewns

	grid columnconfigure $info {1 3 5 7} -weight 1
	grid columnconfigure $info {2 4 6} -minsize 2

	grid columnconfigure $main 0 -weight 1
	grid rowconfigure $main 1 -weight 1

	pack $mw -fill both -expand yes

	set Vars(score) $info.score.t
	set Vars(move) $info.move.t
	set Vars(time) $info.time.t
	set Vars(depth) $info.depth.t
	set Vars(toolbar:childs) {}
	set Vars(toolbar:height) 0
	set Vars(info:height) 0

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
	trace add variable [namespace current]::${tree}::Vars(engine:pause) write \
		[namespace code [list ConfigurePause $tree]]
	lappend Vars(toolbar:childs) $Vars(button:pause)
	set Vars(button:lock) [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLock \
		-variable [namespace current]::${tree}::Vars(engine:locked) \
		-tooltipvar [namespace current]::mc::LockEngine \
		-command [namespace code [list EngineLock $tree]] \
	]
	lappend Vars(toolbar:childs) $Vars(button:lock)
	::toolbar::add $tbControl button \
		-image $::icon::toolbarSetup \
		-command [namespace code [list Setup $number]] \
		-tooltipvar [::mc::var [namespace current]::mc::Setup "..."] \
		;
	::toolbar::addSeparator $tbControl
	set tbw [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLines \
		-variable [namespace current]::${number}::Options(engine:singlePV) \
		-onvalue 0 \
		-offvalue 1 \
		-tooltipvar [namespace current]::mc::MultipleVariations \
		-command [namespace code [list SetMultiPV $tree]] \
	]
	lappend Vars(toolbar:childs) $tbw
	set Vars(widget:ordering) [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarSort(descending) \
		-variable [namespace current]::${number}::Options(engine:bestFirst) \
		-tooltipvar [namespace current]::mc::BestFirstOrder \
		-command [namespace code [list SetOrdering $tree]] \
	]
	lappend Vars(toolbar:childs) $Vars(widget:ordering)
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
		-textvar [namespace current]::${number}::Options(engine:nlines) \
		-exportselection no \
		-command [namespace code [list SetLinesPerPV $tree]] \
	]
	$lpv set $Options(engine:nlines)
	::theme::configureSpinbox $lpv
	set Vars(widget:linesPerPV) $lpv
	::toolbar::add $tbControl frame -width 3
	set Vars(toolbar:control) $tbControl
	bind $tbControl <Configure> [list set [namespace current]::${tree}::Vars(toolbar:height) %h]

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

	set EngineMap($number) $tree
	SetState $tree disabled
	Layout $tree
}


proc newNumber {} {
	variable EngineMap

	set i 1
	set numbers [array names EngineMap]
	while {$i in $numbers} { incr i }
	return $i
}


proc highestNumber {} {
	variable EngineMap

	set numbers [lsort -decreasing [array names EngineMap]]
	return [expr {[llength $numbers] ? [lindex $numbers 0] : 0}]
}


proc exists? {number} {
	variable EngineMap
	return [info exists EngineMap($number)]
}


proc active? {number} {
	return [::engine::active? $number]
}


proc update {args} {
	variable Defaults
	variable EngineMap

	foreach number [array names EngineMap] {
		variable [set [namespace current]::EngineMap($number)]::Vars

		if {[info exists Vars(after)]} {
			after cancel $Vars(after)
		}
		if {[::engine::active? $number] && !$Vars(engine:locked)} {
			set Vars(after) [after $Defaults(engine:delay) [list ::engine::startAnalysis $number]]
		}
	}
}


proc startAnalysis {number} {
	set tree [set [namespace current]::EngineMap($number)]
	variable ${tree}::Vars
	variable $Vars(number)::Options

	set Vars(message) {}
	$Vars(mesg) configure -text ""
	::engine::kill $number
	after cancel $Vars(after)

	set isReadyCmd [namespace current]::IsReady
	set signalCmd [namespace current]::Signal
	set updateCmd [namespace current]::UpdateInfo

	::engine::startEngine $number $isReadyCmd $signalCmd $updateCmd $tree
	::application::setAnalysisTitle $number [set Vars(title) [::engine::engineName $number]]
	set Vars(engine:pause) [expr {![engine::active? $number]}]

	if {!$Vars(engine:pause)} {
		if {$Options(engine:bestFirst)} { set order bestFirst } else { set order unordered }
		::scidb::engine::ordering [::engine::id $number] $order
		if {$Options(engine:singlePV)} { set multiPV 1 } else { set multiPV $Options(engine:multiPV) }
		::engine::activateEngine $number [list multiPV $multiPV]
	}
}


proc restartAnalysis {number} {
	variable $Vars(number)::Options
	variable ${tree}::Vars
	
	after cancel $Vars(after)
	if {$Options(engine:singlePV)} { set multiPV 1 } else { set multiPV $Options(engine:multiPV) }
	::engine::restartAnalysis $number [list multiPV $multiPV]
	::application::setAnalysisTitle $number [set Vars(title) [::engine::engineName $number]]
}


proc activate {w flag} {
	::toolbar::activate $w $flag
}


proc closed {w} {
	variable EngineMap

	set tree ${w}.mw.main.tree
	variable ${tree}::Vars

	after cancel $Vars(after)
	after cancel $Vars(after2)
	array unset EngineMap $Vars(number)
	::engine::kill $Vars(number)
}


proc clearHash {number} {
	Display(hash) [set [namespace current]::EngineMap($number)] 0
}


proc Pause {tree} {
	variable ${tree}::Vars

	set Vars(engine:pause) [expr {!$Vars(engine:pause)}]

	if {$Vars(engine:pause)} {
		after cancel $Vars(after)
		::engine::pause $Vars(number)
	} else {
		::engine::resume $Vars(number)
	}
}


proc ConfigurePause {tree args} {
	if {![winfo exists $tree]} { return }
	variable ${tree}::Vars

	if {$Vars(engine:pause)} {
		set icon $::icon::toolbarStart
		set tip [namespace current]::mc::Resume
	} else {
		set icon $::icon::toolbarPause
		set tip [namespace current]::mc::Pause
	}
	::toolbar::childconfigure $Vars(button:pause) -image $icon -tooltipvar $tip
}


proc Setup {number} {
	::engine::openSetup .application $number
}


proc SetOrdering {tree} {
	variable ${tree}::Vars
	variable $Vars(number)::Options
	variable Defaults

	if {$Options(engine:bestFirst) || $Options(engine:singlePV)} {
		set Vars(best:1) black
	} else {
		set Vars(best:1) [::colors::lookup $Defaults(best:foreground)]
	}

	if {$Options(engine:bestFirst)} {
		set order bestFirst
	} else {
		set order unordered
	}

	::scidb::engine::ordering [::engine::id $Vars(number)] $order

	if {$Options(engine:bestFirst)} {
		foreach i {0 1 2 3 4 5 6 7} {
			$tree item element configure Line$i Eval  elemTextSym -fill black
			$tree item element configure Line$i Value elemTextFig -fill black
		}
	}
}


proc EngineLock {tree} {
	variable ${tree}::Vars

	if {[::engine::active? $Vars(number)] && !$Vars(engine:locked)} {
		after cancel $Vars(after)
		after idle [list :::engine::startAnalysis $Vars(number)]
	}
}


proc ClearLines {tree args} {
	foreach i $args {
		$tree item element configure Line$i Eval  elemTextSym -text "" -fill black
		$tree item element configure Line$i Value elemTextFig -text "" -fill black
		$tree item element configure Line$i Moves elemTextFig -text "" -fill black
	}
}


proc SetMultiPV {tree {number 0}} {
	variable ${tree}::Vars
	variable $Vars(number)::Options
	variable Defaults

	if {$number} {
		if {$number == 1} {
			set Options(engine:singlePV) 1
		} else {
			set Options(engine:singlePV) 0
			set Options(engine:multiPV) $number
		}
	}

	if {$Options(engine:singlePV)} { set multiPV 1 } else { set multiPV $Options(engine:multiPV) }
	::scidb::engine::multiPV [::engine::id $Vars(number)] $multiPV
	if {$Options(engine:bestFirst) || $Options(engine:singlePV)} {
		set Vars(best:1) black
	} else {
		set Vars(best:1) [::colors::lookup $Defaults(best:foreground)]
	}
	Layout $tree
}


proc SetLinesPerPV {tree} {
	variable ${tree}::Vars
	variable $Vars(number)::Options

	set Options(engine:nlines) [$Vars(widget:linesPerPV) get]
	Layout $tree
}


proc Layout {tree} {
	variable ${tree}::Vars
	variable $Vars(number)::Options

	if {$Options(engine:singlePV)} {
		set pvcount 1
		set nlines 4
		set state disabled
	} else {
		set pvcount $Options(engine:multiPV)
		set nlines $Options(engine:nlines)
		set state readonly
	}

	if {$nlines == 1} {
		set lines 0
		set wrap none
	} else {
		set lines $nlines
		set wrap word
	}

	for {set i 0} {$i < $pvcount} {incr i} {
		$tree item configure Line$i -visible 1
		$tree item element configure Line$i Moves elemTextFig -lines $lines -wrap $wrap
	}

	for {} {$i < 8} {incr i} {
		$tree item configure Line$i -visible 0
		$tree item element configure Line$i Moves elemTextFig -lines $lines -wrap $wrap
		ClearLines $tree $i
	}

	set theight [expr {$nlines*$pvcount*$Vars(linespace) + $pvcount*4}]
	set lheight [expr {$nlines*$Vars(linespace)}]
	$tree configure -height $theight
#	$tree style layout styleFig elemText -padx {4 4} -pady {2 2} -squeeze x -sticky ne -minheight $lheight
	$tree style layout styleFig elemTextFig -minheight $lheight
	$tree style layout styleSym elemTextSym -minheight $lheight
	::toolbar::childconfigure $Vars(widget:linesPerPV) -state $state
#	::toolbar::childconfigure $Vars(widget:ordering) -state $state
	after idle [namespace code [list ResizePane $tree $theight]]
}


proc ResizePane {tree height} {
	variable ${tree}::Vars

	if {$height <= 1 || $Vars(toolbar:height) <= 1} { return }
	incr height $Vars(toolbar:height)
	incr height [winfo height $Vars(info)]
	incr height 8 ;# borders
	[namespace parent]::resizePaneHeight analysis:$Vars(number) $height
}


proc SetState {tree state} {
	variable ${tree}::Vars

	after cancel $Vars(after2)
	set Vars(after2) ""

	if {![winfo exists $tree]} { return }
	if {$Vars(state) eq $state} { return }
	set Vars(state) $state

	foreach child $Vars(toolbar:childs) {
		::toolbar::childconfigure $child -state $state
	}
}


proc EvalText {score mate} {
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

	return $nag
}


proc ScoreText {score mate} {
	if {$mate == 0} { return [FormatScore $score] }
	if {$mate < 0} { set sign "\u2212" } else { set sign "+" }
	return "$sign#[abs $mate]"
}


proc FormatScore {score} {
	set p [expr {abs($score)/100}]
	set cp [expr {abs($score) % 100}]
	if {$score < 0} {
		set sign "\u2212"
	} elseif {$score > 0} {
		set sign "+"
	} else {
		set sign ""
	}
	return [format "$sign%d.%02d" $p $cp]
}


proc ShowMessage {tree type txt} {
	variable Defaults
	variable ${tree}::Vars

	set width [expr {[winfo width $Vars(mw)] - 50}]
	$Vars(mesg) configure \
		-text $txt \
		-wraplength $width \
		-foreground [::colors::lookup $Defaults($type:foreground)] \
		;
	$Vars(mw) raise $Vars(mesg)
}


proc Display(state) {tree state} {
	variable ${tree}::Vars

	after cancel $Vars(after2)
	set Vars(after2) ""

	switch $state {
		stop	{ set Vars(after2) { after idle [namespace code [list SetState $tree disabled]] } }
		start	{ SetState $tree normal }

		pause - resume {
			$Vars(move) configure -state normal
			$Vars(move) delete 1.0 end
			if {$state eq "pause"} {
				$Vars(move) insert end $mc::Stopped {stopped center}
			} else {
				SetState $tree normal
			}
			$Vars(move) configure -state disabled
		}
	}
}


proc Display(clear) {tree} {
	variable Defaults
	variable ${tree}::Vars

	set Vars(message) {}
	$Vars(mesg) configure -text ""
	$Vars(mw) raise $Vars(main)

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

	ClearLines $tree 0 1 2 3 4 5 6 7
	$tree activate 0
}


proc Display(pv) {tree score mate depth seldepth time nodes nps tbhits line pv} {
	variable ${tree}::Vars
	variable $Vars(number)::Options

	Display(time) $tree $time $depth $seldepth $nodes $nps $tbhits

	set evalTxt [::font::mapNagToSymbol [EvalText $score $mate]]
	set scoreTxt [ScoreText $score $mate]

	$tree item element configure Line$line Eval  elemTextSym -text $evalTxt
	$tree item element configure Line$line Value elemTextFig -text $scoreTxt
	$tree item element configure Line$line Moves elemTextFig -text [::font::translate $pv]

	if {$line + 1 == $Vars(current:item)} {
		$tree activate $Vars(current:item)
	}
}


proc Display(suspended) {tree args} {
	variable ${tree}::Vars

	set line [lindex $args 6]
	set Vars(suspended,$line) $args
}


proc Display(bestscore) {tree score mate bestLines} {
	variable ${tree}::Vars

	$Vars(score) configure -state normal
	$Vars(score) delete 1.0 end
	if {$mate} {
		if {$mate < 0} { set stm White } else { set stm Black }
		set color [string index [set ::mc::$stm] 0]
		set scoreTxt [string map [list %color $color %n [abs $mate]] $mc::MateIn]
	} else {
		set scoreTxt "  "
		append scoreTxt [FormatScore $score]
		lassign [::font::splitAnnotation [EvalText $score $mate]] value sym tags
		lappend tags center
		$Vars(score) insert end $sym $tags
	}
	$Vars(score) insert end $scoreTxt center
	$Vars(score) configure -state disabled

	set line 0
	foreach best $bestLines {
		set color [::colors::lookup $Vars(best:$best)]
		$tree item element configure Line$line Eval  elemTextSym -fill $color
		$tree item element configure Line$line Value elemTextFig -fill $color
		if {$best} {
			set evalTxt [::font::mapNagToSymbol [EvalText $score $mate]]
			set scoreTxt [ScoreText $score $mate]
			$tree item element configure Line$line Eval  elemTextSym -text $evalTxt
			$tree item element configure Line$line Value elemTextFig -text $scoreTxt
		}
		incr line
	}
}


proc Display(over) {tree state color} {
	variable ${tree}::Vars

	set Vars(message) [list Display(over) $tree $state $color]
	ShowMessage $tree info [format $mc::Status($state) [set ::mc::[string toupper $color 0 0]]]
}


proc Display(move) {tree number count move} {
	variable ${tree}::Vars

	if {$count > 0} {
		set Vars(maxMoves) $count
	} elseif {$Vars(maxMoves) < $number} {
		set Vars(maxMoves) $number
	}

	$Vars(move) configure -state normal
	$Vars(move) delete 1.0 end
	$Vars(move) insert end [::font::translate $move] {figurine center}
	if {$number > 0} {
		$Vars(move) insert end " ($number/$Vars(maxMoves))"
	}
	$Vars(move) configure -state disabled
}


proc Display(time) {tree time depth seldepth nodes nps tbhits} {
	variable ${tree}::Vars

	# TODO: show nps, tbhits

	if {$depth} {
		set txt $depth
		if {$seldepth} { append txt " (" $seldepth ")" }
		append txt " " $mc::Ply
		$Vars(depth) configure -text $txt
	}

	if {$time > 0.0} {
		set txt ""
		set seconds [lindex [split $time .] 0]
		set minutes [expr {$seconds/60}]
		if {$minutes} {
			set seconds [expr {$seconds % 60}]
			append txt $minutes ":"
			if {[string length $seconds] == 1} { append txt "0" }
			append txt $seconds " " $mc::Minutes
		} elseif {$seconds} {
			append txt $seconds " " $mc::Seconds
		}
		$Vars(time) configure -text $txt
	}
}


proc Display(bestmove) {tree move} {
# TODO
}


proc Display(hash) {tree fullness} {
	variable ${tree}::Vars
	$Vars(widget:hashfullness) configure -text "[expr {int($fullness/10.0 + 0.5)}]%"
}


proc Display(cpuload) {tree load} {
#	TODO
#	variable ${tree}::Vars
#	$Vars(widget:cpuload) configure -text "[expr {int($load/10.0 + 0.5)}]%"
}


proc Display(error) {tree code} {
	variable ${tree}::Vars

	switch $code {
		registration - copyprotection	{ set msg $::engine::mc::ProbeError($code) }
		standard - chess960 - analyze	{ set msg $mc::NotSupported($code) }
		position								{ set msg $mc::IllegalPosition }
		moves									{ set msg $mc::IllegalMoves }
		pong									{ set msg $mc::DidNotReceivePong }
		searchMate							{ set msg $mc::SearchMateNotSupported }

		variant {
			set variant [::scidb::engine::variant [::engine::id $Vars(number)]]
			set msg [format $mc::NotSupported($code) $::mc::VariantName($variant)]
		}
	}

	set Vars(message) [list Display(error) $tree $code]
	ShowMessage $tree error $msg
}


proc UpdateInfo {tree id type info} {
	if {![winfo exists $tree]} { return }
	Display($type) $tree {*}$info
}


proc IsReady {tree id} {
	if {![winfo exists $tree]} { return }
	variable ${tree}::Vars
	after idle [list :::engine::startAnalysis $Vars(number)]
}


proc Signal {tree id code} {
	if {![winfo exists $tree]} { return }
	variable ${tree}::Vars

	after cancel $Vars(after)
	set parent [winfo toplevel $tree]
	SetState $tree disabled

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
			after idle [list ::engine::kill $Vars(number)]
		}
	}
}


proc VisitItem {tree mode column item {x {}} {y {}}} {
	variable ${tree}::Vars

	if {$Vars(keepActive)} { return }
	if {[string length $column] == 0} { return }
	if {![::engine::active? $Vars(number)]} { return }

	if {$mode eq "leave"} {
		$tree activate root
		set Vars(current:item) 0
	} else {
		if {$item <= [::scidb::engine::countLines [::engine::id $Vars(number)]]} {
			$tree activate $item
		}
		set Vars(current:item) $item
	}
}


proc AddMoves {tree x y} {
	variable ${tree}::Vars
	variable $Vars(number)::Options

	set id [$tree identify $x $y]
	if {[lindex $id 0] ne "item"} { return }
	set line [$tree item order [lindex $id 1] -visible]
	set id [::engine::id $Vars(number)]
	if {[::scidb::engine::empty? $id $line]} { return }
	if {[::scidb::engine::snapshot $id]} { set arg line } else { set arg move }
	InsertMoves $tree add $line $mc::Add($arg)
}


proc InsertMoves {tree what line operation} {
	variable ${tree}::Vars

	set id [::engine::id $Vars(number)]

	if {[application::pgn::ensureScratchGame]} {
		::scidb::engine::bind $id
	}

	# don't care about errors, may happen if the user is
	# double clicking or in seldom cases due to raise conditions
	::scidb::engine::snapshot $id $what $line
}


proc LanguageChanged {} {
	foreach number [array names EngineMap] {
		variable [set [namespace current]::EngineMap($number)]::Vars
		if {[llength $Vars(message)]} { {*}$Vars(message) }
	}
}


proc PopupMenu {tree number args} {
	variable ${tree}::Vars
	variable $Vars(number)::Options

	set menu $tree.__menu__
	catch { destroy $menu }
	menu $menu -tearoff no
	catch { wm attributes $menu -type popup_menu }

	if {[llength $args]} {
		set id [$tree identify {*}$args]

		if {[lindex $id 0] eq "item"} {
			set line [$tree item order [lindex $id 1] -visible]
			set id [::engine::id $Vars(number)]
			if {![::scidb::engine::empty? $id $line]} {
				$tree activate [set Vars(current:item) [expr {$line + 1}]]
				if {[::scidb::engine::snapshot $id]} {
					set state normal
					set lbl $mc::Add(var)
				} else {
					set state disabled
					set lbl $mc::Add(move)
				}
				$menu add command \
					-label " $lbl" \
					-image $::icon::16x16::plus \
					-compound left \
					-command [namespace code [list InsertMoves $tree move $line $lbl]] \
					;
				$menu add command \
					-label " $mc::Add(line)" \
					-image $::icon::16x16::plus \
					-compound left \
					-command [namespace code [list InsertMoves $tree line $line $mc::Add(line)]] \
					-state $state \
					;
				if {$Options(engine:singlePV)} { set state disabled }
				$menu add command \
					-label " $mc::Add(all)" \
					-image $::icon::16x16::plus \
					-compound left \
					-command [namespace code [list InsertMoves $tree all $line $mc::Add(all)]] \
					-state $state \
					;
				$menu add separator
			}
		}
	}

	$menu add command \
		-label " $mc::Setup..." \
		-image $::icon::16x16::setup \
		-compound left \
		-command [namespace code [list Setup $number]] \
		;
	if {$Vars(engine:pause)} {
		set txt $mc::Resume
		set img $::icon::16x16::start
	} else {
		set txt $mc::Pause
		set img $::icon::16x16::pause
	}
	$menu add command \
		-label " $txt" \
		-image $img \
		-compound left \
		-command [namespace code [list Pause $tree]] \
		;
	$menu add separator
	$menu add checkbutton \
		-label " $mc::LockEngine" \
		-image $::icon::16x16::lock \
		-compound left \
		-command [namespace code [list EngineLock $tree]] \
		-variable [namespace current]::${tree}::Vars(engine:locked) \
		;
	::theme::configureCheckEntry $menu
	$menu add checkbutton \
		-label " $mc::BestFirstOrder" \
		-image $::icon::16x16::sort(descending) \
		-compound left \
		-command [namespace code [list SetOrdering $tree]] \
		-variable [namespace current]::${number}::Options(engine:bestFirst) \
		;
	::theme::configureCheckEntry $menu
	$menu add separator
	set sub [menu $menu.multiPV -tearoff 0]
	$menu add cascade \
		-menu $sub \
		-label " $mc::MultipleVariations"  \
		-image $::icon::16x16::lines \
		-compound left \
		;
	foreach n {1 2 4 8} {
		$sub add radiobutton \
			-label $n \
			-value $n \
			-variable [namespace current]::${number}::Options(engine:multiPV) \
			-command [namespace code [list SetMultiPV $tree $n]] \
			;
		::theme::configureRadioEntry $sub
	}
	if {!$Options(engine:singlePV)} {
		set sub [menu $menu.lines -tearoff 0]
		$menu add cascade \
			-menu $sub \
			-label " $mc::LinesPerVariation" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach i {1 2 3 4} {
			$sub add radiobutton \
				-label $i \
				-value $i \
				-variable [namespace current]::${number}::Options(engine:nlines) \
				-command [namespace code [list SetLinesPerPV $tree]] \
				;
			::theme::configureRadioEntry $sub
		}
	}

	set Vars(keepActive) 1
	rename [namespace current]::Display(pv) [namespace current]::Display_
	rename [namespace current]::Display(suspended) [namespace current]::Display(pv)
	::bind $menu <<MenuUnpost>> [namespace code [list RevertDisplay $tree]]
	tk_popup $menu {*}[winfo pointerxy $tree]
}


proc RevertDisplay {tree} {
	variable ${tree}::Vars

	rename [namespace current]::Display(pv) [namespace current]::Display(suspended)
	rename [namespace current]::Display_ [namespace current]::Display(pv)

	foreach line [array names Vars suspended,*] {
		Display(pv) $tree {*}$Vars($line)
	}

	array unset Vars suspended,*
	set Vars(keepActive) 0
	after idle [namespace code [list ActivateCurrent $tree]]
}


proc ActivateCurrent {tree} {
	variable ${tree}::Vars

	if {![winfo exists $tree]} { return }
	lassign [winfo pointerxy $tree] x y
	set x [expr {$x - [winfo rootx $tree]}]
	set y [expr {$y - [winfo rooty $tree]}]
	set id [$tree identify $x $y]
	if {[lindex $id 0] eq "item"} { set item [lindex $id 1] } else { set item 0 }
	$tree activate $item
	set Vars(current:item) $item
}


proc WriteOptions {chan} {
	variable EngineMap

	foreach ns [namespace children [namespace current]] {
		if {[string match {*[0-9]} $ns]} {
			::options::writeEvalNS $chan $ns
			::options::writeItem $chan ${ns}::Options
		}
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace analysis
} ;# namespace application

# vi:set ts=3 sw=3:
