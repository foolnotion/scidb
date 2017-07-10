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

package require Tk 8.5
package provide toolbar 1.0

namespace eval toolbar {

namespace eval mc {

set IconSize		"Icon Size"
set Default			"Default"
set Small			"Small"
set Medium			"Medium"
set Large			"Large"
set Flat				"Flat"
set Hide				"Hide"
set Floating		"Floating"
set Top				"Top"
set Bottom			"Bottom"
set Left				"Left"
set Right			"Right"
set Center			"Center"
set Expand			"Expand"
set Toolbar			"Toolbar"
set Orientation	"Orientation"
set Alignment		"Alignment"

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

variable iconSizes {medium small large}

variable Counter	0
variable Initialize 1
variable HaveTooltips 1
variable Lookup [dict create]
variable Map [dict create]

set Specs(toolbars) {}
set Specs(repeat) {}

if {[catch {package require tooltip}]} { set HaveTooltips 0 }

array set Defaults {
	button:selectcolor			#e0e0e0
	toolbar:padding				2
	toolbar:activebackground	#d9d9e4
	toolbar:overrelief			solid
	toolbar:relief					flat
	toolbarframe:forget			false
	toolbarframe:alignment		left
	toolbarframe:iconsize		false
	toolbarframe:padding			1
	handle:size						6
	handle:doubleclick			false
	handle:color:dark				#000000
	handle:color:lite				#ffffff
	handle:color:gray				#efefef
	flathandle:relief				flat
	flathandle:width				30
	floating:frame:background	#ffdd76
	floating:frame:foreground	black
	floating:frame:activebg		#4590db
	floating:frame:activefg		white
	floating:overrideredirect	false
	floating:focusmodel			active
	drag:color:snapping			red
	drag:color:floating			black
	icons:x11Hack					true
	dialog:class					*Dialog*
	dialog:snapping:x				35
	dialog:snapping:y				35
}
# button:selectcolor #d1dbe0

array set Options {
	icons:size						medium
}


event add <<ToolbarHide>>		ToolbarHide
event add <<ToolbarFlat>>		ToolbarFlat
event add <<ToolbarShow>>		ToolbarShow
event add <<ToolbarIcon>>		ToolbarIcon
event add <<ToolbarDisabled>>	ToolbarDisabled
event add <<ToolbarEnabled>>	ToolbarEnabled


proc mc {tok} { return [tk::msgcat::mc [set $tok]] }
proc makeStateSpecificIcons {img} { return $img }
proc configureCheckEntry {m} { return $m }
proc configureRadioEntry {m} { return $m }


proc toolbar {parent args} {
	variable Specs
	variable Initialize
	variable Defaults
	variable Options
	variable Counter
	variable Lookup
	variable Map

	set path $parent
	if {$path ne "."} { set path "$path." }

	set haveId false

	foreach {arg val} $args {
		if {$arg eq "-id"} {
			set id $val
			set haveId true
		}
	}

	if {!$haveId} { set id [incr Counter] }

	set toolbar ${path}__tb__${id}
	set handle $toolbar.handle

	array set Specs [list                           \
		packed:$toolbar		0                       \
		expandable:$toolbar	0                       \
		hide:$toolbar			0                       \
		flat:$toolbar			1                       \
		float:$toolbar			1                       \
		small:$toolbar			0                       \
		medium:$toolbar		0                       \
		large:$toolbar			0                       \
		icon:$toolbar			0                       \
		finish:$toolbar		0                       \
		hidden:$toolbar		0                       \
		takefocus:$toolbar	0                       \
		usehandle:$toolbar	1                       \
		padx:$toolbar			0                       \
		pady:$toolbar			0                       \
		keepoptions:$toolbar	1                       \
		enabled:$toolbar		1                       \
		side:$toolbar			top                     \
		state:$toolbar			show                    \
		default:$toolbar		$Options(icons:size)    \
		iconsize:$toolbar		default                 \
		id:$toolbar				$id                     \
		position:$toolbar		{}                      \
		variables:$toolbar	{}                      \
		title:$toolbar			{}                      \
		titlevar:$toolbar		{}                      \
		allow:$toolbar			{left right top bottom} \
		justify:$toolbar		left                    \
                                                   \
		tooltipvar:$handle:$toolbar	{}             \
		tooltip:$handle:$toolbar		{}             \
	]

	set options {}
	set alignment $Defaults(toolbarframe:alignment)

	foreach {arg val} $args {
		switch -- $arg {
			-hide				{ set Specs(hide:$toolbar) $val }
			-flat				{ set Specs(flat:$toolbar) $val }
			-float			{ set Specs(float:$toolbar) $val }
			-side				{ set Specs(side:$toolbar) $val }
			-tooltip			{ if {[llength $val]} { set Specs(tooltip:$handle:$toolbar) $val } }
			-tooltipvar		{ if {[llength $val]} { set Specs(tooltipvar:$handle:$toolbar) $val } }
			-title			{ set Specs(title:$toolbar) $val }
			-titlevar		{ set Specs(titlevar:$toolbar) $val }
			-orientation	{ set Specs(side:$toolbar) $val }
			-alignment		{ set alignment $val }
			-iconsize		{ set Specs(iconsize:$toolbar) $val }
			-state			{ set Specs(state:$toolbar) $val }
			-allow			{ set Specs(allow:$toolbar) $val }
			-justify			{ set Specs(justify:$toolbar) $val }
			-expandable		{ set Specs(expandable:$toolbar) $val }
			-usehandle		{ set Specs(usehandle:$toolbar) $val }
			-padx				{ set Specs(padx:$toolbar) $val }
			-pady				{ set Specs(pady:$toolbar) $val }
			-keepoptions	{ set Specs(keepoptions:$toolbar) $val }
			-enabled			{ set Specs(enabled:$toolbar) $val }
			-id				{ ;# skip }
			default			{ lappend options $arg $val }
		}
	}

	if {!$haveId} { set Specs(keepoptions:$toolbar) 0 }
	set parent [join [lrange [split $toolbar .] 0 end-1] .]
	lappend Specs(count:$parent) $toolbar
	lappend Specs(remember:$parent) $toolbar

	if {$haveId} {
		dict set Lookup $parent:$Specs(id:$toolbar) $toolbar
		dict set Map $toolbar $Specs(id:$toolbar)
		lappend Specs(idlist:$parent) $id

		if {[info exists Specs(options:$parent)]} {
			if {![info exists Specs(idlist:$parent)]} {
				setOptions $parent $Specs(options:$parent)
				unset -nocomplain Specs(configure:$parent)
			}
			array set opts $Specs(options:$parent)
			if {[info exists opts(state:$id)]} {
				foreach key {iconsize position side state} {
					set Specs($key:$toolbar) $opts($key:$id)
				}
			}
			if {$Specs(state:$toolbar) eq "float"} {
				set Specs(state:$toolbar) "hide"
				set Specs(finish:$toolbar) 1
			}
			set dir $Specs(side:$toolbar)
			set tbf [Join $parent __tbf__$Specs(side:$toolbar)]
			if {[info exists Specs(childs:$tbf)]} {
				set childs $Specs(childs:$tbf)
			} else {
				set childs {}
			}
			if {[info exists Specs(childs:id:$tbf)]} {
				set index -1
				foreach i $Specs(childs:id:$tbf) {
					if {[dict exists $Lookup $parent:$i]} { 
						set child [dict get $Lookup $parent:$i]
						set order([incr index]) $child
						if {$child ni $childs} { lappend childs $child }
					}
				}
				set Specs(childs:$tbf) {}
				set n [llength $Specs(childs:id:$tbf)]
				for {set i 0} {$i < $n} {incr i} {
					if {[info exists order($i)] && $order($i) in $childs} {
						lappend Specs(childs:$tbf) $order($i)
					}
				}
			}
			set alignment ""
		}
	}

	set Specs(lookup:$Specs(id:$toolbar):$toolbar) $toolbar
	if {[llength $Specs(tooltip:$handle:$toolbar)] == 0} {
		set Specs(tooltip:$handle:$toolbar) $Specs(title:$toolbar)
	}
	if {[llength $Specs(tooltipvar:$handle:$toolbar)] == 0} {
		set Specs(tooltipvar:$handle:$toolbar) $Specs(titlevar:$toolbar)
	}
	if {[llength $Specs(title:$toolbar)] == 0} {
		set Specs(title:$toolbar) $Specs(tooltip:$handle:$toolbar)
	}
	if {[llength $Specs(titlevar:$toolbar)] == 0} {
		set Specs(titlevar:$toolbar) $Specs(tooltipvar:$handle:$toolbar)
	}
	if {[llength $Specs(title:$toolbar)] == 0 && [llength $Specs(titlevar:$toolbar)] == 0} {
		set Specs(hide:$toolbar) 0
		set Specs(float:$toolbar) 0
		set Specs(flat:$toolbar) 0
	}
	if {$Specs(hide:$toolbar)} { lappend Specs(toolbars:$parent) $toolbar }
	set Specs(menu:$toolbar) $Specs(state:$toolbar)

	tk::frame $toolbar -relief $Defaults(toolbar:relief) -borderwidth 0 -class Toolbar {*}$options
	set Specs(frame:background) [$toolbar cget -background]
	bind $toolbar <Destroy> [namespace code [list Cleanup $toolbar]]

	if {$Specs(side:$toolbar) eq "top" || $Specs(side:$toolbar) eq "bottom"} {
		switch $Specs(justify:$toolbar) {
			top		{ set Specs(justify:$toolbar) left }
			bottom	{ set Specs(justify:$toolbar) right }
		}
		set Specs(orientation:$toolbar) horz
		set widgetOptions [list -side left -padx $Defaults(toolbar:padding)]
		set handleOptions {-side left -fill y -expand yes}
	} else {
		switch $Specs(justify:$toolbar) {
			left		{ set Specs(justify:$toolbar) top }
			right		{ set Specs(justify:$toolbar) bottom }
		}
		set Specs(orientation:$toolbar) vert
		set widgetOptions [list -side top -pady $Defaults(toolbar:padding)]
		set handleOptions {-side top -fill x -expand yes}
	}
	
	set widgets [tk::frame $toolbar.widgets -borderwidth 0 -takefocus 0]
	set tbf [Join $parent __tbf__$Specs(side:$toolbar)]
	bind $toolbar <Configure> [namespace code [list Resize $tbf]]

	if {$Specs(usehandle:$toolbar)} {
		CreateHandle $toolbar $toolbar.handle
		pack $handle {*}$handleOptions
		bind $widgets <ButtonPress-3> [namespace code [list Menu $toolbar %X %Y]]
		bind $toolbar <ButtonPress-3> [namespace code [list Menu $toolbar %X %Y]]
	}

	if {$Specs(enabled:$toolbar)} {
		pack $widgets {*}$widgetOptions
	}

	switch $Specs(state:$toolbar) {
		flat - hide	{ Hide $toolbar $Specs(state:$toolbar) }
		show			{ Show $toolbar $alignment }
	}

	if {$Initialize} {
		trace add variable [namespace current]::Options(icons:size) write [namespace code SetIconSize]
		set Initialize 0
	}

	lappend Specs(toolbars) $toolbar

	if {![info exists Specs(activated:$parent)]} {
		set Specs(activated:$parent) 0
	}

	return $toolbar
}


proc add {args} {
	if {[llength $args] > 1} { return [Add {*}$args] }

	set widget [lindex $args 0]
	set toolbar [winfo parent $widget]

	if {$widget ni [pack slaves $toolbar.widgets]} {
		PackWidget $toolbar $widget
		if {[winfo exists $toolbar.floating.frame]} { CloneWidget $toolbar $widget }
	}
}


proc addSeparator {toolbar} {
	variable Counter
	variable Defaults
	variable Specs

	set w $toolbar.__tbs__[incr Counter]
	tk::frame $w -class ToolbarSeparator -relief sunken -borderwidth 1
	if {$Specs(usehandle:$toolbar)} {
		bind $w <ButtonPress-3> [namespace code [list Menu $toolbar %X %Y]]
	}
	set Specs(float:$w:$toolbar) 1
	PackWidget $toolbar $w
	if {[winfo exists $toolbar.floating.frame]} { CloneWidget $toolbar $w }
	return $w
}


proc remove {widget} {
	variable Specs

	set toolbar [winfo parent $widget]
	pack forget $widget
	catch { pack forget $Specs(child:$widget:$toolbar.floating.frame) }
}


proc forget {widget} {
	variable Specs

	if {[winfo exists $widget]} {
		set toolbar [winfo parent $widget]
		destroy $widget
		catch { destroy $Specs(child:$widget:$toolbar.floating.frame) }
		array unset Specs *:$widget:$toolbar
	}
}


proc children {toolbar} {
	return [pack slaves $toolbar.widgets]
}


proc childconfigure {w args} {
	variable Specs
	variable HaveTooltips

	set toolbar [winfo parent $w]

	foreach {key val} $args {
		switch -- $key {
			-tooltip - -tooltipvar {
				set key [string range $key 1 end]
				set Specs($key:$w:$toolbar) $val
				set v Specs(child:$w:$toolbar.floating.frame)
				if {[info exists $v]} {
					set Specs($key:[set $v]:$toolbar.floating.frame) $val
				}
			}

			-state {
				if {$Specs(state:$w:$toolbar) ne $val} {
					set Specs(state:$w:$toolbar) $val
				}
			}

			-image {
				SetupIcons $toolbar $w $val
				set size $Specs(iconsize:$toolbar)
				if {$size eq "default"} { set size $Specs(default:$toolbar) }
				if {[info exists Specs($size:$w:$toolbar)] && [llength $Specs($size:$w:$toolbar)]} {
					set state $Specs(state:$w:$toolbar)
					set icon $Specs($size-$state:$w:$toolbar)
					if {[$w cget -image] ne $icon} {
						$w configure -image $icon
						if {[info exists Specs(child:$w:$toolbar.floating.frame)]} {
							$Specs(child:$w:$toolbar.floating.frame) configure -image $icon
						}
					}
				}
			}

			default {
				$w configure $key $val
				if {[info exists Specs(child:$w:$toolbar.floating.frame)]} {
					$Specs(child:$w:$toolbar.floating.frame) configure $key $val
				}
			}
		}
	}

	if {$HaveTooltips} {
		SetupTooltips $w
		if {"-state" in $args} { Tooltip hide $w }
	}
}


proc childcget {w key} {
	variable Specs

	set toolbar [winfo parent $w]
	switch -- $key {
		-state - -tooltip - -tooltipvar {
			set key [string range $key 1 end]
			return $Specs($key:$w:$toolbar)
		}
	}
	return -code error "unknown option '$key'"
}


proc deactivate {parent} {
	activate $parent 0
}


proc activate {parent {flag 1}} {
	variable Specs

	if {$flag} { set state normal } else { set state withdrawn }
	set Specs(activated:$parent) $flag

	foreach dir {top bottom left right} {
		set tbf [Join $parent __tbf__$dir]
		set childs {}
		if {[info exists Specs(childs:$tbf)]} {
			foreach toolbar $Specs(childs:$tbf) {
				if {[winfo exists $toolbar.floating]} {
					wm state $toolbar.floating $state
				}
			}
		}
	}
}


proc activeParents {} {
	variable Specs

	set result {}

	foreach entry [array names Specs activated:*] {
		set parent [string range $entry 10 end]
		if {$Specs(activated:$parent)} {
			set use 0
			if {[winfo ismapped $parent]} {
				foreach dir {top left right bottom} {
					set tbf [Join $parent __tbf__$dir]
					if {[info exists Specs(childs:$tbf)]} {
						foreach toolbar $Specs(childs:$tbf) {
							if {$Specs(hide:$toolbar)} {
								set use 1
							}
						}
					}
				}
			}
			if {$use} {
				lappend result $parent
			}
		}
	}

	return $result
}


proc getOptions {parent} {
	variable Specs
	variable Lookup
	variable Map

	if {![info exists Specs(count:$parent)]} { return $Specs(options:$parent) }
	set options {}

	if {[info exists Specs(frame:order:$parent)]} {
		lappend options frame:order $Specs(frame:order:$parent)
	}

	foreach dir {top bottom left right} {
		set tbf [Join $parent __tbf__$dir]
		set childs {}
		if {[info exists Specs(childs:$tbf)]} {
			lappend options alignment:$dir $Specs(alignment:$tbf)
			foreach toolbar $Specs(childs:$tbf) {
				if {[dict exists $Map $toolbar]} { lappend childs [dict get $Map $toolbar] }
			}
			lappend options frame:childs:$dir $childs
		}
	}

	if {[info exists Specs(idlist:$parent)]} {
		foreach id $Specs(idlist:$parent) {
			set toolbar [dict get $Lookup $parent:$id]
			foreach {key val} [array get Specs *:$toolbar] {
				if {![string match *:*:* $key]} {
					switch -glob $key {
						side:* - iconsize:* - position:* - justify:* {
							set key [string range $key 0 [expr {[string first : $key] - 1}]]
							lappend options $key:$id $val
						}
						state:* {
							if {$Specs(finish:$toolbar)} {
								lappend options state:$id float
							} else {
								lappend options state:$id $val
							}
						}
					}
				}
			}
		}
	}

	return $options
}


proc setOptions {parent options} {
	variable Specs

	set Specs(options:$parent) $options
	array set opts $options

	if {[info exists opts(frame:order)]} {
		set Specs(frame:order:$parent) $opts(frame:order)
	}

	foreach dir {top left right bottom} {
		if {[info exists opts(frame:childs:$dir)]} {
			set tbf $parent.__tbf__$dir
			set Specs(childs:id:$tbf) $opts(frame:childs:$dir)
			set Specs(alignment:$tbf) $opts(alignment:$dir)
		}
	}
}


proc show {toolbar} {
	Show $toolbar ""
}


proc getState {toolbar} {
	return [set [namespace current]::Specs(state:$toolbar)]
}


proc getIconSize {toolbar}	{
	variable Specs

	set size $Specs(iconsize:$toolbar)
	if {$size eq "default"} { set size $Specs(default:$toolbar) }
	return $size
}


proc setState {toolbar state} {
	variable Specs

	switch $state {
		enabled - normal {
			if {$Specs(enabled:$toolbar)} { return }
			set Specs(enabled:$toolbar) 1
			set state $Specs(state:$toolbar)
			if {$Specs(finish:$toolbar) && $state eq "hide"} { set state float }

			switch $state {
				flat	{ Hide $toolbar flat }
				show	{ show $toolbar }
				float	{
					if {[info exists Specs(position:$toolbar)] && [llength $Specs(position:$toolbar)] == 2} {
						set tl [winfo toplevel $toolbar]
						lassign $Specs(position:$toolbar) x y
						set x [expr {$x + [winfo rootx $tl]}]
						set y [expr {$y + [winfo rooty $tl]}]
					} else {
						set x [winfo rootx $toolbar]
						set y [winfo rooty $toolbar]
					}
					UndockToolbar $toolbar $x $y
				}
			}

			event generate $toolbar <<ToolbarEnabled>>
		}

		disabled {
			if {$Specs(enabled:$toolbar)} {
				set Specs(enabled:$toolbar) 0
				set state $Specs(state:$toolbar)
				if {[winfo exists $toolbar.floating]} {
					destroy $toolbar.floating
				}
				RemoveFlatHandle $toolbar
				Forget $toolbar
				set Specs(state:$toolbar) $state
				event generate $toolbar <<ToolbarDisabled>>
			}
		}

		float	{ UndockToolbar $toolbar [winfo rootx $toolbar] [winfo rooty $toolbar] }
		flat	{ Hide $toolbar flat }
		hide	{ Hide $toolbar hide }
		show	{ show $toolbar }
	}
}



proc addToolbarMenu {menu parent {index -1} {var {}}} {
	variable Specs

	if {![info exists Specs(toolbars:$parent)]} { return -1 }
	if {[string length $var] == 0} { set var [namespace current]::mc::Toolbar }

	if {$index eq "end" || $index eq "last"} {
		set m [menu $menu.__tb__Toolbar -tearoff false]
		$menu add cascade -menu $m
		set index [$menu index last]
		if {$index eq "none"} { set index -1 }
	} elseif {[string is integer -strict $index] && $index >= 0} {
		set m [menu $menu.__tb__Toolbar -tearoff false]
		$menu insert cascade $index -menu $m
	} else {
		set m $menu
	}

	if {$index >= 0} {
		set cmd "[namespace current]::SetMenuLabel $menu $index"
		trace add variable $var write $cmd
		bind $menu <Destroy> +[list trace remove variable $var write $cmd]
		SetMenuLabel $menu $index $var
	}

	set i [$m index last]
	if {$i eq "none"} { set i -1}
	incr i

	foreach tb $Specs(toolbars:$parent) {
		$m add checkbutton \
			-onvalue 0 \
			-offvalue 1 \
			-variable [namespace current]::Specs(hidden:$tb) \
			-command "[namespace current]::ShowToolbar $tb" \
			;

		if {[llength $Specs(titlevar:$tb)]} {
			set var $Specs(titlevar:$tb)
			SetMenuLabel $m $i $var
			set cmd "[namespace current]::SetMenuLabel $m $i"
			trace add variable $var write $cmd
			bind $m <Destroy> +[list trace remove variable $var write "$cmd"]
		} else {
			$m entryconfigure $i -label $Specs(title:$tb)
		}

		configureCheckEntry $m
		incr i
	}

	return $index
}


proc removeToolbarMenu {menu index {var {}}} {
	if {[llength $var] == 0} { set var [namespace current]::mc::Toolbar }
	set cmd "[namespace current]::SetMenuLabel $menu $index"
	trace remove variable $var write $cmd
	destroy $menu.__tb__Toolbar
}


proc realpath {toolbar} {
	variable Specs

	if {[winfo exists $toolbar.floating.frame]} { return $toolbar.floating.frame }
	return $toolbar
}


proc lookupChild {child} {
	set toolbar [winfo parent $child]
	if {![info exists Specs(child:$child:$toolbar.floating.frame)]} { return $child }
	return $Specs(child:$child:$toolbar.floating.frame)
}


proc lookupClone {toolbar w} {
	variable Specs

	if {![winfo exists $toolbar.floating]} { return "" }
	if {![info exists Specs(clone:$toolbar:$w)]} { return "" }
	return $Specs(clone:$toolbar:$w)
}


proc requestedHeight {parent} {
	set slaves [pack slaves $parent]
	set height 0

	foreach side {left right flat} {
		set tbf [Join $parent __tbf__$side]
		if {$tbf in $slaves && [winfo exists $tbf.frame.scrolled]} {
			incr height [winfo reqheight $tbf.frame.scrolled]
		}
	}

	return $height
}


proc totalHeight {parent} {
	set slaves [pack slaves $parent]
	set height 0

	foreach side {top bottom flat} {
		set tbf [Join $parent __tbf__$side]
		if {$tbf in $slaves && [winfo exists  $tbf.frame.scrolled]} {
			incr height [winfo reqheight $tbf.frame.scrolled]
		}
	}

	return $height
}


proc totalWidth {parent} {
	set slaves [pack slaves $parent]
	set width 0

	foreach side {left right} {
		set tbf [Join $parent __tbf__$side]
		if {$tbf in $slaves && [winfo exists $tbf.frame.scrolled]} {
			incr width [winfo reqwidth $tbf.frame.scrolled]
		}
	}

	return $width
}


proc toolbarDialogs {} {
	variable Specs

	set result {}

	foreach dlg [array names Specs options:*] {
		set dlg [string range $dlg 8 end]
		if {$dlg ni $result} { lappend result $dlg }
	}

	return $result
}


proc Add {toolbar widgetCommand args} {
	variable Counter
	variable Defaults
	variable HaveTooltips
	variable Specs

	if {$widgetCommand eq "separator"} { return [addSeparator $toolbar] }

	set w $toolbar.__tbw__[incr Counter]
	set variable ""
	set value ""
	set state normal
	set widgetType $widgetCommand
	set packOpts {}
	array set options { -takefocus 0 }

	array set Specs [list                                       \
		float:$w:$toolbar				1                             \
		padx:$w:$toolbar				1                             \
		onvalue:$w:$toolbar			1                             \
		offvalue:$w:$toolbar			0                             \
		tooltip:$w:$toolbar			{}                            \
		tooltipvar:$w:$toolbar		{}                            \
		arrowttip:$w:$toolbar		{}                            \
		arrowttipvar:$w:$toolbar	{}                            \
		default:$w:$toolbar			{}                            \
		small:$w:$toolbar				{}                            \
		medium:$w:$toolbar			{}                            \
		large:$w:$toolbar				{}                            \
		state:$w:$toolbar				normal                        \
		overrelief:$w:$toolbar		$Defaults(toolbar:overrelief) \
		relief:$w:$toolbar			$Defaults(toolbar:relief)     \
		menucmd:$w:$toolbar			{}                            \
	]

	foreach {arg val} $args {
		switch -- $arg {
			-after			{ lappend packOpts -after $val }
			-before			{ lappend packOpts -before $val }
			-image			{ set options(-image) [SetupIcons $toolbar $w $val] }
			-state			{ set state $val }
			-overrelief		{ set Specs(overrelief:$w:$toolbar) $val }
			-relief			{ set Specs(relief:$w:$toolbar) $val }
			-tooltip			{ if {[llength $val]} { set Specs(tooltip:$w:$toolbar) $val } }
			-tooltipvar		{ if {[llength $val]} { set Specs(tooltipvar:$w:$toolbar) $val } }
			-arrowttip		{ if {[llength $val]} { set Specs(arrowttip:$w:$toolbar) $val } }
			-arrowttipvar	{ if {[llength $val]} { set Specs(arrowttipvar:$w:$toolbar) $val } }
			-value			{ set value $val }
			-variable		{ set variable $val }
			-float			{ set Specs(float:$w:$toolbar) $val }
			-padx				{ set Specs(padx:$w:$toolbar) $val }
			-onvalue			{ set Specs(onvalue:$w:$toolbar) $val }
			-offvalue		{ set Specs(offvalue:$w:$toolbar) $val }
			-menucmd			{ set Specs(menucmd:$w:$toolbar) $val }
			default			{ set options($arg) $val }
		}
	}

	if {![info exists options(-background)] && [string match *button* $widgetCommand]} {
		set options(-background) [$toolbar cget -background]
	}
	if {![info exists options(-activebackground)]} {
		set options(-activebackground) $Defaults(toolbar:activebackground)
	}

	if {[string match *ttk::spinbox $widgetCommand]} { set options(-state) $state }
	if {$widgetCommand eq "spinbox"} { set options(-state) $state }
	if {$widgetCommand eq "checkbutton"} { set widgetCommand "button" }
	if {$widgetCommand ne "button" && $widgetCommand ne "dropdownbutton"} {
		unset options(-activebackground)
	}
	if {$widgetCommand eq "dropdownbutton"} { set options(-menucmd) $Specs(menucmd:$w:$toolbar) }
	if {$widgetCommand eq "frame"} { set options(-relief) $Specs(relief:$w:$toolbar) }
	if {![string match *ttk* $widgetCommand]} { set options(-relief) $Specs(relief:$w:$toolbar) }
	if {[string match *entry $widgetCommand]} { set Specs(takefocus:$toolbar) 1 }
	if {[string match *spinbox $widgetCommand]} { set variable {} }

	eval $widgetCommand $w [array get options]

	set class [winfo class $w]
	if {$class eq "Button" || $class eq "DropdownButton"} {
		set Specs(command:$w:$toolbar) [$w cget -command]
		set Specs(active:$w:$toolbar) [$w cget -activebackground]
		set Specs(button1:$w:$toolbar) ::tooltip::hide
		set Specs(entercmd:$w:$toolbar) {}
		if {[$w cget -state] eq "normal"} {
			$w configure -overrelief $Specs(overrelief:$w:$toolbar)
		}
		bind $w <ButtonPress-1> $Specs(button1:$w:$toolbar)
	}

	if {[llength $variable]} {
		if {$widgetType eq "checkbutton"} {
			set traceCmd "[namespace current]::Tracer4 $toolbar $w $variable"
			trace add variable $variable write $traceCmd
			bind $w <Destroy> "+trace remove variable $variable write {$traceCmd}"
			ConfigureCheckButton $toolbar $w $w $variable
			bind $w <ButtonRelease-1> +[namespace code [list CheckButtonPressed $toolbar $w $variable]]
		} else {
			if {![info exists $variable]} { set $variable $value }
			if {[llength $value]} {
				set Specs(value:$variable:$w:$toolbar) $value
			} else {
				set Specs(value:$variable:$w:$toolbar) [set $variable]
			}
			if {[info exists Specs(variable:$variable:$toolbar)]} {
				lappend Specs(variable:$variable:$toolbar) $w
			} elseif {[llength $value]} {
				set Specs(variable:$variable:$toolbar) $w
				if {$variable ni $Specs(variables:$toolbar)} {
					lappend Specs(variables:$toolbar) $variable
				}
			}
			if {[llength $value]} {
				set Specs(onvalue:$w:$toolbar) $value
				set bg [$w cget -background]
				set activebg [$w cget -activebackground]
				set traceCmd "[namespace current]::Tracer1 $toolbar $variable $bg $activebg"
				bind $w <Destroy> "+trace remove variable $variable write {$traceCmd}"
				trace add variable $variable write $traceCmd
				set v [namespace current]::Specs(state:$w:$toolbar)
				set traceCmd "[namespace current]::Tracer5 $toolbar $w $variable"
				trace add variable $v write $traceCmd
				bind $w <Destroy> "+trace remove variable $v write {$traceCmd}"

				if {[set $variable] eq $value} {
					$w configure -relief solid -background [$w cget -activebackground]
				}
			}
		}
		bind $w <Leave> [namespace code [list LeaveButton $toolbar $w $variable $value]]
	} elseif {[info exists options(-relief)]} {
		bind $w <Leave> [namespace code [list LeaveButton $toolbar $w]]
	}

	set variable [namespace current]::Specs(state:$w:$toolbar)
	set traceCmd "[namespace current]::Tracer2 $toolbar $w $variable"
	trace add variable $variable write $traceCmd
	bind $w <Destroy> "+trace remove variable $variable write {$traceCmd}"

	set variable [namespace current]::Specs(state:$toolbar)
	set traceCmd "[namespace current]::Tracer3 $toolbar $variable"
	trace add variable $variable write $traceCmd
	bind $w <Destroy> "+trace remove variable $variable write {$traceCmd}"

	if {$HaveTooltips} {
		SetupTooltips $w
	}
	if {$widgetCommand eq "button"} {
		bind $w <Enter> +[namespace code [list EnterButton $toolbar $w]]
		set Specs(entercmd:$w:$toolbar) [bind $w <Enter>]
	}
	if {$Specs(usehandle:$toolbar)} {
		bind $w <ButtonPress-3> [namespace code [list Menu $toolbar %X %Y]]
		if {[string match *frame $widgetCommand]} {
			bind $w <Configure> [namespace code [list BindMenuToChilds $toolbar $w]]
		}
	}

	PackWidget $toolbar $w {*}$packOpts
	if {[winfo exists $toolbar.floating.frame]} { CloneWidget $toolbar $w }

	set parent [winfo parent $toolbar]
	if {![info exists Specs(configure:$parent)]} {
		bind $parent <Map> [namespace code { Finish %W }]
		set Specs(configure:$parent) 1
	}

	if {$state ne "normal"} { set Specs(state:$w:$toolbar) $state }

	return $w
}


proc SetIconSize {args} {
	variable Specs
	variable Options

	foreach toolbar $Specs(toolbars) {
		set Specs(default:$toolbar) $Options(icons:size)
		ChangeIcons $toolbar
	}
}


proc SetupTooltips {w} {
	variable Specs

	set toolbar [winfo parent $w]

	if {![info exists Specs(tooltip-init:$w:$toolbar)]} {
		if {[llength $Specs(tooltip:$w:$toolbar)] || [llength $Specs(tooltipvar:$w:$toolbar)]} {
			::tooltip::init
			bind $w <Enter> +[namespace code { Tooltip show %W }]
			bind $w <Leave> +[namespace code { Tooltip hide %W }]
		}
	}

	if {[winfo class $w] eq "DropdownButton"} {
		$w configure -arrowttipvar $Specs(arrowttipvar:$w:$toolbar)
		$w configure -arrowttip $Specs(arrowttip:$w:$toolbar)
		$w configure -tooltipvar $Specs(tooltipvar:$w:$toolbar)
		$w configure -tooltip $Specs(tooltip:$w:$toolbar)
	}
}


proc EnterButton {toolbar w} {
	variable Specs

	if {$Specs(state:$w:$toolbar) eq "normal"} {
		set relief $Specs(overrelief:$w:$toolbar)
		$w configure -relief $relief -overrelief $relief

		if {[winfo exists $toolbar.floating]} {
			$Specs(child:$w:$toolbar.floating.frame) configure -relief $relief -overrelief $relief
		}
	}
}


proc LeaveButton {toolbar w {var {}} {value {}}} {
	variable Specs

	if {$Specs(state:$w:$toolbar) eq "normal"} {
		if {[llength $var] == 0 || [set $var] ne $value} {
			$w configure -relief $Specs(relief:$w:$toolbar)

			if {[winfo exists $toolbar.floating]} {
				$Specs(child:$w:$toolbar.floating.frame) configure -relief $Specs(relief:$w:$toolbar)
			}
		}
	}
}


proc SetMenuLabel {m index var {unused {}} {unused {}}} {
	$m entryconfigure $index -label [set $var]
}


proc BindMenuToChilds {toolbar w} {
	foreach child [winfo children $w] {
		bind $child <ButtonPress-3> [namespace code [list Menu $toolbar %X %Y]]
	}
	bind $w <Configure> {#}
}


proc Cleanup {toolbar} {
	variable Specs

	set parent [winfo parent $toolbar]

	if {$Specs(hide:$toolbar)} {
		set index [lsearch -exact $Specs(toolbars:$parent) $toolbar]
		set Specs(toolbars:$parent) [lreplace $Specs(toolbars:$parent) $index $index]
		if {[llength $Specs(toolbars:$parent)] == 0} {
			unset -nocomplain Specs(toolbars:$parent)
			unset -nocomplain Specs(configure:$parent)
		}
	}

	set i [lsearch -exact $Specs(count:$parent) $toolbar]
	set Specs(count:$parent) [lreplace $Specs(count:$parent) $i $i]
	if {[llength $Specs(count:$parent)] == 0} {
		set keepoptions $Specs(keepoptions:$toolbar)
		if {[info exists Specs(idlist:$parent)]} {
			set idlist $Specs(idlist:$parent)
		}
		if {$keepoptions} { set options [getOptions $parent] }
		foreach tb $Specs(remember:$parent) { array unset Specs *:$tb }
		array unset Specs *:$parent
		if {$keepoptions} {
			set Specs(options:$parent) $options
			if {[info exists idlist]} {
				set Specs(idlist:$parent) $idlist
			}
		}
	}

	set i [lsearch -exact $Specs(toolbars) $toolbar]
	set Specs(toolbars) [lreplace $Specs(toolbars) $i $i]
}


proc PackWidget {toolbar w args} {
	variable Specs

	if {$Specs(orientation:$toolbar) eq "horz"} {
		set side left; set fill y; set width -width
	} else {
		set side top; set fill x; set width -height
	}

	if {[string match *.floating.frame $toolbar]} {
		set tb [string range $toolbar 0 end-15]
	} else {
		set tb $toolbar
	}

	lappend options -side $side
	set cls [winfo class $w]

	if {$cls eq "ToolbarSeparator"} {
		set pady 3; set padx 3
		$w configure $width 3
		lappend options -fill $fill
	} elseif {$Specs(padx:$w:$toolbar)} {
		set pady 1; set padx $Specs(padx:$w:$toolbar)
	} elseif {[string match T* $cls]} {
		set pady 1; set padx 3
	} else {
		set pady 1; set padx 0
	}

	pack $w -in $toolbar.widgets -pady $pady -padx $padx {*}$options {*}$args
}


proc PackToolbarFrame {tbf side} {
	variable Specs
	variable Defaults

	set parent [winfo parent $tbf]
	set slaves [pack slaves $parent]
	set before {}
	if {[info exists Specs(frame:order:$parent)]} {
		set order $Specs(frame:order:$parent)
		set i [lsearch -exact $order $side]
		if {$i >= 0} {
			for {set k 0} {$k < $i} {incr k} {
				lappend before "$parent.__tbf__[lindex $order $k]"
			}
		}
	}
	set index 0
	set firstSlave [lindex $slaves $index]
	if {[string match *__tbf__flat $firstSlave]} {
		set firstSlave [lindex $slaves [incr index]]
	}
	while {	[llength $firstSlave]
			&& (	[string match $Defaults(dialog:class) [winfo class $firstSlave]]
				|| $firstSlave in $before)} {
		set firstSlave [lindex $slaves [incr index]]
	}
	set fill [expr {$Specs(orientation:$tbf) eq "horz" ? "x" : "y"}]
	if {[llength $firstSlave]} {
		pack $tbf -before $firstSlave -side $side -fill $fill
		set slaves [linsert $slaves $index $tbf]
	} else {
		pack $tbf -side $side -fill $fill
		lappend slaves $tbf
	}
	if {![info exists Specs(frame:order:$parent)]} {
		set Specs(frame:order:$parent) $side
	} elseif {$side ni $Specs(frame:order:$parent)} {
		set Specs(frame:order:$parent) {}
		foreach slave $slaves {
			if {[winfo class $slave] eq "ToolbarFrame"} {
				if {![string match *__tbf__flat $slave]} {
					lappend Specs(frame:order:$parent) [lindex [split $slave __] end]
				}
			}
		}
	}
}


proc PackToolbar {toolbar {before {}} {alignment {}}} {
	variable Specs
	variable Defaults

	if {!$Specs(enabled:$toolbar)} { return }
	set parent [winfo parent $toolbar]
	if {![info exists Specs(side:$toolbar)]} { return }
	set tbf [Join $parent __tbf__$Specs(side:$toolbar)]

	if {![winfo exists $tbf]} {
		set Specs(orientation:$tbf) $Specs(orientation:$toolbar)
		set Specs(side:$tbf) $Specs(side:$toolbar)
		set Specs(offset:$tbf) 0
		set Specs(pos:$tbf) 0
		set Specs(after:$tbf) {}
		tk::frame $tbf -class ToolbarFrame -borderwidth 0 -takefocus 0
		tk::frame $tbf.frame -borderwidth 0 -takefocus 0
		tk::frame $tbf.frame.scrolled -borderwidth 1 -relief raised -takefocus 0
		grid $tbf.frame -row 1 -column 1 -sticky ewns
		if {$Specs(orientation:$toolbar) eq "horz"} {
			grid columnconfigure $tbf {1} -weight 1
		} else {
			grid rowconfigure $tbf {1} -weight 1
		}
		place $tbf.frame.scrolled -x 0 -y 0
		bind $tbf <Configure> [namespace code [list Resize $tbf]]
		bind $tbf.frame.scrolled <Configure> [namespace code [list Resize $tbf]]
#		bind $tbf <Destroy> [list catch [list array unset [namespace current]::Specs *:$tbf]]
		if {$Specs(usehandle:$toolbar)} {
			bind $tbf.frame.scrolled <ButtonPress-3> [namespace code [list ToolbarMenu $tbf]]
		}
		if {![info exists Specs(childs:$tbf)]} { set Specs(childs:$tbf) {} }
		if {![info exists Specs(alignment:$tbf)]} {
			if {$alignment eq ""} { set alignment $Defaults(toolbarframe:alignment) }
			set Specs(alignment:$tbf) $alignment
		}
	} 
	
	if {[llength [pack slaves $tbf.frame.scrolled]] == 0} {
		PackToolbarFrame $tbf $Specs(side:$toolbar)
	} elseif {$Defaults(toolbarframe:iconsize)} {
		set Specs(iconsize:$toolbar) $Specs(iconsize:[lindex [pack slaves $tbf.frame.scrolled] 0])
	}

	set nextSlave ""
	if {[llength $before] == 0} {
		set slaves [pack slaves $tbf.frame.scrolled]
		set childs $Specs(childs:$tbf)
		set index [lsearch -exact $childs $toolbar]

		while {$nextSlave eq "" && $index >= 0 && $index < [llength $childs]} {
			if {[lsearch -exact $slaves [lindex $childs $index]] == -1} {
				incr index
			} else {
				set nextSlave [lindex $childs $index]
			}
		}
	} elseif {$before eq "last"} {
		set before {}
	} else {
		set nextSlave $before
	}

	if {$Defaults(toolbarframe:forget) && [info exists Specs(frame:$toolbar)]} {
		set index [lsearch -exact $Specs(childs:$Specs(frame:$toolbar)) $toolbar]
		set Specs(childs:$Specs(frame:$toolbar)) \
			[lreplace $Specs(childs:$Specs(frame:$toolbar)) $index $index]
	}

	set index [lsearch -exact $Specs(childs:$tbf) $toolbar]
	if {[llength $before]} {
		if {$index >= 0} { set Specs(childs:$tbf) [lreplace $Specs(childs:$tbf) $index $index] }
		set index [lsearch -exact $Specs(childs:$tbf) $before]
		set Specs(childs:$tbf) [linsert $Specs(childs:$tbf) $index $toolbar]
	} elseif {$index == -1} {
		lappend Specs(childs:$tbf) $toolbar
	} elseif {[llength $nextSlave] == 0} {
		set i -1
		foreach child [pack slaves $tbf.frame.scrolled] {
			set i [max $i [lsearch -exact $Specs(childs:$tbf) $child]]
		}
		if {$i > $index} {
			set Specs(childs:$tbf) [lreplace $Specs(childs:$tbf) $index $index]
			set Specs(childs:$tbf) [linsert $Specs(childs:$tbf) [expr {$i + 1}] $toolbar]
		}
	}

	if {[llength $nextSlave]} { lappend options -before $nextSlave }

#	if {$Specs(alignment:$tbf) eq "right" && $Specs(justify:$toolbar) eq "right"} {
#		set justify left
#	} else {
#		set justify $Specs(justify:$toolbar)
#	}
	set justify $Specs(justify:$toolbar)
	if {$Specs(orientation:$tbf) eq "horz"} {
		lappend options -side $justify -padx 0 -pady 1 -fill y -ipady $Defaults(toolbarframe:padding)
	} else {
		lappend options -side $justify -padx 1 -pady 0 -fill x -ipadx $Defaults(toolbarframe:padding)
	}

	set Specs(frame:$toolbar) $tbf
	set Specs(packed:$toolbar) 1

	pack $toolbar -in $tbf.frame.scrolled {*}$options
	raise $toolbar
	RaiseArrows $toolbar
	DoAlignment $tbf
	ReplaceIcons $toolbar
}


proc Resize {tbf} {
	variable Specs

	if {![winfo exists $tbf]} { return }

	if {$Specs(orientation:$tbf) eq "horz"} {
		if {[winfo width $tbf] == 1 || [winfo reqwidth $tbf.frame.scrolled] == 1} { return }
		$tbf.frame configure -height [winfo reqheight $tbf.frame.scrolled]
		PlaceToolbarFrame $tbf r 0
	} else {
		if {[winfo height $tbf] == 1 || [winfo reqheight $tbf.frame.scrolled] == 1} { return }
		$tbf.frame configure -width [winfo reqwidth $tbf.frame.scrolled]
		PlaceToolbarFrame $tbf b 0
	}
}


proc PlaceToolbarFrame {tbf dir incr} {
	variable Specs

	set parent [winfo parent $tbf]
	set side $Specs(side:$tbf)
	after cancel $Specs(after:$tbf)

	switch $dir {
		l - r {
			set offset [min 0 [expr {$Specs(offset:$tbf) - $incr*max(5, (2*[winfo width $tbf.frame])/3)}]]
			set rheight [winfo reqheight $tbf.frame.scrolled]
			set rwidth [winfo reqwidth $tbf.frame.scrolled]
			set width [winfo width $tbf]

			if {$offset != 0 && $incr != 0} {
				if {$incr < 0} {
					set x [expr {-$rwidth}]
					foreach w [lreverse [pack slaves $tbf.frame.scrolled]] {
						set x1 [expr {$x + [winfo width $w]}]
						if {$x1 > $Specs(offset:$tbf)} { break }
						set x $x1
					}
					if {$offset > $x && $x > $Specs(offset:$tbf)} { set offset $x }
				} else {
					set x 0
					foreach w [pack slaves $tbf.frame.scrolled] {
						set x1 [expr {$x - [winfo width $w]}]
						if {$x1 < $Specs(offset:$tbf)} { break }
						set x $x1
					}
					if {$offset < $x && $x < $Specs(offset:$tbf)} { set offset $x }
				}
			}

			set rarrow $parent.__tba__${side}_r
			set larrow $parent.__tba__${side}_l

			if {$width < $rwidth} {
				MakeArrow $tbf r +1
				MakeArrow $tbf l -1
				incr width [expr {-([winfo reqwidth $larrow] + [winfo reqwidth $rarrow])}]
				set offset [max $offset [expr {$width - $rwidth}]]
				if {$rarrow ni [grid slaves $tbf]} {
					grid $larrow -in $tbf -row 1 -column 0 -sticky ns
					grid $rarrow -in $tbf -row 1 -column 2 -sticky ns
				}
			} else {
				if {$rarrow in [grid slaves $tbf]} {
					grid forget $rarrow
					grid forget $larrow
					# we need this trick to force a Configure event
					$tbf configure -width [expr {$width - 1}]
					after idle [list $tbf configure -width $width]
				}
				set offset 0
			}

			if {[winfo exists $rarrow]} {
				if {$width < $rwidth + $offset} { set state normal } else { set state disabled }
				if {$state ne [$rarrow cget -state]} { $rarrow configure -state $state }
				if {$offset < 0} { set state normal } else { set state disabled }
				if {$state ne [$larrow cget -state]} { $larrow configure -state $state }
			}

			set Specs(offset:$tbf) $offset
			PlaceHorzFrame $tbf $rheight [max $width $rwidth]

			if {[winfo exists $rarrow]} {
				raise $rarrow
				raise $larrow
			}
		}

		t - b {
			set offset [min 0 [expr {$Specs(offset:$tbf) - $incr*max(5, [winfo height $tbf.frame]/2)}]]
			set rwidth [winfo reqwidth $tbf.frame.scrolled]
			set rheight [winfo reqheight $tbf.frame.scrolled]
			set height [winfo height $tbf]

			if {$offset != 0 && $incr != 0} {
				if {$incr < 0} {
					set y [expr {-$rheight}]
					foreach w [lreverse [pack slaves $tbf.frame.scrolled]] {
						set y1 [expr {$y + [winfo height $w]}]
						if {$y1 > $Specs(offset:$tbf)} { break }
						set y $y1
					}
					if {$offset > $y && $y > $Specs(offset:$tbf)} { set offset $y }
				} else {
					set y 0
					foreach w [pack slaves $tbf.frame.scrolled] {
						set y1 [expr {$y - [winfo height $w]}]
						if {$y1 < $Specs(offset:$tbf)} { break }
						set y $y1
					}
					if {$offset < $y && $y < $Specs(offset:$tbf)} { set offset $y }
				}
			}

			set tarrow $parent.__tba__${side}_t
			set barrow $parent.__tba__${side}_b

			if {$height < $rheight} {
				MakeArrow $tbf b +1
				MakeArrow $tbf t -1
				incr height [expr {-([winfo reqheight $tarrow] + [winfo reqheight $barrow])}]
				set offset [max $offset [expr {$height - $rheight}]]
				if {$barrow ni [grid slaves $tbf]} {
					grid $tarrow -in $tbf -row 0 -column 1 -sticky ew
					grid $barrow -in $tbf -row 2 -column 1 -sticky ew
				}
			} else {
				if {$tarrow in [grid slaves $tbf]} {
					grid forget $tarrow
					grid forget $barrow
					# we need this trick to force a Configure event
					$tbf configure -height [expr {$height - 1}]
					after idle [list $tbf configure -height $height]
				}
				set offset 0
			}

			if {[winfo exists $tarrow]} {
				if {$height < $rheight + $offset} { set state normal } else { set state disabled }
				if {$state ne [$barrow cget -state]} { $barrow configure -state $state }
				if {$offset < 0} { set state normal } else { set state disabled }
				if {$state ne [$tarrow cget -state]} { $tarrow configure -state $state }
			}

			set Specs(offset:$tbf) $offset
			PlaceVertFrame $tbf [max $height $rheight] $rwidth

			if {[winfo exists $barrow]} {
				raise $barrow
				raise $tarrow
			}
		}
	}
}


proc PlaceHorzFrame {tbf height width} {
	variable Specs

	if {![winfo exists $tbf]} { return }

	set x $Specs(pos:$tbf)
	set offs $Specs(offset:$tbf)
	if {$x < $offs} { set dir +1 } elseif {$x > $offs} { set dir -1 } else { set dir 0 }
	incr x $dir
	place $tbf.frame.scrolled -x $x -y 0 -height $height -width $width
	set Specs(pos:$tbf) $x

	if {$x != $offs} {
		set Specs(after:$tbf) [after 20 [namespace code [list PlaceHorzFrame $tbf $height $width]]]
	}
}


proc PlaceVertFrame {tbf height width} {
	variable Specs

	if {![winfo exists $tbf]} { return }

	set y $Specs(pos:$tbf)
	set offs $Specs(offset:$tbf)
	if {$y < $offs} { set dir +1 } elseif {$y > $offs} { set dir -1 } else { set dir 0 }
	incr y $dir
	place $tbf.frame.scrolled -x 0 -y $y -height $height -width $width
	set Specs(pos:$tbf) $y

	if {$y != $offs} {
		set Specs(after:$tbf) [after 20 [namespace code [list PlaceVertFrame $tbf $height $width]]]
	}
}


proc MakeArrow {tbf dir incr} {
	variable Specs

	set parent [winfo parent $tbf]
	set arrow $parent.__tba__$Specs(side:$tbf)_${dir}
	if {[winfo exists $arrow]} { return }
	ttk::button $arrow \
		-padding {0 0 0 0} \
		-takefocus 0 \
		-image [makeStateSpecificIcons $icon::8x16::arrow($dir)] \
		-command [namespace code [list PlaceToolbarFrame $tbf $dir $incr]] \
		;
	bind $arrow <ButtonPress-1> [namespace code [list InvokeRepeat $arrow]]
}


proc InvokeRepeat {w} {
	variable Specs

	after cancel $Specs(repeat)
	set Specs(repeat) [after 300 [namespace code [list Repeat $w]]]
}


proc Repeat {w} {
	variable Specs

	if {![winfo exists $w]} { return }
	$w instate disabled { $w state !pressed } ;# looks like a Tk bug
	$w instate !pressed { return }
	set Specs(repeat) [after 100 [namespace code [list Repeat $w]]]
	eval [$w cget -command]
}


proc Finish {parent} {
	variable Specs

	if {![info exists Specs(configure:$parent)]} { return }

	bind $parent <Map> {}
	unset Specs(configure:$parent)

	foreach toolbar $Specs(count:$parent) {
		if {$Specs(enabled:$toolbar) && $Specs(finish:$toolbar)} {
			lassign $Specs(position:$toolbar) fx fy
			if {[llength $fy] == 0} { set fx 500; set fy 500 }
			set tl [winfo toplevel $parent]
			UndockToolbar $toolbar [expr {[winfo rootx $tl] + $fx}] [expr {[winfo rooty $tl] + $fy}]
		}
	}
}


proc DoAlignment {tbf} {
	variable Specs

	set slaves [pack slaves $tbf.frame.scrolled]
	if {[llength $slaves] == 0} { return }

	switch $Specs(orientation:$tbf) {
		horz { lassign {w e} w e }
		vert { lassign {n s} w e }
	}

	switch $Specs(alignment:$tbf) {
		left {
			pack configure {*}$slaves -expand 0 -anchor $w
		}
		right {
			pack configure {*}$slaves -expand 0 -anchor $e
			set i 0
			while {$i < [llength $slaves] && $Specs(justify:[lindex $slaves $i]) eq "right"} {
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
				pack configure {*}$slaves -expand 0 -anchor $w
				set i 0
				while {$i < [llength $slaves] && $Specs(justify:[lindex $slaves $i]) eq "right"} {
					incr i
				}
				if {$i < [llength $slaves]} {
					pack configure [lindex $slaves $i] -expand 1 -anchor $e
				}
				set i [expr {[llength $slaves] - 1}]
				while {$i >= 0 && $Specs(justify:[lindex $slaves $i]) ne "right"} {
					incr i -1
				}
				if {$i < 0} { set i end }
				pack configure [lindex $slaves $i] -expand 1 -anchor $w
			}
		}
	}
}


proc Forget {toolbar} {
	variable Specs

	if {!$Specs(packed:$toolbar)} { return }
	pack forget $toolbar
	set tbf $Specs(frame:$toolbar)
	after idle [namespace code [list Resize $tbf]]
	if {[llength [pack slaves $tbf.frame.scrolled]] == 0} {
		pack forget $tbf
		set parent [winfo parent $tbf]
		set side [lindex [split $tbf __] end]
		set i [lsearch -exact $Specs(frame:order:$parent) $side]
		if {$i >= 0} {
			set Specs(frame:order:$parent) [lreplace $Specs(frame:order:$parent) $i $i]
		}
	} else {
		DoAlignment $tbf
	}
	set Specs(packed:$toolbar) 0
}


proc PackFlatHandle {toolbar} {
	variable Specs
	variable Counter
	variable Defaults

	set parent [winfo parent $toolbar]
	set flattoolbar [Join $parent __tbf__flat]

	if {![winfo exists $flattoolbar]} {
		tk::frame $flattoolbar -class ToolbarHandle -borderwidth 2 -relief $Defaults(flathandle:relief)
		set firstSlave [lindex [pack slaves $parent] 0]
		if {[llength $firstSlave]} {
			pack $flattoolbar -side top -fill x -before $firstSlave
		} else {
			pack $flattoolbar -side top -fill x
		}
	}

	set handle $flattoolbar.handle[incr Counter]
	set Specs(flathandle:$toolbar) $handle
	set Specs(tooltip:$handle:$flattoolbar) $Specs(tooltip:$toolbar.handle:$toolbar)
	set Specs(tooltipvar:$handle:$flattoolbar) $Specs(tooltipvar:$toolbar.handle:$toolbar)
	set Specs(orientation:$flattoolbar) vert

	CreateHandle $toolbar $handle $Defaults(flathandle:width)
	pack $handle -side left -padx 5
	bind $handle <Destroy> +[list array unset [namespace current]::Specs *:$handle:$flattoolbar]
}


proc CheckIfOn {toolbar w var} {
	variable Specs

	set x [set $var]
	set y $Specs(onvalue:$w:$toolbar)

	if {[string is boolean -strict $x]} { set x [expr {!!$x}] }
	if {[string is boolean -strict $y]} { set y [expr {!!$y}] }

	return [expr {$x == $y}]
}


proc Tracer1 {toolbar var bg activebg args} {
	variable Specs

	ConfigureWidget $toolbar $var $bg $activebg
	if {[winfo exists $toolbar.floating]} {
		ConfigureWidget $toolbar.floating.frame $var $bg $activebg
	}
}


proc Tracer2 {toolbar w args} {
	variable Specs

	set state $Specs(state:$w:$toolbar)
	SetState $toolbar $w $w $state

	if {[winfo exists $toolbar.floating]} {
		SetState $toolbar $w $Specs(child:$w:$toolbar.floating.frame) $state
	}
}


proc Tracer3 {toolbar args} {
	variable Specs

	if {$Specs(state:$toolbar) eq "hide"} {
		set Specs(hidden:$toolbar) 1
	} else {
		set Specs(hidden:$toolbar) 0
	}
}


proc Tracer4 {toolbar w var args} {
	variable Specs

	ConfigureCheckButton $toolbar $w $w $var

	if {[winfo exists $toolbar.floating]} {
		set v $Specs(child:$w:$toolbar.floating.frame)
		ConfigureCheckButton $toolbar $w $v $var
	} else {
		set v $w
	}

	if {$Specs(state:$w:$toolbar) eq "disabled"} { return }

	if {[winfo containing {*}[winfo pointerxy .]] eq $v} {
		EnterButton $toolbar $w
		if {[CheckIfOn $toolbar $w $var]} {
			after idle [list $w configure -relief sunken -overrelief sunken]
		}
	}
}


proc Tracer5 {toolbar w var args} {
	variable Specs
	variable Defaults

	if {[winfo exists $toolbar.floating]} {
		set v $Specs(child:$w:$toolbar.floating.frame)
	} else {
		set v $w
	}

	if {$Specs(state:$w:$toolbar) eq "disabled" || ![CheckIfOn $toolbar $w $var]} {
		$w configure -background $Specs(frame:background)
	} else {
		$w configure -relief solid -overrelief solid -background $Defaults(button:selectcolor)
	}

	if {[winfo containing {*}[winfo pointerxy .]] eq $v} {
		after idle [namespace code [list EnterButton $toolbar $w]]
	}
}


proc CheckButtonPressed {toolbar w var} {
	variable Specs

	if {$Specs(state:$w:$toolbar) eq "disabled"} { return }

	if {[CheckIfOn $toolbar $w $var]} {
		set $var $Specs(offvalue:$w:$toolbar)
	} else {
		set $var $Specs(onvalue:$w:$toolbar)
	}
}


proc ConfigureCheckButton {toolbar v w var args} {
	variable Specs
	variable Defaults

	if {[CheckIfOn $toolbar $v $var]} {
		set relief sunken
		set overrelief sunken
		set color $Defaults(button:selectcolor)
	} else {
		set relief flat
		set overrelief solid
		set color $Specs(frame:background)
	}

	set Specs(relief:$v:$toolbar) $relief
	set Specs(overrelief:$v:$toolbar) $overrelief
	$w configure -relief $relief -overrelief $overrelief -background $color
}


proc ConfigureWidget {toolbar var bg activebg} {
	variable Specs

	set value [set $var]

	foreach w $Specs(variable:$var:$toolbar) {
		if {[info exists Specs(value:$var:$w:$toolbar)]} {
			if {![info exists Specs(state:$w:$toolbar)] || $Specs(state:$w:$toolbar) eq "normal"} {
				if {$Specs(value:$var:$w:$toolbar) eq $value} {
					$w configure -background $activebg -relief solid
				} else {
					$w configure -background $bg -relief flat
				}
			}
		}
	}
}


proc SetState {toolbar v w state} {
	variable Specs

	switch [winfo class $w] {
		Button - DropdownButton {
			if {$state eq "normal"} {
				set overrelief $Specs(overrelief:$v:$toolbar)
				set relief $Specs(relief:$v:$toolbar)
				set activebackground $Specs(active:$v:$toolbar)
				set command $Specs(command:$v:$toolbar)
				bind $w <ButtonPress-1> $Specs(button1:$v:$toolbar)
				bind $w <Enter> $Specs(entercmd:$v:$toolbar)
			} else {
				set overrelief flat
				set relief flat
				set activebackground [$w cget -background]
				set command {}
				bind $w <ButtonPress-1> { break }
				bind $w <Enter> { break }
			}
			set iconsize $Specs(iconsize:$toolbar)
			if {$iconsize eq "default"} { set iconsize $Specs(default:$toolbar) }
			set icon $Specs($iconsize-$state:$v:$toolbar)
			$w configure \
				-image $icon \
				-overrelief $overrelief \
				-relief $relief \
				-activebackground $activebackground \
				-command $command \
				;
			if {[winfo class $w] eq "DropdownButton"} {
				$w configure -arrowstate $state
			}
		}

		default {
			$w configure -state $state
		}
	}
}


proc SetupIcons {toolbar w icons} {
	variable Specs
	variable Defaults
	variable iconSizes

	set i -1
	foreach size $iconSizes {
		set Specs($size:$w:$toolbar) [lindex $icons [incr i]]
	}

	if {[tk windowingsystem] eq "x11" && $Defaults(icons:x11Hack)} {
		variable Images

		# we need a hack to center the image inside a button:
		# we make a slightly bigger icon that has the required padding
		# (see Tk Toolkit - Bug #2433781; it seems that hobbs does not
		# like to fix the problem.)

		foreach size $iconSizes {
			set imageList {}
			set images $Specs($size:$w:$toolbar)
			for {set i 0} {$i < [llength $images]} {incr i 1} {
				set img [lindex $images $i]
				if {![info exists Images($img)]} {
					set wd [image width $img]
					set ht [image height $img]
					set ic [image create photo -width [expr {$wd + 2}] -height [expr {$ht + 2}]]
					$ic blank	;# ensure alpha channel
					$ic copy $img -to 0 0 $wd $ht
					set Images($img) $ic
				}
				lappend imageList $Images($img)
				if {[incr i] < [llength $images]} { lappend imageList [lindex $images $i] }
			}
			set Specs($size:$w:$toolbar) $imageList
		}
	}

	set count 0
	foreach size $iconSizes {
		set Specs($size-disabled:$w:$toolbar) {}
		set Specs($size-normal:$w:$toolbar) {}

		if {[llength $Specs($size:$w:$toolbar)]} {
			incr count
			set images $Specs($size:$w:$toolbar)
			set Specs($size:$w:$toolbar) [lindex $images 0]
			set Specs($size-normal:$w:$toolbar) [lindex $images 0]
			if {[llength $images] >= 3} { set i 2 } else { set i 0 }
			set Specs($size-disabled:$w:$toolbar) [lindex $images $i]
		}
	}

	if {$count > 1} {
		set Specs(icon:$toolbar) 1
		foreach size $iconSizes {
			if {[llength $Specs($size:$w:$toolbar)]} { set Specs($size:$toolbar) 1 }
		}
	}

	set size $Specs(iconsize:$toolbar)
	if {$size eq "default"} { set size $Specs(default:$toolbar) }

	return $Specs($size:$w:$toolbar)
}


proc ChangeIcons {toolbar} {
	variable Specs
	variable Defaults

	set iconsize $Specs(iconsize:$toolbar)

	if {[winfo exists $toolbar.floating] || !$Defaults(toolbarframe:iconsize)} {
		ReplaceIcons $toolbar
	} else {
		foreach toolbar [pack slaves $Specs(frame:$toolbar)] {
			set Specs(iconsize:$toolbar) $iconsize
			ReplaceIcons $toolbar
		}
	}
}


proc ReplaceIcons {toolbar} {
	variable Specs

	set resize 0
	set size $Specs(iconsize:$toolbar)
	if {$size eq "default"} { set size $Specs(default:$toolbar) }

	foreach child [pack slaves $toolbar.widgets] {
		if {[info exists Specs($size:$child:$toolbar)] && [llength $Specs($size:$child:$toolbar)]} {
			set state $Specs(state:$child:$toolbar)
			if {[$child cget -image] ne $Specs($size-$state:$child:$toolbar)} {
				$child configure -image $Specs($size-$state:$child:$toolbar)
				set resize 1
			}
		}
	}

	if {$resize} { Resize $Specs(frame:$toolbar) }

	set win $toolbar.floating.frame
	if [winfo exists $win] {
		foreach child [pack slaves $win.widgets] {
			if {[info exists Specs($size:$child:$win)] && [llength $Specs($size:$child:$win)]} {
				$child configure -image $Specs($size:$child:$win)
			}
		}
	}

	if {$resize && $Specs(enabled:$toolbar) && $Specs(state:$toolbar) eq "show"} {
		event generate $toolbar <<ToolbarIcon>> -data $size
	}
}


proc CreateHandle {toolbar handle {size 0}} {
	variable Specs
	variable Defaults
	variable HaveTooltips

	tk::frame $handle -class ToolbarHandle -borderwidth 0

	if {$Specs(orientation:[winfo parent $handle]) eq "horz"} {
		set decor [tk::canvas $handle.c -width $Defaults(handle:size) -height $size -borderwidth 0]
		pack $decor -fill y -side left -expand yes
	} else {
		set decor [tk::canvas $handle.c -width $size -height $Defaults(handle:size) -borderwidth 0]
		pack $decor -fill x -side top -expand yes
	}

	if {$HaveTooltips} {
		bind $handle <Enter> [namespace code { Tooltip show %W }]
		bind $handle <Leave> [namespace code { Tooltip hide %W }]
	}
	bind $decor <Configure> [namespace code [list ConfigureHandle $handle %w %h]]

	if {$size == 0} {
		foreach w [list $handle $decor] {
			bind $w <ButtonPress-1>		[namespace code [list Grab $toolbar %X %Y 1]]
			bind $w <ButtonPress-2>		[namespace code [list ChangeState $toolbar flat]]
			bind $w <ButtonPress-3>		[namespace code [list Menu $toolbar %X %Y]]
			bind $w <ButtonRelease-1>	[namespace code [list Ungrab $toolbar %X %Y]]
			bind $w <B1-Motion>			[namespace code [list Drag $toolbar %X %Y]]
		}
	} else {
		foreach w [list $handle $decor] {
			bind $w <ButtonPress-1> [namespace code [list show $toolbar]]
			bind $w <ButtonPress-2> [namespace code [list show $toolbar]]
		}
	}
}


proc Show {toolbar alignment} {
	variable Specs

	if {[winfo exists $toolbar.floating]} { return }

	if {$Specs(enabled:$toolbar)} {
		RemoveFlatHandle $toolbar
		PackToolbar $toolbar "" $alignment
	}
	set Specs(state:$toolbar) "show"
#	set Specs(position:$toolbar) {}

	if {$Specs(enabled:$toolbar)} {
		event generate $toolbar <<ToolbarShow>>
	}
}


proc RemoveFlatHandle {toolbar} {
	variable Specs

	if {![info exists Specs(flathandle:$toolbar)]} { return }
	set flattoolbar [winfo parent $Specs(flathandle:$toolbar)]
	destroy $Specs(flathandle:$toolbar)
	unset Specs(flathandle:$toolbar)
	if {[llength [pack slaves $flattoolbar]] == 0} { destroy $flattoolbar }
}


proc Grab {toolbar x y time} {
	variable Specs
	variable Defaults

	# in rare cases we do not receive a ButtonRelease event. tk bug?
	if {[winfo exists $toolbar.__t__]} {
		$toolbar configure -cursor {}
		foreach dir {l r t b} { destroy $toolbar.__${dir}__ }
		if {![info exists Specs(drag:after)]} { array unset Specs drag:* }
		::tooltip::tooltip on
	}

	if {[llength $Specs(allow:$toolbar)] <= 1} { return }

	if {$Defaults(handle:doubleclick) && $Specs(float:$toolbar)} {
		if {![winfo exists $toolbar]} { return }

		if {$time == 1} {
			if {[info exists Specs(drag:after)]} {
				after cancel $Specs(drag:after)
				unset Specs(drag:after)
				unset Specs(drag:click)
				UndockToolbar $toolbar [winfo rootx $toolbar] [winfo rooty $toolbar]
			} else {
				# in rare cases we do not receive a ButtonRelease-1 event. tk bug?
				set Specs(drag:after) [after 500 [namespace code [list Grab $toolbar $x $y 2]]]
				set Specs(drag:click) 1
			}
			return
		} elseif {$Specs(drag:click) == 2} {
			unset Specs(drag:after)
			unset Specs(drag:click)
			return
		}

		unset Specs(drag:after)
		unset Specs(drag:click)
	}

	::tooltip::tooltip off
	$toolbar configure -cursor hand2

	set Specs(drag:directions) {}
	foreach dir $Specs(allow:$toolbar) { lappend Specs(drag:directions) [string range $dir 0 0] }

	set parent [winfo parent $Specs(frame:$toolbar)]
	set slaves [pack slaves $parent]
	set decrH 0
	set decrW 0
	foreach slave $slaves {
		if {[string match $Defaults(dialog:class) [winfo class $slave]]} {
			if {[winfo x $slave] < [winfo width $parent]} {
				incr decrH [winfo height $slave]
			} else {
				incr decrW [winfo width $slave]
			}
		}
	}

	set h [Join $parent __tbf__flat]
	set t [Join $parent __tbf__top]
	set b [Join $parent __tbf__bottom]
	set l [Join $parent __tbf__left]
	set r [Join $parent __tbf__right]
	foreach dir {t b l r} {
		if {![IsUsed [set $dir]]} { set $dir "" }
	}
	set dx $Defaults(dialog:snapping:x)
	set dy $Defaults(dialog:snapping:y)
	set tw [expr {[winfo width $parent] - $decrW}]
	set th [expr {[winfo height $parent] - $decrH}]
	set tx0 [winfo rootx $parent]
	set ty0 [winfo rooty $parent]
	set tx1 [expr {$tx0 + $tw}]
	set ty1 [expr {$ty0 + $th}]

	if {[string length $l]} { set ix0 [expr {$tx0 + [winfo x $l] + [winfo width $l]}] }
	if {[string length $r]} { set ix1 [expr {$tx0 + [winfo x $r]}] }
	if {[string length $t]} { set iy0 [expr {$ty0 + [winfo y $t] + [winfo height $t]}] }
	if {[string length $b]} { set iy1 [expr {$ty0 + [winfo y $b]}] }

	if {[winfo exists $h]} { incr ty0 [winfo height $h] }

	if {![string length $l]} { set ix0 [expr {$tx0 + $dx}] }
	if {![string length $r]} { set ix1 [expr {$tx1 - $dx}] }
	if {![string length $t]} { set iy0 [expr {$ty0 + $dy}] }
	if {![string length $b]} { set iy1 [expr {$ty1 - $dy}] }

	set preferToverL [expr {[string length $t] && [winfo x $t] <= 1}]
	set preferBoverL [expr {[string length $b] && [winfo x $b] <= 1}]
	set preferToverR [expr {[string length $t] && [winfo x $t] + [winfo width $t] >= $tw - 1}]
	set preferBoverR [expr {[string length $b] && [winfo x $b] + [winfo width $b] >= $tw - 1}]

	if {"left" ni $Specs(allow:$toolbar)} {
		set preferToverL 1
		set preferBoverL 1
	}
	if {"right" ni $Specs(allow:$toolbar)} {
		set preferToverR 1
		set preferBoverR 1
	}
	if {"top" ni $Specs(allow:$toolbar)} {
		set preferToverL 0
		set preferToverR 0
	}
	if {"bottom" ni $Specs(allow:$toolbar)} {
		set preferBoverL 0
		set preferBoverR 0
	}

	incr tx0 [expr {-$dx/2}]
	incr tx1 [expr { $dx/2}]
	incr ty0 [expr {-$dy/2}]
	incr ty1 [expr { $dy/2}]

	set Specs(drag:l:x0) $tx0
	set Specs(drag:l:x1) $ix0
	set Specs(drag:l:y0) [expr {$preferToverL ? $iy0 : $ty0}]
	set Specs(drag:l:y1) [expr {$preferBoverL ? $iy1 : $ty1}]
	set Specs(drag:r:x0) $ix1
	set Specs(drag:r:x1) $tx1
	set Specs(drag:r:y0) [expr {$preferToverR ? $iy0 : $ty0}]
	set Specs(drag:r:y1) [expr {$preferBoverR ? $iy1 : $ty1}]
	set Specs(drag:t:x0) [expr {$preferToverL ? $tx0 : $ix0}]
	set Specs(drag:t:x1) [expr {$preferToverR ? $tx1 : $ix1}]
	set Specs(drag:t:y0) $ty0
	set Specs(drag:t:y1) $iy0
	set Specs(drag:b:x0) [expr {$preferBoverL ? $tx0 : $ix0}]
	set Specs(drag:b:x1) [expr {$preferBoverR ? $tx1 : $ix1}]
	set Specs(drag:b:y0) $iy1
	set Specs(drag:b:y1) $ty1
	set Specs(drag:mx)   [expr {$x - [winfo rootx $toolbar]}]
	set Specs(drag:my)   [expr {$y - [winfo rooty $toolbar]}]

	set sw [winfo width  $toolbar]
	set sh [winfo height $toolbar]

	if {$Specs(orientation:$toolbar) eq "vert"} {
		set Specs(drag:orientation) vert
		set Specs(drag:sw:vert) $sw
		set Specs(drag:sh:vert) $sh
		set Specs(drag:sw:horz) [expr {min($sh, max($dx, $tw - $dx))}]
		set Specs(drag:sh:horz) $sw
	} else {
		set Specs(drag:orientation) horz
		set Specs(drag:sw:horz) $sw
		set Specs(drag:sh:horz) $sh
		set Specs(drag:sw:vert) $sh
		set Specs(drag:sh:vert) [expr {min($sw, max($dy, $th - $dy))}]
	}

	set Specs(drag:color) $Defaults(drag:color:snapping)
	set options [list -background $Specs(drag:color) -borderwidth 0 -relief flat -highlightthickness 0]
	set top [winfo toplevel $toolbar]
	tk::toplevel $toolbar.__l__ -width 1 -height $sh {*}$options
	tk::toplevel $toolbar.__r__ -width 1 -height $sh {*}$options
	tk::toplevel $toolbar.__t__ -width $sw -height 1 {*}$options
	tk::toplevel $toolbar.__b__ -width $sw -height 1 {*}$options
	foreach dir {l r t b} {
		wm transient $toolbar.__${dir}__ $top
		wm overrideredirect $toolbar.__${dir}__ true
	}
	MoveFrame $toolbar $x $y
}


proc Ungrab {toolbar x y} {
	variable Specs

	$toolbar configure -cursor {}

	if {[winfo exists $toolbar.__t__]} {
		foreach dir {l r t b} { destroy $toolbar.__${dir}__ }
	}

	if {[info exists Specs(drag:after)]} {
		set Specs(drag:click) 2
	} elseif {[info exists Specs(drag:mx)]} {
		set region [FindRegion $toolbar $x $y]
		if {[llength $region]} {
			switch $region {
				l { set Specs(side:$toolbar) left }
				r { set Specs(side:$toolbar) right }
				t { set Specs(side:$toolbar) top }
				b { set Specs(side:$toolbar) bottom }
			}
			set nearest [FindNearest $toolbar $Specs(side:$toolbar) $x $y $region]
			if {[llength $nearest] == 0} { set nearest last }
			if {$nearest ne $toolbar} { Move $toolbar "" $nearest }
		} elseif {$Specs(float:$toolbar)} {
			UndockToolbar $toolbar [expr {$x - $Specs(drag:mx)}] [expr {$y - $Specs(drag:my)}]
		}
		array unset Specs drag:*
		::tooltip::tooltip on
	}
}


proc Drag {toolbar x y} {
	variable Specs
	if {[info exists Specs(drag:mx)]} { MoveFrame $toolbar $x $y }
}


proc MoveFrame {toolbar x y} {
	variable Specs
	variable Defaults

	set lrsize ""
	set tbsize ""
	set region [FindRegion $toolbar $x $y]

	if {[llength $region]} {
		set color $Defaults(drag:color:snapping)
		if {$region eq "l" || $region eq "r"} { set orientation vert } else { set orientation horz }
	} else {
		set color $Defaults(drag:color:floating)
		set orientation horz
	}

	if {$orientation ne $Specs(drag:orientation)} {
		set Specs(drag:orientation) $orientation
		set lrsize 1x$Specs(drag:sh:$orientation)
		set tbsize $Specs(drag:sw:$orientation)x1
	}

	if {$color ne $Specs(drag:color)} {
		foreach dir {l r t b} { $toolbar.__${dir}__ configure -background $color }
		set Specs(drag:color) $color
	}

	set x0 [expr {$x  - $Specs(drag:mx)}]
	set y0 [expr {$y  - $Specs(drag:my)}]
	set x1 [expr {$x0 + $Specs(drag:sw:$orientation)}]
	set y1 [expr {$y0 + $Specs(drag:sh:$orientation)}]

	wm geometry $toolbar.__l__ $lrsize+$x0+$y0
	wm geometry $toolbar.__t__ $tbsize+$x0+$y0
	wm geometry $toolbar.__r__ $lrsize+$x1+$y0
	wm geometry $toolbar.__b__ $tbsize+$x0+$y1
}


proc FindRegion {toolbar x y} {
	variable Specs

	foreach dir $Specs(drag:directions) {
		if {	$x >= $Specs(drag:$dir:x0) && $x <= $Specs(drag:$dir:x1)
			&& $y >= $Specs(drag:$dir:y0) && $y <= $Specs(drag:$dir:y1)} {
			return $dir
		}
	}
	return ""
}


proc FindNearest {toolbar dir x y region} {
	variable Specs

	set parent [winfo parent $Specs(frame:$toolbar)]
	set tbf [Join $parent __tbf__$dir]
	if {![winfo exists $tbf]} { return "" }
	set childs [pack slaves $tbf.frame.scrolled]
	if {[llength $childs] == 0} { return "" }
	set sx [winfo rootx $parent]
	set sy [winfo rooty $parent]

	if {$dir eq "left" || $dir eq "right"} {
		if {$y < [winfo rooty [lindex $childs 0]]} { return [lindex $childs 0] }
	} else {
		if {$x < [winfo rootx [lindex $childs 0]]} { return [lindex $childs 0] }
	}

	for {set i 0} {$i < [llength $childs]} {incr i} {
		scan [winfo geometry [lindex $childs $i]] "%dx%d+%d+%d" tw th tx ty
		incr tx $sx
		incr ty $sy

		if {$dir eq "left" || $dir eq "right"} {
			if {$y >= $ty} {
				if {$y <= [expr {$ty + $th/2}]} { return [lindex $childs $i] }
				if {$y <= [expr {$ty + $th  }]} { return [lindex $childs [expr {$i+1}]] }
			}
		} else {
			if {$x >= $tx} {
				if {$x <= [expr {$tx + $tw/2}]} { return [lindex $childs $i] }
				if {$x <= [expr {$tx + $tw  }]} { return [lindex $childs [expr {$i+1}]] }
			}
		}
	}

	return ""
}


proc ConfigureHandle {handle w h} {
	variable Specs
	variable Defaults

	if {$h <= 1 || $w <= 1} { return }

	set toolbar [winfo parent $handle]
	set canv $handle.c
	$canv delete rect

	if {$Specs(orientation:$toolbar) eq "horz"} {
		set n [expr {$h/3}]
		set y0 [expr {($h - 3*$n)/2}]
		set x0 0 ;#[expr {($w - 6)/2}]
		set xi $x0

		for {set i 0} {$i < $n} {incr i; incr y0 3} {
			foreach k {1 2 3} { set x$k [expr {$x0 + $k}]; set y$k [expr {$y0 + $k}] }
			$canv create rectangle $x0 $y0 $x2 $y2 -fill $Defaults(handle:color:dark) -outline {} -tag rect
			$canv create rectangle $x1 $y1 $x3 $y3 -fill $Defaults(handle:color:lite) -outline {} -tag rect
			$canv create rectangle $x1 $y1 $x2 $y2 -fill $Defaults(handle:color:gray) -outline {} -tag rect
			if {$x0 == $xi} { incr x0 3 } else { set x0 $xi }
		}
	} else {
		set n [expr {$w/3}]
		set x0 [expr {($w - 3*$n)/2}]
		set y0 0 ;#[expr {($h - 6)/2}]
		set yi $y0

		for {set i 0} {$i < $n} {incr i; incr x0 3} {
			foreach k {1 2 3} { set x$k [expr {$x0 + $k}]; set y$k [expr {$y0 + $k}] }
			$canv create rectangle $x0 $y0 $x2 $y2 -fill $Defaults(handle:color:lite) -outline {} -tag rect
			$canv create rectangle $x1 $y1 $x3 $y3 -fill $Defaults(handle:color:dark) -outline {} -tag rect
			$canv create rectangle $x1 $y1 $x2 $y2 -fill $Defaults(handle:color:gray) -outline {} -tag rect
			if {$y0 == $yi} { incr y0 3 } else { set y0 $yi }
		}
	}
}


proc Tooltip {mode w} {
	variable Specs

	set toolbar [winfo parent $w]

	if {![info exists Specs(tooltip:$w:$toolbar)]} { return }
	if {![llength $Specs(tooltip:$w:$toolbar)] && ![llength $Specs(tooltipvar:$w:$toolbar)]} { return }

	if {	$mode eq "show"
		&& [info exists Specs(state:$w:$toolbar)]
		&& $Specs(state:$w:$toolbar) eq "disabled"} {

		return
	}

#	if {![string match *floating.frame $toolbar]} {
#		set focus [focus]
#		if {[llength $focus] == 0 || [winfo toplevel $w] ne [winfo toplevel $focus]} {
#			set mode hide
#		}
#	}

	lassign [winfo pointerxy $w] mx my
	if {$mx < 0 || $my < 0} { set mode hide }

	set rx [winfo rootx $w]
	set ry [winfo rooty $w]
	if {$mx < $rx || $my < $ry || $mx > $rx + [winfo width $w] || $my > $ry + [winfo height $w]} {
		set mode hide
	}

	switch $mode {
		show {
			if {[string length $Specs(tooltipvar:$w:$toolbar)]} {
				::tooltip::showvar $w $Specs(tooltipvar:$w:$toolbar)
			} elseif {[string length $Specs(tooltip:$w:$toolbar)]} {
				::tooltip::show $w $Specs(tooltip:$w:$toolbar)
			}
		}

		hide {
			::tooltip::hide true
		}
	}
}


proc Move {toolbar oldSide {before {}}} {
	variable Specs

	if {$Specs(side:$toolbar) eq $oldSide} { return }
	Forget $toolbar
	Repack $toolbar
	PackToolbar $toolbar $before
	event generate $toolbar <<ToolbarShow>>
	after idle [namespace code [list Resize $Specs(frame:$toolbar)]]
}


proc Repack {toolbar} {
	variable Specs
	variable Defaults

	if {$Specs(side:$toolbar) eq "top" || $Specs(side:$toolbar) eq "bottom"} {
		set orientation horz
	} else {
		set orientation vert
	}

	if {$Specs(orientation:$toolbar) eq $orientation} { return }
	set Specs(orientation:$toolbar) $orientation
	switch $Specs(justify:$toolbar) {
		left		{ set Specs(justify:$toolbar) top }
		right		{ set Specs(justify:$toolbar) bottom }
		top		{ set Specs(justify:$toolbar) left }
		bottom	{ set Specs(justify:$toolbar) right }
	}

	if {$Specs(usehandle:$toolbar)} {
		pack forget $toolbar.handle.c
		pack forget $toolbar.handle $toolbar.widgets
	}

	set childs [pack slaves $toolbar.widgets]
	pack forget {*}$childs

	if {$orientation eq "horz"} {
		if {$Specs(usehandle:$toolbar)} {
			$toolbar.handle.c configure -width $Defaults(handle:size) -height 0
			pack $toolbar.handle.c -fill y -side left -expand yes
			pack $toolbar.handle -fill y -side left -expand yes
		}
		pack $toolbar.widgets -side left -padx $Defaults(toolbar:padding)
		foreach w $childs { PackWidget $toolbar $w }
	} else {
		if {$Specs(usehandle:$toolbar)} {
			$toolbar.handle.c configure -width 0 -height $Defaults(handle:size)
			pack $toolbar.handle.c -fill x -side top -expand yes
			pack $toolbar.handle -fill x -side top -expand yes
		}
		pack $toolbar.widgets -side top -pady $Defaults(toolbar:padding)
		foreach w $childs { PackWidget $toolbar $w }
	}

	raise $toolbar
	RaiseArrows $toolbar
}


proc RaiseArrows {toolbar} {
	variable Specs

	set tbf $Specs(frame:$toolbar)
	set parent [winfo parent $tbf]
	foreach dir {l r t b} {
		set arrow $parent.${dir}arrow
		if {[winfo exists $arrow]} { raise $arrow }
	}
}


proc MoveCmd {toolbar side oldSide} {
	variable Specs

	set Specs(side:$toolbar) $side

	if {[winfo exists $toolbar.floating]} {
		Repack $toolbar
		destroy $toolbar.floating
	} elseif {$side ne $oldSide} {
		Move $toolbar $oldSide
	}
}


proc ToolbarMenu {tbf} {
	variable Defaults

	set menu $tbf.frame.scrolled.menu
	catch { destroy $menu }
	menu $menu -tearoff 0

	set parent [winfo parent $tbf]
	set count 0

	MenuAlignment $tbf $menu
	if {$Defaults(toolbarframe:iconsize) && [UseIconSizeMenu $tbf]} {
		MenuIconSize [lindex [pack slaves $tbf.frame.scrolled] 0] $menu
		incr count
	}
	if {[addToolbarMenu $menu $parent end] >= 0} { incr count }
	if {$count == 0} { set menu $menu.mAlignment }

	MenuExpand $tbf $menu
	tk_popup $menu {*}[winfo pointerxy .]
}


proc MenuOrientation {toolbar menu} {
	variable Specs

	if {$Specs(float:$toolbar)} {
		$menu add checkbutton \
			-label [Tr Floating] \
			-onvalue float \
			-offvalue [expr {$Specs(state:$toolbar) eq "float" ? "" : "float"}] \
			-variable [namespace current]::Specs(menu:$toolbar) \
			-command [namespace code [list ChangeState $toolbar float]] \
			;
		configureCheckEntry $menu
	}

	if {$Specs(flat:$toolbar)} {
		$menu add checkbutton \
			-label [Tr Flat] \
			-onvalue flat \
			-offvalue show \
			-variable [namespace current]::Specs(menu:$toolbar) \
			-command [namespace code [list ChangeState $toolbar flat]] \
			;
		configureCheckEntry $menu
	}

	if {$Specs(hide:$toolbar)} {
		$menu add checkbutton \
			-label [Tr Hide] \
			-onvalue hide \
			-offvalue show \
			-variable [namespace current]::Specs(menu:$toolbar) \
			-command [namespace code [list ChangeState $toolbar hide]] \
			;
		configureCheckEntry $menu
	}

	if {[llength $Specs(allow:$toolbar)] > 1} {
		if {$Specs(float:$toolbar) || $Specs(flat:$toolbar)} { $menu add separator }

		foreach side {top left right bottom} {
			if {$side in $Specs(allow:$toolbar)} {
				set prev $Specs(side:$toolbar)
				$menu add radiobutton \
					-label [Tr [string toupper $side 0 0]] \
					-variable [namespace current]::Specs(side:$toolbar) \
					-value $side \
					-command [namespace code [list MoveCmd $toolbar $side $prev]] \
					;
				configureRadioEntry $menu
			}
		}
	}
}


proc MenuExpand {tbf menu} {
	variable Specs
	variable Defaults

	set orient $Specs(orientation:$tbf)
	if {$orient eq "horz"} { set dim width } else { set dim height }
	set size [winfo $dim $tbf]
	set parent [winfo parent $tbf]

	foreach slave [pack slaves $parent] {
		if {[string match $Defaults(dialog:class) [winfo class $slave]]} {
			if {[winfo x $slave] < [winfo width $parent]} {
				if {$orient eq "vert"} { incr size [winfo height $slave] }
			} else {
				if {$orient eq "horz"} { incr size [winfo width $slave] }
			}
		}
	}

	if {$size + 2 < [winfo $dim $parent]} {
		$menu add separator
		$menu add command -label [Tr Expand] -command [namespace code [list Expand $tbf]]
	}
}


proc UseIconSizeMenu {tbf} {
	variable Specs
	variable iconSizes

	foreach size $iconSizes { set $size 0 }

	foreach toolbar [pack slaves $tbf.frame.scrolled] {
		foreach size $iconSizes {
			if {$Specs($size:$toolbar)} { set $size 1 }
		}
	}

	if {$small + $medium + $large <= 1} { return false }
	return true
}


proc MenuIconSize {toolbar menu} {
	variable iconSizes
	variable Specs

	set m [menu $menu.mIconSize -tearoff false]
	$menu add cascade -menu $m -label [Tr IconSize]

	set usedSizes {}
	foreach size $iconSizes {
		if {$Specs($size:$toolbar)} { lappend usedSizes $size }
	}

	foreach size [list default {*}$usedSizes] {
		$m add radiobutton \
			-label [Tr [string toupper $size 0 0]] \
			-value $size \
			-variable [namespace current]::Specs(iconsize:$toolbar) \
			-command [namespace code [list ChangeIcons $toolbar]] \
			;
		configureRadioEntry $m
	}
}


proc MenuAlignment {tbf menu} {
	variable Specs

	set m [menu $menu.mAlignment -tearoff false]
	$menu add cascade -menu $m -label [Tr Alignment]

	if {$Specs(orientation:$tbf) eq "horz"} {
		set params {left Left center Center right Right}
	} else {
		set params {left Top center Center right Bottom}
	}

	foreach {align text} $params {
		$m add radiobutton \
			-label [Tr $text] \
			-value $align \
			-variable [namespace current]::Specs(alignment:$tbf) \
			-command [namespace code [list DoAlignment $tbf]] \
			;
		configureRadioEntry $m
	}
}


proc Menu {toolbar x y} {
	variable Specs
	variable Defaults

	if {[winfo exists $toolbar.__t__]} { return }

	set parent [winfo parent $toolbar]
	set Specs(menu:$toolbar) $Specs(state:$toolbar)
	set useToolbar [info exists Specs(toolbars:$parent)]
	set useAlignment [expr ![winfo exists $toolbar.floating]]
	set useCascade false

	if {[winfo exists $toolbar.floating] || $Specs(icon:$toolbar)} {
		set useIconSize $Specs(icon:$toolbar)
	} elseif {$Defaults(toolbarframe:iconsize)} {
		set useIconSize [UseIconSizeMenu $Specs(frame:$toolbar)]
	} else {
		set useIconSize 0
	}

	if {$useToolbar || $useIconSize || $useAlignment} { set useCascade true }

	set menu $toolbar.menu
	catch { destroy $menu }
	menu $menu -tearoff 0

	if {$useCascade} {
		set m [menu $menu.mOrientation -tearoff false]
		$menu add cascade -menu $m -label [Tr Orientation]
	} else {
		set m $menu
	}
	MenuOrientation $toolbar $m

	if {$useAlignment} {
		MenuAlignment $Specs(frame:$toolbar) $menu
	}

	if {$useIconSize} {
		MenuIconSize $toolbar $menu
	}

	if {$useToolbar} {
		addToolbarMenu $menu $parent end
	}

	if {![winfo exists $toolbar.floating]} {
		MenuExpand $Specs(frame:$toolbar) $menu
	}

	tk_popup $menu $x $y
}


proc Expand {tbf} {
	variable Specs

	pack forget $tbf
	set parent [winfo parent $tbf]
	set side [lindex [split $tbf __] end]
	set i [lsearch -exact $Specs(frame:order:$parent) $side]
	if {$i >= 0} {
		set Specs(frame:order:$parent) [lreplace $Specs(frame:order:$parent) $i $i]
	}
	PackToolbarFrame $tbf $Specs(side:[lindex [pack slaves $tbf.frame.scrolled] 0])
}


proc Hide {toolbar event} {
	variable Specs
	variable Counter

	if {[winfo exists $toolbar.floating]} {
		destroy $toolbar.floating
	}

	set Specs(state:$toolbar) $event

	if {$Specs(enabled:$toolbar)} {
		RemoveFlatHandle $toolbar
		Forget $toolbar
	}

	if {$event == "flat"} {
		PackFlatHandle $toolbar
		set ev <<ToolbarFlat>>
	} else {
		set ev <<ToolbarHide>>
	}

	if {$Specs(enabled:$toolbar)} {
		event generate $toolbar $ev
	}
}


proc ChangeState {toolbar event {caller menu}} {
	variable Specs

	switch $event {
		float {
			if {$Specs(float:$toolbar)} {
				UndockToolbar $toolbar [winfo rootx $toolbar] [winfo rooty $toolbar]
			} elseif {$Specs(flat:$toolbar)} {
				Hide $toolbar flat
			}
		}

		flat {
			if {$Specs(flat:$toolbar)} {
				Hide $toolbar flat
			}
		}

		hide {
			if {$Specs(hide:$toolbar)} {
				Hide $toolbar hide
			}
		}

		show {
			show $toolbar
		}
	}
}


proc ShowToolbar {toolbar} {
	variable Specs

	if {$Specs(enabled:$toolbar)} {
		if {$Specs(hidden:$toolbar)} {
			Hide $toolbar hide
		} else {
			set Specs(menu:$toolbar) show
			set Specs(state:$toolbar) show
			ChangeState $toolbar show
		}
	}
}


proc DockToolbar {toolbar} {
	variable Specs

	if {[winfo exists [winfo parent $toolbar]] && $Specs(state:$toolbar) ne "show"} {
		show $toolbar
	}
}


proc UndockToolbar {toolbar x y} {
	variable Specs
	variable Defaults
	variable iconSizes

	if {!$Specs(enabled:$toolbar)} { return }

	set haveMakeToolbar false
	if {[tk windowingsystem] eq "x11"} {
		set haveMakeToolbar [llength [info procs x11MakeToolbar]]
	}
	set win $toolbar.floating
	if [winfo exists $win] { return }

	Forget $toolbar
	set Specs(state:$toolbar) "float"

	tk::toplevel $win -relief solid
	bind $win <Destroy>  [namespace code [list DockToolbar $toolbar]]
	bind $toolbar <Destroy> +[list catch [list if [list "$toolbar" eq %W] [list destroy $win]]]

	set floatingToolbar \
		[tk::frame $win.frame -class ToolbarFloat -relief raised -borderwidth 2 -takefocus 0]
	bind $floatingToolbar <Destroy>  [namespace code [list array unset Specs *:$floatingToolbar]]
	bind $floatingToolbar <ButtonPress-3> [namespace code [list Menu $toolbar %X %Y]]
	pack $floatingToolbar -fill both -expand yes
	bind $floatingToolbar <Configure> [namespace code [list TracePosition $floatingToolbar $toolbar]]

	if {	$Defaults(floating:overrideredirect)
		|| [tk windowingsystem] eq "aqua"
		|| $haveMakeToolbar} {

		set decor [tk::label $floatingToolbar.decor \
			-justify left \
			-background $Defaults(floating:frame:background) \
			-foreground $Defaults(floating:frame:foreground) \
			-font TkSmallCaptionFont \
			-textvar $Specs(titlevar:$toolbar) \
			-text $Specs(title:$toolbar)] \
			;
		set font [$decor cget -font]
		$decor configure -font [list [font configure $font -family] [font configure $font -size] bold]
		pack $decor -fill x -expand yes

		bind $decor <Double-Button-1>	[list destroy $win]
		bind $decor <ButtonPress-3>	[namespace code [list Menu $toolbar %X %Y]]
		bind $decor <ButtonPress-1>	[namespace code [list StartMotion $floatingToolbar %X %Y]]
		bind $decor <ButtonRelease-1>	[namespace code [list TracePosition $floatingToolbar $toolbar]]
		bind $decor <Button1-Motion>	[namespace code [list Motion $floatingToolbar %X %Y]]
	}

	set Specs(finish:$toolbar) 0
	set Specs(orientation:$floatingToolbar) horz
	set Specs(icon:$floatingToolbar) $Specs(icon:$toolbar)
	set padx $Specs(padx:$toolbar)
	set pady $Specs(pady:$toolbar)
	pack [tk::frame $floatingToolbar.widgets -borderwidth 0 -takefocus 0] -padx $padx -pady $pady

	foreach child [pack slaves $toolbar.widgets] {
		if {$Specs(float:$child:$toolbar)} { CloneWidget $toolbar $child }
		if {[string match *Frame [winfo class $child]]} {
			bind $child <Configure> [namespace code [list BindMenuToChilds $toolbar $child]]
		}
	}

	wm withdraw $win
	wm transient $win [winfo toplevel $toolbar]
	catch { wm attributes $win -type toolbar }
	wm focusmodel $win $Defaults(floating:focusmodel)
#	NOTE: we cannot handle WM_TAKE_FOCUS correctly (we need the X server time stamp to set the focus)
#	if {$Specs(takefocus:$toolbar)} {
#		wm protocol $win WM_TAKE_FOCUS { ??? }
#	}
	::update idletasks
	set rw [winfo reqwidth $win]
	set rh [winfo reqheight $win]
	set sw [winfo workareawidth $win]
	set sh [winfo workareaheight $win]
	set rx [expr {max(min($x, $sw - $rw), 0)}]
	set ry [expr {max(min($y, $sh - $rh), 0)}]
	wm geometry $win +$rx+$ry
	if {[tk windowingsystem] eq "aqua"} {
		::tk::unsupported::MacWindowStyle style $win plainDBox {}
#		::tk::unsupported::MacWindowStyle style $win toolbar {noTitleBar}
	} elseif {[tk windowingsystem] eq "win32"} {
		wm attributes $win -toolwindow
		if {[llength $Specs(titlevar:$toolbar)]} {
			wm title $win [set $Specs(titlevar:$toolbar)]
		} else {
			wm title $win $Specs(title:$toolbar)
		}
	} elseif {$haveMakeToolbar} {
		if {$Defaults(floating:overrideredirect)} {
			wm overrideredirect $win true
		} else {
#			bind $win <FocusIn>  [namespace code [list Focus $win in]]
#			bind $win <FocusOut> [namespace code [list Focus $win out]]
		}
		x11MakeToolbar $win
	} elseif {$Defaults(floating:overrideredirect)} {
		wm overrideredirect $win true
	} else {
		wm resizable $win 0 0
		if {[llength $Specs(titlevar:$toolbar)]} {
			wm title $win [set $Specs(titlevar:$toolbar)]
		} else {
			wm title $win $Specs(title:$toolbar)
		}
		bind $win <FocusIn>  [namespace code [list Focus $win in]]
		bind $win <FocusOut> [namespace code [list Focus $win out]]
	}
	wm deiconify $win

	event generate $toolbar <<ToolbarShow>>
}


proc TracePosition {floating toolbar} {
	variable Specs

	set fx [winfo rootx $floating]
	set fy [winfo rooty $floating]
	set tx [winfo rootx [winfo toplevel $toolbar]]
	set ty [winfo rooty [winfo toplevel $toolbar]]

	set Specs(position:$toolbar) [list [expr {$fx - $tx}] [expr {$fy - $ty}]]
}


proc StartMotion {toolbar x y} {
	variable Specs

	set win [winfo parent $toolbar]
	set Specs(x:$toolbar) [expr {[winfo rootx $win] - $x}]
	set Specs(y:$toolbar) [expr {[winfo rooty $win] - $y}]
}


proc Motion {toolbar x y} {
	variable Specs

	if {![info exists Specs(x:$toolbar)]} { return }	;# this may happen during a double click

	incr x $Specs(x:$toolbar)
	incr y $Specs(y:$toolbar)
	wm geometry [winfo parent $toolbar] +$x+$y
}


proc CloneWidget {toolbar child} {
	variable Counter
	variable Specs
	variable HaveTooltips
	variable iconSizes

	set floatingToolbar $toolbar.floating.frame
	set clone $floatingToolbar.__tbw__[incr Counter]
	MakeClone $toolbar $floatingToolbar $clone $child

	set Specs(child:$child:$floatingToolbar) $clone

	if {[info exists Specs(padx:$child:$toolbar)]} {
		set Specs(padx:$clone:$floatingToolbar) $Specs(padx:$child:$toolbar)
	}

	if {[llength $clone]} {
		bind $clone <Destroy> [namespace code [list array unset Specs *:$clone:$floatingToolbar]]

		if {[info exists Specs(default:$child:$toolbar)]} {
			foreach attr [list default {*}$iconSizes tooltip tooltipvar] {
				set Specs($attr:$clone:$floatingToolbar) $Specs($attr:$child:$toolbar)
			}
		}
		if {$HaveTooltips && [info exists Specs(tooltip:$clone:$floatingToolbar)]} {
			if {	[llength $Specs(tooltip:$clone:$floatingToolbar)]
				|| [llength $Specs(tooltipvar:$clone:$floatingToolbar)]} {
				bind $clone <Enter> +[namespace code { Tooltip show %W }]
				bind $clone <Leave> +[namespace code { Tooltip hide %W }]
			}
		}
		set class [winfo class $child]
		if {$class eq "Button" || $class eq "DropdownButton"} {
			foreach attr {relief overrelief active command} {
				set Specs($attr:$clone:$floatingToolbar) $Specs($attr:$child:$toolbar)
			}
		}

		foreach var $Specs(variables:$toolbar) {
			if {[info exists Specs(value:$var:$child:$toolbar)]} {
				set Specs(value:$var:$clone:$floatingToolbar) $Specs(value:$var:$child:$toolbar)
				lappend Specs(variable:$var:$floatingToolbar) $clone
			}
		}
	}

	PackWidget $floatingToolbar $clone
	if {[winfo class $child] eq "ToolbarSeparator"} { return "" }
	return $clone
}


proc MakeClone {toolbar parent clone w} {
	variable Specs

	set class [winfo class $w]
	set Specs(clone:$toolbar:$w) $clone

	switch $class {
		ToolbarSeparator	{ frame $clone -class ToolbarSeparator -relief sunken -borderwidth 1 }
		TCombobox			{ ttk::combobox $clone }
		TTCombobox			{ ttk::tcombobox $clone; $clone clone $w }
		TEntry				{ ttk::entry $clone }
		TSpinbox				{ ttk::spinbox $clone; $clone set [$w get] }
		DropdownButton		{ $w clone $clone }
		Frame					{ CloneFrame $toolbar $parent $clone $w }
		default				{ catch {[string tolower $class] $clone} }
	}

	foreach option [$w configure] {
		set spec [lindex $option 0]
		catch { $clone configure $spec [$w cget $spec] }
	}

	foreach Tag [bind $w] {
		bind $clone $Tag [bind $w $Tag]
	}

	if {$class eq "Menubutton"} {
		set menu [$w cget -menu]
		$menu clone $clone.menu
		$clone configure -menu $clone.menu
	}
}


proc CloneFrame {toolbar parent f w} {
	variable Counter
	variable Specs

	tk::frame $f

	foreach child [winfo children $w] {
		set clone $f.__tbw__[incr Counter]
		MakeClone $toolbar $parent $clone $child
	}

	if {[llength [grid slaves $w]]} {
		set maxcol 0
		set maxrow 0

		foreach child [grid slaves $w] {
			array set opts [grid info $child]
			unset opts(-in)
			set maxcol [max $maxcol $opts(-column)]
			set maxrow [max $maxrow $opts(-row)]
			grid $Specs(clone:$toolbar:$child) {*}[array get opts]
		}

		incr maxcol
		incr maxrow

		grid anchor $f [grid anchor $w]
		grid propagate $f [grid propagate $w]

		foreach option {-minsize -weight -uniform -pad} {
			for {set i 0} {$i <= $maxcol} {incr i} {
				grid columnconfigure $f $i $option [grid columnconfigure $w $i $option]
			}
			for {set i 0} {$i <= $maxrow} {incr i} {
				grid rowconfigure $f $i $option [grid rowconfigure $w $i $option]
			}
		}
	} else {
		foreach child [pack slaves $w] {
			pack $Specs(clone:$toolbar:$child) {*}[pack info $child]
		}
	}
}


proc IsUsed {toolbarFrame} {
	return [expr {[winfo exists $toolbarFrame] && [llength [pack slaves $toolbarFrame]] > 0}]
}


proc Join {parent name} {
	if {$parent eq "."} { return ".$name" }
	return "${parent}.${name}"
}


proc Focus {win mode} {
	variable Defaults

	if {$mode eq "in"} {
		set bg $Defaults(floating:frame:activebg)
		set fg $Defaults(floating:frame:activefg)
	} else {
		set bg $Defaults(floating:frame:background)
		set fg $Defaults(floating:frame:foreground)
	}

	$win.frame.decor configure -background $bg -foreground $fg
}


proc Tr {tok} { return [mc [namespace current]::mc::$tok] }

namespace eval icon {
namespace eval 8x16 {

set arrow(l) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAgAAAAQCAQAAACBg/b2AAAAAmJLR0QA/vCI/CkAAAAJb0ZGcwAA
	AAQAAAAAAEG79NgAAAAJcEhZcwAAAEgAAABIAEbJaz4AAAAJdnBBZwAAABAAAAAQAFzGrcMAAAA2
	SURBVBjTY2AgDfxnYGBC5SIL/IdQTKhcmMB/hD4mVC6qoXABRkwVjJhaGDHNYGTAAv4zEAEAjWwH
	EotT0u8AAAAldEVYdGRhdGU6Y3JlYXRlADIwMTItMDgtMjJUMTA6NTI6NDUrMDI6MDCawkqxAAAA
	JXRFWHRkYXRlOm1vZGlmeQAyMDEyLTA4LTIyVDEwOjUyOjQ1KzAyOjAw65/yDQAAAABJRU5ErkJg
	gg==
}]

set arrow(r) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAgAAAAQCAQAAACBg/b2AAAAAmJLR0QA/vCI/CkAAAAJb0ZGcwAA
	AAQAAAAAAEG79NgAAAAJcEhZcwAAAEgAAABIAEbJaz4AAAAJdnBBZwAAABAAAAAQAFzGrcMAAAAz
	SURBVBjTY2AgBvxH5jChCzGhq2JC18iEbhayAAPDf3QBDBWMqAKMqCoYUbUw4nQ6YQAAl1IHEp/u
	ZiMAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTItMDgtMjJUMTA6NTI6NDcrMDI6MDANXVuYAAAAJXRF
	WHRkYXRlOm1vZGlmeQAyMDEyLTA4LTIyVDEwOjUyOjQ3KzAyOjAwfADjJAAAAABJRU5ErkJggg==
}]

set arrow(t) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAICAQAAABaf7ccAAAAAmJLR0QAAKqNIzIAAAAJb0ZGc///
	//gAAAAIABYA5y8AAAAJcEhZcwAAAEgAAABIAEbJaz4AAAAJdnBBZwAAAAgAAAAgAGwFG8YAAAAs
	SURBVBjTY2AgEfxn+I8qwIgmjSHKiEUaRZwRqzSSDCMOabgcI05pTBdiBwAP3AcEZbEJrgAAACV0
	RVh0ZGF0ZTpjcmVhdGUAMjAxMi0wOC0yMlQxMDo1Mzo1NCswMjowMB/dKqUAAAAldEVYdGRhdGU6
	bW9kaWZ5ADIwMTItMDgtMjJUMTA6NTM6NTQrMDI6MDBugJIZAAAAAElFTkSuQmCC
}]

set arrow(b) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAICAQAAABaf7ccAAAAAmJLR0QAAKqNIzIAAAAJb0ZGc///
	//gAAAAIABYA5y8AAAAJcEhZcwAAAEgAAABIAEbJaz4AAAAJdnBBZwAAAAgAAAAgAGwFG8YAAAAy
	SURBVBjThY5BCgAwCMPS/z+6XsaYaFlOlaYgfBAAzq1OdBrrnt7qV+iKRmiKiDg+nChsvAcEVLmW
	6gAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxMi0wOC0yMlQxMDo1NTowNiswMjowMM28Ra8AAAAldEVY
	dGRhdGU6bW9kaWZ5ADIwMTItMDgtMjJUMTA6NTU6MDYrMDI6MDC84f0TAAAAAElFTkSuQmCC
}]

} ;# namespace 8x16
} ;# namespace icon
} ;# namespace toolbar

# vi:set ts=3 sw=3:
