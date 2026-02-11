#!/bin/bash
# Installs TrEd extensions on UFAL network

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

##ATTENTION pozor, tuto je upraveny make, aby mal zname cesty a pod...
## a mojou sikovnostou je uz aj na UFAL svn :/

echo "Installing TrEd extensions to $INSTALL_SHARE"

# Create directories for TrEd
mkdir -p $WWW/tred/extensions 2> /dev/null

# create symlink in TrEd install directory
# (we have to test the existance of symlink first, otherwise we would create link the other way (and also never-ending recursion))
#if [ ! -h $TRED_WININST_DIR/extensions ]; then
#	ln -s $WWW/tred/extensions/ $TRED_WININST_DIR/extensions
#fi

##ATT naco sa robi nasl riadok??
cd ${TRED_EXT_DIR}; ./make pdt20; ./make pdt_vallex && \
# remove old extensions dir
(test ! -d ${INSTALL_SHARE}/tred-extensions.new/ || rm -rf ${INSTALL_SHARE}/tred-extensions.new) && \
# two basic extensions installed under $INSTALL_SHARE
mkdir -p ${INSTALL_SHARE}/tred-extensions.new/ && \
svn export ${TRED_SVN_EXT}/pdt20 ${INSTALL_SHARE}/tred-extensions.new/pdt20 >> $LOG && \
svn export ${TRED_SVN_EXT}/pdt_vallex ${INSTALL_SHARE}/tred-extensions.new/pdt_vallex >> $LOG && \
chmod -R g+rwX ${INSTALL_SHARE}/tred-extensions.new/ && \
(echo pdt20; echo pdt_vallex) > ${INSTALL_SHARE}/tred-extensions.new/extensions.lst && \

# remove tred-extensions.old
(test ! -d ${INSTALL_SHARE}/tred-extensions.old/ || rm -rf ${INSTALL_SHARE}/tred-extensions.old) && \
# rename current extensions to old extensions
(test ! -d ${INSTALL_SHARE}/tred-extensions/ || mv ${INSTALL_SHARE}/tred-extensions ${INSTALL_SHARE}/tred-extensions.old) && \
# rename new extensions to current extensions
mv ${INSTALL_SHARE}/tred-extensions.new ${INSTALL_SHARE}/tred-extensions && \
# remove new old extensions again
(test ! -d ${INSTALL_SHARE}/tred-extensions.old/ || rm -rf ${INSTALL_SHARE}/tred-extensions.old) && \
# eof install-tred-extensions

echo "Installing TrEd extensions done."
