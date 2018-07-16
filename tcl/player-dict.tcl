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
# Copyright: (C) 2013-2017 Gregor Cramer
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

set PlayerDictionary		"Player Dictionary"
set PlayerFilter			"Player Filter"
set OrganizationID		"Organization ID"
set Count					"Count"
set Ignore					"Ignore"
set Ratings					"Ratings"
set Titles					"Titles"
set None						"None"
set Operation				"Operation"
set Awarded					"Awarded"
set RangeOfYears			"Range of years"
set SearchPlayerName		"Search Player Name"
set HelpPatternMatching	"Help: Pattern Matching"

set ChessChampion	"%sex% %mode% %age% %region% %champion% %where%"
set Sex(f)			"Woman"
set Sex(m)			""
set Region(w)		"World"
set Region(e)		"European"
set Region(-)		"National"
set Champion(w)	"Champion"
set Champion(e)	"Champion"
set Champion(-)	"Champion"
set Age(j)			"Junior"
set Age(s)			"Senior"
set Age(-)			""
set Mode(c)			"Correspondence"
set Mode(-)			""
set Where			"in %country%"

set AgeClass(unrestricted)	"Unrestricted"
set AgeClass(junior)			"Junior"
set AgeClass(senior)			"Senior"

set Champions(world)	"World Champions"
set Champions(eu)		"European Champions"
set Champions(nat)	"National Champions"

set T_Ranking	"Ranking"
set T_Trophy	"Trophäen"

# don't translate
set F_Rating1			Elo
set F_Rating2			DWZ
set F_Ranking			"\u2460"
set F_Organization	FIDE

}

namespace import ::tcl::mathfunc::abs

#		ID   			Adjustment	Min	Max	Width	Stretch	Elipsis	Color
#	----------------------------------------------------------------------------
set Columns {
	{ country			center	 4		 5		 5			0		0			darkgreen	}
	{ lastName			left		10		 0		40			1		1			{}				}
	{ firstName			left		10		 0		30			1		1			{}				}
	{ organization		right		10		 0		12			0		1			{}				}
	{ federation		center	 4		 5		 5			0		0			darkgreen	}
	{ sex					center	 0		 0		18px		0		0			{}				}
	{ rating1			center	 0		 0		 6			0		1			darkblue		}
	{ rating2			center	 0		 0		 6			0		1			darkblue		}
	{ titles				left		 5		19		 9			0		1			darkgreen	}
	{ dateOfBirth		center	 5		10		 5			0		1			darkgreen	}
	{ dateOfDeath		center	 5		10		 5			0		1			darkgreen	}
	{ frequency			right		 4		10		 6			0		1			{}				}
}
#	{ ranking1			center	 0		 0		 4			0		0			darkred		} ;# after rating1
#	{ ranking2			center	 0		 0		 4			0		0			darkred		} ;# after rating2
#	{ trophy				center	 0		 0		18px		0		0			{}				} ;# after titles

array set Options {
	country-code				flags
	organization				Fide
	title-year					no
	rating1:type				Elo
	rating2:type				DWZ
	stripes						playerdict,stripes
	date-format					year
	trophy:region:world		1
	trophy:region:eu			1
	trophy:region:nat			1
	trophy:mode:otb			1
	trophy:mode:pm				1
	trophy:age:unrestricted	1
	trophy:age:junior			1
	trophy:age:senior			1
	trophy:under:8				1
	trophy:under:10			1
	trophy:under:12			1
	trophy:under:14			1
	trophy:under:16			1
	trophy:under:18			1
	trophy:under:20			1
}

array set Priv {
	receiver ""
	dialog	""
}

set History {}


proc setReceiver {cmd}	{ set [namespace current]::Priv(receiver) $cmd }
proc unsetReceiver {}	{ set [namespace current]::Priv(receiver) {} }
proc dialog {}				{ return [set [namespace current]::Priv(dialog)] }


proc open {parent args} {
	variable ::gametable::ratings
	variable Priv
	variable DefaultFilter
	variable Filter
	variable Columns
	variable Options

	if {[string length $Priv(dialog)]} {
		::widget::dialogRaise $Priv(dialog)
		return
	}

	if {$parent eq "."} { set dlg .playerDict } else { set dlg $parent.playerDict }
	if {[winfo exists $dlg]} { return [::widget::dialogRaise $dlg] }
	set Priv(dialog) $dlg

	array set opts {
		-organization	""
		-rating1			""
		-rating2			""
	}
	array set opts $args

	if {[string length $opts(-organization)]} {
		set Options(organization) $opts(-organization)
	}
	if {[string length $opts(-rating1)]} {
		set Options(rating1:type) $opts(-rating1)
	}
	if {[string length $opts(-rating2)]} {
		set Options(rating2:type) $opts(-rating2)
	}

	array unset opts

	tk::toplevel $dlg -class Scidb
	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
	wm withdraw $dlg
	pack $top -fill both -expand yes
	bind $top <Destroy> [namespace code Destroy]
	bind $top <<LanguageChanged>> [namespace code [list LanguageChanged(dictionary) $dlg]]

	set Priv(letter) ""
	set Priv(filter) {}

	array set DefaultFilter {
		country				""
		federation			""
		name					""
		organization		""
		sex					""
		titles				{}
		titles:range		{0 3000}
		titles:type			""
		rating1:range		{0 4000}
		rating2:range		{0 4000}
		trophy:region		""
		trophy:range		{0 3000}
		birth:range			{0 3000}
		death:range			{0 3000}
		frequency:range	{0 unlimited}
		operation			reset
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
	set mc::F_Organization "$Options(organization) ID"

	RefreshHeader 1
	RefreshHeader 2
	EvalTrophyFlags

	::scidb::player::dict open player

	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch ellipsis color
		lassign {"" "" ""} tvar fvar ivar
		set menu {}

		if {$id ne "firstName"} {
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id ascending]] \
				-labelvar ::gametable::mc::SortAscending] \
				;
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id descending]] \
				-labelvar ::gametable::mc::SortDescending] \
				;
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id reverse]] \
				-labelvar ::gametable::mc::ReverseOrder] \
				;
			lappend menu [list command \
				-command [namespace code [list SortColumn $table $id cancel]] \
				-labelvar ::gametable::mc::CancelSort] \
				;
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
			}

			organization {
				foreach value $::organizationbox::organizations {
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshOrganization $table]] \
						-label "$value ID" \
						-variable [namespace current]::Options(organization) \
						-value $value \
					]
				}
			}

			rating1 - rating2 {
				foreach ratType $ratings {
					if {$ratType ne "Any"} {
						set number [string index $id 6]
						lappend menu [list radiobutton \
							-command [namespace code [list RefreshRatings $table $number]] \
							-label $ratType \
							-variable [namespace current]::Options($id:type) \
							-value $ratType \
						]
					}
				}
			}

			titles {
#				lappend menu [list checkbutton \
#					-command [namespace code [list Refresh $table]] \
#					-labelvar ::playertable::mc::ShowTitleYear \
#					-variable [namespace current]::Options(title-year) \
#				]
			}

			trophy {
#				foreach region {world eu nat} {
#					lappend menu [list checkbutton \
#						-command [namespace code [list Refresh $table]] \
#						-labelvar [namespace current]::mc::Champions($region) \
#						-variable [namespace current]::Options(trophy:region:$region) \
#					]
#				}
#				lappend menu { separator }
#				foreach mode {otb pm} {
#					lappend menu [list checkbutton \
#						-command [namespace code [list Refresh $table]] \
#						-labelvar ::eventmodebox::mc::[string toupper $mode] \
#						-variable [namespace current]::Options(trophy:mode:$mode) \
#					]
#				}
#				lappend menu { separator }
#				foreach cls {unrestricted junior senior} {
#					lappend menu [list checkbutton \
#						-command [namespace code [list Refresh $table]] \
#						-labelvar [namespace current]::mc::AgeClass($cls) \
#						-variable [namespace current]::Options(trophy:age:$cls) \
#					]
#				}
#				lappend menu { separator }
#				foreach age {8 10 12 14 16 18 20} {
#					lappend menu [list checkbutton \
#						-command [namespace code [list Refresh $table]] \
#						-label "U$age" \
#						-variable [namespace current]::Options(trophy:under:$age) \
#					]
#				}
			}

			dateOfBirth - dateOfDeath {
#				lappend menu [list checkbutton \
#					-command [namespace code [list Refresh $table]] \
#					-labelvar ::playertable::mc::ShowFullDate \
#					-variable [namespace current]::Options(date-format) \
#				]
			}
		}

		switch $id {
			titles {
				set fvar ::playertable::mc::F_Title
			}
			dateOfBirth {
				set fvar ::playertable::mc::F_DateOfBirth
				set tvar ::playertable::mc::T_DateOfBirth
			}
			dateOfDeath {
				set fvar ::playertable::mc::F_DateOfDeath
				set tvar ::playertable::mc::T_DateOfDeath
			}
			country {
				set tvar ::playertable::mc::T_NativeCountry
				set ivar ::playertable::mc::I_Federation
				set fvar ::playertable::mc::F_Federation
			}
			rating1 {
				set tvar [namespace current]::mc::T_Rating1
				set fvar [namespace current]::mc::F_Rating1
			}
			rating2 {
				set tvar [namespace current]::mc::T_Rating1
				set fvar [namespace current]::mc::F_Rating2
			}
			ranking1 - ranking2 {
				set fvar [namespace current]::mc::F_Ranking
				set tvar [namespace current]::mc::T_Ranking
			}
			organization {
				set fvar [namespace current]::mc::F_Organization
			}
			trophy {
				set tvar [namespace current]::mc::T_Trophy
			}
			frequency {
				set fvar ::playertable::mc::F_Frequency
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
		lappend opts -removable 0
		lappend opts -optimizable 0
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
		-stripes $Options(stripes) \
	]

	::bind $table <<TableFill>>		[namespace code [list TableFill $table %d]]
	::bind $table <<TableVisit>>		[namespace code [list TableVisit $table %d]]
	::bind $table <<TableSelected>>	[namespace code [list TableSelected $table %d]]

	set count [::tk::label $top.size -borderwidth 1 -relief sunken]
	set Priv(label:size) $count
	UpdateCount

	set Priv(subscribe) [list [list [namespace current]::UpdateDatabaseInfo $table]]
	::scidb::db::subscribe dbInfo {*}$Priv(subscribe)

	set search [searchentry $top.search \
		-history [namespace current]::History \
		-helpinfo [namespace current]::mc::HelpPatternMatching \
		-ghosttextvar [namespace current]::mc::SearchPlayerName \
		-parent $dlg \
		-takefocus 1 \
		-mode key \
	]
	bind $search <<Find>>		[namespace code [list Find $table first %d]]
	bind $search <<FindNext>>	[namespace code [list Find $table next %d]]
	bind $search <<Help>>		[list ::help::open .application Pattern-Matching]

	::searchentry::bindShortcuts $dlg

	grid $alpha		-row 1 -column 1 -sticky w -columnspan 7
	grid $table		-row 3 -column 1 -sticky ewns -columnspan 7
	grid $count		-row 5 -column 1 -sticky ew
	grid $search	-row 5 -column 3 -sticky ew
	grid rowconfigure $top {3} -weight 1
	grid columnconfigure $top {5} -weight 1
	grid columnconfigure $top {0 4} -minsize $::theme::padx
	grid columnconfigure $top {2} -minsize $::theme::padX
	grid rowconfigure $top {0 2 4 6} -minsize $::theme::pady

	::widget::dialogButtons $dlg {close}
	$dlg.close configure -command [list destroy $dlg]
	::widget::dialogButtonAdd $dlg filter ::mc::Filter {}
	$dlg.filter configure -command [namespace code [list SetFilter $table]]
	$dlg.filter configure -image $::icon::16x16::filter(inactive) -compound left

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
	::util::place $dlg -parent [winfo toplevel $parent] -position center
	wm deiconify $dlg

	::scrolledtable::update $table "" "" [::scidb::player::count]
	::scrolledtable::activate $table 0
	::scrolledtable::focus $table
}


proc UpdateDatabaseInfo {table base variant} {
	::scrolledtable::refresh $table
}


proc ColumnsIndex {id} {
	variable Columns

	set i [lsearch -exact -index 0 $Columns $id]
	if {$i >= 2} { incr i -1 }
	return $i
}


proc Destroy {} {
	variable Priv

	set Priv(dialog) ""
	::scidb::player::dict close
	::scidb::db::unsubscribe dbInfo {*}$Priv(subscribe)
}


proc Find {path mode name} {
	if {$mode eq "next"} {
		set lastIndex [::scrolledtable::active $path]
	} else {
		set lastIndex -1
	}
	set i [::scidb::player::search "${name}*" $lastIndex]
	if {$i >= 0} {
		::scrolledtable::see $path $i
		::scrolledtable::activate $path $i
	}
}


proc SortColumn {table id dir} {
	variable Priv
	variable Options

	::widget::busyCursor on
	set see 0
	switch $dir {
		cancel {
			::scidb::player::sort cancel
		}
		reverse {
			::scidb::player::sort reverse
		}
		default {
			if {$id eq "organization"} {
				set id $Options(organization)
			}
			switch $id {
				rating2 - ranking2	{ set rt $Options(rating2:type) }
				default					{ set rt $Options(rating1:type) }
			}
			::scidb::player::sort $dir $id $rt
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
	variable History

	array set Filter_ [array get Filter]

	foreach title $::titlebox::titles(all) { set Title_($title) 0 }
	foreach title $Filter(titles) { set Title_($title) 1 }

	set parent [winfo toplevel $table]
	set dlg [tk::toplevel $parent.filterDialog -class Scidb]
	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
	wm withdraw $dlg
	pack $top -fill both -expand yes
	bind $top <<LanguageChanged>> [namespace code [list LanguageChanged(filter) $top]]
	set bg [::colors::lookup theme,background]
	set bold [list [font configure TkTextFont -family] [font configure TkTextFont -size] bold]

	### name / federation / native top #############################
	set general [tk::frame $top.general -relief groove -borderwidth 2 -background $bg]
	set Filter(name) [string trimright $Filter(name) "*"]
	ttk::label $general.lname -textvar ::playertable::mc::Name -font $bold
	searchentry $general.name \
		-history [namespace current]::History \
		-buttons {erase help} \
		-helpinfo [namespace current]::mc::HelpPatternMatching \
		-textvar [namespace current]::Filter(name) \
		-mode enter \
		;
	bind $general.name <<Help>> [list ::help::open .application Pattern-Matching]
	$general.name selection range 0 end
	ttk::label $general.lfed -textvar ::playertable::mc::T_Federation -font $bold
	ttk::label $general.lnat -textvar ::playertable::mc::T_NativeCountry -font $bold
	set $Filter(country) ""; set $Filter(federation) ""
	countrybox $general.fed -height 20 -excluded {--} -included {Any}
	countrybox $general.nat -height 20 -excluded {--} -included {Any}
	$general.fed set $Filter(federation)
	$general.nat set $Filter(country)

	grid $general.lname	-row 1 -column 1 -sticky w
	grid $general.name	-row 1 -column 3 -sticky ew
	grid $general.lfed	-row 3 -column 1 -sticky w
	grid $general.fed		-row 3 -column 3 -sticky ew
	grid $general.lnat	-row 5 -column 1 -sticky w
	grid $general.nat		-row 5 -column 3 -sticky ew
	grid columnconfigure $general {0 2 4} -minsize $::theme::padx
	grid columnconfigure $general {3} -weight 1
	grid rowconfigure $general {0 2 4 6} -minsize $::theme::pady

	### organization type ########################################
	tk::label $top.lids -textvar [namespace current]::mc::OrganizationID -background $bg -font $bold
	set ids [ttk::labelframe $top.ids -labelwidget $top.lids]
	ttk::radiobutton $ids.ignore \
		-textvar [namespace current]::mc::Ignore \
		-variable [namespace current]::Filter(organization) \
		-value "" \
		;
	foreach fid $::organizationbox::organizations {
		ttk::radiobutton $ids.[string tolower $fid] \
			-text $fid \
			-value $fid \
			-variable [namespace current]::Filter(organization) \
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
		ttk::label $ratings.text$i -text $Options(rating$i:type)
		lassign $DefaultFilter(rating$i:range) from to
		rangebox $ratings.range$i -from $from -to $to -textvar [namespace current]::Filter(rating$i:range)
	}
	grid $ratings.text1	-row 1 -column 1
	grid $ratings.range1	-row 1 -column 3
	grid $ratings.text2	-row 1 -column 5
	grid $ratings.range2	-row 1 -column 7
	grid columnconfigure $ratings {0 2 6 8} -minsize $::theme::padx
	grid columnconfigure $ratings {0 8} -weight 1
	grid columnconfigure $ratings {4} -minsize [expr {4*$::theme::padx}]
	grid rowconfigure $ratings {0 2} -minsize $::theme::pady

	### titles #####################################################
	tk::label $top.ltitles -textvar [namespace current]::mc::Titles -background $bg -font $bold
	set titles [ttk::labelframe $top.titles -labelwidget $top.ltitles]

	set list [ttk::frame $titles.list -borderwidth 0]
	ttk::button $list.fide \
		-text "Fide" \
		-style aligned.TButton \
		-command [namespace code [list ToggleTitles Fide]] \
		;
	grid $list.fide -row 0 -column 0 -sticky w
	set col 2
	foreach title $::titlebox::titles(Fide) {
		set w $list.[string tolower $title]
		ttk::checkbutton $w -text $title -variable [namespace current]::Title_($title)
		::tooltip::tooltip $w ::titlebox::mc::Title($title)
		grid $w -row 0 -column $col -sticky w
		grid columnconfigure $list $col -uniform title
		incr col 2
	}
	ttk::button $list.iccf \
		-text "ICCF" \
		-style aligned.TButton \
		-command [namespace code [list ToggleTitles ICCF]] \
		;
	grid $list.iccf -row 2 -column 0 -sticky w
	set col 2
	foreach title $::titlebox::titles(ICCF) {
		set w $list.[string tolower $title]
		ttk::checkbutton $w -text $title -variable [namespace current]::Title_($title)
		::tooltip::tooltip $w ::titlebox::mc::Title($title)
		grid $w -row 2 -column $col -sticky w
		grid columnconfigure $list $col -uniform title
		incr col 2
	}
	grid columnconfigure $list {1 3 5 7 9 11 13 15 17} -minsize $::theme::padX
	grid columnconfigure $list {1} -uniform btn
	grid rowconfigure $list {1} -minsize $::theme::pady

#	set date [ttk::frame $titles.date -borderwidth 0]
#	ttk::label $date.text -text "$mc::Awarded (Fide)"
#	lassign $DefaultFilter(titles:range) from to
#	rangebox $date.range -from $from -to $to -textvar [namespace current]::Filter(titles:range)
#	grid $date.text  -row 0 -column 0
#	grid $date.range -row 0 -column 2
#	grid columnconfigure $date {1} -minsize $::theme::padx

	grid $list -row 1 -column 1
#	grid $date -row 3 -column 1
	grid columnconfigure $titles {0} -minsize $::theme::padx -weight 1
	grid rowconfigure $titles {0 2} -minsize $::theme::pady

#	### trophys ####################################################
#	tk::label $top.ltrophy -textvar [namespace current]::mc::T_Trophy -background $bg -font $bold
#	set trophy [ttk::labelframe $top.trophy -labelwidget $top.ltrophy]
#
#	set nation [ttk::frame $trophy.nation -borderwidth 0]
#	ttk::label $nation.text -text $::mc::Country
#	countrybox $nation.country -height 20 -excluded {--} -included {Interstate}
#	grid $nation.text		-row 1 -column 1 -sticky w
#	grid $nation.country	-row 1 -column 3 -sticky ew
#	grid columnconfigure $nation {2} -minsize $::theme::padx
#	grid columnconfigure $nation {3} -weight 1
#
#	set range [ttk::frame $trophy.range -borderwidth 0]
#	ttk::label $range.text -text $mc::RangeOfYears
#	lassign $DefaultFilter(trophy:range) from to
#	rangebox $range.box -from $from -to $to -textvar [namespace current]::Filter(trophy:range)
#	grid $range.text -row 0 -column 0
#	grid $range.box  -row 0 -column 2
#	grid columnconfigure $range {1} -minsize $::theme::padx
#
#	grid $nation -row 1 -column 1
#	grid $range  -row 3 -column 1
#	grid columnconfigure $trophy {0 2} -minsize $::theme::padx -weight 1
#	grid rowconfigure $trophy {0 2 4} -minsize $::theme::pady

	### birth/death year ###########################################
	tk::label $top.lyear -background $bg -font $bold
	set year [ttk::labelframe $top.year -labelwidget $top.lyear]
	foreach attr {birth death} {
		ttk::label $year.$attr -textvar ::playertable:::mc::[string toupper $attr 0 0]Year
		lassign $DefaultFilter($attr:range) from to
		rangebox $year.range$attr -from $from -to $to -textvar [namespace current]::Filter($attr:range)
	}
	grid $year.birth -row 1 -column 1
	grid $year.rangebirth -row 1 -column 3
	grid $year.death -row 1 -column 5
	grid $year.rangedeath -row 1 -column 7
	grid columnconfigure $year {0 2 6 8} -minsize $::theme::padx
	grid columnconfigure $year {0 8} -weight 1
	grid columnconfigure $year {4} -minsize [expr {4*$::theme::padx}]
	grid rowconfigure $year {0 2} -minsize $::theme::pady

	### frequency ##################################################
	tk::label $top.lfreq -textvar ::playertable::mc::F_Frequency -background $bg -font $bold
	set freq [ttk::labelframe $top.freq -labelwidget $top.lfreq]
	lassign $DefaultFilter(frequency:range) from to
	rangebox $freq.range -from $from -to $to -textvar [namespace current]::Filter(frequency:range)
	grid $freq.range -row 0 -column 1
	grid columnconfigure $freq {0 2} -minsize $::theme::padx -weight 1
	grid rowconfigure $freq {0 2} -minsize $::theme::pady

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
#	grid $trophy		-row 11 -column 1 -sticky ew
	grid $year			-row 11 -column 1 -sticky ew
	grid $freq			-row 13 -column 1 -sticky ew
	grid $operation	-row 15 -column 1 -sticky ew

	grid columnconfigure $top {0 2} -minsize $::theme::padx
	grid rowconfigure $top {0 2 4 6 8 10 12 14 16} -minsize $::theme::pady

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
	::util::place $dlg -parent $parent -position center
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
	set Filter(federation) [$general.fed value]
	set Filter(country) [$general.nat value]

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

	foreach attr {country federation name organization sex} { ;# trophy
		if {$Filter($attr) ne $DefaultFilter($attr)} {
			lappend filter $attr $Filter($attr)
		}
	}

	if {	$Filter(titles) ne $DefaultFilter(titles)
		|| $Filter(titles:range) ne $DefaultFilter(titles:range)} {
		lassign $Filter(titles:range) from to
		if {$from <= $to} { lappend filter titles [list $Filter(titles) $from $to] }
	}

	foreach attr {rating1 rating2} {
		if {$Filter($attr:range) ne $DefaultFilter($attr:range)} {
			lassign $Filter($attr:range) from to
			if {$from <= $to} { lappend filter $attr [list $Options($attr:type) $from $to] }
		}
	}

	foreach attr {birth death frequency} {
		if {$Filter($attr:range) ne $DefaultFilter($attr:range)} {
			lassign $Filter($attr:range) from to
			if {$to eq "unlimited"} { set to 4294967295 }
			if {$from <= $to} { lappend filter $attr [list $from $to] }
		}
	}

	if {[llength $filter] == 0} {
		set Filter(operation) reset
		set Priv(filter) {}
	} else {
		if {$Filter(operation) eq "reset"} { set Priv(filter) {} }
		lappend Priv(filter) [list $Filter(operation) $filter]
	}

	if {[arrayEqual Filter DefaultFilter]} { set state inactive } else { set state active }
	$parent.filter configure -image $::icon::16x16::filter($state)
	::scidb::player::filter $Filter(operation) $filter
	UpdateFilter $table
	::widget::busyCursor off
}


proc LanguageChanged(filter) {top} {
	$top.lyear configure -text "$::playertable::mc::BirthYear / $::playertable::mc::DeathYear"
	wm title [winfo toplevel $top] $mc::PlayerFilter
}


proc LanguageChanged(dictionary) {dlg} {
	SetDialogHeader $dlg
	UpdateCount
}


proc ToggleTitles {organization} {
	variable Title_

	set state 1
	foreach title $::titlebox::titles($organization) {
		if {$Title_($title)} { set state 0 }
	}
	foreach title $::titlebox::titles($organization) {
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
		set line [scidb::player::info $index \
			-ratings $ratings \
			-organization $Options(organization) \
			;
			#-titleyear $Options(title-year) \
			#-trophyflags $Priv(trophy:flags) \
			#-trophyageset $Priv(trophy:ageset)
		]
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

				ranking1 - ranking2 {
					if {$item == 0} {
						lappend text ""
					} else {
						lappend text $item
					}
				}

				titles {
					lappend text [join $item " "]
				}

				trophy {
					if {[string length $item] == 0} {
						lappend text [list @ {}]
					} else {
						switch [string range $item 0 2] {
							EAR		{ set item [list @ $icon::16x16::gold] }
							EUR		{ set item [list @ $icon::16x16::bronze] }
							default	{ set item [list @ $icon::16x16::silver] }
						}
						lappend text $item
					}
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

				dateOfBirth - dateOfDeath {
					if {[string length $item] == 0} {
						lappend text {}
					} elseif {$Options(date-format) eq "year"} {
						lappend text [string range $item 0 3]
					} else {
						lappend text [::locale::formatNormalDate $item]
					}
				}

				frequency {
					if {$item} {
						lappend text [::locale::formatNumber $item]
					} else {
						lappend text ""
					}
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
	variable Options
	variable Priv

	if {[string length $Priv(receiver)]} {
		set ratings [list $Options(rating1:type) $Options(rating2:type)]
		{*}$Priv(receiver) [scidb::player::info $index -ratings $ratings]
	} else {
		::scrolledtable::select $table none 
	}
}


proc TableVisit {table data} {
	variable Options
	variable Priv

	lassign $data _ _ mode id row

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	set tip ""
	set info [scidb::player::info [::scrolledtable::rowToIndex $table $row]]
		#-titleyear 1 \
		#-trophyflags $Priv(trophy:flags) \
		#-alltrophies 1
	set item [lindex $info [ColumnsIndex $id]]

	switch $id {
		federation {
			if {[string length $item]} { set tip [::country::name $item] }
		}
		country {
			if {[string length $item]} { set tip [::country::name $item] }
		}
		titles {
			foreach title $item {
				if {[string length $tip]} { append tip \n }
				set year ""
				lassign [split $title :] code year
				append tip $::titlebox::mc::Title($code)
				if {[string length $year]} { append tip " \[$year\]" }
			}
		}
		trophy {
			if {[string length $item]} { set tip [MakeChampionInfo $item] }
		}
		dateOfBirth {
			if {[string length $item] > 4} { set tip [::locale::formatDate $item] }
		}
		dateOfDeath {
			if {[string length $item] > 4} { set tip [::locale::formatDate $item] }
		}
	}

	if {[string length $tip]} {
		::tooltip::show $table $tip
	}
}


proc MakeChampionInfo {data} {
	set result ""

	foreach entry $data {
		set info ""
		set organization ""
		set under ""
		set where ""
		set age ""

		lassign $entry country types range _ number
		lassign [split $country -] country organization

		if {[string match *w* $types]} { set sex "f" } else { set sex "m" }
		if {[string match *c* $types]} { set mode "c" } else { set mode "-" }

		if {[string match *j* $types]} {
			set age "j"
		} elseif {[string match *u* $types]} {
			set age "j"
			scan $types "u%u" under
		} elseif {[string match *s* $types]} {
			set age "s"
		} else {
			set age "-"
		}

		switch $country {
			EAR		{ set region w }
			EUR		{ set region e }
			default	{ set region - }
		}

		if {$sex eq "f"} { set part 1 } else { set part 0 }

		if {$region eq "-"} {
			set where [string map [list %country% [::country::name $country]] $mc::Where]
		}

		if {[string length $under]} {
			set under "U$under"
			set i [string first "%under%" $mc::ChessChampion]
			if {[string is alpha [string index $mc::ChessChampion [expr {$i + 8}]]]} { append under "-" }
			if {[string is alpha [string index $mc::ChessChampion [expr {$i - 1}]]]} { set under "-$under" }
		}

		set mapping [list \
			%champion%	[ModifyStr $part $mc::Champion($region)] \
			%sex%			[ModifyStr $part $mc::Sex($sex)] \
			%age%			[ModifyStr $part $mc::Age($age)] \
			%region%		[ModifyStr $part $mc::Region($region)] \
			%mode%		[ModifyStr $part $mc::Mode($mode)] \
			%under%		$under \
			%where%		$where \
		]

		if {$mode eq "c" && [string length $number]} { append info $number ". " }
		append info [string map $mapping $mc::ChessChampion]
		if {[string length $range]} { append info " $range" }
		if {[string length $organization]} { append info " (" $organization ")" }

		append result [string trim $info] "\n"
	}

	while {[string first "  " $result] >= 0} {
		set result [string map {"  " " "} $result]
	}

	return [string trim $result]
}


proc ModifyStr {part str} {
	set parenthesized 0
	set result ""

	foreach sub [split $str "()"] {
		if {[string length $sub]} {
			if {$parenthesized} {
				append result [lindex [split $sub ,] $part]
			} else {
				append result $sub
			}
		}
		set parenthesized [expr {!$parenthesized}]
	}

	return $result
}


proc RefreshRatings {table number} {
	RefreshHeader $number
	::scrolledtable::refresh $table
}


proc RefreshOrganization {table} {
	variable Options

	set mc::F_Organization "$Options(organization) ID"
	::scrolledtable::refresh $table
}


proc RefreshHeader {number} {
	variable Options

	set tip $::playertable::mc::TooltipRating
	set mc::F_Rating$number $Options(rating$number:type)
	set mc::T_Rating$number [format $tip $Options(rating$number:type)]
}


proc SetDialogHeader {dlg} {
	wm title $dlg $mc::PlayerDictionary
}


proc EvalTrophyFlags {} {
	variable Options
	variable Priv

return ;# XXX not yet available
	set Priv(trophy:flags) ""
	set Priv(trophy:ageset) {}

	if {$Options(trophy:mode:otb)}			{ append Priv(trophy:flags) o }
	if {$Options(trophy:mode:pm)}				{ append Priv(trophy:flags) c }
	if {$Options(trophy:age:unrestricted)}	{ append Priv(trophy:flags) u }
	if {$Options(trophy:age:junior)}			{ append Priv(trophy:flags) j }
	if {$Options(trophy:age:senior)}			{ append Priv(trophy:flags) s }
	if {$Options(trophy:region:world)}		{ append Priv(trophy:flags) w }
	if {$Options(trophy:region:eu)}			{ append Priv(trophy:flags) e }
	if {$Options(trophy:region:nat)}			{ append Priv(trophy:flags) n }

	foreach age {8 10 12 14 16 18 20} {
		if {$Options(trophy:under:$age)} { lappend Priv(trophy:ageset) $age }
	}
}


proc Refresh {table} {
	EvalTrophyFlags
	::scrolledtable::clear $table
	::scrolledtable::refresh $table
}


proc PopupMenu {table menu _ _ index} {
	if {![string is digit -strict $index]} { return }
	set info [scidb::player::info $index -web 1]
	::playercard::buildWebMenu $table $menu $info
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::History
}
::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 16x16 {

set gold [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA/1BMVEUmFQUqFwUsGQUwGwZr
	PA5lMA9mMg9gJxFrPA5zQQ9rPA5zQQ97RRDaVSjaVinaViraVyraWCzbVyfbXTLcXjPcXzPd
	ZTzea0PhYyXhZCXhZiviajHkhWXkh2flaiTliGnmglPnbiTnkHPnknXnk3bocCPpcyPpdy/q
	dCPro4vteyLur5nvfSHvhC3vuabvuafwgCHwvKrxwKzyx7jzyLrzzL70zsH0z8L1iSD1iiD1
	jCb1jSj1jir2iyD2iyH2jCH2jCP2kzD21sv3lzn32tD4pVP4q174xp/44Nf55d770KX82bb8
	3Lv838H87uf88u/97t7+/Pn+/fz+/f3///9m1RogAAAADXRSTlMDAwQEMzQ0NTY2Nzc5lYmS
	MwAAAJRJREFUGNNjYOTkRgbMDCy2KIAHp4CDHZKAjZailJ+Pra21K0iATU4hSJlXwMldQ0I7
	xA0owM4rZizLy6siz8sr4+0IFuDlcxHm1Tfj5TVxtoUI8Hqa8nsEiysF2sMEzEMMg0KM/ANs
	YQJ6IWDgCxfQhAh4wQUERUREpdV1rWACQpKqOhZwp7OqGVii+IWBgwsZMAEAdSwpcmvE/TwA
	AAAASUVORK5CYII=
}]

set silver [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA0lBMVEUeISAfIiEhJCMjKCZE
	TUk8Q0A9REE0OzhETUlJUk5ETUlJUk5OV1NreHNseXRtenVue3Zxfnlyf3p1gn11hH53hoB6
	iYN8iYR9ioV/jIeBjomDkIuGk46IlZCKl5KNmpWPmpaRnJiUn5uVoJyWoZ2Xop6Yo5+ZpKCc
	p6OdqKOeqaSfqqWgq6attrKxura4v7y/xsPAx8TDysfHzMrKz83M0c/N0tDP1NLR1tTS19XT
	2Nba3dzc397d4N/f4uHh5OPl6Ofu7+/y8/P5+vr6+/v8/f1HnS8bAAAADXRSTlMDAwQEMzQ0
	NTY2Nzc5lYmSMwAAAJFJREFUGNNjYOTkRgbMDCyqKIAHp4AasoC6rKSooy1QUBckwCam4KLF
	K2BtIi2s76oHFGDnFTVV5uXVVuHlVbLRBAvw8tkK8hpa8PKa6ahCBHgdzPntXSQ0nNVgAlau
	Ri6uxk6OqjABA1cwsIML6EIELOECAkJCQuIyimowAX4RKTlluEtZpeVVUPzCwMGFDJgAU8ge
	o7eW8OkAAAAASUVORK5CYII=
}]

set bronze [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAz1BMVEUCAAAEAgAHBgANCwBJ
	RAA6NgA8NwAsKQBJRABTTgBJRABTTgBbVQCRigeTiweUjQmXjgmdlAqelQujmQukmwynnw2t
	pQ+wpg+zqhC3rRG8shHAtxPFuhPGvRXMwxbPxBbSyBfUyhvVyhzVyx7Wyx/WyyLWzCTXzirY
	zyvYzy7a0C/a0DHe1kTf103i21bl3WLl3mPn32no4W/p43Xq5Hnq5Hvr5Xzt54Dt54Lt54Xv
	6o7w65Lw65Tx7Zjz7pv076H386/59bf8+cT8+sb9+sjTT0/YAAAADXRSTlMDAwQEMzQ0NTY2
	Nzc5lYmSMwAAAJFJREFUGNNjYOTkRgbMDCwqKIAHp4AqsoCajISogw1QUAckwCYm76zJK2Bl
	LCWs56ILFGDnFTVR4uXVUublVbTWAAvw8tkI8hqY8/KaaqtABHjtzfjtnMXVnVRhApYuhs4u
	Ro4OKjABfRcwsIUL6EAELOACAkJCQuLSCqowAX4RSVkluEtZpeSUUfzCwMGFDJgA/0YeCuS9
	ENMAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace playerdict

# vi:set ts=3 sw=3:
