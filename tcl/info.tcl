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

::util::source info-dialog

catch { package require platform }

namespace eval info {
namespace eval mc {

set InfoTitle				"About %s"
set Info						"Info"
set About					"About"
set Contributions			"Contributions"
set License					"License"
set Localization			"Localization"
set Testing					"Testing"
set References				"References"
set System					"System"
set FontDesign				"chess font design"
set ChessPieceDesign		"chess piece design"
set BoardThemeDesign		"Board theme design"
set FlagsDesign			"Miniature flags design"
set IconDesign				"Icon design"
set Development			"Development"
set Programming			"Programming"
set Head						"Head"

set Version					"Version"
set Distributed			"This program is distributed under the terms of the GNU General Public License."
set Inspired				"Scidb is inspired by Scid 3.6.1, copyrighted \u00A9 1999-2003 by Shane Hudson."
set SpecialThanks			"Special thanks to Shane Hudson for his terrific work. His effort is the basis for this application."

} ;# namespace mc


proc openDialog {parent} {
	set path [winfo toplevel $parent]
	if {$path ne "."} { set path "$path." }
	set dlg ${path}infoDialog

	if {[winfo exists $dlg]} {
		::widget::dialogRaise $dlg
	} else {
		tk::toplevel $dlg -class $::scidb::app
		wm iconname $dlg ""
		wm withdraw $dlg
		BuildDialog $dlg
		wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
		wm title $dlg [format [set [namespace current]::mc::InfoTitle] $::scidb::app]
		wm resizable $dlg 0 0
#		wm transient $dlg [winfo toplevel $parent]
		util::place $dlg center [winfo toplevel $parent]
		wm deiconify $dlg
	}

	focus $dlg.top.nb
}


proc BuildDialog {dlg} {
	set top [ttk::frame $dlg.top]
	set nb [ttk::notebook $top.nb -takefocus 1]
	pack $top
	pack $nb -padx $::theme::padx -pady $::theme::pady
	set count 1

	foreach tab {About Contributions System License} {
		set f [ttk::frame $nb.tab$tab]
		Build${tab}Frame $f
		$nb add $f -sticky nsew -padding $::theme::padding
		::widget::notebookTextvarHook $nb $f [namespace current]::mc::${tab}
		incr count
	}

	widget::dialogButtons $dlg close
	$dlg.close configure -command [list destroy $dlg]
	bind $dlg <Escape> [list $dlg.close invoke]
}


proc BuildAboutFrame {w} {
	::html $w.t \
		-imagecmd [namespace code GetImage] \
		-center yes \
		-fittowidth yes \
		-width 580 \
		-height 400 \
		-borderwidth 1 \
		-relief sunken \
		-doublebuffer no \
		-exportselection yes \
		;
	pack $w.t

	bind [winfo toplevel $w] <FocusIn>	[list $w.t focusin]
	bind [winfo toplevel $w] <FocusOut>	[list $w.t focusout]

	$w.t handler node link [list [namespace current]::LinkHandler $w.t]
	$w.t handler node a    [namespace current]::A_NodeHandler

	$w.t onmouseover [list [namespace current]::MouseEnter $w.t]
	$w.t onmouseout  [list [namespace current]::MouseLeave $w.t]
	$w.t onmouseup1  [list [namespace current]::Mouse1Up $w.t]

	DisplayAbout $w.t
	bind $w.t <<LanguageChanged>> [namespace code [list DisplayAbout $w.t]]
}


proc DisplayAbout {w} {
	array set font [font actual TkTextFont]
	set fam $font(-family)

	$w parse "
		<link/>
		<table border='0' style='font-family: Final Frontier, $fam; font-size: 16pt;' color='steelblue4'>
			<tr>
				<td><img src='logo'/></td>
				<td width='30px'></td>
				<td align='center'>
					<font style='font-size: 48pt;'><font color='brown'>S</font>cidb</font><br/>
					is a
					<font color='brown'>C</font>hess
					<font color='brown'>I</font>nformation
					<font color='brown'>D</font>ata
					<font color='brown'>B</font>ase
				<td>
			</tr>
		</table>
		<br/><br/>
		<font style='font-family: $fam; font-size: 12pt;'>
			$mc::Version $::scidb::version<br/>
			Copyright &#x00A9; 2008-2012 Gregor Cramer<br/><br/>
			<a href='http://scidb.sourceforge.net'>scidb.sourceforge.net</a><br/><br/>
			$mc::Distributed<br/><br/>
			<font style='font-size: 10pt;'>$mc::Inspired</font>
		</font>
	"
}


proc GetImage {file} {
	if {$file eq "logo"} {
		set src $icon::128x128::logo
		set img [image create photo -width [image width $src] -height [image height $src]]
		$img copy $src
	}
	return $img
}


proc A_NodeHandler {node} {
	$node dynamic set link
}


proc LinkHandler {w node} {
	$w style -id user "
		:link    { color: blue2; text-decoration: none; }
		:visited { color: purple; text-decoration: none; }
		:hover   { text-decoration: underline; }
	"
}


proc MouseEnter {w node} {
	if {[llength $node] == 0} { return }
	set href [$node attribute -default {} href]
	if {[llength $href]} {
		$node dynamic set hover
		[$w drawable] configure -cursor hand2
	}
}


proc MouseLeave {w node} {
	if {[llength $node] == 0} { return }
	set href [$node attribute -default {} href]
	if {[llength $href]} {
		$node dynamic clear hover
		[$w drawable] configure -cursor {}
	}
}


proc Mouse1Up {w node} {
	if {[llength $node] == 0} { return }
	set href [$node attribute -default {} href]
	if {[llength $href]} {
		::web::open $w $href
		$node dynamic set visited
	}
}


proc Enc {s} { return [encoding convertfrom utf-8 $s] }


proc BuildContributionsFrame {w} {
	set t [tk::text $w.t \
		-padx 10 -pady 10 \
		-cursor left_ptr \
		-width 0 -height 0 \
		-wrap word \
		-font TkTextFont \
		-yscrollcommand [list ::scrolledframe::sbset $w.s] \
	]
	set s [ttk::scrollbar $w.s -command [list $t yview]]
	grid $t -row 0 -column 0 -sticky nsew
	grid $s -row 0 -column 1 -sticky ns
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 1

	set family [font configure TkTextFont -family]
	set size [font configure TkTextFont -size]
	$t tag configure caption -font [list $family $size bold]

	DisplayContributions $t
	bind $t <<LanguageChanged>> [namespace code [list DisplayContributions $t]]
}


proc DisplayContributions {t} {
	$t configure -state normal
	$t delete 1.0 end

	$t insert end [Enc "[set [namespace current]::mc::Development]:\n"] caption
	$t insert end [Enc "Gregor Cramer"]

#	$t insert end [Enc "\n\n"]
#	$t insert end [Enc "[set [namespace current]::mc::Programming]:\n"] caption
#	$t insert end [Enc "Gregor Cramer ([set [namespace current]::mc::Head]), "]
#	$t insert end [Enc "Giovanni Ornaghi"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "[set [namespace current]::mc::Localization]:\n"] caption
	$t insert end [Enc "Lars Ekman ([::encoding::languageName sv]), "]
	$t insert end [Enc "Carlos Fernando González ([::encoding::languageName es]), "]
	$t insert end [Enc "Giovanni Ornaghi ([::encoding::languageName it]), "]
	$t insert end [Enc "Zoltán Tibenszky ([::encoding::languageName hu]), "]
	$t insert end [Enc "Juan Carlos V�squez ([::encoding::languageName es]), "]
	$t insert end [Enc "Gregor Cramer ([::encoding::languageName de], [::encoding::languageName en])"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "[set [namespace current]::mc::Testing]:\n"] caption
	$t insert end [Enc "Steven Atkinson, "]
	$t insert end [Enc "Paolo Casaschi, "]
	$t insert end [Enc "Gregor Cramer, "]
	$t insert end [Enc "Lars Ekman, "]
#	$t insert end [Enc "Carlos Fernando González, "]
	$t insert end [Enc "Giovanni Ornaghi, "]
	$t insert end [Enc "Zoltán Tibenszky"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "TrueType [set [namespace current]::mc::FontDesign]:\n"] caption
	$t insert end [Enc "Armando Hernández Marroquín, "]
	$t insert end [Enc "Eric Bentzen, "]
	$t insert end [Enc "David L. Brown, "]
	$t insert end [Enc "Alan Cowderoy, "]
	$t insert end [Enc "Frank David, "]
	$t insert end [Enc "Matthieu Leschemelle, "]
	$t insert end [Enc "Christian Poisson, "]
	$t insert end [Enc "Alastair Scott, "]
	$t insert end [Enc "Christoph Wirth"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "SVG [set [namespace current]::mc::ChessPieceDesign]:\n"] caption
	$t insert end [Enc "Colin M.L. Burnett, "]
	$t insert end [Enc "Eran Karu, "]
	$t insert end [Enc "Maurizio Monge, "]
	$t insert end [Enc "Peter Wong"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "[set [namespace current]::mc::BoardThemeDesign]:\n"] caption
	$t insert end [Enc "Gregor Cramer"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "[set [namespace current]::mc::FlagsDesign]:\n"] caption
	$t insert end [Enc "Mark James, "]
	$t insert end [Enc "Gregor Cramer"]

#	$t insert end [Enc "\n\n"]
#	$t insert end [Enc "[set [namespace current]::mc::IconDesign]:\n"] caption
#	$t insert end [Enc "Gregor Cramer"]

	$t insert end [Enc "\n\n"]
	$t insert end [Enc "Scid 3:\n"] caption
	$t insert end [Enc $mc::SpecialThanks]

	$t configure -state disabled
}


proc BuildSystemFrame {w} {
	global tcl_platform

	set padding 40
	set total [::system::memTotal]
	if {$total == -1} { set total "" }
	
	set xft ""
	if {[tk windowingsystem] eq "x11"} {
		set xft (no-xft)
		catch { if {[::tk::pkgconfig get fontsystem] eq "xft"} { set xft "" } }
	}

	if {[catch {platform::identify} identity]} {
		set identity "<cannot determine identifier>"
	}

	# TODO: use a label for the first line (ensures minimum width)
	set f [tk::frame $w.f -background white -relief sunken -borderwidth 1]
	set t [tk::text $f.t \
		-cursor left_ptr \
		-width 0 -height [expr {6 + [llength $total]}] \
		-font TkFixedFont \
		-padx $padding \
		-borderwidth 0 \
	]
	set l1 [tk::label $f.l1 \
		-image [set [namespace current]::icon::64x64::LinuxIcon] \
		-background lightgray \
	]
	set l2 [tk::label $f.l2 \
		-image [set [namespace current]::icon::64x58::WindowsIcon] \
		-background lightgray \
	]
	set l3 [tk::label $f.l3 \
		-image [set [namespace current]::icon::64x74::AppleIcon] \
		-background lightgray \
	]
	pack $f -fill both -expand true
	grid $l1 -row 0 -column 0 -sticky nswe
	grid $l2 -row 1 -column 0 -sticky nswe
	grid $l3 -row 2 -column 0 -sticky nswe
	grid $t  -row 0 -column 1 -sticky we -rowspan 3
	grid columnconfigure $f 0 -minsize [expr {2*$padding + 20}]
	grid columnconfigure $f 1 -weight 1
	grid rowconfigure $f {0 1 2} -weight 1

	$t insert end "Tcl/Tk version:      [info tclversion] (pl[lindex [split [info patchlevel] .] 2]) $xft\n"
	$t insert end "Operating System:    $tcl_platform(os) $tcl_platform(osVersion)\n"
	$t insert end "OS Identifier:       $identity\n"
	$t insert end "System Architecture: $tcl_platform(machine)\n"
	$t insert end "Windowing System:    [tk windowingsystem]\n"
	$t insert end "Vendor String:       [winfo server .]"
	if {[llength $total]} {
	$t insert end "\n"
	$t insert end "Total Memory:        [format %0.1f [expr {$total/1048576.0}]] MB"
	}

	$t configure -state disabled
}


proc BuildLicenseFrame {w} {
	set t [tk::text $w.t \
		-cursor left_ptr \
		-height 0 \
		-font TkFixedFont \
		-yscrollcommand [list $w.s set]]
	set s [ttk::scrollbar $w.s -command [list $t yview]]
	pack $t -side left -fill both -expand yes
	pack $s -side left -fill both
	$t insert end [set [namespace current]::License]
	$t configure -state disabled
}


set License \
{		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
                       59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

			    Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.

		    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

		     END OF TERMS AND CONDITIONS

	    How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
convey the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this
when it starts in an interactive mode:

    Gnomovision version 69, Copyright (C) year name of author
    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, the commands you use may
be called something other than `show w' and `show c'; they could even be
mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your
school, if any, to sign a "copyright disclaimer" for the program, if
necessary.  Here is a sample; alter the names:

  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
  `Gnomovision' (which makes passes at compilers) written by James Hacker.

  <signature of Ty Coon>, 1 April 1989
  Ty Coon, President of Vice

This General Public License does not permit incorporating your program into
proprietary programs.  If your program is a subroutine library, you may
consider it more useful to permit linking proprietary applications with the
library.  If this is what you want to do, use the GNU Library General
Public License instead of this License.}


namespace eval icon {
namespace eval 64x58 {

set WindowsIcon [image create photo -data {
	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
	AAAASUVORK5CYII=
}]

} ;# namespace 64x58

namespace eval 64x74 {

set AppleIcon [image create photo -data {
	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
}]

} ;# namespace 64x74

namespace eval 64x64 {

set LinuxIcon [image create photo -data {
	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
}]

} ;# namespace 64x64

namespace eval 128x128 {

set logo [image create photo -data {
	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
	OA==
}]

} ;# namespace 128x128
} ;# namespace icon
} ;# namespace info

# vi:set ts=3 sw=3:
