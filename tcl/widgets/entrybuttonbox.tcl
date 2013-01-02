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
# Copyright: (C) 2011-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source entry-button-box

package provide entrybuttonbox 1.0

namespace eval ttk {

proc entrybuttonbox {w args} {
	return [entrybuttonbox::Build $w {*}$args]
}

namespace eval entrybuttonbox {

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	array set opts { -state readonly }
	array set opts $args

	foreach option [array names opts] {
		switch -- $option {
			-invalidcommand   -
			-postcommand      -
			-readonly         -
			-show             -
			-validate         -
			-validatecommand  -
			-values           -
			-xscrollincrement {
				error "invalid option \"$option\""
			}

			-command {
				set Vars($option) $opts($option)
				array unset opts $option
			}

			-state {
				if {$opts($option) eq "disabled"} {
					set opts($option) disabled
				}
			}
		}
	}

	ttk::combobox $w -class TEntryButtonBox -style entrybuttonbox.TCombobox {*}[array get opts]

	ChangeStyle $w
	bind $w <<ThemeChanged>> [namespace code [list ChangeStyle $w]]
	bind $w <<ComboboxSelected>> [namespace code [list ComboboxSelected $w]]
	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			$w.__w__ delete 0 end
			return [$w.__w__ insert 0 [lindex $args 0]]
		}

		current - validate {
			error "invalid command \"$command\""
		}

		configure {
			if {[llength $args] % 2 == 1} {
				error "value for \"[lindex $args end]\" missing"
			}
			array set opts $args
			if {[info exists opts(-state)]} {
				if {$opts(-state) eq "normal"} { set opts(-state) readonly }
			}
			set args [array get opts]
		}

		invoke {
			if {[$w cget -state] ne "disabled"} {
				{*}[set ttk::entrybuttonbox::${w}::Vars(-command)]
			}
			return
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.__w__ instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}
	}

	return [$w.__w__ $command {*}$args]
}


proc ChangeStyle {w} {
	if {"entrybuttonbox.downarrow" ni [ttk::style element names]} {
		if {[font metrics [$w cget -font] -linespace] == 15} {
			set icon $icon::dots([::theme::currentTheme])
		} else {
			set icon $icon::14x16::open
		}
		ttk::style element create entrybuttonbox.downarrow image $icon
		ttk::style layout entrybuttonbox.TCombobox {
			Combobox.field -sticky nswe -children {
				entrybuttonbox.downarrow -side right -sticky ns
				Combobox.padding -expand 1 -sticky nswe -children {
					Combobox.textarea -sticky nswe
				}
			}
		} 
	}
	$w configure -style entrybuttonbox.TCombobox
}


namespace eval icon {
namespace eval 14x16 {

set open [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAAQCAMAAAARSr4IAAAA9lBMVEW4vLy2urpQWlpQWlpQ
	WlqBiIiEi4uzt7e2urqgpqahp6eZoaGaoaGboaGboqJYYmJZY2NaZGRbZWVdZmZdZ2deaGhf
	aWlibGxjbW1mcHBrdHRueHhxe3t2gIB9h4d+hoaAiYmCi4uCjYyEj46Hjo6Hk5GJkpKJlZOK
	lJSLk5OLlZWMmZaOm5iRn5uToZ2WpKCYpaKaoqKbqqWcq6adpaWdq6afqqegp6ehq6mirauk
	sKymr66msLCssrKwurqyvLy1v7+4v7+5v7+5w8O7wMC9x8fBy8vEzs7FysrI0tLM1tbQ2trY
	4eHa4+Pg5ubh5+fx9PT09vZjn+UlAAAAAXRSTlMAQObYZgAAAHpJREFUCB0FwdFJQ1EQBcDZ
	lzURJMQvK7CN9G49IgYEUcm7e5wBAJTD8wn4u43q66WAfL1NP51XgDpfbn1c78tj5dfh5ahX
	7vENk2iZABU6MwFqouU+gNCyB6jEBgB0Zg2wDV3rFWCnH/YpINP69rEB+FRO20ZV2X/iH/pG
	OwhaoTPGAAAAAElFTkSuQmCC
}]

} ;# namespace 14x16
# namespace eval 12x16 {
#
# set dots [image create photo -data {
	# iVBORw0KGgoAAAANSUhEUgAAAAwAAAAQCAQAAACIaFaMAAAAF0lEQVQY02NgGAVYwX+G/2gk
	# AxMdrAUAn9YF/e5hLfQAAAAASUVORK5CYII=
# }]
#
# } ;# namespace 12x16
namespace eval 14x17 {	;# alt

set normal [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAARCAAAAADIo8JDAAAAIklEQVQI12P4jwwYGP7fRICm
	QcRlYIAirFy8epuQAAMaAACYlKF3/7a3CQAAAABJRU5ErkJggg==
}]

set active [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA4AAAARCAAAAADIo8JDAAAAIklEQVQI12P4jwwYGP6/QYCm
	QcRlYIAirFy8epuQAAMaAABh96wBoaEfRAAAAABJRU5ErkJggg==
}]

} ;# namespace 14x17
namespace eval 13x17 {	;# default

set normal [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA0AAAARCAAAAAAjlHlAAAAAHklEQVQI12P4jwwY/t9EgKYB
	5zEwQBEWHtGmNCEBAMi2rEtkp1/8AAAAAElFTkSuQmCC
}]

set active [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAA0AAAARCAAAAAAjlHlAAAAAHklEQVQI12P4jwwY/r9BgKYB
	5zEwQBEWHtGmNCEBADuPt6ZjsVvUAAAAAElFTkSuQmCC
}]

} ;# namespace 13x17

set dots(default)	[list $13x17::normal active $13x17::active]
set dots(alt)		[list $14x17::normal active $14x17::active]
set dots(clam)		$14x16::open

} ;# namespace icon
} ;# namespace entrybuttonbox
} ;# namespace ttk

ttk::copyBindings TEntry TEntryButtonBox
ttk::copyBindings TCombobox TEntryButtonBox

bind TEntryButtonBox <KeyPress-Down>	{ {*}[set ttk::entrybuttonbox::%W::Vars(-command)] }
bind TEntryButtonBox <KeyPress-space>	{ {*}[set ttk::entrybuttonbox::%W::Vars(-command)] }
bind TEntryButtonBox <<TraverseIn>>		{ ttk::combobox::TraverseIn %W  }

bind TEntryButtonBox <ButtonPress-1> {
	if {[%W cget -state] ne "disabled"} {
		{*}[set ttk::entrybuttonbox::%W::Vars(-command)]
	}
}

# vi:set ts=3 sw=3:
