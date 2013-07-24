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

### MIME ICONS & TYPES #################################################

install-mime-icons:
	@echo "Install mime type icons"
	@for app in scidb chessbase archive; do                                      \
		for size in 16 22 32 48 64 128; do                                        \
			if [ -f $$app-ft-$$size.png ]; then                                    \
				xdg-icon-resource install --noupdate --novendor --context mimetypes \
					--size $$size ./$$app-ft-$$size.png application-x-chess-$$app;   \
			fi; \
		done; \
	done
	@for size in 16 22 32 48 64 128; do                                       \
		if [ -f scid-ft-$$size.png ]; then                                     \
			xdg-icon-resource install --noupdate --novendor --context mimetypes \
				--size $$size ./scid-ft-$$size.png application-x-chess-scid3;    \
			xdg-icon-resource install --noupdate --novendor --context mimetypes \
				--size $$size ./scid-ft-$$size.png application-x-chess-scid4;    \
		fi; \
	done

install-mime-types:
	@echo "Install mime types"
	@if [ "`xdg-mime --version`" = "xdg-mime 1.0" ]; then    \
		mkdir .tmp;                                           \
		for f in `ls *.xml`; do                               \
			cat $$f | grep -v "generic-icon name=" > .tmp/$$f; \
			xdg-mime install --mode system .tmp/$$f;           \
		done;                                                 \
		rm -rf .tmp;                                          \
	else                                                     \
		for f in `ls *.xml`; do                               \
			xdg-mime install $$f;                              \
		done;                                                 \
	fi

update-mime-database:
	@echo "Update mime database"
	@xdg-icon-resource forceupdate
	@if [ "`id -u`" -eq 0 ]; then                                     \
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
	fi

install-mime: install-mime-icons install-mime-types update-mime-database

uninstall-mime:
	@# do nothing, because other applications may use these mime types

### DESKTOP ICONS & MENU ###############################################

install-app-icons:
	@echo "Install desktop application icons"
	@for size in 16 22 32 48 64 128; do                                                           \
		if [ -f scidb-$$size.png ]; then                                                           \
			xdg-icon-resource install --noupdate --novendor --size $$size ./scidb-$$size.png scidb; \
		fi;                                                                                        \
	done
	@xdg-icon-resource forceupdate

uninstall-app-icons:
	@echo "Uninstall desktop application icons"
	@for size in 16 22 32 48 64 128; do                                                  \
		if [ -f scidb-$$size.png ]; then                                                  \
			xdg-icon-resource uninstall --noupdate --size $$size ./scidb-$$size.png scidb; \
		fi;                                                                               \
	done
	@xdg-icon-resource forceupdate

install-desktop-menu-entry:
	@echo "Install desktop menu"
	@xdg-desktop-menu install --novendor scidb.desktop
	@xdg-desktop-menu forceupdate

uninstall-desktop-menu-entry:
	@echo "Uninstall desktop menu"
	@xdg-desktop-menu uninstall scidb.desktop
	@xdg-desktop-menu forceupdate

install-desktop-database:
	@echo "Update desktop databases"
	@if [ "`id -u`" -eq 0 ]; then                                     \
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
	./update-mimeapps.list add $$appdir/mimeapps.list;                \
	update-desktop-database $$appdir 2>/dev/null

uninstall-desktop-database:
	@echo "Update desktop databases"
	@if [ "`id -u`" -eq 0 ]; then                                     \
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
	./update-mimeapps.list remove $$appdir/mimeapps.list;             \
	update-desktop-database $$appdir 2>/dev/null

install-desktop-menu: install-app-icons install-desktop-menu-entry install-desktop-database

uninstall-desktop-menu: uninstall-app-icons uninstall-desktop-menu-entry uninstall-desktop-database

# vi:set ts=3 sw=3:
