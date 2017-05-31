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
# Copyright: (C) 2009-2013 Gregor Cramer
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

set CloseDatabase						"Close Database"
set CloseAllGames						"Close all open games of database '%s'?"
set SomeGamesAreModified			"Some games of database '%s' are modified. Close anyway?"
set AllSlotsOccupied					"All game slots are occupied."
set ReleaseOneGame					"Please release one of the games before loading a new one."
set GameAlreadyOpen					"Game is already open but modified. Discard modified game?"
set GameAlreadyOpenDetail			"'%s' will open a new game."
set GameHasChanged					"Game %s has changed."
set GameHasChangedDetail			"Probably this is not the expected game due to database changes."
set CorruptedHeader					"Corrupted header in recovery file '%s'."
set RenamedFile						"Renamed this file to '%s.bak'."
set CannotOpen							"Cannot open recovery file '%s'."
set OldGameRestored					"One game restored."
set OldGamesRestored					"%s games restored."
set GameRestored						"One game from last session restored."
set GamesRestored						"%s games from last session restored."
set ErrorInRecoveryFile				"Error in recovery file '%s'"
set Recovery							"Recovery"
set UnsavedGames						"You have unsaved game changes."
set DiscardChanges					"'%s' will throw away all changes."
set ShouldRestoreGame				"Should this game be restored in next session?"
set ShouldRestoreGames				"Should these games be restored in next session?"
set NewGame								"New Game"
set NewGames							"New Games"
set Created								"created"
set ClearHistory						"Clear history"
set RemoveSelectedGame				"Remove selected game from history"
set GameDataCorrupted				"Game data is corrupted."
set GameDecodingFailed				"Decoding of this game was not possible."
set GameDecodingChanged				"The database is opened with character set '%base%', but this game seems to be encoded with character set '%game%', therefore this game is loaded with the detected character set."
set GameDecodingChangedDetail		"Probably you have opened the database with the wrong character set. Note that the automatic detection of the character set is limited."
set VariantHasChanged				"Game cannot be opened because the variant of the database has changed and is now different from the game variant."
set RemoveGameFromHistory			"Remove game from history?"
set GameNumberDoesNotExist			"Game %number does not exist in '%base'."
set ReallyReplaceGame				"It seems that the actual game #%s in game editor is not the originally loaded game due to intermediate database changes, it is likely that you lose a different game. Really replace game data?"
set ReallyReplaceGameDetail		"It is recommended to have a look on game #%s before doing this action."
set ReopenLockedGames				"Re-open locked games from previous session?"
set OpenAssociatedDatabases		"Open all associated databases?"
set OverwriteCurrentGame			"Overwrite current game?"
set OverwriteCurrentGameDetail	"A new game will be opened if answered with '%s'."

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

variable Header [list "Backup file for Scidb (UTF-8 encoded; HTML format)" "Version 1.0"]

# {<time>
#	<modified>
#	<locked>
#	<frozen>
#	{<base> <codec> <number> <variant>}
#	{<crc-index> <crc-moves>}
#	<tags>
#	<encoding>
#	<mode>}
variable List		{}

# {<tags> {<base> <codec> <number> <variant>} {<crc-index> <crc-moves>} <encoding>}
variable History	{}

variable HistorySize		10
variable MaxPosition		9
variable BrowserCount	100
variable LockedGames		{}
variable Selection		-1

array set Options {
	askAgain:overwrite	1
	askAgain:releaseAll	1
	askAgain:closeAnyway	1
	answer:overwrite		0
	answer:releaseAll		0
	answer:closeAnyway	0
	game:max					9
}

array set Vars {
	slots {}
}


proc new {parent args} {
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable MaxPosition
	variable List
	variable Options
	variable Vars

	array set opts {
		-base			""
		-view			-1
		-number		-1
		-fen			""
		-variant		Normal
		-lock			0
		-replace		0
		-encoding	utf-8
		-mode			edit
	}
	array set opts $args
	set base $opts(-base)
	set view $opts(-view)
	set number $opts(-number)
	set variant $opts(-variant)

	set init [expr {[llength $List] == 0}]

	# TODO: check whether base is open or existing!

	set lock [expr {$number == -1 ? 1 : $opts(-lock)}]
	if {[llength $base] == 0} { set base $scratchbaseName }
	set variant $opts(-variant)
	set codec [::scidb::db::get codec $base $variant]
	set id [list $base $codec $number $variant]
	set time [clock format [clock seconds] -format {%Y.%m.%d %H:%M:%S}]
	set entry [list $time 0 0 0 $id]
	set tags {}
	if {$base eq $scratchbaseName} {
		set pos -1
	} else {
		set pos [lsearch -exact -index 4 $List $id]
	}
	set loadPos -1
	set cmd ""

	if {$pos >= 0} {
		set loadPos [expr {$MaxPosition + 1}]
		::scidb::game::release $loadPos
		if {![load $parent $loadPos $base \
			-view $view \
			-number $number \
			-checkEncoding yes \
			-fen $opts(-fen) \
			-variant $opts(-variant) \
		]} {
			return -1
		}
		set crc [::scidb::game::query $loadPos checksum]

		if {$crc ne [lindex $List $pos 5]} {
			# TODO: open new slot iff only crc-index differs
			set msg [format $mc::GameHasChanged [expr {$number + 1}]]
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
		set Vars(lookup:$pos) $Vars(lookup:$loadPos)
		::application::pgn::select $pos
		::scidb::game::switch $pos
	} else {
		if {[string length $cmd] == 0} {
			set pos -1

			if {$opts(-replace)} {
				set pos [::scidb::game::current]
			} else {
				for {set i 0} {$i < [llength $List]} {incr i} {
					set elem [lindex $List $i]
					if {![lindex $elem 1] && ![lindex $elem 2] && ![lindex $elem 3]} {
						if {$pos < 0 || [llength [lindex $elem 0]]} {
							set pos $i
						}
					}
				}
			}

			if {$pos < 0} {
				set pos [llength $List]
				if {$pos == $Options(game:max)} {
					::dialog::info -parent $parent -message $mc::AllSlotsOccupied -detail $mc::ReleaseOneGame
					return -2
				}
				set cmd add
			} elseif {[llength [lindex $List $pos 0]] == 0} {
				set cmd add
			} else {
				set cmd replace
			}
		}

		if {$loadPos == -1} {
			set backupPos -1
			if {[::scidb::game::query $pos open?]} {
				set backupPos [expr {$MaxPosition + 1}]
				if {![::scidb::game::query $backupPos open?]} {
					::scidb::game::new $backupPos $opts(-variant)
				}
				::scidb::game::swapPositions $pos $backupPos
				::scidb::game::release $pos ;# release scratch game
			}
			if {![load $parent $pos $base \
				-view $view \
				-number $number \
				-checkEncoding yes \
				-fen $opts(-fen) \
				-variant $opts(-variant) \
			]} {
				if {$backupPos >= 0} {
					if {![::scidb::game::query $pos open?]} {
						::scidb::game::new $pos $opts(-variant)
					}
					::scidb::game::swapPositions $pos $backupPos
				}
				return -1
			}
			if {$backupPos >= 0} {
				::scidb::game::release $backupPos
			}
			set crc [::scidb::game::query $pos checksum]
		} else {
			::scidb::game::swapPositions $pos $loadPos
			set Vars(lookup:$pos) $Vars(lookup:$loadPos)
			::scidb::game::release $loadPos
		}

		set tags [::scidb::game::tags $pos]
		lappend entry $crc $tags $opts(-encoding) $opts(-mode)
		if {$pos == [llength $List]} {
			lappend List $entry
		}  else {
			lset List $pos $entry
		}
		::application::pgn::$cmd $pos $base $variant $tags
		::scidb::game::switch $pos
		if {$cmd eq "replace"} { stateChanged $pos 0 }
	}

	if {$lock} {
		::application::pgn::lock $pos
		lockChanged $pos $lock
	}

	if {$init} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
		::scidb::db::subscribe gameHistory [namespace current]::UpdateHistory
	}

	UpdateHistoryEntry $pos $base $variant $tags

	return $pos
}


proc replace {parent} {
	variable MaxPosition

	set replace 0

	if {[::scidb::game::current] < $MaxPosition && (![locked?] || [import?])} {
		set detail [format $mc::OverwriteCurrentGameDetail [::mc::stripAmpersand $::dialog::mc::No]]

		if {[modified?]} {
			append detail \n
			append detail [format $mc::DiscardChanges [::mc::stripAmpersand $::dialog::mc::Yes]]
		}

		set rc [::dialog::question \
			-parent $parent \
			-message $mc::OverwriteCurrentGame \
			-detail $detail \
			-default no
		]
		if {$rc eq "yes"} { set replace 1 }
	}

	return [new $parent -replace $replace -mode import]
}


proc verify {parent position number} {
	variable ::scidb::scratchbaseName

	set sink [lindex [::scidb::game::link? $position] 0]
	if {$sink eq $scratchbaseName && ![::scidb::game::verify $position]} {
		set msg [format $mc::ReallyReplaceGame $number]
		set detail [format $mc::ReallyReplaceGameDetail $number]
		return [::dialog::question -parent $parent -message $msg -detail $detail -default no]
	}

	return yes
}


proc getSourceInfo {position} {
	variable Vars

	if {![info exists Vars(lookup:$position)]} { return {} }
	return $Vars(lookup:$position)
}


proc time? {position}	{ variable List; return [lindex $List $position 0] }
proc tags? {position}	{ variable List; return [lindex $List $position 6] }
proc number? {position}	{ variable List; return [lindex $List $position 4 2] }


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


proc setModified {position} {
	variable List
	variable MaxPosition

	if {$position >= $MaxPosition} { return 0 }
	::application::pgn::setModified $position
	lset List $position 1 1
}


proc modified? {{position -1}} {
	variable List
	variable MaxPosition

	if {$position == -1} { set position [::scidb::game::current] }
	if {$position >= $MaxPosition} { return 0 }
	return [lindex $List $position 1]
}


proc import? {{position -1}} {
	variable List
	variable MaxPosition

	if {$position == -1} { set position [::scidb::game::current] }
	if {$position >= $MaxPosition} { return 0 }
	return [expr {[lindex $List $position 8] eq "import"}]
}


proc lock {position} {
	variable List
	variable MaxPosition

	if {$position >= $MaxPosition} { return 0 }
	if {[set rc [::application::pgn::lock $position]]} { lset List $position 2 1 }
	return $rc
}


proc unlock {position} {
	variable List
	variable MaxPosition

	if {$position >= $MaxPosition} { return 0 }
	if {[set rc [::application::pgn::unlock $position]]} { lset List $position 2 0 }
	return $rc
}


proc locked? {{position -1}} {
	variable List
	variable MaxPosition

	if {$position == -1} { set position [::scidb::game::current] }
	if {$position >= $MaxPosition} { return 0 }
	return [lindex $List $position 2]
}


proc lockChanged {position locked} {
	variable List
	variable MaxPosition

	if {$position < $MaxPosition} {
		lset List $position 2 $locked
	}
}


proc freeze {position {tooltipvar ""}} {
	variable List

	::application::pgn::freeze $position $tooltipvar
	lset List $position 3 1
}


proc unfreeze {position} {
	variable List

	::application::pgn::unfreeze $position
	lset List $position 3 0

#	set gamebar [::application::pgn::gamebar]
#	if {[::gamebar::size $gamebar] > 1 && ![lindex $List $position 2] && ![lindex $List $position 1]} {
#		::gamebar::remove $gamebar $position
#	}
}


proc load {parent position base args} {
	variable ::scidb::scratchbaseName
	variable Vars

	array set opts {
		-view				-1
		-number			-1
		-fen				""
		-variant			Normal
		-checkEncoding	0
	}
	array set opts $args

	set rc 0

	if {$base eq $scratchbaseName} {
		set Vars(lookup:$position) {}
		set variant [::util::toMainVariant $opts(-variant)]
		::scidb::game::new $position $variant
		set rc 1
	} else {
		set variant [::util::toMainVariant $opts(-variant)]
		set parent [winfo toplevel $parent]
		set options {}
		if {$opts(-view) >= 0} { lappend options -view $opts(-view) }

		if {[catch \
				{ ::scidb::game::load $position $base $variant $opts(-number) $opts(-fen) {*}$options } \
				result options]} {
			array set opts $options
			::dialog::error \
				-parent $parent \
				-message $::import::mc::AbortedDueToInternalError \
				;
			::tk::dialog::error::bgerror $opts(-errorinfo)
			return 0 
		}

		switch $result {
			 1 { set rc 1 }
			-1 { ::dialog::info  -parent $parent -message $mc::GameDecodingFailed }
			-2 { ::dialog::error -parent $parent -message $mc::GameDataCorrupted }
		}

		if {$rc == 1} {
			set Vars(lookup:$position) [list $base $variant $opts(-view) $opts(-number)]

			if {$opts(-checkEncoding)} {
				set baseEncoding [::scidb::db::get encoding $base]
				set gameEncoding [::scidb::game::query $position encoding]

				if {$baseEncoding != $gameEncoding} {
					set fmt [list %base% $baseEncoding %game% $gameEncoding]
					set msg [string map $fmt $mc::GameDecodingChanged]
					set dtl $mc::GameDecodingChangedDetail
					::dialog::info -parent $parent -message $msg -detail $dtl
				}
			}
		}
	}

	return $rc
}


proc setFirst {base variant tags encoding} {
	variable List

	if {[llength $List] == 0} {
		::scidb::db::subscribe gameInfo [namespace current]::Update
		::scidb::db::subscribe gameHistory [namespace current]::UpdateHistory
	}

	if {[llength $List] == 0} { lappend List {} }
	set id [list $base sci 0 $variant]
	set time [clock format [clock seconds] -format {%Y.%m.%d %H:%M:%S}]
	lset List 0 [list $time 0 0 0 $id {0 0} $tags $encoding utf-8]
}


proc release {position} {
	variable List
	variable Vars

	update idletasks ;# fire dangling events
	::scidb::game::release $position
	lset List $position {{} 0 0 0 {{} {} {} {} {}} {0 0} {} {} {}}
	set Vars(lookup:$position) {}
}


proc nextGamePosition {} {
	variable BrowserCount
	return [incr BrowserCount]
}


proc gameList {} {
	variable List

	set list {}

	foreach entry $List {
		lassign [lindex $entry 4] name _ number variant
		lappend list [list $name $variant $number]
	}

	return $list
}


proc closeAll {parent base variant {title ""} {detail ""}} {
	variable List
	variable Options
	variable Priv

	if {[string length $title] == 0} {
		set title $mc::CloseDatabase
	}

	set openGames {}
	set modifiedGames {}
	set pos 0
	set query 1

	foreach entry $List {
		lassign $entry time modified locked frozen database crc tags _
		lassign $database name _ number var

		if {$base eq $name && $variant eq $var} {
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


proc releaseAll {parent base {variant ""}} {
	variable List
	variable Options

	set openGames {}
	set modifiedGames {}
	set pos 0

	foreach entry $List {
		lassign $entry time modified locked frozen database crc tags _
		lassign $database name _ number var

		if {$base eq $name && ([string length $variant] == 0 || $variant eq $var)} {
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
		release $pos	;# release scratch game
	}

	::application::pgn::select
	return 1
}


proc queryCloseApplication {parent} {
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable LockedGames
	variable Selection
	variable List

	set modifiedGames {}
	set LockedGames {}
	set pos 0

	foreach entry $List {
		lassign $entry time modified locked frozen key crc tags encoding
		lassign $key name _ number variant

		if {$modified} {
			if {![::scidb::game::query $pos empty?]} {
				set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $pos] + 1}]
				lappend modifiedGames [list $pos $index $time $name $number $tags]
			}
		} elseif {$locked && $name ne $scratchbaseName && $name ne $clipbaseName} {
			set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $pos] + 1}]
			set cursor [::scidb::game::query $pos current]
			lappend LockedGames [list $index $time $crc $key $encoding $cursor]
		}

		incr pos
	}

	set LockedGames [lsort -index 0 $LockedGames]
	set Selection [::application::pgn::selected]

	if {[llength $modifiedGames] == 0} {
		return discard
	}

	set modifiedGames [lsort -index 1 $modifiedGames]

	append msg $mc::UnsavedGames
	append msg <embed>
	if {[llength $modifiedGames] == 1} {
		append msg $mc::ShouldRestoreGame
	} else {
		append msg $mc::ShouldRestoreGames
	}

	set reply [::dialog::question \
		-parent $parent \
		-message $msg \
		-detail [format $mc::DiscardChanges [::mc::stripAmpersand $::dialog::mc::No]] \
		-buttons {cancel yes no} \
		-embed [namespace code [list EmbedCloseMessage $modifiedGames]] \
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
	variable Header
	variable MaxPosition

	set Recovery [lrepeat $MaxPosition {}]

	for {set i 0} {$i < [llength $List]} {incr i} {
		if {	[llength [lindex $List $i 0]]
			&& [::scidb::game::query $i modified?]
			&& ![::scidb::game::query $i empty?]} {
			lassign [lindex $List $i] time _ _ _ key crc _ encoding
			lassign [::scidb::game::link? $i] _ _ _ crcIndex crcMoves
			set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $i] + 1}]
			set filename [file join $::scidb::dir::backup game-$index.pgn]
			set cursor [::scidb::game::query $i current]
			set comment [lindex $Header 0]
			append comment "\n"
			append comment [lindex $Header 1]
			append comment "\n"
			append comment [list $time $key $crc [list $crcIndex $crcMoves] $encoding $cursor]
			::scidb::game::export $filename -comment $comment -position $i
		}
	}
}


proc recover {parent} {
	variable ::scidb::scratchbaseName
	variable Recovery
	variable Selection
	variable Current
	variable Header
	variable List
	variable Vars

	set count 0
	set pattern game-*.pgn
	if {[::process::testOption recover-old]} { append pattern .bak }

	log::open $mc::Recovery
	set files [lsort -dictionary [glob -directory $::scidb::dir::backup -nocomplain $pattern]]
	set bases {}
	set selection 0

	foreach file $files {
		if {![::process::testOption dont-recover]} {
			if {[file readable $file]} {
				set position [string range [file tail $file] 5 5]
				set chan [open $file r]
				fconfigure $chan -encoding utf-8
				set content [read $chan]
				close $chan

				set header [split $content "\n"]
				lassign {"" "" "" ""} line1 line2 line3 line4
				lassign $header line1 line2 line3 line4
				if {$line1 eq [encoding convertfrom identity "\xef\xbb\xbf"]} {
					set line1 $line2; set line2 $line3; set line3 $line4
				}
				set line1 [string range $line1 2 end]
				set line2 [string range $line2 2 end]
				set line3 [string range $line3 2 end]
				set version [string trim [string range $line2 8 end]]

				if {	$line1 != [lindex $Header 0]
					|| ![regexp {Version ([0-9]+\.[0-9]+)} $line2 _ version]
					|| $version != "1.0"
					|| [catch { set length [llength $line3] }]
					|| $length != 6
					|| [llength [lindex $line3 1]] != 4
					|| [llength [lindex $line3 2]] != 2
					|| [llength [lindex $line3 3]] != 2} {
					::dialog::error \
						-parent $parent \
						-message [format $mc::CorruptedHeader $file] \
						-detail [format $mc::RenamedFile $file] \
						;
				} else {
					lappend Vars(slots) $position
					lassign $line3 time key crc crcLink encoding cursor
					lassign $key base _ index variant
					if {$base ne $scratchbaseName && [lsearch -exact -index 0 $bases $base] == -1} {
						lappend bases [list $base $encoding]
					}
					set Current(file) $file
					set Current(key) $key
					::scidb::game::new $count $variant
					set tags [::scidb::game::tags $count]
					lappend List [list $time 1 0 0 $key $crc $tags $encoding]
					::scidb::game::import $count $content [namespace current]::Log {} \
						-encoding utf-8 \
						-variation 0 \
						-scidb 1 \
						-database $base \
						-index $index \
						-variant $variant \
						;
					Update _ $count
					set tags [lindex $List $count 6]
					::scidb::game::sink $count $base $index {*}$crcLink
					::application::pgn::add $count $base $variant $tags
					::application::pgn::setModified $count
					::scidb::game::modified $count -irreversible yes
					::scidb::game::go trykey $cursor
					if {$position == $Selection} { set selection $count }
					incr count
				}
			} else {
				::dialog::error \
					-parent $parent \
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
		if {[llength $bases] > 0} {
			append msg "\n\n" $mc::OpenAssociatedDatabases
			set reply [::dialog::question -parent $parent -message $msg]
			if {$reply eq "yes"} { OpenAssociatedDatabases $parent $bases }
		} else {
			::dialog::info -parent $parent -message $msg
		}
		::scidb::game::switch $selection
		::application::pgn::select $selection
		::process::setOption "show-board"
	}

	return $count
}


proc reopenLockedGames {parent} {
	variable LockedGames
	variable Selection
	variable Vars
	variable List

	if {[llength $LockedGames] == 0} { return 0 }

	set lockedGames $LockedGames
	set LockedGames {}

	set reply [::dialog::question -parent $parent -message $mc::ReopenLockedGames -default yes]
	if {$reply eq "no"} { UnlockGames; return 0 }

	set selection -1
	set count [llength $Vars(slots)]
	set bases {}
	set Vars(slots) [lsort -integer -decreasing $Vars(slots)]

	foreach entry $lockedGames {
		lassign $entry _ _ _ key encoding _
		set base [lindex $key 0]

		if {[lsearch -exact -index 0 $bases $base] == -1} {
			lappend bases [list $base $encoding]
		}
	}

	OpenAssociatedDatabases $parent $bases

	foreach entry $lockedGames {
		lassign $entry position time crc key encoding cursor
		lassign $key base _ number variant

		if {![::scidb::db::get open? $base]} {
			# Log: cannot open anymore
			continue
		}

		::scidb::game::new $count $variant

		if {[load $parent $count $base -variant $variant -number $number]} {
			set at {}
			set i [expr {$count - 1}]
			foreach slot $Vars(slots) {
				if {$position < $slot} { set at $i }
			}

			set tags [::scidb::game::tags $count]
			lappend List [list $time 0 1 0 $key $crc $tags]
			Update _ $count
			::application::pgn::add $count $base $variant $tags {*}$at
			::application::pgn::lock $count
			::scidb::game::go trykey $cursor
			::process::setOption "show-board"
			if {$position == $Selection} { set selection $count }
			incr count
		} else {
			# Log: couldn't load game
			::scidb::game::release $count
		}
	}

	if {$selection >= 0} {
		::scidb::game::switch $selection
		::application::pgn::select $selection
	}

	return $count
}


proc traverseHistory {headerScript gameScript} {
	variable History
	variable List

	set myList {}
	set count 0

	foreach entry $History {
		if {[lsearch -exact -index 4 $List [lindex $entry 1]] == -1} {
			lassign $entry tags key 
			set base [lindex $key 0]
			set i [lsearch -exact $myList $base]
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
	lassign $base base codec number variant
	set rc 1
	set parent [winfo toplevel $parent]

	if {[::application::database::openBase $parent $base no -encoding $encoding -variant $variant]} {
		if {$variant ni [::scidb::db::get variants $base]} {
			::dialog::warning -buttons {ok} -parent $parent -message $mc::VariantHasChanged
			set rc 0
		} elseif {$number >= [::scidb::db::count games $base $variant]} {
			set map [list %number [expr {$number + 1}] %base $base]
			set msg [string map $map $mc::GameNumberDoesNotExist]
			::dialog::error -parent $parent -message $msg
			set rc 0
		} else {
			set pos [new $parent -base $base -number $number -variant $variant]
			if {$pos >= 0} {
				set crcLoad [lindex $List $pos 5]
				if {$crcLoad ne $crcHist} {
					# TODO: open new slot iff only crc-index differs
					set msg [format $mc::GameHasChanged [expr {$number + 1}]]
					set det $mc::GameHasChangedDetail
					::dialog::warning -buttons {ok} -parent $parent -message $msg -detail $det
				}
			} elseif {$pos == -1} {
				set rc 0
			}
		}
	} else {
		set rc -1
	}

	if {$rc == 0} {
		set reply [::dialog::question -parent $parent -message $mc::RemoveGameFromHistory -default yes]
		if {$reply eq "yes"} {
			set History [lreplace $History $index $index]
			::application::pgn::historyChanged
		}
	}

	return [expr {$rc > 0}]
}


proc embedReleaseMessage {positions w infoFont alertFont} {
	variable ::gamebar::icon::15x15::digit
	variable List

	set list {}
	foreach pos $positions {
		set index [expr {[::gamebar::getIndex [::application::pgn::gamebar] $pos] + 1}]
		lappend list [list $pos $index]
	}
	set list [lsort -index 1 -integer $list]

	set row 0
	grid columnconfigure $w {1 3} -minsize 5

	foreach entry $list {
		lassign $entry pos index
		lassign {"?" "?"} white black
		foreach pair [::game::tags? $pos] {
			lassign $pair name value
			switch $name {
				White { set white $value }
				Black { set black $value }
			}
		}

		set col(1) "$white \u2013 $black"
		set col(2) "(#[expr {[::game::number? $pos] + 1}])"

		grid [tk::label $w.line-$row-0 -image $digit($index)] -row $row -column 0 -sticky w
		grid [tk::label $w.line-$row-1 -text $col(1) -font $infoFont] -row $row -column 2 -sticky w
		grid [tk::label $w.line-$row-2 -text $col(2) -font $infoFont] -row $row -column 4 -sticky w

		incr row
	}
}


proc UnlockGames {} {
	variable LockedGames
	variable List

	set LockedGames {}

	for {set i 0} {$i < [llength $List]} {incr i} {
		lset List $i 3 0
	}
}


proc OpenAssociatedDatabases {parent bases} {
	foreach entry $bases {
		lassign $entry base encoding

		if {![file exists $base]} {
			# Log problem
		} elseif {![::application::database::openBase $parent $base no -encoding $encoding]} {
			# Log problem
		}
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
	grid columnconfigure $w {6} -weight 1

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
			grid $text -row $row -column 1 -columnspan 5 -sticky w
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
		append msg " - "
		append msg [lindex $Current(key) 3]
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
		set key    [lindex $List $position 4]
		set tags   [::scidb::game::tags $position]

		lassign [::scidb::game::link? $position] base variant number

		set i [lsearch -exact -index 1 $History $key]
		if {$i >= 0} {
			set filename [lindex $History $i 1 0]
			set var [lindex $History $i 1 3]
			if {$base eq $filename && $variant eq $var} {
				set History [lreplace $History $i $i]
			}
		}

		if {[::scidb::db::get open? $base $variant]} {
			set codec [::scidb::db::get codec $base $variant]
		} else {
			set codec sci
			set variant Normal
		}

		lset List $position 4 0 $base
		lset List $position 4 1 $codec
		lset List $position 4 2 $number
		lset List $position 4 3 [::scidb::game::query $position variant?]
		lset List $position 1 [::scidb::game::query $position modified?]
		lset List $position 5 [::scidb::game::query $position checksum]
		lset List $position 6 $tags

		if {[::scidb::db::get open? $base $variant]} {
			UpdateHistoryEntry $position $base $variant $tags
		}
	}
}


proc UpdateHistory {_ base variant index} {
	variable History

	for {set i 0} {$i < [llength $History]} {incr i} {
		lassign [lindex $History $i] info key crcHist _
		lassign $key filename codec number var

		if {$base eq $filename && $variant eq $var && $index eq $number} {
			set tags [::scidb::db::get tags $index $base $variant]
			set info {}

			foreach pair $tags {
				lassign $pair name value
				set lookup($name) $value
			}
			foreach name {Event Site Date Round White Black Result} { lappend info $lookup($name) }

			lset History $i 0 $info
			lset History $i 2 [list [::scidb::db::get checksum $index $base $variant] [lindex $crcHist 1]]
			lset History $i 3 [::scidb::db::get usedencoding $base]
		}
	}
}


proc UpdateHistoryEntry {pos base variant tags} {
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable List
	variable History
	variable HistorySize

	if {[llength $tags] == 0} { return }
	if {[string length [file extension $base]] == 0} { return }

	foreach pair $tags {
		lassign $pair name value
		set lookup($name) $value
	}
	set info {}
	set encoding [::scidb::db::get usedencoding $base]
	foreach name {Event Site Date Round White Black Result} { lappend info $lookup($name) }
	set entry [list $info [lindex $List $pos 4] [lindex $List $pos 5] $encoding]

	set i 0
	set k -1
	while {$i < [llength $History]} {
		set i [lsearch -exact -index 0 -start $i $History $info]
		if {$i == -1} { break }
		if {$base eq [lindex $History $i 1 0] && $variant eq [lindex $History $i 1 3]} { set k $i }
		incr i
	}

	if {$k >= 0 && $base eq [lindex $List $pos 4 0] && $variant eq [lindex $List $pos 4 3]} {
		if {$k == -1} { set k end }
		set History [lreplace $History $k $k]
	}

	while {[llength $History] >= $HistorySize} {
		set History [lreplace $History end end]
	}

	set History [linsert $History 0 $entry]
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::History
	::options::writeList $chan [namespace current]::LockedGames
	::options::writeItem $chan [namespace current]::Options
	::options::writeItem $chan [namespace current]::Selection
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace game

# vi:set ts=3 sw=3:
