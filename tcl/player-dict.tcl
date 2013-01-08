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
# Copyright: (C) 2013 Gregor Cramer
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
set PlayerFilter		"Player Filter"
set Count				"Count"
set Ignore				"Ignore"
set FederationID		"Federation ID"
set BirthYear			"Birth Year"
set DeathYear			"Death Year"
set Ratings				"Ratings"
set Titles				"Titles"
set None					"None"
set Operation			"Operation"
set CancelSort			"Cancel sort"

# don't translate
set F_Rating1			Elo
set F_Rating2			DWZ
set F_FederationId	Fide
set F_BirthYear		"\u2605"
set F_DeathYear		"\u2625"

}

namespace import ::tcl::mathfunc::abs

#		ID   			Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------
set Columns {
	{ federation		center	 4		5		 5			0			0			0			darkgreen	}
	{ lastName			left		10		0		40			1			0			1			{}				}
	{ firstName			left		10		0		30			1			0			1			{}				}
	{ federationId		right		10		0		12			0			0			1			{}				}
	{ country			center	 4		5		 5			0			0			0			darkgreen	}
	{ sex					center	 0		0		18px		0			0			0			{}				}
	{ rating1			center	 0		0		 6			0			0			1			darkblue		}
	{ rating2			center	 0		0		 6			0			0			1			darkblue		}
	{ titles				left		 0		0		12			0			0			1			darkred		}
	{ birthYear			center	 5		5		 5			0			0			0			darkgreen	}
	{ deathYear			center	 5		5		 5			0			0			0			darkgreen	}
}

array set Options {
	country-code	flags
	federation		Fide
	rating1:type	Elo
	rating2:type	DWZ
}

set Priv(receiver) {}


proc setReceiver {cmd}	{ set [namespace current]::Priv(receiver) $cmd }
proc unsetReceiver {}	{ set [namespace current]::Priv(receiver) {} }


proc open {parent args} {
	variable ::gametable::ratings
	variable Priv
	variable DefaultFilter
	variable Filter
	variable Columns
	variable Options

	if {$parent eq "."} { set dlg .playerDict } else { set dlg $parent.playerDict }
	if {[winfo exists $dlg]} { return [::widget::dialogRaise $dlg] }

	array set opts {
		-federation	""
		-rating1		""
		-rating2		""
	}
	array set opts $args

	if {[string length $opts(-federation)]} {
		set Options(federation) $opts(-federation)
	}
	if {[string length $opts(-rating1)]} {
		set Options(rating1:type) $opts(-rating1)
	}
	if {[string length $opts(-rating2)]} {
		set Options(rating1:type) $opts(-rating2)
	}

	array unset opts

	tk::toplevel $dlg -class Scidb
	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
	wm withdraw $dlg
	pack $top -fill both -expand yes
	bind $top <Destroy> [namespace code Destroy]

	set Priv(letter) ""

	array set DefaultFilter {
		country			""
		federation		""
		name				""
		federationId	""
		sex				""
		titles			{}
		rating1:min		0
		rating1:max		4000
		rating2:min		0
		rating2:max		4000
		birth:min		0
		birth:max		3000
		death:min		0
		death:max		3000
		operation		reset
	}
	array set Filter [array get DefaultFilter]

	set table $top.table
	set alpha [ttk::frame $top.alpha -takefocus 0 -borderwidth 0]
	ttk::registerbutton $alpha.all \
		-text "*" \
		-padx 7 \
		-command [namespace code [list Letter $table {}]] \
		-variable [namespace current]::Priv(letter) \
		-value "" \
		;
	grid $alpha.all -row 1 -column 1 -sticky ew
	set col 5
	foreach letter {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} {
		set w $alpha.[string tolower $letter]
		ttk::registerbutton $w \
			-text $letter \
			-padx 7 \
			-command [namespace code [list Letter $table $letter]] \
			-variable [namespace current]::Priv(letter) \
			-value $letter \
			;
		grid $w -row 1 -column $col -sticky ew
		grid columnconfigure $alpha $col -uniform letter
		incr col 2
	}

	set mc::F_Rating1 $Options(rating1:type)
	set mc::F_Rating2 $Options(rating2:type)
	set mc::F_FederationId $Options(federation)

	RefreshHeader 1
	RefreshHeader 2

	::scidb::player::dict open player

	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		lassign {"" "" ""} tvar fvar ivar
		set menu {}

		if {$id ne "firstName"} {
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id ascending]] \
				-labelvar ::gametable::mc::SortAscending]
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id descending]] \
				-labelvar ::gametable::mc::SortDescending]
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id reverse]] \
				-labelvar ::gametable::mc::ReverseOrder]
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id cancel]] \
				-labelvar [namespace current]::mc::CancelSort]
			lappend menu { separator }
		}

		switch $id {
			federation - country {
				foreach {labelvar value} {Flags flags PGN_CountryCode PGN ISO_CountryCode ISO} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $table]] \
						-labelvar ::gametable::mc::$labelvar \
						-variable [namespace current]::Options(country-code) \
						-value $value \
					]
				}
				lappend menu separator
			}

			federationId {
				foreach value {Fide DSB ECF ICCF} {
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshFederation $table]] \
						-label "$value ID" \
						-variable [namespace current]::Options(federation) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			rating1 - rating2 {
				foreach ratType $ratings {
					set number [string index $id 6]
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $table $number]] \
						-label $ratType \
						-variable [namespace current]::Options($id:type) \
						-value $ratType \
					]
				}
				lappend menu { separator }
			}
		}

		switch $id {
			titles {
				set tvar [namespace current]::mc::Titles
			}
			birthYear {
				set tvar [namespace current]::mc::BirthYear
				set fvar [namespace current]::mc::F_BirthYear
			}
			deathYear {
				set tvar [namespace current]::mc::DeathYear
				set fvar [namespace current]::mc::F_DeathYear
			}
			country {
				set tvar ::playertable::mc::T_NativeCountry
				set ivar ::playertable::mc::I_Federation
				set fvar ::playertable::mc::F_Federation
			}
			rating1 - rating2 {
				set tvar [namespace current]::mc::T_[string toupper $id 0 0]
				set fvar [namespace current]::mc::F_[string toupper $id 0 0]
			}
			federationId {
				set fvar [namespace current]::mc::F_FederationId
			}
			default {
				set ivar ::playertable::icon::12x12::I_[string toupper $id 0 0]
				set tvar ::playertable::mc::T_[string toupper $id 0 0]
				set fvar ::playertable::mc::F_[string toupper $id 0 0]
			}
		}

		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

		lappend opts -justify $adjustment
		lappend opts -minwidth $minwidth
		lappend opts -maxwidth $maxwidth
		lappend opts -width $width
		lappend opts -stretch $stretch
		lappend opts -removable $removable
		lappend opts -ellipsis $ellipsis
		lappend opts -visible 1
		lappend opts -foreground $color
		lappend opts -menu $menu
		lappend opts -image $ivar
		lappend opts -textvar $fvar
		lappend opts -tooltipvar $tvar

		lappend columns $id $opts

		if {$id ne "firstName"} {
			lappend Priv(columns) $id
		}
	}

	set Priv(table) [::scrolledtable::build $table $columns \
		-configurable no \
		-popupcmd [namespace code PopupMenu] \
		-height 25 \
		-stripes linen \
	]
#		-background #ebf4f5
#		-stripes #cddfe2

	::bind $table <<TableFill>>		[namespace code [list TableFill $table %d]]
	::bind $table <<TableVisit>>		[namespace code [list TableVisit $table %d]]
	::bind $table <<TableSelected>>	[namespace code [list TableSelected $table %d]]

	set Priv(search) ""
	set cmd [namespace code [list Search $table]]
	set lsearch [ttk::label $top.lsearch -textvar [::mc::var ::playertable::mc::Find :]]
	set esearch [ttk::entry $top.esearch -textvariable [namespace current]::Priv(search)]
	set bsearch [ttk::button $top.bsearch \
		-style icon.TButton \
		-image $::icon::22x22::enter \
		-command $cmd \
	]
	::tooltip::tooltip $bsearch ::playertable::mc::StartSearch
	set Priv(search:cmd) [list  [namespace current]::Priv(search) write $cmd]
	trace add variable {*}$Priv(search:cmd)

	grid $alpha		-row 1 -column 1 -sticky w -columnspan 5
	grid $table		-row 3 -column 1 -sticky ewns -columnspan 5
	grid $lsearch	-row 5 -column 1 -sticky w
	grid $esearch	-row 5 -column 3 -sticky ew
	grid $bsearch	-row 5 -column 5 -sticky ew
	grid rowconfigure $top {3} -weight 1
	grid columnconfigure $top {3} -weight 1

	grid columnconfigure $top {0 2 4 6} -minsize $::theme::padx
	grid rowconfigure $top {0 2 4 6} -minsize $::theme::pady

	::widget::dialogButtons $dlg {close}
	$dlg.close configure -command [list destroy $dlg]
	::widget::dialogButtonAdd $dlg filter ::mc::Filter {}
	$dlg.filter configure -command [namespace code [list SetFilter $table]]
	$dlg.filter configure -image $::icon::16x16::filter(inactive) -compound left

	set Priv(label:size) [::tk::label $dlg.size]
	place $Priv(label:size) -in $dlg.__buttons -x $::theme::padx -y $::theme::pady
	bind $dlg.__buttons <Configure> [namespace code [list Place $Priv(label:size)]]
	UpdateCount

	update idletasks
	set minsize [winfo reqwidth $dlg]
	set minheight [expr {[winfo reqheight $dlg] - [winfo reqheight $table]}]
	set height [expr {$minheight + [::scrolledtable::computeHeight $table 30]}]
	set minheight  [expr {$minheight + [::scrolledtable::computeHeight $table 5]}]

	SetDialogHeader $dlg
	wm resizable $dlg yes yes
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm geometry $dlg ${minsize}x${height}
	wm minsize $dlg $minsize $minheight
	::util::place $dlg center [winfo toplevel $parent]
	wm deiconify $dlg

	::scrolledtable::update $table "" "" [::scidb::player::count]
	::scrolledtable::activate $table 0
	::scrolledtable::focus $table
}


proc Place {w} {
	set f [winfo parent $w].__buttons
	set y [expr {([winfo height $f] - [winfo height $w])/2}]
	place $w -in $f -x $::theme::padx -y $y
}


proc Destroy {} {
	variable Priv

	::scidb::player::dict close
	trace remove variable {*}$Priv(search:cmd)
}


proc Search {table args} {
	variable Priv

	set value $Priv(search)
	if {[string length $value] == 0} { return }
	set i [::scidb::player::search $value]
	if {$i >= 0} { ::scrolledtable::see $table $i }
}


proc SortColumn {table id dir} {
	variable Priv
	variable Options

	::widget::busyCursor on
	set ratings [list $Options(rating1:type) $Options(rating2:type)]
	set see 0
	switch $dir {
		cancel {
			::scidb::player::sort cancel
		}
		reverse {
			::scidb::player::sort reverse
		}
		default {
			switch $id {
				rating1 - rating2	{ set id $Options($id:type) }
				federationId		{ set id $Options(federation) }
			}
			::scidb::player::sort $dir $id
		}
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $table -1
}


proc Letter {table alpha} {
	::scidb::player::letter $alpha
	UpdateFilter $table
}


proc UpdateFilter {table} {
	set count [::scidb::player::count]
	::scrolledtable::select $table none
	::scrolledtable::update $table "" "" $count
	if {$count > 0} {
		::scrolledtable::see $table 0
		::scrolledtable::activate $table 0
	}
	UpdateCount
}


proc SetFilter {table} {
	variable Filter
	variable DefaultFilter
	variable Options
	variable Priv
	variable Reply_
	variable Filter_
	variable Title_
	variable Country_

	array set Filter_ [array get Filter]

	foreach title $::titlebox::titles(all) { set Title_($title) 0 }
	foreach title $Filter(titles) { set Title_($title) 1 }

	set parent [winfo toplevel $table]
	set dlg [tk::toplevel $parent.filterDialog -class Scidb]
	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
	wm withdraw $dlg
	pack $top -fill both -expand yes
	bind $top <<LanguageChanged>> [namespace code [list LanguageChanged(filter) $top]]
	set bg [::theme::getBackgroundColor]
	set bold [list [font configure TkTextFont -family] [font configure TkTextFont -size] bold]

	### name / federation / native top #############################
	set general [tk::frame $top.general -relief groove -borderwidth 2 -background $bg]
	ttk::label $general.lname -textvar ::playertable::mc::Name -font $bold
	ttk::entry $general.name -textvar [namespace current]::Filter(name)
	$general.name selection range 0 end
	ttk::label $general.lfed -textvar ::playertable::mc::T_Federation -font $bold
	ttk::label $general.lnat -textvar ::playertable::mc::T_NativeCountry -font $bold
	countrybox $general.fed -height 20
	countrybox $general.nat -height 20
	$general.nat set $Filter(country)
	$general.fed set $Filter(federation)

	grid $general.lname	-row 1 -column 1 -sticky w
	grid $general.name	-row 1 -column 3 -sticky ew
	grid $general.lfed	-row 3 -column 1 -sticky w
	grid $general.fed		-row 3 -column 3 -sticky ew
	grid $general.lnat	-row 5 -column 1 -sticky w
	grid $general.nat		-row 5 -column 3 -sticky ew
	grid columnconfigure $general {0 2 4} -minsize $::theme::padx
	grid columnconfigure $general {3} -weight 1
	grid rowconfigure $general {0 2 4 6} -minsize $::theme::pady

	### federation id type #########################################
	tk::label $top.lids -textvar [namespace current]::mc::FederationID -background $bg -font $bold
	set ids [ttk::labelframe $top.ids -labelwidget $top.lids]
	ttk::radiobutton $ids.ignore \
		-textvar [namespace current]::mc::Ignore \
		-variable [namespace current]::Filter(federationId) \
		-value "" \
		;
	foreach fid {Fide DSB ECF ICCF} {
		ttk::radiobutton $ids.[string tolower $fid] \
			-text $fid \
			-value $fid \
			-variable [namespace current]::Filter(federationId) \
			;
	}
	grid $ids.ignore	-row 1 -column 1
	grid $ids.fide		-row 1 -column 3
	grid $ids.dsb		-row 1 -column 5
	grid $ids.ecf		-row 1 -column 7
	grid $ids.iccf		-row 1 -column 9
#	grid columnconfigure $ids {1 3 5 7 9} -uniform id
	grid columnconfigure $ids {2 4 6 8} -minsize [expr {4*$::theme::padx}]
	grid columnconfigure $ids {0 10} -minsize $::theme::padx -weight 1
	grid rowconfigure $ids {2} -minsize $::theme::pady

	### sex ########################################################
	tk::label $top.lsex -textvar ::playertable::mc::T_Sex -background $bg -font $bold
	set sex [ttk::labelframe $top.sex -labelwidget $top.lsex]
	ttk::radiobutton $sex.any \
		-textvar [namespace current]::mc::Ignore \
		-variable [namespace current]::Filter(sex) \
		-value ""
		;
	ttk::radiobutton $sex.male \
		-textvar ::genderbox::mc::Gender(m) \
		-variable [namespace current]::Filter(sex) \
		-value "m"
		;
	ttk::radiobutton $sex.female \
		-textvar ::genderbox::mc::Gender(f) \
		-variable [namespace current]::Filter(sex) \
		-value "f"
		;
	grid $sex.any		-row 1 -column 1
	grid $sex.male		-row 1 -column 3
	grid $sex.female	-row 1 -column 5
	grid columnconfigure $sex {2 4 6} -minsize [expr {4*$::theme::padx}]
	grid columnconfigure $sex {0 8} -minsize $::theme::padx -weight 1
	grid rowconfigure $sex {0 2} -minsize $::theme::pady

	### ratings ####################################################
	tk::label $top.lratings -textvar [namespace current]::mc::Ratings -background $bg -font $bold
	set ratings [ttk::labelframe $top.ratings -labelwidget $top.lratings]
	foreach i {1 2} {
		ttk::label $ratings.rating$i -text $Options(rating$i:type)
		ttk::spinbox $ratings.min$i \
			-from 0 \
			-to 4000 \
			-textvar [namespace current]::Filter(rating$i:min) \
			-width 5 \
			-justify right \
			;
		ttk::label $ratings.delim$i -text "\u2212"
		ttk::spinbox $ratings.max$i \
			-from 0 \
			-to 4000 \
			-textvar [namespace current]::Filter(rating$i:max) \
			-width 5 \
			-justify right \
			;
	}
	grid $ratings.rating1	-row 1 -column 1
	grid $ratings.min1		-row 1 -column 3
	grid $ratings.delim1		-row 1 -column 4
	grid $ratings.max1		-row 1 -column 5
	grid $ratings.rating2	-row 1 -column 7
	grid $ratings.min2		-row 1 -column 9
	grid $ratings.delim2		-row 1 -column 10
	grid $ratings.max2		-row 1 -column 11
	grid columnconfigure $ratings {0 2 8 12} -minsize $::theme::padx
	grid columnconfigure $ratings {0 12} -weight 1
	grid columnconfigure $ratings {6} -minsize [expr {4*$::theme::padx}]
	grid rowconfigure $ratings {0 2} -minsize $::theme::pady

	### titles #####################################################
	tk::label $top.ltitles -textvar [namespace current]::mc::Titles -background $bg -font $bold
	set titles [ttk::labelframe $top.titles -labelwidget $top.ltitles]
	ttk::button $titles.fide \
		-text "Fide" \
		-style aligned.TButton \
		-command [namespace code [list ToggleTitles Fide]] \
		;
	grid $titles.fide -row 1 -column 1 -sticky w
	set col 3
	foreach title $::titlebox::titles(Fide) {
		set w $titles.[string tolower $title]
		ttk::checkbutton $w -text $title -variable [namespace current]::Title_($title)
		::tooltip::tooltip $w ::titlebox::mc::Title($title)
		grid $w -row 1 -column $col -sticky w
		grid columnconfigure $titles $col -uniform title
		incr col 2
	}
	set col 3
	ttk::button $titles.iccf \
		-text "ICCF" \
		-style aligned.TButton \
		-command [namespace code [list ToggleTitles ICCF]] \
		;
	grid $titles.iccf -row 3 -column 1 -sticky w
	set col 3
	foreach title $::titlebox::titles(ICCF) {
		set w $titles.[string tolower $title]
		ttk::checkbutton $w -text $title -variable [namespace current]::Title_($title)
		::tooltip::tooltip $w ::titlebox::mc::Title($title)
		grid $w -row 3 -column $col -sticky w
		grid columnconfigure $titles $col -uniform title
		incr col 2
	}

	grid columnconfigure $titles {0 20} -minsize $::theme::padx
	grid columnconfigure $titles {2 4 6 8 10 12 14 16 18} -minsize $::theme::padX
	grid columnconfigure $titles {1} -uniform btn
	grid rowconfigure $titles {0 2 4} -minsize $::theme::pady

	### birth/death year ###########################################
	tk::label $top.lyear -background $bg -font $bold
	set year [ttk::labelframe $top.year -labelwidget $top.lyear]
	foreach attr {birth death} {
		ttk::label $year.$attr -textvar [namespace current]::mc::[string toupper $attr 0 0]Year
		ttk::spinbox $year.min$attr \
			-from 0 \
			-to $DefaultFilter($attr:max) \
			-textvar [namespace current]::Filter($attr:min) \
			-width 5 \
			-justify right \
			;
		ttk::label $year.delim$attr -text "\u2212"
		ttk::spinbox $year.max$attr \
			-from 0 \
			-to $DefaultFilter($attr:max) \
			-textvar [namespace current]::Filter($attr:max) \
			-width 5 \
			-justify right \
			;
	}
	grid $year.birth			-row 1 -column 1
	grid $year.minbirth		-row 1 -column 3
	grid $year.delimbirth	-row 1 -column 4
	grid $year.maxbirth		-row 1 -column 5
	grid $year.death			-row 1 -column 7
	grid $year.mindeath		-row 1 -column 9
	grid $year.delimdeath	-row 1 -column 10
	grid $year.maxdeath		-row 1 -column 11
	grid columnconfigure $year {0 2 8 12} -minsize $::theme::padx
	grid columnconfigure $year {0 12} -weight 1
	grid columnconfigure $year {6}  -minsize [expr {4*$::theme::padx}]
	grid rowconfigure $year {0 2} -minsize $::theme::pady

	### operation ##################################################
	tk::label $top.loperation -textvar [namespace current]::mc::Operation -background $bg -font $bold
	set operation [ttk::labelframe $top.operation -labelwidget $top.loperation]
	set col 1
	foreach op {reset or and null remove not} {
		set w $operation.$op
		ttk::radiobutton $w \
			-style darker.TRadiobutton \
			-textvar ::mc::Logical($op) \
			-variable [namespace current]::Filter(operation) \
			-value $op \
			;
		::tooltip::tooltip $w ::mc::LogicalDetail($op)
		grid $w -row 1 -column $col -sticky w
#		grid columnconfigure $operation $col -uniform op
		incr col 2
	}
	grid columnconfigure $operation {0 2 4 6 8 10 12} -minsize [expr {4*$::theme::padx}]
	grid columnconfigure $operation {0 12} -weight 1
	grid rowconfigure $operation {0 2} -minsize $::theme::pady

	### layout #####################################################
	grid $general		-row  1 -column 1 -sticky ew
	grid $ids			-row  3 -column 1 -sticky ew
	grid $sex			-row  5 -column 1 -sticky ew
	grid $ratings		-row  7 -column 1 -sticky ew
	grid $titles		-row  9 -column 1 -sticky ew
	grid $year			-row 11 -column 1 -sticky ew
	grid $operation	-row 13 -column 1 -sticky ew

	grid columnconfigure $top {0 2} -minsize $::theme::padx
	grid rowconfigure $top {0 2 4 6 8 10 12 14} -minsize $::theme::pady

	### popup ######################################################
	::widget::dialogButtons $dlg {ok cancel reset} -default ok
	::widget::dialogButtonReplace $dlg reset revert
	$dlg.ok configure -command [list set [namespace current]::Reply_ ok]
	$dlg.cancel configure -command [list set [namespace current]::Reply_ cancel]
	$dlg.reset configure -command [namespace code [list ResetFilter $top]]
	LanguageChanged(filter) $top
	wm resizable $dlg no no
	wm protocol $dlg WM_DELETE_WINDOW [list set [namespace current]::Reply_ cancel]
	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center $parent
	::ttk::grabWindow $dlg
	wm deiconify $dlg
	focus $general.name
	tkwait visibility $dlg
	tkwait variable [namespace current]::Reply_
	::ttk::releaseGrab $dlg

	if {$Reply_ eq "cancel"} { return [destroy $dlg] }
	set Filter(titles) {}

	foreach title $::titlebox::titles(all) {
		if {$Title_($title)} { lappend Filter(titles) $title }
	}

	set Filter(country) [$general.nat value]
	set Filter(federation) [$general.fed value]

	destroy $dlg

	if {[arrayEqual Filter Filter_]} { return }

	::widget::busyCursor on
	set filter {}

	while {[string range $Filter(name) end-1 end] eq "**"} {
		set Filter(name) [string range $Filter(name) 0 end-1]
	}
	if {$Filter(operation) eq "reset"} {
		if {$Filter(name) eq "*"} {
			set Priv(letter) ""
			::scidb::player::letter $Priv(letter)
			set Filter(name) ""
		} elseif {[string match {[A-Z]\*} $Filter(name)]} {
			set Priv(letter) [string index $Filter(name) 0]
			::scidb::player::letter $Priv(letter)
			set Filter(name) ""
		}
	}

	if {[string length $Filter(name)] && [string first "*" $Filter(name)] == -1} {
		append Filter(name) "*"
	}

	foreach attr {country federation name federationId sex titles} {
		if {$Filter($attr) ne $DefaultFilter($attr)} {
			lappend filter $attr $Filter($attr)
		}
	}

	foreach attr {rating1 rating2} {
		if {	$Filter($attr:min) ne $DefaultFilter($attr:min)
			|| $Filter($attr:max) ne $DefaultFilter($attr:max)} {
			lappend filter $attr [list $Options($attr:type) $Filter($attr:min) $Filter($attr:max)]
		}
	}

	foreach attr {birth death} {
		if {	$Filter($attr:min) ne $DefaultFilter($attr:min)
			|| $Filter($attr:max) ne $DefaultFilter($attr:max)} {
			lappend filter $attr [list $Filter($attr:min) $Filter($attr:max)]
		}
	}

	if {[llength $filter] == 0} { set Filter(operation) reset }

	if {[arrayEqual Filter DefaultFilter]} { set state inactive } else { set state active }
	$parent.filter configure -image $::icon::16x16::filter($state)
	::scidb::player::filter $Filter(operation) $filter
	UpdateFilter $table
	::widget::busyCursor off
}


proc LanguageChanged(filter) {top} {
	$top.lyear configure -text "$mc::BirthYear / $mc::DeathYear"
	SetDialogHeader [winfo toplevel $top]
}


proc ToggleTitles {federation} {
	variable Title_

	set state 1
	foreach title $::titlebox::titles($federation) {
		if {$Title_($title)} { set state 0 }
	}
	foreach title $::titlebox::titles($federation) {
		set Title_($title) $state
	}
}


proc ResetFilter {top} {
	variable DefaultFilter
	variable Filter
	variable Title_

	array set Filter [array get DefaultFilter]

	foreach title $::titlebox::titles(all) { set Title_($title) 0 }
	foreach title $Filter(titles) { set Title_($title) 1 }

	$top.general.nat set $Filter(country)
	$top.general.fed set $Filter(federation)
}


proc UpdateCount {} {
	variable Priv
	$Priv(label:size) configure -text "$mc::Count: [::locale::formatNumber [::scidb::player::count]]"
}


proc TableFill {table args} {
	variable Priv
	variable Options

	lassign [lindex $args 0] table _ _ start first last columns

	set last [expr {min($last, [scidb::player::count] - $start)}]
	set ratings [list $Options(rating1:type) $Options(rating2:type)]

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [scidb::player::info $index -ratings $ratings -federation $Options(federation)]
		set text {}
		set k 0

		foreach id $columns {
			set item [lindex $line $k]

			switch $id {
				lastName {
					if {[string length $item] == 0} {
						lappend text "-" ""
					} else {
						set parts [split $item ,]
						lappend text [lindex $parts 0] [lindex [lrange $parts 1 end] 0]
					}
				}

				firstName {
					incr k -1
				}

				federationId {
					if {[string index $item 0] eq "-"} {
						lappend text "*[string range $item 1 end]"
					} else {
						lappend text $item
					}
				}

				sex {
					switch $item {
						m			{ set icon $::icon::12x12::male }
						f			{ set icon $::icon::12x12::female }
						c			{ set icon $::icon::12x12::program }
						default	{ set icon {} }
					}
					lappend text [list @ $icon]
				}

				rating1 - rating2 {
					if {$item == 0} {
						lappend text ""
					} else {
						lappend text [format " %4d " $item]
					}
				}

				titles {
					lappend text [join $item " "]
				}

				federation - country {
					if {[string length $item] == 0} {
						if {$Options(country-code) eq "flags"} {
							lappend text [list @ {}]
						} else {
							lappend text {}
						}
					} else {
						switch $Options(country-code) {
							flags	{ lappend text [list @ $::country::icon::flag($item)] }
							PGN	{ lappend text $item }
							ISO	{ lappend text [::country::iso $item] }
						}
					}
				}

				birthYear - deathYear {
					if {$item == 0} { lappend text "" } else { lappend text $item }
				}

				default {
					lappend text $item
				}
			}

			incr k
		}

		::table::insert $table $i $text
	}
}


proc TableSelected {table index} {
	variable Priv

	if {[llength $Priv(receiver)]} {
		set info [scidb::player::info $index]
		{*}$Priv(receiver) [lrange [scidb::player::info $index] 1 2]
	} else {
		::scrolledtable::select $table none 
	}
}


proc TableVisit {table data} {
	variable Priv

	lassign $data _ _ mode id row

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	set tip ""
	set info [scidb::player::info [::scrolledtable::rowToIndex $table $row]]

	switch $id {
		federation {
			set code [lindex $info 0]
			if {[string length $code]} {
				set tip [::country::name $code]
			}
		}
		country {
			set code [lindex $info 3]
			if {[string length $code]} {
				set tip [::country::name $code]
			}
		}
		titles {
			foreach title [lindex $info 7] {
				if {[string length $tip]} { append tip \n }
				append tip $::titlebox::mc::Title($title)
			}
		}
	}

	if {[string length $tip]} {
		::tooltip::show $table $tip
	}
}


proc RefreshRatings {table number} {
	RefreshHeader $number
	::scrolledtable::refresh $table
}


proc RefreshFederation {table} {
	variable Options

	set mc::F_FederationId $Options(federation)
	::scrolledtable::refresh $table
}


proc RefreshHeader {number} {
	variable Options

	set mc::F_Rating$number $Options(rating$number:type)
	set mc::T_Rating$number [format $::playertable::mc::TooltipRating $Options(rating$number:type)]
}


proc SetDialogHeader {dlg} {
	wm title $dlg $mc::PlayerDictionary
}


proc Refresh {table} {
	::scrolledtable::clear $table
	::scrolledtable::refresh $table
}


proc PopupMenu {table menu _ _ index} {
	if {![string is digit -strict $index]} { return }
	set info [scidb::player::info $index -web 1]
	::playercard::buildWebMenu $table $menu $info
}

} ;# namespace playerdict

# vi:set ts=3 sw=3:
