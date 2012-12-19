## ======================================================================
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
# Copyright: (C) 2011-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source help-dialog

namespace eval help {
namespace eval mc {

set Contents					"&Contents"
set Index						"&Index"
set Search						"&Search"

set Help							"Help"
set MatchEntireWord			"Match entire word"
set MatchCase					"Match case"
set TitleOnly					"Search in titles only"
set CurrentPageOnly			"Search in current page only"
set GoBack						"Go back one page"
set GoForward					"Go forward one page (Alt-Right)"
set GotoPage					"Go to page '%s'"
set ExpandAllItems			"Expand all items"
set CollapseAllItems			"Collapse all items"
set SelectLanguage			"Select Language"
set KeepLanguage				"Keep language %s for subsequent sessions?"
set NoHelpAvailable			"No help files available for language English.\nPlease choose an alternative language\nfor the help dialog."
set NoHelpAvailableAtAll	"No help files available for this topic."
set ParserError				"Error while parsing file %s."
set NoMatch						"No match is found"
set MaxmimumExceeded			"Maximal number of matches exceeded in some pages."
set OnlyFirstMatches			"Only first %s matches per page will be shown."
set HideIndex					"Hide index"
set ShowIndex					"Show index"

set FileNotFound				"File not found."
set CantFindFile				"Can't find the file at %s."
set IncompleteHelpFiles		"It seems that the help files are still incomplete. Sorry about that."
set ProbablyTheHelp			"Probably the help page in a different language may be an alternative for you"
set PageNotAvailable			"This page is not available"

} ;# namespace mc

variable Geometry {}
variable Lang {}

array set Colors {
	foreground:gray		#999999
	foreground:litegray	#696969
	background:gray		#f5f5f5
	background:emphasize	lightgoldenrod
}

# we will not use latin ligatures because they are looking bad with some fonts
array set Priv {
	tab				contents
	matchCase		no
	entireWord		no
	titleOnly		no
	currentOnly		no
	latinligatures	no
}


proc helpLanguage {} {
	variable Lang

	if {[string length $Lang]} { return $Lang }
	return $::mc::langID
}


proc open {parent {file {}} args} {
	variable Priv
	variable Links
	variable ExternalLinks
	variable Geometry

	array set opts {
		-transient	no
		-parent		{}
	}
	array set opts $args
	if {[llength $opts(-parent)] == 0} { set opts(-parent) $parent }

	set Priv(check:lang) [CheckLanguage $opts(-parent) $file]
	if {$Priv(check:lang) eq "none"} { return "" }

	if {[string length $file] == 0} {
		set Priv(current:file) ""
		set Priv(current:lang) [helpLanguage]
	} elseif {[file extension $file] ne ".html"} {
		append file .html
	}

	set dlg .help
	if {[winfo exists $dlg]} {
		if {[string length $file] == 0} { ShowIndex }
		raise $dlg
		focus $dlg
		set Priv(current:file) [FullPath $file]
		set Priv(current:lang) [helpLanguage]
		ReloadCurrentPage
		return $dlg
	}

	array unset Links
	array unset ExternalLinks
	array set Links {}
	array set ExternalLinks {}

	set Priv(topic) ""
	set Priv(dlg) $dlg
	set Priv(minsize) 260
	set Priv(recent) {}
	set Priv(grab) {}

	::scidb::misc::html cache on

	tk::toplevel $dlg -class Scidb
	wm protocol $dlg WM_DELETE_WINDOW [namespace code Destroy]
	wm withdraw $dlg

	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	set pw [tk::panedwindow $top.pw -orient horizontal]
	::theme::configurePanedWindow $top.pw
	pack $pw -expand yes -fill both

	### Left side ########################################
	set control [ttk::frame $pw.control]
	set Priv(control) $control

	set buttons [ttk::frame $control.buttons]
	ttk::button $buttons.back \
		-image [::icon::makeStateSpecificIcons $::icon::16x16::controlBackward] \
		-command [namespace code GoBack] \
		-state disabled \
		;
	set Priv(button:back) $buttons.back
	ttk::button $buttons.forward \
		-image [::icon::makeStateSpecificIcons $::icon::16x16::controlForward] \
		-command [namespace code GoForward] \
		-state disabled \
		;
	ttk::button $buttons.expand \
		-image [::icon::makeStateSpecificIcons $::treetable::icon::16x16::collapse] \
		-command [namespace code ExpandAllItems] \
		;
	set Priv(button:collapse) $buttons.collapse
	::tooltip::tooltip $buttons.expand [namespace current]::mc::ExpandAllItems
	ttk::button $buttons.collapse \
		-image [::icon::makeStateSpecificIcons $::treetable::icon::16x16::expand] \
		-command [namespace code CollapseAllItems] \
		;
	set Priv(button:expand) $buttons.expand
	::tooltip::tooltip $buttons.collapse [namespace current]::mc::CollapseAllItems
	set Priv(button:forward) $buttons.forward
	grid $buttons.expand   -row 1 -column 1
	grid $buttons.collapse -row 1 -column 3
	grid $buttons.back     -row 1 -column 5
	grid $buttons.forward  -row 1 -column 7
	grid columnconfigure $buttons {0 2 4 6 8} -minsize $::theme::padding
	grid columnconfigure $buttons 4 -weight 1
	grid rowconfigure $buttons {0 2} -minsize $::theme::padding

	set nb [ttk::notebook $control.nb -takefocus 1 -width 320]
	::ttk::notebook::enableTraversal $nb
	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb]]
	contents::BuildFrame $nb.contents
	index::BuildFrame $nb.index
	search::BuildFrame $nb.search
	$nb add $nb.contents -sticky nsew -padding $::theme::padding
	$nb add $nb.index -sticky nsew -padding $::theme::padding
	$nb add $nb.search -sticky nsew -padding $::theme::padding
	::widget::notebookTextvarHook $nb 0 [namespace current]::mc::Contents
	::widget::notebookTextvarHook $nb 1 [namespace current]::mc::Index
	::widget::notebookTextvarHook $nb 2 [namespace current]::mc::Search

	grid $buttons -row 1 -column 1 -sticky we
	grid $nb      -row 3 -column 1 -sticky nsew
	grid columnconfigure $control 1 -weight 1
	grid rowconfigure $control 3 -weight 1
	grid rowconfigure $control 2 -minsize $::theme::padding

	bind $dlg <Alt-Left>			[namespace code GoBack]
	bind $dlg <Alt-Right>		[namespace code GoForward]
	bind $dlg <ButtonPress-3>	[namespace code [list PopupMenu $dlg $pw.control]]

	bind $nb <<LanguageChanged>> [namespace code Update]
	$nb select $nb.$Priv(tab)

	### Right side #######################################
	set html $pw.html
	set Priv(html) $html
	BuildHtmlFrame $dlg $html

	if {[string length $file] == 0} {
		$pw add $control -sticky nswe -stretch never -minsize $Priv(minsize)
	}
	$pw add $html -sticky nswe -stretch always -minsize 500

	bind $dlg <Configure> [namespace code [list RecordGeometry $pw]]

#	switch [tk windowingsystem] {
#		win32 - aqua {
#			bind $dlg <MouseWheel> [list event generate $html <MouseWheel> -delta %D]
#		}
#		x11 {
#			bind $dlg <ButtonPress-4> [list event generate $html <ButtonPress-4>]
#			bind $dlg <ButtonPress-5> [list event generate $html <ButtonPress-5>]
#		}
#	}

	if {$opts(-transient)} {
		wm transient $dlg [winfo toplevel $parent]
	}
	wm minsize $dlg 600 300
	if {[string length $file] == 0} {
		if {[llength $Geometry] == 0} {
			update idletasks
			set Geometry [winfo reqwidth $dlg]x[winfo reqheight $dlg]
			focus $Priv($Priv(tab):tree)
		}
		wm geometry $dlg $Geometry
	} else {
		::util::place $dlg center $parent
	}

	if {[string length $file]} {
		set Priv(current:file) [FullPath $file]
		set Priv(current:lang) [helpLanguage]
	}
	ReloadCurrentPage
	wm deiconify $dlg
	return $dlg
}


proc FullPath {file} {
	variable Priv

	if {[string length $file] == 0} { return "" }
	if {[string length [file extension $file]] == 0} { append file ".html" }
	if {[string match ${::scidb::dir::help}* $file]} { return $file }

	if {[file extension $file] eq ".html"} {
		set lang [helpLanguage]
	} elseif {[info exists Priv(current:lang)]} {
		set lang $Priv(current:lang)
	} else {
		set lang [helpLanguage]
	}
	return [file normalize [file join $::scidb::dir::help $lang $file]]
}


proc CheckLanguage {parent helpFile} {
	variable Lang
	variable ::country::icon::flag

	if {[string length $helpFile] > 0 && ![string match *.html $helpFile]} {
		append helpFile .html
	}

	set rc "temporary"

	if {[llength $helpFile] == 0} {
		set helpFile Contents.dat
		set rc "substitution"
	}

	set lang $::mc::langID
	set file [file normalize [file join $::scidb::dir::help $lang $helpFile]]
	if {[file readable $file]} {
		set Lang {}
		return "found"
	}

	if {[string length $Lang]} {
		set file [file normalize [file join $::scidb::dir::help $Lang $helpFile]]
		if {[file readable $file]} { return "found" }
	}

	set codes {}
	foreach lang [lsort [array names ::mc::input]] {
		if {[string length $lang]} {
			set code [set ::mc::lang$lang]
			set file [file normalize [file join $::scidb::dir::help $code $helpFile]]
			if {[file readable $file]} { lappend codes $code }
		}
	}

	if {[llength $codes] == 0} {
		::dialog::info -parent $parent -message $mc::NoHelpAvailableAtAll
		return "none"
	}

	set Lang {}
	set dlg $parent.lang
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top
	ttk::label $top.msg -text $mc::NoHelpAvailable
	pack $top.msg -side top -padx $::theme::padx -pady $::theme::pady
	set focus ""
	foreach code $codes {
		set icon ""
		catch { set icon $flag([set ::mc::langToCountry($code)]) }
		if {[string length $icon] == 0} { set icon none }
		ttk::button $top.$code \
			-style aligned.TButton \
			-text " $::encoding::mc::Lang($code)" \
			-image $icon \
			-compound left \
			-command [namespace code [list SetupLang $code]] \
			;
		pack $top.$code -side top -padx $::theme::padx -pady $::theme::pady
		bind $top.$code <Return> { event generate %W <Key-space>; break }
	}
	::widget::dialogButtons $dlg cancel
	$dlg.cancel configure -command [list destroy $dlg]
	wm resizable $dlg no no
	wm title $dlg $mc::SelectLanguage
	::util::place $dlg center $parent
	wm deiconify $dlg
	update idletasks
	focus $dlg.cancel
	::ttk::grabWindow $dlg
	vwait [namespace current]::Lang
	::ttk::releaseGrab $dlg
	catch { destroy $dlg }

	if {[string length $Lang] == 0} { return "none" }
	return $rc
}


proc SetupLang {code} {
	set [namespace current]::Lang $code
}


proc Destroy {} {
	variable Priv
	variable Lang

	if {$Priv(check:lang) eq "substitution"} {
		set language $::encoding::mc::Lang($Lang)
		set reply [::dialog::question -parent $Priv(dlg) -message [format $mc::KeepLanguage $language]]
		if {$reply eq "no"} { set Lang "" }
	} elseif {$Priv(check:lang) eq "temporary"} {
		set Lang ""
	}

	destroy $Priv(dlg)
	::scidb::misc::html cache off
}


namespace eval contents {

proc BuildFrame {w} {
	variable [namespace parent]::Priv

	::treetable $w -takefocus 1 -showarrows 1 -borderwidth 1 -relief sunken -showlines no

	set Priv(contents:changed) 0
	set Priv(contents:tree) $w

	bind $w <<TreeTableSelection>> [namespace code [list LoadPage %d]]
	bind $w <Alt-Left>	[namespace parent]::GoBack
	bind $w <Alt-Right>	[namespace parent]::GoForward
	bind $w <Alt-Left>	{+ break }
	bind $w <Alt-Right>	{+ break }

	Update
}


proc FillContents {t contents {depth 0}} {
	variable [namespace parent]::Colors
	variable [namespace parent]::icon::16x16::library
	variable [namespace parent]::icon::16x16::document
	variable [namespace parent]::icon::16x16::bookClosed
	variable [namespace parent]::icon::16x16::bookOpen
	variable [namespace parent]::Priv

	set g 0
	foreach group $contents {
		set e 0
		set d $depth
		foreach entry $group {
			if {[llength $entry] == 1} {
				set topic [lindex $entry 0]
				set enabled yes
				set collapse no
				set tag "$d-$g-$e"
				if {[llength $topic] > 0} {
					set file [[namespace parent]::FullPath [lindex $topic 1]]
					if {![file readable $file]} {
						set enabled no
					} elseif {[llength $topic] > 2} {
						set Priv(uri:$tag) [::tkhtml::uri $file#[lindex $topic 2]]
					} else {
						set Priv(uri:$tag) [::tkhtml::uri $file]
					}
				}
				set title [lindex $topic 0]
				set icon ""
				if {[llength $topic] == 2} {
					set Priv(topic:$file) $title
					if {$d == 0} { set icon $library } else { set icon $document }
				} else {
					set collapse yes
					set icon [list $bookClosed {!open} $bookOpen {open}]
				}
				$t add $d \
					-text $title \
					-icon $icon \
					-enabled $enabled \
					-collapse $collapse \
					-tag $tag \
					;
				if {[llength $topic] != 2} { incr d }
			} else {
				FillContents $t $entry [expr {$depth + 1}]
			}
			incr e
		}
		incr g
	}
}


proc FilterContents {contents exclude} {
	set result {}

	foreach group $contents {
		set newGroup {}
		foreach entry $group {
			if {[llength $entry] == 1} {
				set file [lindex $entry 0 1]
				if {$file ni $exclude} {
					lappend newGroup $entry
				}
			} else {
				lappend newGroup [FilterContents $contents $exclude]
			}
		}
		lappend result $newGroup
	}

	return $result
}


proc Update {} {
	global tcl_platform
	variable [namespace parent]::Priv
	variable [namespace parent]::Contents

	set Contents {}
	set file [[namespace parent]::FullPath Contents.dat]
	if {![file readable $file]} { return [[namespace parent]::Destroy] }
	catch { source -encoding utf-8 $file }
	foreach name [array names Priv uri:*] { $Priv($name) destroy }
	if {$tcl_platform(platform) ne "unix"} {
		set Contents [FilterContents $Contents $UnixOnly]
	}
	array unset Priv uri:*
	set t $Priv(contents:tree)
	$t clear
	FillContents $t $Contents
	catch { $t activate 1 }
}


proc LoadPage {item} {
	variable [namespace parent]::Priv
	variable [namespace parent]::Links
	variable [namespace parent]::ExternalLinks

	if {[info exists Priv(uri:$item)]} {
		set path [$Priv(uri:$item) path]

		if {[string match http* $path] || [string match ftp* $path]} {
			::web::open $Priv(html) $path
			set ExternalLinks($path) 1
		} else {
			set fragment [$Priv(uri:$item) fragment]
			set Links($path) [[namespace parent]::Load $path {} {} $fragment]
		}
	}
}

} ;# namespace contents

namespace eval index {

proc BuildFrame {w} {
	variable [namespace parent]::Priv

	set Priv(index:changed) 0
	set Priv(index:tree) $w
	::treetable $w -takefocus 1 -showarrows 0 -borderwidth 1 -relief sunken -showlines no
	bind $w <<TreeTableSelection>> [namespace code [list LoadPage %d]]
	bind $w <Any-KeyPress> [namespace code { Select %W %A }]
	Update
}


proc Update {} {
	variable [namespace parent]::Priv

	set t $Priv(index:tree)
	if {![winfo exists $t]} { return }

	set Index {}
	set file [[namespace parent]::FullPath Index.dat]
	if {![file readable $file]} { return }
	catch { source -encoding utf-8 $file }
	$t clear
	set font [$t cget -font]
	set bold [list [list [font configure $font -family] [font configure $font -size] bold]]
	array unset Priv index:path:*
	array unset Priv key:*

	foreach group $Index {
		lassign $group alph entries

		$t add 0 -text $alph -fill red4 -font $bold -enabled no -tag $alph -collapse no
		set count 0

		foreach entry $entries {
			lassign $entry topic file fragment
			set tag "$alph-$count"
			$t add 1 -text $topic -tag $tag
			set path [[namespace parent]::FullPath $file]
			set Priv(index:path:$tag) [list $path $fragment]
			if {$count == 0} { set Priv(key:$alph) $tag }
			incr count
		}
	}

	catch { $t activate 2 }
}


proc LoadPage {item} {
	variable [namespace parent]::Priv

	if {[string length $item] == 0} { return }
	lassign $Priv(index:path:$item) path fragment

	if {[string match http* $path] || [string match ftp* $path]} {
		::web::open $Priv(html) $path
	} else {
		[namespace parent]::Load $path {} {} $fragment
	}
}


proc Select {t key} {
	variable [namespace parent]::Priv

	set key [string toupper $key]

	if {[info exists Priv(key:$key)]} {
		set item $Priv(key:$key)
		$t activate $item
		$t see $item
	}
}

} ;# namespace index

namespace eval search {

proc BuildFrame {w} {
	variable [namespace parent]::Priv

	set Priv(search:entry) ""
	set Priv(search:changed) 0

	ttk::frame $w -takefocus 0
	set top [ttk::frame $w.top -takefocus 0]
	set bot $w.bot

	### Top Frame ###########################################
	ttk::entry $top.search \
		-textvariable [namespace parent]::Priv(search:entry) \
		-takefocus 1 \
		-exportselection no \
		-cursor xterm \
		;
	set Priv(search) $top.search

	ttk::checkbutton $top.entire \
		-textvariable [namespace parent]::mc::MatchEntireWord \
		-variable [namespace parent]::Priv(entireWord) \
		;
	ttk::checkbutton $top.case \
		-textvariable [namespace parent]::mc::MatchCase \
		-variable [namespace parent]::Priv(matchCase) \
		;
	ttk::checkbutton $top.title \
		-textvariable [namespace parent]::mc::TitleOnly \
		-variable [namespace parent]::Priv(titleOnly) \
		;
	ttk::checkbutton $top.current \
		-textvariable [namespace parent]::mc::CurrentPageOnly \
		-variable [namespace parent]::Priv(currentOnly) \
		;

	grid $top.search  -row 0 -column 0 -sticky ew
	grid $top.entire  -row 2 -column 0 -sticky w
	grid $top.case    -row 4 -column 0 -sticky w
	grid $top.title   -row 6 -column 0 -sticky w
	grid $top.current -row 8 -column 0 -sticky w
	grid columnconfigure $top 0 -weight 1
	grid rowconfigure $top {1} -minsize $::theme::padding

	foreach v {search entire case title current} {
		bind $top.$v <Return> [namespace code [list Search $bot]]
	}

	### Bottom Frame ########################################
	set Priv(search:tree) $bot
	::treetable $bot -takefocus 1 -showarrows 0 -borderwidth 1 -relief sunken -showlines no
	bind $bot <<TreeTableSelection>> [namespace code [list LoadPage %d]]

	### Geometry ############################################
	grid $top -row 0 -column 0 -sticky ew
	grid $bot -row 2 -column 0 -sticky nsew
	grid rowconfigure $w 2 -weight 1
	grid rowconfigure $w 1 -minsize $::theme::padding
	grid columnconfigure $w 0 -weight 1
}


proc Search {t} {
	variable [namespace parent]::Contents
	variable [namespace parent]::Priv
	variable [namespace parent]::Colors

	set search $Priv(search:entry)
	if {[string length $search] == 0} { return }

	lappend options -max 20
	if {!$Priv(matchCase)}	{ lappend options -noCase }
	if {$Priv(entireWord)}	{ lappend options -entireWord }
	if {$Priv(titleOnly)}	{ lappend options -titleOnly }

	array unset Priv match:*
	set lang [[namespace parent]::helpLanguage]
	set directory [file normalize [file join $::scidb::dir::help $lang]]
	set results {}
	set exceededMsg 0
	set activate 1
	::log::open [set [namespace parent]::mc::Help]

	if {$Priv(currentOnly)} {
		set files [list $Priv(current:file)]
	} else {
		set files [glob -nocomplain -directory $directory *.html]
	}

	foreach path $files {
		set file [file tail $path]

		if {$file ne "Overview.html" && [file readable $path]} {
			set fd [::open $path r]
			chan configure $fd -encoding utf-8
			set content [read $fd]
			close $fd

			lassign [::scidb::misc::html search {*}$options $search $content] rc exceeded title positions

			if {!$rc} {
				::log::error [format [set [namespace parent]::mc::ParserError] [file join $lang $file]]
			}
			if {$exceeded} {
				set exceededMsg 1
			}
			if {[llength $positions] > 0} {
				if {[string length $title] == 0} { set title [FindTitle $file $Contents] }
				if {[string length $title] > 0} {
					lappend results [list [llength $positions] $path $positions $title $search]
				}
			}
		}
	}

	::log::close
	set results [lsort -integer -decreasing -index 0 $results]
	$t clear

	if {[llength $results] == 0} {
		$t add 0 \
			-text [set [namespace parent]::mc::NoMatch] \
			-fill $Colors(foreground:litegray) \
			-enabled no \
			;
	} else {
		set count 0
		foreach match $results {
			set tag "t-$count"
			$t add 0 -text [lindex $match 3] -tag $tag
			set Priv(match:$tag) $match
			incr count
		}
		$t activate 1
		for {set i 0} {$i < [llength $results]} {incr i} {
			set path [lindex $results $i 1]
			if {$Priv(current:file) eq $path} {
				set Priv(current:file) ""
				$t select "t-$i"
				break
			}
		}
	}

	if {$exceededMsg} {
		::dialog::info \
			-parent $t \
			-message [set [namespace parent]::mc::MaxmimumExceeded] \
			-detail [format [set [namespace parent]::mc::OnlyFirstMatches] 20] \
			;
	}
}


proc FindTitle {file contents} {
	foreach group $contents {
		foreach entry $group {
			if {[llength $entry] == 1} {
				set topic [lindex $entry 0]
				if {[lindex $topic 1] eq $file} { return [lindex $topic 0] }
			} else {
				set title [FindTitle $file $entry]
				if {[string length $title]} { return $title }
			}
		}
	}

	return ""
}


proc LoadPage {item} {
	variable [namespace parent]::Priv

	if {[llength $item] > 0} {
		if {$Priv(search:changed)} { set Priv(current:file) "" }
		set Priv(search:changed) 0
		[namespace parent]::Load [lindex $Priv(match:$item) 1] {} $Priv(match:$item)
	}
}


proc Update {} {
	variable [namespace parent]::Priv
	$Priv(search:tree) clear
}

} ;# namespace search


proc TabChanged {nb} {
	variable Priv

	set tab [$nb select]

	switch -glob -- [$nb select] {
		*contents	{ set mode contents }
		*index		{ set mode index }
		*search		{ set mode search }
	}

	if {$Priv(tab) eq $mode} { return }
	set Priv($Priv(tab):changed) 1
	set Priv(tab) $mode

	switch $Priv(tab) {
		contents	{ set state normal }
		default	{ set state disabled }
	}

	foreach type {expand collapse} { $Priv(button:$type) configure -state $state }
}


proc UpdateTitle {} {
	variable Priv

	append title $::scidb::app
	append title ": "
	append title $mc::Help

	if {[string length $Priv(topic)]} {
		append title " - "
		append title $Priv(topic)
	}

	wm title $Priv(dlg) $title

	set tip "$mc::GoBack ($::mc::Key(Alt)-$::mc::Key(Left))"
	::tooltip::tooltip $Priv(button:back) $tip
	set tip "$mc::GoForward ($::mc::Key(Alt)-$::mc::Key(Right))"
	::tooltip::tooltip $Priv(button:forward) $tip
}


proc Update {} {
	UpdateTitle
	ReloadCurrentPage
	index::Update
	contents::Update
	search::Update
}


proc RecordGeometry {pw} {
	variable Priv
	variable Geometry

	set dlg [winfo toplevel $pw]

	lassign {0 0} x y
	scan $Geometry "%dx%d%d%d" _ _ x y
	scan [wm geometry $dlg] "%dx%d%d%d" w h x y
	if {$x < 0} { set x 0 }
	if {$y < 0} { set y 0 }

	if {[llength [$pw panes]] == 1} {
		set w [expr {min($w + $Priv(minsize), [winfo screenwidth $pw] - 30)}]
	} else {
		set Priv(minsize) [winfo width [lindex [$pw panes] 0]]
	}

	set Geometry "${w}x${h}+${x}+${y}"
}


proc ExpandAllItems {} {
	variable Priv
	$Priv(contents:tree) expand
}


proc CollapseAllItems {} {
	variable Priv
	$Priv(contents:tree) collapse
}


proc PopupMenu {dlg tab} {
	variable Priv
	variable Contents

	::tooltip::hide

	set m $dlg.popup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	set cursor [winfo pointerxy $dlg]

	switch -glob -- [winfo containing {*}$cursor] {
		*.contents.tree {
			$m add command \
				-command [namespace code ExpandAllItems] \
				-label " $mc::ExpandAllItems" \
				-image $::treetable::icon::16x16::collapse \
				-compound left \
				;
			$m add command \
				-command [namespace code CollapseAllItems] \
				-label " $mc::CollapseAllItems" \
				-image $::treetable::icon::16x16::expand \
				-compound left \
				;
			$m add separator
		}

		*.html.* {
			$m add command \
				-command [namespace code GoBack] \
				-label " $mc::GoBack" \
				-image $::icon::16x16::backward \
				-compound left \
				-state [$Priv(button:back) cget -state]
				;
			$m add command \
				-command [namespace code GoForward] \
				-label " $mc::GoForward" \
				-image $::icon::16x16::forward \
				-compound left \
				-state [$Priv(button:forward) cget -state]
				;
			$m add separator
			set count 0
			foreach file $Priv(recent) {
				set topic [FindTopic $file $Contents]
				if {[llength $topic]} {
					lassign $topic title file
					set path [FullPath $file]
					if {$Priv(current:file) ne $path} {
						$m add command \
							-command [namespace code [list Load $path]] \
							-label " [format $mc::GotoPage $title]" \
							-image $icon::16x16::document \
							-compound left \
							;
						incr count
					}
				}
			}
			if {$count > 0} { $m add separator }
		}

		*.tree	{}
		default	{ return }
	}

	if {$tab in [[winfo parent $tab] panes]} {
		set text $mc::HideIndex
		set icon $::icon::16x16::toggleMinus
	} else {
		set text $mc::ShowIndex
		set icon $::icon::16x16::togglePlus
	}
	$m add command \
		-label " $text" \
		-image $icon \
		-compound left \
		-command [namespace code ToggleIndex] \
		;
	$m add command \
		-image $::icon::16x16::close \
		-label " $::mc::Close" \
		-compound left \
		-command [namespace code Destroy] \
		;

	bind $m <<MenuUnpost>> +::tooltip::hide
	tk_popup $m {*}$cursor
}


proc FindTopic {file contents} {
	set file [file rootname $file]
	foreach group $contents {
		foreach entry $group {
			if {[llength $entry] != 1} {
				return [FindTopic $file $entry]
			}
			set topic [lindex $entry 0]
			set f [file rootname [file tail [lindex $topic 1]]]
			if {$f eq $file} { return $topic }
		}
	}

	return {}
}


proc ToggleIndex {} {
	variable Priv

	set pw [winfo parent $Priv(control)]

	if {$Priv(control) in [$pw panes]} {
		$pw forget $Priv(control)
	} else {
		$pw add $Priv(control) -sticky nswe -stretch never -minsize $Priv(minsize) -before [$pw panes]
	}
}


proc ShowIndex {} {
	variable Priv

	set pw [winfo parent $Priv(control)]
	if {$Priv(control) ni [$pw panes]} { ToggleIndex }
}


proc BuildHtmlFrame {dlg w} {
	variable Priv

	# setup css script
	set css [::html::defaultCSS [::font::htmlFixedFamilies] [::font::htmlTextFamilies]]

	# build HTML widget
	set height [expr {min([winfo screenheight $dlg] - 60, 800)}]
	::html $w \
		-imagecmd [namespace code GetImage] \
		-center no \
		-fittowidth yes \
		-width 600 \
		-height $height \
		-cursor left_ptr \
		-borderwidth 1 \
		-relief sunken \
		-doublebuffer yes \
		-exportselection yes \
		-css $css \
		-showhyphens 1 \
		-latinligatures $Priv(latinligatures) \
		;

	$w handler node link [namespace current]::LinkHandler
	$w handler node a    [namespace current]::A_NodeHandler

	$w onmouseover [namespace current]::MouseEnter
	$w onmouseout  [namespace current]::MouseLeave
	$w onmouseup1  [namespace current]::Mouse1Up

	set dlg [winfo toplevel $dlg]

	bind $dlg <FocusIn>	[list $w focusin]
	bind $dlg <FocusOut>	[list $w focusout]

	return [$w drawable]
}


proc GetImage {file} {
	if {[string match {[A-Z][A-Z][A-Z]} $file]} {
		set src $::country::icon::flag($file)
		set img [image create photo -width [image width $src] -height [image height $src]]
		$img copy $src
	} else {
		set file [FullPath $file]
		if {[catch { set img [image create photo -file $file] }]} {
			set src $icon::16x16::broken
			set img [image create photo -width [image width $src] -height [image height $src]]
			$img copy $src
		}
	}
	return $img
}


proc A_NodeHandler {node} {
	variable Nodes
	variable Links
	variable ExternalLinks

	set href [$node attribute -default {} href]

	if {[string match http* $href] || [string match ftp* $href]} {
		$node dynamic set user
		set file $href

		if {[info exists ExternalLinks($file)]} {
			if {$ExternalLinks($file)} {
				$node dynamic clear link
				$node dynamic set user2
			} else {
				$node dynamic clear link
				$node dynamic set user3
			}
		}
	} else {
		$node dynamic set link

		if {[string length $href] && ![string match script(*) $href]} {
			set file [FullPath $href]
			if {[info exists Links($file)]} {
				if {$Links($file)} {
					$node dynamic set visited
				} else {
					$node dynamic clear link
					$node dynamic set user3
				}
			}
		}
	}

	set Nodes($node) 0
}


proc LinkHandler {node} {
	if {[$node attribute rel] eq "stylesheet"} {
		set uri [$node attribute -default {} href]
		if {[string length $uri]} { ImportHandler author $uri }
	}
}


proc ImportHandler {parentid uri} {
	variable _StyleCount
	variable Priv

	set file [FullPath $uri]
	set fd [::open $file r]
	chan configure $fd -encoding utf-8
	set content [read $fd]
	close $fd

	set id "$parentid.[format %.4d [incr _StyleCount]]"
	set handler [namespace code [list ImportHandler $id]]
	$Priv(html) style -id $id.9999 -importcmd $handler $content
}


proc MouseEnter {node} {
	variable Nodes
	variable Priv

	if {[llength $node] == 0} { return }

	if {[info exists Nodes($node)]} {
		$node dynamic set hover
		[$Priv(html) drawable] configure -cursor hand2

		if {[$node dynamic get user3]} {
			::tooltip::show $Priv(html) $mc::PageNotAvailable
		} elseif {[$node dynamic get user]} {
			::tooltip::show $Priv(html) [$node attribute href]
		}
	}
}


proc MouseLeave {node} {
	variable Nodes
	variable Priv

	::tooltip::hide
	if {[llength $node] == 0} { return }

	if {[info exists Nodes($node)]} {
		$node dynamic clear hover
		[$Priv(html) drawable] configure -cursor {}
	}
}


proc Mouse1Up {node} {
	variable Nodes
	variable Links
	variable ExternalLinks
	variable Priv

	if {[llength $node] == 0} { return }

	if {[info exists Nodes($node)]} {
		set Nodes($node) 1
		$node dynamic clear link
		if {[$node dynamic get user]} {
			$node dynamic set user2
		} else {
			$node dynamic set visited
		}

		set href [$node attribute -default {} href]
		if {[string length $href] == 0} { return }

		if {[string match script(*) $href]} {
			set script [string range $href 7 end-1]
			eval [namespace code [list {*}$script]]
		} elseif {[string match http* $href] || [string match ftp* $href]} {
			::web::open $Priv(html) $href
			set ExternalLinks($href) 1
		} elseif {[llength $href]} {
			set fragment ""
			lassign [split $href \#] href fragment
			set file [FullPath $href]
			set wref [$node attribute -default {} wref]
			if {[llength $wref] == 0} { set wref $file }
			set Links($wref) [Load $file $wref {} $fragment]
		}
	}
}


proc ReloadCurrentPage {} {
	variable Priv
	variable Links

	set file ""
	if {[info exists Priv(current:file)] && [string length $Priv(current:file)] > 0} {
		set file $Priv(current:file)
	}

	if {[string length $file] == 0 || ![file readable [FullPath [file tail $file]]]} {
		set file Overview.html
		if {![file readable [FullPath [file tail $file]]]} { return }
	}

	set Priv(history) {}
	set Priv(history:index) -2
	set Priv(current:file) ""

	set Links($file) [Load [FullPath [file tail $file]]]
}


proc Goto {position} {
	variable Priv

	if {[string length $position] == 0} {
		set position 0
	} elseif {![string is integer -strict $position]} {
		if {[string index $position 0] eq "#"} { set position [string range $position 1 end] }
		set selector [format {[id="%s"]} $position]
		set node [lindex [$Priv(html) search $selector] 0]
		if {[llength $node] == 0} { return }
		set position [lindex [$Priv(html) bbox $node] 1]
	}

	$Priv(html) scrollto $position
}


proc Load {file {wantedFile {}} {match {}} {position {}}} {
	variable Priv

	if {[string length $file] == 0 || $Priv(current:file) eq $file} {
		if {[llength $match]} {
			SeeNode [$Priv(html) root]
		} else {
			Goto $position
		}
		return 1
	}

	set rc [Parse $file $wantedFile 0 $match]

	if {[string length $match] == 0} {
		Goto $position
	}

	incr Priv(history:index)
	set Priv(history) [lrange $Priv(history) 0 $Priv(history:index)]
	lappend Priv(history) [list $file 0 $rc]
	if {$rc && [file tail $file] ni $Priv(recent)} {
		if {[llength $Priv(recent)] > 4} { set Priv(recent) [lrange $Priv(recent) 0 4] }
		set Priv(recent) [linsert $Priv(recent) 0 [file tail $file]]
	}

	SetupButtons
	return $rc
}


proc Parse {file wantedFile moveto {match {}}} {
	variable Colors
	variable Nodes
	variable Priv

	if {$Priv(current:file) eq $file} { return }

	set index [expr {$Priv(history:index) + 1}]
	if {$index >= 0 && $index < [llength $Priv(history)]} {
		lset Priv(history) $index 1 [lindex [$Priv(html) yview] 0]
		SetupButtons
	}

	array unset Nodes
	array set Nodes {}
	set content "<>"
	set rc 1

	if {[file readable $file]} {
		set Priv(current:lang) [lindex [file split $file] end-1]
		catch {
			set fd [::open $file r]
			chan configure $fd -encoding utf-8
			set content [read $fd]
			close $fd
		}
	}

	if {$content eq "<>"} {
		set Priv(current:lang) [helpLanguage]
		set parts [file split $file]
		set pref [file join {*}[lrange $parts 0 end-2]]
		set suff [lindex $parts end]
		set alternatives {}
		foreach lang [lsort [array names ::mc::input]] {
			if {[string length $lang]} {
				set code [set ::mc::lang$lang]
				set f [file join $pref $code $suff]
				if {[file readable $f]} {
					set img "<img src='$::mc::langToCountry($code)' align='bottom'/>"
					lappend alternatives [list $img $f $::encoding::mc::Lang($code)]
				}
			}
		}
		set alternatives [lsort -index 2 $alternatives]
		append content "
			<html><head><link rel='stylesheet'/></head><body>
			<h1>$mc::FileNotFound</h1>
			<p>[format $mc::CantFindFile [list <ragged><b>$file</b></ragged>]]</p><br>
			<p><div style='background: $Colors(background:emphasize); border: 1px solid black;'>
			<blockquote><h4>$mc::IncompleteHelpFiles</h4></blockquote>
			</div></p>
		"
		if {[llength $alternatives]} {
			append content "<br/><br/><br/>"
			append content "<div style='background: $Colors(background:gray); border: 1px solid black;'>"
			append content "<blockquote><p>$mc::ProbablyTheHelp:</p>"
			append content "<dl>"
			foreach alt $alternatives {
				lassign $alt icon href lang
				append content "<dt>$icon&ensp;<a href='$href' wref='$file'>$lang</a></dt>"
			}
			append content "</dl></blockquote></div>"
		}
		append content "
			<br/><p><a href='script(GoBack)'>${mc::GoBack}</a></p>
			</body></html>"
		set match {}
		set rc 0
	} elseif {[llength $match]} {
		lassign $match _ _ positions _ search

		set len [string length $search]
		set str $content
		set content ""
		set from 0

		foreach pos $positions {
			append content [string range $str $from [expr {$pos - 1}]]
			append content "<span class='match'>"
			append content [string range $str $pos [expr {$pos + $len - 1}]]
			append content "</span>"
			set from [expr {$pos + $len}]
		}
		append content [string range $str $from end]
	}

	set lang [lindex [file split $file] end-1]
	set content [::html::hyphenate $lang $content]
	if {$Priv(latinligatures)} { set content [::scidb::misc::html ligatures $content] }

	[$Priv(html) drawable] configure -cursor {}
	$Priv(html) parse $content
	update idletasks
	$Priv(html) yview moveto $moveto

	if {[string length $wantedFile] == 0} { set wantedFile $file }
	set Priv(current:file) $wantedFile

	if {[llength $match]} { SeeNode [$Priv(html) root] }

	set Priv(topic) ""
	catch { set Priv(topic) $Priv(topic:$file) }
	UpdateTitle

	return $rc
}


proc SeeNode {node} {
	variable Priv

	set cls [$node attribute -default "" class]

	if {$cls eq "match"} {
		$Priv(html) scrollto [lindex [$Priv(html) bbox $node] 1]
		return 1
	}

	foreach node [$node children] {
		if {[SeeNode $node]} { return 1 }
	}

	return 0
}


proc GetGoBackIndex {} {
	variable Priv

	set index $Priv(history:index)
	while {$index >= 0} {
		if {[lindex $Priv(history) $index 2]} { break }
		incr index -1
	}

	return $index
}


proc GoBack {} {
	variable Priv

	set index [GetGoBackIndex]

	if {$index >= 0} {
		set entry [lindex $Priv(history) $index]
		Parse [lindex $entry 0] {} [lindex $entry 1]
		set Priv(history:index) [expr {$index - 1}]
		SetupButtons
	}
}


proc GoForward {} {
	variable Priv

	set index [expr {$Priv(history:index) + 2}]
	while {$index < [llength $Priv(history)]} {
		if {[lindex $Priv(history) $index 2]} { break }
		incr index
	}

	if {$index < [llength $Priv(history)]} {
		set entry [lindex $Priv(history) $index]
		Parse [lindex $entry 0] {} [lindex $entry 1]
		set Priv(history:index) [expr {$index - 1}]
		SetupButtons
	}
}


proc SetupButtons {} {
	variable Priv

	if {![info exists Priv(button:forward)]} { return }

	if {$Priv(history:index) + 2 < [llength $Priv(history)]} {
		set state normal
	} else {
		set state disabled
	}
	$Priv(button:forward) configure -state $state

	if {$Priv(history:index) >= 0} {
		set state normal
	} else {
		set state disabled
	}
	$Priv(button:back) configure -state $state
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Lang
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 16x16 {

set broken [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH1QgYESoxCKsW2AAAAxJJREFUOMuNk11sk3UU
	xn//frzv2m6jQ1oHONaNZXU1XhiZm4yQiRCjTV00cdWl0yVIYsICTaaZroORDAwzkRgMXHGD
	M35gNMo2y0TDdEv8QIMG7ULUFu1gwQwiYWxr37c93rQTEi98rs55Ts6TnPOco0QEpVS/z+fb
	4Ha7dQARAVCFmirkmKZBIjH9tYjsowBbMUilUm38D/z4w9m1BdGB2wQAhr9I0vVqnJVlGs4S
	O+VOOw5HCVkDylw6vspShntb75mamrIqpSwisqcooAGs12eIdmykrfFO8qaBkRMsuovmwB18
	8tZRWsPdALS0tNydTP7+tFJK2QD3S7HYC/VOJ5bsIofGT/PzFQ+XZ69i0xy0b/HgtVtp1DW+
	/PYnHt1xgLGxcTZULtTV1tY2Et29+3IlyK/hsEyH26XBoclHI6PS/d4l+S59Q0qtyKmtD8ul
	ri7ZUV0l0e0RiX34p4iI+P3+uEXT9aUMML+0hOglvBtqY+8zT1G/GGfb+hWcaN3CujVruWkY
	XM8sUe2rAfIAKKXEMjQ0dG/34OBMaGKCq3NzaCUO3gk+zkhsL+8/tA3fXVWIYbDr8894sLcX
	b/Blspns8uKLXu8TkYEKTWMkGMSzejUZpbAB1kyGXfHTPHvgNQKPhZmdgWvzN4lsdhEIBD4t
	umACjF5IEKzzcyyfZ7Hg8SjgeG475xvOE3ujH7tpsqAvENl85bZDsgFsrW/gzXwevUBagTAQ
	O36c9kdOwBOKC8lfuH7j7+URLICrf//+5yvsdo6YJlUOBwADNhuzgO50chCTgx1PUv1NDS7n
	Cs6mvi/2Cz09PSkFMr5qlUx3dspXDQFZAzIcH5fy0pVyzOGSRCQi55qbZSPIkcHD8sChJhER
	CQQCo5acaeo2oGbTJiy5HKHpBEfPnGIs9zbxP86wM5vl3MQEdaEQpUBy5jea/E3/3r+IuF/s
	6/urDKQC5L9QrmmyDqSvf0/uVt7r9X6gRASPx7OzMxJ5xTQMx8cnT76eTqfnl31Wimg02nFt
	bu6+5MWLhycnJ9O3/N/9/wBvyWHwrbQl3wAAAABJRU5ErkJggg==
}]

set bookOpen [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
	ZSBJbWFnZVJlYWR5ccllPAAAAkdJREFUeNqUUz1vE0EQfbt3e3ZwnICDk2AXSEFBIEsERIVE
	R0eBKxoq6ggqGv4H0KcBRBco+BA9KBJSIkcxYAkJGzCJDIY4Ocucb3eY3bOJQSiI0Y20HzNv
	35uZEydvPseDywFyfhe19y3M5Cdp7sSZzWajdiM7kb23sfEWvueDIACjYcigVCphfUvj2qNv
	kBgYEVnPkTFIH8rPzi1cuKu1fqENrWhNxOse+6LR8VljaJgGn5fLvC/bw+L0OCLNJwxioWeL
	x859b7xCrjAPNX4kFYvMnTDcBWNBG8kPiocWoFxI7eJwfgrdcAfvPnUsHcsJYOqSYk4wGPMV
	JqcKyKsDfLUNFa3AQJSdBKYGy8o4Gdgzcp+TZ5iV4RpwFCcY/mJ3yQACFMcYzdvXBoGGcyBE
	UkTNlRX4PzMszZoDIB3/fiss3D6QfGW7NQBgCVYPBkk2WXj/ABKJBAdg0biIw7jsmMHH1y/R
	7XzhLijGEH+FIFdQngOnx9ga2JclDmYCRL0mmpUacsVT8GwrPQ9SegwmXYxllnSEiyh5o5SE
	DHyknCtEkUZ3p4ftz1XX2q9bLfzoduAF6eR5mXZxnAxfsdx6dRXVSoWDRUKZXVtG7UIyVOE6
	Gm/WmOp9NxNSSmQU8T9SZgDEncV6eUJzMo0UqU8SS8efud3VD5eghB5tAjxBCNDv2PXC0YvX
	T5Pu6+Ffpfu9aOb8ldtaBNPuKGw9ba8+WZI+axSuNdwo5dUf31obFjizN2O/5m2eXQ32bfbN
	P3pq1+FPAQYA17kRbxpFka4AAAAASUVORK5CYII=
}]

set bookClosed [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAByFBMVEUfUZIWY7YbS4kUR4Yb
	S4gbS4kbTIkbTYoKSZNMs99nveNdvORau+MRRIASQHllxehmxehnxehrxulvx+l3y+sPQ4MS
	UZYXV5kijcQlnNAqns0xo9QxrNg8qtg9r9pJsdtJtd1VuN9XuuBjwONkwORuxOZ0x+h3yeh+
	zeuAzOoNQIB+zesMN2sLNmoLNmscR3slUIO43usAMnEANHMANXMBNXMHSY8HSpAHS5AdisAd
	l8cejsIfkcQfk8UflMUglsYgmsgkpNIlnc8no9IoqNQpq9YprNYprdc0qNU2qNU5rtg6sNg7
	s9o8tds8tttAZ5dFsdpIstpLt91Ofq9OvN9PvuBPv+BXut9au99dsdZewOFgut5hxONjxuRo
	vOBowuRtxeVvx+ZxweJyyedzy+d1zOh1zeh3yuh6k7B6xuV+zuqC0OuDyuiD0OyD0euE0euG
	0+yH0+yI0+2Kz+qK1vCL0euL1O2L2vOM1e6M1/CM2vKM2vON1e6N2vON2/OO2PCP1u6P2PCP
	2/OQ2PCR0uyS2fGU1OyV2e+V3fOX2vCY2/Kas82d4PSh3vOq1+mw4PC24vG95fPE6PTK6/bQ
	7ffS6/TU7/j///9grXZJAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMA
	AAsTAQCanBgAAAAHdElNRQfcAQMVICLc9PR3AAAAoUlEQVQY02NgYBAVl5KGAQYgMMjo7uuf
	MHHS5CnTpoIF9P2DI6PjkjJzilvawAK6RmZW0sh69IwtHNy8g6ISs4oqq8ACJub27r4hMSnZ
	ZfXVUAE7V7/Q2NS8ikYkgbDY1PyaxlqiBWwxBXxDY9Pya5rroAI2Lj4hMakFDa1NUAFrZ6+g
	qOTC9q4OkICOqZmlk2dgREJ2Z28P2DNaYhJIXgEAYWlBFIyfP+wAAAAASUVORK5CYII=
}]

set document [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAABFElEQVQYGQXBPWpUURgA0HPf
	uzOJ5A/RwmARgnbBMuAGbKOCTSrrbMQma3AfVmKnGIJ1bBUcmYGMiTrMvDvfl3MKH5cxAND1
	vy9P35gA2H7dsmXLli1btlzk93z/1S5AlVwZ+2NLCE/98/Z49eHsxAxsv2r5K6c5zVlOc5JD
	XuQkW55/9gg6uDY3NTN3oxj8dOnl8/0TqHCoGIykIh1rmntKDxW+KEInPDFyo7NwBKhwoLcy
	EjbteQAAKjxULWyimbv1F88AFS4UoRMOjP1QdQhQYV+1VDUjW450AkCFXb0dpE7qpR5AXeNK
	qNb+u2+lqA7tWYMKS53BjmqsaDYUAajwQiBAAHpAXXx7/C4CAgBRuP4Edyw3eA24NyyYAAAA
	AElFTkSuQmCC
}]

set library [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACYUlEQVQ4y4VS3UuTURj/Pee8H25rHzVXftS2HG5YmiNq
	EiWBSYkXhQR1EXTVv1C3/QXddi8EQTdCBQ5vKggiM7OyRhM3M52iLF/SOdv7nvd08W7kx6zn
	6jnw/D6e33M46hcpasPRcOLcjXiy/4GqqppRXPwAQAMgdgzWGqYosC3LfagllozEUlfbEsnB
	7u6O+OmuI3o+8yY7ks5O5Wdzq/np9H0AxRpOAcBDQORUs//yZs/AUOzk2dSl7jOBzvaD8Lg4
	cgWJFdYXb0z2xL3x91YwVKp8G58aNmHnIfGLrjf5h/tSnb3R873hhxTnF0+0IhLQMfGjhIXv
	fgiporVFoCvGEG1U8fZjZvPZ68nS19HndxSX66kyeDhw+0L7cSzbwJf8Il5OZNAgBdzRCK4k
	29CfCMKtEQolE09m1jAvPW4Rjuik6zrzHICiCQtLY2nMcxfszlv4XakAwoLFVpAzSnj0TsOc
	SQh4m8EYA2MM0radAKSE4iRIAGPVTAkEhrK5hVfZGWiyAb6WNgS8TWBEe86loArZcZfqkzMG
	LhmICKgDrmnv/gJ7mf5RDKC/5HXm5f8JnBWopki71tnPhZRc9fm2Rbef2/3wtq0ujI2CzW2Z
	S4ZlY0NICLkNRYCsw0qMOWrS5kTElcfLxs1xHQMFTXasRNcHGdd0kHPjmrrjkGCbJsqFBWvt
	86fZrWJxFYDqjGguoFL2USJ1l3uD17iwNCumN7KwL6jZGtyeoAyV+c+NbHZiLTOd3pjLv5BC
	5ACUd3vkAEIAOBLhIX6s6Z4iyJTF9bScL4yYhjEJwABg1wB/ABDT1Vm/mN9CAAAAAElFTkSu
	QmCC
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace help

# vi:set ts=3 sw=3:
