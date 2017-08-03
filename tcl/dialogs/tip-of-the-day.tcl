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
# Copyright: (C) 2013-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source tip-of-the-day-dialog

namespace eval tips {
namespace eval mc {

set TipOfTheDay			"Tip of the Day"
set FurtherInformation	"Further information"
set CouldNotOpenFile		"Could not open file %s."
set CouldNotFindAnyTip	"Could not find any tip."
set RepeatAllTips			"Repeat all tips (restart from the beginning)"
set NextTip					"Next Tip" ;# Unused
set FirstTip				"<p>The Tip-of-the-Day information serves to a better insight into the functioning of this application. Furthermore it will give useful hints that will help to know what is possible.</p><p color='darkgreen'><b>Have joy with Scidb!</b></p>"

set Choice(everytime)				"Show everytime"
set Choice(periodically)			"Show periodically"
set Choice(everytimeWhenNew)		"Show everytime, but only new tips"
set Choice(periodicallyWhenNew)	"Show periodically, but only new tips"
set Choice(neverShow)				"Don't show anymore"

} ;# namespace mc

array set Options {
	firstTime	1
	textalign	justify
	mode			periodicallyWhenNew
	lastDay		0
	counter		3
	history		{}
	motives		{}
}


proc open {parent} {
	variable Options
	variable Priv

	set dlg .tipoftheday
	if {[winfo exists $dlg]} {
		::widget::dialogRaise $dlg
		return $dlg
	}

	set Options(lastDay) [::scidb::misc::julianDay]
	set Options(counter) 3
	::scidb::misc::html cache on
	Setup

	tk::toplevel $dlg -class Scidb
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm withdraw $dlg

	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	::font::html::setupFonts tips
	set css [DefaultCSS]
	append css "div.body { margin-left: 140px; }\n"
	append css "div.title { margin-left: 0; }\n"
	append css "ol { padding-left: 5px; }\n"
	append css "ul { padding-left: 5px; }\n"
	set html $top.html

	::html $html \
		-imagecmd [namespace code GetImage] \
		-center yes \
		-fittowidth yes \
		-fittoheight yes \
		-borderwidth 1 \
		-relief sunken \
		-doublebuffer yes \
		-exportselection yes \
		-css $css \
		-showhyphens 1 \
		-fontsize [::font::html::fontSize tips] \
		-textalign $Options(textalign) \
		-importdir [file join $::scidb::dir::help $Priv(lang)] \
		-width 560 \
		-usevertscroll no \
		-usehorzscroll no \
		;
	pack $html -fill both -expand yes

	$html handler node a [namespace current]::A_NodeHandler

	$html onmouseover [namespace current]::MouseEnter
	$html onmouseout  [namespace current]::MouseLeave
	$html onmouseup1  [namespace current]::Mouse1Up

	set Priv(html) $html

	bind $dlg <Control-Shift-N> [namespace code ShowNextTip] ;# developer only
	bind $dlg <Control-Shift-I> [namespace code ShowNextImage] ;# developer only
	bind $top <Destroy> [list ::scidb::misc::html cache off]

	set Priv(mode) $mc::Choice($Options(mode))
	set options [ttk::combobox $dlg.options \
		-textvariable [namespace current]::Priv(mode) \
		-state readonly \
		-width 32 \
		-justify center \
	]
	bind $options <<LanguageChanged>> [namespace code { LanguageChanged %W }]
	bind $options <<ComboboxSelected>> [namespace code { SetChoice %W }]
	FillCombobox $options

	::widget::dialogButtons $dlg {close} -alignment right
#	::widget::dialogButtons $dlg {revert} -alignment right -side left -position start
#	::widget::dialogButtonAdd $dlg next [namespace current]::mc::NextTip {} -justify right -position start
	::widget::dialogButtonsPack $options -justify left -position start
	$dlg.close configure -command [list destroy $dlg]
#	$dlg.revert configure -command [namespace code [list RepeatAllTips]]
#	$dlg.next configure -command [namespace code [list ShowNextTip]]
#	::tooltip::tooltip $dlg.revert [namespace current]::mc::RepeatAllTips

	ShowNextTip

	wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
	wm resizable $dlg no no
	wm title $dlg $mc::TipOfTheDay
	::util::place $dlg -position center -parent $parent
	wm deiconify $dlg
	return $dlg
}


proc show {parent} {
	variable Options
	variable Priv

	if {$Options(mode) eq "neverShow"} { return }

	Setup

	if {!$Options(firstTime)} {
		if {[string match periodically* $Options(mode)]} {
			if {$Options(counter) > 0 && [incr Options(counter) -1] > 0} { return }
			if {$Options(lastDay) + 7 > [::scidb::misc::julianDay]} { return }
		}
	}

	if {[llength [FindTips]] == 0} {
		if {[string match *WhenNew $Options(mode)]} { return }
	}

	after 100 [namespace code [list open $parent]]
}


proc Setup {} {
	variable Priv

	if {![info exists Priv(lang)]} {
		set Priv(lang) $::mc::langID
		set Priv(file) [file join $::scidb::dir::help $Priv(lang) Tip-of-the-Day.html]
		if {![file readable $Priv(file)]} {
			set Priv(lang) en
			set Priv(file) [file join $::scidb::dir::help en Tip-of-the-Day.html]
		}
		set Priv(tips) {}
		set Priv(new-tips) {}
		set Priv(html-header) ""
		set Priv(html-trailer) ""
	}
}


proc LanguageChanged {cb} {
	variable Priv

	unset Priv(lang)
	Setup
	FillCombobox $cb
}


proc FillCombobox {cb} {
	set index [$cb current]
	set values {}
	foreach what {everytime periodically everytimeWhenNew periodicallyWhenNew neverShow} {
		lappend values $mc::Choice($what)
	}
	$cb configure -values $values
	if {$index >= 0} { $cb current $index }
}


proc SetChoice {cb} {
	variable Options
	variable Priv

	foreach what {everytime periodically everytimeWhenNew periodicallyWhenNew neverShow} {
		if {$mc::Choice($what) eq [$cb get]} {
			set Options(mode) $what
			return
		}
	}
}


proc ShowNextTip {} {
	variable Links
	variable ExternalLinks
	variable Options
	variable Priv

	if {$Options(firstTime)} {
		FindTips
		set content $Priv(html-header)
		append content "<div class='body'>"
		append content $mc::FirstTip
		append content "\n</div>"
		append content $Priv(html-trailer)
	} else {
		set number [FindNextTip]

		if {$number == -1} {
			if {[string length $Priv(html-header)] == 0} {
				set error [format $mc::CouldNotOpenFile $Priv(file)]
			} else {
				set error $mc::CouldNotFindAnyTip
			}
			append content "<h2><span color='darkred'>$error</span></h2><p>_</p>"
		} else {
			set content $Priv(html-header)
			append content $Priv($number)
			append content $Priv(html-trailer)
		}
	}

	array set Links {}
	array set ExternalLinks {}

	set Priv(content) [::html::hyphenate $Priv(lang) $content]
	$Priv(html) parse $Priv(content)
	set Options(firstTime) 0
}


proc ShowNextImage {} {
	variable Priv

	unset Priv(motive)
	$Priv(html) parse $Priv(content)
}


proc FindNextTip {} {
	variable Options
	variable Priv

	if {[llength [FindTips]] == 0} {
		set Priv(new-tips) $Priv(tips)
		set Options(history) {}
	}

	if {[llength $Priv(new-tips)] == 0} {
		return -1
	}

	set number [lindex $Priv(new-tips) 0]
	set Priv(new-tips) [lreplace $Priv(new-tips) 0 0]

	if {$number ni $Options(history)} {
		lappend Options(history) $number
	}

	return $number
}


proc FindTips {} {
	variable Options
	variable Priv

	if {[llength $Priv(tips)] == 0} {
		set content ""
		catch {
			set fd [::open $Priv(file) r]
			chan configure $fd -encoding utf-8
			set content [read $fd]
			close $fd
		}

		set dest Priv(html-header)
		set number "000"
		set level 0

		foreach line [split $content \n] {
			if {[string index $line 0] ne "#"} {
				if {[string match {<TIP number="???" level="?">*} $line]} {
					set number [string range $line 13 15]
					set level [string index $line 25]
					set tip "<div class='body'>\n"
					set dest tip
				} elseif {[string match {</TIP>*} $line]} {
					append tip "</div>\n"
					set Priv($number) $tip
					lappend section($level) $number
					set dest ""
				} elseif {[string match {*</body>*} $line]} {
					set dest Priv(html-trailer)
					append  Priv(html-trailer) $line \n
				} elseif {[string match {*<h1 class=\"title\">*} $line]} {
					set subst {{<h1 class="title">} {<h1 class='title'><img src='motive' align='left'/>}}
					set line [string map $subst $line]
					append Priv(html-header) $line \n
				} elseif {[string length $dest]} {
					append $dest $line \n
				}
			}
		}

		foreach level [lsort -integer [array names section]] {
			foreach number $section($level) {
				lappend Priv(tips) $number
				if {$number ni $Options(history)} {
					lappend Priv(new-tips) $number
				}
			}
		}
	}

	return $Priv(new-tips)
}


proc RepeatAllTips {} {
	variable Options
	variable Priv

	set Options(firstTime) 1
	set Options(lastDay) 0
	set Options(counter) 4
	set Options(history) {}

	ShowNextTip
}


proc GetNextMotiveFile {} {
	variable Options
	variable Priv

	if {$Options(firstTime)} { return [file join $::scidb::dir::images Scidb-Logo-128.png] }

	while {1} {
		if {[llength $Options(motives)] == 0} {
			set Options(motives) \
				[glob -nocomplain -directory $::scidb::dir::images -types f -tails Motive-*.*]
			lappend Options(motives) Scidb-Logo-128.png
		}
		set rand [expr {min([llength $Options(motives)] - 1, int(rand()*[llength $Options(motives)]))}]
		set file [lindex $Options(motives) $rand]
		set Options(motives) [lreplace $Options(motives) $rand $rand]
		set Priv(motive) [file join $::scidb::dir::images $file]
		if {[file readable $Priv(motive)]} { return $Priv(motive) }
	}
}


proc FindMotiveFile {} {
	variable Priv

	if {![info exists Priv(motive)]} { set Priv(motive) [GetNextMotiveFile] }
	return $Priv(motive)
}


proc FullPath {file} {
	variable Priv

	if {[string length $file] == 0} { return "" }
	if {[string length [file extension $file]] == 0} { append file .html }
	return [file normalize [file join $::scidb::dir::help $Priv(lang) $file]]
}


proc MouseEnter {nodes} {
	variable Nodes
	variable Priv

	foreach node $nodes {
		if {[info exists Nodes($node)]} {
			$node dynamic set hover
			ttk::setCursor [$Priv(html) drawable] link
		}
	}
}


proc MouseLeave {nodes} {
	variable Nodes
	variable Priv

	foreach node $nodes {
		if {[info exists Nodes($node)]} {
			$node dynamic clear hover
			ttk::setCursor [$Priv(html) drawable] {}
		}
	}
}


proc Mouse1Up {nodes} {
	variable Nodes
	variable Links
	variable ExternalLinks
	variable Priv

	foreach node $nodes {
		if {[info exists Nodes($node)]} {
			set Nodes($node) 1
			$node dynamic clear link
			$node dynamic set visited

			set href [$node attribute -default {} href]

			if {[::web::isExternalLink $href]} {
				::web::open $Priv(html) $href
				set ExternalLinks($href) 1
			} elseif {[string length $href]} {
				lassign [split $href \#] file fragment
				set Links($file) [::help::open .application $href]
			}
		}
	}
}


proc A_NodeHandler {node} {
	variable Nodes
	variable Links
	variable ExternalLinks

	set href [$node attribute -default {} href]

	if {[::web::isExternalLink $href]} {
		$node dynamic set user
		$node attribute class external

		if {[info exists ExternalLinks($href)]} {
			$node dynamic clear link
			$node dynamic set user2
		}
	} else {
		$node dynamic set link

		if {[string length $href]} {
			set file [FullPath $href]
			if {[info exists Links($file)]} {
				$node dynamic set visited
			}
		}
	}

	set Nodes($node) 0
}


proc DefaultCSS {} {
	set fixedFonts [::font::html::defaultFixedFonts tips]
	set textFonts [::font::html::defaultTextFonts tips]
	return [::html::defaultCSS $fixedFonts $textFonts]
}


proc GetImage {file} {
	variable Options
	variable Priv

	if {$file eq "motive"} { set file [FindMotiveFile] }

	set file [file join $::scidb::dir::help $Priv(lang) $file]

	if {[catch { set img [image create photo -file $file] }]} {
		set src $::help::icon::16x16::broken
		set img [image create photo -width [image width $src] -height [image height $src]]
		$img copy $src
	}

	return $img
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace tips

# vi:set ts=3 sw=3:
