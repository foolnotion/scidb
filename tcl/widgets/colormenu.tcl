# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

package require Tk 8.5
package require choosecolor
package require place
if {[catch { package require tkpng }]} { package require Img }
package provide colormenu 1.0

namespace eval colormenu {
namespace eval mc {
set BaseColor			"Base Color"
set UserColor			"User Color"
set UsedColor			"Used Color"
set RecentColor		"Recent Color"
set Texture				"Texture"
set OpenColorDialog	"Open Color Dialog"
set EraseColor			"Erase Color"
set Close				"Close"
}

variable selection {}
variable useGrab true
variable catchEmptyBackgroundError true
variable bgerrorHandler ::tk::dialog::error::bgerror

namespace import ::dialog::choosecolor::getActualColor
namespace import ::tcl::mathfunc::min

namespace export popup

proc popup {parent args} {
	variable ::dialog::choosecolor::userColorList
	variable selection
	variable useGrab
	variable haveTooltips
	variable catchEmptyBackgroundError

	if {$catchEmptyBackgroundError} {
		# BUG: sometimes we get an empty background error. I don't know why.
		# (unluckely it is an error w/o any message; that means the error is a bug).
		proc ::bgerror {message} {
			if {[string length $message]} { return [$::colormenu::bgerrorHandler $message] }
			return 0
		}
	}

	if {![winfo exists $parent]} {
		return -code error "window name \"$parent\" doesn't exist"
	}

	set disableParent false
	set showEraser false
	set recentColorList {}
	set usedColorList {}
	set baseColorList {}
	set hasParentArg false
	set dlgArgs {}
	set userActions {}
	set textureList {}

	if {!$useGrab && [catch {$parent cget -state}]} { set disableParent true }
	set key [lindex $args 0]

	while {$key != ""} {
		if {[llength $args] <= 1} {
			return -code error "no value given to option \"$key\""
		}

		set value [lindex $args 1]
		set args [lreplace $args 0 1]

		switch $key {
			-recentcolors {
				set recentColorList [set $value]
				lappend dlgArgs $key $value
			}

			-usedcolors {
				set usedColorList $value
			}

			-basecolors {
				if {[llength $value]} {
					set baseColorList $value
					set n [llength $baseColorList]
					if {$n % 6} { lappend baseColorList {*}[lrepeat [expr {6 - ($n % 6)}] {}] }
				}
			}

			-textures {
				set textureList $value
			}

			-eraser {
				if {![string is boolean $value]} {
					return -code error "option \"$key\": value should be boolean"
				}
				set showEraser $value
			}

			-parent {
				set hasParentArg true
				lappend dlgArgs $key $value
			}

			-action {
				if {[llength $value]} {
					if {[llength $value] != 3} {
						return -code error "option \"$key\": value should be {<name> <icon> <tip>}"
					}
					lappend userActions {*}$value
				}
			}

			default {
				lappend dlgArgs $key $value
			}
		}

		set key [lindex $args 0]
	}

	if {!$hasParentArg} { lappend dlgArgs -parent [winfo toplevel $parent] }

	set point [expr {[winfo toplevel $parent] == "." ? "" : "."}]
	set top [winfo toplevel $parent]${point}__colormenu__
	if {[winfo exists $top]} { return }
	
	menu $top
	wm withdraw $top
	tk::frame $top.f -relief raised -borderwidth 2
	set bg [$top.f cget -background]
	pack $top.f

	bind $top <ButtonPress-1> [namespace code [list ClearSelection $top %X %Y]]
	bind $top <ButtonPress-2> [namespace code [list ClearSelection $top %X %Y]]
	bind $top <ButtonPress-3> [namespace code [list ClearSelection $top %X %Y]]
	bind $top <Deactivate> [namespace code { set selection {} }]
	bind $top <Destroy> [namespace code [list ClearTooltips $top %W]]
	if {!$useGrab} { bind $top <FocusOut> [namespace code [list ClearSelection $top]] }

	set colorList {}
	if {[llength $recentColorList]} { set colorList $recentColorList }

	set col		0
	set row		1
	set count	0
	set colors	[concat $baseColorList]
	set nb		[llength $baseColorList]
	set nu		0
	set nd		0
	set nr		0
	set nt		0

	foreach color $userColorList {
		if {[llength $color] == 0 && ($nu == 0 || $nu % 6 == 0)} { break }
		lappend colors $color
		incr nu
	}
	if {$nu % 6} { lappend colors {*}[lrepeat [expr {6 - ($nu % 6)}] {}] }
	foreach color $usedColorList {
		if {[llength $color] == 0 && ($nd == 0 || $nd % 6 == 0)} { break }
		lappend colors $color
		incr nd
	}
	if {$nd % 6} { lappend colors {*}[lrepeat [expr {6 - ($nd % 6)}] {}] }
	foreach color $recentColorList {
		if {[llength $color] == 0 && ($nr == 0 || $nr % 6 == 0)} { break }
		lappend colors $color
		incr nr
	}
	if {$nr % 6} { lappend colors {*}[lrepeat [expr {6 - ($nr % 6)}] {}] }
	foreach texture $textureList {
		if {[llength $texture] == 0 && ($nt == 0 || $nt % 6 == 0)} { break }
		incr nt
	}
	if {$nt % 6} { lappend textureList {*}[lrepeat [expr {6 - ($nt % 6)}] {{} {}}] }

	set actions [list palette [set [namespace current]::icon::16x16::palette] [Tr OpenColorDialog]]
	lappend actions {*}$userActions
	if {$showEraser} {
		lappend actions erase [set [namespace current]::icon::16x16::eraser] [Tr EraseColor]
	}
	lappend actions close [set [namespace current]::icon::16x16::crossHand] [Tr Close]

	set buttonList {}
	set buttonRow {}

	set col 0
	foreach {name icon tip} $actions {
		set f [tk::label $top.f.$name \
					-highlightthickness 1 \
					-highlightcolor black \
					-highlightbackground $bg \
					-background $bg \
					-takefocus 1 \
					-borderwidth 1 \
					-width 16 \
					-height 16 \
					-image $icon]
		grid $f -column $col -row $row
		bind $f <ButtonPress-1> [namespace code [list set selection $name]]
		bind $f <Return> [namespace code [list set selection $name]]
		bind $f <space> [namespace code [list set selection $name]]
		bind $f <Escape> [namespace code [list set selection close]]
		bind $f <Enter> { focus %W }
		lappend buttonRow $f
		Tooltip $f $tip
		incr col
	}
	lappend buttonList $buttonRow

	grid rowconfigure $top.f [list 0 [expr {$row + 2}]] -minsize 2
	grid [ttk::separator $top.f.sep1] -column 0 -row [expr {$row + 1}] -columnspan 6 -sticky we
	incr row 2
	set col 0
	set buttonRow {}

	foreach color $colors {
		set actual ""
		if {$color != ""} {
			set actual [getActualColor $color]
			if {$actual == ""} {
				return -code error "option \"$key\": invalid color \"$color\""
			}
		}
		set f [tk::frame $top.f.color$col$row \
					-highlightthickness 1 \
					-highlightcolor black \
					-highlightbackground $bg \
					-background $bg \
					-borderwidth 0 \
					-width 22 \
					-height 22]
		set b [tk::frame $f.b \
					-relief solid \
					-borderwidth 1 \
					-width 18 \
					-height 18 \
					-background [expr {[llength $color] ? $color : $bg}]]
		bind $b <ButtonPress-1> [namespace code [list set selection $color]]
		bind $f <ButtonPress-1> [namespace code [list set selection $color]]
		bind $f <Return> [namespace code [list set selection $color]]
		bind $f <space> [namespace code [list set selection $color]]
		bind $f <Escape> [namespace code [list set selection close]]
		bind $f <Enter> { focus %W }
		grid $f -column $col -row $row
		pack $b -padx 1 -pady 1
		lappend buttonRow $f

		if {[llength $color]} {
			if {$count < $nb} {
				set tip BaseColor
			} elseif {$count < $nb + $nu} {
				set tip UserColor
			} elseif {$count < $nb + $nu + $nd} {
				set tip UsedColor
			} elseif {$count < $nb + $nu + $nd + $nr} {
				set tip RecentColor
			} else {
				set tip Texture
			}
			Tooltip $f "[Tr $tip]: [::dialog::choosecolor::extendColorName $actual]"
		}

		incr count
		if {[incr col] == 6} {
			set col 0
			incr row 2
			lappend buttonList $buttonRow
			set buttonRow {}
		}
	}

	if {$col != 0} { incr row 2 }
	set col 0
	set buttonRow {}

	if {$nt > 0} {
		grid [ttk::separator $top.f.sep2] -column 0 -row [expr {$row - 1}] -columnspan 6 -sticky we
		foreach texture $textureList {
			set f [tk::frame $top.f.color$col$row \
						-highlightthickness 1 \
						-highlightcolor black \
						-highlightbackground $bg \
						-background $bg \
						-borderwidth 0 \
						-width 22 \
						-height 22]
			set b [tk::canvas $f.b -relief solid -borderwidth 1 -width 16 -height 16]
			set tooltip [lindex $texture 1]
			set texture [lindex $texture 0]
			if {[llength $texture]} { $b create image 1 1 -image $texture -anchor nw }
			bind $b <ButtonPress-1> [namespace code [list set selection $texture]]
			bind $f <ButtonPress-1> [namespace code [list set selection $texture]]
			bind $f <Return> [namespace code [list set selection $texture]]
			bind $f <space> [namespace code [list set selection $texture]]
			bind $f <Escape> [namespace code [list set selection close]]
			bind $f <Enter> { focus %W }
			grid $f -column $col -row $row
			pack $b -padx 1 -pady 1
			lappend buttonRow $f
			if {[llength $tooltip]} { Tooltip $f "[Tr Texture]: $tooltip" }
			incr count
			if {[incr col] == 6} {
				set col 0
				incr row 2
				lappend buttonList $buttonRow
			}
		}
	}

	if {$col != 0} { incr row 2 }
	set lastrow [expr {$row - 1}]

	foreach row $buttonList {
		for {set i 0} {$i < [llength $row]} {incr i} {
			set k [expr {$i + 1}]
			bind [lindex $row $i] <Right> [list focus [lindex $row $k]]
			bind [lindex $row $k] <Left>  [list focus [lindex $row $i]]
		}
	}
	for {set i 0} {$i < [llength $buttonList] - 1} {incr i} {
		set row0 [lindex $buttonList $i]
		set row1 [lindex $buttonList [expr {$i + 1}]]
		bind [lindex $row0 end] <Right> [list focus [lindex $row1 0]]
		foreach b0 $row0 b1 $row1 {
			if {[llength $b0] && [llength $b1]} { bind $b0 <Down> [list focus $b1] }
		}
	}
	for {set i 1} {$i < [llength $buttonList]} {incr i} {
		set row0 [lindex $buttonList [expr {$i - 1}]]
		set row1 [lindex $buttonList $i]
		bind [lindex $row1 0] <Left> [list focus [lindex $row0 end]]
		foreach b0 $row0 b1 $row1 {
			if {[llength $b0] && [llength $b1]} { bind $b1 <Up> [list focus $b0] }
		}
	}

	set sum 0
	foreach v {nb nu nd nr nt} {
		set sum [expr {$sum + [set $v]}]
		set row [expr {2*(($sum + 5)/6) + 2}]
		if {0 <= $row && $row < $lastrow} { grid rowconfigure $top.f $row -minsize 8 }
	}
	grid columnconfigure $top.f 6 -minsize 1

	Tooltip on $top*
	wm transient $top [winfo toplevel [winfo parent $top]]
	catch { wm attributes $top -type popup_menu }
	util::place $top below $parent
	wm deiconify $top
	raise $top
	focus $top
	if {[tk windowingsystem] == "x11"} {
		catch { tkwait visibility $top }
		update idletasks
		if {![winfo exists $top]} { return }
	}
	if {$useGrab} { ttk::globalGrab $top.f }
	catch { focus -force $top.f.close }
	vwait [namespace current]::selection
	if {$useGrab} { ttk::releaseGrab $top.f }
	destroy $top
	Tooltip on
	update idletasks

	switch $selection {
		close		{ return "" }
		palette	{
			if {$disableParent} { $parent configure -state disabled }
			set selection [::dialog::chooseColor {*}$dlgArgs]
			if {$disableParent} { $parent configure -state normal }
		}
	}

	if {$catchEmptyBackgroundError} {
		proc ::bgerror {message} { return [$::colormenu::bgerrorHandler $message] }
	}

	return $selection
}


proc ClearSelection {menu {x {}} {y {}}} {
	if {[llength $x]} {
		set w [winfo containing $x $y]
	} else {
		set w [focus]
	}

	if {![string match $menu* $w]} {
		set [namespace current]::selection {}
	}
}


proc ClearTooltips {menu w} {
	if {$menu eq $w} {
		::dialog::choosecolor::tooltip clear $w.*
		::dialog::choosecolor::tooltip hide
	}
}


proc Tr {tok} { return [::dialog::choosecolor::mc [namespace current]::mc::$tok] }
proc Tooltip {args} { ::dialog::choosecolor::tooltip {*}$args }

namespace eval icon {
namespace eval 16x16 {

set eraser [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACQUlEQVQ4y72Tz0uTcRzH38+P
	qU8EwUbGDoEXd1RjMFCjQ3+Ag3A5dpDIggi0okOQh6lISNFJI6QVibOtpTCGF8UdxJNEIVO6
	jPWAuGGj5EHG3J7vs+fdwSEaBkLQGz6HD3zenx/w+gD/KOUMNWpnZ2dvOBx+4/V6fZlMpnhw
	cJA/S3MH4LkFTGY9nvecnv7EcrnMQqHAaDS6GQgEHgG4eJqxCbh8H3iuA78IsB4lNjd/5MjI
	LIvFIvP5PH0+38/jxvN9fX2PBwcfFhobY8eMf4ZFTZvkwMBdLi4uGkfujo6O9fn5eZKkruvs
	739LRVk/pcEqgTSnphJcWloyZABwu91XQqFQy9bWFsbGxiBJEmZmbmNj4xx6et4B+AbAApAE
	0ALgOpqaACEEMDQ09CKXy9kkWSqVmEwmOTw8zFgsRtM0SZKzsx8oy08JiKNN5uYSjEQiOWl5
	edno7u6+oKoqHA4HJEnCzs4O1tbWsLu7C5fLBU3TMD5OZDI36wdb8Pt7N1dWVnqQTqcNkhRC
	sFwus1qt0rZtCiEYj8eZSqVIkm1tifr0KoHwZwCXAECu1WqHtKgqNE2DLMuoVCpQFAVOp/Pw
	ziP9AHAnCoxeqydQTdMUJ7BTVZCEJEkAgP39fQCAJG3WgFdPgNWXJ1A2DON7Q0ODt7W11ako
	h2Tbtg1FUaDrOra3t2Ga5t7CwrMbe3tfo3/F1u/330ulUnnLsiiEYDabtUKhULyrq+uLy+Xy
	nPW5tGAw+GBiYuJ1e3v7VfwP/QZihziV88XulwAAAABJRU5ErkJggg==
}]

set palette [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0
	RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAORSURBVHjaYvz//z8DJQAggBg3
	B0IYTEBzfv9k4GXmZAgRVFL3+C5sYCohK8HLyc3J8Onls78f7py7uf7g9V0rL/5d9uoXw32Y
	AQABxAAyYJMfEPsyeJxqNDv15vyq/3suf/h/6uW///se//v/9s+////+/Pz/98WD/9+vbvu/
	t9H5kYcsQzJMP0AAAEEAvv8AsU4AALNSA2Tjr2n+/v7p//7++P9Nsf7/OL3+/yqp/v/Fz9P/
	/qh2//7GnP/+roj//vLc/9ymaP4+GQBuAAAAAAIAQQC+/wNaJwA7Hz4+qdTf8OGul5DWFfXM
	CwcuKQr4CgoAFgjuAFsT3QAKy5MAAPPOAPvawQABJDYAEi83ASsA2kK3x+K/AgBBAL7/A3BT
	JJwGGiInZnu1YbvS7X/339MgfVsoM0kQ7QBVC9cACgLzAAAYHAD7FCcA/xwfAAMECQABCyMA
	GxQJBObMuw8CiEXU0MhKwtyGYXLB9faf79/lyOppGP3/94WB7eNlYKj+YmD4+xcUxAysTECa
	9R8Dw6d5DAzSJ4HiNxhs1HmtAAKIhfnzC2YOMVYG17xwLYaPH7UYGECKgIH86ycDwx+gAX9+
	AxX/ARoGxL+AfOEnDAzAqPr//z6DCC8zD0AAMf9/+ZxPm+W1BT8n0Bo2oGWf3zEwfAXi7x8Y
	GL69B+K3QP4bBoYvb8D0j08CDD8esjKwP3jLcP/Bp58AAQBBAL7/A8nk/b3ExeTJ1crY/Rr/
	8igXGAwEAP36AAD49gAA+vcAAPnyAP/y7wAB+PMA0Pn7AN07fgD0H0kA+9qxANzQ8u0CiBkU
	Fc++M9wFGrTh4Ok3V9WY3zoqK/LxgL3w4wvDv/8CDN9E/BjY/v9hWPzvDkOn0UeGzfyXGD5c
	vsbwaf+fYwABxIScLK9/YthQsOxt6tWT94Ee/s7w78s3husvchheSXUy3Pq7mMH8HTuD5tf7
	DMpf7jDI3//BsPY+ww6AAGJBT9vXgRbM2fFiWZ8cYxwTyx+GF7f5weH38bYwgycvG8OKdY8Y
	fv5gZqjbxXDu0ieGtQABxIwtgzz+wHCB9+d3d3XhP6KyApcYRGS+Myj9b2UQ4rrC8OXtP4Yp
	e//e6r/AkP/zH8MlgABixJXLuJkZlLwUGbKNpRmcRbgZxLjZGBhffGL4vvcew+49jxjm/vjH
	cBao7C9AADESkWNFgJgHlHMZwImE4RUDKICgACDAAIaNf6pWNsqkAAAAAElFTkSuQmCC
}]

set crossHand [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACnklEQVQ4y41PW0iTART+/n9e9q85MXPadHM63eZcKiVO
	DTcMUzEduiC0BxWXYD5ISQ9RT5bSAh98iR7SdPYQGAXqg6YkBaKI4SVSo6ALmjek7fdKc9vp
	SbGxpO/tnO9yzscAAMcw9y6LRFUsEfjAIOrlnWUApuGDADBll0SiNmVEJHhpJLomxysOOE21
	RLLdL5XSbFISlUbJpgEIffxqa4SMn9Tracdmo0yNdgCA4JANZJjrdkUsLaak0LLRRAqRuO2I
	mTsfFjn1NiWVfttsdLu6ZgmA1PdDaESi/k9pabSfk0PDhmw3C6YAAGKCTrS/Umtpq7GRhp50
	uFmGzcM/ILsWJVtbTU+nTZOJauXKlWBGcOuRTEmrViutDA7RaWlUE46DAIylOynZ+7m4mMZK
	zNSsUNJqXR25JyboYo5p9K/evgMAELAwsb0dbQg7eU4iCUGhPAbhFgvu9/ZtPH3Rkw/Aif+A
	2CKLWxs1Gmm/oYEWuuzEsmyNPyHrbxnAMMWZEk4a6nJBoNNBLY9BYdrZGn96gR9/YrU8tq8k
	USXUabXYiVdBxLK44PEoumc/0K7b/e64AGF2WMTrGwlxSkNRETqX1zdbX/Z9vMKQLOTbV6jF
	kuyen0sjABb9Fo8K5h73JJ8hZ309zbR3erlgYTmAhIcqHf8rI4M8eXlUG5/wBYDYX+/y1kQN
	/TCbaevNCGlV6o4DjhMEVgzoU707WVm0WVBI6pDQDl+/xhot5+dyc8nT20tXzaVzALijgmRx
	6PPvGQbyVlbSeGWVN4BlLYcHssJPTc3k55O7pYXszQ92Aej9NAy/qdIuempriex2umuxbACQ
	CQCUmhTx5nWvd3PY4eCbnnXfce27Bv0E7L13OhZ2AeO0w8EzHLc/Nj+/9weRl/0oDhMDQgAA
	AABJRU5ErkJggg==
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace colormenu

# vi:set ts=3 sw=3:
