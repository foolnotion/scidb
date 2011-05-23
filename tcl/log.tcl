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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval log {
namespace eval mc {

set LogTitle		"Log"
set Warning			"Warning"
set Error			"Error"
set Information	"Info"

}


array set colors {
	warning	darkgreen
	error		darkred
	info		black
}


proc warning {args}	{ Print Warning 1 {*}$args }
proc error {args}		{ Print Error 1 {*}$args }
proc info {args}		{ Print Information 0 {*}$args }


proc open {callee {show 1}} {
	variable Priv

	if {![winfo exists .log]} { Open }

	set Priv(callee) $callee
	set Priv(show) $show
	set Priv(delay) 0
	set Priv(force) 0
	set t .log.top.text

	if {[$t count -chars 1.0 2.0] > 1} {
		$t configure -state normal
		$t insert end "\n"
		$t configure -state disabled
		$t yview moveto 1.0
	}
}


proc close {} {
	variable Priv

	if {$Priv(hide)} {
		set Priv(hide) 0
		set Priv(delay) 0
	} elseif {$Priv(delay)} {
		set Priv(delay) 0
		if {$Priv(force)} {
			set Priv(force) 0
			Show
		}
	}

	update idle
	.log.top.text yview moveto 1.0
}


proc show {} {
	variable Priv

	if {![winfo exists .log]} { Open }
	set Priv(show) 1
	set Priv(delay) 0
	Show
}


proc delay {{flag 1}} {
	set [namespace current]::Priv(delay) $flag
}


proc hide {{flag 1}} {
	set [namespace current]::Priv(hide) $flag
}


proc exists	{} { return [winfo exists .log] }


proc Show {} {
	variable Priv

	if {$Priv(delay)} { return }

	update idle

	switch [wm state .log] {
		withdrawn - iconic {
			if {$Priv(center)} {
				set parent .application
				if {![winfo exists $parent]} { set parent . }
				::util::place .log center $parent
				set Priv(center) 0
			}
			wm deiconify .log
		}
	
		default {
			if {$Priv(show) && $Priv(visibility) ne "VisibilityUnobscured"} {
				wm deiconify .log
				raise .log
				focus .log
			}
		}
	}

	after idle [focus .log.close]
}


proc Print {type show args} {
	variable Priv

	switch [llength $args] {
		1 {
			set msg [lindex $args 0]
		}
		2 {
			open [lindex $args 0] 0
			set msg [lindex $args 1]
		}
		default {
			set msg $args
		}
	}

	switch $type {
		Warning - Error {
			set Priv(force) 1
			if {$show || $Priv(show)} {
				Show
				set Priv(show) 0
			}
		}
	}

	if {![winfo exists .log]} { Open }

	set t .log.top.text
	$t configure -state normal
	if {[$t count -chars 1.0 2.0] > 1} { $t insert end "\n" }

	if {[string length $Priv(callee)]} {
		$t insert end "\[$Priv(callee)\] " Callee
	}

	if {[string range $msg 0 0] eq "\{"} {
		foreach entry $msg {
			set tag {}
			lassign $entry m tag
			$t insert end $m {*}$tag $type
		}
	} else {
		$t insert end $msg $type
	}

	$t configure -state disabled
	$t yview moveto 1.0

}


proc Clear {} {
	variable Priv

	set t .log.top.text
	$t configure -state normal
	$t delete 1.0 end
	$t configure -state disabled
}


proc Visibility {state} {
	set [namespace current]::Priv(visibility) $state
}


proc Open {} {
	variable Priv
	variable colors

	set dlg .log
	toplevel $dlg -class $::scidb::app
	wm protocol $dlg WM_DELETE_WINDOW [list wm withdraw $dlg]
	if {[tk windowingsystem] ne "win32" && [winfo viewable .application]} {
		wm transient $dlg .application
	}
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes -padx $::theme::padx -pady $::theme::pady
	set log [text $top.text \
		-wrap none \
		-state disabled \
		-height 10 \
		-width 70 \
		-takefocus 0 \
		-setgrid 1 \
		-yscrollcommand [list $top.ybar set] \
		-xscrollcommand [list $top.xbar set] \
		]
	bind $log <Visibility> [namespace code { Visibility %s }]
	ttk::scrollbar $top.ybar -command [list $log yview] -takefocus 0 -orient vertical
	ttk::scrollbar $top.xbar -command [list $log xview] -takefocus 0 -orient horizontal
	grid $top.text  -row 0 -column 0 -sticky nsew
	grid $top.xbar -row 1 -column 0 -sticky nsew
	grid $top.ybar -row 0 -column 1 -sticky nsew
	grid rowconfigure $top 0 -weight 1
	grid columnconfigure $top 0 -weight 1
	$log tag configure Warning -foreground $colors(warning)
	$log tag configure Error -foreground $colors(error)
	$log tag configure Info -foreground $colors(info)
	$log tag configure Callee -foreground #88681a
	$log tag configure hyperlink -underline on -foreground blue
	$log tag configure link -foreground blue
	widget::dialogButtons $dlg {clear close} close no
	$dlg.close configure -command [list wm withdraw $dlg]
	$dlg.clear configure -command [namespace code Clear]
	wm protocol $dlg WM_DELETE_WINDOW [list wm withdraw $dlg]
	wm withdraw $dlg
	wm title $dlg "$::scidb::app - $mc::LogTitle"
	wm minsize $dlg 50 5
	set Priv(visibility) VisibilityFullyObscured
	set Priv(show) 0
	set Priv(force) 0
	set Priv(delay) 0
	set Priv(hide) 0
	set Priv(center) 1
}

} ;# namespace log

# vi:set ts=3 sw=3:
