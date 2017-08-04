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

::util::source internationalization

namespace eval mc {

set Key(Alt)			"Alt"
set Key(BS)				"\u232b"
set Key(Ctrl)			"Ctrl"
set Key(Del)			"Delete"
set Key(Down)			"\u2193"
set Key(End)			"End"
set Key(Enter)			"Enter"
set Key(Esc)			"Esc"
set Key(Home)			"Home"
set Key(Ins)			"Insert"
set Key(Left)			"\u2190"
set Key(Next)			"Page\u2193"	;# Page Down
set Key(Option)		"option"			;# Mac
set Key(Prior)			"Page\u2191"	;# Page Up
set Key(Right)			"\u2192"
set Key(Shift)			"Shift"
set Key(Space)			"\u2423"
set Key(Up)				"\u2191"

set Alignment			"Alignment"
set Apply				"Apply"
set Archive				"Archive"
set Background			"Background"
set Black				"Black"
set Bottom				"Bottom"
set Cancel				"Cancel"
set Clear				"Clear"
set Close				"Close"
set Color				"Color"
set Colors				"Colors"
set Configuration		"Configuration"
set Copy					"Copy"
set Country				"Country"
set Cut					"Cut"
set Dark					"Dark"
set Database			"Database"
set Default				"Default"
set Delete				"Delete"
set Edit					"Edit"
set Empty				"Empty"
set Enabled				"Enabled"
set File					"File"
set Filter				"Filter"
set From					"From"
set Game					"Game"
set Hidden				"Hidden"
set InternalMessage	"Internal message"
set Layout				"Layout"
set Left					"Left"
set Lite					"Light"
set Low					"Low"
set Modify				"Modify"
set Monospaced			"Monospaced"
set No					"No"
set Normal				"Normal"
set Number				"Number"
set OK					"OK"
set Order				"Order"
set Paste				"Paste"
set PieceSet			"Piece Set"
set Preview				"Preview"
set Redo					"Redo"
set Reset				"Reset"
set Right				"Right"
set SelectAll			"Select all"
set Texture				"Texture"
set Theme				"Theme"
set To					"To"
set Top					"Top"
set Undo					"Undo"
set Variant				"Variant"
set Variation			"Variation"
set Volume				"Volume"
set White				"White"
set Yes					"Yes"

set Piece(K)			"King"
set Piece(Q)			"Queen"
set Piece(R)			"Rook"
set Piece(B)			"Bishop"
set Piece(N)			"Knight"
set Piece(P)			"Pawn"

set Logical(reset)	"Reset"
set Logical(or)		"Or"
set Logical(and)		"And"
set Logical(null)		"Clear"
set Logical(remove)	"Remove"
set Logical(not)		"Not"

set LogicalDetail(reset)			"Clear filter / Fill display"
set LogicalDetail(or)				"Remove from filter / Add to display"
set LogicalDetail(and)				"Extend filter / Restrict display"
set LogicalDetail(null)				"Fill filter / Clear display"
set LogicalDetail(remove)			"Add to filter / Remove from display"
set LogicalDetail(not)				"Restrict filter / Extent display"

set VariantName(Undetermined)		"Undetermined"
set VariantName(Normal)				"Normal Chess"
set VariantName(Bughouse)			"Bughouse Chess"
set VariantName(DropChess)			"Drop Chess"
set VariantName(Crazyhouse)		"Crazyhouse"
set VariantName(Chessgi)			"Chessgi"
set VariantName(ThreeCheck)		"Three-check Chess"
set VariantName(KingOfTheHill)	"King-of-the-Hill"
set VariantName(Antichess)			"Antichess"
set VariantName(Suicide)			"Suicide"
set VariantName(Giveaway)			"Giveaway"
set VariantName(Losers)				"Losers"
set VariantName(Chess960)			"Chess 960"
set VariantName(Symm960)			"Chess 960 (symmetrical only)"
set VariantName(Shuffle)			"Shuffle Chess"

set NotAvailableSign "\u2298"
#set NotAvailableSign "\u2370" ;# not available on some systems

array set EcoTrans		{}
set EcoMatch				{}
set Language				English

set langID					en
set langEnglish			en
set encoding				iso8859-1
set encodingEnglish		iso8859-1

set input(English)		english.tcl

event add <<LanguageChanged>>	Language

set countries {
	az be bg bs ca cs cy da de el en es et eu fi fo fr ga gd hr hu hy is it ka kk
	ky lb lt lv mk mo mt nl no pl pt rm ro ru sk sl sq sr sv tg tk tr uk uz wa xx
}

array set langToCountry {
	az		AZE
	be		BLR
	bg		BUL
	br		GBR
	bs		BIH
	ca		CAT
	cs		CZE
	cy		WLS
	da		DEN
	de		GER
	de+	GER
	dsb	SRB
	el		GRE
	en		GBR
	eo		ZZX
	es		ESP
	et		EST
	eu		BAS
	fi		FIN
	fo		FAI
	fr		FRA
	ga		NIR
	gd		SCO
	gl		ESP
	he		ISR
	hr		CRO
	hsb	SRB
	hu		HUN
	hy		ARM
	ia		UNK
	is		ISL
	it		ITA
	ka		GEO
	kk		KAZ
	ku		TUR
	ky		KGZ
	la		ITA
	lb		LUX
	lt		LTU
	lv		LAT
	mk		MKD
	mo		MDA
	ms		MAS
	mt		MLT
	nl		NED
	no		NOR
	pl		POL
	pt		POR
	rm		SUI
	ro		ROU
	ru		RUS
	se		FIN
	sk		SVK
	sl		SLO
	sq		ALB
	sr		SRB
	sv		SWE
	tg		TJK
	tk		TKM
	tr		TUR
	uk		UKR
	uz		UZB
	wa		BEL
	wen	SRB
	xx		ZZX
}

# unknown: ast bat br eo iu oc wa wen
array set lang2Region {
	ca 1 cy 1 da 1 de 1 el 1 en 1 es 1 et 1 eu 1 fi 1 fo 1 fr 1 ga 1 gd 1 gl 1 hr 1 hu 1
	it 1 is 1 kl 1 la 1 lb 1 nl 1 no 1 pt 1 rm 1 se 1 sv 1
	be 2 bg 2 bs 2 cs 2 hy 2 lv 2 lt 2 pl 2 ro 2 sk 2 sl 2 sq 2 sr 2
	af 3 am 3 ar 3 he 3 mg 3 mt 3 rn 3 rw 3 so 3 sw 3
	az 4 fa 4 ka 4 kk 4 ku 4 ky 4 ms 5 ps 4 ru 4 tg 4 tk 4 tr 4 uk 4 uz 4
	as 5 bn 5 dv 5 hi 5 id 5 ja 5 km 5 ko 5 lo 5 mk 5 mn 5 mr 5 my 5 pa 5 sm 5 ta 5 th 5 tl 5 ur 5 zh 5
	vi 6
}

array set encoding2Region {
	ascii			{5}
	cp1250		{1 2}
	cp1251		{2 4 5}
	cp1252		{1 2 3 4}
	cp1253		{1}
	cp1254		{4}
	cp1255		{3}
	cp1256		{3}
	cp1257		{1 2}
	cp1258		{6}
	cp437			{1}
	cp737			{1}
	cp775			{1 2}
	cp850			{1 2 3 4}
	cp852			{1 2}
	cp855			{2 4 5}
	cp857			{4}
	cp860			{1}
	cp861			{1}
	cp862			{3}
	cp863			{1}
	cp864			{3}
	cp865			{1}
	cp866			{2 4 5}
	cp869			{1}
	cp874			{5}
	cp932			{5}
	cp936			{5}
	cp949			{5}
	cp950			{5}
	dingbats		{}
	ebcdic		{}
	euc-cn		{5}
	euc-jp		{5}
	euc-kr		{5}
	gb12345		{5}
	gb1988		{5}
	gb2312		{5}
	gb2312-raw	{5}
	iso2022		{5}
	iso2022-jp	{5}
	iso2022-kr	{5}
	iso8859-1	{1 2 3 4}
	iso8859-2	{1 2}
	iso8859-3	{3 4}
	iso8859-4	{1 2}
	iso8859-5	{2 4 5}
	iso8859-6	{3}
	iso8859-7	{1}
	iso8859-8	{3}
	iso8859-9	{4}
	iso8859-10	{1}
	iso8859-11	{5}
	iso8859-12	{5}
	iso8859-13	{}
	iso8859-14	{1}
	iso8859-15	{1 2 3 5}
	iso8859-16	{1 2}
	jis0201		{5}
	jis0208		{5}
	jis0212		{5}
	koi8-r		{4}
	koi8-u		{2 4}
	ksc5601		{5}
	macCentEuro	{1 2 3 4}
	macCroatian	{1}
	macCyrillic	{2 4 5}
	macDingbats	{}
	macGreek		{1}
	macIceland	{1}
	macJapan		{5}
	macRoman		{1 2 3 4}
	macRomania	{2}
	macThai		{5}
	macTurkish	{4}
	macUkraine	{4}
}


proc currentLanguage {} { return [set [namespace current]::Language] }


proc countryForLang {lang} {
	variable langToCountry

	if {[info exists langToCountry($lang)]} { return $langToCountry($lang) }
	return UNK
}


proc setLang {id} {
	variable langID
	variable ::i18n::languages

	set n [lsearch -exact -index 1 $languages $id]
	if {$n == -1} {
		set id en	;# language id is gone
		set n [lsearch -exact -index 1 $languages $id]
		if {$n == -1} { return } ;# no language set loaded
	}

	set langID $id
	::font::useLanguage $id
	selectLang [lindex $languages $n 0]
}


proc var {var str} {
	if {![info exists ${var}_($str)]} {
		set ${var}_($str) "[set $var]$str"
		trace add variable $var write "[namespace current]::SetVar $str"
	}
	return ${var}_($str)
}


proc stripped {var} {
	if {![info exists ${var}_()]} {
		set ${var}_() [stripAmpersand [set $var]]
		trace add variable $var write [namespace current]::SetStripped
	}
	return ${var}_()
}


proc stripAmpersand {str} {
	return [string map {& {}} $str]
}


proc extractAccelerator {str} {
	set i [string first "&" $str]
	if {$i == -1} { return "" }
	return [string index $str [expr {$i + 1}]]
}


proc translate {str} {
	return [set $str]
}


proc mapForSort {str}	{ return [string map $mc::SortMapping $str] }
proc mapToAscii {str}	{ return [string map $mc::AsciiMapping $str] }

proc mappingForSort {}	{ return $mc::SortMapping }
proc mappingToAscii {}	{ return $mc::AsciiMapping }
proc sortOrderTable {}	{ return $mc::SortOrder }


proc extract {msg n} {
	set msg2 ""
	lassign [split $msg |] msg msg2
	if {[string length $msg2] == 0 || $n == 1} { return $msg }
	return $msg2
}


proc setup {} {
	variable languages

	set languages {}
	if {[info exists ::i18n::languages]} {
		foreach entry $::i18n::languages {
			lassign $entry lang code encoding file
			set f [file join $::scidb::dir::share lang $file]

			if [file readable $f] {
				set [namespace current]::lang$lang $code
				set [namespace current]::encoding$lang $encoding
				set [namespace current]::input($lang) $file
				lappend languages $code
			}
		}
	}

	selectLang
}


proc selectLang {{lang {}}} {
	variable EcoTrans
	variable EcoMatch
	variable Language
	variable langID
	variable encoding

	if {[llength $lang]} { set Language $lang }

	if {![info exists ::mc::lang$Language]} {
		set msg "Language '$Language' is currently not supported, a volunteer is wanted who likes to finish the translation for '$Language'."
		after idle [list ::dialog::info -message $msg]
		set Language English
	}

	set langID [set ::mc::lang$Language]
	set encoding [set ::mc::encoding$Language]

	set file [file join $::scidb::dir::share lang $mc::input($Language)]
	if {[file readable $file]} {
		set f [open $file r]
		chan configure $f -encoding $encoding

		while {[gets $f line] >= 0} {
			if {[string length $line] > 0 && [string index $line 0] ne "#"} {
				set [lindex $line 0] [lindex $line 1]
			}
		}

		close $f
	}

	if {[tk windowingsystem] eq "aqua"} { set ::mc::Ctrl "Cmd" }

	set file [file join $::scidb::dir::share lang nag $mc::input($Language)]
	if {[file readable $file]} {
		set f [open $file r]
		chan configure $f -encoding $encoding

		while {[gets $f line] >= 0} {
			if {[string length $line] > 0 && [string index $line 0] ne "#"} {
				lassign [split $line \"] nag descr
				set ::annotation::mc::Nag([string trim $nag]) $descr
			}
		}

		close $f
	}

	array unset EcoTrans
	array unset EcoMatch

	set file [file join $::scidb::dir::share lang eco $mc::input($Language)]
	if {![file readable $file]} {
		# use English descriptions as fallback
		set file [file join $::scidb::dir::share lang eco $mc::input(English)]
	}
	if {[file readable $file]} {
		set f [open $file r]
		chan configure $f -encoding $encoding

		while {[gets $f line] >= 0} {
			if {[string length $line] > 0 && [string index $line 0] ne "#"} {
				set key [lindex $line 0]
				set val [lindex $line 1]
				if {[string match {\* *} $key] && [string match {*%1*} $val]} {
					lappend EcoMatch $key $val
				} else {
					lappend EcoTrans([string index $key 0],[string length $key]) $key $val
				}
			}
		}

		close $f
	}

	InvokeLang . $Language
}


proc translateEco {str} {
	variable EcoTrans
	variable EcoMatch

	set list EcoTrans([string index $str 0],[string length $str])

	if {[info exists $list]} {
		foreach {key val} [set $list] {
			if {$key eq $str} {
				return $val
			}
		}
	}

	foreach {key val} $EcoMatch {
		if {[string match $key $str]} {
			if {[string index $key 0] eq "*"} {
				set i [expr {[string last [string range $key 2 end] $str] - 2}]
				set s [translateEco [string range $str 0 $i]]
			} else {
				set i [expr {[string length $key] - 1}]
				set s [translateEco [string range $str $i end]]
			}
			set t [string map [list %1 $s] $val]
			return $t
		}
	}

	return [TranslateParen $str]
}


proc TranslateParen {str} {
	set i1 [string first "(" $str]
	if {$i1 == -1} { return [TranslateColon $str] }
	set i2 [string last ")" $str]
	if {$i2 == -1} { return [TranslateColon $str] }

	set str1 [string range $str 0 [expr {$i1 - 1}]]
	set str2 [string range $str [expr {$i1 + 1}] [expr {$i2 - 1}]]
	set str3 [string range $str [expr {$i2 + 1}] end]

	set spc1 ""
	set spc2 ""

	if {[string index $str1 end] eq " "} {
		set str1 [string trimright $str1]
		set spc1 " "
	}
	if {[string index $str3 end] eq " "} {
		set str3 [string trimleft $str3]
		set spc2 " "
	}

	append result [translateEco $str1]
	append result $spc1
	append result "("
	append result [translateEco $str2]
	append result ")"
	append result $spc2
	append result [translateEco $str3]

	return $result
}


proc TranslateColon {str} {
	set i [string first ": " $str]
	if {$i == -1} { return [TranslateComma $str] }

	set str1 [string range $str 0 [expr {$i - 1}]]
	set str2 [string range $str [expr {$i + 2}] end]

	append result [translateEco $str1]
	append result ": "
	append result [translateEco $str2]

	return $result
}


proc TranslateComma {str} {
	set i [string first ", " $str]
	if {$i == -1} { return [TranslateAmpersand $str] }

	set str1 [string range $str 0 [expr {$i - 1}]]
	set str2 [string range $str [expr {$i + 2}] end]

	append result [translateEco $str1]
	append result ", "
	append result [translateEco $str2]

	return $result
}


proc TranslateAmpersand {str} {
	set i [string first " & " $str]
	if {$i == -1} { return [TranslateSpace $str] }

	set str1 [string range $str 0 [expr {$i - 1}]]
	set str2 [string range $str [expr {$i + 3}] end]

	append result [translateEco $str1]
	append result " & "
	append result [translateEco $str2]

	return $result
}


proc TranslateSpace {str} {
	set words [split $str " "]
	if {[llength $words] == 1} { return [TranslateHyphen $str] }
	set n [llength $words]
	set result ""

	for {set i 0} {$i < $n} {} {
		for {set k [expr {$n - 1}]} {$k >= $i} {} {
			set seq [join [lrange $words $i $k] " "]
			set res [TranslateHyphen $seq]

			if {$res ne $seq} {
				if {$i > 0} { append result " " }
				append result $res
				set i [expr {$k + 1}]
				set k [expr {$n - 1}]
			} elseif {$i == $k} {
				if {$i > 0} { append result " " }
				append result $seq
				incr i
				set k [expr {$n  - 1}]
			} elseif {$k == $i} {
				incr i
				set k [expr {$n  - 1}]
			} else {
				incr k -1
			}
		}
	}

	return $result
}


proc TranslateHyphen {str} {
	set result [TranslateSlash $str]

	if {$result eq $str} {
		set i [string first "-" $str]
		
		if {$i >= 0} {
			set str1 [string range $str 0 [expr {$i - 1}]]
			set str2 [string range $str [expr {$i + 1}] end]

			set result ""
			append result [TranslateSlash $str1]
			append result "-"
			append result [TranslateSpace $str2]
		}
	}

	return $result
}


proc TranslateSlash {str} {
	set result [TranslateWord $str]

	if {$result eq $str} {
		set i [string first "/" $str]
		
		if {$i >= 0} {
			set str1 [string range $str 0 [expr {$i - 1}]]
			set str2 [string range $str [expr {$i + 1}] end]

			set result ""
			append result [TranslateWord $str1]
			append result "/"
			append result [TranslateSpace $str2]
		}
	}

	return $result
}


proc TranslateWord {str} {
	variable EcoTrans

	set list EcoTrans([string index $str 0],[string length $str])

	if {[info exists $list]} {
		foreach {key val} [set $list] {
			if {$key eq $str} { return $val }
		}
	}

	return $str
}


proc SetVar {str var {unused {}} {unused {}}} {
	set ${var}_($str) "[set $var]$str"
}


proc SetStripped {var {unused {}} {unused {}}} {
	set ${var}_() [stripAmpersand [set $var]]
}


proc InvokeLang {w lang} {
	if {![winfo exists $w]} { return }
	event generate $w <<LanguageChanged>> -data $lang
	if {![winfo exists $w]} { return }
	foreach child [winfo children $w] {
		InvokeLang $child $lang
	}
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Language
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace mc

# vi:set ts=3 sw=3:
