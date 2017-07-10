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
# Copyright: (C) 2010-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source tiled-window-manager

package require Tk 8.5
package require tktwm 1.0
package require Ttk

namespace eval twm {
namespace eval mc {

set Close			"Close"
set Undock			"Undock"

set Timeout			"Timeout after eight seconds without mouse motions,\
						the frame has been re-docked to old place."
set TimeoutDetail	"This safety handling is required to avoid frozen screens, as long as the\
						tiling window management is in an experimental stage."

} ;# namespace mc

array set Defaults {
	header:fix:foreground		white
	header:flex:background		#4f94cd
	header:flex:foreground		white
	header:active:background	#fffdfc
	header:font						TkHeadingFont
	header:fontsize				9
	header:button:background	#d7d7d7
	header:tab:background		#4f94cd
	header:tab:foreground		#333333
	frame:borderwidth				1
	flathandle:size				7
	flathandle:color:dark		#0e62a8
	flathandle:color:lite		#a6ceef
	flathandle:color:gray		#74aedf
	sash:size						5
	cross:color:1					black
	cross:color:2					#24a249
	cross:active					yellow
	cross:size						24
	highlight:color				#3778ed
	highlight:opacity				0.3
	highlight:minsize				150
}
# flathandle:color:dark		#000000
# flathandle:color:lite		#ffffff
# flathandle:color:gray		#efefef
# highlight:opacity 0.4

array set Options [array get Defaults]


array set DirMap {
	m center
	t top    n top
	b bottom s bottom
	l left   w left
	r right  e right
}


proc tr {tok} { return [::tk::msgcat::mc [set $tok]] }
proc tooltip {args} {}
proc makeStateSpecificIcons {icon} { return $icon }

namespace export twm tr tooltip


if {![catch {package require tooltip}]} {
	proc tooltip {args} { ::tooltip::tooltip {*}$args }
}


proc twm {path args} {
	namespace eval [namespace current]::$path {}
	variable ${path}::Vars
	variable ${path}::MakePane
	variable Options

	array set opts { -makepane {} }
	array set opts $args
	set MakePane $opts(-makepane)
	set Vars(docking:recipient) ""
	set Vars(docking:position) ""
	set Vars(docking:current) ""
	set Vars(afterid:release) {}

	set fam [font configure $Options(header:font) -family]
	set headerFont [list $fam $Options(header:fontsize) bold]
	set background [ttk::style lookup $::ttk::currentTheme -background]
	set tabbg [ttk::style lookup TNotebook.Tab -background]
	ttk::style configure twm.TNotebook -borderwidth 0
	ttk::style configure twm.TNotebook.Tab -font $headerFont -padding {2 2}
	ttk::style configure twm.TButton -padding {1 1 0 0}
	ttk::style configure twm.TLabel -font $headerFont -background $tabbg
	#ttk::style map twm.TNotebook.Tab -background [list active $background selected $background]

	ttk::frame $path -class TwmToplevel -takefocus 0
	bind $path <Destroy> [list [namespace current]::DestroyTWM %W]

	set h [tk::toplevel $path.__highlight__ -borderwidth 0]
	pack [tk::canvas $h.c -borderwidth 0]
	$h.c create image 0 0 -anchor nw -tag image
	wm withdraw $h

	rename ::$path $path.__twm_frame__
	proc ::$path {command args} "[namespace current]::WidgetProc $path \$command {*}\$args"

	return $path
}


proc WidgetProc {twm command args} {
	variable Options

	switch -- $command {
		set				{ ::scidb::tk::twm set $twm {*}$args }
		get				{ return [::scidb::tk::twm get $twm {*}$args] }
		uid				{ return [::scidb::tk::twm uid $twm {*}$args] }
		id					{ return [::scidb::tk::twm id $twm {*}$args] }
		leader			{ return [::scidb::tk::twm leader $twm {*}$args] }
		iscontainer		{ return [::scidb::tk::twm iscontainer $twm {*}$args] }
		isnotebook		{ return [string match {*Notebook} [winfo class {*}$args]] }
		ismultiwindow	{ return [string match {*Multiwindow} [winfo class {*}$args]] }
		ispanedwindow	{ return [string match {*Panedwindow} [winfo class {*}$args]] }
		isframe			{ return [string match {Twm*Frame} [winfo class {*}$args]] }
		ismetaframe		{ return [string equal "TwmMetaframe" [winfo class {*}$args]] }
		container		{ return [::scidb::tk::twm container $twm {*}$args] }
		visible			{ return [::scidb::tk::twm visible $twm {*}$args] }
		parent			{ return [::scidb::tk::twm parent $twm {*}$args] }
		frames			{ return [::scidb::tk::twm frames $twm {*}$args] }
		panes				{ return [::scidb::tk::twm panes $twm {*}$args] }
		neighbors		{ return [::scidb::tk::twm neighbors $twm {*}$args] }
		orientation		{ return [::scidb::tk::twm orientation $twm {*}$args] }
		dock				{ return [::scidb::tk::twm dock $twm {*}$args] }
		undock			{ return [::scidb::tk::twm undock $twm {*}$args] }
		togglebar		{ return [ToggleHeader $twm {*}$args] }
		togglenotebook	{ return [::scidb::tk::twm toggle $twm {*}$args] }

		init				{ ::scidb::tk::twm init $twm {*}$args }
		load				{ ::scidb::tk::twm load $twm {*}$args }
		frame				{ return [MakeFrame $twm frame {*}$args] }
		frame2			{ MakeFrame2 $twm {*}$args }
		header			{ UpdateHeader $twm {*}$args }
		title				{ UpdateTitle $twm {*}$args }
		metaframe		{ return [MakeFrame $twm metaframe {*}$args] }
		pane				{ return [MakePane $twm {*}$args] }
		notebook			{ return [MakeNotebook $twm {*}$args] }
		multiwindow		{ return [MakeMultiwindow $twm {*}$args] }
		panedwindow		{ return [MakePanedWindow $twm {*}$args] }
		paneconfigure	{ return [PaneConfigure $twm {*}$args] }
		resized			{ return [ResizeToplevel $twm {*}$args] }
		pack				{ return [Pack $twm {*}$args] }
		unpack			{ return [Unpack $twm {*}$args] }
		select			{ return [Select $twm {*}$args] }
		destroy			{ DestroyPane $twm {*}$args }
		sashsize			{ return $Options(sash:size) }
		framehdrsize	{ return [FrameHeaderSize $twm {*}$args] }
		nbhdrsize		{ return [NotebookHeaderSize $twm {*}$args] }

		default			{ return -code error "unknown command '$command'" }
	}

	return $twm
}


proc DestroyPane {twm pane} {
	catch { destroy $pane }
}


proc FrameHeaderSize {twm frame} {
	update idletasks
	return [winfo height $frame.__header__]
}


proc NotebookHeaderSize {twm nb} {
	update idletasks
	return [expr {[winfo height $nb] - [winfo height [$nb select]]}]
}


proc MakeMultiwindow {twm args} {
	variable Counter

	set w [tk::multiwindow $twm.__multiwindow__[incr Counter(multiwindow)] -takefocus 0]
	if {[llength $args] == 1} { set args [lindex $args 0] }
	foreach {name value} $args {
		catch { $w configure $name $value }
	}
	return $w
}


proc MakeNotebook {twm args} {
	variable Counter

	set w [ttk::notebook $twm.__notebook__[incr Counter(notebook)] -style twm.TNotebook -takefocus 0]
	MenuBindings $twm $w $w
	if {[llength $args] == 1} { set args [lindex $args 0] }
	foreach {name value} $args {
		catch { $w configure $name $value }
	}
	return $w
}


proc MakePanedWindow {twm args} {
	variable Counter
	variable Options

	set w [tk::panedwindow $twm.__panedwindow__[incr Counter(panedwindow)]]
	$w configure -sashwidth $Options(sash:size)
	if {[llength $args] == 1} { set args [lindex $args 0] }
	foreach {name value} $args {
		catch { $w configure $name $value }
	}
	return $w
}


proc MakePane {twm id} {
	variable ${twm}::MakePane
	variable Options

	lassign [$MakePane $twm $twm pane $id] w name priority
	$w configure -borderwidth $Options(frame:borderwidth) -relief raised
	$twm set $w name $name priority $priority
	return $w
}


proc MakeFrame {twm type} {
	variable Counter

	set frame $twm.__${type}__[incr Counter($type)]
	set class Twm[string toupper $type 0 0]
	return [tk::frame $frame -class $class -borderwidth 0 -takefocus 0]
}


proc MakeFrame2 {twm frame id} {
	variable Options
	variable ${twm}::MakePane

	if {[winfo class $frame] eq "TwmFrame"} {
		lassign [$MakePane $twm $frame frame $id] child name priority closable undockable moveable
		$child configure -borderwidth $Options(frame:borderwidth) -relief raised
	} elseif {[$twm iscontainer $id]} {
		set child $id
		set leader [$twm leader $id]
		set name [$twm get $leader name]
		set priority [$twm get $leader priority]
		if {[llength [$twm panes $child]] > 0} {
			lassign {0 0 0} closable undockable moveable
		} else {
			lassign {1 1 1} closable undockable moveable
			set frames [$twm frames $child]
			foreach f $frames {
				if {![$twm get $f move]} { set moveable 0 }
				if {![$twm get $f close]} { set closable 0 }
				if {![$twm get $f undock]} { set undockable 0 }
			}
		}
		raise $child $frame
	} else {
		set child $id
		lassign {0 0 0} closable undockable moveable
		set priority [$twm get $id priority]
		set name [$twm get $id name]
		if {[winfo toplevel $frame] ne $frame} {
			raise $child $frame
		}
	}

	set hdr [tk::frame $frame.__header__ -borderwidth 1 -relief raised -takefocus 0]

	if {$moveable} {
		set bg $Options(header:flex:background)
	} else {
		set bg [ttk::style lookup $::ttk::currentTheme -background]
	}
	$hdr configure -background $bg
	$frame configure -background [$child cget -background]

	#pack $hdr -side top -fill x -expand no
	pack $child -side top -fill both -expand yes -in $frame

	if {$closable} {
		ttk::button $hdr.close \
			-style twm.TButton \
			-image $icon::12x12::close \
			-command [list [namespace current]::Close $twm $frame] \
			-state [expr {$closable ? "normal" : "disabled"}] \
			-takefocus 0 \
			;
		tooltip $hdr.close [tr [namespace current]::mc::Close]
		MouseWheelBindings $twm $frame $hdr.close
	}
	if {$undockable} {
		ttk::button $hdr.undock \
			-style twm.TButton \
			-image $icon::12x12::undock \
			-command [list [namespace current]::Undock $twm $frame] \
			-state [expr {$undockable ? "normal" : "disabled"}] \
			-takefocus 0 \
			;
		tooltip $hdr.undock [tr [namespace current]::mc::Undock]
		MouseWheelBindings $twm $frame $hdr.undock
	}

	set opts {}
	if {[info exists $name]} {
		lappend opts -textvar $name
		set text [set $name]
	} else {
		lappend opts -text $name
		set text $name
	}

	$twm set $frame \
		name $text \
		id $id \
		move $moveable \
		close $closable \
		undock $undockable \
		priority $priority \
		flat 0 \
		;

	ShowHeaderButtons $twm $frame
	HeaderBindings $twm $frame $hdr
}


proc ShowHeaderButtons {twm frame} {
	set hdr $frame.__header__
	set undockable [$twm get $frame undock]
	set closable   [$twm get $frame close]

	if {$undockable} { grid $hdr.undock -column 1 -row 0 }
	if {$closable}   { grid $hdr.close  -column 3 -row 0 }

	grid columnconfigure $hdr 0 -weight 1 -minsize 5
	if {$closable && $undockable} {
		grid columnconfigure $hdr 2 -minsize 3
	}
	grid columnconfigure $hdr 4 -minsize 2
}


proc UnbindHeader {w} {
	bind $w <Configure> {#}
	bind $w <ButtonPress-1> {#}
	bind $w <Button1-Motion> {#}
	bind $w <ButtonRelease-1> {#}
}


proc HeaderBindings {twm frame w} {
	if {[$twm get $frame move]} {
		bind $w <ButtonPress-1>		[list [namespace current]::HeaderPress $twm $frame %X %Y]
		bind $w <Button1-Motion>	[list [namespace current]::HeaderMotion $twm $frame %X %Y]
		bind $w <ButtonRelease-1>	[list [namespace current]::HeaderRelease $twm $frame]
	}
	MouseWheelBindings $twm $frame $w
	MenuBindings $twm $frame $w
}


proc MenuBindings {twm frame w} {
	bind $w <ButtonPress-3> [list event generate $twm <<TwmMenu>> -x %X -y %Y -data $frame]
}


proc MouseWheelBindings {twm frame w} {
	switch [tk windowingsystem] {
		x11 {
			bind $w <Button-4> [list [namespace current]::PlaceLabelBar $twm $frame -5]
			bind $w <Button-5> [list [namespace current]::PlaceLabelBar $twm $frame +5]
		}
		aqua {
			bind $w <MouseWheel> [list [namespace current]::PlaceLabelBar $twm $frame [list expr {-(%D)}]]
		}
		win32 {
			bind $w <MouseWheel> \
				[list [namespace current]::PlaceLabelBar $twm $frame [list expr {-(%D/120)*5)}]]
		}
	}
}


proc UpdateTitle {twm frame titlePath} {
	wm title $frame [$twm get $titlePath name]
}


proc ToggleHeader {twm frame} {
	variable Options

	if {![winfo exists $frame]} { return }

	set flat [$twm get $frame flat]
	$twm set $frame flat [expr {!$flat}]
	set hdr $frame.__header__
	set decor $hdr.__flat__

	if {$flat} {
		pack forget $decor
		ShowHeaderButtons $twm $frame
		HeaderBindings $twm $frame $frame
		HeaderBindings $twm $frame $hdr
		UpdateHeader $twm $frame [$twm get $frame panes]
	} else {
		if !{[winfo exists $decor]} {
			tk::canvas $decor -height $Options(flathandle:size) -background $Options(header:flex:background)
			MenuBindings $twm $frame $decor
			bind $decor <Configure> [namespace code [list ConfigureFlatHandle $decor %w %h]]
		}
		catch { destroy $hdr.l }
		catch { destroy $hdr.r }
		destroy {*}[$twm get $frame labels {}]
		set slaves [grid slaves $hdr]
		if {[llength $slaves]} { grid forget {*}$slaves }
		foreach w [place slaves $hdr] { place forget $w }
		$twm set $frame labels {}
		pack $decor -fill x -side top -expand yes
		bind $decor <ButtonRelease-1> [list [namespace current]::ToggleHeader $twm $frame]
		UnbindHeader $frame
		UnbindHeader $hdr
	}
}


proc ConfigureFlatHandle {canv w h} {
	variable Options

	if {$w <= 1} { return }

	set n [expr {$w/2}]
	set x0 [expr {($w - 2*$n)/2}]
	set y0 1 ;#[expr {($h - 6)/2}]
	set yi $y0

	for {set i 1} {$i <= $n} {incr i; incr x0 2} {
		if {[llength [$canv find withtag $i]] == 0} {
			foreach k {1 2 3} { set x$k [expr {$x0 + $k}]; set y$k [expr {$y0 + $k}] }
			$canv create rectangle $x0 $y0 $x2 $y2 -fill $Options(flathandle:color:lite) -outline {} -tag $i
			$canv create rectangle $x1 $y1 $x3 $y3 -fill $Options(flathandle:color:dark) -outline {} -tag $i
			$canv create rectangle $x1 $y1 $x2 $y2 -fill $Options(flathandle:color:gray) -outline {} -tag $i
		}
		if {$y0 == $yi} { incr y0 3 } else { set y0 $yi }
	}
}


proc UpdateHeader {twm frame panes} {
	variable ${twm}::Vars
	variable Options

	set hdr $frame.__header__
	bind $hdr <Configure> {#}
	destroy {*}[place slaves $hdr]
	catch { destroy $hdr.l }
	catch { destroy $hdr.r }
	destroy {*}[$twm get $frame labels {}]
	$twm set $frame labels {} panes $panes

	if {[llength $panes] == 0} {
		if {$Vars(docking:current) ne $frame} {
			pack forget $frame.__header__
		}
		return
	}

	if {"$frame.__header__" ni [pack slaves $frame]} {
		pack $frame.__header__ -side top -fill x -expand no -before [lindex [pack slaves $frame] 0]
		#update idletasks
	}

	raise $hdr ;# seems to be a bug in Tk lib that a child must be raised
	if {[$twm get $frame flat]} { return }

	set fam [font configure $Options(header:font) -family]
	set headerFont [list $fam $Options(header:fontsize) bold]

	set n [llength $panes]
	set parent [$twm parent $frame]
	set labels {}
	set type [expr {[$twm get $frame move] ? "flex" : "fix"}]
	set lighter [ttk::style lookup $::ttk::currentTheme -background]
	set darker [ttk::style lookup TNotebook.Tab -background]

	for {set i 0} {$i < $n} {incr i} {
		set f [lindex $panes $i]
		set lbl $hdr.$i
		set name [$twm get [$twm leader $f] name]
		ttk::label $lbl -style twm.TLabel -text $name -takefocus 0
		bind $lbl 
		place $lbl -x 0 -y 0
		lappend labels $lbl
		if {$f eq $frame} {
			HeaderBindings $twm $frame $lbl
			$twm set $frame mine $lbl
			set index $i
			if {[$twm get $frame move]} {
				$lbl configure \
					-relief flat \
					-padding {4 2 4 0} \
					-background $Options(header:$type:background) \
					-foreground $Options(header:$type:foreground) \
					;
			} else {
				$lbl configure \
					-relief raised \
					-padding {4 1 4 1} \
					-background $Options(header:tab:background) \
					-foreground $Options(header:$type:foreground) \
					;
			}
		} else {
			bind $lbl <ButtonPress-1> [list [namespace current]::Select $twm $parent $f]
			bind $lbl <Enter> [list $lbl configure -background $lighter]
			bind $lbl <Leave> [list $lbl configure -background $darker]
			MouseWheelBindings $twm $frame $lbl
			$lbl configure \
				-relief raised \
				-padding {4 0 4 2} \
				-foreground $Options(header:tab:foreground) \
				-background $darker \
				;
		}
	}

	$twm set $frame maxoffset 0 labels $labels repeat 0 width 0
	set conf [list [namespace current]::ConfigureLabelBar $twm $frame %w]
	after idle $conf
	bind $hdr <Configure> $conf
	bind $frame <Configure> $conf
}


proc ConfigureLabelBar {twm frame width} {
	variable Options

	set hdr $frame.__header__
	set bd [expr {2*$Options(frame:borderwidth)}]
	set see [expr {$width < 0}]
	set force [expr {$width <= 0}]
	set current [expr {$width > 1}]
	if {$width <= 1} { set width [winfo width $frame] }
	if {$width <= 1} { return }
	if {!$force && [$twm get $frame width 0] == $width} { return }
	$twm set $frame width $width
	set labels [$twm get $frame labels]
	if {[llength $labels] == 0} { return }
	set parent [$twm parent $frame]
	set offset [$twm get $parent offset 0]
	set h [winfo reqheight [lindex $labels 0]]
	if {$h % 2 == 1} { incr h }
	if {[winfo exists $hdr.close]} { incr width -[winfo width $hdr.close] }
	if {[winfo exists $hdr.undock]} { incr width -[winfo width $hdr.undock] }
	if {[winfo exists $hdr.close] || [winfo exists $hdr.undock]} { incr width -8 }
	if {[winfo exists $hdr.close] && [winfo exists $hdr.undock]} { incr width -3 }
	incr width -$bd

	foreach w $labels { incr totalWidth [winfo reqwidth $w] }
	if {$totalWidth > $width && [llength $labels] > 1} {
		MakeArrow $twm $frame l -5
		MakeArrow $twm $frame r +5
		set arrwd [winfo reqwidth $hdr.l]
		set maxoffset [expr {$totalWidth - $width + 2*$arrwd - $bd}]
		$twm set $frame maxoffset $maxoffset
		if {$offset > $maxoffset} { $twm set $parent offset $maxoffset }
		set totalWidth [expr {min($totalWidth, $width) - $arrwd}]
	} else {
		if {[winfo exists $hdr.l]} {
			destroy $hdr.l; destroy $hdr.r
		}
		$twm set $parent offset 0
		$twm set $frame maxoffset 0
	}

	$twm set $frame height $h labelbarwidth [expr {min($width,$totalWidth)}]
	PlaceLabelBar $twm $frame [expr {$see ? "see" : ($current ? 0 : "setup")}]
	$hdr configure -height [expr {$h + $bd}]
	grid rowconfigure $hdr 0 -minsize $h
}


proc PlaceLabelBar {twm frame incr} {
	variable Options

	if {[$twm get $frame flat]} { return }

	set parent [$twm parent $frame]
	set maxoffset [$twm get $frame maxoffset 0]
	set labels [$twm get $frame labels]
	set width [$twm get $frame labelbarwidth]
	set bd [expr {2*$Options(frame:borderwidth)}]
	set hdr $frame.__header__

	if {$incr eq "setup"} {
		set offset [$twm get $parent offset]
	} else {
		if {$incr eq "see"} {
			set incr 0
			set visible [$twm get $frame mine]
			$twm set $parent visible $visible
		} else {
			set visible [$twm get $parent visible ""]
		}
		set offset [expr {max(0, min($maxoffset, [$twm get $parent offset] + $incr))}]
		if {$maxoffset > 0} {
			if {$incr == 0} {
				if {[string length $visible] > 0} {
					set x0 0
					foreach w $labels {
						set x1 [expr {$x0 + [winfo reqwidth $w]}]
						if {$w eq $visible} { break }
						set x0 $x1
					}
					if {$x0 < $offset} {
						set offset [expr {min($x0, $maxoffset)}]
					} elseif {[set d [expr {$x1 + [winfo reqwidth $hdr.l] - $width - $offset - $bd}]] > 0} {
						set offset [expr {min($offset + $d, $maxoffset)}]
					}
				}
			} elseif {$offset == [$twm get $parent offset]} {
				return
			}
		}
	}

	$twm set $parent offset $offset
	set height [$twm get $frame height]
	set x -$offset

	if {$maxoffset > 0} {
		set ht [winfo reqheight $hdr]
		place $hdr.l -x -$bd -y 3 -height $ht
		set x [expr {$x + [winfo reqwidth $hdr.l] - $bd}]
		if {$offset == 0} { set state disabled } else { set state normal }
		if {$state ne [$hdr.l cget -state]} { $hdr.l configure -state $state }
	}

	foreach w $labels {
		if {$x >= $width} {
			place forget $w
		} else {
			set y $height
			if {[$w cget -relief] ne "flat"} { incr y $bd }
			set wd [expr {min([winfo reqwidth $w], $width - $x)}]
			if {$wd < [winfo reqwidth $w]} { set extend 4 } else { set extend 0 }
			place $w -x $x -y $y -width [expr {$wd + $extend}] -anchor sw
			incr x $wd
			raise $w ;# seems to be a bug in Tk lib that a child must be raised
		}
	}

	if {$maxoffset > 0} {
		set x $width
		set ht [winfo reqheight $hdr]
		place $hdr.r -x $x -y 3 -height $ht
		if {$offset == $maxoffset} { set state disabled } else { set state normal }
		if {$state ne [$hdr.r cget -state]} { $hdr.r configure -state $state }
		raise $hdr.l; raise $hdr.r
	}
}


proc MakeArrow {twm frame dir incr} {
	set arrow $frame.__header__.$dir
	if {[winfo exists $arrow]} { return }
	ttk::button $arrow \
		-style twm.TButton \
		-takefocus 0 \
		-image [makeStateSpecificIcons $icon::8x16::arrow($dir)] \
		-command [list [namespace current]::PlaceLabelBar $twm $frame $incr] \
		;
	bind $arrow <ButtonPress-1> [list [namespace current]::InvokeRepeat $twm $frame $arrow]
	MouseWheelBindings $twm $frame $arrow
}


proc InvokeRepeat {twm frame w} {
	if {![winfo exists $w]} { return }
	after cancel [$twm get $frame repeat]
	$twm set $frame repeat [after 300 [list [namespace current]::Repeat $twm $frame $w]]
}


proc Repeat {twm frame w} {
	if {![winfo exists $w]} { return }
	$w instate disabled { $w state !pressed } ;# looks like a Tk bug
	$w instate !pressed { return }
	$twm set $frame repeat [after 75 [list [namespace current]::Repeat $twm $frame $w]]
	eval [$w cget -command]
}


proc HeaderPress {twm frame x y} {
	variable ${twm}::Vars

	after cancel $Vars(afterid:release)
	ttk::setCursor $frame.__header__ link
	set Vars(init:x) $x
	set Vars(init:y) $y
	set Vars(delta:x) [expr {$x - [winfo rootx $frame]}]
	set Vars(delta:y) [expr {$y - [winfo rooty $frame]}]
	set Vars(docking:markers) {}
	set Vars(docking:marker) {}
	set Vars(docking:recipient) ""
	set Vars(docking:position) ""
	set Vars(docking:outside) 0
	set Vars(docking:current) $frame
	set Vars(afterid:display) {}

	# After 8 seconds without any mouse motion we will dock the window,
	# because it's too dangerous to keep the global grab.
	set Vars(afterid:release) [after 8000 [list [namespace current]::HeaderRelease $twm $frame 1]]
	ttk::globalGrab $frame
}


proc HeaderMotion {twm frame x y} {
	if {[grab status $frame] eq "none"} { return }

	if {[catch { DoHeaderMotion $twm $frame $x $y } _ opts]} {
		puts stderr "Error in HeaderMotion"
		HeaderRelease $twm $frame
		return {*}$opts -rethrow 1 0
	}
}


proc DoHeaderMotion {twm frame x y} {
	if {![namespace exists [namespace current]::${twm}]} { return }
	variable ${twm}::Vars

	after cancel $Vars(afterid:release)
	# After 8 seconds without any mouse motion we will dock the window,
	# because it's too dangerous to keep the global grab.
	set Vars(afterid:release) [after 8000 [list [namespace current]::HeaderRelease $twm $frame 1]]

	if {[winfo toplevel $frame] eq $frame} {
		after idle [list [namespace current]::ShowDockingPoints $twm $frame $x $y]

		foreach entry $Vars(docking:markers) {
			lassign $entry canv w x0 y0 x1 y1
			if {$x0 <= $x && $x < $x1 && $y0 <= $y && $y < $y1} {
				if {[llength $Vars(docking:marker)]} {
					if {$Vars(docking:marker) eq $canv} { return }
					DockingMotion $twm $frame $w $Vars(docking:marker) leave $x $y
					set Vars(docking:marker) {}
				}
				DockingMotion $twm $frame $w $canv enter $x $y
				set Vars(docking:marker) $canv
				return
			}
			if {$Vars(docking:marker) eq $canv} {
				DockingMotion $twm $frame $w $canv leave $x $y
				set Vars(docking:marker) {}
			}
		}

		WithdrawHiliteFrame $twm
		wm geometry $frame +[expr {$x - $Vars(delta:x)}]+[expr {$y - $Vars(delta:y)}]
	} elseif {abs($x - $Vars(init:x)) >= 3 || abs($y - $Vars(init:y)) >= 3} {
		set child [lindex [pack slaves $frame] end]
		bind $frame <Button1-Motion> {#}
		bind $frame <ButtonRelease-1> {#}
		set wd [winfo width $frame]
		set ht [winfo height $frame]
		set bd [$child cget -borderwidth]
		set x [expr {$x - $Vars(delta:x)}]
		$frame configure -width $wd -height $ht
		ttk::releaseGrab $frame
		$twm undock -temporary $frame
		$child configure -borderwidth 1
		set bd [expr {1 - $bd}]
		incr wd $bd; incr ht $bd
		wm geometry $frame ${wd}x${ht}+${x}+${y}
		::scidb::tk::wm dialog $frame
		wm state $frame normal
		ttk::globalGrab $frame
		bind $frame <Button1-Motion> [bind $frame.__header__ <Button1-Motion>]
		bind $frame <ButtonRelease-1> [bind $frame.__header__ <ButtonRelease-1>]
		ComputeDockingPoints $twm $frame
	}
}


proc HeaderRelease {twm frame {timeout 0}} {
	if {![winfo exists $frame]} { return }
	if {[grab status $frame] eq "none"} { return }

	# Must be at start of this function (for safety).
	ttk::releaseGrab $frame

	bind $frame <Button1-Motion> {#}
	bind $frame <ButtonRelease-1> {#}
	ttk::setCursor $frame.__header__ {}

	if {![namespace exists [namespace current]::${twm}]} { return }
	variable ${twm}::Vars

	set Vars(docking:current) ""
	after cancel $Vars(afterid:release)
	after cancel $Vars(afterid:display)
	HideDockingPoints $twm $frame

	foreach entry $Vars(docking:markers) {
		set w [lindex $entry 0]
		if {[winfo exists $w]} {
			destroy [winfo parent $w]
		}
		WithdrawHiliteFrame $twm
	}

	if {[winfo toplevel $frame] eq $frame} {
		if {$timeout} {
			set Vars(docking:recipient) ""
			set Vars(docking:position) ""
		}
		Dock $twm $frame
		if {$timeout} {
			tk_messageBox \
				-parent $twm \
				-type ok \
				-message [tr [namespace current]::mc::Timeout] \
				-detail [tr [namespace current]::mc::TimeoutDetail] \
				;
		}
	}
}

#proc ReleaseAfterTimeout {twm frame} {
#	# After 8 seconds without any mouse motion we will make a floating window,
#	# because it's too dangerous to keep the global grab.
#
#	Undock $twm $frame true
#
#	# the following does not work...
#	::scidb::tk::wm normal $frame
#
#	# ... so we need a work-around
#	set x [winfo rootx $frame]
#	set y [winfo rooty $frame]
#	wm forget $frame
#	wm manage $frame ;# ::scidb::tk::twm release $frame
#	wm state $frame normal
#	wm geometry $frame +${x}+${y}
#
#	wm title $frame $Vars(frame:name:$frame)
#	wm state $frame normal
#	wm protocol $frame WM_DELETE_WINDOW [list [namespace current]::Dock $twm $frame]
#}


proc WithdrawHiliteFrame {twm} {
	set w $twm.__highlight__
	if {[winfo exists $w]} {
		wm withdraw $w
		catch { image delete [$w.c itemcget image -image] }
	}
}


proc ShowDockingPoints {twm frame x y} {
	if {![namespace exists [namespace current]::${twm}]} { return }
	if {![winfo exists $frame]} { return }
	variable ${twm}::Vars

	foreach entry $Vars(docking:panes) {
		lassign $entry pane x0 y0 x1 y1 size

		if {!$Vars(docking:outside) && !($x0 <= $x && $x < $x1 && $y0 <= $y && $y < $y1)} {
			HideDockingPoint $twm $frame $pane
		} elseif {[info exists Vars(docking:hover:$pane)]} {
			ShowDockingPoint $twm $frame $pane $x $y $size
		}
	}
}


proc ShowDockingPoint {twm frame w x y cs} { # cs is cross size
	variable ${twm}::Vars
	variable Options

	if {[grab status $frame] eq "none"} { return }
	if {[winfo exists $w.__m__]} { return }

	foreach point $Vars(docking:hover:$w) {
		lassign $point pos x0 y0

		set x0 [expr {$x0 + $Vars(docking:shift:x:$w)}]
		set y0 [expr {$y0 + $Vars(docking:shift:y:$w)}]
		array unset lines

		switch $pos {
			m {
				set wd    [expr {$cs + 4}]
				set ht    [expr {$cs + 4}]
				set ht_1  [expr {$ht - 1}]
				set wd_1  [expr {$wd - 1}]
				set ix    2
				set iy    2
				set color 1
				set lines(white) [list -1 0 0 0 -1 $ht_1 0 $ht_1 $wd_1 0 $wd 0 $ht_1 $wd_1 $ht_1 $wd]
				set lines(t) [list 0 0 $wd 0]
				set lines(b) [list 0 $ht_1 $wd $ht_1]
				set lines(l) [list 0 0 0 $ht]
				set lines(r) [list $wd_1 0 $wd_1 $ht]
			}
			l {
				set wd    [expr {$cs + 2}]
				set ht    [expr {$cs + 4}]
				set ht_1  [expr {$ht - 1}]
				set ix    2
				set iy    2
				set color 1
				set lines(white) [list 0 0 $wd 0 0 $ht_1 $wd $ht_1 0 0 0 $ht]
			}
			r {
				set wd    [expr {$cs + 2}]
				set ht    [expr {$cs + 4}]
				set ht_1  [expr {$ht - 1}]
				set wd_1  [expr {$wd - 1}]
				set ix    0
				set iy    2
				set color 1
				set lines(white) [list 0 0 $wd 0 0 $ht_1 $wd $ht_1 $wd_1 0 $wd_1 $ht]
			}
			t {
				set wd    [expr {$cs + 4}]
				set ht    [expr {$cs + 2}]
				set wd_1  [expr {$wd - 1}]
				set ix    2
				set iy    2
				set color 1
				set lines(white) [list 0 0 $wd 0 0 0 0 $ht $wd_1 0 $wd_1 $ht]
			}
			b {
				set wd    [expr {$cs + 4}]
				set ht    [expr {$cs + 2}]
				set ht_1  [expr {$ht - 1}]
				set wd_1  [expr {$wd - 1}]
				set ix    2
				set iy    0
				set color 1
				set lines(white) [list 0 $ht_1 $wd $ht_1 0 0 0 $ht $wd_1 0 $wd_1 $ht]
			}
			n {
				set wd    [expr {$cs + 2}]
				set wd_1  [expr {$cs + 1}]
				set ht    [expr {$cs + 2}]
				set ix    0
				set iy    2
				set color 2
				set lines(white) [list 0 0 $wd 0 $wd_1 0 $wd_1 $ht]
			}
			s {
				set wd    [expr {$cs + 2}]
				set ht    [expr {$cs + 2}]
				set ht_1  [expr {$cs + 1}]
				set ix    2
				set iy    0
				set color 2
				set lines(white) [list 0 0 0 $ht 0 $ht_1 $wd $ht_1]
			}
			e {
				set wd    [expr {$cs + 2}]
				set ht    [expr {$cs + 2}]
				set wd_1  [expr {$cs + 1}]
				set ht_1  [expr {$cs + 1}]
				set ix    0
				set iy    0
				set color 2
				set lines(white) [list 0 $ht_1 $wd_1 $ht_1 $wd_1 0 $wd_1 $ht_1]
			}
			w {
				set wd    [expr {$cs + 2}]
				set ht    [expr {$cs + 2}]
				set ix    2
				set iy    2
				set color 2
				set lines(white) [list 0 0 $wd 0 0 0 0 $ht]
			}
			L {
				set ht [expr {$cs + 4}]
				set c $w.__m__.__docking__
				$c create line 0 0 0 $ht -fill white
				continue
			}
			R {
				set ht [expr {$cs + 4}]
				set wd [expr {$cs + 3}]
				set c $w.__m__.__docking__
				$c create line $wd 0 $wd $ht -fill white
				continue
			}
			T {
				set wd [expr {$cs + 4}]
				set c $w.__m__.__docking__
				$c create line 0 0 $wd 0 -fill white
				continue
			}
			B {
				set ht [expr {$cs + 3}]
				set wd [expr {$cs + 3}]
				$c create line 0 $ht $wd $ht -fill white
				continue
			}
		}

		set tl [tk::toplevel $w.__${pos}__ -width $wd -height $ht -borderwidth 0]
		wm withdraw $tl
		set c [tk::canvas $tl.__docking__ -borderwidth 0 -width $wd -height $ht]
		pack $c
		$c create rectangle 0 0 $wd $ht -width 0 -fill $Options(cross:color:$color) -tag background
		if {$pos eq "m"} { set color black } else { set color white }
		foreach dir {t b l r} {
			if {[info exists lines($dir)]} {
				foreach {lx0 ly0 lx1 ly1} $lines($dir) {
					$c create line $lx0 $ly0 $lx1 $ly1 -fill black -tags [list border:$dir border:m]
				}
			}
		}
		foreach {lx0 ly0 lx1 ly1} $lines(white) { $c create line $lx0 $ly0 $lx1 $ly1 -fill white }
		$c create image $ix $iy -anchor nw -image [set icon::${cs}x${cs}::shape($pos)]
		wm transient $tl $twm
		wm overrideredirect $tl true
		wm attributes $tl -topmost true
		wm geometry $tl ${wd}x${ht}+${x0}+${y0}
		wm state $tl normal
		raise $tl $twm.__highlight__

		if {$tl ni $Vars(docking:markers)} {
			lappend Vars(docking:markers) [list $c $w $x0 $y0 [expr {$x0 + $wd}] [expr {$y0 + $ht}]]
		}
	}
}


proc DockingMotion {twm frame w canv mode x y} {
	variable ${twm}::Vars
	variable Options

	if {![winfo exists $canv]} { return }

	switch $mode {
		enter {
			regexp {.*\.__([tbrlmnswe])__\.__docking__} $canv -> Vars(docking:position)
			$canv itemconfigure background -fill $Options(cross:active)
			$w.__m__.__docking__ itemconfigure border:$Vars(docking:position) -fill white
			after cancel $Vars(afterid:display)
			if {$Vars(docking:position) in {n s w e}} { set w [lindex [$w panes] 0] }
			set Vars(docking:recipient) $w
			set Vars(afterid:display) \
				[after 100 [list [namespace current]::ShowHighlightRegion $twm $frame $w $canv]]
			raise [winfo toplevel $w]
			raise $frame
		}

		leave {
			if {$Vars(docking:position) in {n s e w}} { set i 2 } else { set i 1 }
			$canv itemconfigure background -fill $Options(cross:color:$i)
			$w.__m__.__docking__ itemconfigure border:$Vars(docking:position) -fill black
			after cancel $Vars(afterid:display)
			set Vars(docking:recipient) ""
			set Vars(docking:position) ""
			wm geometry $frame +[expr {$x - $Vars(delta:x)}]+[expr {$y - $Vars(delta:y)}]
			set h $twm.__highlight__
			if {[winfo exists $h]} {
				wm withdraw $h
				catch { image delete [$h.c itemcget image -image] }
			}
		}
	}
}


proc ShowHighlightRegion {twm frame w canv} {
	if {![namespace exists [namespace current]::${twm}]} { return }

	variable ${twm}::Vars
	variable Options

	update idletasks

	set tl $twm.__highlight__
	if {[winfo exists $tl]} {
		wm withdraw $tl
		catch { image delete [$tl.c itemcget image -image] }
		update idletasks
	}

	set minSize $Options(highlight:minsize)
	set position $Vars(docking:position)

	if {$position in {n s w e}} {
		set w [lindex [pack slaves $w] 1]
		set dividend 3
		set minSize [expr {($minSize*2)/3}]
	} else {
		set dividend 2
	}

	set x   [winfo rootx $w]
	set y   [winfo rooty $w]
	set wd  [winfo width $w]
	set ht  [winfo height $w]
	set ht2 [expr {max(2,min($minSize,$ht/$dividend))}]
	set wd2 [expr {max(2,min($minSize,$wd/$dividend))}]

	set v $w
	if {$w in [pack slaves [winfo parent $v]]} { set v [winfo parent $w] }
	lassign [$twm neighbors $v] wL wR
	set orient [string index [$twm orientation $v] 0]

	if {$orient eq "h" && $position eq "l" && [string length $wL]} {
		set wdL  [winfo width $wL]
		set wd2L [expr {max(2,min($minSize,$wdL/$dividend))}]
		set wd2  [expr {min($wd2,$wd2L)}]
		set x    [expr {$x - $wd2/2}]
	} elseif {$orient eq "h" && $position eq "r" && [string length $wR]} {
		set wdR  [winfo width $wR]
		set wd2R [expr {max(2,min($minSize,$wdR/$dividend))}]
		set wd2  [expr {min($wd2,$wd2R)}]
		set x    [expr {$x + $wd2/2}]
	} elseif {$orient eq "v" && $position eq "t" && [string length $wL]} {
		set htL  [winfo height $wL]
		set ht2L [expr {max(2,min($minSize,$htL/$dividend))}]
		set ht2  [expr {min($ht2,$ht2L)}]
		set y    [expr {$y - $ht2/2}]
	} elseif {$orient eq "v" && $position eq "b" && [string length $wR]} {
		set htR  [winfo height $wR]
		set ht2R [expr {max(2,min($minSize,$htR/$dividend))}]
		set ht2  [expr {min($ht2,$ht2R)}]
		set y    [expr {$y + $ht2/2}]
	}

	set x2 [expr {$x + $wd - $wd2}]
	set y2 [expr {$y + $ht - $ht2}]

	switch $position {
		m     { set vars {} }
		t - n { set vars {ht} }
		l - w { set vars {wd} }
		b - s { set vars {ht y} }
		r - e { set vars {wd x} }
	}
	foreach var $vars { set $var [set ${var}2] }

	$tl.c configure -width $wd -height $ht
	set img [image create photo -width $wd -height $ht]
	::scidb::tk::x11 region $x $y $img
	::scidb::tk::image paintover $Options(highlight:color) $Options(highlight:opacity) $img
	$tl.c itemconfigure image -image $img
	wm geometry $tl ${wd}x${ht}+${x}+${y}
	wm overrideredirect $tl true
	wm transient $tl $w
	wm state $tl normal
	after idle [list [namespace current]::HeaderMotion $twm $frame {*}[winfo pointerxy $twm]]
}


proc HideDockingPoints {twm frame} {
	variable ${twm}::Vars

	foreach name [array names Vars docking:hover:*] {
		set w [lindex [split $name :] 2]
		HideDockingPoint $twm $frame $w
	}
}


proc HideDockingPoint {twm frame w} {
	foreach dir {l r t b m n s e w} {
		catch { destroy $w.__${dir}__ }
	}
}


proc SortX {lhs rhs} { return [expr {[lindex $lhs 1] - [lindex $rhs 1]}] }
proc SortY {lhs rhs} { return [expr {[lindex $lhs 3] - [lindex $rhs 3]}] }


proc ComputeDockingPoints {twm frame} {
	variable ${twm}::Vars

	update idletasks
	array unset Vars docking:hover:*
	array unset Vars docking:shift:x:*
	array unset Vars docking:shift:y:*
	set Vars(docking:panes) {}
	array set bounds { l 0 r 0 t 0 b 0 }

	foreach entry [$twm visible] { ComputePoints $twm $entry }

	# The following algorithm is separating overlapping crosses, no cross
	# should overlap another one.

	foreach entry $Vars(docking:panes) {
		lassign $entry w x0 y0 x1 y1

		set points $Vars(docking:hover:$w)
		set Vars(docking:shift:x:$w) 0
		set Vars(docking:shift:y:$w) 0
		set l [lindex $points 1 1]; set r [lindex $points 2 1]
		set t [lindex $points 3 2]; set b [lindex $points 4 2]
		incr r 36; incr b 36
		while {[info exists same($l:$t)]} {
			incr l; incr r; incr Vars(docking:shift:x:$w)
		}
		lappend rects [list $w $l $r $t $b]
		set same($l:$t) 1
	}

	if {![info exists rects]} { return }

	# Firstly separate horizontally.

	set rects [lsort -command [namespace current]::SortX $rects]
	set n [llength $rects]
	set lastr -100000
	set indices {}
	set index 0

	for {set i 0} {$i < $n} {incr i} {
		lassign [lindex $rects $i] w l r t b
		set repr($w) $index
		if {[info exists equal($l)]} {
			lappend equal($l) $i
		} else {
			set dist($index) [expr {$l - $lastr}]
			set move($index) 0
			set lastr $r
			set equal($l) $i
			lappend indices $i
			incr index
		}
	}

	set n [llength $indices]
	set odd 0

	for {set i 0} {$i < $n} {incr i} {
		if {$dist($i) < 0} {
			set shift(l) [expr {-($odd + $dist($i))/2}]
			set shift(r) [expr {-$dist($i) - $shift(l)}]
			if {$dist($i) % 2 == 1} { set odd [expr {1 - $odd}] }

			for {set j [expr {$i - 1}]} {$j >= 0 && $shift(l) > 0} {incr j -1} {
				set d $dist($j)
				set move($j) [expr {$move($j) - $shift(l)}]
				if {$j > 0} { set dist($j) [expr {max(0, $d - $shift(l))}] }
				set shift(l) [expr {$shift(l) - $d}]
			}

			set move($i) [expr {$move($i) + $shift(r)}]
			set dist($i) 0

			for {set j [expr {$i + 1}]} {$j < $n && $shift(r) > 0} {incr j} {
				set d [expr {min($shift(r), max(0, $dist($j)))}]
				set s [expr {$shift(r) - $d}]
				set dist($j) [expr {$dist($j) - $d}]
				set move($j) [expr {$move($j) + $s}]
				set shift(r) [expr {$shift(r) - $d}]
			}
		}
	}

	for {set i 0} {$i < $n} {incr i} {
		set index [lindex $indices $i]
		set l [lindex $rects $index 1]
		foreach k $equal($l) {
			set Vars(docking:shift:x:[lindex $rects $k 0]) $move($i)
		}
	}

	# Secondly separate vertically.

	array unset equal
	array unset move
	array unset dist

	set rects [lsort -command [namespace current]::SortY $rects]
	set n [llength $rects]
	set lastb -100000
	set indices {}
	set index 0

	for {set i 0} {$i < $n} {incr i} {
		lassign [lindex $rects $i] w l r t b
		set repr($w) $index
		if {[info exists equal($t)]} {
			lappend equal($t) $i
		} else {
			set dist($index) [expr {$t - $lastb}]
			set move($index) 0
			set lastb $b
			set equal($t) $i
			lappend indices $i
			incr index
		}
	}

	set n [llength $indices]
	set odd 0

	for {set i 0} {$i < $n} {incr i} {
		if {$dist($i) < 0} {
			set shift(t) [expr {-($odd + $dist($i))/2}]
			set shift(b) [expr {-$dist($i) - $shift(t)}]
			if {$dist($i) % 2 == 1} { set odd [expr {1 - $odd}] }

			for {set j [expr {$i - 1}]} {$j >= 0 && $shift(t) > 0} {incr j -1} {
				set d $dist($j)
				set move($j) [expr {$move($j) - $shift(t)}]
				if {$j > 0} { set dist($j) [expr {max(0, $d - $shift(t))}] }
				set shift(t) [expr {$shift(t) - $d}]
			}

			set move($i) [expr {$move($i) + $shift(b)}]
			set dist($i) 0

			for {set j [expr {$i + 1}]} {$j < $n && $shift(b) > 0} {incr j} {
				set d [expr {min($shift(b), max(0, $dist($j)))}]
				set s [expr {$shift(b) - $d}]
				set dist($j) [expr {$dist($j) - $d}]
				set move($j) [expr {$move($j) + $s}]
				set shift(b) [expr {$shift(b) - $d}]
			}
		}
	}

	for {set i 0} {$i < $n} {incr i} {
		set index [lindex $indices $i]
		set t [lindex $rects $index 3]
		foreach k $equal($t) {
			set Vars(docking:shift:y:[lindex $rects $k 0]) $move($i)
		}
	}

	# Test whether any cross is not completely inside the bounding region.

	foreach entry $Vars(docking:panes) {
		lassign $entry w l0 t0 r0 b0

		foreach point $Vars(docking:hover:$w) {
			lassign $point pos l1 t1

			incr l1 $Vars(docking:shift:x:$w)
			incr t1 $Vars(docking:shift:y:$w)
			set r1 [expr {$l1 + 34}]
			set b1 [expr {$t1 + 34}]

			if {!($l1 >= $l0 && $t1 >= $t0 && $r1 <= $r0 && $b1 <= $b0)} {
				set Vars(docking:outside) 1
			}
		}
	}
}


proc ComputePoints {twm entry} {
	variable ${twm}::Vars
	variable Options

	lassign $entry w dirs
	if {[info exists Vars(docking:hover:$w)]} { return }
	if {![winfo ismapped $w]} { return }

	set x  [winfo rootx $w]
	set y  [winfo rooty $w]
	set wd [winfo width $w]
	set ht [winfo height $w]

	set s $Options(cross:size)
	if {$wd < 5*$s && $ht < 5*$s} { set s 16; }

	set mx [expr {$x + $wd/2 - ($s + 4)/2}]
	set my [expr {$y + $ht/2 - ($s + 4)/2}]
	set tx $mx
	set ty [expr {$my - ($s + 2)}]
	set bx $mx
	set by [expr {$my + ($s + 4)}]
	set lx [expr {$mx - ($s + 2)}]
	set ly $my
	set rx [expr {$mx + ($s + 4)}]
	set ry $my

	set m [list m $mx $my]
	if {"l" in $dirs} { set l [list l $lx $ly] } else { set l [list L $mx $my] }
	if {"r" in $dirs} { set r [list r $rx $ry] } else { set r [list R $mx $my] }
	if {"t" in $dirs} { set t [list t $tx $ty] } else { set t [list T $mx $my] }
	if {"b" in $dirs} { set b [list b $bx $by] } else { set b [list B $mx $my] }
	lappend Vars(docking:hover:$w) $m $l $r $t $b
	if {"n" in $dirs} { lappend Vars(docking:hover:$w) [list n $rx $ty] }
	if {"s" in $dirs} { lappend Vars(docking:hover:$w) [list s $lx $by] }
	if {"e" in $dirs} { lappend Vars(docking:hover:$w) [list e $rx $by] }
	if {"w" in $dirs} { lappend Vars(docking:hover:$w) [list w $lx $ty] }

	lappend Vars(docking:panes) [list $w $x $y [expr {$x + $wd}] [expr {$y + $ht}] $s]
}


proc Undock {twm frame} {
	pack forget $frame.__header__
	[pack slaves $frame] configure -borderwidth 0
	set child [lindex [pack slaves $frame] end]
	set wd [winfo width $child]
	set ht [winfo height $child]
	set x [winfo rootx $frame]
	set y [winfo rooty $frame]
	$child configure -width $wd -height $ht
	set toplevel [$twm undock $frame]
	::update idletasks ;# is reducing flickering
	wm geometry $toplevel ${wd}x${ht}+${x}+${y}
 	#wm transient $toplevel $twm
	wm title $toplevel [$twm get $frame name]
	wm state $toplevel normal
	wm protocol $toplevel WM_DELETE_WINDOW [list [namespace current]::Dock $twm $toplevel]
}


proc Dock {twm toplevel} {
	variable ${twm}::Vars
	variable Options
	variable DirMap
	global errorInfo errorCode

	if {![winfo exists $twm]} { return }
	if {![winfo exists $toplevel]} { return }
	wm protocol $toplevel WM_DELETE_WINDOW {}

	set options {}

	if {[string length $Vars(docking:recipient)]} {
		lappend options $Vars(docking:recipient) $DirMap($Vars(docking:position))
	}

	# NOTE: This procedure may be called via WM_DELETE_WINDOW callback, and in this
	# case the error handling of Tcl is not working (I don't know why), thus we have
	# to catch errors by hand.
	set errorInfo {}
	set frame [$twm dock $toplevel {*}$options]
	if {[string length $errorInfo]} {
		return -code 1 -errorcode $errorCode -errorinfo $errorInfo -rethrow 1 $errorInfo
	}

	$twm set $frame width 0 ;# otherwise ConfigureLabelBar may not work as expected

	set Vars(docking:recipient) ""
	set Vars(docking:position) ""

	if {[llength [set slaves [pack slaves $frame]]] > 0} {
		[lindex $slaves end] configure -borderwidth $Options(frame:borderwidth)
	}
}


proc Close {twm frame} {
	destroy $frame
}


proc DestroyTWM {twm} {
	after idle [list [namespace current]::DestroyNamespace $twm]
}


proc DestroyNamespace {twm} {
	if {[namespace exists $twm]} {
		namespace delete $twm
	}
}


proc ResizeToplevel {twm toplevel width height} {
	if {$twm eq $toplevel} { set toplevel .application }
	wm geometry $toplevel ${width}x${height} ;# XXX
}


proc PaneConfigure {twm parent child opts} {
	array set args $opts

	if {[$parent cget -orient] eq "horizontal"} {
		if {[info exists args(-minwidth)]} { lappend options -minsize $args(-minwidth) }
		if {[info exists args(-maxwidth)]} { lappend options -maxsize $args(-minwidth) }
		if {[info exists args(-width)]}    { lappend options -width $args(-width) }
	} else {
		if {[info exists args(-minheight)]} { lappend options -minsize $args(-minheight) }
		if {[info exists args(-maxheight)]} { lappend options -maxsize $args(-minheight) }
		if {[info exists args(-height)]}    { lappend options -height $args(-height) }
	}

	$parent paneconfigure $child {*}$options
}


proc Pack {twm parent child opts} {
	set class [winfo class $parent]

	switch -glob -- $class {
		*Panedwindow {
			array set args $opts
			set options {}

			if {[info exists args(-after)]} {
				lappend options -after $args(-after)
			} elseif {[info exists args(-before)]} {
				lappend options -before $args(-before)
			}
			if {[info exists args(-sticky)]} {
				lappend options -sticky $args(-sticky)
			}
			if {[$parent cget -orient] eq "horizontal"} {
				if {[info exists args(-minwidth)]} { lappend options -minsize $args(-minwidth) }
				if {[info exists args(-maxwidth)]} { lappend options -maxsize $args(-minwidth) }
				if {[info exists args(-width)]}    { lappend options -width $args(-width) }
			} else {
				if {[info exists args(-minheight)]} { lappend options -minsize $args(-minheight) }
				if {[info exists args(-maxheight)]} { lappend options -maxsize $args(-minheight) }
				if {[info exists args(-height)]}    { lappend options -height $args(-height) }
			}

			$parent add $child -stretch always {*}$options
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

			set leader [$twm leader $child]
			set name [$twm get $leader name]
			$parent insert $pos $child -text $name {*}$options
		}

		*Multiwindow {
			array set args $opts
			set options {}

			if {[info exists args(-after)]} {
				lappend options -after $args(-after)
			} elseif {[info exists args(-before)]} {
				lappend options -before $args(-before)
			}
			if {[info exists args(-sticky)]} {
				lappend options -sticky $args(-sticky)
			}

			$parent add $child {*}$options

			if {[$twm get $child flat 0]} {
				ToggleHeader $twm $child
			}
		}

		TwmMetaframe {
			pack $child -side top -fill both -expand yes -in $parent
		}

		TwmToplevel - TwmFrame {
			array set args $opts
			set options {}

			if {$class eq "TwmToplevel"} {
				lappend options -sticky nsew
			} elseif {[info exists args(-sticky)]} {
				lappend options -sticky $args(-sticky)
			}
			if {[info exists args(-width)]} {
				$child configure -width $args(-width)
			}
			if {[info exists args(-height)]} {
				$child configure -height $args(-height)
			}

			grid $child -column 1 -row 1 -in $parent {*}$options

			if {$class eq "Frame"} { set args(-expand) both }
			if {[info exists args(-expand)]} {
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

#	if {$class ne "Frame"} {
#		# Without this little work-around it may happen that the
#		# packed child will not be displayed immediately (obviously
#		# a bug in Tk library).
#		$child configure -width [winfo width $child] -height [winfo height $child]
#	}

#puts "==================================="
#update idletasks
#TraverseChilds $twm .application
#puts "==================================="
}


proc Unpack {twm parent child} {
	if {[$twm iscontainer $parent]} {
		$parent forget $child
	} else {
		pack forget $child
	}
#puts "==================================="
#update idletasks
#TraverseChilds $twm .application
#puts "==================================="
}


proc Select {twm parent frame} {
	if {[$twm isnotebook $parent]} {
		$parent select $frame
	} else {
		$parent raise $frame
	}
}


proc TraverseChilds {twm w {indent ""}} {
	variable visited
	if {[string length $indent] == 0} { set visited {} }
	if {[string match {*__header__*} $w]} { return }
	if {[string match {*__highlight__*} $w]} { return }
	#if {[winfo class $w] eq "TwmToplevel"} { return }
	puts ${indent}$w
	#puts "${indent}$w ([winfo width $w]x[winfo height $w])"
	append indent "  "
	lappend visited $w
	switch -glob -- [winfo class $w] {
		*Panedwindow - *Multiwindow {
			foreach child [$w panes] { TraverseChilds $twm $child $indent }
		}
		*Notebook {
			foreach child [$w tabs] { TraverseChilds $twm $child $indent }
		}
		TwmToplevel - Toplevel {
			foreach child [winfo children $w] {
				if {$child ni $visited} {
					TraverseChilds $twm $child $indent
				}
			}
		}
	}
}


rename ::ttk::notebook::ActivateTab ::ttk::notebook::ActivateTab__

proc ::ttk::notebook::ActivateTab {w tab} {
	if {[$w cget -style] ne "twm.TNotebook"} {
		return [::ttk::notebook::ActivateTab__ $w $tab]
	}
	set oldtab [$w select]
	$w select $tab
	set newtab [$w select]
	if {$newtab eq $oldtab} { return }
	update idletasks
	if {[set f [ttk::focusFirst $newtab]] ne ""} { ttk::traverseTo $f }
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

namespace eval 16x16 {

set shape(t) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAARFQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HX49HHg7HHg7HHg7JKFJHHg7HHg7HHc7IZREJKJJ
	HHg7HHg7HX49JKNJHHg7HHg7HHg7JKBIJKJJHHg7HHc7II5CJKNJHHg7HHg7HXs8JKNJHHg7HHg7
	HHg7I51HJKJJHHg7HHg7HoQ/JKNJJKJJJKJJHHg7HHg7HX49IIxCIZBDJKFJJKJJJKJJJKFJHHg7
	HHg7HHg7HHc7IphGJKJJJKJJI5pGHHg7HHg7HHg7HHg7IZVFJKNJJKNJJKNJJKNJIphGHHc7HHg7
	HHg7HHo8HoM/HoM/HoM/HHo8HHg7HHg7HHg7HHg7HHg7HHg7HHg7JKJJ////4/S0egAAAFl0Uk5T
	AAA03AukwaFgRSbLg3EGlcFP3U/eW6Qcw5No9QPJTtE+22iVFLWiX/CA0EKo5fbpiCE3M4P6+4XT
	3devS+zyXyJHTok9tsnIvVHGTdhrR0pIb9lAkevo5+xqgaAzAAAAAWJLR0RaA7ulogAAAAlwSFlz
	AAAASAAAAEgARslrPgAAALhJREFUGBkdwbFKA0EYhdHvzj+zbgw2FisoIYQEbATbFHa+r+AD5AFs
	7Cws7CSIVmaLWGxync05ohIStqkyo5DQ4WAgASIfI4aMAAGaSML23iDQhSpc9SYjiqRHNraRM3Sq
	oNjuvgnd9NOIB5hvU9p1fehyGrGmmn2l8/Sbl6o4KbaXcRXVTwe8pZHudbLiQ4OrPJFe1hK0Go6y
	Y1XK4v267P+apn29dRZoficJVU8mAZ/tqDlLz8A/+C88sUmqPCkAAAAldEVYdGRhdGU6Y3JlYXRl
	ADIwMTctMDYtMTJUMTU6MTY6NDMrMDI6MDDRYaWyAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE3LTA2
	LTEyVDE1OjE2OjQzKzAyOjAwoDwdDgAAAABJRU5ErkJggg==
}]

set shape(b) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAARpQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHo8HoM/HoM/HoM/HHo8HHg7HHg7HHg7
	HHg7HHg7HHg7HHc7IphGJKNJJKNJJKNJJKNJIZVFHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHc7
	I5pGJKJJJKJJIphGHHg7HHg7HHg7HHg7HX49IIxCIZBDJKFJJKJJJKJJJKFJHHg7HHg7HoQ/JKNJ
	JKJJJKJJHHg7HHg7HHg7I51HJKJJHHg7HXs8JKNJHHg7HHg7HHc7II5CJKNJHHg7HHg7JKBIJKJJ
	HHg7HHg7HX49JKNJHHg7HHc7IZREJKJJHHg7HHg7JKFJHHg7HX49HHg7HHg7HHg7JKJJ////SOnv
	mgAAAFx0Uk5TAAALku7o5+uRQNltSEpHa9g+I0lNlcZRvcjJtj3DiU5HItTd169f8uxL3NPpiCE3
	M4X7+oOA0EKo5fYUtaJf8NtolQODyU7RHJNo9U/eW6QGwU/dJstxYEWkwTTifTOdAAAAAWJLR0Rd
	nd8wAQAAAAlwSFlzAAAASAAAAEgARslrPgAAALFJREFUGBkFwbFKAmAYhtHn+f6vkEIot4YWL0Hw
	KhobusYGx1ZnhwahJQhaihYhAwkhhLdzBFUl5V+C4EQV1Z/gTFVVVe0rTemSZ09nf5n0harCpad0
	4lLVOfCeJOlz1VuA+UeSjM/DTdUUgF99eSsW3b0D2HX3gsq6X8fYw36M115H5E6dckjyRIrQmzGO
	xzE2TRDw3v2M7+usAgWwqq+qr1oBCKAPkscEKABS220FgH9290RF4h/KywAAACV0RVh0ZGF0ZTpj
	cmVhdGUAMjAxNy0wNi0xMlQxNToxNjo0MCswMjowMOCJvy8AAAAldEVYdGRhdGU6bW9kaWZ5ADIw
	MTctMDYtMTJUMTU6MTY6NDArMDI6MDCR1AeTAAAAAElFTkSuQmCC
}]

set shape(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAARRQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HoQ/
	HX49HHg7HHg7HHg7HHg7HHc7HXs8I51HJKNJIIxCHHg7HHg7HHg7HHg7HHg7II5CJKNJJKJJJKJJ
	IZBDHHc7HHc7HHg7HHg7HHg7HHg7HHg7HHc7HX49JKBIJKNJJKJJJKJJJKFJI5pGIphGHHo8HHg7
	HHg7HHg7IZREJKNJJKJJJKJJJKJJJKNJHoM/HHg7HHg7HX49JKFJJKJJJKNJHoM/HHg7JKJJJKJJ
	JKNJHoM/JKNJJKFJIphGIpVFHHo8II5CJKNJIZBDHHg7HHg7HHg7HHg7JKJJ////eyJnmgAAAFp0
	Uk5TAAAUgOzTIgQ+tdGJ3Eccg9uiQiLXTwjDy2hfqDeVDSXek0yV8uM0r8fZkQxgzcFbaNH+9oVf
	UG/qNKRPpPT69b1J6MFFcd7ISuf57rdI0oNKPGpOljXE2No8FZWDVwAAAAFiS0dEW3S8lTQAAAAJ
	cEhZcwAAAEgAAABIAEbJaz4AAACTSURBVBjTY2SAAEYGRhD4/Z8FymdjhAgwsECkeSF8xi9gAUbR
	/0wQLi+7GFAvg9w/ZkYkoAWlNW5CaEvGS8w6jIyyQK1PwAI85kBCBGr5W0ZGJgY0gKzlA1DtH+an
	fIICv3794rwnclOQmZn5Ncv/a2BrWZVOMbJd0mf8xIjsMJvNfkcZUZ3+5j8jque+wAQQ3gcAhYUl
	e8XgaXAAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTctMDYtMTJUMTU6MTY6MzIrMDI6MDB906cfAAAA
	JXRFWHRkYXRlOm1vZGlmeQAyMDE3LTA2LTEyVDE1OjE2OjMyKzAyOjAwDI4fowAAAABJRU5ErkJg
	gg==
}]

set shape(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAASlQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HX49HoQ/HHg7
	HHg7HHg7HHg7HHg7HHg7HHg7IIxCJKNJI51HHXs8HHc7HHg7HHg7HHg7HHg7HHg7HHc7IZBDJKJJ
	JKJJJKNJII5CHHc7HHg7HHg7HHg7HHo8IpVFIphGJKFJJKJJJKJJJKNJJKBIHX49HHc7HHg7HHg7
	HHg7HHg7HoM/JKNJJKJJJKJJJKJJJKNJIZREHHg7HHg7HoM/JKNJJKJJJKFJHX49HHg7HHg7HoI+
	JKJJHHg7HHo8JKNJJKBIHX49HHg7HHg7HHc7IZBDJKNJII5CHHg7HHg7HHg7HXs8HHc7HHg7HHg7
	HHg7HHg7JKJJ////AU/PLwAAAGF0Uk5TAAAi0+yAFEfcidG1PgRP1yJCotuDHA0/lzeoX2bKwwiS
	2cmwNOPylk6T3pUlajxKg/b+0mtcwc1gDOdIt+759aRPpDRKyN5xRcHoSPTtbdFoW9jErzWVTJM8
	2mjLSd0j1GKioicAAAABYktHRGIruR08AAAACXBIWXMAAABIAAAASABGyWs+AAAAp0lEQVQY02Ng
	YGRiZmFlY2RkgAFGdg5OLm4eXrgIIx+/gKCQsIgoVJGYuISwpJS0jKwcnzxYREFRSVlFVU1dQ1NL
	WwekiEVXT9/AMNHI2MTUzNzCkpHBytrG1i4RCOwdHEU4nJwZrFxcE6HAzd3DkwNTwMsbqsUHqsXX
	D2Kof0AgxFCFoOCQUFW1sPAIqLVikZxRQIdFx8AchuF0BsbYODTPxScgex8APJskq6UiDmgAAAAl
	dEVYdGRhdGU6Y3JlYXRlADIwMTctMDYtMTJUMTU6MTY6MzYrMDI6MDCJnIMMAAAAJXRFWHRkYXRl
	Om1vZGlmeQAyMDE3LTA2LTEyVDE1OjE2OjM2KzAyOjAw+ME7sAAAAABJRU5ErkJggg==
}]

set shape(m) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAT5QTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHc7G3Q6Gm44Gm84HHU6HHc7
	HHg7HHg7HHg7HHg7HHg7HHY6JaZKJKNJJKNJJKRKJahLG3U6HHg7HHg7HHg7HHg7HXw8JKNJJKJJ
	JKJJJKNJHX09HHg7HHg7HHY6JKJJJKRKHHc7HHg7HHg7HHg7I59II59IHHg7HHg7HHY6JKRKJKJJ
	HHY6HHg7HHg7G3Q6JKNJG3U6HHg7G3U6HHg7HHc7JKRKHHY6HHg7I5tHJKJJJKBIHHg7HHg7HHc7
	HHY6HHg7HHg7HHg7HXs8HX89HHg7HHg7HHU6JalLJKJJJKNJJqpMHHg7HHg7HHg7HHg7HHc7G3U6
	GWo2GWk2G3M5HHc7HHg7HHg7HHg7HHg7HHg7JKJJ////oMHfiAAAAGh0Uk5TAAAKTp/Bxs3JohyO
	um4nExY4c7SNHa6jIBZQdlAVHZiqCJsXScb2ShGPuyHlSSzIqJQbGqbXYE/1WNTkNXU65jnZZU5Z
	nR3FGYzONSjDkLkiDpWxIBV3URUUiae2cC0ODR5RpKG4l039BLxLAAAAAWJLR0RpvGvEtAAAAAlw
	SFlzAAAASAAAAEgARslrPgAAAL5JREFUGBlNwbFqwlAUBuD/Pzn3BpeWoi/gIIIgKHQMDr5Bn9Jn
	cBEKcRQFBSehS53SdrD1hmh71BiL30eAN4WZgUSN//YBZIMl8OInY3P3wLMhJiYs4pxRm0eX4CIl
	uZJuHP8lKCW5e++rI+uo1K1F8d73UOl550QFdwQi6heoLAo9yFcUPaLy8eQKWTq3TVFKRXXOZpfc
	5BxiYtLhOte378HsmdNP9HmWZSRqfOHV9jVAzEIYxaPfnaqOg9kJ/7o7j1DvB+0AAAAldEVYdGRh
	dGU6Y3JlYXRlADIwMTctMDYtMTJUMTU6MTY6MjYrMDI6MDBFNoOSAAAAJXRFWHRkYXRlOm1vZGlm
	eQAyMDE3LTA2LTEyVDE1OjE2OjI2KzAyOjAwNGs7LgAAAABJRU5ErkJggg==
}]

foreach {dir pt} {t n b s l w r e} {
	set shape($pt) [image create photo -width 16 -height 16]
	::scidb::tk::image copy $shape($dir) $shape($pt)
	::scidb::tk::image recolor black $shape($pt)
}

} ;# namespace 16x16

namespace eval 24x24 {

set shape(t) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAbxQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHk7HHg7
	HHg7HHg7HHg7JKRKHHg7HHg7HHg7HHc7IpdFJKJJHHg7HHg7HHg7HXs8JKJJJKJJHHg7HHg7HHg7
	HHc7JKFJJKJJHHg7HHg7HHg7HHg7IIxCJKJJJKJJHHg7HHg7HHg7HHg7JKNJJKJJHHg7HHg7HHg7
	HHc7JKJJJKJJHHg7HHg7HHg7H4lBJKJJJKJJHHg7HHg7HHg7HHg7JKNJJKJJHHg7HHg7HHg7I5xH
	JKJJHHg7HX09JKNJJKJJHHg7HHg7HHc7JKNJJKJJHHg7HX89JKNJJKJJJKJJJKJJHHg7HHg7HHg7
	Gm84GGU1GGM0IIxCJKJJJKJJJKJJHHg7HHg7HHg7HHg7HHc7JaVKJKJJJKJJJKRKHHg7HHg7HHg7
	HHg7HHg7HHg7HHg7JaZKJKJJJKRKHHg7HHg7HHg7HHg7HHg7JalLJKJJJKJJJKJJJaZKHHg7HHg7
	HHg7HHg7HX09II9DII9DHX89HHg7HHg7HHg7HHg7HHg7HHg7JKJJHHg7////Q2IZTgAAAJF0Uk5T
	AAAGZ+831/MyDaL7iZ9g9bscKM/qUzkLkPqRH7gBTtEpdvkexPBdO9sDf/yjHqf+R+PYNWT0GLD5
	cC/SbfevIpn8MOHmQFXvEKH4Ksi/Hof9y+1OUuuLCEd/l+bWPxUSDw4PhfqI/e7r3lZE8vdjXr3B
	wNvyXzrxZOUOHR99KbO/uUjxll2YHRobIyXOt7wCxysmg7YAAAABYktHRJPhA9+2AAAACXBIWXMA
	AABIAAAASABGyWs+AAABTklEQVQYGUXBPWsUYRiF4fvMvJlxjUFSmMaFDZJiLFJYaBUt0gQDtrax
	lTRaWIitYpFVSzvR1l9gYRWWDWgZ/Kj8aALGgIjNCjHH95kd43WJfwoJ+4hOoqNSwsVvM5WY0glJ
	uNDEtBKdGUnYMxOmREvzynD2wwQRtKCAw77JCkK/Pqg6B3WfIDKdU7jJU4dPBhKgRi2oHZqPhhLQ
	2RQ24ML7MnwDBLqocJ3w0uGtSdBUCrQqh+YDJVpO4Rqt5nOZnfpCobW63quqdTrrVbVX12tK/bGu
	LEkcS17ytvtaPa1shf9Gzn5q7sFIEtIlwhsb2yv3dHmgzjKwqz9ufU075/WdBWVkPR3a+5zxTrE5
	7g0WZwPh5Oyz+cVBb7wp3ZXQu9e3JEAa3tEE+6FEdv/VVUlkOhyNfnFsa1g/mms9rodbBBGevLhR
	MHX0fOM22V/ecn1VrQ5SrwAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNy0wNi0xMlQxOToxMzoyNysw
	MjowMJ/S+pkAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTctMDYtMTJUMTk6MTM6MjcrMDI6MDDuj0Il
	AAAAAElFTkSuQmCC
}]

set shape(b) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAcJQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HoA+II9DII9DHX09
	HHg7HHg7HHg7HHg7HHg7HHg7HHg7JaZKJKJJJKJJJKJJJalLHHg7HHg7HHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HHg7JKRKJKJJJKJJJaZKHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHc7JKRK
	JKJJJaVKHHg7HHg7HHg7Gm84GGU1GGM0IIxCJKJJJKJJJKJJHHg7HX89JKNJJKJJJKJJJKJJHHg7
	HHg7HHc7JKNJJKJJHHg7HHg7HX09JKNJJKJJHHg7HHg7HHg7I5xHJKJJHHg7HHg7HHg7JKNJJKJJ
	HHg7HHg7HHg7H4lBJKJJJKJJHHg7HHg7HHg7HHc7JKJJJKJJHHg7HHg7HHg7JKNJJKJJHHg7IIxC
	JKJJJKJJHHg7HHg7HHc7JKFJJKJJHHg7HHg7HXs8JKJJJKJJHHg7HHg7HHg7HHc7IpdFJKJJHHg7
	HHg7HHg7HHg7JKRKHHg7HHk7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7JKJJ////eP9JWwAA
	AJN0Uk5TAAACRs3HRyXO87efYPiYIBobHfddER4flvFIub+zKe19HQ5ep7/A5V9k9/E68tvBvaPv
	/e7r3lZj8kTWPxUSDw4PiPqFiwhHf5fmMMtOUusB9R6H/RChfyrI4eZAVe8Dba8imfwYsPlwL9Lj
	2DVk9Pwep/7E8F07207RKXb5C5D6kR+4KM/qUzm7HA2i+4k31wZnjhH2BAAAAAFiS0dElQhgeoMA
	AAAJcEhZcwAAAEgAAABIAEbJaz4AAAFlSURBVBgZVcGxS5RxGAfw7/f3Ps/5vhrecjZFDiJUYIND
	hLuDNrnp4mRLY4Obk5vLuTXU1H/gEoIINzhEkyjIQcNRNChKoCKcdfbt+d0dRp8PkSWyiYG37P1B
	ILIRBmQKtwhGBGcGQKnn/IVgaJAgr8dJAOTPBywwyg6nSILfJ8k3AN6x5+xW5JXVyXM8nCGvEMZ5
	J13eTqhu357wMbMxhFHeSZOS2qm7XIWyLJcQlmplWYXlLl/x+Dk5j3/2pKMZJW/Nts1auNcya8+2
	PO0s+Km74567n/rCDsHFOsMLDHxRuPykBDVqu+5+iL5Dd9+tNQQCXGP2DNmJsg8CAdBfM0wD+Krw
	/reAhLByYQdF0QE6RXFgFysIRODEKsMj/FD4eC4ACUFzvm9mZ2dmtu9zQiAybjCDsk0hEH3cZIDC
	hpARAxybf0no896N0EcMcIskJK0L/2Nzu6q2m8SQYUiJT5EkDP0FXrmEl4lVk3EAAAAldEVYdGRh
	dGU6Y3JlYXRlADIwMTctMDYtMTJUMTk6MTM6MjcrMDI6MDCf0vqZAAAAJXRFWHRkYXRlOm1vZGlm
	eQAyMDE3LTA2LTEyVDE5OjEzOjI3KzAyOjAw7o9CJQAAAABJRU5ErkJggg==
}]

set shape(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAbNQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHc7HX89HHg7HHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HX09JKNJJKNJGm84HHg7HHg7HHg7HHg7HHg7I5xHJKNJJKJJJKJJGGQ0HHg7HHg7HHg7
	HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHc7H4ZAJKNJJKJJJKJJJKJJF2AzHHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HHg7JKJJJKJJJKJJJKJJIIxCHHg7HHg7HHg7HHg7HHg7HHg7HHc7IIxCJKNJJKJJJKJJ
	JKJJJKRKJaZKHYA+HHg7HHg7HHg7HHg7HHg7HHc7HXs8JKFJJKJJJKJJJKJJJKJJJKJJII9DHHg7
	HHg7HHg7HHg7IpdFJKJJJKJJJKJJHHg7HHg7HHk7JKRKJKJJJKJJJKJJJKJJII9DJKJJJaVKJaZK
	JahLHX09HHg7JKJJJKJJH4lBHHg7HHg7HHg7HHg7JKJJ////AxAETgAAAI50Uk5TAAAwn/nuXgIQ
	YMvW+qMOAzGh8+2MP++9HRhu4Pe/TggT7MEfR7Dkfx5SRxLAHuOuQSqH6YIP5pZhJQEMTsT82XAf
	Vcj7fQ3e8fbOKJDwNS+U7ZcPV1+YyM/QXR5k0uaIY0givPsEN6KRKjun9fr3uBtn17tTH3bbv/WJ
	HDn48vCzGoVEOikct5nuIkDbfQQPujkAAAABYktHRJB4Co4MAAAACXBIWXMAAABIAAAASABGyWs+
	AAABCUlEQVQoz2NgQAaMjEzMLKxs7AwMaMIcnFx93Dy8fGjC/AKCQsIiomLiEqjiklLSMrJy8gqK
	SsooylVUZdTUNTS1tIV1lBkZGWHiuup6PPoGhkbGJqaKZuYWllYQYWsbWzt7B0cnZ5d+Vzd3IQ9P
	LxWQMKO3D6svr59/QGB/f39QcEioRZhQOEg5ZwRPZFR0TGw/CMTFJyQkJiWnMKSmpXsqZmRmZef0
	Q0BuXl5+AXMfQ2GRXXFJaVl5PxKoAEmIVVZV1+TX9hMvgdMoTMvr6hsagRIYzm1qbmlta09B9mBH
	J7IHkYKkCxokHsKVoCBBCsRucCAK9/SyQQIRT7Djjig8UYs7MaAlHwAZiHyfbvGZvwAAACV0RVh0
	ZGF0ZTpjcmVhdGUAMjAxNy0wNi0xMlQxOToxODoyMiswMjowMDUKLskAAAAldEVYdGRhdGU6bW9k
	aWZ5ADIwMTctMDYtMTJUMTk6MTg6MjIrMDI6MDBEV5Z1AAAAAElFTkSuQmCC
}]

set shape(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAcVQTFRF
	AAAAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HX89HHc7HHg7HHg7HHg7HHg7HHg7HHg7Gm84
	JKNJJKNJHX09HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7GGQ0JKJJJKJJJKNJI5xHHHg7HHg7
	HHg7HHg7HHg7HHg7HHg7HHg7F2AzJKJJJKJJJKJJJKNJH4lBHHc7HHg7HHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HHg7HHg7IIxCJKJJJKJJJKJJJKJJHHg7HHg7HHg7HHg7HHg7HHg7HX09JahLJaZKJaVK
	JKJJJKJJJKJJJKNJII1CHHc7HHg7HHg7II9DJKJJJKJJJKJJJKJJJKJJJKJJJKFJHXs8HHc7HHg7
	HHg7HHg7II9DJKJJJKJJJKJJIpdFHHg7HHg7HHg7HHg7JKJJJKJJJKRKHHk7HHg7HHg7JKJJHHg7
	HX09JalLJKNJIIxCJKJJJKJJHHg7H4ZAHHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7JKJJ////Or10
	PwAAAJR0Uk5TAAACXu75nzAOo/rWy2AQHb3vP4zt86ExAx/B7BMITr/34W4YwBJHUh5/37BHASVi
	neYPgumHKj2u4x7O9vLeDX37yFUicNn8xE4MzZhhX1cPl+6ZLzXwkCj+txwpOkSF5tJrH13Qzxqz
	8PL69qc7KpGiNwQbv9t2H1O712f4uDkcifX1vB8pZB7tlPEffdtB5OARpxv7al0AAAABYktHRJaR
	aSs5AAAACXBIWXMAAABIAAAASABGyWs+AAABG0lEQVQoz2NgYGBgYmZhZWNnZGRABxycXNxTeHj5
	MKT4BQSFhEVExcQl0KQkpaRlZOXkFRSVlJFkGBkZJVVEVNXUNTS1FLR1EJp09fQNDKWNjE1Mzcwt
	uCw1rWAyOtY2tqJ29g5THZ2cXVzd3D08vSBS3qI+vn7+AYFTp04NCg4J5QxjCY9gBElFRkXHxMbF
	J0wFgcSk5JRUrjRekKYpbOkZmVnZUyEgJzcvv0DaprCoGChRUjoVCZSVV1RWuVfXYEhMra2rb2hs
	EiReAskoZMubEZZHtrS2IZzb3gF3LpIHO7uQPahj3STSDQ2SHuQg0dVj7u0TAQdiP0ogIgX7BJRg
	B0WUCiSiJqJEFBBYybNgj9pJk3EkBqzJBwAWV4J1PWTn8wAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAx
	Ny0wNi0xMlQxOToxMzoyNyswMjowMJ/S+pkAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTctMDYtMTJU
	MTk6MTM6MjcrMDI6MDDuj0IlAAAAAElFTkSuQmCC
}]

set shape(m) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAf5QTFRF
	AAAAHHg7H4hAIIxCIItBIppGHXs8////H4lBH4pBSP+HII1CII9DKLVPIZJEX/+xHX09IZNEHHg7
	HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7
	HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7F14yG3M5HHg7HHg7HHg7HHg7HHg7HHg7HHg7FEws
	JKNJJKJJJKJJJaVKHHg7HHg7HHg7HHg7HHg7HHg7HHg7JKJJJKJJJKJJJKJJJKJJHHg7HHg7HHg7
	HHg7JKJJJKJJJKJJHHg7HHg7HHg7HHg7JKJJJKJJHHg7HHg7HHg7HHg7HHc7HHg7HHg7HHg7HHg7
	KbpRJKJJKsBTHHg7HHg7HHg7HHY6JahLJKJJJadLHHY6HHg7HHg7HHg7GnA4JKRKG3E5HHg7HHg7
	F1wyJKNJGGU1HHg7HHg7GGI0GGM0HHg7HHg7G3I5G3A4HHg7HHY6JalLHHY6HHg7HHg7II5CKbxS
	HHg7HHg7G3E5HHc7HHg7HHg7HHg7HHg7HHg7JKRKLc1YHHg7HHg7HHg7HHg7HHg7HHg7JKRKHHg7
	HHg7HHg7HHg7HHg7Gm44HHc7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7HHg7JKJJHHg7Nzif
	hgAAAKh0Uk5TAAAAAAAAAAAAAAAAAAAAAAAADj6CxObw9erDgTie4dOWdmRthrHf450LZdbdeCwE
	FDFu1X7uui4CHDVCGyqu6H/rqiIheLvl+hqX6TlFvfsVsw/cRNpC7eWNBAiA/lsB+QFJwOQzGbwa
	KNTBtRUzGP2gB0ALpaMJCqS/Gxa3Nxkq12EBAUj2CwaV81PSOgIBEq/xhO+7GxuY4tpvChhLxtih
	UGfNn94/Oo+nQgAAAAFiS0dEBxZhiOsAAAAJcEhZcwAAAEgAAABIAEbJaz4AAAGDSURBVCjPY2AA
	AUYhYRFRMXEJSSlpYSFGBihgZGSUkZWTV1BUUlZRVVPXkAEKQCQ0tbR1dPX0mZhZWA0MjYyNtTQh
	EpompmbmFmyWVtbWVjZs7LZ29g6aYIO0HJ2cOVxc3dw9PNzdXF04Pb28tYCGMfoYO3ky+Pr5rwAD
	fz9froBAbRlGhiCNYD3ukNAVcBAawhMWrhHEIBwRGeXitwIJ+LlEa0QIM8TExsW7JiBLJLgmJknE
	MCSnpKalr0AB6RmZWdkMkjm5ee6oEu55+WaSDAWFRcUeqBIexSWlBQwFZeWYEhWVBQzeVdWYRtXU
	SjJUSdbVY1je0JjMELOyqRnduS2tbTFAD9q1o3uwoxPowSCNrm5e1CDh87EHBgmjTGNPbx9yIPZP
	mAgKREZGpUlSepxIwR40OUILHIeaJlOmmvOzTQNFlKWA4PQZM8ERBYpaJe1Zs83ncPLwcPLNnTdf
	Hha1oMSgkbJg4exFSYtVApcs9YElBljymTlzmY7U5OXQ5AMAnb3MttL1x/IAAAAldEVYdGRhdGU6
	Y3JlYXRlADIwMTctMDYtMTJUMTk6MTY6NTIrMDI6MDAhBhdjAAAAJXRFWHRkYXRlOm1vZGlmeQAy
	MDE3LTA2LTEyVDE5OjE2OjUyKzAyOjAwUFuv3wAAAABJRU5ErkJggg==
}]

foreach {dir pt} {t n b s l w r e} {
	set shape($pt) [image create photo -width 24 -height 24]
	::scidb::tk::image copy $shape($dir) $shape($pt)
	::scidb::tk::image recolor black $shape($pt)
}

} ;# namespace 32x32

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

foreach {dir pt} {t n b s l w r e} {
	set shape($pt) [image create photo -width 32 -height 32]
	::scidb::tk::image copy $shape($dir) $shape($pt)
	::scidb::tk::image recolor black $shape($pt)
}

} ;# namespace 32x32

namespace eval 8x16 {

set arrow(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAgAAAAQCAQAAACBg/b2AAAAAmJLR0QA/vCI/CkAAAAJb0ZGcwAA
	AAQAAAAAAEG79NgAAAAJcEhZcwAAAEgAAABIAEbJaz4AAAAJdnBBZwAAABAAAAAQAFzGrcMAAAA2
	SURBVBjTY2AgDfxnYGBC5SIL/IdQTKhcmMB/hD4mVC6qoXABRkwVjJhaGDHNYGTAAv4zEAEAjWwH
	EotT0u8AAAAldEVYdGRhdGU6Y3JlYXRlADIwMTItMDgtMjJUMTA6NTI6NDUrMDI6MDCawkqxAAAA
	JXRFWHRkYXRlOm1vZGlmeQAyMDEyLTA4LTIyVDEwOjUyOjQ1KzAyOjAw65/yDQAAAABJRU5ErkJg
	gg==
}]

set arrow(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAgAAAAQCAQAAACBg/b2AAAAAmJLR0QA/vCI/CkAAAAJb0ZGcwAA
	AAQAAAAAAEG79NgAAAAJcEhZcwAAAEgAAABIAEbJaz4AAAAJdnBBZwAAABAAAAAQAFzGrcMAAAAz
	SURBVBjTY2AgBvxH5jChCzGhq2JC18iEbhayAAPDf3QBDBWMqAKMqCoYUbUw4nQ6YQAAl1IHEp/u
	ZiMAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTItMDgtMjJUMTA6NTI6NDcrMDI6MDANXVuYAAAAJXRF
	WHRkYXRlOm1vZGlmeQAyMDEyLTA4LTIyVDEwOjUyOjQ3KzAyOjAwfADjJAAAAABJRU5ErkJggg==
}]

} ;# namespace 8x16
} ;# namespace icon
} ;# namespace twm

# vi:set ts=3 sw=3:
