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

::util::source board-texture-dialog

namespace eval board {
namespace eval texture {

namespace eval mc { set PreselectedOnly "Preselected only" }

variable preferredOnly 1

array set Browser {
	size		50
	cols		5
	rows		5
	count		0
	space		5
	border	2
	delay		10
	time		0
	list		{}
	files		{}
	current	{}
	other		{}
	frame		{}

	afterId,texture	{}
	afterId,key			{}
}

set Browser(incr) [expr {$Browser(size) + 2*$Browser(space)}]

namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::max
namespace import [namespace parent]::findTexture

namespace export openBrowser buildBrowser forgetTextures getTexture makePopup popup popdown


proc SetScrollRegion {canv} {
	variable Browser

	set height [expr {($Browser(row) + 1)*$Browser(incr)}]
	$canv configure -scrollregion [list 0 0 [$canv cget -width] $height]
}


proc MakeVisible {canv} {
	variable Browser

	set topFraction [lindex [$canv yview] 0]
	set first [expr int(($topFraction + 0.00001)*($Browser(row) + 1))]
	set last [expr {$first + $Browser(nrows) - 1}]

	if {$Browser(cury) < $first} {
		$canv yview scroll [expr {$Browser(cury) - $first}] units
	} elseif {$last < $Browser(cury)} {
		$canv yview scroll [expr {$Browser(cury) - $last}] units
	}
}


proc Reload {canv which} {
	variable Browser

	$canv delete all
	after cancel $Browser(afterId,texture)
	set Browser(row) 0
	set Browser(col) 0
	LoadTextures $canv $which $Browser(files)
}


proc Configure {canv which w h} {
	variable Browser

	set nrows [expr {$h/$Browser(incr)}]
	set ncols [expr {$w/$Browser(incr)}]

	if {$nrows == 0 || $ncols == 0} { return }

	if {$ncols != $Browser(ncols)} {
		set count [expr {$Browser(cury)*$Browser(ncols) + $Browser(curx)}]
		set Browser(ncols) $ncols
		set Browser(nrows) $nrows
		set Browser(row) 0
		set Browser(col) 0
		set Browser(cury) [expr {$count/$ncols}]
		set Browser(curx) [expr {$count%$ncols}]
		SetScrollRegion $canv
		Reload $canv $which
	} elseif {$nrows != $Browser(nrows)} {
		set Browser(nrows) $nrows
		SetScrollRegion $canv
		MakeVisible $canv
	}
}


proc Move {canv ydir xdir} {
	variable Browser

	set row [expr {$Browser(cury) + $ydir}]
	set col [expr {$Browser(curx) + $xdir}]

	if {$ydir > 1} {
		set row [min $row $Browser(row)]

		if {$row == $Browser(row) && $col >= $Browser(col)} {
			incr row -1
		}
	}
	if {$ydir < 1} {
		set row [max 0 $row]
	}
	if {$xdir == 1 && $col >= $Browser(ncols)} {
		set col 0
		incr row 1
	}
	if {$xdir == -1 && $col == -1} {
		set col $Browser(ncols)
		incr row -1
		incr col -1
	}

	if {	(0 <= $row && 0 <= $col)
		&& (	($row < $Browser(row) && $col < $Browser(ncols))
			|| ($row == $Browser(row) && $col < $Browser(col)))} {
		$canv itemconfigure "hi:$Browser(cury):$Browser(curx)" -state hidden
		set Browser(curx) $col
		set Browser(cury) $row
		$canv itemconfigure "hi:$Browser(cury):$Browser(curx)" -state normal
		MakeVisible $canv
	}
}


proc popdown {} {
	update idletasks
	::tooltip::tooltip on
	catch { wm withdraw .board_texture_popup }
}


proc popup {w xc yc} {
	::tooltip::tooltip off
	set dx [expr {[$w.texture cget -width] + 4}]
	set dy [expr {[$w.texture cget -height] + 4}]
	if {($xc + $dx) > [winfo workareawidth $w]} {
		set xc [expr {[winfo workareawidth $w] - $dx}]
	}
	if {($yc + $dy) > [winfo screenheight $w]} {
		set yc [expr {[winfo screenheight $w] - $dy}]
	}
	wm geometry $w "+$xc+$yc"
	wm attributes $w -topmost
	update idletasks ;# help shadow package
	wm deiconify $w
}


proc makePopup {} {
	set w .board_texture_popup
	if {[winfo exists $w]} { return $w }

	tk::toplevel $w -class TooltipPopup -relief raised -borderwidth 1
	wm withdraw $w
	wm overrideredirect $w 1
	tk::canvas $w.texture
	pack $w.texture
	$w.texture create image 0 0 -anchor nw -tag img
	$w.texture create rectangle 0 0 1 1 -tags {view dark} -state hidden -width 1 -outline black
	$w.texture create rectangle 0 0 1 1 -tags {view lite} -state hidden -width 1 -outline white
	return $w
}


proc ShowTexture {canv {file {}} {row 0} {col 0} {xc 0} {yc 0}} {
	variable Browser

	set w [makePopup]

	if {$file == ""} {
		set col $Browser(curx)
		set row $Browser(cury)
		lassign [$canv bbox "tex:$row:$col"] x1 y1 x2 y2
		set topFraction [lindex [$canv yview] 0]
		set first [expr int(($topFraction + 0.00001)*($Browser(row) + 1))]
		set xc [expr {[winfo rootx $canv] + $x1 + ($x2 - $x1)/2}]
		set yc [expr {[winfo rooty $canv] - $first*$Browser(incr) + $y1 + ($y2 - $y1)/2}]
		set file [lindex $Browser(files) [expr {$row*$Browser(ncols) + $col}]]
	} else {
		incr xc 5
		incr yc 5
	}

	catch { image delete $Browser(image) }
	if {[catch { set Browser(image) [image create photo -file $file] }]} { return }
	$w.texture configure -height [image height $Browser(image)] -width [image width $Browser(image)]
	$w.texture itemconfigure img -image $Browser(image)
	$w.texture itemconfigure view -state hidden
	popup $w $xc $yc
}


proc SelectCurrent {} {
	variable Browser
	SendResult [lindex $Browser(files) [expr {$Browser(cury)*$Browser(ncols) + $Browser(curx)}]]
}


proc SelectTexture {canv row col file} {
	variable Browser

	$canv itemconfigure "hi:$Browser(cury):$Browser(curx)" -state hidden
	$canv itemconfigure "hi:$row:$col" -state normal
	set Browser(cury) $row
	set Browser(curx) $col
	set Browser(result) $file
	SendResult $file
}


proc SendSelected {} {
	variable Browser

	if {[llength $Browser(result)]} {
		SendResult $Browser(result)
	} elseif {[llength $Browser(hilite)]} {
		SendResult $Browser(hilite)
	}
}


proc SendResult {file} {
	variable Browser

	set result [list [lrange [file split $file] end-1 end]]
	lappend result $Browser(rotation)
	event generate $Browser(recv) <<BrowserSelect>> -data $result
}


proc LoadTextures {canv which files} {
	variable Browser

	set border $Browser(border)
	set size $Browser(size)
	set loop true

	while {1} {
		if {[llength $files] == 0} { return }

		set file [lindex $files 0]
		set files [lreplace $files 0 0]

		if {![file exists $file]} {
			set index [lsearch -exact $Browser(files) "$file"]
			set Browser(files) [lreplace $Browser(files) $index $index]
			continue
		}

		if {![info exists Browser(texture,$file)]} {
			set Browser(texture,$file) [image create photo -width $size -height $size]
			if {[catch { [namespace parent]::loadImage $file $Browser(texture,$file) }]} {
				set index [lsearch -exact $Browser(files) "$file"]
				set Browser(files) [lreplace $Browser(files) $index $index]
				image delete $Browser(texture,$file)
				unset Browser(texture,$file)
				continue
			}
			lappend Browser(list) $Browser(texture,$file)
			set loop false
		}
	
		if {$Browser(col) == $Browser(ncols)} {
			set Browser(col) 0
			incr Browser(row)
		}

		set row $Browser(row)
		set col $Browser(col)
		set x [expr {$col*$Browser(incr) + $Browser(space)}]
		set y [expr {$row*$Browser(incr) + $Browser(space)}]
		set hilite [expr {$file eq $Browser(hilite)}]
	
		$canv create rectangle \
			[expr {$x - $border}] [expr {$y - $border}] \
			[expr {$x + $size + $border + 1}] [expr {$y + $size + $border + 1}] \
			-fill [$canv cget -background] \
			-width 0
		$canv create rectangle \
			[expr {$x - $border}] [expr {$y - $border}] \
			[expr {$x + $size + $border}] [expr {$y + $size + $border}] \
			-fill "white" \
			-width 0
		$canv create rectangle \
			[expr {$x}] [expr {$y}] \
			[expr {$x + $size + $border}] [expr {$y + $size + $border}] \
			-fill "black" \
			-width 0
		if {$hilite} {
			$canv create rectangle \
				[expr {$x - $border}] [expr {$y - $border}] \
				[expr {$x + $size + $border + 2}] [expr {$y + $size + $border + 2}] \
				-outline "red3" \
				-width 2
		}
		$canv create rectangle \
			[expr {$x - $border - 1}] [expr {$y - $border - 1}] \
			[expr {$x + $size + $border + 3}] [expr {$y + $size + $border + 3}] \
			-outline "black" \
			-width 2 \
			-state hidden \
			-tag "hi:$row:$col"
		$canv create image $x $y \
			-image $Browser(texture,$file) \
			-anchor nw \
			-tag "tex:$row:$col"
		$canv bind "tex:$row:$col" <ButtonPress-1> \
			[namespace code [list SelectTexture $canv $row $col $file]]
		$canv bind "tex:$row:$col" <Double-1> [list destroy [winfo toplevel $canv]]
		$canv bind "tex:$row:$col" <ButtonPress-2> \
			[namespace code [list ShowTexture $canv "$file" $row $col %X %Y]]
		$canv bind "tex:$row:$col" <ButtonPress-3> \
			[namespace code [list ShowTexture $canv "$file" $row $col %X %Y]]
		bind $canv <ButtonPress-1>   [namespace code { popdown }]
		bind $canv <ButtonRelease-2> [namespace code { popdown }]
		bind $canv <ButtonRelease-3> [namespace code { popdown }]
		::tooltip::tooltip $canv -item "tex:$row:$col" "$file"

		if {$Browser(col) == 0} {
			SetScrollRegion $canv
		}
		if {$Browser(col) == $Browser(curx) && $Browser(row) == $Browser(cury) && [focus] == $canv} {
			$canv itemconfigure "hi:$Browser(row):$Browser(col)" -state normal
			MakeVisible $canv
		}
		incr Browser(col)

		if {!$loop} {
			set Browser(afterId,texture) \
				[after $Browser(delay) [namespace code [list LoadTextures $canv $which $files]]]
			return
		}
	}
}


proc FindTextures {canv which} {
	variable [namespace parent]::square::preferences
	variable preferredOnly
	variable Browser

	if {$preferredOnly && [info exists preferences($Browser(other))]} {
		set Browser(files) {}

		foreach {parts} $preferences($Browser(other)) {
			lappend Browser(files) [file join $::scidb::dir::share textures {*}$parts]
		}

		set Browser(files) [lsort -dictionary $Browser(files)]
	} else {
		set Browser(files) {}

		foreach cat [set [namespace parent]::square::texSubDirs] {
			set dir [file join $::scidb::dir::share textures $which $cat]
			set files [glob -directory $dir -nocomplain *.jpg *.png *.gif]
			set dir [file join $::scidb::dir::user textures $which $cat]
			lappend files {*}[glob -directory $dir -nocomplain *.jpg *.png *.gif]
			lappend Browser(files) {*}[lsort -dictionary $files]
		}
	}

	set Browser(curx) 0
	set Browser(cury) 0

	Reload $canv $which
}


proc Focus {canv state} {
	variable Browser
	$canv itemconfigure "hi:$Browser(cury):$Browser(curx)" -state $state
}


proc openBrowser {parent which currentTexture {otherTexture {}} {rotation {}} {place center}} {
	variable Browser

	set dlg [tk::toplevel $parent.select_texture -class Scidb]
	bind $dlg <Escape> [list destroy $dlg]
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	set browser \
		[buildBrowser $top $dlg $which $Browser(rows) $Browser(cols) $currentTexture $otherTexture]
	set Browser(recv) $parent
	set Browser(rotation) $rotation

	if {[string is integer -strict $rotation]} {
		set rot [::ttk::frame $top.rot -takefocus 0]
		ttk::label $rot.lrot -textvar [namespace parent]::piece::mc::Rotate
		set col 3
		foreach deg {0 90 180 270} {
			set Browser($deg,$which) [ttk::checkbutton $rot.b$deg \
				-text "$deg°" \
				-variable [namespace current]::Browser(rotation) \
				-onvalue $deg \
				-command [namespace code SendSelected] \
			]
			grid $rot.b$deg -row 1 -column $col
			incr col 2
		}

		grid $rot.lrot -row 1 -column 1
		grid rowconfigure $rot {0 2} -minsize $::theme::pady
		grid columnconfigure $rot {0 2 4 6 8 10} -minsize $::theme::padx
		grid $rot -row 1 -column 0 -sticky w
	}
		
	widget::dialogButtons $dlg close
	$dlg.close configure -command [list destroy $dlg]

	if {[winfo viewable [winfo toplevel $parent]]} {
		wm transient $dlg $parent
	}
	wm iconname $dlg ""
	wm title $dlg "$::scidb::app: $::mc::Texture"
	wm protocol $dlg WM_DELETE_WINDOW "destroy $dlg"
	wm withdraw $dlg
	wm grid $dlg $Browser(ncols) $Browser(nrows) $Browser(incr) $Browser(incr)
	wm minsize $dlg 4 1
	::util::place $dlg -parent $parent -position $place
	wm deiconify $dlg
	focus $browser
	ttk::grabWindow $dlg
	tkwait window $dlg
	ttk::releaseGrab $dlg

	set Browser(rows) $Browser(nrows)
	set Browser(cols) $Browser(ncols)

	if {$Browser(rotation) ne $rotation} {
		set Browser(result) $currentTexture
	}

	return $Browser(result)
}


proc buildBrowser {w recv which nrows ncols currentTexture {otherTexture {}}} {
	variable [namespace parent]::square::preferences
	variable Browser

	if {[llength $otherTexture] && ($which eq "lite" || $which eq "dark")} {
		set otherTexture [list [expr {$which eq "lite" ? "dark" : "lite"}] {*}$otherTexture]
	}
	set Browser(other) $otherTexture
	set Browser(recv) $recv
	set Browser(nrows) $nrows
	set Browser(ncols) $ncols
	set Browser(frame) $w

	set width  [expr {$Browser(ncols)*$Browser(incr) + 1}]
	set height [expr {$Browser(nrows)*$Browser(incr) + 1}]
	set provideSwitch [expr {[llength $Browser(other)] && [info exists preferences($Browser(other))]}]

	tk::canvas $w.container \
		-borderwidth 2 \
		-relief groove \
		-takefocus 1 \
		-cursor left_ptr \
		-yscrollcommand "$w.vsb set" \
		-yscrollincrement $Browser(incr) \
		-scrollregion [list 0 0 $width $height] \
		-width $width \
		-height $height
	ttk::scrollbar $w.vsb -orient vertical -command "$w.container yview"
	if {$provideSwitch} {
		ttk::checkbutton $w.preferredOnly \
			-textvar [namespace current]::mc::PreselectedOnly \
			-variable [namespace current]::preferredOnly \
			-command "[namespace current]::FindTextures $w.container $which"
	}
	
	bind $w.container <FocusIn>	[namespace code { Focus %W normal }]
	bind $w.container <FocusOut>	[namespace code { Focus %W hidden }]
	# NOTE: we have to use 'break', otherwise <space> will be sent afterwards (seems to be a Tk bug?!)
#	bind $w.container <Return>		[namespace code { SelectCurrent; break }]
	bind $w.container <space>		[namespace code { SelectCurrent }]
	bind $w.container <Up>			[namespace code { Move %W -1  0 }]
	bind $w.container <Down>		[namespace code { Move %W +1  0 }]
	bind $w.container <Left>		[namespace code { Move %W  0 -1 }]
	bind $w.container <Right>		[namespace code { Move %W  0 +1 }]
	bind $w.container <Next>		[namespace code { Move %W +[expr {$Browser(nrows) - 1}] 0 }]
	bind $w.container <Prior>		[namespace code { Move %W -[expr {$Browser(nrows) - 1}] 0 }]
	bind $w.container <Home>		[namespace code { Move %W -$Browser(cury) -$Browser(curx) }]
	bind $w.container <End>			[namespace code {
		Move %W [expr {$Browser(row) - $Browser(cury)}] [expr {$Browser(col) - $Browser(curx) - 1}]
	}]

#	bind $w.container <Tab>		[namespace code {
#		if {$Browser(curx) == $Browser(ncols) - 1} { Move %W +1 -$Browser(curx) } else { Move %W 0 +1 }
#	}]
#	bind $w.container <KeyPress-space> "
#		if {\$[namespace current]::Browser(time) != %t} {
#			[namespace current]::ShowTexture $w.container
#		} else {
#			after cancel \$[namespace current]::Browser(afterId,key)
#		}
#	"
#	bind $w.container <KeyRelease-space> "
#		set [namespace current]::Browser(time) %t
#		set [namespace current]::Browser(afterId,key) \[after idle { [namespace current]::popdown }\]
#	"

	grid $w.vsb -row 0 -column 1 -sticky nswe
	grid $w.container -row 0 -column 0 -sticky nsew -padx 0 -pady 0
	if {$provideSwitch} {
		grid $w.preferredOnly \
			-row 1 -column 0 -columnspan 2 \
			-sticky nswe \
			-padx $::theme::padx -pady $::theme::pady \
			;
	}
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 0 -weight 1

	if {[llength $currentTexture] == 2} {
		set currentTexture [[namespace parent]::findTexture $which {*}$currentTexture]
	} else {
		set currentTexture ""
	}

	set Browser(row) 0
	set Browser(col) 0
	set Browser(hilite) $currentTexture
	set Browser(result) {}

	bind $w.container <Destroy>  [namespace code { after cancel $Browser(afterId,texture) }]
	bind $w.container <Destroy> +[namespace code { after cancel $Browser(afterId,key) }]
	bind $w.container <Destroy> +[namespace code { catch { image delete $Browser(image) } }]
	bind $w.container <Configure> [namespace code [list Configure %W $which %w %h]]

	after idle [FindTextures $w.container $which]
	return $w.container
}


proc forgetTextures {} {
	variable Browser

	image delete {*}$Browser(list)
	set Browser(list) {}
	array unset Browser texture,*
}


proc getTexture {file} {
	variable Browser

	if {[info exists Browser(texture,$file)]} { return $Browser(texture,$file) }
	return {}
}

} ;# namespace texture
} ;# namespace board

# vi:set ts=3 sw=3:
