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
# Copyright: (C) 2012-2018 Gregor Cramer
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

set MoveForm(can)	"Computer Algebraic Notation"	;# also "Coordinate Algebraic"
set MoveForm(san)	"Short Algebraic Notation"		;# also "Standard  Algebraic Notation"
set MoveForm(lan)	"Long Algebraic Notation"
set MoveForm(gan) "German Short Algebraic Notation"
set MoveForm(man)	"Minimal Algebraic Notation"	;# Informator style
set MoveForm(ran)	"Reversible Algebraic Notation"
set MoveForm(smi)	"Smith Notation"
set MoveForm(edn)	"English Descriptive Notation"
set MoveForm(sdn)	"Spanish Descriptive Notation"
set MoveForm(cor)	"ICCF Numeric Notation (Correspondence)"
set MoveForm(tel)	"Alphabetic Notation (Telegraph)"

} ;# namespace mc

variable moveStyles { san lan can man gan ran smi edn sdn cor tel }


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
	set selbox [::tlistbox $list.selection \
		-exportselection 0 \
		-pady 1 \
		-borderwidth 1 \
		-usescroll 0 \
		{*}$args \
	]
	$selbox addcol text -id text -expand yes
	foreach name $NotationList { $selbox insert [list $name] }
	pack $selbox -anchor s -fill both -expand yes
	bind $selbox <Configure> [namespace code { ConfigureListbox %W %h }]
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


proc buildMenuForShortNotation {cmd var} {
	set menu {}
	foreach notation {san gan man} {
		lappend menu [list radiobutton \
			-command $cmd \
			-labelvar ::notation::mc::MoveForm($notation) \
			-variable $var \
			-value $notation \
		]
	}
	return $menu
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
		san { $text insert end "17.e4 " text }
		gan { $text insert end "17.e4 " text }
		man { $text insert end "17.e4 " text }
		lan { $text insert end "17.e3-e4 " text }
		ran { $text insert end "17.e3-e4 " text }
		can { $text insert end "17.e3e4 f6e4" text }
		smi { $text insert end "17.e3e4 f6e4" text }
		edn { $text insert end "17.P-K4 NxP+" text }
		sdn { $text insert end "17.P4R CxP+" text }
		cor { $text insert end "17.5354 6654" text }
		tel { $text insert end "17.GEGO TIGO" text }
	}

	switch $notation {
		san - gan - lan - man - ran {
			if {$Lang eq "graphic"} {
				$text insert end [lindex $::figurines::langSet(graphic) 4] figurine
			} else {
				$text insert end [lindex $::figurines::langSet($Lang) 4] text
			}
		}
	}

	switch $notation {
		san			{ $text insert end "x" text }
		lan - ran	{ $text insert end "f6x" text }
	}

	if {$notation eq "ran"} {
		if {$Lang eq "graphic"} {
			$text insert end [lindex $::figurines::langSet(graphic) 5] figurine
		} else {
			$text insert end [lindex $::figurines::langSet($Lang) 5] text
		}
	}

	switch $notation {
		man					{ $text insert end "e4" text }
		san - lan - ran	{ $text insert end "e4+" text }
		gan					{ $text insert end "e4:+" text }
	}

	if {$notation eq "smi"} {
		if {$Lang eq "graphic"} {
			$text insert end [lindex $::figurines::langSet(graphic) 4] figurine
		} else {
			$text insert end [string tolower [lindex $::figurines::langSet($Lang) 4]] text
		}
	}

	$text configure -state disabled

	if {$send} {
		event generate $w <<ListboxSelect>> -data $notation
	}
}


proc ConfigureListbox {selbox height} {
	after idle [list $selbox resize -fixed]
#	set n [$selbox.selection curselection]
#	set linespace [$selbox.selection cget -linespace]
#	set nrows [expr {$height/$linespace}]
#	if {$nrows > [$selbox.selection cget -height]} {
#		$list.selection configure -height $nrows
#	}
#	$selbox.selection see 0
#	after idle [list $selbox.selection see]
}

} ;# namespace notation

# vi:set ts=3 sw=3:
