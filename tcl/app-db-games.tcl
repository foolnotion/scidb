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
	number white whiteElo black blackElo event result site date round length eco deleted acv
}

variable Tables {}
variable Layout bottom


proc build {parent} {
	variable Options
	variable Columns
	variable Tables

	set tb $parent.table
	::gametable::build $tb              \
		[namespace code [list View $tb]] \
		$Columns                         \
		-useScale 1                      \
		-layout $Options(layout)         \
		;

	namespace eval [namespace current]::$tb {}
	variable [namespace current]::${tb}::Vars
	array set Vars {
		minheight	0
		minsize		{}
		gameno		{}
	}

#	set Vars(slider)		[$sc cget -sliderlength]
	set Vars(layout)		$Options(layout)
	set Vars(theme)		[::theme::currentTheme]
	set Vars(toolbars)	{}
	set Vars(after)		{}
	set Vars(resizing)	0

	bind $tb <<TableMinSize>>	[namespace code [list TableMinSize $tb %d]]
	bind $tb <<TableLayout>>	[namespace code [list TableLayout $tb]]
	bind $tb <<TableResized>>	[namespace code [list TableResized $tb %d]]
	bind $tb <<Language>>		[namespace code [list ::scrolledtable::refresh $tb]]

	set tbGameNo [::toolbar::toolbar $parent \
		-id gameno \
		-hide 1 \
		-side bottom \
		-alignment center \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::GameNumber] \
		;
	lappend Vars(toolbars) $tbGameNo
	set tbControl [::toolbar::toolbar $parent \
		-id control \
		-hide 1 \
		-side bottom \
		-alignment center \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Control] \
		;
	lappend Vars(toolbars) $tbControl
#	set tbFind [::toolbar::toolbar $parent \
#		-id find \
#		-hide 1 \
#		-side bottom \
#		-alignment center \
#		-allow {top bottom} \
#		-tooltipvar [namespace current]::mc::FindText] \
	;
#	lappend Vars(toolbars) $tbFind
	set tbLayout [::toolbar::toolbar $parent \
		-id layout \
		-hide 1 \
		-side bottom \
		-alignment center \
		-allow {top bottom} \
		-tooltipvar ::mc::Layout] \
		;
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

	::toolbar::add $tbGameNo label -float 0 -textvar [::mc::var [namespace current]::mc::GameNumber ":"]
	set gameno [::toolbar::add $tbGameNo ::ttk::entry \
		-width 8 \
		-takefocus 1 \
		-textvariable [namespace current]::${tb}::Vars(gameno) \
		-validatecommand { return [expr {%d == 0 || [string match {[0-9]*} [string trim "%P"]]}] } \
		-validate key \
		-invalidcommand { bell } \
	]
	bind $gameno <Return> [namespace code [list Goto $tb]]
	bind $gameno <Any-Button> +[list focus $gameno]
	bind $gameno <FocusOut> [namespace code [list ResetGameNo $tb]]
	::toolbar::add $tbGameNo button \
		-image $::icon::22x22::enter \
		-tooltipvar [namespace current]::mc::GotoEnteredGameNumber \
		-command [namespace code [list Goto $tb]] \
		;

#	::toolbar::add $tbFind label -float 0 -textvar [::mc::var [namespace current]::mc::FindText ":"]
#	::toolbar::add $tbFind ttk::combobox -width 20
#	::toolbar::add $tbFind button -image $::icon::22x22::enter -command {}

	::toolbar::add $tbLayout button \
		-image $::icon::toolbarScrollbarRight \
		-variable [namespace current]::Options(layout) \
		-value right \
		-tooltipvar [namespace current]::mc::UseVerticalScrollbar \
		-command [namespace code [list ChangeLayout $tb right]]
		;
	::toolbar::add $tbLayout button \
		-image $::icon::toolbarScrollbarBottom \
		-variable [namespace current]::Options(layout) \
		-value bottom \
		-tooltipvar [namespace current]::mc::UseHorizontalScrollbar \
		-command [namespace code [list ChangeLayout $tb bottom]] \
		;
	
	foreach w $Vars(toolbars) {
		foreach event {ToolbarShow ToolbarHide ToolbarFlat ToolbarIcon} {
			bind $w <<$event>> [namespace code [list ToolbarShow $tb %W]]
		}
	}

	if {$tb ni $Tables} { lappend Tables $tb }
	::scidb::db::subscribe gameList [namespace current]::Update [namespace current]::Close $tb
}


proc activate {w menu flag} {
	::toolbar::activate $w $flag
#	::gametable::focus $w.table
}


proc prepareSwitch {w newCodec} {
	# we have to clear the country column if the codec is changing
	if {[::scidb::db::get codec] ne $newCodec} {
		::gametable::clearColumn $w.table whiteCountry
		::gametable::clearColumn $w.table blackCountry
		::gametable::clearColumn $w.table eventCountry
	}
}


proc overhang {parent} {
	return [::gametable::overhang $parent.table]
}


proc borderwidth {parent} {
	return [::gametable::borderwidth $parent.table]
}


proc View {pane base} {
	return 0
}


proc Update {path base {view -1} {index -1}} {
	variable ${path}::Vars

	if {$view <= 0} {
		after cancel $Vars(after)

		if {$index == -1} {
			set Vars(after) [after idle [list ::gametable::update $path $base [::scidb::db::count games]]]
		} else {
			set Vars(after) [after idle [list ::gametable::fill $path $index [expr {$index + 1}]]]
		}
	}
}


proc Close {path base} {
	::gametable::forget $path $base
}


proc ChangeLayout {table dir} {
	variable ${table}::Vars
	variable Options

	if {$Options(layout) eq $dir} { return }
	if {$Options(layout) eq "right"} { set Options(layout) bottom } else { set Options(layout) right }
	lassign [::gametable::changeLayout $table $Options(layout)] width height

	if {[llength $width]} {
		incr Vars(minwidth) $width
		incr Vars(minheight) $height
		set Vars(minsize) [list [lindex $Vars(minsize) 0] [expr {[lindex $Vars(minsize) 1] + $height}]]

		set top [winfo toplevel $table]
		if {$Vars(minwidth) > [winfo width $table]} {
			[winfo parent $table] configure -width $Vars(minwidth)
			wm minsize $top $Vars(minwidth) $Vars(minheight)
		} else {
#			# avoid resizing (multicolumn problem)
#			wm geometry $top [wm geometry $top]
			wm minsize $top $Vars(minwidth) $Vars(minheight)
		}

		GenerateTableMinSizeEvent $table
	}
}


proc TableResized {table height} {
	variable ${table}::Vars

	set overhang [::gametable::overhang $table]
	# TODO: grid table height (but avoid Configure [see table.tcl])
	# NOTE: currently overhang is 2 pixels too large
}


proc ToolbarShow {table w} {
	variable ${table}::Vars

#	# avoid resizing (multicolumn problem)
#	wm geometry [winfo toplevel $table] [wm geometry [winfo toplevel $table]]
	GenerateTableMinSizeEvent $table
}


proc GenerateTableMinSizeEvent {table} {
	variable ${table}::Vars

	# may invoked before configuration completed
	if {![info exists Vars(minwidth)]} { return }

	update idletasks
	set data [list $Vars(minwidth) [ComputeMinHeight $table] $Vars(gridsize)]
	event generate [winfo parent $table] <<TableMinSize>> -data $data
}


proc TableLayout {table} {
	variable ${table}::Vars

	if {[llength $Vars(minsize)]} {
		# its a trick, but it works!
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


proc Goto {table} {
	variable ${table}::Vars

	set Vars(gameno) [string trim [string map {. "" , ""} $Vars(gameno)]]
	if {[llength $Vars(gameno)] && [string is integer $Vars(gameno)] && $Vars(gameno) > 0} {
		set index [::scidb::db::get gameIndex [expr {$Vars(gameno) - 1}] 0]
		if {$index >= 0} {
			::gametable::scroll $table $index
			after idle [list ::gametable::activate $table [::gametable::indexToRow $table $index]]
		}
	}
	ResetGameNo $table
}


proc ResetGameNo {table} { set ${table}::Vars(gameno) "" }


proc TableMinSize {table minsize} {
	variable ${table}::Vars

	lassign $minsize minsize gridsize
	lassign $minsize minwidth minheight
	set Vars(gridsize) $gridsize
	set Vars(minsize) $minsize

	update idletasks
#	# avoid resizing (multicolumn problem)
#	wm geometry [winfo toplevel $table] [wm geometry [winfo toplevel $table]]

	set mintblwidth [winfo width $table]
	if {$mintblwidth <= 1} { set mintblwidth [lindex $minsize 0] }

	set top [winfo toplevel $table]
	incr minwidth [winfo width $top]
	incr minwidth [expr {-$mintblwidth}]
	set Vars(minwidth) $minwidth
	lassign [wm minsize $top] mw mh
	wm minsize $top $minwidth $mh
	set minheight [ComputeMinHeight $table]
	set Vars(minheight) $minheight

	event generate [winfo parent $table] <<TableMinSize>> -data [list $minwidth $minheight $gridsize]
}


proc ComputeMinHeight {table} {
	variable ${table}::Vars

	# TODO computation is incorrect!
	set minheight [lindex $Vars(minsize) 1]
	incr minheight [winfo height [winfo parent $table]]
	incr minheight -[winfo height $table]

	return $minheight
}


proc WriteOptions {chan} {
	variable Tables

	::options::writeItem $chan [namespace current]::Options

	foreach table $Tables {
		variable ${table}::Vars
		puts $chan "::gametable::setOptions $table {"
		::options::writeArray $chan [::gametable::getOptions $table]
		puts $chan "}"
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace games
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
