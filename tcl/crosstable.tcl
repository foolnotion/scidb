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

set TournamentTable		"Tournament Table"
set AverageRating			"Average Rating"
set Category				"Category"
set Games					"games"
set Game						"game"

set ScoringSystem			"Scoring System"
set Tiebreak				"Tie-break Rule"
set Settings				"Settings"
set RevertToStart			"Revert to initial values"
set UpdateDisplay			"Update display"

set Traditional			"Traditional"
set Bilbao					"Bilbao"

set None						"None"
set Buchholz				"Buchholz"
set MedianBuchholz		"Median-Buchholz"
set ModifiedMedianBuchholz "Mod. Median Buchholz"
set RefinedBuchholz		"Refined-Buchholz"
set SonnebornBerger		"Sonneborn-Berger"
set Progressive			"Progressive Score"
set KoyaSystem				"Koya-System"
set GamesWon				"Number of Games Won"
set GamesWonWithBlack	"Number of Games Won with Black"
set ParticularResult		"Particular Result"
set TraditionalScoring	"Traditional Scoring"

set Crosstable				"Crosstable"
set Scheveningen			"Scheveningen"
set Swiss					"Swiss System"
set Match					"Match"
set Knockout				"Knockout"
set RankingList			"Ranking List"

set Order					"Order"
set Type						"Table Type"
set Score					"Score"
set Alphabetical			"Alphabetical"
set Rating					"Rating"
set Federation				"Federation"

set Debugging				"Debugging"
set Display					"Display"
set Style					"Style"
set Spacing					"Spacing"
set Padding					"Padding"
set ShowLog					"Show Log"
set ShowHtml				"Show HTML"
set ShowRating				"Show Rating"
set ShowPerformance		"Show Performance"
set ShowTiebreak			"Show Tiebreak"
set ShowOpponent			"Show Opponent (as Tooltip)"
set KnockoutStyle			"Knockout Table Style"
set Pyramid					"Pyramid"
set Triangle				"Triangle"

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
	crosstable		"crosstable.eXt"
	scheveningen	"scheveningen.eXt"
	swiss				"swiss.eXt"
	match				"match.eXt"
	knockout			"knockout.eXt"
	rankingList		"rankingList.eXt"
}

set TypeList {
	crosstable
	scheveningen
	swiss
	match
	knockout
	rankingList
}

set ScoringList {
	traditional
	bilbao
}

set TiebreakList {
	none
	sonnebornBerger
	buchholz
	medianBuchholz
	modifiedMedianBuchholz
	refinedBuchholz
	progressive
	koyaSystem
	gamesWon
	gamesWonWithBlack
	particularResult
	traditionalScoring
}

set OrderList {
	score
	alphabetical
	rating
	federation
}

variable RecentlyUsedHistory {}
variable MostRecentHistory {}

array set RecentlyUsedTiebreaks {
	crosstable		sonnebornBerger
	swiss				buchholz
	scheveningen	{}
	match				{}
	knockout			{}
	rankingList		{}
}

array set RecentlyUsedScoring {
	crosstable		traditional
	swiss				traditional
	scheveningen	traditional
	match				traditional
	knockout			traditional
	rankingList		traditional
}

array set Defaults {
	base					{}
	index					-1
	number				-1
	frozen				0
	scoring				traditional
	tiebreaks			{}
	bestMode				rankingList
	order					score
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


proc open {parent base index view source} {
	variable TiebreakList
	variable ScoringList
	variable OrderList
	variable TypeList
	variable Vars
	variable Options
	variable Geometry
	variable Path

	set dlg $Path

	if {$source eq "game"} {
		set number [::scidb::db::get gameNumber $base $index $view]
		set info [::scidb::db::fetch eventInfo $number $base]
	} else { ;# $source eq "event"
		set info [::scidb::db::get eventInfo $index $view $base]
		set number [::scidb::db::get eventIndex $index $view $base]
	}

	lassign $info title type date mode timeMode country site
	set key [list $base $site $title $type $date $mode $timeMode]

	if {$Vars(base) eq $base && $Vars(key) == $key} {
		raise $dlg
		focus $dlg
		return
	}

	set Vars(closed) 0
	if {[winfo exists $dlg]} { Destroy $dlg $dlg 0 }
	set Vars(closed) 0

	set top $dlg.top
	set canv $top.canv
	set html $canv.html

	set Vars(html) $html
	set Vars(base) $base
	set Vars(view) $view
	set Vars(index) $index
	set Vars(info) $info
	set Vars(key) $key
	set Vars(warning) {}
	set Vars(lastMode) ""
	set Vars(prevMode) ""
	set Vars(prevTiebreaks) ""
	set Vars(prevScoring) ""
	set Vars(tooltip) ""
	set Vars(viewId) [::scidb::view::new $base slave slave slave slave]
	set Vars(subscribe) [list [namespace current]::Close $base $dlg]

	if {$source eq "game"} { set search gameevent } else { set search event }
	::scidb::view::search $base $Vars(viewId) null none [list $search $number]

	if {[winfo exists $dlg]} {
		set Vars(tableId) [::scidb::crosstable::make $base $Vars(viewId)]
		Update 1
		raise $dlg
		focus $dlg
		return
	}

	::scidb::view::subscribe {*}$Vars(subscribe)

	set Vars(tiebreakList) {}
	set Vars(orderList) {}
	set Vars(typeList) {}
	set Vars(scoringList) {}

	toplevel $dlg -class Scidb
	bind $dlg <Destroy> [namespace code [list Destroy $dlg %W 1]]
	wm withdraw $dlg

	ttk::frame $top
	ttk::frame $canv
	::html $html \
		-nodehandler [namespace current]::NodeHandler \
		-imagecmd [namespace code GetImage] \
		-delay 10 \
		;
	bind [winfo parent [$html drawable]] <ButtonPress-3> [namespace code PopupMenu]

	set tb [::toolbar::toolbar $dlg \
				-id settings \
				-allow {top bottom} \
				-titlevar [namespace current]::mc::Settings \
				-padx 4 \
				-pady 2 \
			]
	foreach entry $TiebreakList { lappend Vars(tiebreakList) [set mc::[string toupper $entry 0 0]] }
	foreach entry $ScoringList { lappend Vars(scoringList) [set mc::[string toupper $entry 0 0]] }
	foreach entry $OrderList { lappend Vars(orderList) [set mc::[string toupper $entry 0 0]] }
	foreach entry $TypeList { lappend Vars(typeList) [set mc::[string toupper $entry 0 0]] }
	set Vars(value:order) [lindex $Vars(orderList) 0]
	set Vars(value:type) [lindex $Vars(typeList) 0]
	set Vars(value:scoring) [lindex $Vars(scoringList) 0]

	set f1 [::toolbar::add $tb frame]
	set f2 [::toolbar::add $tb frame]
	set f3 [::toolbar::add $tb frame]

	tk::label $f1.label_type -textvar [namespace current]::mc::Type
	::ttk::combobox  $f1.choose_type \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-values $Vars(typeList) \
		-textvar [namespace current]::Vars(value:type) \
		-width 16 \
		;
	set Vars(widget:type) $f1.choose_type

	tk::label $f1.label_order -textvar [namespace current]::mc::Order
	::ttk::combobox $f1.choose_order \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-values $Vars(orderList) \
		-textvar [namespace current]::Vars(value:order) \
		-width 12 \
		;
	set Vars(widget:order) $f1.choose_order

	tk::label $f1.scoring_label -textvar [namespace current]::mc::ScoringSystem
	set Vars(widget:scoring) $f1.choose_scoring
	::ttk::combobox $Vars(widget:scoring) \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-values $Vars(scoringList) \
		-textvar [namespace current]::Vars(value:scoring) \
		-width 12 \
		;

	::toolbar::add $tb separator
	::toolbar::add $tb button \
		-image $icon::32x32::go \
		-command [namespace code Refresh] \
		-tooltipvar [namespace current]::mc::UpdateDisplay \
		-padx 4 \
		;
	::toolbar::add $tb button \
		-image $icon::32x32::reset \
		-command [namespace code Reset] \
		-tooltipvar [namespace current]::mc::RevertToStart \
		-padx 4 \
		;

	grid $f1.label_type     -row 1 -column 1 -sticky w
	grid $f1.choose_type    -row 1 -column 3 -sticky ew
	grid $f1.label_order    -row 3 -column 1 -sticky w
	grid $f1.choose_order   -row 3 -column 3 -sticky ew
	grid $f1.scoring_label  -row 5 -column 1 -sticky w
	grid $f1.choose_scoring -row 5 -column 3 -sticky ew

	foreach i {1 2 3 4 5 6} {
		set Vars(label:tiebreak$i) "$i. $mc::Tiebreak"
		set Vars(value:tiebreak$i) [lindex $Vars(tiebreakList) 0]
		set f [set f[expr {($i - 1)/3 + 2}]]
		set r [expr {($i*2 - 1)%6}]
		tk::label $f.label$i -textvar [namespace current]::Vars(label:tiebreak$i)
		set Vars(widget:tiebreak$i) $f.choose$i
		::ttk::combobox $Vars(widget:tiebreak$i) \
			-takefocus 0 \
			-exportselection 0 \
			-state readonly  \
			-values $Vars(tiebreakList) \
			-textvar [namespace current]::Vars(value:tiebreak$i) \
			-width 23 \
			-height [llength $TiebreakList] \
			;
		grid $f.label$i  -row $r -column 1 -sticky w
		grid $f.choose$i -row $r -column 3 -sticky ew
	}

	foreach i {1 2 3} {
		set f [set f$i]
		grid columnconfigure $f 2 -minsize $::theme::padding
		grid rowconfigure $f {0 2 4 6} -minsize 3
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

	bind $dlg <<LanguageChanged>> [namespace code [list LanguageChanged $dlg %W]]

	if {$source eq "event"} {
		::widget::dialogButtons $dlg {close previous next} close
		$dlg.previous configure -command [namespace code [list NextEvent -1]]
		$dlg.next configure -command [namespace code [list NextEvent +1]]
	} else {
		::widget::dialogButtons $dlg close close
	}
	$dlg.close configure -command [list destroy $dlg]

	::update
	set Vars(tableId) [::scidb::crosstable::make $base $Vars(viewId)]
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


proc Close {dlg base {view {}}} {
	variable Vars

	if {!$Vars(closed) && $base eq $Vars(base) && ([llength $view] == 0 || $view == $Vars(viewId))} {
		set Vars(closed) 1
		destroy $dlg
	}
}


proc RecordGeometry {dlg} {
	set [namespace current]::Geometry [lindex [split [wm geometry $dlg] +] 0]
}


proc NextEvent {step} {
	variable Vars

	::scidb::crosstable::release $Vars(tableId) $Vars(viewId)
	incr Vars(index) $step
	set number [::scidb::db::get eventIndex $Vars(index) $Vars(view) $Vars(base)]
	::scidb::view::search $Vars(base) $Vars(viewId) null none [list event $number]
	set Vars(info) [::scidb::db::get eventInfo $Vars(index) $Vars(viewId) $Vars(base)]
	set Vars(tableId) [::scidb::crosstable::make $Vars(base) $Vars(viewId)]
	set Vars(warning) 0
	set Vars(lastMode) ""
	set Vars(prevMode) ""
	set Vars(prevTiebreaks) ""
	set Vars(prevScoring) ""
	Update 1
}


proc LanguageChanged {dlg w} {
	variable Vars
	variable TiebreakList
	variable ScoringList
	variable OrderList
	variable TypeList

	if {$dlg ne $w} { return }

	SetTitle $dlg

	set parent $Vars(widget:tiebreak1)
	foreach entry $TiebreakList { lappend tiebreakList [set mc::[string toupper $entry 0 0]] }
	foreach i {1 2 3 4 5 6} {
		set n [lsearch $Vars(tiebreakList) $Vars(value:tiebreak$i)]
		set Vars(label:tiebreak$i) "$i. $mc::Tiebreak"
		$Vars(widget:tiebreak$i) configure -values $tiebreakList
		set clone [::toolbar::lookupClone $parent $Vars(widget:tiebreak$i)]
		if {[llength $clone]} { $clone configure -values $tiebreakList }
		if {$n >= 0} { set Vars(value:tiebreak$i) [lindex $tiebreakList $n] }
	}
	set Vars(tiebreakList) $tiebreakList

	set n [lsearch $Vars(scoringList) $Vars(value:scoring)]
	foreach entry $ScoringList { lappend scoringList [set mc::[string toupper $entry 0 0]] }
	$Vars(widget:scoring) configure -values $scoringList
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:scoring)] $Vars(widget:scoring)]
	if {[llength $clone]} { $clone configure -values $scoringList }
	if {$n >= 0} { set Vars(value:scoring) [lindex $scoringList $n] }
	set Vars(scoringList) $scoringList

	set n [lsearch $Vars(orderList) $Vars(value:order)]
	foreach entry $OrderList { lappend orderList [set mc::[string toupper $entry 0 0]] }
	$Vars(widget:order) configure -values $orderList
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:order)] $Vars(widget:order)]
	if {[llength $clone]} { $clone configure -values $orderList }
	if {$n >= 0} { set Vars(value:order) [lindex $orderList $n] }
	set Vars(orderList) $orderList

	set n [lsearch $Vars(typeList) $Vars(value:type)]
	foreach entry $TypeList { lappend typeList [set mc::[string toupper $entry 0 0]] }
	$Vars(widget:type) configure -values $typeList
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:type)] $Vars(widget:type)]
	if {[llength $clone]} { $clone configure -values $typeList }
	if {$n >= 0} { set Vars(value:type) [lindex $typeList $n] }
	set Vars(typeList) $typeList

	Update
}


proc SetTitle {dlg} {
	variable Vars
	wm title $dlg "$::scidb::app: $mc::TournamentTable$Vars(eventName)"
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

	foreach attr [array names Vars reset:*] {
		set Vars([string range $attr 6 end]) $Vars($attr)
	}
	Refresh
}


proc Refresh {} {
	variable Vars
	variable TypeList
	variable OrderList
	variable TiebreakList
	variable ScoringList

	set Vars(prevMode) $Vars(bestMode)
	set Vars(prevTiebreaks) $Vars(tiebreaks)
	set Vars(prevScoring) $Vars(scoring)
	set Vars(order) [lindex $OrderList [lsearch $Vars(orderList) $Vars(value:order)]]
	set Vars(bestMode) [lindex $TypeList [lsearch $Vars(typeList) $Vars(value:type)]]
	set Vars(scoring) [lindex $ScoringList [lsearch $Vars(scoringList) $Vars(value:scoring)]]
	set Vars(tiebreaks) {}
	for {set i 1} {$i <= 6} {incr i} {
		set n [lsearch $Vars(tiebreakList) $Vars(value:tiebreak$i)]
		if {$n > 0} { lappend Vars(tiebreaks) [lindex $TiebreakList $n] }
	}

	Update
	UpdateHistory
}


proc UpdateHistory {} {
	variable RecentlyUsedTiebreaks
	variable RecentlyUsedScoring
	variable RecentlyUsedHistory
	variable MostRecentHistory
	variable Vars

	set RecentlyUsedTiebreaks($Vars(bestMode)) $Vars(tiebreaks)
	set RecentlyUsedScoring($Vars(bestMode)) $Vars(scoring)

	if {	$Vars(prevMode) ne $Vars(bestMode)
		|| $Vars(prevScoring) ne $Vars(scoring)
		|| $Vars(prevTiebreaks) ne $Vars(tiebreaks)} {
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

		set entry [list $Vars(bestMode) $Vars(tiebreaks) $Vars(scoring)]
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
	variable ScoringList

	set w $Vars(html)
	set base $Vars(base)
	set index $Vars(index)
	set viewId $Vars(viewId)

	array unset ImageCache

	if {$setup} {
		variable TiebreakList
		variable OrderList
		variable TypeList
		variable RecentlyUsedHistory
		variable RecentlyUsedScoring
		variable RecentlyUsedTiebreaks
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
			lassign [lindex $RecentlyUsedHistory $i 1] bestMode tiebreaks scoring
		} else {
			set i [lsearch -index 0 $MostRecentHistory $Vars(event)]

			if {$i >= 0} {
				lassign [lindex $MostRecentHistory $i 1] bestMode tiebreaks scoring
			} else {
				set bestMode [string tolower [::scidb::crosstable::get bestMode $Vars(tableId) $viewId] 0 0]
				set tiebreaks $RecentlyUsedTiebreaks($bestMode)
				set scoring $RecentlyUsedScoring($bestMode)
			}
		}

		set i 0
		foreach tb $tiebreaks {
			set Vars(value:tiebreak[incr i]) [lindex $Vars(tiebreakList) [lsearch $TiebreakList $tb]]
		}
		for {incr i} {$i <= 6} {incr i} {
			set Vars(value:tiebreak$i) [lindex $Vars(tiebreakList) 0]
		}
		set Vars(value:scoring) [lindex $Vars(scoringList) [lsearch $ScoringList $scoring]]
		set Vars(value:type) [lindex $Vars(typeList) [lsearch $TypeList $bestMode]]
		set Vars(bestMode) $bestMode
		set Vars(tiebreaks) $tiebreaks
		set Vars(scoring) $scoring
		foreach attr {	tiebreaks bestMode value:type value:tiebreak1
							value:tiebreak2 value:tiebreak3 value:tiebreak4} {
			set Vars(reset:$attr) $Vars($attr)
		}
		SetTitle [winfo toplevel $w]
		ConfigureButtons
	}

	set font [$w font]
	array set metrics [font metrics $font]

	set linespace $metrics(-linespace)
	set charWidth [font measure $font "0"]
	set order $Vars(order)
	set scoring $Vars(scoring)
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

	if {$Vars(bestMode) eq "crosstable"} {
		append preamble "\\let\\TableLimit\\$Defaults(crosstableLimit)"
		set id [list $base $Vars(viewId)]

		if {$Vars(warning) ne $id} {
			set playerCount [::scidb::crosstable::get playerCount $Vars(tableId) $viewId]

			if {$playerCount > $Defaults(crosstableLimit)} {
				set detail ""
				if {[string length $Vars(prevMode)] == 0} {
					set cancel [::mc::stripAmpersand $::dialog::mc::Cancel]
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
						set Vars(bestMode) [::scidb::crosstable::get bestMode $Vars(tableId) $viewId]
						if {$Vars(bestMode) eq "crosstable"} { set Vars(bestMode) rankingList }
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
		$Vars(tableId) $viewId $searchDir $script $bestMode $order \
		$knockoutOrder $scoring $tiebreaks $preamble \
	]
	lassign $result html Vars(output:log)

	set i [string first "%date%" $html]
	while {$i >= 0} {
		set e [expr {$i + 15}]
		set date [string range $html [expr {$i + 6}] $e]
		set html [string replace $html $i $e [::locale::formatDate $date]]
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


proc Destroy {dlg w unsubscribe} {
	if {$w ne $dlg} { return }

	variable Vars
	variable Defaults
	variable ImageCache

	if {$unsubscribe} { ::scidb::view::unsubscribe {*}$Vars(subscribe) }
	::scidb::crosstable::release $Vars(tableId) $Vars(viewId)
	if {!$Vars(closed)} {
		set Vars(closed) 1
		::scidb::view::close $Vars(base) $Vars(viewId)
	}
	array unset ImageCache
	array set Vars [array get Defaults]
}


proc Open {which gameIndex} {
	variable Vars

	Tooltip hide

	set base $Vars(base)
	set path $Vars(html)

	if {$which eq "pgn"} {
		::widget::busyOperation ::game::new $path $base $gameIndex
	} else {
		set viewId $Vars(viewId)
		set index [::scidb::view::map game $base $viewId $gameIndex]
		set info [::scidb::db::get gameInfo $index $viewId $base]
		set Vars(${which}Id) \
			[::widget::busyOperation ::${which}::load $path $base $info $viewId $index $Vars(${which}Id)]
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
			Tooltip [::scidb::crosstable::get playerName $Vars(tableId) $Vars(viewId) $rank]
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
			$node hilite $Colors(highlighted)
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
					$node hilite none
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
		set color none
		catch { if {$Highlighted($node) > 0} { set color $Colors(highlighted) } }
		$node hilite $color
	}
	array unset Marks

	set curr [lindex $idList end]
	foreach id [split $idList :] {
		if {$id ni $oldIdList} {
			catch {
				set node $Nodes($id)
				set Marks($node) $id
				$node hilite $Colors(mark)
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
			set info [::scidb::crosstable::get playerInfo $Vars(tableId) $Vars(viewId) $rank]
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
	catch { wm attributes $m -type popup_menu }

	$m add command \
		-compound left \
		-image $::icon::16x16::browse \
		-label $::browser::mc::BrowseGame \
		-command [namespace code [list Open browser $gameIndex]] \
		;
	$m add command \
		-compound left \
		-image $::icon::16x16::overview \
		-label $::overview::mc::Overview \
		-command [namespace code [list Open overview $gameIndex]] \
		;
	$m add command \
		-compound left \
		-image $::icon::16x16::document \
		-label " $::browser::mc::LoadGame" \
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

	if {$Vars(bestMode) eq "knockout"} { set state disabled } else { set state normal }
	foreach opt {rating performance tiebreak} {
		$sub add checkbutton \
			-label [set mc::Show[string toupper $opt 0 0]] \
			-command [namespace code Update] \
			-variable [namespace current]::Options(show:$opt) \
			-state $state \
			;
	}

	if {$Vars(bestMode) eq "swiss"} { set state normal } else { set state disabled }
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

	if {$Vars(bestMode) eq "knockout"} { set state normal } else { set state disabled }

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
	catch { wm attributes $m -type popup_menu }
	BuildMenu $m
	bind $m <<MenuUnpost>> [list $Vars(html) stimulate]
	bind $m <<MenuUnpost>> +::tooltip::hide
	tk_popup $m {*}[winfo pointerxy $Path]
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::RecentlyUsedHistory
	::options::writeList $chan [namespace current]::MostRecentHistory
	::options::writeItem $chan [namespace current]::RecentlyUsedTiebreaks
	::options::writeItem $chan [namespace current]::RecentlyUsedScoring
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 32x32 {

#set go [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAACAVBMVEUAAAACDw8LTlECDw8C
#	Dw8RbHECDw8CDw8CDw8CDw8CDw8CDw8CDw8NXmMCDw8CDw8CDw8CDw8CDw8OZmsCDw8CDw8D
#	FxgCDw8CDw8CDw8CDw8CDw8CDw8CDw8CDw8CDw8PaG0CDw8CDw8CDw8CDw8CDw8CDw8CDw8D
#	FxgOYmYCDw8GKiwCDw8CDw8CDw8CDw8GLzECDw8CDw8OYmYKSk0IODsOZWkOYmYNW18KRUkO
#	ZmsOY2gOZmsOZmsOZmsMVFcOZmsOYmYOZWkNXmMOZmsOZmsOZWkOYmYOZmsOZmsOZmsOZmsR
#	bHERbHEPam8RbHEOZmsWcXYXcncjfIEkfoIOZmsfeX4kfoIxiI01i5A9kZUOZmsUb3Qwh4wZ
#	dHlDlZlVoaVBlJhLm59orrJRn6NYpKhfqKwOZWkeeH0feX4gen8he4AjfIEkfoIlf4MmgIQo
#	gYUpgoYqg4cshIgthYouhoswh4wxiI0ziY41i5A3jJE4jpI6j5M7kJQ9kZVAk5dBlJhDlZlE
#	lptGl5xImJ1Jmp5Lm59MnKBOnaFQnqJToKRVoaVYpKhapalcpqpfqKxnrbForrJssLRusbVw
#	s7Z0tbh2trp4t7t8ur1+u76AvL+CvcCEvsKGwMOIwcSKwsWOxMeQxsiTx8qVyMuXycyZys2b
#	zM6ezc+gztGk0dOm0tRLVt61AAAAZ3RSTlMAAQECAwMEBQYHCAkKCgsMDQ4PDxARERITFBUW
#	FxgaGxwdHh8gIiMkJCUmJikqLC4uMjY5P0BFUV1gYGxxgIiKkpuytLW/yNbY4uft7vL09fb2
#	9vb29/f39/f3+Pj5+vr6+/v9/v7+GgnqVwAAAaVJREFUOMvNkt1qU0EUhdfaM2krJShFIjQW
#	RVAQBZEW9Eapr+BL+HA+gILQC2mlFRFRREFapBjpOfmpYAM987O3FzlJmwi51X23Nh+z1qwZ
#	4N+Pm5bPfGcGkBl9/ZHMB56ubTbnWWzcuNlbSb/mnKDlZvvu+rmFnwW0/8BeLr6ZLDgKX9Ty
#	yuMjtaXlF72dOA08FAIgIT/MdOnSq977/rTFIUkBCDPTYXiy679/OQ9YpsAIQoFs6ed975tv
#	z665cXUAgxnNYDmE0+rk2q3+5cMzYPUYAGnI1fDkNMRYDXCvbB9MLFJ0ApjmDKOoKMzU+XEG
#	j/SbQkeSAFWUaC9v9bZrwDUAkEIKaVBR+rWv3eKd1oB3AEnSEaSJykL7Q1l889lGAB1wR0AS
#	5IGqXGjtlcURRXKdwfBpXP26mFxsvu53hoCNi9L8fLHR8A0nvA2yxd2iEzWp5hoIkoQw846A
#	a30sumVKIcY0qboy1QVNzjHI6k63W2qKIYY8AazKOTnvRaBbg85xjjmmMPWaKQXvxHFlu/gc
#	NOeU/vpROQMU7O+ZjuL/R/MHYAPLcEBkVE0AAAAASUVORK5CYII=
#}]

set go [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAErUlEQVRYw72XXYhVVRTHf2vt
	fc6dD8eSDKKnxJfx4yWE6sFSNJUYC32YwhgzQ3oJ+iCJMFMqERKJgiCLIPwqTJhEc0QcBx0s
	wnqoUGcooZjUUhxMZSznztm7h3POzDn3nptzxdqwOff897p7r4//WnsdAexdb+zfcy2StrID
	56kaAoAHBH+TuAoECk3G7/9jfdsSYCSVb5m4rsv/X2Piui4PtKSHW6Ch7JK3Y4+CNoBoxh4P
	DLPm0kdsnPQsECY21oF7D+5vmL2P5KwG4GqqgPisn4xWKOBAlNAqWAUvgNaHexkLjM9EKVFg
	NFKvD76HaoCIjMVTPEYcDTLEhsF3ibzivdSFOwfOlXmrii2JAiRg+9wpSOKInJCBzp5+2ue1
	MhLVjztP5tgCBUZD4Dzee1xGARHBi4CL8A58IlMX7jxIHAZfkWU2+5JaLjkFYjx9qiQJVgeO
	ZKNepECyGKqgInkFAGMgUKFkwCJ4pC7cqYzVFylQIMU6e05gNC8lAkYVa5TOnj4i5/C+XtwT
	OXj1sZlVjrBZWjyxIBaQAhJ+fvgUjz88vYps48F9hoS+MASZVe+StM14wEtmzTFq6bhxl5SI
	Ag2qSai+OgQSw0bAZcg2blx9tVuLFAhNvINUXCzWgLFCaDNsrwN3SLXvi7Jg16GTqIJUUMUY
	JVBlV3c/UeTqxj0e5+DFthnFWZBq17FoBlR4K7VoZ3cfHQumxaQaF95Px8JWXGUl/DcOxETK
	S4hI7F4fWxElMjfC8R5NlHGQy5Ic73KultozJdV4cSNKEzD7NWHVB5NHLZfcTVuhQGihFEh+
	WggVrBVChVIqk+CBtTQoNAXQFApNATQqhDZEgYYSTG0Z5LmP744P1FJtEu48dBIkT0JJSWWU
	nT0pqeLQBCagudTCF18P4r2ObqQCExvvZO+3oApPPriabV9tZkv3clRfrk3ClQtnVGWLJELb
	evp4et40RhJxBQLgmQ/n0He+t6rEphU1ciBmAotntXPohx1MDS/yfa1S7AqaUpHYisjFZIqS
	iucVAoEfz/TS+dL7XCl3pQ1W7v/OO9Tfwcnfd/PIrOWYcDuT32RL9zragSiXBVagkqwi8baa
	PNOKZ2Qsq4aGL3HsdFfhresBZB8awokL21l070rEfrLUbGTPwTUszd19VqCk+Rkmi0HSLISJ
	jM2U76HoXByPgikhSABiwRv4afBT7ps2E7EsBhpzJNx6+BQJC3OxVBWsUXYc6cc5H3NALM2l
	yajANc5iSjV7jvgyIu53nbnO8dMnGL7CUSDI9QMr5k+n1vjsaD8dc1ur8LcPwrAO0NBc3W94
	H3MqKsehsAYGzkJPD0eObuIFoGwBAqPcaCyb01qIr3qonXe27qZoC+fhehlWLIvJMDAAe4+3
	8d2m/auBc8BfFqDZ+Ku3rT/QUo5c7U+z9I7PlGijlpJ9nsC8gjqTs9+jjPgJ3B9OJWiE0z/D
	l9/M57eRDZdh/wXgEhAJcDswBZhUu3W86REs2cyBB2ZDbzcXutbyFHAe+BX4M60DQ8AvwFlu
	/ZhkDBzr5UrXWpYmZ1xOzizqUW+9AsA9iaFngItAufrL+78bIdCU/B6qPBzgH0AljNbciY+A
	AAAAAElFTkSuQmCC
}]

set reset [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAABL5J
	REFUWMPtl22IFVUYx//Pmbl79+5dZcU0E4tCyyzTYjXNLTHDUNNdX7JIwgwjUjI/RZEgFpUS
	BFEfKiVZ3wI3lLTMt60kJMoF094k1EgtN2xX77o7d2bunPM8fZi5d6fr7t1V+xJ54DBn7j3n
	/H/P2xwOcLX93xsBQH1tWor/kAtO6sn98HraYP3MimlC9NnCHQ5dDoCdH9S+uBakLEBZ2PHq
	At8f0C8JnC8JsLE2vSzZp2qVl3Uu2wMqZjMyTVsB4R4XNcyDtaGuYk3f625YNXnxGykrkbxs
	ALtTnyFG9wjQMG9Apedntw8ZUX3PqBmLUpZtX1EOqE59hrCGsOl28qY5qSG+nz00vGbafaNn
	LEq5Jw6CA+/fAQg9EADctQfqZ1VUG7GP3PXQE0OH3j010X70SwSZMxBmAKIb5iF1RSEQNhAd
	dOmB+tqK2rKyig/Hz3m6orJqILX/uAec80BgkGgIs50N0m0b6kR3ZlRkoV0GUha076W6qpTO
	ALKBmNxFAOtnp5+vqOz/8viHl6Rs46Hjp0YIaxAEEAYphelLV0NEEsKcgHDoTWEIMzjwASLs
	fn9lbzyQAyKAcq3tjTPT6/pde9Oj1XVPpfTZ43Caj4IAEASEUKjtwLowcdmERkR5JEaDtQbr
	AP0mL+5FFUQAwhoQKiPmfYNHjhlx+8TZ5e6vBxGcOwVFAEhC6yMIiiwGG0AMWAyINZgNlGgI
	NBS4FzkgBhx5QAg0fNyUkTeOmpDo+GE3jNMKBYAUQJQXjwAgkdcYwgaKDUQMSDTAGopNydLu
	BNABRPsQ1pg44zGkr78tkfm2Aew7oeUWARICkDCgs5CcA9EuoHMQDiIhAsgCyAIpGwQrnN8T
	gMlmELSeBvsOOlpOIzVoGMhOAk4rIBrCAQz7kCALaBcEhlIAUXighOEBIAKBBrOGGB9gACbX
	ixwAwIEHzrk49M0BXHPypDe6Zmp59mgLguZjsBSgFCAK4ZhC8fyTKB/KsARJok9KIWw9ngXx
	I1JyLc2nPm1q3OamRkxG+paaglhBOA9S9LRigCoG2p2e6gZMGv/Ac3+2tqz+emeDSwNvReWo
	6SClChCqBERcXP3z01NWrNntSdLui71kp/vua5NwRu/a9va4B6am+o55BN7320CcK3ik8sHl
	F4egqHNnBKxIM9cjQGBEAVDL92f3LB2rH9d7Pqkfc++kykHjFpD33RZQ0F4Q/ui9ty7l7Ml3
	LgkQb+805Y7U3sxzhb/YcEf12P7Dxi9M+Ie3gJyzEYQEK77yZ588bzKRdUH0zBW9l66CeLMU
	SUTJAMyOY/q3Uw7mPoumtR0X2obeWTM/aX7e3mkaUV5IR93E1ud7fM/SAOkyym9USKPDZ/Rf
	L7Xp+a/oX97MZrM1E6bMKhcBCJCEBReAGwnrIhgd+930pgpQlVK6yJU+AO+sg7Zlu9xnjp34
	fdPnHzd4vgn5kjblAVwAXjTfLwpFaYBBdcsL4+ED7VxsEy/qLgDXB5xl+7IrjzefW7F38xqX
	hcoqk+QAyBZBeDGYPEDXObB3YzyTKVmVyXgxN9pRCVnxTH6h0f3g9ftxYnAftVU7uUwkVsib
	mNu55L3gEu8RFIFQ0XopSjK5eu36T7S/AR5ziJulvhGVAAAAAElFTkSuQmCC
}]

} ;# namespace 32x32
} ;# namespace icon
} ;# namespace crosstable

# vi:set ts=3 sw=3:
