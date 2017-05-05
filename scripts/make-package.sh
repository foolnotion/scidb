rm -f scidb*.spec
type=$1
shift
requires=""
case $type in
	debian)
		requires="desktop-file-utils,libgdbm3,hicolor-icon-theme,libc6,libexpat1,libfontconfig1,libfreetype6,libgcc1,libice6,libsm6,libstdc++6,libx11-6,libxcursor1,libxft2,shared-mime-info,tcl8.6,tk8.6,xdg-utils,zlib1g";;
	rpm)
		requires="desktop-file-utils,expat,fontconfig,freetype,gdbm,glibc,hicolor-icon-theme,libgcc,libICE,libSM,libstdc++,libX11,libXcursor,libXft,shared-mime-info,tcl,tk,xdg-utils,zlib";;
esac
checkinstall --type=$type \
	--pkgname="scidb-beta" \
	--pkgversion="1.0" \
	--pkgrelease="r1004" \
	--pkglicense="GPL" \
	--pkggroup="Application/Games" \
	--pkgsource="http://sourceforge.net/projects/scidb" \
	--maintainer="gcramer@users.sourceforge.net" \
	--requires="$requires" \
	--newslack --fstrans=no --nodoc --strip=no --backup=no --install=no $* make install
