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

proc eventmodebox {w args} {
	return [::eventmodebox::Build $w {*}$args]
}


namespace eval eventmodebox {
namespace eval mc {

set OTB				"Over the board"
set PM				"Correspondence"
set EM				"E-mail"
set ICS				"Internet Chess Server"
set TC				"Telecommunication"
set Analysis		"Analysis"
set Composition	"Composition"

} ;# namespace mc


namespace import ::tcl::mathfunc::max

variable modes {OTB PM EM ICS TC Analysis Composition}


proc minWidth {} {
	variable modes

	set len 0
	foreach mode $modes {
		set len [max $len [string length [set mc::$mode]]]
	}

	return $len
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
	bind $w.__w__ <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
	bind $w.__w__ <<ComboboxPosted>> [list set [namespace current]::${w}::IgnoreKey 1]
	bind $w.__w__ <<ComboboxUnposted>> [list set [namespace current]::${w}::IgnoreKey 0]
	bind $w.__w__ <<ComboboxCurrent>> [namespace code [list ShowIcon $w]]

	$w.__w__ current 0

	catch { rename ::$w $w.__eventmodebox__ }
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

		focus {
			return [focus $w.__w__]
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
			if {[info exists mc::$value]} { set value [set mc::$value] }
			$w.__w__ current search mode $value
			ShowIcon $w
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
		$w.__w__ listinsert [list [set icon::12x12::$mode] [set mc::$mode]] -index [incr index]
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
			set img [set icon::12x12::[lindex $modes [expr {$idx - 1}]]]
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

set OTB $::icon::12x12::filetypeScidbBase

set PM [image create photo -data {
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

set EM [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAABqklEQVQoz32SMWgTYRiGn2tu
	MENCC5nubxwcQkgMCMFCykmEk4Lg0qFEkcThTER6KOIQOqmLqKAgZvFIhhM6BIUKDmK1qESk
	KkUwJEOlDtr/FBK0TcUqVH4nYxTqM7483wcvvBq/iTgGP74fzB/OVJstCUAqKciaMY6frQu6
	FR9AAyidnr35c2urNL/QJhwKcsaxSMQNAOYX2nyQnwnouuteP3oCIo5hT3sqGi+razceqvXe
	N/X8xYoaRH5cU/a0p4g4BlWvoaLxsqp6DaWUUucv3lPReFllrEv943yx1ne0fLGmOp2v3J87
	RW9jk91jF5iwEtgFkzt3l7g9t9SvuX9fDL3ZkhSOZAB4u9Kh7pVYfPmO3DGXf2m2JPpgkN6z
	k/EDl1mVX9iOoVRSsOr/ETJju7aVU0nBUNaM8eBRm97GJgDnZg5hF0zCoSCjYoSpyTSLj2cY
	FSNkzRgaEcewc3ullGvUbxUJh4J/ffU/rWOf9BBimFr9ldDpVvyAPusKMVwat64wNZkmHNoB
	wOs373nSWGbCShDQdZduxdcGp1G9mpNPny3zv2n8AlFovOmd2P40AAAAAElFTkSuQmCC
}]

set ICS [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAC
	NklEQVQYGQXBvU8TYQAH4N/dvdy1lH6BbekHLaHUyNVIFAQVMESjA4rRxA2JGuPkQIwQR/8B
	Ep2MiQOS6ODgIBrKpsUPQESS2qKggKUUpFK49kppe733fB4GAIBBAFOM2DFwqO2E64LbbRBV
	QFtZ34nNTC+Mxz8PLQLnNWAMjNH0FHI2RS7d7ujv7XUOnTxiDRww60hJVfFXKpTD89LS6/Ef
	wx9HnjzX2QIKVyq+Qfe1uzd6rpoedrUaPDVmPasxJaRyCXBEZl1O1aboy90S6/iXnH0wT5pa
	X4mCN3PPaneZ+QovqMZhK72MVEYGGA7FogytHDXrazHoOXZ/jph96NkXDAenthqg8DzU9DxW
	Ft9DA4t8oYBfiSRmF77BYj3st9Y1XibQ7YnxP2GynYtBarkJQq1YSmhYW30HSUqA4Qyo9bXB
	YXFw5SREQmlOK3FxbG98gcnuRWOgH4H2AcichOzqMhrqz0EMXERtJYvYboQQovDRGrtd8VqC
	FcHGM2AJQDUOLk8QqFhF99HrSGVmkEjtqLtJKU6kxULI39x+q7OjK2gS3MgWgTIF6k094IOn
	4TBWwUAETLyd2pz4OhZiY5E7P+WIftgq66UWp4bjboo2l4ZOrxFn/U6cqjNCSdL9udDss3wq
	PEl4vg+K8vtFFUtIoTczxPjTfsFEuSpSCW3PR8PTG5ujoy9HIh8eP2JYR54BAMADYJ21+fqa
	q5uqrwh2KlKVcsoGXUt+j4Zy258mASEPFPEfbEDrobR43ScAAAAASUVORK5CYII=
}]

set TC [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAbklEQVQYGQXBgQBDMRAFsChU
	YQqn8BWqUIWncApTqEIVpjCFKXQJwLBEFAAQEcvL1AqgFY7jetAKpgfEcb1BQwCwfcBUBABx
	ASEAiAsIAUD8wMsiBijL1wExGBpsxxWUAKUN27ENjwZgiIiICfwBWf0kIYLYC6MAAAAASUVO
	RK5CYII=
}]

set Analysis [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAAnFBMVEUoLmwoLmwoLmwwYKIu
	VJUqPXw5UYwvX6EwYKIrQ4MvPXouWJkpOXgsSYkwYaMoLmxEaqQsS4tUi8JFbKUvX6FGbaYv
	W5wvX6EwYKJUi8JUi8Jbmc8vYKJal81al80mK2knLGonLWonLWsnLWsnLWsvX6EwYKImK2km
	K2knLGonLWonLWsnLWswYKIwYKJamM5amM1amM1al83///+31ACgAAAAMnRSTlMABwomNzo8
	QURITVZXWlpeX2BgY2Vla25wdnd+jpWWnZ2dnZ6fpLS1tra3uMXU6O3x8mnlvKoAAAABYktH
	RDM31XxeAAAAfUlEQVQIHQXB2wqCQBRA0X0uii8lQgQR0v//VCC+JEFgFkzqzGktoe33EEJ8
	nF1O96YJJKXL22WvewPysItCpQBagUIJgCjgVMvTAslLh4LJtK6TGDjZu3Qkd3PGsTR8P2xr
	MkwOcePc+jXVs4duj9fCr2waQttnDaTYOP8BNs03vf+FovoAAAAASUVORK5CYII=
}]

set Composition [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAeUlEQVQoz42QwQ3DMAwDr10g
	k/TFWbSC1+lbO2Un9lEhMFw7LgHBMEhJ0MF/chXPReAAXsBbkiUtYhEpyYDrTSKy3zBKVxBS
	kgVura0byhin6v6GCIBH1a20WK0dJQBa5vd46ZzTKUIdAXcgzM7o/tMGz3j/TN8agz5FxUEL
	p2duhQAAAABJRU5ErkJggg==
}]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace eventmodebox

# vi:set ts=3 sw=3:
