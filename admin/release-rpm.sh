#!/bin/bash

# Prepare deb package and upload it to testbed website.
# The core release must be made first, so the install_tred.bash script is ready.

EXTDIR=`dirname $(readlink -fen $0)`
. $EXTDIR/env.sh

GIT_DATE=`git log -1 --date=format:"%Y%m%d" --format="%ad"|tr -d "\n"`

# Prepare the deb package
cd "$PROJECT_DIR/unix_install_pkgs/rpm" || exit 1
./prepare_rpm_pkg.sh || exit 2

# Copying the package to the local www
echo "Copying the package to local www ..."
ls -1 ./tred*.rpm | while read FILE; do
	cp "$FILE" "${TREDWWW}/tred/$FILE"
done

echo "Creating symlinks for rpm packages ..."
DISTROS=`ls -1 ./tred*.rpm | sed -E 's/^.*tred-[0-9]+-[0-9]+-//' | sed 's/[.]noarch[.]rpm$//' | tr "\\n" " "`
for DISTRO in $DISTROS; do
	echo "... for $DISTRO ..."
	d=`pwd`
	cd "${TREDWWW}/tred/"
	ln -sfr "tred-3-${GIT_DATE}-${DISTRO}.noarch.rpm" "tred-${DISTRO}.rpm"
	cd $d
done

test $TREDNET -eq 1  || exit 0
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
	ssh ${LOGIN_NAME}@${TESTING_SERVER} "cd /var/www/tred/testbed && ln -sf ./tred-3-${GIT_DATE}-${DISTRO}.noarch.rpm ./tred-${DISTRO}.rpm"
done

cd "$EXTDIR"
