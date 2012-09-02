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

SCRIPT = scidb$(SUFFIX)
ARCH = arch-scidb
UPDATE_PHOTO_FILES = update-scidb-photo-files

# NOTE that the ordering is important!
SOURCES = \
	exec.tcl \
	start.tcl \
	utils/tcl_bugs.tcl \
	utils/place.tcl \
	splash.tcl \
	utils/archive.tcl \
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
	dialogs/help.tcl \
	contrib/tkmenu.tcl \
	contrib/treectrl.tcl \
	contrib/filelist-bindings.tcl \
	utils/locale.tcl \
	utils/countries.tcl \
	utils/web.tcl \
	utils/xcursor.tcl \
	utils/player-photos.tcl \
	dnd/tkdnd.tcl \
	dnd/tkdnd_unix.tcl \
	widgets/tooltip.tcl \
	widgets/toolbar.tcl \
	widgets/validate.tcl \
	widgets/tlistbox.tcl \
	widgets/tcombobox.tcl \
	widgets/colormenu.tcl \
	widgets/table.tcl \
	widgets/treetable.tcl \
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
	widgets/figurines.tcl \
	widgets/notation.tcl \
	widgets/twm.tcl \
	gametable.tcl \
	playertable.tcl \
	eventtable.tcl \
	sitetable.tcl \
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
	app-db-sites.tcl \
	app-pgn.tcl \
	app-tree.tcl \
	app-tree-games.tcl \
	app-variation.tcl \
	app-analysis.tcl \
	pgn-setup.tcl \
	save-replace.tcl \
	export.tcl \
	import.tcl \
	browser.tcl \
	overview.tcl \
	player-card.tcl \
	setup-board.tcl \
	setup-position.tcl \
	crosstable.tcl \
	info.tcl \
	move.tcl \
	game.tcl \
	i18n.tcl \
	utils/shadow.tcl \
	menu.tcl \
	end.tcl \

SCRIPTS = $(SCRIPT) $(UPDATE_PHOTO_FILES)

all: $(SCRIPTS)

clean:
	@echo "Clean `pwd`"
	@rm -f $(SCRIPT)
	@rm -f $(UPDATE_PHOTO_FILES)

depend:
	@# nothing to do

build-install-help: build-help install-help

build-help:
	@for lang in `ls -d help/[a-z][a-z]`; do           \
		(cd $$lang; if [ -f Makefile ]; then make; fi); \
	done

install-scripts: $(SCRIPTS)
	@echo "Install Tcl scripts"
	@install -m 755 -d $(BINDIR)
	@install -m 755 -p $(SCRIPT) $(BINDIR)
	@install -m 755 -p $(UPDATE_PHOTO_FILES) $(BINDIR)

uninstall-scripts:
	@echo "Uninstall Tcl scripts"
	@rm -f $(BINDIR)/$(SCRIPT)
	@rm -f $(BINDIR)/$(UPDATE_PHOTO_FILES)

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
	@install -m 755 -d $(SHAREDIR)/photos

uninstall-photos:
	@if [ -d $(SHAREDIR)/photos ]; then                                          \
		photodir=$(SHAREDIR)/photos;                                              \
		if [ -f $$photodir/FILES ]; then                                          \
			echo -n "Uninstall player photos:";                                    \
			for file in `cat $$photodir/FILES`; do                                 \
				if [ -f $$photodir/$file ]; then                                    \
					rm -f $$photodir/$file;                                          \
				fi;                                                                 \
			done;                                                                  \
			for i in a b c d e f g h i j k l m n o p q r s t u v w x y z; do       \
				dir=$$photodir/$$i;                                                 \
				if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then        \
					rmdir $$dir;                                                     \
				fi;                                                                 \
			done;                                                                  \
			if [ "`find $$photodir -type d -empty`" = "`ls -d $$photodir`" ]; then \
				rmdir $$photodir;                                                   \
			fi;                                                                    \
		fi;                                                                       \
	fi
	@if [ "`find $(SHAREDIR) -type d -empty`" = "`ls -d $(SHAREDIR)`" ]; then \
		rmdir $(SHAREDIR);                                                     \
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
	@install -m 644 -p scripts/*.css $(SHAREDIR)/scripts

uninstall-text-scripts:
	@echo "Uninstall TeXt scripts"
	@if [ -d $(SHAREDIR)/scripts ]; then                                                        \
		for f in `ls scripts/*.eXt scripts/*.css`; do rm -f $(SHAREDIR)/$$f; done;               \
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
		if [ -f $$lang/Contents.dat ]; then                                  \
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
	@if [ 1 ]; then                                                                   \
		if [ "`id -u`" -eq 0 ]; then                                                   \
			fontdir="$(FONTDIR)";                                                       \
		else                                                                           \
			if [ "`uname -s`" = "Darwin" ]; then                                        \
				fontdir="$(HOME)/Library/Fonts";                                         \
			else                                                                        \
				fontdir="$(HOME)/.fonts";                                                \
			fi;                                                                         \
		fi;                                                                            \
		install -m 755 -d $$fontdir;                                                   \
		install -m 644 -p fonts/*.ttf $$fontdir;                                       \
		if [ ! -z "`which fc-cache`" ]; then                                           \
			fc-cache -f $$fontdir;                                                      \
		else                                                                           \
			if [ "`uname -s`" != "Darwin" ]; then                                       \
				echo "Don't know how to setup truetype fonts (fc-cache not available)."; \
				echo "Please contact your system administrator.";                        \
			fi;                                                                         \
		fi;                                                                            \
	fi

uninstall-fonts:
	@echo "Uninstall fonts"
	@if [ 1 ]; then                                                 \
		if [ "`id -u`" -eq 0 ]; then                                 \
			fontdir="$(FONTDIR)";                                     \
		else                                                         \
			if [ "`uname -s`" = "Darwin" ]; then                      \
				fontdir="$(HOME)/Library/Fonts";                       \
			else                                                      \
				fontdir="$(HOME)/.fonts";                              \
			fi;                                                       \
		fi;                                                          \
		for f in `ls fonts/*.ttf`; do                                \
			rm -f $$fontdir/`basename $$f`;                           \
		done;                                                        \
		if [ ! -z "`which fc-cache`" ]; then                         \
			fc-cache -f $$fontdir;                                    \
		fi;                                                          \
		if [ "`find $$fontdir -type d -empty`" = "$$fontdir" ]; then \
			rmdir $$fontdir;                                          \
		fi;                                                          \
	fi

install-no-photos: install-scripts install-pieces install-cursors install-flags \
	install-localizations install-textures install-themes install-text-scripts  \
	install-pdf-images install-help install-fonts

install: install-no-photos install-photos

uninstall: uninstall-scripts uninstall-pieces uninstall-cursors uninstall-flags uninstall-localizations \
	uninstall-themes uninstall-text-scripts uninstall-textures uninstall-pdf-images    \
	uninstall-help uninstall-fonts
	@if [ "`find $(SHAREDIR) -type d -empty`" = "`ls -d $(SHAREDIR)`" ]; then \
		rmdir $(SHAREDIR);                                                     \
	fi

$(SCRIPT): $(SOURCES)
	@echo "Build $(SCRIPT)"
	@if [ -e $(SCRIPT) ]; then rm -f $(SCRIPT); fi
	@cat $(SOURCES) | sed                                  \
		-e 's/# vi:set ts=3 sw=3:/update idletasks/'        \
		-e 's#%SHAREDIR%#$(SHAREDIR)#g'                     \
		-e 's#%%ENGINESDIR%%#$(%ENGINESDIR%)#g'             \
		-e 's/%UPDATE_PHOTO_FILES%/$(UPDATE_PHOTO_FILES)/g' \
		-e '/^##/d'                                         \
		-e '/^#$$/d'                                        \
		-e '/^[ 	]*#[ 	]\+/d'                               \
		> $(SCRIPT)
	@chmod 0555 $(SCRIPT)

$(UPDATE_PHOTO_FILES): utils/update-photos.tcl
	@echo "Build $(UPDATE_PHOTO_FILES)"
	@if [ -e $(UPDATE_PHOTO_FILES) ]; then rm -f $(UPDATE_PHOTO_FILES); fi
	@cat utils/update-photos.tcl | sed                     \
		-e 's/%PROGRAM%/tclscidb$(SUFFIX)/g'                \
		-e 's#%SHAREDIR%#$(SHAREDIR)#g'                     \
		-e 's/%UPDATE_PHOTO_FILES%/$(UPDATE_PHOTO_FILES)/g' \
		> $(UPDATE_PHOTO_FILES)
	@chmod 0555 $(UPDATE_PHOTO_FILES)

$(ARCH): utils/archive.tcl
	@echo "Build $(ARCH)"
	@if [ -e $(ARCH) ]; then rm -f $(ARCH); fi
	@cat utils/archive.tcl | sed            \
		-e 's/%PROGRAM%/tclscidb$(SUFFIX)/g' \
		-e 's#%SHAREDIR%#$(SHAREDIR)#g'      \
		-e 's/%ARCH%/$(ARCH)/g'              \
		> $(ARCH)
	@chmod 0555 $(ARCH)

# vi:set ts=3 sw=3:
