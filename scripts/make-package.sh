rm -f scidb*.spec
type=$1
shift
checkinstall --type=$type \
	--pkgname="scidb-beta" \
	--pkgversion="1.0" \
	--pkgrelease="r955" \
	--pkglicense="GPL" \
	--pkggroup="Application/Games" \
	--pkgsource="http://sourceforge.net/projects/scidb" \
	--maintainer="gcramer@users.sourceforge.net" \
	--requires="tk8.5,tcl8.5,libX11-6,libsm6,libice6,libxcursor1,libexpat1,libstdc++6,libc6,libgcc1,libxft2,libfontconfig1,libfreetype6,zlib1g" \
	--newslack --nodoc --strip=no --backup=no --install=no $* make install
