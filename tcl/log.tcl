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
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source log-dialog

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

variable Log .application.log


proc warning {args}	{ Print Warning 1 {*}$args }
proc error {args}		{ Print Error 1 {*}$args }
proc info {args}		{ Print Information 0 {*}$args }


proc newline {} {
	variable Log

	if {[winfo exists $Log]} {
		set t $Log.top.text
		$t configure -state normal
		$t insert end \n
		$t configure -state disabled
		$t yview moveto 1.0
	}
}


proc open {callee {show 1}} {
	variable Priv
	variable Log

	if {![winfo exists $Log]} { Open }
	if {[incr Priv(open)] > 1} { return }

	set Priv(callee) $callee
	set Priv(show) $show
	set Priv(delay) 0
	set Priv(force) 0
	set Priv(newline) 1
	set t $Log.top.text

	if {!$Priv(empty) && [$t count -chars 1.0 2.0] > 1} {
		$t configure -state normal
		$t insert end "\n"
		$t configure -state disabled
		$t yview moveto 1.0
	}

	set Priv(empty) 1
}


proc close {} {
	variable Priv
	variable Log

	if {[incr Priv(open) -1] > 0} { return }

	if {$Priv(newline)} {
		$Log.top.text delete end-1
	}

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

	update idletasks
	$Log.top.text yview moveto 1.0
	set Priv(callee) ""
}


proc show {{force 0}} {
	variable Priv
	variable Log

	if {![winfo exists $Log]} { Open }

	set Priv(show) 1
	set Priv(delay) 0

	if {![string is boolean -strict $force]} { set force 1 }
	if {$force} { set Priv(suppress) 0 }
	if {!$Priv(suppress)} { Show }
}


proc delay {{flag 1}} {
	set [namespace current]::Priv(delay) $flag
}


proc hide {{flag 1}} {
	set [namespace current]::Priv(hide) $flag
}


proc suppress {{flag 1}} {
	set [namespace current]::Priv(suppress) $flag
}


proc exists	{} { return [winfo exists $Log] }


proc finishLayout {} {
	::widget::dialogButtonSetIcons [set [namespace current]::Log]
}


proc Show {} {
	variable Priv
	variable Log

	if {$Priv(delay)} { return }

	update idletasks

	if {$Priv(transient)} {
		wm transient $Log .application
		set Priv(transient) 0
	}

	switch [wm state $Log] {
		withdrawn - iconic - icon {
			if {$Priv(center)} {
				raise $Log
				::util::place $Log -parent .application -position center
				focus $Log
				set Priv(center) 0
			}
			wm deiconify $Log
		}
	
		default {
			if {$Priv(show) && $Priv(visibility) ne "VisibilityUnobscured"} {
				if {[::fsbox::checkIsKDE]} {
					set geom [wm geometry $Log]
					if {[string length $geom]} {
						set geom [string range $geom [string first + $geom] end]
						catch { wm geometry $Log $geom }
					}
					wm withdraw $Log
				}
				wm deiconify $Log
				raise $Log
				focus -force $Log
			}
		}
	}

	focus $Log.close
}


proc Print {type show args} {
	variable Priv
	variable Log

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

	if {![winfo exists $Log]} { Open }

	set t $Log.top.text
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
	set Priv(newline) 0
	set Priv(empty) 0
}


proc Clear {} {
	variable Priv
	variable Log

	set t $Log.top.text
	$t configure -state normal
	$t delete 1.0 end
	$t configure -state disabled
}


proc Visibility {state} {
	set [namespace current]::Priv(visibility) $state
}


proc Open {} {
	variable Priv
	variable Log
	variable colors

	tk::toplevel $Log -class $::scidb::app
	wm withdraw $Log
	wm protocol $Log WM_DELETE_WINDOW [list wm withdraw $Log]
	set top [ttk::frame $Log.top]
	pack $top -fill both -expand yes -padx $::theme::padx -pady $::theme::pady
	set log [tk::text $top.text \
		-wrap none \
		-state disabled \
		-height 10 \
		-width 70 \
		-takefocus 0 \
		-setgrid 1 \
		-yscrollcommand [list $top.ybar set] \
		-xscrollcommand [list $top.xbar set] \
		-tabs {2c 15c} \
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
	widget::dialogButtons $Log {clear close} -default close -icons no
	$Log.close configure -command [list wm withdraw $Log]
	$Log.clear configure -command [namespace code Clear]
	wm title $Log "$::scidb::app - $mc::LogTitle"
	wm minsize $Log 50 5
	set Priv(visibility) VisibilityFullyObscured
	set Priv(show) 0
	set Priv(force) 0
	set Priv(delay) 0
	set Priv(hide) 0
	set Priv(suppress) 0
	set Priv(center) 1
	set Priv(newline) 1
	set Priv(empty) 0
	set Priv(open) 0
	set Priv(transient) [expr {[tk windowingsystem] ne "win32"}]
}

} ;# namespace log

# vi:set ts=3 sw=3:
