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
# Copyright: (C) 2010-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source title-selection-box

proc titlebox {w args} {
	return [::titlebox::Build $w {*}$args]
}


namespace eval titlebox {
namespace eval mc {

set Title(GM)		"Grandmaster (FIDE)"
set Title(IM)		"International Master (FIDE)"
set Title(FM)		"Fide Master (FIDE)"
set Title(CM)		"Candidate Master (FIDE)"
set Title(WGM)		"Woman Grandmaster (FIDE)"
set Title(WIM)		"Woman International Master (FIDE)"
set Title(WFM)		"Woman Fide Master (FIDE)"
set Title(WCM)		"Woman Candidate Master (FIDE)"
set Title(HGM)		"Honorary Grandmaster (FIDE)"
set Title(NM)		"National Master (USCF)"
set Title(SM)		"Senior Master (USCF)"
set Title(LM)		"Life Master (USCF)"
set Title(CGM)		"Correspondence Grandmaster (ICCF)"
set Title(CIM)		"Correspondence International Master (ICCF)"
set Title(CLGM)	"Correspondence Lady Grandmaster (ICCF)"
set Title(CILM)	"Correspondence Lady International Master (ICCF)"
set Title(CSIM)	"Correspondence Senior International Master (ICCF)"

}


variable titles { GM IM FM CM WGM WIM WFM WCM HGM CGM CLGM CIM CILM CSIM NM SM LM }

array set Association {
	GM		FIDE
	IM		FIDE
	FM		FIDE
	CM		FIDE
	WGM	FIDE
	WIM	FIDE
	WFM	FIDE
	WCM	FIDE
	HGM	FIDE
	CGM	ICCF
	CLGM	ICCF
	CIM	ICCF
	CILM	ICCF
	CSIM	ICCF
	NM		USCF
	SM		USCF
	LM		USCF
}


proc Build {w args} {
	variable titles

	namespace eval [namespace current]::${w} {}
	variable ${w}::Content ""

	array set opts {
		-height			15
		-width			48
		-textvar 		{}
		-textvariable	{}
		-state			normal
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	set vcmd { return [string is alpha [string trim [string range %P 0 2]]] }

	ttk::tcombobox $w \
		-height [expr {[llength $titles] + 1}] \
		-showcolumns {title descr} \
		-format "%1 \u2013 %2" \
		-empty {0} \
		-width $opts(-width) \
		-textvariable $opts(-textvariable) \
		-scrollcolumn title \
		-validate key \
		-validatecommand $vcmd \
		-invalidcommand { bell } \
		-exportselection no \
		-state $opts(-state) \
		-highlightbackground whitesmoke \
		-highlightforeground black \
		;

	$w addcol text  -id title -width 4
	$w addcol text  -id descr -foreground darkgreen

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
#	bind $w <FocusOut> [namespace code [list Completion $w]]
	bind $w <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w <<LanguageChanged>> [namespace code [list LanguageChanged $w]]

	SetupList $w

	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			return [bind $w {*}$args]
		}

		value {
			variable titles
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			return [lindex $titles [expr {$item - 1}]]
		}

		valid? {
			set value [$w.__w__ get]
			set index [lsearch -exact [$w.__w__ cget -values] $value]
			if {$index >= 0} { return true }
			if {$value eq "-" || $value eq "\u2014" || $value eq ""} { return true }
			return false
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set value [lindex $args 0]
			if {[info exists mc::Title($value)]} {
				$w.__w__ current search descr $mc::Title($value)
			} else {
				$w.__w__ current 0
			}
			return $w
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.__w__ instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}
	}

	return [$w.__w__ $command {*}$args]
}


proc SetupList {w} {
	variable mc::Title
	variable titles
	variable Association

	$w listinsert { "\u2014" } -index 0

	set index 0
	foreach title $titles {
		switch $Association($title) {
			ICCF		{ set highlight yes }
			default	{ set highlight no  }
		}
		$w listinsert [list $title $Title($title)] -index [incr index] -highlight $highlight
	}

	$w resize
	$w current 0
}


proc LanguageChanged {w} {
	set content [$w get]
	set title [lindex $content 0]
	SetupList $w
	$w current search title $title
	if {[string length $content] && [string length [$w get]] == 0} {
		$w set $content
	}
	$w icursor end
}


proc Completion {w code sym var} {
	if {[$w popdown?]} { return }

	switch -- $sym {
		Tab {
			set $var [string trimleft [set $var]]
			Search $w $var 1
		}

		default {
			if {[string is alpha -strict $code] || $code eq " "} {
				after idle [namespace code [list Completion2 $w $var [set $var]]]
			}
		}
	}
}


proc Completion2 {w var prevContent} {
	variable reasons

	set content [string trimleft [set $var]]
	set len [string length $content]

	if {$len == 0} {
		$w.__w__ current 0
	} elseif {[string equal -nocase -length [expr {$len - 1}] $content $prevContent]} {
		Search $w $var 0
	}
}


proc Search {w var full} {
	variable titles

	set title [lindex [string toupper [set $var]] 0]
	set n [lsearch -exact $titles $title]
	if {$n >= 0} {
		$w current [incr n]
		if {!$full} {
			$w selection clear
			$w selection range [string length $title] end
		}
	}
}

} ;# namespace titlebox

# vi:set ts=3 sw=3:
