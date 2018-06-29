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

# ======================================================================
# Note: Each base entry has the following form:
# ---------------------------------------------
# { <unique-id> <type> <filename> <extension>
#   <encoding> <readonly-flag> <short-name> }
# ======================================================================

::util::source database-switcher

namespace eval database {

proc switcher {w args} { return [switcher::Build $w {*}$args] }

namespace eval switcher {
namespace eval mc {

set Empty								"empty"
set None									"none"
set Failed								"failed"

set UriRejectedDetail(open)		"Only Scidb databases can be opened:"
set UriRejectedDetail(import)		"Only Scidb databases can be imported:"
set EmptyUriList						"Drop content is empty."
set CopyGames							"Copy games"
set CopyGamesFromTo					"Copy games from '%src' to '%dst'"
set CopiedGames						"%s game(s) copied"
set NoGamesCopied						"No games copied"
set CopyGamesFrom						"Copy games from '%s'"
set ImportGames						"Import games"
set ImportFiles						"Import Files:"

set ImportOneGameTo(0)				"Import one game to '%dst'?"
set ImportOneGameTo(1)				"Import about one game to '%dst'?"
set ImportGamesTo(0)					"Import %num games to '%dst'?"
set ImportGamesTo(1)					"Import about %num games to '%dst'?"

set NumGames(0)						"none"
set NumGames(1)						"one game"
set NumGames(N)						"%s games"

set SelectGames(all)					"All games"
set SelectGames(filter)				"Only filtered games"
set SelectGames(all,variant)		"Only variant %s"
set SelectGames(filter,variant)	"Only filtered games of variant %s"
set SelectGames(complete)			"Complete database"

set GameCount							"Games"
set DatabasePath						"Database path"
set DeletedGames						"Deleted Games"
set ChangedGames						"Changed Games"
set AddedGames							"Added Games"
set Description						"Description"
set Created								"Created"
set LastModified						"Last modified"
set Encoding							"Encoding"
set YearRange							"Year range"
set RatingRange						"Rating range"
set Result								"Result"
set Score								"Score"
set Type									"Type"
set ReadOnly							"Read only"

}

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

set Tags {active filler border1 border2 border3 content name suff type size icon input}

set Options(iconsize) 48

array set Defaults {
	symbol-padding			4
	background				switcher,background
	selected:background	switcher,selected:background
	normal:background		switcher,normal:background
	normal:foreground		switcher,normal:foreground
	hidden:background		switcher,hidden:background
	hidden:foreground		switcher,hidden:foreground
	emph:foreground		switcher,emph:foreground
	drop:background		switcher,drop:background
	prop:background		switcher,prop:background
}


proc Build {w args} {
	variable Options
	variable Defaults

	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	array set opts {
		-opencmd		{}
		-popupcmd	{}
		-switchcmd	{}
		-updatecmd	{}
		-hide			0
	}
	array set opts $args

	set Vars(active) -1
	set Vars(selection) -1
	set Vars(counter) 0
	set Vars(bases) {}
	set Vars(subset) {}
	set Vars(variant) Normal
	set Vars(opencmd) $opts(-opencmd)
	set Vars(popupcmd) $opts(-popupcmd)
	set Vars(switchcmd) $opts(-switchcmd)
	set Vars(updatecmd) $opts(-updatecmd)
	set Vars(hide) $opts(-hide)
	set Vars(drop-targets) {}
	set Vars(drag-item) -1
	set Vars(drop-item) -1
	set Vars(curr-item) -1
	set Vars(dragging) 0
	set Vars(ignore-button1) 0

	trace add variable [namespace current]::Options(iconsize) write \
		[namespace code [list UpdateIconSize $w]]

	set background [::colors::lookup $Defaults(background)]
	set height $Options(iconsize)
	incr height 14
	set canv $w.content
	set sb $w.sb

	ttk::frame $w -borderwidth 1 -relief sunken
	tk::canvas $canv -takefocus 1 -height $height -background $background -yscrollcommand [list $w.sb set]
	$canv configure -background $background
	pack $canv -fill both -expand yes -side left
	ttk::scrollbar $sb -orient vertical -takefocus 0 -command [list $canv yview]

	bind $canv <Configure>		 [namespace code [list LayoutSwitcher $w %w %h]]
	bind $canv <ButtonPress-3>	 [namespace code [list PopupMenu $w %X %Y]]
	bind $canv <ButtonPress-1>	 [list focus $canv]
	bind $canv <ButtonPress-1>	+[list set [namespace current]::${w}::Vars(ignore-button1) 0]
	bind $canv <ButtonPress-1>	+[list ::tooltip::tooltip hide]
	bind $canv <FocusIn>			 [namespace code [list ActivateSwitcher $w normal]]
	bind $canv <FocusOut>		 [namespace code [list ActivateSwitcher $w hidden]]
	bind $canv <Left>				 [namespace code [list Traverse $w -unit]]
	bind $canv <Right>			 [namespace code [list Traverse $w +unit]]
	bind $canv <Up>				 [namespace code [list Traverse $w -line]]
	bind $canv <Down>				 [namespace code [list Traverse $w +line]]
	bind $canv <space>			 [namespace code [list ActivateBase $w]]

	rename ::$w $w.__switcher__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	::scidb::db::subscribe dbInfo [namespace current]::UpdateInfo {} $w

	return $w
}


proc WidgetProc {w command args} {
	variable [namespace current]::${w}::Vars

	switch -- $command {
		add			{ return [AddBase $w {*}$args] }
		remove		{ return [DeleteBase $w {*}$args] }
		minheight	{ return [ComputeMinHeight $w] }
		show			{ return [Properties $w $Vars(id:[lindex $args 0]) false] }

		active? {
			set file [lindex $args 0]
			set variants [::scidb::db::get variants $file]
			return [expr {$Vars(variant) in $variants}]
		}

		contains? {
			set file [lindex $args 0]
			set k [lsearch -index 2 $Vars(bases) $file]
			return [expr {$k >= 0}]
		}

		variant? {
			return $Vars(variant)
		}

		variant {
			return [SwitchToVariant $w [lindex $args 0]]
		}

		bases {
			set bases {}
			foreach entry $Vars(bases) {
				lappend bases [lindex $entry 2]
			}
			return $bases
		}

		type {
			if {[llength $args] == 2} {
				lassign $args file type
				return [SetType $w $Vars(id:$file) $type]
			} else {
				set file [lindex $args 0]
				return [lindex $Vars(bases) $Vars(index:$file) 1]
			}
		}

		extension {
			set file [lindex $args 0]
			return [lindex $Vars(bases) $Vars(index:$file) 3]
		}

		encoding {
			set index $Vars(index:[lindex $args 0])
			if {[llength $args] == 1} {
				return [lindex $Vars(bases) $index 4]
			} else {
				set flag [lindex $args 1]
				return [lset Vars(bases) $index 4 $flag]
			}
		}

		readonly? {
			set file [lindex $args 0]
			return [lindex $Vars(bases) $Vars(index:$file) 5]
		}

		readonly {
			lassign $args file flag
			return [lset Vars(bases) $Vars(index:$file) 5 $flag]
		}

		current? {
			return [lindex $Vars(bases) $Vars(map:$Vars(selection)) 2]
		}

		current {
			set file [lindex $args 0]
			return [Select $w $file]
		}

		iconsize {
			if {[llength $args] == 0} { return [set [namespace current]::Options(iconsize)] }
			return [SetIconSize $w [lindex $args 0]]
		}

		update {
			if {[llength $args] == 0} { return [LayoutSwitcher $w] }
			if {[llength $args] == 1} { return [UpdateSwitcher $w {*}$args] }

			lassign $args file variant
			CheckVariant $w $file $variant
			return [UpdateSwitcher $w $file $variant]
		}

		see {
			set file [lindex $args 0]
			return [SeeSymbol $w $Vars(id:$file)]
		}

		activate {
			return [RegisterDragDropEvents $w]
		}

		focus {
			return [focus $w.content]
		}
	}

	return [$w.__switcher__ $command {*}$args]
}


proc UpdateInfo {w file variant} {
	variable ::scidb::clipbaseName
	variable ${w}::Vars

	if {$file ne $clipbaseName && [string length [file extension $file]] == 0} { return }

	$Vars(updatecmd)
	UpdateSwitcher $w $file $variant
}


proc ComputeMinHeight {w} {
	variable ${w}::Vars
	variable Defaults
	variable Options

	set canv $w.content
	$canv itemconfigure size0 -state normal
	lassign [$canv bbox size0] x1 y1 x2 y2
	set textHeight [expr {$y2 - $y1}]

	set ipad 2
	set minheight $Options(iconsize)
	incr minheight $Defaults(symbol-padding)
	incr minheight [expr {2*$ipad + 6}]

	if {$Options(iconsize) < 32} {
		set minheight [expr {max($minheight, $textHeight + 4)}]
	} else {
		set minheight [expr {max($minheight, 2*$textHeight + 6)}]
	}

	return $minheight
}


proc UpdateIconSize {w args} {
	variable ${w}::Vars
	variable Options

	set canv $w.content
	set size $Options(iconsize)
	if {$size <= 16} { set symFont TkTooltipFont } else { set symFont TkTextFont }

	foreach entry $Vars(bases) {
		lassign $entry id type
		set img [set ::application::database::icons::${type}(${size}x${size})]
		$canv itemconfigure icon$id -image $img
		$canv itemconfigure name$id -font $symFont
		$canv itemconfigure suff$id -font $symFont
		$canv itemconfigure size$id -font $symFont
		UpdateIcon $w $id
	}

	update idletasks
	LayoutSwitcher $w
}


proc Select {w file} {
	variable ${w}::Vars

	set id $Vars(id:$file)
	if {$Vars(selection) == $id} { return }
	set canv $w.content

	if {$Vars(selection) >= 0} {
		set current [lindex $Vars(bases) $Vars(map:$Vars(selection)) 2]
		set Vars(base:$Vars(variant)) $current
	}

	set Vars(selection) $id

	CheckVariant $w $file 
	UpdateSwitcher $w $file
	SeeSymbol $w $id
}


proc SetCount {w id file} {
	variable ${w}::Vars

	set count [::scidb::db::count games $file $Vars(variant)]
	set total [::scidb::db::count total $file]
	if {$total > $count} {
		set count "[::locale::formatNumber $count] / [::locale::formatNumber $total]"
	} elseif {$count == 0} {
		set count $mc::Empty
	} else {
		set count [::locale::formatNumber $count]
	}

	$w.content itemconfigure size$id -text $count
}


proc SwitchToVariant {w variant} {
	variable ${w}::Vars

	set file [lindex $Vars(bases) $Vars(map:$Vars(selection)) 2]
	set Vars(base:$Vars(variant)) $file
	set variants [::scidb::db::get variants $file]
	set Vars(variant) $variant

	if {$variant ni $variants} {
		if {[info exists Vars(base:$variant)]} {
			set Vars(selection) $Vars(id:$Vars(base:$variant))
		} else {
			set Vars(selection) [lindex $Vars(idList) 0]
		}
	}

	foreach id $Vars(idList) {
		UpdateBase $w $id
	}

	LayoutSwitcher $w
}


proc CheckVariant {w file {variant ""}} {
	variable ${w}::Vars

	if {[string length $variant] == 0} { set variant $Vars(variant) }

	set variants [::scidb::db::get variants $file]

	if {$variant ni $variants} {
		if {[info exists Vars(variant:$file)]} {
			set variant $Vars(variant:$file)
		} else {
			set variant [lindex $variants 0]
		}
	}

	if {$variant ne $Vars(variant)} {
		set Vars(variant) $variant
		$Vars(updatecmd) $Vars(variant)
		foreach id $Vars(idList) {
			UpdateBase $w $id
		}
	}
}


proc UpdateBase {w id} {
	variable ${w}::Vars
	variable Options

	lassign [lindex $Vars(bases) $Vars(map:$id)] _ type file
	set variants [::scidb::db::get variants $file]
	set included [expr {$Vars(variant) in $variants}]
	set canv $w.content

	if {$included} {
		SetCount $w $id $file
	}

	if {$id == 0} {
		$canv itemconfigure name$id -text $::util::clipbaseName
	}

	if {!$Vars(hide)} {
		set img [set ::application::database::icons::${type}(${Options(iconsize)}x${Options(iconsize)})]
		if {!$included} { set img [::icon::makeDisabledImage $img] }
		if {[$canv itemcget icon$id -image] ne $img} {
			$canv itemconfigure icon$id -image $img
		}

		set icon [::dialog::fsbox::fileIcon [GetFileType $file]]
		if {!$included} { set icon [::icon::makeDisabledImage $icon ] }
		if {[$canv itemcget type$id -image] ne $icon} {
			$canv itemconfigure type$id -image $icon
		}
	}
}


proc UpdateIcon {w id} {
	variable ${w}::Vars
	variable Options

	lassign [lindex $Vars(bases) $Vars(map:$id)] _ type file

	if {[::scidb::db::get writable? $file]} {
		set ext [string tolower [file extension $file]]

		if {$ext eq ".pgn" || $ext eq ".gz" || $ext eq ".zip"} {
			set unsaved [::scidb::db::get unsaved? $file]
			set size $Options(iconsize)
			set icon [set ::application::database::icons::${type}(${size}x${size})]

			if {$unsaved} {
				variable UnsavedIcon

				if {![info exists UnsavedIcon($type,$size)]} {
					set img [image create photo -width 0 -height 0]
					$img copy $icon
					::scidb::tk::image colorize darkred 1 $img
					set UnsavedIcon($type,$size) $img
				}

				set icon $UnsavedIcon($type,$size)
			}

			$w.content itemconfigure icon$id -image $icon
		}
	}
}


proc UpdateSwitcher {w file {variant ""}} {
	variable ${w}::Vars

	if {[string length $variant] == 0 || $variant eq "Undetermined" || $variant eq $Vars(variant)} {
		if {[info exists Vars(id:$file)]} {
			UpdateBase $w $Vars(id:$file)
			UpdateIcon $w $Vars(id:$file)
			LayoutSwitcher $w
		}
	}
}


proc ActivateSwitcher {w state} {
	variable ${w}::Vars

	if {$state eq "normal"} { set Vars(active) $Vars(selection) }

	if {!$Vars(hide)} {
		$w.content itemconfigure active$Vars(active) -state $state
	}
}


proc Traverse {w move} {
	variable ${w}::Vars

	set active $Vars(active)
	$w.content itemconfigure active$active -state hidden
	if {$Vars(hide)} { set idList $Vars(subset) } else { set idList $Vars(idList) }
	set n [lsearch -integer -index 0 $idList $Vars(active)]
	set nbases [llength $idList]

	switch -- $move {
		+unit {
			if {[incr n] == $nbases} { set n 0 }
		}
		-unit {
			if {[incr n -1] < 0} { set n [expr {$nbases - 1}] }
		}
		+line {
			set ncols $Vars(unitsperline)
			set nrows [expr {($nbases + $ncols - 1)/$ncols}]
			incr n $ncols
			if {$n >= $nrows*$ncols} { set n [expr {$n % $ncols}] }
		}
		-line {
			set ncols $Vars(unitsperline)
			if {$n < $ncols} {
				set nrows [expr {($nbases + $ncols - 1)/$ncols}]
				set n [expr {($nrows - 1)*$ncols + $n}]
			} else {
				incr n -$ncols
			}
		}
	}

	if {$n >= 0 && $n < [llength $idList]} {
		set Vars(active) [lindex $idList $n 0]
	}
	$w.content itemconfigure active$Vars(active) -state normal
	SeeSymbol $w $Vars(active)
}


proc SeeSymbol {w id} {
	variable ${w}::Vars
	variable Defaults

	if {![info exists Vars(canv-height)]} { return }

	update idletasks
	set pad $Defaults(symbol-padding)
	set canv $w.content
	set topFraction [lindex [$canv yview] 0]
	set y3 [expr {$topFraction*$Vars(canv-height)}]
	set y4 [expr {$y3 + [winfo height $canv]}]
	lassign [$canv bbox input$id] x1 y1 x2 y2
	if {$y3 + $pad < $y1 || $y2 < $y4 + $pad} {
		set fraction [expr {double($y1 - $pad)/$Vars(canv-height)}]
		set fraction [min 1.0 [max 0.0 $fraction]]
		$canv yview moveto $fraction
	}
}


proc ActivateBase {w} {
	variable ${w}::Vars

	set Vars(selection) $Vars(active)
	set file [lindex $Vars(bases) $Vars(map:$Vars(active)) 2]
	CheckVariant $w $file
	LayoutSwitcher $w
	$Vars(switchcmd) $file
}


proc DeleteBase {w file} {
	variable ${w}::Vars
	variable Tags

	set k $Vars(index:$file)
	set newId [set id [lindex $Vars(bases) $k 0]]
	set Vars(bases) [lreplace $Vars(bases) $k $k]
	set Vars(idList) [lreplace $Vars(idList) $k $k]

	array unset Vars variant:$file
	array unset Vars index:$file
	array unset Vars id:$file
	array unset Vars map:*

	foreach variant {Normal ThreeCheck Bughouse Crazyhouse Antichess Losers} {
		if {[info exists Vars(base:$variant)] && $Vars(base:$variant) eq $file} {
			array unset Vars base:$variant
		}
	}

	set index -1
	foreach entry $Vars(bases) {
		lassign $entry i _ file
		set Vars(index:$file) [incr index]
		set Vars(map:$i) $index
	}

	foreach tag $Tags { $w.content delete $tag$id }

	if {$Vars(selection) == $id} {
		set i [lsearch -integer $Vars(subset) $id]
		if {$i == 0} {
			set newId [lindex $Vars(subset) end]
		} else {
			set newId [lindex $Vars(subset) [expr {$i - 1}]]
		}
		set Vars(selection) $newId
	}

	if {$Vars(active) == $id} { set Vars(active) $Vars(selection) }
	LayoutSwitcher $w

	if {$id != $newId} {
		set file [lindex $Vars(bases) $Vars(map:$newId) 2]
		set variant $Vars(variant)
		if {[llength $Vars(subset)] == 1 && [llength [::scidb::db::get variants $file]] == 0} {
			set variant Normal
		}
		CheckVariant $w $file $variant
		$Vars(switchcmd) $file
	}

	$Vars(updatecmd) $Vars(variant)
}


proc SetType {w id type} {
	variable ${w}::Vars
	variable Options

	set img [set ::application::database::icons::${type}(${Options(iconsize)}x${Options(iconsize)})]
	$w.content itemconfigure icon$id -image $img
	lset Vars(bases) $Vars(map:$id) 1 $type
}


proc GetFileType {file} {
	switch [set ext [string tolower [file extension $file]]] {
		.zip		{ set ext .pgn }
		.pgn.gz	{ set ext .pgn }
		.bpgn.gz	{ set ext .bpgn }
		""			{ set ext .sci }
	}
	return $ext
}


proc AddBase {w file type readonly {encoding {}}} {
	variable ${w}::Vars
	variable Options
	variable Defaults
	variable Tags

	set id $Vars(counter)
	incr Vars(counter)

	if {[string length $encoding] == 0 || $encoding eq $::encoding::autoEncoding} {
		set encoding [::scidb::db::get encoding $file]
	}
	set name [::util::databaseName $file no]
	set ext [GetFileType $file]
	set icon [::dialog::fsbox::fileIcon $ext]
	set Vars(index:$file) [llength $Vars(bases)]
	set Vars(id:$file) $id
	set Vars(map:$id) $Vars(index:$file)
	set ext [string range $ext 1 end]
	lappend Vars(bases) [list $id $type $file $ext $encoding $readonly $name]
	lappend Vars(idList) $id

	set bg [::colors::lookup $Defaults(hidden:background)]
	set emph [::colors::lookup $Defaults(emph:foreground)]
	set canv $w.content
	if {$Options(iconsize) <= 16} { set fnt TkTooltipFont } else { set fnt TkTextFont }

	$canv create rectangle 0 0 0 0 -tags active$id -fill black -width 0
	$canv create rectangle 0 0 0 0 -tags filler$id -fill white -width 0
	$canv create rectangle 0 0 0 0 -tags border1$id -fill white -width 0
	$canv create rectangle 0 0 0 0 -tags border2$id -fill gray56 -width 0
	$canv create rectangle 0 0 0 0 -tags border3$id -fill white -width 0
	$canv create rectangle 0 0 0 0 -tags content$id -fill $bg -width 0
	$canv create text 0 0 -anchor nw -tags name$id -font $fnt -text $name
	$canv create text 0 0 -anchor nw  -tags suff$id -font $fnt -text $ext -fill $emph
	$canv create text 0 0 -anchor ne -tags size$id -font $fnt
	$canv create image 0 0 -anchor nw -tags type$id -image $icon
	$canv create image 0 0 -tags icon$id -anchor nw
	$canv create rectangle 0 0 0 0 -tags [list $id input$id] -fill {} -width 0

	$canv bind input$id <ButtonPress-3>		 [namespace code [list PopdownProps $w]]
	$canv bind input$id <ButtonPress-3>		+[namespace code [list PopupMenu $w %X %Y $id]]
	$canv bind input$id <ButtonRelease-1>	 [namespace code [list DoSwitch $w $id %x %y]]
	$canv bind input$id <ButtonPress-2>		 [namespace code [list Properties $w $id true]]
	$canv bind input$id <ButtonRelease-2>	 [namespace code [list PopdownProps $w]]
	$canv bind input$id <Enter>				 [namespace code [list ShowDescription $w $id]]
	$canv bind input$id <Leave>				 [list ::tooltip::hide]

	$canv yview moveto 1.0

	SetType $w $id $type
	$Vars(updatecmd) $Vars(variant)
	UpdateBase $w $id
	LayoutSwitcher $w
}


proc DoSwitch {w id x y} {
	variable ${w}::Vars

	if {$Vars(ignore-button1)} { return }

	set canv $w.content
	lassign [$canv bbox input$id] x1 y1 x2 y2
	if {$x < $x1 || $x2 < $x || $y < $y1 || $y2 < $y} { return }

	$canv itemconfigure active$Vars(active) -state hidden
	$canv itemconfigure active$id -state normal
	set Vars(active) $id
	set file [lindex $Vars(bases) $Vars(map:$id) 2]
	$Vars(switchcmd) $file
	focus $canv
}


proc LayoutSwitcher {w args} {
	variable ${w}::Vars
	variable Options
	variable Defaults
	variable Tags

	if {[llength $Vars(bases)] == 0} { return }

	set canv $w.content

	if {[llength $args] == 0} {
		set wd [winfo width $canv]
		set ht [winfo height $canv]
	} else {
		lassign $args wd ht
	}
	if {$wd <= 1} { return }

	set subset {0}

	for {set i 1} {$i < [llength $Vars(bases)]} {incr i} {
		set file [lindex $Vars(bases) $i 2]
		set variants [::scidb::db::get variants $file]
		if {$Vars(variant) in $variants} {
			lappend subset [lindex $Vars(bases) $i 0]
		}
	}

	if {$Vars(hide)} {
		foreach id $Vars(subset) {
			if {$id ni $subset} {
				foreach tag $Tags { $canv itemconfigure $tag$id -state hidden }
			}
		}
		foreach id $subset {
			if {$id ni $Vars(subset)} {
				foreach tag $Tags { $canv itemconfigure $tag$id -state normal }
			}
		}
		set idList $subset
	} else {
		set idList $Vars(idList)
	}

	set Vars(subset) $subset
	set sbw [winfo width $w.sb]
	if {$sbw <= 1} { set sbw 15 }
	if {"$w.sb" in [pack slaves $w]} { incr wd $sbw }
	$canv itemconfigure size0 -state normal
	lassign [$canv bbox size0] x1 y1 x2 y2
	set textHeight [expr {$y2 - $y1}]
	set padType 3
	set minwidth 0

	foreach id $idList {
		lassign [$canv bbox name$id] x1 y1 x2 y2
		set minwidth [max $minwidth [expr {$x2 - $x1}]]
		if {$Options(iconsize) >= 32} { set state normal } else { set state hidden }
		$canv itemconfigure size$id -state $state
		$canv itemconfigure suff$id -state hidden
		$canv itemconfigure type$id -state hidden
		if {$Options(iconsize) >= 48} {
			$canv itemconfigure suff$id -state normal
			$canv itemconfigure type$id -state normal
			lassign [$canv bbox size$id] x1 y1 x2 y2
			lassign [$canv bbox suff$id] u1 v1 u2 v2
			lassign [$canv bbox type$id] s1 t1 s2 t2
			set minwidth [max	$minwidth [expr {$x2 - $x1 + $u2 - $u1 + $s2 - $s1 + 5 + $padType}]]
		} elseif {$Options(iconsize) >= 32} {
			$canv itemconfigure suff$id -state normal
			lassign [$canv bbox size$id] x1 y1 x2 y2
			lassign [$canv bbox suff$id] s1 t1 s2 t2
			set minwidth [max	$minwidth [expr {$x2 - $x1 + $s2 - $s1 + 5}]]
		} else {
			incr minwidth 3
		}
	}

	set pad $Defaults(symbol-padding)
	set ipad 2
	incr minwidth $Options(iconsize)
	incr minwidth $pad
	incr minwidth [expr {3*$ipad + 4}]
	set minheight $Options(iconsize)
	incr minheight $pad
	incr minheight [expr {2*$ipad + 4}]
	if {$Options(iconsize) < 32} {
		set maxheight [expr {$textHeight + 4}]
	} else {
		set maxheight [expr {2*$textHeight + 6}]
	}
	set maxheight [expr {max($minheight, $maxheight)}]
	set shiftY [expr {($maxheight - $minheight)/2}]
	set minheight $maxheight
	set cols [expr {($wd - $pad)/$minwidth}]
	set rows [expr {([llength $Vars(subset)] + $cols - 1)/$cols}]
	set minH [expr {$rows*$minheight + $pad}]
	set includesPane [expr {"$w.sb" in [pack slaves $w]}]
	if {$ht < $minH && !$includesPane} {
		pack $w.sb -fill y -side left
	} elseif {$minH <= $ht && $includesPane} {
		pack forget $w.sb
	}
	if {$includesPane} { incr wd -$sbw }
	set haveFocus [expr {[focus] eq $canv}]
	set cols [expr {($wd - $pad)/$minwidth}]
	set minH [expr {$rows*$minheight + $pad}]
	set offsY [expr {($minheight - $pad - 2*$textHeight)/3}]
	set x $pad
	set y $pad
	set r 0

	foreach id $idList {
		set x0 $x
		set y0 $y
		set x1 [expr {$x + $minwidth - $pad}]
		set y1 [expr {$y + $minheight - $pad}]

		$canv coords active$id [expr {$x0 - 1}] [expr {$y0 - 1}] [expr {$x1 + 2}] [expr {$y1 + 2}]
		$canv coords filler$id [expr {$x0 - 0}] [expr {$y0 - 0}] [expr {$x1 + 1}] [expr {$y1 + 1}]
		$canv coords input$id $x0 $y0 $x1 $y1
		$canv coords border1$id $x0 $y0 $x1 $y1
		$canv coords border2$id [incr x0] [incr y0] $x1 $y1
		$canv coords border3$id [incr x0] [incr y0] [incr x1 -1] [incr y1 -1]
		$canv coords content$id $x0 $y0 [incr x1 -1] [incr y1 -1]
		$canv coords icon$id [expr {$x0 + $ipad}] [expr {$y0 + $ipad + $shiftY}]

		switch $Options(iconsize) {
			16 - 24 {
				set x0 [expr {$x0 + 2*$ipad + $Options(iconsize) + 3}]
				set y0 [expr {$y + ($minheight - $pad - $textHeight)/2}]
				$canv coords name$id $x0 $y0
			}
			32 {
				set x0 [expr {$x0 + 2*$ipad + $Options(iconsize)}]
				set y0 [expr {$y + $ipad + $offsY}]
				set x1 [expr {$x + $minwidth - $pad - 3*$ipad}]
				set y1 [expr {$y + $minheight - $pad - $textHeight - $offsY}]
				set y2 [expr {$y + $ipad + $shiftY + $Options(iconsize)}]
				$canv coords name$id $x0 $y0
				$canv coords suff$id $x0 $y1
				$canv coords size$id $x1 $y1
			}
			48 {
				lassign [$canv bbox suff$id] u1 v1 u2 v2
				set x0 [expr {$x0 + 2*$ipad + $Options(iconsize)}]
				set y0 [expr {$y + $ipad + $offsY}]
				set x1 [expr {$x0 + $u2 - $u1 + $padType}]
				set x2 [expr {$x + $minwidth - $pad - 3*$ipad}]
				set y1 [expr {$y + $minheight - $pad - $textHeight - $offsY}]
				set y2 [expr {$y + $ipad + $shiftY + $Options(iconsize)}]
				$canv coords name$id $x0 $y0
				$canv coords type$id $x1 $y1
				$canv coords size$id $x2 $y1
				$canv coords suff$id $x0 $y1
			}
		}

		if {$Vars(active) == $id && $haveFocus} { set state normal } else { set state hidden }
		$canv itemconfigure active$id -state $state

		if {$Vars(selection) == $id} {
			set state selected
		} elseif {$id in $Vars(subset)} {
			set state normal
		} else {
			set state hidden
		}
		$canv itemconfigure content$id -fill [::colors::lookup $Defaults($state:background)]

		if {$id in $Vars(subset)} { set state emph } else { set state hidden }
		$canv itemconfigure suff$id -fill [::colors::lookup $Defaults($state:foreground)]

		if {$id in $Vars(subset)} { set state normal } else { set state hidden }
		$canv itemconfigure name$id -fill [::colors::lookup $Defaults($state:foreground)]
		$canv itemconfigure size$id -fill [::colors::lookup $Defaults($state:foreground)]

		if {[incr r] == $cols} {
			incr y $minheight
			set x $pad
			set r 0
		} else {
			incr x $minwidth
		}
	}

	$canv configure -scrollregion [list 0 0 $wd [expr {$rows*$minheight + $pad}]]
	set Vars(unitsperline) $cols
	if {$r != $cols} { incr y $minheight }
	set Vars(canv-height) $y
}


proc PopupMenu {w x y {id -1}} {
	variable ${w}::Vars

	if {$id >= 0} {
		set file [lindex $Vars(bases) $Vars(map:$id) 2]
	} else {
		set file ""
	}

	$Vars(popupcmd) $w.content $x $y $file
}


proc RegisterDragDropEvents {w} {
	set canv $w.content

	::tkdnd::drop_target register $canv DND_Files
	::tkdnd::drag_source register $canv DND_Files

	bind $canv <<DropEnter>>		[namespace code [list HandleDropEvent $w enter %t %a %X %Y]]
	bind $canv <<DropLeave>>		[namespace code [list HandleDropEvent $w leave %t %a %X %Y]]
	bind $canv <<DropPosition>>	[namespace code [list HandleDropPosition $w %a %X %Y]]
	bind $canv <<Drop>>				[namespace code [list HandleDropEvent $w %D %t %a %X %Y]]
	bind $canv <<DragInitCmd>>		[namespace code [list HandleDragEvent $w %W %t %X %Y]]
	bind $canv <<DragEndCmd>>		[namespace code [list FinishDragEvent $w %W %A]]
	bind $canv <<DragPosition>>	[namespace code [list HandleDragPositon $w %W %X %Y]]
}


proc HandleDragEvent {w src types x y} {
	variable ${w}::Vars

	set id [FindDragItem $w $x $y]
	if {$id < 0} { return {} }
	set base [lindex $Vars(bases) $Vars(map:$id) 2]
	set variants [::scidb::db::get variants $base]
	if {$Vars(variant) ni $variants} { return {} }

	set Vars(drag-item) $id
	array set Vars { drop-item -1 curr-item -1 dragging 1 ignore-button1 1 drop-targets {} }

	foreach entry $Vars(bases) {
		lassign $entry i _ file _ _ readonly
		if {!$readonly} {
			set variants [::scidb::db::get variants $file]
			if {$Vars(variant) in $variants} {
				lappend Vars(drop-targets) $i
			}
		}
	}

	set ext [file extension $base]
	if {[string length $ext] == 0} { set ext .sci }
	set dragCursors [::dialog::fsbox::dragCursors $ext]
	if {[llength $dragCursors]} {
		::tkdnd::set_drag_cursors $src \
			{copy move link ask private} [lindex $dragCursors 0] \
			refuse_drop [lindex $dragCursors 1] \
			;
	}

	set actionList {copy}
	if {[::scidb::db::get memoryOnly? $base] || $::tcl_platform(platform) ne "windows"} {
		lappend actionList move
	}
	lappend actionList link ask private

	set files {}
	set file [file rootname $base]

	if {$file eq $base} {
		lappend files $file
	} else {
		foreach ext [::scidb::misc::suffixes $base] {
			set f "$file.$ext"
			if {[file exists $f]} { lappend files $f }
		}
	}

	return [list $actionList DND_Files $files]
}


proc HandleDragPositon {w src x y} {
	variable ${w}::Vars

	set item [winfo containing $x $y]
	if {$Vars(drag-item) == 0 && $item ne "$w.content"} { return refuse_drop }
	return ""
}


proc FinishDragEvent {w src currentAction} {
	variable ${w}::Vars

	::tkdnd::set_drag_cursors $src
	set Vars(dragging) 0
}


proc HandleDropEvent {w action types actions x y} {
	variable ${w}::Vars

	if {[llength $actions] == 0} { return refuse_drop }
	if {[llength $actions] == 1 && "private" in $actions} { return refuse_drop }

	switch $action {
		enter {
			if {!$Vars(dragging)} {
				array set Vars { drop-item -1 curr-item -1 }
			}
			HighlightDropRegion $w $x $y enter
			::tooltip::tooltip exclude $w.content
		}
		leave {
			HighlightDropRegion $w $x $y leave
		}
		default {
			if {$Vars(drop-item) >= 0} {
				if {$Vars(drop-item) != $Vars(drag-item)} {
					set destination [lindex $Vars(bases) $Vars(map:$Vars(drop-item)) 2]
					if {$Vars(dragging)} {
						set source [lindex $Vars(bases) $Vars(map:$Vars(drag-item)) 2]
						set cmd [list CopyDatabase $w $source $destination $Vars(variant) $x $y]
					} else {
						set cmd [list ImportDatabases $w $action $destination $Vars(variant) $x $y]
					}
					after idle [namespace code $cmd]
				}
			} elseif {!$Vars(dragging)} {
				HighlightDropRegion $w $x $y leave
				after idle [namespace code [list OpenUri $w $action]]
			}
			::tooltip::tooltip include all
		}
	}

	return copy
}


proc HandleDropPosition {w actions x y} {
	variable ${w}::Vars

	if {[llength $actions] == 0} { return refuse_drop }
	if {[llength $actions] == 1 && "private" in $actions} { return refuse_drop }

	HighlightDropRegion $w $x $y position

	if {$Vars(curr-item) != $Vars(drop-item) && $Vars(curr-item) != $Vars(drag-item)} {
		return refuse_drop
	}

	if {$Vars(curr-item) == -1} { return copy }
	return ask
}


proc FindDragItem {w x y} {
	variable ${w}::Vars

	set canv $w.content
	set x [expr {$x - [winfo rootx $canv]}]
	set y [expr {$y - [winfo rooty $canv]}]

	if {0 <= $x && $x < [winfo width $canv] && 0 <= $y && $y < [winfo height $canv]} {
		foreach tag [$canv gettags [$canv find closest $x $y]] {
			if {[string is integer -strict $tag]} {
				if {!$Vars(dragging) || $tag in $Vars(drop-targets) || $tag == $Vars(drag-item)} {
					return $tag
				}
			}
		}
	}

	return -1
}


proc HighlightDropRegion {w x y action} {
	variable ${w}::Vars
	variable Defaults

	set id [FindDragItem $w $x $y]
	set canv $w.content

	if {!$Vars(dragging)} {
		switch $action {
			enter {
				if {$id == -1} {
					$canv configure -background [::colors::lookup $Defaults(drop:background)]
				}
			}
			leave {
				if {$Vars(drop-item) == -1} {
					$canv configure -background [::colors::lookup $Defaults(background)]
				}
			}
			position {
				if {$Vars(curr-item) != $id} {
					if {$id == -1} { set color $Defaults(drop:background) } else { set color white }
					$canv configure -background [::colors::lookup $color]
				}
			}
		}
	}

	if {$Vars(drop-item) >= 0 && ($action eq "leave" || $Vars(drop-item) != $id)} {
		$canv itemconfigure content$Vars(drop-item) -fill $Vars(background:item)
		set Vars(drop-item) -1
	}

	if {$action ne "leave"} {
		if {	$id >= 0
			&& $id != $Vars(drop-item)
			&& $id != $Vars(drag-item)
			&& ![lindex $Vars(bases) $Vars(map:$id) 5]} {

			set Vars(background:item) [$canv itemcget content$id -fill]
			$canv itemconfigure content$id -fill [::colors::lookup $Defaults(drop:background)]
			set Vars(drop-item) $id
		}
	}

	set Vars(curr-item) $id
}


proc ParseUriFiles {parent files allowedExtensions action} {
	set errorList {}
	set rejectList {}
	set remoteList {}
	set trashList {}
	set acceptList {}

	foreach {uri file} [::fsbox::parseUriList $files] {
		if {	[string equal -length 5 $uri "http:"]
			|| [string equal -length 6 $uri "https:"]
			|| [string equal -length 4 $uri "ftp:"]} {
			lappend remoteList $uri
		} elseif {[string equal -length 5 $uri "http:"] || [string equal -length 4 $uri "ftp:"]} {
			# TODO: support .scv, .pgn, and .bpgn files in successor versions
			lappend rejectList $uri
		} elseif {[file exists $file]} {
			if {[string equal -length 9 $uri "trash:/0-"]} {
				# KDE style: normalize URI
				set uri "trash:///[string range $uri 9 end]"
			}
			lappend acceptList $uri $file
		} elseif {$uri ni $errorList} {
			lappend errorList $uri
		}
	}

	set databaseList {}

	# TODO: in case of .zip files reject if no .pgn (or .PGN) file is contained
	
	foreach {uri file} $acceptList {
		set origExt [file extension $file]

		if {[string length $origExt]} {
			set origExt [string range $origExt 1 end]
			set mappedExt [::scidb::misc::mapExtension $origExt]

			if {$origExt ne $mappedExt} {
				set f [file rootname $file]
				append f . $mappedExt
				if {[file exists $f]} {
					set file $f
				}
			}
		}

		if {[file extension $file] in $allowedExtensions} {
			if {$file ni $databaseList} { lappend databaseList $file }
		} elseif {$file ni $rejectList} {
			if {[string match trash* $uri]} {
				lappend rejectList $uri
			} else {
				lappend rejectList $file
			}
		}
	}

	if {[llength $errorList]} {
		if {[string match file:* $files] && [llength $databaseList] == 0} {
			set message $::fsbox::mc::CannotOpenUri
			if {[llength $errorList] > 10} {
				append message \n\n [join [lrange $errorList 0 9] \n]
				append message \n...
			} else {
				append message \n\n [join $errorList \n]
			}
		} else {
			set message $::fsbox::mc::InvalidUri
		}
		dialog::error -parent $parent -message $message
	}

	if {[llength $trashList]} {
		set message $::fsbox::mc::CannotOpenTrashFiles
		if {[llength $trashList] > 10} {
			append message \n\n [join [lrange $trashList 0 9] \n]
			append message \n...
		} else {
			append message \n\n [join $trashList \n]
		}
		dialog::info -parent $parent -message $message
	}

	if {[llength $remoteList]} {
		set message $::fsbox::mc::CannotOpenRemoteFiles
		if {[llength $remoteList] > 10} {
			append message \n\n [join [lrange $remoteList 0 9] \n]
			append message \n...
		} else {
			append message \n\n [join $remoteList \n]
		}
		dialog::info -parent $parent -message $message
	}

	if {[llength $rejectList]} {
		set message $::fsbox::mc::UriRejected
		if {[llength $rejectList] > 10} {
			append message \n\n [join [lrange $rejectList 0 9] \n]
			append message \n...
		} else {
			append message \n\n [join $rejectList \n]
		}
		append detail $mc::UriRejectedDetail($action)
		append detail " "
		append detail [join $allowedExtensions ", "]
		dialog::info -parent $parent -message $message -detail $detail
	}
	
	if {	[llength $databaseList] +
			[llength $rejectList] +
			[llength $trashList] +
			[llength $errorList] == 0} {
		set message $mc::EmptyUriList
		dialog::info -parent $parent -message $message
	}

	return $databaseList
}


proc OpenUri {w uriFiles} {
	variable ${w}::Vars

	set parent $w.content
	set allowedExtensions {.sci .scv .si3 .si4 .cbh .cbf .pgn .pgn.gz .bpgn .bpgn.gz .zip .CBF .PGN .ZIP}
	set databaseList [ParseUriFiles $parent $uriFiles $allowedExtensions open]

	# take into account that the application is currently loading a database
	if {[::remote::blocked?]} {
		::remote::requestOpenBases $databaseList
	} else {
		foreach file $databaseList {
			$Vars(opencmd) $file no
		}
		if {[llength $databaseList] == 1} {
			$Vars(switchcmd) [lindex $databaseList 0]
		}
	}
}


proc ImportDatabases {parent uriFiles destination variant x y} {
	set allowedExtensions {.sci .si3 .si4 .pgn .pgn.gz .bpgn .bpgn.gz .zip .PGN .ZIP}
	set databaseList [ParseUriFiles $parent $uriFiles $allowedExtensions import]
	set reply no

	if {[llength $databaseList] > 0} {
		set ngames 0
		set estimated 0

		foreach file $databaseList {
			set n [::dialog::fsbox::estimateNumberOfGames $file]
			if {$n < 0} { set estimated 1 }
			set ngames [expr {$ngames + abs($n)}]
		}

		if {$ngames == 1} {
			set msg $mc::ImportOneGameTo($estimated)
		} else {
			set msg $mc::ImportGamesTo($estimated)
		}
		set ngames [::locale::formatNumber $ngames]
		set msg [string map [list %dst [::util::databaseName $destination] %num $ngames] $msg]
		append msg "\n\n"
		append msg $mc::ImportFiles
		set detail [join $databaseList "\n"]
		set reply [::dialog::question \
			-parent $parent \
			-title "$::scidb::app: $mc::ImportGames" \
			-message $msg \
			-detail $detail \
			-buttons {yes no} \
			-default yes \
		]
	}

	HighlightDropRegion $parent $x $y leave

	if {$reply eq "yes"} {
		::import::import $parent $destination $databaseList $mc::ImportGames
	}
}


proc CopyDatabase {parent src dst variant x y} {
	variable ::table::options

	set srcN [::util::databaseName $src]
	set dstN [::util::databaseName $dst]
	set msg  [string map [list %src $srcN %dst $dstN] $mc::CopyGamesFromTo]
	set opts [list -message $msg. -interrupt yes]
	set args [list [namespace current]::LogCopyDb {}]

	set srcVariants [::scidb::db::get variants $src]
	set dstVariants [::scidb::db::get variants $dst]

	if {[llength $srcVariants] > 1} { set varg ",variant" } else { set varg "" }

	set m [menu $parent.selection_ -tearoff 0]
	$m add command                                       \
		-label " [format $mc::CopyGamesFrom $srcN]"       \
		-image $::icon::16x16::none                       \
		-compound left                                    \
		-background $options(menu:headerbackground)       \
		-foreground $options(menu:headerforeground)       \
		-activebackground $options(menu:headerbackground) \
		-activeforeground $options(menu:headerforeground) \
		-font $options(menu:headerfont)                   \
		;
	$m add separator

	# All games of current variant ###########################
	set ngames [::scidb::db::count games $src $variant]
	if {$ngames == 0} { set state disabled } else { set state normal }
	set txt [format $mc::SelectGames(all$varg) $variant]
	switch $ngames {
		0			{ append txt " ($mc::NumGames(0))" }
		1			{ append txt " ($mc::NumGames(1))" }
		default	{ append txt " ([format $mc::NumGames(N) [::locale::formatNumber $ngames]])" }
	}
	$m add command \
		-label " $txt" \
		-image $::icon::16x16::piechart(all) \
		-compound left \
		-command [list set [namespace current]::trigger_ all] \
		-state $state \
		;

	# All games of current filter ############################
	set ngames 0 ;# TODO get number of games from active filter
	if {$ngames == 0} { set state disabled } else { set state normal }
	set txt [format $mc::SelectGames(filter$varg) $variant]
	switch $ngames {
		0			{ append txt " ($mc::NumGames(0))" }
		1			{ append txt " ($mc::NumGames(1))" }
		default	{ append txt " ([format $mc::NumGames(N) [::locale::formatNumber $ngames]])" }
	}
	$m add command \
		-label " $txt" \
		-image $::icon::16x16::piechart(filter) \
		-compound left \
		-command [list set [namespace current]::trigger_ filter] \
		-state $state \
		;

	if {[llength $srcVariants] > 1 && [llength $dstVariants] > 1} {
		# Copy all games of database #############################
		set ntotal [::scidb::db::count total $src]
		if {$ntotal == $ngames} { set state disabled } else { set state normal }
		set txt $mc::SelectGames(complete)
		switch $ntotal {
			0			{ append txt " ($mc::NumGames(0))" }
			1			{ append txt " ($mc::NumGames(1))" }
			default	{ append txt " ([format $mc::NumGames(N) [::locale::formatNumber $ntotal]])" }
		}
		$m add command \
			-label " $txt" \
			-image $::icon::16x16::piechart(complete) \
			-compound left \
			-command [list set [namespace current]::trigger_ complete] \
			-state $state \
			;
	}

	# Cancel operation #######################################
	$m add separator
	$m add command \
		-label " $::mc::Cancel" \
		-image $::icon::16x16::crossHand \
		-compound left \
		-command [list set [namespace current]::trigger_ cancel] \
		-accelerator $::mc::Key(Esc) \
		;

	variable trigger_ none
	bind $m <<MenuUnpost>> [list set [namespace current]::trigger_ cancel]
	tk_popup $m {*}[winfo pointerxy $parent]
	vwait [namespace current]::trigger_
	destroy $m
	HighlightDropRegion $parent $x $y leave
	if {$trigger_ eq "cancel"} { return }

	::log::open $mc::CopyGames
	::log::delay
	::log::info $msg

	switch $trigger_ {
		filter {
			# TODO
		}
		all {
			set ngames [::scidb::db::count games $dst $variant]
			set cmd [list ::scidb::view::copy $src 0 $dst $variant {}]
		}
		complete {
			set ngames [::scidb::db::count total $dst]
			set cmd [list ::scidb::db::copy $src $dst {}]
		}
	}

	set cmd [list ::progress::start $parent $cmd $args $opts 0]

	if {[catch { ::util::catchException $cmd result } rc opts]} {
		::log::error $::import::mc::AbortedDueToInternalError
		::progress::close
		::log::close
		return {*}$opts -rethrow 1 $ngames
	}

	if {$rc == 1} {
		::log::error $::import::mc::AbortedDueToIoError
		::progress::close
		::log::close
		# show error dialog
		return 0
	}

	lassign $result total illegal accepted rejected

	if {$total < 0} {
		::log::warning $::import::mc::UserHasInterrupted
		set total [expr {-$total + 1}]
		set rc -1
	}

	update idletasks	;# be sure the following will be appended

	::import::logResult $total $illegal $mc::NoGamesCopied $mc::CopiedGames $accepted $rejected
	set cmd [list ::scidb::db::save $dst]
	set rc [::util::catchException { ::progress::start $parent $cmd {} {} 1 } count]
	if {$rc == 1} { ::log::error $::import::mc::AbortedDueToIoError }
	::progress::close
	::log::close
	::log::show
}


proc LogCopyDb {sink arguments} {
	lassign $arguments type code gameNo
	set var [string toupper $type 0 0]
	append line $::import::mc::GameNumber " " [::locale::formatNumber $gameNo] ": "
	append line [set ::import::mc::${var}($code)]
	::log::${type} $line
}


proc Properties {w id popup} {
	variable ${w}::Vars
	variable Defaults

	set canv $w.content
	lassign [lindex $Vars(bases) $Vars(map:$id)] _ type file ext

	if {$popup} {
		set dlg $canv.properties
	} else {
		set dlg $canv.prop_[regsub -all {[^[:alnum:]]} $file _]
		if {[winfo exists $dlg]} { return [::widget::dialogRaise $dlg] }
	}

	if {$popup} {
		if {[winfo exists $dlg]} { destroy $dlg }
		set f [::util::makePopup $dlg]
		set label ::tk::label
		set options [list -background [$f cget -background]]
	} else {
		tk::toplevel $dlg -class Scidb
		set f $dlg.f
		tk::frame $f -takefocus 0 -background [::colors::lookup $Defaults(prop:background)]
		wm title $dlg "$::scidb::app - [::util::databaseName $file]"
		wm resizable $dlg false false
		set label ::ttk::label
		set options {}
		pack $f -fill x -expand yes
	}

	set variant $Vars(variant)
	set variants [::scidb::db::get variants $file]
	if {[llength $variants] == 1 && $variant ni $variants} {
		set variant [lindex $variants 0]
	}

	set row 1
	foreach {name var} {	path DatabasePath descr Description type Type variant Variant
								readonly ReadOnly created Created lastModified LastModified
								encoding Encoding games GameCount deleted DeletedGames changed
								ChangedGames added AddedGames yearRange YearRange ratingRange
								RatingRange score Score resWhite {Result 1-0} resBlack
								{Result 0-1} resDraw {Result 1/2-1/2} resLost {Result 0-0}
								resNone {Result *}} {

		if {[llength $var] == 1} {
			if {[info exists mc::$var]} { set txt [set mc::$var] } else { set txt [set ::mc::$var] }
			$label $f.l$name -text "[set mc::$var]:" {*}$options
		} else {
			lassign $var v extension
			if {$v eq "Result"} { set extension [::util::formatResult $extension] }
			$label $f.l$name -text "[set mc::$v] $extension:" {*}$options
		}
		$label $f.t$name -justify left {*}$options
		if {!$popup} {
			$f.l$name configure -background [::colors::lookup $Defaults(prop:background)]
			$f.t$name configure -background [::colors::lookup $Defaults(prop:background)]
		}
		grid $f.l$name -row $row -column 1 -sticky wn
		grid $f.t$name -row $row -column 3 -sticky wn
		incr row 2
	}

	$f.tpath configure -wraplength 250 -justify left
	$f.tdescr configure -wraplength 250 -justify left
	grid columnconfigure $f {0 2 4} -minsize $::theme::padx
	grid rowconfigure $f [list 0 [expr {$row - 1}]] -minsize $::theme::pady

	set size [::scidb::db::count games $file $variant]
	set readOnly [::scidb::db::get readonly? $file]

	set descr [::scidb::db::get description $file]
	if {[string length $descr] == 0} { set descr "\u2014" }
	grid $f.lpath $f.tpath $f.ldescr $f.tdescr
	$f.tpath configure -text $file
	$f.tdescr configure -text $descr

	if {$id == 0} {
		foreach name {path readonly created lastModified} {
			grid remove $f.l$name $f.t$name
		}
	} else {
		set created [::scidb::db::get created? $file]
		if {[string length $created] == 0} {
			$f.tcreated configure -text $::mc::NotAvailableSign
		} else {
			$f.tcreated configure -text [::locale::formatTime $created]
		}
		set lastModified [::scidb::db::get modified? $file]
		if {[string length $lastModified] == 0} {
			$f.tlastModified configure -text $::mc::NotAvailableSign
		} else {
			$f.tlastModified configure -text [::locale::formatTime $lastModified]
		}
	}
	if {$size == 0} {
		set ngames $mc::None
	} else {
		set ngames [::locale::formatNumber $size]
	}

	$f.ttype			configure -text [set ::application::database::mc::T_$type]
	$f.tvariant		configure -text $::mc::VariantName($variant)
	$f.tgames		configure -text $ngames
	$f.treadonly	configure -text [expr {$readOnly ? $::mc::Yes : $::mc::No}]

	set txt [::scidb::db::get usedencoding $file]
	if {[::scidb::db::get encodingState $file] ne "ok"} { append txt " ($mc::Failed)" }
	$f.tencoding configure -text $txt

	set slaves [grid slaves $f]

	if {$size == 0} {
		foreach name {	deleted changed added yearRange ratingRange score \
							resWhite resBlack resDraw resLost resNone} {
			if {"$f.l$name" in $slaves} { grid remove $f.l$name $f.t$name }
		}
	} else {
		if {$ext eq "bpgn"} {
			if {"$f.ldeleted" in $slaves} { grid remove $f.ldeleted $f.tdeleted }
		} else {
			if {"$f.ldeleted" ni $slaves} { grid $f.ldeleted $f.tdeleted }
		}
		if {"$f.lyearRange" ni $slaves} {
			foreach name {yearRange ratingRange score resWhite resBlack resDraw resLost resNone} {
				grid $f.l$name $f.t$name
			}
		}

		lassign [::scidb::db::get stats $file] deleted changed added minYear maxYear avgYear \
			minElo maxElo avgElo resNone resWhite resBlack resDraw resLost
		set total [expr {double($resWhite + $resBlack + $resDraw + $resLost)}]
		set size [expr {double($size)}]
		set score 0

		if {$total != 0.0} {
			set score [expr {round((($resWhite + 0.5*$resDraw)/$total)*100)}]
		}
	
		if {$minYear && $maxYear && $minYear != $maxYear} {
			set yearRange "$minYear-$maxYear ($avgYear)"
		} elseif {$minYear} {
			set yearRange $minYear
		} else {
			set yearRange "\u2014"
		}

		if {$minElo && $maxElo && $minElo != $maxElo} {
			set ratingRange "$minElo-$maxElo ($avgElo)"
		} elseif {$minElo} {
			set ratingRange $minElo
		} else {
			set ratingRange "\u2014"
		}

		foreach var {	deleted changed added yearRange ratingRange
							score resWhite resBlack resDraw resLost resNone} {
			set value [set $var]
			if {$var eq "score"} {
				set text  [format "%d%%" $value]
			} elseif {$value == 0} {
				set text "\u2014"
			} elseif {[string match *Range $var]} {
				set text $value
			} else {
				set text [::locale::formatNumber $value]
				append text " (" [format "%d" [expr {round((double($value)/$size)*100)}]] "%)"
			}
			$f.t$var configure -text $text
		}
	}

	if {$popup} {
		set Vars(properties) $dlg
		::tooltip::popup $canv $dlg cursor
	} elseif {![winfo exists $dlg.close]} {
		::widget::dialogButtons $dlg close
		$dlg.close configure -command [list destroy $dlg]
		wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
		wm withdraw $dlg
		::util::place $dlg -parent $canv -position center
		wm deiconify $dlg
	}
}


proc PopdownProps {w} {
	variable ${w}::Vars

	if {[info exists Vars(properties)]} {
		::tooltip::popdown $Vars(properties)
	}
}


proc ShowDescription {w id} {
	variable ${w}::Vars

	set file [lindex $Vars(bases) $Vars(map:$id) 2]
	set text [::scidb::db::get description $file]
	if {[string length $text]} { ::tooltip::show $w.content $text }
}

} ;# namespace switcher
} ;# namespace database

# vi:set ts=3 sw=3:
