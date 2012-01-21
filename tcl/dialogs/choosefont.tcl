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

# ======================================================================
# Based on ChooseFont -- yet another font chooser dialog
# by Keith Vetter, June 2006
# ======================================================================

package require Tk 8.5
package require progressbar
package provide choosefont 1.1

namespace eval dialog {

proc chooseFont {font args} { return [choosefont::choosefont $font {*}$args] }

namespace export chooseFont

namespace eval choosefont {
namespace eval mc {
### Client Relevant Data ########################################
set Apply				"&Apply"
set Cancel				"&Cancel"
set FixedOnly			"&Monospaced fonts only"
set Family				"&Family"
set Ok					"&OK"
set Reset				"&Reset"
set Size					"&Size"
set Strikeout			"Stri&keout"
set Style				"S&tyle"
set Underline			"&Underline"
set Color				"Co&lor"

set Regular				"Regular"
set Bold					"Bold"
set Italic				"Italic"
set {Bold Italic}		"Bold Italic"

set Effects				"Effects"
set Filter				"Filter"
set Sample				"Sample"
set SearchTitle		"Searching for monospaced fonts"
set SeveralMinutes	"This operation may take about %d minute(s)."
set FontSelection		"Font Selection"
set Wait					"Wait"
#################################################################
} ;# namespace mc

### Client Relevant Data ########################################
variable iconOk {}
variable iconCancel {}
variable iconApply {}
variable iconReset {}
#################################################################

array set fontFamilies {
	{Avant Garde} {
		{Avant Garde Medium BT}
		{AvantGarde Bk BT}
		{Avant Garde Medium Oblique BT}
		{AvantGarde}
		{Avant Garde Gothic}
		{Century Gothic}
		{URW Gothic L}
		{Futura}
	}

	Bookman {
		{Bookman}
		{Bookman L}
		{Bookman Old Style}
		{URW Bookman L}
		{ITC Bookman}
	}

	Chancery {
		{Zapf Chancery}
		{ITC Zapf Chancery}
		{BlackChancery}
		{URW Chancery L}
	}

	Charter {
		{Charter}
		{Bitstream Charter}
		{Charis SIL}
		{Bitstream Vera Serif}
		{DejaVu Serif}
		{FreeSerif}
		{Times New Roman}
	}

	Courier {
		{Bitstream Vera Sans}
		{DejaVu Sans}
		{Cumberland AMT}
		{Lucida Console}
	}

	Fixed {
		{Bitstream Vera Sans Mono}
		{DejaVu Sans Mono}
		{Lucida Console}
		{Andale Mono}
		{Courier New}
		{Luxi Mono}
		{Nimbus Mono L}
		{FreeMono}
		{Mono}
		{Fonotone}
		{Courier}
	}

	Fourier {
		{Utopia}
		{Bitstream Vera Serif}
		{DejaVu Serif}
		{Times New Roman}
		{Times}
	}

	Helvetica {
		{Bitstream Vera Sans}
		{DejaVu Sans}
		{Arial}
		{Verdana}
		{Albany AMT}
		{Nimbus Sans L}
		{Luxi Sans}
		{Lucida}
		{Lucida Sans Unicode}
		{Tahoma}
		{FreeSans}
		{MgOpen Modata}
		{Helvetica}
	}

	{Latin Modern} {
		{BaKoMa}
		{CM Unicode}
		{Latin Modern Roman}
		{TeX Tyre Germes}
		{Bitstream Vera Serif}
		{DejaVu Serif}
		{Times New Roman}
		{Times}
	}

	{New Century} {
		{New Century Schoolbook}
		{Century Schoolbook}
		{Century Schoolbook L}
	}

	Palatino {
		{Palatino}
		{Palatino Linotype}
		{URW Palladio L}
	}

	Times {
		{Bitstream Vera Serif}
		{DejaVu Serif}
		{Times New Roman}
		{Nimbus Roman No9 L}
		{Charter}
		{Georgia}
		{Luxi Serif}
		{Lucida Bright}
		{New Century Schoolbook}
		{Tom's New Roman}
		{Utopia}
		{Thryomanes}
		{FreeSerif}
		{MgOpen Canonica}
		{Times}
	}
}

#foreach fam [array names fontFamilies] {
#	foreach f $fontFamilies($fam) { set BuiltinFontMap($f) $fam }
#}
#unset f fam

array set Vars {
	open				0
	additional		{}
	fonts				{}
	fonts,fixed		{}
	geometry			{}
	recentColors	{{} {} {} {} {} {}}
	sizes				{8 9 10 11 12 14 16 18 20 22 24 26 28}
	styles			{Regular Italic Bold {Bold Italic}}
	sample			"AaBbYyZz\n0123456789"
}

set Vars(sizes,lcase)			$Vars(sizes)
set Vars(fonts,fixed,lcase)	$Vars(fonts,fixed)
set Vars(styles,lcase)			{}

foreach style $Vars(styles) {
	lappend Vars(styles,lcase) [string tolower $style]
}

namespace export choosefont geometry


proc mc {tok} { return [tk::msgcat::mc [set $tok]] }


proc messageBox {parent msg buttons defaultButton} {
	return [tk_messageBox -icon info -parent $parent -message $msg -type okcancel]
}


proc choosefont {font args} {
	set parent .
	set effects {}
	set title [Tr FontSelection]
	set app [tk appname]
	set class ""
	set apply {}
	set geometry {}
	set modal true
	set key [lindex $args 0]

	while {[llength $key]} {
		if {[llength $args] <= 1} {
			return -code error "no value given to option \"$key\""
		}

		set value [lindex $args 1]
		set args [lreplace $args 0 1]

		switch -exact -- $key {
			-parent {
				set parent $value
				if {![winfo exists $parent]} {
					return -code error "window name \"$parent\" doesn't exist"
				}
			}
			
			-app {
				set app $value
			}

			-class {
				set class $value
			}

			-effects {
				set effects $value
				if {[llength $effects] && ![string is boolean $effects]} {
					return -code error "option \"$key\": expected boolean but got \"$value\""
				}
			}
			
			-apply {
				set apply $value
			}

			-receiver {
				set recv $value
			}

			-modal {
				if {![string is boolean $value]} {
					return -code error "option \"$key\": value should be boolean"
				}
				set modal $value
			}

			-title {
				set title $value
			}
			
			-geometry {
				if {$value eq "last"} {
					set $geometry [geometry]
				} else {
					if {[regexp {^(\d+x\d+)?(\+\d+\+\d+)?$} $value] == 0} {
						return -code error \
							"option \"$key\": invalid geometry '$value'; should be \[WxH\]\[+X+Y\]"
					}
					set geometry $value
				}
			}

			default {
				return -code error \
					"unknown option \"$key\": should be -app, -apply, \
					-effects, -geometry, -modal, -parent, or -title"
			}
		}

		set key [lindex $args 0]
	}

	return [OpenDialog $parent $class $app $font $title $effects $apply $recv $geometry $modal]
}


proc geometry {{whichPart size}} {
	variable Vars

	set geom $Vars(geometry)
	if {[llength $geom] == 0} { return "" }

	switch -- $whichPart {
		size	{ set geom [lindex [split $geom "+"] 0] }
		pos	{ set geom [string range $geom [string first "+" $geom] end] }
	}

	return $geom
}


proc isOpen {} { return [set [namespace current]::Vars(open)] }


proc build {path font {enableEffects {}} {color {}}} {
	ttk::frame $path
	BuildFrame $path 0 $font $enableEffects $path $color
	Init $path
	return $path
}


proc select {w args} {
	variable ${w}::S

	switch $S(style) {
		"Regular"		{ lassign {normal roman} weight slant }
		"Bold"			{ lassign {bold roman} weight slant }
		"Italic"			{ lassign {normal italic} weight slant }
		"Bold Italic"	{ lassign {bold italic} weight slant }
	}

	foreach {key value} $args {
		switch -- $key {
			-family		{ set S(font) $value }
			-size			{ set S(size) $value }
			-slant		{ set slant [string tolower $value] }
			-weight		{ set weight [string tolower $value] }
			-overstrike	{ set S(overstrike) $value }
			-underline	{ set S(underline) $value }
			-color		{ set S(color) $value }
		}
	}

	set S(style) [Style $weight $slant]
	set S(style:tr) [set mc::$S(style)]
	foreach var {font size style} { set S(prev,$var) $S($var) }
	foreach var {font size style:tr} { set S(current,$var) $S($var) }

	SetColor $w $S(color)
	Apply $w 
	Tracer $w
}


proc setFonts {w {fonts {}}} {
	variable ${w}::S
	variable Vars

	set S(map) 0

	if {[llength $fonts] > 0} {
		set lcase {}
		set fonts [lsort -unique -dictionary $fonts]
		foreach font $fonts { lappend lcase [string tolower $font] }
		set state disabled

		if {[llength $fonts] <= 30} {
			variable fontFamilies

			set S(map) 1
			foreach fam $lcase {
				if {[llength [MapFamily $fam]] == 0} { set S(map) 0 }
			}
		}
	} elseif {$S(fixed)} {
		set fonts $Vars(fonts,fixed)
		set lcase $Vars(fonts,fixed,lcase)
		set state normal
	} else {
		set fonts $Vars(fonts)
		set lcase $Vars(fonts,lcase)
		set state normal
	}

	set S(fonts) $fonts
	set S(fonts,lcase) $lcase
	$w.filter.fixed configure -state $state
}


proc setSizes {w {sizes {}}} {
	variable ${w}::S
	variable Vars

	if {[llength $sizes] == 0} {
		set sizes $Vars(sizes)
	} else {
		set sizes [lsort -unique -integer $sizes]
	}

	set S(sizes) $sizes
	set S(sizes,lcase) $sizes
}


proc setSample {w {sample {}}} {
	variable Vars

	if {[llength $sample] == 0} { set sample $Vars(sample) }
	$w.sample.fsample.sample configure -text $sample
}


proc addFontFamily {family} {
	variable Vars

	lappend Vars(additional) $family
	set Vars(fonts) {}
}


proc fontFamilies {{caseSensitive true}} {
	variable Vars

	SearchFonts
	if {$caseSensitive} { return $Vars(fonts) }
	return $Vars(fonts,lcase)
}


proc resetFonts {} {
	set [namespace current]::Vars(fonts) {}
}


proc Tr {tok} { return [mc [namespace current]::mc::$tok] }


proc OpenDialog {parent class app font title enableEffects applyProc receiver geometry modal} {
	variable iconOk
	variable iconCancel
	variable iconApply
	variable iconReset

	if {[isOpen]} { return -code error "choosefont dialog already open" }

	set point [expr {$parent eq "." ? "" : "."}]
	set dlg ${parent}${point}__choosefont__
	if {[llength $class]} {
		toplevel $dlg -padx 10 -pady 10 -class $class
	} else {
		toplevel $dlg -padx 10 -pady 10
	}
	set cancelCmd [list $dlg.buttons.cancel invoke]
	switch $::tcl_platform(platform) {
		macintosh	{ bind $dlg <Command-period> $cancelCmd }
		windows		{ bind $dlg <Escape> $cancelCmd }
		x11			{ bind $dlg <Escape> $cancelCmd; bind $dlg <Control-c> $cancelCmd }
	}
	bind $dlg <Configure>	[list [namespace current]::RecordGeometry %W]
	bind $dlg <Alt-Key>		[list tk::AltKeyInDialog $dlg %A]

	BuildFrame $dlg 1 $font $enableEffects $receiver

	variable ${dlg}::S

	ttk::style configure fsbox.TButton -anchor w -width -1
	set buttons [tk::frame $dlg.buttons]
	set focusInCmd "%W configure -default active; $buttons.ok configure -default normal"
	set focusOutCmd "%W configure -default normal; $buttons.ok configure -default active"

	ttk::button $buttons.ok \
		-style fsbox.TButton \
		-class TButton \
		-default active \
		-command [namespace code [list Done $dlg 1]]
	ttk::button $buttons.cancel \
		-style fsbox.TButton \
		-class TButton \
		-command [namespace code [list Done $dlg 0]]

	bind $buttons.cancel <FocusIn> $focusInCmd
	bind $buttons.cancel <FocusOut> $focusOutCmd
	bind $buttons.cancel <Return> { event generate %W <Key-space>; break }
	bind $dlg <Return> "
		if {\[$buttons.ok cget -state\] eq {normal}} {
			focus $buttons.ok
			event generate $buttons.ok <Key-space>
		}
	"

	if {[llength $iconOk] && [llength $iconCancel]} {
		$buttons.ok configure -compound left -image $iconOk
		$buttons.cancel configure -compound left -image $iconCancel
		tk::SetAmpText $buttons.ok " [Tr Ok] "
		tk::SetAmpText $buttons.cancel " [Tr Cancel] "
	} else {
		tk::SetAmpText $buttons.ok "   [Tr Ok]   "
		tk::SetAmpText $buttons.cancel "   [Tr Cancel]   "
	}

	if {[llength $applyProc]} {
		tk::AmpWidget ttk::button $buttons.apply \
			-style fsbox.TButton \
			-class TButton \
			-command [namespace code [list Apply $dlg $applyProc]]
		tk::AmpWidget ttk::button $buttons.reset \
			-style fsbox.TButton \
			-class TButton \
			-command [namespace code [list Reset $dlg]]

		bind $buttons.apply <FocusIn>  $focusInCmd
		bind $buttons.reset <FocusIn>  $focusInCmd
		bind $buttons.apply <FocusOut> $focusOutCmd
		bind $buttons.reset <FocusOut> $focusOutCmd
		bind $buttons.apply <Return> { event generate %W <Key-space>; break }
		bind $buttons.reset <Return> { event generate %W <Key-space>; break }

		if {[llength iconApply] && [llength iconReset]} {
			$buttons.apply configure -compound left -image $iconApply
			$buttons.reset configure -compound left -image $iconReset
			tk::SetAmpText $buttons.apply " [Tr Apply] "
			tk::SetAmpText $buttons.reset " [Tr Reset] "
		} else {
			tk::SetAmpText $buttons.apply "   [Tr Apply]   "
			tk::SetAmpText $buttons.reset "   [Tr Reset]   "
		}
	}

	grid $buttons.ok		-row 0 -sticky ew
	grid $buttons.cancel	-row 2 -sticky ew

	grid rowconfigure $buttons 1 -minsize 5

	if {[llength $applyProc]} {
		grid $buttons.apply	-row 4 -sticky ew
		grid $buttons.reset	-row 6 -sticky ew

		grid rowconfigure $buttons 3 -minsize 10
		grid rowconfigure $buttons 5 -minsize 5
	}

	grid $dlg.buttons	-column 9 -row 3 -sticky new	-rowspan 5
	grid columnconfigure $dlg 8 -minsize 10

	Init $dlg

	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm title $dlg [expr {$app eq "" ? $title : "$app: $title"}]
	if {[winfo viewable [winfo parent $dlg]]} {
		wm transient $dlg [winfo toplevel [winfo parent $dlg]]
	}
	catch { wm attributes $dlg -type dialog }
	wm iconname $dlg ""
	wm withdraw $dlg
	update idletasks
	scan [wm grid $dlg] "%d %d %d %d" bw bh wi hi
	set w [winfo reqwidth  $dlg]
	set h [winfo reqheight $dlg]
	set S(width) $w
	set S(height) $h
	if {[string first "+" $geometry] >= 0} {
		wm geometry $dlg $geometry
	} else {
		if {$geometry eq ""} {
			set geometry [format "%dx%d" $bw $bh]
			set uw $bw
			set uh $bh
		} else {
			scan $geometry "%dx%d" uw uh
			incr w [expr {($uw - $bw)*$wi}]
			incr h [expr {($uh - $bh)*$hi}]
		}
		set sw [winfo screenwidth  $parent]
		set sh [winfo screenheight $parent]
		if {$parent eq "."} {
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
	wm minsize $dlg $uw $uh
	wm deiconify $dlg

	if {$modal} { ::ttk::grabWindow $dlg }
	focus $dlg.efont
	tkwait window $dlg
	if {$modal} { ::ttk::releaseGrab $dlg }

	set result [list $S(font) $S(size) [Weight $S(style)] [Slant $S(style)]]
	namespace delete [namespace current]::$dlg

	return $result
}


proc BuildFrame {w isDialog font enableEffects receiver {color {}}} {
	namespace eval [namespace current]::$w {}
	variable ${w}::S
	variable Vars

	if {[llength $enableEffects] == 0} {
		set enableEffects [expr {$::tcl_platform(platform) eq "windows"}]
	}

	set S(fixed) 0
	set S(recv) $receiver
	set S(fontobj) $font
	set S(color) $color
	set S(map) 0
	set S(locked) 0

	SearchFonts
	foreach var {fonts styles sizes} {
		set S($var) $Vars($var)
		set S($var,lcase) $Vars($var,lcase)
	}

	set S(styles) {}
	set S(styles,lcase) {}
	foreach style $Vars(styles) {
		lappend S(styles) [set mc::$style]
		lappend S(styles,lcase) [string tolower [set mc::$style]]
	}

	if {$isDialog} {
		tk::AmpWidget ttk::label $w.font  -text "[Tr Family]:"
		tk::AmpWidget ttk::label $w.style -text "[Tr Style]:"
		tk::AmpWidget ttk::label $w.size  -text "[Tr Size]:"

		bind $w.font  <<AltUnderlined>> [list focus $w.lfonts]
		bind $w.style <<AltUnderlined>> [list focus $w.lstyles]
		bind $w.size  <<AltUnderlined>> [list focus $w.lsizes]
	} else {
		ttk::label $w.font	-text [string map {& ""} "[Tr Family]:"]
		ttk::label $w.style	-text [string map {& ""} "[Tr Style]:"]
		ttk::label $w.size	-text [string map {& ""} "[Tr Size]:"]
	}

	set height 8
	ttk::entry $w.efont \
		-textvariable [namespace current]::${w}::S(font) \
		-exportselection no \
		-background white \
		-validatecommand [namespace code [list Validate $w %P %d font]] \
		-validate key
	ttk::scrollbar $w.sbfonts -command [list $w.lfonts yview]
	tk::listbox $w.lfonts \
		-listvariable [namespace current]::${w}::S(fonts) \
		-yscroll [list $w.sbfonts set] \
		-height $height \
		-width 0 \
		-background white \
		-exportselection 0 \
		-highlightthickness 0 \
		-setgrid 1
	ttk::entry $w.estyle \
		-textvariable [namespace current]::${w}::S(style:tr) \
		-exportselection no \
		-background white \
		-validatecommand [namespace code [list Validate $w %P %d style:tr]] \
		-validate key \
		-width 0
	tk::listbox $w.lstyles \
		-listvariable [namespace current]::${w}::S(styles) \
		-height $height \
		-width 0 \
		-background white \
	   -exportselection 0 \
		-highlightthickness 0
	ttk::entry $w.esize \
		-textvariable [namespace current]::${w}::S(size) \
		-exportselection no \
		-background white \
		-validatecommand [namespace code [list Validate $w %P %d size]] \
		-validate key \
		-width 0
	ttk::scrollbar $w.sbsizes -command [list $w.lsizes yview]
	tk::listbox $w.lsizes \
		-listvariable [namespace current]::${w}::S(sizes) \
	   -yscroll [list $w.sbsizes set] \
		-width 6 \
		-height $height \
		-background white \
		-exportselection 0 \
		-highlightthickness 0

	bind $w.efont  <FocusIn>  { %W selection range 0 end }
	bind $w.estyle <FocusIn>  { %W selection range 0 end }
	bind $w.esize  <FocusIn>  { %W selection range 0 end }
	bind $w.efont  <FocusOut> [namespace code [list FocusOut $w font]]
	bind $w.estyle <FocusOut> [namespace code [list FocusOut $w style]]
	bind $w.esize  <FocusOut> [namespace code [list FocusOut $w size]]

	foreach var {font style size} {
		bind $w.l${var}s <<ListboxSelect>> [namespace code [list Click $w $var]]
	}
	bind $w.lfonts <Home> [namespace code {
		set w [winfo parent %W]
		set ${w}::S(font) [lindex [set ${w}::S(fonts)] 0]
		Tracer $w
	}]
	bind $w.lfonts <End> [namespace code {
		set w [winfo parent %W]
		set ${w}::S(font) [lindex [set ${w}::S(fonts)] end]
		Tracer $w
	}]
	bind $w.lfonts <KeyPress> [namespace code {
		if {%s <= 1 && [string length %K] == 1 && [string is alnum %K]} {
			set w [winfo parent %W]
			set n [lsearch -glob [set ${w}::S(fonts,lcase)] [string tolower %K]*]
			if {$n == -1} {
				bell
			} else {
				set ${w}::S(font) [lindex [set ${w}::S(fonts)] $n]
				Tracer $w
			}
		}
	}]

	if {[llength $color]} {
		package require colormenu

		set WC $w.color
		tk::AmpWidget ttk::labelframe $WC -text [Tr Color]
		tk::AmpWidget ttk::button $WC.select \
			-text [Tr Color] \
			-command [namespace code [list SelectColor $w]]
		ttk::label $WC.name \
			-text [::dialog::choosecolor::getActualColor $color] \
			-relief ridge \
			-anchor center
	}

	set WF $w.filter
	ttk::labelframe $WF -text [Tr Filter]
	if {$isDialog} {
		tk::AmpWidget ttk::checkbutton $WF.fixed \
			-variable [namespace current]::${w}::S(fixed) \
			-text [Tr FixedOnly] \
			-command [namespace code [list Filter $w]]
	} else {
		ttk::checkbutton $WF.fixed \
			-variable [namespace current]::${w}::S(fixed) \
			-text [string map {& ""} [Tr FixedOnly]] \
			-command [namespace code [list Filter $w]]
	}

	if {[llength $color] == 0} {
		set WE $w.effects
		ttk::labelframe $WE -text [Tr Effects]
		if {$isDialog} {
			tk::AmpWidget ttk::checkbutton $WE.strike \
				-variable [namespace current]::${w}::S(strike) \
				-text [Tr Strikeout] \
				-command [namespace code [list Click $w strike]]
			tk::AmpWidget ttk::checkbutton $WE.under \
				-variable [namespace current]::${w}::S(under) \
				-text [Tr Underline] \
				-command [namespace code [list Click $w under]]
		} else {
			ttk::checkbutton $WE.strike \
				-variable [namespace current]::${w}::S(strike) \
				-text [string map {& ""} [Tr Strikeout]] \
				-command [namespace code [list Click $w strike]]
			ttk::checkbutton $WE.under \
				-variable [namespace current]::${w}::S(under) \
				-text [string map {& ""} [Tr Underline]] \
				-command [namespace code [list Click $w under]]
		}

		if {!$enableEffects} {
			$WE.strike configure -state disabled
			$WE.under configure -state disabled
		}
	}

	set WS $w.sample
	ttk::labelframe $WS -text [Tr Sample]
	tk::label $WS.fsample -borderwidth 1 -relief sunken
	tk::label $WS.fsample.sample -text $Vars(sample) -background white
	if {[llength $color]} { $WS.fsample.sample configure -foreground $color }
	set S(sample) $WS.fsample.sample
	pack $WS.fsample -fill both -expand 1 -padx 10 -pady 10 -ipady 15
	pack $WS.fsample.sample -fill both -expand 1
	pack propagate $WS.fsample 0

	grid $WF.fixed		-row 1 -sticky w -padx 10
	grid rowconfigure $WF 2 -minsize 3

	if {[llength $color]} {
		grid $WC.select	-row 1 -column 1 -sticky w
		grid $WC.name		-row 1 -column 3 -sticky nsew -pady 1
		grid rowconfigure $WC {0 2} -minsize 5
		grid columnconfigure $WC 2 -minsize 5
		grid columnconfigure $WC {0 4} -minsize 10
		grid columnconfigure $WC 3 -weight 1
	} else {
		grid $WE.strike	-row 1 -sticky w -padx 10
		grid $WE.under		-row 2 -sticky w -padx 10
		grid rowconfigure $WE 3 -minsize 3
	}

	grid $w.font		-column 1 -row 1 -sticky ew	-columnspan 2
	grid $w.style		-column 4 -row 1 -sticky ew
	grid $w.size		-column 6 -row 1 -sticky ew	-columnspan 2
	grid $w.efont		-column 1 -row 3 -sticky ew	-columnspan 2
	grid $w.estyle		-column 4 -row 3 -sticky ew
	grid $w.esize		-column 6 -row 3 -sticky ew	-columnspan 2
	grid $w.lfonts		-column 1 -row 5 -sticky nsew
	grid $w.sbfonts	-column 2 -row 5 -sticky nsew
	grid $w.lstyles	-column 4 -row 5 -sticky nsew
	grid $w.lsizes		-column 6 -row 5 -sticky nsew
	grid $w.sbsizes	-column 7 -row 5 -sticky nsew
	grid $WS				-column 1 -row 7 -sticky nsew	-columnspan 2 -rowspan 3
	if {[llength $color]} {
		grid $WC			-column 4 -row 7 -sticky new	-columnspan 4
		grid $WF			-column 4 -row 9 -sticky sew	-columnspan 4
	} else {
		grid $WF			-column 4 -row 7 -sticky new	-columnspan 4
		grid $WE			-column 4 -row 9 -sticky sew	-columnspan 4
	}

	grid columnconfigure $w {3 5} -minsize 10
	grid columnconfigure $w 1 -minsize 210
	grid columnconfigure $w 1 -weight 10000
	grid columnconfigure $w 4 -weight 1

	grid rowconfigure $w {6 8} -minsize 10
	grid rowconfigure $w {2 4} -minsize 3
	grid rowconfigure $w 5 -weight 10000
	grid rowconfigure $w 3 -weight 1

	if {!$isDialog} {
		bind $WS.fsample <Destroy> [list namespace delete [namespace current]::$w]
	}

	foreach item {font size style} { set S(prev,$item) {} }
}


proc FocusOut {w attr} {
	variable ${w}::S

	$w.e$attr selection clear
	set n [$w.l${attr}s curselection]

	if {$attr eq "style"} {
		if {[llength $n] == 0} {
			if {$S(style:tr) ni $S(styles)} {
				set S(style) $S(prev,style)
				set S(style:tr) [set mc::$S(style)]
				Tracer $w
			}
		} else {
			set S(style:tr) [lindex $S(styles) $n]
			MapStyle $w
		}
	} else {
		if {[llength $n] == 0} {
			if {$S($attr) ni $S(${attr}s)} {
				set S($attr) $S(prev,$attr)
				Tracer $w
			}
		} else {
			set S($attr) [lindex $S(${attr}s) $n]
		}
	}
}


proc SelectColor {w} {
	variable ${w}::S
	variable Vars

	set selection [::colormenu::popup $w.color.select \
							-class Dialog \
							-oldcolor $S(color) \
							-initialcolor $S(color) \
							-recentcolors $Vars(recentColors) \
							-geometry last \
							-modal true \
							-parent [winfo toplevel $w] \
							-place centeronparent]
	
	if {[llength $selection]} {
		set Vars(recentColors) [::dialog::choosecolor::addToList $Vars(recentColors) $S(color)]
		if {[llength $S(recv)]} { event generate $S(recv) <<FontColor>> -data $selection }
		SetColor $w $selection
	}
}


proc SetColor {w color} {
	variable ${w}::S

	set S(color) $color
	$w.sample.fsample.sample configure -foreground $color
	$w.color.name configure -text [::dialog::choosecolor::getActualColor $color]
}


proc RecordGeometry {dlg} {
	if {[winfo toplevel $dlg] ne $dlg} { return }

	variable ${dlg}::S
	scan [wm geometry $dlg] "%dx%d%d%d" w h x y

	if {$w > 1} {
		scan [wm grid $dlg] "%d %d %d %d" bw bh wi hi
		set w [expr {($w - $S(width))/$wi + $bw}]
		set h [expr {($h - $S(height))/$hi + $bh}]
		set S(geometry) "${w}x${h}+${x}+${y}"
	}
}


proc SearchFonts {} {
	variable Vars

	if {[llength $Vars(fonts)] == 0} {
		set families [font families]
		lappend families {*}$Vars(additional)
		set Vars(fonts) [lsort -unique -dictionary $families]
		foreach f $Vars(fonts) { lappend Vars(fonts,lcase) [string tolower $f] }
	}
}


proc Weight {style} {
	return $style eq "Bold Italic" || $style eq "Bold" ? "bold" : "normal"
}


proc Slant {style} {
	return $style eq "Bold Italic" || $style eq "Italic" ? "italic" : "roman"
}


proc Apply {dlg {func {}}} {
	variable ${dlg}::S

	# Change font to have new characteristics.
	font configure $S(fontobj) \
		-family $S(font) \
		-size $S(size) \
		-slant [Slant $S(style)] \
		-weight [Weight $S(style)] \
		-overstrike $S(strike) \
		-underline $S(under)
	
	if {[llength $func]} { $func $S(fontobj) }
}


proc Reset {dlg} {
	variable ${dlg}::S
	variable Vars

	foreach var {font size style strike under color} {
		set S($var) $S(init,$var)
		set S(prev,$var) $S($var)
	}

	set S(style:tr) [set mc::$S(style)]

	if {$S(fixed) && [string tolower $S(font)] ni $S(fonts)} {
		set S(fixed) 0
		set S(fonts) $Vars(fonts)
		set S(fonts,lcase) $Vars(fonts,lcase)
	}

	Apply $dlg
	Tracer $dlg
}


proc Done {dlg ok} {
	if {$ok} { Apply $dlg }
	destroy $dlg
}


proc SearchFixed {w} {
	variable ${w}::S
	variable Vars

	foreach f $Vars(fonts) {
		incr S(progress)
		update idletasks

		if {[font metrics [list $f] -fixed] == 1} {
			lappend Vars(fonts,fixed) $f
			lappend Vars(fonts,fixed,lcase) [string tolower $f]
		}
	}
}


proc Filter {w} {
	variable ${w}::S
	variable Vars

	if {$S(fixed)} {
		if {[llength $Vars(fonts,fixed)] == 0} {
			# NOTE: estimated time per font: 0.3s (probed under Linux)
			set estimated [expr 0.035*[llength $Vars(fonts)]]
			if {[expr $estimated <= 15]} {
				set reply "continue"
			} else {
				set minutes [expr {(int($estimated) + 59)/60}]
				set reply [messageBox \
									[winfo toplevel $w] \
									[format [Tr SeveralMinutes] $minutes] \
									{ cancel continue } \
									continue \
								]
			}
			if {$reply eq "cancel"} {
				set S(fixed) 0
				return
			} else {
				set S(progress) 0
				dialog::progressBar [winfo toplevel $w].progress \
					-title [Tr Wait] \
					-message "[Tr SearchTitle] ..." \
					-maximum [llength $Vars(fonts)] \
					-variable [namespace current]::${w}::S(progress) \
					-command [namespace code [list SearchFixed $w]]
			}
		}
		set S(fonts) $Vars(fonts,fixed)
		set S(fonts,lcase) $Vars(fonts,fixed,lcase)
	} else {
		set S(fonts) $Vars(fonts)
		set S(fonts,lcase) $Vars(fonts,lcase)
	}

	Tracer $w
	Show $w
}


proc Style {weight slant} {
	if {$weight eq "bold"} {
		if {$slant eq "italic"} { return "Bold Italic" }
		return "Bold"
	}
	if {$slant eq "italic"} { return "Italic" }
	return "Regular"
}


proc Init {w} {
	variable ${w}::S

	array set F [font actual $S(fontobj)]

	set S(font) $F(-family)
	set S(size) $F(-size)
	set S(style) [Style $F(-weight) $F(-slant)]
	set S(strike) $F(-overstrike)
	set S(under) $F(-underline)
	set S(style:tr) [set mc::$S(style)]

	if {![info exists S(color)]} {
		set S(color) black
	}

	# sometimes "font actual" gives a negative size
	if {$S(size) < 0} { set S(size) [expr {-$S(size)}] }

	foreach var {font size style strike under color} {
		set S(init,$var) $S($var)
		set S(prev,$var) $S($var)
	}

	foreach var {font size style:tr} {
		set S(current,$var) $S($var)
	}

	Tracer $w
}


proc Click {w who} {
	variable ${w}::S

	if {$S(locked)} { return }
	set value [$w.l${who}s get [$w.l${who}s curselection]]

	if {$who eq "style"} {
		set S($who:tr) $value
		MapStyle $w
	} else {
		set S($who) $value
	}

	Show $w
	if {[llength $S(recv)]} { event generate $S(recv) <<FontSelected>> -data [Result $w] }
}


proc Select {w {autoComplete 0}} {
	variable ${w}::S

	if {$S(locked)} { return }

	set changed {}
	set nstate normal
	set S(locked) 1 ;# avoid recursive calls

	# Make selection in each listbox
	foreach {attr var} {font font style style:tr size size} {
		set e $w.e${attr}
		set l $w.l${attr}s
		$l selection clear 0 end
		if {[$e selection present]} {
			$e delete sel.first sel.last
		}
	   set value [string tolower $S(current,$var)]

		if {[string length $value] > 0} {
			set n [lsearch -exact $S(${attr}s,lcase) $value]
			if {$n != -1} {
				lappend changed $attr
			} elseif {$attr ne "size"} {	;# No match, try prefix
				set n [lsearch -glob $S(${attr}s,lcase) "$value*"]
				if {	$n == -1
					|| [string match "$value*" [lindex $S(${attr}s,lcase) [expr {$n + 1}]]]} {
					set nstate disabled
				}
			} else {
				set nstate disabled
			}

			if {$n != -1} {
				$l selection set $n
				$l activate $n
				$l see $n

				if {$autoComplete && $nstate eq "normal"} {
					$e delete 0 end
					$e insert 0 [lindex $S(${attr}s) $n]
					$e selection clear
					$e selection range [string length $value] end
					$e icursor [string length $value]
				}
			} else {
				$e icursor end
				$e selection clear
			}
		}
	}

	if {[llength $changed]} { Show $w }

	if {[string match *.__choosefont__.* $w]} {
		$w.buttons.ok configure -state $nstate
		catch { $w.buttons.apply configure -state $nstate }
	}

	set S(locked) 0
	return $changed
}


proc MapStyle {w} {
	variable Vars
	variable ${w}::S

	set S(style) [lindex $Vars(styles) [lsearch $S(styles) $S(style:tr)]]
}


proc Validate {w content action var} {
	variable ${w}::S

	if {$S(locked)} { return 1 }

	foreach attr {font style:tr size} {
		set S(current,$attr) $S($attr)
	}
	set S(current,$var) $content

	foreach var [Select $w [expr {$action == 1}]] {
		if {$S(prev,$var) ne $S($var)} {
			set S(prev,$var) $S($var)
			if {[llength $S(recv)]} { event generate $S(recv) <<FontSelected>> -data [Result $w] }
		}
	}

	return 1
}


proc Tracer {w args} {
	variable ${w}::S

	if {$S(locked)} { return }
	if {![info exists S(strike)]} { return }

	foreach var {font style:tr size} {
		set S(current,$var) $S($var)
	}

	foreach var [Select $w no] {
		if {$S(prev,$var) ne $S($var)} {
			set S(prev,$var) $S($var)
			if {[llength $S(recv)]} { event generate $S(recv) <<FontSelected>> -data [Result $w] }
		}
	}
}


proc Result {w {fam {}}} {
	variable ${w}::S

	MapStyle $w
	if {[llength $fam] == 0} { set fam $S(font) }
	if {$S(size) in $S(sizes)} {
		set S(result) [list $fam $S(size)]
	} else {
		set S(result) [list $fam $S(prev,size)]
	}
	switch $S(style) {
		"Regular"		{ lappend S(result) normal roman }
		"Bold"			{ lappend S(result) bold roman }
		"Italic"			{ lappend S(result) normal italic }
		"Bold Italic"	{ lappend S(result) bold italic }
	}
	if {$S(strike)} { lappend S(result) overstrike }
	if {$S(under)} { lappend S(result) underline }

	return $S(result)
}


proc Show {w} {
	variable ${w}::S
	variable Vars
	variable fontFamilies

	set family ""

	if {$S(map)} {
		set fam [MapFamily $S(font)]

		if {[llength $fam] > 0} {
			set index 0
			set n -1
			set families $fontFamilies($fam)

			while {$n == -1 && $index < [llength $families]} {
				set fam [string tolower [lindex $families $index]]
				set n [lsearch -exact $Vars(fonts,lcase) $fam]
				incr index
			}
			if {$n >= 0} { set family $fam }
		}
	}

	$S(sample) configure -font [Result $w $family]
}


proc MapFamily {fam} {
	switch -glob -- [string map {" " ""} [string tolower $fam]] {
		avantgarde*								{ return {Avant Garde} }
		bookman*									{ return Bookman }
		chancery* - zapfchancery*			{ return Chancery }
		charter*									{ return Charter }
		courier*									{ return Courier }
		fixed* - monospace*					{ return Fixed }
		fourier* - utopia*					{ return Fourier }
		latinmodern* - computermodern*	{ return {Latin Modern} }
		helvetica* - sans* - swiss*		{ return Helvetica }
		newcentury* - century*				{ return {New Century} }
		palatino*								{ return Palatino }
		times* - serif*						{ return Times }
	}

	return ""
}

} ;# namespace choosefont
} ;# namespace dialog

# vi:set ts=3 sw=3:
