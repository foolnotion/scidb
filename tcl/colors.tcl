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
# Copyright: (C) 2014-2015 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval colors {

array set Colors {
	lite:pgn,background						#ffffff
	lite:pgn,foreground:variation			#0000ee
	lite:pgn,foreground:bracket			#0000ee
	lite:pgn,foreground:numbering			#aa0acd
	lite:pgn,foreground:nag					#ee0000
	lite:pgn,foreground:nagtext			#912a2a
	lite:pgn,foreground:comment			#006300
	lite:pgn,foreground:info				#8b4513
	lite:pgn,foreground:result				#000000
	lite:pgn,foreground:illegal			#ee0000
	lite:pgn,foreground:marks				#6300c6
	lite:pgn,foreground:empty				#666666
	lite:pgn,foreground:opening			#000000
	lite:pgn,foreground:result				#000000
	lite:pgn,background:current			#ffdd76
	lite:pgn,background:nextmove			#eeff00
	lite:pgn,background:merge				#f0f0f0
	lite:pgn,hilite:comment					#7a5807
	lite:pgn,hilite:info						#b22222
	lite:pgn,hilite:move						#dce4e5

	lite:analysis,background				#ffffee
	lite:analysis,info:background			#f5f5e4
	lite:analysis,info:foreground			darkgreen
	lite:analysis,best:foreground			darkgreen
	lite:analysis,error:foreground		darkred
	lite:analysis,active:background		#f5f5e4

	lite:database,selected					#ffdd76

	lite:information,html:hover			#ebf4f5
	lite:information,html:color			white
	lite:information,html:header			yellow
	lite:information,html:link				yellow
	lite:information,html:visited			#ffb432
	lite:information,html:menu				#ffdd76
	lite:information,background:news		orange
	lite:information,background:html		#014b72

	lite:tree,background						white
	lite:tree,emphasize						linen
	lite:tree,stripes							#ebf4f5
	lite:tree,ratio:color					darkgreen
	lite:tree,score:color					darkred
	lite:tree,draws:color					darkgreen
	lite:tree,progress:color				darkred
	lite:tree,progress:finished			forestgreen

	lite:variation,background				white
	lite:variation,emphasize				linen
	lite:variation,stripes					#ebf4f5

	lite:board,modifiedForeground			white
	lite:board,modifiedBackground			brown
	lite:board,fixedBackground				#fff5d6

	lite:browser,background:header		#ebf4f5
	lite:browser,background:hilite		cornflowerblue
	lite:browser,background:modified		linen
	lite:browser,foreground:hilite		white

	lite:overview,background:normal		#ebf4f5
	lite:overview,background:modified	linen

	lite:crosstable,background				#ffffff
	lite:crosstable,highlighted			#ebf4f5
	lite:crosstable,mark						#ffdd76

	lite:export,shadow						#999999
	lite:export,text							#c0c0c0

	lite:import,background					#ebf4f5
	lite:import,background:select			#ffdd76
	lite:import,background:hilite			linen

	lite:switcher,background				#ebf4f5
	lite:switcher,selected:background	#ffdd76
	lite:switcher,normal:background		LemonChiffon
	lite:switcher,normal:foreground		black
	lite:switcher,hidden:background		#ebf4f5
	lite:switcher,hidden:foreground		black
	lite:switcher,emph:foreground			darkgreen
	lite:switcher,drop:background			LemonChiffon
	lite:switcher,prop:background			#aee239

	lite:fsbox,menu:headerbackground		#ffdd76
	lite:fsbox,menu:headerforeground		black
	lite:fsbox,drop:background				LemonChiffon
	lite:fsbox,selectionbackground		#ebf4f5
	lite:fsbox,selectionforeground		black
	lite:fsbox,inactivebackground			#f2f2f2
	lite:fsbox,inactiveforeground			black
	lite:fsbox,activebackground			#ebf4f5
	lite:fsbox,activeforeground			black

	lite:gamebar,background:normal		#d9d9d9
	lite:gamebar,foreground:normal		black
	lite:gamebar,background:selected		white
	lite:gamebar,background:emphasize	linen
	lite:gamebar,background:active		#efefef
	lite:gamebar,background:darker		#828282
	lite:gamebar,background:shadow		#e6e6e6
	lite:gamebar,background:lighter		white
	lite:gamebar,background:hilite		#ebf4f5
	lite:gamebar,foreground:hilite		black
	lite:gamebar,background:hilite2		cornflowerblue
	lite:gamebar,foreground:hilite2		white
	lite:gamebar,foreground:elo			darkblue

	lite:scrolledtable,background			white
	lite:scrolledtable,stripes				#ebf4f5
	lite:scrolledtable,highlight			#f4f4f4
	lite:scrolledtable,separatorcolor	darkgrey

	lite:tlistbox,background				white
	lite:tlistbox,foreground				black
	lite:tlistbox,selectbackground		#ffdd76
	lite:tlistbox,selectforeground		black
	lite:tlistbox,disabledbackground		#ebf4f5
	lite:tlistbox,disabledforeground		black
	lite:tlistbox,highlightbackground	darkblue
	lite:tlistbox,highlightforeground	white
	lite:tlistbox,dropbackground			#dce4e5
	lite:tlistbox,dropforeground			black

	lite:treetable,background				white
	lite:treetable,disabledforeground	#999999

	lite:help,foreground:gray				#999999
	lite:help,foreground:litegray			#696969
	lite:help,background:gray				#f5f5f5
	lite:help,background:emphasize		LightGoldenrod

	lite:table,background					white
	lite:table,foreground					black
	lite:table,selectionbackground		#ffdd76
	lite:table,selectionforeground		black
	lite:table,disabledforeground			#555555
	lite:table,labelforeground				black
	lite:table,labelbackground				#d9d9d9

	lite:fsbox,emphasizebackground		BlanchedAlmond

	lite:save,number							darkred
	lite:save,frequency						darkgreen
	lite:save,title							darkgreen
	lite:save,federation						darkblue
	lite:save,score							darkgreen
	lite:save,ratingType						darkblue
	lite:save,date								darkblue
	lite:save,eventDate						darkblue
	lite:save,eventCountry					darkblue
	lite:save,taglistOutline				gray
	lite:save,taglistBackground			LightYellow
	lite:save,taglistHighlighting			#ebf4f5
	lite:save,taglistCurrent				blue
	lite:save,matchlistBackground			#ebf4f5
	lite:save,matchlistHeaderForeground	#727272
	lite:save,matchlistHeaderBackground	#dfe7e8

	lite:encoding,selection					#ffdd76
	lite:encoding,active						#ebf4f5
	lite:encoding,normal						linen
	lite:encoding,description				#efefef

	lite:engine,selectbackground:dict	#ebf4f5
	lite:engine,selectbackground:setup	lightgray
	lite:engine,selectforeground:setup	black
	lite:engine,stripes						linen

	lite:default,disabledbackground		#ebf4f5
	lite:default,disabledforeground		black
	lite:default,foreground:gray			#999999

	lite:treetable,selected:focus			#ffdd76
	lite:treetable,selected!focus			#ffdd76
	lite:treetable,active:focus			#ebf4f5
	lite:treetable,hilite!selected		#ebf4f5

	lite:gamehistory,selected:focus		#ebf4f5
	lite:gamehistory,selected:hilite		#ebf4f5
	lite:gamehistory,selected!focus		#f2f2f2
	lite:gamehistory,hilite					#ebf4f5

	lite:playerdict,stripes					linen

	lite:varslider,background				#ffdd76
	lite:varslider,hilite					#ffc618
}
# mapped from #ebf4f5
array set Colors {
	dark:tree,stripes							#dce4e5
	dark:variation,stripes					#dce4e5
	dark:import,background					#dce4e5
	dark:browser,background:header		#dce4e5
	dark:information,hover					#dce4e5
	dark:overview,background:normal		#dce4e5
	dark:crosstable,highlighted			#dce4e5
	dark:fsbox,selectionbackground		#dce4e5
	dark:gamebar,background:hilite		#dce4e5
	dark:scrolledtable,stripes				#dce4e5
	dark:tlistbox,disabledbackground		#dce4e5
	dark:tlistbox,dropbackground			#dce4e5
	dark:save,taglistHighlighting			#dce4e5
	dark:save,matchlistBackground			#dce4e5
	dark:encoding,active						#dce4e5
	dark:engine,selectbackground:dict	#dce4e5
	dark:default,disabledbackground		#dce4e5
	dark:treetable,active:focus			#dce4e5
	dark:treetable,hilite!selected		#dce4e5
	dark:gamehistory,selected:focus		#dce4e5
	dark:gamehistory,selected:hilite		#dce4e5
	dark:gamehistory,hilite					#dce4e5
	dark:fsbox,activebackground			#dce4e5
	dark:switcher,background				#dce4e5
	dark:switcher,hidden:background		#dce4e5
}
# mapped from #dce4e5
array set Colors {
	dark:pgn,hilite:move						#cddddf
}
# mapped from #f0f0f0
array set Colors {
	dark:pgn,background:merge				#e9e9e9
}
# mapped from #efefef
array set Colors {
	dark:gamebar,background:active		#e4e4e4
	dark:encoding,description				#e4e4e4
}
# mapped from linen
array set Colors {
	dark:tree,emphasize						#ecded0
	dark:variation,emphasize				#ecded0
	dark:browser,background:modified		#ecded0
	dark:overview,background:modified	#ecded0
	dark:import,background:hilite			#ecded0
	dark:gamebar,background:emphasize	#ecded0
	dark:encoding,normal						#ecded0
	dark:playerdict,stripes					#ecded0
	lite:engine,stripes						#ecded0
}
# mapped from #ffffee
array set Colors {
	dark:analysis,info:background			#e7e7d8
	dark:analysis,active:background		#e7e7d8
}
# mapped from #dfe7e8
array set Colors {
	dark:save,matchlistHeaderBackground	#d1d8d9
}
# mapped from #999999
array set Colors {
	dark:default,foreground:gray			#777777
}

set Scheme dark

proc lookup {color} {
	variable Colors
	variable Scheme

	if {[string match theme,* $color]} {
		return [::theme::getColor [string range $color 6 end]]
	}

	if {[info exists Colors($Scheme:$color)]} { return $Colors($Scheme:$color) }
	if {[info exists Colors(lite:$color)]} { return $Colors(lite:$color) }

	return $color
}

} ;# namespace colors

# vi:set ts=3 sw=3:
