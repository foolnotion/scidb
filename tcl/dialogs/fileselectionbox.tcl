# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 1994-1998 Sun Microsystems, Inc.
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This package is derived from tk8.5.6/library/tkfbox.tcl
# ----------------------------------------------------------------------
# This software is copyrighted by the Regents of the University of
# California, Sun Microsystems, Inc., and other parties.  The following
# terms apply to all files associated with the software unless explicitly
# disclaimed in individual files.
# 
# The authors hereby grant permission to use, copy, modify, distribute,
# and license this software and its documentation for any purpose, provided
# that existing copyright notices are retained in all copies and that this
# notice is included verbatim in any distributions. No written agreement,
# license, or royalty fee is required for any of the authorized uses.
# Modifications to this software may be copyrighted by their authors
# and need not follow the licensing terms described here, provided that
# the new terms are clearly indicated on the first page of each file where
# they apply.
# 
# IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
# DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# 
# THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
# IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
# NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
# 
# GOVERNMENT USE: If you are acquiring this software on behalf of the
# U.S. government, the Government shall have only "Restricted Rights"
# in the software and related documentation as defined in the Federal 
# Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
# are acquiring the software on behalf of the Department of Defense, the
# software shall be classified as "Commercial Computer Software" and the
# Government shall have only "Restricted Rights" as defined in Clause
# 252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
# authors grant the U.S. Government and others acting in its behalf
# permission to use and distribute the software in accordance with the
# terms specified in this license.
# ======================================================================

package require Tk 8.5
if {[catch { package require tkpng }]} { package require Img }

package provide fsbox 1.0

namespace eval dialog {

if {[tk windowingsystem] eq "win32"} {
	# TODO use option -verifycmd !!!
	proc openFile  {args} { return [tk_getOpenFile {*}[fsbox::FilterArgs $args]] }
	proc saveFile  {args} { return [tk_getSaveFile {*}[fsbox::FilterArgs $args]] }
	proc chooseDir {args} { return [tk_chooseDirectory {*}[fsbox::FilterArgs $args]] }
} else {
	proc openFile  {args} { return [fsbox::Open open {*}$args] }
	proc saveFile  {args} { return [fsbox::Open save {*}$args] }
	proc chooseDir {args} { return [fsbox::Open dir  {*}$args] }
}

namespace eval fsbox {
namespace eval mc {
### Client Relevant Data ########################################
set Add						"&Add"
set Cancel					"&Cancel"
set Directory				"&Directory:"
set Filename				"File &name:"
set Filenames				"File &names:"
set FilesType				"Files of &type:"
set Ok						"&Ok"
set Open						"&Open"
set Remove					"&Remove"
set Save						"&Save"
set Selection				"&Selection:"
set ShowHiddenDirs		"Show &Hidden Directories"
set ShowHiddenFiles		"Show &Hidden Files and Directories"

set ChooseDirectory		"Choose Directory"
set CreateFolder			"Create Folder"
set Desktop					"Desktop"
set FileSystem				"File System"
set Folder					"Folder:"
set HomeFolder				"Home Folder"
set TitleOpen				"Open"
set TitleSaveAs			"Save As"

set AddFolder				"Add the folder '%s' to the bookmarks"
set CannotChangeDir		"Cannot change to the directory \"%s\".\nPermission denied."
set CannotCreate			"The folder \"%s\" could not be created. Permission denied."
set DirDoesNotExist		"Directory \"%s\" does not exist."
set DirectoryRemoved		"Cannot change to the directory \"%s\".\nDirectory is removed."
set FileAlreadyExists	"File \"%s\" already exists.\n\nDo you want to overwrite it?"
set FileDoesNotExist		"File \"%s\" does not exist."
set FileExists				"The folder \"%s\" could not be created. File exists."
set GotoParentDir			"Go to parent directory"
set InvalidDirectory		"The directory \"%s\" does not exist. Open anyway?"
set InvalidFilename		"Invalid file name \"%s\"."
set InvalidFileExt		"Invalid file extension \"%s\"."
set RemoveBookmark		"Remove the bookmark '%s'"
set SelectWhichType		"Select which type of file are shown"
#################################################################
} ;# namespace mc

### Client Relevant Data ########################################
variable showHiddenBtn 0
variable showHiddenVar 1
variable destroyOnExit 0

variable iconAdd {}
variable iconRemove {}
variable iconSave {}
variable iconCancel {}
variable iconOpen {}
variable iconFolder {}

proc tooltip {args} {}
proc makeStateSpecificIcons {img} { return $img }
proc messageBox {args} { return [tk_messageBox {*}$args] }
proc mc {msg args} { return [::msgcat::mc [set $msg] {*}$args] }
#################################################################

variable Priv


proc setBookmarks {list} {
	variable Priv
	variable IconFolder

	set Priv(bookmarks) {}
	foreach {text dir} $list {
		lappend Priv(bookmarks) [list $text $dir $IconFolder 1]
	}
}


proc getBookmarks {} {
	variable Priv

	set bookmarks {}

	if {[info exists Priv(bookmarks)]} {
		foreach entry $Priv(bookmarks) {
			lassign $entry text dir icon flag
			if {$flag} {
				lappend bookmarks $text $dir
			}
		}
	}

	return $bookmarks
}


proc setupIcon {ext icon} {
	variable Priv
	set Priv(icon:$ext) $icon
}


proc geometry {{whichPart size}} {
	variable Priv

	set geom $Priv(geometry)
	if {$geom eq ""} { return "" }

	switch -glob -- $whichPart {
		*size {
			set geom [lindex [split [lindex [split $geom "-"] 0] "+"] 0]
		}
		*pos {
			set ip [string first "+" $geom]
			set im [string first "-" $geom]
			if {$im != -1 && ($im < $ip || $ip == -1)} { set ip $im }
			set geom [string range $geom $ip end]
		}
	}

	return $geom
}


proc setFileTypes {w fileTypes} {
	set dataName [winfo name $w]
	upvar [namespace current]::$dataName data

	if {$data(class) ne "FileDialog"} { return }
	set data(-filetypes) [FDGetFileTypes $dataName $fileTypes]
	$data(typeMenu) delete 0 end

	if {[llength $data(-filetypes)]} {
		# Default type and name to first entry
		set initialtype     [lindex $data(-filetypes) 0]
		set initialTypeName [lindex $initialtype 0]

		if {($data(-typevariable) ne "") && [upvar 2 [list info exists $data(-typevariable)]]} {
			set initialTypeName [upvar 2 [list set $data(-typevariable)]]
		}

		foreach type $data(-filetypes) {
			set title  [lindex $type 0]
			set filter [lindex $type 1]

			$data(typeMenu) add command \
				-label $title \
				-command [list [namespace current]::SetFilter $w $type]

			# string first avoids glob-pattern char issues
			if {[string first ${initialTypeName} $title] == 0} {
				set initialtype $type
			}
		}

		$data(typeMenuBtn) configure -state normal -takefocus 1
		$data(typeMenuLab) configure -state normal
	} else {
		set data(filter) "*"
		$data(typeMenuBtn) configure -state disabled -takefocus 0
		$data(typeMenuLab) configure -state disabled
	}

	if {[info exists initialtype]} {
		SetFilter $w $initialtype
	} else {
		SetFilter $w [list "" "*"]
	}

#	$data(ent) delete 0 end
}


proc changeFileDialogType {w type} {
	upvar [namespace current]::[winfo name $w] data

	switch -- $type {
		save { set data(type) save }
		open { set data(type) open }
	}
}


proc Open {type args} {
	variable Priv
	variable iconSave
	variable iconOpen
	variable iconFolder
	variable showHiddenBtn
	variable destroyOnExit

	if {$type eq "dir"} {
		set dataName __choosedir
		set class "ChooseDir"
	} else {
		set dataName __filedialog
		set class "FileDialog"
	}
	upvar [namespace current]::$dataName data
	set data(-place) "centeronscreen"
	set data(-geometry) ""
	set recreated 1

	Config $dataName $type $args

	if {$data(-parent) eq "."} {
		set w .$dataName
	} else {
		set w $data(-parent).$dataName
	}

	# (re)create the dialog box if necessary

	if {![winfo exists $w]} {
		Create $w $class
	} elseif {[winfo class $w] ne $class} {
		destroy $w
		Create $w $class
	} else {
		set data(dirMenuBtn) $w.contents.dirMenu
		set data(dirMenu) $w.contents.dirMenu.m
		set data(dirent)  $w.contents.dirent
		set data(newDir) $w.contents.new
		set data(upBtn) $w.contents.up
		set data(selection) $w.contents.selection
		set data(bookmarks) $w.contents.bookmarks
		set data(ent) $w.contents.ent
		set data(okBtn) $w.buttons.ok
		set data(cancelBtn) $w.buttons.cancel
		set data(hiddenBtn) $w.buttons.hidden
		set data(dirLbl) $w.contents.lab
		if {$class eq "FileDialog"} {
			set data(typeMenuLab) $w.contents.fType
			set data(typeMenuBtn) $w.contents.typeMenu
			set data(typeMenu) $data(typeMenuBtn).m
		}
		SetSelectMode $w $data(-multiple)
		set recreated 0
	}
	set data(class) $class

	switch -- $type {
		save {
			if {[llength $iconSave]} {
				$data(okBtn) configure -image $iconSave
				::tk::SetAmpText $data(okBtn) " [Tr Save]"
			} else {
				::tk::SetAmpText $data(okBtn) [Tr Save]
			}
		}

		open {
			if {[llength $iconOpen]} {
				$data(okBtn) configure -image $iconOpen
				::tk::SetAmpText $data(okBtn) " [Tr Open]"
			} else {
				::tk::SetAmpText $data(okBtn) [Tr Open]
			}
			$data(okBtn) configure -state normal
		}

		dir {
			if {[llength $iconFolder]} {
				$data(okBtn) configure -image $iconFolder
				::tk::SetAmpText $data(okBtn) " [Tr Open]"
			} else {
				::tk::SetAmpText $data(okBtn) [Tr Open]
			}
			$data(okBtn) configure -state normal
		}
	}

	if {$showHiddenBtn} {
		pack $data(hiddenBtn)
	} else {
		pack forget $data(hiddenBtn)
	}

	if {$class eq "ChooseDir" && $data(-mustexist)} {
		$data(ent) configure -validate key -validatecommand [list [namespace current]::IsOK? $w %P]
	} else {
		$data(ent) configure -validate none
	}

	# Make sure subseqent uses of this dialog are independent [Bug 845189]
	unset -nocomplain data(extUsed)

	# Dialog boxes should be transient with respect to their parent,
	# so that they will always stay on top of their parent window.  However,
	# some window managers will create the window as withdrawn if the parent
	# window is withdrawn or iconified.  Combined with the grab we put on the
	# window, this can hang the entire application.  Therefore we only make
	# the dialog transient if the parent is viewable.

	if {[winfo viewable [winfo toplevel $data(-parent)]]} {
		wm transient $w $data(-parent)
	}

	# Add traces on the selectPath variable

	trace add variable data(selectPath) write [list [namespace current]::SetPath $w]
	$data(dirMenuBtn) configure -textvariable [namespace current]::${dataName}(selectPath)

	# Cleanup previous menu

	if {$class eq "FileDialog"} {
		$data(typeMenu) delete 0 end
		$data(typeMenuBtn) configure -state normal -text ""
	}

	# Initialize the file types menu

	set data(filter) "*"
	set data(previousEntryText) ""
	if {$data(type) ne "dir"} {
		setFileTypes $w $data(-filetypes)
	}

	unset -nocomplain Priv(min:bookmarks)
	unset -nocomplain Priv(min:selection)

	set dlg $w

	if {!$data(-embed)} {
		wm title $dlg $data(-title)

		set geometry $data(-geometry)
		if {[string match last* $geometry]} { set geometry [geometry $geometry] }

		if {!$recreated} {
			wm geometry $dlg $geometry
		} else {
			update idletasks
			set rw [winfo reqwidth  $dlg]
			set rh [winfo reqheight $dlg]
			if {[string first "+" $geometry] >= 0} {
				wm geometry $dlg $geometry
			} else {
				if {[llength $geometry] == 0} {
					set geometry [format "%dx%d" $rw $rh]
					set w $rw
					set h $rh
				} else {
					scan $geometry "%dx%d" w h
				}
				set parent $data(-parent)
				set sw [winfo screenwidth  $parent]
				set sh [winfo screenheight $parent]
				if {$parent eq "." || $data(-place) eq "centeronscreen"} {
					set x0 [expr {($sw - $w)/2 - [winfo vrootx $parent]}]
					set y0 [expr {($sh - $h)/2 - [winfo vrooty $parent]}]
				} else {
					set x0 [expr {[winfo rootx $parent] + ([winfo width  $parent] - $w)/2}]
					set y0 [expr {[winfo rooty $parent] + ([winfo height $parent] - $h)/2}]
				}
				set x "+$x0"
				set y "+$y0"
				if {[tk windowingsystem] ne "win32"} {
					if {$x0 + $w > $sw}	{ set x "-0"; set x0 [expr {$sw - $w}] }
					if {$x0 < 0}			{ set x "+0" }
					if {$y0 + $h > $sh}	{ set y "-0"; set y0 [expr {$sh - $h}] }
					if {$y0 < 0}			{ set y "+0" }
				}
				if {[tk windowingsystem] eq "aqua"} {
					# avoid the native menu bar which sits on top of everything
					scan $y0 "%d" y
					if {0 <= $y && $y < 22} { set y0 "+22" }
				}
				wm geometry $dlg $geometry${x}${y}
			}
			wm minsize $dlg $rw $rh
			update idletasks
#			set Priv(min:bookmarks) [winfo width $data(bookmarks)]
			set Priv(min:selection) [winfo width $data(selection)]
		}

		wm iconname $dlg ""
		wm deiconify $dlg
	} else {
#		set Priv(min:bookmarks) [winfo reqwidth $data(bookmarks)]
		set Priv(min:selection) [winfo reqwidth $data(selection)]
	}

	set Priv(min:bookmarks) 120
	SetupBookmarks $dlg
	if {$class ne "FileDialog"} { UpdateWhenIdle $dlg }

	$data(ent) delete 0 end
	if {$class eq "FileDialog"} {
		$data(ent) insert 0 $data(selectFile)
	} else {
		$data(ent) insert 0 $data(selectPath)
	}
	$data(ent) icursor end

	# Wait for the user to respond, then restore the focus and
	# return the index of the selected button.  Restore the focus
	# before deleting the window, since otherwise the window manager
	# may take the focus away so we can't redirect it.  Finally,
	# restore any grab that was in effect.

	if {$data(-embed)} { return $w }
	$data(ent) selection range 0 end

	# Set a grab and claim the focus too.
	::tk::SetFocusGrab $dlg $data(ent)

	vwait [namespace current]::Priv(selectFilePath)

	if {$destroyOnExit} {
		::tk::RestoreFocusGrab $dlg $data(ent)
		destroy $dlg
	} else {
		::tk::RestoreFocusGrab $dlg $data(ent) withdraw
		$data(dirMenuBtn) configure -textvariable {}
	}

	# Cleanup traces on selectPath variable

	foreach trace [trace info variable data(selectPath)] {
		trace remove variable data(selectPath) [lindex $trace 0] [lindex $trace 1]
	}

	return $Priv(selectFilePath)
}


proc SetupBookmarks {w} {
	variable Priv
	set dataName [winfo name $w]
	upvar [namespace current]::$dataName data

	::tk::IconList_DeleteAll $data(bookmarks)
	set bookmarks $Priv(bookmarks)
	set Priv(bookmarks) {}

	foreach entry $bookmarks {
		lassign $entry text dir icon flag

		if {[file isdirectory $dir]} {
			::tk::IconList_Add $data(bookmarks) $icon [list $text]
			lappend Priv(bookmarks) $entry
		}
	}

	::tk::IconList_Arrange $data(bookmarks)
}


proc Config {dataName type argList} {
	upvar [namespace current]::$dataName data

	set data(chdir) ""
	set data(mode) "file"
	set data(type) $type
	set data(index) -1
	set data(dir) ""

	# 0: Delete all variable that were set on data(selectPath) the
	# last time the file dialog is used. The traces may cause troubles
	# if the dialog is now used with a different -parent option.

	foreach trace [trace info variable data(selectPath)] {
		trace remove variable data(selectPath) [lindex $trace 0] [lindex $trace 1]
	}

	# 1: the configuration specs

	switch $type {
		dir {
			set specs {
				{-cancel "" "" ""}
				{-embed "" "" 0}
				{-geometry "" "" ""}
				{-initialdir "" "" ""}
				{-mustexist "" "" 0}
				{-newdir "" "" 1}
				{-ok "" "" ""}
				{-parent "" "" "."}
				{-place "" "" ""}
				{-title "" "" ""}
			}
		}
		save {
			set specs {
				{-cancel "" "" ""}
				{-defaultextension "" "" ""}
				{-embed "" "" 0}
				{-filetypes "" "" ""}
				{-geometry "" "" ""}
				{-initialdir "" "" ""}
				{-initialfile "" "" ""}
				{-newdir "" "" 1}
				{-ok "" "" ""}
				{-parent "" "" "."}
				{-place "" "" ""}
				{-title "" "" ""}
				{-typevariable "" "" ""}
				{-verifycmd "" "" ""}
			}
		}
		default {
			set specs {
				{-cancel "" "" ""}
				{-defaultextension "" "" ""}
				{-embed "" "" 0}
				{-filetypes "" "" ""}
				{-geometry "" "" ""}
				{-initialdir "" "" ""}
				{-initialfile "" "" ""}
				{-newdir "" "" 0}
				{-ok "" "" ""}
				{-parent "" "" "."}
				{-place "" "" ""}
				{-title "" "" ""}
				{-typevariable "" "" ""}
			}
		}
	}

	# The "-multiple" option is only available for the "open" file dialog.

	if {$type eq "open"} {
		lappend specs {-multiple "" "" "0"}
	}

	# 2: default values depending on the type of the dialog

	if {![info exists data(selectPath)]} {
		# first time the dialog has been popped up
		set data(selectPath) [pwd]
		set data(selectFile) ""
	}

	# 3: parse the arguments

	tclParseConfigSpec [namespace current]::$dataName $specs "" $argList

	if {$data(-title) eq ""} {
		switch -- $type {
			open	{ set data(-title) [Tr TitleOpen] }
			save	{ set data(-title) [Tr TitleSaveAs] }
			dir	{ set data(-title) [Tr ChooseDirectory] }
		}
	}

	# 4: set the default directory and selection according to the -initial
	#    settings

	if {$data(-initialdir) ne ""} {
		# Ensure that initialdir is an absolute path name.
		if {[file isdirectory $data(-initialdir)]} {
			set old [pwd]
			cd $data(-initialdir)
			set data(selectPath) [pwd]
			cd $old
		} else {
			set data(selectPath) [pwd]
		}
	}

	if {$data(type) ne "dir" } {
		set data(selectFile) $data(-initialfile)
	}

	# 5. Parse the -filetypes option

	if {![winfo exists $data(-parent)]} {
		error "bad window path name \"$data(-parent)\""
	}

	# Set -multiple to a one or zero value (not other boolean types
	# like "yes") so we can use it in tests more easily.
	if {$type eq "save"} {
		set data(-multiple) 0
	} elseif {$data(type) ne "dir" && $data(-multiple)} {
		set data(-multiple) 1
	} else {
		set data(-multiple) 0
	}
}


# In ::tk::FDGetFileTypes argument string is limited to length 40 (our limit is 60)
proc FDGetFileTypes {dataName string} {
	upvar [namespace current]::$dataName data

	foreach t $string {
		if {[llength $t] < 2 || [llength $t] > 3} {
			error "bad file type \"$t\", should be \"typeName {extension ?extensions ...?} \
					?{macType ?macTypes ...?}?\""
		}
		lappend fileTypes([lindex $t 0]) {*}[lindex $t 1]
	}

	set types {}
	foreach t $string {
		set label [lindex $t 0]
		set exts {}

		if {[info exists hasDoneType($label)]} { continue }

		# Validate each macType.  This is to agree with the 
		# behaviour of TkGetFileFilters().  This list may be
		# empty.
		foreach macType [lindex $t 2] {
			if {[string length $macType] != 4} {
				error "bad Macintosh file type \"$macType\""
			}
		}

		set name "$label \("
		set sep ""
		set doAppend 1

		foreach ext $fileTypes($label) {
			if {$ext eq ""} { continue }
			regsub {^[.]} $ext "*." ext

			if {![info exists hasGotExt($label,$ext)]} {
				if {$doAppend} {
					if {[string length $sep] && [string length $name] > 60} {
						set doAppend 0
						append name $sep...
					} else {
						append name $sep$ext
					}
				}
				lappend exts $ext
				set hasGotExt($label,$ext) 1
			}

			set sep ","
		}

		append name "\)"
		lappend types [list $name $exts]

		set hasDoneType($label) 1
	}

	return $types
}


proc Create {w class} {
	variable IconHome
	variable iconCancel
	variable iconAdd
	variable iconRemove
	variable IconUp
	variable iconOpen
	variable iconFolder
	variable IconFolderNew
	variable IconDesktop
	variable IconRoot
	variable Priv

	set Priv(afterId) {}
	if {![info exists Priv(geometry)]} { set Priv(geometry) "" }
	set dataName [lindex [split $w .] end]
	upvar [namespace current]::$dataName data

	set bookmarks {}
	if {	![info exists Priv(bookmarks)]
		|| [llength $Priv(bookmarks)] == 0
		|| [lindex [lindex $Priv(bookmarks) 0] 3]} {

		set bookmarks {}
		lappend bookmarks [list [Tr HomeFolder] [file nativename "~"] $IconHome 0]
		lappend bookmarks [list [Tr Desktop] [file nativename "~/Desktop"] $IconDesktop 0]
		lappend bookmarks [list [Tr FileSystem] "/" $IconRoot 0]
		if {[info exists Priv(bookmarks)]} { lappend bookmarks {*}$Priv(bookmarks) }
		set Priv(bookmarks) $bookmarks
	}

	if {![info exists data(selectPath)]} { set data(selectPath) "" }

	# 1. the top level window

	if {$data(-embed)} {
		::ttk::frame $w -class $class -takefocus 0
	} else {
		toplevel $w -class $class
		bind $w <Configure> "[namespace current]::RecordGeometry $w %W %w"
		wm withdraw $w
	}
	set contents [ttk::frame $w.contents]
	set buttons [tk::frame $w.buttons]
	set lt $contents
	set rt $contents
	ttk::style configure fsbox.TButton -anchor w

	# the "new directory" button and entry

	set data(newDir) [ttk::button $rt.new \
							-image [makeStateSpecificIcons $IconFolderNew] \
							-command [list [namespace current]::CreateDirectory $w]]
	tooltip $data(newDir) [Tr CreateFolder]
	set data(dirent) [ttk::entry $rt.dirent -cursor xterm]
	bind $data(dirent) <FocusOut> [list [namespace current]::RestoreDirMenu $w]
	bind $data(dirent) <Return> "[namespace current]::MakeDir $w; break"
	bind $data(dirent) <Escape> "[namespace current]::EscapeDirEntry $w; break"

	# the directory label

	set data(dirLbl) [::tk::AmpWidget ttk::label $lt.lab -text [Tr Directory]]
	bind $data(dirLbl) <<AltUnderlined>> [list focus $lt.dirMenu]

	# the directory option menu (incl. buttons)

	set data(dirMenuBtn) $rt.dirMenu
	set data(dirMenu) $rt.dirMenu.m

	ttk::menubutton $data(dirMenuBtn) \
		-menu $data(dirMenu) \
		-takefocus 1 \
		-direction flush \
		-textvariable [format %s(selectPath) [namespace current]::$dataName]

	[menu $data(dirMenu) -tearoff 0] add radiobutton \
		-label "" \
		-variable [format %s(selectPath) [namespace current]::$dataName]

	set data(upBtn) [ttk::button $rt.up -image $IconUp]
	tooltip $data(upBtn) [Tr GotoParentDir]

	# the IconList that list the bookmarks

	set data(bookmarks) [::tk::IconList $lt.bookmarks \
		-command [list [namespace current]::SelectPath $w] \
		-multiple 0]
	bind $data(bookmarks) <<ListboxSelect>> [list [namespace current]::ResetRemoveButton $w]
	upvar ::tk::${data(bookmarks)} iconListData

	if {![info exists Priv(bookmarks,width)]} { set Priv(bookmarks,width) 110 }
	$iconListData(canvas) configure -width $Priv(bookmarks,width)
	set Priv(bookmarks,canvas) $iconListData(canvas)

	# the bookmark buttons (Add & Remove)

	set data(addBtn) [tk::AmpWidget ttk::button $lt.add \
		-style fsbox.TButton \
		-state disabled \
		-command [list [namespace current]::AddDir $w]]
	set data(removeBtn) [tk::AmpWidget ttk::button $lt.remove \
		-style fsbox.TButton \
		-state disabled \
		-command [list [namespace current]::RemoveDir $w]]
	if {[llength $iconAdd] && [llength $iconRemove]} {
		$lt.add configure -compound left -image [makeStateSpecificIcons $iconAdd]
		$lt.remove configure -compound left -image [makeStateSpecificIcons $iconRemove]
		tk::SetAmpText $lt.add " [Tr Add]"
		tk::SetAmpText $lt.remove " [Tr Remove]"
	} else {
		tk::SetAmpText $lt.add "  [Tr Add]  "
		tk::SetAmpText $lt.remove "  [Tr Remove]  "
	}
	
	# the IconList that list the files and directories

	if {$class eq "FileDialog"} {
		set iconListCommand [list [namespace current]::OkCmd $w]
	} else {
		set iconListCommand [list [namespace current]::DblClick $w]
	}

	set data(selection) [::tk::IconList $rt.selection \
		-command $iconListCommand \
		-multiple $data(-multiple)]
	bind $data(selection) <<ListboxSelect>> [list [namespace current]::ListBrowse $w]
	upvar ::tk::$data(selection) browserData
	bind $browserData(canvas) <Return> {+ break }

	# the file name row

	if {$class ne "FileDialog"} {
		set fNameCaption [Tr Selection]
	} elseif { $data(-multiple) } {
		set fNameCaption [Tr :Filenames]
	} else {
		set fNameCaption [Tr Filename]
	}

	set data(fname) [::tk::AmpWidget ttk::label $rt.fname -text $fNameCaption]
	bind $data(fname) <<AltUnderlined>> [list focus $rt.ent]
	set data(ent) [ttk::entry $rt.ent -cursor xterm]

	# the file type line (only if this is a File Dialog)

	if {$class eq "FileDialog"} {
		set data(typeMenuLab) [::tk::AmpWidget ttk::label $rt.fType \
										-text [Tr FilesType] \
										-anchor e]
		set data(typeMenuBtn) [ttk::menubutton $rt.typeMenu -menu $rt.typeMenu.m]
		set data(typeMenu) [menu $data(typeMenuBtn).m -tearoff 0]
		bind $data(typeMenuLab) <<AltUnderlined>> [list focus $data(typeMenuBtn)]
		tooltip $data(typeMenuBtn) [Tr SelectWhichType]
	}

	# the dialog button frame

	if {$class eq "FileDialog"} {
		set text [Tr ShowHiddenFiles]
	} else {
		set text [Tr ShowHiddenDirs]
	}
	set data(hiddenBtn) [::tk::AmpWidget ttk::checkbutton $buttons.hidden \
		-text $text \
		-variable [namespace current]::showHiddenVar \
		-command [list [namespace current]::UpdateWhenIdle $w]]

	set data(cancelBtn) [tk::AmpWidget ttk::button $buttons.cancel -class TButton -default normal]
	set data(okBtn) [tk::AmpWidget ttk::button $buttons.ok -class TButton]
	$data(okBtn) configure -default active
	set iconOk [expr {$class eq "FileDialog" ? $iconOpen : $iconFolder}]
	if {[llength $iconOk] && [llength $iconCancel]} {
		$buttons.cancel configure -compound left -image $iconCancel
		$buttons.ok configure -compound left -image $iconOk
		tk::SetAmpText $buttons.cancel " [Tr Cancel]"
		tk::SetAmpText $buttons.ok " [Tr Ok]"
	} else {
		tk::SetAmpText $buttons.cancel [Tr Cancel]
		tk::SetAmpText $buttons.ok [Tr Ok]
	}
	bind $data(okBtn) <Destroy> [list [namespace current]::Destroyed $w]

	# the resize handle frame

	set fHnd [ttk::frame $w.contents.handle -width 5 -cursor sb_h_double_arrow]
	bind $fHnd <ButtonPress-1> [list [namespace current]::PaneHandleClick $w %X %Y]
	bind $fHnd <Button1-Motion> [list [namespace current]::PaneHandleMotion $w %X %Y]

	# pack all the frames together, we are done with widget construction

	if {$data(-newdir)} {
		grid $data(newDir)		-column 1 -row 1 -sticky nsw
	}
	grid $data(dirLbl)			-column 1 -row 1 -sticky nse
	grid $data(bookmarks)		-column 1 -row 3 -sticky nsew
	grid $data(addBtn)			-column 1 -row 5 -sticky nsew
	grid $data(removeBtn)		-column 1 -row 7 -sticky nsew

	grid $data(dirMenuBtn)		-column 3 -row 1 -sticky nsew -columnspan 3
	grid $data(upBtn)				-column 7 -row 1 -sticky nsew
	grid $data(selection)		-column 3 -row 3 -sticky nsew -columnspan 5
	if {$class eq "FileDialog"} {
		grid $data(fname)			-column 3 -row 5 -sticky nse
		grid $data(ent)			-column 5 -row 5 -sticky nsew -columnspan 3
		grid $data(typeMenuLab)	-column 3 -row 7 -sticky nse
		grid $data(typeMenuBtn)	-column 5 -row 7 -sticky nsew -columnspan 3
	} else {
		grid $data(fname)			-column 3 -row 5 -sticky nsw  -columnspan 5
		grid $data(ent)			-column 3 -row 7 -sticky nsew -columnspan 5
	}
	grid $fHnd						-column 2 -row 0 -sticky nsew -rowspan 9

	grid rowconfigure $contents {0 2 3 4 6 8} -minsize 5
	grid rowconfigure $contents 3 -weight 1
	grid columnconfigure $contents {0 4 6 8} -minsize 5
	grid columnconfigure $contents 5 -weight 1
	grid columnconfigure $contents 1 -minsize 115

	pack $contents -expand 1 -fill both
	pack [ttk::separator $w.sep] -fill x
	pack $buttons -fill x
	pack $data(hiddenBtn) -pady 5 -padx 5 -side left
	pack $data(okBtn) -pady 5 -padx 5 -fill x -side right
	pack $data(cancelBtn) -pady 5 -padx 5 -fill x -side right

	# The font to use for the icons. The default Canvas font on Unix is just deviant.
	set ::tk::$lt.bookmarks(font) [$data(ent) cget -font]
	set ::tk::$rt.selection(font) [$data(ent) cget -font]

	# Set up the event handlers that are common to Directory and File Dialogs

	if {!$data(-embed)} {
		wm protocol $w WM_DELETE_WINDOW [list [namespace current]::CancelCmd $w]
	}
	$data(upBtn) configure -command [list [namespace current]::UpDirCmd $w]
	$data(cancelBtn) configure -command [list [namespace current]::CancelCmd $w]
	bind [winfo toplevel $w] <Escape> [list $data(cancelBtn) invoke]
	if {!$data(-embed)} { bind $w <Alt-Key> [list tk::AltKeyInDialog $w %A] }
	bind [winfo toplevel $w] <Return> \
		"if {\[$data(okBtn) cget -state\] eq {normal}} { $data(okBtn) invoke }"

	# Set up event handlers specific to File or Directory Dialogs

	if {$class eq "FileDialog"} {
		bind $data(ent) <Return> "[namespace current]::ActivateEnt $w; break"
		set okCmd "[namespace current]::OkCmd $w"
	} else {
		set okCmd "
			if {\[$data(okBtn) cget -state\] eq {normal}} { [namespace current]::OkCmd $w }
			break
		"
		bind $data(ent) <Return> $okCmd
	}
	$data(okBtn) configure -command $okCmd
	bind $data(ent) <Tab> "[namespace current]::CompleteEnt $w"

	# Build the focus group for all the entries

	bind $data(ent) <FocusIn>	[list [namespace current]::EntFocusIn $w]
	bind $data(ent) <FocusOut>	[list [namespace current]::EntFocusOut $w]
}


proc Tr {tok {args {}}} {
	return [mc [namespace current]::mc::$tok {*}$args]
}


proc CreateDirectory {w} {
	upvar [namespace current]::[winfo name $w] data

	$data(newDir) configure -state disabled
	::tk::SetAmpText $data(dirLbl) [Tr Folder]
	grid forget $data(dirMenuBtn)
	grid forget $data(upBtn)
	grid $data(dirent) -column 3 -row 1 -sticky nsew -columnspan 5
	focus $data(dirent)
	$data(dirent) selection range 0 end
}


proc RestoreDirMenu {w} {
	upvar [namespace current]::[winfo name $w] data

	$data(newDir) configure -state normal
	::tk::SetAmpText $data(dirLbl) [Tr Directory]
	grid forget $data(dirent)
	grid $data(dirMenuBtn)	-column 3 -row 1 -sticky nsew -columnspan 3
	grid $data(upBtn)			-column 7 -row 1 -sticky nsew
}


proc MakeDir {w} {
	upvar [namespace current]::[winfo name $w] data

	set text [$data(dirent) get]

	if {[llength $text]} {
		set dir [JoinFile $data(selectPath) $text]

		if {[file exists $dir]} {
			if {![file isdirectory $dir]} {
				set message [Tr FileExists $dir]
				messageBox -type ok -parent $w -icon error -message $message
			}
		} elseif {[catch {file mkdir $dir}]} {
			set message [Tr CannotCreate $dir]
			messageBox -type ok -parent $w -icon error -message $message
		}

		if {[file isdirectory $dir]} {
			set data(selectPath) $dir
		}
	}

	RestoreDirMenu $w
}


proc EscapeDirEntry {w} {
	upvar [namespace current]::[winfo name $w] data

	if {$data(dirent) in [grid slaves [winfo parent $data(dirent)]]} {
		RestoreDirMenu $w
	} else {
		CancelCmd $w
	}
}


proc DblClick {w} {
	upvar [namespace current]::[winfo name $w] data

	set selection [tk::IconList_CurSelection $data(selection)]

	if {[llength $selection]} {
		set filenameFragment [tk::IconList_Get $data(selection) [lindex $selection 0]]
		set file $data(selectPath)
		if {[file isdirectory $file]} {
			ListInvoke $w [list $filenameFragment]
		}
	}
}


proc RecordGeometry {dlg window width} {
	variable Priv
	upvar [namespace current]::[winfo name $dlg] data

	if {$window eq $dlg} {
		set g [winfo geometry $dlg]
		scan $g "%ux%u" gw gh

		if {$gw <= 1} { return }

		set rw [winfo reqwidth $dlg]
		set rh [winfo reqheight $dlg]

		if {$gw != $rw || $gh != $rh} {
			set Priv(geometry) $g
		} elseif {[llength $Priv(geometry)]} {
			scan $Priv(geometry) "%ux%u" pw ph
			if {$gw < $pw || $gh < $ph} { set Priv(geometry) $g }
		}
	} elseif {$window eq $data(selection)} {
		if {[info exists Priv(min:selection)]} {
			if {$width < $Priv(min:selection)} {
				set bkmW [winfo width $data(bookmarks)]
				set incr [expr {$Priv(min:selection) - $width}]
				after idle [list grid columnconfigure $dlg.contents 1 -minsize [expr {$bkmW - $incr}]]
			}
		}
	}
}


proc PaneHandleClick {w x y} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	set Priv(x) $x
	set Priv(width:selection) [winfo width $data(selection)]
	set Priv(width:bookmarks) [winfo width $data(bookmarks)]
}


proc PaneHandleMotion {w x y} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	set incr [expr {$x - $Priv(x)}]

	if {[expr {$Priv(width:selection) - $incr}] < $Priv(min:selection)} {
		set incr [expr {$Priv(width:selection) - $Priv(min:selection)}]
	}

	set bkmW [expr {$Priv(width:bookmarks) + $incr}]
	if {$bkmW < $Priv(min:bookmarks)} { return }

	if {$bkmW != [winfo width $data(bookmarks)]} {
		grid columnconfigure $w.contents 1 -minsize $bkmW
		set Priv(bookmarks,width) [winfo width $Priv(bookmarks,canvas)]
	}
}


proc SelectPath {w} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	set selection [::tk::IconList_CurSelection $data(bookmarks)]

	if {[llength $selection]} {
		set entry [lindex $Priv(bookmarks) $selection]

		if {[llength $entry]} {
			if {$data(type) eq "dir"} {
				ListInvoke $w [lindex $entry 1]
			} else {
				set selectPath $data(selectPath)
				VerifyFileName $w [lindex $entry 1]
				if {$selectPath ne $data(selectPath)} { SetPath $w }
			}
		}
	}
}


proc ResetRemoveButton {w} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	if {![$data(removeBtn) instate {pressed}]} {
		set data(index) -1
		set selection [::tk::IconList_CurSelection $data(bookmarks)]

		if {[llength $selection] == 0} {
			$data(removeBtn) configure -state disabled
			tooltip clear $data(removeBtn)
		} else {
			set entry [lindex $Priv(bookmarks) $selection]

			if {[lindex $entry 3]} {
				$data(removeBtn) configure -state normal
				tooltip $data(removeBtn) [Tr RemoveBookmark [lindex $entry 0]]
				set data(index) $selection
			}
		}

		if {[$data(removeBtn) cget -state] eq "disabled" && [focus] eq $data(removeBtn)} {
			focus [tk_focusNext $data(removeBtn)]
		}
	}
}


proc AddDir {w} {
	variable IconFolder
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	if {[file isdirectory $data(dir)]} {
		set index [lsearch -exact -index 1 $Priv(bookmarks) $data(dir)]

		if {$index == -1} {
			set text [file tail $data(dir)]
			lappend Priv(bookmarks) [list $text $data(dir) $IconFolder 1]
			::tk::IconList_Add $data(bookmarks) $IconFolder [list $text]
			::tk::IconList_Arrange $data(bookmarks)
		}
	}

	$data(addBtn) configure -state disabled
	tooltip clear $data(addBtn)
}


proc RemoveDir {w} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	if {$data(index) >= 0} {
		set entry [lindex $Priv(bookmarks) $data(index)]

		if {[lindex $entry 3]} {
			set Priv(bookmarks) [lreplace $Priv(bookmarks) $data(index) $data(index)]
			SetupBookmarks $w
		}
	}

	$data(removeBtn) configure -state disabled
	tooltip clear $data(removeBtn)
	set data(index) -1
}


proc SetSelectMode {w multi} {
	variable Priv
	set dataName __filedialog
	upvar [namespace current]::$dataName data
	if { $multi } {
		set fNameCaption [Tr Filenames]
	} else {
		set fNameCaption [Tr Filename]
	}
	set iconListCommand [list [namespace current]::OkCmd $w]
	::tk::SetAmpText $data(fname) $fNameCaption
	::tk::IconList_Config $data(selection) [list -multiple $multi -command $iconListCommand]
}


proc UpdateWhenIdle {w} {
	upvar [namespace current]::[winfo name $w] data

	if {![info exists data(updateId)]} {
		set data(updateId) [after idle [list [namespace current]::Update $w]]
	}
}


proc Update {w} {
	variable IconFolder
	variable IconDocument
	variable showHiddenVar
	variable Priv

	# This proc may be called within an idle handler. Make sure that the
	# window has not been destroyed before this proc is called
	if {![winfo exists $w]} { return }
	set class [winfo class $w]
	if {($class ne "FileDialog") && ($class ne "ChooseDir")} { return }

	set dataName [winfo name $w]
	upvar [namespace current]::$dataName data
	unset -nocomplain data(updateId)

	set appPWD [pwd]
	if {[catch {
		cd $data(selectPath)
	}]} {
		# We cannot change directory to $data(selectPath). $data(selectPath)
		# should have been checked before Update is called, so
		# we normally won't come to here. Anyways, give an error and abort
		# action.
		CannotChangeDir $w $data(selectPath)
		cd $appPWD
		return
	}

	# Turn on the busy cursor. BUG?? We haven't disabled X events, though,
	# so the user may still click and cause havoc ...

	set entCursor [$data(ent) cget -cursor]
	set dlgCursor [$w cget -cursor]
	$data(ent) configure -cursor watch
	$w configure -cursor watch
	update idletasks

	::tk::IconList_DeleteAll $data(selection)
	set showHidden $showHiddenVar

	# Make the dir list
	# Using -directory [pwd] is better in some VFS cases.
	set cmd [list glob -tails -directory [pwd] -type d -nocomplain *]
	if {$showHidden} { lappend cmd .* }
	set dirs [lsort -dictionary -unique [eval $cmd]]
	set dirlist {}
	foreach d $dirs {
		if {$d eq "." || $d eq ".."} {
			continue
		}
		lappend dirlist $d
	}
	::tk::IconList_Add $data(selection) $IconFolder $dirlist

	if {$class eq "FileDialog"} {
		# Make the file list if this is a File Dialog, selecting all
		# but 'd'irectory type files.
	
		set cmd [list glob -tails -directory [pwd] -type {f b c l p s} -nocomplain]
		if {$data(filter) eq "*"} {
			lappend cmd *
			if {$showHidden} {
				lappend cmd .*
			}
		} else {
			eval [list lappend cmd] $data(filter)
		}
		set fileList [lsort -dictionary -unique [eval $cmd]]

		foreach file $fileList {
			set extension [file extension $file]
			
			if {[info exists Priv(icon:$extension)]} {
				set icon $Priv(icon:$extension)
			} else {
				set icon $IconDocument
			}

			::tk::IconList_Add $data(selection) $icon [list $file]
		}
	}

	::tk::IconList_Arrange $data(selection)

	# Update the Directory: option menu

	set list ""
	set dir ""
	foreach subdir [file split $data(selectPath)] {
		set dir [file join $dir $subdir]
		lappend list $dir
	}

	$data(dirMenu) delete 0 end
	set var [format %s(selectPath) [namespace current]::$dataName]
	foreach path $list {
		$data(dirMenu) add command -label $path -command [list set $var $path]
	}

	# Restore the PWD to the application's PWD

	cd $appPWD

	# turn off the busy cursor.
	$data(ent) configure -cursor $entCursor
	$w configure -cursor $dlgCursor
}


proc SetPathSilently {w path} {
    upvar [namespace current]::[winfo name $w] data

    trace remove variable data(selectPath) write [list [namespace current]::SetPath $w]
    set data(selectPath) $path
    trace add variable data(selectPath) write [list [namespace current]::SetPath $w]
}


proc SetPath {w {name1 ""} {name2 ""} {op ""}} {
	if {[winfo exists $w]} {
		upvar [namespace current]::[winfo name $w] data
		UpdateWhenIdle $w
		# On directory dialogs, we keep the entry in sync with the currentdir.
		if {[winfo class $w] eq "ChooseDir"} {
			$data(ent) delete 0 end
			$data(ent) insert end $data(selectPath)
		}
	}
}


proc SetFilter {w type} {
	upvar [namespace current]::[winfo name $w] data
	upvar ::tk::$data(selection) icons

	set data(filterType) $type
	set data(filter) [lindex $type 1]
	$data(typeMenuBtn) configure -text [lindex $type 0] ;#-indicatoron 1

	# If we aren't using a default extension, use the one suppled
	# by the filter.
	if {![info exists data(extUsed)]} {
		if {[string length $data(-defaultextension)]} {
			set data(extUsed) 1
		} else {
			set data(extUsed) 0
		}
	}

	if {!$data(extUsed)} {
		# Get the first extension in the list that matches {^\*\.\w+$}
		# and remove all * from the filter.
		set index [lsearch -regexp $data(filter) {^\*\.\w+$}]
		if {$index >= 0} {
			set data(-defaultextension) \
			[string trimleft [lindex $data(filter) $index] "*"]
		} else {
			# Couldn't find anything!  Reset to a safe default...
			set data(-defaultextension) ""
		}
	}

	$icons(sbar) set 0.0 0.0

	UpdateWhenIdle $w
}


proc ResolveFile {context text defaultext {expandEnv 1}} {
	set appPWD [pwd]

	set path [JoinFile $context $text]

	# If the file has no extension, append the default.  Be careful not
	# to do this for directories, otherwise typing a dirname in the box
	# will give back "dirname.extension" instead of trying to change dir.
	if {![file isdirectory $path] && ([file ext $path] eq "") && ![string match {$*} [file tail $path]]} {
		set path "$path$defaultext"
	}

	if {[catch {file exists $path}]} {
		# This "if" block can be safely removed if the following code
		# stop generating errors.
		#
		#	file exists ~nonsuchuser

		return [list ERROR $path ""]
	}

	if {[file exists $path]} {
		if {[file isdirectory $path]} {
			if {[catch {cd $path}]} {
				return [list CHDIR $path ""]
			}
			set directory [pwd]
			set file ""
			set flag OK
			cd $appPWD
		} else {
			if {[catch {cd [file dirname $path]}]} {
				return [list CHDIR [file dirname $path] ""]
			}
			set directory [pwd]
			set file [file tail $path]
			set flag OK
			cd $appPWD
		}
	} else {
		set dirname [file dirname $path]
		if {[file exists $dirname]} {
			if {[catch {cd $dirname}]} {
				return [list CHDIR $dirname ""]
			}
			set directory [pwd]
			cd $appPWD
			set file [file tail $path]
			# It's nothing else, so check to see if it is an env-reference
			if {$expandEnv && [string match {$*} $file]} {
				set var [string range $file 1 end]
				if {[info exist ::env($var)]} {
					return [ResolveFile $context $::env($var) $defaultext 0]
				}
			}
			if {[regexp {[*?]} $file]} {
				set flag PATTERN
			} else {
				set flag FILE
			}
		} else {
			set directory $dirname
			set file [file tail $path]
			set flag PATH
			# It's nothing else, so check to see if it is an env-reference
			if {$expandEnv && [string match {$*} $file]} {
				set var [string range $file 1 end]
				if {[info exist ::env($var)]} {
					return [ResolveFile $context $::env($var) $defaultext 0]
				}
			}
		}
	}

	return [list $flag $directory $file]
}


proc EntFocusIn {w} {
	upvar [namespace current]::[winfo name $w] data

	if {[$data(ent) get] ne ""} {
		$data(ent) selection range 0 end
		$data(ent) icursor end
	} else {
		$data(ent) selection clear
	}
}


proc EntFocusOut {w} {
	upvar [namespace current]::[winfo name $w] data
	$data(ent) selection clear
}


proc ActivateEnt {w} {
	upvar [namespace current]::[winfo name $w] data

	set text [$data(ent) get]

	if {$data(-multiple)} {
		foreach t $text {
			VerifyFileName $w $t
		}
	} elseif {[llength $text]} {
		VerifyFileName $w $text
	}
}


proc CannotChangeDir {w path} {
	if {[file isdirectory $path]} {
		set message [Tr CannotChangeDir $path]
	} else {
		set message [Tr DirectoryRemoved $path]
	}
	messageBox -type ok -parent $w -icon warning -message $message
}


proc VerifyFileName {w filename} {
	upvar [namespace current]::[winfo name $w] data

	set list [ResolveFile $data(selectPath) $filename $data(-defaultextension)]
	lassign $list flag path file

	switch -- $flag {
		OK {
			SetPathSilently $w $path
			if {$data(-multiple)} {
				lappend data(selectFile) $file
			} else {
				set data(selectFile) $file
			}
			Done $w
		}
		PATTERN {
			set data(selectPath) $path
			set data(filter) $file
		}
		FILE {
			if {$data(type) eq "save"} {
				SetPathSilently $w $path
				if {$data(-multiple)} {
					lappend data(selectFile) $file
				} else {
					set data(selectFile) $file
				}
				Done $w
			} else {
				messageBox \
					-icon warning \
					-type ok \
					-parent $w \
					-message [Tr FileDoesNotExist [file join $path $file]]
				$data(ent) selection range 0 end
				$data(ent) icursor end
			}
		}
		PATH {
			messageBox \
				-icon warning \
				-type ok \
				-parent $w \
				-message [Tr DirDoesNotExist $path]
			$data(ent) selection range 0 end
			$data(ent) icursor end
		}
		CHDIR {
			CannotChangeDir $w $path
			$data(ent) selection range 0 end
			$data(ent) icursor end
		}
		ERROR {
			messageBox \
				-type ok \
				-parent $w \
				-icon warning \
				-message [Tr InvalidFilename $path]
			$data(ent) selection range 0 end
			$data(ent) icursor end
		}
	}
}


proc InvokeBtn {w key} {
	upvar [namespace current]::[winfo name $w] data

	if {[$data(okBtn) cget -text] eq $key} {
		$data(okBtn) invoke
	}
}


proc UpDirCmd {w} {
	upvar [namespace current]::[winfo name $w] data

	if {$data(selectPath) ne "/"} {
		set data(selectPath) [file dirname $data(selectPath)]
	}
}


proc JoinFile {path file} {
	if {[string match {~*} $file] && [file exists $path/$file]} {
		return [file join $path ./$file]
	} else {
		return [file join $path $file]
	}
}


proc FinishOk {w} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	if {[llength $data(-ok)] && [info exists Priv(selectFilePath)] && $Priv(selectFilePath) ne ""} {
		eval $data(-ok) [list $Priv(selectFilePath)]
	}
}


proc OkCmd {w} {
	upvar [namespace current]::[winfo name $w] data

	if {$data(type) eq "dir"} {
		# This is the brains behind selecting non-existant directories.  Here's
		# the flowchart:
		# 1.  If the icon list has a selection, join it with the current dir,
		#     and return that value.
		# 1a. If the icon list does not have a selection ...
		# 2.  If the entry is empty, do nothing.
		# 3.  If the entry contains an invalid directory, then...
		# 3a.   If the value is the same as last time through here, end dialog.
		# 3b.   If the value is different than last time, save it and return.
		# 4.  If entry contains a valid directory, then...
		# 4a.   If the value is the same as the current directory, end dialog.
		# 4b.   If the value is different from the current directory, change to
		#       that directory.

		set selection [tk::IconList_CurSelection $data(selection)]

		if {[llength $selection] != 0} {
			set iconText [tk::IconList_Get $data(selection) [lindex $selection 0]]
			set iconText [file join $data(selectPath) $iconText]
			ChooseDir $w $iconText
		} else {
			set text [$data(ent) get]
			if {$text eq ""} { return  }
			set text [file join {*}[file split [string trim $text]]]

			if {![file exists $text] || ![file isdirectory $text]} {
				# Entry contains an invalid directory.
				set reply [messageBox \
								-icon question \
								-type yesno \
								-parent $w \
								-message [Tr InvalidDirectory $text]]
				if {$reply eq "yes"} {
					ChooseDir $w $text
				}
			} else {
				# Entry contains a valid directory.  If it is the same as the
				# current directory, end the dialog.  Otherwise, change to that
				# directory.
				if {$text eq $data(selectPath)} {
					ChooseDir $w $text
				} else {
					set data(selectPath) $text
				}
			}
		}
	} else {
		set filenames {}
		foreach item [::tk::IconList_CurSelection $data(selection)] {
			lappend filenames [::tk::IconList_Get $data(selection) $item]
		}

		if {	([llength $filenames] == 1 && !$data(-multiple))
			|| ($data(-multiple) && ([llength $filenames] > 0))} {

			set filename [lindex $filenames 0]
			set file [JoinFile $data(selectPath) $filename]
			if {[file isdirectory $file]} {
				ListInvoke $w [list $filename]
				return
			}
		}

		ActivateEnt $w
	}
}


proc IsOK? {w text} {
	upvar [namespace current]::[winfo name $w] data

	set ok [file isdirectory $text]
	$data(okBtn) configure -state [expr {$ok ? "normal" : "disabled"}]

	# always return 1
	return 1
}


proc CancelCmd {w} {
	upvar [namespace current]::[winfo name $w] data

	if {[llength $data(-cancel)]} {
		eval $data(-cancel)
	} else {
		variable Priv

		bind $data(okBtn) <Destroy> {}
		set Priv(selectFilePath) ""
	}
}


proc Destroyed {w} {
	upvar [namespace current]::[winfo name $w] data
	variable Priv

	set Priv(selectFilePath) ""
	after cancel $Priv(afterId)
	set Priv(afterId) {}
}


proc ListBrowse {w} {
	variable Priv
	upvar [namespace current]::[winfo name $w] data

	if {![$data(addBtn) instate {pressed}]} {
		$data(addBtn) configure -state disabled
		tooltip clear $data(addBtn)
	}

	set text {}
	foreach item [::tk::IconList_CurSelection $data(selection)] {
		lappend text [::tk::IconList_Get $data(selection) $item]
	}
	if {[llength $text]} {
		if {$data(-multiple)} {
			set newtext {}
			foreach file $text {
				set fullfile [JoinFile $data(selectPath) $file]
				if {![file isdirectory $fullfile]} {
					lappend newtext $file
				}
			}
			set text $newtext
			set isDir 0
		} else {
			set text [lindex $text 0]
			set file [JoinFile $data(selectPath) $text]
			set isDir [file isdirectory $file]
		}

		if {!$isDir} {
			$data(ent) delete 0 end
			$data(ent) insert 0 $text
			set data(mode) "file"
		} else {
			set dir [JoinFile $data(selectPath) $text]
			set data(index) [lsearch -exact -index 1 $Priv(bookmarks) $dir]
			if {$data(index) == -1} {
				$data(addBtn) configure -state normal
				tooltip $data(addBtn) [Tr AddFolder $text]
				set data(dir) $dir
			}
			if {[winfo class $w] eq "FileDialog"} {
				set data(chdir) $text
			}
		}
	}

	if {[$data(addBtn) cget -state] eq "disabled" && [focus] eq $data(addBtn)} {
		focus [tk_focusPrev $data(addBtn)]
	}
}


proc ListInvoke {w filenames} {
	upvar [namespace current]::[winfo name $w] data

	$data(addBtn) configure -state disabled
	tooltip clear $data(addBtn)
	if {[llength $filenames] == 0} {
		return
	}

	set file [JoinFile $data(selectPath) [lindex $filenames 0]]
	set class [winfo class $w]

	if {$class eq "ChooseDir" || [file isdirectory $file]} {
		set appPWD [pwd]
		if {[catch {cd $file}]} {
			CannotChangeDir $w $file
		} else {
			cd $appPWD
			set data(selectPath) $file
		}
	} else {
	if {$data(-multiple)} {
			set data(selectFile) $filenames
		} else {
			set data(selectFile) $file
		}
		Done $w
	}
}


proc Done {w {selectFilePath ""}} {
	upvar [namespace current]::[winfo name $w] data
	variable Priv

	if {$selectFilePath eq ""} {
		if {$data(-multiple)} {
			set selectFilePath {}
			foreach f $data(selectFile) {
				if {$data(type) eq "dir" || [llength $f]} {
					lappend selectFilePath [JoinFile $data(selectPath) $f]
				}
			}
		} else {
			set selectFilePath [JoinFile $data(selectPath) $data(selectFile)]
		}

		if {[llength $selectFilePath] == 0} { return }

		set Priv(selectFile) $data(selectFile)
		set Priv(selectPath) $data(selectPath)

		if {($data(type) ne "dir")} {
			# XXX: not sufficient! e.g. "*.pgn.gz"
			set extension [file extension $selectFilePath]
			if {$data(type) eq "save" && [llength $extension] && [llength $data(-filetypes)]} {
				set found 0
				if {[llength $extension]} {
					foreach types $data(-filetypes) {
						foreach type [lindex $types 1] {
							set ext [file extension $type]
							if {$ext eq $extension} {
								set found 1
							}
						}
					}
				}
				if {!$found} {
					messageBox \
						-icon error \
						-type ok \
						-parent $w \
						-message [format [Tr InvalidFileExt] $extension] \
						;
					return
				}
			}
			if {[file exists $selectFilePath]} {
				if {[file isdirectory $selectFilePath]} { return }
				if {$data(type) eq "save"} {
					set reply [messageBox \
						-icon warning \
						-type yesno \
						-parent $w \
						-message [Tr FileAlreadyExists $selectFilePath]]
					if {$reply eq "no"} { return }
				}
			} elseif {$data(type) eq "save"} {
				if {[llength $data(-verifycmd)]} {
					set selectFilePath [eval $data(-verifycmd) $w $selectFilePath]
				}
				if {![llength $selectFilePath]} { return }
				if {[file exists $selectFilePath]} {
					if {[file isdirectory $selectFilePath]} { return }
					set reply [messageBox \
						-icon warning \
						-type yesno \
						-parent $w \
						-message [Tr FileAlreadyExists $selectFilePath]]
					if {$reply eq "no"} { return }
				}
			}
		}

		if {	[info exists data(-typevariable)]
			&& $data(-typevariable) ne ""
			&& [info exists data(-filetypes)] && [llength $data(-filetypes)]
			&& [info exists data(filterType)] && $data(filterType) ne ""} {

			upvar 4 $data(-typevariable) initialTypeName
			set initialTypeName [lindex $data(filterType) 0]
		}
	}

	bind $data(okBtn) <Destroy> {}
	set Priv(selectFilePath) $selectFilePath
	FinishOk $w
}


proc ChooseDir {w {selectFilePath ""}} {
	upvar [namespace current]::[winfo name $w] data
	variable Priv

	if {$selectFilePath eq ""} {
		set selectFilePath $data(selectPath)
	}

	if {!$data(-mustexist) || [file isdirectory $selectFilePath]} {
		set Priv(selectFilePath) $selectFilePath
	}
}


proc CompleteEnt {w} {
	upvar [namespace current]::[winfo name $w] data
	variable showHiddenVar

	set f [$data(ent) get]
	if {$data(-multiple)} {
		if {[catch {llength $f} len] || $len != 1} {
			return -code break
		}
		set f [lindex $f 0]
	}

	# Get list of matching filenames and dirnames
	set globF [list glob -tails -directory $data(selectPath) -type {f b c l p s} -nocomplain]
	set globD [list glob -tails -directory $data(selectPath) -type d -nocomplain *]

	if {$data(filter) eq "*"} {
		lappend globF *
		if {$showHiddenVar} {
			lappend globF .*
			lappend globD .*
		}
		if {[winfo class $w] eq "FileDialog"} {
			set files [lsort -dictionary -unique [{*}$globF]]
		} else {
			set files {}
		}
		set dirs [lsort -dictionary -unique [{*}$globD]]
	} else {
		if {$showHiddenVar} {
			lappend globD .*
		}
		if {[winfo class $w] eq "FileDialog"} {
			set files [lsort -dictionary -unique [{*}$globF {*}$data(filter)]]
		} else {
			set files {}
		}
		set dirs [lsort -dictionary -unique [{*}$globD]]
	}

	# Filter specials
	set dirs [lsearch -all -not -exact -inline $dirs .]
	set dirs [lsearch -all -not -exact -inline $dirs ..]
	set dirs2 {}
	foreach d $dirs {lappend dirs2 $d/}
	set targets [concat [lsearch -glob -all -inline $files $f*] [lsearch -glob -all -inline $dirs2 $f*]]

	if {[llength $targets] == 1} {
		# We have a winner!
		set f [lindex $targets 0]
	} elseif {$f in $targets || [llength $targets] == 0} {
		if {[string length $f] > 0} {
			bell
		}
		return
	} elseif {[llength $targets] > 1} {
		# Multiple possibles
		if {[string length $f] == 0} {
			return
		}
		set t0 [lindex $targets 0]
		for {set len [string length $t0]} {$len>0} {} {
			set allmatch 1
			foreach s $targets {
				if {![string equal -length $len $s $t0]} {
					set allmatch 0
					break
				}
			}
			incr len -1
			if {$allmatch} break
		}
		set f [string range $t0 0 $len]
	}

	if {$data(-multiple)} {
		set f [list $f]
	}
	$data(ent) delete 0 end
	$data(ent) insert 0 $f
	return -code break
}


proc FilterArgs {args} {
	set opts {}
	foreach {name value} $args {
		switch -- $name {
			-defaultextension - \
			-filetypes - \
			-initialdir - \
			-initialfile - \
			-multiple - \
			-mustexist - \
			-newdir - \
			-parent - \
			-title - \
			-typevariable { lappend opts $name $value }
		}
	}
	return $opts
}

# 16x16 Icons ######################################
set IconFolderNew [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABcUlEQVQ4y6WTu0oDQRSGvzHb
	CpJ3EFN5yVuIlfoMViKmsNNGUEGwkRQ2+gB2pkrjC9gYFQ2CnZdCwd1g3MzeJsdiNm42UVH8
	YTgz55z5z5l/ZhQpymt3goACRClAADjfG88WGVRuNVNpih8b8UOT2XTMVJoCiLglEbckg2TO
	9MqV1LcnaEd93PJpmBy9ozFQfnrlUhTQqE4pBxPRjhnC+FiB73BRnepNxZEkohV8nShu6Uef
	Kt7iiIlw0/YLgEntb+FI19gOFGxsXeelLt4OVe73WQIT0wphd+ec2fky+wtp5MhkSU6+p+Vj
	G6ufNHAkCfECMGHEkwuLh72SoNTwAwB49Gw8CUN7hLcQjA549vqeiGRXOtj6S5pndGBFbEeQ
	6ADP/3pzad3kXN679ZtOYDXwQ4i1z83m79Wv1c5YOtWM0E0+2f4K0+ngiEl41RAHmlrt7E8E
	SaCtZBNzB3J/FQ38tb5TiwIl+Y8ooB9WFf/FB5YUz7XQOzipAAAAAElFTkSuQmCC
}]

set IconFolder [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwY
	AAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAA
	F2+SX8VGAAAByElEQVR42mJkgAKjktv/Gf4zMDAC2f8ZwSRY/FyPKiMDHgAQQGBkWHDt/9ff
	f/9//fkXQUMxSA6fXoAAYjHIvfR/e6s6w+dfUBGo5TA36PHeZmDIvfj/PyNIjJEB7Eyo/PnJ
	+owAAcTC8PcXw+ffmCb//wdUxMTAUFPoA+EzQPgMQHEGJgg/7O+Z/wABxPL/zy+GDz/wuBFo
	VVTZFRySrAwAAcTyH+iCd1DnMwPxXxj9H0Jn1l1hqEyXZYgz40fRuuEqA0Nl3xUGgABi+f/v
	L8QFQJtqWjBtSoySBmuecBBoKCw+kIIVIICALvjN8OEnA0Nn2zkGz0AjholBmA7NX4sIXGTw
	99dvBoAAAobBT4b3QBf8/fmL4ek7BobgOQhbQMnhP2aQQMSAxJ+fPxkAAgjshU9AF/z9/oPh
	5XuoCniwI9mKnJygciA9AAEEDkRQGvgD5Lz/ikMzmhDMrL/ffjAABBA4DL4CXfD7+1eGq40M
	RIONG08ypO75zgAQQEwM//7ATSMV/P32jQEggIAu+MPw9jvQBT++g00lBfwB6gEIILB31L2n
	/3906RdqUCP7GpwR0EITyP3+OJ8RIIAY////z0AJAAgwAMOI0lA6uJJcAAAAAElFTkSuQmCC
}]

set IconDocument [image create photo -data {
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

set IconHome [image create photo -data {
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

set IconRoot [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACxUlEQVQ4y42TWUhUARSGv7s0
	izOOmk6YtkhaSdpIpWVFGRRFWU8RtEHRAkFKQUVQ0lNF9RA9VFAgtBCpFWEvIWaSZCUlZi5Z
	ljU45pIzo47TzJ25Sy8VFkl9TwcO5/85nP9I/B1hTG0BcgEr4OdfHNuXee3OpdXdxVsSr05N
	lreXX9nR4207YdSVb9TzssyHAHE8JwDLzQuFwZXzVVFXA1S90Fi/KhNN6cfQVe5X944WnWyb
	CfT9HBD/ELDF2XQRQUCQbaSlgB4dBsDQQkwQA3bABUi/CUxOkpbcOL/2xa2LG7vc7h4QYwCQ
	dR+iKQFDV+kb8OEPxlBbtr2qpDj/ITDx1wqnD+c279mc41JDPSCYqK7rZMXCBJ42dFGwZBYt
	7R4UKYOlizKJBjowdJXUFY/3AqUiIKQ4LSZNGQRAj3gpmC9xrjpIbXohB54EsSc6WZhtJjLc
	gvLNS2lF6yjQzs9dtKjXnpeTukpVhmjt8NDpjtA1dzlNm14zkiISLguAmESvT6bp7SiXy92X
	/cN6GRCRAN67o77FOY79adOnMGNGOikJfipe92Ka7eTj3Q8cyJDJy4wl1WmQnTWLedkZc25X
	ttYZ4BYBbFYhf92afGzmEGqom2fNYU64knEdf0Vpcipf+wUMQwVADXlwpQ06dmyIPQhMkACi
	KsFJCfq2uBjF2tjiY9nylcRbvGhKgMW5i5gUF6b+5WecDgXUIVo7ejh3w3/lW8hokH+cs/PI
	mcasqcnyqfrKol1ypAMDAVEygyBhsztInxbP1qPv2uJjxeZHDaEaoBJQ5TEh6uv3ajVWM7ui
	ETA0BSUcpn/AR5JD4pNn2HjVrpQAVYAC6IxNFICm45Eky86leWn2yOhHHtR+Hdxd0nw2MOL9
	cv2B997gkHYXGAGM8X4BwFWwwLovEjWk52/CFUA9oP3oRflPJMA0jsFvfAe7SSQGK+9DvwAA
	AABJRU5ErkJggg==
}]

set IconUp [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAABGdBTUEAALGPC/xhBQAAABhQ
	TFRF////AAAAAMDAAICAAP//AEBA////wP//o/QjfgAAAAF0Uk5TQDY6mfYAAAABYktHRACI
	BR1IAAAACXBIWXMAAAsQAAALEAGtI711AAAAB3RJTUUH0AkbCSwrzr6tAQAAAEdJREFUeJxj
	YEACjDCGuABUICUQwhBzMhWACCgpB0IElJRAQkABJbCQOFAALCQoKKKkLCgIUi6upAwxCJMh
	YmwMYQhClMIAAGM4CHtO68+RAAAAAElFTkSuQmCC
}]

set IconDesktop [image create photo -data {
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

} ;# namespace fsbox
} ;# namespace dialog

# vi:set ts=3 sw=3:
