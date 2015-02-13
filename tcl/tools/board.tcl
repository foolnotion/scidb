# \
exec ../src/tkscidb-beta "$0" ${1+"$@"}

option add *Menu.tearOff 0
option add *Menu.activeBackground #678db2
option add *Menu.activeForeground white
option add *Menu.activeBorderWidth 0

namespace eval util { proc source {args} {} }
namespace eval load { set currentFile "" }
namespace eval tooltip { proc tooltip {args} {} }

namespace eval scidb {
	namespace eval dir {
		set home  [file nativename "~"]
		set user  [file nativename "."]
		set share /tmp
	}
}

namespace eval log {
	proc error {x msg} {
		puts stderr "$x: $msg"
		exit 1
	}
}

source colors.tcl
source options.tcl
source i18n.tcl
source utils/place.tcl
source dialogs/choosecolor.tcl
source board-basic.tcl
source board-texture.tcl
source board-pieceset.tcl
source board-stuff.tcl
source board-options.tcl
source widgets/tlistbox.tcl
source contrib/treectrl.tcl

proc util::place::getWmFrameExtents {w} { return [::scidb::tk::wm extents $w] }
proc util::place::getWmWorkArea {w} { return [::scidb::tk::wm workarea $w] }
proc tlistbox::lookupColor {color} { return [::colors::lookup $color] }

foreach subdir {piece square {}} {
	foreach file [glob -directory [file join $::scidb::dir::user themes {*}$subdir] -nocomplain *.dat] {
		set load::currentFile $file
		source $file
	}
}

foreach file [glob -directory [file join $::scidb::dir::user pieces] -nocomplain *.tcl] {
	source $file
}

namespace eval mc {

	proc selectLang {{lang {}}} {
		variable Language
		variable langID
		variable encoding

		if {[llength $lang]} { set Language $lang }

		if {![info exists ::mc::lang$Language]} {
			set Language English
		}

		set langID [set ::mc::lang$Language]
		set encoding [set ::mc::encoding$Language]

		set file [file join $::scidb::dir::share lang $mc::input($Language)]
		if {[file readable $file]} {
			set f [open $file r]
			chan configure $f -encoding $encoding

			while {[gets $f line] >= 0} {
				if {[string length $line] > 0 && [string index $line 0] ne "#"} {
					catch { set [lindex $line 0] [lindex $line 1] }
				}
			}

			close $f
		}

		InvokeLang . $Language
	}

}

::mc::setup
::board::setup

wm withdraw .
set dlg .board
tk::toplevel $dlg -class Scidb
wm withdraw $dlg
set top [ttk::frame $dlg.top]
pack $top -fill both -expand yes

set board [::board::diagram::new $top.board 80 -bordersize 1]
pack $board -fill both -expand yes

bind $dlg <Key-plus>				{ ChangeBoardSize +5 }
bind $dlg <Key-KP_Add>			{ ChangeBoardSize +5 }
bind $dlg <Key-minus>			{ ChangeBoardSize -5 }
bind $dlg <Key-KP_Subtract>	{ ChangeBoardSize -5 }

bind $dlg <Control-plus>			{ ChangeBoardSize +50 }
bind $dlg <Control-KP_Add>			{ ChangeBoardSize +50 }
bind $dlg <Control-minus>			{ ChangeBoardSize -50 }
bind $dlg <Control-KP_Subtract>	{ ChangeBoardSize -50 }

bind [::board::diagram::canvas $board] <ButtonPress-3> PopupMenu

lassign {"" "" "" ""} theme pieceset squarestyle piecestyle
for {set i 0} {$i < $argc} {incr i} {
	set arg [lindex $argv $i]
	if {[string range $arg 0 1] ne "--"} {
		break
	}
	switch -- [string range $arg 2 end] {
		"pieceset"	{ set pieceset [lindex $argv [incr i]] }
		"theme"		{ set theme [lindex $argv [incr i]] }
		default		{ puts stderr "unknown option '$arg'"; exit 1; }
	}
}
set board::theme::style(identifier) $board::defaultId
if {$theme != ""} { ::board::setTheme $theme }
if {$pieceset != ""} { ::board::setPieceSet $pieceset }
if {$theme == "" && $pieceset == ""} { ::board::setTheme Default }

wm protocol $dlg WM_DELETE_WINDOW [list exit 0]
wm resizable $dlg no no
wm title $dlg "Scidb - Board"
wm deiconify $dlg

::board::diagram::update $board

proc ChangeBoardSize {delta} {
	variable board

	set size [expr {[::board::diagram::size $board] + $delta}]
	::board::diagram::resize $board $size
}

proc PopupMenu {} {
	variable dlg

	set menu $dlg.__menu__
	catch { destroy $menu }
	menu $menu
	catch { wm attributes $m -type popup_menu }

	$menu add command -label "Select Theme" -command SelectTheme
	$menu add command -label "Select Piece Set" -command SelectPieceSet
	$menu add command -label "Select Squares" -command SelectSquares
	$menu add command -label "Tune Piece Set" -command TunePieceSet
	$menu add command -label "Generate Image" -command PreviewDialog
	$menu add command -label "Show BBox Info" -command ShowDimensions
	tk_popup $menu {*}[winfo pointerxy $dlg]
}

proc SelectTheme {} {
	variable ::board::theme::style
	variable ::board::theme::styleNames

	set dlg .board.themeselection
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set w $dlg.themes

	tlistbox $w \
		-height 30 \
		-selectmode single \
		-listvariable board::theme::styleNames \
		-takefocus 1 \
		;
	$w addcol text -id text
	foreach styleName $styleNames { $w insert [list $styleName] }
	$w select [lsearch -exact $styleNames [lindex [split $style(identifier) |] 0]]
	$w resize
	bind $w <<ListboxSelect>> [list SetTheme $w]
	pack $w -fill both -expand yes

	wm resizable $dlg no yes
	wm title $dlg "Select Theme"
	wm deiconify $dlg
}

proc SetTheme {w} {
	variable board::theme::styleNames

	ResetPieceSet
	::board::setTheme [lindex $styleNames [$w curselection]]

	if {[winfo exists .board.pieceselection]} {
		::board::pieceset::updatePieceSet .board.pieceselection.top
	}

	if {[winfo exists .board.tuning]} {
		PieceSetChanged
	}

	if {[winfo exists .board.dim]} {
		UpdateDimensions
	}
	if {[winfo exists .board.preview]} {
		GenerateImage
	}
}

proc SelectPieceSet {} {
	set dlg .board.pieceselection
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes
	::board::pieceset::makePieceSelectionFrame $top 15
	::board::pieceset::updatePieceSet $top
	bind $top <<PieceSetChanged>> [list PieceSetSelected %d]
	wm resizable $dlg no yes
	wm title $dlg "Select Piece Set"
	wm deiconify $dlg
	focus $top.pieceSel
}

proc PieceSetSelected {pieceSet} {
	ResetPieceSet
	::board::setPieceSet $pieceSet

	if {[winfo exists .board.tuning]} {
		PieceSetChanged
	}

	if {[winfo exists .board.dim]} {
		UpdateDimensions
	}

	if {[winfo exists .board.preview]} {
		GenerateImage
	}
}

proc SelectSquares {} {
	set dlg .board.squareselection
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set w [ttk::frame $dlg.white]
	set b [ttk::frame $dlg.black]
	set wf [ttk::label $dlg.wf]
	set bf [ttk::label $dlg.bf]
	grid $w  -row 1 -column 1
	grid $b  -row 1 -column 2
	grid $wf -row 2 -column 1 -sticky ew
	grid $bf -row 2 -column 2 -sticky ew
	::board::texture::buildBrowser $w $w lite 10 5 {}
	::board::texture::buildBrowser $b $b dark 10 5 {}
	bind $w <<BrowserSelect>> [list SetSquare $wf lite %d]
	bind $b <<BrowserSelect>> [list SetSquare $bf dark %d]
	wm resizable $dlg no no
	wm title $dlg "Select Squares"
	wm deiconify $dlg
}

proc SetSquare {lbl which file} {
	variable board
	variable ::board::square::style
	variable ::board::needRefresh

	set style($which,texture) $file
	::board::loadTexture $which
	set needRefresh($which,[::board::diagram::size $board]) 1
	::board::setupSquares all
	$lbl configure -text $file
}

proc TunePieceSet {} {
	variable params

	ResetPieceSet
	PieceSetChanged

	set dlg .board.tuning
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set f [ttk::frame $dlg.top]
	pack $f -expand 1 -fill both

	set l [ttk::frame $f.l -border 2 -relief ridge]
	set r [ttk::frame $f.r -border 2 -relief ridge]

	ttk::label $l.lcontourw -text "Contour W"
	ttk::label $l.lcontourb -text "Contour B"
	ttk::label $l.lstrokew -text "Stroke W"
	ttk::label $l.lstrokeb -text "Stroke B"
	ttk::label $l.loverstroke -text "Overstroke"
	ttk::label $l.lscale -text "Scale"
	ttk::label $l.lsampling -text "Sampling"

	set updcmd UpdatePieceSet
	set focusoutcmd {+ %W selection clear }

	ttk::spinbox $l.contourw \
		-from 0 \
		-to 500 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(contourw) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	ttk::spinbox $l.contourb \
		-from 0 \
		-to 500 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(contourb) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	ttk::spinbox $l.strokew \
		-from -1 \
		-to 10 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(strokew) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	ttk::spinbox $l.strokeb \
		-from -1 \
		-to 10 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(strokeb) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	ttk::spinbox $l.overstroke \
		-from 0 \
		-to 20 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(overstroke) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	ttk::spinbox $l.scale \
		-from -99.00 \
		-to +99.00 \
		-increment 0.1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(scale) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	ttk::spinbox $l.sampling \
		-from 50 \
		-to 300 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable params(sampling) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
		;
	
	bind $l.contourw   <FocusOut> $updcmd
	bind $l.contourb   <FocusOut> $updcmd
	bind $l.strokew    <FocusOut> $updcmd
	bind $l.strokeb    <FocusOut> $updcmd
	bind $l.overstroke <FocusOut> $updcmd
	bind $l.scale      <FocusOut> $updcmd
	bind $l.sampling   <FocusOut> $updcmd

	bind $l.contourw   <FocusOut> $focusoutcmd
	bind $l.contourb   <FocusOut> $focusoutcmd
	bind $l.strokew    <FocusOut> $focusoutcmd
	bind $l.strokeb    <FocusOut> $focusoutcmd
	bind $l.overstroke <FocusOut> $focusoutcmd
	bind $l.scale      <FocusOut> $focusoutcmd
	bind $l.sampling   <FocusOut> $focusoutcmd

	grid $l.lcontourw   -row  1 -column 1 -sticky w
	grid $l.contourw    -row  1 -column 3 -sticky w
	grid $l.lcontourb   -row  3 -column 1 -sticky w
	grid $l.contourb    -row  3 -column 3 -sticky w
	grid $l.lstrokew    -row  5 -column 1 -sticky w
	grid $l.strokew     -row  5 -column 3 -sticky w
	grid $l.lstrokeb    -row  7 -column 1 -sticky w
	grid $l.strokeb     -row  7 -column 3 -sticky w
	grid $l.loverstroke -row  9 -column 1 -sticky w
	grid $l.overstroke  -row  9 -column 3 -sticky w
	grid $l.lscale      -row 11 -column 1 -sticky w
	grid $l.scale       -row 11 -column 3 -sticky w
	grid $l.lsampling   -row 13 -column 1 -sticky w
	grid $l.sampling    -row 13 -column 3 -sticky w

	grid rowconfigure $l {0 2 6 14} -minsize 5
	grid rowconfigure $l {4 8 10 12} -minsize 15
	grid columnconfigure $l {0 2 4} -minsize 5

	set row 1

	foreach p {k q r b n p} {
		set w [ttk::labelframe $r.$p -text [string toupper $p]]
		set updcmd [list UpdatePieceSet $p]

		ttk::label $w.lscale -text "Scale"
		ttk::label $w.lmovex -text "Move X"
		ttk::label $w.lmovey -text "Move Y"

		ttk::spinbox $w.scale \
			-from 0.0 \
			-to 2.00 \
			-increment 0.01 \
			-width 10 \
			-command $updcmd \
			-textvariable params($p,scale) \
			-exportselection false \
			-justify right \
			-takefocus 1 \
			;
		ttk::spinbox $w.movex \
			-from -99.00 \
			-to +99.00 \
			-increment 0.1 \
			-width 10 \
			-command $updcmd \
			-textvariable params($p,movex) \
			-exportselection false \
			-justify right \
			-takefocus 1 \
			;
		ttk::spinbox $w.movey \
			-from -99.00 \
			-to +99.00 \
			-increment 0.1 \
			-width 10 \
			-command $updcmd \
			-textvariable params($p,movey) \
			-exportselection false \
			-justify right \
			-takefocus 1 \
			;

		bind $w.scale <FocusOut> $updcmd
		bind $w.movex <FocusOut> $updcmd
		bind $w.movey <FocusOut> $updcmd

		bind $w.scale <FocusOut> $focusoutcmd
		bind $w.movex <FocusOut> $focusoutcmd
		bind $w.movey <FocusOut> $focusoutcmd

		grid $w.lscale -row 1 -column 1 -sticky ew
		grid $w.scale  -row 1 -column 3 -sticky ew
		grid $w.lmovex -row 3 -column 1 -sticky ew
		grid $w.movex  -row 3 -column 3 -sticky ew
		grid $w.lmovey -row 5 -column 1 -sticky ew
		grid $w.movey  -row 5 -column 3 -sticky ew

		grid rowconfigure $w {0 2 4 6} -minsize 5
		grid columnconfigure $w {0 2 4} -minsize 5

		grid $w -row $row -column 1
		incr row 2
	}

	grid rowconfigure $r {0 2 4 6 8 10 14} -minsize 5
	grid columnconfigure $r {0 2 4} -minsize 5

	grid $l -row 0 -column 0 -sticky ns
	grid $r -row 0 -column 2 -sticky ns
	grid columnconfigure $f {1} -minsize 5

	wm resizable $dlg no no
	wm title $dlg "Tune Piece Set"
	wm deiconify $dlg
}

proc PieceSetChanged {} {
	variable board::theme::style
	variable board::pieceset::RegExpPieceScale
	variable board::pieceset::RegExpTranslation
	variable params
	variable board_PieceSet

	set pieceSet [lindex $board_PieceSet [lsearch -exact -index 0 $board_PieceSet $style(piece-set)]]
	set params(stroke) -1
	set params(strokew) -1
	set params(strokeb) -1
	set params(contourw) 0
	set params(contourb) 0
	set params(contour) 0
	set params(sampling) 0
	set params(overstroke) 0
	set params(scale) 1.0

	for {set i 2} {$i < [llength $pieceSet]} {incr i} {
		lassign [lindex $pieceSet $i] attr value
		set params($attr) $value
	}

	set fontName [string map {"-" "_" " " ""} [lindex $pieceSet 0]]
	set source [lindex $pieceSet 1]

	switch -exact -- $source {
		svg		{ upvar #0 svg_$fontName font }
		truetype	{ upvar #0 truetype_$fontName font }
	}

	if {[llength $params(stroke)] == 2} {
		lassign $params(stroke) params(strokew) params(strokeb)
	} else {
		set params(strokew) $params(stroke)
		set params(strokeb) $params(stroke)
	}

	if {[llength $params(contour)] == 2} {
		lassign $params(contour) params(contourw) params(contourb)
	} else {
		set params(contourw) $params(contour)
		set params(contourb) $params(contour)
	}

	foreach p {k q r b n p} {
		set pieceScale 1.0
		set pieceMoveX 0
		set pieceMoveY 0

		regexp $RegExpPieceScale $font(w$p) - pieceScale
		regexp $RegExpTranslation $font(w$p) - pieceMoveX pieceMoveY

		set params($p,scale) $pieceScale
		set params($p,scale,initial) $pieceScale
		set params($p,movex) $pieceMoveX
		set params($p,movex,initial) $pieceMoveX
		set params($p,movey) $pieceMoveY
		set params($p,movey,initial) $pieceMoveY
	}
}

proc ResetPieceSet {} {
	array set board::pieceset::PieceScale { k 1 q 1 r 1 b 1 n 1 p 1 }
	array set board::pieceset::PieceMoveX { k 0 q 0 r 0 b 0 n 0 p 0 }
	array set board::pieceset::PieceMoveY { k 0 q 0 r 0 b 0 n 0 p 0 }
	array set board::pieceset::Stroke     { w -1 b -1 }
	array set board::pieceset::Contour    { w 0 b 0 }

	set board::pieceset::Scale 1.0
	set board::pieceset::Sampling	0
	set board::pieceset::Overstroke	0
}


proc UpdatePieceSet {{p {}}} {
	variable board::theme::style

	set grad(w) {}
	set grad(b) {}
	set pieceSet $style(piece-set)

	variable board::piece::style

	##########################################################################################
	# NOTE: this hack is neccessary as long as the Skulls font will not be rendered accurately
	if {$pieceSet eq "Skulls"} {
		if {	!$style(gradient,w,use)
			&& [llength $style(color,w,fill)] == 0
			&& [llength $style(color,w,texture)] == 0} {

			set grad(w) [list \
								\#fbfbfb \
								\#141414 \
								0.22297297297297297 \
								0 \
								0.7837837837837838 \
								0.9932432432432432 \
							 ]
		}
		if {	!$style(gradient,b,use)
			&& [llength $style(color,b,fill)] == 0
			&& [llength $style(color,b,texture)] == 0} {

			set grad(b) [list \
								\#be9771 \
								\#0c0c0c \
								0.32432432432432434 \
								0.13513513513513514 \
								0.8108108108108109 \
								1 \
							 ]
		}
	}
	# end of hack ############################################################################

	foreach color {w b} {
		if {$style(gradient,$color,use)} {
			if {$grad($color) eq ""} {
				set grad($color) [list \
										$style(gradient,$color,start) \
										$style(gradient,$color,stop) \
										$style(gradient,$color,x1) \
										$style(gradient,$color,y1) \
										$style(gradient,$color,x2) \
										$style(gradient,$color,y2) \
									 ]
			}

			if {[board::pieceset::isOutline]} {
				lappend grad($color) $style(gradient,$color,tx) $style(gradient,$color,ty)
			}
		}
	}

	if {[board::pieceset::isOutline] && !$style(useWhitePiece)} {
		set fillColors [list $style(color,w,fill) $style(color,b,stroke)]
		set strokeColors [list $style(color,w,stroke) $style(color,b,fill)]
	} else {
		set fillColors [list $style(color,w,fill) $style(color,b,fill)]
		set strokeColors [list $style(color,w,stroke) $style(color,b,stroke)]
	}

	set texture [list $style(color,w,texture) $style(color,b,texture)]
	set contour [list $style(color,w,contour) $style(color,b,contour)]
	set gradients [list $grad(w) $grad(b)]
	set pieceSet [lindex $::board_PieceSet [lsearch -exact -index 0 $::board_PieceSet $pieceSet]]

	############################################################################################

	if {[llength $p] == 0} {
		set pieceList {wk wq wr wb wn wp bk bq br bb bn bp}
	} else {
		set pieceList [list w$p b$p]
	}

	variable board
	variable params

	set size [::board::diagram::size $board]

	foreach cp $pieceList {
		lassign [split $cp {}] c p

		set board::pieceset::PieceScale($p) [expr {$params($p,scale)/$params($p,scale,initial)}]
		set board::pieceset::PieceMoveX($p) [expr {$params($p,movex) - $params($p,movex,initial)}]
		set board::pieceset::PieceMoveY($p) [expr {$params($p,movey) - $params($p,movey,initial)}]

		set board::pieceset::Stroke(w) $params(strokew)
		set board::pieceset::Stroke(b) $params(strokeb)
		set board::pieceset::Contour(w) $params(contourw)
		set board::pieceset::Contour(b) $params(contourb)
		set board::pieceset::Sampling $params(sampling)
		set board::pieceset::Overstroke $params(overstroke)
		set board::pieceset::Scale $params(scale)

		board::pieceset::MakePieces \
			{}                       \
			$pieceSet                \
			[list $cp]               \
			$size                    \
			$style(zoom)             \
			$style(contour)          \
			no                       \
			$style(shadow)           \
			$fillColors              \
			$strokeColors            \
			$texture                 \
			$contour                 \
			$gradients               \
			$style(opacity)          \
			$style(diffusion)        \
			$style(useWhitePiece)    \
			;
	}
}

proc GenerateImage {} {
	variable board::theme::style
	variable Stroke
	variable Zoom
	variable Size
	variable Img

	array set stroke [array get board::pieceset::Stroke]
	$Img blank

	set pieceSet [lindex $::board_PieceSet [lsearch -exact -index 0 $::board_PieceSet $style(piece-set)]]
	set board::pieceset::Stroke(w) $Stroke(w)
	set board::pieceset::Stroke(b) $Stroke(b)

	board::pieceset::MakePieces \
		{}                       \
		$pieceSet                \
		{wk bq wr bb wn bp}      \
		$Size                    \
		$Zoom                    \
		0                        \
		no                       \
		0                        \
		{#ffffff00 #ffffff00}    \
		{{} {}}                  \
		{{} {}}                  \
		{{} {}}                  \
		{{} {}}                  \
		0                        \
		linear                   \
		no                       \
		;

	set x 0
	set i 1
	foreach p {wk bq wr bb wn bp} {
		$Img copy photo_Piece($p,$Size) -to $x 0 [expr {$x + 34}] 34
		set x [expr {int((200/6.0)*$i + 0.5)}]
		incr i
	}

	array set board::pieceset::Stroke [array get stroke]
}

proc PreviewDialog {} {
	variable Stroke
	variable Zoom
	variable Size
	variable Img

	array set Stroke { w 20 b 10 }
	set Zoom 1.0
	set Size 34

	set dlg .board.preview
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg

	::board::registerSize $Size
	set top [ttk::frame $dlg.top]
	pack $top -expand yes -fill both
	set canv [canvas $top.canv -width 200 -height $Size -background white -border 1 -relief raised]
	set Img [image create photo -width 200 -height $Size]
	set updcmd GenerateImage

	set lstrokew [ttk::label $top.lstrokew -text "Stroke W"]
	set lstrokeb [ttk::label $top.lstrokeb -text "Stroke B"]
	set lzoom [ttk::label $top.lzoom -text "Zoom"]

	set strokew [ttk::spinbox $top.strokew \
		-from 0 \
		-to 50 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable Stroke(w) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
	]
	set strokeb [ttk::spinbox $top.strokeb \
		-from 0 \
		-to 50 \
		-increment 1 \
		-width 10 \
		-command $updcmd \
		-textvariable Stroke(b) \
		-exportselection false \
		-justify right \
		-takefocus 1 \
	]
	set zoom [ttk::spinbox $top.zoom \
		-from 0.5 \
		-to 1.5 \
		-increment 0.1 \
		-width 10 \
		-command $updcmd \
		-textvariable Zoom \
		-exportselection false \
		-justify right \
		-takefocus 1 \
	]
	set save [ttk::button $top.save -text "Save" -command [list SaveImage $top]]

	bind $strokew <FocusOut> $updcmd
	bind $strokeb <FocusOut> $updcmd
	bind $zoom    <FocusOut> $updcmd

	set focusoutcmd {+ %W selection clear }
	bind $strokew <FocusOut> $focusoutcmd
	bind $strokeb <FocusOut> $focusoutcmd
	bind $zoom    <FocusOut> $focusoutcmd
	
	grid $canv     -row 1 -column 1 -sticky ew -columnspan 3
	grid $lstrokew -row 3 -column 1 -sticky w
	grid $strokew  -row 3 -column 3 -sticky w
	grid $lstrokeb -row 5 -column 1 -sticky w
	grid $strokeb  -row 5 -column 3 -sticky w
	grid $lzoom    -row 7 -column 1 -sticky w
	grid $zoom     -row 7 -column 3 -sticky w
	grid $save     -row 9 -column 1 -sticky ew -columnspan 3

	grid rowconfigure $top {0 4 6 10} -minsize 5
	grid rowconfigure $top {2 8} -minsize 10
	grid columnconfigure $top {0 2 4} -minsize 5
	grid columnconfigure $top {3} -weight 1

	GenerateImage
	$canv create image 0 0 -image $Img -anchor nw

	bind $top <Destroy> [list ::board::unregisterSize $Size]
	bind $top <Destroy> +[list image delete $Img]

	wm resizable $dlg no no
	wm title $dlg "Image"
	wm deiconify $dlg
}

proc SaveImage {w} {
	variable Img

	set fname [tk_getSaveFile \
		-confirmoverwrite yes \
		-defaultextension .png \
		-filetypes {{{PNG Files} {.png} .PNG}} \
		-parent $w \
		-title "Save image" \
	]
	if {[string length $fname]} {
		if {[catch {$Img write -format png $fname} result]} {
			tk_messageBox -message "Failed to write image" -type ok -parent $w
		}
	}
}

proc ShowDimensions {} {
	set dlg .board.dim
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg

	set top [ttk::frame $dlg.top]
	pack $top -expand yes -fill both
	tk::text $top.info \
		-borderwidth 0 \
		-exportselection yes \
		-width 40 \
		-height 12 \
		-undo no \
		-state disabled \
		;
	pack $top.info -expand yes -fill both -padx 5 -pady 5
	UpdateDimensions

	wm resizable $dlg yes no
	wm title $dlg "Dimensions"
	wm deiconify $dlg
}

proc UpdateDimensions {} {
	variable board::pieceset::Dimensions

	set text .board.dim.top.info
	$text configure -state normal
	$text delete 1.0 end
	foreach line $Dimensions {
		$text insert end $line
		$text insert end \n
	}
	$text configure -state disabled
}

# vi:set ts=3 sw=3:
