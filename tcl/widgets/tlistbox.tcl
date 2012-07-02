# =====================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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
package require tktreectrl 2.2
package provide tlistbox 1.0

proc tlistbox {args} {
	if {[llength $args] == 0} {
		return error -code "wrong # args: should be \"tlistbox pathName ?options?\""
	}

	if {[winfo exists [lindex $args 0]]} {
		return error -code "window name \"[lindex $args 0]\" already exists"
	}

	if {[llength $args] % 2 == 0} {
		return error -code "value for \"[lindex $args end]\" missing"
	}

	return [::tlistbox::Build {*}$args]
}

namespace eval tlistbox {

namespace import ::tcl::mathfunc::max


bind TListBoxFrame <Destroy> [namespace code { DestroyHandler %W }]

bind TListBox <Button-1>	[namespace code { Activate %W %x %y yes }]
bind TListBox <Double-1>	[namespace code { Activate %W %x %y yes yes }]
bind TListBox <Home>			[namespace code { Home %W }]
bind TListBox <End>			[namespace code { End %W }]
bind TListBox <Prior>		[namespace code { Prior %W }]
bind TListBox <Next>			[namespace code { Next %W }]
bind TListBox <Up>			[namespace code { Up %W }]
bind TListBox <Down>			[namespace code { Down %W }]
bind TListBox <Left>			[namespace code { Left %W }]
bind TListBox <Right>		[namespace code { Right %W }]
bind TListBox <Key-space>	[namespace code { SelectActive %W }]

switch [tk windowingsystem] {
	x11 {
		bind TListBox <Button-4> { %W yview scroll -1 units }
		bind TListBox <Button-5> { %W yview scroll +1 units }
	}
	aqua {
		bind TreeCtrl <MouseWheel> { %W yview scroll [expr {-(%D)}] units }
	}
	win32 {
		bind TreeCtrl <MouseWheel> { %W yview scroll [expr {-(%D/120)}] units }
	}
}

bind TListBox <<PasteSelection>>	{ break }


bind TListBox <Motion> {
	TreeCtrl::CursorCheck %W %x %y
	TreeCtrl::MotionInHeader %W %x %y
	TreeCtrl::MotionInItems %W %x %y
}
bind TListBox <Leave> {
	TreeCtrl::CursorCancel %W
	TreeCtrl::MotionInHeader %W
	TreeCtrl::MotionInItems %W
}


proc Build {w args} {
	array set opts {
		-font						TkTextFont
		-background				white
		-foreground				black
		-selectbackground		#ffdd76
		-selectforeground		black
		-disabledbackground	#ebf4f5
		-disabledforeground	black
		-disabledfont			TkTextFont
		-highlightbackground	darkblue
		-highlightforeground	white
		-highlightfont			TkTextFont
		-relief					sunken
		-focusmodel				click
		-selectmode				single
		-borderwidth			2
		-takefocus				{}
		-showfocus				1
		-setgrid					0
		-orientation			horizontal
		-usescroll				1
		-padx						2
		-pady						2
		-ipady					0
		-padding					5
		-height					-1
		-width					0
		-minwidth				0
		-maxwidth				0
		-linespace				0
		-skiponeunit			1
		-columns					1
		-state					normal
	}
	array set opts $args

	set style {}
	if {[info exists opts(-style)]} {
		set style [list -style $opts(-style)]
		unset opts(-style)
	}
	if {$opts(-focusmodel) eq "hover"} {
		set opts(-selectmode) single
	}
	if {$opts(-columns) > 1} {
		set opts(-usescroll) 0
		set opts(-skiponeunit) 0
	}

	::ttk::frame $w -class TListBoxFrame -takefocus 0 {*}$style
	if {[winfo class [winfo parent $w]] ne "ComboboxPopdown"} {
		bind $w <FocusIn> { focus [tk_focusNext %W] }
	}
	if {[llength $style]} {
		# "::ttk::frame $w -stlye <style>" does not work for any reason!
		catch { $w configure -borderwidth [::ttk::style lookup $style -borderwidth] }
		catch { $w configure -relief [::ttk::style lookup $style -relief] }
	}
	namespace eval [namespace current]::$w {}
	variable [namespace current]::${w}::Priv
	rename ::$w $w.__tlistbox_frame__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	if {$opts(-height) < 0} {
		set opts(-height) 10
		set Priv(minheight) 0
	} else {
		set Priv(minheight) $opts(-height)
	}

	set t $w.__tlistbox__

	treectrl $t                         \
		-class TListBox                  \
		-takefocus $opts(-takefocus)     \
		-highlightthickness 0            \
		-borderwidth $opts(-borderwidth) \
		-relief $opts(-relief)           \
		-showheader no                   \
		-selectmode $opts(-selectmode)   \
		-showroot no                     \
		-showlines no                    \
		-showrootlines no                \
		-xscrollincrement 1              \
		-keepuserwidth no                \
		-background $opts(-background)   \
		-foreground $opts(-foreground)   \
		-font $opts(-font)               \
		-fullstripes 1                   \
		-expensivespanwidth 1            \
		-state $opts(-state)             \
		;

	if {$opts(-width)} { $t configure -width $opts(-width) }
	if {$opts(-usescroll)} {
		$t configure -yscrollcommand [list $w.vsb set]
		::ttk::scrollbar $w.vsb -orient vertical -command [list $t yview] -takefocus 0
#		bind $w.vsb <Button-1> [namespace code [list Focus $t]]
		grid $w.vsb -row 0 -column 1 -sticky ns
	}
	if {$opts(-columns) > 1} {
		$t configure -itemwidthequal yes -orient vertical -wrap window
	}

	$t notify install <Item-enter>
	$t notify install <Item-leave>

	$t notify bind $t <Item-enter> [namespace code { VisitItem %W enter %C %I %x %y }]
	$t notify bind $t <Item-leave> [namespace code { VisitItem %W leave %C %I }]

	$t state define highlight

	if {$opts(-focusmodel) eq "hover"} {
		lappend fill $opts(-selectbackground) {active}
	}
	if {!$opts(-showfocus)} {
		set opts(-showfocus) {}
	}
	lappend fill \
		$opts(-selectbackground) {selected} \
		$opts(-highlightbackground) {highlight} \
		$opts(-disabledbackground) {!enabled} \
		;
#		$opts(-background) {enabled !highlight}
	$t element create sel.e  rect -fill $fill -open e  -showfocus $opts(-showfocus)
	$t element create sel.w  rect -fill $fill -open w  -showfocus $opts(-showfocus)
	$t element create sel.we rect -fill $fill -open we -showfocus $opts(-showfocus)
	$t element create sel    rect -fill $fill -showfocus $opts(-showfocus)

	$t element create elemImg image
	$t element create elemTxt text -font $opts(-font) -lines 1

	grid $t -row 0 -column 0 -sticky nsew -padx 0 -pady 0
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 0
	grid rowconfigure $w 0 -weight 1

	if {$opts(-linespace)} {
		set Priv(linespace) [expr {$opts(-linespace) + 2*$opts(-pady) + $opts(-ipady)}]
		$t configure -itemheight $Priv(linespace)
	} else {
		set linespace [font metrics $opts(-font) -linespace]
		set Priv(linespace) [expr {$linespace + 2*$opts(-pady) + $opts(-ipady)}]
	}
	set Priv(numcolumns) [expr {max(1,$opts(-columns))}]

	set Priv(columns) {}
	set Priv(types) {}
	foreach attr {padx pady ipady padding height width skiponeunit} {
		set Priv($attr) $opts(-$attr)
	}
	foreach attr {maxwidth minwidth} {
		set Priv($attr) [expr {max(0, $opts(-$attr) - 2*$opts(-borderwidth))}]
	}

	set Priv(colwidth) {}
	set Priv(last) -1
	set Priv(index) 0
	set Priv(selected) 0
	set Priv(resized) 0
	set Priv(charwidth) [font measure $opts(-font) "0"]
	set Priv(expand) ""
	set Priv(itembackgrounds) {}
	set Priv(background:normal) $opts(-background)
	set Priv(foreground:disabled) $opts(-disabledforeground)
	set Priv(addcol) {}

	foreach attr {disabled highlight} {
		set Priv(background:$attr) $opts(-${attr}background)
		set Priv(foreground:$attr) $opts(-${attr}foreground)
		set Priv(font:$attr) [list $opts(-${attr}font)]
	}

	if {$opts(-setgrid)} {
		wm grid [winfo toplevel $w] $opts(-width) [expr {max(1, $Priv(minheight))}] 1 $Priv(linespace)
	}

	if {[llength $opts(-takefocus)] && $opts(-takefocus)} {
		Focus $t
	}

	return $w
}


proc WidgetProc {w command args} {
	variable [namespace current]::${w}::Priv

	set t $w.__tlistbox__

	switch -- $command {
		addcol {
			if {[llength $args] == 0} {
				error "wrong # args: should be \"[namespace current] $command text|image ?options?\""
			}
			array set opts {
				-justify		left
				-expand		no
				-foreground	{}
				-font			{}
				-font2		{}
				-squeeze		no
				-steady		yes
			}
			set opts(-id) [llength $Priv(columns)]
			set opts(-background) $Priv(background:normal)
			set type [lindex $args 0]
			switch -- $type {
				text - image - combined {}
				default { error "bad element type \"$type\": must be combined, image, or text" }
			}
			lappend Priv(addcol) $args
			array set opts [lrange $args 1 end]
			set id $opts(-id)
			if {$Priv(numcolumns) > 1} {
				set opts(-expand) no
				set opts(-squeeze) no
				set opts(-steady) no
			} elseif {$opts(-expand)} {
				set Priv(expand) $id
			}
			$t column create                      \
				-tag $id                           \
				-itemjustify $opts(-justify)       \
				-expand $opts(-expand)             \
				-squeeze $opts(-squeeze)           \
				-steady $opts(-steady)             \
				-itembackground $opts(-background) \
				;
			if {[llength $opts(-font)]} {
				set charwidth [font measure $opts(-font) "0"]
			} else {
				set charwidth $Priv(charwidth)
			}
			set Priv(charwidth:$id) $charwidth
			set width 0
			if {[info exists opts(-width)]} {
				if {$type eq "image"} {
					set width $opts(-width)
				} else {
					set width [expr {$opts(-width)*$charwidth}]
				}
				set width [expr {$width + 2*$Priv(padx) + $Priv(padding)}]
				$t column configure $id -width $width
			}
			lappend Priv(colwidth) $width
			lappend Priv(columns) $id
			lappend Priv(types) $type
			set Priv(foreground:$id) $opts(-foreground)
			set Priv(font:$id) $opts(-font)
			set Priv(font2:$id) $opts(-font2)
			switch -- $type {
				image		{ set Priv(type:$id) elemImg }
				text		{ set Priv(type:$id) elemTxt }
				combined	{ set Priv(type:$id) elemCom }
			}
		}

		configcol {
			if {[llength $args] <= 1} {
				error "wrong # args: should be \"[namespace current] $command id ?options?\""
			}
			set id [lindex $args 0]
			if {![info exists Priv(type:$id)]} {
				error "unknown column id \"$id\""
			}
			array set opts [lrange $args 1 end]
			foreach key [array names opts] {
				switch -- $key {
					-width {
						set type $Priv(type:$id)
						if {$type eq "image"} {
							set width $opts(-width)
						} else {
							set width [expr {$opts(-width)*$Priv(charwidth:$id)}]
						}
						set width [expr {$width + 2*$Priv(padx) + $Priv(padding)}]
						$t column configure $id -width $width
					}
					-background {
						set background $opts(-background)
						if {[llength $background] == 0} { set background $Priv(background:normal) }
						$t column configure $id -itembackground $opts(-background)
					}
					default {
						error "cannot set column attribute \"$key\""
					}
				}
			}
		}

		clear {
			if {$Priv(last) != -1} { set Priv(last) 0 }
			set Priv(index) 0
			$t item delete 0 end
		}

		insert {
			array set opts {
				-index		-1
				-enabled		yes
				-highlight	no
				-types		{}
				-font			{}
				-font2		{}
				-foreground	{}
				-span			{}
			}
			array set opts [lrange $args 1 end]
			set args [lindex $args 0]
			set index $opts(-index)
			if {$index == -1} {
				set index $Priv(index)
				incr Priv(index)
			}
			if {$Priv(last) == -1} {
				MakeStyles $w
				set Priv(last) 0
			}
			incr index 1
			set Priv(resized) 0
			MakeItems $w [expr {$Priv(last) + 1}] $index
			set Priv(last) [expr {max($Priv(last), $index)}]
			set styles {}
			foreach type $opts(-types) {
				switch -- $type {
					image		{ set style elemImg }
					text		{ set style elemTxt }
					combined	{ set style elemCom }
					default	{ error "bad element type \"$type\": must be combined, image, or text" }
				}
				lappend styles $style
			}
			if {[llength $opts(-span)]} {
				$t item span $index {*}$opts(-span)
			}
			while {[llength $Priv(itembackgrounds)] < $index} {
				lappend Priv(itembackgrounds) $Priv(background:normal)
			}
			set Priv(enabled:$index) $opts(-enabled)
			set enabled $opts(-enabled)
			$t item enabled $index $enabled
			if {$opts(-highlight)} {
				$t item state set $index highlight
				if {[llength $opts(-foreground)] == 0} { set opts(-foreground) $Priv(foreground:highlight) }
				if {[llength $opts(-font)] == 0} { set opts(-font) $Priv(font:highlight) }
				set background $Priv(background:highlight)
			} elseif {!$opts(-enabled)} {
				if {[llength $opts(-foreground)] == 0} { set opts(-foreground) $Priv(foreground:disabled) }
				if {[llength $opts(-font)] == 0} { set opts(-font) $Priv(font:disabled) }
				set background $Priv(background:disabled)
			} else {
				set background $Priv(background:normal)
			}
			lset Priv(itembackgrounds) [expr {$index - 1}] $background
			if {!$opts(-highlight)} { $t item state set $index !highlight }
			set col -1
			foreach id $Priv(columns) {
				set item [lindex $args [incr col]]
				set style [lindex $styles $col]
				set textOpts {}
				if {[llength $style] == 0} { set style $Priv(type:$id) }
				if {[string length $Priv(foreground:$id)] && [llength $opts(-span)] == 0} {
					set fill [list $Priv(foreground:$id) enabled]
				} else {
					set fill [list $opts(-foreground) enabled]
				}
				lappend fill $Priv(foreground:disabled) !enabled
				if {[string length $Priv(font:$id)] && [llength $opts(-span)] == 0} {
					set font $Priv(font:$id)
				} else {
					set font $opts(-font)
				}
				if {[llength $opts(-font2)]} {
					lappend textOpts -font2 $opts(-font2)
				} elseif {[llength $Priv(font2:$id)]} {
					lappend textOpts -font2 $Priv(font2:$id)
				}
				switch -- $style {
					elemImg - elemTxt {
						if {[string length $item]} {
							set isImage 0
							catch { set isImage [expr {[image width $item] != -9999999}] }
							if {$isImage} {
								$t item element configure $index $id elemTxt -text ""
								$t item element configure $index $id elemImg -image $item
							} else {
								$t item element configure $index $id elemImg -image ""
								$t item element configure $index $id elemTxt \
									-text $item -fill $fill -font $font {*}$textOpts
							}
						} else {
							$t item element configure $index $id elemImg -image ""
							$t item element configure $index $id elemTxt -text ""
						}
					}
					elemCom {
						$t item element configure $index $id \
							elemImg -image [lindex $item 0] + \
							elemTxt -text [lindex $item 1] -fill $fill -font $font {*}$textOpts \
							;
					}
				}
			}
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			return [bind $t {*}$args]
		}

		resize {
			if {[llength $args] > 1 || ([llength $args] == 1 && [lindex $args 0] ne "-force")} {
				error "wrong # args: should be \"[namespace current] resize ?-force?\""
			}
			if {!$Priv(resized) || [llength $args] == 1} {
				ComputeGeometry $w

				if {[winfo exists $w.vsb]} {
					if {$Priv(height) >= $Priv(last)} {
						grid remove $w.vsb
					} else {
						grid $w.vsb
					}
				}

				set Priv(resized) 1
#				SetState $t
			}
		}

		recolor {
			$t column configure tail -itembackground $Priv(itembackgrounds)
		}

		get {
			if {[llength $args] == 0 || [llength $args] > 2} {
				error "wrong # args: should be \"[namespace current] get ?<index>? <column>\""
			}
			if {[llength $args] == 1} {
				set index $Priv(selected)
				if {$index == 0} { return "" }
				set column [lindex $args 0]
			} else {
				lassign $args index column
				if {![string is integer -strict $index]} {
					error "wrong argument: index should be integer ('$index' is given)"
				}
				if {$index < 0} { return "" }
				if {$index >= $Priv(last)} {
					error "index '$index' out of range"
				}
				incr index
			}
			if {![string is integer $column]} {
				set column [lsearch -exact $Priv(columns) $column]
				if {$column == -1} {
					error "invalid column \"[lindex $args 1]\""
				}
			}
			if {![$t item enabled $index]} { return " " }
			set result ""
			if {[lindex $Priv(types) $column] ne "text"} {
				set result [$t item image $index $column]
			}
			if {[string length $result] == 0} {
				set result [$t item text $index $column]
			}
			return $result
		}

		child {
			return $t
		}

		size {
			return $Priv(last)
		}

		see {
			if {[llength $args] > 0} {
				set index [lindex $args 0]
				if {![string is integer -strict $index]} {
					error "wrong argument: index should be integer ('$index' is given)"
				}
				incr index
			} elseif {$Priv(selected) > 1} {
				set index $Priv(selected)
			} else {
				return
			}
			if {$index <= $Priv(last)} { $t see $index }
		}

		active {
			return [expr {[$t item id active] - 1}]
		}

		pointer {
			lassign [winfo pointerxy $t] x y
			set x [expr {$x - [winfo rootx $t]}]
			set y [expr {$y - [winfo rooty $t]}]
			set id [$t identify $x $y]
			if {[llength $id] == 0} { return -1 }
			set index [lindex $id 1]
			if {![$t item enabled $index]} { return -1 }
			return [expr {$index - 1}]
		}

		activate {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] activate <index>\""
			}
			if {[$t cget -selectmode] eq "browse"} { return }
			set index [lindex $args 0]
			if {[llength $index] == 0} { return }
			if {[string is integer -strict $index]} {
				incr index
			} elseif {$index eq "none"} {
				set index 0
			} else {
				set index [$t item id $index]
			}
			if {$index <= $Priv(last) && [$t item enabled $index]} {
				$t activate $index
				$t see $index
			} else {
				$t activate 0
			}
		}

		select {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] select <index>\""
			}
			switch [$t cget -selectmode] {
				single - browse { $t selection clear }
			}
			set index [lindex $args 0]
			if {[llength $index] == 0} { return }
			if {[string is integer -strict $index]} {
				incr index
			} elseif {$index eq "none"} {
				set Priv(selected) 0
				return
			} else {
				set index [$t item id $index]
			}
			if {$index <= $Priv(last) && [$t item enabled $index]} {
				if {[$t cget -selectmode] eq "multiple" && $index in [$t selection get]} {
					$t selection clear $index $index
					set Priv(selected) 0
				} else {
					$t selection add $index
					set Priv(selected) $index
				}
				$t activate $index
				$t see $index
				event generate $w <<ListboxSelect>> -data [expr {$index - 1}]
			} else {
				set Priv(selected) 0
			}
		}

		curselection {
			return [expr {$Priv(selected) - 1}]
		}

		selection {
			set result {}
			foreach i [$t selection get] {
				if {$i > 0} { lappend result [expr {$i - 1}] }
			}
			return $result
		}

		enabled? {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] enabled? <index>\""
			}
			set index [lindex $args 0]
			if {[string is integer -strict $index]} { incr index }
			return [$t item enabled $index]
		}

		enable - disable {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <index>\""
			}
			if {![string is integer -strict [lindex $args 0]} {
				error "wrong arg: first arg should be integer"
			}
			set index [lindex $args 0]
			incr index
			if {![$t item state get $index highlight]} {
				if {$command eq "enable"} {
					$t item enabled $index 1
					lset Priv(itembackgrounds) [expr {$index - 1}] $Priv(background:normal)
				} else {
					$t item enabled $index 0
					lset Priv(itembackgrounds) [expr {$index - 1}] $Priv(background:disabled)
				}
			}
		}

		highlight {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <index> ?<boolean>?\""
			}
			if {![string is integer -strict [lindex $args 0]]} {
				error "wrong arg: first arg should be integer"
			}
			if {[llength $args] == 2 && ![string is boolean -strict [lindex $args 1]]} {
				error "wrong arg: second argument should be boolean"
			}
			set index [lindex $args 0]
			incr index
			if {[llength $args] == 0 || [lindex $args 1]} {
				$t item state set $index highlight
				lset Priv(itembackgrounds) [expr {$index - 1}] $Priv(background:$command)
			} else {
				$t item state set $index highlight
				lset Priv(itembackgrounds) [expr {$index - 1}] $Priv(background:normal)
			}
		}

		elemconfigure {
			if {[llength $args] != 4} {
				error "wrong # args: should be \"[namespace current] $command foreground <index> <column> <color>\""
			}
			lassign $args attr index id color
			if {$attr ne "foreground"} {
				error "bad attribute \"$attr\": must be foreground"
			}
			incr index
			set style $Priv(type:$id)
			switch -- $Priv(type:$id) {
				elemTxt - elemCom {
					$t item element configure $index $id elemTxt -fill $color
				}
			}
		}

		columns {
			if {[llength $args] > 1} {
				error "wrong # args: should be \"[namespace current] columns ?clear?\""
			}
			if {[llength $args] == 0} {
				return $Priv(columns)
			}
			set cmd [lindex $args 0]
			if {$cmd ne "clear"} {
				error "bad command \"$cmd\": must be clear"
			}
			catch { $t item delete 1 end }
			foreach col [$t column list] { $t column delete $col }
			foreach style [$t style names] {
				if {![string match sel* $style]} { $t style delete $style }
			}
			set Priv(last) -1
			set Priv(index) 0
			set Priv(addcol) {}
			set Priv(columns) {}
			set Priv(expand) ""
			return $t
		}

		yview {
			$t yview {*}$args
		}

		identify {
			if {[llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] identify x y\""
			}
			return [$t identify {*}$args]
		}

		configure {
			if {[llength $args] % 2 == 1} {
				return error -code "value for \"[lindex $args end]\" missing"
			}
			array set opts $args
			if {[info exists opts(-maxwidth)]} {
				set Priv(maxwidth) [expr {max(0, $opts(-maxwidth) - 2*[$t cget -borderwidth])}]
				if {$Priv(width) == 0} {
					ComputeGeometry $w
				}
				unset opts(-maxwidth)
			}
			if {[info exists opts(-minwidth)]} {
				set Priv(minwidth) [expr {max(0, $opts(-minwidth) - 2*[$t cget -borderwidth])}]
				if {$Priv(width) == 0} {
					ComputeGeometry $w
				}
				unset opts(-minwidth)
			}
			if {[info exists opts(-width)]} {
				set Priv(width) $width
#				unset opts(-width)
			}
			if {[info exists opts(-state)]} {
				set state $opts(-state)
				unset opts(-state)
				$t configure -state $state
			}
			if {[info exists opts(-height)]} {
				set Priv(height) $opts(-height)
				set Priv(minheight) $Priv(height)
				$w resize -force
				unset opts(-height)
			}
			set args [array get opts]
			if {[llength $args]} {
				$w.__tlistbox_frame__ configure {*}$args
			}
		}

		cget {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] cget <option>\""
			}
			set arg [lindex $args 0]
			switch -- $arg {
				-height		{ return $Priv(height) }
				-linespace	{ return $Priv(linespace) }
				-takefocus	{ return [$t cget $arg] }
				-cursor		{ return [$w.__tlistbox_frame__ cget $arg] }
				-state		{ return [$t cget -state] }
			}
			if {[catch {$t cget $arg} result]} {
				error "unknown option \"$arg\""
			}
			return $result
		}

		search {
			if {[llength $args] != 2 && [llength $args] != 3 && [llength $args] != 4} {
				error "wrong # args: should be \"[namespace current] $command <column> <char> ?<mapping-1>? ?<mapping-2>?\""
			}
			set mapping1 {}
			set mapping2 {}
			lassign $args column code mapping1 mapping2

			set i [FindMatch $w $column $code $mapping1]

			if {$i == -1 && [llength $mapping2]} {
				set i [FindMatch $w $column $code $mapping2]
			}

			if {$i >= 0} {
				$w select $i
				$w yview scroll 1 page
				$w yview scroll 1 unit
				$w see $i
			}
		}

		clone {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <[namespace current]>\""
			}
			set lb [lindex $args 0]
			if {![winfo exists $lb]} {
				error "wrong arg: $lb is not an existing window"
			}
			if {[winfo class $lb] ne [winfo class $w]} {
				error "wrong arg: given window $lb is not of type [winfo class $w]"
			}
			foreach name [array names [namespace current]::${lb}::Priv] {
				set Priv($name) [set [namespace current]::${lb}::Priv($name)]
			}
			set Priv(last) -1
			set Priv(index) 0
			set Priv(addcol) {}
			set Priv(columns) {}
			set Priv(expand) ""
			foreach options [set [namespace current]::${lb}::Priv(addcol)] {
				$w addcol {*}$options
			}
		}

		default {
			error "bad command \"$command\": must be activate, addcol, cget, configure, curselection, enabled?, get, insert, resize, or select"
		}
	}

	return $w
}


proc FindMatch {w column code mapping} {
	variable [namespace current]::${w}::Priv

	set n $Priv(last)
	set c [string toupper $code]
	set k [expr {$Priv(selected) - 1}]

	set i [expr {$k + 1}]
	set d [string toupper [string index [$w get $k $column] 0]]
	set succ [expr {$c eq $d || $c eq [string index [string map $mapping $d] 0]}]

	if {$i >= $n} { set i 0 }

	while {$i != $k} {
		if {[$w enabled? $i]} {
			set d [string toupper [string index [$w get $i $column] 0]]
			if {$c eq $d || $c eq [string index [string map $mapping $d] 0]} {
				if {!$succ} { return $i }
			} else {
				set succ 0
			}
		} else {
			set succ 0
		}
		if {[incr i] == $n} {
			set i 0
		}
	}

	return -1
}


proc ComputeGeometry {cb} {
	variable [namespace current]::${cb}::Priv

	if {[llength $Priv(columns)] == 0} { return }

	set t $cb.__tlistbox__

	if {[llength $Priv(expand)] == 0} {
		set Priv(expand) [lindex $Priv(columns) end]
	}
	$t column squeeze $Priv(expand)
	$t column fit $Priv(expand)

	if {$Priv(width) == 0} {
		set width 0
		foreach id $Priv(columns) {
			set w [$t column cget $id -width]
			if {[llength $w] == 0} { set w [$t column width $id] }
			incr width $w
		}
		set maxwidth $Priv(maxwidth)
		set minwidth $Priv(minwidth)
		if {"$cb.vsb" in [grid slaves $cb]} {
			if {$maxwidth} { set maxwidth [expr {$maxwidth - [winfo width $cb.vsb]}] }
			if {$minwidth} { set minwidth [expr {$minwidth - [winfo width $cb.vsb]}] }
		}
		if {$maxwidth && $maxwidth < $width} {
			set width $maxwidth
		} else {
			set width [max $width $minwidth]
		}
		set width [expr {$Priv(numcolumns)*$width}]
		$t configure -width $width
		if {$Priv(expand) eq [lindex $Priv(columns) end] && $Priv(numcolumns) == 1} {
			$t column expand $Priv(expand)
		}
	}

	set last [expr {min($Priv(last), $Priv(height))}]
	set height 0
	for {set i 1} {$i <= $last} {incr i} {
		lassign [$t item bbox $i] x0 y0 x1 y1
		incr height [expr {$y1 - $y0}]
	}
	if {$last < $Priv(minheight)} {
		set height [expr {$height + ($Priv(minheight) - $last)*$Priv(linespace)}]
	}
	$t configure -height $height
}


proc MakeStyles {w} {
	variable [namespace current]::${w}::Priv

	set t $w.__tlistbox__
	set n [llength $Priv(columns)]
	incr n -1

	for {set i 0} {$i <= $n} {incr i} {
		if {$n == 0} {
			set dir {}
		} elseif {$i == 0} {
			set dir .e
		} elseif {$i == $n} {
			set dir .w
		} else {
			set dir .we
		}
		set id [lindex $Priv(columns) $i]

		set padx $Priv(padx)
		if {$i > 0} {
			if {$Priv(numcolumns) == 1} {
				set padx [list [expr {$padx + $Priv(padding)}] $padx]
			} else {
				incr padx $Priv(padding)
				set padx [list $padx $padx]
			}
		}
		set ipady [list 0 $Priv(ipady)]
	
		switch -- $Priv(type:$id) {
			elemCom {
				set s [$t style create style$id -orient vertical]
				$t style elements $s [list sel$dir elemImg elemTxt]
				$t style layout $s elemImg -ipadx $padx -pady $Priv(pady) -expand nsew
				$t style layout $s elemTxt -ipadx $padx -expand we -ipady $ipady -squeeze x
			}

			elemTxt {
				set s [$t style create style$id]
				$t style elements $s [list sel$dir elemTxt elemImg]
				$t style layout $s elemTxt -ipadx $padx -pady $Priv(pady) -expand ns
				$t style layout $s elemImg -ipadx $padx -pady $Priv(pady) -expand nsew -detach yes
			}

			elemImg {
				set s [$t style create style$id]
				$t style elements $s [list sel$dir elemImg elemTxt]
				$t style layout $s elemTxt -ipadx $padx -pady $Priv(pady) -expand nsew -detach yes
				$t style layout $s elemImg -ipadx $padx -pady $Priv(pady) -expand nsew -ipady $ipady
			}
		}
		$t style layout $s sel$dir -detach yes -iexpand xy
	}
}


proc MakeItems {w first last} {
	variable [namespace current]::${w}::Priv

	set styles {}
	foreach id $Priv(columns) { lappend styles $id style$id  }
	set t $w.__tlistbox__

	for {set index $first} {$index <= $last} {incr index} {
		set item [$t item create]
		$t item configure $item
		$t item style set $item {*}$styles
		$t item lastchild root $item
	}
}


proc VisitItem {t mode column item {x {}} {y {}}} {
	if {[$t cget -state] eq "disabled"} { return }
	set index [expr {$item - 1}]
	set id [$t column tag names $column]
	event generate [winfo parent $t] <<ItemVisit>> -data [list $mode $id $index $column]
}


proc Activate {t x y select {isDoubleClick 0}} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	if {[$t cget -state] eq "disabled"} { return }

	set info [$t identify $x $y]
	if {[lindex $info 0] eq "item" && [$t item enabled [lindex $info 1]]} {
		SetActive $t [lindex $info 1] $select $isDoubleClick
	}

	if {[winfo exists $t]} { focus $t }
}


proc SetActive {t index select {isDoubleClick 0}} {
	if {[$t cget -state] eq "disabled"} { return }

	if {$index eq "end"} {
		set index [expr {[$t item count] - 1}]
	}

	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	if {$index < 1} { set index 1 }
	if {$index > $Priv(last)} { set index $Priv(last) }

	if {($select && [$t cget -selectmode] eq "single") || [$t cget -selectmode] eq "browse"} {
		$t selection clear
		$t selection add $index
		$t activate $index
		if {$isDoubleClick} { set data "" } else { set data [expr {$index - 1}] }
		set Priv(selected) $index
		event generate [winfo parent $t] <<ListboxSelect>> -data $data
	} elseif {$select && [$t cget -selectmode] eq "multiple"} {
		if {$index in [$t selection get]} {
			$t selection clear $index $index
			set Priv(selected) 0
		} else {
			$t selection add $index
			set Priv(selected) $index
		}
		$t activate $index
		if {$isDoubleClick} { set data "" } else { set data [expr {$index - 1}] }
		event generate [winfo parent $t] <<ListboxSelect>> -data $data
	} else {
		$t activate $index
	}

	if {[winfo exists $t]} { $t see $index }
}


proc Home {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	set cur 1
	while {$cur <= $Priv(last) && ![$t item enabled $cur]} { incr cur }
	if {$cur <= $Priv(last)} { SetActive $t $cur [expr {$Priv(numcolumns) > 1}] }
}


proc End {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	set cur [expr {[$t item count] - 1}]
	while {$cur > 0 && ![$t item enabled $cur]} { incr cur -1 }
	if {$cur > 0} { SetActive $t $cur [expr {$Priv(numcolumns) > 1}] }
}


proc Down {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	if {$Priv(numcolumns) == 1} {
		set active [$t item id active]
		if {$active <= $Priv(last)} {
			set first [$t item id {nearest 0 0}]
			set last [$t item id [list nearest 0 [winfo height $t]]]
			if {$first <= $active && $active <= $last} {
				set cur [expr {$active + 1}]
			} else {
				set cur $first
			}
			while {$cur <= $Priv(last) && ![$t item enabled $cur]} { incr cur }
			if {$cur <= $Priv(last)} { SetActive $t $cur no }
		}
	} else {
		TreeCtrl::SetActiveItem $t [TreeCtrl::UpDown $t active 1]
	}
}


proc Up {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	if {$Priv(numcolumns) == 1} {
		set active [$t item id active]
		set last [$t item id [list nearest 0 [winfo height $t]]]
		if {$active > 0} {
			set first [$t item id {nearest 0 0}]
			if {$first <= $active && $active <= $last} {
				set cur [expr {$active - 1}]
			} else {
				set cur $last
			}
			while {$cur > 0 && ![$t item enabled $cur]} { incr cur -1 }
			if {$cur > 0} { SetActive $t $cur no }
		}
	} else {
		TreeCtrl::SetActiveItem $t [TreeCtrl::UpDown $t active -1]
	}
}


proc Left {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	if {$Priv(numcolumns) > 1} {
		TreeCtrl::SetActiveItem $t [TreeCtrl::LeftRight $t active -1]
	}
}


proc Right {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	if {$Priv(numcolumns) > 1} {
		TreeCtrl::SetActiveItem $t [TreeCtrl::LeftRight $t active 1]
	}
}


proc Next {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	set active [$t item id active]
	set last [$t item id [list nearest 0 [winfo height $t]]]
	if {$active == $last} {
		if {[$t cget -selectmode] eq "browse"} {
			$t selection clear
		}
		if {$Priv(numcolumns) == 1} {
			$t yview scroll 1 pages
			if {$Priv(skiponeunit)} {
				$t yview scroll 1 unit
			}
		}
		set cur [$t item id [list nearest 0 [winfo height $t]]]
		set count 0
		while {$cur <= $Priv(last) && ![$t item enabled $cur]} {
			incr cur
			incr count
		}
		if {$cur > $Priv(last)} {
			incr cur -1
			while {$cur > $active && ![$t item enabled $cur]} {
				incr cur -1
				incr count -1
			}
		}
		if {$Priv(numcolumns) == 1} {
			$t yview scroll $count unit
		}
		SetActive $t $cur no
	} else {
		while {$last <= $Priv(last) && ![$t item enabled $last]} { incr last }
		if {$last <= $Priv(last)} { SetActive $t $last no }
	}
}


proc Prior {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	set active [$t item id active]
	set first [$t item id {nearest 0 0}]
	if {$active == $first} {
		if {[$t cget -selectmode] eq "browse"} {
			$t selection clear
		}
		if {$Priv(numcolumns) == 1} {
			$t yview scroll -1 pages
			set last [$t item id [list nearest 0 [winfo height $t]]]
			if {$first != $last} {
				$t yview scroll -1 units
			}
		}
		set cur [$t item id [list nearest 0 0]]
		set count 0
		while {$cur > 0 && ![$t item enabled $cur]} {
			incr cur -1
			incr count -1
		}
		if {$cur <= 0} {
			incr cur
			while {$cur < $active && ![$t item enabled $cur]} {
				incr cur
				incr count
			}
		}
		if {$Priv(numcolumns) == 1} {
			$t yview scroll $count unit
		}
		SetActive $t $cur no
	} else {
		while {$first > 0 && ![$t item enabled $first]} { incr first -1 }
		if {$first > 0} { SetActive $t $first no }
	}
}


proc Focus {t} {
	if {[$t cget -state] ne "disabled"} { after idle [list focus $t] }
}


proc SelectActive {t} {
	set w [winfo parent $t]
	variable [namespace current]::${w}::Priv

	set active [$t item id active]
	if {$active > 0} {
		switch [$t cget -selectmode] {
			browse - single {
				$t selection clear
				$t selection add $active
				set Priv(selected) $active
			}
			multiple {
				if {$active in [$t selection get]} {
					$t selection clear $active $active
					set Priv(selected) 0
				} else {
					$t selection add $active
					set Priv(selected) $active
				}
			}
		}
		event generate $w <<ListboxSelect>> -data [expr {$active - 1}]
	}
}


proc DestroyHandler {w} {
	if {[winfo class $w] eq "TListBoxFrame"} {
		namespace delete [namespace current]::$w
		rename $w {}
	}
}

} ;# namespace tlistbox

# vi:set ts=3 sw=3:
