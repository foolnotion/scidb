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

namespace eval application {
namespace eval board {
namespace eval mc {

set ShowCrosstable		"Show tournament table for this game"

set Tools					"Tools"
set Control					"Control"
set GoIntoNextVar			"Go into next variation"
set GoIntPrevVar			"Go into previous variation"

set KeyEditAnnotation	"A"
set KeyEditComment		"C"
set KeyEditMarks			"M"

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::abs

variable board {}

variable Index		-1
variable Vars
variable Toolbar
variable Dim

set Defaults(coords-font-family) [font configure TkDefaultFont -family]


proc build {w menu width height} {
	variable Dim
	variable Vars
	variable board

	Preload $width $height

	set canv [tk::canvas $w.c -width $width -height $height -takefocus 1 -borderwidth 0]
	pack $canv -fill both -expand yes
	$canv xview moveto 0
	$canv yview moveto 0
	SetBackground $canv window $width $height
	set border [tk::canvas $canv.border -takefocus 0 -borderwidth 0]
	$border xview moveto 0
	$border yview moveto 0
	set board [::board::stuff::new $border.board $Dim(squaresize) $Dim(edgethickness)]
	$canv create window 0 0 -window $border -anchor nw -tag board
	$border create window 0 0 -window $board -anchor nw -tag board
	set Vars(widget:border) $border
	set Vars(widget:frame) $canv
	set Vars(widget:parent) $w
	set Vars(autoplay) 0
	set Vars(active) 0
	$board configure -cursor crosshair
	bind $canv <Configure> [namespace code { ConfigureWindow %W %w %h }]
	bind $canv <Destroy> [namespace code [list activate $w $menu 0]]
	bind $canv <FocusIn> [namespace code { GotFocus %W }]

	::board::stuff::bind $board all <Enter>				{ ::move::enterSquare %q }
	::board::stuff::bind $board all <Leave>				{ ::move::leaveSquare %q }
	::board::stuff::bind $board all <ButtonPress-1>		{ ::move::pressSquare %q %s }
	::board::stuff::bind $board all <ButtonPress-1>		{+focus %W }
	::board::stuff::bind $board all <ButtonRelease-1>	{ ::move::releaseSquare %X %Y %s }
	::board::stuff::bind $board all <Button1-Motion>	{ ::move::dragPiece %X %Y }

	::board::stuff::bind $board all <Control-ButtonPress-1>		{ ::marks::pressSquare %X %Y }
	::board::stuff::bind $board all <Control-ButtonPress-1>		{+ ::move::disable }
	::board::stuff::bind $board all <Control-ButtonRelease-1>	{ ::marks::unpressSquare }

	bind .application <<ControlOn>>	{ ::move::disable }
	bind .application <<ControlOff>>	{ ::move::enable %X %Y }
	bind .application <<ControlOff>>	{+ ::marks::releaseSquare }
	bind .application <FocusOut>		{ ::move::enable }
	bind .application <FocusOut>		{+ ::marks::releaseSquare }

	::board::stuff::update $board standard
	::board::unregisterSize $Dim(squaresize)

	set tbTools		[::toolbar::toolbar $w -hide 1 -id tools -tooltipvar [namespace current]::mc::Tools]
	set tbLayout	[::toolbar::toolbar $w -hide 1 -id layout -tooltipvar ::mc::Layout]
	set tbControl	[::toolbar::toolbar $w \
							-hide 1 \
							-id control \
							-tooltipvar [namespace current]::mc::Control \
							-orientation bottom \
							-alignment center]

	set main [winfo parent $w]

#	::toolbar::add $tbTools button -image $::icon::toolbarGameList			-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarGameNotation	-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarMaintenance		-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarEcoBrowser		-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarTreeWindow		-command {}

	set Vars(crossTable) [::toolbar::add $tbTools button \
		-image $::icon::toolbarCrossTable \
		-command [namespace code [list ShowCrossTable [winfo toplevel $board]]] \
		-tooltipvar [namespace current]::mc::ShowCrosstable \
	]
#	::toolbar::add $tbTools button \
#		-image $::icon::toolbarEngine \
#		-command [namespace code StartAnalysis] \
#		;

	::toolbar::add $tbLayout button \
		-image $::icon::toolbarRotateBoard \
		-tooltipvar ::overview::mc::RotateBoard \
		-command [namespace code [list Rotate $canv] \
	]
	::toolbar::add $tbLayout checkbutton \
		-image $::icon::toolbarSideToMove \
		-variable ::board::layout(side-to-move) \
		-tooltipvar ::board::options::mc::ShowSideToMove \
		-command [namespace code [list ToggleSideToMove $canv] \
	]

	foreach {action key tipvar} {	GotoStart Home		GotoStartOfGame
											FastBack  Prior	GoBackFast
											Back      Left		GoBackward
											Fwd       Right	GoForward
											FastFwd   Next		GoForwardFast
											GotoEnd   End		GotoEndOfGame} {
		set Vars([string tolower $action 0]) \
			[::toolbar::add $tbControl button \
				-state disabled \
				-tooltipvar ::browser::mc::$tipvar \
				-image [set ::icon::toolbarCtrl${action}] \
				-command [namespace code Go$key]]
	}

	::toolbar::addSeparator $tbControl
	set Vars(enterVar) [::toolbar::add $tbControl button \
		-state disabled \
		-tooltipvar [namespace current]::mc::GoIntoNextVar \
		-image [set ::icon::toolbarCtrlEnterVar] \
		-command [namespace code GoDown]]
	set Vars(leaveVar) [::toolbar::add $tbControl button \
		-state disabled \
		-tooltipvar [namespace current]::mc::GoIntPrevVar \
		-image [set ::icon::toolbarCtrlLeaveVar] \
		-command [namespace code GoUp]]
	
	Bind <Left>				[namespace code GoLeft]
	Bind <Right>			[namespace code GoRight]
	Bind <Prior>			[namespace code GoPrior]
	Bind <Next>				[namespace code GoNext]
	Bind <Home>				[namespace code GoHome]
	Bind <End>				[namespace code GoEnd]
	Bind <Down>				[namespace code GoDown]
	Bind <Up>				[namespace code GoUp]
	Bind <Control-Down>	[namespace code LoadNext]
	Bind <Control-Up>		[namespace code LoadPrevious]
	Bind <<Undo>>			[namespace parent]::pgn::undo
	Bind <<Redo>>			[namespace parent]::pgn::redo
	Bind <ButtonPress-3>	[namespace code { PopupMenu %W }]

	for {set i 1} {$i <= 9} {incr i} {
		Bind <Key-$i>    [namespace code [list [namespace parent]::pgn::selectAt [expr {$i - 1}]]]
		# NOTE: the working of the following depends on actual keyboard bindings!
		Bind <Key-KP_$i> [namespace code [list [namespace parent]::pgn::selectAt [expr {$i - 1}]]]
	}

	Bind <Shift-Up>		[list [namespace parent]::pgn::scroll -1 units]
	Bind <Shift-Down>		[list [namespace parent]::pgn::scroll +1 units]
	Bind <Shift-Prior>	[list [namespace parent]::pgn::scroll -1 pages]
	Bind <Shift-Next>		[list [namespace parent]::pgn::scroll +1 pages]
	Bind <Shift-Home>		[list [namespace parent]::pgn::scroll -9999 pages]
	Bind <Shift-End>		[list [namespace parent]::pgn::scroll +9999 pages]

	set Vars(after) {}
	set Vars(key:annotation) $mc::KeyEditAnnotation
	set Vars(key:comment) $mc::KeyEditComment
	set Vars(key:marks) $mc::KeyEditMarks

	LanguageChanged
	Bind <<LanguageChanged>> [namespace code LanguageChanged]

	BuildBoard $canv
	ConfigureBoard $canv

	::scidb::db::subscribe gameSwitch [namespace current]::GameSwitched
}


proc activate {w menu flag} {
	variable Toolbar
	variable Index
	variable Vars

	set Vars(active) $flag
	::toolbar::activate $w $flag

	if {$flag} {
		focus $Vars(widget:frame)
	} elseif {$Index >= 0 && [winfo exists $menu]} {
		$menu delete $Index
	}

	[namespace parent]::pgn::activate $w $menu $flag
}


proc setFocus {} {
	focus [set [namespace current]::Vars(widget:frame)]
}


proc active? {} {
	return [set [namespace current]::Vars(active)]
}


proc goto {step} {
	variable ::browser::Options
	variable Vars

	::scidb::game::go -1 $step

	if {$Vars(autoplay)} {
		if {[::scidb::game::position -1 atEnd?]} {
			ToggleAutoPlay
		} else {
			after cancel $Vars(afterid)
			set Vars(afterid) [after $Options(autoplayDelay) [namespace code { Goto +1 }]]
		}
	}
}


proc update {position cmd data} {
	variable ::board::layout
	variable Vars
	variable board

	switch $cmd {
		set	{ ::board::stuff::update $board $data }
		move	{ ::board::stuff::move $board $data }
	}

	UpdateSideToMove $Vars(widget:frame)
	DrawMaterialValues $Vars(widget:frame)
	UpdateControls
}


proc updateMarks {marks} {
	variable board
	variable Vars

	::board::stuff::updateMarks $board $marks
	if {!$Vars(autoplay)} {
		::move::leaveSquare
		::move::enterSquare
	}
}


proc GoLeft 	{} { goto -1 }
proc GoRight	{} { goto +1 }
proc GoPrior	{} { goto -10 }
proc GoNext		{} { goto +10 }
proc GoHome		{} { goto start }
proc GoEnd		{} { goto end }
proc GoDown		{} { goto down }
proc GoUp		{} { goto up }


proc LoadNext		{} { ;# TODO load next game from last used view }
proc LoadPrevious	{} { ;# TODO }


proc GotFocus {w} {
	# we have to skip the focus if no game is open
	if {[::application::pgn::empty?]} { focus [::tk_focusNext $w] }
}


proc Bind {key cmd} {
	variable Vars
	variable board

	bind $Vars(widget:frame) $key $cmd
	bind $Vars(widget:border) $key $cmd
	bind $Vars(widget:frame) $key {+ break }
	bind $Vars(widget:border) $key {+ break }
	::board::stuff::bind $board $key $cmd
}


proc Preload {width height} {
	variable Attr
	variable Dim

	set Dim(bordersize) 0
	set Dim(fontsize) 0
	ComputeLayout $width $height

	::board::registerSize $Dim(squaresize)
	::board::setupSquares $Dim(squaresize)
	::board::setupPieces $Dim(squaresize)
}


proc ConfigureWindow {w width height} {
	variable Vars

	set Vars(width) $width
	set Vars(height) $height
	after cancel $Vars(after)
	set Vars(after) [after 100 [namespace code [list RebuildBoard $w $width $height]]]
}


proc SetBackground {canv which {width 0} {height 0}} {
	variable ::board::colors

	if {[llength $colors(hint,background-color)]} {
		$canv configure -background $colors(hint,background-color)
	} else {
		::theme::configureBackground $canv
	}

	::board::setBackground $canv window $width $height
}


proc PopupMenu {w} {
	variable Vars

	set m $w.popup_menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }

	$m add command \
		-compound left \
		-image $::icon::16x16::rotateBoard \
		-label $::overview::mc::RotateBoard \
		-command [namespace code [list Rotate $Vars(widget:frame)]] \
		;
	$m add command \
		-compound left \
		-image $::icon::16x16::checker \
		-label " $::setup::board::mc::SetStartBoard..." \
		-command [namespace code [list SetStartBoard $Vars(widget:frame)]] \
		;
	$m add command \
		-compound left \
		-image $::icon::16x16::checker \
		-label " $::setup::position::mc::SetStartPosition..." \
		-command [namespace code [list SetStartPosition $Vars(widget:frame)]] \
		;
	if {[::board::options::isOpen]} { set state disabled } else { set state normal }
	$m add command \
		-compound left \
		-image $::icon::16x16::setup \
		-label " $::board::options::mc::BoardSetup..." \
		-command [list ::board::options::openConfigDialog $w \
			[list [namespace current]::Apply $Vars(widget:frame)]] \
		-state $state \
		;
	
	$m add separator

	$m add checkbutton \
		-label $::board::options::mc::ShowSideToMove \
		-variable ::board::layout(side-to-move) \
		-command [namespace code [list Apply $Vars(widget:frame)]] \
		;
	$m add checkbutton \
		-label $::board::options::mc::ShowMaterialValues \
		-variable ::board::layout(material-values) \
		-command [namespace code [list Apply $Vars(widget:frame)]] \
		;
	$m add checkbutton \
		-label $::board::options::mc::ShowBar \
		-variable ::board::layout(material-bar) \
		-state [expr {$::board::layout(material-values) ? "normal" : "disabled"}] \
		-command [namespace code [list Apply $Vars(widget:frame)]] \
		;
	$m add checkbutton \
		-label $::board::options::mc::ShowBorder \
		-variable ::board::layout(border) \
		-command [namespace code [list Apply $Vars(widget:frame)]] \
		;
	$m add checkbutton \
		-label $::board::options::mc::ShowCoordinates \
		-variable ::board::layout(coordinates) \
		-command [namespace code [list Apply $Vars(widget:frame)]] \
		;
	$m add checkbutton \
		-label $::board::options::mc::ShowSuggestedMove \
		-variable ::board::hilite(show-suggested) \
		-command [namespace code [list Apply $Vars(widget:frame)]] \
		;
	tk_popup $m {*}[winfo pointerxy $w]
}


proc Apply {canv} {
	variable Vars
	RebuildBoard $canv $Vars(width) $Vars(height)
}


proc RebuildBoard {canv width height} {
	variable Dim
	variable Vars
	variable board

	set squareSize $Dim(squaresize)
	set edgeThickness $Dim(edgethickness)
	ComputeLayout $width $height $Dim(bordersize)
	SetBackground $canv window $width $height
	$canv coords board $Dim(border:x1) $Dim(border:y1)
	$Vars(widget:border) coords board $Dim(borderthickness) $Dim(borderthickness)
	set bordersize [expr {$Dim(bordersize) + $Dim(border:gap)}]
	$Vars(widget:border) configure -width $bordersize -height $bordersize

	if {$Dim(border:gap) > 0} {
		$Vars(widget:border) configure -background black
	} else {
		$Vars(widget:border) configure -background [$canv cget -background]
	}

	BuildBoard $canv
	ConfigureBoard $canv
	DrawMaterialValues $canv

	if {$squareSize != $Dim(squaresize) || $edgeThickness != $Dim(edgethickness)} {
		::update idletasks
		::board::stuff::resize $board $Dim(squaresize) $Dim(edgethickness)
	} else {
		::board::stuff::rebuild $board
	}
}


proc DrawMaterialValues {canv} {
	variable ::board::layout

	if {!$layout(material-values)} { return }

	$canv delete material
	lassign [::scidb::game::material] p n b r q

	# match knights and bishops
	for {} {$n < 0 && $b > 0} {incr b -1} {incr n}
	for {} {$b < 0 && $n > 0} {incr n -1} {incr b}

	set sum [expr {abs($p) + abs($n) + abs($b) + abs($r) + abs($q)}]
	set rank 0

	AddMaterial $q "q" $canv $rank $sum; incr rank [abs $q]
	AddMaterial $r "r" $canv $rank $sum; incr rank [abs $r]
	AddMaterial $b "b" $canv $rank $sum; incr rank [abs $b]
	AddMaterial $n "n" $canv $rank $sum; incr rank [abs $n]
	AddMaterial $p "p" $canv $rank $sum
}


proc AddMaterial {count piece canv rank sum} {
	variable Dim

	if {$count == 0} { return }

	set dist	[expr {$Dim(piece)/8}]
	set gap	[expr {$Dim(piece)/4}]
	set offs	[expr {$Dim(piece) + $gap}]
	set size	[expr {$sum*$Dim(piece) + ($sum - 1)*$gap}]
	set x		[expr {$Dim(border:x2) + $Dim(gap) + ($Dim(stm) - $Dim(piece) - $dist)/2 + 1}]
	set y		[expr {$Dim(mid:y) - $size/2 + $rank*$offs}]
	set res	${Dim(piece)}x${Dim(piece)}

	if {$count < 0} {
		set color "b"
		set count [abs $count]
	} else {
		set color "w"
	}

	for {set i 0} {$i < $count} {incr i} {
		set n [expr {$i + $rank}]
		$canv create image $x $y \
			-image [set ::icon::${res}::piece(${color}${piece})] \
			-tags [list material mv$n] \
			-anchor nw
		incr y $offs
	}
}


proc ComputeLayout {canvWidth canvHeight {bordersize -1}} {
	variable ::board::layout
	variable Dim
	variable Vars

	if {$bordersize > 0} {
		::update idletasks
	}

	set distance		[expr {max(1, min($canvWidth, $canvHeight)/150)}]
	set width			[expr {$canvWidth - 2*$distance}]
	set height			[expr {$canvHeight - 2*$distance}]

	if {$layout(side-to-move) || $layout(material-values)} {
		if {$layout(side-to-move)} { set minsize 64 } else { set minsize 34 }
		set Dim(stm)	[expr {max(18, min($minsize, (min($canvWidth, $canvHeight) - 19)/32 + 5))}]
		set Dim(gap)	[expr {max(7, $Dim(stm)/3)}]
	} else {
		set Dim(stm)	0
		set Dim(gap)	0
	}

	if {$layout(border) && $layout(coordinates)} {
		set Dim(borderthickness) [expr {min(36, max(12, int(min($width, $height)/24.0 + 0.5)))}]
		set Dim(offset) $Dim(borderthickness)
	} elseif {$layout(border)} {
		set Dim(borderthickness) 12
		set Dim(offset) 12
	} elseif {$layout(coordinates)} {
		set Dim(borderthickness) 0
		set Dim(offset) [expr {min(36, max(12, int(min($width, $height)/24.0 + 0.5)))}]
	} else {
		set Dim(borderthickness) 0
		set Dim(offset) 0
	}

	if {$layout(border)} {
		set width [expr {$width - 2*$Dim(borderthickness) - 2*($Dim(stm) + $Dim(gap))}]
	} else {
		set width [expr {$width - max(2*$Dim(offset), 2*($Dim(stm) + $Dim(gap)))}]
	}

	set height					[expr {$height - 2*$Dim(offset)}]
	set boardsize				[expr {min($width, $height)}]
	set Dim(edgethickness)	[expr {$Dim(borderthickness) ? 0 : ($boardsize/8 < 65 ? 1 : 2)}]
	set Dim(squaresize)		[expr {($boardsize - 2*$Dim(edgethickness))/8}]
	set Dim(border:gap)		[::board::computeGap $Dim(squaresize)]

	if {$Dim(border:gap) > 0} {
		if {[::board::borderlineGap] > 0 || $layout(border)} {
			set Dim(border:gap)		0
		} else {
			set height					[expr {$height - $Dim(border:gap)}]
			set width					[expr {$width - $Dim(border:gap)}]
			set boardsize				[expr {min($width, $height)}]
			set Dim(squaresize)		[expr {$boardsize/8}]
			set Dim(edgethickness)	0
		}
	}

	set Dim(boardsize)		[expr {8*$Dim(squaresize) + 2*$Dim(edgethickness)}]
	set Dim(bordersize)		[expr {$Dim(boardsize) + 2*$Dim(borderthickness)}]
	set Dim(border:x1)		[expr {($canvWidth - $Dim(bordersize))/2}]
	set Dim(border:y1)		[expr {($canvHeight - $Dim(bordersize))/2}]
	set Dim(border:x2)		[expr {$Dim(border:x1) + $Dim(bordersize)}]
	set Dim(border:y2)		[expr {$Dim(border:y1) + $Dim(bordersize)}]
	set Dim(mid:y)				[expr {$Dim(border:y1) + $Dim(bordersize)/2}]

	if {$bordersize != -1 && $Dim(bordersize) != $bordersize} {
		$Vars(widget:frame) delete stm
		$Vars(widget:border) delete shadow
		$Vars(widget:border) delete mvbar mv
	}

	if {$Dim(stm) < 24} {
		set Dim(piece) 16
	} elseif {$Dim(stm) < 34} {
		set Dim(piece) 22
	} else {
		set Dim(piece) 32
	}
}


proc ConfigureBoard {canv} {
	variable ::board::layout
	variable ::board::colors
	variable Dim
	variable Vars
	variable board

	set border $Vars(widget:border)

	# configure border #############################
	set state hidden
	if {$layout(border)} { set state normal }
	$border itemconfigure -state $state

	# configure side to move #######################
	if {$layout(side-to-move)} {
		if {[::board::stuff::flipped? $board]} {
			set stmw stmb
			set stmb stmw
		} else {
			set stmw stmw
			set stmb stmb
		}
		set x [expr {$Dim(border:x2) + $Dim(gap)}]
		set y [expr {$Dim(border:y1) + $Dim(gap)}]
		$canv coords $stmb $x $y
		set y [expr {$Dim(border:y2) - $Dim(stm) - $Dim(gap)}]
		$canv coords $stmw $x $y
		$canv raise stm
	}
	$canv itemconfigure stmb -state hidden
	$canv itemconfigure stmw -state hidden
	UpdateSideToMove $canv

	# configure material bar #######################
	$canv delete material

	set state hidden
	if {$layout(material-values) && $layout(material-bar)} {
		set dist [expr {$Dim(piece)/8}]
		set x3 [expr {$Dim(border:x2) + $Dim(gap) + ($Dim(stm) - $Dim(piece) - $dist)/2}]
		set x4 [expr {$x3 + $Dim(piece) + $dist}]

		if {$layout(side-to-move)} {
			set y3 [expr {$Dim(border:y1) + $Dim(stm) + 2*$Dim(gap) + 1}]
			set y4 [expr {$Dim(border:y2) - $Dim(stm) - 2*$Dim(gap) - 1}]
		} else {
			set y3 [expr {$Dim(border:y1) + $Dim(edgethickness)}]
			set y4 [expr {$Dim(border:y2) - $Dim(edgethickness)}]
		}

		$canv coords mvbar1 $x3 $y3 $x4 $y4
		incr x3; incr y3
		$canv coords mvbar2 $x3 $y3 $x4 $y4
		incr x4 -1; incr y4 -1
		$canv coords mvbar3 $x3 $y3 $x4 $y4

		$canv raise mvbar
		set state normal
	}

	$canv itemconfigure mvbar1 -state $state
	$canv itemconfigure mvbar2 -state $state
	$canv itemconfigure mvbar3 -state $state

	# configure coordinates ########################
	if {$layout(coordinates)} {
		if {$layout(border)} { set w $border } else { set w $canv }
		$w itemconfigure ncoords -state normal
		set size $Dim(offset)
		if {$layout(border)} { incr size -4 }
		set font [ComputeFont $w $size]
	}
	$canv itemconfigure coords -state hidden
	$border itemconfigure coords -state hidden
	if {$layout(coordinates)} {
		if {$layout(border)} { set w $border } else { set w $canv }
		$w itemconfigure ncoords -state normal -fill $colors(hint,coordinates)
		$w itemconfigure coords -font $font
		if {$layout(coords-embossed)} {
			scan $colors(hint,coordinates) "\#%2x%2x%2x" r g b
			set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
			if {$luma >= 128} { $w itemconfigure bcoords -state normal -fill black }
			if {$luma <  128} { $w itemconfigure wcoords -state normal -fill white }
		} else {
			$w itemconfigure bcoords -state normal -fill gray48
		}
		if {$layout(border)} {
			set x [expr {$Dim(offset)/2 + 1}]
			set y [expr {$Dim(offset) + $Dim(squaresize)/2}]
		} else {
			set x [expr {$Dim(border:x1) - $Dim(offset)/2 - $Dim(edgethickness)}]
			set y [expr {$Dim(border:y1) + $Dim(edgethickness) + $Dim(squaresize)/2}]
		}
		set columns {8 7 6 5 4 3 2 1}
		set rows {A B C D E F G H}
		if {[::board::stuff::flipped? $board]} {
			set columns [lreverse $columns]
			set rows [lreverse $rows]
		}
		foreach r $columns {
			foreach {k offs} {w -1 b 1 {} 0} {
				$w coords ${k}coord${r} [expr {$x + $offs}] [expr {$y + $offs}]
			}
			incr y $Dim(squaresize)
		}
		if {$layout(border)} {
			set x [expr {$Dim(offset) + $Dim(squaresize)/2}]
			set y [expr {$Dim(bordersize) - $Dim(offset)/2 - 2}]
		} else {
			set x [expr {$Dim(border:x1) + $Dim(edgethickness) + $Dim(squaresize)/2}]
			set y [expr {$Dim(border:y2) + $Dim(edgethickness) + $Dim(offset)/2}]
		}
		foreach c $rows {
			foreach {k offs} {w -1 b 1 {} 0} {
				$w coords ${k}coord${c} [expr {$x + $offs}] [expr {$y + $offs}]
			}
			incr x $Dim(squaresize)
		}
	}
}


proc ComputeFont {w size} {
	variable Defaults
	variable Dim

	set delta [expr {min(7, int(($size - 10)/3.0 + 0.5) + 2)}]
	if {$Dim(fontsize) == $size} { return $Dim(font) }
	set size [max 6 $size]
	set Dim(fontsize) $size

	while {$size >= 6} {
		set Dim(font) [list $Defaults(coords-font-family) $size]
		$w itemconfigure coordA -font $Dim(font)
		lassign [$w bbox coordA] x1 y1 x2 y2
		set Dim(font-width) [expr {$x2 - $x1}]
		set Dim(font-height) [expr {$y2 - $y1}]
		set dx [expr {$Dim(offset) - $Dim(font-width) - $delta}]
		set dy [expr {$Dim(offset) - $Dim(font-height) - $delta}]
		if {$dx >= 0 && $dy >= 0} { return $Dim(font) }
		incr size [expr {min(-1, min($dx, $dy)/2)}]
	}

	return $Dim(font)
}


proc BuildBoard {canv} {
	variable ::board::layout
	variable ::board::colors
	variable stmWhite
	variable stmBlack
	variable Dim
	variable Vars

	set border $Vars(widget:border)

	# border #######################################
	if {$layout(border)} {
		::board::setBackground $border border
		if {[llength $colors(hint,border-color)]} {
			$border configure -background $colors(hint,border-color)
		}
		if {[llength [$border find withtag shadow]] == 0} {
			::board::stuff::drawBorderlines $border $Dim(bordersize)
		}
	}

	# side to move #################################
	if {$layout(side-to-move) && [llength [$canv find withtag stm]] == 0} {
		catch { image delete [namespace current]::Stm(white) }
		catch { image delete [namespace current]::Stm(black) }
		image create photo [namespace current]::Stm(white) -width $Dim(stm) -height $Dim(stm)
		image create photo [namespace current]::Stm(black) -width $Dim(stm) -height $Dim(stm)
		::scidb::tk::image copy $stmWhite [namespace current]::Stm(white)
		::scidb::tk::image copy $stmBlack [namespace current]::Stm(black)
		$canv create image 0 0 -image [namespace current]::Stm(black) -tags {stm stmb} -anchor nw
		$canv create image 0 0 -image [namespace current]::Stm(white) -tags {stm stmw} -anchor nw
	}

	# material bar #################################
	$canv delete mvbar mv
	if {$layout(material-values) && $layout(material-bar) && [llength [$canv find withtag mv]] == 0} {
		$canv create rectangle 0 0 0 0 -fill white -width 0 -tags {mvbar mvbar1}
		$canv create rectangle 0 0 0 0 -fill black -width 0 -tag {mvbar mvbar2}
		$canv create rectangle 0 0 0 0  -fill #e6e6e6 -width 0 -tag {mvbar mvbar3}
	}

	# coordinates ##################################
	if {$layout(coordinates) && [llength [$border find withtag coords]] == 0} {
		foreach w [list $canv $border] {
			foreach r {1 2 3 4 5 6 7 8} {
				$w create text 0 0 -justify right -text $r -tags [list coords wcoords wcoord$r]
				$w create text 0 0 -justify right -text $r -tags [list coords bcoords bcoord$r]
				$w create text 0 0 -justify right -text $r -tags [list coords ncoords coord$r]
			}
			foreach c {A B C D E F G H} {
				$w create text 0 0 -text $c -tags [list coords wcoords wcoord$c]
				$w create text 0 0 -text $c -tags [list coords bcoords bcoord$c]
				$w create text 0 0 -text $c -tags [list coords ncoords coord$c]
			}
		}
	}
}


proc Rotate {canv} {
	variable board

	::board::stuff::rotate $board
	ConfigureBoard $canv
}


proc SetStartBoard {canv} {
	::setup::board::open [winfo toplevel $canv]
}


proc SetStartPosition {canv} {
	::setup::position::open [winfo toplevel $canv]
}


proc ToggleSideToMove {canv} {
	variable ::board::layout

	set layout(side-to-move) [expr {!$layout(side-to-move)}]
	Apply $canv
}


proc UpdateSideToMove {canv} {
	variable ::board::layout
	variable Vars

	if {$layout(side-to-move)} {
		if {[::scidb::game::ply] % 2} { set color b } else { set color w }
		if {$color eq "w"} { set other b} else { set other w }
		$canv itemconfigure stm$color -state normal
		$canv itemconfigure stm$other -state hidden
	}
}


proc UpdateControls {} {
	variable Vars

	set level [::scidb::game::level]

	if {[::scidb::game::position -1 atStart?]} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(back) -state $state
	::toolbar::childconfigure $Vars(fastBack) -state $state
	if {$level} { set state normal }
	::toolbar::childconfigure $Vars(gotoStart) -state $state

	if {[::scidb::game::position -1 atEnd?]} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(fwd) -state $state
	::toolbar::childconfigure $Vars(fastFwd) -state $state
	if {$level} { set state normal }
	::toolbar::childconfigure $Vars(gotoEnd) -state $state

	if {$level == 0} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(leaveVar) -state $state

	if {[::scidb::game::variation count]} { set state normal } else { set state disabled }
	::toolbar::childconfigure $Vars(enterVar) -state $state
}


proc StartAnalysis {} {
	puts "StartAnalysis"
}


proc GameSwitched {position} {
	variable Vars
	variable ::scidb::scratchbaseName

	if {[lindex [::scidb::game::link?] 0] eq $scratchbaseName} {
		set state disabled
	} else {
		set state normal
	}

	::toolbar::childconfigure $Vars(crossTable) -state $state
}


proc ShowCrossTable {parent} {
	set base [::scidb::game::query database]
	set index [::scidb::game::index]
	::crosstable::open .application $base $index -1 game
}


proc LanguageChanged {} {
	variable Vars

	Bind <Control-[string tolower $Vars(key:annotation)]> {}
	Bind <Control-[string toupper $Vars(key:annotation)]> {}
	Bind <Control-[string tolower $Vars(key:comment)]> {}
	Bind <Control-[string toupper $Vars(key:comment)]> {}
	Bind <Control-Shift-[string tolower $Vars(key:comment)]> {}
	Bind <Control-Shift-[string toupper $Vars(key:comment)]> {}
	Bind <Control-[string tolower $Vars(key:marks)]> {}
	Bind <Control-[string toupper $Vars(key:marks)]> {}

	Bind <Control-[string tolower $mc::KeyEditAnnotation]> [namespace parent]::pgn::editAnnotation
	Bind <Control-[string toupper $mc::KeyEditAnnotation]> [namespace parent]::pgn::editAnnotation
	Bind <Control-[string tolower $mc::KeyEditComment]> [list [namespace parent]::pgn::editComment p]
	Bind <Control-[string toupper $mc::KeyEditComment]> [list [namespace parent]::pgn::editComment p]
	Bind <Control-Shift-[string tolower $mc::KeyEditComment]> \
		[list [namespace parent]::pgn::editComment a]
	Bind <Control-Shift-[string toupper $mc::KeyEditComment]> \
		[list [namespace parent]::pgn::editComment a]
	Bind <Control-[string tolower $mc::KeyEditMarks]> [namespace parent]::pgn::openMarksPalette
	Bind <Control-[string toupper $mc::KeyEditMarks]> [namespace parent]::pgn::openMarksPalette

	set Vars(key:annotation) $mc::KeyEditAnnotation
	set Vars(key:comment) $mc::KeyEditComment
	set Vars(key:marks) $mc::KeyEditMarks
}


# 80x80
set stmWhite [image create photo -data {
	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
	EL0AAAAASUVORK5CYII=
}]

set stmBlack [image create photo -data {
	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
	82tOVvj6PzoZkRdVHOXfAAAAAElFTkSuQmCC
}]

} ;# namespace board
} ;# namespace application

# vi:set ts=3 sw=3:
