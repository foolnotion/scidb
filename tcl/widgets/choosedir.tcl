# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2011-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.4
if {[catch { package require tkpng }]} { package require Img }
package require tooltip
package provide choosedir 1.0


proc choosedir {w args} {
	return [::choosedir::Build $w {*}$args]
}


namespace eval choosedir {
namespace eval mc {

set ShowPredecessor	"Show Predecessor"
set ShowTail			"Show Tail"
set Folder				"Folder"

}

namespace import ::tcl::mathfunc::max

proc tooltip {args} {}
proc mc {tok} { return [tk::msgcat::mc [set $tok]] }

if {![catch {package require tooltip}]} {
	proc tooltip {args} { ::tooltip::tooltip {*}$args }
}

proc Tr {tok} { return [mc [namespace current]::mc::$tok] }


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	array set opts {
		-width				300
		-borderwidth		1
		-padx					2
		-pady					5
		-relief				raised
		-font					TkTextFont
		-activebackground	{}
		-initialdir			{}
		-showlabel			0
		-showhidden			0
	}
	array set opts $args

	if {[llength $opts(-activebackground)] == 0} {
		set opts(-activebackground) [::colors::lookup theme,activebackground]
		if {[llength $opts(-activebackground)] == 0} {
			tk::button $w
			set opts(-activebackground) [$w cget -activebackground]
			destroy $w
		}
	}

	set Vars(dir) ""
	set Vars(dir:components) { "" }
	set Vars(dir:size) 0
	set Vars(prefix:components) { "" }
	set Vars(prefix:size) 0
	set Vars(size) 0
	set Vars(start) 1
	set Vars(font) $opts(-font)
	set Vars(padx) $opts(-padx)
	set Vars(pady) $opts(-pady)
	set Vars(initialdir) $opts(-initialdir)
	set Vars(user) 0
	set Vars(icon) {}
	set Vars(startmenu) {}
	set Vars(showhidden) $opts(-showhidden)
	set Vars(prefix) ""
	set Vars(basename) ""
	set Vars(tooltip) ""

	set Vars(linespace) [font metrics $opts(-font) -linespace]
	set Vars(activebackground) $opts(-activebackground)
	set Vars(showlabel) $opts(-showlabel)

	array unset opts -font
	array unset opts -pad*
	array unset opts -activebackground
	array unset opts -initialdir
	array unset opts -showlabel
	array unset opts -showhidden

	set opts(-height) [expr {$Vars(linespace) + 2*$Vars(pady)}]
	set bg [::colors::lookup theme,background]

	tk::frame $w -background $bg -takefocus 0 {*}[array get opts]

	if {$Vars(showlabel)} {
		tk::button $w.label      \
			-text "[Tr Folder]:"  \
			-pady 2               \
			-padx 2               \
			-relief flat          \
			-overrelief flat      \
			-background $bg       \
			-activebackground $bg \
			;
		bind $w.label <ButtonPress-1> { break }
	}

	tk::button $w.prev                           \
		-image $icon::14x14::prevComponent        \
		-relief flat                              \
		-overrelief raised                        \
		-background $bg                           \
		-activebackground $Vars(activebackground) \
		-takefocus 0                              \
		;
	bind $w.prev <Enter> [namespace code [list ShowTooltip $w]]
	bind $w.prev <Leave> { ::tooltip::hide yes }
	tk::button $w.next                           \
		-image $icon::14x14::nextComponent        \
		-relief flat                              \
		-overrelief raised                        \
		-background $bg                           \
		-activebackground $Vars(activebackground) \
		-takefocus 0                              \
		;
	bind $w.prev <Leave> {+ %W configure -relief flat }
	tooltip $w.next [Tr ShowTail]
	if {$Vars(showlabel)} {
		grid $w.label -column 1 -row 1 -sticky ns
	}
	grid $w.prev -column 3 -row 1 -sticky ns
	grid $w.next -column 1000 -row 1 -sticky ns
	grid rowconfigure $w {0 2} -minsize $Vars(pady)
	grid columnconfigure $w {2 1001} -minsize $Vars(padx)

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w <Configure> [namespace code { Configure %W %w }]
	catch { rename ::$w $w.__choosedir__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	if {[string length $Vars(initialdir)] == 0} { set Vars(initialdir) [pwd] }
	$w set $Vars(initialdir) "" "" ""

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		set {
			if {[llength $args] != 4} {
				error "wrong # args: should be \"[namespace current] $command <dir> <basename> <icon> <prefix>\""
			}
			variable ${w}::Vars

			lassign $args folder basename icon prefix
			if {$folder ne $Vars(dir) || $prefix ne $Vars(prefix)} {
				set separator [file separator $folder]
				set Vars(dir) $folder
				set Vars(basename) $basename
				set Vars(prefix) $prefix
				set Vars(prefix:components) [file split $prefix]
				set Vars(dir:components) [file split $folder]
				foreach attr {dir prefix} {
					if {[llength $Vars($attr:components)] <= 1} {
						set Vars($attr:components) {}
					} else {
						set Vars($attr:components) [lreplace $Vars($attr:components) 0 0]
					}
					set Vars($attr:size) [llength $Vars($attr:components)]
				}
				set Vars(start) [expr {$Vars(dir:size) - $Vars(prefix:size) + 1}]
				set Vars(user) 0
				set Vars(icon) $icon
				Layout $w
			}

			return $w
		}

		setfolder {
			if {[llength $args] != 2 && [llength $args] != 3} {
				error "wrong # args: should be \"[namespace current] $command <folder> <basename> ?<icon>?\""
			}
			variable ${w}::Vars

			set icon {}
			lassign $args folder basename icon
			if {$folder ne $Vars(dir)} {
				set Vars(dir) $folder
				set Vars(dir:components) { "" }
				set Vars(dir:size) 0
				set Vars(prefix) ""
				set Vars(prefix:components) { "" }
				set Vars(prefix:size) 0
				set Vars(basename) $basename
				set Vars(start) 1
				set Vars(user) 1
				set Vars(icon) $icon
				Layout $w
			}

			return $w
		}

		setstartmenu {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <start-menu>\""
			}
			variable ${w}::Vars
			set Vars(startmenu) [lindex $args 0]
			return $w
		}

		showhidden {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <flag>\""
			}
			variable ${w}::Vars
			set Vars(showhidden) [lindex $args 0]
			return $w
		}

		tooltip {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <string>\""
			}
			variable ${w}::Vars
			set Vars(tooltip) [lindex $args 0]
			return
		}

		dir {
			variable ${w}::Vars
			return $Vars(dir)
		}

		configure {
			if {[llength $args] % 2 == 1} {
				error "value for \"[lindex $args end]\" missing"
			}
			array set opts $args
			foreach option {padx pady} {
				if {[info exists opts(-$option)]} {
					set Vars($option) $opts(-$option)
					array unset opts -$option
				}
			}
			if {[info exists opts(-font)]} {
				set value $opts(-font)
				for {set i 0} {$i < $Vars(size)} {incr i} {
					$w.text-$i configure -font $value
				}
			}
			if {[info exists opts(-activebackground)]} {
				set value $opts(-activebackground)
				for {set i 0} {$i < $Vars(size)} {incr i} {
					$w.text-$i configure -activebackground $value
					$w.image-$i configure -activebackground $value
				}
			}
			set args [array get opts]
			if {[llength $args]} {
				$w.__choosedir__ {*}$args
			}
			Layout $w
			return $w
		}
	}

	return [$w.__choosedir__ {*}$args]
}


proc ShowTooltip {w} {
	variable ${w}::Vars

	if {[string length $Vars(tooltip)]} {
		::tooltip::show $w $Vars(tooltip)
	}
}


proc Layout {w} {
	variable ${w}::Vars

	set bg [::colors::lookup theme,background]
	set n [expr {$Vars(dir:size) - $Vars(prefix:size) + 1}]

	for {set i $Vars(size)} {$i < $n} {incr i} {
		tk::button $w.text-$i                                       \
			-font $Vars(font)                                        \
			-padx 2                                                  \
			-pady 2                                                  \
			-relief flat                                             \
			-overrelief raised                                       \
			-background $bg                                          \
			-activebackground $Vars(activebackground)                \
			-command [namespace code [list Invoke $w $w.text-$i $i]] \
			-takefocus 0                                             \
			;
		tk::button $w.image-$i                                          \
			-image $icon::9x14::Delimiter                                \
			-relief flat                                                 \
			-pady 2                                                      \
			-overrelief raised                                           \
			-background $bg                                              \
			-activebackground $Vars(activebackground)                    \
			-command [namespace code [list PopupDirs $w $w.image-$i $i]] \
			-takefocus 0                                                 \
			;
		# we have to help Tk a little bit
		bind $w.text-$i <Leave> { %W configure -relief flat }
		bind $w.image-$i <Leave> { %W configure -relief flat }
		set col [expr {4*($i + 2)}]
		grid $w.text-$i -column [incr col] -row 1
		grid $w.image-$i -column [incr col] -row 1 -sticky ns
	}

	$w.text-0 configure -text $Vars(basename)

	for {set i $Vars(prefix:size)} {$i < $Vars(dir:size)} {incr i} {
		set k [expr {$i - $Vars(prefix:size) + 1}]
		$w.text-$k configure -text [lindex $Vars(dir:components) $i]
	}

	set Vars(size) [max $n $Vars(size)]
	set removeLast 0

	if {[llength [glob -nocomplain -tails -dir $Vars(dir) -types d *]] == 0} {
		set removeLast 1
	}

	update idletasks

	if {[winfo exists $w.image-0]} {
		set iwd [winfo width $w.image-0]
	} else {
		set iwd 0
	}
	set bwd [$w.__choosedir__ cget -borderwidth]
	set twd [expr {[winfo width $w] - 2*$bwd - [winfo width $w.prev] - 3*$Vars(padx)}]
	if {!$removeLast} { set twd [expr {$twd - $iwd}] }
	if {$Vars(showlabel)} { set twd [expr {$twd - [winfo width $w.label] - $Vars(padx)}] }

	set i 0
	set x 0
	set width(0) 0

	while {$i < $n} {
		set wd [winfo width $w.text-$i]
		set x [expr {$x + $wd + $iwd}]
		set width([incr i]) $x
	}

	set e $n
	set f $e
	while {$f > 0 && $width($e) - $width([expr {$f - 1}]) <= $twd} { incr f -1 }

	while {$f > $Vars(start)} {
		incr f -1
		while {$e > $f && $width($e) - $width($f) > $twd} { incr e -1 }
	}

	if {$e < $n} {
		set twd [expr {$twd - [winfo width $w.next]}]
		if {$e > 0 && $width($e) - $width($f) > $twd} { incr e -1 }
	}

	if {$f > 0} {
		if {$width($e) - $width($f) > $twd} { incr f 1 }
		bind $w.next <ButtonRelease-1> [namespace code [list SetRange $w $w.next $n]]
	}
	if {$f == 0} {
		set icon $Vars(icon)
		if {[llength $icon] == 0} { set icon $icon::16x16::fileSystem }
		$w.prev configure -command [namespace code [list Invoke $w $w.prev -1]]
		tooltip $w.prev ""
	} else {
		set icon $icon::14x14::prevComponent
		$w.prev configure -command [namespace code [list SetRange $w $w.prev [expr {$f - 1}]]]
		tooltip $w.prev [Tr ShowPredecessor]
	}
	$w.prev configure -image $icon
	if {$f >= $e} { set f [expr {$e - 1}] }

	for {set i 0} {$i < $Vars(size)} {incr i} {
		if {$i >= $f && $i < $e} {
			grid $w.text-$i
			grid $w.image-$i
		} else {
			grid remove $w.text-$i
			grid remove $w.image-$i
		}
	}

	if {$Vars(user)} {
		if {[llength $Vars(icon)] == 0} {
			grid remove $w.prev
		}
		grid remove $w.image-0
	} else {
		grid $w.prev
		if {$removeLast} { grid remove $w.image-[expr {$n - 1}] }
		if {$e < $n} { grid $w.next } else { grid remove $w.next }
	}
}


proc ButtonEnter {w} {
	# poor Tk: we have to help Tk a bit
	set ptrw [winfo containing {*}[winfo pointerxy .]]
	if {$ptrw eq $w} {
		$w configure -relief [$w cget -overrelief]
		::tk::ButtonEnter $w
	}
}


proc Invoke {w btn i} {
	variable ${w}::Vars

	if {$i == -1} {
		event generate $w <<GetStartMenu>>
		set m $w.popup
		if {[winfo exists $m]} { destroy $m }
		menu $m -tearoff false
		foreach {icon name folder} $Vars(startmenu) {
			if {[string length $name] == 0} {
				$m add separator
			} else {
				$m add command \
					-label " $name" \
					-image $icon \
					-compound left \
					-command [namespace code [list ChangeFolder $w $folder]] \
					;
			}
		}
		bind $m <<MenuUnpost>> [list $btn configure -state normal -relief flat]
		bind $m <<MenuUnpost>> +[namespace code [list ButtonEnter $btn]]
		tk_popup $m [winfo rootx $btn] [expr {[winfo rooty $btn] + [winfo height $btn]}]
	} elseif {$Vars(user)} {
		event generate $w <<SetFolder>> -data $Vars(dir)
	} elseif {$i == 0} {
		event generate $w <<SetDirectory>> -data [file join "/" {*}$Vars(prefix:components)]
	} else {
		set components [lrange $Vars(dir:components) 0 [expr {$i + $Vars(prefix:size) - 1}]]
		event generate $w <<SetDirectory>> -data [file join "/" {*}$components]
	}

	after idle [namespace code [list ButtonEnter $btn]]
}


proc PopupDirs {w btn i} {
	variable ${w}::Vars

	if {$Vars(user)} {
		set subdirs {}
	} else {
		set i [expr {$i + $Vars(prefix:size) - 1}]
		set rootdir [file join "/" {*}[lrange $Vars(dir:components) 0 $i]]
		set filter *
		if {$::tcl_platform(platform) eq "unix" && $Vars(showhidden)} { lappend filter .* }
		set subdirs [glob -nocomplain -tails -dir $rootdir -types d {*}$filter]
		foreach dir {. ..} {
			set i [lsearch -exact $subdirs $dir]
			if {$i >= 0} { set subdirs [lreplace $subdirs $i $i] }
		}
		set subdirs [lsort -dictionary -unique $subdirs]
	}

	set m $w.popup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false

	if {[llength $subdirs]} {
		set linespace [font metrics [$m cget -font] -linespace]
		set maxh [winfo screenheight $m]
		set columns [expr {(2*[llength $subdirs]*$linespace + $maxh - 1)/$maxh}]
		if {$columns > 4} { set columns [expr {([llength $subdirs]*$linespace + $maxh - 1)/$maxh}] }
		set size [expr {[llength $subdirs]/$columns}]
		set n 0
		foreach dir $subdirs {
			set opts {}
			if {$n == $size} {
				lappend opts -columnbreak 1
				set n 0
			}
			if {$Vars(user)} {
				set rootdir [file dirname $dir]
				set dir [lindex [file split $dir] end]
			}
			$m add command {*}$opts -label $dir -command [namespace code [list ChangeDir $w $rootdir $dir]]
			incr n
		}
	}

	bind $m <<MenuUnpost>> [namespace code [list ButtonEnter $btn]]
	tk_popup $m [winfo rootx $btn] [expr {[winfo rooty $btn] + [winfo height $btn]}]
}


proc ChangeFolder {w folder} {
	event generate $w <<SetFolder>> -data $folder
}


proc ChangeDir {w rootdir subdir} {
	event generate $w <<SetDirectory>> -data [file join $rootdir $subdir]
}


proc SetRange {w btn index} {
	variable ${w}::Vars

	set Vars(start) $index
	Layout $w
	after idle [namespace code [list ButtonEnter $btn]]
}


proc Configure {w width} {
	variable ${w}::Vars

	if {$width <= 1} { return }
	set Vars(start) [expr {[llength $Vars(dir:components)] - $Vars(prefix:size)}]
	Layout $w
}


namespace eval icon {
namespace eval 16x16 {

set fileSystem [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAACDVBMVEVjYGAEBARraGhtampm
	ZGRhYGBfXl5eXl5fXl4NDQ1fX19fX19eXl5eXl4oKChRUVFwbW0XGheJh4eRj4+CgIAiIiKU
	kpKXlZWbmpqfn5+ioqIZHBqop6eCgYEuMy+rq6uurq6vr69SVFKLi4uoqag3Nzg7Ozs+PUA+
	PkGYmJigoKCnp6eqqqqrq6usrKytra05OTo5PDmRkZEyOzQzQzempKSurKyxsbG2tbW6urrA
	wMAcHB3FxcXLy8vPz8/S0tLT0tJeXl61tbUgKSInSC8oKB4sLy0wMDExMTExMjE0dkNLSSVn
	ZClpcGtra19xbS1ybi5zhXZzlnp4eHh5eXl7emV8fHl9gH1/f3+AgICBgGuBgYGCgoKEg3CF
	hoWJiYmKioqMjIyNjY2Ojo6Tk5OZmZmampqcnJydnZ2fn5+kpKSlpaWoqKiurq6wr6+wsLCy
	srKzsrK0tLS1tbW3tra3t7e4uLi5ubm5vbq6urq8vLy9vb2/v7/BwcHBwcLCwsLDw8PExMTE
	xsTFxcXFyMbGxcXGxsbHxsbIyMjJycnKysrLy8zNzc3Nzs3Ozc3Ozs7OztDPz8/Q0NDR0dHS
	0tLT09PU1NTV1dXW1tbY2NjZ2dna2trb29vc3Nzd3d3e3t7f39/g4ODh4eHj4+Pj5OPk5OTl
	5eXm5ubn5+fo6Ojp6enq6urr6+vs7Oz///8yXVsIAAAAQ3RSTlMSHR8hKTE4P0VISk5RVFVV
	WmKPkZeYmaGor7W3ury+vsHExcXFxsbGxsbGxsbGxsbHx8fIyeHi5Obo6uvs7u/w8PHxjP3u
	2AAAAAFiS0dErrlrk6cAAADNSURBVBgZBcFdTsJQEIDR+WampT9iQyBNDDHRV7fgct2Vvvis
	NgYR5LbcO56D7IZaXSJUcmk+j66Pz5uNhCCSl+ny4lCOr7fEd6en9VDh0Cuhy5U80xRzkP5p
	KeyF4klR0Dx+5XPq0mpDh8O5bsdhmu4fbDo1ODr06Y5mW19THmtcaW/UxBuZi7WmDqaVi4hE
	SbObwiGrAmrYT8FhbA0IwfNWcdX3fl0ZhKS/38484m1VWWqJSDNL8WXOy5zTASGXOiXY7S8S
	BRHplY/jP3c7WDhrbzSyAAAAAElFTkSuQmCC
}]

} ;# namespace 16x16

namespace eval 14x14 {

set prevComponent [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAQAAAC1QeVaAAAAT0lEQVQY02NgIBEYMEjikrJk
	2Mdggl3KhuEywwcGY2xSDgxXGP4zvMMm6cxwneE/NkkmBg+GWwz/sUuKMeyGSpGqE6+dBF1L
	wJ8EQgglbAEKliaZAtPhwwAAAABJRU5ErkJggg==
}]

set nextComponent [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAQAAAC1QeVaAAAAAmJLR0QA/4ePzL8AAABQSURB
	VBjTY2AgAkgyGOCWNGHYx2CJS9KY4QPDZQYbXJLvGP4zXGFwwC35n+E6gzNuyf8Mtxg8GJhw
	Sf5n2M0gRoZOPHbidC0ef+INIaxhCwCrHiaZy5kakAAAAABJRU5ErkJggg==
}]

set fileSystem [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAABnlBMVEVvbW0MDAx+fHyBf39+
	fHx8e3t9fX1/fn6BgIAVFRaBgYGAgIB6enpOTk54dnYcHxyUkpKcmpqfnp6Mi4spKSiko6Op
	qamsrKyysbEfIR+2traOjo65ubkvODG4uLh+gH85OTc6Ojo7PDtGRUGXl5efn5+rq6uwsLC3
	t7e4uLi5ubkzOTRCQT4zSTmtrKyzsrK3tra7u7u/v7/GxcUmJiPMzMzQ0NCFhYXKysrR0dEq
	PS4tOC83Nzg5OTk5Ojk6e0g7OSRfXClvbC1wbS53d3d4eHiLi4uMjIiOjo6QmJKUppeVlZWZ
	mJOcoZ2dnZ2goKChoJuhoaGkpKKkpKSlpaWnp6eoqairq6utra2vr6+xsbGzs7O1tbW2tra4
	uLi5ubm6ubm8vLy9vb2+vr6/v7/AwMDBwcHCwsLDw8PFxcXGxsbHx8fIyMjJycnKysrLy8vN
	zc3Ozs7Pz8/Q0NDR0tHS0tLT1NPU1NTW1tbX19fZ2dnb29vc3Nzd3d3d3t3g4ODh4eHi4uLk
	5OTm5ubn5+fo6Ojp6enq6urr6+v///9jZt2HAAAAOnRSTlMjLzY6Q0tTWV9hY2Zpam95oKSs
	srOzusDExsjKy8zNzs/Pz8/Pz8/Pz8/P0NDR7/Dy8/T19vb3+Pj4+XarFgAAAAFiS0dEiRxh
	JswAAACdSURBVAgdBcFBTsNAEEXBft9tO4OIIisLEJwh189ROAFrhCDC9nh6mirsukjqpuz9
	79f1fntuWEBnuzv4Z1zqY+j9bcLBl828jE2nwMFe9kNM2/mhQVBn0/Z1Ws4tcHjKi451nveS
	OCoazUvuURou8NHM6GqSM1QNaQaZISenmoaZRUpOfoyuiexrJN6ituwNI/yocH1dLTCj6Pvn
	H8+nR5bTmXW8AAAAAElFTkSuQmCC
}]

} ;# namespace 14x14

namespace eval 9x14 {

set Delimiter [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAkAAAAOCAMAAADKSsaaAAAAZlBMVEUAAAAAUdMAVcwAVM0A
	VckAV8sAVcgAV8kAVMgAWNEAVbsAVtIAWMUAWM8AVcQAV8sAMrEAWMwAObcAQboAV8gARsAA
	V8oAVsUAUcMAWMcATsEAScAAUL8AUswAV8UAT8MAR74APrp/s5o1AAAAInRSTlMARUtSWl5m
	bXN6e4KDhoqKj5GUnJ6hrLS8vMDDzM7c5OboX/pA0QAAAE5JREFUCB0FwQcCgkAMALAoMk5q
	UcB5zv9/0gQAygZgHLeAQ1N2wKlppwGsbd+tCZcuYrg+ce8z97czXiXjscA7oi7gk3UGvnUG
	/I4AAH/GOgNDmSduDgAAAABJRU5ErkJggg==
}]

} ;# namespace 9x14
} ;# namespace icon
} ;# namespace choosedir

# vi:set ts=3 sw=3:
