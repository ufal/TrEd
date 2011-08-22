#!/bin/bash
# Packs TrEd extensions

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Packing TrEd extensions" && \

cd ${TRED_EXT_DIR} && ./make && \

##TODO This script also prepares extensions in $WWW/tred/extensions, one icon is missing there, maybe put it into svn later
cd ${WWW}/tred/extensions && \
wget -nv http://ufal.mff.cuni.cz/~pajas/tred/extensions/extension.png && \
##TODO pdt20 doc is created in wrong directory, this is a temporary fix
mv ${WWW}/pdt* ${WWW}/tred/documentation

echo "Packing TrEd extensions done."