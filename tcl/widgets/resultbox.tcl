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

::util::source result-selection-box

proc resultbox {w args} {
	return [::resultbox::Build $w {*}$args]
}


namespace eval resultbox {

variable results { "*" "1-0" "1/2" "0-1" "0-0" }


proc minWidth {} {
	return 4
}


proc Build {w args} {
	variable results

	namespace eval [namespace current]::${w} {}
	variable ${w}::Content ""
	variable ${w}::Map

	array set opts {
		-textvar			{}
		-textvariable	{}
		-width			0
		-excludelost	no
		-skipspace		no
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	if {$opts(-excludelost)} {
		set keys {1 = 0 *}
		set values [lrange $results 0 end-1]
	} else {
		set keys {1 = 0 \u2013 *}
		set values $results
	}
	foreach key $keys value $results {
		switch $key {
			1			{ set tip ::terminationbox::mc::Result(1-0) }
			0			{ set tip ::terminationbox::mc::Result(0-1) }
			=			{ set tip ::terminationbox::mc::Result(1/2-1/2) }
			\u2013	{ set tip ::terminationbox::mc::Result(0-0) }
			*			{ set tip ::mc::Unknown }
		}
		lappend hints $key $tip
		set Map($key) $value
	}

	ttk::frame $w -borderwidth 0 -takefocus 0
	bind $w <FocusIn> { focus [tk_focusNext %W] }
	ttk::combobox $w.__w__ \
		-width [expr {max([minWidth], $opts(-width))}] \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-values $values \
		-validate key \
		-validatecommand { return [regexp {^[*012/=-]*$} %P] } \
		-invalidcommand bell \
		;
	if {$opts(-skipspace)} {
		bind $w.__w__ <Key-space> [list after idle [namespace code { SkipSpace %W }]]
	}
	$w.__w__ current 0
	keybar $w.hint $hints
	bind $w.hint <<KeybarPress>> [namespace code [list Invoke $w %d]]

	grid $w.__w__ -column 0 -row 0 -sticky ns
	grid $w.hint  -column 2 -row 0 -sticky ns
	grid columnconfigure $w 1 -minsize $::theme::padding

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [list after idle [namespace code { Select %W %A }]]

	catch { rename ::$w $w.__resultbox__ }
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
				error "wrong # args: should be \"[namespace current] $command <tag> ?<sequence>? ?<script?>\""
			}
			bind $w.__w__ {*}$args
			return
		}

		focus {
			return [focus $w.__w__]
		}

		valid? {
			variable results
			set result [$w.__w__ get]
			if {$result eq "1/2"} { return 1 }
			return [expr {[lsearch -exact $results $result] >= 0}]
		}

		value {
			set result [$w.__w__ get]
			if {$result eq "1/2"} { return "1/2-1/2" }
			return $result
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <string>"
			}
			set result [lindex $args 0]
			if {$result eq "1/2-1/2"} { set result "1/2" }
			variable results
			set index [lsearch -exact $results $result]
			if {$index == -1} {
				set args [join $results ", "]
				error "wrong arg '$result'; should be one of \{$args\}"
			}
			$w.__w__ current $index
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


proc Invoke {w key} {
	variable ${w}::Map
	variable results

	focus $w
	set i [lsearch $results $Map($key)]
	$w current [expr {($i + 1) % [llength [$w cget -values]]}]
}


proc Select {w key} {
	if {[string length [$w get]] != 1} { return }

	set index -1

	switch -- $key {
		"*" { set index 0 }
		"1" { set index 1 }
		"=" { set index 2 }
		"0" { set index 3 }
		"-" { set index 4 }
	}

	if {0 <= $index && $index < [llength [$w cget -values]]} {
		$w current $index

		if {$key eq "0" || $key eq "1"} {
			$w selection clear
			$w selection range insert end
		} else {
			$w icursor end
		}
	}
}


proc SkipSpace {w} {
	if {[$w get] == " " || [string length [$w get]] == 0} {
		$w delete 0 end
		$w insert end "*"
		tk::TabToWindow [tk_focusNext $w]
	}
}

} ;# namespace resultbox

# vi:set ts=3 sw=3:
