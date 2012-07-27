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
# Copyright: (C) 2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source notation

namespace eval notation {
namespace eval mc {

set Notation		"Notation"

set MoveForm(alg)	"Algebraic"
set MoveForm(san)	"Short Algebraic"
set MoveForm(lan)	"Long Algebraic"
set MoveForm(eng)	"English"
set MoveForm(cor)	"Correspondence"
set MoveForm(tel)	"Telegraphic"

} ;# namespace mc

variable moveStyles { san lan alg eng cor tel }


proc listbox {path args} {
	variable moveStyles

	namespace eval [namespace current]::${path} {}
	variable ${path}::Notation
	variable ${path}::Lang

	set Notation {}
	foreach form $moveStyles { lappend Notation [list $form $mc::MoveForm($form)] }
	set NotationList {}
	foreach entry $Notation { lappend NotationList [lindex $entry 1] }
	set Lang graphic

	ttk::labelframe $path -text $mc::Notation
	set list [ttk::frame $path.list -takefocus 0]
	set selbox [::tlistbox $list.selection -exportselection 0 -pady 1 -borderwidth 1 {*}$args]
	$selbox addcol text -id text -expand yes
	foreach name $NotationList { $selbox insert [list $name] }
	pack $selbox -anchor s -fill both -expand yes
#	bind $list <Configure> [namespace code { ConfigureListbox %W %h }]
	set text [tk::text $path.text \
		-borderwidth 1 \
		-relief sunken \
		-background white \
		-state disabled \
		-exportselection 0 \
		-cursor {} \
		-width 0 \
		-height 1 \
	]
	bind $text <Any-Button> { break }
	bind $text <Any-Key> { break }
	$text tag configure text -font TkTextFont -justify center
	$text tag configure figurine -font $::font::figurine(text:normal) -justify center
	bind $selbox <<ListboxSelect>> [namespace code [list SetNotation $path $text yes]]
	bind $path <FocusIn> { focus [tk_focusNext %W] }
	bind $list <FocusIn> { focus [tk_focusNext %W] }

	grid $list -row 1 -column 1 -sticky nsew
	grid $text -row 3 -column 1 -sticky ew
	grid rowconfigure $path {0 4} -minsize $::theme::padding
	grid rowconfigure $path 1 -weight 1
	grid rowconfigure $path 2 -minsize $::theme::padding
	grid columnconfigure $path {0 2} -minsize $::theme::padding
	grid columnconfigure $path 1 -weight 1

	catch { rename ::$path $path.__notation__ }
	proc ::$path {command args} "[namespace current]::WidgetProc $path \$command {*}\$args"

	return $path
}


proc WidgetProc {w command args} {
	switch -- $command {
		setlang {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] setlang <lang>\""
			}
			variable ${w}::Lang
			set lang [lindex $args 0]
			set Lang $lang
			SetNotation $w $w.text yes
			return $w
		}

		select {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] setlang <lang>\""
			}
			variable ${w}::Notation
			set index [lsearch -exact -index 0 $Notation [lindex $args 0]]
			return [$w.list.selection select $index]
		}
	}

	return [$w.list.selection $command {*}$args]
}


proc SetNotation {w text {send 0}} {
	variable ${w}::Notation
	variable ${w}::Lang

	set sel [$w.list.selection curselection]
	if {$sel == -1} { return }
	set notation [lindex $Notation $sel 0]
	$text configure -state normal
	$text delete 1.0 end

	switch $notation {
		san { $text insert end "1.e4 " text }
		lan { $text insert end "1.e2-e4 " text }
		alg { $text insert end "1.e2e4 g8f6" text }
		eng { $text insert end "1.P-K4 N-KB3" text }
		cor { $text insert end "1.5254 7866" text }
		tel { $text insert end "1.GEGO WATI" text }
	}

	switch $notation {
		san - lan {
			if {$Lang eq "graphic"} {
				$text insert end [lindex $::figurines::langSet(graphic) 4] figurine
			} else {
				$text insert end [lindex $::figurines::langSet($Lang) 4] text
			}
		}
	}

	switch $notation {
		san { $text insert end "f6" text }
		lan { $text insert end "g8-f6" text }
	}

	$text configure -state disabled

	if {$send} {
		event generate $w <<ListboxSelect>> -data $notation
	}
}


proc ConfigureListbox {list height} {
	set n [$list.selection curselection]
	set linespace [$list.selection cget -linespace]
	set nrows [expr {$height/$linespace}]
	if {$nrows > [$list.selection cget -height]} {
		$list.selection configure -height $nrows
	}
	$list.selection see 0
	after idle [list $list.selection see]
}

} ;# namespace notation

# vi:set ts=3 sw=3:
