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
# Copyright: (C) 2011-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source crosstable-dialog

namespace eval crosstable {
namespace eval mc {

set TournamentTable			"Tournament Table"
set AverageRating				"Average Rating"
set Category					"Category"
set Games						"games"
set Game							"game"

set ScoringSystem				"Scoring System"
set Tiebreak					"Tie-break Rule"
set Settings					"Settings"
set RevertToStart				"Revert to initial values"
set UpdateDisplay				"Update display"
set SaveAsHTML					"Save as HTML file"

set Traditional				"Traditional"
set Bilbao						"Bilbao"

set None							"None"
set Buchholz					"Buchholz"
set MedianBuchholz			"Median-Buchholz"
set ModifiedMedianBuchholz "Mod. Median Buchholz"
set RefinedBuchholz			"Refined-Buchholz"
set SonnebornBerger			"Sonneborn-Berger"
set Progressive				"Progressive Score"
set KoyaSystem					"Koya-System"
set GamesWon					"Number of Games Won"
set GamesWonWithBlack		"Number of Games Won with Black"
set ParticularResult			"Particular Result"
set TraditionalScoring		"Traditional Scoring"

set Crosstable					"Crosstable"
set Scheveningen				"Scheveningen"
set Swiss						"Swiss System"
set Match						"Match"
set Knockout					"Knockout"
set RankingList				"Ranking List"

set Order						"Order"
set Type							"Table Type"
set Score						"Score"
set Alphabetical				"Alphabetical"
set Rating						"Rating"
set Federation					"Federation"

set Debugging					"Debugging"
set Display						"Display"
set Style						"Style"
set Spacing						"Spacing"
set Padding						"Padding"
set ShowLog						"Show Log"
set ShowHtml					"Show HTML"
set ShowRating					"Show Rating"
set ShowPerformance			"Show Performance"
set ShowWinDrawLoss			"Show Win/Draw/Loss"
set ShowTiebreak				"Show Tiebreak"
set ShowOpponent				"Show Opponent (as Tooltip)"
set KnockoutStyle				"Knockout Table Style"
set Pyramid						"Pyramid"
set Triangle					"Triangle"

set CrosstableLimit			"The crosstable limit of %d players will be exceeded."
set CrosstableLimitDetail	"'%s' is choosing another table mode."
set CannotOverwriteFile		"Cannot overwrite file '%s': permission denied."
set CannotCreateFile			"Cannot create file '%s': permission denied."

} ;# namespace mc

namespace import ::tcl::mathfunc::max

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

array set ListEntries {
	type		{ crosstable scheveningen swiss match knockout rankingList }
	scoring	{ traditional bilbao }
	tiebreak	{ none sonnebornBerger buchholz medianBuchholz modifiedMedianBuchholz refinedBuchholz
					progressive koyaSystem gamesWon gamesWonWithBlack particularResult traditionalScoring }
	order		{ score alphabetical rating federation }
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
	show:winDrawLoss	0
	show:performance	1
	show:tiebreak		1
	show:opponent		1
}

array set List {}
array set Key {}
array set Locked {}

variable Geometry "1024x768"
variable Counter 0
variable Reuse ""


proc open {parent base variant index view source} {
	variable ListEntries
	variable Options
	variable Defaults
	variable Geometry
	variable Counter
	variable Reuse
	variable Key

	if {$source eq "game"} {
		set number [::scidb::db::get gameNumber $base $variant $index $view]
		set info [::scidb::db::fetch eventInfo $number $base $variant -card]
	} else { ;# $source eq "event"
		set info [::scidb::db::get eventInfo $index $view $base $variant -card]
		set number [::scidb::db::get eventIndex $index $view $base $variant]
	}

	lassign $info title type date mode timeMode country site
	set key "key:$base:$variant:$site:$title:$type:$date:$mode:$timeMode"

	if {[info exists Key($key)]} {
		set dlg $Key($key)
		variable ${dlg}::Vars
		if {$Vars(open)} {
			::widget::dialogRaise $dlg
		} else {
			set Vars(open) 1
			::scidb::crosstable::release $Vars(tableId) $Vars(viewId)
			set Vars(tableId) [::scidb::crosstable::make $base $variant $Vars(viewId)]
			UpdateContent $dlg 1
		}
		return
	}

	if {[string length $Reuse]} {
		set dlg $Reuse
	} else {
		set dlg .application.crosstable_[incr Counter]
		set Reuse $dlg
	}

	namespace eval [namespace current]::$dlg {}
	variable ${dlg}::Vars
	array set Vars [array get Defaults]

	set top $dlg.top
	set canv $top.canv
	set html $canv.html

	set Vars(open) 1
	set Vars(html) $html
	set Vars(base) $base
	set Vars(variant) $variant
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

	if {[info exists Vars(tableId)]} {
		::scidb::crosstable::release $Vars(tableId) $Vars(viewId)
	}
	if {![info exists Vars(viewId)]} {
		set Vars(viewId) [::scidb::view::new $base $variant slave slave slave slave slave]
	}
	if {$source eq "game"} { set search gameevent } else { set search event }
	::scidb::view::search $base $variant $Vars(viewId) null none [list $search $number]

	if {[winfo exists $dlg]} {
		::widget::dialogRaise $dlg
		set Vars(tableId) [::scidb::crosstable::make $base $variant $Vars(viewId)]
		UpdateContent $dlg 1
		return
	}

	set Vars(subscribe) [list [namespace current]::Close $base $variant $dlg]
	::scidb::view::subscribe {*}$Vars(subscribe)

	tk::toplevel $dlg -class Scidb
	bind $dlg <Destroy> [namespace code [list Destroy $dlg %W 1]]
	wm withdraw $dlg

	ttk::frame $top
	ttk::frame $canv
	set css [::html::defaultCSS [::font::htmlFixedFamilies] [::font::htmlTextFamilies]]
	set dir [file join $::scidb::dir::share scripts]
	::html $html \
		-imagecmd [namespace code GetImage] \
		-delay 10 \
		-center yes \
		-fittowidth no \
		-css $css \
		-importdir $dir \
		;
	$html handler node td [namespace current]::NodeHandler
	$html handler node span [namespace current]::NodeHandler
	bind [winfo parent [$html drawable]] <ButtonPress-3> [namespace code [list PopupMenu $dlg]]

	if {![info exists List(order)]} { MakeLists }
	variable List

	set tb [::toolbar::toolbar $dlg \
				-id crosstable-settings \
				-allow {top bottom} \
				-titlevar [namespace current]::mc::Settings \
				-padx 4 \
				-pady 2 \
			]
	set Vars(value:order) [lindex $List(order) 0]
	set Vars(value:type) [lindex $List(type) 0]
	set Vars(value:scoring) [lindex $List(scoring) 0]

	set f1 [::toolbar::add $tb frame]
	set f2 [::toolbar::add $tb frame]
	set f3 [::toolbar::add $tb frame]

	tk::label $f1.label_type -textvar [namespace current]::mc::Type
	::ttk::combobox  $f1.choose_type \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-textvar [namespace current]::${dlg}::Vars(value:type) \
		-width 16 \
		;
	set Vars(widget:type) $f1.choose_type

	tk::label $f1.label_order -textvar [namespace current]::mc::Order
	::ttk::combobox $f1.choose_order \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-textvar [namespace current]::${dlg}::Vars(value:order) \
		-width 12 \
		;
	set Vars(widget:order) $f1.choose_order

	tk::label $f1.scoring_label -textvar [namespace current]::mc::ScoringSystem
	set Vars(widget:scoring) $f1.choose_scoring
	::ttk::combobox $Vars(widget:scoring) \
		-takefocus 0 \
		-exportselection 0 \
		-state readonly  \
		-textvar [namespace current]::${dlg}::Vars(value:scoring) \
		-width 12 \
		;
	
	::toolbar::add $tb separator
	::toolbar::add $tb button \
		-image $icon::32x32::go \
		-command [namespace code [list Refresh $dlg]] \
		-tooltipvar [namespace current]::mc::UpdateDisplay \
		-padx 4 \
		;
	::toolbar::add $tb button \
		-image $icon::32x32::reset \
		-command [namespace code [list Reset $dlg]] \
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
		set f [set f[expr {($i - 1)/3 + 2}]]
		set r [expr {($i*2 - 1)%6}]
		set Vars(label:tiebreak$i) {}
		tk::label $f.label$i -textvar [namespace current]::${dlg}::Vars(label:tiebreak$i)
		set Vars(widget:tiebreak$i) $f.choose$i
		set Vars(value:tiebreak$i) [lindex $List(tiebreak) 0]
		::ttk::combobox $Vars(widget:tiebreak$i) \
			-takefocus 0 \
			-exportselection 0 \
			-state readonly  \
			-textvar [namespace current]::${dlg}::Vars(value:tiebreak$i) \
			-width 23 \
			-height [llength $ListEntries(tiebreak)] \
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

	InsertEntries $dlg

	$html onmouseover		[namespace code [list MouseEnter $dlg]]
	$html onmouseout		[namespace code [list MouseLeave $dlg]]
	$html onmousedown1	[namespace code [list Mouse1Down $dlg]]
	$html onmousedown2	[namespace code [list Mouse2Down $dlg]]
	$html onmouseup2		[namespace code [list Mouse2Up   $dlg]]
	$html onmousedown3	[namespace code [list Mouse3Down $dlg]]

	pack $top -expand yes -fill both

	grid $canv -row 1 -column 1 -sticky nsew
	grid columnconfigure $top 1 -weight 1
	grid rowconfigure $top 1 -weight 1

	grid $html -row 0 -column 0 -sticky nsew
	grid columnconfigure $canv 0 -weight 1
	grid rowconfigure $canv 0 -weight 1

	bind $dlg <<LanguageChanged>> [namespace code [list LanguageChanged $dlg %W]]

	if {$source eq "event"} {
		::widget::dialogButtons $dlg {close previous next}
		$dlg.previous configure -command [namespace code [list NextEvent $dlg -1]]
		$dlg.next configure -command [namespace code [list NextEvent $dlg +1]]
	} else {
		::widget::dialogButtons $dlg close
	}
	$dlg.close configure -command [list destroy $dlg]

	::update
	set Vars(tableId) [::scidb::crosstable::make $base $variant $Vars(viewId)]
	UpdateContent $dlg 1

	lassign {0 0} w h
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


proc Close {dlg args} {
	set [namespace current]::${dlg}::Vars(open) 0
}


proc RecordGeometry {dlg} {
	variable Geometry

	set g [wm geometry $dlg]
	set n [string first "+" $g]
	if {$n == -1} { set n [string first "-" $g] }
	if {$n >= 0} { set Geometry [string range $g 0 [expr {$n - 1}]] }
}


proc NextEvent {dlg step} {
	variable ${dlg}::Vars

	::scidb::crosstable::release $Vars(tableId) $Vars(viewId)
	incr Vars(index) $step
	set view $Vars(view)
	set base $Vars(base)
	set variant  $Vars(variant)
	set index $Vars(index)
	set number [::scidb::db::get eventIndex $index $view $base $variant]
	::scidb::view::search $base $variant $Vars(viewId) null none [list event $number]
	set Vars(info) [::scidb::db::get eventInfo $index $Vars(viewId) $base $variant -card]
	set Vars(tableId) [::scidb::crosstable::make $base $variant $Vars(viewId)]
	set Vars(warning) 0
	set Vars(lastMode) ""
	set Vars(prevMode) ""
	set Vars(prevTiebreaks) ""
	set Vars(prevScoring) ""
	UpdateContent $dlg 1
}


proc MakeLists {} {
	variable ListEntries
	variable List

	foreach attr {tiebreak scoring order type} {
		set List($attr) {}
		foreach entry $ListEntries($attr) { lappend List($attr) [set mc::[string toupper $entry 0 0]] }
	}
}


proc InsertEntries {dlg} {
	variable List
	variable ${dlg}::Vars

	set parent $Vars(widget:tiebreak1)
	foreach i {1 2 3 4 5 6} {
		set n [lsearch -exact $List(tiebreak) $Vars(value:tiebreak$i)]
		set Vars(label:tiebreak$i) "$i. $mc::Tiebreak"
		$Vars(widget:tiebreak$i) configure -values $List(tiebreak)
		set clone [::toolbar::lookupClone $parent $Vars(widget:tiebreak$i)]
		if {[llength $clone]} { $clone configure -values $List(tiebreak) }
		if {$n >= 0} { set Vars(value:tiebreak$i) [lindex $List(tiebreak) $n] }
	}

	set n [lsearch -exact $List(scoring) $Vars(value:scoring)]
	$Vars(widget:scoring) configure -values $List(scoring)
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:scoring)] $Vars(widget:scoring)]
	if {[llength $clone]} { $clone configure -values $List(scoring) }
	if {$n >= 0} { set Vars(value:scoring) [lindex $List(scoring) $n] }

	set n [lsearch -exact $List(order) $Vars(value:order)]
	$Vars(widget:order) configure -values $List(order)
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:order)] $Vars(widget:order)]
	if {[llength $clone]} { $clone configure -values $List(order) }
	if {$n >= 0} { set Vars(value:order) [lindex $List(order) $n] }

	set n [lsearch -exact $List(type) $Vars(value:type)]
	$Vars(widget:type) configure -values $List(type)
	set clone [::toolbar::lookupClone [winfo parent $Vars(widget:type)] $Vars(widget:type)]
	if {[llength $clone]} { $clone configure -values $List(type) }
	if {$n >= 0} { set Vars(value:type) [lindex $List(type) $n] }
}


proc LanguageChanged {dlg w} {
	if {$dlg ne $w} { return }

	SetTitle $dlg
	MakeLists
	InsertEntries $dlg
	UpdateContent $dlg
}


proc SetTitle {dlg} {
	variable ${dlg}::Vars
	wm title $dlg "$::scidb::app: $mc::TournamentTable$Vars(eventName)"
}


proc GetImage {code} {
	return [list $::country::icon::flag($code) [namespace code DoNothing]]
}


proc DoNothing {args} {
	# nothing to do
}


proc Reset {dlg} {
	variable ${dlg}::Vars

	foreach attr [array names Vars reset:*:$dlg] {
		set Vars([string range $attr 6 end]) $Vars($attr)
	}
	Refresh $dlg
}


proc Refresh {dlg} {
	variable ${dlg}::Vars
	variable List
	variable ListEntries

	set Vars(prevMode) $Vars(bestMode)
	set Vars(prevTiebreaks) $Vars(tiebreaks)
	set Vars(prevScoring) $Vars(scoring)
	set Vars(order) [lindex $ListEntries(order) [lsearch -exact $List(order) $Vars(value:order)]]
	set Vars(bestMode) [lindex $ListEntries(type) [lsearch -exact $List(type) $Vars(value:type)]]
	set Vars(scoring) [lindex $ListEntries(scoring) [lsearch -exact $List(scoring) $Vars(value:scoring)]]
	set Vars(tiebreaks) {}
	for {set i 1} {$i <= 6} {incr i} {
		set n [lsearch -exact $List(tiebreak) $Vars(value:tiebreak$i)]
		if {$n > 0} { lappend Vars(tiebreaks) [lindex $ListEntries(tiebreak) $n] }
	}

	UpdateContent $dlg
	UpdateHistory $dlg
}


proc UpdateHistory {dlg} {
	variable RecentlyUsedTiebreaks
	variable RecentlyUsedScoring
	variable RecentlyUsedHistory
	variable MostRecentHistory
	variable ${dlg}::Vars

	set RecentlyUsedTiebreaks($Vars(bestMode)) $Vars(tiebreaks)
	set RecentlyUsedScoring($Vars(bestMode)) $Vars(scoring)

	if {	$Vars(prevMode) ne $Vars(bestMode)
		|| $Vars(prevScoring) ne $Vars(scoring)
		|| $Vars(prevTiebreaks) ne $Vars(tiebreaks)} {
		set event $Vars(event)
		set i [lsearch -exact -index 0 $RecentlyUsedHistory $event]

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


proc UpdateContent {dlg {setup 0}} {
	variable ${dlg}::Vars
	variable List
	variable Defaults
	variable Options
	variable Scripts
	variable Highlighted
	variable Marks
	variable Nodes
	variable ListEntries

	set w $Vars(html)
	set base $Vars(base)
	set variant $Vars(variant)
	set index $Vars(index)
	set viewId $Vars(viewId)

	if {$setup} {
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
		if {[string length $name] <= 1} { set Vars(eventName) "" } else { set Vars(eventName) " $name" }
		set Vars(event) [list $name $eventDate $site $eventCountry $eventType $eventMode $timeMode]
		set i [lsearch -exact -index 0 $RecentlyUsedHistory $Vars(event)]

		if {$i >= 0} {
			lassign [lindex $RecentlyUsedHistory $i 1] bestMode tiebreaks scoring
		} else {
			set i [lsearch -exact -index 0 $MostRecentHistory $Vars(event)]

			if {$i >= 0} {
				lassign [lindex $MostRecentHistory $i 1] bestMode tiebreaks scoring
			} else {
				set bestMode [::scidb::crosstable::get bestMode $Vars(tableId) $viewId]
				set bestMode [string tolower $bestMode 0 0]
				set tiebreaks $RecentlyUsedTiebreaks($bestMode)
				set scoring $RecentlyUsedScoring($bestMode)
			}
		}

		set i 0
		foreach tb $tiebreaks {
			set Vars(value:tiebreak[incr i]) \
				[lindex $List(tiebreak) [lsearch -exact $ListEntries(tiebreak) $tb]]
		}
		for {incr i} {$i <= 6} {incr i} {
			set Vars(value:tiebreak$i) [lindex $List(tiebreak) 0]
		}
		set Vars(value:scoring) [lindex $List(scoring) [lsearch -exact $ListEntries(scoring) $scoring]]
		set Vars(value:type) [lindex $List(type) [lsearch -exact $ListEntries(type) $bestMode]]
		set Vars(bestMode) $bestMode
		set Vars(tiebreaks) $tiebreaks
		set Vars(scoring) $scoring
		foreach attr {	tiebreaks bestMode value:type value:tiebreak1
							value:tiebreak2 value:tiebreak3 value:tiebreak4} {
			set Vars(reset:$attr) $Vars($attr)
		}
		SetTitle [winfo toplevel $w]
		ConfigureButtons $dlg
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
		\\def\\Lang{$::mc::langID}
		\\def\\Title{$mc::TournamentTable:$Vars(eventName)}
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
		\\let\\ShowWinDrawLoss\\$Options(show:winDrawLoss)
		\\let\\ShowChange\\1
		\\let\\ShowCountry\\1
	"

	if {$Vars(bestMode) eq "crosstable"} {
		append preamble "\\let\\TableLimit\\$Defaults(crosstableLimit)"
		set id [list $base $variant $Vars(viewId)]

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
						set Vars(bestMode) [string tolower $Vars(bestMode) 0 0]
						if {$Vars(bestMode) eq "crosstable"} { set Vars(bestMode) rankingList }
						set Vars(value:type) \
							[lindex $List(type) [lsearch -exact $ListEntries(type) $Vars(bestMode)]]
						UpdateHistory $dlg
						after idle [namespace code [list UpdateContent $dlg]]
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
			ShowTrace $dlg $attr
		} elseif {[winfo exists $w.$attr]} {
			destroy $w.$attr
		}
	}
	set Vars(tooltip) ""
}


proc ConfigureButtons {dlg} {
	variable ${dlg}::Vars

	set dlg [winfo toplevel $Vars(html)]
	if {![winfo exists $dlg.next]} { return }

	if {$Vars(index) == -1} {
		$dlg.previous configure -state disabled
		$dlg.next configure -state disabled
	} else {
		if {$Vars(index) == 0} { set state disabled } else { set state normal }
		$dlg.previous configure -state $state
		set count [scidb::view::count events $Vars(base) $Vars(variant) $Vars(view)]
		if {$Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$dlg.next configure -state $state
	}
}


proc CloseTrace {dlg which} {
	variable Options
	variable ${dlg}::Vars

	set Options(debug:$which) 0
	catch { destroy [winfo toplevel $Vars(html)].$which }
}


proc ShowTrace {dlg which} {
	variable ${dlg}::Vars

	if {$which eq "log"} {
		set useHorzScroll 0
	} else {
		set useHorzScroll 1
	}
	set path [winfo toplevel $Vars(html)].$which
	set closeCmd [namespace code [list CloseTrace $dlg $which]]
	::widget::showTrace $path $Vars(output:$which) $useHorzScroll $closeCmd
}


proc ToggleTrace {dlg which} {
	variable Options

	if {$Options(debug:$which)} {
		ShowTrace $dlg $which
	} else {
		CloseTrace $dlg $which
	}
}


proc Destroy {dlg w unsubscribe} {
	if {$w ne $dlg} { return }

	variable ${dlg}::Vars
	variable Key

	catch { destroy $dlg.html }
	catch { destroy $dlg.log }

	if {$unsubscribe} { ::scidb::view::unsubscribe {*}$Vars(subscribe) }
	::scidb::crosstable::release $Vars(tableId) $Vars(viewId)
	if {$Vars(open)} {
		set Vars(open) 0
		::scidb::view::close $Vars(base) $Vars(variant) $Vars(viewId)
	}
	namespace delete [namespace current]::$dlg
	array unset Key $dlg
}


proc Open {dlg which gameIndex} {
	variable ${dlg}::Vars

	Tooltip $dlg hide

	set base $Vars(base)
	set variant $Vars(variant)
	set path $Vars(html)
	set viewId $Vars(viewId)

	if {$which eq "pgn"} {
		::widget::busyOperation \
			{ ::game::new $path -base $base -variant $variant -view $viewId -number $gameIndex }
	} else {
		set index [::scidb::view::map game $base $variant $viewId $gameIndex]
		set info [::scidb::db::get gameInfo $index $viewId $base $variant]
		set Vars(${which}Id) [::widget::busyOperation \
			[list ::${which}::load $path $base $variant $info $viewId $index $Vars(${which}Id)]]
	}
}


proc ShowPlayerCard {dlg rank} {
	variable ${dlg}::Vars

	Tooltip $dlg hide
	lassign [::scidb::crosstable::get playerId $Vars(tableId) $Vars(viewId) $rank]] gameIndex side
	::playercard::show $Vars(base) $Vars(variant) $gameIndex $side
}


proc Tooltip {dlg msg} {
	variable ${dlg}::Vars

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
	if {[string length $attr]} { set Nodes($attr) $node }
}


proc MouseEnter {dlg node} {
	variable ${dlg}::Vars
	variable Options

	HandleEnterLeave $node EnterNode

	set country [$node attribute -default {} src]
	if {[llength $country]} {
		set Vars(tooltip) $node
		Tooltip $dlg [::country::name $country]
	} elseif {$Options(show:opponent)} {
		set rank [$node attribute -default {} player]
		if {[llength $rank]} {
			set Vars(tooltip) $node
			Tooltip $dlg [::scidb::crosstable::get playerName $Vars(tableId) $Vars(viewId) $rank]
		}
	}
}


proc MouseLeave {dlg node {stimulate 0}} {
	variable ${dlg}::Vars

	HandleEnterLeave $node LeaveNode

	if {$Vars(tooltip) eq $node} {
		set Vars(tooltip) ""
		foreach attr {src player id} {
			set content [$node attribute -default {} $attr]
			if {[llength $content]} { Tooltip $dlg hide }
		}
	}

	if {$stimulate} {
		$Vars(html) stimulate
		::tooltip::hide
	}
}


proc HandleEnterLeave {node action} {
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


proc Mouse1Down {dlg node} {
	variable ${dlg}::Vars

	if {[llength $node] == 0} { return }
	set gameIndex [$node attribute -default {} game]
	if {[string length $gameIndex]} {
		Open $dlg browser $gameIndex
		$Vars(html) stimulate
		::tooltip::hide
	}

	# don't use because Button-1 is used for highlighting
#	set rank [$node attribute -default {} rank]
#	if {[string length $rank]} { ShowPlayerCard $dlg $rank }

	set mark [$node attribute -default {} mark]
	if {[string length $mark]} {
		set idList [$node attribute -default {} send]
		if {[string length $idList]} { append idList : }
		append idList $mark
		Hilite $idList
	}
}


proc Mouse2Down {dlg node} {
	variable ${dlg}::Vars

	if {[llength $node] == 0} { return }
	set gameIndex [$node attribute -default {} game]
	if {[string length $gameIndex]} {
		MouseEnter $dlg $node
		::gametable::showGame $dlg $Vars(base) $Vars(variant) -1 $gameIndex 
	} else {
		set rank [$node attribute -default {} rank]
		if {[string length $rank]} {
			MouseEnter $dlg $node
			set info [::scidb::crosstable::get playerInfo $Vars(tableId) $Vars(viewId) $rank]
			::playercard::popupInfo $dlg $info
		} else {
			set id [$node attribute -default {} recv]
			if {$id eq "event"} {
				MouseEnter $dlg $node
				::eventtable::popupInfo $dlg $Vars(info)
			}
		}
	}
}


proc Mouse2Up {dlg node} {
	if {[llength $node] == 0} { return }
	set attr [$node attribute -default {} recv]
	if {[string length $attr] == 0} { return }

	::gametable::hideGame $dlg
	::playercard::popdownInfo $dlg
	::eventtable::popdownInfo $dlg
	MouseLeave $dlg $node 1
}


proc Mouse3Down {dlg node} {
	variable _Popup

	if {[llength $node] == 0} {
		if {[info exists _Popup]} { return }
		return [PopupMenu $dlg]
	}

	set rank [$node attribute -default {} rank]
	set gameIndex [$node attribute -default {} game]

	if {[llength $rank] == 0 && [llength $gameIndex] == 0} { return }

	set m $dlg.popup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }

	if {[llength $rank]} {
		$m add command \
			-compound left \
			-image $::icon::16x16::playercard \
			-label " $::playertable::mc::ShowPlayerCard" \
			-command [namespace code [list ShowPlayerCard $dlg $rank]] \
			;
	} else {
		$m add command \
			-compound left \
			-image $::icon::16x16::browse \
			-label " $::browser::mc::BrowseGame" \
			-command [namespace code [list Open $dlg browser $gameIndex]] \
			;
		$m add command \
			-compound left \
			-image $::icon::16x16::overview \
			-label " $::overview::mc::Overview" \
			-command [namespace code [list Open $dlg overview $gameIndex]] \
			;
		$m add command \
			-compound left \
			-image $::icon::16x16::document \
			-label " $::browser::mc::LoadGame" \
			-command [namespace code [list Open $dlg pgn $gameIndex]] \
			;
		# TODO: add Merge Game
	}

	if {[info exists m]} {
		$m add separator
		BuildMenu $dlg $m

		MouseEnter $dlg $node
		set _Popup 1
		bind $m <<MenuUnpost>> [list unset [namespace current]::_Popup]
		bind $m <<MenuUnpost>> +[namespace code [list MouseLeave $dlg $node 1]]
		tk_popup $m {*}[winfo pointerxy $dlg]
	}
}


proc BuildMenu {dlg m} {
	variable Options
	variable ${dlg}::Vars

	set sub [menu $m.display]

	if {$Vars(bestMode) eq "knockout"} { set state disabled } else { set state normal }
	foreach opt {rating performance tiebreak winDrawLoss} {
		$sub add checkbutton \
			-label [set mc::Show[string toupper $opt 0 0]] \
			-command [namespace code [list UpdateContent $dlg]] \
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

	$m add command \
		-label "$mc::SaveAsHTML..." \
		-command [namespace code [list SaveAsHTML $dlg]] \
		;
	$m add separator

	$m add cascade -label $mc::Display -menu $sub

	set sub [menu $m.style]

	menu $sub.spacing
	menu $sub.padding
	menu $sub.knockout

	foreach pad {1 2 3 4 5 6} {
		$sub.padding add radiobutton \
			-label $pad \
			-command [namespace code [list UpdateContent $dlg]] \
			-variable [namespace current]::Options(fmt:padding) \
			-value $pad \
			;
		::theme::configureRadioEntry $sub.padding $pad
	}
	foreach spc {0 1} {
		$sub.spacing add radiobutton \
			-label $spc \
			-command [namespace code [list UpdateContent $dlg]] \
			-variable [namespace current]::Options(fmt:spacing) \
			-value $spc \
			;
		::theme::configureRadioEntry $sub.spacing $spc
	}

	if {$Vars(bestMode) eq "knockout"} { set state normal } else { set state disabled }

	$sub add cascade -label $mc::Spacing -menu $sub.spacing
	$sub add cascade -label $mc::Padding -menu $sub.padding
	$sub add cascade -label $mc::KnockoutStyle -menu $sub.knockout -state $state

	set text $mc::Triangle
	$sub.knockout add radiobutton \
		-label $text \
		-command [namespace code [list UpdateContent $dlg]] \
		-variable [namespace current]::Options(fmt:pyramid) \
		-value 0 \
		;
	::theme::configureRadioEntry $sub.knockout $text
	set text $mc::Pyramid
	$sub.knockout add radiobutton \
		-label $text \
		-command [namespace code [list UpdateContent $dlg]] \
		-variable [namespace current]::Options(fmt:pyramid) \
		-value 1 \
		;
	::theme::configureRadioEntry $sub.knockout $text

	$m add cascade -label $mc::Style -menu $sub

	set sub [menu $m.debugging]

	foreach opt {html log} {
		$sub add checkbutton \
			-label [set mc::Show[string toupper $opt 0 0]] \
			-command [namespace code [list ToggleTrace $dlg $opt]] \
			-variable [namespace current]::Options(debug:$opt) \
			;
	}

	$m add separator
	$m add cascade -label $mc::Debugging -menu $sub
}


proc SaveAsHTML {dlg} {
	variable ${dlg}::Vars
	variable Options

	set filetypes [list [list $::dialog::fsbox::mc::FileType(html) {.html}]]
	set eventName [lindex $Vars(event) 0]
	set save [::dialog::saveFile \
		-parent $dlg \
		-class crosstable \
		-initialdir $::scidb::dir::home \
		-initialfile $eventName.html \
		-filetypes $filetypes \
		-needencoding no \
		-geometry last \
	]

	if {[llength $save] == 0} { return }

	set file [lindex $save 0]
	if {[catch { ::open $file w } chan ]} {
		if {[file exists $file]} {
			set msg $mc::CannotOverwriteFile
		} else {
			set msg $mc::CannotCreateFile
		}
		return [::dialog::error -parent $dlg -message [format $msg $file]]
	}

	set html $Vars(output:html)
	set html [regsub -all {[ ](recv|send|game)=[\"][^\"]*[\"]} $html ""]

	append data "    " [::html::textStyle [::font::htmlTextFamilies]] \n
	append data "    " [::html::monoStyle [::font::htmlFixedFamilies]] \n
	array set flags {}
	while {[set n [string first "<td><img src=" $html]] != -1} {
		set code [string range $html [expr {$n + 14}] [expr {$n + 16}]]
		set flag $::country::icon::flag($code)
		set wd [image width $flag]
		set ht [image height $flag]
		set txt "<div class=\"$code\" title=\"[::country::name $code]\"></div>"
		set html [string replace $html [expr {$n + 4}] [expr {$n + 19}] $txt]
		if {![info exists flags($code)]} {
			set flags($code) 1
			set img [string map {\t "" \n "" " " ""} [$flag cget -data]]
			append data "    .$code { width:${wd}px; height:${ht}px; background-repeat:no-repeat; "
			append data "background-image:url(data:image/png;base64,$img); }\n"
		}
	}
	if {[string length $data]} {
		append style "  <style type=\"text/css\">\n"
		append style $data
		append style "  </style>\n"
		set html [regsub {</head>} $html $style]
	}
	if {[set n [string first "<img src=" $html]] != -1} {
		set i1 [expr {$n + 10}]
		set i2 [expr {$n + 12}]
		set code [string range $html $i1 $i2]
		append src "data:image/png;base64,"
		append src [string map {\t "" \n "" " " ""} [$::country::icon::flag($code) cget -data]]
		append src "\" title=\"[::country::name $code]"
		set html [string replace $html $i1 $i2 $src]
	}

	fconfigure $chan -encoding binary
	puts $chan $html
	close $chan
}


proc PopupMenu {dlg} {
	variable ${dlg}::Vars

	set m .application.__crosstable_popup__
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	BuildMenu $dlg $m
	bind $m <<MenuUnpost>> [list $Vars(html) stimulate]
	bind $m <<MenuUnpost>> +::tooltip::hide
	tk_popup $m {*}[winfo pointerxy $dlg]
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

# set go [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAACAVBMVEUAAAACDw8LTlECDw8C
# 	Dw8RbHECDw8CDw8CDw8CDw8CDw8CDw8CDw8NXmMCDw8CDw8CDw8CDw8CDw8OZmsCDw8CDw8D
# 	FxgCDw8CDw8CDw8CDw8CDw8CDw8CDw8CDw8CDw8PaG0CDw8CDw8CDw8CDw8CDw8CDw8CDw8D
# 	FxgOYmYCDw8GKiwCDw8CDw8CDw8CDw8GLzECDw8CDw8OYmYKSk0IODsOZWkOYmYNW18KRUkO
# 	ZmsOY2gOZmsOZmsOZmsMVFcOZmsOYmYOZWkNXmMOZmsOZmsOZWkOYmYOZmsOZmsOZmsOZmsR
# 	bHERbHEPam8RbHEOZmsWcXYXcncjfIEkfoIOZmsfeX4kfoIxiI01i5A9kZUOZmsUb3Qwh4wZ
# 	dHlDlZlVoaVBlJhLm59orrJRn6NYpKhfqKwOZWkeeH0feX4gen8he4AjfIEkfoIlf4MmgIQo
# 	gYUpgoYqg4cshIgthYouhoswh4wxiI0ziY41i5A3jJE4jpI6j5M7kJQ9kZVAk5dBlJhDlZlE
# 	lptGl5xImJ1Jmp5Lm59MnKBOnaFQnqJToKRVoaVYpKhapalcpqpfqKxnrbForrJssLRusbVw
# 	s7Z0tbh2trp4t7t8ur1+u76AvL+CvcCEvsKGwMOIwcSKwsWOxMeQxsiTx8qVyMuXycyZys2b
# 	zM6ezc+gztGk0dOm0tRLVt61AAAAZ3RSTlMAAQECAwMEBQYHCAkKCgsMDQ4PDxARERITFBUW
# 	FxgaGxwdHh8gIiMkJCUmJikqLC4uMjY5P0BFUV1gYGxxgIiKkpuytLW/yNbY4uft7vL09fb2
# 	9vb29/f39/f3+Pj5+vr6+/v9/v7+GgnqVwAAAaVJREFUOMvNkt1qU0EUhdfaM2krJShFIjQW
# 	RVAQBZEW9Eapr+BL+HA+gILQC2mlFRFRREFapBjpOfmpYAM987O3FzlJmwi51X23Nh+z1qwZ
# 	4N+Pm5bPfGcGkBl9/ZHMB56ubTbnWWzcuNlbSb/mnKDlZvvu+rmFnwW0/8BeLr6ZLDgKX9Ty
# 	yuMjtaXlF72dOA08FAIgIT/MdOnSq977/rTFIUkBCDPTYXiy679/OQ9YpsAIQoFs6ed975tv
# 	z665cXUAgxnNYDmE0+rk2q3+5cMzYPUYAGnI1fDkNMRYDXCvbB9MLFJ0ApjmDKOoKMzU+XEG
# 	j/SbQkeSAFWUaC9v9bZrwDUAkEIKaVBR+rWv3eKd1oB3AEnSEaSJykL7Q1l889lGAB1wR0AS
# 	5IGqXGjtlcURRXKdwfBpXP26mFxsvu53hoCNi9L8fLHR8A0nvA2yxd2iEzWp5hoIkoQw846A
# 	a30sumVKIcY0qboy1QVNzjHI6k63W2qKIYY8AazKOTnvRaBbg85xjjmmMPWaKQXvxHFlu/gc
# 	NOeU/vpROQMU7O+ZjuL/R/MHYAPLcEBkVE0AAAAASUVORK5CYII=
# }]

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
