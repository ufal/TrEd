#!/bin/bash

. env.sh
ssh $MAC_RELEASER <<EOF
	mkdir $MAC_TRED_INSTALLATION
EOF
scp ${WWW}/tred/install_tred.bash $MAC_RELEASER:$MAC_TRED_INSTALLATION
scp ${WWW}/tred/tred-current.tar.gz $MAC_RELEASER:$MAC_TRED_INSTALLATION
ssh $MAC_RELEASER <<EOF
	pwd
	cd TrEd && svn update || exho "Unable to update repository. Do it manually if needed!!!\nContinues without repository updated.\n"
EOF