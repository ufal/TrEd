#!/bin/bash
# Download/update unix dependency packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Updating unix dependency packages" && \
# remove old packages
echo "Remove old packages" && \
rm -rf ${TRED_UNIXINST_DIR}/packages_unix/packages && \

# fetch packages from CPAN && use INSTALL_BASE
cd ${TRED_UNIXINST_DIR}/packages_unix && \
echo "Update packages from CPAN" && \
PERLLIB= PERL5LIB= LD_LIBRARY_PATH= ./install -b -C && \

echo "Updating unix dependency packages done."
