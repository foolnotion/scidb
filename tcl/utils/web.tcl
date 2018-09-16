# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2010-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source web

namespace eval web {
namespace eval mc {

set SaveFile "Save File"

}

proc isExternalLink {url} {
	# These regular expressions aren't perfect, but sufficient for our purposes.
	if {	[regexp {^[a-z]{3,5}://.*\.[a-z]{2,6}$} $url]
		|| [regexp {^(mailto:)?[a-zA-Z0-9_.+-]+@([a-zA-Z0-9-]+\.)+[a-z]{2,6}$} $url]} {
		return 1
	}
	return 0
}


proc isWebLink {url} {
	return [regexp {^https?://[^\s]+$} $url]
}


proc open {parent url} {
	set url [::scidb::misc::url escape $url]
	::widget::busyCursor on

	switch -- [tk windowingsystem] {
		"aqua" {
			catch {exec open $url &}
		}

		"win32" {
			if {$::tcl_platform(os) eq "Windows NT"} {
				catch {exec $::env(COMSPEC) /c start \"$url\" &}
			} else {
				catch {exec start \"$url\" &}
			}
		}

		"x11" {
			variable DefaultBrowser
			variable Excluded
			variable Options

			set xdgopen [auto_execok xdg-open]
			if {[string length $xdgopen] > 0} {
				# xdg-open always reports errors
				if {![regexp {^[a-z]+:} $url]} {
					if {[string match *@* $url]} {
						set prot mailto:
					} elseif {![regexp {^[a-z]+://} $url]} {
						set prot http://
					}
					set url ${prot}${url}
				}
				catch { exec $xdgopen "$url" & }
			} else {
				if {![info exists DefaultBrowser]} {
					set DefaultBrowser [FindDefaultBrowser]
				}
				while {[string length $DefaultBrowser]} {
					if {[info exists Options($DefaultBrowser)]} {
						set options [string map [list %url% $url] $Options($DefaultBrowser)]
						if {![catch {exec /bin/sh -c "$DefaultBrowser $options"}]} { break }
					}
					if {![catch {exec /bin/sh -c "$DefaultBrowser '$url'" &}]} { break }
					lappend Excluded $DefaultBrowser
					set DefaultBrowser [FindDefaultBrowser]
				}
				if {[llength $DefaultBrowser] == 0} {
					::dialog::error \
						-parent $parent \
						-message $mc::CannotFindBrowser \
						-detail $mc::CannotFindBrowserDetail \
						;
				}
			}
		}
	}

	::widget::busyCursor off
}


proc downloadURL {parent url args} {
	variable RetryCounter
   global env

	array set opts {
		-successcmd	{}
		-failedcmd 	{}
		-retrycmd  	{}
		-timeouts  	{1000 3000}
		-filetypes 	{}
	}
	array set opts $args

   if {[catch {package require http 2.7}]} {
		if {[llength $opts(-failedcmd)]} {
			{*}$opts(-failedcmd) $parent $url http
		}
		return
   }

	set http_proxy [expr {[info exists env(http_proxy)] ? $env(http_proxy) : ""}]
   set i [string last : $http_proxy]
   if {$i >= 0} {
      set host [string range $http_proxy 0 [expr {$i - 1}]]
      set port [string range $http_proxy [expr {$i + 1}] end]
      if {[string is integer -strict $port]} {
         ::http::config -proxyhost $host -proxyport $port
      }
   }

   ::http::config -urlencoding utf-8
   set ::http::defaultCharset utf-8

	if {[llength $opts(-successcmd)] == 0} {
		set opts(-successcmd) [namespace current]::SaveData
	}

	set RetryCounter 0
   return [GetURL $parent $url {*}[array get opts]]
}


proc GetURL {parent url args} {
	array set opts $args
	set timeout [lindex $opts(-timeouts) 0]
	if {[llength $timeout] == 0} { set timeout 5000 }
	set opts(-timeouts) [lrange $opts(-timeouts) 1 end]
   set cmd [list [namespace current]::DownLoadResponse $parent $url [array get opts]] 

   if {[catch { ::http::geturl $url -command $cmd -timeout $timeout }] && [llength $opts(-failedcmd)]} {
		{*}$opts(-failedcmd) $parent $url down
   }
}


proc DownLoadResponse {parent url args token} {
	variable RetryCounter

	array set opts $args
   set code [::http::ncode $token]
   set state [::http::status $token]
   set data [::http::data $token]
   ::http::cleanup $token
   set retry 0

   switch $state {
      error { set code 404 }
      timeout - eof { set retry 1 }

      ok {
         if {[string length $code] == 0} {
            set code 100
         }
         switch $code {
            100 - 408 - 429 - 503 - 503 - 522 { set retry 1 }
            200 { ;# ok }

            default {
					if {[llength $opts(-failedcmd)]} {
						{*}$opts(-failedcmd) $parent $url $code
					}
					return
				}
         }
      }
   }

	if {$code == 404} {
		if {[llength $opts(-failedcmd)]} {
			{*}$opts(-failedcmd) $parent $url notfound
		}
	} elseif {!$retry} {
		if {[llength $opts(-successcmd)]} {
			{*}$opts(-successcmd) $parent $url $data
		} else {
			SaveData $parent $url $data {*}$args
		}
   } elseif {[llength $opts(-timeouts)]} {
		set timeout [lindex $opts(-timeouts) 0]
		set opts(-timeouts) [lrange $opts(-timeouts) 1 end]
      after $timeout [list [namespace current]::GetURL $parent $url {*}[array get opts]]
   } elseif {[llength $opts(-retrycmd)]} {
		{*}$opts(-retrycmd) $parent $url $retry [incr RetryCounter]
   } elseif {[llength $opts(-failedcmd)]} {
		{*}$opts(-failedcmd) $parent $url timeout
   }
}


proc SaveData {parent url data args} {
	array set opts $args

	set result [::dialog::saveFile \
		-parent $parent \
		-filetypes $opts(-filetypes) \
		-geometry last \
		-title [set [namespace current]::mc::SaveFile] \
	]
	if {[llength $result]} {
		set fp [open $result wb]
		puts -nonewline $fp $data
		close $fp
	}
}


if {[tk windowingsystem] eq "x11"} {

namespace eval mc {
	set CannotFindBrowser			"Couldn't find a suitable web browser."
	set CannotFindBrowserDetail	"Set the BROWSER environment variable to your desired browser."
}

variable Browsers {google-chrome firefox iceweasel mozilla safari opera iexplorer konqueror epiphany galeon mosaic amaya browsex}
variable Options {
	mozilla		{-raise -remote 'openURL(%url%)'}
	iceweasel	{-remote 'openURL(%url%)'}
}
variable Excluded {}


proc FindDefaultBrowser {} {
	global env
	variable Browsers

	if {[info exists env(BROWSER)]} {
		foreach browser [split $env(BROWSER) :] {
			set browser [auto_execok $browser]
			if {![IsExcluded $browser] && [IsX11Browser $browser]} { return $browser }
		}
	}

	set browser [auto_execok x-www-browser]
	if {[llength $browser] && ![IsExcluded $browser]} { return $browser }

	set htmlviewrc [file join $::scidb::dir::home .htmlviewrc]
	if {[file readable $htmlviewrc]} {
		set chan [::open $htmlviewrc]

		while {[gets $chan line] >= 0} {
			if {[string range $line 0 9] eq "X11BROWSER"} {
				set browser [auto_execok [string trim [lindex [split $line =] 1]]]
				if {[llength $browser] && ![IsExcluded $browser]} { return $browser }
			}
		}

		close $chan
	}

	foreach browser $Browsers {
		set browser [auto_execok $browser]
		if {[llength $browser] && ![IsExcluded $browser]} { return $browser }
	}

	return ""
}


proc IsX11Browser {browser} {
	variable Browsers

	if {[llength $browser]} {
		foreach b $Browsers {
			if {[string match [list *$b*] $browser]} { return 1 }
		}
	}

	return 0
}


proc IsExcluded {browser} {
	variable Excluded

	return [expr {[lsearch -exact $Excluded $browser] >= 0}]
}

} ;# [tk windowingsystem] eq "x11"

} ;# namespace web

# vi:set ts=3 sw=3:
