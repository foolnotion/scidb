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
# Copyright: (C) 2012-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source pgn-setup

namespace eval pgn {
namespace eval setup {
namespace eval mc {

set Configure(editor)			"Customize Editor"
set Configure(browser)			"Customize Text Display"
set TakeOver(editor)				"Adopt settings from Game Browser"
set TakeOver(browser)			"Adopt settings from Game Editor"
set Pixel							"pixel"
set Spaces							"spaces"
set RevertSettings				"Revert to initial settings"
set ResetSettings					"Reset to factory settings"
set DiscardAllChanges			"Discard all applied changes?"
set ThreefoldRepetition			"Threefold move repetition"
set FiftyMoveRule					"50 move rule"

set Setup(Appearance)			"Appearance"
set Setup(Layout)					"Layout"
set Setup(Diagrams)				"Diagrams"
set Setup(MoveStyle)				"Move Style"

set Setup(Fonts)					"Fonts"
set Setup(font-and-size)		"Text font and size"
set Setup(figurine-font)		"Figurine (normal)"
set Setup(figurine-bold)		"Figurine (bold)"
set Setup(symbol-font)			"Symbols"

set Setup(Colors)					"Colors"
set Setup(Highlighting)			"Highlighting"
set Setup(start-position)		"Start Position"
set Setup(variations)			"Variations"
set Setup(numbering)				"Numbering"
set Setup(brackets)				"Brackets"
set Setup(illegal-move)			"Illegal Move"
set Setup(comments)				"Comments"
set Setup(annotation)			"Annotation"
set Setup(nagtext)				"NAG-Text"
set Setup(marks)					"Marks"
set Setup(move-info)				"Move Information"
set Setup(result)					"Result"
set Setup(current-move)			"Current Move"
set Setup(next-moves)			"Next Moves"
set Setup(empty-game)			"Empty Game"

set Setup(Hovers)					"Hovers"
set Setup(hover-move)			"Move"
set Setup(hover-comment)		"Comment"
set Setup(hover-move-info)		"Move Information"

set Section(ParLayout)			"Paragraph Layout"
set ParLayout(use-spacing)		"Use Paragraph Spacing"
set ParLayout(column-style)	"Column Style"
set ParLayout(tabstop-1)		"Indent for White Move"
set ParLayout(tabstop-2)		"Indent for Black Move"
set ParLayout(mainline-bold)	"Bold Text for Main Line"

set Section(Variations)			"Variation Layout"
set Variations(width)			"Indent Width"
set Variations(level)			"Indent Level"

set Section(Display)				"Display"
set Display(numbering)			"Show Variation Numbering"
set Display(moveinfo)			"Show Move Information"
set Display(nagtext)				"Text for unusual NAG comments"

set Section(Diagrams)			"Diagrams"
set Diagrams(show)				"Show Diagrams"
set Emoticons(show)				"Detect Emoticons"
set Diagrams(square-size)		"Square Size"
set Diagrams(indentation)		"Indent Width"

}

array set ShowMoveInfo {
	eval	1
	clk	1
	emt	1
	ccsnt	1
	video	0
}

set StyleLayout {
	{ 0 0 Appearance }
		{ 1 0 Layout }
		{ 1 0 MoveStyle }
		{ 1 1 Diagrams }
	{ 0 0 Fonts }
		{ 1 0 font-and-size }
		{ 1 0 figurine-font }
		{ 1 1 figurine-bold }
		{ 1 0 symbol-font }
	{ 0 0 Colors }
		{ 1 1 start-position }
		{ 1 1 variations }
		{ 1 1 brackets }
		{ 1 1 numbering }
		{ 1 0 illegal-move }
		{ 1 1 comments }
		{ 1 1 annotation }
		{ 1 1 nagtext }
		{ 1 1 marks }
		{ 1 1 move-info }
		{ 1 0 result }
		{ 1 0 empty-game }
	{ 0 0 Highlighting }
		{ 1 0 current-move }
		{ 1 0 next-moves }
	{ 0 0 Hovers }
		{ 1 0 hover-move }
		{ 1 1 hover-comment }
		{ 1 1 hover-move-info }
}

array set DefaultColors {
	background				pgn,background
	foreground:variation	pgn,foreground:variation
	foreground:bracket	pgn,foreground:bracket
	foreground:numbering	pgn,foreground:numbering
	foreground:nag			pgn,foreground:nag
	foreground:nagtext	pgn,foreground:nagtext
	foreground:comment	pgn,foreground:comment
	foreground:info		pgn,foreground:info
	foreground:result		pgn,foreground:result
	foreground:illegal	pgn,foreground:illegal
	foreground:marks		pgn,foreground:marks
	foreground:empty		pgn,foreground:empty
	foreground:opening	pgn,foreground:opening
	foreground:result		pgn,foreground:result
	background:current	pgn,background:current
	background:nextmove	pgn,background:nextmove
	hilite:comment			pgn,hilite:comment
	hilite:info				pgn,hilite:info
	hilite:move				pgn,hilite:move
}
#	foreground:numbering	#68480a
#	foreground:numbering	#bd1091
#	foreground:numbering	#ad0f85
#
#	foreground:opening	#1c1cd6
#	foreground:opening	#8b0000
#	background:nextmove	#f8f2b1
#	background:nextmove	#e5ff00
#	foreground:comment	#008b00
#	hilite:comment			#005500
#	foreground:info		#008b00
#	foreground:start		#68480a

array set DefaultOptions {
	style:column		0
	style:move			san
	spacing:paragraph	0
	weight:mainline	bold
	show:moveinfo		1
	show:varnumbers	0
	show:diagram		1
	show:emoticon		1
	show:opening		1
	show:result			1
	show:nagtext		1
	indent:amount		25
	indent:max			2
	diagram:size		30
	diagram:padx		25
	diagram:pady		5
	tabstop:1			6.0
	tabstop:2			0.7
	tabstop:3			12.0
	tabstop:4			4.0
}

array set Timestamp { editor 0 browser 0 }

set Attributes(Appearance)		{ style:column style:move tabstop:1 tabstop:3 }
set Attributes(Colors)			{ foreground:illegal foreground:result foreground:empty }
set Attributes(Highlighting)	{ background:current background:nextmove }
set Attributes(Hovers)			{ hilite:move }

set RecentColors { {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} }
set ContextList {}

namespace import ::dialog::choosecolor::addToList
namespace import ::dialog::choosecolor::getActualColor


proc buildText {path context {forceSbSet 0}} {
	variable ContextList
	variable Context

	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	set Context($path) $context
	if {$context ni $ContextList} { lappend ContextList $context }

	set styles {normal bold}
	if {$context ne "browser"} { lappend styles italic bold-italic }

	::font::registerTextFonts $context $styles
	::font::registerFigurineFonts $context
	::font::registerSymbolFonts $context
	set complex [expr {$context ne "browser"}]

	array set options [array get [namespace current]::DefaultOptions]
	array set colors [array get [namespace current]::DefaultColors]

	if {[info exists Options]} { array set options [array get Options] }
	if {[info exists Colors]} { array set colors [array get Colors] }

	array set Options [array get options]
	array set Colors [array get colors]

	array unset options colors

	set f [::tk::frame $path -takefocus 0]
	set sb [::ttk::scrollbar $f.sb -command [list ::widget::textLineScroll $f.pgn] -takefocus 0]

	if {$complex && !$forceSbSet} {
		set yscrollcmd [list $f.sb set]
	} else {
		set yscrollcmd [list ::scrolledframe::sbset $f.sb]
	}

	set pgn [tk::text $f.pgn \
		-yscrollcommand $yscrollcmd \
		-takefocus 0 \
		-exportselection 0 \
		-undo 0 \
		-width 0 \
		-height 0 \
		-relief sunken \
		-borderwidth 1 \
		-state disabled \
		-wrap word \
		-font $::font::text($context:normal) \
		-cursor {} \
	]

	::widget::textPreventSelection $pgn
#	bind $pgn <Button-3> [namespace code [list PopupMenu $edit $i]]
	::widget::bindMouseWheel $pgn

	grid $pgn -row 1 -column 1 -sticky nsew
	grid $sb -row 1 -column 2 -sticky ns
	grid rowconfigure $f 1 -weight 1
	grid columnconfigure $f 1 -weight 1

	if {$context eq "editor"} { InitText $path }
	configureText $path $context

	return $pgn
}


proc closeText {path context} {
	variable ContextList

	set i [lsearch $ContextList $context]
	if {$i >= 0} { set ContextList [lreplace $ContextList $i $i] }
}


proc configureText {path {fontContext ""}} {
	variable Context
	variable [namespace parent]::$Context($path)::Options
	variable [namespace parent]::$Context($path)::Colors

	set context $Context($path)
	set w $path.pgn

	if {[string length $fontContext] == 0} { set fontContext $context }
	if {$context ne "browser"} { set bold $Options(weight:mainline) } else { set bold normal }
	set charwidth [font measure [$w cget -font] "0"]

	$w configure -font $::font::text($fontContext:normal)

	if {$context ne "browser"} {
		$w tag configure main -font $::font::text($fontContext:$bold)
		$w tag configure italic -font $::font::text($fontContext:italic)
		$w tag configure bold -font $::font::text($fontContext:bold)
		$w tag configure bold-italic -font $::font::text($fontContext:bold-italic)
		$w tag configure variation -foreground [::colors::lookup $Colors(foreground:variation)]

		$w tag configure opening -foreground [::colors::lookup $Colors(foreground:opening)]
		$w tag configure opening -font $::font::text($fontContext:bold)
		$w tag configure comment -foreground [::colors::lookup $Colors(foreground:comment)]

		$w tag configure figurineb -font $::font::figurine($fontContext:bold) -underline no
		$w tag configure symbol -font $::font::symbol($fontContext:normal)
		$w tag configure symbolb -font $::font::symbol($fontContext:bold)
		$w tag configure code -font $::font::text($fontContext:normal)
		$w tag configure codeb -font $::font::text($fontContext:bold)

		$w tag configure nag -foreground [::colors::lookup $Colors(foreground:nag)]
		$w tag configure nagtext -foreground [::colors::lookup $Colors(foreground:nagtext)]
		$w tag configure bracket -foreground [::colors::lookup $Colors(foreground:bracket)]
		$w tag configure numbering -foreground [::colors::lookup $Colors(foreground:numbering)]
		$w tag configure marks -foreground [::colors::lookup $Colors(foreground:marks)]
		$w tag configure info -foreground [::colors::lookup $Colors(foreground:info)]

		$w tag configure circled -font [list {Scidb Circled} [::font::currentFontSize $fontContext]]
		$w tag configure circled -foreground #008b00

		for {set k 0} {$k <= 10} {incr k} {
			set margin [expr {$k*$Options(indent:amount)}]
#			set indent [expr {$margin + 1.3*$charwidth + $Options(show:varnumbers)*1.5*$charwidth}]
			set indent $margin
			$w tag configure indent$k -lmargin1 $margin -lmargin2 $indent
		}
	}

	$w tag configure figurine -font $::font::figurine($fontContext:normal) -underline no
	$w tag configure result -font $::font::text($fontContext:$bold)
	$w tag configure result -foreground  [::colors::lookup $Colors(foreground:result)]
	$w tag configure empty -foreground [::colors::lookup $Colors(foreground:empty)]
	$w tag configure illegal -foreground [::colors::lookup $Colors(foreground:illegal)]
	$w tag configure state -foreground [::colors::lookup $Colors(foreground:illegal)]

	if {$Options(style:column)} {
		set tab1 [expr {round($Options(tabstop:1)*$charwidth)}]
		set tab2 [expr {$tab1 + round($Options(tabstop:2)*$charwidth)}]
		set tab3 [expr {$tab2 + round($Options(tabstop:3)*$charwidth)}]
		if {$Options(style:move) eq "lan"} {
			set tab3 [expr {$tab3 + $Options(tabstop:4)*$charwidth}]
		}
		$w configure -tabs [list $tab1 right $tab2 $tab3] -tabstyle wordprocessor
	} else {
		$w configure -tabs {} -tabstyle tabular
	}
}


proc setupStyle {context positionList} {
	variable [namespace parent]::${context}::Options
	variable ShowMoveInfo

	if {$Options(style:column)} { set thresholds {0 0 0 0} } else { set thresholds {240 80 60 0} }

	set discardUnknownResult 1

	if {$context eq "browser"} {
		set paragraphSpacing no
		set showDiagrams no
		set showMoveInfo {}
		set showEmoticons no
		set showVariationNumbers no
	} else {
		set paragraphSpacing $Options(spacing:paragraph)
		set showDiagrams $Options(show:diagram)
		set showEmoticons [expr {$Options(show:emoticon) && abs([::font::currentFontSize $context]) >= 12}]
		set showMoveInfo {}
		set showVariationNumbers $Options(show:varnumbers)

		if {$Options(show:moveinfo)} {
			foreach {type show} [array get ShowMoveInfo] {
				if {$show} { lappend showMoveInfo $type }
			}
		}
	}

	foreach position $positionList {
		::scidb::game::setupStyle \
			$position \
			{*}$thresholds \
			$Options(style:column) \
			$Options(style:move) \
			$paragraphSpacing \
			$showDiagrams \
			$showMoveInfo \
			$showEmoticons \
			$showVariationNumbers \
			$discardUnknownResult \
			;
	}
}


proc setupNags {context} {
	variable [namespace parent]::${context}::Options
	if {$Options(show:nagtext)} { set nags [::annotation::unusualNags] } else { set nags {} }
	::scidb::game::setupNags $nags
}


proc openSetupDialog {parent context position args} {
	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	variable StyleLayout
	variable Circle
	variable Revert_Options
	variable Revert_Colors
	variable Revert_Fonts
	variable New_Options
	variable New_Colors
	variable New_Fonts
	variable Priv
	variable Recent

	::font::copyFonts $context setup

	array set Revert_Options [array get Options]
	array set Revert_Colors [array get Colors]
	array set Revert_Fonts [array get ::font::Options]
	array set New_Options [array get Options]
	array set New_Colors [array get Colors]
	array set New_Fonts [array get ::font::Options]

	array unset Priv
	set Priv(current-data) ""
	set Priv(current-diagram-size) $Options(diagram:size)
	set Priv(after) {}
	set Priv(blink) 0
	set Priv(color:attr) {}
	set Priv(color:selected) {}
	set Priv(previous-pane) ""
	set Priv(refresh:cmd) {}
	set Priv(applied) 0
	set Priv(dlg) $parent.pgnSetup

	set dlg [tk::toplevel $Priv(dlg) -class Scidb]
	set top [::ttk::frame $dlg.top -takefocus 0]
	pack $top -fill both -expand yes

	set style [treetable $top.style -showarrows yes -selectmode browse]
	set Priv(tree) $style
	set complex [expr {$context ne "browser"}]
	array set available {}
	foreach entry $StyleLayout {
		lassign $entry depth complexOnly name
		set available($name) [expr {$complex || !$complexOnly}]
		if {$available($name)} {
			$style add $depth -text $mc::Setup($name) -tags $name
		}
	}
	$style resize

	SetupStyle $style

	set options [::tk::multiwindow $top.options \
		-borderwidth 1 \
		-relief raised \
		-background [::colors::lookup theme,background] \
	]

	foreach id {Appearance Fonts Colors Highlighting Hovers} {
		if {$available($id)} {
			set Priv(pane:$id) [BuildFrame(topics) $options.topic-$id $id $context $position $style]
		}
	}
	foreach id {Layout MoveStyle Diagrams} {
		if {$available($id)} {
			set Priv(pane:$id) [BuildFrame($id) $options.sub-$id $position $context]
		}
	}
	set Priv(pane:Font) [BuildFrame(Font) $options.sub-font $position $context]
	set Priv(pane:colors) [::dialog::choosecolor::embedFrame $options.colors \
		-recentcolors [namespace current]::RecentColors \
		-receiver $options \
	]

	bind $options <<ChooseColorSelected>> [namespace code [list SelectColor $context $position %d]]
	foreach pane [array names Priv pane:*] { $options add $Priv($pane) -sticky nsew }
	$options paneconfigure $Priv(pane:colors) -sticky new
	setupStyle $context $position
	setupNags $context

	set sample [::ttk::labelframe $top.sample -text $::mc::Preview]
	set Priv(pgn) [buildText $sample.text $context yes]

	$Priv(pgn) configure -font $::font::text(setup:normal)
	$Priv(pgn) configure -inactiveselectbackground white
	$Priv(pgn) configure -selectforeground black
	set Priv(path) $sample.text
	grid $sample.text -row 1 -column 1 -sticky nsew
	bind $style <<TreeTableSelection>> \
		[namespace code [list SelectionChanged $options $context $position %d]]
	set Priv(context) $context
	if {$complex} { set mainlineOnly no } else { set mainlineOnly yes }
	::scidb::game::subscribe pgn $position [namespace current]::UpdateDisplay $mainlineOnly
	$style select Appearance

	grid $style -row 1 -column 1 -sticky nsew
	grid $options -row 1 -column 3 -sticky nsew
	grid $sample -row 1 -column 5 -sticky nsew
	grid columnconfigure $top {0 2 4 6} -minsize $::theme::padx
	grid rowconfigure $top {0 2} -minsize $::theme::pady
	grid rowconfigure $sample {0 2} -minsize $::theme::pady
	grid rowconfigure $sample {1} -weight 1
	grid columnconfigure $sample {0 2} -minsize $::theme::padx
	grid columnconfigure $sample 1 -minsize 300
	grid rowconfigure $top 1 -minsize [expr {18*[$style itemheight?] + 4}]

	::widget::dialogButtons $dlg {ok apply cancel reset revert}
	$dlg.ok configure -command [namespace code [list ApplyOptions $context $position yes]]
	$dlg.apply configure -command [namespace code [list ApplyOptions $context $position no]]
	$dlg.cancel configure -command [namespace code [list RevertOptions $context $position yes]]
	$dlg.revert configure -command [namespace code [list RevertOptions $context $position no]]
	$dlg.reset configure -command [namespace code [list ResetOptions $context $position]]
	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list RevertOptions $context $position yes]]
	::tooltip::tooltip $dlg.revert $mc::RevertSettings
	::tooltip::tooltip $dlg.reset $mc::ResetSettings

	wm withdraw $dlg
	wm title $dlg "$::scidb::app - $mc::Configure($context)"
	wm resizable $dlg no no
	::util::place $dlg -parent $parent -position center
	wm transient $dlg [winfo toplevel $parent]
	catch { wm attributes $dlg -type dialog }
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	focus $style
	tkwait window $dlg
	::ttk::releaseGrab $dlg

	::scidb::game::unsubscribe pgn $position [namespace current]::UpdateDisplay
	set Options(show:opening) 1
	set Options(show:result) 1

	if {[llength $Priv(color:attr)]} {
		addToList [namespace current]::Recent($Priv(color:attr)) \
			[::colors::lookup $Priv(color:selected)]
	}

	array unset New_Options
	array unset New_Colors
	array unset New_Fonts
	array unset Revert_Options
	array unset Revert_Colors
	array unset Revert_Fonts

	::font::deleteFonts setup
}


proc ApplyOptions {context position close} {
	variable New_Options
	variable New_Colors
	variable New_Fonts
	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	variable ContextList
	variable Priv

	incr Priv(applied)
	set show:opening $Options(show:opening)
	set show:result $Options(show:result)

	array set Options [array get New_Options]
	array set Colors [array get New_Colors]
	array set ::font::Options [array get New_Fonts]

	set styles [::font::unregisterTextFonts $context]
	::font::unregisterFigurineFonts $context
	::font::unregisterSymbolFonts $context

	foreach attr [array names ::font::Options setup:*] {
		set what [lindex [split $attr :] 1]
		set ::font::Options($context:$what) $::font::Options($attr)
		set New_Fonts($context:$what) $::font::Options($attr)
	}

	::font::registerTextFonts $context $styles
	::font::registerFigurineFonts $context
	::font::registerSymbolFonts $context

	set Options(show:opening) $show:opening
	set Options(show:result) $show:result
	foreach cxt $ContextList { ::pgn::${cxt}::refresh yes }

	if {$close} {
		variable Timestamp
		set Timestamp($context) [clock microseconds]
		DoClose $context $position
	} elseif {[llength $Priv(refresh:cmd)]} {
		{*}$Priv(refresh:cmd)
	}
}


proc DoClose {context position} {
	variable Priv

	setupStyle $context $position
	setupNags $context
	destroy [winfo toplevel $Priv(path)]
}


proc RevertOptions {context position close} {
	variable Revert_Options
	variable Revert_Colors
	variable Revert_Fonts
	variable ContextList
	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	variable Priv

	array set Options [array get Revert_Options]
	array set Colors [array get Revert_Colors]

	if {$Revert_Fonts(figurine:use)} {
		set lang graphic
	} else {
		set lang $Revert_Fonts(figurine:lang)
	}
	::font::useLanguage $lang

	set styles [::font::unregisterTextFonts setup]
	::font::unregisterFigurineFonts setup
	::font::unregisterSymbolFonts setup

	array set ::font::Options [array get Revert_Fonts]

	if {$close} {
		foreach cxt $ContextList { ::pgn::${cxt}::refresh yes }
		DoClose $context $position
	} else {
		::font::registerTextFonts setup $styles
		::font::registerFigurineFonts setup
		::font::registerSymbolFonts setup
		FinishReset $context $position
	}
}


proc ResetOptions {context position} {
	variable DefaultOptions
	variable DefaultColors
	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	variable Priv

	array set Options [array get DefaultOptions]
	array set Colors [array get DefaultColors]

	::font::resetFonts setup
	FinishReset $context $position
}


proc FinishReset {context position} {
	variable New_Options
	variable New_Colors
	variable New_Fonts
	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	variable Priv
	variable Recent

	array set New_Options [array get Options]
	array set New_Colors [array get Colors]
	array set New_Fonts [array get ::font::Options]

	if {[llength $Priv(refresh:cmd)]} { {*}$Priv(refresh:cmd) }

	foreach attr [array names Colors] {
		if {[info exists Recent($attr)]} {
			addToList [namespace current]::Recent($attr) [::colors::lookup $Colors($attr)]
		}
	}

	setupStyle $context $position
	setupNags $context
	configureText $Priv(path) setup
	::scidb::game::refresh $position -immediate
}


proc InitText {path} {
	set w $path.pgn

	foreach k [array names ::annotation::mc::Nag] {
		$w tag bind nag$k <Any-Enter> [namespace code [list Tooltip $w $k]]
		$w tag bind nag$k <Any-Leave> [namespace code [list Tooltip $w hide]]
	}

	foreach k [array names ::annotation::mc::Nag] {
		$w tag bind nag$k <Any-Enter> [namespace code [list Tooltip $w $k]]
		$w tag bind nag$k <Any-Leave> [namespace code [list Tooltip $w hide]]
	}

	$w tag bind threefold <Any-Enter> [namespace code [list Tooltip $w threefold]]
	$w tag bind threefold <Any-Leave> [namespace code [list Tooltip $w hide]]
	$w tag bind fifty     <Any-Enter> [namespace code [list Tooltip $w fifty]]
	$w tag bind fifty     <Any-Leave> [namespace code [list Tooltip $w hide]]

	$w tag bind illegal <Any-Enter> [namespace code [list Tooltip $w illegal]]
	$w tag bind illegal <Any-Leave> [namespace code [list Tooltip $w hide]]

	$w tag configure underline -underline true
}


proc Tooltip {path nag} {
	variable ::annotation::mc::Nag

	switch $nag {
		hide			{ ::tooltip::hide }
		illegal		{ ::tooltip::show $path $::browser::mc::IllegalMove }
		threefold	{ ::tooltip::show $path $mc::ThreefoldRepetition }
		fifty			{ ::tooltip::show $path $mc::FiftyMoveRule }
		
		default {
			if {[info exists Nag($nag)]} {
				::tooltip::show $path $Nag($nag)
			}
		}
	}
}


proc UpdateDisplay {position data} {
	variable Priv
	after idle [namespace code [list DoUpdateDisplay $Priv(context) $position $data]]
}


proc DoUpdateDisplay {context position data} {
	variable Priv

	if {[::scidb::game::query $position open?]} {
		::pgn::${context}::doLayout $position $data $context $Priv(pgn)
	}
}


proc BuildFrame(topics) {w topic context position tree} {
	variable StyleLayout
	variable Timestamp
	variable Priv

	ttk::frame $w -borderwidth 0 -takefocus 0

	set row 1
	set state 0
	set entries {}
	set maxwidth 0
	set mw [winfo parent $w]
	set count 0
	set complex [expr {$context ne "browser"}]

	foreach entry $StyleLayout {
		lassign $entry level complexOnly tag

		if {$complex || !$complexOnly} {
			incr count
			if {$state == 0 && $level == 0 && $tag eq $topic} {
				set state 1
			} elseif {$state == 1} {
				if {$level == 0} { break }
				lappend entries $tag $count
				set maxwidth [expr {max($maxwidth, [string length $mc::Setup($tag)])}]
			}
		}
	}

	incr maxwidth 5
	set nentries [expr {[llength $entries]/2}]
	set ncols [expr {($nentries + 7)/8}]
	set nrows [expr {($nentries + $ncols - 1)/$ncols}]
	set count 0
	set row 1
	set col 1

	foreach {tag item} $entries {
		if {[$Priv(tree) item enabled $tag]} {
			set t $w.text-$tag
			tk::text $t \
				-borderwidth 0 \
				-width $maxwidth \
				-height 1 \
				-background [::colors::lookup theme,background] \
				-exportselection no \
				-cursor {} \
				-takefocus 0 \
				;
			bind $t <Any-Button> { break }
			bind $t <Any-Key> { break }
			$t tag configure link -foreground blue2
			$t tag bind link <Enter> [list $t tag configure link -underline 1]
			$t tag bind link <Leave> [list $t tag configure link -underline 0]
			$t tag bind link <ButtonPress-1> [namespace code [list $tree select $item]]
			$t insert end $mc::Setup($tag) link
			$t configure -state disabled
			set Priv(link:text:$tag) $t
			set Priv(link:item:$tag) $item
			grid $t -row $row -column $col -sticky w
			incr row 2

			if {[incr count]  == $nrows} {
				set row 1
				incr col 2
				set count 0
			}
		}
	}

	if {[info exists ::pgn::editor::Options] && [info exists ::pgn::browser::Options]} {
		if {$context eq "editor"} { set other browser } else { set other editor }
		if {$Timestamp($context) < $Timestamp($other)} {
			ttk::button $w.takeover \
				-text $mc::TakeOver($context) \
				-command [namespace code [list TakeOver $context $position $topic]] \
				;
			grid $w.takeover -row [expr {2*$nrows + 1}] -column 1 -columnspan [expr {2*($ncols - 1) + 1}]
			grid rowconfigure $w [expr {2*$nrows}] -weight 1
			grid rowconfigure $w [expr {2*$nrows + 2}] -minsize 40
		}
	}

	for {set i 1} {$i <= $nrows} {incr i} {
		grid rowconfigure $w [expr {2*$i}] -minsize $::theme::padY
	}

	grid rowconfigure $w 0 -minsize 40
	grid columnconfigure $w [expr {2*$ncols}] -weight 1
	grid columnconfigure $w 0 -minsize 40

	return $w
}


proc BuildFrame(Layout) {w position context} {
	variable	[namespace parent]::${context}::Options

	ttk::frame $w -borderwidth 0 -takefocus 0
	set complex [expr {$context ne "browser"}]

	### Section: paragraph Layout ##########################################
	set m [ttk::labelframe $w.moveLayout -text $mc::Section(ParLayout)]
	if {$Options(style:column)} { set state normal } else { set state disabled }

	if {$complex} {
		ttk::checkbutton $m.useSpacing \
			-text $mc::ParLayout(use-spacing) \
			-variable [namespace current]::New_Options(spacing:paragraph) \
			-command [namespace code [list RefreshOptions $context $position spacing:paragraph]] \
			;
		grid $m.useSpacing	-row 1 -column 1 -sticky w -columnspan 4
		grid rowconfigure $m {2} -minsize $::theme::pady
	}
	ttk::checkbutton $m.columnStyle \
		-text $mc::ParLayout(column-style) \
		-variable [namespace current]::New_Options(style:column) \
		-command [namespace code [list ToggleColumnStyle $context $position $m.stabstop1 $m.stabstop2]] \
		;
	ttk::label $m.ltabstop1 -text $mc::ParLayout(tabstop-1)
	ttk::spinbox $m.stabstop1 \
		-from 5.0 \
		-to 15.0 \
		-increment 0.1 \
		-width 5 \
		-textvariable [namespace current]::New_Options(tabstop:1) \
		-command [namespace code [list RefreshOptions $context $position tabstop:1]] \
		-exportselection no \
		-state $state \
		;
	::theme::configureSpinbox $m.stabstop1
	::validate::spinboxFloat $m.stabstop1
	ttk::label $m.pixel1 -text $mc::Spaces
	ttk::label $m.ltabstop2 -text $mc::ParLayout(tabstop-2)
	ttk::spinbox $m.stabstop2 \
		-from 8.0 \
		-to 15.0 \
		-increment 0.1 \
		-width 5 \
		-textvariable [namespace current]::New_Options(tabstop:3) \
		-command [namespace code [list RefreshOptions $context $position tabstop:3]] \
		-exportselection no \
		-state $state \
		;
	ttk::label $m.pixel2 -text $mc::Spaces
	::theme::configureSpinbox $m.stabstop2
	::validate::spinboxFloat $m.stabstop2

	grid $m.columnStyle  -row 3 -column 1 -sticky w -columnspan 4
	grid $m.ltabstop1    -row 5 -column 2 -sticky w
	grid $m.stabstop1    -row 5 -column 4 -sticky ew
	grid $m.pixel1       -row 5 -column 6 -sticky w
	grid $m.ltabstop2    -row 7 -column 2 -sticky w
	grid $m.stabstop2    -row 7 -column 4 -sticky ew
	grid $m.pixel2       -row 7 -column 6 -sticky w
	grid rowconfigure $m {0 6 10} -minsize $::theme::pady
	grid rowconfigure $m {4 8} -minsize $::theme::pady
	grid rowconfigure $m {0 10} -weight 1
	grid columnconfigure $m {5 7} -minsize $::theme::padx
	grid columnconfigure $m 3 -minsize $::theme::padX
	grid columnconfigure $m 1 -minsize 20
	grid columnconfigure $m 0 -minsize 40

	if {$complex} {
		ttk::checkbutton $m.mainlineBold \
			-text $mc::ParLayout(mainline-bold) \
			-variable [namespace current]::New_Options(weight:mainline) \
			-offvalue normal \
			-onvalue bold \
			-command [namespace code [list RefreshOptions $context $position weight:mainline]] \
			;
		grid $m.mainlineBold -row 9 -column 1 -sticky w -columnspan 4
	}

	if {$complex} {
		### Section: Variations ################################################
		set p [ttk::labelframe $w.parLayout -text $mc::Section(Variations)]

		ttk::label $p.lmaxlevel -text $mc::Variations(level)
		ttk::spinbox $p.smaxlevel \
			-from 0 \
			-to 9 \
			-width 5 \
			-textvariable [namespace current]::New_Options(indent:max) \
			-command [namespace code [list RefreshIndentLevel $context $position $p.sindentation]] \
			-exportselection no \
			;
		::theme::configureSpinbox $p.smaxlevel
		::validate::spinboxInt $p.smaxlevel
		ttk::label $p.lindentation -text $mc::Variations(width)
		if {$Options(indent:max) <= 0} { set state disabled } else { set state normal }
		ttk::spinbox $p.sindentation \
			-from 0 \
			-to 99 \
			-width 5 \
			-textvariable [namespace current]::New_Options(indent:amount) \
			-command [namespace code [list RefreshOptions $context $position indent:amount]] \
			-exportselection no \
			-state $state \
			;
		::theme::configureSpinbox $p.sindentation
		::validate::spinboxInt $p.sindentation
		ttk::label $p.pixel -text $mc::Pixel

		grid $p.lmaxlevel    -row 1 -column 1 -sticky w
		grid $p.smaxlevel    -row 1 -column 3 -sticky ew
		grid $p.lindentation -row 3 -column 1 -sticky w
		grid $p.sindentation -row 3 -column 3 -sticky ew
		grid $p.pixel        -row 3 -column 5 -sticky w

		grid rowconfigure $p {0 2 4} -minsize $::theme::pady
		grid rowconfigure $p {0 4} -weight 1
		grid columnconfigure $p {4 6} -minsize $::theme::padx
		grid columnconfigure $p 2 -minsize $::theme::padX
		grid columnconfigure $p 0 -minsize 40

		### Section: Display ###################################################
		set d [ttk::labelframe $w.display -text $mc::Section(Display)]

		ttk::checkbutton $d.varnumbers \
			-text $mc::Display(numbering) \
			-variable [namespace current]::New_Options(show:varnumbers) \
			-command [namespace code [list RefreshOptions $context $position show:varnumbers]] \
			;
		ttk::checkbutton $d.moveinfo \
			-text $mc::Display(moveinfo) \
			-variable [namespace current]::New_Options(show:moveinfo) \
			-command [namespace code [list RefreshOptions $context $position show:moveinfo]] \
			;
		ttk::checkbutton $d.nagtext \
			-text $mc::Display(nagtext) \
			-variable [namespace current]::New_Options(show:nagtext) \
			-command [namespace code [list RefreshOptions $context $position show:nagtext]] \
			;

		grid $d.varnumbers	-row 1 -column 1 -sticky w
		grid $d.moveinfo		-row 3 -column 1 -sticky w
		grid $d.nagtext		-row 5 -column 1 -sticky w
		grid rowconfigure $d {0 2 4 6} -minsize $::theme::pady
		grid rowconfigure $d {0 6} -weight 1
		grid columnconfigure $d 2 -minsize $::theme::padx
		grid columnconfigure $d 0 -minsize 40

		### Geometry ###########################################################
		grid $m -row 1 -column 1 -sticky ewns
		grid $p -row 3 -column 1 -sticky ewns
		grid $d -row 5 -column 1 -sticky ewns
		grid rowconfigure $w {2 4} -minsize $::theme::pady
		grid rowconfigure $w {1 3 5} -weight 1
	} else {
		grid $m -row 1 -column 1 -sticky ewns
		grid rowconfigure $w {1 2 3} -weight 1
	}

	grid columnconfigure $w {0 2} -minsize $::theme::padx
	grid columnconfigure $w 1 -weight 1

	return $w
}


proc BuildFrame(Diagrams) {w position context} {
	ttk::frame $w -borderwidth 0 -takefocus 0

	### Section: Diagrams ##################################################
	set d [ttk::labelframe $w.diagrams -text $mc::Section(Diagrams)]
	set refresh [namespace code [list RefreshOptions $context $position diagram:size]]

	ttk::checkbutton $d.show \
		-text $mc::Diagrams(show) \
		-variable [namespace current]::New_Options(show:diagram) \
		-command [namespace code [list RefreshOptions $context $position show:diagram]] \
		;
	ttk::label $d.lsquaresize -text $mc::Diagrams(square-size)
	ttk::spinbox $d.ssquaresize \
		-from 20 \
		-to 30 \
		-increment 1 \
		-width 5 \
		-textvariable [namespace current]::New_Options(diagram:size) \
		-exportselection no \
		-command $refresh \
		;
	bind $d.ssquaresize <Leave> $refresh
	bind $d.ssquaresize <Return> $refresh
	bind $d.ssquaresize <Return> {+ break }
	ttk::label $d.dsquaresize -text $mc::Pixel
	::theme::configureSpinbox $d.ssquaresize
	::validate::spinboxInt $d.ssquaresize
	bind $d.ssquaresize <FocusIn> +[list $d.ssquaresize selection range 0 end]
	ttk::label $d.lindentation -text $mc::Diagrams(indentation)
#	ttk::spinbox $d.sindentation -width 5
#	::theme::configureSpinbox $d.sindentation
#	::validate::spinboxInt $d.sindentation
#	bind $d.sindentation <FocusIn> +[list $d.sindentation selection range 0 end]

	grid $d.show			-row 1 -column 1 -sticky w -columnspan 6
	grid $d.lsquaresize	-row 3 -column 2 -sticky w
	grid $d.ssquaresize	-row 3 -column 4 -sticky ew
	grid $d.dsquaresize	-row 3 -column 6 -sticky w
#	grid $d.lindentation	-row 5 -column 2 -sticky w
#	grid $d.sindentation	-row 5 -column 4 -sticky ew

	grid rowconfigure $d {0 4} -minsize $::theme::pady
	grid rowconfigure $d 2 -minsize $::theme::padY
	grid rowconfigure $d {0 4} -weight 1
	grid columnconfigure $d {3 5 7} -minsize $::theme::padx
	grid columnconfigure $d 1 -minsize 20
	grid columnconfigure $d 0 -minsize 40

	### Geometry ###########################################################
	grid $d -row 1 -column 1 -sticky ewns
	grid rowconfigure $w {1 2 3} -weight 1
	grid columnconfigure $w {0 2} -minsize $::theme::padx
	grid columnconfigure $w 1 -weight 1

	return $w
}


proc BuildFrame(MoveStyle) {w position context} {
	variable	[namespace parent]::${context}::Options

	if {[::font::useFigurines?]} {
		set lang graphic
	} else {
		set lang $::font::Options(figurine:lang)
	}

	ttk::frame $w -borderwidth 0 -takefocus 0

	::figurines::listbox $w.figurines
	::notation::listbox $w.notation
	$w.figurines connect $w.notation
	$w.notation select $Options(style:move)
	$w.figurines select $lang

	bind $w.figurines <<ListboxSelect>> [namespace code [list RefreshFigurineFont $context $position %d]]
	bind $w.notation <<ListboxSelect>> [namespace code [list RefreshNotation $context $position %d]]

	grid $w.figurines -row 1 -column 1 -sticky nsew
	grid $w.notation  -row 1 -column 3 -sticky nsew
	grid rowconfigure $w 1 -weight 1
	grid columnconfigure $w 3 -weight 1
	grid columnconfigure $w 2 -minsize $::theme::padx

	return $w
}


proc BuildFrame(Font) {w position context} {
	::dialog::choosefont $w ::font::text(setup:normal)
	return $w
}


proc TakeOver {context position topic} {
	variable Priv

	if {$context eq "editor"} { set other browser } else { set other editor }

	switch $topic {
		Fonts {
			variable New_Fonts
			foreach attr [array names ::font::Options $context:*] {
				set tag [lindex [split $attr :] 1]
				set New_Fonts(setup:$tag) $::font::Options($other:$tag)
			}
			RefreshFonts $position
		}
		Appearance {
			variable New_Options
			variable [namespace parent]::${other}::Options
			variable Attributes

			foreach attr $Attributes($topic) {
				set New_Options($attr) $Options($attr)
				set [namespace parent]::${context}::Options($attr) $Options($attr)
			}
		}
		default {
			variable New_Colors
			variable [namespace parent]::${other}::Colors
			variable Attributes

			foreach attr $Attributes($topic) {
				set New_Colors($attr) $Colors($attr)
				set [namespace parent]::${context}::Colors($attr) $Colors($attr)
			}
		}
	}

	setupStyle $context $position
	configureText $Priv(path) setup
	::scidb::game::refresh $position -immediate
}


proc ConfigureTakeOverButton {w topic context} {
	if {![winfo exists $w.takeover]} { return }

	set state disabled

	switch $topic {
		Appearance {
			upvar 0 [namespace parent]::editor::Options editor
			upvar 0 [namespace parent]::browser::Options browser
			variable Attributes

			foreach attr $Attributes($topic) {
				if {[set editor($attr)] ne $browser($attr)} { set state normal }
			}
		}
		Fonts {
			if {$context eq "editor"} { set other browser } else { set other editor }
			foreach attr [array names ::font::Options setup:*] {
				set tag [lindex [split $attr :] 1]
				if {$::font::Options(setup:$tag) ne $::font::Options($other:$tag)} {
					set state normal
				}
			}
		}
		default {
			upvar 0 [namespace parent]::editor::Colors editor
			upvar 0 [namespace parent]::browser::Colors browser
			variable Attributes

			foreach attr $Attributes($topic) {
				if {$editor($attr) ne $browser($attr)} { set state normal }
			}
		}
	}

	$w.takeover configure -state $state
}


proc ToggleColumnStyle {context position ts1 ts2} {
	variable New_Options

	if {$New_Options(style:column)} { set state normal } else { set state disabled }
	$ts1 configure -state $state
	$ts2 configure -state $state
	RefreshOptions $context $position style:column
}


proc RefreshIndentLevel {context position amount} {
	variable New_Options

	if {$New_Options(indent:max) <= 0} { set state disabled } else { set state normal }
	$amount configure -state $state
	RefreshOptions $context $position indent:max
}


proc RefreshFigurineFont {context position lang} {
	variable New_Fonts
	variable Priv

	if {![::font::haveFigurines?]} { return }
	::font::unregisterFigurineFonts setup

	if {$lang eq "graphic"} {
		set ::font::Options(figurine:lang) ""
		::font::useFigurines yes
	} else {
		set ::font::Options(figurine:lang) $lang
		::font::useLanguage $lang
		::font::useFigurines no
	}

	SetupStyle $Priv(tree)

	::font::registerFigurineFonts setup
	array set New_Fonts [array get ::font::Options]
	configureText $Priv(path) setup
	::scidb::game::refresh $position -immediate
}


proc RefreshNotation {context position style} {
	variable New_Options

	set New_Options(style:move) $style
	RefreshOptions $context $position style:move
}


proc SetupStyle {style} {
	variable Priv

	if {[::font::haveSymbols?]} { set action enable } else { set action disable }
	$style $action symbol-font

	if {[::font::haveFigurines?] && [string length $::font::Options(figurine:lang)] == 0} {
		set action enable
		set color blue2
	} else {
		set action disable
		set color #595985
	}

	foreach tag {figurine-font figurine-bold} {
		if {[info exists Priv(link:text:$tag)]} {
			set t $Priv(link:text:$tag)
			$t tag configure link -foreground [::colors::lookup $color]
			if {$action eq "enable"} {
				$t tag bind link <Enter> [list $t tag configure link -underline 1]
				$t tag bind link <Leave> [list $t tag configure link -underline 0]
				$t tag bind link <ButtonPress-1> \
					[namespace code [list $Priv(tree) select $Priv(link:item:$tag)]]
			} else {
				$t tag bind link <Enter> {#}
				$t tag bind link <Leave> {#}
				$t tag bind link <ButtonPress-1> {#}
			}
			$style $action $tag
		}
	}
}


proc SelectColor {context position color} {
	variable [namespace parent]::${context}::Colors
	variable New_Colors
	variable Priv

	set Colors($Priv(color:attr)) $color
	set New_Colors($Priv(color:attr)) $color
	set Priv(color:selected) $color

	if {[llength $Priv(hover:key)] == 0} {
		configureText $Priv(path) setup
	} elseif {$Priv(color:attr) eq "hilite:move"} {
		$Priv(pgn) tag configure $Priv(hover:key) -background [::colors::lookup $color]
	} else {
		$Priv(pgn) tag configure $Priv(hover:key) -foreground [::colors::lookup $color]
	}
}


proc RefreshOptions {context position attr} {
	variable [namespace parent]::${context}::Options
	variable [namespace parent]::${context}::Colors
	variable Fonts
	variable New_Options
	variable New_Colors
	variable New_Fonts
	variable Priv

	if {$Options($attr) eq $New_Options($attr)} { return }
	set Options($attr) $New_Options($attr)
	setupStyle $context $position
	setupNags $context
	configureText $Priv(path) setup
	::scidb::game::refresh $position -immediate
}


proc UpdateFonts {dlg context position font} {
	variable New_Fonts
	variable Priv

	lassign $font family size _ slant
	if {$New_Fonts(setup:size) == $size} { set all 0 } else { set all 1 }
	foreach attr {family size} { set New_Fonts(setup:$attr) [set $attr] }
	RefreshFonts $all
	configureText $Priv(path) setup
	::scidb::game::refresh $position -immediate
}


proc RefreshFonts {{all 1}} {
	variable New_Fonts

	set styles [::font::unregisterTextFonts setup]
	if {$all} {
		::font::unregisterFigurineFonts setup
		::font::unregisterSymbolFonts setup
	}
	foreach attr [array names ::font::Options setup:*] {
		set ::font::Options($attr) $New_Fonts($attr)
	}
	::font::registerTextFonts setup $styles
	if {$all} {
		::font::registerFigurineFonts setup
		::font::registerSymbolFonts setup
	}
}


proc UpdateFigurineFont {dlg context weight font} {
	variable Priv
	variable New_Fonts

	::font::unregisterFigurineFonts setup
	lassign $font ::font::Options(figurine:family:$weight) _ ::font::Options(figurine:weight:$weight)
	lassign $font New_Fonts(figurine:family:$weight) _ New_Fonts(figurine:weight:$weight)
	::font::registerFigurineFonts setup
	UpdateFigurineSample $dlg $weight $::font::Options(figurine:family:$weight)
	configureText $Priv(path) setup
}


proc UpdateSymbolFont {dlg context font} {
	variable Priv
	variable New_Fonts

	::font::unregisterSymbolFonts setup
	lassign $font ::font::Options(symbol:family) _ ::font::Options(symbol:weight)
	lassign $font New_Fonts(symbol:family) _ New_Fonts(symbol:weight)
	::font::registerSymbolFonts setup
	UpdateSymbolSample $dlg $::font::Options(symbol:family)
	configureText $Priv(path) setup
}


proc UpdateFigurineSample {dlg weight font} {
	variable ::font::chessFigurineFontsMap
	variable ::figurines::langSet

	set encoding $chessFigurineFontsMap([string tolower $font])
	set sample [join $langSet(graphic) " "]
	if {[llength $encoding]} { set sample [string map $encoding $sample] }
	::dialog::choosefont::setSample $dlg $sample
}


proc UpdateSymbolSample {dlg font} {
	upvar 0 ::font::$::font::chessSymbolFontsMap([string tolower $font]) encoding
	set sample ""
	foreach nag {7 13 14 16 40 140 142 149 151 156} {
		if {[info exists encoding($nag)]} {
			if {[llength $sample]} { append sample " " }
			append sample $encoding($nag)
		}
	}
	set i [expr {[string length $sample]/2}]
	set sample [string replace $sample $i [expr {$i + 1}] "\n"]
	::dialog::choosefont::setSample $dlg $sample
}


proc SelectionChanged {mw context position tag {blink yes}} {
	variable Priv
	variable Games
	variable [namespace parent]::${context}::Colors
	variable [namespace parent]::${context}::Options
	variable New_Colors
	variable New_Options
	variable ::mc::langID

	BreakBlink $context $position

	if {[llength $Priv(color:attr)]} {
		addToList [namespace current]::Recent($Priv(color:attr)) \
			[::colors::lookup $Priv(color:selected)]
	}

	set data ""
	set Priv(color:attr) ""
	set Priv(color:selected) ""
	set Priv(hover:key) ""
	set Priv(refresh:cmd) [namespace code [list SelectionChanged $mw $context $position $tag no]]
	array set Colors [array get New_Colors]
	array set Options [array get New_Options]

	switch $tag {
		Appearance - Fonts - Colors - Highlighting - Hovers {
			ConfigureTakeOverButton $Priv(pane:$tag) $tag $context
			set Options(show:moveinfo) 1
			set pane $tag 
		}

		Diagrams - Layout - MoveStyle {
			set Options(show:opening) 0
			set Options(show:result) 0
			set Colors(background:nextmove) $Colors(background)
			set data $Games([string tolower $tag])
			set pane $tag 

			if {$tag eq "MoveStyle"} {
				if {[::font::useFigurines?]} {
					set lang graphic
				} else {
					set lang $::font::Options(figurine:lang)
				}
				$mw.sub-MoveStyle.notation select $Options(style:move)
				$mw.sub-MoveStyle.figurines select $lang
				set Options(show:moveinfo) 0
			} elseif {$tag ne "Layout"} {
				set Options(show:moveinfo) 1
			}
		}

		font-and-size - figurine-font - figurine-bold - symbol-font {
			set dlg $Priv(pane:Font)
			switch $tag {
				font-and-size {
					lappend args ::font::text(setup:normal) \
						-stylelist {normal} \
						-fontlist {} \
						-fixedsize no \
						-receiver $dlg \
						-sample "" \
						;
					set cmd [list UpdateFonts $dlg $context $position %d]
				}
				figurine-font {
					lappend args ::font::figurine(setup:normal) \
						-stylelist {Regular Bold} \
						-fontlist $::font::chessFigurineFonts \
						-fixedsize yes \
						-receiver $dlg \
						;
					set cmd [list UpdateFigurineFont $dlg $context normal %d]
					UpdateFigurineSample $dlg normal $::font::Options(figurine:family:normal)
				}
				figurine-bold {
					lappend args ::font::figurine(setup:bold) \
						-stylelist {Regular Bold} \
						-fontlist $::font::chessFigurineFonts \
						-fixedsize yes \
						-receiver $dlg \
						;
					set cmd [list UpdateFigurineFont $dlg $context bold %d]
					UpdateFigurineSample $dlg normal $::font::Options(figurine:family:bold)
				}
				symbol-font {
					lappend args ::font::symbol(setup:normal) \
						-stylelist {Regular Bold} \
						-fontlist $::font::chessSymbolFonts \
						-fixedsize yes \
						-receiver $dlg \
						;
					UpdateSymbolSample $dlg $::font::Options(symbol:family)
					set cmd [list UpdateSymbolFont $dlg $context %d]
				}
			}
			::dialog::choosefont::setup $dlg {*}$args
			bind $dlg <<FontSelected>> [namespace code $cmd]
			set Options(show:opening) 0
			set Options(show:result) 0
			set Options(show:moveinfo) 1
			set data $Games(colors)
			set pane Font
		}

		default {
			set Options(spacing:paragraph) 0
			set Options(style:column) 0
			set Options(show:moveinfo) 1
			set Options(show:opening) 1
			set Options(show:result) 1

			switch $tag {
				start-position		{ set Priv(color:attr) foreground:opening }
				variations			{ set Priv(color:attr) foreground:variation }
				illegal-move		{ set Priv(color:attr) foreground:illegal }
				comments				{ set Priv(color:attr) foreground:comment }
				marks					{ set Priv(color:attr) foreground:marks }
				move-info			{ set Priv(color:attr) foreground:info }
				result				{ set Priv(color:attr) foreground:result }
				current-move		{ set Priv(color:attr) background:current }
				next-moves			{ set Priv(color:attr) background:nextmove }

				hover-move			{ set Priv(color:attr) hilite:move }
				hover-comment		{ set Priv(color:attr) hilite:comment }
				hover-move-info	{ set Priv(color:attr) hilite:info }

				brackets {
					set Options(show:varnumbers) 0
					set Priv(color:attr) foreground:bracket
				}

				numbering {
					set Options(show:varnumbers) 1
					set Priv(color:attr) foreground:numbering
				}

				annotation {
					set Options(show:nagtext) 0
					set Priv(color:attr) foreground:nag
				}

				nagtext {
					set Options(show:nagtext) 1
					set Priv(color:attr) foreground:nagtext
				}

				empty-game {
					set Priv(color:attr) foreground:empty
					set data "\[Result \"1-0\"]\n*"
				}
			}
		}
	}

	setupNags $context

	if {[llength $Priv(color:attr)]} {
		variable Recent
		set attr $Priv(color:attr)
		if {![info exists Recent($attr)]} {
			variable DefaultColors
			set Recent($attr) [lrepeat [array size DefaultColors] {}]
			lset Recent($attr) 0 [::colors::lookup $Colors($attr)]
		}
		::dialog::choosecolor::setupColor $Priv(pane:colors) [::colors::lookup $Colors($attr)]
		::dialog::choosecolor::setupRecentColors $Priv(pane:colors) [namespace current]::Recent($attr)
		set pane colors
		if {[string length $data] == 0} { set data $Games(colors) }
		if {[string match hover* $tag]} { append data " " }
	}

	set w $Priv(pgn)
	$w tag remove sel 1.0 end
	$mw raise $Priv(pane:$pane)

	setupStyle $context $position
	::scidb::game::switch $position
	::scidb::game::import $position $data [namespace current]::Trash {}
	::scidb::game::langSet $position [list {} $langID]
	if {$pane ne $Priv(previous-pane)} {
		::pgn::${context}::resetGoto $w $position
		foreach key [$w tag names] { $w tag configure $key -background {} }
	}
	set Priv(current-data) $data

	if {[llength $Priv(color:attr)]} {
		if {$pane eq "colors"} {
			::scidb::game::go $position end
			set key [::scidb::game::position $position key]
			::scidb::game::go $position start
			set hover [string match hover* $tag]

			if {$hover} { set color $Colors(hilite:move) } else { set color {} }
			after idle [list $w tag configure $key -background [::colors::lookup $color]]
			set hilite(comment) $Colors(foreground:comment)
			set hilite(info) $Colors(foreground:info)

			if {$hover} {
				switch -glob $tag {
					*-move {
						set Priv(hover:key) $key
					}
					*-comment {
						set Priv(hover:key) comment:$key:after:$langID
						set hilite(comment) $Colors(hilite:comment)
					}
					*-info {
						set Priv(hover:key) info:$key
						set hilite(info) $Colors(hilite:info)
					}
				}
			}

			if {$context ne "browser"} {
				after idle [list $w tag configure comment:$key:p:$langID \
					-foreground [::colors::lookup $hilite(comment)]]
				after idle [list $w tag configure info:$key -foreground [::colors::lookup $hilite(info)]]
			}
		}

		if {$context eq "editor"} {
			::scidb::game::go $position 1
		} else {
			if {$tag in {"current-move" "next-moves"}} {
				::scidb::game::go $position 1
				after idle [list ::pgn::browser::showNext $w $position yes]
			} else {
				::pgn::browser::showNext $w $position no
			}
		}
		switch $Priv(color:attr) {
			foreground:variation { set color $Colors(foreground:variation) }
			default { set color $Colors($attr) }
		}

		if {$blink} { after idle [namespace code [list HiliteTags $context $position]] }
	}

	set Priv(previous-pane) $pane
}


proc HiliteTags {context position} {
	variable Priv

	if {[llength $Priv(color:attr)] == 0} { return }

	set w $Priv(pgn)
	$w tag remove sel 1.0 end
	$w configure -inactiveselectbackground white
	$w configure -selectborderwidth 0
	if {[llength $Priv(hover:key)] == 0} {
		set tag [lindex [split $Priv(color:attr) :] 1]
		foreach {first last} [$w tag ranges $tag] { $w tag add sel $first $last }
	}

	switch $Priv(color:attr) {
		foreground:variation { set compl darkgoldenrod }
		foreground:bracket - foreground:numbering { set compl white }
		foreground:empty { set compl yellow }
		background:current - background:nextmove { set compl white }
		default {
			variable [namespace parent]::${context}::Colors
			scan [getActualColor [::colors::lookup $Colors($Priv(color:attr))]] "\#%2x%2x%2x" r g b
			set r [expr {255 - $r}]; set g [expr {255 - $g}]; set b [expr {255 - $b}]
			set compl [format "\#%02x%02x%02x" $r $g $b]
			if {$compl eq "#ffffff"} { set compl yellow }
		}
	}

	set Priv(blink) 0
	set Priv(after) [after 250 [namespace code [list Blink $context $position $compl]]]
}


proc Blink {context position compl} {
	variable [namespace parent]::${context}::Colors
	variable Priv

	set w $Priv(pgn)
	if {![winfo exists $w]} { return }
	lassign [split $Priv(color:attr) :] attr tag

	if {$Priv(blink) % 2 == 0} {
		if {[llength $compl]} {
			if {$attr eq "hilite"} {
				if {$tag eq "move"} { set color $Colors(hilite:move) } else { set color $compl }
				$w tag configure $Priv(hover:key) -foreground [::colors::lookup $color]
			} else {
				switch $tag {
					variation - bracket - numbering {
						$w tag configure $tag -foreground [::colors::lookup $compl]
					}
					current {
						set key [::scidb::game::position $position key]
						set bg [::colors::lookup $Colors($Priv(color:attr))]
						$w tag configure $key -foreground $bg
						$w tag configure $key -background $bg
					}
					nextmove {
						set keys [::scidb::game::next keys $position] 
						set bg [::colors::lookup $Colors($Priv(color:attr))]
						foreach key $keys {
							$w tag configure $key -background $bg
							$w tag configure $key -foreground $bg
						}
					}
					default {
						$w configure -selectborderwidth 1
						$w configure -inactiveselectbackground [::colors::lookup $compl]
					}
				}
			}
		}
		set period 500
	} else {
		if {$attr eq "hilite"} {
			if {$tag eq "move"} { set color {} } else { set color $Colors($Priv(color:attr)) }
			$w tag configure $Priv(hover:key) -foreground [::colors::lookup $color]
		} else {
			switch $tag {
				variation - bracket - numbering {
					$w tag configure $tag -foreground [::colors::lookup $Colors($Priv(color:attr))]
				}
				current {
					set key [::scidb::game::position $position key]
					$w tag configure $key -foreground black
				}
				nextmove {
					set keys [::scidb::game::next keys $position] 
					foreach key $keys { $w tag configure $key -foreground black }
				}
				default {
					$w configure -inactiveselectbackground white
					$w configure -selectborderwidth 0
				}
			}
		}
		set period 250
	}

	if {[llength $compl] && [incr Priv(blink)] < 4} {
		set Priv(after) [after $period [namespace code [list Blink $context $position $compl]]]
	}
}


proc BreakBlink {context position} {
	variable Priv

	after cancel $Priv(after)
	if {$Priv(blink) % 2} { Blink $context $position {} }
	set Priv(blink) 0
	set Priv(after) {}
}


proc Trash {args} {}


proc WriteOptions {chan} {
	variable Timestamp
	variable Context

	set context {}
	foreach path [array names Context] {
		set cxt $Context($path)
		set [namespace parent]::${cxt}::Options(show:opening) 1 ;# to be sure
		set [namespace parent]::${cxt}::Options(show:result) 1 ;# to be sure
		if {$cxt ni $context} { lappend context $cxt }
	}

	foreach cxt {browser editor merge} {
		if {[info exists [namespace parent]::${cxt}::Options]} {
			::options::writeItem $chan [namespace parent]::${cxt}::Options
		}
		if {[info exists [namespace parent]::${cxt}::Colors]} {
			::options::writeItem $chan [namespace parent]::${cxt}::Colors
		}
	}

	if {[array names Timestamp] > 0} {
		::options::writeItem $chan [namespace current]::Timestamp
	}

	::options::writeItem $chan [namespace current]::ShowMoveInfo
}

::options::hookWriter [namespace current]::WriteOptions


set Games(layout) {
[Result "*"]
[LastMoves "5...Bxf2 6.Kf1"]
1.e4 e5
	(1...c5 {+0.25|16})
	(1...c5 {+0.09|16}
		(2...e6 {+0.13|16}))
		(2...d6 3.d4 {+0.12|16}
			(3.Bb5+ Bd7
				(3...Nd7)
				(3...Nc6))
			(3.c3 {+0.08|16}))
2.Nf3 Nc6
3.Bc4 Nf6
4.Ng5 Bc5
5.Nxf7 Bxf2+ $70
6.Kf1
*
}

set Games(movestyle) $Games(layout)

set Games(diagrams) {
[Result "*"]
[LastMoves "1.e4 e5"]
1.e4 e5 D *
}

set Games(colors) {
[Result "1/2-1/2"]
[LastMoves "5.O-O Nf6"]
1.f3 e5 2.e4 Nc6
	(2...Bc5 {[%draw full,g1,red]} {-0.74})
	(2...Nf6 3.Nh3 Bc5 4.Qe2 0-0 5.d3 d5 6.Bg5 Bxh3 7.gxh3 Nc6
	{-1.41|11} {Juhl-Karlsson/SVE-chT corr/1978})
3.Nh3 d6 4.Bc4?
%	({$213} 4.Nf2)
Qh4+? {[%draw full,e1,red]}
	(4...Bxh3 5.gxh3 Qh4+ $19 $108)
5.O-O Nf6 {-0.37|11} {$232}
1/2-1/2
}

} ;# namespace setup
} ;# namespace pgn

# vi:set ts=3 sw=3:
