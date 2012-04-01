# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval widget {
namespace eval mc {

set Ok			"&OK"
set Cancel		"&Cancel"
set Apply		"&Apply"
set Reset		"&Reset"
set Close		"&Close"
set Clear		"C&lear"
set Import		"&Import"
set Revert		"&Revert"
set Update		"&Update"
set Previous	"&Previous"
set Next			"&Next"
set Last			"Las&t"
set First		"&First"

} ;# namespace mc

set Priv(busy:state) 0


set ButtonOrder { previous next update clear close ok apply cancel reset revert }
	

proc textLineScroll {w cmd args} {
	switch $cmd {
		moveto {
			lassign $args fraction
			set fraction [expr {min(1.0, max(0.0, $fraction))}]
			lassign [$w yview] first last

			set incr     [font metrics [$w cget -font] -linespace]
			set height   [expr {[winfo height $w] - 2*([$w cget -borderwidth] + [$w cget -pady])}]
			set visible  [expr {$height/$incr}]
			set total    [expr {int($visible/($last - $first) + 0.5)}]
			set topline  [expr {int($fraction*double($total) + 0.5)}]
			
			$w yview moveto [expr {double($topline)/double($total)}]
		}

		default {
			$w yview $cmd {*}$args
		}
	}
}


proc textPreventSelection {w} {
	bind $w <Double-1>	{ break }
	bind $w <Triple-1>	{ break }
	bind $w <B1-Motion>	{ break }
	bind $w <B2-Motion>	{ break }
}


proc notebookSetLabel {nb id text} {
	lassign [::tk::UnderlineAmpersand $text] text idx
	$nb tab $id -text [::mc::stripAmpersand $text] -underline $idx
}


proc notebookTextvarHook {nb id var {args {}}} {
	SetNotebookLabel $nb $id $var $args
	set cmd [list [namespace current]::SetNotebookLabel $nb $id $var $args]
	trace add variable $var write $cmd
	bind $nb <Destroy> "+
		if {{$nb} eq {%W}} { trace remove variable $var write {$cmd} }
	"
}


proc menuTextvarHook {m index var {args {}}} {
	SetMenuLabel $m $index $var $args
	set cmd [list [namespace current]::SetMenuLabel $m $index $var $args]
	trace add variable $var write $cmd
#	For some reasons this callback will be called although the menu is not destroyed
#	(possibly some kind of copy operation).
#	bind $m <Destroy> +[list trace remove variable $var write $cmd]
}


proc dialogButtons {dlg buttons {dflt {}} {useIcons yes}} {
	variable ButtonOrder

	if {[llength $dflt] == 0} { set dflt [lindex $buttons 0] }
	bind $dlg <Alt-Key> [list tk::AltKeyInDialog $dlg %A]
	::ttk::separator $dlg.__sep -class Dialog
	tk::frame $dlg.__buttons -class Dialog
	set slaves [pack slaves $dlg]
	if {[llength $slaves]} {
		pack $dlg.__sep -fill x -side bottom -before [lindex $slaves 0]
	} else {
		pack $dlg.__sep -fill x -side bottom
	}
	pack $dlg.__buttons -anchor center -side bottom -before $dlg.__sep

	set entries {}
	foreach entry $buttons {
		set icon {}
		lassign $entry type var icon
		lappend entries [list $type $var $icon [lsearch $ButtonOrder $type]]
	}
	set entries [lsort -index 3 -integer $entries]

	foreach entry $entries {
		lassign $entry type var icon
		set w [::ttk::button $dlg.$type -class TButton]

		switch -- $type {
			ok			{ set var [namespace current]::mc::Ok }
			cancel	{ set var [namespace current]::mc::Cancel }
			apply		{ set var [namespace current]::mc::Apply }
			update	{ set var [namespace current]::mc::Update }
			reset		{ set var [namespace current]::mc::Reset }
			close		{ set var [namespace current]::mc::Close }
			clear		{ set var [namespace current]::mc::Clear }
			import	{ set var [namespace current]::mc::Import }
			revert	{ set var [namespace current]::mc::Revert }
			previous	{ set var [namespace current]::mc::Previous }
			next		{ set var [namespace current]::mc::Next }
			first		{ set var [namespace current]::mc::First }
			last		{ set var [namespace current]::mc::Last }

			default	{
				if {![info exists var]} {
					return -code error "unknown button type $type"
				}
			}
		}

		dialogButtonsSetup $dlg $type $var $dflt
		bind $w <Return> "event generate $w <Key-space>; break"
		pack $w -in $dlg.__buttons -pady $::theme::pady -padx $::theme::padx -side left
	}

	if {$useIcons} { dialogButtonSetIcons $dlg }
}


proc dialogButtonSetIcons {dlg} {
	foreach w [winfo children $dlg] {
		if {[winfo class $w] eq "TButton"} {
			set icon {}

			switch [lindex [split $w .] end] {
				ok			{ set icon $::icon::iconOk }
				cancel	{ set icon $::icon::iconCancel }
				apply		{ set icon $::icon::iconApply }
				update	{ set icon $::icon::iconUpdate }
				reset		{ set icon $::icon::iconReset }
				clear		{ set icon $::icon::iconClear }
				close		{ set icon $::icon::iconClose }
				revert	{ set icon $::icon::iconReset }
				previous	{ set icon $::icon::iconBackward }
				next		{ set icon $::icon::iconForward }
				first		{ set icon $::icon::iconFirst }
				last		{ set icon $::icon::iconLast }
			}

			if {[llength $icon]} {
				$w configure -compound left -image $icon
			}
		}
	}
}


proc dialogButtonAdd {dlg type labelvar {icon {}}} {
	set w [::ttk::button $dlg.$type -class TButton]
	if {[llength $icon]} {
		$w configure -compound left -image $icon
	}
	dialogButtonsSetup $dlg $type $labelvar
	bind $w <Return> "event generate $w <Key-space>; break"
	pack $w -in $dlg.__buttons -pady $::theme::pady -padx $::theme::padx -side left
}


proc dialogButtonsSetup {parent type var {dflt {}}} {
	set w $parent.$type

	if {$type eq $dflt} {
		$w configure -default active
		bind $parent <Return> "
			if {\[winfo exists $w\] && \[$w cget -state\] eq {normal}} {
				focus $w
				event generate $w <Key-space>
			}"
	} elseif {[llength $dflt]} {
		bind $w <FocusIn>		"$parent.$dflt configure -default normal; $w configure -default active"
		bind $w <FocusOut>	"$parent.$dflt configure -default active; $w configure -default normal"
	} else {
		bind $w <FocusIn>		"$w configure -default active"
		bind $w <FocusOut>	"$w configure -default normal"
	}

	buttonSetText $w $var
}


proc dialogButtonInvoke {parent} {
	foreach w [winfo children $parent] {
		if {[winfo class $w] eq "TButton"} {
			if {[$w cget -default] eq "active"} {
				focus $w
				event generate $w <Key-space>
			}
		}
	}
}


proc dialogSetTitle {dlg cmd} {
	SetDialogTitle $dlg $cmd
	bind $dlg <<LanguageChanged>> [namespace code [list SetDialogTitle $dlg $cmd]]
}


proc buttonSetText {w var args} {
	if {[$w cget -compound] eq "left"} {
		::tk::SetAmpText $w " [set $var]"
	} else {
		::tk::SetAmpText $w [set $var]
	}

	set cmd "[namespace current]::buttonSetText $w $var"
	trace add variable $var write $cmd
	bind $w <Destroy> "+
		if {\"$w\" eq \"%W\"} {
			trace remove variable $var write \"$cmd\"
		}
	"
}


proc busyCursor {w {state on}} {
	variable BusyCmd
	variable Priv

	if {[string index $w 0] ne "."} {
		set state $w
		set w --
	}

	if {$state eq "on"} {
		if {[incr Priv(busy:state)] != 1} { return }
		set action hold
	} else {
		if {[incr Priv(busy:state) -1] != 0} { return }
		set action forget
	}

	if {$action eq "hold"} { ::update }

	::scidb::tk::busy $action .application

	if {[tk windowingsystem] eq "x11"} {
		foreach tlv [winfo children .application] {
			BusyCursor $action $tlv $w
		}
	}

	if {$action eq "hold"} { ::update }
}


proc unbusyCursor {{w {}}} {
	if {[llength $w]} { busyCursor $w off } else { busyCursor off }
}


proc busyOperation {args} {
	busyCursor on

	if {[catch {uplevel $args} result options]} {
		busyCursor off
		array set opts $options
		return \
			-code $opts(-code) \
			-errorinfo $opts(-errorinfo) \
			-errorcode $opts(-errorcode) \
			-rethrow 1 \
			$result
	}

	busyCursor off
	return $result
}


proc menuItemHighlightSecond {menu} {
	##	NOTE: the menu is flickering a lot!
	##  ----------------------------------
	set active [$menu index active]
	set numEntries [expr {[$menu index last] + 1}]

	if {$active eq "none"} {
		set index -1
	} else {
		set index [expr {($active + $numEntries/2) % $numEntries}]
	}

	for {set i 0} {$i < $numEntries} {incr i} {
		if {$i != $active && $i != $index} {
			if {[llength [$menu entrycget $i -background]]} {
				$menu entryconfigure $i -background {} -foreground {}
			}
		}
	}

	if {$index != -1} {
		$menu entryconfigure $index \
			-background [option get $menu activeBackground Menu] \
			-foreground [option get $menu activeForeground Menu]
	}
}


proc BusyCursor {action w ignore} {
	if {$w ne $ignore} {
		if {[winfo toplevel $w] eq $w} {
			catch { ::scidb::tk::busy $action $w }
		}
		foreach tlv [winfo children $w] {
			BusyCursor $action $tlv $ignore
		}
	}
}


proc SetNotebookLabel {nb id var args} {
	lassign [::tk::UnderlineAmpersand [set $var]] text idx
	$nb tab $id -text [format $text {*}$args] -underline $idx
}


proc SetMenuLabel {m index var args} {
	lassign [::tk::UnderlineAmpersand [format [set $var] {*}$args]] text ul
	set text " $text"
	incr ul

	if {$ul > 0} {
		$m entryconfigure $index -label $text -underline $ul
	} else {
		$m entryconfigure $index -label $text
	}
}


proc SetDialogTitle {dlg cmd} {
	wm title $dlg [eval $cmd]
}

} ;# namespace widget

# vi:set ts=3 sw=3:
