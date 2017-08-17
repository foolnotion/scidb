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
# Copyright: (C) 2009-2017 Gregor Cramer
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
set TruetypeFonts			"Truetype fonts"
set ChessPieceDesign		"chess piece design"
set BoardThemeDesign		"Board theme design"
set FlagsDesign			"Miniature flags design"
set IconDesign				"Icon design"
set Development			"Development"
set DevelopmentOfUnCBV	"Development of unzipping CBV archives"
set Programming			"Programming"
set Head						"Head"
set AllOthers				"all others"
set TheMissingOnes		"the missing ones"

set Version					"Version"
set Distributed			"This program is distributed under the terms of the GNU General Public License."
set Inspired				"Scidb is inspired by Scid 3.6.1, copyrighted \u00A9 1999-2003 by Shane Hudson."
set SpecialThanks			"Special thanks to %s for his terrific work. His effort is the basis for this application."

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
		util::place $dlg -parent [winfo toplevel $parent] -position center
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
				<td><img src='Scidb-Logo-128'/></td>
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
			Copyright &#x00A9; 2008-2017 Gregor Cramer<br/><br/>
			[Url http://scidb.sourceforge.net]<br/><br/>
			$mc::Distributed<br/><br/>
			<font style='font-size: 10pt;'>$mc::Inspired</font>
		</font>
	"
}


proc GetImage {name} {
	variable Images

	set file [file join $::scidb::dir::images $name.png]
	if {[catch { set img [image create photo -file $file] }]} {
		set src $::help::icon::16x16::broken
		set img [image create photo -width [image width $src] -height [image height $src]]
		$img copy $src
	}
	lappend Images $img
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


proc MouseEnter {w nodes} {
	foreach node $nodes {
		set href [$node attribute -default {} href]
		if {[llength $href]} {
			$node dynamic set hover
			ttk::setCursor [$w drawable] link
		}
	}
}


proc MouseLeave {w nodes} {
	foreach node $nodes {
		set href [$node attribute -default {} href]
		if {[llength $href]} {
			$node dynamic clear hover
			ttk::setCursor [$w drawable] {}
		}
	}
}


proc Mouse1Up {w nodes} {
	foreach node $nodes {
		set href [$node attribute -default {} href]
		if {[llength $href]} {
			::web::open $w $href
			$node dynamic set visited
		}
	}
}


proc BuildContributionsFrame {w} {
	set css [::html::defaultCSS [::font::html::fixedFonts] [::font::html::textFonts]]

	append css {
		h1 {
			font-size:		110%;
			font-weight:	bold;
		}
		hr {
			border:			0;
			border-top:		solid 1px black;
			border-bottom:	transparent;
		}
		table {
			padding-top:		0.2em;
			padding-bottom:	0.5em;
		}
		div.box {
			background:			#fff8dc;
			border:				1px solid black;
			border-radius:		0.5em;
			margin-top:			1em;
			margin-bottom:		1em;
			margin-left:		0em;
			margin-right:		0em;
			padding-top:		0em;
			padding-bottom:	0em;
			padding-left:		1em;
			padding-right:		1em;
			overflow:			hidden;
		}
		:hover {
			text-decoration:	underline;
			background:			none;
		}
	}

	::html $w.t \
		-background lightgoldenrod \
		-imagecmd [namespace code GetImage] \
		-center yes \
		-fittowidth yes \
		-width 580 \
		-height 400 \
		-borderwidth 1 \
		-relief sunken \
		-doublebuffer no \
		-exportselection yes \
		-css $css \
		;
	pack $w.t

	bind [winfo toplevel $w] <FocusIn>	[list $w.t focusin]
	bind [winfo toplevel $w] <FocusOut>	[list $w.t focusout]

	$w.t handler node link [list [namespace current]::LinkHandler $w.t]
	$w.t handler node a    [namespace current]::A_NodeHandler

	$w.t onmouseover [list [namespace current]::MouseEnter $w.t]
	$w.t onmouseout  [list [namespace current]::MouseLeave $w.t]
	$w.t onmouseup1  [list [namespace current]::Mouse1Up $w.t]

	DisplayContributions $w.t
	bind $w.t <<LanguageChanged>> [namespace code [list DisplayContributions $w.t]]
}


proc DisplayContributions {w} {
	$w parse "
		<div class='box'>
			<h1>$mc::Development</h1>
			<hr/>
			<p>[Name {Gregor Cramer}]</p>
		</div>
		<div class='box'>
			<h1>$mc::DevelopmentOfUnCBV</h1>
			<hr/>
			<p>[Name {Antoni Boucher}]</p>
		</div>
		<div class='box'>
			<h1>$mc::Localization</h1>
			<hr/>
			<table border='0'>
				<tr>
					<td>[Name {Lars Ekman}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[::encoding::languageName sv]</td>
				</tr>
				<tr>
					<td>[Name {Carlos Fernando González}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[::encoding::languageName es]</td>
				</tr>
				<tr>
					<td>[Name {Giovanni Ornaghi}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[::encoding::languageName it]</td>
				</tr>
				<tr>
					<td>[Name {Zoltán Tibenszky}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[::encoding::languageName hu]</td>
				</tr>
				<tr>
					<td>[Name {Juan Carlos Vásquez}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[::encoding::languageName es]</td>
				</tr>
				<tr>
					<td>[Name {Gregor Cramer}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[::encoding::languageName de], [::encoding::languageName en]</td>
				</tr>
			</table>
		</div>
		<div class='box'>
			<h1>$mc::Testing</h1>
			<hr/>
			<table border='0'>
				<tr>
					<td>[Name {Steven Atkinson}]</td>
					<td>\u2000\u2000</td>
					<td>[Name {Lars Ekman}]</td>
					<td>\u2000\u2000</td>
					<td>[Name {Zoltán Tibenszky}]</td>
				</tr>
				<tr>
					<td>[Name {Paolo Casaschi}]</td>
					<td>\u2000\u2000</td>
					<td>[Name {José Carlos Martins}]</td>
				</tr>
				<tr>
					<td>[Name {Gregor Cramer}]</td>
					<td>\u2000\u2000</td>
					<td>[Name {Giovanni Ornaghi}]</td>
				</tr>
			</table>
		</div>
		<div class='box'>
			<h1>TrueType $mc::FontDesign</h1>
			<hr/>
			<table border='0'>
				<tr><td colspan='2'>[Name {Armando Hernández Marroquín}]</td></tr>
				<tr><td>\u2001</td><td>Adventurer, Condal, Kingdom, Leipzig, Lucena, Magnetic,
											Marroquin, Maya, Mediaeval, Merida, Motif, Usual</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Gorgonian}]</td></tr>
				<tr><td>\u2001</td><td>Aquarium (GAquarium), Bookup (GBookup), Celtic (GCeltic),
											Chess7 (GChess7), ChessCube (GChessCube), Fritz (GFritz),
											Habsburg (GHabsburg), Military (GMilitary), Old Style
											(GOldStyle), Segoe (GSegoe), Standard (GCMF),
											Zurich (GZurich)</td></tr>
				<tr><td>\u2001</td><td>[Url http://gorgonian.weebly.com/babaschess.html]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Eric Bentzen}]</td></tr>
				<tr><td>\u2001</td><td>Alpha, Berlin</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {David L. Brown}]</td></tr>
				<tr><td>\u2001</td><td>Good Companion</td></tr>
				<tr><td>\u2001</td><td>
					[Url http://www.bstephen.me.uk/downloads/8-good-companion-chess-fonts]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Alan Cowderoy}]</td></tr>
				<tr><td>\u2001</td><td>Traveller Standard</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Frank David}]</td></tr>
				<tr><td>\u2001</td><td>[Enc {Chess Olé}]</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Matthieu Leschemelle}]</td></tr>
				<tr><td>\u2001</td><td>Cases</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Christian Poisson}]</td></tr>
				<tr><td>\u2001</td><td>Phoenix</td></tr>
				<tr><td>\u2001</td><td>
					[Url http://christian.poisson.free.fr/problemesis/police.html]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Alastair Scott}]</td></tr>
				<tr><td>\u2001</td><td>Cheq</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Christoph Wirth}]</td></tr>
				<tr><td>\u2001</td><td>Smart Regular</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.enpassant.dk/chess/fonteng.htm]</td></tr>
				<tr height='7'></tr>
			</table>
		</div>
		<div class='box'>
			<h1>SVG $mc::ChessPieceDesign</h1>
			<hr/>
			<table border='0'>
				<tr><td colspan='2'>[Name {Colin M.L. Burnett}]</td></tr>
				<tr><td>\u2001</td><td>Burnett</td></tr>
				<tr><td>\u2001</td><td>[Url http://en.wikipedia.org/wiki/Chess_pieces]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Eran Karu}]</td></tr>
				<tr><td>\u2001</td><td>Free Staunton</td></tr>
				<tr><td>\u2001</td><td>
					[Url http://code.google.com/p/pychess/source/browse/pieces/freestaunton]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Maurizio Monge}]</td></tr>
				<tr><td>\u2001</td><td>Eyes, Fantasy, Skulls, Spatial</td></tr>
				<tr><td>\u2001</td><td>[Url http://poisson.phc.unipi.it/~monge/chess_art.php]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Unicode Consortium}]</td></tr>
				<tr><td>\u2001</td><td>Standard</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.fileformat.info/info/unicode]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Peter Wong}]</td></tr>
				<tr><td>\u2001</td><td>Virtual</td></tr>
				<tr><td>\u2001</td><td>[Url http://www.virtualpieces.net/diagrams]</td></tr>
				<tr height='7'></tr>
			</table>
		</div>
		<div class='box'>
			<h1>$mc::BoardThemeDesign</h1>
			<hr/>
			<table border='0'>
				<tr>
					<td>[Name {José Carlos Martins}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>Country Style</td>
				</tr>
				<tr>
					<td>[Name {Gregor Cramer}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>$mc::AllOthers</td>
				</tr>
			</table>
		</div>
		<div class='box'>
			<h1>$mc::FlagsDesign</h1>
			<hr/>
			<table border='0'>
				<tr>
					<td>[Name {Mark James}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>[Url http://www.famfamfam.com/lab/icons/flags]</td>
				</td></tr>
				<tr>
					<td>[Name {Gregor Cramer}]</td>
					<td>\u2000\u2212\u2000</td>
					<td>$mc::TheMissingOnes</td>
				</td></tr>
			</table>
		</div>
		<div class='box'>
			<h1>$mc::TruetypeFonts</h1>
			<hr/>
			<table border='0'>
				<tr><td colspan='2'>[Name {Matthew Desmond}]</td></tr>
				<tr><td>\u2001</td><td>Abel</td></tr>
				<tr><td>\u2001</td><td>[Url https://www.google.com/fonts/specimen/Abel]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Dave Gandy}]</td></tr>
				<tr><td>\u2001</td><td>Font Awesome</td></tr>
				<tr><td>\u2001</td><td>[Url http://fortawesome.github.io/Font-Awesome/]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Software Friends, Inc.}]</td></tr>
				<tr><td>\u2001</td><td>Final Frontier</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Ralph Levien}]</td></tr>
				<tr><td>\u2001</td><td>Inconsolata</td></tr>
				<tr><td>\u2001</td><td>[Url http://levien.com/type/myfonts/inconsolata.html]</td></tr>
				<tr height='7'></tr>

				<tr><td colspan='2'>[Name {Vernon Adams}]</td></tr>
				<tr><td>\u2001</td><td>Nobile</td></tr>
				<tr><td>\u2001</td><td>[Url https://www.google.com/fonts/specimen/Nobile]</td></tr>
				<tr height='7'></tr>
			</table>
		</div>
		<div class='box'>
			<h1>Scid 3</h1>
			<hr/>
			<p>
				[format $mc::SpecialThanks [Name {Shane Hudson}]]
			</p>
		</div>
	"
}


proc BuildSystemFrame {w} {
	global tcl_platform

	set padding 40
	set total [::scidb::misc::memTotal]
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
	ttk::setCursor $t standard
	set l1 [tk::label $f.l1 -image [GetOSImage Linux  ] -background lightgray]
	set l2 [tk::label $f.l2 -image [GetOSImage Windows] -background lightgray]
	set l3 [tk::label $f.l3 -image [GetOSImage Apple  ] -background lightgray]
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
	$t insert end "Total Memory:        [::locale::formatDouble [expr {$total/1048576.0}] 1] MB"
	}

	$t configure -state disabled
}


proc GetOSImage {os} {
	variable Images

	set file [file join $::scidb::dir::images OS-$os.png]
	if {[catch { set img [image create photo -file $file] }]} {
		set src $::help::icon::16x16::broken
		set img [image create photo -width [image width $src] -height [image height $src]]
		$img copy $src
	}
	lappend Images $img
	return $img
}


proc BuildLicenseFrame {w} {
	set t [tk::text $w.t \
		-height 0 \
		-font TkFixedFont \
		-yscrollcommand [list $w.s set]] \
		;
	ttk::setCursor $t standard
	set s [ttk::scrollbar $w.s -command [list $t yview]]
	pack $t -side left -fill both -expand yes
	pack $s -side left -fill both
	$t insert end [set [namespace current]::License]
	$t configure -state disabled
}


proc Url {url}		{ return "<a href='$url'>$url</a>" }
proc Enc {name}	{ return [encoding convertfrom utf-8 $name] }
proc Name {name}	{ return [Enc $name] }


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

} ;# namespace info

# vi:set ts=3 sw=3:
