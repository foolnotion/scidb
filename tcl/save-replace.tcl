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

::util::source save-replace-dialog

namespace eval dialog {
namespace eval save {
namespace eval mc {

set SaveGame						"Save Game"
set ReplaceGame					"Replace Game"
set EditCharacteristics			"Edit Characteristics"
	
set GameData						"Game Data"
set Event							"Event"

set MatchesExtraTags				"Matches / Extra Tags"
set PressToSelect					"Press Ctrl+0 to Ctrl+9 (or left mouse button) to select"
set PressForWhole					"Press Alt-0 to Alt-9 (or middle mouse button) for whole data set"
set EditTags						"Edit Tags"
set RemoveThisTag					"Remove tag '%s'?"
set TagAlreadyExists				"Tag name '%s' already exists."
set TagRemoved						"Extra tag '%s' (current value: '%s') will be removed."
set TagNameIsReserved			"Tag name '%s' is reserved."
set Locked							"Locked"
set OtherTag						"Other tag"
set NewTag							"New tag"
set RemoveTag						"Remove tag"
set SetToGameDate					"Set to game date"
set SaveGameFailed				"Save of game failed."
set SaveGameFailedDetail		"See log for details."
set SavingGameLogInfo			"Saving game (%white - %black, %event) into database '%base'"
set CurrentBaseIsReadonly		"Current database '%s' is read-only."
set CurrentGameHasTrialMode	"Current game is in trial mode and cannot be saved."
set OpenPlayerDictionary		"Open Player Dictionary"

set LocalName						"&Local Name"
set EnglishName					"E&nglish Name"
set ShowRatingType				"Show &rating"
set EcoCode							"&ECO Code"
set Matches							"&Matches"
set Tags								"&Tags"

set Label(name)					"Name"
set Label(fideID)					"Fide ID"
set Label(value)					"Value"
set Label(title)					"Title"
set Label(rating)					"Rating"
set Label(federation)			"Federation"
set Label(country)				"Country"
set Label(eventType)				"Type"
set Label(sex)						"Sex/Type"
set Label(date)					"Date"
set Label(eventDate)				"Event Date"
set Label(round)					"Round"
set Label(result)					"Result"
set Label(termination)			"Termination"
set Label(annotator)				"Annotator"
set Label(site)					"Site"
set Label(eventMode)				"Mode"
set Label(timeMode)				"Time Mode"
set Label(frequency)				"Frequency"
set Label(score)					"Second rating"

set GameBase						"Game Base"
set PlayerBase						"Player Base"
set EventBase						"Event Base"
set SiteBase						"Site Base"
set AnnotatorBase					"Annotator Base"
set History							"History"

set InvalidEntry					"'%s' is not a valid entry."
set InvalidRoundEntry			"'%s' is not a valid round entry."
set InvalidRoundEntryDetail	"Valid round entries are '4' or '6.1'. Zero numbers are not allowed."
set RoundIsTooHigh				"Round should be less than 256."
set SubroundIsTooHigh			"Sub-round should be less than 256."
set ImplausibleDate				"Date of game '%s' is earlier than event date '%s'."
set ImplausibleRound				"Round '%s' seems to be implausible."
set InvalidTagName				"Invalid tag name '%s' (syntax error)."
set Field							"Field '%s': "
set ExtraTag						"Extra tag '%s': "
set InvalidNetworkAddress		"Invalid network address '%s'."
set InvalidCountryCode			"Invalid country code '%s'."
set InvalidEventRounds			"Invalid number of event rounds '%s' (positive integer expected)."
set InvalidPlyCount				"Invalid move count '%s' (positive integer expected)."
set IncorrectPlyCount			"Incorrect move count %s (actual move count is %s)."
set InvalidTimeControl			"Invalid time control field entry in '%s'."
set InvalidDate					"Invalid date '%s'."
set InvalidYear					"Invalid year '%s'."
set InvalidMonth					"Invalid month '%s'."
set InvalidDay						"Invalid day '%s'."
set MissingYear					"Year is missing."
set MissingMonth					"Month is missing."
set StringTooLong					"Tag %tag%: string '%value%' is too long and will be truncated to '%trunc%'."
set InvalidEventDate				"Cannot accept given event date: The difference between the year of the game and the year of the event should be less than 4 (restriction of Scid's database format)."
set TagIsEmpty						"Tag '%s' is empty (will be discarded)."

} ;# namespace mc


namespace import ::tcl::mathfunc::max


array set DefaultTagOrder {
	Event					 0
	Site					 1
	Date					 2
	Round					 3
	White					 3
	Black					 4
	Result				 5
	Annotator			 6
	SetUp					 7
	FEN					 8
	Variant				 9
	ECO					10
	Termination			11
	EventDate			12
	EventCountry		13
	EventType			14
	Mode					15
	TimeMode				16
	WhiteFideId			17
	BlackFideId			18
	WhiteTitle			19
	BlackTitle			20
	WhiteCountry		21
	BlackCountry		22
	WhiteType			23
	BlackType			24
	WhiteSex				25
	BlackSex				26

	WhiteElo				50
	BlackElo				51
	WhiteIPS				52
	BlackIPS				53
	WhiteDWZ				54
	BlackDWZ				55
	WhiteECF				56
	BlackECF				57
	WhiteUSCF			58
	BlackUSCF			59
	WhiteICCF			60
	BlackICCF			61
	WhiteRapid			62
	BlackRapid			63
	WhiteRating			64
	BlackRating			65

	BlackClock			99
	BlackNA				99
	BlackTeam			99
	BlackTeamCountry	99
	Board					99
	EventRounds			99
	Opening				99
	Remark				99
	Source				99
	SourceDate			99
	SubVariation		99
	TimeControl			99
	Variation			99
	WhiteClock			99
	WhiteNA				99
	WhiteTeam			99
	WhiteTeamCountry	99
}

foreach type {	WhiteElo BlackElo WhiteIPS BlackIPS WhiteDWZ BlackDWZ WhiteECF BlackECF WhiteUSCF
					BlackUSCF WhiteICCF BlackICCF WhiteRapid BlackRapid WhiteRating BlackRating} {
	set RatingTagOrder($type) $DefaultTagOrder($type)
}

foreach type [array names DefaultTagOrder] {
	set Mandatory($type,1) 0
	set Mandatory($type,0) 0
}

foreach type {Event Site Date Round White Black Result EventDate WhiteElo BlackElo ECO} {
	set Mandatory($type,0) 1
	set Mandatory($type,1) 1
}

foreach type { Annotator Termination EventDate EventCountry EventType Mode TimeMode WhiteTitle
					WhiteFideId BlackFideId BlackTitle WhiteCountry BlackCountry WhiteType BlackType
					WhiteSex BlackSex } {
	set Mandatory($type,1) 1
}

array set History {
	player		{}
	event			{}
	site			{}
	annotator	{}
}

array set Attrs {
	player		{ freq name ascii fideID species sex federation title elo rating score }
	event			{ freq name site country eventDate eventMode eventType timeMode }
	site			{ freq name ascii country }
	annotator	{ freq name }
}

array set Colors {
	number							darkred
	frequency						darkgreen
	title								darkgreen
	federation						darkblue
	score								darkgreen
	ratingType						darkblue
	date								darkblue
	eventDate						darkblue
	eventCountry					darkblue
	taglistOutline					gray
	taglistBackground				lightYellow
	taglistHighlighting			#ebf4f5
	tasglistCurrent				blue
	matchlistBackground			#ebf4f5
	matchlistHeaderForeground	#727272
	matchlistHeaderBackground	#dfe7e8
}

array set Selection {
	player:fideID		1
	player:sex			1
	player:federation	1
	player:title		0
	player:elo			0
	player:score		0

	event:site			1
	event:country		1
	event:eventDate	1
	event:eventMode	1
	event:eventType	1
	event:timeMode		1
}

array set Options {
	unicode	0
}

variable MaxColumnLength 380
variable Characteristics -1


proc open {parent base variant position {number 0}} {
	variable TagOrder
	variable DefaultTagOrder

	if {![checkIfWriteable $parent $base $variant $position $number]} { return }
	incr number -1

	set characteristicsOnly [expr {[llength $position] == 0}]
	set codec [::scidb::db::get codec $base $variant]
	if {$codec eq "si4"} { set codec "si3" }
	if {$codec eq "sci"} {
		set characteristics 0
	} else {
		set characteristics $characteristicsOnly
	}
	set dlg [winfo toplevel $parent].saveReplace_${characteristics}_${codec}

	Destroy $dlg

	if {![winfo exists $dlg]} {
		namespace eval ::$dlg {}
	}
	variable ::${dlg}::Priv

	array set TagOrder [array get DefaultTagOrder]

	if {$characteristicsOnly} {
		set Priv(tags) [::scidb::db::get tags $number $base $variant]
	} else {
		set Priv(tags) [::scidb::game::tags $position -userSuppliedOnly yes]
	}

	set Priv(game-eco) ""
	set Priv(title) [GetTitle $base $position $number]
	set Priv(characteristics-only) $characteristicsOnly
	set Priv(codec) $codec
	set Priv(white-score) 0
	set Priv(black-score) 0
	set Priv(white-rating) Elo
	set Priv(black-rating) Elo
	set Priv(base) $base
	set Priv(variant) $variant
	set Priv(position) $position
	set Priv(number) $number
	set Priv(tag:current) {}

	set mc::Label(elo) "Elo"

	if {![winfo exists $dlg]} {
		Build $dlg $base $variant $position $number
	}

	foreach attr {player event site annotator} {
		set maxUsage [::scidb::db::get maxUsage $base $variant $attr]
		set digits [expr {int(ceil(log10(max(1, $maxUsage)))) + 1}]
		$Priv(table:$attr) configcol freq -width $digits
		$Priv(table:$attr) resize
	}

	# Show Dialog #############################################
	wm transient $dlg [winfo toplevel $parent]
	catch { wm attributes $dlg -type dialog }
	wm title $dlg $Priv(title)
	wm resizable $dlg no no
	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list Withdraw $dlg]]
	::util::place $dlg center [winfo toplevel $parent]
	wm deiconify $dlg

	# Finalization ############################################
	if {[llength $position]} {
		set idn [::scidb::game::query $position idn]
	} else {
		set idn [::scidb::db::get idn $number $base $variant]
	}
	if {$idn > 0 && $idn != 518} {
		$dlg.top.white-rating.type set IPS
		$dlg.top.black-rating.type set IPS
	}
	if {$idn == 518 && $variant eq "Normal"} { set state normal } else { set state disabled }
	$dlg.top.game-eco configure -state $state
	$dlg.top.game-eco-l configure -state $state
	foreach attr {white-name black-name event-title event-site game-annotator} {
		set Priv($attr) ""
	}
	$Priv(taglist) item delete 0 end
	SetupTags $dlg.top $base $variant $idn $position $number

	# Finalization ############################################
	focus $dlg.top.white-name
	$dlg.top.white-name selection range 0 end
	bind $dlg <FocusIn> { ::playerdict::unsetReceiver }

	::ttk::grabWindow $dlg
	set Priv(finished) 0
   tkwait variable [namespace current]::Priv(finished)
	::ttk::releaseGrab $dlg
	::playerdict::unsetReceiver

	return $dlg
}


proc checkIfWriteable {parent base variant position number} {
	if {[::scidb::db::get readonly? $base $variant]} {
		set msg [format $mc::CurrentBaseIsReadonly [::util::databaseName $base]]
		::dialog::info -parent $parent -message $msg -title [GetTitle $base $position $number]
		return 0
	}
	if {[::scidb::game::query trial]} {
		set msg [format $mc::CurrentGameHasTrialMode [::util::databaseName $base]]
		::dialog::info -parent $parent -message $msg -title [GetTitle $base $position $number]
		return 0
	}
	return 1
}


proc GetTitle {base position number} {
	set title "[tk appname] - "
	if {[llength $position] == 0} {
		append title $mc::EditCharacteristics
		set characteristicsOnly 1
	} elseif {$number < 0} {
		append title $mc::SaveGame
		set characteristicsOnly 0
	} else {
		append title $mc::ReplaceGame
		set characteristicsOnly 0
	}
	append title " ([::util::databaseName $base])"

	return $title
}


proc Build {dlg base variant position number} {
	variable ::${dlg}::Priv
	variable Colors
	variable MaxColumnLength
	variable Selection
	variable Options

	switch $Priv(codec) {
		si3 -
		si4 { set excludelost 1; set twoRatings 0; set playertype 0; set useStringForRound 1 }
		sci { set excludelost 0; set twoRatings 1; set playertype 1; set useStringForRound 0 }
	}

	set Priv(twoRatings) $twoRatings
	set Priv(format) [expr {$twoRatings ? "sci" : "si3"}]

	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg

	set top [ttk::frame $dlg.top -takefocus 0]
	set ltrow 1
	set rtrow 1
	set minYear [::scidb::db::get minYear $base $variant]
	set maxYear [::scidb::db::get maxYear $base $variant]
	set rows {}
	set charwidth [font measure TkTextFont "0"]
	set maxlen [expr {$MaxColumnLength/$charwidth}]
	set fields {}
	set disabled {}

	set Priv(entry) ""
	set Priv(focus) ""
	set Priv(list) {}
	set Priv(dont-match) 0
	set Priv(posted) 0
	set Priv(match:white-name) {}
	set Priv(match:black-name) {}
	set Priv(match:event-title) {}
	set Priv(match:event-site) {}
	set Priv(match:game-annotator) {}
	set Priv(game-eco-flag) 0

	if {$Priv(characteristics-only) && !$playertype} { set state disabled } else { set state normal }

	# White + Black Player ####################################
	foreach {side row col} {white ltrow 1 black rtrow 5} {
		set color [string toupper $side 0 0]
		ttk::labelbar $top.$side ::mc::[string toupper $side 0 0]

		ttk::label $top.$side-player-l
		bind $top.$side-player-l <<LanguageChanged>> \
			[namespace code [list UpdateNameLabel $top.$side-player-l $state]]
		UpdateNameLabel $top.$side-player-l $state

		foreach attr {rating title federation sex} {
			ttk::label $top.$side-$attr-l -textvar [namespace current]::mc::Label($attr)
		}

		ttk::frame $top.$side-player -borderwidth 0 -takefocus 0
		entrybox $top.$side-name -textvar ::${dlg}::Priv(${side}-name)
		if {$state eq "normal"} {
			fideidbox $top.$side-fideID -textvar ::${dlg}::Priv(${side}-fideID) -state $state
		}
		ttk::button $top.$side-dict \
			-style icon.TButton \
			-image $::icon::12x12::dictionary \
			-command [namespace code [list GetPlayerFromDict $dlg $side]] \
			;
		::tooltip::tooltip $top.$side-dict [namespace current]::mc::OpenPlayerDictionary
		ttk::frame $top.$side-rating -borderwidth 0 -takefocus 0
		if {$twoRatings} {
			ttk::label $top.$side-rating.l-elo -text "Elo"
			scorebox $top.$side-rating.elo -textvar ::${dlg}::Priv(${side}-elo)
		}
		ratingbox $top.$side-rating.type -format $Priv(format) -textvar ::${dlg}::Priv(${side}-rating)
		scorebox $top.$side-rating.score -textvar ::${dlg}::Priv(${side}-score)
		titlebox $top.$side-title \
			-width $maxlen \
			-textvar ::${dlg}::Priv(${side}-title) \
			-state $state \
			;
		countrybox $top.$side-federation \
			-height 20 \
			-width $maxlen \
			-textvar ::${dlg}::Priv(${side}-federation) \
			-state $state \
			;
		genderbox $top.$side-sex -textvar ::${dlg}::Priv(${side}-sex) -state $state

		if {$state eq "disabled"} {
			lappend disabled ${side}-fideID ${side}-title ${side}-federation ${side}-sex
		}

		lappend fields [list $color $side-name]
		if {$state eq "normal"} { lappend fields [list ${color}FideId $side-fideID] }
		if {$twoRatings} { lappend fields [list ${color}Elo $side-rating.elo] }
		lappend fields [list ${color}Rating ${side}-rating.type ${side}-rating.score]
		lappend fields [list ${color}Title ${side}-title]
		lappend fields [list ${color}Country $side-federation]
		lappend fields [list ${color}Sex ${side}-sex]

		if {$twoRatings} {
			grid $top.$side-rating.l-elo  -row 0 -column 0 -sticky ns
			grid $top.$side-rating.elo    -row 0 -column 2 -sticky ns
			grid $top.$side-rating.type   -row 0 -column 4 -sticky ns
			grid $top.$side-rating.score  -row 0 -column 6 -sticky ns
			grid columnconfigure $top.$side-rating {1 5} -minsize $::theme::padding
			grid columnconfigure $top.$side-rating 3 -minsize 30
		} else {
			grid $top.$side-rating.type   -row 0 -column 0 -sticky ns
			grid $top.$side-rating.score  -row 0 -column 2 -sticky ns
			grid columnconfigure $top.$side-rating 1 -minsize $::theme::padding
		}

		set Priv(${side}-name) {}
		set Priv(${side}-fideID) {}

		lappend rows [set $row]
		if {$side eq "white"} { set span 4} else { set span 3}
		grid $top.$side -row [set $row] -column $col -columnspan $span -sticky ew
		incr $row 2

		grid $top.$side-player-l -row [set $row] -column $col -sticky w
		grid $top.$side-player -row [set $row] -column [expr {$col + 2}] -sticky ew
		incr $row 2

		grid $top.$side-name -row 0 -column 0 -sticky ew -in $top.$side-player
		grid columnconfigure $top.$side-player 0 -weight 1
		set c 2; set cols {1}
		if {$state eq "normal"} {
			grid $top.$side-fideID -row 0 -column 2 -sticky w -in $top.$side-player
			lappend cols 3
			incr c 2
		}
		grid $top.$side-dict -row 0 -column $c -sticky wns -in $top.$side-player
		grid columnconfigure $top.$side-player $cols -minsize $::theme::padding

		set list {name {}}
		if {$state eq "normal"} { lappend list fideID FideId }

		foreach {attr tag} $list {
			bind $top.$side-$attr <FocusIn> \
				[namespace code [list UpdateMatchList $top $side-name $side-$attr]]
			bind $top.$side-$attr <FocusOut> \
				[namespace code [list UpdateTags $top ${color}${tag} $side-$attr]]
		}

		if {$state eq "normal"} {
			bind $top.$side-fideID <FocusOut> \
				+[namespace code [list UpdateName $top $side-name $side-fideID]]
		}

		foreach {attr tag} {rating {} title Title federation Country sex Sex} {
			grid $top.$side-$attr-l -row [set $row] -column $col -sticky w
			grid $top.$side-$attr -row [set $row] -column [expr {$col + 2}] -sticky ew
			incr $row 2

			if {$attr ne "rating"} {
				bind $top.$side-$attr <FocusIn> \
					[namespace code [list UpdateMatchList $top $side-name $side-$attr]]

				if {$attr ne "sex"} {
					bind $top.$side-$attr <FocusOut> \
						[namespace code [list UpdateTags $top $color$tag $side-$attr]]
				}
			}
		}

		bind $top.$side-sex <FocusOut> [namespace code [list UpdateSexTag $top $color $side-sex]]

		if {$twoRatings} {
			bind $top.$side-rating.elo <FocusIn> \
				[namespace code [list UpdateMatchList $top $side-name $side-rating.elo]]
			bind $top.$side-rating.elo <FocusOut> \
				[namespace code [list UpdateTags $top ${color}Elo $side-rating.elo]]
		}
		foreach attr {type score} {
			bind $top.$side-rating.$attr <FocusIn> \
				[namespace code [list UpdateMatchList $top $side-name $side-rating.$attr]]
			bind $top.$side-rating.$attr <FocusOut> \
				[namespace code [list UpdateRatingTags $top $color $side-rating $side-score]]
		}
		bind $top.$side-rating.type <<ComboboxPosted>> [list set ::${dlg}::Priv(posted) 1]
		bind $top.$side-rating.type <<ComboboxUnposted>> [list set ::${dlg}::Priv(posted) 0]

		lappend rows [set $row]

		lappend Priv(select:$side) name entrybox $color $side-name
		if {$state eq "normal"} {
			lappend Priv(select:$side) fideID fideidbox ${color}FideId $side-fideID
		}
		if {$twoRatings} {
			lappend Priv(select:$side) elo scorebox ${color}Elo $side-rating.elo
		}
		lappend Priv(select:$side) \
			rating ratingbox $color-Rating $side-rating.type \
			score scorebox $color-Rating $side-rating.score \
			title titlebox ${color}Title $side-title \
			federation countrybox ${color}Country $side-federation \
			sex genderbox ${color}Sex $side-sex \
			;

		BindMatchKeys $top $side
	}

#	bind $top.white-player-l <Destroy> [list wm withdraw $dlg]

	# Game Data ###############################################
	ttk::labelbar $top.game [namespace current]::mc::GameData

	foreach attr {date result round termination annotator} {
		ttk::label $top.game-$attr-l -textvar [namespace current]::mc::Label($attr)
	}

	datebox $top.game-date -minYear $minYear -maxYear $maxYear -usetoday yes
	resultbox $top.game-result -excludelost $excludelost -textvar ::${dlg}::Priv(game-result)
	roundbox $top.game-round -width 10 -textvar ::${dlg}::Priv(event-round) -useString $useStringForRound
	terminationbox $top.game-termination \
		-textvar ::${dlg}::Priv(game-termination) \
		-state $state \
		;
	entrybox $top.game-annotator \
		-width $maxlen \
		-textvar ::${dlg}::Priv(game-annotator) \
		-state $state \
		;
	ttk::checkbutton $top.game-eco-l \
		-variable ::${dlg}::Priv(game-eco-flag) \
		-command [namespace code [list UpdateEcoTag $top game-eco]] \
		;
	ecobox $top.game-eco -textvar ::${dlg}::Priv(game-eco)
	SetEcoCodeText $top.game-eco-l

	bind $top.game-eco-l <FocusIn> [namespace code [list ClearMatchList $top]]
	bind $top.game-date <<DateChanged>> \
		[namespace code [list UpdateEventDate $top.game-date $top.event-eventDate]]
	
	if {$state eq "disabled"} {
		lappend disabled game-termination game-annotator
	}

	lappend fields [list Date game-date]
	lappend fields [list Result game-result]
	lappend fields [list Round game-round]
	lappend fields [list Termination game-termination]
	lappend fields [list Annotator game-annotator]
	lappend fields [list ECO game-eco game-eco-l]

	lappend rows $ltrow
	grid $top.game -row $ltrow -column 1 -columnspan 3 -sticky ew
	incr ltrow 2

	foreach attr {date result round termination annotator eco} {
		if {$attr eq "round"} { set sticky w } else { set sticky ew }

		grid $top.game-$attr-l -row $ltrow -column 1 -sticky w
		grid $top.game-$attr -row $ltrow -column 3 -sticky $sticky
		incr ltrow 2

		switch $attr {
			annotator {
				bind $top.game-$attr <FocusIn> \
					[namespace code [list UpdateMatchList $top game-$attr game-$attr]]
				bind $top.game-$attr <FocusOut> \
					[namespace code [list UpdateTags $top Annotator game-$attr]]
			}

			eco {
				bind $top.game-eco <FocusOut> [namespace code [list UpdateEcoTag $top game-eco]]
				bind $top.game-$attr <FocusIn> [namespace code [list ClearMatchList $top]]
			}

			default {
				bind $top.game-$attr <FocusOut> \
					[namespace code [list UpdateTags $top [string toupper $attr 0 0] game-$attr]]
				bind $top.game-$attr <FocusIn> [namespace code [list ClearMatchList $top]]
			}
		}
	}

	lappend rows $ltrow

	set Priv(select:annotator) [list \
		name entrybox Annotator game-annotator \
	]
	BindMatchKeys $top annotator

	# Event Data ##############################################
	ttk::labelbar $top.event [namespace current]::mc::Event

	foreach attr {title site country eventDate eventMode eventType timeMode} {
		ttk::label $top.event-$attr-l -textvar [namespace current]::mc::Label($attr)
	}

	entrybox $top.event-title -width $maxlen -textvar ::${dlg}::Priv(event-title)
	entrybox $top.event-site -width $maxlen -textvar ::${dlg}::Priv(event-site)
	countrybox $top.event-country \
		-height 20 \
		-width $maxlen \
		-textvar ::${dlg}::Priv(event-country) \
		-state $state \
		;
	datebox $top.event-eventDate \
		-minYear $minYear \
		-maxYear $maxYear \
		-usetoday yes \
		-tooltip [namespace current]::mc::SetToGameDate \
		;
	set width 0
	foreach box {eventmodebox eventtypebox timemodebox} {
		set width [expr {max($width, [::${box}::minWidth])}]
	}
	eventmodebox $top.event-eventMode -textvar ::${dlg}::Priv(event-eventMode) -state $state -width $width
	eventtypebox $top.event-eventType -textvar ::${dlg}::Priv(event-eventType) -state $state -width $width
	timemodebox $top.event-timeMode -textvar ::${dlg}::Priv(event-timeMode) -state $state -width $width

	if {$state eq "disabled"} {
		lappend disabled event-country event-eventMode event-eventType event-timeMode
	}

	lappend fields [list Event event-title]
	lappend fields [list Site event-site]
	lappend fields [list EventCountry event-country]
	lappend fields [list EventDate event-eventDate]
	lappend fields [list Mode event-eventMode]
	lappend fields [list EventType event-eventType]
	lappend fields [list TimeMode event-timeMode]

	lappend rows $ltrow
	grid $top.event -row $ltrow -column 1 -columnspan 3 -sticky ew
	incr ltrow 2

	foreach {attr tag} {	title Event site Site country EventCountry eventDate EventDate
								eventMode Mode eventType EventType timeMode TimeMode} {
		grid $top.event-$attr-l -row $ltrow -column 1 -sticky w
		grid $top.event-$attr -row $ltrow -column 3 -sticky ew
		incr ltrow 2

		switch $attr {
			site - country {
				bind $top.event-$attr <FocusIn> \
					[namespace code [list UpdateMatchList $top event-site event-$attr]]
			}

			default {
				bind $top.event-$attr <FocusIn> \
					[namespace code [list UpdateMatchList $top event-title event-$attr]]
			}
		}

		bind $top.event-$attr <FocusOut> [namespace code [list UpdateTags $top $tag event-$attr]]
	}

	lappend rows $ltrow

	set Priv(select:event) [list \
		name entrybox Event event-title \
		eventDate datebox EventDate event-eventDate \
		eventMode eventmodebox Mode event-eventMode \
		eventType eventtypebox EventType event-eventType \
		timeMode timemodebox TimeMode event-timeMode \
		site entrybox Site event-site \
		country countrybox EventCountry event-country \
	]
	set Priv(select:site) [list \
		name entrybox Site event-site \
		country countrybox EventCountry event-country \
	]
	BindMatchKeys $top event
	BindMatchKeys $top site

	# Matches/Tags ############################################
	ttk::labelbar $top.matches [namespace current]::mc::MatchesExtraTags
	grid $top.matches -row $rtrow -column 5 -columnspan 3 -sticky ewn
	incr rtrow 2

	set nb [ttk::notebook $top.nb -takefocus 1]
	bind $nb <<NotebookTabChanged>> [list focus $nb]
	incr ltrow -1
	grid $top.nb -row $rtrow -column 5 -columnspan 3 -sticky ewns -rowspan [expr {$ltrow - $rtrow}]

	# Matches #################################################
	ttk::frame $nb.matches -takefocus 0
	$nb add $nb.matches -sticky new
	::widget::notebookTextvarHook $nb $nb.matches [namespace current]::mc::Matches

	set opts [ttk::frame $nb.matches.options -borderwidth 0 -takefocus 0]

	tk::AmpWidget ttk::radiobutton $opts.ascii \
		-value 0 \
		-text $mc::EnglishName \
		-variable [namespace current]::Options(unicode) \
		-command [namespace code [list RefreshMatchList $top]] \
		;
	tk::AmpWidget ttk::radiobutton $opts.local \
		-value 1 \
		-text $mc::LocalName \
		-variable [namespace current]::Options(unicode) \
		-command [namespace code [list RefreshMatchList $top]] \
		;

	set Priv(ratingType) Elo
	ttk::label $opts.ratingtype
	ratingbox $opts.ratingbox -textvar ::${dlg}::Priv(ratingType) -format all -state readonly
	SetRatingTypeText $opts.ratingtype $opts.ratingbox
	bind $opts.ratingbox <FocusOut> [namespace code [list RefreshMatchList $top $opts.ratingbox]]
	bind $opts.ratingbox <<ComboboxSelected>> [namespace code [list RefreshMatchList $top]]
	bind $opts.ascii <<LanguageChanged>> \
		"tk::SetAmpText $opts.ascii \$[namespace current]::mc::EnglishName"
	bind $opts.local <<LanguageChanged>> \
		"tk::SetAmpText $opts.local \$[namespace current]::mc::LocalName"
	bind $opts.ratingtype <<LanguageChanged>> \
		[namespace code [list SetRatingTypeText $opts.ratingtype $opts.ratingbox]]

	grid $opts.ascii			-row 1 -column 1 -sticky w
	grid $opts.local			-row 1 -column 3 -sticky w
	grid $opts.ratingtype	-row 1 -column 5 -sticky w
	grid $opts.ratingbox		-row 1 -column 7 -sticky w
	grid columnconfigure $opts {2 6} -minsize $::theme::padding
	grid columnconfigure $opts 4 -weight 1

	grid $opts -row 1 -column 1 -sticky ew

	set maxUsage(player)		9999
	set maxUsage(event)		9999
	set maxUsage(site)		9999
	set maxUsage(annotator)	9999

	set f TkTextFont
	set bold [list [font configure $f -family] [font configure $f -size] bold]

	foreach attr {player event site annotator} {
		ttk::frame $nb.matches.$attr -borderwidth 1 -relief sunken -takefocus 0
		bind $nb.matches.$attr <Configure> [namespace code [list SetMaxWidth $nb.matches.$attr %w]]
		grid $nb.matches.$attr -row 3 -column 1 -sticky ew

		set lb [tlistbox $nb.matches.$attr.lb \
					-background $Colors(matchlistBackground) \
					-disabledbackground $Colors(matchlistBackground) \
					-highlightbackground $Colors(matchlistHeaderBackground) \
					-highlightforeground $Colors(matchlistHeaderForeground) \
					-highlightfont $bold \
					-height 12 \
					-takefocus 0 \
					-focusmodel hover \
					-borderwidth 0 \
					-showfocus 0 \
				]
		pack $lb -fill x
		bind $lb <<ItemVisit>> [namespace code [list VisitMatch $lb %d]]
		bind $lb <<ListboxSelect>> [namespace code [list SelectMatch $top $lb %d 0]]
		$lb bind <ButtonPress-2> [namespace code [list SelectActive $top $lb]]
		$lb bind <ButtonRelease-1> +[namespace code [list SetFocus $dlg]]
		$lb bind <ButtonRelease-2> +[namespace code [list SetFocus $dlg]]
		$lb bind <ButtonPress-3> [namespace code [list SelectMatchAttributes $dlg $attr %X %Y]]
		$lb addcol text -id number -justify right -width 1 -foreground $Colors(number)
		$lb addcol text -id freq -justify right -width 4 -foreground $Colors(frequency)
		$lb addcol text -id name -squeeze yes -weight 1 -steady no
		# -expand yes
		set Priv(table:$attr) $lb
	}

	::ttk::label $nb.matches.footer1 -textvar [namespace current]::mc::PressToSelect -anchor center
	::ttk::label $nb.matches.footer2 -textvar [namespace current]::mc::PressForWhole -anchor center

	grid $nb.matches.footer1 -row 5 -column 1 -sticky ew
	grid $nb.matches.footer2 -row 6 -column 1 -sticky ew

	grid columnconfigure $nb.matches 1 -weight 1
	grid columnconfigure $nb.matches {0 2} -minsize $::theme::padding
	grid rowconfigure $nb.matches {0 2 7} -minsize $::theme::padding
	grid rowconfigure $nb.matches 4 -minsize $::theme::padY
	grid rowconfigure $nb.matches 3 -weight 1

	set Priv(footer) $nb.matches.footer2

	# ------ Player List --------------------------------------
	set lb $nb.matches.player.lb

	$lb addcol text -id title -width 4 -foreground $Colors(title) -justify center
	$lb addcol text \
		-id federation -justify center -width 3 -font TkFixedFont -foreground $Colors(federation)
	$lb addcol image -id sex -justify center -width 14
	$lb addcol text -id elo -width 4 -justify right -foreground $Colors(score)
	$lb addcol text -id rating -width 6 -foreground $Colors(ratingType)

	# ------ Event List ---------------------------------------
	set lb $nb.matches.event.lb

	$lb addcol text  -id eventDate -width 10 -foreground $Colors(date)
	$lb addcol image -id eventMode -width 14 -justify center
	$lb addcol image -id eventType -width 14 -justify center
	$lb addcol image -id timeMode -width 14 -justify center

	# ------ Site List ----------------------------------------
	set lb $nb.matches.site.lb
	$lb addcol text \
		-id country -width 3 -justify center -font TkFixedFont -foreground $Colors(eventCountry)

	# ------ Annotator List -----------------------------------
	set lb $nb.matches.annotator.lb

	# ---------------------------------------------------------
	foreach attr {player event site annotator} {
		set lb $nb.matches.$attr.lb
		for {set i 0} {$i < 12} {incr i} { $lb insert { " " } -enabled 0 }
		set Priv(skip:$attr) "\uffff"
	}

	# Tags ####################################################
	ttk::frame $nb.tags -takefocus 0
	$nb add $nb.tags -sticky nsew
	::widget::notebookTextvarHook $nb $nb.tags [namespace current]::mc::Tags
	set tags $nb.tags

	set t $tags.list
	set highlight lightblue
	set charwidth [font measure TkTextFont "0"]
	set Priv(taglist) $t

	# create treectrl + columns
	treectrl $t \
		-class TagList \
		-showroot no \
		-showlines no \
		-showrootlines no \
		-xscrollincrement 1 \
		-takefocus 1 \
		-borderwidth 1 \
		-relief sunken \
		-background $Colors(taglistBackground) \
		-font TkTextFont \
		-fullstripes 1 \
		-columnresizemode realtime \
		-yscrollcommand [list $tags.vsb set] \
		;
	$t column create \
		-width 22 \
		-justify center \
		-tags delete \
		-borderwidth 1 \
		-button no \
		-resize no \
		-uniform uniform \
		;
	$t column create \
		-text $mc::Label(name) \
		-minwidth [expr {6*$charwidth}] \
		-tags name \
		-borderwidth 1 \
		-button no \
		-resize yes \
		-uniform uniform \
		-expand no \
		-squeeze no \
		;
	$t column create \
		-text $mc::Label(value) \
		-minwidth [expr {16*$charwidth}] \
		-expand yes \
		-tags value \
		-borderwidth 1 \
		-button no \
		-resize yes \
		-uniform uniform \
		-squeeze yes \
		-weight 1 \
		;
	
	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify bind $t <Item-enter> [namespace code { VisitTag %W enter %C %I }]
	$t notify bind $t <Item-leave> [namespace code { VisitTag %W leave %C %I }]

	$t state define edit
	$t state define current
	
	# create elements
	$t element create elemText text -lines 1
	$t element create elemImage image
	$t element create elemBorder rect -open nw -outline $Colors(taglistOutline) -outlinewidth 1
	$t element create elemSel border \
		-background [list $Colors(tasglistCurrent) {current focus}] \
		-relief flat \
		-thickness 1 \
		;
	
	# create styles using the elements
	set s [$t style create styText]
	$t style elements $s {elemBorder elemSel elemText}
	$t style layout $s elemText -padx {2 4} -pady 2 -squeeze x -expand ns
	$t style layout $s elemBorder -detach yes -iexpand xy
	$t style layout $s elemSel -detach yes -iexpand xy

	set s [$t style create styImage]
	$t style elements $s {elemBorder elemSel elemText elemImage}
	$t style layout $s elemImage -padx {1 2} -expand ns
	$t style layout $s elemText -pady 2 -expand ns -detach yes
	$t style layout $s elemBorder -detach yes -iexpand xy
	$t style layout $s elemSel -detach yes -iexpand xy

	$t notify install <Edit-begin>
	$t notify install <Edit-accept>
	$t notify install <Edit-end>

	$t notify bind $t <Edit-begin>	{ %T item state set %I ~edit }
	$t notify bind $t <Edit-begin>	[list set ::${dlg}::Priv(edit) 1]
	$t notify bind $t <Edit-accept>	{ %T item element configure %I %C %E -text %t }
	$t notify bind $t <Edit-end>		{ %T item state set %I ~edit }
	$t notify bind $t <Edit-end>		+[namespace code { FinishEditTag %T %I %C }]
	set Priv(edit) 0

	ttk::scrollbar $tags.vsb -orient vertical -takefocus 0 -command [list $t yview]
	ttk::scrollbar $tags.hsb -orient horizontal -takefocus 0 -command [list $t xview]
	$t notify bind $tags.hsb <Scroll-x> [namespace code { ::scrolledframe::sbset %W %l %u }]
	if {!$Priv(characteristics-only)} {
		bind $t <ButtonPress-3> [namespace code [list PopupTagMenu $t]]
		bind $tags.vsb <ButtonPress-1> [list focus $t]
		bind $tags.hsb <ButtonPress-1> [list focus $t]
	}

	grid $tags.list	-row 1 -column 1 -sticky nsew
	grid $tags.vsb		-row 1 -column 2 -sticky ns
	grid $tags.hsb		-row 2 -column 1 -sticky ew
	grid rowconfigure $tags {0 3} -minsize $::theme::padding
	grid rowconfigure $tags 1 -weight 1
	grid columnconfigure $tags {0 3} -minsize $::theme::padding
	grid columnconfigure $tags 1 -weight 1

	# Layout ##################################################
	set gaps {}
	set rows [lsort -unique [lrange $rows 0 end-1]]
	foreach r $rows {
		if {$r > 1} { lappend gaps [expr {$r - 1}] }
	}
	set rows {}
	set nrows [expr {$ltrow + 2}]
	for {set i 0} {$i < $nrows} {incr i 2} { lappend rows $i }
	grid rowconfigure $top $rows -minsize $::theme::padding
	grid rowconfigure $top $gaps -minsize [expr {$::theme::padding + 3}]
	grid rowconfigure $top $ltrow -weight 1
	grid columnconfigure $top {0 2 6 8} -minsize $::theme::padding
	grid columnconfigure $top 4 -minsize $::theme::padX

	pack $top -fill both

	set cmd +[namespace code [list AdjustDateBox $top]]
	bind $top.game-date <Configure> $cmd
	bind $top.game-date <<LanguageChanged>> $cmd

	# Dialog Buttons ##########################################
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [namespace code [list Save $top $fields]]
	$dlg.cancel configure -command [namespace code [list Withdraw $dlg]]
#	bind $dlg.ok <FocusIn> [namespace code [list ClearMatchList $top]]
#	bind $dlg.cancel <FocusIn> [namespace code [list ClearMatchList $top]]
	bind $dlg <Escape> [list $dlg.cancel invoke]
	::widget::focusNext [$top.event-timeMode path] $dlg.ok
	::widget::focusPrev $dlg.ok [$top.event-timeMode path]

	# Tracing #################################################
	foreach attr {white-name black-name event-title event-site game-annotator} {
		trace variable ::${dlg}::Priv($attr) w  \
			[namespace code [list UpdateMatchList $top $attr $attr]]
	}

	# Finalization ############################################
	set Priv(disabled) $disabled
}


proc Destroy {dlg} {
	variable Lookup
	variable Item
	variable TagOrder

	array unset Lookup
	array unset Item
	array unset TagOrder
}


proc UpdateNameLabel {lbl state} {
	set text $mc::Label(name)
	if {$state eq "normal"} { append text "/" $mc::Label(fideID) }
	$lbl configure -text $text
}


proc UpdateName {top nameField fideIdField} {
	variable Options

	set fideId [$top.$fideIdField value]
	if {[string length $fideId] && [string length [$top.$nameField get]] == 0} {
		$top.$nameField set [::scidb::misc::lookup player $fideId -unicode $Options(unicode)]
	}
}


proc SetEcoCodeText {btn} {
	tk::SetAmpText $btn $mc::EcoCode
	set ch [string index $mc::EcoCode [expr {[$btn cget -underline] + 1}]]
	bind [winfo toplevel $btn] <Alt-[string tolower $ch]> [list $btn invoke]
	bind [winfo toplevel $btn] <Alt-[string toupper $ch]> [list $btn invoke]
}


proc SetRatingTypeText {lbl rbox} {
	tk::SetAmpText $lbl $mc::ShowRatingType
	set ch [string index $mc::ShowRatingType [expr {[$lbl cget -underline] + 1}]]
	bind [winfo toplevel $lbl] <Alt-[string tolower $ch]> [list $rbox post]
	bind [winfo toplevel $lbl] <Alt-[string toupper $ch]> [list $rbox post]
}


proc FindElement {t tagName} {
	foreach item [$t item children root] {
		set name [$t item element cget $item name elemText -text]
		if {$name eq $tagName} { return $item }
	}
}


proc VisitTag {t mode column item} {
	variable Colors

	if {[llength [$t item id $item]] == 0} { return }	;# may happen after deletion

	switch $mode {
		enter {
			set img [$t item element cget $item delete elemImage -image]
			if {$img ne $icon::12x12::locked} {
				$t item element configure $item $column elemBorder -fill $Colors(taglistHighlighting)
			}
			if {$column == 0} {
				if {$img eq $icon::12x12::delete} {
					::tooltip::show $t $::mc::Remove
				} elseif {$img eq $icon::12x12::locked} {
					::tooltip::show $t $mc::Locked
				} else {
					::tooltip::show $t "$mc::NewTag..."
				}
			}
		}

		leave {
			$t item element configure $item $column elemBorder -fill $Colors(taglistBackground)
			::tooltip::hide true
		}
	}
}


proc HighlightTag {t} {
	variable ::[winfo toplevel $t]::Priv
	variable Colors

	lassign [winfo pointerxy $t] x y
	set x [expr {$x - [winfo rootx $t]}]
	set y [expr {$y - [winfo rooty $t]}]
	set id [$t identify $x $y]
	if {[llength $id] == 0} { return }
	if {[lindex $id 0] eq "header"} { return }
	lassign $id _ item _ column
	set img [$t item element cget $item delete elemImage -image]
	if {$img eq $icon::12x12::locked} { return }
	$t item element configure $item $column elemBorder -fill $Colors(taglistHighlighting)
}


proc OpenEntry {t item column} {
	variable ::[winfo toplevel $t]::Priv
	variable Lookup
	variable Item

	set name [$t item element cget $item name elemText -text]
	if {[llength $name]} {
		unset -nocomplain Lookup($name)
		unset -nocomplain Item($name)
	}

	set e [::TreeCtrl::EntryExpanderOpen $t $item $column elemText 1]
	if {$column == 1 || $column eq "name"} {
		$e configure \
			-validate key \
			-validatecommand { return [regexp {^([A-Z][A-Za-z0-9_]*)?$} %P] } \
			-invalidcommand { bell } \
			;
	}
	set Priv(entry) $e
	::TreeCtrl::TryEvent $t Edit begin [list I $item C $column E elemText]
}


proc EditTag {t x y} {
	variable Colors
	variable ::[winfo toplevel $t]::Priv

	if {$Priv(edit)} { return }
	set id [$t identify $x $y]
	if {[llength $id] == 0} { return }
	if {[lindex $id 0] eq "header"} { return }
	lassign $id _ item _ column
	if {$column == 0} { return }
	set img [$t item element cget $item delete elemImage -image]
	if {$img eq $icon::12x12::locked} { return }
	$t item element configure $item $column elemBorder -fill $Colors(taglistBackground)
	OpenEntry $t $item $column
}


proc NewTag {t item {name ""}} {
	if {$name eq "PlyCount"} {
		$t item element configure $item name elemText -text $name
		$t item element configure $item value elemText -text [::scidb::game::count length]
		FinishEditTag $t $item value
	} else {
		if {[string length $name] == 0} {
			set column name
		} else {
			set column value
			$t item element configure $item name elemText -text $name
		}
		OpenEntry $t $item $column
	}
}


proc FinishEditTag {t item column} {
	variable ::[winfo toplevel $t]::Priv
	variable Lookup
	variable TagOrder
	variable Item

	set Priv(edit) 0
	set img [$t item element cget $item delete elemImage -image]
	set name [string trim [$t item element cget $item name elemText -text]]
	set value [string trim [$t item element cget $item value elemText -text]]
	$t item element configure $item name elemText -text $name
	$t item element configure $item value elemText -text $value
	$Priv(entry) configure -invalidcommand {} -validatecommand {} -validate none

	foreach s [array names TagOrder] {
		if {[string compare -nocase $s $name] == 0} {
			if {$name ne $s} {
				$t item element configure $item name elemText -text $s
				set name $s
			}
			break
		}
	}

	if {[string length $name]} {
		if {	($Priv(twoRatings) && ($name eq "WhiteElo" || $name eq "BlackElo"))
			|| ([info exists TagOrder($name)] && $TagOrder($name) < 50)} {
			$t item element configure $item name elemText -text ""
			set msg [format $mc::TagNameIsReserved $name]
			::dialog::error -parent $t -message $msg -title $mc::EditTags
		} elseif {[info exists Item($name)]} {
			$t item element configure $item name elemText -text ""
			set msg [format $mc::TagAlreadyExists $name]
			::dialog::error -parent $t -message $msg -title $mc::EditTags
		} elseif {$img ne $icon::12x12::plus || ($column != 1 && $column ne "name")} {
			$t item element configure $item delete elemImage -image $icon::12x12::delete
			if {![info exists TagOrder($name)] || $TagOrder($name) < 99} {
				set TagOrder($name) 99
			}
			set Lookup($name) $value
			set Item($name) $item
			if {$img eq $icon::12x12::plus} {
				AddEmptyTag $t
			}
		} else {
			OpenEntry $t $item value
			return
		}
	}

	after idle [namespace code [list HighlightTag $t]]
}


proc AddExtraTags {t m item} {
	variable TagOrder
	variable RatingTagOrder
	variable Lookup
	variable ::[winfo toplevel $t]::Priv

	menu $m.white -tearoff 0
	menu $m.black -tearoff 0

	set tags {}
	foreach {name order} [array get TagOrder] {
		if {	(!$Priv(twoRatings) || ![string match *Elo $name])
			&& ($order == 99 || [info exists RatingTagOrder($name)])} {
			lappend tags $name
		}
	}

	set tags [lsort $tags]

	foreach name $tags {
		if {![info exists RatingTagOrder($name)]} {
			if {[string match White* $name]} {
				set sub $m.white
			} elseif {[string match Black* $name]} {
				set sub $m.black
			} else {
				set sub $m
			}
			if {[info exists Lookup($name)]} { set state disabled } else { set state normal }
			$sub add command \
				-label $name \
				-state $state \
				-command [namespace code [list NewTag $t $item $name]] \
				;
		}
	}

	$m add separator
	$m add cascade -menu $m.white -label $::mc::White
	$m add cascade -menu $m.black -label $::mc::Black
	$m.white add separator
	$m.black add separator

	foreach name $tags {
		if {[info exists RatingTagOrder($name)]} {
			if {[string match White* $name]} { set side white } else { set side black }
			if {[info exists Lookup($name)]} {
				set state disabled
			} else {
				set state normal
			}
			$m.$side add command \
				-label $name \
				-state $state \
				-command [namespace code [list NewTag $t $item $name]] \
				;
		}
	}
}


proc ActivateTag {t x y} {
	set id [$t identify $x $y]
	if {[llength $id] == 0} { return }
	if {[lindex $id 0] eq "header"} { return }
	lassign $id _ item _ column
	SetCurrentElement $t $item $column
	if {$column == 0} {
		ActivateElement $t $item
	}
}


proc ActivateElement {t item} {
	set img [$t item element cget $item delete elemImage -image]
	if {$img eq $icon::12x12::delete} {
		set name [$t item element cget $item name elemText -text]
		set msg [format $mc::RemoveThisTag $name]
		if {[::dialog::question -parent $t -message $msg -title $mc::EditTags] eq "yes"} {
			RemoveTag $t $name
		}
		after idle [namespace code [list HighlightTag $t]]
	} elseif {$img eq $icon::12x12::plus} {
		set item [lindex [$t item children 0] end]
		set m $t.m
		catch { destroy $m }
		menu $m -tearoff 0
		catch { wm attributes $m -type popup_menu }
		AddExtraTags $t $m $item
		$m add separator
		$m add command -label $mc::OtherTag -command [namespace code [list NewTag $t $item]]
		scan [$t item bbox $item 0] "%d %d %d %d" x1 y1 x2 y2
		set x [expr {$x1 + [winfo rootx $t]}]
		set y [expr {$y2 + [winfo rooty $t]}]
		tk_popup $m $x $y
	}
}


proc ActivateCurrentElement {t} {
	set col [$t item tag names active]
	if {[llength $col] == 0} { return }

	if {$col == 0} {
		ActivateElement $t active
	} else {
		OpenEntry $t active $col
	}
}


proc ChangeCurrentElement {t {dirX 0} {dirY 0}} {
	variable ::[winfo toplevel $t]::Priv

	switch $dirY {
		 0 	{ set item active }
		+1 	{ set item [$t item nextsibling active] }
		-1		{ set item [$t item prevsibling active] }
		last	{ set item [$t item lastchild root] }
	} 

	if {[llength $item] == 0} { return }
	if {![$t item enabled $item]} { return }

	if {[llength $Priv(tag:current)]} {
		$t item state forcolumn {*}$Priv(tag:current) {!current}
	}

	set col [$t item tag names active]
	if {[llength $col] == 0} { set col 0 }

	if {$dirY eq "last"} {
		set col 0
	} else {
		incr col $dirX
		if {$col < 0} {
			set col 0
		} elseif {$col > 2} {
			set col 2
		}
	}

	$t activate $item
	foreach c [$t column list] { $t item tag remove active $c }
	$t item tag add active $col
	$t item state forcolumn active $col {current}
	set Priv(tag:current) [list $item $col]
	$t see $item
}


proc SetCurrentElement {t item column} {
	variable ::[winfo toplevel $t]::Priv

	if {![$t item enabled $item]} { return }

	if {[llength $Priv(tag:current)]} {
		$t item state forcolumn {*}$Priv(tag:current) {!current}
	}

	$t activate $item
	foreach c [$t column list] { $t item tag remove active $c }
	$t item tag add active $column
	$t item state forcolumn active $column {current}
	set Priv(tag:current) [list $item $column]
	$t see $item
}


proc PopupTagMenu {t} {
	variable ::[winfo toplevel $t]::Priv
	variable TagOrder
	variable Item

	set item [lindex [$t item children 0] end]
	set m $t.tagm
	catch { destroy $m }
	menu $m -tearoff 0
	catch { wm attributes $m -type popup_menu }
	menu $m.new -tearoff 0
	$m add cascade -menu $m.new -label $mc::NewTag
	AddExtraTags $t $m.new $item

	set list {}
	foreach pair $Priv(tags) {
		set name [lindex $pair 0]
		if {![info exists TagOrder($name)] || $TagOrder($name) == 99} {
			lappend list $name
		}
	}
	if {[llength $list]} {
		menu $m.del -tearoff 0
		$m add cascade -menu $m.del -label $mc::RemoveTag
		foreach name $list {
			$m.del add command -label $name -command [namespace code [list RemoveTag $t $name]]
		}
	}

	tk_popup $m {*}[winfo pointerxy $t]
}


proc RemoveTag {t name {showWarning 0}} {
	variable Item
	variable Lookup
	variable ::[winfo toplevel $t]::Priv
	variable TagOrder
	variable Mandatory

	if {$showWarning && !$Mandatory($name,$Priv(twoRatings)) && $TagOrder($name) <= 99} {
		set msg [format $mc::TagRemoved $name $Lookup($name)]
		::dialog::info -parent $t -message $msg -title $mc::EditTags]
	}
	if {[$t item id active] == [$t item id $Item($name)]} {
		ChangeCurrentElement $t 0 +1
	}
	$t item delete $Item($name)
	unset Item($name)
	unset Lookup($name)
	set index [lsearch -exact -index 0 $Priv(tags) $name]
	set Priv(tags) [lreplace $Priv(tags) $index $index]
}


proc UpdateRatingTags {top color typeField scoreField} {
	variable ::[winfo toplevel $top]::Priv
	variable Lookup
	variable RatingTagOrder
	variable TagOrder

	if {$Priv(posted)} { return }
	if {![$top.$typeField.type valid?]} { return }

	set t $top.nb.tags.list
	set value $Priv($scoreField)
	if {$value == 0} { set value "" }
	set ratingType $Priv($typeField)
	set ratingTagName $color$ratingType
	if {[info exists Lookup($ratingTagName)]} {
		RemoveTag $t $ratingTagName 1
		set TagOrder($ratingTagName) 99
	} elseif {[info exists Lookup($color$Priv($color:ratingType))]} {
		RemoveTag $t $color$Priv($color:ratingType) 1
		set TagOrder($color$Priv($color:ratingType) 99
	}
	if {[llength $value]} {
		set TagOrder($ratingTagName) $RatingTagOrder($ratingTagName)
		set Priv($color:ratingType) $ratingType
	} else {
		set Priv($color:ratingType) ---
	}
	UpdateTagList $t $ratingTagName $value

	if {[llength $value] == 0} {
		foreach ratingType $ratingbox::ratings(all) {
			set name $color$ratingType
			if {[info exists Lookup($name)] && $TagOrder($name) == 99} {
				set Priv($typeField) $ratingType
				set Priv($scoreField) $Lookup($name)
				RemoveTag $t $name 1
				set TagOrder($name) $RatingTagOrder($name)
				UpdateTagList $t $name $Priv($scoreField)
			}
		}
	}
}


proc UpdateEcoTag {top field} {
	variable ::[winfo toplevel $top]::Priv
	variable Lookup

	set t $top.nb.tags.list

	if {$Priv(game-eco-flag)} {
		UpdateTagList $t ECO [$top.$field value]
	} elseif {[info exists Lookup(ECO)]} {
		RemoveTag $t ECO 0
	}
}


proc UpdateEventDate {dateField eventDateField} {
	$eventDateField today [$dateField result]
}


proc UpdateSexTag {top color field} {
	set value [$top.$field value]

	if {[string length $value] == 0} {
		set sex ""
		set species ""
	} elseif {$value eq "c"} {
		set sex ""
		set species program
	} else {
		set sex $value
		set species human
	}

	UpdateTagList $top.nb.tags.list ${color}Sex $sex
	UpdateTagList $top.nb.tags.list ${color}Type $species
}


proc UpdateTags {top name field} {
	variable ::[winfo toplevel $top]::Priv
	UpdateTagList $top.nb.tags.list $name [string trim [$top.$field value]]
}


proc UpdateTagList {t name value} {
	variable ::[winfo toplevel $t]::Priv
	variable Lookup
	variable Item
	variable TagOrder
	variable RatingTagOrder

	if {[info exists Lookup($name)]} {
		if {[string length $value] == 0 || $value eq "?"} {
			switch $name {
				Event - Site - Round - White - Black	{ set value "?" }
				Date												{ set value "????.??.??" }
				Result											{ set value "*" }

				default {
					return [RemoveTag $t $name 1]
				}
			}
		}
		if {$Lookup($name) ne $value} {
			$t item element configure $Item($name) value elemText -text $value
			set Lookup($name) $value
			if {[info exists RatingTagOrder($name)]} {
				set TagOrder($name) $RatingTagOrder($name)
			}
		}
	} elseif {[string length $value] > 0 && $value ne "?"} {
		set Lookup($name) $value
		if {[info exists RatingTagOrder($name)]} {
			set TagOrder($name) $RatingTagOrder($name)
		}
		lappend Priv(tags) [list $name $value]
		set Priv(tags) [lsort -command [namespace current]::CompareTag $Priv(tags)]
		set index [lsearch -index 0 $Priv(tags) $name]
		set item [lindex [$t item children 0] [expr {$index - 1}]]
		$t item nextsibling $item [NewItem $t $name $value]
		$t see active
	}
}


proc AdjustDateBox {top} {
	set w $top.game-date
	if {[winfo height $w] <= 1} { return }

	if {[llength [$w overhang1]] == 0} {
		after idle [namespace code [list AdjustDateBox $top]]
	} else {
		grid rowconfigure $top {16 18} -minsize [expr {$::theme::padding - [$w overhang1]}]
		grid rowconfigure $top {34 36} -minsize [expr {$::theme::padding - [$w overhang2]}]
	}
}


proc SortMatchAttr {ordering lhs rhs} {
	return [expr {[lsearch $ordering $lhs] - [lsearch $ordering $rhs]}]
}


proc SelectMatchAttributes {dlg attr x y} {
	variable ::${dlg}::Priv
	variable Selection
	variable Attrs

	if {[llength $Priv(lb)] == 0} { return }

	set fieldList {}
	foreach entry [array names Selection $attr:*] { lappend fieldList [lindex [split $entry :] 1] }
	if {[llength $fieldList] == 0} { return }
	set fieldList [lsort -command [namespace code [list SortMatchAttr $Attrs($attr)]] $fieldList]
	set m $dlg.__select_attrs__
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff 0 -disabledforeground black
	$m add command                                                \
		-label $::mc::Apply                                        \
		-background $::table::options(menu:headerbackground)       \
		-foreground $::table::options(menu:headerforeground)       \
		-activebackground $::table::options(menu:headerbackground) \
		-activeforeground $::table::options(menu:headerforeground) \
		-font TkHeadingFont                                        \
		-state disabled                                            \
		;
	$m add separator
	foreach field $fieldList {
		$m add checkbutton -label $mc::Label($field) -variable [namespace current]::Selection($attr:$field)
	}

	tk_popup $m $x $y
}


proc BindMatchKeys {top attr} {
	variable ::[winfo toplevel $top]::Priv

	foreach {id type tag w} $Priv(select:$attr) {
		for {set z 1} {$z <= 9} {incr z} {
			$top.$w bind <Control-Key-$z> [namespace code [list ChooseMatch $top [expr {$z - 1}] 0]]
			$top.$w bind <Alt-Key-$z> [namespace code [list ChooseMatch $top [expr {$z - 1}] 1]]
		}
		$top.$w bind <Control-Key-0> [namespace code [list ChooseMatch $top 9 0]]
		$top.$w bind <Alt-Key-0> [namespace code [list ChooseMatch $top 9 1]]
	}
}


proc ChooseMatch {top index complete} {
	variable ::[winfo toplevel $top]::Priv

	set lb $Priv(lb)
	if {[string length $lb] == 0} { return }

	if {$index < [llength $Priv(list)]} {
		set Priv(focus) $top.$Priv(entry)
		EnterMatch $top $lb $index $complete
	}
}


proc VisitMatch {lb data} {
	lassign $data mode id index column

	set number [$lb get $index number]
	if {![string is digit -strict $number]} { return }
	if {[incr number -1] == -1} { set number 9 }

	switch $mode {
		enter {
			$lb activate $index
		}

		leave {
			# we have to recompute because the active state may got lost due to a tooltip popup
			if {[$lb pointer] == -1} {
				$lb activate none
			}
			$lb select none
			::tooltip::hide true
			return
		}
	}

	variable ::[winfo toplevel $lb]::Priv
	variable Attrs
	variable Options

	set tip ""
	set data [lindex $Priv(list) $number]

	switch $id {
		freq {
			set item [lindex $data [lsearch $Attrs(player) $id]]
			if {$item > 0} {
				set tip $mc::Label(frequency)
			}
		}

		name {
			set aliases {}

			switch $Priv(entry) {
				event-site {
					set attr site
					set name [lindex $data [lsearch $Attrs(site) name]]
					set country [lindex $data [lsearch $Attrs(site) country]]
					set aliases [::scidb::app::lookup siteAlias $name $country]
				}

				white-name - black-name {
					if {1} { ;# show Fide ID
						set item [lindex $data [lsearch $Attrs(player) fideID]]
						if {[llength $item]} { set tip "$mc::Label(fideID): $item" }
					} else { ;# show aliases
						set attr player
						set name [lindex $data [lsearch $Attrs(player) name]]
						set aliases [::scidb::app::lookup playerAlias $name]
					}
				}
			}

			if {[llength $aliases]} {
				if {!$Options(unicode)} {
					set name [lindex $data [lsearch $Attrs($attr) ascii]]
				}
				set index [lsearch $aliases $name]
				if {$index >= 0} { set aliases [lreplace $aliases $index $index] }
				set aliases [lsort -dictionary -unique $aliases]
				if {[llength $aliases]} {
					set tip [join $aliases \n]
				}
			}
		}

		fideID {
			set item [lindex $data [lsearch $Attrs(player) fideID]]
		}

		sex {
			set item [lindex $data [lsearch $Attrs(player) species]]
			if {$item eq "program"} { set tip $::genderbox::mc::Gender(c) }
		}

		federation {
			set item [lindex $data [lsearch $Attrs(player) $id]]
			if {[llength $item]} { set tip [::country::name $item] }
		}

		country {
			set item [lindex $data [lsearch $Attrs(site) $id]]
			if {[llength $item]} { set tip [::country::name $item] }
		}

		eventMode {
			set item [lindex $data [lsearch $Attrs(event) $id]]
			if {[llength $item]} { set tip [set ::eventmodebox::mc::$item] }
		}

		eventType {
			set item [lindex $data [lsearch $Attrs(event) $id]]
			if {[llength $item]} { set tip $::eventtypebox::mc::Type($item) }
		}

		timeMode {
			set item [lindex $data [lsearch $Attrs(event) $id]]
			if {[llength $item]} { set tip $::timemodebox::mc::Mode($item) }
		}

		elo {
			set elo [lindex $data [lsearch $Attrs(player) $id]]
			set score  [lindex $Priv(list) $number [lsearch $Attrs(player) score]]
			set rating [lindex $Priv(list) $number [lsearch $Attrs(player) rating]]
			
			if {$elo > 0 && ([string length $rating] == 0 || $rating ne $Priv(ratingType))} {
				set tip Elo
			} elseif {$score > 0} {
				set tip $rating
			}
		}
	}

	if {[string length $tip]} {
		::tooltip::show $lb $tip
	}
}


proc MakeMatchEntry {top index entry attr} {
	variable Attrs
	variable ::[winfo toplevel $top]::Priv

	set attrs $Attrs($attr)
	lassign $entry {*}$attrs
	if {$freq == 0} { set freq {} }

	switch $attr {
		player {
			if {$federation eq "UNK"} {
				set federation ""
			} elseif {[string length $federation]} {
				set federation $::country::icon::flag($federation)
			}
			switch $sex {
				m { set sex $::icon::12x12::male }
				f { set sex $::icon::12x12::female }

				default {
					if {$species eq "program"} {
						set sex $::icon::12x12::program
					}
				}
			}
			if {$rating eq $Priv(ratingType)} {
				if {$score} { set elo $score } else { set elo "" }
				set rating ""
			} elseif {$elo > 0} {
				if {$Priv(ratingType) eq "Elo"} {
					set rating ""
				} else {
					set rating Elo
				}
			} elseif {$score} {
				set elo $score
			} else {
				set elo ""
			}
			set entry [list $index $freq $name $title $federation $sex $elo $rating]
		}

		event {
			if {[llength $eventMode]} { set eventMode [set ::eventmodebox::icon::12x12::$eventMode] }
			if {[llength $eventType]} { set eventType $::eventtypebox::icon::12x12::Type($eventType) }
			if {[llength $timeMode]} { set timeMode [set ::timemodebox::icon::12x12::Mode($timeMode)] }
			set entry [list $index $freq $name $eventDate $eventMode $eventType $timeMode]
		}

		site {
			if {[llength $country]} { set country $country::icon::flag($country) }
			set entry [list $index $freq $name $country]
		}

		annotator {
			set entry [list $index $freq $name]
		}
	}

	return $entry
}


proc RefreshMatchList {top {ratingbox {}}} {
	variable ::[winfo toplevel $top]::Priv

	if {[llength $ratingbox] && ![$ratingbox valid?]} {
		$ratingbox set Elo
	}

	set item [lindex [split $Priv(focus) .] end]

	switch $Priv(entry) {
		white-name - black-name {
			if {![string match white-* $item] && ![string match black-* $item]} { return }
			set Priv(skip:player) "\uffff"
		}

		event-site {
			if {$item ne "event-site" && $item ne "event-country"} { return }
			set Priv(skip:site) "\uffff"
		}

		default {
			return
		}
	}

	UpdateMatchList $top $Priv(entry) $item
}


proc UpdateMatchList {top field item args} {
	variable History
	variable Attrs
	variable Colors
	variable ::[winfo toplevel $top]::Priv
	variable Options

	if {$Priv(dont-match)} { return }

	set base $Priv(base)
	set variant $Priv(variant)

	set attr ""
	switch $field {
		white-name - black-name	{ set attr player }
		event-title					{ set attr event }
		event-site					{ set attr site }
		game-annotator				{ set attr annotator }
	}

	if {[string length $attr] == 0} { return }

	if {$field eq $item} {
		if {$Priv(entry) eq $field && $Priv(skip:$attr) eq $Priv($field)} { return }
		set Priv(skip:$attr) $Priv($field)
	} else {
		set Priv(skip:$attr) "\uffff"
	}

	if {$attr eq "player"} {
		$Priv(footer) configure -foreground black
	} else {
		$Priv(footer) configure -foreground [::theme::getBackgroundColor]
	}

	set Priv(entry) $field
	set Priv(list) {}
	set Priv(curr:$attr) 0
	set Priv(focus) $top.$item
	set Priv(lb) $top.nb.matches.$attr.lb

	if {[string length $Priv($field)] == 0} {
		set matches $History($attr)
		set title $mc::History
	} else {
		set matches [::scidb::db::match \
			$attr $base $variant 10 $Priv($field) $Priv(ratingType) $Priv(twoRatings)]
		set title [set mc::[string toupper $attr 0 0]Base]
	}

	set row 0
	set lb $Priv(lb)
	set gamebase 0
	set playerbase 0
	set index 1

	set n [lsearch -exact $Attrs(player) name]
	set a $n

	switch $attr {
		player {
			set a [lsearch -exact $Attrs(player) ascii]
			set e [lsearch -exact $Attrs(player) elo]
			set s [lsearch -exact $Attrs(player) score]
			set f [lsearch -exact $Attrs(player) freq]
			set i 0

			foreach entry $matches {
				# we want positive scores
				lset matches $i $e [expr {abs([lindex $entry $e])}]
				lset matches $i $s [expr {abs([lindex $entry $s])}]

				# probably we want ASCII converted names
				if {!$Options(unicode)} { lset matches $i $n [lindex $entry $a] }

				incr i
			}
		}

		site {
			set a [lsearch -exact $Attrs(site) ascii]
			set i -1

			if {!$Options(unicode)} {
				# we want ASCII converted names
				foreach entry $matches { lset matches [incr i] $n [lindex $entry $a] }
			}
		}
	}

	foreach entry $matches {
		lappend Priv(list) $entry
		set data [MakeMatchEntry $top $index $entry $attr]
		if {[lindex $entry 0] == 0} {
			if {!$playerbase} {
				$lb insert [list {} {} $title] \
					-highlight 1 \
					-index $row \
					-enabled 0 \
					-foreground $Colors(matchlistHeaderForeground) \
					;
				incr row
				set playerbase 1
			}
		} elseif {!$gamebase} {
			$lb insert [list {} {} $mc::GameBase] \
				-highlight 1 \
				-index $row \
				-enabled 0 \
				-foreground $Colors(matchlistHeaderForeground) \
				;
			incr row
			set gamebase 1
		}
		$lb insert $data -index $row -enabled 1 -highlight 0
		set index [expr {($index + 1) % 10}]
		incr row
	}

	for {} {$row < 12} {incr row} {
		$lb insert { " " } -index $row -enabled 0 -highlight 0
	}

	$lb resize
	$lb recolor

	if {[$lb pointer] == -1} {
		$lb select none
		$lb activate none
	}

	raise [winfo parent $lb]
}


proc ClearMatchList {top {field ""}} {
	variable ::[winfo toplevel $top]::Priv

	if {[string length $field] == 0} {
		set field $Priv(entry)
	}

	switch $field {
		white-name - black-name	{ set attr player }
		event-title					{ set attr event }
		event-site					{ set attr site }
		game-annotator				{ set attr annotator }
		default						{ return }
	}

	set lb $top.nb.matches.$attr.lb

	for {set row 0} {$row < 12} {incr row} {
		$lb insert { " " } -index $row -enabled 0 -highlight 0
	}

	$lb select none
	$lb activate none
	$lb resize
	$lb recolor

	set Priv(entry) ""
	set Priv(skip:$attr) "\uffff"
	set Priv(list) {}
	set Priv(lb) ""
}


proc SelectActive {top lb} {
	# we have to recompute because the active state may got lost due to a tooltip popup
	set active [$lb pointer]
	if {$active >= 0} {
		SelectMatch $top $lb $active 1
	}
}


proc SelectMatch {top lb index complete} {
	if {[$lb active] eq $index} {
		set number [$lb get $index number]
		if {[incr number -1] == -1} { set number 9 }
		EnterMatch $top $lb $number $complete
	}
}


proc EnterMatch {top lb index complete} {
	variable ::[winfo toplevel $top]::Priv
	variable Attrs
	variable Selection

	set field $Priv(entry)
	if {[string length $field] == 0} { return }
	set Priv(dont-match) 1

	switch $field {
		white-name - black-name	{ set attr player }
		event-title					{ set attr event }
		event-site					{ set attr site }
		game-annotator				{ set attr annotator }
	}

	set data [lindex $Priv(list) $index]
	set freq [lindex $data 1]
	set Priv(match:$field) $data
	set Priv(curr:$attr) 1
	set attrs $Attrs($attr)

	if {$attr eq "player"} {
		set species [lindex $data [lsearch -exact $attrs species]]
		set side [string range $field 0 4]
		set color [string toupper $side 0 0]
		set list $Priv(select:$side)
		set ratingType [lindex $data [lsearch -exact $attrs rating]]
		set acceptRating [expr {$ratingType eq "Elo" || $ratingType eq $Priv(ratingType)}]
	} else {
		set list $Priv(select:$attr)
	}

	foreach {id type tag field} $list {
		set value [lindex $data [lsearch -exact $attrs $id]]
		set widget $top.$field

		if {[$widget cget -state] eq "normal"} {
			if {[llength $value] == 0 && $type eq "genderbox" && $species eq "program"} { set value "c" }
			set f [lindex [split $field -] 1]
			if {[string first . $f] >= 0} { set f [lindex [split $f .] 1] }
			set apply [expr {$complete || ![info exists Selection($attr:$f)] || $Selection($attr:$f)}]

			if {[llength $value]} {
				if {$apply} {
					switch $type {
						entrybox {
							$widget set $value
							set Priv(skip:$attr) $value
							UpdateTags $top $tag $field
						}

						titlebox	 {
							$widget set $value
							UpdateTags $top $tag $field
						}

						countrybox {
							$widget set $value
							UpdateTags $top $tag $field
						}

						ratingbox {
							if {$freq > 0 && $acceptRating} {
								$widget set $value
								UpdateRatingTags $top $color $side-rating $side-score
							}
						}

						scorebox {
							if {$freq > 0 && ([string match *Elo $tag] || $acceptRating)} {
								$widget set $value
								if {$tag eq "${color}Elo"} {
									UpdateTags $top $tag $field
								} else {
									UpdateRatingTags $top $color $side-rating $side-score
								}
							}
						}

						genderbox {
							if {$Selection(player:sex)} {
								$widget set $value
								UpdateSexTag $top $color $field
							}
						}

						fideidbox {
							$widget set $value
							UpdateTags $top $tag $field
						}

						default {
							$widget set $value
							UpdateTags $top $tag $field
						}
					}
				}
			} elseif {$apply} {
				switch $type {
					entrybox {
						$widget delete 0 end
						UpdateTags $top $tag $field
					}

					genderbox {
						$widget current 0
						UpdateSexTag $top $color $field
					}

					datebox {
						$widget set "????.??.??"
						UpdateTags $top $tag $field
					}

					ratingbox {
						# nothing to do
					}

					fideidbox {
						$widget set ""
						UpdateTags $top $tag $field
					}

					scorebox {
						$widget set 0
						if {$tag eq "${color}Elo"} {
							UpdateTags $top $tag $field
						} else {
							UpdateRatingTags $top $color $side-rating $side-score
						}
					}

					default {
						$widget current 0
						UpdateTags $top $tag $field
					}
				}
			} elseif {$type eq "genderbox" && $Selection(player:sex)} {
				$widget current 0
				UpdateSexTag $top $color $field
			}
		}
	}

	set Priv(dont-match) 0
	$Priv(focus) icursor end
	$Priv(focus) selection clear
}


proc SetFocus {dlg} {
	variable ::${dlg}::Priv

	if {[llength $Priv(focus)]} {
		if {[catch { $Priv(focus) focus }]} {
			focus $Priv(focus)
		}
	}
}


proc SetMaxWidth {f width} {
	if {$width > 1} {
		$f.lb configure -maxwidth $width
		pack propagate $f 0
	}
}


proc CompareTag {lhs rhs} {
	variable TagOrder

	set lhs [lindex $lhs 0]
	set rhs [lindex $rhs 0]

	if {![info exists TagOrder($lhs)]} { return -1 }
	if {![info exists TagOrder($rhs)]} { return +1 }

	return [expr {$TagOrder($lhs) - $TagOrder($rhs)}]
}


proc AddEmptyTag {t} {
	variable ::[winfo toplevel $t]::Priv

	if {$Priv(characteristics-only)} { return }

	set item [$t item create]
	$t item style set $item name styText
	$t item style set $item value styText
	$t item style set $item delete styImage
	$t item element configure $item name elemText -text ""
	$t item element configure $item value elemText -text ""
	$t item element configure $item delete elemText -text " "
	$t item element configure $item delete elemImage -image $icon::12x12::plus
	$t item lastchild root $item

	SetCurrentElement $t $item 0
}


proc NewItem {t name value} {
	variable TagOrder
	variable Item

	set item [$t item create]

	if {[info exists TagOrder($name)] && $TagOrder($name) < 99} {
		set icon $icon::12x12::locked
		$t item enabled $item 0
	} else {
		set icon $icon::12x12::delete
	}

	$t item style set $item name styText
	$t item style set $item value styText
	$t item style set $item delete styImage
	$t item element configure $item name elemText -text $name
	$t item element configure $item value elemText -text $value
	$t item element configure $item delete elemImage -image $icon

	set Item($name) $item
	return $item
}


proc SetupTags {top base variant idn position number} {
	variable ::[winfo toplevel $top]::Priv
	variable TagOrder
	variable RatingTagOrder
	variable Lookup

#	if {!$Priv(twoRatings)} { set Tag(PlyCount) 99 }

	foreach pair $Priv(tags) {
		lassign $pair name value
		set Lookup($name) $value
		if {![info exists TagOrder($name)]} {
			set TagOrder($name) 100
		}
	}

	foreach {tag field} {Event event-title
								Site event-site
								Round game-round
								White white-name
								Black black-name} {
		if {[info exists Lookup($tag)] && $Lookup($tag) ne "?"} {
			set value $Lookup($tag)
		} else {
			set value ""
		}
		$top.$field set $value
	}

	foreach {tag field} {Date game-date Result game-result} {
		if {[info exists Lookup($tag)]} { set value $Lookup($tag) } else { set value "" }
		$top.$field set $value
	}

	foreach {field tag} {game-annotator Annotator
								event-eventDate EventDate
								white-federation WhiteCountry
								black-federation BlackCountry
								event-country EventCountry
								white-title WhiteTitle
								black-title BlackTitle
								white-sex WhiteSex
								black-sex BlackSex
								game-termination Termination
								event-eventType EventType
								event-eventMode Mode
								event-timeMode TimeMode} {
		if {[info exists Lookup($tag)]} { set value $Lookup($tag) } else { set value "" }
		$top.$field set $value
	}

	foreach {field tag} {white-fideID WhiteFideId black-fideID BlackFideId} {
		if [winfo exists $top.$field] {
			if {[info exists Lookup($tag)]} { set value $Lookup($tag) } else { set value "" }
			$top.$field set $value
		}
	}

	foreach entry $Priv(disabled) { set Priv($entry) "" }

	if {[info exists Lookup(WhiteType)] && $Lookup(WhiteType) eq "program"} { $top.white-sex set c }
	if {[info exists Lookup(BlackType)] && $Lookup(BlackType) eq "program"} { $top.black-sex set c }

	if {[llength $position]} {
		lassign [::scidb::game::query $position ratingTypes] ratingType(White) ratingType(Black)
	} else {
		lassign [::scidb::db::get ratingTypes $number $base $variant] ratingType(White) ratingType(Black)
	}

	foreach rating $::ratingbox::ratings(all) {
		foreach side {White Black} {
			if {$rating eq "Elo"} {
				set order $TagOrder($side$rating)
			} else {
				set order 99
			}
			set Priv($side:ratingType) ---
			if {[info exists Lookup($side$rating)]} {
				set Priv($side:ratingType) $rating
				set w $top.[string tolower $side 0 0]-rating
				if {$rating eq "Elo"} {
					if {$Priv(twoRatings)} {
						$w.elo set $Lookup($side$rating)
					} else {
						$w.type set $rating
						$w.score set $Lookup($side$rating)
					}
					set order $RatingTagOrder($side$rating)
				} elseif {$rating eq $ratingType($side)} {
					$w.type set $rating
					$w.score set $Lookup($side$rating)
					set order $RatingTagOrder($side$rating)
				}
			}
			set TagOrder($side$rating) $order
		}
	}

	if {$variant eq "Normal"} {
		if {$idn == 518} {
			if {[info exists Lookup(ECO)]} {
				$top.game-eco set $Lookup(ECO)
				set Priv(game-eco-flag) 1
			} else {
				if {[llength $position]} {
					set eco [::scidb::game::query $position eco]
				} else {
					set eco [::scidb::db::get eco $number $base $variant]
				}
				$top.game-eco set $eco
				set Priv(game-eco-flag) 0
			}
		}
	} else {
		$top.game-eco set ""
		set Priv(game-eco-flag) 0
	}

	set Priv(tags) [lsort -command [namespace current]::CompareTag $Priv(tags)]
	set t $top.nb.tags.list
	foreach pair $Priv(tags) {
		$t item lastchild root [NewItem $t {*}$pair]
	}
	AddEmptyTag $t
	bind $t <Configure> [namespace code [list ExpandLastColumn $t %w]]
}


proc ExpandLastColumn {t width} {
	if {$width > 1} {
		$t column expand value yes
		$t column squeeze value
		bind $t <Configure> {}
	}
}


proc NormalizeDate {date} {
	lassign [split $date "."] y m d
	if {$y eq "????"} { return "" }
	if {$m eq "??"} { return $y }
	if {$d eq "??"} { return "$y.$m" }
	return "$y.$m.$d"
}


proc Save {top fields} {
	variable ::[winfo toplevel $top]::Priv
	variable Tags
	variable WhiteRating
	variable BlackRating
	variable Attrs
	variable History

	set base $Priv(base)
	set variant $Priv(variant)
	set number $Priv(number)
	set position $Priv(position)
	set title $Priv(title)
	set Priv(dont-match) 1
	set rc [CheckFields $top $title $fields]
	set Priv(dont-match) 0

	if {$rc} {
		::widget::busyCursor on
		if {$Priv(characteristics-only)} {
			::scidb::db::update $base $variant $number [array get Tags] 
		} else {
			::log::open $title
			::log::delay
			::log::info [string map \
				[list %white $Tags(White) %black $Tags(Black) %event $Tags(Event) %base $base] \
				$mc::SavingGameLogInfo]
			set replace [expr {$number >= 0}]
			set cmd [list ::scidb::game::save \
				$base \
				$variant \
				[array get Tags] \
				$WhiteRating \
				$BlackRating \
				[namespace current]::Log {} \
				-replace $replace \
			]
			if {[::util::catchException $cmd result] != 0} {
				::widget::busyCursor off
				return
			}
			::widget::busyCursor off
			if {$result} {
				::log::hide
			} else {
				::dialog::error \
					-parent $top \
					-message $mc::SaveGameFailed \
					-detail $mc::SaveGameFailedDetail \
					-title $title \
					;
			}
			::log::close
		}

		foreach {attr field} {	player white-name
										player black-name
										event event-title
										site event-site
										annotator game-annotator} {
			if {[llength $Priv(match:$field)]} {
				set name($field) [lindex $Priv(match:$field) [lsearch -exact $Attrs($attr) name]]
				set ascii($field) [lindex $Priv(match:$field) [lsearch -exact $Attrs($attr) ascii]]
			}

			set hist($field) [lrepeat [llength $Attrs($attr)] {}]
			lset hist($field) [lsearch -exact $Attrs($attr) freq] 0
		}

		foreach color {White Black} {
			set i 0
			set side [string tolower $color 0 0]

			foreach field $Attrs(player) {
				set tag -

				switch $field {
					name			{ set tag $color }
					fideID		{ set tag ${color}FideId }
					species		{ set tag ${color}Type }
					sex			{ set tag ${color}Sex }
					federation	{ set tag ${color}Country }
					title			{ set tag ${color}Title }
					elo			{ set tag ${color}Elo }
				}

				if {[info exists Tags($tag)]} {
					lset hist($side-name) $i $Tags($tag)
				}

				switch $field {
					elo - score {
						if {[llength [lindex $hist($side-name) $i]] == 0} {
							lset hist($side-name) $i 0
						}
					}
				}

				incr i
			}

			if {[llength [set ${color}Rating]]} {
				set i  [lsearch -exact $Attrs(player) rating]
				lset hist($side-name) $i [string range [set ${color}Rating] 5 end]
				set i  [lsearch -exact $Attrs(player) score]
				lset hist($side-name) $i $Tags([set ${color}Rating])
			}
		}

		set i 0
		foreach field $Attrs(event) {
			set tag -

			switch $field {
				name			{ set tag Event }
				eventDate	{ set tag EventDate }
				eventMode	{ set tag Mode }
				eventType	{ set tag EventType }
				timeMode		{ set tag TimeMode }
			}

			if {[info exists Tags($tag)]} {
				set value $Tags($tag)
				if {$tag eq "EventDate"} { set value [NormalizeDate $value] }
				lset hist(event-title) $i $value
			}

			incr i
		}

		set i 0
		foreach field $Attrs(site) {
			set tag -

			switch $field {
				name			{ set tag Site }
				country		{ set tag EventCountry }
			}

			if {[info exists Tags($tag)]} {
				lset hist(event-site) $i $Tags($tag)
			}

			incr i
		}

		if {[info exists Tags(Annotator)]} {
			lset hist(game-annotator) [lsearch -exact $Attrs(annotator) name] $Tags(Annotator)
		}

		foreach {attr field} {	player white-name
										player black-name
										event event-title
										site event-site
										annotator game-annotator} {
			set i [lsearch -exact $Attrs($attr) name]
			set k [lsearch -exact $Attrs($attr) ascii]

			if {[string length [lindex $hist($field) $i]] > 2} {
				switch $attr {
					player - site {
						lset hist($field) $k [lindex $hist($field) $i]
						if {[info exists name($field)]} {
							if {[lindex $hist($field) $i] eq $name($field)} {
								lset hist($field) $k $ascii($field)
							} 
						}
					}
				}

				set i [lsearch $History($attr) $hist($field)]
				
				if {$i >= 0} {
					set History($attr) [lreplace $History($attr) $i $i]
				} elseif {[llength $History($attr)] == 10} {
					set History($attr) [lreplace $History($attr) end end]
				}

				set History($attr) [linsert $History($attr) 0 $hist($field)]
			}
		}
	}

	array unset Tags
	unset WhiteRating
	unset BlackRating

	::widget::busyCursor off
	if {$rc} { Withdraw [winfo toplevel $top] }
}


proc Withdraw {dlg} {
	variable Priv

	wm withdraw $dlg
	set Priv(finished) 1
}


proc Log {_ arguments} {
	lassign $arguments type msg number
	::log::error [set ::import::mc::$msg]
}


proc Truncate {str} {
	while {[string bytelength $str] > 255} {
		set str [string range 0 end-1]
	}

	return $str
}


proc CheckFields {top title fields} {
	variable ::[winfo toplevel $top]::Priv
	variable Lookup
	variable Tags
	variable WhiteRating
	variable BlackRating

	set warnings {}
	array set Tags {}
	set WhiteRating {}
	set BlackRating {}

	foreach entry $fields {
		set tag [lindex $entry 0]

		switch $tag {
			White - Black - Event - Site {
				lassign $entry tagName field
				set value ""
				if {[info exists Priv($field)]} { set value $Priv($field) }
				if {[string length $value] == 0} {
					set value "?"
				}
				set str [Truncate $value]
				if {[string bytelength $value] > 255} {
					lappend warnings \
						[string map [list %tag% $tag %value% $value %trunc% $str] $mc::StringTooLong]
				}
				set Tags($tagName) $str
			}

			Round {
				lassign $entry tagName field
				set value [$top.$field value]
				if {[string length $value] == 0} {
					set value "?"
				} elseif {$value eq "?" || $value eq "-"} {
					# nothing to do
				} elseif {![$top.$field valid?]} {
					::dialog::error \
						-parent $top \
						-message [format $mc::InvalidRoundEntry $value] \
						-detail $mc::InvalidRoundEntryDetail \
						-title $title \
						;
						$top.$field focus
						return 0
				} else {
					set rc [$top.$field check]
					if {$rc > 0} {
						if {$rc == 1} {
							set detail $mc::RoundIsTooHigh
						} else {
							set detail $mc::SubroundIsTooHigh
						}
						::dialog::error \
							-parent $top \
							-message [format $mc::InvalidRoundEntry $value] \
							-detail $detail \
							-title $title \
							;
							$top.$field focus
							return 0
					}
				}
				set str [Truncate $value]
				if {[string length $value] > 255} {
					lappend warnings \
						[string map [list %tag% $tag %value% $value %trunc% $str] $mc::StringTooLong]
				}
				set Tags($tagName) $str
			}

			Annotator {
				lassign $entry tagName field
				if {[info exists Priv($field)]} {
					set value $Priv($field)
					if {[string length $value] && $value ne "?" && $value ne "-"} {
						set str [Truncate $value]
						if {[string length $value] > 255} {
							lappend warnings \
								[string map [list %tag% $tag %value% $value %trunc% $str] $mc::StringTooLong]
						}
						set Tags($tagName) $str
					}
				}
			}

			Date - EventDate {
				lassign $entry tagName field
				lassign [$top.$field date] value error
				if {[llength $error] == 0} {
					if {$tagName eq "Date"} {
						lassign [$top.event-eventDate date] date error
						if {[llength $error] == 0} {
							set cmp [::calendar::compare $value $date]
							if {$cmp == -1} {
								lappend warnings \
									[format $mc::ImplausibleDate [$top.$field value] [$top.event-eventDate value]]
							}
						}
					} elseif {$Priv(characteristics-only) && !$Priv(twoRatings)} {
						set ey [string range $value 0 3]

						if {$ey ne "????"} {
							set dy [string range $Tags(Date) 0 3]

							if {$dy eq "????" || abs($dy - $ey) > 3} {
								::dialog::error -parent $top -message $mc::InvalidEventDate -title $title
								$top.$field focus
								return 0
							}
						}
					}
					set Tags($tagName) $value
				} else {
					set msg [format $mc::Field [set [${top}.${field}-l cget -textvar]]]
					append msg [format [set mc::$error] $value]
					::dialog::error -parent $top -message $msg -title $title
					$top.$field focus
					return 0
				}
			}

			Result - WhiteSex - BlackSex {
				lassign $entry tagName field
				if {![$top.$field valid?]} {
					set msg [format $mc::Field [set [${top}.${field}-l cget -textvar]]]
					append msg [format $mc::InvalidEntry $Priv($field)]
					::dialog::error -parent $top -message $msg -title $title
					$top.$field selection clear
					$top.$field selection range 0 end
					$top.$field icursor end
					focus $top.$field
					return 0
				}
				
				if {[string length [$top.$field value]]} {
					set Tags($tagName) [$top.$field value]

					switch [lindex $entry 0] {
						WhiteSex { set Tags(WhiteType) [$top.$field type] }
						BlackSex { set Tags(BlackType) [$top.$field type] }
					}
				}
			}

			WhiteElo - BlackElo {
				lassign $entry tagName field
				set value [$top.$field value]
				if {[string length $value]} {
					set Tags($tagName) $value
				}
			}

			WhiteRating - BlackRating {
				lassign $entry tagName typeField scoreField
				set value [$top.$scoreField value]
				if {[string length $value]} {
					set type [string range [lindex $entry 0] 0 4][$top.$typeField value]
					set Tags($type) $value
					set [lindex $entry 0] $type
				}
			}

			WhiteFideId - BlackFideId {
				lassign $entry tagName field
				set value [$top.$field value]
				if {[string length $value]} {
					set Tags($tagName) $value
				}
			}

			WhiteCountry - BlackCountry -
			WhiteTitle - BlackTitle -
			EventCountry - EventType -
			Termination - Mode -
			TimeMode - ECO {
				if {$tag ne "ECO" || $Priv(game-eco-flag)} {
					lassign $entry tagName field
					set value ""
					if {[info exists Priv($field)]} { set value $Priv($field) }
					if {![$top.$field valid?]} {
						set msg [format $mc::Field [set [${top}.${field}-l cget -textvar]]]
						append msg [format $mc::InvalidEntry $value]
						::dialog::error -parent $top -message $msg -title $title
						$top.$field selection clear
						$top.$field selection range 0 end
						$top.$field icursor end
						focus $top.$field
						return 0
					}
					set value [$top.$field value]
					if {[string length $value]} { set Tags($tagName) $value }
				}
			}
		}
	}

	foreach tag [array names Lookup] {
		if {![info exists Tags($tag)]} {
			set value $Lookup($tag)
			if {[string length $value] == 0} {
				lappend warnings [format $mc::TagIsEmpty $tag]
			} elseif {$value ne "?"} {
				set error ""

				if {![regexp {^[A-Za-z][A-Za-z0-9_]*$} $tag]} {
					set column 1
					set error [format $mc::InvalidTagName $tag]
				} else {
					set column 2

					switch $tag {
						WhiteNA - BlackNA {
							set local ""
							set domain ""
							lassign [split $value @] local domain rest
							if {	![regexp {^[A-Za-z0-9!#$%&'*+\-/=?^_`{|}~.]+$} $local]
								|| ![regexp {^[A-Za-z0-9-.]+$} $domain]
								|| [string match {*..*} $value]
								|| [string index $local 0] eq "."
								|| [string index $local end] eq "."
								|| [string index $domain 0] eq "."
								|| [string index $domain end] eq "."
								|| [info exists rest]} {
								set error [format $mc::ExtraTag $tag]
								append error [format $mc::InvalidNetworkAddress $value]
							}
						}

						WhiteTeamCountry - BlackTeamCountry {
							set code [::scidb::misc::lookup countryCode $value]
							if {[string length $code] == 0} {
								set error [format $mc::ExtraTag $tag]
								append error [format $mc::InvalidCountryCode $value]
							} elseif {$code ne $value} {
								# TODO: show warning about non-standard country code
							}
						}

						EventRounds {
							if {![string is integer -strict $value] || $value < 0} {
								set error [format $mc::ExtraTag $tag]
								append error [format $mc::InvalidEventRounds $value]
							}
						}

						SourceDate {
							lassign {{} {} {}} y m d
							lassign [split $value .] y m d
							lassign [datebox::validate $y $m $d] date err
							if {[llength $err]} {
								set error [format $mc::ExtraTag $tag]
								append error [format [set mc::$err] $value]
							} else {
								set Tags($tag) $date
							}
						}

						TimeControl {
							if {$value eq "-"} {
								set Tags($tag) $value
							} else {
								set valid 1
								foreach part [split $value :] {
									if {![regexp {^([*]?[0-9]+|[0-9]+[/+][0-9]+)$} $part]} {
										set valid 0
									}
								}
								if {$valid} {
									set Tags($tag) $value
								} else {
									set msg [format $mc::ExtraTag $tag]
									append msg [format InvalidTimeControl $value]
									lappend warnings $msg
								}
							}
						}

						PlyCount {
							if {![string is integer -strict $value] || $value < 0} {
								set error [format $mc::ExtraTag $tag]
								append error [format $mc::InvalidPlyCount $value]
							} else {
								set plyCount [::scidb::game::count halfmoves]
								if {$plyCount != $value} {
									set error [format $mc::ExtraTag $tag]
									append error [format $mc::IncorrectPlyCount $value $plyCount]
								}
							}
						}
					}

					if {[llength $error] == 0} {
						set str [Truncate $value]
						if {[string length $value] > 255} {
							lappend warnings \
								[string map [list %tag% $tag %value% $value %trunc% $str] $mc::StringTooLong]
						}
						set Tags($tag) $str
					}
				}

				if {[llength $error]} {
					$top.nb select $top.nb.tags
					focus $top.nb.tags.list
					SetCurrentElement $top.nb.tags.list [FindElement $top.nb.tags.list $tag] $column
					::dialog::error -parent $top -message $error -title $title
					return 0
				}
			}
		}
	}

	foreach msg $warnings {
		if {[::dialog::warning -parent $top -message $msg -title $title] eq "cancel"} {
			return 0
		}
	}

	return 1
}


proc SetPlayerFromDict {dlg side info} {
	variable ::${dlg}::Priv
	lassign $info Priv(${side}-name) Priv(${side}-fideID)
	::widget::dialogRaise $dlg
	focus -force $dlg.top.$side-name
	$dlg.top.$side-name icursor end
	::playerdict::unsetReceiver
}


proc GetPlayerFromDict {dlg side} {
	variable ::${dlg}::Priv
	::playerdict::setReceiver [namespace code [list SetPlayerFromDict $dlg $side]]
	::playerdict::open . -federation Fide -rating1 Elo -rating2 $Priv(${side}-rating)
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Colors
	options::writeItem $chan [namespace current]::Options
	options::writeItem $chan [namespace current]::History
	options::writeItem $chan [namespace current]::Selection
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 12x12 {

set plus [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMBAMAAACkW0HUAAAAJFBMVEUAAAAwcUgwcUgwcUgw
	cUgwcUgwcUgwcUgzc0o4eE89fFT5/PqNxoUaAAAAB3RSTlMAAwQFDA44rjWicAAAADRJREFU
	CNdjYCoHAgEGdRBVwlBeXr29vJyhAkQth/HKdwMBgoIKgqjpEKqdIRyinRlEJQAAxfwjtX9r
	sv4AAAAASUVORK5CYII=
}]

set locked [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAABrUlEQVQozzWQLWxTURhAz/e9uw4YHaEsS5YOzAICwUI9
	GhLUEjKJQIBA4MAgUTgEJCAQKJgnGQaDAdOxJZA00GSBjjH2KO1K2/dz7/0QHccdccwRgOvH
	YPnKMovnFy+JyF3R5AKAxbBlZg87nzvvNtc3eTECAVi7fxWQhiTuEdi3UOZvAJKp6csgZyz4
	O2DN1QevcQDD3h4gK65yRCRx90S0A+DL/K0F/9IX2QpYE5gEvd2vAHOItFQ1NTMARCSNMbYw
	m+MQB3CiNhGLIbNYmohM3MxENRNV/R+IP2iRVBfObry6/Tw72Im1+tKaJq4EiMFPdXfaq9PV
	ujauPb4x7u9+kVH7CSJ6M8v6T4t8CBgxRAA0UUSEaDOEOHsL7JnL0yZghMop1FUJPrCxtQ1A
	4+IS6hKKfsrf/Raighv++ohYIBytY5Ua+z//0PzQBmB+psf8wkkGv7t0v3fQJMEVWQALePOE
	omQ8GCMxADAejBlVj5ONPHkRUAWXFwKmlNEY5UNCETl3ehaAUET66RBfGGWhqAru0/ttxIzg
	9vAmYMbhVX6kgAhFbgx6GaLCP9Bl3E0+Ey+vAAAAAElFTkSuQmCC
}]

set delete $::icon::12x12::close

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace save
} ;# namespace dialog


bind TagList <Motion> {
	TreeCtrl::CursorCheck %W %x %y
	TreeCtrl::MotionInHeader %W %x %y
	TreeCtrl::MotionInItems %W %x %y
}
bind TagList <Leave> {
	TreeCtrl::CursorCancel %W
	TreeCtrl::MotionInHeader %W
	TreeCtrl::MotionInItems %W
}
bind TagList <ButtonPress-1> {
	TreeCtrl::ButtonPress1 %W %x %y
	::dialog::save::EditTag %W %x %y
}
bind TagList <Button1-Motion> {
	TreeCtrl::Motion1 %W %x %y
}
bind TagList <ButtonRelease-1> {
	TreeCtrl::Release1 %W %x %y
	::dialog::save::ActivateTag %W %x %y
}

bind TagList <Key-Left>		{ ::dialog::save::ChangeCurrentElement %W -1 0 }
bind TagList <Key-Right>	{ ::dialog::save::ChangeCurrentElement %W +1 0 }
bind TagList <Key-Up>		{ ::dialog::save::ChangeCurrentElement %W 0 -1 }
bind TagList <Key-Down>		{ ::dialog::save::ChangeCurrentElement %W 0 +1 }
bind TagList <Key-space>	{ ::dialog::save::ActivateCurrentElement %W }

# vi:set ts=3 sw=3:
