#!/bin/bash
# sync-www

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

LOGIN_NAME=tred
#echo -n "Login name for $REMOTE_WWW:"; read LOGIN_NAME
#if [ -z "${LOGIN_NAME}" ]; then
#    echo "Empty login name provided! Aborting ..."
#    exit
#fi

#echo -n "Press RETURN to start upload to ${LOGIN_NAME}@${REMOTE_WWW}..."; read enter
echo "Uploading TrEd to ${LOGIN_NAME}@${REMOTE_WWW}..."; read enter

rsync -aHlzv --rsh=ssh --chmod=Dug+rwx,o+r,Fug+rwX,o+rX  "${WWW}/tred/" "${LOGIN_NAME}@${REMOTE_WWW}/"
