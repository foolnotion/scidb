# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval trash {

switch [tk windowingsystem] {
	x11 {

		proc usable? {} {
			return [expr {[string length [directory]] > 0}]
		}

		proc isTrash? {path} {
			set dir [directory]
			if {[string length $dir] == 0} { return }
			return [string match ${dir}* $path]
		}

		proc directory {} {
			variable Dir_

			if {[info exists Dir_]} {
				if {![file isdirectory $Dir_]} { return "" }
			} else {
				set Dir_ ""

				if {[info exists ::env(XDG_DATA_HOME)] && [string length $::env(XDG_DATA_HOME)] > 0} {
					if {[file isdirectory [set dir [file join $::env(XDG_DATA_HOME) Trash files]]]} {
						set Dir_ $dir
					}
				}

				if {[string length $Dir_] == 0} {
					set home [file nativename ~]
					if {[file isdirectory [set dir [file join $home .local share Trash files]]]} {
						set Dir_ $dir
					}
				}
			}

			return $Dir_
		}

		proc move {file {extensions {}}} {
			set filesDir [directory]
			if {[string length $filesDir] == 0} { return failed }
			set infoDir [file normalize [file join $filesDir .. info]]
			if {![file exists $infoDir]} { return failed }

			if {[llength $extensions] == 0} {
				set extensions [list [file extension $file]]
				set file [file rootname $file]
			}

			set name [file tail $file]
			set path [file join $filesDir $name]
			set num 0
			while {[FileExists $path $extensions]} {
				set path [file join $filesDir "${name}_[incr num]"]
			}

			set rollback {}

			foreach ext $extensions {
				set orig [file normalize "${file}${ext}"]
				if {[file exists $orig]} {
					set tail [file tail $path]
					set infoFile [file join $infoDir "${tail}${ext}.trashinfo"]
					if {[catch { open $infoFile "w" 0644 } chan]} {
						return [Rollback $rollback nopermission]
					}
					puts $chan {[Trash Info]}
					puts $chan Path=[urlEncode $orig]
					puts $chan DeletionDate=[clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
					close $chan
					set dest "${path}${ext}"
					if {[catch { file rename $orig $dest }]} {
						return [Rollback $rollback failed]
					}
					lappend rollback [list file rename $dest $orig]
				}
			}
	
			return ok
		}

		proc restore {file {newName ""} args} {
			array set opts { -force 0 }
			array set opts $args

			set filesDir [directory]
			if {[string length $filesDir] == 0} { return failed }
			set infoDir [file normalize [file join $filesDir .. info]]
			set tail [file tail $file]

			set infoFile [file join $infoDir "$tail.trashinfo"]
			if {[string length $newName] == 0} {
				set newName [lindex [ReadInfo $infoFile] 0]
				if {[string length $newName] == 0} {
					return failed
				}
			}
			set dir [file dirname $newName]
			if !{[file isdirectory $dir]} {
				return nodir
			}
			if {[file exists $newName] && !$opts(-force)} {
				return exists
			}
			if {[catch { file rename -force $file $newName }]} {
				return nopermission
			}
			catch { file delete $infoFile }

			return ok
		}

		proc content {{filter *}} {
			set result {}

			set filesDir [directory]
			if {[string length $filesDir] == 0} { return {} }
			set infoDir [file normalize [file join $filesDir .. info]]
			set content {}

			foreach file [glob -nocomplain -directory $filesDir -types {f} {*}$filter] {
				set infoFile [file join $infoDir "[file tail $file].trashinfo"]
				lassign [ReadInfo $infoFile] path deletionDate
				lappend content [list $file $path $deletionDate]
			}

			return $content
		}

		proc originalPath {file} {
			set filesDir [directory]
			if {[string length $filesDir] == 0} { return "" }
			set infoDir [file normalize [file join $filesDir .. info]]
			return [lindex [ReadInfo [file join $infoDir "[file tail $file].trashinfo"]] 0]
		}

		proc ReadInfo {file} {
			set path ""
			set deletionDate ""

			if {[file readable $file]} {
				set chan [open $file "r"]
				set datePattern {[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]}

				foreach line [split [read $chan] \n] {
					if {[string match Path=* $line]} {
						set path [string trim [string range $line 5 end]]
					} elseif {[string match DeletionDate=* $line]} {
						set date [string trim [string range $line 13 end]]
						if {[regexp $datePattern $date]} {
							set deletionDate [string map {- . T " "} $date]
						}
					}
				}

				close $chan
			}

			return [list [urlDecode $path] $deletionDate]
		}

		proc FileExists {file extensions} {
			foreach ext $extensions {
				if {[file exists "${file}${ext}"]} { return 1 }
			}
			return 0
		}

		proc Rollback {commands err} {
			foreach cmd $commands { $cmd }
			return $err
		}

		proc urlDecode {str} {
			# protect \ from quoting another '\'
			set str [string map [list "\\" "\\\\"] $str]

			# prepare to process all %-escapes
			regsub -all -- {%([A-Fa-f0-9][A-Fa-f0-9])} $str {\\u00\1} str

			# process \u unicode mapped chars
			return [subst -novar -nocommand $str]
		}

		proc urlEncode {str} {
			variable Alphanumeric_
			variable Map_

			if {![info exists Alphanumeric_]} {
				set Alphanumeric_ {a-zA-Z0-9}
				for {set i 0} {$i <= 256} {incr i} { 
					set c [format %c $i]
					if {![string match \[$Alphanumeric_\] $c]} {
						set Map_($c) %[string toupper [format %.2x $i]]
					}
				}
				# These are handled specially
				array set Map_ { / / . . }
			}

			# The spec says: "non-alphanumeric characters are replaced by '%HH'"
			# 1 leave alphanumerics characters alone
			# 2 Convert every other character to an array lookup
			# 3 Escape constructs that are "special" to the tcl parser
			# 4 "subst" the result, doing all the array substitutions

			regsub -all \[^$Alphanumeric_\] $str {$Map_(&)} str
			# This quotes cases like $Map_([) or $Map_($) => $Map_(\[) ...
			regsub -all {[][{})\\]\)} $str {\\&} str
			return [subst -nocommand $str]
		}
	}

	windows {
		# TODO
	}

	aqua {
		# TODO
	}

}

} ;# namespace trash

# vi:set ts=3 sw=3:
