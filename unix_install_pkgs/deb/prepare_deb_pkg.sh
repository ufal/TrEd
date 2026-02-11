#!/bin/bash

SAVE_DIR=`pwd`
cd `dirname "$0"` || exit 1

rm -f ./*.deb

GIT_DATE=`git log -1 --date=format:"%Y%m%d" --format="%ad"|tr -d "\n"`


# Prepare fresh checkout
echo "Export package config dir from GIT so we can work with it ..."
TRED_DEB_DIR="./tred-3.$GIT_DATE"
git -C ./tred-2.0 archive --output ../$TRED_DEB_DIR.zip  HEAD && \
unzip $TRED_DEB_DIR.zip -d  "$TRED_DEB_DIR" && \
rm $TRED_DEB_DIR.zip || exit 2


# Fix changelog
echo "Fix version and release date in the configuration ..."
DATE=`LC_TIME=en_US.UTF-8 date '+%a, %d %b %Y %T %z'`
sed -i "s/%GIT_DATE%/${GIT_DATE}/g" "$TRED_DEB_DIR/debian/changelog" || exit 3
sed -i "s/%DATE%/${DATE}/g" "$TRED_DEB_DIR/debian/changelog" || exit 3

# Build the package
echo "Build the deb package ..."
cd "$TRED_DEB_DIR" || exit 4
debuild --set-envvar=TREDNET=$TREDNET --set-envvar=TREDWWW=$TREDWWW -us -uc  || exit 4
cd .. || exit 4

# Cleanup
echo "Cleaning up ..."
rm -rf "$TRED_DEB_DIR"
cd "$SAVE_DIR"
