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

::util::source gender-selection-box

proc genderbox {w args} {
	return [::genderbox::Build $w {*}$args]
}


namespace eval genderbox {
namespace eval mc {

set Gender(m) "Male"
set Gender(f) "Female"
set Gender(c) "Computer"
set Gender(?) "Unspecified"

} ;# namespace mc


namespace import ::tcl::mathfunc::max

set types {m f c}


proc minWidth {} {
	variable types

	set len 0
	foreach type $types {
		set len [max $len [string length $mc::Gender($type)]]
	}

	return [expr {$len + 3}]
}


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Male
	variable ${w}::Female
	variable ${w}::Computer
	variable ${w}::Content

	array set opts {
		-textvar			{}
		-textvariable	{}
		-width			0
		-state			normal
		-skipspace		no
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	ttk::frame $w -borderwidth 0 -takefocus 0
	bind $w <FocusIn> { focus [tk_focusNext %W] }
	set width [expr {max([minWidth], $opts(-width))}]
	ttk::tcombobox $w.__w__ \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-column sex \
		-validate key \
		-validatecommand { return [string is alpha %P] || [regexp {[-]*} %P] } \
		-state $opts(-state) \
		-width $width \
		-placeicon yes \
		;
	if {$opts(-skipspace)} {
		bind $w.__w__ <Key-space> [list after idle [namespace code { SkipSpace %W }]]
	}
	$w.__w__ addcol image -id icon -justify center
	$w.__w__ addcol text -id sex

	keybar $w.hint
	bind $w.hint <<KeybarPress>> [namespace code [list Invoke $w %d]]
	Setup $w

	grid $w.__w__ -column 0 -row 0 -sticky ns
	grid $w.hint  -column 2 -row 0 -sticky ns
	grid columnconfigure $w 1 -minsize $::theme::padding

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [list after idle [namespace code [list Select $w %A]]]
	bind $w.__w__ <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
	bind $w.__w__ <<ComboboxSelected>> [namespace code [list CheckEntry $w]]

	$w.__w__ current 0

	catch { rename ::$w $w.__genderbox__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		cget {
			if {[lindex $args 0] eq "-takefocus"} {
				return 0
			}
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			return [bind $w.__w__ {*}$args]
		}

		focus {
			return [focus $w.__w__]
		}

		value {
			variable types
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			return [lindex $types [expr {$item - 1}]]
		}

		type {
			variable types
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			if {[lindex $types [expr {$item - 1}]] eq $mc::Gender(c)} {
				return "program"
			}
			return "human"
		}

		valid? {
			set value [$w.__w__ get]
			set index [lsearch -exact [$w.__w__ cget -values] $value]
			if {$index >= 0} { return true }
			if {$value eq "-" || $value eq "\u2014" || $value eq ""} { return true }
			return false
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set value [lindex $args 0]
			if {[info exists mc::Gender($value)]} {
				$w.__w__ current search sex $mc::Gender($value)
			} else {
				$w.__w__ current 0
			}
			CheckEntry $w
			$w placeicon
			return $w
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.__w__ instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}
	}

	return [$w.__w__ $command {*}$args]
}


proc LanguageChanged {w} {
	$w.__w__ forgeticon
	Setup $w
}


proc Setup {w} {
	variable ${w}::Male
	variable ${w}::Female
	variable ${w}::Computer
	variable ${w}::Map
	variable ${w}::types
	variable types

	set current [$w.__w__ current]

	foreach type $types {
		set ch [string toupper [string index $mc::Gender($type) 0]]
		switch $type {
			m { set Male $ch }
			f { set Female $ch }
			c { set Computer $ch }
		}
	}

	set i 0
	while {$Male eq $Female} {
		set Female [string toupper [string index $mc::Female [incr i]]]
	}

	set i 0
	while {$Computer eq $Male || $Computer eq $Female} {
		set Computer [string toupper [string index $mc::Computer [incr i]]]
	}

	$w.__w__ listinsert { "" "\u2014" } -index 0
	set index 0
	foreach type $types {
		set entry [list $icon::12x12::Gender($type) $mc::Gender($type)]
		$w.__w__ listinsert $entry -index [incr index]
	}
	$w.__w__ resize

	if {$current >= 0} {
		$w.__w__ current $current
		CheckEntry $w
	}

	set Map(?) "?"
	foreach key $types {
		set ch [string tolower [string index $mc::Gender($key) 0]]
		lappend hints $ch [namespace current]::mc::Gender($key)
		set Map($ch) $key
	}
	lappend hints "?" [namespace current]::mc::Gender(?)
	$w.hint keys $hints
}


proc Select {w key} {
	if {[$w popdown?]} { return }
	if {![info exists ${w}::Male]} { return }

	variable ${w}::Male
	variable ${w}::Female
	variable ${w}::Computer

	$w testicon
	if {[string length [$w get]] != 1} { return }

	if {[string is digit -strict $key]} {
		if {$key <= 3} {
			$w.__w__ current $key
			$w.__w__ icursor end
			$w.__w__ selection clear
			$w.__w__ selection range 0 end
		} else {
			$w.__w__ set ""
			bell
		}
	} else {
		set index -1

		if {[string equal -nocase $Male $key]} {
			set index 1
		} elseif {[string equal -nocase $Female $key]} {
			set index 2
		} elseif {[string equal -nocase $Computer $key]} {
			set index 3
		} elseif {$key eq "*" || $key eq " " || $key eq "-" || $key eq "?"} {
			set index 0
		}

		if {$index >= 0} {
			$w.__w__ current $index

			if {[string is alpha $key]} {
				$w.__w__ selection clear
				$w.__w__ selection range insert end
			} else {
				$w.__w__ icursor end
			}
			CheckEntry $w
		}
	}
}


proc Invoke {w key} {
	variable ${w}::Map

	focus $w
	$w delete 0 end
	if {$key eq "?"} {
		$w current 0
		$w.__w__ set ""
	} else {
		set index [lsearch [$w cget -values] $mc::Gender($Map($key))]
		$w current $index
	}
}


proc CheckEntry {w} {
	if {[$w get] eq "\u2014"} {
		$w.__w__ set ""
	}
}


proc SkipSpace {w} {
	if {[$w get] == " " || [string length [$w get]] == 0} {
		$w delete 0 end
		tk::TabToWindow [tk_focusNext $w]
	}
}


namespace eval icon {
namespace eval 12x12 {

set Gender(m) $::icon::12x12::male
set Gender(f) $::icon::12x12::female
set Gender(c) $::icon::12x12::program

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace genderbox

# vi:set ts=3 sw=3:
