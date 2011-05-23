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

namespace eval export {
namespace eval mc {

set FileSelection					"&File Selection"
set Options							"&Options"
set PageSetup						"&Page Setup"
set Style							"Sty&le"
set Encoding						"&Encoding"
set AddGamesToExisitingFile	"&Add games to an existing file"

set Notation						"Notation"
set Figurines						"Figurines"
set Graphic							"Graphic"
set Short							"Short"
set Long								"Long"
set Algebraic						"Algebraic"
set Correspondence				"Correspondence"
set Telegraphic					"Telegraphic"
set FontHandling					"Font handling"
set EmebedTruetypeFonts			"Embed TrueType fonts"
set UseBuiltinFonts				"Use built-in fonts"

set PdfFiles						"PDF Files"
set HtmlFiles						"HTML Files"
set TeXFiles						"TeX Files"

set ExportDatabase				"Export %s Database"
set ExportDatabaseTitle			"Export Database '%s'"
set ExportingDatabase			"Exporting %s to file %s"
set Export							"Export"
set ExportedGames					"%s game(s) exported"
set NoGamesForExport				"No games for export."
set OverwriteDatabase			"You are about to overwrite original database %s. Are you sure?"
set ResetDefaults					"Reset to defaults"
set UnsupportedEncoding			"Cannot use encoding %s for PDF documents. You have to choose an alternative encoding."
set DatabaseIsOpen				"Database '%s' is open. You have to close it first."
set CannotExportToMyself		"Cannot export database '%s' to myself."

set BasicStyle						"Basic Style"
set GameInfo						"Game Info"
set GameText						"Game Text"
set Moves							"Moves"
set MainLine						"Main Line"
set Variation						"Variation"
set Subvariation					"Subvariation"
set Symbols							"Symbols"
set Comments						"Comments"
set Result							"Result"
set Diagram							"Diagram"

set Paper							"Paper"
set Orientation					"Orientation"
set Margin							"Margin"
set Format							"Format"
set Size								"Size"
set Custom							"Custom"
set Potrait							"Potrait"
set Landscape						"Landscape"
set Top								"Top"
set Bottom							"Bottom"
set Left								"Left"
set Right							"Right"
set Justification					"Justification"
set Even								"Even"
set Columns							"Columns"
set One								"One"
set Two								"Two"

set FormatName(scidb)	"Scidb"
set FormatName(scid)		"Scid"
set FormatName(pgn)		"PGN"
set FormatName(pdf)		"PDF"
set FormatName(html)		"HTML"
set FormatName(tex)		"LaTeX"
set FormatName(ps)		"Postscript"

set Option(pgn,include_varations)						"Export variations"
set Option(pgn,include_comments)							"Export comments"
set Option(pgn,include_marks)								"Export marks (as comments)"
set Option(pgn,include_ply_count_tag)					"Write tag 'PlyCount'"
set Option(pgn,include_termination_tag)				"Write tag 'Termination'"
set Option(pgn,include_mode_tag)							"Write tag 'Mode'"
set Option(pgn,include_opening_tag)						"Write tags 'Opening', 'Variation', 'Subvariation'"
set Option(pgn,include_setup_tag)						"Write tag 'Setup' (if needed)"
set Option(pgn,include_variant_tag)						"Write tag 'Variant' (if needed)"
set Option(pgn,include_position_tag)					"Write tag 'Position' (if needed)"
set Option(pgn,include_time_mode_tag)					"Write tag 'TimeMode' (if needed)"
set Option(pgn,exclude_extra_tags)						"Exclude extraneous tags"
set Option(pgn,add_country_after_player)				"Add country after player name"
set Option(pgn,indent_variations)						"Indent variations"
set Option(pgn,indent_comments)							"Indent comments"
set Option(pgn,column_style)								"Column style (one move per line)"
set Option(pgn,symbolic_annotation_style)				"Symbolic annotation style (!, !?)"
set Option(pgn,extended_symbolic_style)				"Extended symbolic annotation style (+=, +/-)"
set Option(pgn,convert_null_moves)						"Convert null moves to comments"
set Option(pgn,space_after_move_number)				"Add space after move numbers"
set Option(pgn,shredder_fen)								"Write Shredder-FEN (default is X-FEN)"
set Option(pgn,convert_lost_result_to_comment)		"Write comment for result '0-0'"
set Option(pgn,append_mode_to_event_type)				"Add mode after event type"
set Option(pgn,use_chessbase_format)					"Use ChessBase format"
set Option(pgn,comment_to_html)							"Write comment in HTML style"
set Option(pgn,exclude_games_with_illegal_moves)	"Exclude games with illegal moves"

}

#set Random {}
#while {[llength $Random] < 30} { lappend Random [expr {min(1.0, rand() + 0.15)}] }
set Random {
	0.75 1.00 1.00 0.97 0.31 0.21 1.00 1.00 0.52 0.17 0.89 1.00 0.18 1.00 0.78
	1.00 0.69 0.26 0.95 0.65 0.65 0.19 1.00 0.75 0.54 0.67 0.93 0.59 0.84 0.77
}

array set PdfEncodingMap {
	iso8859-1	StandardEncoding
	iso8859-2	ISO8859-2
	iso8859-3	ISO8859-3
	iso8859-4	ISO8859-4
	iso8859-5	ISO8859-5
	iso8859-6	ISO8859-6
	iso8859-7	ISO8859-7
	iso8859-8	ISO8859-8
	iso8859-9	ISO8859-9
	iso8859-10	ISO8859-10
	iso8859-11	ISO8859-11
	iso8859-12	ISO8859-12
	iso8859-13	ISO8859-13
	iso8859-14	ISO8859-14
	iso8859-15	ISO8859-15
	iso8859-16	ISO8859-16
	cp1250		CP1250
	cp1251		CP1251
	cp1252		CP1252
	cp1253		CP1253
	cp1254		CP1254
	cp1255		CP1255
	cp1256		CP1256
	cp1257		CP1257
	cp1258		CP1258
}
# cannot handle multi-byte encodings (will be implemented later)
#	koi8-r		KOI8-R
#	cp932			90msp-RKSJ-H
#	cp936			GBK-EUC-H
#	cp949			KSCms-UHC-H
#	cp950			ETen-B5-H
#	euc-cn		GB-EUC-H
#	euc-jp		EUC-H
#	euc-kr		KSC-EUC-H

set PdfEncodingList {}
foreach key [array names PdfEncodingMap] { lappend PdfEncodingList $key }
set PdfEncodingList [lsort -dictionary $PdfEncodingList]

set Paper(tex) {
	{ A2 420 594 mm }
	{ A3 297 420 mm }
	{ A4 210 297 mm }
	{ A5 148 210 mm }
	{ A6 105 148 mm }
	{ B3 353 500 mm }
	{ B4 250 353 mm }
	{ B5 176 250 mm }
	{ Letter 8.5 11 in }
	{ Legal 8.5 14 in }
	{ Executive 7.25 10.5 in }
}

set Paper(pdf) {
	{ A2 420 594 mm }
	{ A3 297 420 mm }
	{ A4 210 297 mm }
	{ A5 148 210 mm }
	{ A6 105 148 mm }
	{ B3 353 500 mm }
	{ B4 250 353 mm }
	{ B5 176 250 mm }
	{ Letter 8.5 11 in }
	{ Legal 8.5 14 in }
	{ Executive 7.25 10.5 in }
	{ {Half Letter} 5.5 8.5 in }
	{ {US B} 11 17 in }
	{ {US C} 17 22 in }
	{ {US 4x6} 4 6 in }
	{ {US 4x8} 4 8 in }
	{ {US 5x7} 5 7 in }
	{ {COMM 10} 4.125 9.5 in }
}

set StyleLayout(tex) {
	{ 0 BasicStyle }
		{ 1 GameInfo }
		{ 1 GameText }
			{ 2 Moves }
				{ 3 MainLine }
				{ 3 Variation }
				{ 3 Subvariation }
			{ 2 Comments }
				{ 3 MainLine }
				{ 3 Variation }
				{ 3 Subvariation }
			{ 2 Result }
}

set StyleLayout(pdf) {
	{ 0 BasicStyle }
		{ 1 GameInfo }
		{ 1 GameText }
			{ 2 Moves }
				{ 3 MainLine }
				{ 3 Variation }
				{ 3 Subvariation }
				{ 3 Figurines }
				{ 3 Symbols }
			{ 2 Comments }
				{ 3 MainLine }
				{ 3 Variation }
				{ 3 Subvariation }
			{ 2 Result }
		{ 1 Diagram }
}

set StyleLayout(html) $StyleLayout(pdf)

array set Styles {
	tex,BasicStyle												{Helvetica 12 normal roman #000000}
	tex,BasicStyle,GameInfo									{{} {} bold {} {}}
	tex,BasicStyle,GameText									{{} {} {} {} {}}
	tex,BasicStyle,GameText,Moves							{{} {} {} {} {}}
	tex,BasicStyle,GameText,Moves,MainLine				{{} {} bold {} {}}
	tex,BasicStyle,GameText,Moves,Variation			{{} {} {} {} {}}
	tex,BasicStyle,GameText,Moves,Subvariation		{{} 10 {} {} {}}
	tex,BasicStyle,GameText,Comments						{{} {} {} {} {}}
	tex,BasicStyle,GameText,Comments,MainLine			{{} {} {} {} {}}
	tex,BasicStyle,GameText,Comments,Variation		{{} {} {} {} {}}
	tex,BasicStyle,GameText,Comments,Subvariation	{{} 10 {} {} {}}
	tex,BasicStyle,GameText,Result						{{} {} bold {} {}}

	pdf,BasicStyle												{Helvetica 12 normal roman #000000}
	pdf,BasicStyle,GameInfo									{{} {} bold {} {}}
	pdf,BasicStyle,GameText									{{} {} {} {} {}}
	pdf,BasicStyle,GameText,Moves							{{} {} {} {} {}}
	pdf,BasicStyle,GameText,Moves,MainLine				{{} {} bold {} {}}
	pdf,BasicStyle,GameText,Moves,Variation			{{} {} {} {} {}}
	pdf,BasicStyle,GameText,Moves,Subvariation		{{} 10 {} {} {}}
	pdf,BasicStyle,GameText,Moves,Figurines			{{Scidb Chess Merida} {} {} {} {}}
	pdf,BasicStyle,GameText,Moves,Symbols				{{Scidb Symbol Traveller} {} {} {} {}}
	pdf,BasicStyle,GameText,Comments						{{} {} {} {} #000099}
	pdf,BasicStyle,GameText,Comments,MainLine			{{} {} {} {} {}}
	pdf,BasicStyle,GameText,Comments,Variation		{{} {} {} {} {}}
	pdf,BasicStyle,GameText,Comments,Subvariation	{{} 10 {} {} {}}
	pdf,BasicStyle,GameText,Result						{{} {} bold {} {}}
	pdf,BasicStyle,Diagram									{{Scidb Diagram Merida} 20 normal roman {}}

	html,BasicStyle											{Helvetica 12 normal roman #000000}
	html,BasicStyle,GameInfo								{{} {} bold {} {}}
	html,BasicStyle,GameText								{{} {} {} {} {}}
	html,BasicStyle,GameText,Moves						{{} {} {} {} {}}
	html,BasicStyle,GameText,Moves,MainLine			{{} {} bold {} {}}
	html,BasicStyle,GameText,Moves,Variation			{{} {} {} {} {}}
	html,BasicStyle,GameText,Moves,Subvariation		{{} 10 {} {} {}}
	html,BasicStyle,GameText,Moves,Figurines			{{Scidb Chess Merida} {} {} {} {}}
	html,BasicStyle,GameText,Moves,Symbols				{{Scidb Symbol Traveller} {} {} {} {}}
	html,BasicStyle,GameText,Comments					{{} {} {} {} #000099}
	html,BasicStyle,GameText,Comments,MainLine		{{} {} {} {} {}}
	html,BasicStyle,GameText,Comments,Variation		{{} {} {} {} {}}
	html,BasicStyle,GameText,Comments,Subvariation	{{} 10 {} {} {}}
	html,BasicStyle,GameText,Result						{{} {} bold {} {}}
	html,BasicStyle,Diagram									{{Scidb Diagram Merida} 20 normal roman {}}
}

array set Colors {
	shadow		#999999
	text			#c0c0c0
	highlight	#fff5d6
}

set Margin(mm)	15
set Margin(in)	0.59
set Margin(pt)	42.48

variable Types	{scidb scid pgn pdf html tex}
variable Info

# NOTE: order must coincide with flags in db::Writer.
array set Flags {
	pgn,include_varations						 0
	pgn,include_comments							 1
	pgn,include_annotation						 2
	pgn,include_marks								 3
	pgn,include_termination_tag				 4
	pgn,include_mode_tag							 5
	pgn,include_opening_tag						 7
	pgn,include_setup_tag						 9
	pgn,include_variant_tag						10
	pgn,include_position_tag					11
	pgn,include_time_mode_tag					12
	pgn,exclude_extra_tags						13
	pgn,add_country_after_player				14
	pgn,indent_variations						15
	pgn,indent_comments							16
	pgn,column_style								17
	pgn,symbolic_annotation_style				18
	pgn,extended_symbolic_style				29
	pgn,convert_null_moves						20
	pgn,space_after_move_number				21
	pgn,shredder_fen								22
	pgn,convert_lost_result_to_comment		23
	pgn,append_mode_to_event_type				24
	pgn,use_chessbase_format					25
	pgn,comment_to_html							25
	pgn,exclude_games_with_illegal_moves	26
}

array set Defaults {
	pgn,include_varations						1
	pgn,include_comments							1
	pgn,include_marks								1
	pgn,include_termination_tag				0
	pgn,include_mode_tag							0
	pgn,include_opening_tag						1
	pgn,include_setup_tag						1
	pgn,include_variant_tag						1
	pgn,include_position_tag					1
	pgn,include_time_mode_tag					1
	pgn,exclude_extra_tags						0
	pgn,add_country_after_player				0
	pgn,indent_variations						1
	pgn,indent_comments							0
	pgn,column_style								0
	pgn,symbolic_annotation_style				1
	pgn,extended_symbolic_style				0
	pgn,convert_null_moves						0
	pgn,space_after_move_number				0
	pgn,shredder_fen								0
	pgn,convert_lost_result_to_comment		1
	pgn,map_lost_result_to_unknown			1
	pgn,append_mode_to_event_type				0
	pgn,use_chessbase_format					0
	pgn,exclude_games_with_illegal_moves	0
	pgn,comment_to_html							0

	tex,margins,A2								{ 15 15 15 15 }
	tex,margins,A3								{ 15 15 15 15 }
	tex,margins,A4								{ 15 15 15 15 }
	tex,margins,A5								{ 15 15 15 15 }
	tex,margins,A6								{ 15 15 15 15 }
	tex,margins,B3								{ 15 15 15 15 }
	tex,margins,B4								{ 15 15 15 15 }
	tex,margins,B5								{ 15 15 15 15 }
	tex,margins,Letter						{  1  1  1  1 }
	tex,margins,Legal							{  1  1  1  1 }
	tex,margins,Executive					{  1  1  1  1 }

	encoding iso8859-1
}

array set Values [array get Defaults]

set Values(notation)			short
set Values(figurines)		graphic
set Values(type)				scidb
set Values(append)			0

set Values(pgn,encoding)	iso8859-1
set Values(scid,encoding)	iso8859-1
set Values(scidb,encoding)	utf-8

set Values(pdf,encoding)		iso8859-1
set Values(pdf,embed)			1
set Values(pdf,builtin)			0
set Values(pdf,fonts)			{}
set Values(pdf,paper)			[lsearch -exact -index 0 $Paper(pdf) A4]
set Values(pdf,paper,top)		0
set Values(pdf,paper,bottom)	0
set Values(pdf,paper,left)		0
set Values(pdf,paper,right)	0
set Values(pdf,custom)			{ 210 297 mm }
set Values(pdf,orientation)	Potrait
set Values(pdf,justification)	0
set Values(pdf,columns)			1

set Values(tex,paper)			[lsearch -exact -index 0 $Paper(tex) A4]
set Values(tex,paper,top)		0
set Values(tex,paper,bottom)	0
set Values(tex,paper,left)		0
set Values(tex,paper,right)	0
set Values(tex,custom)			{ 210 297 mm }
set Values(tex,orientation)	Potrait
set Values(tex,justification)	0
set Values(tex,columns)			1

if {$::tcl_platform(platform) eq "windows"} { set Values(pdf,embed) 0 }

array set Fields {
	pgn	{	include_varations include_comments include_marks indent_variations indent_comments
				convert_lost_result_to_comment add_country_after_player append_mode_to_event_type
				symbolic_annotation_style extended_symbolic_style shredder_fen column_style
				convert_null_moves comment_to_html space_after_move_number include_termination_tag
				include_mode_tag include_opening_tag include_setup_tag include_variant_tag
				include_position_tag include_time_mode_tag exclude_extra_tags use_chessbase_format
				exclude_games_with_illegal_moves
			}
	scid	{}
}

namespace import ::tcl::mathfunc::double
namespace import ::tcl::mathfunc::round
namespace import ::tcl::mathfunc::min


proc open {parent base type name view {closeViewAfterExit 0}} {
	variable icon::32x32::IconPDF
	variable icon::32x32::IconHtml
	variable icon::32x32::IconPS
	variable icon::36x36::IconPGN
	variable icon::37x21::IconTeX
	variable PdfEncodingList
	variable Types
	variable Icons
	variable Info
	variable Values

	if {[::scidb::view::count games $base $view] == 0} {
		::dialog::info -parent $parent -message $mc::NoGamesForExport
		return
	}

	set Info(base) $base
	set Info(name) $name
	set Info(type) $type
	set Info(view) $view

	set Info(after) {}
	set Info(encoding) [::scidb::db::get encoding $base]
	set Info(pdf-encoding) 0

	if {$type ne "scidb" && $Info(encoding) ni $PdfEncodingList} {
		set Info(pdf-encoding) 1
	}

	set dlg [toplevel $parent.export -class Dialog]
	bind $dlg <Alt-Key> [list tk::AltKeyInDialog $dlg %A]
	if {$closeViewAfterExit} { bind $dlg <Destroy> [namespace code CloseView] }
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top

	array set icons [list          \
		scidb	$::icon::32x32::logo  \
		scid	$::icon::32x32::scid3 \
		pgn	$IconPGN              \
		pdf	$IconPDF              \
		html	$IconHtml             \
		tex	$IconTeX              \
		ps		$IconPS               \
	]
	set bwd 2

	set list [::tlistbox $top.list -height [llength $Types] -usescroll no -padx 10 -pady 8]
	pack $list -expand yes -fill both
	$list addcol combined -id item
	foreach type $Types {
		$list insert [list [list $icons($type) $mc::FormatName($type)]]
		set Info($type,flags) 0
	}
	$list resize

	set nb [ttk::notebook $top.nb -takefocus 1]
	bind $list <<ListboxSelect>> [namespace code [list Select $nb %d]]
	bind $nb <ButtonPress-1> [list focus $nb]
	ttk::notebook::enableTraversal $nb
	lappend opts -ok [namespace code [list SaveScidb $parent $dlg]]
	lappend opts -cancel [list destroy $dlg]
	lappend opts -parent $nb
	lappend opts -embed 1
	lappend opts -verifycmd [namespace code VerifyPath]
	lappend opts -initialfile [file rootname [file tail $base]]
	set Info(fsbox) [::dialog::saveFile {*}$opts]
	$nb add $Info(fsbox) -sticky nsew
	::widget::notebookTextvarHook $nb $Info(fsbox) [namespace current]::mc::FileSelection

	set fmode [tk::AmpWidget ttk::checkbutton $top.fmode  \
		-variable [namespace current]::Values(append) \
		-text $mc::AddGamesToExisitingFile \
		-command [namespace code SetupFileMode]]

	foreach {tab text} {	options Options
								style Style
								setup_pdf PageSetup
								setup_tex PageSetup
								encoding Encoding} {
		set f [ttk::frame $nb.$tab]
		$nb add $f -sticky nsew
		::widget::notebookTextvarHook $nb $f [namespace current]::mc::$text
		set Info(configure-$tab) 1
	}
	set Info(configure-encoding-pgn) 1
	set Info(configure-encoding-pdf) 1

	foreach type {pgn pdf} {
		grid [BuildOptionsFrame_$type $nb.options.$type] -row 1 -column 1 -sticky nsew
	}
	grid rowconfigure $nb.options 1 -weight 1

	grid $list	-row 1 -column 1 -sticky ns
	grid $nb		-row 1 -column 3 -sticky nsew
	grid $fmode	-row 1 -column 3 -sticky ne
	
	grid columnconfigure $top {0 2 4} -minsize $::theme::padding
	grid rowconfigure $top {0 2} -minsize $::theme::padding

	set index [lsearch -exact $Types $Values(type)]
	Select $nb $index
	$list select $index

	wm withdraw $dlg
	wm title $dlg [format $mc::ExportDatabaseTitle $name]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm resizable $dlg false false
	wm transient $dlg $parent
	::util::place $dlg center [winfo toplevel $parent]
	wm deiconify $dlg

	ttk::grabWindow $dlg
	tkwait window $dlg
	ttk::releaseGrab $dlg
}


proc VerifyPath {w args} {
	variable Values

	set path "$args"

	switch $Values(type) {
		scidb - scid	{ set path [::menu::verifyDatabaseName $w $path] }
		default			{ set path [::menu::verifyPath $w $path] }
	}

	return $path
}


proc Pow2 {x} { return [expr {1 << $x}] }


proc Exclude {type flag} {
	variable Info
	variable Flags

	set Info($type,flags) [expr {$Info($type,flags) & ~[Pow2 $Flags($type,$flag)]}]
}


proc BuildOptionsFrame_pgn {w} {
	variable Flags
	variable Values
	variable Fields
	variable Info

	ttk::frame $w

	set flags [Pow2 $Flags(pgn,include_annotation)]
	set count 0
	set nrows [expr {([llength $Fields(pgn)] + 1)/2}]

	foreach field $Fields(pgn) {
		ttk::checkbutton $w.$field \
			-variable [namespace current]::Values(pgn,$field) \
			-text $mc::Option(pgn,$field) \
			-command [namespace code [list SetupFlags $w pgn]] \
			;
		set row [expr {2*($count % $nrows) + 3}]
		set col [expr {2*($count / $nrows) + 1}]
		grid $w.$field -row $row -column $col -sticky w
		incr count
	}
	set b [ttk::frame $w.buttons]
	ttk::button $b.reset -text $mc::ResetDefaults -command [namespace code [list Reset $w pgn]]
	if {$count % 2} { incr count }
	incr count 2
	grid $b.reset -row 0 -column 0 -sticky w
	grid columnconfigure $b 1 -minsize $::theme::padding
	grid $b -row [expr {$count + 1}] -column 1 -columnspan 3 -sticky w

	for {set i 0} {$i < $count} {incr i 2} { lappend rows $i }
	grid rowconfigure $w $rows -minsize $::theme::padding
	grid rowconfigure $w $count -minsize [expr {2*$::theme::padding}]
	grid rowconfigure $w [expr {$count + 2}] -minsize $::theme::padding
	grid columnconfigure $w {0 4} -minsize $::theme::padding
	grid columnconfigure $w 2 -minsize [expr {2*$::theme::padding}]
	SetupFlags $w pgn

	return $w
}


proc BuildOptionsFrame_pdf {w} {
	variable Notation
	variable NotationList
	variable Figurines
	variable FigurinesList
	variable Values
	variable Colors

	ttk::frame $w

	set Notation {}
	foreach entry {short long algebraic correspondence telegraphic} {
		lappend Notation [list $entry [set mc::[string toupper $entry 0 0]]]
	}
	set NotationList {}
	foreach entry $Notation { lappend NotationList [lindex $entry 1] }

	set Figurines {}
	foreach lang [array names ::font::figurines] {
		if {$lang ne "graphic"} {
			lappend Figurines [list $lang [::encoding::languageName $lang]]
		}
	}
	set Figurines [lsort -index 1 -dictionary $Figurines]
	set Figurines [linsert $Figurines 0 [list graphic $mc::Graphic]]
	set FigurinesList {}
	foreach entry $Figurines { lappend FigurinesList [lindex $entry 1] }

	foreach {what hasScrollbar} {figurines 1 notation 0} {
		set var [string toupper $what 0 0]
		ttk::labelframe $w.$what -text [set mc::$var]
		ttk::frame $w.$what.list
		listbox $w.$what.list.lb \
			-selectmode single \
			-exportselection false \
			-listvariable [namespace current]::${var}List
		bind $w.$what.list.lb <<ListboxSelect>> [namespace code [list Set$var $w.$what]]
		bind $w.$what.list <Configure> [namespace code [list ConfigureListbox $w.$what.list %h]]
		label $w.$what.sample -borderwidth 2 -relief sunken
		label $w.$what.sample.text -background white
		pack $w.$what.sample.text -fill both -expand yes
		pack propagate $w.$what.sample 0
		pack $w.$what.list.lb -side left
		if {$hasScrollbar} {
			$w.$what.list.lb configure -yscrollcommand "$w.$what.list.sb set"
			::ttk::scrollbar $w.$what.list.sb -orient vertical -command "$w.$what.list.lb yview"
			pack $w.$what.list.sb -side left -fill y -expand yes
			incr lastcol
		}
		grid $w.$what.list   -row 1 -column 1 -sticky ns
		grid $w.$what.sample -row 3 -column 1 -sticky ew
		grid rowconfigure $w.$what 0 -minsize 2
		grid rowconfigure $w.$what 2 -minsize $::theme::padding
		grid rowconfigure $w.$what {2 4} -weight 1
		grid rowconfigure $w.$what 1 -weight 1000000
		grid rowconfigure $w.$what 4 -minsize [expr {$::theme::padding + 2}]
		grid columnconfigure $w.$what {0 2} -minsize [expr {$::theme::padding + 2}]
	}

	$w.figurines.list.lb itemconfigure 0 -background $Colors(highlight)

	ttk::labelframe $w.options -text $mc::FontHandling
	ttk::checkbutton $w.options.builtin \
		-text $mc::UseBuiltinFonts \
		-variable [namespace current]::Values(pdf,builtin) \
		-command [namespace code UseBuiltinFonts]
	ttk::checkbutton $w.options.embed \
		-text $mc::EmebedTruetypeFonts \
		-variable [namespace current]::Values(pdf,embed)
	grid $w.options.builtin -column 1 -row 1 -sticky w
	grid $w.options.embed   -column 1 -row 3 -sticky w
	grid columnconfigure $w.options {0 2} -minsize $::theme::padding
	grid rowconfigure $w.options {0 2} -minsize $::theme::padding

	grid $w.figurines -row 1 -column 1 -sticky ns
	grid $w.notation  -row 1 -column 3 -sticky ns
	grid $w.options   -row 1 -column 5 -sticky ns
	grid rowconfigure $w {0 2} -minsize $::theme::padding
	grid rowconfigure $w 1 -weight 1
	grid columnconfigure $w {0 2 4 6} -minsize $::theme::padding

	return $w
}


proc UseBuiltinFonts {} {
	variable Values

	if {$Values(pdf,builtin)} {
		set Values(pdf,fonts) {Courier Helvetica Times-Roman}
		# TODO map fonts
	} else {
		set Values(pdf,fonts) {}
		# TODO map fonts
	}

	if {[info exists Values(fontsel)]} {
		StyleSelected $Values(fonttree) 0
	}
}


proc SetupOptions {pane} {
	variable Values
	variable Figurines
	variable Notation

	set index [lsearch -exact -index 0 $Figurines $Values(figurines)]
	$pane.pdf.figurines.list.lb selection clear 0 end
	$pane.pdf.figurines.list.lb selection set $index
	SetFigurines $pane.pdf.figurines

	set index [lsearch -exact -index 0 $Notation $Values(notation)]
	$pane.pdf.notation.list.lb selection clear 0 end
	$pane.pdf.notation.list.lb selection set $index
	SetNotation $pane.pdf.notation

	if {$Values(type) eq "pdf"} {
		grid $pane.pdf.options
	} else {
		grid remove $pane.pdf.options
	}
}


proc ConfigureListbox {list height} {
	array set metrics [font metrics [$list.lb cget -font]]
	set linespace [expr {$metrics(-linespace) + 1}]
	set nrows [expr {$height/$linespace}]
	$list.lb configure -height $nrows
	bind $list <Configure> {}
}


proc SetNotation {w} {
	variable Notation
	variable Values

	set notation [lindex $Notation [$w.list.lb curselection] 0]
	set Values(pdf,notation) $notation

	switch $notation {
		short				{ $w.sample.text configure -text "1.e4 Nf6" }
		long				{ $w.sample.text configure -text "1.e2-e4 g8-f6" }
		algebraic		{ $w.sample.text configure -text "1.e2e4 g8f6" }
		correspondence	{ $w.sample.text configure -text "1.5254 7866" }
		telegraphic		{ $w.sample.text configure -text "1.GEGO WATI" }
	}
}


proc SetFigurines {w} {
	variable Figurines
	variable Values

	set lang [lindex $Figurines [$w.list.lb curselection] 0]
	set Values(pdf,figurines) $lang
	if {$lang eq "graphic"} {
		$w.sample.text configure -font ::font::figurine
	} else {
		$w.sample.text configure -font TkTextFont
	}
	$w.sample.text configure -text [join [split $::font::figurines($lang) {}] " "]
}


proc ConfigureHeight {w h} {
	if {$h <= 1} { return }
	array set metrics [font metrics [$w.list cget -font]]
	$w.list configure -height [expr {($h - 2*$::theme::padding)/($metrics(-linespace) + 1)}]
	bind $w <Configure> {}
}


proc SetEncoding {w} {
	variable Values
	set Values(scid,encoding) [lindex $Values(encoding-list) [$w curselection]]
}


proc Reset {w type} {
	variable Defaults
	variable Values

	foreach field [array names Defaults -glob $type,*] {
		set Values($field) $Defaults($field)
	}

	switch $type {
		pgn { SetupFlags $w $type }
	}
}


proc SetupFlags {w type} {
	variable Values
	variable Info
	variable Flags
	variable Fields

	set flags 0
	foreach field $Fields($type) {
		if {$Values($type,$field)} {
			set flags [expr {$flags | [Pow2 $Flags($type,$field)]}]
		}
	}
	set Info($type,flags) $flags

	switch $type {
		pgn {
			if {$Values(pgn,symbolic_annotation_style)} {
				$w.extended_symbolic_style configure -state normal
			} else {
				$w.extended_symbolic_style configure -state disabled
				Exclude pgn extended_symbolic_style
			}
			if {$Values(pgn,exclude_games_with_illegal_moves)} {
				set flags [expr {$flags & ~[Pow2 $Flags($type,$field)]}]
			}
		}
	}
}


proc SetupFileMode {} {
	variable Values
	variable Info

	set type save
	if {$Values(type) eq "pgn" && $Values(append)} { set type open }
	::dialog::fsbox::changeFileDialogType $Info(fsbox) $type
}


proc HideTab {nb tab} { $nb tab $tab -state hidden }
proc ShowTab {nb tab} { $nb tab $tab -state normal }


proc Select {nb index} {
	variable PdfEncodingList
	variable Types
	variable Info
	variable Values

	if {[llength $index] == 0} { return }	;# ignore double click
	set fmode [winfo parent $nb].fmode
	set Values(type) [lindex $Types $index]
	if {$Values(type) eq "pgn"} { grid $fmode } else { grid remove $fmode }
	grid remove $nb.options.pgn
	grid remove $nb.options.pdf

	switch $Values(type) {
		scidb {
			HideTab $nb $nb.options
			HideTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			HideTab $nb $nb.style
			HideTab $nb $nb.encoding
			set var $::menu::mc::ScidbBases
			set ext .sci
		}

		scid {
			HideTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			HideTab $nb $nb.style
			HideTab $nb $nb.options
			if {$Info(type) eq "scidb"} {
				ShowTab $nb $nb.encoding
			} else {
				HideTab $nb $nb.encoding
			}
			set var $::menu::mc::AllScidBases
			set ext {.si4 .si3}
		}

		pgn {
			ShowTab $nb $nb.options
			HideTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			HideTab $nb $nb.style
			if {$Info(type) eq "scidb"} {
				ShowTab $nb $nb.encoding
			} else {
				HideTab $nb $nb.encoding
			}
			grid $nb.options.pgn
			set var $::menu::mc::PGNFiles
			set ext {.pgn .pgn.gz .zip}
		}

		pdf {
			ShowTab $nb $nb.options
			ShowTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			ShowTab $nb $nb.style
			if {$Info(type) eq "scidb" || $Info(pdf-encoding)} {
				ShowTab $nb $nb.encoding
			} else {
				HideTab $nb $nb.encoding
			}
			grid $nb.options.pdf
			SetupOptions $nb.options
			set Values(useCustom) 1
			set var $mc::PdfFiles
			set ext .pdf
		}

		html {
			ShowTab $nb $nb.options
			HideTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			ShowTab $nb $nb.style
			HideTab $nb $nb.encoding
			grid $nb.options.pdf
			SetupOptions $nb.options
			set var $mc::HtmlFiles
			if {$::tcl_platform(platform) eq "windows"} { set ext .htm } else { set ext .html }
		}

		tex {
			ShowTab $nb $nb.options
			HideTab $nb $nb.setup_pdf
			ShowTab $nb $nb.setup_tex
			ShowTab $nb $nb.style
			HideTab $nb $nb.encoding
			grid $nb.options.pdf
			SetupOptions $nb.options
			set Values(useCustom) 0
			set var $mc::TeXFiles
			set ext {.tex .ltx}
		}
	}

	if {[$nb tab $nb.setup_pdf -state] eq "normal"} {
		if {$Info(configure-setup_pdf)} {
			ConfigureSetup $nb.setup_pdf
			set Info(configure-setup_pdf) 0
		}
	}

	if {[$nb tab $nb.setup_tex -state] eq "normal"} {
		if {$Info(configure-setup_tex)} {
			ConfigureSetup $nb.setup_tex
			set Info(configure-setup_tex) 0
		}
	}

	if {[$nb tab $nb.style -state] eq "normal"} {
		if {$Info(configure-style)} {
			ConfigureStyle $nb.style
			set Info(configure-style) 0
		}
	}

	if {[$nb tab $nb.encoding -state] eq "normal"} {
		if {$Values(type) eq "pdf"} { set encTab pdf } else { set encTab pgn }
		if {$Info(configure-encoding-$encTab)} {
			if {$Values(type) eq "pdf"} { set encList $PdfEncodingList } else { set encList {} }
			bind $nb.encoding <Configure> \
				+[namespace code [list ConfigureEncoding $nb.encoding $encTab $encList]]
			set Info(configure-encoding-$encTab) 0
		} elseif {[winfo exists $nb.encoding.$encTab]} {
			if {$Values(type) eq "pdf" && $Info(pdf-encoding)} {
				set encoding $Info(encoding)
			} else {
				set encoding $Values($Values(type),encoding)
			}
			raise $nb.encoding.$encTab
			focus $nb.encoding.$encTab
			::encoding::select $nb.encoding.$encTab $encoding
		}
	}

	::dialog::fsbox::setFileTypes $Info(fsbox) [list [list $var $ext]]
	SetupFileMode
}


proc ConfigureEncoding {w tab encList} {
	variable Info
	variable Values
	variable Defaults

	if {[winfo exists $w.$tab]} { return }

	if {$Values(type) eq "pdf" && $Info(pdf-encoding)} {
		set encoding $Info(encoding)
	} else {
		set encoding $Values($Values(type),encoding)
	}

	if {$Info(type) ne "scidb"} { set currentEncoding $encoding } else { set currentEncoding {} }
	::encoding::build $w.$tab $currentEncoding $Defaults(encoding) [winfo width $w] {} $encList
	if {$Values(type) eq "pdf" && $Info(pdf-encoding)} {
		::encoding::activate $w.$tab $Defaults(encoding)
	} else {
		::encoding::select $w.$tab $encoding
	}
	bind $w.$tab <<TreeControlSelect>> [namespace code [list SetEncoding %d]]
	grid $w.$tab -row 0 -column 0 -sticky nsew
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 0 -weight 1
}


proc SetEncoding {encoding} {
	variable Values
	variable Info

	if {[llength $encoding]} {
		if {$Values(type) eq "pdf" && $Info(pdf-encoding)} {
			set Info(encoding) $encoding
		} else {
			set Values($Values(type),encoding) $encoding
		}
	}
}


proc ConfigureStyle {w} {
	variable StyleLayout
	variable Styles
	variable Values

	treectrl $w.t \
		-highlightthickness 0 \
		-borderwidth 1 \
		-relief sunken \
		-background white \
		-linestyle solid \
		-showheader 0 \
		-showbuttons no \
		-width 175 \
		-takefocus 1 \
		;
	bind $w.t <ButtonPress-1> [namespace code [list SelectStyle %W %x %y]]
	set height [font metrics [$w.t cget -font] -linespace]
	if {$height < 18} { set height 18 }
	$w.t configure -itemheight $height

	$w.t column create -tags item
	$w.t configure -treecolumn item
	$w.t element create elemTxt text -lines 1
	$w.t element create elemSel rect -fill {#ffdd76 selected} -showfocus 1
	$w.t style create style
	$w.t style elements style {elemSel elemTxt}
	$w.t style layout style elemTxt -padx {4 0}
	$w.t style layout style elemSel -union {elemTxt} -ipadx 2

	foreach entry $StyleLayout($Values(type)) {
		lassign $entry depth name
		if {$depth == 0} {
			$w.t item style set root item style
			$w.t item element configure root item elemTxt -text [set mc::$name]
			set parentList {root {} {} {} {} {} {}}
		} else {
			incr depth -1
			set item [$w.t item create -button 1]
			$w.t item style set $item item style
			$w.t item element configure $item item elemTxt -text [set mc::$name]
			$w.t item lastchild [lindex $parentList $depth] $item
			incr depth
			set parentList [lreplace $parentList $depth $depth $item]
		}
	}
	$w.t selection add 0
	$w.t activate 0
	$w.t notify bind $w.t <Selection> [namespace code [list StyleSelected $w.t %S]]

	ttk::scrollbar $w.sh -orient horizontal -command [list $w.t xview]
	$w.t notify bind $w.sh <Scroll-x> { ::widget::sbset %W %l %u }
	bind $w.sh <ButtonPress-1> [list focus $w.t]
	ttk::scrollbar $w.sv -orient vertical -command [list $w.t yview]
	$w.t notify bind $w.sv <Scroll-y> { ::widget::sbset %W %l %u }
	bind $w.sv <ButtonPress-1> [list focus $w.t]

	set type $Values(type)
	set Values(style) [lindex $StyleLayout($Values(type)) 0 1]
	set basic $Styles($type,$Values(style))
	lassign $basic family size weight slant color
	set font [font create -family $family -size $size -weight $weight -slant $slant]
	if {$family eq "Helvetica"} {
		variable ::dialog::choosefont::Helvetica
		array set attrs [font actual $font]
		set index 0
		while {$index < [llength $Helvetica] && [string compare -nocase $attrs(-family) $family]} {
			set family [lindex $Helvetica $index]
			set font [font create -family $family -size $size -weight $weight -slant $slant]
			array set attrs [font actual $font]
		}
		if {[string compare -nocase $attrs(-family) $family] == 0} {
			lset Styles($type,$Values(style)) 0 $family
		}
	}
	::dialog::::choosefont::build $w.fontsel $font {} $color
	bind $w.fontsel <<FontSelected>> [namespace code [list FontSelected %d]]
	bind $w.fontsel <<FontColor>> [namespace code [list FontColor %d]]

	set Values(fontsel) $w.fontsel
	set Values(fonttree) $w.t
	StyleSelected $w.t 0

	grid $w.t  			-row 1 -column 1 -sticky nsew
	grid $w.sv			-row 1 -column 2 -sticky ns
	grid $w.sh			-row 2 -column 1 -sticky ew
	grid $w.fontsel	-row 1 -column 4 -sticky nsew -rowspan 2

	grid columnconfigure $w 4 -weight 1
	grid columnconfigure $w {0 3 5} -minsize $::theme::padding
	grid columnconfigure $w 3 -minsize [expr {2*$::theme::padding}]
	grid rowconfigure $w 1 -weight 1
	grid rowconfigure $w {0 3} -minsize $::theme::padding
}


proc SelectStyle {tree x y} {
	set id [$tree identify $x $y]
	if {[string length $id] == 0} { return }
	if {[lindex $id 0] eq "header"} { return }
	set item [lindex $id 1]
	$tree selection anchor $item
	$tree selection modify $item all
}


proc StyleSelected {tree index} {
	variable StyleLayout
	variable Styles
	variable Values

	set type $Values(type)
	set style ""
	set parent $index
	while {[llength $parent]} {
		set style [join [list [lindex $StyleLayout($Values(type)) $parent 1] {*}$style] ","]
		set parent [$tree item parent $parent]
	}
	set Values(style) $style

	lassign {{} {} {} {} {}} family size weight slant color
	set style [join [lreplace [split $style ","] end end] ","]
	while {[llength $style]} {
		lassign $Styles($type,$style) f s w l c
		set style [join [lreplace [split $style ","] end end] ","]
		if {[llength $family] == 0} { set family $f }
		if {[llength $size  ] == 0} { set size   $s }
		if {[llength $weight] == 0} { set weight $w }
		if {[llength $slant ] == 0} { set slant  $l }
		if {[llength $color ] == 0} { set color  $c }
	}
	set Values($type,family) $family
	set Values($type,size)   $size
	set Values($type,weight) $weight
	set Values($type,slant)  $slant
	set Values($type,color)  $color

	lassign $Styles($type,$Values(style)) f s w l c
	if {[llength $f]} { set family $f }
	if {[llength $s]} { set size   $s }
	if {[llength $w]} { set weight $w }
	if {[llength $l]} { set slant  $l }
	if {[llength $c]} { set color  $c }

	set Values(fontType) [lindex $StyleLayout($Values(type)) $index 1]

	switch -glob -- $Values(fontType) {
		Figurines	{ set fonts $::font::chessFigurineFonts }
		Diagram		{ set fonts $::font::chessDiagramFonts }
		Symbols		{ set fonts $::font::chessSymbolFonts }
		default		{ set fonts $Values(pdf,fonts) }
	}

	::dialog::::choosefont::setFonts $Values(fontsel) $fonts
	UpdateSample $family
	::dialog::::choosefont::select $Values(fontsel) \
		-family $family \
		-size $size \
		-weight $weight \
		-slant $slant \
		-color $color
}


proc UpdateSample {family} {
	variable Values

	set sample ""

	switch $Values(fontType) {
		Diagram {
			upvar 0 ::font::[set ::font::chessDiagramFontsMap($family)] encoding
			foreach code {lite,wk lite,wq lite,wr lite,wb lite,wn lite,wp} {
				append sample $encoding($code)
			}
		}
		Symbols {
			set sample ""
			upvar 0 ::font::[set ::font::chessSymbolFontsMap($family)] encoding
			foreach nag {7 13 14 16 40 140 142 149 151 156} {
				if {[info exists encoding($nag)]} {
					if {[llength $sample]} { append sample " " }
					append sample $encoding($nag)
				}
			}
			set i [expr {[string length $sample]/2}]
			set sample [string replace $sample $i [expr {$i + 1}] "\n"]
		}
		Figurines {
			variable ::font::chessFigurineFontsMap
			set encoding $chessFigurineFontsMap($family)
			set sample [join [split $::font::figurines(graphic) {}] " "]
			if {[llength $encoding]} { set sample [string map $encoding $sample] }
		}
		default {
			set sample {}
		}
	}

	::dialog::::choosefont::setSample $Values(fontsel) $sample
}


proc FontSelected {fontInfo} {
	variable StyleLayout
	variable Styles
	variable Values

	set type $Values(type)
	lassign $fontInfo family size weight slant
	set color [lindex $Styles($type,$Values(style)) 4]

	if {$Values(style) ne [lindex $StyleLayout($Values(type)) 0 1]} {
		foreach item {family size weight slant} {
			if {[set $item] eq $Values($type,$item)} { set $item {} }
		}
	}

	set Styles($type,$Values(style)) [list $family $size $weight $slant $color]
	switch $Values(fontType) { Symbols - Diagram - Figurines { UpdateSample $family } }
}


proc FontColor {color} {
	variable Values
	variable Styles

	set type $Values(type)
	set color [::dialog::choosecolor::getActualColor $color]
	if {$color eq $Values($type,color)} { set color {} }
	lset Styles($type,$Values(style)) 4 $color
}


proc ConfigureSetup {w} {
	variable Paper
	variable Margin
	variable Info
	variable Values
	variable Colors

	set type $Values(type)
	set Info($type,formats) {}
	foreach format $Paper($type) {
		lassign $format id width height units
		lappend Info($type,formats) "$id ($width x $height $units)"
	}
	set Info($type,paper,textvar) [lindex $Info($type,formats) $Values($type,paper)]
	if {$Values(useCustom)} {
		lassign $Values($type,custom) \
			Info($type,paper,width) Info($type,paper,height) Info($type,paper,units)
		lappend Info($type,formats) $mc::Custom
		set Info($type,paper,units,textvar) $Info($type,paper,units)
	}

	canvas $w.c \
		-borderwidth 2 \
		-relief sunken \
		-width 1 \
		-height 1 \
		-background [::theme::getBackgroundColor] \
		;
	$w.c xview moveto 0
	$w.c yview moveto 0
	$w.c create rectangle 0 0 0 0 -tag shadow -fill $Colors(shadow) -outline $Colors(shadow)
	$w.c create rectangle 0 0 0 0 -tag paper -fill white -outline black
	$w.c create rectangle 0 0 0 0 -tag left -fill white -outline $Colors(text)
	$w.c create rectangle 0 0 0 0 -tag right -fill white -outline $Colors(text)

	ttk::labelframe $w.paper -text $mc::Paper
	if {$Values(useCustom)} {
		ttk::labelframe $w.margins -text $mc::Margin
	}
	ttk::labelframe $w.orient -text $mc::Orientation
	ttk::labelframe $w.just -text $mc::Justification
	ttk::labelframe $w.columns -text $mc::Columns

	ttk::label $w.paper.lformat -text $mc::Format
	ttk::combobox $w.paper.cbformat \
		-state readonly \
		-values $Info($type,formats) \
		-textvariable [namespace current]::Info($type,paper,textvar)
	bind $w.paper.cbformat <<ComboboxSelected>> [namespace code [list ConfigureWidgets $w paper]]

	grid $w.paper.lformat	-row 1 -column 1 -sticky w
	grid $w.paper.cbformat	-row 1 -column 3 -sticky ew -columnspan 7

	if {$Values(useCustom)} {
		ttk::label $w.paper.lsize -text $mc::Size
		ttk::entry $w.paper.width -width 5 -textvariable [namespace current]::Info($type,paper,width)
		::validate::entryFloat $w.paper.width
		$w.paper.width configure -validatecommand [namespace code [list SizeChanged $w %P]]
		ttk::label $w.paper.x -text "x"
		ttk::entry $w.paper.height -width 5 -textvariable [namespace current]::Info($type,paper,height)
		::validate::entryFloat $w.paper.height
		$w.paper.height configure -validatecommand [namespace code [list SizeChanged $w %P]]
		ttk::combobox $w.paper.units \
			-state readonly \
			-values {mm in pt} \
			-width 3 \
			-textvariable [namespace current]::Info($type,paper,units,textvar)
		bind $w.paper.units <<ComboboxSelected>> [namespace code [list ConfigureWidgets $w]]

		grid $w.paper.lsize		-row 3 -column 1 -sticky w
		grid $w.paper.width		-row 3 -column 3 -sticky ew
		grid $w.paper.x			-row 3 -column 5 -sticky ew
		grid $w.paper.height		-row 3 -column 7 -sticky ew
		grid $w.paper.units		-row 3 -column 9 -sticky ew
	}

	grid rowconfigure $w.paper {0 2 4} -minsize $::theme::padding
	grid columnconfigure $w.paper {0 2 10} -minsize $::theme::padding
	grid columnconfigure $w.paper {4 6 8} -minsize 2
	grid columnconfigure $w.paper {3 7} -weight 1

	foreach dir {top bottom left right} {
		set Info($type,paper,$dir) $Values($type,paper,$dir)
	}

	if {$Values(useCustom)} {
		if {$Values($type,paper) == [llength $Paper($type)]} {
			set units [lindex $Values($type,custom) 2]
		} else {
			set units [lindex $Paper($type) $Values($type,paper) 3]
		}
		set margin $Margin($units)
		foreach {dir row col} {top 1 1 bottom 3 1 left 1 5 right 3 5} {
			set text [string toupper $dir 0 0]
			if {$Info($type,paper,$dir) == 0} { set Info($type,paper,$dir) $margin }
			ttk::label $w.margins.l$dir -text [set mc::$text]
			ttk::entry $w.margins.s$dir -width 5 -textvariable [namespace current]::Info($type,paper,$dir)
			::validate::entryFloat $w.margins.s$dir
			$w.margins.s$dir configure -validatecommand [namespace code [list MarginChanged $w $dir %P]]
			grid $w.margins.l$dir -row $row -column $col -sticky w
			grid $w.margins.s$dir -row $row -column [expr {$col + 2}] -sticky ew
		}
		
		grid rowconfigure $w.margins {0 3 5} -minsize $::theme::padding
		grid columnconfigure $w.margins {0 2 6 8} -minsize $::theme::padding
		grid columnconfigure $w.margins {3 7} -weight 1
		grid columnconfigure $w.margins 4 -minsize [expr {2*$::theme::padding}]
	}

	ttk::radiobutton $w.orient.potrait \
		-text $mc::Potrait \
		-value Potrait \
		-command [namespace code [list RefreshPreview $w]] \
		-variable [namespace current]::Values($type,orientation)
	ttk::radiobutton $w.orient.landscape \
		-text $mc::Landscape \
		-value Landscape \
		-command [namespace code [list RefreshPreview $w]] \
		-variable [namespace current]::Values($type,orientation)

	grid $w.orient.potrait		-row 1 -column 1 -sticky w
	grid $w.orient.landscape	-row 1 -column 3 -sticky w
	grid rowconfigure $w.orient {0 3} -minsize $::theme::padding
	grid columnconfigure $w.orient {0 4} -minsize $::theme::padding
	grid columnconfigure $w.orient 2 -minsize [expr {2*$::theme::padding}]

	ttk::radiobutton $w.just.left \
		-text $mc::Left \
		-value 0 \
		-command [namespace code [list RefreshPreview $w]] \
		-variable [namespace current]::Values($type,justification)
	ttk::radiobutton $w.just.even \
		-text $mc::Even \
		-value 1 \
		-command [namespace code [list RefreshPreview $w]] \
		-variable [namespace current]::Values($type,justification)

	grid $w.just.left -row 1 -column 1 -sticky w
	grid $w.just.even -row 1 -column 3 -sticky w
	grid rowconfigure $w.just {0 3} -minsize $::theme::padding
	grid columnconfigure $w.just {0 4} -minsize $::theme::padding
	grid columnconfigure $w.just 2 -minsize [expr {2*$::theme::padding}]

	ttk::radiobutton $w.columns.one \
		-text $mc::One \
		-value 1 \
		-command [namespace code [list RefreshPreview $w]] \
		-variable [namespace current]::Values($type,columns)
	ttk::radiobutton $w.columns.two \
		-text $mc::Two \
		-value 2 \
		-command [namespace code [list RefreshPreview $w]] \
		-variable [namespace current]::Values($type,columns)

	grid $w.columns.one -row 1 -column 1 -sticky w
	grid $w.columns.two -row 1 -column 3 -sticky w
	grid rowconfigure $w.columns {0 3} -minsize $::theme::padding
	grid columnconfigure $w.columns {0 4} -minsize $::theme::padding
	grid columnconfigure $w.columns 2 -minsize [expr {2*$::theme::padding}]

	ttk::button $w.reset -text $mc::ResetDefaults -command [namespace code [list ResetPaper $w]]

	grid $w.paper		-row  2 -column 1 -sticky ew -columnspan 3
	if {$Values(useCustom)} {
		grid $w.margins	-row  4 -column 1 -sticky ew -columnspan 3
	}
	grid $w.orient		-row  6 -column 1 -sticky ew -columnspan 3
	grid $w.just		-row  8 -column 1 -sticky ew
	grid $w.columns	-row  8 -column 3 -sticky ew
	grid $w.reset		-row 10 -column 1 -sticky w -columnspan 3
	grid $w.c			-row  1 -column 5 -sticky nsew -rowspan 11

	if {$Values(useCustom)} {
		grid rowconfigure $w {0 3 5 7 11 13} -minsize $::theme::padding
	} else {
		grid rowconfigure $w {0 3 7 11 13} -minsize $::theme::padding
	}
	grid rowconfigure $w 9 -minsize [expr {2*$::theme::padding}]
	grid rowconfigure $w 11 -weight 1
	grid columnconfigure $w {0 2 4 6} -minsize $::theme::padding
	grid columnconfigure $w 5 -weight 1

	ConfigureWidgets $w
	bind $w.c <Configure> [namespace code [list RefreshPreview $w]]
}


proc RefreshPreview {w} {
	variable Paper
	variable Colors
	variable Random
	variable Values
	variable Info

	if {[winfo width $w.c] <= 1} { return }
	bind $w.c <Configure> {}
	after cancel $Info(after)
	set type $Values(type)

	foreach dir {top bottom left right} {
		if {[string match {*[0-9]*} $Info($type,paper,$dir)]} {
			set margin($dir) $Info($type,paper,$dir)
		} else {
			set margin($dir) 0
		}
	}

	if {$Values(useCustom) && $Values($type,paper) == [llength $Paper($type)]} {
		set pw $Info($type,paper,width)
		set ph $Info($type,paper,height)
		set units $Info($type,paper,units)
		set Values($type,custom) [list $pw $ph $units]
	} else {
		lassign [lindex $Paper($type) $Values($type,paper)] id pw ph units
	}
	if {[llength $pw] == 0} { set pw 0 }
	if {[llength $ph] == 0} { set ph 0 }
	if {$Values($type,orientation) eq "Landscape"} {
		set tmp $pw; set pw $ph; set ph $tmp
	}

	set width  [expr {[winfo width  $w.c] - 2*[$w.c cget -borderwidth]}]
	set height [expr {[winfo height $w.c] - 2*[$w.c cget -borderwidth]}]

	set cw [double [expr {$width  - 20}]]
	set ch [double [expr {$height - 20}]]

	set pw [double $pw]
	set ph [double $ph]

	set t [double $margin(top)]
	set b [double $margin(bottom)]
	set l [double $margin(left)]
	set r [double $margin(right)]

	if {$pw == 0 || $ph == 0} {
		set u 0
	} else {
		set u [expr {min($cw/$pw, $ch/$ph)}]
	}

	set pw [expr {$u*$pw}]
	set ph [expr {$u*$ph}]

	set t [expr {round($t*$u)}]
	set b [expr {round($b*$u)}]
	set l [expr {round($l*$u)}]
	set r [expr {round($r*$u)}]

	set x0 [expr {round(($width  - $pw)/2.0)}]
	set y0 [expr {round(($height - $ph)/2.0)}]
	set x1 [expr {round($x0 + $pw)}]
	set y1 [expr {round($y0 + $ph)}]

	set lx0 [expr {$x0 + $r}]
	set ly0 [expr {$y0 + $t}]
	set lx1 [expr {max($x0 + $r, $x1 - $l)}]
	set ly1 [expr {max($y0 + $t, $y1 - $b)}]

	if {$lx0 >= $lx1 || $ly0 >= $ly1} { lassign {0 0 0 0} lx0 lx1 ly0 ly1 }
	set tn [expr {min(2, (min($x1 - $x0, $y1 - $y0)*0.05))}]

	if {$Values($type,columns) == 1 || $lx1 == 0} {
		lassign {0 0 0 0 0} rx0 rx1 ry0 ry1
		set dirs {l}
	} else {
		set gap [expr {min(6, round(0.05*($x1 - $x0)))}]
		if {$gap % 2} { incr gap -1 }
		set xm [expr {$x0 + ($x1 - $x0)/2}]
		set rx0 [expr {min($lx1, $xm + $gap/2)}]
		set ry0 $ly0
		set rx1 $lx1
		set ry1 $ly1
		set lx1 [expr {max($lx0, $xm - $gap/2)}]
		if {$lx1 - $lx0 < $rx1 - $rx0} { incr rx0 }
		set dirs {l r}
	}
	set coords [list $lx0 $ly0 $lx1 $ly1]
	if {$Values($type,columns) == 2} { lappend coords $rx0 $ry0 $rx1 $ry1 }

	$w.c coords shadow [expr {$x0 + $tn}] [expr {$y0 + $tn}] [expr {$x1 + $tn}] [expr {$y1 + $tn}]
	$w.c coords paper $x0 $y0 $x1 $y1
	$w.c coords left $lx0 $ly0 $lx1 $ly1
	$w.c coords right $rx0 $ry0 $rx1 $ry1

	$w.c delete line
	set i 0
	if {$lx1 > $lx0} {
		set n [llength $Random]
		set even $Values($type,justification)
		foreach {x0 y0 x1 y1} $coords {
			set dx [expr {$x1 - $x0}]
			set xt 0.0
			while {$y0 < $y1} {
				set r [lindex $Random [expr {$i % $n}]]
				if {$even && ($r > 0.5 || $xt < $x1)} {
					set xt $x1
				} else {
					set xt [expr {min(max($x0, $x1 - 2), max(5, $x0 + round($r*$dx)))}]
				}
				set yt [expr {min($y1, $y0 + 2)}]
				set tags [list line line:$i]
				$w.c create rectangle $x0 $y0 $xt $yt -fill $Colors(text) -outline {} -tags $tags
				incr y0 4
				incr i
			}
		}
		if {$i % $n == 0} { incr i 10 }
	}
}


proc GetUnits {} {
	variable Paper
	variable Info
	variable Values

	set type $Values(type)

	if {$Values($type,paper) == [llength $Paper($type)]} {
		set units $Info($type,paper,units,textvar)
	} else {
		set units [lindex $Paper($type) $Values($type,paper) 3]
	}

	return $units
}


proc SizeChanged {w value} {
	variable Info
	variable Values

	set units [GetUnits]

	if {$units eq "in"} {
		set ok [::validate::validateFloat $value]
	} else {
		set ok [::validate::validateUnsigned $value 5]
	}

	if {$ok} {
		after cancel $Info(after)
		set Info(after) [after 250 [namespace code [list RefreshPreview $w]]]
	}

	return $ok
}


proc MarginChanged {w dir value} {
	variable Info
	variable Values

	set ok [SizeChanged $w $value]
	set type $Values(type)

	if {$ok && $Info($type,paper,$dir) != $value} {
		set Values($type,paper,$dir) [string trim $value]
		after cancel $Info(after)
		set Info(after) [after 250 [namespace code [list RefreshPreview $w]]]
	}

	return $ok
}


proc ConfigureWidgets {w {action {}}} {
	variable Paper
	variable Values
	variable Info
	variable Defaults

	set type $Values(type)
	set Values($type,paper) [lsearch -exact $Info($type,formats) [$w.paper.cbformat get]]

	if {$Values(useCustom)} {
		if {$Values($type,paper) == [llength $Paper($type)]} {
			$w.paper.width configure -state normal
			$w.paper.height configure -state normal
			$w.paper.units configure -state readonly
			set units $Info($type,paper,units,textvar)
		} else {
			foreach name {width height units} {
				$w.paper.$name configure -state disabled
			}
			set units [lindex $Paper($type) $Values($type,paper) 3]
		}

		if {$action ne "reset" && $Info($type,paper,units) ne $units} {
			switch $Info($type,paper,units)->$units {
				mm->in { set factor [expr {1.0/25.4}] }
				mm->pt { set factor [expr {72.0/25.4}] }
				in->mm { set factor 25.4 }
				in->pt { set factor 72.0 }
				pt->mm { set factor [expr {25.4/72.0}] }
				pt->in { set factor [expr {1.0/72.0}] }
			}

			set Info($type,paper,units) $units

			if {$action ne "paper" && $Values($type,paper) == [llength $Paper($type)]} {
				foreach attr {width height} {
					set Info($type,paper,$attr) [Round [expr {$Info($type,paper,$attr)*$factor}] $units]
				}
			}

			foreach attr {top bottom left right} {
				set Info($type,paper,$attr) [Round [expr {$Info($type,paper,$attr)*$factor}] $units]
				set Values($type,paper,$attr) [Round [expr {$Values($type,paper,$attr)*$factor}] $units]
			}
		}

		$w.margins configure -text "$mc::Margin ($units)"
	} else {
		lassign $Defaults(tex,margins,[lindex $Paper($type) $Values($type,paper) 0]) \
			Info($type,paper,top) Info($type,paper,bottom) \
			Info($type,paper,left) Info($type,paper,right)
	}

	RefreshPreview $w
}


proc Round {x units} {
	set n [round $x]
	if {$units ne "in"} { return $n }
	if {abs($n - $x) < 0.02} { return $n }
	return [expr {round($x*100.0)/100.0}]
}


proc ResetPaper {w} {
	variable Paper
	variable Margin
	variable Info
	variable Values

	set type $Values(type)
	set Values($type,paper) 2
	set Values($type,orientation) Potrait
	set Values($type,justification) 0
	set Values($type,columns) 1
	set Info($type,paper,textvar) [lindex $Info($type,formats) $Values($type,paper)]
	set Info($type,paper,units) [GetUnits]

	set margin $Margin([lindex $Paper($type) $Values($type,paper) 3])
	foreach dir {top bottom left right} {
		set Values($type,paper,$dir) 0
		set Info($type,paper,$dir) $margin
	}

	ConfigureWidgets $w reset
}


proc SaveScidb {parent dlg file} {
	variable PdfEncodingList
	variable PdfEncodingMap
	variable Info
	variable Values

	set file [string trim $file]
	if {[string length $file] == 0} { return }
	set file [encoding convertto utf-8 $file]
	set file [file normalize $file]

	if {[::scidb::db::get open? $file]} {
		::dialog::error \
			-parent $parent \
			-message [format $mc::DatabaseIsOpen $file] \
			-title $mc::Export \
			;
		return
	}

	if {$Values(type) ne "scidb"} {
		set encoding $Values($Values(type),encoding)
	} else {
		set encoding $Info(encoding)
	}
	if {$Values(type) eq "pdf"} {
		if {$encoding ni $PdfEncodingList} {
			$dlg.top.nb select $dlg.top.nb.encoding
			::dialog::info -parent $dlg -message [format $mc::UnsupportedEncoding $encoding]
			return
		}
		set encoding $PdfEncodingMap($encoding)
	}
	if {$Values(type) eq "pgn"} {
		set excludeGamesWithIllegalMoves $Values(pgn,exclude_games_with_illegal_moves)
	} else {
		set excludeGamesWithIllegalMoves 0
	}

	destroy $dlg

	set cmd [list ::scidb::view::export \
					$Info(base) \
					$Info(view) \
					$file \
					$Info($Values(type),flags) \
					$Values(append) \
					$encoding \
					$excludeGamesWithIllegalMoves \
				]
	set options [list -message $mc::ExportDatabase -log 0]
	lappend args [namespace current]::Log {}

	# XXX text widget may overflow (too many messages)
	set parent [winfo toplevel $parent]
	set formatName $mc::FormatName($Info(type))
	if {$mc::FormatName($Info(type)) eq "scid"} {
		append formatName " " [string index $file end]
	}
	::log::open "$formatName $mc::Export"
	::log::delay
	::log::info [format $mc::ExportingDatabase $Info(name) $file]
	set count [::progress::start $parent.progress $cmd $args $options]
	update idle ;# be sure the following will be appended
	::log::info [format $mc::ExportedGames [::locale::formatNumber $count]]
	::log::close
}


proc Log {unused arguments} {
	lassign $arguments type code gameNo
	set line ""

	append line $::import::mc::GameNumber " " [::locale::formatNumber $gameNo]
	append line ": "

	if {[info exists import::mc::$code]} {
		append line [set ::import::mc::$code]
	} else {
		append line $code
	}

	::log::$type $line
	update
}


proc CloseView {} {
	variable Info
	::scidb::view::close $Info(base) $Info(view)
}

namespace eval icon {
namespace eval 32x32 {

set IconPDF [image create photo -data {
	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
}]

set IconHtml [image create photo -data {
	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
	Z89a+H8a/wFQq0OtunEjdgAAAABJRU5ErkJggg==
}]

set IconPS [image create photo -data {
	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
}]

} ;# namespace 32x32

namespace eval 36x36 {

set IconPGN [image create photo -data {
	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
	AElFTkSuQmCC
}]

} ;# namespace 32x32

namespace eval 37x21 {

set IconTeX [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACUAAAAVCAYAAADB5CeuAAADQ0lEQVRIx73WW4hVZRQH8N85
	nZqmrT0YVlO7IoouU5ANFJF0V4TuIdhtUy9GBMKU2UOUCWWUhUIZXYxusLsrPTQPTUSEkQ9S
	DQX2UhbC1oqwsGk7U5NOL+vAZnPGuUCz4MD5vm/ttf/rv9b6f7uRZuUCfIz5Dm0fYAX6ijwZ
	MEVLs7IHn+IUvIln8WeRJ7vSrOzGW1iMVdiDj5q4eAqA4CaMYXkEm6pdgrPQjeV4Er1pVp6J
	x3EjElyKEaxoYi8GsG+CoGPYhRfxF/owbxqgzsHmyvpqLMJduDf2RvEQrsGpLQxFBjfjOLxR
	CfAPzscFmIut2B00T9UG0IUyGIGVNZ8nIv49uLARdV8StJ6HRsV5CHdiO77At1hb5Mnv0wAl
	zco1AezBDsd7cDoGMVTkSX8LijwZxGCala0oV9uODrZ2FnmyyMztaWzEd+itnX2Iq3AGroPW
	JMHmRq/1dMj+yPjbE34nBcs/FXmyo+pb5Mn+NCtfw8kdQB0Ve+uLPNnXCVRaW8/Hb5VekGZl
	E29j2QSJjKdZuQ6PFnkyUtlvBCN1W4bXo4SgWXOog2wUeXIg+qFtCw8BqP3yEbxcS+SZWr+2
	rSv6+Zc0K3s7gfh7kobtxol1ZrAtxvoPfI6XMIwsfJ6KKW7btQFmS6zb031bmpWr66DqWnUw
	zcpqdmeHZlXtRyxulyrNynl4rD0wcWPcX/F/PqZ6LZ6LWwLWhHYtrYMaDl1ZEiyuDzUeq7Ay
	XHvmNOxPs7K9/jr8V1eGZUcwvBkPxNXSincNBHO/Btj3m7UpGcfOQH8C3sU7kR38gDmTTGwf
	7o5kYGlo3bEhki/E2a1xM7waA3ZliGdXs0PQh3FRgPskfqvirAy2JrIDeCSuoztibxPWRWt8
	E317WZEnw9Hg54ZW7cb1WNmYpjIfHoC3VrY3ob/Ik9HovwV4BSNFniycidI2p+l/TE0ehIZt
	SLNyHAfxFb7HDTOV/9Y0/RP8W9u7vSYpX2JDyIPZYKo7JGF0gvOuENcr4lNnVkD9HFfFLVGi
	0ShZ1bbjs4pw/r+gijzZG8p8PC6P7685aBV50ijypBHl3BhTOys9BffF2G8LnWnhiDQrD6t8
	Rb6H/pmC+g9X8ueXA3L0+AAAAABJRU5ErkJggg==
}]

} ;# namespace 37x21
} ;# namespace icon
} ;# namespace export

# vi:set ts=3 sw=3:
