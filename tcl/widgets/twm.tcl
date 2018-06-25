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
# Copyright: (C) 2010-2018 Gregor Cramer
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

# TEMPORARILY:
# After 8 seconds without any mouse motion we will dock the window,
# because it's too dangerous to keep the global grab. Change
# globalgrab:timeout to zero when this is not needed anymore.

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
	header:borderwidth			1
	frame:borderwidth				1
	float:borderwidth				1
	flathandle:size				7
	flathandle:color:dark		#0e62a8
	flathandle:color:lite		#a6ceef
	flathandle:color:gray		#74aedf
	sash:size						5
	cross:color:1					black
	cross:color:2					#24a249
	cross:active					yellow
	cross:size						24
	cross:showall					0
	highlight:color				#3778ed
	highlight:border				#0849c0
	highlight:opacity				0.3
	highlight:minsize				150
	highlight:timeout				100
	motion:busy						0
	motion:overrideredirect		1
	deiconify:timeout				50
	deiconify:force				0
	mtab:padding:selected		{4 2 4 0}
	mtab:padding:hidden			{4 0 4 2}
	mtab:padding:fixed			{4 1 4 1}
	repeat:delay					300
	repeat:interval				75
	globalgrab:timeout			8000
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

set Frozen ""


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
	variable Options

	array set opts {
		-makepane {}
		-buildpane {}
		-workarea {}
		-resizing {}
		-borderwidth 0
		-allowempty 0
		-disableclose 0
		-state "normal"
	}
	array set opts $args
	set Vars(cmd:makepane) $opts(-makepane)
	set Vars(cmd:buildpane) $opts(-buildpane)
	set Vars(cmd:workarea) $opts(-workarea)
	set Vars(cmd:resizing) $opts(-resizing)
	set Vars(allow:empty) $opts(-allowempty)
	set Vars(disable:close) $opts(-disableclose)
	set Vars(state) $opts(-state)
	set Vars(docking:recipient) ""
	set Vars(docking:position) ""
	set Vars(docking:current) ""
	set Vars(afterid:release) {}
	set Vars(cross:showall) $Options(cross:showall)

	set Vars(header:font) [font create ${path}::Vars(header:font) \
		-family [font configure $Options(header:font) -family] \
		-weight bold \
		-size $Options(header:fontsize)
	]

	ttk::frame $path -class TwmToplevel -borderwidth $opts(-borderwidth) -takefocus 0
	bind $path <Destroy> [list [namespace current]::DestroyTWM %W]

	set h [tk::toplevel $path.__highlight__ -borderwidth 0]
	pack [tk::canvas $h.c -borderwidth 0]
	$h.c create image 0 0 -anchor nw -tag image
	wm withdraw $h

	rename ::$path $path.__twm_frame__
	proc ::$path {command args} "[namespace current]::WidgetProc $path \$command {*}\$args"

	SetupTheme $path
	bind $path <<ThemeChanged>> [namespace code [list SetupTheme $path]]

	return $path
}


proc nameOfOptionsArray {} {
	return [namespace current]::Options
}


proc resetFontSize {} {
	variable Options
	variable Defaults

	set Options(header:fontsize) $Defaults(header:fontsize)
}


proc frozen {} {
	return [set [namespace current]::Frozen]
}


proc frozen? {{twm ""}} {
	variable Frozen
	return [expr {[string length $twm] == 0 ? [string length $Frozen] > 0 : $frozen eq $twm}]
}


proc SetupTheme {twm} {
	variable ${twm}::Vars

	ttk::style configure twm.TLabel -background [ttk::style lookup TNotebook.Tab -background]
	ttk::style configure twm.TNotebook -borderwidth 0
	ttk::style configure twm.TNotebook.Tab -font $Vars(header:font) -padding {2 2}
	ttk::style configure twm.TButton -padding {1 1 0 0} -relief raised
	ttk::style map twm.TButton -relief [list {!disabled pressed} sunken] 
	ttk::style layout twm.TButton \
		{ Button.border -children { Button.padding -children { Button.label } } }

#	set background [ttk::style lookup $::ttk::currentTheme -background]
#	ttk::style map twm.TNotebook.Tab -background [list active $background selected $background]

	if {[info exists Vars(theme)] && $Vars(theme) ne $::ttk::currentTheme} {
		after idle [list $twm refresh]
	}
	set Vars(theme) $::ttk::currentTheme
}


proc WidgetProc {twm command args} {
	variable Options
	variable ${twm}::Vars

	switch -- $command {
		adjacent			{ return [::scidb::tk::twm adjacent $twm {*}$args] }
		build				{ return [BuildPane $twm {*}$args] }
		changeuid		{ return [::scidb::tk::twm changeuid $twm {*}$args] }
		clone				{ return [::scidb::tk::twm clone $twm {*}$args] }
		close				{ return [Close $twm {*}$args] }
		cget				{ return [$twm.__twm_frame__ cget {*}$args] }
		configure		{ return [$twm.__twm_frame__ configure {*}$args] }
		container		{ return [::scidb::tk::twm container $twm {*}$args] }
		deiconify		{ return [Deiconify $twm {*}$args] }
		destroy			{ DestroyPane $twm {*}$args }
		dimension		{ return [::scidb::tk::twm dimension $twm {*}$args] }
		geometry			{ return [Geometry $twm {*}$args] }
		dock				{ return [::scidb::tk::twm dock $twm {*}$args] }
		exists			{ return [::scidb::tk::twm exists $twm {*}$args] }
		find				{ return [::scidb::tk::twm find $twm {*}$args] }
		floats			{ return [::scidb::tk::twm floats $twm] }
		frame				{ return [MakeFrame $twm frame {*}$args] }
		frame2			{ MakeFrame2 $twm {*}$args }
		framehdrsize	{ return [FrameHeaderSize $twm {*}$args] }
		frames			{ return [::scidb::tk::twm frames $twm {*}$args] }
		frozen?			{ return [expr {[set [namespace current]::Frozen] eq $twm}] }
		get				{ return [::scidb::tk::twm get $twm {*}$args] }
		get!				{ return [::scidb::tk::twm get! $twm {*}$args] }
		header			{ UpdateHeader $twm {*}$args }
		headerfontsize	{ return [HeaderFontSize $twm {*}$args] }
		headerframes	{ return [::scidb::tk::twm headerframes $twm] }
		hidden			{ return [::scidb::tk::twm hidden $twm {*}$args] }
		hide				{ Hide $twm {*}$args }
		id					{ return [::scidb::tk::twm id $twm {*}$args] }
		init				{ ::scidb::tk::twm init $twm {*}$args }
		inspect			{ return [::scidb::tk::twm inspect $twm flat hide stayontop {*}$args] }
		iscontainer		{ return [::scidb::tk::twm iscontainer $twm {*}$args] }
		isdocked			{ return [::scidb::tk::twm isdocked $twm {*}$args] }
		isfloat			{ return [expr {$args in [$twm floats]}] }
		isframe			{ return [string match "TwmFrame" [winfo class {*}$args]] }
		isheaderframe	{ return [string match {Twm*rame} [winfo class {*}$args]] }
		ismetachild		{ return [::scidb::tk::twm ismetachild $twm {*}$args] }
		ismetaframe		{ return [string equal "TwmMetaframe" [winfo class {*}$args]] }
		ismultiwindow	{ return [string match {*Multiwindow} [winfo class {*}$args]] }
		isnotebook		{ return [string match {*Notebook} [winfo class {*}$args]] }
		ispane			{ return [::scidb::tk::twm ispane $twm {*}$args] }
		ispanedwindow	{ return [string match {*Panedwindow} [winfo class {*}$args]] }
		isroot			{ return [string match $twm {*}$args] }
		istoplevel		{ return [expr {[::scidb::tk::twm toplevel $twm {*}$args] eq $args}] }
		leader			{ return [::scidb::tk::twm leader $twm {*}$args] }
		leaf				{ return [::scidb::tk::twm leaf $twm {*}$args] }
		leaves			{ return [::scidb::tk::twm leaves $twm {*}$args] }
		load				{ ::scidb::tk::twm load $twm {*}$args }
		metaframe		{ return [MakeFrame $twm metaframe {*}$args] }
		multiwindow		{ return [MakeMultiwindow $twm {*}$args] }
		nbhdrsize		{ return [NotebookHeaderSize $twm {*}$args] }
		neighbors		{ return [::scidb::tk::twm neighbors $twm {*}$args] }
		new				{ return [::scidb::tk::twm new $twm {*}$args] }
		notebook			{ return [MakeNotebook $twm {*}$args] }
		orientation		{ return [::scidb::tk::twm orientation $twm {*}$args] }
		pack				{ return [Pack $twm {*}$args] }
		paneconfigure	{ return [PaneConfigure $twm {*}$args] }
		panedwindow		{ return [MakePanedWindow $twm {*}$args] }
		pane				{ return [MakePane $twm {*}$args] }
		panes				{ return [::scidb::tk::twm panes $twm {*}$args] }
		parent			{ return [::scidb::tk::twm parent $twm {*}$args] }
		ready				{ event generate $twm <<TwmReady>> -data $args }
		ready?			{ return [::scidb::tk::twm ready $twm] }
		refresh			{ return [::scidb::tk::twm refresh $twm {*}$args] }
		resize			{ return [Resize $twm {*}$args] }
		resizing			{ return [Resizing $twm {*}$args] }
		sashsize			{ return $Options(sash:size) }
		select			{ return [Select $twm {*}$args] }
		selected			{ return [::scidb::tk::twm selected $twm {*}$args] }
		set				{ ::scidb::tk::twm set $twm {*}$args }
		set!				{ ::scidb::tk::twm set! $twm {*}$args }
		show				{ ::scidb::tk::twm show $twm {*}$args }
		showall			{ return [ShowAll $twm {*}$args] }
		title				{ UpdateTitle $twm {*}$args }
		togglebar		{ return [ToggleHeaders $twm {*}$args] }
		togglenotebook	{ return [::scidb::tk::twm toggle $twm {*}$args] }
		toplevel			{ return [::scidb::tk::twm toplevel $twm {*}$args] }
		uid				{ return [::scidb::tk::twm uid $twm {*}$args] }
		undock			{ return [::scidb::tk::twm undock $twm {*}$args] }
		unpack			{ return [Unpack $twm {*}$args] }
		visible			{ return [::scidb::tk::twm visible $twm {*}$args] }
		workarea			{ return [WorkArea $twm {*}$args] }

		default			{ return -code error "unknown command '$command'" }
	}

	return $twm
}


proc HeaderFontSize {twm {fontSize 0}} {
	variable ${twm}::Vars
	variable Options

	if {$fontSize <= 0} { return $Options(header:fontsize) }
	if {$fontSize == $Options(header:fontsize)} { return }

	font configure $Vars(header:font) -size [set Options(header:fontsize) $fontSize]
	$twm refresh

	foreach frame [$twm headerframes] {
		after idle [list [namespace current]::ConfigureLabelBar frame $twm $frame -1]
	}
}


proc ShowAll {twm flag} {
	variable ${twm}::Vars
	set Vars(cross:showall) $flag
}


proc DestroyPane {twm pane} {
	catch { destroy $pane }
}


proc BuildPane {twm frame id width height} {
	variable ${twm}::Vars
	variable Options

	set pane $frame
	if {![$twm ispane $pane]} { set pane [lindex [pack slaves $frame] end] }
	set bd [expr {-2*$Options(frame:borderwidth)}]
	incr width $bd
	incr height $bd
	$Vars(cmd:buildpane) $twm $pane $id $width $height
	$frame configure -background [$pane cget -background]
}


proc FrameHeaderSize {twm frame} {
	variable Options
	if {[$twm get! $frame flat 0]} {
		set size $Options(flathandle:size)
	} else {
		lassign $Options(mtab:padding:selected) l t r b
		set size  [expr {$t + $b + 2}] ;# 2 additional pixels (TODO: what's the reason?)
		incr size [font metrics [ttk::style lookup twm.TLabel -font] -linespace]
		incr size [expr {$size % 2}] ;# we have even sized headers
	}
	incr size [expr {2*$Options(header:borderwidth)}]
#	if {[set ht [winfo height $frame.__header__]] > 1 && $ht != $size} {
#		puts stderr "FrameHeaderSize: computed=$size, but measured=$ht"
#	}
	return $size
}


proc NotebookHeaderSize {twm {nb}} {
	set padding [ttk::style lookup twm.TNotebook.Tab -padding]
	if {[llength $padding] == 0} {
		puts stderr "\[ttk::style lookup TNotebook.Tab -padding\] returns empty list"
		set padding {2 2}
	}
	set size 3 ;# borderwidth=2 + one overlapping pixel
	switch [llength $padding] {
		2 { incr size [expr {2*[lindex $padding 1]}] }
		3 { incr size [lindex $padding 1] }
		4 { incr size [lindex $padding 1]; incr size [lindex $padding 3] }
	}
	incr size [font metrics [ttk::style lookup twm.TNotebook.Tab -font] -linespace]
#	if {	[string length [$nb select]]
#		&& [set ht [expr {[winfo height $nb] - [winfo height [$nb select]]}]] > 1
#		&& $ht != $size} { puts stderr "NotebookHeaderSize: computed=$size, but measured=$ht" }
	return $size
}


proc MakeMultiwindow {twm args} {
	variable ${twm}::Counter

	set w [tk::multiwindow $twm.__multiwindow__[incr Counter(multiwindow)] -takefocus 0]
	if {[llength $args] == 1} { set args [lindex $args 0] }
	foreach {name value} $args {
		catch { $w configure $name $value }
	}
	return $w
}


proc MakeNotebook {twm args} {
	variable ${twm}::Vars
	variable ${twm}::Counter

	set w [ttk::notebook $twm.__notebook__[incr Counter(notebook)] -style twm.TNotebook -takefocus 0]
	if {$Vars(state) eq "disabled"} { $w configure -state "disabled" }
	MenuBindings $twm $w $w
	if {[llength $args] == 1} { set args [lindex $args 0] }
	foreach {name value} $args {
		catch { $w configure $name $value }
	}
	return $w
}


proc MakePanedWindow {twm args} {
	variable ${twm}::Counter
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
	variable ${twm}::Vars
	variable Options

	lassign [$Vars(cmd:makepane) $twm $twm pane $id] w name priority
	$w configure -borderwidth $Options(frame:borderwidth) -relief raised
	$twm set $w name $name priority $priority
	return $w
}


proc MakeFrame {twm type {id ""}} {
	variable ${twm}::Counter

	set frame $twm.__${type}__${id}__[incr Counter($type)]
	set class Twm[string toupper $type 0 0]
	return [tk::frame $frame -class $class -borderwidth 0 -takefocus 0]
}


proc MakeFrame2 {twm frame id} {
	variable Options
	variable ${twm}::Vars

	if {[$twm isframe $frame]} {
		lassign [$Vars(cmd:makepane) $twm $frame frame $id] \
			child name priority closable undockable moveable
		$child configure -borderwidth $Options(frame:borderwidth) -relief raised
	} elseif {[$twm iscontainer $id]} {
		set child $id
		set leader [$twm leader $id]
		set name [$twm get $leader name]
		set priority [$twm get $leader priority]
		set panes [lmap w [$twm panes $child] {expr {[$twm ispane $w] ? $w : [continue]}}]
		if {[llength $panes] > 0} {
			lassign {0 0 0} closable undockable moveable
		} else {
			lassign {1 1 1} closable undockable moveable
			foreach f [$twm frames $child] {
				if {![$twm get $f move]} { set moveable 0 }
				if {![$twm get $f close]} { set closable 0 }
				if {![$twm get $f undock]} { set undockable 0 }
			}
		}
	} else {
		set child $id
		lassign {0 0 0} closable undockable moveable
		set priority [$twm get $id priority]
		set name [$twm get $id name]
	}

	if {![$twm isframe $frame] && ![$twm istoplevel $frame]} {
		raise $child $frame
	}

	set hdr [tk::frame $frame.__header__ \
		-borderwidth $Options(header:borderwidth) \
		-relief raised \
		-takefocus 0 \
	]

	if {$moveable} {
		set bg $Options(header:flex:background)
	} else {
		set bg [ttk::style lookup $::ttk::currentTheme -background]
	}
	$hdr configure -background $bg
	if {![$twm ismetachild $frame] && $Vars(state) ne "disabled"} {
		bind $hdr <Double-Button-1> [list [namespace current]::ToggleHeaders $twm $frame]
	}

	pack $child -side top -fill both -expand yes -in $frame

	if {$closable} {
		ttk::button $hdr.close \
			-style twm.TButton \
			-image $icon::12x12::close \
			-state [expr {$closable ? "normal" : "disabled"}] \
			-takefocus 0 \
			;
		MouseWheelBindings $twm $frame $hdr.close
		MenuBindings $twm $frame $hdr.close
		if {$Vars(state) eq "normal"} {
			$hdr.close configure -command [list $twm close $frame]
			tooltip $hdr.close [tr [namespace current]::mc::Close]
		}
	}
	if {$undockable} {
		ttk::button $hdr.undock \
			-style twm.TButton \
			-image $icon::12x12::undock \
			-state [expr {$undockable ? "normal" : "disabled"}] \
			-takefocus 0 \
			;
		MouseWheelBindings $twm $frame $hdr.undock
		MenuBindings $twm $frame $hdr.undock
		if {$Vars(state) eq "normal"} {
			$hdr.undock configure -command [list [namespace current]::Undock $twm $frame]
			tooltip $hdr.undock [tr [namespace current]::mc::Undock]
		}
	}

	$twm set $frame \
		name $name \
		id $id \
		move $moveable \
		close $closable \
		undock $undockable \
		priority $priority \
		;

	# ensure existence of this attribute
	$twm set! $frame flat [$twm get! $frame flat 0]

	ShowHeaderButtons $twm $frame
	HeaderBindings $twm $frame $hdr
}


proc ShowHeaderButtons {twm frame} {
	variable ${twm}::Vars

	set hdr $frame.__header__

	if {[$twm isframe $frame] && [llength [$twm panes $twm]] == 1} {
		grid forget $hdr.close
		grid forget $hdr.undock
	} else {
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
}


proc UnbindHeader {w} {
	bind $w <Configure> {#}
	bind $w <ButtonPress-1> {#}
	bind $w <Button1-Motion> {#}
	bind $w <ButtonRelease-1> {#}
}


proc HeaderBindings {twm frame w} {
	variable ${twm}::Vars

	if {$Vars(state) eq "normal"} {
		if {[$twm get $frame move]} {
			bind $w <ButtonPress-1>		[list [namespace current]::HeaderPress $twm $frame %X %Y]
			bind $w <Button1-Motion>	[list [namespace current]::HeaderMotion $twm $frame %X %Y]
			bind $w <ButtonRelease-1>	[list [namespace current]::HeaderRelease $twm $frame]
			bind $w <ButtonPress-1>		{+ break }
			bind $w <ButtonRelease-1>	{+ break }
			bind $w <Button1-Motion>	{+ break }
		}
	}
	MouseWheelBindings $twm $frame $w
	MenuBindings $twm $frame $w
}


proc MenuBindings {twm frame w} {
	variable ${twm}::Vars

	if {$Vars(state) eq "normal"} {
		bind $w <ButtonPress-3> [list event generate $twm <<TwmMenu>> -x %X -y %Y -data $frame]
	}
}


proc MouseWheelBindings {twm frame w} {
	variable ${twm}::Vars
	
	if {$Vars(state) eq "disabled"} { return }

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


proc Resize {twm pane width height minWidth minHeight maxWidth maxHeight} {
	set bd [expr {2*[$pane cget -borderwidth]}]
	if {$width > 0} { set width [expr {$width + $bd}] }
	if {$height > 0} { set height [expr {$height + $bd}] }
	if {$minWidth > 0} { set minWidth [expr {$minWidth + $bd}] }
	if {$minHeight > 0} { set minHeight [expr {$minHeight + $bd}] }
	if {$maxWidth > 0} { set maxWidth [expr {$maxWidth + $bd}] }
	if {$maxHeight > 0} { set maxHeight [expr {$maxHeight + $bd}] }

	::scidb::tk::twm resize $twm $pane $width $height $minWidth $minHeight $maxWidth $maxHeight
}


proc UpdateTitle {twm frame titlePath args} {
	if {![winfo exists $frame]} { return }
	if {[string length $titlePath] == 0} {
		set title [$twm get $frame title ""]
		if {[string length $title] == 0} { return }
	} else {
		set leader [$twm leader $frame]
		set name [$twm get $leader name]
		set title [$twm get $titlePath title $name]
		if {[info exists $title]} {
			trace add variable $title write [list [namespace current]::UpdateTitle $twm $frame ""]
		}
	}
	SetTitle $twm $frame $title
}


proc SetTitle {twm frame title} {
	$twm set $frame title $title
	if {[info exists $title]} { set title [set $title] }
	if {[winfo toplevel $frame] eq $frame} {
		wm title $frame $title
	}
}


proc ToggleHeaders {twm args} {
	foreach frame $args {
		ToggleHeader $twm $frame
	}
	after idle [list $twm refresh]
}


proc ToggleHeader {twm frame} {
	variable Options

	if {![winfo exists $frame]} { return }

	set flat [$twm get! $frame flat 0]
	$twm set! $frame flat [expr {!$flat}]
	set hdr $frame.__header__

	if {$flat} {
		pack forget $hdr.__flat__
		ShowHeaderButtons $twm $frame
		HeaderBindings $twm $frame $frame
		HeaderBindings $twm $frame $hdr
		UpdateHeader $twm $frame [$twm get $frame panes]
		bind $hdr <Double-Button-1> [list [namespace current]::ToggleHeaders $twm $frame]
	} else {
		MakeFlatHeader $twm $frame
	}
}


proc MakeFlatHeader {twm frame} {
	variable ${twm}::Vars
	variable Options

	set hdr $frame.__header__
	set decor $hdr.__flat__
	if !{[winfo exists $decor]} {
		tk::canvas $decor -height $Options(flathandle:size) -background $Options(header:flex:background)
		if {$Vars(state) ne "disabled"} {
			bind $decor <Configure> [list [namespace current]::ConfigureFlatHandle $decor %w %h]
		}
		MenuBindings $twm $frame $decor
	}
	catch { destroy $hdr.l }
	catch { destroy $hdr.r }
	destroy {*}[$twm get $frame labels {}]
	set slaves [grid slaves $hdr]
	if {[llength $slaves]} { grid forget {*}$slaves }
	foreach w [place slaves $hdr] { place forget $w }
	$twm set $frame labels {}
	pack $decor -fill x -side top -expand yes
	if {$Vars(state) ne "disabled"} {
		bind $decor <ButtonRelease-1> [list [namespace current]::ToggleHeaders $twm $frame]
		bind $decor <ButtonRelease-1> {+ break }
		bind $hdr <Double-Button-1> {#}
	}
	UnbindHeader $frame
	UnbindHeader $hdr
}


proc ConfigureFlatHandle {canv w h} {
	variable Options

	if {$w <= 1} { return }

	set n [expr {$w/2}]
	set x0 [expr {($w - 2*$n)/2}]
	set y0 1
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
	foreach w [winfo children $hdr] {
		if {[string match {*:label} $w]} { destroy $w }
	}
	$twm set $frame labels {} panes $panes

	if {[llength $panes] == 0} {
		if {$Vars(docking:current) ne $frame} {
			pack forget $frame.__header__
		}
		return
	}

	if {"$frame.__header__" ni [pack slaves $frame]} {
		pack $frame.__header__ -side top -fill x -expand no -before [lindex [pack slaves $frame] 0]
	}

	raise $hdr ;# seems to be a bug in Tk lib that a child must be raised

	set flat [expr {[llength [pack slaves $hdr]] > 0}]
	if {$flat != [$twm get! $frame flat 0]} {
		if {$flat} {
			pack forget {*}[pack slaves $hdr]
			if {![$twm ismetachild $frame] && $Vars(state) ne "disabled"} {
				bind $hdr <Double-Button-1> [list [namespace current]::ToggleHeaders $twm $frame]
			}
		} else {
			MakeFlatHeader $twm $frame
		}
	}

	if {[$twm get! $frame flat 0]} { return }
	ShowHeaderButtons $twm $frame

	set n [llength $panes]
	set parent [$twm parent $frame]
	set labels {}
	set type [expr {[$twm get $frame move] ? "flex" : "fix"}]
	set lighter [ttk::style lookup $::ttk::currentTheme -background]
	set darker [ttk::style lookup TNotebook.Tab -background]
	set confCmd [list [namespace current]::ConfigureLabelBar trace $twm $frame 0]

	for {set i 0} {$i < $n} {incr i} {
		set f [lindex $panes $i]
		set lbl $hdr.$i:label
		set name [$twm get [$twm leader $f] name]
		if {[info exists $name]} {
			trace add variable $name write $confCmd
			set var var
		} else {
			set var ""
		}
		ttk::label $lbl -style twm.TLabel -text$var $name -takefocus 0
		if {$var eq "var"} { bind $lbl <Destroy> [list trace remove variable $name write $confCmd] }
		place $lbl -x 0 -y 0
		lappend labels $lbl
		if {$f eq $frame} {
			HeaderBindings $twm $frame $lbl
			$twm set $frame mine $lbl
			set index $i
			if {[$twm get $frame move]} {
				$lbl configure \
					-relief flat \
					-padding $Options(mtab:padding:selected) \
					-background $Options(header:$type:background) \
					-foreground $Options(header:$type:foreground) \
					;
			} else {
				$lbl configure \
					-relief raised \
					-padding $Options(mtab:padding:fixed) \
					-background $Options(header:tab:background) \
					-foreground $Options(header:$type:foreground) \
					;
			}
		} else {
			if {$Vars(state) ne "disabled"} {
				bind $lbl <ButtonPress-1> [list [namespace current]::Select $twm $parent $f]
				bind $lbl <ButtonPress-1> {+ break }
				bind $lbl <Enter> [list $lbl configure -background $lighter]
				bind $lbl <Leave> [list $lbl configure -background $darker]
				MouseWheelBindings $twm $frame $lbl
				MenuBindings $twm $frame $lbl
			}
			$lbl configure \
				-relief raised \
				-padding $Options(mtab:padding:hidden) \
				-foreground $Options(header:tab:foreground) \
				-background $darker \
				;
		}
	}

	$twm set $frame maxoffset 0 labels $labels repeat 0 width 0
	after idle [list [namespace current]::ConfigureLabelBar init $twm $frame -1]
	bind $hdr <Configure> [list [namespace current]::ConfigureLabelBar hdr $twm $frame %w]
	bind $hdr <Map> [list [namespace current]::ConfigureLabelBar hdr $twm $frame -1]
	bind $frame <Configure> [list [namespace current]::ConfigureLabelBar frame $twm $frame %w]
}


proc ConfigureLabelBar {source twm frame width args} {
	variable Options

	if {![winfo exists $frame]} { return }

	set hdr $frame.__header__
	if {$hdr ni [pack slaves $frame]} { return }
	set bd [expr {2*$Options(header:borderwidth)}]
	set see [expr {$width < 0}]
	set force [expr {$width <= 0}]
	set current [expr {$width >= 0}]
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
	set showButtons [expr {!([$twm isframe $frame] && [llength [$twm panes $twm]] == 1)}]
	set haveClose [expr {$showButtons && [winfo exists $hdr.close]}]
	set haveUndock [expr {$showButtons && [winfo exists $hdr.undock]}]
	if {$haveClose} { incr width -[winfo width $hdr.close] }
	if {$haveUndock} { incr width -[winfo width $hdr.undock] }
	if {$haveClose || $haveUndock} { incr width -8 }
	if {$haveClose && $haveUndock} { incr width -3 }
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

	if {[$twm get! $frame flat 0]} { return }

	set parent [$twm parent $frame]
	set maxoffset [$twm get $frame maxoffset 0]
	set labels [$twm get $frame labels]
	set width [$twm get $frame labelbarwidth]
	set bd [expr {2*$Options(header:borderwidth)}]
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
		set offset [expr {max(0, min($maxoffset, [$twm get $parent offset 0] + $incr))}]
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
	variable ${twm}::Vars

	set arrow $frame.__header__.$dir
	if {[winfo exists $arrow]} { return }
	ttk::button $arrow \
		-style twm.TButton \
		-takefocus 0 \
		-image [makeStateSpecificIcons $icon::8x16::arrow($dir)] \
		-command [list [namespace current]::PlaceLabelBar $twm $frame $incr] \
		;
	raise $arrow
	if {$Vars(state) ne "disabled"} {
		bind $arrow <ButtonPress-1> [list [namespace current]::InvokeRepeat $twm $frame $arrow]
		MouseWheelBindings $twm $frame $arrow
		MenuBindings $twm $frame $arrow
	}
}


proc InvokeRepeat {twm frame w} {
	variable Options

	if {![winfo exists $w]} { return }
	catch { after cancel [$twm get $frame repeat] }
	$twm set $frame repeat [after $Options(repeat:delay) \
		[list [namespace current]::Repeat $twm $frame $w]]
}


proc Repeat {twm frame w} {
	variable Options

	if {![winfo exists $w]} { return }
	$w instate disabled { $w state !pressed } ;# required because of a Tk bug
	$w instate !pressed { return }
	$twm set $frame repeat [after $Options(repeat:interval) \
		[list [namespace current]::Repeat $twm $frame $w]]
	eval [$w cget -command]
}


proc HeaderPress {twm frame x y} {
	variable ${twm}::Vars
	variable Options

	catch { after cancel $Vars(afterid:release) }
	ttk::setCursor $frame.__header__ link
	set Vars(init:x) $x
	set Vars(init:y) $y
	set Vars(delta:x) [expr {$x - [winfo rootx $frame]}]
	set Vars(delta:y) [expr {$y - [winfo rooty $frame]}]
	set Vars(docking:markers) {}
	set Vars(docking:marker) {}
	set Vars(docking:arrow) ""
	set Vars(docking:arrows) {}
	set Vars(docking:container) {}
	set Vars(docking:recipient) ""
	set Vars(docking:position) ""
	set Vars(docking:outside) 0
	set Vars(docking:current) $frame
	set Vars(afterid:display) {}

	if {$Options(globalgrab:timeout) > 0} {
		set Vars(afterid:release) [after $Options(globalgrab:timeout) \
			[list [namespace current]::HeaderRelease $twm $frame 1]]
	}
	ttk::grabWindow $frame
}


proc HeaderMotion {twm frame x y} {
	if {[grab status $frame] eq "none"} { return }

	if {[catch { DoHeaderMotion $twm $frame $x $y } -> opts]} {
		puts stderr "Error in HeaderMotion"
		HeaderRelease $twm $frame
		return {*}$opts -rethrow 1 0
	}
}


proc DoHeaderMotion {twm frame x y} {
	if {![namespace exists [namespace current]::${twm}]} { return }

	variable ${twm}::Vars
	variable Options

	if {$Options(globalgrab:timeout) > 0} {
		catch { after cancel $Vars(afterid:release) }
		set Vars(afterid:release) [after $Options(globalgrab:timeout) \
			[list [namespace current]::HeaderRelease $twm $frame 1]]
	}

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

		foreach entry $Vars(docking:arrows) {
			lassign $entry w size xl yl xr yr
			set lt $w.__left__; set rt $w.__right__
			if {$xl <= $x && $x <= [expr {$xl + $size}] && $yl <= $y && $y <= [expr {$yl + $size}]} {
				if {$Vars(docking:arrow) ne $lt} {
					set Vars(docking:arrow) $lt
					if {[$twm ismultiwindow $w]} {
						$w previous
					} else { ;# [$twm isnotebook $w]
						if {[set curr [$w index [$w select]]] == 0} { set curr [llength [$w tabs]] }
						$w select [expr {$curr - 1}]
					}
					HideDockingPoints $twm
					ComputeDockingPoints $twm $frame
					return
				}
			} elseif {$Vars(docking:arrow) eq $lt} {
				set Vars(docking:arrow) ""
			}
			if {$xr <= $x && $x <= [expr {$xr + $size}] && $yr <= $y && $y <= [expr {$yr + $size}]} {
				if {$Vars(docking:arrow) ne $rt} {
					set Vars(docking:arrow) $rt
					if {[$twm ismultiwindow $w]} {
						$w next
					} else { ;# [$twm isnotebook $w]
						$w select [expr {([$w index [$w select]] + 1) % [llength [$w tabs]]}]
					}
					HideDockingPoints $twm
					ComputeDockingPoints $twm $frame
					return
				}
			} elseif {$Vars(docking:arrow) eq $rt} {
				set Vars(docking:arrow) ""
			}
		}

		WithdrawHiliteFrame $twm
		wm geometry $frame +[expr {$x - $Vars(delta:x)}]+[expr {$y - $Vars(delta:y)}]
	} elseif {abs($x - $Vars(init:x)) >= 5 || abs($y - $Vars(init:y)) >= 5} {
		variable Options
		variable Frozen

		set Frozen $twm
		set child [lindex [pack slaves $frame] end]
		if {$Options(motion:busy)} {
			::scidb::tk::busy hold $child
			::scidb::tk::busy configure $child -cursor hand2
		}
		set Vars(docking:container) [FindNotebooks $twm $frame]
		bind $frame <Button1-Motion> {#}
		bind $frame <ButtonRelease-1> {#}
		set wd [winfo width $frame]
		set ht [winfo height $frame]
		set bd [$child cget -borderwidth]
		set x [expr {$x - $Vars(delta:x)}]
		$frame configure -width $wd -height $ht
		ttk::releaseGrab $frame
		$twm undock -temporary $frame
		$child configure -borderwidth $Options(float:borderwidth)
		set bd [expr {$Options(float:borderwidth) - $bd}]
		incr wd $bd; incr ht $bd
		wm geometry $frame ${wd}x${ht}+${x}+${y}
		wm overrideredirect $frame $Options(motion:overrideredirect)
		::scidb::tk::wm dialog $frame ;# wm attributes $frame -type dnd
		wm state $frame normal
		tkwait visibility $frame
		ttk::globalGrab $frame
		bind $frame <Button1-Motion> [bind $frame.__header__ <Button1-Motion>]
		bind $frame <ButtonRelease-1> [bind $frame.__header__ <ButtonRelease-1>]
		ComputeDockingPoints $twm $frame
		ComputeArrowPoints $twm $frame
	}
}


proc HeaderRelease {twm frame {timeout 0}} {
	set [namespace current]::Frozen ""
	if {![winfo exists $frame]} { return }
	if {[grab status $frame] eq "none"} { return }

	variable Options

	# Must be at start of this function (for safety).
	ttk::releaseGrab $frame

	if {$Options(motion:busy)} { ::scidb::tk::busy forget [lindex [pack slaves $frame] end] }

	bind $frame <Button1-Motion> {#}
	bind $frame <ButtonRelease-1> {#}
	ttk::setCursor $frame.__header__ {}

	if {![namespace exists [namespace current]::${twm}]} { return }
	variable ${twm}::Vars

	HideDockingPoints $twm

	if {![info exists Vars(docking:markers)]} {
		return ;# Oops, ButtonRelease event w/o ButtonPress event, Tk is sometimes strange.
	}

	set Vars(docking:current) ""
	catch { after cancel $Vars(afterid:release) }
	catch { after cancel $Vars(afterid:display) }

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

	event generate $twm <<TwmAfter>>
}


proc FindNotebooks {twm w} {
	variable ${twm}::Vars

	set container {}
	while {![$twm isroot $w]} {
		if {[$twm ismultiwindow $w] || [$twm isnotebook $w]} {
			lappend container $w
		}
		set w [$twm parent $w]
	}
	return $container
}


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
			HideDockingPoint $twm $pane
		} elseif {[info exists Vars(docking:hover:$pane)]} {
			ShowDockingPoint $twm $frame $pane $x $y $size
		}
	}

	foreach entry $Vars(docking:arrows) {
		lassign $entry pane size xl yl xr yr
		ShowArrows $twm $frame $pane $size $xl $yl $xr $yr
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
		if {$Options(motion:overrideredirect)} { raise $tl $frame }

		if {$tl ni $Vars(docking:markers)} {
			lappend Vars(docking:markers) [list $c $w $x0 $y0 [expr {$x0 + $wd}] [expr {$y0 + $ht}]]
		}
	}
}


proc ShowArrows {twm frame w size xl yl xr yr} {
	variable Options

	foreach {dir tag} {l left r right} {
		if {[winfo exists $w.__${tag}__]} { return }
		set tl [tk::toplevel $w.__${tag}__ -width $size -height $size -borderwidth 0]
		wm withdraw $tl
		pack [set c [tk::canvas $tl.__tab__ -borderwidth 0 -width $size -height $size]]
		$c create rectangle 0 0 $size $size -width 0
		$c create image 0 0 -anchor nw -image [set icon::${size}x${size}::arrow($dir)] -tags image
		wm transient $tl $twm
		wm overrideredirect $tl true
		wm attributes $tl -topmost true
		wm geometry $tl ${size}x${size}+[set x$dir]+[set y$dir]
		wm state $tl normal
		raise $tl $twm.__highlight__
		if {$Options(motion:overrideredirect)} { raise $tl $frame }
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
			catch { after cancel $Vars(afterid:display) }
			if {$Vars(docking:position) in {n s w e}} { set w [$twm selected $w] }
			set Vars(docking:recipient) $w
			set Vars(afterid:display) [after $Options(highlight:timeout) \
				[list [namespace current]::ShowHighlightRegion $twm $frame $w $canv]]
			raise [winfo toplevel $w]
			raise $frame
			if {$Options(motion:overrideredirect)} {
				foreach entry $Vars(docking:markers) {
					catch { raise [winfo toplevel [lindex $entry 0]] }
				}
				foreach entry $Vars(docking:arrows) {
					set w [lindex $entry 0]
					catch { raise $w.__left__ }
					catch { raise $w.__right__ }
				}
			}
		}

		leave {
			if {$Vars(docking:position) in {n s e w}} { set i 2 } else { set i 1 }
			$canv itemconfigure background -fill $Options(cross:color:$i)
			$w.__m__.__docking__ itemconfigure border:$Vars(docking:position) -fill black
			catch { after cancel $Vars(afterid:display) }
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
		if {![$twm ispane $w]} { set w [lindex [pack slaves $w] end] }
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
	::scidb::tk::image border $img \
		-width 1 \
		-type dark \
		-composite overlay \
		-bordercolor $Options(highlight:border) \
		;
	$tl.c itemconfigure image -image $img
	wm geometry $tl ${wd}x${ht}+${x}+${y}
	wm overrideredirect $tl true
	wm transient $tl $w
	wm state $tl normal
	if {$Options(motion:overrideredirect)} { raise $tl $frame }
	catch { raise $tl $w.__right__ }
	catch { raise $tl $w.__left__ }
	# due to a Tk bug (?) we have to raise a second time
	if {$Options(motion:overrideredirect)} { catch { raise $tl $w.__right__ } }
	after idle [list [namespace current]::HeaderMotion $twm $frame {*}[winfo pointerxy $twm]]
}


proc HideDockingPoints {twm} {
	variable ${twm}::Vars

	foreach name [array names Vars docking:hover:*] {
		HideDockingPoint $twm [lindex [split $name :] 2]
	}
	if {[info exists Vars(docking:arrows)]} {
		foreach entry $Vars(docking:arrows) {
			set w [lindex $entry 0]
			# NOTE: do not destroy immediately, because of a Tk bug
			after idle [list catch [list destroy $w.__left__]]
			after idle [list catch [list destroy $w.__right__]]
		}
	}
}


proc HideDockingPoint {twm w} {
	foreach dir {l r t b m n s e w} {
		# NOTE: do not destroy immediately, because of a Tk bug
		after idle [list catch [list destroy $w.__${dir}__]]
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
	set Vars(docking:outside) $Vars(cross:showall)
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
	if {$wd < 5*$s && $ht < 5*$s} { set s 16 }

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


proc ComputeArrowPoints {twm frame} {
	variable ${twm}::Vars
	variable Options

	set size [expr {min(24, $Options(cross:size))}]
	set Vars(docking:arrows) {}

	foreach w $Vars(docking:container) {
		if {![winfo exists $w]} { continue }

		set x  [winfo rootx $w]
		set y  [winfo rooty $w]
		set wd [winfo width $w]

		if {[$twm isnotebook $w]} {
			set h [$twm nbhdrsize $w]
		} else { ;# if [$twm ismultiwindow $w]
			set h [$twm framehdrsize [$twm selected $w]]
		}

		set y [expr {max(0, $y + $h - $size)}]
		if {$size > $h} { set y [expr {max(0, $y + ($size - $h)/2)}] }
		set x0 [expr {$x + 1}]
		set x1 [expr {$x + $wd - $size - 2}]
		lappend Vars(docking:arrows) [list $w $size $x0 $y $x1 $y]
	}
}


proc Hide {twm toplevel} {
	if {[wm state $toplevel] eq "normal"} {
		wm state $toplevel withdraw
	}
}


proc Deiconify {twm toplevel width height x y force} {
	variable Options

	if {	[wm state $toplevel] eq "withdrawn"
		&& ($force || $Options(deiconify:force) || ![$twm get! $toplevel hide 0])} {
		after $Options(deiconify:timeout) \
			[list [namespace current]::DoDeiconify $twm $toplevel $width $height $x $y $force]
	}
}


proc DoDeiconify {twm toplevel width height x y force} {
	variable ${twm}::Vars

	set x [expr {$x + [winfo rootx $twm]}]
	set y [expr {$y + [winfo rooty $twm]}]
	incr x -4	;# magic value, this works under KDE (TODO: find the reason)
	incr y -18	;# magic value, this works under KDE (TODO: find the reason)
	if {[$twm get! $toplevel stayontop 0]} {
		wm transient $toplevel [winfo toplevel $twm]
		# NOTE: not every window manager is re-decorating the window.
		catch { wm attributes $toplevel -type dialog }
	}
	wm geometry $toplevel ${width}x${height}+${x}+${y}
	SetTitle $twm $toplevel [$twm get $toplevel name]
	wm state $toplevel normal
	if {$Vars(disable:close)} {
		set cmd {#}
	} else {
		set cmd [list [namespace current]::Dock $twm $toplevel]
	}
	wm protocol $toplevel WM_DELETE_WINDOW $cmd
}


proc Undock {twm frame} {
	variable ${twm}::Vars
	variable Options

	set x [winfo rootx $frame]
	set y [winfo rooty $frame]
	set child [lindex [pack slaves $frame] end]
	set wd [winfo width $child]
	set ht [winfo height $child]
	pack forget $frame.__header__
	$child configure -borderwidth 0
	$child configure -width $wd -height $ht
	set toplevel [$twm undock $frame]
	# ensure existence of these attributes
	$twm set! $toplevel stayontop [$twm get! $toplevel stayontop 0]
	$twm set! $toplevel hide [$twm get! $toplevel hide 0]
	if {[$twm get! $frame stayontop]} {
		wm transient $toplevel [winfo toplevel $twm]
		# NOTE: not every window manager is re-decorating the window.
		catch { wm attributes $toplevel -type dialog }
	}
	::update idletasks ;# is reducing flickering
	#wm geometry $toplevel ${wd}x${ht}+${x}+${y}
	wm geometry $toplevel +${x}+${y}
	SetTitle $twm $toplevel [$twm get $frame name]
	wm state $toplevel normal
	wm protocol $toplevel WM_DELETE_WINDOW [list [namespace current]::Dock $twm $toplevel]
	event generate $twm <<TwmUndocked>> -data $frame
}


proc Dock {twm toplevel} {
	variable ${twm}::Vars
	variable ${twm}::Update
	variable Options
	variable DirMap
	global errorInfo errorCode

	if {![winfo exists $twm]} { return }
	if {![winfo exists $toplevel]} { return }
	wm protocol $toplevel WM_DELETE_WINDOW {}

	set options {}
	set args {}
	set window ""

	if {[string length $Vars(docking:recipient)]} {
		lappend options $Vars(docking:recipient) $DirMap($Vars(docking:position))
		set args [list dock $Vars(docking:recipient)]
	}

	# NOTE: This procedure may be called via WM_DELETE_WINDOW callback, and in this
	# case the error handling of Tcl is not working (I don't know why), thus we have
	# to catch errors by hand.
	set errorInfo {}
	set frame [$twm dock $toplevel {*}$options]
	if {[llength $errorInfo]} {
		# Note that this cannot be reached if the error handling is working.
		return -code 1 -errorcode $errorCode -errorinfo $errorInfo -rethrow 1 $errorInfo
	}

	$twm set $frame width 0 ;# otherwise ConfigureLabelBar may not work as expected

	set Vars(docking:recipient) ""
	set Vars(docking:position) ""

	if {[llength [set slaves [pack slaves $frame]]] > 0} {
		set bd 0
		if {[$twm isframe $frame] || [$twm ispane $frame]} { set bd $Options(frame:borderwidth) }
		[lindex $slaves end] configure -borderwidth $bd
	}

	event generate $twm <<TwmDocked>> -data $frame
}


proc Close {twm {frame ""}} {
	destroy [expr {[string length $frame] ? $frame : $twm}]
}


proc DestroyTWM {twm} {
	::scidb::tk::twm close $twm
	after idle [list [namespace current]::DestroyNamespace $twm]
}


proc DestroyNamespace {twm} {
	if {[namespace exists $twm]} { namespace delete $twm }
}


proc Resizing {twm toplevel width height} {
	variable ${twm}::Vars

	if {[llength $Vars(cmd:resizing)]} {
		{*}$Vars(cmd:resizing) $twm $toplevel $width $height
	}
}


proc Geometry {twm toplevel width height minWidth minHeight maxWidth maxHeight expand} {
	if {$toplevel eq $twm} {
		event generate $twm <<TwmGeometry>> -data \
			[list $width $height $minWidth $minHeight $maxWidth $maxHeight $expand]
	} else {
		if {$minWidth || $minHeight} {
			set minWidth  [expr {max(1,$minWidth)}]
			set minHeight [expr {max(1,$minHeight)}]
		}
		if {$maxWidth || $maxHeight} {
			if {$maxWidth == 0} { set maxWidth [winfo screenwidth $twm] }
			if {$maxHeight == 0} { set maxHeight [winfo screenheight $twm] }
			set maxWidth  [expr {max(1,$maxWidth)}]
			set maxHeight [expr {max(1,$maxHeight)}]
		}
		if {$minWidth || $minHeight} {
			wm minsize $toplevel $minWidth $minHeight
		}
		if {$maxWidth || $maxHeight} {
			wm maxsize $toplevel $maxWidth $maxHeight
		}
		wm geometry $toplevel ${width}x${height}
		set resizeW [expr {$expand in {both x} && ($minWidth == 0 || $minWidth != $maxWidth)}]
		set resizeH [expr {$expand in {both y} && ($minHeight == 0 || $minHeight != $maxHeight)}]
		wm resizable $toplevel $resizeW $resizeH
	}
}


proc WorkArea {twm} {
	variable ${twm}::Vars
	if {[llength $Vars(cmd:workarea)]} { return [$Vars(cmd:workarea) $twm] }
	return [list [winfo screenwidth $twm] [winfo screenheight $twm]]
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
			if {[info exists $name]} {
				$parent insert $pos $child -text [set $name] {*}$options
				trace add variable $name write \
					[list [namespace current]::UpdateTab $twm $parent $child $name]
			} else {
				$parent insert $pos $child -text $name {*}$options
			}
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

			if {[$twm get! $child flat 0]} {
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
			grid rowconfigure $parent 1 -weight 1
			grid columnconfigure $parent 1 -weight 1
			if {[info exists args(-minwidth)]} {
				grid columnconfigure $parent 1 -minsize $args(-minwidth)
			}
			if {[info exists args(-minheight)]} {
				grid rowconfigure $parent 1 -minsize $args(-minheight)
			}
		}
	}
}


proc UpdateTab {twm notebook pane nameVar} {
	if {![winfo exists $child] || ![winfo exists $notebook] || $pane ni [$notebook tabs]} { return }

	set leader [$twm leader $child]
	set name [$twm get $leader name]

	if {$name ne $nameVar} {
		trace remove variable write $name [list [namespace current]::UpdateTab $twm $parent $child $name]
	} else {
		$notebook tab $pane -text [set $name]
	}
}


proc Unpack {twm parent child} {
	if {[$twm iscontainer $parent]} {
		$parent forget $child
	} else {
		pack forget $child
	}
}


proc Select {twm parent frame} {
	$parent [expr {[$twm isnotebook $parent] ? "select" : "raise"}] $frame
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

set arrow(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAQlBMVEXvSXTvSXTtR27tR27vSXDv
	S3bwUHrwUnvyaorybIzybI/ybo3ycJL0iKL1iaX5vcv5v8771d/96e796+/+8vX///8PFoAWAAAA
	BHRSTlPj5vz9oTMETgAAAERJREFUGNNjEEUDDKIsKIBYAWY0AUYgg50HRQsrn7AANzcXXIBbEGyj
	CG4BFlZeIX4uLg6YAAOQwcaJbCgT6S5FFUADAP7zCWQpV9LdAAAAAElFTkSuQmCC
}]

set arrow(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAEJQTFRF
	7Udu70l070l07Udu////70lw8nCS8FJ78myP8m6N+b/O/evv9Yml70t2/vL1+9Xf8mqK+b3L/enu
	9Iii8myM8FB6/dB/5QAAAAR0Uk5T/ebj/KuoGuoAAAABYktHRASPaNlRAAAACXBIWXMAAABIAAAA
	SABGyWs+AAAAQ0lEQVQY02NgQQMMLKwogEQBBmQBNnYgwQgT4ODk5OLm4UVo4QNbyM+JW0CAg0NQ
	SJgXxRYRUSDBhGYtM+kuhQqgAQDUqgViJrvpigAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNy0wNy0y
	MFQxMjozMToyMiswMjowMHVi/d4AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTctMDctMjBUMTI6MzE6
	MjIrMDI6MDAEP0ViAAAAAElFTkSuQmCC
}]

set arrow(hl) [image create photo -width 16 -height 16]
set arrow(hr) [image create photo -width 16 -height 16]

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

set arrow(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAATlBMVEXvSXTvSXTvSXDvS3bvTXPw
	WHzxW4LxZYnxaYz0gJ72mK72mrL2nLH2nrX6ytX6zNf7zdn7z9v82OL83uX95ev97fH+9Pb+9vj+
	+vv////1f8rWAAAAAnRSTlPi5lOyGxsAAABSSURBVCjPY5DEARgkmbCCwSDBiF8HGy9WCRYecWFs
	EpwikpISwkAgiCLBzg8PC1EUCQ4BHBJMzGCjhICAD8NybjFhHM5l5cKQYBiUwY5VAgcAAFuQEIIc
	Qv9SAAAAAElFTkSuQmCC
}]

set arrow(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdC
	AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAE5QTFRF
	70l070l0////70lw9p618VuC/N7l/vb49pyx701z+8/b/vr7/eXr9ICe/e3x+szX8WWJ+83Z8WmM
	+srV/Nji70t2/vT29pqy9piu8Fh8Bd/M5AAAAAJ0Uk5T5uIwsxoGAAAAAWJLR0QCZgt8ZAAAAAlw
	SFlzAAAASAAAAEgARslrPgAAAFFJREFUKM9jYMIBGJiYsYJBJ8GAIcHCikMHGzsHJ7oEFxsQcDMx
	8fCiSfDBg4JfAIeEoBCKhLAIEICNEsVmuZg4J1ZXSUji9yDjoAx2mAQOAADn4Qe1BnqhQQAAACV0
	RVh0ZGF0ZTpjcmVhdGUAMjAxNy0wNy0yMFQxMjozMToyMyswMjowMNMV9moAAAAldEVYdGRhdGU6
	bW9kaWZ5ADIwMTctMDctMjBUMTI6MzE6MjMrMDI6MDCiSE7WAAAAAElFTkSuQmCC
}]

set arrow(hl) [image create photo -width 24 -height 24]
set arrow(hr) [image create photo -width 24 -height 24]

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
