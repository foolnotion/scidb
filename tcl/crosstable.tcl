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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval crosstable {
namespace eval mc {

set TournamentTable	"Tournament Table"
set AverageRating		"Average Rating"
set Category			"Category"
set Games				"games"
set Game					"game"

set Tiebreak			"Tie-break Rule"
set Settings			"Settings"
set RevertToStart		"Revert to initial values"
set UpdateDisplay		"Update display"

set None					"None"
set Buchholz			"Buchholz"
set MedianBuchholz	"Median-Buchholz"
set ModifiedMedianBuchholz "Mod. Median Buchholz"
set RefinedBuchholz	"Refined-Buchholz"
set SonnebornBerger	"Sonneborn-Berger"
set Progressive		"Progressive Score"
set KoyaSystem			"Koya-System"
set GamesWon			"Number of Games Won"

set Crosstable			"Crosstable"
set Scheveningen		"Scheveningen"
set Swiss				"Swiss System"
set Match				"Match"
set Knockout			"Knockout"
set RankingList		"Ranking List"

set Order				"Order"
set Type					"Table Type"
set Score				"Score"
set Alphabetical		"Alphabetical"
set Rating				"Rating"
set Federation			"Federation"

set Debugging			"Debugging"
set Display				"Display"
set Style				"Style"
set Spacing				"Spacing"
set Padding				"Padding"
set ShowLog				"Show Log"
set ShowHtml			"Show HTML"
set ShowRating			"Show Rating"
set ShowPerformance	"Show Performance"
set ShowTiebreak		"Show Tiebreak"
set ShowOpponent		"Show Opponent (as Tooltip)"
set KnockoutStyle		"Knockout Table Style"
set Pyramid				"Pyramid"
set Triangle			"Triangle"

set CrosstableLimit	"The crosstable limit of %d players will be exceeded."
set CrosstableLimitDetail "'%s' is choosing another table mode."

} ;# namespace mc

namespace import ::tcl::mathfunc::max

variable ImageCache

array set Nodes {}

array set Colors {
	background	#ffffff
	highlighted	#ebf4f5
	mark			#ffdd76
}

array set Scripts {
	Crosstable		"crosstable.eXt"
	Scheveningen	"scheveningen.eXt"
	Swiss				"swiss.eXt"
	Match				"match.eXt"
	Knockout			"knockout.eXt"
	RankingList		"rankingList.eXt"
}

set TypeList {
	Crosstable
	Scheveningen
	Swiss
	Match
	Knockout
	RankingList
}

set TiebreakList {
	None
	SonnebornBerger
	Buchholz
	MedianBuchholz
	ModifiedMedianBuchholz
	RefinedBuchholz
	Progressive
	KoyaSystem
	GamesWon
}

set OrderList {
	Score
	Alphabetical
	Rating
	Federation
}

variable RecentlyUsedHistory {}
variable MostRecentHistory {}

array set RecentlyUsedTiebreaks {
	Crosstable		SonnebornBerger
	Swiss				Buchholz
	Scheveningen	{}
	Match				{}
	Knockout			{}
	RankingList		{}
}

array set Defaults {
	base					{}
	index					-1
	number				-1
	frozen				0
	tiebreaks			{}
	bestMode				RankingList
	order					Score
	browserId			{}
	overviewId			{}
	crosstableLimit	60
}

array set Options {
	debug:log			0
	debug:html			0
	fmt:padding			3
	fmt:spacing			1
	fmt:pyramid			0
	show:rating			1
	show:performance	1
	show:tiebreak		1
	show:opponent		1
}

array set Vars [array get Defaults]
variable Path .application.crosstable
variable Geometry "1024x768"


proc open {parent base index {view -1}} {
	variable TiebreakList
	variable OrderList
	variable TypeList
	variable Vars
	variable Options
	variable Geometry
	variable Path

	set dlg $Path

	if {$view == -1} {;# we assume a game index
		set info [::scidb::db::fetch eventInfo $index $base]
		set number $index
	} else {				;# we assume an event index
		set info [::scidb::db::get eventInfo $index $view $base]
		set number [::scidb::db::get eventIndex $index $view $base]
	}
	lassign $info country site title type date mode timeMode
	set key [list $base $site $title $type $date $mode $timeMode]

	if {$Vars(base) eq $base && $Vars(key) == $key} {
		raise $dlg
		focus $dlg
		return
	}

	set top $dlg.top
	set canv $top.canv
	set html $canv.html

	set Vars(html) $html
	set Vars(base) $base
	set Vars(view) $view
	set Vars(index) $index
	set Vars(number) $number
	set Vars(info) $info
	set Vars(key) $key
	set Vars(warning) {}
	set Vars(lastMode) ""
	set Vars(prevMode) ""
	set Vars(prevTiebreaks) ""

	if {[winfo exists $dlg]} {
		::scidb::crosstable::release $Vars(base) $Vars(handle)
		if {$view < 0} { set type game } else { set type event }
		set Vars(handle) [::scidb::crosstable::make $base $type $number]
		Update 1
		return
	}

	set Vars(tooltip) ""

	toplevel $dlg -class Scidb
	bind $dlg <Destroy> [namespace code [list Destroy $dlg %W]]
	wm withdraw $dlg

	ttk::frame $top
	ttk::frame $canv
	::html $html -nodehandler [namespace current]::NodeHandler -imagecmd [namespace code GetImage]
	bind [winfo parent [$html drawable]] <ButtonPress-3> [namespace code PopupMenu]

	set tb [::toolbar::toolbar $dlg \
				-id settings \
				-allow {top bottom} \
				-titlevar [namespace current]::mc::Settings \
				-padx 4 \
				-pady 2 \
			]
	foreach entry $TiebreakList { lappend Vars(tiebreakList) [set mc::$entry] }
	foreach entry $OrderList { lappend Vars(orderList) [set mc::$entry] }
	foreach entry $TypeList { lappend Vars(typeList) [set mc::$entry] }
	set Vars(value:order) [lindex $Vars(orderList) 0]
	set Vars(value:type) [lindex $Vars(typeList) 0]

	set f1 [::toolbar::add $tb frame]
	set f2 [::toolbar::add $tb frame]
	set f3 [::toolbar::add $tb frame]

	foreach i {1 2 3 4} {
		set Vars(label:tiebreak$i) "$i. $mc::Tiebreak"
		set Vars(value:tiebreak$i) [lindex $Vars(tiebreakList) 0]
		set f [set f[expr {($i - 1)/2 + 1}]]
		set r [expr {(1 - ($i%2))*2 + 1}]
		tk::label $f.label$i -textvar [namespace current]::Vars(label:tiebreak$i)
		::ttk::combobox $f.choose$i \
			-takefocus 0 \
			-exportselection 0 \
			-state readonly  \
			-values $Vars(tiebreakList) \
			-textvar [namespace current]::Vars(value:tiebreak$i) \
			-width 21 \
			;
		set Vars(widget:tiebreak$i) $f.choose$i
		grid $f.label$i  -row $r -column 1 -sticky w
		grid $f.choose$i -row $r -column 3 -sticky ew
	}

	tk::label $f3.label_type -textvar [namespace current]::mc::Type
	::ttk::combobox  $f3.choose_type \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-values $Vars(typeList) \
		-textvar [namespace current]::Vars(value:type) \
		-width 16 \
		;
	set Vars(widget:type) $f3.choose_type

	tk::label $f3.label_order -textvar [namespace current]::mc::Order
	::ttk::combobox $f3.choose_order \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-values $Vars(orderList) \
		-textvar [namespace current]::Vars(value:order) \
		-width 12 \
		;
	set Vars(widget:order) $f3.choose_order

	::toolbar::add $tb separator
	::toolbar::add $tb button \
		-image $icon::32x32::go \
		-command [namespace code Refresh] \
		-tooltipvar [namespace current]::mc::UpdateDisplay \
		;
	::toolbar::add $tb button \
		-image $icon::32x32::reset \
		-command [namespace code Reset] \
		-tooltipvar [namespace current]::mc::RevertToStart \
		;

	grid $f3.label_type   -row 1 -column 1 -sticky w
	grid $f3.choose_type  -row 1 -column 3 -sticky ew
	grid $f3.label_order  -row 3 -column 1 -sticky w
	grid $f3.choose_order -row 3 -column 3 -sticky ew

	foreach i {1 2 3} {
		set f [set f$i]
		grid columnconfigure $f 2 -minsize $::theme::padding
		grid rowconfigure $f {0 2 4} -minsize 3
	}

	grid columnconfigure $f2 0 -minsize $::theme::padX
	grid columnconfigure $f3 0 -minsize $::theme::padX
	grid columnconfigure $f3 4 -minsize $::theme::padding

	$html onmouseover		[namespace current]::MouseEnter
	$html onmouseout		[namespace current]::MouseLeave
	$html onmousedown1	[namespace current]::Mouse1Down
	$html onmousedown2	[namespace current]::Mouse2Down
	$html onmouseup2		[namespace current]::Mouse2Up
	$html onmousedown3	[namespace current]::Mouse3Down

	pack $top -expand yes -fill both

	grid $canv -row 1 -column 1 -sticky nsew
	grid columnconfigure $top 1 -weight 1
	grid rowconfigure $top 1 -weight 1

	grid $html -row 0 -column 0 -sticky nsew
	grid columnconfigure $canv 0 -weight 1
	grid rowconfigure $canv 0 -weight 1

	bind $dlg <<Language>> [namespace code [list LanguageChanged $dlg %W]]

	if {$view >= 0} {
		::widget::dialogButtons $dlg {close previous next} close
		$dlg.previous configure -command [namespace code [list NextEvent -1]]
		$dlg.next configure -command [namespace code [list NextEvent +1]]
	} else {
		::widget::dialogButtons $dlg close close
	}
	$dlg.close configure -command [list destroy $dlg]

	if {$view < 0} { set type game } else { set type event }
	set Vars(handle) [::scidb::crosstable::make $base $type $number]
	Update 1

	scan $Geometry "%dx%d" w h
	set w [max 1024 $w]
	set h [max 768 $h]
	bind $dlg <Configure> [namespace code [list RecordGeometry $dlg]]

	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm geometry $dlg "${w}x${h}"
	wm resizable $dlg yes yes
	wm deiconify $dlg

	update idletasks
	wm minsize $dlg [expr {max(840, [winfo width [::toolbar::realpath $tb]] + 4)}] 400
}


proc RecordGeometry {dlg} {
	set [namespace current]::Geometry [lindex [split [wm geometry $dlg] +] 0]
}


proc NextEvent {step} {
	variable Vars

	::scidb::crosstable::release $Vars(base) $Vars(handle)
	incr Vars(index) $step
	set Vars(number) [::scidb::db::get eventIndex $Vars(index) $Vars(view) $Vars(base)]
	set Vars(handle) [::scidb::crosstable::make $Vars(base) event $Vars(number)]
	set Vars(warning) 0
	set Vars(lastMode) ""
	set Vars(prevMode) ""
	set Vars(prevTiebreaks) ""
	Update 1
}


proc LanguageChanged {dlg w} {
	variable Vars
	variable TiebreakList
	variable OrderList
	variable TypeList

	if {$dlg ne $w} { return }
	wm title $dlg "$::scidb::app: $mc::TournamentTable$Vars(eventName)"

	set parent $Vars(widget:tiebreak1)
	foreach entry $TiebreakList { lappend tiebreakList [set mc::$entry] }
	foreach i {1 2 3 4} {
		set n [lsearch $Vars(tiebreakList) $Vars(value:tiebreak$i)]
		set Vars(label:tiebreak$i) "$i. $mc::Tiebreak"
		$Vars(widget:tiebreak$i) configure -values $tiebreakList
		set clone [::toolbar::lookupClone $parent $Vars(widget:tiebreak$i)]
		if {[llength $clone]} { $clone configure -values $tiebreakList }
		if {$n >= 0} { set Vars(value:tiebreak$i) [lindex $tiebreakList $n] }
	}
	set Vars(tiebreakList) $tiebreakList

	set n [lsearch $Vars(orderList) $Vars(value:order)]
	foreach entry $OrderList { lappend orderList [set mc::$entry] }
	$Vars(widget:order) configure -values $orderList
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:order)] $Vars(widget:order)]
	if {[llength $clone]} { $clone configure -values $orderList }
	if {$n >= 0} { set Vars(value:order) [lindex $orderList $n] }
	set Vars(orderList) $orderList

	set n [lsearch $Vars(typeList) $Vars(value:type)]
	foreach entry $TypeList { lappend typeList [set mc::$entry] }
	$Vars(widget:type) configure -values $typeList
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:type)] $Vars(widget:type)]
	if {[llength $clone]} { $clone configure -values $typeList }
	if {$n >= 0} { set Vars(value:type) [lindex $typeList $n] }
	set Vars(typeList) $typeList

	Update
}


proc GetImage {code} {
	variable ImageCache

	if {![info exists ImageCache($code)]} {
		set src $::country::icon::flag($code)
		set img [image create photo -width [image width $src] -height [image height $src]]
		$img copy $src
		set ImageCache($code) $img
	}

	return $ImageCache($code)
}


proc Reset {} {
	variable Vars

	foreach attr {	tiebreaks bestMode value:type value:tiebreak1
						value:tiebreak2 value:tiebreak3 value:tiebreak4} {
		set Vars($attr) $Vars(reset:$attr)
	}
	Refresh
}


proc Refresh {} {
	variable Vars
	variable TypeList
	variable OrderList
	variable TiebreakList

	set Vars(prevMode) $Vars(bestMode)
	set Vars(prevTiebreaks) $Vars(tiebreaks)
	set Vars(order) [lindex $OrderList [lsearch $Vars(orderList) $Vars(value:order)]]
	set Vars(bestMode) [lindex $TypeList [lsearch $Vars(typeList) $Vars(value:type)]]
	set Vars(tiebreaks) {}
	for {set i 1} {$i <= 4} {incr i} {
		set n [lsearch $Vars(tiebreakList) $Vars(value:tiebreak$i)]
		if {$n > 0} { lappend Vars(tiebreaks) [lindex $TiebreakList $n] }
	}

	Update
	UpdateHistory
}


proc UpdateHistory {} {
	variable RecentlyUsedTiebreaks
	variable RecentlyUsedHistory
	variable MostRecentHistory
	variable Vars

	set RecentlyUsedTiebreaks($Vars(bestMode)) $Vars(tiebreaks)

	if {$Vars(prevMode) ne $Vars(bestMode) || $Vars(prevTiebreaks) ne $Vars(tiebreaks)} {
		set event $Vars(event)
		set i [lsearch -index 0 $RecentlyUsedHistory $event]

		if {$i >= 0} {
			set RecentlyUsedHistory [lreplace $RecentlyUsedHistory $i $i]
		} elseif {[llength $RecentlyUsedHistory] == 30} {
			set lastEntry [lindex $RecentlyUsedHistory end]
			set RecentlyUsedHistory [lreplace $RecentlyUsedHistory end end]
			set hist [concat $MostRecentHistory $lastEntry]
			set hist [lsort -indices {0 2} -decreasing $hist]
			if {[llength $hist] > 20} { set hist [lreplace $hist end end] }
			set MostRecentHistory $hist
		}

		set entry [list $Vars(bestMode) $Vars(tiebreaks)]
		set RecentlyUsedHistory [linsert $RecentlyUsedHistory 0 [list $event $entry]]
	}
}


proc Update {{setup 0}} {
	variable Vars
	variable Defaults
	variable Options
	variable ImageCache
	variable Scripts
	variable Highlighted
	variable Marks
	variable Nodes
	variable TypeList

	set w $Vars(html)
	set base $Vars(base)
	set view $Vars(view)
	set index $Vars(index)
	set handle $Vars(handle)

	array unset ImageCache

	if {$setup} {
		variable TiebreakList
		variable RecentlyUsedTiebreaks
		variable OrderList
		variable TypeList
		variable RecentlyUsedHistory
		variable MostRecentHistory

		set info $Vars(info)
		set name [lindex $info [::eventtable::columnIndex event]]
		set eventType [lindex $info [::eventtable::columnIndex eventType]]
		set eventDate [lindex $info [::eventtable::columnIndex eventDate]]
		set eventMode [lindex $info [::eventtable::columnIndex eventMode]]
		set timeMode [lindex $info [::eventtable::columnIndex timeMode]]
		set eventCountry [lindex $info [::eventtable::columnIndex eventCountry]]
		set site [lindex $info [::eventtable::columnIndex site]]
		if {[string length $name] <= 1} { set Vars(eventName) "" } else { set Vars(eventName) " ($name)" }
		set Vars(event) [list $name $eventDate $site $eventCountry $eventType $eventMode $timeMode]
		set i [lsearch -index 0 $RecentlyUsedHistory $Vars(event)]

		if {$i >= 0} {
			lassign [lindex $RecentlyUsedHistory $i 1] bestMode tiebreaks
		} else {
			set i [lsearch -index 0 $MostRecentHistory $Vars(event)]

			if {$i >= 0} {
				lassign [lindex $MostRecentHistory $i 1] bestMode tiebreaks
			} else {
				set bestMode [::scidb::crosstable::get bestMode $base $handle]
				set tiebreaks $RecentlyUsedTiebreaks($bestMode)
			}
		}

		set i 0
		foreach tb $tiebreaks {
			set Vars(value:tiebreak[incr i]) [lindex $Vars(tiebreakList) [lsearch $TiebreakList $tb]]
		}
		for {incr i} {$i <= 4} {incr i} {
			set Vars(value:tiebreak$i) [lindex $Vars(tiebreakList) 0]
		}
		set Vars(value:type) [lindex $Vars(typeList) [lsearch $TypeList $bestMode]]
		set Vars(bestMode) $bestMode
		set Vars(tiebreaks) $tiebreaks

		foreach attr {	tiebreaks bestMode value:type value:tiebreak1
							value:tiebreak2 value:tiebreak3 value:tiebreak4} {
			set Vars(reset:$attr) $Vars($attr)
		}

		wm title [winfo toplevel $w] "$::scidb::app: $mc::TournamentTable$Vars(eventName)"
		ConfigureButtons
	}

	set font [$w font]
	array set metrics [font metrics $font]

	set linespace $metrics(-linespace)
	set charWidth [font measure $font "0"]
	set order $Vars(order)
	set tiebreaks $Vars(tiebreaks)
	set bestMode $Vars(bestMode)
	set searchDir [file join $::scidb::dir::share scripts]
	set script $Scripts($bestMode)
	if {$Options(fmt:pyramid)} { set knockoutOrder pyramid } else { set knockoutOrder triangle }

	set preamble "
		\\def\\FormatDate#date{\\%date\\%#date}
		\\def\\AverageRating{$mc::AverageRating}
		\\def\\Category{$mc::Category}
		\\def\\Games{$mc::Games}
		\\def\\Game{$mc::Game}
		\\let\\DecimalPoint[::locale::decimalPoint]
		\\let\\Linespace\\$linespace
		\\let\\CharWidth\\$charWidth
		\\let\\CellSpacing\\$Options(fmt:spacing)
		\\let\\CellPadding\\$Options(fmt:padding)
		\\let\\Tracing\\$Options(debug:log)
		\\let\\UsePyramid\\$Options(fmt:pyramid)
		\\let\\ShowRating\\$Options(show:rating)
		\\let\\ShowTiebreaks\\$Options(show:tiebreak)
		\\let\\ShowPerformance\\$Options(show:performance)
		\\let\\ShowChange\\1
		\\let\\ShowCountry\\1
	"

	if {$Vars(bestMode) eq "Crosstable"} {
		append preamble "\\let\\TableLimit\\$Defaults(crosstableLimit)"
		set id [list $base $Vars(handle)]

		if {$Vars(warning) ne $id} {
			set playerCount [::scidb::crosstable::get playerCount $base $handle]

			if {$playerCount > $Defaults(crosstableLimit)} {
				set detail ""
				if {[string length $Vars(prevMode)] == 0} {
					set cancel [::menu::stripAmpersand $::dialog::mc::Cancel]
					set detail [format $mc::CrosstableLimitDetail $cancel]
				}
				set rc [::dialog::warning \
							-parent $Vars(html) \
							-message [format $mc::CrosstableLimit $Defaults(crosstableLimit)] \
							-detail $detail \
							-title [tk appname] \
						]
				if {$rc eq "cancel"} {
					set Vars(bestMode) $Vars(lastMode)
					if {[string length $Vars(prevMode)] == 0} {
						set Vars(bestMode) [::scidb::crosstable::get bestMode $base $handle]
						if {$Vars(bestMode) eq "Crosstable"} { set Vars(bestMode) RankingList }
						set Vars(value:type) [lindex $Vars(typeList) [lsearch $TypeList $Vars(bestMode)]]
						UpdateHistory
						after idle [namespace code Update]
					}
					return
				}
				set Vars(warning) $id
			}
		}
	} else {
		set Vars(warning) {}
	}
	set Vars(lastMode) $Vars(bestMode)

	::widget::busyCursor on
	set result [::scidb::crosstable::emit \
						$base $handle $searchDir $script $bestMode $order $knockoutOrder $tiebreaks $preamble]
	lassign $result html Vars(output:log)

	set i [string first "%date%" $html]
	while {$i >= 0} {
		set e [expr {$i + 15}]
		set date [string range $html [expr {$i + 6}] $e]
		set html [string replace $html $i $e [::locale::formatNormalDate $date]]
		set i [string first "%date%" $html]
	}

	array unset Highlighted
	array unset Marks
	array unset Nodes

	$w parse $html
	::widget::busyCursor of

	set Vars(output:html) $html
	set show(log) $Options(debug:log)
	set show(html) $Options(debug:html)
	if {[string length $Vars(output:log)]} { set show(log) yes }

	set w [winfo toplevel $w]
	foreach attr {log html} {
		if {$show($attr)} {
			ShowTrace $attr
		} elseif {[winfo exists $w.$attr]} {
			destroy $w.$attr
		}
	}
	set Vars(tooltip) ""
}


proc ConfigureButtons {} {
	variable Vars

	set dlg [winfo toplevel $Vars(html)]
	if {![winfo exists $dlg.next]} { return }

	if {$Vars(index) == -1} {
		$dlg.previous configure -state disabled
		$dlg.next configure -state disabled
	} else {
		if {$Vars(index) == 0} { set state disabled } else { set state normal }
		$dlg.previous configure -state $state
		set count [scidb::view::count events $Vars(base) $Vars(view)]
		if {$Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$dlg.next configure -state $state
	}
}


proc ShowTrace {which} {
	variable Vars

	set dlg [winfo toplevel $Vars(html)].$which
	set txt $dlg.f.text

	if {[winfo exists $dlg]} {
		$txt configure -state normal
		$txt delete 1.0 end
	} else {
		toplevel $dlg -class Scidb
		set f [::ttk::frame $dlg.f]

		tk::text $f.text \
			-width 100 \
			-height 40 \
			-yscrollcommand [list $f.vsb set] \
			-xscrollcommand [list $f.hsb set] \
			-wrap [expr {$which eq "log" ? "word" : "none"}] \
			-setgrid 1 \
			;
		ttk::scrollbar $f.hsb -orient horizontal -command [list $f.text xview]
		ttk::scrollbar $f.vsb -orient vertical -command [list ::widget::textLineScroll $f.text]
		pack $f -expand yes -fill both
		grid $f.text -row 1 -column 1 -sticky nsew
		grid $f.hsb  -row 2 -column 1 -sticky ew
		grid $f.vsb  -row 1 -column 2 -sticky ns
		grid rowconfigure $f 1 -weight 1
		grid columnconfigure $f 1 -weight 1
		if {$which eq "log"} { grid remove $f.hsb }
		::widget::dialogButtons $dlg close close
		$dlg.close configure -command [namespace code [list CloseTrace $which]]
#		::util::place $dlg center $w
		wm protocol $dlg WM_DELETE_WINDOW [namespace code [list CloseTrace $which]]
		wm deiconify $dlg
	}

	$txt insert end $Vars(output:$which)
	$txt configure -state disabled
}


proc CloseTrace {which} {
	variable Options
	variable Vars

	set Options(debug:$which) 0
	catch { destroy [winfo toplevel $Vars(html)].$which }
}


proc ToggleTrace {which} {
	variable Options

	if {$Options(debug:$which)} {
		ShowTrace $which
	} else {
		CloseTrace $which
	}
}


proc Destroy {dlg w} {
	if {$w ne $dlg} { return }

	variable Vars
	variable Defaults
	variable ImageCache

	::scidb::crosstable::release $Vars(base) $Vars(handle)
	array unset ImageCache
	array unset Vars
	array set Vars [array get Defaults]
}


proc Open {which gameIndex} {
	variable Vars

	set base $Vars(base)
	set info [::scidb::db::get gameInfo $gameIndex -1 $base]
	set path .application

	if {$which eq "pgn"} {
		::widget::busyOperation ::game::new $path $base $gameIndex
	} else {
		set Vars(${which}Id) \
			[::widget::busyOperation ::${which}::load $path $base $info -1 $gameIndex $Vars(${which}Id)]
	}
}


proc Tooltip {msg} {
	variable Vars

	if {$msg eq "hide"} {
		::tooltip::hide yes
	} else {
		::tooltip::hide no ;# XXX probably we need a fix in tooltip.tcl
		::tooltip::show $Vars(html) $msg
	}
}


proc NodeHandler {node} {
	variable Nodes

	set attr [$node attribute -default {} recv]
	if {[llength $attr]} { set Nodes($attr) $node }
}


proc MouseEnter {node} {
	variable Vars
	variable Options

	HandleEnterLeave $node EnterNode

	set country [$node attribute -default {} src]
	if {[llength $country]} {
		set Vars(tooltip) $node
		Tooltip [::country::name $country]
	}

	if {$Options(show:opponent)} {
		set rank [$node attribute -default {} player]
		if {[llength $rank]} {
			set Vars(tooltip) $node
			Tooltip [::scidb::crosstable::get playerName $Vars(base) $Vars(handle) $rank]
		}
	}
}


proc MouseLeave {node {stimulate 0}} {
	variable Vars

	HandleEnterLeave $node LeaveNode

	if {$Vars(tooltip) eq $node} {
		set Vars(tooltip) ""
		foreach attr {src player} {
			set content [$node attribute -default {} $attr]
			if {[llength $content]} { Tooltip hide }
		}
	}

	if {$stimulate} {
		$Vars(html) stimulate
		::tooltip::hide
	}
}


proc HandleEnterLeave {node action} {
	variable Vars

	set id [$node attribute -default {} recv]
	if {[string length $id]} { $action $id }

	set attr [$node attribute -default {} send]
	foreach id [split $attr :] { $action $id }
}


proc EnterNode {id} {
	variable Highlighted
	variable Nodes
	variable Marks
	variable Colors

	catch {
		set node $Nodes($id)
		if {![info exists Marks($node)]} {
			$node attribute bgcolor $Colors(highlighted)
		}
		incr Highlighted($node)
	}
}


proc LeaveNode {id} {
	variable Highlighted
	variable Nodes
	variable Marks
	variable Colors

	if {[catch { set node $Nodes($id) }]} { return }

	if {[info exists Highlighted($node)]} {
		if {$Highlighted($node) > 0} {
			if {[incr Highlighted($node) -1] == 0} {
				if {![info exists Marks($node)]} {
					$node attribute bgcolor $Colors(background)
				}
			}
		}
	}
}


proc Hilite {idList} {
	variable Highlighted
	variable Marks
	variable Nodes
	variable Colors

	set oldIdList {}

	foreach node [array names Marks] {
		lappend oldIdList $Marks($node)
		set attr background
		catch { if {$Highlighted($node) > 0} { set attr highlighted } }
		$node attribute bgcolor $Colors($attr)
	}
	array unset Marks

	set curr [lindex $idList end]
	foreach id [split $idList :] {
		if {$id ni $oldIdList} {
			catch {
				set node $Nodes($id)
				set Marks($node) $id
				$node attribute bgcolor $Colors(mark)
			}
		}
	}
}


proc Mouse1Down {node} {
	variable Vars

	if {[llength $node] == 0} { return }
	set gameIndex [$node attribute -default {} game]
	if {[string length $gameIndex]} {
		Open browser $gameIndex
		$Vars(html) stimulate
		::tooltip::hide
	}
	set mark [$node attribute -default {} mark]
	if {[string length $mark]} {
		set idList [$node attribute -default {} send]
		if {[string length $idList]} { append idList : }
		append idList $mark
		Hilite $idList
	}
}


proc Mouse2Down {node} {
	variable Vars
	variable Path

	if {[llength $node] == 0} { return }
	set gameIndex [$node attribute -default {} game]
	if {[string length $gameIndex]} {
		MouseEnter $node
		::gametable::showGame $Path $Vars(base) -1 $gameIndex 
	} else {
		set rank [$node attribute -default {} rank]
		if {[string length $rank]} {
			MouseEnter $node
			set info [::scidb::crosstable::get playerInfo $Vars(base) $Vars(handle) $rank]
			::playertable::showInfo $Path $info
		}
	}
}


proc Mouse2Up {node} {
	variable Path
	variable Vars

	if {[llength $node] == 0} { return }
	set attr [$node attribute -default {} recv]
	if {[string length $attr] == 0} { return }

	::gametable::hideGame $Path
	::playertable::hideInfo $Path
	MouseLeave $node 1
}


proc Mouse3Down {node} {
	variable Vars
	variable Path
	variable _Popup

	if {[llength $node] == 0} {
		if {[info exists _Popup]} { return }
		return [PopupMenu]
	}

	set gameIndex [$node attribute -default {} game]
	if {[string length $gameIndex] == 0} { return }

	set m $Path.popup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false

	$m add command \
		-label $::browser::mc::BrowseGame \
		-command [namespace code [list Open browser $gameIndex]] \
		;
	$m add command \
		-label $::overview::mc::Overview \
		-command [namespace code [list Open overview $gameIndex]] \
		;
	$m add command \
		-label [string map {& {}} $::browser::mc::LoadGame] \
		-command [namespace code [list Open pgn $gameIndex]] \
		;
	# TODO: add Merge Game

	$m add separator
	BuildMenu $m

	MouseEnter $node
	set _Popup 1
	bind $m <<MenuUnpost>> [list unset [namespace current]::_Popup]
	bind $m <<MenuUnpost>> +[namespace code [list MouseLeave $node 1]]
	tk_popup $m {*}[winfo pointerxy $Path]
}


proc BuildMenu {m} {
	variable Options
	variable Vars

	set sub [menu $m.display]

	if {$Vars(bestMode) eq "Knockout"} { set state disabled } else { set state normal }
	foreach opt {rating performance tiebreak} {
		$sub add checkbutton \
			-label [set mc::Show[string toupper $opt 0 0]] \
			-command [namespace code Update] \
			-variable [namespace current]::Options(show:$opt) \
			-state $state \
			;
	}

	if {$Vars(bestMode) eq "Swiss"} { set state normal } else { set state disabled }
	$sub add checkbutton \
		-label $mc::ShowOpponent \
		-variable [namespace current]::Options(show:opponent) \
		-state $state
		;

	$m add cascade -label $mc::Display -menu $sub

	set sub [menu $m.style]

	menu $sub.spacing
	menu $sub.padding
	menu $sub.knockout

	foreach pad {1 2 3 4 5 6} {
		$sub.padding add radiobutton \
			-label $pad \
			-command [namespace code Update] \
			-variable [namespace current]::Options(fmt:padding) \
			-value $pad \
			;
	}
	foreach spc {0 1} {
		$sub.spacing add radiobutton \
			-label $spc \
			-command [namespace code Update] \
			-variable [namespace current]::Options(fmt:spacing) \
			-value $spc \
			;
	}

	if {$Vars(bestMode) eq "Knockout"} { set state normal } else { set state disabled }

	$sub add cascade -label $mc::Spacing -menu $sub.spacing
	$sub add cascade -label $mc::Padding -menu $sub.padding
	$sub add cascade -label $mc::KnockoutStyle -menu $sub.knockout -state $state

	$sub.knockout add radiobutton \
		-label $mc::Triangle \
		-command [namespace code Update] \
		-variable [namespace current]::Options(fmt:pyramid) \
		-value 0 \
		;
	$sub.knockout add radiobutton \
		-label $mc::Pyramid \
		-command [namespace code Update] \
		-variable [namespace current]::Options(fmt:pyramid) \
		-value 1 \
		;

	$m add cascade -label $mc::Style -menu $sub

	set sub [menu $m.debugging]

	foreach opt {html log} {
		$sub add checkbutton \
			-label [set mc::Show[string toupper $opt 0 0]] \
			-command [namespace code [list ToggleTrace $opt]] \
			-variable [namespace current]::Options(debug:$opt) \
			;
	}

	$m add cascade -label $mc::Debugging -menu $sub
}


proc PopupMenu {} {
	variable Vars
	variable Path

	set m $Path.popup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	BuildMenu $m
	bind $m <<MenuUnpost>> [list $Vars(html) stimulate]
	bind $m <<MenuUnpost>> +::tooltip::hide
	tk_popup $m {*}[winfo pointerxy $Path]
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::RecentlyUsedHistory
	::options::writeList $chan [namespace current]::MostRecentHistory
	::options::writeItem $chan [namespace current]::RecentlyUsedTiebreaks
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 32x32 {

set go [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAABH5J
	REFUWMPtl0tsFVUcxn9nZtrelmJpoVrE8hJFCPGRiEZjcl0Y3fkKiYqPECFG44IEFzbBqDy0
	JCZujMawEHSDuqkufAQptJIgljcIgqXS0hbaAqWlnfuYmXP+Lmbuq1TkIrDRSU7uzZmZ//c7
	3/nOyRn4r1+qmIc7tn/iWGVVC1MnmzvmLfps4GoAWMU8PNS5Y4tdUbfDTw52tDbOXnLdAbp2
	NsVrTu1lFlWVVRMmbWhZXbepZc3UqusGEJx3KTv4I5V7W1jgVzPjpjueVRLs2/Zu7QPXBcBL
	ADoJ4mF3H2FGzznurLt3VkWsvHXbqtqVLWvrrWsK4KYB44ElYIEaPcuk9iPcUz6npK5m+lrE
	b25tnDXtmgFYgInEQwgBk6bk5FHmDmnm3bjg4VKnZH/rutueKBpARDDGXHoVJECMn3Ug25RB
	DfVR23mcuyrqp1RXVje1rpvz8c/rbo9d9j7g/tLQNvxH88K+Y7soscMboykYSYKbUrge9A/A
	a/H5xIbPRtQZehX+F0Ap9OSbOV1zA13Dpw5pbZ6LN7Qf/keAn5ZPkvhDj6OG+0ECMBoRg4gg
	WiMmQMRQduEsVioRvmSiEhlxycFIWQUj0+o57p1PjqYSK0B9Gm9o/3uATc8gT989h9LkhfH3
	SZFcZ3bkeb/mYhDBIqidSmeFRd/oYJNgLYs3tA+OmwEvAMTPhWtssykMX0EfYEvYsrkQlDKU
	nOnl1v5B5pZPfqrUtg60Ns6OjwsQaBClC8OVFaOw2TmRi+7beXBKQAlW0qW2t5cFbvKWicZt
	bnmvfk1r40wHwMk6oMM0Y8nF9itBlOT6rDFTYEV50NE0mCgLOurTgAmY4AbMR9udFYm3+pyy
	+4FHswC+BpE02KGKZEZWYG0EocaJUlY4EjfkAYQQohVaqzAf2qPAAT8AywERE/ZmhO1IMGN5
	vjtKhYpGQtHMyhAJQ2mTBRENrgi/jfi6zw3eF1GrCwE0UE5YLH/E2VBl5jTfAcnbB6RwKeoQ
	QowgltAfGA4OJLvctPfioo/YnqlQ4ACO5AFIYRgzwvkAKhJDCpegCd8TI/gBHDvncex06qtA
	y6uL1zOUP3lZgKl1MTwxaPGjIhLWk9A+UYJSivJyC8seE4Gx+4ERxMBoUrPnz9TIiQG9fOlG
	Noy3E2YBFj44ve2bfV33pZJpHCs0wgtCZ7wgXCUKeOXJGNVVmWBEQ87Mv4TiWgsnz3gc6vB2
	JdM8v3Qj7VflTPjmI8gbL8SYUmPnApkVD91KuIb9v6d1e7f5AHj75c/xL1XTKQbAsUE5UUbG
	BFFroas7YPcBv8dN8tLSL9h2WTWLOkKr6A0nByBAImHY2eZz5LhpciyWvf4lg5c9qKIOJAqU
	nXPACPT0ajZv9d2BQVbESlm//OvijmRFAUi07YoD6bTwa5vPjt1mXxCw+J3vOHolh9KiACaU
	wUiykkSPy+YWz5zolg8di5WrfsC70lNxUQAz6xg5vGdwYstBektsljRuZsu//TApCiCR4rFS
	h5kVZXy7+nsS/H9dhesv0bBGtUsVFSgAAAAASUVORK5CYII=
}]

set reset [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAE5UlEQVRYw+1XW2wUVRj+zpnZ
	abvb3Xbpdku7ba1t2lJaUCLVguKFm7cHeRNRY0zUSHxVw4MaIGC8QNqABA1gNChEYhAwBhrA
	0sCWtNKiFSLoFioWSm2h9LKzuzN7zu/DTGW3IJj08sSfnMzOOWfn++b/vvOfOcCdmKR44fjf
	/p1/ReZ+ezHqSOznkwHuqz3wUteVa6Eytxbc3XntcOKYOqHAH+/zAPg00+95zj03F5ucJprO
	ds6bFAK+D/fUANiRe3/p3eLBArQpAhQehnHlEiaUgK/2AIcRXaG5nSuznprlGCh0QTAGQFgT
	YvrEEciuqw9Q3NzuKS98TF08HX1pKgADAAFwAERAdIIIZNfVP6M4U7Z5amZk6RVTEVGlPaIl
	zDLGn0B2XX0qgPVawL885ZFyNjQlDRIAhGItM0Uk/8GWgIgYALAxgldBUXemVJdWoSoPJleS
	X3hUKNFBGG/XAkxF8eyHUTNzegsbA/hynulZ73i0Ms30u2892SblIMJcYRUfIkJw7RZLguwt
	x3OVlLTVS2cUPpGXpqqfneo+Mth/9d3eV+eEbgKcBc638tLCJfyBYsQUFTBHTXKMqnKGdTE1
	hkZbdEZAvPsCuG/joVyKmy2BsqxXOsrc+c0lrqlF5ZlLFSlafBsPVYwCfxSu1J8x794lNKcU
	ceU/LGRaTZqARLIHR8hYRohDhYiucpcV5HfPDKBLsxRJqZyCvKF874WWU+sAPO2rPaACWEkF
	2StYTYUCLRVk4n+lHQkkuCOBiAMASagwoo+HSwKQw7DXK6BrCoaKcqC1hxbdtes3Jdx1fj9V
	z1jIygMAs0jKm2AyogS33zguYgC3iY1MVREeVAQ5IPoBaQDctuVwxIAWDnPulRxGFBBxC3jU
	m9PIk4wR+rfOijRtE6oEBoCjO9SY3toO3i8h+4H4ZUC5LKCeaEP4bHPw/LOVJgavPsnqD66h
	/Y2CDwyDiEBEEDGCNHDbNuIJhC2i0rB/A1CcFbPa451nX8xLz0grd7kxlWKId7Qh3Lw3SrHo
	83p780X96D6pH/u+wVVyXwOFzi+A051B6R7A5FaJF7bWAiC7MWnrJK/3kbCyRMLq58Efoejt
	zVedJdP2Dnd3lvT09hT1docQ/eOnIA1dWda3c3NLYgb14/svuGY99AXrCBWzsFHJvH5IpoIE
	s0w5GjQCkC0NEwDFCYwxQFr3vKUhuRIWvLNZoUiYd61/07ztrvfGmpfhz99A1YvSRU4OpMmT
	zWkvt+umIzAQFC0GJgS4U4WyfdvYSrHvtfdKmcf7NaucVy2KKmEoGugWj+SRYWh76oDoIHiG
	HyyroImNef9/faUDjK9WC6a9JavmKxGnFwQGeZPvPRYZQsp3a9H3+Uf/4ipjJaCfOCL1Ew2H
	U4tKj6L7zIJ0t9cjU7yIC55sPgEopgnlXBP01qOrxv2jtG/b+w000HtPpOHL3a7TPyBT6mAG
	XS+/Bix5KBlSwTiGfjIY0U8Gd2k5OZd4z+/zXf6AZsIDKZm9OgQc55qgtzaOfwaSsvHVhi1m
	z5+zIwc3tWVdbkQGYqAYJW9EE30u6NvxyRnEonOGjn2zTm3bKn24hEBqBEjVJk6CGyT5tUXo
	p1sPanmBpnjXLwtLivPdw9H44EDD7g8m9WTUt2vrIUg57UzHuWV6b9fiOwfVxPgHhYw89PDr
	mYAAAAAASUVORK5CYII=
}]

} ;# namespace 32x32
} ;# namespace icon
} ;# namespace crosstable

# vi:set ts=3 sw=3:
