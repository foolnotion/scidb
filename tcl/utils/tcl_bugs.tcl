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

# vi:set ts=3 sw=3:
