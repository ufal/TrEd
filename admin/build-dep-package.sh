#!/bin/bash
# Build packages TrEd depends on

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Building a package with unix TrEd dependencies" && \
# create package with tred unix dependencies
tar czhf "${WWW}/tred/tred-dep-unix.tar.gz" --exclude=.svn --exclude='*~' -C ${TRED_UNIXINST_DIR} packages_unix && \
# create linux installation script in $WWW/tred directory
svn cat ${TRED_SVN_REPO}/devel/unix_install/install_tred.bash > ${WWW}/tred/install_tred.bash && \

echo "Building package done."