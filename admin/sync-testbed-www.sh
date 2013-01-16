#!/bin/bash
# sync-www

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

LOGIN_NAME=tred
echo "Uploading TrEd to ${LOGIN_NAME}@${REMOTE_WWW}..."
rsync -aHlzv --rsh=ssh --exclude '*~' --chmod=Dug+rwx,o+r,Fug+rwX,o+rX  "${WWW}/tred/" "${LOGIN_NAME}@${REMOTE_WWW}/"
