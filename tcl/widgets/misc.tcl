# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

::util::source miscellaneous-widget-functions

namespace eval widget {
namespace eval mc {

set Ok			"&OK"
set Cancel		"&Cancel"
set Apply		"&Apply"
set Reset		"&Reset"
set Close		"&Close"
set Clear		"C&lear"
set Import		"&Import"
set Revert		"&Revert"
set Update		"&Update"
set Previous	"&Previous"
set Next			"&Next"
set Last			"Las&t"
set First		"&First"
set Help			"&Help"
set Start		"&Start"

set New			"&New"
set Save			"&Save"
set Delete		"&Delete"

set Control(minimize)	"Minimize"
set Control(restore)		"Leave Full-screen"
set Control(close)		"Close"

} ;# namespace mc

set Priv(busy:state) 0
set Priv(busy:locked) 0


set ButtonOrder \
	{ new delete save previous next clear update close ok apply cancel revert reset help hlp }
	

proc focusNext {w next} { set [namespace current]::Priv(next:$w) $next }
proc focusPrev {w prev} { set [namespace current]::Priv(prev:$w) $prev }


proc bindMouseWheel {w {number 5} {units "units"}} {
	switch [tk windowingsystem] {
		x11 {
			bind $w <Button-4> [list %W yview scroll -$number $units]
			bind $w <Button-5> [list %W yview scroll +$number $units]
		}
		aqua {
			bind $w <MouseWheel> { %W yview scroll [expr {-(%D)}] $units }
		}
		win32 {
			bind $w <MouseWheel> { %W yview scroll [expr {-(%D/120)*max(1,$number - 1)}] $units }
		}
	}
	if {[string first . $w] >= 0} {
		if {[tk windowingsystem] eq "x11"} {
			bind $w <Button-4> {+ break }
			bind $w <Button-5> {+ break }
		} else {
			bind $w <MouseWheel> {+ break }
		}
	}
}


proc showTrace {path text useHorzScroll closeCmd} {
	set txt $path.f.text

	if {[winfo exists $path]} {
		$txt configure -state normal
		$txt delete 1.0 end
	} else {
		tk::toplevel $path -class Scidb
		set f [::ttk::frame $path.f -takefocus 0]

		if {$useHorzScroll} {
			set wrap none
			set xscrollcommand [list -xscrollcommand [list $f.hsb set]]
		} else {
			set wrap word
			set xscrollcommand {}
		}
		tk::text $f.text \
			-width 100 \
			-height 40 \
			-yscrollcommand [list $f.vsb set] \
			{*}$xscrollcommand \
			-wrap $wrap \
			-setgrid 1 \
			;
		if {$useHorzScroll} {
			ttk::scrollbar $f.hsb -orient horizontal -command [list $f.text xview]
		}
		ttk::scrollbar $f.vsb -orient vertical -command [list ::widget::textLineScroll $f.text]
		pack $f -expand yes -fill both
		grid $f.text -row 1 -column 1 -sticky nsew
		if {$useHorzScroll} {
			grid $f.hsb  -row 2 -column 1 -sticky ew
		}
		grid $f.vsb  -row 1 -column 2 -sticky ns
		grid rowconfigure $f 1 -weight 1
		grid columnconfigure $f 1 -weight 1
		dialogButtons $path close
		if {[llength $closeCmd]} {
			$path.close configure -command $closeCmd
		}
#		::util::place $path -parent $w -position center
		wm protocol $path WM_DELETE_WINDOW $closeCmd
		wm deiconify $path
	}

	$txt insert end $text
	$txt configure -state disabled
}


proc textIsEmpty? {w} {
	if {[$w compare end > 2.0]} { return 0 }
	return [expr {[$w count -chars 1.0 2.0] <= 1}]
}


proc textLineScroll {w cmd args} {
	switch $cmd {
		moveto {
			lassign $args fraction
			set fraction [expr {min(1.0, max(0.0, $fraction))}]
			lassign [$w yview] first last

			set incr     [font metrics [$w cget -font] -linespace]
			set height   [expr {max(1, [winfo height $w] - 2*([$w cget -borderwidth] + [$w cget -pady]))}]
			set visible  [expr {double($height)/$incr}]
			set total    [expr {int($visible/($last - $first) + 0.5)}]
			set topline  [expr {int($fraction*double($total) + 0.5)}]

			if {$total > 0} {
				$w yview moveto [expr {double($topline)/double($total)}]
			}
		}

		default {
			$w yview $cmd {*}$args
		}
	}
}


proc textPreventSelection {w} {
	bind $w <Double-1>			{ break }
	bind $w <Triple-1>			{ break }
	bind $w <B1-Motion>			{ break }
	bind $w <B2-Motion>			{ break }
	bind $w <ButtonPress-2>		{ break }
	bind $w <ButtonRelease-2>	{ break }
}


proc notebookSetLabel {nb id text} {
	lassign [::tk::UnderlineAmpersand $text] text idx
	$nb tab $id -text [::mc::stripAmpersand $text] -underline $idx
}


proc notebookTextvarHook {nb id var {args {}}} {
	SetNotebookLabel $nb $id $var $args
	set cmd [list [namespace current]::SetNotebookLabel $nb $id $var $args]
	trace add variable $var write $cmd
	bind $nb <Destroy> "+
		if {{$nb} eq {%W}} { trace remove variable $var write {$cmd} }
	"
}


proc menuTextvarHook {m index var {args {}}} {
	SetMenuLabel $m $index $var $args
	set cmd [list [namespace current]::SetMenuLabel $m $index $var $args]
	trace add variable $var write $cmd
#	For some reasons this callback will be called although the menu is not destroyed
#	(possibly some kind of copy operation).
#	bind $m <Destroy> +[list trace remove variable $var write $cmd]
}


proc dialogWatch {dlg} {
	variable Priv
	bind $dlg <Visibility> [namespace code [list Visibility %W $dlg %s]]
}


proc dialogRaise {dlg} {
	variable Priv

	switch [wm state $dlg] {
		withdrawn - iconic - icon {
			wm deiconify $dlg
		}

		default {
			if {[CheckIsKDE]} {
				if {	![info exists Priv(visibility:$dlg)]
					|| $Priv(visibility:$dlg) ne "VisibilityUnobscured"} {
					# stupid handling of KDE: without withdrawing
					# the window will not be raised
					set geom [wm geometry $dlg]
					if {[string length $geom]} {
						set geom [string range $geom [string first + $geom] end]
						catch { wm geometry $dlg $geom }
					}
					wm withdraw $dlg
				}
			}
			wm deiconify $dlg
		}
	}

	raise $dlg
	focus -force $dlg
}


proc dialogButtons {dlg buttons args} {
	variable ButtonOrder
	variable Specs

	array set opts {
		-default 	{}
		-icons		yes
		-alignment	center
		-justify		center
	}
	array set opts $args

	if {![winfo exists $dlg.__buttons]} {
		if {[llength $opts(-default)] == 0} { set opts(-default) [lindex $buttons 0] }
		bind $dlg <Alt-Key> [list tk::AltKeyInDialog $dlg %A]
		::ttk::separator $dlg.__sep -class Dialog
		tk::frame $dlg.__buttons -class Dialog -takefocus 0
		set slaves [pack slaves $dlg]
		if {[llength $slaves]} {
			pack $dlg.__sep -fill x -side bottom -before [lindex $slaves 0]
		} else {
			pack $dlg.__sep -fill x -side bottom
		}
		pack $dlg.__buttons -anchor center -side bottom -before $dlg.__sep -fill x -expand 0
	}

	set entries {}
	foreach entry $buttons {
		set icon {}
		lassign $entry type var icon
		lappend entries [list $type $var $icon [lsearch -exact $ButtonOrder $type]]
	}
	set entries [lsort -index 3 -integer $entries]
	set Specs(alignment:$dlg) $opts(-alignment)

	foreach entry $entries {
		lassign $entry type var icon
		set w [::ttk::button $dlg.$type -class TButton]

		switch -- $type {
			ok {
				set n [llength [pack slaves $dlg.__buttons]]
				if {$n > 0} {
					set sep [tk::frame $dlg.sep$n -borderwidth 0 -takefocus 0 -width 20]
					PackDialogButton $dlg $sep left
					set Specs(justify:$sep) $opts(-justify)
				}
				set var [namespace current]::mc::Ok
			}

			cancel	{ set var [namespace current]::mc::Cancel }
			apply		{ set var [namespace current]::mc::Apply }
			update	{ set var [namespace current]::mc::Update }
			reset		{ set var [namespace current]::mc::Reset }
			close		{ set var [namespace current]::mc::Close }
			clear		{ set var [namespace current]::mc::Clear }
			import	{ set var [namespace current]::mc::Import }
			revert	{ set var [namespace current]::mc::Revert }
			previous	{ set var [namespace current]::mc::Previous }
			next		{ set var [namespace current]::mc::Next }
			first		{ set var [namespace current]::mc::First }
			last		{ set var [namespace current]::mc::Last }
			new		{ set var [namespace current]::mc::New }
			save		{ set var [namespace current]::mc::Save }
			delete	{ set var [namespace current]::mc::Delete }
			start		{ set var [namespace current]::mc::Start }

			help - hlp {
				set n [llength [pack slaves $dlg.__buttons]]
				if {$n > 0} { dialogButtonAddSeparator $dlg }
				set var [namespace current]::mc::Help
			}

			default {
				return -code error "unknown button type $type"
			}
		}

		dialogButtonsSetup $dlg $type $var $opts(-default)
		bind $w <Return> "event generate $w <Key-space>; break"
		set Specs(justify:$w) $opts(-justify)
		PackDialogButton $dlg $w left
	}

	DoAlignment $dlg
	if {$opts(-icons)} { dialogButtonSetIcons $dlg }
}


proc dialogButtonReplace {dlg type iconType} {
	$dlg.$type configure -image [GetIcon $iconType]
}


proc dialogButtonSetIcons {dlg} {
	foreach w [winfo children $dlg] {
		if {[winfo class $w] eq "TButton"} {
			set type [lindex [split $w .] end]
			set icon [GetIcon $type]
			if {$type eq "hlp"} { set compound image } else { set compound left }
			if {[llength $icon]} { $w configure -compound $compound -image $icon }
		}
	}
}


proc dialogButtonAddSeparator {dlg args} {
	variable Specs

	array set opts {
		-justify		center
		-side			left
		-position	end
	}
	array set opts $args

	if {![winfo exists $dlg.__buttons]} { dialogButtons $dlg {} }
	set index 0
	while {[winfo exists $dlg.sep$index]} { incr index }
	set sep [tk::frame $dlg.sep$index -borderwidth 0 -takefocus 0 -width 10]
	PackDialogButton $dlg $sep $opts(-side)
	set Specs(justify:$sep) $opts(-justify)
}


proc dialogButtonAdd {dlg type labelvar icon args} {
	variable Specs

	array set opts {
		-justify		center
		-side			left
		-position	end
	}
	array set opts $args

	if {![winfo exists $dlg.__buttons]} { dialogButtons $dlg {} }
	set w [::ttk::button $dlg.$type -class TButton]
	if {[llength $icon]} {
		$w configure -compound left -image $icon
	}
	set Specs(justify:$w) $opts(-justify)
	dialogButtonsSetup $dlg $type $labelvar
	bind $w <Return> "event generate $w <Key-space>; break"
	PackDialogButton $dlg $w $opts(-side) $opts(-position)
	DoAlignment $dlg
}


proc dialogButtonsPack {w args} {
	variable Specs

	array set opts {
		-justify		center
		-side			left
		-position	end
	}
	array set opts $args

	set dlg [winfo parent $w]
	if {![winfo exists $dlg.__buttons]} { dialogButtons $dlg {} }
	set Specs(justify:$w) $opts(-justify)
	PackDialogButton $dlg $w $opts(-side) $opts(-position)
	DoAlignment $dlg
}


proc dialogButtonsSetup {parent type var {dflt {}}} {
	set w $parent.$type

	if {$type eq $dflt} {
		$w configure -default active
		bind $parent <Return> "
			if {\[winfo exists $w\] && \[$w cget -state\] eq {normal}} {
				focus $w
				event generate $w <Key-space>
			}"
	} elseif {[llength $dflt]} {
		bind $w <FocusIn>		"$parent.$dflt configure -default normal; $w configure -default active"
		bind $w <FocusOut>	"$parent.$dflt configure -default active; $w configure -default normal"
	} else {
		bind $w <FocusIn>		"$w configure -default active"
		bind $w <FocusOut>	"$w configure -default normal"
	}

	buttonSetText $w $var
}


proc dialogButtonInvoke {parent} {
	foreach w [winfo children $parent] {
		if {[winfo class $w] eq "TButton"} {
			if {[$w cget -default] eq "active"} {
				focus $w
				event generate $w <Key-space>
				return
			}
		}
	}
}


proc dialogSetTitle {dlg cmd} {
	SetDialogTitle $dlg $cmd
	bind $dlg <<LanguageChanged>> [namespace code [list SetDialogTitle $dlg $cmd]]
}


proc dialogFullscreenButtons {parent} {
	tk::frame $parent.__control__ -borderwidth 0 -takefocus 0

	tk::button $parent.__control__.minimize \
		-image $icon::12x12::minimize \
		-relief flat \
		-overrelief raised \
		-borderwidth 1 \
		-takefocus 0 \
		;
	::tooltip::tooltip $parent.__control__.minimize [namespace current]::mc::Control(minimize)

	tk::button $parent.__control__.restore \
		-image $icon::12x12::restore \
		-relief flat \
		-overrelief raised \
		-borderwidth 1 \
		-takefocus 0 \
		;
	::tooltip::tooltip $parent.__control__.restore [namespace current]::mc::Control(restore)

	tk::button $parent.__control__.close \
		-image $icon::12x12::close \
		-relief flat \
		-overrelief raised \
		-borderwidth 1 \
		-takefocus 0 \
		;
	FullscreenSetupCloseButton $parent

	bind $parent.__control__.close <<LanguageChanged>> \
		[namespace code [list FullscreenSetupCloseButton $parent]]

	pack $parent.__control__.minimize -side left -fill y -expand yes
	pack $parent.__control__.restore -side left -fill y -expand yes
	pack $parent.__control__.close -side left -fill y -expand yes

	return $parent.__control__
}


proc FullscreenSetupCloseButton {parent} {
	::tooltip::tooltip $parent.__control__.close "$mc::Control(close) ($::mc::Key(Alt)+F4)"
}


proc buttonSetText {w var args} {
	set type [lindex [split $w .] end]

	if {$type eq "hlp"} {
		if {[string first "&" [set $var]] >= 0} {
			set var [mc::stripped $var]
		}
		::tooltip::tooltip $w "[set $var] <F1>"
		bind $w <<LanguageChanged>> [list buttonSetText $w $var]
	} else {
		if {[$w cget -compound] eq "left"} {
			::tk::SetAmpText $w " [set $var]"
		} else {
			::tk::SetAmpText $w [set $var]
		}

		set cmd "[namespace current]::buttonSetText $w $var"
		trace add variable $var write $cmd
		bind $w <Destroy> "+
			if {\"$w\" eq \"%W\"} {
				trace remove variable $var write \"$cmd\"
			}
		"
	}
}


proc setBoldFont {w} {
	set font [$w cget -font]
	set bold [list [font configure $font -family]  [font configure $font -size] bold]
	$w configure -font $font
}


proc busyCursor {w {state on}} {
	variable Priv

	if {$Priv(busy:locked)} { return }

	if {[string index $w 0] ne "."} {
		set state $w
		set w --
	}

	if {$state eq "on"} {
		if {[incr Priv(busy:state)] != 1} { return }
		set action hold
	} else {
		if {[incr Priv(busy:state) -1] != 0} { return }
		set action forget
	}

	set Priv(busy:locked) 1
	::update

	foreach toplevel {.application .setupEngine .help .playerDict .mergeDialog} {
		if {[winfo exists $toplevel]} {
			::scidb::tk::busy $action $toplevel

			if {[tk windowingsystem] eq "x11"} {
				foreach tlv [winfo children $toplevel] {
					BusyCursor $action $tlv $w
				}
			}
		}
	}

	if {$action eq "hold"} { ::update }
	set Priv(busy:locked) 0
}


proc unbusyCursor {{w {}}} {
	busyCursor {*}$w off
}


proc busyOperation {cmd} {
	busyCursor on

	if {[catch {uplevel 1 $cmd} result options]} {
		busyCursor off
		array set opts $options
		return \
			-code $opts(-code) \
			-errorinfo $opts(-errorinfo) \
			-errorcode $opts(-errorcode) \
			-rethrow 1 \
			$result
	}

	busyCursor off
	return $result
}


proc menuItemHighlightSecond {menu} {
	##	NOTE: the menu is flickering a lot!
	##  ----------------------------------
	set active [$menu index active]
	set numEntries [expr {[$menu index last] + 1}]

	if {$active eq "none"} {
		set index -1
	} else {
		set index [expr {($active + $numEntries/2) % $numEntries}]
	}

	for {set i 0} {$i < $numEntries} {incr i} {
		if {$i != $active && $i != $index} {
			if {[llength [$menu entrycget $i -background]]} {
				$menu entryconfigure $i -background {} -foreground {}
			}
		}
	}

	if {$index != -1} {
		$menu entryconfigure $index \
			-background [option get $menu activeBackground Menu] \
			-foreground [option get $menu activeForeground Menu]
	}
}


proc Visibility {w dialog state} {
	variable Priv
	if {$dialog eq $w} { set Priv(visibility:$w) $state }
}


proc PackDialogButton {dlg btn side {position {}}} {
	set slaves [pack slaves $dlg.__buttons]
	set options {}
	if {[llength $slaves]} {
		switch $position {
			start	{ lappend options -before [lindex $slaves 0] }
			end	{ lappend options -after [lindex $slaves end] }
		}
	}
	pack $btn -in $dlg.__buttons -pady $::theme::pady -padx $::theme::padx -side $side {*}$options
}


proc DoAlignment {dlg} {
	variable Specs

	set slaves [pack slaves $dlg.__buttons]
	if {[llength $slaves] == 0} { return }

	switch $Specs(alignment:$dlg) {
		left {
			pack configure {*}$slaves -expand 0 -anchor w
			set i 0
			while {$i < [llength $slaves] && $Specs(justify:[lindex $slaves $i]) eq "right"} {
				incr i
			}
			if {$i < [llength $slaves]} {
				pack configure [lindex $slaves $i] -expand 1
			}
		}
		right {
			pack configure {*}$slaves -expand 0 -anchor e
			set i 0
			while {$i < [llength $slaves] && $Specs(justify:[lindex $slaves $i]) eq "left"} {
				incr i
			}
			if {$i < [llength $slaves]} {
				pack configure [lindex $slaves $i] -expand 1
			}
		}
		center {
			if {[llength $slaves] == 1} {
				pack configure {*}$slaves -expand 1 -anchor center
			} else {
				pack configure {*}$slaves -expand 0 -anchor w
				set i 0
				while {$i < [llength $slaves] && $Specs(justify:[lindex $slaves $i]) eq "right"} {
					incr i
				}
				if {$i < [llength $slaves]} {
					pack configure [lindex $slaves $i] -expand 1 -anchor e
				}
				set i [expr {[llength $slaves] - 1}]
				while {$i >= 0 && $Specs(justify:[lindex $slaves $i]) ne "right"} {
					incr i -1
				}
				if {$i < 0} { set i end }
				pack configure [lindex $slaves $i] -expand 1 -anchor w
			}
		}
	}
}


proc GetIcon {type} {
	switch $type {
		ok				{ return $::icon::iconOk }
		cancel		{ return $::icon::iconCancel }
		apply			{ return $::icon::iconApply }
		update		{ return $::icon::iconUpdate }
		reset			{ return $::icon::iconSetup }
		clear			{ return $::icon::iconClear }
		close			{ return $::icon::iconClose }
		revert		{ return $::icon::iconReset }
		previous		{ return $::icon::iconBackward }
		next			{ return $::icon::iconForward }
		first			{ return $::icon::iconFirst }
		last			{ return $::icon::iconLast }
		new			{ return $::icon::16x16::plus }
		save			{ return $::icon::iconSave }
		delete		{ return $::icon::16x16::delete }
		help - hlp	{ return $::icon::16x16::help }
		start			{ return $::icon::16x16::run }
	}
}


proc BusyCursor {action w ignore} {
	if {$w ne $ignore} {
		if {[winfo toplevel $w] eq $w} {
			catch { ::scidb::tk::busy $action $w }
		}
		foreach tlv [winfo children $w] {
			BusyCursor $action $tlv $ignore
		}
	}
}


proc SetNotebookLabel {nb id var args} {
	lassign [::tk::UnderlineAmpersand [set $var]] text idx
	$nb tab $id -text [format $text {*}$args] -underline $idx
}


proc SetMenuLabel {m index var args} {
	lassign [::tk::UnderlineAmpersand [format [set $var] {*}$args]] text ul
	set text " $text"
	incr ul

	if {$ul > 0} {
		$m entryconfigure $index -label $text -underline $ul
	} else {
		$m entryconfigure $index -label $text
	}
}


proc SetDialogTitle {dlg cmd} {
	wm title $dlg [eval $cmd]
}


proc CheckIsKDE {} {
	variable IsKde_

	if {![info exists IsKde_]} {
		if {[tk windowingsystem] eq "x11"} {
			set atoms {}
			catch { set atoms [exec /bin/sh -c "xlsatoms | grep _KDE_RUNNING"] }
			set IsKde_ [expr {[string length $atoms] > 0}]
		} else {
			set IsKde_ 0
		}
	}

	return $IsKde_
}


namespace eval icon {
namespace eval 12x12 {

set restore [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAQElEQVQY02N8z4AdsMAYgv+R
	hd8zMjEQ0sHA8J4RWTcLwhiYYRAFhIxCNgaikwVTLXFGofqCgYGBgRGXz3EaBQCJyw4hsZ0N
	1AAAAABJRU5ErkJggg==
}]

set minimize [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAH0lEQVQY02P8z4AdMDEMKQkW
	CMWI5J3/jHh1MJLscwAXlAQX2HQFpAAAAABJRU5ErkJggg==
}]

set close [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAApklEQVQY033OsY4BARSF4S8U
	Emw27NARr7DvINErVOIlvAOJYpttSUS3UUg0PIpuOp1KMhOjmC1mhkac6uTec+9/eKuyiVbu
	u0ZKxXjqbK2Brr3QJFs1LSVif74d3V0tVLObLxs3sYtEZO7jSWnbSqVSv1k6x6j5zF2g8sx3
	HCQioZvYumjYsnMX+dGzkYis1LN3Y6GZKgJLJ8MCUdJ/NAkMHuRX+gd3xCejvVN16wAAAABJ
	RU5ErkJggg==
}]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace widget


# NOTE: we have to stipulate tk_focusNext before renaming is possibe!
tk_focusNext .
tk_focusPrev .
rename tk_focusNext tk_focusNext_widget_
rename tk_focusPrev tk_focusPrev_widget_


proc ::tk_focusNext {w} {
	variable widget::Priv

	if {[info exists Priv(next:$w)]} { return $Priv(next:$w) }
	return [tk_focusNext_widget_ $w]
}


proc ::tk_focusPrev {w} {
	variable widget::Priv

	if {[info exists Priv(prev:$w)]} { return $Priv(prev:$w) }
	return [tk_focusPrev_widget_ $w]
}

# vi:set ts=3 sw=3:
