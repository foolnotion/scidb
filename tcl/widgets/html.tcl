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


proc defaultCSS {monoFamilies textFamilies} {
	set css "
		:link    { color: blue2; text-decoration: none; }
		:visited { color: purple; text-decoration: none; }
		/*:user	{ color: red3; text-decoration: none; }*/
		:user		{ color: blue2; text-decoration: underline; }	/* http link */
		:user2	{ color: purple; text-decoration: underline; }	/* http visited */
		:user3	{ color: black; text-decoration: underline; }	/* invalid link */
		:hover   { text-decoration: underline; background: yellow; }
		.match	{ background: yellow; color: black; }
		html		{ font-family: [join $textFamilies ","]; }
		pre, tt, code, kbd { font-family: [join $monoFamilies ","]; }
	"
}


proc Build {w args} {
	array set opts {
		-width				800
		-height				600
		-background			white
		-borderwidth		{}
		-relief				{}
		-exportselection	no
		-center				no
		-fittowidth			no
		-imagecmd			{}
		-doublebuffer		yes
		-latinligatures	yes
		-useHorzScroll		yes
		-useVertScroll		yes
		-keepHorzScroll	no
		-keepVertScroll	no
		-showhyphens		0
		-delay				0
		-css					{}
	}

	array set opts $args

	set options {}
	set htmlOptions {}
	foreach name [array names opts] {
		switch -- $name {
			-delay - -css - -center - -fittowidth -
			-useHorzScroll - -useVertScroll - -keepHorzScroll - -keepVertScroll {}

			-imagecmd - -doublebuffer - -latinligatures - -exportselection -
			-selectbackground - -selectforeground - -showhyphens -
			-inactiveselectbackground - -inactiveselectforeground - 
			-width - -height {
				set value $opts($name)
				if {[llength $value]} { lappend htmlOptions $name $value }
			}

			default {
				set value $opts($name)
				if {[llength $value]} { lappend options $name $value }
			}
		}
	}

	tk::frame $w {*}$options
	tk::frame $w.sub -background $opts(-background) -borderwidth 0 
	set html $w.sub.html
	if {$opts(-useVertScroll)} {
		::scrolledframe::scrollbar $w.v -orient "vertical" -command [list $html yview]
		grid $w.v -row 0 -column 1 -sticky ns
	}
	if {$opts(-useHorzScroll)} {
		::scrolledframe::scrollbar $w.h -orient "horizontal" -command [list $html xview]
		grid $w.h -row 1 -column 0 -sticky ew
	}
	grid $w.sub -row 0 -column 0 -sticky nsew
	grid columnconfigure $w {0} -weight 1
	grid rowconfigure $w {0} -weight 1

	namespace eval [namespace current]::$w {}
	variable [namespace current]::${w}::Priv
	variable [namespace current]::${w}::HoverNodes
	variable [namespace current]::${w}::ActiveNodes1
	variable [namespace current]::${w}::ActiveNodes2
	variable [namespace current]::${w}::ActiveNodes3

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

	set Priv(delay)		$opts(-delay)
	set Priv(center)		$opts(-center)
	set Priv(fittowidth)	$opts(-fittowidth)
	set Priv(bw)    		$opts(-borderwidth)
	set Priv(css)   		$opts(-css)
	set Priv(minbbox)		{}
	set Priv(styleCount)	0

	if {[llength $Priv(bw)] == 0} { set Priv(bw) 0 }

	rename ::$w $w.__html__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	if {$Priv(center)} {
		$w.sub configure -width $opts(-width) -height $opts(-height)
	}

	if {$opts(-useVertScroll)} { set shrink no } else { set shrink yes }
	__html_widget $html {*}$htmlOptions -shrink $shrink
	$html handler script style [namespace code [list StyleHandler $html]]

	if {$opts(-useHorzScroll)} {
		if {$opts(-keepHorzScroll)} {
			set cmd [list $w.h set]
		} else {
			set cmd [namespace code [list SbSet $w.h]]
		}
		$html configure -xscrollcommand $cmd -xscrollincrement 10
	}
	if {$opts(-useVertScroll)} {
		if {$opts(-keepVertScroll)} {
			set cmd [list $w.v set]
		} else {
			set cmd [namespace code [list SbSet $w.v]]
		}
		$html configure -yscrollcommand $cmd -yscrollincrement 10
	}

	if {$Priv(center)} {
		place $html -x 0 -y 0
		bind $w.sub <Configure> [namespace code { Place %W }]
	} else {
		pack $html -fill both -expand yes
		if {$opts(-useVertScroll)} {
			bind $w <Configure> [namespace code { Configure %W %w %# }]
		}
	}

	SelectionClear $html
	selection handle $html [namespace code [list SelectionHandler $html]]

	return $w
}


proc StyleHandler {w node contents} {
	variable [winfo parent [winfo parent $w]]::Priv

	incr Priv(styleCount)
	set id "author.[format %.4d $Priv(styleCount)]"
	$w style -id $id.9999 -importcmd [namespace code [list ImportHandler $w]] $contents
}


proc ImportHandler {w parentid uri} {
	puts stderr "html.tcl: ImportHandler not yet implemented"
}


proc WidgetProc {w command args} {
	variable ${w}::Priv

	switch -glob -- $command {
		parse {
			variable Margin
			variable MaxWidth

			array unset [namespace current]::HoverNodes
			array unset [namespace current]::ActiveNodes1
			array unset [namespace current]::ActiveNodes2
			array unset [namespace current]::ActiveNodes3
			set Priv(nodeList) {}
			$w.sub.html reset
			$w.sub.html xview moveto 0
			$w.sub.html yview moveto 0
			if {!$Priv(fittowidth)} {
				$w.sub.html configure -fixedwidth $MaxWidth
			}
			$w.sub.html parse -final [lindex $args 0]
			if {[string length $Priv(css)]} { $w.sub.html style -id user $Priv(css) }
			set Priv(minbbox) {}
			if {$Priv(center) || !$Priv(fittowidth)} {
				set bbox [$w minbbox]
				if {[llength $bbox] == 0} { set bbox [$w bbox] }
				set width [expr {min([lindex $bbox 2], 4000) + $Margin}]
				$w.sub.html configure -fixedwidth $width
			}
			if {$Priv(center)} {
				update idletasks
				after idle [namespace code [list Place $w.sub]]
			}
			return
		}

		minbbox {
			if {[llength $Priv(minbbox)] == 0} {
				if {$Priv(fittowidth)} {
					set maxWidth [$w.sub cget -width]
				} else {
					set maxWidth [set [namespace current]::MaxWidth]
				}
				set Priv(minbbox) [ComputeBoundingBox $w.sub.html [$w.sub.html node] $maxWidth]
			}
			return $Priv(minbbox)
		}

		handler - search - style {
			return [$w.sub.html $command {*}$args]
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
			set x [expr {[winfo pointerx .] - [winfo rootx $w.sub.html]}]
			set y [expr {[winfo pointery .] - [winfo rooty $w.sub.html]}]
			event generate $w.sub.html <Motion> -x $x -y $y
			return
		}

		drawable	{ return $w.sub.html }
		pointer	{ return $Priv(pointer) }
		font		{ return HtmlFont }

		bbox {
			if {[llength $args] == 0} {
				return [$w.sub.html bbox]
			}
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command ?<node>?\""
			}
			return [$w.sub.html bbox [lindex $args 0]]
		}

		viewbox {
			return [$w.sub viewbox]
		}

		size {
			lassign [$w.sub.html bbox] x y w h
			set w [expr {$w + 2*$x}]
			set h [expr {$h + 2*$y}]
			return [list $w $h]
		}

		xview - yview {
			return [$w.sub.html $command {*}$args]
		}

		scrollto {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <px>\""
			}
			variable Margin
			set height [lindex [$w.sub.html bbox [$w.sub.html node]] 3]
			set y [expr {max(0, [lindex $args 0] - $Margin)}]
			set fraction [expr {double($y)/double($height)}]
			return [$w.sub.html yview moveto $fraction]
		}

		root {
			return [$w.sub.html node]
		}

		focusin {
			if {!$Priv(focus)} {
				set Priv(focus) 1
				if {[$w.sub.html cget -exportselection]} {
					$w.sub.html tag configure selection \
						-foreground [$w.sub.html cget -selectforeground] \
						-background [$w.sub.html cget -selectbackground] \
						;
				}
			}
			return
		}

		focusout {
			if {$Priv(focus)} {
				set Priv(focus) 0
				if {[$w.sub.html cget -exportselection]} {
					$w.sub.html tag configure selection \
						-foreground [$w.sub.html cget -inactiveselectforeground] \
						-background [$w.sub.html cget -inactiveselectbackground] \
						;
				}
			}
			return
		}
	}

	return [$w.__html__ $command {*}$args]
}


proc Place {w} {
	variable [winfo parent $w]::Priv
	variable MaxWidth

	set width [winfo width $w]
	set height [winfo height $w]
	if {$width == 1} { return }
	lassign [$w.html visbbox] _ _ htmlWidth htmlHeight
	set xdelta [expr {max(0, ($width - $htmlWidth)/2)}]
	set ydelta [expr {max(0, ($height - $htmlHeight)/2)}]
	if {$ydelta > 0} { set height $htmlHeight }
	if {$xdelta > 0} { set width $htmlWidth }
	$w.html configure -width $width -height $height
	place $w.html -x $xdelta -y $ydelta
	$w.html xview scroll 0 units
	$w.html yview scroll 0 units
}


proc Configure {parent width req} {
	variable ${parent}::Priv

	if {[winfo width $parent.sub.html] == $width} { return }

	# This (using the serial field from the event) is working under x11
	# to prevent endless loops. But does this work with windows and mac?
	if {$req == $Priv(request)} { return }
	set Priv(request) $req

	$parent.sub.html configure -width [expr {max(1, $width - 2*$Priv(bw) - [VsbWidth $parent])}]
}


proc ConfigureFrame {parent sb visible} {
	variable ${parent}::Priv

	if {!$Priv(center) && [$sb cget -orient] eq "vertical"} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
		set width [$parent.sub.html cget -width]
		incr width [VsbWidth $parent.sub]
		Configure $parent $width 0
	}
}


proc VsbWidth {parent} {
	if {"$parent.v" ni [grid slaves $parent]} { return 0 }
	return [winfo width $parent.v]
}


proc ComputeBoundingBox {w node maxWidth} {
	variable MaxWidth
	variable Margin

	set tag [$node tag]
	set result {}

	if {[string length $tag] > 0} {
		switch -- $tag {
			html {}
			head { return $result }
			default {
				if {$tag ne "body"} {
					set bbox [$w bbox $node]
					if {[llength $bbox]} {
						if {[lindex $bbox 2] == $maxWidth - $Margin} { lset bbox 2 0 }
						set result $bbox
					}
				}
			}
		}
	}

	if {[llength $result] == 0 || [lindex $result 2] == 0} {
		foreach n [$node children] {
			set bbox [ComputeBoundingBox $w $n $maxWidth]
			if {[llength $bbox] > 0} {
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


proc SbSet {sb first last} {
	set parent [winfo parent $sb]
	set slaves [grid slaves $parent]
	::scrolledframe::sbset $sb $first $last
	if {$slaves ne [grid slaves $parent]} {
		ConfigureFrame $parent $sb [expr {$sb in [grid slaves $parent]}]
	}
}


proc Motion {w x y state} {
	variable [winfo parent [winfo parent $w]]::Priv

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
	variable [winfo parent [winfo parent $w]]::HoverNodes
	variable [winfo parent [winfo parent $w]]::Priv

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
	variable [winfo parent [winfo parent $w]]::HoverNodes
	variable [winfo parent [winfo parent $w]]::Priv

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
	variable [winfo parent [winfo parent $w]]::Priv

	foreach {event node} $eventlist {
		if {[llength $node] == 0 || [llength [info commands $node]] > 0} {
			foreach script $Priv($event) {
				{*}$script $node
			}
		}
	}
}


proc ButtonPress {w x y k {state 0}} {
	variable [winfo parent [winfo parent $w]]::ActiveNodes$k
	variable [winfo parent [winfo parent $w]]::Priv

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
	variable [winfo parent [winfo parent $w]]::ActiveNodes$k
	variable [winfo parent [winfo parent $w]]::Priv

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
	variable [winfo parent [winfo parent $w]]::Priv

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
	variable [winfo parent [winfo parent $w]]::Priv
	set Priv(sel:state) false
}


proc SelectionExtend {w x y {node {}}} {
	variable [winfo parent [winfo parent $w]]::Priv

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

	lassign [$w viewbox] x0 y0 x1 y1
	lassign [$w visbbox] _ _ xmax ymax

	set motioncmd {}
	if {$y > $y1 - $y0} {
		if {$y1 < $ymax} {
			set motioncmd [list $w yview scroll 1 units]
		}
	} elseif {$y < 0} {
		if {$y0 > 0} {
			set motioncmd [list $w yview scroll -1 units]
		}
	}

	if {$motioncmd ne ""} {
		set Priv(sel:ignore) 1
		{*}$motioncmd
		update idletasks
		after cancel $Priv(sel:afterid)
		set Priv(sel:afterid) [after 200 [namespace code [list SelectionContinueMotion $w]]]
	}

	if {$x > $x1 - $x0} {
		if {$x1 < $xmax} {
			set motioncmd [list $w xview scroll 1 units]
		}
	} elseif {$x < 0} {
		if {$x0 > 0} {
			set motioncmd [list $w xview scroll -1 units]
		}
	}

	if {$motioncmd ne ""} {
		set Priv(sel:ignore) 1
		{*}$motioncmd
		update idletasks
		after cancel $Priv(sel:afterid)
		set Priv(sel:afterid) [after 100 [namespace code [list SelectionContinueMotion $w]]]
	}
}


proc SelectionContinueMotion {w} {
	variable [winfo parent [winfo parent $w]]::Priv

	set Priv(sel:ignore) 0
	set Priv(sel:afterid) {}
	set x [expr [winfo pointerx $w] - [winfo rootx $w]]
	set y [expr [winfo pointery $w] - [winfo rooty $w]]
	set node [lindex [$w node $x $y] 0]
	SelectionExtend $w $x $y $node
}


proc Select {w x y mode} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }

	SelectionClear $w
	set Priv(sel:mode) $mode
	set Priv(sel:state) true
	set Priv(sel:moved) 1
	SelectionExtend $w $x $y
}


proc ExtendSelection {w x y mode} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }

	if {!$Priv(sel:moved)} { SelectionClear $w }

	set Priv(sel:to:node) ""
	set Priv(sel:mode) $mode
	set Priv(sel:state) true
	set Priv(sel:moved) 1

	SelectionExtend $w $x $y
}


proc SelectionClear {w} {
	variable [winfo parent [winfo parent $w]]::Priv

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
	set cidx1 [WordStart $t $cidx]
	set cidx2 [WordEnd $t $cidx]
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
	variable [winfo parent [winfo parent $w]]::Priv

	set t  [$w text text]
	set n1 $Priv(sel:from:node)
	set i1 $Priv(sel:from:index)
	set n2 $Priv(sel:to:node)
	set i2 $Priv(sel:to:index)

	set stridxA [$w text offset $Priv(sel:from:node) $Priv(sel:from:index)]
	set stridxB [$w text offset $Priv(sel:to:node) $Priv(sel:to:index)]
	if {$stridxA > $stridxB} { lassign [list $stridxB $stridxA] stridxA stridxB }

	if {$Priv(sel:mode) eq "word"} {
		set stridxA [WordStart $t $stridxA]
		set stridxB [WordEnd $t $stridxB]
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
	variable [winfo parent [winfo parent $w]]::Priv

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


proc WordStart {str index} {
	set index [string wordstart $str $index]

	# this is [string wordstart] but including zero with joiners
	while {	$index > 1
			&& (	[string index $str [expr {$index - 1}]] eq "\u200c"
				|| [string index $str [expr {$index - 1}]] eq "\u200d")} {
		set index [string wordstart $str [expr {$index - 2}]]
	}

	return $index
}


proc WordEnd {str index} {
	set index [string wordend $str $index]

	# this is [string wordend] but including zero with joiners
	while {	$index < [string length $str]
			&& (	[string index $str $index] eq "\u200c"
				|| [string index $str $index] eq "\u200d")} {
		set index [string wordend $str [expr {$index + 1}]]
	}

	return $index
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
bind Html <Shift-Double-ButtonPress-1>	[namespace code { ExtendSelection %W %x %y word }]
bind Html <Shift-Triple-ButtonPress-1>	[namespace code { ExtendSelection %W %x %y block }]

switch [tk windowingsystem] {
	win32 {
		bind Html <MouseWheel> { %W yview scroll [expr %D/-60] units; break }
	}
	aqua {
		bind Html <MouseWheel> { %W yview scroll [expr %D*-2] units; break }
	}
	x11 {
		bind Html <ButtonPress-4> { %W yview scroll -2 units; break }
		bind Html <ButtonPress-5> { %W yview scroll +2 units; break }
	}
}

} ;# namespace html

# vi:set ts=3 sw=3:
