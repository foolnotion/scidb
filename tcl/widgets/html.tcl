# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2011-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
package require Tkhtml 3.1

rename html __html_widget

proc html {args} {
	if {[llength $args] == 0} {
		return error -code "wrong # args: should be \"html pathName ?options?\""
	}

	if {[winfo exists [lindex $args 0]]} {
		return error -code "window name \"[lindex $args 0]\" already exists"
	}

	if {[llength $args] % 2 == 0} {
		return error -code "value for \"[lindex $args end]\" missing"
	}

	return [html::Build {*}$args]
}

namespace eval html {

namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::max

variable Margin	8 ;# do not change!
variable MaxWidth	12000



proc findHyphenPatterns {lang} {
	set patternFilename [file join $::scidb::dir::hyphen pattern $lang.dat]
	if {![file readable $patternFilename]} { return { "" {} } }
	set dictFilenames ""
	set filename [file join $::scidb::dir::hyphen dict xx.dat]
	if {[file readable $filename]} { append dictFilenames $filename }
	set filename [file join $::scidb::dir::hyphen dict $lang.dat]
	if {[file readable $filename]} {
		if {[string length $dictFilenames]} { append dictFilenames ";" }
		append dictFilenames $filename
	}
	set filename [file join $::scidb::dir::home dict $lang.dat]
	if {[file readable $filename]} {
		if {[string length $dictFilenames]} { append dictFilenames ";" }
		append dictFilenames $filename
	}
	return [list $patternFilename $dictFilenames]
}


proc preload {lang} {
	lassign [findHyphenPatterns $lang] patternFilename dictFilenames
	if {[string length $patternFilename]} {
		::scidb::misc::html preload $patternFilename $dictFilenames
	}
}


proc hyphenate {lang content} {
	lassign [findHyphenPatterns $lang] patternFilename dictFilenames
	if {[string length $patternFilename]} {
#		if {$lang eq "de"} {
#			# don't use German eszet:
#			set content [string map {"ß" "ss"} $content]
#		}
		set content [::scidb::misc::html hyphenate $patternFilename $dictFilenames $content]
	}

	return $content
}


proc formatPath {path {delim {}}} {
	if {[llength $delim] == 0} {
		if {$::tcl_platform(platform) eq "windows"} { set delim "\\" } else { set delim "/" }
	}
	set parts {}
	set components [split $path $delim]
	for {set i 0} {$i < [llength $components]} {incr i} {
		set comp [lindex $components $i]
		if {[string length $comp] > 0} {
			lappend parts $comp
		} elseif {$i == 0} {
			if {[llength $components] > 1} {
				incr i
				lappend parts "${delim}[lindex $components $i]"
			} else {
				lappend parts $delim
			}
		}
	}
	if {[string index $path end] eq $delim && [lindex $parts end] ne $delim} {
		lset $parts end "[lindex $parts end]${delim}"
	}
	set result ""
	for {set i 0} {$i < [llength $parts]} {incr i} {
		if {$i < [llength $parts] - 1} {
			append result "<code>[lindex $parts $i]${delim}</code>&#8203;"
		}  else {
			append result "<code>[lindex $parts $i]</code>"
		}
	}
	return $result
}


proc formatUrl {url} {
	set i [string first :// $url]
	if {$i == -1} { return [formatPath $url "/"] }
	set result "<code>[string range $url 0 [expr {$i - 1}]]://</code>&#8203;"
	append result [formatPath [string range $url [expr {$i + 3}] end] "/"]
	return $result
}


proc defaultCSS {monoFamilies textFamilies {hoverColor none}} {
	append css \n
	append css ":link    { color: blue2; text-decoration: none; }" \n
	append css ":visited { color: purple; text-decoration: none; }" \n
	append css ":user    { color: blue2; text-decoration: none; }   /* http link */" \n
	append css ":user2   { color: purple; text-decoration: none; }  /* http visited */" \n
	append css ":user3   { color: black; text-decoration: none; }   /* invalid link */" \n
	append css ":hover   { text-decoration: underline; background: $hoverColor; }" \n
	append css ".match   { background: yellow; color: black; }" \n
	append css "body     { color: black; }\n"
	append css [monoStyle $monoFamilies] \n
	append css [textStyle $textFamilies] \n
	return $css
}


proc monoStyle {families} {
	append result "pre, tt, code, kbd { font-family: " [BuildFontString $families] "; }"
	return $result
}


proc textStyle {families} {
	append result "html { font-family: " [BuildFontString $families] "; }"
	return $result
}


proc minFontSize {} { return 8 }
proc maxFontSize {} { return 14 }


proc getFontTable {fontsize} {
	if {8 > $fontsize || $fontsize > 14} {
		error "unsupported font size '$fontsize': should be one of {8 9 10 11 12 13 14}"
	}
	switch $fontsize {
		 8 { return { 5  6  7  8 10 12 14} }
		 9 { return { 6  7  8  9 11 13 15} }
		10 { return { 7  8  9 10 12 14 16} }
		11 { return { 8  9 10 11 13 15 17} }
		12 { return { 9 10 11 12 14 16 18} }
		13 { return {10 11 12 13 15 17 19} }
		14 { return {11 12 13 14 16 18 20} }
	}
}


proc BuildFontString {families} {
	set result ""
	foreach fam $families {
		set last [string index $result end]
		if {$last ne "," && $last ne ""} { append result "," }
		if {[string index $fam 0] eq "\""} {
			append result $fam
		} else {
			append result "\"" $fam "\""
		}
	}
	return $result
}


proc Build {w args} {
	array set opts {
		-width				800
		-height				600
		-fixedwidth			0
		-class				Html
		-background			{}
		-backgroundimage	""
		-borderwidth		{}
		-relief				{}
		-exportselection	no
		-center				no
		-fittowidth			no
		-fittoheight		no
		-imagecmd			{}
		-doublebuffer		yes
		-latinligatures	yes
		-usehorzscroll		yes
		-usevertscroll		yes
		-keephorzscroll	no
		-keepvertscroll	no
		-showhyphens		0
		-delay				0
		-css					{}
		-importdir			{}
		-fonttable			{}
		-fontsize			11
		-textalign			"left"
		-cursor				standard
	}

	array set opts $args
	set preamble ""

	if {[string length $opts(-background)] || [string length $opts(-background)]} {
		append preamble "html {"
		if {[string length $opts(-background)]} {
			append preamble "background: $opts(-background);\n"
		}
		if {[string length $opts(-backgroundimage)]} {
			append preamble "background-image: '$opts(-backgroundimage)';\n"
		}
		append preamble "}\n"
		append script $preamble
		append script $opts(-css)
		set opts(-css) $script
	}

	if {[string length $opts(-background)] == 0} { set opts(-background) white }
	if {[string length $opts(-imagecmd)] == 0} { set opts(-imagecmd) [namespace code GetImage] }

	set options {}
	set htmlOptions {}
	foreach name [array names opts] {
		switch -- $name {
			-delay - -css - -center - -fittowidth - -fittoheight - -importdir - -textalign - -cursor -
			-usehorzscroll - -usevertscroll - -keephorzscroll - -keepvertscroll - -fontsize -
			-backgroundimage - -fixedwidth {}

			-class - -imagecmd - -doublebuffer - -latinligatures - -exportselection -
			-selectbackground - -selectforeground - -inactiveselectbackground -
			-inactiveselectforeground - -width - -height - -fonttable {
				set value $opts($name)
				if {[llength $value]} { lappend htmlOptions $name $value }
			}

			-showhyphens {
				set value $opts($name)
				if {[llength $value]} {
					if {$value in {no false}} {
						set value 0
					} elseif {$value in {yes true}} {
						set value 1
					}
					lappend htmlOptions $name $value
				}
			}

			default {
				set value $opts($name)
				if {[llength $value]} { lappend options $name $value }
			}
		}
	}

	tk::frame $w {*}$options
	tk::frame $w.sub -background $opts(-background) -borderwidth 0  -class _HTML_Frame_
	set html $w.sub.html
	if {$opts(-usevertscroll)} {
		::scrolledframe::scrollbar $w.v -orient "vertical" -command [list $html yview]
		grid $w.v -row 0 -column 1 -sticky ns
	}
	if {$opts(-usehorzscroll)} {
		::scrolledframe::scrollbar $w.h -orient "horizontal" -command [list $html xview]
		grid $w.h -row 1 -column 0 -sticky ew
	}
	grid $w.sub -row 0 -column 0 -sticky nsew
	grid columnconfigure $w {0} -weight 1
	grid rowconfigure $w {0} -weight 1

	namespace eval [namespace current]::$w {}
	variable ${w}::Priv
	variable ${w}::HoverNodes
	variable ${w}::ActiveNodes1
	variable ${w}::ActiveNodes2
	variable ${w}::ActiveNodes3

	array set Priv {
		onmouseover		{}
		onmouseout		{}
		onmousedown1	{}
		onmouseup1		{}
		onmousedown2	{}
		onmouseup2		{}
		onmousedown3	{}
		onmouseup3		{}
		nodeList			{}
		afterId			{}
		request			{}
		bbox				{}
		widgets			{}
		minbbox			{}
		script			""
		pointer			{0 0}
		focus				0
		sel:state		0
		styleCount		0
	}
	set Priv(preamble) $preamble
	set Priv(fixedwidth) $opts(-fixedwidth)

	lappend Priv(onmouseover) [namespace code [list ShowTooltip $html]]
	lappend Priv(onmouseout)  [namespace code HideTooltip]

	foreach attr {delay center fittowidth fittoheight borderwidth css importdir textalign} {
		set Priv($attr) $opts(-$attr)
	}

	if {[llength $Priv(borderwidth)] == 0} { set Priv(borderwidth) 0 }

	if {[llength $opts(-fonttable)]} {
		set opts(-fontsize) [lindex $opts(-fonttable) 3]
		set Priv(fontsize) $opts(-fontsize)
	} elseif {$opts(-fontsize) != 11} {
		set opts(-fonttable) [getFontTable $opts(-fontsize)]
		lappend htmlOptions -fonttable $opts(-fonttable)
		set Priv(fontsize) $opts(-fontsize)
	} else {
		set Priv(fontsize) 11
	}

	rename ::$w $w.__html__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	if {$Priv(center)} {
		$w.sub configure -width $opts(-width) -height $opts(-height)
	}

	if {$opts(-usevertscroll)} { set shrink no } else { set shrink yes }
	__html_widget $html {*}$htmlOptions -shrink $shrink
	$html handler script style [namespace code [list StyleHandler $html]]
	$html handler node a [namespace code [list RefHandler $html]]
	if {[string length $Priv(importdir)]} {
		$html handler node link [namespace code [list LinkHandler $html]]
	}

	ttk::setCursor $html $opts(-cursor)

	if {$opts(-usehorzscroll)} {
		if {$opts(-keephorzscroll)} {
			set cmd [list $w.h set]
		} else {
			set cmd [namespace code [list SbSet $w.h]]
		}
		$html configure -xscrollcommand $cmd -xscrollincrement 30
	}
	if {$opts(-usevertscroll)} {
		if {$opts(-keepvertscroll)} {
			set cmd [list $w.v set]
		} else {
			set cmd [namespace code [list SbSet $w.v]]
		}
		$html configure -yscrollcommand $cmd -yscrollincrement 18
	}

	if {$Priv(center)} {
		place $html -x 0 -y 0
		bind $w.sub <Configure> [namespace code { Place %W }]
	} else {
		pack $html -fill both -expand yes
		if {$opts(-usevertscroll)} {
			bind $w <Configure> [namespace code { Configure %W %w %# }]
		}
	}

	SelectionClear $html
	selection handle $html [namespace code [list SelectionHandler $html]]

	return $w
}


proc StyleHandler {w node contents} {
	variable [winfo parent [winfo parent $w]]::Priv

	incr Priv(styleCount)
	set id "author.[format %.4d $Priv(styleCount)]"
	$w style \
		-id $id.9999 \
		-importcmd [namespace code [list ImportHandler $w]] \
		-urlcmd [namespace code [list UrlHandler $w]] \
		$contents
}


proc RefHandler {w node} {
	puts "[$node attribute href]"
}


proc LinkHandler {w node} {
	if {[$node attribute rel] eq "stylesheet"} {
		set uri [$node attribute -default {} href]
		if {[string length $uri]} { ImportHandler $w author $uri }
	}
}


proc ImportHandler {w parentid uri} {
	variable [winfo parent [winfo parent $w]]::Priv

	set file [file join $Priv(importdir) $uri]

	if {[file readable $file]} {
		set fd [::open $file r]
		chan configure $fd -encoding utf-8
		set contents [read $fd]
		close $fd

		incr Priv(styleCount)
		set id "$parentid.[format %.4d $Priv(styleCount)]"
		set handler [namespace code [list ImportHandler $w]]
		$w style -id $id.9999 -importcmd $handler -urlcmd [namespace code [list UrlHandler $w]] $contents
	}
}


proc UrlHandler {w args} {
	puts "UrlHandler: $args"
}


proc ShowTooltip {html nodes} {
	foreach node $nodes {
		if {[string length [set tip [$node attribute -default "" title]]]} {
			::tooltip::show $html $tip
		}
	}
}


proc HideTooltip {nodes} {
	foreach node $nodes {
		if {[string length [$node attribute -default "" title]]} {
			::tooltip::hide
		}
	}
}


proc GetImage {file} {
	if {[catch { set img [image create photo -file $file] }]} { return {} }
	return [list $img [namespace code DeleteImage]]
}


proc DeleteImage {args} { catch { image delete $args } }


proc WidgetProc {w command args} {
	if {![winfo exists $w]} { return }
	variable ${w}::Priv

	switch -glob -- $command {
		clear {
			$w.sub.html reset
		}

		parse {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <html-script>\""
			}

			variable Margin
			variable MaxWidth

			array unset [namespace current]::${w}::HoverNodes
			array unset [namespace current]::${w}::ActiveNodes1
			array unset [namespace current]::${w}::ActiveNodes2
			array unset [namespace current]::${w}::ActiveNodes3
			set Priv(nodeList) {}

			$w.sub.html reset
			$w.sub.html xview moveto 0
			$w.sub.html yview moveto 0
			if {$Priv(fixedwidth) > 0} {
				$w.sub.html configure -fixedwidth $Priv(fixedwidth)
			} elseif {!$Priv(fittowidth)} {
				$w.sub.html configure -fixedwidth $MaxWidth
			}
			set Priv(script) [lindex $args 0]
			$w.sub.html parse -final [lindex $args 0]
			SetupCSS $w
			EvalWidgetCommands $w
			set Priv(minbbox) {}
			if {$Priv(fixedwidth) <= 0 && ($Priv(center) || !$Priv(fittowidth))} {
				set bbox [$w minbbox]
				if {[llength $bbox] == 0} { set bbox [$w bbox] }
				set width [expr {min([lindex $bbox 2], 4000) + $Margin}]
				$w.sub.html configure -fixedwidth $width
			}
			if {$Priv(fittoheight)} {
				update idletasks
				lassign [$w.sub.html bbox] x y wd ht
				set height [expr {$ht + 2*$y}]
				$w.sub configure -height $height
				$w.sub.html configure -height $height
			}
			if {$Priv(center)} {
				update idletasks
				after idle [namespace code [list Place $w.sub]]
			}
			return $Priv(minbbox)
		}

		minbbox {
			if {[llength $Priv(minbbox)] == 0} {
				if {$Priv(fittowidth)} {
					set maxWidth [$w.sub cget -width]
				} else {
					set maxWidth [set [namespace current]::MaxWidth]
				}
				set Priv(minbbox) [ComputeBoundingBox $w.sub.html [$w.sub.html node] $maxWidth]
			}
			return $Priv(minbbox)
		}

		margin {
			return [set [namespace current]::Margin]
		}

		handler - search - style {
			return [$w.sub.html $command {*}$args]
		}

		onmouse* {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <script>\""
			}
			if {![info exists Priv($command)]} {
				append msg "unknown event type \""
				append msg $command
				append msg "\": should be one of"
				append msg [join [array names Priv onmouse*] ", "]
				error $msg
			}
			set Priv($command) $args
			switch $command {
				onmouseover	{ lappend Priv(onmouseover) [namespace code [list ShowTooltip $w.sub.html]] }
				onmouseout	{ lappend Priv(onmouseout)  [namespace code HideTooltip] }
			}
			return
		}

		stimulate {
			set x [expr {[winfo pointerx .] - [winfo rootx $w.sub.html]}]
			set y [expr {[winfo pointery .] - [winfo rooty $w.sub.html]}]
			Motion $w.sub.html $x $y 0
			return
		}

		drawable	{ return $w.sub.html }
		pointer	{ return $Priv(pointer) }
		font		{ return HtmlFont }

		bbox {
			if {[llength $args] == 0} {
				return [$w.sub.html bbox]
			}
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command ?<node>?\""
			}
			return [$w.sub.html bbox [lindex $args 0]]
		}

		viewbox {
			return [$w.sub.html viewbox]
		}

		visbbox {
			return [$w.sub.html visbbox]
		}

		node {
			return [$w.sub.html node {*}$args]
		}

		nearest {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <y>"
			}
			set node [FindNearest $w.sub.html {*}$args]
			if {[llength $node] == 0} { return $node }
			return [GetInnerNode $w.sub.html $node]
		}

		size {
			lassign [$w.sub.html bbox] x y w h
			set w [expr {$w + 2*$x}]
			set h [expr {$h + 2*$y}]
			return [list $w $h]
		}

		xview - yview {
			return [$w.sub.html $command {*}$args]
		}

		scrollto {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <px>\""
			}
			variable Margin
			set height [lindex [$w.sub.html visbbox] 3]
			if {$height > 0 } {
				set y [expr {max(0, [lindex $args 0] - $Margin)}]
				set fraction [expr {double($y)/double($height)}]
			} else {
				set fraction 0
			}
			return [$w.sub.html yview moveto $fraction]
		}

		fonttable? {
			return [$w.sub.html cget -fonttable]
		}

		fonttable {
			if {[llength $args] == 0} {
				return [$w.sub.html cget -fonttable]
			}
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <font sizes>"
			}
			set Priv(fontsize) [lindex $args 0 3]
			SetupCSS $w
			$w.sub.html configure -fonttable {*}$args
			return
		}

		fontsize? {
			return $Priv(fontsize)
		}

		fontsize {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <pt>"
			}
			set size [expr {max(8, min(14, [lindex $args 0]))}]
			if {$size != $Priv(fontsize)} {
				set Priv(fontsize) $size
				SetupCSS $w
				$w.sub.html configure -fonttable [getFontTable $size]
			}
			return $size
		}

		css {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] $command <script>"
			}
			set Priv(css) [lindex $args 0]
			SetupCSS $w
			return
		}

		root {
			return [$w.sub.html node]
		}

		focusin {
			if {!$Priv(focus)} {
				set Priv(focus) 1
				if {[$w.sub.html cget -exportselection]} {
					# TODO the problem with this change is that
					# the whole widget will be updated. In this
					# case the double buffering cannot work.
					$w.sub.html tag configure selection \
						-foreground [$w.sub.html cget -selectforeground] \
						-background [$w.sub.html cget -selectbackground] \
						;
				}
			}
			return
		}

		focusout {
			if {$Priv(focus)} {
				set Priv(focus) 0
				if {[$w.sub.html cget -exportselection]} {
					# TODO the problem with this change is that
					# the whole widget will be updated. In this
					# case the double buffering cannot work.
					$w.sub.html tag configure selection \
						-foreground [$w.sub.html cget -inactiveselectforeground] \
						-background [$w.sub.html cget -inactiveselectbackground] \
						;
				}
			}
			return
		}

		configure {
			if {[llength $args] % 2 == 1} {
				return error -code "value for \"[lindex $args end]\" missing"
			}
			set reparse 0
			set showhyphens [$w.sub.html cget -showhyphens]
			array set opts $args
			if {[info exists opts(-textalign)]} {
				set Priv(textalign) $opts(-textalign)
				array unset opts -textalign
				set reparse 1
			}
			if {[info exists opts(-showhyphens)]} {
				set showhyphens $opts(-showhyphens)
				array unset opts -showhyphens
				set reparse 1
			}
			if {[info exists opts(-fixedwidth)]} {
				set Priv(fixedwidth) $opts(-fixedwidth)
				array unset opts -fixedwidth
			}
			if {[info exists opts(-fittowidth)]} {
				set Priv(fittowidth) $opts(-fittowidth)
				array unset opts -fittowidth
			}
			set args {}
			foreach {attr value} [array get opts] {
				switch -- $attr {
					-imagecmd - -doublebuffer - -latinligatures - -exportselection -
					-selectbackground - -selectforeground - -inactiveselectbackground -
					-inactiveselectforeground - -width - -fonttable {
						$w.sub.html configure $attr $value
					}
					default {
						lappend args $attr $value
					}
				}
			}
			if {$reparse} {
				SetupCSS $w
				$w.sub.html configure -showhyphens $showhyphens
				$w parse $Priv(script)
			}
			if {[info exists opts(-height)]} {
				$w.sub configure -height $opts(-height)
			}
		}
	}

	return [$w.__html__ $command {*}$args]
}


proc SetupCSS {w} {
	variable ${w}::Priv

	append css $Priv(preamble)
	append css $Priv(css)
	append css "\nbody { font-size: ${Priv(fontsize)}pt; }"
	if {$Priv(textalign) ne "left"} {
		append css "\np { text-align: $Priv(textalign); }"
		append css "\nli { text-align: $Priv(textalign); }"
		append css "\nspan.justification { text-align: $Priv(textalign); }"
		append css "\ndiv.annotation { text-align: $Priv(textalign); }"
		append css "\ntd.justification { text-align: $Priv(textalign); }"
		append css "\ntd.standard-justification { text-align: $Priv(textalign); }"
	}
	set css [string trim $css]
	if {[string length $css]} { $w.sub.html style -id user $css }
}


proc EvalWidgetCommands {w} {
	variable ${w}::Priv

	set widgets {}
	set nodes {}

	foreach node [$w search {[htmlwidget]}] {
		lappend nodes $node
		lappend widgets [$node attr htmlwidget]
	}

	foreach widget $Priv(widgets) {
		if {$widget ni $widgets && [winfo exists $widget]} {
			destroy $widget
		}
	}

	foreach widget $widgets node $nodes {
		$node replace $widget -configurecmd [namespace code [list ConfigureWidget $widget]]
	}

	set Priv(widgets) $widgets
}


proc ConfigureWidget {w options} {
	array set opts $options

	if {[info exists opts(font)]} {
		catch { $w configure -font $opts(font) }
	}
	if {[info exists opts(color)]} {
		catch { $w configure -foreground $opts(color) }
	}
}


proc Place {w} {
	if {![winfo exists $w]} { return }

	variable [winfo parent $w]::Priv
	variable MaxWidth

	set width [winfo width $w]
	if {$width == 1} { return }
	set height [winfo height $w]
	lassign [$w.html visbbox] _ _ htmlWidth htmlHeight
	set xdelta [expr {max(0, ($width - $htmlWidth)/2)}]
	set ydelta [expr {max(0, ($height - $htmlHeight)/2)}]
	if {$ydelta > 0} { set height $htmlHeight }
	if {$xdelta > 0} { set width $htmlWidth }
	if {	$width < $htmlWidth
		|| $height < $htmlHeight
		|| $width != [$w.html cget -width]
		|| $height != [$w.html cget -height]} {
		$w.html configure -forcewidth 0 -width $width -height $height
	}
	place $w.html -x $xdelta -y $ydelta
	$w.html xview scroll 0 units
	$w.html yview scroll 0 units
}


proc Configure {parent width req} {
	variable ${parent}::Priv

	if {[winfo width $parent.sub.html] == $width} { return }

	# This (using the serial field from the event) is working under X11
	# to prevent endless loops. But does this work with windows and mac?
	if {$req == $Priv(request)} { return }
	set Priv(request) $req

	set wantedWidth [expr {max(1, $width - 2*$Priv(borderwidth) - [VsbWidth $parent])}]
	$parent.sub.html configure -width $wantedWidth
}


proc ConfigureFrame {parent sb visible} {
	variable ${parent}::Priv

	if {!$Priv(center) && [$sb cget -orient] eq "vertical"} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
		set width [$parent.sub.html cget -width]
		incr width [VsbWidth $parent.sub]
		Configure $parent $width 0
	}
}


proc VsbWidth {parent} {
	if {"$parent.v" ni [grid slaves $parent]} { return 0 }
	return [winfo width $parent.v]
}


proc ComputeBoundingBox {w node maxWidth} {
	variable MaxWidth
	variable Margin

	set tag [$node tag]
	set result {}

	if {[string length $tag] > 0} {
		switch -- $tag {
			html {}
			head { return $result }
			default {
				if {$tag ne "body"} {
					set bbox [$w bbox $node]
					if {[llength $bbox]} {
						if {[lindex $bbox 2] == $maxWidth - $Margin} { lset bbox 2 0 }
						set result $bbox
					}
				}
			}
		}
	}

	if {[llength $result] == 0 || [lindex $result 2] == 0} {
		foreach n [$node children] {
			set bbox [ComputeBoundingBox $w $n $maxWidth]
			if {[llength $bbox] > 0} {
				set result [CombineBox $result $bbox]
			}
		}
	}

	return $result
}


proc CombineBox {box1 box2} {
	if {[llength $box1] == 0} { return $box2 }
	if {[llength $box2] == 0} { return $box1 }

	lassign $box1 x11 y11 x12 y12
	lassign $box2 x21 y21 x22 y22

	return [list [min $x11 $x21] [min $y11 $y21] [max $x12 $x22] [max $y12 $y22]]
}


proc FindNearest {w ypos} {
	set node [$w node 5 5]
	if {[llength $node] == 0} { set node [$w node] }
	set bbox [$w bbox $node]
	if {[llength $bbox] == 0} { return $node }
	return [FindNearestNode $w $ypos [expr {abs([lindex $bbox 1] - $ypos)}] $node]
}


proc FindNearestNode {w ypos delta node} {
	set candidate $node
	foreach n [$node children] {
		set bbox [$w bbox $n]
		if {[llength $bbox]} {
			lassign $bbox _ y0 _ y1
			set d [expr {min(abs($y0 - $ypos), abs($y1 - $ypos))}]
			if {$d < $delta} {
				set candidate $n
				set delta $d
			}
		}
	}
	if {$candidate ne $node} {
		set candidate [FindNearestNode $w $ypos $delta $candidate]
	}
	return $candidate
}


proc GetInnerNode {w node} {
	set y0 [lindex [$w bbox $node] 1]

	foreach n [$node children] {
		set y1 [lindex [$w bbox $n] 1]
		if {$y1 == $y0} { return [GetInnerNode $w $n] }
	}

	return $node
}


proc SbSet {sb first last} {
	set parent [winfo parent $sb]
	set slaves [grid slaves $parent]
	::scrolledframe::sbset $sb $first $last
	if {$slaves ne [grid slaves $parent]} {
		ConfigureFrame $parent $sb [expr {$sb in [grid slaves $parent]}]
	}
}


proc Motion {w x y state} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {$state & 1} { SelectionExtend $w $x $y }

	set Priv(pointer) [list $x $y]
	if {$state >= 256} { return }

	set nodelist [lindex [$w node $x $y] end]
	if {$Priv(nodeList) eq $nodelist} { return }

	if {[llength $Priv(afterId)]} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
	}

	if {$Priv(delay)} {
		set Priv(afterId) [after $Priv(delay) [namespace code [list HandleMotion $w $nodelist]]]
	} else {
		HandleMotion $w $nodelist
	}
}


proc HandleMotion {w nodelist} {
	if {![winfo exists $w]} { return }

	variable [winfo parent [winfo parent $w]]::HoverNodes
	variable [winfo parent [winfo parent $w]]::Priv

	set Priv(nodeList) $nodelist
	set events(onmouseover) {}

	foreach node $nodelist {
		if {![catch { set tag [$node tag] }]} {
			if {[string length $tag] == 0} { set node [$node parent] }

			for {set n $node} {[string length $n] > 0} {set n [$n parent]} {
				if {[info exists hoverNodes($n)]} { break }

				if {[info exists HoverNodes($n)]} {
					array unset HoverNodes $n
				} else {
					lappend events(onmouseover) $n
				}

				set hoverNodes($n) 1
			}
		}
	}

	set events(onmouseout) [array names HoverNodes]

	array unset HoverNodes
	array set HoverNodes [array get hoverNodes]

	GenerateEvent $w onmouseout $events(onmouseout)
	GenerateEvent $w onmouseover $events(onmouseover)
}


proc Leave {w} {
	variable [winfo parent [winfo parent $w]]::HoverNodes
	variable [winfo parent [winfo parent $w]]::Priv

	if {[llength $Priv(afterId)]} {
		after cancel $Priv(afterId)
		set Priv(afterId) {}
	}

	GenerateEvent $w onmouseout [array names HoverNodes]
	array unset HoverNodes
}


proc Mapped {w} {
	lassign [winfo pointerxy $w] x y
	set x [expr {$x - [winfo rootx $w]}]
	set y [expr {$y - [winfo rooty $w]}]
	Motion $w $x $y 0
}


proc GenerateEvent {w event nodes} {
	variable [winfo parent [winfo parent $w]]::Priv

	set nodeList {}
	set emptyNode 0

	foreach node $nodes {
		if {[llength $node] == 0} {
			set emptyNode 1
		} elseif {[llength [info commands $node]] > 0} {
			lappend nodeList $node
		}
	}

	if {[llength $nodeList] || $emptyNode} {
		foreach script $Priv($event) { {*}$script $nodeList }
	}
}


proc ButtonPress {w x y k {state 0}} {
	variable [winfo parent [winfo parent $w]]::ActiveNodes$k
	variable [winfo parent [winfo parent $w]]::Priv

	if {$k == 1} { SelectionAnchor $w $x $y $state }

	array unset ActiveNodes$k
	array set ActiveNodes$k {}
	set node [lindex [$w node $x $y] end]
	if {[string length $node]  > 0 && [string length [$node tag]] == 0} { set node [$node parent] }
	if {[string length $node] == 0 || [string length [$node tag]] == 0} { set node [$w node] }

	for {set n $node} {[string length $n] > 0} {set n [$n parent]} {
		set ActiveNodes${k}($n) 1
	}

	GenerateEvent $w onmousedown${k} [array names ActiveNodes$k]
}


proc ButtonRelease {w x y k} {
	variable [winfo parent [winfo parent $w]]::ActiveNodes$k
	variable [winfo parent [winfo parent $w]]::Priv

	if {$k == 1} { SelectionFinish $w $x $y }

	set node [lindex [$w node $x $y] end]
	if {[string length $node]  > 0 && [string length [$node tag]] == 0} { set node [$node parent] }
	if {[string length $node] == 0 || [string length [$node tag]] == 0} { set node [$w node] }

	set nodeList [array names ActiveNodes$k]
	if {[llength $nodeList] == 0} { set nodeList {{}} }
	GenerateEvent $w onmouseup${k} $nodeList
	array unset ActiveNodes$k
}


proc SelectionAnchor {w x y state} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }

	if {($state & 1) && $Priv(sel:moved)} {
		set Priv(sel:to:node) ""
	} else {
		SelectionClear $w
	}

	set Priv(sel:state) true
	set Priv(sel:mode) char
	set Priv(sel:ignore) 0
	set Priv(sel:x) $x
	set Priv(sel:y) $y

	SelectionExtend $w $x $y
}


proc SelectionFinish {w x y} {
	variable [winfo parent [winfo parent $w]]::Priv
	set Priv(sel:state) false
}


proc SelectionExtend {w x y {node {}}} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }
	if {!$Priv(sel:state)} { return } ;# this may happen during a double click
	if {$Priv(sel:ignore)} { return }

	set to [$w node -index $x $y]
	lassign $to toNode toIdx

	if {[llength $node] > 0 && [llength $toNode] > 0} {
		if {[$node stacking] ne [$toNode stacking]} { set to {} }
	}

	if {[llength $to] > 0} {
		if {[llength $Priv(sel:from:node)] == 0} {
			set Priv(sel:from:node) $toNode
			set Priv(sel:from:index) $toIdx
		}

		if {	$toNode != $Priv(sel:from:node)
			|| $toIdx !=  $Priv(sel:from:index)
			|| abs($x - $Priv(sel:x)) >= 3
			|| abs($y - $Priv(sel:y)) >= 3} {
			set Priv(sel:moved) 1
		}

		set rc [catch {
			if {$Priv(sel:to:node) ne $toNode || $toIdx != $Priv(sel:to:index)} {
				if {$Priv(sel:moved)} {
					switch -- $Priv(sel:mode) {
						char {
							if {[llength $Priv(sel:to:node)] > 0} {
								$w tag remove selection $Priv(sel:to:node) $Priv(sel:to:index) $toNode $toIdx
							}
							$w tag add selection $Priv(sel:from:node) $Priv(sel:from:index) $toNode $toIdx
							if {$Priv(sel:from:node) ne $toNode || $Priv(sel:from:index) != $toIdx} {
								selection own $w
							}
						}

						word {
							if {[llength $Priv(sel:to:node)] > 0} {
								$w tag remove selection $Priv(sel:to:node) $Priv(sel:to:index) $toNode $toIdx
								SelectionUntagWord $w $Priv(sel:to:node) $Priv(sel:to:index)
							}

							$w tag add selection $Priv(sel:from:node) $Priv(sel:from:index) $toNode $toIdx
							SelectionTagWord $w $toNode $toIdx
							SelectionTagWord $w $Priv(sel:from:node) $Priv(sel:from:index)
							selection own $w
						}

						block {
							set toBlock2  [SelectionToBlock $w $toNode $toIdx]
							set fromBlock [SelectionToBlock $w $Priv(sel:from:node) $Priv(sel:from:index)]

							if {[llength $Priv(sel:to:node)] > 0} {
								set toBlock [SelectionToBlock $w $Priv(sel:to:node) $Priv(sel:to:index)]
								$w tag remove selection $Priv(sel:to:mode) $Priv(sel:to:index) $toNode $toIdx
								$w tag remove selection {*}$toBlock
							}

							$w tag add selection $Priv(sel:from:node) $Priv(sel:from:index) $toNode $toIdx
							$w tag add selection {*}$toBlock2
							$w tag add selection {*}$fromBlock
							selection own $w
						}
					}
				}

				set Priv(sel:to:node) $toNode
				set Priv(sel:to:index) $toIdx
			}
		} msg]

		if {$rc && [regexp {[^ ]+ is an orphan} $msg]} {
			SelectionClear $w
		}
	}

	lassign [$w viewbox] x0 y0 x1 y1
	lassign [$w visbbox] _ _ xmax ymax

	set motioncmd {}
	if {$y > $y1 - $y0} {
		if {$y1 < $ymax} {
			set motioncmd [list $w yview scroll 1 units]
		}
	} elseif {$y < 0} {
		if {$y0 > 0} {
			set motioncmd [list $w yview scroll -1 units]
		}
	}

	if {$motioncmd ne ""} {
		incr Priv(sel:ignore) 1
		{*}$motioncmd
		update idletasks
		after cancel $Priv(sel:afterid)
		set Priv(sel:afterid) [after 200 [namespace code [list SelectionContinueMotion $w]]]
	}

	if {$x > $x1 - $x0} {
		if {$x1 < $xmax} {
			set motioncmd [list $w xview scroll 1 units]
		}
	} elseif {$x < 0} {
		if {$x0 > 0} {
			set motioncmd [list $w xview scroll -1 units]
		}
	}

	if {$motioncmd ne ""} {
		incr Priv(sel:ignore) -1
		{*}$motioncmd
		update idletasks
		after cancel $Priv(sel:afterid)
		set Priv(sel:afterid) [after 100 [namespace code [list SelectionContinueMotion $w]]]
	}
}


proc SelectionContinueMotion {w} {
	if {![winfo exists $w]} { return }

	variable [winfo parent [winfo parent $w]]::Priv

	set Priv(sel:ignore) 0
	set Priv(sel:afterid) {}
	set x [expr [winfo pointerx $w] - [winfo rootx $w]]
	set y [expr [winfo pointery $w] - [winfo rooty $w]]
	set node [lindex [$w node $x $y] 0]
	SelectionExtend $w $x $y $node
}


proc Select {w x y mode} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }

	SelectionClear $w
	set Priv(sel:mode) $mode
	set Priv(sel:state) true
	set Priv(sel:moved) 1
	SelectionExtend $w $x $y
}


proc ExtendSelection {w x y mode} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }

	if {!$Priv(sel:moved)} { SelectionClear $w }

	set Priv(sel:to:node) ""
	set Priv(sel:mode) $mode
	set Priv(sel:state) true
	set Priv(sel:moved) 1

	SelectionExtend $w $x $y
}


proc SelectionClear {w} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return }

	$w tag delete selection
	$w tag configure selection \
		-foreground [$w cget -selectforeground] \
		-background [$w cget -selectbackground] \
		;
	set Priv(sel:from:node) ""
	set Priv(sel:to:node) ""
	set Priv(sel:moved) 0
	set Priv(sel:ignore) 0
	set Priv(sel:afterid) {}
}


proc SelectionTagWord {w node idx} {
	lassign [SelectionToWord $node $idx] i1 i2
	$w tag add selection $node $i1 $node $i2
}


proc SelectionUntagWord {w node idx} {
	lassign [SelectionToWord $node $idx] i1 i2
	$w tag remove selection $node $i1 $node $i2
}


proc SelectionToWord {node idx} {
	set t [$node text]
	set cidx [::tkhtml::charoffset $t $idx]
	set cidx1 [WordStart $t $cidx]
	set cidx2 [WordEnd $t $cidx]
	set idx1 [::tkhtml::byteoffset $t $cidx1]
	set idx2 [::tkhtml::byteoffset $t $cidx2]
	return [list $idx1 $idx2]
}


proc SelectionToBlock {w node idx} {
	set t [$w text text]
	set offset [$w text offset $node $idx]

	set start [string last "\n" $t $offset]
	if {$start < 0} {set start 0}
	set end [string first "\n" $t $offset]
	if {$end < 0} {set end [string length $t]}

	set startIdx [$w text index $start]
	set endIdx   [$w text index $end]

	return [concat $startIdx $endIdx]
}


proc SelectionGet {w offset maxChars} {
	variable [winfo parent [winfo parent $w]]::Priv

	set t  [$w text text]
	set n1 $Priv(sel:from:node)
	set i1 $Priv(sel:from:index)
	set n2 $Priv(sel:to:node)
	set i2 $Priv(sel:to:index)

	set stridxA [$w text offset $Priv(sel:from:node) $Priv(sel:from:index)]
	set stridxB [$w text offset $Priv(sel:to:node) $Priv(sel:to:index)]
	if {$stridxA > $stridxB} { lassign [list $stridxB $stridxA] stridxA stridxB }

	if {$Priv(sel:mode) eq "word"} {
		set stridxA [WordStart $t $stridxA]
		set stridxB [WordEnd $t $stridxB]
	}
	if {$Priv(sel:mode) eq "block"} {
		set stridxA [string last "\n" $t $stridxA]
		if {$stridxA < 0} {set stridxA 0}
		set stridxB [string first "\n" $t $stridxB]
		if {$stridxB < 0} {set stridxB [string length $t]}
	}

	set text [string range [$w text text] $stridxA [expr $stridxB - 1]]
	set text [string range $text $offset [expr $offset + $maxChars]]

	return $text
}


proc SelectionHandler {w args} {
	variable [winfo parent [winfo parent $w]]::Priv

	if {![$w cget -exportselection]} { return "" }
	set eval [concat SelectionGet $w $args]

	if {[catch [list uplevel $eval] result]} {
		set cmd [list bgerror $result]
		set error [list $::errorInfo $::errorCode]
		after idle [list lassign [list $error $cmd] ::errorInfo ::errorCode]
		set ::errorInfo ""
		return ""
	}

	return $result
}


proc WordStart {str index} {
	set index [string wordstart $str $index]

	# this is [string wordstart] but including zero width joiners
	while {	$index > 1
			&& (	[string index $str [expr {$index - 1}]] eq "\u200c"
				|| [string index $str [expr {$index - 1}]] eq "\u200d")} {
		set index [string wordstart $str [expr {$index - 2}]]
	}

	return $index
}


proc WordEnd {str index} {
	set index [string wordend $str $index]

	# this is [string wordend] but including zero width joiners
	while {	$index < [string length $str]
			&& (	[string index $str $index] eq "\u200c"
				|| [string index $str $index] eq "\u200d")} {
		set index [string wordend $str [expr {$index + 1}]]
	}

	return $index
}


proc WrapMotion {w x y args} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	Motion [winfo parent $w] $x $y {*}$args
}


proc WrapButtonPress {w x y args} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	ButtonPress [winfo parent $w] $x $y {*}$args
}


proc WrapButtonRelease {w x y args} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	ButtonRelease [winfo parent $w] $x $y {*}$args
}


proc WrapSelect {w x y args} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	Select [winfo parent $w] $x $y {*}$args
}


proc WrapExtendSelection {w x y args} {
	incr x [winfo x $w]
	incr y [winfo y $w]
	ExtendSelect [winfo parent $w] $x $y {*}$args
}


proc WrapLeave {w}	{ Leave [winfo parent $w] }
proc WrapMapped {w}	{ Mapped [winfo parent $w] }


proc Scroll {w units {state 0}} {
	variable ::util::shiftMask

	set w [winfo parent $w]

	if {[expr {($state & $shiftMask) != 0}]} {
		$w xview scroll $units units
	} else {
		$w yview scroll $units units
	}
}


proc FrameWrapButtonPress {w k} {
	GenerateEvent $w.html onmousedown${k} {{}}
}


proc FrameWrapButtonRelease {w k} {
	GenerateEvent $w.html onmouseup${k} {{}}
}


# IMPORTANT NOTE: we have to wrap all events to the parent window.

bind Html <Motion>				[namespace code { WrapMotion %W %x %y %s }]
bind Html <Leave>					[namespace code { WrapLeave %W }]
bind Html <ButtonPress-1>		[namespace code { WrapButtonPress %W %x %y 1 %s }]
bind Html <ButtonRelease-1>	[namespace code { WrapButtonRelease %W %x %y 1 }]
bind Html <ButtonPress-2>		[namespace code { WrapButtonPress %W %x %y 2 }]
bind Html <ButtonRelease-2>	[namespace code { WrapButtonRelease %W %x %y 2 }]
bind Html <ButtonPress-3>		[namespace code { WrapButtonPress %W %x %y 3 }]
bind Html <ButtonRelease-3>	[namespace code { WrapButtonRelease %W %x %y 3 }]
bind Html <Unmap>					[namespace code { WrapLeave %W }]
bind Html <Map>					[namespace code { WrapMapped %W }]

bind Html <Double-ButtonPress-1>			[namespace code { WrapSelect %W %x %y word }]
bind Html <Triple-ButtonPress-1>			[namespace code { WrapSelect %W %x %y block }]
bind Html <Shift-Double-ButtonPress-1>	[namespace code { WrapExtendSelection %W %x %y word }]
bind Html <Shift-Triple-ButtonPress-1>	[namespace code { WrapExtendSelection %W %x %y block }]

switch [tk windowingsystem] {
	win32 {
		bind Html <MouseWheel> [namespace code [list Scroll %W {[expr {(%D/-120)*4}]} %s]]
		bind Html <MouseWheel> {+ break }
	}
	aqua {
		bind Html <MouseWheel> [namespace code [list Scroll %W [expr {-(%D)}] %s]]
		bind Html <MouseWheel> {+ break }
	}
	x11 {
		bind Html <ButtonPress-4> [namespace code [list Scroll %W -5 %s]]
		bind Html <ButtonPress-4> {+ break }
		bind Html <ButtonPress-5> [namespace code [list Scroll %W +5 %s]]
		bind Html <ButtonPress-5> {+ break }
	}
}

bind _HTML_Frame_ <ButtonPress-3>   [namespace code { FrameWrapButtonPress %W 3 }]
bind _HTML_Frame_ <ButtonRelease-3>	[namespace code { FrameWrapButtonRelease %W 3 }]

} ;# namespace html

# vi:set ts=3 sw=3:
