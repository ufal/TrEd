#!/bin/bash

. env.sh
ssh $MAC_RELEASER <<EOF
  rm -rf $MAC_TRED_INSTALLATION_OLD;
  mv $MAC_TRED_INSTALLATION $MAC_TRED_INSTALLATION_OLD || echo "no previous release to backup";
EOF