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

::util::source eco-selection-box

proc ecobox {w args} {
	return [::ecobox::Build $w {*}$args]
}


namespace eval ecobox {
namespace eval mc {

set OpenEcoDialog "Open ECO dialog"

}


bind EcoBoxFrame <Destroy>		[list namespace delete [namespace current]::%W]
bind EcoBoxFrame <Destroy>		{+ rename %W {} }
bind EcoBoxFrame <FocusIn>		{ focus [tk_focusNext %W] }

bind EcoBoxFrame <<TraverseIn>> {
	%W.entry instate {!readonly !disabled} {
		%W.entry selection range 0 3
		%W.entry icursor 3
	}
}


proc Build {w variant args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Content

	array set opts {
		-textvar {}
		-textvariable {}
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	ttk::frame $w -borderwidth 0 -takefocus 0 -class EcoBoxFrame
	ttk::entry $w.entry \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-width 4 \
		-validate key \
		-validatecommand [namespace code { ValidateEco %P %S }] \
		-invalidcommand { bell } \
		-cursor xterm \
		;
	grid $w.entry -row 0 -column 0 -sticky ew
	grid columnconfigure $w {0} -weight 1
	if {$variant eq "Normal" && [llength [namespace which -command openEcoDialog]]} {
		set linespace [font metrics [$w.entry cget -font] -linespace]
		set size [expr {$linespace >= 16 ? 16 : 12}]
		ttk::button $w.eco \
			-style icon.TButton \
			-image [set icon::${size}x${size}::dialog] \
			-command [namespace code [list OpenEcoDialog $w]] \
			;
		grid $w.eco -row 0 -column 2 -sticky wns
		grid columnconfigure $w {1} -minsize $::theme::padx
		tooltip $w.eco [namespace current]::mc::OpenEcoDialog
	}

	bind $w.entry <Any-Key> [namespace code [list Completion $w.entry %A %K $opts(-textvariable)]]
	bind $w.entry <<LanguageChanged>> \
		[namespace code [list LanguageChanged $w.entry $opts(-textvariable)]]

	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc tooltip {args} {}


proc OpenEcoDialog {w} {
	set eco [openEcoDialog $w]
	if {[string length $eco]} { $w set $eco }
}


proc WidgetProc {w command args} {
	switch -- $command {
		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace curent] bind <tag> ?<sequence>? ?<script?>\""
			}
			bind $w.entry {*}$args
			return
		}

		cget {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace curent] cget <option>\""
			}
			if {[lindex $args 0] eq "-takefocus"} {
				$w.entry instate disabled { return 0 }
				return 1
			}
		}

		valid? {
			set value [string range [$w.entry get] 0 2]
			return [regexp {([A-E][0-9][0-9])?} $value]
		}

		value {
			return [string range [$w.entry get] 0 2]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set var [$w.entry cget -textvariable]
			set $var [lindex $args 0]
			Completion2 $w.entry $var no
			return $w
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace curent] $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.entry instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}
	}

	return [$w.entry $command {*}$args]
}


proc LanguageChanged {w var} {
	Completion2 $w $var no
}


proc ValidateEco {eco key} {
	switch [string length $eco] {
		0 { return 1 }
		1 { return [expr {$eco eq " " || [string match {[A-Ea-e]} $eco]}] }
		2 { return [string match {[A-Ea-e][0-9]} $eco] }
		3 { return [string match {[A-Ea-e][0-9][0-9]} $eco] }
	}

	return 0
}


proc Completion {w code sym var} {
	if {$sym eq "Tab"} {
		after idle [namespace code [list Completion2 $w $var no]]
	} elseif {$sym in {BackSpace Delete}} {
		$w delete 3 end
	} elseif {[string is alnum -strict $code] || $code eq " "} {
		$w delete 3 end
		after idle [namespace code [list Completion2 $w $var yes]]
	}
}


proc Completion2 {w var selection} {
	set content [string trimleft [string toupper [set $var] 0 1]]
	set len [string length $content]

	if {$len == 0} {
		set $var ""
	} elseif {[string length $content] >= 3} {
		set content [string range $content 0 2]
		set opening [::scidb::app::lookup ecoCode $content]
		lassign $opening long short
		set vars [lrange $opening 2 end]
		append content " \u2013 "
		if {[llength $vars]} {
			append content [::mc::translateEco $short]
			append content ", " [::mc::translateEco [lindex $vars end]]
		} else {
			append content [::mc::translateEco $long]
		}
		set $var $content
		if {$selection} { $w selection clear }
	} else {
		set $var [string range $content 0 2]
	}
}


namespace eval icon {
namespace eval 12x12 {

set dialog [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABJlBMVEUAAAAAAAAJe7UIcacHerQI
	erQIe7QJe7QKfLUNZLkOfrYQf7YRZ7wTab4Tar8UgbYVgbYVgbcWgrgXgrg3nds4nds5ndt5en17
	fX9+gIN/goSBgoSBg4WEhoiEhoqFh4mGh4qHiYuHiYyHioyJio2JjI6Ki46KjJCLjZGMjpGNkJOO
	kJKPkJSQkZSQkpSQk5aTlZmUlZmVl5iVl5qYmpyZm52Zzeyazeye0O+23fW/vbzIxsbQzMzW1NLg
	3d3h3tzh4eHj4uDj4uLj4+Pk4d7k4+Pk5OTn5ebr5uTs6+rv7Ojw8fHx8PD09PP18e/18/D19PP1
	9fX19vb28ez29/b3+Pf49fL5+vn7+fn8/fz9+/j9/v39/v7/+vX/+vj//v3///z///+pwotmAAAA
	c0lEQVQI12NgEhbkF4AAJgYhCzMzcwgQYuAWgwNuBo5EOOBgYLN3cXRydQOCRDYGNg8+KxVZSXEJ
	aRDHK9jfNygkNDQExPHjtdZVl5OSUQJyWMNioyJjwAawMrDE8dgY6ajJKmgksjCwIIxmYWDmYmeB
	AQDbNRr4oMGO8QAAAABJRU5ErkJggg==
}]

} ;# namespace 12x12
namespace eval 16x16 {

set dialog [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABJlBMVEUAAAAAAAAJe7UIcacHerQI
	erQIe7QJe7QKfLUNZLkOfrYQf7YRZ7wTab4Tar8UgbYVgbYVgbcWgrgXgrg3nds4nds5ndt5en17
	fX9+gIN/goSBgoSBg4WEhoiEhoqFh4mGh4qHiYuHiYyHioyJio2JjI6Ki46KjJCLjZGMjpGNkJOO
	kJKPkJSQkZSQkpSQk5aTlZmUlZmVl5iVl5qYmpyZm52Zzeyazeye0O+23fW/vbzIxsbQzMzW1NLg
	3d3h3tzh4eHj4uDj4uLj4+Pk4d7k4+Pk5OTn5ebr5uTs6+rv7Ojw8fHx8PD09PP18e/18/D19PP1
	9fX19vb28ez29/b3+Pf49fL5+vn7+fn8/fz9+/j9/v39/v7/+vX/+vj//v3///z///+pwotmAAAA
	s0lEQVQYGQXBIU4DQRQA0Dczf2nrINwA2qQCCKIHwOAxJD0iigNwACweUYXCkCBadrMzw3spX7SW
	AD3nnzjfNAnQ5c8Y0yElQO+bMep2CwAf0RyGmkpCre26Bav3m+9xbqlErAny43w55KTXqRHE293v
	dJrz2SJdEd3yqfYyYJpHPbrl6/1xmk5luUhbPcjPABpBetn9zdMxVkO6JQp7AJQovOy+AA9KYG8N
	QCqLWgGUMv4Doyw/M/TPkLwAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon

} ;# namespace ecobox

# vi:set ts=3 sw=3:
