#!/bin/bash

SIGNATURE=$1

. env.sh

ssh $MAC_RELEASER <<EOF
  . ~/perl5/perlbrew/etc/bashrc
  echo "======== perl version"
  perlbrew info
  echo "========"
	cd ${MAC_GIT_DIR}/osx_install/scripts && ./make-release.sh $SIGNATURE
EOF
