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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval game {
namespace eval mc {

set Overwrite "Game %s has been altered.\n\nDo you really want to continue and discard the changes made to it?"
set CloseAllGames "Close all open games of database '%s'?\n%s"
set DetachAllOpenGames "All unclosed games will be detached from their database association."

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

variable List	{}	;# {<timestamp> <modified> {<base> <codec> <number>} <info>}
variable Max	9
variable Size	3
variable Count	0

array set Options {
	askAgain:overwrite	1
	askAgain:releaseAll	1
	answer:overwrite		0
	answer:releaseAll		0
}


proc new {parent base info {index -1}} {
	variable List
	variable Size
	variable Count

	set init [expr {[llength $List] == 0}]

	if {$index == -1} { set index [incr Count] }
	if {[llength $base] == 0} {
		set codec [::scidb::db::get codec $base]
	} else {
		set codec [::scidb::db::get codec Clipbase]
	}
	set id [list $base $codec $index]
	set pos [lsearch -exact -index 2 $List $id]
	set entry [list [clock milliseconds] 0 $id $info]

	if {$pos >= 0} {
		lset List $pos $entry
		select $pos
	} elseif {[llength $List] < $Size} {
		set pos [llength $List]
		::scidb::game::release $pos	;# release scratch game
		load $parent $pos $base $index
		if {[llength $info] == 0} { set info [::scidb::game::info $pos] }
		::scidb::game::switch $pos
		::application::pgn::add $pos $base $info [::scidb::game::tags $pos]
		lappend List $entry
	} else {
		set games [lsort -index 0 $List]
		set i [lsearch -integer -index 1 $games 0]
		if {$i == -1} {
			if {![AskOverwrite $parent [lindex $games 0 3]} { return }
			set i 0
		}
		set pos [lsearch -exact -index 2 $List [lindex $games $i 2]]
		if {[lindex $List $pos 0]} { application::pgn::release $pos }
		::scidb::game::release $pos	;# release scratch game
		load $parent $pos $base $index
		if {[llength $info] == 0} { set info [::scidb::game::info $pos] }
		::scidb::game::switch $pos
		::application::pgn::add $pos $base $info [::scidb::game::tags $pos]
		lset List $pos $entry
	}

	if {$init} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
	}

	return $pos
}


proc load {parent position base index} {
	if {[llength $base]} {
		if {![::scidb::game::load $position $base $index]} {
			::dialog::error -parent $parent -message $::browser::mc::GameDataCorrupted
		}
	} else {
		::scidb::game::new $position [::scidb::pos::fen]
	}
}


proc setFirst {base info} {
	variable List
	variable Size

	if {[llength $List] == 0} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
	}

	if {[llength $List] == 0} { lappend List {} }
	set id [list $base sci 0]
	lset List 0 [list [clock milliseconds] 0 $id $info]
	select 0
}


proc select {position} {
	::scidb::game::switch $position
	::application::pgn::select $position
}


proc release {position} {
	variable List

	update idletasks	;# fire dangling events
	::scidb::game::release $position
	lset List $position {0 0 {{} {} {}} {}}
}


proc releaseAll {parent base} {
	variable List
	variable Options

	set entries {}
	set pos 0

	foreach entry $List {
		lassign $entry timestamp modified database info
		lassign $database name codec number

		if {$base eq $name} {
			set index [::gamebar::getIndex [::application::pgn::gamebar] $pos]
			lappend entries [list $pos $index $timestamp $modified $number $info]
		}

		incr pos
	}

	if {[llength $entries] == 0} { return 1 }

	if {$Options(askAgain:releaseAll)} {
		foreach entry $entries {
			lassign $entry pos index timestamp modified number info

			append s "\n"
			append s "  "
			append s [expr {$index + 1}]
			append s ": "
			append s [::gametable::column $info white]
			append s " - "
			append s [::gametable::column $info black]
			append s " (#"
			append s [expr {$number + 1}]
			append s ")"
		}
		
		set reply [::dialog::question \
			-parent $parent \
			-message [format $mc::CloseAllGames [::util::::databaseName $base] $s] \
			-detail $mc::DetachAllOpenGames \
			-check [namespace current]::Options(askAgain:releaseAll) \
			-buttons {cancel yes no} \
		]

		if {$reply eq "cancel"} {
			return 0
		} elseif {$reply eq "yes"} {
			set Options(answer:releaseAll) 1
		} else {
			set Options(answer:releaseAll) 0
		}
	}

	if {!$Options(answer:releaseAll)} {
		return 1
	}

	foreach entry $entries {
		set pos [lindex $entry 0]
		::application::pgn::release $pos
		::scidb::game::release $pos	;# release scratch game
	}

	::application::pgn::select
	return 1
}


proc resize {n} {
	variable Size
	variable Max

	set Size [max 1 [min $n $Max]]
}


proc startTrialMode {{pos -1}} {
	::scidb::game::push $pos
}


proc endTrialMode {{pos -1}} {
	::scidb::game::pop $pos
}


proc trialMode? {{pos -1}} {
	return [::scidb::game::query trial]
}


proc AskOverwrite {parent info} {
	variable Options

	if {(!$Options(askAgain:overwrite)} { return $Options(answer:overwrite) }

	set w [::gametable::column $info white]
	set b [::gametable::column $info black]

	set reply [::dialog::question \
		-parent $parent \
		-message [format $mc::Overwrite "$w - $b"] \
		-check [namespace current]::Options(askAgain:overwrite) \
	]
	
	if {$reply eq "yes"} {
		set Options(answer:overwrite) 1
	} else {
		set Options(answer:overwrite) 0
	}

	return $Options(answer:overwrite)
}


proc Update {_ position} {
	variable List

	lset List $position 2 0 [::scidb::game::query $position database]
	lset List $position 2 1 [::scidb::game::query $position index]
	lset List $position 1 [::scidb::game::query $position modified?]
	lset List $position 3 [::scidb::game::info $position]
}

} ;# namespace game

# vi:set ts=3 sw=3:
