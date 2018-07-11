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
# Copyright: (C) 2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source application-twm

namespace eval application {
namespace eval twm {
namespace eval mc {

set FoldTitleBar				"Fold Titlebar"
set FoldAllTitleBars			"Fold all Titlebars"
set UnfoldAllTitleBars		"Unfold all Titlebars"
set Notebook					"Notebook"
set Multiwindow				"Multiwindow"
set MoveWindow					"Move Window"
set StayOnTop					"Stay on Top"
set HideWhenLeavingTab		"Hide When Leaving Tab"
set SaveLayout					"Save Layout"
set SaveLayoutAs				"Save Layout as %s"
set RenameLayout				"Rename Layout"
set LoadLayout					"Restore Layout"
set NewLayout					"New Layout"
set ManageLayouts				"Manage Layouts"
set ShowAllDockingPoints	"Show all Docking Points"
set DockingArrowSize			"Docking Arrow Size"
set LinkLayout					"Link Layout '%s'"
set UnlinkLayout				"Unlink Layout '%s'"
set LinkLayoutTip				"Link With Board Layout"
set Actual						"current"
set Windows						"Windows"
set ConfirmDelete				"Really delete layout '%s'?"
set ConfirmOverwrite			"Overwrite existing layout '%s'?"
set LayoutSaved				"Layout '%s' successfully saved"
set EnterName					"Enter Name"

set Pane(analysis)			"Analysis"
set Pane(board)				"Board"
set Pane(editor)				"Notation"
set Pane(tree)					"Tree"
set Pane(games)				"Games"
set Pane(player)				"Players"
set Pane(event)				"Events"
set Pane(annotator)			"Annotator"
set Pane(site)					"Site"
set Pane(position)			"Position"

} ;# namespace mc

# ---------------------------------------------------------------------
# Start of Scidb:
# Load board:layout:list, board:layout:list:* from option file,
# setup twm with board:layout:list.
# ---------------------------------------------------------------------
# Saving layout:
# Set board:layout:list:$variant from board:layout:list.
# Save board:layout:list:$variant, and save board:layout:list:normal
# if not yet existing. Also set board:layout:saved:$variant from
# board:layout:list:$variant.
# ---------------------------------------------------------------------
# Restoring layout:
# Load board:layout:list:* for all saved variants, and set
# board:layout:list from board:layout:list:$variant, or set
# from board:layout:list:normal if former is not existing. Also
# set board:layout:saved:$variant from board:layout:list:$variant.
# ---------------------------------------------------------------------
# Switching variant:
# Set board:layout:list:$variant from board:layout:list.
# Set board:layout:list from board:layout:list:$variant, or set from
# board:layout:list:normal if latter is not existing.
# ------------------------------------------------------------------
# Closing Scidb:
# Set board:layout:list:$variant from board:layout:list, and set
# board:layout:list from board:layout:list:normal, if current
# layout variant is not "normal". Save board:layout:list and all
# board:layout:list:* to option file. Also save all
# board:layout:saved:* to option file.
# ---------------------------------------------------------------------
array set Options {
	board:docking:showall		no
	board:layout:name				""
	board:layout:list				{}
	games:docking:showall		no
	games:layout:name				""
	games:layout:list				{}
	player:docking:showall		yes
	player:layout:name			""
	player:layout:list			{}
	event:docking:showall		yes
	event:layout:name				""
	event:layout:list				{}
	site:docking:showall			yes
	site:layout:name				""
	site:layout:list				{}
	annotator:docking:showall	yes
	annotator:layout:name		""
	annotator:layout:list		{}
	position:docking:showall	yes
	position:layout:name			""
	position:layout:list			{}
}

variable SetupFunc {}
variable LayoutVariants {dropchess antichess}


proc make {twm id makePane buildPane prioArr options layout args} {
	variable [namespace parent]::Vars
	variable Options

	twm::twm $twm \
		-makepane  $makePane \
		-buildpane $buildPane \
		-resizing  [namespace current]::resizing \
		-workarea  [namespace current]::workArea \
		-frameborderwidth 0 \
		{*}$args \
		;
	$twm showall $Options($id:docking:showall)
	pack $twm -fill both -expand yes

	if {$id eq "board"} { bind $twm <<TwmGeometry>> [namespace code [list geometry %d]] }
	bind $twm <<TwmMenu>> [namespace code [list Menu $twm %d %x %y]]

	set Vars($id:prioArr) $prioArr
	set Vars($id:init:options) $options
	set Vars($id:init:layout:name) $layout
	set Vars(id:$twm) $id
	set Vars(twm:$id) $twm
	lappend Vars(twm) $twm

	return $twm
}


proc load {twm} {
	variable [namespace parent]::Vars

	set id $Vars(id:$twm)
	set Vars(loading) 1
	loadInitialLayout $twm
	$twm load [GetLayout $id]
	::options::save $twm $Vars($id:layout:variant)
	set Vars(saved:$id:$Vars($id:layout:variant)) 1
	set Vars(loading) 0
	return $twm
}


proc loadInitialLayout {twm {origTWM ""}} {
	variable [namespace parent]::Vars

	set id $Vars(id:[expr {[string length $origTWM] ? $origTWM : $twm}])
	array set opts $Vars($id:init:options)
	set layout $Vars($id:init:layout:name)
	foreach name [array names opts] {
		set layout [string map [list %${name}% [list $opts($name)]] $layout]
	}
	$twm init $layout
}


proc priority {twm uid} {
	variable [namespace parent]::Vars

	set arrName $Vars($Vars(id:$twm):prioArr)
	return [set ${arrName}([lindex [split $uid :] 0])]
}


proc toLayoutVariant {variant} {
	switch [::util::toMainVariant $variant] {
		Crazyhouse	{ return dropchess }
		Antichess	{ return antichess }
	}
	return normal
}


proc toVariant {layoutVariant} {
	switch $layoutVariant {
		dropchess	{ return DropChess }
		antichess	{ return Antichess }
	}
	return Normal
}


proc makeDir {id layoutVariant} {
	set dir [file join $::scidb::dir::layout $id]
	if {$layoutVariant ne "normal"} { set dir [file join $dir $layoutVariant] }
	return $dir
}


proc makeFilename {id layoutVariant name} {
	return [file join [makeDir $id $layoutVariant] $name.layout]
}


proc workArea {twm} {
	variable [namespace parent]::Vars

	if {[::menu::fullscreen?]} {
		set width [winfo screenwidth .application]
		set height [winfo screenheight .application]
	} else {
		lassign [winfo workarea .application] _ _ ww wh
		lassign [winfo extents .application] ew1 ew2 eh1 eh2
		set width [expr {$ww - $ew1 - $ew2}]
		set height [expr {$wh - $eh1 - $eh2}]
	}
	decr height [::theme::notebookTabPaneSize .application.nb]
	if {$Vars(id:$twm) ne "board"} {
# XXX problem: returns 0 because it is called too early
		decr height [::application::database::switcherSize]
	}
	set bd [expr {2*[::theme::notebookBorderwidth]}]
	decr width $bd
	decr height $bd
	return [list $width $height]
}


proc resizing {twm toplevel width height} {
	variable [namespace parent]::Vars

	if {[::menu::fullscreen?]} {
		set maxwidth [winfo screenwidth .application]
		set maxheight [winfo screenheight .application]
	} else {
		lassign [winfo workarea .application] _ _ ww wh
		lassign [winfo extents .application] ew1 ew2 eh1 eh2
		set maxwidth [expr {$ww - $ew1 - $ew2}]
		set maxheight [expr {$wh - $eh1 - $eh2}]
	}
	set bd [expr {2*[::theme::notebookBorderwidth]}]
	decr maxwidth $bd
	decr maxheight $bd
	decr maxheight [::theme::notebookTabPaneSize .application.nb]
	if {$Vars(id:$twm) ne "board"} {
# XXX problem: returns 0 because it is called too early
		decr maxheight [::application::database::switcherSize]
	}
	set width [expr {min($width, $maxwidth)}]
	set height [expr {min($height, $maxheight)}]
	return [list $width $height]
}


proc geometry {data} {
	variable [namespace parent]::Vars
	variable Geometry

	if {[::menu::fullscreen?]} { return }

	# TODO:
	# Probably we should not resize the main pane after the theme has changed.

	set Geometry $data
	lassign $data width height minwidth minheight maxwidth maxheight expand

	set bd [expr {2*[::theme::notebookBorderwidth]}]
	incr incrH $bd
	incr incrV $bd
	incr incrV [::theme::notebookTabPaneSize .application.nb]
	incr width  $incrH
	incr height $incrV

	if {$minwidth}  { incr minwidth $incrH }
	if {$maxwidth}  { incr maxwidth $incrH }
	if {$minheight} { incr minheight $incrV }
	if {$maxheight} { incr maxheight $incrV }

	if {[::widget::checkIsKDE]} {
		# IMPORTANT NOTE:
		# Without temporarily disabling the resize behavior some window
		# managers like KDE will not shrink the window in any case.
		wm resizable .application false false
	}

	if {$minwidth || $minheight} {
		wm minsize .application $minwidth $minheight
	}
	if {$maxwidth || $maxheight || $Vars(need:maxsize)} {
		# TODO: does this work with multi-screens?
		if {$maxwidth == 0} {
			set maxwidth [winfo screenwidth .application]
		}
		if {$maxheight == 0} {
			set maxwidth [winfo screenheight .application]
		}
		wm maxsize .application $maxwidth $maxheight
		set Vars(need:maxsize) 1
	}
	wm geometry .application ${width}x${height}

	set resizeW [expr {$minwidth == 0 || $minwidth != $maxwidth}]
	set resizeH [expr {$minheight == 0 || $minheight != $maxheight}]

	if {[::widget::checkIsKDE]} {
		# We need a delay, otherwise resizing may not work, see above.
		after 250 [list wm resizable .application $resizeW $resizeH]
	}
}


proc switchLayout {variant reason} {
	variable [namespace parent]::Vars
	variable Options

	set newLayoutVariant [toLayoutVariant $variant]

	foreach twm $Vars(twm) {
		if {[winfo exists $twm]} {
			set id $Vars(id:$twm)
			if {$reason eq "game" ? $id ne "board" : $id eq "board"} { continue }
			if {$newLayoutVariant ne $Vars($id:layout:variant)} {
				set Options($id:layout:list:$Vars($id:layout:variant)) [inspectLayout $twm]
				if {![info exists Options($id:layout:list:$newLayoutVariant)]} {
					set Options($id:layout:list:$newLayoutVariant) $Options($id:layout:list:normal)
				}
				set Options($id:layout:list) $Options($id:layout:list:$newLayoutVariant)
				if {![currentLayoutIsEqTo $twm $Options($id:layout:list) $newLayoutVariant options]} {
					::options::save $twm $Vars($id:layout:variant)
					set Vars(saved:$id:$Vars($id:layout:variant)) 1
					$twm load $Options($id:layout:list)
					if {[info exists Vars(saved:$id:$newLayoutVariant)]} {
						::options::restore $twm $newLayoutVariant
					}
				}
				set Vars($id:layout:variant) $newLayoutVariant
			}
		}
	}
}


proc prepareExit {} {
	variable [namespace parent]::Vars
	variable Options

	foreach twm $Vars(twm) {
		set id $Vars(id:$twm)
		set Options($id:layout:list:$Vars($id:layout:variant)) [inspectLayout $twm]
		set Options($id:layout:list) $Options($id:layout:list:normal)
	}
}


proc setup {layoutVariant id layout} {
	variable [namespace parent]::Vars
	variable SetupFunc

	if {[llength $SetupFunc]} {
		{*}$SetupFunc $layout
	} else {
		RestoreLayout $Vars(twm:$id) $layoutVariant $Vars($id:layout:name) $layout
	}
}


proc loadLayout {twm name} {
	variable [namespace parent]::Vars
	variable Options
	variable LayoutVariants

	set id $Vars(id:$twm)

	if {![file exists [makeFilename $id normal $name]]} {
		# TODO show error message, and clear Options($id:layout:name)
	}

	set layout $Vars($id:layout:name)
	set Vars($id:layout:name) $name
	set loadVariant [CurrentLayoutVariant $id]
	if {$loadVariant ne "normal" && ![file exists [makeFilename $id $loadVariant $name]]} {
		set loadVariant "normal"
	}
	set Vars($id:layout:variant) $loadVariant

	foreach layoutVariant [list normal {*}$LayoutVariants] {
		set file [makeFilename $id $layoutVariant $name]
		if {[file exists $file]} {
			if {[catch { ::load::source $file -encoding utf-8 -throw 1 } -> opts]} {
				return {*}$opts -rethrow 1
			}
		}
	}

	LoadLinkedLayouts $id $name
}


proc inspectLayout {twm} {
	variable [namespace parent]::Vars

	set id $Vars(id:$twm)
	set list {}
	if {$id eq "board"} { set list {Extent} }
	return [$Vars(twm:$id) inspect {*}$list]
}


proc currentLayout {twm} {
	variable [namespace parent]::Vars
	return $Vars($Vars(id:$twm):layout:name)
}


proc currentLayoutIsEqTo {twm layout layoutVariant mode} {
	variable [namespace parent]::Vars

	set currentLayout [inspectLayout $twm]
	# probably ignore float positions
	if {$mode eq "ignore"} { set opts -all } else { set opts {} }
	# TODO: possibly strip "-snapshots {...}" and "-structures {...}",
	# also strip "-x <coord>" and "-y <coord>"
	set lhs [regsub {*}$opts -- {[-][xy]\s\s*[0-9][0-9]*} $currentLayout ""]
	set rhs [regsub {*}$opts -- {[-][xy]\s\s*[0-9][0-9]*} $layout ""]
	set lhs [string map {"  " " "} [string trim $lhs]]
	set rhs [string map {"  " " "} [string trim $rhs]]

	return [expr {	$lhs eq $rhs
					&& (	$mode ne "options"
						|| ![info exists Vars(saved:$Vars(id:$twm):$layoutVariant)]
						|| [::options::compare $twm $layoutVariant])}]
}


proc renameLayout {twm name parent} {
	variable layout_

	SaveLayout $twm $parent [list [namespace current]::RenameLayout $twm $name] $name $mc::RenameLayout
	return $layout_
}


proc deleteLayout {twm name parent} {
	variable [namespace parent]::Vars
	variable Options
	variable LayoutVariants

	if {[::dialog::question \
			-parent $parent \
			-message [format $mc::ConfirmDelete $name] \
			-default no \
		] eq "yes"} {
		set id $Vars(id:$twm)
		set filename [makeFilename $id normal $name]
		file delete $filename
		foreach layoutVariant $LayoutVariants {
			file delete [makeFilename $id $layoutVariant $name]
		}
		if {$Vars($id:layout:name) eq $name} { set Vars($id:layout:name) "" }
		if {$Options($id:layout:name) eq $name} { set Options($id:layout:name) "" }
		if {$id eq "board"} {
			foreach attr [array names Options *:link] {
				if {$Options($attr) eq $name} { array unset Options $attr }
			}
		} else {
			array unset Options $id:$name:link
		}
		return 1
	}
	return 0
}


proc getId {twm} {
	variable [namespace parent]::Vars
	return $Vars(id:$twm)
}


proc makeLayoutMenu {twm menu {w ""}} {
	variable [namespace parent]::Vars
	variable Options
	variable flat_
	variable ismultiwindow_
	variable stayontop_
	variable hide_
	variable layout_

	set id $Vars(id:$twm)
	set count 0

	if {[string length $w]} {
		set flat_ [$twm get! $w flat -1]

		if {$flat_ != -1 && ![$twm ismetachild $w]} {
			$menu add checkbutton \
				-label " $mc::FoldTitleBar" \
				-variable [namespace current]::flat_ \
				-command [list $twm togglebar $w] \
				;
			::theme::configureCheckEntry $menu
			incr count
		}

		set v $w
		if {!([$twm ismultiwindow $w] || [$twm isnotebook $w])} { set v [$twm parent $w] }
		if {[$twm ismultiwindow $v] || [$twm isnotebook $v]} {
			if {$count} { $menu add separator }
			set ismultiwindow_ [$twm ismultiwindow $v]
			$menu add radiobutton \
				-label " $mc::Multiwindow" \
				-variable [namespace current]::ismultiwindow_ \
				-value 1 \
				-command [list $twm togglenotebook $v] \
				;
			::theme::configureRadioEntry $menu
			$menu add radiobutton \
				-label " $mc::Notebook" \
				-variable [namespace current]::ismultiwindow_ \
				-value 0 \
				-command [list $twm togglenotebook $v] \
				;
			::theme::configureRadioEntry $menu
			incr count
		}
	}

	set unfolded [lmap v [$twm find flat 0] { expr {[$twm ismetachild $v] ? [continue] : $v}}]
	set folded [lmap v [$twm find flat 1] { expr {[$twm ismetachild $v] ? [continue] : $v}}]
	if {[llength $unfolded] || [llength $folded]} {
		if {$count} { $menu add separator }
		$menu add command \
			-label " $mc::FoldAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list [namespace current]::ToggleTitlebars $twm $unfolded] \
			-state [expr {[llength $unfolded] ? "normal" : "disabled"}] \
			;
		$menu add command \
			-label " $mc::UnfoldAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list [namespace current]::ToggleTitlebars $twm $folded] \
			-state [expr {[llength $folded] ? "normal" : "disabled"}] \
			;
		incr count
	}

	if {[llength [set floats [$twm floats]]]} {
		if {$count} { $menu add separator }
		menu $menu.stayontop
		$menu add cascade \
			-menu $menu.stayontop \
			-label " $mc::StayOnTop" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach v $floats {
			set stayontop_($v) [$twm get! $v stayontop 0]
			$menu.stayontop add checkbutton \
				-label [set [$twm get [$twm leader $v] name]] \
				-variable [namespace current]::stayontop_($v) \
				-command [namespace code [list StayOnTop $twm $v]] \
				;
			::theme::configureCheckEntry $menu.stayontop
		}
		menu $menu.hide
		$menu add cascade \
			-menu $menu.hide \
			-label " $mc::HideWhenLeavingTab" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach v $floats {
			set hide_($v) [$twm get! $v hide 0]
			$menu.hide add checkbutton \
				-label [set [$twm get [$twm leader $v] name]] \
				-variable [namespace current]::hide_($v) \
				-command [namespace code [list HideWhenLeavingTab $twm $v]] \
				;
			::theme::configureCheckEntry $menu.hide
		}
		if {"editor" in [$twm leaves]} {
			set editor [$twm leaf editor]
			if {[$twm ismetachild $editor]} { set editor [$twm parent $editor] }
			set i [lsearch $floats $editor]
			if {$i >= 0} { set floats [lreplace $floats $i $i] }
		}
		if {[llength $floats] > 0} {
			menu $menu.close
			$menu add cascade \
				-menu $menu.close \
				-label " $::mc::Close" \
				-image $::icon::16x16::close \
				-compound left \
				;
			foreach v $floats {
				$menu.close add command \
					-label [set [$twm get [$twm leader $v] name]] \
					-image $::icon::16x16::none \
					-compound left \
					-command [list $twm close $v] \
					;
			}
		}
		incr count
	}

	array set opts $Vars($id:init:options)
	set leaves1 [lmap uid [array names opts] {
		expr {$uid ni {board analysis editor} && $uid ne $id ? $uid : [continue]}
	}]
	set leaves2 [lmap uid [$twm leaves] {
		expr {[string match {analysis:*} $uid] && [$twm isdocked $uid] ? $uid : [continue]}
	}]
	if {[llength $leaves1] || [llength $leaves2]} {
		if {$count} { $menu add separator }
		menu $menu.windows
		$menu add cascade \
			-menu $menu.windows \
			-label " $mc::Windows" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach uid $leaves1 {
			variable vis_${uid}_ [$twm isdocked $uid]
			$menu.windows add checkbutton \
				-label $mc::Pane($uid) \
				-variable [namespace current]::vis_${uid}_ \
				-command [namespace code [list ChangeState $twm $uid]] \
				;
			::theme::configureCheckEntry $menu.windows
		}
		foreach uid $leaves2 {
			variable [namespace parent]::MapTerminalToAnalysis
			variable [namespace parent]::NameVar
			variable vis_${uid}_ 1
			$menu.windows add checkbutton \
				-label $NameVar($MapTerminalToAnalysis([[namespace parent]::NumberFromUid $uid])) \
				-variable [namespace current]::vis_${uid}_ \
				-command [namespace code [list ChangeState $twm $uid]] \
				;
			::theme::configureCheckEntry $menu.windows
		}
		incr count

#		if {[string length $w] && [$twm get $w move 0]} {
#			set hidden [$twm hidden $w]
#			if {[llength $hidden]} {
#				menu $menu.move
#				$menu add cascade -menu $menu.move -label $mc::MoveWindow
#				foreach v $hidden {
#					$menu.move add command \
#						-label [set [$twm get [$twm leader $v] name]] \
#						-command [namespace code [list MoveWindow $twm $w $v]] \
#						;
#				}
#			}
#			incr count
#		}
	}

	if {$count} { $menu add separator }
	set names [glob $id]
	if {[llength $names]} {
		menu $menu.load
		$menu add cascade \
			-menu $menu.load \
			-label " $mc::LoadLayout" \
			-image $::icon::16x16::layout \
			-compound left \
			;
		foreach name $names {
			set lbl $name
			if {$name eq $Options($id:layout:name)} { append lbl " ($mc::Actual)" }
			$menu.load add command \
				-label $lbl \
				-image $::icon::16x16::none \
				-compound left \
				-command [namespace code [list loadLayout $twm $name]] \
				;
		}
	}
	set labelName " $mc::SaveLayoutAs"
	set state "disabled"
	if {[string length $Vars($id:layout:name)]} {
		if {$Vars($id:layout:name) ni $names} {
			set Vars($id:layout:name) ""
			set Options($id:layout:name) ""
		} else {
			set layoutVariant $Vars($id:layout:variant)
			if {![info exists Options($id:layout:list:$layoutVariant)]} { set layoutVariant normal }
			set list $Options($id:layout:list:$layoutVariant)
			if {![currentLayoutIsEqTo $twm $list $layoutVariant options]} { set state normal }
			set labelName [string map [list "%s" "\"$Vars($id:layout:name)\""] $labelName]
			if {$layoutVariant ne "normal"} {
				append labelName " \[$::mc::VariantName([toVariant $layoutVariant])\]"
			}
		}
	}
	set layout_ $Vars($id:layout:name)
	if {[string length $layout_]} {
		$menu add command \
			-label $labelName \
			-image $::icon::16x16::save \
			-compound left \
			-command [namespace code [list DoSaveLayout $twm $twm $layoutVariant $names]] \
			-state $state \
			;
	}
	$menu add command \
		-label " $mc::SaveLayout..." \
		-image $::icon::16x16::saveAs \
		-compound left \
		-command [namespace code [list SaveLayout \
				$twm $twm [namespace current]::DoSaveLayout "" $mc::SaveLayout]]
		;

	if {$id ne "board" && [string length [set current $Vars($id:layout:name)]] > 0} {
		set names [glob board]
		if {[llength $names]} {
			menu $menu.link
			$menu add cascade \
				-menu $menu.link \
				-label " [format $mc::LinkLayout $current]" \
				-image $::icon::16x16::none \
				-compound left \
				;
			tooltip::tooltip $menu -index [$menu index end] $mc::LinkLayoutTip
			set state [expr {[info exists Options($id:$current:link)] ? "normal" : "disabled"}]
			foreach name $names {
				$menu.link add radiobutton \
					-label $name \
					-variable [namespace current]::Options($id:$current:link) \
					-value $name \
					;
				::theme::configureRadioEntry $menu.link
			}
			$menu add command \
				-label " [format $mc::UnlinkLayout $current]" \
				-image $::icon::16x16::none \
				-compound left \
				-command [list array unset [namespace current]::Options $id:$current:link] \
				-state $state \
				;
			bind $menu <<MenuUnpost>> [namespace code [list CheckLink $id:$current]]
		}
	}

	set n 0
	lmap uid [$twm leaves] { expr {[$twm isundockable $uid] ? [incr n] : [continue]} }
	if {$n > 0} {
		set link ""
		set cur $Vars($id:layout:name)
		if {[info exists Options($id:$cur:link)]} { set link $Options($id:$cur:link) }
		set cmd [list [namespace parent]::layout::open $twm $id $Vars($id:layout:variant) $cur $link]
		$menu add command \
			-label " $mc::ManageLayouts..." \
			-image $::icon::16x16::setup \
			-compound left \
			-command $cmd \
			-state [expr {[llength $names] ? "normal" : "disabled"}] \
			;

		$menu add separator
		$menu add checkbutton \
			-label " $mc::ShowAllDockingPoints" \
			-variable [namespace parent]::Options($id:docking:showall) \
			-command [namespace code [list ShowAllDockingPoints $twm]] \
			;
		::theme::configureCheckEntry $menu

		$menu add separator
		menu $menu.size
		$menu add cascade \
			-menu $menu.size \
			-label " $mc::DockingArrowSize" \
			-image $::icon::16x16::none \
			-compound left \
			;
		foreach {size pixels} {Small 16 Medium 24 Large 32} {
			$menu.size add radiobutton \
				-label " [set ::toolbar::mc::$size]" \
				-variable ::twm::Defaults(cross:size) \
				-value $pixels \
				;
			::theme::configureRadioEntry $menu.size
		}
	}
}


proc glob {id} {
	set files [::glob -nocomplain -directory [makeDir $id normal] *.layout]
	return [lsort -dictionary [lmap f $files {file tail [file rootname $f]}]]
}


proc setLink {id name link} {
	variable Options

	if {[string length $link] == 0} {
		array unset Options $id:$name:link
	} else {
		set Options($id:$name:link) $link
	}
}


proc restoreLayout {twm layoutVariant name list} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars(id:$twm)
	set Vars(loading) 1
	$Vars(twm:$id) load $list
	if {[info exists Vars(saved:$id:$layoutVariant)]} {
		::options::restore $twm $layoutVariant
	}
	set Vars(loading) 0
	set Vars($id:layout:name) $name
	set Options($id:layout:name) $name
	set Options($id:layout:list) $list
	set Options($id:layout:list:$layoutVariant) $list
	set Options($id:layout:saved:$layoutVariant) $list
}


proc StayOnTop {twm w} {
	variable stayontop_

	$twm set! $w stayontop $stayontop_($w)
	if {$stayontop_($w)} {
		set master [winfo toplevel $twm]
		wm transient $w $master
		raise $w $master
		# NOTE: not every window manager is re-decorating the window.
		catch { wm attributes $w -type dialog }
	} else {
		wm transient $w ""
	}
}


proc HideWhenLeavingTab {twm w} {
	variable hide_
	$twm set! $w hide $hide_($w)
}


# NOTE: unused
proc MoveWindow {twm w recv} {
	$twm undock -temporary $w
	$twm dock $w $recv left
}


proc ChangeState {twm uid} {
	variable [namespace parent]::Vars

	if {[$twm isdocked $uid]} {
		destroy [$twm leaf $uid]
	} else {
		set id $Vars(id:$twm)
		array set opts $Vars($id:init:options)
		$twm new frame $uid $opts($uid)
	}
}


proc RestoreLayout {twm layoutVariant name list} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars(id:$twm)

	if {$layoutVariant eq $Vars($id:layout:variant)} {
		set Vars(loading) 1
		::options::save $twm $layoutVariant
		set Vars(saved:$id:$layoutVariant) 1
		$Vars(twm:$id) load $list
		# here we don't have to restore
		set Vars(loading) 0
		set Vars($id:layout:name) $name
		set Options($id:layout:name) $name
		set Options($id:layout:list) $list
	}

	set Options($id:layout:list:$layoutVariant) $list
	set Options($id:layout:saved:$layoutVariant) $list
}


proc CheckLink {attr} {
	variable Options

	if {[info exists Options($attr:link)] && [string length $Options($attr:link)] == 0} {
		array unset Options $attr:link
	}
}


proc SaveLayout {twm parent cmd name title} {
	variable [namespace parent]::Vars
	variable layout_

	set myName $name
	set layout_ $name
	if {[string length $layout_] == 0} { set layout_ $mc::NewLayout }
	set id $Vars(id:$twm)
	set names [glob $id]
	set dlg [tk::toplevel $parent.save -class Scidb]
	pack [set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]]
	set cb [ttk::combobox $top.input \
		-height 10 \
		-width 40 \
		-textvariable [namespace current]::layout_ \
		-values $names \
	]
	$cb selection range 0 end

	grid $cb -row 1 -column 1 -sticky nsew
	grid columnconfigure $top {0 2} -minsize $::theme::padX
	grid rowconfigure $top {0 2} -minsize $::theme::padY

	::widget::dialogButtons $dlg {ok cancel} -default ok
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.ok configure -command [namespace code [list IfThenElse \
		[list {*}$cmd $parent $dlg "" $names] \
		[list destroy $dlg] \
		[list [namespace current]::ResetCB $cb $name] \
	]]

	wm withdraw $dlg
	wm resizable $dlg no no
	wm transient $dlg [winfo toplevel $parent]
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm title $dlg $mc::EnterName
	::util::place $dlg -parent .application -position center
	wm deiconify $dlg
	focus $cb
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc ResetCB {cb name} {
	if {[string length [$cb get]] == 0 && [string length $name] == 0} {
		$cb set $mc::NewLayout
		$cb selection range 0 end
	}
	focus $cb
}


proc IfThenElse {if then else} { if {[{*}$if]} { {*}$then } else { {*}$else } }


proc RenameLayout {twm oldName parent - - names} {
	variable [namespace parent]::Vars
	variable LayoutVariants
	variable Options
	variable layout_

	if {$layout_ eq $oldName} { return 1 }
	set id $Vars(id:$twm)
	set newName $layout_
	if {$newName in $names} {
		if {[::dialog::question \
				-parent $parent \
				-message [format $mc::ConfirmOverwrite $newName] \
				-default no \
			] ne "yes"} {
			set layout_ ""
			return [expr {$twm eq $parent}]
		}
	}
	if {![::fsbox::checkPath $parent $newName]} {
		if {[string length $oldName]} { set layout_ "" }
		return 0
	}

	foreach layoutVariant [list normal {*}$LayoutVariants] {
		set source [makeFilename $id $layoutVariant $oldName]
		if {[file exists $source]} {
			set target [makeFilename $id $layoutVariant $newName]
			file rename -force $source $target
		}
	}

	if {$Vars($id:layout:name) eq $oldName} { set Vars($id:layout:name) $newName }
	if {$Options($id:layout:name) eq $oldName} { set Options($id:layout:name) $newName }
	return 1
}


proc DoSaveLayout {twm parent layoutVariant names} {
	variable [namespace parent]::Vars
	variable Options
	variable layout_

	if {![::fsbox::checkPath $parent $layout_]} { return 0 }
	set id $Vars(id:$twm)
	set variants {}
	if {[string length $layoutVariant] == 0} {
		set layoutVariant [CurrentLayoutVariant $id]
		if {$layoutVariant eq "normal" || ![file exists [makeFilename $id normal $layout_]]} {
			lappend variants "normal"
		}
		if {$layoutVariant ne "normal"} {
			lappend variants $layoutVariant
		}
	} else {
		lappend variants $layoutVariant
	}
	if {$layout_ in $names} {
		set confirm 0
		foreach v $variants {
			if {[file exists [makeFilename $id $v $layout_]]} { set confirm 1; break }
		}
		if {$confirm} {
			if {[::dialog::question \
					-parent $parent \
					-message [format $mc::ConfirmOverwrite $layout_] \
					-default no \
				] ne "yes"} {
				set layout_ ""
				return [expr {$twm eq $parent}]
			}
		}
	}
	if {[llength $variants]} {
		foreach v $variants { WriteLayout $twm $id $v }
		::dialog::info -parent $parent -message [format $mc::LayoutSaved $layout_]
	}
	set Vars($id:layout:name) $layout_
	set Options($id:layout:name) $layout_
	return 1
}


proc WriteLayout {twm id layoutVariant} {
	variable Options
	variable layout_

	set dir [makeDir $id $layoutVariant]
	file mkdir $dir
	set fh [::open [makeFilename $id $layoutVariant $layout_] "w"]
	fconfigure $fh -encoding utf-8
	set Options($id:layout:list:$layoutVariant) [inspectLayout $twm]
	set Options($id:layout:saved:$layoutVariant) $Options($id:layout:list:$layoutVariant)
	puts $fh "::application::twm::setup $layoutVariant $id {$Options($id:layout:list:$layoutVariant)}"
	::options::writeTableOptions $fh $id
	close $fh
}


proc ShowAllDockingPoints {twm} {
	variable Options
	$twm showall $Options($id:docking:showall)
}


proc ToggleTitlebars {twm windows} {
	$twm togglebar {*}$windows
}


proc CurrentLayoutVariant {id} {
	if {$id ne "board"} {
		set variant [::scidb::db::get variant?]
	} elseif {[::scidb::game::current] >= 0} {
		set variant [::scidb::game::query variant?]
	} else {
		return "normal" ;# no game exists before startup has been completed
	}
	return [toLayoutVariant $variant]
}


proc LoadLinkedLayouts {id name} {
	variable [namespace parent]::Vars
	variable Options

	if {$id ne "board"} { return }

	foreach attr [array names Options *:link] {
		if {$Options($attr) eq $name} {
			lassign [split $attr :] id myName
			if {$Options($id:layout:name) ne $myName} {
				loadLayout $Vars(twm:$id) $myName
			}
		}
	}
}


proc GetLayout {id} {
	variable [namespace parent]::Vars
	variable LayoutVariants
	variable Options

	if {[::process::testOption initial-layout]} {
		array unset Options $id:layout:list:*
		array unset Options $id:layout:saved:*
		set Options($id:layout:name) ""
		set Options($id:layout:list) {}
		set Options($id:layout:list:normal) {}
		set Vars($id:layout:name) ""
	} else {
		if {	[string length $Options($id:layout:name)]
			&& ![file exists [makeFilename $id normal $Options($id:layout:name)]]} {
			set Options($id:layout:name) ""
		}
		set Vars($id:layout:name) $Options($id:layout:name)
	}
	set layoutVariant [CurrentLayoutVariant $id]
	if {![info exists Options($id:layout:list:$layoutVariant)]} {
		set layoutVariant normal
	}
	if {![info exists Options($id:layout:list:$layoutVariant)]} {
		set Options($id:layout:list:$layoutVariant) $Options($id:layout:list)
	}
	if {![info exists Options($id:layout:list:normal)]} {
		set Options($id:layout:list:normal) $Options($id:layout:list:$layoutVariant)
	}
	set Vars($id:layout:variant) $layoutVariant
	return $Options($id:layout:list:$layoutVariant)
}


proc Menu {twm w x y} {
	set menu $twm.__menu__
	# Try to catch accidental double clicks.
	if {[winfo exists $menu]} { return }
	menu $menu
	catch { wm attributes $menu -type popup_menu }
	makeLayoutMenu $twm $menu $w
	bind $menu <<MenuUnpost>> +[list after idle [list catch [list destroy $menu]]]
	tk_popup $menu $x $y
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Options
}
::options::hookWriter [namespace current]::WriteOptions

} ;# namespace twm
} ;# namespace application

# vi:set ts=3 sw=3:
