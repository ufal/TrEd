#!/bin/bash
# sync-www

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo -n "Press RETURN to start upload to $REMOTE_WWW..."; read enter
rsync -aHlzv --chmod=Dug+rwx,o+r,Fug+rwX,o+rX  "${WWW}/tred" ${REMOTE_WWW}/