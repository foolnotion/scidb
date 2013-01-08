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
# Copyright: (C) 2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source registerbutton

namespace eval ttk {

proc registerbutton {w args} {
	return [registerbutton::Build $w {*}$args]
}

namespace eval registerbutton {

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	array set opts {
		-command			{}
		-textvariable	{}
		-text				""
		-value			""
		-variable		{}
		-padx				{}
	}
	array set opts $args
	if {[info exists opts(-textvar)]} { set opts(-textvariable) $opts(-textvar) }

	set Vars(value) $opts(-value)
	set Vars(variable) $opts(-variable)
	set Vars(command) $opts(-command)

	if {[llength $Vars(variable)]} {
		set Vars(tracecmd) [list variable $Vars(variable) write [namespace code [list Configure $w]]]
		trace add {*}$Vars(tracecmd)
	}

	set args {}
	if {[llength $opts(-textvariable)]} {
		lappend args -textvariable $opts(-textvariable)
	} else {
		lappend args -text $opts(-text)
	}
	if {[llength $opts(-padx)]} {
		lappend args -padx $opts(-padx)
	}

	tk::button $w {*}$args \
		-background [::theme::getBackgroundColor] \
		-takefocus 0 \
		;
	::scidb::tk::misc setClass $w Registerbutton
	if {[llength $Vars(variable)]} { Configure $w }

	catch { rename ::$w $w.__w__ }
	bind $w <Destroy> [namespace code [list Destroy $w]]
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	variable ${w}::Vars

#	switch -- $command {
#	}

	return [$w.__w__ $command {*}$args]
}


proc Configure {w args} {
	variable ${w}::Vars

	if {[set $Vars(variable)] eq $Vars(value)} {
		set relief sunken
		set bg [::theme::getSelectBackgroundColor]
		set fg [::theme::getSelectForegroundColor]
	} else {
		set relief raised
		set bg [::theme::getBackgroundColor]
		set fg [::theme::getForegroundColor]
	}

	$w configure -relief $relief -background $bg -foreground $fg
}


proc Destroy {w} {
	variable ${w}::Vars
	if {[info exists Vars(tracecmd)]} { trace remove {*}$Vars(tracecmd) }
	namespace delete [namespace current]::${w}
}


proc ButtonEnter {w} {
	if {[$w cget -state] ne "disabled"} {
		if {[$w cget -relief] eq "raised"} {
			$w configure -background [::theme::getActiveBackgroundColor]
		}
	}
}


proc ButtonLeave {w} {
	if {[$w cget -state] ne "disabled"} {
		if {[$w cget -relief] eq "raised"} {
			$w configure -background [::theme::getBackgroundColor]
		}
	}
}


proc ButtonSelect {w} {
	variable ${w}::Vars

	if {[$w cget -state] eq "disabled"} { return }
	if {[$w cget -relief] eq "sunken"} { return }

	if {[llength $Vars(variable)]} {
		set $Vars(variable) $Vars(value)
	} else {
		$w configure \
			-relief sunken \
			-background [::theme::getSelectBackgroundColor] \
			-foreground [::theme::getSelectForegroundColor] \
			;
	}

	if {[llength $Vars(command)]} { {*}$Vars(command) }
}

} ;# namespace registerbutton
} ;# namespace ttk


bind Registerbutton <Enter>			{ ttk::registerbutton::ButtonEnter %W }
bind Registerbutton <Leave>			{ ttk::registerbutton::ButtonLeave %W }
bind Registerbutton <ButtonPress-1>	{ ttk::registerbutton::ButtonSelect %W }

# vi:set ts=3 sw=3:
