#!/bin/bash

# Prepare deb package and upload it to testbed website.
# The core release must be made first, so the install_tred.bash script is ready.

EXTDIR=`dirname $(readlink -fen $0)`
. $EXTDIR/env.sh

SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`

# Prepare the deb package
cd "$PROJECT_DIR/unix_install_pkgs/deb" || exit 1
./prepare_deb_pkg.sh || exit 2

test $net -eq 1 || cd "$EXTDIR" && exit 0

# Delete previous versions of deb packages ...
echo "Delete previous versions of deb packages ..."
ssh ${LOGIN_NAME}@${TESTING_SERVER} "rm -f /var/www/tred/testbed/*.deb"

# Upload the package to the testbed website
echo "Uploading the package to testbed web ..."
DEB_FILE="tred_2.${SVN_VERSION}_all.deb"
scp "./${DEB_FILE}" "${LOGIN_NAME}@${REMOTE_WWW}/${DEB_FILE}"

# Make sure tred.deb link points to the newest deb package
echo "Creating symlink tred.deb ..."
ssh ${LOGIN_NAME}@${TESTING_SERVER} "cd /var/www/tred/testbed && ln -sf ./${DEB_FILE} ./tred.deb"

cd "$EXTDIR"
