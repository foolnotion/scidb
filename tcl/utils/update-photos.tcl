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
# Copyright: (C) 2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

#! We have to set the library path because sudo does not keep
#! this path (in general):                     \
if [ $# -gt 0 ]; then                          \
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$1; \
	shift;                                      \
fi;                                            \
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

#! The "\" at the end of the comment line below is necessary! It means
#! that the "exec" line is a comment to Tcl/Tk, but not to /bin/sh.
#! The next line restarts using tclscidb: \
exec `dirname $0`/%PROGRAM% "$0" ${1+"$@"}

package require Tcl 8.5
package require tclscidb

catch { wm withdraw . }

proc Return {code args} {
	puts [list $code {*}$args]
	puts terminated
	if {[llength $args]} { exit 1 }
	exit 0
}

if {[catch {package require http 2.7}]} { Return nohttp }

set nameofexecutable [info nameofexecutable]
if {[llength $nameofexecutable] == 0} {
	if {$tcl_platform(platform) eq "unix"} {
		catch { set nameofexecutable [exec readlink /proc/[pid]/exe] }
	}
	if {[llength $nameofexecutable] == 0} { Return broken }
}

if {$tcl_platform(platform) eq "windows"} {
	set photoDir [file join [file dirname $nameofexecutable] photos]
} elseif {[exec id -u] == 0} {
	if {[info exists env(SCIDB_SHAREDIR)]} {
		set share $env(SCIDB_SHAREDIR)
	} else {
		set share "%SHAREDIR%"
	}
	set photoDir [file join $share photos]
} else {
	set proj [string range %PROGRAM% [string first scidb %PROGRAM%] end]
	set home [file nativename "~"]
	set user [file join $home .$proj]
	set photoDir [file join $user photos]
}

if {![file isdirectory $photoDir]} { Return missing $photoDir }
if {![file writable $photoDir]} { Return noperm $photoDir }

set URL http://scidb-player-photos.googlecode.com/svn/trunk
set TimestampFile [file join $photoDir TIMESTAMP]
set FilesFile [file join $photoDir FILES]
set GetUrlArgs {-binary 1 -keepalive 1 -timeout 2000}
set Terminate 0
set MaxRetry 5
set Wait 2000

set Escape {
	" "	%20
	"!"	%21
	"\""	%22
	"#"	%23
	"$"	%24
	"%"	%25
	"&"	%26
	"'"	%27
	"("	%28
	")"	%29
	"*"	%2A
	"+"	%2B
	","	%2C
	"-"	%2D
	":"	%3A
	";"	%3B
	"<"	%3C
	"="	%3D
	">"	%3E
	"?"	%3F
	"@"	%40
	"["	%5B
	"\\"	%5C
	"]"	%5D
	"^"	%5E
	"`"	%60
	"{"	%7B
	"|"	%7C
	"}"	%7D
}

foreach {ch tok} $Escape { lappend Unescape $tok $ch }

proc Terminate {} {
	variable Terminate
	set data [gets stdin]
	if {[string trim $data] eq "terminate"} { set Terminate 1 }
}

if {$tcl_platform(platform) eq "windows"} {
	proc Join {file} { return [file join $::photoDir {*}[split $file /]] }
} else {
	proc Join {file} { return [file join $::photoDir $file] }
}

proc MakeUrl {file} {
	return $::URL/[string map $::Escape $file]
}

proc MakeFile {url} {
	return [string map $::Unescape $url]
}

proc Checksum {file} {
	if {![info exists ::checksum($file)]} {
		if {[file readable [Join $file]]} {
			set f [open [Join $file] rb]
			set ::checksum($file) [::zlib::crc [read $f]]
			close $f
		} else {
			set ::checksum($file) -1
		}
	}
	return $::checksum($file)
}

proc FetchFile {file srvCrc} {
	set url [MakeUrl $file]
	set retry 1

	while {$retry > 0} {
		set token [::http::geturl $url {*}$::GetUrlArgs]

		switch [::http::status $token] {
			ok {
				set data [::http::data $token]
				set crc [::zlib::crc $data]
				if {$crc ne $srvCrc} {
					if {$::Terminate} { Return aborted }
					if {[incr retry] > $::MaxRetry} { return 0 }
				} else {
					set file [Join $file]
					file mkdir [file dirname $file]
					set f [open $file.tmp wb]
					puts -nonewline $f $data
					close $f
					file rename -force $file.tmp $file
					set retry 0
				}
			}
			timeout {
				if {$::Terminate} { Return aborted }
				if {[incr retry] > $::MaxRetry} { Return timeout [MakeFile $url] }
				# is there a more convinient way to reset the connection?
				catch { ::http::geturl $url. -binary 1 -keepalive 0 -timeout 1 }
				after $::Wait ;# wait a bit
			}
			error {
				Return httperr [::http::error $token] [MakeFile $url]
			}
		}

		::http::cleanup $token
	}

	if {$::Terminate} { Return aborted }
	return 1
}

fileevent stdin readable [namespace current]::Terminate
::http::config -urlencoding utf-8

if {[info exists env(http_proxy)]} {
	set i [string last : $env(http_proxy)]
	if {$i >= 0} {
		set host [string range $env(http_proxy) 0 [expr {$i - 1}]]
		set port [string range $env(http_proxy) [expr {$i + 1}] end]
		if {[string is integer -strict $port]} {
			::http::config -proxyhost $host -proxyport $port
		}
	}
}

set locTimestamp ""
if {[file readable $TimestampFile]} {
	set f [open $TimestampFile r]
	set locTimestamp [string trim [read $f]]
	close $f
}

if {[string length locTimestamp] > 0} {
	set url [MakeUrl TIMESTAMP]
	set retry 1
	while {$retry > 0} {
		set token [::http::geturl $url {*}$GetUrlArgs]
		switch [::http::status $token] {
			ok		{ set retry 0 }
			error	{ Return httperr [::http::error $token] [MakeUrl $url] }
			timeout {
				if {[incr retry] > $::MaxRetry} { Return timeout [MakeUrl $url] }
				# is there a more convinient way to reset the connection?
				catch { ::http::geturl $url. -binary 1 -keepalive 0 -timeout 1 }
				after $::Wait ;# wait a bit
			}
		}
	}
	set code [::http::ncode $token]
	set http [::http::code $token]
	set srvTimestamp [string trim [::http::data $token]]
	::http::cleanup $token
	if {$code == 404} { Return maintenance }
	if {$code != 200} { Return httperr $http [MakeFile $url] }
}

if {$srvTimestamp eq $locTimestamp} { Return uptodate }

set url [MakeUrl FILES]
set retry 1
while {$retry > 0} {
	set token [::http::geturl $url {*}$GetUrlArgs]
	switch [::http::status $token] {
		ok		{ set retry 0 }
		error	{ Return httperr [::http::error $token] [MakeUrl $url] }
		timeout {
			if {[incr retry] > $::MaxRetry} { Return timeout [MakeUrl $url] }
			# is there a more convinient way to reset the connection?
			catch { ::http::geturl $url. -binary 1 -keepalive 0 -timeout 1 }
			after $::Wait ;# wait a bit
		}
	}
}
set code [::http::ncode $token]
set http [::http::code $token]
set content [::http::data $token]
::http::cleanup $token
if {$code == 404} { Return maintenance }
if {$code != 200} { Return httperr $http [MakeFile $url] }

set locFiles {}
if {[file readable $FilesFile]} {
	set f [open $FilesFile r]
	while {[gets $f line] > 0} { lappend locFiles [split $line " "] }
	close $f
	set locFiles [lsort -index 0 $locFiles]
}

set srvFiles {}
foreach {file crc} $content { lappend srvFiles [list $file $crc] }
set srvFiles [lsort -index 0 $srvFiles]

set fileList {}
set locn [llength $locFiles]; set srvn [llength $srvFiles]
set srvi 0; set loci 0

puts [list total $srvn]

while {$loci < $locn && $srvi < $srvn} {
	lassign [lindex $srvFiles $srvi] srvFile srvCrc
	lassign [lindex $locFiles $loci] locFile locCrc

	switch [string compare $locFile $srvFile] {
		-1 {
			# File does not exist anymore on server,
			# but only delete if not user-written:
			if {$locCrc != [Checksum $locFile]} {
				if {![catch { file delete $locFile }]} {
					puts [list deleted $locFile]
				}
			}
			incr srvi
		}
		1 {
			# It's a new file, but only write if not user-written:
			if {![file exists $srvFile]} {
				if {[FetchFile $srvFile $srvCrc]} {
					puts [list created $srvFile]
				} else {
					puts [list crcerror $srvFile]
				}
			} elseif {[Checksum $srvFile] != $srvCrc} {
				puts [list skipped $srvFile]
			}
			incr loci
		}
		0 {
			# Newer file, but only overwrite if not user-written:
			if {[Checksum $locFile] != $locCrc} {
				if {[FetchFile $srvFile $srvCrc]} {
					puts [list updated $srvFile]
				} else {
					puts [list crcerror $srvFile]
				}
			} elseif {[Checksum $locFile] != $srvCrc} {
				puts [list skipped $srvFile]
			}
			incr srvi; incr loci
		}
	}

	puts [list progress $srvi]
}

for {} {$loci < $locn} {incr loci} {
	lassign [lindex $locFiles $loci] locFile locCrc
	# File does not exist anymore on server,
	# but only delete if not user-written:
	if {$locCrc != [Checksum $locFile]} {
		if {![catch { file delete $locFile }]} {
			puts [list deleted $locFile]
		}
	}
}

for {} {$srvi < $srvn} {incr srvi} {
	lassign [lindex $srvFiles $srvi] srvFile srvCrc
	# It's a new file, but only write if not user-written:
	set crc [Checksum $srvFile]
	if {$crc == -1} {
		if {[FetchFile $srvFile $srvCrc]} {
			puts [list created $srvFile]
		} else {
			puts [list crcerror $srvFile]
		}
	} elseif {$crc != $srvCrc} {
		puts [list skipped $srvFile]
	}

	puts [list progress $srvi]
}

set tmpfile [Join .FILES]
set f [open $tmpfile w]
foreach entry $srvFiles { puts $f $entry }
close $f
file rename -force $tmpfile $FilesFile

set tmpfile [Join .TIMESTAMP]
set f [open $tmpfile w]
puts $f $srvTimestamp
close $f
file rename -force $tmpfile $TimestampFile

Return finished

# vi:set ts=3 sw=3:
