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
# Copyright: (C) 2012-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source player-card

namespace eval playercard {
namespace eval mc {

set PlayerCard					"Player Card"
set Latest						"Latest"
set Highest						"Highest"
set Minimal						"Minimal"
set Maximal						"Maximal"
set Win							"Win"
set Draw							"Draw"
set Loss							"Loss"
set Total						"Total"
set FirstGamePlayed			"First game played"
set LastGamePlayed			"Last game played"
set WhiteMostPlayed			"Most common openings as White"
set BlackMostPlayed			"Most common openings as Black"

set OpenInWebBrowser			"Open in web browser"
set OpenPlayerCard			"%s player card"
set OpenFileCard				"%s file card"
set OpenFideRatingHistory	"FIDE rating history"
set OpenWikipedia				"Wikipedia biographie"
set OpenViafCatalog			"VIAF catalog"
set OpenPndCatalog			"catalog of Deutsche Nationalbibliothek"
set OpenChessgames			"chessgames.com collection"
set SeachIn365ChessCom		"Search in 365Chess.com"

}

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::max

array set Options {
	debug:log	0
	debug:html	0

	url:fide			"http://ratings.fide.com/card.phtml?event=%id%"
	url:iccf			"http://www.iccf-webchess.com/PlayerDetails.aspx?id=%id%"
	url:uscf			"http://main.uschess.org/assets/msa_joomla/MbrDtlMain.php?%id%"
	url:dsb			"http://www.schachbund.de/dwz/db/spieler.html?zps=%id%&amp;unloadcache=1"
	url:ecf			"http://grading.bcfservices.org.uk/getref.php?ref=%id%"
	url:viaf			"http://viaf.org/viaf/%id%"
	url:pnd			"http://d-nb.info/gnd/%id%"
	url:wikipedia	"http://%lang%.wikipedia.org/wiki/%name%"
	url:chessgames	"http://chessgames.com/player/%id%.html"
	url:365Chess	"http://www.365chess.com/search_result.php?wlname=%lastname%&wname=%firstname%&open=&blname=&bname=&eco=&nocolor=on&yeari=&yeare=&sply=1&ply=&res=&submit_search=1"
}

set Counter 0
set Photo ""
array set ImageCache {}


proc show {base variant args} {
	variable Vars
	variable Options
	variable Counter

	set info [::scidb::db::playerInfo $base $variant {*}$args]
	set key [MakeKey $base $variant $info]
	if {[string length $key] == 0} { return }
	set name [lindex $info 0]

	if {[info exists Vars($key)]} {
		if {$Vars($key:open)} {
			::widget::dialogRaise $Vars($key)
		} else {
			set Vars($key:open) 1
			UpdateContent $Vars($key).content $key $base $variant $name $args
		}
		return
	}

	::widget::busyCursor on

	::scidb::db::subscribe dbInfo {} [namespace current]::Close $key
	set dlg [tk::toplevel .application.__card__[incr Counter] -class Scidb]
	set Vars($key) $dlg
	set Vars($key:open) 1
	bind $dlg <Destroy> [namespace code [list Destroy $dlg $key %W 1]]
	wm withdraw $dlg

	set css [::html::defaultCSS [::font::htmlFixedFamilies] [::font::htmlTextFamilies]]
	set dir [file join $::scidb::dir::share scripts]
	::html $dlg.content \
		-imagecmd [namespace code [list GetImage $info]] \
		-center no \
		-fittowidth yes \
		-height 600 \
		-width 800 \
		-cursor left_ptr \
		-borderwidth 1 \
		-relief sunken \
		-doublebuffer no \
		-exportselection yes \
		-importdir $dir \
		-css $css \
		-showhyphens 0 \
		-usehorzscroll no \
		-usevertscroll yes \
		-keepvertscroll yes \
		;
	bind [winfo parent [$dlg.content drawable]] <ButtonPress-3> [namespace code [list PopupMenu $key]]
	pack $dlg.content -fill both -expand yes
	bind $dlg.content <Destroy> [list array unset [namespace current]::Vars $key*]
	set id [::scidb::db::get playerKey $base $variant {*}$args]
	set updateCmd [list UpdatePlayer $dlg.content $id $key $base $variant $name $args]
	bind $dlg.content <<LanguageChanged>> [namespace code $updateCmd]
	$dlg.content onmouseover [namespace code [list MouseEnter $dlg.content $variant]]
	$dlg.content onmouseout [namespace code [list MouseLeave $dlg.content]]
	$dlg.content onmousedown3 [namespace code [list Mouse3Down $dlg.content $key $info]]
	set Vars($dlg.content:tooltip) ""

	set geometry [UpdateContent $dlg.content $key $base $variant $name $args]
	::widget::busyCursor off

	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm resizable $dlg false true
	wm geometry $dlg $geometry
	wm deiconify $dlg

	return $dlg
}


proc popupInfo {path info} {
	variable Photo

	lassign $info name fideID type sex rating _ _ country titles _ _ dateOfBirth dateOfDeath
	if {[string length $name] == 0} { return }
	if {[string index $fideID 0] eq "-"} { set fideID [string range $fideID 1 end] }

	set w $path.showinfo
	catch { destroy $w }
	set top [::util::makePopup $w]
	set bg [$top cget -background]

	set f [tk::frame $top.f -borderwidth 0 -background $bg]
	grid $f -column 3 -row 1

	lassign $rating highestRating mostRecentRating ratingType
	set highestRating [abs $highestRating]
	set mostRecentRating [max 0 $mostRecentRating]
	set dateOfBirth [::locale::formatDate $dateOfBirth]
	set dateOfDeath [::locale::formatDate $dateOfDeath]
	switch $sex {
		m			{ set sex $::genderbox::mc::Gender(m) }
		f			{ set sex $::genderbox::mc::Gender(f) }
		default	{ set sex "" }
	}
	set federation [::country::name $country]
	if {$type eq "program"} {
		set title $::genderbox::mc::Gender(c)
	} else {
		set title ""
	}
	foreach t $titles {
		if {[string length $title]} { append title "\n" }
		append title $::titlebox::mc::Title($t)
	}
	set row 1
	foreach var {	name sex dateOfBirth dateOfDeath highestRating
						mostRecentRating title federation fideID} {
		set value [set $var]
		if {[string length $value] <= 1} {
			set value "\u2013"
		} elseif {$var in {highestRating mostRecentRating} && $ratingType ne "Rating"} {
			append value " ($ratingType)"
		}
		set attr [string toupper $var 0 0]
		if {[info exists ::playertable::mc::T_$attr]} {
			set text [set ::playertable::mc::T_$attr]
		} elseif {[info exists ::playertable::mc::F_$attr]} {
			set text [set ::playertable::mc::F_$attr]
		} else {
			set text [set ::playertable::mc::$attr]
		}
		tk::label $f.lbl$row -background $bg -text "$text:"
		tk::label $f.val$row -background $bg -text $value -justify left
		grid $f.lbl$row -row $row -column 3 -sticky nw
		grid $f.val$row -row $row -column 5 -sticky w
#		grid rowconfigure $f [expr {$row + 1}] -minsize $::theme::padding
		incr row 2
	}
	grid columnconfigure $f 4 -minsize $::theme::padding
	grid columnconfigure $f {2 6} -minsize 2
	grid rowconfigure $f [list 0 [incr row -1]] -minsize 2

	set Photo [::util::photos::get $name $info]
	if {[string length $Photo]} {
		tk::frame $top.lt -background $bg -borderwidth 0
		set lbl [tk::label $top.lt.photo -background $bg -image $Photo -relief solid]
		grid $lbl -column 1 -row 1
	}

	set icon [::country::countryFlag $country]
	if {[llength $icon]} {
		if {![winfo exists $top.lt]} { tk::frame $top.lt -background $bg -borderwidth 0 }
		set lbl [tk::label $top.lt.flag -background $bg -image $icon -borderwidth 0]
		grid $lbl -column 1 -row 3 -sticky n
	}

	if {[winfo exists $top.lt]} {
		grid $top.lt -column 1 -row 1
		grid columnconfigure $top 0 -minsize 2
		grid columnconfigure $top 2 -minsize $::theme::padding
		grid rowconfigure $top {0 2} -minsize 2

		if {[winfo exists $top.lt.photo] && [winfo exists $top.lt.flag]} {
			grid rowconfigure $top.lt 2 -minsize 3
		}
	}

	::tooltip::popup $path $w cursor
}


proc popdownInfo {path} {
	variable Photo

	if {[string length $Photo]} {
		image delete $Photo
		set Photo ""
	}
	::tooltip::popdown $path.showinfo
}


proc setupPrivateCard {parent} {
	variable Var

	# Name
	# Sex
	# Birthday
	# Actual Rating
	# Title
	# Nation
	# Fide-ID (6-8 digits) / DSB-ID "<zps>-<nr>" / ECF-ID (6 digits + 1 alpha) / ICCF-ID (6 digits)
	# Photo

	set dlg $parent.setupPrivateCard
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top -fill both -expand yes

	### left frame ########################################################
	set list [::tlistbox $top.select \
		-usescroll yes \
		-padx 5 \
		-pady 7 \
		-selectmode browse \
	]

	### right frame #######################################################
	set f [ttk::frame $top.data -borderwidth 0 -takefocus 0]

	ttk::label		$f.lname -textvar ::engine::mc::Name
	ttk::entry		$f.ename -textvar [namespace current]::Var(Name)
	ttk::label		$f.lsex -textvar ::playertable::mc::T_Sex
	::genderbox		$f.bsex -textvar [namespace current]::Var(Sex)
	ttk::label		$f.lbirthday -textvar ::playertable::mc::DateOfBirth
	::datebox		$f.bbirthday
	ttk::label		$f.lnation -textvar ::playertable::mc::T_Federation
	::countrybox	$f.bnation -textvar [namespace current]::Var(Nation)

	ttk::label		$f.lrating1 -textvar [::mc::var ::engine::mc::Rating " 1"]
	::ratingbox		$f.brating1 -textvar [namespace current]::Var(Rating1) -format all
	ttk::spinbox	$f.escore1 -textvar [namespace current]::Var(Score1) -width 5 -from 0 -to 4000
	ttk::label		$f.lrating2 -textvar [::mc::var ::engine::mc::Rating " 2"]
	::ratingbox		$f.brating2 -textvar [namespace current]::Var(Rating2) -format all
	ttk::spinbox	$f.escore2 -textvar [namespace current]::Var(Score2) -width 5 -from 0 -to 4000
	ttk::label		$f.lrating3 -textvar [::mc::var ::engine::mc::Rating " 3"]
	::ratingbox		$f.brating3 -textvar [namespace current]::Var(Rating3) -format all
	ttk::spinbox	$f.escore3 -textvar [namespace current]::Var(Score3) -width 5 -from 0 -to 4000

	ttk::label		$f.ltitle1 -textvar [::mc::var ::playertable::mc::F_Title " 1"]
	::titlebox		$f.btitle1 -textvar [namespace current]::Var(Title1)
	ttk::label		$f.ltitle2 -textvar [::mc::var ::playertable::mc::F_Title " 2"]
	::titlebox		$f.btitle2 -textvar [namespace current]::Var(Title2)
	ttk::label		$f.ltitle3 -textvar [::mc::var ::playertable::mc::F_Title " 3"]
	::titlebox		$f.btitle3 -textvar [namespace current]::Var(Title3)

	ttk::label		$f.lfide -textvar ::playertable::mc::F_FideID
	ttk::entry		$f.efide -textvar [namespace current]::Var(FideID)
	ttk::label		$f.ldsb -text "DSB-ID"
	ttk::entry		$f.edsb -textvar [namespace current]::Var(DsbID)
	ttk::label		$f.lecf -text "ECF-ID"
	ttk::entry		$f.eecf -textvar [namespace current]::Var(EcfID)
	ttk::label		$f.liccf -text "ICCF-ID"
	ttk::entry		$f.eiccf -textvar [namespace current]::Var(IccfID)
	ttk::label		$f.luscf -text "USCF-ID"
	ttk::entry		$f.euscf -textvar [namespace current]::Var(UscfID)

	### Geometry ##########################################################
	grid $top.select -row 1 -column 1 -sticky ns
	grid $top.data   -row 1 -column 3 -sticky nsew

	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid rowconfigure $top {0 2} -minsize $::theme::pady

	grid $f.lname		-row  1 -column 1 -sticky w
	grid $f.ename		-row  1 -column 3 -sticky we -columnspan 3
	grid $f.lsex		-row  3 -column 1 -sticky w
	grid $f.bsex		-row  3 -column 3 -sticky w -columnspan 3
	grid $f.lbirthday	-row  5 -column 1 -sticky w
	grid $f.bbirthday	-row  5 -column 3 -sticky w -columnspan 3
	grid $f.lnation	-row  7 -column 1 -sticky w
	grid $f.bnation	-row  7 -column 3 -sticky we -columnspan 3

	grid $f.lrating1	-row  9 -column 1 -sticky w
	grid $f.brating1	-row  9 -column 3 -sticky w
	grid $f.escore1	-row  9 -column 5 -sticky w
	grid $f.lrating2	-row 11 -column 1 -sticky w
	grid $f.brating2	-row 11 -column 3 -sticky w
	grid $f.escore2	-row 11 -column 5 -sticky w
	grid $f.lrating3	-row 13 -column 1 -sticky w
	grid $f.brating3	-row 13 -column 3 -sticky w
	grid $f.escore3	-row 13 -column 5 -sticky w

	grid $f.ltitle1	-row 15 -column 1 -sticky w
	grid $f.btitle1	-row 15 -column 3 -sticky we -columnspan 3
	grid $f.ltitle2	-row 17 -column 1 -sticky w
	grid $f.btitle2	-row 17 -column 3 -sticky we -columnspan 3
	grid $f.ltitle3	-row 19 -column 1 -sticky w
	grid $f.btitle3	-row 19 -column 3 -sticky we -columnspan 3

	grid $f.lfide		-row 21 -column 1 -sticky w
	grid $f.efide		-row 21 -column 3 -sticky w -columnspan 3
	grid $f.ldsb		-row 23 -column 1 -sticky w
	grid $f.edsb		-row 23 -column 3 -sticky w -columnspan 3
	grid $f.lecf		-row 25 -column 1 -sticky w
	grid $f.eecf		-row 25 -column 3 -sticky w -columnspan 3
	grid $f.liccf		-row 27 -column 1 -sticky w
	grid $f.eiccf		-row 27 -column 3 -sticky w -columnspan 3
	grid $f.luscf		-row 29 -column 1 -sticky w
	grid $f.euscf		-row 29 -column 3 -sticky w -columnspan 3

	grid columnconfigure $f {2 4} -minsize $::theme::padx
	grid columnconfigure $f {5} -weight 1
	grid rowconfigure $f {2 4 6 10 12 16 18 22 24 26 28} -minsize $::theme::pady
	grid rowconfigure $f {8 14 20} -minsize $::theme::padY

	### Buttons ###########################################################
	::widget::dialogButtons $dlg {new save delete close help} -default close
	$dlg.delete configure -command [namespace code [list DeletePlayer $list]]
	$dlg.save configure -command [namespace code [list SavePlayer $list]] -state disabled
	$dlg.new configure -command [namespace code [list NewPlayer $list]]
	$dlg.close configure -command [namespace code [list CloseSetup $list]]

	### Popup #############################################################
	wm protocol $dlg WM_DELETE_WINDOW [$dlg.close cget -command]
	wm minsize $dlg [winfo reqwidth $dlg] [winfo reqheight $dlg]
	wm resizable $dlg true false
	wm title $dlg [::mc::stripAmpersand $::menu::mc::PrivatePlayerCard]
	wm transient $dlg [winfo toplevel $parent]
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $list
	update idletasks
	wm geometry $dlg [winfo width $dlg]x[winfo height $dlg]
}


proc buildWebMenu {parent m info} {
	variable Options

	set fideID    [lindex $info  1]
	set dsbID     [lindex $info 13]
	set ecfID     [lindex $info 14]
	set iccfID    [lindex $info 15]
	set viafID    [lindex $info 16]
	set pndID     [lindex $info 17]
	set cgdcID    [lindex $info 18]
	set wikiLinks [lindex $info 19]

	if {[string index $fideID 0] eq "-"} { set fideID [string range $fideID 1 end] }

	set name      [::playertable::column $info lastName]
	set lastName  [string trim [lindex [split $name ,] 0]]
	set firstName [string trim [lindex [split $name ,] 1]]

	$m add command \
		-label " [format $mc::OpenPlayerCard Fide]" \
		-state [expr {[string length $fideID] ? "normal" : "disabled"}] \
		-image $icon::16x16::Fide \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $fideID] $Options(url:fide)]] \
		;
	$m add command \
		-label " [format $mc::OpenPlayerCard ICCF]" \
		-state [expr {[string length $iccfID] ? "normal" : "disabled"}] \
		-image $icon::16x16::ICCF \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $iccfID] $Options(url:iccf)]] \
		;
#	$m add command \
#		-label " [format $mc::OpenPlayerCard USCF]" \
#		-state [expr {[string length $uscfID] ? "normal" : "disabled"}] \
#		-image $icon::16x16::USCF \
#		-compound left \
#		-command [list ::web::open $parent [string map [list %id% $uscfID] $Options(url:uscf)]] \
#		;
	$m add command \
		-label " [format $mc::OpenFileCard DWZ]" \
		-state [expr {[string length $dsbID] ? "normal" : "disabled"}] \
		-image $icon::16x16::DSB \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $dsbID] $Options(url:dsb)]] \
		;
	$m add command \
		-label " [format $mc::OpenPlayerCard ECF]" \
		-state [expr {[string length $ecfID] ? "normal" : "disabled"}] \
		-image $icon::16x16::ECF \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $ecfID] $Options(url:ecf)]] \
		;
	set sub [menu $m.wiki -tearoff false]
	$m add cascade \
		-menu $sub \
		-label " $mc::OpenWikipedia" \
		-state [expr {[llength $wikiLinks] ? "normal" : "disabled"}] \
		-image $icon::16x16::Wikipedia \
		-compound left \
		;
	$m add command \
		-label " $mc::OpenViafCatalog" \
		-state [expr {[string length $viafID] ? "normal" : "disabled"}] \
		-image $icon::16x16::VIAF \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $viafID] $Options(url:viaf)]] \
		;
	$m add command \
		-label " $mc::OpenPndCatalog" \
		-state [expr {[string length $pndID] ? "normal" : "disabled"}] \
		-image $icon::16x16::PND \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $pndID] $Options(url:pnd)]] \
		;
	$m add command \
		-label " $mc::OpenChessgames" \
		-state [expr {[string length $cgdcID] ? "normal" : "disabled"}] \
		-image $icon::16x16::ChessgamesDotCom \
		-compound left \
		-command [list ::web::open $parent [string map [list %id% $cgdcID] $Options(url:chessgames)]] \
		;
	set url [string map [list %lastname% $lastName %firstname% $firstName] $Options(url:365Chess)]
	$m add command \
		-label " $mc::SeachIn365ChessCom" \
		-image $icon::16x16::365ChessCom \
		-compound left \
		-command [list ::web::open $parent $url]
		;
	
	foreach {lang name} $wikiLinks {
		set flag ""
		catch { set flag $::country::icon::flag($::mc::langToCountry($lang)) }
		if {[string length $flag] == 0} { set flag $::icon::16x16::none }
		set url [string map [list %lang% $lang %name% $name] $Options(url:wikipedia)]
		$sub add command \
			-label " [::encoding::languageName $lang]" \
			-image $flag \
			-compound left \
			-command [list ::web::open $parent $url] \
			;
	}

#	if {	[string length $fideID] == 0
#		&& [string length $iccfID] == 0
#		&& [string length $dsbID] == 0
#		&& [string length $ecfID] == 0
#		&& [llength $wikiLinks] == 0
#		&& [string length $viafID] == 0
#		&& [string length $pndID] == 0
#		&& [string length $cgdcID] == 0} {
#
#		return 0
#	}

	return 1
}


proc UpdatePlayer {w id key base variant name playerCardArgs} {
	if {[llength $playerCardArgs] == 1} {
		set pos [::scidb::db::find player $base $variant $id]
		if {$pos == -1} {
			destroy [winfo toplevel $w]
			return
		}
		set playerCardArgs $pos
	}

	UpdateContent $w $key $base $variant $name $playerCardArgs
}


proc MakeKey {base variant info} {
	lassign $info name fideID type sex _ _ _ country titles _ _ dateOfBirth _
	if {[string length $name] == 0} { return "" }
	return card:$base:$variant:$name:$fideID:$type:$sex:$country:$titles:$dateOfBirth
}


proc UpdateContent {w key base variant name playerCardArgs} {
	variable Vars
	variable Options

	if {!$Vars($key:open)} { return }

	set preamble "
		\\def\\FormatDate#date{\\%date\\%(#date)}
		\\def\\FormatFederation#code{\\%code\\%(#code)}
		\\def\\DecimalPoint{[::locale::decimalPoint]}
		\\def\\Lang{$::mc::langID}
		\\def\\Title{$mc::PlayerCard: $name}
		\\let\\Tracing\\$Options(debug:log)
		\\def\\Label-White{$::mc::White}
		\\def\\Label-Black{$::mc::Black}
		\\def\\Label-Surname{$::playertable::mc::F_LastName}
		\\def\\Label-Forename{$::playertable::mc::F_FirstName}
		\\def\\Label-Federation{$::playertable::mc::T_Federation}
		\\def\\Label-FIDE-ID{$::playertable::mc::F_FideID}
		\\def\\Label-Title{$::playertable::mc::F_Title}
		\\def\\Label-BirthDay{$::playertable::mc::DateOfBirth}
		\\def\\Label-DeathDay{$::playertable::mc::DateOfDeath}
		\\def\\Label-Latest{$mc::Latest}
		\\def\\Label-Highest{$mc::Highest}
		\\def\\Label-Minimal{$mc::Minimal}
		\\def\\Label-Maximal{$mc::Maximal}
		\\def\\Label-Win{$mc::Win}
		\\def\\Label-Draw{$mc::Draw}
		\\def\\Label-Loss{$mc::Loss}
		\\def\\Label-Total{$mc::Total}
		\\def\\Label-Score{$::crosstable::mc::Score}
		\\def\\Label-First-Game-Played{$mc::FirstGamePlayed}
		\\def\\Label-Last-Game-Played{$mc::LastGamePlayed}
		\\def\\Label-White-Most-Played{$mc::WhiteMostPlayed}
		\\def\\Label-Black-Most-Played{$mc::BlackMostPlayed}
	"
	set searchDir [file join $::scidb::dir::share scripts]
	set script "player-card.eXt"
	set result [::scidb::db::playerCard $searchDir $script $preamble $base $variant {*}$playerCardArgs]
	lassign $result html log

	set i [string first "%date%(" $html]
	while {$i >= 0} {
		set e [string first ) $html [expr {$i + 6}]]
		set date [string range $html [expr {$i + 7}] [expr {$e - 1}]]
		if {[string length $date] == 10} {
			set html [string replace $html $i $e [::locale::formatDate $date]]
		} else {
			set html [string replace $html $i $e ""]
		}
		set i [string first "%date%(" $html]
	}

	set i [string first "%code%(" $html]
	while {$i >= 0} {
		set e [string first ) $html [expr {$i + 6}]]
		set code [string range $html [expr {$i + 7}] [expr {$e - 1}]]
		if {[string length $code] == 3} {
			set html [string replace $html $i $e [::country::name $code]]
		} else {
			set html [string replace $html $i $e ""]
		}
		set i [string first "%code%(" $html]
	}

	set dlg [winfo toplevel $w]
	$w parse $html
	lassign [$w minbbox] x y x2 y2
	incr x2 -4
	incr y2 -4
	set height [expr {2*$y + $y2}]
	set width [expr {2*$x + $x2 + 15}]

	wm maxsize $dlg [expr {$width + 100}] [expr {2*$y + $y2}]
	wm minsize $dlg 1 340
	wm title $dlg "[tk appname] - $mc::PlayerCard: $name ([::util::databaseName $base])"

	set show(log) $Options(debug:log)
	set show(html) $Options(debug:html)
	if {[string length $log]} { set show(log) yes }

	foreach attr {log html} {
		set Vars(output:$attr) [set $attr]
		if {$show($attr)} {
			ShowTrace $attr $key
		} elseif {[winfo exists $dlg.$attr]} {
			destroy $dlg.$attr
		}
	}

	return ${width}x${height}
}


proc MouseEnter {w variant node} {
	variable Vars

	set titles [split [$node attribute -default {} title] ',']
	if {[string length $titles]} {
		set Vars($w:tooltip) $node
		set tip ""
		set delim ""
		foreach title $titles {
			append tip $delim
			append tip $::titlebox::mc::Title([string trim $title])
			set delim \n
		}
		Tooltip $w $tip
	}

	set eco [$node attribute -default {} eco]
	if {[string length $eco]} {
		set Vars($w:tooltip) $node
		lassign [::scidb::misc::lookup opening $eco $variant] opening shortOpening variation subVariation
		if {[string length $variation]} {
			set opening [::mc::translateEco $shortOpening]
			append opening ", "
			append opening [::mc::translateEco $variation]
			if {[string length $subVariation]} {
				append opening ", "
				append opening [::mc::translateEco $subVariation]
			}
		} else {
			set opening [::mc::translateEco $opening]
		}
		Tooltip $w $opening
	}
}


proc MouseLeave {w node {stimulate 0}} {
	variable Vars

	if {$Vars($w:tooltip) eq $node} {
		set Vars($w:tooltip) ""
		foreach attr {title eco} {
			set content [$node attribute -default {} $attr]
			if {[llength $content]} { Tooltip $w hide }
		}
	}

	if {$stimulate} {
		$w stimulate
		::tooltip::hide
	}
}


proc Mouse3Down {w key info node} {
	variable ::table::options

	if {[llength $node] > 0} { return }
	set m $w.popup_web_links
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	$m add command                                       \
		-label " $mc::OpenInWebBrowser"                   \
		-image $::icon::16x16::none                       \
		-compound left                                    \
		-background $options(menu:headerbackground)       \
		-foreground $options(menu:headerforeground)       \
		-activebackground $options(menu:headerbackground) \
		-activeforeground $options(menu:headerforeground) \
		-font $options(menu:headerfont)                   \
		;
	$m add separator
	buildWebMenu $w $m $info
	$m add separator

	set sub [menu $m.debugging]
	foreach opt {html log} {
		$sub add checkbutton \
			-label [set ::crosstable::mc::Show[string toupper $opt 0 0]] \
			-command [namespace code [list ToggleTrace $opt $key]] \
			-variable [namespace current]::Options(debug:$opt) \
			;
	}
	$m add cascade -label $::crosstable::mc::Debugging -menu $sub

	tk_popup $m {*}[winfo pointerxy $w]
}


proc Tooltip {w msg} {
	if {$msg eq "hide"} {
		::tooltip::hide yes
	} elseif {[string length $msg]} {
		::tooltip::hide no ;# XXX probably we need a fix in tooltip.tcl
		::tooltip::show $w $msg
	}
}


proc GetImage {info code} {
	lassign $info name _ species sex _ _ _ country
	set img {}

	switch -glob -- $code {
		*.png {
			variable ImageCache
			if {![info exists ImageCache($code)]} {
				set ImageCache($code) [image create photo -file $code]
			}
			set img $ImageCache($code)
		}

		flag {
			if {[llength $country]} {
				set img $::country::icon::flag($country)
			}
		}

		photo {
			set img [::util::photos::get $name $info]
			if {[string length $img] > 0} { return $img }
			if {$species eq "program"} {
				set img $icon::80x80::engine
			} elseif {$sex eq "f"} {
				set img $icon::80x80::female
			} else {
				set img $icon::80x80::male
			}
		}
	}

	if {[string length $img] == 0} { return $img }
	return [list $img [namespace code DoNothing]]
}


proc DoNothing {args} {
	# nothing to do
}


proc PopupMenu {key} {
	variable Vars

	set m $Vars($key).popup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }

	set sub [menu $m.debugging]
	foreach opt {html log} {
		$sub add checkbutton \
			-label [set mc::Show[string toupper $opt 0 0]] \
			-command [namespace code [list ToggleTrace $opt $key]] \
			-variable [namespace current]::Options(debug:$opt) \
			;
	}
	$m add cascade -label $::crosstable::mc::Debugging -menu $sub

	bind $m <<MenuUnpost>> [list $Vars($key).content stimulate]
	bind $m <<MenuUnpost>> +::tooltip::hide
	tk_popup $m {*}[winfo pointerxy $Vars($key)]
}


proc Destroy {dlg key w unsubscribe} {
	if {$w ne $dlg} { return }

	catch { destroy $dlg.html }
	catch { destroy $dlg.log }

	::scidb::db::unsubscribe dbInfo {} [namespace current]::Close $key
}


proc Close {key args} {
	set [namespace current]::Vars($key:open) 0
}


proc CloseTrace {which key} {
	variable Options
	variable Vars

	set Options(debug:$which) 0

	if {[winfo exists $Vars($key)]} {
		catch { destroy $Vars($key).$which }
	}
}


proc ShowTrace {which key} {
	variable Vars

	if {$which eq "log"} {
		set useHorzScroll 0
	} else {
		set useHorzScroll 1
	}
	set path $Vars($key).$which
	set closeCmd [namespace code [list CloseTrace $which $key]]
	::widget::showTrace $path $Vars(output:$which) $useHorzScroll $closeCmd
}


proc ToggleTrace {which key} {
	variable Options

	if {$Options(debug:$which)} {
		ShowTrace $which $key
	} else {
		CloseTrace $which $key
	}
}


namespace eval icon {
namespace eval 16x16 {

set Fide [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAADAFBMVEUiMVkmNF0nNl0oNmAn
	N14oN14pN18pOF8qOF8qOGAqOV8qOWArOV8qOl8rOmArOmEsOmAsOmEsO2EsO2ItO2IuPGIu
	PGMvPGIvPWMwPmQxP2QxP2UyP2UyQGUyQWYzQWUzQWY0QWYzQmU0QmY2RGg3RGk4RGk4Rmk5
	Rmk6SGs8Sm09Sm0/TG5ATW9DUHNFUXNGUnFGVHRIVHRHVXZIVXRJVXRKV3ZNWXhOWXhUXn9T
	YH1UYH9XYH9YYX9dZ4RhbIdibIhhbYhibYhjbYhmcotpc41rd5BweJBzfpZ6hJt+hp2AiZ2J
	kqOKk6WVm66VnKuXnq2Xnq+aoK6epbWhp7OmrLinrLqnrbyutMKwtcC2usa2vMe4vcS7v8e7
	wMm9wsjLztTMz9PQ0trQ09nR1NnR1drS1dnT1dvT19vX2d7Z2t3Z2t7a2t7c3eHd3eHc3uDc
	3uHd3uHd3uLc3+Hd3+Hd3+Pe3+He3+Tf4OHe4ePe4ebf4eTg4uTh4uXh4+Xi4+Xi5Obj5ejk
	5unn5+nl6Ono6uvq6uvq6uzq6+zq7Ovr7O3s7e/t7u/v8PLw8PDv8fHw8fLx8fLx8vTx8/T1
	9fX29vb39/f4+Pn6+vv7+vv8/f39/f7/////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////+x
	IAogAAAAAWJLR0T/pQfyxQAAAAlwSFlzAAAASAAAAEgARslrPgAAANRJREFUGNNjUEADDNgE
	5ISYxdTVRNn4ZMECisIibhFJaRPLozzkuZWBAvzW0WVTw/UcM6fVxzpzKjBIGBTPmR7JIMxo
	1TxpTq+tAIN0akdlkYOLDr9NTml1U5U2g3nfhP7+njAZJu+JrZ1dPfYMFnn5JTUp4hJMnm11
	DbX1TgwqjT0F2XGqulrmyVm57ZP1GUTsWmbMnhJiahQwadbMbnceBgUO14yKhFBLs6DEwnQv
	LpBLeZV8A31i4v2D/TTYIU6XZRXQNDQxFmSRQnhOVlJSEodvAWIQPt+YToStAAAAInpUWHRD
	b21tZW50AAB42nMuSk0sSU1RKM8syVBw9/QNAAA3nQXih332+AAAAABJRU5ErkJggg==
}]

set VIAF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAVFBMVEUAAAD/AAD/AAD/AAD/
	AAD/AAD/AAD/AAD/AAD/AAD/AAD/CAj/EBD/GBj/ISH/KSn/MTH/OTn/QkL/UlL/Wlr/Y2P/
	c3P/e3v/hIT/jIz/lJT/nJzfRPm7AAAACnRSTlMAECEpMTlKUlpr0isF6AAAAIFJREFUGBkF
	wQtiglAMALCU8ioUZR8V1N3/nksg5hxGxjRyBvHY0ueIeNwGsF458X0A1s07yE7A0qPw2gGq
	T/g6AcaOuPQCMCWiRgEozFWjCqgOpu3M+Q7ipyeqJxngqE6e+99xAcvz6MF19Q7Il+xSHUD8
	hupP3m8JZGbMOTIzwT9JowRosixU4gAAAABJRU5ErkJggg==
}]

set PND [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAMElEQVQ4y2NggAHjM/9hzJln
	GCDsmf/hYv/PGMPZZ4wRbCYGCsGoAaMGjBowWAwAAA5vDEZFz8UhAAAAAElFTkSuQmCC
}]

set Wikipedia [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAA6klEQVQoz6WRsQ3DIBBF7wAr
	VYo0cTbAtStL7l2lZwSkzEDrAdIwAyOwQwZghChDROQOY8lSoihSRAEc7/79O6CX3xf8D4gJ
	A0Qx9RINRJyVptOMQWml0dMbXV2XGSA6dlnppkUHtpe0e7AEKA139E1LgD3lgz2e0TPOQPWA
	QTzEUFDSQIeGo1TcVEBMpOFKESszhprvuHDtAiJEtqf0mCFyhCzOmzZJ9smCBUgl07LRzRwg
	YSBZc8ljZnPo2PYGQLe77a9oWBoS2MXTFjCQqANTLCcqM7yNejVKsIf04S/EtGYpvUz2p896
	AezgV2Eyd2fxAAAAAElFTkSuQmCC
}]

set ICCF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAAA
	CXBIWXMAAAsTAAALEwEAmpwYAAACt0lEQVQ4y12Rz4sUVxDHP+/165n+MTP2/GrXHfCo5pKD
	Me6SQHJJIDcJOeYWl9xzykkIIUfzA0HEPyD3kCjkICyIRCSKhuQkyK7ZFTYz2zP2bs9093a/
	fjnYoyYFRb1XFJ+q+pa4eNF8l+fsb21xLct4Y7Hg8zAkPn2a769fZ3t9nfcOD9k4fpzZmTN8
	++QJzokTfCYErmVRqs1NvlCKZ+02m1HEpb09PppMoCxZnD3LD1HEpfGYD8ZjyHPiU6eY377N
	l0kC7TaoyQSaTYznsba/z7oxlHGMmk65MBqx/fgx56WkimPkbMbHts1vUQRxDFkGUggwBhOG
	nBOCIAi4G4ZMx2NaUvKOZdFZWeGPMCR+/pzOfI4H0OsRHzvGLQkgBCJNaRoDQvBMKRZZhhVF
	+MYAsKMU6XyOzDKUEFAU/Nrr8amsC4QxCIA6CiEQWiN5zbR+VQeYJCFTov7WIKTE9PscSIm0
	LHQ9YdXvE0tJpRSlMRAEfDgacVktabWTJOxrzYZSICWfAKQpe77PZcuicl0uAOzs0B8M2PjP
	iABVRd7p8NB1uS8l6TJn2zx0XR5YFjmAetE6U/8HOA5BmnI1yxC2TQXQaDCQkmtFQZWm5EJA
	GPJoNOLKEiBqx7Zpz2a8G0VIz+NenetMp7wdReijI+4AjMc8unGDH5crGKUwy7fWUJYYpdC1
	yEZrqKpXWkmJFALrJcD3KaQEY+gWBQ3HQQ+HpEJAWdIvChq+T+U4FK+vLJe3n0z4U2uSNOX9
	6ZTBYECiNQ/ynPnBAeejiF4QcNhqvRD25dldFxwHCfw+GrGdpjRtG9Hp8MvRET+fPMlukmA3
	m9Dp8NNiwU6jAZ6H5XlIa23tq/7KCnd9n5tBwD/DIW+trnK/1eJrz2Or3eag2+XN1VXuDYd8
	s7vL390uaRCw+fQpf/0Lr1kjDHVG8/MAAAAASUVORK5CYII=
}]

set DSB [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA51BMVEUSEREWFRQjIiI0MzM7
	EA1ANxtANx1FRERKEw9OOzlOPTtPRSNQTUxRTUxRTk1RTk5STk5SUE9SUVFSUlFTUlJUU1NV
	VFRWVVVdXVxnJSBvYjZ0Jhd1Hxl4d3d+bTeEIhuIiIiOfD+ZmZmqqqqtl0y7u7u9pVPMPjLM
	zMzNPzTZSCvZSCzaOynaPyvaQCvaRizbOSzbOy/bPTHbPjLbPjPbQTXcQDPcQDTcQzfcQzjc
	RTncUEXcwGLd3d3szWbszWfszmfszmjszmnt0G3t0G7t0nPu0XHu7u759/f7+fn8+vr9+/v/
	///cr/VjAAAAAWJLR0RM928Q8wAAAL9JREFUGBk1wQsjg2AUgOFD7LisfQu5RyL3a6whHctl
	G73///dg2vMI0O5mz+9mTAgEncXe9ZsZE0LQWeqfm9EQXJBlr/ZJQ9Zccd+zD6akrud2r162
	NQZVPUTGm/nWwV5MnKCMPOR79fZs/mgjKWE2jiLky2V3LSsTTfDSVEsZu2J/Z7lkpChEqdT1
	zMLJcUu9U0Q1QtZ995RXxpSw4of55cBoCPh+8XAzMP4JhK79mF9U1ZA/AoTOZf3CKuPXD0lh
	NPjifAX2AAAAAElFTkSuQmCC
}]

set USCF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAwMD///8chckP
	AAAAAXRSTlMAQObYZgAAAAFiS0dEAmYLfGQAAABASURBVAjXYwgFAgbRsKkhDKJRS2EEiCu2
	NGoKg9SqVUuQCLFVq6YwiIaGApWsWgUlWFetCmBgDA11YGBgdGAAAOJKGAxPwtmzAAAAAElF
	TkSuQmCC
}]

set ECF [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAFVBMVEUAAAAAAIAAgIAA//+A
	gIDAwMD///+l7zIHAAAAAWJLR0QGYWa4fQAAADtJREFUCNdjYEAAtjQgSmBgCGJLMxIDMZTY
	0oLADJgUCEP56AyGVLY0ZzYUXYJsaYxYdAXBGErI2qEAACDeFlFInMaQAAAAAElFTkSuQmCC
}]

set ChessgamesDotCom [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEX///+AAAC098j+AAAA
	AXRSTlMAQObYZgAAABNJREFUCNdj4OdngKMPHxAIhzgAKl8P8bapubgAAAAASUVORK5CYII=
}]

set 365ChessCom [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAACs0lEQVQ4y42TPWxTVxTHf/e+L9uxE8dNsEJicJKGqqCi
	VlAJKJ8SBVoQC526shQGJCp16VbW7jBX6tIutFIlxAQVCIkGxEAFIYRgi8RJbMfEBn+89+69
	j4HiEAoSRzrD+frrp6NzhFKauVr765ly56TS9PAeJiX+hox3cTwb/8UuLT/f+/fDzh8I4QDY
	QvNhRhBqw6MVi3yvwnUsHtcMQ0mIuTaFmqJU18e0Co09u1A/iog5r9QtETGa7UUpja+ekx9I
	kIjH8IMa+cEEyUSc+ZVlgkjImYX6CVtp7STbReJhlUrvNgQAAs/z+HTU62J/kh8AIIqibs4P
	wh7pmCZ7Hpxl58MfSTcfEBpJodxAKY020RtuKCzVaWurK2IrmeDe8En62rM04qMYJNNVje0E
	lDvWmuUlbc1cVWOwVwVWAiFz5Sn67SIRguHaFdY3JxlK7mNj/ksQottstGax1sLXoE1EJ4yw
	s4+vWk5qiCA9zpYbP5Dfvxtn5BvsxUk6t87jf3YKA2gDSsNUJeB+NWS5pdmaDrAHh7O0lpq0
	Ags5foDi7Sf4F87g7vgKkc7SnpqGdWNdisJTzXxjlUrKjZuJ2s8wz2qIgfX4Ny9BFBH8cxkr
	Nwblwpo9JByxJrbVv9eQmRymViKcvNwtCMcFpVjwHVpPo/9uBFKeBMwqgSnPQU8KOTKBnr7d
	Lbi7jhNO38HktmKJl8NSwP5NKfJ9rxGIniTCiyN704i+NFG1gjW2BZn7CL+0yPC6Ptaay/YR
	l0I9eClgPj4QmplJTKmIe+Q0MjMAgaJy5SLtQ99Do/W/Z2oFCoCYTdP2gsaf9cr8d4nBoXjn
	13MI10F8kOXnwZ/wr3fe+ZEx/PCLXPSbUEpx687dw8XC7LfBo7ueSKUR8SRT7QxaOG8dtiyh
	d070/3Vw9+e/vwABiS7BVQ8I3wAAAABJRU5ErkJggg==
}]

} ;# namespace 16x16
namespace eval 80x80 {

set male [image create photo -data {
	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
	kvK/y6hSofVNuCwAAAAASUVORK5CYII=
}]

set female [image create photo -data {
	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
	QmCC
}]

set engine [image create photo -data {
	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
}]

} ;# namespace 80x80
} ;# namespace icon
} ;# namespace playercard

# vi:set ts=3 sw=3:
