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

::util::source termination-selection-box

proc terminationbox {w args} {
	return [::terminationbox::Build $w {*}$args]
}


namespace eval terminationbox {
namespace eval mc {

set Normal				"Normal"
set Unplayed			"Unplayed"
set Abandoned			"Abandoned"
set Adjudication		"Adjudication"
set Death				"Death"
set Emergency			"Emergency"
set RulesInfraction	"Rules infraction"
set TimeForfeit		"Time forfeit"
set Unterminated		"Unterminated"

} ;# namespace mc


namespace import ::tcl::mathfunc::max

variable reasons {Normal Unplayed Abandoned Adjudication Death Emergency
						RulesInfraction TimeForfeit Unterminated}


proc minWidth {} {
	variable reasons

	set len 0
	foreach reason $reasons {
		set len [max $len [string length [set mc::$reason]]]
	}

	return [expr {$len + 3}]
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
	bind $w <FocusIn> { focus [tk_focusNext %W] }
	ttk::tcombobox $w.__w__ \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-column reason \
		-validate key \
		-validatecommand { return [string is alpha %P] || [regexp {[-]*} %P] } \
		-state $opts(-state) \
		;
	$w.__w__ addcol image -id icon -justify center
	$w.__w__ addcol text -id reason
	pack $w.__w__ -anchor w

	set Width $opts(-width)
	Setup $w

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w.__w__ <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
	bind $w.__w__ <<ComboboxPosted>> [list set [namespace current]::${w}::IgnoreKey 1]
	bind $w.__w__ <<ComboboxUnposted>> [list set [namespace current]::${w}::IgnoreKey 0]
	bind $w.__w__ <<ComboboxCurrent>> [namespace code [list ShowIcon $w]]

	$w.__w__ current 0

	catch { rename ::$w $w.__terminationbox__ }
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
			if {$value eq "-" || $value eq "\u2014" || $value eq ""} { return true }
			return false
		}

		value {
			variable reasons
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			return [lindex $reasons [expr {$item - 1}]]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set value [lindex $args 0]
			if {[info exists mc::$value]} {
				$w.__w__ current search reason [set mc::$value]
			} else {
				$w.__w__ current 0
			}
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
	variable reasons

	$w.__w__ forgeticon
	$w.__w__ configure -width [expr {max([minWidth], $Width)}]
	$w.__w__ listinsert [list "" "\u2014"] -index 0
	set index 0
	foreach reason $reasons {
		$w.__w__ listinsert [list [set icon::12x12::$reason] [set mc::$reason]] -index [incr index]
	}
	$w.__w__ resize
	$w.__w__ mapping [::mc::mappingForSort] [::mc::mappingToAscii]
}


proc ShowIcon {w} {
	variable reasons

	set content [$w get]
	if {[string length $content] > 1} {
		set idx [$w.__w__ find $content]
		if {$idx >= 1} {
			set img [set icon::12x12::[lindex $reasons [expr {$idx - 1}]]]
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
	variable reasons

	set content [string trimleft [set $var]]
	set len [string length $content]

	if {$len == 0} {
		$w.__w__ current 0
	} elseif {$len == 1 && [string is digit -strict $content]} {
		if {$content <= [llength $reasons]} {
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
		$w.__w__ current search -nocase reason $content
	} else {
		$w.__w__ current match -nocase reason $content
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

set Normal [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH2gUQEjAYNACUvQAAAYtJREFUKM99jT9rU1EY
	h5/3nHNJrQG1FU0kWEEzSCnFQYeKES1IxnwNN5eA30E3P4GjWwYnl2pEUAraxaEiZFCRKk0k
	9+bc3J5z7nGIScXBB15+8PL7I51OZ6/X621up9ce3DTbG6fCip3YdHf/x8dX+Sf/Ra+q+Ob1
	c2JERMAQ2QE2qfpHKpIkXmOLcfFVDz6n53+9tMP0/dLFpcyNirVg4zNjMHsAAZ/8lAMETU5e
	8XK0HsSvKy1RaYliZIzEXZOUlW8AkciIQxIq2JihRIMAIAgCnBThkkl8csBsgkynJPGQabQs
	EAEEhAThslmW6hCAQpgu54wYMo2WgP9T/BdCU52R1THA4Ok+Hs8kZuTREggs/LK4NdXauJ0D
	FANwR/5hkbsnzvp3YVpOKPmX2rwjAmzd2pK3dz5w5cbKaeXK6zh/Nzh3NRTFCZcV30NW7tBq
	teaB2G63j7uSmVTvaXP2vqmc6yp14bHGNJtN+v3+bK9WOw64mWQvgs/Az9+qXq8vPI1Gg263
	y//4DVnEp/zMlQN2AAAAAElFTkSuQmCC
}]

set RulesInfraction [image create photo -data {
	R0lGODlhCQAMALMAAJkAAJkAM7siM6sSM8gvM7MaM6MKM78mM7ceM8QrM68WM6cOM8wzM54F
	MwAAAAAAACH5BAAHAP8ALAAAAAAJAAwAAAQzEMhJmWUkHXnzERyTJIKASBkpFIU0luwgfUih
	DItk2rghsbeFofEbDAzDgMSIbASUlGgEADs=
}]

set Adjudication [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QAAAAAAAD5Q7t/AAAB
	9klEQVQYGV3By2oTURgA4P/c5pKLmSaYRMFgoUihGhCKQbEW7MIW3dStLvoWRRRBXIgVFd/A
	R3CjiFBciLgx1ajUKtFGQjqNqZlkcjkzc+acozur34fgP1MnT8PBTGKaUIrcrv/5+8Yb0PAX
	hn0wAOxOVqAr4IrL1dVf5UVA8C8Kf1y/cQ2KNsEDkiTZzpZ+uMdSGADftD+y4e1bkJIj2eKg
	7t9dA1Q5VYGYj6nMHlo1LHMWYhEHQE9ohMDS4gMijAaI1gzev5OwzIj6yISY4WMg1EowaD8L
	/V4tMzHxSisFP3veIOHkypA7vKKo9STGRo3i0gyw5uY5JIN2oPHudv3rY9hnZm5y1YjGnVEk
	57rO0RpF3zbyQsG039l5lC6UFstnF4oEo51R3wMNuBALMeW77gO7UDqTaLwvYm2lLmiEgnar
	uS4ReCFmCy7NQGg6wOzkeRWFg1b9ywvJR76RSi9hEfJlLMNqHsCnIN9KrS9l+80k3WtYEaCL
	FGSVAfhUhdUwjC6jI7PzniJkkzDD13HsCI3yeNxbYnwYczPz3EwluxoTD4FKCx4cpwrBO2E7
	8zwIMBEabMWfkmHHgzBQ1DrwKbIzy8BMoDJUbDx6TbJEbWUZInbMo5TiL6Xn3ttu/Kj3BkOe
	s0ndoWCY416Y4P110XXXfgO/yPUYX0KWdQAAAABJRU5ErkJggg==
}]

set Death [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QAAAAAAAD5Q7t/AAAC
	H0lEQVQYGTXBW0hTYRwA8P93O1OHGzbbvNAybwQLhSAlNIOCfIiil6LCpJ7SgijowR6iXnqL
	MEIieumxsgtRKWkgaGUglIpRMvNyNLW1qXC2821n33f+ZejvR2BDWmm4eqEd6pv2t1LAm47G
	RUXFpa47d78Mj3yAXM5gHdn73oThhSQcrfDvmrD0weaMebxjd7ihf2DQfekW9q+U1QxW5dF3
	NyJbRqNJR/Pmojw+b6tTAzF53tKQnVbo50JAVmVJVKriaEIemLHIsV9Sdbdsz7/Hn84nz604
	7hWp8ScgsQhiAQACIhKqFKC048sSklK5ZxeksnjCcS/rrBM/4klVlObQvFKkfo/HA5Gd1dCe
	kGVaJArNWRMmYtT7ORhp42mNgUKS/XO9NlRZUxwQhDLkhgFNjQ2wz9U+AuDredsLq5++AhRU
	RriXU0c6jD0anxsNRhd50KCBlrrItvGxMdI3E0tZvqBcmEqgyfwCGJ/mgNjliJzW+3LrdzcF
	mUa9XHW4ei08GZ2CZ0ts+ls4MElCdcIooSUuZZ1cUNKpXFj15YgztgsplmECNnAhQHhErp9x
	kC4+sBW+4Iu2ymTXMg+LSrzjIcFOBjTxAgAiAgkaJL3kYUNaqVep3+kfRoEB/yEilL+ZAawH
	ePy693Q8Hs886X6uO27dbvt4ogn29JmwicM/hBBYNzc7C7W2PeTLz79YtqPcsNK6x4xcg5FD
	Ydj0F/aAASKHDsEtAAAAAElFTkSuQmCC
}]

set Emergency $::icon::12x12::gameflag(~)

set TimeForfeit [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAk1BMVEUAAAAAAAAAAAAAAAAA
	AAAzMzM0NDRGRkZiYmJiY2JxcXF1dXV4eHh5eXmPj4+QkZGRkZGSkpKhoaChoaG2tra4ubm5
	uLi5uLm5ubi/v76/v7/AwMDHx8jIx8fPz8/Qz8/W19fX1tbX19fe3t7l5eTl5eXn5+fr6+vr
	6+zr7Ovx8fH29vb29vf29/b7+/r7+/v///+3By9uAAAABHRSTlMAAhJKXupqqQAAAHhJREFU
	CB0FwTEOwkAMBMC1Y9CFUEVISOH/P6Kl4wOkQEfO3mXGAPOWiE4h4HFuq338lzQ7LVuYiu8+
	3M/bZE+y7uHRWphQLM3muZoSVVLLgLGEF/AYsOV6U5FF7RndJVJUHscEfS9kkfsog0e0+Ri9
	igaYt0R0Cn+NW0wNxwDW2wAAAABJRU5ErkJggg==
}]

set Unplayed [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAABp0lEQVQoz22QTWsTURiFnzu3
	bWLSaUhUxAEpaLHeBmfhRKIRQYTiILoOaNGfUNAuZzlrN0J/QikIbs1CujRUOmLVCJZpaKe1
	bWrTJGOaNJvgximl5MC7Oc/7xZEAEzNzdsYsLGbMQnD47ZPPKZ1lcmJmzgbcl0+nrdW1qjo9
	FLHiowdWZX1DZcxCIK49f73y4sm0VdnYZvLKZRY+LHmA8/+A+/j+HavWaJHWk3wsr3gyYxaC
	1bWqyk1dN778WieXnTSq2zsKeJg3s9bm3j7DQ5Ly1x8e4AiAq89e2YB775Zpbe7uM5qI0+n2
	OGg0GRkZptkKPcCpLrwpSYDG97Kfvnk32NqtqXPxmFGrNzjqHqNpGn/b7ZNmgKEojX6/D0Dn
	uIfUNM76kSTAeHHWFkK4qbExC0AIcVLxWMzo9Xoqlc0HrcqyL8aLszbgns+krWhL/bDhAQzw
	HJnK5hcvXbxgaUKgCcGfg3oU61Kn21X6aNLQhCCZSBjto46SurodhO22Sum68Xuv5gHO1ru3
	pVZl2R/EZPjzs5+8kQuaYagAZ+f9fCl6YxD7ByswwHrAi8cXAAAAAElFTkSuQmCC
}]

set Abandoned [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QAAAAAAAD5Q7t/AAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAAB7klEQVQoz3WQz2vacByGP02+swk2yJqitbIi1myzSNkO
	pbutlB6CwX9gO/QqjN02GHiQbZedBrvs5Ogt7FA36A7W/bhIe5CuEiqTsRicUdLMVqsxqUZj
	spvQ0b3n93kODw7/meM4AAD3WJZ9RpJkhWGYliiKgF115nkeksnkXZZl34XD4ZVarda0LOtq
	czweh2g0SmWz2Y/FYtFJpVKPZVkGhmEAAAD9CyQSCSiXy5uBQICtVCrVQqHwOZfLUbFYLDQa
	jRYRTlHYy0hk2QOwKPR6+xzHDT9kMg9s2yYkSRpyHPfE4/GsIISCoih+RW9XV7fmHGfLe3Ky
	MDccfrq9sYHhlhWTJAkoirpF0/RNXddVWZa3BUF4g6I+3/Nau823FIW6Q5KPXDMz5+T0NHl4
	fNzsXVwciKKYr9frX/L5/E+apsdoNBj8Xna7H/b9/v4PWU53TdPt29mJG2dnT1/t7fEAMMmj
	qirg/vE4jwxD/aVpmfHammvT601YpZJePzrafoHj1e9LS/Cn1ZpEwffb7fP7kcihOTvrWQ8G
	XwvV6nvX6em1edMMrYdCuzf6fUfpdCYABgDgwjDAAAhC08iFRiMy6HTcDQw7cEol20aXy+MA
	ANTUFAia1pw3DPt6txtq6PpuGqF0liCsb4pyCfgLqm7gB7Lkj8cAAAAASUVORK5CYII=
}]

set Unterminated [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAA51BMVEWMjIyIiIiIiIiJiYmL
	i4uKi4uZmpqgo6OgpKShpKSYmpqZmpqpsLCrsrKqsbG+Uk2/Uk3ATknAT0vHZWDIU1DIVFLI
	ZmLKWlfKWljLVlTMV1XNambNamfOXVvTXFzTXlzU2NjV2NjV2NnV2dnYZmXYZmbYcm/YcnHY
	kI3ednXed3bfpqPfpqTiqKfirqzksK/lm5rlsbDms7Hm5+fnrazn5+fosK3osa/os7PotLPp
	trXqra3qr67qsa/qsrDrtrXuycfu3t3v4N/x4ODzubjzurnzzMvz4uL0ubn0urr0zcz50dH/
	//9Oyly5AAAAD3RSTlMAISJAi43f4+Pj5ub19fn96pgSAAAAjklEQVQIHQXBwQqCQBQF0Pu8
	o9YiFEwDLVu0aNH/f0qLliMmLRLKIHScl50jgJAhZtUFArI8G/hbpyrB6rK1Tsyxv44Bi3TI
	ncseScGAp0Y3+yo1zYkmir+DZHh2jCMDP+sEOEcP4zzz8o5Ke+8oqD9D+4JW9k1Mybr5LeNu
	sk5AHuoFYltVAYShgZ91wR/K3j8yHsfm5wAAAABJRU5ErkJggg==
}]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace terminationbox

# vi:set ts=3 sw=3:
