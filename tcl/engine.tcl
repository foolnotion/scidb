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
# Copyright: (C) 2011-2013 Gregor Cramer
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

set Information				"Information"
set Features					"Features"
set Options						"Options"

set Name							"Name"
set Identifier					"Identifier"
set Author						"Author"
set Webpage						"Webpage"
set Email						"Email"
set Country						"Country"
set Rating						"Rating"
set Logo							"Logo"
set Protocol					"Protocol"
set Parameters					"Parameters"
set Command						"Command"
set Directory					"Directory"
set Variants					"Variants"
set LastUsed					"Last used"

set Variant(standard)		"Standard"
set Variant(chess960)		"Chess 960"
set Variant(bughouse)		"Bughouse"
set Variant(crazyhouse)		"Crazyhouse"
set Variant(suicide)			"Antichess"
set Variant(giveaway)		"Antichess"
set Variant(losers)			"Antichess"
set Variant(3check)			"Three-check"

set Edit							"Edit"
set View							"View"
set New							"New"
set Rename						"Rename"
set Delete						"Delete"
set Select(engine)			"Select engine"
set Select(profile)			"Select profile"
set ProfileName				"Profile name"
set NewProfileName			"New profile name"
set OldProfileName			"Old profile name"
set CopyFrom					"Copy from"
set NewProfile					"New Profile"
set RenameProfile				"Rename Profile"
set EditProfile				"Edit Profile '%s'"
set ProfileAlreadyExists	"A profile with name '%s' already exists."
set ChooseDifferentName		"Please choose a different name."
set ReservedName				"Name '%s' is reserved and cannot be used."
set ReallyDeleteProfile		"Really delete profile '%s'?"
set SortName					"Sort by name"
set SortElo						"Sort by Elo rating"
set SortRating					"Sort by CCRL rating"
set OpenUrl						"Open URL (web browser)"

set AdminEngines				"Manage Engines"
set SetupEngine				"Setup engine %s"
set ImageFiles					"Image files"
set SelectEngine				"Select Engine"
set SelectEngineLogo			"Select Engine Logo"
set EngineDictionary			"Engine Dictionary"
set EngineFilter				"Engine Filter"
set EngineLog					"Engine Console"
set Probing						"Probing"
set NeverUsed					"Never used"
set OpenFsbox					"Open File Selection Dialog"
set ResetToDefault			"Reset to default"
set ShowInfo					"Show \"Info\""
set TotalUsage					"%s times in total"
set Memory						"Memory (MB)"
set CPUs							"CPUs"
set Priority					"CPU Priority"
set ClearHash					"Clear hash tables"

set ConfirmNewEngine			"Confirm new engine"
set EngineAlreadyExists		"An entry with this engine already exists."
set CopyFromEngine			"Make a copy of entry"
set CannotOpenProcess		"Cannot start process."
set DoesNotRespond			"This engine does not respond either to UCI nor to XBoard/WinBoard protocol."
set DiscardChanges			"The current item has changed.\n\nReally discard changes?"
set ReallyDelete				"Really delete engine '%s'?"
set EntryAlreadyExists		"An entry with name '%s' already exists."
set NoFeaturesAvailable		"This engine does not provide any feature, not even an analyze mode is available. You cannot use this engine for the analysis of positions."
set NoStandardChess			"This engine does not support standard chess."
set NoEngineAvailable		"No engine available."
set FailedToCreateDir		"Failed to create directory '%s'."
set ScriptErrors				"Any errors while saving will be displayed here."
set CommandNotAllowed		"Usage of command '%s' is not allowed here."
set ThrowAwayChanges			"Throw away all changes?"
set ResetToDefaultContent	"Reset to default content"

set ProbeError(registration)			"This engine requires a registration."
set ProbeError(copyprotection)		"This engine is copy-protected."

set FeatureDetail(analyze)				"This engine provides an analyze mode."
set FeatureDetail(multiPV)				"Allows you to see the engine evaluations and principal variations (PVs) from the highest ranked candidate moves. This engines can show up to %s principal variations."
set FeatureDetail(pause)				"This provides a proper handling of pause/resume: the engine does not think, ponder, or otherwise consume significant CPU time. The current thinking or pondering (if any) is suspended and both player's clocks are stopped."
set FeatureDetail(playOther)			"The engine is capable to play your move. Your clock wiil run while the engine is thinking about your move."
set FeatureDetail(hashSize)			"This feature allows to inform the engine on how much memory it is allowed to use maximally for the hash tables. This engine allows a range between %min and %max MB."
set FeatureDetail(clearHash)			"The user may clear the hash tables whlle the engine is running."
set FeatureDetail(threads)				"It allows you to configure the number of threads the chess engine will use during its thinking. This engine is using between %min and %max threads."
set FeatureDetail(smp)					"More than one CPU (core) can be used by this engine."
set FeatureDetail(limitStrength)		"The engine is able to limit its strength to a specific Elo number between %min-%max."
set FeatureDetail(skillLevel)			"The engine provides the possibility to lower the skill down, where it can be beaten quite easier."
set FeatureDetail(ponder)				"Pondering is simply using the user's move time to consider likely user moves and thus gain a pre-processing advantage when it is our turn to move, also referred as Permanent brain."
set FeatureDetail(chess960)			"Chess960 (or Fischer Random Chess) is a variant of chess. The game employs the same board and pieces as standard chess, but the starting position of the pieces along the players' home ranks is randomized, with a few restrictions which preserves full castling options in all starting positions, resulting in 960 unique positions."
set FeatureDetail(bughouse)			"Bughouse chess (also called Exchange chess, Siamese chess, Tandem chess, Transfer chess, or Double Bughouse) is a chess variant played on two chessboards by four players in teams of two. Normal chess rules apply, except that captured pieces on one board are passed on to the players of the other board, who then have the option of putting these pieces on their board."
set FeatureDetail(crazyhouse)			"Crazyhouse (also known as Drop Chess) is a chess variant similar to bughouse chess, but with only two players. It effectively incorporates a rule in shogi (Japanese chess), in which a player can introduce a captured piece back to the board as his own."
set FeatureDetail(suicide)				"Suicide Chess (also called Antichess, Take Me Chess, Must Kill, Reverse Chess) has simple rules: capturing moves are mandatory and the object is to lose all pieces. There is no check, the king is captured like an ordinary piece. In case of stalemate the side with fewer pieces will win (according to FICS rules)."
set FeatureDetail(giveaway)			"Giveaway Chess (a variant of Antichess) is like Suicide Chess, but in case of stalemate the side which is stalemate wins (according to international rules)."
set FeatureDetail(losers)				"Losing Chess is a variant of Antichess, where the goal is to lose the chess game, but with several conditions attached to the rules. The goal is to lose all of your pieces (except the king), although in Losers Chess, you can also win by getting checkmated (according to ICC rules)."
set FeatureDetail(3check)				"The characteristic of this chess variant: a player wins if he checks his opponent three times."
set FeatureDetail(playingStyle)		"This engine provides different playing styles, namely %s. See the handbook of the engine for an explanation of the different styles."

# don't translate
set Feature(analyze)			"Analyze"
set Feature(multiPV)			"Multiple Best Lines"
set Feature(pause)			"Pause"
set Feature(playOther)		"Play Other"
set Feature(hashSize)		"Hash Size"
set Feature(clearHash)		"Clear Hash"
set Feature(threads)			"Threads"
set Feature(smp)				"SMP"
set Feature(limitStrength)	"Limit Strength"
set Feature(skillLevel)		"Skill Level"
set Feature(ponder)			"Pondering"
set Feature(playingStyle)	"Playing Styles"

set Feature(chess960)		"Chess960"
set Feature(bughouse)		"Bughouse"
set Feature(crazyhouse)		"Crazyhouse"
set Feature(suicide)			"Suicide"
set Feature(giveaway)		"Giveaway"
set Feature(losers)			"Losers"
set Feature(3check)			"Three-check"

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
	Variants			{}
	LastUsed			0
	Frequency		0
	Features:UCI	{}
	Features:WB		{}
	Profiles:UCI	{}
	Profiles:WB		{}
	ProfileType		Options
	Timestamp		0
	FileTime			0
	UserDefined		1
}

array set Options {
	engine Stockfish
}

variable PhotoFiles {}
variable Engines {}

array set Priv { after {}  }
array set Logo { width 100 height 54 }


proc openAdmininstration {parent} {
	variable Engines
	variable Priv
	variable Option
	variable Option_
	variable Var
	variable Var_

	set dlg $parent.adminEngines
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	set Priv(state) edit
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
	set list [MakeEngineList $top.list 6]

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
	ttk::label			$setup.lauthor -text $mc::Author
	ttk::entry			$setup.eauthor -textvar [namespace current]::Var(Author)
	ttk::label			$setup.lemail -text $mc::Email
	ttk::entry			$setup.eemail -textvar [namespace current]::Var(Email)

	ttk::label			$setup.lidentifier -text $mc::Identifier
	ttk::label			$setup.tidentifier -textvar [namespace current]::Var(Identifier) {*}$labelOptions
	ttk::label			$setup.lvariants -text $mc::Variants
	ttk::label			$setup.tvariants -textvar [namespace current]::Var(variants) {*}$labelOptions
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
	ttk::label			$setup.lprotocol -text $mc::Protocol
	ttk::label			$setup.tprotocol -textvar [namespace current]::Var(protocol) {*}$labelOptions
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

	grid $setup.frating.lelo	-row 1 -column 1
	grid $setup.frating.selo	-row 1 -column 3
	grid $setup.frating.lccrl	-row 1 -column 5
	grid $setup.frating.sccrl	-row 1 -column 7
	grid columnconfigure $setup.frating {2 6} -minsize $::theme::padx
	grid columnconfigure $setup.frating {4} -minsize $::theme::padX

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
	grid $setup.lurl			-row 17 -column 1 -sticky w
	grid $setup.eurl			-row 17 -column 3 -sticky we
	grid $setup.burl			-row 17 -column 5 -sticky we
	grid $setup.llogo			-row 19 -column 1 -sticky w
	grid $setup.elogo			-row 19 -column 3 -sticky we
	grid $setup.blogo			-row 19 -column 5 -sticky we

	grid $setup.lcommand		-row 21 -column 1 -sticky w
	grid $setup.tcommand		-row 21 -column 3 -sticky we
	grid $setup.lprotocol	-row 23 -column 1 -sticky w
	grid $setup.tprotocol	-row 23 -column 3 -sticky we
	grid $setup.ldirectory	-row 25 -column 1 -sticky w
	grid $setup.edirectory	-row 25 -column 3 -sticky we
	grid $setup.bdirectory	-row 25 -column 5 -sticky we
	grid $setup.lparams		-row 27 -column 1 -sticky w
	grid $setup.eparams		-row 27 -column 3 -sticky we

	grid columnconfigure $setup {0 2 4 6} -minsize $::theme::padx
	grid columnconfigure $setup {3} -weight 1
	grid rowconfigure $setup {0 2 4 8 10 14 16 18 22 24 26 28} -minsize $::theme::pady
	grid rowconfigure $setup {6 12 20} -minsize [expr {3*$::theme::pady}] -weight 1

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

	### Variables ########################################################ä
	set Priv(pane:features) $features
	set Priv(pane:setup) $setup
	set Priv(notebook) $nb

	### Geometry ##########################################################
	grid $list -row 1 -column 1
	grid $nb	  -row 1 -column 3 -sticky nswe
	grid rowconfigure $top {0 2} -minsize $::theme::pady
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid columnconfigure $top {3} -weight 1

	### Buttons ###########################################################
	::widget::dialogButtons $dlg {new save delete close help} -default close
	$dlg.delete configure -command [namespace code [list DeleteEngine $list]]
	$dlg.save configure -command [namespace code [list SaveEngine $list]] -state disabled
	$dlg.new configure -command [namespace code [list NewEngine $list]]
	$dlg.close configure -command [namespace code [list CloseSetup $list]]
	if {[llength $Engines] == 0} { $dlg.delete configure -state disabled }
	set Priv(button:save) $dlg.save
	set Priv(button:delete) $dlg.delete

	### Popup #############################################################
	if {[llength $Engines]} { $list select 0 }
	update idletasks

	$nb.setup configure -width [winfo reqwidth $nb.setup ]
	wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
	wm minsize $dlg [winfo reqwidth $dlg] [winfo reqheight $dlg]
	wm resizable $dlg true false
	wm title $dlg $mc::AdminEngines
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


proc openSetup {parent} {
	variable Engines
	variable Options
	variable Vars

	if {[llength $Engines] == 0} {
		return [::dialog::info -parent $parent -message $mc::NoEngineAvailable]
	}

	set dlg .setupEngine

	if {[winfo exists $dlg]} {
		SetupClearHash $Vars(active:name)
		::widget::dialogRaise $dlg
		return
	}

	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top -takefocus 0]
	pack $top -fill both -expand yes
	set lf [ttk::labelframe $top.engine -text $mc::Select(engine)]
	set rf [ttk::labelframe $top.profile -text $mc::Select(profile)]

	set memory [::system::memAvailable]
	if {$memory == -1} {
		set memory 256
	} else {
		set memory [expr {min(256, [::scidb::misc::predPow2 [expr {$memory/1048576}]])}]
	}

	set Vars(selection) -1
	set Vars(priority) $mc::Normal
	set Vars(list:profiles) $rf.profiles
	set Vars(list:engines) $lf.list

	set Vars(current:name) ""
	set Vars(current:protocol) UCI
	set Vars(current:memory) $memory
	set Vars(current:cores) [expr {[::system::ncpus] - 1}]
	set Vars(current:priority) normal
	set Vars(current:profile) Default

	set Vars(active:name) ""
	set Vars(active:protocol) UCI
	set Vars(active:memory) 0
	set Vars(active:cores) 1
	set Vars(active:priority) normal
	set Vars(active:profile) Default
	set Vars(active:id) -1

	set listheight 7

	### fst panel  ########################################################
	set list [::tlistbox $lf.list -usescroll yes -height $listheight -minwidth 70]
 	bind $list <<ListboxSelect>> [namespace code [list UseEngine $list %d $Vars(list:profiles)]]
	SetupEngineList

	### snd panel #########################################################
	set lt [::ttk::frame $lf.lt -takefocus 0]
	ttk::label $lt.lpriority -textvar [namespace current]::mc::Priority
	ttk::label $lt.lmemory -textvar [namespace current]::mc::Memory
	ttk::label $lt.lcpus -textvar [namespace current]::mc::CPUs
	ttk::label $lt.lprotocol -textvar [namespace current]::mc::Protocol

	ttk::combobox $lt.priority \
		-width 7 \
		-state readonly \
		-values [list $::mc::Normal $::mc::Low] \
		-textvariable [namespace current]::Vars(priority) \
		;
	ttk::tcombobox $lt.memory \
		-width 7 \
		-height 12 \
		-listjustify right \
		-state readonly \
		-textvariable [namespace current]::Vars(current:memory) \
		;
	$lt.memory addcol text -d mb -justify right
	bind $lt.memory <<ComboboxSelected>> [namespace code SetMemory]
	ttk::spinbox $lt.cores \
		-width 7 \
		-state readonly \
		-textvariable [namespace current]::Vars(current:cores) \
		-command [namespace code SetCores] \
		;
	ttk::frame $lt.protocol -takefocus 0 -borderwidth 0
	ttk::radiobutton $lt.protocol.buci \
								-text "UCI" \
								-value "UCI" \
								-variable [namespace current]::Vars(current:protocol) \
								-command [namespace code SetupProfiles] \
								;
	if {[tk windowingsystem] eq "x11"} { set prot XBoard } else { set prot WinBoard }
	ttk::radiobutton $lt.protocol.bwb \
								-text $prot \
								-value "WB" \
								-variable [namespace current]::Vars(current:protocol) \
								-command [namespace code SetupProfiles] \
								;
	ttk::button $lt.clearHash \
		-textvar [namespace current]::mc::ClearHash \
		-command [namespace code ClearHash] \
		-state disabled \
		;

	grid $lt.protocol.buci	-row 1 -column 1
	grid $lt.protocol.bwb	-row 1 -column 3
	grid columnconfigure $lt.protocol {2} -minsize 3

	set Vars(widget:memory) $lt.memory
	set Vars(widget:cores) $lt.cores
	set Vars(widget:priority) $lt.priority
	set Vars(widget:clearHash) $lt.clearHash
	set Vars(widget:uci) $lt.protocol.buci
	set Vars(widget:wb) $lt.protocol.bwb

	bind $lt.priority <<LanguageChanged>> [namespace code [list LanguageChanged $list]]
	bind $lt.priority <<ComboboxSelected>> [namespace code SetPriority]

	### thd panel #########################################################
	set prof [::tlistbox $rf.profiles -usescroll yes -height $listheight -minwidth 70]
	bind $prof <<ListboxSelect>> [namespace code [list UseProfile %d]]

	### fth panel #########################################################
	set rt [::ttk::frame $rf.rt -takefocus 0]
	ttk::button $rt.edit \
		-style aligned.TButton \
		-text " $mc::Edit" \
		-image $::icon::16x16::edit \
		-compound left \
		-command [namespace code [list OpenSetupEngineDialog $dlg]] \
		;
	ttk::button $rt.rename \
		-style aligned.TButton \
		-text " $mc::Rename" \
		-image $::fsbox::bookmarks::icon::16x16::modify \
		-compound left \
		-command [namespace code [list RenameProfile $dlg]] \
		;
	ttk::button $rt.new \
		-style aligned.TButton \
		-text " $mc::New" \
		-image $::icon::16x16::plus \
		-compound left \
		-command [namespace code [list NewProfile $dlg]] \
		;
	ttk::button $rt.delete \
		-style aligned.TButton \
		-text " $mc::Delete" \
		-image $::fsbox::filelist::icon::16x16::delete \
		-compound left \
		-command [namespace code [list DeleteProfile $dlg]] \
		;

	set Vars(widget:edit) $rt.edit
	set Vars(widget:rename) $rt.rename
	set Vars(widget:new) $rt.new
	set Vars(widget:delete) $rt.delete

	### gemoetry ##########################################################
	grid $lf		-row 1 -column 1 -sticky ns
	grid $rf		-row 1 -column 3 -sticky ns
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid rowconfigure $top {0 2} -minsize $::theme::pady

	grid $list	-row 1 -column 1 -sticky ns
	grid $lt		-row 1 -column 3 -sticky ns
	grid columnconfigure $lf {0 2 4} -minsize $::theme::padx
	grid rowconfigure $lf {0 2} -minsize $::theme::pady

	grid $prof	-row 1 -column 1 -sticky ns
	grid $rt		-row 1 -column 3 -sticky ns
	grid columnconfigure $rf {0 2 4} -minsize $::theme::padx
	grid rowconfigure $rf {0 2} -minsize $::theme::pady

	grid $lt.lpriority	-row 1 -column 1 -sticky w
	grid $lt.lmemory		-row 3 -column 1 -sticky w
	grid $lt.lcpus			-row 5 -column 1 -sticky w
	grid $lt.lprotocol	-row 7 -column 1 -sticky w
	grid $lt.priority		-row 1 -column 3 -sticky we
	grid $lt.memory		-row 3 -column 3 -sticky we
	grid $lt.cores			-row 5 -column 3 -sticky we
	grid $lt.protocol		-row 7 -column 3 -sticky we
	grid $lt.clearHash	-row 9 -column 1 -columnspan 3 -sticky we

	grid columnconfigure $lt {2} -minsize $::theme::padx
	grid rowconfigure $lt {1 3 5} -uniform u
	grid rowconfigure $lt {2 4 6} -minsize $::theme::pady
	grid rowconfigure $lt {8} -minsize $::theme::padY -weight 1

	grid $rt.edit		-row 1 -column 1 -sticky we
	grid $rt.rename	-row 3 -column 1 -sticky we
	grid $rt.new		-row 5 -column 1 -sticky we
	grid $rt.delete	-row 7 -column 1 -sticky we
	grid rowconfigure $rt {2 4 6} -minsize $::theme::pady -weight 1

	### finish dialog #####################################################
	set var [namespace current]::mc::AdminEngines
	::widget::dialogButtons $dlg {start close} -default start
	::widget::dialogButtonAdd $dlg admin $var $::icon::16x16::setup -position end
	$dlg.start configure -command [namespace code [list StartEngine $list]]
	$dlg.close configure -command [list wm withdraw $dlg]
	$dlg.admin configure -command [namespace code [list OpenAdministration $dlg]]

	set i [FindIndex $Options(engine)]
	if {$i == -1} { set i 0 }
	$list select $i
	LanguageChanged $list

	wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
	wm resizable $dlg false false
	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $list
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


proc showEngineDictionary {parent} {
	variable Priv

	if {$parent eq "."} { set dlg .engineDict } else { set dlg $parent.engineDict }
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
	bind $lb <<ListboxSelect>> [namespace code [list OpenUrl $dlg %d]]
	bind $lb <<ItemVisit>> [namespace code [list VisitItem $lb %d]]
	bind $lb <<HeaderVisit>> [namespace code [list VisitHeader $lb %d]]
	bind $lb <<LanguageChanged>> [namespace code [list SetDialogHeader $dlg]]
	$lb bind <ButtonPress-3> [namespace code [list PopupMenu $lb %x %y]]

	set colwd 20
	$lb addcol image -id country -justify center -headervar [namespace current]::mc::Country
	$lb addcol text  -id name -headervar [namespace current]::mc::Name -witdh 30
	$lb addcol text  -id elo -justify right -foreground darkgreen -header "Elo"
	$lb addcol text  -id ccrl -justify right -foreground darkgreen -header "CCRL"
	$lb addcol image -id chess960 -width $colwd -header "9" -justify center
	$lb addcol image -id threeCheck -width $colwd -justify center
	$lb addcol image -id crazyhouse -width $colwd -justify center
	$lb addcol image -id bughouse -width $colwd -justify center
	$lb addcol image -id suicide -width $colwd -justify center
	$lb addcol image -id giveaway -width $colwd -justify center
	$lb addcol image -id losers -width $colwd -justify center
	$lb addcol text  -id url -header "URL" -expand yes -width 50 -squeeze 1 -ellipsis 1
	FillHeader $lb

	if {![info exists Priv(engines)]} {
		set engines [::scidb::misc::sort -dictionary -nopunct -unique -index 0 [::scidb::engine::list]]
		set Priv(engines) {}

		foreach name $engines {
			set result [::scidb::engine::info $name]
			if {[llength $result]} {
				lassign $result _ country elo ccrl _ _ variants url
				lappend Priv(engines) [list $country $name $elo $ccrl $url {*}$variants]
			}
		}
	}

	set Priv(sort) name
	ResetFilter $lb
	FillDict $lb
	$lb resize
	$lb fixwidth

	grid $lb -row 1 -column 1 -sticky ewns
	grid rowconfigure $top {1} -weight 1
	grid columnconfigure $top {1} -weight 1

	grid columnconfigure $top {0 2} -minsize $::theme::padx
	grid rowconfigure $top {0 2} -minsize $::theme::pady

	::widget::dialogButtons $dlg {close}
	::widget::dialogButtonAdd $dlg filter ::mc::Filter {}
	$dlg.close configure -command [list destroy $dlg]
	$dlg.filter configure -command [namespace code [list SetFilter $lb]]
	$dlg.filter configure -image $::icon::16x16::filter(inactive) -compound left

	SetDialogHeader $dlg
	wm resizable $dlg yes yes
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center [winfo toplevel $parent]
	wm deiconify $dlg

	if {[llength $Priv(engines)]} {
		focus $lb
		$lb select 0
	}
}


proc setup {} {
	variable EmptyEngine
	variable Engines

	set localFile $::scidb::file::engines
	set shareFile [file join $::scidb::dir::share engines [file tail $localFile]]
	set localFiletime 0
	set shareFiletime 0

	if {[file readable $localFile]} { file stat $localFile st; set localFiletime $st(mtime) }
	if {[file readable $shareFile]} { file stat $shareFile st; set shareFiletime $st(mtime) }

	if {$localFiletime > 0} {
		if {$shareFiletime > $localFiletime} {
			# update local configuration file
			set engines [LoadSharedConfiguration $shareFile]
			::load::source $localFile -message $::load::mc::ReadingFile(engines) -encoding utf-8
			set changed 0

			foreach newEntry $engines {
				array set newEngine $EmptyEngine
				array set newEngine $newEntry

				if {[file exists $newEngine(Command)]} {
					set changed 1
					set index [FindIndex $newEngine(Name)]
					if {$index >= 0} {
						array set oldEngine $EmptyEngine
						array set oldEngine [lindex $Engines $index]
						if {$oldEngine(ProfileType) eq "Options"} {
							foreach prot {UCI WB} {
								set oldProfiles $oldEngine(Profiles:$prot)
								set newProfiles $newEngine(Profiles:$prot)
								if {[llength $oldProfiles] >= 2 && [llength $newProfiles] == 2} {
									set newOptions [lindex $newProfiles 1]
									array set valueMap {}
									foreach {profile oldOptions} $oldProfiles {
										array unset valueMap
										foreach opt $oldOptions { set valueMap([lindex $opt 0]) [lindex $opt 2] }
										set options {}
										foreach opt $newOptions {
											lassign $opt name type value dflt var max
											if [info exists valueMap($name)] {
												set oldValue $valueMap($name)
												switch $type {
													spin - slider {
														set oldValue [expr {min($max, max($var, $oldValue))}]
													}
													combo {
														if {$oldValue ni [SplitComboEntries $var]} {
															set oldValue $value
														}
													}
												}
												lset opt 2 $oldValue
											}
											lappend options $opt
										}
										lappend optionList $profile $options
									}
									set newEngine(Profiles:$prot) $optionList
								}
							}
							set newEntry [array get newEngine]
							lset Engines $index $newEntry
						} else {
							foreach {profile options} $newEngine(Profiles:WB) {
								if {$profile eq "Default"} { set newEngine(Script:Default) $options }
							}
							set newEngine(Profiles:WB) $oldEngine(Profiles:WB)
						}
						set newEntry [array get newEngine]
						lset Engines $index $newEntry
					} else {
						lappend Engines $newEntry
					}
				}
			}

			if {$changed} { ::options::hookWriter [namespace current]::WriteEngineOptions engines }
		} else {
			::load::source $localFile -message $::load::mc::ReadingFile(engines) -encoding utf-8
		}
	} elseif {$shareFiletime > 0} {
		LoadSharedConfiguration $shareFile
		::options::hookWriter [namespace current]::WriteEngineOptions engines
	}
}


proc startEngine {isReadyCmd signalCmd updateCmd} {
	variable EmptyEngine
	variable Engines
	variable Vars

	set index [FindIndex $Vars(current:name)]
	if {$index == -1} { return -1 }

	set entry [lindex $Engines $index]
	array set engine $EmptyEngine
	array set engine $entry

	set protocol $Vars(current:protocol)
	if {[string length $engine(Directory)] && [file isdirectory $engine(Directory)]} {
		set dir $engine(Directory)
	} else {
		set dir $::scidb::dir::log
	}
	set engine(LastUsed) [clock seconds]
	incr engine(Frequency)
	lset Engines $index [array get engine]
	::options::hookWriter [namespace current]::WriteEngineOptions engines
	set id [::scidb::engine::start \
		$engine(Command) \
		$dir \
		$protocol \
		$isReadyCmd \
		$signalCmd \
		$updateCmd \
	]
	return $id
}


proc activateEngine {engineId features} {
	variable Engines
	variable Vars

	if {$engineId == -1} { return }
	set Vars(active:name) $Vars(current:name)
	set Vars(active:id) $engineId
	set Vars(active:priority) $Vars(current:priority)
	sendOptions $engineId
	sendFeatures $engineId $features
	::scidb::engine::activate $engineId
	if {$Vars(current:priority) ne "normal"} {
		::scidb::engine::priority $engineId $Vars(current:priority)
	}
}


proc sendFeatures {engineId features} {
	variable EmptyEngine
	variable Engines
	variable Vars

	if {$engineId == -1} { return }
	set Vars(active:cores) $Vars(current:cores)
	set Vars(active:memory) $Vars(current:memory)
	set index [FindIndex $Vars(current:name)]
	if {$index == -1} { return }
	array set engine $EmptyEngine
	array set engine [lindex $Engines $index]
	array set featureArr { analyze false }
	array set featureArr $features
	set protocol $Vars(current:protocol)
	array set engineFeatures $engine(Features:$protocol)
	if {[info exists engineFeatures(analyze)]} { set featureArr(analyze) true }
	if {[info exists engineFeatures(threads)]} { set featureArr(smp) $Vars(current:cores) }
	if {[info exists engineFeatures(smp)]} { set featureArr(smp) $Vars(current:cores) }
	if {[info exists engineFeatures(hashSize)]} { set featureArr(hashSize) $Vars(current:memory) }
	::scidb::engine::setFeatures $engineId [array get featureArr]
}


proc sendOptions {engineId} {
	variable EmptyEngine
	variable Engines
	variable Vars

	if {$engineId == -1} { return }
	set index [FindIndex $Vars(current:name)]
	if {$index == -1} { return }
	array set engine $EmptyEngine
	array set engine [lindex $Engines $index]
	set protocol $Vars(current:protocol)
	array set profiles $engine(Profiles:$protocol)
	if {[llength profiles($Vars(current:profile))]} {
		set Vars(active:profile) $Vars(current:profile)
		switch $engine(ProfileType) {
			Options {
				set pairs {}
				foreach opt $profiles($Vars(current:profile)) {
					lassign $opt name _ value _ _ _
					lappend pairs $name $value
				}
				::scidb::engine::setOptions $engineId options $pairs
			}
			Script {
				set script ""
				foreach line $profiles($Vars(current:profile)) {
					set n [string first "#" $line]
					if {$n >= 0} { set line [string range $line 0 [expr {$n - 1}]] }
					set line [string trim $line]
					if {[string length $line]} {
						append script $line "\n"
					}
				}
				::scidb::engine::setOptions $engineId script $script
			}
		}
	}
}


proc restartAnalysis {engineId features} {
	variable Vars

	if {$engineId != -1} {
		::scidb::engine::analyze stop $engineId
		if {$Vars(current:profile) ne $Vars(active:profile)} {
			sendOptions $engineId
		}
		if {$Vars(current:cores) != $Vars(active:cores) || $Vars(current:memory) != $Vars(active:memory)} {
			sendFeatures $engineId $features
		}
		::scidb::engine::analyze start $engineId
	}
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
	variable Vars

	if {$engineId != -1} {
		::scidb::engine::kill $engineId
		set Vars(active:name) ""
		set Vars(active:profile) ""
		set Vars(active:id) -1
	}
}


proc engineName {engineId} {
	return [set [namespace current]::Vars(current:name)]
}


proc OpenUrl {parent index} {
	variable Priv

	if {[llength $index] == 0} {
		set url [lindex $Priv(engines) [lindex $Priv(filter) $Priv(dict:current)] 4]
		if {[string length $url]} { ::web::open $parent $url }
	} else {
		set Priv(dict:current) $index
	}
}


proc SetDialogHeader {dlg} {
	wm title $dlg $mc::EngineDictionary
}


proc VisitHeader {lb data} {
	variable Priv

	lassign $data mode id column

	switch $mode {
		enter {
			set name [string toupper $id 0 0]
			if {[info exists ::mc::VariantName($name)]} {
				switch $name {
					Suicide - Giveaway - Losers {
						set tip "$::mc::VariantName(Antichess) - $::mc::VariantName($name)"
					}
					default {
						set tip $::mc::VariantName($name)
					}
				}
				tooltip::show $lb $tip
			}
		}
		leave {
			::tooltip::tooltip hide
		}
	}
}


proc VisitItem {lb data} {
	variable Priv

	lassign $data mode id index column

	switch $mode {
		enter {
			set entry [lindex $Priv(engines) [lindex $Priv(filter) $index]]
			lassign $entry country _ _ _ _ chess960 shuffle threeCheck \
				crazyhouse bughouse suicide giveaway losers
			if {$id eq "country"} {
				tooltip::show $lb [::country::name $country]
			} else {
				set name [string toupper $id 0 0]
				if {[info exists ::mc::VariantName($name)] && [set $id]} {
					switch $name {
						Suicide - Giveaway - Losers {
							set tip "$::mc::VariantName(Antichess) - $::mc::VariantName($name)"
						}
						default {
							set tip $::mc::VariantName($name)
						}
					}
					tooltip::show $lb $tip
				}
			}
		}
		leave {
			::tooltip::tooltip hide
		}
	}
}


proc PopupMenu {lb x y} {
	variable Priv

	set m $lb.__menu__
	catch { destroy $m }
	menu $m -tearoff 0
	catch { wm attributes $m -type popup_menu }

	set item [$lb identify $x $y]
	if {[lindex $item 0] ne "item"} { return }
	set index [expr {[lindex $item 1] - 1}]
	$lb select $index

	set url [lindex $Priv(engines) [lindex $Priv(filter) $index] 4]
	if {[string length $url]} {
		$m add command \
			-label $mc::OpenUrl \
			-command [list ::web::open $lb $url] \
			;
		$m add separator
	}

	$m add radiobutton \
		-label $mc::SortName \
		-command [namespace code [list SortEngines $lb]] \
		-variable [namespace current]::Priv(sort) \
		-value name \
		;
	$m add radiobutton \
		-label $mc::SortElo \
		-command [namespace code [list SortEngines $lb]] \
		-variable [namespace current]::Priv(sort) \
		-value elo \
		;
	$m add radiobutton \
		-label $mc::SortRating \
		-command [namespace code [list SortEngines $lb]] \
		-variable [namespace current]::Priv(sort) \
		-value rating \
		;

	tk_popup $m {*}[winfo pointerxy $lb]
}


proc SortEngines {lb} {
	variable Priv

	::widget::busyCursor on
	switch $Priv(sort) {
		name {
			set Priv(engines) [::scidb::misc::sort -dictionary -nopunct -index 1 $Priv(engines)]
		}
		elo {
			set Priv(engines) [lsort -integer -index 2 -decreasing $Priv(engines)]
		}
		rating {
			set Priv(engines) [lsort -integer -index 3 -decreasing $Priv(engines)]
		}
	}
	FillDict $lb
	::widget::busyCursor off
}


proc FillHeader {lb} {
	$lb configcol threeCheck	-header [string range $::mc::VariantName(ThreeCheck) 0 1]
	$lb configcol crazyhouse	-header [string range $::mc::VariantName(Crazyhouse) 0 1]
	$lb configcol bughouse		-header [string range $::mc::VariantName(Bughouse) 0 1]
	$lb configcol suicide		-header [string range $::mc::VariantName(Suicide) 0 1]
	$lb configcol giveaway		-header [string range $::mc::VariantName(Giveaway) 0 1]
	$lb configcol losers			-header [string range $::mc::VariantName(Losers) 0 1]
}


proc ResetFilter {lb} {
	variable DefaultFilter
	variable Filter

	foreach variant {Normal Chess960 ThreeCheck Crazyhouse Bughouse Suicide Giveaway Losers} {
		set Filter($variant) 1
	}

	set Filter(elo:min) 0
	set Filter(elo:max) 4000
	set Filter(ccrl:min) 0
	set Filter(ccrl:max) 4000

	array set DefaultFilter [array get Filter]
}


proc SetFilter {lb} {
	variable DefaultFilter
	variable Filter
	variable Filter_
	variable Reply_

	set parent [winfo toplevel $lb]
	set dlg [tk::toplevel $parent.engineFilter -class Scidb]
	set top [ttk::frame $dlg.top -takefocus 0 -borderwidth 0]
	wm withdraw $dlg
	pack $top -fill both -expand yes

	set v [::ttk::labelframe $top.variants -text $mc::Variants]

	set row 0
	set col 1
	foreach variant {Normal Chess960 ThreeCheck Crazyhouse Bughouse Suicide Giveaway Losers} {
		set name [string tolower $variant 0 0]
		grid rowconfigure $v $row -minsize $::theme::pady
		ttk::checkbutton $v.$name \
			-text $::mc::VariantName($variant) \
			-variable [namespace current]::Filter($variant) \
			;
		grid $v.$name -row $row -column $col -sticky w
		if {[incr col 2] > 3} {
			set col 1
			incr row 2
		}
	}
	grid rowconfigure $v $row -minsize $::theme::pady
	grid columnconfigure $v {0 2 4} -minsize $::theme::padx

	ttk::label $top.elo -text "Elo"
	ttk::spinbox $top.eloMin \
		-from 0 \
		-to 4000 \
		-textvar [namespace current]::Filter(elo:min) \
		-width 5 \
		-justify right \
		;
	ttk::label $top.eloDelim -text "\u2212"
	ttk::spinbox $top.eloMax \
		-from 0 \
		-to 4000 \
		-textvar [namespace current]::Filter(elo:max) \
		-width 5 \
		-justify right \
		;

	ttk::label $top.ccrl -text "CCRL"
	ttk::spinbox $top.ccrlMin \
		-from 0 \
		-to 4000 \
		-textvar [namespace current]::Filter(ccrl:min) \
		-width 5 \
		-justify right \
		;
	ttk::label $top.ccrlDelim -text "\u2212"
	ttk::spinbox $top.ccrlMax \
		-from 0 \
		-to 4000 \
		-textvar [namespace current]::Filter(ccrl:max) \
		-width 5 \
		-justify right \
		;

	::validate::spinboxInt $top.eloMin
	::validate::spinboxInt $top.eloMax
	::validate::spinboxInt $top.ccrlMin
	::validate::spinboxInt $top.ccrlMax

	grid $top.variants	-row 1 -column 1 -columnspan 6 -sticky ew
	grid $top.elo			-row 3 -column 1 -sticky w
	grid $top.eloMin		-row 3 -column 3
	grid $top.eloDelim	-row 3 -column 4
	grid $top.eloMax		-row 3 -column 5
	grid $top.ccrl			-row 5 -column 1 -sticky w
	grid $top.ccrlMin		-row 5 -column 3
	grid $top.ccrlDelim	-row 5 -column 4
	grid $top.ccrlMax		-row 5 -column 5

	grid rowconfigure $top {0 2 4 6} -minsize $::theme::pady
	grid columnconfigure $top {0 2 7} -minsize $::theme::padx
	grid columnconfigure $top {6} -weight 1

	array set Filter_ [array get Filter]
	set Reply_ ""

	::widget::dialogButtons $dlg {ok revert} -default ok
	$dlg.ok configure -command [list set [namespace current]::Reply_ ok]
	$dlg.revert configure -command [namespace code [list ResetFilter $lb]]
	wm resizable $dlg no no
	wm title $dlg $mc::EngineFilter
	wm protocol $dlg WM_DELETE_WINDOW [list set [namespace current]::Reply_ cancel]
	::util::place $dlg center $parent
	::ttk::grabWindow $dlg
	wm deiconify $dlg
	focus $v.chess960
	tkwait variable [namespace current]::Reply_
	::ttk::releaseGrab $dlg
	destroy $dlg

	if {[arrayEqual Filter DefaultFilter]} { set state inactive } else { set state active }
	[winfo toplevel $lb].filter configure -image $::icon::16x16::filter($state)

	switch $Reply_ {
		ok {
			if {![arrayEqual Filter Filter_]} { FillDict $lb }
		}
		cancel {
			array set Filter [array get Filter_]
		}
	}
}


proc FillDict {lb} {
	variable Priv
	variable Filter

	$lb clear
	set Priv(filter) {}

	set variants {}
	foreach variant {Normal Chess960 ThreeCheck Crazyhouse Bughouse Suicide Giveaway Losers} {
		if {$Filter($variant)} { lappend variants $variant }
	}

	set index 0
	foreach entry $Priv(engines) {
		lassign $entry country name elo ccrl url chess960 shuffle \
			threeCheck crazyhouse bughouse suicide giveaway losers

		if {	$elo  >= $Filter(elo:min)  && $Filter(elo:max)  >= $elo
			&& $ccrl >= $Filter(ccrl:min) && $Filter(ccrl:max) >= $ccrl} {
			set normal 1
			set include 0

			foreach variant {Normal Chess960 ThreeCheck Crazyhouse Bughouse Suicide Giveaway Losers} {
				if {$variant in $variants && [set [string tolower $variant 0 0]]} {
					set include 1
				}
			}

			if {$include} {
				set v [lrepeat 7 "\u2212"]
				if {$elo == 0}		{ set elo "" }
				if {$ccrl == 0}	{ set ccrl "" }
				if {$chess960}		{ lset v 0 $::icon::16x16::checkGreen }
				if {$threeCheck}	{ lset v 1 $::icon::16x16::checkGreen }
				if {$crazyhouse}	{ lset v 2 $::icon::16x16::checkGreen }
				if {$bughouse}		{ lset v 3 $::icon::16x16::checkGreen }
				if {$suicide}		{ lset v 4 $::icon::16x16::checkGreen }
				if {$giveaway}		{ lset v 5 $::icon::16x16::checkGreen }
				if {$losers}		{ lset v 6 $::icon::16x16::checkGreen }

				if {[string length $country]} {
					set flag $::country::icon::flag($country)
				} else {
					set flag ""
				}
				$lb insert [list $flag $name $elo $ccrl {*}$v $url]
				lappend Priv(filter) $index
			}
		}

		incr index
	}
}


proc Search {lb s} {
	if {[string length $s] == 1} { $lb search name $s }
}


proc CloseSetup {list} {
	if {[DiscardChanges $list]} {
		destroy [winfo toplevel $list]
	}
}


proc StartEngine {list} {
	variable Engines
	variable Vars

	wm withdraw [winfo toplevel $list]
	update idletasks

	if {$Vars(active:id) >= 0 && [::scidb::engine::active? $Vars(active:id)]} {
		if {$Vars(current:protocol) ne $Vars(active:protocol)} {
			::application::analysis::startAnalysis [::application::board::anaylsisWindow]
		} else {
			if {$Vars(current:name) ne $Vars(active:name)} {
				::application::analysis::startAnalysis [::application::board::anaylsisWindow]
			} elseif {$Vars(current:profile) ne $Vars(active:profile)} {
				::application::analysis::restartAnalysis
			}
			if {$Vars(current:priority) ne $Vars(active:priority)} {
				set Vars(active:priority) $Vars(current:priority)
				::scidb::engine::priority $engineId $Vars(current:priority)
			}
		}
	} else {
		::application::board::openAnalysis force
		::application::analysis::startAnalysis [::application::board::anaylsisWindow]
	}
}


proc LanguageChanged {list} {
	variable Vars

	set w $Vars(widget:priority)
	set current [$w current]
	$w configure -values [list $::mc::Normal $::mc::Low]
	$w current $current

	SetTitle $list
}


proc SetMemory {} {
	variable Options
	variable Vars

	set Options($Vars(current:name):memory) $Vars(current:memory)
}


proc SetCores {} {
	variable Options
	variable Vars

	set Options($Vars(current:name):cores) $Vars(current:cores)
}


proc SetPriority {} {
	variable Vars

	if {[$Vars(widget:priority) current] == 0} {
		set Vars(current:priority) normal
	} else {
		set Vars(current:priority) low
	}
}


proc MemTotal {} {
	set mem [::system::memTotal]
	if {$mem <= 0} { return 2048 }
	return [::scidb::misc::predPow2 [expr {$mem/1048576}]]
}


proc UseEngine {list item profileList} {
	variable EmptyEngine
	variable Engines
	variable Options
	variable Vars

	if {[llength $item] == 0} { return }
	set Vars(selection) $item
	set name [$list get name]
	set i [FindIndex [$list get name]]

	array set engine $EmptyEngine
	array set engine [lindex $Engines $i]

	set name $engine(Name)
	set Options(engine) $name
	set Vars(current:name) $name

	if {[llength $engine(Protocol)] < 2} {
		set protocol [lindex $engine(Protocol) 0]
		if {$protocol eq "WB"} {
			set state(UCI) disabled
			set state(WB) normal
		} else {
			set state(UCI) normal
			set state(WB) disabled
			set Vars(current:protocol) UCI
		}
	} else {
		set state(UCI) normal
		set state(WB) normal
		set protocol UCI
	}
	$Vars(widget:uci) configure -state $state(UCI)
	$Vars(widget:wb) configure -state $state(WB)
	if {[info exists Options($name:protocol)] && $Options($name:protocol) in $engine(Protocol)} {
		set Vars(current:protocol) $Options($name:protocol)
		set protocol $Options($name:protocol)
	} else {
		set Vars(current:protocol) $protocol
		set Options($name:protocol) $protocol
	}

	array set features $engine(Features:$protocol)

	if {[info exists features(hashSize)]} {
		$Vars(widget:memory) clear
		if {[llength $features(hashSize)] == 0} {
			set min 4
			set max [MemTotal]
		} else {
			lassign $features(hashSize) min max
			set min2 [expr {max(4, [::scidb::misc::succPow2 $min])}]
			set nmin [expr {$min2 + $min2/2}]
			if {$nmin <= $min} { set min $nmin } else { set min $min2 }
			set avail [::system::memAvailable]
			if {$avail >= 0} {
				set avail [expr {$avail/1048576}]
				if {$max > 0 } { set avail [expr {min($avail, $max)}] }
				set max [::scidb::misc::predPow2 $avail]
				set nmax [expr {$max + $max/2}]
				if {$nmax <= $max} { set max $nmax }
			}
		}
		while {$min <= $max} {
			$Vars(widget:memory) listinsert $min
			set incr [expr {[::scidb::misc::predPow2 $min]/2}]
			incr min $incr
		}
		$Vars(widget:memory) resize
		$Vars(widget:memory) configure -height 0 -state readonly
		set Vars(current:memory) [expr {min($Vars(current:memory), $max)}]
		if {[info exists Options($name:memory)]} {
			set Vars(current:memory) [expr {min($Options($name:memory), $Vars(current:memory))}]
		}
	} else {
		$Vars(widget:memory) configure -state disabled
	}

	if {[info exists features(smp)] || [info exists features(threads)]} {
		set ncpus [::system::ncpus]
		if {[info exists features(threads)]} {
			lassign $features(threads) min max
			set ncpus [expr {min($max, $ncpus)}]
		}
		$Vars(widget:cores) configure -state readonly -from 1 -to $ncpus
		if {[info exists Options($name:cores)]} {
			set Vars(current:cores) [expr {min($Options($name:cores), $ncpus)}]
		} else {
			set Vars(current:cores) [expr {min($Vars(current:cores), $ncpus)}]
		}
	} else {
		$Vars(widget:cores) configure -state disabled
	}

	SetTitle $list
	SetupClearHash $Vars(current:name)
	SetupProfiles
}


proc SetupClearHash {engineName} {
	variable EmptyEngine
	variable Engines
	variable Vars

	if {$Vars(current:name) ne $Vars(active:name)} {
		set state disabled
	} else {
		set i [FindIndex $engineName]
		array set engine $EmptyEngine
		array set engine [lindex $Engines $i]
		set protocol $Vars(current:protocol)
		array set features $engine(Features:$protocol)

		if {$Vars(active:id) == -1 || ![::scidb::engine::active? $Vars(active:id)]} {
			set state disabled
		} elseif {[info exists features(clearHash)]} {
			set state normal
		} else {
			set state disabled
		}
	}
	$Vars(widget:clearHash) configure -state $state
}


proc SetTitle {list} {
	variable Engines

	array set engine [lindex $Engines [$list curselection]]
	wm title [winfo toplevel $list] [format $mc::SetupEngine $engine(Name)]
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

	if {![winfo exists $text]} { return }

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
		array set engine [lindex $Engines $item]
		if {$Var(Name) eq $engine(Name)} { return }

		if {![DiscardChanges $list]} {
			$list select $Priv(selection)
			return
		}

		array unset engine
		array set engine $EmptyEngine
		array set engine [lindex $Engines $Priv(selection)]
		set logo $engine(ShortId)
		if {[info exists Photo($logo)]} {
			$list set $Priv(selection) [list [lindex $Photo($logo) 1]]
		}
	}

	set Priv(selection) $item
	set entry [lindex $Engines $item]
	array unset engine
	array set engine $EmptyEngine
	array set engine $entry
	FillInfo $list $entry
	foreach protocol $engine(Protocol) {
		set features $engine(Features:$protocol)
	}
	ShowFeatures $list $features $engine(Variants)
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

	if {![arrayEqual Var Var_] || ![arrayEqual Option Option_]} {
		set rc [::dialog::question -parent [winfo toplevel $list] -message $mc::DiscardChanges]
		if {$rc eq "no"} { return 0 }
	}

	return 1
}


proc ShowFeatures {list features variants} {
	variable Priv

	append html "<html>"
	append html "<head><style type='text/css'>body { background-color: #ffdd76; }</style></head>"
	append html "<body>"

	if {"standard" ni $variants} {
		append html "<h3>$mc::NoStandardChess</h3>"
	}

	set count 0
	foreach variant $variants {
		if {$variant ne "standard"} {
			if {[incr count] == 1} { append html "<table cellpadding='5'>" }
			append html "<tr><td style='white-space:nowrap;' valign='top'>"
			append html "<b>$mc::Feature($variant)</b></td>"
			append html "<td>$mc::FeatureDetail($variant)</td>"
			append html "</tr>"
		}
	}

	if {[llength $features] == 0} {
		if {$count} { append html "</table>" }
		append html "<h3>$mc::NoFeaturesAvailable</h3>"
		if {"standard" in $variants && [llength $variants] == 1} {
			append html "<p align='center'>"
			append html "<img src='Smiley-Cry-128x128.png' style='padding-top: 50px;' /></p>"
		}
	} else {
		if {$count == 0} { append html "<table cellpadding='5'>" }

		foreach {name value} $features {
			append html "<tr><td style='white-space:nowrap;' valign='top'>"
			append html "<b>$mc::Feature($name)</b></td>"

			switch $name {
				analyze - pause - playOther - clearHash - ponder -  skillLevel - smp {
					append html "<td>$mc::FeatureDetail($name)</td>"
				}
				multiPV {
					append html "<td>[format $mc::FeatureDetail($name) $value]</td>"
				}
				hashSize {
					if {[llength $value] == 0} {
						set min 4
						set max [MemTotal]
					} else {
						lassign $value min max
					}
					set map [list %min $min %max $max]
					append html "<td>[string map $map $mc::FeatureDetail($name)]</td>"
				}
				limitStrength - threads {
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
				if {[tk windowingsystem] eq "x11"} { set prot XBoard } else { set prot WinBoard }
				if {[llength $engine(Protocol)] == 2} {
					set Var(protocol) "UCI, $prot"
				} elseif {"UCI" in $engine(Protocol) } {
					set Var(protocol) "Universal Chess Interface (UCI)"
				} else {
					set Var(protocol) "Chess Engine Communication Protocol ($prot)"
				}
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
			Variants {
				set variants {}
				foreach variant $engine(Variants) {
					switch $variant {
						suicide - giveaway - losers {}
						default { lappend variants $mc::Variant($variant) }
					}
				}
				array set used {}
				foreach variant $engine(Variants) {
					switch $variant {
						suicide - giveaway - losers {
							set name $mc::Variant($variant)
							if {![info exists used($name)]} {
								lappend variants $name
								set used($name) 1
							}
						}
					}
				}
				set Var(variants) [join $variants  ", "]
			}
			Profiles:UCI - Profiles:WB {
				;# skip
			}
			default {
				set Var($attr) $engine($attr)
			}
		}
	}

	if {$engine(UserDefined)} { set state normal } else { set state disabled }
	$Priv(button:delete) configure -state $state

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
	variable Var
	variable Var_
	variable Priv

	if {[arrayEqual Var Var_]} { set state disabled } else { set state normal }
	$Priv(button:save) configure -state $state
}


proc FilterOptions {protocol options} {
	if {$protocol eq "WB"} { return $options }
	set optionList {}

	foreach opt $options {
		lassign $opt name type value dflt var max
		switch $type {
			spin {
				switch $name {
					Hash - Threads - MultiPV - {Skill Level} {}
					default { lappend optionList $opt }
				}
			}
			check {
				switch $name {
					Ponder {}
					default { lappend optionList $opt }
				}
			}
			combo {
				switch $name {
					{Playing Style} {}
					default { lappend optionList $opt }
				}
			}
			button  {}
			default { lappend optionList $opt }
		}
	}

	return $optionList
}


proc OpenAdministration {dlg} {
	variable Vars

	openAdmininstration $dlg
	SetupEngineList
	set i [FindIndex $Vars(current:name)]
	if {$i == -1} { set i 0 }
	$Vars(list:engines) select $i
}


proc DeleteProfile {parent} {
	variable Engines
	variable Vars

	set msg [format $mc::ReallyDeleteProfile $Vars(current:profile)]
	set reply [::dialog::question -parent $parent -message $msg]
	if {$reply eq "no"} { return }

	set i [FindIndex $Vars(current:name)]
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	set profiles $engine(Profiles:$protocol)
	set k [FindProfileIndex $profiles]
	set profiles [lreplace $profiles $k [expr {$k + 1}]]
	set engine(Profiles:$protocol) $profiles
	lset Engines $i [array get engine]
	set Vars(current:profile) Default
	SaveEngineList
	SetupProfiles
	$Vars(list:profiles) select 0
}


proc RenameProfile {parent} {
	variable NewProfile_ ""
	variable OldProfile_
	variable Vars

	set profileName $Vars(current:profile)
	if {$profileName eq "Default"} { set profileName $::mc::Default }
	set OldProfile_ $profileName

	set dlg [tk::toplevel $parent.renameProfile -class Scidb]
	pack [set top [ttk::frame $dlg.top -takefocus 0]]
	wm withdraw $dlg

	ttk::label $top.old -text "$mc::OldProfileName:"
	ttk::label $top.oldEntry -text $profileName
	ttk::label $top.new -text "$mc::NewProfileName:"
	ttk::entry $top.newEntry -width 20 -textvar [namespace current]::NewProfile_
	grid $top.old -row 1 -column 1 -sticky w
	grid $top.oldEntry -row 1 -column 3 -sticky we
	grid $top.new -row 3 -column 1 -sticky w
	grid $top.newEntry -row 3 -column 3 -sticky we
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid rowconfigure $top {0 2 4} -minsize $::theme::pady
	set Vars(entry:name) $top.newEntry
	::widget::dialogButtons $dlg {ok cancel} -default ok
	$dlg.ok configure -command [namespace code [list DoRenameProfile $dlg]]
	$dlg.cancel configure -command [list destroy $dlg]
	::util::place $dlg center $parent
	wm resizable $dlg no no
	wm transient $dlg $parent
	wm title $dlg $mc::RenameProfile
	::ttk::grabWindow $dlg
	wm deiconify $dlg
	focus $top.newEntry
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc DoRenameProfile {dlg} {
	variable NewProfile_
	variable OldProfile_
	variable Engines
	variable Vars

	set NewProfile_ [string trim $NewProfile_]
	if {[string length $NewProfile_] == 0} { return }
	if {![CheckProfileName $dlg $NewProfile_]} { return }
	if {$NewProfile_ eq $OldProfile_} { return }

	lappend Vars(profiles) $NewProfile_
	set i [FindIndex $Vars(current:name)]
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	set profiles $engine(Profiles:$protocol)
	set k [FindProfileIndex $profiles]
	set profiles [lreplace $profiles $k $k $NewProfile_]
	set engine(Profiles:$protocol) $profiles
	lset Engines $i [array get engine]
	SaveEngineList
	SetupProfiles
	set Vars(current:profile) $NewProfile_
	set k [lsearch -exact $Vars(profiles) $NewProfile_]
	$Vars(list:profiles) select $k
	destroy $dlg
}


proc NewProfile {parent} {
	variable NewProfile_ ""
	variable CopyFrom_ ""
	variable Vars

	set dlg [tk::toplevel $parent.newProfile -class Scidb]
	pack [set top [ttk::frame $dlg.top -takefocus 0]]
	wm withdraw $dlg

	ttk::label $top.new -text "$mc::ProfileName:"
	ttk::entry $top.name -width 20 -textvar [namespace current]::NewProfile_
	grid $top.new -row 1 -column 1 -sticky w
	grid $top.name -row 1 -column 3 -sticky we
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid rowconfigure $top {0 2} -minsize $::theme::pady
	set Vars(entry:name) $top.name
	set CopyFrom_ [lindex $Vars(profiles) 0]

	if {[llength $Vars(profiles)] > 1} {
		ttk::label $top.copy -text "$mc::CopyFrom:"
		ttk::combobox $top.profiles \
			-values $Vars(profiles) \
			-textvar [namespace current]::CopyFrom_ \
			-state readonly \
			;
		grid $top.copy -row 3 -column 1 -sticky w
		grid $top.profiles -row 3 -column 3 -sticky we
		grid rowconfigure $top {4} -minsize $::theme::pady
	}

	::widget::dialogButtons $dlg {ok cancel} -default ok
	$dlg.ok configure -command [namespace code [list MakeProfile $dlg]]
	$dlg.cancel configure -command [list destroy $dlg]

	::util::place $dlg center $parent
	wm resizable $dlg no no
	wm transient $dlg $parent
	wm title $dlg $mc::NewProfile
	::ttk::grabWindow $dlg
	wm deiconify $dlg
	focus $top.name
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc MakeProfile {dlg} {
	variable NewProfile_
	variable CopyFrom_
	variable Engines
	variable Vars

	set NewProfile_ [string trim $NewProfile_]
	if {[string length $NewProfile_] == 0} { return }
	if {![CheckProfileName $dlg $NewProfile_]} { return }

	set copy $CopyFrom_
	if {$copy eq $::mc::Default} { set copy Default }
	lappend Vars(profiles) $NewProfile_
	set i [FindIndex $Vars(current:name)]
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	array set profiles $engine(Profiles:$protocol)
	set options $profiles($copy)
	unset profiles
	set profiles $engine(Profiles:$protocol)
	lappend profiles $NewProfile_ $options
	set engine(Profiles:$protocol) $profiles
	lset Engines $i [array get engine]
	set Vars(current:profile) $NewProfile_
	SaveEngineList
	SetupProfiles
	$Vars(list:profiles) select end
	destroy $dlg
}


proc CheckProfileName {parent name} {
	variable Vars

	if {$name in $Vars(profiles)} {
		set msg [format $mc::ProfileAlreadyExists $name]
		::dialog::error -parent $parent -message $msg -detail $mc::ChooseDifferentName
		focus $Vars(entry:name)
		$Vars(entry:name) selection range 0 end
		return 0
	}
	if {$name eq "Default"} {
		set msg [format $mc::ReservedName $name]
		::dialog::error -parent $parent -message $msg -detail $mc::ChooseDifferentName
		focus $Vars(entry:name)
		$Vars(entry:name) selection range 0 end
		return 0
	}

	return 1
}


proc OpenSetupEngineDialog {parent} {
	variable EmptyEngine
	variable Engines
	variable Vars

	set i [FindIndex $Vars(current:name)]
	array set engine $EmptyEngine
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	OpenSetupDialog($engine(ProfileType)) $parent
}


proc OpenSetupDialog(Script) {parent} {
	variable EmptyEngine
	variable Engines
	variable Vars

	set i [FindIndex $Vars(current:name)]
	array set engine $EmptyEngine
	array set engine [lindex $Engines $i]
	array set profiles $engine(Profiles:WB)
	set script $profiles($Vars(current:profile))

	set dlg [tk::toplevel $parent.confScript -class Scidb]
#	pack [set top [ttk::frame $dlg.top -takefocus 0]] -fill both -expand yes
	pack [set main [tk::panedwindow $dlg.main -orient vertical -opaqueresize true]] -fill both -expand yes
	wm withdraw $dlg
	set width 60

	### text pane ###########################################################
	set edit [ttk::frame $main.edit]
	tk::text $edit.txt \
		-width $width \
		-height 10 \
		-background white \
		-foreground black \
		-borderwidth 1 \
		-relief sunken \
		-setgrid on \
		-xscrollcommand [list ::scrolledframe::sbset $edit.hsb] \
		-yscrollcommand [list $edit.vsb set] \
		-wrap none \
		-undo no \
		-font TkFixedFont \
		;
	::scidb::tk::misc setClass $edit.txt Script
	ttk::scrollbar $edit.hsb -orient horizontal -command [list $edit.txt xview]
	ttk::scrollbar $edit.vsb -orient vertical -command [list $edit.txt yview]
	grid $edit.txt -row 1 -column 1 -sticky nsew
	grid $edit.hsb -row 2 -column 1 -sticky we
	grid $edit.vsb -row 1 -column 2 -sticky ns
	grid columnconfigure $edit {1} -weight 1
	grid rowconfigure $edit {1} -weight 1
	$main paneconfigure $edit -sticky nswe -stretch always
	$main add $edit

	$edit.txt tag configure comment -foreground darkgreen
	$edit.txt tag configure error -foreground darkred
	foreach line $script {
		ScriptInsertLine $edit.txt $line
		$edit.txt insert end \n
	}
	$edit.txt mark set insert 1.0
	set Vars(script:content) [split [$edit.txt get 1.0 end] \n]
	set Vars(script:original) $Vars(script:content)
	bind $edit.txt <<Modified>> [namespace code [list ScriptUpdate $edit.txt]]
#	bind $edit.txt <<Undo>> [namespace code [list ScriptUndo $edit.txt]]
#	bind $edit.txt <<Redo>> [namespace code [list ScriptRedo $edit.txt]]

	### log pane ############################################################
	set log [ttk::frame $main.log]
	tk::text $log.txt \
		-width $width \
		-background #ebf4f5 \
		-height 4 \
		-yscrollcommand [list $log.vsb set] \
		-takefocus 0 \
		-wrap word \
		-undo no \
		-font TkFixedFont \
		-cursor left_ptr \
		;
	ttk::scrollbar $log.vsb -orient vertical -command [list ::widget::textLineScroll $log.txt]
	grid $log.txt -row 1 -column 1 -sticky nsew
	grid $log.vsb -row 1 -column 2 -sticky ns
	grid columnconfigure $log {1} -weight 1
	grid rowconfigure $log {1} -weight 1
	$main paneconfigure $log -sticky nswe -stretch never
	$main add $log

	$log.txt tag configure error -foreground darkred
	$log.txt insert end $mc::ScriptErrors hint
	$log.txt configure -state disabled

	### buttons ##############################################################
	::widget::dialogButtons $dlg {save cancel reset help} -default save
	$dlg.cancel configure -command [namespace code [list AskCloseSetup $dlg.save]]
	$dlg.save configure -state disabled -command [namespace code [list SaveScript $edit.txt $log.txt]]
	$dlg.reset configure -command [namespace code [list ResetScript $edit.txt]]
	::tooltip::tooltip $dlg.reset [namespace current]::mc::ResetToDefaultContent

	### popup ################################################################
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg center .
	wm resizable $dlg yes yes
	wm transient $dlg $parent
	wm title $dlg "$engine(Name) - [format $mc::EditProfile $Vars(current:profile)]"
	::ttk::grabWindow $dlg
	wm deiconify $dlg
	focus $edit.txt
	update idletasks
	$main paneconfigure $log -minsize [winfo height $main.log]
	$main paneconfigure $edit -minsize [winfo height $main.log]
	if {[scan [wm grid $dlg] "%d %d" w h] >= 2} {
		wm minsize $dlg $w $h
	}
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc AskCloseSetup {saveBtn} {
	set dlg [winfo toplevel $saveBtn]

	if {[$saveBtn cget -state] == "normal"} {
		set reply [::dialog::question -message $mc::ThrowAwayChanges -parent $dlg]
		if {$reply eq "no"} { return }
	}

	destroy $dlg
}


proc ResetScript {txt} {
	variable Engines
	variable Vars

	set i [FindIndex $Vars(current:name)]
	array set engine [lindex $Engines $i]
	array set profiles $engine(Profiles:WB)
	set script $engine(Script:Default)
	$txt delete 1.0 end

	foreach line $engine(Script:Default) {
		ScriptInsertLine $txt $line
		$txt insert end \n
	}

	$txt mark set insert 1.0
	$txt see 1.0

	set content [split [$txt get 1.0 end] \n]
	if {$Vars(script:original) eq $content} { set state disabled } else { set state normal }
	[winfo toplevel $txt].save configure -state $state
	set Vars(script:content) $content
}


proc SaveScript {txt log} {
	variable Engines
	variable Option
	variable Vars

	set i [FindIndex $Vars(current:name)]
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	set profiles $engine(Profiles:$protocol)
	set script {}
	$log configure -state normal
	$log delete 1.0 end
	set cur [$txt index insert]
	set row 1
	set errCount 0

	foreach line $Vars(script:content) {
		set line [string trim $line]
		if {[string length $line]} {
			# smpmt mt cores memory
			if {[regexp {^([a-z]+)[= \t]} $line _ cmd]} {
				if {$cmd in {smpmt mt cores memory}} {
					$log insert end [format $mc::CommandNotAllowed $cmd] error
					$txt delete $row.0 $row.end
					$txt insert $row.0 $line error
					incr errCount
				}
			}
			incr row
			lappend script $line
		}
	}
	$txt mark set insert $cur
	$log configure -state disabled

	if {$errCount == 0} {
		set k [expr {[FindProfileIndex $profiles] + 1}]
		lset profiles $k $script
		set engine(Profiles:$protocol) $profiles
		lset Engines $i [array get engine]

		SaveEngineList
		destroy [winfo toplevel $txt]
	}
}


proc ScriptUpdate {txt} {
	variable Vars

	set content [split [$txt get 1.0 end] \n]

	set row 1
	set cur [$txt index insert]

	foreach old $Vars(script:content) new $content {
		if {$old ne $new} {
			$txt delete $row.0 $row.end
			$txt mark set insert $row.0
			ScriptInsertLine $txt $new
		}
		incr row
	}

	$txt mark set insert $cur
	if {$Vars(script:original) eq $content} { set state disabled } else { set state normal }
	[winfo toplevel $txt].save configure -state $state
	set Vars(script:content) $content
}


proc ScriptInsertLine {txt line} {
	set n [string first "#" $line]
	if {$n == -1} {
		$txt insert insert $line
	} else {
		$txt insert insert [string range $line 0 [expr {$n - 1}]]
		$txt insert insert [string range $line $n end] comment
	}
}


proc OpenSetupDialog(Options) {parent} {
	variable EmptyEngine
	variable Engines
	variable Option
	variable Option_
	variable Vars

	if {[winfo screenwidth $parent] >= 1500} { set vertical 0 } else { set vertical 1 }

	set dlg [tk::toplevel $parent.confOptions -class Scidb]
#	if {$vertical} { set expand x } else { set expand y }
#	set scrolled [::scrolledframe $dlg.top -expand $expand]
	set scrolled [::scrolledframe $dlg.top]
	pack $dlg.top
	set top [ttk::frame $scrolled.f -borderwidth 0 -takefocus 0]
	grid $scrolled.f -sticky nsew
	wm withdraw $dlg

	set i [FindIndex $Vars(current:name)]
	array set engine $EmptyEngine
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	set directory $engine(Directory)
	array set profiles $engine(Profiles:$protocol)
	set options [FilterOptions $protocol $profiles($Vars(current:profile))]

	array unset Option
	array unset Option_
	array set Option {}
	array set Option_ {}
	set n [llength $options]

	if {$vertical} {
		if {$n > 12} { set numCols 2 } else { set numCols 1 }
		set wrapLength [expr {([winfo screenwidth $parent] - 760)/$numCols}]
	} else {
		set maxRows [expr {[winfo screenheight $parent]/45}]
		set numCols [expr {($n + $maxRows - 1)/$maxRows}]
		if {$n > 12} { set numCols [expr {max(2, $numCols)}] }
	}
	set numRows [expr {($n + $numCols  - 1)/$numCols}]

	for {set i 0} {$i < $numCols} {incr i} {
		set pane [ttk::frame $top.pane$i -takefocus 0]
		grid columnconfigure $pane {0 2 4 6} -minsize $::theme::padx
		grid $pane -row 1 -column [expr {2*$i + 1}] -sticky n
		if {$i > 0} {
			set sep [ttk::separator $top.sep$i -orient vertical]
			grid $sep -row 1 -column [expr {2*$i}] -sticky ns
			grid columnconfigure $top [expr {2*$i}] -minsize 10
		}
	}
	set pane $top.pane0
	set nrows 0
	set ncols 0
	set row 1
	set uniform {1}
	set rows {0}
	set focus ""

	foreach opt $options {
		lassign $opt name type value dflt var max
		set lbl $pane.lbl_$row
		set val $pane.val_$row
		set see $val
		set sticky w

		if {$protocol eq "UCI" && $type eq "spin" && $max - $var <= 400} { set type slider }

		switch $type {
			spin {
				ttk::label $lbl -text $name
				set n [expr {max(1, max(abs($var), abs($max)))}]
				set width [expr {int(log10($n)) + 2}]
				ttk::frame $val -borderwidth 0 -takefocus 0
				set see [ttk::spinbox $val.s -from $var -to $max -width $width -takefocus 1]
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
				set see $val
				::theme::enableScale $val
				if {$max - $var > 200} {
					$val configure -length 300
				} elseif {$max - $var > 20} {
					$val configure -length 200
				}
			}
			check {
				ttk::label $lbl -text $name
				ttk::checkbutton $val \
					-takefocus 1 \
					-variable [namespace current]::Option($name) \
					-offvalue false \
					-onvalue true \
					;
			}
			combo {
				ttk::label $lbl -text $name
				ttk::combobox $val \
					-values [SplitComboEntries $var] \
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
				set see [ttk::entry $val.e -textvar [namespace current]::Option($name) -takefocus 1]
				ttk::button $val.b \
					-style icon.TButton \
					-image $::fsbox::icon::16x16::folder \
					-command [namespace code [list GetPath($type) $dlg $name $dflt $directory]] \
					;
				::tooltip::tooltip $val.b $mc::OpenFsbox
				grid $val.e -column 0 -row 0 -sticky we
				grid $val.b -column 2 -row 0
				grid columnconfigure $val {1} -minsize $::theme::padx
				grid columnconfigure $val {0} -weight 1
				set sticky ew
			}
			button {
				ttk::label $lbl -text ""
				ttk::button $val \
					-text $name \
					-takefocus 1 \
					-command [namespace code [list InvokeButton $name]] \
					;
				if {	$Vars(active:name) ne $Vars(current:name)
					|| $Vars(active:id) == -1
					|| ![::scidb::engine::active? $Vars(active:id)]} {
					$val configure -state disabled
				}
			}
		}

		if {$type ne "button"} {
			set btn $pane.btn_$row
			ttk::button $btn \
				-image [::icon::makeStateSpecificIcons $::icon::12x12::reset] \
				-command [list set [namespace current]::Option($name) $dflt] \
				;
			::tooltip::tooltip $btn "$mc::ResetToDefault: $dflt"
			grid $btn -row $row -column 1
			set args [list variable [namespace current]::Option($name) write \
							[namespace code [list SetOptionState $dlg $val $name $dflt $btn]]]
			trace add {*}$args
			bind $btn <Destroy> [list trace remove {*}$args]
		}

		if {$vertical} { $lbl configure -wraplength $wrapLength }
		bind $see <<TraverseIn>> [namespace code [list $scrolled see %W]]
		if {!$vertical} {
			if {$type eq "button"} { set w $val } else { set w $btn }
			bind $see <<TraverseIn>> +[namespace code [list $scrolled see $w]]
		}
		bind $see <FocusIn> {+ ::tooltip::tooltip hide }
		if {[winfo exists $lbl]} { grid $lbl -row $row -column 3 -sticky w }
		if {[string length $focus] == 0} { set focus $see }

		grid $val -row $row -column 5 -sticky $sticky
		lappend uniform $row
		lappend rows [incr row]
		incr row

		if {[incr nrows] == $numRows} {
			grid rowconfigure $pane $rows -minsize 8
			grid rowconfigure $pane $uniform -uniform all
			set pane $top.pane[incr ncols]
			set uniform {1}
			set rows {0}
			set nrows 0
			set row 1
		}

		set Option($name) $value
		set Option_($name) $value
	}

	if {[winfo exists $pane]} {
		grid rowconfigure $pane $rows -minsize 8
		grid rowconfigure $pane $uniform -uniform all
	}

	::widget::dialogButtons $dlg {save cancel} -default save
	$dlg.cancel configure -command [namespace code [list AskCloseSetup $dlg.save]]
	$dlg.save configure -state disabled -command [namespace code [list SaveOptions $dlg]]

	update idletasks
	$scrolled configure -height [expr {min([winfo reqheight $top], [winfo screenheight $top] - 120)}]
	$scrolled configure -width [expr {min([winfo reqwidth $top], [winfo screenwidth $top] - 20)}]

	set profileName $Vars(current:profile)
	if {$Vars(current:profile) eq "Default"} { set profileName $::mc::Default }

	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg center .
	wm resizable $dlg no no
	wm transient $dlg $parent
	wm title $dlg "$engine(Name) - [format $mc::EditProfile $Vars(current:profile)]"
	::ttk::grabWindow $dlg
	wm deiconify $dlg
	focus $focus
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc InvokeButton {name} {
	variable Vars
	::scidb::engine::invoke $Vars(active:id) $name
}


proc FindProfileIndex {profileList} {
	variable Vars

	set k 0
	foreach {profile _} $profileList {
		if {$profile eq $Vars(current:profile)} { return $k }
		incr k 2
	}
	return -1
}


proc SaveOptions {dlg} {
	variable Engines
	variable Option
	variable Vars

	set i [FindIndex $Vars(current:name)]
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	set profiles $engine(Profiles:$protocol)
	set k [expr {[FindProfileIndex $profiles] + 1}]
	set options [lindex $profiles $k]
	set newOptions {}

	foreach opt $options {
		lassign $opt name type value dflt var max
		if {[info exists Option($name)]} { lset opt 2 $Option($name) }
		lappend newOptions $opt
	}

	lset profiles $k $newOptions
	set engine(Profiles:$protocol) $profiles
	lset Engines $i [array get engine]

	SaveEngineList
	destroy $dlg
}


proc ClearHash {} {
	variable Vars

	if {$Vars(active:id) == -1} { return }
	if {![::scidb::engine::active? $Vars(active:id)]} { return }
	::scidb::engine::clearHash $Vars(active:id)
}


proc GetPath(file) {parent key dflt dir} {
	variable Option
	variable Priv

	set ext [file extension $dflt]
	set checkexistence no
	set ft  ""

	if {[string length $ext] == 0} {
		set filetypes {}
	} else {
		set filetypes [list [list $ft $ext]]
		set suf [string range $ext 1 end]
		if {[info exists ::dialog::fsbox::mc::FileType($suf)]} {
			set ft $::dialog::fsbox::mc::FileType($suf)
		}
		if {$ext eq ".bin"} { set checkexistence yes }
	}

	set initialdir $dir
	if {[string length $initialdir] == 0} { set initialdir $::scidb::dir::home }

	set result [::dialog::openFile \
		-parent $parent \
		-initialdir $initialdir \
		-initialfile $dflt \
		-filetypes $filetypes \
		-needencoding no \
		-checkexistence $checkexistence \
		-geometry last \
	]

	if {[llength $result]} {
		if {[string length $dir] > 0} {
			set file [lindex $result 0]
			set path [file dirname $file]
			if {[string match $dir* $path]} {
				set file [string range $file [string length $dir] end]
				if {[string index $file 0] eq [file separator]} {
					set file [string range $file 1 end]
				}
			}
		}
		set Option($key) $file
	}
}


proc GetPath(path) {parent key dflt dir} {
	variable Option
	variable Priv

	if {[string length $dflt] > 0 && [file isdirectory $dflt]} {
		set initialdir $dflt
	} elseif {[string length $dir] == 0} {
		set initialdir $::scidb::dir::home
	} else {
		set initialdir $dir
	}

	set result [::dialog::chooseDir \
		-parent $parent \
		-initialdir $initialdir \
		-checkexistence yes \
		-geometry last \
	]

	if {[llength $result]} {
		set path [lindex $result 0]
		if {[string match $dir* $path]} {
			set path [string range $path [string length $dir] end]
			if {[string index $path 0] eq [file separator]} {
				set path [string range $path 1 end]
			}
		}
		set Option($key) $path
	}
}


proc SetOptionState {dlg val key dflt btn args} {
	variable Option
	variable Option_

	if {[winfo exists $dlg.save]} {
		if {[arrayEqual Option Option_]} { set state disabled } else { set state normal }
		$dlg.save configure -state $state
	}
	if {$Option($key) eq $dflt} { set state disabled } else { set state normal }
	$btn configure -state $state
	if {[winfo class $val] eq "TCheckbutton"} {
		$val configure -text [expr {$Option($key) ? "true" : "false"}]
	}
}


proc SplitComboEntries {s} {
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


proc UseProfile {item} {
	variable Options
	variable Vars

	if {[llength $item] == 0} { return }
	set Vars(selection) $item

	if {$item == 0} {
		set Vars(current:profile) Default
		set state disabled
	} else {
		set Vars(current:profile) [$Vars(list:profiles) get name]
		set state normal
	}

	set Options($Vars(current:name):profile) $Vars(current:profile)

	foreach op {rename delete} {
		$Vars(widget:$op) configure -state $state
	}

	foreach op {edit new} {
		$Vars(widget:$op) configure -state normal
	}
}


proc SetupProfiles {} {
	variable EmptyEngine
	variable Engines
	variable Options
	variable Vars

	set w $Vars(list:profiles)
	set i [FindIndex $Vars(current:name)]
	array set engine $EmptyEngine
	array set engine [lindex $Engines $i]
	set protocol $Vars(current:protocol)
	set Options($engine(Name):protocol) $protocol
	set profiles $engine(Profiles:$protocol)
	set Vars(profiles) {}

	$w clear
	if {[llength [$w columns]] == 0} {
		$w addcol text -id name
	}

	set i 0
	foreach {profile _} $profiles {
		if {$i == 0} { set profile $::mc::Default }
		lappend Vars(profiles) $profile
		$w insert [list $profile]
		incr i
	}
	$w resize

	if {$i > 0} {
		$w configure -background white
		set i 0
		if {[info exists Options($Vars(current:name):profile)]} {
			set k [lsearch -exact $Vars(profiles) $Options($Vars(current:name):profile)]
			if {$k >= 0} { set i $k }
		}
		$w select $i
	} else {
		$w configure -background lightgray
		foreach op {edit new rename delete} {
			$Vars(widget:$op) configure -state disabled
		}
	}
}


proc SetupEngineList {} {
	variable EmptyEngine
	variable Engines
	variable Vars

	set w $Vars(list:engines)

	if {[llength [$w columns]] == 0} {
		$w addcol text -id name
	}

	$w clear

	foreach entry $Engines {
		array unset engine
		array unset features
		array set engine $EmptyEngine
		array set engine $entry
		foreach protocol $engine(Protocol) {
			array set features $engine(Features:$protocol)
		}
		if {[info exists features(analyze)]} {
			$w insert [list $engine(Name)]
		}
	}

	$w resize
	set Vars(selection) -1
}


proc MakeEngineList {w height} {
	variable Logo

	::tlistbox $w \
		-usescroll yes \
		-padx 5 \
		-pady 7 \
		-linespace $Logo(height) \
		-height $height \
		-selectmode browse \
		;
	RebuildEngineList $w

	return $w
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
				$list insert [list $engine(Name)]
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
	::scidb::tk::wm frameless $wait
	wm deiconify $wait
	::ttk::grabWindow $wait
	::widget::busyCursor on
	set error ""
	update idletasks

	for {set i 0} {$i < 2} {incr i} {
		set res [::scidb::engine::probe $engine(Command) $::scidb::dir::log $protocol($i) 2000]

		switch [lindex $res 0] {
			failed - undecidable {}

			ok {
				set prot $protocol($i)
				set result($prot) $res
				lappend protocols $prot
			}

			default { set error $res }
		}
	}

	destroy $wait
	::widget::busyCursor off
	::ttk::releaseGrab $wait

	if {[lindex $res 0] eq "error"} {
		::dialog::error -parent $parent -message $mc::CannotOpenProcess
		return {}
	}

	if {[string length $error]} {
		::dialog::error -parent $parent -message $mc::ProbeError($error)
		if {[llength $protocols] == 0} { return {} }
	}

	if {[llength $protocols] == 0} {
		::dialog::error -parent $parent -message $mc::DoesNotRespond
		return {}
	}

	foreach prot $protocols {
		lassign $result($prot) ok info variants features options

		# setup information
		array set engine $info
		if {[info exists engine(Author)]} {
			set engine(Author) [string map [list " and " " & "] $engine(Author)]
		}
		if {[llength $options]} {
			set engine(Profiles:$prot) [list Default $options]
		} else {
			set engine(Profiles:$prot) [list Default {}]
			if {$prot eq "WB"} { set engine(ProfileType) Script }
		}
		set engine(Variants) $variants
		array set fts $features

		if {[info exists fts(hashSize)]} {
			lassign $fts(hashSize) min max
			if {$max == 0} {
				set fts(hashSize) {}
			} else {
				set min [expr {max(4, $min)}]
				if {$max > 0 && $min >= $max} {
					array unset fts hashSize
				} else {
					set min [::scidb::misc::succPow2 $min]
					if {$max > 0} { set max [::scidb::misc::predPow2 $max] }
					set fts(hashSize) [list $min $max]
				}
			}
		}
		if {[info exists fts(threads)]} {
			lassign $fts(threads) min max
			set min [expr {max(1, $min)}]
			if {$min >= $max} {
				array unset fts threads
			} else {
				set fts(threads) [list $min $max]
			}
		}
		set engine(Features:$prot) [array get fts]
		set hasAnalyze($prot) [info exists fts(analyze)]
	}

	if {[llength $protocols] == 2} {
		# Ignore WinBoard protocol if UCI protocol is supported and:
		# 1. WinBoard don't has an analyze feature or
		# 2. does not have options
		if {!$hasAnalyze(WB) || [llength $engine(Profiles:WB)] == 0} {
			set protocols {UCI}
		}
	}

	if {[llength $protocols] == 2} {
		set engine(Protocol) {UCI WB}
	} else {
		set engine(Protocol) [lindex $protocols 0]
	}

	array unset result
	set result {}
	if {[info exists engine(Name)] && [string length $engine(Name)]} {
		set result [::scidb::engine::info $engine(Name)]
	} else {
		set engine(Name) $engine(Identifier)
	}
	if {[llength $result]} {
		lassign $result _ country _ ccrl _ _ _ url aliases
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
		if {![info exists engine(CCRL)]} { set engine(CCRL) $ccrl }
		if {![info exists engine(Country)]} { set engine(Country) $country }
		if {![info exists engine(Url)]} { set engine(Url) $url }
	}
	if {![info exists engine(ShortId)]} {
		set engine(ShortId) $engine(Name)
	}

	set dir [string map {" " "-"} $engine(ShortId)]
	set engine(Directory) [file join $::scidb::dir::user engines $dir]

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

		array unset engine
		array set engine [lindex $Engines $sel]

		foreach attr [array names engine] {
			switch $attr {
				Country {
					set engine(Country) [$Priv(countrybox) value]
				}
				Variant - Profiles:UCI - Profiles:WB {
					;# alreay set
				}
				Directory {
					if {[info exists Var(Directory)] && [string length $Var(Directory)] > 0} {
						set failed 0
						set Var(Directory) [file normalize $Var(Directory)]
						if {	[string length $engine(Directory)] > 0
							&& [file isdirectory $engine(Directory)]
							&& ![file isdirectory $Var(Directory)]} {
							if {[catch { file rename $engine(Directory) $Var(Directory) }]} {
								set failed 1
							}
						}
						if {![file isdirectory $Var(Directory)]} {
							if {[catch { file mkdir $Var(Directory) }]} {
								set failed 1
							}
						}
					}
					if {$failed} {
						set msg [format $mc::FailedToCreateDir $Var(Directory)]
						return [::dialog::error -parent [winfo toplevel $list] -message $msg]
					}
					set engine(Directory) $Var(Directory)
				}
				default {
					if {[info exists Var($attr)]} {
						set engine($attr) $Var($attr)
					}
				}
			}
		}

		set engine(Timestamp) [clock seconds]
		lset Engines $sel [array get engine]
	}

	SaveEngineList
	UpdateVars
}


proc SaveEngineList {} {
	set filename $::scidb::file::engines
	set f [open $filename.tmp "w"]
	fconfigure $f -encoding utf-8

	if {[catch {
		::options::writeHeader $f engines
		::options::writeList $f [namespace current]::Engines
	}]} {
		close $f
		file delete -force $filename.tmp
		append msg $::util::mc::IOErrorOccurred
		append msg ": "
		append msg $::util::mc::IOError(WriteFailed)
		append msg "."
		append detail [format $::fsbox::mc::PermissionDenied [file dirname $filename.tmp]]
		::dialog::error -parent .application -topmost yes -message $msg -detail $detail
	} else {
		close $f
		file rename -force $filename.tmp $filename
	}

	::options::unhookWriter [namespace current]::WriteEngineOptions engines
}


proc UpdateVars {} {
	variable Var
	variable Var_
	variable Priv

	array set Var_ [array get Var]
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
	UpdateVars
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
	set newEntry {}
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
			array unset engine
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
		::widget::dialogButtons $dlg {ok cancel} -default ok
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

	array unset engine
	array set engine $newEntry
	set engine(Command) $file
	set newEntry [ProbeEngine $parent [array get engine]]
	if {[llength $newEntry] == 0} { return }
	array unset engine
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
		-showhidden yes \
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
	variable Engines

	set index 0
	foreach entry $Engines {
		array set engine $entry
		if {$engine(Name) eq $name} { return $index }
		incr index
	}

	return -1
}


proc LoadSharedConfiguration {file} {
	variable Engines

	::load::source $file -message $::load::mc::ReadingFile(engines) -encoding utf-8
	set engines {}

	foreach entry $Engines {
		array unset engine
		array set engine $entry

		set engine(Command) "[file join $::scidb::dir::engines $engine(Command)]"

		if {[file executable $engine(Command)]} {
			set result [::scidb::engine::info $engine(Name)]
			if {[llength $result]} {
				lassign $result _ Country _ CCRL _ _ _ Url _
				# We don't like to set the ELO value
				foreach attr {Country CCRL Url} {
					set engine($attr) [set $attr]
				}
			}
			if {![info exists engine(ShortId)]} {
				set engine(ShortId) $engine(Name)
			}
			file stat $engine(Command) st
			set engine(FileTime) $st(mtime)
			set engine(Timestamp) 0
			if {![info exists engine(Directory)]} {
				set dir [file tail $engine(Command)]
				set engine(Directory) [file normalize [file join $::scidb::dir::user engines $dir]]
			}
			if {![file isdirectory $engine(Directory)]} {
				file mkdir $engine(Directory)
				set sharedir [file join $::scidb::dir::share engines [file tail $engine(Command)]]
				set sharedir [file normal $sharedir]
				if {$sharedir ne $engine(Directory) && [file isdirectory $sharedir]} {
					set files [glob -directory $sharedir -nocomplain *]
					if {[llength $files]} {
						file copy {*}$files $engine(Directory)
					}
				}
			}
			set engine(UserDefined) 0
			if {[info exists engine(Profiles:WB)]} {
				foreach {profile options} $engine(Profiles:WB) {
					if {$profile eq "Default"} { set engine(Script:Default) $options }
				}
			}
			lappend engines [array get engine]
		}
	}

	set Engines $engines
	return $engines
}


proc WriteEngineOptions {chan} {
	::options::writeList $chan [namespace current]::Engines
}


proc WriteOptions {chan} {
	variable Options

	foreach attr [array names Options *:profile] {
		set name [lindex [split $attr :] 0]
		if {[FindIndex $name] == -1} { array unset Options $name:* }
	}

	::options::writeItem $chan [namespace current]::Options no
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace engine


ttk::copyBindings Text Script

bind Script <Delete> {
	if {[%W tag nextrange sel 1.0 end] ne ""} {
		%W delete sel.first sel.last
		event generate %W <<Modified>>
	} else {
		%W delete insert
		event generate %W <<Modified>>
		%W see insert
	}
}

bind Script <BackSpace> {
	if {[%W tag nextrange sel 1.0 end] ne ""} {
		%W delete sel.first sel.last
		event generate %W <<Modified>>
	} elseif {[%W compare insert != 1.0]} {
		%W delete insert-1c
		event generate %W <<Modified>>
		%W see insert
	}
}

bind Script <<Cut>> {
	tk_textCut %W
	event generate %W <<Modified>>
}

bind Script <<Copy>> {
	tk_textCopy %W
	event generate %W <<Modified>>
}

bind Script <<Paste>> {
	tk_textPaste %W
	event generate %W <<Modified>>
}

bind Script <<Clear>> {
	catch {%W delete sel.first sel.last}
	event generate %W <<Modified>>
}

bind Script <<PasteSelection>> {
	if {![info exists tk::Priv(mouseMoved)] || !$tk::Priv(mouseMoved)} {
		tk::TextPasteSelection %W %x %y
		event generate %W <<Modified>>
	}
}

bind Script <Insert> {
	catch {tk::TextInsert %W [::tk::GetSelection %W PRIMARY]}
	event generate %W <<Modified>>
}

bind Script <KeyPress> {
	tk::TextInsert %W %A
	event generate %W <<Modified>>
}

bind Script <Control-d> {
	%W delete insert
	event generate %W <<Modified>>
}

bind Script <Control-k> {
	if {[%W compare insert == {insert lineend}]} {
		%W delete insert
	} else {
		%W delete insert {insert lineend}
	}
	event generate %W <<Modified>>
}

bind Script <Control-o> {
	%W insert insert \n
	%W mark set insert insert-1c
	event generate %W <<Modified>>
}

bind Script <Control-t> {
	tk::TextTranspose %W
	event generate %W <<Modified>>
}

bind Script <Return> {+ break }

bind Script <<Undo>> {
	catch { %W edit undo }
	event generate %W <<Modified>>
}

bind Script <<Redo>> {
	catch { %W edit redo }
	event generate %W <<Modified>>
}

bind Script <Meta-d> {
	%W delete insert [tk::TextNextWord %W insert]
	event generate %W <<Modified>>
}

bind Script <Meta-BackSpace> {
	%W delete [tk::TextPrevPos %W insert tcl_startOfPreviousWord] insert
	event generate %W <<Modified>>
}

bind Script <Meta-Delete> {
	%W delete [tk::TextPrevPos %W insert tcl_startOfPreviousWord] insert
	event generate %W <<Modified>>
}

bind Script <Control-h> {
	if {[%W compare insert != 1.0]} {
		%W delete insert-1c
		event generate %W <<Modified>>
		%W see insert
	}
}


# --- Setup engines ----------------------------------------------------
if {[catch {::engine::setup} err]} {
	set msg $::load::mc::EngineSetupFailed
	lappend ::load::Log error "$msg: $err"
	puts "$msg -- $err"
	unset msg err
}

# vi:set ts=3 sw=3:
