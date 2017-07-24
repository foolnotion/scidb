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
# Copyright: (C) 2010-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source tree-pane

namespace eval application {
namespace eval tree {
namespace eval mc {

set Total								"Total"
set Control								"Control"
set ChooseReferenceBase				"Choose reference database"
set ReferenceBaseSwitcher			"Reference database switcher"
set Numeric								"Numeric"
set Bar									"Bar"
set StartSearch						"Start search"
set StopSearch							"Stop search"
set UseExactMode						"Use position search mode"
set UseFastMode						"Use accelerated mode"
set UseQuickMode						"Use quick mode"
set AutomaticSearch					"Automatic search"
set LockReferenceBase				"Lock reference database"
set SwitchReferenceBase				"Switch reference database"
set TransparentBar					"Transparent bar"
set NoGamesFound						"No games found"
set NoGamesAvailable					"No games available"
set Searching							"Searching"
set VariantsNotYetSupported		"Chess variants not yet supported."
set End									"end"
set ShowMoveOrders					"Show move orders"
set ShowMoveTree						"Show move tree"

set FromWhitesPerspective			"From whites perspective"
set FromBlacksPerspective			"From blacks perspective"
set FromSideToMovePerspective		"From side to move perspective"
set FromWhitesPerspectiveTip		"Score from whites perspective"
set FromBlacksPerspectiveTip		"Score from blacks perspective"
set EmphasizeMoveOfGame				"Emphasize move of game"

set TooltipAverageRating			"Average Rating (%s)"
set TooltipBestRating				"Best Rating (%s)"

set F_Number							"#"
set F_Move								"Move"
set F_Eco								"ECO"
set F_Frequency						"Frequency"
set F_Ratio								"Ratio"
set F_Score								"Score"
set F_Draws								"Draws"
set F_Performance						"Performance"
set F_AverageYear						"\u00f8 Year"
set F_LastYear							"Last Played"
set F_BestPlayer						"Best Player"
set F_FrequentPlayer					"Frequent Player"

set T_Number							"Numeration"
set T_AverageYear						"Average Year"
set T_FrequentPlayer					"Most Frequent Player"

} ;# namespace mc

#		ID   			Adjustment	Min	Max	Width	Stretch	Removable	Ellipsis	Color
#	----------------------------------------------------------------------------------------
set Columns {
	{ number				right		3		 3		 3			0			1			0			{}				}
	{ move				left		7		 8		 7			0			0			0			{}				}
	{ eco					left		4		 4		 4			0			1			0			darkgreen	}
	{ frequency			right		5		10		 9			0			1			0			{}				}
	{ ratio				right		55px	 6		 6			0			1			0			{}				}
	{ score				right		55px	 6		 6			0			1			0			darkred		}
	{ draws				right		55px	 6		 6			0			1			0			{}				}
	{ averageRating	right		5		 5		 5			0			1			0			darkblue		}
	{ performance		right		5		 5		 5			0			1			0			{}				}
	{ bestRating		right		5		 5		 5			0			1			0			{}				}
	{ averageYear		right		5		 5		 5			0			1			0			{}				}
	{ lastYear			right		5		 5		 5			0			1			0			{}				}
	{ bestPlayer		left		6		 0		12			0			1			1			{}				}
	{ frequentPlayer	left		6		 0		12			0			1			1			{}				}
}

array set Options {
	ratio:bar			1
	score:bar			1
	draws:bar			1
	bar:transparent	1
	search:automatic	1
	search:mode			exact
	base:lock			0
	sort:column			frequency
	rating:type			Elo
	score:side			white
	hilite:nextmove	0
	show:tree			1

	-background			tree,background
	-emphasize			tree,emphasize
	-stripes				tree,stripes
}

array set Priv {
	ratio:color			tree,ratio:color
	score:color			tree,score:color
	draws:color			tree,draws:color
	progress:color		tree,progress:color
	progress:finished	tree,progress:finished
}

array set Vars {
	current	{}
	progress	{}
	table		{}
	after		{}
	nextmove	-1
}

array set Bars {}


proc build {parent width height gameTable} {
	variable ::ratingbox::ratings
	variable Columns
	variable Options
	variable Priv
	variable Vars

	set bg [::colors::lookup $Options(-background)]
	set mw [tk::multiwindow $parent.mw -borderwidth 0 -background $bg]
	set info [tk::frame $mw.info -background $bg -borderwidth 0 -takefocus 0]
	set mesg [tk::label $mw.mesg -borderwidth 0 -background $bg]
	pack $mw -fill both -expand yes

	bind $mesg <<LanguageChanged>> [namespace code SetMessage]

	$mw add $info
	$mw add $mesg

	set Vars(mw) $mw
	set Vars(info) $info
	set Vars(mesg) $mesg

	set tb $info.table
	set sb $info.scrollbar
	set sq $info.square

	set Vars(whiteKnob) \
		[list $::icon::22x22::whiteKnob $::icon::16x16::whiteKnob $::icon::32x32::whiteKnob]
	set Vars(blackKnob) \
		[list $::icon::22x22::blackKnob $::icon::16x16::blackKnob $::icon::32x32::blackKnob]

	::table::table $tb \
		-listmode 1 \
		-fixedrows 1 \
		-moveable 1 \
		-takefocus 0 \
		-fillcolumn end \
		-stripes {} \
		-fullstripes 0 \
		-background $bg \
		-pady {1 0} \
		-highlightcolor $Options(-emphasize) \
		;
	::table::setColumnBackground $tb tail [::colors::lookup $Options(-stripes)] $bg
	::table::setScrollCommand $tb [list $sb set]
	::ttk::scrollbar $sb  \
		-orient vertical \
		-takefocus 0     \
		-command [namespace code [list $tb.t yview]] \
		;
	bind $sb <Any-Button> [list ::tooltip::hide]
	::ttk::frame $sq -borderwidth 1 -relief sunken

	$tb.t state define next
	set font(normal) [::table::getFont $tb]
	set font(bold) [::font::makeBoldFont $font(normal)]
	set specialfont(normal) [list $::font::figurine(text:normal) 9812 9823]
	set specialfont(bold) [list $::font::figurine(text:bold) 9812 9823]
	set Vars(style) [list \
		-font [list $font(bold) next $font(normal) !next] \
		-specialfont [list $specialfont(bold) next $specialfont(normal) !next] \
	]

	grid $tb -row 0 -column 0 -rowspan 2 -sticky nsew
	grid $sb -row 0 -column 1 -rowspan 2 -sticky ns
	grid rowconfigure $info 0 -weight 1
	grid columnconfigure $info 0 -weight 1

	set Vars(styles) {}
	$tb.t element create elemTotal rect -fill [::colors::lookup $Options(-emphasize)]
	set padx $::table::options(element:padding)

	RefreshHeader $tb

	foreach col $Columns {
		lassign $col id adjustment minwidth maxwidth width stretch removable ellipsis color

		set ivar [namespace current]::I_[string toupper $id 0 0]
		set fvar [namespace current]::mc::F_[string toupper $id 0 0]
		set tvar [namespace current]::mc::T_[string toupper $id 0 0]
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

		set menu {}
		set lock none
		set stripes $Options(-stripes)
		set visible 1

		switch $id {
			number - move {
				lappend menu [list checkbutton \
					-command [namespace code [list RefreshCurrentItem $tb]] \
					-labelvar [namespace current]::mc::EmphasizeMoveOfGame \
					-variable [namespace current]::Options(hilite:nextmove) \
				]
				lappend menu { separator }
				if {$id eq "number"} {
					set var {}
					set stripes $Options(-emphasize)
					set lock left
				} else {
					set var ::gametable::mc::SortAscending
					set stripes $Options(-emphasize)
					set lock left
				}
				if {$id eq "number"} { set visible 0 }
			}

			eco {
				set visible $Options(show:tree)
				set Vars(eco:visible) $visible
				set var ::gametable::mc::SortAscending
			}

			ratio - score - draws {
				if {$id eq "score"} {
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $tb]] \
						-labelvar [namespace current]::mc::FromWhitesPerspective \
						-variable [namespace current]::Options(score:side) \
						-value white \
					]
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $tb]] \
						-labelvar [namespace current]::mc::FromBlacksPerspective \
						-variable [namespace current]::Options(score:side) \
						-value black \
					]
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $tb]] \
						-labelvar [namespace current]::mc::FromSideToMovePerspective \
						-variable [namespace current]::Options(score:side) \
						-value sideToMove \
					]
					lappend menu { separator }
				}
				lappend menu [list radiobutton \
					-command [namespace code [list FetchResult $tb true]] \
					-labelvar [namespace current]::mc::Numeric \
					-variable [namespace current]::Options($id:bar) \
					-value 0 \
				]
				lappend menu [list radiobutton \
					-command [namespace code [list FetchResult $tb true]] \
					-labelvar [namespace current]::mc::Bar \
					-variable [namespace current]::Options($id:bar) \
					-value 1 \
				]
				lappend menu { separator }
				lappend menu [list checkbutton \
					-command [namespace code [list ToggleTransparentBar $tb]] \
					-labelvar [namespace current]::mc::TransparentBar \
					-variable [namespace current]::Options(bar:transparent) \
				]
				lappend menu { separator }
				set var ::gametable::mc::SortDescending
			}

			averageRating {
				# TODO: si3/4 does not have rating type IPS
				foreach ratType $ratings(all) {
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $tb]] \
						-label $ratType \
						-variable [namespace current]::Options(rating:type) \
						-value $ratType \
					]
				}
				lappend menu { separator }
				set var ::gametable::mc::SortDescending
			}

			default {
				set var ::gametable::mc::SortDescending
			}
		}

		if {[llength $var]} {
			if {$id eq "ratio"} { set value "frequency" } else { set value $id }
			lappend menu [list checkbutton \
				-command [namespace code [list SortColumn $tb]] \
				-labelvar $var \
				-variable [namespace current]::Options(sort:column) \
				-onvalue $value \
				]
			lappend menu { separator }
		}

		::table::addcol $tb $id \
			-justify $adjustment \
			-minwidth $minwidth \
			-maxwidth $maxwidth \
			-width $width \
			-stretch $stretch \
			-removable $removable \
			-ellipsis $ellipsis \
			-visible $visible \
			-foreground $color \
			-menu $menu \
			-image $ivar \
			-textvar $fvar \
			-tooltipvar $tvar \
			-lock $lock \
			-stripes $stripes \
			;

		if {$ellipsis} { set squeeze "x" } else { set squeeze "" }

		$tb.t style create styTotal$id
		$tb.t style elements styTotal$id [list elemTotal elemImg elemIco elemTxt$id]
		::table::setDefaultLayout $tb $id styTotal$id
		$tb.t style layout styTotal$id elemTotal -union elemTxt$id -iexpand nswe
		lappend Vars(styles) $id styTotal$id
	}

	::table::configure $tb move -specialfont [list [list $::font::figurine(text:normal) 9812 9823]]

	::table::bind $tb <ButtonPress-2>	[namespace code [list ShowPlayerInfo $tb %x %y]]
	::table::bind $tb <ButtonRelease-2>	[namespace code [list HideInfo $tb]]
	::table::bind $tb <ButtonPress-1>	[namespace code [list Select $tb %x %y]]
	::table::bind $tb <Button1-Motion>	[namespace code [list Motion1 $tb %x %y]]
	::table::bind $tb <ButtonRelease-1>	+[namespace code [list Activate $tb]]
	::table::bind $tb <ButtonRelease-3>	+[list set [namespace current]::Vars(button) 0]
	::table::bind $tb <Leave>				[namespace code [list Leave %W]]
	::table::bind $tb <Motion>				[namespace code [list Motion %W %x %y]]

	foreach seq {	Shift-Up Shift-Down ButtonPress-1 ButtonPress-3
						ButtonRelease-3 Double-Button-1 Leave Motion} {
		::table::bind $tb <$seq> {+ break }
	}

	bind $tb <<TableScrollbar>>	 [namespace code [list Scrollbar $tb %d]]
	bind $tb <<TableVisit>>			 [namespace code [list VisitItem $tb %d]]
	bind $tb <<TableFill>>			 [namespace code [list FillTable $tb]]
	bind $tb <<TableMenu>>			 [namespace code [list PopupMenu $tb %X %Y]]
	bind $tb <<LanguageChanged>>	 [namespace code [list FillTable $tb]]
	bind $tb <<LanguageChanged>>	+[namespace code [list RefreshHeader $tb]]

	TreeCtrl::finishBindings $tb

	$tb.t element create rectDivider rect -fill blue -height 1
	$tb.t style create styLine
	$tb.t style elements styLine {rectDivider}
	$tb.t style layout styLine rectDivider -pady {3 2} -iexpand x

	set tbSwitcher [::toolbar::toolbar $parent \
		-id tree-switcher \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::ReferenceBaseSwitcher \
	]
	set tbControl [::toolbar::toolbar $parent \
		-id tree-control \
		-hide 0 \
		-side top \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control \
	]
	::toolbar::add $tbControl checkbutton \
		-image $::icon::toolbarSearch \
		-variable [namespace current]::Options(search:automatic) \
		-tooltipvar [namespace current]::mc::AutomaticSearch \
		-command [namespace code [list AutomaticSearch $tb]] \
		;
	set search [::toolbar::add $tbControl button \
		-image $::icon::toolbarStart \
		-tooltipvar [namespace current]::mc::StartSearch \
		-command [namespace code startSearch] \
	]
	::toolbar::addSeparator $tbControl
	::toolbar::add $tbSwitcher checkbutton \
		-image $::icon::toolbarLock \
		-variable [namespace current]::Options(base:lock) \
		-tooltipvar [namespace current]::mc::LockReferenceBase \
		-command [namespace code LockBase] \
		;
	set switcher [::toolbar::add $tbSwitcher ::ttk::tcombobox \
		-exportselection no \
		-state readonly \
		-textvariable [namespace current]::Vars(name) \
		-tooltipvar [namespace current]::mc::SwitchReferenceBase \
		-showcolumns {name} \
	]
	$switcher configure -postcommand [namespace code [list FillSwitcher $switcher]]
	::toolbar::add $tbSwitcher frame -width 4
	set stm [::toolbar::add $tbSwitcher label -image $Vars(whiteKnob)]
	::toolbar::add $tbSwitcher frame -width 2
	foreach mode {exact fast} {
		set Vars(widget:$mode) [::toolbar::add $tbControl button \
			-image [set ::icon::toolbar[string toupper $mode 0 0]] \
			-variable [namespace current]::Options(search:mode) \
			-tooltipvar [namespace current]::mc::Use[string toupper $mode 0 0]Mode \
			-value $mode \
			-command [list set [namespace current]::Options(search:mode) $mode] \
		]
	}
	set tbProgress [::toolbar::toolbar $parent \
		-id tree-progress \
		-hide 0 \
		-side bottom \
		-alignment left \
		-justify right \
		-allow {top bottom} \
	]
	set progress [::toolbar::add $tbProgress frame -width 130 -height 7 -borderwidth 1 -relief sunken]
	tk::frame $progress.bar -background [::colors::lookup $Priv(progress:color)] -height 5
	$switcher addcol text -id name
	bind $switcher <<LanguageChanged>> [namespace code LanguageChanged]
	bind $switcher <<ComboboxCurrent>> [namespace code [list SetReferenceBase $switcher]]

	set Vars(progress) $progress.bar
	set Vars(gameTable) $gameTable
	set Vars(search) $search
	set Vars(searching) 0
	set Vars(data) {}
	set Vars(table) $tb
	set Vars(activated) 0
	set Vars(selected) -1
	set Vars(enabled) 1
	set Vars(active) -1
	set Vars(hidden) 1
	set Vars(button) 0
	set Vars(name) {}
	set Vars(current:base) ""
	set Vars(current:variant) ""
	set Vars(list) {}
	set Vars(stm) $stm
	set Vars(side) {}
	set Vars(show:tree) $Options(show:tree)
### VARIANTS ####################################
set Vars(force) 0
set Vars(switcher) $switcher
#################################################

	set Vars(subscribe) [list tree [namespace current]::Update [namespace current]::Close $tb]
	after idle [list ::scidb::db::subscribe {*}$Vars(subscribe)]
	::scidb::tree::init [namespace current]::Tick $tb
	::scidb::tree::switch [expr {!$Options(base:lock)}]

	bind $mw <Configure> [namespace code PlaceMessage]
	after idle [namespace code startSearch]
	SetSwitcher [::scidb::tree::get] [::scidb::app::variant]
}


proc activate {w flag} {
	variable Vars

	::toolbar::activate $w $flag
	set Vars(hidden) [expr {!$flag}]
}


proc closed {w} {
	variable Vars

	catch { after cancel $Vars(after) }
	::scidb::db::unsubscribe {*}$Vars(subscribe)
}


proc columnIndex {name} {
	variable Columns

	set n [lsearch -exact -index 0 $Columns $name]

	if {$n <= 1} { return 0 }
	if {$n == 2} { return 1 }
	if {$n <= 4} { return 2 }

	return [incr n -2]
}


proc startSearch {} {
	variable Vars

	if {![winfo exists $Vars(table)]} { return }

### VARIANTS ####################################
if {[::scidb::game::query mainvariant?] ne "Normal"} { return }
#################################################

	if {[llength [::scidb::tree::get]] == 0} {
		return [ShowMessage NoGamesAvailable]
	}

	if {$Vars(searching)} {
		set Vars(searching) 0
		::scidb::tree::stop
		place forget $Vars(progress)
		ConfigSearchButton $Vars(table) Start
		# show "interrupted by user"
	} else {
		set variant [::scidb::game::query mainvariant?]
		set n [::scidb::db::count games [::scidb::tree::get] $variant]
		if {$n == 0} {
			ShowMessage NoGamesAvailable
		} else {
			DoSearch $Vars(table)
		}
	}
}


proc update {position} {
	variable Vars
	variable Options

	if {![[namespace parent]::exists? tree]} { return }

	if {[::scidb::tree::isUpToDate?]} {
		Enabled true
		return
	}

	if {$Options(search:automatic) && [llength [::scidb::tree::get]]} {
		set variant [::scidb::game::query $position mainvariant?]
### VARIANTS ####################################
if {$variant eq "Normal"} {
::toolbar::childconfigure $Vars(switcher) -state readonly
#################################################
		set n [::scidb::db::count games [::scidb::tree::get] $variant]
		if {$n == 0} {
			ShowMessage NoGamesAvailable
		} else {
			after cancel $Vars(after)
			set Vars(after) [after 250 [namespace code [list DoSearch $Vars(table)]]]
		}
### VARIANTS ####################################
} else {
	ShowMessage VariantsNotYetSupported
	games::clear
	set Vars(force) 1
	::toolbar::childconfigure $Vars(switcher) -state disabled
}
#################################################
	}

	Enabled false
}


proc Enabled {flag} {
	variable Vars

	if {$Vars(enabled) == $flag} { return }

	set table $Vars(table)
	set nrows [llength $Vars(data)]
	if {$nrows > 2} { incr nrows } else { incr nrows -1 }
	if {$flag} { set deleted !deleted } else { set deleted deleted }
	set Vars(enabled) $flag

	for {set r 0} {$r < $nrows} {incr r} {
		catch {
			::table::setState $table $r $deleted
			::table::setEnabled $table $r $flag
		}
	}

	if {$flag} {
		if {$Vars(active) != -1} {
			::table::activate $table $Vars(active) true
		} else {
			# TODO
			# check if pointer hovers a tree row
			# ::table::activate $table $row true
		}
	} else {
		::table::activate $table none true
		::table::select $table none
		set Vars(selected) -1
		set Vars(active) -1
	}
}


proc View {pane base variant} {
	set view [::scidb::tree::view]
	if {$view == -1} { return 0 }
	return $view
}


proc ConfigSearchButton {table mode} {
	variable Vars

	::toolbar::childconfigure $Vars(search) \
		-image [set ::icon::toolbar$mode] \
		-tooltipvar [namespace current]::mc::${mode}Search \
		;
}


proc Update {table base variant} {
	variable Vars
	variable Options

### VARIANTS ####################################
if {[::scidb::game::query mainvariant?] eq "Normal"} {
::toolbar::childconfigure $Vars(switcher) -state readonly
#################################################
	if {[::scidb::tree::isUpToDate?]} { return }

	if {[string length $base]} {
		if {$base ne $Vars(current:base) || $variant ne $Vars(current:variant)} {
			SetSwitcher $base $variant
		}

		if {$Options(search:automatic)} {
			after cancel $Vars(after)
			set Vars(after) [after 250 [namespace code [list DoSearch $table]]]
		}
	} else {
		ShowMessage NoGamesAvailable
	}

	Enabled false
### VARIANTS ####################################
} else {
ShowMessage VariantsNotYetSupported
games::clear
set Vars(force) 1
::toolbar::childconfigure $Vars(switcher) -state disabled
}
#################################################
}


proc DoSearch {table} {
	variable Vars
	variable Options
	variable Priv

### VARIANTS ####################################
if {[::scidb::game::query mainvariant?] ne "Normal"} { return }
#################################################

	if {[::scidb::tree::update $Options(rating:type) $Options(search:mode)]} {
		if {$Vars(searching)} {
			$Vars(progress) configure -background [::colors::lookup $Priv(progress:finished)]
			place $Vars(progress) -x 1 -y 1 -width 127
			set Vars(searching) 0
		}
		SearchResultAvailable $table
	} else {
		if {[llength $Vars(data)] == 0} { ShowMessage Searching }
		set Vars(searching) 1
		ConfigSearchButton $table Stop
		$Vars(progress) configure -background [::colors::lookup $Priv(progress:color)]
		place forget $Vars(progress)
	}
}


proc Close {table base variant} {
	variable Vars

	if {$base eq [::scidb::tree::get] && $variant eq [::scidb::app::variant]} {
		return [ShowMessage NoGamesAvailable]	}
}


proc Tick {table n} {
	variable Vars
	variable Options
	variable Priv

	if {[llength [::scidb::tree::get]] == 0} { return }

	if {$n == 0} {
		if {$Vars(searching)} {
			place forget $Vars(progress)
			$Vars(progress) configure -background [::colors::lookup $Priv(progress:color)]
			set Vars(searching) 0
			ConfigSearchButton $table Start
			# show "interrupted due to a database modification"
		}
	} else {
		if {!$Vars(searching)} {
			ConfigSearchButton $table Stop
			$Vars(progress) configure -background [::colors::lookup $Priv(progress:color)]
			set Vars(searching) 1
		}

		place $Vars(progress) -x 1 -y 1 -width [expr {($n - 1)/2}]

		if {$n == 255} {
			set Vars(searching) 0
			ConfigSearchButton $table Start
			$Vars(progress) configure -background [::colors::lookup $Priv(progress:finished)]
			after idle [namespace code [list SearchResultAvailable $table]]
		}
	}
}


proc AutomaticSearch {table} {
	variable Options
	variable Vars

	if {$Options(search:automatic)} {
		Update $table [::scidb::tree::get] [::scidb::app::variant]
	}
}


proc SortColumn {table} {
	FetchResult $table true
}


proc DoSelection {table} {
	variable Vars

	if {![winfo exists $table]} { return }
	if {$Vars(hidden)} { return }

	lassign [winfo pointerxy $table] x y
	set x [expr {$x - [winfo rootx $table]}]
	set y [expr {$y - [winfo rooty $table]}]
	lassign [::table::identify $table $x $y] row
	set nrows [llength $Vars(data)]

	if {$row + 1 < $nrows} {
		::table::activate $table $row true
		set Vars(active) $row
	}
}


proc VisitItem {table data} {
	variable Options
	variable Vars

	lassign $data mode id row
	set nrows [llength $Vars(data)]
	set Vars(active) -1

	if {$row + 1 < $nrows} {
		if {$mode eq "enter"} {
			if {$Vars(enabled)} {
				::table::activate $table $row true
			}
			set Vars(active) $row
		} else {
			::table::activate $table none true
		}
	}

	if {$nrows <= 1 || $row + 1 == $nrows} { return }

	if {$mode eq "leave"} {
		::tooltip::hide
	} else {
		if {$row == $nrows} { incr row -1 }
		set value [lindex $Vars(data) $row [columnIndex $id]]
		set item {}

		switch $id {
			ratio - score - draws {
				if {$Options($id:bar)} {
					set total [lindex $Vars(data) end [columnIndex frequency]]
					set value [ComputeValue $id $value $total]
					set item [Format $value]
					append item "%"
				}
			}

			eco {
				set opening [::scidb::app::lookup ecoCode $value]
				lassign $opening long short
				set vars [lrange $opening 2 end]
				if {[llength $vars]} {
					set item [::mc::translateEco $short]
					foreach var $vars { append item ", " [::mc::translateEco $var] }
				} else {
					set item [::mc::translateEco $long]
				}
			}

			bestPlayer {
				if {"bestRating" ni [::table::visibleColumns $table]} {
					set value [lindex $value 1]
					if {$value > 0} {
						set item "$Options(rating:type): $value"
					}
				}
			}

			frequentPlayer {
				set value [lindex $value 1]
				if {$value > 0} {
					set item "$mc::F_Frequency: $value"
				}
			}
		}

		if {[string length $item]} {
			::tooltip::show $table $item
		}
	}
}


proc ShowPlayerInfo {table x y} {
	variable Columns
	variable Options
	variable Vars

	::tooltip::disable
	set Vars(button) 2
	set nrows [llength $Vars(data)]
	if {$nrows == 0} { return }
	lassign [::table::identify $table $x $y] row column
	if {$row == -1} { return }
	if {$row + 1 == $nrows} { return }
	set id [lindex $Columns $column 0]
	if {$id ne "bestPlayer" && $id ne "frequentPlayer"} { return }
	::table::activate $table $row 1
	if {$row == $nrows} { incr row -1 }
	set info [::scidb::tree::player $row $id $Options(rating:type)]
	::playercard::popupInfo $table $info
}


proc HideInfo {table} {
	variable Vars

	::tooltip::enable
	set Vars(button) 0
	::playercard::popdownInfo $table
	after idle [namespace code [list DoSelection $table]]
}


proc ToggleTransparentBar {table} {
	variable Bars

	foreach key [array names Bars] {
		image delete $Bars($key)
	}
	array unset Bars
	FetchResult $table true
}


proc RefreshCurrentItem {table} {
	variable Vars

	if {$Vars(nextmove) >= 0} {
		SetItemState $table $Vars(nextmove)
	}
}


proc RefreshHeader {table} {
	variable Options

	set mc::F_AverageRating "\u00f8 $Options(rating:type)"
	set mc::T_AverageRating [format $mc::TooltipAverageRating $Options(rating:type)]
	set mc::F_BestRating [format $mc::TooltipBestRating $Options(rating:type)]
}


proc RefreshRatings {table} {
	RefreshHeader table
	FetchResult $table true
	RefreshRatingLabel
}


proc RefreshRatingLabel {} {
	variable Vars
	variable Options

	set side white
	switch $Options(score:side) {
		black			{ set side black }
		sideToMove	{ if {[::scidb::pos::stm] eq "b"} { set side black } }
	}

	if {$Vars(side) != $side} {
		set Vars(side) $side
		::toolbar::childconfigure $Vars(stm) -image $Vars(${side}Knob)
		switch $side {
			white { set var FromWhitesPerspectiveTip }
			black { set var FromBlacksPerspectiveTip }
		}
		::toolbar::childconfigure $Vars(stm) -tooltipvar [namespace current]::mc::$var
	}
}


proc SearchResultAvailable {table} {
	FetchResult $table
#	[namespace parent]::vars::update
}


proc FetchResult {table {force false}} {
	variable Options
	variable Vars
	variable Priv

### VARIANTS ####################################
if {[::scidb::game::query mainvariant?] ne "Normal"} { return }
if {$Vars(force)} { set force true }
#################################################

	$Vars(progress) configure -background [::colors::lookup $Priv(progress:finished)]

	set options {}
	if {[llength $Options(sort:column)]} {
		lappend options -sort [columnIndex $Options(sort:column)]
	}
	set state [::scidb::tree::finish $Options(rating:type) $Options(search:mode) {*}$options]

	if {$force || $state ne "unchanged"} {
		set Vars(data) [::scidb::tree::fetch]
		set nrows [llength $Vars(data)]

		if {$nrows == 0} {
			set variant [::scidb::game::query mainvariant?]
			set n [::scidb::db::count games [::scidb::tree::get] $variant]
			if {$n == 0} { set msg NoGamesAvailable } else { set msg NoGamesFound }
			ShowMessage $msg
		} else {
			if {$nrows == 2} { set nrows 1 } elseif {$nrows} { incr nrows }
			set active [::table::active $table]

			::table::clear $table
			::table::setHeight $table 0
			::table::setHeight $table $nrows [namespace current]::SetItemStyle
			FillTable $table
			$Vars(mw) raise $Vars(info)

			if {0 <= $active && $active < max(1, $nrows - 1)} {
				::table::activate $table $active true
			}
		}
	}

### VARIANTS ####################################
if {$Vars(force)} {
	games::UpdateTable [games::table] $Vars(current:base) Normal
	set Vars(force) 0
}
#################################################

	set Vars(activated) 0
	if {[llength $Vars(data)]} { Enabled true }
}


proc SetItemStyle {table item row} {
	variable Vars
	variable Columns

	set nrows [expr {[llength $Vars(data)] + 1}]

	if {$row == [expr {$nrows - 2}]} {
		set style {}
		foreach col $Columns { lappend style [lindex $col 0] styLine }
		$table.t item style set $item {*}$style
		$table.t item enabled $item false
	} elseif {$row == [expr {$nrows - 1}]} {
		$table.t item style set $item {*}$Vars(styles)
	} else {
		$table.t item style set $item {*}[::table::defaultStyles $table]
		$table.t item element configure $row move elemTxtmove {*}$Vars(style)
		$table.t item element configure $row number elemTxtnumber {*}$Vars(style)
	}
}


proc PlaceMessage {} {
	variable Vars

	set width [expr {max(1, [winfo width $Vars(mw)] - 50)}]
	$Vars(mesg) configure -wraplength $width
}


proc SetMessage {} {
	variable Vars

	set txt [set mc::$Vars(message)]
	if {$Vars(message) eq "Searching"} { append txt "..." }
	$Vars(mesg) configure -text $txt
	PlaceMessage
}


proc ShowMessage {msg} {
	variable Vars

	set Vars(message) $msg
	SetMessage
	$Vars(mw) raise $Vars(mesg)
}


proc Format {value} {
	return [expr {$value/10}],[expr {$value%10}]
}


proc SetItemState {table index} {
	variable Options
	variable Vars

	if {$Vars(nextmove) != $index || !$Options(hilite:nextmove)} { append states ! }
	append states next
	$table.t item state set $index $states
}


proc FillTable {table} {
	variable Options
	variable Priv
	variable Columns
	variable Vars
	variable Bars

	if {[llength $Vars(data)] == 0} { return }

	set total [lindex $Vars(data) end [columnIndex frequency]]
	set nrows [llength $Vars(data)]
	set stm [::scidb::pos::stm]
	set row 1
	set nextMove [::scidb::game::next move]
	set Vars(nextmove) -1

	RefreshRatingLabel

	foreach rowData $Vars(data) {
		set col 0
		set text {}

		foreach entry $Columns {
			set id [lindex $entry 0]
			set item [lindex $rowData $col]

			switch $id {
				number {
					if {$row < [llength $Vars(data)]} {
						lappend text ${row}.
					} else {
						lappend text {}
					}
				}

				move {
					if {$row == [expr {$nrows + 1}]} {
						lappend text $mc::Total
					} else {
						set index [expr {$row - 1}]
						if {$item eq "end"} {
							if {[string length $nextMove] == 0} { set Vars(nextmove) $index }
							SetItemState $table $index
							# lappend text "\uff0d"
							# lappend text "\u2205"
							lappend text "\[$mc::End\]"
						} else {
							if {$nextMove eq $item} { set Vars(nextmove) $index }
							# if {$item eq "--"} { set item null }
							SetItemState $table $index
							lappend text [::font::translate $item]
						}
					}
					incr col
				}

				eco {
					lappend text [string range $item 0 2]
					incr col
				}

				frequency {
					lappend text [::locale::formatNumber $item]
				}

				ratio - score - draws {
					set item [ComputeValue $id $item $total]
					if {$Options($id:bar)} {
						set color [::colors::lookup $Priv($id:color)]
						set width [expr {($item + 10)/20}]
						if {![info exists Bars($width:$color)]} {
							set img [image create photo -width 51 -height 7]
							::scidb::tk::image recolor #000000 $img -composite set
							if {$Options(bar:transparent)} {
								::scidb::tk::image alpha 0.0 $img -composite set -area 1 1 50 6
							} else {
								::scidb::tk::image recolor #ffffff $img -composite set -area 1 1 50 6
							}
							::scidb::tk::image recolor $color $img -composite set -area 1 1 $width 6 
							set Bars($width) $img
						}
						lappend text [list @ $Bars($width)]
					} else {
						lappend text [Format $item]
					}

					incr col
				}

				performance {
					if {$item >= 0} {
						lappend text $item
					} else {
						lappend text {}
					}
					incr col
				}

				averageRating - bestRating - averageYear - lastYear {
					if {$item} {
						lappend text $item
					} else {
						lappend text {}
					}
					incr col
				}

				bestPlayer - frequentPlayer {
					lappend text [lindex $item 0]
					incr col
				}
			}
		}

		::table::insert $table [expr {$row - 1}] $text

		if {$nrows == 2} { return }

		if {[incr row] == $nrows} {
			::table::insert $table $row [lrepeat [llength $Columns] {}]
			incr row
		}
	}

	catch { ::table::see $table 0 }
	DoSelection $table
}


proc ComputeValue {id value total} {
	variable Options

	switch $id {
		ratio {
			set value [expr {int((1000.0*$value)/double($total) + 0.5)}]
		}
		score {
			switch $Options(score:side) {
				black {
					set value [expr {1000 - $value}]
				}
				sideToMove {
					if {[::scidb::pos::stm] eq "b"} {
						set value [expr {1000 - $value}]
					}
				}
			}
		}
	}

	return $value
}


proc FindIndex {table x y} {
	variable Vars

	set x [expr {$x - [winfo rootx $table]}]
	set y [expr {$y - [winfo rooty $table]}]
	lassign [::table::identify $table $x $y] row column
	set nrows [llength $Vars(data)]
	if {0 <= $row && ($nrows == 1 || $row < $nrows - 1)} { return $row }
	return -1
}


proc Select {table x y} {
	variable Vars

	set Vars(button) 1
	if {$Vars(activated)} { return }

	::tooltip::disable
	lassign [::table::identify $table $x $y] row column

	if {$row == -1} {
		::table::Highlight $table $x $y
	} else {
		set nrows [llength $Vars(data)]

		if {0 <= $row && ($nrows == 1 || $row < $nrows - 1)} {
			set move [::scidb::tree::move $row]
			if {[string length $move]} {
				set Vars(selected) $row
				::table::select $table $row
			}
		}
	}
}


proc Motion1 {table x y} {
	variable Vars

	if {!$Vars(enabled)} { return }
	if {$Vars(activated)} { return }
	if {$Vars(selected) == -1} { return }

	lassign [::table::identify $table $x $y] row column

	if {$row < 0} {
		::table::activate $table none
		::table::select $table none
		set offs [::table::scrolldistance $table $y]

		if {$offs != 0} {
			if {$offs < 0} {
				set Vars(dir) -1
			} else {	;# offs > 0
				set Vars(dir) +1
			}

			set Vars(interval) [expr {300/max(int(abs($offs)/5.0 + 0.5), 1)}]

			if {![info exists Vars(timer)]} {
				set Vars(timer) [after $Vars(interval) [namespace code [list Scroll $table]]]
			}
		} elseif {[info exists Vars(timer)]} {
			after cancel $Vars(timer)
			unset Vars(timer)
		}
	} else {
		if {[info exists Vars(timer)]} {
			after cancel $Vars(timer)
			unset Vars(timer)
		}
		if {$row == $Vars(selected)} {
			if {$row != [::table::selection $table]} {
				::table::select $table $row
			}
		} elseif {$row >= 0} {
			if {$Vars(selected) == [::table::selection $table]} {
				::table::select $table none
			}
		}
	}

	TreeCtrl::MotionInItems $table.t $x $y
}


proc Motion {w x y} {
	variable Vars

	if {$Vars(button) != 2} {
		TreeCtrl::CursorCheck $w $x $y
		TreeCtrl::MotionInHeader $w $x $y
		TreeCtrl::MotionInItems $w $x $y
	}
}


proc Leave {w} {
	variable Vars

	if {$Vars(button) != 2} {
		TreeCtrl::CursorCancel $w
		TreeCtrl::MotionInHeader $w
		TreeCtrl::MotionInItems $w
	}
}


proc Scroll {table} {
	variable Vars

	if {[info exists Vars(dir)]} {
		$table.t yview scroll $Vars(dir) units
		set Vars(timer) [after $Vars(interval) [namespace code [list Scroll $table]]]
	}
}


proc Activate {table} {
	variable Vars

	set Vars(button) 0
	::tooltip::enable

	if {[info exists Vars(dir)]} {
		catch { after kill $Vars(timer) }
		unset -nocomplain Vars(dir)
		unset -nocomplain Vars(timer)
		unset -nocomplain Vars(interval)
	}

	if {$Vars(activated)} { return }
	if {$Vars(selected) == -1} { return }

	set Vars(activated) 1
	
	if {$Vars(selected) == [::table::selection $table]} {
		set move [::scidb::tree::move $Vars(selected)]
		if {[string length $move]} {
			set action [::move::addMove menu $move \
				-nomovecmd [list set [namespace current]::Vars(activated) 0] \
				-actions {load} \
			]
			if {$action eq "load"} { LoadFirstGame $table $Vars(selected) $move }
		}
	} else {
		set Vars(activated) 0
	}

	set Vars(selected) -1
	::table::select $table none
	DoSelection $table
}


proc LoadFirstGame {table row move} {
	variable Vars

	set index [::scidb::tree::gameIndex $row]
	set fen [::scidb::tree::position $move]
	set base [::scidb::tree::get]
	set variant [::scidb::app::variant]
	set view [::scidb::tree::view]

	set position [::game::new $table -base $base -variant $variant -view $view -number $index -fen $fen]
}


proc Scrollbar {table state} {
	set parent [winfo parent $table]
	set sq $parent.square
	set sb $parent.scrollbar

	if {$state eq "hide"} {
		grid forget $sq
		grid $sb -row 0 -column 1 -rowspan 2 -sticky ns
	} elseif {$sq ni [grid slaves $parent]} {
		set size [winfo width $sb]
		$sq configure -width $size -height $size
		grid $sb -row 0 -column 1 -rowspan 1 -sticky ns
		grid $sq -row 1 -column 1
	}
}


proc SetReferenceBase {w} {
	variable ::scidb::clipbaseName
	variable Vars

	set index [[::toolbar::realpath $w] current]

	if {$index == 0} {
		set base $clipbaseName
	} else {
		set base [lindex $Vars(list) [expr {$index - 1}] 1]
	}

	::scidb::tree::set $base
}


proc FillSwitcher {w} {
	variable Vars

	set w [::toolbar::realpath $w]

	$w clear
	$w listinsert [list $::util::clipbaseName]

	set list {}
	foreach base [::scidb::tree::list] { lappend list [list [::util::databaseName $base] $base] }
### VARIANTS ####################################
set l {}
foreach entry $list {
	if {"Normal" in [::scidb::db::get variants [lindex $entry 1]]} { lappend l $entry }
}
set list $l
#################################################
	set list [lsort -dictionary -index 0 $list]

	foreach base $list {
		$w listinsert [list [lindex $base 0]]
	}

	set Vars(list) $list
	$w resize
}


proc SetSwitcher {base variant} {
	variable ::scidb::clipbaseName
	variable Vars

	set Vars(current:base) $base
	set Vars(current:variant) $variant
	set name [::util::databaseName $base]
	if {$name eq $clipbaseName} { set name $::util::clipbaseName }
	set Vars(name) $name
}


proc LanguageChanged {} {
	SetSwitcher [::scidb::tree::get] [::scidb::app::variant]
}


proc LockBase {} {
	variable Options
	::scidb::tree::switch [expr {!$Options(base:lock)}]
}


proc DoAction {table row move action} {
	if {$action eq "load"} {
		LoadFirstGame $table $row $move
	} else {
		::move::doAction $action $move
	}
}


proc ToggleView {table} {
	variable Options
	variable Vars

	if {$Vars(show:tree) == $Options(show:tree)} { return }

	if {$Options(show:tree)} {
		if {$Vars(eco:visible)} {
			::table::showColumn $table eco
		}
		::toolbar::childconfigure $Vars(widget:exact) -state normal
		::toolbar::childconfigure $Vars(widget:fast) -state normal
	} else {
		set Vars(eco:visible) [::table::visible? $table eco]
		::table::hideColumn $table eco
		::toolbar::childconfigure $Vars(widget:exact) -state disabled
		::toolbar::childconfigure $Vars(widget:fast) -state disabled
	}

	games::clear
	set Vars(show:tree) $Options(show:tree)
}


proc PopupMenu {table x y} {
	variable ::scidb::clipbaseName
	variable Vars
	variable Options
	variable _Current

	set Vars(button) 3
	set m $table.popup_menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	set row [FindIndex $table $x $y]

	if {$row >= 0} {
		::table::activate $table $row true
		after idle [list ::table::activate $table $row true]
		set move [::scidb::tree::move $row]
		if {[string length $move] && $move ne [::scidb::game::next move]} {
			::move::addActionsToMenu $m [namespace code [list DoAction $table $row $move]] {append load}
			$m add separator
		}
	}

#	$m add radiobutton \
#		-label $mc::ShowMoveTree \
#		-variable [namespace current]::Options(show:tree) \
#		-value 1 \
#		-command [namespace code [list ToggleView $table]] \
#	;
#	::theme::configureRadioEntry $m
#	$m add radiobutton \
#		-label $mc::ShowMoveOrders \
#		-variable [namespace current]::Options(show:tree) \
#		-value 0 \
#		-command [namespace code [list ToggleView $table]] \
#	;
#	::theme::configureRadioEntry $m
#	$m add separator
	$m add command \
		-label " $mc::StartSearch" \
		-command [namespace code startSearch] \
		-image $::icon::16x16::start \
		-compound left \
		;
	$m add separator
	if {$Options(show:tree)} {
		foreach {mode icon} {exact slow fast fast} {
			set text " [set mc::Use[string toupper $mode 0 0]Mode]"
			$m add radiobutton \
				-label $text \
				-variable [namespace current]::Options(search:mode) \
				-value $mode \
				-image [set ::icon::16x16::$icon] \
				-compound left \
				;
			::theme::configureRadioEntry $m
		}
		$m add separator
	}
	$m add checkbutton \
		-label $mc::AutomaticSearch \
		-variable [namespace current]::Options(search:automatic) \
		-image $::icon::16x16::search \
		-compound left \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $mc::LockReferenceBase \
		-variable [namespace current]::Options(base:lock) \
		-image $::icon::16x16::lock \
		-compound left \
		;
	::theme::configureCheckEntry $m
	$m add separator

	set n [menu $m.switch -tearoff false]
	$m add cascade -menu $n -label $mc::ChooseReferenceBase

	set list {}
	foreach base [::scidb::tree::list] {
		if {$base eq $Vars(current:base)} { set _Current $base }
		lappend list [list [::util::databaseName $base] $base]
	}
	if {$Vars(current:base) eq $clipbaseName} {
		set _Current $clipbaseName
	}

	set text $::util::clipbaseName
	$n add radiobutton \
		-label $text \
		-value $clipbaseName \
		-variable [namespace current]::_Current \
		-command [list ::scidb::tree::set $clipbaseName] \
		;
	::theme::configureRadioEntry $n $text
	foreach base [lsort -dictionary -index 0 $list] {
		lassign $base text value
		$n add radiobutton \
			-label $text \
			-value $value \
			-variable [namespace current]::_Current \
			-command [list ::scidb::tree::set $value] \
			;
		::theme::configureRadioEntry $n
	}

	::bind $m <<MenuUnpost>> [list after idle [list table::doSelection $table]]
	tk_popup $m $x $y
}


# proc ShowAllMoveOrders {parent} {
# 	set parent [winfo toplevel $parent]
# 	set dlg $parent.moveOrders
# 	set top $dlg.top
# 	set tb $top.table
# 	set exists [winfo exists $dlg]
# 	set lines [::scidb::game::lines]
# 
# 	if {$exists} {
# 		$tb clear
# 	} else {
# 		wm withdraw [tk::toplevel $dlg -class Dialog]
# 		set specialfont [list [list $::font::figurine(text:normal) 9812 9823]]
# 		set stripes [::colors::lookup scrolledtable,stripes]
# 		pack [ttk::frame $top -borderwidth 0 -takefocus 0] -fill both -expand yes
# 		pack [tlistbox $tb \
# 			-setgrid 1 \
# 			-maxheight 20 \
# 			-maxwidth 800 \
# 			-stripes $stripes \
# 			-takefocus 0
# 		] -fill both -expand yes
# 		$tb addcol text -id line -specialfont $specialfont -expand yes
# 	}
# 
# 	foreach line $lines { $tb insert [list $line] }
# 	$tb resize -force -dontshrink
# 
# 	if {$exists} {
# 		widget::dialogRaise $dlg
# 	} else {
# 		::widget::dialogButtons $dlg {close}
# 		::widget::dialogButtonAdd $dlg spread [namespace current]::mc::ComputeSpread {}
# 		$dlg.close configure -command [list destroy $dlg]
# 		$dlg.spread configure -command [namespace code [list ComputeSpread $tb]]
# 		::widget::dialogWatch $dlg
# 		wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
# 		wm title $dlg $mc::MoveOrders
# 		wm resizable $dlg true true
# 		::util::place $dlg -parent $parent -position center
# 		wm deiconify $dlg
# 	}
# 
# 	focus $dlg.close
# }


proc WriteOptions {chan} {
	variable Vars

	::options::writeItem $chan [namespace current]::Options

	puts $chan "::table::setOptions $Vars(table) {"
	::options::writeArray $chan [::table::getOptions $Vars(table)]
	puts $chan "}"
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace tree
} ;# namespace application

# vi:set ts=3 sw=3:
