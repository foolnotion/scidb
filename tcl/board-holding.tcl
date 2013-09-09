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
# Copyright: (C) 2012-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source board-holding

namespace eval board {
namespace eval holding {

array set Index { q 0 r 1 b 2 n 3 p 4 }


proc computeWidth {size}	{ return [expr {$size + 2}] }
proc computeHeight {size}	{ return [expr {5*$size + 6}] }


proc new {w color size args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	set Vars(width) [computeWidth $size]
	set Vars(height) [computeHeight $size]
	set Vars(size) $size
	set Vars(color) $color
	set Vars(selected) ""
	set Vars(selection) ""
	set Vars(afterid) {}
	set Vars(pieces) {0 0 0 0 0}
	set Vars(piece) ""
	set Vars(targets) $args
	lappend Vars(targets) $w

   tk::canvas $w \
		-width $Vars(width) \
		-height $Vars(height) \
		-borderwidth 0 \
		-relief raised \
		-takefocus 0 \
		;

   [namespace parent]::registerSize $size
   [namespace parent]::setupSquares $size

   rebuild $w
	bind $w <Destroy> [namespace code [list Destroy $w]]

   return $w
}


proc resize {w size} {
   variable ${w}::Vars

   if {$size == $Vars(size)} { return }

	after cancel $Vars(afterid)
	set oldSize $Vars(size)

	set Vars(width) [computeWidth $size]
	set Vars(height) [computeHeight $size]
	set Vars(size) $size

	$w configure -width $Vars(width) -height $Vars(height)
	$w xview moveto 0
	$w yview moveto 0

	::board::registerSize $size
	::board::setupSquares $size

	set Vars(afterid) [after 50 [namespace code [list [namespace parent]::setupPieces $size]]]

	rebuild $w
	::board::unregisterSize $oldSize
}


proc width {w}		{ return [set [namespace current]::${w}::Vars(width)] }
proc height {w}	{ return [set [namespace current]::${w}::Vars(height)] }


proc select {w piece} {
	variable ${w}::Vars

	deselect $w
	set piece [string tolower $piece]
	set Vars(selection) $piece
	$w coords $Vars(selected) {*}[$w coords input-$piece]
	$w itemconfigure $Vars(selected) -state normal
}


proc deselect {w} {
	variable ${w}::Vars

	set Vars(selection) ""
	$w itemconfigure $Vars(selected) -state hidden
}


proc pieceCount {w piece} {
	variable ${w}::Vars
	variable Index

	set piece [string tolower $piece]
	return [lindex $Vars(pieces) $Index($piece)]
}


proc selected? {w} {
	variable ${w}::Vars

	set piece $Vars(selection)
	if {$Vars(color) eq "w"} { set piece [string toupper $piece] }
	return $piece
}


proc finishDrop {w} {
	variable ${w}::Vars

	set p [string tolower $Vars(piece)]
	$w itemconfigure piece-$p -state normal
	set Vars(piece) ""
}


proc update {w piecesInHand} {
	variable ${w}::Vars

	if {$piecesInHand eq $Vars(pieces)} { return }
	set Vars(pieces) $piecesInHand

	foreach n $piecesInHand p {q r b n p} {
		if {$n > 1} {
			$w itemconfigure count-$p -state normal -text $n
			$w itemconfigure shadow-$p -state normal -text $n
		} else {
			$w itemconfigure count-$p -state hidden
			$w itemconfigure shadow-$p -state hidden
		}
		if {$n == 0} {
			$w delete piece-$p
		} elseif {[llength [$w find withtag piece-$p]] == 0} {
			$w create image {*}[$w coords square-$p]          \
				-image photo_Piece($Vars(color)$p,$Vars(size)) \
				-anchor nw                                     \
				-tag piece-$p                                  \
				;
			$w raise shadow-$p
			$w raise count-$p
			$w raise input-$p
		}
	}
}


proc rebuild {w} {
	variable ${w}::Vars
	variable Digit

	set pieces $Vars(pieces)
	set Vars(pieces) {0 0 0 0 0}
	$w delete border
	$w delete $Vars(selected)
	foreach p {q r b n p} { $w delete square-$p input-$p piece-$p count-$p shadow-$p }
	$w create rectangle 0 0 $Vars(width) $Vars(height) -tag border -width 0
	if {$Vars(color) eq "w"} {
		set color dark
		set fill yellow
		set shadow black
		lassign { 0 1} tx ty
		lassign {-1 0} sx sy
	} else {
		set color lite
		set fill red
		set shadow white
		lassign {-1 0} tx ty
		lassign { 0 1} sx sy
	}
	set fontSize [expr {min(18, max(7, int(($Vars(size))/3.0 + 0.5) + 2))}]
	array set fopts [font actual TkTextFont]
	set font [list $fopts(-family) $fontSize]

	set y 1
	foreach p {q r b n p} {
		$w create image 1 $y -image photo_Square($color,$Vars(size)) -tags square-$p -anchor nw
		$w create text [expr {$Vars(size) + $tx}] [expr {$y + $ty - 1}] \
			-tag shadow-$p -fill $shadow -font $font -anchor ne -state hidden
		$w create text [expr {$Vars(size) + $sx}] [expr {$y + $sy - 1}] \
			-tag count-$p -fill $fill -font $font -anchor ne -state hidden
		$w create rectangle 1 $y $Vars(size) [expr {$y + $Vars(size) - 1}] -tag input-$p -outline {}
		if {[llength $Vars(targets)]} {
			$w bind input-$p <ButtonPress-1> [namespace code [list StartDrag $w %X %Y $p]]
			$w bind input-$p <Button1-Motion> [namespace code [list DragPiece $w %X %Y %s]]
			$w bind input-$p <ButtonRelease-1> [namespace code [list FinishDrag $w %X %Y %s]]
		}
		set y [expr {$y + $Vars(size) + 1}]
	}

	set Vars(selected) [board::diagram::makeHiliteRect $w selected {} $Vars(size) 1 1]
	foreach p {q r b n p} { $w raise shadow-$p; $w raise count-$p; $w raise input-$p }
	update $w $pieces
}


proc StartDrag {w x y piece} {
	variable ${w}::Vars
	variable Index

	set Vars(dragging) 0
	set Vars(n) 0

	if {[::scidb::pos::stm] ne $Vars(color)} { return }
#	set Vars(cursor) [$w cget -cursor]
	if {$Vars(color) eq "w"} { set piece [string toupper $piece] }

	set Vars(x) $x
	set Vars(y) $y
	set Vars(piece) $piece

	if {[llength $Vars(targets)] > 1} {
		set Vars(n) [lindex $Vars(pieces) $Index([string tolower $piece])]
	}
}


proc DragPiece {w x y state} {
	variable ${w}::Vars

	if {$Vars(n) == 0} { return }

	if {!$Vars(dragging)} {
		if {[expr {abs($Vars(x) - $x)}] <= 3 && [expr {abs($Vars(y) - $y)}] <= 3} { return }

		set Vars(dragging) 1
#		$w configure -cursor hand2
		set p [string tolower $Vars(piece)]
		set img photo_Piece($Vars(color)$p,$Vars(size))
		foreach t $Vars(targets) {
			$t create image 0 0 -image $img -state hidden -tag drag-piece -anchor center
			$t raise drag-piece
		}
		if {$Vars(n) == 1} { $w itemconfigure piece-$p -state hidden }
		lassign [$w coords square-$p] x0 y0
		set xc [expr {$x0 + $Vars(size)/2}]
		set yc [expr {$y0 + $Vars(size)/2}]
		set Vars(dx) [expr {$x - [winfo rootx $w] - $xc}]
		set Vars(dy) [expr {$y - [winfo rooty $w] - $yc}]
	}

	set i 0
	foreach t $Vars(targets) {
		set x0 [expr {$x - [winfo rootx $t] - $Vars(dx)}]
		set y0 [expr {$y - [winfo rooty $t] - $Vars(dy)}]
		$t coords drag-piece $x0 $y0
		$t itemconfigure drag-piece -state normal
	}

	set x [expr {$x - $Vars(dx)}]
	set y [expr {$y - $Vars(dy)}]

	event generate $w <<InHandDropPosition>> -x $x -y $y -state $state -data $Vars(piece)
}


proc FinishDrag {w x y state} {
	variable ${w}::Vars

#	$w configure -cursor $Vars(cursor)

	if {$Vars(n) == 0} {
		deselect $w
		if {$Vars(selection) ne ""} {
			event generate $w <<InHandSelection>> -data " "
		}
	} else {
		if {$Vars(dragging)} {
			set Vars(dragging) 0

			foreach t $Vars(targets) {
				$t delete drag-piece
			}

			set p [string tolower $Vars(piece)]
			set x [expr {$x - $Vars(dx)}]
			set y [expr {$y - $Vars(dy)}]
			event generate $w <<InHandPieceDrop>> -x $x -y $y -state $state -data $Vars(piece)
		} elseif {[::scidb::pos::stm] eq $Vars(color)} {
			if {[string toupper $Vars(selection)] eq [string toupper $Vars(piece)]} {
				deselect $w
				event generate $w <<InHandSelection>> -data " "
			} else {
				if {$Vars(selection) ne ""} { deselect $w }
				select $w $Vars(piece)
				event generate $w <<InHandSelection>> -data $Vars(piece)
			}
		}
	}
}


proc Destroy {w} {
	variable ${w}::Vars

	after cancel $Vars(afterid)
	[namespace parent]::unregisterSize $Vars(size)
	namespace delete [namespace current]::${w}
}

} ;# namespace holding
} ;# namespace board

# vi:set ts=3 sw=3:
