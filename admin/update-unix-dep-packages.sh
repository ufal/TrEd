#!/bin/bash
# Download/update unix dependency packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Updating unix dependency packages" && \
# remove old packages
echo "Remove old packages" && \
rm -rf ${TRED_UNIXINST_DIR}/packages_unix/packages && \

# update svn
echo "Subversion update" && \
svn up $TRED_UNIXINST_DIR >> $LOG && \
echo "Subversion status" && \
svn status $TRED_UNIXINST_DIR && \

# fetch packages from CPAN && use INSTALL_BASE
cd ${TRED_UNIXINST_DIR}/packages_unix && \
echo "Remove old packages" && \
PERLLIB= PERL5LIB= LD_LIBRARY_PATH= ./install -b -C && \

echo "Updating unix dependency packages done."
