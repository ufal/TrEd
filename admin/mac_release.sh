#!/bin/bash

. env.sh

ssh $MAC_RELEASER <<EOF
	cd "$MAC_SVN_DIR/trunk/osx_install/scripts/make_release.sh" && ./make_release.sh
EOF