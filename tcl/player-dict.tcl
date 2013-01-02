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

::util::source player-dictionary

namespace eval playerdict {
namespace eval mc {

set PlayerDictionary	"Player Dictionary"

}


proc open {parent} {
	variable Priv

	set dlg $parent.playerDict
	if {[winfo exists $dlg]} { return [::widget::dialogRaise $dlg] }
	tk::toplevel $dlg -class Scidb
	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
	wm withdraw $dlg
	pack $top -fill both -expand yes

	set linespace [expr {min(18,[font metrics TkTextFont -linespace])}]
	set lb [::tlistbox $top.list \
		-height 20 \
		-borderwidth 1 \
		-relief sunken \
		-selectmode browse \
		-stripes #ebf4f5 \
		-usescroll yes \
		-setgrid 1 \
		-linespace $linespace \
	]

	bind $dlg <Any-Key> [namespace code [list Search $lb %K]]
#	bind $lb <<ListboxSelect>> [namespace code [list OpenPlayerCard $dlg %d]]
	bind $lb <<ItemVisit>> [namespace code [list VisitItem $lb %d]]
	bind $lb <<HeaderVisit>> [namespace code [list VisitHeader $lb %d]]
	bind $lb <<LanguageChanged>> [namespace code [list SetDialogHeader $dlg]]
	$lb bind <ButtonPress-3> [namespace code [list PopupMenu $lb %x %y]]

	$lb addcol image -id country -justify center -headervar ::engine::mc::Country
	$lb addcol text  -id name -headervar ::playertable::mc::Name -witdh 30
	$lb addcol text -id fideid -text ::playertable::mc::FideID -witdh 8 -justify right
	$lb addcol image  -id sex -justify center -headervar ::playertable::mc::T_Sex
	$lb addcol text -id elo -justify right -header "Elo"
	$lb addcol text -id rating -justify right -headervar ::engine::mc::Rating
	$lb addcol text -id title -justify center -headervar ::playertable::mc::F_Title
	$lb addcol text -id birthday -headervar ::playertable::mc::DateOfBirth
	$lb addcol text -id deathday -headervar ::playertable::mc::DateOfDeath

	grid $lb -row 1 -column 1 -sticky ewns
	grid rowconfigure $top {1} -weight 1
	grid columnconfigure $top {1} -weight 1

	grid columnconfigure $top {0 2} -minsize $::theme::padx
	grid rowconfigure $top {0 2} -minsize $::theme::pady

	set Priv(sort) name
	MakePlayerList
	FillDict $lb
	$lb resize
	$lb fixwidth

	::widget::dialogButtons $dlg {close}
	::widget::dialogButtonAdd $dlg filter ::mc::Filter {}
	$dlg.close configure -command [list destroy $dlg]
	$dlg.filter configure -command [namespace code [list SetFilter $lb]]
	$dlg.filter configure -image $::icon::16x16::filter(inactive) -compound left

	SetDialogHeader $dlg
	wm resizable $dlg yes yes
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg center [winfo toplevel $parent]
	wm deiconify $dlg

	if {[llength $Priv(list)]} {
		focus $lb
		$lb select 0
	}
}


proc SetDialogHeader {dlg} {
	wm title $dlg $mc::PlayerDictionary
}


proc VisitHeader {lb data} {
	variable Priv

	lassign $data mode id column

	if {$mode eq "leave"} {
		return [::tooltip::tooltip hide]
	}

#	tooltip::show $lb $tip
}


proc VisitItem {lb data} {
	variable Priv

	lassign $data mode id index column

	if {$mode eq "leave"} {
		return [::tooltip::tooltip hide]
	}

#	tooltip::show $lb $tip
}


proc MakePlayerList {{letter "A"}} {
	variable Priv

	# each entry consists of:
	# <name> <native-country> <federation> <sex> <birthDay> <deathDay>
	# <titles> <FIDE-ID> <ICCF-ID> <DSB-ID> <ECF-ID> <list-of-ratings>

	set Priv(indices) [::scidb::player::list $letter]
	set Priv(list) {}

	foreach index $Priv(indices) {
		lappend Priv(list) [::scidb::player::info $index]
	}

	set args {}

	switch $Priv(sort) {
		name			{ set index 0; set args {-dictionary -nopunct} }
		country		{ set index 1 }
		federation	{ set index 2 }
		sex			{ set index 3 }
		birthDay		{ set index 4 }
		deathDay		{ set index 5 }
		titles		{ set index 6 }
		fideID		{ set index 7; set args -integer }
		iccfID		{ set index 8; set args -integer }
		dsbID			{ set index 9 }
		ecfID			{ set index 10 }
		elo			{ set index {11 0}; set args -integer }
		rating		{ set index {11 1}; set args -integer }
		rapid			{ set index {11 2}; set args -integer }
		iccf			{ set index {11 3}; set args -integer }
		uscf			{ set index {11 4}; set args -integer }
		dwz			{ set index {11 5}; set args -integer }
		ecf			{ set index {11 6}; set args -integer }
		ips			{ set index {11 7}; set args -integer }
	}

	set Priv(sorted) [::scidb::misc::sort {*}$args -index $index -indices $Priv(list)]
}


proc FillDict {lb} {
	variable Priv

	$lb clear

	foreach index $Priv(sorted) {
		set entry [lindex $Priv(list) [lindex $Priv(sorted) $index]]
		lassign $entry name country federation sex birthDay deathDay titles fide iccf dsb ecf ratings
		if {[string length $federation]} {
			set flag $::country::icon::flag($federation)
		} else {
			set flag ""
		}
		switch $sex {
			m { set gender $::icon::12x12::male }
			f { set gender $::icon::12x12::female }
			c { set gender $::icon::12x12::program }
		}
		set elo [lindex $ratings 0]
		set dwz [lindex $ratings 5]
		set titles [join $titles ", "]
		if {$fide == 0} { set fide "" }
		if {$elo == 0} { set elo "" }
		if {$dwz == 0} { set dwz "" }
		$lb insert [list $flag $name $fide $gender $elo $dwz $titles $birthDay $deathDay]
	}
}

} ;# namespace playerdict

# vi:set ts=3 sw=3:
