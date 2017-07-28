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
# Copyright: (C) 2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source manage-layouts

namespace eval application {
namespace eval layout {
namespace eval mc {

set Rename					"Rename"
set Delete					"Delete"
set Load						"Load"
set CannotOpenFile		"Cannot read file '%s'."
set RestoreToOldLayout	"Restore to old layout"

}


array set Options {
	borderwidth 5
	padding 7
}


proc open {parent currentLayout} {
	variable Width
	variable Height
	variable Options
	variable OldLayout
	variable OldList
	variable names_

	set OldList [[namespace parent]::inspectLayout]
	set OldLayout [[namespace parent]::currentLayout]

	set dlg $parent.layout
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg

	pack [set top [ttk::frame $dlg.top]] -expand yes -fill both
	set lt [ttk::frame $top.lt -borderwidth 0]
	set rt [ttk::frame $top.rt -borderwidth 0]
	set layout [tk::frame $rt.layout -background #0170cc]
	set twm [twm::twm $layout.manage \
		-makepane  [namespace current]::MakePane \
		-buildpane [namespace current]::BuildPane \
		-resizing  [namespace current]::Resizing \
		-borderwidth $Options(borderwidth) \
		-state readonly \
	]
	pack $twm -padx $Options(padding) -pady $Options(padding)
	[namespace parent]::loadInitialLayout $twm

	set names_ [lmap f [glob -nocomplain -directory $::scidb::dir::layout *.layout] {
		file tail [file rootname $f]}]
	set names_ [lsort $names_]
	set list [tk::listbox $lt.list -width 40 -listvariable [namespace current]::names_]
	set index [lsearch $names_ $currentLayout]
	$list activate $index
	if {$index >= 0} {
		$list selection set $index
		after idle [namespace code [list LoadLayout $twm $list $lt.res ""]]
	}
	$list see [expr {max(0,$index)}]

	set ren [ttk::button $lt.ren \
		-style aligned.TButton \
		-text $mc::Rename \
		-image $::icon::16x16::exchange \
		-compound left \
		-command [namespace code [list Rename $twm $list]] \
	]
	set del [ttk::button $lt.del \
		-style aligned.TButton \
		-text $mc::Delete \
		-image $::icon::16x16::delete \
		-compound left \
		-command [namespace code [list Delete  $twm $list]] \
	]
	set res [ttk::button $lt.res \
		-style aligned.TButton \
		-text $mc::Load \
		-image $::icon::16x16::refresh \
		-compound left \
		-command [namespace code [list Load $twm $list]] \
	]

	bind $list <<ListboxSelect>> [namespace code [list LoadLayout $twm $list $res $dlg.revert]]

	lassign [[namespace parent]::workArea $parent] Width Height
	set Width [expr {($Width*4)/9}]
	set Height [expr {($Height*4)/9}]

	grid $lt -row 1 -column 1 -sticky nsew
	grid $rt -row 1 -column 3 -sticky nsew
	grid columnconfigure $top {0 2 4} -minsize $::theme::padX
	grid rowconfigure $top {0 2 4} -minsize $::theme::padY

	grid $list -row 1 -column 1 -sticky nswe
	grid $ren  -row 3 -column 1 -sticky we
	grid $del  -row 5 -column 1 -sticky we
	grid $res  -row 7 -column 1 -sticky wes
	grid rowconfigure $lt {2 4 6} -minsize 2
	grid rowconfigure $lt {1} -weight 1

	grid $layout -row 1 -column 1 -sticky nsew
	grid columnconfigure $rt {1} -minsize [expr {$Width + 2*($Options(borderwidth) + $Options(padding))}]
	grid rowconfigure $rt {1} -minsize [expr {$Height + 2*($Options(borderwidth) + $Options(padding))}]

	::widget::dialogButtons $dlg {close revert}
	$dlg.close configure -command [list destroy $dlg]
	$dlg.revert configure -state disabled -command [namespace code [list Revert $twm $res $dlg.revert]]
	::tooltip::tooltip $dlg.revert [namespace current]::mc::RestoreToOldLayout
	wm resizable $dlg no no
	wm transient $dlg .application
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg -parent $parent -position center
	wm deiconify $dlg
	focus $list
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc NameFromUid {uid}		{ return [lindex [split $uid :] 0] }
proc NumberFromUid {uid}	{ return [lindex [split $uid :] 1] }


proc TitleFromUid {uid} {
	set name [NameFromUid $uid]
	if {$name eq "analysis"} {
		set title [set [namespace parent]::mc::Pane($name)]
		if {[set number [NumberFromUid $uid]] > 1} { append title " ($number)" }
	} else {
		set title [set [namespace parent]::mc::Pane($name)]
	}
	return $title
}


proc MakePane {twm parent type uid} {
	variable [namespace parent]::Prios
	variable Vars

	set name [TitleFromUid $uid]
	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus 0]
	set result [list $frame $name $Prios([NameFromUid $uid])]
	if {$type ne "pane"} { lappend result [expr {$uid ne "editor"}] yes yes }
	return $result
}


proc BuildPane {twm frame uid width height} {
	variable Vars

	switch [NameFromUid $uid] {
		analysis	{ $frame configure -background [::colors::lookup #ffee75] }
		editor	{ $frame configure -background [::colors::lookup pgn,background] }
		games		{ $frame configure -background [::colors::lookup scrolledtable,stripes] }
		tree		{ $frame configure -background [::colors::lookup tree,emphasize] }

		board {
			variable ::board::colors

			pack [set w [tk::canvas $frame.c -borderwidth 0 -takefocus 0]] -fill both -expand yes
			if {[llength $colors(hint,background-color)]} {
				$w configure -background $colors(hint,background-color)
			} else {
				::theme::configureBackground $w
			}
			bind $w <Configure> [list ::board::setBackground $w window %w %h]
			bind $w <Configure> +[namespace code [list ResizeBoard $w %w %h]]
			$w xview moveto 0
			$w yview moveto 0
			set size [expr {max(1, (min($width,$height) - 20)/8)}]
			board::diagram::new $w.diagram $size -empty 1 -bordersize 2 -bordertype lines -bordercolor white
			set x [expr {($width - ($size*8 + 2))/2}]
			set y [expr {($height - ($size*8 + 2))/2}]
			$w create window $x $y -anchor nw -window $w.diagram -tags board
		}
	}

	::tooltip::tooltip $frame [namespace parent]::mc::Pane([NameFromUid $uid])
}


proc ResizeBoard {w width height} {
	set size [expr {max(1, (min($width,$height) - 20)/8)}]
	board::diagram::resize $w.diagram $size
	set x [expr {($width - ($size*8 + 2))/2}]
	set y [expr {($height - ($size*8 + 2))/2}]
	$w coords board $x $y
}


proc Resizing {twm toplevel width height} {
	variable Width
	variable Height

	lassign [winfo workarea .application] _ _ ww wh
	lassign [winfo extents .application] ew1 ew2 eh1 eh2
	set adjustedWidth [expr {min($width, $ww - $ew1 - $ew2)}]
	set adjustedHeight [expr {min($height, $wh - $eh1 - $eh2)}]

	set fh [expr {double($Width)/double($adjustedWidth)}]
	set fv [expr {double($Height)/double($adjustedHeight)}]
	set f  [expr {min($fh, $fv)}]
	set fh [expr {$f*(double($adjustedWidth)/double($width))}]
	set fv [expr {$f*(double($adjustedHeight)/double($height))}]

	return [list [expr {int($fh*double($width) + 0.5)}] [expr {int($fv*double($height) + 0.5)}]]
}


proc LoadLayout {twm list loadBtn revertBtn} {
	if {[llength [$list curselection]] == 0} { return }

	set name [$list get [$list curselection]]
	set filename [file join $::scidb::dir::layout "$name.layout"]
	if {![file exists $filename]} {
		set msg [format $mc::CannotOpenFile $filename]
		return [dialog::error -parent $list -message $msg -topmost yes]
	}
	set fh [::open $filename "r"]
	$twm load [set layout [read $fh]]
	::close $fh

	if {[[namespace parent]::currentLayout] eq $name} { set state disabled } else { set state normal }
	$loadBtn configure -state $state
	if {[string length $revertBtn]} {
		$revertBtn configure -state normal
	}
}


proc Delete {twm list} {
	variable names_

	set name [$list get [$list curselection]]
	[namespace parent]::deleteLayout [winfo toplevel $twm] $name
	set i [lsearch $names_ $name]
	if {$i >= 0} { set names_ [lreplace $names_ $i $i] }
}


proc Rename {twm list} {
	variable names_

	set name [$list get [$list curselection]]
	set newName [[namespace parent]::renameLayout [winfo toplevel $twm] $name]
	if {[string length $newName] > 0} {
		set i [lsearch $names_ $name]
		if {$i >= 0} {
			set names_ [lreplace $names_ $i $i $newName]
			set names_ [lsort $names_]
			$list selection set $i
		}
	}
}


proc Load {twm list} {
	[namespace parent]::loadLayout [$list get [$list curselection]]
}


proc Revert {twm loadBtn revertBtn} {
	variable OldLayout
	variable OldList

	[namespace parent]::restoreLayout $OldLayout $OldList
	$loadBtn configure -state normal
	$revertBtn configure -state disabled
}

} ;# namespace layout
} ;# namespace application

# vi:set ts=3 sw=3:
