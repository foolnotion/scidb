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
# Copyright: (C) 2017-2018 Gregor Cramer
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
set Linked					"Linked with"
set CannotOpenFile		"Cannot read file '%s'."
set RestoreToOldLayout	"Restore to old layout"

}


array set Options {
	borderwidth 5
	padding 7
}


proc open {twm id currentLayout link} {
	variable Width
	variable Height
	variable Options
	variable OldLayout
	variable OldList
	variable Twm
	variable names_

	set OldList [[namespace parent]::twm::inspectLayout $twm]
	set OldLayout [[namespace parent]::twm::currentLayout $twm]
	set force $::twm::Options(deiconify:force)
	set ::twm::Options(deiconify:force) 1
	set Twm $twm

	set dlg $twm.layout
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg

	pack [set top [ttk::frame $dlg.top]] -expand yes -fill both
	set lt [ttk::frame $top.lt -borderwidth 0]
	set rt [ttk::frame $top.rt -borderwidth 0]
	set layout [tk::frame $rt.layout -background #0170cc]
	set myTWM [twm::twm $layout.manage \
		-makepane  [namespace current]::MakePane \
		-buildpane [namespace current]::BuildPane \
		-resizing  [namespace current]::Resizing \
		-borderwidth $Options(borderwidth) \
		-state readonly \
		-disableclose 1 \
	]
	pack $myTWM -padx $Options(padding) -pady $Options(padding)
	[namespace parent]::twm::loadInitialLayout $myTWM $twm

	set names_ [[namespace parent]::twm::glob $id]
	set list [tk::listbox $lt.list -width 30 -listvariable [namespace current]::names_]
	set index [lsearch $names_ $currentLayout]
	$list activate $index
	if {$index >= 0} {
		$list selection set $index
		after idle [namespace code [list LoadLayout $myTWM $twm $id $list $lt.res]]
	}
	$list see [expr {max(0,$index)}]

	set ren [ttk::button $lt.ren \
		-style aligned.TButton \
		-text $mc::Rename \
		-image $::icon::16x16::exchange \
		-compound left \
		-command [namespace code [list Rename $twm [winfo toplevel $myTWM] $list]] \
	]
	set del [ttk::button $lt.del \
		-style aligned.TButton \
		-text $mc::Delete \
		-image $::icon::16x16::delete \
		-compound left \
		-command [namespace code [list Delete $twm [winfo toplevel $myTWM] $list]] \
	]
	set res [ttk::button $lt.res \
		-style aligned.TButton \
		-text $mc::Load \
		-image $::icon::16x16::refresh \
		-compound left \
		-command [namespace code [list Load $twm $list $dlg.revert]] \
	]

	if {$id ne "board"} {
		set names [[namespace parent]::twm::glob board]
		if {[llength $names]} {
			variable link_
			set link_ $link
			if {[string length $link_] == 0} { set link_ "\u2014" }
			set names [linsert $names 0 "\u2014"]
			set linkframe [ttk::frame $lt.link -borderwidth 0]
			ttk::label $linkframe.lbl -text "${mc::Linked}:"
			ttk::combobox $linkframe.cb \
				-values $names \
				-textvariable [namespace current]::link_ \
				-state readonly \
				;
			tooltip::tooltip $linkframe.lbl [namespace parent]::twm::mc::LinkLayoutTip
			grid $linkframe.lbl -row 0 -column 0
			grid $linkframe.cb  -row 0 -column 2 -sticky ew
			grid columnconfigure $linkframe {1} -minsize $::theme::padx
			grid columnconfigure $linkframe {2} -weight 1
			bind $linkframe.cb <<ComboboxSelected>> \
				[namespace code [list SetLink $id $currentLayout $linkframe.cb]]
		}
	}

	bind $list <<ListboxSelect>> [namespace code [list LoadLayout $myTWM $twm $id $list $res]]

	lassign [[namespace parent]::twm::workArea $twm] Width Height
	set Width [expr {($Width*4)/9}]
	set Height [expr {($Height*4)/9}]

	grid $lt -row 1 -column 1 -sticky nsew
	grid $rt -row 1 -column 3 -sticky nsew
	grid columnconfigure $top {0 2 4} -minsize $::theme::padX
	grid rowconfigure $top {0 2} -minsize $::theme::padY

	grid $list -row 1 -column 1 -sticky nswe
	grid $ren  -row 3 -column 1 -sticky we
	grid $del  -row 5 -column 1 -sticky we
	grid $res  -row 7 -column 1 -sticky wes
	grid rowconfigure $lt {2 4 6} -minsize 2
	grid rowconfigure $lt {1} -weight 1

	if {[info exists linkframe]} {
		grid $linkframe -row 9 -column 1 -sticky wes
		grid rowconfigure $lt {8} -minsize $::theme::pady
	}

	grid $layout -row 1 -column 1 -sticky nsew
	grid columnconfigure $rt {1} -minsize [expr {$Width + 2*($Options(borderwidth) + $Options(padding))}]
	grid rowconfigure $rt {1} -minsize [expr {$Height + 2*($Options(borderwidth) + $Options(padding))}]

	::widget::dialogButtons $dlg {close revert}
	$dlg.close configure -command [list destroy $dlg]
	$dlg.revert configure -state disabled -command [namespace code [list Revert $myTWM $res $dlg.revert]]
	::tooltip::tooltip $dlg.revert [namespace current]::mc::RestoreToOldLayout
	wm resizable $dlg no no
	wm transient $dlg .application
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm title $dlg [set [namespace parent]::twm::mc::ManageLayouts]
	::util::place $dlg -parent $twm -position center
	wm deiconify $dlg
	focus $list
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
	set ::twm::Options(deiconify:force) $force
}


proc SetLink {id name cb} {
	variable link_

	if {[$cb current] == 0} { set link "" } else { set link $link_ }
	[namespace parent]::twm::setLink $id $name $link
}


proc NameFromUid {uid}		{ return [lindex [split $uid :] 0] }
proc NumberFromUid {uid}	{ return [lindex [split $uid :] 1] }


proc TitleFromUid {uid} {
	set name [NameFromUid $uid]
	if {$name eq "analysis"} {
		set title [set [namespace parent]::twm::mc::Pane($name)]
		if {[set number [NumberFromUid $uid]] > 1} { append title " ($number)" }
	} else {
		set title [set [namespace parent]::twm::mc::Pane($name)]
	}
	return $title
}


proc MakePane {myTWM parent type uid} {
	variable Twm

	set name [TitleFromUid $uid]
	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus 0]
	set result [list $frame $name [$Twm get [$Twm leaf $uid] priority])]
	if {$type ne "pane"} {
		set closable [expr {$uid ne "editor" && $uid ne [[namespace parent]::twm::getId $Twm]}]
		lappend result $closable yes yes
	}
	return $result
}


proc BuildPane {myTWM frame uid width height} {
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

		default { $frame configure -background [::colors::lookup tree,stripes] }
	}

	::tooltip::tooltip $frame [namespace parent]::twm::mc::Pane([NameFromUid $uid])
}


proc ResizeBoard {w width height} {
	set size [expr {max(1, (min($width,$height) - 20)/8)}]
	board::diagram::resize $w.diagram $size
	set x [expr {($width - ($size*8 + 2))/2}]
	set y [expr {($height - ($size*8 + 2))/2}]
	$w coords board $x $y
}


proc Resizing {myTWM toplevel width height} {
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


proc LoadLayout {myTWM twm id list loadBtn} {
	if {[llength [$list curselection]] == 0} { return }

	set name [$list get [$list curselection]]
	# TODO: find directory for actual variant
	set filename [file join $::scidb::dir::layout $id "$name.layout"]
	if {![file exists $filename]} {
		set msg [format $mc::CannotOpenFile $filename]
		return [dialog::error -parent $list -message $msg -topmost yes]
	}
	set ::application::twm::SetupFunc [list $myTWM load]
	after idle [list set ::application::twm::SetupFunc {}]
	::load::source $filename -encoding utf-8 -throw 1
	set state [expr {[[namespace parent]::twm::currentLayout $twm] eq $name ? "disabled" : "normal"}]
	$loadBtn configure -state $state
}


proc Delete {twm parent list} {
	variable names_

	set name [$list get [$list curselection]]
	if {[[namespace parent]::twm::deleteLayout $twm $name $parent]} {
		set i [lsearch $names_ $name]
		if {$i >= 0} { set names_ [lreplace $names_ $i $i] }
	}
}


proc Rename {twm parent list} {
	variable names_

	set name [$list get [$list curselection]]
	set newName [[namespace parent]::twm::renameLayout $twm $name $parent]
	if {[string length $newName] > 0} {
		set i [lsearch $names_ $name]
		if {$i >= 0} {
			set names_ [lreplace $names_ $i $i $newName]
			set names_ [lsort $names_]
			$list selection set $i
		}
	}
}


proc Load {twm list revertBtn} {
	variable OldList
	[namespace parent]::twm::loadLayout $twm [$list get [$list curselection]]
	set eq [[namespace parent]::twm::currentLayoutIsEqTo $twm $OldList]
	$revertBtn configure -state [expr {$eq ? "disabled" : "normal"}]
}


proc Revert {twm loadBtn revertBtn} {
	variable OldLayout
	variable OldList

	[namespace parent]::twm::restoreLayout $twm $OldLayout $OldList
	$loadBtn configure -state normal
	$revertBtn configure -state disabled
}

} ;# namespace layout
} ;# namespace application

# vi:set ts=3 sw=3:
