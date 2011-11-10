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

proc countrybox {w args} {
	return [::countrybox::Build $w {*}$args]
}


namespace eval countrybox {

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Content ""
	variable ${w}::Key ""
	variable ${w}::IgnoreKey 0

	array set opts {
		-height			15
		-width			47
		-textvar			{}
		-textvariable	{}
		-state			normal
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	set f TkTextFont
	set bold [list [font configure $f -family] [font configure $f -size] bold]

	ttk::tcombobox $w \
		-height $opts(-height) \
		-showcolumns {name code} \
		-format "%1 (%2)" \
		-empty {0} \
		-width $opts(-width) \
		-textvariable $opts(-textvariable) \
		-scrollcolumn name \
		-exportselection no \
		-disabledbackground #ebf4f5 \
		-disabledforeground black \
		-disabledfont $bold \
		-state $opts(-state) \
		;

	$w addcol text  -id code -foreground darkgreen -font TkFixedFont -width 3 -justify center
	$w addcol text  -id iso  -foreground darkred -font TkFixedFont -width 3 -justify center
	$w addcol image -id flag -width 20 -justify center
	$w addcol text  -id name

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w <<ComboBoxPosted>> [list set [namespace current]::${w}::IgnoreKey 1]
	bind $w <<ComboBoxUnposted>> [list set [namespace current]::${w}::IgnoreKey 0]
	bind $w <<ComboBoxUnposted>> +[list set [namespace current]::${w}::Key ""]
	bind $w <<ComboboxCurrent>> [namespace code [list ShowCountry $w]]
	bind $w <<LanguageChanged>> [namespace code [list LanguageChanged $w]]

	SetupList $w

	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			return [bind $w {*}$args]
		}

		value {
			set code [$w.__w__ get [$w.__w__ current] code]
			if {$code eq "UNK"} { return "" }
			return $code
		}

		valid? {
			return [expr {[$w.__w__ find [$w.__w__ get]] >= 0}]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set var [$w.__w__ cget -textvariable]
			set $var [lindex $args 0]
			Search $w $var 1
			ShowCountry $w
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


proc SetupList {w} {
	set index -1

	foreach region $::country::regions {
		if {$region ne "--"} {
			$w listinsert [list [set ::country::mc::$region] {} {} {}] \
				-types {text} -span {code 4} -enabled no -index [incr index]
		}
		set list {}
		foreach entry $::country::region($region) {
			lassign $entry code iso1 iso2 region active name
			if {$iso1 eq "--"} { set iso1 "" }
			set options {}
			if {!$active} {
				lappend options -foreground grey60
			}
#			elseif {$iso1 eq ""} {
#				lappend options -foreground darkblue
#			}
			set country [set ::country::mc::$name]
			set flag $::country::icon::flag($code)
			lappend list [list [::mc::mapForSort $country] $code $iso1 $flag $country $options]
		}
		set list [lsort -index 0 -dictionary $list]
		foreach entry $list {
			lassign $entry _ code iso1 flag country options
			$w listinsert [list $code $iso1 $flag $country] {*}$options -index [incr index]
		}
	}

	$w resize -force
	$w current 0
	$w mapping [::mc::mappingForSort] [::mc::mappingToAscii]
}


proc LanguageChanged {w} {
	set content [$w get]
	set code ""

	if {[string length $content] && [$w find $content] >= 0} {
		set code [string range $content end-3 end-1]
	}

	SetupList $w

	if {[string length $code] == 0} {
		$w current 0
	} else {
		$w current search code $code
	}

	if {[string length $content] && [string length [$w get]] == 0} {
		$w set $content
	}

	$w icursor end
}


proc Completion {w code sym var} {
	if {![info exists ${w}::IgnoreKey]} { return }
	variable ${w}::IgnoreKey

	if {$IgnoreKey} { return }

	switch -- $sym {
		Tab {
			set $var [string trimleft [set $var]]
			Search $w $var 1
			ShowCountry $w
		}

		default {
			if {[string is alnum -strict $code] || [string is punct -strict $code] || $code eq " "} {
				after idle [namespace code [list Completion2 $w $var [set $var]]]
			} else {
				after idle [namespace code [list ShowCountry $w]]
			}
		}
	}
}


proc Completion2 {w var prevContent} {
	set content [string trimleft [set $var]]

	if {	[string length $content]
		&& (	[string range $content 0 end-1] eq $prevContent
			|| [string match {*([A-Z][A-Z][A-Z])} $prevContent])} {
		Search $w $var 0
	}

	ShowCountry $w
}


proc Search {w var full} {
	set content [set $var]
	if {[llength $content] == 0} { return }

	if {[string length $content] == 2 && [string tolower $content] eq $content} {
		$w current match iso $content
		$w icursor end
	} elseif {[string length $content] == 3 && [string toupper $content] eq $content} {
		$w current match code [::scidb::app::lookup countryCode $content]
		$w icursor end
	} elseif {	[string length $content] > 1
				&& [string is upper [string index $content 0]]
				&& [string is lower [string index $content 1]]} {
		if {$full} {
			$w current search name $content
		} else {
			$w current match name $content
			set newContent [$w get]
			
			if {$content ne $newContent} {
				set k 0
				set j 0
				set n [string length $content]
				while {$j < $n} {
					set c [string index $newContent $k]

					if {$c eq [string index $content $j]} {
						incr j
					} else {
						incr j [string length [::mc::mapForSort $c]]
					}

					incr k
				}

				$w icursor $k
				$w selection clear
				$w selection range $k end
			}
		}
	}
}


proc ShowCountry {cb} {
	set content [$cb get]
	if {[string length $content]} {
		if {[$cb find $content] >= 0} {
			set code [string range $content end-3 end-1]
			if {[info exists ::country::icon::flag($code)]} {
				if {[$cb placeicon $::country::icon::flag($code)]} {
					return
				}
			}
		}
	}

	$cb forgeticon
}

} ;# namespace countrybox

# vi:set ts=3 sw=3:
