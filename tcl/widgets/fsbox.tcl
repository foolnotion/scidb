# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2011-2012 Gregor Cramer
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
set Restore							"Restore"
set Rename							"Rename"
set Duplicate						"Duplicate"
set CopyOf							"Copy of %s"
set NewFolder						"New Folder"
set Layout							"Layout"
set ListLayout						"List Layout"
set DetailedLayout				"Detailed Layout"
set ShowHiddenDirs				"Show Hidden Directories" ;# TODO unused
set ShowHiddenFiles				"Show Hidden Files and Directories"
set AppendToExisitingFile		"&Append to an existing file"
set Cancel							"&Cancel"
set Save								"&Save"
set Open								"&Open"

set AddBookmark					"Add Bookmark '%s'"
set RemoveBookmark				"Remove Bookmark '%s'"
set RenameBookmark				"Rename Bookmark '%s'"

set Filename						"File &name:"
set Filenames						"File &names:"
set Directory						"Directory:"
set FilesType						"Files of &type:"
set FileEncoding					"File &encoding:"

set Favorites						"Favorites"
set LastVisited					"Last Visited"
set FileSystem						"File System"
set Desktop							"Desktop"
set Trash							"Trash"
set Home								"Home"

set SelectEncoding				"Select the encoding of the database (opens a dialog)"
set SelectWhichType				"Select which type of file are shown"
set TimeFormat						"%d/%m/%y %I:%M %p"

set CannotChangeDir				"Cannot change to the directory \"%s\".\nPermission denied."
set DirectoryRemoved				"Cannot change to the directory \"%s\".\nDirectory is removed."
set ReallyMove(file,w)			"Really move file '%s' to trash?"
set ReallyMove(file,r)			"Really move write-protected file '%s' to trash?"
set ReallyMove(folder,w)		"Really move folder '%s' to trash?"
set ReallyMove(folder,r)		"Really move write-protected folder '%s' to trash?"
set ReallyDelete(file,w)		"Really delete file '%s'? You cannot undo this operation."
set ReallyDelete(file,r)		"Really delete write-protected file '%s'? You cannot undo this operation."
set ReallyDelete(link,w)		"Really delete link to '%s'?"
set ReallyDelete(link,r)		"Really delete link to '%s'?"
set ReallyDelete(folder,w)		"Really delete folder '%s'? You cannot undo this operation."
set ReallyDelete(folder,r)		"Really delete write-protected folder '%s'? You cannot undo this operation."
set DeleteFailed					"Deletion of '%s' failed."
set RstoreFailed					"Restoring '%s' failed."
set CommandFailed					"Command '%s' failed."
set CopyFailed						"Copying of file '%s' failed: permission denied."
set CannotCopy						"Cannot create a copy because file '%s' is already exisiting."
set CannotDuplicate				"Cannot duplicate file '%s' due to the lack of read permission."
set ReallyDuplicateFile			"Really duplicate this file?"
set ReallyDuplicateDetail		"This file has about %s. Duplicating this file may take some time."
set ErrorRenaming(folder)		"Error renaming folder '%old' to '%new': permission denied."
set ErrorRenaming(file)			"Error renaming file '%old' to '%new': permission denied."
set InvalidFileExt				"Operation failed: '%s' has an invalid file extension."
set CannotRename					"Cannot rename to '%s' because this folder/file already exists."
set CannotCreate					"Cannot create folder '%s' because this folder/file already exists."
set ErrorCreate					"Error creating folder: permission denied."
set FilenameNotAllowed			"Filename '%s' is not allowed."
set ContainsTwoDots				"Contains two consecutive dots."
set ContainsReservedChars		"Contains reserved characters: %s, or a control character (ASCII 0-31)."
set InvalidFileName				"A filename cannot start with a hyphen, and cannot end with a space or a period."
set IsReservedName				"On some operating systems this is an reserved name."
set FilenameTooLong				"A file name should have less than 256 characters."
set InvalidFileExtension		"Invalid file extension in '%s'."
set MissingFileExtension		"Missing file extension in '%s'."
set FileAlreadyExists			"File \"%s\" already exists.\n\nDo you want to overwrite it?"
set CannotOverwriteDirectory	"Cannot overwite directory '%s'."
set FileDoesNotExist				"File \"%s\" does not exist."
set DirectoryDoesNotExist		"Directory \"%s\" does not exist."
set CannotOpenOrCreate			"Cannot open/create '%s'. Please choose a directory."
set WaitWhileDuplicating		"Wait while duplicating file..."
set FileHasDisappeared			"File '%s' has disappeared."
set CannotDelete					"Cannot delete file '%s'."
set CannotRename					"Cannot rename file '%s'."
set CannotDeleteDetail			"This file is currently in use."
set CannotOverwrite				"Cannot overwrite file '%s'."
set PermissionDenied				"Permission denied for directory '%s'."

}

namespace import ::tcl::mathfunc::max

set duplicateFileSizeLimit 5000000

# possibly we should avoid "{}[]+=,;%", too especially ';' should be avoided!?
set reservedChars {\" \\ / : * < > ? |}

array set Options {
	show:hidden	0
	show:layout	details
	show:filetypeicons 1
	pane:favorites 0
	menu:headerbackground #ffdd76
	menu:headerforeground black
	tooltip:shorten-paths 0
}


proc fsbox {w type args} {
	variable Options
	variable icon::16x16::filesystem

	if {![namespace exists [namespace current]::${w}]} {
		namespace eval [namespace current]::${w} {}
	}
	variable ${w}::Vars

	array set opts {
		-font							TkTextFont
		-background					white
		-foreground					black
		-bookmarkswidth			120
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
		-multiple					0
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
		-duplicatecommand			{}
		-okcommand					{}
		-cancelcommand				{}
		-inspectcommand			{}
		-customcommand				{}
		-customfiletypes			{}
		-customicon					{}
		-customtooltip				{}
		-helpcommand				{}
		-helpicon					{}
		-helplabel					{}
		-isusedcommand				{}
		-actions						{delete rename copy new}
	}

	array set opts $args
	if {$opts(-multiple)} { set opts(-selectmode) extended } else { set opts(-selectmode) single }

	foreach option {	selectionbackground selectionforeground font multiple savemode
							activebackground activeforeground defaultextension defaultencoding
							inactivebackground inactiveforeground filetypes fileencodings
							fileicons showhidden sizecommand selectencodingcommand validatecommand
							deletecommand renamecommand duplicatecommand okcommand cancelcommand
							inspectcommand initialfile bookmarkswidth customcommand customicon
							customtooltip customfiletypes helpcommand helpicon helplabel
							isusedcommand actions} {
		set Vars($option) $opts(-$option)
		array unset opts -$option
	}

	if {$Options(pane:favorites) == 0} {
		set Options(pane:favorites) $Vars(bookmarkswidth)
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

	set Vars(delete:action) delete
	set filesystem $::choosedir::icon::16x16::fileSystem

	set Vars(type) $type
	set Vars(glob) Files
	set Vars(folder:home) [file nativename ~]
	set Vars(folder:desktop) [file join $Vars(folder:home) Desktop]
	if {![file isdirectory $Vars(folder:desktop)]} { set Vars(folder:desktop) "" }
	set Vars(folder:trash) [file join $Vars(folder:home) .local share Trash files]
	if {![file isdirectory $Vars(folder:trash)]} { set Vars(folder:trash) "" }
	if {![CheckIsKDE $w]} { set Vars(folder:trash) "" }
	set Vars(folder:filesystem) [fileSeparator]
	set Vars(bookmark:folder) ""
	set Vars(edit:active) 0
	set Vars(lookup:$Vars(folder:home)) home
	set Vars(lookup:$Vars(folder:filesystem)) filesystem
	set Vars(history:folder) ""
	if {[llength $Vars(folder:desktop)]} { set Vars(lookup:$Vars(folder:desktop)) desktop }
#	if {[llength $Vars(folder:trash)]} { set Vars(lookup:$Vars(folder:trash)) trash }

	set Vars(icon:lastvisited) $icon::16x16::visited
	set Vars(icon:favorites) $icon::16x16::star
	set Vars(icon:desktop) $icon::16x16::desktop
	set Vars(icon:filesystem) $icon::16x16::filesystem
	set Vars(icon:trash) $icon::16x16::trash
	set Vars(icon:home) $icon::16x16::home

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
	set Vars(choosedir) \
		[choosedir $top.folder -initialdir $Vars(folder) -showlabel 1 -showhidden $Options(show:hidden)]
	bind $Vars(choosedir) <<SetDirectory>> [namespace code [list ChangeDir $w %d]]
	bind $Vars(choosedir) <<SetFolder>>    [namespace code [list ChangeDir $w %d]]
	bind $Vars(choosedir) <<GetStartMenu>> [namespace code [list GetStartMenu $w]]

	tk::panedwindow $top.main -sashwidth 7 -sashrelief flat
	set Vars(widget:panedwindow) $top.main

	if {$Vars(type) eq "dir"} {
		set Vars(multiple) 0
		set lbl [Tr Directory]
	} elseif {$Vars(multiple)} {
		set lbl [Tr Filenames]
	} else {
		set lbl [Tr Filename]
	}
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

	set Vars(widget:encoding:label) [::tk::AmpWidget ttk::label $top.lbl_encoding -text [Tr FileEncoding]]
	set Vars(widget:encoding:entry) [ttk::entrybuttonbox $top.ent_encoding \
		-width 14 \
		-textvar [namespace current]::${w}::Vars(encodingVar) \
		-command [namespace code [list SelectEncoding $w]] \
	]
	bind $Vars(widget:encoding:label) <<AltUnderlined>> [list $Vars(widget:encoding:entry) invoke]
	tooltip $top.ent_encoding [Tr SelectEncoding]

	if {[llength $Vars(selectencodingcommand)]} {
		set Vars(encodingVar) $Vars(defaultencoding)
		set Vars(encodingDefault) ""
		set Vars(encodingUser) ""
	}

	if {[llength $Vars(filetypes)]} {
		::tk::AmpWidget ttk::label $top.lbl_filetype -text [Tr FilesType]
		ttk::tcombobox $top.ent_filetype  \
			-state readonly                \
			-format "%1 (%2)"              \
			-padding 1                     \
			;
		bind $top.ent_filetype <<ComboboxSelected>> [namespace code [list SelectFileTypes $w %W]]
		bind $top.lbl_filetype <<AltUnderlined>> [list ::ttk::combobox::Post $top.ent_filetype]
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
		grid columnconfigure $top {4} -minsize 10
		grid columnconfigure $top {6} -minsize 5
		grid columnconfigure $top {7} -minsize 0
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
			-text [Tr AppendToExisitingFile] \
			-command [namespace code [list SetupSaveMode $w]] \
			-onvalue append \
			-offvalue overwrite \
		]
	}
	set Vars(button:ok) [tk::AmpWidget ttk::button $buttons.ok \
		-class TButton \
		-default active \
		-compound left \
		-command [namespace code [list Activate $w yes]] \
	]
	set Vars(button:cancel) [tk::AmpWidget ttk::button $buttons.cancel  \
		-class TButton \
		-default normal \
		-compound left \
		-image $icon::16x16::cancel \
		-command [namespace code [list Cancel $w]] \
	]
	if {[llength $Vars(helpcommand)]} {
		tk::AmpWidget ttk::button $buttons.help  \
			-class TButton \
			-default normal \
			-compound left \
			-image $Vars(helpicon) \
			-command [list $Vars(helpcommand) $w] \
			;
	}
	set utype [string toupper $Vars(type) 0 0]
	if {$utype eq "Dir"} { set utype Open }
	tk::SetAmpText $buttons.cancel " [Tr Cancel]"
	tk::SetAmpText $buttons.ok " [Tr $utype]"
	if {[llength $Vars(helpcommand)]} {
		tk::SetAmpText $buttons.help " $Vars(helplabel)"
	}
	changeFileDialogType $w $type

	bind $Vars(button:ok) <Return> [namespace code { InvokeOk %W }]
	bind $Vars(button:cancel) <Return> [namespace code [list Cancel $w]]

	if {$type eq "save"} { useSaveMode $w $Vars(savemode) }
	if {[llength $Vars(helpcommand)]} { pack $buttons.help -pady 5 -padx 5 -fill x -side left }
	pack $Vars(button:cancel) -pady 5 -padx 5 -fill x -side right
	pack $Vars(button:ok) -pady 5 -padx 5 -fill x -side right

	bind $top.main <<ThemeChanged>> [namespace code [list ThemeChanged $w]]

	set tl [winfo toplevel $top]
	bind $tl <Escape>		[list $Vars(button:cancel) invoke]
	bind $tl <Return>		[list $Vars(button:ok) invoke]
	bind $tl <Alt-Key>	[namespace code [list AltKeyInDialog $top $tl %A]]
	bind $tl <Alt-Left>	[namespace code [list Undo $top $w]]
	bind $tl <Alt-Right>	[namespace code [list Redo $top $w]]
	if {[llength $Vars(helpcommand)]} {
		bind $tl <F1>		[list $Vars(helpcommand) $w]
	}

	array unset Vars widget:list:file
	setFileTypes $w $Vars(filetypes) $Vars(defaultextension)

	bookmarks::Build $w $top.main.fav {*}[array get opts]
	filelist::Build $w $top.main.list {*}[array get opts]
	set Vars(widget:favorites) $top.main.fav

	$top.main add $top.main.fav  -minsize 0 -sticky nsew -stretch last
	$top.main add $top.main.list -minsize 300 -sticky nsew -stretch always

	bind $top.main.fav <Configure> [namespace code { ConfigurePane %w }]

	CheckInitialFile $w
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
	set Vars(selectencodingcommand) {}
	set Vars(fileencodings) {}
	set Vars(initialfile) ""

	foreach option {	multiple defaultextension defaultencoding filetypes fileencodings
							showhidden sizecommand selectencodingcommand deletecommand
							renamecommand okcommand cancelcommand initialfile} {
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

	::toolbar::childconfigure $Vars(button:forward) -state disabled
	::toolbar::childconfigure $Vars(button:backward) -state disabled

	if {[llength $Vars(selectencodingcommand)]} {
		set Vars(encodingVar) $Vars(defaultencoding)
		set Vars(encodingDefault) ""
		set Vars(encodingUser) ""
	}

	set Vars(undo:history) {}
	set Vars(undo:current) -1
	set Vars(tip:forward) ""
	set Vars(tip:backward) ""

	CheckInitialFile $w
	DirChanged $w 0
	changeFileDialogType $w $type
	setFileTypes $w $Vars(filetypes) $Vars(defaultextension)
	filelist::RefreshFileList $w
	focus $Vars(widget:filename)
}


proc countRows {w} {
	variable ${w}::Vars
	return $Vars(rows:computed)
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

	if {![info exists Vars(widget:filetypes:combobox)]} { return }

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
					append types "$ext"
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

	UpdateFileTypesState $w

	if {[info exists Vars(widget:list:file)]} {
		filelist::RefreshFileList $w
	}
}


proc lastFolder {w} {
	variable ${w}::Vars

	if {[info exists Vars(lastFolder)]} { return $Vars(lastFolder) }
	return ""
}


proc fileSeparator {} {
	if {$::tcl_platform(platform) == "windows"} { return "\\" }
	return "/"
}


proc validateCharacters {path} {
	variable reservedChars

	if {[string length $path] == 0} { return 1 }
	foreach c [list $path] {
		# windows forbids the use of characters in range 1-31
		if {[string is control $c]} { return 0 }
	}
	# windows forbids the use of some characters
	set pattern *\[[join $reservedChars ""]\]*
	if {[string match $pattern $path]} { return 0 }
	return 1
}


proc validatePath {path} {
	variable reservedChars

	if {[string length $path] == 0} { return 1 }
	# hyphen must not be the first character
	if {[string index $path 0] eq "-"} { return 0 }
	# in windows the space and the period are not allowed as the final character of a filename
	if {[string is space [string index $path end]] || [string index $path end] eq "."} { return 0 }
	return 1
}


proc verifyPath {path} {
	if {$path eq "."} {
		return oneDot
	}
	# we do not allow two or more consecutive dots in filename
	if {[string first ".." $path] >= 0} {
		return twoDots
	}
	if {[string length $path] > 255} { return tooLong }
	# be sure filename is portable (since we support unix, windows and mac)
	if {![validateCharacters $path]} { return reservedChar }
	if {![validatePath $path]} { return invalidName }
	if {[string toupper $path] in { CON PRN AUX CLOCK\$ NUL
			COM0 COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8 COM9
			LPT0 LPT1 LPT2 LPT3 LPT4 LPT5 LPT6 LPT7 LPT8 LPT9
			\$MFT \$MFTMIRR \$LOGFILE \$VOLUME \$ATTRDEF \$BITMAP
			\$BOOT \$BADCLUS \$SECURE \$UPCASE \$EXTEND \$QUOTA
			\$OBJID \$REPARSE A.OUT CORE .PROFILE .HISTORY .CSHRC}} {
		return reservedName
	}
	return {}
}


proc tooltip {args} {}
proc mc {msg args} { return [::msgcat::mc [set $msg] {*}$args] }
proc messageBox {args} { return [tk_messageBox {*}$args] }
proc busy {w} {}
proc unbusy {w} {}
proc configureRadioEntry {sub text} {}


proc makeStateSpecificIcons {img} {
	return $img ;# XXX how to do?
}


proc checkIsKDE {} {
	variable _IsKDE

	if {![info exists _IsKDE]} {
		if {[tk windowingsystem] eq "x11"} {
			set atoms {}
			catch {set atoms [exec /bin/sh -c "xlsatoms | grep _KDE_RUNNING"]}
			set _IsKDE [expr {[string length $atoms] > 0}]
		} else {
			set _IsKDE 0
		}
	}

	return $_IsKDE
}


proc x11NoWindowDecor {w} {}


proc noWindowDecor {w} {
	switch [tk windowingsystem] {
		aqua	{ ::tk::unsupported::MacWindowStyle style $w plainDBox {} }
		win32	{ wm attributes $w -toolwindow }
		x11	{ x11NoWindowDecor $w }
	}
}


proc Tr {tok {args {}}} {
	return [mc [namespace current]::mc::$tok {*}$args]
}

namespace export Tr


proc GetFileSize {file mtime} {
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


proc CheckInitialFile {w} {
	variable ${w}::Vars

	if {$Vars(type) eq "dir"} {
		if {[string length $Vars(initialfile)] == 0} {
			set Vars(initialfile) [fileSeparator]
		}
		ChangeDir $w $Vars(initialfile)
	} elseif {[string length $Vars(initialfile)]} {
		set t $Vars(widget:list:file)
		set i [expr {[llength $Vars(list:folder)] + 1}]
		set sel 0
		foreach file $Vars(list:file) {
			set file [file tail $file]
			if {$file eq $Vars(initialfile)} { set sel $i }
			incr i
		}
		$t selection clear
		$t selection add $sel
		$t activate $sel
		$t see $sel
		filelist::SelectFiles $w [list $sel]
	}
}


proc CheckEncoding {w file} {
	variable ${w}::Vars

	if {[llength $Vars(selectencodingcommand)]} {
		if {[string length $Vars(encodingUser)] == 0} {
			set Vars(encodingVar) $Vars(defaultencoding)

			foreach {ext enable encoding} $Vars(fileencodings) {
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

	set file $Vars(initialfile)

	if {[llength $file]} {
		if {[string length [file extension $file]] == 0 && [string length $Vars(defaultextension)]} {
			append file $Vars(defaultextension)
		}
		CheckEncoding $w $file
	}
}


proc UpdateFileTypesState {w} {
	variable ${w}::Vars

	set top [winfo parent $Vars(widget:encoding:label)]

	if {[llength $Vars(selectencodingcommand)]} {
		set state disabled
		foreach {ext enable encoding} $Vars(fileencodings) {
			if {$ext in $Vars(extensions) && $enable} { set state normal }
		}
		$Vars(widget:encoding:entry) configure -state $state
		grid $Vars(widget:encoding:label) -row 5 -column 5
		grid $Vars(widget:encoding:entry) -row 5 -column 7
		grid $Vars(widget:filename) -columnspan 1
		grid columnconfigure $top {4} -minsize 10
		grid columnconfigure $top {6} -minsize 5
		grid columnconfigure $top {7} -minsize 0
	} else {
		grid remove $Vars(widget:encoding:label) $Vars(widget:encoding:entry)
		grid $Vars(widget:filename) -columnspan 5
		grid columnconfigure $top {7} -minsize 92
	}
}


proc SelectFileTypes {w combo} {
	variable ${w}::Vars

	set selection [$combo get]
	set i [string last " (" $selection]
	set selection [string range $selection 0 [expr {$i - 1}]]
	set i [lsearch -index 0 -exact $Vars(filetypes) $selection]
	set Vars(extensions) [lindex $Vars(filetypes) $i 1]

	UpdateFileTypesState $w
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


proc GetHeaderBackground {w} {
	set background [ttk::style lookup $::ttk::currentTheme -background]
	set activebg [ttk::style lookup $::ttk::currentTheme -activebackground]
	if {[llength $activebg] == 0} { set activebg [$w cget -background] }
	set background [list $background {!active} $activebg {active}]
}


proc ThemeChanged {w} {
	variable ${w}::Vars

	set background [ttk::style lookup $::ttk::currentTheme -background]
	set activebg [ttk::style lookup $::ttk::currentTheme -activebackground]
	if {[llength $activebg]== 0} { set activebg [$w cget -background] }

	foreach n {bookmark file} {
		set t $Vars(widget:list:$n)
		foreach id [$t column list] {
			$t column configure $id -background [GetHeaderBackground $w]
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
			enter {
				foreach i [$t item children root] { $t item state set $i {!hilite} }
				catch { $t item state set $item {hilite} }
			}

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


proc ScrollPage {w units} {
	set pages $units
	set active [$w item id active]

	if {$active > 0} {
		if {$pages > 0} {
			if {[lindex [$w yview] 0] == 0} {
				set last [$w item id [list nearest 0 [expr {[winfo height $w] - 1}]]]
				if {$active < $last} { set pages 0 }
			}
		} else {
			if {[lindex [$w yview] 1] == 1} {
				set first [$w item id {nearest 0 0}]
				if {$first < $active} { set pages 0 }
			}
		}
	}

	$w yview scroll $pages pages

	if {$active > 0} {
		if {$units > 0} {
			set activate [$w item id [list nearest 0 [expr {[winfo height $w] - 1}]]]
		} else {
			set activate [$w item id {nearest 0 0}]
		}
		$w activate $activate

		if {[$w cget -selectmode] eq "single"} {
			set selection [$w selection get]

			if {[llength $selection] == 1} {
				set sel [lindex $selection 0]

				if {$active eq $sel} {
					$w selection clear
					$w selection add $activate
				}
			}
		}
	}
}


proc HasFocus {w focus} {
	if {[llength $focus] > 0} {
		while {$focus ne "."} {
			if {$w eq $focus} { return 1 }
			set focus [winfo parent $focus]
		}
	}
	return 0
}


proc AltKeyInDialog {tl path key} {
	if {[HasFocus $tl [focus]]} { tk::AltKeyInDialog $path $key }
}


proc Undo {tl w} {
	if {[HasFocus $tl [focus]]} { filelist::Undo $w }
}


proc Redo {tl w} {
	if {[HasFocus $tl [focus]]} { filelist::Redo $w }
}


proc SbSet {sb first last} {
	if {$first <= 0 && $last >= 1} {
		grid remove $sb
	} elseif {$sb ni [grid slaves [winfo parent $sb]]} {
		grid $sb
	}
	$sb set $first $last
}


proc AddToHistory {w folder} {
	variable ${w}::Vars
	variable bookmarks::Bookmarks
	variable bookmarks::BookmarkSize

	if {[string length $folder] == 0} { return }

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


proc DirChanged {w {useHistory 1}} {
	variable ${w}::Vars
	variable bookmarks::Bookmarks

	set Vars(history:folder) ""

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

		if {$Vars(glob) eq "Files" && $folder ne [fileSeparator]} {
			set Vars(history:folder) $folder
		}
	}

	set Vars(bookmark:folder) ""
	foreach action {delete rename copy new} { set Vars(disable:$action) 0 }
	::toolbar::childconfigure $Vars(button:add) -state normal

	if {[string length $Vars(folder:trash)] > 0 && [string match $Vars(folder:trash)* $Vars(folder)]} {
		set action restore
	} else {
		set action delete
	}
	filelist::SetDeleteAction $w $action

	foreach f {desktop trash} {
		if {[string length $Vars(folder:$f)] > 0 && [string match $Vars(folder:$f)* $Vars(folder)]} {
			foreach action {delete rename copy new} { set Vars(disable:$action) 1 }
			::toolbar::childconfigure $Vars(button:add) -state disabled
		}
	}

	foreach f {home filesystem} {
		if {$Vars(folder) eq $Vars(folder:$f)} {
			::toolbar::childconfigure $Vars(button:add) -state disabled
		}
	}

	if {$Vars(glob) ne "Files"} {
		::toolbar::childconfigure $Vars(button:add) -state disabled
	} else {
		foreach f $Bookmarks(user) {
			if {$Vars(folder) eq [lindex $f 0]} {
				::toolbar::childconfigure $Vars(button:add) -state disabled
			}
		}
	}

	set Vars(bookmark:folder) $folder
	set tip [format [Tr AddBookmark] [file tail $folder]]
	::toolbar::childconfigure $Vars(button:add) -tooltip $tip
	filelist::ConfigureButtons $w
}


proc GetStartMenu {w} {
	variable ${w}::Vars
	variable bookmarks::Bookmarks

	foreach folder {Favorites LastVisited} {
		lappend start $Vars(icon:[string tolower $folder]) [Tr $folder] $folder
	}
	lappend start "" "" ""
	foreach folder {FileSystem Desktop Trash Home} {
		set id [string tolower $folder]
		if {[llength $Vars(folder:$id)]} {
			lappend start $Vars(icon:$id) [Tr $folder] $Vars(folder:$id)
		}
	}
	if {[llength $Bookmarks(user)]} {
		lappend start "" "" ""
		foreach entry $Bookmarks(user) {
			lassign $entry folder name
			if {[file isdirectory $folder]} {
				lappend start $icon::16x16::folder $name $folder
			}
		}
	}
	$Vars(choosedir) setstartmenu $start
}


proc ChangeDir {w path {useHistory 1}} {
	variable ${w}::Vars

	if {[catch {glob -nocomplain -directory $path -types d .*} result err]} {
		set msg [format [Tr PermissionDenied] $path]
		messageBox                    \
			-type ok                   \
			-icon error                \
			-parent $Vars(widget:main) \
			-message $msg              \
			;
		return
	}

	set Vars(prevFolder) $Vars(folder)
	if {[string length $Vars(prevFolder)] == 0} {
		set Vars(prevFolder) $Vars(glob)
	}

	switch $path {
		Favorites - LastVisited {
			set Vars(glob) $path
			set Vars(folder) {}
			$Vars(choosedir) setfolder [Tr $path] $Vars(icon:[string tolower $path])
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
				if {![file isdirectory $path]} { filelist::RefreshFileList $w }
				return
			}

			if {[info exists Vars(lookup:$path)]} {
				set icon [set icon::16x16::$Vars(lookup:$path)]
			} elseif {	[string length $Vars(folder:trash)] > 0
						&& [string match $Vars(folder:trash)* $path]} {
				set icon $Vars(icon:trash)
			} else {
				set icon ""
			}
			set Vars(folder) [pwd]
			cd $appPWD
			$Vars(choosedir) set $Vars(folder) $icon
			set Vars(lastFolder) $Vars(folder)
		}
	}

	if {$Vars(type) eq "dir" && $Vars(initialfile) ne $path} {
		set Vars(initialfile) $path
	}

	$Vars(widget:list:file) item delete all
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


proc Activate {w {exit no}} {
	variable ${w}::Vars

	switch $Vars(glob) {
		Files			{ set complete Join }
		Favorites	{ set complete SearchFavorite }
		LastVisited	{ set complete SearchLastVisited }
	}

	set files {}
	set selected {}

	if {$Vars(multiple)} {
		set even 0
		foreach list [string trim [split $Vars(initialfile) \"]] {
			if {$even} { set list [list $list] }
			set even [expr {1 - $even}]
			foreach file $list {
				if {[string length $file]} {
					if {$Vars(type) eq "save"} {
						set fullname $file
						if {[string length $Vars(defaultextension)]} {
							append fullname $Vars(defaultextension)
						}
						if {![CheckPath $w $fullname]} { return }
					}
					lappend selected [[namespace current]::$complete $w $file]
				}
			}
		}
	} else {
		set file [string trim $Vars(initialfile)]
		if {[string length $file]} {
			if {$Vars(type) eq "save"} {
				set fullname $file
				if {[string length $Vars(defaultextension)]} { append fullname $Vars(defaultextension) }
				if {![CheckPath $w $fullname]} { return }
			}
			lappend selected [[namespace current]::$complete $w $file]
		}
	}

	if {[llength $selected] == 0} { return }
	AddToHistory $w $Vars(history:folder)

	foreach file $selected {
		if {[lindex [file split $file] 0] ne [fileSeparator]} {
			set msg [format [Tr CannotOpenOrCreate] $file]
			messageBox -type ok -icon error -parent $Vars(widget:main) -message $msg
			return
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
					filelist::RefreshFileList $w
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
				if {[CheckIfInUse $w $file overwrite]} { return }
				if {[file exists $file]} {
					set msg [format [Tr FileAlreadyExists] [file tail $file]]
					set reply [messageBox                  \
									-type yesno                \
									-icon question             \
									-parent $Vars(widget:main) \
									-message $msg              \
					]
					if {$reply ne "yes"} { return }
				}
			}
		}
	}

	if {$exit} {
		if {[llength $Vars(okcommand)]} {
			if {!$Vars(multiple)} { set files [lindex $files 0] }
			if {[llength $Vars(selectencodingcommand)]} {
				{*}$Vars(okcommand) $files $Vars(encodingVar)
			} else {
				{*}$Vars(okcommand) $files
			}
		}
	} elseif {$Vars(type) eq "dir" && [llength $files]} {
		ChangeDir $w [lindex $files 0]
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

	foreach entry $Bookmarks(lastvisited) {
		set d [lindex $entry 0]
		if {[file tail $d] eq $dir} {
			return $d
		}
	}

	return $dir
}


proc CheckPath {w path} {
	variable ${w}::Vars

	set message ""
	set detail ""

	switch [verifyPath $path] {
		oneDot {
			set message [format [Tr FilenameNotAllowed] $path]
		}

		twoDots {
			set message [format [Tr FilenameNotAllowed] $path]
			set detail [Tr ContainsTwoDots]
		}

		tooLong {
			set message [format [Tr FilenameNotAllowed] $path]
			set detail [Tr FilenameTooLong]
		}

		reservedChar {
			variable reservedChars
			set message [format [Tr FilenameNotAllowed] $path]
			set detail [format [Tr ContainsReservedChars] [join $reservedChars " "]]
		}

		invalidName {
			set message [format [Tr FilenameNotAllowed] $path]
			set detail [Tr InvalidFileName]
		}

		reservedName {
			set message [format [Tr FilenameNotAllowed] $path]
			set detail [Tr IsReservedName]
		}
	}

	if {[string length $message] == 0} { return 1 }

	messageBox \
		-type ok \
		-icon error \
		-parent $Vars(widget:main) \
		-message $message \
		-detail $detail \
		;

	return 0
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


proc CheckIfInUse {w file mode} {
	variable ${w}::Vars

	if {[llength $Vars(isusedcommand)] > 0 && [$Vars(isusedcommand) $Vars(folder) $file]} {
		set msg [format [Tr Cannot[string toupper $mode 0 0]] [file tail $file]]
		set detail [Tr CannotDeleteDetail]
		messageBox                    \
			-type ok                   \
			-icon info                 \
			-parent $Vars(widget:main) \
			-message $msg              \
			-detail $detail            \
			;
		return 1
	}
	return 0
}


proc CheckIsKDE {w} {
	variable ${w}::Vars

	if {![info exists Vars(iskde)]} {
		set Vars(iskde) [checkIsKDE]
		if {$Vars(iskde)} {
			set Vars(exec:delete) [auto_execok kioclient]
			if {[llength $Vars(exec:delete)] == 0} {
				set Vars(exec:delete) [auto_execok kfmclient]
			}
			set Vars(exec:restore) [auto_execok ktrash]
			if {[llength $Vars(exec:delete)] == 0} { set $Vars(iskde) 0 }
		}
	}

	return $Vars(iskde)
}

###### B O O K M A R K S ######################################################

namespace eval bookmarks {

array set Bookmarks {
	favorites	{}
	lastvisited	{}
	user			{}
}

set BookmarkSize 15

namespace import [namespace parent]::Tr


proc Build {w path args} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options
	variable Bookmarks

	if {![info exists [namespace current]::icon::16x16::iconAdd]} {
		foreach {icon img} {Add plus Minus minus Modify modify} {
			set [namespace current]::icon::16x16::icon$icon \
				[list [[namespace parent]::makeStateSpecificIcons \
					[set [namespace current]::icon::16x16::$img]]]
		}
	}

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
	::toolbar::add $tb separator
	set Vars(button:modify) [::toolbar::add $tb button    \
		-image $icon::16x16::iconModify                    \
		-command [namespace code [list RenameBookmark $w]] \
		-state disabled                                    \
	]
	
	tk::frame $path.f -borderwidth 0 -takefocus 0
	pack $path.f -fill both -expand yes

	set t $path.f.list
	set sb $path.f.vscroll
	set Vars(widget:list:bookmark) $t
	set yscrollcmd [list [namespace parent]::SbSet $sb]

	treectrl $t {*}[array get opts] \
		-class FSBox                 \
		-highlightthickness 0        \
		-showroot no                 \
		-showheader no               \
		-showbuttons no              \
		-showlines no                \
		-takefocus 1                 \
		-itemheight $linespace       \
		-yscrollcommand $yscrollcmd  \
		;

	ttk::scrollbar $sb          \
		-orient vertical         \
		-takefocus 0             \
		-command [list $t yview] \
		;

	grid $t -row 0 -column 0 -sticky nsew
	grid $sb -row 0 -column 1 -sticky ns
	grid columnconfigure $path.f {0} -weight 1
	grid rowconfigure $path.f {0} -weight 1

	$t state define hilite
	$t state define edit

	$t column create -tags root
	$t configure -treecolumn root

	$t element create elemImg image
	$t element create elemTxt text                     \
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

	TreeCtrl::SetEditable  $t { {root style elemTxt} }

	$t notify install <Edit-begin>
	$t notify install <Edit-accept>
	$t notify install <Edit-end>
	$t notify install <Item-enter>
	$t notify install <Item-leave>

	$t notify bind $t <Item-enter> [list [namespace parent]::VisitItem $w $t enter %I]
	$t notify bind $t <Item-leave> [list [namespace parent]::VisitItem $w $t leave %I]

	$t style layout style elemTxt -draw {no edit}
	$t style layout style elemSel -draw {no edit}
	$t notify bind $t <Edit-begin> { %T item state set %I ~edit }
	$t notify bind $t <Edit-accept> { %T item element configure %I %C %E -text %t }
	$t notify bind $t <Edit-accept> +[namespace code [list EditAccept $w]]
	$t notify bind $t <Edit-end> { %T item state set %I ~edit }
	$t notify bind $t <Edit-end> +[namespace code [list FinishEdit $w]]

	bind $t <Double-Button-1> [namespace code [list InvokeBookmark $w %x %y]]
	bind $t <Double-Button-1> {+ break }
	bind $t <ButtonPress-3> [namespace code [list PopupMenu $w %x %y]]
	bind $t <Key-space> [namespace code [list InvokeBookmark $w]]
	bind $t <Return> [namespace code [list InvokeBookmark $w]]

	if {[llength $Vars(inspectcommand)]} {
		bind $t <ButtonPress-2> [namespace code [list InspectBookmark $w show %x %y]]
		bind $t <ButtonRelease-2> [namespace code [list InspectBookmark $w hide]]
	}

	set Vars(bookmarks) {
		{ star			Favorites	}
		{ visited		LastVisited	}
		{ divider		""				}
		{ filesystem	FileSystem	}
	}
	if {[string length $Vars(folder:desktop)]} {
		lappend Vars(bookmarks) { desktop Desktop }
	}
	if {[string length $Vars(folder:trash)]} {
		lappend Vars(bookmarks) { trash Trash }
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


proc InspectBookmark {w mode args} {
	variable [namespace parent]::${w}::Vars

	set tl [winfo toplevel $w]

	if {$mode eq "show"} {
		variable Bookmarks
		set t $Vars(widget:list:bookmark)
		lassign $args x y
		set id [$t identify $x $y]
		if {[llength $id] > 0 && [lindex $id 0] eq "header"} { return }
		set index [lindex $id 1]
		if {$index < [llength $Vars(bookmarks)]} {
			set attr [string tolower [lindex $Vars(bookmarks) [expr {$index - 1}] 1]]
			if {![info exists Vars(folder:$attr)]} { return }
			set path $Vars(folder:$attr)
			if {[string length $path] == 1} { set path " $path " }
		} else {
			set path [lindex [lindex $Bookmarks(user) [expr {$index - [llength $Vars(bookmarks)] - 1}]] 0]
		}
		{*}$Vars(inspectcommand) $tl $path
	} else {
		{*}$Vars(inspectcommand) $tl
	}
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
				elemTxt -text [Tr $text] \
				;
		}
		$t item lastchild root $item
	}

	set bookmarks {}
	foreach entry $Bookmarks(user) {
		lassign $entry folder name
		if {[file isdirectory $folder]} {
			if {[string length $name] == 0} { set name [file tail $folder] } ;# support old format
			lappend bookmarks [list $folder $name]
		}
	}
	set Bookmarks(user) $bookmarks
	array unset Vars bookmark:tooltip:*

	set index 0
	foreach entry $Bookmarks(user) {
		lassign $entry folder name
		set icon [set [namespace parent]::icon::16x16::folder]
		set item [$t item create]
		$t item style set $item root style
		$t item element configure $item root elemImg -image $icon + elemTxt -text $name
		$t item lastchild root $item
		set Vars(bookmark:tooltip:$item) $index
		incr index
	}
}


proc AddBookmark {w} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

#	set ReallyAddBookmark "A bookmark for folder '%folder%' already exists, with name '%name%'. Really add this bookmark again?"
#	set i [lsearch -index 0 $Bookmarks(user) $Vars(folder)]
#	if {$i >= 0} {
#		set msg [string map \
#			[list %name% [lindex $Bookmarks(user) $i 1] %folder% [file tail $Vars(folder)]] \
#			[Tr ReallyAddBookmark] \
#		]
#		set reply [messageBox -yesno -parent $w -icon question -message $msg]
#	}

	set folder $Vars(folder)
#	while {[file type $folder] eq "link"} {
#		set folder [file readlink $folder]
#	}
	lappend Bookmarks(user) [list [file normalize $folder] [file tail $Vars(folder)]]
	set list {}
	set index -1
	foreach entry $Bookmarks(user) {
		lappend list [list [incr index] [string tolower [lindex $entry 1]]]
	}
	set list [lsort -nocase -index 1 $list]
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


proc RenameBookmark {w} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)
	set sel [$t item id active]
	OpenEdit $w $sel rename
}


proc OpenEdit {w sel mode} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:bookmark)
	$t selection clear
	foreach item [$t item children root] { $t item state set $item {!hilite} }
	$t see $sel
	set index [expr {$sel - [llength $Vars(bookmarks)] - 1}]

	set e [::TreeCtrl::EntryExpanderOpen $t $sel 0 elemTxt 0]
	set Vars(edit:active) 1
	set Vars(edit:sel) $sel
	set Vars(edit:index) $index
	set Vars(edit:accept) 0
	::TreeCtrl::TryEvent $t Edit begin [list I $sel C 0 E elemTxt]
}


proc EditAccept {w} {
	variable [namespace parent]::${w}::Vars
	set Vars(edit:accept) 1
}


proc FinishEdit {w} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)
	set sel $Vars(edit:sel)
	set Vars(edit:active) 0

	if {$Vars(edit:accept)} {
		$t selection clear
		set newName [string trim [$t item element cget $sel 0 elemTxt -text]]
		set oldName [lindex $Bookmarks(user) $Vars(edit:index) 1]
		if {[string length $newName] == 0} { return $oldName }
		if {$oldName eq $newName} { return $oldName }
		lset Bookmarks(user) $Vars(edit:index) 1 $newName
		Selected $w $Vars(edit:sel)
	}

	$t selection clear
	$t selection add $sel
	$t activate $sel
	$t see $sel

	after idle [list [namespace parent]::Stimulate $w]
}


proc Selected {w sel} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	if {[string is integer -strict $sel] && $sel > [llength $Vars(bookmarks)]} {
		set name [lindex $Bookmarks(user) [expr {$sel - [llength $Vars(bookmarks)] - 1}] 1]
		set tip [format [Tr RemoveBookmark] [file tail $name]]
		::toolbar::childconfigure $Vars(button:minus) -state normal -tooltip $tip
		set tip [format [Tr RenameBookmark] [file tail $name]]
		::toolbar::childconfigure $Vars(button:modify) -state normal -tooltip $tip
	} else {
		::toolbar::childconfigure $Vars(button:minus) -state disabled
		::toolbar::childconfigure $Vars(button:modify) -state disabled
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
		set folder [lindex $Vars(bookmarks) $sel 1]
		set id [string tolower $folder]
		if {[string length $folder] == 0} { return }
		switch $folder {
			Favorites - LastVisited	{ set dir $folder }
			default { set dir $Vars(folder:$id) }
		}
		[namespace parent]::ChangeDir $w $dir
	} else {
		set i [expr {$sel - [llength $Vars(bookmarks)]}]
		if {$i < [llength $Bookmarks(user)]} {
			[namespace parent]::ChangeDir $w [lindex $Bookmarks(user) $i 0]
		}
	}
}


proc PopupMenu {w x y} {
	variable [namespace parent]::${w}::Vars
	variable Bookmarks

	set t $Vars(widget:list:bookmark)
	set id [$t identify $x $y]
	if {[llength $id] > 0 && [lindex $id 0] eq "header"} { return }
	foreach item [$t item children root] { $t item state set $item {!hilite} }

	set m $w.menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	set count 0

	if {[string length $Vars(folder)] && [::toolbar::childcget $Vars(button:add) -state] eq "normal"} {
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

	if {[::toolbar::childcget $Vars(button:minus) -state] eq "normal"} {
		set sel [expr {[$t item id active] - [llength $Vars(bookmarks)] - 1}]
		if {$sel >= 0} {
			set name [lindex $Bookmarks(user) $sel 1]
			set text [format [Tr RemoveBookmark] $name]
			$m add command                                        \
				-compound left                                     \
				-image $icon::16x16::minus                         \
				-label " $text"                                    \
				-command [namespace code [list RemoveBookmark $w]] \
				;
			set text [format [Tr RenameBookmark] $name]
			$m add command                                        \
				-compound left                                     \
				-image $icon::16x16::modify                        \
				-label " $text"                                    \
				-command [namespace code [list RenameBookmark $w]] \
				;
			incr count
		}
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

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace bookmarks

######  F I L E  L I S T ######################################################

namespace eval filelist {

namespace import ::tcl::mathfunc::max
namespace import [namespace parent]::Tr


proc Build {w path args} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	if {![info exists [namespace current]::icon::16x16::iconAdd]} {
		foreach {icon img} {	Delete delete Restore restore Modify modify Duplicate duplicate
									Add folder_add Backward backward Forward forward} {
			set [namespace current]::icon::16x16::icon$icon \
				[list [[namespace parent]::makeStateSpecificIcons \
					[set [namespace current]::icon::16x16::$img]]]
		}
	}

	if {[llength $Vars(customcommand)] && [llength $Vars(customicon)]} {
		set Vars(customicon) [list [[namespace parent]::makeStateSpecificIcons $Vars(customicon)]]
	}

	array set opts {
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
	set Vars(disable:delete) 0
	set Vars(disable:rename) 0
	set Vars(disable:copy) 0
	set Vars(disable:new) 0
	set Vars(disable:custom) 0

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
	set count 0

	if {"delete" in $Vars(actions)} {
		set Vars(button:delete) [::toolbar::add $tb button \
			-image $icon::16x16::iconDelete                 \
			-command [namespace code [list DeleteFile $w]]  \
			-tooltip [Tr Delete]                            \
			-state disabled                                 \
		]
		incr count
	}
	if {"rename" in $Vars(actions)} {
		set Vars(button:rename) [::toolbar::add $tb button \
			-image $icon::16x16::iconModify                 \
			-command [namespace code [list RenameFile $w]]  \
			-tooltip [Tr Rename]                            \
			-state disabled                                 \
		]
		incr count
	}
	if {"copy" in $Vars(actions) && $Vars(type) ne "dir"} {
		set Vars(button:copy) [::toolbar::add $tb button     \
			-image $icon::16x16::iconDuplicate                \
			-command [namespace code [list DuplicateFile $w]] \
			-tooltip [Tr Duplicate]                           \
			-state disabled                                   \
		]
		incr count
	}
	if {[llength $Vars(customcommand)] && [llength $Vars(customicon)]} {
		set Vars(button:custom) [::toolbar::add $tb button       \
			-image $Vars(customicon)                              \
			-command [namespace code [list CallCustomCommand $w]] \
			-tooltip $Vars(customtooltip)                         \
			-state disabled                                       \
		]
		incr count
	}
	if {"new" in $Vars(actions)} {
		set Vars(button:new) [::toolbar::add $tb button  \
			-image $icon::16x16::iconAdd                  \
			-command [namespace code [list NewFolder $w]] \
			-tooltip [Tr NewFolder]                       \
		]
		incr count
	}

	if {$count > 0} { ::toolbar::add $tb separator }

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
	if {$::tcl_platform(platform) eq "unix"} {
		if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
		set Vars(widget:hidden) [::toolbar::add $tb checkbutton \
			-image [set icon::16x16::${ipref}locked]             \
			-command [namespace code [list SwitchHidden $w]]     \
			-tooltip [Tr ShowHiddenFiles]                        \
			-variable [namespace parent]::Options(show:hidden)   \
			-padx 1                                              \
		]
	}

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

	ttk::scrollbar $sv          \
		-orient vertical         \
		-takefocus 0             \
		-command [list $t yview] \
		;
	ttk::scrollbar $sh          \
		-orient horizontal       \
		-takefocus 0             \
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

	bind $t <Double-Button-1> [namespace code [list InvokeFile $w %x %y]]
	bind $t <Double-Button-1> {+ break }
	bind $t <ButtonPress-3> [namespace code [list PopupMenu $w %x %y]]
	bind $t <Key-space> [namespace code [list InvokeFile $w]]
	bind $t <Return> [namespace code [list InvokeFile $w]]

	if {[llength $Vars(inspectcommand)]} {
		bind $t <ButtonPress-2>		[namespace code [list Inspect $w show %x %y]]
		bind $t <ButtonRelease-2>	[namespace code [list Inspect $w hide]]
	}

	CheckDir $t

	if {[info exists Vars(rows)]} {
		update idletasks
		set minh [expr {[::toolbar::requestetHeight $path] - [$t headerheight]}]
		set Vars(rows:computed) [expr {max($Vars(rows), ($minh + $linespace - 1)/$linespace)}]
		set h [expr {[$t headerheight] + max($Vars(rows:computed), 1)*$linespace}]
		$t configure -height $h
	}
}


proc SwitchHidden {w} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	set Options(show:hidden) [expr {!$Options(show:hidden)}]
	if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
	toolbar::childconfigure $Vars(widget:hidden) -image [set icon::16x16::${ipref}locked]
	$Vars(choosedir) showhidden $Options(show:hidden)
	RefreshFileList $w
}


proc DetailsLayout {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)

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

	set background [[namespace parent]::GetHeaderBackground $w]

	$t column create                          \
		-background $background                \
		-text [Tr Name]                        \
		-tags name                             \
		-minwidth [expr {10*$Vars(charwidth)}] \
		-arrow up                              \
		-borderwidth $Vars(borderwidth)        \
		-steady yes                            \
		-textpadx $Vars(textpadx)              \
		-textpady $Vars(textpady)              \
		-font $Vars(font)                      \
		-expand yes                            \
		-squeeze yes                           \
		{*}$copts(name)                        \
		;
	if {$Vars(type) ne "dir"} {
		$t column create                         \
			-background $background               \
			-text [Tr Size]                       \
			-tags size                            \
			-justify right                        \
			-width [expr {11*$Vars(charwidth)}]   \
			-minwidth [expr {6*$Vars(charwidth)}] \
			-arrowside left                       \
			-arrowgravity right                   \
			-borderwidth $Vars(borderwidth)       \
			-steady yes                           \
			-textpadx $Vars(textpadx)             \
			-textpady $Vars(textpady)             \
			-font $Vars(font)                     \
			{*}$copts(size)                       \
			;
	}
	$t column create                          \
		-background $background                \
		-text [Tr Modified]                    \
		-tags modified                         \
		-width [expr {18*$Vars(charwidth)}]    \
		-minwidth [expr {10*$Vars(charwidth)}] \
		-borderwidth $Vars(borderwidth)        \
		-steady yes                            \
		-textpadx $Vars(textpadx)              \
		-textpady $Vars(textpady)              \
		-font $Vars(font)                      \
		{*}$copts(modified)                    \
		;
	
	$t element create elemImg image ;# -image [set [namespace parent]::icon::16x16::folder]
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
	$t element create txtDate text                     \
		-fill [list                                     \
			$Vars(selectionforeground) {selected focus}  \
			$Vars(selectionforeground) {selected hilite} \
			$Vars(inactiveforeground)  {selected !focus} \
			$Vars(activeforeground) {hilite}             \
		]                                               \
		-datatype time                                  \
		-format [Tr TimeFormat]                         \
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

	if {$Vars(type) eq "dir"} {
		set Vars(scriptDir) {
			set item [$t item create -open no]
			if {[llength $icon] == 0} { set icon $::fsbox::icon::16x16::folder }
			if {[llength $folder] == 0} { set folder [file tail $path] }
			$t item style set $item name styName modified styDate
			$t item element configure $item \
				name elemImg -image $icon , \
				name txtName -text $folder , \
				modified txtDate -data [file mtime $path]
			$t item lastchild root $item
		}

		set Vars(scriptNewDir) {
			set item [$t item create -open no]
			if {[llength $folder] == 0} { set folder [file tail $path] }
			$t item style set $item name styName modified styDate
			$t item element configure $item \
				name elemImg -image $icon , \
				name txtName -text $folder
			$t item lastchild root $item
		}
	} else {
		set Vars(scriptDir) {
			set item [$t item create -open no]
			if {[llength $icon] == 0} { set icon $::fsbox::icon::16x16::folder }
			if {[llength $folder] == 0} { set folder [file tail $path] }
			$t item style set $item name styName size stySize modified styDate
			$t item element configure $item \
				name elemImg -image $icon , \
				name txtName -text $folder , \
				modified txtDate -data [file mtime $path]
			$t item lastchild root $item
		}

		set Vars(scriptNewDir) {
			set item [$t item create -open no]
			if {[llength $folder] == 0} { set folder [file tail $path] }
			$t item style set $item name styName size stySize modified styDate
			$t item element configure $item \
				name elemImg -image $icon , \
				name txtName -text $folder
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

		set Vars(scriptNewFile) {
			set item [$t item create -open no]
			$t item style set $item name styName size stySize modified styDate
			set icon [GetFileIcon $w $file]
			$t item element configure $item \
				name elemImg -image $icon , \
				name txtName -text [file tail $file]
			$t item lastchild root $item
		}
	}
}


proc ListLayout {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)

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
		if {[llength $icon] == 0} { set icon $::fsbox::icon::16x16::folder }
		if {[llength $folder] == 0} { set folder [file tail $path] }
		$t item style set $item name styName
		$t item element configure $item name \
			elemImg -image $icon + \
			txtName -text $folder
		$t item lastchild root $item
	}

	set Vars(scriptNewDir) $Vars(scriptDir)

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

	set Vars(scriptNewFile) $Vars(scriptFile)
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
	
	[namespace parent]::busy [winfo toplevel $w]
	set t $Vars(widget:list:file)
	set selection [$t selection get]
	$t selection clear

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
	[namespace parent]::unbusy [winfo toplevel $w]
}


proc ColumnResized {w col} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)

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

	set t $Vars(widget:list:file)

	if {[string length $column] == 0} {
		set column $Vars(sort-column)
		if {[$t column cget $column -arrow] eq "none"} { return }
	} else {
		set column [lindex [$t column tag names $column] 0]
		set arrow [$t column cget $column -arrow]
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
					-nocase                           \
					;
			}
			if {$fileCount} {
				$t item sort root -$Vars(sort-order)                \
					-first [list root child [expr {$lastDir + 1}]]   \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column                                  \
					-nocase                                          \
					;
			}
		}

		size {
			if {$fileCount} {
				$t item sort root -$Vars(sort-order)                                 \
					-first [list root child [expr {$lastDir + 1}]]                    \
					-last [list root child [expr {$totalCount - 1}]]                  \
					-column $column                                                   \
					-command [namespace code [list CompSize $Vars(widget:list:file)]] \
					-column name                                                      \
					-nocase                                                           \
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
					-nocase                           \
					;
			}
			if {$fileCount} {
				$t item sort root -$Vars(sort-order)                \
					-first [list root child [expr {$lastDir + 1}]]   \
					-last [list root child [expr {$totalCount - 1}]] \
					-column $column                                  \
					-integer                                         \
					-column name                                     \
					-nocase                                          \
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

	set lookupFolder 0

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
				set folders [lsort -nocase $folders]
			}

			LastVisited - Favorites {
				variable [namespace parent]::bookmarks::Bookmarks

				set lookupFolder 1
				set attr [string tolower $Vars(glob)]
				set arrow none
				set state disabled
				set bookmarks {}
				foreach entry $Bookmarks($attr) {
					if {$attr eq "favorites"} { set folder [lindex $entry 0] } else { set folder $entry }
					if {[file isdirectory $folder]} {
						lappend bookmarks $entry
					}
				}
				set Bookmarks($attr) $bookmarks
				set folders {}
				foreach entry $Bookmarks($attr) {
					if {$attr eq "favorites"} { set folder [lindex $entry 0] } else { set folder $entry }
					if {[string index $folder 0] ne "." || $Options(show:hidden)} { 
						lappend folders $folder
					}
				}
			}
		}

		$Vars(widget:list:file) column configure $Vars(sort-column) -arrow $arrow
		if {[info exists Vars(button:new)]} {
			::toolbar::childconfigure $Vars(button:new) -state $state
		}

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

			# NOTE: we dont want -dictionary
			foreach file [lsort -nocase -unique $files] {
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

	} else {
		set filelist {}
		foreach file $Vars(list:file) {
			if {[file exists $file] && [file isfile $file]} {
				lappend filelist $file
			}
		}
	}

	set t $Vars(widget:list:file)
	foreach path $Vars(list:folder) {
		set icon {}
		set folder {}
		if {$lookupFolder} {
			if {[info exists Vars(lookup:$path)]} {
				set attr $Vars(lookup:$path)
				set icon [set [namespace parent]::icon::16x16::$attr]
				set folder [Tr [string toupper $attr 0 0]]
			} elseif {	[string length  $Vars(folder:trash)] > 0
						&& [string match $Vars(folder:trash)* $path]} {
				set icon [set [namespace parent]::icon::16x16::trash]
				set folder [Tr Trash]
				if {$path ne $Vars(folder:trash)} { append folder ": " [file tail $path] }
			}
		}
		eval $Vars(scriptDir)
	}
	if {[$t item count] == 1} { set item root } else { set item "root children" }
	$Vars(widget:list:file) item tag add $item directory

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

	set t $Vars(widget:list:file)

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
		if {!$Vars(multiple)} { [namespace parent]::Activate $w yes }
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

	set Vars(lock:selection) 1
	set t $Vars(widget:list:file)
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
			$t selection clear
			$t selection add $n
			lappend Vars(selected:folders) $folder
		}
	}

	foreach file $files {
		set i [lsearch -exact $Vars(list:file) $file]
		if {$i >= 0} {
			set n [expr {$i + 1 + [llength $Vars(list:folder)]}]
			$t selection clear
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


#proc CurrentFileIsUsed {w} {
#	variable [namespace parent]::${w}::Vars
#
#	if {$Vars(glob) ne "Files"} { return 0 }
#	if {[llength $Vars(selected:files)] > 1} { return 0 }
#	if {[llength $Vars(isusedcommand)] == 0} { return 0 }
#	return [$Vars(isusedcommand) $Vars(folder) [file join $Vars(folder) $Vars(initialfile)]]
#}


proc ConfigureButtons {w} {
	variable [namespace parent]::${w}::Vars

	if {	[llength $Vars(selected:folders)] + [llength $Vars(selected:files)] == 0
		|| $Vars(glob) ne "Files"} {
		set st disabled
	} else {
		set st normal
	}

	foreach what {delete rename copy} { set Vars(state:$what) $st }
	if {[llength $Vars(selected:folders)] > 0} { set Vars(state:copy) disabled }
	if {$Vars(glob) eq "Files"} { set Vars(state:new) normal } else { set Vars(state:new) disabled }

#	if {[CurrentFileIsUsed $w]} {
#		set Vars(state:delete) disabled
#		set Vars(state:rename) disabled
#	}

	foreach action {delete rename copy new} {
		if {$Vars(disable:$action) || $action ni $Vars(actions)} { set Vars(state:$action) disabled }
	}

	foreach action {delete rename copy new} {
		if {[info exists Vars(button:$action)]} {
			::toolbar::childconfigure $Vars(button:$action) -state $Vars(state:$action)
		}
	}

	if {[info exists Vars(button:custom)]} {
		if {	[llength $Vars(selected:files)] == 1
			&& [file extension $Vars(initialfile)] in $Vars(customfiletypes)} {
			if {$Vars(glob) eq "Files"} {
				set Vars(state:custom) normal
			} else {
				set Vars(state:custom) disabled
			}
		} else {
			set Vars(state:custom) disabled
		}
		::toolbar::childconfigure $Vars(button:custom) -state $Vars(state:custom)
	}

	# NOTE ktrash is not working
	if {[info exists Vars(button:delete)] && $Vars(delete:action) eq "restore"} {
		::toolbar::childconfigure $Vars(button:delete) -state disabled
	}
}


proc SelectFiles {w selection} {
	variable [namespace parent]::${w}::Vars

	if {$Vars(lock:selection)} { return }

	set Vars(selected:folders) {}
	set Vars(selected:files) {}

	set selection [lsort -integer -unique [$Vars(widget:list:file) selection get]]

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

	if {$Vars(type) eq "dir"} {
		if {[llength $Vars(selected:folders)]} {
			set Vars(initialfile) [lindex $Vars(selected:folders) 0]
		}
	} else {
		set filenames ""
		foreach file $Vars(selected:files) {
			if {$Vars(multiple) && ([llength $Vars(selected:files)] > 1 || [string first " " $file] >= 0)} {
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
	}

	ConfigureButtons $w
}


proc CheckFile {w {file ""}} {
	if {[llength $file]} { [namespace parent]::CheckEncoding $w $file }
}


proc CheckDir {w {folder  ""}} {
	# nothing to do
}


proc TraverseFiles {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	set list $Vars(list:file)
	set Vars(list:file) {}

	foreach file $list {
		if {[file isfile $file]} {
			lappend Vars(list:file) $file
			eval $Vars(scriptFile)
		}
	}
}


proc TraverseFolders {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	set list $Vars(list:folder)
	set Vars(list:folder) {}
	set icon {}

	foreach path $list {
		if {[file isdirectory $path]} {
			lappend Vars(list:folder) $path
			set folder {}
			eval $Vars(scriptDir)
		}
	}
}


proc DeleteFile {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	set sel [expr {[$t item id active] - 1}]

	if {$sel < [llength $Vars(list:folder)]} {
		set file [lindex $Vars(list:folder) $sel]
		set type folder
		set ltype folder
	} else {
		set sel [expr {$sel - [llength $Vars(list:folder)]}]
		set file [lindex $Vars(list:file) $sel]
		switch [file type $file] {
			link		{ set type link }
			default	{ set type file }
		}
		set ltype file
		if {[[namespace parent]::CheckIfInUse $w $file delete]} { return }
	}

	[namespace parent]::busy $w

	if {$type eq "link"} {
		set iskde 0
		set dest [file link $file]
	} else {
		set iskde [[namespace parent]::CheckIsKDE $w]
		set dest $file
	}

	if {$Vars(delete:action) eq "restore"} {
# "ktrash --restore <file>" is not working despite the documentation
#		if {$iskde && [llength $Vars(exec:restore)] > 0} {
#			set fs [[namespace parent]::fileSeparator]
#			set n [llength [split $Vars(folder:trash) $fs]]
#			if {$ltype eq "file"} {
#				foreach f [{*}$Vars(deletecommand) $file] {
#					if {[file exists $f]} {
#						set components [lrange [split $f $fs] $n end]
#						set f [file join {*}$components]
#						set cmd "$Vars(exec:restore) --restore \"$f\""
#						if {[catch {exec /bin/sh -c $cmd}]} {
#							# TODO: ktrash failed
#						}
#					}
#				}
#			} else {
#				set cmd "$Vars(exec:restore) --restore \"$file\""
#			}
#			if {[catch {exec /bin/sh -c $cmd}]} {
#				# TODO: ktrash failed
#			}
#		}
	} else {
		if {[file writable $file]} { set mode w } else { set mode r }
		if {$iskde} { set which ReallyMove } else { set which ReallyDelete }
		set fmt [Tr ${which}($type,$mode)]
		set msg [format $fmt [file tail $dest]]
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

		if {$iskde} {
			if {$ltype eq "file" && [llength $Vars(deletecommand)] > 0} {
				set cmd "$Vars(exec:delete) move"
				foreach f [{*}$Vars(deletecommand) $file] {
					if {[file exists $f]} { append cmd " \"$f\"" }
				}
				append cmd " trash:/"
			} else {
				set cmd "$Vars(exec:delete) move \"$file\" trash:/"
			}
			if {[catch {exec /bin/sh -c $cmd}]} {
				# Oops, kioclient is always returning an error
			}
		} elseif {$ltype eq "file"} {
			if {[llength $Vars(deletecommand)] > 0} {
				set files {}
				set delim ""
				foreach f [{*}$Vars(deletecommand) $file] {
					if {[file exists $f]} { lappend files $f }
				}
			} else {
				set files [list $file]
			}

			catch {file delete -force {*}$files}
		} elseif {![catch {file delete -force $file}]} {
			[namespace parent]::bookmarks::LayoutBookmarks $w
		}
	}

	RefreshFileList $w
	[namespace parent]::unbusy $w

	if {$file in $Vars(list:$ltype)} {
		set action [string toupper $Vars(delete:action) 0 0]
		set msg [format [Tr ${action}Failed] $file]
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


proc SetDeleteAction {w action} {
	variable [namespace parent]::${w}::Vars

	set Vars(delete:action) $action

	# NOTE that ktrash is not working, we cannot restore files
#	set name [string toupper $action 0 0]
#	::toolbar::childconfigure $Vars(button:delete) \
#		-image [set icon::16x16::icon$name] \
#		-tooltip [Tr $name] \
#		;
}


proc RenameFile {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	set sel [$t item id active]
	set i [expr {$sel - 1}]
	if {$i < [llength $Vars(list:folder)]} {
		set Vars(edit:file) [lindex $Vars(list:folder) $i]
	} else {
		set i [expr {$i - [llength $Vars(list:folder)]}]
		set Vars(edit:file) [lindex $Vars(list:file) $i]
		if {[[namespace parent]::CheckIfInUse $w $Vars(edit:file) rename]} { return }
	}
	OpenEdit $w $sel rename
}


proc MakeFileSize {size} {
	set unit Byte
	if {$size >= 1000000000} {
		set size [expr {($size + 500000000)/1000000000}]
		set unit GB
	} elseif {$size >= 1000000} {
		set size [expr {($size + 500000)/1000000}]
		set unit MB
	} elseif {$size >= 1000} {
		set size [expr {($size + 500)/1000}]
		set unit KB
	}
	return "$size $unit"
}


proc DuplicateFile {w} {
	variable [namespace parent]::duplicateFileSizeLimit
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	set sel [$t item id active]
	set i [expr {$sel - 1}]
	if {$i < [llength $Vars(list:folder)]} { return }
	set i [expr {$i - [llength $Vars(list:folder)]}]
	set file [lindex $Vars(list:file) $i]
	if {![file exists $file]} {
		set msg [format [Tr FileHasDisappeared] [file tail $file]]
		[namespace parent]::messageBox \
			-type ok                    \
			-icon error                 \
			-parent $Vars(widget:main)  \
			-message $msg               \
			;
		return
	}
	set Vars(edit:file) $file
	set dir [file dirname $file]
	set newFile [file join $dir [format [Tr CopyOf] [file tail $file]]]
	while {[file exists $newFile]} {
		set newFile [file join $dir [format [Tr CopyOf] [file tail $newFile]]]
	}
	if {[llength $Vars(duplicatecommand)]} {
		set files [{*}$Vars(duplicatecommand) $file $newFile]
	} else {
		set files [list $file $newFile]
	}
	set size 0
	foreach {f g} $files {
		if {[file exists $f]} {
			if {[file exists $g]} {
				set msg [format [Tr CannotCopy] [file tail $g]]
				[namespace parent]::messageBox \
					-type ok                    \
					-icon error                 \
					-parent $Vars(widget:main)  \
					-message $msg               \
					;
				return
			}
			incr size [file size $f]
		}
	}
	if {$size > $duplicateFileSizeLimit} {
		set msg [Tr ReallyDuplicateFile]
		set detail [format [Tr ReallyDuplicateDetail] [MakeFileSize $size]]
		set reply [[namespace parent]::messageBox \
			-type yesno                            \
			-icon question                         \
			-parent $Vars(widget:main)             \
			-message $msg                          \
			-detail $detail                        \
		]
		if {$reply ne "yes"} { return }
	}

	$t item delete all
	TraverseFolders $w
	if {[$t item count] == 1} { set item root } else { set item "root children" }
	$t item tag add $item directory
	TraverseFiles $w
	foreach file [list $newFile] $Vars(scriptNewFile)
	OpenEdit $w [expr {[llength $Vars(list:folder)] + [llength $Vars(list:file)] + 1}] duplicate
}


proc NewFolder {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)

	set sel [$t item id active]
	set i [expr {$sel - 1}]
	if {$i < [llength $Vars(list:folder)]} {
		set Vars(edit:file) [lindex $Vars(list:folder) $i]
	} else {
		set i [expr {$i - [llength $Vars(list:folder)]}]
		set Vars(edit:file) [lindex $Vars(list:file) $i]
	}
	$t item delete all
	TraverseFolders $w
	set icon [set [namespace parent]::icon::16x16::folder]
	foreach folder [list [Tr NewFolder]] $Vars(scriptNewDir)
	$t item tag add "root children" directory
	TraverseFiles $w
	OpenEdit $w [expr {[llength $Vars(list:folder)] + 1}] new
}


proc CallCustomCommand {w} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)

	set sel [$t item id active]
	set i [expr {$sel - 1}]
	if {$i < [llength $Vars(list:folder)]} {
		set file [lindex $Vars(list:folder) $i]
	} else {
		set i [expr {$i - [llength $Vars(list:folder)]}]
		set file [lindex $Vars(list:file) $i]
	}

	{*}$Vars(customcommand) [winfo toplevel $w] $file
	RefreshFileList $w
	[namespace parent]::bookmarks::LayoutBookmarks $w
}


proc OpenEdit {w sel mode} {
	variable [namespace parent]::${w}::Vars

	set t $Vars(widget:list:file)
	$t selection clear
	foreach item [$t item children root] { $t item state set $item {!hilite} }
	$t see $sel

	set e [::TreeCtrl::EntryExpanderOpen $t $sel 0 txtName 0 [namespace code [list SelectFileName $w]]]
	set vcmd { return [::fsbox::validateCharacters %P] }
	$e configure                \
		-validate key            \
		-validatecommand $vcmd   \
		-invalidcommand { bell } \
		;
	set Vars(edit:active) 1
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

	set t $Vars(widget:list:file)
	set sel $Vars(edit:sel)
	set Vars(edit:active) 0

	if {$Vars(edit:accept)} {
		set name [string trim [$t item element cget $sel 0 txtName -text]]

		switch $Vars(edit:mode) {
			rename		{ set selFile [FinishRenameFile $w $sel $name] }
			duplicate	{ set selFile [FinishDuplicateFile $w $sel $name] }
			new			{ set selFile [FinishNewFolder $w $sel $name] }
		}
	} else {
		set selFile $Vars(edit:file)
	}

	RefreshFileList $w

	if {[string length $selFile]} {
		set k [lsearch $Vars(list:folder) $selFile]
		if {$k == -1} {
			set k [lsearch $Vars(list:file) $selFile]
			if {$k >= 0} { set k [expr {[llength $Vars(list:folder)] + $k}] }
		}
		if {$k >= 0} {
			incr k
			set t $Vars(widget:list:file)
			$t selection clear
			$t selection add $k
			$t activate $k
			$t see $k
		}
	}

	after idle [list [namespace parent]::Stimulate $w]
}


proc FinishRenameFile {w sel name} {
	variable [namespace parent]::${w}::Vars

	set name [string trim $name]
	set t $Vars(widget:list:file)
	$t selection clear
	set i [expr {$sel - 1}]
	if {$i < [llength $Vars(list:folder)]} {
		set type folder
	} else {
		set i [expr {$i - [llength $Vars(list:folder)]}]
		set type file
	}
	set oldName [lindex $Vars(list:$type) $i]
	if {[string length $name] == 0} { return $oldName }
	set newName [file join $Vars(folder) $name]
	if {$oldName eq $newName} { return $oldName }
	if {![[namespace parent]::CheckPath $w $name]} { return $oldName }

	if {[file exists $newName]} {
		[namespace parent]::messageBox               \
			-type ok                                  \
			-icon error                               \
			-parent $Vars(widget:main)                \
			-message [format [Tr CannotRename] $name] \
			;
		return $oldName
	}

	set ok 1
	set files {}
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
		set old [file tail $oldName]
		set new [file tail $newName]
		set ok 0
	}
	if {$ok} {
		lset Vars(list:$type) $i $newName
	} else {
		if {$type eq "file" && [llength $files] == 0} {
			set msg [format [Tr InvalidFileExt] [file tail $new]]
		} else {
			set msg [Tr ErrorRenaming($type)]
			set msg [string map [list %old [file tail $old] %new [file tail $new]] $msg]
		}
		[namespace parent]::messageBox \
			-type ok                    \
			-icon error                 \
			-parent $Vars(widget:main)  \
			-message $msg               \
			;
		return $oldName
	}

	return $newName
}


proc FinishDuplicateFile {w sel name} {
	variable [namespace parent]::${w}::Vars

	set name [string trim $name]
	set srcFile $Vars(edit:file)
	set dir [file dirname $srcFile]
	set dstFile [file join $dir $name]

	if {![[namespace parent]::CheckPath $w $name]} { return $srcFile }

	if {[llength $Vars(duplicatecommand)]} {
		set fileList [{*}$Vars(duplicatecommand) $srcFile $dstFile]
	} else {
		set fileList [list $srcFile $dstFile]
	}

	set files {}
	foreach {f g} $fileList {
		if {[file exists $f]} {
			while {[file type $f] eq "link"} {
				set f [file readlink $f]
			}
		}
		lappend files $f $g
	}

	if {[llength $files] == 0} {
		set msg [format [Tr InvalidFileExt] $name]
		[namespace parent]::messageBox \
			-type ok                    \
			-icon error                 \
			-parent $Vars(widget:main)  \
			-message $msg               \
			;
		return $srcFile
	}

	foreach {_ f} $files {
		if {[file exists $f]} {
			[namespace parent]::messageBox                      \
				-type ok                                         \
				-icon error                                      \
				-parent $Vars(widget:main)                       \
				-message [format [Tr CannotCopy] [file tail $f]] \
				;
			return $srcFile
		}
	}

	set dlg [tk::toplevel $w.wait]
	wm withdraw $dlg
	set top [tk::frame $dlg.top -border 2 -relief raised]
	pack $top
	tk::message $top.msg -aspect 250 -text [Tr WaitWhileDuplicating]
	pack $top.msg -padx 5 -pady 5
	wm resizable $dlg no no
	wm transient $dlg [winfo toplevel $w]
	::util::place $dlg center [winfo toplevel $w]
	update idletasks
	[namespace parent]::noWindowDecor $dlg
	wm deiconify $dlg
	::ttk::grabWindow $dlg
	[namespace parent]::busy $dlg

	set newFiles {}
	foreach {f g} $files {
		if {[file exists $f]} {
			if {[catch { file copy $f $g }]} {
				::ttk::releaseGrab $dlg
				destroy $dlg
				set msg [format [Tr CopyFailed] [file tail $f]]
				[namespace parent]::messageBox \
					-type ok                    \
					-icon error                 \
					-parent $Vars(widget:main)  \
					-message $msg               \
					;
				foreach f $newFiles { catch { file delete -force $f } }
				[namespace parent]::unbusy $w
				return $srcFile
			} else {
				if {$::tcl_platform(platform) eq "unix"} { exec touch $g }
				lappend newFiles $g
			}
		}
	}

	::ttk::releaseGrab $dlg
	[namespace parent]::unbusy $dlg
	destroy $dlg

	return $dstFile
}


proc FinishNewFolder {w sel name} {
	variable [namespace parent]::${w}::Vars

	set name [string trim $name]
	if {[string length $name] == 0} { return "" }

	set folder [file join $Vars(folder) $name]
	if {[file exists $folder]} {
		[namespace parent]::messageBox               \
			-type ok                                  \
			-icon error                               \
			-parent $Vars(widget:main)                \
			-message [format [Tr CannotCreate] $name] \
			;
	} elseif {[catch {file mkdir $folder}]} {
		[namespace parent]::messageBox      \
			-type ok                         \
			-icon error                      \
			-parent $Vars(widget:main)       \
			-message [Tr ErrorCreate($type)] \
			;
		RefreshFileList $w
	} else {
		$Vars(widget:list:file) item element configure $sel 0 txtName -text $name
		lappend Vars(list:folder) $folder
		set t $Vars(widget:list:file)
		$t selection clear
		$t selection add $sel
		$t see $sel
	}

	return ""
}


proc SetTooltip {w which folder} {
	variable [namespace parent]::${w}::Vars
	variable [namespace parent]::Options

	if {$folder eq "Favorites" || $folder eq "LastVisited"} {
		set folder [Tr $folder]
	} elseif {$Options(tooltip:shorten-paths)} {
		# NOTE: We are shortening the (display of) file path. This is a bit experimental.
		set parts [file split $folder]
		set k [expr {[llength $parts] - 1}]
		set length 0
		set count 0

		while {$k >= 0 && $length + [string length [lindex $parts $k]] < 30} {
			incr length [string length [lindex $parts $k]]
			incr length 1
			incr count
		}
		set count [expr {max(1, $count)}]

		if {$count + 2 < [llength $parts]} {
			set folder "\u2026[file join {*}[lrange $parts [expr {[llength $parts] - $count - 1}] end]]"
		}
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

	set t $Vars(widget:list:file)
	set id [$t identify $x $y]
	if {[llength $id] > 0 && [lindex $id 0] eq "header"} { return }
	foreach item [$t item children root] { $t item state set $item {!hilite} }

	set m $w.menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false -disabledforeground black

	if {$Vars(glob) eq "Files"} {
		set count 0
		set sel [$t item id active]
		if {$sel in [$t selection get]} {
			incr sel -1
			if {$sel >= [llength $Vars(list:folder)]} {
				set file [lindex $Vars(list:file) [expr {$sel - [llength $Vars(list:folder)]}]]
			} else {
				set file [lindex $Vars(list:folder) $sel]
			}
			$m add command                                       \
				-label [file tail $file]                          \
				-background $Options(menu:headerbackground)       \
				-foreground $Options(menu:headerforeground)       \
				-activebackground $Options(menu:headerbackground) \
				-activeforeground $Options(menu:headerforeground) \
				-font TkHeadingFont                               \
				-state disabled                                   \
				;
			$m add separator
#			if {![CurrentFileIsUsed $w]} {
				# NOTE ktrash is not working
				if {$Vars(state:delete) eq "normal" && $Vars(delete:action) eq "delete"} {
					incr count
					set name [string toupper $Vars(delete:action) 0 0]
					$m add command                                    \
						-compound left                                 \
						-image [set icon::16x16::$Vars(delete:action)] \
						-label " [Tr $name]"                           \
						-command [namespace code [list DeleteFile $w]] \
						;
				}
				if {$Vars(state:rename) eq "normal"} {
					incr count
					$m add command                                    \
						-compound left                                 \
						-image $icon::16x16::modify                    \
						-label " [Tr Rename]"                          \
						-command [namespace code [list RenameFile $w]] \
						;
				}
#			}
			if {$Vars(state:copy) eq "normal"} {
				incr count
				$m add command                                       \
					-compound left                                    \
					-image $icon::16x16::duplicate                    \
					-label " [Tr Duplicate]"                          \
					-command [namespace code [list DuplicateFile $w]] \
					;
			}
			if {	[llength $Vars(customcommand)]
				&& [llength $Vars(customtooltip)]
				&& $Vars(state:custom) eq "normal"
				&& [file extension $file] in $Vars(customfiletypes)} {
				incr count
				$m add command                                           \
					-compound left                                        \
					-image [lindex $Vars(customicon) 0 0]                 \
					-label " $Vars(customtooltip)"                        \
					-command [namespace code [list CallCustomCommand $w]] \
					;
			}
		}
		if {$Vars(state:new) eq "normal"} {
			incr count
			$m add command                                   \
				-compound left                                \
				-image $icon::16x16::folder_add               \
				-label " [Tr NewFolder]"                      \
				-command [namespace code [list NewFolder $w]] \
				;
		}
		if {$count > 0} { $m add separator }
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
	set text " [Tr DetailedLayout]"
	$sub add radiobutton                                     \
		-compound left                                        \
		-image $icon::16x16::list                             \
		-label $text                                          \
		-variable [namespace parent]::Options(show:layout)    \
		-command [namespace code [list SwitchLayout $w list]] \
		-value details                                        \
		;
	[namespace parent]::configureRadioEntry $sub $text
	set text " [Tr ListLayout]"
	$sub add radiobutton                                        \
		-compound left                                           \
		-image $icon::16x16::details                             \
		-label $text                                             \
		-variable [namespace parent]::Options(show:layout)       \
		-command [namespace code [list SwitchLayout $w details]] \
		-value list                                              \
		;
	[namespace parent]::configureRadioEntry $sub $text
	if {$::tcl_platform(platform) eq "unix"} {
		if {$Options(show:hidden)} { set ipref "" } else { set ipref "un" }
		variable _ShowHidden $Options(show:hidden)
		$m add checkbutton                                  \
			-compound left                                   \
			-image [set icon::16x16::${ipref}locked]         \
			-label " [Tr ShowHiddenFiles]"                   \
			-command [namespace code [list SwitchHidden $w]] \
			-variable [namespace current]::_ShowHidden       \
			;
	}

	set Vars(edit:active) 1
	tk_popup $m {*}[winfo pointerxy $w]
	bind $m <<MenuUnpost>> [list [namespace parent]::Stimulate $w]
}


proc Inspect {w mode args} {
	variable [namespace parent]::${w}::Vars

	set tl [winfo toplevel $w]

	if {$mode eq "show"} {
		set t $Vars(widget:list:file)
		lassign $args x y
		set id [$t identify $x $y]
		if {[llength $id] > 0 && [lindex $id 0] eq "header"} { return }
		set index [expr {[lindex $id 1] - 1}]
		switch $Vars(glob) {
			LastVisited - Favorites {
				set path [lindex $Vars(list:folder) $index]
				{*}$Vars(inspectcommand) $tl $path
			}
			default {
				if {$index >= [llength $Vars(list:folder)]} {
					set index [expr {$index - [llength $Vars(list:folder)]}]
					set file [lindex $Vars(list:file) $index]
				} else {
					set file [lindex $Vars(list:folder) $index]
				}
				{*}$Vars(inspectcommand) $tl $Vars(folder) $file
			}
		}
	} else {
		{*}$Vars(inspectcommand) $tl
	}
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

set restore [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
	ZSBJbWFnZVJlYWR5ccllPAAAAjhJREFUeNqcUj1s00AUfj6fY9w2DBlQKB0qVSBQmXA7loUB
	6MDUBSliQupINtaIGaSy0TWKVCExIBZGRpZYtAK1ClWVtoIkSPmrG/+c7fPxbOevHqjEJz3d
	vbt73/vu7pPuvT4AWVGADkOW5QIArAkhNnEEx7IgjZBz4EEAge8DTe0VOOfFUeJ7HlwGMl2M
	jMXC+nU9YvYYiztdhkSBEHHx840l3TTDWBqimlaO0RqulzGOYwK866OoePPpHb1Ws0DTCDy5
	v6AnvADTI/M4a3Xs1f2j7oNAiBIufaE+So3QbLpg2z5IEsWHTIqmCTgX4DiBOkMz+dXla3Nf
	v/0qBWFYl5ZfGbjJC6ikuPH4btz5w+cfRvqu2hWqLOTnclmNzjtuQEIiN2tHnXck6SAqgce2
	dj5WDde2wGcukgYrYRiO49y01/drrZ0/fafRFQS4Iufw3Mr4FyISn3lb7z/tGp7LwB1YF34B
	SX7j/tuTk3bXv5qFnjqj4rk8PWu3o00MDhJIleG116JiyzRjw0RQMpnYcNgcOsosnk18QvtI
	EEEiBB9QAiLLFUwraQ9gfgNVvlBvLuYakgZZz2L4Aa2JE4XYxu76qGMaQs0oytJi7uzW7XkX
	ZFBPG11UUKVTBfrDl8/0UxvAC5Nw+WQeIHsfc/xNmO21B87u3iH4fpkOXRfj8Bz94GK3SLK4
	OAqcKNaAKfV6z937/hMYKxFCjmk4UWAcvNn+l+3HVsYHLBNKYytLYmS3/8RfAQYAPjpdqK/T
	5bcAAAAASUVORK5CYII=
}]

set modify $::fsbox::bookmarks::icon::16x16::modify

set duplicate [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAElBMVEVjGABli9ydt+7s7/j/
	//9Udr4gqxYTAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCa
	nBgAAAAHdElNRQfcAQcLLzlI0zh5AAAAQUlEQVQI12NgYGBQDQ0NDQLSDKGCgoKhYAYIgBgh
	Li4uriBGsLGxsSmCAdYCYoC1gBkgAGKAtYAMDIFpIYYBcwMAgsMW8snNu0wAAAAASUVORK5C
	YII=
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

set trash [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAmJLR0QA/4ePzL8AAAFISURB
	VBgZBcG7TlNhAADg7/z9T89pESwULUnrrW6occLEuMnmYvQBHF19AeNL6ISTC7MBExfjApPV
	RR2MTkQTlUi4Bc7p3e9LALgxfWwKXvqSACS8Giyk5y14KAeUNhzbse9REld+dtOmkYknClNQ
	c4pLuu7sRIMtiQItLbOiwqF3hqruGRxEu/e7bUM1z2yCIJi46a49/lXanz9cHV35Zc+uWUuW
	tMw7p+675+8/roZer+m2B9o6rrlgTmpsRkddDYHSXyOHlp1oOuOypqplx/oIHO2fiv547bct
	R3qCbWd11BA5+HYiyEQVOXI0zJg3VxDYfrqxFtRV5TKJTGnRyObam3UC9AW5RZkoFeXqxgas
	E6GvVJMaqEo0EJWGIMLYVOqiHxoSiYrrCkMQYRRfuCVTB0wMfKUCCbDyNq9mgoCJiULp0yr8
	B2HEZMPtArUvAAAAAElFTkSuQmCC
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

# set ok [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
# 	CXBIWXMAAABIAAAASABGyWs+AAACp0lEQVQ4y42TT0gUYRjGn2/mm53Z2XHdXbc1U9HV/kiB
# 	JZZ0COoSJIKhYVaHLtI/KDoUBUV2KKIiIsqrh6jsz8WQDtalTkEURVoGIbGs7j/Ndt1dd2d2
# 	5vu+DlERFfqeXnh5Hl54fo+MJYykU7irDdXXsIzZRQvcZL9u8lIM1CoP9DbfHWNtsJ/bdq3k
# 	kUuhlppY7kta0KUYyG6pMrStoaulb6dWx8LN5F3yzPiT5zFAnJAWFWsUvqbg8aqeJk0mCrwu
# 	L9ZvbIM/GPRnW3KRRT8oa6qoUbeWH5MNBQIClmNh8NrV9As6ultqk95QAFBUBXrAAJM5mMVQ
# 	nM0DAPRqL8gKcim4v85gsGGxPO6fuxiLhD+1Q8eE3k8ZDW6uoQS806GsVTNUTRDpgTQmvy7l
# 	LahhvdnXG9onFA6bm3h7fTiTrI10MG5/VM6CLyzkQfOzmd5Al+9uoN0PYgBz9+YO8km+zu3x
# 	ROlyesHY4ZcZL2Fq8H0xoUR2sXL2QT+v8OzXDGALyGWNgUnmWAeMTYYHLgJttebKxvMpl6ES
# 	o8d72dXoJumHCTs2G9krtcrP5FMlVpxegGDiByOFz/NF5NXbPMsAR0DySOCErbF95g19i0Hm
# 	R2ZYfDraJzaQEXa6wHiKg3P+OyXBOKiszBCvOKSGNQJKkB1Krwr1VdU7sRKSrxIn0UkH+eEC
# 	41EGZjl/UsodDl3Tx4oTxThMALZA5dEqg1ZQJIZjQ6KX3pKvOAwZAlHif8UsAYAtO8LJiHdY
# 	EIAJqLUupAbiY6JHOSI/YtwczQuetf/dEwD4NpaCE7VfOnEHIieQHEjErXZ0+01/QTxmHOL/
# 	oJGfS3XHyvpcbnZcECSsPeh2pkoT4qbFFUdBybQWN/DWBWAxKwgJ82y7YPQpuDldWLRo3wEp
# 	ZjhR3++h3QAAAABJRU5ErkJggg==
# }]

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
bind FSBox <KeyPress-Prior>		{ fsbox::ScrollPage %W -1 }
bind FSBox <KeyPress-Next>			{ fsbox::ScrollPage %W +1 }

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
