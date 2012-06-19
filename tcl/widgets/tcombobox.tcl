# ======================================================================
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
package require Ttk
package require tlistbox
package provide tcombobox 1.0

namespace eval ttk {

proc tcombobox {args} {
	if {[llength $args] == 0} {
		return error -code "wrong # args: should be \"tcombobox pathName ?options?\""
	}

	if {[winfo exists [lindex $args 0]]} {
		return error -code "window name \"[lindex $args 0]\" already exists"
	}

	if {[llength $args] % 2 == 0} {
		return error -code "value for \"[lindex $args end]\" missing"
	}

	return [tcombobox::Build {*}$args]
}

} ;# namespace ttk


namespace eval ttk {
namespace eval tcombobox {

proc Build {w args} {
	variable Priv

	array set opts {
		-background			white
		-state				normal
		-showcolumns		{}
		-column				{}
		-format				"%1"
		-empty				{}
		-searchcommand		{}
		-scrollcolumn		{}
		-textvariable		{}
		-validate			none
		-validatecommand	{}
		-exportselection	1
		-invalidcommand	bell
		-width				0
		-postcommand		{}
		-takefocus			{}
		-cursor				{}
	}

	array set listopts { -textvar {} -textvariable {} }
	array set listopts $args
	if {[llength $listopts(-textvariable)] == 0} {
		set listopts(-textvariable) $listopts(-textvar)
	}
	if {[llength $listopts(-textvariable)] == 0} {
		set listopts(-textvariable) [namespace current]::Priv($w:textvar)
	}
	unset listopts(-textvar)

	set keys [array names opts]
	foreach key [array names listopts] {
		if {$key in $keys} {
			set opts($key) $listopts($key)
			unset listopts($key)
		}
	}
	array set listopts {
		-usescroll				yes
		-relief					flat
		-highlightthickness	0
		-selectmode				browse
		-borderwidth			1
		-showfocus				0
	}
	set listopts(-background) $opts(-background)
	if {[tk windowingsystem] eq "aqua"} {
		set listopts(-borderwidth) 0
	}
	if {[info tclversion] >= "8.6"} {
		set listopts(-style) ComboboxPopdownFrame
	}
	if {[llength $opts(-column)] > 0 && [llength $opts(-showcolumns)] == 0} {
		set opts(-showcolumns) [list $opts(-column)]
	}
	if {[llength $opts(-showcolumns)] == 0} {
		set opts(-showcolumns) {0}
	}
	if {$opts(-state) eq "readonly"} {
		set opts(-cursor) {}
	}
	if {$opts(-width) == 0} {
		unset opts(-width)
	}

	set Priv($w:showcolumns) $opts(-showcolumns)
	set Priv($w:format) $opts(-format)
	set Priv($w:empty) $opts(-empty)
	set Priv($w:searchcommand) $opts(-searchcommand)
	set Priv($w:scrollcolumn) $opts(-scrollcolumn)
	set Priv($w:mapping1) {}
	set Priv($w:mapping2) {}

	set cbopts {}
	foreach key {	-class -cursor -style -takefocus -exportselection -justify
						-height -postcommand -state -textvariable -values -width
						-background -validate -validatecommand -invalidcommand} {
		if {[info exists opts($key)]} {
			lappend cbopts $key $opts($key)
		}
	}

	::ttk::combobox $w -class TTCombobox {*}$cbopts
	bind $w <<PasteSelection>> {+ %W forgeticon }	;# global binding is not working

	tk::canvas $w.__image__ -borderwidth 0 -background $listopts(-background) -takefocus 0

	foreach {ev c} {	ButtonPress-1 ""
							Shift-ButtonPress-1 "s"
							Double-ButtonPress-1 "2"
							Triple-ButtonPress-1 "3"} {
		bind $w.__image__ <$ev> [namespace code [list ButtonPress $w $c %x %y]]
		bind $w.__image__ <$ev> {+ break }
	}

	rename ::$w $w.__combobox__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	set poplevel [::ttk::combobox::PopdownToplevel $w.popdown]
	wm withdraw $poplevel
	set lb [::tlistbox $poplevel.l {*}[array get listopts]]
	bindtags $lb.__tlistbox__ [list $lb TComboboxListbox [winfo class $lb.__tlistbox__] $w all]
	pack $lb -fill both

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		listinsert {
			return [$w.popdown.l insert {*}$args]
		}

		addcol - clear {
			return [$w.popdown.l $command {*}$args]
		}

		resize {
			variable Priv

			set values {}
			set nrows [$w.popdown.l size]
			set columns $Priv($w:showcolumns)
			for {set i 0} {$i < $nrows} {incr i} {
				if {[llength $columns] == 1} {
					lappend values [$w.popdown.l get $i [lindex $columns 0]]
				} else {
					set lastValue ""
					set text [string range $Priv($w:format) 0 end]
					set index 1
					set count 0
					foreach column $columns {
						set value [string trim [$w.popdown.l get $i $column]]
						if {[string length $value]} {
							set lastValue $value
							set text [string map [list %$index $value] $text]
							incr count
						}
						incr index
					}
					if {$count == 1} { set text $lastValue }
					lappend values $text
				}
			}
			foreach index $Priv($w:empty) { lset values $index "" }
			$w configure -values $values
			return [$w.popdown.l $command {*}$args]
		}

		find {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <string>\""
			}
			return [lsearch -exact [$w cget -values] [lindex $args 0]]
		}

		get {
			if {[llength $args] > 0} {
				return [$w.popdown.l get {*}$args]
			}
		}

		mapping {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <list-1> ?<list-2>?\""
			}
			set [namespace current]::Priv($w:mapping1) [lindex $args 0]
			set [namespace current]::Priv($w:mapping2) [lindex $args 1]
			return $w
		}

		current - activate - select {
			set cmd [lindex $args 0]
			if {$cmd eq "match" || $cmd eq "search"} {
				if {[llength $args] != 3 && ([llength $args] != 4 || [lindex $args 1] ne "-nocase")} {
					error "wrong # args: should be \"[namespace current] $command match|search ?-nocase? <column> <string>\""
				}

				variable Priv

				set strEqOpts {}
				if {[llength $args] == 4} {
					lassign $args search nocase column key
					lappend strEqOpts -nocase
				} else {
					lassign $args search column key
				}

				set k [FindMatch $w.popdown.l $cmd $column $key $Priv($w:mapping1) $strEqOpts]

#				if {[llength $Priv($w:mapping2)]} {
#					set j [FindMatch $w.popdown.l $cmd $column $key $Priv($w:mapping2) $strEqOpts]
#					if {$j >= 0} {
#						if {$k == -1} {
#							set k $j
#						} elseif {$k != $j} {
#							set k -1 ;# match is ambiguous
#						}
#					}
#				}

				if {$k == -1} { return }
				set args [list $k]
			}

			if {$command ne "current"} {
				return [$w.popdown.l $command {*}$args]
			}

			if {[llength $args] > 0} {
				$w.popdown.l select [lindex $args 0]
				event generate $w <<ComboboxCurrent>> -when mark
			}
		}

		search {
			if {[llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <column> <char>\""
			}
			variable Priv
			return [$w.popdown.l search {*}$args $Priv($w:mapping1) $Priv($w:mapping2)]
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.__combobox__ instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}

		configure {
			if {[llength $args] % 2 == 1} {
				error "value for \"[lindex $args end]\" missing"
			}
			array set opts $args
			if {[info exists opts(-background)]} {
				$w.__image__ configure -background $opts(-background)
			}
		}

		showcolumns {
			variable Priv

			if {[llength $args] > 1} {
				error "wrong # args: should be \"[namespace current] $command ?<list-of-columns>?\""
			}
			if {[llength $args] == 1} {
				set Priv($w:showcolumns) [lindex $args 0]
			}
			return $Priv($w:showcolumns)
		}

		columns {
			return [$w.popdown.l columns {*}$args]
		}

		placeicon {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <image>\""
			}
			set img [lindex $args 0]
			if {[winfo ismapped $w]} {
				lassign [$w bbox [expr {[string length [$w get]] - 1}]] x y _ h
				if {$y == 0} {
					after 20 [list $w placeicon $img]
				} else {
					if {[$w.__image__ itemcget image -image] ne $img} {
						$w.__image__ delete image
						$w.__image__ create image 0 0 -image $img -tag image -anchor nw
						$w.__image__ configure -width [image width $img]
						$w.__image__ configure -height [image height $img]
					}
					set x1 [expr {$x + 12}]
					set y1 [expr {$y + ($h - [image height $img])/2}]
					set x2 [expr {$x1 + [image width $img] + 2}]
					set y2 [expr {$y1 + [image height $img]}]

					if {$x2 <= [winfo width $w]} {
						set area [$w identify $x2 $y2]
						if {[string match *textarea $area]} {
							place $w.__image__ -x $x1 -y $y1
							return 1
						}
					} else {
						place forget $w.__image__
					}
				}
			} else {
				bind $w <Map> [list after idle [namespace code [list PlaceIcon $w $img]]]
			}

			return 0
		}

		forgeticon {
			place forget $w.__image__
			return $w
		}

		geticon {
			return [$w.__image__ itemcget image -image]
		}

		post {
			set focus [focus]
			bind $w <<ComboboxUnposted>> [namespace code [list Unposted $w $focus]]
			return [::ttk::combobox::Post $w]
		}

		clone {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <[namespace current]>\""
			}
			set cb [lindex $args 0]
			if {![winfo exists $cb]} {
				error "wrong arg: $cb is not an existing window"
			}
			if {[winfo class $cb] ne [winfo class $w]} {
				error "wrong arg: given window $cb is not of type [winfo class $w]"
			}
			variable Priv
			foreach name {mapping1 mapping2 showcolumns format empty searchcommand scrollcolumn} {
				set Priv($w:$name) $Priv($cb:$name)
			}
			$w.popdown.l clone $cb.popdown.l
			return $w
		}
	}

	return [$w.__combobox__ $command {*}$args]
}


proc FindMatch {w cmd column key mapping strEqOpts} {
	set str [string map $mapping $key]
	set len [expr {[string length $str] - 1}]

	set n [$w size]
	set k -1
	set j -1

	for {set i 0} {$i < $n} {incr i} {
		if {[$w enabled? $i]} {
			set content [$w get $i $column]
			set mapped [string map $mapping $content]
			if {0 < [string length $mapped] && $len < [string length $mapped]} {
				if {[string equal {*}$strEqOpts -length $len $mapped $str]} {
					set idx 0
					set end 0
					set pre ""
					for {set idx 0} {$end <= $len} {incr idx} {
						set c [string map $mapping [string index $content $idx]]
						append pre $c
						incr end [string length $c]
					}
					if {[string equal {*}$strEqOpts $pre $str]} {
						# prefix match
						set j $k
						set k $i
						if {$cmd eq "search" && $len + 1 == [string length $mapped]} {
							set j -1
							return $k
						}
					}
				}
			}
		}
	}

	if {$j >= 0} { return -1 } ;# match is ambiguous
	return $k
}


proc Unposted {w focus} {
	bind $w <<ComboboxUnposted>> {#}
	if {[llength $focus]} { focus $focus }
}


proc PlaceIcon {w icon} {
	update idletasks
	$w placeicon $icon
	bind $w <Map> {#}
}


proc ButtonPress {w c x y} {
	set rx [winfo rootx $w]
	set ry [winfo rooty $w]
	set sx [winfo rootx $w.__image__]
	set sy [winfo rooty $w.__image__]
	ttk::combobox::Press $c $w [expr {$sx - $rx + $x}] [expr {$sy - $ry + $y}]
}


proc DestroyHandler {w} {
	if {[winfo class $w] eq "TTCombobox"} {
		variable Priv
		unset Priv $w:*
		rename $w {}
	}
}

} ;# namespace tcombobox
} ;# namespace ttk


ttk::copyBindings Entry TTCombobox
ttk::copyBindings TCombobox TTCombobox

bind TTCombobox <B1-Leave>	{ break } ;# avoid AutoScroll (bug in Tk)
#bind TTCombobox <<PasteSelection>> { %W forgeticon }	;# not working! why?

rename ttk::combobox::Press				ttk::combobox::Press_tcb_orig_
rename ttk::combobox::LBSelect			ttk::combobox::LBSelect_tcb_orig_
rename ttk::combobox::LBSelected			ttk::combobox::LBSelected_tcb_orig_
rename ttk::combobox::LBMaster			ttk::combobox::LBMaster_tcb_orig_
rename ttk::combobox::LBHover				ttk::combobox::LBHover_tcb_orig_
rename ttk::combobox::PlacePopdown		ttk::combobox::PlacePopdown_tcb_orig_
rename ttk::combobox::Post					ttk::combobox::Post_tcb_orig_
rename ttk::combobox::Unpost				ttk::combobox::Unpost_tcb_orig_
rename ttk::combobox::PopdownWindow		ttk::combobox::PopdownWindow_tcb_orig_
rename ttk::combobox::ConfigureListbox	ttk::combobox::ConfigureListbox_tcb_orig_


namespace eval ttk {
namespace eval combobox {

bind TComboboxListbox <ButtonRelease-1>	[namespace code { LBSelected %W }]
bind TComboboxListbox <KeyPress-Return>	[namespace code { LBSelected %W }]
bind TComboboxListbox <KeyPress-Escape>	[namespace code { LBCancel %W }]
bind TComboboxListbox <KeyPress-Tab>		[namespace code { LBTab %W next }]
bind TComboboxListbox <Any-KeyPress>		[namespace code { LBSearch %W %A %K }]
bind TComboboxListbox <<PrevWindow>>		[namespace code { LBTab %W prev }]
bind TComboboxListbox <Motion>				[namespace code { LBHover %W %x %y }]
bind TComboboxListbox <Map>					{ focus -force %W }

bind TComboboxListbox <ButtonPress-4> {
	%W yview scroll -5 units
	after idle { ttk::combobox::LBHover %W %x %y }
}

bind TComboboxListbox <ButtonPress-5> {
	%W yview scroll +5 units
	after idle { ttk::combobox::LBHover %W %x %y }
}


switch -- [tk windowingsystem] {
	win32 {
		bind TComboboxListbox <FocusOut>		[namespace code { LBCancel %W }]
	}
}


proc Press {mode cb x y} {
	variable ::ttk::tcombobox::Priv

	if {![info exists Priv($cb:focusmodel)]} {
		set Priv($cb:focusmodel) [wm focusmodel [winfo toplevel $cb]]
	}

	if {[$cb cget -takefocus] == 0} {
		set Priv($cb:focus) [focus]
	}

	if {$Priv($cb:focusmodel) eq "passive"} {
		Press_tcb_orig_ $mode $cb $x $y
	} else {
		Post $cb
	}
}


proc LBMaster {lb} {
	if {[winfo class $lb] eq "Listbox"} {
		return [LBMaster_tcb_orig_ $lb]
	}

	return [winfo parent [winfo parent [winfo parent $lb]]]
}


proc LBSelect {lb} {
	if {[winfo class $lb] eq "Listbox"} {
		return [LBSelect_tcb_orig_ $lb]
	}

	set cb [LBMaster $lb]
	set selection [[winfo parent $lb] curselection]

	if {$selection >= 0} {
		SelectEntry $cb $selection
		return 1
	}

	return 0
}


proc LBSelected {lb} {
	if {[winfo class $lb] eq "Listbox"} {
		return [LBSelected_tcb_orig_ $lb]
	}

	set cb [LBMaster $lb]

	if {[LBSelect $lb]} {
		variable ::ttk::tcombobox::Priv

		if {![info exists Priv($cb:focusmodel)]} {
			set Priv($cb:focusmodel) [wm focusmodel [winfo toplevel $cb]]
		}

		Unpost $cb

		if {$Priv($cb:focusmodel) eq "passive"} {
			focus $cb
		}
	}
}


proc LBHover {w x y} {
	if {[winfo class $w] eq "TListBox"} {
		set w [winfo parent $w]
		$w activate [list nearest $x $y]
		$w select [list nearest $x $y]
	} else {
		return [LBHover_tcb_orig_ $w $x $y]
	}
}


proc LBSearch {lb code sym} {
	variable ::ttk::tcombobox::Priv

	set cb [LBMaster $lb]

	if {[llength $Priv($cb:searchcommand)]} {
		{*}$Priv($cb:searchcommand) $cb $code $sym
	} elseif {[llength $Priv($cb:scrollcolumn)] && [string is alnum -strict $code]} {
		[winfo parent $lb] search $Priv($cb:scrollcolumn) $code $Priv($cb:mapping1) $Priv($cb:mapping2)
	}
}


proc PlacePopdown {cb popdown} {
	if {[winfo class $cb] ne "TTCombobox"} {
		return [PlacePopdown_tcb_orig_ $cb $popdown]
	}

	set x [winfo rootx $cb]
	set y [winfo rooty $cb]
	set w [winfo reqwidth $popdown]
	set h [winfo height $cb]
	set postoffset [ttk::style lookup TCombobox -postoffset {} {0 0 0 0}]
	foreach var {x y w h} delta $postoffset {
		incr $var $delta
	}

	set H [winfo reqheight $popdown]
	if {$y + $h + $H > [winfo screenheight $popdown]} {
		set Y [expr {$y - $H}]
	} else {
		set Y [expr {$y + $h}]
	}
	if {$x + $w > [winfo screenwidth $popdown]} {
		set x [expr {[winfo screenwidth $popdown] - $w}]
	}
	wm geometry $popdown ${w}x${H}+${x}+${Y}
}


proc Post {cb} {
	if {[$cb instate disabled]} { return }
	Post_tcb_orig_ $cb
	event generate $cb <<ComboboxPosted>> -when mark
}


proc Unpost {cb} {
	Unpost_tcb_orig_ $cb

	variable ::ttk::tcombobox::Priv
	if {[info exists Priv($cb:focus)]} {
		after idle [list focus $Priv($cb:focus)]
		unset Priv($cb:focus)
	}

	if {[winfo class $cb] eq "TTCombobox"} {
		event generate $cb <<ComboboxUnposted>> -when mark
	}
}


proc PopdownWindow {cb} {
	if {[winfo class $cb] ne "TTCombobox"} {
		PopdownWindow_tcb_orig_ $cb
	}

	return $cb.popdown
}


proc ConfigureListbox {cb} {
	if {[winfo class $cb] ne "TTCombobox"} {
		return [ConfigureListbox_tcb_orig_ $cb]
	}

	set popdown [PopdownWindow $cb]
	set current [$cb current]
	if {0 > $current || $current >= [$popdown.l size]} { set current 0 }

	set padding [::ttk::style lookup TCombobox -padding]

	if {[info tclversion] >= "8.6"} {
		set borderwidth [::ttk::style lookup ComboboxPopdownFrame -borderwidth]
	} else {
		 switch -- [tk windowingsystem] {
			x11	{ set borderwidth 1 }
			win32	{ set borderwidth 1 }
			aqua	{ set borderwidth 0 }
		 }
	}

	$popdown.l configure -minwidth [expr {[winfo width $cb] - 2*$padding - 2*$borderwidth}]
	$popdown.l configure -cursor {}
	$popdown.l select $current
	$popdown.l activate $current
	$popdown.l see $current

	event generate $cb <<ComboBoxConfigured>>
}

} ;# namespace combobox
} ;# namespace ttk

# vi:set ts=3 sw=3:
