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

namespace import ::tcl::mathfunc::min


# The user has to overwrite these procedures.
proc setModTime {file time} {}
proc tick {progress n} {}
proc setMaxTick {progress n} {}


proc inspect {arch {destDir ""}} {
	set fd [open $arch "r"]
	fconfigure $fd -translation lf
	set fileSize [file size $arch]
	set entries {}
	set header {}
	gets $fd line

	if {[string length $destDir] == 0} {
		set destDir [file dirname $arch]
	}

	gets $fd line
	while {$line ne "<-- H E A D -->"} {
		regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
		lappend header [list $attr [string trim $value]]
		gets $fd line
	}

	while {[tell $fd] < $fileSize} {
		if {$line ne "<-- H E A D -->"} {
			# log error
			return
		}
		set attrs {}
		unset -nocomplain FileName FileSize Size Compression Checksum Modified
		gets $fd line
		while {$line ne "<-- D A T A -->"} {
			lassign {MissingAttribute MissingValue} attr value
			regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
			set value [string trim $value]
			set $attr $value
			if {$attr eq "FileName"} {
				set value [file join $destDir [file tail $value]]
			}
			if {![info exists FileName]} {
				# error: missing mandatory attribute FileName
			}
			lappend attrs [list $attr $value]
			gets $fd line
		}
		lappend entries $attrs
		seek $fd $Size current
		gets $fd line
		gets $fd line
	}

	close $fd
	return [list $header $entries]
}


proc packFiles {arch sources progress procCompression {procCount {}} {mapExtension {}}} {
	set TotalSize 0
	set Count 0
	array set formats {}
	set Type single
	set fileAttrs {}
	array set filenames {}

	foreach f $sources {
		if {![string match http:* $f]} {
			file stat $f info
			set FileSize $info(size)
			set Modified $info(mtime)
			set Size $FileSize

			if {[llength $procCount] && $Count >= 0} {
				set count [$procCount $f]
				if {[llength $count] > 0} {
					incr Count $count
				} else {
					set Count -1
				}
			}

			incr TotalSize $FileSize
			set ext [string range [file extension $f] 1 end]
			set Compression [$procCompression $ext]
			if {[llength $mapExtension]} { set ext [$mapExtension $ext] }
			set formats($ext) 1
		}

		set rootname [file rootname  $f]
		if {[info exists filenames($rootname)]} { set Type multi }
		set filenames($rootname) 1
		set attrs [list FileName $f]

		if {![string match http:* $f]} {
			foreach attr {FileSize Compression Modified} {
				lappend attrs $attr [string trim [set $attr]]
			}
		}

		lappend fileAttrs $attrs
	}

	set fd [open $arch wb]
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
			puts $fd "<$attr> $value"
		}

		if {![string match http:* $FileName]} {
			puts -nonewline $fd "<Size> "
			set sizeOffs [tell $fd]
			puts $fd "           " ;# placeholder for Size

			puts -nonewline $fd "<Checksum> "
			set checksumOffs [tell $fd]
			puts $fd "           " ;# placeholder for Checksum
		}

		puts $fd "<-- D A T A -->"

		if {[string match http:* $FileName]} {
			# TODO
		} else {
			set f [open $FileName rb]
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
				default {
					# error: unknown compression method
				}
			}
			close $f
			seek $fd $sizeOffs start
			puts -nonewline $fd $size
			seek $fd $checksumOffs start
			puts -nonewline $fd $crc
			seek $fd 0 end
		}
	}

	close $fd
}


proc packStreams {arch sources formats compression modified count procWrite progress} {
	set TotalSize 0
	set Count 0
	set Type single
	set fileAttrs {}

	set fd [open $arch wb]
	fconfigure $fd -translation lf

	puts $fd "iveArch"
	puts -nonewline $fd "<TotalSize> "
	set offs(TotalSize) [tell $fd]
	puts $fd "           " ;# placeholder
	puts $fd "<Count> $Count"
	puts $fd "<Format> [join $formats ","]"
	puts -nonewline $fd "<Type> single"

	set TotalSize 0

	foreach source $sources {
		puts $fd ""
		puts $fd "<-- H E A D -->"

		puts $fd "<FileName> $source"
		puts -nonewline $fd "<FileSize> "
		set offs($source,FileSize) [tell $fd]
		puts $fd "           " ;# placeholder
		puts $fd "<Compression> $compression"
		puts $fd "<Modified> $modified"

		foreach attr {Size Checksum} {
			puts -nonewline $fd "<$attr> "
			set offs($source,$attr) [tell $fd]
			puts $fd "           " ;# placeholder
		}

		puts $fd "<-- D A T A -->"

		lassign [$procWrite $source $fd $progress] FileSize Size Checksum
		incr $TotalSize $FileSize

		foreach attr {FileSize Size Checksum} {
			seek $fd $offs($source,$attr) start
			puts -nonewline $fd [set $attr]
		}

		seek $fd 0 end
	}

	seek $fd $offs(TotalSize) start
	puts -nonewline $fd $TotalSize
	close $fd
}


proc unpack {arch progress {destDir ""}} {
	set fd [open $arch "r"]
	fconfigure $fd -translation lf
	set fileSize [file size $arch]
	set entries {}
	set header {}
	gets $fd line

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

	while {[tell $fd] < $fileSize} {
		if {$line ne "<-- H E A D -->"} {
			# log error
			return 0
		}
		set attrs {}
		set Compression raw
		unset -nocomplain FileName FileSize Size Checksum Modified
		gets $fd line
		while {$line ne "<-- D A T A -->"} {
			regexp {<([A-Za-z]+)>[ 	]*(.*)} $line _ attr value
			set $attr $value
			gets $fd line
		}
		lappend entries $attrs
		set destFilename [file join $destDir [file tail $FileName]]
		if {[string match http:* $FileName]} {
		} elseif {[catch {set f [open $destFilename wb]} err]} {
			# write "error opening file" to log
			seek $fd $Size current 
			tick $progress $Size
		} else {
			fconfigure $f -buffering none
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
					# error: unknown compression method
				}
			}
			close $f
			if {[info exists Modified]} {
				setModTime $destFilename $Modified
			}
			if {[info exists Checksum]} {
				if {$crc != $Checksum} {
					# write "checksum error" to log
				}
			}
		}
		gets $fd line
		gets $fd line
	}

	close $fd
	return 1
}

} ;# namespace archive

if {0} {
	proc getCount {file} {
		switch [file extension $file] {
			.sci - .si3 - .si4 - .cbh - .pgn - .gz {
				return [::scidb::misc::size $file]
			}
		}
		return 0
	}

	wm withdraw .
	source ../dialogs/progressbar.tcl
	source ../progress.tcl
	::dialog::progressbar::open .p -variable N

	if {1} {
		::archive::packFiles \
			arch.scv \
			{ \
				{../Bases/CB Light Database.sci}
				{../Bases/CB Light Database.scg}
				{../Bases/CB Light Database.scn}
			} \
			.p \
			::archive::getCompressionMethod \
			getCount \
			::scidb::misc::mapExtension \
			;
	} elseif {1} {
		wm withdraw .p
		lassign [::archive::inspect arch.scv] header files
		puts "================================="
		foreach pair $header {
			lassign $pair attr value
			puts "$attr: $value"
		}
		puts "================================="
		foreach entry $files {
			foreach pair $entry {
				lassign $pair attr value
				puts "$attr: $value"
			}
			puts "---------------------------------"
		}
	} elseif {0} {
		::archive::unpack arch.scv .p
	}

	exit 0
}

# vi:set ts=3 sw=3:
