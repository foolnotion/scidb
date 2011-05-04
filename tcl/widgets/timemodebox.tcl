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
# Copyright: (C) 2010-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

proc timemodebox {w args} {
	return [::timemodebox::Build $w {*}$args]
}


namespace eval timemodebox {
namespace eval mc {

set Mode(normal)	"Normal"
set Mode(rapid)	"Rapid"
set Mode(blitz)	"Blitz"
set Mode(bullet)	"Bullet"
set Mode(corr)		"Correspondence"

} ;# namespace mc


namespace import ::tcl::mathfunc::max

variable modes {normal rapid blitz bullet corr}


proc minWidth {} {
	variable modes

	set len 0
	foreach mode $modes {
		set len [max $len [string length $mc::Mode($mode)]]
	}

	return [expr {$len + 2}]
}


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Content
	variable ${w}::Width
	variable ${w}::IgnoreKey 0

	array set opts {
		-textvar			{}
		-textvariable	{}
		-width			0
		-state			normal
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	ttk::frame $w -borderwidth 0 -takefocus 0
	ttk::tcombobox $w.__w__ \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-column mode \
		-state $opts(-state) \
		;
	$w.__w__ addcol image -id icon -justify center
	$w.__w__ addcol text -id mode
	pack $w.__w__ -anchor w

	set Width $opts(-width)
	Setup $w

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w.__w__ <<Language>> [namespace code [list LanguageChanged $w]]
	bind $w.__w__ <<ComboBoxPosted>> [list set [namespace current]::${w}::IgnoreKey 1]
	bind $w.__w__ <<ComboBoxUnposted>> [list set [namespace current]::${w}::IgnoreKey 0]
	bind $w.__w__ <<ComboboxCurrent>> [namespace code [list ShowIcon $w]]

	$w.__w__ current 0

	catch { rename ::$w $w.__timemodebox__ }
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
			bind $w.__w__ {*}$args
			return
		}

		valid? {
			set value [$w.__w__ get]
			set index [lsearch [$w.__w__ cget -values] $value]
			if {$index >= 0} { return true }
			if {$value eq "-" || $value eq "--" || $value eq ""} { return true }
			return false
		}

		value {
			variable modes
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			return [lindex $modes [expr {$item - 1}]]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set value [lindex $args 0]
			if {[info exists mc::Mode($value)]} { set value $mc::Mode($value) }
			$w.__w__ current search mode $value
			ShowIcon $w
			return $w
		}

		focus {
			return [focus $w.__w__]
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
	set current [$w.__w__ current]
	Setup $w
	if {$current >= 0} {
		$w.__w__ current $current
	}
}


proc Setup {w} {
	variable ${w}::Width
	variable modes

	$w.__w__ configure -width [expr {max([minWidth], $Width)}]
	$w.__w__ listinsert [list "" "--"] -index 0
	set index 0
	foreach mode $modes {
		$w.__w__ listinsert [list $icon::12x12::Mode($mode) $mc::Mode($mode)] -index [incr index]
	}
	$w.__w__ resize
	$w.__w__ mapping [::mc::mappingForSort] [::mc::mappingToAscii]
}


proc ShowIcon {w} {
	variable modes

	set content [$w get]
	if {[string length $content]} {
		set idx [$w.__w__ find $content]
		if {$idx >= 1} {
			set img $icon::12x12::Mode([lindex $modes [expr {$idx - 1}]])
			if {[$w.__w__ placeicon $img]} {
				return
			}
		}
	}

	$w.__w__ forgeticon
}


proc Completion {w code sym var} {
	if {![info exists ${w}::IgnoreKey]} { return }

	variable ${w}::IgnoreKey

	if {$IgnoreKey} { return }

	switch -- $sym {
		Tab {
			set $var [string trimleft [set $var]]
			Search $w $var 1
			ShowIcon $w
		}

		default {
			if {[string is alnum -strict $code] || $code eq " "} {
				after idle [namespace code [list Completion2 $w $var [set $var]]]
			} else {
				after idle [namespace code [list ShowIcon $w]]
			}
		}
	}
}


proc Completion2 {w var prevContent} {
	variable modes

	set content [string trimleft [set $var]]

	set len [string length $content]
	if {$len == 0} { return }

	if {$len == 1 && [string is digit $content]} {
		if {$content <= [llength $modes]} {
			$w.__w__ current $content
			$w.__w__ icursor end
			$w.__w__ selection clear
			$w.__w__ selection range 0 end
		} else {
			$w.__w__ set ""
			bell
		}
	} elseif {[string equal -nocase -length [expr {$len - 1}] $content $prevContent]} {
		Search $w $var 0
	}

	ShowIcon $w
}


proc Search {w var full} {
	set content [set $var]
	if {[string length $content] == 0} { return }

	if {$full} {
		$w.__w__ current search -nocase mode $content
	} else {
		$w.__w__ current match -nocase mode $content
		set newContent [$w get]
		
		if {$content ne $newContent} {
			set k 0
			set j 0
			set n [string length $content]
			while {$j < $n} {
				set c [string index $newContent $k]

				if {[string equal -nocase $c [string index $content $j]]} {
					incr j
				} else {
					incr j [string length [::mc::mapForSort $c]]
				}

				incr k
			}

			$w.__w__ icursor $k
			$w.__w__ selection clear
			$w.__w__ selection range $k end
		}
	}
}


namespace eval icon {
namespace eval 12x12 {

set Mode(normal) $::icon::12x12::dot

set Mode(rapid) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAABlElEQVQoz2NgwAQsbGxsGfb2
	Dt8Cg4J+ysjILmZgYGBjwANkNLV0z+47dOr/sVOX//sHRvxnYGBQgZuGRQObgKAo87efzAyf
	v/1g+PXnPwMDAwMPTJIZi4aPTx7f1/r5+7vx48d33x3ev3P358+fJuBzkoGxsfFmCwuLzwwM
	DOsZGBjKGRgYonA5iVNUVDQiv6DQXUVFhenAwUM23FxcDosXLbhz5syZIwwMDI+Y0DSIWFha
	GyqrqLMKCoszGxgYi/DxCwswMrH8YWBgEMNmA+uvX7+5fv78x/D2zQeGBfMXMGzdsuHO16+f
	KxkYGK4wMDAwoNjAycnpKy0jp8fLL8jAJyDEkJSSyeDt4y/EwMAgycDA8ANZbbCcnNL13ILK
	/7sOnv5f09D6R1xc8kZ9c8/PTduP/zcytrzLwMBggxysxq4eASFunn6cO3ds+rJiyfwVL54/
	q3xw/44kOzuXyssXzxifPH5wgoGB4RLMBjEpGfmDGpq690TFxAugHmRkYGAwEBOXXMnGxh7M
	wMAgwMDAwAAA2k9/Hff2g9AAAAAASUVORK5CYII=
}]

set Mode(blitz) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABI1BMVEUAAAAAAAMEAwMEBQgT
	ExMYGhAhL28mJiYxKxI3LxZiSxuKayKikjvcljjdmDTdnTH//yL//94AAAAEBgkAAAAAAAAA
	AAAIDQsAAAAMCwgAAAAbFw4AAAAAAAA1KBw4MhIGBANAOx0KCAVANxEgFg4PDAZKMBovLRQx
	JxErHwwiGAwnHQ4pIA1jRBtmWRguIg9IPBlbPxdaQBVlSh8vIg5xYB0vHxBTOheMdyhjSBuW
	gR5+TiCpgi2MYSSpbzCWaya3mSrCpSWmcCiIbiOchCmvfCmwbyusZyy9gi2+jy/btC3XijG6
	gi3VljLfmzHhpDHkjDXlsDLorDbsnjLtnjTupzfuuzXwszDzrzbzsC/z0Cv1yDX2wiv2xi34
	yzP40in////fwhI+AAAATHRSTlMAAAAAAAAAAAAAAAAAAAAAAAABAgMLDA8QFBgaHiQ0NkJD
	REVHUFNaZmtsbW15ent7fH9/g4ybqK+2wM3Y2trk5e7w8fHx8fT2+/z+s6hhmQAAAAFiS0dE
	YMW3fBAAAACASURBVAgdJcHrCoJAEAbQb2QsZbu4A1IGvf9b9bvU0h2vhaxpnUP4CyWbbowV
	2X1mHyFjEdlUpBlCBgI5nhLzVKeMWC67jBtqHTFYzobIeLN5ByCeffDRetxODN+Ppu9c2dzB
	iU2TVvU1lAAfrqKuaHMsOIqLSocaK/ZV3pUzfr6lhTQTYwNLxAAAAABJRU5ErkJggg==
}]

set Mode(bullet) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABUFBMVEUAAAAnIyQ6OjpGRkZI
	SEhWVlZoaGiioaH///8dHR0iIiI4ODheXl5wcHB8fHyYmJgaGhoeHh4vLy9ZWVktLS06OjpO
	Tk5aWlo9PT03Nzc7Ozo4ODg3NzcjIyMqKipHR0csLCwwMDBGRkYsLCw/QEAsLCw+Pj4sLCwz
	MzMuLi4wMDAsKysvLy8tLS0uLi4vLy8wMDAxMTGCgoIaGhpCQkIcHBxRUlIkJCQRERFMTEwQ
	EBBdXV0YGBgeHh4eHh5ZWVkZGRliYmJ7e3sNDQ0UFBQVFRUWFhYaGhobGxsbGxwdHR0eHh4f
	Hx8gICAhISIiIiIkJCQsLCw2Nzc8PTxGRkZLS0tNTU1PT09RUVFUVVVVVVZVVldZWlpeX2Bi
	Y2Nubm5vb293d3d5eXl9fX19fX6Cg4OLjIyLjY2Qk5OSkpSTk5akpqamqamxsrPP0NH///9e
	4W3tAAAAQ3RSTlMAAAAAAAAAAAABAQEBAQEBAgICAgMDAwMLDC81d3x8fH19fX9/gJ+goKKi
	pKWnp6msrd/g4+fn6vT09/j8/P39/v7+RANJ7wAAAAFiS0dEb1UIYYEAAACCSURBVAgdTcE9
	EoIwEAbQ/TabhL8RZ8BRCy3sbLz/NTyBlX1ggBCExJb3iHZApBFttAhFBDeaK2Esy8HJOW/L
	Oxif7fEWc311EzG10Vs5PTFMVelnViL4Sn3xtRqwJqUs37TZnKc0q2I0TXTd9FuLHqrROQt4
	CccRRJQFk6WUypX2/ozULS3iF7o0AAAAAElFTkSuQmCC
}]

set Mode(corr) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAJCAYAAAAGuM1UAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAABeklEQVQY023QsU8TURzA8e/v9bhWuMPKNaaNxoGQ1KFo
	aEiJScsoMTFOOjiwyOqfZOLiYlwYoIEmLBgWpMGAWCIXhoZYaS8sgrx77b1z0MXE7/yZvvL4
	1ZvFrOtslm5P5qxN+V8W6Ec/tRmOlhwnI62H94vu8rMq0/cCtLEgf2UKOVfRPu7zobmf/Xry
	vaVuek525XlN3m8ccBSec20V/UvL4DLh2iqOwnNa21948XRevBtjWRXHmsKUR6NeYXXrkDDs
	cssbI++5hGGX1a1DGvUKhcDDGI1jTMwwsUzkfaoLFTZ2DtjbPwEg+pUwv/CA8fwkw5EljjUq
	1hqL0DntsdvuMDNbpnsldK+Emdkyn9odjk97WARjNGpoYqLBBc21j0xMBbi+T60xR60xh+v7
	jAcB62vbRIMLjImR6fpr/ahadpdfPpHS3SJJkvxzSWUy9M5+8PZdM937/M1Isbqy6GTU5p1S
	IWdtipCSyh8sCCmglHDWi/QosUu/AcpVoLcZHweRAAAAAElFTkSuQmCC
}]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace timemodebox

# vi:set ts=3 sw=3:
