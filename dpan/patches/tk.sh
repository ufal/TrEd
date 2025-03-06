#!/bin/bash
# Patches Tk-804.030 package
# patch for gcc if it contains full path on win32 machine instead of just gcc..

# These were patches for 804.029:
# Applies two patches, for further information, see
# win32 64bit patch: 	http://www.mail-archive.com/win32-vanilla@perl.org/msg00249.html, https://rt.cpan.org/Public/Bug/Display.html?id=60707
# MacOS X libpng patch:	https://rt.cpan.org/Public/Bug/Display.html?id=58011


EXTDIR=`dirname $(readlink -fen $0)`
GIT_DIR=$(dirname $(dirname $(dirname $(readlink -fen $0))))
. "$EXTDIR/../../admin/env.sh"

echo "Patching Tk" && \

cd "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/" && \

PACKAGE_NAME=`ls -1 Tk*.tar.gz | grep "Tk-[0-9.]\+\.tar\.gz"` && \

if [ -e "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME.patched" ]; then
	echo "Tk already patched."
	exit;
fi && \

echo "Entering $EXTDIR" && \
cd $EXTDIR && \
cp "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME" . && \

tar -xzvf $PACKAGE_NAME && \
DIR_NAME=`echo $PACKAGE_NAME | cut -d '.' -f -2` && \
cd $DIR_NAME && \

## this is where actual patching starts

# these are already patched in Tk 804.030
# patch -p1 -i ../tk-804.029-64bit-strawberry-win32.patch && \
# patch -p1 -i ../tk-804.029-libpng-macos.patch && \
# this is a new patch for 804.030, fixed in 804.031
# patch -p1 -i ../Tk-804.030-full-gcc-path-win32.patch && \
## end of patching

cd $EXTDIR

#Pack the Tk package
tar -czf $PACKAGE_NAME $DIR_NAME && \

cp $PACKAGE_NAME "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME" && \

rm $PACKAGE_NAME && \

if [ -z $DIR_NAME ]; then 
	echo "Not removing, don't have proper file name";
else 
	rm -rf "$DIR_NAME/";
fi && \

touch "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME.patched" && \

echo "Patching Tk done."
