# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2008-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
if {[catch { package require tkpng }]} { package require Img }
package provide progressbar 1.0

namespace eval dialog {

proc progressBar {path args} {
	return [progressbar::open $path {*}$args]
}

namespace export progressBar

namespace eval progressbar {
namespace eval mc {

set Interrupt "Stop"

}

namespace export open

variable ticks 300

variable Priv


proc busyCursor {w state} {
	if {$state eq "on"} {
		$w configure -cursor watch
	} else {
		catch { $w configure -cursor {} }
	}
}


proc open {w args} {
	variable icon::48x48::hourGlass
	variable icon::16x16::stop
	variable Priv
	variable ticks

	array set opts {
		-title			""
		-message			"Busy..."
		-information	""
		-maximum			0
		-interrupt		0
		-topmost			0
		-close			1
		-transient		1
		-class			Dialog
		-mode				determinate
		-variable		{}
		-command			{}
		-parent			{}
	}
	array set opts $args

	tk::toplevel $w -relief solid -class $opts(-class)
	set parent $opts(-parent)
	if {[llength $parent] == 0} {
		set parent [winfo parent $w]
	}
	set Priv(interrupted:$w) 0
	set Priv(interruptable:$w) $opts(-interrupt)
	setTitle $w $opts(-title)
	wm iconname $w ""
	wm resizable $w false false
	wm protocol $w WM_DELETE_WINDOW {#}
	if {[string length $parent]} {
		if {$opts(-transient)} { wm transient $w $parent }
		wm group $w $parent
	} else {
		if {$opts(-transient)} { wm transient $w [winfo toplevel $parent] }
		wm group $w [winfo toplevel $parent]
	}
	wm attributes $w -topmost $opts(-topmost)
	catch { wm attributes $dlg -type dialog }
	
	tk::label $w.l \
		-image $hourGlass \
		-text $opts(-message) \
		-compound left \
		-wraplength [expr {$ticks - 50}] \
		-justify left \
		;

	set options {}
	if {[llength $opts(-variable)]} { lappend options -variable $opts(-variable) }
	if {$opts(-mode) eq "determinate"} { lappend options -maximum $opts(-maximum) }
	ttk::progressbar $w.p \
		-orient horizontal \
		-mode $opts(-mode) \
		-length $ticks \
		{*}$options \
		;
	
	tk::label $w.m -text " "

	if {$opts(-interrupt)} {
		variable icon::16x16::stop
		ttk::button $w.i -text $mc::Interrupt -command [namespace code [list interrupt $w]] -takefocus 0
		if {[info exists stop]} {
			$w.i configure -image $stop -compound left
		}
		bind $w.i <ButtonRelease-1> [list after idle [list $w.i state pressed]]
	}

	grid $w.l -row 1 -column 1 -sticky we
	grid $w.p -row 3 -column 1 -sticky we
	grid $w.m -row 5 -column 1 -sticky w

	grid rowconfigure $w {0} -minsize 10
	grid rowconfigure $w {2} -minsize 15
	grid rowconfigure $w {4} -minsize 5
	grid rowconfigure $w {6} -minsize 10

	grid columnconfigure $w {0 2} -minsize 10

	if {$opts(-interrupt)} {
		grid $w.i -row 7 -column 1 ;# -sticky we
		grid rowconfigure $w {8} -minsize 10
	}

	if {[string length $opts(-information)]} {
		setInformation $w $opts(-information)
	}

	bind $w.l <Destroy> [namespace code [list Cleanup $w]]
	wm withdraw $w
	update idletasks

	set rw [winfo reqwidth $w]
	set rh [winfo reqheight $w]
	set sw [winfo workareawidth  $parent]
	set sh [winfo workareaheight $parent]
	if {$parent eq "."} {
		set x0 [expr {($sw - $rw)/2 - [winfo vrootx $parent]}]
		set y0 [expr {($sh - $rh)/2 - [winfo vrooty $parent]}]
	} else {
		set x0 [expr {[winfo rootx $parent] + ([winfo width  $parent] - $rw)/2}]
		set y0 [expr {[winfo rooty $parent] + ([winfo height $parent] - $rh)/2}]
	}
	set x "+$x0"
	set y "+$y0"
	if {$::tcl_platform(platform) ne "win32"} {
		if {$x0 + $rw > $sw}	{ set x "-0"; set x0 [expr {$sw - $rw}] }
		if {$x0 < 0}			{ set x "+0" }
		if {$y0 + $rh > $sh}	{ set y "-0"; set y0 [expr {$sh - $rh}] }
		if {$y0 < 0}			{ set y "+0" }
	}
	wm geometry $w ${x}${y}
	wm deiconify $w
	if {[tk windowingsystem] == "x11"} {
		# prevent error 'window ".progress" was deleted before its visibility changed'
		catch { tkwait visibility $w }
		if {![winfo exists $w]} { return }
	}
	if {[llength $opts(-command)]} { busyCursor $w on }
	if {[llength $opts(-command)] == 0} { return }
	after idle [namespace code [list Start $w $opts(-command) $opts(-close)]]
	focus -force $w
	ttk::grabWindow $w
	tkwait window $w
	ttk::releaseGrab $w
	if {[llength $opts(-command)]} { busyCursor $w off }
	update idletasks
}


proc maximum {w} {
	return [$w.p cget -maximum]
}


proc ticks {} {
	return [set [namespace current]::ticks]
}


proc tick {w {amount 1}} {
	$w.p step $amount
}


proc interruptable? {w} {
	return [set [namespace current]::Priv(interruptable:$w)]
}


proc interrupted? {w} {
	variable Priv
	return ![info exists Priv(interrupted:$w)] || $Priv(interrupted:$w)
}


proc interrupt {w} {
	variable Priv

	if {$Priv(interruptable:$w)} {
		set Priv(interrupted:$w) 1
		event generate $w <<Stop>>
	}
}


proc setInformation {w msg} {
#	if {[string length $msg]} { grid $w.m } else { grid remove $w.m }
	$w.m configure -text $msg
}


proc setMessage {w msg} {
	$w.l configure -text $msg
}


proc setTitle {w title} {
	set t [tk appname]
	if {[llength $title]} { append t " - $title" }
   wm title $w $t
}


proc setMaximum {w maximum} {
	$w.p configure -value 0
	$w.p configure -maximum $maximum
}


proc Start {w command close} {
	{*}$command
	if {$close} { destroy $w }
}


proc Cleanup {w} {
	unset [namespace current]::Priv(interrupted:$w)
}


namespace eval icon {
namespace eval 16x16 {

# user may overwrite
# set stop [image create photo -data {}]

};# namespace 16x16
namespace eval 48x48 {

set hourGlass [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAMwElEQVRo3s2aWZBc1XnH/+fc
	rfv2vsyi2bUvI8UYoZWSLAnJyCAUYkRIqYxcCU6Zil2pPKScqqSSClUJUbmcqgApC+M4TmQn
	ARLLrIIYERASAm1oR0L7zGhmumd6er2373aWPIykkoQUeJjpynnp7tPV3z2/823/c6oJvsTY
	t/t9A4DRYhoxRVFilNIICAwCoklIQAJCCC6FdKQUjhTSKnhBhUvpMSm9latWS0zSILdOpDQ1
	PS+bWD+jLbtsekfLnI6O1p7urrZ0tqM1Hk8nVUVVAQCcMfieD9eyUa9aqBUrqBSKqIwWUc4X
	UBopcMf1rWogijbj/QWPnc17/sG867+V94IrkwJglcv0h/cvPTWlq21OoimNeCYFMxGHHjFh
	REwICbiOBx4ECHwfzAvguy68ugPXqsOxbDjVGuxyFXaxAsfz4XHA4xIul3A5oBBY20+fmWIm
	ktZEAKg3fqAE1NDUpO34GOvLo/JpP2qWC9f1ITiHYAyCC+gRE5nObiSbW6GFQmCBCrsYoNg/
	CF4eA4UEkfL67kTDOqKKgpFKHS6XUQDKRHngJgAmJc/X6idbw2ZLLJMmtWIFgeeDBQxScESa
	WtG75j7MXfhVZNIpFMeqYEJCCAIJgHOJfN9lnP3gHVQ/OwYiJXSVYt2mdSgNj2L3ewfBPX5B
	SPiTlgMKgbJpZsc//u6GVU8e2XcUHiUXm2ZMG526bPXc6YuXh6NmWAlqNRp4HgpjFUQTcQgO
	cC7AGIeQVHBB2OXjR/z9L/1swK8W+1tSibV111cC+Me2n80t9oT0J8UDAMAl+Ilc8ZXZB09+
	13YdufvK6JPf/dOtUxeuX78xrtMkiBwaPHJ4uRfY7fFMJt/2lcUfcAFwAUgoXECRPoPRuvg+
	JbrsG5f+asuGXz69evFit2qlXv3vD09O5OJvCwAAXZn4PUtWLyaH3ttPNvzOqieXrVlHQhrN
	egKDKoSAZzeFdA2FYikDgCiaHggGXnFRHqujMmbDtn3EebI3+Nb3nnri/K5nU+WKhYSprZzo
	MkpvN5kr1U69+dLbbHisKBZ8/cFsyNDSTMAWgKcq1AwlMrVy1UYi25QTimblHVw8XcKh82Wc
	GbYwXPVQDQTKQiLasvqxy0PhjkNGRMe5sv1UQwCOlu1XZi79ypHp3Z1B2/K1eYUizCRsBYjG
	CFk7Y15v+q4lS+ApofN9NvlkzMMwE2A3GZFwqQBVFCN870MbrVmzp6PsMbchAAAwo7OlmQiu
	UyEMAERK+BpBEyEIgRBixuKoVSpUAuIOJrjCIRWOkKmTKABkda2pYQChiJkRQhCvPKZfq1gc
	sCEhCYC6VYM1mo/+XxVO4ZBUgqm8Hhl3CrITDaDe6QsjHIpKCTiFfERM69TAedTyWIkheEtz
	7MWXTn7S5NnVeGCXkiwAuA/wABABIH0AnKjUV2NM4UwNrDgARFUl3TAAPWQAkMgd37si2xJG
	CC683FHEQz6iYQVtCYbsnGCGf+75v/GdAL7LUHElSg7gOhIOj8FCEhVnBJ0xZ9wmpY0D0PTx
	yCkPDwa+Y2shQwLCg65S6BqgSDIuCBQAioSkAioBFAJQAqgkBMe3YFu1MYSlASAqpEw2LAeo
	Oi5XDr236z/KI4PCr9cQjny5DVRJBFQS+KyK/QeOP2MoRABAUlMTDQO4Ns6d7T/58k+3/biU
	60M41gyiaF9gUIeKMDxewaWB3MeH9+3ZpqhqGAAIIY0HCCk09l87P/zBrp07P3CsIszUdBCi
	3kFYqVBkBExayJdKg7/61eubHa9eUBSqAYCQiDccQEjEbDdwXvi3dx5+Y8cr+6kagxbtBMgt
	OlDqINIEg43B4tjQP/3LyxtqY8OXAIDQ8cdIiWjDkvgGcRcDgGLNLT31zI51rmP//A+f2PCI
	psUAeFcpDRBJIYiNoxdyx579+eubyoXh89c9cxVAuZPrJhMgoamRa+/rHqtt3fbW5qYgGFj7
	2NeaQ7oOSAWQBJxY+PXe8689/8vXt/j1WuWm0LrqLTGBB5kvDKGD7/4GTFrIplV+47zDhH/6
	wKnjv962A4VCGSAcnNTlM6+e2vbcz/5z062LB4CLp47DqpWQTqmNA9C0kEepyk7krBduOfCo
	HT2zjFlTe7HrxffBhcTOw6Mf/uLF174veRDcztbxw8fOl4o5WJy92jAA00waVlWqKUPbdHON
	J4Y1mFt48P3DOPNZiY1aupXTZ70teXAnUYeV6+6f2tE1B35NztUIURoCsOfd/aLq2LAZ333j
	vCekjWzmjVh7C5Y88nsjqhF2vvaNh+KLHtyy9E62/ueVXfSjvUdhmkpEIZ8/xk4KwMOPP0RX
	rFqK+e0t624SeZQo03q6Vsy5/7fR3TO1zQglsy3JWNtf/8MLK9Zs+bPVoNrndnjOogUjC+6e
	hXg2e84VkjWmD0hg8OIAaqXaTfqh++4VM7q//k1t3qIlUMMxROMZmTW1ttlZY+nTf/f0xs1/
	8fzDVI+Eb/xNJh1vSSYTSBnGqoblQKa9Fb7rYdByr19ALXngsUU733nzj3tmz9IJpSAEklDK
	FIqAUoh0iPb84Ht/8MCfPPfGZj3WdF24tfZ0gnkBTp8d4A3vxJSgBgB33ffIwu3b//mJVCya
	pYSyq/VdEEr51eoUUApmKMg+vnHVyj/64UuPqGYqcu3yhlACCkw4wBc2MoWg1jRtQee2n/5k
	SyJqpikBI4oSAAClVAKCl11WcBguVD24tgstG0Lvow+uXjHY//flA899/6gU43e7HDJQCAiX
	kA0DEIru/OWPtm3ubM5MIQSCAKCqGgS+hyuX+wIzpFoFtXeQmRjxAkBIaPOasIYC5qbN3744
	ePAdSwpxzRH2RC7+S4XQtHsfmL5hzfL5QoJSAqEAqWQqm6gWC6jXai4Iuan+MwFmBzg7ZmHA
	9aiy9ok/n8O5uBZmlYaFkOTj61p//9p2ClKhBAKApEAmHEtEY8ksFMOo33o9KSTke5fxouKj
	STKYbR1Tq6KgBAAUX4hKw5I48MdVQXNbqyYlFEogKgz9RYn3S+XiQLU0Cs2MOrdVsAIikLA0
	BkOFqnOq+gBgMW41DMB3XQAE4XiCEQniCdQqDIN1ib6+/PDBwPegGiH7Tk1EQjIlEAqYDHFq
	XNXdsBsWQr7ruYQgZMQSrgKECgGGoY4noKRKHQDUsGkDTtP1RUtACE4Cz1eY7RmGRcKOtGM+
	E/64DBGjDQNwrXqBAO3cTJYyYTzgBRitAHkAoEa4JoWEQrmuCDcinErKV9KDVtXWyuWaYdUc
	XQ1oOEHShMYMi2tRCwAcLvINA+gfzBc5Y4mPPjl5YUrzmv1jdVxQ4+M7bQ1cmk9kBXOz1j06
	CUCHd/z+GTZ376jsOhBIzVfUiJ/V08yksaKbpMXRE1ZZG/dRtSE5sKwt862ZM7t7iapG9v3i
	J+aoyz7zHekILog1eH5uip28d3aPj2j4msDj6mx+ZNVMe+/j2Zgea27qstJ6Cp6pFI8d2VM7
	c2D3CQAY89mEV6HbavPukL4uGBpZPzRaxOW+M28eGvM/nTWnp4f27Xm02T38UDZFqeQSnHFw
	Jq6/EubEUDi9KKiRWEXo+TO5M96Op7/Tt3FB+3eoH2SG+nOXzlnO25MO0JOMtm9Yt/xRXqtJ
	qRtWlxhbxUqnvjmtXemMR1SiaxSSi88BuIzAZxp1a/1dfec/7v3035/pnukVlreaxvzhwRGw
	wO8+WrSevdo75KQAbPitGd/eeNfsHw1dvBIfGi2T1og+N6h7XUdPnNNOnR9AS2sCbS1xSHGr
	BwCXEeQrDnZ9dBKHPtxnpAzSNK2taYpgHI7vgTkeiER8yPV/M1EeuKmL1itl5fC/bh240p+b
	sv/dfWB1GzyQYAQYkQR5QVAjCqa0p/DV3k60tyRhGhpqto+hfBUnLxVw9nIOEAKZkIaeVBSz
	Ihrm9LShMDyCT8/2oeoT+XLfFTpZVYjoIYPMXdgLQggun7mAykgRgesgwjjSXKDEJarDRewd
	LsHHVX0BAkoJFELQEVKRMFQ0Rwx0xkzEVYKP93wCTzCAEHg+I5NZRiWklOmmNO5ZuRDz7p6L
	WrGC6lgZ9WoNVqUGv+6gbjuo+z68gINxgYBxECkAIUA4h8I5hF2DValgxGOo+wwuE3A5ACnl
	pCXx327dKocuDeTaktF58Vg0TSklhFLougrDDMGMmAhHTURiUcSiJmJmCFFDQ0SlMCChcgZ4
	PoK6A8/z4fkMPuNgYlzkCYixy/X6iznPf21ScuCG5kA6o+HZM9ubF81ob5qfTcZnNkXNTl1V
	mk2VxiBEiAdM5UGg+a4//n8Jx+Oe47K64wZW3XXtgFdLPiuUAz5U8tnFEc8/lnOD7bf0IIEG
	DgX/D8f/AoH8nepNaDRfAAAAAElFTkSuQmCC
}]

} ;# namespace 48x48
} ;# namespace icon
} ;# namespace progressbar
} ;# namespace dialog

# vi:set ts=3 sw=3:
