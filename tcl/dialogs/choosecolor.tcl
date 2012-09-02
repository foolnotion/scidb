# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2008-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
if {[catch { package require tkpng }]} { package require Img }
package provide choosecolor 1.0

namespace eval dialog {

proc chooseColor {{args {}}} { return [choosecolor::choosecolor {*}$args] }

namespace export chooseColor

namespace eval choosecolor {
namespace eval mc {
### Client Relevant Data ########################################
set Ok					"&OK"
set Cancel				"&Cancel"

set BaseColors			"Base Colors"
set UserColors			"User Colors"
set RecentColors		"Recent Colors"
set Old					"Old"
set Current				"Current"
set HexCode				"Hex Code"
set ColorSelection	"Color Selection"
set Red					"Red"
set Green				"Green"
set Blue					"Blue"
set Hue					"Hue"
set Saturation			"Saturation"
set Value				"Value"
set Enter				"Enter"
set AddColor			"Add current color to user colors"
#################################################################
} ;# namespace mc

### Client Relevant Data ########################################
variable iconOk {}
variable iconCancel {}
variable userColorList { {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} }
variable recentColorList {}
#################################################################

namespace export choosecolor isOpen geometry addToList
namespace export hsv2rgb rgb2hsv getActualColor
namespace export lookupColorName extendColorName
namespace export userColorList recentColorList

namespace import ::tcl::mathfunc::*

# variable baseColorList {
# 	\#0000ff \#00ff00 \#00ffff \#ff0000 \#ff00ff \#ffff00
# 	\#000099 \#009900 \#009999 \#990000 \#990099 \#999900
# 	\#000000 \#333333 \#666666 \#999999 \#cccccc \#ffffff
# }

array set Options {
	button:height	15
	button:width	20
}

variable Methods {}


proc mc {tok} { return [::tk::msgcat::mc [set $tok]] }
proc tooltip {args} {}
#proc noWindowDecor {w} {}

if {![catch {package require tooltip}]} {
	proc tooltip {args} { ::tooltip::tooltip {*}$args }
}


proc choosecolor {args} {
	return [OpenDialog [ParseArguments {*}$args]]
}


proc setupColor {path rgb} {
	variable Priv

	set Priv(rgb) $rgb
	set Priv(hexcode) [string range $rgb 1 end]
	ShowColor $path.lt.current $rgb


	if {$Priv(configured)} {
		scan $rgb "\#%2x%2x%2x" r g b
		namespace eval $Priv(current-method) [list Update $r $g $b false]
	}
}


proc setupRecentColors {path recentcolors} {
	variable Options
	variable icon::$Options(button:width)x$Options(button:height)::Empty

	set row 1
	set col 1
	set count 0
	set lt $path.lt

	foreach c [set $recentcolors] {
		set fround $lt.roundrecent$count
		set fcolor $lt.colorrecent$count
		set bg [$fround cget -background]
		if {[llength $c] == 0} {
			set tip ""
			if {![winfo exists $fcolor.empty]} {
				$fcolor configure -background $bg
				pack [tk::label $fcolor.empty -borderwidth 0 -image $Empty]
			}
		} else {
			catch { destroy $fcolor.empty }
			$fcolor configure -background $c
			set tip [extendColorName $c]
		}
		tooltip $fcolor $tip
		if {[incr col] == 7} {
			incr row
			set col 1
		}
		incr count
	}
}


proc embedFrame {path args} {
	ttk::frame $path -takefocus 0
	BuildFrame $path [ParseArguments {*}$args]
	return $path
}


proc geometry {{whichPart size}} {
	variable Priv

	if {![winfo exists Priv(geometry)]} { return "" }

	set geom $Priv(geometry)
	if {$geom eq ""} { return "" }

	switch -- $whichPart {
		size	{ set geom [lindex [split $geom "+"] 0] }
		pos	{ set geom [string range $geom [string first "+" $geom] end] }
	}

	return $geom
}


proc getActualColor {color} {
	variable Priv

	if {![info exists Priv(label)]} {
		set Priv(label) [tk::label ._choosecolor__should_be_unique_pathname_[clock seconds]]
	}
	if {[catch {$Priv(label) configure -background $color}]} { return "" }
	lassign [winfo rgb $Priv(label) [$Priv(label) cget -background]] r g b
	return [format "#%02x%02x%02x" [expr {$r/257}] [expr {$g/257}] [expr {$b/257}]]
}


proc lookupColorName {color} {
	variable x11::Palette

	if {[string range $color 0 0] ne "#"} { return $color}

	set name ""
	set i [lsearch -exact $Palette [string range $color 1 end]]
	if {$i != -1} {
		set name [lindex $Palette [expr {$i + 1}]]
	} else {
		scan $color "\#%2x%2x%2x" r g b
		if {$r == $g && $g == $b} {
			switch $r {
				  0 { set name "Black" }
				105 { set name "Dim Gray" }
				169 { set name "Dark Gray" }
				190 { set name "Gray" }
				211 { set name "Light Gray" }
				255 { set name "White" }

				25 - 76 - 128 - 178 - 230 { ;# "fails calculation below" }

				default {
					set v [expr {$r*0.3921568627450980392}]	;# we need full precision!
					set n [expr {int($v + 0.5)}]
					if {abs($v - $n) < 0.2} { set name "Gray $n" }
				}
			}
		}
	}

	return $name
}


proc extendColorName {color} {
	set name [lookupColorName $color]
	if {[llength $name] == 0} { return $color }
	return "$color ($name)"
}


proc isOpen {} {
	variable Priv
	return [expr {[info exists Priv(pane)] && [winfo exists $Priv(pane)]}]
}


proc hsv2rgb {hue sat val} {
	if {$sat < 5.0e-6} {			;# the color is on the bw center line
		set v [expr {round(255.0*$val)}]
		return [list $v $v $v]	;# achromatic (grey)
	}

	set v [expr {round(255.0*$val)}]

	if {$hue >= 360.0} {
		set hue [expr {$hue - 360.0}]
	}

	set h [expr {$hue*0.01666666666667}]	;# 6/360
	set i [expr {int($h)}]
	set f [expr {$h - $i}]
	set p [expr {round(255.0*$val*(1 - $sat))}]
	set q [expr {round(255.0*$val*(1 - ($sat*$f)))}]
	set t [expr {round(255.0*$val*(1 - ($sat*(1 - $f))))}]

	switch $i {
		0 { return [list $v $t $p] }
		1 { return [list $q $v $p] }
		2 { return [list $p $v $t] }
		3 { return [list $p $q $v] }
		4 { return [list $t $p $v] }
		5 { return [list $v $p $q] }
	}
}


proc rgb2hsv {r g b} {
	set max [max $r $g $b]
	set min [min $r $g $b]

	set val [expr {$max/255.0}]	;# this is the brightness

	if {$max == 0 || $max == $min} {
		set sat 0
		set hue 0	;# no hue
	} else {
		set delta [expr {$max - $min}]

		set rc [expr {$max - $r}]
		set gc [expr {$max - $g}]
		set bc [expr {$max - $b}]

		set sat [expr {(double($delta)/double($max))}]

		if {$r == $max} {			;# between yellow and magenta
			set hue [expr {double($bc - $gc)/$delta}]
		} elseif {$g == $max} {	;# between cyan and yellow
			set hue [expr {2.0 + double($rc - $bc)/$delta}]
		} else {						;# between magenta and cyan
			set hue [expr {4.0 + double($gc - $rc)/$delta}]
		}

		set hue [expr {$hue*60.0}]	;# convert hue to degrees
		if {$hue < 0} { set hue [expr {$hue + 360}] }
	}

	return [list $hue $sat $val]
}


proc addToList {listvar color} {
	if {[llength $color] == 0} { return }
	set color [getActualColor $color]
	set n [lsearch -exact [set $listvar] $color]
	if {$n == -1} { set n end }
	set $listvar [linsert [lreplace [set $listvar] $n $n] 0 $color]
}


proc Tr {tok} { return [mc [namespace current]::mc::$tok] }
namespace export Tr


proc OpenDialog {options} {
	variable Priv
	variable Methods
	variable iconOk
	variable iconCancel

	if {[isOpen]} {
		return -code error "choosecolor dialog already open"
	}

	array set opts $options
	set oldcolor $opts(oldcolor)

	### Create Dialog ##############
	set point [expr {$opts(parent) eq "." ? "" : "."}]
	set dlg $opts(parent)${point}__choosecolor__
	if {[llength $opts(class)]} {
		tk::toplevel $dlg -class $opts(class)
	} else {
		tk::toplevel $dlg
	}
	bind $dlg <Configure> [namespace code [list RecordGeometry $dlg %W]]
	event add <<ChooseColorSelected>> ChooseColorSelected
	event add <<ChooseColorReset>> ChooseColorReset

	set top [ttk::frame $dlg.top -takefocus 0]
	BuildFrame $top $options

	### Button Frame ###############
	set box [tk::frame $dlg.bbox -takefocus 0]
	tk::AmpWidget ttk::button $box.ok  -default active -command [namespace code [list Done $dlg 1 ]]
	tk::AmpWidget ttk::button $box.cancel -command \
		[namespace code [list Done $dlg 0 [expr {$oldcolor eq "" ? $opts(initialcolor) : $oldcolor}]]]
	if {[llength iconOk] && [llength iconCancel]} {
		$box.ok configure -compound left -image $iconOk
		$box.cancel configure -compound left -image $iconCancel
		tk::SetAmpText $box.ok " [Tr Ok]"
		tk::SetAmpText $box.cancel " [Tr Cancel]"
	} else {
		tk::SetAmpText $box.ok [Tr Ok]
		tk::SetAmpText $box.cancel [Tr Cancel]
	}
	bind $box.cancel <Return> { event generate %W <Key-space>; break }
	bind $box.cancel <FocusIn>  "%W configure -default active; $box.ok configure -default normal"
	bind $box.cancel <FocusOut> "%W configure -default normal; $box.ok configure -default active"
	pack $box.ok -side left -padx 5
	pack $box.cancel -side left -padx 5

	set cancelCmd "$box.cancel invoke"
	switch $::tcl_platform(platform) {
		macintosh	{ bind $dlg <Command-period> $cancelCmd }
		windows		{ bind $dlg <Escape> $cancelCmd }
		x11			{ bind $dlg <Escape> $cancelCmd; bind $dlg <Control-c> $cancelCmd }
	}
	bind $dlg <Return> "focus $box.ok; event generate $box.ok <Key-space>"
	bind $dlg <Alt-Key> [list tk::AltKeyInDialog $dlg %A]

	### Dialog Layout ##############
	set sep [ttk::separator $dlg.sep -orient horizontal]
	pack $top -side top -expand yes -fill both -padx 5 -pady 5
	pack $sep -side top -anchor ne -fill x
	pack $box -side top -anchor ne -pady 2m

	### Map Dialog ################
   wm protocol $dlg WM_DELETE_WINDOW \
		[namespace code [list Done $dlg 0 [expr {$oldcolor eq "" ? $opts(initialcolor) : $oldcolor}] ]]
   wm title $dlg [expr {$opts(app) eq "" ? $opts(title) : "$opts(app): $opts(title)"}]
	Popup $dlg $opts(parent) $opts(modal) $top.rt $opts(place) $opts(geometry)

	return $Priv(rgb)
}


proc BuildFrame {w options} {
	variable Options
	variable icon::$Options(button:height)x$Options(button:height)::GreenArrow
	variable icon::$Options(button:width)x$Options(button:height)::Empty
	variable Methods
	variable Priv

	array set opts $options
	set oldcolor $opts(oldcolor)
	set Priv(receiver) $opts(receiver)
	set Priv(embedded) {}
	set Priv(configured) 0

	set Priv(notebook-size:y) [[namespace current]::x11::ComputeHeight \
		$opts(height) \
		[llength [set $opts(usercolors)]] \
		[llength [set $opts(recentcolors)]] \
	]
	set Priv(notebook-size:x) \
		[[namespace current]::[lindex $Methods 0]::ComputeWidth $Priv(notebook-size:y)]

	### Top Frame ##################
	set lt [ttk::frame $w.lt -relief flat -takefocus 0]
	set rt [ttk::notebook $w.rt -takefocus 1]

	grid $lt -row 1 -column 1 -sticky ns
	grid $rt -row 1 -column 3 -sticky nsew
	grid columnconfigure $w 2 -minsize 5
	grid columnconfigure $w 3 -weight 1
	grid rowconfigure $w 1 -weight 1

	set count 0
	set frow 0
	set frows {}
	foreach {type var name} [list \
			user $opts(usercolors) UserColors \
			recent $opts(recentcolors) RecentColors \
		] {
		if {[llength [set $var]] == 0} { continue }

		set f [ttk::labelframe $lt.$type -text [Tr $name]]
		grid $f -sticky nwe -row $frow -column 0

		set row 1
		set col [expr {($type eq "user") + 1}]

		foreach c [set $var] {
			set fround [tk::frame $lt.round$type$count -relief raised -borderwidth 1 -takefocus 0]
			set bg [$fround cget -background]
			set args {}
			set color $c
			if {[llength $color] == 0} { set color $bg }
			set fcolor [tk::frame $lt.color$type$count \
										-width $Options(button:width) \
										-height $Options(button:height) \
										-highlightthickness 0 \
										-borderwidth 0 \
										-background $color \
			]
			if {[llength $c] == 0} {
				pack [tk::label $fcolor.empty -borderwidth 0 -image $Empty]
			} else {
				tooltip $fcolor [extendColorName $c]
			}
			pack $fcolor -in $fround -padx 0 -pady 0
			grid $fround -in $f -row $row -column $col -padx 2 -pady 2

			bind $fcolor <ButtonPress-1>		[list $fround configure -relief sunken]
			bind $fcolor <ButtonRelease-1>	[list $fround configure -relief raised]
			bind $fcolor <ButtonPress-1>		+[namespace code [list SelectRGB $type $count]]

			incr count
			if {[incr col] == 7} {
				incr row
				set col 1
			}
		}

		set count 0
		lappend frows [expr {$frow + 1}]
		incr frow 2
		grid columnconfigure $f {0 7} -minsize 3 -weight 1
		grid rowconfigure $f 0 -minsize 3
		grid rowconfigure $f $row -minsize 3
	}

	if {[llength [set $opts(usercolors)]] > 0} {
		set add [tk::button $lt.add \
			-image [set GreenArrow] \
			-width [expr {$Options(button:width) - 2}] \
			-height [expr {$Options(button:height) - 2}] \
			-background [ttk::style lookup $::ttk::currentTheme -background] \
			-activebackground $bg \
			-relief raised \
			-borderwidth 1 \
			-takefocus 0 \
			-command [namespace code [list AddCurrentColor $lt $opts(usercolors)]] \
		]
		grid $add -in $lt.user -row 1 -column 1 -padx 2 -pady 2
		bind $add <ButtonPress-1> [list $add configure -relief sunken]
		bind $add <ButtonRelease-1> [list $add configure -relief raised]
		tooltip $lt.add [Tr AddColor]
	}

	set colorFrames {}
	if {$oldcolor ne ""} { lappend colorFrames old Old }
	if {$opts(embedcmd) eq "" || $oldcolor eq ""} { lappend colorFrames current Current }

	if {$opts(embedcmd) ne ""} {
		set Priv(embedded) [ttk::frame $lt.embed -takefocus 0]
		grid $Priv(embedded) -row $frow -sticky nsew
		lappend frows [expr {$frow + 1}]
		set rcv [eval $opts(embedcmd) $Priv(embedded)]
		if {$rcv ni $Priv(receiver)} { lappend Priv(receiver) $rcv }
		incr frow 2
	}

	set n 0
	foreach {type name} $colorFrames {
		if {[llength $colorFrames] == 2 || $n == 1} {
			set hex [ttk::frame $lt.hex -relief groove -borderwidth 2 -takefocus 0]
			ttk::label $hex.lbl -text "$mc::HexCode: #"
			ttk::entry $hex.code \
				-width 0 \
				-textvariable [namespace current]::Priv(hexcode) \
				-validatecommand {
					return [expr {	%d == 0
									|| ([string match \[0-9a-fA-F\]* "%S"] && [string length "%P"] <= 6)}]
				} \
				-validate key \
				-invalidcommand { bell } \
				-exportselection yes \
				;
			bind $hex.code <FocusIn> [list $hex.code selection range 0 end]
			bind $hex.code <FocusOut> [list $hex.code selection clear]
			bind $hex.code <FocusOut> +[namespace code AcceptHexCode]
			bind $hex.code <Return> [namespace code AcceptHexCode]
			bind $hex.code <Return> {+ break }
			grid $hex.lbl  -column 2 -row 1
			grid $hex.code -column 4 -row 1 -sticky ew
			grid columnconfigure $hex {0 5} -minsize 5
			grid columnconfigure $hex 4 -weight 1
			grid rowconfigure $hex {0 2} -minsize 1
			grid $hex -row $frow -sticky ew
			lappend frows [incr frow]
			incr frow
		}
		set fcolor [ttk::frame $lt.f$type -relief sunken -borderwidth 1 -takefocus 0]
		set ccolor [tk::canvas $lt.$type -highlightthickness 0 -width 10 -height 10]
		if {$oldcolor ne ""} {
			$lt.$type create text 5 5 -anchor nw -text [Tr $name] -tags label
		}
		grid $fcolor -row $frow -sticky nsew
		grid rowconfigure $lt $frow -weight 1 -minsize 25
		pack $ccolor -in $fcolor -expand yes -fill both
		lappend frows [incr frow]
		incr frow
		incr n
	}

	set frows [lreplace $frows end end]
	grid rowconfigure $lt $frows -minsize 5

	if {$opts(embedcmd) eq "" || $oldcolor eq ""} {
		lappend Priv(receiver) $lt.current
		bind $lt.current <<ChooseColorSelected>> [namespace code [list ShowColor $lt.current %d]]
	}

	set count 1
	foreach meth $Methods {
		tk::frame $rt.$meth -takefocus 0
		namespace eval $meth [list MakeFrame $rt.$meth]
		set icon [namespace eval $meth { Icon }]
		set args {}
		if {$icon eq ""} {
			lappend args -text [mc [string toupper $meth 0 0]]
		} else {
			lappend args -image $icon
		}
		$rt add $rt.$meth -sticky nsew -padding 5 {*}$args
		set Priv(need-configure:$meth) 1
		bind $w <F$count> [list $rt select [expr {$count - 1}]]
		incr count
	}
	set Priv(current-method) [lindex $Methods 0]

	bind $rt <<NotebookTabChanged>> [namespace code [list TabChanged $rt]]
	bind $rt <Configure> [namespace code [list Configure $rt]]

	### Setup ######################
	if {[llength $opts(initialcolor)] == 0} {
		set opts(initialcolor) [expr {$oldcolor eq "" ? "#ffffff" : $oldcolor}]
	}
	set Priv(pane) $w.lt
	set Priv(rgb) $opts(initialcolor)
	set Priv(hexcode) [string range $opts(initialcolor) 1 end]
	scan $Priv(rgb) "\#%2x%2x%2x" r g b
	if {$opts(embedcmd) eq "" || $oldcolor eq ""} { ShowColor $lt.current $Priv(rgb) }
	if {[llength $oldcolor]} { ShowColor $lt.old $oldcolor }
}


proc ParseArguments {args} {
	array set opts {
		parent			.
		class				""
		initialcolor	""
		oldcolor			""
		geometry			{}
		embedcmd			{}
		height			0
		modal				true
		place				centeronscreen
		usercolors		{}
		receiver			{}
		recentcolors	{}
	}
	set opts(usercolors)		[namespace current]::userColorList
	set opts(recentcolors)	[namespace current]::recentColorList
	set opts(title)			[Tr ColorSelection]
	set opts(app)				[tk appname]

	set key [lindex $args 0]
	while {$key ne ""} {
		if {[llength $args] <= 1} {
			return -code error "no value given to option \"$key\""
		}

		set value [lindex $args 1]
		set args [lreplace $args 0 1]

		switch -exact -- $key {
			-parent {
				if {![winfo exists $value]} {
					return -code error "window name \"$value\" doesn't exist"
				}
				set opts(parent) $value
			}
			
			-place {
				if {$value ne "centeronscreen" && $value ne "centeronparent"} {
					return -code error "option \"$key\": invalid argument \"$value\""
				}
				set opts(place) $value
			}

			-initialcolor {
				if {$value ne ""} {
					set opts(initialcolor) [getActualColor $value]
					if {$opts(initialcolor) eq ""} {
						return -code error "option \"$key\": invalid color \"$value\""
					}
				}
			}

			-oldcolor {
				if {$value ne ""} {
					set opts(oldcolor) [getActualColor $value]
					if {$opts(oldcolor) eq ""} {
						return -code error "option \"$key\": invalid color \"$value\""
					}
				}
			}

			-recentcolors - usercolors {
				set $value [MakeColorList [set $value]]
				set opts([string range $key 1 end]) $value
			}

			-geometry {
				if {$value eq "last"} {
					set opts(geometry) [geometry]
				} else {
					if {[regexp {^(\d+x\d+)?(\+\d+\+\d+)?$} $value] == 0} {
						return -code error \
							"option \"$key\": invalid geometry '$value'; should be \[WxH\]\[+X+Y\]"
					}
					set opts(geometry) $value
				}
			}

			-height {
				if {![string is integer $value]} {
					return -code error "option \"$key\": value should be integer"
				}
				set opts(height) $value
			}

			-modal {
				if {![string is boolean $value]} {
					return -code error "option \"$key\": value should be boolean"
				}
				set opts(modal) $value
			}

			-app - -class - -title - -embedcmd - -receiver {
				set opts([string range $key 1 end]) $value
			}

			default {
				return -code error \
					"unknown option \"$key\": should be -app, -class, -embedcmd, -geometry, -height, \
					-initialcolor, -modal, -parent, -receiver, -recentcolors, -usercolors, or -title"
			}
		}

		set key [lindex $args 0]
	}

	return [array get opts]
}


proc MakeColorList {colors} {
	set newColors {}
	foreach color $colors {
		set actual ""
		if {$color ne ""} {
			set actual [getActualColor $color]
			if {$actual eq ""} { return -code error "option \"$key\": invalid color \"$color\"" }
		}
		lappend newColors $actual
	}
	if {[llength $newColors] > 0} {
		set n [expr {6 - ([llength $newColors]%6)}]
		if {$n < 6} { set newColors [concat $newColors [lrepeat $n {}]] }
	}

	return $newColors
}


proc Popup {dlg parent modal focus {place {}} {geometry {}}} {
	if {[winfo viewable [winfo toplevel $parent]] } {
		wm transient $dlg [winfo toplevel $parent]
	}
	catch { wm attributes $dlg -type dialog }
	wm iconname $dlg ""
	wm withdraw $dlg
	update idletasks
	set rw [winfo reqwidth  $dlg]
	set rh [winfo reqheight $dlg]
	if {[string first "+" $geometry] >= 0} {
		wm geometry $dlg $geometry
	} else {
		if {$geometry eq ""} {
			set geometry [format "%dx%d" $rw $rh]
			set w $rw
			set h $rh
		} else {
			scan $geometry "%dx%d" w h
		}
		set sw [winfo screenwidth  $parent]
		set sh [winfo screenheight $parent]
		if {$parent eq "." || $place eq "centeronscreen"} {
			set x0 [expr {($sw - $w)/2 - [winfo vrootx $parent]}]
			set y0 [expr {($sh - $h)/2 - [winfo vrooty $parent]}]
		} else {
			set x0 [expr {[winfo rootx $parent] + ([winfo width  $parent] - $w)/2}]
			set y0 [expr {[winfo rooty $parent] + ([winfo height $parent] - $h)/2}]
		}
		set x "+$x0"
		set y "+$y0"
		if {[tk windowingsystem] ne "win32"} {
			if {$x0 + $w > $sw}	{ set x "-0"; set x0 [expr {$sw - $w}] }
			if {$x0 < 0}			{ set x "+0" }
			if {$y0 + $h > $sh}	{ set y "-0"; set y0 [expr {$sh - $h}] }
			if {$y0 < 0}			{ set y "+0" }
		}
		if {[tk windowingsystem] eq "aqua"} {
			# avoid the native menu bar which sits on top of everything
			scan $y0 "%d" y
			if {0 <= $y && $y < 22} { set y0 "+22" }
		}
		wm geometry $dlg $geometry${x}${y}
	}
	wm minsize $dlg $rw $rh
	wm deiconify $dlg
	if {$modal} { ttk::grabWindow $dlg }
	focus $focus
   tkwait window $dlg
	if {$modal} { ttk::releaseGrab $dlg }
}


proc Done {dlg ok {oldcolor ""}} {
	variable Priv

	if {!$ok} {
		set Priv(rgb) ""
		foreach recv $Priv(receiver) {
			if {$recv ne "$Priv(pane).current"} {
				event generate $recv <<ChooseColorReset>> -data $oldcolor
			}
		}
	}
	destroy $dlg
}


proc Configure {tabs} {
	variable Methods
	variable Priv

	foreach meth $Methods {
		set Priv(need-configure:$meth) 1
	}

	set Priv(configured) 1
	TabChanged $tabs true
}


proc RecordGeometry {dlg window} {
	variable Priv

	if {$dlg ne $window} { return }

	set g [winfo geometry $dlg]
	scan $g "%ux%u" gw gh

	if {$gw > 1} {
		set rw [winfo reqwidth $dlg]
		set rh [winfo reqheight $dlg]

		if {$gw != $rw || $gh != $rh} {
			set Priv(geometry) $g
		} elseif {[info exists Priv(geometry)]} {
			scan $Priv(geometry) "%ux%u" pw ph
			if {$gw < $pw || $gh < $ph} { set Priv(geometry) $g }
		}
	}
}


proc TabChanged {tabs {resized false}} {
	variable Priv

	set w [winfo width $tabs.$Priv(current-method)]

	if {$w <= 1} { return }

	set parts [split [$tabs select] .]
	set Priv(current-method) [lindex $parts end]

	if {$Priv(need-configure:$Priv(current-method))} {
		set h [winfo height $tabs.$Priv(current-method)]
		namespace eval $Priv(current-method) [list Configure $w $h]
		set Priv(need-configure:$Priv(current-method)) 0
	}

	scan $Priv(rgb) "\#%2x%2x%2x" r g b
	namespace eval $Priv(current-method) [list Update $r $g $b $resized]

	if {!$resized} { focus $tabs }
}


proc AddCurrentColor {w usercolors} {
	variable Priv

	addToList $usercolors $Priv(rgb)

	set count 0
	foreach color [set $usercolors] {
		if {$color ne ""} {
			set btn $w.coloruser$count
			catch { destroy $btn.empty }
			$btn configure -background $color
			tooltip $btn [extendColorName $color]
		}
		incr count
	}
}


proc ShowColor {w color} {
	if {[string match *old $w]} {
		tooltip $w [extendColorName $color]
	}

	$w configure -background $color
	scan $color "\#%2x%2x%2x" r g b
	set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
	$w itemconfigure label -fill [expr {$luma < 128 ? "white" : "black"}]
}


proc SelectRGB {type count} {
	variable Priv

	set w $Priv(pane).color$type$count
	SetColor [$w cget -background]
	scan $Priv(rgb) "\#%2x%2x%2x" r g b
	namespace eval $Priv(current-method) [list Update $r $g $b false]
}


proc SetColor {rgb} {
	variable Priv

	set Priv(rgb) $rgb
	set Priv(hexcode) [string range $rgb 1 end]
	foreach recv $Priv(receiver) {
		event generate $recv <<ChooseColorSelected>> -data $rgb
	}
}


proc SetRGB {rgb} {
	SetColor [format "#%02x%02x%02x" {*}$rgb]
}


proc AcceptHexCode {} {
	variable Priv

	if {[string length $Priv(hexcode)] == 6} {
		SetColor "#$Priv(hexcode)"
		scan $Priv(hexcode) "%2x%2x%2x" r g b
		namespace eval $Priv(current-method) [list Update $r $g $b false]
	} else {
		set Priv(hexcode) [string range $Priv(rgb) 1 end]
		bell
	}
}


proc Clip {val min max} {
	if {$val < $min} { return $min }
	if {$val > $max} { return $max }
	return $val
}
namespace export Clip

namespace eval circle {

lappend [namespace parent]::Methods circle

namespace import [namespace parent]::hsv2rgb
namespace import [namespace parent]::rgb2hsv
namespace import [namespace parent]::Clip
namespace import ::tcl::mathfunc::*


proc ComputeWidth {height} {
	return [expr {round((0.067*($height - 6))/(1 - 0.067)) + $height - 4}]
}


proc Icon {} { return $icon::22x22::Circle }


proc MakeFrame {container} {
	variable Vars
	variable ColorCircle

	set size 218
	set Vars(size) 0
	set Vars(after) {}

	set cchoose1 [tk::canvas $container.hs \
		-width $size \
		-height $size \
		-borderwidth 2 \
		-relief sunken \
		-highlightthickness 1 \
	]
	set cchoose2 [tk::canvas $container.v \
		-width 15 \
		-height $size \
		-borderwidth 2 \
		-relief sunken \
	]
	
	place $cchoose1 -x 0 -y 0
	place $cchoose2 -x 229 -y 0

	bind $cchoose1 <Up>					[namespace code { MoveHS 0 +1 }]
	bind $cchoose1 <Down>				[namespace code { MoveHS 0 -1 }]
	bind $cchoose1 <Left>				[namespace code { MoveHS -1 0 }]
	bind $cchoose1 <Right>				[namespace code { MoveHS +1 0 }]
	bind $cchoose1 <Control-Up>		[namespace code { MoveHS 0 +1 10 }]
	bind $cchoose1 <Control-Down>		[namespace code { MoveHS 0 -1 10 }]
	bind $cchoose1 <Control-Left>		[namespace code { MoveHS -1 0 10 }]
	bind $cchoose1 <Control-Right>	[namespace code { MoveHS +1 0 10 }]
	bind $cchoose1 <ButtonPress-1>	[namespace code { SelectHS %x %y }]
	bind $cchoose1 <ButtonRelease-1>	[namespace code { DrawValues }]
	bind $cchoose1 <B1-Motion>			[namespace code { SelectHS %x %y }]
	bind $cchoose1 <ButtonPress-1>	{+ focus %W }

	bind $cchoose2 <Up>					[namespace code { MoveV -1 }]
	bind $cchoose2 <Down>				[namespace code { MoveV +1 }]
	bind $cchoose2 <Control-Up>		[namespace code { MoveV -10 }]
	bind $cchoose2 <Control-Down>		[namespace code { MoveV +10 }]
	bind $cchoose2 <Prior>				[namespace code { MoveV -10 }]
	bind $cchoose2 <Next>				[namespace code { MoveV +10 }]
	bind $cchoose2 <Home>				[namespace code { MoveV -9999 }]
	bind $cchoose2 <End>					[namespace code { MoveV +9999 }]
	bind $cchoose2 <ButtonPress-1>	[namespace code { SelectV %x %y }]
	bind $cchoose2 <B1-Motion>			[namespace code { SelectV %x %y }]
	bind $cchoose2 <ButtonPress-1>	{+ focus %W }

	set Vars(widget:hs) $cchoose1
	set Vars(widget:v) $cchoose2
}


proc Configure {width height} {
	variable [namespace parent]::icon::11x11::ArrowRight
	variable [namespace parent]::icon::11x11::ActiveArrowRight
	variable Vars

	incr height -6
	incr width -17

	set vbarSize [expr {round(0.067*$width)}]
	set size [expr {$width - $vbarSize}]
	if {$size > $height} {
		set size $height
		set vbarSize [expr {round((0.067*$size)/(1 - 0.067))}]
	}
	if {$Vars(size) == $size} { return }
	set Vars(size) $size

	### setup Hue-Saturation window #####################
	$Vars(widget:hs) configure -height $size
	$Vars(widget:hs) configure -width $size
	$Vars(widget:hs) xview moveto 0
	$Vars(widget:hs) yview moveto 0
	$Vars(widget:hs) delete circle
	MakeCircle $Vars(widget:hs) $size {36 36 36 36 36 36 36 36 36 12 1}

	if {[llength [$Vars(widget:hs) find withtag crosshair1]] == 0} {
		MakeCrossHair $Vars(widget:hs)
	}

	### setup Value window ##############################
	$Vars(widget:v) configure -height $size
	$Vars(widget:v) configure -width $vbarSize
	$Vars(widget:v) xview moveto 0
	$Vars(widget:v) yview moveto 0

#	place forget $Vars(widget:v)
	place $Vars(widget:v) -x [expr {$size + 11}] -y 0

	if {[llength [$Vars(widget:v) find withtag all]] == 0} {
		for {set i 1} {$i <= 255} {incr i} {
			$Vars(widget:v) create rectangle 0 0 0 0 -width 0 -tags val[expr {255 - $i}]
		}

		$Vars(widget:v) create image 0 0 -anchor w -image $ArrowRight -tags target
		$Vars(widget:v) create image 0 0 -anchor w -image $ActiveArrowRight -tags active
		$Vars(widget:v) itemconfigure active -state hidden

		bind $Vars(widget:v) <FocusIn> "
			$Vars(widget:v) itemconfigure target -state hidden
			$Vars(widget:v) itemconfigure active -state normal
		"
		bind $Vars(widget:v) <FocusOut> "
			$Vars(widget:v) itemconfigure target -state normal
			$Vars(widget:v) itemconfigure active -state hidden
		"
	}

	set ncells	[min $size 255]
	set step		[expr {double($size)/double($ncells)}]
	set y0		0

	for {set i 1} {$i <= $ncells} {incr i} {
		set y1 [expr {round($i*$step)}]
		$Vars(widget:v) coords val[expr {$ncells - $i}] 0 $y0 $vbarSize $y1
		set y0 $y1
	}
	for {} {$i <= 255} {incr i} {
		$Vars(widget:v) coords val[expr {$ncells - $i}] 0 0 0 0
	}

	$Vars(widget:hs) raise crosshair1
	$Vars(widget:hs) raise crosshair2
}


proc MakeCrossHair {canv} {
	$canv create line 0 0 1 1 -width 1 -tags {n1 crosshair1}
	$canv create line 0 0 1 1 -width 1 -tags {w1 crosshair1}
	$canv create line 0 0 1 1 -width 1 -tags {e1 crosshair1}
	$canv create line 0 0 1 1 -width 1 -tags {s1 crosshair1}
	$canv create line 0 0 1 1 -width 1 -tags {n2 crosshair2}
	$canv create line 0 0 1 1 -width 1 -tags {w2 crosshair2}
	$canv create line 0 0 1 1 -width 1 -tags {e2 crosshair2}
	$canv create line 0 0 1 1 -width 1 -tags {s2 crosshair2}
}


proc Update {r g b afterResize} {
	variable Vars

	set Vars(hsv) [rgb2hsv $r $g $b]
	lassign $Vars(hsv) h s v

	Reflect $h $s
	DrawValues
	set y [expr {round((1.0 - $v)*($Vars(size) - 1))}]
	$Vars(widget:v) coords target 1 $y
	$Vars(widget:v) coords active 1 $y
}


proc Reflect {hue sat} {
	variable Vars

	set w		[expr {$Vars(size) - 1}]
	set x		[expr {round(0.5*$w*(1.0 + cos($hue*0.017453292519943)*$sat))}]
	set y		[expr {round(0.5*$w*(1.0 + sin($hue*0.017453292519943)*$sat))}]
	set y		[expr {$w - $y}]
	set x		[expr {round($x)}]
	set y		[expr {round($y)}]
	set rgb	[hsv2rgb $hue $sat 1.0]

	DrawCrosshair $Vars(widget:hs) $x $y $rgb
}


proc SelectHS {x y} {
	variable Vars

	set x		[expr {$x - 3}]	;# take border into account
	set y		[expr {$y - 3}]	;# take border into account
	set y		[expr {$Vars(size) - $y - 1}]
	set xc	[expr {$x/double(2*$Vars(size)) - 1.0}]
	set yc	[expr {1.0 - $y/double(2*$Vars(size))}]
	set xh	[expr {$x - $Vars(size)/2.0}]
	set yh	[expr {$y - $Vars(size)/2.0}]
	set h		[expr {57.295779513082*atan2($yh,$xh)}]	;# 180/PI*atan2(yh,xy)
	set s		[min [expr {2.0*(hypot($xh,$yh)/$Vars(size))}] 1.0]
	set v		[lindex $Vars(hsv) 2]

	if {$h < 0} { set h [expr {$h + 360.0}] }

	Reflect $h $s
	[namespace parent]::SetRGB [hsv2rgb $h $s $v]
	set Vars(hsv) [list $h $s $v]

	after cancel $Vars(after)
	set Vars(after) [after 30 [namespace code { DrawValues }]]
}


proc MoveHS {xdir ydir {repeat 1}} {
	variable Vars

	lassign [CrosshairCoords $Vars(widget:hs)] x y

	set y [expr {$Vars(size) - $y}]
	set x [expr {$x + $repeat*$xdir}]
	set y [expr {$y + $repeat*$ydir}]

	for {} {$repeat > 0} {incr repeat -1} {
		set xh	[expr {$x - $Vars(size)/2}]
		set yh	[expr {$y - $Vars(size)/2}]
		set s		[expr {2.0*(hypot($xh,$yh)/$Vars(size))}]

		if {$s <= 1.0} { break }

		set x [expr {$x - $xdir}]
		set y [expr {$y - $ydir}]
	}

	if {$s > 1.0} { return }

	set y [expr {$Vars(size) - round($y)}]
	set x [expr {round($x)}]
	set y [expr {round($y)}]
	set h [expr {57.295779513082*atan2($yh,$xh)}]	;# 180/PI*atan2(yh,xy)
	set v [lindex $Vars(hsv) 2]

	if {$h < 0} { set h [expr {$h + 360.0}] }

	set Vars(hsv) [list $h $s $v]
	[namespace parent]::SetRGB [hsv2rgb $h $s $v]
	DrawCrosshair $Vars(widget:hs) $x $y [hsv2rgb $h $s 1.0]

	after cancel $Vars(after)
	set Vars(after) [after idle [namespace code { DrawValues }]]
}


proc SelectV {x y} {
	variable Vars

	set y [Clip $y 0 [expr {$Vars(size) - 1}]]
	$Vars(widget:v) coords target 1 $y
	$Vars(widget:v) coords active 1 $y
	set v [expr {1.0 - double($y*$Vars(size))/double($Vars(size)*($Vars(size) - 1))}]
	set Vars(hsv) [lreplace $Vars(hsv) 2 2 $v]
	[namespace parent]::SetRGB [hsv2rgb {*}$Vars(hsv)]
}


proc MoveV {ydir} {
	variable Vars

	lassign [$Vars(widget:v) coords target] x y
	SelectV [expr {round($x)}] [expr {round($y) + $ydir}]
}


proc DrawValues {} {
	variable Vars

	set ncells	[min $Vars(size) 255]
	set step		[expr {1.0/($ncells - 1)}]

	lassign $Vars(hsv) hue sat

	for {set i 0} {$i < $ncells} {incr i} {
		set rgb [hsv2rgb $hue $sat [expr {$i*$step}]]
		$Vars(widget:v) itemconfigure val$i -fill [format "\#%02x%02x%02x" {*}$rgb]
	}
}


proc MakeCircle {canv size sectors} {
	set circles	[llength $sectors]
	set step		[expr {$size/(2*$circles - 1)}]
	set x2		[expr {$size - 1}]
	set y2		[expr {$size - 1}]
	set x1		0
	set y1		0

	for {set sat 0} {$sat < $circles} {incr sat} {
		set nsecs [lindex $sectors $sat]
		set angle [expr {360.0/$nsecs}]

		for {set hue 0} {$hue < $nsecs} {incr hue} {
			set a [expr {(360.0*$hue)/$nsecs - $angle/2.0}]
			set h [expr {(360.0*$hue + (720.0/$nsecs))/$nsecs}]
			set s [expr {double($circles - $sat - 1)/$circles}]
			set c [format "#%02x%02x%02x" {*}[hsv2rgb $h $s 1]]

			if {$nsecs == 1} {
				$canv create arc $x1 $y1 $x2 $y2 \
					-fill $c -outline $c -width 0 -style chord -extent 359.99 -tags circle
			} else {
				$canv create arc $x1 $y1 $x2 $y2 \
					-start $a -extent $angle -fill $c -outline $c -width 0 -tags circle
			}
		}

		set x1 [expr {$x1 + $step}]
		set x2 [expr {$x2 - $step}]
		set y1 [expr {$y1 + $step}]
		set y2 [expr {$y2 - $step}]
	}
}


proc DrawCrosshair {canv x y rgb} {
	lassign $rgb r g b

	set max	[max $r $g $b]
	set min	[min $r $g $b]
	set sat	[expr {$max == 0 ? 0 : double($max - $min)/double($max)}]
	set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
	set fg	[expr {$luma < 128 || ($b == 255 && $r + $g < 320) ? "white" : "black"}]
	set size	[$canv cget -width]

	if {$size > 300 } {
		$canv itemconfigure crosshair2 -state hidden
		foreach d {n1 e1 s1 w1} {
			$canv itemconfigure $d -width 3
		}
		$canv coords n1 $x [expr {$y - 8}] $x [expr {$y - 2}]
		$canv coords s1 $x [expr {$y + 3}] $x [expr {$y + 9}]
		$canv coords e1 [expr {$x - 2}] $y [expr {$x - 8}] $y
		$canv coords w1 [expr {$x + 3}] $y [expr {$x + 9}] $y
	} else {
		$canv itemconfigure crosshair2 -state normal
		foreach d {n1 e1 s1 w1} {
			$canv itemconfigure $d -width 1
		}
		set x1 $x
		set y1 $y
		set x2 [expr {$x + 1}]
		set y2 [expr {$y + 1}]
		$canv coords n1 $x1 [expr {$y1 - 6}] $x1 [expr {$y1 - 1}]
		$canv coords n2 $x2 [expr {$y2 - 6}] $x2 [expr {$y2 - 1}]
		$canv coords s1 $x1 [expr {$y1 + 2}] $x1 [expr {$y1 + 7}]
		$canv coords s2 $x2 [expr {$y2 + 2}] $x2 [expr {$y2 + 7}]
		$canv coords e1 [expr {$x1 - 1}] $y1 [expr {$x1 - 6}] $y1
		$canv coords e2 [expr {$x2 - 1}] $y2 [expr {$x2 - 6}] $y2
		$canv coords w1 [expr {$x1 + 2}] $y1 [expr {$x1 + 7}] $y1
		$canv coords w2 [expr {$x2 + 2}] $y2 [expr {$x2 + 7}] $y2
		$canv itemconfigure crosshair2 -fill [expr {$fg eq "white" ? "black" : "white"}]
	}

	$canv itemconfigure crosshair1 -fill $fg
}


proc CrosshairCoords {canv} {
	lassign [$canv coords n1] x y

	set y [expr {round($y)}]
	set w [$canv cget -width]
	set n [expr {$w > 300 ? 8 : 6}]
	incr y [expr {$w > 300 ? 8 : 6}]

	return [list $x $y]
}


namespace eval icon {
namespace eval 22x22 {

set Circle [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAGCElEQVQ4y3WVW2xcVxWG19p7
	n33Omas9E48Te6gnju00Tdw4cdM8tDQhRiUVrVxQChIJEqJ5RULqS7kJQZ+QgkRBVEhtQRWI
	tipIKYiqVYPaNI1JwSRO4ja2azuJHWdszy3jM5dzzj57L14oBJH+T2st6f+1nr4f4VP0g53f
	Rla8eU+vKY316LXhDt7KSGq1CKNVBWYusKyzqQcemNl38qS5kx+JCBGRbj8eTz65Pw7WU70x
	2r8zuZHsb86KbHWRLPK1QdBqZLfxYm64fmlq0rPNs/knjpze9eyv/ycDb19e+9EfEqd+9vZ3
	u3PdR+8eHcwkw0CmZyaxsPBX3e0voUUhx0cOI42Po06nqFUtRVdfea65Wr/++66DDz89+vM/
	NT/J4p8M3znwE3fqj5PP7xsb/dqez+/JqpKS3uwao/lFzPhFk4INFPeNCDh0iCEiYxzRynXy
	9IGHbB0Ud9/46Mzot8YPvv7iuUUFAMAAAKbeW2KLk8snRh++b3xo3/Zkfb7OK7MVLM1Usdlm
	5INjdDxlCBnBO+8AzM8CqCYwaJOdsKBw5Ek73Z0eK868f+IfP3wc//Px/MnOL96Vzzzz4KN7
	nI25GpamS7B2eR0pVOBAQFmshtmdm0Hu2i7wM70I9XWClUsahvqI2RrCS3+G9Oe+IdavnLun
	eu2j869+HM3zHz89yf/23uoLjx69vy8oayhdLOu1C0WiSCMDAgmh6cRbweYdWZA2CZQMoJAz
	MNSr4eopDdU5xkfHOSS7EOMZXr7yQf/xgzteEs//Zn5vfmhguBzl2My0R9XzlunUKZPAhkYi
	HqJNbZEyEXBNoS+QcQTHicBWCNznEMsyBoDMRJC9+35ud+Z21VYWRnigxo/cu7dvbL2ckWcm
	4lgPYixECQBoOBptgaI4NFUXrgbxLiTWbYWYaEZQneaw47MuVBYYZHoxEjYoLiEIPV0tzlwT
	woJBTRL/OcWp4qeZiwl+C9JQw07swaJSaEVJ5lGxtqQSy9OtVCHHeWBiOLhbghUQDOw0UJ0A
	kz7MDDBKbh8S7CobFrEk755falGpqSGKS1IgyecONHgCaqIT6jxplBMZu6uEYrCm+zsWolT/
	gM1zoQ/xUICb4JFXpyjlWWtLZ6C4/oFmeeoROo3iur9BWAgNOtoYx44Cm4c6ZgVBzA4aNkUe
	XzXNTIrCAcfANk5bu2Ya6U1bGJfCBotbqt3Bbi79VC17NaZcIspYJPx+1gjdgKx8I+S9bUVd
	0scUBjrJQt82kWrVlV++oT0oYqPgMb9fWWFn6AzIa3YamcPMCt9o/h3rUcCMNACASke4KmCE
	z1M6ApOvER/sQJZ3pYlLAeDHdGMtMtcvNBvVs4GiWWpZVazaIa9KwgO8woZACN6Y4bU6Yd3T
	CAhEDAxKPiOcrfJ0O6aeihKeRF5BxmwwMkEU1gzWP2xC8UygKxctn9dMqREaT2mnQkRrdMsf
	adb4ljI4tKYFBQTi3/SxY4mz4iv3FiZeWFlYjMAMR+V1JgSAaNvGBDc0Lb2vqTgpqVFySEYh
	eSZUbXIXfRReSNFCGXVfMVI9GwZ7AXgHAFmMXd1212PnEAAg+8YbRytKvQREDJkGYbU09z70
	4eZp39y6Io1pSRTksy3oww6MYQZc9MnIstaZpoECABtCEH1IuJnJY998LHxFAAB8vb//5V/M
	zX5Z6/BL5JUoKl8xpnQeeGPeAfJtxpAhQ0KNxnDDoqxmBo0IiIyPqFvATB1Ie0y8tXfbV18D
	+O1/eZx98y+pWq34tinPjeLNSQXr0wTtqgDQAhgAAkbgQkB5YrzA7XgmzhIyDjEep1bkUajK
	5w919n/h1Qfnav8H+v0v/3LT1Mfv/g7XLx202mXGSHPOGEohwZWuSSQTUTqfhkRfQjhph3GL
	w8WNi7TiL7+5PdV7bOqhxdodGwQAYOv3jvBaZer4Jml9v9CV35xLdYErXXSkA67rktvhgk5r
	uBxcNhP1iWUVhieOpY+++NzhX6lPrabb1fPEVifUzce3bOoe68n0DMeT8Rg6iCVT2phW0xfC
	WHgqV8m9tfjMYvtO/n8Bt4YbaS8sLmEAAAAASUVORK5CYII=
}]

} ;# namespace 22x22
} ;# namespace icon
} ;# namespace circle

namespace eval swatches {

lappend [namespace parent]::Methods swatches

namespace import [namespace parent]::Clip


proc Icon {} { return $icon::16x16::Swatches }


proc MakeFrame {container} {
	variable Vars

	set f [tk::frame $container.f -relief flat -takefocus 0]
	pack $f -anchor n -expand yes -fill both -padx 5 -pady 5
	set bg [::ttk::style lookup $::ttk::currentTheme -background]
	set Vars(widget:buttons) [tk::canvas $f.buttons \
		-height 100 \
		-width 100 \
		-background [$f cget -background] \
	]
	pack $Vars(widget:buttons) -expand yes -fill both

	bind $Vars(widget:buttons) <Left>	[namespace code { Move -1  0 }]
	bind $Vars(widget:buttons) <Right>	[namespace code { Move +1  0 }]
	bind $Vars(widget:buttons) <Up>		[namespace code { Move  0 -1 }]
	bind $Vars(widget:buttons) <Down>	[namespace code { Move  0 +1 }]
	bind $Vars(widget:buttons) <space>	[namespace code { SetColor %W }]

	set Vars(size:x) 0
	set Vars(size:y) 0
}


proc SetColor {w} {
	variable Vars
	[namespace parent]::SetColor [$w itemcget button-$Vars(row)-$Vars(col) -fill]
}


proc Configure {width height} {
	variable Vars
	variable Palette

	update idletasks

	set width [winfo width $Vars(widget:buttons)]
	if {$width <= 1} {
		set width [$Vars(widget:buttons) cget -width]
	}
	if {$Vars(size:x) == $width && $Vars(size:y) == $height} { return }

	if {[llength [$Vars(widget:buttons) find withtag all]] == 0} {
		set row	0
		set col	0

		foreach line $Palette {
			foreach cell $line {
				$Vars(widget:buttons) create rectangle 0 0 0 0 -width 0 -fill black -tags border-$row-$col
				$Vars(widget:buttons) create rectangle 0 0 0 0 -width 0 -fill \#$cell -tags button-$row-$col
				$Vars(widget:buttons) bind button-$row-$col <ButtonPress-1> \
					[namespace code [list SelectColor button-$row-$col]]
				set color [[namespace parent]::extendColorName \#$cell]
				[namespace parent]::tooltip $Vars(widget:buttons) -item button-$row-$col $color
				incr col
			}

			incr row
			set col 0
		}

		$Vars(widget:buttons) create rectangle 0 0 0 0 -width 0 -fill white -tags {hilite white}
		$Vars(widget:buttons) create rectangle 0 0 0 0 -width 0 -fill black -tags {hilite black}
		$Vars(widget:buttons) create rectangle 0 0 0 0 -width 0 -fill black -tags {hilite color}
		$Vars(widget:buttons) bind hilite <ButtonPress-1> [namespace code [list SelectColor color]]
		$Vars(widget:buttons) raise white
		$Vars(widget:buttons) raise black
		$Vars(widget:buttons) raise color

		bind $Vars(widget:buttons) <FocusIn> [namespace code ShowHilite]
		bind $Vars(widget:buttons) <FocusOut> [namespace code ShowHilite]
	}

	set Vars(size:x) $width
	set Vars(size:y) $height

	incr height -10

	set nrows	[llength $Palette]
	set ncols	[llength [lindex $Palette 0]]
	set over		[expr {min(($width - $ncols + 1)/$ncols, ($height - $nrows + 1)/$nrows)/2 - 1}]
	set over		[expr {min(10, max(6, $over))}]
	set hbut		[expr {($width - 2*$over + 1)/$ncols}]
	set vbut		[expr {($height - 2*$over + 1)/$nrows}]
	set hpal		[expr {$ncols*$hbut - 1}]
	set vpal		[expr {$nrows*$vbut - 1}]
	set hmar		[expr {($width - $hpal)/2}]
	set vmar		[expr {($height - $vpal)/2}]

	set row	0
	set col	0
	set x		$hmar
	set y		$vmar

	foreach line $Palette {
		foreach cell $line {
			$Vars(widget:buttons) coords border-$row-$col \
				$x $y \
				[expr {$x + $hbut - 1}] [expr {$y + $vbut - 1}] \
				;
			$Vars(widget:buttons) coords button-$row-$col \
				[expr {$x + 1}] [expr {$y + 1}] \
				[expr {$x + $hbut - 2}] [expr {$y + $vbut - 2}] \
				;
			incr x $hbut
			incr col
		}

		set x $hmar
		incr y $vbut
		incr row
		set col 0
	}

	set Vars(over) $over
}


proc SelectColor {tag} {
	variable Vars

	set rgb [$Vars(widget:buttons) itemcget $tag -fill]
	[namespace parent]::SetColor $rgb
	[namespace current]::Reflect [string range $rgb 1 end]
	focus $Vars(widget:buttons)
}


proc ShowHilite {} {
	variable Vars

	set o $Vars(over)
	set color [$Vars(widget:buttons) itemcget button-$Vars(row)-$Vars(col) -fill]
	lassign [$Vars(widget:buttons) coords button-$Vars(row)-$Vars(col)] x1 y1 x2 y2
	if {[focus] eq $Vars(widget:buttons)} { set increments {-1 -2 0} } else { set increments {-1 -1 0} }
	foreach tag {white black color} incr $increments {
		$Vars(widget:buttons) coords $tag \
			[expr {$x1 - $o}] [expr {$y1 - $o}] [expr {$x2 + $o}] [expr {$y2 + $o}]
		incr o $incr
	}
	$Vars(widget:buttons) itemconfigure color -fill $color
	set color [[namespace parent]::extendColorName $color]
	[namespace parent]::tooltip $Vars(widget:buttons) -item color $color
}


proc Move {xdir ydir} {
	variable Vars
	variable Palette

	set Vars(row) [Clip [expr {$Vars(row) + $ydir}] 0 [expr {[llength $Palette] - 1}]]
	set Vars(col) [Clip [expr {$Vars(col) + $xdir}] 0 [expr {[llength [lindex $Palette 0]] - 1}]]

	ShowHilite
}


proc Reflect {rgb} {
	scan $rgb "%2x%2x%2x" r g b
	Update $r $g $b no
}


proc Update {r g b afterResize} {
	variable Vars
	variable Palette

	if {!$afterResize} {
		set bestDist [expr {3*255*255 + 1}]

		set col 0
		set row 0

		foreach line $Palette {
			foreach cell $line {
				scan $cell "%2x%2x%2x" r2 g2 b2

				set d1	[expr {$r - $r2}]
				set d2	[expr {$g - $g2}]
				set d3	[expr {$b - $b2}]
				set dist	[expr {$d1*$d1+ $d2*$d2 + $d3*$d3}]

				if {$dist < $bestDist} {
					set bestDist $dist
					set Vars(row) $row
					set Vars(col) $col
				}

				incr col
			}

			set col 0
			incr row
		}
	}

	ShowHilite
}


set Palette {
	{ ffffff eeeeee dddddd cccccc bbbbbb aaaaaa 999999 888888 \
	  777777 666666 555555 444444 333333 222222 111111 000000 }
	{ eeeeee ffd6d6 ffded6 ffefd6 fff7d6 f7ffd6 f7ffd6 d6ffd6 \
	  d6ffef d6ffff d6f7ff d6e7ff d6d6ff efd6ff ffd6ff ffd6ff }
	{ dddddd ffb5b5 ffc6b5 ffdeb5 ffefb5 ffffb5 e7ffb5 b5ffb5 \
	  b5ffde bfffff b5e7ff c6d6ff c6c6ff deb5ff ffb5ff ffb5de }
	{ cccccc ffa5a5 ffbda5 ffd6a5 ffe794 ffff94 d6ff94 a5ffa5 \
	  a5ffd6 a5ffff a5e7ff a5c6ff a5a5ff d6a5ff ffa5ff ffa5d6 }
	{ bbbbbb ff9494 ffa584 ffc684 ffde73 ffff73 d6ff84 94ff94 \
	  94ffce 84ffff 94deff 94b5ff 9494ff ce94ff ff84ff ff94ce }
	{ aaaaaa ff8484 ff9473 ffb563 ffde63 ffff42 c6ff63 73ff73 \
	  73ffbd 73ffff 84d6ff 84adff 8484ff c684ff ff73ff ff84c6 }
	{ 999999 ff6363 ff7b52 ffad52 ffd642 f7f700 b5ff42 63ff63 \
	  63ffb5 52ffff 63ceff 73a5ff 7373ff b563ff ff52ff ff63b5 }
	{ 888888 ff5252 ff7342 ff9c31 ffc600 f7f700 9cff00 52ff52 \
	  52ffad 00f7f7 52c6ff 528cff 6363ff ad52ff ff42ff ff52ad }
	{ 777777 ff4242 ff5a21 ff8400 f7b500 e7e700 94f700 00ff00 \
	  00ff84 00f5ff 42c6ff 4284ff 5252ff a542ff ff21ff ff42a5 }
	{ 666666 ff2121 ff4200 e77300 d69c00 c6c600 84d600 00e700 \
	  00e773 00d6d6 00adff 3173ff 3131ff 9421ff ff00ff ff2194 }
	{ 555555 ff0000 e73900 d66b00 c69400 b5b500 73c600 00d600 \
	  00d66b 00c6c6 0094e7 0052ff 2121ff 8400ff e700e7 ff0084 }
	{ 444444 e70000 c63100 b55a00 a57b00 a5a500 63a500 00b500 \
	  00b55a 00a5a5 0084c6 004ae7 0000ff 7300e7 cd00cd e70073 }
	{ 333333 c60000 a52900 a55200 946b00 949400 5a9400 00a500 \
	  00a552 009494 006ba5 0042c6 0000d6 6300c6 a500a5 c60063 }
	{ 222222 940000 942100 844200 846300 737300 528400 008400 \
	  008442 008484 006394 003194 0000a5 4a0094 940094 94004a }
	{ 111111 730000 731800 633100 634a00 636300 396300 006300 \
	  006331 006363 004a73 002173 000084 390073 730073 730039 }
	{ 000000 520000 522100 522900 522900 525200 315200 005200 \
	  005229 005252 003152 001852 000052 290052 520052 520029 }
}


namespace eval icon {
namespace eval 16x16 {

set Swatches [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAAIGNIUk0AAHomAACAhAAA+gAA
	AIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAEZ0FNQQAAsY58+1GTAAAAAXNSR0IArs4c6QAA
	AAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAAOxAAADsQBlSsOGwAAA7VJREFUeNq1lV1rHFUY
	x/+TnZ2mSWpXWdJEKi4BZalaFSRU0puAtldFivSqvYgokX6AUvoFBOk3MAVttb60V3oRvbCI
	0KqlxASETcXGvLimm8xmN9ndmdmdmXOOz3N2Z3Zng5cdOBzOPnN+c57z/M5ZY3EGGYR4DX2P
	ECi98RUefgGcUMBgb8wAmheA374E8gIY658bAksmQ4cnMj+NTGQ6RAVZ97H14PFnNHpveHT0
	dm5q6qiOSQnlOFhfWCiiWn1OApdfPH16xhoa0mHlebCXl7G9vj5t8g8MHXsrB/j0/UYAv+Qw
	WL88cuSIeezsWSAIIG0bqlyGXSiYBNZxAmMom4Xa2YGkmKJ3CIyBeP0dKBxqbpDMrQfKPY97
	n16ocl39mxmlH0O5eT0TKf1eqAZ0JmsorVzyFnGsE4/BvKecvl4pQVt2d6JwXeWsrEBWKhoi
	NjYglVJR3KG0Q86A4iG9F1DVNZirz4WK9jR6Bgzc495eXb35w9xcNpE6UO70936+caNfCqSA
	Ep7UY5yZS5/IDGdvHx552myvQsEPPbVd3rz57ax/6Y8P078efPZQrrvnCt5mfe2VufDNz4Gr
	o/n8+YF02ojkb5RKoVOpnDNTSA3mn3/16OSxaaphAEdUYNc28P2d73T6DJ14/3j7ELikvuPj
	72+WaVDng5KdnJ0d17o1GrqAhfl5FO7fH4x1i6BOuANX7O7PrQPV1giV1K0D1cbQAepaoUQM
	5d4Te/8PJS2VL7pQAql6XUNlv8eB8mKoG1awF26id08T0G0nuVrSTIZh7Dp/pK0bRPPRxnKx
	aK+YQoUIVZOE155qpbhQek8p/WilzZq/Fmn34Natx4YQBp9G1WzSUQhCvqSenG65Mx/lIYzL
	+wIk/+r8lWvvfGJdpWG2L1xmFRcv4APaqan+uUriYxPKGDt18uWZt0++pH+seT6KWzV8+vUd
	Hl4bz+bOn5p8d5wHLenCk7u4u/AjHdN/LzH0hYuvz1iHD7RrQUUu/1KEvbh1Xes2dDCN7DMj
	MA9YMEwLMpWOv26apnFoOAOL3hkYFDAs2ktDGFGcodZT1NIpWKZBV0E7FHu8S5WvNqhR9fec
	5LXYkk5sDPfsfNKaoGtOILq6NWkQQSvU/1N2eubJBJS1FMpPOk5uxVcujyPww0clAgfwSKcq
	fVkEYTxvr7ET/l64C59cD6RHq2+g5Yn4Bd5TnT6vlKD1qtcBm62ltc3taWp9d5/SV1/N3T33
	51/1xJ8pux9Vnwu1zzUTS/8B4LWNt4LSXHMAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace swatches

namespace eval x11 {

lappend [namespace parent]::Methods x11

set CellHeight 20


proc ComputeHeight {adjHeight nusercolors nrecentcolors} {
	variable CellHeight
	variable Vars

	set nrows [expr {($nrecentcolors + 5)/6 + ($nusercolors + 5)/6 + 5}]
	if {$nrecentcolors > 0} { incr nrows }
	if {$nrecentcolors + $nusercolors == 0} { incr nrows 2 }
	return [expr {$nrows*$CellHeight + [expr {($adjHeight/$CellHeight)*$CellHeight}] + 6}]
}


proc Icon {} { return $icon::22x22::Palette }


proc MakeFrame {container} {
	variable [namespace parent]::Priv
	variable CellHeight
	variable Palette
	variable Vars

	set height	[expr {$Priv(notebook-size:y) - 6}]
	set width	[expr {$Priv(notebook-size:x) - 6}]

	set canvas [tk::canvas $container.list \
		-yscrollcommand [ list $container.vsb set] \
		-yscrollincrement $CellHeight \
		-width $width \
		-height $height \
		-relief sunken \
		-borderwidth 2 \
	]
	$canvas xview moveto 0
	$canvas yview moveto 0
	set scroll [ttk::scrollbar $container.vsb -orient vert -command "$canvas yview"]
	bind $container.vsb <ButtonRelease-1> [list focus $container.list]
	pack $scroll -side right -fill y
	pack $canvas -side right -fill both -expand yes

	bind $scroll <Button-1>	{ focus %W }
	bind $canvas <Button-1>	[namespace code { Select %W %y }]
	bind $canvas <Home>		[namespace code { Hilite %W 0 }]
	bind $canvas <End>		[namespace code [list Hilite %W [expr {[llength $Palette]/2 - 1}]]]
	bind $canvas <Prior>		[namespace code { Prior %W }]
	bind $canvas <Next>		[namespace code { Next %W }]
	bind $canvas <Up>			[namespace code { Move %W -1 }]
	bind $canvas <Down>		[namespace code { Move %W +1 }]
	bind $canvas <space>		[namespace code Enter]

	set Vars(widget:canvas) $canvas
	set Vars(widget:scrollbar) $scroll
	set Vars(size:x) 0
	set Vars(size:y) 0
	set Vars(selection) -1
}


proc Configure {width height} {
	variable Vars
	variable Palette
	variable CellHeight
	variable icon::18x18::ArrowLeft
	variable icon::18x18::ArrowRight
	variable icon::18x18::ActiveArrowLeft
	variable icon::18x18::ActiveArrowRight

	set canv			$Vars(widget:canvas)
	set cellHeight	$CellHeight
	set height		[expr {(($height - 6)/$CellHeight)*$cellHeight}]

	if {[winfo width $Vars(widget:scrollbar)] <= 1 } { update idletasks }

	if {$Vars(size:x) != $width} {
		set Vars(size:x)	$width
		set width	[expr {$width - [winfo width $Vars(widget:scrollbar)]}]
		set hyinc	[expr {$cellHeight/2}]
		set hwidth	[expr {$width/2}]
		set mark		0

		$canv delete all
		foreach {color name} $Palette {
			scan $color "%2x%2x%2x" r g b
			set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
			set fg [expr {$luma < 128 ? "white" : "black"}]
			set color \#$color

			$canv create rect 0 $mark $width [incr mark $cellHeight] -fill $color -outline {} -tags $color
			$canv create text $hwidth [expr {$mark - $hyinc}] -text $name -fill $fg -tags $color
			$canv bind $color <ButtonPress-1> [namespace code [list [namespace parent]::SetColor $color]]
		}

		$canv create image 10 9 -image $ArrowRight -tags right1
		$canv create image 10 9 -image $ActiveArrowRight -tags right2
		$canv create image [expr {$width - 15}] 9 -image $ArrowLeft -tags left1
		$canv create image [expr {$width - 15}] 9 -image $ActiveArrowLeft -tags left2
		$canv itemconfigure left2 -state hidden
		$canv itemconfigure right2 -state hidden
		$canv config -scrollregion [list 0 0 $height $mark]

		bind $canv <FocusIn> "
			$canv itemconfigure left1 -state hidden
			$canv itemconfigure right1 -state hidden
			$canv itemconfigure left2 -state normal
			$canv itemconfigure right2 -state normal
		"
		bind $canv <FocusOut> "
			$canv itemconfigure left1 -state normal
			$canv itemconfigure right1 -state normal
			$canv itemconfigure left2 -state hidden
			$canv itemconfigure right2 -state hidden
		"
	}
	
	if {$Vars(size:y) != $height} {
		set Vars(size:y) $height
		set Vars(visible)	[expr {$height/$cellHeight}]
		$canv config -scrollregion [list 0 0 $height [expr {([llength $Palette]/2)*$cellHeight}]]
	}
}


proc Update {r g b afterResize} {
	variable Palette
	variable Vars

	if {!$afterResize} {
		set bestDist [expr {3*255*255 + 1}]
		set best 0
		set i 0

		foreach {color name} $Palette {
			scan $color "%2x%2x%2x" r2 g2 b2

			set d1 [expr {$r - $r2}]
			set d2 [expr {$g - $g2}]
			set d3 [expr {$b - $b2}]

			set dist  [expr {$d1*$d1}]
			incr dist [expr {$d2*$d2}]
			incr dist [expr {$d3*$d3}]

			if {$dist < $bestDist} {
				set bestDist $dist
				set best $i
			}

			incr i
		}

		set selection $Vars(selection)
		set Vars(selection) -1
		Hilite $Vars(widget:canvas) $best
		set first [First $Vars(widget:canvas)]
		set last [expr {$first + $Vars(visible)}]
		if {$selection < $first || $last <= $selection} {
			set n [expr {$best - $first}]
			$Vars(widget:canvas) yview scroll [expr {$n - $Vars(visible)/2}] units
		}
	} else {
		set sel $Vars(selection)
		set Vars(selection) -1
		Hilite $Vars(widget:canvas) $sel
	}
}


proc Clip {n} {
	variable Palette

	if {$n < 0} { return 0 }
	if {$n < [llength $Palette]/2} { return $n }
	return [expr {[llength $Palette]/2 - 1}]
}


proc First {w} {
	variable Palette

	set topFraction [lindex [$w yview] 0]
	set first [expr {int(0.5*($topFraction + 0.00001)*[llength $Palette])}]
}


proc Hilite {w n} {
	variable CellHeight
	variable Palette
	variable Vars

	if {$n != $Vars(selection)} {
		set Vars(selection) $n
		set first [First $w]
		set last [expr {$first + $Vars(visible) - 1}]

		if {$Vars(selection) < $first} {
			$w yview scroll [expr {$Vars(selection) - $first}] units
		} elseif {$last < $Vars(selection)} {
			$w yview scroll [expr {$Vars(selection) - $last}] units
		}

		foreach which {left1 left2 right1 right2} {
			lassign [$w coords $which] x1 y1 x2 y2
			$w coords $which $x1 [expr {$CellHeight*$Vars(selection) + 10}]
		}
	}
}


proc Prior {w} {
	variable Vars

	set first [First $w]
	if {$first == $Vars(selection)} { incr first -$Vars(visible) }
	Hilite $w [Clip $first]
}


proc Next {w} {
	variable Vars

	set first [First $w]
	set last [Clip [expr {$first + $Vars(visible) - 1}]]
	if {$last == $Vars(selection)} { incr last $Vars(visible) }
	Hilite $w [Clip $last]
}


proc Move {w dir} {
	variable Vars
	Hilite $w [Clip [expr {$Vars(selection) + $dir}]]
}


proc Select {w y} {
	variable CellHeight
	variable Palette
	variable Vars

	set y [$w canvasy $y]
	set n [expr {int($y/$CellHeight)}]

	if {2*$n < [llength $Palette]} { Hilite $w $n }
	focus $w
}


proc Enter {} {
	variable Palette
	variable Vars

	[namespace parent]::SetColor "#[lindex $Palette [expr {2*$Vars(selection)}]]"
}


set Palette {
	fffafa Snow
	f8f8ff {Ghost White}
	f5f5f5 {White Smoke}
	dcdcdc Gainsboro
	fffaf0 {Floral White}
	fdf5e6 {Old Lace}
	faf0e6 Linen
	faebd7 {Antique White}
	ffefd5 {Papaya Whip}
	ffebcd {Blanched Almond}
	ffe4c4 Bisque
	ffdab9 {Peach Puff}
	ffdead {Navajo White}
	ffe4b5 Moccasin
	fff8dc Cornsilk
	fffff0 Ivory
	fffacd {Lemon Chiffon}
	fff5ee Seashell
	f0fff0 Honeydew
	f5fffa {Mint Cream}
	f0ffff Azure
	f0f8ff {Alice Blue}
	e6e6fa Lavender
	fff0f5 {Lavender Blush}
	ffe4e1 {Misty Rose}
	2f4f4f {Dark Slate Gray}
	696969 {Dim Gray}
	708090 {Slate Gray} 778899 {Light Slate Gray}
	bebebe Gray d3d3d3 {Light Grey}
	191970 {Midnight Blue}
	000080 Navy
	6495ed {Cornflower Blue}
	483d8b {Dark Slate Blue} 6a5acd {Slate Blue} 7b68ee {Medium Slate Blue} 8470ff {Light Slate Blue}
	0000cd {Medium Blue}
	4169e1 {Royal Blue}
	0000ff Blue
	1e90ff {Dodger Blue}
	00bfff {Deep Sky Blue} 87ceeb {Sky Blue} 87cefa {Light Sky Blue}
	4682b4 {Steel Blue} b0c4de {Light Steel Blue}
	add8e6 {Light Blue}
	b0e0e6 {Powder Blue}
	afeeee {Pale Turquoise} 00ced1 {Dark Turquoise} 48d1cc {Medium Turquoise} 40e0d0 Turquoise
	00ffff Cyan e0ffff {Light Cyan}
	5f9ea0 {Cadet Blue}
	66cdaa {Medium Aquamarine} 7fffd4 Aquamarine
	006400 {Dark Green}
	556b2f {Dark Olive Green}
	8fbc8f {Dark Sea Green}
	2e8b57 {Sea Green} 3cb371 {Medium Sea Green} 20b2aa {Light Sea Green}
	98fb98 {Pale Green}
	00ff7f {Spring Green}
	7cfc00 {Lawn Green}
	00ff00 Green
	7fff00 Chartreuse
	00fa9a {Medium Spring Green}
	adff2f {Green Yellow}
	32cd32 {Lime Green}
	9acd32 {Yellow Green}
	228b22 {Forest Green}
	6b8e23 {Olive Drab}
	bdb76b {Dark Khaki}
	f0e68c Khaki
	eee8aa {Pale Goldenrod}
	fafad2 {Light Goldenrod Yellow}
	ffffe0 {Light Yellow} ffff00 Yellow
	ffd700 Gold
	eedd82 {Light Goldenrod} daa520 Goldenrod b8860b {Dark Goldenrod}
	bc8f8f {Rosy Brown}
	cd5c5c {Indian Red}
	8b4513 {Saddle Brown}
	a0522d Sienna
	cd853f Peru
	deb887 Burlywood
	f5f5dc Beige
	f5deb3 Wheat
	f4a460 {Sandy Brown}
	d2b48c Tan
	d2691e Chocolate
	b22222 Firebrick
	a52a2a Brown
	e9967a {Dark Salmon} fa8072 Salmon ffa07a {Light Salmon}
	ffa500 Orange ff8c00 {Dark Orange}
	ff7f50 Coral f08080 {Light Coral}
	ff6347 Tomato
	ff4500 {Orange Red}
	ff0000 Red
	ff69b4 {Hot Pink}
	ff1493 {Deep Pink} ffc0cb Pink ffb6c1 {Light Pink}
	db7093 {Pale Violet Red}
	b03060 Maroon
	c71585 {Medium Violet Red} d02090 {Violet Red}
	ff00ff Magenta
	ee82ee Violet
	dda0dd Plum
	da70d6 Orchid ba55d3 {Medium Orchid} 9932cc {Dark Orchid}
	9400d3 {Dark Violet}
	8a2be2 {Blue Violet}
	a020f0 Purple 9370db {Medium Purple}
	d8bfd8 Thistle
	eee9e9 Snow2 cdc9c9 Snow3 8b8989 Snow4
	eee5de Seashell2 cdc5bf Seashell3 8b8682 Seashell4
	ffefdb AntiqueWhite1 eedfcc AntiqueWhite2
	cdc0b0 AntiqueWhite3 8b8378 AntiqueWhite4
	eed5b7 Bisque2 cdb79e Bisque3 8b7d6b Bisque4
	eecbad PeachPuff2 cdaf95 PeachPuff3 8b7765 PeachPuff4
	eecfa1 NavajoWhite2 cdb38b NavajoWhite3 8b795e NavajoWhite4
	eee9bf LemonChiffon2 cdc9a5 LemonChiffon3 8b8970 LemonChiffon4
	eee8cd Cornsilk2 cdc8b1 Cornsilk3 8b8878 Cornsilk4
	eeeee0 Ivory2 cdcdc1 Ivory3 8b8b83 Ivory4
	e0eee0 Honeydew2 c1cdc1 Honeydew3 838b83 Honeydew4
	eee0e5 LavenderBlush2 cdc1c5 LavenderBlush3 8b8386 LavenderBlush4
	eed5d2 MistyRose2 cdb7b5 MistyRose3 8b7d7b MistyRose4
	e0eeee Azure2 c1cdcd Azure3 838b8b Azure4
	836fff SlateBlue1 7a67ee SlateBlue2 6959cd SlateBlue3 473c8b SlateBlue4
	4876ff RoyalBlue1 436eee RoyalBlue2 3a5fcd RoyalBlue3 27408b RoyalBlue4
	0000ee Blue2 00008b Blue4
	1c86ee DodgerBlue2 1874cd DodgerBlue3 104e8b DodgerBlue4
	63b8ff SteelBlue1 5cacee SteelBlue2 4f94cd SteelBlue3 36648b SteelBlue4
	00b2ee DeepSkyBlue2 009acd DeepSkyBlue3 00688b DeepSkyBlue4
	87ceff SkyBlue1 7ec0ee SkyBlue2 6ca6cd SkyBlue3 4a708b SkyBlue4
	b0e2ff LightSkyBlue1 a4d3ee LightSkyBlue2
	8db6cd LightSkyBlue3 607b8b LightSkyBlue4
	c6e2ff SlateGray1 b9d3ee SlateGray2 9fb6cd SlateGray3 6c7b8b SlateGray4
	cae1ff LightSteelBlue1 bcd2ee LightSteelBlue2
	a2b5cd LightSteelBlue3 6e7b8b LightSteelBlue4
	bfefff LightBlue1 b2dfee LightBlue2 9ac0cd LightBlue3 68838b LightBlue4
	d1eeee LightCyan2 b4cdcd LightCyan3 7a8b8b LightCyan4
	bbffff PaleTurquoise1 aeeeee PaleTurquoise2
	96cdcd PaleTurquoise3 668b8b PaleTurquoise4
	98f5ff CadetBlue1 8ee5ee CadetBlue2 7ac5cd CadetBlue3 53868b CadetBlue4
	00f5ff Turquoise1 00e5ee Turquoise2 00c5cd Turquoise3 00868b Turquoise4
	00eeee Cyan2 00cdcd Cyan3 008b8b Cyan4
	97ffff DarkSlateGray1 8deeee DarkSlateGray2
	79cdcd DarkSlateGray3 528b8b DarkSlateGray4
	76eec6 Aquamarine2 458b74 Aquamarine4
	c1ffc1 DarkSeaGreen1 b4eeb4 DarkSeaGreen2
	9bcd9b DarkSeaGreen3 698b69 DarkSeaGreen4
	54ff9f SeaGreen1 4eee94 SeaGreen2 43cd80 SeaGreen3
	9aff9a PaleGreen1 90ee90 PaleGreen2 7ccd7c PaleGreen3 548b54 PaleGreen4
	00ee76 SpringGreen2 00cd66 SpringGreen3 008b45 SpringGreen4
	00ee00 Green2 00cd00 Green3 008b00 Green4
	76ee00 Chartreuse2 66cd00 Chartreuse3 458b00 Chartreuse4
	c0ff3e OliveDrab1 b3ee3a OliveDrab2 698b22 OliveDrab4
	caff70 DarkOliveGreen1 bcee68 DarkOliveGreen2
	a2cd5a DarkOliveGreen3 6e8b3d DarkOliveGreen4
	fff68f Khaki1 eee685 Khaki2 cdc673 Khaki3 8b864e Khaki4
	ffec8b LightGoldenrod1 eedc82 LightGoldenrod2
	cdbe70 LightGoldenrod3 8b814c LightGoldenrod4
	eeeed1 LightYellow2 cdcdb4 LightYellow3 8b8b7a LightYellow4
	eeee00 Yellow2 cdcd00 Yellow3 8b8b00 Yellow4
	eec900 Gold2 cdad00 Gold3 8b7500 Gold4
	ffc125 Goldenrod1 eeb422 Goldenrod2 cd9b1d Goldenrod3 8b6914 Goldenrod4
	ffb90f DarkGoldenrod1 eead0e DarkGoldenrod2
	cd950c DarkGoldenrod3 8b6508 DarkGoldenrod4
	ffc1c1 RosyBrown1 eeb4b4 RosyBrown2 cd9b9b RosyBrown3 8b6969 RosyBrown4
	ff6a6a IndianRed1 ee6363 IndianRed2 cd5555 IndianRed3 8b3a3a IndianRed4
	ff8247 Sienna1 ee7942 Sienna2 cd6839 Sienna3 8b4726 Sienna4
	ffd39b Burlywood1 eec591 Burlywood2 cdaa7d Burlywood3 8b7355 Burlywood4
	ffe7ba Wheat1 eed8ae Wheat2 cdba96 Wheat3 8b7e66 Wheat4
	ffa54f Tan1 ee9a49 Tan2 8b5a2b Tan4
	ff7f24 Chocolate1 ee7621 Chocolate2 cd661d Chocolate3
	ff3030 Firebrick1 ee2c2c Firebrick2 cd2626 Firebrick3 8b1a1a Firebrick4
	ff4040 Brown1 ee3b3b Brown2 cd3333 Brown3 8b2323 Brown4
	ff8c69 Salmon1 ee8262 Salmon2 cd7054 Salmon3 8b4c39 Salmon4
	ee9572 LightSalmon2 cd8162 LightSalmon3 8b5742 LightSalmon4
	ee9a00 Orange2 cd8500 Orange3 8b5a00 Orange4
	ff7f00 DarkOrange1 ee7600 DarkOrange2
	cd6600 DarkOrange3 8b4500 DarkOrange4
	ff7256 Coral1 ee6a50 Coral2 cd5b45 Coral3 8b3e2f Coral4
	ee5c42 Tomato2 cd4f39 Tomato3 8b3626 Tomato4
	ee4000 OrangeRed2 cd3700 OrangeRed3 8b2500 OrangeRed4
	ee0000 Red2 cd0000 Red3 8b0000 Red4
	ee1289 DeepPink2 cd1076 DeepPink3 8b0a50 DeepPink4
	ff6eb4 HotPink1 ee6aa7 HotPink2 cd6090 HotPink3 8b3a62 HotPink4
	ffb5c5 Pink1 eea9b8 Pink2 cd919e Pink3 8b636c Pink4
	ffaeb9 LightPink1 eea2ad LightPink2
	cd8c95 LightPink3 8b5f65 LightPink4
	ff82ab PaleVioletRed1 ee799f PaleVioletRed2
	cd6889 PaleVioletRed3 8b475d PaleVioletRed4
	ff34b3 Maroon1 ee30a7 Maroon2 cd2990 Maroon3 8b1c62 Maroon4
	ff3e96 VioletRed1 ee3a8c VioletRed2
	cd3278 VioletRed3 8b2252 VioletRed4
	ee00ee Magenta2 cd00cd Magenta3 8b008b Magenta4
	ff83fa Orchid1 ee7ae9 Orchid2 cd69c9 Orchid3 8b4789 Orchid4
	ffbbff Plum1 eeaeee Plum2 cd96cd Plum3 8b668b Plum4
	e066ff MediumOrchid1 d15fee MediumOrchid2
	b452cd MediumOrchid3 7a378b MediumOrchid4
	bf3eff DarkOrchid1 b23aee DarkOrchid2
	9a32cd DarkOrchid3 68228b DarkOrchid4
	9b30ff Purple1 912cee Purple2 7d26cd Purple3 551a8b Purple4
	ab82ff MediumPurple1 9f79ee MediumPurple2
	8968cd MediumPurple3 5d478b MediumPurple4
	ffe1ff Thistle1 eed2ee Thistle2 cdb5cd Thistle3 8b7b8b Thistle4
}

namespace eval icon {
namespace eval 18x18 {

set ArrowLeft [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAwklEQVQ4y6XSwQ2CQBSE4YkB
	DuyRRmxBG9keKICGjJZA9EYNwJ2TMSGBm/5eJCGisuu+Ar7MvIwUeMC+7/tLEACcAcZxJAio
	65qyLP0gYAdcJsBaSxRFFEXhBr0SLABJSFqH1oBVaA40TYO1ljiOF8BXyDXBV2j+xLZtnYF3
	aCPpJukq6WGMUZZlSpIkaKFb4AQ8uq4jz3PSNHWv9gO8T6Axxh/yBX0GuQDnlZ2hNdAbegOP
	E1hV1X/QJzAImoPDMByeNNKVb5AdHYEAAAAASUVORK5CYII=
}]

set ArrowRight [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAx0lEQVQ4y6XUwQmDQBAF0E9Q
	D+7RRtJCbGR7sAAbCkkJEm/WoN49hYDg3OLPRWGzwbjrfpjr4w8Dg3Eca5I5QiMiXPIIAkWE
	VVWxbdswUERYliWjKKLW2gRrkhdvCAABbIG5N3QY3ILWieOYWmt2Xfcf3IOcG7pCNtj3/ddR
	Tr5XTpIEWZZBKQUAM4AngJdzozRNWRQFh2EgyZnkneTZeTWllAm8f4A9yBnYgqwV9gEbOgyY
	UNM0JnDzAqw3chxYM03TNQhY8gHsrJVvOA9vaAAAAABJRU5ErkJggg==
}]

set ActiveArrowLeft [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAQAAAD8x0bcAAAAAmJLR0QA/4ePzL8AAACOSURB
	VCjPhdI9DoJAEIbhr8WEnl7pt7OGm+0BvAM90TPAnbTR4GuBYfnZ2Z1pn0y+zIxQutWWYwZo
	EEUO1DQWUqNR1HR88DGkNgDgiPbggGZwoePNuhYUm7BBc8hzFATk9NBUceNlI/SH3zjcBl8m
	Pm1kwfgydxm9eZYV9MkDO901VVxTKMAi93JI7tT/AP7LhwO7RmqrAAAAAElFTkSuQmCC
}]

set ActiveArrowRight [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAQAAAD8x0bcAAAAAmJLR0QA/4ePzL8AAACGSURB
	VCjPhdK9DkBADADgriR2O3abmTfzAN7BLjwD7+QWQl3dkUOv2qTTl/4khWiCCkFOCKiOMtSo
	xOwHalTjiq2BE5ReROHAyosk+EAUi4bpC34Q15FFF0zsMV6ksMEYYYMBchZZsBNgx81OB3Zx
	DjyQ8oAbScCiwoCeB9eriOBEYScDygNd6IcD/vJ/qAAAAABJRU5ErkJggg==
}]

} ;# namespace 18x18

namespace eval 22x22 {

set Palette [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAMAAADzapwJAAABfVBMVEUAO2MAP2cALlgAOmMA
	NF0APWUER2sJTHANS20cWnwZU3IxaYgZVXUraIYfWnkgXHsiXXwjXnwlYH4mYoAnY4EpZIIr
	ZoQsaIYtaIcvaogwbIoxbYssXXdYiaJZeYqZuclgeomuyNUAAAAAebAAerAAerEAe7AFgbYI
	g7Y8mb48mb8+Znw+Z31BmLRCncFDmbRtljltlzlulzlvmDxvr8JwmDx0obZ0pLh/o1aApFiE
	o1OEpFiFpVqGpFWGpFeHlZ+IjpWOkZaUoquVmaGVsHOWmZ+WsXOZmp+fqrKguIWjpaqmr7Sm
	uoWmu4ensripuL+uvsWxwci2pJ24ime4i2i4xs7AoovBzdPCnorCnovG0tfI1drMpI/MpY/Q
	3OHW4+jX4ePX4eTa5OXtiU7tpTvtpz7upTfuvG3voy/vpDLvu2jxhELz9PD4dCT6sk368uL6
	8uP7oSD7oSH7r0P7vWb8oSD97dX+Zwr+kAD/XgD/XwD/YAD/kAD/kQD/kgAY1T64AAAAInRS
	TlMAABQUHh50dJ+frKy+vtjY2NjY2NjY2NjY2NjY8/P6+v7+ZNre/gAAAAFiS0dEIl1lXKwA
	AADiSURBVBgZVcExTsNAEEDRmd1ZR0KQSFESwQ2g4iB0FByTjrNQIagAkYBkKQm2s7OfyvLy
	noql1ZXKhI/dKVuYbe4MmWh++iqx2Tx4TOgoCbevv3pxv7ZGakPePoZ5xACZGHFulH2rIhpl
	RACjvP+oSEBGvlxieH+IUiuDY1BCkBoFDE+NSi0mxyjbPkit5HOMfOyD1IpnDFCVmgIGqajU
	NIHBtavUiB2GrxcqNdo3At4h/9A5xjDsz6R27Aes+PdhhsoI7Tsv2lzelCK1EJ4/owzdXKj5
	y/akanG1UJnQ7jz/AVm9lOwac2MWAAAAAElFTkSuQmCC
}]

} ;# namespace 22x22
} ;# namespace icon
} ;# namespace x11

namespace eval rgb {

lappend [namespace parent]::Methods rgb

namespace import [namespace parent]::rgb2hsv
namespace import [namespace parent]::hsv2rgb
namespace import [namespace parent]::Tr
namespace import ::tcl::mathfunc::*


proc Icon {} { return $icon::22x22::RGB }


proc MakeFrame {container} {
	variable Vars

	set height 15
	set width 220
	set Vars(width) 0

	set f [tk::frame $container.f -takefocus 0]
	pack $f -anchor n -expand yes -fill x -padx 5 -pady 10

	set row 0
	foreach which {r g b h s v} {
		set Vars(value:$which) "0"
		set Vars(value:current:$which) "0"
		tk::frame $f.f$which -borderwidth 2 -relief sunken -takefocus 0
		tk::canvas $f.c$which -width 100 -height $height
		bind $f.c$which <FocusIn> "
			$f.c$which itemconfigure target -state hidden
			$f.c$which itemconfigure active -state normal
		"
		bind $f.c$which <FocusOut> "
			$f.c$which itemconfigure target -state normal
			$f.c$which itemconfigure active -state hidden
		"
		pack $f.c$which -in $f.f$which -fill both
		$f.c$which yview moveto 0
		ttk::label $f.l$which -text [string toupper $which]
		switch -exact -- $which {
			r { [namespace parent]::tooltip $f.l$which [Tr Red] }
			g { [namespace parent]::tooltip $f.l$which [Tr Green] }
			b { [namespace parent]::tooltip $f.l$which [Tr Blue] }
			h { [namespace parent]::tooltip $f.l$which [Tr Hue] }
			s { [namespace parent]::tooltip $f.l$which [Tr Saturation] }
			v { [namespace parent]::tooltip $f.l$which [Tr Value] }
		}
		::ttk::spinbox $f.s$which \
			-background white \
			-from 0 \
			-to [Maxima $which] \
			-increment 1 \
			-width 3 \
			-justify right \
			-textvariable [namespace current]::Vars(value:$which) \
			-validatecommand {
				return	[expr {%d == 0 \
						|| (	[string match \[0-9\]* "%S"] \
							&& [string length %s] <= 2)}]
			} \
			-invalidcommand { bell } \
			-exportselection no \
			;

		grid $f.l$which -row $row -column 0 -sticky nw
		grid $f.f$which -row $row -column 2 -sticky nwe
		grid $f.s$which -row $row -column 4 -sticky ne

		set Vars(widget:$which) $f.c$which
		incr row 2
	}

	foreach which {r g b h s v} {
		switch $which {
			r - g - b { set what RGB }
			h - s - v { set what HSV }
		}
		bind $f.c$which <Left>				[namespace code [list Move$what $which -1]]
		bind $f.c$which <Right>				[namespace code [list Move$what $which +1]]
		bind $f.c$which <Control-Left>	[namespace code [list Move$what $which -10]]
		bind $f.c$which <Control-Right>	[namespace code [list Move$what $which +10]]
		bind $f.c$which <Home>				[namespace code [list Move$what $which -9999]]
		bind $f.c$which <End>				[namespace code [list Move$what $which +9999]]
		bind $f.c$which <ButtonPress-1>	[namespace code [list Select${what}Value $which %x %y]]
		bind $f.c$which <ButtonPress-1>	{+ focus %W }
		bind $f.c$which <B1-Motion>		[namespace code [list Select${what}Value $which %x %y]]
		bind $f.s$which <Return>			[namespace code [list Set${what}Value $which]]
		bind $f.s$which <Return>			{+ break }
		bind $f.s$which <FocusIn>			{ %W configure -validate key }
		bind $f.s$which <FocusOut>			[namespace code [list Set${what}Value $which]]
		bind $f.s$which <FocusOut>			{+ %W selection clear }
		$f.s$which configure -command		[namespace code [list Set${what}Value $which]]
	}

	grid columnconfigure $f {1 3} -minsize 5
	grid columnconfigure $f 2 -weight 1
	grid rowconfigure $f {1 3 7 9} -minsize 12
	grid rowconfigure $f 5 -minsize 25
}


proc Maxima {which} {
	switch $which {
		h { return 360 }
		s -
		v { return 100 }
	}

	return 255
}


proc Configure {width height} {
	variable [namespace parent]::icon::11x11::ArrowUp
	variable [namespace parent]::icon::11x11::ActiveArrowUp
	variable Vars

	update idletasks

	set width [winfo width $Vars(widget:r)]
	if {$width <= 1} {
		set width [$Vars(widget:r) cget -width]
	}
	if {$Vars(width) == $width} { return }

	foreach which {r g b h s v} {
		$Vars(widget:$which) delete all
		$Vars(widget:$which) xview moveto 0
	}

	set Vars(width) $width
	set height [$Vars(widget:r) cget -height]
	set nsteps [min 255 $width]
	set scale [expr {1.0/($nsteps - 1)}]
	set step [expr {1.0/$nsteps}]

	foreach which {r g b} {
		set bar $Vars(widget:$which)

		switch -- $which {
			r { set rgb {255 0 0} }
			g { set rgb {0 255 0} }
			b { set rgb {0 0 255} }
		}

		set hsv [rgb2hsv {*}$rgb]
		lassign $hsv h s v

		set x0 0
		for {set i 0} {$i < $nsteps} {incr i} {
			set v [expr {$scale*$i}]
			#set v [sqrt $v]
			set x1 [expr {round(($i + 1)*$step*$width)}]
			set color [format "#%02x%02x%02x" {*}[hsv2rgb $h $s $v]]
			$bar create rectangle $x0 0 $x1 $height -width 0 -fill $color
			set x0 $x1
		}
	}

	set bar $Vars(widget:h)
	for {set x 0} {$x < $width} {incr x} {
		set h [expr {(360.0*$x)/($width - 1)}]
		set color [format "#%02x%02x%02x" {*}[hsv2rgb $h 1.0 1.0]]
		$bar create rectangle $x 0 $x $height -width 0 -fill $color
	}

	set hsv [rgb2hsv 238 221 130] ;# LightGoldenRod
	lassign $hsv h s v
	set bar $Vars(widget:s)
	for {set x 0} {$x < $width} {incr x} {
		set s [expr {double($x)/($width - 1)}]
		set color [format "#%02x%02x%02x" {*}[hsv2rgb $h $s $v]]
		$bar create rectangle $x 0 $x $height -width 0 -fill $color
	}

	set bar $Vars(widget:v)
	for {set x 0} {$x < $width} {incr x} {
		set v [expr {double($x)/($width - 1)}]
		set color [format "#%02x%02x%02x" {*}[hsv2rgb 0 0 $v]]
		$bar create rectangle $x 0 [expr {$x + 1}] $height -width 0 -fill $color
	}

	foreach which {r g b h s v} {
		$Vars(widget:$which) create image 0 3 -image $ArrowUp -anchor n -tags target
		$Vars(widget:$which) create image 0 3 -image $ActiveArrowUp -anchor n -tags active
		$Vars(widget:$which) itemconfigure active -state hidden
	}
}


proc Update {r g b afterResize} {
	UpdateRGB $r $g $b
	UpdateHSV [rgb2hsv $r $g $b]
}


proc SetSpinboxValue {which val} {
	variable Vars

	if {$val != $Vars(value:$which)} {
		set Vars(value:$which) $val
		set Vars(value:current:$which) $val
	}
}


proc UpdateRGB {r g b} {
	foreach which {r g b} {
		SetSpinboxValue $which [set $which]
		Reflect $which [set $which]
	}
}


proc UpdateHSV {hsv} {
	variable Vars

	set Vars(hsv) $hsv
	lassign $hsv h s v

	set h [expr {round($h)}]
	set s [expr {round($s*100)}]
	set v [expr {round($v*100)}]

	foreach which {h s v} {
		SetSpinboxValue $which [set $which]
		Reflect $which [set $which]
	}
}


proc Reflect {which val} {
	variable Vars

	set x [expr {round((double($val)/double([Maxima $which]))*double($Vars(width) - 1))}]
	$Vars(widget:$which) coords target $x 3
	$Vars(widget:$which) coords active $x 3
}


proc SetRGBValue {which {val {}}} {
	variable [namespace parent]::Priv
	variable Vars

	if {[llength $val] == 0} {
		set val [string trimleft $Vars(value:$which) "0"]
	}
	if {$val eq "" || $val < 0} { set val 0 }
	if {$val > 255} { set val 255 }
	if {$val == $Vars(value:current:$which)} { return }
	set Vars(value:current:which) $val
	SetSpinboxValue $which $val
	scan $Priv(rgb) "\#%2x%2x%2x" r g b

	switch $which {
		r { set r $val }
		g { set g $val }
		b { set b $val }
	}

	Reflect $which $val
	[namespace parent]::SetRGB [list $r $g $b]
	UpdateHSV [rgb2hsv $r $g $b]
}


proc SetHSVValue {which {val {}}} {
	variable Vars

	if {[llength $val] == 0} {
		set val [string trimleft $Vars(value:$which) "0"]
	}
	if {$val eq "" || $val < 0} { set val 0 }

	switch $which {
		h { if {$val > 360} { set val 360 } }
		s -
		v { if {$val > 100} { set val 100 } }
	}

	if {$val == $Vars(value:current:$which)} { return }
	set Vars(value:current:$which) $val
	SetSpinboxValue $which $val

	switch $which {
		h { set Vars(hsv) [lreplace $Vars(hsv) 0 0 $val] }
		s { set Vars(hsv) [lreplace $Vars(hsv) 1 1 [expr {$val/100.0}]] }
		v { set Vars(hsv) [lreplace $Vars(hsv) 2 2 [expr {$val/100.0}]] }
	}

	set rgb [hsv2rgb {*}$Vars(hsv)]
	Reflect $which $val
	[namespace parent]::SetRGB $rgb
	UpdateRGB {*}$rgb
}


proc SelectRGBValue {which x y} {
	variable [namespace parent]::Priv
	variable Vars

	incr x -2

	set x [min $x [expr {$Vars(width) - 1}]]
	set x [max 0 $x]
	set d [expr {double($x*$Vars(width)*[Maxima $which])/double($Vars(width)*($Vars(width) - 1))}]

	$Vars(widget:$which) coords target $x 3
	$Vars(widget:$which) coords active $x 3
	scan $Priv(rgb) "\#%2x%2x%2x" r g b

	switch $which {
		r { set r [expr {round($d)}] }
		g { set g [expr {round($d)}] }
		b { set b [expr {round($d)}] }
	}

	[namespace parent]::SetRGB [list $r $g $b]
	SetSpinboxValue $which [set $which]
	UpdateHSV [rgb2hsv $r $g $b]
}


proc SelectHSVValue {which x y} {
	variable Vars

	set x [min $x [expr {$Vars(width) - 1}]]
	set x [max 0 $x]
	set d [expr {(double($x)/double($Vars(width) - 1))}]

	if {$which eq "h"} { set d [expr {$d*360}] }

	$Vars(widget:$which) coords target $x 3
	$Vars(widget:$which) coords active $x 3

	switch $which {
		h { set Vars(hsv) [lreplace $Vars(hsv) 0 0 $d] }
		s { set Vars(hsv) [lreplace $Vars(hsv) 1 1 $d] }
		v { set Vars(hsv) [lreplace $Vars(hsv) 2 2 $d] }
	}

	set rgb [hsv2rgb {*}$Vars(hsv)]
	[namespace parent]::SetRGB $rgb
	UpdateRGB {*}$rgb

	if {$which ne "h"} { set d [expr {$d*100}] }
	SetSpinboxValue $which [expr {round($d)}]
}


proc MoveRGB {which step} {
	variable Vars

	SetRGBValue $which [expr {$Vars(value:$which) + $step}]
}


proc MoveHSV {which step} {
	variable Vars

	SetHSVValue $which [expr {$Vars(value:$which) + $step}]
}

namespace eval icon {
namespace eval 22x22 {

set RGB [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAACaElEQVQ4y62UT2gTURDGv5l5
	b7PZhDSppKUB0bSCJYKIIIUqeBAUQdBDD4oUD3rSq3eRqnj3Ior24EE9Cj0IIsVDBb1VWyx4
	kVr634JESjbZfc/DrmmsTdQ2A8O8eTv89jHvm0dDudTR4azzxBVTJLEgZUFi8Mc6ztHRGSxw
	5vno9PfLL2dWfDQxdcrTdwY8XWQxIGVAOoKxNhFYUQTVv/bWVNDbd3FsavYZgLFmYHZg8/hP
	cyiEBSVb1TC2aUyglt+tbV3Q7DyhMaZlxSdD91YDY/8NSICXw5uv5XlHqbctK4sdHURhdX+5
	4ndGO7bOoAZePbLg2kDh443x2XJLsAAkCb2r6teS2+13wlWBXwkWfpNbz7GuC12HMw8yeZVK
	JgDXBdwE4ChAawMtFlpbaDEQip0NhMI4Ag51h1+mKg9Pntlz9WzplQUA2je0e6JwJDvouUCy
	wR1tI1cWWlloZaBimOIQTBu5UAj/20EzcmmisLZSWQIA5gTnsGOzYCGuViAburFW0CZTmhsH
	hNZ3jiSY0BrRNqz/pLpUu7W+WHksnSpDVYB8wFaAQFvUVORaWaj48lTcU65fooVDhXB2em70
	0fjg8rnS67rc3O7+vDc/s5La7nmTKRWOfbiycKLvfn3QKOFltO7qLdXKq9lop2HC/7reNEUE
	IKjWeg8ceqdQOn39R9/x2/ByBGGABRABmOMomyJvnYuARJBPO1h8/+Ip++meYbgZaocqrLVY
	XQ+Q2dt/vq1yixQdNYVhTVvBDe+1nW8nUDMjCMOywtzkTXbTI0acHJjR1Kkxly1riBnZtOMv
	f568+xMPp9Zz9rIrQgAAAABJRU5ErkJggg==
}]

} ;# namespace 22x22
} ;# namespace icon
} ;# namespace rgb

namespace eval icon {
namespace eval 11x11 {

set ArrowUp [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAAdElEQVQY043QMQrDMBSDYXk0
	+DwdXTr6QrmCL9SMBo++kHlb/0yFUp6TCLSJb5DkBNh0J8AL+ACPO+NeawXYL9XWGpIYY5zr
	QM85I4lSCsD7UpVECGGt/6rfuvq/eqp7qquvVE8PZtbN7DnnXL6UUlKMcT8AIjqQZ7OBVAYA
	AAAASUVORK5CYII=
}]

set ActiveArrowUp [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAAf0lEQVQY043QsRHDIBBE0b0I
	AppxAPF1oGpoQ9WQ4wbkdiC6dSSNPAZJP955wQL/CYAVD1sAEIDeDUVEtpwzAdRbVVVpZowx
	XuoCYKu1kiRLKZf6oZKkmTGlNNRFRA51b6b/qHsjfajO9EVVOeusSwjh45x7ee+nf/be0Vp7
	fwEX3Jjf4QNfoAAAAABJRU5ErkJggg==
}]

set ArrowRight [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAAcklEQVQY043OMQ6DMBBE0fWl
	UlpK6QvlCr4QlJYofQ/3dmlXfJosQpCwjDTdm9VK730B3vIktVZSSgD2qJSCiOC9t0eKtbej
	M74d/cPaGCPACnx+YuccIQRyziswA6/L5ROadnT82USa1pqNNGMMG32zAR8mrjjWt+mAAAAA
	AElFTkSuQmCC
}]

set ActiveArrowRight [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAQAAAADpb+tAAAAUUlEQVQI12XMMRJAQBBE0Z8R
	ku85VsyhlIMh5mLTAmxtbXf4/tTQX8z4Ri3CU5J0e0p616Sfm1SzJG0iWCsOnZqCg1yuP9rJ
	5bcRwOAE0DkBDyxWXHFgN2EuAAAAAElFTkSuQmCC
}]

} ;# namespace 11x11

#namespace eval 12x12 {
#
#set GreenArrow12 [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAA/0lEQVQoz63RPUvDUBjF8X/S
#	RBKU2rQKvsUGBOki4iAIDu6ugl/AbyAI0lGUKLi4FL+Crq6Cg4trdVCDkwgi2IoENbm5t9ep
#	HaxYEc/0DOc3HB74c2oss4PZq9Yp+IWhY7tkXnDI4q/AzLjP7EQwP+oOnDsHuSP2CX4EQqQs
#	TFfod22jUh5eDYqD11ZohuyS/xbITOGX8ox4Hk6fRXms4CzNTW5OFb3IqBpr7Z7VPlqyhZKC
#	+F3SaMQkQpImkjRWttba7QIqU0SPTep396CBNzISajhsEdLsAqY2OLu8AQF8cAJsEHL7dXQH
#	RA/PPL28XqFYZ5vT3o+rssIeOf47nxVoTimZ8GPfAAAAAElFTkSuQmCC
#}]
#
#} ;# namespace 12x12

namespace eval 20x15 {

set Empty [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABQAAAAPCAQAAABOkSfeAAAAAmJLR0QA/4ePzL8AAAAJcEhZ
	cwAACxMAAAsTAQCanBgAAAAHdElNRQfcBw0HKxHw7bknAAAAHXRFWHRDb21tZW50AENyZWF0
	ZWQgd2l0aCBUaGUgR0lNUO9kJW4AAACySURBVCjPhdIxDgFBGIbhP5GsCgkXIFE5AwewncIB
	uIB1C5yAW+gl7kC2kFALCgoJieBVjGWYf7Jf/WbyZGaEZFsiCgjiGd9dmNIgQ2oIcGBERT2X
	/z1Y0iXvxJxxd1UQtJhxU+I9Q8rWuQhFeqx5KogFHXKfGEGoMebkQdQtBEJAk7mK2DGgKlYq
	lIhUxJ3V7w0YxERDuPcqBIQuQnsrg+izsRG+H5AgjinhO87SJjbhCzrFVmHf9TjpAAAAAElF
	TkSuQmCC
}]

}
namespace eval 15x15 {

set GreenArrow [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABUElEQVQoz7WRTSsEcQDGf7Mz
	dmZ32GGiLbUSorYQRSmyV6V8Bl/BUXKSwtVLW3JSysEX4OIgUZI9OLBs5Lx52d15n7/TUhZt
	yXN6Ds+vp54H/qwtUqxj1BuPfBghzemquittS2NkidYNGoqeyKT7p5sl9VDxIpts0FcXKAWC
	ka4e2owmvbPNmE026CfRNXmBFTq+A+Wq0aaiM5ODPUO2KyiWniUzEY+bjdokvpTxJ0I/GBcF
	jrFrGgkElmORTrXTmkgQUxswm+PyYG9yeKA7mW2Jx/ZZYLQaV6pGhOB7HgEyb2Wf17cKluPh
	uj5OJZCckq8hUGtBTyBCOM8/kis8QQh4hNhc45NFZg+NYg1IKKg4govbOwgRWLzgskXIDsvk
	v47z2RjA2c095WfbxuEAhVWWuPrpjg+wZDuVy9zDkXDFMhFOWfxc8HfN08k8Jv+td1C9fWIG
	NKEPAAAAAElFTkSuQmCC
}]

} ;# namespace 15x15
} ;# namespace icon
} ;# namespace choosecolor
} ;# namespace dialog

# vi:set ts=3 sw=3:
