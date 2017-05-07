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

ifneq ($(wildcard ../Makefile.in),)
	include ../Makefile.in
endif

ifneq ($(XDGDIR),)
	export XDG_DATA_DIRS=$(XDGDIR)/share
endif

### MIME ICONS & TYPES #################################################

prepare-install-mime:
	@# Without these directories xdg-icon-resource will fail.
	@if [ -n "$(XDGDIR)" ]; then                        \
		echo "Create icon directories";                  \
		install -m 755 -d $(XDGDIR)/share/icons/hicolor; \
		install -m 755 -d $(XDGDIR)/share/mime/packages; \
	fi

install-mime-icons:
	@echo "Install mime type icons"
	@for size in 16 22 32 48 64 128; do                                                       \
		for app in scidb archive pgn; do                                                       \
			if [ -f $$app-ft-$$size.png ]; then                                                 \
				xdg-icon-resource install --noupdate --novendor --context mimetypes              \
					--size $$size ./$$app-ft-$$size.png application-x-chess-$$app;                \
			fi;                                                                                 \
		done;                                                                                  \
		if [ -f chessbase-ft-$$size.png ]; then                                                \
			xdg-icon-resource install --noupdate --novendor --context mimetypes                 \
				--size $$size ./chessbase-ft-$$size.png application-x-chess-chessbase;           \
			xdg-icon-resource install --noupdate --novendor --context mimetypes                 \
				--size $$size ./chessbase-ft-$$size.png application-x-chess-chessbasedos;        \
		fi;                                                                                    \
		if [ -f scid-ft-$$size.png ]; then                                                     \
			xdg-icon-resource install --noupdate --novendor --context mimetypes                 \
				--size $$size ./scid-ft-$$size.png application-x-chess-scid3;                    \
			xdg-icon-resource install --noupdate --novendor --context mimetypes                 \
				--size $$size ./scid-ft-$$size.png application-x-chess-scid4;                    \
		fi;                                                                                    \
	done

## This belongs to install-mime-icons, but some shells are complaining a syntax error
## (in this commented form).
## --------------------------------------------------------------------------------------
#	#@for size in 16 22 32 48 64 128; do                                                      \
# 		if [ ! -f /usr/share/icons/hicolor/32x32/mimetypes/application-x-chess-pgn.png ]; then \
# 			if [ -f $$app-ft-$$size.png ]; then                                                 \
# 				xdg-icon-resource install --noupdate --novendor --context mimetypes              \
# 					--size $$size ./$$app-ft-$$size.png application-x-chess-$$app;                \
# 			fi;                                                                                 \
# 		fi;                                                                                    \
#	done

install-mime-types:
	@echo "Install mime types (may take a long time)"
	@if case `xdg-mime --version` in "xdg-mime 1.0"*) true;; *) false;; esac; then \
		if [ "`id -u`" -eq 0 ]; then mode="system"; else mode="user"; fi;           \
	   dir="/tmp/scidb.037738378737";                                              \
		mkdir -p $$dir;                                                             \
		for f in `ls *.xml`; do                                                     \
			cat $$f | grep -v "generic-icon name=" > $$dir/$$f;                      \
			xdg-mime install --mode $$mode $$dir/$$f;                                \
		done;                                                                       \
		rm -rf $$dir;                                                               \
	else                                                                           \
		for f in `ls *.xml`; do                                                     \
			xdg-mime install $$f;                                                    \
		done;                                                                       \
	fi

update-mime-database:
	@# We do not use "xdg-mime default", this tool is destructive.
	@if [ -z "$(XDGDIR)" ]; then                                         \
		echo "Update mime database (may take a longer time)";             \
		xdg-icon-resource forceupdate;                                    \
		if [ "`id -u`" -eq 0 ]; then                                      \
			xdgdir=/usr/share;                                             \
			if [ -z "$(XDG_DATA_DIRS)" ]; then                             \
				if [ -f /usr/local/share/applications/mimeapps.list ]; then \
					xdgdir=/usr/local/share;                                 \
				fi;                                                         \
			else                                                           \
				for p in ${XDG_DATA_HOME//:/ }; do                          \
					if [ -d $$p/applications ] ; then                        \
						xdgdir=$$p;                                           \
						break;                                                \
					fi;                                                      \
				done;                                                       \
			fi;                                                            \
		else                                                              \
			xdgdir=~/.local/share;                                         \
			if [ ! -z "$(XDG_DATA_HOME)" ]; then                           \
				if [ -d $(XDG_DATA_HOME) ]; then                            \
					xdgdir=$(XDG_DATA_HOME);                                 \
				fi;                                                         \
			fi;                                                            \
		fi;                                                               \
		if [ -n "$(shell update-mime-database -V 2>/dev/null)" ]; then    \
			update-mime-database $$xdgdir/mime >/dev/null 2>/dev/null;     \
		fi;                                                               \
	else                                                                 \
		echo "SKIP - Update mime database";                               \
	fi

install-mime: prepare-install-mime install-mime-icons install-mime-types update-mime-database

uninstall-mime:
	@# do nothing, because other applications may use these mime types

### DESKTOP ICONS & MENU ###############################################

prepare-install-desktop:
	@# Without these directories xdg-xxx will fail.
	@if [ -n "$(XDGDIR)" ]; then                              \
		echo "Create desktop directories";                     \
		install -m 755 -d $(XDGDIR)/share/icons/hicolor;       \
		install -m 755 -d $(XDGDIR)/share/applications;        \
		install -m 755 -d $(XDGDIR)/share/desktop-directories; \
	fi

install-app-icons:
	@echo "Install desktop application icons"
	@for size in 16 22 32 48 64 128; do                                                           \
		if [ -f scidb-$$size.png ]; then                                                           \
			xdg-icon-resource install --noupdate --novendor --size $$size ./scidb-$$size.png scidb; \
		fi;                                                                                        \
	done
	@if [ -z "$(XDGDIR)" ]; then      \
		xdg-icon-resource forceupdate; \
	fi

uninstall-app-icons:
	@echo "Uninstall desktop application icons"
	@for size in 16 22 32 48 64 128; do                                                  \
		if [ -f scidb-$$size.png ]; then                                                  \
			xdg-icon-resource uninstall --noupdate --size $$size ./scidb-$$size.png scidb; \
		fi;                                                                               \
	done
	@if [ -z "$(XDGDIR)" ]; then      \
		xdg-icon-resource forceupdate; \
	fi

install-desktop-menu-entry:
	@echo "Install desktop menu"
	@if [ -z "$(XDGDIR)" ]; then                                  \
		xdg-desktop-menu install --novendor scidb.desktop;         \
		xdg-desktop-menu forceupdate;                              \
	else                                                          \
		install -m 644 scidb.desktop $(XDGDIR)/share/applications; \
	fi

uninstall-desktop-menu-entry:
	@echo "Uninstall desktop menu"
	@xdg-desktop-menu uninstall scidb.desktop
	@if [ -z "$(XDGDIR)" ]; then     \
		xdg-desktop-menu forceupdate; \
	fi

install-desktop-database:
	@if [ -z "$(XDGDIR)" ]; then                                            \
		if [ -z "`type update-desktop-database 2>/dev/null`" ]; then         \
			echo "Cannot install desktop files";                              \
		else                                                                 \
			echo "Update desktop databases";                                  \
			if [ "`id -u`" -eq 0 ]; then                                      \
				xdgdir=/usr/share;                                             \
				if [ -z "$(XDG_DATA_DIRS)" ]; then                             \
					if [ -f /usr/local/share/applications/mimeapps.list ]; then \
						xdgdir=/usr/local/share;                                 \
					fi;                                                         \
				else                                                           \
					for p in ${XDG_DATA_HOME//:/ }; do                          \
						if [ -d $$p/applications ] ; then                        \
							xdgdir=$$p;                                           \
							break;                                                \
						fi;                                                      \
					done;                                                       \
				fi;                                                            \
			else                                                              \
				xdgdir=~/.local/share;                                         \
				if [ ! -z "$(XDG_DATA_HOME)" ]; then                           \
					if [ -d $(XDG_DATA_HOME) ]; then                            \
						xdgdir=$(XDG_DATA_HOME);                                 \
					fi;                                                         \
				fi;                                                            \
			fi;                                                               \
			appdir=$$xdgdir/applications;                                     \
			./update-mimeapps.list.tcl add $$appdir/mimeapps.list;            \
			update-desktop-database $$appdir 2>/dev/null;                     \
		fi;                                                                  \
	else                                                                    \
		echo "SKIP - Update desktop databases";                              \
	fi

uninstall-desktop-database:
	@if [ -z "$(XDGDIR)" ]; then                                            \
		if [ -n "`type update-desktop-database 2>/dev/null`" ]; then         \
			echo "Update desktop databases";                                  \
			if [ "`id -u`" -eq 0 ]; then                                      \
				xdgdir=/usr/share;                                             \
				if [ -z "$(XDG_DATA_DIRS)" ]; then                             \
					if [ -f /usr/local/share/applications/mimeapps.list ]; then \
						xdgdir=/usr/local/share;                                 \
					fi;                                                         \
				else                                                           \
					for p in ${XDG_DATA_HOME//:/ }; do                          \
						if [ -d $$p/applications ] ; then                        \
							xdgdir=$$p;                                           \
							break;                                                \
						fi;                                                      \
					done;                                                       \
				fi;                                                            \
			else                                                              \
				xdgdir=~/.local/share;                                         \
				if [ ! -z "$(XDG_DATA_HOME)" ]; then                           \
					if [ -d $(XDG_DATA_HOME) ]; then                            \
						xdgdir=$(XDG_DATA_HOME);                                 \
					fi;                                                         \
				fi;                                                            \
			fi;                                                               \
			appdir=$$xdgdir/applications;                                     \
			./update-mimeapps.list.tcl remove $$appdir/mimeapps.list;         \
			update-desktop-database $$appdir 2>/dev/null;                     \
		fi;                                                                  \
	fi

install-desktop-menu: prepare-install-desktop install-app-icons install-desktop-menu-entry \
	install-desktop-database

uninstall-desktop-menu: uninstall-app-icons uninstall-desktop-menu-entry uninstall-desktop-database

### DISTRIBUTION ######################################################

distribute:
	@echo "Distribute freedesktop.org stuff"
	@install -m 755 -d $(SHAREDIR)/freedesktop.org
	@install -m 755 update-mimeapps.list.tcl $(SHAREDIR)/freedesktop.org
	@chmod 0555 $(SHAREDIR)/freedesktop.org/update-mimeapps.list.tcl
	@install -m 644 *.* Makefile $(SHAREDIR)/freedesktop.org

remove:
	@echo "Remove freedesktop.org stuff"
	@if [ -d $(SHAREDIR)/freedesktop.org ]; then \
		rm -f $(SHAREDIR)/freedesktop.org/*;      \
		rmdir $(SHAREDIR)/freedesktop.org;        \
	fi

# vi:set ts=3 sw=3:
