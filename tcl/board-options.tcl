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

::util::source board-options-dialog

namespace eval board {
namespace eval options {
namespace eval mc {

#et AnimationTime			"Animation"
#et MilliSeconds			"ms"
#et Off						"off"
set Coordinates			"Coordinates"
set SolidColor				"Solid Color"
set EditList				"Edit list"
set Embossed				"Embossed"
set Highlighting			"Highlighting"
set Border					"Border"
set SaveWorkingSet		"Save Working Set"
set SelectedSquare		"Selected Square"
set ShowBorder				"Show Border"
set ShowCoordinates		"Show Coordinates"
set ShowMaterialValues	"Show Material Values"
set ShowBar					"Show Bar"
set ShowSideToMove		"Show Side to Move"
set ShowSuggestedMove	"Show Suggested Move"
set SuggestedMove			"Suggested Move"
set Basic					"Basic"
set PieceStyle				"Piece Style"
set SquareStyle			"Square Style"
set Styles					"Styles"
set Show						"Preview"
set ChangeWorkingSet		"Edit Working Set"
set CopyToWorkingSet		"Copy to Working Set"
set NameOfPieceStyle		"Enter name of piece style"
set NameOfSquareStyle	"Enter name of square style"
set NameOfThemeStyle		"Enter name of theme"
set PieceStyleSaved		"Piece style '%s' saved under '%s'"
set SquareStyleSaved		"Square style '%s' saved under '%s'"
set ChooseColors			"Choose Colors"
set SupersedeSuggestion	"Supersede/use suggested colors from square style"
set CannotDelete			"Cannot delete '%s'."
#et CannotRename			"Cannot rename '%s'."
set IsWriteProtected		"File '%s' is write protected."
set ConfirmDelete			"Are you sure to delete '%s'?"
set YouCannotReverse		"You cannot reverse this action. File '%s' will be physically removed."
set NoPermission			"Cannot delete '%s'.\nPermission denied."
set BoardSetup				"Board Setup"
set OpenTextureDialog	"Open Texture Dialog"

set CannotUsePieceWorkingSet	"Cannot create new theme with '%s' selected for piece style."
set ChooseAnotherPieceStyle	"At first you have to save new piece style, or choose another piece style."

set CannotUseSquareWorkingSet	"Cannot create new theme with '%s' selected for square style."
set ChooseAnotherSquareStyle	\
	"At first you have to save new square style, or choose another square style."

} ;# namespace mc

namespace import ::tcl::mathfunc::min

variable RecentTextures			[lrepeat 6 {{} {}}]
variable PieceSetListCount		11
variable BoardSize				[expr {45*$PieceSetListCount}]
variable SquareSize				[expr {($BoardSize - 66)/4}]
variable InitialPosition		{{bk br {} bq} {bp bb {} wn} {bn {} wb wp} {wq {} wr wk}}
variable EditStylePath			.board_options_edit_style_[clock milliseconds]
variable FixedBackground		#fff5d6
variable ModifiedBackground	brown
variable ModifiedForeground	white
variable BorderWidth
variable ChangeWS
variable NameList
variable Widget
variable Position
variable Time
variable Identifier

array set RecentColors {
	coordinates	{ {} {} {} {} {} {} }
	background	{ {} {} {} {} {} {} }
}

array set HilitePos {
	x,selected	0
	y,selected	0
	x,suggested	3
	y,suggested	3
}

namespace import [namespace parent]::texture::openBrowser
namespace import [namespace parent]::texture::forgetTextures
namespace import [namespace parent]::stuff::drawBorderlines
namespace import [namespace parent]::setTile
namespace import [namespace parent]::setTheme
namespace import [namespace parent]::setSquareStyle
namespace import [namespace parent]::setPieceStyle
namespace import [namespace parent]::setPieceSet
namespace import [namespace parent]::setBackground
namespace import ::dialog::choosecolor::addToList
namespace import ::dialog::choosecolor::extendColorName


proc makeBasicFrame {path} {
	variable [namespace parent]::hilite
	variable [namespace parent]::colors
	variable [namespace parent]::layout
	variable AnimationTimeList
	variable Widget
	variable Time

	# Layout #######################################

	set f [::ttk::labelframe $path.layout -labelwidget [::ttk::label $path.llayout -textvar ::mc::Layout]]

	::ttk::checkbutton $f.border \
		-textvar [namespace current]::mc::ShowBorder \
		-variable [namespace parent]::layout(border) \
		-command [namespace code { ToggleShowBorder }]
	::ttk::checkbutton $f.mv \
		-textvar [namespace current]::mc::ShowMaterialValues \
		-variable [namespace parent]::layout(material-values) \
		-command [namespace code { RefreshBoard }]
	::ttk::checkbutton $f.mvbar \
		-textvar [namespace current]::mc::ShowBar \
		-variable [namespace parent]::layout(material-bar) \
		-command [namespace code { RefreshBoard }]
	set Widget(bar) $f.mvbar
	::ttk::checkbutton $f.stm \
		-textvar [namespace current]::mc::ShowSideToMove \
		-variable [namespace parent]::layout(side-to-move) \
		-command [namespace code { RefreshBoard }]
	::ttk::checkbutton $f.coords \
		-textvar [namespace current]::mc::ShowCoordinates \
		-variable [namespace parent]::layout(coordinates) \
		-command [namespace code { ToggleShowCoords }]
	::ttk::checkbutton $f.embossed \
		-textvar [namespace current]::mc::Embossed \
		-variable [namespace parent]::layout(coords-embossed) \
		-command [namespace code { RefreshBoard }]
	set Widget(embossed) $f.embossed
	
	grid $f.border			-row  1 -column 1 -sticky w -columnspan 2
	grid $f.mv				-row  3 -column 1 -sticky w -columnspan 2
	grid $f.mvbar			-row  5 -column 2 -sticky w
	grid $f.stm				-row  7 -column 1 -sticky w -columnspan 2
	grid $f.coords			-row  9 -column 1 -sticky w -columnspan 2
	grid $f.embossed		-row 11 -column 2 -sticky w
	grid columnconfigure $f {0 3} -minsize $::theme::padx
	grid columnconfigure $f 1 -minsize 25
	grid columnconfigure $f 2 -weight 1
	grid rowconfigure $f {0 2 4 6 8 10 12} -minsize $::theme::pady

	# Highlighting #################################

	set f [::ttk::labelframe $path.hilite \
				-labelwidget [::ttk::label $path.lhilite \
				-textvar [namespace current]::mc::Highlighting]]

	::ttk::checkbutton $f.suggested \
		-textvar [namespace current]::mc::ShowSuggestedMove \
		-variable [namespace parent]::hilite(show-suggested) \
		-command [namespace code { ToggleShowSuggested }]
	::ttk::label $f.l_suggested -textvar [namespace current]::mc::SuggestedMove
	::ttk::spinbox $f.s_suggested \
		-from -10 \
		-to 10 \
		-textvariable [namespace parent]::hilite(suggested) \
		-width 3 \
		-exportselection false \
		-justify right \
		-command [namespace code { RefreshBoard }]
	bind $f.s_suggested <FocusOut> [namespace code { RefreshBoard }]
	::validate::spinboxInt $f.s_suggested
	::theme::configureSpinbox $f.s_suggested
	::ttk::label $f.l_selected -textvar [namespace current]::mc::SelectedSquare
	::ttk::spinbox $f.s_selected \
		-from -10 \
		-to 10 \
		-textvariable [namespace parent]::hilite(selected) \
		-width 3 \
		-exportselection false \
		-justify right \
		-command [namespace code { RefreshBoard }]
	bind $f.s_selected <FocusOut> [namespace code { RefreshBoard }]
	::validate::spinboxInt $f.s_selected
	::theme::configureSpinbox $f.s_selected
	set Widget(suggested) $f.s_suggested
	if {!$hilite(show-suggested)} { $Widget(suggested) configure -state disabled }

	grid $f.suggested		-row 1 -column 1 -sticky we -columnspan 3
	grid $f.l_suggested	-row 3 -column 1 -sticky we
	grid $f.s_suggested	-row 3 -column 3 -sticky we
	grid $f.l_selected	-row 5 -column 1 -sticky we
	grid $f.s_selected	-row 5 -column 3 -sticky we
	grid columnconfigure $f {0 2 4} -minsize $::theme::padx
	grid rowconfigure $f {0 2 4 6} -minsize $::theme::pady

	# Colors #######################################

	set f [::ttk::labelframe $path.colors -labelwidget [::ttk::checkbutton $path.lcolors \
				-textvar ::mc::Colors \
				-variable [namespace parent]::colors(locked) \
				-command [namespace code { ToggleLock }]]]
	::tooltip::tooltip $path.lcolors [namespace current]::mc::SupersedeSuggestion

	::ttk::button $f.background \
		-textvar ::mc::Background \
		-command [namespace code [list SelectBackgroundColor user $f.background $f.erase_background]]
	::ttk::button $f.erase_background \
		-image [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser] \
		-command [namespace code [list EraseBackgroundColor user $f.background $f.erase_background]]
	::ttk::button $f.border \
		-textvar [namespace current]::mc::Border \
		-command [namespace code [list SelectBorderColor user $f.border]]
	::ttk::button $f.coords_color \
		-textvar [namespace current]::mc::Coordinates \
		-command [namespace code [list SelectCoordsColor user $f.coords_color]] \
		-state disabled
	set Widget(coordinates) $f.coords_color
	if {$layout(coordinates) && $colors(locked)} {
		$Widget(coordinates) configure -state normal
		::tooltip::tooltip \
			$Widget(coordinates) \
			"${::mc::Color}: [extendColorName $colors(user,coordinates)]"
	}
	set Widget(background) $f.background
	set Widget(erase_background) $f.erase_background
	set Widget(border-color) $f.border
	ToggleLock

	grid $f.background			-row 1 -column 1 -sticky we
	grid $f.erase_background	-row 1 -column 3 -sticky we
	grid $f.border					-row 3 -column 1 -sticky we
	grid $f.coords_color			-row 5 -column 1 -sticky we
	grid columnconfigure $f 1 -weight 1
	grid columnconfigure $f {0 2 4} -minsize $::theme::padx
	grid rowconfigure $f {0 2 4 6} -minsize $::theme::pady

#	# Effects ######################################
#
#	set f [::ttk::labelframe $path.effects \
#				-labelwidget [::ttk::label $path.leffects \
#				-textvar [namespace current]::mc::Effects]]
#
#	::ttk::label $f.l_animation -textvar [::mc::var [namespace current]::mc::AnimationTime :]
#	::ttk::label $f.v_animation -textvar [namespace current]::Time
#	# NOTE: currently ::ttk::scale is causing a core dump
#	if {0} {
#		::ttk::scale $f.s_animation \
#			-class THorzScale \
#			-from 9 \
#			-to 100 \
#			-orient horizontal \
#			-value [expr {$effects(animation)/10.0}] \
#			-command [namespace code { UpdateAnimationTime }]
#	} else {
#		variable _animation
#		set _animation [expr {$effects(animation)/10.0}]
#		tk::scale $f.s_animation \
#			-showvalue 0 \
#			-variable [namespace current]::_animation \
#			-from 9 \
#			-to 100 \
#			-orient horizontal \
#			-takefocus 1 \
#			-command [namespace code { UpdateAnimationTime }]
#	}
#	UpdateAnimationTime $effects(animation)
#
#	grid $f.l_animation	-row 1 -column 1 -sticky nw
#	grid $f.v_animation	-row 1 -column 2 -sticky sw
#	grid $f.s_animation	-row 2 -column 1 -sticky swe -columnspan 2
#	grid columnconfigure $f {0 3} -minsize $::theme::padx
#	grid columnconfigure $f 2 -weight 1
#	grid rowconfigure $f {0 3} -minsize $::theme::pady
#	grid rowconfigure $f 2 -weight 1
	
	# Theme ########################################

	set f [::ttk::labelframe $path.theme -labelwidget [::ttk::label $path.ltheme -textvar ::mc::Theme]]

	set list [::ttk::frame $f.list]
	bind $list <Configure> [namespace code { BuildThemeListbox %W %h }]

	::ttk::button $f.save \
		-textvar [::mc::var [namespace current]::mc::SaveWorkingSet ...] \
		-command [namespace code [list SaveTheme $f.save]]
	::ttk::button $f.editList \
		-textvar [::mc::var [namespace current]::mc::EditList ...] \
		-command [namespace code [list EditStyles $f.editList theme]]
	set Widget(theme,save) $f.save
	set Widget(theme,edit) $f.editList
	ConfigThemeSelectionFrame

	grid $f.list		-row 1 -column 1 -sticky nswe
	grid $f.save		-row 3 -column 1 -sticky nswe
	grid $f.editList	-row 5 -column 1 -sticky nswe
	grid columnconfigure $f 1 -weight 1
	grid columnconfigure $f {0 2} -minsize $::theme::padx
	grid rowconfigure $f {0 2 4 6} -minsize $::theme::pady
	grid rowconfigure $f 1 -weight 1

	# Top Frame ####################################
	grid $path.layout			-row 1 -column 1 -sticky nswe
	grid $path.hilite			-row 3 -column 1 -sticky nswe
#	grid $path.effects		-row 5 -column 1 -sticky nswe
	grid $path.colors			-row 5 -column 1 -sticky nswe
	grid $path.theme			-row 1 -column 3 -sticky nswe -rowspan 9
	grid columnconfigure $path {0 2 4} -minsize $::theme::padx
	grid columnconfigure $path 3 -minsize 160 -weight 1
	grid rowconfigure $path {2 4} -minsize $::theme::pady

	bind $path.layout <Destroy> +[namespace code { forgetTextures }]
}


proc ScaleMove {scale delta} {
	$scale set [expr {[$scale get] + $delta}]
}


#proc UpdateAnimationTime {val} {
#	variable [namespace parent]::effects
#	variable Time
#
#	if {$val < 10} {
#		set effects(animation) 0
#	} else {
#		set effects(animation) [expr {int(round($val))*10}]
#	}
#
#	if {$effects(animation) == 0} {
#		set Time [set [namespace current]::mc::Off]
#	} else {
#		set Time "$effects(animation) ([set [namespace current]::mc::MilliSeconds])"
#	}
#}


proc ConfigureListbox {w} {
	variable FixedBackground

	set fg [$w cget -selectforeground]
	if {$fg eq "#ffffff"} { set fg $FixedBackground }

	$w itemconfigure 0 -background $FixedBackground -selectforeground $fg
	$w itemconfigure 1 -background $FixedBackground -selectforeground $fg
}


proc SetSelection {list n} {
	ConfigureListbox $list
	$list selection clear 0 end
	$list selection set $n
	$list activate $n
	$list see $n
}


proc BuildThemeListbox {f height} {
	variable [namespace parent]::theme::style
	variable [namespace parent]::theme::styleNames
	variable Widget

	if {$height <= 1} { return }
	bind $f <Configure> {}

	set l [tk::listbox .__BuildThemeListbox__should_be_unique_path__[clock milliseconds]]
	set font [$l cget -font]
	array set metrics [font metrics $font]

	tk::listbox $f.content \
		-height [expr {$height/($metrics(-linespace) + 1)}] \
		-selectmode single \
		-exportselection false \
		-yscrollcommand "$f.vsb set" \
		-listvariable [namespace parent]::theme::styleNames
	$f.content selection set [lsearch -exact $styleNames $style(identifier)]
	ConfigureListbox $f.content
	::ttk::scrollbar $f.vsb -orient vertical -command "$f.content yview"
	bind $f.vsb <ButtonPress-1> [list focus $f.content]
	set Widget(theme,list) $f.content
	grid $f.content	-row 0 -column 0 -sticky nswe
	grid $f.vsb			-row 0 -column 1 -sticky nswe
	grid columnconfigure $f 0 -weight 1
	grid rowconfigure $f 1 -weight 1
	bind $f.content <<ListboxSelect>> [namespace code { ThemeSelected %W }]
	bind $f.content <Destroy> [namespace code { array unset Widget theme,* }]
	TabChanged $Widget(tabs)
}


proc makePieceSetSelectionFrame {path} {
	variable Widget
	variable PieceSetListCount

	[namespace parent]::pieceset::makePieceSelectionFrame $path $PieceSetListCount
	bind $path <<PieceSetChanged>> [namespace code { PieceSetSelected %d }]
	set Widget(pieceset) $path
}


proc ConfigStyleSelectionFrame {which} {
	variable Widget
	variable ModifiedBackground
	variable ModifiedForeground

	if {$which eq "theme"} {
		ConfigThemeSelectionFrame
	} else {
		if {[lindex [$Widget($which,list) curselection] 0] == 0} {
			$Widget($which,ws) configure \
				-textvar [::mc::var [namespace current]::mc::ChangeWorkingSet ...] \
				-command [namespace code [list OpenConfigDialog $which]]
		} else {
			$Widget($which,ws) configure \
				-textvar [namespace current]::mc::CopyToWorkingSet \
				-command [namespace code [list CopyToWorkingSet $which]]
		}

		if {[[namespace parent]::isWorkingSet $which]} {
			$Widget($which,save) configure -state normal
		} else {
			$Widget($which,save) configure -state disabled
		}

		if {[[namespace parent]::workingSetIsModified $which]} {
			$Widget($which,list) itemconfigure 0 \
				-foreground $ModifiedBackground \
				-selectforeground $ModifiedForeground \
				-selectbackground $ModifiedBackground \
				;
		} else {
			$Widget($which,list) itemconfigure 0 -foreground {} -selectbackground {}
		}
	}
}


proc makeStyleSelectionFrame {path} {
	variable SquareSize
	variable Widget

	foreach {which label} {square SquareStyle piece PieceStyle} {
		variable [namespace parent]::${which}::style
		variable [namespace parent]::${which}::styleNames

		set f [::ttk::labelframe $path.$which \
					-labelwidget [::ttk::label $path.l$which -textvar [namespace current]::mc::$label] \
					-padding $::theme::padding]
		tk::listbox $f.content \
			-selectmode single \
			-exportselection false \
			-yscrollcommand "$f.vsb set" \
			-listvariable [namespace parent]::${which}::styleNames
		$f.content selection set [lsearch -exact $styleNames $style(identifier)]
		ConfigureListbox $f.content
		bind $f.content <<ListboxSelect>> [namespace code [list ${label}Selected $f.content]]
		::ttk::scrollbar $f.vsb -orient vertical -command "$f.content yview"
		bind $f.vsb <ButtonPress-1> [list focus $f.content]
		::ttk::button $f.ws
		::ttk::button $f.save \
			-textvar [::mc::var [namespace current]::mc::SaveWorkingSet ...] \
			-command [namespace code [list SaveWorkingSet $f.save $which]]
		::ttk::button $f.editList \
			-textvar [::mc::var [namespace current]::mc::EditList ...] \
			-command [namespace code [list EditStyles $f.editList $which]]
		set Widget($which,ws) $f.ws
		set Widget($which,list) $f.content
		set Widget($which,edit) $f.editList
		set Widget($which,save) $f.save

		grid $f.content	-row 0 -column 0 -sticky nswe
		grid $f.vsb			-row 0 -column 1 -sticky nswe
		grid $f.ws			-row 2 -column 0 -sticky nswe -columnspan 2
		grid $f.save		-row 4 -column 0 -sticky nswe -columnspan 2
		grid $f.editList	-row 6 -column 0 -sticky nswe -columnspan 2
		grid columnconfigure $f 0 -weight 1
		grid rowconfigure $f {1 3 5} -minsize $::theme::pady
		grid rowconfigure $f 0 -weight 1

		ConfigStyleSelectionFrame $which
	}

	grid $path.square	-row 0 -column 1 -sticky nswe
	grid $path.piece	-row 0 -column 3 -sticky nswe
	grid columnconfigure $path {0 2 4} -minsize $::theme::padx
	grid columnconfigure $path {1 3} -weight 1
	grid rowconfigure $path 0 -weight 1
	grid rowconfigure $path 1 -minsize $::theme::pady
}


proc CopyToWorkingSet {which} {
	variable Widget

	[namespace parent]::copyToWorkingSet $which
	SetSelection $Widget($which,list) 0
	ConfigStyleSelectionFrame $which
}


proc OpenConfigDialog {which} {
	variable SquareSize
	variable Widget
	variable ChangeWS

	$Widget($which,ws) configure -state disabled
	$Widget($which,edit) configure -state disabled
	$Widget($which,list) configure -state disabled
	$Widget($which,list) configure -state disabled

	if {[incr ChangeWS] == 1} {
		$Widget(theme,list) configure -state disabled
		$Widget(theme,save) configure -state disabled
		$Widget(theme,edit) configure -state disabled
	}

	[namespace parent]::acquireWorkingSet $which

	[namespace parent]::${which}::openConfigDialog \
		$Widget($which,ws) \
		$SquareSize \
		[namespace code [list ConfigDialogClosed $Widget($which,ws) $which]] \
		[namespace code [list ApplyWorkingSet $which]] \
		[namespace code [list ResetWorkingSet $which]] \
		;
}


proc EnterName {parent labelText} {
	variable Identifier

	set Identifier ""
	set dlg [tk::toplevel ${parent}.enterName -class Scidb]
	set f [::ttk::frame $dlg.top]
	::ttk::label $f.l -text $labelText
	::ttk::entry $f.e \
		-validate key \
		-validatecommand { return [expr {"%P" ne "|"}] } \
		-invalidcommand { bell } \
		;
	pack $f -fill both -expand yes
	grid $f.l -row 1 -column 1 -sticky w
	grid $f.e -row 3 -column 1 -sticky ew
	grid columnconfigure $f {0 3} -minsize $::theme::padx
	grid columnconfigure $f 1 -weight 1
	grid rowconfigure $f {0 2 4} -minsize $::theme::pady
	bind $f.e <Return> "$dlg.ok invoke"
	bind $dlg <Escape> "$dlg.cancel invoke"

	::widget::dialogButtons $dlg {ok cancel} ok false
	$dlg.cancel configure -command "destroy $dlg"
	$dlg.ok configure -command "
		set [namespace current]::Identifier \[string trim \[$f.e get\]\]
		destroy $dlg
	"

	wm withdraw $dlg
	wm title $dlg "$::scidb::app"
	wm transient $dlg [winfo toplevel $parent]
	catch { wm attributes $dlg -type dialog }
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $f.e
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg

	return $Identifier
}


proc SaveTheme {parent} {
	variable [namespace parent]::theme::styleNames
	variable Identifier
	variable Widget

	if {[[namespace parent]::isWorkingSet piece]} {
		set msg [format	$mc::CannotUsePieceWorkingSet \
								[set [namespace parent]::mc::WorkingSet]]
		::dialog::info -parent $parent -message $msg -detail $mc::ChooseAnotherPieceStyle
		return
	}
	if {[[namespace parent]::isWorkingSet square]} {
		set msg [format	$mc::CannotUseSquareWorkingSet \
								[set [namespace parent]::mc::WorkingSet]]
		::dialog::info -parent $parent -message $msg -detail $mc::ChooseAnotherSquareStyle
		return
	}

	set name [EnterName $parent "[set [namespace current]::mc::NameOfThemeStyle]:"]
	if {[llength $name] == 0} { return }

	set identifier [[namespace parent]::saveWorkingSet $name theme]
	SetSelection $Widget(theme,list) [lsearch -exact $styleNames $identifier]
	ThemeSelected $Widget(theme,list) $styleNames
}


proc SaveWorkingSet {parent which} {
	if {$which eq "piece"} { SavePieceStyle $parent } else { SaveSquareStyle $parent }
}


proc SavePieceStyle {parent} {
	variable [namespace parent]::piece::styleNames
	variable Widget

	set name [EnterName $parent "[set [namespace current]::mc::NameOfPieceStyle]:"]
	if {[llength $name] == 0} { return }

	set identifier [[namespace parent]::saveWorkingSet $name piece]
	SetSelection $Widget(piece,list) [lsearch -exact $styleNames $identifier]
	PieceStyleSelected $Widget(piece,list) $styleNames
	ConfigStyleSelectionFrame piece
}


proc SaveSquareStyle {parent} {
	variable [namespace parent]::square::style
	variable [namespace parent]::layout
	variable [namespace parent]::colors
	variable Identifier
	variable Widget

	set showBorder	$layout(border)
	set showCoords	$layout(coordinates)

	if {!$showCoords} { set layout(coordinates) true }
	if {!$showBorder} { set layout(border) true }
	ConfigureBoard
	RefreshBoard

	set Identifier ""
	set dlg [tk::toplevel ${parent}.saveSquareStyle -class Scidb]
	set f [::ttk::frame $dlg.top]
	pack $f -fill both -expand yes

	set hints [::ttk::labelframe $f.hints -text [set [namespace current]::mc::ChooseColors]]
	::ttk::button $hints.background \
		-text $::mc::Background \
		-command [namespace code [list SelectBackgroundColor hint $hints.background $hints.erase_bg]]
	::ttk::button $hints.erase_bg \
		-image [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser] \
		-command [namespace code [list EraseBackgroundColor hint $hints.background $hints.erase_bg]]
	::ttk::button $hints.border \
		-text [set [namespace current]::mc::Border] \
		-command [namespace code [list SelectBorderColor hint $hints.border]]
	::ttk::button $hints.coords \
		-text [set [namespace current]::mc::Coordinates] \
		-command [namespace code [list SelectCoordsColor hint $hints.coords]]
	
	grid $hints.background	-row 1 -column 1 -sticky ew
	grid $hints.erase_bg		-row 1 -column 3
	grid $hints.border		-row 3 -column 1 -sticky ew
	grid $hints.coords		-row 5 -column 1 -sticky ew
	grid columnconfigure $hints {0 2 4} -minsize $::theme::padx
	grid columnconfigure $hints 1 -weight 1
	grid rowconfigure $hints {0 2 4 6} -minsize $::theme::pady

	set lbl [::ttk::label $f.lbl -text "[set [namespace current]::mc::NameOfSquareStyle]:"]
	set entry [::ttk::entry $f.entry]

	grid $hints	-row 1 -column 1 -sticky ew
	grid $lbl	-row 3 -column 1 -sticky w
	grid $entry	-row 5 -column 1 -sticky ew
	grid columnconfigure $f {0 2} -minsize $::theme::padx
	grid columnconfigure $f 1 -weight 1
	grid rowconfigure $f {0 2 4 6} -minsize $::theme::pady

	bind $entry <Return> "$dlg.ok invoke"
	bind $dlg <Escape> "$dlg.cancel invoke"

	::widget::dialogButtons $dlg {ok cancel} ok false
	$dlg.cancel configure -command "destroy $dlg"
	$dlg.ok configure -command "
		set name \[string trim \[$entry get\]\]
		if {\[llength \$name\]} {
			set [namespace current]::Identifier \[[namespace parent]::saveWorkingSet \$name square\]
			destroy $dlg
		}
	"

	wm withdraw $dlg
	wm title $dlg "$::scidb::app"
	::util::place $dlg center $parent
	wm transient $dlg [winfo toplevel $parent]
	catch { wm attributes $dlg -type dialog }
	wm deiconify $dlg
	focus $entry
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg

	if {[llength $Identifier]} {
		variable [namespace parent]::square::styleNames
		SetSelection $Widget(square,list) [lsearch -exact $styleNames $Identifier]
		SquareStyleSelected $Widget(square,list) $styleNames
		ConfigStyleSelectionFrame square
	}

	if {!$showCoords} { set layout(coordinates) false }
	if {!$showBorder} { set layout(border) false }

	if {$colors(locked)} {
		foreach attr {background-tile background-color border-tile border-color coordinates} {
			set colors(hint,$attr) $colors(user,$attr)
		}
	}

	ConfigureBoard
	RefreshBoard
}


proc ApplyWorkingSet {which {apply false}} {
	variable Widget

	if {$apply} {
		[namespace parent]::changeWorkingSet $which
	}

	RefreshBoard

	if {$which eq "square"} {
		[namespace parent]::piece::notifySquareChanged
	}
}


proc ResetWorkingSet {which} {
	[namespace parent]::resetWorkingSet $which
	RefreshBoard

	if {$which eq "square"} {
		[namespace parent]::piece::notifySquareChanged
	}
}


proc ConfigDialogClosed {parent which} {
	variable ChangeWS
	variable Widget

	[namespace parent]::releaseWorkingSet $which

	if {![winfo exists $parent]} { return }

	$parent configure -state normal
	$Widget($which,edit) configure -state normal
	$Widget($which,list) configure -state normal
	$Widget($which,list) configure -state normal

	if {[incr ChangeWS -1] == 0} {
		$Widget(theme,save) configure -state normal
		$Widget(theme,edit) configure -state normal
		$Widget(theme,list) configure -state normal
	}

	ConfigStyleSelectionFrame $which
}


proc makeFrame {path} {
	variable BoardSize
	variable SquareSize
	variable Widget
	variable ChangeWS

	set top [::ttk::frame $path.top]
	pack $top

	[namespace parent]::prepareNameLists
	set ChangeWS 0

	# Notebook #####################################
	set nb [::ttk::notebook $top.nb -takefocus 1]
	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb]]
	set Widget(tabs) $nb

	makeBasicFrame [::ttk::frame $nb.basic]
	makeStyleSelectionFrame [::ttk::frame $nb.styles]
	makePieceSetSelectionFrame [::ttk::frame $nb.pieceSet]

	$nb add $nb.basic		-sticky nsew -padding $::theme::padding
	$nb add $nb.styles	-sticky nsew -padding $::theme::padding
	$nb add $nb.pieceSet	-sticky nsew -padding [expr {3*$::theme::padding}]
	::widget::notebookTextvarHook $nb 0 [namespace current]::mc::Basic
	::widget::notebookTextvarHook $nb 1 [namespace current]::mc::Styles
	::widget::notebookTextvarHook $nb 2 ::mc::PieceSet

	# Preview ######################################
	set f [::ttk::labelframe $top.preview \
				-labelwidget [::ttk::label $top.lpreview -textvar ::mc::Preview]]
	set Widget(canv,preview) [tk::canvas $f.board -width $BoardSize -borderwidth 1 -relief solid]
	::theme::configureCanvas $f.board
	$f.board xview moveto 0
	$f.board yview moveto 0
	pack $f.board -padx $::theme::padx -pady $::theme::pady -fill both -expand yes

	bind $f.board <Configure> [namespace code { DrawBoard %h %w }]
	bind $f.board <Destroy> [namespace code { array unset Widget }]

	# Top Frame ####################################
	grid $top.nb		-row 1 -column 1 -sticky nswe
	grid $top.preview	-row 1 -column 3 -sticky nswe
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid columnconfigure $top 3 -weight 1
	grid rowconfigure $top {0 2} -minsize $::theme::pady
}


proc isOpen {} {
	variable Widget
	return [info exists Widget(dialog)]
}


proc openConfigDialog {parent applyProc} {
	variable Widget

	[namespace parent]::acquire
	set path $parent
	if {$parent ne "."} { set path "$path." }
	set dlg ${path}boardConfigDialog
	set Widget(dialog) $dlg
	tk::toplevel $dlg -class Dialog
	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list Cancel $dlg $applyProc]]
	bind $dlg <Escape> [namespace code [list Cancel $dlg $applyProc]]
	bind $dlg <Destroy> "if {{$dlg} eq {%W}} { array unset [namespace current]::Widget }"
	wm withdraw $dlg
	wm title $dlg "$::scidb::app: [set [namespace current]::mc::BoardSetup]"
	wm transient $dlg [winfo toplevel $parent]
	wm iconname $dlg ""
	wm resizable $dlg 0 0
	makeFrame $dlg
	::widget::dialogButtons $dlg {ok cancel apply reset} apply
	$dlg.cancel configure -command [namespace code [list Cancel $dlg $applyProc]]
	$dlg.ok configure -command "
		[namespace current]::Apply {$applyProc}
		destroy $dlg"
	$dlg.apply configure -command [namespace code [list Apply $applyProc]]
	$dlg.reset configure -command [namespace code [list Reset $applyProc]]
	wm deiconify $dlg
}


proc Cancel {dlg applyProc} {
	[namespace parent]::release
	destroy $dlg
	eval $applyProc
}


proc Apply {applyProc} {
	variable [namespace parent]::needRefresh
	variable Widget

	$Widget(dialog) configure -cursor watch
	[namespace parent]::apply
	foreach which {piece lite dark white black} {
		set needRefresh($which,all) true
	}
	[namespace parent]::setupSquares all
	[namespace parent]::setupPieces all
	eval $applyProc
	$Widget(dialog) configure -cursor {}
}


proc Reset {applyProc} {
	variable [namespace parent]::needRefresh
	variable Widget

	$Widget(dialog) configure -cursor watch
	[namespace parent]::reset
	foreach which {piece lite dark white black} {
		set needRefresh($which,all) true
	}
	[namespace parent]::setupSquares all
	[namespace parent]::setupPieces all
	setBackground $Widget(canv,preview) window
	setBackground $Widget(canv,border) border
	eval $applyProc
	$Widget(dialog) configure -cursor {}
	SetCurrentSelection theme
	SetCurrentSelection piece
	SetCurrentSelection square
	ConfigStyleSelectionFrame theme
	ConfigStyleSelectionFrame piece
	ConfigStyleSelectionFrame square
	RefreshBoard
}


proc SetCurrentSelection {which} {
	variable Widget

	set identifier [[namespace parent]::currentStyle $which]
	if {$identifier eq [set [namespace parent]::workingSetId]} {
		set index 0
	} elseif {$identifier eq [set [namespace parent]::defaultId]} {
		set index 1
	} else {
		variable [namespace parent]::${which}::styleNames
		set index [lsearch -exact $styleNames $identifier]
	}
	SetSelection $Widget($which,list) $index
}


proc TabChanged {nb} {
	variable Widget

	if {[string match *pieceSet [$nb select]]} {
		[namespace parent]::pieceset::updatePieceSet [$nb select]
	} elseif {[string match *styles [$nb select]]} {
		SetCurrentSelection piece
		SetCurrentSelection square
	} elseif {[info exist Widget(theme,list)]} {
		SetCurrentSelection theme
	}

	focus $nb

	if {[string match *style* [$nb select]]} {
		ConfigStyleSelectionFrame piece
		ConfigStyleSelectionFrame square
	}
}


proc ToggleLock {} {
	variable [namespace parent]::square::style
	variable [namespace parent]::colors
	variable [namespace parent]::layout
	variable Widget

	if {$colors(locked)} {
		$Widget(background) configure -state normal
		foreach attr {background-tile background-color border-tile border-color coordinates} {
			set colors(hint,$attr) $colors(user,$attr)
		}
		SetRecent window $style(hint,background-color) $style(hint,background-tile)
		SetRecent border $style(hint,border-color) $style(hint,border-tile)
	} else {
		$Widget(background) configure -state disabled
		foreach attr {background-tile background-color border-tile border-color coordinates} {
			set colors(hint,$attr) $style(hint,$attr)
		}
	}
	if {$colors(locked) && [llength $colors(user,background-color)]} {
		$Widget(erase_background) configure -state normal
	} else {
		$Widget(erase_background) configure -state disabled
	}
	if {$colors(locked) && $layout(coordinates)} {
		$Widget(coordinates) configure -state normal
	} else {
		$Widget(coordinates) configure -state disabled
	}
	if {$colors(locked) && $layout(border)} {
		$Widget(border-color) configure -state normal
	} else {
		$Widget(border-color) configure -state disabled
	}

	if {[info exists Widget(canv,preview)]} { RefreshBoard }
	SetColorTooltips
}


proc SetColorTooltips {} {
	variable [namespace parent]::colors
	variable Widget

	if {$colors(locked)} {
		if {[llength $colors(user,background-tile)]} {
			::tooltip::tooltip \
				$Widget(background) \
				"${::mc::Texture}: [file join tile {*}$colors(user,background-tile)]"
		} elseif {[llength $colors(user,background-color)]} {
			::tooltip::tooltip \
				$Widget(background) \
				"[set [namespace current]::mc::SolidColor]: \
				[extendColorName $colors(user,background-color)]"
		}
		if {[llength $colors(user,border-tile)]} {
			::tooltip::tooltip \
				$Widget(border-color) \
				"${::mc::Texture}: [file join tile {*}$colors(user,border-tile)]"
		} elseif {[llength $colors(user,border-color)]} {
			::tooltip::tooltip \
				$Widget(border-color) \
				"[set [namespace current]::mc::SolidColor]: \
				[extendColorName $colors(user,border-color)]"
		}
		if {[llength $colors(user,coordinates)]} {
			::tooltip::tooltip \
				$Widget(coordinates) \
				"${::mc::Color}: [extendColorName $colors(user,coordinates)]"
		}
	}
}


proc ToggleShowSuggested {} {
	variable [namespace parent]::hilite
	variable Widget

	RefreshBoard

	if {$hilite(show-suggested)} {
		$Widget(suggested) configure -state normal
	} else {
		$Widget(suggested) configure -state disabled
	}
}


proc ToggleShowBorder {} {
	variable [namespace parent]::layout
	variable [namespace parent]::colors
	variable Widget

	ConfigureBoard
	RefreshBoard

	if {$layout(border) && $colors(locked)} {
		$Widget(border-color) configure -state normal
	} else {
		$Widget(border-color) configure -state disabled
	}
}


proc ToggleShowCoords {} {
	variable [namespace parent]::layout
	variable [namespace parent]::colors
	variable Widget

	ConfigureBoard
	RefreshBoard

	if {$layout(coordinates)} {
		$Widget(embossed) configure -state normal
	} else {
		$Widget(embossed) configure -state disabled
	}

	if {$layout(coordinates) && $colors(locked)} {
		$Widget(coordinates) configure -state normal
		::tooltip::tooltip \
			$Widget(coordinates) \
			"${::mc::Color}: extendColorName $colors(user,coordinates)]"
	} else {
		$Widget(coordinates) configure -state disabled
		::tooltip::tooltip $Widget(coordinates) ""
	}
}


proc EditStyles {parent which} {
	variable [namespace parent]::${which}::styleNames
	variable Widget
	variable EditStylePath
	variable icon::15x15::ArrowUp
	variable icon::15x15::ArrowDown
	variable NameList

	$parent configure -state disabled
	set dlg [toplevel $EditStylePath]
	wm withdraw $dlg
	set top [::ttk::frame $dlg.top]
	set NameList [lreplace [concat $styleNames] 0 1]
	set current [[namespace parent]::currentStyle $which]

	# left side ####################################
	set lt [::ttk::frame $top.list -padding $::theme::padding]
	tk::listbox $lt.content \
		-width 0 \
		-setgrid true \
		-height [min 15 [llength $NameList]] \
		-selectmode browse \
		-exportselection false \
		-yscrollcommand [list ::scrolledframe::sbset $lt.vsb] \
		-listvariable [namespace current]::NameList
	set n [$Widget($which,list) curselection]
	if {$n < 2} { set n 0 } else { incr n -2 }
	$lt.content selection set $n
	$lt.content activate $n
	$lt.content see $n
	bind $lt.content <<ListboxSelect>> [namespace code [list ConfigureButtons $which %W]]
	::ttk::scrollbar $lt.vsb -orient vertical -command "$lt.content yview"

	grid $lt.content -row 1 -column 1 -sticky ewns
	grid $lt.vsb -row 1 -column 2 -sticky ns

	grid columnconfigure $lt 1 -weight 1
	grid rowconfigure $lt 1 -weight 1
	
	# right side ###################################
	set rt [::ttk::frame $top.buttons]
#	::ttk::button $rt.rename \
#		-textvar ::mc::Rename \
#		-command [namespace code [list RenameStyleEntry $rt.rename $lt.content $which]]
	::ttk::button $rt.delete \
		-textvar ::mc::Delete \
		-command [namespace code [list DeleteStyle $lt.content $which]]
	::ttk::button $rt.up \
		-image [::icon::makeStateSpecificIcons $ArrowUp] \
		-command [namespace code [list MoveStyleEntry $lt.content -1 $which]]
	::ttk::button $rt.down \
		-image [::icon::makeStateSpecificIcons $ArrowDown] \
		-command [namespace code [list MoveStyleEntry $lt.content +1 $which]]
	::ttk::button $rt.show \
		-textvar ::board::options::mc::Show \
		-command [namespace code [list StyleSelected $which $lt.content true]]

#	grid $rt.rename	-row 1 -column 1 -sticky we
	grid $rt.delete	-row 1 -column 1 -sticky we
	grid $rt.up			-row 3 -column 1 -sticky we
	grid $rt.down		-row 5 -column 1 -sticky we
	grid $rt.show		-row 7 -column 1 -sticky we
	grid rowconfigure $rt {0 2 6 8} -minsize $::theme::pady
	grid rowconfigure $rt {2 6} -minsize 15
	grid rowconfigure $rt 8 -weight 1
	grid columnconfigure $rt 2 -minsize $::theme::padx

	set Widget(buttons) $rt
	ConfigureButtons $which $lt.content

	# top frame ####################################

	pack $top.list -side left -fill both -expand yes
	pack $top.buttons -side left -fill y -expand no
	pack $top -fill both -expand yes
	pack [::ttk::separator $dlg.sep] -fill x
	pack [::ttk::button $dlg.ok -textvar ::mc::Close -command "destroy $dlg"] -pady $::theme::pady

	# bindings
	bind $dlg <Escape> [list destroy $dlg]
	bind $dlg <Destroy> "
		if {{$dlg} == {%W} && \[winfo exists $parent\]} {
			$parent configure -state normal
			[namespace current]::StyleSelected $which $Widget($which,list)
		}"

	# map window ###################################
	::util::place $dlg center $parent
	wm transient $dlg [winfo toplevel $parent]
	wm protocol $dlg WM_DELETE_WINDOW "destroy $dlg"
	wm title $dlg $::scidb::app
 	update idletasks
 	scan [wm grid $dlg] "%d %d %d %d" bw bh wi hi
 	wm minsize $dlg $bw $bh
 	wm deiconify $dlg
	::ttk::grabWindow $dlg
	focus $lt.content
   tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc ConfigureButtons {which listbox} {
	variable Widget
	variable NameList

	set index [lindex [$listbox curselection] 0]
	set identifier [lindex $NameList $index]

	if {$which ne "theme"} {
		if {[llength [[namespace parent]::referees $which $identifier]]} {
			$Widget(buttons).delete configure -state disabled
		} else {
			$Widget(buttons).delete configure -state normal
		}
	}

	if {$index == 0} {
		$Widget(buttons).up configure -state disabled
	} else {
		$Widget(buttons).up configure -state normal
	}
	if {$index == [llength $NameList] - 1} {
		$Widget(buttons).down configure -state disabled
	} else {
		$Widget(buttons).down configure -state normal
	}
}


proc DeleteFile {listbox filename} {
	if {[catch { file delete $filename }]} {
		# this should not happen
		::dialog::error \
			-parent $listbox \
			-message [format [set [namespace current]::mc::NoPermission] $filename]
		return false
	}

	return true
}


proc DeleteStyle {listbox which} {
	variable [namespace parent]::${which}::styleNames
	variable NameList
	variable Widget

	set identifier [lindex $NameList [$listbox curselection]]
	set filename [[namespace parent]::filename $identifier $which]

	if {![file writable $filename]} {
		::dialog::info \
			-parent $listbox \
			-message [format [set [namespace current]::mc::CannotDelete] $identifier] \
			-detail [format [set [namespace current]::mc::IsWriteProtected] $filename]
		return
	}
	set reply [::dialog::warning \
					-parent $listbox \
					-message [format [set [namespace current]::mc::ConfirmDelete] $identifier] \
					-detail [format [set [namespace current]::mc::YouCannotReverse] $filename]]
	if {$reply ne "ok" || ![DeleteFile $listbox $filename]} { return false }
	set shortId [lindex $styleNames [$Widget($which,list) curselection]]
	set longId [[namespace parent]::mapToLongId $shortId $which]
	[namespace parent]::removeStyle $identifier $which
	ResetSelection $longId $which
	set NameList [lreplace [concat $styleNames] 0 1]
	if {[llength $NameList] == 0} { return [destroy [winfo toplevel $listbox]] }

	if {[llength [$listbox curselection]] == 0} {
		$listbox selection set end
		$listbox activate end
		$listbox see end
	}
	ConfigureButtons $which $listbox
}


proc ResetSelection {longId which} {
	variable [namespace parent]::${which}::styleNames
	variable Widget

	set index -1
	catch { set index [lsearch -exact $styleNames [[namespace parent]::mapToShortId $longId $which]] }
	if {$index == -1} { set index 0 }
	SetSelection $Widget($which,list) $index
}


#proc RenameStyleEntry {parent listbox which} {
#	variable [namespace parent]::${which}::styleNames
#	variable NameList
#
#	set identifier [lindex $NameList [$listbox curselection]]
#	set filename [[namespace parent]::filename $identifier $which]
#	if {![file writable $filename]} {
#		::dialog::info \
#			-parent $listbox \
#			-message [format [set [namespace current]::mc::CannotRename] $identifier] \
#			-detail [format [set [namespace current]::mc::IsWriteProtected] $filename]
#		return
#	}
#	set name [[namespace parent]::mapToName $identifier $which]
#	set mcid "[namespace current]::mc::NameOf[string toupper $which 0 0]Style"
#	set newName [EnterName $parent "[set $mcid]:"]
#	if {[llength $newName] == 0 || $name eq $newName} { return }
#	if {![DeleteFile $listbox $filename]} { return }
#	[namespace parent]::acquireWorkingSet $which
#	[namespace parent]::selectStyle [[namespace parent]::mapToLongId $identifier $which] $which
#	[namespace parent]::copyToWorkingSet $which
#	set shortId [[namespace parent]::saveWorkingSet $newName $which]
#	[namespace parent]::releaseWorkingSet $which
#	[namespace parent]::removeStyle $identifier $which
#	ResetSelection [[namespace parent]::mapToLongId $shortId $which] $which
#	set NameList [lreplace [concat $styleNames] 0 1]
#	set n [lsearch -exact $NameList $shortId]
#	$listbox selection clear 0 end
#	$listbox selection set $n
#	$listbox activate $n
#	$listbox see $n
#}


proc MoveStyleEntry {list delta which} {
	variable NameList
	variable Widget

	set name [GetStyleName $which [$Widget($which,list) curselection]]
	set longId [[namespace parent]::mapToLongId $name $which]
	set i [lindex [$list curselection] 0]
	set k [expr {$i + $delta}]
	set identifier [lindex $NameList $i]
	set NameList [lreplace $NameList $i $i]
	set NameList [linsert $NameList $k $identifier]
	$list selection clear $i
	$list selection set $k
	$list see $k
	ConfigureButtons $which $list
	[namespace parent]::reorder $NameList $which
	ResetSelection $longId $which
}


proc MakeHiliteRect {canv tag} {
	variable [namespace parent]::hilite
	variable SquareSize
	variable Position

	$canv delete $tag:h

	if {$tag ne "suggested" || $hilite(show-suggested)} {
		[namespace parent]::stuff::makeHiliteRect \
			$canv \
			$tag \
			h \
			$SquareSize \
			$Position(x,$tag) \
			$Position(y,$tag)
		$canv itemconfigure $tag:h -state normal
		$canv raise piece
		$canv raise shadow
	}

	return
}


proc RefreshBoard {} {
	variable [namespace parent]::layout
	variable [namespace parent]::colors
	variable [namespace parent]::square::style
	variable Widget

	set canv $Widget(canv,preview)
	set board $Widget(board)
	set border $Widget(canv,border)

	$canv itemconfigure stm		-state hidden
	$canv itemconfigure mv		-state hidden
	$canv itemconfigure shadow	-state hidden
	$canv itemconfigure mvbar	-state hidden
#	$canv itemconfigure white	-state hidden
#	$canv itemconfigure black	-state hidden

	if {$layout(side-to-move)}		{ $canv itemconfigure stm		-state normal }
	if {$layout(material-values)}	{ $canv itemconfigure mv		-state normal }
	if {$layout(border)}				{ $canv itemconfigure shadow	-state normal }

	foreach w [list $canv $border] {
		$w itemconfigure coords		-state hidden
		$w itemconfigure wcoords	-state hidden
		$w itemconfigure bcoords	-state hidden
		$w itemconfigure coords		-fill $colors(hint,coordinates)

		if {$layout(coordinates)} {
			$w itemconfigure coords -state normal

			if {$layout(coords-embossed)} {
				scan $colors(hint,coordinates) "\#%2x%2x%2x" r g b
				set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]

				if {$luma >= 128} { $w itemconfigure bcoords -state normal }
				if {$luma <  128} { $w itemconfigure wcoords -state normal }
			}
		}
	}

	if {$layout(material-values) && $layout(material-bar)} {
		$canv itemconfigure mvbar -state normal
	}

	if {[llength $colors(user,background-color)]} {
		$canv configure -background $colors(user,background-color)
	} else {
		 $canv configure -background [::theme::getBackgroundColor]
	}

	if {$layout(material-values)} {
		$Widget(bar) configure -state normal
	} else {
		$Widget(bar) configure -state disabled
	}

	MakeHiliteRect $board selected
	MakeHiliteRect $board suggested

	$board raise black
	$board raise white

	setBackground $Widget(canv,preview) window
	if {[llength $colors(hint,background-color)]} {
		$Widget(canv,preview) configure -background $colors(hint,background-color)
	} elseif {[llength $colors(hint,background-tile)] == 0} {
		::theme::configureBackground $Widget(canv,preview)
	}

	setBackground $Widget(canv,border) border
	if {[llength $colors(hint,border-color)]} {
		$Widget(canv,border) configure -background $colors(hint,border-color)
	}
}


proc ConfigureBoard {} {
	variable [namespace parent]::layout
	variable SquareSize
	variable Widget
	variable BorderWidth

	set border $Widget(canv,border)
	set preview $Widget(canv,preview)
	set board $Widget(board)

	set w [winfo width $preview]
	set h [winfo height $preview]

	# compute dimensions ###########################
	set x1 [expr {($w - 4*$SquareSize)/2}]
	set y1 [expr {($h - 4*$SquareSize)/2}]
	set x2 [expr {$x1 + 4*$SquareSize}]
	set y2 [expr {$y1 + 4*$SquareSize}]

	if {$layout(border)} {
		if {$layout(coordinates)} {
			set bdw 20
		} else {
			set bdw 12
		}
	} else {
		set bdw 0
	}

	if {$BorderWidth == $bdw} { return }
	set BorderWidth bdw

	# configure windows ############################
	set u1 [expr {$x1 - $bdw}]
	set u2 [expr {$x2 + $bdw}]
	set v1 [expr {$y1 - $bdw}]
	set v2 [expr {$y2 + $bdw}]

	$preview coords board $u1 $v1
	$border configure -width [expr {$u2 - $u1}] -height [expr {$v2 - $v1}]
	$border xview moveto 0
	$border yview moveto 0
	$border coords board $bdw $bdw
	$border delete shadow
	$board configure -width [expr {$x2 - $x1}] -height [expr {$y2 - $y1}]

	# draw border lines ############################
	drawBorderlines $border [expr {4*$SquareSize + 2*$bdw}]

	# configure side to move #######################
	set stmSize 19	;#[expr {$SquareSize/4 + 5}]
	set stmGap	7	;#[expr {$stmSize/3}]
	set x [expr {$x2 + $stmGap + $bdw}]
	set y [expr {$y1 + $stmGap}]
	$preview coords stmb $x $y
	set y [expr {$y2 - $stmSize - $stmGap}]
	$preview coords stmw $x $y

	# configure material values ####################
	set mvGap	3
	set mvS		16
	set x3		[expr {$x2 + $stmGap + $bdw}]
	set y3		[expr {$y1 + $stmSize + 2*$stmGap + 1}]
	set x4		[expr {$x3 + $stmSize - 1}]
	set y4		[expr {$y2 - $stmSize - 2*$stmGap - 1}]

	$preview coords mvbar1 $x3 $y3 $x4 $y4
	incr x3; incr y3
	$preview coords mvbar2 $x3 $y3 $x4 $y4
	incr x4 -1; incr y4 -1
	$preview coords mvbar3 $x3 $y3 $x4 $y4

	set x $x3
	set y [expr {$y1 + 2*$SquareSize - 2*$mvS - $mvGap - $mvGap/2}]
	foreach {i c} {0 b 1 b 2 w 3 w} {
		$preview coords mv$i $x $y
		incr y [expr {$mvS + $mvGap}]
	}
}


proc DrawBoard {h w} {
	variable [namespace parent]::colors
	variable [namespace parent]::needRefresh
	variable ::application::board::stmWhite
	variable ::application::board::stmBlack
	variable SquareSize
	variable InitialPosition
	variable Widget
	variable Position
	variable HilitePos
	variable BorderWidth

	if {$h <= 1 || $w <= 1} { return }
	set canv $Widget(canv,preview)
	bind $canv <Configure> {}
	set SquareSize [min $SquareSize [expr {($h - 60)/4}]]
	set BorderWidth -1
	update idletasks

	set needRefresh(piece,$SquareSize) true
	set needRefresh(lite,$SquareSize) true
	set needRefresh(dark,$SquareSize) true

	[namespace parent]::registerSize $SquareSize
	[namespace parent]::setupSquares $SquareSize

	# compute dimensions ###########################
	set x1 [expr {($w - 4*$SquareSize)/2}]
	set y1 [expr {($h - 4*$SquareSize)/2}]
	set x2 [expr {$x1 + 4*$SquareSize}]
	set y2 [expr {$y1 + 4*$SquareSize}]

	# board window #################################
	set bord [tk::canvas $canv.border -relief raised]
	set board [tk::canvas $bord.board -borderwidth 0]
	$canv create window 0 0 -anchor nw -window $bord -tag board
	$bord create window 0 0 -anchor nw -window $board -tag board
	set Widget(canv,border) $bord
	set Widget(board) $board

	# 4x4 board ####################################
	after 50 [namespace code [list [namespace parent]::setupPieces $SquareSize]]
	set y 0

	for {set row 0} {$row < 4} {incr row; incr y $SquareSize} {
		set x 0
		for {set col 0} {$col < 4} {incr col; incr x $SquareSize} {
			set color [expr {($row + $col) % 2 ? "lite" : "dark"}]
			$board create image $x $y -anchor nw -image photo_Square($color,$SquareSize)
			set piece [lindex $InitialPosition $row $col]
			if {$piece != ""} {
				$board create image $x $y -anchor nw -image photo_Piece($piece,$SquareSize) -tag piece
			}
		}
	}

	# borderlines ##################################
	set mx [expr {$x2 - $x1 - 1}]
	set my [expr {$y2 - $y1 - 1}]

	$canv create line [expr {$x1 - 1}] $y1 [expr {$x1 - 1}] [expr {$y2 + 1}] -fill white
	$canv create line [expr {$x1 - 1}] [expr {$y1 - 1}] [expr {$x2 + 1}] [expr {$y1 - 1}] -fill white
	$canv create line $x2 $y1 $x2 $y2 -fill black
	$canv create line $x1 $y2 [expr {$x2 + 1}] $y2 -fill black

	$board create line 0 0 [expr {$y2 - $y1}] 0  -fill black -tag black
	$board create line 0 0 0 [expr {$x2 - $x1}] -fill black -tag black
	$board create line 1 $my $mx $my -fill white -tag white
	$board create line $mx 1 $mx $my -fill white -tag white

	# side to move #################################
	set stmSize 19	;#[expr {$SquareSize/4 + 5}]

	if {[info exists [namespace current]::Stm(white)]} { image delete [namespace current]::Stm(white) }
	if {[info exists [namespace current]::Stm(black)]} { image delete [namespace current]::Stm(black) }
	image create photo [namespace current]::Stm(white) -width $stmSize -height $stmSize
	image create photo [namespace current]::Stm(black) -width $stmSize -height $stmSize
	::scidb::tk::image copy $stmWhite [namespace current]::Stm(white)
	::scidb::tk::image copy $stmBlack [namespace current]::Stm(black)
	$canv create image 0 0 -image [namespace current]::Stm(black) -tags {stm stmb} -anchor nw
	$canv create image 0 0 -image [namespace current]::Stm(white) -tags {stm stmw} -anchor nw
	
	# material values ##############################
	$canv create rectangle 0 0 0 0 -fill white -width 0 -tags {mvbar mvbar1}
	$canv create rectangle 0 0 0 0 -fill black -width 0 -tag {mvbar mvbar2}
	$canv create rectangle 0 0 0 0  -fill #e6e6e6 -width 0 -tag {mvbar mvbar3}
	foreach {i c} {0 b 1 b 2 w 3 w} {
		$canv create image 0 0 -image $::icon::16x16::piece(${c}p) -tag [list mv mv$i] -anchor nw
	}

	# hiliting #####################################
	set Position(x,selected)	[expr {$HilitePos(x,selected)*$SquareSize}]
	set Position(y,selected)	[expr {$HilitePos(y,selected)*$SquareSize}]
	set Position(x,suggested)	[expr {$HilitePos(x,suggested)*$SquareSize}]
	set Position(y,suggested)	[expr {$HilitePos(y,suggested)*$SquareSize}]

	# coordinates ##################################
	set bdw	20
	set x3	[expr {$x1 - 10}]
	set y3	[expr {$y1 + $SquareSize/2}]
	set x4	12
	set y4	[expr {$bdw + $SquareSize/2}]

	foreach row {1 2 3 4} {
		$canv create text [expr {$x3 - 1}] [expr {$y3 - 1}] \
			-justify right -text $row -fill white -tag coords -tag wcoords
		$canv create text [expr {$x3 + 1}] [expr {$y3 + 1}] \
			-justify right -text $row -fill black -tag coords -tag bcoords
		$canv create text $x3 $y3 -justify right -text $row -tag coords
		$bord create text [expr {$x4 - 1}] [expr {$y4 - 1}] \
			-justify right -text $row -fill white -tag coords -tag wcoords
		$bord create text [expr {$x4 + 1}] [expr {$y4 + 1}] \
			-justify right -text $row -fill black -tag coords -tag bcoords
		$bord create text $x4 $y4 -justify right -text $row -tag coords
		incr y3 $SquareSize
		incr y4 $SquareSize
	}
	set x3 [expr {$x1 + $SquareSize/2}]
	set y3 [expr {$y2 + 10}]
	set x4 [expr {$SquareSize/2 + $bdw}]
	set y4 [expr {4*$SquareSize + $bdw + $bdw/2 - 1}]
	foreach col {a b c d} {
		$canv create text [expr {$x3 - 1}] [expr {$y3 - 1}] -text $col -fill white -tag coords -tag wcoords
		$canv create text [expr {$x3 + 1}] [expr {$y3 + 1}] -text $col -fill black -tag coords -tag bcoords
		$canv create text $x3 $y3 -text $col -tag coords
		$bord create text [expr {$x4 - 1}] [expr {$y4 - 1}] -text $col -fill white -tag coords -tag wcoords
		$bord create text [expr {$x4 + 1}] [expr {$y4 + 1}] -text $col -fill black -tag coords -tag bcoords
		$bord create text $x4 $y4 -text $col -tag coords
		incr x3 $SquareSize
		incr x4 $SquareSize
	}
	
	# background ###################################
	setBackground $canv window

	ConfigureBoard
	RefreshBoard
}


proc StyleSelected {which list {useNameList false}} {
	if {$useNameList} {
		upvar 0 [namespace current]::NameList nameList
	} else {
		set nameList {}
	}

	switch $which {
		theme		{ ThemeSelected $list $nameList }
		square	{ SquareStyleSelected $list $nameList }
		piece		{ PieceStyleSelected $list $nameList }
	}
}


proc GetCurrentSelection {list nameList which} {
	if {[llength $nameList]} {
		return [lindex $nameList [$list curselection]]
	}

	return [GetStyleName $which [$list curselection]]
}


proc GetStyleName {which index} {
	switch $index {
		0 { return [set [namespace parent]::workingSetId] }
		1 { return [set [namespace parent]::defaultId] }
	}

	set selection [lindex [set [namespace parent]::${which}::styleNames] $index]
}


proc ThemeSelected {list {nameList {}}} {
	variable [namespace parent]::colors
	variable SquareSize

	# strange: we can get a <<ListboxSelect>> event although the listbox is disabled
	if {[$list cget -state] eq "disabled"} { return }

	[winfo toplevel $list] configure -cursor watch
	update idletasks
	setTheme [GetCurrentSelection $list $nameList theme] $SquareSize
	[winfo toplevel $list] configure -cursor {}

	variable [namespace parent]::square::style
	SetRecentColors border border
	SetColors
	RefreshBoard
	ConfigThemeSelectionFrame
}


proc ConfigThemeSelectionFrame {} {
	variable Widget
	variable [namespace parent]::theme::styleNames

	if {[[namespace parent]::isWorkingSet]} {
		$Widget(theme,save) configure -state normal
	} else {
		$Widget(theme,save) configure -state disabled
	}

	if {[llength $styleNames] <= 2} {
		$Widget(theme,edit) configure -state disabled
	} else {
		$Widget(theme,edit) configure -state normal
	}
}


proc SetColors {} {
	variable [namespace parent]::colors
	variable [namespace parent]::square::style

#	if {[[namespace parent]::isWorkingSet square]} {
#		foreach which {background-tile background-color border-tile border-color coordinates} {
#			set colors(hint,$which) $colors(user,$which)
#		}
#	}
	if {!$colors(locked)} {
		foreach which {background-tile background-color border-tile border-color coordinates} {
			set colors(hint,$which) $style(hint,$which)
		}

		if {[llength $colors(hint,coordinates)] == 0} {
			set colors(hint,coordinates) #ffffff
		}
	}
}


proc SquareStyleSelected {list {nameList {}}} {
	variable SquareSize
	variable Widget

	[winfo toplevel $list] configure -cursor watch
	update idletasks
	setSquareStyle [GetCurrentSelection $list $nameList square] $SquareSize
	[winfo toplevel $list] configure -cursor {}

	SetRecentColors border border
	SetColors
	RefreshBoard
	ConfigStyleSelectionFrame square
	ConfigStyleSelectionFrame theme
}


proc PieceStyleSelected {list {nameList {}}} {
	variable SquareSize

	[winfo toplevel $list] configure -cursor watch
	update idletasks
	setPieceStyle [GetCurrentSelection $list $nameList piece] $SquareSize
	[winfo toplevel $list] configure -cursor {}

	ConfigStyleSelectionFrame piece
	ConfigStyleSelectionFrame theme
}


proc PieceSetSelected {identifier} {
	variable SquareSize
	variable Widget

	[winfo toplevel $Widget(pieceset)] configure -cursor watch
	update idletasks
	setPieceSet $identifier $SquareSize
	[namespace parent]::piece::notifyPieceSetChanged
	[winfo toplevel $Widget(pieceset)] configure -cursor {}
	ConfigThemeSelectionFrame
}


proc MakePreview {path} {
	variable [namespace parent]::colors
	variable [namespace parent]::layout

	set f [::ttk::labelframe $path.lf -labelwidget [::ttk::label $path.llf -textvar ::mc::Preview]]
	set canv [tk::canvas $f.coords -width 150 -height 20 -borderwidth 2 -relief sunken]
	if {$layout(border)} {
		if {[llength $colors(hint,border-tile)]} {
			setTile $canv border
		} else {
			$canv configure -background $colors(hint,border-color)
		}
	} elseif {[llength $colors(user,background-tile)]} {
		setTile $canv window
	} elseif {[llength $colors(user,background-color)]} {
		$canv configure -background $colors(user,background-color)
	} else {
		$canv configure -background [::theme::getBackgroundColor]
	}
	$canv create text 75 10 -text "a b c d" -fill $colors(hint,coordinates) -tag abcd
	bind $canv <<ChooseColorSelected>> "$canv itemconfigure abcd -fill %d"
	pack $f -expand yes -fill both
	pack $canv -pady $::theme::padY
	return $canv
}


proc SelectCoordsColor {which parent} {
	variable [namespace parent]::colors
	variable RecentColors

	set selection [::colormenu::popup $parent \
							-class Dialog \
							-initialcolor $colors(hint,coordinates) \
							-recentcolors $RecentColors(coordinates) \
							-geometry last \
							-modal true \
							-embedcmd [namespace current]::MakePreview \
							-height 40 \
							-parent $parent \
							-place centeronparent]
	
	if {[llength $selection]} {
		set RecentColors(coordinates) [addToList $RecentColors(coordinates) $colors(hint,coordinates)]
		set colors(hint,coordinates) $selection
		if {$which eq "user"} { set colors(user,coordinates) $colors(hint,coordinates) }
		::tooltip::tooltip $parent "${::mc::Color}: [extendColorName $selection]"
		RefreshBoard
	}
}


proc SetRecentColors {what which} {
	variable [namespace parent]::colors
	SetRecent $what $colors(hint,$which-color) $colors(hint,$which-tile)
}


proc SetRecent {what recentColor recentTexture} {
	variable [namespace parent]::texture
	variable RecentColors
	variable RecentTextures

	if {[llength $recentTexture] && [llength $texture($what)]} {
		set img photo_Texture(bg:$recentTexture)
		set file [file join tile {*}$recentTexture]
		image create photo $img -width 16 -height 16
		::scidb::tk::image copy $texture($what) $img -from 0 0 32 32
		set n [lsearch -exact -index 0 $RecentTextures $img]
		if {$n == -1} {
			catch { image delete photo_Texture(bg:[lindex $RecentTextures end 0]) }
			set n end
		}
		set RecentTextures [linsert [lreplace $RecentTextures $n $n] 0 [list $img $file]]
	}

	if {[llength $recentColor]} {
		set RecentColors(background) [addToList $RecentColors(background) $recentColor]
	}
}


proc SetBorderTexture {setter which tile} {
	variable [namespace parent]::colors
	variable Widget

	set colors(hint,border-tile) $tile

	if {[setBackground $Widget(canv,border) border]} {
		set colors(hint,border-color) {}
	} else {
		set colors(hint,border-tile) {}
	}

	RefreshBoard
}


proc SelectBorderColor {which setter} {
	variable [namespace parent]::colors
	variable RecentColors
	variable RecentTextures

	set selection [::colormenu::popup $setter \
							-class Dialog \
							-initialcolor $colors(user,border-color) \
							-recentcolors $RecentColors(background) \
							-textures $RecentTextures \
							-action [list texture $::icon::16x16::texture $mc::OpenTextureDialog] \
							-geometry last \
							-modal true \
							-parent $setter \
							-place centeronparent]
	
	if {[llength $selection] == 0} { return }
	set n [string first ":" $selection]

	if {$n == -1 && $selection ne "texture"} {
		SetRecentColors border border
		set colors(hint,border-tile) {}
		set colors(hint,border-color) $selection
	} else {
		if {$n >= 0} {
			SetBorderTexture $setter $which [string range $selection [expr {$n + 1}] end-1]
		} else {
			bind $setter <<BrowserSelect>> [namespace code [list SetBorderTexture $setter $which %d]]
			set tile [openBrowser $setter tile $colors(hint,border-tile)]
			bind $setter <<BrowserSelect>> {}
			if {[llength $tile] == 0} { return }
		}

		SetRecentColors border border
	}

	if {$which eq "user"} {
		set colors(user,border-tile) $colors(hint,border-tile)
		set colors(user,border-color) $colors(hint,border-color)
	}

	if {$n == -1} { RefreshBoard }
	if {$which eq "user"} { SetColorTooltips }
}


proc SetBackgroundTexture {setter which tile} {
	variable [namespace parent]::colors
	variable Widget

	set colors(hint,background-tile) $tile
	if {[setBackground $Widget(canv,preview) window]} {
		set colors(hint,background-color) {}
		# NOTE: we do not provide full language support; not needed here
		::tooltip::tooltip $setter "${::mc::Texture}: [file join tile {*}$colors(hint,background-tile)]"
	} else {
		set colors(hint,background-tile) {}
	}
}


proc SelectBackgroundColor {which setter eraser} {
	variable [namespace parent]::colors
	variable RecentColors
	variable RecentTextures
	variable Widget

	if {[llength $colors(user,background-color)] || [llength $colors(user,background-tile)]} {
		set showEraser true
	} else {
		set showEraser false
	}

	set selection [::colormenu::popup $setter \
							-class Dialog \
							-initialcolor $colors(user,background-color) \
							-recentcolors $RecentColors(background) \
							-textures $RecentTextures \
							-eraser $showEraser \
							-action [list texture $::icon::16x16::texture $mc::OpenTextureDialog] \
							-geometry last \
							-modal true \
							-parent $setter \
							-place centeronparent]
	
	if {[llength $selection] == 0} { return }
	set n [string first ":" $selection]

	if {$selection eq "erase"} {
		EraseBackgroundColor $which $setter $eraser
	} elseif {$n == -1 && $selection ne "texture"} {
		set colors(hint,background-color) $selection
		set colors(hint,background-tile) {}
		$eraser configure -state normal
		setBackground $Widget(canv,preview) window
		::tooltip::tooltip $setter "${::mc::Color}: [extendColorName $selection]"
	} else {
		if {$n > 0} {
			SetBackgroundTexture $setter $which [string range $selection [expr {$n + 1}] end-1]
		} else {
			bind $setter <<BrowserSelect>> [namespace code [list SetBackgroundTexture $setter $which %d]]
			set tile [openBrowser $setter tile $colors(hint,background-tile)]
			bind $setter <<BrowserSelect>> {}
			if {[llength $tile] == 0} { return }
			$eraser configure -state normal
		}

		SetRecentColors window background
	}

	if {$which eq "user"} {
		set colors(user,background-tile) $colors(hint,background-tile)
		set colors(user,background-color) $colors(hint,background-color)
	}

	if {$n == -1} { RefreshBoard }
	if {$which eq "user"} { SetColorTooltips }
}


proc EraseBackgroundColor {which setter eraser} {
	variable [namespace parent]::colors
	variable Widget

	SetRecentColors window background
	set colors(hint,background-color) {}
	set colors(hint,background-tile) {}
	$eraser configure -state disabled
	setBackground $Widget(canv,preview) window
	RefreshBoard
	::tooltip::tooltip $setter {}

	if {$which eq "user"} {
		set colors(user,background-color) {}
		set colors(user,background-tile) {}
	}
}


namespace eval icon {
namespace eval 15x15 {

set ArrowUp [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAABX0lEQVQoz8XTzysFURTA8e+d
	uXPnama8R6hH6HnyqxDZYKGQlb9ASRYWNn78AZQfScpGSTaytrezs7G39BcoCY8xnjeuxfMj
	P6bsnDqrcz6dU/ce+K8QiZUlNIZ+4Ix1Hn9rsZKsI+0B15JHQjCc1PM73iTQWi5kc+kqgZhj
	hYo/Y9uIiWx9atTzFcIVQ0RM/Q1vE6R9veiXqzJhCYTCRbLA8s/pX/EBNkVma6q91hiDI20s
	KaCMRmLm2UIm4wc6K9J6xnEtHotFHEcibAEu4DJNSG8iVtKeCTzVHD4/U3iJydZl0FqVii4N
	xMyy8/m89ofcZ8STaq22slr35doZ6+ohrRWD7W2kvIB8VOAhinLm2pwzzgUn73gX3xH26mBL
	R3dfU85Uetrc3N+afBia2/ydCZQ0mVS5cZUjL6/uUiY0x5zyVFphDw/DJAV8CsDLW8bfsvQn
	IwyHbHD/b3fBKyE5W+LtjFmsAAAAAElFTkSuQmCC
}]

set ArrowDown [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAABgklEQVQoz82SPU8UURSGn7lz
	GcdlwlLZEGKnlQWWNnYkJiZaUW/oNiQ0GE0MlX9ApZCCRGM0lv4CY6QiUtBIDAuEz2wkELKw
	s8POvXPvHBvwg+zW+iane59zTt5z4F8pAOApCQE1hBiA8FKp84qAiA4B76iT6fMmKtRq/Pat
	6/dujFwLqoNXkEDQWhNqTRzFnFnP92ZTFtdWPxbev7+YAfexcibpQdp+cGxMXB0aUjdHR1QS
	R6qaDKutw2O1vLmuVvd32l0pnlCn8XttgDkCjnhNQg0N1aTCwztjfN1o4JzHWs9Bmr2ydT91
	gahf8DRCyDyGPYA8t2w3fxCpkMrAAGlmN63zC38Gpv6Kr8IKhjcYEC8UheOq1hSmpHWSLzDI
	t/7wYxwhL+myWzqhcJ6QgMOjrIFmnkl8fxjgGS0cL8RipBQ6bds96eTPmSG9bFU9rx/zVows
	Zh3L9v7pJx/Ih162sCf8hZy7tNKWHS/K8lE5K41eNt3v9UT4bMRNICzx3+knrNCl/M8+qyEA
	AAAASUVORK5CYII=
}]

} ;# namespace 15x15
} ;# namespace icon
} ;# namespace options
} ;# namespace board

# vi:set ts=3 sw=3:
