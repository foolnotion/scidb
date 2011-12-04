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

set FileSelection			"&File Selection"
set Options					"&Options"
set PageSetup				"&Page Setup"
set Style					"Sty&le"
set Encoding				"&Encoding"

set Notation				"Notation"
set Figurines				"Figurines"
set Hyphenation			"Hyphenation"
set None						"(none)"
set Graphic					"Graphic"
set Short					"Short"
set Long						"Long"
set Algebraic				"Algebraic"
set Correspondence		"Correspondence"
set Telegraphic			"Telegraphic"
set FontHandling			"Font handling"
set DiagramStyle			"Diagram Style"
set UseImagesForDiagram	"Use images for diagram generation"
set EmebedTruetypeFonts	"Embed TrueType fonts"
set UseBuiltinFonts		"Use built-in fonts"
set SelectExportedTags	"Selection of exported tags"
set ExcludeAllTags		"Exclude all tags"
set IncludeAllTags		"Include all tags"
set ExtraTags				"All other extra tags"

set PdfFiles				"PDF Files"
set HtmlFiles				"HTML Files"
set TeXFiles				"TeX Files"

set ExportDatabase		"Export %s Database"
set ExportDatabaseTitle	"Export Database '%s'"
set ExportingDatabase	"Exporting %s to file %s"
set Export					"Export"
set ExportedGames			"%s game(s) exported"
set NoGamesForExport		"No games for export."
set ResetDefaults			"Reset to defaults"
set UnsupportedEncoding	"Cannot use encoding %s for PDF documents. You have to choose an alternative encoding."
set DatabaseIsOpen		"Database '%s' is open. You have to close it first."

set BasicStyle				"Basic Style"
set GameInfo				"Game Info"
set GameText				"Game Text"
set Moves					"Moves"
set MainLine				"Main Line"
set Variation				"Variation"
set Subvariation			"Subvariation"
set Symbols					"Symbols"
set Comments				"Comments"
set Result					"Result"
set Diagram					"Diagram"

set Paper					"Paper"
set Orientation			"Orientation"
set Margin					"Margin"
set Format					"Format"
set Size						"Size"
set Custom					"Custom"
set Potrait					"Potrait"
set Landscape				"Landscape"
set Top						"Top"
set Bottom					"Bottom"
set Left						"Left"
set Right					"Right"
set Justification			"Justification"
set Even						"Even"
set Columns					"Columns"
set One						"One"
set Two						"Two"

set DocumentStyle			"Document Style"
set Article					"Article"
set Report					"Report"
set Book						"Book"

set FormatName(scidb)	"Scidb"
set FormatName(scid)		"Scid"
set FormatName(pgn)		"PGN"
set FormatName(pdf)		"PDF"
set FormatName(html)		"HTML"
set FormatName(tex)		"LaTeX"
set FormatName(ps)		"Postscript"

set Option(pgn,include_varations)						"Export variations"
set Option(pgn,include_comments)							"Export comments"
set Option(pgn,include_moveinfo)							"Export move information (as comments)"
set Option(pgn,include_marks)								"Export marks (as comments)"
set Option(pgn,use_scidb_import_format)				"Use Scidb Import Format"
set Option(pgn,use_chessbase_format)					"Use ChessBase format"
set Option(pgn,include_ply_count_tag)					"Write tag 'PlyCount'"
set Option(pgn,include_termination_tag)				"Write tag 'Termination'"
set Option(pgn,include_mode_tag)							"Write tag 'Mode'"
set Option(pgn,include_opening_tag)						"Write tags 'Opening', 'Variation', 'Subvariation'"
set Option(pgn,include_setup_tag)						"Write tag 'Setup' (if needed)"
set Option(pgn,include_variant_tag)						"Write tag 'Variant' (if needed)"
set Option(pgn,include_position_tag)					"Write tag 'Position' (if needed)"
set Option(pgn,include_time_mode_tag)					"Write tag 'TimeMode' (if needed)"
set Option(pgn,exclude_extra_tags)						"Exclude extraneous tags"
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
set Option(pgn,comment_to_html)							"Write comment in HTML style"
set Option(pgn,exclude_games_with_illegal_moves)	"Exclude games with illegal moves"

} ;# namespace mc

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
	utf-8			UTF-8
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
	{ A4 210 297 mm }
	{ A5 148 210 mm }
	{ B5 176 250 mm }
	{ Letter 8.5 11 in }
	{ Legal 8.5 14 in }
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

set DocumentStyle {
	Article
	Report
	Book
}

set Languages {
	bg br ca cs cy da de de+ dsb el en eo es et eu fi fr ga gd gl he hr
	hsb hu ia is it ku la ms nl no pl pt ro ru se sk sl sq sr sv tr uk
}

array set Colors {
	shadow	#999999
	text		#c0c0c0
}

array set DefaultTags {
	Board					1
	EventCountry		1
	EventType			1
	Mode					1
	Remark				1
	TimeControl			1
	TimeMode				1
	White/BlackClock	1
	White/BlackFideId	1
	White/BlackTeam	1
	White/BlackTitle	1
}

array set Tags [array get DefaultTags]

variable Types	{scidb scid pgn pdf html tex}
variable Info

# NOTE: order must coincide with flags in db::Writer/db::PgnWriter.
array set Flags {
	pgn,include_varations						 0
	pgn,include_comments							 1
	pgn,include_annotation						 2
	pgn,include_moveinfo							 3
	pgn,include_marks								 4
	pgn,include_termination_tag				 5
	pgn,include_mode_tag							 6
	pgn,include_opening_tag						 7
	pgn,include_setup_tag						10
	pgn,include_variant_tag						11
	pgn,include_position_tag					12
	pgn,include_time_mode_tag					13
	pgn,exclude_extra_tags						14
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
	pgn,comment_to_html							25
	pgn,use_chessbase_format					26
	pgn,use_scidb_import_format				27
	pgn,exclude_games_with_illegal_moves	28
}

array set Defaults {
	pgn,include_varations						1
	pgn,include_comments							1
	pgn,include_moveinfo							1
	pgn,include_marks								1
	pgn,include_termination_tag				0
	pgn,include_mode_tag							0
	pgn,include_opening_tag						1
	pgn,include_setup_tag						1
	pgn,include_variant_tag						1
	pgn,include_position_tag					1
	pgn,include_time_mode_tag					1
	pgn,exclude_extra_tags						0
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
	pgn,comment_to_html							0
	pgn,use_scidb_import_format				0
	pgn,exclude_games_with_illegal_moves	0

	pdf,margins,A2									{ 40    53     44    44    }
	pdf,margins,A3									{ 38    44     31    31    }
	pdf,margins,A4									{ 20    27     22    22    }
	pdf,margins,A5									{ 14    19     15    15    }
	pdf,margins,A6									{ 10    13     11    11    }
	pdf,margins,B3									{ 33    45     37    37    }
	pdf,margins,B4									{ 23    32     26    26    }
	pdf,margins,B5									{ 17    22     18    18    }
	pdf,margins,Letter							{  0.74  1.00   0.89  0.89 }
	pdf,margins,Legal								{  0.94  1.26   0.89  0.89 }
	pdf,margins,Executive						{  0.70  0.95   0.76  0.76 }
	{pdf,margins,Half Letter}					{  0.57  0.76   0.57  0.57 }
	{pdf,margins,US B}							{  1.14  1.53   1.15  1.15 }
	{pdf,margins,US C}							{  1.47  1.98   1.78  1.78 }
	{pdf,margins,US 4x6}							{  0.40  0.54   0.42  0.42 }
	{pdf,margins,US 4x8}							{  0.54  0.72   0.42  0.42 }
	{pdf,margins,US 5x7}							{  0.50  0.63   0.52  0.52 }
	{pdf,margins,COMM 10}						{  0.64  0.85   0.43  0.43 }
}

array set Setup {
	tex,notation									short
	tex,figurines									graphic
	tex,primary-lang								en

	pdf,embed										1
	pdf,builtin										0
	pdf,notation									short
	pdf,figurines									graphic
	pdf,use-images									0
	pdf,diagram										{Default Merida}
	pdf,image-size									200
}

array set SetupPaper {
	tex,document									Article
	tex,format										A4
	tex,orientation								Potrait
	tex,columns										2
	tex,justification								1

	pdf,format										A4
	pdf,custom										{ 210 297 mm }
	pdf,orientation								Potrait
	pdf,columns										2
	pdf,justification								0
	pdf,paper,top									0
	pdf,paper,bottom								0
	pdf,paper,left									0
	pdf,paper,right								0
}

array set Values [array get Defaults]
array set Values [array get Setup]
array set Values [array get SetupPaper]

set Values(Type)					scidb

set Values(pgn,encoding)		iso8859-1
set Values(scid,encoding)		utf-8
set Values(scidb,encoding)		utf-8
set Values(pdf,encoding)		iso8859-1

#if {$::tcl_platform(platform) eq "windows"} { set Values(pdf,embed) 0 }

array set Fields {
	pgn	{	include_varations include_comments include_moveinfo include_marks indent_variations
				indent_comments convert_lost_result_to_comment use_scidb_import_format
				use_chessbase_format append_mode_to_event_type symbolic_annotation_style
				extended_symbolic_style shredder_fen column_style convert_null_moves comment_to_html
				space_after_move_number include_termination_tag include_mode_tag include_opening_tag
				include_setup_tag include_variant_tag include_position_tag include_time_mode_tag
				exclude_extra_tags exclude_games_with_illegal_moves
			}
	scid	{}
}

namespace import ::tcl::mathfunc::double
namespace import ::tcl::mathfunc::round
namespace import ::tcl::mathfunc::min


proc open {parent base type name view {closeViewAfterExit 0}} {
	variable icon::32x32::IconPDF
	variable icon::32x32::IconHtml
	variable icon::32x32::IconPGN
	variable icon::32x32::IconTeX
	variable ::scidb::clipbaseName
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
	set Info(fonts) {}

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
		tex	$IconTeX              \
		html	$IconHtml             \
		pdf	$IconPDF              \
	]
	set bwd 2

	set list [::tlistbox $top.list -height [llength $Types] -usescroll no -padx 10 -pady 7 -ipady 4]
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
	set initialfile [file rootname [file tail $base]]
	if {$initialfile eq $clipbaseName} { set initialfile $::util::clipbaseName }
	lappend opts -okcommand [namespace code [list DoExport $parent $dlg]]
	lappend opts -cancelcommand [list destroy $dlg]
	lappend opts -parent $nb
	lappend opts -embed 1
	# XXX verifymcd needed?
#	lappend opts -verifycmd [namespace code VerifyPath]
	lappend opts -initialfile $initialfile
	lappend opts -filetypes {{dummy .___}}
	lappend opts -width 720
	set Info(fsbox) [::dialog::saveFile {*}$opts]
	$nb add $Info(fsbox) -sticky nsew
	::widget::notebookTextvarHook $nb $Info(fsbox) [namespace current]::mc::FileSelection

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

	foreach type {pgn pdf tex scid} {
		grid [BuildOptionsFrame_$type $nb.options.$type] -row 1 -column 1 -sticky nsew
	}
	grid rowconfigure $nb.options 1 -weight 1

	grid $list	-row 1 -column 1 -sticky ns
	grid $nb		-row 1 -column 3 -sticky nsew
	
	grid columnconfigure $top {0 2 4} -minsize $::theme::padding
	grid rowconfigure $top {0 2} -minsize $::theme::padding

	set index [lsearch -exact $Types $Values(Type)]
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

	switch $Values(Type) {
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


proc BuildOptionsFrame_scid {w} {
	variable Tags

	set extraTags [lsort [::scidb::misc::extraTags]]
	set tagList {}

	foreach tag $extraTags {
		if {[string match White* $tag]} {
			set blackTag "Black[string range $tag 5 end]"
			if {$blackTag in $extraTags} {
				lappend tagList "White/$blackTag"
			} else {
				lappend tagList $tag
			}
		} elseif {[string match Black* $tag]} {
			set whiteTag "White[string range $tag 5 end]"
			if {$whiteTag ni $extraTags} { lappend tagList $tag }
		} else {
			lappend tagList $tag
		}
	}
	lappend tagList ExtraTag

	::ttk::frame $w
	::ttk::label $w.header -textvar [namespace current]::mc::SelectExportedTags
	set font [$w.header cget -font]
	if {[llength $font] == 0} { set font TkDefaultFont }
	set bold [list [font configure $font -family]  [font configure $font -size] bold]
	$w.header configure -font $bold
	grid $w.header -row 1 -column 1 -columnspan 5 -sticky w

	set nrows [expr {([llength $tagList] + 2)/3}]
	set count 0

	foreach tag $tagList {
		if {![info exists Tags($tag)]} { set Tags($tag) 0 }
		set btn $w.[string tolower $tag 0 0]
		if {$tag eq "ExtraTag"} {
			set text $mc::ExtraTags
			incr count
		} else {
			set text $tag
		}
		::ttk::checkbutton $btn \
			-text $text \
			-variable [namespace current]::Tags($tag) \
			;
		set row [expr {2*($count % $nrows) + 3}]
		set col [expr {2*($count / $nrows) + 1}]
		grid $btn -row $row -column $col -sticky w
		incr count
	}
	set lastRow [expr {2*$nrows + 3}]

	foreach tag [array names Tags] {
		if {$tag ni $tagList} { array unset Tags $tag }
	}

	::ttk::frame $w.buttons
	grid $w.buttons -row $lastRow -column 1 -columnspan 5 -sticky w

	ttk::button $w.buttons.include \
		-textvar [namespace current]::mc::IncludeAllTags \
		-command [namespace code [list ResetTags 1]] \
		;
	ttk::button $w.buttons.exclude \
		-textvar [namespace current]::mc::ExcludeAllTags \
		-command [namespace code [list ResetTags 0]] \
		;
	ttk::button $w.buttons.reset \
		-textvar [namespace current]::mc::ResetDefaults \
		-command [namespace code [list ResetTags -1]] \
		;
	grid $w.buttons.include -row 0 -column 0
	grid $w.buttons.exclude -row 0 -column 2
	grid $w.buttons.reset   -row 0 -column 4
	grid columnconfigure $w.buttons {1 3} -minsize $::theme::padding

	for {set i 2} {$i <= $lastRow} {incr i 2} { lappend rows $i }
	grid rowconfigure $w $rows -minsize $::theme::padding
	set rows [list 0 2 [expr {$lastRow - 1}] [expr {$lastRow + 1}]]
	grid rowconfigure $w $rows -minsize [expr {2*$::theme::padding}]
	grid columnconfigure $w {0 6} -minsize $::theme::padding
	grid columnconfigure $w {2 4} -minsize [expr {4*$::theme::padding}]

	return $w
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


proc BuildNotationAndFigurineList {w} {
	variable Notation
	variable NotationList
	variable Figurines
	variable FigurinesList
	variable Colors

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

	### Figurine #############################################################################
	ttk::labelframe $w.figurines -text [set mc::Figurines]
	set list [ttk::frame $w.figurines.list]
	set selbox [::tlistbox $list.selection -exportselection 0 -pady 1 -borderwidth 1 -minwidth 180]
	$selbox addcol image -id icon
	$selbox addcol text -id text -expand yes
	foreach entry $Figurines {
		lassign $entry lang name
		set img $::country::icon::flag([::mc::countryForLang $lang])
		$selbox insert [list $img $name]
	}
	$selbox resize
	pack $selbox -anchor s
	bind $selbox <<ListboxSelect>> [namespace code [list SetFigurines $w]]
	bind $list <Configure> [namespace code { ConfigureTListbox %W %h }]
	set sample [tk::label $w.figurines.sample -borderwidth 1 -relief sunken]
	tk::label $w.figurines.sample.text -background white
	pack $w.figurines.sample.text -fill both -expand yes
	pack propagate $sample 0

	grid $list   -row 1 -column 1 -sticky ns
	grid $sample -row 3 -column 1 -sticky ew
	grid rowconfigure $w.figurines {0 2 4} -minsize $::theme::padding
	grid rowconfigure $w.figurines {1} -weight 1
	grid columnconfigure $w.figurines {0 2} -minsize $::theme::padding

	### Notation #############################################################################
	ttk::labelframe $w.notation -text [set mc::Notation]
	set list [ttk::frame $w.notation.list]
	set selbox [::tlistbox $list.selection -exportselection 0 -pady 1 -borderwidth 1 -minwidth 165]
	$selbox addcol text -id text
	foreach name $NotationList { $selbox insert [list $name] }
	$selbox resize
	pack $selbox -anchor s
	bind $selbox <<ListboxSelect>> [namespace code [list SetNotation $w]]
	bind $list <Configure> [namespace code { ConfigureTListbox %W %h }]
	set sample [tk::label $w.notation.sample -borderwidth 1 -relief sunken]
	tk::label $w.notation.sample.text -background white
	pack $w.notation.sample.text -fill both -expand yes
	pack propagate $sample 0

	grid $list   -row 1 -column 1 -sticky ns
	grid $sample -row 3 -column 1 -sticky ew
	grid rowconfigure $w.notation {0 2 4} -minsize $::theme::padding
	grid rowconfigure $w.notation {1} -weight 1
	grid columnconfigure $w.notation {0 2} -minsize $::theme::padding
}


proc BuildOptionsFrame_pdf {w} {
	variable DiagramStyles
	variable DiagramSizes
	variable Values
	variable Info

	ttk::frame $w

	### Notation + Figurine #################################################################
	BuildNotationAndFigurineList $w

	### Font Handling #######################################################################
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
	grid rowconfigure $w.options {0 2 4} -minsize $::theme::padding

	### Diagram Style #######################################################################
	ttk::checkbutton $w.use \
		-text $mc::UseImagesForDiagram \
		-variable [namespace current]::Values(pdf,use-images) \
		;
	ttk::labelframe $w.diagram -labelwidget $w.use
	SearchDiagramStyles
	set selbox [::tlistbox $w.diagram.selection \
		-height [llength $DiagramStyles] \
		-borderwidth 1 \
		-disabledbackground [::theme::getBackgroundColor] \
		-disabledforeground [::theme::getDisabledColor] \
	]
	$selbox addcol image -id icon
	$selbox addcol text -id text -expand yes
	set Info(diagram:list) {}
	foreach entry $DiagramStyles {
		lassign $entry sample style set sizes
		catch {
			set img [image create photo -file $sample]
			set name "$style - $set"
			$selbox insert [list $img $name]
			lappend Info(diagram:list) [list [list $style $set] $sizes]
		}
	}
	$selbox resize
	set f [ttk::frame $w.diagram.sizes -borderwidth 0]
	ttk::label $f.size -text "$mc::Size (pt):"
	grid $f.size -column 1 -row 1
	set col 2
	foreach size $DiagramSizes {
		ttk::radiobutton $f.$size \
			-text [expr {int(double($size)*0.12 + 0.5)}] \
			-variable [namespace current]::Values(pdf,image-size) \
			-value $size \
			;
		grid columnconfigure $f $col -minsize $::theme::padding
		grid $f.$size -column [incr col] -row 1
		incr col
	}
	ToggleUseImages $selbox $f
	$w.use configure -command [namespace code [list ToggleUseImages $selbox $f]]
	bind $selbox <<ListboxSelect>> [namespace code [list UseDiagram %d $f]]
	grid columnconfigure $f $col -minsize $::theme::padding
	grid $w.diagram.selection -column 1 -row 1 -sticky ew
	grid $w.diagram.sizes -column 1 -row 3 -sticky w
	grid columnconfigure $w.diagram {0 2} -minsize $::theme::padding
	grid rowconfigure $w.diagram {0 4} -minsize $::theme::padding
	grid rowconfigure $w.diagram 2 -minsize [expr {2*$::theme::padding}]

	### Layout ##############################################################################
	grid $w.figurines -row 1 -column 1 -sticky ns -rowspan 3
	grid $w.notation  -row 1 -column 3 -sticky ns -rowspan 3
	grid $w.options   -row 1 -column 5 -sticky nsew
	grid $w.diagram   -row 3 -column 5 -sticky nsew
	grid rowconfigure $w {0 2 4} -minsize $::theme::padding
	grid rowconfigure $w {1 3} -weight 1
	grid columnconfigure $w {0 2 4 6} -minsize $::theme::padding

	return $w
}


proc BuildOptionsFrame_tex {w} {
	variable Languages
	variable Values
	variable Info

	ttk::frame $w

	### Notation + Figurine #################################################################
	BuildNotationAndFigurineList $w

	### Default Language ####################################################################
	set Info(languages) [list [list none $mc::None]]
	foreach lang $Languages {
		lappend Info(languages) [list $lang [::encoding::languageName $lang]]
	}
	set Info(languages) [lsort -dictionary -index 1 $Info(languages)]
	ttk::labelframe $w.language -text $mc::Hyphenation
	ttk::frame $w.language.list
	set selbox [::tlistbox $w.language.list.selection -borderwidth 1 -pady 1 -minwidth 180]
	$selbox addcol image -id icon
	$selbox addcol text -id name -expand yes
	foreach entry $Info(languages) {
		lassign $entry lang name
		if {$lang eq "none"} {
			set img {}
		} else {
			set img $::country::icon::flag([::mc::countryForLang $lang])
		}
		$selbox insert [list $img $name]
	}
	$selbox resize
	pack $selbox -anchor s
	pack $w.language.list -padx $::theme::padding -pady $::theme::padding -fill y -expand yes
	bind $w.language.list <Configure> [namespace code { ConfigureTListbox %W %h }]
	bind $selbox <<ListboxSelect>> [namespace code [list SetLanguage %d]]
	$selbox select [lsearch -index 0 $Info(languages) $Values(tex,primary-lang)]

	### Layout ##############################################################################
	grid $w.figurines -row 1 -column 1 -sticky ns
	grid $w.notation  -row 1 -column 3 -sticky ns
	grid $w.language  -row 1 -column 5 -sticky ns
	grid rowconfigure $w {0 2} -minsize $::theme::padding
	grid rowconfigure $w {1} -weight 1
	grid columnconfigure $w {0 2 4 6} -minsize $::theme::padding

	return $w
}


proc SetLanguage {index} {
	variable Info
	variable Values

	set Values(tex,primary-lang) [lindex $Info(languages) $index 0]
}


proc ToggleUseImages {selbox sizes} {
	variable Values
	variable Info

	set index [lsearch -index 0 $Info(diagram:list) $Values(pdf,diagram)]
	if {$Values(pdf,use-images)} { set state normal } else { set state disabled }
	$selbox configure -state $state
	$selbox select none
	$selbox select $index

	if {$state eq "disabled"} {
		set usedSizes {}
	} else {
		set usedSizes [lindex $Info(diagram:list) $index 1]
	}
	CheckSizes $sizes $usedSizes
}


proc CheckSizes {sizes usedSizes} {
	variable DiagramSizes
	variable Values

	foreach size $DiagramSizes {
		if {$size in $usedSizes} { set state normal } else { set state disabled }
		$sizes.$size configure -state $state
	}

	if {[llength $usedSizes] && $Values(pdf,image-size) ni $usedSizes} {
		$sizes.[lindex $usedSizes end] invoke
	}
}


proc UseDiagram {index sizes} {
	variable Info
	variable Values

	lassign [lindex $Info(diagram:list) $index] value usedSizes
	set Values(pdf,diagram) $value
	CheckSizes $sizes $usedSizes
}


proc SearchDiagramStyles {} {
	variable DiagramStyles
	variable DiagramSizes

	if {[info exists DiagramStyles]} { return }

	set diagramStyles {}
	set DiagramStyles {}
	set DiagramSizes {}
	set path [file join $scidb::dir::share pdf sets]

	foreach sub1 [glob -directory $path -nocomplain -types d *] {
		foreach sub2 [glob -directory $sub1 -nocomplain -types d *] {
			set size [file tail $sub2]
			if {$size ni $DiagramSizes} { lappend DiagramSizes $size }
			foreach sub3 [glob -directory $sub2 -nocomplain -types d *] {
				foreach sub4 [glob -directory $sub3 -nocomplain -types d *] {
					set style [file tail $sub1]
					set pieces [file tail $sub4]
					set sample [file join $sub4 sample.png]
					if {[file exists $sample]} {
						lappend diagramStyles [list $sample $style $pieces]
					}
					lappend sizes($style,$pieces) $size
				}
			}
		}
	}

	foreach entry $diagramStyles {
		lassign $entry sample style pieces
		lappend DiagramStyles [list $sample $style $pieces $sizes($style,$pieces)]
	}

	set DiagramSizes [lsort -integer $DiagramSizes]
	set DiagramStyles [lsort -dictionary -index 0 $DiagramStyles]
}


proc ResetTags {value} {
	variable Tags
	variable DefaultTags

	if {$value == -1} {
		foreach tag [array names Tags] { set Tags($tag) 0 }
		array set Tags [array get DefaultTags]
	} else {
		foreach tag [array names Tags] { set Tags($tag) $value }
	}
}


proc UseBuiltinFonts {} {
	variable Info

	if {[info exists Info(fontsel)]} {
		StyleSelected $Info(fonttree) 0
	}
}


proc SetupOptions {pane} {
	variable Values
	variable Figurines
	variable Notation

	set type [lindex [split $pane .] end]

	set index [lsearch -exact -index 0 $Figurines $Values($type,figurines)]
	$pane.figurines.list.selection select $index

	set index [lsearch -exact -index 0 $Notation $Values($type,notation)]
	$pane.notation.list.selection select $index

	SetFigurines $pane
}


proc ConfigureTListbox {list height} {
	set linespace [$list.selection cget -linespace]
	set nrows [expr {$height/$linespace}]
	if {$nrows > [$list.selection cget -height]} {
		$list.selection configure -height $nrows
	}
}


proc SetNotation {w} {
	variable Notation
	variable Figurines
	variable Values

	set type [lindex [split $w .] end]
	set notation [lindex $Notation [$w.notation.list.selection curselection] 0]
	set Values($type,notation) $notation

	set lang [lindex $Figurines [$w.figurines.list.selection curselection] 0]
	if {$lang eq "graphic"} { set n N } else { set n [lindex $::font::figurines($lang) 4] }

	switch $notation {
		short				{ $w.notation.sample.text configure -text "1.e4 ${n}f6" }
		long				{ $w.notation.sample.text configure -text "1.e2-e4 ${n}g8-f6" }
		algebraic		{ $w.notation.sample.text configure -text "1.e2e4 g8f6" }
		correspondence	{ $w.notation.sample.text configure -text "1.5254 7866" }
		telegraphic		{ $w.notation.sample.text configure -text "1.GEGO WATI" }
	}
}


proc SetFigurines {w} {
	variable Figurines
	variable Values

	set type [lindex [split $w .] end]
	set lang [lindex $Figurines [$w.figurines.list.selection curselection] 0]
	set Values($type,figurines) $lang
	if {$lang eq "graphic"} {
		$w.figurines.sample.text configure -font ::font::figurine
	} else {
		$w.figurines.sample.text configure -font TkTextFont
	}
	$w.figurines.sample.text configure -text [join $::font::figurines($lang) " "]
	if {[$w.notation.list.selection curselection] >= 0} { SetNotation $w }
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
			if {$Values(pgn,use_chessbase_format) || $Values(pgn,use_scidb_import_format)} {
				if {$Values(pgn,use_chessbase_format)} {
					$w.use_chessbase_format configure -state normal
					$w.use_scidb_import_format configure -state disabled
				} else {
					$w.use_chessbase_format configure -state disabled
					$w.use_scidb_import_format configure -state normal
				}
				foreach field $Fields(pgn) {
					switch $field {
						use_chessbase_format -
						use_scidb_import_format -
						exclude_games_with_illegal_moves -
						column_style -
						indent_comments -
						indent_variations -
						space_after_move_number -
						include_opening_tag {}
						default { $w.$field configure -state disabled }
					}
				}
			} else {
				foreach field $Fields(pgn) { $w.$field configure -state normal }
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
}


proc HideTab {nb tab} { $nb tab $tab -state hidden }
proc ShowTab {nb tab} { $nb tab $tab -state normal }


proc Select {nb index} {
	variable PdfEncodingList
	variable Types
	variable Info
	variable Values

	if {[llength $index] == 0} { return }	;# ignore double click
	set Values(Type) [lindex $Types $index]
	set savemode 0
	grid remove $nb.options.pgn
	grid remove $nb.options.pdf
	grid remove $nb.options.tex
	grid remove $nb.options.scid

	switch $Values(Type) {
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
			ShowTab $nb $nb.options
			if {$Values(Type) eq "scidb"} {
				ShowTab $nb $nb.encoding
			} else {
				HideTab $nb $nb.encoding
			}
			grid $nb.options.scid
			set var $::menu::mc::ScidBases
			set ext {.si4 .si3}
		}

		pgn {
			ShowTab $nb $nb.options
			HideTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			HideTab $nb $nb.style
			if {$Values(Type) eq "scidb"} {
				ShowTab $nb $nb.encoding
			} else {
				HideTab $nb $nb.encoding
			}
			grid $nb.options.pgn
			set var $::menu::mc::PGNFiles
			set ext {.pgn .pgn.gz .zip}
			set savemode 1
		}

		pdf {
			ShowTab $nb $nb.options
			ShowTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			ShowTab $nb $nb.style
			if {$Values(Type) eq "scidb" || $Info(pdf-encoding)} {
				ShowTab $nb $nb.encoding
			} else {
				HideTab $nb $nb.encoding
			}
			grid $nb.options.pdf
			SetupOptions $nb.options.pdf
			set Info(useCustom) 1
			set Info(configure-style) 1
			set var $mc::PdfFiles
			set ext .pdf
			::beta::notYetImplemented $nb tex
		}

		html {
			ShowTab $nb $nb.options
			HideTab $nb $nb.setup_pdf
			HideTab $nb $nb.setup_tex
			ShowTab $nb $nb.style
			HideTab $nb $nb.encoding
			grid $nb.options.pdf
			SetupOptions $nb.options.pdf
			set Info(configure-style) 1
			set var $mc::HtmlFiles
			if {$::tcl_platform(platform) eq "windows"} { set ext .htm } else { set ext .html }
			::beta::notYetImplemented $nb html
		}

		tex {
			ShowTab $nb $nb.options
			ShowTab $nb $nb.setup_tex
			HideTab $nb $nb.setup_pdf
			ShowTab $nb $nb.style
			HideTab $nb $nb.encoding
			grid $nb.options.tex
			SetupOptions $nb.options.tex
			set Info(configure-style) 1
			set Info(useCustom) 0
			set var $mc::TeXFiles
			set ext {.tex .ltx}
		}
	}

	::dialog::fsbox::useSaveMode $Info(fsbox) $savemode

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
		if {$Values(Type) eq "pdf"} { set encTab pdf } else { set encTab pgn }
		if {$Info(configure-encoding-$encTab)} {
			if {$Values(Type) eq "pdf"} { set encList $PdfEncodingList } else { set encList {} }
			bind $nb.encoding <Configure> \
				+[namespace code [list ConfigureEncoding $nb.encoding $encTab $encList]]
			set Info(configure-encoding-$encTab) 0
		} elseif {[winfo exists $nb.encoding.$encTab]} {
			if {$Values(Type) eq "pdf" && $Info(pdf-encoding)} {
				set encoding $Info(encoding)
			} else {
				set encoding $Values($Values(Type),encoding)
			}
			raise $nb.encoding.$encTab
			focus $nb.encoding.$encTab
			::encoding::select $nb.encoding.$encTab $encoding
		}
	}

	::dialog::fsbox::setFileTypes $Info(fsbox) [list [list $var $ext]] $ext
	if {$Values(Type) eq "pdf" && $Values(pdf,builtin)} { UseBuiltinFonts }
}


proc ConfigureEncoding {w tab encList} {
	variable Info
	variable Values
	variable Defaults

	if {[winfo exists $w.$tab]} { return }
	set type $Values(Type)

	if {$type eq "pdf" && $Info(pdf-encoding)} {
		set encoding $Info(encoding)
	} else {
		set encoding $Values($type,encoding)
	}

	if {$Values(Type) ne "scidb"} { set currentEncoding $encoding } else { set currentEncoding {} }
	::encoding::build $w.$tab $currentEncoding iso8859-1 [winfo width $w] 0 $encList
	if {$type eq "pdf" && $Info(pdf-encoding)} {
		::encoding::activate $w.$tab iso8859-1
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
		if {$Values(Type) eq "pdf" && $Info(pdf-encoding)} {
			set Info(encoding) $encoding
		} else {
			set Values($Values(Type),encoding) $encoding
		}
	}
}


proc ConfigureStyle {w} {
	variable StyleLayout
	variable Styles
	variable Values
	variable Info

	if {[winfo exists $w.t]} {
		foreach child [winfo children $w] { destroy $child }
	}

	treectrl $w.t \
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

	set parent(0) root
	foreach entry $StyleLayout($Values(Type)) {
		lassign $entry depth name
		if {$depth == 0} {
			$w.t item style set root item style
			$w.t item element configure root item elemTxt -text [set mc::$name]
		} else {
			incr depth -1
			set item [$w.t item create -button 1]
			$w.t item style set $item item style
			$w.t item element configure $item item elemTxt -text [set mc::$name]
			$w.t item lastchild $parent($depth) $item
			incr depth
			set parent($depth) $item
		}
	}
	$w.t selection add 0
	$w.t activate 0
	$w.t notify bind $w.t <Selection> [namespace code [list StyleSelected $w.t %S]]

	ttk::scrollbar $w.sh -orient horizontal -command [list $w.t xview]
	$w.t notify bind $w.sh <Scroll-x> { ::scrolledframe::sbset %W %l %u }
	bind $w.sh <ButtonPress-1> [list focus $w.t]
	ttk::scrollbar $w.sv -orient vertical -command [list $w.t yview]
	$w.t notify bind $w.sv <Scroll-y> { ::scrolledframe::sbset %W %l %u }
	bind $w.sv <ButtonPress-1> [list focus $w.t]

	set type $Values(Type)
	set Info(style) [lindex $StyleLayout($Values(Type)) 0 1]
	set basic $Styles($type,$Info(style))
	lassign $basic family size weight slant color
	set font [font create -family $family -size $size -weight $weight -slant $slant]
	if {$family eq "Helvetica"} {
		variable ::dialog::choosefont::fontFamilies
		set helvetica $fontFamilies(Helvetica)
		array set attrs [font actual $font]
		set index 0
		while {$index < [llength $helvetica] && [string compare -nocase $attrs(-family) $family]} {
			set family [lindex $helvetica $index]
			set font [font create -family $family -size $size -weight $weight -slant $slant]
			array set attrs [font actual $font]
		}
		if {[string compare -nocase $attrs(-family) $family] == 0} {
			lset Styles($type,$Info(style)) 0 $family
		}
	}
	::dialog::::choosefont::build $w.fontsel $font {} $color
	bind $w.fontsel <<FontSelected>> [namespace code [list FontSelected %d]]
	bind $w.fontsel <<FontColor>> [namespace code [list FontColor %d]]

	set Info(fontsel) $w.fontsel
	set Info(fonttree) $w.t
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
	variable Info

	set type $Values(Type)
	set style ""
	set parent $index
	while {[llength $parent]} {
		set style [join [list [lindex $StyleLayout($Values(Type)) $parent 1] {*}$style] ","]
		set parent [$tree item parent $parent]
	}
	set Info(style) $style

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

	lassign $Styles($type,$Info(style)) f s w l c
	if {[llength $f]} { set family $f }
	if {[llength $s]} { set size   $s }
	if {[llength $w]} { set weight $w }
	if {[llength $l]} { set slant  $l }
	if {[llength $c]} { set color  $c }

	set Info(fontType) [lindex $StyleLayout($Values(Type)) $index 1]

	switch -glob -- $Info(fontType) {
		Figurines	{ set fonts $::font::chessFigurineFonts }
		Diagram		{ set fonts $::font::chessDiagramFonts }
		Symbols		{ set fonts $::font::chessSymbolFonts }

		default		{
			if {$type eq "tex"} {
				set Info(fonts) {{Avant Garde} Bookman Chancery Charter Courier Fixed Fourier \
										Helvetica {Latin Modern} {New Century} Palatino Times}
			} elseif {$Values(pdf,builtin)} {
				set Info(fonts) {Courier Helvetica Times-Roman}
			} else {
				set Info(fonts) {}
			}
			set fonts $Info(fonts)
		}
	}

	if {$type eq "tex"} {
		set sizes {8 9 10 11 12 14 17 20 25}
	} else {
		set sizes {}
	}

	::dialog::::choosefont::setFonts $Info(fontsel) $fonts
	::dialog::::choosefont::setSizes $Info(fontsel) $sizes
	UpdateSample $family
	::dialog::::choosefont::select $Info(fontsel) \
		-family $family \
		-size $size \
		-weight $weight \
		-slant $slant \
		-color $color
}


proc UpdateSample {family} {
	variable Values
	variable Info

	set sample ""

	switch $Info(fontType) {
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

	::dialog::::choosefont::setSample $Info(fontsel) $sample
}


proc FontSelected {fontInfo} {
	variable StyleLayout
	variable Styles
	variable Values
	variable Info

	set type $Values(Type)
	lassign $fontInfo family size weight slant
	set color [lindex $Styles($type,$Info(style)) 4]

	if {$Info(style) ne [lindex $StyleLayout($Values(Type)) 0 1]} {
		foreach item {family size weight slant} {
			if {[set $item] eq $Values($type,$item)} { set $item {} }
		}
	}

	set Styles($type,$Info(style)) [list $family $size $weight $slant $color]
	switch $Info(fontType) { Symbols - Diagram - Figurines { UpdateSample $family } }
}


proc FontColor {color} {
	variable Values
	variable Styles

	set type $Values(Type)
	set color [::dialog::choosecolor::getActualColor $color]
	if {$color eq $Values($type,color)} { set color {} }
	lset Styles($type,$Info(style)) 4 $color
}


proc ConfigureSetup {w} {
	variable Paper
	variable Info
	variable Values
	variable Colors
	variable DocumentStyle

	set type $Values(Type)
	set Info($type,formats) {}
	foreach format $Paper($type) {
		lassign $format id width height units
		lappend Info($type,formats) "$id ($width x $height $units)"
	}
	if {$Info(useCustom)} {
		lassign $Values($type,custom) \
			Info($type,paper,width) Info($type,paper,height) Info($type,paper,units)
		lappend Info($type,formats) $mc::Custom
		set Info($type,paper,units,textvar) $Info($type,paper,units)
	}
	if {$Values($type,format) eq "_Custom_"} {
		set n [llength $Paper($type)]
	} else {
		set n [lsearch -index 0 $Paper($type) $Values($type,format)]
	}
	set Info($type,paper,textvar) [lindex $Info($type,formats) $n]

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

	if {$type eq "tex"} {
		set Info(tex,document-styles) {}
		foreach style $DocumentStyle {
			lappend Info(tex,document-styles) [set mc::$style]
		}
		set n [lsearch $DocumentStyle $Values(tex,document)]
		set Info(tex,document) [lindex $Info(tex,document-styles) $n]
		ttk::labelframe $w.doc -text $mc::DocumentStyle
		ttk::combobox $w.doc.style \
			-state readonly \
			-values $Info(tex,document-styles) \
			-textvariable [namespace current]::Info(tex,document)
		bind $w.doc.style <<ComboboxSelected>> [namespace code [list SelectDocumentStyle $w]]
		grid $w.doc.style -row 1 -column 1 -sticky ew
		grid rowconfigure $w.doc {0 2} -minsize $::theme::padding
		grid columnconfigure $w.doc {0 2} -minsize $::theme::padding
		grid columnconfigure $w.doc {1} -weight 1
	}
	ttk::labelframe $w.paper -text $mc::Paper
	if {$Info(useCustom)} {
		ttk::labelframe $w.margins -text $mc::Margin
	}
	ttk::labelframe $w.orient -text $mc::Orientation
	ttk::labelframe $w.just -text $mc::Justification
	ttk::labelframe $w.columns -text $mc::Columns

	if {$Info(useCustom)} {
		ttk::label $w.paper.lformat -text $mc::Format
	}
	ttk::combobox $w.paper.cbformat \
		-state readonly \
		-values $Info($type,formats) \
		-textvariable [namespace current]::Info($type,paper,textvar) \
		;
	bind $w.paper.cbformat <<ComboboxSelected>> [namespace code [list ConfigureWidgets $w paper]]

	if {$Info(useCustom)} {
		grid $w.paper.lformat	-row 1 -column 1 -sticky w
	}
	grid $w.paper.cbformat		-row 1 -column 3 -sticky ew -columnspan 7

	if {$Info(useCustom)} {
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

		grid columnconfigure $w.paper {0 2 10} -minsize $::theme::padding
	} else {
		grid columnconfigure $w.paper {0 10} -minsize $::theme::padding
	}

	grid rowconfigure $w.paper {0 2 4} -minsize $::theme::padding
	grid columnconfigure $w.paper {4 6 8} -minsize 2
	grid columnconfigure $w.paper {3 7} -weight 1

	if {$type eq "pdf"} {
		foreach dir {top bottom left right} {
			set Info($type,paper,$dir) $Values($type,paper,$dir)
		}
	}

	if {$Info(useCustom)} {
		if {$Values($type,format) eq "_Custom_"} {
			set units [lindex $Values($type,custom) 2]
		} else {
			set units [lindex $Paper($type) [lsearch -index 0 $Paper($type) $Values($type,format)] 3]
		}
		foreach {dir row col} {top 1 1 bottom 3 1 left 1 5 right 3 5} {
			set text [string toupper $dir 0 0]
			if {$Info($type,paper,$dir) == 0} {
				set Info($type,paper,$dir) [DefaultMargin $dir $type $units]
			}
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

	if {$type eq "tex"} {
		grid $w.doc			-row  1 -column 1 -sticky ew -columnspan 3
	}
	grid $w.paper			-row  3 -column 1 -sticky ew -columnspan 3
	if {$Info(useCustom)} {
		grid $w.margins	-row  5 -column 1 -sticky ew -columnspan 3
	}
	grid $w.orient			-row  7 -column 1 -sticky ew -columnspan 3
	grid $w.just			-row  9 -column 1 -sticky ew
	grid $w.columns		-row  9 -column 3 -sticky ew
	grid $w.reset			-row 11 -column 1 -sticky w -columnspan 3
	grid $w.c				-row  1 -column 5 -sticky nsew -rowspan 12

	if {$type eq "tex"} {
		set rows {0 2 6 8 10 13}
	} elseif {$Info(useCustom)} {
		set rows {0 4 6 8 10 13}
	} else {
		set rows {0 6 8 10 13}
	}
	grid rowconfigure $w $rows -minsize $::theme::padding
	grid rowconfigure $w 10 -minsize [expr {2*$::theme::padding}]
	grid rowconfigure $w 12 -weight 1
	grid columnconfigure $w {0 2 4 6} -minsize $::theme::padding
	grid columnconfigure $w 5 -weight 1

	ConfigureWidgets $w
	bind $w.c <Configure> [namespace code [list RefreshPreview $w]]
}


proc SelectDocumentStyle {w} {
	variable Info
	variable Values
	variable DocumentStyle

	set n [lsearch $Info(tex,document-styles) $Info(tex,document)]
	set Values(tex,document) [lindex $DocumentStyle $n]
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
	set type $Values(Type)

	foreach dir {top bottom left right} {
		if {	[string match {*[0-9]*} $Info($type,paper,$dir)] ||
				[string match {*[0-9].[0-9][0-9]*} $Info($type,paper,$dir)]} {
			set margin($dir) $Info($type,paper,$dir)
		} else {
			set margin($dir) 0
		}
	}

	if {$Values($type,format) eq "_Custom_"} {
		set pw $Info($type,paper,width)
		set ph $Info($type,paper,height)
		set units $Info($type,paper,units)
		set Values($type,custom) [list $pw $ph $units]
	} else {
		set n [lsearch -index 0 $Paper($type) $Values($type,format)]
		lassign [lindex $Paper($type) $n] id pw ph units
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
#		set gap [expr {min(6, round(0.05*($x1 - $x0)))}]
		set gap [expr {max(6,round(min($l,$r)/2.0))}]
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

	set type $Values(Type)

	if {$Values($type,format) eq "_Custom_"} {
		set units $Info($type,paper,units,textvar)
	} else {
		set units [lindex $Paper($type) [lsearch -index 0 $Paper($type) $Values($type,format)]]
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
	set type $Values(Type)

	if {$ok && $Info($type,paper,$dir) != $value} {
		set Values($type,paper,$dir) [string trim $value]
		after cancel $Info(after)
		set Info(after) [after 250 [namespace code [list RefreshPreview $w]]]
	}

	return $ok
}


proc Round {x units} {
	set n [round $x]
	if {$units ne "in"} { return $n }
	if {abs($n - $x) < 0.02} { return $n }
	return [expr {round($x*100.0)/100.0}]
}


proc MapUnits {value from to} {
	switch $from->$to {
		mm->in  { set factor [expr {1.0/25.4}] }
		mm->pt  { set factor [expr {72.0/25.4}] }
		in->mm  { set factor 25.4 }
		in->pt  { set factor 72.0 }
		pt->mm  { set factor [expr {25.4/72.0}] }
		pt->in  { set factor [expr {1.0/72.0}] }
		default { return $value }
	}

	set x [expr {$factor*double($value)}]
	set n [round $x]

	if {$to ne "in"} { return $n }
	if {abs($n - $x) < 0.02} { return $n }
	return [expr {round($x*100.0)/100.0}]
}


proc ConfigureWidgets {w {action {}}} {
	variable Paper
	variable Values
	variable Info
	variable Defaults

	set type $Values(Type)
	set n [lsearch -exact $Info($type,formats) [$w.paper.cbformat get]]
	if {$n == [llength $Paper($type)]} {
		set Values($type,format) _Custom_
	} else {
		set Values($type,format) [lindex $Paper($type) $n 0]
	}

	if {$Info(useCustom)} {
		if {$Values($type,format) eq "_Custom_"} {
			$w.paper.width configure -state normal
			$w.paper.height configure -state normal
			$w.paper.units configure -state readonly
			set wantedUnits $Info($type,paper,units,textvar)
		} else {
			foreach name {width height units} {
				$w.paper.$name configure -state disabled
			}
			set n [lsearch -index 0 $Paper($type) $Values($type,format)]
			set wantedUnits [lindex $Paper($type) $n 3]
		}

		if {$action ne "reset"} {
			set origUnits $Info($type,paper,units)
			set Info($type,paper,units) $wantedUnits

			if {$action ne "paper" && $Values($type,format) eq "_Custom_"} {
				foreach attr {width height} {
					set Info($type,paper,$attr) [MapUnits $Info($type,paper,$attr) $origUnits $wantedUnits]
				}
			}

			foreach attr {top bottom left right} {
				if {$Values($type,paper,$attr) == 0} {
					set Info($type,paper,$attr) [DefaultMargin $attr $type $wantedUnits]
				} else {
					set Info($type,paper,$attr) [MapUnits $Info($type,paper,$attr) $origUnits $wantedUnits]
					set Values($type,paper,$attr) \
						[MapUnits $Values($type,paper,$attr) $origUnits $wantedUnits]
				}
			}
		}

		$w.margins configure -text "$mc::Margin ($wantedUnits)"
	} else {
		lassign $Defaults(pdf,margins,$Values($type,format)) \
			Info($type,paper,top) Info($type,paper,bottom) \
			Info($type,paper,left) Info($type,paper,right)
	}

	RefreshPreview $w
}


proc ResetPaper {w} {
	variable Paper
	variable Info
	variable Values
	variable Defaults
	variable DocumentStyle
	variable SetupPaper

	set type $Values(Type)

	array set Values [array get SetupPaper $type,*]

	set n [lsearch -index 0 $Paper($type) $Values($type,format)]
	set Info($type,paper,textvar) [lindex $Info($type,formats) $n]
	set Info($type,paper,units) [GetUnits]

	if {$type eq "tex"} {
		set n [lsearch $DocumentStyle $Values(tex,document)]
		set Info(tex,document) [lindex $Info(tex,document-styles) $n]
	}

	set wantedUnits [lindex $Paper($type) $n 3]
	foreach dir {top bottom left right} {
		set Values($type,paper,$dir) 0
		set Info($type,paper,$dir) [DefaultMargin $dir $type $wantedUnits]
	}

	ConfigureWidgets $w reset
}


proc DefaultMargin {dir type units} {
	variable Defaults
	variable Values
	variable Paper
	variable Info

	if {[lsearch -index 0 $Paper($type) $Values($type,format)] == -1} {
		set format A4
	} else {
		set format $Values($type,format)
	}

	lassign $Defaults(pdf,margins,$format) m(top) m(bottom) m(left) m(right)
	return [MapUnits $m($dir) $Info($type,paper,units) $units]
}


proc DoExport {parent dlg file} {
	variable PdfEncodingList
	variable PdfEncodingMap
	variable Info
	variable Values
	variable Tags

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

	if {$Values(Type) ne "scidb"} {
		set encoding $Values($Values(Type),encoding)
	} else {
		set encoding $Info(encoding)
	}
	if {$Values(Type) eq "pdf"} {
		if {$encoding ni $PdfEncodingList} {
			$dlg.top.nb select $dlg.top.nb.encoding
			::dialog::info -parent $dlg -message [format $mc::UnsupportedEncoding $encoding]
			return
		}
		set encoding $PdfEncodingMap($encoding)
	}

	if {$Values(Type) eq "pgn"} {
		set excludeGamesWithIllegalMoves $Values(pgn,exclude_games_with_illegal_moves)
	} else {
		set excludeGamesWithIllegalMoves 0
	}

	set tagList {}

	switch $Values(Type) {
		scid {
			foreach tag [array names Tags] {
				if {$Tags($tag)} {
					lappend tagList $tag
					if {[string match White/Black* $tag]} {
						set name [string range $tag 11 end]
						lappend tagList White$name
						lappend tagList Black$name
					} else {
						lappend tagList $tag
					}
				}
			}
		}

		pdf {
			# Values(pdf,encoding)
			# Values(pdf,embed)
			# Values(pdf,builtin)
			# Values(pdf,format)
			# Values(pdf,paper,top)
			# Values(pdf,paper,bottom)
			# Values(pdf,paper,left)
			# Values(pdf,paper,right)
			# Values(pdf,custom)
			# Values(pdf,orientation)
			# Values(pdf,justification)
			# Values(pdf,columns)
			# Values(pdf,use-images)
			# Values(pdf,diagram)
			# Values(pdf,imageSize)
			# Values(pdf,notation)
			# Values(pdf,figurines)

			# pdf,BasicStyle
			# pdf,BasicStyle,GameInfo
			# pdf,BasicStyle,GameText
			# pdf,BasicStyle,GameText,Moves
			# pdf,BasicStyle,GameText,Moves,MainLine
			# pdf,BasicStyle,GameText,Moves,Variation
			# pdf,BasicStyle,GameText,Moves,Subvariation
			# pdf,BasicStyle,GameText,Moves,Figurines
			# pdf,BasicStyle,GameText,Moves,Symbols
			# pdf,BasicStyle,GameText,Comments
			# pdf,BasicStyle,GameText,Comments,MainLine
			# pdf,BasicStyle,GameText,Comments,Variation
			# pdf,BasicStyle,GameText,Comments,Subvariation
			# pdf,BasicStyle,GameText,Result
			# pdf,BasicStyle,Diagram
		}
	
		tex {
			# tex,BasicStyle
			# tex,BasicStyle,GameInfo
			# tex,BasicStyle,GameText
			# tex,BasicStyle,GameText,Moves
			# tex,BasicStyle,GameText,Moves,MainLine
			# tex,BasicStyle,GameText,Moves,Variation
			# tex,BasicStyle,GameText,Moves,Subvariation
			# tex,BasicStyle,GameText,Comments
			# tex,BasicStyle,GameText,Comments,MainLine
			# tex,BasicStyle,GameText,Comments,Variation
			# tex,BasicStyle,GameText,Comments,Subvariation
			# tex,BasicStyle,GameText,Result

			# Values(tex,notation)
			# Values(tex,figurines)

			# column style for main line moves (default)
			#-------------------------------------------
			# list of language codes for comments
			#-------------------------------------------
			# show all diagrams from white's perspective
			# show all diagrams from black's perspective
			# show diagram movers (default)
			# board size (10pt, 15pt, 20pt, 30pt) (default is 20pt)
			#-------------------------------------------
			# map unknown NAG's to comments (en,de,it,es) (default is current language)
			# map all NAG's to comments (en,de,it,es) (default is current language)

			# NAG mapping:
			# --------------
			# 7 -> 8
			# --------------
			# 11 -> 10
			# 12 -> 10
			# --------------
			# 22/23 -> 176
			# --------------
			# 24/25 -> 164
			# 26/27 -> 164
			# 28/29 -> 164
			# --------------
			# 30/31 -> 175
			# 32/33 -> 175
			# 34/35 -> 175
			# --------------
			# 36/37 -> 179
			# 38/39 -> 179
			# --------------
			# 40/41 -> 178
			# --------------
			# 44/45 -> 181
			# --------------
			# 48/49 -> 167
			# 50/51 -> 167
			# 52/53 -> 167
			# --------------
			# 54/55 -> 183		(60/61 -> 184)
			# 56/57 -> 183		(62/63 -> 184)
			# 58/59 -> 183		(64/65 -> 184)
			# --------------
			# 130/131 -> 180
			# 132/133 -> 180
			# 134/135 -> 180
			# --------------
			# 151/152 -> 182

			set families {}
			foreach style [array names Values tex,BasicStyle,*] {
				lassign $Values($style) family size weight slant color
				set name [string range $style 4 end]
				append preamble "\\def\\$name\${{$family} \\$size {$weight} {$slant} {$color}}"
			}
			
			set preamble "
				\\def\\DocumentStyle{[string tolower $Values(tex,document)]}
				\\def\\Hyphenation{$Values(tex,primary-lang)}
				\\let\\FontSize\\[lindex $Values(tex,BasicStyle) 1]
				\\def\\PageStyle{$Values(tex,format)}
				\\def\\ColumnStyle{[expr {$Values(tex,columns) == 1 ? onecolumn : twocolumn}]}
				\\def\\Orientation{$Values(tex,orientation)}
				\\let\\Justification\\$Values(tex,justification)
			"
		}
	}

	switch [::dialog::fsbox::saveMode $Info(fsbox)] {
		append		{ set append 1 }
		overwrite	{ set append 0 }
	}

	destroy $dlg

	set cmd [list ::scidb::view::export \
					$Info(base) \
					$Info(view) \
					$file \
					$Info($Values(Type),flags) \
					$append \
					$encoding \
					$excludeGamesWithIllegalMoves \
					$tagList \
				]
	set options [list -message $mc::ExportDatabase -log 0]
	lappend args [namespace current]::Log {}

	# XXX text widget may overflow (too many messages)
	set parent [winfo toplevel $parent]
	set formatName $mc::FormatName($Values(Type))
	if {$formatName eq "scid"} {
		append formatName " " [string index $file end]
	}
	::log::open "$formatName $mc::Export"
	::log::delay
	::log::info [format $mc::ExportingDatabase $Info(name) $file]
	set count [::progress::start $parent $cmd $args $options]
	update idletasks ;# be sure the following will be appended
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
	update idletasks
}


proc CloseView {} {
	variable Info
	::scidb::view::close $Info(base) $Info(view)
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Values
	options::writeItem $chan [namespace current]::Tags no
}

::options::hookWriter [namespace current]::WriteOptions

namespace eval icon {
namespace eval 32x32 {

set IconPDF [image create photo -data {
	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
}]

set IconHtml [image create photo -data {
	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
	Z89a+H8a/wFQq0OtunEjdgAAAABJRU5ErkJggg==
}]

set IconPGN [image create photo -data {
	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
	AABJRU5ErkJggg==
}]

#set IconPS [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAANkE3LLaAgAABb5J
#	REFUeJy1lstvVMkVxn/16Ot+OHYzpDO0bTFx7Eg48owCFiLyLtZIiBBFKJJJdl4QpCwMGjaR
#	4A/IZJMtCyKxYMECsmFnFKEgkUV2M4mEsIdIjBTGBI8ZP9rdfV9VZxbX3TZ2d9uDlCOVbune
#	qvt99Z1HHcP/1/rn5+d/WavV0tXV1W86LVC9dt+4cePT6enpn3nv3wXcl0qlYzMzMz+5c+fO
#	X+fm5mY7LbI9fqCmpqZ+fv78+TPvgi4iLC8v8+bNG6IoKnZb14uAbGxsNA8D5pwjTVOcc+25
#	iNBoNCgUCgDynQgUi8VjIyMj4/l8vnwQuPd+3xARRDJMpRRKdfe07vRydnb290+fPn0yPT39
#	017gIvIWaCciB1lHBay1RWttT+Z7CfRS4TsT6OvrE4A0TQ8N7px7S4kWgYMO0dEFrU3Oua4b
#	u5149/ydFWhZNwW6yd7J/wcp0JNAHMcd32stIALiQQtKBM3OUAjeCT2yrzeBKIqSzc0N1tbX
#	Wf66yVotpR56wtijlZAzoJTgncOLJ3WeRjPFaI9CMMrTZz0Fm6IUeO+7BtM+ApVK5Vi1Wj0e
#	Rw2W68d4+o8a48MFnBhyNkfOKkSy3JbtCBIFuaKQpEKSesQ7Fr+KiRoJ46MppVJpaHR09KMX
#	L158AYS78VoOGrh+/fonMzMzH09OTk5WKpUjxhj+/nmD/64kfFDN47zgvMd7ydQn84AX8F5w
#	XmWBt/3TeihE0Ra/O19lY32deqPhXr9+/eXz58//9fDhw7/dvn37L4CzgLp169aty5cv/2av
#	GkFOWF2PwWWxoHMar8E5T+oF7wXvQURlMohGoUCg1vQc6c/ON1guM1gum6GhobGTJ0+OXbx4
#	8df5fL588+bNP6nh4eGPlpaWPiuVSvtS8p+LIXcfLVMpvMEYEFvABQOIZFGeOkG8wjlwDnyq
#	UBiKQcA3G8KJDxTzF97v6PvFxcWvJiYmPrSnTp063QkcIN+nebUZ82IlRHBgY5wO0RqUgv58
#	wMZWQhgJSQxxDM2mIKmh1Fdi8kdHO4IDjI+PD09MTHxoK5VKZ4qAtYrh4e+jc2WcpNhcloJa
#	g0LRXwjYqCU0Q08SQxRCGILylrBpsMZ0JWCtZWBgoGp7NRtBoPnyfytoFVEsGXIWrAGtsjKw
#	4gQniiSBeBs8DKFRF1bXhF9MHe/6bwCllGmn4d7SqbWi3G84eiTg3/95TXFL0Wchp8HojIAT
#	iB1EaQbcbEKzAVtbwnvfe4+R9wMgC9a91sKykNX8RqOxr2yWFPzhV0N8sXIEvCMwCqO3FSBL
#	wdRD4rZHDFGcPY8fDZj6oader7P3ShARrLU7BOI4ptnc3/woBT+wUB3RgOlaWNWuiQJQgvcx
#	iYN6fWfX7uak5XoLEEXRvrqfz+cJgqAzUA9rwSkDgdlRt3XQNE3J5/Pt9dZ7TxzHbxEIgoDH
#	jx/z5MmTrkAH3XKQST06OsqFCxfaMaa1Jk3TNl7bBa0XWmvq9TrXrl3j5cuXhzjzwTY0NMSZ
#	M2dwzqG1xjm3QyAMw0Ycx0RRBIAxhs3NTcrlMqdPn2ZwcPCt+33vs9tcKUWapiwsLPDq1SuS
#	JKHZbOK9R2tNPp9HRLSt1Wp1rTVBELRbqEKhwJUrVzh79ixadyyShzJrLQ8ePGB4eBgRwRiD
#	MaYdjHEcN1UQBD+em5v7Y7VaHXHOiVLKR1Gkzp07d2psbCzfrSk5jBljWFtbk3v37n0WBEFD
#	RAxALpdTS0tLS3fv3r2hyIJ7EOjf3hedOHHi40ePHt3J5XK2V1/Y6gFNl5KrlKJYLHLp0qVP
#	79+//2egsOvzBlDTZJmzDrzcHl/Pz8/PFotFG4YhSZLsGy1VgiBga2uLRqPR7ox3j1a0X716
#	9bdAYxfGS6AGnVsys7Cw8PmzZ89skiRdLwpjTDs+kiTpqpLWWsdxvEKm8L5q1ymZFdAH5Dt8
#	exdTQLwNvu9A3wL/t44r9rJkdQAAAABJRU5ErkJggg==
#}]

set IconTeX [image create photo -data {
	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
}]

} ;# namespace 32x32

namespace eval 37x21 {

#set IconTeX [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAACUAAAAVCAYAAADB5CeuAAADQ0lEQVRIx73WW4hVZRQH8N85
#	nZqmrT0YVlO7IoouU5ANFJF0V4TuIdhtUy9GBMKU2UOUCWWUhUIZXYxusLsrPTQPTUSEkQ9S
#	DQX2UhbC1oqwsGk7U5NOL+vAZnPGuUCz4MD5vm/ttf/rv9b6f7uRZuUCfIz5Dm0fYAX6ijwZ
#	MEVLs7IHn+IUvIln8WeRJ7vSrOzGW1iMVdiDj5q4eAqA4CaMYXkEm6pdgrPQjeV4Er1pVp6J
#	x3EjElyKEaxoYi8GsG+CoGPYhRfxF/owbxqgzsHmyvpqLMJduDf2RvEQrsGpLQxFBjfjOLxR
#	CfAPzscFmIut2B00T9UG0IUyGIGVNZ8nIv49uLARdV8StJ6HRsV5CHdiO77At1hb5Mnv0wAl
#	zco1AezBDsd7cDoGMVTkSX8LijwZxGCala0oV9uODrZ2FnmyyMztaWzEd+itnX2Iq3AGroPW
#	JMHmRq/1dMj+yPjbE34nBcs/FXmyo+pb5Mn+NCtfw8kdQB0Ve+uLPNnXCVRaW8/Hb5VekGZl
#	E29j2QSJjKdZuQ6PFnkyUtlvBCN1W4bXo4SgWXOog2wUeXIg+qFtCw8BqP3yEbxcS+SZWr+2
#	rSv6+Zc0K3s7gfh7kobtxol1ZrAtxvoPfI6XMIwsfJ6KKW7btQFmS6zb031bmpWr66DqWnUw
#	zcpqdmeHZlXtRyxulyrNynl4rD0wcWPcX/F/PqZ6LZ6LWwLWhHYtrYMaDl1ZEiyuDzUeq7Ay
#	XHvmNOxPs7K9/jr8V1eGZUcwvBkPxNXSincNBHO/Btj3m7UpGcfOQH8C3sU7kR38gDmTTGwf
#	7o5kYGlo3bEhki/E2a1xM7waA3ZliGdXs0PQh3FRgPskfqvirAy2JrIDeCSuoztibxPWRWt8
#	E317WZEnw9Hg54ZW7cb1WNmYpjIfHoC3VrY3ob/Ik9HovwV4BSNFniycidI2p+l/TE0ehIZt
#	SLNyHAfxFb7HDTOV/9Y0/RP8W9u7vSYpX2JDyIPZYKo7JGF0gvOuENcr4lNnVkD9HFfFLVGi
#	0ShZ1bbjs4pw/r+gijzZG8p8PC6P7685aBV50ijypBHl3BhTOys9BffF2G8LnWnhiDQrD6t8
#	Rb6H/pmC+g9X8ueXA3L0+AAAAABJRU5ErkJggg==
#}]

} ;# namespace 37x21
} ;# namespace icon
} ;# namespace export

# vi:set ts=3 sw=3:
