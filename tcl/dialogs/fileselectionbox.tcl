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
# Copyright: (C) 2011-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source file-selection-box

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

if {[tk windowingsystem] eq "x11"} {
namespace eval fsbox {
namespace eval mc {

set ScidbDatabase				"Scidb Database"
set ScidDatabase				"Scid Database"
set ChessBaseDatabase		"ChessBase Database"
set PortableGameFile			"Portable Game File"
set ZipArchive					"ZIP Archive"
set ScidbArchive				"Scidb Arvchive"
set PortableDocumentFile	"Portable Document File"
set HypertextFile				"Hypertext File"
set TypesettingFile			"Typesetting File"
set ImageFile					"Image File"
set LinkTo						"Link to %s"
set LinkTarget					"Link target"
set Directory					"Directory"

set Content						"Content"
set Open							"Open"

}

array set Priv { dialog {} }
array set FileSizeCache {}
array set LastFolders {}

set FileIcons [list                        \
	.sci	$::icon::16x16::filetypeScidbBase \
	.si4	$::icon::16x16::filetypeScid4Base \
	.si3	$::icon::16x16::filetypeScid3Base \
	.scv  $::icon::16x16::filetypeArchive   \
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
	.scv 0 utf-8 \
	.cbh 1 $::encoding::windowsEncoding \
	.pgn 1 $::encoding::defaultEncoding \
	.gz  1 $::encoding::defaultEncoding \
	.zip 1 $::encoding::defaultEncoding \
]
if {$tcl_platform(platform) eq "windows"} {
	set FileEncodings(.cbh) [list 1 $::encoding::systemEncoding] ;# XXX ok?
}

array set FileType [list      \
	.sci	ScidbDatabase        \
	.si4	ScidDatabase         \
	.si3	ScidDatabase         \
	.scv  ScidbArchive         \
	.cbh	ChessBaseDatabase    \
	.pgn	PortableGameFile     \
	.gz	PortableGameFile     \
	.zip	ZipArchive           \
	.pdf	PortableDocumentFile \
	.html	HypertextFile        \
	.htm	HypertextFile        \
	.tex	TypesettingFile      \
	.ltx	TypesettingFile      \
	.ppm	ImageFile            \
	.png	ImageFile            \
	.gif	ImageFile            \
	.jpg	ImageFile            \
	.jpeg	ImageFile            \
]


proc geometry {class {whichPart size}} {
	variable Priv

	if {[info exists Priv(geometry:$class)]} {
		set geom $Priv(geometry:$class)
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
	} else {
		set Priv(geometry:$class) ""
		return ""
	}

	return $geom
}


proc currentDialog {} {
	variable Priv
	return $Priv(dialog)
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


proc dragCursors {{ext ""}} {
	variable DragCursor

	if {![info exists DragCursor]} {
		set DragCursor {}

		foreach {filetypes name} {	{.sci .si4 .si3 .scv .cbh .pgn .gz .zip} db
											{.pdf .html .htm .tex .ltx} document
											{.ppm .png .gif .jpg .jpeg} image } {
			if {[tk windowingsystem] eq "x11"} {
				set accept [file join $::scidb::dir::share cursor drag-$name-accept-32x32.xcur]
				set deny   [file join $::scidb::dir::share cursor drag-$name-deny-32x32.xcur]

				if {[file readable $accept] && [file readable $deny]} {
					if {	![catch { ::xcursor::loadCursor $accept } acceptCursor]
						&&	![catch { ::xcursor::loadCursor $deny } denyCursor]} {
						lappend DragCursor $filetypes [list $acceptCursor $denyCursor]
					}
				}
			}
		}
	}

	if {[string length $ext] == 0} { return $DragCursor }

	foreach {extList cursors} $DragCursor {
		if {$ext in $extList} { return $cursors }
	}

	return {}
}


proc estimateNumberOfGames {filename} {
	set count [NumGames $filename]
	if {[file extension $filename] in {.pgn .gz .zip}} {
		set count [expr {-[RoundNumGames $count]}]
	}
	return $count
}


proc Open {type args} {
	variable LastFolders
	variable DragCursor
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
		-parent			.
		-place			{}
		-geometry		""
		-embed			0
		-needencoding	0
		-rows				10
		-class			{}
		-databases		1
		-filetypes		{}
	}

	set opts(-initialdir) {}
	set opts(-defaultencoding) {}

	array set data $args
	array set opts $args

	if {[info exists LastFolders($class:$data(-class))]} {
		set opts(-initialdir) $LastFolders($class:$data(-class))
	}

	set scidbFileType 0
	set knownFileType 0
	foreach entry $data(-filetypes) {
		set ft [lindex $entry 1]
		if {".sci" in $ft || ".pgn" in $ft} {
			set scidbFileType 1
			set knownFileType 1
			break;
		} elseif {".png" in $ft} {
			set knownFileType 1
			break;
		}
	}

	array unset opts -class
	array unset opts -embed
	array unset opts -geometry
	array unset opts -needencoding
	array unset opts -parent
	array unset opts -place
	array unset opts -rows
	array unset opts -title
	array unset opts -width

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
		bind $dlg <Destroy> [namespace code [list TraceLastFolder $dlg %W $w $class]]
	} elseif {$create} {
		tk::toplevel $w -class $class
		bind $w <Configure> [namespace code [list RecordGeometry $w %W %w $class]]
		wm withdraw $w
		if {[winfo viewable [winfo toplevel $data(-parent)]]} {
			wm transient $w $data(-parent)
		}
		catch { wm attributes $w -type dialog }
		lappend Priv(dialogs) $w
		bind $w <Destroy> [namespace code [list Destroyed $w]]
		bind $w <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
		set Priv(dialog) $w
	}

	set Priv($type:type) $type
	set geometry $data(-geometry)
	if {[string match last* $geometry]} { set geometry [geometry $class $geometry] }
	if {![info exists Priv(minheight)]} { set Priv(minheight) 350 }

	if {$data(-needencoding)} {
		if {[llength $opts(-defaultencoding)] == 0} {
			set opts(-defaultencoding) $::encoding::mc::AutoDetect
		}
		set opts(-selectencodingcommand) [namespace code [list SelectEncoding $type]]
		set opts(-fileencodings) [set [namespace current]::FileEncodings]
	}

	if {![info exists opts(-helpcommand)]} {
		set opts(-helpcommand) [namespace code OpenHelp]
		set opts(-helpicon) $::icon::16x16::help
		set opts(-helplabel) $::menu::mc::Help
	}
	if {![info exists opts(-cancelcommand)]} {
		set opts(-cancelcommand) [list set [namespace current]::Priv($type:$w:result) {}]
	}
	if {![info exists opts(-okcommand)]} {
		set opts(-okcommand) [namespace code [list OkCmd $type:$w]]
	}

	lappend options -fileicons [fileIcons]
	lappend options -filecursors [dragCursors]
	if {$scidbFileType} {
		lappend options \
			-sizecommand [namespace code GetNumGames] \
			-validatecommand [namespace code ValidateFile] \
			-deletecommand [namespace code DeleteFile] \
			-renamecommand [namespace code RenameFile] \
			-duplicatecommand [namespace code DuplicateFile] \
			-inspectcommand [namespace code Inspect] \
			-mapextcommand [namespace code MapExtension] \
			-isusedcommand [namespace code IsUsed] \
	} elseif  {$knownFileType} {
		lappend options -inspectcommand [namespace code Inspect]
	}

	if {$create} {
		if {[string length $geometry] == 0} { set opts(-rows) 8 }
		::fsbox $w.fsbox $type \
			-bookmarkswidth 120 \
			-formattimecmd [namespace code FormatTime] \
			-font TkTextFont \
			{*}[array get opts] \
			{*}$options \
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

	wm protocol $w WM_DELETE_WINDOW [list set [namespace current]::Priv($type:$w:result) {}]
	wm title $w $data(-title)

	if {$create} {
		if {[string length $geometry] == 0} {
			update idletasks
			set linespace [font metrics TkTextFont -linespace]
			if {$linespace < 20} { set linespace 20 }
			set Priv(minheight) [winfo height $w]
			set h [expr {$Priv(minheight) + max($data(-rows) - [::fsbox::countRows $w.fsbox],0)*$linespace}]
			if {[info exists data(-width)]} { set width $data(-width) } else { set width 680 }
			set geometry "${width}x${h}[geometry pos]"
		} else {
			scan $geometry "%dx%d" dw dh
		}
		wm minsize $w 640 $Priv(minheight)
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
		wm minsize $w 640 $Priv(minheight)
		update idletasks
		::fsbox::reset $w.fsbox $type {*}[array get opts] {*}$options
	}

	wm iconname $w ""
	wm deiconify $w

	array unset Priv $type:$w:result
	tkwait visibility $w
	::ttk::grabWindow $w
	vwait [namespace current]::Priv($type:$w:result)
	::ttk::releaseGrab $w
	wm withdraw $w
	set Priv(dialog) {}
	set LastFolders($class:$data(-class)) [::fsbox::lastFolder $w.fsbox]
	::fsbox::cleanup $w.fsbox

	lassign $Priv($type:$w:result) path encoding
	if {[llength $path] == 0} { return {} }

	if {$encoding eq $::encoding::mc::AutoDetect} {
		return [list $path $::encoding::autoEncoding]
	}

	return $Priv($type:$w:result)
}


proc OpenHelp {w} {
	::help::open $w File-Selection-Dialog
}


proc Destroyed {w} {
	variable Priv
	set i [lsearch -exact $Priv(dialogs) $w]
	if {$i >= 0} { set Priv(dialogs) [lreplace $Priv(dialogs) $i $i] }
}


proc LanguageChanged {w} {
	if {[winfo exists $w]} { destroy $w }
}


proc TraceLastFolder {dlg dlg2 w class} {
	if {$dlg eq $dlg2} {
		set [namespace current]::Priv(lastFolder:$class) [::fsbox::lastFolder $w.fsbox]
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


proc DuplicateFile {srcName dstName} {
	set srcExt [file extension $srcName]
	set dstExt [file extension $dstName]
	if {$srcExt ne $dstExt} { return {} }
	set result {}
	set src [file rootname $srcName]
	set dst [file rootname $dstName]
	foreach ext [::scidb::misc::suffixes $srcName] {
		lappend result "$src.$ext" "$dst.$ext"
	}
	return $result
}


proc GetArchiveSize {arch} {
	set fd [open $arch "r"]
	fconfigure $fd -translation lf
	gets $fd line
	gets $fd line
	while {$line ne "<-- H E A D -->" && ![eof $fd]} {
		lassign {"" ""} attr value
		regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
		if {$attr eq "Count" && [string is integer -strict $value]} {
			close $fd
			return $value
		}
		gets $fd line
	}
	close $fd
	return -1
}


proc NumGames {filename {mtime 0}} {
	variable FileSizeCache

	set modified -1
	if {[llength $mtime] == 0} { set mtime [file mtime $filename] }
	catch { lassign $FileSizeCache($filename) size modified }
	if {$modified != $mtime} {
		if {[file extension $filename] ne ".scv"} {
			set size [::scidb::misc::size $filename]
		} elseif {[catch {set size [GetArchiveSize $filename]} err]} {
			set size -1
		}
		set FileSizeCache($filename) [list $size $mtime]
	}
	return $size
}


proc RoundNumGames {count} {
	if {$count > 10000} {
		set count [expr {(($count + 500)/1000)*1000}]
	} elseif {$count > 1000} {
		set count [expr {(($count + 50)/100)*100}]
	} elseif {$count > 10} {
		set count [expr {(($count + 5)/10)*10}]
	}
	return $count
}


proc FormatNumGames {filename count} {
	set result ""
	if {$count > 0} {
		switch [file extension $filename] {
			.pgn - .gz - .zip {
				set count [RoundNumGames $count]
				append result "~ "
			}

			.cbh { append result "\u2264 " }
		}
	}
	append result [::locale::formatNumber $count]
	return $result
}


proc GetNumGames {filename mtime} {
	return [FormatNumGames $filename [NumGames $filename $mtime]]
}


proc IsUsed {file} {
	switch [file extension $file] {
		.pgn - .gz - .zip {
			# no action
		}

		.sci - .si3 - .si4 - .cbh {
			if {[::scidb::db::get open? [file normalize $file]]} { return yes }
		}
	}

	return no
}


proc FormatTime {time} {
	return [::locale::formatTime [clock format $time -format {%Y.%m.%d %H:%M:%S}]]
}


proc MapExtension {extension} {
	set result [::scidb::misc::mapExtension $extension]
	if {[string length $result]} { set result ".$result" }
	if {$result ne $extension} { return $result }
	if {$result in {.sci .scv .si3 .si4 .cbh .pgn .gz .zip}} { return $result }
	return ""
}


proc Inspect {parent {folder ""} {filename ""}} {
	variable FileType

	set dlg $parent.__inspect__
	catch { destroy $dlg }

	if {[string length $folder] > 0} {
		set f [::util::makePopup $dlg]
		set bg [$f cget -background]

		if {[string length $filename] > 0} {
			file stat $filename stat
			set type [file type $filename]
			set mtime [::locale::formatTime [clock format $stat(mtime) -format {%Y.%m.%d %H:%M:%S}]]

			if {$stat(type) eq "directory"} {
				set fileType $mc::Directory
				if {$type eq "link"} { set fileType [format $mc::LinkTo $fileType] }
				tk::label $f.lname -text "$::fsbox::mc::Name:"
				tk::label $f.tname -text [file tail $filename]
				tk::label $f.ltype -text "$::application::database::mc::Type:"
				tk::label $f.ttype -text $fileType
				if {$type eq "link"} {
					tk::label $f.ltarget -text "$mc::LinkTarget:"
					tk::label $f.ttarget -text [file readlink $filename]
				}
				tk::label $f.lmodified -text "$::fsbox::mc::Modified:"
				tk::label $f.tmodified -text $mtime
			} else {
				set ext [file extension $filename]
				if {![info exists FileType($ext)]} { return }
				set ctime [::locale::formatTime [clock format $stat(ctime) -format {%Y.%m.%d %H:%M:%S}]]
				# TODO: should we sum the sizes of all related files?
				set size [::locale::formatFileSize $stat(size)]
				set fileType [set mc::$FileType($ext)]
				if {$type eq "link"} { set fileType [format $mc::LinkTo $fileType] }

				tk::label $f.lname -text "$::fsbox::mc::Name:"
				tk::label $f.tname -text [file tail $filename]
				tk::label $f.ltype -text "$::application::database::mc::Type:"
				tk::label $f.ttype -text $fileType
				if {$type eq "link"} {
					tk::label $f.ltarget -text "$mc::LinkTarget:"
					tk::label $f.ttarget -text [file readlink $filename]
				}
				tk::label $f.lsize -text "$::fsbox::mc::Size:"
				tk::label $f.tsize -text $size
				tk::label $f.lcreated -text "$::application::database::mc::Created:"
				tk::label $f.tcreated -text $ctime

				switch $ext {
					.sci - .si3 - .si4 - .cbh - .pgn - .gz {
						lassign [::scidb::misc::attributes $filename] numGames type created descr
						if {[string length $descr] == 0} { set descr "\u2014" }
#						set type [set ::application::database::mc::T_$type]
						set numGames [FormatNumGames $filename $numGames]
						if {[llength $created] > 0} {
							$f.tcreated configure -text [::locale::formatTime $created]
						}
						tk::label $f.lmodified -text "$::fsbox::mc::Modified:"
						tk::label $f.tmodified -text $mtime
						if {$numGames >= 0} {
							tk::label $f.lngames -text "$::crosstable::mc::Games:"
							tk::label $f.tngames -text $numGames
						}
						if {[::scidb::db::get open? [file normalize $filename]]} {
							set open [string tolower $::mc::Yes]
						} else {
							set open [string tolower $::mc::No]
						}
						tk::label $f.lused -text "$mc::Open:"
						tk::label $f.tused -text $open
						tk::label $f.ldescr -text "$::application::database::mc::Description:"
						tk::label $f.tdescr -text $descr -wraplength 200 -justify left
					}
					.scv {
						lassign [::archive::inspect $filename] header files
						foreach pair $header {
							lassign $pair attr value
							if {$attr eq "Count"} {
								tk::label $f.lngames -text "$::crosstable::mc::Games:"
								tk::label $f.tngames -text [::locale::formatNumber $value]
							}
						}
						set bases {}
						foreach entry $files {
							foreach pair $entry {
								lassign $pair attr value
								if {$attr eq "FileName"} {
									switch [file extension $value] {
										.sci - .si3 - .si4 - .cbh - .pgn - .gz {
											if {[string length $bases] > 0} { append bases \n }
											set file [file tail $value]
											append bases $file
										}
									}
								}
							}
						}
						if {[string length $bases]} {
							tk::label $f.ldescr -text "$mc::Content:"
							tk::label $f.tdescr -text $bases -wraplength 250 -justify left
						}
					}
				}
			}

			set r 1
			foreach attr {name type target size created modified ngames used descr} {
				if {[winfo exists $f.l$attr]} {
					$f.l$attr configure -background $bg
					$f.t$attr configure -background $bg
					grid $f.l$attr -row $r -column 1 -sticky wn
					grid $f.t$attr -row $r -column 3 -sticky wn
					grid rowconfigure $f [incr r] -minsize 3
					incr r
				}
			}
			grid rowconfigure $f [list 0 $r] -minsize 3
			grid columnconfigure $f {0 2 4} -minsize 3
		} else {
			pack [tk::label $f.folder -background $bg -text $folder]
		}

		::tooltip::popup $parent $dlg cursor
	} else {
		::tooltip::popdown $dlg
	}
}


proc ValidateFile {filename {size {}}} {
	if {![string match *.zip $filename]} { return 1 }
	if {[llength $size] == 0} { set size [NumGames $filename [file mtime $filename]] }
	if {$size >= 0} { return 1 }
	return 0
}


proc SelectEncoding {type parent encoding defaultEncoding} {
	variable Priv

	if {$encoding eq $::encoding::mc::AutoDetect} {
		set encoding $::encoding::autoEncoding
	}
	if {$Priv($type:type) eq "save"} { set autoDetectFlag 0 } else { set autoDetectFlag 1 }
	set encoding [::encoding::choose [winfo toplevel $parent] $encoding $defaultEncoding $autoDetectFlag]
	if {$encoding eq $::encoding::autoEncoding} {
		set encoding $::encoding::mc::AutoDetect
	}
	return $encoding
}


proc OkCmd {type files {encoding ""}} {
	set [namespace current]::Priv($type:result) [list $files $encoding]
}


proc RecordGeometry {dlg window width class} {
	variable Priv

	if {$window eq $dlg} {
		set g [winfo geometry $dlg]
		scan $g "%ux%u" gw gh

		if {$gw <= 1} { return }

		set rw [winfo reqwidth $dlg]
		set rh [winfo reqheight $dlg]

		if {$gw != $rw || $gh != $rh} {
			set Priv(geometry:$class) $g
		} elseif {[llength $Priv(geometry:$class)]} {
			scan $Priv(geometry:$class) "%ux%u" pw ph
			if {$gw < $pw || $gh < $ph} { set Priv(geometry:$class) $g }
		}
	}
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::LastFolders no
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace fsbox
} ;# x11
} ;# namespace dialog

# vi:set ts=3 sw=3:
