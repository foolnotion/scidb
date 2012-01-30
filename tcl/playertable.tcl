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
# Copyright: (C) 2010-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval playertable {
namespace eval mc {

set Find							"Find"
set StartSearch				"Start search"
set ClearEntries				"Clear entries"
set NotFound					"Not found."

set Name							"Name"
set HighestRating				"Highest rating"
set MostRecentRating			"Most recent rating"
set DateOfBirth				"Date of birth"
set DateOfDeath				"Date of death"
set FideID						"Fide ID"

set TooltipRating				"Rating: %s"

set OpenInWebBrowser			"Open in web browser..."
set OpenPlayerCard			"%s player card"
set OpenFileCard				"%s file card"
set OpenFideRatingHistory	"FIDE rating history"
set OpenWikipedia				"Wikipedia biographie"
set OpenViafCatalog			"VIAF catalog"
set OpenPndCatalog			"catalog of Deutsche Nationalbibliothek"
set OpenChessgames			"chessgames.com collection"
set SeachIn365ChessCom		"Search in 365Chess.com"

set F_LastName					"Last Name"
set F_FirstName				"First Name"
set F_FideID					"Fide ID"
set F_Title						"Title"

set T_Federation				"Federation"
set T_RatingType				"Rating Type"
set T_Type						"Type"
set T_Sex						"Sex"
set T_PlayerInfo				"Info Flag"

# translation not needed (TODO)
set F_RatingType				"RT"
set F_Federation				"\u2691"
set F_Frequency				"\u2211"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::max

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------
set Columns {
	{ lastName		left		10		0		14			1			0			1			{}				}
	{ firstName		left		10		0		14			1			0			1			{}				}
	{ fideID			right		 0		0		10			0			1			1			{}				}
	{ type			center	 0		0		14px		0			1			0			{}				}
	{ sex				center	 0		0		14px		0			1			0			{}				}
	{ rating1		center	 0		0		 6			0			1			1			darkblue		}
	{ rating2		center	 0		0		 6			0			1			1			darkblue		}
	{ ratingType	left      0    0      7       0        1        0        darkblue		}
	{ federation	center	 0		0		 5			0			1			0			darkgreen	}
	{ title			left		 0		0		 5			0			1			1			darkred		}
	{ playerInfo	center	 0		0		14px		0			1			0			red			}
	{ frequency		right		 4		8		 5			0			0			1			{}				}
}

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Options {
	country-code	flags

	exclude-elo		1
	include-type	1

	rating1:which	highest
	rating2:which	highest
	rating1:type	Elo
	rating2:type	DWZ

	url:fide			"http://ratings.fide.com/card.phtml?event=%id%"
	url:iccf			"http://www.iccf-webchess.com/PlayerDetails.aspx?id=%id%"
	url:uscf			"http://main.uschess.org/assets/msa_joomla/MbrDtlMain.php?%id%"
	url:dsb			"http://www.schachbund.de/dwz/db/spieler.html?zps=%id%&amp;unloadcache=1"
	url:ecf			"http://grading.bcfservices.org.uk/getref.php?ref=%id%"
	url:viaf			"http://viaf.org/viaf/%id%"
	url:pnd			"http://d-nb.info/gnd/%id%"
	url:wikipedia	"http://%lang%.wikipedia.org/wiki/%name%"
	url:chessgames	"http://chessgames.com/player/%id%.html"
	url:365Chess	"http://www.365chess.com/search_result.php?wlname=%lastname%&wname=%firstname%&open=&blname=&bname=&eco=&nocolor=on&yeari=&yeare=&sply=1&ply=&res=&submit_search=1"
}

variable Find {}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable ::gametable::ratings
	variable Columns
	variable Options
	variable Find
	variable columns

	namespace eval [namespace current]::$path {}
	variable ${path}::Vars

	set mc::F_Rating1 $Options(rating1:type)
	set mc::F_Rating2 $Options(rating2:type)

	RefreshHeader 1
	RefreshHeader 2

	array set Vars {
		columns			{}
		find-current	{}
		selectcmd		{}
	}

	if {[llength $visibleColumns] == 0} { set visibleColumns $columns }

	set columns {}
	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		if {$id ne "firstName"} {
			lappend menu [list command \
				-command [namespace code [list SortColumn $path $id ascending]] \
				-labelvar ::gametable::mc::SortAscending]
			lappend menu [list command \
				-command [namespace code [list SortColumn $path $id descending]] \
				-labelvar ::gametable::mc::SortDescending]
			lappend menu [list command \
				-command [namespace code [list SortColumn $path $id reverse]] \
				-labelvar ::gametable::mc::ReverseOrder]
			lappend menu { separator }
		}

		switch $id {
			federation {
				foreach {labelvar value} {Flags flags PGN_CountryCode PGN ISO_CountryCode ISO} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar ::gametable::mc::$labelvar \
						-variable [namespace current]::Options(country-code) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			rating1 - rating2 {
				foreach ratType $ratings {
				set number [string index $id 6]
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $path $number]] \
						-label $ratType \
						-variable [namespace current]::Options($id:type) \
						-value $ratType \
					]
				}
				lappend menu { separator }
				foreach {labelvar value} {HighestRating highest MostRecentRating latest} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar [namespace current]::mc::$labelvar \
						-variable [namespace current]::Options($id:which) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			ratingType {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar ::gametable::mc::ExcludeElo \
					-variable [namespace current]::Options(exclude-elo) \
				]
				lappend menu { separator }
			}

			sex {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar ::gametable::mc::IncludePlayerType \
					-variable [namespace current]::Options(include-type) \
				]
				lappend menu { separator }
			}
		}

		switch $id {
			rating2 - ratingType - type - playerInfo { set visible 0 }
			default { set visible [expr {$id in $visibleColumns}] }
		}

		set ivar [namespace current]::icon::12x12::I_[string toupper $id 0 0]
		set fvar ::playertable::mc::F_[string toupper $id 0 0]
		set tvar ::playertable::mc::T_[string toupper $id 0 0]
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

		set opts {}
		lappend opts -justify $adjustment
		lappend opts -minwidth $minwidth
		lappend opts -maxwidth $maxwidth
		lappend opts -width $width
		lappend opts -stretch $stretch
		lappend opts -removable $removable
		lappend opts -ellipsis $ellipsis
		lappend opts -visible $visible
		lappend opts -foreground $color
		lappend opts -menu $menu
		lappend opts -image $ivar
		lappend opts -textvar $fvar
		lappend opts -tooltipvar $tvar

		lappend columns $id $opts

		if {$id ne "firstName"} {
			lappend Vars(columns) $id
		}
	}

	set options(-usefind) 0
	array set options $args
	set useFind $options(-usefind)
	unset options(-usefind)
	if {[info exists options(-selectcmd)]} {
		set Vars(selectcmd) $options(-selectcmd)
		unset options(-selectcmd)
	}
	set args [array get options]
	lappend args -popupcmd [namespace code PopupMenu]

	ttk::frame $path -takefocus 0 -borderwidth 0
	set table $path.table
	set Vars(table) [::scrolledtable::build $table $columns {*}$args]
	pack $table -fill both -expand yes

	::bind $table <<TableFill>>		[namespace code [list TableFill $path %d]]
	::bind $table <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $table <<TableVisit>>		[namespace code [list TableVisit $path %d]]

	set Vars(viewcmd) $getViewCmd

	::scrolledtable::bind $table <ButtonPress-2>		[namespace code [list ShowInfo $path %x %y]]
	::scrolledtable::bind $table <ButtonRelease-2>	[namespace code [list hideInfo $path]]
	::scrolledtable::bind $table <ButtonPress-3>		+[namespace code [list hideInfo $path]]

#	::scrolledtable::configure $table lastName -font2 $::font::figurine

	if {$useFind} {
		set tbFind [::toolbar::toolbar $path \
			-id find \
			-hide 1 \
			-side bottom \
			-alignment left \
			-allow {top bottom} \
			-tooltipvar [namespace current]::mc::Find] \
			;
		::toolbar::add $tbFind label -float 0 -textvar [::mc::var [namespace current]::mc::Find ":"]
		set cb [::toolbar::add $tbFind ttk::combobox \
			-width 20 \
			-takefocus 1 \
			-values $Find \
			-textvariable [namespace current]::${path}::Vars(find-current)] \
			;
		::bind $cb <Return> [namespace code [list Find $path $cb]]
		::toolbar::add $tbFind button \
			-image $::icon::22x22::enter \
			-tooltipvar [namespace current]::mc::StartSearch \
			-command [namespace code [list Find $path $cb]] \
			;
		::toolbar::add $tbFind button \
			-image $::icon::22x22::clear \
			-tooltipvar [namespace current]::mc::ClearEntries \
			-command [namespace code [list Clear $path $cb]] \
			;
	}

	return $Vars(table)
}


proc init {path base} {
	set [namespace current]::${path}::Vars($base:index) -1
}


proc forget {path base} {
	variable ${path}::Vars

	::scrolledtable::forget $path.table $base
	unset -nocomplain Vars($base:index)
}


proc columnIndex {name} {
	variable columns
	return [lsearch -exact $columns $name]
}


proc column {info name} {
	variable columns
	return [lindex $info [lsearch -exact $columns $name]]
}


proc clear {path} {
	::scrolledtable::clear $path.table
}


proc clearColumn {path id} {
	::scrolledtable::clearColumn $path.table $id
}


proc fill {path first last} {
	::scrolledtable::fill $path.table $first $last
}


proc update {path base size} {
	::scrolledtable::update $path.table $base $size
}


proc changeLayout {path dir} {
	return [::scrolledtable::changeLayout $path.table $dir]
}


proc overhang {path} {
	return [::scrolledtable::overhang $path.table]
}


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path.table]
}


proc selectedPlayer {path base} {
	return [set [namespace current]::${path}::Vars($base:index)]
}


proc getOptions {path} {
	return [::scrolledtable::getOptions $path.table]
}


proc setOptions {path options} {
	::scrolledtable::setOptions $path.table $options
}


proc scroll {path position} {
	::scrolledtable::scroll $path.table $position
}


proc activate {path row} {
	::scrolledtable::activate $path.table $row
}


proc select {path row} {
	::scrolledtable::select $path.table $row
}


proc setSelection {path row} {
	::scrolledtable::setSelection $path.table $row
}


proc index {path} {
	return [::scrolledtable::index $path.table]
}


proc indexToRow {path index} {
	return [::scrolledtable::indexToRow $path.table $index]
}


proc at {path y} {
	return [::scrolledtable::at $path.table $y]
}


proc focus {path} {
	::scrolledtable::focus $path.table
}


proc bind {path sequence script} {
	::scrolledtable::bind $path.table $sequence $script
}


proc see {path position} {
	::scrolledtable::see $path.table $position
}


proc showInfo {path info} {
	lassign $info \
		name fideID type sex elo unused unused country titles unused unused dateOfBirth dateOfDeath
	if {[string length $name] == 0} { return }
	if {[string index $fideID 0] eq "-"} { set fideID [string range $fideID 1 end] }

	set w $path.showinfo
	catch { destroy $w }
	set top [::util::makePopup $w]
	set bg [$top cget -background]

	set f [tk::frame $top.f -borderwidth 0 -background $bg]
	grid $f -column 3 -row 1

	lassign $elo highestRating mostRecentRating
	set highestRating [abs $highestRating]
	set mostRecentRating [max 0 $mostRecentRating]
	set dateOfBirth [::locale::formatDate $dateOfBirth]
	set dateOfDeath [::locale::formatDate $dateOfDeath]
	switch $sex {
		m			{ set sex $::genderbox::mc::Gender(m) }
		f			{ set sex $::genderbox::mc::Gender(f) }
		default	{ set sex "" }
	}
	set federation [::country::name $country]
	if {$type eq "program"} {
		set title $::genderbox::mc::Gender(c)
	} else {
		set title ""
	}
	foreach t $titles {
		if {[string length $title]} { append title "\n" }
		append title $::titlebox::mc::Title($t)
	}
	set row 1
	foreach var {	name sex dateOfBirth dateOfDeath highestRating
						mostRecentRating title federation fideID} {
		set value [set $var]
		if {[string length $value] == 0 || $value == 0} { set value "\u2013" }
		set attr [string toupper $var 0 0]
		if {[info exists mc::T_$attr]} {
			set text [set mc::T_$attr]
		} elseif {[info exists mc::F_$attr]} {
			set text [set mc::F_$attr]
		} else {
			set text [set mc::$attr]
		}
		tk::label $f.lbl$row -background $bg -text "$text:"
		tk::label $f.val$row -background $bg -text $value -justify left
		grid $f.lbl$row -row $row -column 3 -sticky nw
		grid $f.val$row -row $row -column 5 -sticky w
#		grid rowconfigure $f [expr {$row + 1}] -minsize $::theme::padding
		incr row 2
	}
	grid columnconfigure $f 4 -minsize $::theme::padding
	grid columnconfigure $f {2 6} -minsize 2
	grid rowconfigure $f [list 0 [incr row -1]] -minsize 2

	if {[FindPlayerPhoto $name $info]} {
		tk::frame $top.lt -background $bg -borderwidth 0
		set lbl [tk::label $top.lt.photo -background $bg -image PlayerPhoto_ -relief solid]
		grid $lbl -column 1 -row 1
	}

	set icon [::country::countryFlag $country]
	if {[llength $icon]} {
		if {![winfo exists $top.lt]} { tk::frame $top.lt -background $bg -borderwidth 0 }
		set lbl [tk::label $top.lt.flag -background $bg -image $icon -borderwidth 0]
		grid $lbl -column 1 -row 3 -sticky n
	}

	if {[winfo exists $top.lt]} {
		grid $top.lt -column 1 -row 1
		grid columnconfigure $top 0 -minsize 2
		grid columnconfigure $top 2 -minsize $::theme::padding
		grid rowconfigure $top {0 2} -minsize 2

		if {[winfo exists $top.lt.photo] && [winfo exists $top.lt.flag]} {
			grid rowconfigure $top.lt 2 -minsize 3
		}
	}

	::tooltip::popup $path $w cursor
}


proc hideInfo {path} {
	::tooltip::popdown $path.showinfo
}


proc popupMenu {menu info} {
	variable Options

	set parent    [winfo toplevel $menu]
	set name      [column $info lastName]
	set lastName  [string trim [lindex [split $name ,] 0]]
	set firstName [string trim [lindex [split $name ,] 1]]
	set fideID    [lindex $info  1]
	set dsbID     [lindex $info 13]
	set ecfID     [lindex $info 14]
	set iccfID    [lindex $info 15]
	set viafID    [lindex $info 16]
	set pndID     [lindex $info 17]
	set cgdcID    [lindex $info 18]
	set wikiLinks [lindex $info 19]

	if {[string index $fideID 0] eq "-"} { set fideID [string range $fideID 1 end] }

	if {	[string length $fideID]
		|| [string length $iccfID]
		|| [string length $dsbID]
		|| [string length $ecfID]
		|| [llength $wikiLinks]
		|| [string length $viafID]
		|| [string length $pndID]
		|| [string length $cgdcID]} {

		set state normal
	} else {
		set state disabled
	}

	set m [menu $menu.web -tearoff false]
	$menu add cascade -menu $m -state $state -label " $mc::OpenInWebBrowser"
	
	$m add command \
		-label " [format $mc::OpenPlayerCard Fide]" \
		-state [expr {[string length $fideID] ? "normal" : "disabled"}] \
		-image $icon::16x16::Fide \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $fideID] $Options(url:fide)]] \
		;
	$m add command \
		-label " [format $mc::OpenPlayerCard ICCF]" \
		-state [expr {[string length $iccfID] ? "normal" : "disabled"}] \
		-image $icon::16x16::ICCF \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $iccfID] $Options(url:iccf)]] \
		;
#	$m add command \
#		-label " [format $mc::OpenPlayerCard USCF]" \
#		-state [expr {[string length $uscfID] ? "normal" : "disabled"}] \
#		-image $icon::16x16::USCF \
#		-compound left \
#		-command [list ::web::open $parent [string map [list %id% $uscfID] $Options(url:uscf)]] \
#		;
	$m add command \
		-label " [format $mc::OpenFileCard DWZ]" \
		-state [expr {[string length $dsbID] ? "normal" : "disabled"}] \
		-image $icon::16x16::DSB \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $dsbID] $Options(url:dsb)]] \
		;
	$m add command \
		-label " [format $mc::OpenPlayerCard ECF]" \
		-state [expr {[string length $ecfID] ? "normal" : "disabled"}] \
		-image $icon::16x16::ECF \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $ecfID] $Options(url:ecf)]] \
		;
	set sub [menu $m.wiki -tearoff false]
	$m add cascade \
		-menu $sub \
		-label " $mc::OpenWikipedia" \
		-state [expr {[llength $wikiLinks] ? "normal" : "disabled"}] \
		-image $icon::16x16::Wikipedia \
		-compound left \
		;
	$m add command \
		-label " $mc::OpenViafCatalog" \
		-state [expr {[string length $viafID] ? "normal" : "disabled"}] \
		-image $icon::16x16::VIAF \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $viafID] $Options(url:viaf)]] \
		;
	$m add command \
		-label " $mc::OpenPndCatalog" \
		-state [expr {[string length $pndID] ? "normal" : "disabled"}] \
		-image $icon::16x16::PND \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $pndID] $Options(url:pnd)]] \
		;
	$m add command \
		-label " $mc::OpenChessgames" \
		-state [expr {[string length $cgdcID] ? "normal" : "disabled"}] \
		-image $icon::16x16::ChessgamesDotCom \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $cgdcID] $Options(url:chessgames)]] \
		;
	set url [string map [list %lastname% $lastName %firstname% $firstName] $Options(url:365Chess)]
	$m add command \
		-label " $mc::SeachIn365ChessCom" \
		-image $icon::16x16::365ChessCom \
		-compound left \
		-command [list ::web::open $parent $url]
		;
	
	foreach {lang name} $wikiLinks {
		set flag ""
		catch { set flag $::country::icon::flag($::mc::langToCountry($lang)) }
		if {[string length $flag] == 0} { set flag $::icon::16x16::none }
		set url [string map [list %lang% $lang %name% $name] $Options(url:wikipedia)]
		$sub add command \
			-label " [::encoding::languageName $lang]" \
			-image $flag \
			-compound left \
			-command [list ::web::open $parent $url] \
			;
	}

#	if {![::scidb::db::get readonly? $base]} {
#		$menu add separator
#		$menu add command \
#			-label " $::mc::Edit..." \
#			-command [namespace code [list RenamePlayer $parent $index]] \
#			;
#	}
}


proc RefreshHeader {number} {
	variable Options

	set mc::F_Rating$number $Options(rating$number:type)
	set mc::T_Rating$number [format $mc::TooltipRating $Options(rating$number:type)]
}


proc RefreshRatings {path number} {
	RefreshHeader $number
	::scrolledtable::refresh $path.table
}


proc NormalizeName {name} {
	set key [string map {. "" " " "" - ""} [string tolower $name]]
	set index [string last ",dr" $key]
	if {$index >= 0} { set key [string range $key 0 [expr {$index - 1}]] }
	return $key
}


proc FindPhotoFile {name} {
	set dir [string index $name 0]
	if {![string match {[a-z]} $dir]} { return "" }
	set path [file join $::scidb::dir::home photos $dir $name]
	if {[file readable $path]} { return $path }
	set path [file join $::scidb::dir::photos $dir $name]
	if {[file readable $path]} { return $path }
	return ""
}


proc FindPlayerPhoto {name info} {
	set key [NormalizeName $name]
	set file [FindPhotoFile $key]
	set found $file

	if {[string length $found] == 0} {
		set aliases [lindex $info 20]

		foreach alias $aliases {
			set key [NormalizeName $alias]
			set file [FindPhotoFile $key]
			if {[string length $file]} {
				set found $file
				break
			}
		}
	}

	if {[string length $found] == 0} { return 0 }

	catch {
		set fd [open $found rb]
		set data [read $fd]
		image create photo PlayerPhoto_ -data $data
		set rc 1
	}

	return $rc
}


proc Refresh {path} {
	set table $path.table
	::scrolledtable::clear $table
	::scrolledtable::refresh $table
}


proc TableSelected {path index} {
	variable ${path}::Vars

	if {[llength $Vars(selectcmd)]} {
		::widget::busyCursor on
		set base [::scrolledtable::base $path.table]
		set view [{*}$Vars(viewcmd) $base]
		set Vars($base:index) [::scidb::db::get playerIndex $index $view $base]
		{*}$Vars(selectcmd) $base $view
		::widget::busyCursor off
	}
}


proc view {path} {
	variable ${path}::Vars
	return [{*}$Vars(viewcmd) [::scrolledtable::base $path.table]]
}


proc TableFill {path args} {
	variable icon::12x12::check
	variable ${path}::Vars
	variable Options

	lassign [lindex $args 0] table base start first last columns

	set codec [::scidb::db::get codec $base]
	set view [{*}$Vars(viewcmd) $base]
	set last [expr {min($last, [scidb::view::count players $base $view] - $start)}]
	set ratings [list $Options(rating1:type) $Options(rating2:type)]

	if {![info exists Vars($base:index)]} {
		set Vars($base:index) -1
	}

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set base [::scrolledtable::base $path.table]
		set line [scidb::db::get playerInfo $index $view $base -ratings $ratings]
		set text {}
		set k -1

		foreach id $columns {
			set item [lindex $line [incr k]]

			switch $id {
				lastName {
					if {[string length $item] == 0} {
						lappend text "-"
					} else {
						set parts [split $item ,]
						lappend text [lindex $parts 0]
						lappend text [lindex [lrange $parts 1 end] 0]
					}
				}

				firstName {
					incr k -1
				}

				fideID {
					if {[string index $item 0] eq "-"} {
						lappend text "[string range $item 1 end]*"
					} else {
						lappend text "$item "
					}
				}

				playerInfo {
					if {$item} {
						# TODO: only for 12pt; use U+2716 (or U+2718) for other sizes
						set image $check
					} else {
						set image {}
					}
					lappend text [list @ $image]
				}

				sex {
					switch $item {
						m { set icon $::icon::12x12::male }
						f { set icon $::icon::12x12::female }

						default	{
							if {$Options(include-type) && $type eq "program"} {
								set icon $::icon::12x12::program
							} else {
								set icon {}
							}
						}
					}
					lappend text [list @ $icon]
				}

				rating1 - rating2 {
					if {$Options($id:which) eq "highest"} {
						set value [lindex $item 0]
					} else {
						set value [lindex $item 1]
						if {$value == 0} { set value [lindex $item 0] }
					}
					if {$value == 0} {
						lappend text ""
					} elseif {$value > 0} {
						lappend text [format " %4d " $value]
					} elseif {$value <= -1000} {
						lappend text [format "(%4d)" [abs $value]]
					} else {
						lappend text [format " (%3d)" [abs $value]]
					}
				}

				ratingType {
					if {$Options(exclude-elo) && $item eq "Elo"} {
						lappend text {}
					} else {
						lappend text $item
					}
				}

				title {
					lappend text [lindex $item 0]
				}

				type {
					if {[string length $item]} {
						lappend text [list @ [set ::icon::12x12::$item]]
					} else {
						lappend text [list @ {}]
					}
					set type $item
				}

				federation {
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

				default {
					lappend text $item
				}
			}
		}

		::table::insert $table $i $text
	}
}


proc TableVisit {path data} {
	variable ${path}::Vars
	variable Options

	lassign $data base mode id row
	set table $path.table

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	switch $id {
		federation - title - type {}
		sex { if {!$Options(include-type)} { return } }
		default { return }
	}

	if {$id eq "sex"} {
		set col [lsearch -exact $Vars(columns) type]
	} else {
		set col [lsearch -exact $Vars(columns) $id]
	}

	set view [{*}$Vars(viewcmd) $base]
	set row  [::scrolledtable::rowToIndex $table $row]
	set item [::scidb::db::get playerInfo $row $view $base $col]

	if {[string length $item] == 0} { return }

	switch $id {
		federation	{ set tip [::country::name $item] }
		title			{ set tip $::titlebox::mc::Title([lindex $item 0]) }
		type			{ set tip $::gametable::mc::PlayerType($item) }

		sex { 
			if {$item eq "program"} {
				set tip $::gametable::mc::PlayerType(program)
			} else {
				set tip ""
			}
		}
	}

	if {[string length $tip]} {
		::tooltip::show $table $tip
	}
}


proc SortColumn {path id dir} {
	variable ${path}::Vars
	variable Options

	::widget::busyCursor on
	set base [::scrolledtable::base $path.table]
	set view [{*}$Vars(viewcmd) $base]
	set table $path.table
	set ratings [list $Options(rating1:type) $Options(rating2:type)]
	set see 0
	set selection [::scrolledtable::selection $table]
	if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $table]} { set see 1 }
	if {$dir eq "reverse"} {
		::scidb::db::reverse player $base $view
	} else {
		set options [list -ratings $ratings]
		if {[string match {rating*} $id] && $Options($id:which) eq "latest"} {
			lappend options -latest
		}
		if {$dir eq "descending"} { lappend options -descending }
		set column [::scrolledtable::columnNo $table $id]
		if {$column > 1} { incr column -1 }
		::scidb::db::sort player $base $column $view {*}$options
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupPlayer $selection $view $base]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $table $selection $see
}


proc Find {path combo} {
	variable ${path}::Vars
	variable Find

	set value $Vars(find-current)
	if {[string length $value] == 0} { return }
	set base [::scrolledtable::base $path.table]
	set view [{*}$Vars(viewcmd) $base]
	set i [::scidb::view::find player $base $view $value]
	if {[string length $value] > 2} {
		lappend Find $value
		set Find [lsort -dictionary -increasing -unique $Find]
		::toolbar::childconfigure $combo -values $Find
	}
	if {$i >= 0} {
		::scrolledtable::see $path.table $i
		::scrolledtable::focus $path.table
	} else {
		::dialog::info -parent [::toolbar::lookupChild $combo] -message $mc::NotFound
	}
}


proc Clear {path combo} {
	variable ${path}::Vars
	variable Find

	set Find {}
	::toolbar::childconfigure $combo -values {}
	set Vars(find-current) {}
}


proc ShowInfo {path x y} {
	variable ${path}::Vars

	set table $path.table
	set index [::scrolledtable::at $table $y]
	if {![string is digit $index]} { return }
	::scrolledtable::focus $table
	::scrolledtable::activate $table [::scrolledtable::indexToRow $table $index]
	set base [::scrolledtable::base $table]
	set view [{*}$Vars(viewcmd) $base]
	set info [scidb::db::get playerInfo $index $view $base -card -ratings {Elo Elo}]
	showInfo $path $info
}


proc PopupMenu {table menu base index} {
	set path [winfo parent $table]
	variable ${path}::Vars
	variable Options

	if {![string is digit $index]} { return }

	set view [{*}$Vars(viewcmd) $base]
	set info [scidb::db::get playerInfo $index $view $base -info]

	popupMenu $menu $info
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::Find
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 12x12 {

set I_Type [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAEESURB
	VBjTY2AAAj0gTk1OfKzz3rzFhc2aAQ4sGAxlkq+l/Ff9b/LW2sIGIaHFoKWv/kb+v8p/0z+2
	obYICXkGeRn524r/rf+Hfo61jUFIKDOIsBgsMf7v8z/3XLV4OUKCA2iYRpDRb5//4fU2DNNg
	wjwMLEzSaroTbP66/zdao2AsySoHEnZl8BYK69J7ZPzP93/gf8v/eq81F6oqqjMweDA4hqX9
	Dv4f9D/kf/B/v//u/23/GxU7MDC4M5hW+f9v+l//v/p/1f+S/5lAfY6zgUbFMRjUOv4o+lfz
	vxYIa/4X/Xf6bTRfgpVBjUFGVDXMa0r6gfzLBddyjocs0kyUknNhAACyuV8yGfi7+AAAAABJ
	RU5ErkJggg==
}]

set I_PlayerInfo [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAB2SURB
	VBgZbcE9DsFgAADQRyJqsUnayRHEJSwSu8TPIWow6j0MtbhBF9FVHMEJDCajRWqRSL7Pe/yM
	VDZaIoVGrScyVZv7o22gK9KXu8oFUqWHRiGwcHD0MhFIZC5uUpGxp9JQJrD2tneyFNhp3G0l
	AjNnKx1fH6/zGA8ObbOQAAAAAElFTkSuQmCC
}]

set I_Sex $::icon::12x12::yinyang

set check [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAABuklEQVQoz32QP2gTUQCHf++9u8tdcjnOIz1qsUVNUilY
	KlYtCoKTi/9ABEWwq4OB6ORUF10srYNSkIqTi9pFRFF0F5QKhVoKNkpEKcY2ofGSy7s/7163
	ghD7zb9v+H0M25DeZ6eNXrMAhnXRigAAbDtBL5rjow/Ove3vL1y283aee/4v5X/j7IBN3dN7
	yr2HhsjY2JFBs+oN3kJptbtAANqnXXHH88MSApWlL3JubvJ2c2TjnqJaKThDbg9RaQ9vBV83
	Fn7HVt4x7EvuHbKD4k+lIt88e329bTVn7PumoEbRLKtnSE2/qi6pI+yFklFhHLSuWRdyu/zV
	BuafvLzbcbwZbVqK+nINiozwjmoU+t4UkmPiVJB1RpUCuxl7HN8fL87GB8QEKYeiUw8AABT1
	ZLn9yf+AEFBdFeG31sPMiWzu56OVp7wYlMIbf2PRjLfusdDjyFiWYxzVT5Ishb7b6Gu8X//M
	j4vzdCoORDWEFHJLoAAgIOejSggqCfgKX+P7xUUyG/nhgi+R/BuQAQATpIaULPEqDxo7W2e1
	j2wxftWRSSy6FQdSuTQUWzscudEaBsiP6HlbykSiG5sKg7NehOto0gAAAABJRU5ErkJggg==
}]

} ;# namespace 12x12

namespace eval 16x16 {

set Fide [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAADAFBMVEUiMVkmNF0nNl0oNmAn
	N14oN14pN18pOF8qOF8qOGAqOV8qOWArOV8qOl8rOmArOmEsOmAsOmEsO2EsO2ItO2IuPGIu
	PGMvPGIvPWMwPmQxP2QxP2UyP2UyQGUyQWYzQWUzQWY0QWYzQmU0QmY2RGg3RGk4RGk4Rmk5
	Rmk6SGs8Sm09Sm0/TG5ATW9DUHNFUXNGUnFGVHRIVHRHVXZIVXRJVXRKV3ZNWXhOWXhUXn9T
	YH1UYH9XYH9YYX9dZ4RhbIdibIhhbYhibYhjbYhmcotpc41rd5BweJBzfpZ6hJt+hp2AiZ2J
	kqOKk6WVm66VnKuXnq2Xnq+aoK6epbWhp7OmrLinrLqnrbyutMKwtcC2usa2vMe4vcS7v8e7
	wMm9wsjLztTMz9PQ0trQ09nR1NnR1drS1dnT1dvT19vX2d7Z2t3Z2t7a2t7c3eHd3eHc3uDc
	3uHd3uHd3uLc3+Hd3+Hd3+Pe3+He3+Tf4OHe4ePe4ebf4eTg4uTh4uXh4+Xi4+Xi5Obj5ejk
	5unn5+nl6Ono6uvq6uvq6uzq6+zq7Ovr7O3s7e/t7u/v8PLw8PDv8fHw8fLx8fLx8vTx8/T1
	9fX29vb39/f4+Pn6+vv7+vv8/f39/f7/////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////+x
	IAogAAAAAWJLR0T/pQfyxQAAAAlwSFlzAAAASAAAAEgARslrPgAAANRJREFUGNNjUEADDNgE
	5ISYxdTVRNn4ZMECisIibhFJaRPLozzkuZWBAvzW0WVTw/UcM6fVxzpzKjBIGBTPmR7JIMxo
	1TxpTq+tAIN0akdlkYOLDr9NTml1U5U2g3nfhP7+njAZJu+JrZ1dPfYMFnn5JTUp4hJMnm11
	DbX1TgwqjT0F2XGqulrmyVm57ZP1GUTsWmbMnhJiahQwadbMbnceBgUO14yKhFBLs6DEwnQv
	LpBLeZV8A31i4v2D/TTYIU6XZRXQNDQxFmSRQnhOVlJSEodvAWIQPt+YToStAAAAInpUWHRD
	b21tZW50AAB42nMuSk0sSU1RKM8syVBw9/QNAAA3nQXih332+AAAAABJRU5ErkJggg==
}]

set VIAF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAVFBMVEUAAAD/AAD/AAD/AAD/
	AAD/AAD/AAD/AAD/AAD/AAD/AAD/CAj/EBD/GBj/ISH/KSn/MTH/OTn/QkL/UlL/Wlr/Y2P/
	c3P/e3v/hIT/jIz/lJT/nJzfRPm7AAAACnRSTlMAECEpMTlKUlpr0isF6AAAAIFJREFUGBkF
	wQtiglAMALCU8ioUZR8V1N3/nksg5hxGxjRyBvHY0ueIeNwGsF458X0A1s07yE7A0qPw2gGq
	T/g6AcaOuPQCMCWiRgEozFWjCqgOpu3M+Q7ipyeqJxngqE6e+99xAcvz6MF19Q7Il+xSHUD8
	hupP3m8JZGbMOTIzwT9JowRosixU4gAAAABJRU5ErkJggg==
}]

set PND [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAMElEQVQ4y2NggAHjM/9hzJln
	GCDsmf/hYv/PGMPZZ4wRbCYGCsGoAaMGjBowWAwAAA5vDEZFz8UhAAAAAElFTkSuQmCC
}]

set Olimpbase [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEWwrKzy8vL////wkSGV
	AAAAHklEQVQI12MIBQKGrJUOjLgJsBIw4cCYtRI3AVICAFJ9FUGX+2YSAAAAAElFTkSuQmCC
}]

set Wikipedia [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAA6klEQVQoz6WRsQ3DIBBF7wAr
	VYo0cTbAtStL7l2lZwSkzEDrAdIwAyOwQwZghChDROQOY8lSoihSRAEc7/79O6CX3xf8D4gJ
	A0Qx9RINRJyVptOMQWml0dMbXV2XGSA6dlnppkUHtpe0e7AEKA139E1LgD3lgz2e0TPOQPWA
	QTzEUFDSQIeGo1TcVEBMpOFKESszhprvuHDtAiJEtqf0mCFyhCzOmzZJ9smCBUgl07LRzRwg
	YSBZc8ljZnPo2PYGQLe77a9oWBoS2MXTFjCQqANTLCcqM7yNejVKsIf04S/EtGYpvUz2p896
	AezgV2Eyd2fxAAAAAElFTkSuQmCC
}]

set ICCF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAACt0lEQVQ4y12Rz4sUVxDHP+/165n+MTP2/GrXHfCo5pKD
	Me6SQHJJIDcJOeYWl9xzykkIIUfzA0HEPyD3kCjkICyIRCSKhuQkyK7ZFTYz2zP2bs9093a/
	fjnYoyYFRb1XFJ+q+pa4eNF8l+fsb21xLct4Y7Hg8zAkPn2a769fZ3t9nfcOD9k4fpzZmTN8
	++QJzokTfCYErmVRqs1NvlCKZ+02m1HEpb09PppMoCxZnD3LD1HEpfGYD8ZjyHPiU6eY377N
	l0kC7TaoyQSaTYznsba/z7oxlHGMmk65MBqx/fgx56WkimPkbMbHts1vUQRxDFkGUggwBhOG
	nBOCIAi4G4ZMx2NaUvKOZdFZWeGPMCR+/pzOfI4H0OsRHzvGLQkgBCJNaRoDQvBMKRZZhhVF
	+MYAsKMU6XyOzDKUEFAU/Nrr8amsC4QxCIA6CiEQWiN5zbR+VQeYJCFTov7WIKTE9PscSIm0
	LHQ9YdXvE0tJpRSlMRAEfDgacVktabWTJOxrzYZSICWfAKQpe77PZcuicl0uAOzs0B8M2PjP
	iABVRd7p8NB1uS8l6TJn2zx0XR5YFjmAetE6U/8HOA5BmnI1yxC2TQXQaDCQkmtFQZWm5EJA
	GPJoNOLKEiBqx7Zpz2a8G0VIz+NenetMp7wdReijI+4AjMc8unGDH5crGKUwy7fWUJYYpdC1
	yEZrqKpXWkmJFALrJcD3KaQEY+gWBQ3HQQ+HpEJAWdIvChq+T+U4FK+vLJe3n0z4U2uSNOX9
	6ZTBYECiNQ/ynPnBAeejiF4QcNhqvRD25dldFxwHCfw+GrGdpjRtG9Hp8MvRET+fPMlukmA3
	m9Dp8NNiwU6jAZ6H5XlIa23tq/7KCnd9n5tBwD/DIW+trnK/1eJrz2Or3eag2+XN1VXuDYd8
	s7vL390uaRCw+fQpf/0Lr1kjDHVG8/MAAAAASUVORK5CYII=
}]

set DSB [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA51BMVEUSEREWFRQjIiI0MzM7
	EA1ANxtANx1FRERKEw9OOzlOPTtPRSNQTUxRTUxRTk1RTk5STk5SUE9SUVFSUlFTUlJUU1NV
	VFRWVVVdXVxnJSBvYjZ0Jhd1Hxl4d3d+bTeEIhuIiIiOfD+ZmZmqqqqtl0y7u7u9pVPMPjLM
	zMzNPzTZSCvZSCzaOynaPyvaQCvaRizbOSzbOy/bPTHbPjLbPjPbQTXcQDPcQDTcQzfcQzjc
	RTncUEXcwGLd3d3szWbszWfszmfszmjszmnt0G3t0G7t0nPu0XHu7u759/f7+fn8+vr9+/v/
	///cr/VjAAAAAWJLR0RM928Q8wAAAL9JREFUGBk1wQsjg2AUgOFD7LisfQu5RyL3a6whHctl
	G73///dg2vMI0O5mz+9mTAgEncXe9ZsZE0LQWeqfm9EQXJBlr/ZJQ9Zccd+zD6akrud2r162
	NQZVPUTGm/nWwV5MnKCMPOR79fZs/mgjKWE2jiLky2V3LSsTTfDSVEsZu2J/Z7lkpChEqdT1
	zMLJcUu9U0Q1QtZ995RXxpSw4of55cBoCPh+8XAzMP4JhK79mF9U1ZA/AoTOZf3CKuPXD0lh
	NPjifAX2AAAAAElFTkSuQmCC
}]

set USCF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAwMD///8chckP
	AAAAAXRSTlMAQObYZgAAAAFiS0dEAmYLfGQAAABASURBVAjXYwgFAgbRsKkhDKJRS2EEiCu2
	NGoKg9SqVUuQCLFVq6YwiIaGApWsWgUlWFetCmBgDA11YGBgdGAAAOJKGAxPwtmzAAAAAElF
	TkSuQmCC
}]

set ECF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAFVBMVEUAAAAAAIAAgIAA//+A
	gIDAwMD///+l7zIHAAAAAWJLR0QGYWa4fQAAADtJREFUCNdjYEAAtjQgSmBgCGJLMxIDMZTY
	0oLADJgUCEP56AyGVLY0ZzYUXYJsaYxYdAXBGErI2qEAACDeFlFInMaQAAAAAElFTkSuQmCC
}]

set ChessgamesDotCom [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEX///+AAAC098j+AAAA
	AXRSTlMAQObYZgAAABNJREFUCNdj4OdngKMPHxAIhzgAKl8P8bapubgAAAAASUVORK5CYII=
}]

set 365ChessCom [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACs0lEQVQ4y42TPWxTVxTHf/e+L9uxE8dNsEJicJKGqqCi
	VlAJKJ8SBVoQC526shQGJCp16VbW7jBX6tIutFIlxAQVCIkGxEAFIYRgi8RJbMfEBn+89+69
	j4HiEAoSRzrD+frrp6NzhFKauVr765ly56TS9PAeJiX+hox3cTwb/8UuLT/f+/fDzh8I4QDY
	QvNhRhBqw6MVi3yvwnUsHtcMQ0mIuTaFmqJU18e0Co09u1A/iog5r9QtETGa7UUpja+ekx9I
	kIjH8IMa+cEEyUSc+ZVlgkjImYX6CVtp7STbReJhlUrvNgQAAs/z+HTU62J/kh8AIIqibs4P
	wh7pmCZ7Hpxl58MfSTcfEBpJodxAKY020RtuKCzVaWurK2IrmeDe8En62rM04qMYJNNVje0E
	lDvWmuUlbc1cVWOwVwVWAiFz5Sn67SIRguHaFdY3JxlK7mNj/ksQottstGax1sLXoE1EJ4yw
	s4+vWk5qiCA9zpYbP5Dfvxtn5BvsxUk6t87jf3YKA2gDSsNUJeB+NWS5pdmaDrAHh7O0lpq0
	Ags5foDi7Sf4F87g7vgKkc7SnpqGdWNdisJTzXxjlUrKjZuJ2s8wz2qIgfX4Ny9BFBH8cxkr
	Nwblwpo9JByxJrbVv9eQmRymViKcvNwtCMcFpVjwHVpPo/9uBFKeBMwqgSnPQU8KOTKBnr7d
	Lbi7jhNO38HktmKJl8NSwP5NKfJ9rxGIniTCiyN704i+NFG1gjW2BZn7CL+0yPC6Ptaay/YR
	l0I9eClgPj4QmplJTKmIe+Q0MjMAgaJy5SLtQ99Do/W/Z2oFCoCYTdP2gsaf9cr8d4nBoXjn
	13MI10F8kOXnwZ/wr3fe+ZEx/PCLXPSbUEpx687dw8XC7LfBo7ueSKUR8SRT7QxaOG8dtiyh
	d070/3Vw9+e/vwABiS7BVQ8I3wAAAABJRU5ErkJggg==
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace playertable

# vi:set ts=3 sw=3:
