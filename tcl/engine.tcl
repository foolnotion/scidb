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

::util::source engine-dialog

namespace eval engine {
namespace eval mc {

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

set ConfirmNewEngine		"Confirm new engine"
set EngineAlreadyExists	"An entry with this engine already exists."
set CopyFromEngine		"Make a copy of entry"
set CannotOpenProcess	"Cannot start process."
set DoesNotRespond		"This engine does not respond either to UCI nor to WinBoard protocol."

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

	set dlg $parent.chooseEngine
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	set Priv(state) edit
	set Priv(engines) {}
	set Priv(selection) -1

	### left frame ########################################################
	set list [::tlistbox $top.list \
		-usescroll yes \
		-padx 5 \
		-pady 7 \
		-linespace $Logo(height) \
		-height 5 \
		-selectmode browse \
	]
	RebuildEngineList $list

	### right frame #######################################################
	set setup [ttk::frame $top.setup -takefocus 0 -borderwidth 0]
	set bg [::theme::getBackgroundColor]
	lappend labelOptions -borderwidth 1 -relief raised -background [::theme::getToplevelBackground]

	ttk::label			$setup.lname -text $mc::Name
	ttk::combobox		$setup.cname \
								-textvar [namespace current]::Var(Name) \
								-height 15 \
								-exportselection no \
								-postcommand [namespace code [list FillCombobox $setup.cname]] \
								;
	ttk::label			$setup.lidentifier -text $mc::Identifier
	ttk::label			$setup.tidentifier -textvar [namespace current]::Var(Identifier) {*}$labelOptions
	ttk::label			$setup.lauthor -text $mc::Author
	ttk::label			$setup.tauthor -textvar [namespace current]::Var(Author) {*}$labelOptions
	ttk::label			$setup.lvariants -text $mc::Variants
	ttk::label			$setup.tvariants -textvar [namespace current]::Var(Variant) {*}$labelOptions
	ttk::label			$setup.ltimestamp -text $mc::LastUsed
	ttk::label			$setup.ttimestamp -textvar [namespace current]::Var(Timestamp) {*}$labelOptions
	ttk::label			$setup.lcommand -text $mc::Command
	ttk::label			$setup.tcommand -textvar [namespace current]::Var(Command) {*}$labelOptions
#	tk::button			$setup.bcommand \
#								-text "..." \
#								-background $bg \
#								-padx 2 \
#								-pady 0 \
#								-command [namespace code [list GetCommand $dlg]] \
#								;
	ttk::label			$setup.lparams -text $mc::Parameters
	ttk::entry			$setup.eparams -textvar [namespace current]::Var(Parameters)
	ttk::label			$setup.lcountry -text $mc::Country
	::countrybox		$setup.ccountry
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
								-text "WinBoard" \
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
								-command [namespace code [list GetLogo $dlg]] \
								;

	::tooltip::tooltip $setup.burl ::playercard::mc::OpenInWebBrowser
	::theme::configureSpinbox $setup.frating.selo
	::theme::configureSpinbox $setup.frating.sccrl
	::validate::spinboxInt $setup.frating.selo
	::validate::spinboxInt $setup.frating.sccrl
	set Priv(countrybox) $setup.ccountry
	set Priv(button:UCI) $setup.fprotocol.buci
	set Priv(button:WB) $setup.fprotocol.bwb

	grid $setup.frating.lelo	-row 1 -column 1
	grid $setup.frating.selo	-row 1 -column 3
	grid $setup.frating.lccrl	-row 1 -column 5
	grid $setup.frating.sccrl	-row 1 -column 7
	grid columnconfigure $setup.frating {2 6} -minsize $::theme::padx
	grid columnconfigure $setup.frating {4} -minsize $::theme::padX

#	grid $setup.fprotocol.bauto	-row 1 -column 1
	grid $setup.fprotocol.buci		-row 1 -column 1
	grid $setup.fprotocol.bwb		-row 1 -column 3
	grid columnconfigure $setup.fprotocol {2} -minsize $::theme::padX

	grid $setup.lname			-row  1 -column 1 -sticky w
	grid $setup.cname			-row  1 -column 3 -sticky we -columnspan 3
	grid $setup.lidentifier	-row  3 -column 1 -sticky w
	grid $setup.tidentifier	-row  3 -column 3 -sticky we -columnspan 3
	grid $setup.lauthor		-row  5 -column 1 -sticky w
	grid $setup.tauthor		-row  5 -column 3 -sticky we -columnspan 3
	grid $setup.lvariants   -row  7 -column 1 -sticky w
	grid $setup.tvariants   -row  7 -column 3 -sticky we -columnspan 3
	grid $setup.ltimestamp	-row  9 -column 1 -sticky w
	grid $setup.ttimestamp	-row  9 -column 3 -sticky we -columnspan 3

	grid $setup.lcountry		-row 11 -column 1 -sticky w
	grid $setup.ccountry		-row 11 -column 3 -sticky we -columnspan 3
	grid $setup.lrating		-row 13 -column 1 -sticky w
	grid $setup.frating		-row 13 -column 3 -sticky w
	grid $setup.lprotocol	-row 15 -column 1 -sticky w
	grid $setup.fprotocol	-row 15 -column 3 -sticky w  -columnspan 3

	grid $setup.lurl			-row 17 -column 1 -sticky w
	grid $setup.eurl			-row 17 -column 3 -sticky we
	grid $setup.burl			-row 17 -column 5 -sticky we
	grid $setup.llogo			-row 19 -column 1 -sticky w
	grid $setup.elogo			-row 19 -column 3 -sticky we
	grid $setup.blogo			-row 19 -column 5 -sticky we

	grid $setup.lcommand		-row 21 -column 1 -sticky w
	grid $setup.tcommand		-row 21 -column 3 -sticky we -columnspan 3
#	grid $setup.bcommand		-row 21 -column 5 -sticky we
	grid $setup.lparams		-row 23 -column 1 -sticky w
	grid $setup.eparams		-row 23 -column 3 -sticky we -columnspan 3

	grid columnconfigure $setup {0 2 4} -minsize $::theme::padx
	grid columnconfigure $setup {3} -weight 1
	grid rowconfigure $setup {0 2 4 6 8 12 14 18 22 24} -minsize $::theme::pady
	grid rowconfigure $setup {10 16 20} -minsize [expr {3*$::theme::pady}] -weight 1

	bind $list <<ListboxSelect>> [namespace code [list Select $list %d]]
	if {[llength $Engines]} { $list select 0 }

	### geoemetry #########################################################
	grid $list	-row 1 -column 1
	grid $setup	-row 1 -column 3 -sticky nswe
	grid rowconfigure $top {0 2} -minsize $::theme::pady
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid columnconfigure $top {3} -weight 1

	::widget::dialogButtons $dlg {new save delete close help} -default close
	$dlg.delete configure -command [namespace code [list DeleteEngine $list]]
	$dlg.save configure -command [namespace code [list SaveEngine $list]]
	$dlg.new configure -command [namespace code [list NewEngine $list]]
	$dlg.close configure -command [list destroy $dlg]

	update idletasks
	wm minsize $dlg [winfo reqwidth $dlg] [winfo reqheight $dlg]
	wm resizable $dlg true false
	wm title $dlg $mc::SetupEngines
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $list

openEngineLog .application
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
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
	::widget::dialogButtons $dlg close
	$dlg.close configure -command [namespace code [list CloseLog $dlg]]
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
		lappend list [list $opts(Name) $opts(Timestamp)]
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
		Name			""
		ShortId		""
		Identifier	""
		Author		""
		Country		""
		Elo			0
		CCRL			0
		Command		""
		Parameters	{}
		Logo			""
		Url			""
		Protocol		""
		Variant		standard
		Timestamp	0
		Frequency	0
		Feautures	{}
		Options		{}
	}

	if {[file readable $::scidb::file::engines]} {
		::load::source $::scidb::file::engines -message $::load::mc::ReadingFile(engines) -encoding utf-8
	} else {
		set Engines {
			{
				Name			Stockfish
				ShortId		Stockfish
				Identifier	Stockfish
				Author		""
				Country		""
				Elo			0
				CCRL			0
				Command		stockfish-191-32-ja
				Parameters	{}
				Logo			""
				Url			http://www.stockfishchess.com/download/all/index.html
				Protocol		UCI
				Variant		standard
				Timestamp	0
				Frequency	0
				Feautures	{}
				Options		{}
			}
			{
				Name			Crafty
				ShortId		Crafty
				Identifier	Crafty
				Author		""
				Country		""
				Elo			0
				CCRL			0
				Command		crafty
				Parameters	{}
				Logo			""
				Url			ftp://ftp.cis.uab.edu/pub/hyatt
				Protocol		WB
				Variant		standard
				Timestamp	0
				Frequency	0
				Feautures	{}
				Options		{}
			}
			{
				Name			"Toga II"
				ShortId		"Toga II"
				Identifier	"Toga II 1.3.1"
				Author		"Thomas Gaksch & Fabien Letouzey"
				Country		""
				Elo			0
				CCRL			0
				Command		fruit
				Parameters	{}
				Logo			""
				Url			http://www.fruitchess.com
				Protocol		UCI
				Variant		standard
				Timestamp	0
				Frequency	0
				Feautures	{multiPV 10}
				Options		{}
			}
			{
				Name			Phalanx
				ShortId		Phalanx
				Identifier	Phalanx
				Author		""
				Country		""
				Elo			0
				CCRL			0
				Command		phalanx
				Parameters	{}
				Logo			""
				Url			http://phalanx.sourceforge.net
				Protocol		WB
				Variant		standard
				Timestamp	0
				Frequency	0
				Feautures	{}
				Options		{}
			}
			{
				Name			{Gullydeckel 2}
				ShortId		{Gullydeckel 2}
				Identifier	{Gullydeckel 2}
				Author		""
				Country		""
				Elo			0
				CCRL			0
				Command		gully2
				Parameters	{}
				Logo			""
				Url			http://borriss.com
				Protocol		WB
				Variant		standard
				Timestamp	0
				Frequency	0
				Feautures	{}
				Options		{}
			}
			{
				Name			Micro-Max
				ShortId		Micro-Max
				Identifier	"micro-Max 4.8 (m)"
				Author		""
				Country		""
				Elo			0
				CCRL			0
				Command		micromax
				Parameters	{}
				Logo			""
				Url			http://home.hccnet.nl/h.g.muller/max-src2.html
				Protocol		WB
				Variant		standard
				Timestamp	0
				Frequency	0
				Feautures	{}
				Options		{}
			}
		}

		set list $Engines
		set Engines {}

		foreach entry $list {
			array set arr $entry
			set arr(Directory) $::scidb::dir::user
			set arr(Command) "[file join $::scidb::dir::engines $arr(Command)]"

#			if {[file executable $arr(Command)]} {
				set result [::scidb::engine::info $arr(ShortId)]
				if {[llength $result]} {
					lassign $result _ arr(Country) arr(Elo) arr(CCRL) uci wb chess960 shuffle
					if {$uci && $wb} {
						set arr(Protocol) UCI/WB
						set arr(protocol) UCI
					} elseif {$uci} {
						set arr(Protocol) UCI
						set arr(protocol) UCI
					} elseif {$wb} {
						set arr(Protocol) WB
						set arr(protocol) WB
					}
					if {$shuffle} {
						set arr(Variant) shuffle
					} elseif {$chess960} {
						set arr(Variant) chess960
					}
				}

				lappend Engines [array get arr]
#			}
		}
	}
}


proc CloseLog {dlg} {
	::scidb::engine::log close
	destroy $dlg
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
}


proc Select {list item} {
	variable Engines
	variable Priv
	variable Photo

	if {$Priv(selection) >= 0} {
		array set engine [lindex $Engines $Priv(selection)]
		set logo $engine(ShortId)
		if {[info exists Photo($logo)]} {
			$list set $Priv(selection) [list [lindex $Photo($logo) 0]]
		}
	}

	set Priv(selection) $item
	Fill $list [lindex $Engines $item]
}


proc Fill {list entry} {
	variable Photo
	variable Priv
	variable Var

	array set engine $entry

	foreach attr [array names engine] {
		switch $attr {
			Protocol {
				switch -glob $engine($attr) {
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
			Timestamp {
				set t $engine($attr)
				if {$t == 0} {
					set Var($attr) ""
				} else {
					set Var($attr) [::locale::formatNormalDate [::locale::timestampToTime $t]]
				}
			}
			Country {
				$Priv(countrybox) set $engine(Country)
			}
			Variant {
				switch $engine($attr) {
					standard	{ set Var(Variant) $mc::Variant(standard) }
					chess960	{ set Var(Variant) $mc::Variant(chess960) }
					shuffle	{ set Var(Variant) "$mc::Variant(chess960) / $mc::Variant(shuffle)" }
				}
			}
			default {
				set Var($attr) $engine($attr)
			}
		}
	}

	set logo $engine(ShortId)
	if {[info exists Photo($logo)]} {
		$list set [list [lindex $Photo($logo) 1]]
	}
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
			$list insert [list [lindex $Photo($logo) 0]]
		} else {
			set photoFile $opts(Logo)
			if {[string length $photoFile] == 0} {
				set photoFile [::util::photos::findPhotoFile $opts(Name)]
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

	set protocol(0) "WB"
	set protocol(1) "UCI"
	set protocols {}
	array set features {}

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
				lappend protocols $protocol($i)
				lassign $result _ engine(Identifier) engine(Author) multiPV chess960 shuffle pause playOther
				if {$multiPV > 1} { set features(uci:multiPV) $multiPV }
				if {$pause} { set features(wb:pause) $pause }
				if {$playOther} { set features(wb:playOther) $playOther }
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
	if {$shuffle} {
		set engine(Variant) shuffle
	} elseif {$chess960} {
		set engine(Variant) chess960
	} else {
		set engine(Variant) standard
	}
	set parts [split $engine(Identifier) " "]
	set result {}
	while {[llength $result] == 0 && [llength $parts] > 0} {
		set name [join $parts " "]
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
}


proc DeleteEngine {list} {
	variable Engines

	set sel [$list curselection]
	if {$sel >= 0} {
		set Engines [lreplace $Engines $sel $sel]
		RebuildEngineList $list
		if {[llength $Engines]} { $list select 0 }
	}
}


proc FillCombobox {cb} {
	variable Priv

	if {[llength $Priv(engines)] == 0} {
		# TODO
		# write own sorting routine because we have to take
		# unicode characters into account.
		set Priv(engines) [lsort -dictionary -unique [::scidb::engine::list]]
	}

	$cb configure -values $Priv(engines)
}


proc NewEngine {list} {
	variable Engines
	variable Engine
	variable _Index
	variable _Button

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
		set _Index -1
		set i 0
		foreach entry $entries {
			array set engine $entry
			ttk::radiobutton $cpy.rb$i \
				-text $engine(Name) \
				-variable [namespace current]::_Index \
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
		$dlg.ok configure -command [list set [namespace current]::_Button ok]
		$dlg.cancel configure -command [list set [namespace current]::_Button cancel]
		wm resizable $dlg false false
		wm title $dlg $mc::ConfirmNewEngine
		wm protocol $dlg WM_DELETE_WINDOW {#}
		wm transient $dlg $parent
		::util::place $dlg center $parent
		wm deiconify $dlg
		focus $cpy.rb0
		::ttk::grabWindow $dlg
		tkwait variable [namespace current]::_Button
		::ttk::releaseGrab $dlg
		destroy $dlg
		if {$_Button eq "cancel"} { return }
		if {$_Index >= 0} { set newEntry [lindex $entries $_Index] }
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
	$list select end
	$list see end
	set Priv(state) new
}


proc UnsetRadiobutton {b} {
	$b instate {selected} {
		after idle [list set [namespace current]::_Index -1]
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
	set img ""

	catch {
		set fd [open $file rb]
		set data [read $fd]
		close $fd
		catch {set img [image create photo -data $data]}
	}

	if {[string length $img]} {
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
		set Photo($logo) [list $img $img2]
		$list set $item $img
	}

	if {[llength $PhotoFiles]} {
		set Priv(after) [after 50 [namespace code [list LoadPhotoFiles $list]]]
	}
}


proc WebOpen {parent} {
	variable Var

	if {[string length $Var(Url)]} {
		::web::open $parent $Var(Url)
	}
}


proc GetLogo {parent} {
	set result [::dialog::openFile \
		-parent $parent \
		-class image \
		-filetypes [list [list $mc::ImageFiles {.gif .jpeg .jpg .png .ppm}]] \
		-geometry last \
		-title $mc::SelectEngineLogo \
	]
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
