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

::util::source engine-admin

namespace eval engine {
namespace eval mc {

set Informationen			"Information"
set Options					"Options"

set Name						"Name"
set Identifier				"Identifier"
set Author					"Author"
set Country					"Country"
set Rating					"Rating"
set Logo						"Logo"
set Protocol				"Protocol"
set Parameters				"Parameters"
set Command					"Command"
set Variants				"Variants"
set LastUsed				"Last used"
set Frequency				"Frequency"

set Variant(standard)	"Standard Chess"
set Variant(chess960)	"Chess 960"
set Variant(shuffle)		"Shuffle Chess"

set SetupEngines			"Setup Egines"
set ImageFiles				"Image files"
set SelectEngine			"Select Engine"
set SelectEngineLogo		"Select Engine Logo"
set Executables			"Executables"
set EngineLog				"Engine Log"
set Probing					"Probing"
set NeverUsed				"never used"
set OpenFsbox				"Open File Selection Dialog"
set ResetToDefault		"Reset to default"

set ConfirmNewEngine		"Confirm new engine"
set EngineAlreadyExists	"An entry with this engine already exists."
set CopyFromEngine		"Make a copy of entry"
set CannotOpenProcess	"Cannot start process."
set DoesNotRespond		"This engine does not respond either to UCI nor to XBoard/WinBoard protocol."
set DiscardChanges		"The current item has changed.\n\nReally discard changes?"
set ReallyDelete			"Really delete engine '%s'?"

} ;# namespace mc

variable Engines {}
variable PhotoFiles {}

array set Engine {}
array set Priv { after {} }
array set Logo { width 100 height 54 }


proc openSetup {parent} {
	variable Engines
	variable Logo
	variable Priv
	variable Var
	variable Var_

	set dlg $parent.chooseEngine
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	set Priv(state) edit
	set Priv(engines) {}
	set Priv(selection) -1
	set Priv(initialise) 1
	set Priv(rows) {0}
	array set Var {}
	array set Var_ {}

	### left frame ########################################################
	set list [::tlistbox $top.list \
		-usescroll yes \
		-padx 5 \
		-pady 7 \
		-linespace $Logo(height) \
		-height 6 \
		-selectmode browse \
	]
	RebuildEngineList $list

	### right frame #######################################################
	set nb [::ttk::notebook $top.nb -takefocus 1]
	::ttk::notebook::enableTraversal $nb

	### Tab: Setup ########################################################
	set setup [ttk::frame $nb.setup -takefocus 0 -borderwidth 0]
	$nb add $setup -sticky nsew -text $mc::Information -padding {5 5}
	set bg [::theme::getBackgroundColor]
#	lappend labelOptions -borderwidth 1 -relief raised -background [::theme::getToplevelBackground]
	lappend labelOptions -borderwidth 1 -relief raised -background #f2f2f2

	ttk::label			$setup.lname -text $mc::Name
	ttk::entry			$setup.ename -textvar [namespace current]::Var(Name)
#	ttk::combobox		$setup.cname \
#								-textvar [namespace current]::Var(Name) \
#								-height 15 \
#								-exportselection no \
#								-postcommand [namespace code [list FillCombobox $setup.cname]] \
#								;
	ttk::label			$setup.lauthor -text $mc::Author
	ttk::entry			$setup.eauthor -textvar [namespace current]::Var(Author)
	ttk::label			$setup.lidentifier -text $mc::Identifier
	ttk::label			$setup.tidentifier -textvar [namespace current]::Var(Identifier) {*}$labelOptions
	ttk::label			$setup.lvariants -text $mc::Variants
	ttk::label			$setup.tvariants -textvar [namespace current]::Var(Variant) {*}$labelOptions
	ttk::label			$setup.llastused -text $mc::LastUsed
	ttk::label			$setup.tlastused -textvar [namespace current]::Var(LastUsed) {*}$labelOptions
	tk::button			$setup.blastused \
								-image $::icon::12x12::eraser \
								-background $bg \
								-command [namespace code [list ClearLastUsed $list]] \
								;
	ttk::label			$setup.lused -text $mc::Frequency
	ttk::label			$setup.tused -textvar [namespace current]::Var(Frequency) {*}$labelOptions
	tk::button			$setup.bused \
								-image $::icon::12x12::eraser \
								-background $bg \
								-command [namespace code [list ClearFrequency $list]] \
								;
	ttk::label			$setup.lcommand -text $mc::Command
	ttk::label			$setup.tcommand -textvar [namespace current]::Var(Command) {*}$labelOptions
	ttk::label			$setup.lparams -text $mc::Parameters
	ttk::entry			$setup.eparams -textvar [namespace current]::Var(Parameters)
	ttk::label			$setup.lcountry -text $mc::Country
	::countrybox		$setup.ccountry -textvar [namespace current]::Var(Country)
	ttk::label			$setup.lrating -text $mc::Rating
	ttk::frame			$setup.frating -takefocus 0 -borderwidth 0
	ttk::label			$setup.frating.lelo -text "Elo"
	ttk::spinbox		$setup.frating.selo \
								-width 5 \
								-from 0 \
								-to 4000 \
								-exportselection no \
								-textvar [namespace current]::Var(Elo) \
								;
	ttk::label			$setup.frating.lccrl -text "CCRL"
	ttk::spinbox		$setup.frating.sccrl \
								-width 5 \
								-from 0 \
								-to 4000 \
								-exportselection no \
								-textvar [namespace current]::Var(CCRL) \
								;
	ttk::label			$setup.lprotocol -text $mc::Protocol
	ttk::frame			$setup.fprotocol -takefocus 0 -borderwidth 0
	ttk::radiobutton	$setup.fprotocol.buci \
								-text "UCI" \
								-variable [namespace current]::Var(protocol) \
								-value "UCI" \
								;
	ttk::radiobutton	$setup.fprotocol.bwb \
								-text "XBoard/WinBoard" \
								-variable [namespace current]::Var(protocol) \
								-value "WB" \
								;
	ttk::label			$setup.lurl -text "URL"
	ttk::entry			$setup.eurl -textvar [namespace current]::Var(Url)
	tk::button			$setup.burl \
								-image $::icon::16x16::internet \
								-background $bg \
								-command [namespace code [list WebOpen $dlg]] \
								;
	ttk::label			$setup.llogo -text $mc::Logo
	ttk::entry			$setup.elogo -textvar [namespace current]::Var(Logo)
	tk::button			$setup.blogo \
								-text "..." \
								-background $bg \
								-padx 2 \
								-pady 0 \
								-command [namespace code [list GetLogo $dlg $list]] \
								;

	::tooltip::tooltip $setup.burl ::playercard::mc::OpenInWebBrowser
	::tooltip::tooltip $setup.blastused $::mc::Clear
	::tooltip::tooltip $setup.bused $::mc::Clear
	::tooltip::tooltip $setup.blogo $mc::OpenFsbox
	::theme::configureSpinbox $setup.frating.selo
	::theme::configureSpinbox $setup.frating.sccrl
	::validate::spinboxInt $setup.frating.selo
	::validate::spinboxInt $setup.frating.sccrl
	bind $setup.elogo <FocusOut> [namespace code [list SetLogo $list]]

	set Priv(countrybox) $setup.ccountry
	set Priv(button:UCI) $setup.fprotocol.buci
	set Priv(button:WB) $setup.fprotocol.bwb

	grid $setup.frating.lelo	-row 1 -column 1
	grid $setup.frating.selo	-row 1 -column 3
	grid $setup.frating.lccrl	-row 1 -column 5
	grid $setup.frating.sccrl	-row 1 -column 7
	grid columnconfigure $setup.frating {2 6} -minsize $::theme::padx
	grid columnconfigure $setup.frating {4} -minsize $::theme::padX

	grid $setup.fprotocol.buci		-row 1 -column 1
	grid $setup.fprotocol.bwb		-row 1 -column 3
	grid columnconfigure $setup.fprotocol {2} -minsize $::theme::padX

	grid $setup.lname			-row  1 -column 1 -sticky w
	grid $setup.ename			-row  1 -column 3 -sticky we ;# -columnspan 3
	grid $setup.lauthor		-row  3 -column 1 -sticky w
	grid $setup.eauthor		-row  3 -column 3 -sticky we ;# -columnspan 3

	grid $setup.lidentifier	-row  5 -column 1 -sticky w
	grid $setup.tidentifier	-row  5 -column 3 -sticky we ;# -columnspan 3
	grid $setup.lvariants   -row  7 -column 1 -sticky w
	grid $setup.tvariants   -row  7 -column 3 -sticky we ;# -columnspan 3
	grid $setup.llastused	-row  9 -column 1 -sticky w
	grid $setup.tlastused	-row  9 -column 3 -sticky we
	grid $setup.blastused	-row  9 -column 5 -sticky we
	grid $setup.lused			-row 11 -column 1 -sticky w
	grid $setup.tused			-row 11 -column 3 -sticky we
	grid $setup.bused			-row 11 -column 5 -sticky we

	grid $setup.lcountry		-row 13 -column 1 -sticky w
	grid $setup.ccountry		-row 13 -column 3 -sticky we ;# -columnspan 3
	grid $setup.lrating		-row 15 -column 1 -sticky w
	grid $setup.frating		-row 15 -column 3 -sticky w
	grid $setup.lprotocol	-row 17 -column 1 -sticky w
	grid $setup.fprotocol	-row 17 -column 3 -sticky w  ;# -columnspan 3

	grid $setup.lurl			-row 19 -column 1 -sticky w
	grid $setup.eurl			-row 19 -column 3 -sticky we
	grid $setup.burl			-row 19 -column 5 -sticky we
	grid $setup.llogo			-row 21 -column 1 -sticky w
	grid $setup.elogo			-row 21 -column 3 -sticky we
	grid $setup.blogo			-row 21 -column 5 -sticky we

	grid $setup.lcommand		-row 23 -column 1 -sticky w
	grid $setup.tcommand		-row 23 -column 3 -sticky we ;# -columnspan 3
	grid $setup.lparams		-row 25 -column 1 -sticky w
	grid $setup.eparams		-row 25 -column 3 -sticky we ;# -columnspan 3

	grid columnconfigure $setup {0 2 4 6} -minsize $::theme::padx
	grid columnconfigure $setup {3} -weight 1
	grid rowconfigure $setup {0 2 6 8 10 14 16 20 24 26} -minsize $::theme::pady
	grid rowconfigure $setup {4 12 18 22} -minsize [expr {3*$::theme::pady}] -weight 1

	bind $list <<ListboxSelect>> [namespace code [list Select $list %d]]

	### Tab: Options ######################################################
	set options $nb.options
	set scrolled [::scrolledframe $options \
		-background [::theme::getBackgroundColor] \
		-borderwidth 1 \
		-relief sunken \
	]
	$nb add $options -sticky nsew -text $mc::Options -padding {5 5}
	set f [ttk::frame $scrolled.f -borderwidth 0]
	grid $f -sticky nsew
	set Priv(tab:options) $options
	set Priv(scrolled:options) $scrolled
	set Priv(pane:options) $f
	set Priv(pane:setup) $setup

	### geoemetry #########################################################
	grid $list -row 1 -column 1
	grid $nb	  -row 1 -column 3 -sticky nswe
	grid rowconfigure $top {0 2} -minsize $::theme::pady
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid columnconfigure $top {3} -weight 1

	::widget::dialogButtons $dlg {new save delete close help} -default close
	$dlg.delete configure -command [namespace code [list DeleteEngine $list]]
	$dlg.save configure -command [namespace code [list SaveEngine $list]] -state disabled
	$dlg.new configure -command [namespace code [list NewEngine $list]]
	$dlg.close configure -command [namespace code [list CloseSetup $list]]
	if {[llength $Engines] == 0} { $dlg.delete configure -state disabled }
	set Priv(button:save) $dlg.save
	set Priv(button:delete) $dlg.delete

	if {[llength $Engines]} { $list select 0 }
	update idletasks

	$nb.setup configure -width [winfo reqwidth $nb.setup ]
	wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
	wm minsize $dlg [winfo reqwidth $dlg] [winfo reqheight $dlg]
	wm resizable $dlg true false
	wm title $dlg $mc::SetupEngines
#	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $list
}


proc openEngineLog {parent} {
	if {[logIsOpen? $parent]} { return }
	if {$parent eq "."} { set dlg .engineLog } else { set dlg $parent.engineLog }
	tk::toplevel $dlg -class Scidb
	set top [ttk::frame $dlg.top -takefocus 0]
	tk::text $top.text \
		-width 80 \
		-height 40 \
		-yscrollcommand [list $top.vsb set] \
		-xscrollcommand [list $top.hsb set] \
		-wrap none \
		-setgrid 1 \
		-state disabled \
		;
	$top.text tag configure error -foreground darkred
	$top.text tag configure in -foreground darkgreen
	$top.text tag configure out -foreground black
	::scidb::engine::log open [namespace current]::Log $top.text
	ttk::scrollbar $top.hsb -orient horizontal -command [list $top.text xview]
	ttk::scrollbar $top.vsb -orient vertical -command [list ::widget::textLineScroll $top.text]
	pack $top -expand yes -fill both
	grid $top.text -row 1 -column 1 -sticky nsew
	grid $top.hsb  -row 2 -column 1 -sticky ew
	grid $top.vsb  -row 1 -column 2 -sticky ns
	grid rowconfigure $top 1 -weight 1
	grid columnconfigure $top 1 -weight 1
	::widget::dialogButtons $dlg {close clear} -default clear
	$dlg.close configure -command [namespace code [list CloseLog $dlg]]
	$dlg.clear configure -command [namespace code [list ClearLog $top.text]]
	wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
	wm title $dlg $mc::EngineLog
	wm deiconify $dlg
}


proc logIsOpen? {parent} {
	if {$parent eq "."} { set dlg .engineLog } else { set dlg $parent.engineLog }
	return [winfo exists $dlg]
}


proc engines {} {
	variable Engines

	set list {}

	foreach entry $Engines {
		array set opts $entry
		lappend list [list $opts(Name) $opts(LastUsed)]
	}

	# TODO
	# write own sorting routine because we have to take
	# unicode characters into account.
	set entries [lsort  -dictionary -index 0 $list]
	set entries [lsort -integer -index 1 $entries]
	set list {}
	foreach entry $entries { lappend list [lindex $entry 0] }
	return $list
}


# proc EngineDictionary {list} {
# 	variable Priv
# 	variable _Name
# 
# 	set dlg [tk::toplevel $list.newEngine -class Scidb]
# 	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
# 	wm withdraw $dlg
# 	pack $top
# 
# 	set lb [::tlistbox $top.list \
# 		-height 15 \
# 		-borderwidth 1 \
# 		-relief sunken \
# 		-selectmode browse \
# 		-stripes #ebf4f5 \
# 		-linespace 18 \
# 	]
# 	bind $lb <<ListboxSelect>> [namespace code [list SetEngine %d]]
# 	$lb addcol text  -id name -header $mc::Name
# 	$lb addcol text  -id elo -justify right -foreground darkgreen -header "Elo"
# 	$lb addcol text  -id ccrl -justify right -foreground darkgreen -header "CCRL"
# 	$lb addcol image -id chess960 -header "960"
# 	$lb addcol image -id shuffle -header "Shuffle"
# 
# 	set en [ttk::entry $top.name -textvar [namespace current]::_Name]
# 
# 	if {[llength $Priv(engines)] == 0} {
# 		# TODO
# 		# write own sorting routine because we have to take
# 		# unicode characters into account.
# 		set Priv(engines) [lsort -dictionary -unique [::scidb::engine::list]]
# 	}
# 
# 	foreach entry $Priv(engines) {
# 		set result [::scidb::engine::info $entry]
# 		lassign {0 0 "" ""} elo ccrl chess960 shuffle
# 		if {[llength $result]} {
# 			lassign $result _ _ elo ccrl _ _ chess960Flag shuffleFlag
# 			if {$shuffleFlag} { set shuffle $::icon::16x16::checkGreen }
# 			if {$chess960Flag} { set chess960 $::icon::16x16::checkBlue }
# 		}
# 		if {$elo == 0} { set elo "" }
# 		if {$ccrl == 0} { set ccrl "" }
# 		$lb insert [list $entry $elo $ccrl $chess960 $shuffle]
# 	}
# 
# 	$lb resize
# 
# 	grid $lb -row 1 -column 1 -sticky ew
# 	grid $en -row 3 -column 1 -sticky ew
# 
# 	grid columnconfigure $top {0 2} -minsize $::theme::padx
# 	grid rowconfigure $top {0 2} -minsize $::theme::pady
# 
# 	::widget::dialogButtons $dlg {ok cancel}
# 	$dlg.ok configure -command [namespace code [list MakeNewEngine $dlg $list]]
# 	$dlg.cancel configure -command [list destroy $dlg]
# 
# 	wm resizable $dlg false false
# 	wm title $dlg $mc::SelectEngine
# 	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
# 	wm transient $dlg [winfo toplevel $list]
# 	::util::place $dlg center [winfo toplevel $list]
# 	wm deiconify $dlg
# 
# 	if {[llength $Priv(engines)]} {
# 		focus $lb
# 		$lb select 0
# 	} else {
# 		focus $en
# 	}
# 
# 	::ttk::grabWindow $dlg
# 	tkwait window $dlg
# 	::ttk::releaseGrab $dlg
# }
# 
# 
# proc SetEngine {index} {
# 	variable Priv
# 	variable _Name
# 
# 	set _Name [lindex $Priv(engines) $index]
# }


proc setup {} {
	variable Engines
	variable Engine

	set Engine(empty) {
		Name				""
		ShortId			""
		Identifier		""
		Author			""
		Country			""
		Elo				0
		CCRL				0
		Command			""
		Parameters		{}
		Logo				""
		Url				""
		Protocol			""
		Variant			standard
		LastUsed			0
		Frequency		0
		Features:UCI	{}
		Features:WB		{}
		Options:UCI		{}
		Options:WB		{}
		Timestamp		0
		FileTime			0
	}

	if {[file readable $::scidb::file::engines]} {
		::load::source $::scidb::file::engines -message $::load::mc::ReadingFile(engines) -encoding utf-8
	} else {
		set Engines {
			{
				Name				Stockfish
				ShortId			Stockfish
				Identifier		"Stockfish 120903"
				Author			"Tord Romstad, Marco Costalba & Joona Kiiski"
				Country			""
				Elo				0
				CCRL				0
				Command			stockfish-120903
				Parameters		{}
				Logo				""
				Url				http://www.stockfishchess.com
				Protocol			UCI
				Variant			chess960
				LastUsed			0
				Frequency		0
				Features:UCI	{multiPV 500}
				Features:WB		{}
				Options:UCI		{
					{{Use Debug Log} check false false {} {}}
					{{Use Search Log} check false false {} {}}
					{{Search Log Filename} string SearchLog.txt SearchLog.txt {} {}}
					{{Book File} string book.bin book.bin {} {}}
					{{Best Book Move} check false false {} {}}
					{{Mobility (Middle Game)} spin 100 100 0 200}
					{{Mobility (Endgame)} spin 100 100 0 200}
					{{Passed Pawns (Middle Game)} spin 100 100 0 200}
					{{Passed Pawns (Endgame)} spin 100 100 0 200}
					{Space spin 100 100 0 200}
					{Aggressiveness spin 100 100 0 200}
					{Cowardice spin 100 100 0 200}
					{{Min Split Depth} spin 4 4 4 7}
					{{Max Threads per Split Point} spin 5 5 4 8}
					{Threads spin 4 4 1 32}
					{{Use Sleeping Threads} check true true {} {}}
					{Hash spin 32 32 4 8192}
					{{Clear Hash} button {} {} {} {}}
					{{Skill Level} spin 20 20 0 20}
					{{Emergency Move Horizon} spin 40 40 0 50}
					{{Emergency Base Time} spin 200 200 0 30000}
					{{Emergency Move Time} spin 70 70 0 5000}
					{{Minimum Thinking Time} spin 20 20 0 5000}
					{{Slow Mover} spin 100 100 10 1000}
				}
				Options:WB		{}
				Timestamp		0
				FileTime			0
			}
			{
				Name				Crafty
				ShortId			Crafty
				Identifier		Crafty-23.2a
				Author			"Dr. Robert M. Hyatt"
				Country			""
				Elo				0
				CCRL				0
				Command			crafty-32.2
				Parameters		{}
				Logo				""
				Url				ftp://ftp.cis.uab.edu/pub/hyatt
				Protocol			WB
				Variant			standard
				LastUsed			0
				Frequency		0
				Features:UCI	{}
				Features:WB		{}
				Options:UCI		{}
				Options:WB		{}
				Timestamp		0
				FileTime			0
			}
			{
				Name				"Toga II"
				ShortId			"Toga II"
				Identifier		"Toga II 1.3.1"
				Author			"Thomas Gaksch & Fabien Letouzey"
				Country			""
				Elo				0
				CCRL				0
				Command			fruit
				Parameters		{}
				Logo				""
				Url				http://www.superchessengine.com/toga_ii.htm
				Protocol			UCI
				Variant			standard
				LastUsed			0
				Frequency		0
				Features:UCI	{multiPV 10}
				Features:WB		{}
				Options:UCI		{
					{Hash spin 16 16 4 1024}
					{{Search Time} spin 0 0 0 3600}
					{{Search Depth} spin 0 0 0 20}
					{BookFile string performance.bin performance.bin {} {}}
					{{NullMove Pruning} combo Always Always {Always;Fail High;Never} {}}
					{{NullMove Reduction} spin 3 3 1 4}
					{{Verification Search} combo Always Always {Always;Endgame;Never} {}}
					{{Verification Reduction} spin 5 5 1 6}
					{{History Pruning} check true true {} {}}
					{{History Threshold} spin 70 70 0 100}
					{{Futility Pruning} check true true {} {}}
					{{Futility Margin} spin 100 100 0 500}
					{{Extended Futility Margin} spin 300 300 0 900}
					{{Delta Pruning} check true true {} {}}
					{{Delta Margin} spin 50 50 0 500}
					{{Quiescence Check Plies} spin 1 1 0 2}
					{Material spin 100 100 0 400}
					{{Piece Activity} spin 100 100 0 400}
					{{King Safety} spin 100 100 0 400}
					{{Pawn Structure} spin 100 100 0 400}
					{{Passed Pawns} spin 100 100 0 400}
					{{Toga Lazy Eval} check true true {} {}}
					{{Toga Lazy Eval Margin} spin 200 200 0 900}
					{{Toga King Safety} check false false {} {}}
					{{Toga King Safety Margin} spin 1700 1700 500 3000}
					{{Toga Extended History Pruning} check false false {} {}}
				}
				Options:WB		{}
				Timestamp		0
				FileTime			0
			}
			{
				Name				Phalanx
				ShortId			Phalanx
				Identifier		Phalanx
				Author			"Dusan Dobes"
				Country			""
				Elo				0
				CCRL				0
				Command			phalanx
				Parameters		-l-
				Logo				""
				Url				http://phalanx.sourceforge.net
				Protocol			WB
				Variant			standard
				LastUsed			0
				Frequency		0
				Features:UCI	{}
				Features:WB		{}
				Options:UCI		{}
				Options:WB		{}
				Timestamp		0
				FileTime			0
			}
			{
				Name				Micro-Max
				ShortId			Micro-Max
				Identifier		"micro-Max 4.8 (m)"
				Author			"H.G. Muller"
				Country			""
				Elo				0
				CCRL				0
				Command			micromax
				Parameters		{}
				Logo				""
				Url				http://home.hccnet.nl/h.g.muller/max-src2.html
				Protocol			WB
				Variant			standard
				LastUsed			0
				Frequency		0
				Features:UCI	{}
				Features:WB		{}
				Options:UCI		{}
				Options:WB		{}
				Timestamp		0
				FileTime			0
			}
		}

		set list $Engines
		set Engines {}

		foreach entry $list {
			array set arr $entry
			set arr(Directory) $::scidb::dir::user
			set arr(Command) "[file join $::scidb::dir::engines $arr(Command)]"

			if {[file executable $arr(Command)]} {
				set result [::scidb::engine::info $arr(ShortId)]
				if {[llength $result]} {
					lassign $result _ arr(Country) arr(Elo) arr(CCRL) uci wb chess960 shuffle
#					if {$uci && $wb} {
#						set arr(Protocol) UCI/WB
#						set arr(protocol) UCI
#					} elseif {$uci} {
#						set arr(Protocol) UCI
#						set arr(protocol) UCI
#					} elseif {$wb} {
#						set arr(Protocol) WB
#						set arr(protocol) WB
#					}
#					if {$shuffle} {
#						set arr(Variant) shuffle
#					} elseif {$chess960} {
#						set arr(Variant) chess960
#					}
				}

				file stat $arr(Command) st
				set arr(FileTime) $st(mtime)
				set arr(Timestamp) [clock seconds]
				lappend Engines [array get arr]
			}
		}
	}
}


proc CloseSetup {list} {
	if {[DiscardChanges $list]} {
		destroy [winfo toplevel $list]
	}
}


proc CloseLog {dlg} {
	::scidb::engine::log close
	destroy $dlg
}


proc ClearLog {text} {
	$text configure -state normal
	$text delete 1.0 end
	$text configure -state disabled
}


proc Log {text msg} {
	switch -- [string index $msg 0] {
		> { set tag out } 
		< { set tag in } 
		! { set tag error } 
		default { set tag out }
	}

	$text configure -state normal
	$text insert end [string range $msg 2 end] $tag
	$text configure -state disabled
	$text see end
}


proc Select {list item} {
	variable Engines
	variable Priv
	variable Photo
	variable Var

	if {$Priv(selection) >= 0} {
		array set engine [lindex $Engines $item]
		if {$Var(Name) eq $engine(Name)} { return }

		if {![DiscardChanges $list]} {
			$list select $Priv(selection)
			return
		}

		array set engine [lindex $Engines $Priv(selection)]
		set logo $engine(ShortId)
		if {[info exists Photo($logo)]} {
			$list set $Priv(selection) [list [lindex $Photo($logo) 1]]
		}
	}

	set Priv(selection) $item
	Fill $list [lindex $Engines $item]
	UpdateVars
}


proc DiscardChanges {list} {
	variable Var
	variable Var_
	variable Option
	variable Option_
	variable Engines
	variable Priv

	if {[llength $Engines] == 0} { return 1 }

	if {![arrayCompare Var Var_] || ![arrayCompare Option Option_]} {
		set rc [::dialog::question -parent [winfo toplevel $list] -message $mc::DiscardChanges]
		if {$rc eq "no"} { return 0 }
	}

	return 1
}


proc Fill {list entry} {
	variable Photo
	variable Priv
	variable Var

	array set engine $entry

	foreach attr [array names engine] {
		switch $attr {
			Protocol {
				switch -glob $engine(Protocol) {
					WB*	{ set Var(protocol) WB }
					UCI*	{ set Var(protocol) UCI }
				}
				switch $engine(Protocol) {
					WB {
						$Priv(button:UCI) configure -state disabled
						$Priv(button:WB) configure -state normal
					}
					UCI {
						$Priv(button:UCI) configure -state normal
						$Priv(button:WB) configure -state disabled
					}
					default {
						$Priv(button:UCI) configure -state normal
						$Priv(button:WB) configure -state normal
					}
				}
			}
			LastUsed {
				set t $engine(LastUsed)
				if {$t == 0} {
					set Var(LastUsed) $mc::NeverUsed
				} else {
					set Var(LastUsed) [::locale::formatNormalDate [::locale::timestampToTime $t]]
				}
			}
			Frequency {
				if {$engine(Frequency) == 0} {
					set Var(Frequency) $mc::NeverUsed
				} else {
					set Var(Frequency) $engine(Frequency)
				}
			}
			Country {
				$Priv(countrybox) set $engine(Country)
			}
			Variant {
				switch $engine(Variant) {
					standard	{ set Var(Variant) $mc::Variant(standard) }
					chess960	{ set Var(Variant) $mc::Variant(chess960) }
					shuffle	{ set Var(Variant) "$mc::Variant(chess960) / $mc::Variant(shuffle)" }
				}
			}
			Options:UCI - Options:WB {
				switch -glob $engine(Protocol) {
					WB*	{ set protocol WB }
					UCI*	{ set protocol UCI }
				}
				if {"Options:$protocol" eq $attr} {
					BuildOptionFrame $protocol $engine(Name) $engine(Options:$protocol)
				}
			}
			default {
				set Var($attr) $engine($attr)
			}
		}
	}

	set logo $engine(ShortId)
	if {[info exists Photo($logo)]} {
		$list set [list [lindex $Photo($logo) 2]]
	}

	if {$Priv(initialise)} {
		foreach attr [array names Var] {
			set args [list variable [namespace current]::Var($attr) write [namespace code VarChanged]]
			trace add {*}$args
			bind $list <Destroy> +[list trace remove {*}$args]
		}
		set Priv(initialise) 0
	}
}


proc VarChanged {args} {
	variable Option
	variable Option_
	variable Var
	variable Var_
	variable Priv

	if {[arrayCompare Var Var_] && [arrayCompare Option Option_]} {
		set state disabled
	} else {
		set state normal
	}
	$Priv(button:save) configure -state $state
}


proc BuildOptionFrame {protocol engineName options} {
	variable Option
	variable Priv

	set f $Priv(pane:options)
	grid rowconfigure $f $Priv(rows) -minsize 0
	set Priv(rows) {0}
	set slaves [grid slaves $f]
	if {[llength $slaves]} { destroy {*}$slaves }
	set row 1

	foreach opt $options {
		lassign $opt name type value dflt var max
		set lbl $f.lbl_$row
		set val $f.val_$row
		set sticky w

		if {$protocol eq "UCI" && $type eq "spin" && $max - $var <= 400} { set type slider }

		switch $type {
			spin {
				ttk::label $lbl -text $name
				set n [expr {max(1, max(abs($var), abs($max)))}]
				set width [expr {int(log10($n)) + 2}]
				ttk::frame $val -borderwidth 0 -takefocus 0
				ttk::spinbox $val.s -from $var -to $max -width $width -takefocus 1
				$val.s configure -textvar [namespace current]::Option($name)
				::validate::spinboxInt $val.s
				ttk::label $val.r -text "($var..$max)"
				grid $val.s -column 0 -row 0
				grid $val.r -column 2 -row 0
				grid columnconfigure $val {1} -minsize $::theme::padx
			}
			slider {
				ttk::label $lbl -text $name
				tk::scale $val \
					-orient horizontal \
					-from $var \
					-to $max \
					-showvalue yes \
					-takefocus 1 \
					-width 10 \
					-variable [namespace current]::Option($name) \
					-font TkTooltipFont \
					;
				::theme::enableScale $val
				if {$max - $var > 200} {
					$val configure -length 300
				} elseif {$max - $var > 20} {
					$val configure -length 200
				}
			}
			button {
				ttk::button $val \
					-text $name \
					-takefocus 1 \
					-command [namespace code [list SendAction $engineName $name]] \
					;
			}
			check {
				ttk::checkbutton $val \
					-text $name \
					-takefocus 1 \
					-variable [namespace current]::Option($name) \
					-offvalue false \
					-onvalue true \
					;
			}
			combo {
				ttk::label $lbl -text $name
				ttk::combobox $val \
					-values [Split $var] \
					-state readonly \
					-takefocus 1 \
					-textvar [namespace current]::Option($name)
					;
			}
			string {
				ttk::label $lbl -text $name
				ttk::entry $val -textvar [namespace current]::Option($name) -takefocus 1
				set sticky ew
			}
			file - path {
				ttk::label $lbl -text $name
				ttk::frame $val -borderwidth 0 -takefocus 0
				ttk::entry $val.e -textvar [namespace current]::Option($name) -takefocus 1
				tk::button $val.b \
					-text "..." \
					-background [::theme::getBackgroundColor] \
					-padx 2 \
					-pady 0 \
					-command [namespace code [list GetPath $type $name]] \
					;
				grid $val.e -column 0 -row 0
				grid $val.b -column 2 -row 0
				grid columnconfigure $val {1} -minsize $::theme::padx
				set sticky ew
			}
		}

		if {[winfo exists $val]} {
			if {$type ne "button"} {
				set btn $f.btn_$row
				ttk::button $btn \
					-image [::icon::makeStateSpecificIcons $::icon::12x12::reset] \
					-command [list set [namespace current]::Option($name) $dflt] \
					;
				::tooltip::tooltip $btn "$mc::ResetToDefault: $dflt"
				grid $btn -row $row -column 1
				set args [list variable [namespace current]::Option($name) write \
								[namespace code [list SetOptionState $name $dflt $btn]]]
				trace add {*}$args
				bind $btn <Destroy> [list trace remove {*}$args]
			}

			set Option($name) $value
			if {[winfo exists $lbl]} { $lbl configure -wraplength 200 }
			bind $val <FocusIn> [namespace code [list $Priv(scrolled:options) see %W]]
			bind $val <FocusIn> {+ ::tooltip::tooltip hide }
			if {[winfo exists $lbl]} { grid $lbl -row $row -column 3 -sticky w }
			lappend Priv(rows)
			grid $val -row $row -column 5 -sticky $sticky
			incr row
			if {$row ni $Priv(rows)} { lappend Priv(rows) $row }
			incr row
		}
	}

	if {[llength [grid slaves $f]]} {
		grid columnconfigure $f {0 2 4 6} -minsize $::theme::padx
		set state normal
	} else {
		set state disabled
	}
	set rows $Priv(rows)
	grid rowconfigure $f $Priv(rows) -minsize 15
	if {[llength $rows] > 2} {
		grid rowconfigure $f [list [lindex $rows 0] [lindex $rows end]] -minsize $::theme::pady
	}
	[winfo parent $Priv(tab:options)] tab $Priv(tab:options) -state $state
	$Priv(scrolled:options) yview moveto 0
}


proc SetOptionState {name dflt btn args} {
	variable Option

	VarChanged
	if {$Option($name) eq $dflt} { set state disabled } else { set state normal }
	$btn configure -state $state
}


proc Split {s} {
	set k 0
	set n [string first ";" $s]
	set result {}
	while {$n >= 0} {
		lappend result [string range $s $k [expr {$n - 1}]]
		set k [expr {$n + 1}]
		set n [string first ";" $s $k]
	}
	lappend result [string range $s $k end]
	return $result
}


proc RebuildEngineList {list} {
	variable Engines
	variable Photo
	variable PhotoFiles
	variable Logo
	variable Priv

	set resize 0
	if {[llength [$list columns]] == 0} {
		$list addcol image -id icon -width $Logo(width)
		set resize 1
	}

	$list clear

	set i 0
	foreach entry $Engines {
		array set opts $entry
		set logo $opts(ShortId)

		if {[info exists Photo($logo)]} {
			$list insert [list [lindex $Photo($logo) 1]]
		} else {
			set photoFile $opts(Logo)
			if {![file readable $photoFile]} {
				set photoFile [::util::photos::findPhotoFile $opts(ShortId)]
				if {[string length $photoFile] == 0} {
					set photoFile [::util::photos::findPhotoFile [file tail $opts(Command)]]
				}
			}

			if {[string length $photoFile] && $photoFile ni $PhotoFiles} {
				lappend PhotoFiles [list $i $logo $photoFile]
			}

			$list insert [list $opts(Name)] -font TkCaptionFont
		}

		incr i
	}

#	if {$resize} {
		$list resize
#	}

	set Priv(selection) -1

	if {[llength $PhotoFiles]} {
		after cancel $Priv(after)
		set Priv(after) [after 100 [namespace code [list LoadPhotoFiles $list]]]
	}
}


proc ProbeEngine {parent entry} {
	array set engine $entry

	set protocol(0) WB
	set protocol(1) UCI
	set protocols {}
	array set features_UCI {}
	array set features_WB {}

	set wait [tk::toplevel $parent.wait -class Scidb]
	wm withdraw $wait
	pack [tk::frame $wait.f -border 2 -relief raised]
	pack [tk::label $wait.f.text -compound left -text "$mc::Probing..."] -padx 10 -pady 10
	wm resizable $wait no no
	wm transient $wait $parent
	::util::place $wait center $parent
	update idletasks
	::scidb::tk::wm noDecor $wait
	wm deiconify $wait
	::ttk::grabWindow $wait
	::widget::busyCursor on
	update idletasks

	for {set i 0} {$i < 2} {incr i} {
		# TODO: take parameters into account
		set res [::scidb::engine::probe $engine(Command) $::scidb::dir::log $protocol($i) 2000]

		switch [lindex $res 0] {
			failed - undecidable {}

			ok {
				set result $res
				set prot $protocol($i)
				lappend protocols $prot
				lassign $result _ engine(Identifier) engine(Author) \
					multiPV chess960 shuffle pause playOther engine(Options:$prot)
				if {$multiPV > 1} { set features_${prot}(multiPV) $multiPV }
				if {$pause} { set features_${prot}(pause) $pause }
				if {$playOther} { set features_${prot}(playOther) $playOther }
			}
		}
	}

	destroy $wait
	::widget::busyCursor off
	::ttk::releaseGrab $wait

	if {[lindex $res 0] eq "error"} {
		::dialog::error -parent $parent -message $mc::CannotOpenProcess
		return {}
	}
	if {[llength $protocols] == 0} {
		::dialog::error -parent $parent -message $mc::DoesNotRespond
		return {}
	}

	if {[llength $protocols] == 2} {
		set engine(Protocol) UCI/WB
		set engine(protocol) UCI
	} else {
		set engine(Protocol) [lindex $protocols 0]
		set engine(protocol) [lindex $protocols 0]
	}

	lassign $result _ engine(Identifier) engine(Author) multiPV chess960 shuffle pause playOther
	set engine(Author) [string map [list " and " " & "] $engine(Author)]
	set engine(Features:UCI) [array get features_UCI]
	set engine(Features:WB) [array get features_WB]
	if {$shuffle} {
		set engine(Variant) shuffle
	} elseif {$chess960} {
		set engine(Variant) chess960
	} else {
		set engine(Variant) standard
	}
	set parts [split $engine(Identifier) " -"]
	set result {}
	while {[llength $result] == 0 && [llength $parts] > 0} {
		set name [string trim [join $parts " "]]
		set result [::scidb::engine::info $name]
		set parts [lreplace $parts end end]
	}
	if {[llength $result]} {
		set engine(ShortId) $name
		if {[string length $engine(Name)] == 0} {
			set engine(Name) $engine(ShortId)
		}
		lassign $result _ country elo ccrl _ _ _ _
		if {$engine(Elo) == 0} { set engine(Elo) $elo }
		if {$engine(CCRL) == 0} { set engine(CCRL) $ccrl }
		if {[string length $engine(Country)] == 0} { set engine(Country) $country }
	} elseif {[string length $engine(Name)] == 0} {
		set engine(Name) $engine(Identifier)
	}

	return [array get engine]
}


proc SaveEngine {list} {
	variable Engines
	variable Option

	set sel [$list curselection]

	if {$sel >= 0} {
		array set engine [lindex $Engines $sel]
		set protocol ""
		switch -glob $engine(Protocol) {
			WB*	{ set protocol WB }
			UCI*	{ set protocol UCI }
		}
		if {[string length $protocol]} {
			set newOptions {}
			foreach opt $engine(Options:$protocol) {
				lset opt 2 $Option([lindex $opt 0])
				lappend newOptions $opt
			}
			set engine(Options:UCI) $newOptions
			lset Engines $sel [array get engine]
		}
	}

	set filename $::scidb::file::engines
	set f [open $filename.tmp "w"]
	fconfigure $f -encoding utf-8
	::options::writeHeader $f engines
	::options::writeItem $f [namespace current]::Engines
	close $f
	file rename -force $filename.tmp $filename
	UpdateVars
}


proc UpdateVars {} {
	variable Var
	variable Var_
	variable Option
	variable Option_
	variable Priv

	array set Var_ [array get Var]
	array set Option_ [array get Option]
	$Priv(button:save) configure -state disabled
}


proc DeleteEngine {list} {
	variable Engines
	variable Priv
	variable Var

	set sel [$list curselection]
	if {$sel < 0} { return 0 }

	set msg [format $mc::ReallyDelete $Var(Name)]
	set rc [::dialog::question -parent [winfo toplevel $list] -message $msg]
	if {$rc eq "no"} { return 0 }
	set Engines [lreplace $Engines $sel $sel]
	RebuildEngineList $list
	if {[llength $Engines]} {
		$list select 0
	} else {
		foreach attr [array names Var] {
			if {[string is integer -strict $Var($attr)]} {
				set Var($attr) 0
			} else {
				set Var($attr) {}
			}
		}
		$Priv(button:delete) configure -state disabled
		$Priv(button:save) configure -state disabled
		SetInfoPaneState disabled
	}

	return 1
}


proc SetInfoPaneState {state} {
	variable Priv

	foreach w [grid slaves $Priv(pane:setup)] {
		if {[string match *Frame [winfo class $w]]} {
			foreach w [winfo children $w] { $w configure -state $state }
		} else {
			$w configure -state $state
		}
	}
}


# proc FillCombobox {cb} {
# 	variable Priv
# 
# 	if {[llength $Priv(engines)] == 0} {
# 		# TODO
# 		# write own sorting routine because we have to take
# 		# unicode characters into account.
# 		set Priv(engines) [lsort -dictionary -unique [::scidb::engine::list]]
# 	}
# 
# 	$cb configure -values $Priv(engines)
# }


proc NewEngine {list} {
	variable Engines
	variable Engine
	variable Index_
	variable Button_
	variable Priv

	if {![DiscardChanges $list]} { return }

	set parent [winfo toplevel $list]
	set result [::dialog::openFile \
		-parent $parent \
		-class engine \
		-geometry last \
		-title $mc::SelectEngine \
		-initialdir $::scidb::dir::engines \
		-filetypes [list [list $mc::Executables {x}]] \
	]
	if {[llength $result] == 0} { return }
	set file [lindex $result 0]
	set newEntry $Engine(empty)

	set entries {}
	set numbers {}
	foreach entry $Engines {
		array set engine $entry
		if {$file eq $engine(Command)} { lappend entries $entry }
	}
	if {[llength $entries] > 0} {
		set dlg [tk::toplevel $parent.chooseCopy -class Scidb]
		set top [ttk::frame $dlg.top -takefocus 0]
		pack $top -fill both
		ttk::label $top.msg -text $mc::EngineAlreadyExists
		set cpy [ttk::labelframe $top.cpy -text $mc::CopyFromEngine]
		grid $top.msg -row 1 -column 1 -sticky w
		grid $top.cpy -row 3 -column 1 -sticky ew
		grid rowconfigure $top {2} -minsize 20
		grid rowconfigure $top {0 4} -minsize $::theme::pady
		grid columnconfigure $top {0 3} -minsize $::theme::padx
		set Index_ -1
		set i 0
		foreach entry $entries {
			array set engine $entry
			ttk::radiobutton $cpy.rb$i \
				-text $engine(Name) \
				-variable [namespace current]::Index_ \
				-value $i \
				;
			bind $cpy.rb$i <ButtonRelease-1> [namespace code [list UnsetRadiobutton $cpy.rb$i]]
			grid $cpy.rb$i -row [expr {$i + 1}] -column 1 -sticky w
			grid rowconfigure $cpy [expr {$i + 2}] -minsize $::theme::pady
			incr i
		}
		grid rowconfigure $cpy {0} -minsize $::theme::pady
		grid columnconfigure $cpy {0 3} -minsize $::theme::padx
		::widget::dialogButtons $dlg {ok cancel}
		$dlg.ok configure -command [list set [namespace current]::Button_ ok]
		$dlg.cancel configure -command [list set [namespace current]::Button_ cancel]
		wm resizable $dlg false false
		wm title $dlg $mc::ConfirmNewEngine
		wm protocol $dlg WM_DELETE_WINDOW {#}
		wm transient $dlg $parent
		::util::place $dlg center $parent
		wm deiconify $dlg
		focus $cpy.rb0
		::ttk::grabWindow $dlg
		tkwait variable [namespace current]::Button_
		::ttk::releaseGrab $dlg
		destroy $dlg
		if {$Button_ eq "cancel"} { return }
		if {$Index_ >= 0} { set newEntry [lindex $entries $Index_] }
	}

	array set engine $newEntry
	set engine(Command) $file
	set newEntry [ProbeEngine $parent [array get engine]]
	if {[llength $newEntry] == 0} { return }
	array set engine $newEntry

	set numbers {}
	foreach entry $Engines {
		array set e $entry
		if {$engine(Name) eq $e(Name)} {
			lappend numbers 1
		} elseif {[string match "$engine(Name) (\[0-9]*)" $e(Name)]} {
			if {[regexp {.*\(([0-9]+)\)$} $e(Name) _ n]} { lappend numbers $n }
		}
	}
	if {[llength $numbers]} {
		set n [lindex [lsort -integer $numbers] end]
		set engine(Name) "$engine(Name) ([expr {$n + 1}])"
	}

	lappend Engines [array get engine]
	RebuildEngineList $list
	SetInfoPaneState normal
	$list select end
	$list see end
	$Priv(button:delete) configure -state normal
	SaveEngine $list
}


proc UnsetRadiobutton {b} {
	$b instate {selected} {
		after idle [list set [namespace current]::Index_ -1]
	}
}


proc LoadPhotoFiles {list} {
	variable PhotoFiles
	variable Photo
	variable Logo
	variable Priv

	if {![winfo exists $list]} { return }

	lassign [lindex $PhotoFiles 0] item logo file
	set PhotoFiles [lreplace $PhotoFiles 0 0]
	MakePhotos $logo $file

	if {[info exists Photo($logo)]} {
		if {$item == $Priv(selection)} { set index 2 } else { set index 1 }
		$list set $item [lindex $Photo($logo) $index]
	}

	if {[llength $PhotoFiles]} {
		set Priv(after) [after 50 [namespace code [list LoadPhotoFiles $list]]]
	}
}


proc MakePhotos {logo file} {
	variable Logo
	variable Photo

	catch { image create photo -file $file } img
	if {![info exists img]} { return }

	set w [image width $img]
	set h [image height $img]
	if {$h > $Logo(height) || $w > $Logo(width)} {
		if {$w > $Logo(width)
			set h [expr {ceil((double($h)*$Logo(width))/double($w))}]
			set w $Logo(width)
		}
		if {$h > $Logo(height)} {
			set w [expr {ceil((double($w)*$Logo(height))/double($h))}]
			set h $Logo(height)
		}
		set tmp [image create photo -width $w -height $h]
		::scidb::tk::image copy $img $tmp
		image delete $img
		set img $tmp
	}
	set img2 [image create photo -width $w -height $h]
	::scidb::tk::image disable $img $img2 150
	set Photo($logo) [list $file $img $img2]
}


proc WebOpen {parent} {
	variable Var

	if {[string length $Var(Url)]} {
		::web::open $parent $Var(Url)
	}
}


proc ClearLastUsed {list} {
	variable Var
	variable Engines

	set sel [$list curselection]
	array set engine [lindex $Engines $sel]
	set Var(LastUsed) 0
	set engine(LastUsed) 0
	lset Engines $sel [array get engine]
	Fill $list [lindex $Engines $sel]
}


proc ClearFrequency {list} {
	variable Var
	variable Engines

	set sel [$list curselection]
	array set engine [lindex $Engines $sel]
	set Var(Frequency) 0
	set engine(Frequency) 0
	lset Engines $sel [array get engine]
	Fill $list [lindex $Engines $sel]
}


proc SetLogo {list} {
	variable Engines
	variable Photo
	variable Priv
	variable Var

	array set engine [lindex $Engines $Priv(selection)]
	set logo $engine(ShortId)
	set file $Var(Logo)

	if {[file readable $file]} {
		set Var(Logo) $file
	} else {
		set file [::util::photos::findPhotoFile $logo]
		if {[string length $file] == 0} {
			set file [::util::photos::findPhotoFile [file tail $engine(Command)]]
		}
	}

	if {[info exists Photo($logo)] && $Photo($logo) eq $file} { return }

	array unset Photo $logo
	MakePhotos $logo $file

	if {[info exists Photo($logo)]} {
		set content [list [lindex $Photo($logo) 2]]
	} else {
		set content $engine(Name)
	}

	set engine(Logo) $Var(Logo)
	lset Engines $Priv(selection) [array get engine]
	$list set $Priv(selection) $content
}


proc GetLogo {parent list} {
	variable Var

	set result [::dialog::openFile \
		-parent $parent \
		-class image \
		-filetypes [list [list $mc::ImageFiles {.gif .jpeg .jpg .png .ppm}]] \
		-geometry last \
		-title $mc::SelectEngineLogo \
	]

	if {[llength $result]} {
		set Var(Logo) [lindex $result 0]
		SetLogo $list
	}
}


proc GetCommand {parent} {
	set result [::dialog::openFile \
		-parent $parent \
		-class engine \
		-geometry last \
		-title $mc::SelectEngine \
		-initialdir $::scidb::dir::engines \
		-filetypes [list [list $mc::Executables {x}]] \
	]
}


proc WriteOptions {chan} {
	options::writeList $chan [namespace current]::Engines
}

#::options::hookWriter [namespace current]::WriteOptions engines

} ;# namespace engine

# vi:set ts=3 sw=3:
