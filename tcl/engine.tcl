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

set Information			"Information"
set Features				"Features"
set Options					"Options"

set Name						"Name"
set Identifier				"Identifier"
set Author					"Author"
set Webpage					"Webpage"
set Email					"Email"
set Country					"Country"
set Rating					"Rating"
set Logo						"Logo"
set Protocol				"Protocol"
set Parameters				"Parameters"
set Command					"Command"
set Directory				"Directory"
set Variants				"Variants"
set LastUsed				"Last used"

set Variant(standard)	"Standard Chess"
set Variant(chess960)	"Chess 960"
set Variant(shuffle)		"Shuffle Chess"

set SetupEngines			"Setup Egines"
set ImageFiles				"Image files"
set SelectEngine			"Select Engine"
set SelectEngineLogo		"Select Engine Logo"
set EngineLog				"Engine Console"
set Probing					"Probing"
set NeverUsed				"never used"
set OpenFsbox				"Open File Selection Dialog"
set ResetToDefault		"Reset to default"
set ShowInfo				"Show \"Info\""
set TotalUsage				"%s times in total"

set ConfirmNewEngine		"Confirm new engine"
set EngineAlreadyExists	"An entry with this engine already exists."
set CopyFromEngine		"Make a copy of entry"
set CannotOpenProcess	"Cannot start process."
set DoesNotRespond		"This engine does not respond either to UCI nor to XBoard/WinBoard protocol."
set DiscardChanges		"The current item has changed.\n\nReally discard changes?"
set ReallyDelete			"Really delete engine '%s'?"
set EntryAlreadyExists	"An entry with name '%s' already exists."
set NoFeaturesAvailable	"This engine does not provide any feature, not even an analyze mode is available. You cannot use this engine for the analysis of positions."

set FeatureDetail(analyze)			"This engine provides an analyze mode."
set FeatureDetail(multiPV)			"Allows you to see the engine evaluations and principal variations (PVs) from the highest ranked candidate moves. This engines can show up to %s principal variations."
set FeatureDetail(pause)			"This provides a proper handling of pause/resume: the engine does not think, ponder, or otherwise consume significant CPU time. The current thinking or pondering (if any) is suspended and both player's clocks are stopped."
set FeatureDetail(playOther)		"The engine is capable to play your move. Your clock wiil run while the engine is thinking about your move."
set FeatureDetail(hashSize)		"This feature allows to inform the engine on how much memory it is allowed to use maximally for the hash tables. This engine allows a range between %min and %max MB."
set FeatureDetail(clearHash)		"The user may clear the hash tables whlle the engine is running."
set FeatureDetail(threads)			"It allows you to configure the number of threads the chess engine will use during its thinking. This engine is using between %min and %max threads."
set FeatureDetail(limitStrength)	"The engine is able to limit its strength to a specific Elo number between %min-%max."
set FeatureDetail(skillLevel)		"The engine provides the possibility to lower the skill down, where it can be beaten quite easier."
set FeatureDetail(ponder)			"Pondering is simply using the user's move time to consider likely user moves and thus gain a pre-processing advantage when it is our turn to move, also referred as Permanent brain."
set FeatureDetail(chess960)		"Chess960 (or Fischer Random Chess) is a variant of chess. The game employs the same board and pieces as standard chess, but the starting position of the pieces along the players' home ranks is randomized, with a few restrictions which preserves full castling options in all starting positions, resulting in 960 unique positions."
set FeatureDetail(shuffle)			"This is the parent variant of Chess960. No additional rules on the back rank shuffles, castling only possible when king and rook are on their traditional starting squares."
set FeatureDetail(playingStyle)	"This engine provides different playing styles, namely %s. See the handbook of the engine for an explanation of the different styles."

# don't translate
set Feature(analyze)			"Analyze"
set Feature(multiPV)			"Multiple Best Lines"
set Feature(pause)			"Pause"
set Feature(playOther)		"Play Other"
set Feature(hashSize)		"Hash Size"
set Feature(clearHash)		"Clear Hash"
set Feature(threads)			"Threads"
set Feature(limitStrength)	"Limit Strength"
set Feature(skillLevel)		"Skill Level"
set Feature(ponder)			"Pondering"
set Feature(chess960)		"Chess960"
set Feature(shuffle)			"Shuffle Chess"
set Feature(playingStyle)	"Playing Styles"

} ;# namespace mc

set EmptyEngine {
	Name				""
	ShortId			""
	Identifier		""
	Author			""
	Email				""
	Country			""
	Elo				0
	CCRL				0
	Command			""
	Directory		""
	Parameters		""
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

variable Engines {}
variable PhotoFiles {}

array set Priv { after {}  }
array set Logo { width 100 height 54 }


proc openSetup {parent} {
	variable Engines
	variable Logo
	variable Priv
	variable Option
	variable Option_
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
	set Priv(uniform) {1}
	set Priv(html) ""

	array set Var {}
	array set Var_ {}
	array set Option {}
	array set Option_ {}

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
	bind $nb <<NotebookTabChanged>> [namespace code TabChanged]

	### Tab: Setup ########################################################
	set setup [ttk::frame $nb.setup -takefocus 0 -borderwidth 0]
	$nb add $setup -sticky nsew -text $mc::Information -padding {5 5}
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
	ttk::label			$setup.lemail -text $mc::Email
	ttk::entry			$setup.eemail -textvar [namespace current]::Var(Email)

	ttk::label			$setup.lidentifier -text $mc::Identifier
	ttk::label			$setup.tidentifier -textvar [namespace current]::Var(Identifier) {*}$labelOptions
	ttk::label			$setup.lvariants -text $mc::Variants
	ttk::label			$setup.tvariants -textvar [namespace current]::Var(variant) {*}$labelOptions
	ttk::label			$setup.llastused -text $mc::LastUsed
	ttk::label			$setup.tlastused -textvar [namespace current]::Var(lastused) {*}$labelOptions
	ttk::button			$setup.blastused \
								-style icon.TButton \
								-image $::icon::12x12::eraser \
								-command [namespace code [list ClearLastUsed $list]] \
								;

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

	ttk::label			$setup.lurl -text $mc::Webpage
	ttk::entry			$setup.eurl -textvar [namespace current]::Var(Url)
	ttk::button			$setup.burl \
								-style icon.TButton \
								-image $::icon::16x16::internet \
								-command [namespace code [list WebOpen $dlg]] \
								;
	ttk::label			$setup.llogo -text $mc::Logo
	ttk::entry			$setup.elogo -textvar [namespace current]::Var(Logo)
	ttk::button			$setup.blogo \
								-style icon.TButton \
								-image $::fsbox::icon::16x16::folder \
								-command [namespace code [list GetLogo $dlg $list]] \
								;

	ttk::label			$setup.lcommand -text $mc::Command
	ttk::label			$setup.tcommand -textvar [namespace current]::Var(Command) {*}$labelOptions
	ttk::label			$setup.ldirectory -text $mc::Directory
	ttk::entry			$setup.edirectory -textvar [namespace current]::Var(Directory)
	ttk::button			$setup.bdirectory \
								-style icon.TButton \
								-image $::fsbox::icon::16x16::folder \
								-command [namespace code [list GetDirectory $dlg $list]] \
								;
	ttk::label			$setup.lparams -text $mc::Parameters
	ttk::entry			$setup.eparams -textvar [namespace current]::Var(Parameters)

	::tooltip::tooltip $setup.burl ::playercard::mc::OpenInWebBrowser
	::tooltip::tooltip $setup.blastused $::mc::Clear
	::tooltip::tooltip $setup.blogo $mc::OpenFsbox
	::tooltip::tooltip $setup.bdirectory $::dialog::fsbox::mc::Title(dir)
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
	grid $setup.ename			-row  1 -column 3 -sticky we
	grid $setup.lauthor		-row  3 -column 1 -sticky w
	grid $setup.eauthor		-row  3 -column 3 -sticky we
	grid $setup.lemail		-row  5 -column 1 -sticky w
	grid $setup.eemail		-row  5 -column 3 -sticky we

	grid $setup.lidentifier	-row  7 -column 1 -sticky w
	grid $setup.tidentifier	-row  7 -column 3 -sticky we
	grid $setup.lvariants   -row  9 -column 1 -sticky w
	grid $setup.tvariants   -row  9 -column 3 -sticky we
	grid $setup.llastused	-row 11 -column 1 -sticky w
	grid $setup.tlastused	-row 11 -column 3 -sticky we
	grid $setup.blastused	-row 11 -column 5 -sticky we

	grid $setup.lcountry		-row 13 -column 1 -sticky w
	grid $setup.ccountry		-row 13 -column 3 -sticky we
	grid $setup.lrating		-row 15 -column 1 -sticky w
	grid $setup.frating		-row 15 -column 3 -sticky w
	grid $setup.lprotocol	-row 17 -column 1 -sticky w
	grid $setup.fprotocol	-row 17 -column 3 -sticky w

	grid $setup.lurl			-row 19 -column 1 -sticky w
	grid $setup.eurl			-row 19 -column 3 -sticky we
	grid $setup.burl			-row 19 -column 5 -sticky we
	grid $setup.llogo			-row 21 -column 1 -sticky w
	grid $setup.elogo			-row 21 -column 3 -sticky we
	grid $setup.blogo			-row 21 -column 5 -sticky we

	grid $setup.lcommand		-row 23 -column 1 -sticky w
	grid $setup.tcommand		-row 23 -column 3 -sticky we
	grid $setup.ldirectory	-row 25 -column 1 -sticky w
	grid $setup.edirectory	-row 25 -column 3 -sticky we
	grid $setup.bdirectory	-row 25 -column 5 -sticky we
	grid $setup.lparams		-row 27 -column 1 -sticky w
	grid $setup.eparams		-row 27 -column 3 -sticky we

	grid columnconfigure $setup {0 2 4 6} -minsize $::theme::padx
	grid columnconfigure $setup {3} -weight 1
	grid rowconfigure $setup {0 2 4 8 10 14 16 16 20 24 26 28} -minsize $::theme::pady
	grid rowconfigure $setup {6 12 18 22} -minsize [expr {3*$::theme::pady}] -weight 1

	bind $list <<ListboxSelect>> [namespace code [list Select $list %d]]

	### Tab: Features #####################################################
	set features $nb.features
	set css [::html::defaultCSS [::font::htmlFixedFamilies] [::font::htmlTextFamilies]]
	::html $nb.features \
		-imagecmd [namespace code GetImage] \
		-center no \
		-fittowidth yes \
		-width 0 \
		-height 0 \
		-borderwidth 1 \
		-relief sunken \
		-doublebuffer no \
		-exportselection yes \
		-cursor left_ptr \
		-showhyphens no \
		-css $css \
		-usehorzscroll no \
		-usevertscroll yes \
		-takefocus 0 \
		;
	$nb add $features -sticky nsew -text $mc::Features -padding {5 5}

	### Tab: Options ######################################################
	set options $nb.options
	set scrolled [::scrolledframe $options \
		-background [::theme::getBackgroundColor] \
		-borderwidth 1 \
		-relief sunken \
	]
	$nb add $options -sticky nsew -text $mc::Options -padding {5 5}
	ttk::frame $scrolled.f -borderwidth 0
	grid $scrolled.f -sticky nsew

	### Variables ########################################################ä
	set Priv(tab:options) $options
	set Priv(pane:features) $features
	set Priv(scrolled:options) $scrolled
	set Priv(pane:options) $scrolled.f
	set Priv(pane:setup) $setup
	set Priv(notebook) $nb

	### Geoemetry #########################################################
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
	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $list
	::ttk::grabWindow $dlg
	tkwait visibility $dlg
	wm geometry $dlg [winfo width $dlg]x[winfo height $dlg]
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc openEngineLog {parent} {
	variable ShowInfo 0

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
	::widget::dialogButtons $dlg {close clear} -default clear -justify right -alignment left
	ttk::checkbutton $dlg.info \
		-textvar [namespace current]::mc::ShowInfo \
		-variable [namespace current]::ShowInfo \
		;
	::widget::dialogButtonsPack $dlg.info -justify left -position start
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
	variable EmptyEngine
	variable Engines

	set list {}

	foreach entry $Engines {
		array set engine $EmptyEngine
		array set engine $entry
		lappend list [list $engine(Name) $engine(LastUsed)]
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
# 		lassign {0 0 "" ""} elo ccrl chess960 shuffle url aliases
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

	if {[file readable $::scidb::file::engines]} {
		::load::source $::scidb::file::engines -message $::load::mc::ReadingFile(engines) -encoding utf-8
	} else {
		set Engines {
			{
				Name				Stockfish
				ShortId			Stockfish
				Identifier		"Stockfish 2.3"
				Author			"Tord Romstad, Marco Costalba & Joona Kiiski"
				Command			stockfish-120903
				Protocol			UCI
				Variant			chess960
				Features:UCI	{
					analyze true
					multiPV 500
					ponder true
					hashSize {4 8192}
					threads {4 32}
					skillLevel {0 20}
					clearHash true
				}
				Options:UCI		{
					{{Use Debug Log} check false false {} {}}
					{{Use Search Log} check false false {} {}}
					{{Search Log Filename} file SearchLog.txt SearchLog.txt {} {}}
					{{Book File} file book.bin book.bin {} {}}
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
			}
			{
				Name				Crafty
				ShortId			Crafty
				Identifier		Crafty-23.2a
				Author			"Dr. Robert M. Hyatt"
				Command			crafty-32.2
				Protocol			WB
				Features:WB		{analyze true playOther true}
			}
			{
				Name				"Toga II"
				ShortId			"Toga II"
				Identifier		"Toga II 1.3.1"
				Author			"Thomas Gaksch & Fabien Letouzey"
				Command			fruit
				Protocol			UCI
				Features:UCI	{analyze true multiPV 10 ponder true hashSize {4 1024}}
				Options:UCI		{
					{Hash spin 16 16 4 1024}
					{{Search Time} spin 0 0 0 3600}
					{{Search Depth} spin 0 0 0 20}
					{BookFile file performance.bin performance.bin {} {}}
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
			}
			{
				Name				Phalanx
				ShortId			Phalanx
				Identifier		Phalanx
				Author			"Dusan Dobes"
				Command			phalanx
				Parameters		-l-
				Protocol			WB
				Features:WB		{analyze true}
			}
			{
				Name				Micro-Max
				ShortId			Micro-Max
				Identifier		"micro-Max 4.8 (m)"
				Author			"H.G. Muller"
				Command			micromax
				Protocol			WB
			}
		}

		set list $Engines
		set Engines {}

		foreach entry $list {
			array unset engine
			array set engine $entry
			set engine(Command) "[file join $::scidb::dir::engines $engine(Command)]"

			if {[file executable $engine(Command)]} {
				set result [::scidb::engine::info $engine(Name)]
				if {[llength $result]} {
					lassign $result _ Country _ CCRL _ _ _ _ Url _
					# We don't like to set the ELO value
					foreach attr {Country CCRL Url} {
						set engine($attr) [set $attr]
					}
				}
				file stat $engine(Command) st
				set engine(FileTime) $st(mtime)
				set engine(Timestamp) [clock seconds]
				lappend Engines [array get engine]
return
			}
		}
	}
}


proc startEngine {name isReadyCmd signalCmd updateCmd} {
	variable EmptyEngine
	variable Engines
	variable Priv

	set index [FindIndex $name]
	if {$index == -1} { return -1 }

	set entry [lindex $Engines $index]
	array set engine $EmptyEngine
	array set engine $entry

	set protocol [lindex $engine(Protocol) 0]
	if {[string length $engine(Directory)] && [file isdirectory $engine(Directory)]} {
		set dir $engine(Directory)
	} else {
		set dir $::scidb::dir::log
	}
	set engine(LastUsed) [clock seconds]
	incr engine(Frequency)
	lset Engines $index [array get engine]
	::options::hookWriter [namespace current]::WriteOptions engines
	set id [::scidb::engine::start \
		$engine(Command) \
		$dir \
		$protocol \
		$isReadyCmd \
		$signalCmd \
		$updateCmd \
	]
	set Priv(engine:$id) $engine(Name)
	return $id
}


proc activateEngine {engineId features} {
	variable EmptyEngine
	variable Engines
	variable Priv

	if {$engineId == -1} { return }
	set index [FindIndex $Priv(engine:$engineId)]
	if {$index == -1} { return }
	array set engine $EmptyEngine
	array set engine [lindex $Engines $index]
	array set featureArr { analyze false }
	array set featureArr $features
	set protocol [lindex $engine(Protocol) 0]
	array set engineFeatures $engine(Features:$protocol)
	if {[info exists engineFeatures(analyze)]} { set featureArr(analyze) true }
	::scidb::engine::setOptions $engineId $engine(Options:$protocol)
	::scidb::engine::setFeatures $engineId [array get featureArr]
	::scidb::engine::activate $engineId
}


proc startAnalysis {engineId} {
	if {$engineId != -1} {
		::scidb::engine::analyze start $engineId
	}
}


proc stopAnaylsis {engineId} {
	if {$engineId != -1} {
		::scidb::engine::analyze stop $engineId
	}
}


proc pause {engineId} {
	if {$engineId != -1} {
		::scidb::engine::pause $engineId
	}
}


proc resume {engineId} {
	if {$engineId != -1} {
		::scidb::engine::resume $engineId
	}
}


proc kill {engineId} {
	if {$engineId != -1} {
		::scidb::engine::kill $engineId
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
	variable ShowInfo
	variable Priv

	switch -- [string index $msg 0] {
		"<" {
			if {!$ShowInfo && [string match {< info *} $msg]} {
				return
			}
			set msg [string range $msg 2 end]
			if {!$ShowInfo && [string is integer -strict [string index [string trimleft $msg] 0]]} {
				return
			}
			set tag in
		} 
		">" {
			set tag out
		}
		"!" {
			set msg [string range $msg 2 end]
			set tag error
		} 
		"@" {
			set msg "FATAL: [string range $msg 2 end]"
			set tag error
		}
		default {
			set tag out
		}
	}

	$text configure -state normal
	$text insert end $msg $tag
	$text configure -state disabled
	$text see end
}


proc Select {list item} {
	variable Engines
	variable EmptyEngine
	variable Priv
	variable Photo
	variable Var

	if {[llength $item] == 0} { return }

	if {$Priv(selection) >= 0} {
		array set engine $EmptyEngine
		array set engine [lindex $Engines $item]
		if {$Var(Name) eq $engine(Name)} { return }

		if {![DiscardChanges $list]} {
			$list select $Priv(selection)
			return
		}

		array set engine $EmptyEngine
		array set engine [lindex $Engines $Priv(selection)]
		set logo $engine(ShortId)
		if {[info exists Photo($logo)]} {
			$list set $Priv(selection) [list [lindex $Photo($logo) 1]]
		}
	}

	set Priv(selection) $item
	set entry [lindex $Engines $item]
	array set engine $EmptyEngine
	array set engine $entry
	FillInfo $list $entry
	set features $engine(Features:[lindex $engine(Protocol) 0])
	if {$engine(Variant) ne "standard"} {
		lappend features $engine(Variant) true
	}
	ShowFeatures $list $features
	TabChanged
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


proc ShowFeatures {list features} {
	variable Priv

	if {"shuffle" in $features} { lappend features chess960 true }

	append html "<html>"
	append html "<head><style type='text/css'>body { background-color: #ffdd76; }</style></head>"
	append html "<body>"

	if {[llength $features] == 0} {
		append html "<h3>$mc::NoFeaturesAvailable</h3>"
		append html "<p align='center'><img src='Smiley-Cry-128x128.png' style='padding-top: 50px;' /></p>"
	} else {
		append html "<table cellpadding='5'>"

		foreach {name value} $features {
			append html "<tr><td style='white-space:nowrap;' valign='top'><b>$mc::Feature($name)</b></td>"

			switch $name {
				analyze - pause - playOther - clearHash - ponder - chess960 - shuffle - skillLevel {
					append html "<td>$mc::FeatureDetail($name)</td>"
				}
				multiPV {
					append html "<td>[format $mc::FeatureDetail($name) $value]</td>"
				}
				hashSize - limitStrength - threads {
					set map [list %min [lindex $value 0] %max [lindex $value 1]]
					append html "<td>[string map $map $mc::FeatureDetail($name)]</td>"
				}
				playingStyle {
					set styles {}
					foreach entry $value { lappend styles "\"$entry\"" }
					set values [join $styles ", "]
					append html "<td>[format $mc::FeatureDetail($name) $values]</td>"
				}
			}

			append html "</tr>"
		}

		append html "</table>"
	}

	append html "</body>"
	append html "</html>"
	set Priv(html) $html
}


proc TabChanged {} {
	variable Priv

	if {[string length $Priv(html)] && [$Priv(notebook) select] eq $Priv(pane:features)} {
		$Priv(pane:features) parse $Priv(html)
		set Priv(html) ""
	}
}


proc GetImage {file} {
	set img ""
	catch { set img [image create photo -file [file join $::scidb::dir::images $file]] }
	return $img
}


proc FillInfo {list entry} {
	variable EmptyEngine
	variable Photo
	variable Priv
	variable Var

	array set engine $EmptyEngine
	array set engine $entry

	foreach attr [array names engine] {
		switch $attr {
			Protocol {
				set Var(protocol) [lindex $engine(Protocol) 0]
				$Priv(button:UCI) configure -state disabled
				$Priv(button:WB) configure -state disabled
				foreach prot $engine(Protocol) { $Priv(button:$prot) configure -state normal }
			}
			LastUsed {
				set time $engine(LastUsed)
				set freq $engine(Frequency)
				if {$time == 0} {
					set str $mc::NeverUsed
				} else {
					set str [::locale::formatTime [::locale::timestampToTime $time]]
				}
				if {$freq > 1} {
					append str " (" [format $mc::TotalUsage $freq] ")"
				}
				set Var(lastused) $str
			}
			Country {
				$Priv(countrybox) set $engine(Country)
			}
			Variant {
				switch $engine(Variant) {
					standard	{ set Var(variant) $mc::Variant(standard) }
					chess960	{ set Var(variant) $mc::Variant(chess960) }
					shuffle	{ set Var(variant) "$mc::Variant(chess960) / $mc::Variant(shuffle)" }
				}
			}
			Options:UCI - Options:WB {
				set protocol [lindex $engine(Protocol) 0]
				if {"Options:$protocol" eq $attr} {
					BuildOptionFrame $protocol $engine(Name) $engine(Options:$protocol) $engine(Directory)
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


proc BuildOptionFrame {protocol engineName options directory} {
	variable Option
	variable Priv

	set f $Priv(pane:options)
	grid rowconfigure $f $Priv(rows) -minsize 0
	grid rowconfigure $f $Priv(uniform) -uniform {}
	set Priv(rows) {0}
	set Priv(uniform) {1}
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
#				ttk::button $val \
#					-text $name \
#					-takefocus 1 \
#					-command [namespace code [list SendAction $engineName $name]] \
#					;
			}
			check {
				ttk::label $lbl -text $name
				ttk::checkbutton $val \
					-takefocus 1 \
					-variable [namespace current]::Option($name) \
					-offvalue false \
					-onvalue true \
					;
#				set args [list variable [namespace current]::Option($name) \
#					write [namespace code [list SetOnOff $val]]]
#				trace add {*}$args
#				bind $val <Destroy> [list trace remove {*}$args]
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
				ttk::button $val.b \
					-style icon.TButton \
					-image $::fsbox::icon::16x16::folder \
					-command [namespace code [list GetPath $type $name $dflt $directory]] \
					;
				grid $val.e -column 0 -row 0 -sticky we
				grid $val.b -column 2 -row 0
				grid columnconfigure $val {1} -minsize $::theme::padx
				grid columnconfigure $val {0} -weight 1
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
								[namespace code [list SetOptionState $val $name $dflt $btn]]]
				trace add {*}$args
				bind $btn <Destroy> [list trace remove {*}$args]
			}

			if {[winfo exists $lbl]} { $lbl configure -wraplength 200 }
			bind $val <FocusIn> [namespace code [list $Priv(scrolled:options) see %W]]
			bind $val <FocusIn> {+ ::tooltip::tooltip hide }
			if {[winfo exists $lbl]} { grid $lbl -row $row -column 3 -sticky w }
			lappend Priv(rows)
			grid $val -row $row -column 5 -sticky $sticky
			if {$row ni $Priv(uniform)} { lappend Priv(uniform) $row }
			incr row
			if {$row ni $Priv(rows)} { lappend Priv(rows) $row }
			incr row
		}

		set Option($name) $value
	}

	if {[llength [grid slaves $f]]} {
		grid columnconfigure $f {0 2 4 6} -minsize $::theme::padx
		set state normal
	} else {
		set state disabled
	}
	set rows $Priv(rows)
	grid rowconfigure $f $Priv(rows) -minsize 10
	grid rowconfigure $f $Priv(uniform) -uniform all
	if {[llength $rows] > 2} {
		grid rowconfigure $f [list [lindex $rows 0] [lindex $rows end]] -minsize $::theme::pady
	}
	[winfo parent $Priv(tab:options)] tab $Priv(tab:options) -state $state
	$Priv(scrolled:options) yview moveto 0
}


proc GetPath {type name dflt dir} {
	variable Option
	variable Priv

	set ext [file extension $dflt]
	set suf [string range $ext 1 end]
	set ft  ""

	if {[info exists ::dialog::fsbox::mc::FileType($suf)]} {
		set ft $::dialog::fsbox::mc::FileType($suf)
	}

	if {$ext eq ".bin"} { set checkexistence yes } else { set checkexistence no }
	if {[string length $dir] == 0} { set dir $::scidb::dir::home }

	set result [::dialog::openFile \
		-parent $Priv(pane:options) \
		-initialdir $dir \
		-initialfile $dflt \
		-filetypes [list [list $ft $ext]] \
		-needencoding no \
		-checkexistence $checkexistence \
		-geometry last \
	]

	if {[llength $result]} {
		if {[string length $dir] == 0} { set dir $::scidb::dir::user }
		set file [lindex $result 0]
		set path [file dirname $file]
		if {[string match $dir* $path]} {
			set file [string range $file [string length $dir] end]
			if {[string index $file 0] eq [file separator]} {
				set file [string range $file 1 end]
			}
		}
		set Option($name) $file
	}
}


proc SetOptionState {val name dflt btn args} {
	variable Option

	VarChanged
	if {$Option($name) eq $dflt} { set state disabled } else { set state normal }
	$btn configure -state $state
	if {[winfo class $val] eq "TCheckbutton"} {
		$val configure -text [expr {$Option($name) ? "true" : "false"}]
	}
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
	variable EmptyEngine
	variable Photo
	variable PhotoFiles
	variable Logo
	variable Priv

	if {[llength [$list columns]] == 0} {
		$list addcol image -id icon -minwidth $Logo(width) -font TkCaptionFont
	}

	$list clear

	set i 0
	foreach entry $Engines {
		array set engine $EmptyEngine
		array set engine $entry
		set logo $engine(ShortId)

		if {[info exists Photo($logo)]} {
			$list insert [list [lindex $Photo($logo) 1]]
		} else {
			set photoFile $engine(Logo)
			if {![file readable $photoFile]} {
				set photoFile [::util::photos::findPhotoFile $engine(ShortId)]
				if {[string length $photoFile] == 0} {
					set photoFile [::util::photos::findPhotoFile [file tail $engine(Command)]]
				}
			}

			if {[string length $photoFile] && $photoFile ni $PhotoFiles} {
				lappend PhotoFiles [list $i $logo $photoFile $engine(Name)]
				$list insert {}
			} else {
				$list insert [list $engine(Name)] -font TkCaptionFont
			}
		}

		incr i
	}

	$list resize
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
				set prot $protocol($i)
				set result($prot) $res
				lappend protocols $prot
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
		set engine(Protocol) {UCI WB}
	} else {
		set engine(Protocol) [lindex $protocols 0]
	}

	foreach prot $protocols {
		lassign $result($prot) ok info features options
if {$prot == "WB"} { puts "$prot: $options" }

		# setup information
		array set engine $info
		set engine(Author) [string map [list " and " " & "] $engine(Author)]
		set engine(Options:$prot) $options

		if {"shuffle" in $features} {
			set engine(Variant) shuffle
		} elseif {"chess960" in $features} {
			set engine(Variant) chess960
		} else {
			set engine(Variant) standard
		}

		array set fts $features
		array unset fts chess960
		array unset fts shuffle
		set engine(Features:$prot) [array get fts]
	}

	array unset result
	set result {}
	if {[string length $engine(Name)]} {
		set result [::scidb::engine::info $engine(Name)]
	} else {
		set engine(Name) $engine(Identifier)
	}
	if {[llength $result]} {
		lassign $result _ country _ ccrl _ _ _ _ url aliases
		set shortName $engine(Name)
		set n [string length $shortName]
		foreach alias $aliases {
			set a [string length $alias]
			if {$a + 3 < $n && $n > 14} {
				set shortName $alias
				set n $a
			}
		}
		set engine(Name) $shortName
		if {$engine(CCRL) == 0} { set engine(CCRL) $ccrl }
		if {[string length $engine(Country)] == 0} { set engine(Country) $country }
		if {[string length $engine(Url)] == 0} { set engine(Url) $url }
	}
	if {[string length $engine(ShortId)] == 0} {
		set engine(ShortId) $engine(Name)
	}

	return [array get engine]
}


proc SaveEngine {list} {
	variable Engines
	variable Option
	variable Var
	variable Priv

	set sel [$list curselection]

	if {$sel >= 0} {
		set i 0

		foreach entry $Engines {
			if {$i ne $sel} {
				array set engine $entry
				if {$Var(Name) eq $engine(Name)} {
					set msg [format $mc::EntryAlreadyExists $Var(Name)]
					::dialog::error -parent [winfo toplevel $list] -message $msg
					return
				}
			}
			incr i
		}

		array set engine [lindex $Engines $sel]

		foreach attr [array names engine] {
			switch $attr {
				Protocol {
					if {[llength $engine(Protocol)] == 2} {
						switch $Var(protocol) {
							WB		{ set engine(Protocol) {WB UCI} }
							UCI	{ set engine(Protocol) {UCI WB} }
						}
					} else {
						set engine(Protocol) $Var(protocol)
					}
				}
				Country {
					set engine(Country) [$Priv(countrybox) get]
				}
				Variant - Options:UCI - Options:WB {
					;# alreay set
				}
				default {
					if {[info exists Var($attr)]} {
						set engine($attr) $Var($attr)
					}
				}
			}
		}

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

	SaveEngineList
}


proc SaveEngineList {} {
	variable Priv

	set filename $::scidb::file::engines
	set f [open $filename.tmp "w"]
	fconfigure $f -encoding utf-8
	::options::writeHeader $f engines
	::options::writeList $f [namespace current]::Engines
	close $f
	file rename -force $filename.tmp $filename
	::options::unhookWriter [namespace current]::WriteOptions engines
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

	SaveEngineList
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
	variable EmptyEngine
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
		-filetypes [list [list $::dialog::fsbox::mc::FileType(exe) {x}]] \
	]
	if {[llength $result] == 0} { return }
	set file [lindex $result 0]
	set newEntry $EmptyEngine

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

	lassign [lindex $PhotoFiles 0] item logo file name
	set PhotoFiles [lreplace $PhotoFiles 0 0]
	MakePhotos $logo $file

	if {[info exists Photo($logo)]} {
		if {$item == $Priv(selection)} { set index 2 } else { set index 1 }
		$list set $item [lindex $Photo($logo) $index]
	} else {
		$list set $item [list $name]
	}

	if {[llength $PhotoFiles]} {
		set Priv(after) [after 50 [namespace code [list LoadPhotoFiles $list]]]
	} else {
		$list resize -width
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
	variable Engines
	variable Var

	array set engine [lindex $Engines [$list curselection]]
	set engine(LastUsed) 0
	set engine(Frequency) 0
	set Var(LastUsed) 0
	set Var(Frequency) 0
	FillInfo $list [array get engine]
}


proc SetLogo {list} {
	variable Engines
	variable EmptyEngine
	variable Photo
	variable Priv
	variable Var

	array set engine $EmptyEngine
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
	$list resize -width
}


proc GetDirectory {parent list} {
	variable Var

	set result [::dialog::chooseDir \
		-parent $parent \
		-initialdir $::scidb::dir::home \
		-geometry last \
	]

	if {[llength $result]} {
		set Var(Directory) [lindex $result 0]
	}
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


proc FindIndex {name} {
	variable EmptyEngine
	variable Engines

	set index 0
	foreach entry $Engines {
		array set engine $entry
		if {$engine(Name) eq $name} { return $index }
		incr index
	}

	return -1
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::Engines
}

} ;# namespace engine

# vi:set ts=3 sw=3:
