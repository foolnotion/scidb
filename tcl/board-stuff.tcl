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

::util::source board-diagram

namespace eval board {
namespace eval diagram {

namespace import ::dialog::choosecolor::hsv2rgb
namespace import ::dialog::choosecolor::rgb2hsv
namespace import ::dialog::choosecolor::getActualColor

namespace export drawBorderlines

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::int
namespace import ::tcl::mathfunc::atan2

array set pieceToLetter {
	wk K  wq Q  wr R  wb B  wn N  wp P
	bk k  bq q  br r  bb b  bn n  bp p
	e .
}

variable squareIndex {
	a1 b1 c1 d1 e1 f1 g1 h1
	a2 b2 c2 d2 e2 f2 g2 h2
	a3 b3 c3 d3 e3 f3 g3 h3
	a4 b4 c4 d4 e4 f4 g4 h4
	a5 b5 c5 d5 e5 f5 g5 h5
	a6 b6 c6 d6 e6 f6 g6 h6
	a7 b7 c7 d7 e7 f7 g7 h7
	a8 b8 c8 d8 e8 f8 g8 h8
}

array set LetterToPiece {
	K wk  Q wq  R wr  B wb  N wn  P wp
	k bk  q bq  r br  b bb  n bn  p bp
 	. e
}

set emptyBoard		"................................................................"
set standardBoard	"RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"


proc new {w size args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Board

	array set opts {
		-relief		raised
		-bordertype	normal
		-bordersize	0
		-rotate		0
		-promosign	0
		-targets		{}
	}
	array set opts $args

	set Board(flip) $opts(-rotate)
	set Board(mark:promoted) $opts(-promosign)
	set Board(show:promoted) 0
	set Board(marks) {}
	set Board(alternatives) {}
	set Board(size) $size
	set Board(data) ""
	set Board(promoted) ""
	set Board(drag:square) -1
	set Board(drag:active) 0
	set Board(drag:x) -1
	set Board(drag:y) -1
	set Board(pointer:x) -1
	set Board(pointer:y) -1
	set Board(afterid) [after 50 [namespace code [list [namespace parent]::setupPieces $size]]]
	set Board(animate) 1
	set Board(animate,piece) ""
	set Board(targets) $opts(-targets)
	set Board(bordersize) $opts(-bordersize)
	set Board(bordertype) $opts(-bordertype)
   set boardSize [expr {8*$size}]
	set borderSize $Board(bordersize)

	if {$Board(bordertype) == "lines"} {
		set boardSize [expr {$boardSize + 2*$borderSize}]
		set borderSize 0
	}

   tk::frame $w -class Board
   tk::canvas $w.c \
		-width $boardSize \
		-height $boardSize \
		-borderwidth $borderSize \
		-relief $opts(-relief) \
		-takefocus 0 \
		;
   grid $w.c -column 0 -row 0

	$w.c xview moveto 0
	$w.c yview moveto 0

   [namespace parent]::registerSize $size
   [namespace parent]::setupSquares $size

   Build $w
	::bind $w.c <Destroy> [namespace code [list Destroy $w]]

   return $w
}


proc setPromoSign {w method} {
	variable ${w}::Board

	if {$method ne $Board(mark:promoted)} {
		set oldMethod $Board(mark:promoted)
		MakePromoImage $w $method
		set Board(mark:promoted) $method
		if {$oldMethod eq "none"} {
			foreach sq $Board(promoted) {
				$w.c delete promoted:$sq
				drawPromoted $w $sq
			}
		}
	}
}


proc showPromoted {w flag} {
	variable ${w}::Board
	set Board(show:promoted) $flag
}


proc showPromoted? {w} {
	variable ${w}::Board
	return $Board(show:promoted)
}


proc setTargets {w args} {
	variable ${w}::Board
	set Board(targets) $args
}


proc resize {w size args} {
   variable ${w}::Board

	array set opts [list -bordersize $Board(bordersize)]
	array set opts $args

   if {$size != $Board(size)} {
		DeleteImages $w
		after cancel $Board(afterid)

		set oldSize $Board(size)
		set boardSize [expr {8*$size}]
		set borderSize $opts(-bordersize)

		if {$Board(bordertype) == "lines"} {
			set boardSize [expr {$boardSize + 2*$borderSize}]
			set borderSize 0
		}

		$w.c configure -width $boardSize -height $boardSize -borderwidth $borderSize
		$w.c xview moveto 0
		$w.c yview moveto 0

		::board::registerSize $size
		::board::setupSquares $size

		set Board(size) $size
		set Board(afterid) [after 50 [namespace code [list [namespace parent]::setupPieces $size]]]
		set Board(bordersize) $opts(-bordersize)

		rebuild $w
		::board::unregisterSize $oldSize
	} elseif {$Board(bordersize) != $opts(-bordersize)} {
		set Board(bordersize) $opts(-bordersize)
		set boardSize [expr {8*$size}]
		set borderSize $opts(-bordersize)

		if {$Board(bordertype) == "lines"} {
			set boardSize [expr {$boardSize + 2*$borderSize}]
			set borderSize 0
		}

		$w.c configure -width $boardSize -height $boardSize -borderwidth $borderSize
		$w.c xview moveto 0
		$w.c yview moveto 0

		SetupBorders $w
	}
}


proc alignBoard {w {background {}}} {
	grid rowconfigure $w {1} -minsize 1
	if {[llength $background]} { $w configure -background $background }
}


proc bind {w args} {
	if {[llength $args] == 2} {
		::bind $w.c {*}$args
	} else {
		lassign $args sq event action

		if {$sq eq "all"} {
			for {set i 0} {$i < 64} {incr i} {
				$w.c bind input:$i $event [string map [list "%q" $i] $action]
			}
		} else {
			$w.c bind input:$sq $event [string map [list "%q" $sq] $action]
		}
	}
}


proc update {w {board {}} {promoted {}}} {
	variable ${w}::Board
	variable emptyBoard
	variable standardBoard

	set oldBoard $Board(data)
	set redraw 0
	
	switch -- $board {
		empty {
			set board $emptyBoard
		}

		standard {
			set board $standardBoard
		}

		flip - mirror {
			if {$board eq "mirror"} {
				set b [string reverse $oldBoard]
			} else {
				set b $oldBoard
			}
			set board ""
			set f 56
			set t 63
			while {$f >= 0} {
				append board [string range $b $f $t]
				incr f -8
				incr t -8
			}
		}

		default {
			if {[string length $board] == 0} {
				set board $Board(data)
				set promoted $Board(promoted)
				if {[string length $board] == 0} {
					set board $standardBoard
				}
				set redraw 1
			}
		}
	}

	set Board(data) $board

	if {$redraw || $Board(data) ne $oldBoard} {
		set size $Board(size)
		CancelAnimation $w

		# Remove all marks (incl. arrows) from the board:
		if {!$redraw} {
			set Board(marks) {}
			set Board(alternatives) {}
		}
		$w.c delete mark

		# Draw each square:
		for {set sq 0} {$sq < 64} {incr sq} {
			$w.c itemconfigure selected:$sq -state hidden
			$w.c itemconfigure suggested:$sq -state hidden
			set piece [string index $board $sq]
			if {$redraw || $piece ne [string index $oldBoard $sq]} {
				DrawPiece $w $sq $piece
			}
		}

		# Redraw marks and arrows:
		DrawAllMarks $w
		DrawAllAlternatives $w
	}

	if {$redraw || $Board(promoted) ne $promoted} {
		foreach sq $Board(promoted) {
			if {$sq ni $promoted} { $w.c delete promoted:$sq }
		}
		set Board(promoted) {}
		foreach sq $promoted {
			DrawPromoted $w $sq
		}
	}

	return $board
}


proc animate {w flag} {
	variable ${w}::Board
	set Board(animate) $flag
}


proc move {w list} {
	variable [namespace parent]::effects
	variable ${w}::Board

	CancelAnimation $w

	lassign $list color squareFrom squareTo squareCaptured \
		pieceFrom pieceTo pieceCaptured pieceHolding rookFrom rookTo forward

	if {$pieceTo eq " "} {
		if {$pieceFrom eq " "} { return }  ;# null move
		set pieceTo "."
	}

	set Board(data) [string replace $Board(data) $squareFrom $squareFrom .]

	if {$rookFrom >= 0} {
		set Board(data) [string replace $Board(data) $rookFrom $rookFrom .]
		set Board(data) [string replace $Board(data) $rookTo $rookTo [expr {$color eq "w" ? "R" : "r"}]]
	}

	set Board(data) [string replace $Board(data) $squareTo $squareTo $pieceTo]

	if {$squareCaptured != -1 && $squareCaptured != $squareTo} {
		set Board(data) [string replace $Board(data) $squareCaptured $squareCaptured $pieceCaptured]
	}

	if {$Board(show:promoted) && $pieceFrom != $pieceTo && $squareFrom != $squareTo} {
		if {!$forward} {
			removePromoted $w $squareFrom
		} elseif {$squareFrom ni $Board(promoted)} {
			# the moving piece is a promoted piece
			lappend Board(promoted) $squareFrom
		}
	}

	if {!$Board(animate) || $effects(animation) <= 0} {
		DoMove $w $list
	} elseif {$squareFrom eq $squareTo && $rookFrom == -1} {
		variable LetterToPiece
		# use fading effect because we cannot animate
		set animation $effects(animation)
		set after [max 5 [expr {round($animation/127.0)}]]
		set Board(animate,start) [clock milliseconds]
		set Board(animate,end) [expr {$Board(animate,start) + $animation} ]
		set Board(animate,after) $after
		set Board(animate,move) $list
		set Board(animate,to) $squareTo
		set Board(animate,time) $animation
		set Board(animate,piece) ""
		if {$pieceFrom eq " "} {
			set Board(animate,opacity) 10
			DrawFadingPiece $w $squareTo $LetterToPiece($pieceTo) +1
		} else {
			set Board(animate,opacity) 254
			DrawFadingPiece $w $squareTo $LetterToPiece($pieceFrom) -1
		}
	} else {
		if {$pieceFrom != $pieceTo && [string match {[Pp]} $pieceTo]} {
			DrawPiece $w $squareFrom $pieceTo
		}

		set animation $effects(animation)
		set after [max 1 [expr {round($animation/200.0)}]]

		# Start the animation:
		if {$squareFrom != $squareTo} {
			set Board(animate,from) $squareFrom
			set Board(animate,to) $squareTo
			set Board(animate,rookFrom) $rookFrom
			raisePiece $w $squareFrom

#			if {$rookFrom >= 0} {
#				# castling w/ moving king and w/ moving rook
#				set animation [expr {$animation/2.0}]
#			}
		} elseif {$rookFrom >= 0} {
			# castling w/o moving king, move rook instead
			set Board(animate,from) $rookFrom
			set Board(animate,to) $rookTo
			set Board(animate,rookFrom) -1
			raisePiece $w $squareFrom
		} else {
			# castling w/o moving king and w/o rook
			# TODO: probably we should animate a piece swap twice times
			return
		}

		set Board(animate,start) [clock milliseconds]
		set Board(animate,end) [expr {$Board(animate,start) + $animation} ]
		set Board(animate,after) $after
		set Board(animate,move) $list
		set Board(animate,rookTo) $rookTo
		set Board(animate,time) $animation

		AnimateMove $w
	}
}


proc rotate {w} {
	variable ${w}::Board

	set Board(flip) [expr {!$Board(flip)}]
	rebuild $w
}


proc rotated? {w} {
	variable ${w}::Board
	return $Board(flip)
}


proc rebuild {w} {
	Build $w
	SetupBorders $w
	update $w
}


proc size {w} {
	variable ${w}::Board
	return $Board(size)
}


proc bordersize {w} {
	variable ${w}::Board
	return $Board(bordersize)
}


proc canvas {w} {
	return $w.c
}


proc hilite {w i which} {
	variable [namespace parent]::hilite
	variable ${w}::Board

	if {$i < 0 || $i > 63} { return }

	if {$which eq "off"} {
		$w.c itemconfigure selected:$i -state hidden
		$w.c itemconfigure suggested:$i -state hidden
	} else {
		$w.c itemconfigure $which:$i -state normal
		$w.c raise $which:$i
		$w.c raise suggested:$i
		raisePiece $w
		RaiseAdornment $w
	}
}


proc hilited {w which} {
	return [set ${w}::Board($which)]
}


proc clearMarks {w} {
	variable ${w}::Board

	set Board(marks) {}
	set Board(alternative) {}
	$w.c delete mark
}


proc clearAlternatives {w} {
	variable ${w}::Board

	set Board(alternative) {}
	$w.c delete alternative
	$w.c delete click
}


proc updateMarks {w marks} {
	variable ${w}::Board

	set Board(marks) $marks
	set Board(alternatives) {}
	$w.c delete mark
	DrawAllMarks $w
}


proc drawPromoted {w square} {
	DrawPromoted $w $square
	raisePiece $w $square
	RaiseAdornment $w
}


proc removePromoted {w square} {
	variable ${w}::Board

	$w.c delete promoted:$square

	if {[set i [lsearch -exact $Board(promoted) $square]] >= 0} {
		set Board(promoted) [lreplace $Board(promoted) $i $i]
	}
}


proc removeAllPromoted {w} {
	variable ${w}::Board

	$w.c delete promoted
	set Board(promoted) {}
}


proc promotedSquares {w} {
	variable ${w}::Board
	return $Board(promoted)
}


proc piece {w sq} {
	variable ${w}::Board
	variable LetterToPiece

	set p [string index $Board(data) $sq]
	if {$p eq " "} { return "e" }
	return $LetterToPiece([string index $Board(data) $sq])
}


proc square {name} {
	variable squareIndex
	return [lsearch -exact $squareIndex $name]
}


proc getSquare {w x y} {
	variable ${w}::Board

	if {[winfo containing $x $y] ne "$w.c"} { return -1 }

	set x [expr {int(($x - [winfo rootx $w.c])/$Board(size))}]
	set y [expr {int(($y - [winfo rooty $w.c])/$Board(size))}]

	if {$x < 0 || $y < 0 || $x > 7 || $y > 7} { return -1 }

	set sq [expr {(7 - $y)*8 + $x}]
	return [expr {$Board(flip) ? 63 - $sq : $sq}]
}


proc finishDrag {w} {
	variable ${w}::Board
	variable squareIndex

	if {$Board(drag:active)} {
		if {$Board(drag:square) != -1} {
			set sq [getSquare $w $Board(pointer:x) $Board(pointer:y)]
			lassign [$w.c coords square:$sq] x y
			if {[llength $x]} {
				# hack: for any reason the mark will not be moved with 'drag-target'
				$w.c coords promoted:$Board(drag:square) $x $y
				$w.c coords drag-target $x $y
				$w.c raise drag-target
			}
		}

		foreach t $Board(targets) { $t delete drag-target }
		$w.c dtag promoted:$Board(drag:square) drag-target
		$w.c dtag piece:$Board(drag:square) drag-target
	}

	set Board(drag:active) 0
}


proc cancelDrag {w} {
	variable ${w}::Board
	set Board(drag:square) -1
}


proc dragTarget {w} {
	variable ${w}::Board
	return [getSquare $w $Board(pointer:x) $Board(pointer:y)]
}


proc setDragSquare {w {sq -1}} {
	variable ${w}::Board

	set oldSq $Board(drag:square)

	if {$oldSq != -1} {
		DrawPiece $w $oldSq [string index $Board(data) $oldSq]
	}

	if {$sq != -1} {
		set x [expr {[winfo pointerx $w] - [winfo rootx $w.c] - $Board(size)/2}]
		set y [expr {[winfo pointery $w] - [winfo rooty $w.c] - $Board(size)/2}]

		lassign [$w.c coords square:$sq] x0 y0

		set Board(drag:x) [expr {$x - $x0}]
		set Board(drag:y) [expr {$y - $y0}]
	}

	set Board(drag:square) $sq
	set Board(drag:active) 0

	foreach t $Board(targets) { $t delete drag-target }
	$w.c dtag drag-target drag-target
}


proc raisePiece {w {square ""}} {
	variable ${w}::Board

	if {[string length $square] == 0} {
		if {$Board(mark:promoted) eq "disk"} { $w.c raise promoted }
		$w.c raise piece
		if {$Board(mark:promoted) in {bullet star}} { $w.c raise promoted }
	} else {
		if {$Board(mark:promoted) eq "disk"} { $w.c raise promoted:$square }
		$w.c raise piece:$square
		if {$Board(mark:promoted) in {bullet star}} { $w.c raise promoted:$square }
	}
}


proc isDragged? {w} {
	variable ${w}::Board
	return $Board(drag:active)
}


proc dragSquare {w} {
	variable ${w}::Board
	return $Board(drag:square)
}


proc dragPiece {w x y} {
	variable ${w}::Board

	set sq $Board(drag:square)
	if {$sq == -1} { return }

	set Board(pointer:x) $x
	set Board(pointer:y) $y

	set xc [expr {$x - [winfo rootx $w.c] - $Board(size)/2}]
	set yc [expr {$y - [winfo rooty $w.c] - $Board(size)/2}]

	if {!$Board(drag:active)} {
		lassign [$w.c coords square:$sq] x0 y0
		if {abs($x0 - $xc) > 5 || abs($y0 - $yc) > 5} {
			set Board(drag:active) 1
			$w.c addtag drag-target withtag promoted:$sq
			$w.c addtag drag-target withtag piece:$sq

			if {[llength $Board(targets)]} {
				set piece [piece $w $sq]
				set img photo_Piece($piece,$Board(size))
				foreach t $Board(targets) {
					$t create image 0 0 -image $img -tag drag-target -anchor center
				}
			}
		}
	}

	if {$Board(drag:x) != -1 && $Board(drag:y) != -1} {
		set dx $Board(drag:x)
		set dy $Board(drag:y)
	} else {
		lassign {0 0} dx dy
	}

	set x0 [expr {$xc - $dx}]
	set y0 [expr {$yc - $dy}]

	$w.c coords promoted:$sq $x0 $y0
	$w.c coords piece:$sq $x0 $y0
	$w.c raise drag-target

	if {[llength $Board(targets)]} {
		foreach t $Board(targets) {
			set x1 [expr {$x - [winfo rootx $t] - $dx}]
			set y1 [expr {$y - [winfo rooty $t] - $dy}]
			$t coords drag-target $x1 $y1
		}
	}
}


proc setPiece {w sq piece} {
	variable ${w}::Board

	set Board(data) [string replace $Board(data) $sq $sq $piece]
	DrawPiece $w $sq $piece
	return $Board(data)
}


proc setSign {w square} {
	variable [namespace parent]::square::style
	variable ${w}::Board

	makeHiliteRect $w.c sign $square $Board(size) {*}[$w.c coords square:$square] $style(hilite,selected)

	RaiseSign $w
	raisePiece $w
	RaiseAdornment $w
}


proc eraseSign {w square} {
	$w.c delete sign:$square
}


proc makeHiliteRect {canv which tag size x1 y1 {color {}}} {
	variable [namespace parent]::square::style
	variable [namespace parent]::hilite

	set x1 [int $x1]
	set y1 [int $y1]
	set x2 [expr {$x1 + $size}]
	set y2 [expr {$y1 + $size}]

	incr x1 [int $style(borderline,gap)]
	incr y1 [int $style(borderline,gap)]

	if {[llength $color] == 0} {
		set outline $hilite($which)
		set color $style(hilite,$which)
		set tags [list hilite rect $which:$tag]
		set state hidden
	} else {
		set outline 0
		set tags [list mark rect $which:$tag]
		set state normal
		incr x1
		incr y1
		incr x2 -1
		incr y2 -1
	}

	if {$outline > 0} {
		set inc1 $outline
		set inc2 $outline
		if {$inc1 % 2} {
			incr inc1 -1
			incr inc2
		}
		set inc1 [expr {$inc1/2}]
		set inc2 [expr {$inc2/2}]
		incr x1 $inc1; incr x2 -$inc2
		incr y1 $inc1; incr y2 -$inc2
		$canv create rectangle $x1 $y1 $x2 $y2 \
			-tags $tags -width $outline -outline $color -state $state
	} else {
		incr x1 [abs $outline]
		incr y1 [abs $outline]
		incr x2 $outline
		incr y2 $outline
		$canv create rectangle $x1 $y1 $x2 $y2 -tags $tags -width 0 -fill $color -state $state
	}

	return $which:$tag
}


proc drawBorderlines {border wd {ht 0}} {
	if {$ht <= 0} { set ht $wd }

	foreach n {0 1 2} {
		set hl photo_Borderline(hl$n:$border)
		set vl photo_Borderline(vl$n:$border)
		set hd photo_Borderline(hd$n:$border)
		set vd photo_Borderline(vd$n:$border)

		catch { image delete $hl }
		catch { image delete $vl }
		catch { image delete $hd }
		catch { image delete $vd }

		image create photo $hl -width [expr {$wd - 2*$n - 1}] -height 1
		image create photo $vl -width 1 -height [expr {$ht - 2*$n - 2}]
		image create photo $hd -width [expr {$wd - 2*$n}] -height 1
		image create photo $vd -width 1 -height [expr {$ht - 2*$n - 1}]

		$hl copy photo_Borderline(horz,lite,$n)
		$vl copy photo_Borderline(vert,lite,$n)
		$hd copy photo_Borderline(horz,dark,$n)
		$vd copy photo_Borderline(vert,dark,$n)

		$border create image $n $n -anchor nw -image $hl -tag shadow
		$border create image $n [expr {$n + 1}] -anchor nw -image $vl -tag shadow
		$border create image $n [expr {$ht - $n - 1}] -anchor nw -image $hd -tag shadow
		$border create image [expr {$wd - $n - 1}] $n -anchor nw -image $vd -tag shadow
	}
}


proc drawText {canv squareSize color x y text} {
	if {$text eq "-"} { set text "\u2212" }
	set size [expr {int(double($squareSize)*0.6 + 0.5)}]
	if {$squareSize % 2} { incr size }
	set x0 [expr {$x + $squareSize/2}]
	set y0 [expr {$y + $squareSize/2}]
	scan [getActualColor $color] "\#%2x%2x%2x" r g b
	set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
	set font [list [font configure TkFixedFont -family] $size bold]
	set x1 [expr {$x0 + 1}]
	set y1 [expr {$y0 + 1}]
	set tags {mark text}
	if {$luma < 50} {
		$canv create text $x0 $y0 -fill white  -font $font -text $text -anchor center -tags $tags
		$canv create text $x1 $y1 -fill $color -font $font -text $text -anchor center -tags $tags
	} else {
		$canv create text $x1 $y1 -fill black  -font $font -text $text -anchor center -tags $tags
		$canv create text $x0 $y0 -fill $color -font $font -text $text -anchor center -tags $tags
	}
}


proc drawFull {canv squareSize color x y {tag tag}} {
	makeHiliteRect $canv rect $tag $squareSize $x $y $color
}


proc drawSquare {canv squareSize color x y} {
	SetImage $canv $squareSize $x $y [MakeSquare $squareSize $color]
}


proc drawCircle {canv squareSize color x y} {
	SetImage $canv $squareSize $x $y [MakeCircle $squareSize $color]
}


proc drawDisk {canv squareSize color x y} {
	SetImage $canv $squareSize $x $y [MakeDisk $squareSize $color]
}


proc drawAlternative {w from to color cmd} {
	variable ${w}::Board

	if {$from == $to} { return }

	set i [llength $Board(alternatives)]
	lappend Board(alternatives) [list $from $to $color $i]

	set size $Board(size)
	set rows [expr {$to/8 - $from/8}]
	set cols [expr {$to%8 - $from%8}]
	set img [DrawArrow $w $from $to $color $i]
	set cmdEnter [namespace code [list HiliteArrow $w $rows $cols $color $i click]]
	set cmdLeave [namespace code [list HiliteArrow $w $rows $cols $color $i alternative]]

	$w.c bind alt:$i <ButtonPress-1> $cmd
	$w.c bind alt:$i <Enter> $cmdEnter
	$w.c bind alt:$i <Leave> $cmdLeave
	$w.c raise click
}


proc RaiseAdornment {w} {
	$w.c raise text
	$w.c raise arrow
	$w.c raise alternative
	$w.c raise input
	$w.c raise click
}


proc RaiseSign {w} {
	$w.c raise rect
	$w.c raise mark
	$w.c raise hilite
	$w.c raise sign
}


proc HiliteArrow {w rows cols color index type} {
	variable ${w}::Board

	set size $Board(size)

	if {![info exists Board(image,$type,$rows,$cols,$size,$color)]} {
		if {$type eq "click"} { set hilite [GetHiliteColor $color] } else { set hilite $color }
		set Board(image,$type,$rows,$cols,$size,$color) [MakeArrow $size $rows $cols $hilite click]
	}

	$w.c itemconfigure alternative:$index -image $Board(image,$type,$rows,$cols,$size,$color)
}


proc GetHiliteColor {color} {
	scan [getActualColor $color] "\#%2x%2x%2x" r g b
	lassign [rgb2hsv $r $g $b] h s v
	return [format "#%02x%02x%02x" {*}[hsv2rgb $h 1.0 1.0]]
}


proc DrawPiece {w sq piece} {
	variable LetterToPiece
	variable ${w}::Board

	set piece $LetterToPiece($piece)
	set promoted [$w.c find withtag promoted:$sq]
	$w.c delete piece:$sq promoted:$sq

	if {$piece ne "e"} {
		$w.c create image {*}[$w.c coords square:$sq] \
			-image photo_Piece($piece,$Board(size)) \
			-anchor nw \
			-tags [list piece piece:$sq] \
			;
		if {[string length $promoted]} { DrawPromoted $w $sq }
		RaiseAdornment $w
	}
}



proc DrawPromoted {w square} {
	variable ${w}::Board

	if {$Board(mark:promoted) ne "none" && [string length [$w.c find withtag promoted:$square]] == 0} {
		lassign [$w.c coords square:$square] x y
		set tags [list promoted promoted:$square]
		set img [MakePromoImage $w]
		$w.c create image $x $y -anchor nw -image $img -tags $tags
	}

	if {$square ni $Board(promoted)} { lappend Board(promoted) $square }
}


proc Build {w} {
	variable ${w}::Board

	set size $Board(size)
	set flip $Board(flip)
	set offs [expr {$Board(bordertype) == "lines" ? $Board(bordersize) : 0}]

	for {set i 0} {$i < 64} {incr i} {
		set row [expr {$i/8}]
		set col [expr {$i%8}]
		set x [expr {$col*$size + $offs}]
		set y [expr {(7 - $row)*$size + $offs}]
		set k [expr {$flip ? 63 - $i : $i}]
		set color [expr {($row + $col) % 2 ? "lite" : "dark"}]
		$w.c delete square:$k selected:$k suggested:$k input:$k
		$w.c create image $x $y -anchor nw -image photo_Square($color,$size) -tag square:$k
		$w.c create rectangle $x $y [expr {$x + $size}] [expr {$y + $size}] \
			-tag mark:$k -width 0 -state hidden
		makeHiliteRect $w.c selected $k $size $x $y
		makeHiliteRect $w.c suggested $k $size $x $y
		$w.c create rectangle $x $y [expr {$x + $size}] [expr {$y + $size}] \
			-tags [list input input:$k] \
			-outline {} \
			;
	}
}


proc SetupBorders {w} {
	variable ${w}::Board

	$w.c delete borderline
	if {$Board(bordertype) ne "lines"} { return }
	set borderSize $Board(bordersize)
	set boardSize [expr {8*$Board(size) + 2*$borderSize}]

	for {set i 0; set bs [expr {$boardSize - 1}]} {$i < $borderSize} {incr i; decr bs} {
		$w.c create line $i $bs $boardSize $bs -width 1 -fill #4f4f4f -tag borderline
		$w.c create line $bs [expr {$i + 1}] $bs $boardSize -width 1 -fill #4f4f4f -tag borderline
	}
}


proc Destroy {w} {
	variable ${w}::Board

	after cancel $Board(afterid)
	DeleteImages $w
	[namespace parent]::unregisterSize $Board(size)
	namespace delete [namespace current]::${w}
}


proc DeleteImages {w} {
	variable ${w}::Board

	if {[string length $Board(animate,piece)]} {
		image delete $Board(animate,piece)
		set Board(animate,piece) ""
	}

	foreach name [array names Board -glob image,*] {
		image delete $Board($name)
	}

	array unset Board image,*
}


proc DoMove {w list} {
	variable ${w}::Board

	lassign $list color squareFrom squareTo squareCaptured \
		pieceFrom pieceTo pieceCaptured pieceHolding rookFrom rookTo forward

	if {$Board(show:promoted) && $forward && $squareCaptured != -1} {
		# we have to remove a possible promotion mark
		removePromoted $w $squareCaptured
	}

	if {$squareFrom != $squareTo} {
		DrawPiece $w $squareFrom .
	}

	if {$rookFrom != $rookTo} {
		DrawPiece $w $rookFrom .
		DrawPiece $w $rookTo [expr {$color eq "w" ? "R" : "r"}]
	}

	if {$pieceTo ne " "} {
		DrawPiece $w $squareTo $pieceTo
	}

	if {$squareCaptured != -1 && $squareCaptured != $squareTo} {
		DrawPiece $w $squareCaptured $pieceCaptured
	}

	if {$Board(show:promoted)} {
		if {	$squareFrom in $Board(promoted)
			|| (	$pieceFrom != $pieceTo
				&& $pieceTo ne " "
				&& [string match {[Pp]} $pieceFrom])} {
			# 1. move promotion marker to new piece position, or
			# 2. mark newly promoted piece
			removePromoted $w $squareFrom
			DrawPromoted $w $squareTo
			raisePiece $w $squareTo
		}

		if {	!$forward
			&& $pieceCaptured != $pieceHolding
			&& $pieceCaptured != "."
			&& [string match {[Pp]} $pieceHolding]
			&& ![string match {[Pp]} $pieceCaptured]} {
			# take back capture of promoted piece
			DrawPromoted $w $squareFrom
			raisePiece $w $squareFrom
		}
	}

	RaiseAdornment $w
}


proc DrawFadingPiece {w sq piece dir} {
	variable ${w}::Board
	variable pieceToLetter

	if {![winfo exists $w.c]} { return }

	set end $Board(animate,end)
	set now [clock milliseconds]

	if {$now >= $end || ($dir == 1 ? $Board(animate,opacity) >= 255 : $Board(animate,opacity) < 10)} {
		if {$dir == 1} {
			DrawPiece $w $sq $pieceToLetter($piece)
		} else {
			$w.c delete piece:$sq
		}
		unset Board(animate,afterid)
	} else {
		set to $Board(animate,to)
		set start $Board(animate,start)

		if {[string length $Board(animate,piece)] == 0} {
			set img photo_Piece($piece,$Board(size))
			set Board(animate,piece) \
				[image create photo -width [image width $img] -height [image height $img]]
			$w.c delete piece:$sq
			$w.c create image {*}[$w.c coords square:$sq] \
				-image $Board(animate,piece) -anchor nw -tag piece:$sq
			raisePiece $w $sq
			RaiseAdornment $w
		}

		::scidb::tk::image disable \
			photo_Piece($piece,$Board(size)) \
			$Board(animate,piece) \
			[expr {round($Board(animate,opacity))}] \
			;

		# Compute next alpha value:
		set ratio [expr {double($now - $start)/double($end - $start)}]
		if {$dir == 1} {
			set Board(animate,opacity) [expr {10 + $ratio*244}]
		} else {
			set Board(animate,opacity) [expr {255 - $ratio*244}]
		}

		# Schedule another animation update in a few milliseconds:
		set Board(animate,afterid) \
			[after $Board(animate,after) [namespace code [list DrawFadingPiece $w $sq $piece $dir]]]
	}
}


proc AnimateMove {w} {
	if {![namespace exists $w]} { return }
	variable ${w}::Board

	if {![winfo exists $w.c]} { return }

	set end $Board(animate,end)
	set now [clock milliseconds]

	if {$now >= $end} {
		if {$Board(animate,rookFrom) < 0} {
			DoMove $w $Board(animate,move)
			unset Board(animate,afterid)
			return
		}

		# place king at right place
		$w.c coords piece:$Board(animate,from) {*}[$w.c coords square:$Board(animate,to)]

		# start rook animation (in case of castling)
		set Board(animate,start) $now
		set Board(animate,from) $Board(animate,rookFrom)
		set Board(animate,to) $Board(animate,rookTo)
		set Board(animate,end) [expr {$Board(animate,end) + $Board(animate,time)} ]
		set Board(animate,rookFrom) -1
		set Board(animate,rookTo) -1
		raisePiece $w $Board(animate,from)
	} else {
		set from $Board(animate,from)
		set to $Board(animate,to)
		set start $Board(animate,start)

		# Compute where the moving piece should be displayed and move it:
		set ratio [expr {double($now - $start)/double($end - $start)}]
		lassign [$w.c coords square:$from] fromX fromY
		lassign [$w.c coords square:$to] toX toY
		set x [expr {$fromX + round(($toX - $fromX)*$ratio)}]
		set y [expr {$fromY + round(($toY - $fromY)*$ratio)}]
		$w.c coords promoted:$from $x $y
		$w.c coords piece:$from $x $y
	}

	# Schedule another animation update in a few milliseconds:
	set Board(animate,afterid) [after $Board(animate,after) [namespace code [list AnimateMove $w]]]
}


proc CancelAnimation {w} {
	variable ${w}::Board

	if {[string length $Board(animate,piece)]} {
		image delete $Board(animate,piece)
		set Board(animate,piece) ""
	}

	if {[info exists Board(animate,afterid)]} {
		after cancel $Board(animate,afterid)
		unset Board(animate,afterid)
		DoMove $w $Board(animate,move)
	}
}


proc DrawAllMarks {w} {
	variable ${w}::Board

	foreach mark $Board(marks) {
		lassign [split $mark ,] cmd type sq sq2 color
		set square [square $sq]
		switch $type {
			full		{ DrawFull $w $square $color }
			square	{ DrawSquare $w $square $color ;# Scid does not use 'square' }
			arrow		{ DrawArrow $w $square [square $sq2] $color }
			circle	{ DrawCircle $w $square $color }
			disk		{ DrawDisk $w $square $color }
			default	{ DrawText $w $type $square $color }
		}
	}

	RaiseSign $w
	raisePiece $w
	RaiseAdornment $w
}


proc DrawAllAlternatives {w} {
	variable ${w}::Board

	foreach alt $Board(alternatives) { DrawArrow $w {*}$alt }
	$w.c raise alternative
	$w.c raise click
}


proc DrawText {w text square color} {
	drawText $w.c [set ${w}::Board(size)] $color {*}[$w.c coords square:$square] $text
}


proc DrawFull {w square color} {
	drawFull $w.c [set ${w}::Board(size)] $color {*}[$w.c coords square:$square] $square
}


proc SetImage {canv squareSize x y img {tags {}}} {
	set size [image width $img]
	set x [expr {$x + ($squareSize - $size)/2}]
	set y [expr {$y + ($squareSize - $size)/2}]
	$canv create image $x $y -anchor nw -image $img -tags [list mark {*}$tags]
}


proc MakeSquare {squareSize color} {
	variable Rectangle

	set size [expr {int(double($squareSize)*0.8 + 0.5)}]
	if {($squareSize % 2) != ($size % 2)} { incr size }
	set img [image create photo -width $size -height $size]
	set svg [string map [list \#c# $color] $Rectangle]
	::scidb::tk::image create svg $img
	::scidb::tk::image alpha 0.8 $img -composite overlay
	return $img
}


proc DrawSquare {w square color {tags {}}} {
	variable ${w}::Board

	if {![info exists Board(image,square,$Board(size),$color)]} {
		set Board(image,square,$Board(size),$color) [MakeSquare $Board(size) $color]
	}

	SetImage $w.c $Board(size) {*}[$w.c coords square:$square] \
		$Board(image,square,$Board(size),$color) $tags
}


proc MakePromoImage {w {method ""}} {
	variable ${w}::Board

	if {[string length $method] == 0} { set method $Board(mark:promoted) }
	set size $Board(size)
	set create 0

	if {[info exists Board(image,marker)]} {
		set img $Board(image,marker)
		if {$method eq "none"} {
			image delete $Board(image,marker)
			unset Board(image,marker)
			return
		}
		set create [expr {$method ne $Board(mark:promoted)}]
	} else {
		set img [image create photo -width $size -height $size]
		set Board(image,marker) $img
		set create 1
	}

	if {$create} {
		$img blank

		switch $method {
			bullet {
				$img copy $::board::icon::12x12::marker -to 2 [expr {$size - 14}] 14 [expr {$size - 2}]
			}
			star {
				set s [expr {($size*2)/5}]
				if {$s % 2 == 0} { incr s }
				set star [image create photo -width $s -height $s]
				::scidb::tk::image create [namespace current]::Star $star
				set x1 [expr {($size - $s)/2}]
				set y1 [expr {$size - $s - 2}]
				$img copy $star -to $x1 $y1 [expr {$x1 + $s}] [expr {$y1 + $s}]
			}
			disk {
				variable Disk
				set tmp [image create photo -width [image width $Disk] -height [image height $Disk]]
				::scidb::tk::image copy $Disk $tmp
				::scidb::tk::image colorize orange 0.7 $tmp
				::scidb::tk::image copy $tmp $img
				image delete $tmp
				#::scidb::tk::image alpha 0.9 $img -composite overlay
			}
		}
	}

	return $img
}


proc MakeCircle {squareSize color} {
	variable Circle

	set size [expr {int(double($squareSize)*0.8 + 0.5)}]
	if {($squareSize % 2) != ($size % 2)} { incr size }
	set tmp [image create photo -width [image width $Circle] -height [image height $Circle]]
	$tmp copy $Circle
	::scidb::tk::image colorize $color 0.7 $tmp
	set img [image create photo -width $size -height $size]
	::scidb::tk::image copy $tmp $img
	::scidb::tk::image alpha 0.8 $img -composite overlay
	image delete $tmp
	return $img
}


proc DrawCircle {w square color} {
	variable ${w}::Board

	if {![info exists Board(image,circle,$Board(size),$color)]} {
		set Board(image,circle,$Board(size),$color) [MakeCircle $Board(size) $color]
	}
	SetImage $w.c $Board(size) {*}[$w.c coords square:$square] $Board(image,circle,$Board(size),$color)
}


proc MakeDisk {squareSize color} {
	variable Disk

	set size [expr {int(double($squareSize)*0.8 + 0.5)}]
	if {($squareSize % 2) != ($size % 2)} { incr size }
	set tmp [image create photo -width [image width $Disk] -height [image height $Disk]]
	$tmp copy $Disk
	::scidb::tk::image colorize $color 0.7 $tmp
	set img [image create photo -width $size -height $size]
	::scidb::tk::image copy $tmp $img
	::scidb::tk::image alpha 0.8 $img -composite overlay
	image delete $tmp
	return $img
}


proc DrawDisk {w square color} {
	variable ${w}::Board

	if {![info exists Board(image,disk,$Board(size),$color)]} {
		set Board(image,disk,$Board(size),$color) [MakeDisk $Board(size) $color]
	}
	SetImage $w.c $Board(size) {*}[$w.c coords square:$square] $Board(image,disk,$Board(size),$color)
}


proc DrawArrow {w from to color {index -1}} {
	variable ${w}::Board

	if {$from == $to} { return }

	if {$index >= 0} { set type alternative } else { set type arrow }

	set size $Board(size)
	set sizh [expr {$size/2}]
	set sizq [expr {$size/4}]
	set rows [expr {$to/8 - $from/8}]
	set cols [expr {$to%8 - $from%8}]

	if {$Board(flip)} {
		set cols [expr {-$cols}]
		set rows [expr {-$rows}]
	}

	if {![info exists Board(image,$type,$rows,$cols,$size,$color)]} {
		set Board(image,$type,$rows,$cols,$size,$color) [MakeArrow $size $rows $cols $color $type]
	}

	lassign [$w.c coords square:$from] x1 y1
	lassign [$w.c coords square:$to  ] x2 y2
	set x0 [expr {int(min($x1, $x2))}]
	set y0 [expr {int(min($y1, $y2))}]
	if {$cols} { incr x0 $sizh }
	if {$rows} { incr y0 $sizh }

	set img $Board(image,$type,$rows,$cols,$size,$color)
	set tags [list mark $type]

	incr x0 [expr {-([image width  $img] - [expr {max(1, [abs $cols])*$size}])/2}]
	incr y0 [expr {-([image height $img] - [expr {max(1, [abs $rows])*$size}])/2}]

	if {$type eq "alternative"} {
		set iw [image width  $img]
		set ih [image height $img]
		set ah [expr {min(33.0/$size, max(0.5, 12.0/$size))}]	;# arrowhead width (= ah*size)
		set as [expr {int(0.5*$ah*$size + 0.5)}]

		set opts [list -tags [list mark click alt:$index] -width 4 -outline {} -fill {}]

		if {$cols == 0 || $rows == 0} {
			if {$cols == 0} {
				set dw [expr {max(0,($iw - $as)/2 - 2)}]
				set x1 [expr {$x0 + $dw}]
				set x2 [expr {$x0 + $iw - $dw}]
				set y1 $y0
				set y2 [expr {$y0 + $ih}]
			} else {
				set dh [expr {max(0,($ih - $as)/2 - 2)}]
				set x1 $x0
				set x2 [expr {$x0 + $iw}]
				set y1 [expr {$y0 + $dh}]
				set y2 [expr {$y0 + $ih - $dh}]
			}
			$w.c create rectangle $x1 $y1 $x2 $y2 {*}$opts
		} else {
			if {($rows > 0) == ($cols > 0)} {
				set x1 [expr {$x0 + $iw}]
				set y1 [expr {$y0 + $as}]
				set x2 [expr {$x0 + $iw - $as}]
				set y2 $y0
				set x3 $x0
				set y3 [expr {$y0 + $ih - $as}]
				set x4 [expr {$x0 + $as}]
				set y4 [expr {$y0 + $ih}]
			} else {
				set x1 $x0
				set y1 [expr {$y0 + $as}]
				set x2 [expr {$x0 + $as}]
				set y2 $y0
				set x3 [expr {$x0 + $iw}]
				set y3 [expr {$y0 + $ih - $as}]
				set x4 [expr {$x0 + $iw - $as}]
				set y4 [expr {$y0 + $ih}]
			}
			$w.c create polygon $x1 $y1 $x2 $y2 $x3 $y3 $x4 $y4 {*}$opts
		}

		lappend tags alternative:$index
	}

	$w.c create image $x0 $y0 -anchor nw -image $img -tags $tags
}


proc MakeArrow {size rows cols color type} {
	set ncols [abs $cols]
	set nrows [abs $rows]
	set length [expr {$size*(max($nrows,$ncols)) - $size/4}]

	set rot [geometry::rad2deg [atan2 $cols $rows]]
	set deg $rot
	if {$deg <   0.0} { set deg [expr {$deg + 360.0}] }
	if {$deg > 180.0} { set deg [expr {$deg - 180.0}] }
	if {$deg >  90.0} { set deg [expr {$deg -  90.0}] }
	if {$deg >  45.0} { set deg [expr {90.0 -  $deg}] }
	set scalef [expr {1.0/cos([geometry::deg2rad $deg])}]

	###########################
	#                         #
	#   ^   ^       x         #
	#   |   |      / \        #
	#   |  hh     /   \       #
	#   |   |    /     \      #
	#  th   v   +-+   +-+     #
	#   |   ^     |   |       #
	#   |   |     |   |       #
	#   |  sh     |   |       #
	#   |   |     |   |       #
	#   v   v     +---+       #
	#             <--->   sw  #
	#           <-------> hw  #
	#                         #
	###########################
	switch $type {
		arrow {
			set ah [expr {min(22.0/$size, max(0.3, 8.0/$size))}]	;# arrowhead width (= ah*size)
			set op 0.8	;# opacity
			set as 0.4	;# arrow shaft ratio (shaft width = as*width)
		}
		alternative {
			set ah [expr {min(33.0/$size, max(0.45, 12.0/$size))}]	;# arrowhead width (= ah*size)
			set op 0.75	;# opacity
			set as 0.5	;# arrow shaft ratio (shaft width = as*width)
		}
		click {
			set ah [expr {min(33.0/$size, max(0.45, 12.0/$size))}]	;# arrowhead width (= ah*size)
			set op 1.0	;# opacity
			set as 0.5	;# arrow shaft ratio (shaft width = as*width)
		}
	}
	set sf 1.0	;# stroke width factor
	set ar 0.6	;# arrow head ratio (height = ar*width)

	# we do a small correction to reduce an optical illusion
	if {$rows == 0 || $cols == 0} { set as [expr {1.05*$as}] }

	set hw 100.0
	set sw [expr {$hw*$as}]
	set hh [expr {$ar*$hw}]
	set th [expr {($length*$scalef*$hw)/($size*$ah)}]
	set sh [expr {$th - $hh}]

	set strokeWidth [expr {0.05*$hw*$sf}]
	set opacity $op

	set p(0,x) 0					; set p(0,y) -$hh
	set p(1,x) [expr {-$hw/2}]	; set p(1,y) 0
	set p(2,x) [expr {-$sw/2}]	; set p(2,y) 0
	set p(3,x) [expr {-$sw/2}]	; set p(3,y) $sh
	set p(4,x) [expr {+$sw/2}]	; set p(4,y) $sh
	set p(5,x) [expr {+$sw/2}]	; set p(5,y) 0
	set p(6,x) [expr {+$hw/2}]	; set p(6,y) 0

	set offs [expr {1.4142135624*($hh + $strokeWidth)}]
	for {set i 0} {$i < 7} {incr i} { set p($i,y) [expr {$p($i,y) + $offs}] }

	set delta [expr {(0.4*$hw)/$strokeWidth}]
	set q01 [geometry::translation $p(0,x) $p(0,y) $p(1,x) $p(1,y) +$delta $delta]
	set q06 [geometry::translation $p(0,x) $p(0,y) $p(6,x) $p(6,y) -$delta $delta]
	set q12 [list $p(1,x) [expr {$p(1,y) - $delta}] $p(2,x) [expr {$p(2,y) - $delta}]]
	set q56 [list $p(5,x) [expr {$p(5,y) - $delta}] $p(6,x) [expr {$p(6,y) - $delta}]]

	lassign [geometry::intersection $q01 $q06] q(0,x) q(0,y)
	lassign [geometry::intersection $q01 $q12] q(1,x) q(1,y)
	set q(2,x) [expr {$p(3,x) + $delta}]; set q(2,y) [expr {$p(2,y) - $delta}]
	set q(3,x) [expr {$p(3,x) + $delta}]; set q(3,y) [expr {$p(3,y) - $delta}]
	set q(4,x) [expr {$p(4,x) - $delta}]; set q(4,y) [expr {$p(4,y) - $delta}]
	set q(5,x) [expr {$p(5,x) - $delta}]; set q(5,y) [expr {$p(5,y) - $delta}]
	lassign [geometry::intersection $q06 $q56] q(6,x) q(6,y)

	scan [getActualColor $color] "\#%2x%2x%2x" r g b
	set lite [list $r $g $b]
	lassign [rgb2hsv {*}$lite] h s v
	set dark [hsv2rgb $h $s [expr {min(1.0,$v*0.70)}]]
	set lite [format "#%02x%02x%02x" {*}$lite]
	set dark [format "#%02x%02x%02x" {*}$dark]

	if {$type eq "arrow"} {
		set edge [hsv2rgb $h $s [expr {min(1.0,$v*0.15)}]]
		set edge [format "#%02x%02x%02x" {*}$edge]
	} else {
		set edge #000000
	}

	append svg "<svg>"
	append svg "<defs>"
	append svg "<linearGradient id=\"linearGradient1683\">"
	append svg "<stop offset=\"0.0000000\" style=\"stop-color:$lite;stop-opacity:$opacity\"/>"
	append svg "<stop offset=\"1.0000000\" style=\"stop-color:$dark;stop-opacity:$opacity\"/>"
	append svg "</linearGradient>"
	append svg "<linearGradient id=\"linearGradient1694\">"
	append svg "<stop offset=\"0\" style=\"stop-color:#ffffff;stop-opacity:[expr {0.3*$opacity}]\"/>"
	append svg "<stop offset=\"1\" style=\"stop-color:#ffffff;stop-opacity:0.0\"/>"
	append svg "</linearGradient>"
	append svg "<linearGradient id=\"down-top-1683\" x1=\"0%\" y1=\"100%\" x2=\"0%\" y2=\"0%\" "
	append svg "xlink:href=\"#linearGradient1683\"/>"
	append svg "<linearGradient id=\"top-down-1694\" x1=\"0%\" y1=\"0%\" x2=\"0%\" y2=\"100%\" "
	append svg "xlink:href=\"#linearGradient1694\"/>"
	append svg "</defs>"
	append svg "<g>"
	append svg "<path d=\""
	append svg "M $p(0,x),$p(0,y)"
	append svg "L $p(1,x),$p(1,y)"
	append svg "L $p(2,x),$p(2,y)"
	append svg "L $p(3,x),$p(3,y)"
	append svg "L $p(4,x),$p(4,y)"
	append svg "L $p(5,x),$p(5,y)"
	append svg "L $p(6,x),$p(6,y)"
	append svg "z\" style=\""
	append svg "fill:url(#down-top-1683);fill-opacity:$opacity;stroke:$edge;"
	append svg "stroke-width:$strokeWidth;stroke-linecap:butt;stroke-linejoin:round;"
	append svg "stroke-miterlimit:[expr {$strokeWidth/2.0}];stroke-opacity:$opacity"
	append svg "\"/>"
	append svg "<path d=\""
	append svg "M $q(0,x),$q(0,y)"
	append svg "L $q(1,x),$q(1,y)"
	append svg "L $q(2,x),$q(2,y)"
	append svg "L $q(3,x),$q(3,y)"
	append svg "L $q(4,x),$q(4,y)"
	append svg "L $q(5,x),$q(5,y)"
	append svg "L $q(6,x),$q(6,y)"
	append svg "z\" style=\""
	append svg "fill:url(#top-down-1694);fill-opacity:$opacity;stroke:none;"
	append svg "stroke-width:$strokeWidth;stroke-linecap:butt;stroke-linejoin:round;"
	append svg "stroke-miterlimit:[expr {$strokeWidth/2.0}];stroke-opacity:$opacity"
	append svg "\"/>"
	append svg "</g>"
	append svg "</svg>"

	set img [image create photo -width $length -height $length]
	# NOTE: for any reason the resulting arrow is not anti-aliased
	::scidb::tk::image create svg $img -scale $scalef -rotate $rot

	if {$ncols != $nrows} {
		set w [expr {min($length, int(1.2*max(1, $ncols)*$size + 0.5))}]
		set h [expr {min($length, int(1.2*max(1, $nrows)*$size + 0.5))}]
		set x [expr {($length - $w)/2}]
		set y [expr {($length - $h)/2}]
		set fin [image create photo -width $w -height $h]
		$fin copy $img -from $x $y [expr {$x + $w}] [expr {$y + $h}]
		image delete $img
		set img $fin
	}

	return $img
}

namespace eval geometry {

namespace import ::tcl::mathfunc::atan2

proc rad2deg {a} { return [expr {$a*57.29577951308232311}] }
proc deg2rad {a} { return [expr {$a*0.01745329251994329509}] }
proc signum  {x} { return [expr {$x < 0 ? -1 : ($x > 0 ? +1 : 0)}] }


proc translation {x1 y1 x2 y2 dx dy} {
	set rot [atan2 [expr {abs($x2 - $x1)}] [expr {abs($y2 - $y1)}]]
	set vx [expr {cos($rot)*$dx}]
	set vy [expr {sin($rot)*$dy}]
	set x1 [expr {$x1 + $vx}]
	set y1 [expr {$y1 + $vy}]
	set x2 [expr {$x2 + $vx}]
	set y2 [expr {$y2 + $vy}]
	return [list $x1 $y1 $x2 $y2]
}


proc intersection {slope1 slope2} {
	lassign $slope1 px py qx qy
	lassign $slope2 ux uy vx vy

	set a1 [expr {$qy - $py}]
	set b1 [expr {$px - $qx}]
	set c1 [expr {$qx*$py - $px*$qy}]
	set r3 [expr {$a1*$ux + $b1*$uy + $c1}]
	set r4 [expr {$a1*$vx + $b1*$vy + $c1}]
	set a2 [expr {$vy - $uy}]
	set b2 [expr {$ux - $vx}]
	set c2 [expr {$vx*$uy - $ux*$vy}]
	set dm [expr {$a1*$b2 - $a2*$b1}]
	set of [expr {abs($dm)/2.0}]
	set x0 [expr {$b1*$c2 - $b2*$c1}]
	set y0 [expr {$a2*$c1 - $a1*$c2}]
	set x1 [expr {($x0 + [signum $x0]*$of)/$dm}]
	set y1 [expr {($y0 + [signum $y0]*$of)/$dm}]

	return [list $x1 $y1]
}

} ;# namespace geometry

set Circle [image create photo -data {
	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
}]

set Disk [image create photo -data {
	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
	oZppAC9TKScAAAAASUVORK5CYII=
}]

# NOTE: an alternative for Rectangle
#set Square [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAAJYAAACWCAQAAACWCLlpAAAICUlEQVR42u2cS2wbRRjH//uw
#	nbh1kqZJoC2USiBAKpeWVCBUKKL0AhVCQuqFAxIcuCG1Fw4ckOCAeBx64cYBIYQqKFUFQrSi
#	KhIlTSOVglSgpa/0HdIQkhDn6bWHw9qJY+9jZnZmH96ZQxTPrtfj/37fb77HyhoaxkBB24qn
#	8ATuwwYUoCEtg6CIW7hOhkaHJk+9Ou50Sp0YP0Nfi+fxOh5Cd4pEahKtXLSuDB8a/PLw5bGS
#	i1iDWmWr9gG2I+uiZQubVPOoVMYuH9v/2cHpsfrDVTUGTO0VvIfe2rSBHNrRBhMG9IYLEteP
#	Ik1zxGNZtK+Ix/Vp3+l1BQICggosWLDqjpTw0/GP3p46icqyKgBO6to+vIu1takO9KATeWRg
#	QKNcDKE8HpZQzVK5r1CDBh0GMshAA6nOGrh3Y/9zxTvDF2AtiTWg6bvwMTrtiTb0oQNm1eTo
#	FkOYxGG7Js2sv1B+Vl8TTYcJE5WqMRl6d6GwY+HG1bP2CQbw2iP4AnfZJ3eiD1mJQoHRTnk+
#	gcamvD5LRwZAGQCgo6c9+9jxQdwEAGMwg3ew05ZqDbptvwxdKOcvQgLaqf8anWc1GEtymcjm
#	c5suHrVmAJ1swwv2KXl0QXfEn/Mrp/tF906aq9Zf3+udbkdWzhDHOeJx1Swy1Vd9xrZnu55G
#	BtDxsu2COfRW9z1CdfeJx0fTC+625Obrs8jmtjK3m+J0VQ1tVS/LYD1278U6QMdu+1AXTMql
#	OX0R4rJQFjsNIhTxFcrfuhpfaUshZw/Wb3lmB2Bio70H5iktioUnYeCcb9+ji8kMmLAA5LAm
#	W9mMrA0pFKq0orEo2jtD5zTE07nZYylC6XA0TqwtcauAx19Cj2kbXD6SoNPv+iJtii/w0KtB
#	eRvKGawybbgbnm+SEXSKjc5lCAUQaDBgAciCmGg3ASArKZYKN41hi/+9BK//X6v+JQZyph3G
#	0zufyKBTXmrsJ5S/TTXWXVb3vbnFXMqmYy8US2rMZlNeq62JpekZ01xWL5k4lylU4zDF4pxt
#	8fJjKR5KuUm1JBZJdGrME3SybhMrLKu1cC7C+Yi/GxJmB4tHiBBcKP+Kh7kySQjGpfjHUvyr
#	bXBDOalxsnBOtRtGV0MIFksRZtqxMdXBDaOKpdhr5/Jx7rU+U+GcTqgmwAdZij8gSeiUEimU
#	gxvyOQ2bUFGkxryFAoqgNL04h0vl1ZNZ8Wqvi0+N2W+rC7PozDmK9np4lCI0zGK/S2EKJS41
#	ZheKk1nRt9flOZ/3Z5i8QomsIUQTS9GnQ67pTqvgPIhQXMwKs3HF3u2WhXMOZkXfXhdREmar
#	0jm9mynOkp0a8z6HIH+XZoyzwmxchV9DEBpnJaG9LoNSVA2LVsC5XzeRb++nDB2CmrMooeTg
#	nMVOKd0wqZRiiaXothbT23RbtYYgqG8oH+fxCjpphXJgVlLb67Io5dHdSWZ7nS81JiLcUOHc
#	xw2d2vfJaq+LpJTPbpic1FgcpXisy4wHznlTY9E4Z8oNWyc1ZpOf7n8TUpwvCakx+2rNIBaV
#	LJwHva0UfcP4t9eJBEpxMEtU0CmzvS4ilgpcg497ahykHczmfIzMiiY1Dj+W8hKKilnRpMay
#	cM4vlE/xTyTOaYSSUxImXDfSV6xk1RDCoRQVs+QLJa69HuSBbXqhfHPD4IDkY0g8cE4RZ6Wj
#	hsAulAfg5dcQ5DeuRDmfD+DlpMZy2uvycE7BrPg9ViarhsApVhIbV8FrCAHcsBXa60SiUNRu
#	GAXOWXc48ThnqDokqb0u1/kcmNV6jSuxQjG4YRpxzuWGYaXG0QedAXfDaGoI4aXGXMxSOA/k
#	hlHHUuGkxgJyw6S118MQyreeFR7Oo0qNA+SGKpbiZlY6Yynm0EHhnIFZSW2vh+qGcYylwgw6
#	GcWKCudx2/eY4qy073uczIrDvhcPqXziLNk1hHjjnIFZrV9DkJAbpptSvsxKbns9ZGYl5bGy
#	WLphstrrEeSGilKUzFJCMZdo4vGIfgLcMOz2elKEqtsNiXDnSz7OqQCvKEUdlKYrNRYAeIVz
#	BjdMT2ocAPCKUkwlGiUUg1hpS40FAT4dqbEQwPP/GEmrCuUC+OS212PDrLQLRcms1igJh5Ib
#	pinoZM4N1b7HxSxFKQ+xlFCC3DCtlHKMszQunKdHJmY3TLtU1L+trITi2A3TLNUKZimhOCJ4
#	RSlKZimhOBJpJRSHGyqhHACvnC+AGyqhKN1QCcUZwatBGcGr0Th0JRWjWPbPqyipKC1LCcXB
#	LDWcxyIWipdGdCUEzVjAwvRX15RYVGMWuoV53ZpRUviNMiagW5jTZ39UYviNcVgoXsOUPnvQ
#	mldyeNvVKAh+O4JJ/dMjE78rQbzGFEbx38j8aVT0b+4MfjI/pyRxGyUMo4ybP5w5AxjA3O11
#	W9ffryldHAbBFYxgcebzfaVLIAYwMnvqav+Ta7uVXM1SjeIC5ovf779xABZgACCLt8zs3ds7
#	MiroWgn2G/gLZUyc+PYtTAK2WCDkz7OZ3OpHOzMGlH3VYvZLuIoy7pw4tnf8oj1n1JKfP4a0
#	6YmNq3tWQdlXGbdxDmNYnD136Ls3bp6vzRvLueKFodO/5vv+7Vtss2sQWsqsjKCEeUzhOs5j
#	BIsYOTPw4bH3524tn7FSDx09/Tsf3rOhv9CbyxnQUyQXQQVllFGChZnR8tipA2e/Lg5jof6c
#	ZjU0dOGeF3dlH1zoKOU3be59IDXOV/rlqDmXLbZPHjn8zzD+RqnxjP8BfPmoXlir33YAAAAA
#	SUVORK5CYII=
#}]

# fdff00 605a00
# ff8100 602e00
set Star "
<svg width=\"300px\" height=\"275px\" viewBox=\"0 0 300 275\"
     xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">
  <polygon fill=\"#ff8100\" stroke=\"#602e00\" stroke-width=\"15\" 
            points=\"150,25  179,111 269,111 197,165
                    223,251  150,200 77,251  103,165
                    31,111 121,111\" />
</svg>
"

# TODO: use rounded rect (we need a SVG extension for this task)
set Rectangle "
<svg>
  <defs>
    <linearGradient
       id=\"linearGradient2190\">
      <stop
         style=\"stop-color:#ffffff;stop-opacity:1\"
         offset=\"0\" />
      <stop
         style=\"stop-color:#ffffff;stop-opacity:0\"
         offset=\"1\" />
    </linearGradient>
    <linearGradient
       x1=\"-78.461533\"
       y1=\"-59.999996\"
       x2=\"100\"
       y2=\"212.30769\"
       id=\"linearGradient2196\"
       xlink:href=\"#linearGradient2190\"
       gradientUnits=\"userSpaceOnUse\"
       gradientTransform=\"matrix(1,0,0,0.857142,0,1.42858)\" />
  </defs>
  <g>
    <rect
       width=\"252\" height=\"252\" x=\"6\" y=\"6\"
       style=\"opacity:1;color:#000000;fill:#000000;fill-opacity:0.50196078;fill-rule:evenodd;stroke:none;stroke-width:1.39999998;stroke-linecap:butt;stroke-linejoin:miter;marker:none;marker-start:none;marker-mid:none;marker-end:none;stroke-miterlimit:4;stroke-opacity:1\" />
    <rect
       width=\"250\" height=\"250\" x=\"5\" y=\"5\"
       style=\"opacity:1;color:#000000;fill:#c#;fill-opacity:1;fill-rule:evenodd;stroke:none;stroke-width:1.39999998;stroke-linecap:butt;stroke-linejoin:miter;marker:none;marker-start:none;marker-mid:none;marker-end:none;stroke-miterlimit:4;troke-opacity:1\" />
    <rect
       width=\"240\" height=\"240\" x=\"10\" y=\"10\"
       style=\"opacity:1;color:#000000;fill:url(#linearGradient2196);fill-opacity:1;fill-rule:evenodd;stroke:none;stroke-width:1.39999998;stroke-linecap:butt;stroke-linejoin:miter;marker:none;marker-start:none;marker-mid:none;marker-end:none;stroke-miterlimit:4;stroke-opacity:1\" />
  </g>
</svg>
"
} ;# namespace diagram
} ;# namespace board

# vi:set ts=3 sw=3:
