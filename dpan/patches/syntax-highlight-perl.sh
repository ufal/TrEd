#!/bin/bash
# Patches Syntax::Highlight::Perl package

# This package has its documentation placed in file 
# Syntax::Highlight::Perl.html. This file name is, however,
# forbidden on Windows, so we need to rename the file 

EXTDIR=`dirname $(readlink -fen $0)`
GIT_DIR=$(dirname $(dirname $(dirname $(readlink -fen $0))))
. "$EXTDIR/../../admin/env.sh"

echo "Patching Syntax::Highlight::Perl" && \

cd "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/" && \

PACKAGE_NAME=`ls Syntax-Highlight-Perl*.tar.gz` && \

if [ -e "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME.patched" ]; then
	echo "Syntax::Highlight::Perl already patched."
	exit;
fi && \


echo "Entering $EXTDIR" && \
cd $EXTDIR && \
cp "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME" . && \

tar -xzvf $PACKAGE_NAME && \
DIR_NAME=`echo $PACKAGE_NAME | cut -d '.' -f -2` && \
cd $DIR_NAME && \

## this is where actual patching starts

mv Syntax::Highlight::Perl.POD.html Syntax__Highlight__Perl.POD.html && \
patch -p0 -i ../syntax-highlight-perl.patch && \

## end of patching

cd $EXTDIR

#Pack the S::H::P package
tar -czf $PACKAGE_NAME $DIR_NAME && \

cp $PACKAGE_NAME "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME" && \

rm $PACKAGE_NAME && \

if [ -z $DIR_NAME ]; then 
	echo "Not removing, don't have proper file name";
else 
	rm -r "$DIR_NAME/";
fi && \

touch "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME.patched" && \

echo "Patching Syntax::Highlight::Perl done."
