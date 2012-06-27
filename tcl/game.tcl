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

::util::source game-management

namespace eval game {
namespace eval mc {

set CloseDatabase					"Close Database"
set CloseAllGames					"Close all open games of database '%s'?"
set SomeGamesAreModified		"Some games of database '%s' are modified. Close anyway?"
set AllSlotsOccupied				"All game slots are occupied."
set ReleaseOneGame				"Please release one of the games before loading a new one."
set GameAlreadyOpen				"Game is already open but modified. Discard modified game?"
set GameAlreadyOpenDetail		"'%s' will open a new game."
set GameHasChanged				"Game %s has changed."
set GameHasChangedDetail		"Probably this is not the expected game due to database changes."
set CorruptedHeader				"Corrupted header in recovery file '%s'."
set RenamedFile					"Renamed this file to '%s.bak'."
set CannotOpen						"Cannot open recovery file '%s'."
set OldGameRestored				"One game restored."
set OldGamesRestored				"%s games restored."
set GameRestored					"One game from last session restored."
set GamesRestored					"%s games from last session restored."
set ErrorInRecoveryFile			"Error in recovery file '%s'"
set Recovery						"Recovery"
set UnsavedGames					"You have unsaved game changes."
set DiscardChanges				"'%s' will throw away all changes."
set ShouldRestoreGame			"Should this game be restored in next session?"
set ShouldRestoreGames			"Should these games be restored in next session?"
set NewGame							"New Game"
set NewGames						"New Games"
set Created							"created"
set ClearHistory					"Clear history"
set RemoveSelectedGame			"Remove selected game from history"
set GameDataCorrupted			"Game data is corrupted."
set GameDecodingFailed			"Decoding of this game was not possible."
set GameDecodingChanged			"The database is opened with character set '%base%', but this game seems to be encoded with character set '%game%', therefore this game is loaded with the detected character set."
set GameDecodingChangedDetail	"Probably you have opened the database with the wrong character set. Note that the automatic detection of the character set is limited."

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

# {<time> <modified> <locked> {<base> <codec> <number>} {<crc-index> <crc-moves>} <tags>}
variable List		{}

# {<tags> {<base> <codec> <number>} {<crc-index> <crc-moves>} <encoding>}
variable History	{}

variable HistorySize		10
variable MaxPosition		9
variable Count				0

array set Options {
	askAgain:overwrite	1
	askAgain:releaseAll	1
	askAgain:closeAnyway	1
	answer:overwrite		0
	answer:releaseAll		0
	answer:closeAnyway	0
	game:max					9
}


proc new {parent {base {}} {index -1} {fen {}}} {
	variable ::scidb::scratchbaseName
	variable MaxPosition
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
	if {[llength $base] == 0} { set base $scratchbaseName }
	set codec [::scidb::db::get codec $base]
	set id [list $base $codec $index]
	set time [clock format [clock seconds] -format {%Y.%m.%d %H:%M:%S}]
	set entry [list $time 0 0 $id]
	set tags {}
	if {$base eq $scratchbaseName} {
		set pos -1
	} else {
		set pos [lsearch -exact -index 3 $List $id]
	}
	set loadPos -1
	set cmd ""

	if {$pos >= 0} {
		set loadPos [expr {$MaxPosition + 1}]
		::scidb::game::release $loadPos
		if {![load $parent $loadPos $base $index yes]} { return -1 }
		set crc [::scidb::game::query $loadPos checksum]

		if {$crc ne [lindex $List $pos 4]} {
			# TODO: open new slot iff only crc-index differs
			set msg [format $mc::GameHasChanged [expr {$index + 1}]]
			set det $mc::GameHasChangedDetail
			::dialog::warning -buttons {ok} -parent $parent -message $msg -detail $det
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
				cancel	{ return -2 }
				no			{ set pos -2 }
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
					if {$pos < 0 || [llength [lindex $elem 0]]} {
						set pos $i
					}
				}
			}
			if {$pos < 0} {
				set pos [llength $List]
				if {$pos == $Options(game:max)} {
					::dialog::info -parent $parent -message $mc::AllSlotsOccupied -detail $mc::ReleaseOneGame
					return -2
				}
				lappend List $entry	;# only a placeholder
				set cmd add
			} elseif {[llength [lindex $List $pos 0]] == 0} {
				set cmd add
			} else {
				set cmd replace
			}
		}

		if {$loadPos == -1} {
			::scidb::game::release $pos ;# release scratch game
			if {![load $parent $pos $base $index yes]} { return -1 }
			set crc [::scidb::game::query $pos checksum]
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
		::scidb::db::subscribe gameHistory [namespace current]::UpdateHistory
	}

	if {[llength $fen]} {
		::scidb::game::go $pos position $fen
	}

	UpdateHistoryEntry $pos $base $tags

	return $pos
}


proc time? {position} {
	variable List
	return [lindex $List $position 0]
}


proc usedPositions? {} {
	variable List

	set pos 0
	set result {}

	foreach entry $List {
		if {[llength [lindex $List $pos 0]]} { lappend result $pos }
		incr pos
	}

	return $result
}


proc stateChanged {position modified} {
	variable List
	variable MaxPosition

	if {$position < $MaxPosition} {
		lset List $position 1 $modified

		if {!$modified} {
			# ensure that at most one game is writable
			for {set i 0} {$i < [llength $List]} {incr i} {
				set entry [lindex $List $i]
				if {	$i != $position
					&& [llength [lindex $entry 0]]
					&& ![lindex $entry 1]
					&& ![lindex $entry 2]} {
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

	if {$position < $MaxPosition} {
		lset List $position 2 $locked
	}
}


proc load {parent position base index {checkEncoding 0}} {
	variable ::scidb::scratchbaseName

	set rc 0

	if {$base eq $scratchbaseName} {
		::scidb::game::new $position [::scidb::pos::fen]
		set rc 1
	} else {
		switch [::scidb::game::load $position $base $index] {
			 1 { set rc 1 }
			-1 { ::dialog::info  -parent [winfo toplevel $parent] -message $mc::GameDecodingFailed }
			-2 { ::dialog::error -parent [winfo toplevel $parent] -message $mc::GameDataCorrupted }
		}

		if {$checkEncoding} {
			set baseEncoding [::scidb::db::get encoding $base]
			set gameEncoding [::scidb::game::query $position encoding]

			if {$baseEncoding != $gameEncoding} {
				set fmt [list %base% $baseEncoding %game% $gameEncoding]
				set msg [string map $fmt $mc::GameDecodingChanged]
				set dtl $mc::GameDecodingChangedDetail
				::dialog::info -parent [winfo toplevel $parent] -message $msg -detail $dtl
			}
		}
	}

	return $rc
}


proc setFirst {base tags} {
	variable List

	if {[llength $List] == 0} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
		::scidb::db::subscribe gameHistory [namespace current]::UpdateHistory
	}

	if {[llength $List] == 0} { lappend List {} }
	set id [list $base sci 0]
	set time [clock format [clock seconds] -format {%Y.%m.%d %H:%M:%S}]
	lset List 0 [list $time 0 0 $id {0 0} $tags]
}


proc release {position} {
	variable List

	update ;# fire dangling events
	::scidb::game::release $position
	lset List $position {{} 0 0 {{} {} {} {}} {0 0} {}}
}


proc closeAll {parent base {title ""} {detail ""}} {
	variable List
	variable Options

	if {[string length $title] == 0} {
		set title $mc::CloseDatabase
	}

	set openGames {}
	set modifiedGames {}
	set pos 0
	set query 1

	foreach entry $List {
		lassign $entry time modified locked database crc tags
		lassign $database name codec number

		if {$base eq $name} {
			set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $pos] + 1}]
			set entry [list $pos $index $time $modified $locked $number $tags]
			if {$modified} { lappend modifiedGames $entry } else { lappend openGames $entry }
		}

		incr pos
	}

	if {[llength $modifiedGames]} {
		set modifiedGames [lsort -index 1 -integer $modifiedGames]
		append msg [format $mc::SomeGamesAreModified [::util::databaseName $base]]
		append msg <embed>

		set reply [::dialog::question \
			-parent $parent \
			-title "$::scidb::app: $title" \
			-message $msg \
			-detail $detail \
			-buttons {yes cancel} \
			-default cancel \
			-embed [namespace code [list EmbedReleaseMessage $modifiedGames]] \
		]

		if {$reply eq "cancel"} { return 0 }
		set query 0
		unset msg
	}

	if {[llength $openGames] == 0} { return 1 }

	set openGames [lsort -index 1 -integer $openGames]
	set name [::util::databaseName $base]
	append msg [format $mc::CloseAllGames $name]
	append msg <embed>
	set base

	if {$query} {
		set reply [::dialog::question \
			-parent $parent \
			-title "$::scidb::app: $title" \
			-message $msg \
			-detail $detail \
			-buttons {cancel yes} \
			-default yes \
			-embed [namespace code [list EmbedReleaseMessage $openGames]] \
		]

		if {$reply eq "cancel"} { return 0 }
	}

	foreach entry [concat $openGames $modifiedGames] {
		set pos [lindex $entry 0]
		::application::pgn::release $pos
		::scidb::game::release $pos	;# release scratch game
	}

	::application::pgn::select
	return 1
}


proc releaseAll {parent base} {
	variable List
	variable Options

	set openGames {}
	set modifiedGames {}
	set pos 0

	foreach entry $List {
		lassign $entry time modified locked database crc tags
		lassign $database name codec number

		if {$base eq $name} {
			set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $pos] + 1}]
			set entry [list $pos $index $time $modified $locked $number $tags]
			if {$modified} { lappend modifiedGames $entry } else { lappend openGames $entry }
		}

		incr pos
	}

	if {[llength $modifiedGames]} {
		set modifiedGames [lsort -index 1 -integer $modifiedGames]
		append msg [format $mc::SomeGamesAreModified [::util::databaseName $base]]
		append msg <embed>

		set reply [::dialog::question \
			-parent $parent \
			-title "$::scidb::app: $mc::CloseDatabase" \
			-message $msg \
			-check [namespace current]::Options(askAgain:closeAnyway) \
			-buttons {yes no} \
			-default yes \
			-embed [namespace code [list EmbedReleaseMessage $modifiedGames]] \
		]

		if {$reply eq "cancel"} { return 0 }

		if {$reply eq "yes"} {
			set Options(answer:closeAnyway) 1
		} else {
			set Options(answer:closeAnyway) 0
		}

		if {!$Options(answer:closeAnyway)} {
			return 0
		}

		unset msg
	}

	if {[llength $openGames] == 0} { return 1 }

	if {$Options(askAgain:releaseAll)} {
		set openGames [lsort -index 1 -integer $openGames]
		set name [::util::databaseName $base]
		append msg [format $mc::CloseAllGames $name]
		append msg <embed>
		set base

		set reply [::dialog::question \
			-parent $parent \
			-title "$::scidb::app: $mc::CloseDatabase" \
			-message $msg \
			-check [namespace current]::Options(askAgain:releaseAll) \
			-buttons {cancel yes no} \
			-default yes \
			-embed [namespace code [list EmbedReleaseMessage $openGames]] \
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

	foreach entry $openGames {
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

		if {$modified && ![::scidb::game::query $pos empty?]} {
			set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $pos] + 1}]
			lappend games [list $pos $index $time $name $number $tags]
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
		-detail [format $mc::DiscardChanges [::mc::stripAmpersand $::dialog::mc::No]] \
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


proc flipTrialMode {{pos -1}} {
	if {[trialMode? $pos]} {
		::scidb::game::pop $pos
		::gamebar::setEmphasized [::application::pgn::gamebar] 0
	} else {
		::scidb::game::push $pos
		::gamebar::setEmphasized [::application::pgn::gamebar] 1
	}
}


proc trialMode? {{pos -1}} {
	return [::scidb::game::query $pos trial]
}


proc save {parent} {
	if {[::scidb::game::current] != 9} {
		::dialog::save::open $parent [::scidb::db::get name] -1
	}
}


proc replace {parent} {
	if {[::scidb::game::current] != 9} {
		::dialog::save::open $parent [::scidb::db::get name] -1 [::scidb::game::number]
	}
}


# proc replaceMoves {parent} {
# 	if {[::scidb::game::current] != 9} {
# 		set base [::scidb::db::get name]
# 		set number [::scidb::game::number]
# 
# 		if {[::dialog::save::checkIfWriteable $parent $base -1 $number]} {
# 			::application::pgn::replaceMoves $parent
# 		}
# 	}
# }


proc clearHistory {} {
	set [namespace current]::History {}
	::application::pgn::historyChanged
}


proc removeHistoryEntry {index} {
	variable History

	set History [lreplace $History $index $index]
	::application::pgn::historyChanged
}


proc historyIsEmpty? {} {
	return [expr {[llength [set [namespace current]::History]] == 0}]
}


proc backup {} {
	variable List
	variable MaxPosition

	set Recovery [lrepeat $MaxPosition {}]

	for {set i 0} {$i < [llength $List]} {incr i} {
		if {	[llength [lindex $List $i 0]]
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
	set pattern game-*.pgn
	if {[::process::testOption recover-old]} { append pattern .bak }

	log::open $mc::Recovery
	set files [lsort -dictionary [glob -directory $::scidb::dir::backup -nocomplain $pattern]]

	foreach file $files {
		if {![::process::testOption dont-recover]} {
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
						set Current(key) $key
						::scidb::game::new $count
						set tags [::scidb::game::tags $count]
						lappend List [list $time 1 0 $key $crc $tags]
						::scidb::game::import $count $content [namespace current]::Log {} \
							-encoding utf-8 \
							-variation 0 \
							-scidb 1 \
							;
						Update _ $count
						set tags [lindex $List $count 5]
						set base [lindex $key 0]
						set index [lindex $key 2]
						::scidb::game::sink $count $base $index
						::application::pgn::add $count $base $tags
						::application::pgn::setModified $count
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
		}

		if {![::process::testOption recover-old]} {
			file rename -force $file $file.bak
		}
	}

	log::close

	if {$count > 0} {
		if {$count == 1} {
			if {[::process::testOption recover-old]} {
				set msg $mc::OldGameRestored
			} else {
				set msg $mc::GameRestored
			}
		} else {
			if {[::process::testOption recover-old]} {
				set msg [format $mc::OldGamesRestored $count]
			} else {
				set msg [format $mc::GamesRestored $count]
			}
		}
		::dialog::info -parent .application -message $msg
		::application::pgn::select 0
	}
}


proc traverseHistory {headerScript gameScript} {
	variable History
	variable List

	set myList {}
	set count 0

	foreach entry $History {
		if {[lsearch -index 3 $List [lindex $entry 1]] == -1} {
			lassign $entry tags key 
			set base [lindex $key 0]
			set i [lsearch $myList $base]
			if {$i == -1} { lappend myList $base }
			lappend data($base) $tags $count
		}

		incr count
	}

	set count 0

	foreach base $myList {
		eval $headerScript
		foreach {tags index} $data($base) {
			eval $gameScript
			incr count
		}

		incr count
	}
}


proc openGame {parent index} {
	variable History
	variable List

	lassign [lindex $History $index] tags base crcHist encoding
	lassign $base base codec number
	set rc 1
	set parent [winfo toplevel $parent]

	if {[::application::database::openBase $parent $base no $encoding]} {
		set pos [new $parent $base $number]
		if {$pos >= 0} {
			set crcLoad [lindex $List $pos 4]
			if {$crcLoad ne $crcHist} {
				# TODO: open new slot iff only crc-index differs
				set msg [format $mc::GameHasChanged [expr {$number + 1}]]
				set det $mc::GameHasChangedDetail
				::dialog::warning -buttons {ok} -parent $parent -message $msg -detail $det
			}
		} elseif {$pos == -1} {
			set rc 0
		}
	} else {
		set rc 0
	}

	if {!$rc} {
		set History [lreplace $History $index $index]
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

		set col(1) "$white \u2013 $black"
		set col(2) "(#[expr {$number + 1}])"

		grid [tk::label $w.line-$row-0 -image $digit($index)] -row $row -column 0 -sticky w
		grid [tk::label $w.line-$row-1 -text $col(1) -font $infoFont] -row $row -column 2 -sticky w
		grid [tk::label $w.line-$row-2 -text $col(2) -font $infoFont] -row $row -column 4 -sticky w

		incr row
	}
}


proc EmbedCloseMessage {games w infoFont alertFont} {
	variable ::gamebar::icon::15x15::digit
	variable ::scidb::scratchbaseName

	grid columnconfigure $w 0 -minsize 10
	grid columnconfigure $w {2 4} -minsize 5

	set prev ""
	set row 0
	set count 0

	foreach entry $games {
		if {[lindex $entry 2] eq $scratchbaseName} { incr count }
	}

	foreach entry $games {
		lassign $entry pos index time base number tags

		if {$prev ne $base} {
			set prev $base
			if {$row > 0} {
				grid rowconfigure $w $row -minsize 8
				incr row
			}
			if {$base ne $scratchbaseName} {
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

		if {$prev eq $scratchbaseName} {
			set col(1) "$mc::Created: [::locale::formatTime $time]"
			set col(2) ""
		} else {
			set col(1) "$white \u2013 $black"
			set col(2) "(#[expr {$number + 1}])"
		}

		grid [tk::label $w.line-$row-0 -image $digit($index)] -row $row -column 1 -sticky w
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
		::log::error $msg
		::log::info [::import::makeLog $arguments]
	}
}


proc Update {_ position} {
	variable List
	variable History
	variable MaxPosition

	if {$position < $MaxPosition} {
		set key    [lindex $List $position 3]
		set base   [::scidb::game::query $position database]
		set tags   [::scidb::game::tags $position]
		set number [expr {[::scidb::game::number $position] - 1}]

		set i [lsearch -index 1 $History $key]
		if {$i >= 0} {
			lassign [lindex $History $i 1] filename _ index
			if {$base eq $filename} {
				set History [lreplace $History $i $i]
			}
		}

		lset List $position 3 0 $base
		lset List $position 3 1 [::scidb::db::get codec $base]
		lset List $position 3 2 [::scidb::game::index $position]
		lset List $position 1 [::scidb::game::query $position modified?]
		lset List $position 4 [::scidb::game::query $position checksum]
		lset List $position 5 $tags

		UpdateHistoryEntry $position $base $tags
	}
}


proc UpdateHistory {_ base index} {
	variable History

	for {set i 0} {$i < [llength $History]} {incr i} {
		lassign [lindex $History $i] info key crcHist _
		lassign $key filename codec number

		if {$base eq $filename && $index eq $number} {
			set tags [::scidb::db::get tags $index $base]
			set info {}

			foreach pair $tags {
				lassign $pair name value
				set lookup($name) $value
			}
			foreach name {Event Site Date Round White Black Result} { lappend info $lookup($name) }

			lset History $i 0 $info
			lset History $i 2 [list [::scidb::db::get checksum $index $base] [lindex $crcHist 1]]
			lset History $i 3 [::scidb::db::get encoding $base]
		}
	}
}


proc UpdateHistoryEntry {pos base tags} {
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable List
	variable History
	variable HistorySize

	if {[llength $tags] == 0} { return }
	if {$base eq $scratchbaseName} { return }
	if {$base eq $clipbaseName} { return }

	foreach pair $tags {
		lassign $pair name value
		set lookup($name) $value
	}
	set info {}
	set encoding [::scidb::db::get encoding $base]
	foreach name {Event Site Date Round White Black Result} { lappend info $lookup($name) }
	set entry [list $info [lindex $List $pos 3] [lindex $List $pos 4] $encoding]

	set i 0
	set k -1
	while {$i < [llength $History]} {
		set i [lsearch -index 0 -start $i $History $info]
		if {$i == -1} { break }
		if {$base eq [lindex $History $i 1 0]} { set k $i }
		incr i
	}

	if {$k >= 0 && $base eq [lindex $List $pos 3 0]} {
		if {$k == -1} { set k end }
		set History [lreplace $History $k $k]
	}

	while {[llength $History] >= $HistorySize} {
		set History [lreplace $History end end]
	}

	set History [linsert $History 0 $entry]
}


proc GameInTrialMode {parent title} {
	set name [::util::databaseName [::scidb::db::get name]]
	::dialog::info \
		-parent $parent \
		-message [format $mc::CurrentGameHasTrialMode $name] \
		-title "[tk appname] - $title" \
		;
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::History
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace game

# vi:set ts=3 sw=3:
