# =======================================================================
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
# Copyright: (C) 2010-2018 Gregor Cramer
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
set SetupEngine				"Setup engine"
set Pause						"Pause"
set Resume						"Resume"
set LockEngine					"Lock engine to current position"
set CloseEngine				"Power down motor"
set MultipleVariations		"Multiple variations"
set HashFullness				"Hash fullness"
set NodesPerSecond			"Nodes per second"
set TablebaseHits				"Tablebase hits"
set Hash							"Hash"
set Lines						"Lines"
set MateIn						"%color mate in %n"
set BestScore					"Best score (of current lines)"
set CurrentMove				"Currently searching this move"
set TimeSearched				"Time searched"
set SearchDepth				"Search depth in plies (Selective search depth)"
set IllegalPosition			"Illegal position - Cannot analyze"
set IllegalMoves				"Illegal moves in game - Cannot analyze"
set DidNotReceivePong		"Engine is not responding to \"ping\" command - Engine aborted"
set SearchMateNotSupported	"This engine is not supporting search for mate."
set EngineIsPausing			"This engine is currently pausing."
set PressEngineButton		"Use the locomotive for starting a motor."
set Stopped						"stopped"
set OpponentsView				"Opponents view"
set InsertMoveAsComment		"Insert move as comment"
set SetupEvalEdges			"Setup evaluation edges"
set InvalidEdgeValues		"Invalid edge values."
set MustBeAscending			"The values must be strictly ascending as in the examples."
set StartMotor					"Start motor"
set StartOfMotorFailed		"Start of motor failed"
set WineIsNotInstalled		"'Wine' is not (properly) installed"

set LinesPerVariation		"Lines per variation"
set BestFirstOrder			"Use \"best first\" order"
set Engine						"Engine"

set Ply							"ply"
set Seconds						"sec"
set Minutes						"min"

set Show(more)					"Show more"
set Show(less)					"Show less"

set Status(checkmate)		"%s is checkmate"
set Status(stalemate)		"%s is stalemate"
set Status(threechecks)		"%s got three checks"
set Status(losing)			"%s lost all pieces"
set Status(check)				"%s is in check"

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

set Add(move)					"Append move"
set Add(seq)					"Append variation"
set Add(var)					"Add move as new variation"
set Add(line)					"Add variation"
set Add(all)					"Add all variations"
set Add(merge)					"Merge variation"
set Add(incl)					"Merge all variations"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs

array set Defaults {
	engine:bestFirst	1
	engine:nlines		1
	engine:multiPV		4
	engine:singlePV	0
	toolbar:info		less
}

array set GlobalOptions {
	background			analysis,background
	info:background	analysis,info:background
	info:foreground	analysis,info:foreground
	best:foreground	analysis,best:foreground
	error:foreground	analysis,error:foreground
	active:background	analysis,active:background
	engine:delay		250
	eval:edges			{ 45 75 175 400 }
	engine:font			TkTextFont
}
# Edge values:
# Scidb:		45	 75	175	400
# Scid:		50	150	300	550
# CB:			35	70		160

array set NumberToTree {}
set FreeNumbers {}

# from Scid
# array set Informant { !? 0.5 ? 1.5 ?? 3.0 ?! 0.5 }


proc build {parent number patternNumber} {
	variable ScoreEdgeValues
	variable GlobalOptions
	variable Defaults
	variable NumberToTree

	namespace eval ${number} {}
	variable ${number}::Options

	set ScoreEdgeValues {}
	foreach score $GlobalOptions(eval:edges) nag {10 14 16 18} { lappend ScoreEdgeValues $score $nag }

	set mw $parent.mw
	set main $mw.main
	set mesg $mw.mesg
	set tree $main.tree

	namespace eval $tree {}
	variable ${tree}::Vars

	array set Vars {
		after:id				{}
		best:0				black
		best:1				black
		current:item		0
		current:message	{}
		engine:locked		0
		engine:opponent	0
		engine:opponent	0
		engine:pause		0
		engine:state		normal
		info:height			0
		keep:active			0
		moves:max			0
		state:paused		0
		toolbar:childs		{}
		toolbar:height		0
	}

	array set Options [array get ${patternNumber}::Options]
	foreach name [array names Defaults] {
		if {![info exists Options($name)]} { set Options($name) $Defaults($name) }
	}

	set bg [::colors::lookup $GlobalOptions(info:background)]
	set fg [::colors::lookup $GlobalOptions(info:foreground)]
	set mw [tk::multiwindow $mw -borderwidth 0 -background $bg -takefocus 0]

	if {!$Options(engine:bestFirst) && !$Options(engine:singlePV)} {
		set Vars(best:1) $GlobalOptions(best:foreground)
	}
	set Vars(linespace) [font metrics $GlobalOptions(engine:font) -linespace]
	set Vars(number) $number
	set Vars(main) $main
	set Vars(mesg) $mesg
	set Vars(mw) $mw

	set charwidth [font measure $GlobalOptions(engine:font) "0"]
	set minsize [expr {12*$charwidth}]

	set main [tk::frame $main -takefocus 0 -borderwidth 0 -background $bg]
	set mesg [tk::label $mw.mesg \
		-takefocus 0 \
		-borderwidth 0 \
		-background [::colors::lookup $GlobalOptions(background)] \
	]
	bind $main <<LanguageChanged>> [namespace code LanguageChanged]
	bind $mesg <ButtonPress-3> [namespace code [list PopupMenu $tree $number]]

	$mw add $main -sticky nsew
	$mw add $mesg

	set info [tk::frame $main.info \
		-background [::colors::lookup $GlobalOptions(background)] \
		-borderwidth 0 \
		-takefocus 0 \
	]
	set score [tk::frame $info.score -background $bg -borderwidth 1 -relief raised -takefocus 0]
	set tscore [tk::text $info.score.t \
		-font $::font::text(text:normal) \
		-background $bg \
		-foreground $fg \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
		-takefocus 0 \
	]
	catch { $tscore configure -state readonly }
	$tscore tag configure center -justify center
	$tscore tag configure symbol -font $::font::symbol(text:normal)
	pack $tscore -padx 2 -pady 2
	set Vars(info) $main.info

	set move [tk::frame $info.move -background $bg -borderwidth 1 -relief raised -takefocus 0]
	set tmove [tk::text $info.move.t \
		-font $::font::text(text:normal) \
		-background $bg \
		-foreground $fg \
		-borderwidth 0 \
		-state disabled \
		-width 0 \
		-height 1 \
		-cursor {} \
		-takefocus 0 \
	]
	catch { $tmove configure -state readonly }
	$tmove tag configure figurine -font $::font::figurine(text:normal)
	$tmove tag configure center -justify center
	$tmove tag configure stopped -foreground darkred
	pack $tmove -padx 2 -pady 2

	set time [tk::frame $info.time -background $bg -borderwidth 1 -relief raised -takefocus 0]
	set ttime [tk::label $info.time.t \
		-font $::font::text(text:normal) \
		-background $bg \
		-foreground $fg \
		-borderwidth 0 \
		-width 0 \
		-takefocus 0 \
	]
	pack $ttime -padx 2 -pady 2

	set depth [tk::frame $info.depth -background $bg -borderwidth 1 -relief raised -takefocus 0]
	set tdepth [tk::label $info.depth.t \
		-font $::font::text(text:normal) \
		-background $bg \
		-foreground $fg \
		-borderwidth 0 \
		-takefocus 0 \
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
		-background [::colors::lookup $GlobalOptions(background)] \
		-font $GlobalOptions(engine:font) \
		;
	bind $tree <ButtonPress-3> [namespace code [list PopupMenu $tree $number %x %y]]
	bind $tree <ButtonPress-1> [namespace code [list AddMove $tree %x %y %s]]

	$tree notify install <Item-enter>
	$tree notify install <Item-leave>
	$tree notify bind Table <Item-enter> [namespace code [list VisitItem $tree enter %C %I %x %y]]
	$tree notify bind Table <Item-leave> [namespace code [list VisitItem $tree leave %C %I]]

	$tree element create elemRect rect \
		-open nw \
		-outline gray \
		-outlinewidth 1 \
		-fill [list [::colors::lookup $GlobalOptions(active:background)] active] \
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

	set tbControl [::toolbar::toolbar $parent \
		-id analysis-control \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control \
		-avoidconfigurehack 1 \
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
	set Vars(button:opponent) [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarRotateBoard \
		-variable [namespace current]::${tree}::Vars(engine:opponent) \
		-command [namespace code [list restartAnalysis $Vars(number)]] \
		-tooltipvar [namespace current]::mc::OpponentsView \
	]
	lappend Vars(toolbar:childs) $Vars(button:opponent)
	::toolbar::add $tbControl button \
		-image $::icon::toolbarEngine \
		-command [namespace code [list Setup $tree $number]] \
		-tooltipvar [::mc::var [namespace current]::mc::SetupEngine "..."] \
		;
	set Vars(button:close) [::toolbar::add $tbControl button \
		-image $::icon::toolbarStop \
		-tooltipvar [namespace current]::mc::CloseEngine \
		-command [namespace code [list CloseEngine $tree]] \
		-state disabled \
	]
	::toolbar::addSeparator $tbControl
	set tbw [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarLines \
		-variable [namespace current]::${number}::Options(engine:singlePV) \
		-onvalue 0 \
		-offvalue 1 \
		-tooltipvar [namespace current]::mc::MultipleVariations \
		-command [namespace code [list SetMultiPV $tree]] \
	]
	#lappend Vars(toolbar:childs) $tbw
	set Vars(widget:ordering) [::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarSort(descending) \
		-variable [namespace current]::${number}::Options(engine:bestFirst) \
		-tooltipvar [namespace current]::mc::BestFirstOrder \
		-command [namespace code [list SetOrdering $tree]] \
	]
	#lappend Vars(toolbar:childs) $Vars(widget:ordering)
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
	set Vars(widget:show) \
		[::toolbar::add $tbInfo button -command [namespace code [list ToggleInfo $tree]]]
	set Vars(widget:nps:label) [::toolbar::add $tbInfo label -text "NPS"]
	set Vars(widget:nps) [::toolbar::add $tbInfo label \
		-width 9 \
		-justify center \
		-background #e0e0e0 \
		-relief raised \
		-borderwidth 1 \
		-tooltipvar [namespace current]::mc::NodesPerSecond \
	]
	set Vars(widget:tbhits:label) [::toolbar::add $tbInfo label -text "TB hits"]
	set Vars(widget:tbhits) [::toolbar::add $tbInfo label \
		-width 5 \
		-justify center \
		-background #e0e0e0 \
		-relief raised \
		-borderwidth 1 \
		-tooltipvar [namespace current]::mc::TablebaseHits \
	]

	set NumberToTree($number) $tree
	ConfigureInfo $tree
	SetState $tree disabled
	Layout $tree
	DisplayPressEngineButton $tree
}


proc exists? {number} {
	variable NumberToTree
	return [info exists NumberToTree($number)]
}


proc active? {number} {
	if {![exists? $number]} { return false }
	variable NumberToTree
	set tree $NumberToTree($number)
	return [::engine::active? [set ${tree}::Vars(number)]]
}


proc newNumber {} {
	variable NumberToTree
	variable FreeNumbers
	
	if {[llength $FreeNumbers]} {
		set n [lindex $FreeNumbers 0]
		set FreeNumbers [lrange $FreeNumbers 1 end]
		return $n
	}

	if {[array size NumberToTree] == 0} { return 1 }
	return [expr {[lindex [lsort -integer -decreasing [array names NumberToTree]] 0] + 1}]
}


proc update {args} {
	variable GlobalOptions
	variable NumberToTree

	foreach number [array names NumberToTree] {
		variable [set [namespace current]::NumberToTree($number)]::Vars

		if {[info exists Vars(after:id)]} {
			after cancel $Vars(after:id)
		}
		if {[::engine::active? $number] && !$Vars(engine:locked)} {
			set Vars(after:id) [after $GlobalOptions(engine:delay) [list ::engine::startAnalysis $number]]
		}
	}
}


proc startAnalysis {number} {
	variable NumberToTree

	if {![exists? $number]} {
		::application::newAnalysisPane $number
	}
	set tree [set NumberToTree($number)]
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

	set Vars(current:message) {}
	$Vars(mesg) configure -text ""
	::engine::kill $number
	after cancel $Vars(after:id)

	set isReadyCmd [namespace current]::IsReady
	set signalCmd [namespace current]::Signal
	set updateCmd [namespace current]::UpdateInfo

	DisplayStartOfMotor $tree $number
	set rc [::engine::startEngine $number $isReadyCmd $signalCmd $updateCmd $tree]

	if {![string is integer -strict $rc] || $rc == -2} {
		DisplayStartOfMotorFailed $tree $rc
		set rc -1
	}

	::application::updateAnalysisTitle $number [::engine::engineName $number]
	set Vars(engine:pause) [expr {![engine::active? $number]}]

	if {!$Vars(engine:pause)} {
		if {$Options(engine:bestFirst)} { set order bestFirst } else { set order unordered }
		::scidb::engine::ordering [::engine::id $number] $order
		if {$Options(engine:singlePV)} { set multiPV 1 } else { set multiPV $Options(engine:multiPV) }
		::engine::activateEngine $number [list multiPV $multiPV]
	}
}


proc restartAnalysis {number} {
	variable NumberToTree
	set tree [set NumberToTree($number)]
	variable ${tree}::Vars
	variable ${Vars(number)}::Options
	
	after cancel $Vars(after:id)
	if {$Options(engine:singlePV)} { set multiPV 1 } else { set multiPV $Options(engine:multiPV) }
	::engine::restartAnalysis $number $Vars(engine:opponent) [list multiPV $multiPV]
	::application::updateAnalysisTitle $number [::engine::engineName $number]
}


proc activate {w flag} {
	::toolbar::activate $w $flag
}


proc closed {w} {
	variable NumberToTree
	variable FreeNumbers

	set tree ${w}.mw.main.tree
	variable ${tree}::Vars

	after cancel $Vars(after:id)
	array unset NumberToTree $Vars(number)
	lappend FreeNumbers $Vars(number)
	::engine::forget $Vars(number)

	if {[winfo exists $Vars(button:close)]} {
		::toolbar::childconfigure $Vars(button:close) -state disabled
	}
}


proc clearHash {number} {
	Display(hash) [set [namespace current]::NumberToTree($number)] 0
}


proc CloseEngine {tree} {
	variable ${tree}::Vars

	::engine::kill $Vars(number)
	::toolbar::childconfigure $Vars(button:close) -state disabled
	::application::updateAnalysisTitle $Vars(number)
	after idle [namespace code [list DisplayPressEngineButton $tree]]
}


proc Pause {tree} {
	variable ${tree}::Vars

	set Vars(engine:pause) [expr {!$Vars(engine:pause)}]

	if {$Vars(engine:pause)} {
		after cancel $Vars(after:id)
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


proc Setup {tree number} {
	::engine::openSetup [winfo toplevel $tree] $number
}


proc ToggleInfo {tree} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

	if {$Options(toolbar:info) eq "more"} {
		set Options(toolbar:info) less
	} else {
		set Options(toolbar:info) more
	}

	ConfigureInfo $tree
}


proc ConfigureInfo {tree} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

	switch $Options(toolbar:info) {
		more {
			set arrow $icon::11x14::arrowLeft
			set ttv [namespace current]::mc::Show(less)
			set visible yes
		}
		less {
			set arrow $icon::11x14::arrowRight
			set ttv [namespace current]::mc::Show(more)
			set visible no
		}
	}

	::toolbar::childconfigure $Vars(widget:show) -image $arrow -tooltipvar $ttv
	::toolbar::childconfigure $Vars(widget:nps:label) -visible $visible
	::toolbar::childconfigure $Vars(widget:nps) -visible $visible
	::toolbar::childconfigure $Vars(widget:tbhits:label) -visible $visible
	::toolbar::childconfigure $Vars(widget:tbhits) -visible $visible
}


proc SetOrdering {tree} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options
	variable GlobalOptions

	if {$Options(engine:bestFirst) || $Options(engine:singlePV)} {
		set Vars(best:1) black
	} else {
		set Vars(best:1) [::colors::lookup $GlobalOptions(best:foreground)]
	}

	if {$Options(engine:bestFirst)} {
		set order bestFirst
	} else {
		set order unordered
	}

	if {[::engine::active? $Vars(number)]} {
		::scidb::engine::ordering [::engine::id $Vars(number)] $order
	}

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
		after cancel $Vars(after:id)
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
	variable ${Vars(number)}::Options

	if {$number} {
		if {$number == 1} {
			set Options(engine:singlePV) 1
		} else {
			set Options(engine:singlePV) 0
			set Options(engine:multiPV) $number
		}
	}

	if {$Options(engine:singlePV)} { set multiPV 1 } else { set multiPV $Options(engine:multiPV) }
	if {[::engine::active? $Vars(number)]} {
		::scidb::engine::multiPV [::engine::id $Vars(number)] $multiPV
	}
	if {$Options(engine:bestFirst) || $Options(engine:singlePV)} {
		set Vars(best:1) black
	} else {
		set Vars(best:1) [::colors::lookup $GlobalOptions(best:foreground)]
	}
	Layout $tree
}


proc SetLinesPerPV {tree} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

	set Options(engine:nlines) [$Vars(widget:linesPerPV) get]
	Layout $tree
}


proc Layout {tree} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

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
	incr height 5 ;# borders
	[namespace parent]::resizePaneHeight $Vars(number) $height
}


proc SetState {tree state} {
	variable ${tree}::Vars

	set Vars(state:paused) 0

	if {![winfo exists $tree]} { return }
	if {$Vars(engine:state) eq $state} { return }

	set Vars(engine:state) $state

	foreach child $Vars(toolbar:childs) {
		::toolbar::childconfigure $child -state $state
	}
}


proc EvalText {score mate} {
	variable ScoreEdgeValues

	if {$mate} {
		if {$mate > 0} { set nag 20 } else { set nag 21 }
	} else {
		set value [abs $score]
		set nag 20

		foreach {barrier nagv} $ScoreEdgeValues {
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
	variable GlobalOptions
	variable ${tree}::Vars

	set width [expr {[winfo width $Vars(mw)] - 50}]
	$Vars(mesg) configure \
		-text $txt \
		-wraplength $width \
		-foreground [::colors::lookup $GlobalOptions($type:foreground)] \
		;
	$Vars(mw) raise $Vars(mesg)
}


proc DisplayPressEngineButton {tree} {
	variable ${tree}::Vars

	set Vars(current:message) [list [namespace current]::DisplayPressEngineButton $tree]
	ShowMessage $tree info $mc::PressEngineButton
}


proc DisplayStartOfMotorFailed {tree rc} {
	variable ${tree}::Vars

	set msg $mc::StartOfMotorFailed
	append msg ": "
	if {![string is integer -strict $rc]} {
		append msg "\"" $rc "\""
	} else {
		append msg $mc::WineIsNotInstalled
	}
	append msg "."
	set Vars(current:message) [list [namespace current]::DisplayStartOfMotorFailed $tree $rc]
	ShowMessage error $msg
}


proc Display(state) {tree state} {
	variable ${tree}::Vars

	switch $state {
		stop	{
			SetState $tree disabled
			::toolbar::childconfigure $Vars(button:close) -state disabled
			Display(clear) $tree
		}

		start	{
			SetState $tree normal
			::toolbar::childconfigure $Vars(button:close) -state normal
		}

		pause {
			if {!$Vars(state:paused)} {
				$Vars(move) delete 1.0 end
				if {[$Vars(mw) raise] eq $Vars(mesg)} {
					ShowMessage $tree info $mc::EngineIsPausing
				} else {
					$Vars(move) insert end $mc::Stopped {stopped center}
				}
				set Vars(state:paused) 1
			}
		}

		resume {
			$Vars(move) delete 1.0 end
			SetState $tree normal
			set Vars(engine:pause) 0
			$Vars(button:close) configure -state normal
		}
	}
}


proc Display(clear) {tree} {
	variable ${tree}::Vars

	set Vars(current:message) {}
	$Vars(mesg) configure -text ""
	$Vars(mw) raise $Vars(main)

	$Vars(score) delete 1.0 end
	$Vars(move) delete 1.0 end
	$Vars(depth) configure -text ""
	$Vars(time) configure -text ""

	[::toolbar::lookupChild $Vars(widget:hashfullness)] configure -text ""
	[::toolbar::lookupChild $Vars(widget:nps)] configure -text ""
	[::toolbar::lookupChild $Vars(widget:tbhits)] configure -text ""
	set Vars(moves:max) 0

	ClearLines $tree 0 1 2 3 4 5 6 7
	$tree activate 0
}


proc Display(pv) {tree score mate depth seldepth time nodes nps tbhits line pv} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

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
	set Vars(suspended,$line) $args ;# XXX unused
}


proc Display(bestscore) {tree score mate bestLines} {
	variable ${tree}::Vars

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


proc DisplayStartOfMotor {tree number} {
	variable ${tree}::Vars

	append msg "$mc::StartMotor \""
	append msg [join [::engine::startCommand $number] " "]
	append msg "\" ..."
	ShowMessage $tree info $msg
}


proc Display(over) {tree state color} {
	variable ${tree}::Vars

	set Vars(current:message) [list [namespace current]::Display(over) $tree $state $color]
	ShowMessage $tree info [format $mc::Status($state) [set ::mc::[string toupper $color 0 0]]]
}


proc Display(move) {tree number count move} {
	variable ${tree}::Vars

	if {$count > 0} {
		set Vars(moves:max) $count
	} elseif {$Vars(moves:max) < $number} {
		set Vars(moves:max) $number
	}

	$Vars(move) delete 1.0 end
	$Vars(move) insert end [::font::translate $move] {figurine center}
	if {$number > 0} {
		$Vars(move) insert end " ($number/$Vars(moves:max))"
	}
}


proc Display(time) {tree time depth seldepth nodes nps tbhits} {
	variable ${tree}::Vars

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

	if {$nps} {
		[::toolbar::lookupChild $Vars(widget:nps)] configure -text [::locale::formatNumber $nps]
	}

	if {$tbhits} {
		[::toolbar::lookupChild $Vars(widget:tbhits)] configure -text [::locale::formatNumber $tbhits]
	}
}


proc Display(bestmove) {tree move} {
	# not yet used
}


proc Display(hash) {tree fullness} {
	variable ${tree}::Vars

	set w [::toolbar::lookupChild $Vars(widget:hashfullness)]
	$w configure -text "[expr {int($fullness/10.0 + 0.5)}]%"
}


proc Display(cpuload) {tree load} {
#	TODO
#	variable ${tree}::Vars
#	[::toolbar::lookupChild $Vars(widget:cpuload)] configure -text "[expr {int($load/10.0 + 0.5)}]%"
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

	set Vars(current:message) [list [namespace current]::Display(error) $tree $code]
	ShowMessage $tree error $msg
}


proc UpdateInfo {tree id type info} {
	variable ${tree}::Vars

	if {[winfo exists $tree]} {
		Display($type) $tree {*}$info
	}
}


proc IsReady {tree id} {
	if {![winfo exists $tree]} { return }
	variable ${tree}::Vars
	after idle [list :::engine::startAnalysis $Vars(number)]
}


proc Signal {tree id code} {
	if {![winfo exists $tree]} { return }
	variable ${tree}::Vars

	after cancel $Vars(after:id)
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
			if {[string is integer $code]} {
				set msg [format $mc::Signal(terminated) $code]
			} else {
				set msg $mc::Signal($code)
			}
			after idle [list ::dialog::error -parent $parent -message $msg]
			after idle [list ::engine::kill $Vars(number)]
		}
	}
}


proc VisitItem {tree mode column item {x {}} {y {}}} {
	variable ${tree}::Vars

	if {$Vars(keep:active)} { return }
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


proc AddMove {tree x y state} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

	if {$Vars(engine:opponent)} { return }
	if {[::scidb::game::query expansion?]} { return }
	set engineID [::engine::id $Vars(number)]
	if {$engineID == -1} { return }
	if {![::scidb::engine::bound? $engineID]} { return }
	set id [$tree identify $x $y]
	if {[lindex $id 0] ne "item"} { return }
	set id [$tree identify $x $y]
	set line [$tree item order [lindex $id 1] -visible]
	if {[::scidb::engine::empty? $engineID $line]} { return }
	::scidb::engine::snapshot $engineID
	set san [::scidb::engine::snapshot $engineID san $line]
	if  {[::scidb::game::valid? $san]} {
		set force [::util::shiftIsHeldDown? $state]
		::move::addMove menu $san -force $force
	}
	::scidb::engine::snapshot $engineID clear
}


proc InsertMoves {tree what line} {
	variable ${tree}::Vars

	set id [::engine::id $Vars(number)]

	if {[application::pgn::ensureScratchGame]} {
		::scidb::engine::bind $id
	}

	# don't care about errors, may happen if the user is
	# double clicking or in seldom cases due to raise conditions
	::scidb::engine::snapshot $id $what $line
}


proc InsertComment {tree line} {
	variable ${tree}::Vars

	set id [::engine::id $Vars(number)]
	set san [::scidb::engine::snapshot $id comment $line]

	if {[string length $san]} {
		set move {}
		if {$Vars(engine:opponent)} {
			lappend move {nag 140}
			lappend move {str " "}
		}
		if {[string index $san 0] in {K Q R B N P}} {
			lappend move [list sym [string index $san 0]]
			set san [string range $san 1 end]
		}
		lappend move [list str $san]
		set comment [::scidb::misc::xml fromList [list [list {} $move]]]
		::scidb::game::update addcomment [::scidb::game::query current] [::scidb::game::current] $comment
	}
}


proc LanguageChanged {} {
	variable NumberToTree

	foreach number [array names NumberToTree] {
		variable [set [namespace current]::NumberToTree($number)]::Vars
		if {[llength $Vars(current:message)]} { {*}$Vars(current:message) }
	}
}


proc PopupMenu {tree number args} {
	variable ${tree}::Vars
	variable ${Vars(number)}::Options

	set menu $tree.__menu__
	catch { destroy $menu }
	menu $menu -tearoff no
	catch { wm attributes $menu -type popup_menu }

	if {[llength $args] && [::engine::id $Vars(number)] >= 0} {
		set id [$tree identify {*}$args]

		if {[lindex $id 0] eq "item"} {
			set line [$tree item order [lindex $id 1] -visible]
			set id [::engine::id $Vars(number)]
			if {	![::scidb::engine::empty? $id $line]
				&& ![::scidb::game::query expansion?]
				&& [::scidb::engine::bound? $id]} {
				$tree activate [set Vars(current:item) [expr {$line + 1}]]
				if {[set atLineEnd [::scidb::engine::snapshot $id]] eq "atend"} {
					set action move
					set icon $icon::16x16::append
				} else {
					set action var
					set icon $::icon::16x16::plus
				}
				$menu add command \
					-label " $mc::Add($action)" \
					-image $icon \
					-compound left \
					-command [namespace code [list InsertMoves $tree $action $line]] \
					;
				if {$atLineEnd eq "atend"} {
					$menu add command \
						-label " $mc::Add(seq)" \
						-image $icon::16x16::append \
						-compound left \
						-command [namespace code [list InsertMoves $tree seq $line]] \
						;
				}
				if {[::scidb::game::current] != 9} {
					$menu add command \
						-label " $mc::Add(line)" \
						-image $::icon::16x16::plus \
						-compound left \
						-command [namespace code [list InsertMoves $tree line $line]] \
						;
					if {!$Options(engine:singlePV)} {
						$menu add command \
							-label " $mc::Add(all)" \
							-image $::icon::16x16::plus \
							-compound left \
							-command [namespace code [list InsertMoves $tree all $line]] \
							;
					}
					if {!$Vars(engine:opponent)} {
						$menu add command \
							-label " $mc::Add(merge)" \
							-image $::icon::16x16::merge \
							-compound left \
							-command [namespace code [list InsertMoves $tree merge $line]] \
							;
						if {!$Options(engine:singlePV)} {
							$menu add command \
								-label " $mc::Add(incl)" \
								-image $::icon::16x16::merge \
								-compound left \
								-command [namespace code [list InsertMoves $tree incl $line]] \
								;
						}
					}
					$menu add command \
						-label " $mc::InsertMoveAsComment" \
						-image $icon::16x16::insert \
						-compound left \
						-command [namespace code [list InsertComment $tree $line]] \
						;
				}
				$menu add separator
			}
		}
	}

	$menu add command \
		-label " $mc::SetupEngine..." \
		-image $::icon::16x16::setup \
		-compound left \
		-command [namespace code [list Setup $tree $number]] \
		;
	$menu add command \
		-label " $mc::SetupEvalEdges..." \
		-image $::icon::16x16::none \
		-compound left \
		-command [namespace code [list SetupEvalEdges $tree]]
		;

	if {[::engine::id $Vars(number)] >= 0} {
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
		if {$Vars(number) >= 0} {
			$menu add command \
				-label " $mc::CloseEngine" \
				-image $::icon::16x16::stop \
				-compound left \
				-command [namespace code [list CloseEngine $tree]] \
				;
		}
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
			-label " $mc::OpponentsView" \
			-image $::icon::16x16::rotateBoard \
			-compound left \
			-command [namespace code [list restartAnalysis $Vars(number)]] \
			-variable [namespace current]::${tree}::Vars(engine:opponent) \
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
		foreach n {1 2 3 4 5 6 7 8} {
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

		set Vars(keep:active) 1
		rename [namespace current]::Display(pv) [namespace current]::Display_
		rename [namespace current]::Display(suspended) [namespace current]::Display(pv)
		::bind $menu <<MenuUnpost>> [namespace code [list RevertDisplay $tree]]
	}

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
	set Vars(keep:active) 0
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


proc SetupEvalEdges {tree} {
	variable GlobalOptions
	variable Score_

	set dlg [tk::toplevel $tree.setupEvalRanges -class Dialog]
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes
#	ttk::label $top.logo -style icon.TButton -image $::icon::48x48::logo -borderwidth 0
	ttk::label $top.logo -style icon.TButton -image $::icon::32x32::engine -borderwidth 0
	grid $top.logo -row 1 -column 1 -rowspan 3

	foreach nag {14 16 18 20} score $GlobalOptions(eval:edges) {
		set Score_($nag) [::locale::formatSpinboxDouble [expr {$score/100.0}]]
	}

	set col 1
	foreach nag {14 16 18 20} {
		ttk::label $top.lbl$nag \
			-font $::font::symbol(text:normal) \
			-anchor center \
			-text [::font::mapNagToSymbol $nag] \
			;
		grid $top.lbl$nag -row 1 -column [incr col 2] -sticky ew
		::tooltip::tooltip $top.lbl$nag ::annotation::mc::Nag($nag)
	}

	set col 1
	foreach nag {14 16 18 20} {
		ttk::spinbox $top.spb$nag \
			-from 0.0 \
			-to 999.0 \
			-width 5 \
			-increment 0.01 \
			-justify right \
			-takefocus 1 \
			-textvar [namespace current]::Score_($nag) \
			-exportselection no \
			;
		::theme::configureSpinbox $top.spb$nag
		::validate::spinboxDouble $top.spb$nag
		grid $top.spb$nag -row 3 -column [incr col 2] -sticky ew
	}

	set values {0.45 0.75 1.75 4.00}
	set btn [ttk::button $top.scidb \
		-style aligned.TButton \
		-text "Scidb" \
		-command [namespace code [list SetEdgeValues $top $values]] \
	]
	grid $btn -row 5 -column 1 -sticky w
	set col 1
	foreach nag {14 16 18 20} score $values {
		set score [::locale::formatDouble $score]
		grid [ttk::label $top.scidb$nag -text "$score  " -anchor e] -row 5 -column [incr col 2] -sticky ew
	}

	set values {0.50 1.50 3.00 5.50}
	set btn [ttk::button $top.scid \
		-style aligned.TButton \
		-text "Scid" \
		-command [namespace code [list SetEdgeValues $top $values]] \
	]
	grid $btn -row 7 -column 1 -sticky w
	set col 1
	foreach nag {14 16 18 20} score $values {
		set score [::locale::formatDouble $score]
		grid [ttk::label $top.scid$nag -text "$score  " -anchor e] -row 7 -column [incr col 2] -sticky ew
	}

	set values {0.35 0.70 1.60 \u2014}
	set btn [ttk::button $top.cb \
		-style aligned.TButton \
		-text "ChessBase" \
		-command [namespace code [list SetEdgeValues $top $values]] \
	]
	grid $btn -row 9 -column 1 -sticky w
	set col 1
	foreach nag {14 16 18 20} score $values {
		if {[string is double $score]} { set score [::locale::formatDouble $score] }
		grid [ttk::label $top.cb$nag -text "$score  " -anchor e] -row 9 -column [incr col 2] -sticky ew
	}

	grid columnconfigure $top {2 4 6 8} -minsize $::theme::padx
	grid columnconfigure $top {0 10} -minsize $::theme::padY
	grid rowconfigure $top {2 6 8} -minsize $::theme::pady
	grid rowconfigure $top {4} -minsize [expr {3*$::theme::pady}]
	grid rowconfigure $top {0 10} -minsize $::theme::padX

	::widget::dialogButtons $dlg {save cancel} -default save
	$dlg.save   configure -command [namespace code [list SaveEvalRanges $dlg]]
	$dlg.cancel configure -command [list destroy $dlg]

	wm protocol $dlg WM_DELETE_WINDOW [$dlg.cancel cget -command]
	wm resizable $dlg false false
	wm transient $dlg .application
	wm title $dlg $mc::SetupEvalEdges
	::util::place $dlg -parent [winfo parent [winfo parent $tree]] -position above-or-below
	focus $top.spb14
	$top.spb14 selection range 0 end
	wm deiconify $dlg
}


proc SetEdgeValues {w values} {
	variable Score_

	foreach score $values nag {14 16 18 20} {
		if {[string is double $score]} { set Score_($nag) [::locale::formatSpinboxDouble $score] }
	}
}


proc SaveEvalRanges {dlg} {
	variable ScoreEdgeValues
	variable GlobalOptions
	variable Score_

	set score -1.0
	foreach nag {14 16 18 20} {
		if {[::locale::toDouble $Score_($nag)] <= $score} {
			return [::dialog::error \
				-parent $dlg \
				-message $mc::InvalidEdgeValues \
				-detail $mc::MustBeAscending \
			]
		}
	}

	set GlobalOptions(eval:edges) {}
	set ScoreEdgeValues {}

	foreach nag1 {14 16 18 20} nag2 {10 14 16 18} {
		set score [expr {int([::locale::toDouble $Score_($nag1)]*100)}]
		lappend GlobalOptions(eval:edges) $score
		lappend ScoreEdgeValues $score $nag2
	}

	destroy $dlg
}


proc WriteOptions {chan} {
	foreach ns [namespace children [namespace current]] {
		if {[string match {*[0-9]} $ns]} {
			if {[set number [[namespace parent]::mapToTerminalNumber $ns]] >= 0} {
				namespace eval ${number} {}
				array set ${number}::Options_ [array get ${ns}::Options]
			}
		}
	}
	foreach ns [namespace children [namespace current]] {
		if {[array exists ${ns}::Options_]} {
			array set ${ns}::Options [array get ${ns}::Options_]
		}
	}
	foreach ns [namespace children [namespace current]] {
		if {[string match {*[0-9]} $ns]} {
			::options::writeEvalNS $chan $ns
			::options::writeItem $chan ${ns}::Options
		}
	}
	::options::writeItem $chan [namespace current]::GlobalOptions
}
::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 16x16 {

set append [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAL
	EwAACxMBAJqcGAAAAAd0SU1FB90LBAgQO28cqdoAAACHUExURQAAAAUYaQQUWAQVXAQUWAQVXAUW
	XwUWXwYXYg0eaQ0gcw4hdA8gaxEibREkdxIleBMlcRYmdhYpfBcpdxgrfhwtgB4xhCIyhiU1iSg4
	jCs7jyw8kDNElzpInjtJn0FPpUJQpkJRrEhWqkhWrE1br09bsVRftFRiulVht1VhuVxnvF5qwv//
	/63/nPcAAAAIdFJOUwABqqqtr+PkLJGxYQAAAAFiS0dELLrdcasAAABoSURBVBgZBcExTgRBEAQw
	99Ap4kj4/w9BgnCnCnvA+Tjy+8CC+Vr5m2KB1gUWSARYIFeAPYO3jJyDzvsnDA58r0IRuNsCgO69
	MKOFO2ewr9GfB91gktGkWOAeARZ4RoEFnlFgoQ1a+AfIKzUdQvXMkAAAAABJRU5ErkJggg==
}]

set insert [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAL
	EwAACxMBAJqcGAAAAAd0SU1FB90LBQcrFqWROs8AAACHUExURQAAAGkFR1gEO1wEPlgEO1wEPl8F
	QF8FQGIGQ2kNSmsPTG0RTnETUXMNUHQOUXYWU3cRVHcXVngSVXwWWX4YW4AcW4QeYYYiYoklZYwo
	aI8ra5AsbJczc546d587eKVBfqZCf6pIhKxCg6xIha9NibFPibRUjbdVj7lVkLpUkrxclcJemf//
	/3Pft5wAAAAIdFJOUwABqqqtr+PkLJGxYQAAAAFiS0dELLrdcasAAABrSURBVBgZBcGxjQJQDAUw
	55PuhIREx/5rsQAVzVWQPOwC53rs/xca1OOYZwUNTFmggR0LNDBlgD6FS1bOQervDoULvFogWEgn
	ACCdgSoJpE6hbyXvL9KL2i3ZDRrYEqCBORZoYFaAhuSDBH7XhjUH+TKbOQAAAABJRU5ErkJggg==
}]

} ;# namespace 16x16
namespace eval 11x14 {

set arrowLeft [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAsAAAAOCAYAAAD5YeaVAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A
	/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB90LBQoSNHatZcIAAAA/SURBVCjP
	ldEhEgAgDAPBGxQ/xiL5dVBlcHBRFSvaBt4ZfGYCMTAGxsAYGAMPbhfuyHyvoQ/Ur9Ol6Lorq4YN
	lP4qZoNcRJIAAAAASUVORK5CYII=
}]

set arrowRight [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAsAAAAOCAYAAAD5YeaVAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A
	/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB90LBQoTD969vacAAABISURBVCjP
	Y2BAgHIGAoAZiX2EgYGBkYGB4QADEeA/FDeQopgoDf9J0fCfFA3/CWlgIsIvHFR3RgPVg47oSCFK
	IQMDA0MHIQUAVuEqb7IfnCgAAAAASUVORK5CYII=
}]

} ;# namespace 11x14
} ;# namespace icon
} ;# namespace analysis
} ;# namespace application

# vi:set ts=3 sw=3:
