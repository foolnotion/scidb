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

namespace eval system {

proc memTotal {} {
	switch $::tcl_platform(platform) {
		unix {
			if {[file exists /proc/meminfo]} {
				set info {}
				catch { set info [exec cat /proc/meminfo] }
				if {[llength $info] % 3 == 0} {
					foreach {attr mem unit} $info {
						if {$attr eq "MemTotal:"} {
							if {[string is integer -strict $mem]} { return [expr {$mem*1024}] }
							break
						}
					}
				}
			}
		}
	}

	return -1
}


proc memAvailable {} {
	switch $::tcl_platform(platform) {
		unix {
			if {[file readable /proc/meminfo]} {
				set info {}
				catch { set info [exec cat /proc/meminfo] }
				if {[llength $info] % 3 == 0} {
					foreach {attr mem unit} $info {
						if {$attr eq "MemFree:"} {
							if {[string is integer -strict $mem]} { return [expr {$mem*1024}] }
							break
						}
					}
				}
			}
		}
	}

	return -1
}


proc ncpus {} {
	return [::scidb::misc::numberOfProcessors]
}

} ;# namespace system

# vi:set ts=3 sw=3:
