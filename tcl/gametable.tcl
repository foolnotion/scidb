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
# Copyright: (C) 2009-2012 Gregor Cramer
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
set SortOnNumber			"Sort on game number (asscending)"
set ReverseOrder			"Reverse order"
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

set AccelBrowse			"W"
set AccelOverview			"O"
set AccelTournTable		"T"
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
set F_EventDate			"Event Date"
set F_EventType			"Ev.Type"
set F_Changed				"Changed"
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
set T_EngFlag				"English Language Flag"
set T_OthFlag				"Other Language Flag"
set T_Idn					"Chess 960 Position Number"
set T_Annotations			"Annotations"
set T_Comments				"Comments"
set T_Variations			"Variations"
set T_TimeMode				"Time Mode"

set P_RatingScore			"Score"
set P_RatingType			"Rating Type"
set P_Country				"Country"
set P_Title					"Title"
set P_Type					"Type"
set P_Mode					"Mode"
set P_Date					"Date"
set P_Sex					"Sex"
set P_Name					"Name"

set G_White					"White"
set G_Black					"Black"
set G_Event					"Event"

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
	{ number				{}			right		 4		 9		 6			0			1			1			{}				}
	{ white				white		left		10		 0		18			1			0			1			darkblue		}
	{ whiteFideID		white		right		 0		 0		10			0			1			1			{}				}
	{ whiteRating1		white		center	 0		 0		 6			0			1			1			darkgreen	}
	{ whiteRating2		white		center	 0		 0		 6			0			1			1			darkgreen	}
	{ whiteRatingType	white		left		 0		 0		 7			0			1			0			darkgreen	}
	{ whiteCountry		white		center	 0		 0		 5			0			1			0			darkgreen	}
	{ whiteTitle		white		left		 0		 0		 5			0			1			1			darkred		}
	{ whiteType			white		center	 0		 0		14px		0			1			0			{}				}
	{ whiteSex			white		center	 0		 0		14px		0			1			0			{}				}
	{ black				black		left		10		 0		18			1			0			1			darkblue		}
	{ blackFideID		black		right		 0		 0		10			0			1			1			{}				}
	{ blackRating1		black		center	 0		 0		 6			0			1			1			darkgreen	}
	{ blackRating2		black		center	 0		 0		 6			0			1			1			darkgreen	}
	{ blackRatingType	black		left		 0		 0		 7			0			1			0			darkgreen	}
	{ blackCountry		black		center	 0		 0		 5			0			1			0			darkgreen	}
	{ blackTitle		black		left		 0		 0		 5			0			1			1			darkred		}
	{ blackType			black		center	 0		 0		14px		0			1			0			{}				}
	{ blackSex			black		center	 0		 0		14px		0			1			0			{}				}
	{ event				event		left		10		 0		18			1			1			1			{}				}
	{ eventType			event		left		 2		 8		 6			0			1			0			{}				}
	{ eventDate			event		left		 5		10		10			0			1			0			darkred		}
	{ result				{}			center	 5		 5		 5			0			1			1			blue			}
	{ eventCountry		event		center	 0		 0		 5			0			1			0			{}				}
	{ site				event		left		10		 0		16			1			1			1			{}				}
	{ date				{}			left		 5		10		10			0			1			0			darkred		}
	{ round				{}			right		 2		 0		 5			0			1			1			{}				}
	{ annotator			{}			left		10		 0		10			0			1			1			darkred		}
	{ idn					{}			right		 0		 0		 5			0			1			1			#68480a		}
	{ position			{}			left		 0		 0		13			0			1			1			#68480a		}
	{ length				{}			right		 3		 5		 4			0			1			1			{}				}
	{ eco					{}			left		 4		 5		 4			0			1			0			darkgreen	}
	{ flags				{}			left		 2		 0		54px		0			1			0			{}				}
	{ material			{}			left		 8		 0		25			0			1			1			{}				}
	{ deleted			{}			center	 0		 0		14px		0			1			0			red			}
	{ acv					{}			center	 0		 0		30px		0			1			0			{}				}
	{ engFlag			{}			center	 0		 0		18px		0			1			0			black			}
	{ othFlag			{}			center	 0		 0		18px		0			1			0			black			}
	{ changed			{}			center	 0		 0		14px		0			1			0			{}				}
	{ promotion			{}			center	 0		 0		14px		0			1			0			{}				}
	{ underPromo		{}			center	 0		 0		14px		0			1			0			{}				}
	{ standardPos		{}			center	 0		 0		14px		0			1			0			{}				}
	{ chess960Pos		{}			center	 0		 0		14px		0			1			0			{}				}
	{ termination		{}			center	 0		 0		14px		0			1			0			{}				}
	{ eventMode			event		center	 0		 0		14px		0			1			1			{}				}
	{ timeMode			event		center	 0		 0		14px		0			1			1			{}				}
	{ overview			{}			left		10		 0		10			0			1			1			{}				}
	{ opening			{}			left		10		 0		10			1			1			1			{}				}
	{ variation			{}			left		10		 0		10			1			1			1			{}				}
	{ subvariation		{}			left		10		 0		10			1			1			1			{}				}
	{ key					{}			left		 4		 9		 9			0			1			0			magenta4		}
}
# alternative colors: darkgoldenrod

variable Count { "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10-12" "13-17" "18-24" "25-34" "35-44" "45+" }

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Defaults {
	monochrome		0
	showIDN			0
	relief			0
	transparent		0
	opening-index	1
	exclude-elo		1
	include-type	0
	country-code	flags
	eventtype-icon	1
	rating:1			Elo
	rating:2			DWZ
}

array set GameFlags {}

variable ratings {Elo DWZ ECF IPS USCF ICCF Rapid Rating Any}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable Columns
	variable Defaults
	variable ratings

	namespace eval [namespace current]::$path {}
	variable [namespace current]::${path}::Vars
	variable [namespace current]::${path}::Options

	array set Vars {
		deleted		1
		listmode		0
		pool			{}
		crosshand	{}
		columns		{}
		positioncmd	{}
	}

	if {[array size Options] < [array size Defaults]} {
		array set Options [array get Defaults]
	}

	RefreshHeader $path 1
	RefreshHeader $path 2

	set columns {}
	set index 0
	foreach column $Columns {
		lassign $column id group adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		switch $id {
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
						-variable [namespace current]::Defaults(rating:$number) \
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
		}

		switch $id {
			variation - subvariation - key {}

			opening {
				foreach {labelvar value} {Long 0 Short 1} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar [namespace current]::mc::$labelvar \
						-variable [namespace current]::${path}::Options(opening-index) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			default {
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
				lappend menu { separator }
			}
		}

		set ivar [namespace current]::icon::12x12::I_[string toupper $id 0 0]
		set fvar [namespace current]::mc::F_[string toupper $id 0 0]
		set tvar [namespace current]::mc::T_[string toupper $id 0 0]
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }
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

		if {[llength $group]} {
			lappend opts -groupvar [namespace current]::mc::G_[string toupper $group 0 0]
		}

		lappend columns $id $opts
		lappend Vars(columns) $id
		incr index
	}

	array set options $args
	if {[info exists options(-positioncmd)]} {
		set Vars(positioncmd) $options(-positioncmd)
		unset options(-positioncmd)
		set args [array get options]
	}
	if {[info exists options(-listmode)]} {
		set Vars(listmode) $options(-listmode)
	}
	lappend args -popupcmd [namespace code PopupMenu]
	set Vars(table) [::scrolledtable::build $path $columns {*}$args]
	::scrolledtable::configure $path material -font2 $::font::figurine
	::scrolledtable::configure $path position -font2 $::font::figurine
	::scrolledtable::configure $path overview -font2 $::font::figurine
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
	set Vars(viewcmd) $getViewCmd

	return $Vars(table)
}


proc init {path base} {
}


proc tablePath {path} {
	return [::scrolledtable::tablePath $path]
}


proc forget {path base} {
	::scrolledtable::forget $path $base
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


proc update {path base size} {
	::scrolledtable::update $path $base $size
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


proc getOptions {path} {
	variable ${path}::Options

	set options [::scrolledtable::getOptions $path]
	lappend options {*}[array get Options]
	return $options
}


proc setOptions {path options} {
	namespace eval [namespace current]::$path {}

	variable ${path}::Options
	variable Defaults

	array set myOptions $options
	array set Options [array get Defaults]

	foreach key [array names Defaults] {
		if {[info exists myOptions($key)]} {
			set Options($key) $myOptions($key)
			array unset myOptions $key
		}
	}

	::scrolledtable::setOptions $path [array get myOptions]
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


proc showGame {path base view index {pos {}}} {
	set info [::scidb::db::get gameInfo $index $view $base]
	set length [lindex $info [columnIndex length]]
	set result [lindex $info [columnIndex result]]
#	set result [::util::formatResult $result]
	if {$result eq "1/2-1/2"} { set result "1/2" }
	set moves [lindex [::scidb::game::dump $base $view $index $pos] 1]
	showMoves $path $moves $result [expr {$length == 0}]
}


proc hideGame {path} { hideMoves $path }


proc showMoves {path moves result showEmpty {width 50}} {
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
      $f.text tag configure figurine -font $::font::figurine
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
	$t configure -width $width -state normal
	$t delete 1.0 end
	set moves [::font::splitMoves $moves]
	set complete 1
	if {[string length $moves] == 0} {
		if {$showEmpty} { set text $mc::NoMoves } else { set text $mc::NoMoreMoves }
		$t insert end $text
		$t insert end " "
	} else {
		set i 0
		foreach {move tag} $moves {
			$t insert end $move $tag
			if {[incr i] == 300} {
				set complete 0
				break
			}
		}
	}
	if {$complete} { $t insert end $result }
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


proc TableSelected {path index} {
	variable ${path}::Vars

	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]
	set info [::scidb::db::get gameInfo $index $view $base]
	set fen  {}

	if {[llength $Vars(positioncmd)]} { set fen [{*}$Vars(positioncmd)] }

	set pos [::widget::busyOperation \
					::game::new $path $base [expr {[column $info number] - 1}] $fen]
}


proc TableInvoked {path index} {
	::application::switchTab board
}


proc Refresh {path} {
	::scrolledtable::refresh $path
}


proc RefreshEventType {path} {
	variable ${path}::Options

	if {$Options(eventtype-icon)} {
		set justification center
	} else {
		set justification left
	}

	::scrolledtable::clearColumn $path eventType
	::scrolledtable::setColumnJustification $path eventType $justification
	Refresh $path
}


proc RefreshHeader {path number} {
	variable Defaults

	set rt $Defaults(rating:$number)
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
	variable icon::12x12::Check
	variable icon::12x12::NotAvailable
	variable GameFlags
	variable Defaults
	variable ${path}::Vars
	variable ${path}::Options

	lassign [lindex $args 0] table base start first last columns

	set codec [::scidb::db::get codec $base]
	set used [::table::used $table acv]
	set view [{*}$Vars(viewcmd) $base]
	set last [expr {min($last, [scidb::view::count games $base $view] - $start)}]
	set ratings [list $Defaults(rating:1) $Defaults(rating:2)]
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
		set line [::scidb::db::get gameInfo $index $view $base -ratings $ratings]
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
#								set a [expr {sqrt([lindex $item $j]*4335)/255.0}]
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
							lappend text $::mc::NotAvailableSign]
						} elseif {[string length $item]} {
							lappend text [list @ [set ::terminationbox::icon::12x12::$item]]
						} else {
							lappend text {@ {}}
						}
					}

					engFlag - othFlag {
						if {$codec eq "sci"} {
							if {$item} {
								# TODO: only for 12pt; use U+2716 (or U+2718) for other sizes
								set image $Check
							} else {
								set image {}
							}
							lappend text [list @ $image]
						} else {
							lappend text [list @ $NotAvailable]
						}
					}

					deleted - changed {
						# TODO: only for 12pt; use U+2716 (or U+2718) for other sizes
						if {$item} { set image $CrossHandRed } else { set image {} }
						lappend text [list @ $image]
					}

					promotion - underPromo {
						if {$codec eq "cbh"} {
							lappend text [list @ $NotAvailable]
						} else {
							# TODO: only for 12pt; use U+2714 for other sizes
							if {$item} { set image $Check } else { set image {} }
							lappend text [list @ $image]
						}
					}

					standardPos - chess960Pos {
						# TODO: only for 12pt; use U+2714 for other sizes
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
							lappend text $item
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
						if {[llength $item]} {
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
						if {$codec eq "cbh"} {
							lappend text $::mc::NotAvailableSign
						} else {
							lappend text [::font::translate [string map {: " - "} $item]]
						}
					}

					key {
						if {$codec eq "cbh"} {
							lappend text $::mc::NotAvailableSign
						} else {
							lappend text $item
						}
					}

					opening {
						lappend text [::mc::translateEco [lindex $item $Options(opening-index)]]
					}

					variation - subvariation {
						lappend text [::mc::translateEco $item]
					}

					overview {
						if {$codec eq "cbh"} {
							lappend text $::mc::NotAvailableSign
						} else {
							lappend text [::font::translate $item]
						}
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

					wgite - black - event - site {
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
				lappend text ""
			}

			incr k
		}

		::table::insert $table $i $text
		::table::setState $table $i ${deleted}deleted
	}
}


proc TableHide {table id flag} {
	variable ${table}::Vars

	if {$id eq "deleted"} {
		::scrolledtable::refresh $table
	}
}


proc TableVisit {table data} {
	variable ${table}::Vars
	variable ${table}::Options
	variable Defaults
	variable ratings

	lassign $data base mode id row
	set codec [::scidb::db::get codec $base]

	switch $id {
		acv - key - overview - opening { if {$codec eq "cbh"} { return } }
		idn - termination - position { if {$codec ne "sci"} { return } }
		eventType { if {[string match si? $codec]} { return } }
		eco - eventMode - timeMode - flags {}
		whiteType - blackType - whiteTitle - blackTitle - whiteCountry - blackCountry - eventCountry {}
		whiteSex - blackSex { if {!$Options(include-type)} { return } }
		whiteRating1 - blackRating1 { if {$Defaults(rating:1) ne [lindex $ratings end]} { return } }
		whiteRating2 - blackRating2 { if {$Defaults(rating:2) ne [lindex $ratings end]} { return } }
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

	set view  [{*}$Vars(viewcmd) $base]
	set index [::scrolledtable::rowToIndex $table $row]
	set item  [::scidb::db::get gameInfo $index $view $base $col]
	set font  [::tooltip::font]

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
			set lines [::browser::makeOpeningLines $item]
			if {[string length [lindex $lines 1 0]]} {
				if {!$Options(showIDN)} { return }
				set tip [lindex $lines 1 0]
				set font ::font::figurineSmall
			} else {
				set tip [string range [lindex $lines 0 0] 6 end]
			}
		}

		flags {
			set tip ""
			foreach flag $item {
				if {[string length $tip]} { append tip "\n" }
				switch $flag {
					1 - 2 - 3 - 4 - 5 - 6 {
						set text [lindex [::scidb::db::get customFlags $base] [expr {$flag - 1}]]
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
			set lines [::browser::makeOpeningLines $item]
			if {[string length [lindex $lines 1 0]]} { return }
			set tip [string range [lindex $lines 0 0] 6 end]
		}

		overview {
			set lines [::browser::makeOpeningLines $item]
			set tip [lindex $lines 0 0]
			set idx [string last " (" $tip]
			if {$idx > 0} { set tip [string range $tip 0 [expr {$idx - 1}]] }
		}

		opening {
			if {$Options(opening-index) == 0} { return }
			set tip [::mc::translateEco [lindex $item 3 0]]
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
			set font ::font::figurineSmall
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
	}

	if {[string length $tip]} { ::tooltip::show $table $tip cursor $font }
}


proc SortColumn {path id dir {rating {}}} {
	variable ${path}::Vars
	variable Defaults
	variable Columns

	::widget::busyCursor on
	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]
	if {[string length $rating]} {
		set ratings [list $rating $rating]
	} else {
		set ratings [list $Defaults(rating:1) $Defaults(rating:2)]
	}
	set options {}
	set see 0
	set selection [::scrolledtable::selection $path]
	if {$selection >= 0} {
		set number [expr {[lindex [scidb::db::get gameInfo $selection $view $base] 0] - 1}]
		if {[::scrolledtable::selectionIsVisible? $path]} { set see 1 }
	}
	switch $dir {
		reverse {
			::scidb::db::reverse gameInfo $base $view
		}

		default {
			switch $dir {
				descending	{ lappend options -descending }
				average		{ lappend options -average }
			}

			set columnNo [::scrolledtable::columnNo $path $id]
			lappend options -ratings $ratings
			::scidb::db::sort gameInfo $base $columnNo $view {*}$options
		}
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get gameIndex $number $view $base]
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
	set view [{*}$Vars(viewcmd) $base]
	if {[llength $Vars(positioncmd)]} {
		set pos [{*}$Vars(positioncmd)]
	} else {
		set pos {}
	}
	showGame $path $base $view $index $pos
}


proc PopupMenu {path menu base index} {
	variable ${path}::Vars
	variable _Flags
	variable columns
	variable ratings
	variable Columns

	if {$index eq "none"} { return }

	set view [{*}$Vars(viewcmd) $base]
	if {[scidb::view::count games $base $view] == 0} { return }

	if {$index ne "outside"} {
		if {$Vars(listmode)} {
			$menu add command \
				-compound left \
				-image $::icon::16x16::browse \
				-label " $::browser::mc::BrowseGame" \
				-command [namespace code [list OpenBrowser $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::overview \
				-label " $::overview::mc::Overview" \
				-command [namespace code [list OpenOverview $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::document \
				-label " $::browser::mc::LoadGame" \
				-command [namespace code [list LoadGame $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::crossTable \
				-label " $mc::ShowTournamentTable" \
				-command [namespace code [list OpenCrosstable $path $index]] \
				;
		} else {
			$menu add command \
				-compound left \
				-image $::icon::16x16::filetypeScidbBase \
				-label " $::browser::mc::BrowseGame" \
				-accelerator $mc::AccelBrowse \
				-command [namespace code [list OpenBrowser $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::overview \
				-label " $::overview::mc::Overview" \
				-accelerator $mc::AccelOverview \
				-command [namespace code [list OpenOverview $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::document \
				-label " $::browser::mc::LoadGame" \
				-accelerator $mc::Space \
				-command [namespace code [list LoadGame $path $index]] \
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::crossTable \
				-label " $mc::ShowTournamentTable" \
				-accelerator $mc::AccelTournTable \
				-command [namespace code [list OpenCrosstable $path $index]] \
				;
		}
	
		if {![::scidb::db::get readonly? $base]} {
			$menu add separator
			set flag [::scidb::db::get deleted? $index $view $base]

			if {$flag} { set text $mc::UndeleteGame } else { set text $mc::DeleteGame }
			$menu add command \
				-compound left \
				-image $::icon::16x16::remove \
				-label " $text" \
				-command [namespace code [list DeleteGame $base $index $view [expr {!$flag}]]] \
				;

			set item  [::scidb::db::get gameInfo $index $view $base [lsearch -exact $Vars(columns) flags]]
			set flags [::scidb::db::get gameFlags $base]

			foreach flag $flags	{ set _Flags($flag) 0 }
			foreach flag $item	{ set _Flags($flag) 1 }

			menu $menu.gameflags
			foreach flag $flags {
				if {[info exist ::icon::12x12::gameflag($flag)]} {
					set img $::icon::12x12::gameflag($flag)
				} else {
					set img $::icon::12x12::none
				}
				switch $flag {
					1 - 2 - 3 - 4 - 5 - 6 {
						set text [lindex [::scidb::db::get customFlags $base] [expr {$flag - 1}]]
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
					-command [namespace code [list SetFlag $base $index $view $flag]]
					;
			}

			set info [::scidb::db::get gameInfo $index $view $base]

			$menu add cascade \
				-compound left \
				-image $::icon::16x16::flag \
				-label " $mc::EditGameFlags" \
				-menu $menu.gameflags
				;
			$menu add command \
				-compound left \
				-image $::icon::16x16::setup \
				-label " $::dialog::save::mc::EditCharacteristics" \
				-command [list ::dialog::save::open $path $base {} [column $info number]] \
				;
		}

		$menu add separator
	}

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
		-command [namespace code [list SortColumn $path number asscending]] \
		;

	set groups {}
	foreach entry $Columns {
		set name [lindex $entry 1]
		if {[string length $name]} {
			set k [lsearch $groups $name]
			if {$k == -1} { lappend groups $name }
		}
	}

	foreach dir {ascending descending} {
		menu $menu.$dir
		$menu add cascade \
			-label [set [namespace current]::mc::Sort[string toupper $dir 0 0]] \
			-menu $menu.$dir \
			;
		foreach group $groups {
			menu $menu.$dir.$group
			$menu.$dir add cascade \
				-label [set [namespace current]::mc::G_[string toupper $group 0 0]] \
				-menu $menu.$dir.$group \
				;
		}
	}

	foreach id $columns {
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
					if {[llength $group]} { append m .$group }
					set idl [string toupper $id 0 0]
					set fvar [namespace current]::mc::F_$idl
					set fvar [namespace current]::mc::F_$idl
					set tvar [namespace current]::mc::T_$idl
					if {[info exists $tvar]} { set var $tvar } else { set var $fvar }
					$m add command \
						-label [set $var] \
						-command [namespace code [list SortColumn $path $id $dir]] \
						;
				}
			}
		}
	}
}


proc DeleteGame {base index view value} {
	::widget::busyCursor on
	::scidb::db::set delete $index $view $base $value
	::widget::busyCursor off
}


proc SetFlag {base index view flag} {
	variable _Flags

	::scidb::db::set flag $index $view $base $flag $_Flags($flag)
}


proc BindAccelerators {path} {
	variable ${path}::Vars

	foreach {accel proc} [list $mc::AccelBrowse OpenBrowser \
										$mc::AccelOverview OpenOverview \
										$mc::AccelTournTable OpenCrosstable] {
#		if {[info exists Vars(accel:$proc)]} {
#			bind $path <Key-[string toupper $Vars(accel:$proc)]> {}
#			bind $path <Key-[string tolower $Vars(accel:$proc)]> {}
#		}
		set cmd [namespace code [list $proc $path]]
		bind $path <Key-[string toupper $accel]> [list ::util::doAccelCmd $accel %s $cmd]
		bind $path <Key-[string tolower $accel]> [list ::util::doAccelCmd $accel %s $cmd]
#		set Vars(accel:$proc) $accel
	}
}


proc LoadGame {path index} {
	::scrolledtable::select $path [::scrolledtable::indexToRow $path $index]
	TableSelected $path $index
}


proc OpenBrowser {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]
	set info [::scidb::db::get gameInfo $index $view $base]
	set topl [winfo toplevel $path]

	::widget::busyOperation ::browser::open $topl $base $info $view $index [{*}$Vars(positioncmd)]
}


proc OpenOverview {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]
	set info [::scidb::db::get gameInfo $index $view $base]

	::widget::busyOperation ::overview::open $path $base $info $view $index [{*}$Vars(positioncmd)]
}


proc OpenCrosstable {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]

	::crosstable::open $path $base $index $view game
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Defaults
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 12x12 {

set CrossHandBlack [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAClSURB
	VBgZBcHLKoQBAIDR80pjhYXZzI8x5VZYiEIuiyFloygLl42VJI9AXvJzDngKAD4DHPXTfQC3
	/TUPo9776Lvr4KyvPvptFHZ77KG3DtvspYeemwfYbN5Vd91202sHAWDWacedddIQABgaWmqp
	oSEArLbRSmutt9JGqwHW227SVguN2mrSTtOw3HnT9loMFttv2kWzMOmycQDjLpsEGAcAN8E/
	sb1yJ55STrUAAAAASUVORK5CYII=
}]

set CrossHandRed [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABFFBMVEWAAACoAACtAACHAACK
	AACRAACYAACcAACqAACAAACoAACvBAScAACHDg6OAABuAABtAABqAACiAACWKyt/HhaCJBvS
	eHXDSknJYF2dHxy/NCrFRz+kHxOkHxWkIRqkIx6lHhKmHhCrJBevJxuzMSazKx++Sj/DSkDI
	TEPKVkyAIyGBIyGhPjSyQzpqIx9qIyB7PDJZIRxbIRu9AAC+AAC/OTPBEQrCMzPCTUjDOjrF
	OTLGEgzHEgzJPj7LRD/LTkrMRkbQAADQEgzTVlbTV1TTZWDUYl7WYF3XY2HbExDbFBHfEw/f
	FBLfaGHjAADlLyrlMCzlMi3lMi7lc3HmbW3mdnXpjYnvFBLvFRPviYfwjYr1AABdSm1OAAAA
	AXRSTlMAQObYZgAAAIBJREFUCNcli9UWglAABOcbMDHB7kKxA7ADC5P//w/P9e7D7jzsAFH+
	CYuKfcpiSt84KCfvUYT63XsqkF8621pr7WwK4pCdTeeDxSon1cyoP+zpktFMo2tqkhO2NZ5Y
	dlJw6uDuOu29e0xD8Oy/GtB8+5cAqNeKOFRvqpiQVCPwA3nMEgZcj7r6AAAAAElFTkSuQmCC
}]

set Check [image create photo -data {
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

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace gametable

# vi:set ts=3 sw=3:
