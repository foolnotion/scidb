# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

# ======================================================================
# Providing a modified paned window:
#	- cursor handling overworked (the original implementation is clumsy)
#	- additional pane option "-maxsize"
#	- Button-2 is unbound
#	- option -gridsize added, global (will be applied to all childs),
#	  and for specific childs (paneconfigure)
#
# Issues:
#	- option "-opaqueresize" will be ignored (always on)
#	- "-cursor" option should not be changed with "configure"
#	- the cursor of the panes should not be set to "" after
#	  they the pane is added to panedwindow
#
# Why not using ttk::panedwindow?
#	- the design is quite halfhearted, for example no -minsize option,
#    so this widget is somewhat useless
#  - the cursor handling is clumsy
#	- no support of -gridsize
#	- the tk version looks better than the ttk version
#
# IMPORTANT NOTE:
# This version of panedwindow is part of TWM (tiled window managemant).
# ======================================================================

package provide panedwindow 1.0

rename tk::panedwindow tk::panedwindow_old


proc panedwindow {args} {
	if {[llength $args] == 0} {
		return error -code "wrong # args: should be \"panedwindow pathName ?options?\""
	}
	if {[winfo exists [lindex $args 0]]} {
		return error -code "window name \"[lindex $args 0]\" already exists"
	}
	return [panedwindow::Build {*}$args]
}


namespace eval tk {

proc panedwindow {args} { return [::panedwindow {*}$args] }

} ;# namespace tk


namespace eval panedwindow {

proc Build {w args} {
	variable Initialized

	array set opts {
		-borderwidth	0
		-gridsize		0
		-cursor			{}
		-state			"normal"
	}

	namespace eval [namespace current]::$w {}
	variable [namespace current]::${w}::
	set (cursor) left_ptr

	array set opts $args
	array unset opts -opaqueresize
	set (state) $opts(-state)
	array unset opts -state
	set (gridsize) $opts(-gridsize)
	array unset opts -gridsize

	tk::panedwindow_old $w {*}[array get opts] -opaqueresize 1
	if {$(state) ne "disabled"} {
		set cursor sb_[string index [$w cget -orient] 0]_double_arrow
		if {[$w cget -cursor] ne $cursor} {
			$w configure -cursor $cursor
		}
	}
	
	rename ::$w $w.__panedwindow__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	if {$command eq "add" || $command eq "paneconfigure"} {
		if {[llength $args] % 2 == 0} {
			error "value for \"[lindex $args end]\" missing"
		}
		set child [lindex $args 0]
		array set opts [lrange $args 1 end]
		variable [namespace current]::${w}::

		if {![info exists (maxsize:$child)]} { set (maxsize:$child) 32000 }
		if {![info exists (gridsize:$child)]} { set (gridsize:$child) 0 }

		if {[info exists opts(-maxsize)]} {
			if {[string is integer -strict $opts(-maxsize)]} {
				set (maxsize:$child) [expr {$maxsize > 0 ? $maxsize : 32000}]
			} else {
				error "bad screen distance \"$opts(-maxsize)\""
			}
			unset opts(-maxsize)
		}
		if {[info exists opts(-gridsize)]} {
			if {[string is integer -strict $opts(-gridsize)]} {
				set (gridsize:$child) [expr {max(0, $opts(-gridsize))}]
			} else {
				error "bad screen distance \"$opts(-gridsize)\""
			}
			unset opts(-gridsize)
		}

		set args $child
		lappend args {*}[array get opts]
	}

	switch -- $command {
		add {
			variable ${w}::

			set child [lindex $args 0]
			
			if {	$(state) ne "disabled"
				&& [llength [$child cget -cursor]] == 0
				&& [$child cget -cursor] ne $(cursor)} {
				$child configure -cursor $(cursor)
			}
		}

		configure {
			if {[llength $args] % 2 == 1} {
				error "value for \"[lindex $args end]\" missing"
			}
			array set opts $args
			foreach {key val} $args {
				switch -- $key {
					-cursor {
						variable ${w}::
						set (cursor) $val
						if {[string length $(cursor)] == 0} { set (cursor) left_ptr }
						unset opts($key)
					}

					-orient {
						set cursor sb_[string index $val 0]_double_arrow
						set child $w.__panedwindow__
						if {[$child cget -cursor] ne $cursor} {
							$child configure -cursor $cursor
						}
					}

					-opaqueresize {
						unset opts($key)
					}

					-gridsize {
						if {[string is integer -strict $val]} {
							variable ${w}::
							set (gridsize) [expr {max(0, $val)}]
						} else {
							error "bad screen distance \"$opts(-gridsize)\""
						}
						unset opts($key)
					}

					-state {
						if {$state eq "disabled"} {
							variable ${w}::
							set cursor $(cursor)
						} else {
							set cursor sb_[string index [$w cget -orient] 0]_double_arrow
						}
						if {[$w cget -cursor] ne $cursor} {
							$w configure -cursor $cursor
						}
					}
				}
			}
			set args [array get opts]
		}

		cget {
			switch -- [lindex $args 0] {
				-cursor {
					variable ${w}::
					return $(cursor)
				}
				-gridsize {
					variable ${w}::
					return $(gridsize)
				}
			}
		}

		panecget {
			if {[llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <window> <option>\""
			}
			lassign $args pane option
			if {$option eq "-gridsize"} {
				variable ${w}::
				if {$pane ni [$w panes]} {
					error "\"$pane\" is not child of panedwindow"
				}
				return $(gridsize:$pane)
			}
		}
	}

	return [$w.__panedwindow__ $command {*}$args]
}


proc DestroyHandler {w} {
	namespace delete [namespace current]::$w
	rename $w {}
}

} ;# namespace panedwindow


bind Panedwindow <ButtonPress-1>		{ tk::panedwindow::MarkSash %W %x %y }
bind Panedwindow <B1-Motion>			{ tk::panedwindow::DragSash %W %x %y }
bind Panedwindow <ButtonRelease-1>	{ tk::panedwindow::ReleaseSash %W }
bind PanedWindow <Destroy>				{ tk::panedwindow::DestroyHandler %W }

bind Panedwindow <ButtonPress-2>		{#}
bind Panedwindow <B2-Motion>			{#}
bind Panedwindow <ButtonRelease-2>	{#}
bind Panedwindow <Leave>				{#}


namespace eval tk {
namespace eval panedwindow {

proc MarkSash {w x y} {
	variable ::tk::Priv
	variable ::panedwindow::${w}::

	if {$(state) eq "disabled"} { return }

	set what [$w identify $x $y]
	if {[llength $what] != 2} { return }
	lassign $what index which
	if {$::tk_strictMotif && $which ne "handle"} { return }

	set panes [$w panes]
	lassign {0 0 0 0} lhsMax rhsMax lhsMin rhsMin
	set dimen [expr {[string match h* [$w cget -orient]] ? "width" : "height"}]
	set npanes [llength $panes]
	array unset {} gridsize

	foreach pane $panes {
		set maxsize($pane) $(maxsize:$pane)
		if {$(gridsize:$pane) > 1} {
			set (gridsize) $(gridsize:$pane)
			set minsize [$w panecget $pane -minsize]
			set f [expr {($maxsize($pane) - $minsize)/$(gridsize)}]
			set maxsize($pane) [expr {$f*$(gridsize) + $minsize}]
		}
	}

	for {set i 0} {$i <= $index} {incr i} {
		set pane [lindex $panes $i]
		set Priv(panesize:$pane) [expr {max($maxsize($pane), [winfo $dimen $pane])}]
		set lhsMax [expr {$lhsMax + $Priv(panesize:$pane) - [winfo $dimen $pane]}]
		set lhsMin [expr {$lhsMin + max(1, [$w panecget $pane -minsize])}]
	}

	for {set i [expr {$index + 1}]} {$i < $npanes} {incr i} {
		set pane [lindex $panes $i]
		set Priv(panesize:$pane) [expr {max($maxsize($pane), [winfo $dimen $pane])}]
		set rhsMax [expr {$rhsMax + $Priv(panesize:$pane) - [winfo $dimen $pane]}]
		set rhsMin [expr {$rhsMin + max(1, [$w panecget $pane -minsize])}]
	}

	set sashwidth [$w cget -sashwidth]
	incr lhsMax [expr {$index*$sashwidth}]
	incr lhsMin [expr {$index*$sashwidth}]
	incr rhsMax [expr {($npanes - $index - 1)*$sashwidth}]
	incr rhsMin [expr {($npanes - $index - 1)*$sashwidth}]

	set Priv(sash) $index
	lassign [$w sash coord $index] sx sy
	set Priv(dx) [expr {$sx - $x}]
	set Priv(dy) [expr {$sy - $y}]

	set v [expr {[string match h* [$w cget -orient]] ? "x" : "y"}]
	set Priv(min) [expr {max($lhsMin, [set s$v] - $rhsMax)}]
	set Priv(max) [expr {min([winfo $dimen $w] - $rhsMin, [set s$v] + $lhsMax)}]

	set Priv(min) [expr {$Priv(min) + $sashwidth}]
	if {$Priv(min) >= $Priv(max)} { return }

	if {[info exists (gridsize)]} {
		set (mark) [set s$v]
	}
	for {set i 0} {$i < $npanes - 1} {incr i} {
		$w sash mark $i $sx $sy
	}

	set Priv(cursorList) {}
	SetCursor [$w panes] sb_[string index [$w cget -orient] 0]_double_arrow
}


proc DragSash {w x y} {
	variable ::tk::Priv
	variable ::panedwindow::${w}::

	if {$(state) eq "disabled"} { return }

	if {[info exists Priv(sash)]} {
		incr x $Priv(dx)
		incr y $Priv(dy)

		set x [expr {min($Priv(max), max($Priv(min), $x))}]
		set y [expr {min($Priv(max), max($Priv(min), $y))}]

		MoveSash $w $Priv(sash) $x $y 0
	}
}


proc ReleaseSash {w} {
	variable ::tk::Priv

	if {[info exists Priv(sash)]} {
		ResetCursor
		array unset Priv panesize:*
		unset -nocomplain Priv(sash) Priv(dx) Priv(dy) Priv(min) Priv(max) Priv(cursorList)
	}
}


proc MoveSash {w index x y offs} {
	variable ::panedwindow::${w}::
	variable ::tk::Priv

	set panes [$w panes]
	set cx [expr {$x - $offs}]
	set cy [expr {$y - $offs}]

	set pane [lindex $panes $index]
	set gridsize $(gridsize:$pane)
	set v [expr {[string match h* [$w cget -orient]] ? "x" : "y"}]

	if {$gridsize > 1} {
		lassign [$w sash coord $index] x1 y1
		set f  [expr {([set c$v] - [set ${v}1] - $gridsize/2)/$gridsize}]
		set cx [expr {[set ${v}1] + $f*$gridsize}]
	}

	if {[info exists (gridsize)]} {
		if {[set c$v] > $(mark)} {
			set c$v [expr {(([set c$v] - $(mark))/$(gridsize))*$(gridsize) + $(mark)}]
		} else {
			set c$v [expr {$(mark) - (($(mark) - [set c$v])/$(gridsize))*$(gridsize)}]
		}
	}

	$w sash place $index $cx $cy
	set sashSize [$w cget -sashwidth]

	if {$index > 0} {
		lassign [$w sash coord [expr {$index - 1}]] sx sy
		incr s$v $sashSize
		set maxsize $Priv(panesize:$pane)

		if {[set c$v] - [set s$v] > $maxsize} {
			MoveSash $w [expr {$index - 1}] $x $y [expr {$offs + $maxsize + $sashSize}]
		}
	}

	if {$index < [llength $panes] - 2} {
		set pane [lindex $panes [expr {$index + 1}]]
		lassign [$w sash coord [expr {$index + 1}]] sx sy
		incr s$v -$sashSize
		set maxsize $Priv(panesize:$pane)

		if {[set s$v] - [set c$v] > $maxsize} {
			MoveSash $w [expr {$index + 1}] $x $y [expr {$offs - $maxsize - $sashSize}]
		}
	}
}


proc SetCursor {childs cursor} {
	variable ::tk::Priv

	foreach child $childs {
		catch {
			set cur [$child cget -cursor]
			if {[string match {*_double_arrow} $cur]} { set cur "" }
			if {[$child cget -cursor] ne $cursor]} {
				$child configure -cursor $cursor
			}
			lappend Priv(cursorList) $child $cur
		}
		SetCursor [winfo children $child] $cursor
	}
}


proc ResetCursor {} {
	variable ::tk::Priv

	if {![info exists Priv(cursorList)]} { return }

	foreach {child cursor} $Priv(cursorList) {
		if {[winfo exists $child]} {
			catch {
				if {[$child cget -cursor] ne $cursor]} {
					$child configure -cursor $cursor
				}
			}
		}
	}
}

} ;# namespace panedwindow
} ;# namespace tk

# vi:set ts=3 sw=3:
