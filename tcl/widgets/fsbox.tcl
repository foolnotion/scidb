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

package require Tk 8.5
package require tktreectrl 2.2
package require toolbar
package require choosedir
package require tcombobox
package require entrybuttonbox
if {[catch { package require tkpng }]} { package require Img }
package provide fxbox 1.0


proc fsbox {w type args} { return [fsbox::fsbox $w $type {*}$args] }


namespace eval fsbox {
namespace eval mc {

set Name								"Name"
set Size								"Size"
set Modified						"Modified"

set Forward							"Forward to '%s'"
set Backward						"Backward to '%s'"
set Delete							"Delete"
set Rename							"Rename"
set NewFolder						"New Folder"
set Layout							"Layout"
set ListLayout						"List Layout"
set DetailedLayout				"Detailed Layout"
set ShowHiddenDirs				"Show Hidden Directories"
set ShowHiddenFiles				"Show Hidden Files and Directories"
set AppendToExisitingFile		"&Append to an existing file"
set Cancel							"&Cancel"
set Save								"&Save"
set Open								"&Open"

set AddBookmark					"Add Bookmark '%s'"
set RemoveBookmark				"Remove Bookmark '%s'"

set Filename						"File &name:"
set Filenames						"File &names:"
set FilesType						"Files of &type:"
set FileEncoding					"File &encoding:"

set Favorites						"Favorites"
set LastVisited					"Last Visited"
set FileSystem						"File System"
set Desktop							"Desktop"
set Home								"Home"

set SelectWhichType				"Select which type of file are shown"
set TimeFormat						"%d/%m/%y %I:%M %p"

set CannotChangeDir				"Cannot change to the directory \"%s\".\nPermission denied."
set DirectoryRemoved				"Cannot change to the directory \"%s\".\nDirectory is removed."
set ReallyMove(file)				"Really move file '%s' to trash?"
set ReallyMove(folder)			"Really move folder '%s' to trash?"
set ReallyDelete(file)			"Really delete file '%s'?"
set ReallyDelete(folder)		"Really delete folder '%s'?"
set DeleteFailed					"Deletion of '%s' failed."
set CommandFailed					"Command '%s' failed."
set ErrorRenaming(folder)		"Error renaming folder '%old' to '%new': permission denied."
set ErrorRenaming(file)			"Error renaming file '%old' to '%new': permission denied."
set InvalidFileExt				"Cannot rename because '%s' has an invalid file extension."
set CannotRename					"Cannot rename to '%s' because this folder/file already exists."
set CannotCreate					"Cannot create folder '%s' because this folder/file already exists."
set ErrorCreate					"Error creating folder: permission denied."
set FilenameNotAllowed			"Filename '%s' is not allowed."
set ContainsTwoDots				"Contains two consecutive dots."
set InvalidFileExtension		"Invalid file extension in '%s'."
set MissingFileExtension		"Missing file extension in '%s'."
set FileAlreadyExists			"File \"%s\" already exists.\n\nDo you want to overwrite it?"
set CannotOverwriteDirectory	"Cannot overwite directory '%s'."
set FileDoesNotExist				"File \"%s\" does not exist."
set DirectoryDoesNotExist		"Directory \"%s\" does not exist."
set CannotOpenOrCreate			"Cannot open/create '%s'. Please choose a directory."

}

namespace import ::tcl::mathfunc::max

variable HaveTooltips 1
if {[catch {package require tooltip}]} { set HaveTooltips 0 }

array set Options {
	show:hidden	0
	show:layout	details
	show:filetypeicons 1
	pane:favorites 120
}


proc fsbox {w type args} {
	variable Options

	if {![namespace exists [namespace current]::${w}]} {
		namespace eval [namespace current]::${w} {}
	}
	variable ${w}::Vars

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
		-savemode					0
		-initialdir					{}
		-initialfile				{}
		-showhidden					{}
		-defaultextension			{}
		-defaultencoding			{}
		-filetypes					{}
		-fileicons					{}
		-sizecommand				{}
		-validatecommand			{}
		-selectencodingcommand	{}
		-fileencodings				{}
		-deletecommand				{}
		-renamecommand				{}
		-okcommand					{}
		-cancelcommand				{}
		-multiple					0
	}

	array set opts $args
	if {$opts(-multiple)} { set opts(-selectmode) extended } else { set opts(-selectmode) single }

	foreach option {	selectionbackground selectionforeground font multiple savemode
							activebackground activeforeground defaultextension defaultencoding
							inactivebackground inactiveforeground filetypes fileencodings
							fileicons showhidden sizecommand selectencodingcommand validatecommand
							deletecommand renamecommand okcommand cancelcommand initialfile} {
		set Vars($option) $opts(-$option)
		array unset opts -$option
	}

	if {[llength $Vars(showhidden)]} {
		set Options(show:hidden) $Vars(showhidden)
	}
	if {[llength $Vars(sizecommand)] == 0} {
		set Vars(sizecommand) [namespace code GetFileSize]
	}
	if {[llength $Vars(validatecommand)] == 0} {
		set Vars(validatecommand) [namespace code ValidateFile]
	}

	set Vars(type) $type
	set Vars(glob) Files
	set Vars(folder:home) [file nativename ~]
	set Vars(folder:desktop) [file join $Vars(folder:home) Desktop]
	if {![file isdirectory $Vars(folder:desktop)]} { set Vars(folder:desktop) "" }
	set Vars(folder:filesystem) "/"
	set Vars(bookmark:folder) ""
	set Vars(edit:active) 0

	set Vars(folder) $opts(-initialdir)
	set Vars(prevFolder) ""
	array unset opts -initialdir
	if {[string length $Vars(folder)] == 0 || ![file isdirectory $Vars(folder)]} {
		set Vars(folder) [pwd]
		set Vars(lastFolder) ""
	} else {
		set Vars(lastFolder) $Vars(folder)
	}

	set Vars(widget:main) $w
	tk::frame $w -takefocus 0
	set top [ttk::frame $w.top -takefocus 0]
	pack $top -fill both -expand yes
	set Vars(choosedir) [choosedir $top.folder -initialdir $Vars(folder) -showlabel 1]
	bind $Vars(choosedir) <<SetDirectory>> [namespace code [list ChangeDir $w %d]]

	tk::panedwindow $top.main -sashwidth 7 -sashrelief flat
	set Vars(widget:panedwindow) $top.main

	if {$Vars(multiple)} { set lbl [Tr Filenames] } else { set lbl [Tr Filename] }
	::tk::AmpWidget ttk::label $top.lbl_filename -text $lbl
	set Vars(widget:filename) [ttk::entry $top.ent_filename \
		-cursor xterm \
		-textvariable [namespace current]::${w}::Vars(initialfile) \
	]
	$top.ent_filename icursor end
	bind $top.lbl_filename <<AltUnderlined>> [list focus $top.ent_filename]
	bind $top.ent_filename <FocusIn> [namespace code { FocusIn %W }]
	bind $top.ent_filename <FocusOut> [namespace code { FocusOut %W }]
	bind $top.ent_filename <Return> [namespace code [list Activate $w]]
	bind $top.ent_filename <Return> {+ break }
	bind $top.ent_filename <Any-KeyRelease> [namespace code [list CheckFileEncoding $w]]

	if {[llength $Vars(selectencodingcommand)]} {
		set Vars(encodingVar) $Vars(defaultencoding)
		set Vars(encodingDefault) ""
		set Vars(encodingUser) ""
		::tk::AmpWidget ttk::label $top.lbl_encoding -text [Tr FileEncoding]
		set Vars(widget:encoding) [ttk::entrybuttonbox $top.ent_encoding \
			-width 14 \
			-textvar [namespace current]::${w}::Vars(encodingVar) \
			-command [namespace code [list SelectEncoding $w]] \
		]
	}

	if {[llength $Vars(filetypes)]} {
		::tk::AmpWidget ttk::label $top.lbl_filetype -text [Tr FilesType]
		ttk::tcombobox $top.ent_filetype  \
			-state readonly                \
			-format "%1 (%2)"              \
			-padding 1                     \
			;
		bind $top.ent_filetype <<ComboboxSelected>> [namespace code [list SelectFileTypes $w %W]]
		bind $top.lbl_filetype <<AltUnderlined>> [list focus $top.ent_filetype]
		set Vars(widget:filetypes:combobox) $top.ent_filetype
		tooltip $top.ent_filetype [Tr SelectWhichType]

		if {$Options(show:filetypeicons)} {
			tk::canvas $top.cnv_filetype -width 1 -height 1 -relief sunken -borderwidth 1 -takefocus 0
			bind $top.cnv_filetype <Configure> [namespace code [list SetFileTypes $w]]
#			bind $top.cnv_filetype <ButtonPress-1> [list $top.ent_filetype post]
			set Vars(widget:filetypes:canvas) $top.cnv_filetype
#			tooltip $top.cnv_filetype [Tr SelectWhichType]
		}
	}

	if {[llength $Vars(selectencodingcommand)] == 0 && [llength $Vars(filetypes)] > 0} {
		set cspan {-columnspan 4}
	} else {
		set cspan {}
	}

	grid columnconfigure $top {3} -weight 1
	grid columnconfigure $top {0 2 8} -minsize 5
	grid rowconfigure $top {3} -weight 1
	grid rowconfigure $top {0 2 4 6} -minsize 5

	grid $top.folder 			-row 1 -column 1 -sticky ew -columnspan 7
	grid $top.main				-row 3 -column 1 -sticky nsew -columnspan 7
	grid $top.lbl_filename	-row 5 -column 1 -sticky w
	grid $top.ent_filename	-row 5 -column 3 -sticky ew
	if {[llength $Vars(selectencodingcommand)]} {
		grid $top.lbl_encoding -row 5 -column 5
		grid $top.ent_encoding -row 5 -column 7
		grid columnconfigure $top {6} -minsize 5
		grid columnconfigure $top {4} -minsize 10
	} elseif {[llength $Vars(filetypes)]} {
		grid $top.ent_filename -columnspan 5
		grid columnconfigure $top {7} -minsize 92
	}
	if {[llength $Vars(filetypes)]} {
		grid $top.lbl_filetype	-row 7 -column 1 -sticky w
		grid $top.ent_filetype	-row 7 -column 3 -sticky ew -columnspan 5
		grid rowconfigure $top {8} -minsize 5
		if {$Options(show:filetypeicons)} {
			grid $top.ent_filetype -columnspan 3
			grid $top.cnv_filetype -row 7 -column 7 -sticky nsew
			grid columnconfigure $top {6} -minsize 5
		}
	} else {
		grid rowconfigure $top {4} -minsize 10
	}

	set buttons [tk::frame $w.buttons -takefocus 0]
	pack [ttk::separator $w.sep] -fill x
	pack $buttons -fill x -expand no
	ttk::style configure fsbox.TButton -anchor w
	if {$type eq "save"} {
		set Vars(button:mode) [tk::AmpWidget ttk::checkbutton $buttons.mode  \
			-variable [namespace current]::${w}::Vars(savemode:value) \
			-text $mc::AppendToExisitingFile \
			-command [namespace code [list SetupSaveMode $w]] \
			-onvalue append \
			-offvalue overwrite \
		]
	}
	set Vars(button:ok) [tk::AmpWidget ttk::button $buttons.ok \
		-class TButton \
		-default active \
		-compound left \
		-command [namespace code [list Activate $w]] \
	]
	set Vars(button:cancel) [tk::AmpWidget ttk::button $buttons.cancel  \
		-class TButton \
		-default normal \
		-compound left \
		-image $icon::16x16::cancel \
		-command [namespace code [list Cancel $w]] \
	]
	set utype [string toupper $Vars(type) 0 0]
	if {$utype eq "Dir"} { set utype Open }
	tk::SetAmpText $buttons.cancel " [Tr Cancel]"
	tk::SetAmpText $buttons.ok " [Tr $utype]"
	changeFileDialogType $w $type

	bind $Vars(button:ok) <Return> [namespace code { InvokeOk %W }]
	bind $Vars(button:cancel) <Return> [namespace code [list Cancel $w]]

	if {$type eq "save"} { useSaveMode $w $Vars(savemode) }
	pack $Vars(button:cancel) -pady 5 -padx 5 -fill x -side right
	pack $Vars(button:ok) -pady 5 -padx 5 -fill x -side right

	bind $top.main <<ThemeChanged>> [namespace code [list ThemeChanged $w]]
	bind [winfo toplevel $top] <Escape> [list $Vars(button:cancel) invoke]
	bind [winfo toplevel $top] <Return> [list $Vars(button:ok) invoke]

	array unset Vars widget:filelist
	setFileTypes $w $Vars(filetypes) $Vars(defaultextension)

	bookmarks::Build $w $top.main.fav {*}[array get opts]
	filelist::Build $w $top.main.list {*}[array get opts]
	set Vars(widget:favorites) $top.main.fav

	$top.main add $top.main.fav  -minsize 0 -sticky nsew -stretch last
	$top.main add $top.main.list -minsize 300 -sticky nsew -stretch always

	bind $top.main.fav <Configure> [namespace code { ConfigurePane %w }]

	if {[string length $Vars(initialfile)]} {
		set t $Vars(widget:list:file)
		set i [expr {[llength $Vars(list:folder)] + 1}]
		set sel 0
		foreach file $Vars(list:file) {
			set file [lindex [file split $file] end]
			if {$file eq $Vars(initialfile)} { set sel $i }
			incr i
		}
		$t selection add $sel
		$t activate $sel
		$t see $sel
		filelist::SelectFiles $w [list $sel]
	}

	DirChanged $w
	focus $top.ent_filename
	return $w
}


proc reset {w type args} {
	variable ${w}::Vars
	variable Options

	array set opts { -multiple 0 }
	array set opts $args

	if {$opts(-multiple)} { set mode extended } else { set mode single }
	$Vars(widget:list:file) configure -selectmode $mode

	foreach option {	multiple defaultextension filetypes fileencodings showhidden
							sizecommand selectencodingcommand deletecommand renamecommand
							okcommand cancelcommand initialfile} {
		if {[info exists opts(-$option)]} {
			set Vars($option) $opts(-$option)
		}
	}
	if {[llength $Vars(sizecommand)] == 0} {
		set Vars(sizecommand) [namespace code GetFileSize]
	}
	if {[llength $Vars(validatecommand)] == 0} {
		set Vars(validatecommand) [namespace code ValidateFile]
	}

	# Enable these lines if you want to reset the column ordering
#	$Vars(widget:list:file) column configure $Vars(sort-column) -arrow none
#	set Vars(sort-column) name
#	set Vars(sort-order) increasing

	set Vars(type) $type

	set utype [string toupper $Vars(type) 0 0]
	if {$utype eq "Dir"} { set utype Open }
	tk::SetAmpText $Vars(button:ok) " [Tr $utype]"

	$Vars(widget:list:bookmark) selection clear
	$Vars(widget:list:file) selection clear
	$Vars(widget:filename) delete 0 end

	if {[llength $Vars(selectencodingcommand)]} {
		set Vars(encodingVar) $Vars(defaultencoding)
		set Vars(encodingDefault) ""
		set Vars(encodingUser) ""
	}

	set Vars(undo:history) {}
	set Vars(undo:current) -1
	set Vars(tip:forward) ""
	set Vars(tip:backward) ""

	changeFileDialogType $w $type
	setFileTypes $w $Vars(filetypes) $Vars(defaultextension)
	filelist::RefreshFileList $w
	focus $Vars(widget:filename)
}


proc useSaveMode {w {flag 1}} {
	variable ${w}::Vars

	set Vars(savemode:value) overwrite

	if {$flag} {
		pack $Vars(button:mode) -pady 5 -padx 5 -fill x -side left
	} else {
		pack forget $Vars(button:mode)
	}

	SetupSaveMode $w
}


proc saveMode {w} {
	return [set [namespace current]::${w}::Vars(savemode:value)]
}


proc changeFileDialogType {w type} {
	variable ${w}::Vars

	set Vars(type) $type

	switch $type {
		dir - open	{ set icon folder }
		save			{ set icon disk }
	}

	$Vars(button:ok) configure -image [set icon::16x16::$icon]
}


proc setFileTypes {w filetypes {defaultextension ""}} {
	variable ${w}::Vars

	set Vars(defaultextension) $defaultextension
	set Vars(filetypes) $filetypes
	set Vars(extensions) [lindex $filetypes 0 1]
#	set Vars(initialfile) ""

	if {[llength $filetypes] && [string length $Vars(defaultextension)] == 0} {
		set Vars(defaultextension) [lindex $filetypes 0 1 0]
	}

	set fileiconlist {}
	foreach {extensions name} $Vars(fileicons) {
		foreach ext $extensions {
			if {$ext ni $fileiconlist} {
				lappend fileiconlist $ext
				set Vars(fti:$ext) $name
			}
		}
	}

	set filetypeCount 0

	foreach entry $filetypes {
		lassign $entry name extensions
		set iconList {}
		foreach ext $extensions {
			if {$ext in $fileiconlist} {
				if {$Vars(fti:$ext) ni $iconList} {
					lappend iconList $Vars(fti:$ext)
				}
			}
		}
		set filetypeCount [max $filetypeCount [llength $iconList]]
	}

	set cb $Vars(widget:filetypes:combobox)
	if {[winfo exists $cb]} {
		$cb showcolumns [list 0 [expr {$filetypeCount + 1}]]
		$cb columns clear

		if {[llength $filetypes]} {
			$cb configure -state readonly
			$cb addcol text -id name -type text
			for {set i 0} {$i < $filetypeCount} {incr i} {
				$cb addcol image -id icon$i -type image
			}
			$cb addcol text -id extensions -type text

			foreach entry $filetypes {
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
				$cb listinsert [list $name {*}$icons $types]
			}

			$cb resize
			SetFileTypes $w 0
		} else {
			$cb configure -state disabled
		}
	}

	if {[info exists Vars(widget:filelist)]} {
		filelist::RefreshFileList $w
	}
}


proc lastFolder {w} {
	variable ${w}::Vars

	if {[info exists Vars(lastFolder)]} { return $Vars(lastFolder) }
	return ""
}


proc validatePath {path} {
	if {[string length $path] == 0} { return 1 }
	foreach c [list $path] {
		if {[string is control $c]} { return 0 }
	}
	if {[string match {*[\"\*:<>\?\|]*} $path]} {
		return 0
	}
	return 1
}


proc verifyPath {path} {
	if {$path eq "."} { return oneDot }
	# we do not allow two or more consecutive dots in filename
	if {[string first ".." $path] >= 0} {
		return twoDots
	}
	# be sure filename is portable (since we support unix, win32 and mac)
	if {![validatePath $path]} { return forbiddenChars }
	return {}
}


proc tooltip {args} {}
proc mc {msg args} { return [::msgcat::mc [set $msg] {*}$args] }
proc messageBox {args} { return [tk_messageBox {*}$args] }
proc busy {w} {}
proc unbusy {w} {}


proc makeStateSpecificIcons {img} {
	return $img ;# XXX how to do?
}


proc Tr {tok {args {}}} {
	return [mc [namespace current]::mc::$tok {*}$args]
}


proc GetFileSize {file} {
	set size [expr {[file size $file]/1024 + 1}]
}


proc SetupSaveMode {w} {
	variable ${w}::Vars

	if {$Vars(savemode:value) eq "append"} { set type open } else { set type save }
	changeFileDialogType $w $type
}


proc ValidateFile {file {size {}}} {
	return 1
}


proc CheckEncoding {w file} {
	variable ${w}::Vars

	if {[llength $Vars(selectencodingcommand)]} {
		if {[string length $Vars(encodingUser)] == 0} {
			set Vars(encodingVar) $Vars(defaultencoding)

			foreach {ext encoding} $Vars(fileencodings) {
				if {[string match *$ext $file]} {
					if {[string length $Vars(encodingVar)] == 0} {
						set Vars(encodingVar) $encoding
					}
					set Vars(encodingDefault) $encoding
				}
			}
		}
	}
}


proc CheckFileEncoding {w} {
	variable ${w}::Vars

	set file [$Vars(widget:filename) get]

	if {[llength $file]} {
		if {[string length [file extension $file]] == 0 && [string length $Vars(defaultextension)]} {
			append file $Vars(defaultextension)
		}
		CheckEncoding $w $file
	}
}


proc SelectFileTypes {w combo} {
	variable ${w}::Vars

	set selection [$combo get]
	set i [string last " (" $selection]
	set selection [string range $selection 0 [expr {$i - 1}]]
	set i [lsearch -index 0 -exact $Vars(filetypes) $selection]
	set Vars(extensions) [lindex $Vars(filetypes) $i 1]

	SetFileTypes $w
	filelist::RefreshFileList $w
}


proc SetFileTypes {w {index -1}} {
	variable ${w}::Vars
	variable Options

	if {$index >= 0} {
		$Vars(widget:filetypes:combobox) current $index
	} else {
		set index [$Vars(widget:filetypes:combobox) current]
	}

	set Vars(defaultextension) [lindex $Vars(filetypes) $index 1 0]

	if {$Options(show:filetypeicons) && [llength $Vars(filetypes)]} {
		set icons {}
		set x 2
		set i 0
		set t $Vars(widget:filetypes:canvas)
		set y -1000

		foreach ext [lindex $Vars(filetypes) $index 1] {
			if {[info exists Vars(fti:$ext)]} {
				set img $Vars(fti:$ext)
				if {$img ni $icons} {
					incr x 2
					if {[llength [$t gettags ft:$i]] == 0} {
						$t create image 0 0 -anchor nw -tag ft:$i
					}
					if {$y == -1000} {
						set y [expr {(([winfo height $t] + 1) - [image height $img])/2}]
					}
					$t coords ft:$i $x $y
					$t itemconfigure ft:$i -image $img -state normal
					lappend icons $img
					incr x [image width $img]
					incr i
				}
			}
		}

		while {[llength [$t gettags ft:$i]] > 0} {
			$t itemconfigure ft:$i -state hidden
			incr i
		}
	}
}


proc SelectEncoding {w} {
	variable ${w}::Vars

	set current $Vars(encodingVar)
	if {[string length $current] == 0} { set current iso8859-1 }
	set encoding [{*}$Vars(selectencodingcommand) $w $current $Vars(encodingDefault)]

	if {[string length $encoding]} {
		set Vars(encodingVar) $encoding
		set Vars(encodingUser) $encoding
	}
}


proc ThemeChanged {w} {
	variable ${w}::Vars

	set background [ttk::style lookup $::ttk::currentTheme -background]

	foreach n {bookmark file} {
		set t $Vars(widget:list:$n)
		foreach id [$t column list] {
			$t column configure $id -background $background
		}
	}

	$Vars(widget:panedwindow) configure -background $background
}


proc ConfigurePane {width} {
	variable Options

	set Options(pane:favorites) $width
}


proc VisitItem {w t mode item} {
	variable ${w}::Vars

	if {$Vars(edit:active)} { return }

	# Note: this function may be invoked with non-existing items
	if {[string length $item]} {
		switch $mode {
			enter { catch { $t item state set $item {hilite}  } }
			leave { catch { $t item state set $item {!hilite} } }
		}
	}
}


proc SetActiveItem {w item state} {
	variable ::TreeCtrl::Priv

	if {[string length $item] == 0} { return  }

	if {[$w cget -selectmode] eq "extended"} {
		if {[expr {$state & 4}]} { ;# Ctrl is held down
			$w activate $item
			$w selection anchor $item
			$w see $item
			if {$item in [$w selection get]} {
				$w selection clear $item
			} else {
				$w selection add $item
			}
			set Priv(selection) ""
			set Priv(prev) ""
		} elseif {[expr {$state & 1}] && [llength [$w selection get]]} { ;# Shift is held down
			TreeCtrl::DataExtend $w $item
		} else {
			set Priv(prev) ""
			set Priv(selection) ""
			TreeCtrl::SetActiveItem $w $item
		}
	} else {
		set Priv(prev) ""
		set Priv(selection) ""
		TreeCtrl::SetActiveItem $w $item
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


proc DirChanged {w {useHistory 1}} {
	variable ${w}::Vars
	variable bookmarks::Bookmarks
	variable bookmarks::BookmarkSize

	if {$Vars(glob) eq "Files"} {
		set folder $Vars(folder)
	} else {
		set folder $Vars(glob)
	}

	if {$useHistory} {
		set Vars(undo:history) [lrange $Vars(undo:history) 0 $Vars(undo:current)]
		set Vars(undo:current) [llength $Vars(undo:history)]
		lappend Vars(undo:history) $folder
		if {[llength $Vars(undo:history)] > 1} {
			filelist::SetTooltip $w Backward $Vars(prevFolder)
			::toolbar::childconfigure $Vars(button:backward) -state normal -tooltip $Vars(tip:backward)
		}
		::toolbar::childconfigure $Vars(button:forward) -state disabled
		set Vars(tip:forward) ""

		if {$Vars(glob) eq "Files" && $folder ne "/"} {
			set i [lsearch -exact $Bookmarks(lastvisited) $folder]
			if {$i >= 0} {
				set Bookmarks(lastvisited) [lreplace $Bookmarks(lastvisited) $i $i]
			}
			if {[llength $Bookmarks(lastvisited)] >= $BookmarkSize} {
				set erange [expr {$BookmarkSize - 2}]
				set Bookmarks(lastvisited) [lrange $Bookmarks(lastvisited) 0 $erange]
			}
			set Bookmarks(lastvisited) [linsert $Bookmarks(lastvisited) 0 $folder]

			set i [lsearch -exact -index 0 $Bookmarks(favorites) $folder]
			if {$i == -1} {
				if {[llength $Bookmarks(favorites)] >= $BookmarkSize} {
					set erange [expr {$BookmarkSize - 2}]
					set Bookmarks(favorites) [lrange $Bookmarks(favorites) 0 $erange]
				}
				lappend Bookmarks(favorites) [list $folder 1]
			} else {
				set count [lindex $Bookmarks(favorites) $i 1]
				set Bookmarks(favorites) [lreplace $Bookmarks(favorites) $i $i]
				lappend Bookmarks(favorites) [list $folder [incr count]]
			}
			set Bookmarks(favorites) [lsort -index 1 -decreasing -integer $Bookmarks(favorites)]
		}
	}

	set Vars(bookmark:folder) ""

	foreach f {home desktop filesystem} {
		if {$Vars(folder) eq $Vars(folder:$f)} {
			::toolbar::childconfigure $Vars(button:add) -state disabled
			return
		}
	}

	if {$Vars(glob) ne "Files"} {
		::toolbar::childconfigure $Vars(button:add) -state disabled
		return
	} else {
		foreach f $Bookmarks(user) {
			if {$Vars(folder) eq $f} {
				::toolbar::childconfigure $Vars(button:add) -state disabled
				return
			}
		}
	}

	set Vars(bookmark:folder) $folder
	set tip [format $mc::AddBookmark [file tail $folder]]
	::toolbar::childconfigure $Vars(button:add) -state normal -tooltip $tip
}


proc ChangeDir {w path {useHistory 1}} {
	variable ${w}::Vars
	variable bookmarks::Bookmarks

	set Vars(prevFolder) $Vars(folder)
	if {[string length $Vars(prevFolder)] == 0} {
		set Vars(prevFolder) $Vars(glob)
	}

	switch $path {
		Favorites {
			set Vars(glob) $path
			set Vars(folder) {}
			set subfolders {}
			foreach entry $Bookmarks([string tolower $path]) {
				lappend subfolders [lindex $entry 0]
			}
			$Vars(choosedir) setfolder [Tr $path] $subfolders
		}

		LastVisited {
			set Vars(glob) $path
			set Vars(folder) {}
			$Vars(choosedir) setfolder [Tr $path] $Bookmarks([string tolower $path])
		}

		default {
			set Vars(glob) Files
			set appPWD [pwd]

			if {[catch {cd $path}]} {
				if {[file isdirectory $path]} {
					set message [Tr CannotChangeDir $path]
				} else {
					set message [Tr DirectoryRemoved $path]
				}
				$Vars(choosedir) set $appPWD
				messageBox -type ok -parent $Vars(widget:main) -icon warning -message $message
				return
			}

			set Vars(folder) [pwd]
			cd $appPWD
			$Vars(choosedir) set $Vars(folder)
			set Vars(lastFolder) $Vars(folder)
		}
	}

	$Vars(widget:filelist) item delete all
	filelist::Glob $w yes
	if {$Vars(prevFolder) ne $Vars(folder)} {
		DirChanged $w $useHistory
	}
}


proc FocusIn {w} {
	if {[$w get] ne ""} {
		$w selection range 0 end
		$w icursor end
	} else {
		$w selection clear
	}
}


proc FocusOut {w} {
	$w selection clear
}


proc InvokeOk {w} {
	if {[$w cget -state] eq "normal"} {
		$w invoke
	}
}


proc Cancel {w} {
	variable ${w}::Vars

	if {[llength $Vars(cancelcommand)]} {
		{*}$Vars(cancelcommand)
	}
}


proc Activate {w} {
	variable ${w}::Vars

	switch $Vars(glob) {
		Files			{ set complete Join }
		Favorites	{ set complete SearchFavorite }
		LastVisited	{ set complete SearchLastVisited }
	}

	set files {}
	set selected {}

	if {$Vars(multiple)} {
		foreach file [string trim [split [$Vars(widget:filename) get] "\""]] {
			if {[string length $file]} {
				lappend selected [[namespace current]::$complete $w $file]
			}
		}
	} else {
		set file [string trim [$Vars(widget:filename) get]]
		if {[string length $file]} {
			lappend selected [[namespace current]::$complete $w $file]
		}
	}

	if {[llength $selected] == 0} { return }

	foreach file $selected {
		if {[lindex [file split $file] 0] ne "/"} {
			set msg [format [Tr CannotOpenOrCreate] $file]
			messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
			return
		}
	}

	if {$Vars(type) eq "save"} {
		foreach file $selected {
			if {![CheckPath $w $file]} { return }
		}
	}

	foreach file $selected {
		if {[llength $Vars(filetypes)]} {
			if {[string length [file extension $file]]} {
				if {$Vars(type) eq "save"} {
					set found 0
					foreach entry $Vars(filetypes) {
						foreach ext [lindex $entry 1] {
							if {[string match *$ext $file]} {
								set found 1
							}
						}
					}
					if {!$found} {
						set msg [format [Tr InvalidFileExtension] [file tail $file]]
						messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
						return
					}
				}
			} elseif {[string length $Vars(defaultextension)]} {
				append file $Vars(defaultextension)
			} else {
				set msg [format [Tr MissingFileExtension] [file tail $file]]
				messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
				return
			}
		}
		lappend files $file
	}

	switch $Vars(type) {
		dir {
			foreach dir $files {
				if {![file isdirectory $dir]} {
					set msg [format [Tr DirectoryDoesNotExist] $file]
					messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
					return
				}
			}
		}

		open {
			foreach file $files {
				if {![file exists $file]} {
					set msg [format [Tr FileDoesNotExist] $file]
					messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
					return
				}
			}
		}

		save {
			foreach file $files {
				if {[file isdirectory $file]} {
					set msg [format [Tr CannotOverwriteDirectory] [file tail $file]]
					messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
					return
				}
				if {[file exists $file]} {
					set msg [format [Tr FileAlreadyExists] [file tail $file]]
					set reply [messageBox \
									-type yesno \
									-icon question \
									-parent $Vars(widget:main) \
									-message $msg \
					]
					if {$reply ne "yes"} { return }
				}
			}
		}
	}

	if {[llength $Vars(okcommand)]} {
		if {!$Vars(multiple)} { set files [lindex $files 0] }
		if {[llength $Vars(selectencodingcommand)]} {
			{*}$Vars(okcommand) $files $Vars(encodingVar)
		} else {
			{*}$Vars(okcommand) $files
		}
	}
}


proc Join {w filename} {
	variable ${w}::Vars
	return [file join $Vars(folder) $filename]
}


proc SearchFavorite {w dir} {
	variable bookmarks::Bookmarks

	foreach entry $Bookmarks(favorites) {
		set d [lindex $entry 0]
		if {[file tail $d] eq $dir} {
			return $d
		}
	}

	return $dir
}


proc SearchLastVisited {w dir} {
	variable bookmarks::Bookmarks

	foreach d $Bookmarks(lastvisited) {
		set d [lindex $entry 0]
		if {[file tail $d] eq $dir} {
			return $d
		}
	}

	return $dir
}


proc CheckPath {w path} {
	variable ${w}::Vars

	switch [verifyPath $path] {
		oneDot {
			messageBox \
				-type ok \
				-icon error \
				-parent $Vars(widget:main) \
				-message [format [Tr FilenameNotAllowed] $path] \
				;
			return 0
		}

		twoDots {
			messageBox \
				-type ok \
				-icon error \
				-parent $Vars(widget:main) \
				-message [format [Tr FilenameNotAllowed] $path] \
				-detail [Tr ContainsTwoDots] \
				;
			return 0
		}
	}

	return 1
}


proc Stimulate {w} {
	variable ${w}::Vars

	set Vars(edit:active) 0

	foreach type {bookmark file} {
		set t $Vars(widget:list:$type)
		foreach item [$t item children root] { $t item state set $item {!hilite} }
		set x [expr {[winfo pointerx .] - [winfo rootx $t]}]
		set y [expr {[winfo pointery .] - [winfo rooty $t]}]
		set id [$t identify $x $y]
		if {[llength $id] == 0} { return }
		lassign $id what item

		if {$what eq "item"} {
			$t item state set $item {hilite}
		}
	}
}


namespace eval bookmarks {

array set Bookmarks {
	favorites	{}
	lastvisited	{}
	user			{}
}

set BookmarkSize 15


proc Tr {tok args} { return [[namespace parent]::Tr $tok {*}$args] }


proc Build {w path args} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options
	variable Bookmarks

	if {![info exists [namespace current]::icon::16x16::iconAdd]} {
		foreach {icon img} {Add plus Minus minus} {
			set [namespace current]::icon::16x16::icon$icon \
				[list [[namespace parent]::makeStateSpecificIcons \
					[set [namespace current]::icon::16x16::$img]]]
		}
	}

	set opts(-width) 120
	set opts(-selectmode) single
	array set opts $args
	array unset opts -rows

	set linespace [font metrics $Vars(font) -linespace]
	if {$linespace < 20} { set linespace 20 }

	::tk::frame $path -borderwidth 0 -takefocus 0 -width $Options(pane:favorites)
	pack propagate $path 0

	set tb [::toolbar::toolbar $path -id toolbar -hide 0 -side bottom]

	set Vars(button:add) [::toolbar::add $tb button    \
		-image $icon::16x16::iconAdd                    \
		-command [namespace code [list AddBookmark $w]] \
		-state disabled                                 \
	]
	set Vars(button:minus) [::toolbar::add $tb button     \
		-image $icon::16x16::iconMinus                     \
		-command [namespace code [list RemoveBookmark $w]] \
		-state disabled                                    \
	]
	
	tk::frame $path.f -borderwidth 0 -takefocus 0
	pack $path.f -fill both -expand yes

	set t $path.f.list
	set sb $path.f.vscroll
	set Vars(widget:list:bookmark) $t
	set yscrollcmd [list [namespace parent]::SbSet $sb]

	treectrl $t {*}[array get opts]  \
		-class FSBox                   \
		-highlightthickness 0          \
		-showroot no                   \
		-showheader no                 \
		-showbuttons no                \
		-showlines no                  \
		-takefocus 1                   \
		-itemheight $linespace         \
		-yscrollcommand $yscrollcmd    \
		;
	bind $t <ButtonPress-3> [namespace code [list PopupMenu $w %x %y]]

	ttk::scrollbar $sb           \
		-orient vertical          \
		-takefocus 0              \
		-command [list $t yview] \
		;

	grid $t -row 0 -column 0 -sticky nsew
	grid $sb -row 0 -column 1 -sticky ns
	grid columnconfigure $path.f {0} -weight 1
	grid rowconfigure $path.f {0} -weight 1

	$t state define hilite

	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify bind $t <Item-enter> [list [namespace parent]::VisitItem $w $t enter %I]
	$t notify bind $t <Item-leave> [list [namespace parent]::VisitItem $w $t leave %I]
	$t notify bind $t <Item-enter> +[namespace code [list VisitItem $w enter %I]]
	$t notify bind $t <Item-leave> +[namespace code [list VisitItem $w leave %I]]

	$t column create -tags root
	$t configure -treecolumn root

	$t element create elemImg image
	$t element create elemTxt text                    \
		-fill [list                                     \
			$Vars(selectionforeground) {selected focus}  \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite}             \
		]                                               \
		-lines 1                                        \
		;
	$t element create elemSel rect                    \
		-fill [list                                     \
			$Vars(selectionbackground) {selected focus}  \
			$Vars(selectionbackground) {selected hilite} \
			$Vars(inactivebackground) {selected !focus}  \
			$Vars(activebackground) {hilite}             \
		]
	$t element create elemBrd border         \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;

	set s [$t style create style]
	$t style elements $s {elemSel elemImg elemBrd elemTxt}
	$t style layout $s elemImg -expand ns -padx {4 0}
	$t style layout $s elemTxt -padx {6 4} -expand ns -squeeze x
	$t style layout $s elemSel -union {elemTxt} -iexpand nsew
	$t style layout $s elemBrd -iexpand xy -detach yes

	$t element create elemDiv rect -fill black -height 1
	$t style create styLine
	$t style elements styLine {elemDiv}
	$t style layout styLine elemDiv -pady {3 2} -padx {4 4} -iexpand x -expand ns

	bind $t <Double-Button-1>	[namespace code [list InvokeBookmark $w %x %y]]
	bind $t <Key-space>	[namespace code [list InvokeBookmark $w]]
	bind $t <Return> [namespace code [list InvokeBookmark $w]]

	set Vars(bookmarks) {
		{ star			Favorites	}
		{ visited		LastVisited	}
		{ divider		""				}
		{ filesystem	FileSystem	}
	}
	if {[string length $Vars(folder:desktop)]} {
		lappend Vars(bookmarks) { desktop Desktop }
	}
	lappend Vars(bookmarks)         \
		{ home			Home			} \
		{ divider		""				} \
		;

	LayoutBookmarks $w

	$t activate 0
	$t notify bind $t <Selection> [namespace code [list Selected $w %S]]

	Selected $w {}
}


proc LayoutBookmarks {w} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)
	$t item delete all
	$t xview moveto 0.0
	$t yview moveto 0.0

	foreach entry $Vars(bookmarks) {
		lassign $entry icon text
		set item [$t item create]
		if {$icon eq "divider"} {
			$t item style set $item root styLine
			$t item enabled $item false
		} else {
			set icon [set [namespace parent]::icon::16x16::$icon]
			$t item style set $item root style
			$t item element configure $item root \
				elemImg -image $icon + \
				elemTxt -text [set [namespace parent]::mc::$text] \
				;
		}
		$t item lastchild root $item
	}

	set bookmarks {}
	foreach folder $Bookmarks(user) {
		if {[file isdirectory $folder]} {
			lappend bookmarks $folder
		}
	}
	set Bookmarks(user) $bookmarks
	array unset Vars bookmark:tooltip:*

	set index 0
	foreach folder $Bookmarks(user) {
		set icon [set [namespace parent]::icon::16x16::folder]
		set item [$t item create]
		$t item style set $item root style
		$t item element configure $item root elemImg -image $icon + elemTxt -text [file tail $folder]
		$t item lastchild root $item
		set Vars(bookmark:tooltip:$item) $index
		incr index
	}
}


proc AddBookmark {w} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	lappend Bookmarks(user) $Vars(folder)
	set list {}
	set index -1
	foreach folder $Bookmarks(user) {
		lappend list [list [incr index] [string tolower [file tail $folder]]]
	}
	set list [lsort -dictionary -index 1 $list]
	set bookmarks {}
	foreach entry $list { lappend bookmarks [lindex $Bookmarks(user) [lindex $entry 0]] }
	set Bookmarks(user) $bookmarks
	LayoutBookmarks $w
	[namespace parent]::DirChanged $w 0
}


proc RemoveBookmark {w} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)
	set sel [expr {[$t item id active] - 1}]
	set sel [expr {$sel - [llength $Vars(bookmarks)]}]
	set Bookmarks(user) [lreplace $Bookmarks(user) $sel $sel]
	LayoutBookmarks $w
	[namespace parent]::DirChanged $w 0
}


proc Selected {w sel} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	if {[string is integer -strict $sel] && $sel > [llength $Vars(bookmarks)]} {
		set folder [lindex $Bookmarks(user) [expr {$sel - [llength $Vars(bookmarks)] - 1}]]
		set tip [format [set [namespace parent]::mc::RemoveBookmark] [file tail $folder]]
		::toolbar::childconfigure $Vars(button:minus) -state normal -tooltip $tip
	} else {
		::toolbar::childconfigure $Vars(button:minus) -state disabled
	}
}


proc VisitItem {w mode item} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::HaveTooltips
	variable Bookmarks

	if {$HaveTooltips && [string length $item]} {
		switch $mode {
			enter {
				catch {
					::tooltip::show $w [lindex $Bookmarks(user) $Vars(bookmark:tooltip:$item)]
				}
			}
			leave {
				::tooltip::hide
			}
		}
	}
}


proc InvokeBookmark {w args} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)

	if {[llength $args] == 2} {
		lassign $args x y
		set id [$t identify $x $y]
		if {[llength $id] == 0 || [lindex $id 0] eq "header"} { return }
		set sel [$t item order [lindex $id 1] -visible]
	} else {
		set sel [expr {[$t item id active] - 1}]
	}

	if {$sel < [llength $Vars(bookmarks)]} {
		switch [lindex $Vars(bookmarks) $sel 1] {
			Favorites	{ [namespace parent]::ChangeDir $w Favorites }
			LastVisited	{ [namespace parent]::ChangeDir $w LastVisited }
			FileSystem	{ [namespace parent]::ChangeDir $w $Vars(folder:filesystem) }
			Desktop		{ [namespace parent]::ChangeDir $w $Vars(folder:desktop) }
			Home			{ [namespace parent]::ChangeDir $w $Vars(folder:home) }
		}
	} else {
		set i [expr {$sel - [llength $Vars(bookmarks)]}]
		if {$i < [llength $Bookmarks(user)]} {
			[namespace parent]::ChangeDir $w [lindex $Bookmarks(user) $i]
		}
	}
}


proc PopupMenu {w x y} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)
	set id [$t identify $x $y]
	if {[llength $id] == 0 || [lindex $id 0] eq "header"} { return }
	foreach item [$t item children root] { $t item state set $item {!hilite} }

	set m $w.menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	set count 0

	if {[string length $Vars(folder)]} {
		if {[string length $Vars(bookmark:folder)]} { set state normal } else { set state disabled }
		set text [format [Tr AddBookmark] [file tail $Vars(folder)]]
		$m add command \
			-compound left \
			-image $icon::16x16::plus \
			-label " $text" \
			-command [namespace code [list AddBookmark $w]] \
			-state $state \
			;
		incr count
	}

	set sel [expr {[$t item id active] - [llength $Vars(bookmarks)] - 1}]
	if {$sel >= 0} {
		set text [format [Tr RemoveBookmark] [file tail $Bookmarks(user)]]
		$m add command                                        \
			-compound left                                     \
			-image $icon::16x16::minus                         \
			-label " $text"                                    \
			-command [namespace code [list RemoveBookmark $w]] \
			;
		incr count
	}

	if {$count > 0} {
		set Vars(edit:active) 1
		tk_popup $m {*}[winfo pointerxy $w]
		bind $m <<MenuUnpost>> [list [namespace parent]::Stimulate $w]
	}
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

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace bookmarks

namespace eval filelist {

namespace import ::tcl::mathfunc::max


proc Tr {tok args} { return [[namespace parent]::Tr $tok {*}$args] }


proc Build {w path args} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	if {![info exists [namespace current]::icon::16x16::iconAdd]} {
		foreach {icon img} {Delete delete Modify modify Add folder_add Backward backward Forward forward} {
			set [namespace current]::icon::16x16::icon$icon \
				[list [[namespace parent]::makeStateSpecificIcons \
					[set [namespace current]::icon::16x16::$img]]]
		}
	}

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

	if {[info exists opts(-rows)]} {
		set Vars(rows) $opts(-rows)
		array unset opts -rows
	}

	set Vars(sort-column) name
	set Vars(sort-order) increasing
	set Vars(selected:folders) {}
	set Vars(selected:files) {}
	set Vars(lock:selection) 0
	set Vars(undo:history) {}
	set Vars(undo:current) -1
	set Vars(tip:forward) ""
	set Vars(tip:backward) ""

	tk::frame $path -borderwidth 0 -takefocus 0
	tk::frame $path.f -borderwidth 0 -takefocus 0
	pack $path.f -fill both -expand yes

	set sv $path.f.vscroll
	set sh $path.f.hscroll
	set t  $path.f.files
	set tb [::toolbar::toolbar $path -id toolbar -hide 0 -side left]

	set Vars(button:backward) [::toolbar::add $tb button \
		-image $icon::16x16::iconBackward                 \
		-command [namespace code [list Undo $w]]          \
		-state disabled                                   \
	]
	set Vars(button:forward) [::toolbar::add $tb button \
		-image $icon::16x16::iconForward                 \
		-command [namespace code [list Redo $w]]         \
		-state disabled                                  \
	]

	::toolbar::add $tb separator

	set Vars(button:delete) [::toolbar::add $tb button \
		-image $icon::16x16::iconDelete                 \
		-command [namespace code [list DeleteFile $w]]  \
		-tooltip [Tr Delete]                            \
		-state disabled                                 \
	]
	set Vars(button:rename) [::toolbar::add $tb button \
		-image $icon::16x16::iconModify                 \
		-command [namespace code [list RenameFile $w]]  \
		-tooltip [Tr Rename]                            \
		-state disabled                                 \
	]
	set Vars(button:new) [::toolbar::add $tb button   \
		-image $icon::16x16::iconAdd                   \
		-command [namespace code [list NewFolder $w]] \
		-tooltip [Tr NewFolder]                        \
	]

	::toolbar::add $tb separator

	if {$Options(show:layout) eq "list"} {
		set tooltip ListLayout
		set Vars(layout:list) 0
		set layout details
	} else {
		set tooltip DetailedLayout
		set Vars(layout:list) 1
		set layout list
	}
	set Vars(widget:layout) [::toolbar::add $tb button       \
		-image [set icon::16x16::$layout]                     \
		-command [namespace code [list SwitchLayout $w]]      \
		-tooltip [Tr $tooltip]                                \
		-variable [namespace parent]::${w}::Vars(layout:list) \
	]
	if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
	set Vars(widget:hidden) [::toolbar::add $tb checkbutton \
		-image [set icon::16x16::${ipref}locked]             \
		-command [namespace code [list SwitchHidden $w]]     \
		-tooltip [Tr ShowHiddenFiles]                        \
		-variable [namespace parent]::Options(show:hidden)   \
		-padx 1                                              \
	]

	set Vars(widget:list:file) $t
	set Vars(xscrollcmd) [list [namespace parent]::SbSet $sh]
	set Vars(yscrollcmd) [list $sv set]
	set Vars(widget:xscrollbar) $sh
	set Vars(widget:yscrollbar) $sv

	treectrl $t {*}[array get opts] \
		-class FSBox                 \
		-takefocus 1                 \
		-highlightthickness 0        \
		-showheader yes              \
		-showbuttons no              \
		-showroot no                 \
		-showlines no                \
		-showrootlines no            \
		-columnresizemode realtime   \
		-xscrollincrement 1          \
		-keepuserwidth no            \
		-orient vertical             \
		;
	set Vars(widget:filelist) $t
	bind $t <ButtonPress-3> [namespace code [list PopupMenu $w %x %y]]

	ttk::scrollbar $sv           \
		-orient vertical          \
		-takefocus 0              \
		-command [list $t yview] \
		;
	ttk::scrollbar $sh           \
		-orient horizontal        \
		-takefocus 0              \
		-command [list $t xview] \
		;

	grid $t  -row 0 -column 0 -sticky nsew
	grid $sh -row 1 -column 0 -sticky ew
	grid $sv -row 0 -column 1 -sticky ns
	grid columnconfigure $path.f {0} -weight 1
	grid rowconfigure $path.f {0} -weight 1

	SetColumnBackground $t tail $Vars(stripes) $opts(-background)

	set linespace [max [font metrics [$t cget -font] -linespace] 20]
	set Vars(charwidth) [font measure [$t cget -font] "0"]
	$t configure -itemheight $linespace

	$t state define hilite

	SwitchLayout $w

	TreeCtrl::SetEditable  $t { {name styName txtName} }
#	TreeCtrl::SetSensitive $t { {name styName elemImg txtName} }
#	TreeCtrl::SetDragImage $t { {name styName elemImg txtName} }

	$t notify install <Edit-begin>
	$t notify install <Edit-accept>
	$t notify install <Edit-end>
	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify install <Header-invoke>
	$t notify install <Column-resized>

	$t state define edit
	$t style layout styName txtName -draw {no edit}
	$t style layout styName elemSel -draw {no edit}
	$t notify bind $t <Edit-begin> { %T item state set %I ~edit }
	$t notify bind $t <Edit-accept> { %T item element configure %I %C %E -text %t }
	$t notify bind $t <Edit-accept> +[namespace code [list EditAccept $w]]
	$t notify bind $t <Edit-end> { %T item state set %I ~edit }
	$t notify bind $t <Edit-end> +[namespace code [list FinishEdit $w]]
	$t notify bind $t <Item-enter> [list [namespace parent]::VisitItem $w $t enter %I]
	$t notify bind $t <Item-leave> [list [namespace parent]::VisitItem $w $t leave %I]
	$t notify bind $t <Column-resized> [namespace code [list ColumnResized $w %C]]

	$t notify bind $t <Header-invoke> [namespace code [list SortColumn $w %C]]
	$t notify bind $t <Selection> [namespace code [list SelectFiles $w %S]]

	bind $t <Double-Button-1>	[namespace code [list InvokeFile $w %x %y]]
	bind $t <Double-Button-1>	{+ break }
	bind $t <Key-space> [namespace code [list InvokeFile $w]]
	bind $t <Return> [namespace code [list InvokeFile $w]]

	CheckDir $t

	if {[info exists Vars(rows)]} {
		update idletasks
		set h [expr {[$t headerheight] + max($Vars(rows),1)*$linespace}]
		$t configure -height $h
	}
}


proc SwitchHidden {w} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	set Options(show:hidden) [expr {!$Options(show:hidden)}]
	if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
	toolbar::childconfigure $Vars(widget:hidden) -image [set icon::16x16::${ipref}locked]
	RefreshFileList $w
}


proc DetailsLayout {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)

	$t configure -itemwidthequal no
	$t configure -wrap {}
	$t configure -showheader yes
	$t configure -yscrollcommand $Vars(yscrollcmd)
	$t configure -xscrollcommand $Vars(xscrollcmd)
	grid remove $Vars(widget:xscrollbar)
	grid $Vars(widget:yscrollbar)

	catch { $t item delete 1 end }
	foreach col [$t column list] { $t column delete $col }
	$t style delete {*}[$t style names]
	$t element delete {*}[$t element names]

	if {[info exists Vars(column:name)]} {
		set copts(name) [list -width $Vars(column:name)]
		set copts(size) [list -width $Vars(column:size)]
		set copts(modified) [list -width $Vars(column:modified)]
	} else {
		set copts(name) {}
		set copts(size) {}
		set copts(modified) {}
	}

	$t column create                            \
		-text [set [namespace parent]::mc::Name] \
		-tags name                               \
		-minwidth [expr {10*$Vars(charwidth)}]   \
		-arrow up                                \
		-borderwidth $Vars(borderwidth)          \
		-steady yes                              \
		-textpadx $Vars(textpadx)                \
		-textpady $Vars(textpady)                \
		-font $Vars(font)                        \
		-expand yes                              \
		-squeeze yes                             \
		{*}$copts(name)                          \
		;
	$t column create                            \
		-text [set [namespace parent]::mc::Size] \
		-tags size                               \
		-justify right                           \
		-width [expr {11*$Vars(charwidth)}]      \
		-minwidth [expr {6*$Vars(charwidth)}]    \
		-arrowside left                          \
		-arrowgravity right                      \
		-borderwidth $Vars(borderwidth)          \
		-steady yes                              \
		-textpadx $Vars(textpadx)                \
		-textpady $Vars(textpady)                \
		-font $Vars(font)                        \
		{*}$copts(size)                          \
		;
	$t column create                                \
		-text [set [namespace parent]::mc::Modified] \
		-tags modified                               \
		-width [expr {18*$Vars(charwidth)}]          \
		-minwidth [expr {10*$Vars(charwidth)}]       \
		-borderwidth $Vars(borderwidth)              \
		-steady yes                                  \
		-textpadx $Vars(textpadx)                    \
		-textpady $Vars(textpady)                    \
		-font $Vars(font)                            \
		{*}$copts(modified)                          \
		;
	
	$t element create elemImg image -image [set [namespace parent]::icon::16x16::folder]
	$t element create txtName text                     \
		-fill [list                                     \
			$Vars(selectionforeground) {selected focus}  \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite}             \
		]                                               \
		-lines 1                                        \
		;
	$t element create txtSize text                     \
		-fill [list                                     \
			$Vars(selectionforeground) {selected focus}  \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite}             \
		]                                               \
		-lines 1                                        \
		;
	$t element create txtDate text                      \
		-fill [list                                      \
			$Vars(selectionforeground) {selected focus}   \
			$Vars(selectionforeground) {selected hilite}  \
			$Vars(inactiveforeground)  {selected !focus}  \
			$Vars(activeforeground) {hilite}              \
		]                                                \
		-datatype time                                   \
		-format [set [namespace parent]::mc::TimeFormat] \
		-lines 1                                         \
		;
	$t element create elemSel rect                     \
		-fill [list                                     \
			$Vars(selectionbackground) {selected focus}  \
			$Vars(selectionbackground) {selected hilite} \
			$Vars(inactivebackground) {selected !focus}  \
			$Vars(activebackground) {hilite}             \
		] 
	$t element create elemBrd border          \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;
	
	# column 0: icon + text
	set s [$t style create styName -orient horizontal]
	$t style elements $s {elemSel elemImg elemBrd txtName}
	$t style layout $s elemImg -padx {2 0} -expand ns
	$t style layout $s txtName -squeeze x -expand ns -padx {4 0}
	$t style layout $s elemSel -union {txtName} -ipadx 2 -iexpand nsew
	$t style layout $s elemBrd -iexpand xy -detach yes

	# column 1: text
	set s [$t style create stySize]
	$t style elements $s {elemSel elemBrd txtSize}
	$t style layout $s txtSize -padx {4 4} -squeeze x -expand ns
	$t style layout $s elemSel -union {txtSize} -ipadx 2 -iexpand nsew
	$t style layout $s elemBrd -iexpand xy -detach yes

	# column 2: text
	set s [$t style create styDate]
	$t style elements $s {elemSel elemBrd txtDate}
	$t style layout $s txtDate -padx {4 4} -squeeze x -expand ns
	$t style layout $s elemSel -union {txtDate} -ipadx 2 -iexpand nsew
	$t style layout $s elemBrd -iexpand xy -detach yes

	set Vars(scriptDir) {
		set item [$t item create -open no]
		$t item style set $item name styName size stySize modified styDate
		$t item element configure $item \
			name txtName -text [file tail $folder] , \
			modified txtDate -data [file mtime $folder]
		$t item lastchild root $item
	}

	set Vars(scriptNew) {
		set item [$t item create -open no]
		$t item style set $item name styName size stySize modified styDate
		$t item element configure $item name txtName -text [file tail $folder]
		$t item lastchild root $item
	}

	set Vars(scriptFile) {
		set mtime [file mtime $file]
		set size [{*}$Vars(sizecommand) $file $mtime]
		set valid [{*}$Vars(validatecommand) $file $size]
		if {$valid} {
			set valid 1
			set item [$t item create -open no]
			$t item style set $item name styName size stySize modified styDate
			set icon [GetFileIcon $w $file]
			$t item element configure $item \
				name elemImg -image $icon , \
				name txtName -text [file tail $file] , \
				size txtSize -text $size , \
				modified txtDate -data $mtime
			$t item lastchild root $item
		}
	}
}


proc ListLayout {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)

	$t configure -itemwidthequal yes
	$t configure -wrap window
	$t configure -showheader no
	$t configure -yscrollcommand {}
	$t configure -xscrollcommand $Vars(xscrollcmd)
	grid remove $Vars(widget:yscrollbar)

	catch { $t item delete 1 end }
	foreach col [$t column list] { $t column delete $col }
	foreach sty [$t style names] { $t style delete $sty }
	foreach elm [$t element names] { $t element delete $elm }

	$t column create -tags name -steady yes

	$t element create elemImg image -image [set [namespace parent]::icon::16x16::folder]
	$t element create txtName text                     \
		-fill [list                                     \
			$Vars(selectionforeground) {selected focus}  \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite}             \
		]                                               \
		-lines 1                                        \
		;
	$t element create elemSel rect                     \
		-fill [list                                     \
			$Vars(selectionbackground) {selected focus}  \
			$Vars(selectionbackground) {selected hilite} \
			$Vars(inactivebackground) {selected !focus}  \
			$Vars(activebackground) {hilite}             \
		] 
	$t element create elemBrd border          \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;
	
	set s [$t style create styName]
	$t style elements $s {elemSel elemImg elemBrd txtName}
	$t style layout $s elemImg -expand ns -padx {3 0}
	$t style layout $s txtName -squeeze x -expand ns -padx {2 3}
	$t style layout $s elemSel -iexpand xy -detach yes
	$t style layout $s elemBrd -iexpand xy -detach yes

	set Vars(scriptDir) {
		set item [$t item create -open no]
		$t item style set $item name styName
		$t item text $item name [file tail $folder]
		$t item lastchild root $item
	}

	set Vars(scriptNew) $Vars(scriptDir)

	set Vars(scriptFile) {
		set valid [{*}$Vars(validatecommand) $file]
		if {$valid} {
			set valid 1
			set item [$t item create -open no]
			$t item style set $item name styName
			set icon [GetFileIcon $w $file]
			$t item element configure $item name \
				elemImg -image $icon + \
				txtName -text [file tail $file]
			$t item lastchild root $item
		}
	}
}


proc SwitchLayout {w {layout {}}} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	if {[llength $layout] == 0} {
		set Vars(layout:list) [expr {!$Vars(layout:list)}]
		if {$Vars(layout:list)} {
			set tooltip DetailedLayout
			set Options(show:layout) list
			set layout details
		} else {
			set tooltip ListLayout
			set Options(show:layout) details
			set layout list
		}
		::toolbar::childconfigure $Vars(widget:layout) \
			-image [set icon::16x16::$layout] \
			-tooltip [Tr $tooltip] \
			;
	} elseif {$layout eq $Options(show:layout)} {
		return
	}
	
	set t $Vars(widget:filelist)
	set selection [$t selection get]

	switch $Options(show:layout) {
		details {
			DetailsLayout $w
			$t xview moveto 0.0
		}
		list {
			ListLayout $w
		}
	}

	Glob $w no
	catch { $t see 1 }
	$t activate 0
	foreach sel $selection {
		$t selection add $sel
		$t activate $sel
		$t see $sel
	}
}


proc ColumnResized {w col} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)

	foreach id {name size modified} {
		set Vars(column:$id) [$t column width $id]
	}
}


proc GetFileIcon {w filename} {
	variable [namespace parent]::${w}::Vars

	foreach {ext icon} $Vars(fileicons) {
		if {[string match *$ext $filename]} {
			return $icon
		}
	}

	return [set [namespace parent]::icon::16x16::document]
}


proc SortColumn {w {column ""}} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)

	if {[string length $column] == 0} {
		set column $Vars(sort-column)
		if {[$t column cget $column -arrow] eq "none"} { return }
	} else {
		set column [lindex [$t column tag names $column] 0]
		set arrow [$t column cget $Vars(sort-column) -arrow]
		if {$column eq $Vars(sort-column) || $arrow eq "none"} {
			if {$arrow eq "up"} { set order decreasing } else { set order increasing }
		} else {
			if {$arrow eq "up"} { set order increasing } else { set order decreasing }
		}
		$t column configure $Vars(sort-column) -arrow none
		set Vars(sort-column) $column
		set Vars(sort-order) $order
		switch $order {
			increasing { set arrow up }
			decreasing { set arrow down }
		}
		$t column configure $column -arrow $arrow
	}

	set dirCount [llength $Vars(list:folder)]
	set fileCount [expr {[$t item count] - 1 - $dirCount}]
	set totalCount [expr {$dirCount + $fileCount}]
	set lastDir [expr {$dirCount - 1}]

	switch [$t column cget $column -tags] {
		name {
			if {$dirCount} {
				$t item sort root -$Vars(sort-order) \
					-last [list root child $lastDir]  \
					-column $column                   \
					-dictionary                       \
					;
			}
			if {$fileCount} {
				$t item sort root -$Vars(sort-order)                \
					-first [list root child [expr {$lastDir + 1}]]   \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column                                  \
					-dictionary                                      \
					;
			}
		}

		size {
			if {$fileCount} {
				$t item sort root -$Vars(sort-order)                          \
					-first [list root child [expr {$lastDir + 1}]]             \
					-last [list root child [expr {$totalCount - 1}]]           \
					-column $column                                            \
					-command [namespace code CompSize $Vars(widget:list:file)] \
					-column name                                               \
					-dictionary                                                \
					;
			}
		}

		modified {
			if {$dirCount} {
				$t item sort root -$Vars(sort-order) \
					-last [list root child $lastDir]  \
					-column $column                   \
					-integer                          \
					-column name                      \
					-dictionary                       \
					;
			}
			if {$fileCount} {
				$t item sort root -$Vars(sort-order)                \
					-first [list root child [expr {$lastDir + 1}]]   \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column                                  \
					-integer                                         \
					-column name                                     \
					-dictionary                                      \
					;
			}
		}
	}

	if {!$Vars(multiple)} {
		foreach sel [$t selection get] {
			$t see $sel
		}
	}
}


proc CompSize {t lhs rhs} {
	set lsize [regsub -all {[^0-9]} [$t item element cget $lhs 1 txtSize -text] ""]
	set rsize [regsub -all {[^0-9]} [$t item element cget $rhs 1 txtSize -text] ""]
	return [expr {int($lsize) - int($rsize)}]
}


proc SetColumnBackground {t id stripes background} {
	if {[llength $stripes]} {
		$t column configure $id -itembackground [list $stripes $background]
	} else {
		$t column configure $id -itembackground $background
	}
}


proc Glob {w refresh} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	if {$refresh || ![info exists Vars(list:folder)]} {
		[namespace parent]::busy $w

		switch $Vars(glob) {
			Files {
				switch $Vars(sort-order) {
					increasing { set arrow up }
					decreasing { set arrow down }
				}
				set state normal
				set filter *
				if {$Options(show:hidden)} { lappend filter .* }
				set folders [glob -nocomplain -directory $Vars(folder) -types d {*}$filter]
				set folders [lsort -dictionary $folders]
			}

			Favorites {
				variable [namespace parent]::bookmarks::Bookmarks

				set arrow none
				set state disabled
				set bookmarks {}
				foreach entry $Bookmarks(favorites) {
					if {[file isdirectory [lindex $entry 0]]} {
						lappend bookmarks $entry
					}
				}
				set Bookmarks(favorites) $bookmarks
				set folders {}
				foreach entry $Bookmarks(favorites) {
					set folder [lindex $entry 0]
					if {[string index $folder 0] ne "." || $Options(show:hidden)} { 
						lappend folders $folder
					}
				}
			}

			LastVisited {
				variable [namespace parent]::bookmarks::Bookmarks

				set arrow none
				set state disabled
				set bookmarks {}
				foreach entry $Bookmarks(lastvisited) {
					if {[file isdirectory $entry]} {
						lappend bookmarks $entry
					}
				}
				set Bookmarks(lastvisited) $bookmarks
				set folders {}
				foreach folder $Bookmarks(lastvisited) {
					if {[string index $folder 0] ne "." || $Options(show:hidden)} { 
						lappend folders $folder
					}
				}
			}
		}

		$Vars(widget:filelist) column configure $Vars(sort-column) -arrow $arrow
		::toolbar::childconfigure $Vars(button:new) -state $state

		set Vars(list:folder) {}
		set filelist {}

		foreach folder $folders {
			set d [file tail $folder]
			if {$d ne "." && $d ne ".."} {
				lappend Vars(list:folder) $folder
			}
		}

		if {$Vars(glob) eq "Files" && $Vars(type) ne "dir"} {
			set filter *
			if {$Options(show:hidden)} { lappend filter .* }
			set files [glob -nocomplain -directory $Vars(folder) -types f {*}$filter]

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
					lappend filelist $file
				}
			}
		}

		[namespace parent]::unbusy $w
	}

	set t $Vars(widget:filelist)
	foreach folder $Vars(list:folder) $Vars(scriptDir)
	if {[llength $Vars(list:folder)]} {
		$Vars(widget:filelist) item tag add "root children" directory
	}

	set Vars(list:file) {}
	foreach file $filelist {
		eval $Vars(scriptFile)
		if {$valid} { lappend Vars(list:file) $file }
	}

	if {$Vars(glob) eq "Files" && ($Vars(sort-column) ne "name" || $Vars(sort-order) ne "increasing")} {
		SortColumn $w
	}
}


proc InvokeFile {w args} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)

	if {[llength $args] == 2} {
		lassign $args x y
		set id [$t identify $x $y]
		if {[llength $id] == 0 || [lindex $id 0] eq "header"} { return }
		set sel [$t item order [lindex $id 1] -visible]
	} else {
		set sel [expr {[$t item id active] - 1}]
	}

	if {$sel < 0} { return }

	if {$sel >= [llength $Vars(list:folder)]} {
		SelectFiles $w [expr {$sel - [llength $Vars(list:folder)]}]]
		if {!$Vars(multiple)} { [namespace parent]::Activate $w }
	} elseif {$Vars(type) ne "dir"} {
		[namespace parent]::VisitItem $w $t leave [expr {$sel + 1}]
		set folder [lindex $Vars(list:folder) $sel]
		[namespace parent]::ChangeDir $w $folder
		after idle [list [namespace parent]::VisitItem $w $t enter [expr {$sel + 1}]]
	} else {
		SelectFiles $w $sel
		if {!$Vars(multiple)} { [namespace parent]::Activate $w }
	}
}


proc RefreshFileList {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	set Vars(lock:selection) 1
	$t item delete all
	Glob $w yes
	set n "root"
	$t xview moveto 0.0
	$t yview moveto 0.0
	set folders $Vars(selected:folders)
	set files $Vars(selected:files)
	set Vars(selected:folders) {}
	set Vars(selected:files) {}

	foreach folder $folders {
		set i [lsearch -exact $Vars(list:folder) $folder]
		if {$i >= 0} {
			set n [expr {$i + 1}]
			$t selection add $n
			lappend Vars(selected:folders) $folder
		}
	}

	foreach file $files {
		set i [lsearch -exact $Vars(list:file) $file]
		if {$i >= 0} {
			set n [expr {$i + 1 + [llength $Vars(list:folder)]}]
			$t selection add $n
			$t activate $n
			lappend Vars(selected:files) $file
		}
	}

	set Vars(lock:selection) 0
	$t activate $n

	if {[string is integer $n]} {
		$t see $n
	}

	ConfigureButtons $w
}


proc ConfigureButtons {w} {
	variable [namespace parent]::${w}::Vars

	if {$Vars(glob) ne "Files"} {
		set state disabled
	} elseif {[llength $Vars(selected:folders)] + [llength $Vars(selected:files)] == 1} {
		set state normal
	} else {
		set state disabled
	}
	::toolbar::childconfigure $Vars(button:delete) -state $state
	::toolbar::childconfigure $Vars(button:rename) -state $state
}


proc SelectFiles {w selection} {
	variable [namespace parent]::${w}::Vars

	if {$Vars(lock:selection)} { return }

	set Vars(selected:folders) {}
	set Vars(selected:files) {}

	set selection [lsort -integer -unique [$Vars(widget:filelist) selection get]]

	foreach n $selection {
		if {$n <= [llength $Vars(list:folder)]} {
			set folder [lindex $Vars(list:folder) [expr {$n - 1}]]
			lappend Vars(selected:folders) $folder
			CheckDir $w $folder
			CheckFile $w
		} else {
			set file [lindex $Vars(list:file) [expr {$n - [llength $Vars(list:folder)] - 1}]]
			lappend Vars(selected:files) $file
			CheckDir $w
			CheckFile $w $file
		}
	}

	switch $Vars(type) {
		dir		{ set type folders }
		default	{ set type files }
	}

	set filenames ""
	foreach file $Vars(selected:$type) {
		if {[llength $Vars(selected:$type)] > 1 && [string first " " $file] >= 0} {
			set delim "\""
		} else {
			set delim ""
		}
		if {[string length $filenames]} { append filenames " " }
		append filenames $delim
		append filenames [file tail $file]
		append filenames $delim
	}
	if {[string length $filenames]} {
		set Vars(initialfile) $filenames
	}

	ConfigureButtons $w
}


proc CheckFile {w {file ""}} {
	if {[llength $file]} { [namespace parent]::CheckEncoding $w $file }
}


proc CheckDir {w {folder  ""}} {
	# nothing to do
}


proc DeleteFile {w} {
	variable [namespace parent]::${w}::Vars

	[namespace parent]::busy $w
	set t $Vars(widget:filelist)
	set sel [expr {[$t item id active] - 1}]

	if {$sel < [llength $Vars(list:folder)]} {
		set type folder
	} else {
		set sel [expr {$sel - [llength $Vars(list:folder)]}]
		set type file
	}

	if {![info exists Vars(iskde)]} {
		if {[tk windowingsystem] eq "x11"} {
			set atoms {}
			catch {set atoms [exec /bin/sh -c "xlsatoms | grep _KDE_RUNNING"]}
			set Vars(iskde) [expr {[llength $atoms] > 0}]
		} else {
			set Vars(iskde) 0
		}
		if {$Vars(iskde)} {
			set Vars(exec:delete) [auto_execok kioclient]
			if {[llength $Vars(exec:delete)] == 0} {
				set Vars(exec:delete) [auto_execok kfmclient]
			}
		}
	}

	set file [lindex $Vars(list:$type) $sel]
	if {$Vars(iskde)} { set var ReallyMove($type) } else { set var ReallyDelete($type) }
	set msg [format [Tr $var] [lindex [file split $file] end]]
	foreach item [$t item children root] { $t item state set $item {!hilite} }
	set reply [[namespace parent]::messageBox \
					-type yesno                   \
					-icon question                \
					-parent $Vars(widget:main)    \
					-message $msg                 \
					-default no                   \
	]
	after idle [list [namespace parent]::Stimulate $w]

	if {$reply ne "yes" } {
		[namespace parent]::unbusy $w
		return
	}

	if {$Vars(iskde)} {
		if {$type eq "file" && [llength $Vars(deletecommand)] > 0} {
			set cmd "$Vars(exec:delete) move "
			set delim ""
			foreach f [{*}$Vars(deletecommand) $file] {
				if {[file exists $f]} {
					append cmd $delim
					append cmd "\"$f\""
					set delim " "
				}
			}
			append cmd " trash:/"
		} else {
			set cmd "$Vars(exec:delete) move \"$file\" trash:/"
		}

		if {[catch {exec /bin/sh -c $cmd}]} {
			# Oops, kioclient is always returning an error
		}
	} elseif {$type eq "file"} {
		if {[llength $Vars(deletecommand)] > 0} {
			set files {}
			set delim ""
			foreach f [{*}$Vars(deletecommand) $file] {
				if {[file exists $f]} { lappend files $f }
			}
		} else {
			set files [list $file]
		}

		if {[catch {file delete {*}$files}]} {
			# XXX error: what should we do?
		}
	} elseif {[catch {file delete -force $file}]} {
		# XXX error: what should we do?
	} else {
		[namespace parent]::bookmarks::LayoutBookmarks $w
	}

	RefreshFileList $w
	[namespace parent]::unbusy $w

	if {$file in $Vars(list:$type)} {
		set msg [format [Tr DeleteFailed] $file]
		set detail [format [Tr CommandFailed] $cmd]
		[namespace parent]::messageBox \
			-type ok                    \
			-icon error                 \
			-parent $Vars(widget:main)  \
			-message $msg               \
			-detail $detail             \
			;
	}
}


proc RenameFile {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)
	set sel [$t item id active]
	$t selection clear
	set Vars(edit:active) 1
	foreach item [$t item children root] { $t item state set $item {!hilite} }
	OpenEdit $w $sel rename
}


proc NewFolder {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)
	$t item delete all
	foreach folder $Vars(list:folder) $Vars(scriptDir)
	foreach folder [list [Tr NewFolder]] $Vars(scriptNew)
	$t item tag add "root children" directory
	foreach file $Vars(list:file) { eval $Vars(scriptFile) }
	set sel [expr {[llength $Vars(list:folder)] + 1}]
	$t see $sel
	set Vars(edit:active) 1
	foreach item [$t item children root] { $t item state set $item {!hilite} }
	OpenEdit $w $sel new
}


proc OpenEdit {w sel mode} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)
	set e [::TreeCtrl::EntryExpanderOpen $t $sel 0 txtName 0 [namespace code [list SelectFileName $w]]]
	set vcmd { return [::fsbox::validatePath %P] }
	$e configure                \
		-validate key            \
		-validatecommand $vcmd   \
		-invalidcommand { bell } \
		;
	set Vars(edit:sel) $sel
	set Vars(edit:mode) $mode
	set Vars(edit:accept) 0
	::TreeCtrl::TryEvent $t Edit begin [list I $sel C 0 E txtName]
}


proc SelectFileName {w e file} {
	variable [namespace parent]::${w}::Vars

	set end -1

	foreach ext $Vars(extensions) {
		if {[string match *$ext $file]} {
			set end [max $end [expr {[string length $file] - [string length $ext]}]]
		}
	}

	if {$end == -1} { set end end }
	$e selection range 0 $end
	$e icursor $end
}


proc EditAccept {w} {
	variable [namespace parent]::${w}::Vars
	set Vars(edit:accept) 1
}


proc FinishEdit {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:filelist)
	set sel $Vars(edit:sel)
	set name [string trim [$t item element cget $sel 0 txtName -text]]

	switch $Vars(edit:mode) {
		rename	{ FinishRenameFile $w $sel $name }
		new		{ FinishNewFolder $w $sel $name }
	}

	after idle [list [namespace parent]::Stimulate $w]
}


proc FinishRenameFile {w sel name} {
	variable [namespace parent]::${w}::Vars

	set Vars(edit:active) 0
	set name [string trim $name]
	set t $Vars(widget:filelist)
	$t selection add $sel
	set i [expr {$sel - 1}]
	if {$i < [llength $Vars(list:folder)]} {
		set type folder
	} else {
		set i [expr {$i - [llength $Vars(list:folder)]}]
		set type file
	}
	set oldName [lindex $Vars(list:$type) $i]
	if {[string length $name]} {
		set newName [file join $Vars(folder) $name]
	} else {
		set newName [lindex [file split $oldName] end]
		set name $newName
	}
	if {$oldName ne $newName} {
		if {[[namespace parent]::CheckPath $w $name]} {
			set k [lsearch $Vars(list:folder) $newName]
			if {$k == -1} { set k [lsearch $Vars(list:file) $newName] }
			if {$k >= 0} {
				[namespace parent]::messageBox \
					-type ok \
					-icon error \
					-parent $Vars(widget:main) \
					-message [format [Tr CannotRename] $name] \
					;
				set name [lindex [file split $oldName] end]
			} else {
				set ok 1
				if {$type eq "file" && [llength $Vars(renamecommand)] > 0} {
					set files [{*}$Vars(renamecommand) $oldName $newName]
					if {[llength $files] == 0} {
						set ok 0
						set new $newName
					} else {
						set undoList {}
						foreach {old new} $files {
							if {[file exists $old]} {
								if {[catch {file rename $old $new}]} {
									foreach {f g} $undoList { catch { file rename $g $f } }
									set ok 0
									break
								} else {
									lappend undoList $old $new
								}
							}
						}
					}
				} elseif {[catch {file rename $oldName $newName}]} {
					set old [lindex [file split $oldName] end]
					set new [lindex [file split $newName] end]
					set ok 0
				}
				if {$ok} {
					lset Vars(list:$type) $i $newName
				} else {
					if {[llength $files] == 0} {
						set msg [format [Tr InvalidFileExt] $new]
					} else {
						set msg [Tr ErrorRenaming($type)]
						set msg [string map [list %old $old %new $new] $msg]
					}
					[namespace parent]::messageBox \
						-type ok                    \
						-icon error                 \
						-parent $Vars(widget:main)  \
						-message $msg               \
						;
					set name [lindex [file split $oldName] end]
				}
			}
		} else {
			set name [lindex [file split $oldName] end]
		}
	}
	$t item element configure $sel 0 txtName -text $name
}


proc FinishNewFolder {w sel name} {
	variable [namespace parent]::${w}::Vars

	set name [string trim $name]

	if {$Vars(edit:accept) && [string length $name]} {
		set folder [file join $Vars(folder) $name]
		set k [lsearch $Vars(list:folder) $folder]
		if {$k == -1} { set k [lsearch $Vars(list:file) $folder] }
		if {$k >= 0} {
			[namespace parent]::messageBox               \
				-type ok                                  \
				-icon error                               \
				-parent $Vars(widget:main)                \
				-message [format [Tr CannotCreate] $name] \
				;
			RefreshFileList $w
		} elseif {[catch {file mkdir $folder}]} {
			[namespace parent]::messageBox      \
				-type ok                         \
				-icon error                      \
				-parent $Vars(widget:main)       \
				-message [Tr ErrorCreate($type)] \
				;
			RefreshFileList $w
		} elseif {[[namespace parent]::CheckPath $w $name]} {
			$Vars(widget:filelist) item element configure $sel 0 txtName -text $name
			lappend Vars(list:folder) $folder
		} else {
			RefreshFileList $w
		}
	} else {
		RefreshFileList $w
	}
}


proc SetTooltip {w which folder} {
	variable [namespace parent]::${w}::Vars

	if {$folder eq "Favorites" || $folder eq "LastVisited"} {
		set folder [Tr $folder]
	}
	set Vars(tip:[string tolower $which]) [format [Tr $which] $folder]
}


proc Undo {w} {
	variable [namespace parent]::${w}::Vars

	if {$Vars(undo:current) >= 1} {
		set folder [lindex $Vars(undo:history) $Vars(undo:current)]
		incr Vars(undo:current) -1
		[namespace parent]::ChangeDir $w [lindex $Vars(undo:history) $Vars(undo:current)] 0
		if {$Vars(undo:current) == 0} {
			::toolbar::childconfigure $Vars(button:backward) -state disabled
			set Vars(tip:backward) ""
		} else {
			SetTooltip $w Backward [lindex $Vars(undo:history) [expr {$Vars(undo:current) - 1}]]
			::toolbar::childconfigure $Vars(button:backward) -tooltip $Vars(tip:backward)
			after idle [[namespace parent]::tooltip show $Vars(button:backward) $Vars(tip:backward)]
		}
		SetTooltip $w Forward $folder
		::toolbar::childconfigure $Vars(button:forward) -state normal -tooltip $Vars(tip:forward)
	}
}


proc Redo {w} {
	variable [namespace parent]::${w}::Vars

	if {$Vars(undo:current) < [llength $Vars(undo:history)] - 1} {
		set folder [lindex $Vars(undo:history) $Vars(undo:current)]
		incr Vars(undo:current)
		[namespace parent]::ChangeDir $w [lindex $Vars(undo:history) $Vars(undo:current)] 0
		if {$Vars(undo:current) == [llength $Vars(undo:history)] - 1} {
			::toolbar::childconfigure $Vars(button:forward) -state disabled
			set Vars(tip:forward) ""
		} else {
			SetTooltip $w Forward [lindex $Vars(undo:history) [expr {$Vars(undo:current) + 1}]]
			::toolbar::childconfigure $Vars(button:forward) -tooltip $Vars(tip:forward)
			after idle [[namespace parent]::tooltip show $Vars(button:forward) $Vars(tip:forward)]
		}
		SetTooltip $w Backward $folder
		::toolbar::childconfigure $Vars(button:backward) -state normal -tooltip $Vars(tip:backward)
	}
}


proc PopupMenu {w x y} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	set t $Vars(widget:filelist)
	set id [$t identify $x $y]
	if {[llength $id] == 0 || [lindex $id 0] eq "header"} { return }
	foreach item [$t item children root] { $t item state set $item {!hilite} }

	set m $w.menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false

	if {$Vars(glob) eq "Files"} {
		set sel [$t item id active]
		if {$sel in [$t selection get]} {
			$m add command                                    \
				-compound left                                 \
				-image $icon::16x16::delete                    \
				-label " [Tr Delete]"                          \
				-command [namespace code [list DeleteFile $w]] \
				;
			$m add command                                    \
				-compound left                                 \
				-image $icon::16x16::modify                    \
				-label " [Tr Rename]"                          \
				-command [namespace code [list RenameFile $w]] \
				;
		}
		$m add command                                   \
			-compound left                                \
			-image $icon::16x16::folder_add               \
			-label " [Tr NewFolder]"                      \
			-command [namespace code [list NewFolder $w]] \
			;
		$m add separator
	}
	set count 0
	if {[string length $Vars(tip:backward)]} {
		$m add command                              \
			-compound left                           \
			-image $icon::16x16::backward            \
			-label " $Vars(tip:backward)"            \
			-command [namespace code [list Undo $w]] \
			;
		incr count
	}
	if {[string length $Vars(tip:forward)]} {
		$m add command                              \
			-compound left                           \
			-image $icon::16x16::forward             \
			-label " $Vars(tip:forward)"             \
			-command [namespace code [list Redo $w]] \
			;
		incr count
	}
	if {$count} { $m add separator }
	set sub [menu $m.layout -tearoff false]
	$m add cascade -menu $sub -label " [Tr Layout]"
	$sub add radiobutton                                     \
		-compound left                                        \
		-image $icon::16x16::list                             \
		-label " [Tr DetailedLayout]"                         \
		-variable [namespace parent]::Options(show:layout)    \
		-command [namespace code [list SwitchLayout $w list]] \
		-value details                                        \
		;
	$sub add radiobutton                                        \
		-compound left                                           \
		-image $icon::16x16::details                             \
		-label " [Tr ListLayout]"                                \
		-variable [namespace parent]::Options(show:layout)       \
		-command [namespace code [list SwitchLayout $w details]] \
		-value list                                              \
		;
	if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
	variable _ShowHidden $Options(show:hidden)
	$m add checkbutton                                  \
		-compound left                                   \
		-image [set icon::16x16::${ipref}locked]         \
		-label " [Tr ShowHiddenFiles]"                   \
		-command [namespace code [list SwitchHidden $w]] \
		-variable [namespace current]::_ShowHidden       \
		;

	set Vars(edit:active) 1
	tk_popup $m {*}[winfo pointerxy $w]
	bind $m <<MenuUnpost>> [list [namespace parent]::Stimulate $w]
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

#set ok [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
#	CXBIWXMAAABIAAAASABGyWs+AAACp0lEQVQ4y42TT0gUYRjGn2/mm53Z2XHdXbc1U9HV/kiB
#	JZZ0COoSJIKhYVaHLtI/KDoUBUV2KKIiIsqrh6jsz8WQDtalTkEURVoGIbGs7j/Ndt1dd2d2
#	5vu+DlERFfqeXnh5Hl54fo+MJYykU7irDdXXsIzZRQvcZL9u8lIM1CoP9DbfHWNtsJ/bdq3k
#	kUuhlppY7kta0KUYyG6pMrStoaulb6dWx8LN5F3yzPiT5zFAnJAWFWsUvqbg8aqeJk0mCrwu
#	L9ZvbIM/GPRnW3KRRT8oa6qoUbeWH5MNBQIClmNh8NrV9As6ultqk95QAFBUBXrAAJM5mMVQ
#	nM0DAPRqL8gKcim4v85gsGGxPO6fuxiLhD+1Q8eE3k8ZDW6uoQS806GsVTNUTRDpgTQmvy7l
#	LahhvdnXG9onFA6bm3h7fTiTrI10MG5/VM6CLyzkQfOzmd5Al+9uoN0PYgBz9+YO8km+zu3x
#	ROlyesHY4ZcZL2Fq8H0xoUR2sXL2QT+v8OzXDGALyGWNgUnmWAeMTYYHLgJttebKxvMpl6ES
#	o8d72dXoJumHCTs2G9krtcrP5FMlVpxegGDiByOFz/NF5NXbPMsAR0DySOCErbF95g19i0Hm
#	R2ZYfDraJzaQEXa6wHiKg3P+OyXBOKiszBCvOKSGNQJKkB1Krwr1VdU7sRKSrxIn0UkH+eEC
#	41EGZjl/UsodDl3Tx4oTxThMALZA5dEqg1ZQJIZjQ6KX3pKvOAwZAlHif8UsAYAtO8LJiHdY
#	EIAJqLUupAbiY6JHOSI/YtwczQuetf/dEwD4NpaCE7VfOnEHIieQHEjErXZ0+01/QTxmHOL/
#	oJGfS3XHyvpcbnZcECSsPeh2pkoT4qbFFUdBybQWN/DWBWAxKwgJ82y7YPQpuDldWLRo3wEp
#	ZjhR3++h3QAAAABJRU5ErkJggg==
#}]

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

set disk [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABZElEQVQ4y8WSzU7CQBSFT38o
	PzaQKq3AaiIhcUNciMEYfAIfh40biQ+hT2SiwSU/GxdSqYiNpJ0KKrR06gIlaTBAwsKbTHIX
	93xzz5nhksnkGSHkiGfsoKgoSaxRDcuigSA0DcO45w5LpZvjcrmSDoBLaq+jRy2VgsXzuKvX
	b8WJ68KmFLFsDri+WgswqlZhmyZc12WiqqqmpmkAAF3Xoev6UjEhBACgaRpUVTV5bFj/DxB/
	G8Z8EELmHpfeyvPwfT8MyOxmcFGrgeOFFWIOirKNweAtDOi/9jfPwLZsiKKwcCJSBLK8Bd+b
	wugaf2cAAGltB47jgON4VE5PQoPNRhv5QgGf4y88GwZYECxu4HlTxOIJJOLxhVXZT2gAIEWj
	cCfuDPAxHMY8z1vplSGY95RS5PN7MwuMsfN2q7Uvy/J7Npcpdh47AjgOghh+jZdeL6A2ZQ6l
	U0mSRk/dLtzx+GHTf4Rvr/6GjnFu/ZQAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace fsbox


bind FSBox <KeyPress-Up>			{ TreeCtrl::SetActiveItem %W [TreeCtrl::UpDown %W active -1] }
bind FSBox <KeyPress-Down>			{ TreeCtrl::SetActiveItem %W [TreeCtrl::UpDown %W active +1] }
bind FSBox <KeyPress-Left>			{ TreeCtrl::SetActiveItem %W [TreeCtrl::LeftRight %W active -1] }
bind FSBox <KeyPress-Right>		{ TreeCtrl::SetActiveItem %W [TreeCtrl::LeftRight %W active +1] }
bind FSBox <KeyPress-Home>			{ TreeCtrl::SetActiveItem %W [%W item id {first visible state enabled}]}
bind FSBox <KeyPress-End>			{ TreeCtrl::SetActiveItem %W [%W item id {last visible state enabled}] }
bind FSBox <KeyPress-space>		{ TreeCtrl::SetActiveItem %W [%W item id active] }
bind FSBox <Shift-KeyPress-Down>	{ TreeCtrl::Extend %W below }
bind FSBox <Shift-KeyPress-Up>	{ TreeCtrl::Extend %W above }
bind FSBox <ButtonPress-1>			{ fsbox::SetActiveItem %W [TreeCtrl::ButtonPress1 %W %x %y] %s }
bind FSBox <ButtonRelease-1>		{ TreeCtrl::Release1 %W %x %y }
bind FSBox <Button1-Motion>		{ TreeCtrl::Motion1 %W %x %y }
bind FSBox <Button1-Leave>			{ TreeCtrl::Leave1 %W %x %y }
bind FSBox <Button1-Enter>			{ TreeCtrl::Enter1 %W %x %y }

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

# vi:set ts=3 sw=3:
