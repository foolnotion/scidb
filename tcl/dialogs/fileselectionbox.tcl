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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval dialog {

switch [tk windowingsystem] {
	aqua - win32 {
		# TODO use fsbox::verifyPath
		proc openFile  {args} { return [tk_getOpenFile {*}[fsbox::FilterArgs $args]] }
		proc saveFile  {args} { return [tk_getSaveFile {*}[fsbox::FilterArgs $args]] }
		proc chooseDir {args} { return [tk_chooseDirectory {*}[fsbox::FilterArgs $args]] }
	}

	x11 {
		proc openFile  {args} { return [fsbox::Open open {*}$args] }
		proc saveFile  {args} { return [fsbox::Open save {*}$args] }
		proc chooseDir {args} { return [fsbox::Open dir  {*}$args] }
	}
}


namespace eval fsbox {

array set Priv { lastFolder "" }
array set FileSizeCache {}

set FileIcons [list                        \
	.sci	$::icon::16x16::filetypeScidbBase \
	.si4	$::icon::16x16::filetypeScid4Base \
	.si3	$::icon::16x16::filetypeScid3Base \
	.cbh	$::icon::16x16::filetypeChessBase \
	.pgn	$::icon::16x16::filetypePGN       \
	.gz	$::icon::16x16::filetypePGN       \
	.zip	$::icon::16x16::filetypeZipFile   \
	.pdf	$::icon::16x16::filetypePDF       \
	.html	$::icon::16x16::filetypeHTML      \
	.htm	$::icon::16x16::filetypeHTML      \
	.tex	$::icon::16x16::filetypeTeX       \
	.ltx	$::icon::16x16::filetypeTeX       \
]

set FileEncodings [list \
	.sci 0 utf-8 \
	.si4 1 utf-8 \
	.si3 1 utf-8 \
	.cbh 1 $::encoding::windowsEncoding \
	.pgn 1 $::encoding::defaultEncoding \
	.gz  1 $::encoding::defaultEncoding \
	.zip 1 $::encoding::defaultEncoding \
]
if {$tcl_platform(platform) eq "windows"} {
	set FileEncodings(.cbh) [list 1 $::encoding::systemEncoding] ;# XXX ok?
}


proc geometry {{whichPart size}} {
	variable Priv

	set geom $Priv(geometry)
	if {$geom eq ""} { return "" }

	switch -glob -- $whichPart {
		*size {
			set geom [lindex [split [lindex [split $geom "-"] 0] "+"] 0]
		}
		*pos {
			set ip [string first "+" $geom]
			set im [string first "-" $geom]
			if {$im != -1 && ($im < $ip || $ip == -1)} { set ip $im }
			set geom [string range $geom $ip end]
		}
	}

	return $geom
}


proc fileIcons {} {
	return [set [namespace current]::FileIcons]
}


proc setFileTypes {w args} {
	::fsbox::setFileTypes $w.fsbox {*}$args
}


proc changeFileDialogType {w args} {
	::fsbox::changeFileDialogType $w.fsbox {*}$args
}


proc useSaveMode {w {flag 1}} {
	::fsbox::useSaveMode $w.fsbox $flag
}


proc saveMode {w} {
	return [::fsbox::saveMode $w.fsbox]
}


proc Open {type args} {
	variable Priv

	if {$type eq "dir"} {
		set dataName __choosedir
		set class "ChooseDir"
	} else {
		set dataName __filedialog
		set class "FileDialog"
	}

	upvar [namespace current]::$dataName data

	array set data {
		-parent				.
		-place				{}
		-geometry			""
		-embed				0
		-needencoding		0
		-rows					10
	}
	set opts(-initialdir) $Priv(lastFolder)
	set opts(-defaultencoding) {}

	array set data $args
	array set opts $args

	array unset opts -class
	array unset opts -embed
	array unset opts -geometry
	array unset opts -needencoding
	array unset opts -parent
	array unset opts -place
	array unset opts -rows
	array unset opts -title
	array unset opts -width

	if {![info exists Priv(geometry)]} { set Priv(geometry) "" }

	if {$data(-parent) eq "."} {
		set w .$dataName
	} else {
		set w $data(-parent).$dataName
	}

	if {$data(-embed) || ![winfo exists $w]} {
		set create 1
	} elseif {[winfo class $w] ne $class} {
		destroy $w
		set create 1
	} else {
		set create 0
	}

	if {$data(-embed)} {
		::ttk::frame $w -class $class -takefocus 0
		set dlg [winfo toplevel $w]
		bind $dlg <Destroy> [namespace code [list TraceLastFolder $dlg %W $w]]
	} elseif {$create} {
		toplevel $w -class $class
		bind $w <Configure> [namespace code [list RecordGeometry $w %W %w]]
		wm withdraw $w
		if {[winfo viewable [winfo toplevel $data(-parent)]]} {
			wm transient $w $data(-parent)
		}
		catch { wm attributes $w -type dialog }
	}

	set geometry $data(-geometry)
	if {[string match last* $geometry]} { set geometry [geometry $geometry] }
	set minh 350

	if {$data(-needencoding)} {
		if {[llength $opts(-defaultencoding)] == 0} {
			set opts(-defaultencoding) $::encoding::mc::AutoDetect
		}
	}

	if {$create} {
		if {$data(-needencoding)} {
			set opts(-selectencodingcommand) [namespace code [list SelectEncoding $type]]
			set opts(-fileencodings) [set [namespace current]::FileEncodings]
		}

		if {[string length $geometry] == 0} {
			set opts(-rows) 8
		}
		::fsbox $w.fsbox $type \
			-fileicons [fileIcons] \
			-sizecommand [namespace code GetFileSize] \
			-validatecommand [namespace code ValidateFile] \
			-deletecommand [namespace code DeleteFile] \
			-renamecommand [namespace code RenameFile] \
			-okcommand [namespace code OkCmd] \
			-cancelcommand [list set [namespace current]::Priv(result) {}] \
			-font TkTextFont \
			{*}[array get opts] \
			;
		grid $w.fsbox -column 0 -row 0 -sticky nsew
		grid columnconfigure $w 0 -weight 1
		grid rowconfigure $w 0 -weight 1
	}

	if {$data(-embed)} {
		if {[info exists data(-width)]} {
			grid columnconfigure $w 0 -minsize $data(-width)
		}
		return $w
	}

	wm protocol $w WM_DELETE_WINDOW [list set [namespace current]::Priv(result) {}]
	wm title $w $data(-title)

	if {$create} {
		if {[string length $geometry] == 0} {
			update idletasks
			set linespace [font metrics TkTextFont -linespace]
			if {$linespace < 20} { set linespace 20 }
			set h [expr {[winfo height $w] + 6*$linespace}]
			set minh [expr {[winfo height $w] + 1}]
			set h [expr {$minh + max($data(-rows) - 8,0)*$linespace}]
			if {[info exists data(-width)]} { set width $data(-width) } else { set width 650 }
			set geometry "${width}x${h}"
		} else {
			scan $geometry "%dx%d" dw dh
			set minh [expr {min($minh,$dh)}]
		}
		wm geometry $w $geometry
		update idletasks
	} else {
		update idletasks
		set rw [winfo reqwidth  $w]
		set rh [winfo reqheight $w]
		if {[string first "+" $geometry] >= 0} {
			wm geometry $w $geometry
		} else {
			if {[llength $geometry] == 0} {
				set geometry [format "%dx%d" $rw $rh]
				set dw $rw
				set dh $rh
			} else {
				scan $geometry "%dx%d" dw dh
			}
			set minh [expr {min($minh,$dh)}]
			set parent $data(-parent)
			set sw [winfo screenwidth  $parent]
			set sh [winfo screenheight $parent]
			if {$parent eq "." || $data(-place) eq "centeronscreen"} {
				set x0 [expr {($sw - $dw)/2 - [winfo vrootx $parent]}]
				set y0 [expr {($sh - $dh)/2 - [winfo vrooty $parent]}]
			} else {
				set x0 [expr {[winfo rootx $parent] + ([winfo width  $parent] - $dw)/2}]
				set y0 [expr {[winfo rooty $parent] + ([winfo height $parent] - $dh)/2}]
			}
			set x "+$x0"
			set y "+$y0"
			if {[tk windowingsystem] ne "win32"} {
				if {$x0 + $dw > $sw}	{ set x "-0"; set x0 [expr {$sw - $dw}] }
				if {$x0 < 0}			{ set x "+0" }
				if {$y0 + $dh > $sh}	{ set y "-0"; set y0 [expr {$sh - $dh}] }
				if {$y0 < 0}			{ set y "+0" }
			}
			if {[tk windowingsystem] eq "aqua"} {
				# avoid the native menu bar which sits on top of everything
				scan $y0 "%d" y
				if {0 <= $y && $y < 22} { set y0 "+22" }
			}
			wm geometry $w $geometry${x}${y}
		}
		update idletasks
		::fsbox::reset $w.fsbox $type {*}[array get opts]
	}

	wm minsize $w 640 $minh
	wm iconname $w ""
	wm deiconify $w

	array unset Priv result
	::ttk::grabWindow $w
	vwait [namespace current]::Priv(result)
	::ttk::releaseGrab $w
	wm withdraw $w

	set Priv(lastFolder) [::fsbox::lastFolder $w.fsbox]

	lassign $Priv(result) path encoding
	if {[llength $path] == 0} { return {} }

	if {$encoding eq $::encoding::mc::AutoDetect} {
		return [list $path $::encoding::autoEncoding]
	}

	return $Priv(result)
}


proc TraceLastFolder {dlg dlg2 w} {
	if {$dlg eq $dlg2} {
		set [namespace current]::Priv(lastFolder) [::fsbox::lastFolder $w.fsbox]
	}
}


proc DeleteFile {path} {
	set result {}
	set file [file rootname $path]
	foreach ext [::scidb::misc::suffixes $path] {
		lappend result "$file.$ext"
	}
	return $result
}


proc RenameFile {oldName newName} {
	set oldExt [file extension $oldName]
	set newExt [file extension $newName]
	if {$oldExt ne $newExt} { return {} }
	set result {}
	set old [file rootname $oldName]
	set new [file rootname $newName]
	foreach ext [::scidb::misc::suffixes $oldName] {
		lappend result "$old.$ext" "$new.$ext"
	}
	return $result
}


proc FileSize {filename mtime} {
	variable FileSizeCache

	set modified -1
	if {[llength $mtime] == 0} { set mtime [file mtime $filename] }
	catch { lassign $FileSizeCache($filename) size modified }
	if {$modified != $mtime} {
		set size [::scidb::misc::size $filename]
		set FileSizeCache($filename) [list $size $mtime]
	}
	return $size
}


proc GetFileSize {filename mtime} {
	set result ""
	set size [FileSize $filename $mtime]

	if {$size > 0} {
		switch [file extension $filename] {
			.pgn - .gz - .zip {
				append result "~ "
				if {$size > 10000} {
					set size [expr {(($size + 500)/1000)*1000}]
				} elseif {$size > 1000} {
					set size [expr {(($size + 50)/100)*100}]
				} elseif {$size > 10} {
					set size [expr {(($size + 5)/10)*10}]
				}
			}

			.cbh { append result "\u2264 " }
		}
	}

	append result [::locale::formatNumber $size]
	return $result
}


proc ValidateFile {filename {size {}}} {
	if {![string match *.zip $filename]} { return 1 }
	if {[llength $size] == 0} { set size [FileSize $filename [file mtime $filename]] }
	if {$size >= 0} { return 1 }
	return 0
}


proc SelectEncoding {type parent encoding defaultEncoding} {
	if {$encoding eq $::encoding::mc::AutoDetect} {
		set encoding $::encoding::autoEncoding
	}
	if {$type eq "save"} { set autoDetectFlag 0 } else { set autoDetectFlag 1 }
	set encoding [::encoding::choose [winfo toplevel $parent] $encoding $defaultEncoding $autoDetectFlag]
	if {$encoding eq $::encoding::autoEncoding} {
		set encoding $::encoding::mc::AutoDetect
	}
	return $encoding
}


proc OkCmd {files encoding} {
	set [namespace current]::Priv(result) [list $files $encoding]
}


proc RecordGeometry {dlg window width} {
	variable Priv

	if {$window eq $dlg} {
		set g [winfo geometry $dlg]
		scan $g "%ux%u" gw gh

		if {$gw <= 1} { return }

		set rw [winfo reqwidth $dlg]
		set rh [winfo reqheight $dlg]

		if {$gw != $rw || $gh != $rh} {
			set Priv(geometry) $g
		} elseif {[llength $Priv(geometry)]} {
			scan $Priv(geometry) "%ux%u" pw ph
			if {$gw < $pw || $gh < $ph} { set Priv(geometry) $g }
		}
	}
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Priv(lastFolder)
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace fsbox
} ;# namespace dialog

# vi:set ts=3 sw=3:
