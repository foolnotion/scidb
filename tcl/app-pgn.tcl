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

namespace eval application {
namespace eval pgn {
namespace eval mc {

set Command(move:annotation)		"Set Annotation/Comment/Marks"
set Command(move:append)			"Add Move"
set Command(move:exchange)			"Exchange Move"
set Command(variation:new)			"Add Variation"
set Command(variation:replace)	"Replace Moves"
set Command(variation:truncate)	"Truncate Variation"
set Command(variation:first)		"Make First Variation"
set Command(variation:promote)	"Promote Variation"
set Command(variation:remove)		"Delete Variation"
set Command(variation:mainline)	"New Mainline"
set Command(variation:insert)		"Insert Moves"
set Command(variation:exchange)	"Exchange Moves"
set Command(strip:moves)			"Moves from the beginning"
set Command(strip:truncate)		"Moves to the end"
set Command(strip:annotations)	"Annotations"
set Command(strip:marks)			"Marks"
set Command(strip:comments)		"Comments"
set Command(strip:variations)		"Variations"
set Command(game:clear)				"Clear Game"
set Command(game:transpose)		"Transpose Game"

set ColumnStyle						"Column Style"
set NarrowLines						"Narrow Lines"
set IndentVariations					"Indent Variations"					;# TODO remove
set IndentComments					"Indent Comments"						;# TODO remove
set BoldTextForMainlineMoves		"Bold Text for Mainline Moves"
set SpaceAfterMoveNumbers			"Space after Move Numbers"			;# TODO remove
set ShowDiagrams						"Show Diagrams"
set Languages							"Languages"

set NumberOfMoves						"Number of moves (in main line):"
set InvalidInput						"Invalid input '%d'."
set MustBeEven							"Input must be an even number."
set MustBeOdd							"Input must be an odd number."

set StartTrialMode					"Start Trial Mode"
set StopTrialMode						"Stop Trial Mode"
set Strip								"Strip"
set InsertDiagram						"Insert Diagramm"
set InsertDiagramFromBlack			"Insert Diagramm from Black's Perspective"
set SuffixCommentaries				"Suffixed Commentaries"

set AddNewGame							"Save: Add New Game to %s..."
set ReplaceGame						"Save: Replace Game in %s..."

set EditAnnotation					"Edit annotation"
set EditComment						"Edit comment"
set Display								"Display"
set None									"none"

} ;# namespace mc

array set Colors {
	main				#000000
	variation		#0000ee
	startvar			#68480a
	bracket			#0000ee
	nag				#ee0000
	comment			#006300
	comment:hilite	#7a5807
	current			#ffdd76
	hilite			#ebf4f5
	next-move		#eeff00
	background		#ffffff
	emphasized		#ebf4f5
	result			#000000
	illegal			#ee0000
	marks				#6300c6
}
#	next-move		#eee8aa
#	comment			#008b00
#	comment:hilite	#005500

array set Options {
	font					TkTextFont
	font-bold			{}
	font-italic			{}
	font-bold-italic	{}
	mainline-bold		1
	indent-amount		25
	indent-max			2
	indent-comment		1
	indent-var			1
	narrow-lines		0
	column-style		0
	tabstop-1			6.0
	tabstop-2			0.7
	tabstop-3			12.0
	board-size			30
	diagram-show		1
	diagram-pad-x		25
	diagram-pad-y		5
}

variable Vars
variable CharLimit 250


proc build {parent menu width height} {
	variable Vars
	variable Options

	set font $Options(font)
	foreach {key attrs} {bold bold italic italic bold-italic {bold italic}} {
		set Vars(font-$key) $Options(font-$key)
		if {[llength $Vars(font-$key)] == 0} {
			set Vars(font-$key) [list [font configure $font -family] [font configure $font -size] $attrs]
		}
	}

	set top [::ttk::frame $parent.top -borderwidth 0]
	pack $top -fill both -expand yes
	bind $top <Configure> [namespace code { Configure %W %h }]

	set Vars(bar) [::gamebar::gamebar $top.gamebar]
	grid $Vars(bar) -row 1 -column 1 -sticky nsew

	bind $Vars(bar) <<LabelbarSelected>>	[namespace code { LabelbarSelected %d }]
	bind $Vars(bar) <<LabelbarRemoved>>		[namespace code { LabelbarRemoved %d }]

	set Vars(frame) $top
	set Vars(delta) 0
	set Vars(after) {}
	set Vars(index) 0
	set Vars(break) 0
	set Vars(height) 0

	for {set i 0} {$i < 9} {incr i} {
		set f [::ttk::frame $top.f$i]
		set sb [::ttk::scrollbar $f.sb \
					-command [namespace code [list ::widget::textLineScroll $f.pgn]] -takefocus 0]
		set pgn [text $f.pgn \
						-yscrollcommand [list $f.sb set] \
						-takefocus 0 \
						-exportselection 0 \
						-undo 0 \
						-width 0 \
						-height 0 \
						-relief sunken \
						-borderwidth 1 \
						-state disabled \
						-wrap word \
						-font $Options(font) \
						-cursor {}]

		bind $pgn <Button-3>		[namespace code [list PopupMenu $top $i]]
		bind $pgn <Double-1>		{ break }
		bind $pgn <B1-Motion>	{ break }
		bind $pgn <B2-Motion>	{ break }

		grid $pgn -row 1 -column 1 -sticky nsew
		grid $sb -row 1 -column 2 -sticky ns
		grid rowconfigure $f 1 -weight 1
		grid columnconfigure $f 1 -weight 1

		grid $f -row 2 -column 1 -sticky nsew

		set Vars(pgn:$i) $pgn
		set Vars(frame:$i) $f
		set Vars(after:$i) {}
	}

	set Vars(charwidth) [font measure [$Vars(pgn:0) cget -font] "0"]

	set tab1 [expr {round($Options(tabstop-1)*$Vars(charwidth))}]
	set tab2 [expr {$tab1 + round($Options(tabstop-2)*$Vars(charwidth))}]
	set tab3 [expr {$tab2 + round($Options(tabstop-3)*$Vars(charwidth))}]

	set Vars(tabs) [list	$tab1 right $tab2 $tab3]

	SetupStyle
	for {set i 0} {$i < 9} {incr i} { ConfigureText $Vars(pgn:$i) }

	set f [::ttk::frame $top.f$i]
	grid $f -row 2 -column 1 -sticky nsew
	set Vars(frame:9) $f

	set tbLanguages [::toolbar::toolbar $parent \
		-id languages \
		-side bottom \
		-tooltipvar [namespace current]::mc::Languages \
	]
	set Vars(lang:active:xx) 1
	::toolbar::add $tbLanguages checkbutton \
		-image [::country::makeToolbarIcon ZZX] \
		-command [namespace code [list ToggleLanguage xx]] \
		-tooltipvar ::comment::::mc::AllLanguages \
		-variable [namespace current]::Vars(lang:active:xx) \
		-padx 1 \
		;
	set Vars(lang:toolbar) $tbLanguages
	set Vars(lang:active:$::mc::langID) 1

	grid columnconfigure $top 1 -weight 1
	grid rowconfigure $top 2 -weight 1
	bind $top <<Language>> [namespace code LanguageChanged]

	raise $Vars(frame:9)

	set Vars(lang:set) {}
	set Vars(edit:comment) 0

	InitScratchGame
}


proc empty? {} {
	variable Vars
	return [expr {[::gamebar::size $Vars(bar)] == 0}]
}


proc gamebar {} {
	return [set [namespace current]::Vars(bar)]
}


proc add {position base info tags} {
	variable Vars
	variable Options
	variable Colors

	set w $Vars(pgn:$position)

	$w configure -state normal
	$w delete 1.0 end
#	$w tag delete {*}[$Vars(pgn:$position) tag names]
	$w edit reset
	foreach diagram [$w window names] { destroy $diagram }
	array unset Vars diagram:*:$position
	$w configure -state disabled

	::gamebar::add $Vars(bar) $position $info $tags
	::gamebar::activate $Vars(bar) $position
	raise $Vars(frame:$position)

	set Vars(current:$position) {}
	set Vars(previous:$position) {}
	set Vars(next:$position) {}
	set Vars(active:$position) {}
	set Vars(info:$position) $info
	set Vars(see:$position) 1
	set Vars(dirty:$position) 0
	set Vars(comment:$position) ""
	set Vars(result:$position) ""
	set Vars(virgin:$position) 1
	set Vars(last:$position) ""
	set Vars(start:$position) 1

	SetLanguages $position
	SetupStyle $position

	::scidb::game::subscribe pgn $position [namespace current]::Update
	::scidb::game::subscribe board $position [namespace parent]::board::update
	::scidb::game::subscribe tree $position [namespace parent]::tree::update
}


proc release {position} {
	variable Vars

	::gamebar::remove $Vars(bar) $position
#	bind $Vars(frame) <Configure> [namespace code { Align %W %h }]
}


proc select {{position {}}} {
	variable Vars

	if {[llength $position] == 0} {
		set position [::gamebar::selected $Vars(bar)]
		if {[llength $position]} { return }
		if {[::gamebar::empty? $Vars(bar)]} {
			::scidb::game::switch 9
			raise $Vars(frame:9)
			return
		}
		set position [::gamebar::getId $Vars(bar) 0]
	}

	::gamebar::activate $Vars(bar) $position
	raise $Vars(frame:$position)
	set Vars(index) $position
}


proc selectAt {index} {
	variable Vars

	if {$index < [::gamebar::size $Vars(bar)]} {
		select [::gamebar::getId $Vars(bar) $index]
	}
}


proc gamebarIsEmpty? {} {
	variable Vars
	return [::gamebar::empty? $Vars(bar)]
}


proc editAnnotation {{position -1} {key {}}} {
	variable Vars

	if {$position == -1} {
		if {[::annotation::open?]} {
			return [::annotation::close]
		}
		set position $Vars(index)
	}

	if {[string length $key]} {
		GotoMove $position $key
	}

	Edit $position ::annotation
}


proc editComment {{position -1} {key {}} {lang {}}} {
	variable Vars

	if {$position == -1} { set position $Vars(index) }

	if {[llength $lang] == 0} {
		set lang ""
		foreach code [array names Vars lang:active:*] {
			set code [string range $code end-1 end]
			if {[string length $lang] == 0 || $code eq $::mc::langID} {
				if {[::scidb::game::query $position langSet $Vars(current:$position) $code]} {
					set lang $code
				}
			}
		}
		if {[string length $lang] == 0} { set lang xx }
	}

	Edit $position ::comment $key $lang
}


proc openMarksPalette {{position -1} {key {}}} {
	if {$position == -1 && [::marks::open?]} {
		::marks::close
	} else {
		Edit $position ::marks $key
	}
}


proc scroll {args} {
	::widget::textLineScroll [set [namespace current]::Vars(pgn:[::scidb::game::current])] scroll {*}$args
}


proc undo {} { Undo undo }
proc redo {} { Undo redo }


proc ensureScratchGame {} {
	variable [namespace parent]::database::scratchbaseName
	variable Vars

	if {[::gamebar::empty? $Vars(bar)]} {
		# TODO
		# Site:	Scratch Game
		# Event:	<current timestamp>
		::scidb::game::switch 9
		set fen [::scidb::pos::fen]
		::scidb::game::new 0
		::scidb::game::switch 0
		::scidb::pos::setup $fen
		set info [::scidb::game::info 0]
		add 0 $scratchbaseName $info [::scidb::game::tags 0]
		::game::setFirst $scratchbaseName $info
	}
}


proc InitScratchGame {} {
	variable Vars

	::scidb::game::new 9
	::scidb::game::switch 9

	set Vars(current:9) {}
	set Vars(previous:9) {}
	set Vars(next:9) {}
	set Vars(active:9) {}
	set Vars(info:9) [::scidb::game::info 9]
	set Vars(see:9) 1
	set Vars(last:9) {}

	::scidb::game::subscribe board 9 [namespace parent]::board::update
	::scidb::game::switch 9
	raise $Vars(frame:9)
}


proc See {position w key succKey} {
	variable Vars
	variable CharLimit

	if {!$Vars(see:$position)} { return }

	if {$Vars(start:$position)} {
		if {$key eq "m-0.0"} { return }
		set Vars(start:$position) 0
	}

	set firstLine [$w index h-end]
	set range [$w tag nextrange $succKey [$w index $key]]

	if {[llength $range]} {
		lassign [split [lindex $range 0] .] row col
		set last [expr {min($row + 3, $Vars(lastrow:$position))}]
		set rest [$w count -chars $row.$col $row.end]
		set count $rest
		set r $row
		while {$r < $last} {
			incr r
			incr count [$w count -chars $r.0 $r.end]
			if {$count > $CharLimit} {
				incr r -1
				break
			}
		}
		if {$r > $row} { $w see $r.0 }
		if {$rest < $CharLimit} {
			set offs [expr {[winfo width $w]/$Vars(charwidth)}]
			$w see $row.[expr {$col + min($CharLimit, 3*$offs)}]
		}
		$w see $row.$col
	} else {
		$w see $key
	}
}


proc Configure {w height} {
	variable Vars

	after cancel $Vars(after)
	set Vars(after) [after 50 [namespace code [list Align $w $height]]]
}


proc ConfigureText {w} {
	variable Options
	variable Colors
	variable Vars

	if {$Options(mainline-bold)} {
		set mainFont $Vars(font-bold)
	} else {
		set mainFont $Options(font)
	}

	$w tag configure eco -font $Vars(font-bold)

	$w tag configure main -font $mainFont
	$w tag configure variation -foreground $Colors(variation)
	$w tag configure nag -foreground $Colors(nag)
	$w tag configure illegal -foreground $Colors(illegal)
	$w tag configure result -font $mainFont -foreground $Colors(result)
#	$w tag configure startvar -foreground $Colors(startvar)
	$w tag configure bracket -foreground $Colors(bracket)
	$w tag configure marks -foreground $Colors(marks)

	$w tag configure figurine -font $::font::figurine
	$w tag configure symbol -font $::font::symbol
	$w tag configure symbolb -font $::font::symbolb

	$w tag configure comment -foreground $Colors(comment)
	$w tag configure bold -font $Vars(font-bold)
	$w tag configure italic -font $Vars(font-italic)
	$w tag configure bold-italic -font $Vars(font-bold-italic)
	$w tag configure underline -underline true

	$w tag bind illegal <Any-Enter> [namespace code [list Tooltip $w illegal]]
	$w tag bind illegal <Any-Leave> [namespace code [list Tooltip $w hide]]

	if {$Options(column-style)} {
		$w configure -tabs $Vars(tabs) -tabstyle wordprocessor
	} else {
		$w configure -tabs {} -tabstyle tabular
	}

	for {set k 0} {$k <= $Vars(indent-max)} {incr k} {
		set amount [expr {$k*$Options(indent-amount)}]
		$w tag configure indent$k -lmargin1 $amount -lmargin2 $amount
	}

	foreach k [array names ::annotation::mc::Nag] {
		$w tag bind nag$k <Any-Enter> [namespace code [list Tooltip $w $k]]
		$w tag bind nag$k <Any-Leave> [namespace code [list Tooltip $w hide]]
	}
}


proc Align {w height} {
	variable Vars

	if {$height != $Vars(height)} {
		set Vars(height) $height
		set linespace [font metrics [$Vars(pgn:0) cget -font] -linespace]
		set amounts [list $linespace [expr {($height - 2) % $linespace}]]
		::gamebar::setAlignment $Vars(bar) $amounts
	}
}


proc LabelbarSelected {position} {
	variable Vars

	::game::select $position
	raise $Vars(frame:$position)
}


proc LabelbarRemoved {position} {
	variable Vars
	variable Colors

	::game::release $position

	set w $Vars(pgn:$position)
	$w tag configure $Vars(current:$position) -background $Colors(background)
	foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }

	if {[::gamebar::empty? $Vars(bar)]} {
		::widget::busyCursor on
		::scidb::game::switch 9
		raise $Vars(frame:9)
		::widget::busyCursor off
	}
}


proc ToggleLanguage {lang} {
	variable Vars

	set Vars(lang:active:$lang) [expr {!$Vars(lang:active:$lang)}]
	SetLanguages $Vars(index)
}


proc SetLanguages {position} {
	variable Vars

	set langSet {}
	foreach key [array names Vars lang:active:*] {
		if {$Vars($key)} {
			set lang [lindex [split $key :] 2]
			if {$lang eq "xx"} { set lang "" }
			lappend langSet $lang
		}
	}
	::scidb::game::langSet $position $langSet
}


proc AddLanguageButton {lang} {
	variable Vars

	if {![info exists Vars(lang:active:$lang)]} {
		set Vars(lang:active:$lang) 0
	}
	set countryCode $::mc::langToCountry($lang)
	set w [::toolbar::add $Vars(lang:toolbar) checkbutton \
		-image [::country::makeToolbarIcon $countryCode] \
		-command [namespace code [list ToggleLanguage $lang]] \
		-tooltipvar ::encoding::mc::Lang($lang) \
		-variable [namespace current]::Vars(lang:active:$lang) \
		-padx 1 \
	]
	set Vars(lang:button:$lang) $w
}


proc UpdateLanguages {languages} {
	variable Vars

	if {$Vars(lang:set) eq $languages} { return }
	set Vars(lang:set) $languages
	set langButtons [array names Vars lang:button:*]
	
	foreach button $langButtons {
		::toolbar::remove $Vars(lang:toolbar) $Vars($button)
		unset Vars($button)
	}

	foreach lang $languages {
		AddLanguageButton $lang
	}
}


proc Edit {position ns {key {}} {lang {}}} {
	variable Vars

	if {![::gamebar::empty? $Vars(bar)]} {
		if {$position == -1} {
			set position $Vars(index)
		}

		if {[llength $key]} {
			GotoMove $position $key
		}

		${ns}::open [winfo toplevel $Vars(pgn:$position)] {*}$lang
	}
}


proc Dump {w} {
	set dump [$w dump -all 1.0 end]
	foreach {type attr pos} $dump {
		if {$attr ne "current" && $attr ne "insert"} {
			if {$attr eq "\n"} { set attr "\\n" }
			switch $type {
				tagon - tagoff {}
				default { puts "$pos: $type $attr" }
			}
		}
	}
	puts "==============================================="
}


proc Update {position data} {
	variable Options
	variable Vars

	set w $Vars(pgn:$position)
	set startLevel -1

	foreach node $data {
		switch [lindex $node 0] {
			start {
				$w configure -state normal
				set Vars(marks) {}
			}

			languages {
				UpdateLanguages [lindex $node 1]
			}

			header {
				UpdateHeader $position $w [lindex $node 1]
			}

			begin {
				set level [lindex $node 2]
				set startVar($level) [lindex $node 1]
			}

			end {
				set level [lindex $node 2]
				Indent $w $level $startVar($level)
				incr level -1
			}

			action {
				set Vars(dirty:$position) 1
				set args [lindex $node 1]

				switch [lindex $args 0] {
					replace {
						set action replace
						lassign $args unused level removePos insertMark
						$w delete $removePos $insertMark
						$w mark gravity $removePos left
						$w mark gravity $insertMark right
						$w mark set current $insertMark
						set insertPos [$w index $insertMark]
					}

					insert {
						set action insert
						lassign $args unused level insertMark
						$w mark gravity $insertMark right
						$w mark set current $insertMark
						set insertPos [$w index $insertMark]
					}

					finish {
						set level [lindex $args 1]
						Indent $w $level $insertPos
						Mark $w $insertMark
					}

					remove {
						$w delete {*}[lrange $args 2 end]
					}

					clear {
						$w delete h-end m-0
						$w insert m-0 \n
#						$w tag delete {*}[$Vars(pgn:$position) tag names]
					}

					marks	{ [namespace parent]::board::updateMarks [::scidb::game::query marks] }
					goto	{ ProcessGoto $position $w [lindex $args 1] [lindex $args 2] }
				}
			}

			move {
				set key  [lindex $node 1]
				set data [lindex $node 2]

				Mark $w $key
				InsertMove $position $w $level $key $data
				set Vars(last:$position) $key
			}

			diagram {
				set key  [lindex $node 1]
				set data [lindex $node 2]

				Mark $w $key
				InsertDiagram $position $w $level $key $data
			}

			result {
				set result [lindex $node 1]

				if {$Vars(result:$position) != $result} {
					if {[string length $Vars(last:$position)]} {
						$w mark gravity $Vars(last:$position) left
					}
					$w mark gravity m-0 left
					$w mark set current m-0
					# NOTE: the text editor has a severe bug:
					# If all chars after <pos> are newlines, the command
					# '<text> delete <pos-1> <pos-2>' will also delete one
					# newline before <pos>. We should catch this case:
					if {![string is space [$w get m-0 end]]} {
						$w delete current end
					}
					$w insert current \n
					if {$Options(column-style)} { $w insert current \n }
					$w insert current [::util::formatResult $result] result
					$w mark gravity m-0 right
					if {[string length $Vars(last:$position)]} {
						$w mark gravity $Vars(last:$position) right
					}
					set Vars(result:$position) $result
				}
				# TODO: really needed?
				foreach mark $Vars(marks) { $w mark gravity $mark right }
				$w mark gravity m-0 right
				$w configure -state disabled
				set Vars(lastrow:$position) [lindex [split [$w index end] .] 0]
			}
		}
	}
}


proc Indent {w level key} {
	variable Options

	if {$level > 0} {
		if {$Options(column-style)} {
			if {$level == 1} { return }
			incr level -1
		}
		$w tag add indent$level $key current
	}
}


proc ProcessGoto {position w key succKey} {
	variable Vars
	variable Colors

	if {$Vars(current:$position) ne $key} {
		foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }
		set Vars(next:$position) [::scidb::game::next keys $position]
		if {$Vars(active:$position) eq $key} { $w configure -cursor {} }
		if {[llength $Vars(previous:$position)]} {
			$w tag configure $Vars(previous:$position) -background $Colors(background)
		}
		$w tag configure $key -background $Colors(current)
		set Vars(current:$position) $key
		if {[llength $Vars(previous:$position)]} {
			after cancel $Vars(after:$position)
			set Vars(after:$position) {}
			See $position $w $key $succKey
			if {$Vars(active:$position) eq $Vars(previous:$position)} {
				EnterMove $position $Vars(previous:$position)
			}
		}
		foreach k $Vars(next:$position) {
			$w tag configure $k -background $Colors(next-move)
		}
		set Vars(previous:$position) $Vars(current:$position)
		[namespace parent]::board::updateMarks [::scidb::game::query marks]
		::annotation::update $key
	} elseif {$Vars(dirty:$position)} {
		set Vars(dirty:$position) 0
		after cancel $Vars(after:$position)
		set Vars(after:$position) {}
		See $position $w $key $succKey
	}
}


proc UpdateHeader {position w data} {
	variable Vars

	set idn 0
	set opening {}
	set pos ""

	foreach pair $data {
		lassign $pair name value
		switch $name {
			idn		{ set idn $value }
			eco		{ set eco $value }
			position { set pos $value }
			opening	{ set opg $value }
		}
	}

	if {!$Vars(virgin:$position)} {
		$w delete 1.0 h-end
	}

	$w mark set current 1.0
	foreach line [::browser::makeOpeningLines [list $idn $pos $eco {*}$opg]] {
		$w insert current {*}$line
	}
	$w mark set h-end [$w index current]
	$w mark gravity h-end left

	if {$Vars(virgin:$position)} {
		$w insert current "\n"
		$w mark set m-0 [$w index current]
		$w mark gravity m-0 right
	}

	set Vars(virgin:$position) 0
}


proc InsertBreak {w level bracket} {
	variable Options

	switch $level {
		0 - 1 - 2	{ set space "\n" }
		3				{ if {$Options(column-style)} { set space "\n" } { set space " " } }
		default		{ $w insert current " " }
	}

	$w insert current $space

	if {$bracket eq "(" && ($level > 0 || !$Options(column-style) || $Options(narrow-lines))} {
		$w insert current "( " bracket
	}
}


proc InsertMove {position w level key data} {
	variable Options

	foreach node $data {
		switch [lindex $node 0] {
			break {
				InsertBreak $w [lindex $node 1] [lindex $node 2]
			}

			space {
				switch [lindex $node 1] {
					")" {
						if {$level > 1 || !$Options(column-style) || $Options(narrow-lines)} {
							$w insert current " )" bracket
						}
					}

					"("		{ $w insert current " ( " bracket }
					default	{ $w insert current " " }
				}
			}

			ply {
				PrintMove $position $w $level $key [lindex $node 1]
			}

			annotation {
				set pre [lindex $node 1]
				set suf [lindex $node 2]
				lappend suf {*}[lindex $node 3]

				if {[llength $pre]} {
					PrintAnnotation $w $position $level $key $pre
				}
				if {[llength $suf]} {
					if {[llength $pre]} {
						$w insert current " "
					}
					PrintAnnotation $w $position $level $key $suf
				}
			}

			marks {
				set count [lindex $node 1]
				if {$count > 0} {
					set marks [string map {"\[%" "" "\] " "\n" "\]" ""} [lindex $node 2]]
					set tag marks:$key
					$w insert current " "
					$w insert current "\u27f8" [list marks $tag]
					$w tag bind $tag <Any-Enter> +[namespace code [list EnterMark $w $tag $marks]]
					$w tag bind $tag <Any-Leave> +[namespace code [list LeaveMark $w $tag]]
					$w tag bind $tag <ButtonPress-1> [namespace code [list openMarksPalette $position $key]]
				}
			}

			comment {
				set startPos [$w index current]
				PrintComment $position $w $level $key [lindex $node 1]
				if {$level == 0 && !$Options(column-style)} {
					$w tag add indent1 $startPos current
				}
			}
		}
	}
}


proc InsertDiagram {position w level key data} {
	variable Options

	set color white

	foreach entry $data {
		switch [lindex $entry 0] {
			color { set color [lindex $entry 1] }
			break { $w insert current "\n" }

			board {
				set board [lindex $entry 1]
				set index 0
				set key [string map {d m} $key]
				set img $w.[string map {. :} $key]
				board::stuff::new $img $Options(board-size) 2
				if {$color eq "black"} { ::board::stuff::rotate $img }
				::board::stuff::update $img $board
				::board::stuff::bind $img <Button-1> [namespace code [list editAnnotation $position $key]]
				::board::stuff::bind $img <Button-3> [namespace code [list PopupMenu $w $position]]
				$w window create current \
					-align center \
					-window $img \
					-padx $Options(diagram-pad-x) \
					-pady $Options(diagram-pad-y) \
					;
			}
		}
	}
}


proc PrintMove {position w level key data} {
	variable Options

	lassign $data moveNo stm san legal
	lappend tags $key

	if {$level > 0} {
		lappend tags variation
	} else {
		lappend tags main
	}

	if {$level == 0 && $Options(column-style)} {
		$w insert current "\t"

		if {$moveNo} {
			$w insert current $moveNo main
			$w insert current ". " main
			$w insert current "\t"
			if {$stm eq "black"} { $w insert current "...\t" main }
		} 
	} else {
		lappend tags $key

		if {$moveNo} {
			$w insert current $moveNo $tags
			$w insert current "." $tags
			if {$stm eq "black"} { $w insert current ".." $tags }
		}
	}

	foreach {text tag} [::font::splitMoves $san] {
		$w insert current $text [list {*}$tags $tag]
		$w tag bind $key <Any-Enter> [namespace code [list EnterMove $position $key]]
		$w tag bind $key <Any-Leave> [namespace code [list LeaveMove $position $key]]
		$w tag bind $key <Any-Button> [namespace code [list HidePosition $w]]
		$w tag bind $key <ButtonPress-1> [namespace code [list GotoMove $position $key]]
		$w tag bind $key <ButtonPress-2> [namespace code [list ShowPosition $w $position $key]]
		$w tag bind $key <ButtonRelease-2> [namespace code [list HidePosition $w]]
	}

	if {!$legal} {
		set tags illegal
		if {$level == 0} { lappend tags main }
		$w insert current "\u26A1" $tags
		$w tag bind illegal <Any-Enter> +[namespace code [list Tooltip $w illegal]]
		$w tag bind illegal <Any-Leave> +[namespace code [list Tooltip $w hide]]
		$w tag bind illegal <ButtonPress-1> [namespace code [list GotoMove $position $key]]
	}
}


proc PrintComment {position w level key data} {
	variable Vars

	set startPos {}
	set keyTag comment:$key
	set underline 0
	set flags 0
	set count 0
	set needSpace 0
	set lastChar ""
	set paragraph 0

	foreach entry [::scidb::misc::xmlToList $data] {
		lassign $entry lang comment
		if {[string length $lang] == 0} {
			set lang xx
		} elseif {[incr paragraph] == 2} {
			$w insert current " \u2726 "
			set needSpace 0
		}
#		if {$Vars(lang:active:$lang)} {
			set langTag $keyTag:$lang
			foreach pair $comment {
				lassign $pair code text
				set text [string map {"<brace/>" "\{"} $text]
				if {$needSpace} {
					if {![string is space -strict [string index $text 0]]} {
						$w insert current " " $langTag
					}
					set needSpace 0
				}
				set lastChar [string index $text end]
				switch -- $code {
					sym - nag - str {
						if {[llength $startPos] == 0} { set startPos [$w index current] }
					}
				}
				switch -- $code {
					sym {
						$w insert current [string map $::font::pieceMap $text] [list figurine $langTag]
					}
					nag {
						lassign [::font::splitAnnotation $text] value sym tag
						set nagTag nag$text
						if {($flags & 1) && $tag eq "symbol"} { set tag symbolb }
						if {[string is digit $sym]} { set text "{\$$text}" }
						lappend tag $langTag $nagTag
						$w insert current $sym $tag
						incr count
					}
					str {
						switch $flags {
							0 { set tag {} }
							1 { set tag bold }
							2 { set tag italic }
							3 { set tag bold-italic }
						}
						$w insert current $text [list $langTag $tag]
					}
					+bold			{ incr flags +1 }
					-bold			{ incr flags -1 }
					+italic		{ incr flags +2 }
					-italic		{ incr flags -2 }
					+underline	{ set underline 1 }
					-underline	{ set underline 0 }
				}
			}

			if {[llength $startPos]} {
				$w tag add comment $startPos current
				$w tag bind $langTag <Enter> [namespace code [list EnterComment $w $key:$lang]]
				$w tag bind $langTag <Leave> [namespace code [list LeaveComment $w $position $key:$lang]]
				$w tag bind $langTag <ButtonPress-1> [namespace code [list EditComment $position $key $lang]]
				set startPos {}
			}

			if {![string is space -strict $lastChar]} {
				set needSpace 1
			}
#		}
	}
}


proc PrintAnnotation {w position level key nags} {
	variable Vars
	variable Options

	set annotation [::font::splitAnnotation $nags]
	set isPrefix [string match {14[0-5]} [lindex $nags 0]]
	set pos [$w index current]
	set keyTag nag:$key
	set prevSym -1
	set count 0
	set nag ""

	foreach {value nag tag} $annotation {
		set sym [expr {$tag eq "symbol"}]
		if {$level == 0} {
			if {$sym} { set tag symbolb }
			lappend tag main
		}
		set nagTag $keyTag:[incr count]
		set c [string index $nag 0]
		if {[string match {[RN]*} $c]} {
			if {[lindex [split [$w index current] .] end] ne "0"} { $w insert current " " }
			set prevSym 1
		} elseif {$value <= 6} {
			if {$count > 1} { $w insert current " " }
			set prevSym 1
		} elseif {$value == 155 || $value == 156} {
			if {$Options(diagram-show)} {
				set nag ""
			} else {
				if {[lindex [split [$w index current] .] end] ne "0"} { $w insert current " " }
				set prevSym $sym
			}
		} elseif {$prevSym == 0 || (!$sym && !$isPrefix)} {
			$w insert current " "
			set prevSym $sym
		}
		if {[string length $nag]} {
			$w insert current $nag [list nag$value {*}$tag $nagTag]
			$w tag bind $nagTag <Enter> [namespace code [list EnterAnnotation $w $nagTag]]
			$w tag bind $nagTag <Leave> [namespace code [list LeaveAnnotation $w $nagTag]]
		}
		set prefix 0
	}

	set keyTag annotation:$key
	$w tag add nag $pos current
	$w tag raise symbol
	$w tag raise symbolb
	$w tag add $keyTag $pos current
	$w tag bind $keyTag <ButtonPress-1> [namespace code [list editAnnotation $position $key]]
}


proc EditComment {position key lang} {
	variable Vars

	set w $Vars(pgn:$position)
	set Vars(edit:comment) 1
	editComment $position $key $lang
	set Vars(edit:comment) 0
	LeaveComment $w $position $key:$lang
}


# XXX use something like ::scidb::game::key
proc ParentKey {key} {
	return [join [lrange [split $key .] 0 end-2] .]
}


proc Mark {w key} {
	variable Vars

	$w mark unset $key
	$w mark set $key [$w index current]
	$w mark gravity $key left
	lappend Vars(marks) $key
}


proc EnterMove {position key} {
	variable Vars
	variable Colors

	if {$Vars(current:$position) ne $key} {
		$Vars(pgn:$position) tag configure $key -background $Colors(hilite)
		$Vars(pgn:$position) configure -cursor hand2
	}

	set Vars(active:$position) $key
}


proc LeaveMove {position key} {
	variable Vars
	variable Colors

	set Vars(active:$position) {}

	if {$Vars(current:$position) ne $key} {
		if {$key in $Vars(next:$position)} {
			set color $Colors(next-move)
		} else {
			set color $Colors(background)
		}
		$Vars(pgn:$position) tag configure $key -background $color
		$Vars(pgn:$position) configure -cursor {}
	}
}


proc EnterMark {w tag marks} {
	variable Colors

	$w tag configure $tag -background $Colors(emphasized)
	::tooltip::show $w $marks
}


proc LeaveMark {w tag} {
	variable Colors

	$w tag configure $tag -background $Colors(background)
	::tooltip::hide
}


proc GotoMove {position key} {
	variable Vars

	set Vars(see:$position) 0
	if {[llength $key] == 0} { set key [::scidb::game::query start] }
	::scidb::game::moveto $position $key
	set Vars(see:$position) 1
}


proc EnterComment {w key} {
	variable Colors
#	$w tag configure comment:$key -underline true
	$w tag configure comment:$key -foreground $Colors(comment:hilite)
}


proc LeaveComment {w position key} {
	variable Colors
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag configure comment:$key -foreground $Colors(comment)
	}
}


proc EnterAnnotation {w tag} {
	variable Colors
	$w tag configure $tag -background $Colors(emphasized)
}


proc LeaveAnnotation {w tag} {
	variable Colors
	$w tag configure $tag -background $Colors(background)
}


proc ShowPosition {parent position key} {
	set w $parent.showboard

	if {![winfo exists $w]} {
		variable Options

		toplevel $w -class Tooltip -relief solid
		wm withdraw $w
		if {[tk windowingsystem] eq "aqua"} {
			::tk::unsupported::MacWindowStyle style $w help none
		} else {
			wm overrideredirect $w true
		}
		wm attributes $w -topmost true
		::board::stuff::new $w.board $Options(board-size) 2
		pack $w.board
	}

	if {[llength $key] == 0} { set key [::scidb::game::query start] }
	::board::stuff::update $w.board [::scidb::game::board $position $key]
	::tooltip::popup $parent $w cursor
}


proc HidePosition {parent} {
	::tooltip::popdown $parent.showboard
}


proc Tooltip {path nag} {
	variable ::annotation::mc::Nag

	switch $nag {
		hide		{ ::tooltip::hide }
		illegal	{ ::tooltip::show $path $mc::IllegalMove }
		
		default {
			if {[info exists Nag($nag)]} {
				::tooltip::show $path $Nag($nag)
			}
		}
	}
}


proc Undo {action} {
	variable Vars

	if {[llength [::scidb::game::query $action]]} {
		::widget::busyOperation ::scidb::game::execute $action
	}
}


proc PopupMenu {parent position} {
	variable ::annotation::mc::Nag
	variable ::annotation::LastNag
	variable [namespace parent]::database::mc::T_Clipbase
	variable [namespace parent]::database::clipbaseName
	variable [namespace parent]::database::scratchbaseName
	variable Options
	variable Vars

	set menu $parent.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0

	if {[::game::trialMode?]} {
		$menu add command -label $mc::StopTrialMode -command ::game::endTrialMode
	} else {
		if {[::scidb::game::level] > 0} {
			set varno [::scidb::game::variation current]
			if {$varno > 1} {
				$menu add command \
					-label "$mc::Command(variation:first)" \
					-command [namespace code FirstVariation] \
					;
			}
			foreach {action cmd} {promote PromoteVariation remove RemoveVariation} {
				$menu add command -label $mc::Command(variation:$action) -command [namespace code $cmd]
			}
			if {[::scidb::game::variation length] % 2} {
				set state disabled
			} else {
				set state normal
			}
			$menu add command \
				-state $state \
				-label $mc::Command(variation:insert) \
				-command [namespace code [list InsertMoves $parent]] \
				;
			$menu add command \
				-label "$mc::Command(variation:exchange)..." \
				-command [namespace code [list ExchangeMoves $parent]] \
				;
			$menu add separator
		}

		$menu add command -label $mc::StartTrialMode -command ::game::startTrialMode
		$menu add command -label $mc::Command(game:transpose) -command [namespace code TransposeGame]

		menu $menu.strip -tearoff no
		set state "normal"
		if {![::scidb::game::position isMainline?] || [::scidb::game::position atStart?]} {
			set state "disabled"
		}
		$menu.strip add command \
			-label $mc::Command(strip:moves) \
			-state $state \
			-command [list ::widget::busyOperation ::scidb::game::strip moves]
		set state "normal"
		if {	[::scidb::game::position atEnd?]
			|| (![::scidb::game::position isMainline?] && [::scidb::game::position atStart?])} {
			
			set state "disabled"
		}
		$menu.strip add command \
			-label $mc::Command(strip:truncate) \
			-state $state \
			-command [list ::widget::busyOperation ::scidb::game::strip truncate] \
			;
		foreach cmd {variations annotations marks} {
			set state "normal"
			if {[::scidb::game::count $cmd] == 0} { set state "disabled" }
			$menu.strip add command \
				-label $mc::Command(strip:$cmd) \
				-state $state \
				-command [list ::widget::busyOperation ::scidb::game::strip $cmd] \
				;
		}

		set state "normal"
		if {[::scidb::game::count comments] == 0} { set state "disabled" }

		menu $menu.strip.comments -tearoff no
		$menu.strip add cascade \
			-menu $menu.strip.comments \
			-label $mc::Command(strip:comments) \
			-state $state \
			;

		if {$state eq "normal"} {
			$menu.strip.comments add command \
				-compound left \
				-image $::country::icon::flag($::mc::langToCountry(xx)) \
				-label " $::comment::mc::AllLanguages" \
				-command [list ::widget::busyOperation ::scidb::game::strip comments] \
				;

			foreach lang $Vars(lang:set) {
				$menu.strip.comments add command \
					-compound left \
					-image $::country::icon::flag($::mc::langToCountry($lang)) \
					-label " $::encoding::mc::Lang($lang)" \
					-command [list ::widget::busyOperation ::scidb::game::strip comments $lang] \
					;
			}
		}

		$menu add cascade -menu $menu.strip -label $mc::Strip

#		set vars [::scidb::game::next moves -unicode]
#
#		foreach {which cmd start} {first FirstVariation 2
#											promote PromoteVariation 1
#											remove RemoveVariation 1} {
#			if {[llength $vars] > $start} {
#				if {[llength $vars] > [expr {$start + 1}]} {
#					menu $menu.$which
#					$menu add cascade -menu $menu.$which -label $mc::Command($which)
#
#					for {set i $start} {$i < [llength $vars]} {incr i} {
#						$menu.$which add command \
#							-label [::font::translate [lindex $vars $i]] \
#							-command [namespace code [list $cmd $i]]
#					}
#				} else {
#					$menu add command \
#						-label "$mc::Command($which): [::font::translate [lindex $vars 1]]" \
#						-command [namespace code [list $cmd 1]]
#				}
#			}
#		}

		$menu add separator

		if {[::scidb::game::position atStart?]} {
			$menu add command \
				-label $mc::InsertDiagram \
				-command [list ::annotation::setNags suffix 155] \
				;
			$menu add command \
				-label $mc::InsertDiagramFromBlack \
				-command [list ::annotation::setNags suffix 156] \
				;
		} else {
			set cmd ::annotation::setNags

			if {[::scidb::pos::stm] eq "w"} {
				upvar #0 ::annotation::isWhiteNag isStmNag
			} else {
				upvar #0 ::annotation::isBlackNag isStmNag
			}

			foreach type {prefix infix suffix} {
				set ranges $::annotation::sections($type)
				set m [menu $menu.$type]

				if {[llength $ranges] == 1} {
					$m add command -command "$cmd $type 0"
					lassign [lindex $ranges 0] descr from to
					bind $m <<MenuSelect>> [namespace code { ::widget::menuItemHighlightSecond %W }]
				} else {
					$menu add cascade -menu $m -label $mc::SuffixCommentaries
					$m add command -label "($mc::None)" -command "$cmd $type 0"
				}

				foreach range $::annotation::sections($type) {
					lassign $range descr from to
					set text [set ::annotation::mc::$descr]

					if {[llength $ranges] == 1} {
						$menu add cascade -menu $m -label $text
						set sub $m
					} else {
						set sub [menu $m.[string tolower $descr 0 0]]
						$m add cascade -menu $sub -label $text
						bind $sub <<MenuSelect>> [namespace code { ::widget::menuItemHighlightSecond %W }]
					}

					set nags {}
					for {set nag $from} {$nag <= $to} {incr nag} {
						if {!$isStmNag($nag)} {
							set symbol [::font::mapNagToSymbol $nag]
							if {$symbol ne $nag} {
								$sub add command -label $symbol -command "$cmd $type $nag"
								lappend nags $nag
							}
						}
					}

					if {[llength $ranges] == 1} {
						$sub add command -columnbreak 1 -label "($mc::None)" -command "$cmd infix 0"
						set columnbreak 0
					} else {
						set columnbreak 1
					}

					foreach nag $nags {
						$sub add command \
							-label [string toupper $Nag($nag) 0 0] \
							-command "$cmd $type $nag" \
							-columnbreak $columnbreak \
							;
						set columnbreak 0
					}
				}
			}
		}

		if {[::annotation::open?]} { set state disabled } else { set state normal }
		$menu add command \
			-label "$mc::EditAnnotation..." \
			-state $state \
			-command [namespace code [list editAnnotation $position]] \
			;
		$menu add command \
			-label "$mc::EditComment..." \
			-command [namespace code [list editComment $position]] \
			;
		if {[::marks::open?]} { set state disabled } else { set state normal }
		$menu add command \
			-label "$::marks::mc::MarksPalette..." \
			-state $state \
			-command [namespace code [list openMarksPalette $position]] \
			;

		$menu add separator

		$menu add command \
			-label $::import::mc::ImportPgnGame \
			-command [namespace code PasteClipboardGame] \
			;
		$menu add command \
			-label $::import::mc::ImportPgnVariation \
			-command [namespace code PasteClipboardVariation] \
			;

		$menu add separator

		foreach action {undo redo} {
			set cmd [::scidb::game::query $action]
			set label [set ::mc::[string toupper $action 0 0]]
			if {[llength $cmd]} {
				append label " '"
				if {[string match strip:* $cmd]} { append label "$mc::Strip: " }
				append label $mc::Command($cmd) "'"
			}
			$menu add command \
				-compound left \
				-image [set ::icon::12x12::$action] \
				-label $label \
				-command [list ::widget::busyOperation ::scidb::game::execute $action] \
				-state [expr {[llength $cmd] ? "normal" : "disabled"}] \
				;
		}

		$menu add separator

		set base [::scidb::game::query $position database]
		set number [::scidb::game::number $position]
		set bases [::scidb::app::bases]
		unset -nocomplain state

		if {$base eq $scratchbaseName} {
			set base $clipbaseName
			set name $T_Clipbase
			set ext ""
			set state(save) normal
			set state(replace) disabled
		} else {
			if {[::scidb::db::get open? $base] && ![::scidb::db::get readonly? $base]} {
				set state(save) normal
				if {$number >= 0} { set state(replace) normal } else { set state(replace) disabled }
			} else {
				set state(save) disabled
				set state(replace) disabled
			}

			if {$base eq $clipbaseName} {
				set name $T_Clipbase
			} else {
				set name [::util::databaseName $base]
			}
		}

		$menu add command \
			-label [format $mc::ReplaceGame $name] \
			-command [list ::dialog::save::open $parent $base $position $number] \
			-state $state(replace) \
			;
		$menu add command \
			-label  [format $mc::AddNewGame $name] \
			-command [list ::dialog::save::open $parent $base $position -1] \
			-state $state(save) \
			;

		menu $menu.save
		set count 0
		foreach base $bases {
			set myName [::util::databaseName $base]
			if {$name ne $myName && ![::scidb::db::get readonly? $base]} {
				$menu.save add command \
					-label $myName \
					-command [list ::dialog::save::open $parent $base $position -1] \
					;
				incr count
			}
		}
		if {$name ne $T_Clipbase} {
			$menu.save add command \
				-label $T_Clipbase \
				-command [list ::dialog::save::open $parent Clipbase $position -1] \
				;
				incr count
		}
		$menu add cascade \
			-menu $menu.save \
			-label [format $mc::AddNewGame ""] \
			-state [expr {$count ? "normal" : "disabled"}] \
			;
		$menu add separator
	}

	menu $menu.display
	$menu add cascade -menu $menu.display -label $mc::Display
	array unset state

	foreach {label var onValue} {	ColumnStyle column-style 1
											NarrowLines narrow-lines 1
											BoldTextForMainlineMoves mainline-bold 1
											ShowDiagrams diagram-show 1} {
		set state normal
		if {$onValue} { set offValue 0 } else { set offValue 1 }
		if {$var eq "narrow-lines" && !$Options(column-style)} { set state disabled }

		$menu.display add checkbutton \
			-label [set mc::$label] \
			-onvalue $onValue \
			-offvalue $offValue \
			-variable [namespace current]::Options($var) \
			-command [namespace code [list Refresh $var]] \
			-state $state \
			;
	}

#	$menu add separator
#
#	$menu add command -label "$SetupColors..."
#	$menu add command -label "$SetupFonts..."
#
#	$menu add separator
#
#	$menu add command -label $CopyGameToClipboard
#	$menu add command -label "$PrintToFile..."

	tk_popup $menu {*}[winfo pointerxy $parent]
}


proc PasteClipboardGame {} {
	variable Vars

	set position $Vars(index)
	::import::openEdit $Vars(frame:$position) $position game
}


proc PasteClipboardVariation {} {
	variable Vars

	set position $Vars(index)
	::import::openEdit $Vars(frame:$position) $position variation
}


proc TransposeGame {} {
	::game::startTrialMode
	::widget::busyOperation ::scidb::game::transpose true
}


proc FirstVariation {{varno 0}} {
	variable Vars

	set key [::scidb::game::position key]

	if {$varno} {
		set Vars(current:[::scidb::game::current]) {}
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
		set parts [split $key "."]
		lset parts end-1 0
		set key [join $parts "."]
	}

	::widget::busyOperation ::scidb::game::variation first $varno
	::scidb::game::moveto $key
}


proc PromoteVariation {{varno 0}} {
	set key [::scidb::game::position key]

	if {$varno} {
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
		set parts [split $key "."]
		set parts [lreplace $parts end-2 end-1]
		set key [join $parts "."]
	}

	::widget::busyOperation ::scidb::game::variation promote $varno
	::scidb::game::moveto $key
}


proc RemoveVariation {{varno 0}} {
	if {$varno} {
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
	}

	::widget::busyOperation ::scidb::game::variation remove $varno

	if {$varno} {
		::scidb::game::position backward
		::scidb::game::moveto [::scidb::game::position key]
	} else {
		::scidb::game::moveto [ParentKey $key]
	}
}


proc InsertMoves {parent} {
	set key [::scidb::game::position key]
	set varno  [::scidb::game::variation leave]
	::move::doDestructiveCommand \
		$parent \
		$mc::Command(variation:insert) \
		[list ::widget::busyOperation ::scidb::game::variation insert $varno] \
		[list ::scidb::game::moveto [ParentKey $key]] \
		[list ::scidb::game::moveto $key]
}


proc ExchangeMoves {parent} {
	variable Length_
	variable Key_

	set key [::scidb::game::position key]
	set varno [::scidb::game::variation leave]
	set dlg [toplevel $parent.exchange -class Dialog]
	set top [::ttk::frame $dlg.top]
	pack $dlg.top
	set Length_ [::scidb::game::variation length $varno]
	::ttk::spinbox $top.sblength \
		-from [expr {$Length_ % 2 ? 1 : 2}]  \
		-to [expr {10000 + ($Length_ % 2)}] \
		-increment 2 \
		-textvariable [namespace current]::Length_ \
		-width 4 \
		-exportselection false \
		-justify right \
		;
	::validate::spinboxInt $top.sblength no
	::theme::configureSpinbox $top.sblength
	$top.sblength selection range 0 end
	$top.sblength icursor end
	::ttk::label $top.llength -text $mc::NumberOfMoves
	::widget::dialogButtons $dlg {ok cancel} ok
	$dlg.cancel configure -command [namespace code [list DontExchangeMoves $dlg $key]]
	$dlg.ok configure -command [namespace code [list VerifyNumberOfMoves $dlg $Length_]]

	grid $top.llength		-row 1 -column 1
	grid $top.sblength	-row 1 -column 3
	grid columnconfigure $top {0 2 4} -minsize $::theme::padding
	grid rowconfigure $top {0 2} -minsize $::theme::padding

	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list DontExchangeMoves $dlg $key]]]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg $mc::Command(variation:exchange)
	wm resizable $dlg false false
	::util::place $dlg center
	wm deiconify $dlg
	focus $top.sblength
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg

	if {$Length_ >= 0} {
		::move::doDestructiveCommand \
			$parent \
			$mc::Command(variation:exchange) \
			[list ::widget::busyOperation ::scidb::game::variation exchange $varno $Length_] \
			[list ::scidb::game::moveto [ParentKey $key]] \
			[list ::scidb::game::moveto $key]
	}
}


proc DontExchangeMoves {dlg key} {
	variable Length_

	destroy $dlg
	set Length_ -1
	::scidb::game::moveto $key
}


proc VerifyNumberOfMoves {dlg length} {
	variable Length_

	if {$length % 2 != $Length_ % 2} {
		if {$length % 2} {
			set detail $mc::MustBeOdd
		} else {
			set detail $mc::MustBeEven
		}

		::dialog::error -parent $dlg -message [format $mc::InvalidInput $Length_] -detail $detail
		set Length_ $length
		$dlg.top.sblength selection range 0 end
		$dlg.top.sblength icursor end
		::validate::spinboxInt $dlg.top.sblength off
		focus $dlg.top.sblength
	} else {
		destroy $dlg
	}
}


proc Refresh {var} {
	variable Options
	variable Colors
	variable Vars

	set radical ""

	if {$var eq "mainline-bold"} {
		if {$Options(mainline-bold)} {
			set mainFont $Vars(font-bold)
		} else {
			set mainFont $Options(font)
		}

		for {set i 0} {$i < 9} {incr i} {
			$Vars(pgn:$i) tag configure main -font $mainFont
		}
	}

	set Vars(current:$Vars(index)) {}
	SetupStyle

	if {$var eq "column-style"} {
		for {set i 0} {$i < 9} {incr i} {
			if {$Options(column-style)} {
				$Vars(pgn:$i) configure -tabs $Vars(tabs) -tabstyle wordprocessor
			} else {
				$Vars(pgn:$i) configure -tabs {} -tabstyle tabular
			}
			set Vars(result:$i) ""
		}
	}

	if {$var eq "diagram-show"} { set radical "" } else { set radical "-radical" }
	::widget::busyOperation ::scidb::game::refresh {*}$radical
}


proc SetupStyle {{position {}}} {
	variable Options
	variable Vars

	set Vars(indent-max) $Options(indent-max)

	if {$Options(column-style)} {
		incr Vars(indent-max)
		set thresholds {0 0 0 0}
	} else {
		set thresholds {240 80 60 0}
	}

	::scidb::game::setup {*}$position {*}$thresholds \
		$Options(column-style) $Options(narrow-lines) $Options(diagram-show)
}


proc LanguageChanged {} {
	variable Vars 

	if {[info exists Vars(see:0)]} {
		::widget::busyOperation ::scidb::game::refresh
	}
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Colors
	::options::writeItem $chan [namespace current]::Options
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace pgn
} ;# namespace application

# vi:set ts=3 sw=3:
