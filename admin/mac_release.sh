#!/bin/bash

SIGNATURE=$1

. env.sh

ssh $MAC_RELEASER <<EOF
    . ~/.bash_profile
    echo "======== perl version"
    perlbrew info
    echo "========"
	cd $MAC_SVN_DIR/trunk/osx_install/scripts && ./make-release.sh $SIGNATURE
EOF
