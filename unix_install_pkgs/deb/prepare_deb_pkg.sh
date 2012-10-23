#!/bin/bash

SAVE_DIR=`pwd`
cd `dirname "$0"` || exit 1

SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`


# Prepare fresh checkout
TRED_DEB_DIR="./tred-2.$SVN_VERSION"
svn export ./tred-2.0 "$TRED_DEB_DIR" || exit 2

# Fix changelog
DATE=`date '+%a, %d %b %Y %T %z'`
sed -i "s/%SVN_VERSION%/${SVN_VERSION}/g" "$TRED_DEB_DIR/debian/changelog" || exit 3
sed -i "s/%DATE%/${DATE}/g" "$TRED_DEB_DIR/debian/changelog" || exit 3

# Build the package
debuild -us -uc || exit 4

# Cleanup
rm -rf "$TRED_DEB_DIR"
cd "$SAVE_DIR"
