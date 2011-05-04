#!/bin/sh

if [ $# != 2 ]; then
	echo "Usage: mkincl.sh <base-dir> <version-no>"
	exit 1
fi

if [ ! -d "$1" ]; then
	echo "base directory '$1' does not exist"
	exit 1
fi

tcldir=`ls -d $1/tcl$2* 2>/dev/null`
tkdir=`ls -d $1/tk$2* 2>/dev/null`

if [ -z "$tcldir" ]; then
	echo "Tcl version number '$2' does not exist"
	exit 1
fi

if [ -z "$tkdir" ]; then
	echo "Tk version number '$2' does not exist"
	exit 1
fi

if [ ! -d "$tcldir" ]; then
	echo "directory '$tcldir' does not exist"
	exit 1
fi
if [ ! -d "$tkdir" ]; then
	echo "directory '$tkdir' does not exist"
	exit 1
fi

exit 0

mkdir tcl$1
cp $tcldir/generic/tclInt.h tcl$1
cp $tcldir/generic/tclIntDecls.h tcl$1
cp $tcldir/generic/tclIntPlatDecls.h tcl$1
cp $tcldir/generic/tclPort.h tcl$1
cp $tcldir/unix/tclUnixPort.h tcl$1

mkdir tk$1
cp $tkdir/generic/tkInt.h tk$1
cp $tkdir/generic/tkIntDecls.h tk$1
cp $tkdir/generic/tkPort.h tk$1
cp $tkdir/generic/default.h tk$1
cp $tkdir/unix/tkUnixDefault.h tk$1
cp $tkdir/unix/tkUnixPort.h tk$1
