# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

source /home/gregor/development/c++/scidb/tcl/contrib/treectrl.tcl
source /home/gregor/development/c++/scidb/tcl/contrib/filelist-bindings.tcl
source /home/gregor/development/c++/scidb/tcl/widgets/theme.tcl
source /home/gregor/development/c++/scidb/tcl/widgets/tooltip.tcl
source /home/gregor/development/c++/scidb/tcl/widgets/toolbar.tcl
source /home/gregor/development/c++/scidb/tcl/widgets/choosedir.tcl
source /home/gregor/development/c++/scidb/tcl/widgets/tlistbox.tcl
source /home/gregor/development/c++/scidb/tcl/widgets/tcombobox.tcl
theme::setTheme default

package require Tk 8.5
package require tktreectrl 2.2
package require tooltip
package require toolbar
package require choosedir
package require tcombobox
if {[catch { package require tkpng }]} { package require Img }
package provide fxbox 1.0


proc fsbox {w args} { return [fsbox::fsbox $w {*}$args] }


namespace eval fsbox {
namespace eval mc {

set Name					"Name"
set Size					"Size"
set Modified			"Modified"

set Forward				"Forward"
set Backward			"Backward"
set Delete				"Delete"
set Rename				"Rename"
set NewFolder			"New Folder"
set ListLayout			"List Layout"
set DetailedLayout	"Detailed Layout"
set ShowHiddenDirs	"Show Hidden Directories"
set ShowHiddenFiles	"Show Hidden Files and Directories"
set Cancel				"Cancel"
set Save					"Save"

set AddBookmark		"Add Bookmark '%s'"
set RemoveBookmark	"Remove Bookmark '%s'"

set Filename			"File &name:"
set FilesType			"Files of &type:"
set FileEncoding		"File &encoding:"

set Favorites			"Favorites"
set LastVisited		"Last Visited"
set FileSystem			"File System"
set Desktop				"Desktop"
set Home					"Home"

set SelectWhichType	"Select which type of file are shown"

}

namespace import ::tcl::mathfunc::max

array set Options {
	show:hidden		0
	show:details	1
	show:list		0
}


proc fsbox {w args} {
	variable Vars
	variable Options

	array set opts {
		-font							TkTextFont
		-background					white
		-foreground					black
		-selectionbackground		#ebf4f5
		-selectionforeground		black
		-inactivebackground		#f2f2f2
		-inactiveforeground		black
		-activebackground			#f0f9fa
		-activeforeground			black
		-borderwidth				1
		-relief						sunken
		-doublebuffer				window
		-initialdir					{}
		-showhidden					{}
		-timeformat					"%d/%m/%y %I:%M %p"
		-defaultextension			.sci
		-filetypes					{}
		-fileicons					{}
		-sizecommand				{}
		-selectencodingcommand	{}
		-fileencodings				{}
	}

	array set opts $args

	foreach option {	selectionbackground selectionforeground font timeformat
							activebackground activeforeground defaultextension
							inactivebackground inactiveforeground filetypes fileencodings
							fileicons showhidden sizecommand selectencodingcommand} {
		set Vars($option) $opts(-$option)
		array unset opts -$option
	}

	if {[llength $Vars(showhidden)]} {
		set Options(show:hidden) $Vars(showhidden)
	}

	if {[llength $Vars(filetypes)] && [string length $Vars(defaultextension)] == 0} {
		set Vars(defaultextension) [lindex $Vars(filetypes) 0 1 0]
	}

	set Vars(extensions) [lindex $Vars(filetypes) 0 1]

	set Vars(dir) $opts(-initialdir)
	array unset opts -initialdir
	if {[string length $Vars(dir)] == 0} {
		set Vars(dir) [pwd]
	}

	set fileicons {}
	set nameList {}
	foreach {extensions name} $Vars(fileicons) {
		foreach ext $extensions {
			if {$ext ni $fileicons} {
				lappend fileicons $ext
				set Vars(fti:$ext) $name
				if {$name ni $nameList} {
					lappend nameList $name
				}
			}
		}
	}

	set filetypeCount 0
	set secondFiletypeCount 0
	foreach entry $Vars(filetypes) {
		lassign $entry name extensions
		set iconList {}
		foreach ext $extensions {
			if {$ext in $fileicons} {
				if {$Vars(fti:$ext) ni $iconList} {
					lappend iconList $Vars(fti:$ext)
				}
			}
		}
		set filetypeCount [max $filetypeCount [llength $iconList]]
	}

	tk::frame $w -takefocus 0
	set top [ttk::frame $w.top -takefocus 0]
	pack $top -fill both -expand yes
	choosedir $top.dir -initialdir $Vars(dir) -showlabel 1

	tk::panedwindow $top.main \
		-sashwidth 7 \
		-background [ttk::style lookup $::ttk::currentTheme -background] \
		;

	bookmarks::Build $top.main.fav {*}[array get opts]
	filelist::Build $top.main.list {*}[array get opts]

	$top.main add $top.main.fav  -minsize 0 -sticky nsew -stretch last
	$top.main add $top.main.list -minsize 300 -sticky nsew -stretch always

	::tk::AmpWidget ttk::label $top.lbl_filename -text [Tr Filename]
	set Vars(widget:filename) [ttk::entry $top.ent_filename -cursor xterm]
	bind $top.lbl_filename <<AltUnderlined>> [list focus $top.ent_filename]

	if {[llength $Vars(selectencodingcommand)]} {
		::tk::AmpWidget ttk::label $top.lbl_encoding -text [Tr FileEncoding]
		set Vars(widget:encoding) [ttk::entry $top.ent_encoding \
			-state readonly \
			-textvar [namespace current]::Vars(encodingVar) \
			-width 14 \
			-foreground #808080 \
		]
		bind $top.ent_encoding <ButtonPress-1> [namespace code [list SelectEncoding $w]]
	}

	if {[llength $Vars(filetypes)]} {
		::tk::AmpWidget ttk::label $top.lbl_filetype -text [Tr FilesType]
		ttk::tcombobox $top.ent_filetype                       \
			-state readonly                                   \
			-textvariable $Vars(filetypes)                    \
			-format "%1 (%2)"                                 \
			-showcolumns [list 0 [expr {$filetypeCount + 1}]] \
			-padding 1                                        \
			;
		bind $top.ent_filetype <<ComboboxSelected>> [namespace code [list SelectFileTypes $w %W]]
		bind $top.lbl_filetype <<AltUnderlined>> [list focus $top.ent_filetype]
		tooltip $top.lbl_filetype [Tr SelectWhichType]
		set Vars(widget:filetypes:combobox) $top.ent_filetype

		tk::canvas $top.cnv_filetype -width 1 -height 1 -relief sunken -borderwidth 1 -takefocus 0
		bind $top.cnv_filetype <Configure> [namespace code SetFileTypes]
		set Vars(widget:filetypes:canvas) $top.cnv_filetype
	}

	grid columnconfigure $top {3} -weight 1
	grid columnconfigure $top {0 2 8} -minsize 5
	grid rowconfigure $top {3} -weight 1
	grid rowconfigure $top {0 2 4 6} -minsize 5

	grid $top.dir  			-row 1 -column 1 -sticky ew -columnspan 7
	grid $top.main				-row 3 -column 1 -sticky nsew -columnspan 7
	grid $top.lbl_filename	-row 5 -column 1 -sticky w
	grid $top.ent_filename	-row 5 -column 3 -sticky ew
	if {[llength $Vars(selectencodingcommand)]} {
		grid $top.lbl_encoding -row 5 -column 5
		grid $top.ent_encoding -row 5 -column 7
		grid columnconfigure $top {6} -minsize 5
		grid columnconfigure $top {4} -minsize 10
	}
	if {[llength $Vars(filetypes)]} {
		grid $top.lbl_filetype	-row 7 -column 1 -sticky w
		grid $top.ent_filetype	-row 7 -column 3 -sticky ew -columnspan 5
		grid $top.cnv_filetype -row 7 -column 7 -sticky nsew
		grid columnconfigure $top {6} -minsize 5
		grid rowconfigure $top {8} -minsize 5
		grid configure $top.ent_filetype -columnspan 3
	} else {
		grid rowconfigure $top {4} -minsize 10
	}

	bind $top.main <<ThemeChanged>> [namespace code [list ThemeChanged $top.main]]

	set buttons [tk::frame $w.buttons -takefocus 0]
	pack [ttk::separator $w.sep] -fill x
	pack $buttons -fill x
	ttk::style configure fsbox.TButton -anchor w
	set Vars(button:cancel) [tk::AmpWidget ttk::button $buttons.cancel  \
		-class TButton \
		-default normal \
		-compound left \
		-image $icon::16x16::iconCancel \
	]
	set Vars(button:ok) [tk::AmpWidget ttk::button $buttons.ok \
		-class TButton \
		-default active \
		-compound left \
		-image $icon::16x16::folder \
	]
	tk::SetAmpText $buttons.cancel " [Tr Cancel]"
	tk::SetAmpText $buttons.ok " [Tr Save]"

	pack $Vars(button:ok) -pady 5 -padx 5 -fill x -side right
	pack $Vars(button:cancel) -pady 5 -padx 5 -fill x -side right

	if {[llength $Vars(filetypes)]} {
		$top.ent_filetype addcol text -id name -type text
		for {set i 0} {$i < $filetypeCount} {incr i} {
			$top.ent_filetype addcol image -id icon$i -type image
		}
		$top.ent_filetype addcol text -id extensions -type text

		foreach entry $Vars(filetypes) {
			lassign $entry name extensions
			set types {}
			set icons {}

			foreach ext $extensions {
				if {[info exists Vars(fti:$ext)]} {
					set img $Vars(fti:$ext)
					if {$img ni $icons} {
						lappend icons $img
					}
				}
				if {[string length $types] > 0} { append types ", " }
				append types "*$ext"
			}

			while {[llength $icons] < $filetypeCount} {
				lappend icons {}
			}
			$top.ent_filetype listinsert [list $name {*}$icons $types]
		}

		$top.ent_filetype resize
		SetFileTypes 0
	}

	ChangeDir $w
	focus $top.ent_filename
	return $w
}


proc tooltip {args} {}
proc mc {msg args} { return [::msgcat::mc [set $msg] {*}$args] }


proc makeStateSpecificIcons {img} {
	# XXX preliminary
	set disabledImg [image create photo -width 0 -height 0]
	::scidb::tk::image disable $img $disabledImg
	return [list $img disabled $disabledImg]
	return $img ;# how to do?
}


proc Tr {tok {args {}}} {
	return [mc [namespace current]::mc::$tok {*}$args]
}


proc SelectFileTypes {w combo} {
	variable Vars

	set selection [$combo get]
	set i [string last " (" $selection]
	set selection [string range $selection 0 [expr {$i - 1}]]
	set i [lsearch -index 0 -exact $Vars(filetypes) $selection]
	set Vars(extensions) [lindex $Vars(filetypes) $i 1]

	SetFileTypes
	filelist::RefreshFileList $Vars(widget:table-2)
}


proc SetFileTypes {{index -1}} {
	variable Vars

	if {$index >= 0} {
		$Vars(widget:filetypes:combobox) current $index
	} else {
		set index [$Vars(widget:filetypes:combobox) current]
	}

	if {[llength $Vars(filetypes)]} {
		set icons {}
		set x 2
		set i 0
		set w $Vars(widget:filetypes:canvas)
		set y -1000

		foreach ext [lindex $Vars(filetypes) $index 1] {
			if {[info exists Vars(fti:$ext)]} {
				set img $Vars(fti:$ext)
				if {$img ni $icons} {
					incr x 2
					if {[llength [$w gettags ft:$i]] == 0} {
						$w create image 0 0 -anchor nw -tag ft:$i
					}
					if {$y == -1000} {
						set y [expr {(([winfo height $w] + 1) - [image height $img])/2}]
					}
					$w coords ft:$i $x $y
					$w itemconfigure ft:$i -image $img -state normal
					lappend icons $img
					incr x [image width $img]
					incr i
				}
			}
		}

		while {[llength [$w gettags ft:$i]] > 0} {
			$w itemconfigure ft:$i -state hidden
			incr i
		}
	}
}


proc SelectEncoding {w} {
	variable Vars

	set encoding [{*}$Vars(selectencodingcommand) $w]
	$Vars(widget:encoding) configure -foreground black
	set Vars(encodingVar) $encoding
	set Vars(encoding) $encoding
}


proc ThemeChanged {pw} {
	variable Vars

	set background [ttk::style lookup $::ttk::currentTheme -background]

	foreach n {1 2} {
		set w $Vars(widget:table-$n)
		foreach id [$w column list] {
			$w column configure $id -background $background
		}
	}

	$pw configure -background $background
}


proc VisitItem {w mode item} {
	if {[string length $item]} {
		switch $mode {
			enter { $w item state set $item {hilite} }
			leave { $w item state set $item {!hilite} }
		}
	}
}


proc SbSet {sb first last} {
	if {$first <= 0 && $last >= 1} {
		grid remove $sb
	} elseif {$sb ni [grid slaves [winfo parent $sb]]} {
		grid $sb
	}
	$sb set $first $last
}


proc ChangeDir {w} {
	variable Vars

	foreach dir $Vars(folders) {
		if {$Vars(dir) eq $dir} {
			::toolbar::childconfigure $Vars(button:add) -state disabled
			return
		}
	}

	set tip [format $mc::AddBookmark [file tail $Vars(dir)]]
	::toolbar::childconfigure $Vars(button:add) -state normal -tooltip $tip
}


namespace eval bookmarks {

array set Bookmarks {
	favorites	{}
	lastvisited	{}
	user			{}
}


proc Build {w args} {
	variable [namespace parent]::Vars

	array set opts {
		-width 120
	}
	array set opts $args

	set height [font metrics $Vars(font) -linespace]
	if {$height < 20} { set height 20 }

	::tk::frame $w -borderwidth 0 -takefocus 0

	set tb [::toolbar::toolbar $w -id toolbar -hide 0 -side top]

	set Vars(button:add) [::toolbar::add $tb button \
		-image $icon::16x16::iconAdd                 \
		-command [namespace code AddFavorite]        \
	]
	set Vars(button:minus) [::toolbar::add $tb button \
		-image $icon::16x16::iconMinus                 \
		-command [namespace code RemoveFavorite]       \
	]
	
	tk::frame $w.f -borderwidth 0 -takefocus 0
	pack $w.f -fill both -expand yes

	set tc $w.f.list
	set sb $w.f.vscroll
	set Vars(widget:table-1) $tc

	treectrl $tc {*}[array get opts] \
		-class FSBox                 \
		-highlightthickness 0        \
		-showroot no                 \
		-showheader no               \
		-showbuttons no              \
		-showlines no                \
		-takefocus 1                 \
		-itemheight $height          \
		-yscrollcommand [list [namespace parent]::SbSet $sb] \
		;

	ttk::scrollbar $sb           \
		-orient vertical          \
		-takefocus 0              \
		-command [list $tc yview] \
		;

	grid $tc -row 0 -column 0 -sticky nsew
	grid $sb -row 0 -column 1 -sticky ns
	grid columnconfigure $w.f {0} -weight 1
	grid rowconfigure $w.f {0} -weight 1

	$tc state define hilite

	$tc notify install <Item-enter>
	$tc notify install <Item-leave>
	$tc notify bind $tc <Item-enter> [list [namespace parent]::VisitItem $tc enter %I]
	$tc notify bind $tc <Item-leave> [list [namespace parent]::VisitItem $tc leave %I]

	$tc column create -tags root
	$tc configure -treecolumn root

	$tc element create elemImg image
	$tc element create elemTxt text                    \
		-fill [list                                     \
			$Vars(selectionforeground) {selected focus}  \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite}             \
		]                                               \
		-lines 1                                        \
		;
	$tc element create elemSel rect                    \
		-fill [list                                     \
			$Vars(selectionbackground) {selected focus}  \
			$Vars(selectionbackground) {selected hilite} \
			$Vars(inactivebackground) {selected !focus}  \
			$Vars(activebackground) {hilite}             \
		]
	$tc element create elemBrd border         \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;

	set s [$tc style create style]
	$tc style elements $s {elemSel elemImg elemBrd elemTxt}
	$tc style layout $s elemImg -expand ns -padx {4 0}
	$tc style layout $s elemTxt -padx {6 4} -expand ns -squeeze x
	$tc style layout $s elemSel -union {elemTxt} -iexpand nsew
	$tc style layout $s elemBrd -iexpand xy -detach yes

	$tc element create elemDiv rect -fill black -height 1
	$tc style create styLine
	$tc style elements styLine {elemDiv}
	$tc style layout styLine elemDiv -pady {3 2} -padx {4 4} -iexpand x -expand ns

	set Vars(bookmarks) {
		{ star			Favorites	}
		{ visited		LastVisited	}
		{ divider		""				}
		{ filesystem	FileSystem	}
	}
	if {[file isdirectory [file join [file nativename "~"] Desktop]]} {
		lappend Vars(bookmarks) { desktop Desktop }
	}
	lappend Vars(bookmarks) \
		{ home			Home			} \
		{ divider		""				} \
		;
	set Vars(folders) { Bases }

	foreach entry $Vars(bookmarks) {
		lassign $entry icon text
		set item [$tc item create]
		if {$icon eq "divider"} {
			$tc item style set $item root styLine
			$tc item enabled $item false
		} else {
			set icon [set [namespace parent]::icon::16x16::$icon]
			$tc item style set $item root style
			$tc item element configure $item root elemImg \
				-image $icon + elemTxt \
				-text [set [namespace parent]::mc::$text] \
				;
		}
		$tc item lastchild root $item
	}

	foreach folder $Vars(folders) {
		set icon [set [namespace parent]::icon::16x16::folder]
		set item [$tc item create]
		$tc item style set $item root style
		$tc item element configure $item root elemImg -image $icon + elemTxt -text [file tail $folder]
		$tc item lastchild root $item
	}

	$tc activate 0
	$tc notify bind $tc <Selection> [namespace code [list Selected $tc %S]]

	Selected $tc {}
}


proc Selected {w sel} {
	variable [namespace parent]::Vars
	
	set state disabled
	set tip ""

	if {[string is integer -strict $sel] && $sel > [llength $Vars(bookmarks)]} {
		set state normal
		set dir [lindex $Vars(folders) [expr {$sel - [llength $Vars(bookmarks)] - 1}]]
		set tip [format [set [namespace parent]::mc::RemoveBookmark] [file tail $dir]]
	}

	::toolbar::childconfigure $Vars(button:minus) -state $state -tooltip $tip
}


namespace eval icon {
namespace eval 16x16 {

set minus [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAcElEQVQ4y2NgGAUUA8aZRqKr
	OJgYydL8499/BhYZcfZQc1shsgw4efgdA8vfH38ZPt7/SJYBf3/8ZWD5++svw+dnX8gz4Bcz
	A8vf3/8Yvr75Qbru//8Z/jJwMbC8/cO4+isTNxnW/2H4wcg4mgypAQDLTyftPllLiAAAAABJ
	RU5ErkJggg==
}]

set plus [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAAB2klEQVQ4y42TPW5UQQyAP8+83eySHwgEEBIEiYJfcYE0
	RAFRcgKQ6CKEoOESNJQRB4ATINGgIOUOCBQo0kKAkGUTZd/OPNsUb0nYTRTiyjO2P9tjjzAi
	dx83wWnFIpwVIQC4Y6q2DpTvltKQfzEKOD87S0pp/sqNa0vt8XYEKHd6+uXT56etVustrB4O
	KGIDDTbdbk9dOtYeB0CsQQzFqUZjjH3+oxdqhpmR+4kUa3NKCTNDVY8AUMVMSTkRUwQgp4Sq
	mlbVfsDtxWLszLnTt8bazRkch6SNZpzTKpP6AYCqyjSaYS7rTnr4/GJEkH6v/+vH158rcmex
	uHD15vXlEyenLzs+4AqBiA+OImAoDOyC0NnsrK1++LhQIIQqW0xlxR4A8AzyV2dPHwCqpEFE
	QlH32Kcsy90Me5DdiCERhJwT7k4BWFmWKiJD/iFGROpIrzdpyF72eiYiXgDfu53Ok+2t7swg
	p4qE+cmpqUcxxt3JbHW7L91tBYiAmNom8G2kOLj37Diqen9icuLVv4Dtre0HMcbXb178PnwP
	TBU3CzknVOsxmhluFoz9csAmKu5OlfPwG7jh5v8HmBqOb+RcrUndLw5qZhuCHKGCet/fm9oC
	1N8ZMGD9gA74A1LI/eeznYVOAAAAInpUWHRTb2Z0d2FyZQAAeNpzTMlPSlXwzE1MTw1KTUyp
	BAAvnAXUrgypTQAAAABJRU5ErkJggg==
}]

set iconAdd		[list [fsbox::makeStateSpecificIcons $plus]]
set iconMinus	[list [fsbox::makeStateSpecificIcons $minus]]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace bookmarks

namespace eval filelist {

namespace import ::tcl::mathfunc::max


proc Build {w args} {
	variable [namespace parent]::Vars
	variable [namespace parent]::Options

	array set opts {
		-width			300
		-scrollmargin	16
		-selectmode		single
		-fullstripes	yes
		-stripes			{}
		-yscrolldelay	{500 50}
		-textpadx		{6 6}
		-textpady		{0 0}
	}

	array set opts $args

	foreach option {borderwidth textpadx textpady stripes} {
		set Vars($option) $opts(-$option)
		array unset opts -$option
	}

	set Vars(sort-column) name
	set Vars(encoding) ""
	set Vars(selected:dirs) {}
	set Vars(selected:files) {}
	set Vars(lock:selection) 0

	tk::frame $w -borderwidth 0 -takefocus 0
	tk::frame $w.f -borderwidth 0 -takefocus 0
	pack $w.f -fill both -expand yes

	set sv $w.f.vscroll
	set sh $w.f.hscroll
	set tc $w.f.files
	set tb [::toolbar::toolbar $w -id toolbar -hide 0 -side top]

	::toolbar::add $tb button                       \
		-image $icon::16x16::iconBackward            \
		-command [namespace code Backward]           \
		-tooltipvar [namespace parent]::mc::Backward \
		-state disabled                              \
		;
	::toolbar::add $tb button                      \
		-image $icon::16x16::iconForward            \
		-command [namespace code Forward]           \
		-tooltipvar [namespace parent]::mc::Forward \
		-state disabled                             \
		;

	::toolbar::add $tb separator

	set Vars(button:delete) [::toolbar::add $tb button \
		-image $icon::16x16::iconDelete                 \
		-command [namespace code [list DeleteFile $w]]  \
		-tooltipvar [namespace parent]::mc::Delete      \
		-state disabled                                 \
	]
	set Vars(button:rename) [::toolbar::add $tb button \
		-image $icon::16x16::iconModify                 \
		-command [namespace code [list RenameFile $tc]] \
		-tooltipvar [namespace parent]::mc::Rename      \
		-state disabled                                 \
	]
	::toolbar::add $tb button                         \
		-image $icon::16x16::folder_add                \
		-command [namespace code [list NewFolder $tc]] \
		-tooltipvar [namespace parent]::mc::NewFolder  \
		;

	::toolbar::add $tb separator

	if {$Options(show:details)} {
		set layout list
		set tooltip ListLayout
	} else {
		set layout details
		set tooltip DetailedLayout
	}
	set Vars(widget:layout) [::toolbar::add $tb button  \
		-image [set icon::16x16::$layout]                \
		-command [namespace code SwitchLayout]           \
		-tooltipvar [namespace parent]::mc::$tooltip     \
		-variable [namespace parent]::Options(show:list) \
	]
	if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
	set Vars(widget:hidden) [::toolbar::add $tb checkbutton \
		-image [set icon::16x16::${ipref}locked]             \
		-command [namespace code [list SwitchHidden $tc]]    \
		-tooltipvar [namespace parent]::mc::ShowHiddenFiles  \
		-variable [namespace parent]::Options(show:hidden)   \
		-padx 1                                              \
	]

	set Vars(widget:table-2) $tc
	set Vars(xscrollcmd) [list [namespace parent]::SbSet $sh]
	set Vars(yscrollcmd) [list [namespace parent]::SbSet $sv]
	set Vars(widget:xscrollbar) $sh
	set Vars(widget:yscrollbar) $sv

	treectrl $tc {*}[array get opts] \
		-class FSBox                  \
		-takefocus 1                  \
		-highlightthickness 0         \
		-showheader yes               \
		-showbuttons no               \
		-showroot no                  \
		-showlines no                 \
		-showrootlines no             \
		-columnresizemode realtime    \
		-xscrollincrement 1           \
		-keepuserwidth no             \
		;
	set Vars(widget:filelist) $tc

	ttk::scrollbar $sv           \
		-orient vertical          \
		-takefocus 0              \
		-command [list $tc yview] \
		;
	ttk::scrollbar $sh           \
		-orient horizontal        \
		-takefocus 0              \
		-command [list $tc xview] \
		;

	grid $tc -row 0 -column 0 -sticky nsew
	grid $sh -row 1 -column 0 -sticky ew
	grid $sv -row 0 -column 1 -sticky ns
	grid columnconfigure $w.f {0} -weight 1
	grid rowconfigure $w.f {0} -weight 1

	SetColumnBackground $tc tail $Vars(stripes) $opts(-background)
	set height [max [font metrics [$tc cget -font] -linespace] 20]
	set Vars(charwidth) [font measure [$tc cget -font] "0"]
	$tc configure -itemheight $height

	$tc state define hilite

	set Vars(layout) ""
	if {$Options(show:details)} { set layout details } else { set layout list }
	SwitchLayout details

	TreeCtrl::SetEditable  $tc { {name styName txtName} }
	TreeCtrl::SetSensitive $tc { {name styName elemImg txtName} }
#	TreeCtrl::SetDragImage $tc { {name styName elemImg txtName} }

	$tc notify install <Edit-begin>
	$tc notify install <Edit-accept>
	$tc notify install <Edit-end>
	$tc notify install <Item-enter>
	$tc notify install <Item-leave>
	$tc notify install <Header-invoke>

	$tc state define edit
	$tc style layout styName txtName -draw {no edit}
	$tc style layout styName elemSel -draw {no edit}
	$tc notify bind $tc <Edit-begin> { %T item state set %I ~edit }
	$tc notify bind $tc <Edit-accept> { %T item element configure %I %C %E -text %t }
	$tc notify bind $tc <Edit-end> { %T item state set %I ~edit }
	$tc notify bind $tc <Item-enter> [list [namespace parent]::VisitItem $tc enter %I]
	$tc notify bind $tc <Item-leave> [list [namespace parent]::VisitItem $tc leave %I]

	$tc notify bind $tc <Header-invoke> [namespace code { SortColumn %T %C }]

	$tc notify bind $tc <Selection> [namespace code [list SelectFiles $tc %S]]
	bind $tc <Double-ButtonPress-1> [namespace code { DoubleButton %W %x %y }]

	CheckDir $tc
}


proc SwitchHidden {w} {
	variable [namespace parent]::Vars
	variable [namespace parent]::Options

	set Options(show:hidden) [expr {!$Options(show:hidden)}]
	if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
	toolbar::childconfigure $Vars(widget:hidden) -image [set icon::16x16::${ipref}locked]
	RefreshFileList $w
}


proc DetailsLayout {w} {
	variable [namespace parent]::Vars

	$w configure -itemwidthequal no
	$w configure -orient vertical -wrap {}
	$w configure -showheader yes
	$w configure -yscrollcommand $Vars(yscrollcmd)
	$w configure -xscrollcommand {}
	grid remove $Vars(widget:xscrollbar)

	catch { $w item delete 1 end }
	foreach col [$w column list] { $w column delete $col }
	$w style delete {*}[$w style names]
	$w element delete {*}[$w element names]

	$w column create                            \
		-text [set [namespace parent]::mc::Name] \
		-tags name                               \
		-width [expr {25*$Vars(charwidth)}]      \
		-minwidth [expr {10*$Vars(charwidth)}]   \
		-arrow up                                \
		-borderwidth $Vars(borderwidth)          \
		-steady yes                              \
		-textpadx $Vars(textpadx)                \
		-textpady $Vars(textpady)                \
		-font $Vars(font)                        \
		-expand yes                              \
		-squeeze yes                             \
		;
	$w column create                            \
		-text [set [namespace parent]::mc::Size] \
		-tags size                               \
		-justify right                           \
		-width [expr {10*$Vars(charwidth)}]      \
		-minwidth [expr {6*$Vars(charwidth)}]    \
		-arrowside left                          \
		-arrowgravity right                      \
		-borderwidth $Vars(borderwidth)          \
		-steady yes                              \
		-textpadx $Vars(textpadx)                \
		-textpady $Vars(textpady)                \
		-font $Vars(font)                        \
		;
	$w column create                                \
		-text [set [namespace parent]::mc::Modified] \
		-tags modified                               \
		-width [expr {18*$Vars(charwidth)}]          \
		-minwidth [expr {10*$Vars(charwidth)}]       \
		-borderwidth $Vars(borderwidth)              \
		-steady yes                                  \
		-textpadx $Vars(textpadx)                    \
		-textpady $Vars(textpady)                    \
		-font $Vars(font)                            \
		;
	
	if {[llength $Vars(sizecommand)]} {
		set sizefmt "%d"
	} else {
		set sizefmt "%d KB"
	}
	
	$w element create elemImg image -image [set [namespace parent]::icon::16x16::folder]
	$w element create txtName text \
		-fill [list \
			$Vars(selectionforeground) {selected focus} \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite} \
		] \
		-lines 1 \
		;
	$w element create txtSize text \
		-fill [list \
			$Vars(selectionforeground) {selected focus} \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite} \
		] \
		-datatype integer \
		-format $sizefmt \
		-lines 1 \
		;
	$w element create txtDate text \
		-fill [list \
			$Vars(selectionforeground) {selected focus} \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite} \
		] \
		-datatype time \
		-format $Vars(timeformat) \
		-lines 1 \
		;
	$w element create elemSel rect \
		-fill [list \
			$Vars(selectionbackground) {selected focus} \
			$Vars(selectionbackground) {selected hilite} \
			$Vars(inactivebackground) {selected !focus} \
			$Vars(activebackground) {hilite} \
		] 
	$w element create elemBrd border          \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;
	
	# column 0: icon + text
	set s [$w style create styName -orient horizontal]
	$w style elements $s {elemSel elemImg elemBrd txtName}
	$w style layout $s elemImg -padx {2 0} -expand ns
	$w style layout $s txtName -squeeze x -expand ns -padx {4 0}
	$w style layout $s elemSel -union {txtName} -ipadx 2 -iexpand nsew
	$w style layout $s elemBrd -iexpand xy -detach yes

	# column 1: text
	set s [$w style create stySize]
	$w style elements $s {elemSel elemBrd txtSize}
	$w style layout $s txtSize -padx {4 4} -squeeze x -expand ns
	$w style layout $s elemSel -union {txtSize} -ipadx 2 -iexpand nsew
	$w style layout $s elemBrd -iexpand xy -detach yes

	# column 2: text
	set s [$w style create styDate]
	$w style elements $s {elemSel elemBrd txtDate}
	$w style layout $s txtDate -padx {4 4} -squeeze x -expand ns
	$w style layout $s elemSel -union {txtDate} -ipadx 2 -iexpand nsew
	$w style layout $s elemBrd -iexpand xy -detach yes

	set Vars(scriptDir) {
		set item [$w item create -open no]
		$w item style set $item name styName size stySize modified styDate
		$w item element configure $item \
			name txtName -text [file tail $dir] , \
			modified txtDate -data [file mtime $dir]
		$w item lastchild root $item
	}

	set Vars(scriptFile) {
		set item [$w item create -open no]
		$w item style set $item name styName size stySize modified styDate
		set icon [GetFileIcon $file]
		if {[llength $Vars(sizecommand)]} {
			set size [{*}$Vars(sizecommand) $file]
		} else {
			set size [expr {[file size $file]/1024 + 1}]
		}
		$w item element configure $item \
			name elemImg -image $icon , \
			name txtName -text [file tail $file] , \
			size txtSize -data $size , \
			modified txtDate -data [file mtime $file]
		$w item lastchild root $item
	}
}


proc ListLayout {w} {
	variable [namespace parent]::Vars

	$w configure -itemwidthequal yes
	$w configure -orient vertical -wrap window
	$w configure -showheader no
	$w configure -yscrollcommand {}
	$w configure -xscrollcommand $Vars(xscrollcmd)
	grid remove $Vars(widget:yscrollbar)

	catch { $w item delete 1 end }
	foreach col [$w column list] { $w column delete $col }
	foreach sty [$w style names] { $w style delete $sty }
	foreach elm [$w element names] { $w element delete $elm }

	$w column create -tags name -steady yes

	$w element create elemImg image -image [set [namespace parent]::icon::16x16::folder]
	$w element create elemTxt text \
		-fill [list \
			$Vars(selectionforeground) {selected focus} \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite} \
		] \
		-lines 1 \
		;
	$w element create elemSel rect \
		-fill [list \
			$Vars(selectionbackground) {selected focus} \
			$Vars(selectionbackground) {selected hilite} \
			$Vars(inactivebackground) {selected !focus} \
			$Vars(activebackground) {hilite} \
		] 
	$w element create elemBrd border          \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;
	
	set s [$w style create styName]
	$w style elements $s {elemSel elemImg elemBrd elemTxt}
	$w style layout $s elemImg -expand ns -padx {3 0}
	$w style layout $s elemTxt -squeeze x -expand ns -padx {2 3}
	$w style layout $s elemSel -iexpand xy -detach yes
	$w style layout $s elemBrd -iexpand xy -detach yes

	set Vars(scriptDir) {
		set item [$w item create -open no]
		$w item style set $item name styName
		$w item text $item name [file tail $dir]
		$w item lastchild root $item
	}

	set Vars(scriptFile) {
		set item [$w item create -open no]
		$w item style set $item name styName
		set icon [GetFileIcon $file]
		$w item element configure $item name \
			elemImg -image $icon + \
			elemTxt -text [file tail $file]
		$w item lastchild root $item
	}
}


proc SwitchLayout {{layout {}}} {
	variable [namespace parent]::Vars
	variable [namespace parent]::Options

	if {[llength $layout] == 0} {
		set Options(show:details) [expr {!$Options(show:details)}]
		set Options(show:list) [expr {!$Options(show:list)}]
		if {$Options(show:details)} {
			set layout list
			set tooltip ListLayout
		} else {
			set layout details
			set tooltip DetailedLayout
		}
		::toolbar::childconfigure $Vars(widget:layout) \
			-image [set icon::16x16::$layout] \
			-tooltipvar [namespace parent]::mc::$tooltip \
			;
		if {$Options(show:details)} { set layout details } else { set layout list }
	}

	if {$layout eq $Vars(layout)} { return }
	set Vars(layout) $layout
	set w $Vars(widget:filelist)
	set selection [$w selection get]

	switch $layout {
		details	{ DetailsLayout $w }
		list		{ ListLayout $w }
	}

	Glob $w 0
	$w see 1
	$w activate 0
	foreach sel $selection {
		$w selection add $sel
		$w activate $sel
		$w see $sel
	}
}


proc GetFileIcon {filename} {
	variable [namespace parent]::Vars

	foreach {ext icon} $Vars(fileicons) {
		if {[string match *$ext $filename]} {
			return $icon
		}
	}

	return [set [namespace parent]::icon::16x16::document]
}


proc SortColumn {w column} {
	variable [namespace parent]::Vars

	if {[$w column compare $column == $Vars(sort-column)]} {
		if {[$w column cget $Vars(sort-column) -arrow] eq "down"} {
			set order -increasing
			set arrow up
		} else {
			set order -decreasing
			set arrow down
		}
	} else {
		if {[$w column cget $Vars(sort-column) -arrow] eq "down"} {
			set order -decreasing
			set arrow down
		} else {
			set order -increasing
			set arrow up
		}
		$w column configure $Vars(sort-column) -arrow none
		set Vars(sort-column) $column
	}

	$w column configure $column -arrow $arrow
	set dirCount [llength $Vars(dirList)]
	set fileCount [expr {[$w item count] - 1 - $dirCount}]
	set totalCount [expr {$dirCount + $fileCount}]
	set lastDir [expr {$dirCount - 1}]

	switch [$w column cget $column -tags] {
		name {
			if {$dirCount} {
				$w item sort root $order \
					-last [list root child $lastDir] \
					-column $column \
					-dictionary \
					;
			}
			if {$fileCount} {
				$w item sort root $order \
					-first [list root child [expr {$lastDir + 1}]] \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column \
					-dictionary \
					;
			}
		}

		size {
			if {$fileCount} {
				$w item sort root $order \
					-first [list root child [expr {$lastDir + 1}]] \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column \
					-integer \
					-column name \
					-dictionary \
					;
			}
		}

		modified {
			if {$dirCount} {
				$w item sort root $order \
					-last [list root child $lastDir] \
					-column $column  \
					-integer \
					-column name \
					-dictionary \
					;
			}
			if {$fileCount} {
				$w item sort root $order \
					-first [list root child [expr {$lastDir + 1}]] \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column  \
					-integer \
					-column name \
					-dictionary \
					;
			}
		}
	}
}


proc SetColumnBackground {w id stripes background} {
	if {[llength $stripes]} {
		$w column configure $id -itembackground [list $stripes $background]
	} else {
		$w column configure $id -itembackground $background
	}
}


proc Glob {w refresh} {
	variable [namespace parent]::Vars
	variable [namespace parent]::Options

	if {$refresh || ![info exists Vars(dirList)]} {
		set filter *
		if {$Options(show:hidden)} { lappend filter .* }
		set dirs [glob -nocomplain -directory $Vars(dir) -types d {*}$filter]
		set Vars(dirList) {}

		foreach dir [lsort -dictionary $dirs] {
			set d [file tail $dir]
			if {$d ne "." && $d ne ".."} {
				lappend Vars(dirList) $dir
			}
		}

		set filter *
		if {$Options(show:hidden)} { lappend filter .* }
		set files [glob -nocomplain -directory $Vars(dir) -types f {*}$filter]
		set Vars(fileList) {}

		foreach file [lsort -dictionary -unique $files] {
			set match 0

			if {[llength $Vars(extensions)] == 0} {
				set match 1
			} else {
				foreach ext $Vars(extensions) {
					if {[string match *$ext $file]} {
						set match 1
					}
				}
			}

			if {$match} {
				lappend Vars(fileList) $file
			}
		}
	}

	foreach dir $Vars(dirList) $Vars(scriptDir)
	$w item tag add "root children" directory
	foreach file $Vars(fileList) { eval $Vars(scriptFile) }
}


proc DoubleButton {w x y} {
	variable [namespace parent]::Vars

	set id [$w identify $x $y]
	if {![TreeCtrl::IsSensitive $w $x $y]} { return }

	set item [lindex $id 1]
	set column [lindex $id 3]
	if {![$w item tag expr $item directory]} { return }

	set name [$w item text $item $column]
	set Vars(dir) [file join $Vars(dir) $name]
}


proc RefreshFileList {w} {
	variable [namespace parent]::Vars

	set Vars(lock:selection) 1
	$w item delete all
	set Vars(lock:selection) 0
	Glob $w 1
	set n "root firstchild"
	$w xview moveto 0.0
	$w yview moveto 0.0
	set dirs $Vars(selected:dirs)
	set files $Vars(selected:files)
	set Vars(selected:dirs) {}
	set Vars(selected:files) {}

	foreach dir $dirs {
		set i [lsearch -exact $Vars(dirList) $dir]
		if {$i >= 0} {
			set n [expr {$i + 1}]
			$w selection add $n
			lappend Vars(selected:dirs) $dir
		}
	}

	foreach file $files {
		set i [lsearch -exact $Vars(fileList) $file]
		if {$i >= 0} {
			set n [expr {$i + 1 + [llength $Vars(dirList)]}]
			$w selection add $n
			$w activate $n
			lappend Vars(selected:files) $file
		}
	}

	$w activate $n

	if {[string is integer $n]} {
		$w see $n
	}
}


proc SelectFiles {w selection} {
	variable [namespace parent]::Vars

	if {$Vars(lock:selection)} { return }

	set Vars(selected:dirs) {}
	set Vars(selected:files) {}

	foreach n $selection {
		if {$n <= [llength $Vars(dirList)]} {
			set dir [lindex $Vars(dirList) [expr {$n - 1}]]
			lappend Vars(selected:dirs) $dir
			CheckDir $w $dir
			CheckFile $w
		} else {
			if {[llength $Vars(selected:files)] == 0} {
				$Vars(widget:filename) delete 0 end
			} else {
				Vars(widget:filename) insert end "; "
			}
			set file [lindex $Vars(fileList) [expr {$n - [llength $Vars(dirList)] - 1}]]
			$Vars(widget:filename) insert end [file tail $file]
			lappend Vars(selected:files) $file
			CheckDir $w
			CheckFile $w $file
		}
	}

	if {[llength $Vars(selected:dirs)] + [llength $Vars(selected:files)] == 1} {
		set state normal
	} else {
		set state disabled
	}
	::toolbar::childconfigure $Vars(button:delete) -state $state
	::toolbar::childconfigure $Vars(button:rename) -state $state
}


proc CheckFile {w {file ""}} {
	variable [namespace parent]::Vars

	if {[llength $Vars(selectencodingcommand)] && [string length $Vars(encoding)] == 0} {
		foreach {ext encoding} $Vars(fileencodings) {
			if {[string match *$ext $file]} {
				set Vars(encodingVar) $encoding
			}
		}
	}
}


proc CheckDir {w {dir  ""}} {
	# nothing to do
}


proc DeleteFile {w} {
	# KDE: exec 'kioclient move $file trash:/'
	# KDE: exec 'kfmclient move $file trash:/'

	# Probably look if 'kfmclient --commands' contains 'kfmclient move',
	# otherwise kioclient has to be used.
}


proc RenameFile {w} {
}


proc NewFolder {w} {
}


namespace eval icon {
namespace eval 16x16 {

set forward [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAA3NCSVQICAjb4U/gAAAAvVBM
	VEX///8AOcgAOcUAO8cAPMQAP7sAQb4APskARcEAQMcAScUAPrcAQscAS8kAScUARcEAScYA
	Q78ASscAQbwAS8cAS8gAPbQATMgATs0ARMcAR8QAQcYAT9AARMMATc4ARrsAVtMARrsARrwA
	Rr0AR74AVtMAV9MAQr0AScQAScUAScYAVtMAScYAWNQAS8oAWtcASb8ATMYAXdoATcYAX9wA
	YN0ATMAAWtYASLgASbgATsAAUccAVM0AXNcAZOFbNlwqAAAAOHRSTlMAAQIKDxAUHR8iMj5A
	SFFTU1VVV1dZWltgZGl0eomUoqKjo6OkpKerra+xv8HDx9TZ2eLs7/j5/ljh37cAAABuSURB
	VBgZdcFFAsJAEADBxt3dIbi77cL8/1nAhcweUgUB2jFcw20Sx1T2abSZyCnHTzxfLFdrjbWI
	XJp8FcR37QKlt3Lvh6m8tF2C+tP3mEchMxh53nhyMMbceiH+FtaeWyhLe8yirTYpHJ0IAT6u
	8hQ3HDI7ywAAAABJRU5ErkJggg==
}]

set backward [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABN0lEQVQ4y7WTPUsDQRCGnz0v
	F0MMl/gFQcT/oNVBwMagQdDCdDYWNlpZW1inEyzlfoONiIUi0SSoiGCdQvQvhEQvucuORUKC
	BENOyBbD7ruzz8C8szDWtXqTZL18MCzF+PMme79EOn2JbTvhAbnKMnPzV0wlMkOLAOaAsvm8
	wXTqnGh0EQDFxDCA+nXaet0jZZ8SiSR7Wq1W5KvhImgQjaAR6ey9ZqkP2H47JpU4wTSjIzf5
	8yNv4lQMZmNnxK1DgpYiaI3uktaGScRcQAcrtL5VaJt12+g8ypRtrKaL5ecJg6kHu/1050kR
	9wtMto8wsHq6L1W0vCAiIF1ROsEL3MF6a4/7xKSAqWYA8NoXXGd2Rh+kW8elofL4Uu06bYSf
	xDunSF3l8OThfwCAovNOTeXwKI31w/4AzwJhKlxf1k4AAAAASUVORK5CYII=
}]

set delete [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwY
	AAAABGdBTUEAALGeYUxB9wAAACBjSFJNAAB6JQAAgIMAAPn/AACA6AAAUggAARVYAAA6lwAA
	F2/XWh+QAAADFklEQVR42qSRS2icVRxHz//e+30z40zSNI1NJ5M0aWpj0hCToEiRqAhWS5G2
	ii7ERVdioSC4E7pyI5SutIsufCJaFIoQRLJQKVpKwaRYA1XTF01MWpukdJLM8/vuw0VF3Hvg
	tzmrHxw5uWPHrvGDBz7u6u3uvvDRJ58uXr3xjktTnEBOQQZIAOcDOE+kVfuD/f3vbhvY9dyN
	8xdOm7GXDn0zvm/vw/HaXdSzE8fOrZWL1/+8fURpxX+xzpPRes/A2OiHW4eHB27PL8xvNGqX
	TDYTt6ryKmZ9hd5NJiru6Xvj+2b5qemVxhNBSTkA1ntVatt0Zmxs7FBZqdr01NTRtNH8IADy
	XrFILjJvPTby0LGhgt2il25SWy7z81+N1Ys1P5QTBoeiaLJUKrVfrtWn55ZuTeTiOMm3tlKr
	rCOndvZTW1nFJE3aI94fKegjHd5FSdMzV3eVnCNXMEbPeP/ZPesOiyiiOCaXz1OrrKNEBBMZ
	spmYlVr65tnlxs5za+7XtbqjZEMh57z+yboTd7w/jNYEQAARQQCTpgn1pEnTWoxSVIW7SRoi
	5z0uQFYLmxXPLHuFDQBCYi3NahV8QD/eqNNMU3wIaOgZ9H5ut/O9VRFmjf62JSP94wXVvZBK
	x5plSgSch6a1JB5UCAFECNA54Nxsv/NbrBYuRerLRSUv/JjKy+tZ7V7cHh9VwiMuQOD+kwAo
	uZ9ZDTg/0xdCm4mFP4y6eQt5NQaanskzd+xrsRZ5ssNMhuAxEv6dkgBF5z4fCr47m9WsRNr+
	7uV5HcAFMEDDhq++nm8e3503fdti9br84w2ggndbh9rbXikUYsgJM5YTqedKCGA9BAJZBUsN
	//Yv99Iro3lzXAhoQANqc6FwoO/pCdM22Iu0xCFj5FRPTtGVVXRmFaLAC0QaZjfsfnHhgU6t
	DuZFKIigqkm6mB0doWP/Xih1+Yb19dQHEh+wIRADERADAa7/VncnuxTDPRp6NOhHrb2WeLev
	ZXtP8YezF08vlCtf1FNPNfVUUo8SRaQEEUGL0IDvanC+AmEDkBAC/4e/BwACT2zMWyQBIAAA
	AABJRU5ErkJggg==
}]

set modify [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACsElEQVQ4y42TXUhTcRjGn/8525SdOXWxLDRnKWJqEUpm
	c5oUgl0EWWA3RZR0YV141UUXrRF00YUUfYk6u4kuIgiMIkJSkgih/KrQmNOpW/ve8WxzOzv7
	OP8uBEHL7L3/Pc/D+74PwX+O71EtIiuxFv3OnBeyQ5ATtsjVgfOlL9ntwP6O23g9MQwp31S1
	KCS7s+zfy/PsvBq2+NHqkYBrW4Eb10UEh+/UhLLTD4vqrjQszUWI/HYMuQFJK7NM85YCXzvL
	0POlHNJo9MiuJvKEyf1kdMyukj3NXXDFUmAmJ6FSE9WWAjfNu+H/kKzTNWR61QZvbV5SgNI5
	hampFArPdiGYisUTzokBZjM4fm0fKD0BcRn1OqP8WG3wHCKBMKiHgIupoJt5hpnntyRNKWfl
	cyUL2SzgHDwI0ZUx6Yy0V21wV5KAAOIjCNs0CDtYUCkjBpdhDU6lzaoihbCeYKzTAEpbEHOm
	TDoj06Mu8a7DEfsajBSVEpFsK5VyLPrqPOHkcBTrCZYGDyC+nDbqG9l+rsRdCR+/0Tkli2JI
	ZQ3ZGDOnp0L9qwAAgHlvBCi9iNiiVKM/xt7nDO5K+PkNzjQlS/GA0sovwMJmy+swADDFF9ow
	0v7ToKsr7OaKXYfh50G8a87CPAs5KYtRn6LP8w1mBUf55qHghp0xFa2XoasqOqfde8nErOwA
	8QIRuwYRBws5KUtRr8Lqs8HCcFRoehP649zMu/bTZQWm421ZigqFMn0Kor8Ygp0gLWZEwc32
	LY5nzCpNhm8d5f/6L4wvqWwOOBZqSXIOBPlQaivltMRG/Av0rmdWtmRpILQMhbd8dbYxh+mf
	+DxdpOcEysZcTufw7NjydPzewo+EVaWm4TPjq//sCnmwP1uSkplfBVrFR71W9dTtiLkh0/kO
	V2a7ngEAfgMA/k9aWbNcqAAAAABJRU5ErkJggg==
}]

set folder_add [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
	ZSBJbWFnZVJlYWR5ccllPAAAAqZJREFUeNqMUltIFFEY/v45Z3bd1Wy9BaVpKlkSaiRivXax
	oCBCEuwhgqDsISoxkCAIeiojeiixXoTowbLLQ9CD9GohorimSGKTLqWZYnnZNfcyp//MeCMK
	+pl/Zs5/vv/+UX/LgR92PBpQdgJayBAgIb8SGYf55NUmrAg5jwRR14pZaueyulYgFndBQqD3
	/qlsDjJAtOa7GoMTGNKcIkNucgIo22bnJUSHm6AUwcyuxp66J4BBq1ndl3I/0kSw+XSWMEUF
	V9ItHZAK84WP7wXik29WwboC4kDk/GugDaPwCl8rDIVmo8V5Ae5HIxMRLovbJbHWMn8MYeBz
	90fMhCb4qJwARLWMlSja7O3jub1yA+AXhEcHkE4qt2qC1TWIlIAXhce5JXt5RiutmB4EW86e
	kE5tIorRnmFMW1/Wjwt55duRnpOBmHUPpNSyVcHw5SAqdmA2Eu+SZBhYmrAQXZhHRX0bZ+J1
	KnLaSYSauV0DkjE8dd2TG3tDMSKDgxifirVJ3jfmJsaQmrMTiFiwpzt0DicXiSQI7Sh8aB14
	ivZPvU717IIqbx4uNY09FheOFdyAiiOzqASml1eKRR5FEquHh+UBPH52fob3P3uwvxw4s68B
	KWnvMBSZxbYj8Bt6TfPfJuHP38rgJVBKgHWjo0jWmobnI90ozQfCvO3SjCaEI8CuXIbbuCht
	RXO8ltTgwwfQpFJr7GFWEHzwaoqgMvsqKrbcduyXKxV6xhvR2XfLQZZdqy3eHYsnEupP3tqw
	F8L24veakZd7C3jZMeD6QYWbbwl+E+i3mH8fHlUFS851jLgL/qvYRw+h3RrHydxMoHO0kfkP
	8BmLM3hBHAD/El4e/MqD/POvc6vv4G5yOqo1HTR1tHN7A+oJ/y88NmStO0+xhn4LMACJMOOy
	azadagAAAABJRU5ErkJggg==
}]

set details [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAhFBMVEX///8yMjJeXl53d3c7
	btI9b9JFedZQiNpUjN1kmeJsn+Nflt50o+N1peWGr+eJsumVuusDAwMHBwcMDAwSEhIXFxce
	Hh4kJCQmJiYrKystLS00NDQ8PDxDQ0NKSkpRUVFTU1NYWFhZWVlgYGBlZWVra2twcHB0dHR3
	d3ePtumlxO21z/FUFAfUAAAAEXRSTlMAa2trcHBwcHBwcODg4ODg4GafyCkAAABTSURBVBjT
	Y2AgDLgEuFAFBLQFGJg11NVUVZSVFLCqIAw4+TlQBfi0eBmYFOXlZGWkpSRAAuw8bKQaysrN
	girArcnNwCgpLiYqIiwkCBJgQVeBBgBQ6AQqD/VzagAAAABJRU5ErkJggg==
}]

set list [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
	ZSBJbWFnZVJlYWR5ccllPAAAAaFJREFUeNqskz1LA0EQhmf3LmkVrATFIrUWptMmoKBW8U8o
	RIgpLPwPKZRY2IggiK2olUZBmwgpokI4SRVQRDDEkEsM0dzejrPZC35dQCULw+3DzDvLvMOx
	1XQZpMSDloSoYCaM5LfgbnQBuBQguT8/jC1CkIlDg8G8qUQOimhqbgAEAKznATZm+wFBn7VP
	jF4+NdMHieNKNGAawCOVI3BYEBqUtKpatElFmzfE9le+9bhJoTRKy5LJZOexf59w7LiOpTfE
	7QKiamjVEK1qdy4JxNhJXT0c5stnjRxHB14dAJPpjgalOEXgG3fyb1TLpQtt7fTzPiALQIuS
	E0O64KqsY3LYnx2qRW6A0vbGgyXywLIRD+71jMUmYvEFcb8LW3Rf6niQ8DwQ8mNGTqGuJviz
	lMoXF9raKZpDkgcuJcYHdUGB9l2oUfsu7DIVBkz1zIN4uo7XdcRsTc+ovlnae9b25+sGYjz9
	0vbAXDmt5prVx4vdzEBE0JRqk3uXNu2dfh7mzzuZGrj207nSgvob6YRUNxXeSOFfcMjT/hzp
	L/wuwACc0EGVyt8jVQAAAABJRU5ErkJggg==
}]

set locked [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAA3NCSVQICAjb4U/gAAAArlBM
	VEUAAAD///+mdkKmd0OLTgmeZBKwexuoekipe0mpe0meajKqfEurf0+rf0+aZSqsgVFcQBRh
	RxhkSBluViuKTAiLTgmUcSueZBKfgTegXAigZhCtglOwexu2iDS4iDO7jju7lkW8jDHAkDDF
	ky7HnUDHn03JokvUunTVsVHWpDTZtVHZtmzbqTLbuWvbvGXcumvgrTHlsi/lxl/oz4Lu14Tw
	zG3z0Gzz3ov16tP88dOk1C/MAAAAEHRSTlMAABU6f39/kpOiqrHb5/H0F6+W8wAAAIxJREFU
	GBkFwUtSwkAUAMB+M0MCkY0lh/H+O+/iQqoIkmQ+dEcAAHIw0ny5jeggB2n5XNfx1StEsJRH
	I1/rEwn5aGhHhoR5B/sMCSlAJEg4BYgTRPh+Alx+KLQzWsaKwmg8fm9XOgo1vO79ns9eKIx/
	tY++dwOFOulLXdJkQ6FtOx9j26aGwl9A49jxBvUsOgZvCk5SAAAAAElFTkSuQmCC
}]

set unlocked [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAA3NCSVQICAjb4U/gAAAAqFBM
	VEUAAAD///+neEWneEWoekeqfEuKTAiSVgyiaRSyfRyqfUyrfk2rf0+sgVFcQBRhRxhkSBlu
	ViuKTAiSVgyUcSufgTegXAigZhCiaRStglOyfRy2iDS4iDO7jju7lkW8jDHAkDDFky7HnUDH
	n03JokvUunTVsVHWpDTZtVHZtmzbqTLbuWvbvGXcumvgrTHlsi/lxl/oz4Lu14TwzG3z0Gzz
	3ov16tP88dME3NweAAAADnRSTlMAABRgcbG/v7+/wM7b9CY2ri4AAACRSURBVBgZBcFdSsQw
	GADA+ZI0dKsIgj7sSbz/815FcBF1m/4kzkSAIc8vvtcuBzC974+WX9cuIiKiXKdEmq4lB1j2
	1hmUBNTWobeagAggIgFTADElIAUQKT7+AC43KOeMM+MXlHHy8/n2TAflCOu93/NsBWU8HGOM
	rRugHFVfjiVVDZSzbTyN1uoJylcAth38A1SfODLjSYFtAAAAAElFTkSuQmCC
}]

set iconDelete		[list [fsbox::makeStateSpecificIcons $delete]]
set iconModify		[list [fsbox::makeStateSpecificIcons $modify]]
set iconBackward	[list [fsbox::makeStateSpecificIcons $backward]]
set iconForward	[list [fsbox::makeStateSpecificIcons $forward]]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace filelist

namespace eval icon {
namespace eval 16x16 {

set star [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACfklEQVQ4jX1SS08TURg99047
	UKfT0spDaFNINQJVg9QY1I0PdGNc+wuMsbFFhI2JOzYaExUr1KgbNy6IcWHEGENc6MJXxIUb
	wCYgBBMmBUqfdNqZ+7lo8QX1Jic3X+75Ts7NOSAiVMPE/cDQ82F/3/84VR9il7h/felxYXlm
	OBENwVmNx1HldHb1XKl12mu2t7TV+9s7+6rxthSI9Une/YdOnkVeA0oZBA+fPn/nAlO24lr+
	HEbCzMq5pamrO3i9zm13IqsBkNHsafUGAh1DsQi/YQpKREZJbOyw8WvN/S2+tqMO1eFT6+oa
	FdXhUhRFARkA5DJYDYhk5NKZTDa9mswkE1o6lVhYmJ96YVFttb3dezrOQCbAKACUBrJJgFj5
	hyQBJIHBCjuzqnaVqzscXh8y7oOJH/G0ZXJqLlzK523HjvT0SnIBKKYBKgHCAIQJmAQIAGZF
	TFKhF7Zh4suHp/GV1FVGRLgVYq37PK6HJ7r9pySeB0iUHdDGsqiAUNRlejW9OBZfy0YGYrTM
	iAgAcDPEvEGP89Hxvc29ZQH8FhACEARRIno5oz2ZTuZDgzFa/SvGwXu0mMzp76AbgG4CRbN8
	6yagiwpMliwUJzaWN8XYYJPbUarYLYcECAJMEzABLoB62dpZtQduSdoJ3QAgASawnF1flwDu
	qrXVgEzAKMHFpcCWTYyGWX2DxeKDULCakvTXsytvxmaXQmNzWv/bheSnVE42ADsaubTr9kVm
	3eRAZmjSi5y9n09Mfl1beZAjejYwSlo0wvjnzNr4t2zqbFB1nXMQU6wMbgAaAPxKYSTC3Jxw
	QCfEL4/S9387H40wLgR2ywwewfAxfJeyAPATKelrfd3EuF8AAAAASUVORK5CYII=
}]

set filesystem [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAACDVBMVEVjYGAEBARraGhtampm
	ZGRhYGBfXl5eXl5fXl4NDQ1fX19fX19eXl5eXl4oKChRUVFwbW0XGheJh4eRj4+CgIAiIiKU
	kpKXlZWbmpqfn5+ioqIZHBqop6eCgYEuMy+rq6uurq6vr69SVFKLi4uoqag3Nzg7Ozs+PUA+
	PkGYmJigoKCnp6eqqqqrq6usrKytra05OTo5PDmRkZEyOzQzQzempKSurKyxsbG2tbW6urrA
	wMAcHB3FxcXLy8vPz8/S0tLT0tJeXl61tbUgKSInSC8oKB4sLy0wMDExMTExMjE0dkNLSSVn
	ZClpcGtra19xbS1ybi5zhXZzlnp4eHh5eXl7emV8fHl9gH1/f3+AgICBgGuBgYGCgoKEg3CF
	hoWJiYmKioqMjIyNjY2Ojo6Tk5OZmZmampqcnJydnZ2fn5+kpKSlpaWoqKiurq6wr6+wsLCy
	srKzsrK0tLS1tbW3tra3t7e4uLi5ubm5vbq6urq8vLy9vb2/v7/BwcHBwcLCwsLDw8PExMTE
	xsTFxcXFyMbGxcXGxsbHxsbIyMjJycnKysrLy8zNzc3Nzs3Ozc3Ozs7OztDPz8/Q0NDR0dHS
	0tLT09PU1NTV1dXW1tbY2NjZ2dna2trb29vc3Nzd3d3e3t7f39/g4ODh4eHj4+Pj5OPk5OTl
	5eXm5ubn5+fo6Ojp6enq6urr6+vs7Oz///8yXVsIAAAAQ3RSTlMSHR8hKTE4P0VISk5RVFVV
	WmKPkZeYmaGor7W3ury+vsHExcXFxsbGxsbGxsbGxsbHx8fIyeHi5Obo6uvs7u/w8PHxjP3u
	2AAAAAFiS0dErrlrk6cAAADNSURBVBgZBcFdTsJQEIDR+WampT9iQyBNDDHRV7fgct2Vvvis
	NgYR5LbcO56D7IZaXSJUcmk+j66Pz5uNhCCSl+ny4lCOr7fEd6en9VDh0Cuhy5U80xRzkP5p
	KeyF4klR0Dx+5XPq0mpDh8O5bsdhmu4fbDo1ODr06Y5mW19THmtcaW/UxBuZi7WmDqaVi4hE
	SbObwiGrAmrYT8FhbA0IwfNWcdX3fl0ZhKS/38484m1VWWqJSDNL8WXOy5zTASGXOiXY7S8S
	BRHplY/jP3c7WDhrbzSyAAAAAElFTkSuQmCC
}]

set home [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACTklEQVQ4y42SX0hTYRjGf2dn
	c27TtYyW9kfR4ZIyTbqxVibD0K6EIi8aSBC1ILoRuvEiwroLKqobbwO7MLqOCIYFI68i+0O2
	UFshaAdlbmeebWfnfF0ctlxi9cEL3/u+z/u8z8P3SfznGR8f3w70AWo0Gn1eqtu3GnBHrvvq
	QqHHAKvx+DDQF4lEJpPJJID0VwLvlduhHcf7nrh3NTUCOLz1M2+S088GVZVcLleBlf7YKrsa
	W0d9h7tHbUjVmKbVsMnYRJGhqlUG6l2Ejh2VNhH0jIy1fPW1TFTvC3SLvLXFoa0hmQYFTx1I
	IFVV07Ayj2NxruXVvRsLADJA7eWxgUxD6wuHu6bVyKQwNJX9ZHjU38mFjkY+fknwI6UitCxp
	2c1PR+2wFOh4V3g7NSd5L9285trd/AA9D0LgxCB6JMDFE13Itt8OJ6Y/cDc+S16SQZLA4WR9
	ceGq7Ow6OSLp+XYzp9Hmc/LwTA/97QEkQAhRjkN7/PQ2+5mZ+8bySgpTy2Lqekq2t3froqj3
	nj2wV7t//rTH7/VUDG6MOo+Lwc4gyvKS8v77UtooFu6UNcZisclgMHiulCufXuKs0gHIFxzs
	PHiqbCeRSDwNh8NDFf9ACIFhGGVQbv41Na4MAGtaLUZbmI3YTR9JCIFZendgfT1HOp+17oaj
	orclwUYF2bSGMFWLwOas6P2XAjWjUdAsCwWX+98KVFX9rOs6drtV0rJ5cmnLgjDz5aFisYiq
	qrObCBRFuaUoShzYBrAoN1F0+y2Q7KI4NVWCrgGxUvILke4icR6zyMgAAAAASUVORK5CYII=
}]

set visited [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABYlBMVEUAAAA3Nzc4ODg/Pz8+
	Pj5AQUBAQEBQUFBRUVFcXFx/f3+AgICBgIGBgYKRkZKSkpKSkpKTkpOamZuZl5mgn6Ghn6Ka
	nJqcnZu7u7u7vLu8vLu8vry9vrzc39rc39vd4Nze4dyEwGiEwGmFwWqczIadzYfG4rnI47wA
	AAAqkgAqkwArkwAtlAAvlQAvlQEwlgEwlgIxlgMylwQylwUzlwU0mAY0mAc1mAg2mQk4mgs4
	mgw8nBBAnhVCnxhDnxlEoBtHoR5Ioh9LoyNPpSdQpilaqzVgrjxhrj1irz5nskVoskdxtlFx
	uVFyt1JyuVF0ulR0ulV1u1V2uVh5vFp5vVp6vVuAvmOAvmSEwGiLxHGQxniRx3iZy4Kk0JCs
	1Zqy2qC026PH4rvU6crV6cvW6s7Y69Dc7dTd7dXe7tbh79vl8d/n8uLo8+Lo8+Pu9uvv9+zw
	9+32+vX3+/X6/Pn+/v7////HWH9cAAAAKHRSTlMAJCQtLi8wRUVGoaKipLi4ubnf4Onp6+vv
	7+/v8Pz8/f3+/v7+/v7+Xc8I0gAAAAFiS0dEKL2wtbIAAADHSURBVBgZNcHbTsJAFAXQvc8M
	HeyIlyDigwR/xQ/3V1SI0aCWPkAJnXbOsYawFiEFcabJ6GPpDCfsD40P189Nxj/T0eSl92G8
	2goGFifbqjyI050jKQzLxWWtFLEWRph/muXUq/OmGM3jW7eYtZ811Txok3sXpnN+bASEB9QF
	9xjD14YYeBhNywf7XmcCBqHQEvn7fiQAoSjDPqWf9R5mNpbss1xVq6qpnQF6szPfpeVdl2+n
	GPj42rKIF2I4YX9sCCmIM032BwgaXN87aLGBAAAAAElFTkSuQmCC
}]

set desktop [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0
	RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAOCSURBVHjaYgzf95fh189fDMy/
	/zBEcz5nOHflKcNpYX2Gjwz8DL6vsxnSPs1k+PHnPwOnKlOOoHVu/cSO67OL5u5q+M/A8IsB
	CAACiIUBB2D//4VhC3crgwDjZ4bUX0s5/6r8y2F4NEtE4iOvHVAzFwPUAIAAYsJlACPDf4Z/
	jBwMm5nyGd7IcHiz8bKq/73J8b933+vlQOnPEFUcDAABhNMF/0GG/P+p+Y1JJJhBTtSf4S8z
	w6FzP66cffd/B1DqLwMDD5ASZAAIIAwDfv36y/Dzz39JRqZ/WYqCHNnGfLcEhSQkGRju/P/f
	t/P8SqDBjyA+EGZkYPj9HyCA4Ab8//+fgZGRwUVTScRESeRXkpIQm6o8/18GkV+HGViZhBgu
	PRb8e+jnh5sMDPd/AzUDTfjPC8S/AQIIbMDff/8Zfv5lDOYQ5l8RbSXH8vvXb4bvv5kYfn+6
	wyDA8paB4Yskw5p3dixCoRUdv9eVfPvx/OxJYDCDDPkLEEBMf/79NxLkZl7rqcu1mlWQk+Xr
	d6Dmv0wMfxiYgOb/YvjH5MLw4Kk2w9nXUgxs/9mVpTzrFnFKmTkzMLx7xcDw9g1AAABBAL7/
	AjAcArxyOAVSPB0BAfYGCQDn9v0ACQYCAAcHAgD29v4At7XfAO4HOAA/LhUA/fPwAPv9FBMU
	TZOZCB89QQAA+/YCiFneJT7AWEtA5i8wVt/8ZGL4+u0PgwIPMHyAAcLIxMbAISjFwCupwGCk
	yM3wFBh5527/Z/j6noFDxjLM99vj4xcBAgBBAL7/A9S4qr3rGUQ2ICMYHQX+AADk8wEAFgX8
	ABYMBgAHCwwAFRkWAA0JAwAKCAMADgT6AMjd9gAwNh0AICIUB9nFs9cCAEEAvv8BAAAAAAMN
	FxhDhrSoVU0zP/r3AAAU/PUASR4AAOXt9gDe6PcAzt72AN/s/QAKEw4ABw4SANHL0d7GpISf
	9uK/qQKIERaNzLyiwmZl6xb6BVl7s/76z/DqyQeGu4+/MLwFuoiZi4+BF6j5/b0bby6u7lr8
	4fKaZQz/vlwBavsBEECMyImImVtEUC91xgzn0KCw3z+A3nkNjChmBob3z959v7que8OrE3Pn
	MPx8cwqo9AtMD0AAYeYBNh5OjZQliypP/PvvNPPHf5ngmTtZBFSCQUkPm3qAAMJhCjO7oH5Y
	GaesWRqQJw1yHC61AAEGAA9ENHUsc2BpAAAAAElFTkSuQmCC
}]

set arrow [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAA3NCSVQICAjb4U/gAAAAHlBM
	VEUAAAD///8AXZQAXZQAjMAAmc8ApNoAquQArugAr+m41kPiAAAAA3RSTlMAALOoHiboAAAA
	NUlEQVQI12MQhAIGohhCxkCgCGQIzwQCQyBDwKK9ohkkJcCcGmYAZjCYODNAGMwGjMSaDAUA
	ATwNm5T/5i8AAAAASUVORK5CYII=
}]

set folder [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
	ZSBJbWFnZVJlYWR5ccllPAAAAhpJREFUeNqkUz1vE0EQfbO7ZweDUQgECptEFEih4ENJREsT
	aCkokBCigSIFDf8A0dKAhKyEhgaUNg1CpEFCokzg4gJkJAcjJJtggn2W75zL3S6zd84X0CCP
	dLq9nZn3Zt7MkTEGg5jAgKbK8zOLOgqvGh0nFyQkSKoykTjHX/ujqX9DhG2fssnnZ58BW1Ea
	JCVWntw4yyCG6A8ATiIhIFTmExOdSQCM1py8ibDyEMYQnMI1TM4+5+b6yRZkG8i+lIJbujUh
	SUzx/bJKHKbLjgPsl4jWX/HFyySWGMTEGkHH75dukClc53iDjh9ezB/MWgB2xT6EM8RHaYvc
	YdasS+Wdi6DVsSzs4YnRfQipkHOcEuv2IAWgTUuHoB0g6TulQ22lgtGxERy/WQISkU36WL+T
	gTt3+5iyZSLy8Pmti+4vb1cv1mN86jSOFI5iq/qIq9ZJ6RZA5ooIxQSa7XBJWWa/vsbKAtP3
	FriduK+WRPy1BG14VSiTlp8AawYYR+vjKr6s914onjc69RoOF3kq3Sp0c4lDRQois3zau2us
	AzHT0CH8rLq48/jDYtJCu/ENxelL3EodlM1zqtgd4T5jAGcEfmMN3xvN16vzM56yQcFGC7lT
	J4FeiwcxjL82cK9lh7Gx/B61H72FE6NM5s5d9nhgeR3FsEtldjbm32aLMiTak3ffjJWfXvFs
	5IVEsf8zu/duulsD/s6/BRgAq8u/ourCQ6kAAAAASUVORK5CYII=
}]

set document [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwY
	AAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAA
	F2+SX8VGAAABl0lEQVR42mJcsWLFfwYKAEAAsYAIbuVwhvcfGRi+/wTiX1AaiL9B6Z+/UDX9
	A1opLsrAoM++kgEggMAG2OswMHz5xsDwHyjx9x8U//3P8AeE//xj+AfUAcL///8DYiAbiHl5
	uBjOH2VgAAggsAG8HBCMCoCmATWA8L//f4EUUOPff2DN/4BibGzfGc4DVQEEEAs2f4FtAWr4
	+xdi4///jFD+f4Tcv79gtQABxIRdM0wjKobJ//79G64eIICY0DUjK4RhZANBmkF8ZmZmsDqA
	AGLB5gJs+O/fv2AMYoM0wwwACCAWfBph4iCNf/78AfNhGhkZGcE0QACBDfj16xfDz58/GZiY
	mHA6HyQH0wT2O1QtQADBXQBSCMLoAKQJphhmGLILAAKIBeYsmNOwAZDib9++Mezbtw9DDiCA
	mGAGgGzBhUHyMNeFh4czBAYGMuzfv39SREQEB0AAsaD7CRtA9v/r168Z8vLyWoGZsA7kK4AA
	ghvAwcGBN9fx8fGB6bCwsJwDBw5MhYkDBBAjqdkZ6AVG5NgACDAA4TMV4APib38AAAAASUVO
	RK5CYII=
}]

set ok [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACp0lEQVQ4y42TT0gUYRjGn2/mm53Z2XHdXbc1U9HV/kiB
	JZZ0COoSJIKhYVaHLtI/KDoUBUV2KKIiIsqrh6jsz8WQDtalTkEURVoGIbGs7j/Ndt1dd2d2
	5vu+DlERFfqeXnh5Hl54fo+MJYykU7irDdXXsIzZRQvcZL9u8lIM1CoP9DbfHWNtsJ/bdq3k
	kUuhlppY7kta0KUYyG6pMrStoaulb6dWx8LN5F3yzPiT5zFAnJAWFWsUvqbg8aqeJk0mCrwu
	L9ZvbIM/GPRnW3KRRT8oa6qoUbeWH5MNBQIClmNh8NrV9As6ultqk95QAFBUBXrAAJM5mMVQ
	nM0DAPRqL8gKcim4v85gsGGxPO6fuxiLhD+1Q8eE3k8ZDW6uoQS806GsVTNUTRDpgTQmvy7l
	LahhvdnXG9onFA6bm3h7fTiTrI10MG5/VM6CLyzkQfOzmd5Al+9uoN0PYgBz9+YO8km+zu3x
	ROlyesHY4ZcZL2Fq8H0xoUR2sXL2QT+v8OzXDGALyGWNgUnmWAeMTYYHLgJttebKxvMpl6ES
	o8d72dXoJumHCTs2G9krtcrP5FMlVpxegGDiByOFz/NF5NXbPMsAR0DySOCErbF95g19i0Hm
	R2ZYfDraJzaQEXa6wHiKg3P+OyXBOKiszBCvOKSGNQJKkB1Krwr1VdU7sRKSrxIn0UkH+eEC
	41EGZjl/UsodDl3Tx4oTxThMALZA5dEqg1ZQJIZjQ6KX3pKvOAwZAlHif8UsAYAtO8LJiHdY
	EIAJqLUupAbiY6JHOSI/YtwczQuetf/dEwD4NpaCE7VfOnEHIieQHEjErXZ0+01/QTxmHOL/
	oJGfS3XHyvpcbnZcECSsPeh2pkoT4qbFFUdBybQWN/DWBWAxKwgJ82y7YPQpuDldWLRo3wEp
	ZjhR3++h3QAAAABJRU5ErkJggg==
}]

set cancel [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACnklEQVQ4y41PW0iTART+/n9e9q85MXPadHM63eZcKiVO
	DTcMUzEduiC0BxWXYD5ISQ9RT5bSAh98iR7SdPYQGAXqg6YkBaKI4SVSo6ALmjek7fdKc9vp
	SbGxpO/tnO9yzscAAMcw9y6LRFUsEfjAIOrlnWUApuGDADBll0SiNmVEJHhpJLomxysOOE21
	RLLdL5XSbFISlUbJpgEIffxqa4SMn9Tracdmo0yNdgCA4JANZJjrdkUsLaak0LLRRAqRuO2I
	mTsfFjn1NiWVfttsdLu6ZgmA1PdDaESi/k9pabSfk0PDhmw3C6YAAGKCTrS/Umtpq7GRhp50
	uFmGzcM/ILsWJVtbTU+nTZOJauXKlWBGcOuRTEmrViutDA7RaWlUE46DAIylOynZ+7m4mMZK
	zNSsUNJqXR25JyboYo5p9K/evgMAELAwsb0dbQg7eU4iCUGhPAbhFgvu9/ZtPH3Rkw/Aif+A
	2CKLWxs1Gmm/oYEWuuzEsmyNPyHrbxnAMMWZEk4a6nJBoNNBLY9BYdrZGn96gR9/YrU8tq8k
	USXUabXYiVdBxLK44PEoumc/0K7b/e64AGF2WMTrGwlxSkNRETqX1zdbX/Z9vMKQLOTbV6jF
	kuyen0sjABb9Fo8K5h73JJ8hZ309zbR3erlgYTmAhIcqHf8rI4M8eXlUG5/wBYDYX+/y1kQN
	/TCbaevNCGlV6o4DjhMEVgzoU707WVm0WVBI6pDQDl+/xhot5+dyc8nT20tXzaVzALijgmRx
	6PPvGQbyVlbSeGWVN4BlLYcHssJPTc3k55O7pYXszQ92Aej9NAy/qdIuempriex2umuxbACQ
	CQCUmhTx5nWvd3PY4eCbnnXfce27Bv0E7L13OhZ2AeO0w8EzHLc/Nj+/9weRl/0oDhMDQgAA
	AABJRU5ErkJggg==
}]

set iconCancel	[fsbox::makeStateSpecificIcons $cancel]
set iconOk		[fsbox::makeStateSpecificIcons $ok]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace fsbox


bind FSBox <KeyPress-Up>		{ TreeCtrl::SetActiveItem %W [TreeCtrl::UpDown %W active -1] }
bind FSBox <KeyPress-Down>		{ TreeCtrl::SetActiveItem %W [TreeCtrl::UpDown %W active +1] }
bind FSBox <KeyPress-Left>		{ TreeCtrl::SetActiveItem %W [TreeCtrl::LeftRight %W active -1] }
bind FSBox <KeyPress-Right>	{ TreeCtrl::SetActiveItem %W [TreeCtrl::LeftRight %W active +1] }
bind FSBox <KeyPress-Home>		{ TreeCtrl::SetActiveItem %W [%W item id {first visible state enabled}] }
bind FSBox <KeyPress-End>		{ TreeCtrl::SetActiveItem %W [%W item id {last visible state enabled}] }
bind FSBox <KeyPress-space>	{ TreeCtrl::SetActiveItem %W [%W item id active] }
bind FSBox <ButtonPress-1>		{ TreeCtrl::SetActiveItem %W [TreeCtrl::ButtonPress1 %W %x %y] }
bind FSBox <ButtonRelease-1>	{ TreeCtrl::Release1 %W %x %y }
bind FSBox <Button1-Motion>	{ TreeCtrl::Motion1 %W %x %y }
bind FSBox <Button1-Leave>		{ TreeCtrl::Leave1 %W %x %y }
bind FSBox <Button1-Enter>		{ TreeCtrl::Enter1 %W %x %y }

bind FSBox <Motion> {
    TreeCtrl::CursorCheck %W %x %y
    TreeCtrl::MotionInHeader %W %x %y
    TreeCtrl::MotionInItems %W %x %y
}

bind FSBox <Leave> {
    TreeCtrl::CursorCancel %W
    TreeCtrl::MotionInHeader %W
    TreeCtrl::MotionInItems %W
}


####### T E S T #############################################
if {1} {
	set filetypeScidbBase [image create photo -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
		CXBIWXMAAABIAAAASABGyWs+AAACH0lEQVQ4y11SLW9VQRScc9++fpJAQgCBAomChB+AoAaN
		QPMLcPwFHBaDQFGBIBgUAkGCAkJSQQWFUEQb0kLfe9y9ez4GsfteW26y92ZvMnPmzIw8e7N1
		7cvuwePDad7IxWRQw1AMuSiuXDqLR/dvYX1lCSRBEhEBAArg+Ww2e5h29o4eHEzy7WlfpJih
		qKGoIxfFoIYIYv64O8wMZjY2s3vDMHxNe4fT69N+6Io61B3mAXOHeyCiTvz/uDtUdcnMNtKs
		L6NcDNbAahXsDexuMO0Q5AIcEfN1VlNWk6K2mGoesAgE6zRVgyZpAMLdF4ckUil1b2uSfSGV
		CBKqCh0BJBakcxURgdQXRT9o/UGADegR1Qc3uMuJFAhGACBEiHTn5tXjfefs7vAIrC0lfPp2
		ABFp5gbMrJptdQUppXwYj8c3IgKmiqIKLQVmih+/pth8v4tJr8hqyENVm4d6T5187AAsChJz
		me1LokoGgVYHaS9p3ejIY2fjZESNdDCHWpVf460Gk5UxkYSZnYrH3cEgPIhcDLkYzBxqtSve
		1AaJNAeHBzxOEtR7bjt7BEojmbd0NBak7Z2ffy9fPAcAp6qKFlkuBbkYPNhSqAl1ApxZW+67
		1++2Xm5/3z8aNKBOqpNOYUjHgNCD9CDZnBURptEI66vLf5ZT2kyv3n5+sj8Nv3B+/y6DKxEG
		6Wr1fk8myIOi+YWuE4gIuk76NOpeAHj6D9V8jTqtYkCiAAAAAElFTkSuQmCC
	}]
	set filetypeScid3Base [image create photo -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABy1BMVEUAAACAQEA5HBw5HDlN
		MxoUFDtJJBKAQCCASiBLJg85KkBKJRWARSCASCBMLBYlIl4kIWBJKBR9RSAnIGB1Qx4iHlk9
		JCBrOx0/JipIJxN2TBllOhomIV5wSB8mIFwkIV9IJxOWcCiDXSORbCZsPRx/WiCMbiVcNheZ
		eSenhiuScB+VbxkkIV9NKhQlIV9HJhSphixGJhNKKRNAJzNINkbLpx62ly60li89JShIJxNH
		JxPkuhi4mi4nIl1zX0DvxRUqJV/vxhMmImEqIlYrI1YwKl0wK10xK1wxLF0zLVs0JD80Lls1
		L1s8NFhANlZBJB9CJRxCOVdIJxNPRFFQRFJTRk1ZS01ZTE5dTktpWEdsWklsW0VtW0RuXkhw
		XkR0YkB6Zj19aEKAaj2CbDqDbj6GbziGbzuRej2VfjiYfjecgTKehTSfhDaiiDOojDapiy+s
		jzSskDSvkzOxki6ylS+2mDC4mzG5mCi5mS+5mzG6nDC+ny7AoCrDoizEoyvJpiHJpynKqSjN
		qiPOqyTQriXSriTVsSLXsyHZtCHatBzatSHeuB/huhrjuxnjvBfnvhnovhnpwBfuxRbvxRbw
		xhb2yxH4zBL5zRH////A4/h4AAAAQnRSTlMABAkJCg0OEBgiJDAwQEZMTU1gb294gYWGkZGf
		oqapsbG0tbW5ubq8vL3Aw8zNz9DS1NbX2N7j5Ovt8PX3+vv9/v463iK3AAAAAWJLR0SYdtEG
		PgAAAOlJREFUGBkFwYNCBEAUQNEbNtu222zXZNdk23a9jM1ua363cwCAiDpjHkRODQDgnba9
		b7u5t93ZAcAhulKGlp9mPx4FAIKKbNfng6tfwxsCgFvmrzE/ux0rx517AIRWGGOeNxvnrxYH
		ALwyPu1/Zqll8uCsbwEgskR2JnrHj25n2qffgICUw9HWkcvXsa6p9RMB16Ti/qa1i63mufdv
		EQGf/AJVmJhbW11jXkQEPHWD6tFtqjQrNTkhPh0cw1RVXnm96tZaa62BQJXt5KFUSHhcTpnW
		QKyKwU8pC+Ds7u8CUdZgfK1WCwDwD3trP00R9KcNAAAAAElFTkSuQmCC
	}]
	set filetypeScid4Base $filetypeScid3Base
	set filetypeChessBase [image create photo -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACQUlEQVQ4y62ST0tUcRSGn/O7
		944zXkVnKnJmrLmSSRslIr9C2Ub9CCW0lITWEiTiLqggXSYuQslaVB/CdKRwUbbyVgsXNTVz
		J2nuv9NCJYVa1QvncDbn5X0OB/5RAuD1ntHZuTl6ikVuT01x78F91tZe82R+nusdefKWhR7f
		axHHSxPv3t4UgMXHi+r7O6BQKpXwfZ92t51T2Ryy8gxp/gCR3+uqINKa2KpmDYDneSRxgu/7
		lMol6vU6QRDgVSq0ZxyM6p/StwEYgFuTk3iex9WREWbvzjA6Nkqp3Mud6WnqX2s4Ihj07zfY
		WF/X1aerBEHA2Pg4K8vLlHvLDA9cYO/hI9JGQGSESARFDhGY2KqKDbBRrdJdKGBnMrzf3qbS
		10eSpvi+z+k0xUJBBQVi0WNZDMDSzCzns1muDQ3xcn6BK4OD9LsuzxcWCOsNMirYqjiq2HoQ
		+yjCZmVAc52d4Dh8CRrkurtpJQnfm00yxpAYQ4gQGYhECBESEW4cIvQoRI2ASOCksQhr30CE
		E8YQKkSqqMBB20c4iGED2JqiIqgKmiaoCBiBVFExKPv8mIPZwOEhbABLFXv4Mm2FPK2Pn/hZ
		q2GJwUJxK2cxxR5qm28IVXEEwjhhrxn8NkAMVqmI5bo4ly7i2jZRo0ESRkghD50d5PrPkaqi
		jkN9x8d/8eqIQZqQ7vhIVxfq+6SuSxpFpI5D8rmNGCURQxxFpLZNa3cXhyMIuC7p9gfCMCSO
		YxLZf5pjZYRQDJFALAa1DP9FvwCukf19pHFc/gAAAABJRU5ErkJggg==
	}]
	set filetypePGN [image create photo -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADb0lEQVQ4y12TT0xbBQCHv/de
		y2tf6dqOP22gCBzIQLCJwsoFSDAOOLioyYwsJsboWY03F81MjImJUfDMwYSxg4cxwqZjiRKY
		ZoJM/IMT6ypUcIRS2kFfy3uv7w/Pg1mifqff4fsdP4H/sba29ojruq9UjMqTgiC0+HwyPr8/
		4zjOV6ZpfppIJHb+7QsPx8LCgqjr+sXc3t5b0WhM3traYvHWIgBnnz5LIpHAsi1d07T3/H7/
		h93d3ccAIsDk5KSYTqcv3/lu5d3+gQG5r7+PeFMcRVHw+/2EI2HiTXFCoZBf1/UPcrncxMTE
		hADgAdjP5S5kMpnzj3Z2ks1myefzyLLMwMAArutimiZLS0tomsb21jZtbW2vejyeX4FxYWxs
		vGFleXnjtTde9xUKBebn54lEIiSTSYaGhnBdl6mpKebm5jBNk9HRUZqbm0nfS5eze3utYjqd
		fjkej/sURUGWZQC8Xi+Hh4eYpollWViWheu6GIaBbVlIkoTf76/O5/MvCsNDw182NcWf6u7p
		IRKO4DgOgeoAxWIRr9cLQKVSQVVVdF3HcRx0TcesVLAd55oUrY++c/eXuzWZzQzNLS2cGTpD
		LBYjlUoxMzPD+vo67e3tDA4O0trayo0vbvD59euk02lisZjmsS3LtSyLTCbDwcED8vk8oihi
		2zaiICBXyZimSalUwrIsNO0ITdMIBoMUi0WE3mTvzce6uoYlSUKSJJzjY2RZJhQKIftkcEHX
		NdSiilGpIAgCggBV3ipSv6dmRFEU5uvq63nmuWfxer1cnZ7m2uwshUKe5OkkyeRpdnZ2mJ2d
		5er0NLW1NZw79zzBYBDDMObFUCh8+dvbt48URSFy8iSBQIByuUxJLaEWi6hFlXKpjGEYnAiF
		qKmpxeORWFxcVJVA4DMBoKe75+329lPvd3V1oSgKRqXC7u4u2d0sggCNjXGisSg+n49SqcTq
		ne/JZP58c/XH1U8kgAeHxorI8SmPx9P5wvlROjo62Ll/n+WlJQ4ODujr72NkZITGxkamr1xh
		Y2Pz0g8/py7iWo4EYNu6kysc3SyXVPmbr289Lkmix3VddMMgHAnT0NDAb+vrjH88pm1mtj+6
		98dfF2xL1f9T4z9tKr7auponTlT7XqrySL2SJNW5uDi2s2fZx8vqkXEpv7//E65ReXj5Gx20
		nJFFtL/NAAAAAElFTkSuQmCC
	}]
	set filetypeZipFile [image create photo -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACg0lEQVQ4y8VTzUtUcRQ99/d7
		b0ad8WNEKc3GSkdwIWZhWH6k4dgiSgIXQQQJQVSLkBYGpW6rRZ8LQ4gwSaKQIiTJSsoPtDSt
		xtSaUiTzY/QlvplxHGfe77UY1Owf8C4P595z7rlcYKOLeq9cz7Udsp8izldBZeQ7em/fQV7N
		GXRU34Vncm5dkxQR3nDS0d0GAPS2spoS9mUHSVEY+3eIcxSukQFs3rMNzmd98EwurKkS+aQw
		Y2n5cO8r+vzgUVpsUe632bYO+Ho+CSbLOhERiABdpyX/H8iJflIcCgJuBiIGMALj3BdtTTrK
		y+KTKqIy0guMKclY6Osi2xEv87kYBX2CAI0kbiBryUEkZGVCV7wwx1pgtlhgiomWNdV9QCqu
		u3l5ID/noiElmc+P9UB1Khh8asaym1Yta7ZIhAU0OJ63rA8QNC7dqGvLjytM5WOt7ZhI2KvP
		OyUsZhlBRMQI4OEMhpgIABxkPwzOJBARGBFUg7lFej/0u6AgOxGJ+3PQ7AqnE/ZBdA5lY94d
		FVLRl+DmowhqhKmMEug6g9B1MCIsuH3nCADuP+4Kpm018au1jSgv+ohLD3Oh+owgEGTSUH94
		Gl9dHDWd8f+tgG7pWk9jevEWK3/yZhC0Q4imqV16XKYJ8UTEQDCCSKizZDZGYmfhdhARVtLR
		TctNUut0f7k9LhOleTaoqf3suNWDLx4T1KAhxBICw7Uq5N2bcCzHFIJ0gBEw4fVXSK/HP1RW
		kSGqKrXs9Muf7UgPuHDhhwVzAQ4QIAsdDcKPe1MOvHjngCbEin3InM9ION+uN9/CWZdXmZG0
		GWvDrwAmFoMAgiGiAGQS0ASgibXT6gCWNa1+w58RfwHx5/Q7dmRBnQAAAABJRU5ErkJggg==
	}]
	
	set filetypes {
		{ "All Scidb databases"	{.sci .si3 .si4 .cbh .pgn .pgn.gz .zip} }
		{ "Scidb databases"		.sci }
		{ "Scid databases"		{.si3 .si4} }
		{ "ChessBase databases"	{.cbh} }
		{ "PGN files"				{.pgn .pgn.gz .zip} }
	}
	set fileicons [list         \
		.sci	$filetypeScidbBase \
		.si4	$filetypeScid4Base \
		.si3	$filetypeScid3Base \
		.cbh	$filetypeChessBase \
		.pgn	$filetypePGN       \
		.gz	$filetypePGN       \
		.zip	$filetypeZipFile   \
	]
	switch -glob -- $tcl_platform(os) {
		MacOS - Darwin	{ set scidEncoding macRoman }
		Win*				{ set scidEncoding cp1252 }
		default			{ set scidEncoding iso8859-1 }
	}
	set fileencodings [list \
		.sci {} \
		.si4 $scidEncoding \
		.si3 $scidEncoding \
		.cbh cp1252 \
		.pgn iso8859-1 \
		.gz  iso8859-1 \
		.zip iso8859-1 \
	]

	proc GetSize {filename} { return [::scidb::misc::size $filename] }
	proc SelectEncoding {parent} { return utf-8 }

	wm withdraw .
	fsbox .fav \
		-defaultextension .sci \
		-filetypes $filetypes \
		-fileicons $fileicons \
		-sizecommand GetSize \
		-timeformat "%d.%m.%Y %H:%M" \
		-selectencodingcommand ::SelectEncoding \
		-fileencodings $fileencodings \
		-initialdir /home/gregor/development/c++/scidb/tcl/Bases \
		;
	pack .fav -expand yes -fill both
	focus .fav
	wm geometry . 650x600+400+400
	wm deiconify .
}
#############################################################

# vi:set ts=3 sw=3:
