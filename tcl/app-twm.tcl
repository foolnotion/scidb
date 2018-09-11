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

set FoldTitleBar					"Fold Titlebar"
set FoldAllTitleBars				"Fold all Titlebars"
set UnfoldAllTitleBars			"Unfold all Titlebars"
set AmalgamateTitleBar			"Amalgamate Titlebar"
set AmalgamateAllTitleBars		"Amalgamate all Titlebars"
set SeparateAllTitleBars		"Separate all Titlebars"
set AlignToLine					"Align to Line Space"
set Notebook						"Notebook"
set Multiwindow					"Multiwindow"
set MoveWindow						"Move Window"
set StayOnTop						"Stay on Top"
set HideWhenLeavingTab			"Hide When Leaving Tab"
set SaveLayout						"Save Layout"
set SaveLayoutAs					"Save Layout as %s"
set RenameLayout					"Rename Layout"
set LoadLayout						"Restore Layout"
set NewLayout						"New Layout"
set ManageLayouts					"Manage Layouts"
set ShowAllDockingPoints		"Show all Docking Points"
set DockingArrowSize				"Docking Arrow Size"
set LinkLayout						"Link Layout '%s'"
set UnlinkLayout					"Delete Link to '%s'"
set LinkLayoutTip					"Link With Board Layout"
set Actual							"current"
set Changed							"changed"
set Windows							"Windows"
set ConfirmDelete					"Really delete layout '%s'?"
set ConfirmDeleteDetails		"This will only delete the layout of variant '%s'. If you want to delete the complete layout, then you have to delete the layout of variant '%s'."
set ConfirmOverwrite				"Overwrite existing layout '%s'?"
set LayoutSaved					"Layout '%s' successfully saved"
set EnterName						"Enter Name"
set UnsavedLayouts				"At least one layout has been changed. Either cancel the termination of the application, or commit the selected actions."
set LinkWithLayout				"Link with eponymous board layout '%s'?"
set CopyLayoutFrom				"Copy layout from"
set ApplyToAllLayouts			"Apply this action to all changed layouts?"
set KeepEnginesOpen				"Current layout has more analysis windows than selected layout. Keep all additional analysis windows open?"
set ErrorInOptionFile			"Option file for layout variant '%s' is corrupted."

set Pane(analysis)				"Analysis"
set Pane(board)					"Board"
set Pane(editor)					"Notation"
set Pane(tree)						"Tree"
set Pane(games)					"Games"
set Pane(player)					"Players"
set Pane(event)					"Events"
set Pane(annotator)				"Annotator"
set Pane(site)						"Site"
set Pane(position)				"Position"
set Pane(eco)						"ECO-Table"

set UnsavedAction(discard)		"Discard changes (start next time with unchanged layout)"
set UnsavedAction(overwrite)	"Overwrite existing layout with changed layout"
set UnsavedAction(disconnect)	"Disconnect from original layout, but retain the changes"
set UnsavedAction(retain)		"Retain changes, and do not disconnect"

} ;# namespace mc


variable MaxPerPage 3

foreach tab [concat board $::application::database::Tabs] {
	set Options($tab:docking:showall)	no
	set Options($tab:layout:name)			""
	set Options($tab:layout:list)			{}
}
unset tab

variable layoutVariants $::layoutVariants


proc make {twm id prioArr options layout args} {
	variable [namespace parent]::Vars
	variable Options

	twm::twm $twm \
		-resizing [namespace current]::resizing \
		-workarea [namespace current]::workArea \
		-frameborderwidth 0 \
		-panedwindowrelief raised \
		{*}$args \
		;
	$twm showall $Options($id:docking:showall)
	pack $twm -fill both -expand yes

	if {$id eq "board"} {
		bind $twm <<TwmGeometry>> [namespace code [list geometry %d]]
		bind $twm <<TwmFullscreen>> [namespace code [list Fullscreen $twm %d]]
		bind $twm <<Fullscreen>> [namespace code geometry]
	}

	bind $twm <<TwmMenu>> [namespace code [list Menu $twm %d %x %y]]
	bind $twm <<FontSizeChanged>> [list after idle [list $twm refresh]]

	set Vars($id:prioArr) $prioArr
	set Vars($id:init:options) $options
	set Vars($id:init:layout:name) $layout
	set Vars($twm:id) $id
	set Vars($id:twm) $twm
	set Vars($twm:afterid) {}
	set Vars(fullscreen) [::menu::fullscreen?]
	lappend Vars(twm) $twm

	return $twm
}


proc load {twm} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars($twm:id)
	loadInitialLayout $twm
	set layoutVariant [GetLayout $id]
	LoadOptionFile $layoutVariant
	set layout $Options($id:layout:list:$layoutVariant)
	if {[llength $layout] > 0 || ![LoadLayout $twm $layoutVariant $Options($id:layout:name) load]} {
		set Vars(loading) 1
		$twm load $layout
		set Vars(loading) 0
		after idle [list ::options::save $twm $layoutVariant]
		after idle [list ::toolbar::save $id]
		set Vars($id:options:saved:$layoutVariant) 1
	}
	return $twm
}


proc loadInitialLayout {twm {origTWM ""}} {
	variable [namespace parent]::Vars

	set id $Vars([expr {[string length $origTWM] ? $origTWM : $twm}]:id)
	array set opts $Vars($id:init:options)
	set layout $Vars($id:init:layout:name)
	foreach name [array names opts] {
		set layout [string map [list %${name}% [list $opts($name)]] $layout]
	}
	$twm init $layout
}


proc priority {twm uid} {
	variable [namespace parent]::Vars

	set arrName $Vars($Vars($twm:id):prioArr)
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


proc minHeight {} { ;# but not including "board"
	variable [namespace parent]::Vars

	set max 0
	foreach twm $Vars(twm) {
		if {$twm ne $Vars(board:twm)} {
			set minheight [lindex [$twm dimension] 3]
			set max [expr {max($max, $minheight)}]
		}
	}
	return $max
}


proc minWidth {} { ;# but not including "board"
	variable [namespace parent]::Vars

	set max 0
	foreach twm $Vars(twm) {
		if {$twm ne $Vars(board:twm)} {
			set minwidth [lindex [$twm dimension] 2]
			set max [expr {max($max, $minwidth)}]
		}
	}
	return $max
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
	if {$Vars($twm:id) ne "board"} {
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

return [list $width $height] ;# TODO seems too be superfluous
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
	if {$Vars($twm:id) ne "board"} {
# XXX problem: returns 0 because it is called too early
		decr maxheight [::application::database::switcherSize]
	}
	set width [expr {min($width, $maxwidth)}]
	set height [expr {min($height, $maxheight)}]
	return [list $width $height]
}


proc geometry {{data {}}} {
	variable [namespace parent]::Vars

	if {$Vars(fullscreen) && ![::menu::fullscreen?]} {
		lassign [workArea $Vars(board:twm)] w h
		$Vars(board:twm) resize $Vars(board:twm) $w $h
		set data [list $w $h 0 0 0 0]
		set Vars(fullscreen) 0
	}
	if {[llength $data] == 0} { return }

	# TODO:
	# Probably we should not resize the main pane after the theme has changed.

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

	set geometry ${width}x${height}
	if {$Vars(fullscreen) && ![::menu::fullscreen?]} {
		incr incrH +4 ;# TODO why?
		incr incrV -2 ;# TODO why?
		set x [expr {([winfo screenwidth .application] - ($width + $incrH))/2}]
		set y [expr {([winfo screenheight .application] - ($height + $incrV))/2}]
		append geometry "+${x}+${y}"
	}
	wm geometry .application $geometry

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
			set id $Vars($twm:id)
			if {$reason eq "game" ? $id ne "board" : $id eq "board"} { continue }
			set oldLayoutVariant $Vars($id:layout:variant)
			if {$newLayoutVariant ne $oldLayoutVariant} {
				set loaded 0
				TestLayoutStatus $twm
				if {![compareTableOptions $twm $oldLayoutVariant]} {
					::options::save $twm $oldLayoutVariant
					::toolbar::save $id
					set Vars($id:options:saved:$oldLayoutVariant) 1
				}
				set Options($id:layout:list:$oldLayoutVariant) [inspectLayout $twm]
				set Vars($id:layout:variant) $newLayoutVariant ;# must be set before loading
				if {![info exists Options($id:layout:list:$newLayoutVariant)]} {
					if {[string length $Options($id:layout:name)]} {
						LoadOptionFile $newLayoutVariant
						set loaded [LoadLayout $twm $newLayoutVariant $Options($id:layout:name) switch]
					}
					if {!$loaded} {
						if {[info exists Options($id:layout:list:normal)]} {
							set Options($id:layout:list:$newLayoutVariant) $Options($id:layout:list:normal)
						} else {
							set Options($id:layout:list:$newLayoutVariant) {}
						}
						set Options($id:layout:saved:$newLayoutVariant) $Options($id:layout:list:normal)
						set Options($id:layout:changed:$newLayoutVariant) 0
					}
				}
				set Options($id:layout:list) $Options($id:layout:list:$newLayoutVariant)
				if {!$loaded} {
					# load options before applying layout
					if {[info exists Vars($id:options:saved:$newLayoutVariant)]} {
						::options::restore $twm $newLayoutVariant
						::toolbar::restore $id
					} else {
						after idle [list ::options::save $twm $newLayoutVariant]
						after idle [list ::toolbar::save $id]
						set Vars($id:options:saved:$newLayoutVariant) 1
					}
					if {![actualLayoutIsEqTo $twm $Options($id:layout:list) true]} {
						set Vars(loading) 1
						$twm load $Options($id:layout:list)
						set Vars(loading) 0
					}
				}
			}
		}
	}
}


proc saveLayouts {} {
	variable [namespace parent]::Vars
	variable layoutVariants
	variable MaxPerPage
	variable Options
	variable action_
	variable variants_

	array unset variants_
	set unsaved {}
	set showVariants 0
	set Vars(first:selection) 1

	foreach twm $Vars(twm) {
		TestLayoutStatus $twm
		set id $Vars($twm:id)
		foreach v $layoutVariants {
			if {[info exists Vars($id:layout:changed:$v)]} {
				if {$id in $unsaved || $v ne "normal"} { set showVariants 1 }
				if {$id ni $unsaved} { lappend unsaved $id }
				lappend variants_($id) $v
			}
		}
	}

	if {[llength $unsaved]} {
		set buttonCmd {}
		if {[llength $unsaved] > $MaxPerPage} {
			set buttonCmd [namespace code [list EmbedButtons [llength $unsaved]]]
		}
		append msg $mc::UnsavedLayouts <embed>
		set reply [::dialog::info \
			-parent .application \
			-message $msg \
			-default cancel \
			-buttons {ok cancel} \
			-addbuttons $buttonCmd \
			-embed [namespace code [list EmbedUnsavedLayouts $unsaved $showVariants]] \
		]
		if {$reply ne "ok"} { return false }

		foreach id $unsaved {
			foreach v $variants_($id) {
				switch $action_($id) {
					disconnect {
						set Options($id:layout:changed:$v) no
						if {$v eq $Vars($id:layout:variant)} {
							set Options($id:layout:name) ""
							set Options($id:layout:list:$v) [inspectLayout $Vars($id:twm)]
						}
					}
					retain {
						if {$v eq $Vars($id:layout:variant)} {
							set Options($id:layout:list:$v) [inspectLayout $Vars($id:twm)]
						}
					}
					discard {
						set Options($id:layout:changed:$v) no
						set Options($id:layout:list:$v) $Options($id:layout:saved:$v)
					}
					overwrite {
						WriteLayout $Vars($id:twm) $id $Options($id:layout:name) $v
					}
				}
			}
		}
	}

	foreach twm $Vars(twm) {
		set id $Vars($twm:id)
		if {$id ni $unsaved} {
			set Options($id:layout:list:$Vars($id:layout:variant)) [inspectLayout $twm]
		}
		if {[info exists Options($id:layout:list:normal)]} {
			set Options($id:layout:list) $Options($id:layout:list:normal)
		} else {
			set Options($id:layout:list) {}
		}
	}

	return true
}


proc setup {layoutVariant id layout} {
	set [namespace current]::Options($id:layout:list:$layoutVariant) $layout
}


proc loadLayout {twm name} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars($twm:id)

	if {![::file::test [makeFilename $id normal $name]]} {
		set Options($id:layout:name) ""
		return
	}

	set Options($id:layout:name) $name
	set layoutVariant [CurrentLayoutVariant $id]
	set Vars($id:layout:variant) $layoutVariant
	LoadLayout $twm $layoutVariant $name load
}


proc inspectLayout {twm} {
	variable [namespace parent]::Vars

	set list {}
	if {$Vars($twm:id) eq "board"} {
		lappend list Extent
		$twm set $twm fullscreen [::menu::fullscreen?]
	}
	return [$twm inspect {*}$list]
}


proc savedLayout {twm} {
	variable Options
	variable [namespace parent]::Vars

	set id $Vars($twm:id)
	set layoutVariant $Vars($id:layout:variant)
	return $Options($id:layout:saved:$layoutVariant)
}


proc currentLayoutName {twm} {
	variable [namespace parent]::Vars
	variable Options

	return $Options($Vars($twm:id):layout:name)
}


proc testLayoutStatus {twm} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars($twm:id)
	if {[string length $Options($id:layout:name)] == 0} { return false }
	set layoutVariant $Vars($id:layout:variant)
	if {![info exists Options($id:layout:saved:$layoutVariant)]} { return false }
	set list $Options($id:layout:saved:$layoutVariant)
	return [actualLayoutIsEqTo $twm $list true]
}


proc actualLayoutIsEqTo {twm layout {ignoreCoords false}} {
	set actualLayout [inspectLayout $twm]
	if {	[::twm::layoutContainsOnlyOnePane $layout]
		&& [::twm::layoutContainsOnlyOnePane $actualLayout]} {
		# Special case: if both layouts contain only one pane, then comparison is always true.
		# Note that we do not consider the names of the panes (not required here).
		return true
	}
	return [$twm compare $actualLayout $layout $ignoreCoords]
}


proc compareTableOptions {twm layoutVariant} {
	variable [namespace parent]::Vars

	set id $Vars($twm:id)
	if {![info exists Vars($id:options:saved:$layoutVariant)]} { return true }
	if {![::options::compare $twm $layoutVariant]} { return false }
	return [::toolbar::compare $id]
}


proc renameLayout {twm name parent} {
	variable name_

	SaveLayout $twm $parent [list [namespace current]::RenameLayout $twm $name] $name $mc::RenameLayout
	return $name_
}


proc deleteLayout {twm name parent layoutVariant} {
	variable [namespace parent]::Vars
	variable Options
	variable layoutVariants

	set details ""
	if {$layoutVariant ne "normal"} {
		set details [format $mc::ConfirmDeleteDetails \
			$::mc::VariantName([toVariant $layoutVariant]) $::mc::VariantName([toVariant "normal"])]
	}
	if {[::dialog::question \
			-parent $parent \
			-message [format $mc::ConfirmDelete $name] \
			-detail $details \
			-default no \
		] eq "no"} {
		return 0
	}

	set id $Vars($twm:id)
	set filename [makeFilename $id $layoutVariant $name]
	file delete $filename

	if {$layoutVariant eq "normal"} {
		foreach v $layoutVariants {
			if {$v ne "normal"} { file delete [makeFilename $id $v $name] }
		}
		if {$Options($id:layout:name) eq $name} { set Options($id:layout:name) "" }
		if {$id eq "board"} {
			foreach attr [array names Options *:link] {
				if {$Options($attr) eq $name} { array unset Options $attr }
			}
		} else {
			array unset Options $id:$name:link
		}
	}

	return 1
}


proc replaceLayout {twm layoutVariant name} {
	LoadLayout $twm $layoutVariant $name replace
}


proc getId {twm} {
	return [set [namespace parent]::Vars($twm:id)]
}


proc getTWM {id} {
	return [set [namespace parent]::Vars($id:twm)]
}


proc saveTableOptions {} {
	variable [namespace parent]::Vars
	variable layoutVariants

	foreach twm $Vars(twm) {
		set id $Vars($twm:id)
		set layoutVariant $Vars($id:layout:variant)
		::options::save $twm $layoutVariant
		::toolbar::save $id
		set Vars($id:options:saved:$layoutVariant) 1
	}

	foreach layoutVariant $layoutVariants {
		if {[llength [array names Vars *:options:saved:$layoutVariant]]} {
			::options::saveTableOptionsFile $layoutVariant
		}
	}
}


proc makeLayoutMenu {twm menu {w ""}} {
	variable [namespace parent]::Vars
	variable Options
	variable layoutVariants
	variable flat_
	variable ismultiwindow_
	variable stayontop_
	variable hide_
	variable name_
	variable amalgamate_

	set myID $Vars($twm:id)
	set myName $Options($myID:layout:name)
	set count 0
	set hideDisabled [::table::isTableMenu $menu]

	if {[string length $w]} {
		set v $w
		if {!([$twm ismultiwindow $w] || [$twm isnotebook $w])} {
			set v [$twm parent $w]
		}
		if {[$twm ismultiwindow $v] || [$twm isnotebook $v]} {
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

		if {![$twm ismetachild $w]} {
			set flat_ [$twm get! $w flat -1]

			if {$flat_ != -1} {
				if {$count} { $menu add separator }
				$menu add checkbutton \
					-label " $mc::FoldTitleBar" \
					-variable [namespace current]::flat_ \
					-command [list $twm togglebar $w] \
					;
				::theme::configureCheckEntry $menu
				incr count
			}
		}

		set v ""
		if {[$twm amalgamatable $w]} {
			set amalgamate_ [$twm get! $w amalgamate 0]
			set v $w
		} elseif {[string length [set v [$twm amalgamated $w]]]} {
			set amalgamate_ 1
		}
		if {[string length $v]} {
			if {$count && [$menu type end] ne "checkbutton"} {
				$menu add separator
				set count 0
			}
			$menu add checkbutton \
				-label " $mc::AmalgamateTitleBar" \
				-variable [namespace current]::amalgamate_ \
				-command [namespace code [list Amalgamate $twm $v]] \
				;
			::theme::configureCheckEntry $menu
		}
	}

	set folded [$twm collect flat]
	set unfolded [$twm collect !flat]
	if {[llength $unfolded] || [llength $folded]} {
		if {$count} { $menu add separator }
		$menu add command \
			-label " $mc::FoldAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list $twm togglebar {*}$unfolded] \
			-state [::makeState [llength $unfolded]] \
			;
		set state [expr {[llength $folded] ? "normal" : "disabled"}]
		$menu add command \
			-label " $mc::UnfoldAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list $twm togglebar {*}$folded] \
			-state [::makeState [llength $folded]] \
			;
		incr count
	}

	set separated [$twm collect !amalgamate]
	set amalgamated [$twm collect amalgamate]
	if {[llength $separated] || [llength $amalgamated]} {
		$menu add command \
			-label " $mc::AmalgamateAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list $twm amalgamate {*}$separated] \
			-state [::makeState [llength $separated]] \
			;
		$menu add command \
			-label " $mc::SeparateAllTitleBars" \
			-image $::icon::16x16::none \
			-compound left \
			-command [list $twm separate {*}$amalgamated] \
			-state [::makeState [llength $amalgamated]] \
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

	if {$myID eq "board" && [string length $w]} {
		set path [$twm collect visible $w]
		if {[llength $path] == 1} {
			set uid [$twm uid $path]
			if {$Vars(align:$myID:$uid)} {
				if {$count} { $menu add separator }
				set height [ComputeAlignedHeight $twm $uid]
				$menu add command \
					-label " $mc::AlignToLine" \
					-image $::icon::16x16::none \
					-compound left \
					-command [namespace code [list AlignToLine $twm $uid $height]] \
					-state [::makeState $height] \
					;
			}
		}
	}

	array set opts $Vars($myID:init:options)
	set leaves1 [lmap uid [array names opts] {
		expr {$uid ni {board analysis editor} && $uid ne $myID ? $uid : [continue]}
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

	set names [glob $myID]
	if {$count} { $menu add separator }
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
			if {$name eq $myName} {
				set status [expr {[testLayoutStatus $twm] ? "Actual" : "Changed"}]
				append lbl " \[[set mc::$status]\]"
			}
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
	if {[string length $myName]} {
		if {$myName ni $names} {
			set myName [set Options($myID:layout:name) ""]
		} else {
			set layoutVariant $Vars($myID:layout:variant)
			if {![info exists Options($myID:layout:list:$layoutVariant)]} { set layoutVariant normal }
			if {[TestIfChanged $myID $layoutVariant]} {
				set state normal
			} elseif {[info exists Options($myID:layout:saved:$layoutVariant)]} {
				set list $Options($myID:layout:saved:$layoutVariant)
				if {![actualLayoutIsEqTo $twm $list true] || ![compareTableOptions $twm $layoutVariant]} {
					set state normal
				}
			} else {
				set state normal
			}
			set labelName [string map [list "%s" "\"$myName\""] $labelName]
			if {$layoutVariant ne "normal"} {
				append labelName " \[$::mc::VariantName([toVariant $layoutVariant])\]"
			}
		}
	}
	set name_ $myName
	if {[string length $name_] && (!$hideDisabled || $state eq "normal")} {
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

	if {$myID ne "board" && [string length [set current $myName]] > 0} {
		set bnames [glob board]
		if {[llength $bnames]} {
			variable Link_
			menu $menu.link
			$menu add cascade \
				-menu $menu.link \
				-label " [format $mc::LinkLayout $current]" \
				-image $::icon::16x16::none \
				-compound left \
				;
			tooltip::tooltip $menu -index [$menu index end] $mc::LinkLayoutTip
			set Link_ ""
			if {[info exists Options($myID:$current:link)]} {
				set Link_ $Options($myID:$current:link)
			}
			foreach name $bnames {
				$menu.link add radiobutton \
					-label $name \
					-variable [namespace current]::Link_ \
					-value $name \
					-command [namespace code [list UpdateLink $myID $current]] \
					;
				::theme::configureRadioEntry $menu.link
			}
			set state [::makeState [info exists Options($myID:$current:link)]]
			if {$state eq "normal"} {
				$menu add command \
					-label " [format $mc::UnlinkLayout $Link_]" \
					-image $::icon::16x16::none \
					-compound left \
					-command [list array unset [namespace current]::Options $myID:$current:link] \
					-state $state \
					;
			}
		}
	}

	set n 0
	lmap uid [$twm leaves] { expr {[$twm isundockable $uid] ? [incr n] : [continue]} }
	if {$n > 0} {
		set cur $myName
		set cmd [list [namespace parent]::layout::open $twm $myID $Vars($myID:layout:variant) $cur]
		$menu add command \
			-label " $mc::ManageLayouts..." \
			-image $::icon::16x16::setup \
			-compound left \
			-command $cmd \
			-state [::makeState [llength $names]] \
			;

		$menu add separator
		$menu add checkbutton \
			-label " $mc::ShowAllDockingPoints" \
			-variable [namespace parent]::Options($myID:docking:showall) \
			-command [namespace code [list ShowAllDockingPoints $twm]] \
			;
		::theme::configureCheckEntry $menu

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
				-variable ::twm::Options(cross:size) \
				-value $pixels \
				;
			::theme::configureRadioEntry $menu.size
		}
	}
}


proc glob {id {layoutVariant normal}} {
	set files [::glob -nocomplain -directory [makeDir $id $layoutVariant] *.layout]
	return [lsort -dictionary [lmap f $files {file tail [file rootname $f]}]]
}


proc getLink {id name} {
	variable Options

	if {![info exists Options($id:$name:link)]} { return "" }
	return $Options($id:$name:link)
}


proc setLink {id name link} {
	variable Options

	if {[string length $link] == 0} {
		array unset Options $id:$name:link
	} else {
		set Options($id:$name:link) $link
	}
}


proc restoreLayout {twm layoutVariant name currenLayout savedLayout} {
	variable [namespace parent]::Vars
	variable Options

	set rc 1
	set id $Vars($twm:id)
	set Vars(loading) 1
	$Vars($id:twm) load $currenLayout
	if {[info exists Vars($id:options:saved:$layoutVariant)]} {
		::options::restore $twm $layoutVariant
		::toolbar::restore $id
	}
	set Vars(loading) 0
	set filename [makeFilename $id $layoutVariant $name]
	if {![file exists $filename]} { lassign {"" 0} name rc }
	set Options($id:layout:name) $name
	set Options($id:layout:list) $currenLayout
	set Options($id:layout:list:$layoutVariant) $currenLayout
	set Options($id:layout:saved:$layoutVariant) $savedLayout
	LoadLinkedLayouts $twm $name
	return $rc
}


proc Fullscreen {twm flag} {
	variable [namespace parent]::Vars

	::menu::setFullscreen $flag
	update idletasks
}


proc LoadLayout {twm layoutVariant name mode} {
	variable [namespace parent]::Vars
	variable layoutVariants
	variable Options

	if {[string length $name] == 0} { return false }

	set id $Vars($twm:id)
	set file [makeFilename $id $layoutVariant $name]

	if {$layoutVariant ne "normal" && ![file exists $file]} {
		if {$mode eq "switch"} { return false }
		# Note that this file should always exist.
		set file [makeFilename $id normal $name]
	}

	if {[file exists $file]} {
		if {[catch { ::load::source $file -encoding utf-8 -throw 1 } -> opts]} {
			puts stderr "error while loading $file"
			if {$mode ne "load"} { return false }
			return {*}$opts -rethrow 1
		}
	} elseif {$mode ne "load"} {
		return false
	}

	set Options($id:layout:list) $Options($id:layout:list:$layoutVariant)
	set Vars($id:options:saved:$layoutVariant) 1
	set Options($id:layout:saved:$layoutVariant) $Options($id:layout:list:$layoutVariant)
	set Options($id:layout:changed:$layoutVariant) 0
	if {$mode eq "replace"} {
		set Vars($id:layout:changed:$layoutVariant) 1
	} else {
		set Options($id:layout:name) $name
		array unset Vars $id:layout:changed:$layoutVariant
	}
	set preserve {}
	set unused ""

	if {$id eq "board"} {
		foreach uid [$twm leaves] {
			if {[string match {analysis:*} $uid]} {
				set number [[namespace parent]::analysisNumberFromUid $uid]
				if {[[namespace parent]::analysis::active? $number]} {
					lappend preserve $uid
				} elseif {[lindex [split $uid :] 1] == 1} {
					set unused $uid
				}
			}
		}
		set preserve [lsub $preserve [::twm::extractLeaves $Options($id:layout:list)]]
		set preserve [lsort -dictionary $preserve]
		if {$mode eq "load" && [llength $preserve] - [llength $unused] > 0} {
			set reply [::dialog::question \
				-parent .application \
				-message $mc::KeepEnginesOpen \
				-default yes \
				-buttons {yes no} \
			]
			if {$reply eq "no"} { set preserve {} }
		}
	}

	set Vars(loading) 1
	$Vars($id:twm) load -preserve $preserve $Options($id:layout:list)
	set Vars(loading) 0
	if {[llength $unused] && [llength $preserve]} {
		destroy [$twm leaf $unused]
	}
	after idle [list ::options::save $twm $layoutVariant]
	after idle [list ::toolbar::save $id]

	if {$mode eq "load"} {
		foreach v $layoutVariants {
			if {$v ne $layoutVariant} {
				array unset Options $id:layout:*:$v
				array unset Vars $id:layout:changed:$v
			}
		}
	}

	if {$mode ne "replace"} {
		LoadLinkedLayouts $twm $name
	}

	return true
}


proc LoadLinkedLayouts {twm name} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars($twm:id)
	if {$id ne "board"} { return }

	foreach attr [array names Options *:link] {
		if {$Options($attr) eq $name} {
			lassign [split $attr :] id myName
			loadLayout $Vars($id:twm) $myName
		}
	}
}


proc EmbedButtons {numEntries w} {
	variable MaxPerPage
	variable buttons_
	variable colors_
	variable current_

	set l [tk::label $w.page -text $mc::Page]
	grid $l -row 1 -column 1 -sticky s
	grid columnconfigure $w 2 -minsize $::theme::padx
	set numPages [expr {($numEntries + $MaxPerPage - 1)/$MaxPerPage}]
	set colors_(background) [::theme::getColor background]
	set colors_(hilitebackground) [::dropdownbutton::activebackground]
	set colors_(activebackground) [::colors::makeActiveColor $colors_(hilitebackground)]
	set current_ 1
	for {set i 1} {$i <= $numPages} {incr i} {
		set color [expr {$i == $current_ ? "hilite" : ""}]
		set b [tk::button $w.p$i \
			-text $i \
			-background $colors_(${color}background) \
			-activebackground $colors_(activebackground) \
			-command [namespace code [list SelectPane $i]] \
		]
		set buttons_($i) $b
		grid $b -row 1 -column [expr {$i + 2}] -sticky s
	}
}


proc SelectPane {pageno} {
	variable multiwindow_
	variable panes_
	variable buttons_
	variable colors_
	variable current_

	$multiwindow_ raise $panes_($pageno)
	$buttons_($current_) configure -background $colors_(background)
	$buttons_($pageno) configure -background $colors_(hilitebackground)
	set current_ $pageno
}


proc EmbedUnsavedLayouts {unsaved showVariants w infoFont alertFont} {
	variable [namespace parent]::Vars
	variable MaxPerPage
	variable Options
	variable multiwindow_
	variable panes_
	variable action_
	variable variants_

	array unset panes_
	array unset action_

	set multi [expr {[llength $unsaved] > $MaxPerPage}]
	if {$multi} {
		set multiwindow_ [tk::multiwindow $w.mw -borderwidth 0]
		pack $multiwindow_
		set pageno 1
	}

	set frow 0
	set count 0

	foreach id $unsaved {
		if {$multi && ![info exists panes_($pageno)]} {
			set w [tk::frame $multiwindow_.p$pageno -borderwidth 0]
			$multiwindow_ add $w -sticky new
			set panes_($pageno) $w
		}
		set top [ttk::frame $w.$id -borderwidth 1 -relief raised]
		set description ""
		if {$showVariants} {
			set variants {}
			set comma ""
			append description " ("
			foreach v $variants_($id) {
				append description $comma $::mc::VariantName([toVariant $v])
				set comma ", "
			}
			append description ")"
		}

		set hdr [ttk::frame $top.hdr -borderwidth 0]
		grid $hdr -row 1 -column 1 -sticky ew
		set tab [::mc::stripAmpersand [set [namespace parent]::mc::Tab($id)]]
		set l0 [ttk::label $hdr.l0-${id} -font $infoFont  -text "${mc::Tab}: "]
		set l1 [ttk::label $hdr.l1-${id} -font $alertFont -text $tab]
		set l2 [ttk::label $hdr.l2-${id} -font $infoFont  -text " \u2212 $mc::Layout: "]
		set l3 [ttk::label $hdr.l3-${id} -font $alertFont -text $Options($id:layout:name)]
		pack $l0 $l1 $l2 $l3 -side left
		if {[string length $description]} {
			pack [ttk::label $hdr.l4-${id} -font $infoFont -text $description] -side left
		}
		set action_($id) disconnect
		set row 3

		foreach action {disconnect retain discard overwrite} {
			set rb [ttk::radiobutton $top.${action}-${id} \
				-style message.TRadiobutton \
				-text $mc::UnsavedAction($action) \
				-variable [namespace current]::action_($id) \
				-value $action \
				-command [namespace code [list PropagateSelection $top $action $unsaved]] \
			]
			grid $rb -row $row -column 1 -sticky ew
			incr row 1
		}

		grid rowconfigure $top {0 2 7} -minsize $::theme::pady
		grid columnconfigure $top {0 2} -minsize $::theme::padx
		grid columnconfigure $top 1 -weight 1

		grid $top -row $frow -column 1 -sticky ew
		grid columnconfigure $w 1 -weight 1
		incr frow 2
		incr count

		set wrap [expr {$multi && ($count % $MaxPerPage) == 0 && [llength $unsaved] > $count}]
		if {$wrap || $count == [llength $unsaved]} {
			incr frow -2
			for {set row 1} {$row < $frow} {incr row 2} {
				grid rowconfigure $w $row -minsize $::theme::padY
			}
		}
		if {$wrap} {
			incr pageno
			set frow 0
		}
	}

	if {$multi} { $multiwindow_ select $panes_(1) }
}


proc PropagateSelection {w action unsaved} {
	variable [namespace parent]::Vars
	variable action_

	if {!$Vars(first:selection)} { return }
	if {[llength $unsaved] <= 2} { return }
	set Vars(first:selection) 0

	set reply [::dialog::question \
		-parent $w \
		-message $mc::ApplyToAllLayouts \
		-default yes \
		-buttons {yes no} \
	]
	if {$reply eq "yes"} {
		foreach id $unsaved {
			if {$action_($id) != $action} { set action_($id) $action }
		}
	}
}


proc UpdateLink {id name} {
	variable Link_
	setLink $id $name $Link_
}


proc TestIfChanged {id variant} {
	variable Options

	return [expr {	[info exists Options($id:layout:changed:$variant)]
					&& $Options($id:layout:changed:$variant)}]
}


proc TestLayoutStatus {twm} {
	variable [namespace parent]::Vars
	variable Options

	set id $Vars($twm:id)
	if {[string length $Options($id:layout:name)] == 0} { return }
	set layoutVariant $Vars($id:layout:variant)
	if {[TestIfChanged $id $layoutVariant]} { return }
	if {![info exists Options($id:layout:saved:$layoutVariant)]} { return }
	set list $Options($id:layout:saved:$layoutVariant)
	if {![actualLayoutIsEqTo $twm $list true] || ![compareTableOptions $twm $layoutVariant]} {
		set Options($id:layout:changed:$layoutVariant) 1
		set Vars($id:layout:changed:$layoutVariant) 1
	}
}


proc StayOnTop {twm w} {
	variable stayontop_
	$twm stayontop $w $stayontop_($w)
}


proc HideWhenLeavingTab {twm w} {
	variable hide_
	$twm set! $w hide $hide_($w)
}


# proc MoveWindow {twm w recv} {
# 	$twm undock -temporary $w
# 	$twm dock $w $recv left
# }


proc ChangeState {twm uid} {
	variable [namespace parent]::Vars

	if {[$twm isdocked $uid]} {
		destroy [$twm leaf $uid]
	} else {
		set id $Vars($twm:id)
		array set opts $Vars($id:init:options)
		$twm new frame $uid $opts($uid)
	}
}


proc ComputeAlignedHeight {twm uid} {
	set frame [$twm leaf $uid]
	lassign [$twm dimension $frame] - height - - - -
	set linespace [[namespace parent]::${uid}::linespace $frame]
	set overhang [expr {[[namespace parent]::${uid}::computeHeight $frame]}]
	set newHeight [expr {(($height - $overhang)/$linespace)*$linespace + $overhang}]
	if {$newHeight == $height} { return 0 }
#	if {abs($newHeight + $linespace - $height) <= abs($newHeight - $height)} {
	incr newHeight $linespace
#	}
	return $newHeight
}


proc AlignToLine {twm uid newHeight} {
	$twm resize [$twm leaf $uid] 0 $newHeight
}


proc RestoreLayout {twm layoutVariant name list} {
	variable [namespace parent]::Vars
	variable Options

	set Options($Vars($twm:id):layout:list:$layoutVariant) $list
}


proc CheckLink {attr} {
	variable Options

	if {[info exists Options($attr:link)] && [string length $Options($attr:link)] == 0} {
		array unset Options $attr:link
	}
}


proc SaveLayout {twm parent cmd name title} {
	variable [namespace parent]::Vars
	variable Options
	variable name_

	set myName $name
	set name_ $name
	set id $Vars($twm:id)
	if {[string length $name_] == 0} {
		if {	[string length $Options(board:layout:name)]
			&& $Options(board:layout:name) ne $Options($id:layout:name)} {
			set name_ $Options(board:layout:name)
		} else {
			set name_ $mc::NewLayout
		}
	}
	set names [glob $id]
	set dlg [tk::toplevel $parent.save -class Scidb]
	pack [set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]]
	set cb [ttk::combobox $top.input \
		-height 10 \
		-width 40 \
		-textvariable [namespace current]::name_ \
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
	variable layoutVariants
	variable Options
	variable name_

	if {$name_ eq $oldName} { return 1 }
	set id $Vars($twm:id)
	set newName $name_
	if {$newName in $names} {
		if {[::dialog::question \
				-parent $parent \
				-message [format $mc::ConfirmOverwrite $newName] \
				-default no \
			] ne "yes"} {
			set name_ ""
			return [expr {$twm eq $parent}]
		}
	}
	if {![::fsbox::checkPath $parent $newName]} {
		if {[string length $oldName]} { set name_ "" }
		return 0
	}

	foreach layoutVariant $layoutVariants {
		set source [makeFilename $id $layoutVariant $oldName]
		if {[file exists $source]} {
			set target [makeFilename $id $layoutVariant $newName]
			file rename -force $source $target

			if {$id eq "board"} {
				foreach attr [array names Options *:link] {
					if {$Options($attr) eq $oldName} { set Options($attr) $newName }
				}
			}
		}
	}

	if {$Options($id:layout:name) eq $oldName} {
		set Options($id:layout:name) $newName
	}
	return 1
}


proc DoSaveLayout {twm parent layoutVariant names} {
	variable [namespace parent]::Vars
	variable Options
	variable name_

	if {![::fsbox::checkPath $parent $name_]} { return 0 }
	set id $Vars($twm:id)
	set variants {}
	if {[string length $layoutVariant] == 0} {
		set layoutVariant [CurrentLayoutVariant $id]
		if {$layoutVariant eq "normal" || ![file exists [makeFilename $id normal $name_]]} {
			lappend variants "normal"
		}
		if {$layoutVariant ne "normal"} {
			lappend variants $layoutVariant
		}
	} else {
		lappend variants $layoutVariant
	}
	set confirm 0
	if {$name_ in $names} {
		foreach v $variants {
			if {[file exists [makeFilename $id $v $name_]]} { set confirm 1; break }
		}
		if {$confirm} {
			if {[::dialog::question \
					-parent $parent \
					-message [format $mc::ConfirmOverwrite $name_] \
					-default no \
				] ne "yes"} {
				set name_ ""
				return [expr {$twm eq $parent}]
			}
		}
	}
	if {[llength $variants]} {
		foreach v $variants { WriteLayout_ $twm $id $v }
	}
	if {	!$confirm
		&& $id ne "board"
		&& ![info exists Options($id:$name_:link)]
		&& $name_ in [glob board]} {
		if {[::dialog::question \
				-parent $parent \
				-message [format $mc::LinkWithLayout $name_] \
				-default no \
			] eq "yes"} {
			setLink $id $name_ $name_
		}
	}
	set Options($id:layout:name) $name_
	::dialog::info -parent $parent -message [format $mc::LayoutSaved $name_]
	return 1
}


proc CopyLayout {id layoutVariant name} {
	variable [namespace parent]::Vars
	variable Options

	set myLayoutVariant $Vars($id:layout:variant)

	if {	$layoutVariant eq $myLayoutVariant
		|| ![info exists Options($id:layout:list:$layoutVariant)]
		|| ![llength $Options($id:layout:list:$layoutVariant)]} {
		set file [makeFilename $id $layoutVariant $name]
		if {[catch { ::load::source $file -encoding utf-8 -throw 1 } -> opts]} {
			puts stderr "error while loading $file"
			return {*}$opts -rethrow 1
		}
	} else {
		set Options($id:layout:list:$myLayoutVariant) $Options($id:layout:list:$layoutVariant)
		::options::restore $Vars($id:twm) $layoutVariant
		::toolbar::restore $id
	}

	set Options($id:layout:list) $Options($id:layout:list:$layoutVariant)
	set Options($id:layout:changed:$myLayoutVariant) 1
	set Vars($id:layout:changed:$myLayoutVariant) 1

	set Vars(loading) 1
	$Vars($id:twm) load $Options($id:layout:list)
	set Vars(loading) 0
}


proc WriteLayout_ {twm id layoutVariant} {
	variable name_
	WriteLayout $twm $id $name_ $layoutVariant
}


proc WriteLayout {twm id name layoutVariant} {
	variable [namespace parent]::Vars
	variable Options

	set dir [makeDir $id $layoutVariant]
	file mkdir $dir
	set fh [::open [makeFilename $id $layoutVariant $name] "w"]
	fconfigure $fh -encoding utf-8
	set Options($id:layout:list:$layoutVariant) [inspectLayout $twm]
	set Options($id:layout:saved:$layoutVariant) $Options($id:layout:list:$layoutVariant)
	set Options($id:layout:changed:$layoutVariant) 0
	array unset Vars $id:layout:changed:$layoutVariant
	puts $fh "::application::twm::setup $layoutVariant $id {$Options($id:layout:list:$layoutVariant)}"
	::options::save $twm $layoutVariant
	::toolbar::save $id
	set Vars($id:options:saved:$layoutVariant) 1
	::options::writeTableOptions $fh $id $layoutVariant
	close $fh
}


proc ShowAllDockingPoints {twm} {
	variable Options
	$twm showall $Options($id:docking:showall)
}


proc Amalgamate {twm frame} {
	variable amalgamate_
	$twm [expr {$amalgamate_ ? "amalgamate" : "separate"}] $frame
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


proc GetLayout {id} {
	variable [namespace parent]::Vars
	variable Options

	if {[::process::testOption initial-layout]} {
		array unset Options $id:layout:list:*
		array unset Options $id:layout:saved:*
		set Options($id:layout:name) ""
		set Options($id:layout:list) {}
		set Options($id:layout:list:normal) {}
	} elseif {![info exists Vars($id:options:saved:normal)]} {
		if {	[string length $Options($id:layout:name)]
			&& ![file exists [makeFilename $id normal $Options($id:layout:name)]]} {
			set Options($id:layout:name) ""
		}
		if {![info exists Options($id:layout:list:normal)]} {
			set Options($id:layout:list:normal) []
		}
	}
	set layoutVariant [CurrentLayoutVariant $id]
	if {![info exists Options($id:layout:list:$layoutVariant)]} {
		set layoutVariant normal
	}
	if {[info exists Options($id:layout:list:$layoutVariant)]} {
		set Options($id:layout:list) $Options($id:layout:list:$layoutVariant)
	} else {
		set Options($id:layout:list:$layoutVariant) $Options($id:layout:list)
	}
	if {![info exists Options($id:layout:list:normal)]} {
		set Options($id:layout:list:normal) $Options($id:layout:list:$layoutVariant)
	}
	set Vars($id:layout:variant) $layoutVariant
	set Vars($id:options:saved:normal) 1
	return $layoutVariant
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


proc LoadOptionFile {layoutVariant} {
	variable [namespace parent]::Vars
	variable Options

	if {[info exists Vars(options:loaded:$layoutVariant)]} { return }
	set Vars(options:loaded:$layoutVariant) 1
	if {[catch { ::options::sourceFile $layoutVariant } rc]} {
		set message [format $mc::ErrorInOptionFile $::mc::VariantName([toVariant $layoutVariant])]
		::dialog::error -parent .application -message $message
	}
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Options
}
::options::hookWriter [namespace current]::WriteOptions

} ;# namespace twm
} ;# namespace application

# vi:set ts=3 sw=3:
