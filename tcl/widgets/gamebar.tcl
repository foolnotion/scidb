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
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source game-bar

namespace eval gamebar {
namespace eval mc {

set StartPosition			"Start Position"
set Players					"Players"
set Event					"Event"
set Site						"Site"
set SeparateHeader		"Separate header"
set ShowActiveAtBottom	"Show active game at bottom"
set ShowPlayersOnSeparateLines "Show players on separate lines"
set DiscardChanges		"This game has altered.\n\nDo you really want to discard the changes made to it?"
set DiscardNewGame		"Do you really want to throw away this game?"
set NewGameFstPart		"New"
set NewGameSndPart		"Game"

set LockGame				"Lock Game"
set UnlockGame				"Unlock Game"
set CloseGame				"Close Game"

set GameNew					"New Game"

set AddNewGame				"Save: Add New Game to %s..."
set ReplaceGame			"Save: Replace Game in %s..."
set ReplaceMoves			"Save: Replace Moves Only in Game..."

set Tip(Antichess)		"There is no check, no castling, the king\nis captured like an ordinary piece."
set Tip(Suicide)			"In case of stalemate the side with fewer\npieces will win (according to FICS rules)."
set Tip(Giveaway)			"In case of stalemate the side which is\nstalemate wins (according to international rules)."
#set Tip(AISE)				"In case of stalemate the game is remis\n(according to AISE rules)."
set Tip(Losers)			"The king is like in normal chess, and you can also\nwin by getting checkmated or stalemated."

} ;# namespace mc

array set Defaults {
	background:normal		#d9d9d9
	foreground:normal		black
	background:selected	white
	background:emphasize	linen
	background:active		#efefef
	background:darker		#828282
	background:shadow		#e6e6e6
	background:lighter	white
	background:hilite		#ebf4f5
	foreground:hilite		black
	background:hilite2	cornflowerblue
	foreground:hilite2	white
	foreground:elo			darkblue
	width						18
	padx						5
	pady						3
}

array set Options {
	alignment			center
	separateLines		0
	selectedAtBottom	1
	separateColumn		1
}

array set Specs {
	counter:game 0
}


proc gamebar {path} {
	variable Specs
	variable Defaults

	set font TkTextFont
	set bold [list [font configure $font -family] [font configure $font -size] bold]
	set gamebar [tk::canvas $path -borderwidth 0]

	$gamebar bind header <ButtonPress-3> [namespace code [list PopupMenu $gamebar]]

	bind $gamebar <Destroy> [namespace code [list array unset Specs *:$gamebar]]
	bind $gamebar <Configure> [namespace code { Configure %W %w }]
	bind $gamebar <<LanguageChanged>> [namespace code [list LanguageChanged $gamebar]]
	bind $gamebar <<ThemeChanged>> [namespace code [list Layout $gamebar]]

	set Specs(height:$gamebar) 0
	set Specs(width:$gamebar) 0
	set Specs(selected:$gamebar) {}
	set Specs(size:$gamebar) 0
	set Specs(line:$gamebar) 0
	set Specs(number:$gamebar) 1
	set Specs(width:$gamebar) $Defaults(width)
	set Specs(receiver:$gamebar) {}
	set Specs(font:$gamebar) $font
	set Specs(bold:$gamebar) $bold
	set Specs(adjustment:$gamebar) {1 0 0 0}
	set Specs(linewidth:$gamebar) 0
	set Specs(spacewidth:$gamebar) [font measure $font " "]
	set Specs(player:locked) 0
	set Specs(event:locked) 0

	insert $gamebar -1 -1 {}
	::tooltip::tooltip exclude $gamebar input-1
#	::tooltip::tooltip exclude $gamebar close:input-1

	::scidb::db::subscribe gameInfo [namespace current]::Update $gamebar

	return $path
}


proc add {gamebar id tags} { insert $gamebar end $id $tags }


proc insert {gamebar at id tags} {
	variable Specs
	variable Defaults
	variable Options
	variable icon::15x15::close
	variable icon::15x15::digit	;# alternative: or U+2776, U+2777, ... (or U+278A, U+278B)

	if {$at eq "end"} { set at $Specs(size:$gamebar) }
	set normal $Defaults(background:normal)
	set lighter $Defaults(background:lighter)
	set darker $Defaults(background:darker)
	set foreground $Defaults(foreground:normal)
	set bold $Specs(bold:$gamebar)

	if {$at >= 0} {
		set data [MakeData $gamebar $id $tags]
		set state normal
	} else {
		set data {}
		set state hidden
	}

	$gamebar create rectangle 0 0 0 0 \
		-tags [list lighter$id all$id] \
		-fill $lighter \
		-outline $lighter \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list darker$id all$id] \
		-fill $darker \
		-outline $darker \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list bg$id all$id] \
		-fill $normal \
		-outline $normal \
		-state $state \
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
	$gamebar create text 0 0 \
		-anchor nw \
		-font $Specs(font:$gamebar) \
		-fill $Defaults(foreground:elo) \
		-tags [list whiteElo$id all$id] \
		-state hidden \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-font $Specs(font:$gamebar) \
		-fill $Defaults(foreground:elo) \
		-tags [list blackElo$id all$id] \
		-state hidden \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list hyphen$id all$id] \
		-text " \u2013 " \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill $normal \
		-outline $normal \
		-tags [list whitebg$id all$id] \
		-state $state \
		;
	$gamebar create text 0 0 -anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list white$id all$id] \
		-text [lindex $data 0] \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list whiteInput$id all$id] \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill $normal \
		-outline $normal \
		-tags [list blackbg$id all$id] \
		-state $state \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list black$id all$id] \
		-text [lindex $data 1] \
		-fill $foreground \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list blackInput$id all$id] \
		-state $state \
		;
	$gamebar create image 0 0 \
		-anchor nw \
		-tags [list digit$id all$id] \
		-image $digit([expr {$at < 0 ? 1 : $at + 1}]) \
		-state $state \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list line1$id all$id] \
		-text [lindex $data 2] \
		-fill $foreground \
		-state hidden \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list line1bg$id all$id] \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list line1Input$id all$id] \
		-state $state \
		;
	$gamebar create text 0 0 \
		-anchor nw \
		-justify left \
		-font $Specs(font:$gamebar) \
		-tags [list line2$id all$id] \
		-text [lindex $data 3] \
		-fill $foreground \
		-state hidden \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list input$id all$id] \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list close:lighter$id all$id close$id] \
		-fill $lighter \
		-outline $lighter \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list close:darker$id all$id close$id] \
		-fill $darker \
		-outline $darker \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-tags [list close:bg$id all$id close$id] \
		-fill $normal \
		-outline $normal \
		-state $state \
		;
	$gamebar create image 0 0 \
		-anchor nw \
		-tags [list close:icon$id all$id close$id] \
		-image $close(unlocked) \
		-state $state \
		;
	$gamebar create rectangle 0 0 0 0 \
		-fill {} \
		-outline {} \
		-tags [list close:input$id all$id close$id] \
		-state $state \
		;

	set tag line1Input$id

	$gamebar bind $tag <ButtonPress-2>		[namespace code [list ShowEvent $gamebar $id]]
	$gamebar bind $tag <ButtonRelease-2>	[namespace code [list HideEvent $gamebar $id]]
	$gamebar bind $tag <ButtonPress-3>		[namespace code [list PopupEventMenu $gamebar $id]]

	$gamebar bind $tag <Enter>	[namespace code [list EnterEvent $gamebar $id]]
	$gamebar bind $tag <Leave>	[namespace code [list LeaveEvent $gamebar $id]]

	foreach side {white black} {
		set tag ${side}Input${id}

		$gamebar bind $tag <ButtonPress-1>		[namespace code [list ShowPlayerCard $gamebar $id $side]]
		$gamebar bind $tag <ButtonPress-2>		[namespace code [list ShowPlayerInfo $gamebar $id $side]]
		$gamebar bind $tag <ButtonRelease-2>	[namespace code [list HidePlayerInfo $gamebar $id $side]]
		$gamebar bind $tag <ButtonPress-3>		[namespace code [list PopupPlayerMenu $gamebar $id $side]]

		$gamebar bind $tag <Enter>	[namespace code [list EnterPlayer $gamebar $id $side]]
		$gamebar bind $tag <Leave>	[namespace code [list LeavePlayer $gamebar $id $side]]

		set tag ${side}CountryInput${id}

		$gamebar bind $tag <Enter>					[namespace code [list EnterFlag $gamebar $id $side]]
		$gamebar bind $tag <Leave>					[namespace code [list LeaveFlag $gamebar $id]]
		$gamebar bind $tag <ButtonPress-2>		[namespace code [list ShowPlayerInfo $gamebar $id $side]]
		$gamebar bind $tag <ButtonRelease-2>	[namespace code [list HidePlayerInfo $gamebar $id $side]]
		$gamebar bind $tag <ButtonPress-3>		[namespace code [list PopupMenu $gamebar]]
	}

	set tag ${side}CountryInput${id}

	$gamebar bind $tag <Enter> [namespace code [list EnterFlag $gamebar $id $side]]
	$gamebar bind $tag <Leave> [namespace code [list LeaveFlag $gamebar $id]]
	$gamebar bind $tag <ButtonPress-3> [namespace code [list PopupMenu $gamebar]]

	$gamebar bind close:input$id <ButtonPress-1> [namespace code [list Press $gamebar $id close:]]
	$gamebar bind close:input$id <ButtonRelease-1> [namespace code [list Release $gamebar $id close:]]
	$gamebar bind close:input$id <ButtonPress-2> [namespace code [list ShowTags $gamebar $id]]
	$gamebar bind close:input$id <ButtonRelease-2> [namespace code [list HideTags $gamebar]]
#	$gamebar bind close:input$id <ButtonPress-3> [namespace code [list PopupMenu $gamebar $id]]

	if {$id ne "-1"} {
		$gamebar bind close:input$id <Enter> [namespace code [list Enter $gamebar $id close:]]
		$gamebar bind close:input$id <Leave> [namespace code [list Leave $gamebar $id close:]]
	}

	$gamebar bind input$id <ButtonPress-2> [namespace code [list ShowTags $gamebar $id]]
	$gamebar bind input$id <ButtonRelease-2> [namespace code [list HideTags $gamebar]]

	foreach type {input white black} {
		$gamebar bind $type$id <ButtonPress-1> [namespace code [list Press $gamebar $id]]
		$gamebar bind $type$id <ButtonRelease-1> [namespace code [list Release $gamebar $id]]
		$gamebar bind $type$id <ButtonPress-3> [namespace code [list PopupMenu $gamebar $id]]

		if {$id ne "-1"} {
			$gamebar bind $type$id <Enter> [namespace code [list Enter $gamebar $id]]
			$gamebar bind $type$id <Leave> [namespace code [list Leave $gamebar $id]]
		}
	}

	if {$Specs(size:$gamebar) == 1 && $Options(separateColumn)} {
		PrepareAsHeader $gamebar -1
	}

	set Specs(lookup:$at:$gamebar) $id
	set Specs(emphasize:$id:$gamebar) 0
	if {$at >= 0} {
		incr Specs(size:$gamebar)
		Setup $gamebar $at $id $tags $data
	}

	foreach recv $Specs(receiver:$gamebar) {
		eval $recv inserted $id
	}
}


proc replace {gamebar id tags} {
	variable Specs

	Reset $gamebar $id
	Setup $gamebar [getIndex $gamebar $id] $id $tags [MakeData $gamebar $id $tags]
	$gamebar itemconfigure close:icon$id -image $icon::15x15::close(unlocked)
	Update $gamebar $id no
}


proc remove {gamebar id {update yes}} {
	variable Specs
	variable Options
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
	Reset $gamebar $id

	if {$Specs(size:$gamebar) == 1 && $Options(separateColumn)} {
		foreach item [$gamebar find withtag all-1] {
			$gamebar itemconfigure $item -state hidden
		}
	}

	switch $Specs(size:$gamebar) {
		0 { set Specs(selected:$gamebar) {} }
		1 { $gamebar itemconfigure digit$Specs(lookup:0:$gamebar) -state hidden }
	}

	if {$update} {
		if {$id eq $Specs(selected:$gamebar) && $Specs(size:$gamebar)} {
			if {$at == $Specs(size:$gamebar)} { set at 0 }
			SetSelected $gamebar $Specs(lookup:$at:$gamebar)
		} else {
			set sid $Specs(selected:$gamebar)
			set Specs(selected:$gamebar) {}
			SetSelected $gamebar $sid
		}

		foreach recv $Specs(receiver:$gamebar) {
			eval $recv removed $id
		}
	}
}


proc setState {gamebar id modified} {
	variable Specs

	if {$Specs(modified:$id:$gamebar) != $modified} {
		variable icon::15x15::close

		if {$modified} {
			set state modified
		} elseif {$Specs(locked:$id:$gamebar)} {
			set state locked
		} else {
			set state unlocked
		}

		$gamebar itemconfigure close:icon$id -image $close($state)
		set Specs(modified:$id:$gamebar) $modified
		set Specs(state:$id:$gamebar) $state
		SetTooltip $gamebar $id
	}
}


proc setEmphasized {gamebar flag} {
	variable Specs

	set id $Specs(selected:$gamebar)
	set Specs(emphasize:$id:$gamebar) $flag

	if {[UseSeparateColumn $gamebar]} {
		set Specs(emphasize:-1:$gamebar) $flag
		PrepareAsHeader $gamebar -1
	} else {
		PrepareAsHeader $gamebar $id
	}
}


proc lock {gamebar id} {
	variable Specs

	if {!$Specs(locked:$id:$gamebar)} {
		variable icon::15x15::close

		if {$Specs(modified:$id:$gamebar)} { set state modified } else { set state locked }
		set Specs(locked:$id:$gamebar) 1
		SetState $gamebar $id $state
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


proc locked? {gamebar id} {
	return [set [namespace current]::Specs(locked:$id:$gamebar)]
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

	if {$amounts ne $Specs(adjustment:$gamebar)} {
		set Specs(adjustment:$gamebar) $amounts
		Layout $gamebar
	}
}


proc getIdList {gamebar} {
	variable Specs

	set result {}
	foreach key [array names Specs -glob lookup:*:$gamebar] {
		set id $Specs($key)
		if {$id != -1} {lappend result $id }

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


proc popupMenu {parent {addGameHistory 1} {remove -1}} {
	set menu $parent._gamebar_menu_
	catch { destroy $menu }
	menu $menu -tearoff 0
	AddGameMenuEntries $menu 0 $addGameHistory 2 $remove
	tk_popup $menu {*}[winfo pointerxy .]
}


proc addVariantsToMenu {parent m} {
	foreach variant {ThreeCheck Crazyhouse} {
		$m add command \
			-label " $::mc::VariantName($variant)" \
			-image $::icon::16x16::variant($variant) \
			-compound left \
			-command [list ::menu::gameNew $parent $variant] \
			;
	}
	foreach variant {Losers Suicide Giveaway} {
		set lbl " $::mc::VariantName(Antichess) - $::mc::VariantName($variant)"
		$m add command \
			-label $lbl \
			-command [list ::menu::gameNew $parent $variant] \
			-image $::icon::16x16::variant($variant) \
			-compound left \
			;
		set tip ""
		if {$variant ne "Losers"} { append tip $mc::Tip(Antichess) "\n" }
		append tip $mc::Tip($variant)
		::tooltip::tooltip $m -index $lbl $tip
	}
}


proc UseSeparateColumn {gamebar} {
	variable Specs
	variable Options

	return [expr {$Options(separateColumn) && $Specs(size:$gamebar) > 1}]
}


proc LanguageChanged {gamebar} {
	foreach id [getIdList $gamebar] {
		Update $gamebar $id no
	}
}


proc Reset {gamebar id} {
	variable Specs

	foreach item {data tags state atclose locked modified count} {
		array unset Specs $item:$id:$gamebar
	}
	set Specs(emphasize:$id:$gamebar) 0
}


proc SetState {gamebar id state} {
	variable Specs
	variable icon::15x15::close

	set locked $Specs(locked:$id:$gamebar)
	$gamebar itemconfigure close:icon$id -image $close($state)
	set Specs(state:$id:$gamebar) $state
	set Specs(locked:$id:$gamebar) [expr {$state eq "locked"}]
	SetTooltip $gamebar $id

	if {$locked != $Specs(locked:$id:$gamebar)} {
		foreach recv $Specs(receiver:$gamebar) {
			eval $recv lock $id
		}
	}
}


proc SetTooltip {gamebar id} {
	variable Specs

	switch $Specs(state:$id:$gamebar) {
		unlocked				{ set var LockGame  }
		modified - locked	{ set var CloseGame }
	}

	::tooltip::tooltip $gamebar -item close:input$id [namespace current]::mc::$var
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

	if {$Specs(buttonstate:$id:$gamebar) eq "raised"} {
		$gamebar itemconfigure ${pref}lighter${id} \
			-fill $Defaults(background:darker) \
			-outline $Defaults(background:darker) \
			;
		$gamebar itemconfigure ${pref}darker${id} \
			-fill $Defaults(background:lighter) \
			-outline $Defaults(background:lighter) \
			;
		set Specs(buttonstate:$id:$gamebar) "sunken"
	} else {
		foreach item {bg whitebg blackbg} {
			$gamebar itemconfigure $pref$item$id \
				-fill $Defaults(background:active) \
				-outline $Defaults(background:active) \
				;
		}
	}
}


proc Leave {gamebar id {pref {}}} {
	variable Specs
	variable Defaults

	if {[llength $pref] == 0 && $id eq $Specs(selected:$gamebar)} { return }

	if {$Specs(buttonstate:$id:$gamebar) eq "sunken"} {
		$gamebar itemconfigure ${pref}lighter${id} \
			-fill $Defaults(background:lighter) \
			-outline $Defaults(background:lighter) \
			;
		$gamebar itemconfigure ${pref}darker${id} \
			-fill $Defaults(background:darker) \
			-outline $Defaults(background:darker) \
			;
		set Specs(buttonstate:$id:$gamebar) "raised"
	} else {
		foreach item {bg whitebg blackbg} {
			$gamebar itemconfigure $pref$item$id \
				-fill $Defaults(background:normal) \
				-outline $Defaults(background:normal) \
				;
		}
	}
}


proc Press {gamebar id {pref {}}} {
	variable Defaults
	variable Specs

	::tooltip::tooltip off
	HideTags $gamebar
	if {[llength $pref] == 0 && ($id eq "-1" || $id eq $Specs(selected:$gamebar))} { return }

	$gamebar itemconfigure ${pref}lighter${id} \
		-fill $Defaults(background:darker) -outline $Defaults(background:darker)
	$gamebar itemconfigure ${pref}darker${id} \
		-fill $Defaults(background:lighter) -outline $Defaults(background:lighter)
	set Specs(buttonstate:$id:$gamebar) "sunken"
}


proc Release {gamebar id {pref {}}} {
	variable ::scidb::scratchbaseName
	variable Specs

	if {[llength $pref] == 0 && ($id eq "-1" || $id eq $Specs(selected:$gamebar))} { return }

	if {$Specs(buttonstate:$id:$gamebar) eq "sunken"} {
		Leave $gamebar $id $pref
		if {$pref ne "close:"} {
			SetSelected $gamebar $id
		} elseif {$Specs(state:$id:$gamebar) eq "unlocked"} {
			SetState $gamebar $id locked
		} else {
			if {[lindex [::scidb::game::link? $id] 0] eq $scratchbaseName} {
				set question $mc::DiscardNewGame
			} else {
				set question $mc::DiscardChanges
			}
			set reply yes
			if {$Specs(modified:$id:$gamebar)} {
				set reply [::dialog::question -parent $gamebar -message $question]
			}
			if {$reply eq "yes"} {
				remove $gamebar $id
			}
		}
	}

	::tooltip::tooltip clear input$id
#	::tooltip::tooltip clear close:input$id
	::tooltip::tooltip on

	set Specs(buttonstate:$id:$gamebar) normal
}


proc ShowTags {gamebar id} {
	variable ::application::database::mc::T_Clipbase
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable Specs

	if {$id eq "-1"} { set id $Specs(selected:$gamebar) }
	if {[llength $Specs(tags:$id:$gamebar)] == 0} { return }

	set dlg $gamebar.tags
	set f [::util::makePopup $dlg]
	set bg [$f cget -background]

	lassign [::scidb::game::link? $id] base variant number
	if {$base ne $scratchbaseName} {
		if {$base eq $clipbaseName} {
			set name $T_Clipbase
		} else {
			set name [::util::databaseName $base]
		}
		append name " (#[expr {$number + 1}])"
		if {[::scidb::game::query $id modified?]} { set fg darkred } else { set fg black }
		tk::label $f.nhdr -text $name -background $bg -foreground $fg -font $Specs(bold:$gamebar)
		grid $f.nhdr -row 1 -column 1 -columnspan 3 -sticky wn
		ttk::separator $f.sep
		grid $f.sep -row 2 -column 1 -columnspan 3 -sticky ew
	}

	set row 3
	foreach pair $Specs(tags:$id:$gamebar) {
		lassign $pair name value
		tk::label $f.n$name -text $name -background $bg
		tk::label $f.v$name -text $value -background $bg

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


proc Setup {gamebar at id tags data} {
	variable Options
	variable Specs

	set Specs(data:$id:$gamebar) $data
	set Specs(tags:$id:$gamebar) $tags
	set Specs(buttonstate:$id:$gamebar) normal
	set Specs(atclose:$id:$gamebar) {}
	set Specs(locked:$id:$gamebar) 0
	set Specs(modified:$id:$gamebar) 0
	set Specs(state:$id:$gamebar) unlocked
	set Specs(emphasize:$id:$gamebar) 0

	SetTooltip $gamebar $id
	SetCountryFlag $gamebar $id $data white
	SetCountryFlag $gamebar $id $data black
	ConfigureElo $gamebar $id

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
#	::tooltip::tooltip $gamebar -item close:input$id $tooltip
	set Specs(tooltip:$id:$gamebar) $tooltip

	if {[llength $Specs(selected:$gamebar)] == 0} {
		SetSelected $gamebar $id
	} else {
		# may be set hidden in proc remove
		if {$Specs(size:$gamebar) > 1} {
			$gamebar itemconfigure digit$Specs(lookup:0:$gamebar) -state normal
		}
		if {$Options(separateColumn) && $Specs(size:$gamebar) == 2} {
			SetSelected $gamebar $id
		} else {
#			PrepareAsHeader $gamebar $Specs(selected:$gamebar)
			Update $gamebar $id no
		}
	}
}


proc SetSelected {gamebar id} {
	variable Specs
	variable Options

	if {$id eq $Specs(selected:$gamebar)} { return }
	set oldid $Specs(selected:$gamebar)
	set Specs(selected:$gamebar) $id

	if {[llength $oldid]} {
		PrepareAsButton $gamebar $oldid
		::tooltip::tooltip include $gamebar input$oldid
	}

	::tooltip::tooltip exclude $gamebar input$id

	if {[UseSeparateColumn $gamebar]} {
		set Specs(emphasize:-1:$gamebar) $Specs(emphasize:$id:$gamebar)
		PrepareAsSunkenButton $gamebar $id
		PrepareSeparateColumn $gamebar $id
		PrepareAsHeader $gamebar -1
	} else {
		PrepareAsHeader $gamebar $id
	}

	PrepareDigit $gamebar
	Layout $gamebar

	foreach recv $Specs(receiver:$gamebar) {
		eval $recv select $id
	}
}


proc PrepareAsSunkenButton {gamebar id} {
	variable Defaults
	variable Specs

	set lighter		$Defaults(background:lighter)
	set darker		$Defaults(background:darker)
	set selected	$Defaults(background:active)
	set line			$Specs(line:$gamebar)

	$gamebar itemconfigure lighter$id -fill $darker -outline $darker
	$gamebar itemconfigure darker$id -fill $lighter -outline $lighter
	$gamebar itemconfigure hyphen$id -state hidden
	if {$line != 0} { $gamebar itemconfigure blackbg$id -state hidden }
	$gamebar itemconfigure whiteInput$id -state hidden
	$gamebar itemconfigure blackInput$id -state hidden
	foreach i {1 2} { $gamebar itemconfigure line$i$id -state hidden }
	$gamebar itemconfigure line1Input$id -state hidden
	$gamebar itemconfigure line1bg$id -state hidden
	$gamebar itemconfigure whiteCountry$id -state hidden
	$gamebar itemconfigure blackCountry$id -state hidden
	$gamebar itemconfigure whiteCountryInput$id -state hidden
	$gamebar itemconfigure blackCountryInput$id -state hidden
	$gamebar itemconfigure whiteElo$id -state hidden
	$gamebar itemconfigure blackElo$id -state hidden
	if {$Specs(size:$gamebar) > 1} {
		$gamebar itemconfigure digit$id -state normal
	}
	$gamebar itemconfigure white$id -font $Specs(font:$gamebar)
	$gamebar itemconfigure black$id -font $Specs(font:$gamebar)
	$gamebar raise blackbg$id
	$gamebar raise black$id
	$gamebar raise digit$id
	$gamebar raise close$id
	$gamebar raise input$id

	foreach item {bg whitebg blackbg} {
		$gamebar itemconfigure $item$id -fill $selected -outline $selected
	}
}


proc PrepareAsButton {gamebar id} {
	variable Defaults
	variable Specs

	set lighter	$Defaults(background:lighter)
	set darker	$Defaults(background:darker)
	set normal	$Defaults(background:normal)
	set line		$Specs(line:$gamebar)

	::tooltip::tooltip include $gamebar input$id
	::tooltip::tooltip include $gamebar close:input$id
	$gamebar itemconfigure lighter$id -fill $lighter -outline $lighter
	$gamebar itemconfigure darker$id -fill $darker -outline $darker
	if {$Specs(size:$gamebar) > 1} {
		$gamebar itemconfigure digit$id -state normal
	}
	if {$line != 0} { $gamebar itemconfigure blackbg$id -state hidden }
	$gamebar itemconfigure whiteInput$id -state hidden
	$gamebar itemconfigure blackInput$id -state hidden
	foreach i {1 2} { $gamebar itemconfigure line$i$id -state hidden }
	$gamebar itemconfigure line1Input$id -state hidden
	$gamebar itemconfigure line1bg$id -state hidden
	foreach item {bg whitebg blackbg} {
		$gamebar itemconfigure $item$id -fill $normal -outline $normal
	}
	$gamebar itemconfigure white$id -font $Specs(font:$gamebar)
	$gamebar itemconfigure black$id -font $Specs(font:$gamebar)
	$gamebar itemconfigure whiteCountry$id -state hidden
	$gamebar itemconfigure blackCountry$id -state hidden
	$gamebar itemconfigure whiteCountryInput$id -state hidden
	$gamebar itemconfigure blackCountryInput$id -state hidden
	$gamebar itemconfigure whiteElo$id -state hidden
	$gamebar itemconfigure blackElo$id -state hidden
	$gamebar itemconfigure hyphen$id -state hidden
	$gamebar raise blackbg$id
	$gamebar raise black$id
	$gamebar raise line1$id
	$gamebar raise digit$id
	$gamebar raise close$id
	$gamebar raise input$id
}


proc PrepareAsHeader {gamebar id} {
	variable Defaults
	variable Options
	variable Specs

	if {$Specs(emphasize:$id:$gamebar)} { set color emphasize } else { set color selected }

	set darker		$Defaults(background:darker)
	set shadow		$Defaults(background:shadow)
	set selected	$Defaults(background:$color)

	if {$id eq "-1"} {
		foreach item {	white black lighter darker bg whitebg
							whiteInput blackInput line1 line1Input line1bg line2 input} {
			$gamebar itemconfigure ${item}-1 -state normal
		}
		foreach item {close:lighter close:darker close:bg} {
			$gamebar itemconfigure ${item}-1 -state normal
		}
		foreach item {digit close:icon close:input} {
			$gamebar itemconfigure ${item}-1 -state hidden
		}
	}

	$gamebar itemconfigure blackbg$id -state normal
	foreach i {1 2} { $gamebar itemconfigure line$i$id -state normal }
	$gamebar itemconfigure line1Input$id -state normal
	$gamebar itemconfigure line1bg$id -state normal
	foreach item {bg whitebg blackbg line1bg} {
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
	ConfigureElo $gamebar $id

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
	$gamebar raise line1bg$id
	$gamebar raise line1$id
	$gamebar raise line1Input$id
	$gamebar raise close$id

	if {$id eq $Specs(selected:$gamebar)} {
		::tooltip::tooltip exclude $gamebar -item input$id
#		::tooltip::tooltip exclude $gamebar close:input$id
		after 10 { ::tooltip::hide }
	}
}


proc PrepareSeparateColumn {gamebar id} {
	variable Options
	variable Specs

	$gamebar itemconfigure line1-1 -text [$gamebar itemcget line1$id -text]
	$gamebar itemconfigure line2-1 -text [$gamebar itemcget line2$id -text]
	$gamebar itemconfigure white-1 -text [$gamebar itemcget white$id -text]
	$gamebar itemconfigure black-1 -text [$gamebar itemcget black$id -text]

	if {$Options(separateLines)} {
		foreach {side eloIdx} {white 6 black 7} {
			set country [$gamebar itemcget ${side}Country${id} -image]
			if {[string length $country]} {
				$gamebar itemconfigure ${side}Country-1 -image $country
				$gamebar itemconfigure ${side}Country-1 -state normal
			} else {
				$gamebar itemconfigure ${side}Country-1 -state hidden
			}
			if {[lindex $Specs(data:$id:$gamebar) $eloIdx]} { set state normal } else { set state hidden }
			$gamebar itemconfigure ${side}Elo-1 -state $state
		}
	} else {
		$gamebar itemconfigure whiteCountry-1 -state hidden
		$gamebar itemconfigure blackCountry-1 -state hidden
		$gamebar itemconfigure whiteElo-1 -state hidden
		$gamebar itemconfigure blackElo-1 -state hidden
	}
}


proc ShowSeparateColumn {gamebar {flag -1}} {
	variable Options
	variable Specs

	if {$flag >= 0} {
		if {$flag == $Options(separateColumn)} { return }
		set Options(separateColumn) $flag
	}

	if {[UseSeparateColumn $gamebar]} {
		if {[llength $Specs(selected:$gamebar)]} {
			PrepareAsSunkenButton $gamebar $Specs(selected:$gamebar)
			PrepareSeparateColumn $gamebar $Specs(selected:$gamebar)
		}
		PrepareAsHeader $gamebar -1
	} else {
		if {[llength $Specs(selected:$gamebar)]} {
			PrepareAsHeader $gamebar $Specs(selected:$gamebar)
		}
		foreach item [$gamebar find withtag all-1] {
			$gamebar itemconfigure $item -state hidden
		}
	}

	PrepareDigit $gamebar
	Layout $gamebar
}


proc AddGameMenuEntries {m addSaveMenu addGameHistory clearHistory remove} {
	variable ::game::history::mc::GameHistory

	if {[::game::historyIsEmpty?]} {
		set clearHistory 0
	}

	set sub $m.__history__
	menu $sub -tearoff 0
	$sub configure -disabledforeground black
	set parent [winfo parent $m]

	if {$addGameHistory} {
		set headerScript {
			upvar sub n

			uplevel { incr count }

			$n add command \
				-label [::util::databaseName $base] \
				-background "#d3d3d3" \
				-foreground black \
				-activebackground "#d3d3d3" \
				-activeforeground black \
				-font $::table::options(menu:headerfont) \
				-state disabled \
				;
		}

		set gameScript {
			upvar sub n

			set lbl ""

			append lbl [lindex $tags 4]
			append lbl " - "
			append lbl [lindex $tags 5]

			$n add command \
				-label $lbl \
				-command [list ::game::openGame [winfo parent $n] $index] \
				;
		}

		set count 0
		::game::traverseHistory $headerScript $gameScript

		if {$count > 0} {
			$m add cascade \
				-menu $sub \
				-label " $GameHistory" \
				-image $::icon::16x16::folder \
				-compound left \
				;
		} else {
			destroy $sub
			set clearHistory 0
		}
	}

	if {$clearHistory == 1} {
		$m add command \
			-label " $::game::mc::ClearHistory" \
			-image $::icon::16x16::clear \
			-compound left \
			-command ::game::clearHistory \
			;
		$m add separator
	}

	$m add command \
		-label " $mc::GameNew" \
		-accelerator "Ctrl+X" \
		-image $::icon::16x16::document \
		-compound left \
		-command [list ::menu::gameNew $parent] \
		;

	set sub [menu $m.newGame -tearoff 0]
	addVariantsToMenu $parent $sub
	$m add cascade \
		-menu $sub \
		-label " $mc::GameNew" \
		-image $::icon::16x16::document \
		-compound left \
		;

	$m add command \
		-label " $::import::mc::ImportPgnGame" \
		-image $::icon::16x16::filetypePGN \
		-compound left \
		-command [list ::menu::importGame $parent] \
		;
	
	if {$addSaveMenu && ![::game::trialMode?]} {
		variable ::scidb::scratchbaseName
		variable ::scidb::clipbaseName

		$m add separator
		set position [::scidb::game::current]
		lassign [::scidb::game::link? $position] base variant index
		unset -nocomplain state

		set actual [::scidb::db::get name]

		if {$base ne $scratchbaseName} {
			if {	$index >= 0
				&& [::scidb::db::get open? $base $variant]
				&& ![::scidb::db::get readonly? $base $variant]} {
				set state normal
			} else {
				set state disabled
			}

			if {	$base eq $clipbaseName
				&& [lindex [::scidb::game::sink? $position] 0] eq $scratchbaseName} {
				set state disabled
			}

			set name [::util::databaseName $base]

			$m add command \
				-label " [format $mc::ReplaceGame $name]" \
				-image $::icon::16x16::save \
				-compound left \
				-command [list ::dialog::save::open $parent $base $variant $position [expr {$index + 1}]] \
				-state $state \
				-accel "$::mc::Key(Ctrl)-$::application::board::mc::Accel(replace-game)" \
				;

			if {![::scidb::game::query modified?]} { set state disabled }
			$m add command \
				-label " [format $mc::ReplaceMoves $name]" \
				-image $::icon::16x16::save \
				-compound left \
				-command [list ::application::pgn::replaceMoves $parent] \
				-state $state \
				-accel "$::mc::Key(Ctrl)-$::application::board::mc::Accel(replace-moves)" \
				;
		}

		if {	$actual eq $scratchbaseName
			|| $actual eq $clipbaseName
			|| [::scidb::db::get readonly? $actual]
			|| $variant ni [::scidb::db::get variants $actual]} {
			set state disabled
		} else {
			set state normal
		}
		$m add command \
			-label " [format $mc::AddNewGame [::util::databaseName $actual]]" \
			-image $::icon::16x16::saveAs \
			-compound left \
			-command [list ::dialog::save::open $parent $actual $variant $position] \
			-state $state \
			-accel "$::mc::Key(Ctrl)-$::application::board::mc::Accel(add-new-game)" \
			;

		menu $m.save
		set count 0
		foreach base [::scidb::tree::list] {
			if {	$base ne $actual
				&& ![::scidb::db::get readonly? $base]
				&& $variant in [::scidb::db::get variants $base]} {
				set name [::util::databaseName $base]
				$m.save add command \
					-label $name \
					-command [list ::dialog::save::open $parent $base $variant $position] \
					;
				incr count
			}
		}

		if {$count} { set state normal } else { set state disabled }
		$m add cascade \
			-menu $m.save \
			-label " [format $mc::AddNewGame {}]" \
			-image $::icon::16x16::saveAs \
			-compound left \
			-state $state \
			;
	}

	if {$clearHistory == 2} {
		$m add separator
		if {$remove >= 0} {
			$m add command \
				-label " $::game::mc::RemoveSelectedGame" \
				-image $::icon::16x16::remove \
				-compound left \
				-command [list ::game::removeHistoryEntry $remove] \
				;
		}
		$m add command \
			-label " $::game::mc::ClearHistory" \
			-image $::icon::16x16::clear \
			-compound left \
			-command ::game::clearHistory \
			;
	}
}


proc PopupEventMenu {gamebar id} {
	variable Specs

	set menu $gamebar.menu
	catch { destroy $menu }
	menu $menu -tearoff 0

	lassign [::scidb::game::link? $id] base variant _

	if {[::scidb::db::get open? $base $variant]} {
		set Specs(event:locked) 1
		set name [GetEventName $gamebar $id]
		if {[string length $name]} {
			lassign [::scidb::game::sink? $id] base variant index
			::eventtable::popupMenu $gamebar $menu $base $variant 0 $index game
			$menu add separator
		}
	}

	BuildMenu $gamebar $id {} $menu
}


proc PopupPlayerMenu {gamebar id side} {
	variable Specs

	set menu $gamebar.menu
	catch { destroy $menu }
	menu $menu -tearoff 0

	lassign [::scidb::game::link? $id] base variant _

	if {[::scidb::db::get open? $base $variant]} {
		set Specs(player:locked) 1
		set info [GetPlayerInfo $gamebar $id $side]
		set name [lindex $info 0]
		if {$name eq "?" || $name eq "-"} { set name "" }
		if {[string length $name]} {
			lassign [::scidb::game::sink? $id] base variant gameIndex
			::playertable::popupMenu $menu $base $variant $info [list $gameIndex $side]
			$menu add separator
		}
	}

	BuildMenu $gamebar $id $side $menu
}


proc PopupMenu {gamebar {id -1}} {
	set menu $gamebar.menu
	catch { destroy $menu }
	menu $menu -tearoff 0
	BuildMenu $gamebar $id {} $menu
}


proc BuildMenu {gamebar id side menu} {
	variable Specs
	variable Options

	HideTags $gamebar
	set sid $Specs(selected:$gamebar)
	set current [expr {$id == ($Specs(size:$gamebar) == 1 ? $sid : -1)}]
	set addsep {}

	set end [$menu index end]
	AddGameMenuEntries $menu [expr {$current && $Specs(size:$gamebar) > 0}] 1 0 -1
	if {[$menu index end] ne $end} { set addsep [list $menu add separator] }

	if {$Specs(size:$gamebar) > 0} {
		eval $addsep
		set addsep {}
	
		if {$current && [lindex [::scidb::game::sink? $id] 0] ne $::scidb::scratchbaseName} {
			lassign [::scidb::game::link? $id] base variant index
			if {[::scidb::db::get open? $base $variant] && ![::scidb::db::get readonly? $base $variant]} {
				set flag [::scidb::db::get deleted? $index -1 $base]
				if {$flag} { set var UndeleteGame } else { set var DeleteGame }
				$menu add command \
					-compound left \
					-image $::icon::16x16::remove \
					-label " [set ::gametable::mc::$var]" \
					-command [namespace code [list ::gametable::deleteGame $base $variant $index]] \
					;
				::gametable::addGameFlagsMenuEntry $menu $base $variant -1 $index
				set addsep [list $menu add separator]
			}
		}

		if {$id == -1} { set lid $sid } else { set lid $id }
		if {!$Specs(modified:$lid:$gamebar) && $Specs(state:$lid:$gamebar) ne "modified"} {
			eval $addsep
			set addsep {}
			if {$Specs(locked:$lid:$gamebar)} {
				set count 0
				foreach key [array names Specs -glob locked:*:$gamebar] {
					if {$Specs($key)} { incr count }
				}
				if {$count == $Specs(size:$gamebar)} {
					$menu add command \
						-compound left \
						-image $icon::15x15::close(unlocked) \
						-label " $mc::UnlockGame" \
						-command [namespace code [list SetState $gamebar $lid unlocked]] \
						;
					set addsep [list $menu add separator]
				}
			} else {
				$menu add command \
					-compound left \
					-image $icon::15x15::close(locked) \
					-label " $mc::LockGame" \
					-command [namespace code [list SetState $gamebar $lid locked]] \
					;
					set addsep [list $menu add separator]
			}
		}

#		currently not working
#		foreach {num text} [list 0 $mc::Players 2 $mc::Event 3 $mc::Site] {
#			$menu add radiobutton \
#				-label $text \
#				-value $num \
#				-variable [namespace current]::Specs(line:$gamebar) \
#				-command [namespace code [list SelectLine $gamebar]]
#		}
#		::theme::configureRadioEntry $menu $text
#		$menu add separator

		eval $addsep
		menu $menu.configuration -tearoff no
		$menu add cascade -label $::mc::Configuration -menu $menu.configuration

		menu $menu.configuration.alignment -tearoff no
		$menu.configuration add cascade -label $::mc::Alignment -menu $menu.configuration.alignment

		foreach item {left center} {
			set text [set ::toolbar::mc::[string toupper $item 0 0]]
			$menu.configuration.alignment add radiobutton \
				-label $text \
				-value $item \
				-variable [namespace current]::Options(alignment) \
				-command [namespace code [list Layout $gamebar]]
			::theme::configureRadioEntry $menu.configuration.alignment end
		}

		menu $menu.configuration.layout -tearoff no
		$menu.configuration add cascade -label $::mc::Layout -menu $menu.configuration.layout

		if {$Options(separateColumn)} { set state disabled } else { set state normal }

		$menu.configuration.layout add checkbutton \
			-label $mc::SeparateHeader \
			-onvalue 1 \
			-offvalue 0 \
			-variable [namespace current]::Options(separateColumn) \
			-command [namespace code [list ShowSeparateColumn $gamebar]] \
			;
		$menu.configuration.layout add checkbutton \
			-label $mc::ShowActiveAtBottom \
			-onvalue 1 \
			-offvalue 0 \
			-variable [namespace current]::Options(selectedAtBottom) \
			-command [namespace code [list ShowAtBottom $gamebar]] \
			-state $state \
			;
		$menu.configuration.layout add checkbutton \
			-label $mc::ShowPlayersOnSeparateLines \
			-onvalue 1 \
			-offvalue 0 \
			-variable [namespace current]::Options(separateLines) \
			-command [namespace code [list ShowAtSeparateLines $gamebar]] \
			;
	}

	if {[$menu index end] eq "none"} { return }

	if {$Specs(player:locked)} {
		bind $menu <<MenuUnpost>> [namespace code [list LeavePlayer $gamebar $id $side yes]]
	} elseif {$Specs(event:locked)} {
		bind $menu <<MenuUnpost>> [namespace code [list LeaveEvent $gamebar $id yes]]
	}

	tk_popup $menu {*}[winfo pointerxy .]
}


proc ShowAtSeparateLines {gamebar} {
	variable Specs
	variable Options

	if {[UseSeparateColumn $gamebar]} { set id -1 } else { set id $Specs(selected:$gamebar) }

	if {$Options(separateLines)} { set state hidden } else { set state normal }
	$gamebar itemconfigure hyphen$id -state $state

	if {$Options(separateLines)} { set state normal } else { set state hidden }
	$gamebar itemconfigure whiteCountry$id -state $state
	$gamebar itemconfigure blackCountry$id -state $state
	$gamebar itemconfigure whiteCountryInput$id -state $state
	$gamebar itemconfigure blackCountryInput$id -state $state
	ConfigureElo $gamebar $id

	Layout $gamebar
}


proc ShowAtBottom {gamebar} {
	PrepareDigit $gamebar
	Layout $gamebar
}


proc PrepareDigit {gamebar} {
	variable Options
	variable Specs

	if {($Options(separateColumn) || $Options(selectedAtBottom)) && $Specs(size:$gamebar) > 1} {
		set state normal
	} else {
		set state hidden
	}
	$gamebar itemconfigure digit$Specs(selected:$gamebar) -state $state
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
	variable Options

	set line $Specs(line:$gamebar)
	if {$line == 0} { set state normal } else { set state hidden }
	set white [lindex $Specs(data:$id:$gamebar) $line]
	if {$white eq ""} { set white "?" }
	set black [lindex $Specs(data:$id:$gamebar) 1]
	if {$black eq ""} { set text "?" }
	$gamebar itemconfigure white$id -text $white

	if {![UseSeparateColumn $gamebar] && $id eq $Specs(selected:$gamebar)} {
		$gamebar itemconfigure black$id -text $black
	} else {
		$gamebar itemconfigure black$id -state $state
		$gamebar itemconfigure blackbg$id -state $state
		$gamebar itemconfigure blackInput$id -state $state
	}

	if {$id eq $Specs(selected:$gamebar)} {
		$gamebar itemconfigure white-1 -text $white
		$gamebar itemconfigure black-1 -text $black
	}
}


proc MakeData {gamebar id tags {update no}} {
	variable ::scidb::scratchbaseName
	variable Specs

	lassign {"N.N." "N.N." "?" "?" "" "" "" 0 0} \
		white black event site date whiteCountry blackCountry whiteElo blackElo
	lassign [::scidb::game::link? $id] base _ _

	if {$base eq $scratchbaseName && !$update} {
		if {![info exists Specs(count:$id:$gamebar)]} {
			set Specs(count:$id:$gamebar) [incr Specs(counter:game)]
		}

		set white $mc::NewGameFstPart
		set black $mc::NewGameSndPart
		set event "$::mc::Number $Specs(count:$id:$gamebar)"
		set site  [::locale::formatTime [::game::time? $id]]
		set date  "????.??.??"
	} else {
		foreach pair $tags {
			lassign $pair name value

			switch $name {
				White	{ set white [Normalize [normalizePlayer $value] $white] }
				Black	{ set black [Normalize [normalizePlayer $value] $black] }
				Event	{ set event [Normalize $value $event] }
				Site	{ set site [Normalize $value $site] }
				Date	{ set date $value }
			}
		}

		set whiteCountry [::scidb::game::query $id country white]
		set blackCountry [::scidb::game::query $id country black]
		set whiteElo [::scidb::game::query $id elo white]
		set blackElo [::scidb::game::query $id elo black]

		set date [::locale::formatNormalDate $date]

		if {[string length $date]} {
			if {[string length $site]} { append site ", " }
			append site $date
		}
	}

	return [list $white $black $event $site $whiteCountry $blackCountry $whiteElo $blackElo]
}


proc Update {gamebar id {update yes}} {
	variable Specs
	variable Options

	set tags [::scidb::game::tags $id]
	set data [MakeData $gamebar $id $tags $update]

	set Specs(data:$id:$gamebar) $data
	set Specs(tags:$id:$gamebar) $tags

	$gamebar itemconfigure line1$id -text [lindex $data 2]
	$gamebar itemconfigure line2$id -text [lindex $data 3]
	$gamebar itemconfigure whiteElo$id -text [lindex $data 6]
	$gamebar itemconfigure blackElo$id -text [lindex $data 7]

	$gamebar itemconfigure line1-1 -text [lindex $data 2]
	$gamebar itemconfigure line2-1 -text [lindex $data 3]
	$gamebar itemconfigure whiteElo-1 -text [lindex $data 6]
	$gamebar itemconfigure blackElo-1 -text [lindex $data 7]

	SetCountryFlag $gamebar $id $data white
	SetCountryFlag $gamebar $id $data black
	ConfigureElo $gamebar $id

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
		switch _[::theme::currentTheme] {
			_default	{ set scrollWidth 16 }
			_clam		{ set scrollWidth 15 }
			_alt		{ set scrollWidth 17 }
			default	{ set scrollWidth 17 }
		}

		set spacewidth		$Specs(spacewidth:$gamebar)
		set useSepColumn	[UseSeparateColumn $gamebar]
		set line				$Specs(line:$gamebar)
		set padx				$Defaults(padx)
		set pady				$Defaults(pady)
		set digitWidth		[image width $digit(1)]
		set digitHeight	[image height $digit(1)]
		set closeWidth		[image width $close(unlocked)]
		set closeHeight	[image height $close(unlocked)]
		set closePad		[expr {($scrollWidth - $closeWidth)/2}]
		set rowWidth		[winfo width $gamebar]
		set lineWidth		[expr {$rowWidth - $scrollWidth}]
		set closeOffsX		[expr {$rowWidth - $scrollWidth}]
		set digitOffsX		-1
		set barHeight		0
		set height			0
		set flagSep			5
		set whiteEloWd		0
		set blackEloWd		0

		set Specs(linewidth:$gamebar) $lineWidth
		if {$useSepColumn} { set id -1 } else { set id $Specs(selected:$gamebar) }
		set selHeight [expr {2*$pady}]
		if {	!$useSepColumn
			&& $Options(selectedAtBottom)
			&& [$gamebar itemcget digit$id -state] eq "normal"} {
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
		set height0 [expr {$y2 - $y1}]
		incr selHeight [expr {$y2 - $y1}]
		lassign [$gamebar bbox black$id] x1 y1 x2 y2
		set blackWd [expr {$x2 - $x1}]
		if {$Options(separateLines)} {
			incr selHeight [expr {$y2 - $y1}]
			set flagWd 0
			set flagHt 0
			lassign [$gamebar bbox whiteCountry$id] wx1 wy1 wx2 wy2
			lassign [$gamebar bbox blackCountry$id] bx1 by1 bx2 by2
			if {[llength $wx2]} { set flagWd [expr {$wx2 - $wx1}] }
			if {[llength $bx2]} { set flagWd [expr {max($flagWd, $bx2 - $bx1)}] }
			if {[llength $wy2]} { set flagHt [expr {$wy2 - $wy1}] }
			if {[llength $by2]} { set flagHt [expr {$by2 - $by1}] }
			if {$flagWd > 0} { incr flagWd $flagSep }
			if {[$gamebar itemcget whiteElo$id -state] eq "normal"} {
				lassign [$gamebar bbox whiteElo$id] wx1 _ wx2 _
				set whiteEloWd [expr {$wx2 - $wx1 + $spacewidth}]
			}
			if {[$gamebar itemcget blackElo$id -state] eq "normal"} {
				lassign [$gamebar bbox blackElo$id] wx1 _ wx2 _
				set blackEloWd [expr {$wx2 - $wx1 + $spacewidth}]
			}
			set width0 [expr {$whiteWd + $whiteEloWd}]
			set width0 [expr {max($width0, $blackWd + $blackEloWd)}]
			set width1 [expr {max($width0,$width1)}]
			set width2 [expr {max($width0,$width2)}]
		} else {
			lassign [$gamebar bbox hyphen$id] x1 y1 x2 y2
			set hyphenWd [expr {$x2 - $x1}]
			set width0 [expr {$whiteWd + $hyphenWd + $blackWd}]
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

			if {$useSepColumn} { incr barHeight $rowHeight }

			if {$Options(alignment) eq "center"} {
				set maxWidth 0
				set colors white
#				if {$line == 0} { lappend colors black }

				for {set i 0} {$i < $Specs(size:$gamebar)} {incr i} {
					set id $Specs(lookup:$i:$gamebar)
					foreach color $colors {
						if {$useSepColumn || $id ne $Specs(selected:$gamebar)} {
							set state [$gamebar itemcget $color$id -state]
							$gamebar itemconfigure $color$id -state normal
							lassign [$gamebar bbox $color$id] x1 y1 x2 y2
							set maxWidth [expr {max($maxWidth, $x2 - $x1)}]
						}
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

				if {$useSepColumn || $id ne $Specs(selected:$gamebar)} {
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
		if {!$useSepColumn && !$Options(selectedAtBottom)} { set height $selectedX }
		set rowHeight $selHeight
		set adjust [Adjustment $gamebar $barHeight]
		incr barHeight $adjust
		incr rowHeight $adjust

		if {$useSepColumn} { set id -1 } else { set id $Specs(selected:$gamebar) }
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

		if {	!$useSepColumn
			&& $Options(selectedAtBottom)
			&& [$gamebar itemcget digit$id -state] eq "normal"} {
			incr height [expr {2*$pady + $adjust/3}]
			$gamebar coords digit$id $digitOffsX $height
			incr height [expr {$pady + $digitHeight + $adjust/3}]
		} else {
			incr height [expr {$pady + $adjust/2}]
		}
		set x [expr {max(2, ($lineWidth - $width1)/2)}]
		set x [expr {min($x, max(2, ($lineWidth - $width0)/2))}]
		set x [expr {min($x, max(2, ($lineWidth - $width2)/2))}]
		if {$Options(separateLines)} {
			$gamebar coords line1$id $x $height
		} else {
			$gamebar coords line1$id [expr {max(2, ($lineWidth - $width1)/2)}] $height
		}
		$gamebar coords line1bg$id {*}[$gamebar bbox line1$id]
		$gamebar coords line1Input$id {*}[$gamebar bbox line1$id]
		incr height $height1
		if {$Options(separateLines)} {
			if {$flagWd > 0} {
				set fx [expr {$x - $flagWd}]
				set fy [expr {$height - ($flagHt - $height0)/2}]
				$gamebar coords whiteCountry$id $fx $fy
				$gamebar coords blackCountry$id $fx [expr {$fy + $height0}]
				$gamebar coords whiteCountryInput$id {*}[$gamebar bbox whiteCountry$id]
				$gamebar coords blackCountryInput$id {*}[$gamebar bbox blackCountry$id]
			}
			set eloX [expr {$x + max($whiteWd,$blackWd) + max($whiteEloWd,$blackEloWd) + $spacewidth}]
			if {$whiteEloWd > 0} {
				$gamebar coords whiteElo$id [expr {$eloX - $whiteEloWd}] $height
			}
			$gamebar coords white$id $x $height
			incr height $height0
			if {$blackEloWd > 0} {
				$gamebar coords blackElo$id [expr {$eloX - $blackEloWd}] $height
			}
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
			set x [expr {max(2, ($lineWidth - $width2)/2)}]
		}
		foreach side {white black} {
			$gamebar coords ${side}bg${id} {*}[$gamebar bbox ${side}${id}]
			$gamebar coords ${side}Input${id} {*}[$gamebar bbox ${side}${id}]
		}
		$gamebar coords line2$id $x $height
		incr height $height2
	}

	if {$Specs(height:$gamebar) != $barHeight} {
		set $Specs(height:$gamebar) $barHeight
		$gamebar configure -height $barHeight
	}
}


proc EnterEvent {gamebar id} {
	variable Specs
	variable Defaults

	set sid $Specs(selected:$gamebar)

	if {$id eq $sid || $id eq "-1"} {
		set name [GetEventName $gamebar $sid]

		if {[string length $name]} {
			if {$Specs(emphasize:$id:$gamebar)} { set color hilite2 } else { set color hilite }
			$gamebar itemconfigure line1bg${id} \
				-fill $Defaults(background:$color) \
				-outline $Defaults(background:$color) \
				;
			$gamebar itemconfigure line1${id} -fill $Defaults(foreground:$color)
		}
	}
}


proc LeaveEvent {gamebar id {unlock no}} {
	variable Specs
	variable Defaults

	if {$Specs(event:locked)} {
		if {!$unlock} { return }
		set Specs(event:locked) 0
		if {[winfo containing {*}[winfo pointerxy $gamebar]] eq $gamebar} { return }
	}

	set sid $Specs(selected:$gamebar)

	if {$id eq $sid || $id eq "-1"} {
		if {$Specs(emphasize:$id:$gamebar)} { set color emphasize } else { set color selected }
		$gamebar itemconfigure line1bg${id} \
			-fill $Defaults(background:$color) \
			-outline $Defaults(background:$color) \
			;
		$gamebar itemconfigure line1${id} -fill $Defaults(foreground:normal)
	}
}


proc EnterPlayer {gamebar id side} {
	variable Specs
	variable Defaults

	set sid $Specs(selected:$gamebar)

	if {$id eq $sid || $id eq "-1"} {
		set name [GetPlayerName $gamebar $sid $side]

		if {[string length $name]} {
			if {$Specs(emphasize:$id:$gamebar)} { set color hilite2 } else { set color hilite }
			$gamebar itemconfigure ${side}bg${id} \
				-fill $Defaults(background:$color) \
				-outline $Defaults(background:$color) \
				;
			$gamebar itemconfigure ${side}${id} -fill $Defaults(foreground:$color)
		}
	}
}


proc LeavePlayer {gamebar id side {unlock no}} {
	variable Specs
	variable Defaults

	if {$Specs(player:locked)} {
		if {!$unlock} { return }
		set Specs(player:locked) 0
		if {[winfo containing {*}[winfo pointerxy $gamebar]] eq $gamebar} { return }
	}

	set sid $Specs(selected:$gamebar)

	if {$id eq $sid || $id eq "-1"} {
		if {$Specs(emphasize:$id:$gamebar)} { set color emphasize } else { set color selected }
		$gamebar itemconfigure ${side}bg${id} \
			-fill $Defaults(background:$color) \
			-outline $Defaults(background:$color) \
			;
		$gamebar itemconfigure ${side}${id} -fill $Defaults(foreground:normal)
	}
}


proc EnterFlag {gamebar id side} {
	variable Specs

	set sid $Specs(selected:$gamebar)

	if {$id eq $sid || $id eq "-1"} {
		set data $Specs(data:$sid:$gamebar)
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

	set sid $Specs(selected:$gamebar)
	if {$id eq $sid || $id eq "-1"} { ::tooltip::hide true }
}


proc GetEventInfo {gamebar id} {
	lassign [::scidb::game::sink? $id] base variant index
	return [scidb::db::fetch eventInfo $index $base $variant -card]
}


proc GetEventName {gamebar id} {
	set name [lindex [GetEventInfo $gamebar $id] 0]
	if {$name eq "?" || $name eq "-"} { set name "" }
	return $name
}


proc ShowEvent {gamebar id} {
	variable Specs

	set sid $Specs(selected:$gamebar)
	set info [GetEventInfo $gamebar $sid]
	set name [lindex $info 0]
	if {$name eq "?" || $name eq "-"} { set name "" }

	if {[string length $name]} {
		::eventtable::popupInfo $gamebar $info
	} else {
		ShowTags $gamebar $id
	}
}


proc HideEvent {gamebar id} {
	variable Specs

	set sid $Specs(selected:$gamebar)
	set name [GetEventName $gamebar $sid]

	if {[string length $name]} {
		::eventtable::popdownInfo $gamebar
	} else {
		HideTags $gamebar
	}
}


proc GetPlayerInfo {gamebar id side} {
	lassign [::scidb::game::sink? $id] base variant index
	return [scidb::db::fetch ${side}PlayerInfo $index $base $variant -card -ratings {Any Any}]
}


proc GetPlayerName {gamebar id side} {
	set name [lindex [GetPlayerInfo $gamebar $id $side] 0]
	if {$name eq "?" || $name eq "-"} { set name "" }
	return $name
}


proc ShowPlayerCard {gamebar id side} {
	variable Specs

	set sid $Specs(selected:$gamebar)
	set info [GetPlayerInfo $gamebar $sid $side]
	set name [lindex $info 0]
	if {$name eq "?" || $name eq "-"} { set name "" }

	if {[string length $name]} {
		lassign [::scidb::game::sink? $id] base variant index
		::playercard::show $base $variant $index $side
	}
}


proc ShowPlayerInfo {gamebar id side} {
	variable Specs

	set sid $Specs(selected:$gamebar)
	set info [GetPlayerInfo $gamebar $sid $side]
	set name [lindex $info 0]
	if {$name eq "?" || $name eq "-"} { set name "" }

	if {[string length $name]} {
		::playercard::popupInfo $gamebar $info
	} else {
		ShowTags $gamebar $id
	}
}


proc HidePlayerInfo {gamebar id side} {
	variable Specs

	set sid $Specs(selected:$gamebar)
	set name [GetPlayerName $gamebar $sid $side]

	if {[string length $name]} {
		::playercard::popdownInfo $gamebar
	} else {
		HideTags $gamebar
	}
}


proc Adjustment {gamebar height} {
	variable Specs

	lassign $Specs(adjustment:$gamebar) align incr delta
	set f [expr {($height - $incr - $delta + $align + 3)/$align}]
	set h [expr {$f*$align + $incr + $delta}]
	return [expr {$h - $height}]
}


proc ConfigureElo {gamebar id} {
	variable Specs
	variable Options

	if {$Options(separateLines)} {
		if {$id eq -1} {
			set sid $Specs(selected:$gamebar)
		} else {
			set sid $id
		}
		foreach {side index} {white 6 black 7} {
			set elo [lindex $Specs(data:$sid:$gamebar) $index]

			if {$elo} {
				$gamebar itemconfigure ${side}Elo${id} -text $elo -state normal
			} else {
				$gamebar itemconfigure ${side}Elo${id} -state hidden
			}
		}
	} else {
		$gamebar itemconfigure whiteElo${id} -state hidden
		$gamebar itemconfigure blackElo${id} -state hidden
	}
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
	$gamebar itemconfigure ${side}Country-1 -image $icon
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

set close(locked) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAQAAACR313BAAABG0lEQVQY033RvUpcYRDG8d+7
	ewhRWDQi+BHBJhC1j1iky6YKWOca0tmKIgQrwTI3YRnwDoT0AS2sspATNWJgw/FEN553UngK
	bTJPM8Mzf2aGSeC5OcnDCGdK0oxf76Z3ewtdHV1J1mg0qu9XW1OHybO5z0uvnwqBkFvd+nZ0
	sV6YmJwdF1JrJ922aWzWRIGUJcuSE0myjGO3ItEhhOytTauyVzb1RTusgIwDCz546Y0fDjSy
	0NJZNrCv8l5l30B+aIcszOu50TPf1o/oNRtKO0ob1h7TWdJX2vPFnlJfR+Z+tYis8clfV5KB
	bU+MZBEUhn/O7150nLXHRJuNjM4Nu4s3lz/vVkbFdX2vqr6uq7qqh6e/P05/Tf//2D9rCZCi
	edz4QQAAAABJRU5ErkJggg==
}]

set close(unlocked) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAB3UlEQVQoz6WTu2pUURSGv305
	JxOUDLkNUSMRsfGCYGFnnyJgESsbbfQBrIRgGS2sbAWfwUK0CJbaRQkR3yARx0kcCdEJOWdd
	LOaiEQTBv9mbDWuv/f3r34GB8kxxCjgBBP4uBz7Lbv0JIAPk2XIpz5Sr5cmx+diIhDISxxMh
	B+zQsAPFDgw/NOrO4TYhPJCd6lXIM8Vknh17ceHm5WsTxyYAUFPcHTPD3amlQs0QFfa/79N+
	ufVWutX1DDQbZ8fnpiamUFVCCKSc+PBxc/TWi+cvYW64GbXUpGaek27VzACEENQUgBgCMSbW
	Hj0HYHFlmZwyaooCKSbcPIyYccdMCUQgkGLiSuvqqHNOGXdDB0jo4BzAxalFyCkBiRiOGv5+
	891o35ye/HUpgBu4O09uPTzSEaDzbAuAjc46iyvLqAqu3kcEwBxR4V8kIuDOb8wgKtx9eo+c
	MkUqeHP/NQCtO6ePFquC/cEsKsQQMTeGzg+1sHCm77Yp7Z0vw8ZDZnd3R0yIFtGgbHTWR8WV
	VP3QuOGVDmNKBva0W7d7B71zRVEgorgbNx7fxsxoHB9n99tX3B1VRbo11tM2sNcfdqtcKlrl
	ap4u53FwMVz788fAbbCqYz90W/eln+3/+VU/AUFMEbC3rnm9AAAAAElFTkSuQmCC
}]

# set close(modified) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAQAAACR313BAAABCklEQVQYGQXBwUpUARgG0HPv
# 	XIWInKIEJ51ghmgRtKuNzBsIvUt7l75CLxK4iFbC0Au4qlWUMkJFXiNKx/v9ndOAXRMNACgr
# 	5zTPfDuYHW3vbehsaN1aW1v7efbl8Mlx48Hzd28WdxBEGURce7v8/LozfrxzF0CjjDAY3N8x
# 	7miawjZ+gEf47p80tJSImYWJwcTCTETQEVFO3fPKQ3NXTg2i0FIiLi3deOHG0qVBBC0REVs2
# 	rW3aEhGFlhKDqX29D3r7piKClgjmeie+OtGbIwodVREfDf7il/dGbkUVnb6/WD8duVJKKddK
# 	XPtzoW9e+nQwOxrvlYgSEfH7bHU4PW7ArokGAJSVc/4DwzmFHWb6YYoAAAAASUVORK5CYII=
# }]

# set close(modified) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAABmJLR0QA/wD/AP+gvaeTAAAA
# 	CXBIWXMAAAsTAAALEwEAmpwYAAAByElEQVQoz5XTvUtcURAF8N/bj6wKQbYQDJHYbCNpA4Kk
# 	SquvC1ppIQr5DwRJaWGxpYV/hE0gKVIGydYpQliD7Aq6iSESWY0f+96uN4XPjZBEyMDhcpk5
# 	c86dy0R+x0M8QOTfEfAVLYhm8J7pZ6w9ZmwIAxhEEZc4v4UdDt7x8ilvoPyc7c+En4Q24Qfh
# 	iHBI2CfsEj4RPhDeEmbYRrmA4SeMjmee8ujhCgXcy1yEzMUlxhnFcAFyRN3ssfmpKbko0qvV
# 	RCEQRXJTU6IQDNVqvqGbzSUnU0rQiSJhcVFha8tVHLtEL46v74uLOlEkzeplzvrkEIK0WnV/
# 	YsLAxoZoclJpfl7SaDitVvVCkNwi95XTrMFFve5oaUm33Ta0uqrbbjtaWnJRr+tkNX+QE/rJ
# 	fKUiXy7rnp/Ll8vylUo/n95FLsWxkc1NZ82mxtycs2bTyOamUhxL7lJOikWDCwtO9vY0l5ed
# 	vn6tubzsZG/P4MKCpFiUZN94e2AhRZKmdldWhE6HVkuEpF63MzsrVyrppemNcrght/c5bFMp
# 	IW00XGVu+mi1+u6+X+MQ7cILjl+xXmDtEWM3hO5fzi6+cPCR9WmOb2/Qf2/VL+zs2wNNv5A4
# 	AAAAAElFTkSuQmCC
# }]

set close(modified) $::icon::15x15::close

} ;# namespace 15x15
} ;# namespace icon
} ;# namespace gamebar

# vi:set ts=3 sw=3:
