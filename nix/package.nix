{
  lib,
  stdenv,
  src,
  pkg-config,
  makeWrapper,
  tcl,
  tk,
  fontconfig,
  freetype,
  libX11,
  libSM,
  libXcursor,
  libICE,
  xorgproto,
  gdbm,
  expat,
  minizip,
  zlib,
}:

stdenv.mkDerivation {
  pname = "scidb";
  version = "unstable";

  inherit src;

  nativeBuildInputs = [ tcl pkg-config makeWrapper ];

  buildInputs = [
    tcl tk
    fontconfig freetype
    libX11 libSM libXcursor libICE xorgproto
    gdbm expat minizip zlib
  ];

  configurePhase = ''
    runHook preConfigure

    _inc="\
      -I${libX11.dev}/include \
      -I${libSM.dev}/include \
      -I${libXcursor.dev}/include \
      -I${libICE.dev}/include \
      -I${xorgproto}/include \
      -I${freetype.dev}/include \
      -I${fontconfig.dev}/include \
      -I${gdbm.dev}/include \
      -I${expat.dev}/include \
      -I${zlib.dev}/include \
      -I${minizip}/include"
    export SYS_CFLAGS="$_inc -std=gnu11 -fcommon -O3 -march=x86-64-v3"
    export SYS_CXXFLAGS="$_inc -fpermissive -fcommon -O3 -march=x86-64-v3"
    export SYS_LDFLAGS="\
      -L${libX11}/lib -lX11 \
      -L${libSM}/lib -lSM \
      -L${libXcursor}/lib -lXcursor \
      -L${libICE}/lib -lICE \
      -L${freetype}/lib -lfreetype \
      -L${fontconfig}/lib -lfontconfig \
      -L${gdbm}/lib -lgdbm \
      -L${expat}/lib -lexpat \
      -L${zlib}/lib -lz \
      -L${minizip}/lib -lminizip"

    tclsh configure \
      --bindir=$out/bin \
      --datadir=$out/share/scidb \
      --libdir=$out/lib \
      --mandir=$out/share/man \
      --fontdir=$out/share/fonts/scidb \
      --enginesdir=$out/bin \
      --disable-freedesktop \
      --tcl-includes=${tcl}/include \
      --tcl-libraries=${tcl}/lib \
      --tk-includes=${tk}/include \
      --tk-libraries=${tk}/lib \
      --x-includes=${libX11.dev}/include \
      --x-libraries=${libX11}/lib \
      --xcursor-libraries=${libXcursor}/lib \
      --fontconfig-libraries=${fontconfig}/lib \
      --with-zlib-inc=${zlib.dev}/include \
      --with-zlib-lib=${zlib}/lib \
      --with-expat-inc=${expat.dev}/include \
      --with-expat-lib=${expat}/lib

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    export HOME=$(mktemp -d)
    make install
    if [ -d "$HOME/.fonts" ]; then
      mkdir -p "$out/share/fonts/scidb"
      cp -r "$HOME/.fonts/." "$out/share/fonts/scidb/"
    fi
    runHook postInstall
  '';

  postInstall = ''
    rm -f "$out/bin/sjeng-scidb" "$out/bin/stockfish-scidb"
    tkver="${lib.versions.majorMinor tk.version}"
    wrapProgram "$out/bin/tkscidb-beta" \
      --set TK_LIBRARY "${tk}/lib/tk$tkver" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ tk tcl ]}"
  '';

  meta = with lib; {
    description = "Chess database application";
    homepage = "https://scidb.sourceforge.net/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
