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

proc ratingbox {w args} {
	return [::ratingbox::Build $w {*}$args]
}


namespace eval ratingbox {

namespace import ::tcl::mathfunc::max


set ratings(all) {Elo DWZ ECF IPS USCF ICCF Rapid Rating}
set ratings(sci) {DWZ ECF IPS USCF ICCF Rapid Rating}
set ratings(si3) {Elo DWZ ECF USCF ICCF Rapid Rating}
set ratings(si4) $ratings(si3)


proc Build {w args} {
	variable ratings

	namespace eval [namespace current]::${w} {}
	variable ${w}::Type ""
	variable ${w}::Rating
	variable ${w}::Ratings
	variable ${w}::Format

	array set opts {
		-textvar {}
		-textvariable {}
		-state normal
		-format sci
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Rating
	}
	if {$opts(-format) eq "sci"} {
		set Ratings $ratings(sci)
	} else {
		set Ratings $ratings($opts(-format))
	}
	set Format $opts(-format)

	set maxlen 0
	foreach type $Ratings {
		set maxlen [max $maxlen [string length $type]]
	}

	ttk::frame $w -borderwidth 0 -takefocus 0
	ttk::tcombobox $w.__w__ \
		-width $maxlen \
		-exportselection no \
		-state $opts(-state) \
		-textvariable $opts(-textvariable) \
		;
	pack $w.__w__ -side left

	$w.__w__ addcol text -id type
	foreach type $Ratings {
		$w.__w__ listinsert [list $type]
	}
	$w.__w__ resize
	$w.__w__ current 0

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [list after idle [namespace code [list Select %W %A %K $opts(-textvariable)]]]
	bind $w.__w__ <<ComboboxSelected>> [list event generate $w <<ComboboxSelected>> -when mark]
	bind $w.__w__ <<ComboboxPosted>> [list event generate $w <<ComboboxPosted>> -when mark]
	bind $w.__w__ <<ComboboxUnposted>> [list event generate $w <<ComboboxUnposted>> -when mark]

	catch { rename ::$w $w.__ratingbox__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		cget {
			switch -- [lindex $args 0] {
				-takefocus	{ return 0 }
				-format		{ return [set ${w}::Format] }
			}
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			bind $w.__w__ {*}$args
			return
		}

		value {
			return [$w.__w__ get]
		}

		valid? {
			return [expr {[lsearch [$w.__w__ cget -values] [$w.__w__ get]] >= 0}]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set [$w.__w__ cget -textvariable] [lindex $args 0]
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


proc Select {w key sym var} {
	if {![info exists [winfo parent $w]::Ratings]} { return }

	variable [winfo parent $w]::Ratings

	if {[string is integer -strict $key]} {
		if {$key < [llength $Ratings]} {
			$w current $key
			$w icursor end
		}
	} elseif {[string is alpha -strict $key]} {
		set content [set $var]
		set i ""
		set n ""
		foreach rating $Ratings {
			if {[string match -nocase ${content}* $rating]} {
				set n $i
				set i $rating
			}
		}
		if {[string length $i] && [string length $n] == 0} {
			$w set $i
			$w selection clear
			$w selection range insert end
		}
	}
}

} ;# namespace ratingbox

# vi:set ts=3 sw=3:
