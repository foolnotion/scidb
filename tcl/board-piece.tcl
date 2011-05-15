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

namespace eval board {
namespace eval piece {
namespace eval mc {

set Start					"Start"
set Stop						"Stop"
set HorzOffset				"Horizontal Offset"
set VertOffset				"Vertical Offset"
set Gradient				"Gradient"
set Fill						"Fill"
set Stroke					"Stroke"
set Contour					"Contour"
set WhiteShape				"White Shape"
set PieceSelection		"Piece Selection"
set BackgroundSelection	"Background Selection"
set Zoom						"Zoom"
set Shadow					"Shadow"
set Opacity					"Opacity"
set ShadowDiffusion		"Shadow Diffusion"
set None						"None"
set Linear					"Linear"
set Quadratic				"Quadratic"
set PieceStyleConf		"Piece Style Configuration"
set Offset					"Offset"
set Rotate					"Rotate"
set CloseDialog			"Close dialog and throw away changes?"
set OpenTextureDialog	"Open Texture Dialog"

} ;# namespace mc

variable Vars
variable Style
variable Widget
variable Piece		n
variable Layout	ld

array set RecentColors {
	w { {} {} {} {} {} {} }
	b { {} {} {} {} {} {} }
}

array set RecentTextures {
	w { {} {} {} {} {} {} }
	b { {} {} {} {} {} {} }
}

array set SquareStyle {
	w lite
	b dark
}

array set Offset {
	w,tx 0
	w,ty 0
	b,tx 0
	b,ty 0
}

array set Constant {
	contourMaxTick	40
	shadowMaxTick	15
	svgPattern		"
<g>
	<defs>
		<linearGradient
			id=\"linearGradient\" 
			x1=\"#x1#\" y1=\"#y1#\" x2=\"#x2#\" y2=\"#y2#\">
			<stop offset=\"#start-offs#%\" stop-color=\"#start-color#\" />
			<stop offset=\"#stop-offs#%\" stop-color=\"#stop-color#\" />
		</linearGradient>
	</defs>
	<rect
		style=\"fill:url(#linearGradient);stroke:none\"
		x=\"0\" y=\"0\" width=\"100\" height=\"100\"/>
</g>"
}


namespace import [namespace parent]::loadTexture
namespace import [namespace parent]::setupPieces
namespace import [namespace parent]::texture::buildBrowser
namespace import [namespace parent]::texture::makePopup
namespace import [namespace parent]::texture::popup
namespace import [namespace parent]::texture::popdown
namespace import [namespace parent]::pieceset::isOutline
namespace import [namespace parent]::pieceset::computeStartOffset
namespace import [namespace parent]::pieceset::computeStopOffset
namespace import [namespace parent]::pieceset::makePieces
namespace import ::dialog::choosecolor::addToList
namespace import ::tcl::mathfunc::*


proc Update {{colors {}}} {
	variable [namespace parent]::designSize
	variable Piece

	set pieces {}
	if {$colors eq ""} { set colors {w b} }
	foreach color $colors { lappend pieces $color$Piece }
	makePieces $designSize $pieces
}


proc CallUpdate {args} {
	variable [namespace parent]::designSize
	variable style
	variable Style
	variable Constant

	set style(contour)	[expr {double($Style(contour))*(2.0/$Constant(contourMaxTick))}]
	set style(shadow)		[expr {double($Style(shadow))/double($designSize)}]
	set style(opacity)	[expr {double($Style(opacity))/255.0}]
	set style(zoom)		[expr {double($Style(zoom))/100.0}]

	Update
}


proc MakeTexture {which} {
	variable [namespace parent]::designSize

	[namespace parent]::refreshTexture [expr {$which eq "w" ? "white" : "black"}] $designSize
	Update $which
}


proc ConfigureTextureFrame {which} {
	variable [namespace parent]::texture
	variable [namespace parent]::designSize
	variable style
	variable Widget

	set color	[expr {$which eq "w" ? "white" : "black"}]
	set iw		[image width $texture($color)]
	set ih		[image height $texture($color)]
	set s			[min $iw $ih]
	set f			[expr {int(round(100.0*(double($designSize)/double($s))))}]
	set canv		$Widget(texture,$which)

	if {$style(texture,$which,rotation) == 90 || $style(texture,$which,rotation) == 270} {
		set ww $iw; set iw $ih; set ih $ww
	}

	if {$iw > $designSize} {
		$Widget(offsx,$which) configure -state normal -to [expr {$iw - $designSize}]
		::validate::spinboxInt $Widget(offsx,$which)
	} else {
		$Widget(offsx,$which) configure -state disabled
	}
	if {$ih > $designSize} {
		$Widget(offsy,$which) configure -state normal -to [expr {$ih - $designSize}]
		::validate::spinboxInt $Widget(offsy,$which)
	} else {
		$Widget(offsy,$which) configure -state disabled
	}
	if {$iw > $designSize || $ih > $designSize} {
		$canv configure -cursor hand2
		bind $canv <ButtonPress-1> "
			::tooltip::tooltip off
			set [namespace current]::Vars(position) {%X %Y}
			set [namespace current]::Vars(offset,$which,X) \$[namespace current]::Vars(offset,$which,x)
			set [namespace current]::Vars(offset,$which,Y) \$[namespace current]::Vars(offset,$which,y)
		"
		bind $canv <Any-Button>			[namespace code { HideCurrentTexture }]
		bind $canv <ButtonRelease-1>	[namespace code {
			::tooltip::tooltip on
			unset -nocomplain Vars(position)
		}]
		bind $canv <Button1-Motion>	[namespace code [list MoveTexture $which %X %Y]]
		bind $canv <ButtonPress-2>		[namespace code [list ShowCurrentTexture $which %X %Y]]
		bind $canv <ButtonPress-3>		[namespace code [list ShowCurrentTexture $which %X %Y]]
		bind $canv <ButtonRelease-2>	[namespace code { HideCurrentTexture }]
		bind $canv <ButtonRelease-3>	[namespace code { HideCurrentTexture }]
	} else {
		$canv configure -cursor {}
		bind $canv <ButtonPress-1>		{}
		bind $canv <Button1-Motion>	{}
		bind $canv <ButtonPress-2>		{}
		bind $canv <ButtonPress-3>		{}
		bind $canv <ButtonRelease-1>	{}
		bind $canv <ButtonRelease-2>	{}
		bind $canv <ButtonRelease-3>	{}
	}
	if {$f >= 100} {
		$Widget(zoom,$which) configure -state disabled
	} else {
		$Widget(zoom,$which) configure -state normal -from $f
	}
	foreach deg {0 90 180 270} { $Widget($deg,$which) configure -state normal }
}



proc ShowCurrentTexture {which xc yc} {
	variable [namespace parent]::texture
	variable style
	variable Vars

	set w [makePopup]
	set color [expr {$which eq "w" ? "white" : "black"}]

	incr xc 5
	incr yc 5
	set x1 $style(texture,$which,x1)
	set y1 $style(texture,$which,y1)
	set x2 $style(texture,$which,x2)
	set y2 $style(texture,$which,y2)

	if {$style(texture,$which,rotation)} {
		set ht [image height $texture($color)]
		set wd [image width $texture($color)]
		if {$style(texture,$which,rotation) == 90 || $style(texture,$which,rotation) == 270} {
			set t $ht; set ht $wd; set wd $t
		}
		$w.texture configure -height $ht -width $wd
		set Vars(currentTexture) [image create photo -width $wd -height $ht]
		::scidb::tk::image copy $texture($color) $Vars(currentTexture) \
			-rotate [expr {$style(texture,$which,rotation)/90}]
		$w.texture itemconfigure img -image $Vars(currentTexture)
		set dx [expr {$x2 - $x1}]
		set dy [expr {$y2 - $y1}]
		lassign [RotateOffsets $which 0 $style(texture,$which,rotation) $x1 $y1] x1 y1
		set x2 [expr {$x1 + $dx}]
		set y2 [expr {$y1 + $dy}]
	} else {
		$w.texture configure \
			-height [image height $texture($color)] \
			-width [image width $texture($color)]
		$w.texture itemconfigure img -image $texture($color)
	}

	$w.texture itemconfigure view -state normal
	$w.texture coords dark $x1 $y1 $x2 $y2
	$w.texture coords lite [expr {$x1 + 1}] [expr {$y1 + 1}] [expr {$x2 - 1}] [expr {$y2 - 1}]
	[namespace parent]::texture::popup $w $xc $yc
}


proc HideCurrentTexture {} {
	variable Vars

	catch {
		image delete $Vars(currentTexture)
		set Vars(currentTexture) {}
	}

	popdown
}


proc MoveTexture {which x y} {
	variable [namespace parent]::texture
	variable style
	variable Vars

	# catching <Button1-Motion> event w/o preceding <ButtonPress-1> event
	if {![info exists Vars(position)]} { return }

	lassign $Vars(position) x0 y0
	lassign \
		[RotateOffsets $which $Vars(rotation,$which) \
			-$Vars(rotation,$which) $Vars(offset,$which,X) $Vars(offset,$which,Y)] \
		offsX offsY

	switch $Vars(rotation,$which) {
		0   { set tx [expr {$x0 - $x}]; set ty [expr {$y0 - $y}] }
		90  { set tx [expr {$y0 - $y}]; set ty [expr {$x - $x0}] }
		180 { set tx [expr {$x - $x0}]; set ty [expr {$y - $y0}] }
		270 { set tx [expr {$y - $y0}]; set ty [expr {$x0 - $x}] }
	}

	set color [expr {$which eq "w" ? "white" : "black"}]

	set s  [expr {100.0/$Vars(zoom,$which)}]
	set x1 [expr {$offsX + $tx}]
	set y1 [expr {$offsY + $ty}]
	set dx [expr {$style(texture,$which,x2) - $style(texture,$which,x1)}]
	set iw [image width $texture($color)]
	set ih [image height $texture($color)]

	if {$x1 < 0} {
		set x1 0
	} elseif {round($s*$x1) + $dx > $iw} {
		set x1 [expr {int(round(($iw - $dx)/$s))}]
	}
	if {$y1 < 0} {
		set y1 0
	} elseif {round($s*$y1) + $dx > $ih} {
		set y1 [expr {int(round(($ih - $dx)/$s))}]
	}

	lassign [RotateOffsets $which 0 $Vars(rotation,$which) $x1 $y1] offsx offsy

	if {$offsx != $Vars(offset,$which,x) || $offsy != $Vars(offset,$which,y)} {
		set Vars(offset,$which,x) $offsx
		set Vars(offset,$which,y) $offsy
		ShiftTexture $which
	}
}


proc RotateOffsets {which currentRotation deg x y} {
	variable [namespace parent]::texture
	variable style

	if {$deg < 0} { set deg [expr {360 + $deg}] }
	if {$deg == -0} { set deg 0 }

	set color [expr {$which eq "w" ? "white" : "black"}]
	set dx [expr {$style(texture,$which,x2) - $style(texture,$which,x1)}]

	if {$currentRotation == 90 || $currentRotation == 270} {
		set iw [image height $texture($color)]
		set ih [image width $texture($color)]
	} else {
		set iw [image width $texture($color)]
		set ih [image height $texture($color)]
	}

	switch $deg {
		0 {
			set offsx $x
			set offsy $y
		}

		90 {
			set offsx [expr {$ih - $y - $dx}]
			set offsy $x
		}

		180 {
			set offsx [expr {$iw - $x - $dx}]
			set offsy [expr {$ih - $y - $dx}]
		}

		270 {
			set offsx $y
			set offsy [expr {$iw - $x - $dx}]
		}
	}

	return [list $offsx $offsy]
}


proc RotateTexture {which} {
	variable style
	variable Widget
	variable Vars

	set deg [expr {$Vars(rotation,$which) - $style(texture,$which,rotation)}]
	if {$deg == 0} { return }
	if {$deg < 0} { set deg [expr {360 + $deg}] }

	lassign \
		[RotateOffsets \
			$which \
			$style(texture,$which,rotation) \
			$deg \
			$Vars(offset,$which,x) \
			$Vars(offset,$which,y)] \
		offsx offsy

	if {$deg == 90 || $deg == 270} {
		set val [$Widget(offsx,$which) cget -to]
		$Widget(offsx,$which) configure -to [$Widget(offsy,$which) cget -to]
		$Widget(offsy,$which) configure -to $val
		::validate::spinboxInt $Widget(offsx,$which)
		::validate::spinboxInt $Widget(offsy,$which)
	}

	set Vars(offset,$which,x) $offsx
	set Vars(offset,$which,y) $offsy
	set style(texture,$which,rotation) $Vars(rotation,$which)
	MakeTexture $which
	ConfigureTextureFrame $which
}


proc ZoomTexture {which} {
	variable [namespace parent]::texture
	variable [namespace parent]::designSize
	variable style
	variable Vars
	variable Widget

	set color [expr {$which eq "w" ? "white" : "black"}]

	set s  [expr {$Vars(zoom,$which)/100.0}]
	set iw [image width $texture($color)]
	set ih [image height $texture($color)]
	set is [min [expr {int(round($designSize/$s))}] $iw $ih]

	if {$is == $style(texture,$which,x2) - $style(texture,$which,x1)} { return }

	if {$iw > $is} {
		$Widget(offsx,$which) configure -state normal -to [expr {int(round($s*($iw - $is)))}]
		::validate::spinboxInt $Widget(offsx,$which)
	} else {
		$Widget(offsx,$which) configure -state disabled
	}
	if {$ih > $is} {
		$Widget(offsy,$which) configure -state normal -to [expr {int(round($s*($ih - $is)))}]
		::validate::spinboxInt $Widget(offsy,$which)
	} else {
		$Widget(offsy,$which) configure -state disabled
	}
	
	set x1 [max 0 [expr {($style(texture,$which,x1) + $style(texture,$which,x2) - $is)/2}]]
	set y1 [max 0 [expr {($style(texture,$which,y1) + $style(texture,$which,y2) - $is)/2}]]
	set x2 [expr {$x1 + $is}]
	set y2 [expr {$y1 + $is}]
	
	if {$x2 > $iw} {
		set x2 $iw
		set x1 [expr {$iw - $is}]
	}
	if {$y2 > $ih} {
		set y2 $ih
		set y1 [expr {$ih - $is}]
	}

	set style(texture,$which,x1) $x1
	set style(texture,$which,y1) $y1
	set style(texture,$which,x2) $x2
	set style(texture,$which,y2) $y2

	set offsx [expr {round(int($s*$x1))}]
	set offsy [expr {round(int($s*$y1))}]
	lassign \
		[RotateOffsets $which $Vars(rotation,$which) $Vars(rotation,$which) $offsx $offsy] \
		Vars(offset,$which,x) Vars(offset,$which,y)

	$Widget(texture,$which) configure -cursor [expr {$iw > $is || $ih > $is ? "hand2" : ""}]
	MakeTexture $which
}


proc ShiftTexture {which} {
	variable style
	variable Vars

	lassign \
		[RotateOffsets $which $Vars(rotation,$which) \
			-$Vars(rotation,$which) $Vars(offset,$which,x) $Vars(offset,$which,y)] \
		offsx offsy

	set x1 $style(texture,$which,x1)
	set y1 $style(texture,$which,y1)
	set s  [expr {100.0/$Vars(zoom,$which)}]

	set style(texture,$which,x1) [expr {int(round($s*$offsx))}]
	set style(texture,$which,y1) [expr {int(round($s*$offsy))}]

	if {$x1 != $style(texture,$which,x1) || $y1 != $style(texture,$which,y1)} {
		set style(texture,$which,x2) [expr {$style(texture,$which,x2) + $style(texture,$which,x1) - $x1}]
		set style(texture,$which,y2) [expr {$style(texture,$which,y2) + $style(texture,$which,y1) - $y1}]
		MakeTexture $which
	}
}


proc SetTexture {which texture {private false}} {
	variable [namespace parent]::designSize
	variable style
	variable Widget
	variable Vars

	if {$texture eq $style(color,$which,texture)} { return }

	set color [expr {$which eq "w" ? "white" : "black"}]
	set style(color,$which,texture) $texture
	set texture [loadTexture $color]

	if {[llength $texture]} {
		set style(texture,$which,x1) 0
		set style(texture,$which,y1) 0
		set style(texture,$which,x2) $designSize
		set style(texture,$which,y2) $designSize
		set style(texture,$which,rotation) 0
		set Vars(zoom,$which) 100
		set Vars(offset,$which,x) 0
		set Vars(offset,$which,y) 0
		set Vars(rotation,$which) 0
		if {$private} {
			ConfigureTextureFrame $which
		} else {
			ConfigurePieceFrame $which
		}
		MakeTexture $which
	} else {
		::scidb::tk::image recolor #00000000 photo_Square($color,$designSize)
	}
}


proc ResetTexture {which} {
	variable __style
	variable style

	SetTexture $which $__style(color,$which,texture) true
	array set style [array get __style]
}


proc SelectTexture {parent which} {
	variable [namespace parent]::designSize
	variable style
	variable Widget
	variable Vars
	variable __style

	array set __style [array get style]
	incr Vars(open)

	set color [expr {$which eq "w" ? "white" : "black"}]
	set s [expr {$style(texture,$which,x2) - $style(texture,$which,x1)}]
	set state [expr {$s ? "normal" : "disabled"}]

	set Vars(zoom,$which) [expr {$s ? int(round(100.0*(double($designSize)/double($s)))) : 100}]
	set Vars(offset,$which,x) $style(texture,$which,x1)
	set Vars(offset,$which,y) $style(texture,$which,y1)
	set Vars(rotation,$which) $style(texture,$which,rotation)

	set dlg [toplevel $parent.select_texture_$which -class Scidb]
	bind $dlg <<BrowserSelect>> [namespace code [list SetTexture $which "%d" true]]
	bind $dlg <Destroy> "if {{%W} eq {$dlg}} { incr [namespace current]::Vars(open) -1 }"

	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes
	set lt [ttk::frame $top.lt]
	set rt [ttk::frame $top.rt]

	grid $lt -row 1 -column 1 -sticky nsew
	grid $rt -row 1 -column 3 -sticky nsew
	grid columnconfigure $top 3 -weight 1
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid rowconfigure $top 0 -minsize $::theme::padx
	grid rowconfigure $top 1 -weight 1

	ttk::frame $lt.texture -borderwidth 2 -relief groove
	set Widget(texture,$which) [canvas $lt.texture.c -width $designSize -height $designSize]
	pack $lt.texture.c -expand yes -fill both
	$lt.texture.c create rectangle 0 0 $designSize $designSize \
		-width 1 -outline [$lt.texture.c cget -background]
	$lt.texture.c create image 0 0 -image photo_Square($color,$designSize) -anchor nw

	ttk::label $lt.lzoom -textvar [namespace current]::mc::Zoom
	set Widget(zoom,$which) [ \
		::ttk::spinbox $lt.szoom \
			-from 1 \
			-to 100 \
			-textvariable [namespace current]::Vars(zoom,$which) \
			-width 3 \
			-state $state \
			-exportselection false \
			-justify right \
			-command [namespace code [list ZoomTexture $which]]] \
			;
	::validate::spinboxInt $lt.szoom
	::theme::configureSpinbox $lt.szoom
	foreach c {x y} {
		ttk::label $lt.loffs$c -textvar [::mc::var [namespace current]::mc::Offset [string toupper $c]]
		set Widget(offs$c,$which) [ \
			::ttk::spinbox $lt.soffs$c \
				-from 0 \
				-to 0 \
				-textvariable [namespace current]::Vars(offset,$which,$c) \
				-width 3 \
				-state $state \
				-exportselection false \
				-justify right \
				-command [namespace code [list ShiftTexture $which]]] \
				;
		::validate::spinboxInt $lt.soffs$c
		::theme::configureSpinbox $lt.soffs$c
	}
	ttk::label $lt.lrot -textvar [namespace current]::mc::Rotate
	foreach deg {0 90 180 270} {
		set Widget($deg,$which) [ \
			ttk::checkbutton \
				$lt.b$deg \
				-text "$deg°" \
				-variable [namespace current]::Vars(rotation,$which) \
				-onvalue $deg \
				-state $state \
				-command [namespace code [list RotateTexture $which]]]
	}

	bind $Widget(zoom,$which)  <FocusOut> +[namespace code [list ZoomTexture $which]]
	bind $Widget(offsx,$which) <FocusOut> +[namespace code [list ShiftTexture $which]]
	bind $Widget(offsy,$which) <FocusOut> +[namespace code [list ShiftTexture $which]]

	set browser [buildBrowser \
						$top.rt \
						$dlg \
						[expr {$which eq "w" ? "lite" : "dark"}] \
						5 5 \
						$style(color,$which,texture) \
						$style(color,[expr {$which eq "w" ? "b" : "w"}],texture)]
	SetTexture $which $style(color,$which,texture) true
	if {[llength $style(color,$which,texture)]} { ConfigureTextureFrame $which }

	widget::dialogButtons $dlg {ok cancel} ok
	$dlg.ok configure -command "destroy $dlg"
	$dlg.cancel configure -command "
		[namespace current]::ResetTexture $which
		destroy $dlg"

	grid $lt.texture	-row  1 -column 1 -sticky n   -columnspan 5
	grid $lt.lzoom		-row  3 -column 1 -sticky ew
	grid $lt.szoom		-row  3 -column 3 -sticky ew  -columnspan 3
	grid $lt.loffsx	-row  5 -column 1 -sticky ew
	grid $lt.soffsx	-row  5 -column 3 -sticky ew  -columnspan 3
	grid $lt.loffsy	-row  7 -column 1 -sticky ew
	grid $lt.soffsy	-row  7 -column 3 -sticky ew  -columnspan 3
	grid $lt.lrot		-row  9 -column 1 -sticky ew
	grid $lt.b0			-row  9 -column 3 -sticky ew
	grid $lt.b180		-row  9 -column 5 -sticky ew
	grid $lt.b90		-row 11 -column 3 -sticky ew
	grid $lt.b270		-row 11 -column 5 -sticky ew
	grid columnconfigure $lt {0 2 4 6} -minsize $::theme::padx
	grid rowconfigure $lt {0 4 6 10 12} -minsize $::theme::pady
	grid rowconfigure $lt {2 8} -minsize [expr {2*$::theme::pady}]

	if {[winfo viewable [winfo toplevel $parent]]} { wm transient $dlg $parent }
	wm iconname $dlg ""
	wm title $dlg "$::scidb::app: $::mc::Texture"
	wm protocol $dlg WM_DELETE_WINDOW "destroy $dlg"
	wm withdraw $dlg
	update idletasks
	wm minsize $dlg [winfo reqwidth $dlg] [winfo reqheight $dlg]
	util::place $dlg right $Widget(piece,$which)
	wm deiconify $dlg
	focus $browser
	ttk::grabWindow $dlg
	tkwait window $dlg
	ttk::releaseGrab $dlg

	return	[expr {	[llength $style(color,$which,texture)] \
						&& $__style(color,$which,texture) ne $style(color,$which,texture)}]
}


proc SelectColor {parent var component which showEraser} {
	variable [namespace parent]::texture
	variable [namespace parent]::designSize
	variable style
	variable RecentColors
	variable RecentTextures
	variable Vars

	set initialColor $style($component,$which,$var)
	set oldColor $initialColor
	set actions {}
	set useWhite [expr {$which eq "w" || ([isOutline] && $style(useWhitePiece))}]
	set useGradient $style(gradient,$which,use)
	set textures {}

	if {$initialColor eq ""} { set initialColor [DefaultColor $var $which] }
	if {$var eq "start" || $var eq "stop"} { set oldColor {} }

	if {$var eq "fill" && ($which eq "w" || $useWhite || ![isOutline])} {
		set actions [list texture $::icon::16x16::texture $mc::OpenTextureDialog]
		set textures $RecentTextures($which)
	}

	incr Vars(open)
	set selection [::colormenu::popup $parent \
							-eraser $showEraser \
							-action $actions \
							-class Dialog \
							-initialcolor $initialColor \
							-oldcolor $oldColor \
							-recentcolors $RecentColors($which) \
							-textures $textures \
							-geometry last \
							-modal true \
							-place centeronparent \
							-embedcmd [namespace code [list MakePreview $var $which]] \
							-height [expr {$designSize + 20}]]
	incr Vars(open) -1

	switch -- $selection {
		erase {
			set style($component,$which,$var) {}
			SetTexture $which {}
		}

		texture {
			set style(gradient,$which,use) false

			if {[SelectTexture $parent $which]} {
				set useGradient false

				if {[llength $style(color,$which,fill)]} {
					set RecentColors($which) [addToList $RecentColors($which) $style($component,$which,$var)]
					set style(color,$which,fill) {}
				}

				set color [expr {$which eq "w" ? "white" : "black"}]
				set img photo_Texture(piece-bg:$style(color,$which,texture))
				image create photo $img -width 16 -height 16
				::scidb::tk::image copy $texture($color) $img -from 0 0 32 32
				set n [lsearch -exact $RecentTextures($which) $img]
				if {$n == -1} {
					catch { image delete photo_Texture(piece-bg:[lindex $RecentTextures($which) end]) }
					set n end
				}
				set RecentTextures($which) [linsert [lreplace $RecentTextures($which) $n $n] 0 $img]
			}

			ConfigurePieceFrame $which
		}

		default {
			if {[llength $selection]} {
				if {$var eq "fill"} { set useGradient false }
				set n [string first ":" $selection]

				if {$n == -1} {
					if {[llength $style($component,$which,$var)]} {
						set RecentColors($which) \
							[addToList $RecentColors($which) $style($component,$which,$var)]
					}
					set RecentColors($which) [addToList $RecentColors($which) $selection]
					if {$var eq "fill"} { SetTexture $which {} }
					set style($component,$which,$var) $selection
				} else {
					SetTexture $which [string range $selection [expr {$n + 1}] end-1]
					set style(color,$which,fill) {}
				}
			}
		}
	}

	set style(gradient,$which,use) $useGradient

	if {	[isOutline] 
		&& ($var eq "fill" || $var eq "stroke")
		&& $style($component,$which,$var) == [DefaultColor $var $which]} {

		set style($component,$which,$var) ""
	}

	Update $which
}


proc DefaultColor {type which} {
	variable style

	set useWhite [expr {$which eq "w" || ([isOutline] && $style(useWhitePiece))}]

	switch -exact -- $type {
		fill		{ return [expr {$useWhite ? "#ffffff" : "#000000"}] }
		stroke	{ return [expr {$useWhite ? "#000000" : "#ffffff"}] }
	}
	
	return "#ffffff"
}


proc MakePreview {var which path} {
	variable [namespace parent]::designSize
	variable style
	variable Piece
	variable SquareStyle
	variable Vars

	if {$var eq "fill" && $style(gradient,$which,use)} {
		set style(gradient,$which,use) false
		Update $which
	}

	set f [ttk::labelframe $path.lf -labelwidget [ttk::label $path.llf -textvar ::mc::Preview]]
	set canv [canvas $f.piece \
					-width $designSize \
					-height $designSize \
					-borderwidth 2 \
					-relief sunken]
	pack $f -expand yes -fill both
	grid $canv -row 1 -column 1
	grid columnconfigure $f {0 2} -minsize 5 -weight 1
	grid rowconfigure $f {0 3} -minsize 5

	$canv create image 2 2 -image photo_Square($SquareStyle($which),config) -anchor nw
	$canv create image 2 2 -image photo_Piece($which$Piece,$designSize) -anchor nw

	set clearTexture	[expr {$var eq "fill" && [llength $style(color,$which,texture)] > 0}]
	set setDfltColor	[expr {$var eq "fill" && ![isOutline] && [llength $style(color,$which,fill)] == 0}]

	bind $canv <<ChooseColorSelected>> "
		set [namespace current]::style(color,$which,$var) %d
		set [namespace current]::style(gradient,$which,$var) %d
		[namespace current]::Update $which
	"
	bind $canv <<ChooseColorReset>> "
		set [namespace current]::style(color,$which,$var) %d
		if {$clearTexture} {
			set [namespace current]::style(color,$which,texture) {$style(color,$which,texture)}
		}
		if {$setDfltColor} { set [namespace current]::style(color,$which,fill) {} }
	"

	if {$clearTexture} { set style(color,$which,texture) {} }
	if {$setDfltColor} { set style(color,$which,fill) [DefaultColor fill $which] }

	if {$clearTexture || $setDfltColor} { Update $which }

	return $canv
}


proc Clip {val min max} {
	if {$val < $min} { return $min }
	if {$val > $max} { return $max }
	return $val
}


proc DrawGradient {which} {
	variable style
	variable Constant

	set x1 $style(gradient,$which,x1)
	set y1 $style(gradient,$which,y1)
	set x2 $style(gradient,$which,x2)
	set y2 $style(gradient,$which,y2)

	set svg [string map [list \
				\#x1#				$style(gradient,$which,x1) \
				\#y1#				$style(gradient,$which,y1) \
				\#x2#				$style(gradient,$which,x2) \
				\#y2#				$style(gradient,$which,y2) \
				\#start-color#	$style(gradient,$which,start) \
				\#stop-color#	$style(gradient,$which,stop) \
				\#start-offs#	[computeStartOffset $x1 $y1 $x2 $y2] \
				\#stop-offs#	[computeStopOffset $x1 $y1 $x2 $y2] \
			] $Constant(svgPattern)]
	::scidb::tk::image create svg photo_Gradient
}


proc RefreshGradient {which self canv x y rad min max} {
	variable style

	# TODO: the current algorithm is dissatisfying
	set ax [Clip $x $min $max]
	set ay [Clip $y $min $max]

	$canv coords r$self $ax $ay
	$canv coords c$self $ax $ay

	set n [expr {$self eq "start" ? 1 : 2}]
	set x [expr {double($ax - $min)/double($max - $min)}]
	set y [expr {double($ay - $min)/double($max - $min)}]

	set style(gradient,$which,x$n) $x
	set style(gradient,$which,y$n) $y

	DrawGradient $which
	Update $which
}


proc RecolorHandle {canv type which} {
	variable style
	variable Widget

	::scidb::tk::image recolor $style(gradient,$which,$type) photo_Circle($type)
	scan $style(gradient,$which,$type) "\#%2x%2x%2x" r g b
	set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
	::scidb::tk::image recolor [expr {$luma < 128 ? "white" : "black"}] photo_Ring($type)
	$canv raise c$type
	$canv raise r$type

	photo_Knob($type) copy photo_Circle($type)
	photo_Knob($type) copy $::icon::15x15::ringBW
	# this trick forces update of the image
	$Widget(gradient,$type) configure -state normal
}


proc Offset {which var} {
	variable [namespace parent]::designSize
	variable style
	variable Offset

	set offs [expr {double($Offset($which,$var))/double($designSize)}]

	if {$offs != $style(gradient,$which,$var)} {
		set style(gradient,$which,$var) $offs
		Update $which
	}
}


proc SelectGradientColor {which type} {
	variable style
	variable Widget

	SelectColor $Widget(gradient,$type) $type gradient $which false

	if {[llength $style(gradient,$which,$type)]} {
		DrawGradient $which
		RecolorHandle $Widget(gradient,preview) $type $which
		Update $which
		# this trick forces update of the image
		$Widget(gradient,$type) configure -state normal
	}
}


proc RestoreGradient {which} {
	variable style
	variable __style

	SetTexture $which $__style(color,$which,texture)
	array set style [array get __style]
	Update $which
}


proc SelectGradient {which} {
	variable [namespace parent]::designSize
	variable style
	variable __style
	variable Offset
	variable Widget
	variable RecentColors
	variable Vars

	incr Vars(open)

	set dia 15
	set rad [expr $dia/2]
	set csize [expr {$designSize + $dia}]
	set min [expr {$rad + 1}]
	set max [expr {$min + $designSize - 2}]
	set photoSize [expr {$designSize + 2}]

	set Offset($which,tx) [expr {$style(gradient,$which,tx)*$designSize}]
	set Offset($which,ty) [expr {$style(gradient,$which,ty)*$designSize}]

	array set __style [array get style]
	set style(color,$which,fill) {}
	SetTexture $which {}

	image create photo photo_Ring(start) -width $dia -height $dia
	image create photo photo_Ring(stop) -width $dia -height $dia
	image create photo photo_Circle(start) -width $dia -height $dia
	image create photo photo_Circle(stop) -width $dia -height $dia
	image create photo photo_Knob(start) -width $dia -height $dia
	image create photo photo_Knob(stop) -width $dia -height $dia
	photo_Ring(start) copy $::icon::15x15::ring
	photo_Ring(stop) copy $::icon::15x15::ring
	photo_Circle(start) copy $::icon::15x15::circle
	photo_Circle(stop) copy $::icon::15x15::circle

	set dlg [toplevel .selectgradient -class Scidb]
	bind $dlg <Destroy> "
		if {{%W} eq {$dlg}} {
			incr [namespace current]::Vars(open) -1
			image delete photo_Ring(start)
			image delete photo_Ring(stop)
			image delete photo_Circle(start)
			image delete photo_Circle(stop)
			image delete photo_Knob(start)
			image delete photo_Knob(stop)
		}"
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	set grad [ttk::frame $top.grad]
	pack $grad -padx $::theme::padx -pady $::theme::pady

	set Widget(gradient,preview) [ \
		canvas $grad.preview \
			-width $csize \
			-height $csize \
			-borderwidth 2 \
			-relief groove]
	$grad.preview xview moveto 0
	$grad.preview yview moveto 0
	$grad.preview create rectangle\
		[expr {$min - 1}] [expr {$min - 1}] [expr {$max + 1}] [expr {$max + 1}] \
		-width 1 -outline black
	$grad.preview create image $min $min -anchor nw -image photo_Gradient
	$grad.preview create image $min $min -image photo_Circle(start) -tag cstart
	$grad.preview create image $min $min -image photo_Ring(start) -tag rstart
	$grad.preview create image $max $max -image photo_Circle(stop) -tag cstop
	$grad.preview create image $max $max -image photo_Ring(stop) -tag rstop

	set Widget(gradient,start) [ \
		ttk::button $grad.startcolor \
			-textvar [namespace current]::mc::Start \
			-image photo_Knob(start) \
			-compound left \
			-command [namespace code [list SelectGradientColor $which start]]]
	set Widget(gradient,stop) [ \
		ttk::button $grad.stopcolor \
			-textvar [namespace current]::mc::Stop \
			-image photo_Knob(stop) \
			-compound left \
			-command [namespace code [list SelectGradientColor $which stop]]]

	$grad.preview bind rstart <B1-Motion> \
		[namespace code [list RefreshGradient $which start $grad.preview %x %y $rad $min $max]]
	$grad.preview bind rstop  <B1-Motion> \
		[namespace code [list RefreshGradient $which stop $grad.preview %x %y $rad $min $max]]

	grid $grad.preview -row 0
	grid $grad.startcolor -row 2 -sticky we
	grid $grad.stopcolor -row 4 -sticky we
	grid rowconfigure $grad 1 -minsize $::theme::pady

	if {[isOutline] && ($which eq "w" || $style(useWhitePiece))} {
		set offs [ttk::frame $top.offset]
		pack [ttk::separator $top.sep] -fill x
		pack $offs -padx $::theme::padx -pady $::theme::pady

		ttk::label $offs.lhorz -textvar [namespace current]::mc::HorzOffset
		ttk::label $offs.lvert -textvar [namespace current]::mc::VertOffset
		foreach {dir var} {horz tx vert ty} {
			::ttk::spinbox $offs.$dir \
				-from -40 \
				-to 40 \
				-width 3 \
				-textvar [namespace current]::Offset($which,$var) \
				-justify right \
				-exportselection false \
				-command [namespace code [list Offset $which $var]] \
				;
			::validate::spinboxInt $offs.$dir
			::theme::configureSpinbox $offs.$dir
			bind $offs.$dir <FocusOut> +[namespace code [list Offset $which $var]]
		}

		grid $offs.lhorz -row 1 -column 0 -sticky w
		grid $offs.lvert -row 3 -column 0 -sticky w
		grid $offs.horz -row 1 -column 3 -sticky e
		grid $offs.vert -row 3 -column 3 -sticky e
		grid rowconfigure $offs 2 -minsize $::theme::pady
		grid columnconfigure $offs 1 -minsize $::theme::padx
	}

	widget::dialogButtons $dlg {ok cancel} ok false
	$dlg.ok configure -command [list destroy $dlg]
	$dlg.cancel configure -command "
		[namespace current]::RestoreGradient $which
		destroy $dlg"

	if {$style(gradient,$which,start) eq ""} {
		if {$which eq "w"} {
			set style(gradient,w,start) #ffffff
			set style(gradient,w,stop) #b2b2b2
		} else {
			set style(gradient,b,start) #b2b2b2
			set style(gradient,b,stop) #000000
		}
	}
	set style(gradient,$which,use) true

	foreach {t i} {start 1 stop 2} {
		set x [expr {$style(gradient,$which,x$i)*($max - $min) + $min}]
		set y [expr {$style(gradient,$which,y$i)*($max - $min) + $min}]
		$grad.preview coords r$t $x $y
		$grad.preview coords c$t $x $y
	}

	DrawGradient $which
	Update $which
	RecolorHandle $grad.preview start $which
	RecolorHandle $grad.preview stop $which

	wm transient $dlg [winfo toplevel $Widget(dialog)]
	wm iconname $dlg ""
	wm title $dlg $::scidb::app
	wm protocol $dlg WM_DELETE_WINDOW "if {!\[::dialog::choosecolor::isOpen\]} { destroy $dlg }"
	wm withdraw $dlg
	util::place $dlg right $Widget(piece,$which) true
	wm resizable $dlg false false
	wm deiconify $dlg
	ttk::grabWindow $dlg
	focus $grad.startcolor
	tkwait window $dlg
	ttk::releaseGrab $dlg

	if {$style(gradient,$which,use)} {
		if {[llength $style(color,$which,fill)]} {
			set RecentColors($which) [addToList $RecentColors($which) $style(color,$which,fill)]
			set style(color,$which,fill) {}
		}
		set style(color,$which,texture) {}
	}

	ConfigurePieceFrame $which
	update
}


proc SetPiece {piece} {
	variable [namespace parent]::designSize
	variable Piece
	variable Widget

	set Piece $piece
	Update
	$Widget(piece,w) delete piece
	$Widget(piece,b) delete piece
	$Widget(piece,w) create image 0 0 \
		-image photo_Piece(w$Piece,$designSize) \
		-anchor nw \
		-tag piece
	$Widget(piece,b) create image 0 0 \
		-image photo_Piece(b$Piece,$designSize) \
		-anchor nw \
		-tag piece
}


proc notifySquareChanged {} {
	variable Widget
	if {[info exists Widget(dialog)]} { MakeSquare }
}


proc notifyPieceSetChanged {} {
	variable Widget
	variable Piece

	if {[info exists Widget(dialog)]} { SetPiece $Piece }
}


proc MakeSquare {{layout ""}} {
	variable [namespace parent]::designSize
	variable Layout

	if {[llength $layout]} { set Layout $layout }

	switch $Layout {
		ll {
			photo_Square(lite,config) copy photo_Square(lite,$designSize)
			photo_Square(dark,config) copy photo_Square(lite,$designSize)
		}

		ld {
			photo_Square(lite,config) copy photo_Square(lite,$designSize)
			photo_Square(dark,config) copy photo_Square(dark,$designSize)
		}

		ldld {
			set m [expr {$designSize/2}]
			photo_Square(lite,config) copy photo_Square(lite,$designSize) \
				-from 0 0 $m $designSize -to 0 0
			photo_Square(lite,config) copy photo_Square(dark,$designSize) \
				-from $m 0 $designSize $designSize -to $m 0
			photo_Square(dark,config) copy photo_Square(lite,config)
		}

		dd {
			photo_Square(lite,config) copy photo_Square(dark,$designSize)
			photo_Square(dark,config) copy photo_Square(dark,$designSize)
		}

		dl {
			photo_Square(lite,config) copy photo_Square(dark,$designSize)
			photo_Square(dark,config) copy photo_Square(lite,$designSize)
		}

		dldl {
			set m [expr {$designSize/2}]
			photo_Square(lite,config) copy photo_Square(dark,$designSize) \
				-from 0 0 $m $designSize -to 0 0
			photo_Square(lite,config) copy photo_Square(lite,$designSize) \
				-from $m 0 $designSize $designSize -to $m 0
			photo_Square(dark,config) copy photo_Square(lite,config)
		}
	}
}


proc RecolorButton {var which} {
	variable [namespace parent]::texture
	variable style
	variable Widget

	if {[llength $style(color,$which,$var)]} {
		photo_Circle($var,$which) copy $::icon::15x15::circle
		::scidb::tk::image recolor $style(color,$which,$var) photo_Circle($var,$which)
		photo_Circle($var,$which) copy $::icon::15x15::ringBW
	} elseif {$var eq "fill" && [llength $style(color,$which,texture)]} {
		set color [expr {$which eq "w" ? "white" : "black"}]
		photo_Circle(fill,$which) copy $::icon::15x15::circle
		::scidb::tk::image copy $texture($color) photo_Circle(fill,$which) -from 0 0 30 30 -alphamask
		photo_Circle(fill,$which) copy $::icon::15x15::ringBW
	} else {
		::scidb::tk::image recolor #00000000 photo_Circle($var,$which)
	}
	# this trick forces update of the image
	$Widget($var,$which) configure -state normal
}


proc FillOrStroke {which fill} {
	variable Widget

	SelectColor \
		$Widget($fill,$which) \
		$fill \
		color \
		$which \
		[expr {[$Widget($fill,erase,$which) cget -state] eq "normal"}]
	ConfigurePieceFrame $which
	Update $which
}


proc Erase {which fill} {
	variable style
	variable Widget
	variable RecentColors

	if {[llength $style(color,$which,$fill)]} {
		set RecentColors($which) [addToList $RecentColors($which) $style(color,$which,$fill)]
	}
	set style(color,$which,$fill) {}
	$Widget($fill,erase,$which) configure -state disabled
	if {$fill eq "fill"} { SetTexture $which {} }
	RecolorButton $fill $which
	Update $which
}


proc UseWhite {} {
	variable style

	if {[isOutline]} {
		set tmp $style(color,b,fill)
		set style(color,b,fill) $style(color,b,stroke)
		set style(color,b,stroke) $tmp
	}

	if {!$style(useWhitePiece)} {
		SetTexture b {}
	}

	ConfigurePieceFrame b
	Update b
}


proc ConfigurePieceFrame {which} {
	variable style
	variable Widget

	if {[llength $style(color,$which,fill)]} {
		$Widget(fill,erase,$which) configure -state normal
		$Widget(fill,$which) configure -state normal
	} else {
		$Widget(fill,erase,$which) configure -state disabled
		$Widget(fill,$which) configure -state disabled
	}

	if {[llength $style(color,$which,stroke)]} {
		$Widget(stroke,erase,$which) configure -state normal
	} else {
		$Widget(stroke,erase,$which) configure -state disabled
	}

	if {$style(gradient,$which,use)} {
		$Widget(gradient,erase,$which) configure -state normal
	} else {
		$Widget(gradient,erase,$which) configure -state disabled
	}

	if {[llength $style(color,$which,texture)]} {
		$Widget(fill,erase,$which) configure -state normal
	}

	RecolorButton fill $which
	RecolorButton stroke $which
	RecolorButton contour $which
}


proc MakePieceFrame {f which} {
	variable [namespace parent]::designSize
	variable style
	variable SquareStyle
	variable Piece
	variable Widget

	ttk::frame $f.piece -borderwidth 2 -relief groove
	set Widget(piece,$which) [canvas $f.piece.c -width $designSize -height $designSize]
	pack $f.piece.c -expand yes -fill both
	$f.piece.c create image 0 0 -image photo_Square($SquareStyle($which),config) -anchor nw
	$f.piece.c create image 0 0 \
		-image photo_Piece($which$Piece,$designSize) \
		-anchor nw \
		-tag piece

	foreach type {fill stroke contour gradient} {
		image create photo photo_Circle($type,$which) -width 15 -height 15
	}
	bind $f.piece.c <Destroy> "
		foreach type {fill stroke contour gradient} { image delete photo_Circle(\$type,$which) }
	"

	set Widget(fill,$which) [ \
		ttk::button $f.fill \
			-style aligned.TButton \
			-textvar [namespace current]::mc::Fill \
			-image photo_Circle(fill,$which) \
			-compound left \
			-command [namespace code [list FillOrStroke $which fill]]]
	set Widget(fill,erase,$which) [ \
		ttk::button $f.fill_erase \
			-image [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser] \
			-command [namespace code [list Erase $which fill]]]
	set Widget(stroke,$which) [ \
		ttk::button $f.stroke -textvar [namespace current]::mc::Stroke \
			-style aligned.TButton \
			-image photo_Circle(stroke,$which) \
			-compound left \
			-command [namespace code [list FillOrStroke $which stroke]]]
	set Widget(stroke,erase,$which) [ \
		ttk::button $f.stroke_erase \
			-image [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser] \
			-command [namespace code [list Erase $which stroke]]]
	ttk::button $f.gradient \
		-style aligned.TButton \
		-image photo_Circle(gradient,$which) \
		-compound left \
		-textvar [::mc::var [namespace current]::mc::Gradient ...] \
		-command [namespace code [list SelectGradient $which]]
	set Widget(gradient,erase,$which) [ \
		ttk::button $f.gradient_erase \
			-image [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser] \
			-command "
				set [namespace current]::style(gradient,$which,use) false
				$f.gradient_erase configure -state disabled
				[namespace current]::Update $which
			"]
	set Widget(contour,$which) [ \
		ttk::button $f.contour \
			-style aligned.TButton \
			-textvar [namespace current]::mc::Contour \
			-image photo_Circle(contour,$which) \
			-compound left \
			-command "
				[namespace current]::SelectColor $f.contour contour color $which false
				[namespace current]::RecolorButton contour $which
			"]
	
	ConfigurePieceFrame $which

	grid $f.piece          -row 1 -column 1 -rowspan 9
	grid $f.fill           -row 1 -column 3 -sticky wens
	grid $f.fill_erase     -row 1 -column 5 -sticky wens
	grid $f.stroke         -row 3 -column 3 -sticky wens
	grid $f.stroke_erase   -row 3 -column 5 -sticky wens
	grid $f.gradient       -row 5 -column 3 -sticky wens
	grid $f.gradient_erase -row 5 -column 5 -sticky wens
	grid $f.contour        -row 7 -column 3 -sticky wens

	grid rowconfigure $f {0 2 4 6 8} -minsize $::theme::pady
	grid columnconfigure $f {0 2 6} -minsize $::theme::padx
	grid rowconfigure $f 8 -weight 1

	if {$which eq "b"} {
		ttk::checkbutton $f.useWhite \
			-textvar [namespace current]::mc::WhiteShape \
			-variable [namespace current]::style(useWhitePiece) \
			-command [namespace code { UseWhite }]
		grid $f.useWhite -row 9 -column 3 -sticky we
		grid rowconfigure $f $::theme::padY -minsize $::theme::pady
	}
}


proc Option {opt} {
	if {$opt eq ""} { return "{}" }
	return $opt
}


proc Reset {{update false}} {
	variable Offset
	variable Style
	variable style
	variable _Offset
	variable _Style
	variable _style

	SetTexture w $_style(color,w,texture)
	SetTexture b $_style(color,b,texture)
	array set Offset [array get _Offset]
	array set style [array get _style]
	array set Style [array get _Style]

	if {$update} {
		ConfigurePieceFrame w
		ConfigurePieceFrame b
		Update
	}
}


proc MakePieces {size} {
	set [namespace parent]::needRefresh(piece,$size) true
	set [namespace parent]::needRefresh(white,$size) true
	set [namespace parent]::needRefresh(black,$size) true
	setupPieces $size
}


proc DestroyDialog {dlg size resetCmd} {
	variable Vars

	if {$Vars(open)} { return }

	if {[dialog::question \
			-parent $dlg \
			-title $::scidb::app \
			-message [set [namespace current]::mc::CloseDialog]] eq "yes"} {
		Reset
		MakePieces $size
		$resetCmd
		destroy $dlg
	}
}


proc openConfigDialog {parent size closeCmd updateCmd resetCmd} {
	variable [namespace parent]::designSize
	variable style
	variable Constant
	variable Vars
	variable Widget
	variable Offset
	variable Style
	variable _style
	variable _Offset
	variable _Style

	# setup
	set Vars(open)			0
	set Style(contour)	[expr {int(round($style(contour)*0.5*$Constant(contourMaxTick)))}]
	set Style(shadow)		[expr {int(round($style(shadow)*$designSize))}]
	set Style(opacity)	[expr {int(round($style(opacity)*255))}]
	set Style(zoom)		[expr {int(round($style(zoom)*100))}]

	array set _style [array get style]
	array set _Style [array get Style]
	array set _Offset [array get Offset]

	[namespace parent]::registerSize $designSize
	[namespace parent]::setupSquares $designSize
	[namespace parent]::refreshTexture white $designSize
	[namespace parent]::refreshTexture black $designSize
	Update

	image create photo photo_Square(lite,config) -width $designSize -height $designSize
	image create photo photo_Square(dark,config) -width $designSize -height $designSize
	image create photo photo_Gradient -width $designSize -height $designSize

	# toplevel
	set point [expr {$parent eq "." ? "" : "."}]
	set dlg [toplevel ${parent}${point}configPieces -class Scidb]
	set Widget(dialog) $dlg
	bind $dlg <Escape> [namespace code [list DestroyDialog $dlg $size $resetCmd]]
	bind $dlg <Destroy> [namespace code {
		if {"%W" eq $Widget(dialog)} {
			[namespace parent]::unregisterSize [set [namespace parent]::designSize]
			image delete photo_Square(lite,config)
			image delete photo_Square(dark,config)
			image delete photo_Gradient
			array unset Widget
		}
	}]
	bind $dlg <Destroy> "+ if {{%W} eq {$dlg}} { $closeCmd }"

	# toolbars
	set tb1 [::toolbar::toolbar $dlg -tooltipvar [namespace current]::mc::PieceSelection]
	set tb2 [::toolbar::toolbar $dlg -tooltipvar [namespace current]::mc::BackgroundSelection]

	foreach piece {k q r b n p} {
		::toolbar::add $tb1 button \
			-image $::icon::toolbarPiece($piece) \
			-command [namespace code [list SetPiece $piece]] \
			-variable [namespace current]::Piece \
			-value $piece
	}

	foreach layout {ll ld dd dl ldld dldl} {
		::toolbar::add $tb2 button \
			-image [list \
						$icon::22x22::SquareLayout($layout) \
						$icon::16x16::SquareLayout($layout) \
						$icon::32x32::SquareLayout($layout)] \
			-command [namespace code [list MakeSquare $layout]] \
			-variable [namespace current]::Layout \
			-value $layout
	}

	# toplevel frame
	set f [ttk::frame $dlg.f -padding $::theme::padding]

	# left, mid, and right frame
	pack $f
	set top [ttk::frame $f.top]
	set bot [ttk::frame $f.bot]
	pack $top -side top -fill both -expand yes
	pack $bot -side top -fill both -expand yes

	set lt [ttk::labelframe $f.top.lt -labelwidget [ttk::label $f.top.llt -textvar ::mc::White]]
	set rt [ttk::labelframe $f.top.rt -labelwidget [ttk::label $f.top.lrt -textvar ::mc::Black]]
	pack $lt -side left -fill both -expand yes
	pack $rt -side left -fill both -expand yes

	MakeSquare
	MakePieceFrame $lt w
	MakePieceFrame $rt b

	foreach side {lt rt} {
		set $side [ttk::frame $bot.$side]
#		pack [set $side] -side left -fill x -expand yes
	}
	grid $lt -row 1 -column 1 -sticky ewns
	grid $rt -row 1 -column 3 -sticky ewns
	grid columnconfigure $bot {1 3} -weight 1

	foreach {name var side row min max} [list \
													Zoom zoom lt 1 75 125 \
													Contour contour lt 3 0 $Constant(contourMaxTick) \
													Shadow shadow rt 1 0 $Constant(shadowMaxTick) \
													Opacity opacity rt 3 0 255 \
												] {
		scale $bot.$side.s$var \
			-from $min \
			-to $max \
			-bigincrement 10 \
			-orient horizontal \
			-width $::theme::sliderWidth \
			-takefocus 1 \
			-command [namespace current]::CallUpdate \
			-variable [namespace current]::Style($var)
		ttk::label $bot.$side.l$var -textvar [namespace current]::mc::$name
		grid $bot.$side.l$var -row $row -column 1 -sticky sw
		grid $bot.$side.s$var -row $row -column 3 -sticky we
	}

	set f [ttk::labelframe $bot.diffusion \
		-labelwidget [ttk::label $bot.label -textvar [namespace current]::mc::ShadowDiffusion]]
	grid $f -row 3 -column 1 -sticky w -columnspan 3 -sticky ew
	foreach value {none linear quadratic} {
		set var [namespace current]::mc::[string toupper $value 0 0]
		ttk::radiobutton $f.$value \
			-textvar $var \
			-value $value \
			-takefocus 1 \
			-command [namespace current]::CallUpdate \
			-variable [namespace current]::style(diffusion)
		pack $f.$value -side left -padx $::theme::padx
	}

	foreach side {lt rt} {
		grid columnconfigure $bot.$side 3 -weight 1
		grid rowconfigure $bot.$side {0 2 4} -minsize $::theme::pady
	}
	grid rowconfigure $bot.rt 6 -minsize $::theme::pady
	grid columnconfigure $bot.lt {2 4} -minsize $::theme::padx
	grid columnconfigure $bot.rt {0 2} -minsize $::theme::padx

	# dialog buttons
	widget::dialogButtons $dlg {ok cancel apply reset} apply
	$dlg.ok configure -command "
		[namespace current]::MakePieces $size
		$updateCmd true
		destroy $dlg"
	$dlg.cancel configure -command "
		[namespace current]::Reset
		[namespace current]::MakePieces $size
		$resetCmd
		destroy $dlg"
	$dlg.apply configure -command "
		[namespace current]::MakePieces $size
		$updateCmd"
	$dlg.reset configure -command "
		[namespace current]::Reset true
		[namespace current]::MakePieces $size
		$resetCmd"
	
	# display dialog
	wm resizable $dlg 0 0
	wm withdraw $dlg
	wm title $dlg "$::scidb::app: [set [namespace current]::mc::PieceStyleConf]"
	util::place $dlg center $parent
#	wm transient $dlg [winfo toplevel $parent]
	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list DestroyDialog $dlg $size $resetCmd]]
	wm deiconify $dlg

#	ttk::grabWindow $dlg
	catch { focus $dlg.f.top.lt.fill }
#	tkwait window $dlg
#	ttk::releaseGrab $dlg
}


proc WriteOptions {chan} {
	variable RecentColors
	variable RecentTextures

	::options::writeItem $chan [namespace current]::Piece
	::options::writeItem $chan [namespace current]::Layout
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 16x16 {

set SquareLayout(ll) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAALUlEQVQoz2Nk+M+ADBgZGFBF
	WJD5jFAaWYSJgQAYVTB4FLAg4pABI1YZGBgYAPWlBCVWgnioAAAAAElFTkSuQmCC
}]

set SquareLayout(ld) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAJ0lEQVQoz2Nk+M+ADBgZGFBF
	WJD5jAyYgImBABhVMHgUsGCPQwQAABuUAyQ0bUDCAAAAAElFTkSuQmCC
}]

set SquareLayout(ldld) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAALklEQVQoz2Nk+M+ADBgZGFBF
	WGB8RiRBZBEmBgJgECr4T3srGAdlOLBgcxiyCAAPaAUl3pFjmgAAAABJRU5ErkJggg==
}]

set SquareLayout(dd) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAG0lEQVQoz2Nk+M+ADBgZGFBF
	mBgIgFEFw0kBACtCAh/AmCruAAAAAElFTkSuQmCC
}]

set SquareLayout(dl) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAKElEQVQoz2Nk+M+ADBgZGFBF
	WBiwgP9I6pkYCIBRBYNHAdbYZERiAwAJggMkhmihYgAAAABJRU5ErkJggg==
}]

set SquareLayout(dldl) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAANklEQVQoz2Nk+M+ADBgZGFBF
	WCDUf6jsfwZGBlQRJgYCAE0BIyEFDKMKqKTgP4YCFlxxABMBAAI7BiWoI6mVAAAAAElFTkSu
	QmCC
}]

} ;# namespace 16x16

namespace eval 22x22 {

set SquareLayout(ll) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAQAAABuvaSwAAAAJUlEQVQoz2Ng+I8FggBW8f/o
	AKYYm/io4lHFtFP8f8S6mfgMCwB61fclW2cANAAAAABJRU5ErkJggg==
}]

set SquareLayout(ld) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAQAAABuvaSwAAAAIUlEQVQoz2Ng+I8FggBW8f/o
	YFTxqOKBUfx/xLqZ+AwLAGdiV8UClvf8AAAAAElFTkSuQmCC
}]

set SquareLayout(ldld) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAQAAABuvaSwAAAANklEQVQoz2Nk+M+ACRiB+D82
	4f//kVQgK8YUH1VMXcX/gUzG4ayYxKD7TzOTaaeYOm4mPsMCAPFLWwFkJuztAAAAAElFTkSu
	QmCC
}]

set SquareLayout(dd) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAQAAABuvaSwAAAAHElEQVQoz2Nk+M+ACRiB+D82
	4VHFo4pHFQ8ZxQCTbCwB+nvxCwAAAABJRU5ErkJggg==
}]

set SquareLayout(dl) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAQAAABuvaSwAAAAJ0lEQVQoz2Ng+I8JQQQ2cQbc
	itHB4FbMAALD2c0jQPH/UTejKcaEAODGZ7Wd7B16AAAAAElFTkSuQmCC
}]

set SquareLayout(dldl) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAQAAABuvaSwAAAAOklEQVQoz2Nk+M+ACRiB+D82
	Ybjgf4QQUDEjFvHBrBjVg9RV/H9wOGPYKx564fyfkZGqHkQA1MSPAAC6oV0BoBFYIwAAAABJ
	RU5ErkJggg==
}]

} ;# namespace 22x22

namespace eval 32x32 {

set SquareLayout(ll) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAN0lEQVRIx2Nk+M+ADzAC8X/8
	CqhhwH+cemEG4FYxasCoAaMGjBowagA9DfgPQgNqwEiJhQGtnQHaHHoBbZAUGQAAAABJRU5E
	rkJggg==
}]

set SquareLayout(ld) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAM0lEQVRIx2Nk+M+ADzAC8X/8
	CqhhwH+cekcNGDVg1IBRA0YNGFwG/AehATVgpMTCgNbOAMvlXgGe+uK/AAAAAElFTkSuQmCC
}]

set SquareLayout(ldld) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAP0lEQVRIx2Nk+M+ADzAC8X/8
	CqhhwH8U9dgM+I8mNGrAqAEjzYD/QAHGUQMG2IDRlMgADkHGATZgpMTCgNbOAMDFgAGfM8Ek
	AAAAAElFTkSuQmCC
}]

set SquareLayout(dd) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAJklEQVRIx2Ng+I8HvmMAgXd4
	1YwaMGrAqAGjBowaMGrAqAHDzQAAjqa4LqQ10H8AAAAASUVORK5CYII=
}]

set SquareLayout(dl) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAALUlEQVRIx2Nk+M+ADzAyMOBX
	wUgnA/7jlBw1YNSAUQNGDRg1YNSAkWkADWtnAIaAXAE7tvC3AAAAAElFTkSuQmCC
}]

set SquareLayout(dldl) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAAQElEQVRIx2Ng+I8XggABFdQ1
	ABmA+VisQFUxagBBA7DFwqgBQ9CA/wNuwGgsjBowTFLiwBfrJHoBQzGltTNhFQBLAwRDQX6+
	WQAAAABJRU5ErkJggg==
}]

} ;# namespace 32x32
} ;# namespace icon
} ;# namespace piece
} ;# namespace board

# vi:set ts=3 sw=3:
