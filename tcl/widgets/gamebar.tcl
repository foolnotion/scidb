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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval gamebar {
namespace eval mc {

set StartPosition			"Start Position"
set Players					"Players"
set Event					"Event"
set Site						"Site"
set ShowActiveAtBottom	"Show active game at bottom"
set ShowPlayersOnSeparateLines "Show players on separate lines"

} ;# namespace mc

array set Defaults {
	color:normal		#d9d9d9
	color:selected		white
	color:active		#efefef
	color:darker		#828282
	color:shadow		#e6e6e6
	color:lighter		white
	color:player		#ebf4f5
	width					18
	padx					5
	pady					3
}

array set Options {
	alignment			center
	separateLines		0
	selectedAtBottom	1
}

array set Specs {
	counter:label 0
}

event add <<LabelbarSelected>>	LabelbarSelected
event add <<LabelbarRemoved>>		LabelbarRemoved


proc gamebar {path} {
	variable Specs
	variable Defaults

	set bold [list [font configure TkTextFont -family] [font configure TkTextFont -size] bold]
	set gamebar [canvas $path -borderwidth 0]

	$gamebar bind header <ButtonPress-3> [namespace code [list PopupMenu $gamebar]]

	bind $gamebar <Destroy> [namespace code [list array unset Specs *:$gamebar]]
	bind $gamebar <Configure> [namespace code { Configure %W %w }]

	set Specs(height:$gamebar) 0
	set Specs(width:$gamebar) 0
	set Specs(selected:$gamebar) {}
	set Specs(size:$gamebar) 0
	set Specs(line:$gamebar) 0
	set Specs(number:$gamebar) 1
	set Specs(width:$gamebar) $Defaults(width)
	set Specs(receiver:$gamebar) $gamebar
	set Specs(font:$gamebar) TkTextFont
	set Specs(bold:$gamebar) $bold
	set Specs(adjustment:$gamebar) {1 0}
	set Specs(linewidth:$gamebar) 0

	::scidb::db::subscribe gameInfo [namespace current]::Update $gamebar

	return $path
}


proc add {gamebar id data tags} { insert $gamebar end $id $data $tags }


proc insert {gamebar at id info tags} {
	variable Specs
	variable Defaults
	variable icon::15x15::close
	variable icon::15x15::digit	;# alternative: or U+2776, U+2777, ... (or U+278A, U+278B)

	if {$at eq "end"} { set at $Specs(size:$gamebar) }
	set normal $Defaults(color:normal)
	set lighter $Defaults(color:lighter)
	set darker $Defaults(color:darker)
	set bold $Specs(bold:$gamebar)
	set data [MakeData $info]

	$gamebar create rectangle 0 0 0 0 \
		-tags [list lighter$id all$id] \
		-fill $lighter \
		-outline $lighter \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list darker$id all$id] \
		-fill $darker \
		-outline $darker \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list bg$id all$id] \
		-fill $normal \
		-outline $normal \
		;
	$gamebar create image 0 0 \
		-anchor nw \
		-tags [list whiteCountry$id all$id] \
		-state hidden \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list whiteCountryInput$id all$id] \
		-fill {} \
		-outline {} \
		-state hidden \
		;
	$gamebar create image 0 0 \
		-anchor nw \
		-tags [list blackCountry$id all$id] \
		-state hidden \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list blackCountryInput$id all$id] \
		-fill {} \
		-outline {} \
		-state hidden \
		;
	$gamebar create text 0 0 -anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list hyphen$id all$id] \
		-text " \u2212 " \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill $normal \
		-outline $normal \
		-tags [list whitebg$id all$id] \
		;
	$gamebar create text 0 0 -anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list white$id all$id] \
		-text [lindex $data 0] \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list whiteInput$id all$id] \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill $normal \
		-outline $normal \
		-tags [list blackbg$id all$id] \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list black$id all$id] \
		-text [lindex $data 1] \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list blackInput$id all$id] \
		;
	$gamebar create image 0 0 \
		-anchor nw \
		-tags [list digit$id all$id] \
		-image $digit([expr {$at + 1}]) \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list line1$id all$id] \
		-text [lindex $data 2] \
		-state hidden \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list line2$id all$id] \
		-text [lindex $data 3] \
		-state hidden \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list input$id all$id] \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list close:lighter$id all$id close$id] \
		-fill $lighter \
		-outline $lighter \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list close:darker$id all$id close$id] \
		-fill $darker \
		-outline $darker \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list close:bg$id all$id close$id] \
		-fill $normal \
		-outline $normal \
		;
	$gamebar create image 0 0 \
		-anchor nw \
		-tags [list close:icon$id all$id close$id] \
		-image $close \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list close:input$id all$id close$id] \
		;

	SetCountryFlag $gamebar $id $data white
	SetCountryFlag $gamebar $id $data black

	foreach side {white black} {
		set tag ${side}Input${id}

		$gamebar bind $tag <ButtonPress-2>		[namespace code [list ShowPlayer $gamebar $id $side]]
		$gamebar bind $tag <ButtonRelease-2>	[namespace code [list HidePlayer $gamebar $id $side]]
		$gamebar bind $tag <ButtonPress-3>		[namespace code [list PopupMenu $gamebar]]

		$gamebar bind $tag <Enter>	[namespace code [list EnterPlayer $gamebar $id $side]]
		$gamebar bind $tag <Leave>	[namespace code [list LeavePlayer $gamebar $id $side]]

		set tag ${side}CountryInput${id}

		$gamebar bind $tag <Enter> [namespace code [list EnterFlag $gamebar $id $side]]
		$gamebar bind $tag <Leave> [namespace code [list LeaveFlag $gamebar $id]]
		$gamebar bind $tag <ButtonPress-3> [namespace code [list PopupMenu $gamebar]]
	}

	set Specs(lookup:$at:$gamebar) $id
	set Specs(data:$id:$gamebar) $data
	set Specs(tags:$id:$gamebar) $tags
	set Specs(state:$id:$gamebar) normal
	set Specs(atclose:$id:$gamebar) {}
	incr Specs(size:$gamebar)

	set tooltip [lindex $data 0]
	append tooltip " - "
	append tooltip [lindex $data 1]
	foreach i {2 3} {
		set item [lindex $data $i]
		if {$item ne "" && $item ne "?"} {
			if {[string length $tooltip]} { append tooltip "\n" }
			append tooltip $item
		}
	}
	::tooltip::tooltip $gamebar -item input$id $tooltip
	::tooltip::tooltip $gamebar -item close:input$id $tooltip
	set Specs(tooltip:$id:$gamebar) $tooltip

	$gamebar bind close:input$id <ButtonPress-1> [namespace code [list Press $gamebar $id close:]]
	$gamebar bind close:input$id <ButtonRelease-1> [namespace code [list Release $gamebar $id close:]]
	$gamebar bind close:input$id <ButtonPress-2> [namespace code [list ShowTags $gamebar $id]]
	$gamebar bind close:input$id <ButtonRelease-2> [namespace code [list HideTags $gamebar]]
	$gamebar bind close:input$id <ButtonPress-3> [namespace code [list PopupMenu $gamebar]]
	$gamebar bind close:input$id <Enter> [namespace code [list Enter $gamebar $id close:]]
	$gamebar bind close:input$id <Leave> [namespace code [list Leave $gamebar $id close:]]

	$gamebar bind input$id <ButtonPress-2> [namespace code [list ShowTags $gamebar $id]]
	$gamebar bind input$id <ButtonRelease-2> [namespace code [list HideTags $gamebar]]

	foreach type {input white black} {
		$gamebar bind $type$id <ButtonPress-1> [namespace code [list Press $gamebar $id]]
		$gamebar bind $type$id <ButtonRelease-1> [namespace code [list Release $gamebar $id]]
		$gamebar bind $type$id <ButtonPress-3> [namespace code [list PopupMenu $gamebar]]
		$gamebar bind $type$id <Enter> [namespace code [list Enter $gamebar $id]]
		$gamebar bind $type$id <Leave> [namespace code [list Leave $gamebar $id]]
	}

	if {[llength $Specs(selected:$gamebar)] == 0} {
		SetSelected $gamebar $id
	} else {
		# may be set hidden in proc remove
		if {$Specs(size:$gamebar) > 1} {
			$gamebar itemconfigure digit$Specs(lookup:0:$gamebar) -state normal
		}
		Layout $gamebar
	}
}


proc remove {gamebar id} {
	variable Specs
	variable icon::15x15::digit

	set at [getIndex $gamebar $id]
	set succ [expr {$at + 1}]
	set pred $at

	for {} {$succ < $Specs(size:$gamebar)} {incr pred; incr succ} {
		set Specs(lookup:$pred:$gamebar) $Specs(lookup:$succ:$gamebar)
	}

	incr Specs(size:$gamebar) -1
	for {set i 0} {$i < $Specs(size:$gamebar)} {incr i} {
		$gamebar itemconfigure digit$Specs(lookup:$i:$gamebar) -image $digit([expr {$i + 1}])
	}

	$gamebar delete all$id
	array unset Specs lookup:$Specs(size:$gamebar):$gamebar
	foreach item {data tags state atclose} { array unset Specs $item:$id:$gamebar }

	switch $Specs(size:$gamebar) {
		0 { set Specs(selected:$gamebar) {} }
		1 { $gamebar itemconfigure digit$Specs(lookup:0:$gamebar) -state hidden }
	}

	if {$id eq $Specs(selected:$gamebar) && $Specs(size:$gamebar)} {
		if {$at == $Specs(size:$gamebar)} { set at 0 }
		SetSelected $gamebar $Specs(lookup:$at:$gamebar)
	} else {
		Layout $gamebar
	}

	foreach recv $Specs(receiver:$gamebar) {
		event generate $recv <<LabelbarRemoved>> -data $id
	}
}


proc activate {gamebar id} {
	variable Specs

	if {$id ne $Specs(selected:$gamebar)} {
		SetSelected $gamebar $id
	}
}


proc selected {gamebar} {
	return [set [namespace current]::Specs(selected:$gamebar)]
}


proc getId {gamebar at} {
	return [set [namespace current]::Specs(lookup:$at:$gamebar)]
}


proc getIndex {gamebar id} {
	variable Specs

	set at 0
	while {$Specs(lookup:$at:$gamebar) != $id} { incr at }
	return $at
}


proc empty? {gamebar} {
	return [expr {[set [namespace current]::Specs(size:$gamebar)] == 0}]
}


proc size {gamebar} {
	return [set [namespace current]::Specs(size:$gamebar)]
}


proc addReceiver {gamebar recv} {
	lappend [namespace current]::Specs(receiver:$gamebar) $recv
}


proc removeReceiver {gamebar recv} {
	variable Specs

	set n [lsearch -exact $Specs(receiver:$gamebar) $recv]
	if {$n >= 0} {
		set Specs(receiver:$gamebar) [lreplace $Specs(receiver:$gamebar) $n $n]
	}
}


proc getText {gamebar {id {}}} {
	variable Specs

	if {[llength $id] == 0} { set id $Specs(selected:$gamebar) }
	return $Specs(data:$id:$gamebar)
}


proc setAlignment {gamebar amounts} {
	variable Specs

	if {$amounts != $Specs(adjustment:$gamebar)} {
		set Specs(adjustment:$gamebar) $amounts
		Layout $gamebar
	}
}


proc getIdList {} {
	variable Specs

	set result {}
	foreach key [array names Specs -glob lookup:*] {
		lappend result $Specs($key)
	}

	return $result
}


proc normalizePlayer {player} {
	set player [string trim $player]
	set player [regsub -all { ,} $player ", "]
	set player [regsub -all {  } $player " "]
	set player [regsub -all {,,} $player ","]
	set player [regsub -all {,([^ ])} $player {, \1}]

	return $player
}


proc Enter {gamebar id {pref {}}} {
	variable Specs
	variable Defaults

	if {[llength $pref] == 0 && $id eq $Specs(selected:$gamebar)} { return }

	# Due to a bug in Tk which sometimes triggers invalid <Enter> events,
	# we have to check whether the mouse pointer is inside the canvas.
	lassign [winfo pointerxy $gamebar] x y
	set x0 [winfo rootx $gamebar]
	set y0 [winfo rooty $gamebar]
	set x1 [expr {$x0 + [winfo width $gamebar]}]
	set y1 [expr {$y0 + [winfo height $gamebar]}]

	if {$x0 > $x || $x > $x1 || $y0 > $y || $y > $y1} { return }

	if {$Specs(state:$id:$gamebar) eq "raised"} {
		$gamebar itemconfigure ${pref}lighter${id} \
			-fill $Defaults(color:darker) \
			-outline $Defaults(color:darker) \
			;
		$gamebar itemconfigure ${pref}darker${id} \
			-fill $Defaults(color:lighter) \
			-outline $Defaults(color:lighter) \
			;
		set Specs(state:$id:$gamebar) "sunken"
	} else {
		foreach item {bg whitebg blackbg} {
			$gamebar itemconfigure $pref$item$id \
				-fill $Defaults(color:active) \
				-outline $Defaults(color:active) \
				;
		}
	}
}


proc Leave {gamebar id {pref {}}} {
	variable Specs
	variable Defaults

	if {[llength $pref] == 0 && $id eq $Specs(selected:$gamebar)} { return }

	if {$Specs(state:$id:$gamebar) eq "sunken"} {
		$gamebar itemconfigure ${pref}lighter${id} \
			-fill $Defaults(color:lighter) \
			-outline $Defaults(color:lighter) \
			;
		$gamebar itemconfigure ${pref}darker${id} \
			-fill $Defaults(color:darker) \
			-outline $Defaults(color:darker) \
			;
		set Specs(state:$id:$gamebar) "raised"
	} else {
		foreach item {bg whitebg blackbg} {
			$gamebar itemconfigure $pref$item$id \
				-fill $Defaults(color:normal) \
				-outline $Defaults(color:normal) \
				;
		}
	}
}


proc Press {gamebar id {pref {}}} {
	variable Defaults
	variable Specs

	::tooltip::tooltip off
	HideTags $gamebar
	if {[llength $pref] == 0 && $id eq $Specs(selected:$gamebar)} { return }

	$gamebar itemconfigure ${pref}lighter${id} \
		-fill $Defaults(color:darker) -outline $Defaults(color:darker)
	$gamebar itemconfigure ${pref}darker${id} \
		-fill $Defaults(color:lighter) -outline $Defaults(color:lighter)
	set Specs(state:$id:$gamebar) "sunken"
}


proc Release {gamebar id {pref {}}} {
	variable Specs

	if {[llength $pref] == 0 && $id eq $Specs(selected:$gamebar)} { return }

	if {$Specs(state:$id:$gamebar) eq "sunken"} {
		Leave $gamebar $id $pref
		if {$pref eq "close:"} {
			remove $gamebar $id
		} else {
			SetSelected $gamebar $id
		}
	}

	::tooltip::tooltip clear input$id
	::tooltip::tooltip clear close:input$id
	::tooltip::tooltip on
	set Specs(state:$id:$gamebar) normal
}


proc ShowTags {gamebar id} {
	variable ::application::database::mc::T_Clipbase
	variable ::application::database::clipbaseName
	variable ::application::database::scratchbaseName
	variable Specs

	if {[llength $Specs(tags:$id:$gamebar)] == 0} { return }

	set dlg $gamebar.tags
	toplevel $dlg -background white -class Tooltip
	wm withdraw $dlg
	if {[tk windowingsystem] eq "aqua"} {
		::tk::unsupported::MacWindowStyle style $dlg help none
	} else {
		wm overrideredirect $dlg true
	}
	wm attributes $dlg -topmost true
	set bg [::tooltip::background]
	set f [frame $dlg.f -takefocus 0 -relief solid -borderwidth 0 -background $bg]
	pack $f -fill x -padx 2 -pady 2

	lassign [::scidb::game::sink? $id] base number
	if {$base ne $scratchbaseName} {
		if {$base eq $clipbaseName} {
			set name $T_Clipbase
		} else {
			set name [::util::databaseName $base]
		}
		append name " (#[expr {$number + 1}])"
		label $f.nhdr -text $name -background $bg -font $Specs(bold:$gamebar)
		grid $f.nhdr -row 1 -column 1 -columnspan 3 -sticky wn
		ttk::separator $f.sep
		grid $f.sep -row 2 -column 1 -columnspan 3 -sticky ew
	}

	set row 3
	foreach pair $Specs(tags:$id:$gamebar) {
		lassign $pair name value
		label $f.n$name -text $name -background $bg
		label $f.v$name -text $value -background $bg

		grid $f.n$name -row $row -column 1 -sticky wn
		grid $f.v$name -row $row -column 3 -sticky wn
		incr row
	}

	grid columnconfigure $f 2 -minsize $::theme::padding
	grid columnconfigure $f {0 4} -minsize 2
	grid rowconfigure $f [list 0 $row] -minsize 2

	::tooltip::popup $gamebar $dlg cursor
}


proc HideTags {gamebar} {
	::tooltip::popdown $gamebar.tags
	catch { destroy $gamebar.tags }
}


proc SetSelected {gamebar id} {
	variable Specs
	variable Defaults
	variable Options

	if {$id eq $Specs(selected:$gamebar)} { return }

	set lighter		$Defaults(color:lighter)
	set darker		$Defaults(color:darker)
	set shadow		$Defaults(color:shadow)
	set normal		$Defaults(color:normal)
	set selected	$Defaults(color:selected)
	set player		$Defaults(color:player)
	set line			$Specs(line:$gamebar)

	set oldid $Specs(selected:$gamebar)
	if {[llength $oldid]} {
		::tooltip::tooltip include $gamebar input$oldid
		::tooltip::tooltip include $gamebar close:input$oldid
		$gamebar itemconfigure lighter$oldid -fill $lighter -outline $lighter
		$gamebar itemconfigure darker$oldid -fill $darker -outline $darker
		if {$Specs(size:$gamebar) > 1} {
			$gamebar itemconfigure digit$oldid -state normal
		}
		if {$line != 0} { $gamebar itemconfigure blackbg$oldid -state hidden }
		$gamebar itemconfigure whiteInput$oldid -state hidden
		$gamebar itemconfigure blackInput$oldid -state hidden
		foreach i {1 2} { $gamebar itemconfigure line$i$oldid -state hidden }
		foreach item {bg whitebg blackbg} {
			$gamebar itemconfigure $item$oldid -fill $normal -outline $normal
		}
		$gamebar itemconfigure white$oldid -font $Specs(font:$gamebar)
		$gamebar itemconfigure black$oldid -font $Specs(font:$gamebar)
		$gamebar itemconfigure whiteCountry$oldid -state hidden
		$gamebar itemconfigure blackCountry$oldid -state hidden
		$gamebar itemconfigure whiteCountryInput$oldid -state hidden
		$gamebar itemconfigure blackCountryInput$oldid -state hidden
		$gamebar itemconfigure hyphen$oldid -state hidden
		$gamebar raise blackbg$oldid
		$gamebar raise black$oldid
		$gamebar raise digit$oldid
		$gamebar raise close$oldid
		$gamebar raise input$oldid
	}

	set Specs(selected:$gamebar) $id

	$gamebar itemconfigure blackbg$id -state normal
	foreach i {1 2} { $gamebar itemconfigure line$i$id -state normal }
	foreach item {bg whitebg blackbg} {
		$gamebar itemconfigure $item$id -fill $selected -outline $selected
	}
	$gamebar itemconfigure white$id -font $Specs(bold:$gamebar)
	$gamebar itemconfigure black$id -font $Specs(bold:$gamebar)
	if {$Options(separateLines)} { set state hidden } else { set state normal }
	$gamebar itemconfigure hyphen$id -state $state
	if {$Options(separateLines)} { set state normal } else { set state hidden }
	$gamebar itemconfigure whiteCountry$id -state $state
	$gamebar itemconfigure blackCountry$id -state $state
	$gamebar itemconfigure whiteCountryInput$id -state $state
	$gamebar itemconfigure blackCountryInput$id -state $state
	$gamebar itemconfigure whiteInput$id -state normal
	$gamebar itemconfigure blackInput$id -state normal
	$gamebar itemconfigure lighter$id -fill $darker -outline $darker
	$gamebar itemconfigure darker$id -fill $shadow -outline $shadow
	$gamebar raise digit$id
	$gamebar raise input$id
	$gamebar raise whiteCountryInput$id
	$gamebar raise blackCountryInput$id
	$gamebar raise whitebg$id
	$gamebar raise white$id
	$gamebar raise whiteInput$id
	$gamebar raise blackbg$id
	$gamebar raise black$id
	$gamebar raise blackInput$id
	$gamebar raise close$id

	ShowAtBottom $gamebar
	foreach recv $Specs(receiver:$gamebar) {
		event generate $recv <<LabelbarSelected>> -data $id
	}

	::tooltip::tooltip exclude $gamebar input$id
	::tooltip::tooltip exclude $gamebar close:input$id
	after 10 { ::tooltip::hide }
}


proc PopupMenu {gamebar} {
	variable Specs
	variable Options

	HideTags $gamebar
	if {$Specs(size:$gamebar) == 0} { return }

	set menu $gamebar.menu
	catch { destroy $menu }
	menu $menu -tearoff 0

	foreach {num text} [list 0 $mc::Players 2 $mc::Event 3 $mc::Site] {
		$menu add radiobutton \
			-label $text \
			-value $num \
			-variable [namespace current]::Specs(line:$gamebar) \
			-command [namespace code [list SelectLine $gamebar]]
	}

	$menu add separator
	foreach item {left center} {
		$menu add radiobutton \
			-label [set ::toolbar::mc::[string toupper $item 0 0]] \
			-value $item \
			-variable [namespace current]::Options(alignment) \
			-command [namespace code [list Layout $gamebar]]
	}

	$menu add separator
	$menu add checkbutton \
		-label $mc::ShowActiveAtBottom \
		-onvalue 1 \
		-offvalue 0 \
		-variable [namespace current]::Options(selectedAtBottom) \
		-command [namespace code [list ShowAtBottom $gamebar]]
	$menu add checkbutton \
		-label $mc::ShowPlayersOnSeparateLines \
		-onvalue 1 \
		-offvalue 0 \
		-variable [namespace current]::Options(separateLines) \
		-command [namespace code [list ShowAtSeparateLines $gamebar]]

	tk_popup $menu {*}[winfo pointerxy .]
}


proc ShowAtSeparateLines {gamebar} {
	variable Specs
	variable Options

	set id $Specs(selected:$gamebar)

	if {$Options(separateLines)} { set state hidden } else { set state normal }
	$gamebar itemconfigure hyphen$id -state $state

	if {$Options(separateLines)} { set state normal } else { set state hidden }
	$gamebar itemconfigure whiteCountry$id -state $state
	$gamebar itemconfigure blackCountry$id -state $state
	$gamebar itemconfigure whiteCountryInput$id -state $state
	$gamebar itemconfigure blackCountryInput$id -state $state

	Layout $gamebar
}


proc ShowAtBottom {gamebar} {
	variable Specs
	variable Options

	if {$Options(selectedAtBottom) && $Specs(size:$gamebar) > 1} {
		set state normal
	} else {
		set state hidden
	}
	$gamebar itemconfigure digit$Specs(selected:$gamebar) -state $state

	Layout $gamebar
}


proc SelectLine {gamebar} {
	variable Specs

	for {set i 0} {$i < $Specs(size:$gamebar)} {incr i} {
		UpdateLine $gamebar $Specs(lookup:$i:$gamebar)
	}

	Layout $gamebar
}


proc UpdateLine {gamebar id} {
	variable Specs

	set line $Specs(line:$gamebar)
	if {$line == 0} { set state normal } else { set state hidden }
	set text [lindex $Specs(data:$id:$gamebar) $line]
	if {$text eq ""} { set text "?" }
	$gamebar itemconfigure white$id -text $text

	if {$id eq $Specs(selected:$gamebar)} {
		set text [lindex $Specs(data:$id:$gamebar) 1]
		if {$text eq ""} { set text "?" }
		$gamebar itemconfigure black$id -text $text
	} else {
		$gamebar itemconfigure black$id -state $state
		$gamebar itemconfigure blackbg$id -state $state
		$gamebar itemconfigure blackInput$id -state $state
	}
}


proc MakeData {info} {
	set white [Normalize [normalizePlayer [::gametable::column $info white]] "N.N."]
	set black [Normalize [normalizePlayer [::gametable::column $info black]] "N.N."]
	set event [Normalize [::gametable::column $info event] "?"]
	set site [Normalize [::gametable::column $info site] "?"]
	set date [::gametable::column $info date]
	set whiteCountry [::gametable::column $info whiteCountry]
	set blackCountry [::gametable::column $info blackCountry]

	if {[llength $date]} {
		if {[llength $site]} { append site ", " }
		append site $date
	}

	return [list $white $black $event $site $whiteCountry $blackCountry]
}


proc Update {gamebar id} {
	variable Specs
	variable Options

	set data [MakeData [::scidb::game::info $id]]
	set Specs(data:$id:$gamebar) $data
	set Specs(tags:$id:$gamebar) [::scidb::game::tags $id]

	$gamebar itemconfigure line1$id -text [lindex $data 2]
	$gamebar itemconfigure line2$id -text [lindex $data 3]

	SetCountryFlag $gamebar $id $data white
	SetCountryFlag $gamebar $id $data black

	UpdateLine $gamebar $id
	Layout $gamebar
}


proc Layout {gamebar} {
	variable Specs
	variable Defaults
	variable Options
	variable icon::15x15::close
	variable icon::15x15::digit

	if {$Specs(size:$gamebar) == 0} {
		set barHeight 1
	} else {
		set line				$Specs(line:$gamebar)
		set padx				$Defaults(padx)
		set pady				$Defaults(pady)
		set digitWidth		[image width $digit(1)]
		set digitHeight	[image height $digit(1)]
		set closeWidth		[image width $close]
		set closeHeight	[image height $close]
		set scrollWidth	17	;# TODO compute scrollbar width
		set closePad		[expr {($scrollWidth - $closeWidth)/2}]
		set rowWidth		[winfo width $gamebar]
		set lineWidth		[expr {$rowWidth - $scrollWidth}]
		set closeOffsX		[expr {$rowWidth - $scrollWidth}]
		set digitOffsX		-1
		set barHeight		0
		set height			0
		set flagSep			5

		set Specs(linewidth:$gamebar) $lineWidth
		set id $Specs(selected:$gamebar)
		set selHeight [expr {2*$pady}]
		if {$Options(selectedAtBottom) && [$gamebar itemcget digit$id -state] eq "normal"} {
			incr selHeight [expr {$digitHeight + 2*$pady}]
		}
		foreach i {1 2} {
			lassign [$gamebar bbox line$i$id] x1 y1 x2 y2
			set height$i [expr {$y2 - $y1}]
			set width$i [expr {min($lineWidth, $x2 - $x1)}]
			incr selHeight [set height$i]
		}
		lassign [$gamebar bbox white$id] x1 y1 x2 y2
		set whiteWd [expr {$x2 - $x1}]
		set width0 $whiteWd
		set height0 [expr {$y2 - $y1}]
		incr selHeight [expr {$y2 - $y1}]
		lassign [$gamebar bbox black$id] x1 y1 x2 y2
		set blackWd [expr {$x2 - $x1}]
		if {$Options(separateLines)} {
			incr selHeight [expr {$y2 - $y1}]
			set width0 [expr {max($width0, $blackWd)}]
			lassign [$gamebar bbox whiteCountry$id] x1 y1 x2 y2
			set flagWd [expr {$x2 - $x1}]
			lassign [$gamebar bbox blackCountry$id] x1 y1 x2 y2
			set flagWd [expr {max($flagWd, $x2 - $x1)}]
			if {$flagWd > 0} { incr flagWd $flagSep }
			set width0 [expr {$width0 - $flagWd}]
		} else {
			lassign [$gamebar bbox hyphen$id] x1 y1 x2 y2
			set hyphenWd [expr {$x2 - $x1}]
			incr width0 $blackWd
			incr width0 $hyphenWd
		}
		if {$Options(separateLines)} {
			foreach i {1 2} { set width0 [expr {max($width0, [set width$i])}] }
			set width1 $width0
			set width2 $width0
		}

		if {$Specs(size:$gamebar) > 1} {
			set id $Specs(lookup:0:$gamebar)

			if {$id eq $Specs(selected:$gamebar)} { set id $Specs(lookup:1:$gamebar) }
			lassign [$gamebar bbox white$id] x1 y1 x2 y2

			set rowHeight	[expr {max($y2 - $y1, $digitHeight, $closeHeight) + 2*$pady + 2}]
			set closeOffsY	[expr {($rowHeight - $closeHeight)/2}]
			set digitOffsY	[expr {($rowHeight - $digitHeight)/2}]
			set whiteOffsY	[expr {($rowHeight - ($y2 - $y1))/2}]
			set blackOffsY	$whiteOffsY
			set barHeight	[expr {$selHeight + ($Specs(size:$gamebar) - 1)*$rowHeight}]
			set maxWidth	0

			if {$Options(alignment) eq "center"} {
				set maxWidth 0
				set colors white
				if {$line == 0} { lappend colors black }

				for {set i 0} {$i < $Specs(size:$gamebar)} {incr i} {
					set id $Specs(lookup:$i:$gamebar)
					foreach color $colors {
						set state [$gamebar itemcget $color$id -state]
						$gamebar itemconfigure $color$id -state normal
						lassign [$gamebar bbox $color$id] x1 y1 x2 y2
						set maxWidth [expr {max($maxWidth, $x2 - $x1)}]
					}
				}
			}

			if {$line == 0} {
				set blackOffsX	[expr {($lineWidth + $digitWidth)/2 + $padx}]
				set digitOffsX	[expr {$blackOffsX - $padx - $digitWidth}]
				set whiteOffsX	$padx

				if {$maxWidth} { set whiteOffsX [expr {max($whiteOffsX, $digitOffsX - $maxWidth - $padx)}] }
				set items {digit white black}
			} else {
				if {$maxWidth} {
					set digitOffsX [expr {max(1, ($lineWidth - $maxWidth - $digitWidth - $padx)/2)}]
					set whiteOffsX [expr {$digitOffsX + $digitWidth + $padx}]
				} else {
					set digitOffsX	$padx
					set whiteOffsX	[expr {$digitOffsX + $digitWidth + $padx}]
				}
				set items {digit white}
			}

			for {set i 0} {$i < $Specs(size:$gamebar)} {incr i} {
				set id $Specs(lookup:$i:$gamebar)

				if {$id ne $Specs(selected:$gamebar)} {
					set maxY [expr {$height + $rowHeight - 1}]

					$gamebar coords lighter$id 0 $height $lineWidth $maxY
					$gamebar coords darker$id 1 [expr {$height + 1}] $lineWidth $maxY
					$gamebar coords bg$id 1 [expr {$height + 1}] [expr {$lineWidth - 2}] [expr {$maxY - 1}]
					$gamebar coords blackbg$id \
						[expr {$digitOffsX - $padx}] [expr {$height + 1}] \
						[expr {$lineWidth - 2}] [expr {$maxY - 1}]
					$gamebar coords input$id 0 $height $lineWidth $maxY

					$gamebar coords close:lighter$id $closeOffsX $height $rowWidth $maxY
					$gamebar coords close:darker$id \
						[expr {$closeOffsX + 1}] [expr {$height + 1}] $rowWidth $maxY
					$gamebar coords close:bg$id \
						[expr {$closeOffsX + 1}] [expr {$height + 1}] [expr {$rowWidth - 2}] [expr {$maxY - 1}]
					$gamebar coords close:input$id $closeOffsX $height $rowWidth $maxY

					$gamebar coords close:icon$id \
						[expr {$closeOffsX + $closePad}] [expr {$height + $closeOffsY}]

					foreach item $items {
						$gamebar coords $item$id [set ${item}OffsX] [expr {$height + [set ${item}OffsY]}]
					}
					$gamebar coords whitebg$id {*}[$gamebar bbox white$id]

					set height [expr {$maxY + 1}]
				} elseif {!$Options(selectedAtBottom)} {
					set selectedX $height
					incr height $selHeight
					incr height [Adjustment $gamebar $barHeight]
				}
			}
		} else {
			set barHeight $selHeight
			set selectedX 0
		}

		if {$digitOffsX == -1 || $line > 0} {
			set digitOffsX [expr {($lineWidth - $digitWidth)/2}]
		}
		if {!$Options(selectedAtBottom)} { set height $selectedX }
		set rowHeight $selHeight
		set adjust [Adjustment $gamebar $barHeight]
		incr barHeight $adjust
		incr rowHeight $adjust

		set id $Specs(selected:$gamebar)
		set maxY [expr {$height + $rowHeight - 1}]
		$gamebar coords lighter$id 0 $height $lineWidth $maxY
		$gamebar coords darker$id 1 [expr {$height + 1}] $lineWidth $maxY
		$gamebar coords bg$id 1 [expr {$height + 1}] [expr {$lineWidth - 2}] [expr {$maxY - 1}]
		$gamebar coords input$id 0 $height $lineWidth $maxY

		$gamebar coords close:lighter$id $closeOffsX $height $rowWidth $maxY
		$gamebar coords close:darker$id [expr {$closeOffsX + 1}] [expr {$height + 1}] $rowWidth $maxY
		$gamebar coords close:bg$id \
			[expr {$closeOffsX + 1}] [expr {$height + 1}] [expr {$rowWidth - 2}] [expr {$maxY - 1}]
		$gamebar coords close:input$id $closeOffsX $height $rowWidth $maxY
		$gamebar coords close:icon$id \
			[expr {$closeOffsX + $closePad}] [expr {$height + ($rowHeight - $closeHeight)/2}]

		if {$Options(selectedAtBottom) && [$gamebar itemcget digit$id -state] eq "normal"} {
			incr height [expr {2*$pady + $adjust/3}]
			$gamebar coords digit$id $digitOffsX $height
			incr height [expr {$pady + $digitHeight + $adjust/3}]
		} else {
			incr height [expr {$pady + $adjust/2}]
		}
		$gamebar coords line1$id [expr {max(2, ($lineWidth - $width1)/2)}] $height
		incr height $height1
		if {$Options(separateLines)} {
			set x [expr {max(2, ($lineWidth - $width0)/2)}]
			if {$flagWd > 0} {
				set fx [expr {$x - $flagWd}]
				$gamebar coords whiteCountry$id $fx $height
				$gamebar coords blackCountry$id $fx [expr {$height + $height0}]
				$gamebar coords whiteCountryInput$id {*}[$gamebar bbox whiteCountry$id]
				$gamebar coords blackCountryInput$id {*}[$gamebar bbox blackCountry$id]
			}
			$gamebar coords white$id $x $height
			incr height $height0
			$gamebar coords black$id $x $height
			incr height $height0
		} else {
			set x [expr {max(2, ($lineWidth - $width0)/2)}]
			$gamebar coords white$id $x $height
			incr x $whiteWd
			$gamebar coords hyphen$id $x $height
			incr x $hyphenWd
			$gamebar coords black$id $x $height
			incr height $height0
		}
		$gamebar coords whitebg$id {*}[$gamebar bbox white$id]
		$gamebar coords blackbg$id {*}[$gamebar bbox black$id]
		$gamebar coords whiteInput$id {*}[$gamebar bbox white$id]
		$gamebar coords blackInput$id {*}[$gamebar bbox black$id]
		$gamebar coords line2$id [expr {max(2, ($lineWidth - $width2)/2)}] $height
		incr height $height2
	}

	set $Specs(height:$gamebar) $barHeight
	$gamebar configure -height $barHeight
}


proc EnterPlayer {gamebar id side} {
	variable Specs
	variable Defaults

	if {$id eq $Specs(selected:$gamebar)} {
		set name [GetPlayerName $gamebar $id $side]

		if {[string length $name]} {
			$gamebar itemconfigure ${side}bg${id} \
				-fill $Defaults(color:player) \
				-outline $Defaults(color:player) \
				;
		}
	}
}


proc LeavePlayer {gamebar id side} {
	variable Specs
	variable Defaults

	if {$id eq $Specs(selected:$gamebar)} {
		$gamebar itemconfigure ${side}bg${id} \
			-fill $Defaults(color:selected) \
			-outline $Defaults(color:selected) \
			;
	}
}


proc EnterFlag {gamebar id side} {
	variable Specs

	if {$id eq $Specs(selected:$gamebar)} {
		set data $Specs(data:$id:$gamebar)
		switch $side {
			white { set countryCode [lindex $data 4] }
			black { set countryCode [lindex $data 5] }
		}
		if {[string length $countryCode]} {
			::tooltip::show $gamebar [::country::name $countryCode]
		}
	}
}


proc LeaveFlag {gamebar id} {
	variable Specs

	if {$id eq $Specs(selected:$gamebar)} {
		::tooltip::hide true
	}
}


proc GetPlayerInfo {gamebar id side} {
	lassign [::scidb::game::sink? $id] base index
	set playerIndex [::scidb::db::fetch ${side}PlayerIndex $base $index]
	return [scidb::db::get playerInfo $playerIndex -1 $base -card -ratings {Elo Elo}]
}


proc GetPlayerName {gamebar id side} {
	return [lindex [GetPlayerInfo $gamebar $id $side] 0]
}


proc ShowPlayer {gamebar id side} {

	set info [GetPlayerInfo $gamebar $id $side]

	if {[string length [lindex $info 0]]} {
		::playertable::showInfo $gamebar $info
	} else {
		ShowTags $gamebar $id
	}
}


proc HidePlayer {gamebar id side} {
	if {[string length [GetPlayerName $gamebar $id $side]]} {
		::playertable::hideInfo $gamebar
	} else {
		HideTags $gamebar
	}
}


proc Adjustment {gamebar height} {
	variable Specs
	variable Options

	# Nobody can understand this!
	# I discovered this computation with trial and error.

	if {$Specs(size:$gamebar) == 1 || !$Options(selectedAtBottom)} {
		set offs 2
	} else {
		set offs 5
	}
	lassign $Specs(adjustment:$gamebar) align delta
	if {$align == 0} { return $adjust }
	incr delta [expr {$offs - $Specs(size:$gamebar)}]
	return [expr {($height + $delta) % $align}]
}


proc SetCountryFlag {gamebar id data side} {
	switch $side {
		white { set countryCode [lindex $data 4] }
		black { set countryCode [lindex $data 5] }
	}
	if {[string length $countryCode] == 0} {
		set icon $::icon::12x12::none
	} else {
		set icon $::country::icon::flag($countryCode)
	}
	$gamebar itemconfigure ${side}Country${id} -image $icon
}


proc Configure {gamebar width} {
	set [namespace current]::Specs(width:$gamebar) $width
	Layout $gamebar
}


proc Normalize {s {default ""}} {
	if {$s eq "?" || $s eq "-" || $s eq ""} { return $default }
	return $s
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 15x15 {

set digit(1) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAACiklEQVQoz12T3WtUVxTFf+fc
	k/nomA9nTKMjSl8KBUlBGguKaSVgWkN86psGmief+xcphbRvhcYYSjAPpmIeoiBNoBBaSDQ6
	TqbEiTP3Y+6955ztQz5au2A/LNZee7NhL8V/oPhLDQ2aqdHPyzPnzxcuFYt6KE3Z39lxzzY2
	8rl22y8Kdfm3/xAnKn+enZ4empuc7L927lzhUDqW2XllWX6YrCw++Hv2XffL7WPzR+Xn9Zs3
	a09u3Dj5CRi+ny0dm+7d9SgloASFY2mp01hY2LkcRl+8DBSranDQ/Do1Vb0YxwHdUPP4d1hZ
	ga++1tyfh04Hul0IQ6FaDfo31mUsis7+aEol+61WMtFqObT2IIIXwbmDzdtbisCAMYLWoBQE
	pjA+0H992oC9nWaO9T8Shj8OgADxGuc1AI03QqCFwAiB9rxtW7JMCIK+GeN9NibesrkZ0943
	VCoaBLwHMLR2HUqB1o5ez7K3l4E4wI8Z59Ih51KsS2ntJgRGYYwAHijR+icDEZx3iORAjkiG
	iO83zuVta5MRrftQKgCnEO9BFYBBrE2Ao2E54lOcT3Eu6hhgLbfJZ0od3Ih4JLBolR/yCBBE
	PCI5XlKcTbAuWdPAnIgnyyOyrIP3XcqliGotAaB2KqFSiVE6xLoueX5U+z8pxaKC5DeQbwoF
	zenTJ9h+Mcn/MXphjd1WTOddgnXxI+dXJ9TBm/0yAv7xwEDfp/V6iXq9zJkzZYaHS/R6nmYz
	pdFIaDRims1oy9r2uHDntQYQvtsFPZ7nbimOHWFoabdTms2Yvb2EMOzR62XkebqsVPeqcOf1
	B8E4ID+oWu3KZLFYuFWpmEvFYlAFeZtl/mmnE829ac4vw8/HqXoPL75d4VPE4doAAAAASUVO
	RK5CYII=
}]

set digit(2) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAACw0lEQVQoz12T3YvUZRzFP8/z
	+83Mzkzz4jru7qwSXgSS9saqtLFRbBBBiGArqEjoIihehX9B19VldB0UvdIW5m0XRSrl6noR
	EUmbI+rMzmi7szPze32e3/fpQjaqz9W5OOfmHI7iX9zyG2OFyR2niwdmTuamJvbrYrFIFEXS
	fbCSXr/5SdZ7+OF02o23/GpL/Da++5ltC4e/rLw6v8evVtEAzqEAB8hwRPTd97fa31w6sffB
	6so/4Zul5lM7ji/8WJt7vp6fbuI/vRc1OQHWQOsu8vMNnLWIUgQ/LQ9aXyzNzwzurfhXdT2v
	qpXPC4/vqsv9Dt7LLyI/XEHdvov2NLz2CnrmWeTrS6AVhV07q9tr9U+XwtFzvs3nTzrcPtte
	w9ea5L338Z3DywSsRa22cB+8A/faoDVOKXJK7XmiXDnlWzhhw4j4l1/xGg00oJ1DZ4LLMmhO
	QhDi7ncQT2P7m0gUkdP6mJ9Ktt+KEPz+B95GH10qPypCHJ4I3oXzuK++xXbWMHGCWd8gcw7r
	OOAnWVZLJCOfWaLeQ5Tfx3k+AoydeRNdrxGfvUAWJxgcKQ7jHOKk7Jss+yu0dsJXGk8pVAYi
	Qv3cIvrI6/QXTuPiGAEMjkSEWIRQsk0fuBYZc0ijQIE4R+nYGxSOHqZz9BSMho92dmCckDgh
	zjJCa69p4GNxjsCkDJIU76UXqJ8/w59n3yIcyxM1xgkfKzHSMMwsQ2MYpimBNR+pi1S8FC4D
	s14hz6HebXLVCv/n+sF5gtYdwsGAyNobd8TMKoAlKrsFLudq1Z1j002KzSlK01MUGttxcULc
	7RG1O4TtDqO1bjcwZm6R0aoGWGDY0jAnxlzJwggbBCQbm4TdHuH6OskowCQJqbFXE6VmFxmt
	/ucYAG9T0k9uGz9SLJWP++XSQZ3P1VCqL6lZDgeDz5bX2hffdaFs+f8GBzds5NtZWWkAAAAA
	SUVORK5CYII=
}]

set digit(3) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAACzElEQVQoz1WTzWscdRjHP7+Z
	2Zns7HTXdFNo1hTWFmwpHqS2OWj1Ug2SBgIVQaH1FG/5A7zoXQUPgpBehYgXhYgVMUSK1iBx
	i0jYbECiEjbZdrux2dnsvP5ePMQEfU7P4fsC3+f7CP47vyMqTmXqYvHirbpbv+JZ3mhG1t9W
	241m3lx8rB5/w5PoI7g4WvwNf/x65fqnU+Wpl+tuHSwwmGPdtmyzHC/fu7N7563wmfDPY3Lx
	1+L4zMmZe9Mnp89urm6ysrBC626LZJAwOjHKpdlLzL47SykosXKw0llqL10Nnw3/EPyMqLrV
	5fmJ+Wuu53J76jaX377MuVfO4dd8wk7I6gerdJtd5r6dQ0vNQndhrfNd5wXHy7xXLde61lVd
	hBbMfD+DcQx9u8+etYc6o7jw/gUa1QZt2ggjcFxnMpgMXneEFDdTlbKerFN1qmCDsQza0uQ6
	J+kmbH+0zanpU+zoHUIVEpkI27VvOjrTkzrXtIYtTjun8YWPEYZGsXEclve0x/m759mSW/Sy
	HkYZjDKTwl6ye17FqxbKBZySg+M72CM2oiDQlkZuScJ3QsQTghOfnIAUdKyRoVSWylVfRhIV
	KVSskLEkizOyJEOmEs5A8HFA+nUKCehEo1ONTvS+A9zP4/yssAUIMMZgKxuRCYQjDu/dN1AA
	HR0S/zW5bwGLRhuyg4wszDiYP4AfoPx3mWq/ir/mM5wfMnJjBDmQ5IOcfJAjB3JR8BUWKT8C
	zxesApVWhfTLlGFzCEDwVMDY7BjeDY9H8SPCOETFal1tqucO6/kFdTQ/lQvlWm2kxnhxnJpf
	Y8wbIzUpD9OH7Ma77Ax3eBA92JP78iXm2LAAeI2/sLgqtVxLVEIkI8I0pBf32I/3iZKILMtQ
	ufrNGlgvMsfG/x4DQHwonMpE5Y3AD94sOaUrru2OCiP6mc5+GSSDzzrNzuf6PZ0f4f8BqdBr
	fyRDEZQAAAAASUVORK5CYII=
}]

set digit(4) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAACwUlEQVQoz3WTS2hdVRSGv332
	Pufmnntzk2hKaLTRog2Y4ECECNWiGEtbpAMFlVJSO+i04EjFgVDQgRNBZ+JEUROlM6Glo3ZQ
	aws1FGlEY5+kyb1pmtK8zms/HcRAHfiNFqx/wb9++AUP8fdVhIr7x+vpMxNJ8sQLkezqA73q
	7J1po/+YNGbp1NDT+C292BpmrrQGevsOfNvq3buvVtuJiB5aAtbOU2RnL3QWTk2MPrd8CyAC
	mL7UHGh2Hzjf6n19n1I1CG1m/7rM6LOHiWvjCOaRUpA2X3tx28DBi79f7nkKIPr1HAIa36SN
	kV3Bdwi+TVne5si7X/L1Vwc37Yl5BAsQFkgbwwOt1qM//fhdpJRxzfEkyP3OLuNkhIzggw/P
	8uYbO9izO9o8DnMIFAQJQZAk6vmRkb63lbViwntNkV9Fyn7OnGlz7fpdvvh8NyF0AAihQ/CS
	4COs2SCEDBnJI0prP2aMJ8tmuXdviROf3OL0z6M4dxfxb7DOLuJ8hDEaXS3jHDjHmKoq94jW
	Dl1Zjr93nRMf99DdvI+uwMkAgK6WcN5hjMcYMCbgfOgRJ6fi2TRNhlvdCXtefcD/sTj3GNZC
	VQWK0rG2ZlZVCGG6KMywjAS/nOsjTRVdNUmSREgFO4fb3L42SJ4HjA3oylOUjjy300oIfvA+
	HNrINN4HnBM4V8e6BnGsgDZ5nmJtjtYWrR1F4VhfN5NRrOxpCOe9D+RFoCh70GYQ657Eul2b
	P5shinIbGxuKlVXNykr5542b5fcC4OSUHAohuqDi7sfr9e3U64Ok6Xa6uvoJoaIslyiKDnm2
	QJYt3s8y/crRY24mAnjrkJsTwr8UvL3kXIm1OZVeIy+WyYsVqipH6wqt7Uyei5ePHnMz/ykG
	wGefCrljqP+dej09HMeNMSVrvT6INe/1b2W5PnnzRmfq/Y+03tL/A1t1dIlnvOWKAAAAAElF
	TkSuQmCC
}]

set digit(5) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAACu0lEQVQoz22Tz2tcVRzFP/e+
	+ybvTZOZmtZgRqxaZRTMwkJMqb8piLRLhWoqqZJlsepG/AvcuHAvKM1CA1m0UIsI0oUGDaiN
	xYF2omJra8mYamOS92bue/fdHy5KRMUDB75wzuFsvkfwHzSv/HiwnaQz99aGplIpR0vYuObt
	creq5v/07lNa94Rtr9g+dlz6fuzZ5s6Tz4w0D98/lIAU/5AD16zlnB4sfrJ6/eWtiX2//N2W
	Xvhm7LmrP/9wMtsMwP9yrirDXDEIM3+srTY7y3sBFF9/KZLA3ERab/e8B+DtUuMjiZeSAIgA
	vwaPFNBO0/GRRmMhe/+9AyopzcFIxYd+dw7pHQDXCXjAAk5ABKgAEpAhoGq1yeGpySMKW80Y
	5+gUmttVBMAHd+7BrK9T27WL5qMHuO+tN9n9yCTSO3Jn6ftApNSM9Kaa8tay0u/zU6HZefgQ
	exc+Yt/6DR7sdqhPH2H5xaN0z57lsrVcMiXBO4Jz+0V05tTaUKMxFjcaRMPDxPUUlSQQxwSl
	CEJgvlpi48QbjC4tQlniBxqb5165qtqotB6TcYyIIqwAFwLCOYgikBIx8RDu8hUoCnxZ4ssC
	Pxj0FfCd1botowgEhOCJnEOYCqFuhavlC8jWOL7fxxuD0xpbFOclMB+8x+Q5ZisjP36C8PkX
	NG6uc9vGJrXPzpG/+jr12VewWU6VZVRZjs2yecHHpyVluQg8FktJo7uCOX2G/sWLCCEYeaDN
	HS9NI59+ihtaszUY4LRe8b3ew7f+79TC3Xi/NKLiVitNaKV1xtM6u5MEEwJrZcGq1qwO+vyW
	55uV1k9ybLYjAXj+hatI+bgN/tvCeQbWkhnDTa3Z1BpdlhhjsMZ0ZVk+wbHZzr+GASDefUeN
	3rVnOq3Vju5Qav9QrBp4n1c+nM/KYn6t1/uwOv6a2fb/BbySaTDs/mIVAAAAAElFTkSuQmCC
}]

set digit(6) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAC9ElEQVQoz1WTTWgcZQCGn++b
	2WQ3SXc2iWmTtsFsjHaDetAm8SAVbCv+hMWjgkbBiwc9aa03EWpBevTgwT8KhSBaRfEglqTR
	ogdNKgbFNGlg1U2yze62zXZmduabme8bT5H6nh5eHt7bK7gt73Ba5A/kn9x3/74ZZ9iZynR1
	DOkgqXtb3uXG781Zd9P96kTymt71xS6823dmqFQunRs7Pnosf8BBCHH7Lv62z98L//y8/M3y
	Cye3TqwBWACnek8PlcqlH+95/O7DlrDQocYZydM33kdhzCHb34kODLlC7mBnrvOZ8cq9X18M
	5m9YJ3lT9Az0fDH+xKEJExh0aBidLhK7MdVvN6h9fw2/6lMoOTQuN8j2Zrtba62HizdHP7E7
	ejuOC1s81m4GxDKheHSEoB6wevYq6JRUg1f1aP52nVQajDBkMpkHh/cOP2unMp3RUcL2H9sU
	Bgr039fP6rk12jUftACTghRgpRiZEngBsR9j2XLGjk0ykRhN42oT3dJ0DXZh5SQPnZmie383
	6oaiemGDlbNXiNoR3nUXg8GQTspYR32xjoiTiFb9FgjBwOEB5l9e4NMHPmPuxXn2FHsovXQI
	r+ES64TEaExq8jIxyc0wUahEEWlFu+4z98Y8jfUGYRjQXG+y8PoPFMsjRGlMnEZEJkJp5dpp
	yqKKVUkKCQKqSxsoo4h1jBQWQgiEkQD/9UorVBIuWlPWVBvJ84nRpKnBq/kcfetRmpUmGo0z
	5vDI20fYXNpk5bsVwkQRxiG+8k/ZJkwvyC7mkeZYlEbUKluszP3J9HtPUThYQHmK9YvrXHr/
	EpEd4QU+KgqX6159VgC80vHqfpmRP2Xz2ZH8YB5nyKEw6NBzxx50pHHrLq1ai53aDjvXdppe
	2zvycfTRFQtgUf/iTorJ88IWE5lO+06700ZYEp1ooiAidAOCWwF+y19yXXf6w+CD1f8dA6BM
	Wd41OPZ0rif3XLY7OyEzYq+UVjNR8a9ey5+t/FX58jyfJ7v+v/QXiNksLzH9AAAAAElFTkSu
	QmCC
}]

set digit(7) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAACwUlEQVQoz22TT2hcVRSHv3vf
	nZk3k2Qydiatf8BA0mLtQiulVrALQRERxCBIA9VIF4JaLRXcqKCIy+LGLGqxSBC0IgqKCxda
	QRfppibYooIBExOTliHWTN7LvPfuffdcF5KK4rc6i+/HjwPnKP7D4kzzcNwaf7I6PHa3NvU2
	Umz4raXvy94vH4jrnb95irDtqu3hpzP1dnP0wbPNWx+YqLX2orRC/eNRJr+SrZ3/ZvnHL4/t
	fy5Zvh6en447N4w99G17z8S+KFJEGrQKKBVQQAgQUIhAsvL16uIPnx0+eCJdMgAhqr/XGLlj
	n2RrDN35Cv9Hu9Vg7cKr1Hfcdkun3fro7Avpvea7U/F9gegRn68jXrF18ThGByLt0ZQoPMde
	n+X2sR2QrRK8olatHDqwt3nElJ4pKS35+iXMcIeoAjoKaC0EVbKwnPDV7DJvnxxHslV8niIu
	pVaNnjDWySHnhf4fP2PkJlSjgTIBIsEo4bV3FnlpskNVurjEYdMuIgEv3GMK69vWCoUt6W9e
	AWsINUPVwKUVy+zlhNPPx9j0d5wTnAPnA15k2LjSb/aLclfFaCKtUApC8HijeOP9Hi8+VkfE
	k5fgPBQukFshy2XLEJjLcrcn0goUSADvNfOrnsuLJdPHh+jnAS9/N1onZIWnX5TzBsU5kXAk
	7dvtXfAMcuqTHs9O7MTpIazLKV2GcyWFFbKiZHOrPKcrhi+ACyKBfhHIpMXFpSYr64qH7z9A
	Ge/GVkbJGCHJDb20YCOxC79ddTP60TcRrTgKXNUmJkQDnPm8y9OP70cPjuNroxR6hEya9MsG
	aRaSjdRPnnyX/Pptf/oyu5WpfxwP7rqrNnQjtYERKvEwiGCza+Rpl/7mlYWNP69NPvVWMfev
	xwCYfkZXdnZaU3HcOFqpDRysVOMBCWSls3M2Tz9cWevOnDhdZNv+X81sbKw3r2brAAAAAElF
	TkSuQmCC
}]

set digit(8) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAC5klEQVQoz1WSX2hbZQDFf9+9
	NzdJS5M0ibXrZMxRWAmWom5a0LEH3USsbDL2IP5lMp/6pojPioioILIXX/wHczBQ3HQ6sCCi
	g6GuMrZO7CZtXTOXNNokN7nfvd/9vu/6oB3uPB04Bw6ccwT/wyIviUwx/2Bu4tYn/a3lnU4u
	UyY2bftH++fkUvOoacvTm3kt3fCLDXJp4OXR4sO1D4f2bn8ou62Kc7OMXllHzl357uqp+Wem
	gjdWbqi/5F8cLT9yx/flmclxL++TuWsMZ3MBsi7EhrQeYOf/xMiE3txiffnEj7t2BG8tuWeZ
	FW4x91llZnKnGxpyMxOwFpJ+voiYW4bza4iRAZxaFfvDKm4lX0gvrE1vD4ofeCon9vqO2GOa
	PawT44wMkrx5FjeyYECYlPTKOrzzAKwGpI7F9zL3Tg+NH3Sf8na8ksGd9IWHZ8C/rYQzNgQX
	mohGCBkX9o2TNvrob5bQ9Q5xvY3G5sRp//nLBX9wvJgdpDBaIV8ZovTePtyJ6o2y0l9bqMNf
	kXQkUauL1DFtHa45sUmGlU2ItSK8vk72uTvRV9sE979Pf8u7yPs+wlwLEIenUI0OymhUatCp
	LTuJMZ1Qx0ijkEaR31+jNXuScLGJjCLk5Sbd2S/xHpsgQhPbhNgmRFZ1PEjnZaK2ucL5b3lB
	iMK1Ma5wcBAI4VES0LeK2Cb/Bml1zgHxiU0tPRXRVSGtL85zy5H96KkKcsQnmapSOjJD59QC
	gZYEiaSXSDq6f0yc5FknxpwBpp2MR3HrCLVXD1DdU8Mr5tGdiM63v7Hy+tf0l1uEQR9p4ou/
	m9bdAuBTnr7dkp7JFPKbcmMl8puGGRgrka0WSGNN3Oggr7Xp1/8mvN7+q6vD3Yc4vuAAHODj
	JQexy2pzzkYJWsbEXYlsdZHtHlEYoZQiMfpi31W7D3F84ebnA2+LR70tw6OP+wO5J7zB7D1e
	1i+kpIFV+ifZC48tN1aPvpCcUBv+fwAf3XM6aZCeyQAAAABJRU5ErkJggg==
}]

set digit(9) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAC3ElEQVQoz1WTzUsrVxjGn8mc
	iRN1NCbxA8dQWjIS/Fjd9i7qQglKN7ZCuioVCkUo2D/BpfuuhSLcCxdKi3TRVREFpRFD18KQ
	+rGoC2NAJ/NxZubMOXOmi0vk9l09ix8PPO/7vAo+mIWFBbXZbH5lWda3xWLxU0JISQjR6/f7
	7Zubm7f7+/snALIBrwzE7u7ux41G4129Xv98ZGQEiqJ86Avf99HpdP48OTn54eDg4F8AUAFg
	Z2fnk42Njb9qtdqioigolUqYnJzExMQEdF1HGIZIkgTlcrlmGMa2aZq/tdttl9TrdWKa5i+V
	SsUMggC1Wg2EENi2jTiOoes6qtUqfN8HpRSzs7OTMzMzPwP4gqytrX2dz+df+74PTdNQLpdx
	eXkJIQSyLEMQBHBdF/Pz83h8fESaptB1fWNvb2+NaJq2zRhDr9eDYRjIsgyUUnDOX/Lm83kY
	hoEgCOD7PqSU0DRtOyelfC2EQLfbxdPTE+7u7rC8vAwAoJQCAJaWljA0NITn52c4jgMpJRRF
	eUWSJBnjnINzDtd1cXx8jJWVFTQaDRQKBXieh6urK0xPTyMIAgghkKYppJTjJE1TlzGmE0Je
	znN2doZWq4VcLgcAmJubQ7/fB+ccQggkSQLGmEvSNP2bMfblAMyyDFJKCCGgqioURcHi4iJs
	2wZjDJxzJEmCOI7bOUrpWykloigCpRTNZhOVSgWapqFUKmF9fR2GYeDi4gJRFCGKIoRhmHme
	90a9v7//x7KsdVVVq4qioFAoYHNzE6urq7AsC47j4PT0FHEcIwxDUEpBKf398PDwJ+L7ftrt
	dr8xTbNVKBSqtm3j4eEBxWIRo6Oj4Jwjy97XWUqJMAw719fXP77U8/b21p2amjoaHh5+pev6
	R4PlpWkKxhjCMEQURfA876zT6Wyen58//u8xAGBsbEzd2tr6bnx8/HvDMD4jhCDLsl6SJC3H
	cX49Ojr6w3EcOeD/AzOHbzmIaYqrAAAAAElFTkSuQmCC
}]

set close [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAAByElEQVQoz5XTvUtcURAF8N/bj6wKQbYQDJHYbCNpA4Kk
	SquvC1ppIQr5DwRJaWGxpYV/hE0gKVIGydYpQliD7Aq6iSESWY0f+96uN4XPjZBEyMDhcpk5
	c86dy0R+x0M8QOTfEfAVLYhm8J7pZ6w9ZmwIAxhEEZc4v4UdDt7x8ilvoPyc7c+En4Q24Qfh
	iHBI2CfsEj4RPhDeEmbYRrmA4SeMjmee8ujhCgXcy1yEzMUlxhnFcAFyRN3ssfmpKbko0qvV
	RCEQRXJTU6IQDNVqvqGbzSUnU0rQiSJhcVFha8tVHLtEL46v74uLOlEkzeplzvrkEIK0WnV/
	YsLAxoZoclJpfl7SaDitVvVCkNwi95XTrMFFve5oaUm33Ta0uqrbbjtaWnJRr+tkNX+QE/rJ
	fKUiXy7rnp/Ll8vylUo/n95FLsWxkc1NZ82mxtycs2bTyOamUhxL7lJOikWDCwtO9vY0l5ed
	vn6tubzsZG/P4MKCpFiUZN94e2AhRZKmdldWhE6HVkuEpF63MzsrVyrppemNcrght/c5bFMp
	IW00XGVu+mi1+u6+X+MQ7cILjl+xXmDtEWM3hO5fzi6+cPCR9WmOb2/Qf2/VL+zs2wNNv5A4
	AAAAAElFTkSuQmCC
}]

} ;# namespace 15x15
} ;# namespace icon
} ;# namespace gamebar

# vi:set ts=3 sw=3:
