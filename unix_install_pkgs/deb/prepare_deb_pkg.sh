#!/bin/bash

SAVE_DIR=`pwd`
cd `dirname "$0"` || exit 1

rm -f ./*.deb

SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`


# Prepare fresh checkout
echo "Export package config dir from SVN so we can work with it ..."
TRED_DEB_DIR="./tred-2.$SVN_VERSION"
svn export ./tred-2.0 "$TRED_DEB_DIR" || exit 2

# Fix changelog
echo "Fix version and release date in the configuration ..."
DATE=`LC_TIME=en_US.UTF-8 date '+%a, %d %b %Y %T %z'`
sed -i "s/%SVN_VERSION%/${SVN_VERSION}/g" "$TRED_DEB_DIR/debian/changelog" || exit 3
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
