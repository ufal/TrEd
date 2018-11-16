#!/bin/bash

. env.sh

SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`

echo "Copying tred.dmg to local www"
scp $MAC_RELEASER:$MAC_TRED_INSTALLATION/tred.dmg "${TREDWWW}/tred/"

# keep history of released versions in subdir releases/osx
mkdir -p "${TREDWWW}/releases/osx" 2>/dev/null
DMG_FILE="tred_2.${SVN_VERSION}.dmg"
cp "${TREDWWW}/tred/tred.dmg" "${TREDWWW}/tred/releases/osx/$DMG_FILE"