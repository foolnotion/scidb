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

::util::source import-dialog

namespace eval import {
namespace eval mc {

set ImportingPgnFile						"Importing PGN files"
set ImportingDatabase					"Importing databases"
set Line										"Line"
set Column									"Column"
set GameNumber								"Game"
set ImportedGames							"%s game(s) imported"
set NoGamesImported						"No games imported"
set FileIsEmpty							"file is possibly empty"
set DatabaseImport						"PGN Import"
set ImportPgnGame							"Import PGN Game"
set ImportPgnVariation					"Import PGN Variation"
set ImportOK								"PGN text imported with no errors or warnings."
set ImportAborted							"Import aborted."
set TextIsEmpty							"PGN text is empty."
set AbortImport							"Abort PGN import?"
set UnsupportedVariantRejected		"Unsuported variant '%s' rejected"
set Accepted								"accepted"
set Rejected								"rejected"

set DifferentEncoding					"Selected encoding %src does not match file encoding %dst."
set DifferentEncodingDetails			"Recoding of the database will not be successful anymore after this action."
set CannotDetectFigurineSet			"Cannot auto-detect a suitable figurine set."
set TryAgainWithEnglishSet				"Try again with English figurines?"
set TryAgainWithEnglishSetDetail		"It may be helpful to use English figurines, because this is standard in PGN format."
set CheckImportResult					"Please check whether the right figurine set is detected: %s."
set CheckImportResultDetail			"In seldom cases the auto-detection fails due to ambiguities."

set EnterOrPaste							"Enter or paste a PGN-format %s in the frame above.\nAny errors importing the %s will be displayed here."
set EnterOrPaste-Game					"game"
set EnterOrPaste-Variation				"variation"

set AbortedDueToInternalError			"Aborted due to an internal error"
set AbortedDueToIoError					"Aborted due to an I/O error"
set UserHasInterrupted					"User has interrupted"

set State(UnsupportedVariant)			"Unsuported variant rejected"
set State(DecodingFailed)				"Decoding of this game was not possible"
set State(TooManyGames)					"Too many games in database (aborted)"
set State(FileSizeExceeded)			"Maximal file size (2GB) will be exceeded (abort)"
set State(GameTooLong)					"Game too long (skipped)"
set State(TooManyPlayerNames)			"Too many player names in database (aborted)"
set State(TooManyEventNames)			"Too many event names in database (aborted)"
set State(TooManySiteNames)			"Too many site names in database (aborted)"
set State(TooManyRoundNames)			"Too many round names in database"
set State(TooManyAnnotatorNames)		"Too many annotator names in database (aborted)"
set State(TooManySourceNames)			"Too many source names in database (aborted)"

set Warning(MissingWhitePlayerTag)				"Missing white player"
set Warning(MissingBlackPlayerTag)				"Missing black player"
set Warning(MissingPlayerTags)					"Missing players"
set Warning(MissingResult)							"Missing result (at end of move section)"
set Warning(MissingResultTag)						"Missing result (in tag section)"
set Warning(InvalidRoundTag)						"Invalid round tag"
set Warning(InvalidResultTag)						"Invalid result tag"
set Warning(InvalidDateTag)						"Invalid date tag"
set Warning(InvalidEventDateTag)					"Invalid event date tag"
set Warning(InvalidTimeModeTag)					"Invalid time mode tag"
set Warning(InvalidEcoTag)							"Invalid ECO tag"
set Warning(InvalidTagName)						"Invalid tag name"
set Warning(InvalidCountryCode)					"Invalid country code"
set Warning(InvalidRating)							"Invalid rating value"
set Warning(InvalidNag)								"Invalid NAG"
set Warning(BraceSeenOutsideComment)			"\"\}\" seen outside a comment in game"
set Warning(MissingFen)								"Missing FEN (variant tag will be ignored)"
set Warning(UnknownEventType)						"Unknown event type"
set Warning(UnknownTitle)							"Unknown title (ignored)"
set Warning(UnknownPlayerType)					"Unknown player type (ignored)"
set Warning(UnknownSex)								"Unknown sex (ignored)"
set Warning(UnknownTermination)					"Unknown termination reason"
set Warning(UnknownMode)							"Unknown mode"
set Warning(RatingTooHigh)							"Rating too high (ignored)"
set Warning(EncodingFailed)						"Character decoding failed"
set Warning(TooManyNags)							"Too many NAG's (latter ignored)"
set Warning(IllegalCastling)						"Illegal castling"
set Warning(IllegalMove)							"Illegal move"
set Warning(CastlingCorrection)					"Castling correction"
set Warning(ResultDidNotMatchHeaderResult)	"Result did not match header result"
set Warning(ValueTooLong)							"Tag value is too long and will truncated to 255 characacters"
set Warning(NotSuicideNotGiveaway)				"Due to the outcome of the game the variant isn't either Suicide or Giveaway."
set Warning(VariantChangedToGiveaway)			"Due to the outcome of the game the variant has been changed to Giveaway"
set Warning(VariantChangedToSuicide)			"Due to the outcome of the game the variant has been changed to Suicide"
set Warning(ResultCorrection)						"Due to the final position of the game a correction of the result has been done"
set Warning(MaximalErrorCountExceeded)			"Maximal error count (of previous error type) exceeded"
set Warning(MaximalWarningCountExceeded)		"Maximal warning count (of previous warning type) exceeded"

set Error(InvalidToken)								"Invalid token"
set Error(InvalidMove)								"Invalid move"
set Error(UnexpectedSymbol)						"Unexpected symbol"
set Error(UnexpectedEndOfInput)					"Unexpected end of input"
set Error(UnexpectedResultToken)					"Unexpected result token"
set Error(UnexpectedTag)							"Unexpected tag inside game"
set Error(UnexpectedEndOfGame)					"Unexpected end of game (missing result)"
set Error(UnexpectedCastling)						"Unexpected castling (not allowed in this chess variant)"
set Error(ContinuationsNotSupported)			"'Continuations' not supported"
set Error(TagNameExpected)							"Syntax error: Tag name expected"
set Error(TagValueExpected)						"Syntax error: Tag value expected"
set Error(InvalidFen)								"Invalid FEN"
set Error(UnterminatedString)						"Unterminated string"
set Error(UnterminatedVariation)					"Unterminated variation"
set Error(SeemsNotToBePgnText)					"Seems not to be PGN text"

}

array set Colors {
	background			import,background
	background:select	import,background:select
	background:hilite	import,background:hilite
}

variable Variants {Undetermined Normal ThreeCheck Crazyhouse Suicide Giveaway Losers}


proc import {parent base files msg {encoding {}}} {
	if {[llength $files] == 0} { return 0 }
	::remote::busyOperation { Import $parent $base $files $msg $encoding }
}


proc open {parent file msg encoding type} {
	::remote::busyOperation { Open $parent $file $msg $encoding $type }
}


proc openEdit {parent position args} {
	variable Priv
	variable Colors
	variable ::log::colors

	array set opts {
		-mode		{}
		-variant	{}
	}
	array set opts $args

	set Priv($position:encoding) $::encoding::autoEncoding
	set Priv($position:encodingVar) $::encoding::mc::AutoDetect

	if {[string length $opts(-mode)]} {
		set used 1
	} else {
		set used 0
		set opts(-mode) game
	}

	set dlg [tk::toplevel ${parent}.importOnePgnGame${position} -class Scidb]
	set top [ttk::frame $dlg.top]
	set vlb [ttk::label $top.variantsText -textvariable ::mc::Variant]
	if {$opts(-mode) eq "game"} {
		set var [ttk::tcombobox $top.variants -state readonly -showcolumns name -format "%1" -width 26]
	} else {
		set var [::ttk::label $top.variants -text $opts(-variant)]
	}
	set lbl [ttk::label $top.figurinesText -textvariable ::export::mc::Figurines]
	set fig [ttk::tcombobox $top.figurines \
					-state readonly \
					-showcolumns {lang fig} \
					-format "%1 (%2)" \
					-width 26 \
				]
	set elb [ttk::label $top.encodingText -textvariable ::encoding::mc::Encoding]
	set enc [ttk::entrybuttonbox $top.encoding \
		-textvariable [namespace current]::Priv($position:encodingVar) \
		-command [namespace code [list ChooseEncoding $top.encoding $position]] \
	]
	set main [tk::panedwindow $top.main -orient vertical -opaqueresize true]

	set specialfont [list [list $::font::figurine(text:normal) 9812 9823]]
	$fig addcol text  -id fig -font TkFixedFont -specialfont $specialfont
	$fig addcol image -id flag
	$fig addcol text  -id lang
	bind $fig <<ComboboxCurrent>> [namespace code [list ShowCountry $fig $position]]

	if {$opts(-mode) eq "game"} {
		$var addcol image -id icon
		$var addcol text  -id name
		bind $var <<ComboboxCurrent>> [namespace code [list SetVariant $var $position]]
	}

	set gamebar [::application::pgn::gamebar]
	set recv [namespace code [list GamebarChanged $dlg $position]]
	::gamebar::addReceiver $gamebar $recv
	bind $dlg <Destroy> [list ::gamebar::removeReceiver $gamebar $recv]
	bind $dlg <<LanguageChanged>> [namespace code [list LanguageChanged $dlg %W $position]]

	# text editor
	set edit [ttk::frame $main.edit]
	tk::text $edit.text \
		-width 80 \
		-height 20 \
		-undo on \
		-maxundo 10 \
		-yscroll [list $edit.ybar set] \
		;
	$edit.text tag configure hilite -background [::colors::lookup $Colors(background:hilite)]
	ttk::scrollbar $edit.ybar -command [list $edit.text yview] -takefocus 0
	pack $edit.ybar -side right -fill y
	pack $edit.text -side left -expand true -fill both
	$main paneconfigure $edit -sticky nswe -minsize 20 -stretch always
	$main add $edit

	# log window
	set log [ttk::frame $main.log]
	tk::listbox $log.text \
		-background [::colors::lookup $Colors(background)] \
		-selectbackground [::colors::lookup $Colors(background:select)] \
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
	set Priv($position:sets) {}
	set Priv($position:variantList) {}
	set Priv($position:variant) $opts(-variant)
	set Priv($position:mode) $opts(-mode)
	set Priv($position:varno) -1
	set Priv($position:figurines) $fig
	set Priv($position:variants) $var
	set Priv($position:undo) 0
	set Priv(showOnlyEncodingWarnings) 0

	pack $top -expand yes -fill both

	grid $vlb  -row 1 -column 1 -sticky w
	grid $var  -row 1 -column 3 -sticky ew
	grid $lbl  -row 3 -column 1 -sticky w
	grid $fig  -row 3 -column 3 -sticky ew
	grid $elb  -row 5 -column 1 -sticky w
	grid $enc  -row 5 -column 3 -sticky ew
	grid $main -row 7 -column 0 -sticky ewns -columnspan 5
	grid rowconfigure $top 3 -weight 1
	grid rowconfigure $top {0 2 4 6} -minsize 5
	grid columnconfigure $top {0 2 4} -minsize $::theme::padding
	grid columnconfigure $top {4} -weight 1

	::widget::dialogButtons $dlg {import close} -default import
	bind $dlg <Return> {}
	$dlg.import configure -command [namespace code [list DoImport $position $dlg]]
	$dlg.close configure -command [namespace code [list Close $position $dlg]]
	bind $dlg <Escape> [namespace code [list AskAbort $position $dlg.close]]

	# editor bindings
	set selectCmd [list $edit.text tag add sel 1.0 end]
	bind $edit.text <ButtonPress-3> [namespace code [list PopupMenu $edit $position %X %Y]]
	bind $edit.text <Key-Tab> {after idle { focus [::tk_focusNext %W] } }
	bind $edit.text <Key-Tab> {+ break }
	bind $edit.text <Shift-Tab> {after idle { focus [::tk_focusPrev %W] } }
	bind $edit.text <Shift-Tab> {+ break }
	bind $edit.text <Control-A> $selectCmd
	bind $edit.text <Control-a> $selectCmd

	set pastecmd [namespace code [list TextPasteSelection $position %W %x %y PRIMARY]]
	bind $edit.text <<PasteSelection>> $pastecmd
	bind $edit.text <<PasteSelection>> {+ break }
	bind $edit.text <Insert> $pastecmd
	bind $edit.text <Insert> {+ break }
	set pastecmd [namespace code [list TextPasteSelection $position %W %x %y CLIPBOARD]]
	bind $edit.text <<Paste>> $pastecmd
	bind $edit.text <<Paste>> {+ break }

	Clear $position
	SetFigurines $position
	SetVariants $position

	if {$opts(-mode) eq "game" && [string length $opts(-variant)]} {
		$var set $::mc::VariantName($opts(-variant))
	}

	wm withdraw $dlg
	::util::place $dlg -parent [winfo toplevel $parent] -position center
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

	lassign $arguments type lineNo column gameNo variant msg code info item
	set line ""

	if {$code eq "SeemsNotToBePgnText"} { set Priv(ok) 0 }

	append line $mc::Line " " [::locale::formatNumber $lineNo]
	if {$column} {
		append line " (" $mc::Column " " [::locale::formatNumber $column] ")"
	}
	if {[::info exists Priv(gameNo)] && $Priv(gameNo) && $gameNo > 0} {
		append line " " $mc::GameNumber " " [::locale::formatNumber $gameNo]
		append line " (" $mc::VariantName($variant) ")"
	}
	append line ": "

	set type [string toupper $type 0 0]

	if {[::info exists [namespace current]::mc::${type}($code)]} {
		append line [set mc::${type}($code)]
	} else {
		append line $code
	}

	if {[llength $item]} {
		append line ": " $item
	}

	return $line
}


proc showOnlyEncodingWarnings {flag} {
	variable Priv
	set Priv(showOnlyEncodingWarnings) $flag
}


proc logResult {total illegal emptyText importText accepted rejected {unsupported {}}} {
	set count 0
	foreach acc $accepted rej $rejected { incr count $acc; incr count $rej }
	set count [expr {$count + $illegal + [llength $unsupported]/2}]
	
	if {$total == 0} {
		set lastMsg $emptyText
	} else {
		set lastMsg [format $importText [::locale::formatNumber $total]]
	}

	if {$count == 0} {
		append lastMsg " ($mc::FileIsEmpty)"
		::log::info $lastMsg
	} else {
		if {$illegal} {
			::log::warning [format $::export::mc::IllegalRejected $illegal]
		}

		if {$total == 0} { set show 1 } else { set show -1 }

		set detailed yes
		foreach acc $accepted { if {$acc == $total} { set detailed no } }
		foreach rej $rejected { if {$rej} { set detailed yes } }

		if {$detailed || $total == 0} {
			set variants {normal bughouse crazyhouse threeCheck antichess losers}
			foreach variant $variants acc $accepted rej $rejected {
				if {$acc || $rej} {
					if {$variant eq "antichess"} {
						set msg "- $::mc::VariantName(Suicide)/$::mc::VariantName(Giveaway):"
					} else {
						set msg "- $::mc::VariantName([string toupper $variant 0 0]):"
					}
					if {$acc} {
						append msg " [::locale::formatNumber $acc]"
						if {$rej} { append msg " ($mc::Accepted) -" }
						incr show
					}
					if {$rej} {
						append msg " [::locale::formatNumber $rej] ($mc::Rejected)"
						incr show
					}
					::log::info $msg
				}
			}
		}

		foreach {variant n} $unsupported {
			::log::info "- [format $mc::UnsupportedVariantRejected $variant]: [::locale::formatNumber $n]"
		}

		::log::info $lastMsg
		if {$show > 0} { ::log::show }
	}
}


proc Open {parent file msg encoding type} {
	variable Priv

	set Priv(ok) 1
	set Priv(gameNo) 1

	set msg [format $mc::ImportingPgnFile [file tail $file]]
	::log::open $mc::DatabaseImport
	::log::info $msg
	set info "$::mc::File: [file tail $file]"
	set options [list -message $msg -log yes -interrupt yes -information $info]
	set cmd [list ::scidb::db::open $file [namespace current]::Log log]
	set cmd [list ::progress::start $parent $cmd [list -encoding $encoding -description 1] $options 0]

	if {[catch { ::util::catchException $cmd result } rc opts]} {
		::log::error $mc::AbortedDueToInternalError
		::progress::close
		::log::close
		return {*}$opts -rethrow 1 $rc
	}

	if {$rc == 1} {
		::log::error $mc::AbortedDueToIoError
		::progress::close
		::log::close
		set Priv(ok) 0
		return 0
	}

	lassign $result total illegal accepted rejected unsupported

	if {$total < 0} {
		::log::warning $mc::UserHasInterrupted
		set total [expr {-$total + 1}]
	}

	update idletasks	;# be sure the following will be appended
	if {$Priv(ok)} {
		logResult $total $illegal $mc::NoGamesImported $mc::ImportedGames $accepted $rejected $unsupported
	}

	set cmd [list ::scidb::db::save $file]
	set rc [::util::catchException { ::progress::start $parent $cmd {} {} 1 }]
	if {$rc == 1} {
		::log::error $mc::AbortedDueToIoError
		set Priv(ok) 0
	}
	::progress::close
	::log::close

	return $Priv(ok)
}


proc Import {parent base files msg encoding} {
	variable Priv

	set Priv(ok) 1
	set Priv(gameNo) 1

	set codec [::scidb::db::get codec $base]
	if {[llength $encoding] == 0} {
		switch $codec {
			sci - si3 - si4	{ set encoding utf-8 }
			default				{ set encoding $::encoding::defaultEncoding }
		}
	}

	::log::open $mc::DatabaseImport
	switch $codec {
		si3 - si4 {
			set fileEncoding [::scidb::db::get encoding $base]
			if {$encoding ne $::encoding::autoEncoding && $encoding ne $fileEncoding} {
				set ask [string map [list %src $encoding %dst $fileEncoding] $mc::DifferentEncoding]
				set reply [::dialog::warning \
					-parent $parent \
					-message $ask \
					-detail $mc::DifferentEncodingDetails \
					-buttons {cancel continue} \
				]
				if {$reply eq "cancel"} { return }
			}
		}
	}

	set logCount 0

	foreach file $files {
		if {[incr logCount] > 1} { ::log::newline }
		::log::info [format $mc::ImportingDatabase [file tail $file]]
		set info "$::mc::File: [file tail $file]"
		set options [list -message $msg -log yes -interrupt yes -information $info]
		set cmd [list ::scidb::db::import $base $file [namespace current]::Log log]
		switch [file extension $file] {
			.sci - .si3 - .si4	{ set encoding utf-8 }
			default					{ set encoding auto }
		}

		set cmd [list ::progress::start $parent $cmd [list -encoding $encoding] $options 0]
		if {[catch { ::util::catchException $cmd result } rc opts]} {
			::log::error $mc::AbortedDueToInternalError
			::progress::close
			::log::close
			return {*}$opts -rethrow 1 $rc
		}

		if {$rc == 1} {
			::log::error $mc::AbortedDueToIoError
			::progress::close
			::log::close
			set Priv(ok) 0
			return 0
		}

		lassign $result total illegal accepted rejected unsupported

		if {$total < 0} {
			::log::warning $mc::UserHasInterrupted
			set total [expr {-$total + 1}]
			set rc -1
		}

		update idletasks	;# be sure the following will be appended
		if {$Priv(ok)} {
			logResult $total $illegal $mc::NoGamesImported \
				$mc::ImportedGames $accepted $rejected $unsupported
		}
		if {$rc == -1} { break }
	}

	set cmd [list ::scidb::db::save $base]
	set rc [::util::catchException { ::progress::start $parent $cmd {} {} 1 }]
	if {$rc == 1} {
		::log::error $mc::AbortedDueToIoError
		set Priv(ok) 0
	}
	::progress::close
	::log::close

	return $Priv(ok)
}


proc PopupMenu {edit position x y} {
	variable Priv

	set m $edit.menu
	catch { destroy $m }
	menu $m -tearoff 0
	catch { wm attributes $m -type popup_menu }

	set sel ""
	catch { ::tk::GetSelection $edit.text CLIPBOARD } sel
	set accel "$::mc::Key(Ctrl)-"

	if {[llength [$edit.text tag ranges sel]] == 0} { set state disabled } else { set state normal }
	$m add command \
		-label " $::mc::Copy" \
		-accelerator ${accel}C \
		-image $::icon::16x16::clipboardIn \
		-compound left \
		-command [list tk_textCopy $edit.text] \
		-state $state \
		;
	$m add command \
		-label " $::mc::Cut" \
		-accelerator ${accel}X \
		-image $::icon::16x16::clipboardIn \
		-compound left \
		-command [list tk_textCut $edit.text] \
		-state $state \
		;
	if {[string length $sel]} { set state normal } else { set state disabled }
	$m add command \
		-label " $::mc::Paste" \
		-accelerator ${accel}V \
		-image $::icon::16x16::clipboardOut \
		-compound left \
		-command [namespace code [list TextPaste $position $edit.text]] \
		;

	set empty [::widget::textIsEmpty? $edit.text]
	if {!$empty || [$edit.text edit modified] || $Priv($position:undo)} {
		$m add separator
		if {$empty && ![$edit.text edit modified]} { set state disabled } else { set state normal }
		$m add command \
			-compound left \
			-image $::icon::16x16::undo \
			-label $::mc::Undo \
			-accelerator ${accel}Z \
			-command [namespace code [list Undo $position]] \
			-state $state \
			;
		if {$Priv($position:undo)} { set state normal } else { set state disabled }
		$m add command \
			-compound left \
			-image $::icon::16x16::redo \
			-label $::mc::Redo \
			-accelerator ${accel}Y \
			-command [namespace code [list Redo $position]] \
			-state $state
			;
	}

	if {!$empty} {
		$m add separator
		$m add command \
			-label " $::mc::SelectAll" \
			-accelerator ${accel}A \
			-image $::icon::16x16::selectAll \
			-compound left \
			-command [list $edit.text tag add sel 1.0 end] \
			-state $state \
			;
		$m add command \
			-label " $::mc::Clear" \
			-image $::icon::16x16::clear \
			-compound left \
			-command [namespace code [list Clear $position]] \
			;
	}

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


proc ConvertPieces {position str} {
	variable Priv

	set figurine [$Priv($position:figurines) get fig]

	if {$figurine ne $::encoding::mc::AutoDetect} {
		set unicodeMap [list \
			"\u2654" [string index $figurine 0] \
			"\u2655" [string index $figurine 1] \
			"\u2656" [string index $figurine 2] \
			"\u2657" [string index $figurine 3] \
			"\u2658" [string index $figurine 4] \
			"\u2659" [string index $figurine 5] \
		]
		set str [string map $unicodeMap $str]
	}

	return [string trimleft $str]
}


proc ConvertPastedText {position w str} {
	variable Priv

	set str [ConvertPieces $position $str]
	if {[string length $str] == 0} { return $str }
	set encoding $Priv($position:encoding)

	if {$encoding eq $::encoding::autoEncoding} {
		set encoding [::scidb::misc::encoding $str]
		if {[string length $encoding] == 0} {
			set encoding iso8859-1
		} else {
			set Priv($position:encoding) $encoding
			set Priv($position:encodingVar) $encoding
		}
	}

	return [encoding convertfrom $encoding $str]
}


proc TextPaste {position w} {
	global tcl_platform

	if {![catch {::tk::GetSelection $w CLIPBOARD} sel]} {
		if {[tk windowingsystem] ne "x11"} {
			catch { $w delete sel.first sel.last }
		}
		$w insert insert [ConvertPastedText $position $w $sel]
		$w edit separator
	}
}


proc TextPasteSelection {position w x y buffer} {
#	if {![::info exists ::tk::Priv(mouseMoved)] || !$::tk::Priv(mouseMoved)} {
		$w mark set insert [::tk::TextClosestGap $w $x $y]
		if {![catch {::tk::GetSelection $w $buffer} sel]} {
			$w insert insert [ConvertPastedText $position $w $sel]
			$w edit separator
			if {[$w cget -state] eq "normal"} { focus $w }
		}
#	}
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


proc SetVariants {position} {
	variable Variants
	variable Priv

	set w $Priv($position:variants)

	if {$Priv($position:mode) eq "game"} {
		set index [$w current]
		if {$index == -1} {
			set current $::mc::VariantName(Undetermined)
		} else {
			set current [lindex $Priv($position:variantList) $index]
		}
		set Priv($position:variantList) {}
		$w clear

		foreach variant $Variants {
			lappend Priv($position:variantList) $::mc::VariantName($variant)
			if {[::info exists ::icon::16x16::variant($variant)]} {
				set icon $::icon::16x16::variant($variant)
			} else {
				set icon ""
			}
			$w listinsert [list $icon $::mc::VariantName($variant)]
		}

		set index [lsearch -index 0 -exact $Priv($position:variantList) $current]

		$w resize
		$w current $index
	} else {
		$w configure -text $::mc::VariantName($Priv($position:variant))
	}
}


proc SetFigurines {position} {
	variable Figurines
	variable Priv

	set w $Priv($position:figurines)
	set index [lsearch -exact -index 1 $Priv($position:sets) [lindex [$w get] 0]]
	set current [lindex $Priv($position:sets) $index 0]
	set Priv($position:sets) {}
	foreach {lang figurine} [array get ::figurines::langSet] {
		switch $lang {
			en - graphic - user {}

			default {
				set figurine [string map {" " ""} $figurine]
				if {[string bytelength $figurine] == 6} {
					lappend Priv($position:sets) [list $lang [::encoding::languageName $lang] $figurine]
				}
			}
		}
	}
	set font [$w cget -font]
	set bold [list [list [font configure $font -family] [font configure $font -size] bold]]
	set Priv($position:sets) [scidb::misc::sort \
		-index 1 -order [::mc::sortOrderTable] $Priv($position:sets)]
	set value [list en [::encoding::languageName en] [string map {" " ""}  $::figurines::langSet(en)]]
	set Priv($position:sets) [linsert $Priv($position:sets) 0 $value]
	set index [lsearch -index 0 -exact $Priv($position:sets) $current]
	if {$index == -1} { set index 0 }
	set Figurines {}
	$w clear
	$w listinsert [list $::encoding::mc::AutoDetect {} {}] -types {text} -span {fig 3} -font $bold
	foreach entry $Priv($position:sets) {
		lappend Figurines [lindex $entry 1]
		lassign $entry id lang fig
		set flag $::country::icon::flag([::mc::countryForLang $id])
		$w listinsert [list $fig $flag $lang]
	}
	$w resize
	$w current $index
}


proc ChooseEncoding {btn position} {
	variable Priv

	set encoding [::encoding::choose [winfo toplevel $btn] $Priv($position:encoding) iso8859-1 yes]

	if {[llength $encoding]} {
		set Priv($position:encoding) $encoding
		if {$encoding eq $::encoding::autoEncoding} {
			set Priv($position:encodingVar) $::encoding::mc::AutoDetect
		} elseif {[llength $encoding]} {
			set Priv($position:encodingVar) $encoding
		}
	}
}


proc LanguageChanged {dlg w position} {
	variable Priv

	if {$dlg eq $w} {
		SetFigurines $position
		SetVariants $position
		SetTitle $dlg $position

		if {$Priv($position:encoding) eq $::encoding::autoEncoding} {
			set Priv($position:encodingVar) $::encoding::mc::AutoDetect
		}

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
	$txt edit separator
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


proc Undo {position} {
	variable Priv

	if {![catch { $Priv($position:txt) edit undo }]} {
		incr Priv($position:undo)
	}
}


proc Redo {position} {
	variable Priv

	if {![catch { $Priv($position:txt) edit redo }]} {
		decr Priv($position:undo)
	}
}


proc ShowCountry {w position} {
	variable Priv

	set i [lsearch -exact -index 1 $Priv($position:sets) [$w get lang]]
	if {$i == -1} {
		$w forgeticon
	} else {
		$w placeicon $::country::icon::flag([::mc::countryForLang [lindex $Priv($position:sets) $i 0]])
	}
}


proc SetVariant {w position} {
	variable Priv
	variable Variants

	set i [lsearch -exact $Priv($position:variantList) [$w get]]
	set iconVar ::icon::16x16::variant([lindex $Variants $i])
	if {[::info exists $iconVar]} { $w placeicon [set $iconVar] }
}


proc DoImport {position dlg} {
	variable ::log::colors
	variable Variants
	variable Priv

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
	if {$Priv($position:mode) eq "game"} {
		set isVar 0
		set variant [lindex $Variants [$Priv($position:variants) current]]
	} else {
		set variant $Priv($position:variant)
		set isVar 1
	}

	array set figset {}

	if {$figurine eq $::encoding::mc::AutoDetect} {
		set content [ConvertPieces $position $content]
		set found {}
		set successfull 0

		foreach entry $Priv($position:sets) {
			lassign $entry code _ figurine

			set state [::scidb::game::import \
				$position \
				$content \
				-variant $variant \
				-encoding utf-8 \
				-figurine $figurine \
				-variation $isVar \
				-varno $Priv($position:varno) \
				-trial 1 \
			]

			if {$state == 1} {
				set successfull 1
				if {$code eq "en"} { break }
				set f [string range $figurine 0 end-1]
				if {![::info exists figset($f)]} {
					lappend found $code
					set figset($f) 1
				}
			}
		}

		if {$successfull} {
			if {[llength $found] >= 1} {
				set currentCode [lindex $found 0]
				set f $::figurines::langSet($currentCode)
				set s ""
				append s "[lindex $f 0]=$::mc::Piece(K), "
				append s "[lindex $f 1]=$::mc::Piece(Q), "
				append s "[lindex $f 2]=$::mc::Piece(R), "
				append s "[lindex $f 3]=$::mc::Piece(B), "
				append s "[lindex $f 4]=$::mc::Piece(K)"
				if {[llength $found] > 1} {
					::dialog::warning \
						-parent $dlg \
						-buttons {ok} \
						-message [format $mc::CheckImportResult $s] \
						-detail $mc::CheckImportResultDetail \
						;
				}
			} else {
				set currentCode en
			}

			if {[llength $found] <= 1} {
				set index [lsearch -exact -index 0 $Priv($position:sets) $currentCode]
				if {$currentCode ne "en"} {
					$Priv($position:figurines) current [expr {$index + 1}]
				}
			}

			set i [lsearch -exact -index 0 $Priv($position:sets) $currentCode]
			set figurine [lindex $Priv($position:sets) $i 2]
		} else {
			set msg $mc::CannotDetectFigurineSet
			append msg "\n\n"
			append msg $mc::TryAgainWithEnglishSet
			set detail $mc::TryAgainWithEnglishSetDetail
			set reply [::dialog::question -parent $dlg -message $msg -detail $detail]
			if {$reply == "no"} { return }
			set index [lsearch -exact -index 0 $Priv($position:sets) en]
			$Priv($position:figurines) current [expr {$index + 1}]
			set figurine [$Priv($position:figurines) get fig]
		}
	}

	set state [::scidb::game::import \
		$position \
		$content \
		[namespace current]::Log import \
		-variant $variant \
		-encoding utf-8 \
		-figurine $figurine \
		-variation $isVar \
		-varno $Priv($position:varno) \
		-trial 0 \
	]

	if {[string is integer -strict $state]} {
		if {$isVar && $state >= 0} {
			set Priv($position:varno) $state
			set state 1
		}
		if {$state <= 0} {
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
			::scidb::game::switch $position ;# because the variant may have changed
		}
	} else {
		Show info [format $mc::UnsupportedVariantRejected $state]
		$log configure -state disabled -takefocus 0
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
	variable Priv

	if {!$Priv(showOnlyEncodingWarnings) || [lindex $arguments 5] eq "EncodingFailed"} {
		set type [lindex $arguments 0]
		::${sink}::${type} [makeLog $arguments]
		update idletasks
	}
}


# setup
showOnlyEncodingWarnings false

} ;# namespace import

# vi:set ts=3 sw=3:
