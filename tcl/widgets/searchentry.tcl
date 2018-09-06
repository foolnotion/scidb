# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $HeadURL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2014-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source combo-search-box

package require Ttk
package require Tk 8.5
if {[catch { package require tkpng }]} { package require Img }
package require tooltip


proc searchentry {w args} {
	return [::searchentry::Build $w $w {*}$args]
}


if {![namespace exists mc]} {
	namespace eval mc {
		set Key(Ctrl)	"Ctrl"
		set Enabled		"Enabled"
		set Disabled	"Disabled"
	}
}


namespace eval searchentry {

namespace eval mc {
	set Erase					"Erase"
	set FindNext				"Find Next"
	set InteractiveSearch	"Interactive Search"
}


proc makeStateSpecificIcons {img} { return $img }


proc bindShortcuts {w} {
	bind $w <Control-F> [namespace code [list TriggerFindNext $w focus]]
	bind $w <Control-f> [namespace code [list TriggerFindNext $w focus]]
	bind $w <F3> [namespace code [list TriggerFindNext $w findnext]]
}


proc Build {w ns args} {
	array set opts {
		-type				pattern
		-text				{}
		-textvar			{}
		-textvariable	{}
		-ghosttext		{}
		-ghosttextvar	{}
		-ghostcolor		#444444
		-history			{}
		-length			10
		-values			{}
		-postcommand	{}
		-usehistory		{}
		-mode				{}
		-delay			150
		-minlength		4
		-skipfirst		0
		-width			0
		-helpinfo		{}
		-buttons			{}
		-parent			{}
		-takefocus		{}
	}
	array set opts $args

	if {$opts(-type) ni {pattern number}} {
		error "wrong type: should be one of {pattern number}"
	}
	if {[llength $opts(-mode)] == 0} {
		switch {$opts(-type)} {
			number	{ set opts(-mode) enter }
			pattern	{ set opts(-mode) key }
		}
	} elseif {$opts(-mode) ni {key enter}} {
		error "wrong mode: should be one of {key enter}"
	}
	if {[llength $opts(-usehistory)] == 0} {
		set opts(-usehistory) [expr {$opts(-type) ne "number"}]
	}
	if {[llength $opts(-buttons)] == 0} {
		set opts(-buttons) {erase enter}
		if {$opts(-type) eq "pattern"} { lappend opts(-buttons) mode }
	}
	if {"help" ni $opts(-buttons) && [string length $opts(-helpinfo)]} {
		lappend opts(-buttons) help
	}

	namespace eval [namespace current]::${w} {}
	variable ${w}::NS $ns

	namespace eval [namespace current]::${ns} {}
	variable ${ns}::Vars
	variable ${ns}::Priv

	if {[string length $opts(-textvar)] == 0} {
		set opts(-textvar) $opts(-textvariable)
	}
	if {[llength $opts(-ghosttextvar)] == 0} {
		set opts(-ghosttextvar) ::searchentry::${ns}::Vars(ghosttext)
	}
	foreach attr [array name opts] {
		set Vars([string range $attr 1 end]) $opts($attr)
	}
	if {[string length $Vars(ghosttext)]} {
		set $Vars(ghosttextvar) $Vars(ghosttext)
	}
	if {[string length $Vars(textvar)] == 0} {
		set Priv(text) $opts(-text)
		set Vars(textvar) [namespace current]::${ns}::Priv(text)
	}

	set helpcmd [namespace code [list Help $w.e]]
	set findnextcmd [namespace code [list FindNext $w.e]]
	set erasecmd [namespace code [list Clear $w.e]]
	set buttons $opts(-buttons)

	set Priv(current) 1
	set Priv(search) ""
	set Priv(after) {}
	set Priv(lock) 0
	set Priv(content) [set $Vars(textvar)]
	set Priv(empty) [expr {[string length $Priv(content)] == 0}]
	set Priv(findnextcmd) $findnextcmd
	set Priv(focus) ""

	ttk::frame $w -class TSearchEntry -borderwidth 0 -takefocus 0
	bind $w <Destroy> [list namespace delete [namespace current]::${w}]
	bind $w <FocusIn> [list focus $w.e]
	if {$opts(-usehistory)} {
		ttk::combobox $w.e \
			-class TTSearchBox \
			-postcommand [namespace code [list Post $w]] \
			-textvar [namespace current]::${ns}::Priv(content) \
			-takefocus $opts(-takefocus) \
			;
	} else {
		ttk::entry $w.e \
			-class TTSearchEntry \
			-textvar [namespace current]::${ns}::Priv(content) \
			-takefocus $opts(-takefocus) \
			;
	}
	bind $w.e <Escape> [namespace code [list Leave $w]]
	if {$opts(-width) > 0} {
		$w.e configure -width $opts(-width)
	}
	if {$opts(-type) eq "number"} {
		set vcmd { return [expr {%d == 0 || [string match {[0-9.,]*} [string trim "%P"]]}] }
		$w.e configure -validatecommand $vcmd -validate key -invalidcommand { bell }
	}

	grid $w.e -row 0 -column 0 -sticky nsew
	grid columnconfigure $w {0} -weight 1
	set col 0

	if {"erase" in $buttons} {
		ttk::button $w.c \
			-style icon.TButton \
			-image [makeStateSpecificIcons $icon::16x16::erase] \
			-command $erasecmd \
			;
		grid $w.c -row 0 -column [incr col] -sticky ns
	}
	if {"enter" in $buttons} {
		ttk::button $w.r \
			-style icon.TButton \
			-image [makeStateSpecificIcons $icon::16x16::enter] \
			-command $findnextcmd \
			;
		grid $w.r -row 0 -column [incr col] -sticky ns
	}
	if {"mode" in $buttons} {
		ttk::checkbutton $w.i \
			-style Toolbutton \
			-variable [namespace current]::${w}::Vars(mode) \
			-image $icon::16x16::character \
			-onvalue key \
			-offvalue enter \
			-command [namespace code [list SetupButtons $w]] \
			;
		grid $w.i -row 0 -column [incr col] -sticky ns
	}
	if {"help" in $buttons} {
		ttk::button $w.h \
			-style icon.TButton \
			-image [makeStateSpecificIcons $icon::16x16::help] \
			-command $helpcmd \
			;
		grid $w.h -row 0 -column [incr col] -sticky ns
	}

	FocusOut $w.e

	foreach sub {"" .e} {
		if {"help" in $buttons}  {
			bind ${w}${sub} <F1> $helpcmd
			bind ${w}${sub} <F1> {+ break }
		}
		if {"enter" in $buttons} {
			bind ${w}${sub} <F3> $findnextcmd
			bind ${w}${sub} <F3> {+ break }
		}
		bind ${w}${sub} <Control-Key-x> $erasecmd
		bind ${w}${sub} <Control-Key-X> $erasecmd
	}

	if {"enter" in $buttons && [llength $opts(-parent)]} {
		bind $opts(-parent) <F3> $findnextcmd
		bind $opts(-parent) <F3> {+ break }
	}

	ShowButtons $w
	LanguageChanged $w

	set args [list variable [namespace current]::${ns}::Priv(content) \
		write [namespace code [list ContentChanged $w]]]
	trace add {*}$args
	bind $w.e <Destroy> [list trace remove {*}$args]
	bind $w.e <<LanguageChanged>> [namespace code [list LanguageChanged $w]]

	catch { rename ::$w $w.__search__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		configure {
			if {[llength $args] % 2 == 1} {
				error "value for \"[lindex $args end]\" missing"
			}
			variable [set ${w}::NS]::Vars
			variable [set ${w}::NS]::Priv
			array set opts $args
			if {[info exists opts(-text)]} {
				set Vars(text) $opts(-text)
				FocusOut $w.e
				array unset opts -text
			}
			if {[info exists opts(-textvariable)]} {
				set opts(-textvar) $opts(-textvariable)
				array unset opts -textvariable
			}
			if {[info exists opts(-textvar)]} {
				set Vars(textvar) $opts(-textvar)
				FocusOut $w.e
				array unset opts -textvar
 			}
			if {[info exists opts(-text)]} {
				set $Vars(textvar) $opts(-text)
			}
			if {[info exists opts(-length)]} {
				set length $opts(-length)
				if {![string is integer $length] || $length <= 0} {
					error "bad arg: argument for 'length' should be integer > 0"
				}
				set valueVar $Vars(history)
				if {[string length $valueVar] == 0} { set valueVar Vars(values) }
				if {[llength [set $valueVar]] > $length} {
					set values [lrange $valueVar 0 [expr {$length - 1}]]
				}
				set Vars(length) $length
				array unset opts -length
			}
			foreach attr [array names Vars] {
				if {[info exists opts(-$attr)]} {
					set Vars($attr) $opts(-$attr)
					array unset opts -$attr
				}
			}
			ShowButtons $w
			SetupButtons $w
			LanguageChanged $w
			if {[array size opts] == 0} { return }
			set args [array get opts]
		}

		cget {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] cget <option>\""
			}
			set attr [lindex $args 0]
			if {[info exists Vars($attr)]} { return $Vars($attr) }
		}

		clone {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <name>\""
			}
			return [Build [lindex $args 0] [set ${w}::NS]]
		}

		findnext {
			variable [set ${w}::NS]::Priv
			if {[string length $Priv(findnextcmd)]} {
				{*}$Priv(findnextcmd)
			}
			return $w
		}

		focus {
			return [SetFocus $w]
		}
	}

	return [$w.e $command {*}$args]
}


proc SetFocus {w} {
	set focus [focus]
	if {$focus ne "$w.e"} {
		variable [set ${w}::NS]::Priv
		set Priv(focus) [focus]
		::focus $w.e
	}
	$w.e selection range 0 end
	return $w
}


proc Leave {w} {
	variable [set ${w}::NS]::Priv

	if {[string length $Priv(focus)]} {
		set focus $Priv(focus)
		set Priv(focus) ""
	} else {
		set focus [winfo toplevel $w.e]
	}
	catch { focus $focus }
}


proc ShowButtons {w} {
	variable ::searchentry::[set ${w}::NS]::Vars

	foreach {sub attr} {h helpinfo i mode} {
		if {[winfo exists $w.$sub]} {
			if {[string length $Vars($attr)]} {
				grid $w.$sub
			} else {
				grid forget $w.$sub
			}
		}
	}
}


proc Clear {w} {
	set ns [set [winfo parent $w]::NS]
	variable ::searchentry::${ns}::Priv
	variable ::searchentry::${ns}::Vars

	set $Vars(textvar) ""
	set Priv(search) ""
	set Priv(search) ""
	set Priv(current) 1
	set Priv(empty) 1
	if {[focus] eq $w} {
		set Priv(content) ""
	} else {
		set Priv(content) [set $Vars(ghosttextvar)]
		$w configure -foreground $Vars(ghostcolor)
		focus $w
	}
	SetupButtons [winfo parent $w]
}


proc FocusIn {w} {
	set ns [set [winfo parent $w]::NS]
	variable ::searchentry::${ns}::Priv

	if {$Priv(empty)} {
		set Priv(content) ""
		set Priv(search) ""
		set Priv(current) 1
	} else {
		$w selection range 0 end
	}
	$w configure -foreground black
	SetupButtons [winfo parent $w]
	set Priv(search) $Priv(content)
}


proc FocusOut {w} {
	set ns [set [winfo parent $w]::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	set Priv(focus) ""
	$w selection clear
	if {[winfo exists $w.popdown] && [winfo ismapped $w.popdown]} { return }

	if {$Priv(empty)} {
		set Priv(lock) 1
		if {$Vars(type) eq "number"} { $w configure -validate none }
		set $Vars(textvar) ""
		set Priv(search) ""
		set Priv(content) [set $Vars(ghosttextvar)]
		$w configure -foreground $Vars(ghostcolor)
		if {$Vars(type) eq "number"} { $w configure -validate key }
		set Priv(lock) 0
		SetupButtons [winfo parent $w]
	} else {
		if {![string match $w* [focus]]} {
			UpdateHistory [winfo parent $w]
		}
		set $Vars(textvar) $Priv(content)
	}
}


proc Return {w} {
	set w [winfo parent $w].r
	if {[winfo exists $w]} { $w invoke }
}


proc UpdateHistory {w} {
	if {[winfo class $w] ni {TTSearchEntry TTSearchBox}} { return }

	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	if {$Priv(empty)} { return }
	set content [string trimright $Priv(content) "*"]

	if {[string length $content] < $Vars(minlength)} { return }

	set valueVar $Vars(history)
	if {[string length $valueVar] == 0} { set valueVar Vars(values) }
	set values [set $valueVar]
	set i [lsearch -exact $values $content]
	if {$i >= 0} {
		set values [lreplace $values $i $i]
	} elseif {[llength $values] >= $Vars(length)} {
		set values [lreplace $values end end]
	}
	set $valueVar [linsert $values 0 $content]
}


proc Search {w key} {
	set cb [winfo parent [::ttk::combobox::LBMaster $w]]
	if {[winfo class $cb] ni {TTSearchEntry TTSearchBox}} { return }
	set ns [set ${cb}::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	if {[string length $key] == 1} {
		set valueVar $Vars(history)
		if {[string length $valueVar] == 0} { set valueVar Vars(values) }
		set values [set $valueVar]
		if {[llength $values] == 0} { return }
		if {$Priv(current) >= [llength $values]} { set Priv(current) 0 }
		set key [string toupper $key]
		set current $Priv(current)

		while {1} {
			set i $Priv(current)
			if {[incr Priv(current)] == [llength $values]} { set Priv(current) 0 }
			if {[string index [lindex $values $i] 0] == $key} {
				$w see $i
				$w selection clear
				$w selection set $i
				return
			}
			if {[incr i] == [llength $values]} { set i 0 }
			if {$i == $current} { return }
		}
	}
}


proc ContentChanged {w args} {
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	if {$Priv(lock)} { return }

	if {[string length $Priv(content)] == 0} {
		set Priv(search) ""
		set Priv(empty) 1
	} else {
		set Priv(empty) 0

		if {$Vars(mode) eq "key" && ![string match "$Priv(content)*" $Priv(search)]} {
			after cancel $Priv(after)
			if {!$Priv(empty) && [string length $Priv(content)]} {
				set Priv(after) [after $Vars(delay) [namespace code [list Find $w.e]]]
			}
		}

		set Priv(search) $Priv(content)
	}

	set $Vars(textvar) $Priv(content)
	SetupButtons $w
}


proc SetupButtons {w} {
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	if {$Priv(empty)} { set state disabled } else { set state normal }
	if {[winfo exists $w.c]} { $w.c configure -state $state }
	if {[winfo exists $w.r]} { $w.r configure -state $state }

	if {[winfo exists $w.i]} {
		switch $Vars(mode) {
			key		{ set tip "$mc::InteractiveSearch ($mc::Enabled)" }
			enter		{ set tip "$mc::InteractiveSearch ($mc::Disabled)" }
			default	{ set tip "" }
		}
		::tooltip::tooltip $w.i $tip
	}
}


proc FindNext {w} {
	set w [winfo parent $w]
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Priv

	if {$Priv(empty)} { return [SetFocus $w] }
	UpdateHistory $w

	if {[string length $Priv(content)]} {
		event generate $ns <<FindNext>> -data $Priv(content)
	}
}


proc Find {w} {
	if {![winfo exists $w]} { return }

	set w [winfo parent $w]
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Priv

	if {!$Priv(empty)} {
		event generate $ns <<Find>> -data $Priv(content)
	}
}


proc Help {w} {
	set w [winfo parent $w]
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Vars

	if {[string length $Vars(helpinfo)]} {
		event generate $ns <<Help>>
	}
}


proc LanguageChanged {w} {
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	if {[winfo exists $w.h]} {
		if {[string length $Vars(helpinfo)]} {
			if {[info exists $Vars(helpinfo)]} {
				set helpinfo [set $Vars(helpinfo)]
			} else {
				set helpinfo $Vars(helpinfo)
			}

			::tooltip::tooltip $w.h "$helpinfo <F1>"
		}
	}

	if {[winfo exists $w.r]} { ::tooltip::tooltip $w.r "$mc::FindNext <F3>" }
	if {[winfo exists $w.c]} { ::tooltip::tooltip $w.c "$mc::Erase <$::mc::Key(Ctrl)-X>" }

	if {$Priv(empty)} {
		set Priv(content) [set $Vars(ghosttextvar)]
		set Priv(empty) 1
	}
}


proc Post {w} {
	set ns [set ${w}::NS]
	variable ::searchentry::${ns}::Vars
	variable ::searchentry::${ns}::Priv

	if {[llength $Vars(postcommand)]} {
		{*}$Vars(postcommand)
	} else {
		set valueVar $Vars(history)
		if {[string length $valueVar] == 0} { set valueVar Vars(values) }
		set values [set $valueVar]

		if {$Vars(skipfirst) && [llength $values] > 0 && [$w get] == [lindex $values 0]} {
			set values [lrange $values 1 end]
		} else {
			set values $values
		}
		$w.e configure -values $values
	}

	set Priv(current) 1
	set Priv(search) $Priv(content)
	set $Vars(textvar) $Priv(content)
}


proc TriggerFindNext {w cmd} {
	variable Visited

	array unset Visited *
	set Visited(.) 1
	if {[winfo toplevel $w] eq $w} {
		foreach child [winfo children $w] {
			if {[TriggerFindNextRecursively $child $cmd]} { return 1 }
		}
		return 0
	}
	TriggerFindNextRecursively $w $cmd
}


proc TriggerFindNextRecursively {w cmd} {
	variable Visited

	if {[info exists Visited($w)]} { return 0 }
	if {[winfo toplevel $w] eq $w} { return 0 }
	if {![winfo ismapped $w]} { return 0 }
	if {[winfo class $w] eq "TSearchEntry"} {
		$w $cmd
		return 1
	}
	set Visited($w) 1
	foreach child [winfo children $w] {
		if {[TriggerFindNextRecursively $child $cmd]} { return 1 }
	}
	return 0
}


namespace eval icon {
namespace eval 16x16 {

set erase [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAMFBMVEUAAAAAAAAAAAAAAAAA
	AAAYGBgtLS1AQEBaWlppaWmIiIiTk5O3t7e9vb3Pz8////8uw12aAAAABHRSTlMAGTJG0qtO
	sQAAAG1JREFUCB1twaENAkEURdG7NDBmKoBOXj4CQdYwNaxEbiv0gMBTA3RA6IHkiw3mMQgc
	5/DPat1tgBqdYNg/7renoF59vrzFsDt58SLqPB/tSWxbOzibyIjRDlEinE5BhmNMQYkvARmd
	gOLuxc8HJC0tRmaQ+cgAAAAASUVORK5CYII=
}]

set enter [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAC2UlEQVQ4y0WSP0gkVxzHP2/e
	zs4Mu8/ZrHEvNqIWgoJ4hBSypUfS5iRgt6lsUwTDQSSVFhYprhFEAoJgLMTrNiIBO1EQLBRt
	AkbBP9y667q7k9nZPzfzUpyOv/Y9Pu/zvr+v4GnW19fF9fX1z3d3dz84joOUMpJSZoUQAFXD
	MIwgCMhkMh/6+/vfz87OaoDEM6BarY7s7+9/X6vV8tlsFqVUBBhCCKSUkWEYRhRFnJ+ff5qc
	nCwC/wAIgOXl5W+Pj49/l1JOjI6OksvlSCaTSCmxLAspJUIIenp62N3d5fDw8CSfz79bWFj4
	2wCoVCq/lUqlieHhYVzXJZ1OY1kWtm1jWRZKKRzHQQjB1NQUg4ODE7e3t78AGAA3NzduuVQm
	l8uhlEIIERsopVhaWmJtbQ2tNZlMhnQ6zf39vYoBDw8Plh/4CCHohl2AWF1Kyc7ODsVikadA
	CYKAcrmcfgE8PjRr9RoaTRiGGIbB1tYWp6enmKb5HDLhp5Aoiqg8VvhY+liPAe1Wm7pXx0yY
	pJwUm5ubrK6ucnFxQW9vLwBKKTQaNPgNn4bXIF5jrVbDb/i4rsvGxgbb29sAnJycsLKyAsDI
	yAi+75NIJPA8D+8/7wUQtIL435VK5bkaHBwccHZ2hm3b5PN5bNtGCIHneXRb3RdAu9UGwPd9
	5ufnkVKyt7fH3NwchUKBRqNBEAQ8lYpmsxk/kgBImJ8LGXZCUqkUi4uL2LbNwMBAbGZZFo7j
	0O12n+r3eSTA2NjYT9KUuVanxauvXpFxM0xPTzM0NITWGiklyWSSq6srjo6OuPz3kk7YKTX9
	5h8AFH4sfHjz3RsNaEArpXQqldKqR2n3C1f39fXp7JfZ+Pzt9Fs9MzOzFa/x9dev39mWvfGs
	5Xkevu/jNTzqj3XK5TLVSjXW7rQ7f46Pj/8aZ2AI41IK+RfwjWmZpiGM+HKkI3SkARCGIAzD
	biKRKAopLgH+B4kzKq1AYSxKAAAAAElFTkSuQmCC
}]

set help [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADHElEQVQ4y12Ta2iVdQDGf+//
	nJ3N7bgLu+Bm5jIlZkUX3Gi4DxE4aiUhlVpZEQRBkK19SSpQ+qKFYEUXEaQLwT5YGzNB1rpI
	0W1JS83pXLucCztzG2fnnPfdOe/Oec/79EHK1fP1uX15Hov/o+OLDVjBMMpZFHwRArTawr6Q
	49yrCcBeKbeuG0/V4ObXkrEXi6N74iZg/qV8r0ig7eNmVtdVMtKzjD05CXjXA3Z8XUtipkE/
	PzXqAb85EJ0TqYzPcj7Amgp4eDOUWkUuTi9x2+abtpJLngXy1yq2fn6rJP1+Veo+KR3sX9BU
	dEFOal7T8bT2fZbV9sO+hiclqajzEykBbYCB9oGNNHdXj89JD7wl7Tk4KSmpoufrk8GEpLz8
	ZVsdPdNq7Z5R0pamE44INz8PrDeYQqmmjiwe6csS+StGTXCO+Lzh0TfGeOaVUfYfn8AKhWlp
	yjMVm+dQb4wbG8o5883QUaA1iJ8vJpIev5yfYZVxGbpgOLV3DNeD6rVB7t9SAcCVeJZwaZHv
	/1ig6DdRW18HcK+haPz4vEsqnUG+R2nIUF4WIGQVOPpCJe13rOO14xHGYzkqQpB2XDLZZYxl
	ATQaSlZZ4ZDwCi4gjAXZPHTd5bOr607e7bvK+31xaqtKKMrHUCRo+ViWAQgafMvadEOIujA4
	WQ9jDMYSBMqYnnXp/XaWuuoQwYCF7bhsagoSLi8hlVwE8A1uxvgYnu6sJbFgUyiIUInhXNTi
	zd4IaTtPeZnBdT2WnCwv7mhkPu1zdvgHgKQh/k6ytPNky0u7mnmwtZzJWJK55DJPtuf48OVb
	6NxSRXR2iejsIt2P1HNf2xqStseP330J8CtAgPXP3h2dW5Lk6MCxEdU/dFodzw3qWP+Ybt59
	Rht3Duqj/ouSchqLOtrbs0/AYWDDP3OvoqFr2+WYo0LeVTQa16cDI/rgxJ8a+mlCqfSCMnZW
	o5GMXj9wSMB7wDYgtPJYjYTqd9Ky/55LEVtjMUdXYo4uR21ditga+GpYux9/QsDbwHag8r9v
	vIYa4HbgMWAdEFjB5YFR4AQwDuQA/gYnfp8AtyqOvQAAAABJRU5ErkJggg==
}]

set character [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAB
	W0lEQVR42qVTu47CMBCcrN1QgAR/kIaCghJBvoMvQNTX0dFRUvJJSFGKwF9ESBBCBElQeGiu
	IbmEi0DcjTSSbXlnx7tr4AcjAPyQoyx4AICfAgCNhwAzpc1mgyIMw8gpIqV9s9mEPO5ZAGDb
	NlzXzYNFpMRMJCMAVDp4lbV4Vq/XfztYrVZ5hsVigW63i3a7DcuysFwuS4JF5JXdbrf0fZ/7
	/Z7r9Zqe5zEMQ87nc5qmySiKGMcxkyQhAOqCAztz0Ov1ICJI0xTj8Riu60Iphd1u995BEAQ8
	HA70PI+tVouz2Yy+79NxHIoIz+cz0zTl5XIhAFZ2QUQQhiGCIMBwOEStVoPjOHlnskJWOjge
	jzydToyiiJPJhI1Gg6ZpcjqdstPp8Hq98na78X6/lwZpkNUgSRL0+/2X7SvxeQ7iOH47A8Up
	rayB1hpaayiloJTK18/vfsZffuMX/otvyYkGOKTnByIAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon


::ttk::copyBindings TEntry TTSearchEntry

bind TTSearchEntry <FocusIn>			{ ::tooltip::hide }
bind TTSearchEntry <FocusIn>			+[namespace code { FocusIn %W }]
bind TTSearchEntry <FocusOut>			[namespace code { FocusOut %W }]
bind TTSearchEntry <Return>			[namespace code { Return %W }]
bind TTSearchEntry <Return>			{+ break }
bind TTSearchEntry <<TraverseIn>>	{}

::ttk::copyBindings TEntry TTSearchBox
::ttk::copyBindings TTCombobox TTSearchBox

bind TTSearchBox <FocusIn>			{ ::tooltip::hide }
bind TTSearchBox <FocusIn>			+[namespace code { FocusIn %W }]
bind TTSearchBox <FocusOut>		[namespace code { FocusOut %W }]
bind TTSearchBox <Return>			[namespace code { Return %W }]
bind TTSearchBox <Return>			{+ break }
bind TTSearchBox <B1-Leave>		{ break } ;# avoid AutoScroll (bug in Tk)
bind TTSearchBox <<TraverseIn>>	{}

bind ComboboxListbox <Any-Key> [namespace code { Search %W %A }]

switch -- [tk windowingsystem] {
	x11	{ option add *TTSearchBox*Listbox.background white }
	aqua	{ option add *TTSearchBox*Listbox.borderWidth 0 }
}

} ;# namespace searchentry

# vi:set ts=3 sw=3:
