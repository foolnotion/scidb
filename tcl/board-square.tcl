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

::util::source board-squares-dialog

namespace eval board {
namespace eval square {
namespace eval mc {

set SolidColor				"Solid Color"
set CannotReadFile		"Cannot read file"
set Zoom						"Zoom"
set Offset					"Offset"
set Rotate					"Rotate"
set Borderline				"Borderline"
set Width					"Width"
set Opacity					"Opacity"
set GapBetweenSquares	"Gap between squares"
set Highlighting			"Highlighting"
set Selected				"Selected"
set SuggestedMove			"Suggested move"
set Show						"Preview"
set SquareStyleConf		"Square Style Configuration"
set CloseDialog			"Close dialog and throw away changes?"

} ;# namespace mc

namespace import [namespace parent]::texture::openBrowser
namespace import [namespace parent]::texture::getTexture
namespace import [namespace parent]::texture::makePopup
namespace import [namespace parent]::texture::popup
namespace import [namespace parent]::texture::popdown
namespace import [namespace parent]::loadTexture
namespace import [namespace parent]::setupSquares
namespace import [namespace parent]::loadImage
namespace import [namespace parent]::registerSize
namespace import [namespace parent]::unregisterSize
namespace import ::dialog::choosecolor::addToList
namespace import ::dialog::choosecolor::extendColorName
namespace import ::tcl::mathfunc::*

variable Widget
variable Vars

array set RecentColors {
	lite		{ {} {} {} {} {} {} {} {} {} {} {} {} }
	dark		{ {} {} {} {} {} {} {} {} {} {} {} {} }
	hilite	{ {} {} {} {} {} {} {} {} {} {} {} {} }
}


proc SetTooltip {which} {
	variable style
	variable Widget

	if {[llength $style($which,texture)] == 0} {
		set tip "${mc::SolidColor}: [extendColorName $style($which,solid)]"
	} else {
		set tip "${::mc::Texture}: [file join $which {*}$style($which,texture)]"
	}

	::tooltip::tooltip $Widget(texture,$which) $tip
}


proc MakeSquare {which} {
	variable [namespace parent]::needRefresh
	variable [namespace parent]::designSize

	set needRefresh($which,$designSize) true
	setupSquares $designSize
}


proc SelectSquareColor {which} {
	variable [namespace parent]::designSize
	variable style
	variable Widget
	variable Vars

	set initialcolor $style($which,solid)
	set oldcolor ""

	if {[llength $style($which,texture)] == 0} {
		set oldcolor $style($which,solid)
	}

	incr Vars(open)
	set selection [::colormenu::popup $Widget(solid,$which) \
							-class Dialog \
							-initialcolor $initialcolor \
							-oldcolor $oldcolor \
							-recentcolors [namespace current]::RecentColors($which) \
							-geometry last \
							-modal true \
							-place centeronparent]
	incr Vars(open) -1
	
	if {[llength $selection]} {
		if {[llength $style($which,solid)]} {
			addToList [namespace current]::RecentColors($which) $style($which,solid)
		}
		set style($which,solid) $selection
		set style($which,texture) {}
		loadTexture $which
		::scidb::tk::image recolor $selection photo_Square($which,$designSize) -composite set
		addToList [namespace current]::RecentColors($which) $selection
		ConfigureSquareFrame $which
		SetTooltip $which
	}
}


proc ShowCurrentTexture {which xc yc} {
	variable [namespace parent]::texture
	variable style
	variable Vars

	set w [makePopup]

	incr xc 5
	incr yc 5
	set x1 $style($which,x1)
	set y1 $style($which,y1)
	set x2 $style($which,x2)
	set y2 $style($which,y2)

	if {$style($which,rotation)} {
		set ht [image height $texture($which)]
		set wd [image width $texture($which)]
		if {$style($which,rotation) == 90 || $style($which,rotation) == 270} {
			set t $ht; set ht $wd; set wd $t
		}
		$w.texture configure -height $ht -width $wd
		set Vars(currentTexture) [image create photo -width $wd -height $ht]
		::scidb::tk::image copy $texture($which) $Vars(currentTexture) \
			-rotate [expr {$style($which,rotation)/90}]
		$w.texture itemconfigure img -image $Vars(currentTexture)
		set dx [expr {$x2 - $x1}]
		set dy [expr {$y2 - $y1}]
		lassign [RotateOffsets $which 0 $style($which,rotation) $x1 $y1] x1 y1
		set x2 [expr {$x1 + $dx}]
		set y2 [expr {$y1 + $dy}]
	} else {
		$w.texture configure \
			-height [image height $texture($which)] \
			-width [image width $texture($which)]
		$w.texture itemconfigure img -image $texture($which)
	}

	$w.texture itemconfigure view -state normal
	$w.texture coords dark $x1 $y1 $x2 $y2
	$w.texture coords lite [expr {$x1 + 1}] [expr {$y1 + 1}] [expr {$x2 - 1}] [expr {$y2 - 1}]
	popup $w $xc $yc
}


proc HideCurrentTexture {} {
	variable Vars

	catch {
		image delete $Vars(currentTexture)
		set Vars(currentTexture) {}
	}

	popdown
}


proc ConfigureSquareFrame {which} {
	variable [namespace parent]::texture
	variable [namespace parent]::designSize
	variable Widget
	variable Vars
	variable style

	set canv $Widget(texture,$which)

	if {[llength $texture($which)] == 0} {
		foreach what {zoom offsx offsy} { $Widget($what,$which) configure -state disabled }
		foreach deg {0 90 180 270} { $Widget($deg,$which) configure -state disabled }
		$canv configure -cursor {}
		bind $canv <ButtonPress-1>		{}
		bind $canv <ButtonRelease-1>	{}
		bind $canv <Button1-Motion>	{}
		bind $canv <ButtonPress-2>		{}
		bind $canv <ButtonPress-3>		{}
		bind $canv <ButtonRelease-2>	{}
		bind $canv <ButtonRelease-3>	{}
	} else {
		set iw [image width $texture($which)]
		set ih [image height $texture($which)]

		if {$style($which,rotation) == 90 || $style($which,rotation) == 270} {
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
			$canv configure -cursor fleur
			bind $canv <ButtonPress-1> "
				::tooltip::tooltip off
				set [namespace current]::Vars(position) {%X %Y}
				set [namespace current]::Vars(offset,$which,X) \$[namespace current]::Vars(offset,$which,x)
				set [namespace current]::Vars(offset,$which,Y) \$[namespace current]::Vars(offset,$which,y)
			"
			bind $canv <ButtonRelease-1>	[namespace code {
				::tooltip::tooltip on
				unset -nocomplain Vars(position)
			}]
			bind $canv <Button1-Motion>	[namespace code [list MoveSquare $which %X %Y]]
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
		bind $canv <Any-Button>			[namespace code { HideCurrentTexture }]
		bind $canv <ButtonPress-2>		[namespace code [list ShowCurrentTexture $which %X %Y]]
		bind $canv <ButtonPress-3>		[namespace code [list ShowCurrentTexture $which %X %Y]]
		bind $canv <ButtonRelease-2>	[namespace code { HideCurrentTexture }]
		bind $canv <ButtonRelease-3>	[namespace code { HideCurrentTexture }]
		set s [min $iw $ih]
		set f [expr {int(round(100.0*(double($designSize)/double($s))))}]
		if {$f >= 100} {
			$Widget(zoom,$which) configure -state disabled
		} else {
			$Widget(zoom,$which) configure -state normal -from $f
		}
		foreach deg {0 90 180 270} { $Widget($deg,$which) configure -state normal }
	}
}


proc Zoom {which} {
	variable [namespace parent]::texture
	variable [namespace parent]::designSize
	variable style
	variable Vars
	variable Widget

	set s  [expr {$Vars(zoom,$which)/100.0}]
	set iw [image width $texture($which)]
	set ih [image height $texture($which)]
	set is [min [expr {int(round($designSize/$s))}] $iw $ih]

	if {$is == $style($which,x2) - $style($which,x1)} { return }

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
	
	set x1 [max 0 [expr {($style($which,x1) + $style($which,x2) - $is)/2}]]
	set y1 [max 0 [expr {($style($which,y1) + $style($which,y2) - $is)/2}]]
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

	set style($which,x1) $x1
	set style($which,y1) $y1
	set style($which,x2) $x2
	set style($which,y2) $y2

	set offsx [expr {round(int($s*$x1))}]
	set offsy [expr {round(int($s*$y1))}]
	lassign \
		[RotateOffsets $which $Vars(rotation,$which) $Vars(rotation,$which) $offsx $offsy] \
		Vars(offset,$which,x) Vars(offset,$which,y)

	$Widget(texture,$which) configure -cursor [expr {$iw > $is || $ih > $is ? "fleur" : ""}]
	MakeSquare $which
}


proc ShiftSquare {which} {
	variable style
	variable Vars

	lassign \
		[RotateOffsets $which $Vars(rotation,$which) \
			-$Vars(rotation,$which) $Vars(offset,$which,x) $Vars(offset,$which,y)] \
		offsx offsy

	set x1 $style($which,x1)
	set y1 $style($which,y1)
	set s  [expr {100.0/$Vars(zoom,$which)}]

	set style($which,x1) [expr {int(round($s*$offsx))}]
	set style($which,y1) [expr {int(round($s*$offsy))}]

	if {$x1 != $style($which,x1) || $y1 != $style($which,y1)} {
		set style($which,x2) [expr {$style($which,x2) + $style($which,x1) - $x1}]
		set style($which,y2) [expr {$style($which,y2) + $style($which,y1) - $y1}]
		MakeSquare $which
	}
}


proc MoveSquare {which x y} {
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

	set s  [expr {100.0/$Vars(zoom,$which)}]
	set x1 [expr {$offsX + $tx}]
	set y1 [expr {$offsY + $ty}]
	set dx [expr {$style($which,x2) - $style($which,x1)}]
	set iw [image width $texture($which)]
	set ih [image height $texture($which)]

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
		ShiftSquare $which
	}
}


proc RotateOffsets {which currentRotation deg x y} {
	variable [namespace parent]::texture
	variable style
	variable Vars

	if {$deg < 0} { set deg [expr {360 + $deg}] }
	if {$deg == -0} { set deg 0 }

	set dx [expr {$style($which,x2) - $style($which,x1)}]

	if {$currentRotation == 90 || $currentRotation == 270} {
		set iw [image height $texture($which)]
		set ih [image width $texture($which)]
	} else {
		set iw [image width $texture($which)]
		set ih [image height $texture($which)]
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


proc RotateSquare {which} {
	variable style
	variable Widget
	variable Vars

	set deg [expr {$Vars(rotation,$which) - $style($which,rotation)}]
	if {$deg == 0} { return }
	if {$deg < 0} { set deg [expr {360 + $deg}] }

	lassign \
		[RotateOffsets $which $style($which,rotation) $deg $Vars(offset,$which,x) $Vars(offset,$which,y)] \
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
	set style($which,rotation) $Vars(rotation,$which)
	MakeSquare $which
	ConfigureSquareFrame $which
}


proc BrowserSelect {parent which chosen} {
	variable [namespace parent]::designSize
	variable style
	variable Vars

	set style($which,texture) $chosen
	set texture [loadTexture $which]

	if {[llength $style($which,solid)]} {
		addToList [namespace current]::RecentColors($which) $style($which,solid)
	}

	set w [min [image width photo_Square($which,$designSize)] [image width $texture]]
	set h [min [image height photo_Square($which,$designSize)] [image height $texture]]
	::scidb::tk::image copy $texture photo_Square($which,$designSize) -from 0 0 $w $h
	photo_Square($which,$designSize) copy photo_Borderline($designSize)

	set style($which,texture) $chosen
	set style($which,x1) 0
	set style($which,y1) 0
	set style($which,x2) $designSize
	set style($which,y2) $designSize
	set style($which,rotation) 0
	set Vars(zoom,$which) 100
	set Vars(offset,$which,x) 0
	set Vars(offset,$which,y) 0
	set Vars(rotation,$which) 0
	ConfigureSquareFrame $which
	SetTooltip $which
}


proc SelectTexture {parent which} {
	variable style
	variable Vars

	incr Vars(open)
	bind $parent <<BrowserSelect>> [namespace code [list BrowserSelect $parent $which %d]]
	set other [expr {$which eq "lite" ? "dark" : "lite"}]
	openBrowser $parent $which $style($which,texture) $style($other,texture) {} right
	bind $parent <<BrowserSelect>> {}
	incr Vars(open) -1
}


proc MakeSquareFrame {f which} {
	variable [namespace parent]::designSize
	variable style
	variable Vars
	variable Widget

	ttk::frame $f.texture -borderwidth 2 -relief groove
	set Widget(texture,$which) [tk::canvas $f.texture.c -width $designSize -height $designSize]
	pack $f.texture.c -expand yes -fill both
	$f.texture.c create rectangle 0 0 $designSize $designSize \
		-width 1 -outline [$f.texture.c cget -background]
	$f.texture.c create image 0 0 -image photo_Square($which,$designSize) -anchor nw
	$f.texture.c create rectangle 0 0 $designSize $designSize \
		-width 20 -outline $style(hilite,suggested) -state hidden -tag suggested
	$f.texture.c create rectangle \
		[expr {$designSize/4}] [expr {$designSize/4}] \
		[expr {$designSize - $designSize/4}] [expr {$designSize - $designSize/4}] \
		-width 0 -fill $style(hilite,selected) -state hidden -tag selected
	set state disabled

	set Widget(solid,$which) [ \
		# NOTE: we do not provide full multi-language support; not needed here
		ttk::button $f.solid \
			-textvar [namespace current]::mc::SolidColor \
			-command "[namespace current]::SelectSquareColor $which"]
	ttk::button $f.text \
		-textvar [::mc::var ::mc::Texture ...] \
		-command "[namespace code [list SelectTexture $f.texture $which]]"
	ttk::label $f.lzoom -textvar [namespace current]::mc::Zoom
	set Widget(zoom,$which) [ \
		::ttk::spinbox $f.szoom \
			-from 1 \
			-to 100 \
			-textvariable [namespace current]::Vars(zoom,$which) \
			-width 3 \
			-state $state \
			-exportselection false \
			-justify right \
			-command [namespace code [list Zoom $which]]] \
			;
	::validate::spinboxInt $f.szoom
	::theme::configureSpinbox $f.szoom
	foreach c {x y} {
		ttk::label $f.loffs$c -textvar [::mc::var [namespace current]::mc::Offset " [string toupper $c]"]
		set Widget(offs$c,$which) [ \
			::ttk::spinbox $f.soffs$c \
				-from 0 \
				-to 0 \
				-textvariable [namespace current]::Vars(offset,$which,$c) \
				-width 3 \
				-state $state \
				-exportselection false \
				-justify right \
				-command [namespace code [list ShiftSquare $which]]] \
				;
		::validate::spinboxInt $f.soffs$c
		::theme::configureSpinbox $f.soffs$c
	}
	set rot [ttk::frame $f.rot]
	ttk::label $rot.label -textvar [namespace current]::mc::Rotate
	grid $rot.label -column 1 -row 0 -sticky w
	set col 3
	foreach deg {0 90 180 270} {
		set Widget($deg,$which) [ \
			ttk::checkbutton \
				$rot.b$deg \
				-text "$deg°" \
				-variable [namespace current]::Vars(rotation,$which) \
				-onvalue $deg \
				-state $state \
				-command [namespace code [list RotateSquare $which]]]
		grid $rot.b$deg -column $col -row 0
		incr col 2
	}
	grid columnconfigure $rot {2 4 6 8} -minsize $::theme::padx
	grid columnconfigure $rot {2 4 6 8} -weight 1

	bind $Widget(zoom,$which)  <FocusOut> +[namespace code [list Zoom $which]]
	bind $Widget(offsx,$which) <FocusOut> +[namespace code [list ShiftSquare $which]]
	bind $Widget(offsy,$which) <FocusOut> +[namespace code [list ShiftSquare $which]]
	ConfigureSquareFrame $which
	
	grid $f.texture	-row  1 -column 1 -rowspan 9
	grid $f.solid		-row  1 -column 3 -columnspan 3 -sticky ewns
	grid $f.text		-row  3 -column 3 -columnspan 3 -sticky ewns
	grid $f.lzoom		-row  5 -column 3 -sticky ewns
	grid $f.szoom		-row  5 -column 5 -sticky ewns
	grid $f.loffsx		-row  7 -column 3 -sticky ewns
	grid $f.soffsx		-row  7 -column 5 -sticky ewns
	grid $f.loffsy		-row  9 -column 3 -sticky ewns
	grid $f.soffsy		-row  9 -column 5 -sticky ewns
	grid $f.rot			-row 11 -column 1 -columnspan 5 -sticky ew

	grid rowconfigure $f {0 2 4 12} -minsize $::theme::pady
	grid rowconfigure $f {6 8 10} -minsize [expr {$::theme::pady + 2}]
	grid columnconfigure $f {0 2 4 6} -minsize $::theme::padx
	grid columnconfigure $f 5 -weight 1
	grid rowconfigure $f {4} -weight 1
	
	SetTooltip $which
}


proc Reset {size} {
	variable [namespace parent]::needRefresh
	variable [namespace parent]::designSize
	variable style
	variable Vars
	variable Widget
	variable _style
	variable _Vars

	array set Vars [array get _Vars]
	array set style [array get _style]

	set Vars(borderline,width) [expr {int(round($style(borderline,width)*$designSize))}]

	foreach which {lite dark} {
		loadTexture $which
		ConfigureSquareFrame $which
		SetTooltip $which
	}
	
	set needRefresh(lite,$size) true
	set needRefresh(dark,$size) true
	set needRefresh(lite,$designSize) true
	set needRefresh(dark,$designSize) true
	setupSquares [list $size $designSize]
	RecolorButton hilite selected
	RecolorButton hilite suggested
}


proc UpdateBorderline {which {unused 0}} {
	variable [namespace parent]::designSize
	variable style
	variable Widget
	variable Vars

	if {$which eq "width"} {
		set width [expr {double($Vars(borderline,width))/double($designSize)}]
		if {$width == $style(borderline,width)} { return }
		set style(borderline,width) $width
		::theme::enableScale $Widget(opacity) [expr {$width > 0}]
	} else {
		if {$Vars(borderline,$which) == $style(borderline,$which)} { return }
		set style(borderline,$which) $Vars(borderline,$which)
	}

	MakeSquare lite
	MakeSquare dark
}


proc RecolorButton {type which} {
	variable style
	variable Widget
	variable Vars

	if {$which eq "texture"} {
		if {$style($type,texture) eq ""} {
			::scidb::tk::image recolor #00000000 photo_Circle(texture)
		} else {
			# TODO really neccessary?
			set file [file join $::scidb::dir::user textures tile {*}$style($type,texture)]
			set texture [getTexture $file]
			photo_Circle(texture) copy $::icon::15x15::circle
			if {[llength $texture]} {
				::scidb::tk::image copy $texture photo_Circle(texture) -from 0 0 15 15 -alphamask
				photo_Circle(texture) copy $::icon::15x15::ringBW
			} else {
				image create photo photo_Circle(temp) -width 15 -height 15
				loadImage $file photo_Circle(temp)
				::scidb::tk::image copy photo_Circle(temp) photo_Circle(texture) -from 0 0 15 15 -alphamask
				image delete photo_Circle(temp)
			}
			photo_Circle(texture) copy $::icon::15x15::ringBW
		}
	} else {
		if {$style($type,$which) eq ""} {
			::scidb::tk::image recolor #00000000 photo_Circle($which)
		} else {
			photo_Circle($which) copy $::icon::15x15::circle
			::scidb::tk::image recolor $style($type,$which) photo_Circle($which)
			photo_Circle($which) copy $::icon::15x15::ringBW
		}

		if {$type eq "hilite"} {
			foreach what {lite dark} {
				if {$which eq "selected"} {
					$Widget(texture,$what) itemconfigure selected -fill $style(hilite,selected)
				} else {
					$Widget(texture,$what) itemconfigure suggested -outline $style(hilite,suggested)
				}
			}
		}
	}

	# this trick forces update of the image
	$Widget($type,$which) configure -state normal
}


proc MakePreview {type which path} {
	variable [namespace parent]::designSize
	variable style
	variable Vars

	set f [ttk::labelframe $path.lf -labelwidget [ttk::label $path.llf -textvar ::mc::Preview]]
	set canv [tk::canvas $f.square -width $designSize -height $designSize -borderwidth 2 -relief sunken]
	$canv xview moveto 0
	$canv yview moveto 0
	pack $f -expand yes -fill both
	grid $canv -row 0 -column 1
	grid columnconfigure $f {0 2} -minsize 5 -weight 1
	grid rowconfigure $f 1 -minsize 5

	set m [expr {$designSize/2}]
	set Vars(texture) [image create photo -width $designSize -height $designSize]
	$Vars(texture) copy photo_Square(lite,$designSize) -from 0 0 $m $designSize -to 0 0
	$Vars(texture) copy photo_Square(dark,$designSize) -from $m 0 $designSize $designSize -to $m 0

	$canv create image 0 0 -image $Vars(texture) -anchor nw
	$canv create rectangle 0 0 $designSize $designSize -width 20 -outline $style($type,$which) -tag border
	bind $canv <<ChooseColorSelected>> "$canv itemconfigure border -outline %d"
	bind $canv <Destroy> [namespace code [list catch { image delete $Vars(texture) }]]

	return $canv
}


proc SelectColor {type which} {
	variable [namespace parent]::designSize
	variable style
	variable Widget
	variable Vars

	incr Vars(open)
	set selection [::colormenu::popup $Widget($type,$which) \
							-initialcolor $style($type,$which) \
							-oldcolor $style($type,$which) \
							-recentcolors [namespace current]::RecentColors($type) \
							-geometry last \
							-modal true \
							-embedcmd [namespace code [list MakePreview $type $which]] \
							-height [expr {$designSize + 20}] \
							-place centeronparent]
	incr Vars(open) -1
	
	if {[llength $selection]} {
		if {[llength $style($type,$which)]} {
			addToList [namespace current]::RecentColors($type) $style($type,$which)
		}

		if {$selection ne $style($type,$which)} {
			set style($type,$which) $selection
			addToList [namespace current]::RecentColors($type) $selection
			RecolorButton $type $which
		}
	}
}


proc ToggleShowColor {} {
	variable Widget
	variable Vars

	set state hidden
	if {$Vars(preview,color)} { set state normal }
	$Widget(texture,lite) itemconfigure selected -state $state
	$Widget(texture,dark) itemconfigure selected -state $state
	$Widget(texture,lite) itemconfigure suggested -state $state
	$Widget(texture,dark) itemconfigure suggested -state $state
}


proc DestroyDialog {dlg size resetCmd} {
	variable Vars

	if {$Vars(open)} { return }

	if {[dialog::question \
			-parent $dlg \
			-title $::scidb::app \
			-message [set [namespace current]::mc::CloseDialog]] eq "yes"} {
		Reset $size
		$resetCmd
		destroy $dlg
	}
}


proc openConfigDialog {parent size closeCmd updateCmd resetCmd} {
	variable [namespace parent]::designSize
	variable style
	variable Vars
	variable Widget
	variable _style
	variable _Vars

	# setup
	if {![info exists Vars(preview,color)]} { set Vars(preview,color) 0 }
	if {![info exists Vars(preview,border)]} { set Vars(preview,border) 0 }
	set Vars(borderline,width) [expr {int(round($style(borderline,width)*$designSize))}]
	set Vars(borderline,opacity) $style(borderline,opacity)
	set Vars(borderline,gap) $style(borderline,gap)
	set Vars(open) 0
	set [namespace parent]::texture::preferredOnly 1

	foreach which {lite dark} {
		if {[llength $style($which,texture)]} {
			set s [expr {$style($which,x2) - $style($which,x1)}]
			set Vars(zoom,$which) [expr {int(round(100.0*(double($designSize)/double($s))))}]
			set Vars(offset,$which,x) $style($which,x1)
			set Vars(offset,$which,y) $style($which,y1)
			set Vars(rotation,$which) $style($which,rotation)
		} else {
			set Vars(zoom,$which) 100
			set Vars(offset,$which,x) 0
			set Vars(offset,$which,y) 0
			set Vars(rotation,$which) 0
		}
	}

	array set _style [array get style]
	array set _Vars [array get Vars]

	registerSize $designSize
	setupSquares $designSize

	# toplevel
	set point [expr {$parent eq "." ? "" : "."}]
	set dlg [tk::toplevel ${parent}${point}configSquares -class Scidb]
	bind $dlg <Destroy> [namespace code {
		if {"%W" eq [winfo toplevel %W]} {
			unregisterSize [set [namespace parent]::designSize]
		}
	}]
	bind $dlg <Escape> [namespace code [list DestroyDialog $dlg $size $resetCmd]]
	bind $dlg <Destroy> "+ if {{%W} eq {$dlg}} { $closeCmd }"

	set fra [ttk::frame $dlg.fra]
	set top [ttk::frame $fra.top]
	set bot [ttk::frame $fra.bot]
	pack $fra

	# top frame
	set lit [ttk::labelframe $top.lite -labelwidget [ttk::label $top.llite -textvar ::mc::Lite]]
	set drk [ttk::labelframe $top.dark -labelwidget [ttk::label $top.ldark -textvar ::mc::Dark]]

	grid $lit -row 0 -column 0
	grid $drk -row 0 -column 2
	grid columnconfigure $top 1 -minsize 5

	MakeSquareFrame $lit lite
	MakeSquareFrame $drk dark
	ToggleShowColor

	# left bottom frame
	set brl [ttk::labelframe $bot.borderline \
					-labelwidget [ttk::label $bot.lborderline -textvar [namespace current]::mc::Borderline]]

	ttk::label $brl.lwidth -textvar [namespace current]::mc::Width
	tk::scale $brl.swidth \
		-from 0 \
		-to 20 \
		-orient horizontal \
		-width $::theme::sliderWidth \
		-takefocus 1 \
		-variable [namespace current]::Vars(borderline,width) \
		-command [namespace code [list UpdateBorderline width]]

	ttk::label $brl.lopacity -textvar [namespace current]::mc::Opacity
	ttk::frame $brl.fopacity -borderwidth 1 -relief flat
	set Widget(opacity) [ \
		tk::scale $brl.sopacity \
			-from 0 \
			-to 255 \
			-orient horizontal \
			-width $::theme::sliderWidth \
			-takefocus 1 \
			-variable [namespace current]::Vars(borderline,opacity) \
			-command [namespace code [list UpdateBorderline opacity]]]
	
	ttk::checkbutton $brl.gap \
		-textvar [namespace current]::mc::GapBetweenSquares \
		-variable [namespace current]::Vars(borderline,gap) \
		-command [namespace code [list UpdateBorderline gap]]
	
	grid $brl.lwidth -column 1 -row 1 -sticky sew
	grid $brl.swidth -column 3 -row 1 -sticky nsew
	grid $brl.lopacity -column 1 -row 3 -sticky sew
	grid $brl.sopacity -column 3 -row 3 -sticky nsew
	grid $brl.gap -column 1 -columnspan 3 -row 5 -sticky sw
	grid columnconfigure $brl {0 2 4} -minsize $::theme::padx
	grid columnconfigure $brl 3 -weight 1
	grid rowconfigure $brl 4 -minsize $::theme::padY
	grid rowconfigure $brl 6 -minsize $::theme::pady

	# right bottom frame
	set hil [ttk::labelframe $bot.hilighting \
				-labelwidget [ttk::label $bot.lhilighting -textvar [namespace current]::mc::Highlighting]]

	foreach {which textvar} [list	selected [namespace current]::mc::Selected \
											suggested [namespace current]::mc::SuggestedMove] {
		image create photo photo_Circle($which) -width 15 -height 15
		photo_Circle($which) copy $::icon::15x15::circle
		::scidb::tk::image recolor $style(hilite,$which) photo_Circle($which)
		ttk::button $hil.$which \
			-style aligned.TButton \
			-textvar $textvar \
			-image photo_Circle($which) \
			-compound left \
			-command [namespace code [list SelectColor hilite $which]]
		bind $hil.$which <Destroy> "image delete photo_Circle($which)"
		set Widget(hilite,$which) $hil.$which
		RecolorButton hilite $which
	}

	ttk::checkbutton $hil.preview \
		-textvar [namespace current]::mc::Show \
		-variable [namespace current]::Vars(preview,color) \
		-command [namespace code { ToggleShowColor }]

	grid $hil.selected -row 1 -column 1 -sticky we
	grid $hil.suggested -row 3 -column 1 -sticky we
	grid $hil.preview -row 5 -column 1 -sticky sw
	grid columnconfigure $hil 1 -weight 1
	grid columnconfigure $hil {0 3} -minsize $::theme::padx
	grid rowconfigure $hil {0 2 4 6} -minsize $::theme::pady
	grid rowconfigure $hil 4 -weight 1

	grid $brl -row 0 -column 0 -sticky nsew
	grid $hil -row 0 -column 2 -sticky ns
	grid columnconfigure $bot 1 -minsize 5
	grid columnconfigure $bot 0 -weight 1

	# placement
	grid $top -row 1 -column 1
	grid $bot -row 3 -column 1 -sticky ew
	grid rowconfigure $fra {0 2 4} -minsize 5
	grid columnconfigure $fra {0 2} -minsize 5

	# dialog buttons
	widget::dialogButtons $dlg {ok cancel apply revert} -default apply
	$dlg.ok configure -command "
		set [namespace parent]::needRefresh(lite,$size) true
		set [namespace parent]::needRefresh(dark,$size) true
		[namespace parent]::setupSquares $size
		$updateCmd true
		destroy $dlg"
	$dlg.cancel configure -command "
		[namespace current]::Reset $size
		$resetCmd
		destroy $dlg"
	$dlg.apply configure -command "
		set [namespace parent]::needRefresh(lite,$size) true
		set [namespace parent]::needRefresh(dark,$size) true
		[namespace parent]::setupSquares $size
		$updateCmd"
	$dlg.revert configure -command "
		[namespace current]::Reset $size
		$resetCmd"

	# map window
	wm resizable $dlg 0 0
	wm withdraw $dlg
	wm title $dlg "$::scidb::app: [set [namespace current]::mc::SquareStyleConf]"
	::util::place $dlg -parent $parent -position center
#	wm transient $dlg [winfo toplevel $parent]
	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list DestroyDialog $dlg $size $resetCmd]]
	wm deiconify $dlg

#	ttk::grabWindow $dlg
	catch { focus $lit.solid }
#	tkwait window $dlg
#	ttk::releaseGrab $dlg
}

} ;# namespace square
} ;# namespace board

# vi:set ts=3 sw=3:
