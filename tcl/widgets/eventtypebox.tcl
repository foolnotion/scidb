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

::util::source event-type-selection-box

proc eventtypebox {w args} {
	return [::eventtypebox::Build $w {*}$args]
}


namespace eval eventtypebox {
namespace eval mc {

set Type(casual)	"Casual"
set Type(match)	"Match"
set Type(tourn)	"Roound Robin"
set Type(swiss)	"Swiss-System Tournament"
set Type(team)		"Team Tournament"
set Type(k.o.)		"Knockout Tournament"
set Type(simul)	"Simultaneous Tournament"
set Type(schev)	"Scheveningen-System Tournament"

} ;# namespace mc


namespace import ::tcl::mathfunc::max

variable types {match tourn swiss team k.o. schev simul casual}


proc minWidth {} {
	variable types

	set len 0
	foreach type $types {
		set len [max $len [string length $mc::Type($type)]]
	}

	return [expr {$len + 3}]
}


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Content

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
	set width [expr {max([minWidth], $opts(-width))}]
	ttk::tcombobox $w.__w__ \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-column type \
		-state $opts(-state) \
		-width $width \
		-placeicon yes \
		;
	$w.__w__ addcol image -id icon
	$w.__w__ addcol text -id type
	pack $w.__w__ -anchor w

	Setup $w

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w.__w__ <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
	bind $w.__w__ <<ComboboxSelected>> [namespace code [list CheckEntry $w]]

	$w.__w__ current 0

	catch { rename ::$w $w.__eventtypebox__ }
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
			set index [lsearch -exact [$w.__w__ cget -values] $value]
			if {$index >= 0} { return true }
			if {$value eq "-" || $value eq "\u2014" || $value eq ""} { return true }
			return false
		}

		value {
			variable types
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			return [lindex $types [expr {$item - 1}]]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set value [lindex $args 0]
			if {[info exists mc::Type($value)]} {
				$w.__w__ current search type $mc::Type($value)
			} else {
				$w.__w__ current 0
			}
			CheckEntry $w
			$w placeicon
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
	set current [$w.__w__ current]
	$w.__w__ forgeticon
	set current [$w.__w__ current]
	Setup $w
	if {$current >= 0} {
		$w.__w__ current $current
		CheckEntry $w
	}
}


proc Setup {w} {
	variable types

	$w.__w__ listinsert { "" "\u2014" } -index 0
	set index 0
	foreach type $types {
		$w.__w__ listinsert [list $icon::12x12::Type($type) $mc::Type($type)] -index [incr index]
	}
	$w.__w__ resize
	$w.__w__ mapping [::mc::mappingForSort] [::mc::mappingToAscii]
}


proc Completion {w code sym var} {
	if {[$w popdown?]} { return }

	switch -- $sym {
		Tab {
			set $var [string trimleft [set $var]]
			Search $w $var 1
			if {[$w testicon]} {
				$w placeicon
			} else {
				$w select none
			}
		}

		default {
			if {[string is alnum -strict $code] || $code eq " "} {
				after idle [namespace code [list Completion2 $w $var [set $var]]]
			} elseif {$sym ne "Down"} {
				after idle [list $w testentry]
			}
		}
	}
}


proc Completion2 {w var prevContent} {
	variable types

	set content [string trimleft [set $var]]
	set len [string length $content]

	if {$len == 0} {
		$w.__w__ current 0
		CheckEntry $w
	} elseif {$len == 1 && [string is digit -strict $content]} {
		if {$content <= [llength $types]} {
			$w.__w__ current $content
			$w.__w__ icursor end
			$w.__w__ selection clear
			$w.__w__ selection range 0 end
			CheckEntry $w
		} else {
			$w.__w__ set ""
			bell
		}
	} elseif {[string equal -nocase -length [expr {$len - 1}] $content $prevContent]} {
		$w testicon
		Search $w $var 0
	}
}


proc Search {w var full} {
	set content [set $var]
	if {[string length $content] == 0} { return }

	if {$full} {
		$w.__w__ current search -nocase type $content
	} else {
		$w.__w__ current match -nocase type $content
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
			CheckEntry $w
		}
	}
}


proc CheckEntry {w} {
	if {[$w get] eq "\u2014"} {
		$w.__w__ set ""
	}
}


namespace eval icon {
namespace eval 12x12 {

set Type(casual)  $::icon::12x12::filetypeScidbBase

# set Type(match) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAIAAADZF8uwAAAACXBIWXMAAA50AAAOdAFrJLPW
# 	AAABlklEQVQYlWOYPnvW/sOHquvr9AwNbOzt0rMyV69fd+DI4ai4WH1jIzsnx/rmZobL16/9
# 	//+/orqKAQyAjE/fvv75/x+oAcjl5OJcuWYtw/NXL4GKPLy8IIqWrVoJ5L55+1ZCUhLIlVdQ
# 	uHj1GkN+UWFZVWVOQX5NQ31lbU1sYkJxeVlpRXl+cVFrZ0dBSVFcUhJINwcHx449u4EGXL1+
# 	jZWVFSiip69/9+EDoMjM2bMhNjAoKClevHoFKLRm3TqISFBoyOv374Ai2bk5IL6Xr09oZMSk
# 	qVO2bN8GtNHeydHH3y81I33uwgWbtm1NTkt1dndjACqfPmsmxICUjPTP378BRYJDQyAi8xcv
# 	+vf/P0hRFsRMBoaOnq7vv38BkbauDsitXJy79u398ec3w407t8OjoyRkpFU1NTp7ey5euXz0
# 	xAlDU2NZRQVjc7MVa1YDncvAzMY6YcrkD18+P3jyWE5RgYGJUUZeDhgHwPDcsXsXAzMTJy83
# 	Awc318q1a37+/XPmwnlObi6Q/w0NIJ6dMQfkf1YOdgDyrsXfI353DwAAABp6VFh0SlBFRy1D
# 	b2xvcnNwYWNlAAB4nDMCAAAzADP+5LUJAAAAJ3pUWHRKUEVHLVNhbXBsaW5nLWZhY3RvcnMA
# 	AHicM6ow0jGsMARhABGDAumMDrTtAAAAAElFTkSuQmCC
# }]

set Type(match) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACB0lEQVQoz12SXWhSARzF//devYo3P5gXFmE99MlebGwt
	cKPow6VZ5NM+6CUGNXatXgYbFBH08VCw6KEN6tFeLEzQQraUrLy6xd2SFQ0aY9fd3alsXhcE
	lfOK/15azJ3Xcw7nPPwIACBgi1B6gV+ns5fVipqjteS4vesWbM1ooF44l+CZ9Mzchdh8OW/v
	cItTk+lFR3tHdbNE1qWnbkINa+2rFebkb8LY7z7jTPj9/oe9PT02RMTtCzi7YmQK66sD7ovX
	dhSDbyCZ5Hclk/wgIhYNDPOgbgGjfVBRxFOBKO+6PzIKJUUBggDwXfWBTqdrue7jzIiI1L9v
	eLzVTuv0hrumptPNQDPQ2emESOQ1UCQF8op8kOO4w7IkzVIAQOC7KyBnC22p76Ub+j2tTCgU
	Ah1Ng6pWwXPOA6qqUlqt1syybEQDAPh+eaemjMVL4dQM0Uxm1O6ubi3LsmC1shCPx0EURUgk
	EpHgy8A0VY4MwPxC1kER6FjaaOh3ujzfJGm50f/c38gYGFJRFBgeGlqzWCzDRpNJpgrWE7Tm
	pzSoVmsT+w0/PgY+LH4WhE9Rk9F0zOv12gRBgFJp/dW9O7ef7TtwqEbubSAMuT96/kt+I9Y3
	JsDE23Hw+bi1XD63FA6Hwbbb9iuTyQRdZ89XYRsV/xGIx2NwtO1I09jok6eT6VT08aMR86b/
	F28t2/HengXrAAAAAElFTkSuQmCC
}]

#set Type(tourn) [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAAJcEhZ
#	cwAACxMAAAsTAQCanBgAAAAHdElNRQfbBg4JDRx1zN1SAAABDElEQVQY0wXBTysEYRzA8e8z
#	z29mdqe1rMMq5Wbz56hc5C2Qg5B3IEcn5SJvwJ6Vi5QcKFwcHbVpEdmD7Bzslk1iycyaeZ7x
#	+SiAy4H+JVlWlcR0H9oHt+e7EQDXI42jZvyatbNWFmY33ePqZgn0SXG42rfiisJigMAPpnFa
#	V3p9tbSRczMMKQaLJadUpVgTWfTyGYaElBRw0JTK5XlhVGOIiUhxEAAyvHFJEkPELwbBw0Wj
#	sKjE+ax/0cPi4OKTIyBA2bjudA7f3i3gIAg+eXy+m61TPRiWA3fG14KHh4/Hx8/TztqFvrMT
#	NYkYk4IoxZ/pvDS29/afUwWwoGenhuYKk2Li+/Bs67Fn4R+6SWUKCfONswAAAABJRU5ErkJg
#	gg==
#}]

# set Type(tourn) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAABAUlEQVQYGQXBsUrDUBiA0S+5
# 	SbBIN0FEoeiQRRzVSegkShDdnUUfQHBx09VHcHJytV3q0EFwKepo0eKkqFBLk5AmvTe3/T3H
# 	iQBgc3ZnfkO8QTdt0WEATgTKPzs+r1cChJR7bu/MCT9EHJz2piIiVrTkkkhD9tvRogrrhzdb
# 	LlgMOSkxc8TLXw9udXfbFTQFGQkxCUNWCPa86prHmBEZI3I0Bo0iWPW0jQkYklFQYiixlIh1
# 	k06HlJQCi6HEIMSUz65tNye/OGgKCsZM8XjHNFX4mff7UQ1FyQQfjxe6V3KtQngafH8s+QsV
# 	HP54lLeL6SXaiQCgpo5m1h3fvJoGLYB/EXJ63h0RbeQAAAAASUVORK5CYII=
# }]

set Type(tourn) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAABxUlEQVQoz52RX0hTYRjGn3O+8+2cb39tZlsjM7dBg8Da
	/IPoUCao4MJLKxAvuguCLgILo4uuvPW6iy6iKCjwrlggolMET1KisobgYWlTm9P5dzvNnc8L
	JUG76oGX9+L5vTzwvATnJQEwn+zDs6YAAJTZUMzvUm99d6TCF+phjks+47Co72VS6q9E/M36
	opr8e0CojFJRl2qjDx75G6IDtooqp0goAKCo7/OMNjuXGHv/MNh5P/5x8C5I271+mG3O9tqO
	3iHPtYBToQQKFaFQEWamCBddV1wmWfbHXj7+ZC+/vE+0uQnSHO17EgiGm5npFD4eAUymsFgt
	7r2t31+vh1oTEgDmcnt8TpsCcH6+AkGAqbxM9lRWewOhJkgADFks6XZGAPB/8AKoIUAw9AIx
	8pAAHGyuLqky8p3MYgU/kyKKBNtrmc20lpg92MlCaop0YWbyy9uaW8HuusaWGkIoODdOYBHb
	uS2e/DbxQY3HpmWFgayuaFhPL288f/Z0wWph/gsOq1sxEQmlPzyT/pmbHP38evjdqxeBGzdz
	KW3x+HEAMDWfwp3bEVd9Yzh8taraqxcKevLH/PfxkZhqd5Tls9kN/JeOAM21mLL2sHFYAAAA
	AElFTkSuQmCC
}]

# set Type(swiss) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMAgMAAAArG7R0AAAADFBMVEUAAAAAAAD////YGADE
# 	zaH2AAAAGklEQVQI12P4//8/Axi/RuBfq9aDMbIYVB0AMnMiEa20/TkAAAAASUVORK5CYII=
# }]

set Type(swiss) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QAAAAAAAD5Q7t/AAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3AcDDS0VTJIoXQAAAcNJREFUKM910T1oU2EY
	xfH/++amMblG80UTAmktbYo1asXqIA4qbtoiXRShgoObs+3S2cHdUXHroKBQWwsOOgsqKESx
	NpJItEmaNLnJzcfNzX0dSkIWf/M5cB4eQZ8G2LAwHg+mNF9UIPjWbRZe5fL7DBEAD0cneNve
	893QRhcnO/o1j9KmFIqOtH9mPa3NDbv08qo30nywu4M4r7npCqXfdUeXZ63Q/bgMh30TYwgh
	MX/lKDjlcnqk+viZ9eeRhjBR+glWtKNLr8VU5TsXVD5yU/X9jd9RP7iotuR0ZdUdXFJHTiO9
	Zjo8ZnvmIy496Dt5HO+5mcHeQ2en0U+lCEo9GO+650PGl7A2BzEFSY/fT+Lr0+H7CKyvEgBK
	oUuwL5JzEJMOCBNbtnot/sfuWfRwpANCfoZiAytTNkp8FLNkYguDYCaxyCdxhppRpIOV+QBF
	2SJRzNDeytIwKtSpdMqDQrW9R40GWerGNs03dZJFLc5vHHjuozGjUPcSNctvHE4BYDbr5DHr
	aRpP1um+2GT74HG3kLzHCVzGdfsYI9e9uCYBWvR2cnQ33mGvXUFW13AOCkNcUYiNQxQgC4UC
	7AK9fuAfvC+4BMYk9tsAAAAASUVORK5CYII=
}]

# set Type(team) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAB
# 	nUlEQVQYGQXBvWoUYRSA4fec78zszOyOmzhZEjD4g0QIGkNsVkkRRa/AO7FRrMRrsLKz8QJM
# 	kUKCf6CF4A1YWKSwyCJGjePOzsx3fB7ZBw5z7qzAwwySv8Kzp0V4FZYf0Pf/bpFNnmDDCW39
# 	gj9Hz8Mol6qEx2O4lAkKXNht/dPbcm+O6iOScoOQd8A5rPhq6l5EWGuFLEDqMMEpEDHoK7wd
# 	ElvBo0MswsbAao9xtXVuNjConYNTYX+2sPlPywOx3SM2Q/r6Dd3pS5vErovK+xTuJ+ACrwto
# 	vi1fA49f0Pw7IV8idh9Jzv7WdWAEO5WgK0J3Rti6DUgowYod0vGQtFqQlFu0s0SPkJEKU3EM
# 	MIEb74TStVdEdxFJERKQTWxp3VL8qsAVBXUQ4HwWuYzLD2AbFHDDfRkNU1O4i1MgKGAOWRCm
# 	eH+MWAUscBI8gug9c2cqQgRyBAHqHq5LbE7cTEFSYAA4+KY1TprBuINEYQCE2lGJtTn5CO/A
# 	O0V0jb4+sc750DrVXFmNIB386p3PUZhBt403F4luEI+hPfwPB/if8+ZBR2sAAAAASUVORK5C
# 	YII=
# }]

set Type(team) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACEUlEQVQoz12SvU8TcRyHP9/f/WwLd9eXE9srJC3oISpp
	iQzGKKIkDjogcTBRow7+AQ7OOvkf6O5sIpM6NGE0aIIvqSkqRqgNUAp9A+64ttfe3c/BhMFn
	fcbnIfzHo0sxVLY7R0YN+amekJ8IFqD1dfNny3LuEpDnjy9HIQRC/Qq/rWmhE83dnud6fi4U
	kh6mh5PU6YVRrpROO72dWYDy3BMAgDtJXX4eT8QV12+JanXrmhSUtaGxCfQrGkRAxrvXZQYA
	jJgAMZFSo5pybMhAavQUMSmYDUUGCkZ2XCiRPkRi/ZbruX9czwW3rRYAdEeykzDGDAy3O/j+
	tVCmsPKyuFqaMJtWcHO3nreN+AIRQRpUGQ66aF+fm5kOcDZQ2aqi3me3R6az4yq0xHa5ymxF
	VYypZEbWujW+cutL+Gw6oq86OTv2+wOWN1oQ2XtJZ8Af1FPn6fi5NJY2Xx31eWOuddC+wi+k
	gy+mzqg3jfhVVdnThD/kUi06w76V1lDeXkRG/4yPxXnEYylyel6UR4N4IPdxLO3ruHFylhDu
	otGUkFAzWCy8h70/D0DGXt0Upmk6vFixIIdV1FsCy0XA9QAmEdy2h50Np6ybta1e70AIIXxr
	z8nxwkrpU8NsT3KJMfGvCYiIds1Os/Qr/iy/8OONDSLfEwKARTxz/6IXiE4KX9DhH0SMhF9j
	5noOQMNbe3uo/gK7a+ct/HbZxAAAACJ6VFh0U29mdHdhcmUAAHjac0zJT0pV8MxNTE8NSk1M
	qQQAL5wF1K4MqU0AAAAASUVORK5CYII=
}]

# set Type(k.o.) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAD6SURB
# 	VBgZBcGxLkNRGMDx//edc29u01Z7aSORkDTYDIYmXoHEzgPwECaDsHgAY2e7WKxlYJBIhFjv
# 	IgTVilR7z/n8fgKODnHJjsrNWLV3ruxsdJ/hYIGJ6vF0b1INqTVtXbvJa+PFL+bJPo1yGxQw
# 	zOxad0e3nrXxgStiDmCAeftKQ8g1vMWh4X4VDxhmWkrKj6sNZNm2pBLUEAxCUo+fo3M3Y/Jk
# 	3dAxAiCYxpacZo+uAgP62rLV4CMgyI07iWOBjFlkXi5DM/4JvsZh0vvAw5gU6lKkfZkEL+1Y
# 	CEM8QMTm3DM9K2G6EUoFPMAUHnxbd2RFndx9XyjwDzgjaNxaQ2jPAAAAAElFTkSuQmCC
# }]
# 
# set Type(k.o.) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAC
# 	CklEQVQYGTXBTWvTYAAH8H/z5GmbJ0nbbKntmmoXFeZBdvEgeBYmuIKHaY/r2YtzIP0cQ/Hg
# 	y8HbCiL4BYYn0e2mB0FQ3Gzt1jZtTZYmefLmdvD3yzzd2YHjuhAEQQWwGieJGXJO0hSHjElf
# 	Op3OpNvtotVq4Zxguy4opddlWX5TKpXea5r2WlELL8Moevfr6Ojt4+3t261WC93dXZwjd9bW
# 	1Gw290zTSvckxhillGSQEh5G0slwaB4fH99qNtd92zkdrlxbsYUoiurI4AYPQzjOKSxrgtHY
# 	wuzvFLPpDKJIr0pMfgHg+XKjsSACCGzbDuI4RhKn8AMfruvCsR2EYQjDMCAzhjhJbnqeZ4pG
# 	rTb4tH/wjRDxSi6fA+ccc3eO6XSCuetCYnkIhMAPAotSOhI3221v4/6Dr8PRaL1YKAIZgAcB
# 	PM9DrbYEc9kEEQT43vxjbanSF++uN6EqyufBYOCdkbQFDWW9jErlAhqXLkKWFdi2fUgIefW7
# 	/ycm7c1NmKbZt8bW5SDkq7quo24YyOfzSFNEUcj3Pc97YprLH4hAQPb29mDU61xfXHT8INhQ
# 	ZYXmslmMLQu9Xu+7VipuiJQezCZTPNragogzlUoFSNNesVAY5/I5I46TpKzrGVVR+oyxE1VV
# 	0W63cU7EmbKuQxAyPwPOHyZxvBQnUZAmSciY9KNarbq+7+O/f0WV7jXz429oAAAAAElFTkSu
# 	QmCC
# }]
# 
# set Type(k.o.) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAC
# 	EUlEQVQYGTXBTU/TYAAH8H/pM/oy2q2EJRZW2WBbAm6DiAnGgyePJH4Fz969qCcPvkW+gDFq
# 	4gcQQwwXD55M9CCixonbjJgxNrY2LX1ZH/Z0dRz8/bhmvQ7LtsHzvAKgyqIoT0PKx3F8oKrK
# 	19XVVYsxBkIIzhDTtiGJYlmW5XuCKF4djUbKyYnLHXU63vcftS+vt7buE0LeseEQJJEAt7e3
# 	p4ii9ErX9euTwiQYY7BtG61WG593d3F83G1cWrv4WEtrO41ms0VOT0+zoiSthZTC8324ngfL
# 	stDr9dDtdiEIQkFR1KcAtssXlm8QANQ0LcpYhCgawQ98OI4D07RAKUWpVIKqqoiiaN3zvDwp
# 	FQtH2293aiQxuSjLMsIwhOM46HQ6cGwbijIFQgiCIDAFQeiRVFobPHj46Nufg78bmUwGHMch
# 	CAK4rotSsYBKuQzC8/A898PiwvwhuX3nLqY17WO93hi4rivpug7DMJCbP4/lpSWk02n0+/0D
# 	Qsiz/Xoz4jc3n6BarRy22+2FwSCsGoaBUrGI5FQScRwzSukn3/duVSrl9zzPg8PY8xcvkVLV
# 	a7X9X2/mZmdlXT+HvmnBceyfVy6vb4iS1BxSiurKCgjGcrl5II5bmZmZfjIpzzEWjYzsHDet
# 	pQ9TqVRX0zRomoYzBGNGNouJCe73IAxvsiHTGRvSURQNVVVp5vN5fwz//QOvZvn8TcOHDQAA
# 	AABJRU5ErkJggg==
# }]
# 
# set Type(k.o.) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAB
# 	8klEQVQoz1VSO2/TUBS+CKkSEl06Vww82lQkbdM0tZsOrVM3Tuq8nEcdx3acuE4c24nTBzJx
# 	FEWZ+BVs7AjBilj5BzDAAGJCQmwg0SIdjlOpqEc60/3O+R7nEtuyiKZppNVqzWPvNDRNqdfr
# 	miTV93RdXyBYk8mEXBcCiGEYYdu2X7qDwY++6/4x2p2L6pH4k8tk3uXzefbGEG6ZN83uq+Fw
# 	COPxGPzRCHAQVFWDXSYJsc34J0EQ2rKsLKZSHAnkrJjd7rez8ydwcnIKpmWBojagKAgBGCh6
# 	G1Ae4MDrZrO5EAzcVxT1c7vTgWOjPQOXK1VgUxysrUchnTmElq6D1mx9lyQpRp563h0unXlz
# 	yGdxawn4bA6S+yzEtygIhVZmTAYukhXlg6qq92Y+KJp+toyP0Y0YbMQ2IbK6BkvLIUgkdsDp
# 	9cF1XWRWn5+fnd4m69EoYZhk4eGjpd+PwxGgtxMzhkr1CIED8P0R9Hr9LyidrssyxtpoEMdx
# 	7lIU/SIcWQUmuQ9iTZp5wXgvbdt5j7Gng1iR6Spalj0guVyO3aLoX+xBCk1XgEOzu3vMRzzm
# 	g45pkmNd/388URSDDuH2rzyf/SsI5QuM8rJULr8N2D3PIzfKwu9h29acUCrxhULRyBeKqijW
# 	aqg5Pp1Ob/m+f439B81y1RVlTBaEAAAAAElFTkSuQmCC
# }]

set Type(k.o.) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAABmUlEQVQoz4WSMUgcURiE5+3u
	PW/3XM+gJzEhoiAxGjGgKY5cYZGACMY6haVVmnRaCFam1hSBYGNvI1iHFNpYWkQ0Ccbzjqjo
	XVxvb/X23nv/byEWiuLU8zHM/494MvdSNDV6by+i8+L+zNYvPCA7/HGC15MDU0w0Ld/4ujGX
	+RuulWr3AgAw/DE7nkp6I+WzsxGZFNnm4dZT+Sq9H238N3cC/RMv3ndkHg8dlMs2sepqcJ0x
	13d60rmWIrc1HNW2KnwNWABglEFSWnjW3gbDgLDZ97zExKOMu9qRbfncPdvXeSOh98Pz8aaU
	O+inUqjGVdiWBWk7kAnH91yZs6UY9QbTNX7q/nQACK11QmsNZRhhRSEKazDKQGuCrmsGwVDd
	GMuz4QCA1lowATt7/1DcLQMA2DBAOGBFS6xosbS4VwBwBbBhrkYx8vnjKzMjBGGFFX3Budos
	LRXouoMDgJmZfxcPUQmiOhteZ8PzHOvvpW/5+PZZHQDi8DigIIi3qU4L0Lx88nU3uO9xIvOp
	WySl/U4pKhwt/HlwGpdZSMQMQz1mGQAAAABJRU5ErkJggg==
}]

set Type(simul) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAdElEQVQY032PbQ3AIAxErxUw
	BVOAgglBCApwgB6EzECdMFpK2Eey8IfcK68HGuahY90bVhxZuHyAxXJHf6CHFdtUcRlwzio6
	LPZ34HNIKGkvFwp2cDDUZyi5UCjaDg6UXWK7NF6tskvqq64LZUw/fq5oxQ0XEYlxzPEu5kEA
	AAAASUVORK5CYII=
}]

set Type(schev) $::icon::12x12::gameflag(S)

}; # namespace 12x12
}; # namespace icon
} ;# namespace eventtypebox

# vi:set ts=3 sw=3:
