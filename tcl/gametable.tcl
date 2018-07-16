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
# Copyright: (C) 2009-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source game-table

namespace eval gametable {
namespace eval mc {

set DeleteGame				"Mark game as deleted"
set UndeleteGame			"Undelete this game"
set EditGameFlags			"Edit game flags"
set Custom					"Custom"

set Monochrome				"Monochrome"
set Transparent			"Transparent"
set Relief					"Relief"
set ShowIdn					"Show Chess 960 Position Number"
set Icons					"Icons"
set Abbreviations			"Abbreviations"

set SortAscending			"Sort (ascending)"
set SortDescending		"Sort (descending)"
set SortOnAverageElo		"Sort on average Elo (descending)"
set SortOnAverageRating	"Sort on average rating (descending)"
set SortOnDate				"Sort on date (descending)"
set SortOnNumber			"Sort on game number (ascending)"
set ReverseOrder			"Reverse order"
set CancelSort				"Cancel sort"
set NoMoves					"No moves"
set NoMoreMoves			"No (more) moves"
set WhiteRating			"White Rating"
set BlackRating			"Black Rating"

set Flags					"Flags"
set PGN_CountryCode		"PGN country code"
set ISO_CountryCode		"ISO country code"
set ExcludeElo				"Exclude Elo"
set IncludePlayerType	"Include player type"
set ShowTournamentTable "Show Tournament Table"

set Long						"Long"
set Short					"Short"
set IncludeVars			"Include Variations"

set Accel(browse)			"W"
set Accel(overview)		"O"
set Accel(tourntable)	"T"
set Space					"Space"

set F_Number				"#"
set F_White					"White"
set F_Black					"Black"
set F_Event					"Event"
set F_Site					"Site"
set F_Date					"Date"
set F_Result				"Result"
set F_Round					"Round"
set F_Annotator			"Annotator"
set F_Length				"Length"
set F_Termination			"Termination"
set F_EventMode			"Mode"
set F_Eco					"ECO"
set F_Flags					"Flags"
set F_Material				"Material"
set F_Acv					"ACV"
set F_Idn					"960"
set F_Position				"Position"
set F_MoveList				"Move List"
set F_EventDate			"Event Date"
set F_EventType			"Ev.Type"
set F_Promotion			"Promotion"
set F_UnderPromo			"Under-Promotion"
set F_StandardPos			"Standard Position"
set F_Opening				"Opening"
set F_Variation			"Variation"
set F_Subvariation		"Subvariation"
set F_Overview				"Overview"
set F_Key					"Internal ECO code"

set T_Number				"Number"
set T_Acv					"Annotations / Comments / Variations"
set T_WhiteRatingType	"White Rating Type"
set T_BlackRatingType	"Black Rating Type"
set T_WhiteCountry		"White Federation"
set T_BlackCountry		"Black Federation"
set T_WhiteTitle			"White Title"
set T_BlackTitle			"Black Title"
set T_WhiteType			"White Type"
set T_BlackType			"Black Type"
set T_WhiteSex				"White Sex"
set T_BlackSex				"Black Sex"
set T_EventCountry		"Event Country"
set T_EventType			"Event Type"
set T_Chess960Pos			"Chess 960 Position"
set T_ShuffleChessPos	"Shuffle Chess Position"
set T_Deleted				"Deleted"
set T_Changed				"Changed"
set T_Added					"Added"
set T_EngFlag				"English Language Flag"
set T_OthFlag				"Other Language Flag"
set T_Idn					"Chess 960 Position Number"
set T_Annotations			"Annotations"
set T_Comments				"Comments"
set T_Variations			"Variations"
set T_TimeMode				"Time Mode"

set P_Name					"Name"
set P_FideID				"Fide ID"
set P_Rating				"Rating Score"
set P_RatingType			"Rating Type"
set P_Country				"Country"
set P_Title					"Title"
set P_Type					"Type"
set P_Sex					"Sex"

set G_Player				"Player"
set G_Event					"Event"
set G_Game					"Game information"
set G_Opening				"Opening"
set G_Flags					"Flags"
set G_Notation				"Notation"
set G_Internal				"Internal"

set PlayerType(human)	"Human"
set PlayerType(program)	"Computer"

set EventType(game)		"Game"
set EventType(match)		"Match"
set EventType(tourn)		"Tourn"
set EventType(swiss)		"Swiss"
set EventType(team)		"Team"
set EventType(k.o.)		"KO"
set EventType(simul)		"Simul"
set EventType(schev)		"Schev"

set GameFlags(w)			"White Opening"
set GameFlags(b)			"Black Opening"
set GameFlags(m)			"Middle Game"
set GameFlags(e)			"End Game"
set GameFlags(N)			"Novelty"
set GameFlags(p)			"Pawn Structure"
set GameFlags(T)			"Tactics"
set GameFlags(K)			"King Side"
set GameFlags(Q)			"Queen Side"
set GameFlags(!)			"Brilliancy"
set GameFlags(?)			"Blunder"
set GameFlags(U)			"User"
set GameFlags(*)			"Best Game"
set GameFlags(D)			"Decided Tournament"
set GameFlags(G)			"Model Game"
set GameFlags(S)			"Strategy"
set GameFlags(^)			"Attack"
set GameFlags(~)			"Sacrifice"
set GameFlags(=)			"Defense"
set GameFlags(M)			"Material"
set GameFlags(P)			"Piece Play"
set GameFlags(t)			"Tactical Blunder"
set GameFlags(s)			"Strategical Blunder"
set GameFlags(I)			"Illegal Move"

# translation not needed (TODO)
set F_Chess960Pos			"9"
set F_ShuffleChessPos	"3"	;# TODO: use icon instead (dice)
set F_WhiteRatingType	"RT \u26aa"
set F_BlackRatingType	"RT \u26ab"
set F_WhiteFideID			"ID \u26aa"
set F_BlackFideID			"ID \u26ab"
set F_WhiteCountry		"\u2690"	;# TODO: use [Scidb Symbol T1] \U+0152 or \U+00d4
set F_BlackCountry		"\u2691"	;# TODO: use [Scidb Symbol T1] \U+0142
set F_EventCountry		"\u2691"

set RatingType(Any)		"-Any-"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::min

#		ID   				Group	Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------------------
variable Columns {
	{ number				game		right		 4		 9		 6			0			1			1			{}				}
	{ white				white		left		10		 0		18			1			1			1			darkblue		}
	{ whiteFideID		white		right		 0		 0		10			0			1			1			{}				}
	{ whiteRating1		white		center	 0		 0		 6			0			1			1			darkgreen	}
	{ whiteRating2		white		center	 0		 0		 6			0			1			1			darkgreen	}
	{ whiteRatingType	white		left		 0		 0		 7			0			1			0			darkgreen	}
	{ whiteCountry		white		center	 4		 5		 5			0			1			0			darkgreen	}
	{ whiteTitle		white		left		 0		 0		 5			0			1			1			darkred		}
	{ whiteType			white		center	 0		 0		14px		0			1			0			{}				}
	{ whiteSex			white		center	 0		 0		14px		0			1			0			{}				}
	{ black				black		left		10		 0		18			1			1			1			darkblue		}
	{ blackFideID		black		right		 0		 0		10			0			1			1			{}				}
	{ blackRating1		black		center	 0		 0		 6			0			1			1			darkgreen	}
	{ blackRating2		black		center	 0		 0		 6			0			1			1			darkgreen	}
	{ blackRatingType	black		left		 0		 0		 7			0			1			0			darkgreen	}
	{ blackCountry		black		center	 4		 5		 5			0			1			0			darkgreen	}
	{ blackTitle		black		left		 0		 0		 5			0			1			1			darkred		}
	{ blackType			black		center	 0		 0		14px		0			1			0			{}				}
	{ blackSex			black		center	 0		 0		14px		0			1			0			{}				}
	{ event				event		left		10		 0		18			1			1			1			{}				}
	{ eventType			event		left		 2		 8		 6			0			1			0			{}				}
	{ eventDate			event		left		 5		10		10			0			1			0			darkred		}
	{ result				game		center	 5		 5		 5			0			1			1			blue			}
	{ eventCountry		event		center	 4		 5		 5			0			1			0			{}				}
	{ site				event		left		10		 0		16			1			1			1			{}				}
	{ date				game		left		 5		10		10			0			1			0			darkred		}
	{ round				game		right		 2		 0		 5			0			1			1			{}				}
	{ annotator			game		left		10		 0		10			0			1			1			darkred		}
	{ idn					opening	right		 0		 0		 5			0			1			1			#68480a		}
	{ position			opening	left		 0		 0		13			0			1			1			#68480a		}
	{ moveList			notation	left		10		 0		20			1			1			1			{}				}
	{ length				game		right		 3		 5		 4			0			1			1			{}				}
	{ eco					opening	left		 4		 5		 4			0			1			0			darkgreen	}
	{ flags				flags		left		 2		 0		54px		0			1			0			{}				}
	{ material			notation	left		 8		 0		25			0			1			1			{}				}
	{ deleted			flags		center	 0		 0		14px		0			1			0			red			}
	{ changed			flags		center	 0		 0		14px		0			1			0			{}				}
	{ added				flags		center	 0		 0		14px		0			1			0			{}				}
	{ acv					flags		center	 0		 0		30px		0			1			0			{}				}
	{ engFlag			flags		center	 0		 0		18px		0			1			0			black			}
	{ othFlag			flags		center	 0		 0		18px		0			1			0			black			}
	{ promotion			flags		center	 0		 0		14px		0			1			0			{}				}
	{ underPromo		flags		center	 0		 0		14px		0			1			0			{}				}
	{ standardPos		flags		center	 0		 0		14px		0			1			0			{}				}
	{ chess960Pos		flags		center	 0		 0		14px		0			1			0			{}				}
	{ termination		game		center	 0		 0		14px		0			1			0			{}				}
	{ eventMode			event		center	 0		 0		14px		0			1			1			{}				}
	{ timeMode			event		center	 0		 0		14px		0			1			1			{}				}
	{ opening			opening	left		10		 0		15			1			1			1			{}				}
	{ variation			opening	left		10		 0		10			1			1			1			{}				}
	{ subvariation		opening	left		10		 0		10			1			1			1			{}				}
	{ key					internal	right		 4		 9		 9			0			1			0			magenta4		}
}
# alternative colors: darkgoldenrod

variable Count { "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10-12" "13-17" "18-24" "25-34" "35-44" "45+" }

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Defaults {
	monochrome				0
	showIDN					0
	relief					0
	transparent				0
	opening-index			0
	opening-variations	0
	exclude-elo				1
	include-type			0
	country-code			flags
	eventtype-icon			1
	move:figurines			graphic
	move:notation			san
	rating:1					Elo
	rating:2					DWZ
}

array set GameFlags {}

variable ratings {Elo DWZ ECF IPS USCF ICCF Rapid Rating Any}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable Defaults
	variable Columns
	variable MoveStyle
	variable ratings

	if {![info exists MoveStyle]} {
		trace add variable ::pgn::setup::mc::Setup(MoveStyle) write [namespace code UpdateMoveStyleLabel]
		UpdateMoveStyleLabel
	}

	namespace eval $path {}
	variable ${path}::Vars
	variable ${path}::Options

	array set Vars {
		deleted		1
		sortable		1
		mode			normal
		pool			{}
		crosshand	{}
		columns		{}
		positioncmd	{}
		selectcmd	{}
		range			{}
		afterID		{}
	}

	array set options $args
	foreach opt {id positioncmd selectcmd mode sortable} {
		if {[info exists options(-$opt)]} {
			set Vars($opt) $options(-$opt)
			unset options(-$opt)
		}
	}
	set args [array get options]
	lappend args -popupcmd [namespace code PopupMenu]
	lappend args -id $Vars(id)

	array set Options [array get Defaults]
	::scrolledtable::bindOptions $Vars(id) [namespace current]::${path}::Options [array names Defaults]
	RefreshHeader $path 1
	RefreshHeader $path 2

	set columns {}
	set index 0
	foreach column $Columns {
		lassign $column id group adjustment minwidth maxwidth width stretch removable ellipsis color
		set checkbutton 0
		set menu {}

		switch $id {
			number {
				if {$Vars(mode) eq "merge"} {
					set adjustment center
					set removable 0
					set minwidth 0
					set maxwidth 0
					set width 17px
					set checkbutton 1
					lappend args -lock number
				}
			}

			acv {
				set Vars(acvsize) [string range $width 0 end-2]
				lappend menu [list checkbutton \
					-command [namespace code [list RefreshImages $path]] \
					-labelvar [namespace current]::mc::Monochrome \
					-variable [namespace current]::${path}::Options(monochrome) \
				]
				lappend menu [list checkbutton \
					-command [namespace code [list RefreshImages $path]] \
					-labelvar [namespace current]::mc::Transparent \
					-variable [namespace current]::${path}::Options(transparent) \
				]
				lappend menu [list checkbutton \
					-command [namespace code [list RefreshImages $path]] \
					-labelvar [namespace current]::mc::Relief \
					-variable [namespace current]::${path}::Options(relief) \
				]
				lappend menu { separator }
			}

			eco {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar [namespace current]::mc::ShowIdn \
					-variable [namespace current]::${path}::Options(showIDN) \
				]
				lappend menu { separator }
				set Vars(eco-index) $index
			}

			whiteCountry - blackCountry - eventCountry {
				foreach {labelvar value} {Flags flags PGN_CountryCode PGN ISO_CountryCode ISO} {
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshCountries $path]] \
						-labelvar [namespace current]::mc::$labelvar \
						-variable [namespace current]::${path}::Options(country-code) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			whiteRating1 - blackRating1 - whiteRating2 - blackRating2 {
				set number [string index $id 11]
				foreach ratType $ratings {
					if {[info exists mc::RatingType($ratType)]} {
						set rt $mc::RatingType($ratType)
					} else {
						set rt $ratType
					}
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $path $number]] \
						-label $rt \
						-variable [namespace current]::${path}::Options(rating:$number) \
						-value $ratType \
					]
				}
				lappend menu { separator }
			}

			whiteRatingType - blackRatingType {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar [namespace current]::mc::ExcludeElo \
					-variable [namespace current]::${path}::Options(exclude-elo) \
				]
				lappend menu { separator }
			}

			whiteSex - blackSex {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar ::gametable::mc::IncludePlayerType \
					-variable [namespace current]::${path}::Options(include-type) \
				]
				lappend menu { separator }
			}

			eventType {
				lappend menu [list radiobutton \
					-command [namespace code [list RefreshEventType $path]] \
					-labelvar [namespace current]::mc::Icons \
					-variable [namespace current]::${path}::Options(eventtype-icon) \
					-value 1 \
				]
				lappend menu [list radiobutton \
					-command [namespace code [list RefreshEventType $path]] \
					-labelvar [namespace current]::mc::Abbreviations \
					-variable [namespace current]::${path}::Options(eventtype-icon) \
					-value 0 \
				]
				lappend menu { separator }
			}

			idn {
				set Vars(idn-index) $index
			}

			moveList {
				lappend menu {*}[::notation::buildMenuForShortNotation \
					[namespace code [list Refresh $path]] \
					[namespace current]::${path}::Options(move:notation) \
				]
				lappend menu { separator }
				lappend menu [list command \
					-command [namespace code [list SelectFigurines $path]] \
					-labelvar [namespace current]::MoveStyle \
				]
				lappend menu { separator }
			}
		}

		switch $id {
			variation - subvariation - key {}

			opening {
				foreach {labelvar value} {Long 1 Short 0} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar [namespace current]::mc::$labelvar \
						-variable [namespace current]::${path}::Options(opening-index) \
						-value $value \
					]
				}
				lappend menu { separator }
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar [namespace current]::mc::IncludeVars \
					-variable [namespace current]::${path}::Options(opening-variations) \
					-onvalue 1 \
					-offvalue 0 \
				]
				lappend menu { separator }
			}

			default {
				if {$Vars(sortable)} {
					lappend menu [list command \
						-command [namespace code [list SortColumn $path $id ascending]] \
						-labelvar [namespace current]::mc::SortAscending \
					]
					lappend menu [list command \
						-command [namespace code [list SortColumn $path $id descending]] \
						-labelvar [namespace current]::mc::SortDescending \
					]
					switch $id {
						whiteRating1 - blackRating1 - whiteRating2 - blackRating2 {
							lappend menu [list command \
								-command [namespace code [list SortColumn $path $id average]] \
								-labelvar [namespace current]::mc::SortOnAverageRating \
							]
						}
					}
					lappend menu [list command \
						-command [namespace code [list SortColumn $path $id reverse]] \
						-labelvar [namespace current]::mc::ReverseOrder \
					]
					lappend menu [list command \
						-command [namespace code [list SortColumn $path $id cancel]] \
						-labelvar [namespace current]::mc::CancelSort \
					]
					lappend menu { separator }
				}
			}
		}

		if {$Vars(mode) eq "merge" && $id eq "number"} {
			lassign {{} {} {}} ivar fvar tvar
		} else {
			set sid [string toupper $id 0 0]
			set ivar [namespace current]::icon::12x12::I_$sid
			set fvar [namespace current]::mc::F_$sid
			set tvar [namespace current]::mc::T_$sid
			if {![info exists $tvar]} { set tvar {} }
			if {![info exists $fvar]} { set fvar $tvar }
			if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }
		}

		if {$id in $visibleColumns} { set visible 1 } else { set visible 0 }

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
		lappend opts -checkbutton $checkbutton

		if {$group eq "white"} {
			set name [string range $sid 5 end]
			if {[string length $name] == 0} { set name Name }
			lappend opts -nameingroup [namespace current]::mc::P_$name
			lappend opts -associated black[string range $id 5 end]
			lappend opts -groupvar [namespace current]::mc::G_Player
			set group player
		} elseif {$group eq "black"} {
			set group {}
		}

		if {[llength $group]} {
			lappend opts -groupvar [namespace current]::mc::G_[string toupper $group 0 0]
		}

		lappend columns $id $opts
		lappend Vars(columns) $id
		incr index
	}

	set Vars(table) [::scrolledtable::build $path $columns {*}$args]
	pack $path -fill both -expand yes
	::font::registerFigurineFonts movelist
	set specialfont [list [list $::font::figurine(movelist:normal) 9812 9823]]
	::scrolledtable::configure $path material -specialfont $specialfont
	::scrolledtable::configure $path position -specialfont $specialfont
	::scrolledtable::configure $path moveList -specialfont $specialfont
	RefreshEventType $path

	::bind $path <<TableFill>>			[namespace code [list TableFill $path %d]]
	::bind $path <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $path <<TableInvoked>>		[namespace code [list TableInvoked $path %d]]
	::bind $path <<TableVisit>>		[namespace code [list TableVisit $path %d]]
	::bind $path <<TableHide>>			[namespace code [list TableHide $path %d 1]]
	::bind $path <<TableShow>>			[namespace code [list TableHide $path %d 0]]
	::bind $path <Destroy>				[namespace code [list PrepareImages $path -2]]

	bind $path <ButtonPress-2>			[namespace code [list ShowGame $path %x %y]]
	bind $path <ButtonRelease-2>		[namespace code [list hideGame $path]]
	bind $path <ButtonPress-3>			+[namespace code [list hideGame $path]]

	BindAccelerators $path
	::bind $path <<LanguageChanged>>  [namespace code [list BindAccelerators $path]]
	::bind $path <<LanguageChanged>> +[namespace code [list RefreshHeader $path 1]]
	::bind $path <<LanguageChanged>> +[namespace code [list RefreshHeader $path 2]]

	set specialfont [list [list $::font::figurine(text:normal) 9812 9823]]
	foreach col {white black event} {
		::scrolledtable::configure $path $col -specialfont $specialfont
	}

	if {[::scrolledtable::visible? $path moveList]} {
		::scidb::app::moveList open $path [namespace current]::FetchMoveList
	}

	set Vars(ranges) {}
	set Vars(viewcmd) $getViewCmd

	trace add variable [namespace current]::mc::P_Rating1 write [namespace current]::SetupRating
	SetupRating

	return $Vars(table)
}


proc init {path base variant} {
}


proc tablePath {path} {
	return [::scrolledtable::tablePath $path]
}


proc forget {path base variant} {
	::scrolledtable::forget $path $base $variant
}


proc columnIndex {name} {
	variable columns
	return [lsearch -exact $columns $name]
}


proc column {info name} {
	variable columns
	return [lindex $info [lsearch -exact $columns $name]]
}


proc base {path} {
	return [::scrolledtable::base $path]
}


proc clear {path} {
	::scrolledtable::clear $path
}


proc clearColumn {path id} {
	::scrolledtable::clearColumn $path $id
}


proc keepFocus {path {flag {}}} {
	::scrolledtable::keepFocus $path $flag
}


proc fill {path first last} {
	::scrolledtable::fill $path $first $last
}


proc update {path base variant size} {
	::scrolledtable::update $path $base $variant $size
}


proc changeLayout {path dir} {
	return [::scrolledtable::changeLayout $path $dir]
}


proc overhang {path} {
	return [::scrolledtable::overhang $path]
}


proc linespace {path} {
	return [::scrolledtable::linespace $path]
}


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path]
}


proc identify {path x y} {
	return [::scrolledtable::identify $path $x $y]
}


proc setState {path row state} {
	::scrolledtable::setState $path $row $state
}


proc see {path position} {
	::scrolledtable::see $path $position
}


proc scroll {path position} {
	::scrolledtable::scroll $path $position
}


proc scrolldistance {path y} {
	return [::scrolledtable::scrolldistance $path $y]
}


proc doSelection {path} {
	::scrolledtable::doSelection $path
}


proc activate {path row} {
	::scrolledtable::activate $path $row
}


proc select {path row} {
	::scrolledtable::select $path $row
}


proc selection {path} {
	return [::table::selection $path.top.table]
}


proc index {path} {
	return [::scrolledtable::index $path]
}


proc indexToRow {path index} {
	return [::scrolledtable::indexToRow $path $index]
}


proc at {path y} {
	return [::scrolledtable::at $path $y]
}


proc focus {path} {
	::scrolledtable::focus $path
}


proc bind {path sequence script} {
	::scrolledtable::bind $path $sequence $script
}


proc showGame {path base variant view index {pos {}}} {
	set info [::scidb::db::get gameInfo $index $view $base $variant]
	set length [lindex $info [columnIndex length]]
	set result [lindex $info [columnIndex result]]
#	set result [::util::formatResult $result]
	if {$result eq "1/2-1/2"} { set result "1/2" }
	set moves [lindex [::scidb::game::dump $base $variant $view $index $pos] 1]
	showMoves $path $moves -result $result -showEmpty [expr {$length == 0}]
}


proc hideGame {path} { hideMoves $path }


proc showMoves {path moves args} {
	array set opts { -result "" -showEmpty 1 -width 50 }
	array set opts $args

	set w $path.showmoves
	if {![winfo exists $w]} {
		set f [::util::makePopup $w]
		set bg [$f cget -background]
		tk::text $f.text \
			-wrap word \
			-width 50 \
			-height 8 \
			-background [::tooltip::background] \
			-borderwidth 0 \
			-relief solid \
			-cursor {} \
			;
		pack $f.text -padx 1 -pady 1
      $f.text tag configure figurine -font $::font::figurine(text:normal)
		# NOTE: w/o this dirty trick -displaylines will not work.
		::shadow::prevent $w
		wm geometry $w +[winfo screenwidth $w]+[winfo screenheight $w]
		catch { wm attributes $w -type tooltip }
		catch { wm attributes $w -topmost }
		wm deiconify $w
		lower $w
		wm withdraw $w
		::update idletasks
		::shadow::allow $w
	}
	set t $w.f.text
	$t configure -width $opts(-width) -state normal
	$t delete 1.0 end
	set moves [::font::splitMoves $moves]
	set complete 1
	if {[string length $moves] == 0} {
		if {$opts(-showEmpty)} { set text $mc::NoMoves } else { set text $mc::NoMoreMoves }
		$t insert end $text
		set needSpace 1
	} else {
		set i 0
		foreach {move tag} $moves {
			$t insert end $move $tag
			if {[incr i] == 300} {
				set complete 0
				break
			}
		}
		set needSpace 0
	}
	if {$complete && [string length $opts(-result)]} {
		if {$needSpace} { $t insert end " " }
		$t insert end $opts(-result)
	}
	::update idletasks
	set lines [min 20 [$t count -displaylines 1.0 8.0]]
	if {$lines == 1} {
		lassign [$t bbox 1.end-1c] x0 y0 w0 h0
		set width [expr {$x0 + $w0}]
		set charwidth [font measure [$t cget -font] "0"]
		$t configure -width [expr {($width + $charwidth - 1)/$charwidth}]
	}
	$t configure -height $lines -state disabled
	::tooltip::disable
	::tooltip::popup $path $w cursor
}


proc hideMoves {path} {
	::tooltip::popdown $path.showmoves
	::tooltip::enable
}


proc deleteGame {base variant index {view -1}} {
	::widget::busyCursor on
	set flag [expr {![::scidb::db::get deleted? $index $view $base $variant]}]
	::scidb::db::set delete $index $view $base $variant $flag
	::widget::busyCursor off
}


proc addGameFlagsMenuEntry {menu base variant view index} {
	variable Columns
	variable _Flags

	set item     [lsearch -exact -index 0 $Columns flags]
	set myFlags  [lindex [::scidb::db::get gameInfo $index $view $base $variant] $item]
	set allFlags [::scidb::db::get gameFlags $base $variant]

	foreach flag $allFlags { set _Flags($flag) 0 }
	foreach flag $myFlags  { set _Flags($flag) 1 }

	menu $menu.gameflags
	foreach flag $allFlags {
		if {[info exist ::icon::12x12::gameflag($flag)]} {
			set img $::icon::12x12::gameflag($flag)
		} else {
			set img $::icon::12x12::none
		}
		switch $flag {
			1 - 2 - 3 - 4 - 5 - 6 {
				set text [lindex [::scidb::db::get customFlags $base $variant] [expr {$flag - 1}]]
				if {[string length $text] == 0} { set text $mc::Custom }
			}

			default { set text $mc::GameFlags($flag) }
		}
		if {$flag == 1} {
			$menu.gameflags add separator
		}
		$menu.gameflags add checkbutton \
			-label " $text" \
			-image $img \
			-compound left \
			-variable [namespace current]::_Flags($flag) \
			-command [namespace code [list SetFlag $base $variant $index $view $flag]]
			;
		::theme::configureCheckEntry $menu.gameflags
	}

	$menu add cascade \
		-compound left \
		-image $::icon::16x16::flag \
		-label " $mc::EditGameFlags" \
		-menu $menu.gameflags
		;
}


proc TableSelected {path index} {
	variable ${path}::Vars

	if {$index < 0} { return }

	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	# XXX index == -1 should not happen
	set info [::scidb::db::get gameInfo $index $view $base $variant]
	set number [expr {[column $info number] - 1}]
	set fen {}
	if {[llength $Vars(positioncmd)]} { set fen [{*}$Vars(positioncmd)] }

	if {[llength $Vars(selectcmd)]} {
		{*}$Vars(selectcmd) $base $variant $number $fen
	} else {
		::widget::busyOperation {
			::game::new $path \
				-base $base \
				-variant $variant \
				-view $view \
				-number $number \
				-fen $fen \
				;
		}
	}
}


proc TableInvoked {path shiftIsHeldDown} {
	if {!$shiftIsHeldDown} {
		::application::switchTab board
	}
}


proc Refresh {path} {
	variable ${path}::Vars

	set Vars(ranges) {}
	if {[::scidb::app::moveList open? $path]} { ::scidb::app::moveList clear $path }
	::scrolledtable::refresh $path
}


proc RefreshEventType {path} {
	variable ${path}::Options

	set justification [expr {$Options(eventtype-icon) ? "center" : "left"}]
	::scrolledtable::clearColumn $path eventType
	::scrolledtable::setColumnJustification $path eventType $justification
	Refresh $path
}


proc RefreshHeader {path number} {
	variable ${path}::Options

	set rt $Options(rating:$number)
	if {[info exists mc::RatingType($rt)]} { set rt $mc::RatingType($rt) }

	set mc::F_WhiteFideID "$::playertable::mc::F_FideID \u26aa"
	set mc::F_BlackFideID "$::playertable::mc::F_FideID \u26ab"

	set mc::T_WhiteFideID "$::playertable::mc::F_FideID - $::mc::White"
	set mc::T_BlackFideID "$::playertable::mc::F_FideID - $::mc::Black"

	set mc::F_WhiteRating$number "$rt \u26aa"
	set mc::F_BlackRating$number "$rt \u26ab"

	set mc::T_WhiteRating$number "$mc::WhiteRating: $rt"
	set mc::T_BlackRating$number "$mc::BlackRating: $rt"
}


proc RefreshRatings {path number} {
	RefreshHeader $path $number
	::scrolledtable::refresh $path
}


proc RefreshCountries {path} {
	::scrolledtable::clear $path
	::scrolledtable::refresh $path
}


proc RefreshImages {path} {
	variable ${path}::Vars

	PrepareImages $path -1
	::scrolledtable::refresh $path
}


proc PrepareImages {path count} {
	variable ${path}::Vars
	variable ${path}::Options

	if {[llength $Vars(table)] == 0} { return }

	if {$count < 0} {
		foreach image $Vars(pool) { image delete $image }
		set Vars(pool) {}
		if {[llength $Vars(crosshand)]} {
			image delete $Vars(crosshand)
			set Vars(crosshand) {}
		}
		if {$count == -2} { set Vars(table) {} }
		return
	}

	if {$Options(relief)} { set type dark } else { set type lite }
	if {$Options(monochrome)} {
		set colors {#000000 #000000 #000000}
	} else {
		set colors {#ff0000 #00ff00 #0000ff}
	}
	set s [expr {($Vars(acvsize) - 6)/3}]
	foreach k {0 1 2} {
		set Vars(area:$k) [list [expr {$k*$s + 2 + $k}] 2 [expr {($k + 1)*$s + 2 + $k}] [expr {$s + 2}]]
	}
	set width $Vars(acvsize)
	set height [expr {$s + 4}]
	set border [image create photo -width $width -height $height]
	scidb::tk::image border $border -width 1 -type $type

	if {!$Options(transparent) && [llength $Vars(crosshand)] == 0} {
		set Vars(crosshand) [image create photo -width $width -height $height]
		::scidb::tk::image recolor white $Vars(crosshand) -composite set
		$Vars(crosshand) copy $border
		foreach k {0 1 2} {
			::scidb::tk::image recolor [lindex $colors $k] $Vars(crosshand) \
				-area {*}$Vars(area:$k) \
				-composite set
		}
	}

	set pool {}
	while {[incr count -1] >= 0} {
		set image [image create photo -width $width -height $height]
		lappend Vars(pool) $image
		lappend pool $image
		if {$Options(transparent)} {
			$image copy $border
			foreach k {0 1 2} {
				::scidb::tk::image recolor [lindex $colors $k] $image \
					-area {*}$Vars(area:$k) \
					-composite set
			}
		}
	}

	image delete $border
	return $pool
}


proc TableFill {path args} {
	variable icon::12x12::CrossHandRed
	variable icon::12x12::Modified
	variable icon::12x12::Added
	variable icon::12x12::Check
	variable icon::12x12::NotAvailable
	variable GameFlags
	variable ${path}::Vars
	variable ${path}::Options

	lassign [lindex $args 0] table base variant start first last columns

	set codec [::scidb::db::get codec $base $variant]
	set used [::table::used $table acv]
	set view [{*}$Vars(viewcmd) $base $variant]

	if {![::scidb::view::open? games $base $variant $view]} {
		# may happen due to pending updates
		return [clear $path]
	}

	set last [expr {min($last, [scidb::view::count games $base $variant $view] - $start)}]
	set ratings [list $Options(rating:1) $Options(rating:2)]
	set gray [::scrolledtable::visible? $path deleted]
	set delIdx [columnIndex deleted]

	set unused {}
	foreach elem $Vars(pool) {
		if {$elem ni $used} { lappend unused $elem }
	}
	if {[llength $unused] < $last - $first} {
		lappend unused {*}[PrepareImages $path [expr {$last - $first - [llength $unused]}]]
	}

	for {set i $first; set count 0} {$i < $last} {incr i; incr count} {
		set index [expr {$start + $i}]
		set line [::scidb::db::get gameInfo $index $view $base $variant \
			-ratings $ratings -notation $Options(move:notation)]
		set deleted !
		set text {}
		set k 0

		if {$codec eq "sci" && $Options(showIDN)} {
			if {[llength [lindex $line $Vars(eco-index)]] == 0 && [lindex $line $Vars(idn-index)] != 0} {
				lset line $Vars(eco-index) [lindex $line $Vars(idn-index)]
			}
		}

		if {!$gray && [lindex $line $delIdx]} { set deleted {} }

		foreach id $columns {
			if {[::table::visible? $table $id]} {
				set item [lindex $line $k]
				
				switch $id {
					acv {
						if {$codec eq "cbf"} {
							lappend text $::mc::NotAvailableSign
						} else {
							if {$Options(transparent)} {
								set image [lindex $unused $count]
							} else {
								set image $Vars(crosshand)
							}
							set usage 0
							foreach j {0 1 2} {
								if {[lindex $item $j] == 0} {
									::scidb::tk::image alpha 0 $image -area {*}$Vars(area:$j)
								} else {
									set a [expr {([lindex $item $j]*17)/255.0}]
#									set a [expr {sqrt([lindex $item $j]*4335)/255.0}]
									::scidb::tk::image alpha $a $image -area {*}$Vars(area:$j)
									incr usage
								}
							}
							if {$usage} {
								if {!$Options(transparent)} {
									set image [lindex $unused $count]
									::scidb::tk::image recolor white $image -composite set
									$image copy $Vars(crosshand)
								}
								lappend text [list @ $image]
							} else {
								lappend text [list @ {}]
							}
						}
					}

					eventMode {
						if {[string length $item] == 0} {
							lappend text [list @ $::icon::12x12::none]
						} else {
							lappend text [list @ [set ::eventmodebox::icon::12x12::$item]]
						}
					}

					timeMode {
						if {[string length $item] == 0} {
							lappend text [list @ $::icon::12x12::none]
						} else {
							lappend text [list @ $::timemodebox::icon::12x12::Mode($item)]
						}
					}

					termination {
						if {$codec ne "sci"} {
							lappend text $::mc::NotAvailableSign
						} elseif {[string length $item]} {
							lappend text [list @ [set ::terminationbox::icon::12x12::$item]]
						} else {
							lappend text {@ {}}
						}
					}

					allFlag - engFlag - othFlag {
						if {$codec eq "sci"} {
							if {$item} {
								# TODO: only for 12pt; use U+2716 (or U+2718) for other sizes
								# TODO: or use icon font
								set image $Check
							} else {
								set image {}
							}
							lappend text [list @ $image]
						} else {
							lappend text [list @ $NotAvailable]
						}
					}

					deleted {
						# TODO: only for 12pt; use U+2716 (or U+2718) for other sizes
						# TODO: or use icon font
						if {$item} { set image $CrossHandRed } else { set image {} }
						lappend text [list @ $image]
					}

					changed {
						if {$item} { set image $Modified } else { set image {} }
						lappend text [list @ $image]
					}

					added {
						if {$item} { set image $Added } else { set image {} }
						lappend text [list @ $image]
					}

					promotion - underPromo {
						if {[string match cb? $codec]} {
							lappend text [list @ $NotAvailable]
						} else {
							# TODO: only for 12pt; use U+2714 for other sizes
							# TODO: or use icon font
							if {$item} { set image $Check } else { set image {} }
							lappend text [list @ $image]
						}
					}

					standardPos - chess960Pos - added {
						# TODO: only for 12pt; use U+2714 for other sizes
						# TODO: or use icon font
						if {$item} { set image $Check } else { set image {} }
						lappend text [list @ $image]
					}

					idn {
						if {$codec eq "sci"} {
							if {$item} {
								lappend text $item
								set idn $item
							} else {
								lappend text ""
								set idn ""
							}
						} else {
							lappend text $::mc::NotAvailableSign
							set idn ""
						}
					}

					eco {
						if {[string length $item]} {
							lappend text $item
						} elseif {$Options(showIDN) && $idn} {
							lappend text $idn
						} else {
							lappend text ""
						}
					}

					position {
						if {$codec eq "sci"} {
							if {[string match wild* $item]} {
								lappend text $item
							} else {
								lappend text [lindex [split $item /] 1]
							}
						} else {
							lappend text $::mc::NotAvailableSign
						}
					}

					whiteFideID - blackFideID {
						if {[string index $item 0] eq "-"} {
							lappend text "[string range $item 1 end]*"
						} else {
							lappend text "$item "
						}
					}

					whiteRating1 - blackRating1 - whiteRating2 - blackRating2 {
						if {$item == 0} {
							lappend text {}
						} elseif {$item < 0} {
							lappend text [format "(%4d)" [abs $item]]
						} else {
							lappend text [format " %4d " $item]
						}
					}

					whiteRatingType - blackRatingType {
						if {$Options(exclude-elo) && $item eq "Elo"} {
							lappend text {}
						} else {
							lappend text $item
						}
					}

					whiteCountry - blackCountry - eventCountry {
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

					annotator {
						if {$codec eq "sci" || $codec eq "cbh"} {
							lappend text $item
						} else {
							lappend text $::mc::NotAvailableSign
						}
					}

					round {
						if {$item eq "?"} {
							lappend text ""
						} elseif {[string compare -length 1 $item "0"] == 0} {
							lappend text [string range $item 1 end]
						} else {
							lappend text $item
						}
					}

					result {
						lappend text [::util::formatResult $item]
					}

					number {
						set number $item
						lappend text [string trim $item]
					}

					flags {
						if {$codec eq "cbf"} {
							lappend text $::mc::NotAvailableSign
						} elseif {[llength $item]} {
							if {![info exist GameFlags($item)]} {
								set n [llength $item]
								set width [expr {$n*12 + ($n ? ($n - 1)*2 : 0)}]
								set img [image create photo -width $width -height 12]
								set GameFlags($item) $img
								set x 0

								foreach flag $item {
									$img copy $::icon::12x12::gameflag($flag) -to $x 0
									incr x 14
								}
							}
							lappend text [list @ $GameFlags($item)]
						} else {
							lappend text [list @ {}]
						}
					}

					material {
						if {[string match cb? $codec]} {
							lappend text $::mc::NotAvailableSign
						} else {
							lappend text [::font::translate [string map {: " - "} $item]]
						}
					}

					key {
						if {[string match cb? $codec]} {
							lappend text $::mc::NotAvailableSign
						} else {
							lappend text $item
						}
					}

					opening {
						lassign $item op(0) op(1) var(0) var(1)
						set value [::mc::translateEco $op($Options(opening-index))]
						if {$Options(opening-variations) &&
							([string length $var(0)] || [string length $var(1)])} {
							set comma ": "
							if {[string length $var(0)]} { append value $comma $var(0); set comma ", " }
							if {[string length $var(1)]} { append value $comma $var(1) }
						}
						lappend text $value
					}

					variation - subvariation {
						lappend text [::mc::translateEco $item]
					}

					whiteType - blackType {
						if {[string length $item]} {
							lappend text [list @ [set ::icon::12x12::$item]]
						} else {
							lappend text [list @ {}]
						}
						set $id $item
					}

					whiteSex {
						switch $item {
							m { set icon $::icon::12x12::male }
							f { set icon $::icon::12x12::female }

							default {
								if {$Options(include-type) && $whiteType eq "program"} {
									set icon $::icon::12x12::program
								} else {
									set icon {}
								}
							}
						}
						lappend text [list @ $icon]
					}

					blackSex {
						switch $item {
							m { set icon $::icon::12x12::male }
							f { set icon $::icon::12x12::female }

							default {
								if {$Options(include-type) && $blackType eq "program"} {
									set icon $::icon::12x12::program
								} else {
									set icon {}
								}
							}
						}
						lappend text [list @ $icon]
					}

					eventType {
						if {$codec eq "si3" || $codec eq "si4"} {
							lappend text $::mc::NotAvailableSign
						} elseif {[string length $item]} {
							if {$Options(eventtype-icon)} {
								lappend text [list @ $::eventtypebox::icon::12x12::Type($item)]
							} else {
								lappend text $mc::EventType($item)
							}
						} else {
							lappend text {}
						}
					}

					white - black - event - site {
						if {[string length $item] == 0} {
							lappend text "-"
						} else {
							lappend text $item
						}
					}

					default {
						lappend text $item
					}
				}
			} else {
				switch $id {
					whiteType - blackType - idn { set $id [lindex $line $k] }
				}
				lappend text {}
			}

			incr k
		}

		::table::insert $table $i $text
		::table::setState $table $i ${deleted}deleted
	}

	if {$first < $last && [::scidb::app::moveList open? $path]} {
		FetchMoveList $path

		set first [expr {$first + $start}]
		set last [expr {$last + $start}]
		set end [::scrolledtable::lastRow $path]

		lappend Vars(ranges) [list $first $last]
		set opts {}
		if {[llength $Vars(positioncmd)]} { set opts [list -fen [{*}$Vars(positioncmd)]] }
		::scidb::app::moveList retrieve $path $base $variant $view $start $end $first $last \
			-length 40 -notation $Options(move:notation) {*}$opts
	}
}


proc FetchMoveList {path} {
	variable ${path}::Vars
	variable ${path}::Options

	set firstRow [::scrolledtable::firstRow $path]
	set lastRow [::scrolledtable::lastRow $path]
	set nextStart -1
	set nextEnd -1
	set ranges {}

	foreach range $Vars(ranges) {
		lassign $range lower upper

		set lower [expr {max($lower, $firstRow)}]
		set upper [expr {min($upper, $lastRow)}]

		for {} {$lower < $upper} {incr lower} {
			if {[string length [set moves [::scidb::app::moveList fetch $path $lower]]]} {
				if {$moves == "*"} {
					set moves $mc::NoMoves
				} else {
					set moves [::figurines::mapToLocal $moves $Options(move:figurines)]
				}
				::table::setElement $Vars(table) [expr {$lower - $firstRow}] moveList $moves
			} elseif {$nextStart == -1} {
				set nextStart $lower
				set nextEnd [expr {$lower + 1}]
			} elseif {$nextEnd == $lower} {
				set nextEnd [expr {$lower + 1}]
			} else {
				lappend ranges [list $nextStart $nextEnd]
				set nextStart $lower
				set nextEnd [expr {$lower + 1}]
			}
		}
	}

	if {$nextStart >= 0} {
		lappend ranges [list $nextStart $nextEnd]
	}

	set Vars(ranges) $ranges
}


proc TableHide {table id flag} {
	variable ${table}::Vars

	if {$id eq "moveList"} {
		if {$flag} {
			::scidb::app::moveList close $table
		} else {
			::scidb::app::moveList open $table [namespace current]::FetchMoveList
			::scrolledtable::refresh $table
		}
	} elseif {$id eq "deleted"} {
		::scrolledtable::refresh $table
	}
}


proc TableVisit {table data} {
	variable ${table}::Vars
	variable ${table}::Options
	variable ratings

	lassign $data base variant mode id row
	if {[string length $base] == 0} { return }
	if {$row == -1} { return }
	set codec [::scidb::db::get codec $base $variant]

	switch $id {
		acv - key - opening { if {[string match cb? $codec]} { return } }
		idn - termination { if {$codec ne "sci"} { return } }
		eventType { if {[string match si? $codec]} { return } }
		eco - eventMode - timeMode - flags {}
		whiteType - blackType - whiteTitle - blackTitle - whiteCountry - blackCountry - eventCountry {}
		whiteSex - blackSex { if {!$Options(include-type)} { return } }
		whiteRating1 - blackRating1 { if {$Options(rating:1) ne [lindex $ratings end]} { return } }
		whiteRating2 - blackRating2 { if {$Options(rating:2) ne [lindex $ratings end]} { return } }
		deleted - changed - added {}
		default { return }
	}

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	switch $id {
		whiteSex								{ set col [lsearch -exact $Vars(columns) whiteType] }
		blackSex								{ set col [lsearch -exact $Vars(columns) blackType] }
		whiteRating1 - whiteRating2	{ set col [lsearch -exact $Vars(columns) whiteRatingType] }
		blackRating1 - blackRating2	{ set col [lsearch -exact $Vars(columns) blackRatingType] }
		default								{ set col [lsearch -exact $Vars(columns) $id] }
	}

	set view 	[{*}$Vars(viewcmd) $base $variant]
	set index	[::scrolledtable::rowToIndex $table $row]
	set item 	[::scidb::db::get gameInfo $index $view $base $variant $col]
	set font  	[::tooltip::font]
	set tip		""

	if {[string length $item] == 0} { return }

	switch $id {
		acv {
			variable Count

			set tip ""
			lassign $item a c v m
			if {$a || $c || $v} {
				if {$a} { set count [lindex $Count $a] } else { set count "\uff0d" }
				append tip "$mc::T_Annotations: $count\n"
				if {$c} { set count [lindex $Count $c] } else { set count "\uff0d" }
				append tip "$mc::T_Comments: $count\n"
				if {$v} { set count [lindex $Count $v] } else { set count "\uff0d" }
				append tip "$mc::T_Variations: $count"
			}
		}

		eco {
			if {$variant eq "Normal"} {
				set lines [::browser::makeOpeningLines $item]
				if {[string length [lindex $lines 1 0]]} {
					if {!$Options(showIDN)} { return }
					set tip [lindex $lines 1 0]
					set font ::font::figurine(small:normal)
				} else {
					set tip [string range [lindex $lines 0 0] 6 end]
				}
			}
		}

		flags {
			set tip ""
			foreach flag $item {
				if {[string length $tip]} { append tip "\n" }
				switch $flag {
					1 - 2 - 3 - 4 - 5 - 6 {
						set text [lindex [::scidb::db::get customFlags $base $variant] [expr {$flag - 1}]]
						if {[string length $text] == 0} {
							set text "$mc::Custom $flag"
						}
						append tip $text
					}

					default { append tip $mc::GameFlags($flag) }
				}
			}
		}

		key {
			if {$variant eq "Normal"} {
				set lines [::browser::makeOpeningLines $item]
				if {[string length [lindex $lines 1 0]]} { return }
				set tip [string range [lindex $lines 0 0] 6 end]
			}
		}

		overview {
			if {$variant eq "Normal"} {
				set lines [::browser::makeOpeningLines $item]
				set tip [lindex $lines 0 0]
				set idx [string last " (" $tip]
				if {$idx > 0} { set tip [string range $tip 0 [expr {$idx - 1}]] }
			}
		}

		opening {
			if {$Options(opening-index) == 1} { return }
			set tip [::mc::translateEco [lindex $item 4]]
		}

		whiteCountry - blackCountry - eventCountry {
			set tip [::country::name $item]
		}

		whiteType - blackType {
			set tip $mc::PlayerType($item)
		}

		whiteSex - blackSex {
			if {$item eq "program"} {
				set tip $::gametable::mc::PlayerType(program)
			} else {
				set tip ""
			}
		}

		whiteTitle - blackTitle {
			set tip $::titlebox::mc::Title($item)
		}

		whiteRating1 - blackRating1 - whiteRating2 - blackRating2 {
			set tip $item
		}

		idn {
			set font ::font::figurine(small:normal)
			set tip $item
		}

		eventMode {
			set tip [set ::eventmodebox::mc::$item]
		}

		timeMode {
			set tip $::timemodebox::mc::Mode($item)
		}

		termination {
			set tip [set ::terminationbox::mc::$item]
		}

		eventType {
			set tip $::eventtypebox::mc::Type($item)
		}

		deleted {
			if {$item} { set tip [set [namespace current]::mc::T_Deleted] }
		}

		changed {
			if {$item} { set tip [set [namespace current]::mc::T_Changed] }
		}

		added {
			if {$item} { set tip [set [namespace current]::mc::T_Added] }
		}
	}

	if {[string length $tip]} { ::tooltip::show $table $tip cursor $font }
}


proc SortColumn {path id dir {rating {}}} {
	variable ${path}::Vars
	variable ${path}::Options

	::widget::busyCursor on
	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	if {[string length $rating]} {
		set ratings [list $rating $rating]
	} else {
		set ratings [list $Options(rating:1) $Options(rating:2)]
	}
	set options {}
	set see 0
	set selection [::scrolledtable::selection $path]
	if {$selection >= 0} {
		set number [expr {[lindex [scidb::db::get gameInfo $selection $view $base $variant] 0] - 1}]
		if {[::scrolledtable::selectionIsVisible? $path]} { set see 1 }
	}
	switch $dir {
		reverse {
			::scidb::db::reverse gameInfo $base $variant $view
		}
		cancel {
			set columnNo [::scrolledtable::columnNo $path number]
			::scidb::db::sort gameInfo $base $variant $columnNo $view -ascending
		}
		default {
			set columnNo [::scrolledtable::columnNo $path $id]
			::scidb::db::sort gameInfo $base $variant $columnNo $view -$dir -ratings $ratings
		}
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get gameIndex $number $view $base $variant]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $path $selection $see
}


proc ShowGame {path x y} {
	variable ${path}::Vars

	set index [::scrolledtable::at $path $y]
	if {![string is digit $index]} { return }
	::scrolledtable::focus $path
	set row [::scrolledtable::indexToRow $path $index]
	activate $path $row
	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	if {[llength $Vars(positioncmd)]} { set pos [{*}$Vars(positioncmd)] } else { set pos {} }
	showGame $path $base $variant $view $index $pos
}


proc PopupMenu {path menu base variant index} {
	variable ${path}::Vars
	variable _Flags
	variable columns
	variable ratings
	variable Columns

	if {$index eq "none"} { return }
	if {[string length $base] == 0} { return }

	set view [{*}$Vars(viewcmd) $base $variant]
	if {[scidb::view::count games $base $variant $view] == 0} { return }
	set Vars(menu) $menu

	if {$index ne "outside"} {
		if {$Vars(mode) eq "list"} {
			$menu add command \
				-compound left \
				-image $::icon::16x16::browse \
				-label " $::browser::mc::BrowseGame..." \
				-command [namespace code [list Open(browse) $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::overview \
				-label " $::overview::mc::Overview..." \
				-command [namespace code [list Open(overview) $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::document \
				-label " $::browser::mc::LoadGame" \
				-command [namespace code [list LoadGame $path $index]] \
				;
			if {$Vars(mode) ne "merge"} {
				if {[::scidb::game::current] < 9} { set state normal } else { set state disabled }
				set position [list $base $variant $view $index]
				if {[::merge::alreadyMerged [::scidb::game::current] $position]} { set state disabled }
				$menu add command \
					-compound left \
					-image $::icon::16x16::merge \
					-label " $::browser::mc::MergeGame..." \
					-command [list gamebar::mergeGame $path $position] \
					-state $state \
					;
				$menu add command \
					-compound left \
					-image $::icon::16x16::crossTable \
					-label " $mc::ShowTournamentTable..." \
					-command [namespace code [list Open(tourntable) $path $index]] \
					;
			}
		} else {
			$menu add command \
				-compound left \
				-image $::icon::16x16::filetypeScidbBase \
				-label " $::browser::mc::BrowseGame..." \
				-accelerator $mc::Accel(browse) \
				-command [namespace code [list Open(browse) $path $index]] \
				;
			set cmd [namespace code [list InvokeAction $menu browse $path $index]]
			::bind $menu <Key-$mc::Accel(browse)> $cmd
			::bind $menu <Key-[string tolower $mc::Accel(browse)]> $cmd
			$menu add command \
				-compound left \
				-image $::icon::16x16::overview \
				-label " $::overview::mc::Overview..." \
				-accelerator $mc::Accel(overview) \
				-command [namespace code [list Open(overview) $path $index]] \
				;
			set cmd [namespace code [list InvokeAction $menu overview $path $index]]
			::bind $menu <Key-$mc::Accel(overview)> $cmd
			::bind $menu <Key-[string tolower $mc::Accel(overview)]> $cmd
			$menu add command \
				-compound left \
				-image $::icon::16x16::document \
				-label " $::browser::mc::LoadGame" \
				-accelerator $mc::Space \
				-command [namespace code [list LoadGame $path $index]] \
				;
			::bind $menu <Key-space> [namespace code [list InvokeAction $menu load $path $index]]
			if {$Vars(mode) ne "merge"} {
				if {[::scidb::game::current] < 9} { set state normal } else { set state disabled }
				set position [list $base $variant $view $index]
				if {[::merge::alreadyMerged [::scidb::game::current] $position]} { set state disabled }
				$menu add command \
					-compound left \
					-image $::icon::16x16::merge \
					-label " $::browser::mc::MergeGame..." \
					-command [list gamebar::mergeGame $path [list $base $variant $view $index]] \
					-state $state \
					;
				$menu add command \
					-compound left \
					-image $::icon::16x16::crossTable \
					-label " $mc::ShowTournamentTable..." \
					-accelerator $mc::Accel(tourntable) \
					-command [namespace code [list Open(tourntable) $path $index]] \
					;
				set cmd [namespace code [list InvokeAction $menu tourntable $path $index]]
				::bind $menu <Key-$mc::Accel(tourntable)> $cmd
				::bind $menu <Key-[string tolower $mc::Accel(tourntable)]> $cmd
			}
		}

		if {!$Vars(sortable)} { return }

		if {![::scidb::db::get readonly? $base $variant]} {
			$menu add separator
			set flag [::scidb::db::get deleted? $index $view $base $variant]

			if {$flag} { set text $mc::UndeleteGame } else { set text $mc::DeleteGame }
			$menu add command \
				-compound left \
				-image $::icon::16x16::remove \
				-label " $text" \
				-command [namespace code [list deleteGame $base $variant $index $view]] \
				;

			addGameFlagsMenuEntry $menu $base $variant $view $index

			set info [::scidb::db::get gameInfo $index $view $base $variant]
			$menu add command \
				-compound left \
				-image $::icon::16x16::setup \
				-label " $::dialog::save::mc::EditCharacteristics..." \
				-command [list ::dialog::save::open $path $base $variant {} [column $info number]] \
				;
		}

		$menu add separator
	}

	if {!$Vars(sortable)} { return }

	$menu add command \
		-label $mc::SortOnAverageElo \
		-command [namespace code [list SortColumn $path whiteRating1 average Elo]] \
		;
	$menu add command \
		-label $mc::SortOnDate \
		-command [namespace code [list SortColumn $path date descending]] \
		;
	$menu add command \
		-label $mc::SortOnNumber \
		-command [namespace code [list SortColumn $path number ascending]] \
		;

	set visibleColumns [::scrolledtable::visibleColumns $path]
	set groups {}
	foreach entry $Columns {
		if {[set id [lindex $entry 0]] in $visibleColumns} {
			set group [lindex $entry 1]
			if {![info exists use($group)]} { set use($group) 0 } else { incr use($group) }
		}
	}

	foreach dir {ascending descending} {
		menu $menu.$dir
		$menu add cascade \
			-label [set [namespace current]::mc::Sort[string toupper $dir 0 0]] \
			-menu $menu.$dir \
			;
	}

	foreach id $visibleColumns {
		switch $id {
			whiteRating2 - blackRating2 {}

			whiteRating1 - blackRating1 {
				set group [string range $id 0 4]
				foreach dir {ascending descending} {
					menu $menu.$dir.$group.rating
					foreach rating $ratings {
						$menu.$dir.$group.rating add command \
							-label $rating \
							-command [namespace code [list SortColumn $path $id $dir $rating]] \
							;
					}
					$menu.$dir.$group add cascade -label $mc::P_Rating -menu $menu.$dir.$group.rating
				}
			}

			default {
				foreach dir {ascending descending} {
					set m $menu.$dir
					set k [columnIndex $id]
					set group [lindex $Columns $k 1]
					if {[llength $group] && $use($group)} {
						if {![winfo exists $m.$group]} {
							menu $m.$group
							switch $group {
								white		{ set var ::mc::White }
								black		{ set var ::mc::Black }
								default	{ set var [namespace current]::mc::G_[string toupper $group 0 0] }
							}
							$m add cascade -label [set $var] -menu $m.$group
						}
						append m .$group
					}
					if {$group in {white black}} {
						set name [string range $id 5 end]
						if {[string length $name] == 0} { set name Name }
						set var [namespace current]::mc::P_$name
					} else {
						set idl [string toupper $id 0 0]
						set fvar [namespace current]::mc::F_$idl
						set fvar [namespace current]::mc::F_$idl
						set tvar [namespace current]::mc::T_$idl
						if {[info exists $tvar]} { set var $tvar } else { set var $fvar }
						set text [set $var]
					}
					set text [set $var]
					if {$group in {white black} && !$use($group)} {
						append text " - [set mc::[string toupper $group 0 0]]"
					}
					$m add command \
						-label $text \
						-command [namespace code [list SortColumn $path $id $dir]] \
						;
				}
			}
		}
	}
}


proc SetFlag {base variant index view flag} {
	variable _Flags
	::scidb::db::set flag $index $view $base $variant $flag $_Flags($flag)
}


proc BindAccelerators {path} {
	variable ${path}::Vars

	foreach action {browse overview tourntable} {
		if {[info exists Vars(accel:$action)]} {
			bind $path <Key-[string toupper $Vars(accel:$action)]> {}
			bind $path <Key-[string tolower $Vars(accel:$action)]> {}
		}
		set cmd [namespace code [list Open($action) $path]]
		set accel $mc::Accel($action)
		bind $path <Key-[string toupper $accel]> [list ::util::doAccelCmd $accel %s $cmd]
		bind $path <Key-[string tolower $accel]> [list ::util::doAccelCmd $accel %s $cmd]
		set Vars(accel:$action) $accel
	}
}


proc LoadGame {path index} {
	::scrolledtable::select $path [::scrolledtable::indexToRow $path $index]
	TableSelected $path $index
}


proc InvokeAction {m action path index} {
	::tk::MenuUnpost $m
	Open($action) $path $index
}


proc Open(load) {path index} {
	LoadGame $path $index
}


proc Open(browse) {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	set info [::scidb::db::get gameInfo $index $view $base $variant]
	set topl [winfo toplevel $path]

	::widget::busyOperation \
		{ ::browser::open $topl $base $variant $info $view $index [{*}$Vars(positioncmd)] }
}


proc Open(overview) {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	set info [::scidb::db::get gameInfo $index $view $base $variant]

	::widget::busyOperation \
		{ ::overview::open $path $base $variant $info $view $index [{*}$Vars(positioncmd)] }
}


proc Open(tourntable) {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]

	::crosstable::open $path $base $variant $index $view game
}


proc SetupRating {args} {
	set mc::P_Rating1 $mc::P_Rating
	set mc::P_Rating2 $mc::P_Rating
}


proc SelectFigurines {path} {
	variable ${path}::Options

	set lang [::figurines::openDialog $path $Options(move:figurines)]
	if {$lang eq $Options(move:figurines)} { return }
	set Options(move:figurines) $lang
	Refresh $path
}


proc UpdateMoveStyleLabel {args} {
	set [namespace current]::MoveStyle "$::pgn::setup::mc::Setup(MoveStyle)..."
}


namespace eval icon {
namespace eval 12x12 {

set CrossHandBlack [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAClSURB
	VBgZBcHLKoQBAIDR80pjhYXZzI8x5VZYiEIuiyFloygLl42VJI9AXvJzDngKAD4DHPXTfQC3
	/TUPo9776Lvr4KyvPvptFHZ77KG3DtvspYeemwfYbN5Vd91202sHAWDWacedddIQABgaWmqp
	oSEArLbRSmutt9JGqwHW227SVguN2mrSTtOw3HnT9loMFttv2kWzMOmycQDjLpsEGAcAN8E/
	sb1yJ55STrUAAAAASUVORK5CYII=
}]

set CrossHandRed $::icon::12x12::deleted
set Added $::icon::12x12::plus
set Check $::icon::12x12::check
set Modified $::icon::12x12::edit

set NotAvailable [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAA3WAAAN1gGQb3mcAAAAB3RJTUUH2QsXETQFlV93TwAAALlJREFUKM/dzsFtwkAQ
	BdC/u2NbhohYQpBbIpQLlaQLblRBARSVGiggxyA4gBUnsMHa9Swz5pYewqvgAf+feVgsYa0d
	vM5mb+XosVKiXqyDqkJSgnBnovfn4373rkBLRVkiM2Y8eX5ZF9OneShKafMCgRPirwf/fDvn
	6GPYfG06kZYAwBgDFsU5MpreIfQOiRkSOygnDK/yV6IuBIi1zWH7ubrWdZUo63Mi5ACQGIjR
	aHs5+RAaxX24Add6WXPsiMrcAAAAAElFTkSuQmCC
}]

set I_WhiteType [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAAAAABzHgM7AAAAAmJLR0QAAKqNIzIAAAB8SURB
	VAjXY2AAgvg7D2vZGCBA6uKvD4/MoByd++8+fAmGyZz58OOjDZTDMvv737PiUA6D7/s/NVAm
	k3Lnl59LDFhBbKHW619//frxcKY8kBP04/ev30DwNx/IKf8LBn/+zwBxPvz5/+/f/3+fZgB1
	CQf07b5w+cjcKGkGAJMiPt3t8QrBAAAAAElFTkSuQmCC
}]

set I_BlackType [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAEESURB
	VBjTY2AAAj0gTk1OfKzz3rzFhc2aAQ4sGAxlkq+l/Ff9b/LW2sIGIaHFoKWv/kb+v8p/0z+2
	obYICXkGeRn524r/rf+Hfo61jUFIKDOIsBgsMf7v8z/3XLV4OUKCA2iYRpDRb5//4fU2DNNg
	wjwMLEzSaroTbP66/zdao2AsySoHEnZl8BYK69J7ZPzP93/gf8v/eq81F6oqqjMweDA4hqX9
	Dv4f9D/kf/B/v//u/23/GxU7MDC4M5hW+f9v+l//v/p/1f+S/5lAfY6zgUbFMRjUOv4o+lfz
	vxYIa/4X/Xf6bTRfgpVBjUFGVDXMa0r6gfzLBddyjocs0kyUknNhAACyuV8yGfi7+AAAAABJ
	RU5ErkJggg==
}]

#set I_WhiteCountry [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAD4SURB
#	VBgZXcG9S0JRGMDh37nneD8kLUgwI4SKar9jS9AQOEVLWw3R2NY/0tbaUrPNgeAe9LHWYBl9
#	WF0QxGv3es4bNfo8yvM2463pRuwvp/ed5vbrDk3+qGh+//JobSnyzU+WXL+fPrUKur4x6hkb
#	Viu1ksKj4JfX/bja9bxo7uXYGMo4HIJjjITBikYNBl2j0VgEECwWQdA5QzNmhEUAwTEGFJ4W
#	3+QkDMV2076rZbNWCRBExQUT8qDPb+p7xV5lceow2g1mIBuiTMCb6nzfPpazk6/kbvWi1NCh
#	u/poGbAI4HMAGW3a/DPKpc5ahAlGffbP5JmcCb8Rc2Crz4bcwwAAAABJRU5ErkJggg==
#}]
#
#set I_BlackCountry [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAEBSURB
#	VBgZXcG9SsNQAIDR7yY3bdrE1pa6VBQRRNRNFwdBpHVy8jl8BN+jDyCuBRd/QCg4dNFF3IRW
#	KEq1CFWa5GqSm0TURTxHrDn1jaXiylZ+enTVvVj0WvwSy83No6Yz59rG2H+47Ld6d7OV+s5L
#	R8alQtXOx0iEW923GgtPU+W8GF5LEATYGCh8dMlaNVD3z68SYnwKCBQ+EZCQfISRTFEEOBgo
#	AkK+GZYwZUbAOIwGBR3Oe24ECJxKuSYF7+bNsTxMk5l160A2TFuAMqWEmNFjfdhh7/ytW93N
#	bU+89KR3K1NSMqGpcQoT2rT5YaSJyrT2+M8s6jAXn30ONIq/vgDFEWFUXuvtkgAAAABJRU5E
#	rkJggg==
#}]

set I_EngFlag $::country::icon::flag(GBR)
set I_OthFlag $::country::icon::flag(ZZX)

set I_WhiteTitle  [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAD8SURB
	VBjTZY89SwIBAIbf6job1MBAyMo+QNAMIRoOHJqcm2wrvCKJqPsB/YD6BbUFiRDREDTJIdHY
	1GBQk1tlEgVRDUp2Pg2HLT3P9PJMryRJMmXEx6/Drkb0jznrNVXXxN+eVzI+um4saypyOVye
	TsbWAgU/xyLVHFbHvJBj7M7UlrrZ7mBVY5JttZ95oej1l6JXR7R4YKGlFWlrsfMBPJL7cbw2
	8I71rU0pE6qfAfDEGwAnBO+VlqSN9NcdPWqkPrUqqU8ydZrngD32OSSPzjUkydTAZPAmi80O
	DgUsArdK+FfshHdMBReXCiVm0bYfikYz1OgZbphNOdIvWHF8FbpJ9lwAAAAASUVORK5CYII=
}]

set I_BlackTitle  [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAD7SURB
	VBjTZY8xSwJhAIYfT87TQynTL6k4oUOuwSEQDIrASZeO1HI4w6E1Cvot/YCmFmkoaAkCt8bG
	CELyBzQKQWH5NlgtPc/08E4vAGBj58xt6g7DP7yF0fyI4l9XWC/4B+4+S07fuSivlrqZHp4F
	VjZzuTw1E+uGXuLI3Be/FqfWAA925sah2gqm8XP3qqKOWjLvHMJe9q2trlpamfifHUXqqDDh
	GIrxh6oiRWqqpUiRanKeKAM0068NdX8MlR/TsyBGMsaZp21tqKpNlcQ1ScAmYZxBTr4CBfJl
	FH9kbXYlTH9sqa66Gqqrprw4nQ271nNq+Ks7tF84gW+b6GMJEmdX5QAAAABJRU5ErkJggg==
}]

set I_Deleted $CrossHandBlack
set I_WhiteSex $::icon::12x12::yinyang

set I_BlackSex [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAEeSURB
	VBgZBcEvTAJhHIDh94BxcPzb3X0H4gAZKM5NIBiAosU53dRNo8Gmbk5nQLPJIGOShE2abDRn
	UQMGgwYDzWJ0BjMGtDh+Pg9QoOyJLzst68X3HnhwtgvBNAIpJnVVVc3YmfGlCeL6CbSTygKw
	9+x6PuG/45xThog2CjbLPhIzVicdzyW9r8yS4RNB3N/OJs6BqkIx5O/xTI8/BEGCXcyavWYA
	sZLx6BloIwRB9D5mzVo3qAMVI1UMN1xDBNH7qH37GHaBqWg2vuQ1rhEk1CU5bXZSiTS/hFvh
	mzeXdaiJexDdAJwdq5ExQS1EV4Za6MIl4ct5HwVKunNktWOr6dx43jzRP0JXeTUBkKfiHltU
	TfM+8hS5VVtzRhbhH74kTeb3wl4nAAAAAElFTkSuQmCC
}]

set I_TimeMode $::terminationbox::icon::12x12::TimeForfeit
set I_Changed [::icon::makeGrayscale $Modified 0.7]
set I_Added [::icon::makeGrayscale $Added 0.8]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace gametable

# vi:set ts=3 sw=3:
