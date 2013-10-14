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
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

#set tcl_traceExec 1

namespace eval scidb {

set revision 83 ;# first revision ever

variable clipbaseName		[::scidb::db::get clipbase name]
variable scratchbaseName	[::scidb::db::get scratchbase name]
variable mergebaseName		"Mergebase"

namespace eval dir {

if {[info exists ::env(SCIDB_SHAREDIR)]} {
	set share $::env(SCIDB_SHAREDIR)
} elseif {$::tcl_platform(platform) eq "windows"} {
	set share [file dirname $::nameofexecutable]
} else {
	set share "%SHAREDIR%"
	if {[string match ?SHAREDIR? $share]} {
		set share [file tail $::nameofexecutable]
		set share [string range $share [string first scidb $share] end]
		set share "/usr/local/share/$share"
	}
}

if {$::tcl_platform(platform) eq "windows"} {
	set engines $share/engines
} else {
	set engines "%ENGINESDIR%"
	if {[string match ?ENGINESDIR? $engines]} { set engines "/usr/local/games" }
}

set home		[file nativename "~"]
set exec		[file dirname $::nameofexecutable]
set user		[file join $home .[string range [file tail $::nameofexecutable] 2 end]]
set data		[file join $share data]
set help		[file join $share help]
set hyphen	[file join $share hyphen]
set photos	[file join $share photos]
set images	[file join $share images]
set log		[file join $user log]
set backup	[file join $user backup]
set config	[file join $user config]

if {![file isdirectory $user]} {
	set setup 1
	file mkdir $user
	file mkdir [file join $user log]
	file mkdir [file join $user photos]
	file mkdir [file join $user backup]
	file mkdir [file join $user engines]
	file mkdir [file join $user textures tile marble]
	file mkdir [file join $user textures tile wood]
	file mkdir [file join $user textures tile misc]
	file mkdir [file join $user textures lite marble]
	file mkdir [file join $user textures lite wood]
	file mkdir [file join $user textures lite misc]
	file mkdir [file join $user textures dark marble]
	file mkdir [file join $user textures dark wood]
	file mkdir [file join $user textures dark misc]
	file copy  [file join $share themes] $user
} else {
	set setup 0
}

if {![file isdirectory $config]} {
	file mkdir $config
}

if {![info exists ::env(SCIDB_SHAREDIR)]} { set ::env(SCIDB_SHAREDIR) $share }

} ;# namespace dir

namespace eval file {

set options [file join [set [namespace parent]::dir::config] options.dat]
set engines [file join [set [namespace parent]::dir::config] engines.dat]

} ;# namespace file

namespace eval themes {
namespace eval mc {
	set CannotOverwriteTheme "Cannot overwrite theme %s."
}

variable Updated 0

proc update {} {
	variable Updated

	array set identifiers {
		{} {
			{Alpha|1295711284602|yellow.color|gregor}
			{Antique|1263914483272|yellow.color|gregor}
			{Apollo|1296050637190|yellow.color|gregor}
			{Arena|1348599577049|yellow.color|gregor}
			{Black & White|1322146556616|yellow.color|gregor}
			{Blackjack|1371197629186|purple|gregor}
			{Burly|1262881982561|yellow.color|gregor}
			{Burnett|1228820485389|yellow.color|gregor}
			{Country Style|1370798029772|INE543149|cmartins}
			{Creepy|1381672489858|purple|gregor}
			{Fantasy|1228820514842|yellow.color|gregor}
			{Glass|1243787890671|yellow.color|gregor}
			{Goldenrod|1243765848112|yellow.color|gregor}
			{Gray|1248527850611|yellow.color|gregor}
			{José|1243683856813|yellow.color|gregor}
			{Kunterbunt|1250851039023|yellow.color|gregor}
			{Magnetic|1243762798722|yellow.color|gregor}
			{Marble - Brown|1243532376507|yellow.color|gregor}
			{Marble - Red|1296049745744|yellow.color|gregor}
			{Mayan - Marble|1243775222632|yellow.color|gregor}
			{Mayan - Wood|1244309428838|yellow.color|gregor}
			{Modern Cheq|1244122899886|yellow.color|gregor}
			{Motif|1262882557387|yellow.color|gregor}
			{Ocean|1262882648418|yellow.color|gregor}
			{Phoenix|1354101318690|purple|gregor}
			{Primus|1368794511290|yellow.color|gregor}
			{Sand|1228828282840|yellow.color|gregor}
			{Scidb|1251901638256|yellow.color|gregor}
			{Staidly|1326986145826|yellow.color|gregor}
			{Staunton|1355510748081|yellow.color|gregor}
			{Stone Floor|1244113337107|yellow.color|gregor}
			{Virtual|1355495975711|yellow.color|gregor}
			{Virtual - Colored|1381593501788|purple|gregor}
			{Winboard|1228820514841|yellow.color|gregor}
			{Woodgrain|1296150310528|yellow.color|gregor}
		}
		piece {
			{Arena|1348599563208|yellow.color|gregor}
			{Burly|1262881395698|yellow.color|gregor}
			{Condal|1263914065014|yellow.color|gregor}
			{Contrast|1322146529013|yellow.color|gregor}
			{Emerald|1244127333315|yellow.color|gregor}
			{Glass|1243791877212|yellow.color|gregor}
			{Goldenrod|1243765822627|yellow.color|gregor}
			{Gray|1248527841922|yellow.color|gregor}
			{Green|1243460196909|yellow.color|gregor}
			{Khaki|1381672245561|purple|gregor}
			{Lemon|1251901475461|yellow.color|gregor}
			{Lemon|1227320554192|yellow.color|gregor}
			{Mayan - Red|1243775183896|yellow.color|gregor}
			{Not Black nor White|1371197617696|purple|gregor}
			{Orange - Lemon|1243778153963|yellow.color|gregor}
			{Sand|1326983597299|yellow.color|gregor}
			{Sycomore|1244122254189|yellow.color|gregor}
			{Virtual|1381586796154|purple|gregor}
			{Winboard|1228820514952|yellow.color|gregor}
			{Yellow - Blue|1243787883127|yellow.color|gregor}
		}
		square {
			{Apollo|1243715687066|yellow.color|gregor}
			{Arena|1348599714170|yellow.color|gregor}
			{Black & White|1322146381433|yellow.color|gregor}
			{Brown & Goldenrod|1355495679308|yellow.color|gregor}
			{Burly|1295711105525|yellow.color|gregor}
			{Contrast|1371196032342|purple|gregor}
			{Country Style|1370798009651|INE543149|cmartins}
			{Crater|1296048990606|yellow.color|gregor}
			{Glass|1228820514871|yellow.color|gregor}
			{Gray|1243532989423|yellow.color|gregor}
			{Marble - Black&Beige|1243775151068|yellow.color|gregor}
			{Marble - Black&Gray|1243712213706|yellow.color|gregor}
			{Marble - Black&White|1243715852129|yellow.color|gregor}
			{Marble - Blue|1243715888985|yellow.color|gregor}
			{Marble - Brown|1243715874135|yellow.color|gregor}
			{Marble - Red|1296049694406|yellow.color|gregor}
			{Ocean|1262882896027|yellow.color|gregor}
			{Primus|1368794504056|yellow.color|gregor}
			{Sand|1228820287277|yellow.color|gregor}
			{Scidb|1251901586671|yellow.color|gregor}
			{Seagreen|1355510010833|yellow.color|gregor}
			{Staidly|1326985703375|yellow.color|gregor}
			{Stone|1243792087778|yellow.color|gregor}
			{Stone Floor|1244113188050|yellow.color|gregor}
			{Sycomore|1243762745547|yellow.color|gregor}
			{Sycomore Gray|1244122565844|yellow.color|gregor}
			{Blue Sky|1381592499969|purple|gregor}
			{Winboard|1228820514851|yellow.color|gregor}
			{Wood - Brown|1228820485412|yellow.color|gregor}
			{Wood - Green|1244309414202|yellow.color|gregor}
			{Wooden|1263914443955|yellow.color|gregor}
			{Woodgrain|1296150231295|yellow.color|gregor}
		}
	}

	if {$Updated} { return }
	set Updated 1

	foreach dir {piece square {}} {
		set themesDir [file join $::scidb::dir::user themes $dir]
		foreach file [glob -nocomplain -directory [file join $::scidb::dir::share themes $dir] *.dat] {
			set ignore 1
			set f [open $file r]
			while {[gets $f line] >= 0} {
				if {[string match *identifier* $line]} {
					if {	[regexp {[{](.*)[}]} $line _ identifier]
						|| [regexp {identifier[ \t]+([^ \t]+)} $line _ identifier]} {
						if {$identifier in $identifiers($dir)} { set ignore 0 }
					}
				}
			}
			close $f
			if {!$ignore} {
				set overwrite 1
				set path [file join $themesDir [file tail $file]]
				if {[file exists $path]} {
					set exisiting 0
					set f [open $path r]
					while {[gets $f line] >= 0} {
						if {[string match *identifier* $line]} {
							if {	[regexp {[{](.*)[}]} $line _ identifier]
								|| [regexp {identifier[ \t]+([^ \t]+)} $line _ identifier]} {
								if {$identifier in $identifiers($dir)} { set exisiting 1 }
							}
						}
					}
					if {!$exisiting} {
						puts stderr [format $mc::CannotOverwriteTheme $path]
						set overwrite 0
					}
					close $f
				}
				if {$overwrite} {
					catch { file copy -force $file $path }
				}
			}
		}
	}
}

} ;# namespace themes
} ;# namespace scidb


# --- Initialization ------------------------------------------------------------
proc util::place::getWmFrameExtents {w} { return [::scidb::tk::wm extents $w] }
proc util::place::getWmWorkArea {w} { return [::scidb::tk::wm workarea $w] }
# ------------------------------------------------------------------------------


if {[::process::testOption version]} {
	puts "$::scidb::app version $::scidb::version"
	if {[file readable $::scidb::file::options]} {
		puts "option file: $::scidb::file::options"
	}
	puts "exec directory: $::scidb::dir::exec"
	puts "share directory: $::scidb::dir::share"
	exit 0
}


if {[::process::testOption print-recovery-files]} {
	foreach file [glob -directory $::scidb::dir::backup -nocomplain game-*.pgn] {
		if {[file readable $file]} { puts $file }
	}
	exit 0
}

if {[::process::testOption delete-recovery-files]} {
	foreach file [glob -directory $::scidb::dir::backup -nocomplain game-*.pgn] {
		file rename -force $file $file.bak
	}
	exit 0
}

if {[::process::testOption first-time]} {
	file delete $::scidb::file::options
	::process::setOption dont-recover
	set ::scidb::dir::setup 1
}


namespace eval mc {}

tk appname $scidb::app

tk::toplevel .application -class $::scidb::app
::scidb::tk::wm startup .
wm withdraw .application

if {[::scidb::misc::debug?]} {
	::process::setOption single-process
	if {[tk windowingsystem] eq "x11"} { ::scidb::tk::wm sync }
	if {![::process::testOption force-grab]} { proc grab {args} {} }
}

### need to predefine some namespaces ################################

namespace eval menu {}
namespace eval menu::mc {}

### some useful commands #############################################

# 'do {...} while {<condition>}' command
proc do {cmds while expr} {
	uplevel $cmds
	uplevel [list while $expr $cmds]
}


proc decr {w {step 1}} { uplevel [list incr $w [expr {-$step}]] }


proc arrayEqual {lhs rhs} {
	upvar 1 $lhs foo $rhs bar

	if {![array exists foo]} {
		return -code error "$lhs is not an array"
	}
	if {![array exists bar]} {
		return -code error "$rhs is not an array"
	}
	if {[array size foo] != [array size bar]} {
		return 0
	}
	if {[array size foo] == 0} {
		return 1
	}

	;# some 8.4 optimization using the lsort -unique feature 
	set keys [lsort -unique [concat [array names foo] [array names bar]]]
	if {[llength $keys] != [array size foo]} {
		return 0
	}

	foreach key $keys {
		if {$foo($key) ne $bar($key)} {
			return 0
		}
	}
	return 1
}


proc require {myNamespace requiredNamespaces} {
	foreach ns $requiredNamespaces {
		if {![namespace exists $ns]} {
			puts "WARNING($myNamespace): namespace ::$ns required"
		}
	}
}

namespace eval util {
namespace eval mc {

set IOErrorOccurred					"I/O Error occurred"

set IOError(CreateFailed)			"no permissions to create files"
set IOError(OpenFailed)				"open failed"
set IOError(ReadOnly)				"database is read-only"
set IOError(UnknownVersion)		"unknown file version"
set IOError(UnexpectedVersion)	"unexpected file version"
set IOError(Corrupted)				"corrupted file"
set IOError(WriteFailed)			"write operation failed"
set IOError(InvalidData)			"invalid data (file possibly corrupted)"
set IOError(ReadError)				"read error"
set IOError(EncodingFailed)		"cannot write namebase file"
set IOError(MaxFileSizeExceeded)	"maximal file size reached"
set IOError(LoadFailed)				"load failed (too many event entries)"
set IOError(NotOriginalVersion)	"file has changed outside from this session since last open"

set SelectionOwnerDidntRespond   "Timeout during drop action: selection owner didn't respond."

}

set Extensions		{.sci .si4 .si3 .cbh .cbf .CBF .pgn .PGN .zip}
set clipbaseName	Clipbase

set ShiftMask		[::scidb::tk::misc shiftMask?]
set LockMask		[::scidb::tk::misc lockMask?]
set ControlMask	[::scidb::tk::misc controlMask?]
set AltMask			[::scidb::tk::misc altMask?]
set KeyStateMask	[expr {$ShiftMask | $LockMask | $ControlMask | $AltMask}]


proc databaseName {base {withExtension 1}} {
	variable clipbaseName

	if {$base eq [::scidb::db::get clipbase name]} {
		return $clipbaseName
	}

	set name [lindex [file split $base] end]
	set ext [string tolower [file extension $name]]
	set name [file rootname $name]

	if {[string length $name] > 32} {
		set shortName [string range $name 0 14]
		append shortName "\u2026"
		append shortName [string range $name end-14 end]
		set name $shortName
	}

	if {$withExtension} {
		switch -- $ext {
			.pgn.gz	{ set ext .pgn }
			.zip		{ set ext .pgn }
			.bpgn.gz	{ set ext .bpgn }
			.sci		{ set ext "" }
		}

		if {[string length $ext]} { append name " $ext" }
	}

	return [string map {" " "\u2002"} $name]
}


proc formatResult {result} {
	if {$result eq "1/2-1/2"} { return "\u00bd-\u00bd" }
	return $result
}


proc doAccelCmd {accel keyState cmd} {
	switch -glob -- $accel {
		Alt-* {
			variable AltMask
			if {!($keyState & $AltMask)} { return } 
		}

		Ctrl-* {
			variable ControlMask
			if {!($keyState & $ControlMask)} { return }
		}

		default {
			variable ShiftMask
			variable LockMask
			variable KeyStateMask

			set keyState [expr {$keyState & $KeyStateMask}]
			if {($keyState & ($ShiftMask | $LockMask)) != $keyState} { return }
		}
	}

	eval $cmd
}


proc shiftIsHeldDown? {state} {
	variable ShiftMask
	return [expr {$state & $ShiftMask}]
}


proc altIsHeldDown? {state} {
	variable AltMask
	return [expr {$state & $AltMask}]
}


proc databasePath {file} {
	variable Extensions

	set ext [file extension $file]
	if {$ext ni $Extensions && ![string match -nocase {*.pgn.gz} $file]} {
		foreach ext $Extensions {
			set f "$file$ext"
			if {[file readable $f]} {
				return $f
			}
		}
	}

	return $file
}


proc toMainVariant {variant} {
	switch $variant { Suicide - Giveaway { return "Antichess" } }
	return $variant
}


proc catchException {cmd {resultVar {}}} {
	if {[catch { uplevel 1 $cmd } result options]} {
		array set opts $options
		if {[string first %IO-Error% $opts(-errorinfo)] >= 0} {
			lassign $opts(-errorinfo) type file error what
			set descr ""
			if {[info exists mc::IOError($error)]} {
				set descr $mc::IOError($error)
			} else {
				set descr "Unexpected I/O Error ($error)"
			}
			set msg $mc::IOErrorOccurred
			if {[string length $descr]} {
				append msg ": "
				append msg $descr
				append msg "."
			}
			set what [string toupper $what 0 0]
			set i [string first "=== Backtrace" $what]
			if {$i >= 0} { set what [string range $what 0 [incr i -1]] }
			set what [string trim $what]
			::dialog::error \
				-parent .application \
				-message $msg \
				-detail [string toupper $what 0 0] \
				-topmost 1 \
				;
			return 1
		}
		if {[string first %Interrupted% $opts(-errorinfo)] >= 0} {
			lassign $opts(-errorinfo) type count
			if {$count == -1} { return -1 }
			return [expr {-$count - 2}]
		}
		return -code $opts(-code) -errorcode $opts(-errorcode) -rethrow 1 $result
	}
	if {[llength $resultVar]} { uplevel 1 [list set $resultVar $result] }
	return 0
}


proc makePopup {w} {
	tk::toplevel $w -background white -class TooltipPopup
	wm withdraw $w
	if {[tk windowingsystem] eq "aqua"} {
		::tk::unsupported::MacWindowStyle style $w help none
	} else {
		wm overrideredirect $w true
	}
	wm attributes $w -topmost true
	tk::frame $w.f -takefocus 0 -relief solid -borderwidth 0 -background [::tooltip::background]
	pack $w.f -fill x -expand yes -padx 1 -pady 1
	return $w.f
}


proc source {what} {
	update idletasks
}

} ;# namespace util


namespace eval colors {

array set Colors {
	lite:pgn,background						#ffffff
	lite:pgn,foreground:variation			#0000ee
	lite:pgn,foreground:bracket			#0000ee
	lite:pgn,foreground:numbering			#aa0acd
	lite:pgn,foreground:nag					#ee0000
	lite:pgn,foreground:nagtext			#912a2a
	lite:pgn,foreground:comment			#006300
	lite:pgn,foreground:info				#8b4513
	lite:pgn,foreground:result				#000000
	lite:pgn,foreground:illegal			#ee0000
	lite:pgn,foreground:marks				#6300c6
	lite:pgn,foreground:empty				#666666
	lite:pgn,foreground:opening			#000000
	lite:pgn,foreground:result				#000000
	lite:pgn,background:current			#ffdd76
	lite:pgn,background:nextmove			#eeff00
	lite:pgn,background:merge				#f0f0f0
	lite:pgn,hilite:comment					#7a5807
	lite:pgn,hilite:info						#b22222
	lite:pgn,hilite:move						#dce4e5

	lite:analysis,background				#ffffee
	lite:analysis,info:background			#f5f5e4
	lite:analysis,info:foreground			darkgreen
	lite:analysis,best:foreground			darkgreen
	lite:analysis,error:foreground		darkred
	lite:analysis,active:background		#f5f5e4

	lite:database,selected					#ffdd76

	lite:tree,background						white
	lite:tree,emphasize						linen
	lite:tree,stripes							#ebf4f5
	lite:tree,ratio:color					darkgreen
	lite:tree,score:color					darkred
	lite:tree,draws:color					darkgreen
	lite:tree,progress:color				darkred
	lite:tree,progress:finished			forestgreen

	lite:variation,background				white
	lite:variation,emphasize				linen
	lite:variation,stripes					#ebf4f5

	lite:board,modifiedForeground			white
	lite:board,modifiedBackground			brown
	lite:board,fixedBackground				#fff5d6

	lite:browser,background:header		#ebf4f5
	lite:browser,background:hilite		cornflowerblue
	lite:browser,background:modified		linen
	lite:browser,foreground:hilite		white

	lite:overview,background:normal		#ebf4f5
	lite:overview,background:modified	linen

	lite:crosstable,background				#ffffff
	lite:crosstable,highlighted			#ebf4f5
	lite:crosstable,mark						#ffdd76

	lite:export,shadow						#999999
	lite:export,text							#c0c0c0

	lite:import,background					#ebf4f5
	lite:import,background:select			#ffdd76
	lite:import,background:hilite			linen

	lite:switcher,selected:background	#ffdd76
	lite:switcher,normal:background		#efefef
	lite:switcher,normal:foreground		black
	lite:switcher,hidden:background		white
	lite:switcher,hidden:foreground		#696969
	lite:switcher,emph:foreground			darkgreen
	lite:switcher,drop:background			LemonChiffon
	lite:switcher,prop:background			#aee239

	lite:fsbox,menu:headerbackground		#ffdd76
	lite:fsbox,menu:headerforeground		black
	lite:fsbox,drop:background				LemonChiffon
	lite:fsbox,selectionbackground		#ebf4f5
	lite:fsbox,selectionforeground		black
	lite:fsbox,inactivebackground			#f2f2f2
	lite:fsbox,inactiveforeground			black
	lite:fsbox,activebackground			#ebf4f5
	lite:fsbox,activeforeground			black

	lite:gamebar,background:normal		#d9d9d9
	lite:gamebar,foreground:normal		black
	lite:gamebar,background:selected		white
	lite:gamebar,background:emphasize	linen
	lite:gamebar,background:active		#efefef
	lite:gamebar,background:darker		#828282
	lite:gamebar,background:shadow		#e6e6e6
	lite:gamebar,background:lighter		white
	lite:gamebar,background:hilite		#ebf4f5
	lite:gamebar,foreground:hilite		black
	lite:gamebar,background:hilite2		cornflowerblue
	lite:gamebar,foreground:hilite2		white
	lite:gamebar,foreground:elo			darkblue

	lite:scrolledtable,background			white
	lite:scrolledtable,stripes				#ebf4f5
	lite:scrolledtable,highlight			#f4f4f4
	lite:scrolledtable,separatorcolor	darkgrey

	lite:tlistbox,background				white
	lite:tlistbox,foreground				black
	lite:tlistbox,selectbackground		#ffdd76
	lite:tlistbox,selectforeground		black
	lite:tlistbox,disabledbackground		#ebf4f5
	lite:tlistbox,disabledforeground		black
	lite:tlistbox,highlightbackground	darkblue
	lite:tlistbox,highlightforeground	white
	lite:tlistbox,dropbackground			#dce4e5
	lite:tlistbox,dropforeground			black

	lite:treetable,background				white
	lite:treetable,disabledforeground	#999999

	lite:help,foreground:gray				#999999
	lite:help,foreground:litegray			#696969
	lite:help,background:gray				#f5f5f5
	lite:help,background:emphasize		LightGoldenrod

	lite:table,background					white
	lite:table,foreground					black
	lite:table,selectionbackground		#ffdd76
	lite:table,selectionforeground		black
	lite:table,disabledforeground			#555555
	lite:table,labelforeground				black
	lite:table,labelbackground				#d9d9d9

	lite:fsbox,emphasizebackground		BlanchedAlmond

	lite:save,number							darkred
	lite:save,frequency						darkgreen
	lite:save,title							darkgreen
	lite:save,federation						darkblue
	lite:save,score							darkgreen
	lite:save,ratingType						darkblue
	lite:save,date								darkblue
	lite:save,eventDate						darkblue
	lite:save,eventCountry					darkblue
	lite:save,taglistOutline				gray
	lite:save,taglistBackground			LightYellow
	lite:save,taglistHighlighting			#ebf4f5
	lite:save,taglistCurrent				blue
	lite:save,matchlistBackground			#ebf4f5
	lite:save,matchlistHeaderForeground	#727272
	lite:save,matchlistHeaderBackground	#dfe7e8

	lite:encoding,selection					#ffdd76
	lite:encoding,active						#ebf4f5
	lite:encoding,normal						linen
	lite:encoding,description				#efefef

	lite:engine,selectbackground:dict	#ebf4f5
	lite:engine,selectbackground:setup	lightgray
	lite:engine,selectforeground:setup	black
	lite:engine,stripes						linen

	lite:default,disabledbackground		#ebf4f5
	lite:default,disabledforeground		black
	lite:default,foreground:gray			#999999

	lite:treetable,selected:focus			#ffdd76
	lite:treetable,selected!focus			#ffdd76
	lite:treetable,active:focus			#ebf4f5
	lite:treetable,hilite!selected		#ebf4f5

	lite:gamehistory,selected:focus		#ebf4f5
	lite:gamehistory,selected:hilite		#ebf4f5
	lite:gamehistory,selected!focus		#f2f2f2
	lite:gamehistory,hilite					#ebf4f5

	lite:playerdict,stripes					linen
}
# mapped from #ebf4f5
array set Colors {
	dark:tree,stripes							#dce4e5
	dark:variation,stripes					#dce4e5
	dark:import,background					#dce4e5
	dark:browser,background:header		#dce4e5
	dark:overview,background:normal		#dce4e5
	dark:crosstable,highlighted			#dce4e5
	dark:fsbox,selectionbackground		#dce4e5
	dark:gamebar,background:hilite		#dce4e5
	dark:scrolledtable,stripes				#dce4e5
	dark:tlistbox,disabledbackground		#dce4e5
	dark:tlistbox,dropbackground			#dce4e5
	dark:save,taglistHighlighting			#dce4e5
	dark:save,matchlistBackground			#dce4e5
	dark:encoding,active						#dce4e5
	dark:engine,selectbackground:dict	#dce4e5
	dark:default,disabledbackground		#dce4e5
	dark:treetable,active:focus			#dce4e5
	dark:treetable,hilite!selected		#dce4e5
	dark:gamehistory,selected:focus		#dce4e5
	dark:gamehistory,selected:hilite		#dce4e5
	dark:gamehistory,hilite					#dce4e5
	dark:fsbox,activebackground			#dce4e5
}
# mapped from #dce4e5
array set Colors {
	dark:pgn,hilite:move						#cddddf
}
# mapped from #f0f0f0
array set Colors {
	dark:pgn,background:merge				#e9e9e9
}
# mapped from #efefef
array set Colors {
	dark:switcher,normal:background		#e4e4e4
	dark:gamebar,background:active		#e4e4e4
	dark:encoding,description				#e4e4e4
}
# mapped from linen
array set Colors {
	dark:tree,emphasize						#ecded0
	dark:variation,emphasize				#ecded0
	dark:browser,background:modified		#ecded0
	dark:overview,background:modified	#ecded0
	dark:import,background:hilite			#ecded0
	dark:gamebar,background:emphasize	#ecded0
	dark:encoding,normal						#ecded0
	dark:playerdict,stripes					#ecded0
	lite:engine,stripes						#ecded0
}
# mapped from #ffffee
array set Colors {
	dark:analysis,info:background			#e7e7d8
	dark:analysis,active:background		#e7e7d8
}
# mapped from #dfe7e8
array set Colors {
	dark:save,matchlistHeaderBackground	#d1d8d9
}
# mapped from #999999
array set Colors {
	dark:default,foreground:gray			#777777
}

set Scheme dark

proc lookup {color} {
	variable Colors
	variable Scheme

	if {[string match theme,* $color]} {
		return [::theme::getColor [string range $color 6 end]]
	}

	if {[info exists Colors($Scheme:$color)]} { return $Colors($Scheme:$color) }
	if {[info exists Colors(lite:$color)]} { return $Colors(lite:$color) }

	return $color
}

} ;# namespace colors


namespace eval remote {

proc openBases {pathList} {
	set parent [::dialog::fsbox::currentDialog]
	if {[string length $parent] == 0} { set parent .application }
	raise $parent

	if {[llength $pathList]} {
		if {[llength $pathList] == 1} { set switch yes } else { set switch no }
		foreach path $pathList {
			::application::database::openBase $parent [::util::databasePath $path] no -switchToBase $switch
		}
	}

	after idle [::remote::update]
}

} ;# namespace remote

proc bgerror {err} {
	if {$err eq "selection owner didn't respond"} {
      set parent [::tkdnd::get_drop_target]
      if {[llength $parent]} {
			after idle [list dialog::error \
				-parent $parent \
				-message $::util::mc::SelectionOwnerDidntRespond \
			]
		} else {
			puts stderr "selection owner didn't respond"
		}
	} elseif {[string match {*selection doesn't exist*} $err]} {
		# ignore this stupid message. this message appears
		# in case of empty strings. this is not an error!
	} elseif {[string length $err] == 0} {
		# an empty background error! ignore this nonsense.
	} else {
		::tk::dialog::error::bgerror $err
	}
}

# vi:set ts=3 sw=3:
