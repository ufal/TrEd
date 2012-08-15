#!/bin/bash

SAVE_DIR=`pwd`
cd `dirname $0` || exit 1

. .config


# Get Login Name
#echo "Uploading $RELEASE_FILE to $UPLOAD_DEST ..."
#echo -n "Login: "; read LOGIN
#if [ -z "$LOGIN" ]; then
#    echo "Login name is empty!"
#    exit 1
#fi


# Upload
echo "Uploading $RELEASE_FILE to $UPLOAD_DEST ..."
scp "$RELEASE_FILE" "$UPLOAD_DEST"


# Cleanup
cd "$SAVE_DIR"
