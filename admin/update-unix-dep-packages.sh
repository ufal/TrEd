#!/bin/bash
# Download/update unix dependency packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Updating unix dependency packages" && \
# remove old packages
rm -rf ${TRED_UNIXINST_DIR}/packages_unix/packages && \
# update svn
svn up $TRED_UNIXINST_DIR >> $LOG && \
svn status $TRED_UNIXINST_DIR && \
# fetch packages from CPAN && use INSTALL_BASE
cd ${TRED_UNIXINST_DIR}/packages_unix && PERLLIB= PERL5LIB= LD_LIBRARY_PATH= ./install -b -C && \

echo "Updating unix dependency packages done."
