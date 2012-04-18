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

::util::source encoding-dialog

namespace eval encoding {
namespace eval mc {

# Iso-639-1/Iso-639-2/Iso-639-3

set Lang(FI)	"Fide"					;#
set Lang(af)	"Afrikaans"				;# afr
set Lang(ar)	"Arabic"					;# ara
set Lang(ast)	"Leonese"				;# ast
set Lang(az)	"Azerbaijani"			;# aze
set Lang(bat)	"Baltic"					;# bat
set Lang(be)	"Belarusian"			;# bel
set Lang(bg)	"Bulgarian"				;# bul
set Lang(br)	"Breton"					;# bre
set Lang(bs)	"Bosnian"				;# bos
set Lang(ca)	"Catalan"				;# cat
set Lang(cs)	"Czech"					;# cze
set Lang(cy)	"Welsh"					;# wel
set Lang(da)	"Danish"					;# dan
set Lang(de)	"German"					;# ger
set Lang(de+)	"German (reformed)"	;# ger
set Lang(el)	"Greek"					;# gre
set Lang(en)	"English"				;# eng
set Lang(eo)	"Esperanto"				;# epo
set Lang(es)	"Spanish"				;# spa
set Lang(et)	"Estonian"				;# est
set Lang(eu)	"Basque"					;# baq
set Lang(fi)	"Finnish"				;# fin
set Lang(fo)	"Faroese"				;# fao
set Lang(fr)	"French"					;# fre
set Lang(ga)	"Irish"					;# gle
set Lang(gd)	"Scottish"				;# sco
set Lang(gl)	"Galician"				;# glg
set Lang(he)	"Hebrew"					;# heb
set Lang(hi)	"Hindi"					;# hin
set Lang(hr)	"Croatian"				;# scr
set Lang(hu)	"Hungarian"				;# hun
set Lang(hy)	"Armenian"				;# hye
set Lang(ia)	"Interlingua"			;# ina
set Lang(is)	"Icelandic"				;# ice
set Lang(it)	"Italian"				;# ita
set Lang(iu)	"Inuktitut"				;# iku
set Lang(ja)	"Japanese"				;# jpn
set Lang(ka)	"Georgian"				;# kat
set Lang(kk)	"Kazakh"					;# kaz
set Lang(kl)	"Greenlandic"			;# kal
set Lang(ko)	"Korean"					;# kor
set Lang(ku)	"Kurdish"				;# kur
set Lang(ky)	"Kirghiz"				;# kir
set Lang(la)	"Latin"					;# lat
set Lang(lb)	"Luxembourgish"		;# ltz
set Lang(lt)	"Lithuanian"			;# lit
set Lang(lv)	"Latvian"				;# lav
set Lang(mk)	"Macedonian"			;# mac
set Lang(mo)	"Moldovan"				;# ron
set Lang(ms)	"Malay"					;# may
set Lang(mt)	"Maltese"				;# mlt
set Lang(nl)	"Dutch"					;# dut
set Lang(no)	"Norwegian"				;# nor
set Lang(oc)	"Occitan"				;# oci
set Lang(pl)	"Polish"					;# pol
set Lang(pt)	"Portuguese"			;# por
set Lang(rm)	"Romansh"				;# roh
set Lang(ro)	"Romanian"				;# rum
set Lang(ru)	"Russian"				;# rus
set Lang(se)	"Sami"					;# smi
set Lang(sk)	"Slovak"					;# slo
set Lang(sl)	"Slovenian"				;# slv
set Lang(sq)	"Albanian"				;# alb
set Lang(sr)	"Serbian"				;# scc
set Lang(sv)	"Swedish"				;# swe
set Lang(sw)	"Swahili"				;# swa
set Lang(tg)	"Tajik"					;# tgk
set Lang(th)	"Thai"					;# tha
set Lang(tk)	"Turkmen"				;# tuk
set Lang(tl)	"Tagalog"				;# tgl
set Lang(tr)	"Turkish"				;# tur
set Lang(uk)	"Ukrainian"				;# ukr
set Lang(uz)	"Uzbek"					;# uzb
set Lang(vi)	"Vietnamese"			;# vie
set Lang(wa)	"Walloon"				;# wln
set Lang(wen)	"Sorbian"				;# wen
set Lang(hsb)	"Upper Sorbian"		;# hsb
set Lang(dsb)	"Lower Sorbian"		;# dsb
set Lang(zh)	"Chinese"				;# chi

set Font(hi)	"Devanagari"			;# hin

set AutoDetect				"auto-detection"

set Encoding				"Encoding"
set Description			"Description"
set Languages				"Languages (Fonts)"
set UseAutoDetection		"Use Auto-Detection"

set ChooseEncodingTitle	"Choose Encoding"

set CurrentEncoding		"Current encoding:"
set DefaultEncoding		"Default encoding:"
set SystemEncoding		"System encoding:"

} ;# namespace mc

# source: <http://www.w3.org/International/O-charset-lang.html>
variable Encodings {
	{ ascii			{American Standard Code for Information Interchange} {} }
	{ big5			{BIG 5} {zh} }
	{ cp1250			{Windows Code page} {bs de en hr cs de hu pl ro sk sl sq} }
	{ cp1251			{Windows Code page} {be bg en mk mo ru sr uk} }
	{ cp1252			{Windows Code page} {af ast sq eu br ca da de en fo fi fr gd gl is ga it ku la lb nl no oc pt rm es sw sv wa} }
	{ cp1253			{Windows Code page} {el} }
	{ cp1254			{Windows Code page} {tr} }
	{ cp1255			{Windows Code page} {he} }
	{ cp1256			{Windows Code page} {ar} }
	{ cp1257			{Windows Code page} {et lv lt} }
	{ cp1258			{Windows Code page} {vi} }
	{ cp437			{DOS Code page} {en} }
	{ cp737			{DOS Code page} {el} }
	{ cp775			{DOS Code page} {et lv lt} }
	{ cp850			{DOS Code page} {af sq eu br ca en fo gl de ga it ku la ast lb oc rm gd es sw wa} }
	{ cp852			{DOS Code page} {bs hr cs hu pl ro sk} }
	{ cp855			{DOS Code page} {be bg mk ru sr} }
	{ cp857			{DOS Code page} {tr} }
	{ cp860			{DOS Code page} {pt} }
	{ cp861			{DOS Code page} {is} }
	{ cp862			{DOS Code page} {he} }
	{ cp863			{DOS Code page} {fr} }
	{ cp864			{DOS Code page} {ar} }
	{ cp865			{DOS Code page} {da no sv} }
	{ cp866			{DOS Code page} {be bg mk ru sr} }
	{ cp869			{DOS Code page} {el} }
	{ cp874			{DOS Code page} {th} }
	{ cp932			{Windows Code page} {ja} }
	{ cp936			{Windows Code page} {zh} }
	{ cp949			{Windows Code page} {ko} }
	{ cp950			{Windows Code page} {zh} }
	{ euc-cn			{Extended Unix Code} {zh} }
	{ euc-jp			{Extended Unix Code} {ja} }
	{ euc-kr			{Extended Unix Code} {ko} }
	{ gb12345		{Guojia Biaozhun} {zh} }
	{ gb1988			{Guojia Biaozhun} {zh} }
	{ gb2312			{Guojia Biaozhun} {zh} }
	{ gb2312-raw	{Guojia Biaozhun} {zh} }
	{ iso2022		{ISO/IEC 2022} {zh} }
	{ iso2022-jp	{ISO/IEC 2022} {ja} }
	{ iso2022-kr	{ISO/IEC 2022} {ko} }
	{ iso8859-1		Latin-1 {af sq eu br ca da en fo gl de is ga it ku la ast lb no oc pt rm gd es sw sv wa} }
	{ iso8859-2		Latin-2 {bs hr cs hu pl ro sr sk sl wen} }
	{ iso8859-3		Latin-3 {eo mt tr} }
	{ iso8859-4		Latin-4 {et kl lv lt se} }
	{ iso8859-5		Latin/Cyrillic {be bg mk ru sr uk az} }
	{ iso8859-6		Latin/Arabic {ar} }
	{ iso8859-7		Latin/Greek {el} }
	{ iso8859-8		Latin/Hebrew {he} }
	{ iso8859-9		Latin-5 {tr} }
	{ iso8859-10	Latin-6 {iu se} }
	{ iso8859-11	Latin/Thai {th} }
	{ iso8859-12	Latin/Devanagari {hi} }
	{ iso8859-13	Latin-7 {bat} }
	{ iso8859-14	Latin-8 {br gd cy} }
	{ iso8859-15	Latin-9 {af sq br ca da nl en et fo fi fr gl de is ga it la lb ms no oc pt rm gd es sw sv tl wa} }
	{ iso8859-16	Latin-10 {sq hr fr de hu it pl ro sl ga} }
	{ jis0201		{Japan Industrial Standard} {ja} }
	{ jis0208		{Japan Industrial Standard} {ja} }
	{ jis0212		{Japan Industrial Standard} {ja} }
	{ koi8-r			{Kod Obmena Informatsiey} {ru} }
	{ koi8-u			{Kod Obmena Informatsiey} {be uk} }
	{ ksc5601		{Korean Standard} {ko} }
	{ macCentEuro	{Apple Macintosh - Latin & Euro} {af sq eu br ca da en fo gl de is it ku la ast lb no oc pt rm gd ga es sw sv wa} }
	{ macCroatian	{Apple Macintosh} {hr} }
	{ macCyrillic	{Apple Macintosh} {be bg mk ru sr} }
	{ macGreek		{Apple Macintosh} {el} }
	{ macIceland	{Apple Macintosh} {is} }
	{ macJapan		{Apple Macintosh} {ja} }
	{ macRoman		{Apple Macintosh - Latin} {af sq eu br ca da en fo gl de is it ku la ast lb no oc pt rm gd ga es sw sv wa} }
	{ macRomania	{Apple Macintosh} {ro} }
	{ macThai		{Apple Macintosh} {th} }
	{ macTurkish	{Apple Macintosh} {tr} }
	{ macUkraine	{Apple Macintosh} {uk} }
	{ shiftjis		{Japan Industrial Standard} {ja} }
	{ tis-620		{Thai Industrial Standard} {th} }
	{ utf-8			{Unicode Transformation Format} {} }
}

variable autoEncoding auto
variable defaultEncoding iso8859-1
variable windowsEncoding cp1252
variable macEncoding macRoman
variable systemEncoding [encoding system]

variable BorderWidth 1
variable List [lsort -dictionary [encoding names]]

array set Colors {
	selection	#ffdd76
	active		#ebf4f5
	normal		linen
	description	#efefef
}


proc build {path currentEncoding defaultEncoding {width 0} {height 0} {encodingList {}}} {
	variable List
	variable systemEncoding

	if {[llength $encodingList] == 0} { set encodingList $List }

	set f [ttk::frame $path -takefocus 0]
	set table $f.list.t
	ttk::frame $f.enc -takefocus 0
	ttk::frame $f.list -takefocus 0
	if {[llength $currentEncoding]} {
		set cur [ttk::button $f.enc.cur \
			-text "$mc::CurrentEncoding\n$currentEncoding" \
			-command [namespace code [list select $f $currentEncoding]] \
		]
		if {[lsearch $encodingList $currentEncoding] == -1} {
			$cur configure -state disabled
		}
	}
	set def [ttk::button $f.enc.def \
		-text "$mc::DefaultEncoding\n$defaultEncoding" \
			-command [namespace code [list select $f $defaultEncoding]] \
	]
	set sys [ttk::button $f.enc.sys \
		-text "$mc::SystemEncoding\n$systemEncoding" \
			-command [namespace code [list select $f $systemEncoding]] \
	]

	if {[llength $currentEncoding]} {
		grid $cur -row 1 -column 1 -sticky ew -ipady 2
		lappend cols 1
	}
	grid $def -row 1 -column 3 -sticky ew -ipady 2
	grid $sys -row 1 -column 5 -sticky ew -ipady 2
	lappend cols 3 5

	grid columnconfigure $f.enc $cols -weight 1

	namespace eval [namespace current]::${table} {}
	variable ${table}::Vars

	set Vars(active) 1
	set Vars(list) $encodingList
	set Vars(encodings) {}
	set Vars(pending-select) {}
	set Vars(pending-activate) {}

	ttk::scrollbar $f.list.sb -orient vertical -command [list $table yview]
	if {$height > 0} {
		BuildTable $table $width $height
	} else {
		bind $f.list <Configure> [namespace code [list ConfigureTable $table %w %h]]
	}
	bind $f.list.sb <ButtonPress-1> [list focus $f.list.t]
	bind $f.list.sb <Destroy> [list namespace delete [namespace current]::${table}]

	grid $f.enc  -row 1 -column 1 -sticky ew
	grid $f.list -row 3 -column 1 -sticky nsew

	grid columnconfigure $f {0 2} -minsize $::theme::padding
	grid columnconfigure $f 1 -weight 1
	grid rowconfigure $f 2 -minsize $::theme::pady
	grid rowconfigure $f {0 4} -minsize $::theme::padding
	grid rowconfigure $f 3 -weight 1

	return $path
}


proc choose {parent currentEnc defaultEnc {autoDetectFlag no}} {
	variable List
	variable defaultEncoding
	variable autoEncoding
	variable _Encoding

	set encodingList $List
	if {$autoDetectFlag} { set encodingList [linsert $encodingList 0 $autoEncoding] }
	set _Encoding $currentEnc
	set dlg $parent.chooseEncoding
	tk::toplevel $dlg -class Dialog
	if {[llength $defaultEnc] == 0} { set defaultEnc $defaultEncoding }
	build $dlg.enc $currentEnc $defaultEnc 600 400 $encodingList
	variable ${dlg}.enc.list.t::Vars
	bind $dlg.enc <<TreeControlSelect>> [namespace code [list TreeControlSelect $dlg %d]]
	pack $dlg.enc -fill both -expand yes
	::widget::dialogButtons $dlg {ok cancel} ok
	set cancel "
		set [namespace current]::_Encoding {}
		destroy $dlg"
	$dlg.ok configure -command [list destroy $dlg]
	$dlg.cancel configure -command $cancel
	wm protocol $dlg WM_DELETE_WINDOW $cancel
	bind $dlg <Escape> $cancel
	wm transient $dlg [winfo toplevel $parent]
	wm title $dlg "$mc::ChooseEncodingTitle"
	wm resizable $dlg true true
	wm minsize $dlg 600 400
	wm withdraw $dlg
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $dlg.enc.list.t
	ttk::grabWindow $dlg
	set encoding $currentEnc
	if {[lsearch $Vars(encodings) $encoding] == -1} { set encoding $defaultEnc }
	after idle [namespace code [list select $dlg.enc $encoding]]
	tkwait window $dlg
	ttk::releaseGrab $dlg
	return $_Encoding
}


proc activate {path encoding} {
	set table ${path}.list.t
	variable ${table}::Vars

	if {[winfo exists $table]} {
		set Vars(active) [expr {[lsearch -exact $Vars(encodings) $encoding] + 1}]
		if {[focus] eq $table} {
			$table activate $Vars(active)
		}
		if {[winfo viewable $table]} {
			$table see $Vars(active)
		} else {
			bind $table <Map> [namespace code [list See $table]]
		}
		set Vars(pending-activate) {}
	} else {
		set Vars(pending-activate) $encoding
	}
}


proc select {path encoding} {
	set table ${path}.list.t
	variable ${table}::Vars

	if {[winfo exists $table]} {
		set selection [expr {[lsearch -exact $Vars(encodings) $encoding] + 1}]
		if {$selection == 0} { return }
		if {[focus] eq $table} {
			$table activate $selection
		}
		$table selection clear
		$table selection add $selection
		if {[winfo viewable $table]} {
			$table see $selection
		} else {
			bind $table <Map> [namespace code [list See $table]]
		}
		set Vars(active) $selection
		set Vars(pending-select) {}
		set Vars(pending-activate) {}
	} else {
		set Vars(pending-select) $encoding
	}
}


proc languageName {lang} {
	variable Lang

	if {[info exists mc::Lang($lang)]} { return $mc::Lang($lang) }
	return $lang
}


proc See {table} {
	variable ${table}::Vars

	if {$Vars(active) >= 0} {
		$table see $Vars(active)
	}

	bind $table <Map> {}
}


proc BuildTable {table width height} {
	variable ${table}::Vars
	variable Colors
	variable BorderWidth
	variable Encodings
	variable autoEncoding

	treectrl $table \
		-takefocus 1 \
		-borderwidth $BorderWidth \
		-relief sunken \
		-showheader yes \
		-showbuttons no \
		-selectmode single \
		-showroot no \
		-showlines no \
		-showrootlines no \
		-columnresizemode realtime \
		-background white \
		-yscrollincrement 1 \
		-width [expr {$width - 2*$BorderWidth}] \
		-height [expr {$height - 2*$BorderWidth} \
	]

	set parent [winfo parent $table]
	set path [winfo parent $parent]

	grid $table -column 1 -row 1 -sticky nsew
	grid $parent.sb -column 2 -row 1 -sticky ns
	grid columnconfigure $parent 1 -weight 1
	grid rowconfigure $parent 1 -weight 1
	$table notify bind $parent.sb <Scroll-y> { %W set %l %u }

	$table element create elemTxt text
	$table element create elemSel rect -fill [list $Colors(selection) selected $Colors(active) active]
	$table element create elemBrd border -filled no -relief raised -thickness 1 \
		-background {#dbdbdb {active} {} {}}

	$table style create style1
	$table style elements style1 {elemSel elemBrd elemTxt}
	$table style layout style1 elemTxt -padx {2 2} -pady {1 1}
	$table style layout style1 elemSel -union elemTxt -iexpand nswe
	$table style layout style1 elemBrd -iexpand xy -detach yes

	$table style create style2
	$table style elements style2 {elemSel elemBrd elemTxt}
	$table style layout style2 elemTxt -padx {2 2} -pady {1 1} -squeeze x -sticky w
	$table style layout style2 elemSel -union elemTxt -iexpand nswe
	$table style layout style2 elemBrd -iexpand xy -detach yes

	$table style create style3
	$table style elements style3 {elemSel elemBrd elemTxt}
	$table style layout style3 elemTxt -padx {2 2} -pady {1 1} -squeeze x -sticky w
	$table style layout style3 elemSel -union elemTxt -iexpand nswe
	$table style layout style3 elemBrd -iexpand xy -detach yes

	foreach {id minwidth weight} {encoding {} 0 description 200 1 languages 200 4} {
		if {$id eq "description"} {
			set background $Colors(description)
		} else {
			set background $Colors(normal)
		}
		$table column create \
			-tag $id \
			-expand $weight \
			-text [set mc::[string toupper $id 0 0]] \
			-font TkTextFont \
			-justify left \
			-borderwidth 1 \
			-button no \
			-itemjustify left \
			-resize no \
			-steady yes \
			-squeeze $weight \
			-weight $weight \
			-itembackground [list $background white] \
			-minwidth $minwidth \
			;
		set trace "variable mc::$id write { [namespace current]::SetText $table $id }"
		trace add {*}$trace
		::bind $table <Destroy> +[list trace remove {*}$trace]
	}

	set row 1
	foreach enc $Vars(list) {
		set id ""
		if {$enc eq $autoEncoding} {
			set id $autoEncoding
			set descr $mc::UseAutoDetection
			set isocodes {}
		} else {
			set index [lsearch -index 0 -exact $Encodings $enc]
			if {$index >= 0} {
				lassign [lindex $Encodings $index] id descr isocodes
			}
		}
		if {[string length $id]} {
			lappend Vars(encodings) $id
			set langs {}
			foreach code $isocodes {
				if {[string match f-* $code]} {
					lappend langs $mc::Font([string range $code 2 end])
				} else {
					lappend langs $mc::Lang($code)
				}
			}
			set langs [lsort -dictionary $langs]
			set item [$table item create -tag r$row]
			$table item style set $item encoding style1 description style2 languages style3
			$table item lastchild root $item
			$table item element configure $row encoding elemTxt -text $id
			$table item element configure $row description elemTxt -text $descr
			$table item element configure $row languages elemTxt -text [join $langs ", "]
			incr row
		}
	}

	set last [expr {[llength $Vars(encodings)] - 1}]

	bind $table <ButtonPress-1>	[namespace code [list Highlight $table %x %y]]
	bind $table <ButtonRelease-1>	{ break }
	bind $table <Double-1>			[namespace code [list SendSelection $path close %x %y]]
	bind $table <FocusIn>			[namespace code [list FocusIn $table]]
	bind $table <FocusOut>			[namespace code [list FocusOut $table]]
	bind $table <Home>				[namespace code [list Activate $table 0]]
	bind $table <End>					[namespace code [list Activate $table $last]]
	bind $table <Up>					[namespace code [list Activate $table up]]
	bind $table <Down>				[namespace code [list Activate $table down]]
	bind $table <Up>					{+ break }
	bind $table <Down>				{+ break }
	bind $table <Key-space>			[namespace code [list Select $table]]

	$table notify bind $table <ActiveItem> [namespace code [list SetActive $table %c]]
	$table notify bind $table <Selection>  [namespace code [list SendSelection $path %S]]

	$table selection clear

	if {[llength $Vars(pending-select)]} {
		select $path $Vars(pending-select)
	} elseif {[llength $Vars(pending-activate)]} {
		activate $path $Vars(pending-activate)
	}
}


proc TreeControlSelect {w data} {
	variable _Encoding

	if {[llength $data] == 0} {
		destroy $w
	} else {
		set _Encoding $data
	}
}


proc ConfigureTable {table width height} {
	if {$height <= 1} { return }
	BuildTable $table $width $height
	bind [winfo parent $table] <Configure> {}
}


proc Highlight {table x y} {
	variable ${table}::Vars

	focus $table
	set id [$table identify $x $y]
	if {[lindex $id 0] ne "item"} { return }
	set row [$table item order [lindex $id 1] -visible]

	if {0 <= $row && $row < [llength $Vars(encodings)]} {
		incr row
		$table selection clear
		$table selection add $row
		$table activate $row
		set Vars(active) $row
	}
}


proc Activate {table action} {
	variable ${table}::Vars

	switch -- $action {
		up			{ set row [expr {$Vars(active) - 1}] }
		down		{ set row [expr {$Vars(active) + 1}] }
		default	{ set row [expr {$action + 1}] }
	}

	if {0 < $row && $row <= [llength $Vars(encodings)]} {
		$table activate $row
		$table see $row
		set Vars(active) $row
	}
}


proc SetActive {table item} {
	variable ${table}::Vars
	if {$item != 0} { set Vars(active) $item }
}


proc Select {table} {
	variable ${table}::Vars

	$table selection clear
	$table selection add $Vars(active)
}


proc SendSelection {path item args} {
	set table ${path}.list.t
	variable ${table}::Vars

	 if {[llength $args] && [lindex [$table identify {*}$args] 0] eq "header"} {
		 return
	 }

	if {[llength $item]} {
		if {$item eq "close"} {
			set item ""
		} else {
			set item [lindex $Vars(encodings) [expr {$item - 1}]]
		}
		event generate $path <<TreeControlSelect>> -data $item
	}
}


proc FocusIn {table} {
	variable ${table}::Vars
	$table activate $Vars(active)
}


proc FocusOut {table} {
	$table activate root
}


proc SetText {table id args} {
	$table.t column configure $id -text [set mc::$id]
}

} ;# namespace encoding

# vi:set ts=3 sw=3:
