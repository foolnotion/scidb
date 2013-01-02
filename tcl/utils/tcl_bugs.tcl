# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2012-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

rename trace __trace__orig

proc trace {cmd type args} {
	# Repeated "trace add $var write $cmd" results in huge performance problems.
	# Therefore everytime "trace remove $var write $cmd" should be used before
	# adding this variable.

	if {$cmd eq "add" && [string match var* $type] && [llength $args] == 3} {
		lassign $args name ops commandPrefix
		uplevel [list __trace__orig remove $type $name $ops $commandPrefix]
	}

	uplevel [list __trace__orig $cmd $type {*}$args]
}


if {[info tclversion] >= "8.6"} { ;#####################################

# Work around for a severe Tcl 8.6 bug with [namespace code ...] handling.
#
# The response of the Tcl team to this bug item
# http://sourceforge.net/tracker/index.php?func=detail&aid=2945212&group_id=10894&atid=110894
# is really nonsense. Fact is that Tcl 8.5 scripts do not work anymore, and there is no known
# substitute for [namespace code ...].

rename unknown __unknown__orig

proc unknown {args} {
	set cmd [lindex $args 0]
	if {[regexp "^:*namespace\[ \t\n\]+inscope" $cmd] && [llength $cmd] == 4} {
		lassign $cmd _ _ ns cmd
		set args [lrange $args 1 end]
		catch { namespace eval $ns [list $cmd {*}$args] } result opts
		dict unset opts -errorinfo
		dict incr opts -level
		return -options $opts $result
	}

	return [__unknown__orig {*}$args]
}

} ;# [info tclversion] >= "8.6"

# vi:set ts=3 sw=3:
