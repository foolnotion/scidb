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

namespace eval import {
namespace eval mc {

set ImportingPgnFile						"Importing PGN file %s"
set Line										"Line"
set Column									"Column"
set GameNumber								"Game"
set ImportedGames							"%s game(s) imported"
set NoGamesImported						"No games imported"
set FileIsEmpty							"file is possibly empty"
set PgnImport								"PGN Import"
set ImportPgnGame							"Import PGN Game"
set ImportPgnVariation					"Import PGN Variation"
set ImportOK								"PGN text imported with no errors or warnings."
set ImportAborted							"Import aborted."
set TextIsEmpty							"PGN text is empty."
set AbortImport							"Abort PGN import?"
set SelectEncoding						"Select encoding"

set EnterOrPaste							"Enter or paste a PGN-format %s in the frame above.\nAny errors importing the %s will be displayed here."
set EnterOrPaste-Game					"game"
set EnterOrPaste-Variation				"variation"

set MissingWhitePlayerTag				"Missing white player"
set MissingBlackPlayerTag				"Missing black player"
set MissingPlayerTags					"Missing players"
set MissingResult							"Missing result (at end of move section)"
set MissingResultTag						"Missing result (in tag section)"
set InvalidRoundTag						"Invalid round tag"
set InvalidResultTag						"Invalid result tag"
set InvalidDateTag						"Invalid date tag"
set InvalidEventDateTag					"Invalid event date tag"
set InvalidTimeModeTag					"Invalid time mode tag"
set InvalidEcoTag							"Invalid ECO tag"
set InvalidTagName						"Invalid tag name"
set InvalidCountryCode					"Invalid country code"
set InvalidRating							"Invalid rating value"
set InvalidNag								"Invalid NAG"
set MissingFen								"Missing FEN (variant tag will be ignored)"
set UnknownEventType						"Unknown event type"
set UnknownTitle							"Unknown title (ignored)"
set UnknownPlayerType					"Unknown player type (ignored)"
set UnknownSex								"Unknown sex (ignored)"
set UnknownTermination					"Unknown termination reason"
set UnknownMode							"Unknown mode"
set RatingTooHigh							"Rating too high (ignored)"
set EncodingFailed						"Encoding failed"
set TooManyNags							"Too many NAG's (latter ignored)"
set IllegalCastling						"Illegal castling"
set IllegalMove							"Illegal move"
set UnsupportedVariant					"Unsupported chess variant"
set DecodingFailed						"Decoding failed"
set ResultDidNotMatchHeaderResult	"Result did not match header result"
set ValueTooLong							"Tag value is too long and will truncated to 255 characacters"
set CommentAtEndOfGame					"Comment at end of game inserted as sub-variation"
set MaximalErrorCountExceeded			"Maximal error count (of previous error type) exceeded"
set MaximalWarningCountExceeded		"Maximal warning count (of previous warning type) exceeded"
set InvalidToken							"Invalid token"
set InvalidMove							"Invalid move"
set UnexpectedSymbol						"Unexpected symbol"
set UnexpectedEndOfInput				"Unexpected end of input"
set UnexpectedResultToken				"Unexpected result token"
set UnexpectedTag							"Unexpected tag inside game"
set UnexpectedEndOfGame					"Unexpected end of game (missing result)"
set TagNameExpected						"Syntax error: Tag name expected"
set TagValueExpected						"Syntax error: Tag value expected"
set InvalidFen								"Invalid FEN"
set UnterminatedString					"Unterminated string"
set UnterminatedVariation				"Unterminated variation"
set TooManyGames							"Too many games in database (aborted)"
set GameTooLong							"Game too long (skipped)"
set FileSizeExceeded						"Maximal file size (2GB) will be exceeded (abort)"
set TooManyPlayerNames					"Too many player names in database (aborted)"
set TooManyEventNames					"Too many event names in database (aborted)"
set TooManySiteNames						"Too many site names in database (aborted)"
set TooManyRoundNames					"Too many round names in database (aborted)"
set TooManyAnnotatorNames				"Too many annotator names in database (aborted)"
set TooManySourceNames					"Too many source names in database (aborted)"
set SeemsNotToBePgnText					"Seems not to be PGN text"

}

variable Background			#ebf4f5
variable SelectBackground	#ffdd76
variable HiliteBackground	linen


proc open {parent base files msg {encoding {}} {type {}} {useLog 1}} {
	::remote::busyOperation \
		[list [namespace current]::Open $parent $base $files $msg $encoding $type $useLog]
}


proc openEdit {parent position {mode {}}} {
	variable Priv
	variable Background
	variable SelectBackground
	variable HiliteBackground
	variable ::log::colors

	set Priv($position:encoding) iso8859-1
	if {[string length $mode]} {
		set used 1
	} else {
		set used 0
		set mode game
	}

	set dlg [toplevel ${parent}.importOnePgnGame${position} -class Scidb]
	set top [ttk::frame $dlg.top]
	set lbl [ttk::label $top.figurinesText -textvar ::export::mc::Figurines]
	set fig [ttk::tcombobox $top.figurines \
					-state readonly \
					-showcolumns {lang fig} \
					-format "%1 (%2)" \
					-width 26 \
				]
	set lab [ttk::label $top.encodingText -textvar ::encoding::mc::Encoding]
	set enc [tk::entry $top.encoding \
		-state readonly \
		-textvar [namespace current]::Priv($position:encoding) \
	]
	set but [tk::button $top.choose \
					-height 13 \
					-image $::icon::15x13::list \
					-command [namespace code [list ChooseEncoding $top.choose $position]] \
				]
	::theme::configureBackground $but
	set main [panedwindow $top.main -orient vertical -opaqueresize true]
	::tooltip::tooltip $but [namespace current]::mc::SelectEncoding

	$fig addcol text  -id fig -font TkFixedFont -font2 $::font::figurine
	$fig addcol image -id flag
	$fig addcol text  -id lang

	bind $fig <<ComboboxCurrent>> [namespace code [list ShowCountry $fig $position]]

	set gamebar [::application::pgn::gamebar]
	set recv [namespace code [list GamebarChanged $dlg $position]]
	::gamebar::addReceiver $gamebar $recv
	bind $dlg <Destroy> [list ::gamebar::removeReceiver $gamebar $recv]
	bind $dlg <<Language>> [namespace code [list LanguageChanged $dlg %W $position]]

	# text editor
	set edit [ttk::frame $main.edit]
	tk::text $edit.text \
		-width 80 \
		-height 20 \
		-undo on \
		-maxundo 10 \
		-yscroll [list $edit.ybar set] \
		;
	$edit.text tag configure hilite -background $HiliteBackground
	ttk::scrollbar $edit.ybar -command [list $edit.text yview] -takefocus 0
	pack $edit.ybar -side right -fill y
	pack $edit.text -side left -expand true -fill both
	$main paneconfigure $edit -sticky nswe -minsize 20 -stretch always
	$main add $edit

	# log window
	set log [ttk::frame $main.log]
	tk::listbox $log.text \
		-background $Background \
		-selectbackground $SelectBackground \
		-height 4 \
		-yscroll [list $log.ybar set] \
		-takefocus 0 \
		-selectmode single \
		-state disabled \
		-disabledforeground $colors(info) \
		-exportselection 0 \
		;
	bind $log.text <<ListboxSelect>> [namespace code [list ListboxSelect $position]]
	ttk::scrollbar $log.ybar -command [list $log.text yview] -takefocus 0
	pack $log.ybar -side right -fill y
	pack $log.text -side left -expand true -fill both
	$main paneconfigure $log -sticky nswe -minsize 20 -stretch never
	$main add $log

	set Priv($position:log) $log.text
	set Priv($position:txt) $edit.text
	set Priv($position:used) $used
	set Priv($position:values) {}
	set Priv($position:mode) $mode
	set Priv($position:varno) -1
	set Priv($position:figurines) $fig

	pack $top -expand yes -fill both

	grid $lbl  -row 1 -column 0 -sticky w
	grid $fig  -row 1 -column 2 -sticky w
	grid $lab  -row 1 -column 4 -sticky w
	grid $enc  -row 1 -column 6 -sticky w
	grid $but  -row 1 -column 8 -sticky wns
	grid $main -row 3 -column 0 -sticky ewns -columnspan 10
	grid rowconfigure $top 3 -weight 1
	grid rowconfigure $top {0 2} -minsize 5
	grid columnconfigure $top 9 -weight 1
	grid columnconfigure $top {1 5} -minsize $::theme::padding
	grid columnconfigure $top 7 -minsize 4
	grid columnconfigure $top 3 -minsize [expr {2*$::theme::padding}]

	::widget::dialogButtons $dlg {import close} import
	bind $dlg <Return> {}
	$dlg.import configure -command [namespace code [list Import $position $dlg]]
	$dlg.close configure -command [namespace code [list Close $position $dlg]]
	bind $dlg <Escape> [namespace code [list AskAbort $position $dlg.close]]

	# editor bindings
	bind $edit.text <ButtonPress-3> [namespace code [list PopupMenu $edit $position %X %Y]]
	bind $edit.text <<PasteSelection>> [namespace code [list TextPasteSelection $position %W %x %y]]
	bind $edit.text <<PasteSelection>> {+ break }
	bind $edit.text <Key-Tab> {after idle { focus [::tk_focusNext %W] } }
	bind $edit.text <Key-Tab> {+ break }
	bind $edit.text <Shift-Tab> {after idle { focus [::tk_focusPrev %W] } }
	bind $edit.text <Shift-Tab> {+ break }

	Clear $position
	SetFigurines $dlg $position

	wm withdraw $dlg
	::util::place $dlg center [winfo toplevel $parent]
	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list Close $position $dlg]]
	SetTitle $dlg $position
	update idletasks
	wm minsize $dlg [winfo width $dlg] [winfo height $dlg]
	wm resizable $dlg true true
	wm deiconify $dlg
	focus $edit.text

	$main paneconfigure $log -minsize [winfo reqheight $log.text]
	$main paneconfigure $edit -minsize [winfo reqheight $log.text]

	if {$used} {
		ttk::grabWindow $dlg
		wm transient $dlg $parent
		tkwait window $dlg
		ttk::releaseGrab $dlg
	}
}


proc makeLog {arguments} {
	variable Priv

	lassign $arguments type lineNo column gameNo msg code info item
	set line ""

	if {$code eq "SeemsNotToBePgnText"} { set Priv(ok) 0 }

	append line $mc::Line " " [::locale::formatNumber $lineNo]
	if {$column} {
		append line " (" $mc::Column " " [::locale::formatNumber $column] ")"
	}
	if {$Priv(gameNo) && [llength $gameNo] && $gameNo > 0} {
		append line " " $mc::GameNumber " " [::locale::formatNumber $gameNo]
	}
	append line ": "

	if {[::info exists [namespace current]::mc::$code]} {
		append line [set mc::$code]
	} else {
		append line $code
	}

	if {[llength $item]} {
		append line ": " $item
	}

	return $line
}


proc Open {parent base files msg encoding type useLog} {
	variable Priv

	if {[llength $files] == 0} { return 0 }

	set Priv(ok) 1
	set Priv(gameNo) 1
	if {[llength $encoding] == 0} {
		set encoding $::encoding::defaultEncoding
	}

	if {[llength $type]} {
		::scidb::db::new $base $type
	}
	::log::open $mc::PgnImport

	set ngames [::scidb::db::count games $base]

	foreach file $files {
		::log::info [format $mc::ImportingPgnFile $file]
		set cmd [list ::scidb::db::import $base $file [namespace current]::Log log]
		set options [list -message $msg -log $useLog]
		set count [::progress::start $parent.progress $cmd [list -encoding $encoding] $options 0]
		update idletasks	;# be sure the following will be appended

		if {$count == 0} {
			set msg $mc::NoGamesImported
			if {$Priv(ok)} { append msg " ($mc::FileIsEmpty)" }
			::log::info $msg
		} else {
			::log::info	[format $mc::ImportedGames [::locale::formatNumber $count]]
		}
	}

	set cmd [list ::scidb::db::save $base $ngames]
	::progress::start $parent.progress $cmd {} {} 1
	::log::close

	return $Priv(ok)
}



proc PopupMenu {edit position x y} {
	set m $edit.menu
	catch { destroy $m }
	menu $m -tearoff 0
	$m add command -label $mc::Cut -command [list tk_textCut $edit.text]
	$m add command -label $mc::Copy -command [list tk_textCopy $edit.text]
	$m add command -label $mc::Paste -command [namespace code [list TextPaste $position $edit.text]]
	$m add command -label $mc::SelectAll -command [list $edit.text tag add sel 1.0 end]
	$m add command -label $mc::Clear -command [namespace code [list Clear $position]]
	tk_popup $m $x $y
}


proc Close {position dlg} {
	variable Priv

	if {!$Priv($position:used)} {
		::application::pgn::release $position
	}

	destroy $dlg
}


proc AskAbort {position closeButton} {
	variable Priv

	set txt $Priv($position:txt)
	set content [string trim [$txt get 1.0 end]]

	if {[string length $content] > 0} {
		if {[dialog::question \
				-parent [winfo toplevel $closeButton] \
				-title $::scidb::app \
				-message $mc::AbortImport] eq "yes"} {
			Close $position [winfo toplevel $closeButton]
		}
	} else {
		$closeButton invoke
	}
}


proc ConvertPastedText {position str} {
	variable Priv

	set figurine [$Priv($position:figurines) get fig]
	set unicodeMap [list \
		"\u2654" [string index $figurine 0] \
		"\u2655" [string index $figurine 1] \
		"\u2656" [string index $figurine 2] \
		"\u2657" [string index $figurine 3] \
		"\u2658" [string index $figurine 4] \
		"\u2659" [string index $figurine 5] \
	]

	set str [string map $unicodeMap $str]
	set str [string trimleft $str]
	return [encoding convertfrom $Priv($position:encoding) $str]
}


proc TextPaste {position w} {
	global tcl_platform

	if {![catch {::tk::GetSelection $w CLIPBOARD} sel]} {
		if {[tk windowingsystem] ne "x11"} {
			catch { $w delete sel.first sel.last }
		}
		$w insert insert [ConvertPastedText $position $sel]
		$w edit reset
	}
}


proc TextPasteSelection {position w x y} {
	if {![::info exists ::tk::Priv(mouseMoved)] || !$::tk::Priv(mouseMoved)} {
		$w mark set insert [::tk::TextClosestGap $w $x $y]
		if {![catch {::tk::GetSelection $w PRIMARY} sel]} {
			$w insert insert [ConvertPastedText $position $sel]
			$w edit reset
			if {[$w cget -state] eq "normal"} { focus $w }
		}
	}
}


proc SetTitle {dlg position} {
	variable Priv

	if {$Priv($position:mode) eq "game"} {
		set title "$mc::ImportPgnGame"
	} else {
		set title [format $mc::ImportPgnVariation $::mc::Variation]
	}
	set number [expr {[::gamebar::getIndex [::application::pgn::gamebar] $position] + 1}]
	wm title $dlg "$::scidb::app - $title ($number)"
}


proc GamebarChanged {dlg position action id} {
	if {$action eq "removed"} {
		if {$position == $id} {
			destroy $dlg
		} else {
			SetTitle $dlg $position
		}
	}
}


proc SetFigurines {dlg position} {
	variable Figurines
	variable Priv

	set w $Priv($position:figurines)
	set index [lsearch -exact -index 1 $Priv($position:values) [lindex [$w get] 0]]
	set current [lindex $Priv($position:values) $index 0]
	set Priv($position:values) {}
	foreach {lang figurine} [array get ::font::figurines] {
		switch $lang {
			en - graphic {}

			default {
				if {[string bytelength $figurine] == 6} {
					lappend Priv($position:values) [list $lang [::encoding::languageName $lang] $figurine]
				}
			}
		}
	}
	set Priv($position:values) [lsort -index 1 -dictionary $Priv($position:values)]
	set value [list en [::encoding::languageName en] $::font::figurines(en)]
	set Priv($position:values) [linsert $Priv($position:values) 0 $value]
	set index [lsearch -index 0 -exact $Priv($position:values) $current]
	if {$index == -1} { set index 0 }
	set Figurines {}
	set item 0
	foreach entry $Priv($position:values) {
		lappend Figurines [lindex $entry 1]
		lassign $entry id lang fig
		set flag $::country::icon::flag($::mc::langToCountry($id))
		$w listinsert [list $fig $flag $lang] -index $item
		incr item
	}
	$w resize
	$w current $index
}


proc ChooseEncoding {btn position} {
	variable Priv

	set encoding [::encoding::choose [winfo toplevel $btn] $Priv($position:encoding) iso8859-1]
	if {[llength $encoding]} { set Priv($position:encoding) $encoding }
}


proc LanguageChanged {dlg w position} {
	variable Priv

	if {$dlg eq $w} {
		GamebarChanged $dlg $position {}
		SetFigurines $dlg $position
		SetTitle $dlg $position

		set txt $Priv($position:txt)
		set content [string trim [$txt get 1.0 end]]
		if {[string length $content] == 0} { Clear $position }
	}
}


proc CountSubsts {str} {
	set count 0
	set index [string first %s $str]

	while {$index >= 0} {
		incr count
		set index [string first %s $str [incr index 2]]
	}

	return $count
}


proc Clear {position} {
	variable Priv

	set txt $Priv($position:txt)
	set log $Priv($position:log)

	$txt delete 1.0 end
	$txt edit reset
	$txt mark unset {*}[$txt mark names]
	$log configure -state normal
	$log delete 0 end

	set mode [set mc::EnterOrPaste-[string toupper $Priv($position:mode) 0 0]]
	set args [lrepeat [CountSubsts $mc::EnterOrPaste] $mode]
	set text [format $mc::EnterOrPaste {*}$args]
	foreach line [split $text "\n"] {
		$log insert end $line
	}

	$log configure -state disabled -takefocus 0
}


proc ShowCountry {w position} {
	variable Priv

	set i [lsearch -exact -index 1 $Priv($position:values) [$w get lang]]
	$w placeicon $::country::icon::flag($::mc::langToCountry([lindex $Priv($position:values) $i 0]))
}


proc Import {position dlg} {
	variable Priv
	variable ::log::colors

	set Priv(position) $position
	set Priv(gameNo) 0
	set Priv(first) -1

	set txt $Priv($position:txt)
	set log $Priv($position:log)

	$txt mark unset {*}[$txt mark names]
	$txt tag remove hilite 1.0 end
	$log configure -state normal -takefocus 1
	$log delete 0 end
	set content [$txt get 1.0 end]
	set figurine [$Priv($position:figurines) get fig]
	if {$Priv($position:mode) eq "game"} { set isVar 0 } else { set isVar 1 }

	set n [::scidb::game::import \
				$position \
				$content \
				[namespace current]::Log import \
				-encoding utf-8 \
				-figurine $figurine \
				-variation $isVar \
				-varno $Priv($position:varno) \
			]
	
	if {$isVar && $n >= 0} {
		set Priv($position:varno) $n
		set n 1
	}
	
	if {$n <= 0} {
		if {[string length [string trim $content]] == 0} {
			Show info $mc::TextIsEmpty
			$log configure -state disabled -takefocus 0
		} elseif {[$log index end] == 0} {
			Show info "$mc::SeemsNotToBePgnText."
			$log configure -state disabled -takefocus 0
		} else {
			Show info $mc::ImportAborted
			$log selection set $Priv(first)
			ListboxSelect $position
		}
	} else {
		if {[$log index end] == 0} {
			Show info $mc::ImportOK
			$log configure -state disabled -takefocus 0
			set Priv($position:used) 1
		} elseif {$Priv(first) >= 0} {
			$log selection set $Priv(first)
			ListboxSelect $position
			set Priv($position:used) 1
		}
	}
}


proc ListboxSelect {position} {
	variable Priv

	set txt $Priv($position:txt)
	set log $Priv($position:log)

	if {[$log cget -state] eq "disabled"} { return }

	$txt tag remove hilite 1.0 end
	set mark pos:[$log curselection]

	if {$mark in [$txt mark names]} {
		set index [$txt index $mark]
		set lineNo [lindex [split $index .] 0]
		$txt tag add hilite $lineNo.0 [expr {$lineNo + 1}].0
		$txt mark set current $index
		$txt mark set insert $index
		$txt see $index
		after idle [list focus $txt]
	}
}


proc Show {type line} {
	variable Priv
	variable ::log::colors

	set position $Priv(position)

	set log $Priv($position:log)
	set txt $Priv($position:txt)

	set line [string trim $line]
	set lineNo 0
	set colNo 0
	regexp {^.* ([0-9]+) \(.* ([0-9]+)\):} $line unused lineNo colNo

	if {$lineNo == 0} {
		regexp {^.* ([0-9]+):} $line unused lineNo
	}

	if {$lineNo > 0} {
		if {$colNo > 0} { incr colNo -1 }
		set index [$log index end]
		$txt mark set pos:$index $lineNo.$colNo
		if {$Priv(first) == -1} { set Priv(first) $index }
	}

	$log insert end $line
	$log itemconfigure end -foreground $colors($type) -selectforeground $colors($type)
	$log yview moveto 1.0
}


# These procs are private although the names are starting with a lowercase.
proc warning {line}	{ Show warning $line }
proc error {line}		{ Show error $line }
proc info {line}		{ Show info $line }


proc Log {sink arguments} {
	set type [lindex $arguments 0]
	::${sink}::${type} [makeLog $arguments]
	update idletasks
}

} ;# namespace import

# vi:set ts=3 sw=3:
