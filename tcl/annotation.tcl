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
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval annotation {
namespace eval mc {

set AnnotationEditor				"Annotation Editor"
set TooManyNags					"Too many annotations (the last one was ignored)."
set TooManyNagsDetail			"Maximal %d annotations per ply allowed."

set PrefixedCommentaries		"Prefixed Commentaries"
set MoveAssesments				"Move Assessments"
set PositionalAssessments		"Positional Assessments"
set TimePressureCommentaries	"Time Pressure Commentaries"
set AdditionalCommentaries		"Additional Commentaries"
set ChessBaseCommentaries		"ChessBase Commentaries"

set Nag(0)		"Null annotation"
# infix annotation
set Nag(1)		"Good move"
set Nag(2)		"Poor move"
set Nag(3)		"Very good move"
set Nag(4)		"Very poor move"
set Nag(5)		"Interesting move"
set Nag(6)		"Questionable move"
# suffix annotation
set Nag(7)		"Forced move (all others lose quickly)"
set Nag(8)		"Singular move (no reasonable alternatives)"
set Nag(9)		"Worst move"
set Nag(10)		"Drawish position"
set Nag(11)		"Equal chances, quiet position"
set Nag(12)		"Equal chances, active position"
set Nag(13)		"Unclear position"
set Nag(14)		"White has a slight advantage"
set Nag(15)		"Black has a slight advantage"
set Nag(16)		"White has a moderate advantage"
set Nag(17)		"Black has a moderate advantage"
set Nag(18)		"White has a decisive advantage"
set Nag(19)		"Black has a decisive advantage"
set Nag(20)		"White has a crushing advantage (Black should resign)"
set Nag(21)		"Black has a crushing advantage (White should resign)"
set Nag(22)		"White is in zugzwang"
set Nag(23)		"Black is in zugzwang"
set Nag(24)		"White has a slight space advantage"
set Nag(25)		"Black has a slight space advantage"
set Nag(26)		"White has a moderate space advantage"
set Nag(27)		"Black has a moderate space advantage"
set Nag(28)		"White has a decisive space advantage"
set Nag(29)		"Black has a decisive space advantage"
set Nag(30)		"White has a slight time (development) advantage"
set Nag(31)		"Black has a slight time (development) advantage"
set Nag(32)		"White has a moderate time (development) advantage"
set Nag(33)		"Black has a moderate time (development) advantage"
set Nag(34)		"White has a decisive time (development) advantage"
set Nag(35)		"Black has a decisive time (development) advantage"
set Nag(36)		"White has the initiative"
set Nag(37)		"Black has the initiative"
set Nag(38)		"White has a lasting initiative"
set Nag(39)		"Black has a lasting initiative"
set Nag(40)		"White has the attack"
set Nag(41)		"Black has the attack"
set Nag(42)		"White has insufficient compensation for material deficit"
set Nag(43)		"Black has insufficient compensation for material deficit"
set Nag(44)		"White has sufficient compensation for material deficit"
set Nag(45)		"Black has sufficient compensation for material deficit"
set Nag(46)		"White has more than adequate compensation for material deficit"
set Nag(47)		"Black has more than adequate compensation for material deficit"
set Nag(48)		"White has a slight center control advantage"
set Nag(49)		"Black has a slight center control advantage"
set Nag(50)		"White has a moderate center control advantage"
set Nag(51)		"Black has a moderate center control advantage"
set Nag(52)		"White has a decisive center control advantage"
set Nag(53)		"Black has a decisive center control advantage"
set Nag(54)		"White has a slight kingside control advantage"
set Nag(55)		"Black has a slight kingside control advantage"
set Nag(56)		"White has a moderate kingside control advantage"
set Nag(57)		"Black has a moderate kingside control advantage"
set Nag(58)		"White has a decisive kingside control advantage"
set Nag(59)		"Black has a decisive kingside control advantage"
set Nag(60)		"White has a slight queenside control advantage"
set Nag(61)		"Black has a slight queenside control advantage"
set Nag(62)		"White has a moderate queenside control advantage"
set Nag(63)		"Black has a moderate queenside control advantage"
set Nag(64)		"White has a decisive queenside control advantage"
set Nag(65)		"Black has a decisive queenside control advantage"
set Nag(66)		"White has a vulnerable first rank"
set Nag(67)		"Black has a vulnerable first rank"
set Nag(68)		"White has a well protected first rank"
set Nag(69)		"Black has a well protected first rank"
set Nag(70)		"White has a poorly protected king"
set Nag(71)		"Black has a poorly protected king"
set Nag(72)		"White has a well protected king"
set Nag(73)		"Black has a well protected king"
set Nag(74)		"White has a poorly placed king"
set Nag(75)		"Black has a poorly placed king"
set Nag(76)		"White has a well placed king"
set Nag(77)		"Black has a well placed king"
set Nag(78)		"White has a very weak pawn structure"
set Nag(79)		"Black has a very weak pawn structure"
set Nag(80)		"White has a moderately weak pawn structure"
set Nag(81)		"Black has a moderately weak pawn structure"
set Nag(82)		"White has a moderately strong pawn structure"
set Nag(83)		"Black has a moderately strong pawn structure"
set Nag(84)		"White has a very strong pawn structure"
set Nag(85)		"Black has a very strong pawn structure"
set Nag(86)		"White has poor knight placement"
set Nag(87)		"Black has poor knight placement"
set Nag(88)		"White has good knight placement"
set Nag(89)		"Black has good knight placement"
set Nag(90)		"White has poor bishop placement"
set Nag(91)		"Black has poor bishop placement"
set Nag(92)		"White has good bishop placement"
set Nag(93)		"Black has good bishop placement"
set Nag(94)		"White has poor rook placement"
set Nag(95)		"Black has poor rook placement"
set Nag(96)		"White has good rook placement"
set Nag(97)		"Black has good rook placement"
set Nag(98)		"White has poor queen placement"
set Nag(99)		"Black has poor queen placement"
set Nag(100)	"White has good queen placement"
set Nag(101)	"Black has good queen placement"
set Nag(102)	"White has poor piece coordination"
set Nag(103)	"Black has poor piece coordination"
set Nag(104)	"White has good piece coordination"
set Nag(105)	"Black has good piece coordination"
set Nag(106)	"White has played the opening very poorly"
set Nag(107)	"Black has played the opening very poorly"
set Nag(108)	"White has played the opening poorly"
set Nag(109)	"Black has played the opening poorly"
set Nag(110)	"White has played the opening well"
set Nag(111)	"Black has played the opening well"
set Nag(112)	"White has played the opening very well"
set Nag(113)	"Black has played the opening very well"
set Nag(114)	"White has played the middlegame very poorly"
set Nag(115)	"Black has played the middlegame very poorly"
set Nag(116)	"White has played the middlegame poorly"
set Nag(117)	"Black has played the middlegame poorly"
set Nag(118)	"White has played the middlegame well"
set Nag(119)	"Black has played the middlegame well"
set Nag(120)	"White has played the middlegame very well"
set Nag(121)	"Black has played the middlegame very well"
set Nag(122)	"White has played the ending very poorly"
set Nag(123)	"Black has played the ending very poorly"
set Nag(124)	"White has played the ending poorly"
set Nag(125)	"Black has played the ending poorly"
set Nag(126)	"White has played the ending well"
set Nag(127)	"Black has played the ending well"
set Nag(128)	"White has played the ending very well"
set Nag(129)	"Black has played the ending very well"
set Nag(130)	"White has slight counterplay"
set Nag(131)	"Black has slight counterplay"
set Nag(132)	"White has moderate counterplay"
set Nag(133)	"Black has moderate counterplay"
set Nag(134)	"White has decisive counterplay"
set Nag(135)	"Black has decisive counterplay"
set Nag(136)	"White has moderate time control pressure"
set Nag(137)	"Black has moderate time control pressure"
set Nag(138)	"White has severe time control pressure"
set Nag(139)	"Black has severe time control pressure"
# prefix annotation (extension)
set Nag(140)	"With the idea"
set Nag(141)	"Aimed against"
set Nag(142)	"Better is"
set Nag(143)	"Worse is"
set Nag(144)	"Equivalent is"
set Nag(145)	"Editor's remark"
# suffix annotation (extension)
set Nag(146)	"Novelty"
set Nag(147)	"Weak Point"
set Nag(148)	"Endgame"
set Nag(149)	"Line"
set Nag(150)	"Diagonal"
set Nag(151)	"White has a pair of Bishops"
set Nag(152)	"Black has a  pair of Bishops"
set Nag(153)	"Bishops of opposite color"
set Nag(154)	"Bishops of same color"
# suffix annotation (Scidb specific)
set Nag(155)	"Diagram"						;# Scid 3
set Nag(156)	"Diagram from black's perspective"
set Nag(157)	"Isolated pawns"				;# Scid 3
set Nag(158)	"Doubled pawns"				;# Scid 3
set Nag(159)	"Connected pawns"				;# Scid 3
set Nag(160)	"Passed pawn"
set Nag(161)	"Hanging pawns"				;# Scid 3
set Nag(162)	"Backward pawns"				;# Scid 3
set Nag(163)	"More pawns"
set Nag(164)	"More room"
set Nag(165)	"With"
set Nag(166)	"Without"
set Nag(167)	"Center"
set Nag(168)	"File"
set Nag(169)	"Rank"
set Nag(170)	"See"
set Nag(171)	"Various"
set Nag(172)	"Etc."							;# Scid 3
# suffix annotation (for ChessBase support)
set Nag(173)	"Space"
set Nag(174)	"Zeitnot"
set Nag(175)	"Development"
set Nag(176)	"Zugzwang"
set Nag(177)	"Time limit"
set Nag(178)	"Attack"
set Nag(179)	"Initiative"
set Nag(180)	"Counterplay"
set Nag(181)	"With compensation for the material"
set Nag(182)	"Pair of bishops"
set Nag(183)	"Kingside"
set Nag(184)	"Queenside"

} ;# namespace mc

array set sections {
	prefix	{ { PrefixedCommentaries 		140 145 } }
	infix		{ { MoveAssesments				  1   6 } }
	suffix	{ { MoveAssesments				  7   8 }
				  { PositionalAssessments		 10 135 }
				  { TimePressureCommentaries	136 139 }
				  { AdditionalCommentaries		146 172 }
				  { ChessBaseCommentaries		173 184 } }
}

set ranges {
	{ MoveAssesments					  1   9 }
	{ PositionalAssessments			 10 135 }
	{ TimePressureCommentaries		136 139 }
	{ PrefixedCommentaries			140 145 }
	{ AdditionalCommentaries		146 172 }
	{ ChessBaseCommentaries			173 184 }
}

# Infix            Prefix      Suffix
# +----------------+-----------+--------------------------+------+---------------------+------+
# |+----+----+----+|+----+----+|+----+----+----+----+----+|-----+|+----+----+----+----+|+----+|
# || !  | ?  | |-|||| /\ | \/ ||| +/=| =/+| =  | == | |^ ||| [+]||| (+)| X  | N  | ^^ ||| oo ||
# |+----+----+----+|+----+----+|+----+----+----+----+----+|+----+|+----+----+----+----+|+----+|
# || !! | ?? | [] ||| >= | <= ||| +/-| -/+| =~ | ~~ | -> ||| >> ||| () | <->| D  | ^_ ||| o/o||
# |+----+----+----+|+----+----+|+----+----+----+----+----+|+----+|+----+----+----+----+|+----+|
# || !? | ?! | (.)||| =  | RR ||| +--| --+| ~/=| <=>| @  ||| << ||| _|_| /^ | D' | ^= |||o..o||
# |+----+----+----+|+----+----+|+----+----+----+----+----+|+----+|+----+----+----+----+|+----+|
# +----------------+-----------+--------------------------+------+---------------------+------+

# - Gr.0------------ Gr.1 ------ Gr.2 --------------------- Gr.3 - Gr.4 ---------------- Gr.5 -
set Annotations(w) {
  {   1    2    7    140  141     14   15   10   11   36		 50    174  147  146  151    158 }
  {   3    4    8    142  143     16   17   12   13   40		 56    173  149  155  153    157 }
  {   5    6  176    144  145     18   19   44  132   32		 62    148  150  156  154    159 }
}
set Annotations(b) {
  {   1    2    7    140  141     14   15   10   11   37     51    174  147  146  152    158 }
  {   3    4    8    142  143     16   17   12   13   41     57    173  149  155  153    157 }
  {   5    6  176    144  145     18   19   45  133   33     63    148  150  156  154    159 }
 }

array set Vars {
	dialog	{}
	key		{}
	stm		{}
	prefix	{}
	infix		{}
	suffix	{}
	position	{}
	atStart	0
	used		0
	hidden	0
	force		0
}

foreach line $Annotations(w) {
	foreach nag $line { set Value($nag) 0 }
}
unset nag
unset line

variable Position	{}
variable Value
variable MaxNags
variable LastNag
variable MapToBlack
variable MapToWhite

for {set LastNag 0} {[info exists mc::Nag($LastNag)]} {incr LastNag} {}
incr LastNag -1

for {set i 0} {$i <= $LastNag} {incr i} {
	set isWhiteNag($i) [string match {White *} $mc::Nag($i)]
	set isBlackNag($i) [string match {Black *} $mc::Nag($i)]
}

for {set i 0} {$i < [llength $Annotations(w)]} {incr i} {
	set lineW [lindex $Annotations(w) $i]
	set lineB [lindex $Annotations(b) $i]

	for {set k 0} {$k < [llength $lineW]} {incr k} {
		set nagW [lindex $lineW $k]
		set nagB [lindex $lineB $k]

		set MapToBlack($nagW) $nagB
		set MapToBlack($nagB) $nagB
		set MapToWhite($nagB) $nagW
		set MapToWhite($nagW) $nagW
	}
}
unset i k nagW nagB lineW lineB


namespace import ::tcl::mathfunc::int


proc open {parent} {
	variable ::toolbar::Defaults
	variable Annotations
	variable MaxNags
	variable Position
	variable Value
	variable Vars

	set dlg $parent.__annotation__

	if {[winfo exists $dlg]} {
		wm state $dlg normal
		if {$Vars(needUpdate)} { update }
		return
	}

	set Vars(needUpdate) 1
	set Vars(dialog) $dlg
	tk::toplevel $dlg -class Scidb -relief solid
	wm withdraw $dlg
	set title "$::scidb::app: $mc::AnnotationEditor"

	set top [::ttk::frame $dlg.top -relief raised -borderwidth 2]
	pack $dlg.top -fill both -expand yes
	bind $dlg <<LanguageChanged>> [namespace code [list LanguageChanged $dlg %W]]

	if {[tk windowingsystem] ne "win32"} {
		set decor [tk::label $top.decor -justify left -text $title -font TkSmallCaptionFont]
		set font [$decor cget -font]
		$decor configure -font [list [font configure $font -family] [font configure $font -size] bold]
		pack $decor -fill x -expand yes
		tk::button $decor.close \
			-command [namespace code [list Close $dlg]] \
			-image $::gamebar::icon::15x15::close(locked) \
			-relief flat \
			-overrelief raised \
			;
		Focus $dlg out
		pack $decor.close -side right

		bind $decor <ButtonPress-1>	[namespace code [list StartMotion $top %X %Y]]
		bind $decor <ButtonRelease-1>	[namespace code [list TracePosition $top $parent]]
		bind $decor <Button1-Motion>	[namespace code [list Motion $top %X %Y]]

		grid $decor -row 0 -column 0 -columnspan 100 -sticky ew
		grid rowconfigure $top 2 -minsize $::theme::padding
	}

	set std [::ttk::frame $top.std]
	set oth [::ttk::frame $top.oth]

	set buttonDownCmd [bind Checkbutton <1>]
	set buttonUpCmd [bind Checkbutton <ButtonRelease-1>]

	set fcol 2
	set from 0
	set group 0
	foreach to {3 5 10 11 15 16} {
		set f [::ttk::frame $std.f$group -relief raised -borderwidth 1]
		grid $f -row 3 -column $fcol
		incr fcol 2
		for {set r 0} {$r < 3} {incr r} {
			for {set c $from} {$c < $to} {incr c} {
				set nag [lindex $Annotations(w) $r $c]
				set sym [lindex [::font::splitAnnotation $nag] 1]
				set row [expr {2*$r + 3}]
				set col [expr {2*$c + 1}]

				tk::checkbutton $f.$nag \
					-text $sym \
					-padx 5 -pady 5 \
					-offrelief flat \
					-indicatoron off \
					-variable [namespace current]::Value($nag) \
					-font $::font::symbol \
					-overrelief solid \
					;
				bind $f.$nag <2> [list after idle $buttonDownCmd]
				bind $f.$nag <2> +[list set [namespace current]::Vars(force) 1]
				bind $f.$nag <ButtonRelease-2> $buttonUpCmd
				bind $f.$nag <ButtonRelease-2> +[list set [namespace current]::Vars(force) 0]
				::theme::configureCanvas $f.$nag
				$f.$nag configure -command [namespace code [list SetNag $group $nag]]
				bind $f.$nag <Enter> [namespace code [list Tooltip %W $nag $r $c]]
				bind $f.$nag <Leave> [namespace code [list Tooltip hide]]
				grid $f.$nag -row $row -column $col -sticky ewns
			}
		}
		grid rowconfigure $f {2 8} -minsize 2
		grid columnconfigure $f [list [expr {2*$from}] [expr {2*($to + 1)}]] -minsize 2
		set from $to
		incr group
	}

	grid columnconfigure $std {4 6 8 10 12} -minsize 5 -weight 1

	set f TkTextFont
	set bold [list [font configure $f -family] [font configure $f -size] bold]

	for {set i 0} {$i < 7} {incr i} {
		set col [expr {2*$i + 1}]
		set cb $oth.cb$i

		::ttk::tcombobox $cb \
			-state readonly \
			-width 5 \
			-height 15 \
			-column nag \
			-searchcommand [namespace code KeyStroke] \
			-textvar [namespace current]::Value(nag:$i) \
			-disabledfont $bold \
			-disabledforeground black \
			;
		bind $cb <KeyPress-Down>	{+ ::tooltip::tooltip hide }
		bind $cb <ButtonRelease-1>	{+ ::tooltip::tooltip hide }
		bind $cb <Enter> [namespace code { Tooltip %W }]
		bind $cb <Leave> [namespace code { Tooltip hide }]
		bind $cb <<ComboboxSelected>> [namespace code [list CheckNag $cb $i]]
		bind $cb <<ComboBoxConfigured>> [namespace code [list Configured $cb]]

		grid $cb -row 3 -column $col -sticky ew

		set Value(nag:$i) {}
		set Vars(cb:$i) $cb

		$cb addcol text -id nag -width 3 -justify right
		$cb addcol text -id descr -foreground darkgreen

		SetValues $cb
		$cb resize
		$cb current 0
	}
	set MaxNags $i

	grid columnconfigure $oth {2 4 6 8 10 12} -minsize 5 -weight 1

	grid $std -row 3 -column 1 -sticky ew
	grid $oth -row 5 -column 1 -sticky ew

	grid columnconfigure $top 1 -weight 1
	grid columnconfigure $top {0 2} -minsize $::theme::padding
	grid rowconfigure $top {4 6} -minsize $::theme::padding

	wm transient $dlg $parent
	wm focusmodel $dlg $Defaults(floating:focusmodel)
	if {[tk windowingsystem] ne "win32"} {
		if {$Defaults(floating:overrideredirect)} {
			wm overrideredirect $dlg true
		} elseif {$Defaults(floating:focusmodel) ne "active"} {
			bind $dlg <FocusIn>  [namespace code [list Focus $dlg in]]
			bind $dlg <FocusOut> [namespace code [list Focus $dlg out]]
		}
	}
	if {[llength $Position] == 2} {
		::update idletasks
		scan [winfo geometry [winfo toplevel $parent]] "%dx%d+%d+%d" tw th tx ty
		set rx [expr {$tx + [lindex $Position 0]}]
		set ry [expr {$ty + [lindex $Position 1]}]
		set rw [winfo reqwidth $dlg]
		set rh [winfo reqheight $dlg]
		set sw [winfo screenwidth $dlg]
		set sh [winfo screenheight $dlg]
		set rx [expr {max(min($rx, $sw - $rw), 0)}]
		set ry [expr {max(min($ry, $sh - $rh), 0)}]
		wm geometry $dlg +$rx+$ry
	} else {
		::util::place $dlg center $parent
	}
	if {[tk windowingsystem] eq "aqua"} {
		::tk::unsupported::MacWindowStyle style $dlg plainDBox {}
	} elseif {[tk windowingsystem] eq "win32"} {
		catch { wm attributes $dlg -type utility }
		wm attributes $dlg -toolwindow
		wm title $dlg $title
	} else {
		::scidb::tk::wm noDecor $dlg
	}
	wm deiconify $dlg
	update
}


proc open? {} {
	variable Vars

	if {[llength $Vars(dialog)] == 0} { return 0 }
	if {![winfo exists $Vars(dialog)]} { return 0 }
	return [expr {[wm state $Vars(dialog)] eq "normal"}]
}


proc update {{key ""}} {
	variable Annotations
	variable MaxNags
	variable Value
	variable Vars

	if {[string length $key] == 0} {
		set key [::scidb::game::position key]
	}
	set Vars(key) $key

	if {[open?]} {
		set Vars(stm) [::scidb::game::query stm]
		lassign [::scidb::game::query annotation] Vars(infix) Vars(prefix) Vars(suffix)
		Init $Vars(dialog)
		set Vars(needUpdate) 0
	} else {
		set Vars(needUpdate) 1
	}
}


proc hide {flag} {
	variable Vars

	if {[llength $Vars(dialog)] == 0} { return }
	if {![winfo exists $Vars(dialog)]} { return }

	if {$flag} {
		if {[wm state $Vars(dialog)] eq "normal"} {
			wm state $Vars(dialog) withdrawn
			set Vars(hidden) 1
		}
	} else {
		if {$Vars(hidden)} {
			wm state $Vars(dialog) normal
			set Vars(hidden) 0
		}
	}
}


proc deactivate {} {
	variable Vars

	if {[llength $Vars(dialog)] && [winfo exists $Vars(dialog)]} {
		Init $Vars(dialog)
	}
}


proc close {} {
	variable Vars
	catch { Close $Vars(dialog) }
}


proc setNags {group args} {
	variable Vars

	if {[llength $args] == 2} {
		lassign $args key nags
	} else {
		set key [::scidb::game::position key]
		set nags [lindex $args 0]
	}

	set text ""

	for {set i 0} {$i < [llength $nags]} {incr i} {
		if {$i > 0} { append text " " }
		append text "\$[lindex $nags $i]"
	}

	::scidb::game::update $group $key $text
	::scidb::game::variation unfold -force
}


proc Close {dlg} {
	wm withdraw $dlg
}


proc Init {dlg} {
	variable Annotations
	variable MaxNags
	variable Value
	variable Vars

	foreach line $Annotations(w) {
		foreach nag $line { set Value($nag) 0 }
	}

	for {set i 0} {$i < $MaxNags} {incr i} {
		$Vars(cb:$i) set ""
	}

	set entered {}
#	for {set i 0} {$i < $MaxNags} {incr i} {
#		if {[string length [$Vars(cb:$i) get]] > 0} {
#			if {[$Vars(cb:$i) get] eq "0"} {
#				$Vars(cb:$i) set ""
#			} else {
#				lappend entered [int [$Vars(cb:$i) get]]
#			}
#		}
#	}

	set Value(155) 0	;# hack
	set Value(156) 0	;# hack
	if {[::scidb::game::current] == 9} {
		for {set i 0} {$i < $MaxNags} {incr i} {
			$Vars(cb:$i) configure -state disabled
		}
		foreach group {0 1 2 3 4 5} {
			foreach child [winfo children $dlg.top.std.f${group}] {
				$child configure -state disabled
			}
		}
		set Vars(atStart) ""
	} else {
		foreach type {prefix infix suffix} {
			ConfigureButtons $dlg $type $entered
		}

		set atStart [::scidb::game::position atStart?]

		if {$atStart != $Vars(atStart)} {
			set Vars(atStart) $atStart

			if {$atStart} { set state "disabled" } else { set state "readonly" }
			for {set i 0} {$i < $MaxNags} {incr i} {
				$Vars(cb:$i) configure -state $state
			}

			if {$atStart} { set state "disabled" } else { set state "normal" }
			foreach group {0 1 2 3 4 5} {
				foreach child [winfo children $dlg.top.std.f${group}] {
					if {[string match {*.15[56]} $child]} {
						$child configure -state normal
					} else {
						$child configure -state $state
					}
				}
			}
		}
	}
}


proc ConfigureButtons {dlg type entered} {
	variable Annotations
	variable MapToWhite
	variable MaxNags
	variable Value
	variable Vars

	set text $Vars($type)
	set annotations $Annotations([expr {$Vars(stm) eq "white" ? "b" : "w"}])
	set used 0

	foreach nag $text {
		set nag [int [string range $nag 1 end]]
		if {$nag ni $entered} {
			foreach i {0 1 2} {
				set n [lsearch -integer [lindex $annotations $i] $nag]
				if {$n >= 0} { break }
			}
			if {$n >= 0} {
				set Value($MapToWhite($nag)) 1
			} elseif {$used < $MaxNags} {
				for {set i 0} {$i < $MaxNags} {incr i} {
					if {[string length [$Vars(cb:$i) get]] == 0} {
						$Vars(cb:$i) set $nag
						break
					}
				}
				incr used
			}
		}
	}

	set Vars(used) $used
}


proc CountNags {} {
	variable Annotations
	variable MaxNags
	variable Value

	set nagList {}

	foreach line $Annotations(w) {
		foreach nag $line {
			if {$Value($nag) && $nag ni $nagList} {
				lappend nagList $nag
			}
		}
	}

	for {set i 0} {$i < $MaxNags} {incr i} {
		if {[llength $Value(nag:$i)] && $Value(nag:$i) ni $nagList} {
			lappend nagList $Value(nag:$i)
		}
	}

	return [llength $nagList]
}


proc CheckNag {cb index} {
	variable Value
	variable MaxNags

	if {[CountNags] > $MaxNags} {
		set Value(nag:$index) {}
		TooManyNagsWarning [winfo toplevel $cb]
	} else {
		SendNags [winfo toplevel $cb]
	}

	if {[$cb get] eq "0"} { $cb set "" }
}


proc SetNag {group nag} {
	variable MaxNags
	variable Value
	variable Vars

	set deselected 0
	set dlg $Vars(dialog)

	switch $nag {
		153 { if {$Value(154)} { incr deselected } }
		154 { if {$Value(153)} { incr deselected } }
		155 { if {$Value(156)} { incr deselected } }
		156 { if {$Value(155)} { incr deselected } }

		default {
			if {!$Vars(force) && $group != 3 && $group != 4} {
				foreach child [winfo children $dlg.top.std.f${group}] {
					if {![string match *.$nag $child]} {
						if {[set [$child cget -variable]]} { incr deselected }
					}
				}
			}
		}
	}

	if {[CountNags] - $deselected > $MaxNags} {
		set Value($nag) 0
		TooManyNagsWarning $dlg
	} else {
		switch $nag {
			153 { $dlg.top.std.f${group}.154 deselect }
			154 { $dlg.top.std.f${group}.153 deselect }
			155 { $dlg.top.std.f${group}.156 deselect }
			156 { $dlg.top.std.f${group}.155 deselect }

			default {
				if {!$Vars(force) && $group != 3 && $group != 4} {
					foreach child [winfo children $dlg.top.std.f${group}] {
						if {![string match *.$nag $child]} {
							if {[set [$child cget -variable]]} { $child deselect }
						}
					}
				}
			}
		}

		SendNags $dlg
	}

	::tooltip::tooltip hide
}


proc TooManyNagsWarning {dlg} {
	variable MaxNags
	variable ::toolbar::Defaults

	::tooltip::tooltip hide
	if {$Defaults(floating:overrideredirect)} { wm withdraw $dlg }
	::dialog::info -parent $dlg -message $mc::TooManyNags -detail [format $mc::TooManyNagsDetail $MaxNags]
	if {$Defaults(floating:overrideredirect)} { wm state $dlg normal }
}


proc SendNags {dlg} {
	variable Value
	variable Vars
	variable MaxNags
	variable Annotations
	variable MapToBlack

	set nagList {}

	foreach line $Annotations(w) {
		foreach nag $line {
			if {$Value($nag) && $nag ni $nagList} {
				lappend nagList $nag
			}
		}
	}

	if {$Vars(stm) eq "white"} {
		set list {}
		foreach nag $nagList {
			lappend list $MapToBlack($nag)
		}
		set nagList $list
	}

	for {set i 0} {$i < $MaxNags} {incr i} {
		if {[llength $Value(nag:$i)] && $Value(nag:$i) ni $nagList} {
			lappend nagList $Value(nag:$i)
		}
	}

	setNags annotation $Vars(key) $nagList
}


proc Tooltip {w args} {
	if {$w eq "hide"} {
		::tooltip::tooltip hide
	} elseif {[string match *Checkbutton [winfo class $w]]} {
		variable Annotations

		if {[$w cget -state] eq "disabled"} { return }
		lassign $args nag row col
		set stm [::scidb::pos::stm]
		if {$stm eq "white"} { set stm b } else { set stm w }
		set nag [lindex $Annotations($stm) $row $col]
		::tooltip::show $w "[string toupper $mc::Nag($nag) 0 0] (\$$nag)"
	} elseif {[string match *Combobox [winfo class $w]]} {
		set nag [$w get]
		if {[info exists mc::Nag($nag)]} {
			::tooltip::show $w [string toupper $mc::Nag($nag) 0 0]
		}
	}
}


proc Configured {cb} {
	set [namespace current]::Current 0
}


proc KeyStroke {cb code sym} {
	variable LastNag
	variable Current
	variable ranges

	if {[string is integer -strict $code]} {
		if {$Current == 0} {
			set Current $code
		} else {
			set Current [expr {10*$Current + $code}]
		}

		if {$Current > $LastNag} {
			set Current 0
			set current 0
		} else {
			set current $Current
			foreach range $ranges {
				if {$current >= [lindex $range 1]} { incr current }
			}
		}

		$cb select $current
	} else {
		set Current 0
	}
}


proc LanguageChanged {dlg w} {
	variable Values
	variable Vars

	if {$dlg ne $w} { return }
	$dlg.top.decor configure -text "${::scidb::app}: $mc::AnnotationEditor"

	for {set i 0} {$i < 7} {incr i} {
		SetValues $Vars(cb:$i) 
	}
}


proc SetValues {cb} {
	variable LastNag
	variable ranges

	$cb listinsert [list 0 "($mc::Nag(0))"]

	foreach range $ranges {
		lassign $range descr from to
		$cb listinsert [list {} [set mc::$descr]] -span {descr 1} -enabled no -foreground black

		for {set k $from} {$k <= $to} {incr k} {
			$cb listinsert [list $k [string toupper $mc::Nag($k) 0 0]]
		}
	}
}


proc TracePosition {frame parent} {
	variable Position

	set fx [winfo rootx $frame]
	set fy [winfo rooty $frame]
	set tx [winfo rootx $parent]
	set ty [winfo rooty $parent]

	set Position [list [expr {$fx - $tx}] [expr {$fy - $ty}]]
}


proc StartMotion {frame x y} {
	variable Vars

	set win [winfo parent $frame]
	set Vars(x) [expr {[winfo rootx $win] - $x}]
	set Vars(y) [expr {[winfo rooty $win] - $y}]
}


proc Motion {frame x y} {
	variable Vars

	if {![info exists Vars(x)]} { return }	;# this may happen during a double click

	incr x $Vars(x)
	incr y $Vars(y)
	wm geometry [winfo parent $frame] +$x+$y
}


proc Focus {dlg mode} {
	variable ::toolbar::Defaults

	if {$mode eq "in"} {
		set bg $Defaults(floating:frame:activebg)
		set fg $Defaults(floating:frame:activefg)
	} else {
		if {[string match *.top.oth.cb* [focus]]} { return }
		set bg $Defaults(floating:frame:background)
		set fg $Defaults(floating:frame:foreground)
	}

	$dlg.top.decor configure -background $bg -foreground $fg
	$dlg.top.decor.close configure \
		-background $bg \
		-foreground $fg \
		-activebackground $bg \
		-activeforeground $fg \
		;
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::Position
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace annotation

# vi:set ts=3 sw=3:
