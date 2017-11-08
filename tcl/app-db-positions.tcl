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
# Copyright: (C) 2014-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source start-position-list

namespace eval application {
namespace eval database {
namespace eval positions {
namespace eval mc {

set NoCastle		"No castle"

set F_Position		"Position"
set F_Description	"Description"
set F_BackRank		"Back Rank"
set F_Frequency	"Frequency"

} ;# namespace mc

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------
set Columns {
	{ position		right		 0		 0		 5			0			0			0			{}			}
	{ description	left		10		 0		18			1			1			1			darkblue	}
	{ backRank		left		 0		 0		13			0			1			0			{}			}
	{ frequency		right		 4		12		 9			0			0			1			{}			}
}

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

variable Tables {}

proc build {parent} {
	variable Tables
	variable Columns

	set top [tk::panedwindow $parent.top \
		-orient horizontal \
		-opaqueresize true \
		-borderwidth 0 \
	]
	pack $top -fill both -expand yes
	lappend Tables $top

	set lt ${top}.positions
	set rt ${top}.games

	set columns {}
	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		if {$id in {backRank frequency}} {
			lappend menu [list command \
				-command [namespace code [list positions::SortColumn $top $id ascending]] \
				-labelvar ::gametable::mc::SortAscending \
			]
			lappend menu [list command \
				-command [namespace code [list positions::SortColumn $top $id descending]] \
				-labelvar ::gametable::mc::SortDescending \
			]
			lappend menu [list command \
				-command [namespace code [list positions::SortColumn $top $id reverse]] \
				-labelvar ::gametable::mc::ReverseOrder \
			]
		}
		lappend menu [list command \
			-command [namespace code [list positions::SortColumn $top $id cancel]] \
			-labelvar ::gametable::mc::CancelSort \
		]

		set opts {}
		lappend opts -justify $adjustment
		lappend opts -minwidth $minwidth
		lappend opts -maxwidth $maxwidth
		lappend opts -width $width
		lappend opts -stretch $stretch
		lappend opts -removable $removable
		lappend opts -ellipsis $ellipsis
		lappend opts -foreground $color
		lappend opts -textvar [namespace current]::mc::F_[string toupper $id 0 0]
		lappend opts -menu $menu

		lappend columns $id $opts
	}

	set table [::scrolledtable::build $lt $columns]
	::scrolledtable::configure $lt backRank \
		-secondfont [list [list $::font::figurine(text:normal) 9812 9823]] \
		;
	::scrolledtable::bind $lt <ButtonPress-2> [namespace code [list ShowBoard $top %x %y]]
	::scrolledtable::bind $lt <ButtonRelease-2> [namespace code [list HideBoard $top]]

	namespace eval [namespace current]::$top {}
	variable [namespace current]::${top}::Vars
	set Vars(active) 0
	set Vars(base) ""

	set columns {white whiteElo black blackElo event result date length}
	::gametable::build $rt [namespace code [list View $top]] $columns -id db::positions

	::scidb::db::subscribe positionList [namespace current]::positions::Update $top
	::scidb::db::subscribe gameList [namespace current]::games::Update {} $top
	::scidb::db::subscribe dbInfo [namespace current]::NoOp [namespace current]::Close $top

	bind $lt <<TableMinSize>>		[namespace code [list TableMinSize $lt %d]]
	bind $lt <<TableFill>>			[namespace code [list positions::TableFill $top %d]]
	bind $lt <<TableOptions>>		[namespace code [list positions::TableOptions $top]]
	bind $lt <<TableSelected>>		[namespace code [list positions::TableSelected $top %d]]
	bind $lt <<LanguageChanged>>	[list ::scrolledtable::refresh $top.positions]

	$top add $lt -sticky nsew -stretch middle -width 420
	$top add $rt -sticky nsew -stretch always

	return $table
}


proc activate {w flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update:positions) 1
	positions::UpdateTable $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $path.positions $flag
	}
}


proc overhang {parent} {
	return [::scrolledtable::overhang $parent.top.positions]
}


proc linespace {parent} {
	return [::scrolledtable::linespace $parent.top.positions]
}


proc setActive {flag} {
	# no action
}


proc ShowBoard {path x y} {
	variable ${path}::Vars

	set table $path.positions
	set index [::scrolledtable::at $table $y]
	set base [::scrolledtable::base $table]
	set variant [::scrolledtable::variant $table]
	set view $Vars($base:$variant:view)
	set idn [lindex [scidb::db::get position $index $view] 0]

	activate [winfo parent $path] [::scrolledtable::indexToRow $table $index]
	::scrolledtable::focus $table
	if {$idn == 0} { return }

	set fen [lindex [::scidb::board::idnToFen $idn] 0]
	set board [::scidb::board::fenToBoard $fen]
	::browser::showPosition $path $board
}


proc HideBoard {path} {
	::browser::hidePosition $path
}


proc View {path base variant} {
	variable ${path}::Vars

	if {[string length $base] == 0} { return 0 }
	return $Vars($base:$variant:view)
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc InitBase {path base variant} {
	variable ${path}::Vars

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) \
			[::scidb::view::new $base $variant unused unused unused unused master slave]
		set Vars($base:$variant:update) 1
		set Vars($base:$variant:position) ""
		set Vars($base:$variant:after:games) {}
		set Vars($base:$variant:after:positions) {}
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:positions:lastId) -1
		set Vars($base:$variant:games:lastId) -1
		::scidb::view::search $base $variant $Vars($base:$variant:view) null none
	}
}


proc NoOp {args} {}


proc Close {path base variant} {
	variable ${path}::Vars

	#if {$action ne "close"} { return }

	array unset Vars $base:$variant:*
	::scrolledtable::forget $path.positions $base $variant
	::gametable::forget $path.games $base $variant
	if {$Vars(base) eq "$base:$variant"} { ::scrolledtable::clear $path.positions }
	if {$Vars(base) eq "$base:$variant"} { ::gametable::clear $path.games }
}


namespace eval games {

proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::clipbaseName
	variable [namespace parent]::${path}::Vars

	if {$base ne $clipbaseName && [string length [file extension $base]] == 0} { return }
	[namespace parent]::InitBase $path $base $variant

	if {$view == $Vars($base:$variant:view)} {
		after cancel $Vars($base:$variant:after:games)
		set Vars($base:$variant:after:games) \
			[after idle [namespace code [list Update2 $id $path $base $variant]]]
	}
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$id <= $Vars($base:$variant:games:lastId)} { return }

	set Vars($base:$variant:games:lastId) $id
	set lastChange $Vars($base:$variant:lastChange)
	set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
	set view $Vars($base:$variant:view)

	if {	[string is integer -strict $Vars($base:$variant:position)]
		&& $lastChange < $Vars($base:$variant:lastChange)} {
		set position [::scidb::db::find position $base $variant $Vars($base:$variant:position)]
		if {$position >= 0} {
			[namespace parent]::positions::TableSearch $path $base $variant $view
		} else {
			[namespace parent]::positions::Reset $path $base $variant
		}
	} else {
		set n [::scidb::view::count games $base $variant $view]
		after idle [list ::gametable::update $path.games $base $variant $n]
	}
}


proc TableOptions {path} {
	# TODO
}

} ;# namespace games

namespace eval positions {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::gametable::clear $path.games
	::scrolledtable::select $path.positions none
	::scrolledtable::activate none
	set Vars($base:$variant:position) ""
}


proc UpdateTable {path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {$Vars($base:$variant:update)} {
			set n [::scidb::db::count positions $base $variant]
			after idle [list ::scrolledtable::update $path.positions $base $variant $n]
			after idle [list [namespace parent]::games::Update2 \
				$Vars($base:$variant:positions:lastId) $path $base $variant]
			set Vars($base:$variant:update) 0
		}
	}
}


proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::clipbaseName
	variable [namespace parent]::${path}::Vars

	if {$base ne $clipbaseName && [string length [file extension $base]] == 0} { return }

	set Vars(base) "$base:$variant"
	[namespace parent]::InitBase $path $base $variant
	after cancel $Vars($base:$variant:after:positions)
	set Vars($base:$variant:after:positions) \
		[after idle [namespace code [list Update2 $id $path $base $variant]]]
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$id <= $Vars($base:$variant:positions:lastId)} { return }
	set Vars($base:$variant:positions:lastId) $id
	set Vars($base:$variant:update) 1
	UpdateTable $path $base $variant
}


proc TableOptions {path} {
	# TODO
}


proc TableFill {path args} {
	variable [namespace parent]::${path}::Vars

	lassign [lindex $args 0] table base variant start first last columns
	if {![info exists Vars($base:$variant:view)]} { return }
	set view $Vars($base:$variant:view)
	set last [expr {min($last, [scidb::view::count positions $base $variant $view] - $start)}]

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [scidb::db::get position $index $view]
		set text {}

		foreach id {position backRank frequency} value $line {
			switch $id {
				position {
					if {$value == 0} {
						set pos "FEN"
						set value ""
					} else {
						set pos $value
						if {$pos == 518} {
							set value $::setup::board::mc::StandardPosition
						} elseif {960 < $pos} {
							set pos [expr {$value - 960}]
							set value [set [namespace parent]::mc::NoCastle]
						} else {
							set value $::setup::board::mc::Chess960Castling
						}
					}
					lappend text $pos
				}

				frequency {
					set value [::locale::formatNumber $value]
				}
			}

			lappend text $value
		}

		::table::insert $table $i $text
	}
}


proc TableSelected {path index} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	set table $path.positions
	set base [::scrolledtable::base $table]
	set variant [::scrolledtable::variant $table]
	set view $Vars($base:$variant:view)
	set position [scidb::db::get position $index $view]
	set Vars($base:$variant:position) [lindex $position 0]
	TableSearch $path $base $variant $view
	::widget::busyCursor off
}


proc TableSearch {path base variant view} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $path.games none
	::gametable::select $path.games none
	::gametable::scroll $path.games home
	::scidb::view::search $base $variant $view null none [list position $Vars($base:$variant:position)]
	::widget::busyCursor off
}


proc SortColumn {path id dir} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	set table $path.positions
	set base [::scrolledtable::base $table]
	set variant [::scrolledtable::variant $table]
	set view $Vars($base:$variant:view)
	set see 0
	set selection [::scrolledtable::selection $table]
	if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $table]} { set see 1 }
	switch $dir {
		reverse {
			::scidb::db::reverse position $base $variant $view
		}
		cancel {
			set columnNo [::scrolledtable::columnNo $table position]
			::scidb::db::sort position $base $variant $columnNo $view -ascending -reset
		}
		ascending - descending {
			set columnNo [::scrolledtable::columnNo $table $id]
			::scidb::db::sort position $base $variant $columnNo $view -$dir
		}
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupPosition $selection $view $base $variant]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $table $selection $see
}

} ;# namespace positions

proc WriteOptions {chan} {
	variable Tables

	foreach table $Tables {
		foreach type {positions games} {
			puts $chan "::scrolledtable::setOptions db:positions {"
			::options::writeArray $chan [::scrolledtable::getOptions $table.$type]
			puts $chan "}"
		}
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace positions
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
