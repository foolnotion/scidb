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
# Copyright: (C) 2010-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source time-mode-selection-box

proc timemodebox {w args} {
	return [::timemodebox::Build $w {*}$args]
}


namespace eval timemodebox {
namespace eval mc {

set Mode(normal)	"Normal"
set Mode(rapid)	"Rapid"
set Mode(blitz)	"Blitz"
set Mode(bullet)	"Bullet"
set Mode(corr)		"Correspondence"

} ;# namespace mc


namespace import ::tcl::mathfunc::max

variable modes {normal rapid blitz bullet corr}


proc minWidth {} {
	variable modes

	set len 0
	foreach mode $modes {
		set len [max $len [string length $mc::Mode($mode)]]
	}

	return [expr {$len + 3}]
}


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Content

	array set opts {
		-textvar			{}
		-textvariable	{}
		-width			0
		-state			normal
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Content
	}

	ttk::frame $w -borderwidth 0 -takefocus 0
	bind $w <FocusIn> { focus [tk_focusNext %W] }
	set width [expr {max([minWidth], $opts(-width))}]
	ttk::tcombobox $w.__w__ \
		-textvariable $opts(-textvariable) \
		-exportselection no \
		-column mode \
		-state $opts(-state) \
		-width $width \
		-placeicon yes \
		;
	$w.__w__ addcol image -id icon -justify center
	$w.__w__ addcol text -id mode
	pack $w.__w__ -anchor w

	Setup $w

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.__w__ <Any-Key> [namespace code [list Completion $w %A %K $opts(-textvariable)]]
	bind $w.__w__ <<LanguageChanged>> [namespace code [list LanguageChanged $w]]
	bind $w.__w__ <<ComboboxSelected>> [namespace code [list CheckEntry $w]]

	$w.__w__ current 0

	catch { rename ::$w $w.__timemodebox__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		cget {
			if {[lindex $args 0] eq "-takefocus"} {
				return 0
			}
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			bind $w.__w__ {*}$args
			return
		}

		valid? {
			set value [$w.__w__ get]
			set index [lsearch -exact [$w.__w__ cget -values] $value]
			if {$index >= 0} { return true }
			if {$value eq "-" || $value eq "\u2014" || $value eq ""} { return true }
			return false
		}

		value {
			variable modes
			set item [$w.__w__ current]
			if {$item <= 0} { return "" }
			return [lindex $modes [expr {$item - 1}]]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set value [lindex $args 0]
			if {[info exists mc::Mode($value)]} {
				$w.__w__ current search mode $mc::Mode($value)
			} else {
				$w.__w__ current 0
			}
			CheckEntry $w
			$w placeicon
			return $w
		}

		focus {
			return [focus $w.__w__]
		}

		path {
			return $w.__w__
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


proc LanguageChanged {w} {
	$w.__w__ forgeticon
	set current [$w.__w__ current]
	Setup $w
	if {$current >= 0} {
		$w.__w__ current $current
	}
}


proc Setup {w} {
	variable modes

	set current [$w.__w__ current]
	$w.__w__ listinsert [list "" "\u2014"] -index 0
	set index 0
	foreach mode $modes {
		$w.__w__ listinsert [list $icon::12x12::Mode($mode) $mc::Mode($mode)] -index [incr index]
	}
	$w.__w__ resize
	$w.__w__ mapping [::mc::mappingForSort] [::mc::mappingToAscii]

	if {$current >= 0} {
		$w.__w__ current $current
		CheckEntry $w
	}
}


proc Completion {w code sym var} {
	if {[$w popdown?]} { return }

	switch -- $sym {
		Tab {
			set $var [string trimleft [set $var]]
			Search $w $var 1
			if {[$w testicon]} {
				$w placeicon
			} else {
				$w select none
			}
		}

		default {
			if {[string is alnum -strict $code] || $code in {" " "?" "*"}} {
				after idle [namespace code [list Completion2 $w $var [set $var]]]
			} elseif {$sym ne "Down"} {
				after idle [list $w testentry]
			}
		}
	}
}


proc Completion2 {w var prevContent} {
	variable modes

	set content [string trimleft [set $var]]
	set len [string length $content]

	if {$len == 0} {
		$w.__w__ current 0
		CheckEntry $w
	} elseif {$len == 1 && [string is digit -strict $content]} {
		if {$content <= [llength $modes]} {
			$w.__w__ current $content
			$w.__w__ icursor end
			$w.__w__ selection clear
			$w.__w__ selection range 0 end
			CheckEntry $w
		} else {
			$w.__w__ set ""
			bell
		}
	} elseif {$content in {" " "?" "*"}} {
		$w.__w__ set ""
		$w forgeticon
	} elseif {[string equal -nocase -length [expr {$len - 1}] $content $prevContent]} {
		$w testicon
		Search $w $var 0
	}
}


proc Search {w var full} {
	set content [set $var]
	if {[string length $content] == 0} { return }

	if {$full} {
		$w.__w__ current search -nocase mode $content
	} else {
		$w.__w__ current match -nocase mode $content
		set newContent [$w get]
		
		if {$content ne $newContent} {
			set k 0
			set j 0
			set n [string length $content]
			while {$j < $n} {
				set c [string index $newContent $k]

				if {[string equal -nocase $c [string index $content $j]]} {
					incr j
				} else {
					incr j [string length [::mc::mapForSort $c]]
				}

				incr k
			}

			$w.__w__ icursor $k
			$w.__w__ selection clear
			$w.__w__ selection range $k end
			CheckEntry $w
		}
	}
}


proc CheckEntry {w} {
	if {[$w get] eq "\u2014"} {
		$w.__w__ set ""
	}
}


namespace eval icon {
namespace eval 12x12 {

# set Mode(normal) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAAA/FBMVEWMjIyIiIiIiIiJiYmL
# 	i4uLioqLi4qamZmampmkoqClo6CamZiampixram0r6qyrqmzrqozg80zhc8zhtA0hs80htA1
# 	hM43iNA5itI8jdU/jtQ/kNdAkddDkdZDktZEktZEltxFkdVFk9dGj9NGltpHkdRHktZIlthI
# 	md1JlthJmNtJmdtKmNlLktVOnN5QmdlUnNpip+JmrOZoreZ1r+F3tOaMv+qex+ueyOufyu2i
# 	yvCiy/CkyuqkzfKlzvKx2Pmz2vm82fS/2vHD3/jF4fnH4/vJ4PLJ5PvW6PfX6PfZ1tTZ5fDa
# 	19Ta19Xb6/jc6PHe6fPg6/Tn5+ft9PtrDfKBAAAAEXRSTlMAISJAi42N39/j4+bm9fX5+SCc
# 	mvgAAACUSURBVAgdBcHNDsFAEADgmZ3tCpqGHiQNV1cPQcQzi/RZSKQJB0pb/duZHd+HAEiR
# 	BfaigED2MGlDPOQsaKand22Qk/TcUbT/lv18eQ+6vRlyFZOi5cqRcY2Xj0a9+sZZ1Dpkm1J+
# 	VtEO8aJLnwWOaTxYluRxfVHARJig2Lmmo2y9ykcEio6hhZm5eEEAJGeBR1H4A3zkRtpa3SKL
# 	AAAAAElFTkSuQmCC
# }]

# set Mode(normal) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QAlgCWAJZH95v8AAAC
# 	EElEQVQozx2QPWgaYRjH3y6dGjLF1LUQ6GxDhZAlm4voYoYiaJP4BUGqy2EzxIIoClIQcVa4
# 	oSVD1IhR26h33uU0xlI9cmnV2PrRaEjSYkzXe/K+eeAHf57n/3zwII/Hg8xmM1Kr1c/cbvdK
# 	IpGgaJr+SIjH45TL5VohNZPJhIgXORwOpNVqF0Kh0AaDo9VqzURRlAlEl8slJhgMbhCPzWZD
# 	SKVSzQUCgU2e56XqyYnMn55CieNAareh0WxCDedYlpF8Pt/m8vKrObJhNZfLVZgKCww2/xiN
# 	IBaLwejqCsa3t1AXRSizDKTT6YrFYllFkUhkh2HKs1ypCPVOB6ThEIxGIzSx7k4mIPb7cMSy
# 	UCjkZ/i0HRQOh6P5fF7+KgjQ6PXgGz5Fp9MBh7eJ3S6IFxfA1GpwcJCW/X5/FOH7Y9lsVi5W
# 	a3B+eflopigKNBoNGAwGcDqdkMpkIJlMyl6vN4a83g+7h4eF+y8MB2eDAfy5vn5s+oknD8dj
# 	6OMh3HEVUqnMvcfzfhfp9fo1mv4kHBV5+C61YfL3H9zcTTF3cDOdQrfXh2LxGOJxWsCvXUMK
# 	xcK81WrfTibzHUEQ5TOpB78HePJgAtL5L6hWRXl/P9fZ2rJvLy4q5hGOJ0ql8sX6+hsqkdhr
# 	8Jz4v17vyASiSY7UiId4ScNTzHPM66Wll29NJmvUbn/3mUA0yZEaRkm8D5KcZBglFA+gAAAA
# 	AElFTkSuQmCC
# }]

set Mode(normal) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAACEElEQVQoz2NgQAKmRkbMGmpq
	AirKyuLaGhriJgYGAjYWFswM2ICXl5dAcWmp2/pNm7qOnjixZuf+/StmL17cklNQ4Orr4yOA
	otjd3V2gu7cn7dDpSxc3H372LaXtzf8HLz/8u/n40adthw+fqqitTfDy9IRo0lJXZ8ktyPfY
	d/z8penrHv2fuPLVf/fMs//vPn3///XHj/+vP3nyb8uBA6cysrPd9bS1WRhkJCUFl65a2btw
	85VvTXNu/1+57+V/0/Dd/8/cevz/zovn/68+fvz/xPXrn6fMnt2uqqQkxCAqLCy1dffuDfXT
	z/6ftvb+/1V7n/3X9Fr7/+CZG/8v3bn3/8Lte/9P3brzf8WGDWulJSSkGPh5eaW27Ny5sXHG
	2f+Ltj7/b+We/7+8vBxMuwYU/veLrPwfntgI0rBOVEhImoGLg0N4/qJFExdvufy9e+H9/xsO
	vgErXr37yf/1+18CDXn0f9uRy18mT5/eIyggIAyygSUyOspv75HT1xZvffZ/xtpX/1fve/d/
	3YF3/1fsevt/14kX/7btPXg+IjLCV0BAgAUcUqoqKsKFhQX5h46dubHv5PMfmw59BJr6/t/h
	M4+/7t53+GJqWmqWmpqaMHJUsLGzs2lYWJind3R2Llq4ePHeufPm766prZ1ramqaxs7OrglS
	g6yBE4glgVgZiPVAqQSKQWwVIJaCqmEAAPkjA4/G/tA1AAAAAElFTkSuQmCC
}]

# set Mode(rapid) [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAABlElEQVQoz2NgwAQsbGxsGfb2
# 	Dt8Cg4J+ysjILmZgYGBjwANkNLV0z+47dOr/sVOX//sHRvxnYGBQgZuGRQObgKAo87efzAyf
# 	v/1g+PXnPwMDAwMPTJIZi4aPTx7f1/r5+7vx48d33x3ev3P358+fJuBzkoGxsfFmCwuLzwwM
# 	DOsZGBjKGRgYonA5iVNUVDQiv6DQXUVFhenAwUM23FxcDosXLbhz5syZIwwMDI+Y0DSIWFha
# 	GyqrqLMKCoszGxgYi/DxCwswMrH8YWBgEMNmA+uvX7+5fv78x/D2zQeGBfMXMGzdsuHO16+f
# 	KxkYGK4wMDAwoNjAycnpKy0jp8fLL8jAJyDEkJSSyeDt4y/EwMAgycDA8ANZbbCcnNL13ILK
# 	/7sOnv5f09D6R1xc8kZ9c8/PTduP/zcytrzLwMBggxysxq4eASFunn6cO3ds+rJiyfwVL54/
# 	q3xw/44kOzuXyssXzxifPH5wgoGB4RLMBjEpGfmDGpq690TFxAugHmRkYGAwEBOXXMnGxh7M
# 	wMAgwMDAwAAA2k9/Hff2g9AAAAAASUVORK5CYII=
# }]

set Mode(rapid) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH2wYOCQYLFeuBXgAAAa1JREFUKM91kE1IFHEY
	h593PnaY3WY3VsLYNZAKAjEELx6CjECC0ItdunReJDp08xR0SSqJ9lQRERJBB41ufUALWZRk
	ZJLCEsrQh6LVUn9xt3HcmX8HV9iKfufn+fH+XmiKiKCUYuBYZ//D8ZPTty/smmlvlRP8L7nW
	JLZt75y4tq/0w2/TlbKliwWZMgxa0sktxmgWatWAOI6sxSnfC1aWqKuIRIznWFgpZ4sxm4Ug
	1Gitg4VlvLUPHPTf6ZWxSa5+qvC8uoH+RzhTOEo6s2fvyHB0+tnLter1EkX1iyCKwTZZrcd/
	bVBKUTzfPfyt7MZf37A5N87q/AQbvR1cBuSPDSJCJpNxso7faZuhoDGXFki9eMTMlwrl7Wus
	bcE0NPWI7Prnn216UyOCvH7L95EHjNZC7gNxAwSBZCrBoeNd3J0eI5i9R/3pFdb9J+ibBeY8
	l8NKNZrTLpgGfUN9fHx8CX1jiLCrnTuey6mz/cy/uoUe6KYE7LZM4EAORMj3djA52MNyi8dF
	IA+YboLBnv3M5rOcAzI0llvADhGOAI7WvAfCxkMsIAcsAhWg9hsaS50j/4yYmwAAAABJRU5E
	rkJggg==
}]

set Mode(blitz) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABI1BMVEUAAAAAAAMEAwMEBQgT
	ExMYGhAhL28mJiYxKxI3LxZiSxuKayKikjvcljjdmDTdnTH//yL//94AAAAEBgkAAAAAAAAA
	AAAIDQsAAAAMCwgAAAAbFw4AAAAAAAA1KBw4MhIGBANAOx0KCAVANxEgFg4PDAZKMBovLRQx
	JxErHwwiGAwnHQ4pIA1jRBtmWRguIg9IPBlbPxdaQBVlSh8vIg5xYB0vHxBTOheMdyhjSBuW
	gR5+TiCpgi2MYSSpbzCWaya3mSrCpSWmcCiIbiOchCmvfCmwbyusZyy9gi2+jy/btC3XijG6
	gi3VljLfmzHhpDHkjDXlsDLorDbsnjLtnjTupzfuuzXwszDzrzbzsC/z0Cv1yDX2wiv2xi34
	yzP40in////fwhI+AAAATHRSTlMAAAAAAAAAAAAAAAAAAAAAAAABAgMLDA8QFBgaHiQ0NkJD
	REVHUFNaZmtsbW15ent7fH9/g4ybqK+2wM3Y2trk5e7w8fHx8fT2+/z+s6hhmQAAAAFiS0dE
	YMW3fBAAAACASURBVAgdJcHrCoJAEAbQb2QsZbu4A1IGvf9b9bvU0h2vhaxpnUP4CyWbbowV
	2X1mHyFjEdlUpBlCBgI5nhLzVKeMWC67jBtqHTFYzobIeLN5ByCeffDRetxODN+Ppu9c2dzB
	iU2TVvU1lAAfrqKuaHMsOIqLSocaK/ZV3pUzfr6lhTQTYwNLxAAAAABJRU5ErkJggg==
}]

set Mode(bullet) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABUFBMVEUAAAAnIyQ6OjpGRkZI
	SEhWVlZoaGiioaH///8dHR0iIiI4ODheXl5wcHB8fHyYmJgaGhoeHh4vLy9ZWVktLS06OjpO
	Tk5aWlo9PT03Nzc7Ozo4ODg3NzcjIyMqKipHR0csLCwwMDBGRkYsLCw/QEAsLCw+Pj4sLCwz
	MzMuLi4wMDAsKysvLy8tLS0uLi4vLy8wMDAxMTGCgoIaGhpCQkIcHBxRUlIkJCQRERFMTEwQ
	EBBdXV0YGBgeHh4eHh5ZWVkZGRliYmJ7e3sNDQ0UFBQVFRUWFhYaGhobGxsbGxwdHR0eHh4f
	Hx8gICAhISIiIiIkJCQsLCw2Nzc8PTxGRkZLS0tNTU1PT09RUVFUVVVVVVZVVldZWlpeX2Bi
	Y2Nubm5vb293d3d5eXl9fX19fX6Cg4OLjIyLjY2Qk5OSkpSTk5akpqamqamxsrPP0NH///9e
	4W3tAAAAQ3RSTlMAAAAAAAAAAAABAQEBAQEBAgICAgMDAwMLDC81d3x8fH19fX9/gJ+goKKi
	pKWnp6msrd/g4+fn6vT09/j8/P39/v7+RANJ7wAAAAFiS0dEb1UIYYEAAACCSURBVAgdTcE9
	EoIwEAbQ/TabhL8RZ8BRCy3sbLz/NTyBlX1ggBCExJb3iHZApBFttAhFBDeaK2Esy8HJOW/L
	Oxif7fEWc311EzG10Vs5PTFMVelnViL4Sn3xtRqwJqUs37TZnKc0q2I0TXTd9FuLHqrROQt4
	CccRRJQFk6WUypX2/ozULS3iF7o0AAAAAElFTkSuQmCC
}]

set Mode(corr) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAJCAYAAAAGuM1UAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAABeklEQVQY023QsU8TURzA8e/v9bhWuMPKNaaNxoGQ1KFo
	aEiJScsoMTFOOjiwyOqfZOLiYlwYoIEmLBgWpMGAWCIXhoZYaS8sgrx77b1z0MXE7/yZvvL4
	1ZvFrOtslm5P5qxN+V8W6Ec/tRmOlhwnI62H94vu8rMq0/cCtLEgf2UKOVfRPu7zobmf/Xry
	vaVuek525XlN3m8ccBSec20V/UvL4DLh2iqOwnNa21948XRevBtjWRXHmsKUR6NeYXXrkDDs
	cssbI++5hGGX1a1DGvUKhcDDGI1jTMwwsUzkfaoLFTZ2DtjbPwEg+pUwv/CA8fwkw5EljjUq
	1hqL0DntsdvuMDNbpnsldK+Emdkyn9odjk97WARjNGpoYqLBBc21j0xMBbi+T60xR60xh+v7
	jAcB62vbRIMLjImR6fpr/ahadpdfPpHS3SJJkvxzSWUy9M5+8PZdM937/M1Isbqy6GTU5p1S
	IWdtipCSyh8sCCmglHDWi/QosUu/AcpVoLcZHweRAAAAAElFTkSuQmCC
}]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace timemodebox

# vi:set ts=3 sw=3:
