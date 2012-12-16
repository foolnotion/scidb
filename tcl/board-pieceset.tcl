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

::util::source board-pieces

namespace eval board {
namespace eval pieceset {

namespace export isOutline computeStartOffset computeStopOffset makePieces
namespace export makePieceSelectionFrame updatePieceSet

variable Listbox
variable FigurineDict [dict create]

variable RegExpBBox				{scidb:bbox=\"([+-]?[0-9]*[.]?[0-9]+),([+-]?[0-9]*[.]?[0-9]+),([+-]?[0-9]*[.]?[0-9]+),([+-]?[0-9]*[.]?[0-9]+)\"}
variable RegExpPieceScale		{scidb:scale=\"([0-9]*[.]?[0-9]+)\"}
variable RegExpContourWidth	{scidb:contour=\"([0-9]*[.]?[0-9]+)\"}
variable RegExpTranslation		{scidb:translate=\"([+-]?[0-9]*[.]?[0-9]+),([+-]?[0-9]*[.]?[0-9]+)\"}

event add <<PieceSetChanged>> PieceSetChanged


proc isOutline {{fontName ""}} {
	variable [namespace parent]::theme::style

	if {[llength $fontName] == 0} { set fontName $style(piece-set) }
	set pieceSet [lindex $::board_PieceSet [lsearch -exact -index 0 $::board_PieceSet $fontName]]
	return [expr {[lindex $pieceSet 1] eq "truetype"}]
}


proc computeStartOffset {x1 y1 x2 y2} {
	if {$x1 > $x2} { set x1 [expr {1.0 - $x1}] }
	if {$y1 > $y2} { set y1 [expr {1.0 - $y1}] }

	return [expr {100.0*min($x1,$y1)}]
}


proc computeStopOffset {x1 y1 x2 y2} {
	if {$x1 > $x2} { set x2 [expr {1.0 - $x2}] }
	if {$y1 > $y2} { set y2 [expr {1.0 - $y2}] }

	return [expr {100.0*max($x2,$y2)}]
}


proc makePieces {size {pieces all}} {
	variable [namespace parent]::theme::style

	set grad(w) {}
	set grad(b) {}
	set pieceSet $style(piece-set)

	variable [namespace parent]::piece::style

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

			if {[isOutline]} {
				lappend grad($color) $style(gradient,$color,tx) $style(gradient,$color,ty)
			}
		}
	}

	if {[isOutline] && !$style(useWhitePiece)} {
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

	MakePieces               \
		{}                    \
		$pieceSet             \
		$pieces               \
		$size                 \
		$style(zoom)          \
		$style(contour)       \
		no                    \
		$style(shadow)        \
		$fillColors           \
		$strokeColors         \
		$texture              \
		$contour              \
		$gradients            \
		$style(opacity)       \
		$style(diffusion)     \
		$style(useWhitePiece) \
		;
}


proc registerFigurines {size dontUseContour} {
	variable FigurineDict

	set key $size,$dontUseContour
	if {[dict get [dict incr FigurineDict $key] $key] == 1} {
		set prefix figurine,$dontUseContour
		foreach p {wk bk wq wr wb wn wp bq br bb bn bp} {
			image create photo photo_Piece($prefix,$p,$size) -width $size -height $size
		}
		MakeFigurines $size $dontUseContour
	}
}


proc unregisterFigurines {size dontUseContour} {
	variable FigurineDict

	set key $size,$dontUseContour
	if {[dict get [dict incr BoardSizeDict $key -1] $key] == 0} {
		set prefix figurine,$dontUseContour
		foreach p {wk bk wq wr wb wn wp bq br bb bn bp} { image delete photo_Piece($prefix,$p,$size) }
	}
}


proc MakeFigurines {size dontUseContour} {
	set pieceList {wk bk wq wr wb wn wp bq br bb bn bp}
	set pieceSet [lindex $::board_PieceSet [lsearch -exact -index 0 $::board_PieceSet Cases]]
	set prefix figurine,$dontUseContour
	if {$dontUseContour} { set contour 0.0 } else { set contour 1.0 }
	MakePieces             \
		$prefix,            \
		$pieceSet           \
		$pieceList          \
		$size               \
		1.2                 \
		$contour            \
		yes                 \
		0.07333333333333333 \
		{{} {}}             \
		{{} {}}             \
		{{} {}}             \
		{#ffffff #eeeeee}   \
		{{} {}}             \
		0.5019607843137255  \
		linear              \
		no                  \
		;
}


proc MakePieces {	prefix pieceSet pieceList size scale contour boostContour shadow fillColors
						strokeColors textures contourColors gradients shadowOpacity shadowDiffuse
						useWhitePiece } {
	variable RegExpBBox
	variable RegExpPieceScale
	variable RegExpContourWidth
	variable RegExpTranslation

	if {$size == 0} { return }

	lassign $fillColors fillColor(w) fillColor(b)
	lassign $strokeColors strokeColor(w) strokeColor(b)
	lassign $contourColors contourColor(w) contourColor(b)
	lassign $textures texture(w) texture(b)

	set fontName [string map {"-" "_" " " ""} [lindex $pieceSet 0]]
	set source [lindex $pieceSet 1]
	set strokeWidth(w) -1
	set strokeWidth(b) -1
	set contourWidth 0
	set sampleSize 0
	set gradient(w) {}
	set gradient(b) {}
	set overstroke 0

	for {set i 2} {$i < [llength $pieceSet]} {incr i} {
		set attr [lindex $pieceSet $i]
		set value [lindex $attr 1]

		switch -exact -- [lindex $attr 0] {
			stroke			{ set strokeWidth(w) $value; set strokeWidth(b) $value }
			stroke-white	{ set strokeWidth(w) $value }
			stroke-black	{ set strokeWidth(b) $value }
			contour			{ set contourWidth $value }
			sampling			{ set sampleSize $value }
			overstroke		{ set overstroke $value }
		}
	}

	if {$size > $sampleSize} { set sampleSize $size }
	if {$pieceList eq "all"} { set pieceList {wk wq wr wb wn wp bk bq br bb bn bp} }
	set scale [expr $scale*0.96]
	set fontIsOutline [expr {$source eq "truetype"}]

	set shadowSize [expr {int(double($sampleSize)*$shadow + 0.99)}]
	set opacity $shadowOpacity
	if {$shadowDiffuse ne "none" && $shadowSize} {
		if {$shadowDiffuse eq "quadratic"} { incr shadowSize 2 }
		set opacity [expr {$shadowOpacity - (double($shadowSize - 1)/$shadowSize)*$shadowOpacity}]
	}
	set shadowColor [format "#000000%02x" [expr {min(255,int(round($opacity*255.0)))}]]

	foreach {c i} {w 0 b 1} {
		if {[llength [lindex $gradients $i]]} {
			set tx 0
			set ty 0
			lassign [lindex $gradients $i] start stop x1 y1 x2 y2 tx ty

			if {$tx == ""} {
				set tx 0
				set ty 0
			}

			if {$fontIsOutline} {
				set y1 [expr {1.0 - $y1}]
				set y2 [expr {1.0 - $y2}]
			}

			set offs1 [computeStartOffset $x1 $y1 $x2 $y2]
			set offs2 [computeStopOffset $x1 $y1 $x2 $y2]
			set gradient($c) [list $start $stop $offs1 $offs2 $x1 $y1 $x2 $y2]

			if {$c eq "w" || $useWhitePiece} {
				set gradient($c,tx) [expr {($tx*$sampleSize)/$scale}]
				set gradient($c,ty) [expr {($ty*$sampleSize)/$scale}]
			} else {
				set gradient($c,tx) 0
				set gradient($c,ty) 0
			}
		}
	}

	if {$overstroke > 0} {
		foreach c {w b} {
			if {[llength $gradient($c)]} {
				if {[expr {$useWhitePiece ? "w" : $c}] eq "w"} {
					scan [lindex $gradient($c) 0] "\#%2x%2x%2x" r g b
					set luma1 [expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
					scan [lindex $gradient($c) 1] "\#%2x%2x%2x" r g b
					set luma2 [expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
					set overstrokeColor($c) [lindex $gradient($c) [expr {$luma2 < $luma1}]]
				}
			}
		}
	}

	switch -exact -- $source {
		svg		{ upvar #0 svg_$fontName font }
		truetype	{ upvar #0 truetype_$fontName font }
	}

	foreach cp $pieceList {
		lassign [split $cp {}] c p

		set pieceScale 1.0
		set contourWd 0
		set pieceMoveX 0
		set pieceMoveY 0
		set pieceColor [expr {$useWhitePiece ? "w" : $c}]
		set grad $gradient($c)
		set useShadow [expr {$shadow > 0}]
		set useTexture [expr {[llength $texture($c)] > 0}]
		set contourWd $contourWidth

		regexp $RegExpBBox $font($pieceColor$p) dummy minX minY maxX maxY
		regexp $RegExpPieceScale $font($pieceColor$p) dummy pieceScale
		regexp $RegExpTranslation $font($pieceColor$p) dummy pieceMoveX pieceMoveY

		photo_Piece($prefix$c$p,$size) blank

		set useBackground [expr {$contour > 0 || $shadow > 0 || $fontIsOutline}]
		set needBackground [expr {	$fontIsOutline
										&& $contour > 0
										&& [llength $fillColor($c)] > 0
										&& $fillColor($c) ne $contourColor($c)}]

		if {$pieceScale <= 1} {
			set strokeScale [expr {3.0/$pieceScale - 2.0}]
		} elseif {$pieceScale > 1} {
			set strokeScale [expr {(1.0/$pieceScale + 2.0)/3.0}]
		}

		if {[llength $grad] && $fontIsOutline && ($c eq "w" || $useWhitePiece)} {
			set grad [concat	$grad \
									[expr {$gradient($c,tx)/$pieceScale}] \
									[expr {$gradient($c,ty)/$pieceScale}]]
		}

		if {$useBackground} {
			regexp $RegExpContourWidth $font($pieceColor$p) dummy contourWd
			if {$contourWd != 0} {
				set contourStrokeWidth $contourWd
			} else {
				set contourStrokeWidth [expr $contour*$contourWidth]
			}
			if {$size >= 50} {
				set stroke $contourColor($c)
			} elseif {$boostContour} {
				set stroke white
				set contourStrokeWidth [expr {int(round($contourStrokeWidth*(60.0/$size)))}]
			} elseif {$source eq "truetype" || $fontName eq "Burnett" || $fontName eq "Standard"} {
				set stroke $contourColor($c)
				set contourStrokeWidth [expr {int(round($contourStrokeWidth*(40.0/$size)))}]
			} else {
				set stroke black
				set contourStrokeWidth [expr {int(round($contourStrokeWidth*(40.0/$size)))}]
			}
			set maskStrokeWidth [expr $contourStrokeWidth/($scale*$pieceScale)]
			if {$fontIsOutline && [llength $grad] && $pieceColor eq "b"} {
				set maskStrokeWidth [expr {max(0, $maskStrokeWidth - 2*($strokeWidth($c)*$strokeScale))}]
			}
			image create photo piece(bg) -width $sampleSize -height $sampleSize
			::scidb::tk::image create font($pieceColor$p,mask) piece(bg) \
				-flip $fontIsOutline \
				-scale [expr $scale*$pieceScale] \
				-translate $pieceMoveX $pieceMoveY \
				-outline 1 \
				-stroke-width $maskStrokeWidth \
				-stroke $stroke \
				-fill $fillColor($c)
		}

		if {$useShadow} {
			image create photo piece(sh) -width $sampleSize -height $sampleSize
			if {$shadowDiffuse ne "none"} {
				set sh [image create photo -width $sampleSize -height $sampleSize]
				$sh copy piece(bg)
				::scidb::tk::image recolor $shadowColor $sh
				set s [expr {$sampleSize - 1}]
				set offs 1
				for {set i 0} {$i < $shadowSize} {incr i} {
					piece(sh) copy $sh \
						-from 0 0 $s $s \
						-to $offs $offs $sampleSize $sampleSize \
						-compositingrule overlay
					incr s -1; incr offs 1
				}
				::scidb::tk::image boost $opacity $shadowOpacity piece(sh)
				if {$shadowDiffuse eq "quadratic"} { ::scidb::tk::image diffuse $shadowOpacity piece(sh) }
				image delete $sh
			} else {
				piece(sh) copy piece(bg)
				::scidb::tk::image recolor $shadowColor piece(sh)
			}
		}

		if {$needBackground} {
			image create photo piece(tp) -width $sampleSize -height $sampleSize
			::scidb::tk::image create font($c$p,mask) piece(tp) \
				-flip $fontIsOutline \
				-sharpen $fontIsOutline \
				-scale [expr {$scale*$pieceScale}] \
				-translate $pieceMoveX $pieceMoveY \
				-stroke-width [expr {$strokeWidth($c)*$strokeScale}] \
				-stroke $fillColor($c) \
				-fill $fillColor($c)
			piece(bg) copy piece(tp)
			image delete piece(tp)
		}

		if {$useTexture} {
			image create photo piece(tex) -width $size -height $size
			::scidb::tk::image create font($pieceColor$p,mask) piece(tex) \
				-flip $fontIsOutline \
				-sharpen $fontIsOutline \
				-scale [expr {$scale*$pieceScale}] \
				-translate $pieceMoveX $pieceMoveY \
				-stroke-width 0 \
				-fill white
			set color [expr {$c eq "w" ? "white" : "black"}]
			::scidb::tk::image copy photo_Square($color,$size) piece(tex) -alphamask
		}

		image create photo piece(fg) -width $sampleSize -height $sampleSize

		if {$fontIsOutline && [llength $grad]} {
			if {$pieceColor eq "w"} {
				::scidb::tk::image create font(w$p,exterior) piece(fg) \
					-bbox $minX $minY $maxX $maxY \
					-flip $fontIsOutline \
					-scale [expr $scale*$pieceScale] \
					-translate $pieceMoveX $pieceMoveY \
					-gradient $grad
				image create photo piece(tp) -width $sampleSize -height $sampleSize
				if {$overstroke > 0} {
					::scidb::tk::image create font($pieceColor$p) piece(tp) \
						-flip $fontIsOutline \
						-sharpen true \
						-scale [expr $scale*$pieceScale] \
						-translate $pieceMoveX $pieceMoveY \
						-outline true \
						-stroke-width [expr {($overstroke*$strokeScale)}] \
						-stroke $overstrokeColor($c) \
						-fill $overstrokeColor($c)
					piece(fg) copy piece(tp)
				}
				::scidb::tk::image create font(w$p) piece(tp) \
					-flip $fontIsOutline \
					-sharpen [expr {[llength $strokeColor($c)] == 0}] \
					-scale [expr $scale*$pieceScale] \
					-translate $pieceMoveX $pieceMoveY \
					-outline true \
					-stroke-width [expr {$strokeWidth($c)*$strokeScale}] \
					-stroke $strokeColor($c) \
					-fill $strokeColor($c)
				piece(fg) copy piece(tp)
				image delete piece(tp)
			} else {
				::scidb::tk::image create font(b$p,exterior) piece(fg) \
					-bbox $minX $minY $maxX $maxY \
					-flip $fontIsOutline \
					-scale [expr {$scale*$pieceScale}] \
					-translate $pieceMoveX $pieceMoveY \
					-stroke-width 0 \
					-gradient $grad
				if {[string length $font(b$p,interior)]} {
					image create photo piece(tp) -width $sampleSize -height $sampleSize
					::scidb::tk::image create font($pieceColor$p,interior) piece(tp) \
						-bbox $minX $minY $maxX $maxY \
						-flip $fontIsOutline \
						-scale [expr {$scale*$pieceScale}] \
						-translate $pieceMoveX $pieceMoveY \
						-outline true \
						-stroke-width 0 \
						-fill $fillColor($c)
					piece(fg) copy piece(tp)
					image delete piece(tp)
				}
			}
		} else {
			if {$fontIsOutline} {
				set color $strokeColor($c)
			} elseif {$useTexture} {
				set color #00000000
			} else {
				set color $fillColor($c)
			}
			::scidb::tk::image create font($pieceColor$p) piece(fg) \
				-flip $fontIsOutline \
				-sharpen [expr {$fontIsOutline && [llength $strokeColor($c)] == 0}] \
				-scale [expr $scale*$pieceScale] \
				-translate $pieceMoveX $pieceMoveY \
				-outline $fontIsOutline \
				-gradient $grad \
				-stroke-width [expr $strokeWidth($c)*$strokeScale] \
				-stroke $strokeColor($c) \
				-fill $color
		}

		if {$size < $sampleSize} {
			image create photo piece(sample) -width $sampleSize -height $sampleSize
			if {$shadow > 0} {
				set offs [expr {$shadowDiffuse ne "none" ? 1 : max(2, $shadowSize)}]
				set s [expr {$sampleSize - $offs}]
				piece(sample) copy piece(sh) -from 0 0 $s $s -to $offs $offs $sampleSize $sampleSize
			}
			if {$contour > 0 || $fontIsOutline} { piece(sample) copy piece(bg) }

			if {$useTexture} {
				set temp [image create photo -width $size -height $size]
				::scidb::tk::image copy piece(sample) photo_Piece($prefix$c$p,$size)
				::scidb::tk::image copy piece(fg) $temp
				photo_Piece($prefix$c$p,$size) copy piece(tex)
				photo_Piece($prefix$c$p,$size) copy $temp
				image delete $temp
				image delete piece(sample)
			} else {
				piece(sample) copy piece(fg)
				::scidb::tk::image copy piece(sample) photo_Piece($prefix$c$p,$size)
				image delete piece(sample)
			}
		} else {
			if {$shadow > 0} {
				set offs [expr {$shadowDiffuse ne "none" ? 1 : max(2, $shadowSize)}]
				set s [expr {$sampleSize - $offs}]
				photo_Piece($prefix$c$p,$size) copy piece(sh) \
					-from 0 0 $s $s -to $offs $offs $sampleSize $sampleSize
			}
			if {$contour > 0 || $fontIsOutline} { photo_Piece($prefix$c$p,$size) copy piece(bg) }
			if {$useTexture} { photo_Piece($prefix$c$p,$size) copy piece(tex) }
			photo_Piece($prefix$c$p,$size) copy piece(fg)
		}

		image delete piece(fg)
		if {$useBackground} { image delete piece(bg) }
		if {$useShadow} { image delete piece(sh) }
		if {$useTexture} { image delete piece(tex) }
	}
}


proc makePieceSelectionFrame {parent visible} {
	variable [namespace parent]::theme::style
	variable Listbox
	global board_PieceSet

	set Listbox [::tlistbox $parent.pieceSel -height $visible -usescroll 1]

	$Listbox addcol image -id icon
	$Listbox addcol text -id text -expand yes

	set board_PieceSet [lsort -dictionary -index 0 $board_PieceSet]

	set contents {}
	foreach pieceSet $board_PieceSet {
		set name [lindex $pieceSet 0]
		set source [lindex $pieceSet 1]
		set dataName [string map {"-" "_" " " ""} $name]
		upvar #0 ${source}_${dataName} data
		set img [image create photo -data $data(sample,24pt,200x34)]
		$Listbox insert [list $img $name]
	}

	$Listbox resize

	bind $Listbox <<ListboxSelect>> [namespace code [list PieceSetChanged $parent %d]]
	bind $Listbox <Destroy> [namespace code [Cleanup %W $contents]]

	pack $Listbox -expand yes -fill both

	return $Listbox
}


proc PieceSetChanged {parent data} {
	if {[llength $data]} {
		event generate $parent <<PieceSetChanged>> -data [lindex $::board_PieceSet $data 0]
	}
}


proc Cleanup {w contents} {
	variable Listbox

	if {$Listbox eq $w} {
		foreach entry $contents { image delete [lindex $entry 0] }
	}
}


proc updatePieceSet {w} {
	variable [namespace parent]::theme::style
	variable Listbox

	$Listbox select [lsearch -exact -index 0 $::board_PieceSet $style(piece-set)]
}

} ;# namespace pieceset
} ;# namespace board

# vi:set ts=3 sw=3:
