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

namespace eval util {
namespace eval photos {
namespace eval mc {

set InstallPlayerPhotos			"Install/Update Player Photos"
set TimeOut							"Timeout occurred."
set EnterPassword					"Enter Password"
set Download						"Download"
set SharedInstallation			"Shared installation"
set LocalInstallation			"Private installation"
set RetryLater						"Please retry later."
set DownloadStillInProgress	"Download of photo files is still in progress."
set PhotoFiles						"Photo Files"
set DownloadAborted				"Download aborted."

set RequiresSuperuserRights	"The installation/update requires super-user rights.\n\nNote that the password will not be accepted if your user is not in the sudoers file. As a workaround you may do a private installation, or start this application as a super-user."
set RequiresInternetAccess		"The installation/update of the player photo files requires an internet connection."
set AlternativelyDownload(0)	"Alternatively you may download the photo files from %link%. Install these files into directory %local%."
set AlternativelyDownload(1)	"Alternatively you may download the photo files from %link%. Install these files into the shared directory %shared%, or into the private directory %local%."

set Error(nohttp)					"Cannot open an internet connection because package TclHttp is not installed."
set Detail(nohttp)				"Please install package TclHttp, for example %s."
set Error(busy)					"The installation/update is already running."
set Error(failed)					"Unexpected error: The invocation of the sub-process has failed."
set Error(passwd)					"The password is wrong."
set Error(nosudo)					"Cannot invoke 'sudo' command."

set Message(uptodate)			"The photo files are already up-to-date."
set Message(finished)			"The installation/update of photo files has finished."
set Message(broken)				"Broken Tcl library version."
set Message(noperm)				"You dont have write permissions for directory '%s'."
set Message(missing)				"Cannot find directory '%s'."
set Message(httperr)				"HTTP error: %s"
set Message(httpcode)			"Unexpected HTTP code %s."
set Message(badhost)				"HTTP connection failed due to a bad port."
set Message(timeout)				"HTTP timeout occurred. Possibly the file server is currently very busy."
set Message(crcerror)			"Checksum error occurred. Possibly the file server is currently in maintenance mode."
set Message(maintenance)		"Photo file server maintenance is currently in progress."
set Message(notfound)			"Download aborted because photo file server maintenance is currently in progress."
set Message(aborted)				"User has aborted download."
set Message(killed)				"Unexpected termination of download. The sub-process has died."

set Log(started)					"Installation/update of photo files started at %s."
set Log(finished)					"Installation/update of photo files finished at %s."
set Log(destination)				"Destination directory for photo file download is '%s'."
set Log(created)					"%s file(s) created."
set Log(deleted)					"%s file(s) deleted."
set Log(skipped)					"%s file(s) skipped."
set Log(updated)					"%s file(s) updated."

}

set Busy 0
set Pipe {}
set Sourceforge http://sourceforge.net/projects/scidb/files


proc openDialog {parent} {
	variable Sourceforge
	variable Shared

	set Shared 0
	set haveShared 0
#	if {$::tcl_platform(platform) eq "unix" && ![string match /home* $::scidb::dir::share]} {
#		set haveShared 1
#	}

	set dlg [toplevel $parent.installPlayerPhotos -class Scidb]
	set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]
	pack $top -fill both
	wm withdraw $dlg

	set bg [$dlg cget -background]
	set css [::html::defaultCSS [::font::htmlFixedFamilies] [::font::htmlTextFamilies]]
	append css "body { background-color:$bg; }"
	::html $top.info \
		-center no \
		-fittowidth yes \
		-fittoheight yes \
		-width 420 \
		-borderwidth 0 \
		-doublebuffer no \
		-exportselection yes \
		-background $bg \
		-cursor left_ptr \
		-showhyphens 1 \
		-css $css \
		-usehorzscroll no \
		-usevertscroll no \
		-takefocus 0 \
		;
	$top.info handler node a [namespace current]::A_NodeHandler
	$top.info onmouseover [namespace code [list MouseEnter $top.info]]
	$top.info onmouseout [namespace code [list MouseLeave $top.info]]
	$top.info onmouseup1 [namespace code [list Mouse1Up $top.info]]
	grid $top.info -row 0 -column 0
	set link "<a href='$Sourceforge'>Sourceforge</a> ([::html::formatUrl $Sourceforge])"
	set shared [::html::formatPath [file dirname [InstallDir 1]]]
	set local [::html::formatPath [file dirname [InstallDir 0]]]
	set alternate $mc::AlternativelyDownload($haveShared)
	set msg1 $mc::RequiresInternetAccess
	set msg2 [string map [list %link% $link %shared% $shared %local% $local] $alternate]
	set content "<p>$msg1</p><p>$msg2</p>"
	$top.info parse $content

	if {$::tcl_platform(platform) eq "unix" && ![string match /home* $::scidb::dir::share]} {
		ttk::separator $top.sep -orient horizontal
		set f [ttk::frame $top.f -borderwidth 0 -takefocus 0]
		if {![file readable [file join $::scidb::dir::user photos TIMESTAMP]]} { set Shared 1 }
	
		ttk::radiobutton $f.local \
			-text $mc::LocalInstallation \
			-variable [namespace current]::Shared \
			-command [namespace code [list UpdateDir $f.dir]] \
			-value 0 \
			;
		ttk::radiobutton $f.shared \
			-text $mc::SharedInstallation \
			-variable [namespace current]::Shared \
			-command [namespace code [list UpdateDir $f.dir]] \
			-value 1 \
			;

		tk::label $f.dir -borderwidth 1 -relief sunken
		UpdateDir $f.dir

		grid $f.local  -row 4 -column 1 -sticky w
		grid $f.shared -row 4 -column 3 -sticky w
		grid $f.dir    -row 6 -column 1 -sticky w -columnspan 3 -sticky ew
		grid columnconfigure $f {0 2 4} -minsize $::theme::padx
		grid rowconfigure $f {1 3 5 7 9} -minsize $::theme::pady
		grid rowconfigure $f {9} -minsize $::theme::padY

		grid $top.sep -row 2 -column 0 -sticky we
		grid $f -row 3 -column 0
	}

	if {!$Shared} { catch { file mkdir [InstallDir 0] } }

	::widget::dialogButtons $dlg {cancel}
	::widget::dialogButtonAdd $dlg download [namespace current]::mc::Download $icon::16x16::download
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.download configure -command [namespace code [list Download $parent $dlg]]

	wm resizable $dlg no no
	wm title $dlg $mc::InstallPlayerPhotos
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg center $parent
	wm deiconify $dlg
}


proc downloadFiles {informProc shared parent} {
	variable Busy
	variable Terminate

	if {[llength [package versions http]] == 0} { return nohhtp }
	if {$Busy} { return busy }

	set result ok
	::widget::busyCursor on
	if {[catch { OpenPipe $informProc $shared $parent } result]} { set result failed }
	::widget::busyCursor off
	return $result
}


proc terminateUpdate {} {
	variable Pipe
	variable Busy

	if {[llength $Pipe]} {
		puts $Pipe terminate
		vwait [namespace current]::Pipe
	}
}


proc busy? {} {
	return [set [namespace current]::Busy]
}


proc get {name info} {
	set key [NormalizeName $name]
	set file [FindPhotoFile $key]
	set found $file
	set img ""

	if {[string length $found] == 0} {
		set aliases [lindex $info 20]

		foreach alias $aliases {
			set key [NormalizeName $alias]
			set file [find $key]
			if {[string length $file]} {
				set found $file
				break
			}
		}
	}

	if {[string length $found] > 0} {
		catch {
			set fd [open $found rb]
			set data [read $fd]
			close $fd
			catch {set img [image create photo -data $data]}
		}
	}

	return $img
}


proc FindPhotoFile {name} {
	set dir [string index $name 0]
	if {![string match {[a-z]} $dir]} { return "" }
	set path [file join $::scidb::dir::user photos $dir $name]
	if {[file readable $path]} { return $path }
	set path [file join $::scidb::dir::photos $dir $name]
	if {[file readable $path]} { return $path }
	return ""
}


proc NormalizeName {name} {
	set key [string map {. "" " " "" - ""} [string tolower $name]]
	set index [string last ",dr" $key]
	if {$index >= 0} { set key [string range $key 0 [expr {$index - 1}]] }
	return $key
}


proc OpenPipe {informProc shared parent} {
	variable Pipe
	variable Busy
	global tcl_platform
	global env

	set script "%UPDATE_PHOTO_FILES%"
	if {[string match ?UPDATE_PHOTO_FILES? $script]} {
		set script /usr/local/bin/update-scidb-photo-files
	}
	set cmd [file join $::scidb::dir::exec $script]

	if {$shared && $tcl_platform(platform) eq "unix" && [exec id -u] != 0} {
		set sudo [auto_execok sudo]
		if {[string length $sudo] == 0} { return nosudo }
		lassign [AskPassword $parent] passwd result
		update idletasks
		if {$result ne "ok"} { return cancelled }
		if {[catch { exec echo $passwd | $sudo -v -S }]} { return nosudo }
		if {[catch { exec echo $passwd | $sudo -S echo "" }]} { return passwd }
		lassign {"" ""} arg1 arg2
		if {[info exists env(LD_LIBRARY_PATH)] && [string length $env(LD_LIBRARY_PATH)]} {
			set arg1 $env(LD_LIBRARY_PATH)
		}
		if {[info exists env(http_proxy)] && [string length $env(http_proxy)]} {
			if {[string length $arg1] == 0} { set arg1 {""} }
			set arg2 $env(http_proxy)
		}
		set cmd [string trim "$sudo -S $cmd $arg1 $arg2"]
	}

	set Pipe [open "| $cmd" r+]
	fconfigure $Pipe -buffering line -blocking 0
	fileevent $Pipe readable $informProc
	set Busy 1
}


proc Download {parent dlg} {
	variable Shared
	variable Count
	variable Finished

	set Finished 0
	array set Count { deleted 0 created 0 skipped 0 updated 0 }
	set result [downloadFiles [namespace code [list ProcessUpdate $parent]] $Shared $parent]

	switch $result {
		nohhtp {
			::dialog::error \
				-parent $dlg \
				-message $mc::Error(nohttp) \
				-detail [format $mc::Detail(nohttp) {"sudo apt-get install tclhttp"}] \
				;
		}
		failed	{ ::dialog::error -parent $dlg -message $mc::Error(failed) }
		passwd	{ ::dialog::error -parent $dlg -message $mc::Error(passwd) }
		nosudo	{ ::dialog::error -parent $dlg -message $mc::Error(nosudo) }
		busy		{ ::dialog::error -parent $dlg -message $mc::Error(busy) }
		ok			{ destroy $dlg }
	}
}


proc LogProgress {type msg} {
	variable Count

	::log::open $mc::PhotoFiles
	::log::$type $msg
	foreach attr {created deleted skipped updated} {
		if {$Count($attr) > 0} { ::log::info [format $mc::Log($attr) $Count($attr)] }
	}
	if {$type eq "error"} { ::log::info $mc::DownloadAborted }
	::log::close
}


proc ProcessUpdate {parent} {
	variable Pipe
	variable Count
	variable Finished

	set data ""
	catch { set data [gets $Pipe] }

	set arg ""
	lassign $data reason arg url

	switch $reason {
		maintenance {
			::dialog::info -parent $parent -message $mc::Message($reason) -detail $mc::RetryLater
		}

		aborted { ;# no action }

		uptodate {
			catch { destroy $parent.downloadPlayerPhotos }
			::dialog::info -parent $parent -message $mc::Message($reason)
		}

		finished {
			catch { destroy $parent.downloadPlayerPhotos }
			::dialog::info -parent $parent -message $mc::Message($reason)
			LogProgress info [format $mc::Log(finished) [::locale::currentTime]]
		}

		broken - noperm - missing - nohttp {
			if {[info exists mc::Message($reason)]} {
				set msg $mc::Message($reason)
			} else {
				set msg $mc::Error($reason)
			}
			if {[string match *%s* $msg]} { set msg [format $msg $arg] }
			::dialog::error -parent $parent -message $msg
		}

		httperr - httpcode - timeout - crcerror - badhost - notfound {
			set msg $mc::Message($reason)
			if {[string match *%s* $msg]} { set msg [format $msg $arg] }
			LogProgress error "$msg ([::locale::currentTime])"
			set details ""
			switch $reason { timeout - crcerror { set details $mc::RetryLater } }
			::dialog::error -parent $parent -message $msg -detail $details
		}

		deleted - created - skipped - updated {
			incr Count($reason)
			::dialog::progressbar::setInformation $parent.downloadPlayerPhotos $arg
		}

		total {
			::log::open $mc::PhotoFiles
			::log::info [format $mc::Log(started) [::locale::currentTime]]
			::log::info [format $mc::Log(destination) [InstallDir]]
			::log::close

			catch { destroy $parent.installPlayerPhotos }
			::dialog::progressBar $parent.downloadPlayerPhotos \
				-title $::progress::mc::Progress \
				-maximum $arg \
				-message $mc::InstallPlayerPhotos \
				;
			bind $parent.downloadPlayerPhotos <<LanguageChanged>> \
				[namespace code [list LanguageChanged $parent.downloadPlayerPhotos]]
			update idletasks
		}

		progress { ::dialog::progressbar::tick $parent.downloadPlayerPhotos }

		terminated { set Finished 1 }
	}

	set eof 0
	if {[catch { eof $Pipe } eof]} { set eof 1 }

	if {$eof} {
		variable Busy
		set Busy 0
		catch { destroy $parent.installPlayerPhotos }
		catch { destroy $parent.downloadPlayerPhotos }
		catch { close $Pipe }
		set Pipe {}
		if {!$Finished} { LogProgress error $mc::Message(killed) }
		return
	}
}


proc LanguageChanged {pb} {
	::dialog::progressbar::setMessage $pb $mc::InstallPlayerPhotos
	::dialog::progressbar::setTitle $pb $::progress::mc::Progress
}


proc AskPassword {parent} {
	variable _result
	variable _passwd

	set _passwd ""
	set _result ""

	if {$parent eq "."} { set dlg .ask } else { set dlg $parent.ask }
	toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top -borderwidth 1]
	pack $top -fill both
	wm title $dlg $mc::EnterPassword
	wm resizable $dlg no no
	wm protocol $dlg WM_DELETE_WINDOW [list set [namespace current]::_result cancel]

	tk::label $top.m \
		-text $mc::RequiresSuperuserRights \
		-wraplength 350 \
		-justify left \
		-borderwidth 0 \
		-padx $::theme::padx \
		-pady $::theme::pady \
		;
	ttk::separator $top.s -orient horizontal
	ttk::label $top.l -text "$mc::EnterPassword:"
	ttk::entry $top.e -show * -textvar [namespace current]::_passwd
	grid $top.m -row 1 -column 0 -columnspan 5
	grid $top.s -row 2 -column 0 -columnspan 5 -sticky ew
	grid $top.l -row 4 -column 1 -sticky ew
	grid $top.e -row 4 -column 3 -sticky ew
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid columnconfigure $top {3} -weight 1
	grid rowconfigure $top {3 5}  -minsize $::theme::padY

	::widget::dialogButtons $dlg {ok cancel} ok
	$dlg.ok configure -command [list set [namespace current]::_result ok]
	$dlg.cancel configure -command [list set [namespace current]::_result cancel]

	bind $dlg <Return> [list $dlg.ok invoke]
	bind $dlg <Escape> [list $dlg.cancel invoke]

	::util::place $dlg center $parent
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	focus $top.e
	vwait [namespace current]::_result
	::ttk::releaseGrab $dlg
	destroy $dlg

	return [list $_passwd $_result]
}


proc UpdateDir {w} {
	$w configure -text [file dirname [InstallDir]]
}


proc InstallDir {{shared {}}} {
	if {[llength $shared] == 0} { set shared [set [namespace current]::Shared] }
	if {$shared} { return $::scidb::dir::photos }
	return [file join $::scidb::dir::user photos]
}


proc A_NodeHandler {node} {
	$node dynamic set link
}


proc MouseEnter {w node} {
	if {[llength $node]} {
		set href [$node attribute -default {} href]
		if {[string length $href]} {
			$node dynamic set user
			$w configure -cursor hand2
		}
	}
}


proc MouseLeave {w node} {
	if {[llength $node]} {
		set href [$node attribute -default {} href]
		if {[string length $href]} {
			$node dynamic clear user
			$w configure -cursor {}
		}
	}
}


proc Mouse1Up {w node} {
	if {[llength $node]} {
		set href [$node attribute -default {} href]
		if {[string length $href]} {
			::web::open $w $href
			$node dynamic clear link
			$node dynamic set visited
		}
	}
}


namespace eval icon {
namespace eval 16x16 {

set download [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAiZJ
	REFUOI2lk01IVFEYhp9z79w7OjPqNA5FGZZRlAUlbtpk7SqC6GcjRC3atBCirYvIdi1DcBXl
	tkUlluJPm4zshyJTMEEJ1AxiCp0YHefOnXvP1+I2YTPjqg++xXl53/f7OefAf4YqBUbutJKs
	3ZOJrGZigoAELD+RzMiB8/Ejx9v/4YdKDfLpeVX9fammed0OAFEg8DVRqN117WFZB2UGXjaN
	JgZ2KKgugFb4Xq7iCGUGygBlmqAlAHRgYtjW5gbj3UfPplPzraIsMMLK8H1wnT/VgzRi9Ty7
	Fe/CczCUT3xr08CxG28nQgC2++v0yWhNh6WMYK35QtDB3xFgp+OoBqvqNmYUV1nyIRRPABMm
	QEty+V12LXepKaLrlO+gxANTEEPABCwB00N5Dspxeb70MzW3OHN5aJo1E2Bomty+Bu/Ttphx
	JRk1DTEBW6BGBxn1oUqgSpjJ5GRkMdve2c8kBP4AvJhjYf+OQvjgdqvNrhWo01CtA2FYwIZV
	V/NoKtt9c5Ceos7YuNHlnHSNLmTfS8yHiA9RHWRMI9Wa4enc5I816dyoMTceXn5B707osUiE
	q42NKky4WF14/dHLDk+4p+6OkdrUAODNPCuJkJ9q3mueq6sHwsLSN+H+0/z1nnFGS/lGKUBw
	i729A/nHjtbkC8KDJ27feoF7lbhln6kYFw+x5UybOYUH/a/8lsFZVirxyp5yMfo+kz5x2Lzg
	esjgrF9RDPAbJtzjfSOffQoAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace photos
} ;# namespace util

# vi:set ts=3 sw=3:
