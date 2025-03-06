#!/bin/bash
# Patches Graph::Kruskal package

# This package uses some non-standard tar.gz packaging, 
# it can not be unpacked on windows, so just a repack 
# should do the trick

EXTDIR=`dirname $(readlink -fen $0)`
GIT_DIR=$(dirname $(dirname $(dirname $(readlink -fen $0))))
. "$EXTDIR/../../admin/env.sh"

echo "Patching Graph::Kruskal" && \

cd "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/" && \

PACKAGE_NAME=`ls Graph-Kruskal*.tar.gz` && \

if [ -e "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME.patched" ]; then
	echo "Graph::Kruskal already patched.";
	exit;
fi && \


echo "Entering $EXTDIR" && \
cd $EXTDIR && \
cp "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME" . && \

tar -xzvf $PACKAGE_NAME && \

DIR_NAME=`echo $PACKAGE_NAME | cut -d '.' -f -2` && \

tar -czf $PACKAGE_NAME $DIR_NAME && \

cp $PACKAGE_NAME "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME" && \

rm $PACKAGE_NAME && \

if [ -z $PACKAGE_NAME ]; then 
	echo "Not removing, don't have proper file name";
else 
	rm -rf "$DIR_NAME/";
fi && \

touch "$TRED_DPAN_DIR/dpan/authors/id/D/DP/DPAN/$PACKAGE_NAME.patched" && \

echo "Patching Graph::Kruskal done."
