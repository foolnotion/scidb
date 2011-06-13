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

set CloseAllGames				"Close all open games of database '%s'?"
set AllSlotsOccupied			"All game slots are occupied."
set ReleaseOneGame			"Please release one of the games before loading a new one."
set GameAlreadyOpen			"Game is already open but modified. Discard modified game?"
set GameAlreadyOpenDetail	"'%s' will open a new game."
set GameHasChanged			"Game %s has changed (outside this session?)."
set CorruptedHeader			"Corrupted header in recovery file '%s'."
set RenamedFile				"Renamed this file to '%s.bak'."
set CannotOpen					"Cannot open recovery file '%s'."
set GameRestored				"One game from last session restored."
set GamesRestored				"%s games from last session restored."
set ErrorInRecoveryFile		"Error in recovery file '%s'"
set Recovery					"Recovery"
set UnsavedGames				"You have unsaved game changes."
set DiscardChanges			"'%s' will throw away all changes."
set ShouldRestoreGame		"Should this game be restored in next session?"
set ShouldRestoreGames		"Should these games be restored in next session?"
set NewGame						"New Game"
set NewGames					"New Games"
set Created						"created"

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

# {<time> <modified> <locked> {<base> <codec> <number>} {<crc-index> <crc-moves>} <tags>}
variable List		{}
variable History	{}

variable HistorySize		10
variable MaxPosition		9
variable Count				0

array set Options {
	askAgain:overwrite	1
	askAgain:releaseAll	1
	answer:overwrite		0
	answer:releaseAll		0
	game:max					9
}


proc new {parent {base {}} {index -1}} {
	variable MaxPosition
	variable History
	variable HistorySize
	variable List
	variable Options
	variable Count

	set init [expr {[llength $List] == 0}]

	# TODO: check whether base is open or exisiting!

	if {$index == -1} {
		set index [incr Count]
		set lock 1
	} else {
		set lock 0
	}
	if {[llength $base] == 0} { set base Scratchbase }
	set codec [::scidb::db::get codec $base]
	set id [list $base $codec $index]
	set time [clock format [clock seconds] -format {%Y.%m.%d %H:%M:%S}]
	set entry [list $time 0 0 $id]
	set tags {}
	if {$base eq "Scratchbase"} {
		set pos -1
	} else {
		set pos [lsearch -exact -index 3 $List $id]
	}
	set loadPos -1
	set cmd ""

	if {$pos >= 0} {
		set loadPos [expr {$MaxPosition + 1}]
		::scidb::game::release $loadPos
		set crc [load $parent $loadPos $base $index]
		if {[llength $crc] == 0} { return -1 }

		if {$crc ne [lindex $List $pos 4]} {
			::dialog::warning -parent $parent -message [format $mc::GameHasChanged $index]
			set pos -1
		} elseif {[lindex $List $pos 1]} {
			set reply [::dialog::question \
				-parent $parent \
				-message $mc::GameAlreadyOpen \
				-detail [format $mc::GameAlreadyOpenDetail [string toupper $::mc::No 0 0]] \
				-buttons {yes no cancel} \
				-default no
			]
			switch $reply {
				cancel	{ return -1 }
				no			{ set pos -1 }
				yes		{ set cmd replace }
			}
		}
	}

	if {$pos >= 0 && [string length $cmd] == 0} {
		::scidb::game::release $loadPos
		::application::pgn::select $pos
	} else {
		if {[string length $cmd] == 0} {
			set pos -1
			for {set i 0} {$i < [llength $List]} {incr i} {
				set elem [lindex $List $i]
				if {![lindex $elem 1] && ![lindex $elem 2]} {
					if {$pos == -1} {
						set pos $i
					} elseif {[lindex $elem 0] != 0} {
						set pos $i
					}
				}
			}
			if {$pos == -1} {
				set pos [llength $List]
				if {$pos == $Options(game:max)} {
					::dialog::info -parent $parent -message $mc::AllSlotsOccupied -detail $mc::ReleaseOneGame
					return -1
				}
				lappend List $entry	;# only a placeholder
				set cmd add
			} elseif {[lindex $List $pos 0] == 0} {
				set cmd add
			} else {
				set cmd replace
			}
		}

		if {$loadPos == -1} {
			::scidb::game::release $pos	;# release scratch game
			set crc [load $parent $pos $base $index]
			if {[llength $crc] == 0} { return -1 }
		} else {
			::scidb::game::swap $pos $loadPos
			::scidb::game::release $loadPos
		}

		set tags [::scidb::game::tags $pos]
		lappend entry $crc $tags
		::scidb::game::switch $pos
		lset List $pos $entry
		::application::pgn::$cmd $pos $base $tags
		if {$cmd eq "replace"} { stateChanged $pos 0 }
	}

	if {$lock} {
		::application::pgn::lock $pos
	}

	if {$init} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
	}

	if {[llength $tags]} {
		foreach pair $tags {
			lassign $pair name value
			set lookup($name) $value
		}
		set info {}
		foreach name {Event Site Date Round White Black Result} { lappend info $lookup($name) }
		set entry [list $info [lindex $List $pos 3] [lindex $List $pos 4]]
		set i [lsearch -index 0 $History $info]
		if {$i == -1 && [llength $History] < $HistorySize} {
			lappend History $entry
		} else {
			if {$i == -1} { set i end }
			set History [linsert [lreplace $History $i $i] 0 $entry]
		}
	}

	return $pos
}


proc time? {position} {
	variable List
	return [lindex $List $position 0]
}


proc stateChanged {position modified} {
	variable List
	variable MaxPosition

	if {$position <= $MaxPosition} {
		lset List $position 1 $modified

		if {!$modified} {
			# ensure that at most one game is writable
			for {set i 0} {$i < [llength $List]} {incr i} {
				set entry [lindex $List $i]
				if {$i != $position && [lindex $entry 0] != 0 && ![lindex $entry 1] && ![lindex $entry 2]} {
					::application::pgn::lock $position
					return
				}
			}
		}
	}
}


proc lockChanged {position locked} {
	variable List
	variable MaxPosition

	if {$position <= $MaxPosition} {
		lset List $position 2 $locked
	}
}


proc load {parent position base index} {
	if {$base eq "Scratchbase"} {
		::scidb::game::new $position [::scidb::pos::fen]
	} elseif {![::scidb::game::load $position $base $index]} {
		::dialog::error -parent $parent -message $::browser::mc::GameDataCorrupted
		return {}
	}

	return [::scidb::game::query $position checksum]
}


proc setFirst {base tags} {
	variable List

	if {[llength $List] == 0} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
	}

	if {[llength $List] == 0} { lappend List {} }
	set id [list $base sci 0]
	set time [clock format [clock seconds] -format {%Y.%m.%d %H:%M:%S}]
	lset List 0 [list $time 0 0 $id {0 0} $tags]
}


proc release {position} {
	variable List

	update idletasks	;# fire dangling events
	::scidb::game::release $position
	lset List $position {0 0 0 {{} {} {}} {0 0} {}}
}


proc releaseAll {parent base} {
	variable List
	variable Options

	set entries {}
	set pos 0

	foreach entry $List {
		lassign $entry time modified locked database crc tags
		lassign $database name codec number

		if {!$modified && $base eq $name} {
			set index [::gamebar::getIndex [::application::pgn::gamebar] $pos]
			lappend entries [list $pos $index $time $modified $locked $number $tags]
		}

		incr pos
	}

	if {[llength $entries] == 0} { return 1 }

	if {$Options(askAgain:releaseAll)} {
		append msg [format $mc::CloseAllGames [::util::::databaseName $base]]
		append msg <embed>

		set reply [::dialog::question \
			-parent $parent \
			-message $msg \
			-check [namespace current]::Options(askAgain:releaseAll) \
			-buttons {cancel yes no} \
			-embed [namespace code [list EmbedReleaseMessage $entries]] \
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


proc queryCloseApplication {parent} {
	variable List

	set games {}
	set pos 0

	foreach entry $List {
		lassign $entry time modified locked database crc tags
		lassign $database name codec number

		if {$modified} {
			lappend games [list $pos $time $name $number $tags]
		}

		incr pos
	}

	if {[llength $games] == 0} { return discard }
	set games [lsort -index 1 $games]

	append msg $mc::UnsavedGames
	append msg <embed>
	if {[llength $games] == 1} {
		append msg $mc::ShouldRestoreGame
	} else {
		append msg $mc::ShouldRestoreGames
	}

	set reply [::dialog::question \
		-parent $parent \
		-message $msg \
		-detail [format $mc::DiscardChanges [::menu::stripAmpersand $::dialog::mc::No]] \
		-buttons {cancel yes no} \
		-embed [namespace code [list EmbedCloseMessage $games]] \
	]

	switch $reply {
		yes	{ set reply restore }
		no		{ set reply discard }
	}

	return $reply
}


proc resize {n} {
	variable Options
	variable MaxPosition

	set MaxPosition [max 1 [min $n $Options(game:max)]]
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


proc backup {} {
	variable List
	variable MaxPosition

	set Recovery [lrepeat $MaxPosition {}]

	for {set i 0} {$i < [llength $List]} {incr i} {
		if {	[lindex $List $i 0] != 0
			&& [::scidb::game::query $i modified?]
			&& ![::scidb::game::query $i empty?]} {
			lassign [lindex $List $i] time _ _ key crc _
			set filename [file join $::scidb::dir::backup game-$i.pgn]
			::scidb::game::export $i $filename -comment [list $time $key $crc]
		}
	}
}


proc recover {} {
	variable Recovery
	variable Current
	variable List

	set count 0

	foreach file [glob -directory $::scidb::dir::backup -nocomplain game-*.pgn] {
		if {[file readable $file]} {
			set position [string range $file 5 end-4]
			set chan [open $file r]
			fconfigure $chan -encoding utf-8
			set content [read $chan]
			close $chan

			set header [string range [lindex [split $content "\n"] 0] 1 end]

			if {[catch { set length [llength $header] }]} {
				::dialog::error \
					-parent .application \
					-message [format $mc::CorruptedHeader $file] \
					-detail [format $mc::RenamedFile $file] \
					;
			} else {
				if {	$length != 3
					|| [llength [lindex $header 1]] != 3
					|| [llength [lindex $header 2]] != 2} {
					::dialog::error \
						-parent .application \
						-message [format $mc::CorruptedHeader $file] \
						-detail [format $mc::RenamedFile $file] \
						;
				} else {
					lassign $header time key crc
					set Current(file) $file
					set Current(kex) $key
					::scidb::game::new $count
					set tags [::scidb::game::tags $count]
					lappend List [list $time 1 0 $key $crc $tags]
					::scidb::game::import $count $content [namespace current]::Log {} \
						-encoding utf-8 \
						-variation 0 \
						-scidb 1 \
						;
					set base [lindex $key 0]
					set index [lindex $key 2]
					::scidb::game::sink $count $base $index
					::application::pgn::add $count $base $tags
					::scidb::game::modified $count
					incr count
				}
			}
		} else {
			::dialog::error \
				-parent .application \
				-message [format $mc::CannotOpen $file] \
				-detail [format $mc::RenamedFile $file] \
				;
		}

		file rename -force $file $file.bak
	}

	if {$count > 0} {
		if {$count == 1} { set msg $mc::GameRestored } else { set msg $mc::GamesRestored }
		::dialog::info -parent .application -message [format $msg $count]
		::scidb::game::switch 0
	}
}


proc EmbedReleaseMessage {entries w infoFont alertFont} {
	variable ::gamebar::icon::15x15::digit

	set row 0
	grid columnconfigure $w {1 3} -minsize 5

	foreach entry $entries {
		lassign $entry pos index time modified locked number tags

		lassign {"?" "?"} white black
		foreach pair $tags {
			lassign $pair name value
			switch $name {
				White { set white $value }
				Black { set black $value }
			}
		}

		set col(1) "$white \u2212 $black"
		set col(2) "(#[expr {$number + 1}])"

		incr pos
		grid [tk::label $w.line-$row-0 -image $digit($pos)] -row $row -column 0 -sticky w
		grid [tk::label $w.line-$row-1 -text $col(1) -font $infoFont] -row $row -column 2 -sticky w
		grid [tk::label $w.line-$row-2 -text $col(2) -font $infoFont] -row $row -column 4 -sticky w

		incr row
	}
}


proc EmbedCloseMessage {games w infoFont alertFont} {
	variable ::gamebar::icon::15x15::digit

	grid columnconfigure $w 0 -minsize 10
	grid columnconfigure $w {2 4} -minsize 5

	set prev ""
	set row 0
	set count 0

	foreach entry $games {
		if {[lindex $entry 2] eq "Scratchbase"} { incr count }
	}

	foreach entry $games {
		lassign $entry pos time base number tags

		if {$prev ne $base} {
			set prev $base
			if {$row > 0} {
				grid rowconfigure $w $row -minsize 8
				incr row
			}
			if {$base ne "Scratchbase"} {
				set title [::util::databaseName $base]
			} elseif {$count == 1} {
				set title $mc::NewGame
			} else {
				set title $mc::NewGames
			}
			set text [tk::label $w.line-$row -text $title -font $alertFont]
			grid $text -row $row -column 1 -columnspan 3 -sticky w
			incr row
		}

		lassign {"?" "?"} white black
		foreach pair $tags {
			lassign $pair name value
			switch $name {
				White { set white $value }
				Black { set black $value }
			}
		}

		if {$prev eq "Scratchbase"} {
			set col(1) "$mc::Created: [::locale::formatTime $time]"
			set col(2) ""
		} else {
			set col(1) "$white \u2212 $black"
			set col(2) "(#[expr {$number + 1}])"
		}

		incr pos
	
		grid [tk::label $w.line-$row-0 -image $digit($pos)] -row $row -column 1 -sticky w
		grid [tk::label $w.line-$row-1 -text $col(1) -font $infoFont] -row $row -column 3 -sticky w
		grid [tk::label $w.line-$row-2 -text $col(2) -font $infoFont] -row $row -column 5 -sticky w

		incr row
	}
}


proc Log {_ arguments} {
	variable Current

	if {[lindex $arguments 0] eq "error"} {
		append msg [format $mc::ErrorInRecoveryFile $Current(file)]
		append msg " ("
		append msg [lindex $Current(key) 0]
		append msg " ."
		append msg [lindex $Current(key) 1]
		append msg " #"
		append msg [lindex $Current(key) 2]
		append msg "):"
		::log::error $mc::Recovery $msg
		::log::info $mc::Recovery [::import::makeLog $arguments]
	}
}


proc Update {_ position} {
	variable List
	variable MaxPosition

	if {$position <= $MaxPosition} {
		set base [::scidb::game::query $position database]

		lset List $position 3 0 $base
		lset List $position 3 1 [::scidb::db::get codec $base]
		lset List $position 3 2 [::scidb::game::query $position index]
		lset List $position 1 [::scidb::game::query $position modified?]
		lset List $position 4 [::scidb::game::query $position checksum]
		lset List $position 5 [::scidb::game::tags $position]
	}
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::History
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace game

# vi:set ts=3 sw=3:
