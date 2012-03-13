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

package require Tk 8.5
package require tktwm 1.0
if {[catch { package require tkpng }]} { package require Img }

namespace eval twm {
namespace eval mc {

set Close	"Close"
set Undock	"Undock"

} ;# namespace mc

array set Defaults {
	header:background				#4f94cd
	header:foreground				white
	header:font						TkHeadingFont
	header:fontsize				8
	header:button:background	#d7d7d7
	highlight:color				#3778ed
	highlight:opacity				0.4
}
# highlight:color #6495ed

variable Counter 0


proc mc {tok} { return [::tk::msgcat::mc [set $tok]] }
proc tooltip {args} {}

if {![catch {package require tooltip}]} {
	proc tooltip {args} { ::tooltip::tooltip {*}$args }
}


proc twm {path args} {
	namespace eval [namespace current]::$path {}
	variable ${path}::Vars
	variable ${path}::Options

	array set opts { -makepane {} -getname {} }
	array set opts $args
	set Vars(makepane) $opts(-makepane)
	set Vars(getname) $opts(-getname)

	ttk::frame $path -class TwmToplevelFrame
	bind $path <Destroy> [namespace code { Destroy %W }]

	rename ::$path $path.__twm_frame__
	proc ::$path {command args} "[namespace current]::WidgetProc $path \$command {*}\$args"

	return $path
}


proc WidgetProc {twm command args} {
	variable ${twm}::Vars

	switch -- $command {
		add {
		}

		display {
		}

		init {
		}

		frame {
			return [MakeFrame $twm [lindex $args 0]]
		}

		pane {
			return [$Vars(makepane) [winfo parent $twm] [lindex $args 0]]
		}

		notebook {
			variable Counter
			set w [ttk::notebook $twm.__notebook__[incr Counter] {*}$args]
			lappend Vars(container) $w
			return $w
		}

		panedwindow {
			variable Counter
			set w [tk::panedwindow $twm.__panedwindow__[incr Counter] {*}$args]
			lappend Vars(container) $w
			return $w
		}

		update {
#			return [Update [lindex $args 0]]
		}
	}

	return $twm
}


proc MakeFrame {twm id} {
	variable Defaults
	variable Counter
	variable ${twm}::Vars

	set parent [winfo parent $twm]
	incr Counter
	set top [tk::frame $parent.__frame__$Counter -borderwidth 0 -background black]
	set hdr [tk::frame $top.__header__ \
					-background $Defaults(header:background) \
					-borderwidth 1 \
					-relief raised \
				]
	set child [$Vars(makepane) $top $id]
	set name [$Vars(getname) $id]

	pack $hdr -side top -fill x -expand no
	pack $child -side top -fill both -expand yes

	tk::button $hdr.close  -image $icon::12x12::close  -background $Defaults(header:button:background)
	tk::button $hdr.undock \
		-image $icon::12x12::undock \
		-background $Defaults(header:button:background) \
		-command [namespace code [list Undock $twm $top]] \
		;

	tooltip $hdr.close  [namespace current]::mc::Close
	tooltip $hdr.undock [namespace current]::mc::Undock

	set opts {}
	if {[info exists $name]} {
		lappend opts -textvar $name
		set text [set $name]
	} else {
		lappend opts -text $name
		set text $name
	}

	set headerFont [list [font configure $Defaults(header:font) -family] $Defaults(header:fontsize) bold]
	tk::label $hdr.label \
		-background $Defaults(header:background) \
		-foreground $Defaults(header:foreground) \
		-font $headerFont \
		-text $text \
		;

	grid $hdr.close	-column 4 -row 0
	grid $hdr.undock	-column 2 -row 0
	grid $hdr.label	-column 0 -row 0 -padx 2

	grid columnconfigure $hdr 1 -weight 1
	grid columnconfigure $hdr {3 5} -minsize 3

	foreach w [list $hdr $hdr.label] {
		bind $w <ButtonPress-1>		[namespace code [list HeaderPress $twm $top %X %Y]]
		bind $w <Button1-Motion>	[namespace code [list HeaderMotion $twm $top %X %Y]]
		bind $w <ButtonRelease-1>	[namespace code [list HeaderRelease $twm $top %X %Y]]
	}

	return $top
}


proc HeaderPress {twm top x y} {
	variable ${twm}::Vars

	SaveUndockPosition $twm $top
	set Vars(init:x) $x
	set Vars(init:y) $y
	set Vars(delta:x) [expr {$x - [winfo rootx $top]}]
	set Vars(delta:y) [expr {$y - [winfo rooty $top]}]
	set Vars(docking:markers) {}
	set Vars(docking:marker) {}
	set Vars(afterid) {}
	ttk::globalGrab $top
}


proc HeaderMotion {twm top x y} {
	variable ${twm}::Vars

	if {[winfo toplevel $top] eq $top} {
		foreach entry $Vars(docking:markers) {
			lassign $entry canv w x0 y0 x1 y1
			if {$x0 <= $x && $x < $x1 && $y0 <= $y && $y < $y1} {
				if {[llength $Vars(docking:marker)] > 0} {
					if {$Vars(docking:marker) eq $canv} { return }
					DockingMotion $twm $top $w $Vars(docking:marker) leave $x $y
					set Vars(docking:marker) {}
				}
				DockingMotion $twm $top $w $canv enter $x $y
				set Vars(docking:marker) $canv
				return
			} elseif {$Vars(docking:marker) eq $canv} {
				DockingMotion $twm $top $w $canv leave $x $y
				set Vars(docking:marker) {}
			}
		}
		if {[winfo toplevel $top] eq $top} {
			wm geometry $top +[expr {$x - $Vars(delta:x)}]+[expr {$y - $Vars(delta:y)}]
		}
	} elseif {abs($x - $Vars(init:x)) >= 3 || abs($y - $Vars(init:y)) >= 3} {
		bind $top <Button1-Motion> {#}
		bind $top <ButtonRelease-1> {#}
		set wd [expr {[winfo width $top] + 2}]
		set ht [expr {[winfo height $top] + 2}]
		set x [expr {$x - $Vars(delta:x)}]
		$top configure -width $wd -height $ht
		ttk::releaseGrab $top
		::scidb::tk::twm release $top
		$top configure -borderwidth 1
		wm geometry $top ${wd}x${ht}+${x}+${y}
		::scidb::tk::wm noDecor $top
		wm state $top normal
		ttk::globalGrab $top
		bind $top <Button1-Motion> [namespace code [list HeaderMotion $twm $top %X %Y]]
		bind $top <ButtonRelease-1> [namespace code [list HeaderRelease $twm $top %X %Y]]
		ComputeDockingPoints $twm $top
	}

	if {[winfo toplevel $top] eq $top} {
		after idle [namespace code [list ShowDockingPoints $twm $top $x $y]]
	}
}


proc HeaderRelease {twm top x y} {
	variable ${twm}::Vars

	ttk::releaseGrab $top
	after cancel $Vars(afterid)
	HideDockingPoints $twm $top

	foreach entry $Vars(docking:markers) {
		set w [lindex $entry 0]
		if {[winfo exists $w]} {
			destroy [winfo parent $w]
		}
		set w $twm.__highlight__
		if {[winfo exists $w]} {
			wm withdraw $w
			catch { image delete [$w.c itemcget image -image] }
		}
	}

	if {[winfo toplevel $top] eq $top} {
		wm geometry $top +[expr {$x - $Vars(delta:x)}]+[expr {$y - $Vars(delta:y)}]
		$top configure -borderwidth 0
		Dock $twm $top
	}
}


proc ShowDockingPoints {twm top x y} {
	variable ${twm}::Vars

	foreach entry $Vars(docking:panes) {
		lassign $entry w x0 y0 x1 y1

		if {$x0 <= $x && $x < $x1 && $y0 <= $y && $y < $y1} {
			ShowDockingPoint $twm $top $w $x $y
		} else {
			HideDockingPoint $twm $top $w
		}
	}
}


proc ShowDockingPoint {twm top w x y} {
	variable ${twm}::Vars

	set iw 32
	set ih 32

	if {[info exists Vars(docking:hover:$w)]} {
		if {![winfo exists $w.__m__]} {
			foreach point $Vars(docking:hover:$w) {
				lassign $point pos x0 y0

				switch $pos {
					m {
						set wd [expr {$iw + 4}]
						set ht [expr {$ih + 4}]
						set ix 2
						set iy 2
						set lines [list \
							0 0 1 0 \
							0 [expr {$ht - 1}] 1 [expr {$ht - 1}] \
							[expr {$wd - 1}] 0 $wd 0 \
							[expr {$ht - 1}] [expr {$wd - 1}] [expr {$ht - 1}] $wd \
						]
					}

					l {
						set wd [expr {$iw + 2}]
						set ht [expr {$ih + 4}]
						set ix 2
						set iy 2
						set lines [list \
							0 0 $wd 0 \
							0 [expr {$ht - 1}] $wd [expr {$ht - 1}] \
							0 0 0 $ht \
						]
					}

					r {
						set wd [expr {$iw + 2}]
						set ht [expr {$ih + 4}]
						set ix 0
						set iy 2
						set lines [list \
							0 0 $wd 0 \
							0 [expr {$ht - 1}] $wd [expr {$ht - 1}] \
							[expr {$wd - 1}] 0 [expr {$wd - 1}] $ht \
						]
					}

					t {
						set wd [expr {$iw + 4}]
						set ht [expr {$ih + 2}]
						set ix 2
						set iy 2
						set lines [list \
							0 0 $wd 0 \
							0 0 0 $ht \
							[expr {$wd - 1}] 0 [expr {$wd - 1}] $ht \
						]
					}

					b {
						set wd [expr {$iw + 4}]
						set ht [expr {$ih + 2}]
						set ix 2
						set iy 0
						set lines [list \
							0 [expr {$ht - 1}] $wd [expr {$ht - 1}] \
							0 0 0 $ht \
							[expr {$wd - 1}] 0 [expr {$wd - 1}] $ht \
						]
					}
				}

				set tl [tk::toplevel $w.__${pos}__ -width $wd -height $ht -borderwidth 0]
				wm withdraw $tl
				set c [tk::canvas $tl.__docking__ -borderwidth 0 -width $wd -height $ht]
				pack $c
				$c create rectangle 0 0 $wd $ht -width 0 -fill black -tag background
				foreach {lx0 ly0 lx1 ly1} $lines {
					$c create line $lx0 $ly0 $lx1 $ly1 -fill white -tag border
				}
				$c create image $ix $iy -anchor nw -image $icon::32x32::shape($pos)
				wm transient $tl $twm
				wm overrideredirect $tl true
				wm attributes $tl -topmost true
				wm geometry $tl ${wd}x${ht}+${x0}+${y0}
				wm state $tl normal

				if {$tl ni $Vars(docking:markers)} {
					lappend Vars(docking:markers) [list $c $w $x0 $y0 [expr {$x0 + $wd}] [expr {$y0 + $ht}]]
				}
			}
		}
	}
}


proc DockingMotion {twm top w canv mode x y} {
	variable ${twm}::Vars

	after cancel $Vars(afterid)

	switch $mode {
		enter {
			$canv itemconfigure background -fill yellow
			$canv itemconfigure border -fill black
			set Vars(afterid) [after 50 [namespace code [list ShowHighlightRegion $twm $top $w $canv]]]
		}

		leave {
			$canv itemconfigure background -fill black
			$canv itemconfigure border -fill white
			wm geometry $top +[expr {$x - $Vars(delta:x)}]+[expr {$y - $Vars(delta:y)}]
			set h $twm.__highlight__
			if {[winfo exists $h]} {
				wm withdraw $h
				catch { image delete [$h.c itemcget image -image] }
			}
		}
	}
}


proc ShowHighlightRegion {twm top w canv} {
	variable ${twm}::Vars
	variable Defaults

	update idletasks

	set x  [winfo rootx $w]
	set y  [winfo rooty $w]
	set wd [winfo width $w]
	set ht [winfo height $w]

	set tl $twm.__highlight__
	if {[winfo exists $tl]} {
		wm withdraw $tl
		catch { image delete [$tl.c itemcget image -image] }
		update idletasks
	} else {
		set tl [tk::toplevel $tl -borderwidth 0]
		pack [tk::canvas $tl.c -borderwidth 0]
		$tl.c create image 0 0 -anchor nw -tag image
	}

	switch -glob -- $canv {
		*.__t__.__docking__ {
			set ht [expr {$ht/2}]
		}
		*.__b__.__docking__ {
			set y  [expr {$y + $ht/2}]
			set ht [expr {$ht - $ht/2}]
		}
		*.__r__.__docking__ {
			set x  [expr {$x + $wd/2}]
			set wd [expr {$wd - $wd/2}]
		}
		*.__l__.__docking__ {
			set wd [expr {$wd/2}]
		}
	}

	$tl.c configure -width $wd -height $ht
	set img [image create photo -width $wd -height $ht]
	::scidb::tk::x11 region $x $y $img
	::scidb::tk::image paintover $Defaults(highlight:color) $Defaults(highlight:opacity) $img
	$tl.c itemconfigure image -image $img
	wm geometry $tl ${wd}x${ht}+${x}+${y}
	wm overrideredirect $tl true
	foreach pos {m l r b t} {
		set v $w.__${pos}__
		if {[winfo exists $v]} { raise $v $tl }
	}
	wm transient $tl $w
	update idletasks
	::scidb::tk::wm noDecor $tl
	wm state $tl normal

	after idle [namespace code [list HeaderMotion $twm $top {*}[winfo pointerxy $twm]]]
}


proc HideDockingPoints {twm top} {
	variable ${twm}::Vars

	foreach name [array names Vars docking:hover:*] {
		set w [lindex [split $name :] 2]
		HideDockingPoint $twm $top $w
	}
}


proc HideDockingPoint {twm top w} {
	foreach dir {l r t b m} {
		set v $w.__${dir}__
		if {[winfo exists $v]} {
			destroy $v
		}
	}
}


proc ComputeDockingPoints {twm top} {
	variable ${twm}::Vars

	update idletasks
	array unset Vars docking:hover:*
	array unset Vars docking:sub:*
	set Vars(docking:panes) {}
	set panes {}
	set iw 32
	set ih 32

	foreach w $Vars(container) {
		switch -glob -- $w {
			*__panedwindow__* {
				# lrtbm if pointer hovers pane
				foreach v [$w panes] {
if {$v ne ".application.twm.__panedwindow__5"} {
					set x  [winfo rootx $v]
					set y  [winfo rooty $v]
					set wd [winfo width $v]
					set ht [winfo height $v]
					set mx [expr {$x + $wd/2 - ($iw + 4)/2}]
					set my [expr {$y + $ht/2 - ($ih + 4)/2}]
					set tx $mx
					set ty [expr {$my - ($ih + 2)}]
					set bx $mx
					set by [expr {$my + ($ih + 4)}]
					set lx [expr {$mx - ($iw + 2)}]
					set ly $my
					set rx [expr {$mx + ($iw + 4)}]
					set ry $my
					set Vars(docking:hover:$v) \
						[list \
							[list m $mx $my] \
							[list l $lx $ly] \
							[list r $rx $ry] \
							[list t $tx $ty] \
							[list b $bx $by] \
						]
					lappend Vars(docking:panes) [list $v $x $y [expr {$x + $wd}] [expr {$y + $ht}]]
					lappend panes $v
}
				}
			}
		}
	}

	foreach w $Vars(container) {
		if {$w ni $panes} {
			switch -glob -- $w {
				*__notebook__* {
					# lrtbm if pointer hovers notebook
					set x  [winfo rootx $w]
					set y  [winfo rooty $w]
					set wd [winfo width $w]
					set ht [winfo height $w]
					set mx [expr {$x + ($wd/2) - ($iw + 4)/2}]
					set my [expr {$y + ($ht/2) - ($ih + 4)/2}]
					set tx $mx
					set ty [expr {$my - ($ih + 2)}]
					set bx $mx
					set by [expr {$my + ($ih + 4)}]
					set lx [expr {$mx - ($iw + 2)}]
					set ly $my
					set rx [expr {$mx + ($iw + 4)}]
					set ry $my
					set Vars(docking:hover:$w) \
						[list \
							[list m $mx $my] \
							[list l $lx $ly] \
							[list r $rx $ry] \
							[list t $tx $ty] \
							[list b $bx $by] \
						]
					lappend Vars(docking:panes) [list $w $x $y [expr {$x + $wd}] [expr {$y + $ht}]]
				}
				*__panedwindow__* {
if {$w ne ".application.twm.__panedwindow__5"} {
					# tb if horizontal and pane is subwindow
					# lr if vertical and pane is subwindow
					set x  [winfo rootx $w]
					set y  [winfo rootx $w]
					set wd [winfo width $w]
					set ht [winfo height $w]
					if {[$w cget -orient] eq "horizontal"} {
						set tx [expr {$x + $wd/2 - ($iw + 4)/2}]
						set ty $y
						set bx $tx
						set by [expr {$y + $ht - ($ih + 4)}]
						set Vars(docking:sub:$w) [list $w [list t $tx $ty] [list b $bx $by]]
					} else {
						set lx $x
						set ly [expr {$y - $ht/2 - ($ih + 4)}]
						set rx [expr {$x + $wd - ($iw + 4)}]
						set ry $ly
						set Vars(docking:sub:$w) [list [list l $lx $ly] [list r $rx $ry]]
					}
					lappend Vars(docking:panes) [list $w $x $y [expr {$x + $wd}] [expr {$y + $ht}]]
}
				}
			}
		}
	}
}


proc SaveUndockPosition {twm top} {
	variable ${twm}::Vars

	set container {}
	set options {}
	set pos end

	foreach w [winfo children $twm] {
		switch -glob -- $w {
			*__panedwindow__* {
				set panes [$w panes]
				if {$top in $panes} {
					set container $w
					foreach entry [$w paneconfigure $top] {
						if {[llength [lindex $entry 4]]} {
							lappend options [lindex $entry 0] [lindex $entry 4]
						}
					}
					set pos [lsearch $panes $top]
					if {$pos + 1 < [llength $panes]} {
						lappend options -before [lindex $panes [expr {$pos + 1}]]
					}
				}
			}
			*__notebook__* {
				set tabs [$w tabs]
				if {$top in $tabs} {
					set container $w
					set options [$w tab $top]
					set pos [lsearch $tabs $top]
					if {$pos + 1 == [llength $tabs]} { set pos end }
				}
			}
		}
	}

	set Vars(dock:container:$top) $container
	set Vars(dock:options:$top) $options
	set Vars(dock:position:$top) $pos
}


proc Undock {twm top} {
	SaveUndockPosition $twm $top
	pack forget $top.__header__
	set wd [winfo width $top]
	set ht [winfo height $top]
	set x [winfo rootx $top]
	set y [winfo rooty $top]
	::scidb::tk::twm release $top
	::update idle ;# is reducing flickering
	wm geometry $top ${wd}x${ht}+${x}+${y}
#	wm transient $top $twm
	wm title $top [$top.__header__.label cget -text]
	wm state $top normal
	wm protocol $top WM_DELETE_WINDOW [namespace code [list Dock $twm $top]]
}


proc Dock {twm top} {
	variable ${twm}::Vars

	::scidb::tk::twm capture $top
	switch -glob -- $Vars(dock:container:$top) {
		*__panedwindow__*	{
			$Vars(dock:container:$top) add $top {*}$Vars(dock:options:$top) -height [winfo height $top]
		}
		*__notebook__* {
			$Vars(dock:container:$top) insert $Vars(dock:position:$top) $top {*}$Vars(dock:options:$top)
		}
	}
	pack $top.__header__ -side top -fill x -expand no -before [lindex [pack slaves $top] 0]
}


proc Update {data} {
	switch {[lindex $data 0]} {
		makeWindow {
			set name [lindex $data 1]
			set w [tk::toplevel .__window__$name]
			pack .$name
			return $w
		}

		makePane {
			switch [lindex $data 1] {
				board			{ return [MakePane board blue] }
				editor		{ return [MakePane editor white] }
				analysis		{ return [MakePane analysis yellow] }
				tree			{ return [MakePane tree red] }
				tree-games	{ return [MakePane tree-games green] }
			}
		}

		makePanedWindow {
			lassign $data cmd orient pane1 pane2
		}

		makeNotebook {
			lassign $data cmd pane1 pane2
		}

		makeFrame {
			return [MakeFrame [lindex $data 1]]
		}

		destroyPane - destroyPanedWindow - destroyNotebook - destroyWindow {
			destroy [lindex $data 1]
		}

		destroyWindow {
			set name [lindex $data 1]
			pack forget [winfo children $name]
			destroy $name
		}

		addTab			{}
		removeTab		{}

		addPane			{}
		removePane		{}
	}
}


if {0} {
proc Add {twm w args} {
	variable ${twm}::Vars
	variable ${twm}::Options

	array set opts {
		-expand		none
		-height		100
		-width		100
		-minwidth	50
		-minheight	50
		-side			right
		-text			""
		-textVar		{}
	}

	array set opts $args

	foreach {key val} [array get Options *:$w] {
		set opts($key) $val
	}

	set textVar $opts(-textVar)
	if {[llength $textVar] == 0} {
		set Vars(textVar:$w) $opts(-text)
		set textVar [namespace current]::${twm}::Vars(textVar:$w)
	}
	
	lappend Vars(childs:$opts(-side)) $w
	set Vars(childs:$opts(-side)) \
		[lsort -command [namespace code [list Compare $twm]] $Vars(childs:$opts(-side))]
	set Vars(arranged:$w) 0

	switch $opts(-side) {
		left - right {
			set Vars(orientation:$w) vert
			set Vars(resizable:$w) [expr {$expand eq "y" || $expand eq "both"}]
		}

		top - bottom {
			set Vars(orientation:$w) horz
			set Vars(resizable:$w) [expr {$expand eq "x" || $expand eq "both"}]
		}
	}

	foreach {key val} [array get opts] {
		set Options($key) $val
	}
}


proc Display {twm} {
	variable ${twm}::Vars
	variable ${twm}::Options

	foreach w $Vars(childs) {
		if {!$Vars(arranged:$w)} {
			set root $Vars(graph:$Options(-side:$w))
			InsertLeaf $twm $w $root [GetChild $root 0]
		}
	}
}


proc GetChild {node index} {
	return [lindex $index [lindex 3 $node]]
}


proc InsertLeaf {twm w pred curr} {
	variable ${twm}::Vars
	variable ${twm}::Options

	# graph:
	#	type in {leaf, frame, panedWindow, notebook}
	#	min position number
	#	max position number
	#	ordered list of childs

	set position $Options(-position:$w)
	lassign $curr type minPos maxPos childs

	if {$position < $minPos} {
		switch $type {
			leaf {
			}

			frame {
			}

			panedWindow {
			}

			notebook {
				set node [MakeFrame $curr $pred]
			}
		}
	} elseif {$position > $maxPos} {
	} else {
	}
}


proc Compare {twm lhs rhs} {
	variable ${twm}::Options
	return [expr {$Options(-position:$lhs) - $Options(-position:$rhs)}]
}


proc MakeFrame {path text args} {
	variable Defaults

	set top [ttk::frame $path {*}$args]
	set hdr [tk::frame $path.header \
					-background $Defaults(header:background) \
					-borderwidth 1 \
					-relief raised \
				]

	pack $top -fill both -expand yes
	pack $hdr -side top -fill x -expand yes

	tk::button $hdr.close  -image $icon::12x12::close  -background $Defaults(header:button:background)
	tk::button $hdr.undock -image $icon::12x12::undock -background $Defaults(header:button:background)

	tooltip $hdr.close  Close
	tooltip $hdr.undock Undock

	set opts {}
	if {[info exists $text]} {
		lappend opts -textvar $text
	} else {
		lappend opts -text $text
	}

	set headerFont [list [font configure $Defaults(header:font) -family] $Defaults(header:fontsize) bold]
	tk::label $hdr.label \
		-background $Defaults(header:background) \
		-foreground $Defaults(header:foreground) \
		-font $headerFont \
		{*}$opts \
		;

	grid $hdr.close	-column 4 -row 0
	grid $hdr.undock	-column 2 -row 0
	grid $hdr.label	-column 0 -row 0 -padx 2

	grid columnconfigure $hdr 1 -weight 1
	grid columnconfigure $hdr {3 5} -minsize 3

	return $path
}
}


proc Destroy {twm} {
	if {[namespace exists $twm]} {
		namespace delete $twm
	}
}


namespace eval callback {

proc Create {twm name parent type opts} {
	switch $type {
		frame {
			return $twm
		}

		pane {
			array set args $opts
			return [MakeFrame $parent $name
				-width $args(-width) \
				-height $args(-height) \
			]
		}

		notebook {
			array set args $opts
			return [ttk::notebook $parent.$name \
				-width $args(-width) \
				-height $args(-height) \
			]
		}

		panedwindow {
			array set args $opts
			return [tk::panedwindow $parent.$name \
				-orient $args(-orient) \
				-width $args(-width) \
				-height $args(-height) \
			]
		}
	}
}


proc Configure {twm parent path opts} {
	if {[string match *PanedWindow [winfo class $parent]} {
		$parent paneconfigure $path {*}$opts
	}
}


proc Pack {twm parent path opts} {
	switch -glob -- [winfo class $parent] {
		*PanedWindow {
			$parent add $path
			set options {}

			if {[info exists args(-after)]} {
				lappend options -after $args(-after)
			} elseif {[info exists args(-before)]} {
				lappend options -before $args(-before)
			}
			if {[info exists args(-minsize)]} {
				lappend options -minsize $args(-minsize)
			}
			if {[info exists args(-sticky)]} {
				lappend options -minsize $args(-sticky)
			}
			if {[info exists args(-expand)]} {
				switch -- $args(-expand) {
					none	{ lappend options -stretch never }
					both	{ lappend options -stretch always }
					x		{ if {$args(-orient) eq "horz"} { lappend options -stretch always } }
					y		{ if {$args(-orient) eq "vert"} { lappend options -stretch always } }
				}
			}

			$parent paneconfigure $path {*}$options
		}

		*Notebook {
			array set args $opts
			set options {}

			if {[info exists args(-after)]} {
				set pos [$parent index $args(-after)]
				if {$pos == [$parent index end]} { set pos end }
			} elseif {[info exists args(-before)]} {
				set pos [$parent index $args(-before)]
			} else {
				set pos end
			}
			if {[info exists args(-sticky)]} {
				lappend options -sticky $args(-sticky)
			}

			$parent insert $pos $path -text [lindex [split $path .] end] {*}$options
		}

		*Frame {
			set options {}

			if {[info exists args(-sticky)]} {
				lappend options -sticky $args(-sticky)
			}

			grid $path -column 1 -row 1 {*}$options

			if {[info exists args(-expand)} {
				switch -- $args(-expand) {
					both {
						grid rowconfigure $parent 1 -weight 1
						grid columnconfigure $parent 1 -weight 1
					}

					x { grid columnconfigure $parent 1 -weight 1 }
					y { grid rowconfigure $parent 1 -weight 1 }
				}
			}
		}
	}
}


proc Unpack {twm parent path} {
	$parent forget $path
}

} ;# namespace callback


proc MakePane {name color} {
	return [tk::frame .$name -background $color]
}

namespace eval icon {
namespace eval 12x12 {

set close [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAZlBMVEUA5uYA6fQMJIsNLXkQ
	MIwbRpYcMp0ePqUgOYghR6ohTqEnU6YpRJUrV7UvTr40RqA1W7U5Yco5ZLJAUaBAYKpEb8Zy
	iLyLkL6Ml+mPr9CQp9ujt9S7zOPI1/Po/f7u/+b1/v76/9+Gv0fRAAAAAnRSTlMKFw+voHUA
	AAB3SURBVAgdBcFBCsMwDATAlVY2TiiBXgrt/x9X6D1xLFvqjODji5gw2FfevqwXTsAKa2BZ
	LiWGWsRe88Sm3Z1MTStm10iwpidNrrsndDCWptYVIqxzO8rtzU4EwcPGz2ttfcnjrHAibEJs
	n0MlQl3wBF6NNNLaC3/WxzmXRwQ+fwAAAABJRU5ErkJggg==
}]

set undock [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAA51BMVEUAAAASW3gccpL///8A
	AAAAAAAAAAAAAAABDhcAAAAAAxQ9PT0uLi53d3ZOTk5Tk6tFRUVCQkIQT2hVla08PDw6Ojo3
	Nzc2NjZAhJ5so7OHh4ZycnKJpqJambCLtrcYYn7FxMRHaXeBta99rbbLy8oeY32goJ9xmJSh
	oaC1tbXAwL8qc460tLS2tbS3t7ZzjZbIyMiTk5N+pLIAAAAAAAAAAAAAAAAAAACKucK/v77A
	wL/BwcDExMTKycnR0dHj4+Lp6Oft7ezt7e3u7u3u7u7v7+7w8O/w8PDx8fDy8vHz8/L09PT/
	//9MMki2AAAAN3RSTlMAAAAAAQIDBAUGChUaGygqLzAyMzY3Ojs/QkNIS0xQUVdZWVtjZnF6
	enuEiIiIiImZo9bq7PT8eQkIuQAAAAFiS0dETPdvEPMAAABySURBVAgdBcHLCsJAEEXBc3s6
	QxIJqKts/P9fEwVBokQyj7ZKoEvefa5zmRy0rB0Dnj5aGAmgHH67UgBA7hnlWGoye53dAZRN
	0sc7YzveAGQPQkN07Y/Y3BiCru/v3vBj2gBorqpTSm7Ra22lClwiogJ/VrotRDILsaYAAAAA
	SUVORK5CYII=
}]

} ;# namespace 12x12

namespace eval 32x32 {

set shape(t) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAXVBMVEUAAAAceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkceDsceDskokkceDskokkceDsceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkoQLgrAAAAHXRSTlMAEBAgIDAwQEBQUGBgcICA
	j4+fr6+/v8/P39/v79eCthgAAAEVSURBVDjLfZLbloIwDEUjyk0qiFikQvL/n2mblumFMvsB
	1iKHJmwCEPFEfMI/PFDzOK9fV1QK18tpYEKsa8TprN7yAHqMNl+/rPr0ouBbNsCvjqM76Ag3
	r4gqHiUT0ONfYSFa+GOO9d4IGEgzGB19Wi8RJdw2E9huIBHLJMCPZmJmG08d9yDIIWzDxDEU
	2x7YCjty7Bje9McbYuOs5k4B98i4dfwNA9/IuHVMEaFxbtdQQuON84osaWAxnVXsOGY3bh1T
	BmdcX5wR4UUJ58+8HPy40X+C/8WAO9KrGsy5DiNhDzSZgFZRdr1GpgFlnnZlsFASqtkhdGA6
	bFy469pRf9zpT1s7uk9mr18Y8cqstfJl5Rv8AIgzNBnoDubuAAAAAElFTkSuQmCC
}]

set shape(b) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAXVBMVEUAAAAceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkceDsceDskokkceDskokkceDsceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkoQLgrAAAAHXRSTlMAEBAgIDAwQEBQUGBgcICA
	j4+fr6+/v8/P39/v79eCthgAAAEcSURBVDjLfZPbsoIwDEUDlesBRBEEIfz/Z9o0hDbFOevB
	GdpNkywqgNCteLJ0cOGJime8XyC+q+KgeiMWUaDDNfFPyYpxkQFHaKaDHMYgkLWdZbGB+35Q
	2sBIq38ZQC9tRYGDHvBHoPYBtIGz2kMCD986UtbwU7NJYGt4xdC5Gf3c9h/c6OXMHdP68p47
	tEf5hRzN8f5MthaxPEAZB0rrTnxbFZUfQQapSMJpfk3ST7j/Sd2ijOvCdRio+djgU9lyL7//
	4sY8hhpOvaiURjPh13YjNxJoWI7CSZt4f2K9GjbuimziOL5zYtw71ri2ZnJsxPHlXg+Q73se
	ONawceVYw8a1Yw2/qh3Hfw4sIscaaj92rGnporfwD/1lgi93uTQd6kQc3wAAAABJRU5ErkJg
	gg==
}]

set shape(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAXVBMVEUAAAAceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkceDsceDskokkceDskokkceDsceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkoQLgrAAAAHXRSTlMAEBAgIDAwQEBQUGBgcICA
	j4+fr6+/v8/P39/v79eCthgAAADUSURBVDjLnZPrDoMgDIXrFbyic2wybd//MQfDGDE1mJ1f
	hPMROLQF4FRoxAGu1aNTcWULY13LNLydDNbWGViG9asFcensggeyyR6fEsgvgM4drwAUsYDL
	hkMCcqYfYKZenLMZAelI5AGnxykbgPyQB7TVst/jsxWQPsmr9dtvNEG2dt18WkelVAsN4p4t
	g/xFoV4gHLBnW4kFBp+tnIl44JDtTyB6RfSR8ZgXH1VLWUK1AdGvPhSr5ot1o9xMw+g+bJh4
	y91o2njb3xic+OjdGN5w/L8QZDQZzKCcIgAAAABJRU5ErkJggg==
}]

set shape(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAYFBMVEUAAAAceDskokkceDsk
	okkceDskokkceDskokkceDskokkceDskokkceDskokkceDskokkceDskokkceDsceDskokkc
	eDskokkceDskokkceDskokkceDskokkceDskoklWkjs0AAAAHnRSTlMAEBAgIDAwQEBQUGBg
	cHCAgI+Pn6+vv7/Pz9/f7+8EUqY3AAAA2klEQVQ4y52T0XKCMBBFLyICKo1YGyuNZ///L/uQ
	jtNkCOl0Xzkz4ezeK0mSZvCdytMB4MrACRyw9CXAgVoPzE0ZkKYAYSwDezU34NaWALtI4wJh
	yr72zi8gmT0GNTO58TtABMyuO/VLauwgeO99BOzrKKXGgc+odrY4Hzt1v41h1GEYjtfnD2DP
	t8QYet0tnfte7ct4DbDnRRpDNF4FzB6HaDyXgJfxv4HKE7WfzDRP+aLOyaKqq86PNeTHqp5b
	6p3zW4FJIxdWIvfn0NZiv1mcqVa9ank36v8NrZY13DAzgmEAAAAASUVORK5CYII=
}]

set shape(m) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAABPlBMVEUAAAAceDsceDsceDsc
	eDsceDsceDsceDsceDsceDsceDsceDskokkceDsceDsceDsceDsceDsceDsceDsceDsceDsk
	okkceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDsc
	eDsceDsceDskokkceDsceDsceDsceDsceDsceDskokkceDsceDsceDsceDsceDsceDsceDsc
	eDsceDsceDsceDsceDsceDsceDsceDsceDsceDsceDskokkceDsceDsceDsceDsceDsceDsk
	okkceDsceDsceDsceDsceDsceDsceDsceDskokkceDsceDsceDsceDsceDsceDsceDsceDsc
	eDsceDsceDsceDsceDskokkkokkceDsceDsceDsceDskoknM1eVxAAAAaHRSTlMAAQMEBQYH
	CAkLDBAREhQaHyAhJCYnKCsuMzs8PkBBQkRFRklNU1hbYGNlbnBydnd/hIWHiYuMjY6QmZqb
	np+rrq+xsrOztrzBw8fIysvT1djZ2tvd4uPk5ebp6uvv8fL3+Pn5+vv8/SHi5lUAAAGFSURB
	VDjLfZNpWxMxFIXfCqgjdUU6WPcFBy2oFOsaUYG6NijoyBbA2gbO/P8/4Ic60GlnfL/lycnN
	Te45cEQQGeu8d9ZEAcOExksHa5++7UnyJhzcb0j7r64AcHlu6bfUyB63+vPi7PH69ONd2b4i
	VadfE9mKl1blqkfnnVbPAeVaM+5242atDJx5K5fWsPo8DtQ7yT86daD0Tjbt7+soVFpJH60K
	jKz3Og3VnoRKnGSIKzAthYDRc6CVDNCC0hcZCLzuQT0Zog535AMi6TzlzrCgU+bEjiKM1qCW
	5FCD9zJYPYNmnqAJT2VxugtxniCGB3J4XYdunqALt+T/L7gtj9NM8RX35bBaLG5yQRajjeJn
	fpAhki4WfVRpRxGB18Oir74hH4DRj7H8YbEsA4TSbP64r/XGTUPtm3mGGfueWtuqPTVsOV6m
	liN02rwwaFqeHJuWqtPPyaztTy712R5Cq4NHp/r2r25ngtOL3uGb6REAxmcWB6OXhtd/fD2/
	spUb3sL4/wXwM+cM3aIvkgAAAABJRU5ErkJggg==
}]

} ;# namespace 32x32
} ;# namespace icon
} ;# namespace twm

# vi:set ts=3 sw=3:
