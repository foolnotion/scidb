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
# Copyright: (C) 2012-2018 Gregor Cramer
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
set PhotoFiles						"Player Photo Files"
set DownloadAborted				"Download aborted."

set RequiresSuperuserRights	"The installation/update requires super-user rights.\n\nNote that the password will not be accepted if your user is not in the sudoers file."
set RequiresInternetAccess		"The installation/update of the player photo files requires an internet connection."
set AlternativelyDownload(0)	"Alternatively you may download the photo files from %link%. Install these files into directory %local%."
set AlternativelyDownload(1)	"Alternatively you may download the photo files from %link%. Install these files into the shared directory %shared%, or into the private directory %local%."

set Error(nohttp)					"Cannot open an internet connection because package TclHttp is not installed."
set Error(busy)					"The installation/update is already running."
set Error(failed)					"Unexpected error: The invocation of the sub-process has failed."
set Error(passwd)					"The password is wrong."
set Error(nosudo)					"Cannot invoke 'sudo' command because your user is not in the sudoers file."
set Detail(nosudo)				"As a workaround you may do a private installation, or start this application as a super-user."

set Message(uptodate)			"The photo files are still up-to-date."
set Message(finished)			"The installation/update of photo files has finished."
set Message(broken)				"Broken Tcl library version."
set Message(noperm)				"You dont have permissions for creating directory '%s'."
set Message(httperr)				"HTTP error: %s"
set Message(httpcode)			"Unexpected HTTP code %s."
set Message(noconnect)			"HTTP connection failed."
set Message(timeout)				"HTTP timeout occurred. Possibly the file server is currently very busy."
set Message(crcerror)			"Checksum error occurred. Possibly the file server is currently in maintenance mode."
set Message(maintenance)		"Photo file server maintenance is currently in progress."
set Message(notfound)			"Download aborted because photo file server maintenance is currently in progress."
set Message(noreply)				"Server is not replying."
set Message(aborted)				"User has aborted download."
set Message(killed)				"Unexpected termination of download. The sub-process has died."

set Detail(nohttp)				"Please install package TclHttp, for example %s."
set Detail(noconnect)			"Probably you don't have an internet connection."
set Detail(badhost)				"Another possibility is a bad host, or a bad port."

set Log(started)					"Installation/update of photo files started at %s."
set Log(finished)					"Installation/update of photo files finished at %s."
set Log(destination)				"Destination directory for photo file download is '%s'."
set Log(created:1)				"%s file created."
set Log(created:N)				"%s file(s) created."
set Log(deleted:1)				"%s file deleted."
set Log(deleted:N)				"%s file(s) deleted."
set Log(skipped:1)				"%s file skipped."
set Log(skipped:N)				"%s file(s) skipped."
set Log(updated:1)				"%s file updated."
set Log(updated:N)				"%s file(s) updated."

}


array set Options {
	url:player-photos	http://sourceforge.net/projects/scidb/Files
	notify:timeout		7000
	use-gksudo			0
}

array set Priv {
	busy 0
	pipe {}
}


proc openDialog {parent} {
	variable Options
	variable Priv

	set haveShared 0
	if {$::tcl_platform(platform) eq "unix" && ![string match /home* $::scidb::dir::share]} {
		set haveShared 1
	}

	set dlg [toplevel $parent.installPlayerPhotos -class Scidb]
	set top [ttk::frame $dlg.top -borderwidth 0 -takefocus 0]
	pack $top -fill both
	wm withdraw $dlg

	set bg [$dlg cget -background]
	set css [::html::defaultCSS [::font::html::fixedFonts] [::font::html::textFonts]]
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
		-cursor standard \
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
	append link "<a href='$Options(url:player-photos)'>Sourceforge</a> "
	append link "([::html::formatUrl $Options(url:player-photos)])"
	set shared [::html::formatPath [file dirname [InstallDir 1]]]
	set local [::html::formatPath [file dirname [InstallDir 0]]]
	set alternate $mc::AlternativelyDownload($haveShared)
	set msg1 $mc::RequiresInternetAccess
	set msg2 [string map [list %link% $link %shared% $shared %local% $local] $alternate]
	set content "<p>$msg1</p><p>$msg2</p>"
	$top.info parse $content

	if {$haveShared} {
		ttk::separator $top.sep -orient horizontal
		set f [ttk::frame $top.f -borderwidth 0 -takefocus 0]
		set timestamp(local)  [file join $::scidb::dir::user photos TIMESTAMP]
		set timestamp(shared) [file join $::scidb::dir::photos TIMESTAMP]

		# Determine the last update folder: local or shared
		if {![file readable $timestamp(local)]} {
			set Priv(shared) 1
		} elseif {![file readable $timestamp(shared)]} {
			set Priv(shared) 0
		} elseif {[file mtime [InstallDir 1]] >= [file mtime [InstallDir 0]]} {
			set Priv(shared) 1
		} else {
			set Priv(shared) 0
		}
	
		ttk::radiobutton $f.local \
			-text $mc::LocalInstallation \
			-variable [namespace current]::Priv(shared) \
			-command [namespace code [list UpdateDir $f.dir]] \
			-value 0 \
			;
		ttk::radiobutton $f.shared \
			-text $mc::SharedInstallation \
			-variable [namespace current]::Priv(shared) \
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

	if {!$Priv(shared)} { catch { file mkdir [InstallDir 0] } }

	::widget::dialogButtonAdd $dlg download [namespace current]::mc::Download $icon::16x16::download
	::widget::dialogButtons $dlg {cancel}
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.download configure -command [namespace code [list Download $parent $dlg]]

	wm resizable $dlg no no
	wm title $dlg $mc::InstallPlayerPhotos
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg -parent $parent -position center
	wm deiconify $dlg
}


proc downloadFiles {informProc shared parent} {
	variable Priv

	if {[llength [package versions http]] == 0} { return nohhtp }
	if {$Priv(busy)} { return busy }

	set result ok
	::widget::busyCursor on
	if {[catch { OpenPipe $informProc $shared $parent } result]} { set result failed }
	::widget::busyCursor off
	return $result
}


proc terminateUpdate {} {
	variable Priv

	if {[llength $Priv(pipe)]} {
		puts $Priv(pipe) terminate
		after 2000 [namespace code [list ForceTermination]]
		vwait [namespace current]::Priv(pipe)
	}
}


proc busy? {} {
	return [set [namespace current]::Priv(busy)]
}


proc get {name {info {}}} {
	set file [findPhotoFile $name]
	set found $file
	set img ""

	if {[string length $found] == 0 && [llength $info]} {
		set aliases [lindex $info 20]

		foreach alias $aliases {
			set file [findPhotoFile $alias]
			if {[string length $file]} {
				set found $file
				break
			}
		}
	}

	if {[string length $found] > 0} {
		catch { set img [image create photo -data [::file::read $found -translation binary]] }
	}

	return $img
}


proc findPhotoFile {name} {
	set key [NormalizeName $name]
	set dir [string index $key 0]
	if {![string match {[a-z]} $dir]} { return "" }
	set path [file join $::scidb::dir::user photos $dir $key]
	if {[file readable $path]} { return $path }
	set path [file join $::scidb::dir::photos $dir $key]
	if {[file readable $path]} { return $path }
	return ""
}


proc checkForUpdate {informProc} {
	global env

# XXX server does not exist anymore
return

	if {[catch {package require http 2.7}]} { return 0 }
	if {[info exists env(http_proxy)]} { set http_proxy $env(http_proxy) } else { set http_proxy "" }
	set i [string last : $http_proxy]
	if {$i >= 0} {
		set host [string range $http_proxy 0 [expr {$i - 1}]]
		set port [string range $http_proxy [expr {$i + 1}] end]
		if {[string is integer -strict $port]} { ::http::config -proxyhost $host -proxyport $port }
	}
	::http::config -urlencoding utf-8
	catch {
		::http::geturl http://scidb-player-photos.googlecode.com/svn/trunk/TIMESTAMP \
			-binary 1 \
			-command [namespace code [list CheckForUpdateResponse $informProc]] \
			-timeout 10000 \
			;
	}
}


proc pleaseInstallHttp {parent} {
	::dialog::error \
		-parent $parent \
		-message $mc::Error(nohttp) \
		-detail [format $mc::Detail(nohttp) {"sudo apt-get install tclhttp"}] \
		;
}


proc CheckForUpdateResponse {informProc token} {
	set shared [InstallDir 1]
	set local [InstallDir 0]
	set code [::http::ncode $token]
	set state [::http::status $token]
	set srvTimestamp [string trim [::http::data $token]]
	::http::cleanup $token
	if {$state ne "ok" || $code != 200} { return }
	set locTimestamp [ReadTimestamp [InstallDir 1]] ;# shared
	set timestamp [ReadTimestamp [InstallDir 0]] ;# private
	if {[string length $timestamp]} {
		if {[string length $locTimestamp] == 0 || [string compare $locTimestamp $timestamp] < 0} {
			set locTimestamp $timestamp
		}
	}
	if {$srvTimestamp ne $locTimestamp} { $informProc photos }
}


proc ReadTimestamp {dir} {
	set timestamp ""
	set file [file join $dir TIMESTAMP]
	if {[file readable $file]} {
		set timestamp [string trim [::file::read $file]]
	}
	return $timestamp
}


proc NormalizeName {name} {
	set key [string map {. "" " " "" - ""} [string tolower $name]]
	set index [string last ",dr" $key]
	if {$index >= 0} { set key [string range $key 0 [expr {$index - 1}]] }
	return $key
}


proc OpenPipe {informProc shared parent} {
	variable Priv
	variable Options
	global tcl_platform
	global env

	set script "%UPDATE_PHOTO_FILES%"
	if {	[string match ?UPDATE_PHOTO_FILES? $script]
		|| ![file executable [set script [file join $::scidb::dir::exec $script]]]} {
		set script /usr/local/bin/update-scidb-photo-files
		if {![file executable $script]} { set script /usr/bin/update-scidb-photo-files }
	}
	if {![file executable $script]} { return script }

	set Priv(empty) 1
	set Priv(vwait) 0
	set passwd ""

	if {$shared && $tcl_platform(platform) eq "unix" && [exec id -u] != 0} {
		if {$Options(use-gksudo) && [string length [set gksudo [auto_execok gksudo]]]} {
			set msg [lindex [split $mc::RequiresSuperuserRights \n] 0]
			set cmd "$gksudo -g -k -m \"$msg\" $script"
			set Priv(vwait) 1
		} else {
			variable Result_
			global env

			set sudo [auto_execok sudo]
			if {[string length $sudo] == 0} { return failed }
			lassign [AskPassword $parent.installPlayerPhotos] passwd result
			update idletasks
			if {$result ne "ok"} { return cancelled }
			catch { exec sudo -k }
			if {[catch { open "| echo $passwd | $sudo -S echo \"\" 2>@1" r } sudoPipe ]} {
				return failed
			}
			fconfigure $sudoPipe -buffering none -blocking 1
			fileevent $sudoPipe readable [namespace code [list ReadPipe $sudoPipe]]
			set Result_ ""
			update idletasks
			while {![eof $sudoPipe]} { vwait [namespace current]::Result_ }
			catch { close $sudoPipe }
			if {[string match *:*:* $Result_]} { return passwd }
			if {[string match {* incorrect *} $Result_]} { return passwd }
			if {[string match {* sudoers *} $Result_]} { return nosudo }
#			lassign {"" ""} arg1 arg2
#			if {[info exists env(LD_LIBRARY_PATH)] && [string length $env(LD_LIBRARY_PATH)]} {
#				set arg1 $env(LD_LIBRARY_PATH)
#			}
#			if {[info exists env(http_proxy)] && [string length $env(http_proxy)]} {
#				if {[string length $arg1] == 0} { set arg1 {""} }
#				set arg2 $env(http_proxy)
#			}
#			set cmd [string trim "$sudo -S -n $script $arg1 $arg2"]
			set cmd "$sudo -E -S -n -- $script"
		}
	}

	set Priv(pipe) [open "| $cmd" r+]
	fconfigure $Priv(pipe) -buffering line -blocking 0
	fileevent $Priv(pipe) readable $informProc
	if {[string length $passwd]} { puts $Priv(pipe) $passwd }
	set Priv(busy) 1
	if {$Priv(vwait) && ![eof $Priv(pipe)]} { tkwait variable [namespace current]::Priv(vwait) }
}


proc Download {parent dlg} {
	variable Priv

	set Priv(finished) 0
	set Priv(started) 0
	array set Priv { count:deleted 0 count:created 0 count:skipped 0 count:updated 0 }
	set result [downloadFiles [namespace code [list ProcessUpdate $parent]] $Priv(shared) $parent]

	switch $result {
		nohhtp	{ pleaseInstallHttp $dlg }
		failed	{ ::dialog::error -parent $dlg -message $mc::Error(failed) }
		passwd	{ ::dialog::error -parent $dlg -message $mc::Error(passwd) }
		nosudo	{ ::dialog::error -parent $dlg -message $mc::Error(nosudo) -detail $mc::Detail(nosudo) }
		busy		{ ::dialog::error -parent $dlg -message $mc::Error(busy) }
		ok			{ destroy $dlg }
	}
}


proc LogProgress {type msg} {
	variable Priv

	if {!$Priv(started)} { return }
	::log::open $mc::PhotoFiles
	::log::$type $msg
	foreach attr {created deleted skipped updated} {
		switch $Priv(count:$attr) {
			0			{}
			1			{ ::log::info [format $mc::Log($attr:1) $Priv(count:$attr)] }
			default	{ ::log::info [format $mc::Log($attr:N) $Priv(count:$attr)] }
		}
	}
	if {$type eq "error"} { ::log::info $mc::DownloadAborted }
	::log::close
}


proc ProcessUpdate {parent} {
	variable Priv
	variable Options

	set data ""
	catch { set data [gets $Priv(pipe)] }

	lassign {"" "" ""} reason arg url
	lassign $data reason arg url
	set Priv(vwait) 0

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
			if {[string length [set notify [auto_execok notify-send]]]} {
				exec $notify \
					--icon=scidb \
					--expire-time=$Options(notify:timeout) \
					--urgency=low \
					$mc::Message($reason)
			} else {
#				::dialog::info -parent $parent -message $mc::Message($reason)
			}
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

		httperr - httpcode - timeout - crcerror - noconnect - notfound - noreply {
			set msg $mc::Message($reason)
			if {[string match *%s* $msg]} { set msg [format $msg $arg] }
			LogProgress error "$msg ([::locale::currentTime])"
			set details ""
			switch $reason {
				timeout - crcerror {
					set details $mc::RetryLater
				}
				noconnect {
					global env
					set details $mc::Detail(noconnect)
					if {[info exists env(http_proxy)] && [string length $env(http_proxy)]} {
						append details " " $mc::Detail(badhost)
					}
				}
			}
			::dialog::error -parent $parent -message $msg -detail $details
		}

		deleted - created - skipped - updated {
			incr Priv(count:$reason)
			::dialog::progressbar::setInformation $parent.downloadPlayerPhotos [file tail $arg]
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
				-transient no \
				-message $mc::InstallPlayerPhotos \
				;
			bind $parent.downloadPlayerPhotos <<LanguageChanged>> \
				[namespace code [list LanguageChanged $parent.downloadPlayerPhotos]]
			update idletasks
			set Priv(started) 1
		}

		progress { ::dialog::progressbar::tick $parent.downloadPlayerPhotos }

		terminated { set Priv(finished) 1 }
	}

	set eof 0
	if {[catch { eof $Priv(pipe) } eof]} { set eof 1 }

	if {$eof} {
		ForceTermination
		if {!$Priv(finished) && $Priv(started)} { LogProgress error $mc::Message(killed) }
	}
}


proc ForceTermination {} {
	variable Priv

	set Priv(busy) 0
	catch { destroy $parent.installPlayerPhotos }
	catch { destroy $parent.downloadPlayerPhotos }
	catch { close $Priv(pipe) }
	set Priv(pipe) {}
}


proc LanguageChanged {pb} {
	::dialog::progressbar::setMessage $pb $mc::InstallPlayerPhotos
	::dialog::progressbar::setTitle $pb $::progress::mc::Progress
}


proc AskPassword {parent} {
	variable result_
	variable passwd_

	set passwd_ ""
	set result_ ""

	if {$parent eq "."} { set dlg .ask } else { set dlg $parent.ask }
	toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top -borderwidth 1]
	pack $top -fill both
	wm title $dlg $mc::EnterPassword
	wm resizable $dlg no no
	wm protocol $dlg WM_DELETE_WINDOW [list set [namespace current]::result_ cancel]

	tk::label $top.m \
		-text "$mc::RequiresSuperuserRights $mc::Detail(nosudo)" \
		-wraplength 350 \
		-justify left \
		-borderwidth 0 \
		-padx $::theme::padx \
		-pady $::theme::pady \
		;
	ttk::separator $top.s -orient horizontal
	ttk::label $top.l -text "$mc::EnterPassword:"
	ttk::entry $top.e -show * -textvar [namespace current]::passwd_
	grid $top.m -row 1 -column 0 -columnspan 5
	grid $top.s -row 2 -column 0 -columnspan 5 -sticky ew
	grid $top.l -row 4 -column 1 -sticky ew
	grid $top.e -row 4 -column 3 -sticky ew
	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid columnconfigure $top {3} -weight 1
	grid rowconfigure $top {3 5}  -minsize $::theme::padY

	::widget::dialogButtons $dlg {ok cancel}
	$dlg.ok configure -command [list set [namespace current]::result_ ok]
	$dlg.cancel configure -command [list set [namespace current]::result_ cancel]

	bind $dlg <Return> [list $dlg.ok invoke]
	bind $dlg <Escape> [list $dlg.cancel invoke]

	wm transient $dlg $parent
	::util::place $dlg -parent $parent -position center
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	focus $top.e
	vwait [namespace current]::result_
	::ttk::releaseGrab $dlg
	destroy $dlg

	return [list $passwd_ $result_]
}


proc ReadPipe {pipe} {
	variable Result_

	# IMPORTANT NOTE: don't use "append"
	set Result_ "${Result_}[read $pipe]"
}


proc UpdateDir {w} {
	$w configure -text [file dirname [InstallDir]]
}


proc InstallDir {{shared {}}} {
	if {[llength $shared] == 0} { set shared [set [namespace current]::Priv(shared)] }
	if {$shared} { return $::scidb::dir::photos }
	return [file join $::scidb::dir::user photos]
}


proc A_NodeHandler {node} {
	$node dynamic set link
}


proc MouseEnter {w nodes} {
	foreach node $nodes {
		set href [$node attribute -default {} href]
		if {[string length $href]} {
			$node dynamic set user
			$w configure -cursor hand2
		}
	}
}


proc MouseLeave {w nodes} {
	foreach node $nodes {
		set href [$node attribute -default {} href]
		if {[string length $href]} {
			$node dynamic clear user
			$w configure -cursor {}
		}
	}
}


proc Mouse1Up {w nodes} {
	foreach node $nodes {
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
