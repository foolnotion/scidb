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

::util::source board-basics

namespace eval board {
namespace eval mc {

set CannotReadFile			"Cannot read file '%s'"
set CannotFindFile			"Cannot find file '%s'"
set FileWillBeIgnored		"'%s' will be ignored (duplicate id)"
set IsCorrupt					"'%s' is corrupt (unknown %s style '%s')"
set SquareStyleIsUndefined	"Square style '%s' no longer exists"
set PieceStyleIsUndefined	"Piece style '%s' no longer exists"
set ThemeIsUndefined			"Board theme '%s' no longer exists"

set ThemeManagement			"Theme Management"
set Setup						"Setup"

set WorkingSet					"Working Set"

} ;# namespace mc

variable Version 1.0

variable workingSetId	"Working Set"
variable defaultId		"Default"

namespace eval square {

variable workingSetId	[set [namespace parent]::workingSetId]
variable defaultId		[set [namespace parent]::defaultId]

array set Default {
	Modified							false
	Filename							{}

	lite,rotation					0
	lite,solid						#b0c4de
	lite,texture					{}
	lite,x1							0
	lite,x2							0
	lite,y1							0
	lite,y2							0

	dark,rotation					0
	dark,solid						#4682b4
	dark,texture					{}
	dark,x1							0
	dark,x2							0
	dark,y1							0
	dark,y2							0

	borderline,width				0.007
	borderline,opacity			0x80
	borderline,gap					0
	borderline,color				#002958

	hilite,selected				#11ac1f
	hilite,suggested				#fff056

	hint,border-color				#32719d
	hint,border-coords			#ffffff
	hint,border-tile				{}
	hint,border-rotation			0
	hint,background-color		{}
	hint,background-coords		#000000
	hint,background-tile			{marble marble_252.jpg}
	hint,background-rotation	0
}
set Default(identifier) $defaultId
set Default(version) [set [namespace parent]::Version]

array set Working [array get Default]
set Working(identifier) $workingSetId
set Working(version) [set [namespace parent]::Version]

upvar 0 Working style

variable styleNames	{}
variable StyleDict	[dict create]	;# map long ID to style array
variable NameLookup	[dict create]	;# map short ID to long ID
variable NameMap		[dict create]	;# map long ID to short ID
variable NameOrder	{}					;# read user preferred order from option.dat
variable texSubDirs	{wood marble misc}
variable preferences

dict set StyleDict $defaultId [namespace current]::Default
dict set StyleDict $workingSetId [namespace current]::Working

dict set NameLookup $defaultId $defaultId
dict set NameLookup $workingSetId $workingSetId

dict set NameMap $defaultId $defaultId
dict set NameMap $workingSetId $workingSetId

} ;# namespace square

namespace eval piece {

variable workingSetId	[set [namespace parent]::workingSetId]
variable defaultId		[set [namespace parent]::defaultId]

array set Default {
	Modified					false
	Filename					{}

	contour					1.0
	shadow					0.03
	opacity					0.5
	zoom						1.0
	diffusion				none
	useWhitePiece			false

	color,w,contour		#ffffff
	color,w,fill			{}
	color,w,stroke			{}
	color,w,texture		{}

	color,b,contour		#ffffff
	color,b,fill			{}
	color,b,stroke			{}
	color,b,texture		{}

	texture,w,rotation	0
	texture,w,x1			0
	texture,w,x2			0
	texture,w,y1			0
	texture,w,y2			0

	texture,b,rotation	0
	texture,b,x1			0
	texture,b,x2			0
	texture,b,y1			0
	texture,b,y2			0

	gradient,w,use			false
	gradient,w,start		{}
	gradient,w,stop		{}
	gradient,w,tx			0
	gradient,w,ty			0
	gradient,w,x1			0
	gradient,w,x2			1
	gradient,w,y1			0
	gradient,w,y2			1

	gradient,b,use			false
	gradient,b,start		{}
	gradient,b,stop		{}
	gradient,b,tx			0
	gradient,b,ty			0
	gradient,b,x1			0
	gradient,b,x2			1
	gradient,b,y1			0
	gradient,b,y2			1
}
set Default(identifier) $defaultId
set Default(version) [set [namespace parent]::Version]

array set Working [array get Default]
set Working(identifier) $workingSetId
set Working(version) [set [namespace parent]::Version]

upvar 0 Working style

variable styleNames	{}
variable StyleDict	[dict create]	;# map short ID to style array
variable NameLookup	[dict create]	;# map short ID to original ID
variable NameMap		[dict create]	;# map original ID to short ID
variable NameOrder	{}					;# read user preferred order from option.dat
variable Stack			{}

dict set StyleDict $defaultId [namespace current]::Default
dict set StyleDict $workingSetId [namespace current]::Working

dict set NameLookup $defaultId $defaultId
dict set NameLookup $workingSetId $workingSetId

dict set NameMap $defaultId $defaultId
dict set NameMap $workingSetId $workingSetId

} ;# namespace piece

namespace import ::tcl::mathfunc::min

namespace export findTexture loadTexture setupSquares setupPieces
namespace export loadImage registerSize unregisterSize setTile setTheme
namespace export setSquareStyle setPieceStyle setPieceSet setBackground

namespace eval theme {

variable workingSetId	[set [namespace parent]::workingSetId]
variable defaultId		[set [namespace parent]::defaultId]

array set Default {
	Modified			false
	Filename			{}

	square-style	Default
	piece-style		Default
	piece-set		Merida
}
set Default(identifier) $defaultId
set Default(version) [set [namespace parent]::Version]

array set Working [array get Default]
set Working(identifier) $workingSetId
set Working(version) [set [namespace parent]::Version]

upvar 0 Working style

variable styleNames	{}
variable StyleDict	[dict create]	;# map short ID to style array
variable NameLookup	[dict create]	;# map short ID to original ID
variable NameMap		[dict create]	;# map original ID to short ID
variable NameOrder	{}					;# read user preferred order from option.dat
variable Stack			{}
variable Referees

dict set StyleDict $defaultId [namespace current]::Default
dict set StyleDict $workingSetId [namespace current]::Working

dict set NameLookup $defaultId $defaultId
dict set NameLookup $workingSetId $workingSetId

dict set NameMap $defaultId $defaultId
dict set NameMap $workingSetId $workingSetId

} ;# namespace theme

variable BoardSizeDict	[dict create]
variable PieceSizeDict	[dict create]
variable designSize		150
variable currentTheme	$workingSetId

array set texture {
	lite		{}
	dark		{}
	window	{}
	border	{}
	white		{}
	black		{}
}

array set Texture {}
array set Tile {}

array set layout {
	material-values	1
	material-bar		0
	side-to-move		1
	border				1
	coordinates			1
	coords-small		0
	coords-embossed	0
}

array set effects {
	animation	250
}

array set hilite {
	show-suggested	1
	selected			0
	suggested		2
}

array set colors {
	locked							false

	user,background-tile			{}
	user,background-coords		#ffffff
	user,background-color		{}
	user,background-rotation	0
	user,border-tile				{}
	user,border-color				#999999
	user,border-coords			#ffffff
	user,border-rotation			0
}
set colors(hint,border-color)				$square::Default(hint,border-color)
set colors(hint,border-coords)			$square::Default(hint,border-coords)
set colors(hint,border-tile)				$square::Default(hint,border-tile)
set colors(hint,border-rotation)			$square::Default(hint,border-rotation)
set colors(hint,background-color)		$square::Default(hint,background-color)
set colors(hint,background-coords)		$square::Default(hint,background-coords)
set colors(hint,background-tile)			$square::Default(hint,background-tile)
set colors(hint,background-rotation)	$square::Default(hint,background-rotation)

array set needRefresh {
	piece,all		false
	lite,all			false
	dark,all			false
	borderline,all	false
	white,all		false
	black,all		false
}


proc computeGap {size} {
	variable square::style

	set gap $style(borderline,gap)
	set width [expr {int(round($style(borderline,width)*$size + 0.2))}]
	if {$width == 0 && $style(borderline,width) > 0} { set gap 1 }

	return $gap
}


proc borderlineGap {} {
	variable square::style
	return $style(borderline,gap)
}


proc refreshTexture {which size} {
	variable piece::style
	variable texture

	if {[llength $texture($which)] == 0} { return }

	set color [string index $which 0]

	set iw [image width $texture($which)]
	set ih [image height $texture($which)]
	set x1 $style(texture,$color,x1)
	set x2 $style(texture,$color,x2)
	set y1 $style(texture,$color,y1)
	set y2 $style(texture,$color,y2)

	if {$x2 > $iw} { set x2 $iw }
	if {$y2 > $ih} { set y2 $ih }
	if {$x2 - $x1 > $y2 - $y1} { set x2 [expr {$x1 + $y2 - $y1}] }
	if {$y2 - $y1 > $x2 - $x1} { set y2 [expr {$y1 + $x2 - $x1}] }

	::scidb::tk::image copy $texture($which) photo_Square($which,$size) \
		-from $x1 $y1 $x2 $y2 \
		-rotate [expr {$style(texture,$color,rotation)/90}] \
		;
}


proc setupSquares {size} {
	variable square::style
	variable texture
	variable BoardSizeDict
	variable needRefresh
	variable designSize

	if {$size eq "all"} {
		set size [dict keys $BoardSizeDict]

		foreach s $size {
			foreach which {lite dark} {
				if {$needRefresh($which,all)} { set needRefresh($which,$s) true }
			}
		}
	}

	foreach which {lite dark} {
		set needRefresh($which,all) false
	}

	foreach s $size {
		if {$needRefresh(lite,$s) || $needRefresh(dark,$s)} {
			RefreshBorder $s
		}

		foreach which {lite dark} {
			if {$needRefresh($which,$s)} {
				if {[llength $texture($which)]} {
					if {$style($which,x2) == 0} {
						set min [min \
										$s \
										[image width $texture($which)] \
										[image height $texture($which)]]
						set style($which,x2) $min
						set style($which,y2) $min
					}

					RefreshSquare $which $s
				} else {
					set color $style($which,solid)
					if {[string length $color] == 0} { set color gray }
					::scidb::tk::image recolor $color photo_Square($which,$s) -composite set
					photo_Square($which,$s) copy photo_Borderline($s)
				}

				set needRefresh($which,$s) false
			}
		}
	}
}


proc setupPieces {{size all}} {
	variable PieceSizeDict
	variable needRefresh
	variable texture
	variable piece::style

	if {$size eq "all"} {
		set size [dict keys $PieceSizeDict]
		foreach s $size {
			if {$needRefresh(piece,all)} { set needRefresh(piece,$s) true }
			if {$needRefresh(white,all)} { set needRefresh(white,$s) true }
			if {$needRefresh(black,all)} { set needRefresh(black,$s) true }
		}
	}

	set needRefresh(piece,all) false
	set needRefresh(white,all) false
	set needRefresh(black,all) false

	foreach s $size {
		foreach which {white black} {
			if {$needRefresh($which,$s)} {
				if {[llength $texture($which)]} {
					set needRefresh(piece,$s) true
					set color [string index $which 0]
					if {$style(texture,$color,x2) == 0} {
						set min [min \
										$s \
										[image width $texture($which)] \
										[image height $texture($which)]]
						set style(texture,$color,x2) $min
						set style(texture,$color,y2) $min
					}

					refreshTexture $which $s
				}

				set needRefresh($which,$s) false
			}
		}

		if {$needRefresh(piece,$s)} {
			pieceset::makePieces $s
			set needRefresh(piece,$s) false
		}
	}
}


proc registerBoardSize {size} {
	variable BoardSizeDict
	variable needRefresh

	if {[dict get [dict incr BoardSizeDict $size] $size] == 1} {
		foreach which {lite dark} {
			image create photo photo_Square($which,$size) -width $size -height $size
		}
		image create photo photo_Borderline($size) -width $size -height $size

		foreach which {lite dark} {
			set needRefresh($which,$size) true
		}
	}
}


proc unregisterBoardSize {size} {
	variable BoardSizeDict

	if {[dict get [dict incr BoardSizeDict $size -1] $size] == 0} {
		foreach which {lite dark} {
			catch { image delete photo_Square($which,$size) }
		}
		catch { image delete photo_Borderline($size) }
		dict unset BoardSizeDict $size
	}
}


proc registerPieceSize {size} {
	variable PieceSizeDict
	variable needRefresh

	if {[dict get [dict incr PieceSizeDict $size] $size] == 1} {
		foreach piece {wk wq wr wb wn wp bk bq br bb bn bp e} {
			image create photo photo_Piece($piece,$size) -width $size -height $size
		}

		image create photo photo_Square(white,$size) -width $size -height $size
		image create photo photo_Square(black,$size) -width $size -height $size

		foreach which {piece white black} {
			set needRefresh($which,$size) true
		}
	}
}


proc unregisterPieceSize {size} {
	variable PieceSizeDict

	if {[dict get [dict incr PieceSizeDict $size -1] $size] == 0} {
		foreach piece {wk wq wr wb wn wp bk bq br bb bn bp} {
			catch { image delete photo_Piece($piece,$size) }
		}
		catch { image delete photo_Square(white,$size) }
		catch { image delete photo_Square(black,$size) }
		dict unset PieceSizeDict $size
	}
}


proc registerSize {size} {
	registerBoardSize $size
	registerPieceSize $size
}


proc unregisterSize {size} {
	unregisterBoardSize $size
	unregisterPieceSize $size
}


proc findTexture {sub style name} {
	if {[string length $name] == 0} { return "" }
	set file [file join $::scidb::dir::user textures $sub $style $name]
	if {![file readable $file]} {
		set file [file join $::scidb::dir::share textures $sub $style $name]
	}
	return $file
}


proc loadTexture {which} {
	variable colors
	variable texture
	variable Texture

	switch $which {
		border	{ set value $colors(hint,border-tile); set subdir "tile" }
		window	{ set value $colors(hint,background-tile); set subdir "tile" }
		lite		{ variable square::style; set value $style(lite,texture); set subdir "lite" }
		dark		{ variable square::style; set value $style(dark,texture); set subdir "dark" }
		white		{ variable piece::style; set value $style(color,w,texture); set subdir "lite" }
		black		{ variable piece::style; set value $style(color,b,texture); set subdir "dark" }
	}

	if {$texture($which) ne $value} {
		if {[string length $value] == 0} {
			set texture($which) ""
		} else {
			set path [findTexture $subdir {*}$value]

			if {![info exists Texture($path)]} {
				if {[catch { set Texture($path) [image create photo -file $path] } msg]} {
					set message [format "[set mc::CannotReadFile]:" $path]
					append message " (" $msg ")"
					::log::error $mc::ThemeManagement $message

					switch $which {
						border	{ set colors(hint,border-tile) "" }
						window	{ set colors(hint,background-tile) "" }
						lite		{ variable square::style; set style(lite,texture) "" }
						dark		{ variable square::style; set style(dark,texture) "" }
						white		{ variable piece::style; set style(color,w,texture) "" }
						black		{ variable piece::style; set style(color,b,texture) "" }
					}

					set texture($which) ""
					return ""
				}
			}

			set texture($which) $Texture($path)
		}
	}

	return $texture($which)
}


proc loadImage {file dst} {
	variable texture

	set tex [image create photo -file $file]
	set w [min [image width $dst] [image width $tex]]
	set h [min [image height $dst] [image height $tex]]
	::scidb::tk::image copy $tex $dst -from 0 0 $w $h
	image delete $tex
}


proc addPreferences {liteList darkList} {
	variable square::preferences

	foreach {lcat ltex} $liteList {
		foreach {dcat dtex} $darkList {
			set lite [list lite $lcat $ltex]
			set dark [list dark $dcat $dtex]
			lappend preferences($dark) $lite
			lappend preferences($lite) $dark
		}
	}
}


proc acquire {} {
	variable theme::style
	variable _theme
	variable texture
	variable _texture

	foreach which {colors layout effects hilite texture} {
		variable $which
		variable _$which

		array set _$which [array get $which]
	}

	set _theme $style(identifier)
	array set _texture [array get texture]

	foreach which {piece square theme} {
		variable ${which}::Working
		variable ${which}::_Working

		array set _Working [array get Working]
	}
}


proc release {} {
	variable theme::style
	variable theme::NameMap
	variable _theme
	variable texture
	variable _texture

	foreach which {colors layout effects hilite texture} {
		variable $which
		variable _$which

		array set $which [array get _$which]
	}

	foreach which {piece square theme} {
		variable ${which}::Working
		variable ${which}::_Working

		array set Working [array get _Working]
	}

	if {[dict exists $NameMap $_theme]} {
		setTheme [dict get $NameMap $_theme]
	}

	foreach which {window border} {
		if {$texture($which) ne $_texture($which)} {
			loadTexture $which
		}
	}
}


proc apply {} {
	variable texture
	variable _texture

	array set _texture [array get texture]
}


proc reset {} {
	release
	loadTexture window
	loadTexture border
	apply
}


proc setPieceStyle {identifier {size all}} {
	variable piece::NameLookup
	variable piece::style

	set identifier [dict get $NameLookup $identifier]

	if {$style(identifier) ne $identifier} {
		variable theme::style

		if {![FindTheme $style(square-style) $identifier $style(piece-set)]} {
			ChangeToWorkingSet
			variable theme::style
			set style(piece-style) $identifier
			set style(Modified) true
		}

		SetPieceStyle $identifier $size
	}
}


proc setSquareStyle {identifier {size all}} {
	variable square::NameLookup
	variable square::style
	variable colors

	set identifier [dict get $NameLookup $identifier]

	if {$style(identifier) ne $identifier} {
		variable theme::style

		if {![FindTheme $identifier $style(piece-style) $style(piece-set)]} {
			ChangeToWorkingSet
			variable theme::style
			set style(square-style) $identifier
			set style(Modified) true
		}

		SetSquareStyle $identifier $size
	}
}


proc setPieceSet {identifier {size all}} {
	variable theme::style
	variable needRefresh

	if {$style(piece-set) eq $identifier} { return }

	if {![FindTheme $style(square-style) $style(piece-style) $identifier]} {
		ChangeToWorkingSet
		variable theme::style
		set style(piece-set) $identifier
		set style(Modified) true
	}

	set needRefresh(piece,$size) true
	set needRefresh(white,$size) true
	set needRefresh(black,$size) true
	setupPieces $size
}


proc setTheme {identifier {size all}} {
	variable theme::StyleDict
	variable theme::NameLookup
	variable theme::style
	variable needRefresh
	variable currentTheme

	set identifier [dict get $NameLookup $identifier]
	set currentTheme $identifier
	if {$style(identifier) eq $identifier} { return }
	array set current [array get style]
	upvar 0 [dict get $StyleDict $identifier] [namespace current]::theme::style
	variable theme::style
	set pieceSetChanged false

	if {$style(piece-set) ne $current(piece-set)} {
		set pieceSetChanged true
	}

	if {[isWorkingSet square] || $style(square-style) ne $current(square-style)} {
		SetSquareStyle $style(square-style) $size
	}

	if {[isWorkingSet piece] || $style(piece-style) ne $current(piece-style)} {
		SetPieceStyle $style(piece-style) $size
	} elseif {$pieceSetChanged} {
		set needRefresh(piece,$size) true
		set needRefresh(white,$size) true
		set needRefresh(black,$size) true
		setupPieces $size
	}
}


proc setupTheme {{identifier {}}} {
	variable theme::StyleDict
	variable theme::NameLookup
	variable theme::style
	variable currentTheme
	variable defaultId

	if {[llength $identifier] == 0} {
		if {![dict exists $StyleDict $currentTheme]} {
			::log::error $mc::ThemeManagement [format $mc::ThemeIsUndefined $currentTheme]
			set currentTheme $defaultId
		}
		set identifier $currentTheme
	} else {
		set currentTheme $identifier
	}

	array set current [array get style]
	upvar 0 [dict get $StyleDict $identifier] [namespace current]::theme::style
	variable theme::style
	set pieceSetChanged false

	if {$style(piece-set) ne $current(piece-set)} {
		set pieceSetChanged true
	}

	if {[isWorkingSet square] || $style(square-style) ne $current(square-style)} {
		SetSquareStyle $style(square-style)
	}

	if {[isWorkingSet piece] || $style(piece-style) ne $current(piece-style)} {
		SetPieceStyle $style(piece-style)
	}
}


proc selectStyle {identifier {which theme}} {
	variable ${which}::StyleDict
	upvar 0 [dict get $StyleDict $identifier] [namespace current]::${which}::style
}


proc currentStyle {which} {
	variable ${which}::NameMap
	variable ${which}::style

	return [dict get $NameMap $style(identifier)]
}


proc mapToName {identifier {which theme}} {
	variable ${which}::NameLookup
	return [lindex [split [dict get $NameLookup $identifier] |] 0]
}


proc mapToLongId {identifier {which theme}} {
	variable ${which}::NameLookup
	variable defaultId

	if {$identifier eq $::mc::Default} {
		set identifier $defaultId
	} elseif {$identifier eq $mc::WorkingSet} {
		set identifier $workingSetId
	}
	return [dict get $NameLookup $identifier]
}


proc mapToShortId {identifier {which theme}} {
	variable ${which}::NameMap
	return [dict get $NameMap $identifier]
}


proc filename {identifier {which theme}} {
	variable ${which}::StyleDict
	variable ${which}::NameLookup

	upvar 0 [dict get $StyleDict [dict get $NameLookup $identifier]] style
	return $style(Filename)
}


proc acquireWorkingSet {{which theme}} {
	PushWorkingSet $which
	PushWorkingSet $which
}


proc releaseWorkingSet {{which theme}} {
	PopWorkingSet $which
	PopWorkingSet $which
}


proc resetWorkingSet {{which theme}} {
	PopWorkingSet $which
	PushWorkingSet $which
}


proc changeWorkingSet {{which theme}} {
	variable ${which}::Stack
	variable ${which}::Working

	foreach {key val} [lindex $Stack 0] {
		if {[string is lower [string index $key 0]]} {
			if {$val != $Working($key)} {
				set Working(Modified) true
			}
		}
	}

	lset Stack 0 [array get Working]
}


proc workingSetIsModified {{which theme}} {
	return [set ${which}::Working(Modified)]
}


proc isWorkingSet {{which theme}} {
	variable ${which}::style
	variable ${which}::Working
	variable workingSetId

	return [expr {$workingSetId eq $style(identifier)}]
}


proc copyToWorkingSet {{which theme}} {
	variable ${which}::Working
	variable ${which}::StyleDict
	variable ${which}::style
	variable workingSetId

	array set Working [array get style]

	set Working(identifier)	$workingSetId
	set Working(Modified)	false
	set Working(Filename)	{}

	upvar 0 Working [namespace current]::${which}::style
	ChangeToWorkingSet
}


proc prepareNameLists {} {
	BuildNameList theme
	BuildNameList piece
	BuildNameList square
}


proc setTile {canv which {wd 0} {ht 0}} {
	variable texture
	variable colors
	variable Tile

	if {[llength $texture($which)] == 0} { return }

	switch $which {
		border { set what border }
		window { set what background }
	}

	set rotation $colors(hint,$what-rotation)
	set tile ""

	if {[info exists Tile($which:texture)]} {
		if {$Tile($which:texture) eq $texture($which) && $Tile($which:rotation) == $rotation} {
			set tile $Tile($which:tile)
		} else {
			image delete $Tile($which:tile)
			array unset Tile $which:*
		}
	}

	if {$rotation == 0} {
		set tile $texture($which)
	} elseif {[string length $tile] == 0} {
		set w [image width $texture($which)]
		set h [image height $texture($which)]
		if {$rotation != 180} { set tmp $w; set w $h; set h $tmp }
		set img [image create photo -width $w -height $h]
		::scidb::tk::image copy $texture($which) $img -rotate [expr {$rotation/90}]
		set Tile($which:img) $texture($which)
		set Tile($which:tile) $img
		set Tile($which:rotation) $rotation
		set tile $img
		$canv delete tile
	}

	set ih [image height $tile]
	set iw [image width $tile]
	set ch [expr {$ht ? $ht : [winfo height $canv]}]
	set cw [expr {$wd ? $wd : [winfo width $canv]}]

	for {set x 0} {$x < $cw} {incr x $iw} {
		for {set y 0} {$y < $ch} {incr y $ih} {
			if {[llength [$canv find withtag tile:$x:$y]] == 0} {
				$canv create image $x $y -anchor nw -image $tile -tags [list tile tile:$x:$y]
			}
		}
	}
}


proc setBackground {canv which {wd 0} {ht 0}} {
	variable colors
	variable texture

	switch $which {
		border { set what border }
		window { set what background }
	}

	set tile $colors(hint,$what-tile)
	$canv delete tile

	if {[llength $tile] == 0} {
		loadTexture $which
	} else {
		if {[llength [loadTexture $which]] == 0} { return 0 }
		setTile $canv $which $wd $ht
		$canv lower tile
	}

	return 1
}


proc removeStyle {shortId {which theme}} {
	variable ${which}::StyleDict
	variable ${which}::NameLookup
	variable ${which}::NameMap
	variable ${which}::NameOrder
	variable ${which}::style

	if {$which eq "theme"} {
		variable Referees

		foreach what {piece-style square-style} {
			set identifier $style($what)
			set n [lsearch -exact $Referees($identifier) $shortId]
			set Referees($identifier) [lreplace $Referees($identifier) $n $n]
		}
	}

	set longId [dict get $NameLookup $shortId]
	set StyleDict [dict remove $StyleDict $longId]

	set index [lsearch -exact $NameOrder $longId]
	if {$index >= 0} { set NameOrder [lreplace $NameOrder $index $index] }

	# rebild maps
	set NameLookup [dict create]
	set NameMap [dict create]
	foreach key [dict keys $StyleDict] { UpdateMaps $which $key }

	BuildNameList $which
}


proc referees {which identifier} {
	variable Referees
	variable ${which}::NameLookup

	set longId [dict get $NameLookup $identifier]
	if {[info exists Referees($longId)]} { return $Referees($longId) }
	return {}
}


proc reorder {orderedList {which theme}} {
	variable ${which}::NameOrder
	variable ${which}::NameLookup

	set NameOrder {}
	foreach name $orderedList { lappend NameOrder [dict get $NameLookup $name] }
	BuildNameList $which
}


proc addStyle {which style} {
	variable ${which}::StyleDict
	variable ${which}::NameLookup
	variable ${which}::Working
	variable ${which}::Default
	variable ::load::currentFile

	lappend style Filename $currentFile Modified false
	set var [namespace current]::${which}::Style[dict size $StyleDict]
	array set $var [array get Default]
	array set $var $style
	upvar 0 $var arr

	# check consistency
	foreach {key value} [array get Working] {
		if {[string is lower [string index $key 0]]} {
			set tmp $arr($key)
		}
		if {$key eq "identifier" && [dict exists $NameLookup $tmp]} {
			::log::error $mc::ThemeManagement [format $mc::FileWillBeIgnored $currentFile]
			return ""
		}
	}
	if {$which eq "theme"} {
		foreach what {piece square} {
			variable ${what}::NameMap
			if {![dict exists $NameMap $arr($what-style)]} {
				::log::error \
					$mc::ThemeManagement \
					[format $mc::IsCorrupt $currentFile $what $arr($what-style)]
				set StyleDict [dict remove $StyleDict $arr(identifier)]
				return ""
			}
		}
	}

	dict set StyleDict $arr(identifier) $var
	set shortId [UpdateMaps $which $arr(identifier)]

	if {$which eq "theme"} {
		variable Referees

		lappend Referees($arr(piece-style)) $shortId
		lappend Referees($arr(square-style)) $shortId
	}

	return $shortId
}


proc setup {} {
	prepareNameLists
	setupTheme
}


proc makeUniqueKey {name} {
	return "$name|[clock milliseconds]|[info hostname]|$::tcl_platform(user)"
}


proc saveWorkingSet {name {which theme}} {
	variable ${which}::Working
	variable ::load::currentFile

	set Working(Modified) false
	set name [regsub -all {[|]} $name "_"]
	set fname [regsub -all {[|/\\~\"*.:<>?\000-\039]} $name "_"]
	set filename [file join $::scidb::dir::user themes [expr {$which eq "theme" ? "" : $which}] $fname]

	if {[file exists "$filename.dat"]} {
		set n 2
		while {[file exists "$filename-$n.dat"]} { incr n }
		set filename "$filename-$n"
	}
	set filename "$filename.dat"

	array set style [array get Working]
	set style(identifier) [makeUniqueKey $name]
	set style(Modified) false
	set style(Filename) $filename
	set currentFile $filename
	if {$which eq "square"} {
		variable colors
		foreach attr {	background-color background-coords background-tile \
							border-color border-coords border-tile} {
			set style(hint,$attr) $colors(hint,$attr)
		}
	}
	set arr [array get style]
	set identifier [addStyle $which $arr]
	BuildNameList $which

	set chan [open $style(Filename) a]
	puts $chan "::board::addStyle $which {"
	::options::writeArray $chan $arr
	puts $chan "}"
	close $chan

	return $identifier
}


proc RefreshSquare {which size} {
	variable square::style
	variable texture

	set iw [image width $texture($which)]
	set ih [image height $texture($which)]
	set x1 $style($which,x1)
	set x2 $style($which,x2)
	set y1 $style($which,y1)
	set y2 $style($which,y2)

	if {$x2 > $iw} { set x2 $iw }
	if {$y2 > $ih} { set y2 $ih }
	if {$x2 - $x1 > $y2 - $y1} { set x2 [expr {$x1 + $y2 - $y1}] }
	if {$y2 - $y1 > $x2 - $x1} { set y2 [expr {$y1 + $x2 - $x1}] }

	::scidb::tk::image copy $texture($which) photo_Square($which,$size) \
		-from $x1 $y1 $x2 $y2 \
		-rotate [expr {$style($which,rotation)/90}]
	photo_Square($which,$size) copy photo_Borderline($size)
}


proc RefreshBorder {size} {
	variable square::style

	::scidb::tk::image border photo_Borderline($size) \
		-gap				[computeGap $size] \
		-bordercolor	$style(borderline,color) \
		-width			[expr {int(round($style(borderline,width)*$size + 0.2))}] \
		-opacity			[expr {$style(borderline,opacity)/255.0}]
}


proc ChangeToWorkingSet {} {
	variable theme::Working
	variable theme::style
	variable currentTheme
	variable workingSetId

	set currentTheme $workingSetId
	set Working(piece-style) $style(piece-style)
	set Working(square-style) $style(square-style)
	set Working(piece-set) $style(piece-set)

	upvar 0 [namespace current]::theme::Working [namespace current]::theme::style
}


proc BuildNameList {which} {
	variable ${which}::NameMap
	variable ${which}::NameLookup
	variable ${which}::NameOrder
	variable ${which}::Working
	variable ${which}::Default
	variable ${which}::styleNames
	variable defaultId
	variable workingSetId

	set nameList {}
	set idList {}
	dict for {key var} $NameMap {
		if {$key ne $workingSetId && $key ne $defaultId} {
			lappend nameList $var
		}
	}
	set nameList [lsort -dictionary $nameList]
	foreach name $nameList { lappend idList [dict get $NameLookup $name] }
	set orderedList {}

	set count 100000
	foreach id $idList {
		set order($id) $count
		incr count
	}

	set count 0
	foreach id $NameOrder {
		set order($id) $count
		incr count
	}

	foreach name $idList { lappend orderedList $order($name) }
	set indices [lsort -dictionary -integer -indices $orderedList]
	set styleNames [list $mc::WorkingSet $::mc::Default]
	foreach index $indices { lappend styleNames [lindex $nameList $index] }
}


proc SetSquareStyle {identifier {size all}} {
	variable square::StyleDict
	variable square::style
	variable texture
	variable needRefresh

	if {![dict exists $StyleDict $identifier]} {
		::log::error $mc::ThemeManagement [format $mc::SquareStyleIsUndefined $identifier]
		return
	}

	upvar 0 [dict get $StyleDict $identifier] [namespace current]::square::style
	variable square::style

	foreach which {lite dark} {
		if {[llength $style($which,texture)]} {
			if {$texture($which) ne $style($which,texture)} {
				set path [findTexture $which {*}$style($which,texture)]

				if {[file readable $path]} {
					loadTexture $which
				} else {
					set style($which,texture) {}
				}
			}
		}

		if {[llength $style($which,texture)] == 0} {
			loadTexture $which
		}
	}

	set needRefresh(lite,$size) true
	set needRefresh(dark,$size) true
	setupSquares $size
}


proc SetPieceStyle {identifier {size all}} {
	variable piece::StyleDict
	variable needRefresh

	if {![dict exists $StyleDict $identifier]} {
		::log::error $mc::ThemeManagement [format $mc::PieceStyleIsUndefined $identifier]
		return
	}

	upvar 0 [dict get $StyleDict $identifier] [namespace current]::piece::style
	set needRefresh(piece,$size) true
	variable piece::style

	if {[llength $style(color,w,texture)]} {
		set path [findTexture lite {*}$style(color,w,texture)]

		if {[file readable $path]} {
			loadTexture white
			set needRefresh(white,$size) true
		} else {
			set style(color,w,texture) {}
			set style(color,w,fill) $Default(color,w,fill)
		}
	}
	if {[llength $style(color,b,texture)]} {
		set path [findTexture dark {*}$style(color,b,texture)]

		if {[file readable $path]} {
			loadTexture black
			set needRefresh(black,$size) true
		} else {
			set style(color,b,texture) {}
			set style(color,b,fill) $Default(color,b,fill)
		}
	}

	setupPieces $size
}


proc FindTheme {squareStyle pieceStyle pieceSet} {
	variable theme::NameLookup
	variable theme::Working
	variable theme::StyleDict
	variable theme::style
	variable workingSetId

	set identifier $style(identifier)

	foreach id [dict values $NameLookup] {
		if {$id ne $workingSetId} {
			upvar 0 [dict get $StyleDict $id] [namespace current]::theme::style
			variable theme::style

			if {	$style(piece-set) eq $pieceSet
				&& $style(square-style) eq $squareStyle
				&& $style(piece-style) eq $pieceStyle} {
				return true
			}
		}
	}

	upvar 0 [dict get $StyleDict $identifier] [namespace current]::theme::style

	return false
}


proc PushWorkingSet {which} {
	variable ${which}::Stack
	variable ${which}::Working

	lappend Stack [array get Working]
}


proc PopWorkingSet {which} {
	variable ${which}::Stack
	variable ${which}::Working

	if {[llength $Stack]} {
		array set Working [lindex $Stack end]
		set Stack [lreplace $Stack end end]
	}
}


proc UpdateMaps {which longId} {
	variable ${which}::NameLookup
	variable ${which}::NameMap

	lassign [split $longId |] shortID timestamp
	set identifier $shortID
	set count 2
	set entries {}

	while {[dict exists $NameLookup $identifier]} {
		set lid [dict get $NameLookup $identifier]
		lassign [split $lid |] sid time
		lappend entries [list $lid $time $sid]
		set identifier "$shortID ($count)"
		incr count
	}

	if {[llength $entries]} {
		foreach entry $entries {
			lassign $entry lid time sid
			set NameLookup [dict remove $NameLookup $sid]
			set NameMap [dict remove $NameMap $lid]
		}
		lappend entries [list $longId $timestamp]
		set orderedList [lsort -index 1 $entries]
		set count 0
		foreach entry $orderedList {
			set lid [lindex $entry 0]
			set sid $shortID
			if {[incr count] >= 2} { set sid "$sid ($count)" }
			dict set NameLookup $sid $lid
			dict set NameMap $lid $sid
		}
	} else {
		dict set NameLookup $identifier $longId
		dict set NameMap $longId $identifier
	}

	return $identifier
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::currentTheme
	foreach what {theme piece square} {
		::options::writeItem $chan [namespace current]::${what}::Working
	}
	foreach what {effects hilite colors layout} {
		::options::writeItem $chan [namespace current]::$what
	}
}


proc MakeBorderlines {} {
	set sw [winfo screenwidth .]
	set sh [winfo screenheight .]

	set alpha0 0.45
	set alpha1 0.35
	set alpha2 0.25

	foreach n {0 1 2} {
		image create photo photo_Borderline(horz,lite,$n) -width $sw -height 1
		image create photo photo_Borderline(horz,dark,$n) -width $sw -height 1
		image create photo photo_Borderline(vert,lite,$n) -width 1 -height $sh
		image create photo photo_Borderline(vert,dark,$n) -width 1 -height $sh

		::scidb::tk::image recolor #ffffff photo_Borderline(horz,lite,$n) -composite set
		::scidb::tk::image recolor #ffffff photo_Borderline(vert,lite,$n) -composite set
		::scidb::tk::image recolor #000000 photo_Borderline(horz,dark,$n) -composite set
		::scidb::tk::image recolor #000000 photo_Borderline(vert,dark,$n) -composite set

		::scidb::tk::image alpha [set alpha$n] photo_Borderline(horz,lite,$n)
		::scidb::tk::image alpha [set alpha$n] photo_Borderline(vert,lite,$n)
		::scidb::tk::image alpha [set alpha$n] photo_Borderline(horz,dark,$n)
		::scidb::tk::image alpha [set alpha$n] photo_Borderline(vert,dark,$n)
	}
}


# Setup
MakeBorderlines


# check background tiles
if {[llength $square::Default(hint,background-tile)]} {
	set file [board::findTexture tile {*}$square::Default(hint,background-tile)]
	if {![file readable $file]} {
		::log::error $mc::Setup [format $mc::CannotFindFile $file]
		set square::Default(hint,background-tile) {}
	}
}
if {[llength $colors(user,background-tile)]} {
	set file [board::findTexture tile {*}$colors(user,background-tile)]
	if {![file readable $file]} {
		::log::error $mc::Setup [format $mc::CannotFindFile $file]
		set colors(user,background-tile) {}
	}
}
if {[llength $colors(hint,background-tile)]} {
	set file [board::findTexture tile {*}$colors(hint,background-tile)]
	if {![file readable $file]} {
		::log::error $mc::Setup [format $mc::CannotFindFile $file]
		set colors(hint,background-tile) {}
	}
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace board

# vi:set ts=3 sw=3:
