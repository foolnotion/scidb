# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2010-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval web {

variable Browsers {iexplorer opera lynx konqueror w3m links epiphan galeon mosaic amaya browsex elinks}


# borrowed from scid-4.1/tcl/htext.tcl
proc open {url} {
	global tcl_platform

	::widget::busyCursor on
	regsub -all " " $url "%20" url

	if {![catch {tk windowingsystem} wsystem] && $wsystem eq "aqua"} {
		catch {exec open $url &}
	} elseif {$tcl_platform(platform) eq "windows"} {
		if {$tcl_platform(os) eq "Windows NT"} {
			catch {exec $::env(COMSPEC) /c start $url &}
		} else {
			catch {exec start $url &}
		}
	} else {	;# unix
		if {[file executable [auto_execok iceweasel]]} {
			if {[catch {exec /bin/sh -c "$::auto_execs(iceweasel) -remote 'openURL($url)'"}]} {
				catch {exec /bin/sh -c "$::auto_execs(iceweasel) '$url'" &}
			}
		} elseif {[file executable [auto_execok firefox]]} {
			if {[catch {exec /bin/sh -c "$::auto_execs(firefox) -remote 'openURL($url)'"}]} {
				catch {exec /bin/sh -c "$::auto_execs(firefox) '$url'" &}
			}
		} elseif {[file executable [auto_execok mozilla]]} {
			if {[catch {exec /bin/sh -c "$::auto_execs(mozilla) -remote 'openURL($url)'"}]} {
				catch {exec /bin/sh -c "$::auto_execs(mozilla) '$url'" &}
			}
		} elseif {[file executable [auto_execok www-browser]]} {
			catch {exec /bin/sh -c "$::auto_execs(www-browser) '$url'" &}
		} elseif {[file executable [auto_execok netscape]]} {
			if {[catch {exec /bin/sh -c "$::auto_execs(netscape) -raise -remote 'openURL($url)'"}]} {
				catch {exec /bin/sh -c "$::auto_execs(netscape) '$url'" &}
			}
		} else {
			variable Browsers
			foreach executable $Browsers {
				set executable [auto_execok $executable]
				if [string length $executable] {
					set command [list $executable $url &]
					catch {exec /bin/sh -c "$executable '$url'" &}
					break
				}
			}
		}
	}

	::widget::busyCursor off
}

} ;# namespace web

# vi:set ts=3 sw=3:
