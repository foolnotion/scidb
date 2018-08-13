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
# Copyright: (C) 2009-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source game-list

namespace eval application {
namespace eval database {
namespace eval games {
namespace eval mc {

set Control						"Control"
set GameNumber					"Game Number"

set GotoFirstPage				"Go to the first page of games"
set GotoLastPage				"Go to the last page of games"
set PreviousPage				"Previous page of games"
set NextPage					"Next page of games"
set GotoCurrentSelection	"Go to current selection"
set UseVerticalScrollbar	"Use vertical scrollbar"
set UseHorizontalScrollbar	"Use horizontal scrollbar"
set GotoEnteredGameNumber	"Go to entered game number"

} ;# namespace mc

array set Options {
	layout bottom
}

variable Columns {
	number white whiteElo black blackElo event result site date round length eco deleted changed acv
}

array set FrameOptions {
	games { -width 1000 -height 100% -minwidth 200 -minheight 100 -expand both }
}

variable Layout {
	root { -shrink none -grow none } {
		pane games %games%
	}
}

variable Tables {}


proc build {parent} {
	variable Layout
	variable Tables
	variable FrameOptions

	set twm $parent.twm
	namespace eval [namespace current]::$twm {}
	variable ${twm}::Priv

	if {$twm ni $Tables} { lappend Tables $twm }
	::application::twm::make $twm games \
		[namespace current]::MakePane \
		[namespace current]::BuildPane \
		[namespace current]::Prios \
		[array get FrameOptions] \
		$Layout \
		-frameborderwidth 0 \
		;
	bind $twm <<TwmAfter>> [namespace code [list AfterTWM $twm]]
	bind $twm <<TwmReady>> [namespace code [list AfterTWM $twm]]
	::application::twm::load $twm
	set Priv(layout) 1
	return $twm
}


proc activate {w flag} {
	set twm $w.twm
	variable ${twm}::Priv

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $w $flag
	}
	if {$flag} {
		::gametable::focus $w.twm.games.table
		if {$Priv(layout)} {
			set Priv(layout) 0
			after idle [namespace code [list AfterTWM $twm]]
		}
	}
}


proc overhang {parent} {
	return [::gametable::overhang $parent.twm.games.table]
}


proc linespace {parent} {
	return [::gametable::linespace $parent.twm.games.table]
}


proc computeHeight {parent {nrows -1}} {
	set frame $parent.twm.games
	set result [::toolbar::totalHeight $frame]
	if {$nrows >= 0} {
		incr result [::gametable::computeHeight $parent.twm.games.table $nrows]
	}
	return $result
}


proc layout {} {
	return [set [namespace current]::Options(layout)]
}


proc setActive {flag} {
	# no action
}


proc borderwidth {parent} {
	return [::gametable::borderwidth $parent.twm.games.table]
}


proc MakePane {twm parent type uid} {
	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus 1]
	set nameVar ::application::twm::mc::Pane($uid)
	return [list $frame $nameVar 100 yes yes yes]
}


proc BuildPane {twm frame uid width height} {
	variable Columns
	variable Options
	variable ${twm}::Priv

	set tb $frame.table
	namespace eval [namespace current]::$tb {}
	variable ${tb}::Vars
	set Priv(table) $tb

	set Vars(theme)		[::theme::currentTheme]
	set Vars(toolbars)	{}
	set Vars(after)		{}
	set Vars(resizing)	0
	set Vars(codec)		{}
	set Vars(base)			""
	set Vars(ready)		0

	set menucmd {}
	if {[string match [::application::twm games].* $frame]} {
		lappend menucmd -menucmd [namespace current]::HeaderMenu
	}

	set id [::application::twm::getId $twm]
	::gametable::build $tb \
		[namespace code [list View $tb]] \
		$Columns \
		-id db:games:$id \
		-usescale yes \
		-layout $Options(layout) \
		{*}$menucmd \
		;

	bind $tb <<TableMinSize>>		 [namespace code [list TableMinSize $tb %d]]
	bind $tb <<TableLayout>>		 [namespace code [list TableLayout $tb]]
	bind $tb <<LanguageChanged>>	+[namespace code [list ::scrolledtable::refresh $tb]]

	set tbGameNo [::toolbar::toolbar $frame \
		-id games-gameno \
		-hide 1 \
		-side bottom \
		-alignment center \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::GameNumber \
	]
	lappend Vars(toolbars) $tbGameNo
	set tbControl [::toolbar::toolbar $frame \
		-id games-control \
		-hide 1 \
		-side bottom \
		-alignment center \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control \
	]
	lappend Vars(toolbars) $tbControl
	set tbLayout [::toolbar::toolbar $frame \
		-id games-layout \
		-hide 1 \
		-side bottom \
		-alignment center \
		-allow {top bottom} \
		-tooltipvar ::mc::Layout \
	]
	lappend Vars(toolbars) $tbLayout
	
	::toolbar::add $tbControl button \
		-image $::icon::toolbarCtrlGotoStart \
		-tooltipvar [namespace current]::mc::GotoFirstPage \
		-command [namespace code [list Control $tb start] \
	]
	::toolbar::add $tbControl button \
		-image $::icon::toolbarCtrlBack \
		-repeatdelay $::theme::repeatDelay \
		-repeatinterval $::theme::repeatInterval \
		-tooltipvar [namespace current]::mc::PreviousPage \
		-command [namespace code [list Control $tb back] \
	]
	::toolbar::add $tbControl button \
		-image $::icon::toolbarCtrlStop \
		-tooltipvar [namespace current]::mc::GotoCurrentSelection \
		-command [namespace code [list Control $tb stop] \
	]
	::toolbar::add $tbControl button \
		-image $::icon::toolbarCtrlFwd \
		-repeatdelay $::theme::repeatDelay \
		-repeatinterval $::theme::repeatInterval \
		-tooltipvar [namespace current]::mc::NextPage \
		-command [namespace code [list Control $tb forward] \
	]
	::toolbar::add $tbControl button \
		-image $::icon::toolbarCtrlGotoEnd \
		-tooltipvar [namespace current]::mc::GotoLastPage \
		-command [namespace code [list Control $tb end] \
	]

	set cb [::toolbar::add $tbGameNo searchentry \
		-type number \
		-width 12 \
		-usehistory no \
		-parent $tb \
		-ghosttextvar [namespace current]::mc::GameNumber \
	]
	bind $cb <<Find>> [namespace code [list Goto $tb %d]]
	bind $cb <<FindNext>> [namespace code [list Goto $tb %d]]

	::toolbar::add $tbLayout button \
		-image $::icon::toolbarScrollbarRight \
		-variable [namespace current]::Options(layout) \
		-value right \
		-tooltipvar [namespace current]::mc::UseVerticalScrollbar \
		-command [namespace code [list ChangeLayout $tb right] \
	]
	::toolbar::add $tbLayout button \
		-image $::icon::toolbarScrollbarBottom \
		-variable [namespace current]::Options(layout) \
		-value bottom \
		-tooltipvar [namespace current]::mc::UseHorizontalScrollbar \
		-command [namespace code [list ChangeLayout $tb bottom] \
	]
	
	foreach w $Vars(toolbars) {
		foreach event {ToolbarShow ToolbarHide ToolbarFlat ToolbarIcon} {
			bind $w <<$event>> [namespace code [list ToolbarShow $tb %W]]
		}
	}

	::scidb::db::subscribe gameList \
		[list [namespace current]::Update $tb] \
		[list [namespace current]::Close $tb] \
		;
}


proc HeaderMenu {menu} {
	if {[$menu index end] ne "none"} { $menu add separator }
	::application::twm::makeLayoutMenu [::application::twm] $menu
}


proc View {pane base variant} {
	return 0
}


proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::clipbaseName
	variable ${path}::Vars

	if {$base ne $clipbaseName && [string length [file extension $base]] == 0} { return }
	set Vars(base) "$base:$variant"

	if {$view <= 0} {
		after cancel $Vars(after)

		set codec [::scidb::db::get codec $base]
		if {$Vars(codec) ne $codec} { CodecChanged $path $codec }

		if {$index == -1} {
			set n [::scidb::db::count games $base $variant]
			set Vars(after) [after idle [list ::gametable::update $path $base $variant $n]]
		} else {
			set Vars(after) [after idle [list ::gametable::fill $path $index [expr {$index + 1}]]]
		}
	}
}


proc Close {path base variant} {
	::gametable::forget $path $base $variant
}


proc CodecChanged {path newCodec} {
	variable ${path}::Vars

	set Vars(codec) $newCodec
	# we have to clear the country column if the codec is changing
	::gametable::clearColumn $path whiteCountry
	::gametable::clearColumn $path blackCountry
	::gametable::clearColumn $path eventCountry
}


proc AfterTWM {twm} {
	variable ${twm}::Priv
	variable ${Priv(table)}::Vars

	if {[info exists Vars(minsize)]} {
		GenerateTableMinSizeEvent $Priv(table)
	}
}


proc ChangeLayout {table dir} {
	variable ${table}::Vars
	variable Options

	if {$Options(layout) eq $dir} { return }
	set Options(layout) [expr {$Options(layout) eq "right" ? "bottom" : "right"}]
	lassign [::gametable::changeLayout $table $Options(layout)] width height

	if {[llength $width]} {
		lassign $Vars(minsize) minwidth minheight gridsize
		incr minwidth $width
		incr minheight $height
		set Vars(minsize) [list $minwidth $minheight $gridsize]
		GenerateTableMinSizeEvent $table
	}
}


proc ToolbarShow {table w} {
	GenerateTableMinSizeEvent $table
}


proc GenerateTableMinSizeEvent {table} {
	variable ${table}::Vars

	update idletasks
	set parent [winfo parent [winfo parent [winfo parent $table]]]
	event generate $parent <<TableMinSize>> -data $Vars(minsize) -when tail
}


proc TableMinSize {table minsize} {
	variable ${table}::Vars

	lassign $minsize minsize gridsize
	lassign $minsize minwidth minheight
	set Vars(minsize) [list $minwidth $minheight $gridsize]
	GenerateTableMinSizeEvent $table
}


proc TableLayout {table} {
	variable ${table}::Vars

	if {[llength $Vars(minsize)]} {
		# XXX its a trick, but it works!
		ChangeLayout $table ""
		ChangeLayout $table ""
	}
}


proc Control {table action} {
	variable ${table}::Vars

	::tooltip::hide

	switch $action {
		start		{ ::gametable::scroll $table home }
		end		{ ::gametable::scroll $table end }
		stop		{ ::gametable::scroll $table selection }
		back		{ ::gametable::scroll $table back }
		forward	{ ::gametable::scroll $table forward }
	}
}


proc Goto {table number} {
	variable ${table}::Vars

	set number [string trim [string map {. "" , ""} $number]]

	if {[string is integer -strict $number] && $number > 0} {
		set index [::scidb::db::get gameIndex [expr {$number - 1}] 0]
		if {$index >= 0} {
			::gametable::see $table $index
			::gametable::focus $table
			::gametable::activate $table [::gametable::indexToRow $table $index]
		}
	}
}


proc WriteTableOptions {chan variant {id "games"}} {
	variable TableOptions
	variable Tables

	if {$id ne "games"} { return }

	foreach table $Tables {
		set id [::application::twm::getId $table]
		if {[info exists TableOptions($variant:$id)]} {
			puts $chan "::scrolledtable::setOptions db:games:$id {"
			::options::writeArray $chan $TableOptions($variant:$id)
			puts $chan "}"
		}
	}
}
::options::hookTableWriter [namespace current]::WriteTableOptions


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}
::options::hookWriter [namespace current]::WriteOptions


proc SaveOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	set TableOptions($variant:$id) [::scrolledtable::getOptions db:games:$id]
}


proc RestoreOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	::scrolledtable::setOptions db:games:$id $TableOptions($variant:$id)
}


proc CompareOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	if {[::scrolledtable::countOptions db:games:$id] == 0} { return true }
	set lhs $TableOptions($variant:$id)
	set rhs [::scrolledtable::getOptions db:games:$id]
	return [::arrayListEqual $lhs $rhs]
}


::options::hookSaveOptions \
	[namespace current]::SaveOptions \
	[namespace current]::RestoreOptions \
	[namespace current]::CompareOptions \
	;

} ;# namespace games
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
