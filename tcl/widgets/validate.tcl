# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2008-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval validate {
namespace eval mc {

set Unlimited "unlimited"

}

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::int


proc spinboxInt {w args} {
	array set opts { -clamp 1 -vcmd {} -unlimited 0 }
	array set opts $args
	set min [expr {int([$w cget -from])}]
	set max [expr {int([$w cget -to])}]
	set len [max [string length $min] [string length $max]]
	if {$opts(-unlimited)} {
		incr min -1
		$w configure -from $min
	}
	if {$min < 0} {
		set vcmd [namespace code [list ValidateInteger $w %P $len $opts(-vcmd) $opts(-unlimited)]]
	} else {
		set vcmd [namespace code [list ValidateUnsigned $w %P $len $opts(-vcmd) $opts(-unlimited)]]
	}
	$w configure -validatecommand $vcmd -invalidcommand { bell }
	if {$opts(-clamp) || $opts(-unlimited)} {
		bind $w <FocusOut> +[namespace code [list ClampInt %W $opts(-unlimited)]]
	}
	bind $w <FocusOut> {+ %W selection clear }
	bind $w <FocusOut> +[namespace code [list SendData $w $opts(-unlimited)]]
	bind $w <FocusIn>  {+ %W configure -validate key }
	if {$opts(-unlimited)} {
		bind $w <ButtonRelease-1> [namespace code { CheckMinValue %W %x %y }]
		$w set ""
	}
	ClampInt $w $opts(-unlimited)
}


proc spinboxDouble {w args} {
	array set opts { -clamp 1 -vcmd {} }
	array set opts $args
	set min [$w cget -from]
	set max [$w cget -to]
	set vcmd [namespace code { validateDouble %P $opts(-vcmd) }]
	$w configure -validatecommand $vcmd -invalidcommand { bell }
	if {$opts(-clamp)} {
		bind $w <FocusOut> +[namespace code { ClampDouble %W }]
	}
	bind $w <FocusOut> {+ %W selection clear }
	bind $w <FocusOut> +[namespace code { SendData %W }]
	bind $w <FocusIn>  {+ %W configure -validate key }
}


proc entryDouble {w} {
	$w configure -validatecommand [namespace code { validateDouble %P }] -invalidcommand { bell }
	bind $w <FocusOut> +[namespace code { formatDouble %W }]
	bind $w <FocusOut> {+ %W selection clear }
	bind $w <FocusOut> +[namespace code { SendData %W }]
	bind $w <FocusIn>  {+ %W configure -validate key }
}


proc entryUnsigned {w} {
	$w configure -validatecommand [namespace code { validateUnsigned %P }] -invalidcommand { bell }
	bind $w <FocusOut> +[namespace code { formatUnsigned %W }]
	bind $w <FocusOut> {+ %W selection clear }
	bind $w <FocusOut> +[namespace code { SendData %W }]
	bind $w <FocusIn>  {+ %W configure -validate key }
}


proc validateUnsigned {value maxlen} {
	set valid 1
	set value [string trim $value]
	if {	[string length $value] > $maxlen
		|| ![regexp {[0-9]*} $value result]
		|| [string length $value] != [string length $result]} {
		set valid 0
	}
	return $valid
}


proc validateInteger {value maxlen} {
	set valid 1
	set value [string trim $value]
	if {	[string length $value] > $maxlen
		|| ![regexp {[+-]?[0-9]*} $value result]
		|| [string length $value] != [string length $result]} {
		set valid 0
	}
	return $valid
}


proc validateDouble {value {callback {}}} {
	set valid 1
	set value [string trim $value]
	if {	![regexp {[0-9]*[.,]?[0-9]*} $value result]
		|| [string length $value] != [string length $result]} {
		set valid 0
	}
	if {[llength $callback]} { {*}$callback $value $valid }
	return $valid
}


proc formatDouble {w} {
	set var [$w cget -textvariable]
	if {![info exists $var]} { return }

	set val [string trimleft [string trim [set $var]] "0"]
	set val [string map {, .} $val]

	if {[string length $val] == 0} {
		set val "0"
	} else {
		if {[string index $val 0] eq "."} { set val "0$val" }
		if {[string index $val end] eq "."} { set val [string range $val 0 end-1] }
	}

	if {[set $var] ne $val} { set $var $val }
}


proc ValidateUnsigned {w value maxlen callback unlimited} {
	set valid 1
	set value [string trim $value]
	if {[string length $value] == 0} {
		set valid 1
	} elseif {	([string length $value] > $maxlen && !$unlimited)
				|| ![regexp {[0-9]*} $value result]
				|| [string length $value] != [string length $result]} {
		set valid 0
	}
	if {[llength $callback]} { {*}$callback $value $valid }
	return $valid
}


proc ValidateInteger {w value maxlen callback unlimited} {
	set valid 1
	set value [string trim $value]
	if {[string length $value] == 0} {
		set valid 1
	} elseif {	([string length $value] > $maxlen && !$unlimited)
				|| ![regexp {[+-]?[0-9]*} $value result]
				|| [string length $value] != [string length $result]} {
		set valid 0
	}
	if {[llength $callback]} { {*}$callback $value $valid }
	return $valid
}


proc CheckMinValue {w x y} {
	set value [string trim [$w get]]

	switch -exact [$w identify $x $y] {
		uparrow {
			if {![string is integer -strict $value] || int([$w cget -from]) == $value} {
				set value [expr {int([$w cget -from] + 1)}]
				$w set $value
			}
		}
		downarrow {
			if {![string is integer -strict $value] || int([$w cget -from]) == $value} {
				$w set "\u221e"
			}
		}
	}

	SendData $w 1
}


proc SendData {w {unlimited 0}} {
	set value [string trim [$w get]]
	if {$unlimited && ![string is integer -strict $value]} { set value [$w cget -from] }
	event generate $w <<ValueChanged>> -data $value
}


proc ClampInt {w {unlimited 0}} {
	set var [$w cget -textvariable]
	if {![info exists $var]} { return }

	set val [string trim [set $var]]
	if {$val ne "0"} { set val [string trimleft $val "0"] }

	if {![string is integer -strict $val]} {
		set val ""
	}

	if {[string length $val] == 0} {
		set val 0

		if {$unlimited} {
			$w set "\u221e"
			return
		}
	}

	set min [expr {int([$w cget -from])}]

	if {$unlimited && $val == [$w cget -from]} {
		$w set "\u221e"
		return
	}

	set max [expr {int([$w cget -to])}]

	if {$val < $min} {
		set val $min
	} elseif {$val > $max} {
		if {$unlimited} {
			$w set "\u221e"
			return
		}
		set val $max
	}

	if {[set $var] != $val} { set $var $val }
}


proc ClampDouble {w} {
	set var [$w cget -textvariable]
	if {![info exists $var]} { return }

	set min [$w cget -from]
	set max [$w cget -to]
	set val [string trimleft [string trim [set $var]] "0"]

	if {$val == ""} { set val 0.0 }

	if {$val < $min} {
		set val $min
	} elseif {$val > $max} {
		set val $max
	}

	if {[set $var] != $val} { set $var $val }
}

} ;# namespace validate

# vi:set ts=3 sw=3:
