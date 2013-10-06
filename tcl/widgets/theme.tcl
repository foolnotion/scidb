# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval theme {

variable padding 5
variable padx 5
variable pady 5
variable padY 10
variable padX 10
variable sliderWidth 8
variable strongTtk false
variable repeatDelay 0
variable repeatInterval 0
variable useCustomStyleMenuEntries 1

variable Settings
variable Setup 1
variable ActiveBackground {}


# this should be already done in tk8.x.x/library/tk.tcl,
# but it doesn't work for any reason
switch [tk windowingsystem] {
	x11 {
		event add <<Cut>>		<Control-Key-x> <Key-F20> 
		event add <<Copy>>	<Control-Key-c> <Key-F16>
		event add <<Paste>>	<Control-Key-v> <Key-F18>
		event add <<PasteSelection>> <ButtonRelease-2>
		event add <<Undo>>	<Control-Key-z>
		event add <<Redo>>	<Control-Key-y>
	}

	win32 {
		event add <<Cut>>		<Control-Key-x> <Shift-Key-Delete>
		event add <<Copy>>	<Control-Key-c> <Control-Key-Insert>
		event add <<Paste>>	<Control-Key-v> <Shift-Key-Insert>
		event add <<PasteSelection>> <ButtonRelease-2>
		event add <<Undo>>	<Control-Key-z>
		event add <<Redo>>	<Control-Key-y>
	}

	aqua {
		event add <<Cut>>		<Command-Key-x> <Key-F2> 
		event add <<Copy>>	<Command-Key-c> <Key-F3>
		event add <<Paste>>	<Command-Key-v> <Key-F4>
		event add <<PasteSelection>> <ButtonRelease-2>
		event add <<Clear>>	<Clear>
		event add <<Undo>>	<Command-Key-z>
		event add <<Redo>>	<Command-Key-y>
	}
}

proc bindCut {w {cmd {#}}} {
	switch [tk windowingsystem] {
		x11 	{ set keys {<Control-Key-x> <Key-F20>} }
		win32	{ set keys {<Control-Key-x> <Shift-Key-Delete>} }
		aqua	{ set keys {<Control-Key-x> <Key-F2> } }
	}
	foreach key $keys {
		bind $w $key $cmd
	}
}


proc bindCopy {w {cmd {#}}} {
	switch [tk windowingsystem] {
		x11 	{ set keys {<Control-Key-c> <Key-F16>} }
		win32	{ set keys {<Control-Key-c> <Control-Key-Insert>} }
		aqua	{ set keys {<Control-Key-c> <Key-F3> } }
	}
	foreach key $keys {
		bind $w $key $cmd
	}
}


proc bindPaste {w {cmd {#}}} {
	switch [tk windowingsystem] {
		x11 	{ set keys {<Control-Key-v> <Key-F18>} }
		win32	{ set keys {<Control-Key-v> <Shift-Key-Insert>} }
		aqua	{ set keys {<Control-Key-v> <Key-F4> } }
	}
	foreach key $keys {
		bind $w $key $cmd
	}
}


proc bindUndo {w {cmd {#}}} {
	foreach key {<Control-Key-z> <Control-Key-Z>} {
		bind $w $key $cmd
	}
}


proc bindRedo {w {cmd {#}}} {
	foreach key {<Control-Key-y> <Control-Key-Y>} {
		bind $w $key $cmd
	}
}


proc bindPasteSelection {w {cmd {#}}} {
	bind $w <ButtonRelease-2> $cmd
}


event add <<ControlOn>>		<KeyPress-Control_L>    <KeyPress-Control_R>
event add <<ControlOff>>	<KeyRelease-Control_L>	<KeyRelease-Control_R>
event add <<ShiftOn>>		<KeyPress-Shift_L>		<KeyPress-Shift_R>
event add <<ShiftOff>>		<KeyRelease-Shift_L>		<KeyRelease-Shift_R>


switch $::tcl_platform(platform) {
	unix			{ event add <<Cancel>> <Control-c> <Escape> }
	windows		{ event add <<Cancel>> <Escape> }
	macintosh	{ event add <<Cancel>> <Command-period> }
}


# This is not working under older Tk versions.
#proc currentTheme {} { return ttk::style theme use] }
proc currentTheme {} { return $::ttk::currentTheme }


proc getToplevelBackground {} {
	return [set [namespace current]::Settings(tk:background)]
}


proc getColor {which} {
	switch $which {
		disabled {
			return [ttk::style lookup [currentTheme] -foreground disabled]
		}

		activebackground {
			# for any reason the correct implementation is not
			# working, so I'm using a workaround
			return #efefef

#	correct implementation
#	set activebg [ttk::style lookup [currentTheme] -activebackground]
#
#	if {[string length $activebg] == 0} {
#		variable ActiveBackground
#
#		if {[llength $ActiveBackground] == 0} {
#			set btn [tk::button .__btn_activebackground__]
#			set ActiveBackground [$btn cget -activebackground]
#			destroy $btn
#		}
#
#		set activebg $ActiveBackground
#	}
#
#	return $activebg
		}
	}

	return [ttk::style lookup [currentTheme] -$which]
}


proc setTheme {name} {
	variable Setup

	if {$name ne [currentTheme] || $Setup} {
		::ttk::setTheme $name
		SetupCurrentTheme
		set Setup 0
	}
}


proc configureCanvas {canv} {
	configureBackground $canv
	bind $canv <<ThemeChanged>> [namespace code [list configureBackground $canv]]
}


proc configurePanedWindow {win} {
	ConfigurePanedWindowBackground $win
}


proc configureSpinbox {sbox} {
	if {[winfo class $sbox] eq "Spinbox"} {
		$sbox configure -relief sunken
		ConfigureSpinboxBackground $sbox
		bind $sbox <<ThemeChanged>> [namespace code [list ConfigureSpinboxBackground $sbox]]
	}
}


proc enableScale {scale {enable true}} {
	if {$enable} {
		$scale configure \
			-foreground [::ttk::style lookup [currentTheme] -foreground] \
			-troughcolor [GetTroughColor] \
			-state normal
	} else {
		disableScale $scale
	}
}


proc configureCheckEntry {menu {index end}} {
	variable useCustomStyleMenuEntries

	set entry [$menu index $index]
	set text [$menu entrycget $entry -label]
	if {[string index $text 0] ne " "} {
		$menu entryconfigure $entry -label " $text"
	}

	if {$useCustomStyleMenuEntries} {
		set img [$menu entrycget $entry -image]
		if {[string length $img] == 0} {
			$menu entryconfigure $entry \
				-image $icon::16x16::checkNo \
				-selectimage $icon::16x16::checkYes \
				-compound left \
				-indicatoron no \
				;
		} else {
			variable Icons
			if {![info exists Icons($img)]} {
				set y [expr {(16 - [image height $img])/2}]
				set imgOff [image create photo -width 36 -height 16]
				$imgOff copy $icon::16x16::checkNo -to 0 0
				$imgOff copy $img -to 20 $y
				set imgOn [image create photo -width 36 -height 16]
				$imgOn blank
				$imgOn copy $img -to 20 $y
				$imgOn copy $icon::16x16::checkYes -to 0 0
				set Icons($img) [list $imgOff $imgOn]
			} else {
				lassign $Icons($img) imgOff imgOn
			}
			$menu entryconfigure $entry -indicatoron off -image $imgOff -selectimage $imgOn -compound left
		}
	}
}

proc configureRadioEntry {menu {index end}} {
	variable useCustomStyleMenuEntries

	set entry [$menu index $index]

	if {$useCustomStyleMenuEntries} {
		set text [$menu entrycget $entry -label]
		if {[string index $text 0] ne " "} {
			$menu entryconfigure $entry -label " $text"
		}
		set img [$menu entrycget $entry -image]
		if {[string length $img] == 0} {
			$menu entryconfigure $entry \
				-indicatoron off \
				-image $icon::16x16::radioOff \
				-selectimage $icon::16x16::radioOn \
				-compound left \
				;
		} else {
			variable Icons
			if {![info exists Icons($img)]} {
				set y [expr {(16 - [image height $img])/2}]
				set imgOff [image create photo -width 36 -height 16]
				$imgOff copy $icon::16x16::radioOff -to 0 0
				$imgOff copy $img -to 20 $y
				set imgOn [image create photo -width 36 -height 16]
				$imgOn copy $icon::16x16::radioOn -to 0 0
				$imgOn copy $img -to 20 $y
				set Icons($img) [list $imgOff $imgOn]
			} else {
				lassign $Icons($img) imgOff imgOn
			}
			$menu entryconfigure $entry -indicatoron off -image $imgOff -selectimage $imgOn -compound left
		}
	} else {
		$menu entryconfigure $entry \
			-indicatoron off \
			-image $::icon::15x15::none \
			-selectimage $icon::15x15::Dot \
			-compound left \
			;
	}
}


proc disableScale {scale} {
	$scale configure -state disabled
	ConfigureScaleBackground $scale
}


proc configureDefaultButton {but} {
	$but configure -default active
}


proc configureBackground {w} {
	$w configure -background [::ttk::style lookup [currentTheme] -background]
}


proc SetupCurrentTheme {} {
	variable strongTtk
	variable Settings

	# 1. Makes a correction of read-only state color. Read-Only does not mean disabled!
	set fbg {}
	switch "_[currentTheme]" {
		_alt		{ set fbg [list readonly white disabled [ttk::style lookup [currentTheme] -background]] }
		_clam		{ set fbg [list \
									readonly white \
									{readonly focus} [::ttk::style lookup [currentTheme] -selectbackground]] }
		_default	{ set fbg [list readonly white disabled [ttk::style lookup [currentTheme] -background]] }
	}
	if {[llength $fbg]} {
		ttk::style map TCombobox -fieldbackground $fbg
		ttk::style map TEntry -fieldbackground $fbg
		if {[info tclversion] >= "8.6"} {
			ttk::style map TSpinbox -fieldbackground $fbg
		}
	}

	# adjust padding of arrows in spinbox (the default padding is quite ugly)
	switch "_[currentTheme]" {
		_alt - _clam - _default { ttk::style configure TSpinbox -padding {2 0 2 0} }
	}

	# get current settings
	set background [::ttk::style lookup [currentTheme] -background]
	set f [tk::frame .__hopefully_unique_widget_id__[clock milliseconds]]
	set Settings(tk:background) [$f cget -background]
	destroy $f

	# 2a. Provide a left aligned button.
	ttk::style configure aligned.TButton -anchor w -width -9
	# 2b. Provide a button for icons.
	ttk::style configure icon.TButton -padding 0

	# 3. Provide a ttk::scale with keyboard focus.
	ttk::style configure active.Horizontal.TScale -troughcolor [GetActiveTroughColor]
	ttk::style configure active.Vertical.TScale -troughcolor [GetActiveTroughColor]

	# 4. Set theme options
#	option add *Frame.background $Settings(tk:background)
#	option add *Button.background $background
	option add *Spinbox.selectBackground [::ttk::style lookup [currentTheme] -selectbackground]
	option add *Spinbox.disabledBackground $background
	option add *Scale.highlightBackground $background
	option add *Scale.background $background
	option add *Scale.troughColor [GetTroughColor]
	option add *Listbox.disabledForeground [::ttk::style lookup [currentTheme] -foreground disabled]
#	option add *Listbox.selectBackground [::ttk::style lookup [currentTheme] -selectbackground]
#	option add *Listbox.selectForeground [::ttk::style lookup [currentTheme] -selectforeground]
#	option add *Panedwindow.background [GetTroughColor]

	if {$strongTtk} {
		option add *Frame.background $background
		option add *Toplevel.background $background
		option add *Dialog.background $background
		option add *Label.background $background
		option add *Canvas.background $background
		option add *Notebook.background $background
	}
}


proc ConfigureListbox {list} {
	$list configure \
		-disabledforeground [::ttk::style lookup [currentTheme] -foreground disabled]
#		-selectbackground [::ttk::style lookup [currentTheme] -selectbackground]
#		-selectforeground [::ttk::style lookup [currentTheme] -selectforeground]
}


proc ConfigurePanedWindowBackground {win} {
	$win configure -background [GetTroughColor]
}


proc ConfigureSpinboxBackground {sbox} {
	set borderwidth 1
	switch "_[currentTheme]" { _alt { set borderwidth 2 } }

	$sbox configure \
		-buttonbackground [::ttk::style lookup [currentTheme] -background] \
		-selectbackground [::ttk::style lookup [currentTheme] -selectbackground] \
		-disabledbackground [::ttk::style lookup [currentTheme] -background] \
		-borderwidth $borderwidth
}


proc ConfigureScaleBackground {scale} {
	set background [::ttk::style lookup [currentTheme] -background]

	if {[$scale cget -state] eq "disabled"} {
		$scale configure \
			-foreground [getColor disabled] \
			-highlightbackground $background \
			-background $background \
			-troughcolor $background
	} else {
		$scale configure \
			-highlightbackground $background \
			-background $background \
			-troughcolor [GetTroughColor]
	}
}


proc GetTroughColor {} {
	variable Settings

	switch "_[currentTheme]" {
		_aqua			-
		_winnative	-
		_xpnative	{
			if {![info exists Settings([currentTheme]:troughcolor)} {
				set sc [ttk::scale .__hopefully_unique_widget_id__[clock milliseconds]]
				set Settings([currentTheme]:troughcolor) [$sc cget -troughcolor]
				destroy $sc
			}

			return $Settings([currentTheme]:troughcolor)
		}
	}

	return [::ttk::style lookup [currentTheme] -troughcolor]
}


proc GetActiveTroughColor {} {
	return [::ttk::style lookup [currentTheme] -selectbackground]
}


proc ListboxHome {w} {
	switch [$w cget -selectmode] {
		single {
			$w activate 0
			$w see 0
		}
		browse {
			$w selection clear 0 end
			$w selection set 0
			$w activate 0
			$w see 0
		}
		default {
			return -code error "ListboxHome not implemented for select mode [$w cget -selectmode]"
		}
	}
}


proc ListboxEnd {w} {
	switch [$w cget -selectmode] {
		single {
			$w activate end
			$w see end
		}
		browse {
			$w selection clear 0 end
			$w selection set end
			$w activate end
			$w see end
		}
		default {
			return -code error "ListboxEnd not implemented for select mode [$w cget -selectmode]"
		}
	}
}


proc ListboxNext {w} {
	if {[$w cget -selectmode] eq "extended"} {
		return -code error "ListboxNext not implemented for select mode 'extended'"
	}
	set index [$w nearest 0]
	set active [$w index active]
	set linespace [expr {[font metrics [$w cget -font] -linespace] + 1}]
	set nrows [expr {[winfo height $w]/$linespace}]
	set last [expr {$index + $nrows - 1}]
	if {$last == $active} {
		$w yview scroll +1 pages
		$w yview scroll +1 units
	}
	$w activate @0,10000
	if {[$w cget -selectmode] eq "browse"} {
		$w selection clear 0 end
		$w selection set [$w index active]
		event generate $w <<ListboxSelect>>
	}
}


proc ListboxPrior {w} {
	if {[$w cget -selectmode] eq "extended"} {
		return -code error "ListboxPrior not implemented for select mode 'extended'"
	}
	set index [$w index active]
	if {$index eq ""} { return }
	if {[$w bbox $index] ne ""} {
		set bbox [$w bbox [expr {$index - 1}]]
		if {$bbox eq ""} {
			$w yview scroll -1 pages
			$w yview scroll -2 units
		}
	}
	$w activate @0,0
	if {[$w cget -selectmode] eq "browse"} {
		$w selection clear 0 end
		$w selection set [$w index active]
		event generate $w <<ListboxSelect>>
	}
}


proc ListboxUpDown {w dir} {
	if {[$w cget -selectmode] eq "extended"} {
		return -code error "ListboxUpDown not implemented for select mode 'extended'"
	}
	set index [$w index active]
	if {$index eq ""} { return }
	set bbox [$w bbox $index]
	if {$bbox eq ""} {
		if {$dir == -1} {
			$w activate @0,10000
		} else {
			$w activate @0,0
		}
	} else {
		$w activate [expr {$index + $dir}]
		$w see active
	}
	if {[$w cget -selectmode] eq "browse"} {
		$w selection clear 0 end
		$w selection set [$w index active]
		event generate $w <<ListboxSelect>>
	}
}


proc ScaleMove {scale delta} {
	$scale set [expr {[$scale get] + $delta}]
}


proc ScaleJump {scale x y} {
	set curr [$scale get]
	set next [$scale get $x $y]

	if {$next < $curr} {
		$scale set [$scale cget -from]
	} elseif {$next > $curr} {
		$scale set [$scale cget -to]
	}
}


proc ScaleTakeFocus {scale} {
	if {[$scale cget -takefocus] && [$scale cget -state] ne "disabled"} { focus $scale }
}


proc ComboboxSelected {w} {
	# theme "clam" has a bug, we cannot clear the selection
	if {[currentTheme] ne "clam"} { $w selection clear }
}

option add *background #efefef
option add *inactiveSelectBackground darkgrey
option add *inactiveSelectForeground white

option add *Spinbox.background white
option add *Spinbox.selectForeground white
option add *Spinbox.readonlyBackground white

option add *Entry.selectForeground black
option add *Entry.readonlyBackground white
#option add *Entry.selectBackground #678db2

option add *Listbox.background white
option add *Listbox.selectBorderWidth 0
option add *Listbox.activeStyle dotbox
option add *Listbox.selectBackground #ffdd76
option add *Listbox.selectForeground black

option add *Panedwindow.sashWidth 4
option add *Panedwindow.sashRelief raised

option add *Menu.tearOff 0
option add *Menu.activeBackground #678db2
#option add *Menu.activeBackground #437597
option add *Menu.activeForeground white
option add *Menu.activeBorderWidth 0

option add *Text.background white
#option add *Text.selectBackground #678db2

option add *Button.highlightThickness 0

option add *Canvas.highlightThickness 0

option add *TreeCtrl.highlightThickness 0

option add *TCombobox.exportSelection 0

option add *TSpinbox.wrap 0

option add *TEntry.exportSelection 0
option add *TEntry.background white
#option add *TEntry.selectBackground #678db2
#option add *TEntry.cursor xterm

#option add *Combobox.cursor xterm

bind Listbox <Home>	[namespace code { ListboxHome %W }]
bind Listbox <End>	[namespace code { ListboxEnd %W }]
bind Listbox <Next>	[namespace code { ListboxNext %W }]
bind Listbox <Prior>	[namespace code { ListboxPrior %W }]
bind Listbox <Up>		[namespace code { ListboxUpDown %W -1 }]
bind Listbox <Down>	[namespace code { ListboxUpDown %W +1 }]

bind Scale <Button-1>	+[namespace code { ScaleTakeFocus %W }]
bind Scale <FocusIn>		+[namespace code { %W configure -troughcolor [GetActiveTroughColor] }]
bind Scale <FocusOut>	+[namespace code { %W configure -troughcolor [GetTroughColor] }]

bind Spinbox <FocusIn>  {+ if {[%W cget -state] eq "normal"} { %W selection range 0 end } }
bind Spinbox <FocusOut> {+ if {![%W cget -exportselection]} { %W selection clear } }

#bind TSpinbox <FocusIn>  {+ %W instate {!readonly !disabled} { %W selection range 0 end } }
bind TSpinbox <FocusOut> {+ if {![%W cget -exportselection]} { %W selection clear } }

bindRedo Text { catch { %W edit redo } }

# TODO: probably we want to override <Ctrl-A> of text/entry/ttk::entry

bind TCombobox <<ComboboxSelected>> +[namespace code { ComboboxSelected %W }]
bind TCombobox <FocusOut> {+ after idle { if {![%W cget -exportselection]} { %W selection clear } } }
bind TCombobox <B1-Leave> { break }	;# avoid AutoScroll (bug in Tk)

bind TEntry <FocusOut> {+ if {![%W cget -exportselection]} { %W selection clear } }

# change readonly behavior of ttk::entry

bind TEntry <ButtonPress-2> {
	%W instate {!readonly !disabled} { ttk::entry::ScanMark %W %x }
}
bind TEntry <Shift-ButtonPress-1> {
	%W instate {!readonly !disabled} { ttk::entry::Shift-Press %W %x }
}
bind TEntry <Double-ButtonPress-1> {
	%W instate {!readonly !disabled} { ttk::entry::Select %W %x word }
}
bind TEntry <Triple-ButtonPress-1> {
	%W instate {!readonly !disabled} { ttk::entry::Select %W %x line }
}
bind TEntry <<TraverseIn>> {
	%W instate {!readonly !disabled} {
		%W selection range 0 end
		%W icursor end
	}
}
bind TEntry <Control-Key-slash> {
	%W instate {!readonly !disabled} {
		%W selection range 0 end
	}
}

# an entry should have a xterm cursor if in normal state
bind TEntry <Enter> {
	%W instate {!readonly !disabled} {
		%W configure -cursor xterm
	}
}

bind TEntry <Leave> {
	%W instate {!readonly !disabled} {
		%W configure -cursor {}
	}
}

bind THorzScale <ButtonPress-1>		[bind TScale <ButtonPress-1>]
bind THorzScale <B1-Motion>			[bind TScale <B1-Motion>]
bind THorzScale <ButtonRelease-1>	[bind TScale <ButtonRelease-1>]
bind THorzScale <Control-Button-1>	[namespace code { ScaleJump %W %x %y }]
bind THorzScale <Key-Right>			[namespace code { ScaleMove %W +1 }]
bind THorzScale <Key-Left>				[namespace code { ScaleMove %W -1 }]
bind THorzScale <Control-Right>		[namespace code { ScaleMove %W +10 }]
bind THorzScale <Control-Left>		[namespace code { ScaleMove %W -10 }]
bind THorzScale <Home>					{ %W set [%W cget -from] }
bind THorzScale <End>					{ %W set [%W cget -to] }
bind THorzScale <FocusIn>				{ %W configure -style active.Horizontal.TScale }
bind THorzScale <FocusOut>				{ %W configure -style Horizontal.TScale }
bind THorzScale <Button-1>				{+ focus %W }

bind TVertScale <ButtonPress-1>		[bind TScale <ButtonPress-1>]
bind TVertScale <B1-Motion>			[bind TScale <B1-Motion>]
bind TVertScale <ButtonRelease-1>	[bind TScale <ButtonRelease-1>]
bind THorzScale <Control-Button-1>	[namespace code { ScaleJump %W %x %y }]
bind TVertScale <Key-Down>				[namespace code { ScaleMove %W +1 }]
bind TVertScale <Key-Up>				[namespace code { ScaleMove %W -1 }]
bind THorzScale <Control-Down>		[namespace code { ScaleMove %W +10 }]
bind THorzScale <Control-Up>			[namespace code { ScaleMove %W -10 }]
bind THorzScale <Home>					{ %W set [%W cget -from] }
bind THorzScale <End>					{ %W set [%W cget -to] }
bind TVertScale <FocusIn>				{ %W configure -style active.Vertical.TScale }
bind TVertScale <FocusOut>				{ %W configure -style Vertical.TScale }
bind TVertScale <Button-1>				{+ focus %W }

bind Spinbox		<<ThemeChanged>> [namespace code [list ConfigureSpinboxBackground %W]]
bind Scale			<<ThemeChanged>> [namespace code [list ConfigureScaleBackground %W]]
bind Listbox		<<ThemeChanged>> [namespace code [list ConfigureListbox %W]]
bind Panedwindow	<<ThemeChanged>> [namespace code [list ConfigurePanedWindowBackground %W]]


scrollbar .__scrollbar__
set repeatDelay [.__scrollbar__ cget -repeatdelay]
set repeatInterval [.__scrollbar__ cget -repeatinterval]
destroy .__scrollbar__


namespace eval icon {
namespace eval 15x15 {

set None [image create photo -width 15 -height 15]

set Dot [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAQAAACR313BAAAANUlEQVQY02P4z4APMtBJGgaw
	SgPBFIY3QDiFAav0FDhzCjbpN3DmGzKk8Rv+H+60gQg1bBAALHvWNn3PjjEAAAAASUVORK5C
	YII=
}]

} ;# namespace 15x15

namespace eval 16x16 {

set checkYes [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAL
	EwAACxMBAJqcGAAAAAd0SU1FB90HCg81KCMxtFQAAAACYktHRAD/h4/MvwAAAY5JREFUKM9Vkbtu
	1EAUhsdnZuyZsdf2XOzZ7PqWBdssQRsEi0IikGgBiRAayhUplirPgNKk4QWQaGhpeQVooKCEJkIi
	Cu/BJApZcj6d4kiffh3pRw0vhR1gic0VlB2UouENR6VIdKQrtqA7jvxiWYBkYkZhKVCixdBlFLYq
	q9UOx3UYZnHmBNZXLC+vslbwW/HMCq8dRohvK2yarFphi+gO+UDfYi3uSYnYw5DqdVOvkB15j0/p
	mxHn207gD5wwOQs2zTk1OYITeCeu3fYvBduxF3RXT/R6VvkH8Bs+RZ2pr7MLISbsPv4Ix8HCTMRL
	+AVfvPnaSLbxPwHRvIE9+Ao/yQH8gO/kaWN0q7tu9YPqrcHP4Rv88Y7J/jhRvW5VfynQUHWqzxVZ
	wGd0OJHyhrsdWcx3nODPvZmQqstv2gIeRUU6tVM1VV1pgg26pRPEa/KYbpFhkqoUURJLNzgd5P6c
	PGHtKERZHGyQZ/QVfo2XsMTneEu87+/5myp1XZSCDGAczOic3v2PTV6R+Kzwv9J7P34PDPSEAAAA
	AElFTkSuQmCC
}]

set checkNo [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAXNSR0IArs4c6QAAAAJiS0dEAP+H
	j8y/AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3QcKDzUNaDVgEwAAAPlJREFUKM9tjjtP
	w0AQhL+9W9uJFcBREAgk0lLy/38IDQ0lElGCICh+3PmWgjwsJzPd7DerEUDw5HNlIO1XHREDQZjp
	dWUxlHI478x8r802bklK6RcPqa68a499T27u26pobH3+tGjTrRMz4WQnYVLswlX/47p5aL0i6oZG
	CnUhVGSKNzExYaRIg3lQgCRyBnj3nymAXQDiPlGoyQQ3BuwEXP5w2KUwBWc2BtQF2wOpUIvnG5IW
	IiIub+qlrcD80EjY/N4TU6/6Wb+sJ/6jbMKxndHn7WMzLV7bKGQs5dndWS52GiiBdf/GO50g6Oym
	W1AwHBp1s/siYH/45m3dmwA7UwAAAABJRU5ErkJggg==
}]

set radioOn [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAmJJREFUOMtN
	k0tuHDcQhj8W+92SRg+PFMk2JMDWJgkC5AbZZemVb+ALxFufw/cxcoEE3mUR+CFZgCxbkWamp6eb
	zaospgcQNyQL9eDPH58DHGCslwME8EA67gr0QBzPD3NNHgQEqIC9CdTA8PIlzVhcAnus437MN8C5
	8eKBbcDOzugOhPx+SZYV+NsVserodUJ3/5H8v/WgOTBsnuGACeCfwHL3kJ2oiHOYOEwNZ4ZzDkuE
	+ftrsrHmDlAB8qJgF2h2pkyC4r2gh49ZqeFOtmm9oNGQQdn+5Yi+LKlHuc4Bh1WFf/aIVddQJUL8
	1lPP5rxS49wcX57WvM33mccFkgTaTzOyZi39qwD7+0vu+iUlwCSnv5vzajBeGPxqxu9fGl4fGCuA
	eUZxNmWRj7IlTamf/0YYFF8Y7qKlVOPcQQ6oA6/GjzdLSjVcpvjpTwyaUgFeAH/zjmLVYgtDTgpW
	zvEZCKNDiuPfrKJVQ0rg8j3Zxk6vyvQGstOcthdSBtLY8udKODIonePvoLyZClUwXJ/Qf1uwNxi5
	Kl8TYJ4knM4S/tovKNsWqWu4afgDEAz9ueYoKL7o0FkkLCM/yMAtED1gIhz3A1mu3HpP6oTssGRy
	IJTTmoMg5MXa/PaiZ2rGblA+AgsPBFW8Os5nHa723G5NMN+RiCeLQLFFaFpW1z3HQXkWIhfA5fjJ
	AJRZxnMi54B64YrA1WSLbrYgTVOO28ATPKkJH0LgH6ABzD0gq8hzTmLHqXimAnU0Eu+IIdI4+D7A
	Z4645JrlBsJNAx5AVQE7WcaOGZkLhH4Nzz2w3EC0Gfw/imAF/o/T7KQAAAAASUVORK5CYII=
}]

set radioOff [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAXNSR0IArs4c6QAAAUdJREFUKM9V
	kMFu01AQRc+dZz8nNknaIEpbUFiUfgLfwZ93XzZIUGVFUVBqO/Hz87BIEco9u6s5o9EIuYOEESgJ
	TAxkplPrbu4go+YyNIxfWwbmXNIogLskR4EFvjmWVRer0OU8NMdtNRp7H0GIFSF2b5eTyQFccttv
	I2Lnk1FVF7TrVQzgcrnANS1uh1lDLQXWcfqgVOXTtlfckrfySGes8+4wP77a/5A0u3rRimBl8yXl
	UNr5QBbhbixqQkF4mAWvzMVZgn+LBLA09NdlOvddLtL+CseNfbFhmMvOKHRM4/XYk41naDdtC9j/
	E1Pfv6fyX+RAmgL3B5W/F24hC+rUH/qbfJd/8sQkR/P4Od8z2TZv3xxfyvJm+GilfU+PtO5yJGbx
	Nn2yd2qmwnJuefYfF0+7zh1O70eBmmVcehyT7/lD5yOA9BdNkrO4MeXe0gAAAABJRU5ErkJggg==
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace theme


bind Button <Map> {
	variable ::tk::Priv

	if {[info exists Priv(buttonWindow)] && $Priv(buttonWindow) eq "%W"} {
		# Fix bug in Button widget:
		# Reset this variable otherwise ::tk::ButtonEnter may
		# set the relief to sunken if the mouse hovers the
		# button during popup.
		set Priv(buttonWindow) ""
	}
}


# We fix a problem with tk::ButtonEnter; this function is not working
# well if it is called twice (this may happen under some circumstances).

rename tk::ButtonEnter tk::ButtonEnter_theme_orig_
rename tk::MbEnter     tk::MbEnter_theme_orig_
rename ttk::entry::CharSelect ttk::entry::CharSelect_theme_orig_
rename ttk::entry::WordSelect ttk::entry::WordSelect_theme_orig_
rename ttk::entry::LineSelect ttk::entry::LineSelect_theme_orig_

namespace eval tk {

proc ButtonEnter {w} {
	variable ::tk::Priv

	if {$Priv(window) ne $w} {
		ButtonEnter_theme_orig_ $w
	}
}


# we want a fixed Alt key handling
proc FindAltKeyTarget {path char} {
	switch -- [winfo class $path] {
		Button - Label - TButton - TLabel - TCheckbutton - TRadiobutton {
			if {[string equal -nocase $char [string index [$path cget -text] [$path cget -underline]]]} {
				return $path
			}
		}
		TNotebook {
			set target [FindAltKeyTarget [$path select] $char]
			if {$target ne ""} {
				return $target
			}
		}
		default {
			foreach child [concat [grid slaves $path] [pack slaves $path] [place slaves $path]] {
				set target [FindAltKeyTarget $child $char]
				if {$target ne ""} {
					return $target
				}
			}
		}
	}
	return {}
}


# we want a fixed Alt key handling
proc AltKeyInDialog {path key} {
	set target [tk::FindAltKeyTarget $path $key]
	if {[llength $target] == 0} { return }

	if {[winfo class $target] eq "TButton"} {
		set w [focus]
		focus $target
		event generate $target <Key-space> -when head
		after idle "if {[winfo exists $w]} { focus $w }"
	} else {
		event generate $target <<AltUnderlined>> -when head
	}
}


# fix tk::spinbox::AutoScan
rename ::tk::spinbox::AutoScan ::tk::spinbox::AutoScan_buggy_

proc spinbox::AutoScan {w} {
	if {[winfo exists $w]} { return [AutoScan_buggy_ $w] }
}

} ;# namespace tk


namespace eval ttk {

if {[info tclversion] < "8.6"} {

	proc spinbox {args} { ::spinbox {*}$args }


	# we don't like text selection while an arrow is pressed
	bind Spinbox <1> {+
		switch -exact [%W identify %x %y] {
			buttonup - buttondown {
				%W selection clear
			}
		}
	}

} else {

	namespace eval spinbox {

	# - ttk::spinbox takes the focus in state "readonly"; this is misplaced!
	# - we don't like text selection while an arrow is pressed
	proc Press {w x y} {
		$w instate disabled { return }
		$w instate !readonly { focus $w }
		switch -glob -- [$w identify $x $y] {
			uparrow - downarrow { $w selection clear }
		}
		switch -glob -- [$w identify $x $y] {
			*textarea	{ ttk::entry::Press $w $x }
			*rightarrow	-
			*uparrow 	{ ttk::Repeatedly event generate $w <<Increment>> }
			*leftarrow	-
			*downarrow	{ ttk::Repeatedly event generate $w <<Decrement>> }
			*spinbutton {
				if {$y * 2 >= [winfo height $w]} {
					set event <<Decrement>>
				} else {
					set event <<Increment>>
				}
				ttk::Repeatedly event generate $w $event
			}
		}
	}


	# should not select if readonly!
	proc SelectAll {w} {
		$w instate !readonly {
			$w selection range 0 end
			$w icursor end
		}
	}


	# - we have to fix value adjustment (who has tested ttk::spinbox?)
	# - we don't like text selection while an arrow is pressed
	proc Spin {w dir} {
		set nvalues [llength [set values [$w cget -values]]]
		set value [$w get]
		if {$nvalues} {
			set current [lsearch -exact $values $value]
			set index [Adjust $w [expr {$current + $dir}] 0 [expr {$nvalues - 1}]]
			$w set [lindex $values $index]
		} else {
			if {[catch {set v [expr {[scan [$w get] %f] + $dir*[$w cget -increment]}]}]} {
				set v [$w cget -from]
			}
			$w set [FormatValue $w [Adjust $w $v [$w cget -from] [$w cget -to]]]
		}
		uplevel #0 [$w cget -command]
	}

	} ;# namespace spinbox

} ;# [info tclversion] >= "8.6"


namespace eval entry {

# ttk::entry takes the focus in state "readonly"; this is misplaced!
proc Press {w x} {
    variable State

    $w icursor [ClosestGap $w $x]
    $w selection clear
    $w instate {!readonly !disabled} { focus $w }

    # Set up for future drag, double-click, or triple-click.
    set State(x) $x
    set State(selectMode) char
    set State(anchor) [$w index insert]
}


# should not select if readonly!
proc LineSelect {w from to} {
	$w instate !readonly {
		LineSelect_theme_orig_ $w $from $to
	}
}


# should not select if readonly!
proc CharSelect {w from to} {
	$w instate !readonly {
		CharSelect_theme_orig_ $w $from $to
	}
}


# should not select if readonly!
proc WordSelect {w from to} {
	$w instate !readonly {
		WordSelect_theme_orig_ $w $from $to
	}
}

} ;# namespace entry


namespace eval combobox {

# The implementation of ttk::combobox is a bit clumsy.
# The textarea, but only the textarea, should have a
# xterm cursor.

bind TCombobox <Motion>	+[namespace code { CBMotion %W %x %y }]

proc CBMotion {w x y} {
	variable Priv

	set cursor [$w cget -cursor]

	if {[$w identify $x $y] eq "textarea"} {
		if {[$w cget -state] eq "normal" && $cursor ne "xterm"} {
			$w configure -cursor xterm
		}
	} elseif {[llength $cursor]} {
		$w configure -cursor {}
	}
}

# # we want the invocation with a space key-press, but only if
# #   - it is empty
# #   - or the insertion cursor is at position 0
# #   - or the insertion cursor is at end of selection, and the
# #     selection starts at position 0
# bind TCombobox <KeyPress-space> {
# 	if {	[string length [%W get]] == 0
# 		|| [%W index insert] == 0
# 		|| ([%W index sel.first] == 0 && [%W index insert] == [%W index sel.last])} {
# 		ttk::combobox::Post %W
# 	} else {
# 		ttk::entry::Insert %W " "
# 	}
# }

if {[tk windowingsystem] eq "x11"} {

# Bug in Tk: Mouse wheel is generating a button press event.
# This shouldn't unpost the list box.
bind ComboboxPopdown <ButtonPress> {
	if {%b <= 3} { ttk::combobox::Unpost [winfo parent %W] }
}


# We like to bind the mouse wheel to the list box.
bind ComboboxListbox <ButtonPress-4> {
	%W yview scroll -1 units
	after idle { ttk::combobox::LBHover %W %x %y }
}

bind ComboboxListbox <ButtonPress-5> {
	%W yview scroll +1 units
	after idle { ttk::combobox::LBHover %W %x %y }
}

bind ComboboxListbox <Any-Key> {
	if {[string is alnum -strict "%A"]} {
		set key  [string toupper "%A"]
		set cb [ttk::combobox::LBMaster %W]
		set values [$cb cget -values]
		set i [$cb current]
		if {$i >= 0} {
			while {$i < [llength $values] && [string index [lindex $values $i] 0] eq $key} { incr i }
			set i [lsearch -glob -start $i $values ${key}*]
		}
		if {$i == -1} { set i [lsearch -glob $values ${key}*] }
		if {$i >= 0} {
			%W activate $i
			%W selection clear 0 end
			%W selection set $i
			%W see $i
		}
	}
}

bind ComboboxPopdown <ButtonPress-4> { %W.l yview scroll -1 units }
bind ComboboxPopdown <ButtonPress-5> { %W.l yview scroll +1 units }

}

} ;# namespace combobox


namespace eval theme::clam {

ttk::style theme settings clam {
	ttk::style map TCombobox -foreground [list disabled $colors(-disabledfg)]
}

} ;# namespace theme::clam


#namespace eval notebook {
#
# make keyboard traversal in notebooks comfortable
# (otherwise "-takefocus 0" have to be set in all children of each tab)
#proc ActivateTab {w tab} {
#	if {[$w index $tab] eq [$w index current]} {
#		focus $w
#	} else {
#		$w select $tab
#	}
#}
#
#} ;# namespace notebook
} ;# namespace ttk

# vi:set ts=3 sw=3:
