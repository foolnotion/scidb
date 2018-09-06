# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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


array set Colors {
	-background				tlistbox,background
	-foreground				tlistbox,foreground
	-selectbackground		tlistbox,selectbackground
	-selectforeground		tlistbox,selectforeground
	-disabledbackground	tlistbox,disabledbackground
	-disabledforeground	tlistbox,disabledforeground
	-highlightbackground	tlistbox,highlightbackground
	-highlightforeground	tlistbox,highlightforeground
	-dropbackground		tlistbox,dropbackground
	-dropforeground		tlistbox,dropforeground
}

array set LookupColor {
	background				white
	foreground				black
	selectbackground		#ffdd76
	selectforeground		black
	disabledbackground	#ebf4f5
	disabledforeground	black
	highlightbackground	darkblue
	highlightforeground	white
	dropbackground			#ebf4f5
	dropforeground			dark
}

proc lookupColor {color} {
	variable LookupColor

	if {[info exists LookupColor($color)]} { return $LookupColor($color) }
	return $color
}


proc Build {w args} {
	variable Colors

	array set opts {
		-font				TkTextFont
		-disabledfont	TkTextFont
		-highlightfont	TkTextFont
		-relief			sunken
		-focusmodel		click
		-selectmode		single
		-borderwidth	1
		-takefocus		{}
		-showfocus		1
		-setgrid			0
		-orientation	horizontal
		-usescroll		1
		-padx				2
		-pady				2
		-ipady			0
		-padding			5
		-height			-1
		-maxheight		10
		-width			0
		-minwidth		0
		-maxwidth		0
		-linespace		0
		-skiponeunit	1
		-columns			1
		-state			normal
		-stripes			{}
		-sortable		0
		-dontsort		{}
	}
	array set opts [array get Colors]
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
		set opts(-height) $opts(-maxheight)
		set Priv(minheight) 0
	} else {
		set Priv(minheight) $opts(-height)
	}

	set t $w.__tlistbox__

	treectrl $t                                     \
		-class TListBox                              \
		-takefocus $opts(-takefocus)                 \
		-highlightthickness 0                        \
		-borderwidth $opts(-borderwidth)             \
		-relief $opts(-relief)                       \
		-showheader no                               \
		-selectmode $opts(-selectmode)               \
		-showroot no                                 \
		-showlines no                                \
		-showrootlines no                            \
		-xscrollincrement 1                          \
		-keepuserwidth no                            \
		-background [lookupColor $opts(-background)] \
		-foreground [lookupColor $opts(-foreground)] \
		-font $opts(-font)                           \
		-fullstripes 1                               \
		-expensivespanwidth 1                        \
		-state $opts(-state)                         \
		-width 0                                     \
		;

	if {$opts(-sortable)} {
		bind $t <ButtonPress-1>		+[namespace code { ScanMark %W %x %y }]
		bind $t <Button1-Motion>	+[namespace code { ScanDrag %W %x %y }]
		bind $t <ButtonRelease-1>	+[namespace code { MoveRow  %W %x %y }]

		$t state define droptarget
		set Priv(foreground:droptarget) $opts(-dropforeground)
		set Priv(dontsort) $opts(-dontsort)
	}

	if {$opts(-takefocus) == 0} {
		bind $t <ButtonPress-1> { break }
		bind $t <ButtonRelease-1> { break }
	}

	if {$opts(-width)} { $t configure -width $opts(-width) }
	if {$opts(-usescroll)} {
		$t configure -yscrollcommand [list $w.vsb set]
		::ttk::scrollbar $w.vsb -orient vertical -command [list $t yview] -takefocus 0
		grid $w.vsb -row 0 -column 1 -sticky ns
	}
	$t configure -xscrollcommand [list $w.hsb set]
	::ttk::scrollbar $w.hsb -orient horizontal -command [list $t xview] -takefocus 0
	if {$opts(-columns) > 1} {
		$t configure -itemwidthequal yes -orient vertical -wrap window
	}
	set Priv(stripes) $opts(-stripes)
	if {[llength $Priv(stripes)]} {
		set colors [list [lookupColor $Priv(stripes)] [lookupColor $opts(-background)]]
		$t column configure tail -itembackground $colors
	}

	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify install <Header-enter>
	$t notify install <Header-leave>

	$t notify bind $t <Header-enter> [namespace code { VisitHeader %W enter %C }]
	$t notify bind $t <Header-leave> [namespace code { VisitHeader %W leave %C }]
	$t notify bind $t <Item-enter> [namespace code { VisitItem %W enter %C %I }]
	$t notify bind $t <Item-leave> [namespace code { VisitItem %W leave %C %I }]

	$t state define highlight

	if {$opts(-focusmodel) eq "hover"} {
		lappend fill [lookupColor $opts(-selectbackground)] {active}
	}
	if {!$opts(-showfocus)} {
		set opts(-showfocus) {}
	}
	lappend fill \
		[lookupColor $opts(-selectbackground)] {selected} \
		[lookupColor $opts(-highlightbackground)] {highlight} \
		[lookupColor $opts(-disabledbackground)] {!enabled} \
		;
	if {$opts(-sortable)} {
		lappend fill [lookupColor $opts(-dropbackground)] {droptarget}
	}
#	[lookupColor $opts(-background)] {enabled !highlight}
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
		set Priv($attr) [expr {max(0, $opts(-$attr) - 2*$opts(-borderwidth) - 2)}]
	}

	set Priv(colwidth) {}
	set Priv(last) -1
	set Priv(index) 0
	set Priv(resized) 0
	set Priv(charwidth) [font measure $opts(-font) "0"]
	set Priv(expand) ""
	set Priv(itembackgrounds) {}
	set Priv(background:normal) [lookupColor $opts(-background)]
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
				-specialfont	{}
				-squeeze		no
				-steady		yes
				-header		""
				-headervar	""
				-minwidth	0
				-ellipsis	0
				-resize		no
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
			set Priv(ellipsis:$id) $opts(-ellipsis)
			set colors [lookupColor $opts(-background)]
			if {[llength $Priv(stripes)]} { set colors [list [lookupColor $Priv(stripes)] $colors] }
			if {[string length $opts(-headervar)]} {
				set opts(-header) [set $opts(-headervar)]
				set cmd [list [namespace current]::SetHeaderLabel $t $id]
				trace add variable $opts(-headervar) write $cmd
				bind $t <Destroy> +[list trace remove variable $opts(-headervar) write $cmd]
			}
			if {[string length $opts(-header)]} { $t configure -showheader yes }
			$t column create                \
				-tag $id                     \
				-itemjustify $opts(-justify) \
				-expand $opts(-expand)       \
				-squeeze $opts(-squeeze)     \
				-steady $opts(-steady)       \
				-itembackground $colors      \
				-text $opts(-header)         \
				-justify $opts(-justify)     \
				-borderwidth 1               \
				-button no                   \
				-resize $opts(-resize)       \
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
			if {$opts(-minwidth)} {
				if {$type eq "image"} {
					set width $opts(-minwidth)
				} else {
					set width [expr {$opts(-minwidth)*$charwidth}]
				}
				set opts(-minwidth) [expr {$width + 2*$Priv(padx) + $Priv(padding)}]
			}
			lappend Priv(colwidth) $width
			lappend Priv(columns) $id
			lappend Priv(types) $type
			set Priv(foreground:$id) $opts(-foreground)
			set Priv(font:$id) $opts(-font)
			set Priv(specialfont:$id) $opts(-specialfont)
			set Priv(minwidth:$id) $opts(-minwidth)
			switch -- $type {
				image		{ set Priv(type:$id) elemImg }
				text		{ set Priv(type:$id) elemTxt }
				combined	{ set Priv(type:$id) elemCom }
			}
		}

		fixwidth {
			if {[llength $args] > 1} {
				error "wrong # args: should be \"[namespace current] $command ?id?"
			}
			if {[llength $args] == 0} {
				foreach column $Priv(columns) {
					$t column configure $column -width [$t column width $column]
				}
			} else {
				set id [lindex $args 0]
				if {![info exists Priv(type:$id)]} {
					error "unknown column id \"$id\""
				}
				$t column configure name -width [$t column width name]
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
						$t column configure $id -itembackground [lookupColor $background]
					}
					-header {
						$t column configure $id -text $opts(-header)
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
				-index			-1
				-enabled			yes
				-highlight		no
				-types			{}
				-font				{}
				-specialfont	{}
				-foreground		{}
				-span				{}
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
			set Priv(insert:$index) [array get opts]
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
				lappend Priv(itembackgrounds) [lookupColor $Priv(background:normal)]
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
			lset Priv(itembackgrounds) [expr {$index - 1}] [lookupColor $background]
			if {!$opts(-highlight)} { $t item state set $index !highlight }
			set col -1
			foreach id $Priv(columns) {
				set item [lindex $args [incr col]]
				set style [lindex $styles $col]
				if {[llength $style] == 0} { set style $Priv(type:$id) }
				if {[string length $Priv(foreground:$id)] && [llength $opts(-span)] == 0} {
					set fill [list [lookupColor $Priv(foreground:$id)] enabled]
				} else {
					set fill [list [lookupColor $opts(-foreground)] enabled]
				}
				lappend fill [lookupColor $Priv(foreground:disabled)] !enabled
				if {[string length $Priv(font:$id)] && [llength $opts(-span)] == 0} {
					set font $Priv(font:$id)
				} else {
					set font $opts(-font)
				}
				set textOpts [list -fill $fill -font $font]
				if {[llength $opts(-specialfont)]} {
					lappend textOpts -specialfont $opts(-specialfont)
				} elseif {[llength $Priv(specialfont:$id)]} {
					lappend textOpts -specialfont $Priv(specialfont:$id)
				}
				switch -- $style {
					elemImg - elemTxt {
						if {[string length $item]} {
							set isImage 0
							# NOTE: the correct expression {$image in [image names]} is too slow!
							catch { set isImage [expr {[image width $item] != -9999999}] }
							if {$isImage} {
								$t item element configure $index $id elemTxt -text "" {*}$textOpts
								$t item element configure $index $id elemImg -image $item
							} else {
								$t item element configure $index $id elemImg -image ""
								$t item element configure $index $id elemTxt -text $item {*}$textOpts
							}
						} else {
							$t item element configure $index $id elemTxt -text "" {*}$textOpts
							$t item element configure $index $id elemImg -image ""
						}
					}
					elemCom {
						$t item element configure $index $id \
							elemImg -image [lindex $item 0] + \
							elemTxt -text [lindex $item 1] {*}$textOpts \
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
			foreach arg $args {
				if {$arg ni {-width -height -force -dontshrink -fixed}} {
					error "unknown option \"$arg\""
				}
			}
			set checkScrollbar 0
			set dontshrink [expr {"-dontshrink" in $args}]
			set fixed [expr {"-fixed" in $args}]
			if {"-height" in $args && "-width" ni $args} {
				ComputeHeight $w $dontshrink
				set checkScrollbar 1
			} elseif {"-width" in $args && "-height" ni $args} {
				# nothing to do
			} elseif {!$Priv(resized) || "-force" in $args} {
				ComputeHeight $w $dontshrink
				set checkScrollbar 1
			}
			if {$checkScrollbar} {
				if {[winfo exists $w.vsb]} {
					if {$Priv(height) >= $Priv(last)} {
						grid remove $w.vsb
					} else {
						grid $w.vsb
					}
				}
			}
			if {"-height" in $args && "-width" ni $args} {
				# nothing to do
			} elseif {"-width" in $args && "-height" ni $args} {
				ComputeWidth $w $dontshrink $fixed
				set Priv(resized) 1
			} elseif {!$Priv(resized) || "-force" in $args} {
				ComputeWidth $w $dontshrink $fixed
				set Priv(resized) 1
			}
		}

		recolor {
			$t column configure tail -itembackground $Priv(itembackgrounds)
		}

		get {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] get ?<index>? <column>\""
			}
			if {[llength $args] == 1} {
				set index [$t selection get]
				if {[llength $index] == 0} { return }
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
			if {![$t item enabled $index]} { return " " }
			if {![string is integer $column]} {
				set column [lsearch -exact $Priv(columns) $column]
				if {$column == -1} {
					error "invalid column \"[lindex $args 1]\""
				}
			}
			set result ""
			if {[lindex $Priv(types) $column] ne "text"} {
				set result [$t item image $index $column]
			}
			if {[string length $result] == 0} {
				set result [$t item text $index $column]
			}
			return $result
		}

		geticon {
			if {[llength $args] == 0} {
				set index [$t selection get]
				if {[llength $index] == 0} { return "" }
			} else {
				error "wrong # args: should be \"[namespace current] geticon\""
			}
			if {![$t item enabled $index]} { return "" }
			if {[llength $Priv(columns)] == 0} { return "" }
			foreach type $Priv(types) column $Priv(columns) {
				if {$type eq "image"} { break }
			}
			return [$t item image $index $column]
		}

		set {
			if {[llength $args] == 0 || [llength $args] > 2} {
				error "wrong # args: should be \"[namespace current] set ?<index>? <content>...\""
			}
			if {[llength $args] == 1} {
				set index [$t selection get]
				if {[llength $index] == 0} { return }
				set content [lindex $args 0]
			} else {
				set index [lindex $args 0]
				if {![string is integer -strict $index]} {
					error "wrong argument: index should be integer ('$index' is given)"
				}
				if {$index < 0} { return }
				if {$index >= $Priv(last)} {
					error "index '$index' out of range"
				}
				incr index
				set content [lindex $args 1]
			}
			set col 0
			foreach id $Priv(columns) {
				set item [lindex $content $col]
				switch -- $Priv(type:$id) {
					elemImg - elemTxt {
						if {[string length $item]} {
							set isImage 0
							# NOTE: the correct expression {$image in [image names]} is too slow!
							catch { set isImage [expr {[image width $item] != -9999999}] }
							lassign {"" ""} txt img
							if {$isImage} {
								$t item element configure $index $id elemTxt -text ""
								$t item element configure $index $id elemImg -image $item
							} else {
								$t item element configure $index $id elemImg -image ""
								$t item element configure $index $id elemTxt -text $item
							}
						} else {
							$t item element configure $index $id elemImg -image ""
							$t item element configure $index $id elemTxt -text ""
						}
					}
					elemCom {
						$t item element configure $index $id \
							elemImg -image [lindex $item 0] + \
							elemTxt -text [lindex $item 1]
							;
					}
				}
			}
			return
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
				if {$index eq "end"} {
					set index $Priv(last)
				} elseif {![string is integer -strict $index]} {
					error "wrong argument: index should be integer ('$index' is given)"
				} else {
					incr index
				}
			} elseif {[$t selection get] > 0} {
				set index [$t selection get]
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
			set index [lindex $args 0]
			if {[llength $index] == 0} { return }
			if {[string is integer -strict $index]} {
				incr index
			} elseif {$index eq "none"} {
				$t selection clear
				return
			} else {
				set idx [$t item id $index]
				if {[llength $idx] == 0} {
					error "bad index description \"$index\""
				}
				set index $idx
			}
			if {[$t selection get] ne $index} {
				switch [$t cget -selectmode] {
					single - browse { $t selection clear }
				}
				if {$index <= $Priv(last) && [$t item enabled $index]} {
					if {[$t cget -selectmode] eq "multiple" && $index in [$t selection get]} {
						$t selection clear $index $index
					} else {
						$t selection add $index
					}
					$t activate $index
					$t see $index
					event generate $w <<ListboxSelect>> -data [expr {$index - 1}]
				} else {
					$t selection clear
				}
			}
			return $w
		}

		curselection {
			set sel [$t selection get]
			if {[llength $sel] == 0} { return -1 }
			return [expr {$sel - 1}]
		}

		selection {
			if {[llength $args] == 0} {
				set result {}
				foreach i [$t selection get] {
					if {$i > 0} { lappend result [expr {$i - 1}] }
				}
				return $result
			} else {
				error "wrong # args: should be \"[namespace current] selection ?<index>?\""
			}
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
					lset Priv(itembackgrounds) [expr {$index - 1}] [lookupColor $Priv(background:normal)]
				} else {
					$t item enabled $index 0
					lset Priv(itembackgrounds) [expr {$index - 1}] [lookupColor $Priv(background:disabled)]
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
				lset Priv(itembackgrounds) [expr {$index - 1}] [lookupColor $Priv(background:$command)]
			} else {
				$t item state set $index highlight
				lset Priv(itembackgrounds) [expr {$index - 1}] [lookupColor $Priv(background:normal)]
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
			set resize 0
			if {[info exists opts(-maxwidth)]} {
				set Priv(maxwidth) [expr {max(0, $opts(-maxwidth) - 2*[$t cget -borderwidth] - 2)}]
				array unset opts -maxwidth
				set resize 1
			}
			if {[info exists opts(-minwidth)]} {
				set Priv(minwidth) [expr {max(0, $opts(-minwidth) - 2*[$t cget -borderwidth] - 2)}]
				array unset opts -minwidth
				set resize 1
			}
			if {[info exists opts(-width)]} {
				set Priv(width) $opts(-width)
			}
			if {[info exists opts(-state)]} {
				set state $opts(-state)
				array unset opts -state
				$t configure -state $state
			}
			if {[info exists opts(-height)]} {
				if {$opts(-height) == 0} {
					set opts(-height) $Priv(last)
				}
				set Priv(height) $opts(-height)
				set Priv(minheight) $Priv(height)
				$w resize -force -height
				array unset opts -height
			}
			if {[info exists opts(-background)]} {
				$t configure -background [lookupColor $opts(-background)]
				array unset opts -background
			}
			if {$resize && $Priv(width) == 0 && $Priv(resized)} {
				ComputeWidth $w
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
				-cursor		{ return [$w.__tlistbox_frame__ cget $arg] }
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

		find {
			if {[llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <column> <content>\""
			}
			lassign $args column content
			for {set i 1} {$i <= $Priv(last)} {incr i} {
				if {$content eq [$t item text $i $column]} { return [expr {$i - 1}] }
			}
			return -1
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
			foreach name [array names ${lb}::Priv] {
				set Priv($name) [set ${lb}::Priv($name)]
			}
			set Priv(last) -1
			set Priv(index) 0
			set Priv(addcol) {}
			set Priv(columns) {}
			set Priv(expand) ""
			set Priv(types) {}
			foreach options [set ${lb}::Priv(addcol)] {
				$w addcol {*}$options
			}
			set size [set ${lb}::Priv(last)]
			for {set index 1} {$index <= $size} {incr index} {
				set values {}
				set column 0
				foreach type $Priv(types) {
					set result {}
					if {$type ne "text"} {
						set result [$lb.__tlistbox__ item image $index $column]
					}
					if {[string length $result] == 0} {
						set result [$lb.__tlistbox__ item text $index $column]
					}
					lappend values $result
					incr column
				}
				$w insert $values {*}[set ${lb}::Priv(insert:$index)]
			}
			$w resize -force
		}

		default {
			error "bad command \"$command\": must be activate, addcol, cget, configure, curselection, enabled?, get, insert, resize, or select"
		}
	}

	return $w
}


proc SetHeaderLabel {t id name1 name2 _} {
	if {[string length $name1] && [string length $name2]} { set name1 ${name1}(${name2}) }
	$t column configure $id -text [set $name1]
}


proc FindMatch {w column code mapping} {
	variable [namespace current]::${w}::Priv

	set n $Priv(last)
	set c [string toupper $code]
	set t $w.__tlistbox__
	set k [$t selection get]

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


proc ComputeWidth {cb {dontshrink 0} {fixed 0}} {
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
			incr width [max $w $Priv(minwidth:$id)]
		}
		set neededwidth $width
		if {$fixed} {
			set width [winfo width $t]
		} else {
			set maxwidth $Priv(maxwidth)
			set minwidth $Priv(minwidth)
			if {$dontshrink} {
				set w [expr {[winfo width $t] - 2*[$t cget -borderwidth] - 2}]
				set minwidth [max $minwidth $w]
			}
			if {"$cb.vsb" in [grid slaves $cb]} {
				if {$maxwidth} { set maxwidth [expr {$maxwidth - [winfo reqwidth $cb.vsb]}] }
				if {$minwidth} { set minwidth [expr {$minwidth - [winfo reqwidth $cb.vsb]}] }
			}
			if {$maxwidth && $maxwidth < $width} { set width $maxwidth }
			set width [max $width $minwidth]
			set width [expr {$Priv(numcolumns)*$width}]
			$t configure -width [expr {$width + 2*[$t cget -borderwidth]}]
			if {$Priv(expand) eq [lindex $Priv(columns) end] && $Priv(numcolumns) == 1} {
				$t column expand $Priv(expand)
			}
		}
		if {$neededwidth > $width} {
			grid $cb.hsb -row 1 -column 0 -sticky ew
		} else {
			grid forget $cb.hsb
		}
	}
}


proc ComputeHeight {cb dontshrink} {
	variable [namespace current]::${cb}::Priv

	if {[llength $Priv(columns)] == 0} { return }
	set t $cb.__tlistbox__

	set last [expr {min($Priv(last), $Priv(height))}]
	set height 0
	for {set i 1} {$i <= $last} {incr i} {
		lassign [$t item bbox $i] x0 y0 x1 y1
		incr height [expr {$y1 - $y0}]
	}
	if {[$t cget -showheader]} {
		incr height [$t headerheight]
	}
	set minheight $Priv(minheight)
	if {$dontshrink} {
		set h [expr {[winfo height $t] - 2*[$t cget -borderwidth]}]
		set minheight [max $minheight [expr {$h/$Priv(linespace)}]]
	}
	if {$last < $minheight} {
		set height [expr {$height + ($minheight - $last)*$Priv(linespace)}]
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
				if {$Priv(ellipsis:$id)} { set squeeze {-squeeze x} } else { set squeeze {} }
				set s [$t style create style$id]
				$t style elements $s [list sel$dir elemTxt elemImg]
				$t style layout $s elemTxt -ipadx $padx -pady $Priv(pady) -expand ns {*}$squeeze
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
		$t item configure $item -tag $index
		$t item style set $item {*}$styles
		$t item lastchild root $item
	}
}


proc VisitItem {t mode column item} {
	if {[$t cget -state] eq "disabled"} { return }
	set index [expr {$item - 1}]
	set id [$t column tag names $column]
	event generate [winfo parent $t] <<ItemVisit>> -data [list $mode $id $index $column]
}


proc VisitHeader {t mode column} {
	if {[$t cget -state] eq "disabled"} { return }
	set id [$t column tag names $column]
	event generate [winfo parent $t] <<HeaderVisit>> -data [list $mode $id $column]
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
		event generate [winfo parent $t] <<ListboxSelect>> -data $data
	} elseif {$select && [$t cget -selectmode] eq "multiple"} {
		if {$index in [$t selection get]} {
			$t selection clear $index $index
		} else {
			$t selection add $index
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
			set last [$t item id [list nearest 0 [expr {[winfo height $t] - 1}]]]
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
		set last [$t item id [list nearest 0 [expr {[winfo height $t] - 1}]]]
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
	set last [$t item id [list nearest 0 [expr {[winfo height $t] - 1}]]]
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
			set last [$t item id [list nearest 0 [expr {[winfo height $t] - 1}]]]
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
			}
			multiple {
				if {$active in [$t selection get]} {
					$t selection clear $active $active
				} else {
					$t selection add $active
				}
			}
		}
		event generate $w <<ListboxSelect>> -data [expr {$active - 1}]
	}
}


proc ScanMark {table x y} {
	variable [winfo parent $table]::Priv

	set info [$table identify $x $y]
	if {[llength $info] == 0} { return }
	if {[lindex $info 0] ne "item"} { return }
	set row [$table item tag names [lindex $info 1]]
	set index [expr {$row - 1}]

	if {$index ni $Priv(dontsort)} {
		set Priv(drag:click:x) $x
		set Priv(drag:click:y) $y
		set Priv(drag:x) [$table canvasx $x]
		set Priv(drag:y) [$table canvasy $y]
		set Priv(drag:motion) 0
		set Priv(drag:drop) {}
		set Priv(drag:row) $row
		set Priv(drag:target) {}
		set Priv(drag:after) {}
		set Priv(drag:scroll) 0
	}
}


proc ScanDrag {table x y} {
	variable [winfo parent $table]::Priv

	if {![info exists Priv(drag:x)]} { return }

	if {!$Priv(drag:motion)} {
		if {abs($x - $Priv(drag:click:x)) > 4 || abs($y - $Priv(drag:click:y)) > 4} {
			set Priv(drag:motion) 1
			set Priv(drag:selection) [$table selection get]
			$table dragimage clear
			foreach col $Priv(columns) {
				catch { $table dragimage add $Priv(drag:row) $col sel }
			}
			$table dragimage configure -visible yes
		}
	}

	if {$Priv(drag:scroll) != 0} {
		if {$Priv(drag:scroll) < 0} {
			set first [$table item id {nearest 0 0}]
			if {$first > 1} {
				$table yview scroll -1 units
				set Priv(drag:y) [expr {$Priv(drag:y) + $Priv(linespace)}]
			}
		} else {
			set last [$table item id [list nearest 0 [expr {[winfo height $table] - 1}]]]
			if {$last < [$table item count] - 1} {
				$table yview scroll +1 units
				set Priv(drag:y) [expr {$Priv(drag:y) - $Priv(linespace)}]
			}
		}
		set x0 [expr {[$table canvasx $x] - $Priv(drag:x)}]
		set y0 [expr {[$table canvasx $y] - $Priv(drag:y)}]
		$table dragimage offset $x0 $y0
		set Priv(drag:scroll) 0
	}

	if {$Priv(drag:motion)} {
		set info [$table identify 10 $y]
		if {[llength $Priv(drag:target)]} {
			$table item state set $Priv(drag:target) {!droptarget}
			set Priv(drag:target) {}
		}
		if {[llength $info] == 0} {
			set mid [expr {[winfo height $table]/2}]
			if {$y < $mid} { set dir -1 } else { set dir +1 }
			set Priv(drag:scroll:x) $x
			set Priv(drag:scroll:y) $y
			if {[llength $Priv(drag:after)] == 0} {
				set Priv(drag:after) [after 250 [namespace code [list Scroll $table $dir]]]
			}
		} else {
			after cancel $Priv(drag:after)
			set Priv(drag:after) {}
			set row [$table item tag names [lindex $info 1]]
			set index [expr {$row - 1}]

			if {[lindex $info 0] eq "item"} {
				if {$row ne $Priv(drag:row) && $row ne $Priv(drag:target) && $index ni $Priv(dontsort)} {
					$table item state set $row {droptarget}
					set Priv(drag:target) $row
				}
			}
		}

		set x [expr {[$table canvasx $x] - $Priv(drag:x)}]
		set y [expr {[$table canvasx $y] - $Priv(drag:y)}]

		$table dragimage offset $x $y
	}
}


proc MoveRow {table x y} {
	variable [winfo parent $table]::Priv

	if {![info exists Priv(drag:x)]} { return }

	if {$Priv(drag:motion)} {
		$table dragimage configure -visible no
		$table dragimage clear

		if {[llength $Priv(drag:target)]} {
			$table item state set $Priv(drag:target) {!droptarget}
		}

		set info [$table identify 10 $y]
		if {[lindex $info 0] eq "item"} {
			set target [expr {[$table item tag names [lindex $info 1]] - 1}]
			set source [expr {$Priv(drag:row) - 1}]
			if {$target ni $Priv(dontsort)} {
				event generate [winfo parent $table] <<ListboxDropRow>> -data [list $source $target]
			}
		}
	}

	array unset Priv drag:*
}


proc Scroll {table dir} {
	if {![winfo exists $table]} { return }
	variable [winfo parent $table]::Priv
	if {![info exists Priv(drag:x)]} { return }
	set Priv(drag:scroll) $dir
	set Priv(drag:after) {}
	ScanDrag $table $Priv(drag:scroll:x) $Priv(drag:scroll:y)
}


proc DestroyHandler {w} {
	if {[winfo class $w] eq "TListBoxFrame"} {
		namespace delete [namespace current]::$w
		rename $w {}
	}
}

} ;# namespace tlistbox

# vi:set ts=3 sw=3:
