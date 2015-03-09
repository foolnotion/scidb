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
# Copyright: (C) 2015 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source database-information

namespace eval application {
namespace eval database {
namespace eval information {
namespace eval mc {

set RecentlyUsed				"Recently used"
set RemoveSelectedDatabase	"Remove selected database from history"
set NewsAvailable				"There are news available"

}

array set Priv {
	needUpdate	1
	active		0
	width			0
	afterid		{}
	retry			0
	lock			0
	news			""
	checksum		0
}

array set Options {
	checksum	0
	welcome	1
}

set URL "http://scidb.sourceforge.net/%s/news.html"


proc build {tab} {
	variable Priv

	set btn [tk::frame $tab.btn]
	set inf [tk::frame $tab.inf]
	grid $btn -row 1 -column 1 -sticky nsew
	grid $inf -row 2 -column 1 -sticky nsew
	grid rowconfigure $tab {2} -weight 1
	grid columnconfigure $tab {1} -weight 1
	grid remove $btn

	tk::label $btn.new \
		-textvar [namespace current]::mc::NewsAvailable \
		-background [::colors::lookup information,background:news] \
		-justify center \
		;
	pack $btn.new -fill both -expand yes

	set Priv(html) [::html $inf.html \
		-background [::colors::lookup information,background:html] \
		-doublebuffer yes \
		-imagecmd [namespace code GetImage] \
		-borderwidth 1 \
		-usevertscroll yes \
		-center yes \
		-fittoheight 1 \
		-exportselection yes \
	]
	::font::html::setupFonts info
	# pre-load some font informations
	::font::html::defaultTextFonts info
	::font::html::defaultFixedFonts info
#	::font::html::addChangeFontSizeBindings info [winfo toplevel $tab] [list $Priv(html) fontsize]
	bind $Priv(html) <Configure> +[namespace code [list Configure %w]]
	bind $Priv(html) <<LanguageChanged>> [namespace code LanguageChanged]
	$Priv(html) onmouseover    [namespace current]::MouseEnter
	$Priv(html) onmouseout     [namespace current]::MouseLeave
	$Priv(html) onmouseup1     [namespace current]::Mouse1Up
	$Priv(html) onmousedown1   [namespace current]::Mouse1Down
	$Priv(html) onmousedown3   [namespace current]::Mouse3Down
	$Priv(html) handler node a [namespace current]::A_NodeHandler
	pack $Priv(html) -fill both -expand yes
	set Priv(buttons) $btn
	after idle [namespace code [list FetchNews $::mc::langID 0]]
}


proc activate {w flag} {
	variable Priv
	variable Options

	set Priv(active) $flag
	if {!$Priv(active) || !$Priv(needUpdate)} { return }

	set Priv(active) 0
	::update idletasks ;# give the HTTP request a chance
	set Priv(active) 1

	set color-header	[::colors::lookup information,html:header]
	set color-hover	[::colors::lookup information,html:hover]
	set color-link		[::colors::lookup information,html:link]
	set color-visited	[::colors::lookup information,html:visited]
	set color-color	[::colors::lookup information,html:color]
	set color-menu		[::colors::lookup information,html:menu]

	set html $Priv(html)
	set width [winfo width $w]
	if {$width <= 1} { set width [winfo reqwidth $w] }
	set maxWidth [expr {int((920.0*[::font::html::fontSize info])/11.0)}]
	$html configure -fixedwidth [expr {min($maxWidth, $width - 40)}]
	set recentFiles [[namespace parent]::recentFiles]
	append content "<html><body style='color:${color-color};'>"
	append css [::font::html::defaultTextFonts info] \n
	append css [::font::html::defaultFixedFonts info] \n

	if {[llength $recentFiles]} {
		set Options(welcome) 0
		set size 32

		if {[string length $Priv(news)]} {
			append content "<table cellspacing='0' cellpadding='0' border='0' width='100%'>"
			append content "<tr>"
			append content "<td valign='top'>"
		}

		append content "<h1>$mc::RecentlyUsed</h1>"
		append content "<table border='1' cellspacing='1'><tr>"

		set id 0
		foreach entry $recentFiles {
			append content "<tr>"
			set title ""
			lassign $entry type file name encoding readonly
			if {[string first "\u2026" $name] >= 0} {
				set title " title='[file tail $file]'"
			}
			set icon [namespace parent]::icons::${type}(${size}x${size})
			set name [file tail $name]
			set ext [file extension $file]
			if {[string match *$ext $name]} {
				set name [string range $name 0 [expr {[string length $name] - [string length $ext] - 1}]]
				set name [string trim $name]
			}
			append content "<td class='bases' id='$id'><img src='$icon'/></td>"
			append content "<td class='bases' id='$id' $title>$name</td>"
			append content "<td class='bases' id='$id'><img src='[::dialog::fsbox::fileIcon $ext]'/></td>"
			append content "</tr>"
			incr id
		}

		append content "</table>"

		if {[string length $Priv(news)]} {
			append content "</td>"
			append content "<td valign='top' style='padding-left:25px'>"
			append content $Priv(news)
			append content "</td>"
			append content "</tr>"
			append content "</table>"
		}
	} else {
		if {$Options(welcome)} {
			set lang $::mc::langID
			set file [file join $::scidb::dir::help $lang Welcome.html]
			if {![file exists $file]} { set file [file join $::scidb::dir::help en Welcome.html] }
			if {[file readable $file]} {
				set fileContent ""
				catch {
					set fd [::open $file r]
					chan configure $fd -encoding utf-8
					set fileContent [read $fd]
					close $fd
				}
				foreach line [split $fileContent \n] {
					if {[string match {*-- END --*} $line]} { break }
					append content $line " "
				}
				append css "li.space { margin-top:0.5em; margin-bottom:0.5em; }\n"
				set Options(welcome) 0
			}
		}

		append content $Priv(news)
	}

	append css "h1       { font-size:160%; color:${color-header}; }\n"
	append css "td.bases { font-size:18px; color:black; background-color:${color-menu}; }\n"
	append css "td.bases { padding-left:7px; padding-right:7px; }\n"
	append css "td.hover { background-color:${color-hover}; }\n"
	append css ":link    { color:${color-link};text-decoration: none; }\n"
	append css ":visited { color:${color-visited}; text-decoration: none; }\n"
	append css ":hover   { text-decoration: underline; }\n"
	append css "ul       { padding: 0; }\n"
	append css "li       { margin-top:0.5em; margin-bottom:0.5em; }\n"
	append css "hr       { border-top: solid 2px ${color-color}; }\n"

	append content "</body></html>"
	$html css $css
	$Priv(html) fontsize [::font::html::fontSize info]
	$html parse $content
	set Priv(needUpdate) 0

	if {$Priv(checksum) == 0 || $Priv(checksum) == $Options(checksum)} {
		grid remove $Priv(buttons)
	} else {
		grid $Priv(buttons)
	}

	$Priv(html) stimulate
}


proc overhang {parent} { return 0 }
proc linespace {parent} { return 0 }


proc update {} {
	variable Priv
	set Priv(needUpdate) 1
	activate $Priv(html) $Priv(active)
}


proc setActive {} {
	variable Priv
	$Priv(html) stimulate
}


proc Configure {width} {
	variable Priv

	if {$width == $Priv(width)} { return }

	set Priv(width) $width
	set Priv(needUpdate) 1

	if {$Priv(active)} {
		after cancel $Priv(afterid)
		after 150 [namespace code [list activate [winfo parent $Priv(html)] 1]]
	}
}


proc GetImage {file} {
	variable Image_

	if {[string match image* $file]} {
		return [list $file [namespace code DoNothing]]
	}

	if {[string match ::* $file]} {
		return [list [set $file] [namespace code DoNothing]]
	}

	if {![info exists Image_]} {
		set file [file join $::scidb::dir::images $file]
		if {[catch { set Image_ [image create photo -file $file] }]} { return {} }
	}
	return  [list $Image_ [namespace code DoNothing]]
}


proc DoNothing {args} {}


proc Update {size} {
	after idle [namespace code update]
	return $size
}


proc A_NodeHandler {node} {
	variable Priv

	set href [$node attribute -default {} href]
	if {[string match http* $href]} {
		$node dynamic set link
		if {[info exists Priv(link:$href)]} { $node dynamic set visited }
	}
}


proc MouseEnter {nodes} {
	variable Priv

	::tooltip::hide

	foreach node $nodes {
		if {[string length [$node attribute -default {} id]]} {
			set title ""
			foreach n [[$node parent] children] {
				$n attribute class {bases hover}
				set title [$n attribute -default $title title]
			}
			if {[string length $title]} { ::tooltip::show $Priv(html) $title }
			[$Priv(html) drawable] configure -cursor hand2
			return
		} elseif {[string length [$node attribute -default {} href]]} {
			$node dynamic set hover
			[$Priv(html) drawable] configure -cursor hand2
			return
		}
	}
}


proc MouseLeave {nodes} {
	variable Priv

	if {$Priv(lock)} { return }
	::tooltip::hide

	foreach node $nodes {
		if {[string length [$node attribute -default {} id]]} {
			foreach n [[$node parent] children] { $n attribute class bases }
			[$Priv(html) drawable] configure -cursor {}
			return
		} elseif {[string length [$node attribute -default {} href]]} {
			$node dynamic clear hover
			[$Priv(html) drawable] configure -cursor {}
			return
		}
	}
}


proc Mouse1Down {nodes} {
	variable Priv

	::tooltip::hide

	foreach node $nodes {
		set id [$node attribute -default {} id]

		if {[string length $id]} {
			lassign [lindex [[namespace parent]::recentFiles] $id] type file name encoding readonly
			[namespace parent]::openBase $Priv(html) $file no \
				-encoding $encoding \
				-readonly $readonly \
				-switchToBase yes \
				;
			return
		}
	}
}


proc Mouse1Up {nodes} {
	variable Priv

	foreach node $nodes {
		set href [$node attribute -default {} href]

		if {[string match http* $href]} {
			$node dynamic set visited
			::web::open $Priv(html) $href
			set Priv(link:$href) 1
			return
		}
	}
}


proc Mouse3Down {{nodes {}}} {
	variable Priv

	::tooltip::hide
	if {$Priv(lock)} { return }

	set menu $Priv(html).__menu__
	catch { destroy $menu }
	menu $menu
	catch { wm attributes $m -type popup_menu }

	foreach node $nodes {
		set id [$node attribute -default {} id]

		if {[string length $id]} {
			$menu add command \
				-compound left \
				-image $::icon::16x16::remove \
				-label " $mc::RemoveSelectedDatabase" \
				-command [list [namespace parent]::removeRecentFile $id] \
				;
			$menu add separator
			break
		}
	}

	::font::html::addChangeFontSizeToMenu info $menu \
		[namespace code Update] [::html::minFontSize] [::html::maxFontSize] no

	set Priv(lock) 1
	bind $menu <<MenuUnpost>> [namespace code [list Mouse3Up $nodes]]
	tk_popup $menu {*}[winfo pointerxy $Priv(html)]
}


proc Mouse3Up {nodes} {
	variable Priv

	set Priv(lock) 0
	MouseLeave $nodes
	$Priv(html) stimulate
}


proc FetchNews {lang update} {
	global env
	variable Priv

	if {[catch {package require http 2.7}]} { return 0 }
	if {[info exists env(http_proxy)]} { set http_proxy $env(http_proxy) } else { set http_proxy "" }
	set i [string last : $http_proxy]
	if {$i >= 0} {
		set host [string range $http_proxy 0 [expr {$i - 1}]]
		set port [string range $http_proxy [expr {$i + 1}] end]
		if {[string is integer -strict $port]} { ::http::config -proxyhost $host -proxyport $port }
	}
	::http::config -urlencoding utf-8
	set ::http::defaultCharset utf-8
	set Priv(retry) 0
	GetUrl $lang $update
}


proc GetUrl {lang update} {
	variable URL

	::http::geturl [format $URL $lang] \
		-command [namespace code [list FetchNewsResponse $lang $update]] \
		-timeout 5000 \
		;
}


proc FetchNewsResponse {lang update token} {
	variable Priv

	set code [::http::ncode $token]
	set state [::http::status $token]
	set data [::http::data $token]
	set retry 0
	::http::cleanup $token

	switch $state {
		error		{ return }
		timeout	{ set retry 1 }

		ok {
			switch $code {
				404 {
					if {$lang == "en" || $update} { return }
					return [FetchNews "en" $update]
				}
				100 - 408 - 429 - 503 - 503 - 522 { set retry 1 }
				200 { ;# ok }
				default { return }
			}
		}
	}

	if {$retry} {
		if {[incr Priv(retry)] == 3} { return }
		after [expr {$Priv(retry)*1000}] [namespace code [list GetUrl $lang $update]]
	} else {
		variable Counter
		set Priv(news) $data
		set Priv(checksum) [::zlib::crc $data]
		update
	}
}


proc LanguageChanged {} {
	FetchNews $::mc::langID 1
}


proc WriteOptions {chan} {
	variable Priv
	variable Options

	if {$Priv(checksum)} { set Options(checksum) $Priv(checksum) }
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace information
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
