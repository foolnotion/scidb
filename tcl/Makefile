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
	widgets/theme.tcl \
	widgets/misc.tcl \
	options.tcl \
	log.tcl \
	board-basic.tcl \
	load.tcl \
	fonts.tcl \
	icons.tcl \
	encoding.tcl \
	dialogs/fileselectionbox.tcl \
	dialogs/fileselectionbox.tcl \
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
	widgets/scrolledframe.tcl \
	widgets/gamebar.tcl \
	widgets/gamehistory.tcl \
	widgets/scrolledtable.tcl \
	widgets/panedwindow.tcl \
	widgets/calendar.tcl \
	widgets/datebox.tcl \
	widgets/entrybox.tcl \
	widgets/entrybuttonbox.tcl \
	widgets/roundbox.tcl \
	widgets/countrybox.tcl \
	widgets/languagebox.tcl \
	widgets/eventmodebox.tcl \
	widgets/eventtypebox.tcl \
	widgets/fideidbox.tcl \
	widgets/timemodebox.tcl \
	widgets/titlebox.tcl \
	widgets/resultbox.tcl \
	widgets/genderbox.tcl \
	widgets/ratingbox.tcl \
	widgets/scorebox.tcl \
	widgets/terminationbox.tcl \
	widgets/ecobox.tcl \
	widgets/labelbar.tcl \
	widgets/html.tcl \
	widgets/choosedir.tcl \
	widgets/fsbox.tcl \
	widgets/choosedir.tcl \
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
	help.tcl \
	info.tcl \
	move.tcl \
	game.tcl \
	i18n.tcl \
	menu.tcl \
	end.tcl \

all: $(SCRIPT)

clean:
	@echo "Clean `pwd`"
	@rm -f $(SCRIPT)

depend:
	# nothing to do

build-install-help: build-help install-help

build-help:
	@for lang in `ls -d help/[a-z][a-z]`; do           \
		(cd $$lang; if [ -a Makefile ]; then make; fi); \
	done

install-script: $(SCRIPT)
	@echo "Install $(SCRIPT)"
	@install -m 755 -d $(BINDIR)
	@install -m 755 -p $(SCRIPT) $(BINDIR)

uninstall-script:
	@echo "Uninstall $(SCRIPT)"
	@rm -f $(BINDIR)/$(SCRIPT)

install-pieces:
	@echo "Install piece sets"
	@install -m 755 -d $(SHAREDIR)/pieces
	@install -m 644 -p pieces/*.tcl $(SHAREDIR)/pieces

uninstall-pieces:
	@echo "Uninstall piece sets"
	@if [ -d $(SHAREDIR)/pieces ]; then                                                       \
		for f in `ls pieces/*.tcl`; do rm -f $(SHAREDIR)/$$f; done;                            \
		if [ "`find $(SHAREDIR)/pieces -type d -empty`" = "`ls -d $(SHAREDIR)/pieces`" ]; then \
			rmdir $(SHAREDIR)/pieces;                                                           \
		fi;                                                                                    \
	fi

install-cursors:
	@echo "Install cursors"
	@install -m 755 -d $(SHAREDIR)/cursor
	@install -m 644 -p cursor/*.xbm $(SHAREDIR)/cursor
	@install -m 644 -p cursor/*.xcur $(SHAREDIR)/cursor

uninstall-cursors:
	@echo "Uninstall cursors"
	@if [ -d $(SHAREDIR)/cursor ]; then                                                       \
		for f in `ls cursor/*.xbm`; do rm -f $(SHAREDIR)/$$f; done;                            \
		for f in `ls cursor/*.cur`; do rm -f $(SHAREDIR)/$$f; done;                            \
		for f in `ls cursor/*.xcur`; do rm -f $(SHAREDIR)/$$f; done;                           \
		if [ "`find $(SHAREDIR)/cursor -type d -empty`" = "`ls -d $(SHAREDIR)/cursor`" ]; then \
			rmdir $(SHAREDIR)/cursor;                                                           \
		fi;                                                                                    \
	fi

install-flags:
	@echo "Install flags"
	@install -m 755 -d $(SHAREDIR)/flags
	@install -m 644 -p flags/*.png $(SHAREDIR)/flags

uninstall-flags:
	@echo "Uninstall flags"
	@if [ -d $(SHAREDIR)/flags ]; then                                                      \
		for f in `ls flags/*.png`; do rm -f $(SHAREDIR)/$$f; done;                           \
		if [ "`find $(SHAREDIR)/flags -type d -empty`" = "`ls -d $(SHAREDIR)/flags`" ]; then \
			rmdir $(SHAREDIR)/flags;                                                          \
		fi;                                                                                  \
	fi

install-localizations:
	@echo "Install localizations"
	@install -m 755 -d $(SHAREDIR)/lang/eco
	@install -m 755 -d $(SHAREDIR)/lang/nag
	@install -m 644 -p lang/*.tcl $(SHAREDIR)/lang
	@install -m 644 -p lang/eco/*.tcl $(SHAREDIR)/lang/eco
	@install -m 644 -p lang/nag/*.tcl $(SHAREDIR)/lang/nag

uninstall-localizations:
	@echo "Uninstall localizations"
	@if [ -d $(SHAREDIR)/lang ]; then                                                     \
		for f in `ls lang/*.tcl`; do rm -f $(SHAREDIR)/$$f; done;                          \
		eco=$(SHAREDIR)/lang/eco;                                                          \
		if [ -d $$eco ]; then                                                              \
			for f in `ls lang/eco/*.tcl`; do rm -f $(SHAREDIR)/$$f; done;                   \
			if [ "`find $$eco -type d -empty`" = "`ls -d $$eco`" ]; then                    \
				rm -rf $$eco;                                                                \
			fi;                                                                             \
		fi;                                                                                \
		nag=$(SHAREDIR)/lang/nag;                                                          \
		if [ -d $$nag ]; then                                                              \
			for f in `ls lang/nag/*.tcl`; do rm -f $(SHAREDIR)/$$f; done;                   \
			if [ "`find $$nag -type d -empty`" = "`ls -d $$nag`" ]; then                    \
				rm -rf $$nag;                                                                \
			fi;                                                                             \
		fi;                                                                                \
		if [ "`find $(SHAREDIR)/lang -type d -empty`" = "`ls -d $(SHAREDIR)/lang`" ]; then \
			rmdir $(SHAREDIR)/lang;                                                         \
		fi;                                                                                \
	fi

install-lang: install-localizations
uninstall-lang: uninstall-localizations

install-photos:
	@echo -n "Install player photos:"
	@install -m 755 -d $(SHAREDIR)/photos
	@for i in a b c d e f g h i j k l m n o p q r s t u v w x y z; do \
		echo -n " $$i";                                                \
		install -m 755 -d $(SHAREDIR)/photos/$$i;                      \
		install -m 644 -p photos/$$i/* $(SHAREDIR)/photos/$$i;         \
	done
	@echo ""

uninstall-photos:
	@echo -n "Uninstall player photos:"
	@if [ -d $(SHAREDIR)/photos ]; then                                                       \
		for i in a b c d e f g h i j k l m n o p q r s t u v w x y z; do                       \
			dir=$(SHAREDIR)/photos/$$i;                                                         \
			if [ -d $$dir ]; then                                                               \
				echo -n " $$i";                                                                  \
				for f in `ls photos/$$i/*`; do rm -f $(SHAREDIR)/$$f; done;                      \
				if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then                     \
					rmdir $$dir;                                                                  \
				fi;                                                                              \
			fi;                                                                                 \
		done;                                                                                  \
		echo "";                                                                               \
		if [ "`find $(SHAREDIR)/photos -type d -empty`" = "`ls -d $(SHAREDIR)/photos`" ]; then \
			rmdir $(SHAREDIR)/photos;                                                           \
		fi;                                                                                    \
	fi

install-textures:
	@echo "Install textures"
	@install -m 755 -d $(SHAREDIR)/textures
	@for i in dark lite tile; do                                             \
		for k in marble misc wood; do                                         \
			install -m 755 -d $(SHAREDIR)/textures/$$i/$$k;                    \
			install -m 644 -p textures/$$i/$$k/* $(SHAREDIR)/textures/$$i/$$k; \
		done;                                                                 \
	done

uninstall-textures:
	@echo "Uninstall textures"
	@if [ -d $(SHAREDIR)/textures ]; then                                                 \
		for i in dark lite tile; do                                                        \
			if [ -d $(SHAREDIR)/textures/$$i ]; then                                        \
				for k in marble misc wood; do                                                \
					kdir=$(SHAREDIR)/textures/$$i/$$k;                                        \
					if [ -d $$kdir ]; then                                                    \
						for f in `ls textures/$$i/$$k/*`; do                                   \
							rm -f $(SHAREDIR)/$$f;                                              \
						done;                                                                  \
						if [ "`find $$kdir -type d -empty`" = "`ls -d $$kdir`" ]; then         \
							rmdir $$kdir;                                                       \
						fi;                                                                    \
					fi;                                                                       \
				done;                                                                        \
				idir=$(SHAREDIR)/textures/$$i;                                               \
				if [ "`find $$idir -type d -empty`" = "`ls -d $$idir`" ]; then               \
					rmdir $$idir;                                                             \
				fi;                                                                          \
			fi;                                                                             \
		done;                                                                              \
		if [ "`find $(SHAREDIR)/textures -type d -empty`" = "$(SHAREDIR)/textures" ]; then \
			rmdir $(SHAREDIR)/textures;                                                     \
		fi;                                                                                \
	fi

install-themes:
	@echo "Install board themes"
	@install -m 755 -d $(SHAREDIR)/themes/square
	@install -m 755 -d $(SHAREDIR)/themes/piece
	@install -m 644 -p themes/*.dat $(SHAREDIR)/themes
	@install -m 644 -p themes/piece/*.dat $(SHAREDIR)/themes/piece
	@install -m 644 -p themes/square/*.dat $(SHAREDIR)/themes/square

uninstall-themes:
	@echo "Uninstall board themes"
	@if [ -d $(SHAREDIR)/themes ]; then                                               \
		for f in `ls themes/*.dat`; do rm -f $(SHAREDIR)/$$f; done;                    \
		dir=$(SHAREDIR)/themes/piece;                                                  \
		if [ -d $$dir ]; then                                                          \
			for f in `ls themes/piece/*.dat`; do rm -f $(SHAREDIR)/$$f; done;           \
			if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then                \
				rmdir $$dir;                                                             \
			fi;                                                                         \
		fi;                                                                            \
		dir=$(SHAREDIR)/themes/square;                                                 \
		if [ -d $$dir ]; then                                                          \
			for f in `ls themes/square/*.dat`; do rm -f $(SHAREDIR)/$$f; done;          \
			if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then                \
				rmdir $$dir;                                                             \
			fi;                                                                         \
		fi;                                                                            \
		if [ "`find $(SHAREDIR)/themes -type d -empty`" = "$(SHAREDIR)/themes" ]; then \
			rmdir $(SHAREDIR)/themes;                                                   \
		fi;                                                                            \
	fi

install-text-scripts:
	@echo "Install TeXt scripts"
	@install -m 755 -d $(SHAREDIR)/scripts
	@install -m 644 -p scripts/*.eXt $(SHAREDIR)/scripts

uninstall-text-scripts:
	@echo "Uninstall TeXt scripts"
	@if [ -d $(SHAREDIR)/scripts ]; then                                                        \
		for f in `ls scripts/*.eXt`; do rm -f $(SHAREDIR)/$$f; done;                             \
		if [ "`find $(SHAREDIR)/scripts -type d -empty`" = "`ls -d $(SHAREDIR)/scripts`" ]; then \
			rmdir $(SHAREDIR)/scripts;                                                            \
		fi;                                                                                      \
	fi

install-pdf-images:
	@echo "Install PDF images"
	@install -m 755 -d $(SHAREDIR)/pdf
	@install -m 755 -d $(SHAREDIR)/pdf/sets
	@for i in `ls pdf/sets/`; do                                       \
		ip=pdf/sets/$$i;                                                \
		install -m 755 -d $(SHAREDIR)/$$ip;                             \
		for k in `ls $$ip`; do                                          \
			kp=$$ip/$$k;                                                 \
			install -m 755 -d $(SHAREDIR)/$$kp;                          \
			install -m 644 -p $$kp/*.png $$kp/*.jpg $(SHAREDIR)/$$kp;    \
			for j in `ls $$kp/pieces`; do                                \
				jp=$$kp/pieces/$$j;                                       \
				install -m 755 -d $(SHAREDIR)/$$jp;                       \
				install -m 644 -p $$jp/*.png $$jp/*.jpg $(SHAREDIR)/$$jp; \
			done;                                                        \
		done;                                                           \
	done

uninstall-pdf-images:
	@echo "Uninstall PDF images"
	@if [ -d $(SHAREDIR)/pdf ]; then                                                                  \
		if [ -d $(SHAREDIR)/pdf/sets ]; then                                                           \
			for i in `ls pdf/sets/`; do                                                                 \
				idir=$(SHAREDIR)/pdf/sets/$$i;                                                           \
				if [ -d $$idir ]; then                                                                   \
					ip=pdf/sets/$$i;                                                                      \
					for k in `ls $$ip`; do                                                                \
						kdir=$$idir/$$k;                                                                   \
						if [ -d $$kdir ]; then                                                             \
							kp=$$ip/$$k;                                                                    \
							rm -f $$kdir/*.png $$kdir/*.jpg;                                                \
							if [ -d $$kdir/pieces ]; then                                                   \
								for j in `ls $$kp/pieces`; do                                                \
									jdir=$(SHAREDIR)/$$kp/pieces/$$j;                                         \
									if [ -d $$jdir ]; then                                                    \
										rm -f $$jdir/*.png $$jdir/*.jpg;                                       \
										if [ "`find $$jdir -type d -empty`" = "`ls -d $$jdir`" ]; then         \
											rmdir $$jdir;                                                       \
										fi;                                                                    \
									fi;                                                                       \
								done;                                                                        \
								if [ "`find $$kdir/pieces -type d -empty`" = "`ls -d $$kdir/pieces`" ]; then \
									rmdir $$kdir/pieces;                                                      \
								fi;                                                                          \
							fi;                                                                             \
							if [ "`find $$kdir -type d -empty`" = "`ls -d $$kdir`" ]; then                  \
								rmdir $$kdir;                                                                \
							fi;                                                                             \
						fi;                                                                                \
					done;                                                                                 \
					if [ "`find $$idir -type d -empty`" = "`ls -d $$idir`" ]; then                        \
						rmdir $$idir;                                                                      \
					fi;                                                                                   \
				fi;                                                                                      \
			done;                                                                                       \
			if [ "`find $(SHAREDIR)/pdf/sets -type d -empty`" = "`ls -d $(SHAREDIR)/pdf/sets`" ]; then  \
				rmdir $(SHAREDIR)/pdf/sets;                                                              \
			fi;                                                                                         \
		fi;                                                                                            \
		if [ "`find $(SHAREDIR)/pdf -type d -empty`" = "`ls -d $(SHAREDIR)/pdf`" ]; then               \
			rmdir $(SHAREDIR)/pdf;                                                                      \
		fi;                                                                                            \
	fi

install-help:
	@echo "Install help files"
	@install -m 755 -d $(SHAREDIR)/help
	@install -m 755 -d $(SHAREDIR)/help/images
	@install -m 755 -d $(SHAREDIR)/help/styles
	@install -m 644 -p help/images/*.* $(SHAREDIR)/help/images
	@install -m 644 -p help/styles/*.css $(SHAREDIR)/help/styles
	@for lang in `ls -d help/[a-z][a-z]`; do                                \
		if [ -a $$lang/Contents.dat ]; then                                  \
			install -m 755 -d $(SHAREDIR)/$$lang;                             \
			install -m 644 -p $$lang/*.dat $(SHAREDIR)/$$lang;                \
			install -m 644 -p $$lang/*.html $(SHAREDIR)/$$lang;               \
			if [ -d $$lang/images ]; then                                     \
				install -m 755 -d $(SHAREDIR)/$$lang/images;                   \
				install -m 644 -p $$lang/images/*.* $(SHAREDIR)/$$lang/images; \
			fi;                                                               \
		fi;                                                                  \
	done

uninstall-help:
	@echo "Uninstall help files"
	@if [ -d $(SHAREDIR)/help ]; then                                                            \
		dir=$(SHAREDIR)/help/images;                                                              \
		if [ -d $$dir ]; then                                                                     \
			for f in `ls help/images/*.*`; do rm -f $(SHAREDIR)/$$f; done;                         \
			if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then rmdir $$dir; fi;          \
		fi;                                                                                       \
		dir=$(SHAREDIR)/help/styles;                                                              \
		if [ -d $$dir ]; then                                                                     \
			for f in `ls help/styles/*.css`; do rm -f $(SHAREDIR)/$$f; done;                       \
			if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then rmdir $$dir; fi;          \
		fi;                                                                                       \
		for lang in `ls -d help/[a-z][a-z]`; do                                                   \
			dir=$(SHAREDIR)/$$lang;                                                                \
			if [ -d $$dir ]; then                                                                  \
				for f in `ls $$lang/*.dat`; do rm -f $(SHAREDIR)/$$f; done;                         \
				for f in `ls $$lang/*.html`; do rm -f $(SHAREDIR)/$$f; done;                        \
				idir=$$dir/images;                                                                  \
				if [ -d $$idir ]; then                                                              \
					for f in `ls $$lang/images/*.*`; do rm -f $(SHAREDIR)/$$f; done;                 \
					if [ "`find $$idir -type d -empty`" = "`ls -d $$idir`" ]; then rmdir $$idir; fi; \
				fi;                                                                                 \
				if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then rmdir $$dir; fi;       \
			fi;                                                                                    \
		done;                                                                                     \
		if [ "`find $(SHAREDIR)/help -type d -empty`" = "`ls -d $(SHAREDIR)/help`" ]; then        \
			rmdir $(SHAREDIR)/help;                                                                \
		fi;                                                                                       \
	fi

install-fonts:
	@echo "Install fonts"
	@if [ "`uname -s`" = "Darwin" ]; then                                          \
		if [ "`id -u`" -eq 0 ]; then                                                \
			install -m 644 -p fonts/*.ttf $(FONTDIR);                                \
		else                                                                        \
			install -m 644 -p fonts/*.ttf ~/Library/Fonts;                           \
		fi;                                                                         \
	else                                                                           \
		if [ "`id -u`" -eq 0 ]; then                                                \
			install -m 755 -d $(FONTDIR);                                            \
			install -m 644 -p fonts/*.ttf $(FONTDIR);                                \
		else                                                                        \
			install -m 755 -d ~/.fonts;                                              \
			install -m 644 -p fonts/*.ttf ~/.fonts;                                  \
		fi;                                                                         \
		if [ ! -z "`which fc-cache`" ]; then                                        \
			if [ "`id -u`" -eq 0 ]; then                                             \
				fc-cache -fv $(FONTDIR);                                              \
			else                                                                     \
				fc-cache -fv ~/.fonts;                                                \
			fi                                                                       \
		else                                                                        \
			echo "Don't know how to setup truetype fonts (fc-cache not available)."; \
			echo "Please contact your system administrator.";                        \
		fi;                                                                         \
	fi

uninstall-fonts:
	@echo "Uninstall fonts"
	@if [ "`uname -s`" = "Darwin" ]; then                                                  \
		if [ "`id -u`" -eq 0 ]; then                                                        \
			for f in `ls fonts/*.ttf`; do                                                    \
				rm -f $(FONTDIR)/`basename $$f`;                                              \
			done;                                                                            \
			if [ "`find $(FONTDIR) -type d -empty`" = "$(FONTDIR)" ]; then                   \
				rmdir $(FONTDIR);                                                             \
			fi;                                                                              \
		else                                                                                \
			for f in `ls fonts/*.ttf`; do                                                    \
				rm -f ~/Library/Fonts/`basename $$f`;                                         \
			done;                                                                            \
			if [ "`find ~/Library/Fonts -type d -empty`" = "`ls -d ~/Library/Fonts`" ]; then \
				rmdir ~/Library/Fonts;                                                        \
			fi;                                                                              \
		fi;                                                                                 \
	else                                                                                   \
		if [ "`id -u`" -eq 0 ]; then                                                        \
			for f in `ls fonts/*.ttf`; do                                                    \
				rm -f $(FONTDIR)/`basename $$f`;                                              \
			done;                                                                            \
			if [ ! -z "`which fc-cache`" ]; then                                             \
				fc-cache -fv $(FONTDIR);                                                      \
			fi;                                                                              \
			if [ "`find $(FONTDIR) -type d -empty`" = "$(FONTDIR)" ]; then                   \
				rmdir $(FONTDIR);                                                             \
			fi;                                                                              \
		else                                                                                \
			for f in `ls fonts/*.ttf`; do                                                    \
				rm -f ~/.$$f;                                                                 \
			done;                                                                            \
			if [ ! -z "`which fc-cache`" ]; then                                             \
				fc-cache -fv ~/.fonts;                                                        \
			fi;                                                                              \
			if [ "`find ~/.fonts -type d -empty`" = "`ls -d ~/.fonts`" ]; then               \
				rmdir ~/.fonts;                                                               \
			fi;                                                                              \
		fi;                                                                                 \
	fi

install: install-script install-pieces install-cursors install-flags install-localizations \
	install-photos install-textures install-themes install-text-scripts install-pdf-images \
	install-help install-fonts

uninstall: uninstall-script uninstall-pieces uninstall-cursors uninstall-flags uninstall-localizations \
	uninstall-themes uninstall-text-scripts uninstall-photos uninstall-textures uninstall-pdf-images \
	uninstall-help uninstall-fonts
	@if [ "`find $(SHAREDIR) -type d -empty`" = "`ls -d $(SHAREDIR)`" ]; then \
		rmdir $(SHAREDIR);                                                     \
	fi

$(SCRIPT): $(SOURCES)
	@if [ -e $(SCRIPT) ]; then rm -f $(SCRIPT); fi
	cat $(SOURCES) | sed -e '/^##/d' -e '/^# /d' > $(SCRIPT)
	chmod 0555 $(SCRIPT)

# vi:set ts=3 sw=3:
