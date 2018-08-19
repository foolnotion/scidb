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
# Copyright: (C) 2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source key-bar

proc keybar {w {keys {}}} {
	return [keybar::Build $w $keys]
}

namespace eval keybar {

proc tr {text} { return $text }
proc defaultCSS {} { return "" }


proc Build {w keys} {
	namespace eval [namespace current]::$w {}
	set css [defaultCSS]
	append css "
		kbd.key {
			font-size: smaller;
			border-width: 0.2em;
			border-style: solid;
			border-color: #dddddd #bbbbbb #bbbbbb #dddddd;
			padding: 0;
			background: #eeeeee;
			white-space: nowrap;
		}
		body { padding: 0; border: 0; margin: 0; display: block; }"
	::html $w \
		-width 0 \
		-background [::theme::getColor background] \
		-usehorzscroll no \
		-usevertscroll no \
		-fontsize [expr {abs([font configure TkTextFont -size])}] \
		-fittowidth yes \
		-fittoheight no \
		-css $css \
		;
	bind $w <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
	$w onmouseover [list [namespace current]::MouseEnter $w]
	$w onmouseout  [namespace current]::MouseLeave
	catch { rename ::$w $w.__html__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"
	$w keys $keys
	return $w
}


proc WidgetProc {w command args} {
	if {$command ne "keys"} {
		return [$w.__html__ $command {*}$args]
	}
	if {[llength $args] != 1} {
		error "wrong # args: should be \"[namespace current] $command <list-of-key-tip-pairs>\""
	}
	variable ${w}::Keys
	set Keys [lindex $args 0]
	set content ""
	foreach {key tip} $Keys {
		append content "<kbd class='key' tip='$tip'>[tr $key]</kbd>"
	}
	if {[string length $content] == 0} {
		$w.__html__ clear
	} else {
		$w.__html__ parse $content
	}
	return $w
}


proc LanguageChanged {w} {
	variable ${w}::Keys
	$w keys $Keys
}


proc MouseEnter {w nodes} {
	foreach node $nodes {
		if {[$node tag] eq "kbd"} {
			set tip [set [$node attribute tip]]
			if {[string length $tip]} {
				tooltip show $w $tip
			}
			return
		}
	}
}


proc MouseLeave {nodes} { tooltip hide }

} ;# namespace keybar

# vi:set ts=3 sw=3:
