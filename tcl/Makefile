# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

include ../Makefile.in

SOURCES = \
	exec.tcl \
	start.tcl \
	utils/place.tcl \
	splash.tcl \
	dialogs/messagebox.tcl \
	dialogs/progressbar.tcl \
	dialogs/choosecolor.tcl \
	dialogs/choosecolor-cube.tcl \
	dialogs/choosefont.tcl \
	dialogs/fileselectionbox.tcl \
	widgets/theme.tcl \
	widgets/misc.tcl \
	options.tcl \
	log.tcl \
	board-basic.tcl \
	load.tcl \
	fonts.tcl \
	icons.tcl \
	encoding.tcl \
	contrib/tkmenu.tcl \
	contrib/treectrl.tcl \
	contrib/filelist-bindings.tcl \
	utils/locale.tcl \
	utils/countries.tcl \
	utils/web.tcl \
	utils/xcursor.tcl \
	widgets/tooltip.tcl \
	widgets/toolbar.tcl \
	widgets/validate.tcl \
	widgets/tlistbox.tcl \
	widgets/tcombobox.tcl \
	widgets/colormenu.tcl \
	widgets/table.tcl \
	widgets/gamebar.tcl \
	widgets/scrolledtable.tcl \
	widgets/panedwindow.tcl \
	widgets/calendar.tcl \
	widgets/datebox.tcl \
	widgets/entrybox.tcl \
	widgets/roundbox.tcl \
	widgets/countrybox.tcl \
	widgets/eventmodebox.tcl \
	widgets/eventtypebox.tcl \
	widgets/timemodebox.tcl \
	widgets/titlebox.tcl \
	widgets/resultbox.tcl \
	widgets/genderbox.tcl \
	widgets/ratingbox.tcl \
	widgets/scorebox.tcl \
	widgets/terminationbox.tcl \
	widgets/ecobox.tcl \
	widgets/labelbar.tcl \
	widgets/scrolledframe.tcl \
	widgets/html.tcl \
	gametable.tcl \
	playertable.tcl \
	eventtable.tcl \
	progress.tcl \
	board-texture.tcl \
	board-pieceset.tcl \
	board-piece.tcl \
	board-square.tcl \
	board-stuff.tcl \
	board-options.tcl \
	annotation.tcl \
	comment.tcl \
	marks.tcl \
	engine.tcl \
	application.tcl \
	app-board.tcl \
	app-database.tcl \
	app-db-icons.tcl \
	app-db-annotators.tcl \
	app-db-games.tcl \
	app-db-players.tcl \
	app-db-events.tcl \
	app-pgn.tcl \
	app-tree.tcl \
	app-tree-games.tcl \
	app-variation.tcl \
	app-analysis.tcl \
	save-replace.tcl \
	export.tcl \
	import.tcl \
	browser.tcl \
	overview.tcl \
	setup-board.tcl \
	setup-position.tcl \
	crosstable.tcl \
	info.tcl \
	move.tcl \
	game.tcl \
	i18n.tcl \
	menu.tcl \
	end.tcl \

all: $(SCRIPT)

clean:
	rm -f $(SCRIPT)

depend:
	# nothing to do

install: $(SCRIPT)
	install -m 755 -d $(BINDIR)
	install -m 755 -d $(SHAREDIR)
	install -m 755 -d $(SHAREDIR)/pieces
	install -m 755 -d $(SHAREDIR)/cursor
	install -m 755 -d $(SHAREDIR)/flags
	install -m 755 -d $(SHAREDIR)/lang
	install -m 755 -d $(SHAREDIR)/lang/eco
	install -m 755 -d $(SHAREDIR)/photos
	install -m 755 -d $(SHAREDIR)/textures
	install -m 755 -d $(SHAREDIR)/themes
	install -m 755 -d $(SHAREDIR)/themes/square
	install -m 755 -d $(SHAREDIR)/themes/piece
	install -m 755 -d $(SHAREDIR)/scripts
	install -m 755 -p $(SCRIPT) $(BINDIR)
	install -m 644 -p pieces/*.tcl $(SHAREDIR)/pieces
	install -m 644 -p cursor/*.xbm $(SHAREDIR)/cursor
	install -m 644 -p cursor/*.cur $(SHAREDIR)/cursor
	install -m 644 -p cursor/*.xcur $(SHAREDIR)/cursor
	install -m 644 -p flags/*.png $(SHAREDIR)/flags
	install -m 644 -p lang/*.tcl $(SHAREDIR)/lang
	install -m 644 -p lang/eco/*.* $(SHAREDIR)/lang/eco
	install -m 644 -p photos/*.sp? $(SHAREDIR)/photos
	install -m 644 -p themes/*.dat $(SHAREDIR)/themes
	install -m 644 -p themes/piece/*.dat $(SHAREDIR)/themes/piece
	install -m 644 -p themes/square/*.dat $(SHAREDIR)/themes/square
	install -m 644 -p scripts/*.eXt $(SHAREDIR)/scripts
	for i in dark lite tile; do \
		for k in marble misc wood; do \
			install -m 755 -d $(SHAREDIR)/textures/$$i/$$k; \
			install -m 644 -p textures/$$i/$$k/* $(SHAREDIR)/textures/$$i/$$k; \
		done; \
	done
	if [ "`id -u`" -eq 0 ]; then \
		install -m 755 -d $(FONTDIR); \
		install -m 644 -p fonts/*.ttf $(FONTDIR); \
	else \
		install -m 755 -d ~/.fonts; \
		install -m 644 -p fonts/*.ttf ~/.fonts; \
	fi
	@if [ ! -z "`which fc-cache`" ]; then \
		if [ "`id -u`" -eq 0 ]; then \
			fc-cache -fv $(FONTDIR); \
		else \
			fc-cache -fv ~/.fonts; \
		fi; \
	else \
		echo "Don't know how to setup truetype fonts (fc-cache not available)."; \
		echo "Please contact your system administrator."; \
	fi

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)
	for f in `ls pieces/*.tcl`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls cursor/*.xbm`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls cursor/*.cur`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls cursor/*.xcur`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls flags/*.png`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls lang/*.tcl`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls lang/eco/*.*`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls photos/*.sp?`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls themes/*.dat`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls themes/piece/*.dat`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls themes/square/*.dat`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for f in `ls scripts/*.eXt`; do \
		rm -f $(SHAREDIR)/$$f; \
	done
	for i in dark lite tile; do \
		for k in marble misc wood; do \
			for f in `ls textures/$$i/$$k/*`; do \
				rm -f $(SHAREDIR)/$$f; \
			done; \
		done; \
	done
	# repeat 3 times (directory level is 3)
	for d in `find $(SHAREDIR) -type d -empty`; do \
		rmdir $$d; \
	done
	for d in `find $(SHAREDIR) -type d -empty`; do \
		rmdir $$d; \
	done
	for d in `find $(SHAREDIR) -type d -empty`; do \
		rmdir $$d; \
	done
	if [ ! -z "`find $(SHAREDIR) -type d -empty`" ]; then \
		rmdir $(SHAREDIR); \
	fi
	if [ "`id -u`" -eq 0 ]; then \
		for f in `ls fonts/*.ttf`; do \
			rm -f $(FONTDIR)/`basename $$f`; \
		done; \
		if [ ! -z "`which fc-cache`" ]; then \
			fc-cache -fv $(FONTDIR); \
		fi; \
		if [ "`find $(FONTDIR) -type d -empty`" = "$(FONTDIR)" ]; then \
			rmdir $(FONTDIR); \
		fi; \
	else \
		for f in `ls fonts/*.ttf`; do \
			rm -f ~/.$$f; \
		done; \
		if [ ! -z "`which fc-cache`" ]; then \
			fc-cache -fv ~/.fonts; \
		fi; \
		if [ "`find ~/.fonts -type d -empty`" = "`ls -d ~/.fonts`" ]; then \
			rmdir ~/.fonts; \
		fi; \
	fi

$(SCRIPT): $(SOURCES)
	@if [ -e $(SCRIPT) ]; then rm -f $(SCRIPT); fi
	cat $(SOURCES) | sed -e '/^##/d' -e '/^# /d' > $(SCRIPT)
	chmod 0555 $(SCRIPT)

# vi:set ts=3 sw=3:
