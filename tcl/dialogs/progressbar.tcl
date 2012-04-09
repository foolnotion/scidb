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
package provide progressbar 1.0

namespace eval dialog {

proc progressBar {args} {
	return [progressbar::open {*}$args]
}

namespace export progressBar

namespace eval progressbar {

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


proc open {args} {
	variable HourGlass
	variable Priv
	variable ticks

	array set opts {
		-title		""
		-message		"Busy..."
		-maximum		0
		-interrupt	0
		-topmost		0
		-close		1
		-class		Dialog
		-mode			determinate
		-variable	{}
		-command		{}
		-parent		{}
	}
	array set opts [lrange $args 1 end]

	set w [lindex $args 0]
	tk::toplevel $w -relief solid -class $opts(-class)
	set parent $opts(-parent)
	if {[llength $parent] == 0} {
		set parent [winfo parent $w]
	}
	set title [tk appname]
	set Priv(interrupted:$w) 0
	if {[llength $opts(-title)]} { append title " - $opts(-title)" }
   wm title $w $title
	wm iconname $w ""
	wm resizable $w false false
	wm protocol $w WM_DELETE_WINDOW {}
	if {[string length $parent]} {
		wm transient $w $parent
		wm group $w $parent
	} else {
		wm transient $w [winfo toplevel $parent]
		wm group $w [winfo toplevel $parent]
	}
	wm attributes $w -topmost $opts(-topmost)
	catch { wm attributes $dlg -type dialog }
	
	tk::label $w.l \
		-image $HourGlass \
		-text $opts(-message) \
		-compound left \
		-wraplength [expr {$ticks - 50}] \
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

	grid $w.l -row 1 -column 1 -sticky we
	grid $w.p -row 3 -column 1 -sticky we
	grid $w.m -row 5 -column 1 -sticky w

	grid rowconfigure $w {0} -minsize 10
	grid rowconfigure $w {2} -minsize 15
	grid rowconfigure $w {4} -minsize 5
	grid rowconfigure $w {6} -minsize 10

	grid columnconfigure $w {0 2} -minsize 10
#	grid remove $w.m

	bind $w.l <Destroy> [namespace code [list Cleanup $w]]
	wm withdraw $w
	update idletasks

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


proc ticks {} {
	return [set [namespace current]::ticks]
}


proc tick {w {amount 1}} {
	$w.p step $amount
}


proc interrupted? {w} {
	return [set [namespace current]::Priv(interrupted:$w)]
}


proc interrupt {w} {
	set [namespace current]::Priv(interrupted:$w) 1
}


proc setMessage {w msg} {
#	if {[string length $msg]} { grid $w.m } else { grid remove $w.m }
	$w.m configure -text $msg
}


proc setMaximum {w maximum} {
	$w.p configure -value 0
	$w.p configure -maximum $maximum
}


proc Start {w command close} {
	$command
	if {$close} { destroy $w }
}


proc Cleanup {w} {
	unset [namespace current]::Priv(interrupted:$w)
}


if {[catch { package require tkpng }] && [catch { package require Img }]} {
	# 32x32
	set HourGlass [image create photo -data {
		R0lGODlhIAAgALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A
		/wD//////yH5BAEAAAsALAAAAAAgACAAAASAcMlJq7046827/2AYBmRpkoC4BMlzvEkspypg
		3zitIsfjvgcEQifi+X7BoUpi9AGFxFATCV0ueMEDQFu1GrdbpZXZC0e9LvF4gkifl8aX2tt7
		bIPvz/Q5l9btcn0gTWBJeR1GbWBdO0EPPIuHHDmUSyxIMjM1lJVrnp+goaIfEQAAOw==
	}]
} else {
	# 48x48
	set HourGlass [image create photo -data {
		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
		DgX/D8f/AoH8nepNaDRfAAAAAElFTkSuQmCC
	}]
#	set HourGlass [image create photo -data {
#		iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAR4ElEQVRo3tWaaXQc1ZXHf++9
#		qt6kbrXUkizbkrwg78EL3rAhgNmdBEzCQEiGLORkgJlzsjKTcE6YM0km8yEJw5xkMmSBZAZm
#		SMJOnARIWAyx2YxtHMurLEuWLMnapVa796r35kOVWi1jQ7b5MHVOqaq6utT/e+//3vt/75Uw
#		xvD/eRN//bFbznpTa83ShQvo7R9gbDzJhevW8Mqu3Vy9cQNP73iFJXObWZOo5ce79hAOBK5a
#		WFd7ZXO0cn1DMLCsMpePW66LLhbICZk5kZo4sG9waMfzRw4/t3/f75954JpreKa/nycOHeLu
#		Szbxjzu289m16/jGSy9y0fxzePnIYaSUIAQCcF33jBitP8VqrTUFV1fktfmbnDEf+ZfVK9c1
#		5HMUBgbIHO4mOzZGPpchlyvi5nOQz0eapFi7MBxee0tt4gupLVs4aMyeIvysoPWPtDETfyoP
#		/ggDjAfccZqyjvNv//HRD18/q+s4hd4e8pksectCxGJUxKsQuTyFfIFKN4dyCti5IiLjkB4d
#		YrC/n9HWViqKxfNujcfPu+uSTd9+FrG1YMzntTGdf3EDDGCMoVB0yOTzP/jhl++4rXZwCE50
#		gYH8kqV0Oy4TlVFSMkCuIoadSBCLxbHSbejUUVyngJvKEkwWmTnu0NR2An20l2NHD7Pnhec4
#		Jxy+9vW1a699EH5sjLlNG+P+xXJgUcs5dHSdWPPZv7vtV6sXtczgRC+k0wxPJOlwBEMiQLh+
#		FrYlCQcsIgFJwJIEAzY/ffJRbn7POI5WIEBLicFgrEpOjWQIH01S/O1OBg4fo72zg4ZEDbHV
#		a/J3HDt24572o1sRAinlO+aAWr5i1Zk9bwyO1kRjsa/c8+U7ft7U3FhJMMhEPsebA2McC9Wg
#		q+pI1FVTFwtRGw0SCUoCSiKlIGBJ7vrhU9y8PoarwQiBMCAMKF0kFBJYjRHEpSsJNjWxhBAn
#		unvp2t9q3Tpn7kdS8+fb+090v2iEQArB2arlGQ0wxlB0Xc5btvT7X9181Zes4WGoitHWN8Ce
#		E6PoygRhWzK3IUYsYqMUaG0w2qCNQaOxpOLR53Zw07pKXC3wfl4AwqelQGHI5/JE51aSWfce
#		Gu0YsdEsbx5s5UORyEXRVatbXj/W/iRCwFkMkGcErzWbVp77yJ1Ns27nzTfBstl5uIOjw3li
#		sTjNdRXc9d0fkDqVRhvQrsEYH7w24HoJj5CM50IYUU5a748UMJEzfOGREQp5TSSQQ358PVV3
#		3Mh7zzuPXUeO8L6DB27+2uVX/tJofVaaT4uAAQK2zdLG2d/4Yrzqdud4F3LJIn6X0yRjM6mJ
#		hphVW0FFKEBNVZRnXtnJxpVLcbUH2GDAGLTxQEaKJ2mMG4LKwfjen7TCkoKf7kyzYX6IhfU2
#		GsB1CDRG0YsXs+hEkp1HDrMqk17YuOGCFTs6jj38rhEwxlDQeultsxu+Mt7WBvPn8VJRkJkx
#		l0RlkIbqCFJCoeiwad0K2rtO0j88hjYaY6YoZIzGMRrbEhiDB64MPAKSWU1rn8MVS8M4BrQW
#		YEAXXcItFWQ/tZlNy1dyoL+f60/2fXDNgkUff8cI+OCtvz9/7cHo7j3h8Ny57Ew0kDnnXKoj
#		AWbUhBHCo4hGg4HzlrYQqwwjfZCTieYdBV3Hj9AYg6ByMUaU6CMAJSWrmwNEgqoUscmui4Fg
#		UzXFRC0zOoZ54/BBblqx4qr/Ptl3P66bnhYBJUD5T12yoOU/G1v31ZhgkMPVCVILVxALKWZU
#		hxAYjyq+p4uOQ6IqhpIC1/gU8o9eFEyJluUJYPCMlQISlQpHGy+py3dtoFAgfPEC4tddzNza
#		OkbfeCNy13svvv+MFDJAEeZuCQduHunqxm2YQc/CVUQDFjOqIx5I7YEq37V20Zqp68l7vqGT
#		tPGAeXTC97Y+7br87+RTMp/FXLeO5etXM5xJc30uf00skdg4zQDXrzrXLlxwb3L7DkK1Cdob
#		5xOuivPCq69zqKMTpRRSCE9OlINlusfLc8AY47tnKnmFEAgh/aNHGfxzIWSpOtmW5Oigy9bf
#		ZwkH8iQ/uJFz553Dvjde5WvrNtxdnrtSG0PRmKYLc9nNycFBZEMD4/OWUhW2uGzdMn76qxe5
#		4+776B0cKcmKkhF6OvDJZJ68LzQlsELIaWBLRynBv5ZSki5K7v1dhsf25lk+O4B2DJHVc2hY
#		8x6SxSKbUskNFTVTUVCf2vw+ZsRidzbu2/teZduMr16LbllGQzxEfXUVV12whmDA4lBnF4vn
#		Npe4/ra9LIlBoJSip7ed2TEIWS4gS4BPN0JOHqXizeMFqisUn9pYQVVEYRAo46J1kPyew4wP
#		DRJYutR6q7v7KQD50PbtnF9RcctA21HiTY301M+hMqQIBSQF7ZArFNmwfAnXbboA96zgTany
#		eJ6c1DASKSRCKB+4AhRC+tfKPxfe0QAXtoS4dHEERwuvciHBCHJL6lm0YBF9IyN8cMbMLUAc
#		QAopZzYODTQUi0XGKiqJLVhMNGh5PHZBG43jujiue0bve3TxqCIFSF+7SClR0kJIhZSWNzjR
#		BYyTwc2ncAsp3HwKU8hidAEBSGmBtD3QQoJQXq4AlbPrCC9uRgGNI0NVoeqaNQBWfSh0Yabz
#		OHY4RK6xCQGEAwqjvUpgDH6H5QzgKUtO3/M+NbQ2DI8OkAyeQqgRXO1MVRgh3i7aDQhpIe0w
#		VjBGIBRHhaK+4jfgFsjOn01dfQMT/f2sapi18bWx0eetZQ0zVw3s2UlNYyNd2NQFbSxLnuZt
#		zwiP51PnQoDE47XBGzM4rsZ1NQHbZnh0GDfhQsR43j2tYJ7WIgCNLqTJF06RT/WBARWMYoer
#		CVXNpNgQZcbsRgZOdLFmxYoVrx3ar+SypsaWkd4+lGVRiNcQsmRJ/E1qm2k13mjvnjFIKXGN
#		SyqTJpk6RTaXR7suSkmUUijlGSd9309VJM6y+98XyoukFOjiKfLjXYx3v0ZajRGvqyc1McHC
#		2ro5QMByRkbqZaGAdoqQSBC0JUpKpC1wtcQVDtoFv2N5fcevNqlTaRytUVJiKeWBltLnv6Rv
#		JIdoCRCwJK7xURrOFoNS1zZGI4UstRFtJK7WZMKCQEUFQgoqlawGAlYAU+E6LsZxUcEwpzIZ
#		fvjwkwghMVqz9Jw5XLFhlQ9cYLQmncvjOMVpgIuu5jev7kYphWVZPPvKbl56rY2Dx6PctLYC
#		V3uDmSnkonRaLjqMgTm1FntPFPnNgTRSeCrgi1fEWNKowLJQlo0lVQiwLdd1Hdd1/CbkUlMV
#		5fYbPuB3WI1tW2itEUA6nyWTzSF8D082HyEEoWCA9120jmQyQ8C2MePt7NkfZM2COSybE6Ey
#		kEMgMaU2KjDl9Megy1TxnESea5ZXgDBoF+IVkHUEMhTCsi0KShpAWK5tJ7XWaMfBTExgjKEy
#		HMQ1BuPLBG0MyXSGXC7nyQopy/jslU2BQCqL2toaAice4aaFXaQurWHj4kpmVY4RtjRGCKQX
#		yJIRnOZ9v/h5WspI/zMDRqOzBT8CFjkrkAaMNZDN9s4OBDBa457sLalFozUGcLUmmTpFoVj0
#		6FJW5+XktVIIaSNzJ7F6nkIUx3AsGyky1ESyRGyDQfo1XUxJpNMTQJQGnEiEBxzjU0+gnCDF
#		4jgVsRj7s5lBwLVae3oOrJg9i7HBISqSIxQcTVB5CecUHcZSE7jaRRhTJgM8/goh/K5qYw3v
#		wB7chhE2SAuD4PIllWgjPK2DX338AY04LQJGeDkyqVw9I5hyqADbqSCdmqC6sYkD/Sc7gYLc
#		2dn51qy58+jr6CCRGifvuAgEjuuSTKW8ZmUEnEYbISalgcHuehh74CWMDHiywAfcWGOTCBd8
#		lelTTUw2O+lLjkk9JEv3Jr8nZBlFpUVQx8gMDZKYN483j3UcBhzZ0d21Tc+bT94YzL5W0qcm
#		cI1Hm8mSKfyaL2UZeGmh8gOE2+9Fpo9hlO3lgaAklYUQBC3jPTcJVIoy4OXaSaCkQCpvV3KS
#		ql7kXKua4HgeN5VkYnYjXd3HXweKEsdhr21vCwLi1ASjv32WsVO5UmJZUoKU9JwcQkjlaRRp
#		Y03sI3j8AXCyJS0/CbzkQaYnupTlUZj09pTHlVT0jDlk8xCwfIchEEqgRyXORJpINMbLqdQB
#		jOkDtAR4YPfuB5etWUPbnreYcawNB4/vAdtix96DbPn813lh516kVCAUwZO/JND3a4+rk3p+
#		UlqUOu2UEdMNkmfoyFOReLMzy5p/bueX+1KELYWyvM8DqpnMoYPUr13Lz363/XlgFEDats32
#		3bv+S69dl8tqTfDIYUb3voWyLO64+z6eeH4H3/mH27n1xi2I3AAVnT/CTraCtDy+MyXoyqMw
#		zYhpnGZaLkxxX2AwfPT8al780nwe3zXBlu91YQnIu7UERxxUKsnx5jnFXXt3/wIYA1CWZaGB
#		sUiF+4FI5PK2vXuZVVeH3LCRy9Yu5+oL1hCPV6PG9hLueRRhij74sspS8mBZIpYnYClxpxs1
#		OdosXePV/3jE4vrVMW5YG8OVNjrVgmptp7K5mTu2bXuoo7PjKWDEH9RLLKl48uWXvxXYdGk+
#		pzVy1y4GX38dV0jyLtiD2wj1P42ZzIEzzRJPzZqURsGC8jHvdKBn/h/eU1obii64RpNOJUgE
#		G7B6ezkyd77z3AvP/w8wUBpSuq6D1i5gzN5Mpu1vV668Yf+O7bRIyCydT9XoVgKpQ6ACCFQJ
#		iJICy/KaGaY8WeW0ilMehfIeovyq8/apl9LcOFknQaLqQtTzz2MvP5frv/udbw4PDT0HDJ1x
#		Zu6tA/sfeSwef7i+oYGu7TuI/uR+rzNKa1rrFAJsJfj61lE6hgrTBNpZfDv9roC+sQKfeaiH
#		gCWmjW98IpEzVVRXX0JF6yEioRDf7zu5+9DBA48BPe84ufvNxx/7ZHjz+8eHh4dI/r6d7OOd
#		mEgdyCk/SQG94y4vt+dYUG+fedbYN1KKM/t4Tm2QN45lONKfR5VbYDQFIkTjm0gkC4T6T9Jz
#		0cX807e/eQ/QATjvaABa52559pn3r//4Jzh2aD/p1w9SfPQERTeOkLpURT7382HuvCruT1iZ
#		8vUcBB74v7q3G1tNqc4pvQ+uNnzrwzP52I+6J6e9wLjkRJTK+s3U2dXQ1cnAlVdy0S2fvNPJ
#		518Fxt91eh2g72Tfq1tefHHzxk/fSlfbIY4/vQ37qV7SmVpQAtdo1s0LcvWyCI6rSxK4NOQ0
#		oBS8ciSNkmUap2zK0dGGy5fEuGZVlGzBBTSn7PnUzLqeRHgmJJMMrF/P8htv/FJvd9dWoOvs
#		5DzLNmvW7M1br7vu6QP334cVirDq6isYXFJN4oIEVm4Yoz25y7ROK1FKUBFUzPhcGyPfW0K2
#		YKb6w6QIxOuBUhqyRNF6EbPrz0U1zYFshuPHu836a6/58mD/yaeBI6dT5x0jUIpEX+8zFz74
#		4Lm5D9/UWjd7JtseeRT1zD70Q92MtloUVDVYAiGZGvz7R8eFmpjCLVv8wPhrCGi00KRNlOz4
#		PKrTK2lWTajKGAQCPP6LrT0tF2z4xGD/ySeBw2cD/64RKNtC11+86VtfnT3rM3sef4xsPs+K
#		Cy8hPm82E3PiOE2S2PxabGcEaYpIobCVxFIC7VMKIUAFKKo4hYE84XwtDTpGsKhBO9DYTCFa
#		ya333PP0A088fg/QCgy+6yrlH7MkG6+t2/yv133o26v7+xbtf/EF8oUCLatWM2PuPGRVGGdW
#		HfmwwQkU0JaLtBUSSUAGCYgYYR0mmteEZAg3lUQlJwhVxaClhZ/s39/xhX//7ncmxsdfA9qA
#		5B+0zPonLI5X1jfMvPrTGzZ+8rJwaHNld5fsaW8nm04Tq6klPnMWsfpawpUx7HDEo5c2GKeI
#		yecQjkM0kaB67lzabds80Nr60n3P/PoXI4NDO4Bev0n94evEf8Z7FmGgedGChdfdcN6ay86f
#		Ube62XVrouk0hfQpnEIBZVnYgQDhqioiNQmS0ShH8oXRbZ0d+5549dXXjhxt2+Y3pn6/RP7R
#		bxz8OQZMbgEgCsSRsj5cFV88v76+uSYSqbaktIvGuBPZ7KnOwYG+1MjIUV9FpnyKjAHZP+tt
#		lf+DN2As3yjrtCrneAtBFAH9l/qx/wXa48q9KFD+dwAAAABJRU5ErkJggg==
#	}]
}

} ;# namespace progressbar
} ;# namespace dialog

# vi:set ts=3 sw=3:
