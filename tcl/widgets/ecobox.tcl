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

proc ecobox {w args} {
	return [::ecobox::Build $w {*}$args]
}


namespace eval ecobox {

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Content
	variable ${w}::TextVar

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

	ttk::entry $w \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-width 4 \
		-validate key \
		-validatecommand [namespace code { ValidateEco %P %S }] \
		-invalidcommand { bell } \
		;

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w <<Language>> [namespace code [list LanguageChanged $w $opts(-textvariable)]]

	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace curent] bind <tag> ?<sequence>? ?<script?>\""
			}
			bind $w {*}$args
			return
		}

		cget {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace curent] cget <option>\""
			}
			if {[lindex $args 0] eq "-takefocus"} {
				$w.__w__ instate disabled { return 0 }
				return 1
			}
		}

		valid? {
			set value [string range [$w.__w__ get] 0 2]
			return [regexp {([A-E][0-9][0-9])?} $value]
		}

		value {
			return [string range [$w.__w__ get] 0 2]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set var [$w.__w__ cget -textvariable]
			set $var [lindex $args 0]
			Completion2 $w.__w__ $var no
			return $w
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace curent] $command <statespec> ?<script>?\""
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


proc LanguageChanged {w var} {
	Completion2 $w $var no
}


proc ValidateEco {eco key} {
	switch [string length $eco] {
		0 { return 1 }
		1 { return [string match {[A-Ea-e]} $eco] }
		2 { return [string match {[A-Ea-e][0-9]} $eco] }
		3 { return [string match {[A-Ea-e][0-9][0-9]} $eco] }
	}

	return 0
}


proc Completion {w code sym var} {
	if {$sym eq "Tab"} {
		after idle [namespace code [list Completion2 $w $var no]]
	} elseif {[string is alnum -strict $code]} {
		after idle [namespace code [list Completion2 $w $var yes]]
	}
}


proc Completion2 {w var selection} {
	set content [string toupper [set $var] 0 1]

	if {[string length $content] >= 3} {
		set content [string range $content 0 2]
		lassign [::scidb::app::lookup ecoCode $content] opening shortOpening variation subvar
		append content " \u2013 "
		if {[string length $variation]} {
			append content [::mc::translateEco $shortOpening]
			append content ", "
			append content [::mc::translateEco $variation]
			if {[string length $subvar]} {
				append content ", "
				append content [::mc::translateEco $subvar]
			}
		} else {
			append content [::mc::translateEco $opening]
		}
		set $var $content

		if {$selection} {
			$w selection clear
			$w selection range 3 end
		}
	} else {
		set $var [string range $content 0 2]
	}
}

} ;# namespace ecobox

# vi:set ts=3 sw=3:
