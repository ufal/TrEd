#!/bin/bash

. env.sh

GIT_DATE=`git log -1 --date=format:"%Y%m%d" --format="%ad"|tr -d "\n"`

echo "Copying tred.dmg to local www"
scp $MAC_RELEASER:$MAC_TRED_INSTALLATION/tred.dmg "${TREDWWW}/tred/"

# keep history of released versions in subdir releases/osx
mkdir -p "${TREDWWW}/tred/releases/osx" 2>/dev/null
DMG_FILE="tred_3.${GIT_DATE}.dmg"
cp "${TREDWWW}/tred/tred.dmg" "${TREDWWW}/tred/releases/osx/$DMG_FILE"