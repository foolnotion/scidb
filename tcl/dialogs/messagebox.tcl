# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# =================================================================
# Modifications by Gregor Cramer
# Copyright: (C) 2009-2012 Gregor Cramer
# =================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
if {[catch { package require tkpng }]} { package require Img }
package provide messagebox 1.0

namespace eval dialog {
namespace eval mc {
### Client Relevant Data ########################################
set Ok				"&OK"
set Cancel			"&Cancel"
set Yes				"&Yes"
set No				"&No"
set Retry			"&Retry"
set Abort			"&Abort"
set Ignore			"&Ignore"
set Continue		"Con&tinue"

set Error			"Error"
set Warning			"Warning"
set Information	"Information"
set Question		"Query"
set Wait				"Wait"

set DontAskAgain	"Don't ask again"
#################################################################
} ;# namespace mc

### Client Relevant Data ########################################
variable infoFont		[list [font configure TkDefaultFont -family] [font configure TkDefaultFont -size]]
variable alertFont	[list {*}$infoFont bold]

variable iconOk {}
variable iconCancel {}
variable iconGoNext {}
variable iconYes {}
#################################################################

namespace export alert error warning info question


namespace eval messagebox {

variable ButtonOrder {ok continue cancel abort retry ignore yes no}
variable Current ""


proc mc {msg} {
	package require msgcat
	return [::msgcat::mc [set $msg]]
}


proc open? {} { return [set [namespace current]::Current] }

} ;# namespace messagebox


# this is a replacement for tk_messageBox
proc messageBox {args} {
	set specs {
		{ -type		"" "" "" }
		{ -parent	"" "" "" }
		{ -icon		"" "" "" }
		{ -message	"" "" "" }
		{ -detail	"" "" "" }
		{ -default	"" "" "" }
		{ -title		"" "" "" }
		{ -embed		"" "" "" }
	}
	upvar [namespace current]::Data data
	tclParseConfigSpec [namespace current]::Data $specs "" $args

	array set opts [list        \
		-parent	$data(-parent)  \
		-message	$data(-message) \
		-detail	$data(-detail)  \
		-buttons	{}              \
		-default	{}              \
		-title	$data(-title)   \
		-type		info            \
		-embed	$data(-embed)   \
	]

	switch $data(-type) {
		abortretryignore	{ set opts(-buttons) {abort retry ignore} }
		ok						{ set opts(-buttons) {ok} }
		okcancel				{ set opts(-buttons) {ok cancel} }
		retrycancel			{ set opts(-buttons) {cancel retry} }
		yesno					{ set opts(-buttons) {yes no} }
		yesnocancel			{ set opts(-buttons) {cancel yes no} }
		default				{ set opts(-buttons) {ok} }
	}

	foreach button $opts(-buttons) {
		switch $button {
			abort - cancel - ignore - no - ok - retry - yes {
				if { $data(-default) eq $button} { set opts(-default) $button }
			}
		}
	}

	if {[llength $opts(-default)] == 0} { set opts(-default) [lindex $opts(-buttons) 0] }

	switch $data(-icon) {
		error		{
			set opts(-type) error
			if {[llength $opts(-title)] == 0} { set opts(-title) [messagebox::mc ::dialog::mc::Error] }
		}
		info		{
			set opts(-type) info
			if {[llength $opts(-title)] == 0} { set opts(-title) [messagebox::mc ::dialog::mc::Information]}
		}
		warning	{
			set opts(-type) warning
			if {[llength $opts(-title)] == 0} { set opts(-title) [messagebox::mc ::dialog::mc::Warning] }
		}
		question {
			set opts(-type) question
			if {[llength $opts(-title)] == 0} { set opts(-title) [messagebox::mc ::dialog::mc::Question] }
		}
	}

	return [alert {*}[array get opts]]
}


proc error {args} {
	set specs {
		{ -parent	"" "" "" }
		{ -message	"" "" "" }
		{ -detail	"" "" "" }
		{ -buttons	"" "" "" }
		{ -default	"" "" "" }
		{ -title		"" "" "" }
		{ -check		"" "" "" }
		{ -topmost	"" "" "" }
		{ -embed		"" "" "" }
	}
	array set opts {
		-parent	.
		-message	""
		-detail	""
		-buttons	{ ok }
		-default	ok
		-title	""
		-check	""
		-type		error
		-topmost	false
		-embed   {}
	}
	upvar [namespace current]::Data data
	tclParseConfigSpec [namespace current]::Data $specs "" $args
	array set opts $args
	return [alert {*}[array get opts]]
}


proc warning {args} {
	set specs {
		{ -parent	"" "" "" }
		{ -message	"" "" "" }
		{ -detail	"" "" "" }
		{ -buttons	"" "" "" }
		{ -default	"" "" "" }
		{ -title		"" "" "" }
		{ -check		"" "" "" }
		{ -topmost	"" "" "" }
		{ -embed		"" "" "" }
	}
	array set opts {
		-parent	.
		-message	""
		-detail	""
		-buttons	{ ok cancel }
		-default	cancel
		-title	""
		-check	""
		-type		warning
		-topmost	false
		-embed   {}
	}
	upvar [namespace current]::Data data
	tclParseConfigSpec [namespace current]::Data $specs "" $args
	array set opts $args
	return [alert {*}[array get opts]]
}


proc question {args} {
	set specs {
		{ -parent	"" "" "" }
		{ -message	"" "" "" }
		{ -detail	"" "" "" }
		{ -buttons	"" "" "" }
		{ -default	"" "" "" }
		{ -title		"" "" "" }
		{ -check		"" "" "" }
		{ -topmost	"" "" "" }
		{ -embed		"" "" "" }
	}
	array set opts {
		-parent	.
		-message	""
		-detail	""
		-buttons	{ yes no }
		-default	yes
		-title	""
		-check	""
		-type		question
		-topmost	false
		-embed   {}
	}
	upvar [namespace current]::Data data
	tclParseConfigSpec [namespace current]::Data $specs "" $args
	array set opts $args
	return [alert {*}[array get opts]]
}


proc info {args} {
	set specs {
		{ -parent	"" "" "" }
		{ -message	"" "" "" }
		{ -detail	"" "" "" }
		{ -buttons	"" "" "" }
		{ -default	"" "" "" }
		{ -title		"" "" "" }
		{ -check		"" "" "" }
		{ -topmost	"" "" "" }
		{ -embed		"" "" "" }
	}
	array set opts {
		-parent	.
		-message	""
		-detail	""
		-buttons	{ ok }
		-default	ok
		-title	""
		-check	""
		-type		info
		-topmost	false
	}
	upvar [namespace current]::Data data
	tclParseConfigSpec [namespace current]::Data $specs "" $args
	array set opts $args
	return [alert {*}[array get opts]]
}


proc alert {args} {
	variable iconGoNext
	variable iconCancel
	variable iconYes
	variable infoFont
	variable alertFont
	variable messagebox::ButtonOrder
	variable messagebox::Current

	set specs {
		{ -parent	"" "" "" }
		{ -message	"" "" "" }
		{ -detail	"" "" "" }
		{ -buttons	"" "" "" }
		{ -default	"" "" "" }
		{ -title		"" "" "" }
		{ -check		"" "" "" }
		{ -type		"" "" "" }
		{ -topmost	"" "" "" }
		{ -embed		"" "" "" }
	}
	array set opts {
		-parent	.
		-message	""
		-detail	""
		-buttons	{ ok }
		-default	ok
		-title	""
		-check	""
		-type		info
		-topmost	false
		-embed   {}
	}
	upvar [namespace current]::Data data
	tclParseConfigSpec [namespace current]::Data $specs "" $args
	array set opts $args

	if {[llength $opts(-type)] == 0} {
		set type [messagebox::mc ::dialog::mc::Information]
	}
	if {[llength $opts(-title)] == 0} {
		set opts(-title) [tk appname]
	}
	if {	[llength $opts(-default)] == 0
		|| [lsearch -exact -index 0 $opts(-buttons) $opts(-default)] == -1} {
		set opts(-default) [lindex [lindex $opts(-buttons) 0] 0]
	}

	set parent $opts(-parent)
	set path $parent
	if {$path ne "."} { set path "$path." }
	set w ${path}alert[clock milliseconds]
	while {[winfo exists $w]} { set w ${path}alert[clock milliseconds] }
	set windowingsystem [tk windowingsystem]
	tk::toplevel $w -relief solid -class Dialog
	wm title $w $opts(-title)
	wm iconname $w Dialog
	wm protocol $w WM_DELETE_WINDOW {#}
	bind $w <Alt-Key> [list tk::AltKeyInDialog $w %A]

	if {[winfo viewable [winfo toplevel $parent]] } {
		wm transient $w [winfo toplevel $parent]
	}
	if {$windowingsystem eq "aqua"} {
		catch { ::tk::unsupported::MacWindowStyle style $w moveableModal {} }
	}
	catch { wm attributes $w -type dialog }

	set alertBox [tk::frame $w.alert]

	if {[llength $opts(-embed)]} {
		set k [string first <embed> $opts(-message)]
		set ante [string trim [string range $opts(-message) 0 [expr {$k - 1}]]]
		set post [string trim [string range $opts(-message) [expr {$k + 7}] end]]

		if {[llength $ante]} {
			grid [tk::message $alertBox.ante -font $alertFont -text $ante -width 384 -justify left] \
				-row 0 -column 0 -sticky w
			grid rowconfigure $alertBox 1 -minsize 10
		}

		set f [tk::frame $alertBox.embed -borderwidth 0]
		eval $opts(-embed) $f [list $infoFont $alertFont]
		grid $f -row 2 -column 0 -sticky we
		bind $alertBox <Configure> [namespace code [list messagebox::Resize $alertBox %w]]

		if {[llength $post]} {
			grid [tk::message $alertBox.post -font $alertFont -text $post -width 384 -justify left] \
				-row 4 -column 0 -sticky w
			grid rowconfigure $alertBox 3 -minsize 10
		}
	} else {
		grid [tk::message $alertBox.text -font $alertFont -text $opts(-message) -width 384]
	}

	if {[string length $opts(-detail)]} {
		set infoText 	[tk::message $w.info -font $infoFont -text $opts(-detail) -width 384]
	} else {
		set infoText	[tk::frame $w.info -width 1 -height 1]
	}
	set iconLabel		[tk::label $w.icon -image [set [namespace current]::icon::64x64::$opts(-type)]]
	set buttonFrame	[tk::frame $w.buttonFrame]

	set entries {}
	foreach entry $opts(-buttons) {
		lassign $entry type text icon
		set index [lsearch -exact $ButtonOrder $type]
		lappend entries [list $type $text $icon $index]
	}
	set entries [lsort -integer -index 3 $entries]
	set defaultButton {}
	set col 0

	foreach entry $entries {
		lassign $entry type text icon
		if {![::info exists text] || [string length $text] == 0} {
			switch $type {
				abort		{ set text [messagebox::mc ::dialog::mc::Abort ]	}
				cancel	{ set text [messagebox::mc ::dialog::mc::Cancel]	}
				continue	{ set text [messagebox::mc ::dialog::mc::Continue]	}
				ignore	{ set text [messagebox::mc ::dialog::mc::Ignore]	}
				no			{ set text [messagebox::mc ::dialog::mc::No    ]	}
				ok			{ set text [messagebox::mc ::dialog::mc::Ok    ]	}
				retry		{ set text [messagebox::mc ::dialog::mc::Retry ]	}
				yes		{ set text [messagebox::mc ::dialog::mc::Yes   ]	}
				default	{ set text "" }
			}
		}
		if {![::info exists icon] || [llength $icon] == 0} {
			switch $type {
				ok			{ set icon $iconGoNext }
				continue	{ set icon $iconGoNext }
				cancel	{ set icon $iconCancel }
				no			{ set icon $iconCancel }
				yes		{ set icon $iconYes }
				default	{ set icon {} }
			}
		}

		set cmd [list set ::dialog::Reply $type]
		set button [::tk::AmpWidget ::ttk::button $buttonFrame.bt-$type -text " $text" -command $cmd]

		if {$type eq $opts(-default)} {
			$button configure -default active -takefocus 1
			bind $button <Return> [list $button invoke]
			set defaultButton $button
		}

		if {[llength $icon]} {
			$button configure -image $icon -compound left
		}

		bind $button <Return> {
			focus %W
			event generate %W <Key-space>
		}
		grid $button -column [incr col] -row 0 -padx [list 12 0] -sticky se
	}

	set n [lsearch -exact $entries abort]
	if {$n == -1} { set n [lsearch -exact $entries cancel] }
	if {$n == -1} { set n [lsearch -exact $entries no] }
	if {$n == -1 && [llength $entries] == 1} { set n 0 }
	if {$n == 1 && [llength $entries] == 0} { wm protocol $w WM_DELETE_WINDOW { set ::dialog::Reply "" } }

	if {$n >= 0} {
		bind escCmd [list $buttonFrame.bt-[lindex $entries $n] invoke]
		switch $::tcl_platform(platform) {
			macintosh	{ bind $w <Command-period> $escCmd }
			windows		{ bind $w <Escape> $escCmd }
			x11			{ bind $w <Escape> $escCmd; bind $w <Control-c> $escCmd }
		}
	}

	grid columnconfigure $buttonFrame 0 -weight 1

	# grid elements following guidlines from Apple HIG:
	# http://developer.apple.com/documentation/UserExperience/Conceptual/OSXHIGuidelines/index.html

	grid $iconLabel $alertBox
	grid ^ $infoText
	grid $buttonFrame - -sticky news

	grid configure $iconLabel -padx [list 24 8] -pady 15 -sticky n
	grid configure $alertBox -padx [list 8 24] -pady [list 15 4] -sticky w
	grid configure $infoText -padx [list 8 24] -pady [list 4 5] -sticky w
	grid configure $buttonFrame -padx 24 -pady [list 5 20]

	set Current $opts(-type)
	wm withdraw $w
	update idletasks

	# center the window
	set rw [winfo reqwidth $w]
	set rh [winfo reqheight $w]
	set sw [winfo screenwidth  $parent]
	set sh [winfo screenheight $parent]
	if {$parent eq "."} {
		set x0 [expr {($sw - $rw)/2 - [winfo vrootx $parent]}]
		set y0 [expr {($sh - $rh)/2 - [winfo vrooty $parent]}]
	} else {
		set x0 [expr {[winfo rootx $parent] + ([winfo width  $parent] - $rw)/2}]
		set y0 [expr {[winfo rooty $parent] + ([winfo height $parent] - $rh)/2}]
	}
	set x "+$x0"
	set y "+$y0"
	if {$windowingsystem ne "win32"} {
		if {$x0 + $rw > $sw}	{ set x "-0"; set x0 [expr {$sw - $rw}] }
		if {$x0 < 0}			{ set x "+0" }
		if {$y0 + $rh > $sh}	{ set y "-0"; set y0 [expr {$sh - $rh}] }
		if {$y0 < 0}			{ set y "+0" }
	}
	if {$windowingsystem eq "aqua"} {
		# avoid the native menu bar which sits on top of everything
		scan $y0 "%d" y
		if {0 <= $y && $y < 22} { set y0 "+22" }
	}
	wm geometry $w ${x}${y}

	if {$opts(-topmost)} {
		wm attributes $w -topmost true
	}
	wm resizable $w false false
	wm deiconify $w
#	tkwait visibility $w
	set focus [expr {[llength $defaultButton] ? $defaultButton : $w}]
	focus $focus

	if {[llength $opts(-buttons)] == 0} {
		wm protocol $w WM_DELETE_WINDOW [list destroy $w]
		wm deiconify $w
		return $w
	}

	::ttk::grabWindow $w
	vwait ::dialog::Reply
	::ttk::releaseGrab $w
	destroy $w
#	update idletasks
	set Current ""

	return $::dialog::Reply
}


proc messagebox::Resize {alertBox width} {
	if {$width > 384} {
		if {[winfo exists $alertBox.ante]} {
			$alertBox.ante configure -width $width
		}
		if {[winfo exists $alertBox.post]} {
			$alertBox.post configure -width $width
		}
	}
}

namespace eval icon {
namespace eval 64x64 {

set warning [image create photo -data {
	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
}]

set info [image create photo -data {
	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
}]

set error [image create photo -data {
	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
	e/0Ph3G8m++sUvgAAAAASUVORK5CYII=
}]

set question [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAgAElEQVR42u2beZQeV3nmf++9
	Vd/S+yZ1t/ZdsiXhRba8YJCNjY2xYwLGBENwQhISB0LCZGbICrEPkElYjgnMZBz2EPaADQRv
	wo4tbMm2Fi+SZVn7vvei/vrbqure+84f9UkWTGJmhsyZOWemzimp1epPqvvUc9/led4L///6
	f/uSV/pLVQQwACJ4AEV/9jMWMui7SflPD5qGxZTH+zz/cX2o46MJZpvvcj9z3vpl3/37/yT3
	NubadXMu0fXjtwr73wjPR57DmbDssOIelp5ktbzuD57UZT1HuWHC2wtPIC+MYzqn4/d69MlZ
	/e7DI7fD2G+Y19qvhtXz79TiWY/cugFU5MzXvxAAZ/+MiqCt78P6xcLmzDB8VFjaMI1pEA4R
	vnDnhXrs8U3eHMXsW4TZ2Af7jm5rT8PTXUS1NnSgsGTmlOE3XNpzwfjRw/X1Gw7t3rG7dsxT
	SymdbFCeW2fpbRU6nsh+dcqH3MDy36JSe8HUy/extZBSPaeo4YJXc9XOx8znzx8J0X+/eP5H
	QZCfh9BZIMi/8BkDFBLgGPgfJG3+7ud/X7eldwhfnSiyfW33ucPp3NvfNOst7e2FgbnTpl5X
	LrZNES0ixKCCDQFVRYOiKCEEjh2r7Dp4cHz9lq37X/z8N9f/iI4rDzP/qkluIKPwdd530W9G
	15+XmNd3EArgXunxf2EAfmYrmNZnFCADOQB2C0X9G97nH9v6l8Kf7+4equ6a9ae/fu7NyxcN
	3NzbU1wUxzEG06KOQQKo5jcIKHivZJnHuYCIRQM4nzJZG/cvvrj3ke9899lvP/nc8bXM+PWD
	7//iryQr003Fmy4l647JfuZZzf82ACo1ogeewc6Yh/vSXxX03n9+t4xf88uGBcvgK3s6rl4w
	vuS3f/W8986aOfWNHR3l7sgI4hURwQhAQHCtPytiLalCUAUVgoLLAt6DyzzOC2BR76jVJti6
	dfuzW7duXv35b67+aufFg/tnFPa52fd9yVXYqhu4XzJ+HFRf4izGqgjh3woAW29iHt4Gn731
	d73f/gk5PNguO64YbT934qklf3L7Oe87b+m0dxYLBRHJSRJHjlKpShzHFOICUWRBAoriQ0aS
	Wir1Imnq0ZDvKO9zfmVZQIMhZIKqgCpZ2mCyNsKBg7sPrlv/7Fe+8r0Xv3z5iZsPniIyNzHV
	fYLbrdOn3dlMPR28/y0AiOpN+Hd/NKDRZ3ZoP13206UnBv7orqnvfs2K6b83ONAxFJynGENb
	yVAuC8W2gMRVglqgCERkmaEy6Zms1alU67hmQLVIHLVTLBWJonxrWAPegU8czgEaERQaSQMf
	mpyqnGDL85vWf+uL3/yL2u5zn5jKzcnVLHQfp09Vsf9mAJx++4AdH0ffeP7b/PiBu4snzLrp
	f/lflvzapVfN/rNiwSI4ujoiOspCuQiRDQSF8bpw7HiTPXsq7NvfZM+eESYqGZlTnJsksqOE
	4NDgEYHe3l6GhwaZNXuYJQtn0FE2ZCk4L3gPQcFroFKdIGue4Mj+LYc+fdc/3LF3//APhhb9
	9viWzVeFLiqvyIAzWeznATCqyG4ozIKiVeIkNY0Z8/fqinMqyz71kYVf7e8rLikLRIVAR4+n
	o1NQAQmW8VHPc8+PsvHFjJFTKfXE4EJEkiQkSQWXTqKhiSEDzTDisEaJjaFZT3GpxwBLFs3l
	4pULmTd3Cs5BCJ7YGhr1JqkPjFcnGB87xoOPPPZf//GJpz/xzj988PjvXTGpn33nNDm8uT99
	TLf404HwrIx2GqDwigAcPIicPEm8txKZp+W68PE7P1J6FXvO++SHX/P54WkDi+PI0VmeoLe3
	g7hYJPOG8THPk2tH2L6tRqPZTirtSKGAJ1BPaqg2aNbGyJIJkmYFSNHgQR3BewwGKwWyNJA0
	UoJ6lIzpw/1cd91K5s8fJml6ikVLkjkqjQb1eoWJsUPc98APv/y9hx/92PKLDx957cgF6cFd
	+8z3j2/2r8B8jV4JgBk1mLG6wCOfTNKPX5B1vHZo6zV/cvvVnxoc7JhTiDLa2zL6+sGI0mjA
	s8+N8dTTo9SqPYQwE0dEKRaCBozU6CxUqVWPUdQJejoN5antQIz3jsnJGpPVlEYjJSjYOEZS
	g08Bjdm1a5xDBx9h+XnzeeMbVxAVIySKaOso4XyT9o4+rn/99e/OGsgPHth/5+by3KOrXvWE
	P13JnlUo/VRmeEUAmI3oPCvfFY3nN/cs/cPfWvjXA4Ptc6JiQjFu0N/TgZUOxkYDP/7xAV7a
	2cDGgzhbhoISicNkgugEwR9i6ZI2Fi6Yz9zZ/RQiIXhwDtJMaSZKM4Vjx0/xwraDbNr0ArVG
	k6jQjktjiqVOavUmTz21m+0793LL269hwcJB1ENnZxeWCM0ifumNb/517+73P3pm5ENr3vyT
	E00uCiWa8jNAnCnp7b+w7NM/KFcuwvz9S+V4c7V//ic+dOE3Boe6F7W1B6K4zkBviUIUceSY
	4557drBnr2LMdDwl4pIhLjex0SlsOMo55xhuvnk+y5f1MWtGgc42T7noKZWUYiFgTIYYj+Lo
	6G5nzrxhLrnsXNrbO9m/7wjeCcFFaIhJU0+SpTy3eQs9PT0MD03BWiF4wdo20kSYPqPvQtLD
	ZteaF55+/H2fTP7TVzfInPOOyfxZiBG48070Du74VwE4s0f+/oIPmOeeXzn0G9dedOf55y68
	slQwFAtN2spCe1sb+w7W+cb31rPvYJVSaRZWujBEWOtBJ+hsq3LTjbO46OI+2oqBYtykYFIC
	TZQ86gdRfFBcyCO8C6ASMJEwa+YUlixayJFDxxk5OUZkY8DSTDIg5sWte+hs72HGjH7igtBs
	BorFTrIQKJWz87etX/Nc2/hr9pwajY3reozXvQYpFpE77gDuvOOn3vbPXvkeOXqlfc/VN7xr
	1RUrby2YIl2x0G4CXeU2Dh9p8rVvPcuOAylx+ywcbYDFkEJ2gt62Cr/0htnMnB4TkRGLR5yg
	oYzVbjR00shKVOuWehKRuQIhFPBesMZiWhX31IES77rtKpa/apgkHSWEJuVCJyFtJ6t38IPv
	rWHTxh1gDKW2IkEs5fY+hqbNLb/zTVd9vNL7zQU38ed+29PX6YlwVkmvgiBqzs6Nu3cg1y/o
	N5gLLTf8mcx45p+Wrjjn3Nts1EVshQhPe7FA0lS+84/P8dKOBjCL1A/gQ5kgAWOrFOITXH/d
	TGYMRpSLSmzBEmNNGy6LmahYjp80nDwpjJ0SKpOWRsOSpobIxAQnEAyREdCU2Bpufssq5s2b
	gjEpLsuIo3aEdlTbueeeh9i16xBRwVAoR5RKbZQKXcyZs2DenKXuN59kdbHt2B8xdvJMTWMA
	o4pYDmn80V92vDZ6POp6knjOYWfW7n1SRqdnXe+7YcWfX7B46dVtBSi3BaQQsOWY7//oOTZs
	PIhKGVMSbFQCW0JihwuHuOLyKZy3tJuicRhXQNRCJFTSlBOVJqOVjGYaU60pDWdxQci8IpES
	JAEJRCYipIJRS/BgbcTwtH42PbOFFMGJJdiAC44kLbF3/yhLz5+DLQZEEnwSEVJLoaQzHtn2
	43Xbznn/oROVT9nrrky1vB34ci+85tNqCC93S7YMT5XK1N/WGRaHveetunzxu+NIiSLAeGzR
	snPXEdas2UCaBQyCpg6f1Qm+QpqeoKMzYcXF0zAGEA+REgQm64GTI4GJSpHx8Zh/fmQHP/zh
	09z3o3Vs3LCTLHM471DA2rwnsGf46RECw8MDLF22EDGBzCe44BAbgylx5NgpHnxwE1EUE9RQ
	KnVSKnUxODRtxoUXd7+L41/qyq5/n8tGUA4Ch/tA+8QA9NU3QBVcDYrrhsOhdWs63nHjst+O
	CyXEOIzNWkHB8/0frkFMkSiKAcUnAVerkjWO06jvZfnyPsolsCa0iJZRSzJGxgONpMzzz43w
	2b95gMfX7Gfb1lNs3byP1Q88yefvvpeTxycwEhOCYqy2errQuvOguWz5YkQCUSSIGFQtLihi
	Cmza9CJ7957EmjJxsY0oLtFe7mXFeee8sXPkgYUPfP3t8ni/1aPLUfoLCuNq8ONcOrBamIRo
	XMLqkdtkqGPTnNkzh66QqEgUeYwVjI1Yv2EHx05UyTJDUCW4DHEen0ySNY5TMOMsWTSEMXlE
	Vwo0nDI26WgkEbv3TnD/A5sIlMBaxFiEMoW4h8qE474fPU6tmiDkspPqT9UvIDA42EtcsPiQ
	gRG8AsbgAqRZzKP/vBkxhqCGQqGdQqGP3t7B6SsvXHAr2Q759Ec/5kfXEDhSBo5iVs75tp89
	G+EkMrlX9Dm7ILzp9XPe2NPXNwMT40OGMZZG4lnz+DbStISYNkJQVDPwCcHV8OkEQ1O7iIyh
	VnfUGobJqmV0TKk1IlIP6556jswnBFMnmHEcFSDCZQYNMUcOn2R8vIK1FtWAEgitJklEEIFC
	sUy5XEZo6Qeq+S42FpUi23cc4dixScSCV0Mc9VCIe5jS172S7x/tX3v1H8mqu/qjdU7ZyBHM
	Dfyu9FWBDhjdOFfHzCO9w0M9lxhbAokRLN7Dvr0nOHioQpIW8C0VzopDpAGaoN4xe/pMstRw
	4kTK8ZOOk6OBWq2EaIHRkUkOHDiE2AxjE8TUEZOAQggBlwVcptRrGVkWEAEfNO8AvaIIIeRA
	xHEx1wgwBFFUHCqKV4sLMY+vfYGo4DE2Bi1TLPayaPGiy3rs8xdwKJOxwVvd765/1iytfw6z
	AgSLUIWJQ69ixtxseOH86TdhC/hgQCO8E559dg+1aoT3JVQjREBJwTZAUkQMPT29TE4KlUrE
	+ETM6JilNgn1Ghw7NkHSbCIKEgziipDFOJ+SZQnOZYSgFAqWODIo5CqSGoyJQPO2OEsgOFDN
	t6FKQI1DJQAW7yN27TpIM/OogLVtxFE7VopcuGxwFRteirj2dyQsHZQvfAGJbmiVQ7VEeHxk
	CTK8c35kY0KAEAQTFWg0MjZs2EGlConP6JKIctFgrEHJMCYmqOXhh5+nr7dIb18Xvf19TB3o
	o7OtBBZGRyaITIx4gRCjPsKHgNMU7zJEMro6ykwbbie0lHfnAs4rQkSaKvWGp1YXGs0M1VaP
	K7mYeloQtqbA2Ohx9u0/yoz+GagPGFsiUGBoSuelPHbMcuCgb5vS0DvW90n0gnzbvvfcj7Pl
	t2aG+ZVB3vPHS95hnMUQE4wleOXAwVOcmkjItJukZkjSlO62iK62ElEctToM4eTJCsePO5w7
	SJZlZJmjUCzS09uTF5e+hKoQgs9FUB/h6AQmKNoml126nN7ubpJUyTKhmXqUGOeFWgp1Zzgx
	cYpq6lEbgQqowWqMKOAhQnGZZde2Y8y9fDYYUOlEzSC9PTPmzN55/+Dud/7d/i88buzt91S8
	6eXVWmtfoRMrrmNX9HB7dXKybMTgnSNLAw5h7/79VBpNAuAUmolj/FSdYycmODlaY2IypZkK
	XguoaScqdFNs66etcypRqZvJuqdSdWTekjohzQJp5vCaojqJMMmrls/lhhtWoj6QJQ4NQgiC
	V6WROJI0EIDtOw+SZoEQwPuAIC0gFAmQpRlWLMcOj6DqQRSRCIjp7euelcq26ae+lUS3LC8E
	4VGJhhgOz8zohv110zF1omfK1N5leE/IHLEVnCoHj41jCwWcaktjisjwBB/IGoFqIwVSRIQo
	iojjmCiKMNZgrOK9bynBMeo9BkvqEqBBudzgda+7kLf88oU0m0rwPm94mor3hmaa0UgCYstM
	TqTs2LGPLFNsFLfkHYcoqAeC5oESw9EjJ8jSXA5QBJEYa0v4oD3+0LzwBd0VdJVK9ICIcslK
	4eQGW2iTju6eztneByxClgSaBeXI8TGCgPcZYgogFqcG5y0uWERy70yAxAukHg2OEBxIhrVR
	/iCqxFYxmhKZwNDUIre96/VccME8sizfx16h0fAkTWimgcQrLsSkqbLpmZ2cHJnEmCLqBZFc
	49Jc5kCDEElElkK9lpAkSlEExCAS4TzMnjd37gN2Gve/dMLwnXO9+c8LA5x4Mua214XMTZYE
	IXiHeo8GJfVKrd7EuxQbBZQM1UDAoraIkxhHhFNLppZMDVkwOCwqMVDEhZgsRHgiEudJfYMZ
	M3r4g/ffxKUXzydNIE2VJIN6U6jUArUmJJnFUyD1MTt2H2X9hi2oxrlxYlqBL1dJIYAGwWWg
	waDe0KhneXhUASKMLXHp5ctX1DfdHI7rJXDfFIke+pyFeW9RELwSqfeoVYLzSAikmZBmCdYo
	6pPc4TndUapB1Pyr1ouclt40QhGQDBHPkoXTef97X8/UnjKVCXBBaDhDtRmo1lwrQ1gyhSSF
	ffuO8+BDT5KkBiVqLcrlTXvr1pAHQQmCaETIFOc0xycoXg1CTJYRfZfF0e47V2dkSEQnwswZ
	ShgzqiLOe2wI+CzD+EAIBoJH1CGkKBGBCCWnNfIKxouCUUNAQATVQFdXgbfesoq+njYIStqE
	WlOpOahnQuILOAei4Dxs33GYhx5cS3XS596CCNoSSkXztllDbqKczgqooGrRFjmchxDyZ1Ei
	qlhkAehOiJipMPa8UF6qAsF7n1tVzhN7j42EQhRDyMBEQNYyNgOgmFdwnoS8kJEWF8QoQ4Pd
	DE7pplGroWlGmnVTz4S6E+qZoFH+wGkzY926zWzcuI0sE1RKCNGZ/xcNBBUkmDwIBG0VWbl/
	EMUWa3IzJZzxIgUTF91rOeI2/H7NcPsyja5+b780onFd9/xblFBuNJ0jRrFZQpxmeClQLnQR
	slNIBGJT8qhnQS1qfcvgtDnCqkiLlyoBFwGhgFHBuox504cwwZAmRZwvM5EYUn+6ecorvaPH
	KjzyyHoOHDiKUECQXL3A5T2AF4KPIJi8R/KC8WC9IWR56yzeEZcNTgSXpFiX+5KbXzi0Ze2y
	c+SK+1fxxN3j3lyxdJxlXSjbu0OWFaojo+Mnvc/wLsWlCSEzTO2fgs8UdZrnVnUIDshyOuZt
	G0HyW8kNkiDgRc6MVBgL3d0dBCDJlHqS4UIgtNKXBtix/Qjf+8eHOHToBCJR7iarvGyhhzzg
	5XTn5a8DBOdAc4u9vb0dYyyZU4LPtbA4tmzeum8n04P86Wtn6e+wwkZ33kn+CuOKjpyae2r/
	voMvDg7OW9XZJmRZgo2ht7sH9RDEI5L3+SIpiEGDzRkhAcGAGoIENJcaWkVq/j1HQApFJhsO
	UYd3p0tYQRUOHRzhkR+vYbKSoMQYE+U5Xk8zP0DIwcgpc3rf54WQonl57pT+qf15us4CznmQ
	gPNNbMmfGpjzgJwqF3WYtrNE0ex7KuUFjVKp2KjVJvEhZ0HIMmYNz8QGwQRDSD0hS1DXRF2C
	qMurkBYLtMUAVF7OFqefEcUWLI0skHrBq817Dqf4TDly+CSTE3UiW8RKEYLNFxnyIkc9eRve
	cpJbdMvLYAVVJcsyVJSpQ/0Ya3COViHmGT9VORA6Ljr8jg+L/8GGI/YveFQNLxMJvbUjffa5
	7Y/44Gg2aygBlzSZ0t9Nd0cnBMW0bgkOCRmaZbm74RzqXP5mQiv3KhgVRCV/SAwh5Pu32TQk
	TUtaB5cKLhVOjU4iGhOcAW/AC8GHfMGtxZ6+1eeRTXyrCtTTw0y5eTp77kyaidKop/kC1TE2
	XtlXWX758aMbPhUtuNJxOW+zPy2Lf+D9unfPiU31epWgGc41cvPSK4sXzEfTDM0CmnnIPDiP
	8R6TeYxziPMYr2dAEA/iA8Zp3gU6gzohbRqyZpEsickSS8gE8dCse4KzqJO85W2pYYSzJ4By
	OgkGowZpBd9cV1BC8PQN9DJlcICgQggG7zzGBEbG2cgVVTdvXhN3fMhcx3vDT1tjPTB2ctG2
	nbv2PVUu9V4ax11EUqcQl1h27mLWr1+PSL7vRG2LmvmEihiDigfjWzEBlICY1r4lFzMO7B5l
	cjRDW29YRLGRRaxl8lSKepsHUX5mMqlV7r5cXOkZYyO0AiQKYoT5C+YQFSOqkxkuC4AQ1PP0
	c+mPyx/bGOYNeVvtH3C/xxUa5e2NnPnXyp1zR0dHDq93WXpprVYhNp14aWN4eCozp89g/6H9
	SCvQiQTESJ72gkeMb43ByBkQzgwDaR4Pnlz7LJBXexqgENu8UgsmV3gll+1fXmjrlzP6YCsr
	tH4/HXhUFe8dhXLM+RfMJ8s81WoDY0p4r+zYOfrkeMeNm2eUH9CxrcR/eH0jKfx1hMEEdNd8
	o4odk3bpnFzGlk1H7/cupVGvkqQ11CREhcCFKy5EtIAmYF2KzeqQKepD6/Z5KgogahGN0BAR
	fJEQyjgtk3ohk4zUThJ3e3wpIYsSfBTICLnYiqLGAw5zmv6iqFGCBILJmy8Vh0ZZC3KLmhpL
	lg/Q2dtOvW7wvp3gHUbqTIz5tVTS0e/P/U17+yrk8CVr447OPyHCBJi/G0B6++shY780R85/
	Zu+eQ+vmLihePlGdIC71YkPCuecuZsOG5zl84CAhc7lkZX0e4sVBEMTavEAxJs9SerpQD2Ac
	gZRl58zj2utWMmVqHz4LbH/pMKsf2sDIyCRGckE0OMUYQ9DQYr8BolxJDnl9oLh8gSZP2W0d
	ZS66+AJUDY2aI2SWiMCpiRNH124c/zZLZ6gTDQ1IfQlds/2vzE8Fwe3bu+jhpC/ynsrqB579
	jA9Nqs0qk/UKLmQEo1x77dX4VqeoDoLzBJehLs8GkmWQZUiWIplDNCDqkZAiIeHSS5bz9l+5
	hqkDvUSixCKcu2g6v/aONzA00EVIG0hQIqI8uhsBEyOmDZFOhB5EekF6EOmGUAaJMLFw0crz
	6e/vpVENuETywKsZz23d+/3Jy6bsfOvf/kH4xluuyf5u1Z3Nk6fE9w8jZwMQ5s+vM8aINUxx
	1bGpj720Y8eTnoyxygi1ZgWvKUPTpnLN1Ve9XID41sK9Q3wG3mHc6dvndq/zEFK6O4tcfuly
	jAI+0KjUcY06PnF0tZW58tUraC8WIAtYYiAGU0BMG5huML0ovSg9QBcinajGBPVMnzXMRSvP
	pV4LTFaaxGKwKJOVU4ee3RW+8Wff+o/ZB2Z/pjS8/sss+MmHZcuOixkBMXwoPjMmE8dOvW0P
	xz+IVuJfG394zbN/26ifqifpJLX6GKmrEki5+JILmLdgAdnpHlQ9wbszTAguxacpmqaQaT4r
	6JVpU/vo7ewga3ia1Saaac4S7/AuMH3aEB3t7RgTEZzFUCbQTqAzX7T0g/RibDdBSohEGKt0
	dJe46pqVBGKazdxPVO+wZoJNz+z/x4lrLtt8pdlY6msQ32iPyBZgd18P2b9kj4+j8NpnlEX3
	MjbtVfete2rTPZYmtfooo+OHqSan0Fi44c1vYNqs6WDAhaylvbXorgGjIZ/88mCCgAuUojJp
	TXFNxTUgJAaXGrJmQB0YCrS1daEaoxRyyps+xExB7BTE9BMV+nFaQE1EGpq0dcDV115ET387
	lWqgXs8wRohtjWrtwN5tR3q/zO881VxifNbdj6td9jXdNwP9ePM9+j2GQg5AMCCtxBp9Uonu
	lY7Lv6/8wfzas8/X7tq146WdLquQpBUmaqPUshrlni5ufMsvMTA0BRMbPA5PwBNQPIrPs5cT
	1CkSDOMjExhVQtMQ0QauBKFEcAW8E5pJLmMpBYIWUWkD7UHobe39DpyPMVEBiYRim/KaVcuZ
	O7+PWt3RTBQfIjQkuHCSb9yz/YPH31bcxX2L9I73tSUdu6Q5/7N/E924pcdMWTbOp3hSDbN/
	mgFx2euSRz8afeiOHdo38RCS3rr1Rw9t/NCJ44dPZK5OdXKcSnWcSr1C95Rebn77LcyaN5cg
	mrs0rcVrS6YxKnmwzJTjR0bZvfM4IViyBJpNIc0ivI9xQdi+8wijYxMoFiQmhJgQyqi25W2x
	nPYMU4qlwLVvWM6CJQNMVJtUJqu4NBAZi5CyYcPkXYd0xWMf/MBy85ob/j50faEa9tx1WyhO
	wZ7XMxFNG9kPL8555TnBu19AvvKNvsJT9/9OeXD0xfe989Y3f7StPA2xnZTbeujsmoIt9JM1
	mvzk0UfZsmkTxkGsMXiLhAJqOhFbwGPI1DFlRh+vueYips3KmxUTBB8CO3cf5PHH19NoCEa6
	MXShtodg+4ltLxoi8A4xo0wbSrjqyml09Ai11FOv1AjNAprEFEzKU+ue/+Lqje1/dv69Xx/9
	41WfDDefNRV2elbw9KTYz50UnX33BdH+bX9luXdbz6Vz9n/k0pUXvqdYHKBY6qVY6qHYMZW2
	UhuRGHa9tJO1jz7BiSPHKRdKECJcGqEUMXE7XiO8KOXOEjNmDzM4NJXg4ejRwxw4fAgxEUGL
	WNuNoR2J23EaoViKxSJR5Dj/vD6WL2+nXPBUaxmVyYi0rtigFOIqT67b/JUHHvcf41f8EZZ/
	OeED337FUVn78wCYOPZ+S60fbrg2ObRh40ZT2z8wdaDzvMgWcS4jCw0gEEdl+voGWbZ8KcWO
	Do6MHmUyqeRmZqFACAahgIaIrCFMjDbYv+sQh/cfZXK8hpUY7wQrhZbwKYAniqsUy1XmLypz
	1TXTmTO/BKrUqnVqlUBWL1E0Eap1ntq46RsP7Tn+iSV/fffh7s67w/i3lnsOPaP/6wAMv0Oo
	jhXxe7TnE4+G0DyY7NvYtrZ68JDr6yqd01YutXlN8U5JmiCmjNgi02bPYNmKC5gydQo+C4xP
	TOTavDFEhlxUCWk+O2Q8xobWIIYH68BkxCXo6yuwfOl0rnrdQhaf009cgGY9pV7xJFWLpmUs
	oH6C9Zt2fuGhF6t/ufA/f2f/e5Z8345/t2oOrH7GhfCLjsuryvk8xt9xVVTByG8+9lU98I7p
	bVPDt299002v+ov+4WlD1vYi9BPHUxHbTqm9RFQwFGMoBKhMNDh88BhHD48wOjrCxPg49fpk
	3sNbg4oSl2LautqZOjzI0PRBhoanM9DbSSSQOmj6jDTLaNYCZGVcw2LxZP7E+MbN277845P9
	d3Fv+SQy7Gd+8Onwqa/v4JZf/YbK19b+m+Zw72EAAAOqSURBVB2YsACf/96t4Y633lJoLw1y
	MPnSxZddPfTvX335RW+KogHSrB1ju7FxO1FcpFAsUY6LRFHrwIRAZFuj8MGTprn7GxcscdFi
	TF40+pauF7yQ1iF1gTR1eK8Ep0RqwcFkZXTf1+958YPHrpj7yE1/97ZkUdch98zNL7rP3NMv
	S0H51euDfO3B/3UAzjoqc3rGVu/hIaNcK2t5RCYilS+VVk/pK+186y23XP0fBgZmzrS2H+gk
	aBljO5CoE2MNcWyJY8FElhAEaw1RJLS0DNSd1qaUpJnhfO49em9QLeRuT8iITJ169fjxF549
	/p0f/6T8ufQjC3ax+Ju865LP+ebfP2//YsEqt/RTtyprbwTGg7D8FwYgAoIIfjdVcw8nzWHu
	567bP6339B237/3izVI/mdgqhxZcc/VFv3HOknN+ZaB/9hChC08XmelCbIy1MWJiVCMgQtUS
	yCfIck3ftHR9sEiLJVkuu2t+iqLRqI4///yhe1c/fPiLzF24+R/++QpNS8eKn336Tyojv/Tv
	5HMf+Jhe//G/KROAu69u8v6H3Rmt4xc5MPGvHTxSPXOQShkZCOdOeb89yDPzpgyXX//66y5+
	9+x5i1ckOgSUEMoIHXhfAi0jxBgDasLLOp/mdpo1knfQxqEyyujY2L79h2r3/PDhye+y/KqX
	hj/0o+ptbbeZ31gyrp0D+GlnHYo4c2hqzSqVK9f8YucG/2diAxA+9q67dPXXboxTXorHOdZ+
	mLWLF1x0xasXLWpf1dvTvXDa0NT5RjoIodQCxbZWra0xuDwbJEmaHDiYPhUXohNrnnLf3Dk2
	/xlWlsa5loTybs9XPqP7//ip8IUP9ZqPPP2Q/992cvR/AgQBzBNPwK+9/dV62eEfsY9Ou6fn
	oBy9ZQ48Q5ED9/VQWzcN39Z93vJFcy67ZHiFd6YYspItFOLmgcOj+3/y5PYtk37sBL3zxzjn
	+lF+O9QY3BYwXueH1bKUh+jdf9h9+Pe/E7Yev8xeBaET+T8LwNlMWL8J89UfEHV14/e/ODds
	357IedfNY/GiOKx7uFt/EH8NLm8XnsbQi+EliFcT6ILsApSVMPPan/Dm8z9gu/2zdl4JLVYw
	E3uJLlmM722i+36AH/zI72bF3X9rZ4Ar/t8EQAr2BJhe0HYIOKCCYTxvDifbCfXphD0s0z/l
	Zm6cXMPUk5np6ttFX3RcukqY9ggT5dKoCPgZnFXIJMBGlI/ODTz4ILBI5RXt6f9//dzrvwFe
	UwHJZtwqagAAAABJRU5ErkJggg==
}]

} ;# namespace 64x64
} ;# namespace icon
} ;# namespace dialog

# vi:set ts=3 sw=3:
