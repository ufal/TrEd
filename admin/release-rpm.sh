#!/bin/bash

# Prepare deb package and upload it to testbed website.
# The core release must be made first, so the install_tred.bash script is ready.

EXTDIR=`dirname $(readlink -fen $0)`
. $EXTDIR/env.sh

SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`

# Prepare the deb package
cd "$PROJECT_DIR/unix_install_pkgs/rpm" || exit 1
./prepare_rpm_pkg.sh || exit 2

test $net -eq 1  || exit 0
cd "$EXTDIR" || exit 3

# Delete previous versions ...
echo "Remove previous rpm packages ..."
ssh ${LOGIN_NAME}@${TESTING_SERVER} "rm -f /var/www/tred/testbed/*.rpm"

# Upload the package to the testbed website
echo "Uploading the package to testbed web ..."
ls -1 ./tred*.rpm | while read FILE; do
	scp "$FILE" "${LOGIN_NAME}@${REMOTE_WWW}/"
done

# Make sure tred.deb link points to the newest deb package
echo "Creating symlinks for rpm packages ..."
DISTROS=`ls -1 ./tred*.rpm | sed -E 's/^.*tred-[0-9]+-[0-9]+-//' | sed 's/[.]noarch[.]rpm$//' | tr "\\n" " "`
for DISTRO in $DISTROS; do
	echo "... for $DISTRO ..."
	ssh ${LOGIN_NAME}@${TESTING_SERVER} "cd /var/www/tred/testbed && ln -sf ./tred-2-${SVN_VERSION}-${DISTRO}.noarch.rpm ./tred-${DISTRO}.rpm"
done

cd "$EXTDIR"
