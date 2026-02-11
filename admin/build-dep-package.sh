#!/bin/bash
# Build packages TrEd depends on

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Building a package with unix TrEd dependencies" && \
mkdir -p "${WWW}/tred" && \
# create package with tred unix dependencies
tar czhf "${WWW}/tred/tred-dep-unix.tar.gz" --exclude=.svn --exclude='*~' -C ${TRED_UNIXINST_DIR} packages_unix && \
# create linux installation script in $WWW/tred directory
git show HEAD:../${TRED_FOLDER}/devel/unix_install/install_tred.bash > ${WWW}/tred/install_tred.bash && \
# replace TRED_HOME_URL by URL of TrEd webpage 
perl -pi -e "s|TRED_HOME_URL|$TRED_HOME_URL|g" ${WWW}/tred/install_tred.bash && \

echo "Building package done."