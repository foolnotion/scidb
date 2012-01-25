# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2011-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
package require Tkhtml 3.1
package require scrolledframe

rename html __html_widget

proc html {args} {
	if {[llength $args] == 0} {
		return error -code "wrong # args: should be \"html pathName ?options?\""
	}

	if {[winfo exists [lindex $args 0]]} {
		return error -code "window name \"[lindex $args 0]\" already exists"
	}

	if {[llength $args] % 2 == 0} {
		return error -code "value for \"[lindex $args end]\" missing"
	}

	return [html::Build {*}$args]
}

namespace eval html {

namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::max

variable Margin	8 ;# do not change!
variable MaxWidth	12000


proc Build {w args} {
	variable MaxWidth

	array set opts {
		-width				800
		-height				600
		-background			white
		-borderwidth		{}
		-relief				{}
		-exportselection	no
		-center				no
		-imagecmd			{}
		-doublebuffer		yes
		-delay				0
		-css					{}
	}

	array set opts $args

	set options {}
	set htmlOptions {}
	foreach name [array names opts] {
		switch -- $name {
			-delay - -css - -center {}

			-imagecmd - -doublebuffer - -exportselection -
			-selectbackground - -selectforeground -
			-inactiveselectbackground - -inactiveselectforeground {
				set value $opts($name)
				if {[llength $value]} { lappend htmlOptions $name $value }
			}

			default {
				set value $opts($name)
				if {[llength $value]} { lappend options $name $value }
			}
		}
	}

	if {!$opts(-center)} { lappend options -avoidconfigureresize yes }
	set parent [::scrolledframe $w -fill both {*}$options]
	if {!$opts(-center)} {
		bind $parent <<ScrollbarChanged>> [namespace code { ConfigureFrame %W {*}%d }]
	}
	set html $parent.html

	namespace eval [namespace current]::$parent {}
	variable [namespace current]::${parent}::Priv
	variable [namespace current]::${parent}::HoverNodes
	variable [namespace current]::${parent}::ActiveNodes1
	variable [namespace current]::${parent}::ActiveNodes2
	variable [namespace current]::${parent}::ActiveNodes3

	array set Priv {
		onmouseover		{}
		onmouseout		{}
		onmousedown1	{}
		onmouseup1		{}
		onmousedown2	{}
		onmouseup2		{}
		onmousedown3	{}
		onmouseup3		{}
		nodeList			{}
		afterId			{}
		request			{}
		bbox				{}
		pointer			{0 0}
		focus				0
		sel:state		0
	}

	set Priv(delay)  $opts(-delay)
	set Priv(center) $opts(-center)
	set Priv(bw)     $opts(-borderwidth)
	set Priv(css)    $opts(-css)

	if {[llength $Priv(bw)] == 0} { set Priv(bw) 0 }

	rename ::$w $w.__html__
	proc ::$w {command args} "[namespace current]::WidgetProc $w $parent \$command {*}\$args"

	__html_widget $html {*}$htmlOptions -shrink yes
	grid $html

	SelectionClear $html
	selection handle $html [namespace code [list SelectionHandler $html]]

	if {$Priv(center)} {
		grid anchor $parent center
	} else {
		bind $w <Configure> [namespace code [list Configure $parent %w %#]]
	}

	return $w
}


proc WidgetProc {w parent command args} {
	variable ${parent}::Priv

	switch -glob -- $command {
		parse {
			variable Margin
			variable MaxWidth

			array unset [namespace current]::HoverNodes
			array unset [namespace current]::ActiveNodes1
			array unset [namespace current]::ActiveNodes2
			array unset [namespace current]::ActiveNodes3
			set Priv(nodeList) {}
			$parent.html reset
			$parent xview moveto 0
			$parent yview moveto 0
			if {$Priv(center)} {
				$parent.html configure -width $MaxWidth
				update idletasks
			}
			$parent.html parse -final [lindex $args 0]
			if {[string length $Priv(css)]} { $parent.html style -id user $Priv(css) }
			set Priv(bbox) [ComputeBoundingBox $parent.html [$parent.html node] $Priv(center)]
			lset Priv(bbox) 2 [min [lindex $Priv(bbox) 2] 4000]
#			lset Priv(bbox) 3 [min [lindex $Priv(bbox) 3] 8000]
			if {[llength $Priv(bbox)]} {
				if {$Priv(center)} {
					lset Priv(bbox) 2 [expr {[lindex $Priv(bbox) 2] + $Margin}]
					$parent.html configure -width [lindex $Priv(bbox) 2]
				} else {
					lset Priv(bbox) 3 [expr {[lindex $Priv(bbox) 3] + $Margin}]
					$parent.html configure -height [lindex $Priv(bbox) 3]
				}
				update idletasks
				$parent resize
			}
			return
		}

		handler - search - style {
			return [$parent.html $command {*}$args]
		}

		onmouse* {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <script>\""
			}
			if {![info exists Priv($command)]} {
				append msg "unknown event type \""
				append msg $command
				append msg "\": should be one of"
				append msg [join [array names Priv onmouse*] ", "]
				error $msg
			}
			lappend Priv($command) [lindex $args 0]
			return
		}

		stimulate {
			array unset HoverNodes
			set Priv(nodeList) {}
			set x [expr {[winfo pointerx .] - [winfo rootx $parent.html]}]
			set y [expr {[winfo pointery .] - [winfo rooty $parent.html]}]
			event generate $parent.html <Motion> -x $x -y $y
			return
		}

		drawable	{ return $parent.html }
		pointer	{ return $Priv(pointer) }
		font		{ return HtmlFont }

		bbox {
			if {[llength $args] == 0} {
				return $Priv(bbox)
			}
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command ?<node>?\""
			}
			return [$parent.html bbox [lindex $args 0]]
		}

		viewbox {
			return [$parent viewbox]
		}

		size {
			lassign $Priv(bbox) x y w h
			set w [expr {$w + 2*$x}]
			set h [expr {$h + 2*$y}]
			return [list $w $h]
		}

		xview - yview {
			return [$parent $command {*}$args]
		}

		scrollto {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <px>\""
			}
			variable Margin
			set height [winfo height $parent.html]
			set y [expr {max(0, [lindex $args 0] - $Margin)}]
			set fraction [expr {double($y)/double($height)}]
			return [$parent yview moveto $fraction]
		}

		root {
			return [$parent.html node]
		}

		focusin {
			if {!$Priv(focus)} {
				set Priv(focus) 1
				if {[$parent.html cget -exportselection]} {
					$parent.html tag configure selection \
						-foreground [$parent.html cget -selectforeground] \
						-background [$parent.html cget -selectbackground] \
						;
				}
			}
			return
		}

		focusout {
			if {$Priv(focus)} {
				set Priv(focus) 0
				if {[$parent.html cget -exportselection]} {
					$parent.html tag configure selection \
						-foreground [$parent.html cget -inactiveselectforeground] \
						-background [$parent.html cget -inactiveselectbackground] \
						;
				}
			}
			return
		}
	}

	return [$w.__html__ $command {*}$args]
}


proc Configure {parent width req} {
	variable ${parent}::Priv

	if {[winfo width $parent.html] == $width} { return }

	# This (using the serial field from the event) is working under x11
	# to prevent endless loops. But does this work with windows and mac?
	if {$req == $Priv(request)} { return }
	set Priv(request) $req

	$parent.html configure -width [expr {max(1, $width - 2*$Priv(bw) - [$parent vsbwidth])}]
	after cancel $Priv(afterId)
	set afterId [after idle [namespace code [list ComputeSize $parent $req]]]
}


proc ConfigureFrame {parent sb visible} {
	variable ${parent}::Priv

	if {[$sb cget -orient] eq "vertical"} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
		set width [$parent.html cget -width]
		incr width [$parent vsbwidth]
		Configure $parent $width 0
	}
}


proc ComputeSize {parent req} {
	variable ${parent}::Priv
	variable Margin

	after cancel $Priv(afterId)
	set Priv(afterId) {}

	set Priv(bbox) [ComputeBoundingBox $parent.html [$parent.html node] $Priv(center)]
	if {[llength $Priv(bbox)]} {
		lset Priv(bbox) 3 [expr {[lindex $Priv(bbox) 3] + $Margin}]
		$parent.html configure -height [lindex $Priv(bbox) 3]
		update idletasks
		$parent resize
	}
}


proc ComputeBoundingBox {w node skipBody} {
	variable MaxWidth
	variable Margin

	set tag [$node tag]
	set result {}

	if {[string length $tag]} {
		switch -- $tag {
			html {}
			head { return $result }
			default {
				if {!$skipBody || $tag ne "body"} {
					set bbox [$w bbox $node]
					if {[llength $bbox]} {
						if {[lindex $bbox 2] == $MaxWidth - $Margin} { lset bbox 2 0 }
						set result $bbox
					}
				}
			}
		}
	}

	if {[llength $result] == 0} {
		foreach n [$node children] {
			set bbox [ComputeBoundingBox $w $n $skipBody]
			if {[llength $bbox] > 0 && [lindex $bbox 2] > 0} {
				set result [CombineBox $result $bbox]
			}
		}
	}

	return $result
}


proc CombineBox {box1 box2} {
	if {[llength $box1] == 0} { return $box2 }
	if {[llength $box2] == 0} { return $box1 }

	lassign $box1 x11 y11 x12 y12
	lassign $box2 x21 y21 x22 y22

	return [list [min $x11 $x21] [min $y11 $y21] [max $x12 $x22] [max $y12 $y22]]
}


proc Motion {w x y state} {
	variable [winfo parent $w]::Priv

	SelectionExtend $w $x $y

	set Priv(pointer) [list $x $y]
	if {$state >= 256} { return }

	set nodelist [lindex [$w node $x $y] end]
	if {$Priv(nodeList) eq $nodelist} { return }

	if {[llength $Priv(afterId)]} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
	}

	if {$Priv(delay)} {
		set Priv(afterId) [after $Priv(delay) [namespace code [list HandleMotion $w $nodelist]]]
	} else {
		HandleMotion $w $nodelist
	}
}


proc HandleMotion {w nodelist} {
	variable [winfo parent $w]::HoverNodes
	variable [winfo parent $w]::Priv

	set Priv(nodeList) $nodelist
	set events(onmouseover) {}

	foreach node $nodelist {
		if {[string length [$node tag]] == 0} { set node [$node parent] }

		for {set n $node} {[string length $n] > 0} {set n [$n parent]} {
			if {[info exists hoverNodes($n)]} { break }

			if {[info exists HoverNodes($n)]} {
				unset HoverNodes($n)
			} else {
				lappend events(onmouseover) $n
			}

			set hoverNodes($n) 1
		}
	}

	set events(onmouseout) [array names HoverNodes]

	array unset HoverNodes
	array set HoverNodes [array get hoverNodes]

	set eventlist {}

	foreach key {onmouseout onmouseover} {
		foreach node $events($key) {
			lappend eventlist $key $node
		}
	}

	GenerateEvents $w $eventlist
}


proc Leave {w} {
	variable [winfo parent $w]::HoverNodes
	variable [winfo parent $w]::Priv

	if {[llength $Priv(afterId)]} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
	}

	set eventlist {}

	foreach node [array names HoverNodes] {
		lappend eventlist onmouseout $node
	}

	array unset HoverNodes
	GenerateEvents $w $eventlist
}


proc Mapped {w} {
	lassign [winfo pointerxy $w] x y
	set x [expr {$x - [winfo rootx $w]}]
	set y [expr {$y - [winfo rooty $w]}]
	Motion $w $x $y 0
}


proc GenerateEvents {w eventlist} {
	variable [winfo parent $w]::Priv

	foreach {event node} $eventlist {
		if {[llength $node] == 0 || [llength [info commands $node]] > 0} {
			foreach script $Priv($event) {
				{*}$script $node
			}
		}
	}
}


proc ButtonPress {w x y k {state 0}} {
	variable [winfo parent $w]::ActiveNodes$k
	variable [winfo parent $w]::Priv

	if {$k == 1} { SelectionAnchor $w $x $y $state }

	array unset ActiveNodes$k
	set node [lindex [$w node $x $y] end]
	if {[string length $node]  > 0 && [string length [$node tag]] == 0} { set node [$node parent] }
	if {[string length $node] == 0 || [string length [$node tag]] == 0} { set node [$w node] }

	for {set n $node} {[string length $n] > 0} {set n [$n parent]} {
		set ActiveNodes${k}($n) 1
	}

	set eventlist {}
	foreach node [array names ActiveNodes$k] {
		lappend eventlist onmousedown${k} $node
	}
	lappend eventlist onmousedown${k} {}

	GenerateEvents $w $eventlist
}


proc ButtonRelease {w x y k} {
	variable [winfo parent $w]::ActiveNodes$k
	variable [winfo parent $w]::Priv

	if {$k == 1} { SelectionFinish $w $x $y }

	set node [lindex [$w node $x $y] end]
	if {[string length $node]  > 0 && [string length [$node tag]] == 0} { set node [$node parent] }
	if {[string length $node] == 0 || [string length [$node tag]] == 0} { set node [$w node] }

	set eventlist {}
	foreach node [array names ActiveNodes$k] {
		lappend eventlist onmouseup${k} $node
	}
	lappend eventlist onmouseup${k} {}

	GenerateEvents $w $eventlist
	array unset ActiveNodes$k
}


proc SelectionAnchor {w x y state} {
	variable [winfo parent $w]::Priv

	if {![$w cget -exportselection]} { return }

	if {($state & 1) && $Priv(sel:moved)} {
		set Priv(sel:to:node) ""
	} else {
		SelectionClear $w
	}

	set Priv(sel:state) true
	set Priv(sel:mode) char
	set Priv(sel:ignore) 0
	set Priv(sel:x) $x
	set Priv(sel:y) $y

	SelectionExtend $w $x $y
}


proc SelectionFinish {w x y} {
	variable [winfo parent $w]::Priv
	set Priv(sel:state) false
}


proc SelectionExtend {w x y {node {}}} {
	variable [winfo parent $w]::Priv

	if {![$w cget -exportselection]} { return }
	if {!$Priv(sel:state)} { return }
	if {$Priv(sel:ignore)} { return }

	set to [$w node -index $x $y]
	lassign $to toNode toIdx

	if {[llength $node] > 0 && [llength $toNode] > 0} {
		if {[$node stacking] ne [$toNode stacking]} { set to {} }
	}

	if {[llength $to] > 0} {
		if {[llength $Priv(sel:from:node)] == 0} {
			set Priv(sel:from:node) $toNode
			set Priv(sel:from:index) $toIdx
		}

		if {	$toNode != $Priv(sel:from:node)
			|| $toIdx !=  $Priv(sel:from:index)
			|| abs($x - $Priv(sel:x)) >= 3
			|| abs($y - $Priv(sel:y)) >= 3} {
			set Priv(sel:moved) 1
		}

		set rc [catch {
			if {$Priv(sel:to:node) ne $toNode || $toIdx != $Priv(sel:to:index)} {
				if {$Priv(sel:moved)} {
					switch -- $Priv(sel:mode) {
						char {
							if {[llength $Priv(sel:to:node)] > 0} {
								$w tag remove selection $Priv(sel:to:node) $Priv(sel:to:index) $toNode $toIdx
							}
							$w tag add selection $Priv(sel:from:node) $Priv(sel:from:index) $toNode $toIdx
							if {$Priv(sel:from:node) ne $toNode || $Priv(sel:from:index) != $toIdx} {
								selection own $w
							}
						}

						word {
							if {[llength $Priv(sel:to:node)] > 0} {
								$w tag remove selection $Priv(sel:to:node) $Priv(sel:to:index) $toNode $toIdx
								SelectionUntagWord $w $Priv(sel:to:node) $Priv(sel:to:index)
							}

							$w tag add selection $Priv(sel:from:node) $Priv(sel:from:index) $toNode $toIdx
							SelectionTagWord $w $toNode $toIdx
							SelectionTagWord $w $Priv(sel:from:node) $Priv(sel:from:index)
							selection own $w
						}

						block {
							set toBlock2  [SelectionToBlock $w $toNode $toIdx]
							set fromBlock [SelectionToBlock $w $Priv(sel:from:node) $Priv(sel:from:index)]

							if {[llength $Priv(sel:to:node)] > 0} {
								set toBlock [SelectionToBlock $w $Priv(sel:to:node) $Priv(sel:to:index)]
								$w tag remove selection $Priv(sel:to:mode) $Priv(sel:to:index) $toNode $toIdx
								$w tag remove selection {*}$toBlock
							}

							$w tag add selection $Priv(sel:from:node) $Priv(sel:from:index) $toNode $toIdx
							$w tag add selection {*}$toBlock2
							$w tag add selection {*}$fromBlock
							selection own $w
						}
					}
				}

				set Priv(sel:to:node) $toNode
				set Priv(sel:to:index) $toIdx
			}
		} msg]

		if {$rc && [regexp {[^ ]+ is an orphan} $msg]} {
			SelectionClear $w
		}
	}

	set v [winfo parent $w]
	lassign [$v viewbox] x0 y0 vw vh

	set motioncmd {}
	if {$y > $y0 + $vh} {
		if {$y < [winfo height $w]} {
			set motioncmd [list $v yview scroll 1 units]
		}
	} elseif {$y < $y0} {
		if {$y >= 0} {
			set motioncmd [list $v yview scroll -1 units]
		}
	}

	if {$motioncmd ne ""} {
		set Priv(sel:ignore) 1
		{*}$motioncmd
		update idletasks
		after cancel $Priv(sel:afterid)
		set Priv(sel:afterid) [after 200 [namespace code [list SelectionContinueMotion $w]]]
	}

	if {$x > $x0 + $vw} {
		if {$x < [winfo width $w]} {
			set motioncmd [list $v xview scroll 1 units]
		}
	} elseif {$x < 0} {
		if {$x >= 0} {
			set motioncmd [list $v xview scroll -1 units]
		}
	}

	if {$motioncmd ne ""} {
		set Priv(sel:ignore) 1
		{*}$motioncmd
		update idletasks
		after cancel $Priv(sel:afterid)
		set Priv(sel:afterid) [after 200 [namespace code [list SelectionContinueMotion $w]]]
	}
}


proc SelectionContinueMotion {w} {
	variable [winfo parent $w]::Priv

	set Priv(sel:ignore) 0
	set Priv(sel:afterid) {}
	set x [expr [winfo pointerx $w] - [winfo rootx $w]]
	set y [expr [winfo pointery $w] - [winfo rooty $w]]
	set node [lindex [$w node $x $y] 0]
	SelectionExtend $w $x $y $node
}


proc Select {w x y mode} {
	variable [winfo parent $w]::Priv

	if {![$w cget -exportselection]} { return }

	SelectionClear $w
	set Priv(sel:mode) $mode
	set Priv(sel:state) true
	set Priv(sel:moved) 1
	SelectionExtend $w $x $y
}


proc SelectExtend {w x y mode} {
	variable [winfo parent $w]::Priv

	if {![$w cget -exportselection]} { return }

	if {!$Priv(sel:moved)} { SelectionClear $w }

	set Priv(sel:to:node) ""
	set Priv(sel:mode) $mode
	set Priv(sel:state) true
	set Priv(sel:moved) 1

	SelectionExtend $w $x $y
}


proc SelectionClear {w} {
	variable [winfo parent $w]::Priv

	if {![$w cget -exportselection]} { return }

	$w tag delete selection
	$w tag configure selection \
		-foreground [$w cget -selectforeground] \
		-background [$w cget -selectbackground] \
		;
	set Priv(sel:from:node) ""
	set Priv(sel:to:node) ""
	set Priv(sel:moved) 0
	set Priv(sel:ignore) 0
	set Priv(sel:afterid) {}
}


proc SelectionTagWord {w node idx} {
	lassign [SelectionToWord $node $idx] i1 i2
	$w tag add selection $node $i1 $node $i2
}


proc SelectionUntagWord {w node idx} {
	lassign [SelectionToWord $node $idx] i1 i2
	$w tag remove selection $node $i1 $node $i2
}


proc SelectionToWord {node idx} {
	set t [$node text]
	set cidx [::tkhtml::charoffset $t $idx]
	set cidx1 [string wordstart $t $cidx]
	set cidx2 [string wordend $t $cidx]
	set idx1 [::tkhtml::byteoffset $t $cidx1]
	set idx2 [::tkhtml::byteoffset $t $cidx2]
	return [list $idx1 $idx2]
}


proc SelectionToBlock {w node idx} {
	set t [$w text text]
	set offset [$w text offset $node $idx]

	set start [string last "\n" $t $offset]
	if {$start < 0} {set start 0}
	set end [string first "\n" $t $offset]
	if {$end < 0} {set end [string length $t]}

	set startIdx [$w text index $start]
	set endIdx   [$w text index $end]

	return [concat $startIdx $endIdx]
}


proc SelectionGet {w offset maxChars} {
	variable [winfo parent $w]::Priv

	set t  [$w text text]
	set n1 $Priv(sel:from:node)
	set i1 $Priv(sel:from:index)
	set n2 $Priv(sel:to:node)
	set i2 $Priv(sel:to:index)

	set stridxA [$w text offset $Priv(sel:from:node) $Priv(sel:from:index)]
	set stridxB [$w text offset $Priv(sel:to:node) $Priv(sel:to:index)]
	if {$stridxA > $stridxB} { lassign [list $stridxB $stridxA] stridxA stridxB }

	if {$Priv(sel:mode) eq "word"} {
		set stridxA [string wordstart $t $stridxA]
		set stridxB [string wordend $t $stridxB]
	}
	if {$Priv(sel:mode) eq "block"} {
		set stridxA [string last "\n" $t $stridxA]
		if {$stridxA < 0} {set stridxA 0}
		set stridxB [string first "\n" $t $stridxB]
		if {$stridxB < 0} {set stridxB [string length $t]}
	}

	set text [string range [$w text text] $stridxA [expr $stridxB - 1]]
	set text [string range $text $offset [expr $offset + $maxChars]]

	return $text
}


proc SelectionHandler {w args} {
	variable [winfo parent $w]::Priv

	if {![$w cget -exportselection]} { return "" }
	set eval [concat SelectionGet $w $args]

	if {[catch [list uplevel $eval] result]} {
		set cmd [list bgerror $result]
		set error [list $::errorInfo $::errorCode]
		after idle [list lassign [list $error $cmd] ::errorInfo ::errorCode]
		set ::errorInfo ""
		return ""
	}

	return $result
}


bind Html <Motion>				[namespace code { Motion %W %x %y %s }]
bind Html <Leave>					[namespace code { Leave %W }]
bind Html <ButtonPress-1>		[namespace code { ButtonPress %W %x %y 1 %s }]
bind Html <ButtonRelease-1>	[namespace code { ButtonRelease %W %x %y 1 }]
bind Html <ButtonPress-2>		[namespace code { ButtonPress %W %x %y 2 }]
bind Html <ButtonRelease-2>	[namespace code { ButtonRelease %W %x %y 2 }]
bind Html <ButtonPress-3>		[namespace code { ButtonPress %W %x %y 3 }]
bind Html <ButtonRelease-3>	[namespace code { ButtonRelease %W %x %y 3 }]
bind Html <Unmap>					[namespace code { Leave %W }]
bind Html <Map>					[namespace code { Mapped %W }]

bind Html <Double-ButtonPress-1>			[namespace code { Select %W %x %y word }]
bind Html <Triple-ButtonPress-1>			[namespace code { Select %W %x %y block }]
bind Html <Shift-Double-ButtonPress-1>	[namespace code { SelectExtend %W %x %y word }]
bind Html <Shift-Triple-ButtonPress-1>	[namespace code { SelectExtend %W %x %y block }]

switch [tk windowingsystem] {
	win32 {
		bind Html <MouseWheel> { [winfo parent %W] yview scroll [expr %D/-120] units; break }
	}
	aqua {
		bind Html <MouseWheel> { [winfo parent %W] yview scroll [expr %D*-1] units; break }
	}
	x11 {
		bind Html <ButtonPress-4> { [winfo parent %W] yview scroll -1 units; break }
		bind Html <ButtonPress-5> { [winfo parent %W] yview scroll +1 units; break }
	}
}

} ;# namespace html

# vi:set ts=3 sw=3:
