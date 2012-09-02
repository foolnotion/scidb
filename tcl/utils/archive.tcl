# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

namespace eval archive {
namespace eval mc {

set CorruptedArchive			"Archive '%s' is corrupted."
set NotAnArchive				"'%s' is not an archive."
set CorruptedHeader			"Archive header in '%s' is corrupted."
set CannotCreateFile			"Failed to create file '%s'."
set FailedToExtractFile		"Failed to extract file '%s'."
set UnknownCompression		"Unknown compression method '%s'."
set ChecksumError				"Checksum error while extracting '%s'."
set ChecksumErrorDetail		"The extracted file '%s' will be corrupted."
set FileNotReadable			"File '%s' is not readable."
set UsingRawInstead			"Using compression method 'raw' instead."
set CannotOpenArchive		"Cannot open archive '%s'."
set CouldNotCreateArchive	"Could not create archive '%s'."

set PackFile					"Pack %s"
set UnpackFile					"Unpack %s"

}

namespace import ::tcl::mathfunc::min


# The user has to overwrite these procedures.
proc setModTime {file time} {}
proc tick {progress n} {}
proc setMaxTick {progress n} {}
proc setInformation {progress msg} {}
proc logError {msg detail} {}


proc inspect {arch {destDir ""}} {
	if {[catch {set fd [open $arch "r"]} err]} {
		logError [format $mc::CannotOpenArchive $arch] ""
		return {}
	}
	fconfigure $fd -translation lf
	set fileSize [file size $arch]
	set entries {}
	set header {}
	gets $fd line

	if {$line ne "iveArch"} {
		logError [format $mc::NotAnArchive $arch] ""
		close $fd
		return {}
	}

	if {[string length $destDir] == 0} {
		set destDir [file dirname $arch]
	}

	gets $fd line
	while {$line ne "<-- H E A D -->"} {
		regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
		lappend header [list $attr [string trim $value]]
		gets $fd line
	}

	foreach attr {Format Type} {
		if {[lsearch -exact -index 0 $header $attr] == -1} {
			logError [format $mc::CorruptedHeader $arch] ""
			close $fd
			return {}
		}
	}

	while {[tell $fd] < $fileSize} {
		if {$line ne "<-- H E A D -->"} {
			logError [format $mc::CorruptedArchive $arch] ""
			close $fd
			return {}
		}
		set attrs {}
		unset -nocomplain FileName URI FileSize Size Compression Checksum Modified
		gets $fd line
		while {$line ne "<-- D A T A -->"} {
			lassign {MissingAttribute MissingValue} attr value
			regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
			set value [string trim $value]
			set $attr $value
			if {$attr eq "FileName"} {
				set value [file join $destDir $value]
			}
			lappend attrs [list $attr $value]
			gets $fd line
		}
		foreach attr {FileName Size} {
			if {[lsearch -exact -index 0 $attrs $attr] == -1} {
				logError [format $mc::CorruptedHeader $arch] ""
				close $fd
				return {}
			}
		}
		lappend entries $attrs
		seek $fd $Size current
		gets $fd line
		gets $fd line
	}

	close $fd
	return [list $header $entries]
}


proc packFiles {arch baseDir sources progress procCompression
						procGetName {procCount {}} {mapExtension {}}} {
	set TotalSize 0
	set Count 0
	array set formats {}
	set Type single
	set fileAttrs {}
	array set filenames {}
	set fileCount 0
	set pathList {}
	set basedir {}

	foreach f $sources {
		set path [file join $baseDir $f]
		if {[string match http:* $f]} {
			lappend pathList $f
		} elseif {![file readable $path]} {
			logError [format $mc::FileNotReadable $path] ""
		} elseif {[file isdirectory $path]} {
			lappend pathList {*}[GlobDir $path $f]
		} else {
			lappend pathList $f
		}
	}

	foreach f $pathList {
		if {![string match http:* $f]} {
			set path [file join $baseDir $f]
			if {![file readable $path]} {
				logError [format $mc::FileNotReadable $path] ""
			} else {
				file stat $path info
				set FileSize $info(size)
				set Modified $info(mtime)
				set Size $FileSize

				if {[llength $procCount] && $Count >= 0} {
					set count [$procCount $path]
					if {[llength $count] > 0} {
						incr Count $count
					} else {
						set Count -1
					}
				}

				incr TotalSize $FileSize
				set ext [string range [file extension $f] 1 end]
				set Compression [$procCompression $ext]
				if {$Compression ne "raw" && $Compression ne "zlib"} {
					logError \
						[format $mc::UnknownCompression $Compression] \
						[format $mc::UsingRawInstead] \
						;
					set Compression raw
				}
				if {[llength $mapExtension]} { set ext [$mapExtension $ext] }
				set formats($ext) 1
			}
		}

		set rootname [file rootname  $f]
		if {[info exists filenames($rootname)]} { set Type multi }
		set filenames($rootname) 1
		set attrs [list FileName $f]
		lappend attrs PathName $path

		if {![string match http:* $f]} {
			foreach attr {FileSize Compression Modified} {
				lappend attrs $attr [string trim [set $attr]]
			}
		}

		lappend fileAttrs $attrs
	}

	if {[catch {set fd [open $arch wb]} err]} {
		logError [format $mc::CannotCreateFile $arch] ""
		return -1
	}
	fconfigure $fd -translation lf
	setMaxTick $progress [expr {$TotalSize + 1}]

	puts $fd "iveArch"
	puts $fd "<TotalSize> $TotalSize"
	if {$Count >= 0} { puts $fd "<Count> $Count" }
	puts $fd "<Format> [join [array names formats] ","]"
	puts -nonewline $fd "<Type> $Type"

	foreach attrs $fileAttrs {
		puts $fd ""
		puts $fd "<-- H E A D -->"

		foreach {attr value} $attrs {
			set $attr [string trim $value]
			if {$attr ne "PathName"} { puts $fd "<$attr> $value" }
		}

		setInformation $progress [format $mc::PackFile [$procGetName $FileName]]

		if {![string match http:* $FileName]} {
			puts -nonewline $fd "<Size> "
			set sizeOffs [tell $fd]
			puts $fd "           " ;# placeholder for Size

			puts -nonewline $fd "<Checksum> "
			set checksumOffs [tell $fd]
			puts $fd "           " ;# placeholder for Checksum
		}

		puts $fd "<-- D A T A -->"

		if {![string match http:* $FileName]} {
			if {[catch {set f [open $PathName rb]} err]} {
				logError [format $mc::FileNotReadable $f] ""
				logError [format $mc::CouldNotCreateArchive $arch] ""
				close $fd
				file delete $arch
				return -1
			}
			fconfigure $f -buffering none
			switch $Compression {
				zlib {
					lassign [::zlib::deflate $f $fd [namespace current]::tick $progress] size crc
				}
				raw {
					set size 0
					set buf ""
					set crc 0
					while {$size < $FileSize} {
						set data [read $f 65536]
						incr size [string length $data]
						set crc [::zlib::crc $data $crc]
						puts -nonewline $fd $data
						tick $progress [string length $data]
					}
				}
			}
			close $f
			seek $fd $sizeOffs start
			puts -nonewline $fd $size
			seek $fd $checksumOffs start
			puts -nonewline $fd $crc
			seek $fd 0 end
			incr fileCount
		}
	}

	close $fd
	return $fileCount
}


proc packStreams {arch baseDir sources formats compression
						modified count procWrite procGetName progress} {
	set TotalSize 0
	set Count $count
	set Type single
	set fileAttrs {}
	set fileCount 0

	if {[catch {set fd [open $arch wb]} err]} {
		logError [format $mc::CannotCreateFile $arch] ""
		return -1
	}
	fconfigure $fd -translation lf

	puts $fd "iveArch"
	puts -nonewline $fd "<TotalSize> "
	set offs(TotalSize) [tell $fd]
	puts $fd "           " ;# placeholder
	puts $fd "<Count> $Count"
	puts $fd "<Format> [join $formats ","]"
	puts -nonewline $fd "<Type> single"

	set TotalSize 0

	foreach FileName $sources {
		if {![string match http:* $FileName]} {
			set PathName [file join $baseDir $FileName]
			setInformation $progress [format $mc::PackFile [$procGetName $FileName]]

			puts $fd ""
			puts $fd "<-- H E A D -->"

			puts $fd "<FileName> $FileName"
			puts -nonewline $fd "<FileSize> "
			set offs($FileName,FileSize) [tell $fd]
			puts $fd "           " ;# placeholder
			puts $fd "<Compression> $compression"
			puts $fd "<Modified> $modified"

			foreach attr {Size Checksum} {
				puts -nonewline $fd "<$attr> "
				set offs($FileName,$attr) [tell $fd]
				puts $fd "           " ;# placeholder
			}

			puts $fd "<-- D A T A -->"

			lassign [$procWrite $PathName $fd $progress] FileSize Size Checksum
			incr $TotalSize $FileSize

			foreach attr {FileSize Size Checksum} {
				seek $fd $offs($FileName,$attr) start
				puts -nonewline $fd [set $attr]
			}

			seek $fd 0 end
		}
	}

	seek $fd $offs(TotalSize) start
	puts -nonewline $fd $TotalSize
	close $fd

	return $fileCount
}


proc unpack {arch procGetName progress {destDir ""}} {
	if {[catch {set fd [open $arch "r"]} err]} {
		logError [format $mc::CannotCreateFile $arch] ""
		return 0
	}
	fconfigure $fd -translation lf
	set fileSize [file size $arch]
	set entries {}
	set header {}
	gets $fd line

	if {$line ne "iveArch"} {
		logError [format $mc::NotAnArchive $arch] ""
		close $fd
		return 0
	}

	gets $fd line
	while {$line ne "<-- H E A D -->"} {
		regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
		set $attr $value
		gets $fd line
	}

	setMaxTick $progress [expr {$TotalSize + 1}]

	if {[string length $destDir] == 0} {
		set destDir [file dirname $arch]
	}

	set rc 1

	while {[tell $fd] < $fileSize} {
		if {$line ne "<-- H E A D -->"} {
			logError [format $mc::CorruptedArchive $arch] ""
			close $fd
			return 0
		}
		set attrs {}
		set Compression raw
		unset -nocomplain FileName URI FileSize Size Checksum Modified
		gets $fd line
		while {$line ne "<-- D A T A -->"} {
			regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
			set $attr $value
			gets $fd line
		}
		foreach attr {FileName Size} {
			if {![info exists $attr]} {
				logError [format $mc::CorruptedHeader $arch] ""
				close $fd
				return 0
			}
		}
		setInformation $progress [format $mc::UnpackFile [$procGetName $FileName]]
		lappend entries $attrs
		set destFilename [file join $destDir $FileName]
		if {[info exists URI] && [string match http:* $URI]} {
			# TODO
		} else {
			set dir [file dirname $destFilename]
			if {![file exists $dir]} { file mkdir $dir }
			if {[catch {set f [open $destFilename wb]} err]} {
				logError [format $mc::CannotCreateFile $destFilename] ""
				set rc 0
				seek $fd $Size current 
				tick $progress $Size
			} else {
				fconfigure $f -buffering none
				set ok 1
				switch $Compression {
					zlib {
						lassign [::zlib::inflate $fd $f $Size [namespace current]::tick $progress] size crc
					}
					raw {
						set remaining $Size
						set crc 0
						set buf ""
						while {$remaining > 0} {
							set data [read $fd [min $remaining 65536]]
							set remaining [expr {$remaining - [string length $data]}]
							tick $progress [string length $data]
							if {$Compression eq "zlib"} {
								set data [::zlib::inflate $data $buf]
								set buf $data
							}
							set crc [::zlib::crc $data $crc]
							puts -nonewline $f $data
						}
					}
					default {
						logError \
							[format $mc::FailedToExtractFile $FileName] \
							[format $mc::UnknownCompression $Compression] \
							;
						set rc 0
						set ok 0
						seek $fd $Size current 
						tick $progress $Size
					}
				}
				close $f
				if {$ok} {
					if {[info exists Modified]} {
						setModTime $destFilename $Modified
					}
					if {[info exists Checksum]} {
						if {$crc != $Checksum} {
							logError \
								[format $mc::ChecksumError $FileName] \
								[format $mc::ChecksumErrorDetail $destFilename] \
								;
							set rc 0
						}
					}
				} else {
					file delete $destFilename
				}
			}
		}
		gets $fd line
		gets $fd line
	}

	close $fd
	return $rc
}


proc GlobDir {dir subdir} {
	set result {}

	foreach f [glob -directory $dir *] {
		if {[file isdirectory $f]} {
			lappend result {*}[GlobDir $f [file join $subdir [file tail $f]]]
		} else {
			lappend result [file join $subdir [file tail $f]]
		}
	}

	return $result
}

} ;# namespace archive

# vi:set ts=3 sw=3:
