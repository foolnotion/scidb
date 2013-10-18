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
# Copyright: (C) 2012-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source figurines

namespace eval figurines {
namespace eval mc {

set Figurines	"Figurines"
set Graphic		"Graphic"
set User			"User"

} ;# namespace mc

# Sources:
# 	http://en.wikipedia.org/wiki/Algebraic_chess_notation
# 	http://www.geocities.com/timessquare/metro/9154/nap-pieces.htm
#
# Alternatives:
#	ru	{K F L S N P}
#	sr	{K D T L S P}
array set langSet {
	graphic	{\u2654 \u2655 \u2656 \u2657 \u2658 \u2659}
	user		{K Q R B N P}
	az			{S V T F A P}
	bg			{\u0426 \u0414 \u0422 \u041e \u041a \u041f}
	ca			{R D T A C P}
	cs			{K D V S J P}
	cy			{T B C E M G}
	da			{K D T L S B}
	de			{K D T L S B}
	el			{\u03a1 \u0392 \u03a0 \u0391 \u0399 \u03a3}
	en			{K Q R B N P}
	es			{R D T A C P}
	et			{K L V O R E}
	eu			{E D G Z S P}
	fi			{K D T L R S}
	fr			{R D T F C P}
	ga			{R B C E D F}
	gl			{R D T B C P}
	hi			{R V H O G P}
	hr			{K D T L S P}
	hu			{K V B F H G}
	is			{K D H B R P}
	it			{R D T A C P}
	lb			{K D T L P B}
	lt			{K V B R \u017d P}
	lv			{K D T L Z B}
	nl			{K D T L P O}
	no			{K D T L S B}
	pl			{K H W G S P}
	pt			{R D T B C P}
	ro			{R D T N C P}
	ru			{\u0420 \u0424 \u041b \u0421 \u041a \u041f}
	sk			{K D V S J P}
	sl			{K D T L S P}
	sr			{\u041a \u0414 \u0422 \u041b \u0421 \u041f}
	sv			{K D T L S B}
	tr			{\u015e V K F A P}
	uk			{\u0420 \u0424T \u0421 \u041a \u041f}
}
# TODO ------------------------------------------
#	sq			------	Albanian			Mbret	Mbretëreshë Top  		Oficier  	Kal  	 	Pion
#	br			------	Breton			roue 	rouanez 		tour 		marc'heg 	furlukin	pezh-gwerin
#	gl			------	Galician			rei 	raíña 		torre		 cabalo 		bispo 	peón
#	ku			------	Kurdish			ah 	abanî 		birc 		metran 		siwar 	piyon
#	se			------	Sami
#	gd			------	Scotish
#	dsb		------	Lower Sorbian	kral 	dama 			torm 		bga 			kónik 	burik
#	hsb		------	Upper Sorbian	kral 	dama 			wa 		bhar 			konik 	burik
#	he			------	Hebraic			mele	malkah		tseriya	rats			para		ragl
# Auxiliary -------------------------------------
#	af			KDTLRP
#	FI			KDTSNP
#	fy			KDSFHB
#	hi			RVHOGP
#	id			RMBGKP
#	ko			KQRBNP
# Unused-----------------------------------------
#	eo			{R D T K C \u0108}	Esperanto
#	he			{\u05de "\u05d4\u05de" \u05e6 \u05e8 \u05e4 "\u05d9\u05dc\u05d2\u05e8"} Hebraic
#	la			{K G T E Q P}			Interlingua
#	ia			{R G T E C P}			Latin
#	ms			{R M T K G A}			Malay
# -----------------------------------------------

variable pieceMap {
	K "\u2654"
	Q "\u2655"
	R "\u2656"
	B "\u2657"
	N "\u2658"
	P "\u2659"
}

variable unicodeMap {
	"\u2654" K
	"\u2655" Q
	"\u2656" R
	"\u2657" B
	"\u2658" N
	"\u2659" P
}


proc mapToLocal {str lang} {
	variable Map_
	variable langSet

	if {![info exists Map_($lang)]} {
		foreach loc $langSet($lang) uni $langSet(graphic) {
			lappend Map_($lang) $uni $loc
		}
	}

	return [string map $Map_($lang) $str]
}


proc listbox {path args} {
	variable langSet
	variable unicodeMap

	namespace eval [namespace current]::${path} {}
	variable ${path}::Figurines
	variable ${path}::FigurinesList
	variable ${path}::Connect
	variable ${path}::Variable

	array set opts $args
	if {[info exists opts(-variable)]} {
		set Variable $opts(-variable)
		array unset opts -variable
		set args [array get opts]
		if {[llength [set $Variable]] == 0} { lset $Variable $langSet(user) }
	} else {
		set Variable [namespace current]::langSet(user)
	}

	set Connect {}
	set Figurines {}
	foreach lang [array names langSet] {
		if {$lang ne "graphic" && $lang ne "user"} {
			lappend Figurines [list $lang [::encoding::languageName $lang]]
		}
	}
	set Figurines [lsort -index 1 -dictionary $Figurines]
	set Figurines [linsert $Figurines 0 [list graphic $mc::Graphic]]
	set Figurines [linsert $Figurines 1 [list user $mc::User]]
	set FigurinesList {}
	foreach entry $Figurines { lappend FigurinesList [lindex $entry 1] }

	ttk::labelframe $path -text $mc::Figurines
	set list [ttk::frame $path.list -takefocus 0]
	set selbox [::tlistbox $list.selection -exportselection 0 -pady 1 -borderwidth 1 {*}$args]
	$selbox addcol image -id icon
	$selbox addcol text -id text -expand yes
	foreach entry $Figurines {
		lassign $entry lang name
		set img $::country::icon::flag([::mc::countryForLang $lang])
		$selbox insert [list $img $name]
	}
	pack $selbox -anchor s -fill both -expand yes
#	bind $list <Configure> [namespace code { ConfigureListbox %W %h }]
	bind $path <FocusIn> { focus [tk_focusNext %W] }
	bind $list <FocusIn> { focus [tk_focusNext %W] }
	set sample [ttk::frame $path.sample -borderwidth 0 -takefocus 0]

	set text [tk::text $sample.text \
		-borderwidth 1 \
		-relief sunken \
		-background white \
		-state disabled \
		-exportselection 0 \
		-cursor {} \
		-width 0 \
		-height 1 \
		-takefocus 0 \
	]
	bind $text <Any-Button> { break }
	bind $text <Any-Key> { break }
	$text tag configure text -font TkTextFont -justify center
	$text tag configure figurine -font $::font::figurine(text:normal) -justify center
	bind $selbox <<ListboxSelect>> [namespace code [list SetFigurines $path]]

	set user [ttk::frame $sample.user -borderwidth 0 -takefocus 0]
	for {set i 0} {$i < 6} {incr i} {
		ttk::label $user.l$i \
			-font $::font::figurine(text:normal) \
			-text "[lindex $unicodeMap [expr {2*$i}]]:" \
			;
		variable Piece
		set Piece($i) [lindex [set $Variable] $i]
		ttk::entry $user.e$i \
			-width 2 \
			-exportselection no \
			-textvariable [namespace current]::Piece($i) \
			;
		bind $user.e$i <FocusIn> [list $user.e$i selection range 0 end]
		bind $user.e$i <FocusOut> [list $user.e$i selection clear]
		bind $user.e$i <FocusOut> +[namespace code [list SetPiece $path $i]]
		bind $user.e$i <FocusOut> +[namespace code [list SetFigurines $path]]
		grid $user.l$i -row 1 -column [expr {3*$i + 1}]
		grid $user.e$i -row 1 -column [expr {3*$i + 2}]
	}
	grid columnconfigure $user {3 6 9 12 15} -minsize 1
	grid columnconfigure $user {0 17} -weight 1

	grid $user -row 1 -column 1 -sticky nsew
	grid $text -row 1 -column 1 -sticky nsew

	grid $list   -row 1 -column 1 -sticky nsew
	grid $sample -row 3 -column 1 -sticky nsew
	grid rowconfigure $path {0 4} -minsize $::theme::padding
	grid rowconfigure $path 2 -minsize $::theme::padding
	grid rowconfigure $path 1 -weight 1
	grid columnconfigure $path {0 2} -minsize $::theme::padding
	grid columnconfigure $path 1 -weight 1

	catch { rename ::$path $path.__figurines__ }
	proc ::$path {command args} "[namespace current]::WidgetProc $path \$command {*}\$args"

	return $path
}


proc WidgetProc {w command args} {
	variable ${w}::Figurines

	switch -- $command {
		lang {
			return [lindex $Figurines $w.list.selection curselection]]
		}

		select {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] select <set>\""
			}
			set lang [lindex $args 0]
			if {[string length $lang] == 0} { set lang $::mc::langID }
			set index [lsearch -exact -index 0 $Figurines $lang]
			return [$w.list.selection select $index]
		}

		connect {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] connect <widget>\""
			}
			set [namespace current]::${w}::Connect [lindex $args 0]
			return
		}
	}

	return [$w.list.selection $command {*}$args]
}


proc SetFigurines {w} {
	variable ${w}::Figurines
	variable ${w}::Connect
	variable langSet

	set t $w.sample.text
	set sel [$w.list.selection curselection]
	if {$sel == -1} { return }
	set lang [lindex $Figurines $sel 0]
	$t configure -state normal
	$t delete 1.0 end
	if {$lang eq "user"} {
		raise $w.sample.user
		set state normal
	} else {
		raise $t
		set state disabled
	}
	for {set i 0} {$i < 6} {incr i} { $w.sample.user.e$i configure -state $state }
	if {$lang eq "graphic"} { set tag figurine } else { set tag text }
	$t insert end [join $langSet($lang) " "] $tag
 	$t configure -state disabled

	if {[llength $Connect]} { $Connect setlang $lang }
	event generate $w <<ListboxSelect>> -data $lang
}


proc SetPiece {path i} {
	variable ${path}::Variable
	variable langSet
	variable Piece

	lset $Variable $i $Piece($i)
}


proc ConfigureListbox {list height} {
	set h [winfo height $list.selection]
	set n [$list.selection curselection]
	set linespace [$list.selection cget -linespace]
	set nrows [expr {$height/$linespace}]
	if {$nrows > [$list.selection cget -height]} {
		$list.selection configure -height $nrows
	}
	$list.selection resize -height
	$list.selection see 0
	after idle [list $list.selection see]
}


proc WriteOptions {chan} { ::options::writeItem $chan [namespace current]::langSet(user) }
::options::hookWriter [namespace current]::WriteOptions

} ;# namespace figurines

# vi:set ts=3 sw=3:
