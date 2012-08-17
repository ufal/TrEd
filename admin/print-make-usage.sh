#!/bin/bash

EXTDIR=`diname $(readlink -fen $0)`
. $EXTDIR/env.sh


echo "You can:"
echo 
echo "  make install             - install TrEd and extensions into $(INSTALL_BASE)"
echo "  make release             - install + build distribution packages and upload to the testbed ($(REMOTE_WWW))"
echo "  make test                - connect to testing infrastructure and perform TrEd tests;"
echo "                             the TrEd must be already released to testbed ($(REMOTE_WWW))"
echo "  make publish             - upload TrEd release from testbed to its official web site"
echo 
echo "  make release-tred-qcmd   - like release but uses non-interactive SGE jobs rather than qrsh"
echo "  make update-dist-dir     - only update TrEd distribution tree in $(DIST_DIR)"
echo "  make update-dep-packages - fetch latest versions of required modules and libraries"
echo "  make release-dep-package - only release tred dependency package to remote server ($(REMOTE_WWW))"
echo "  make new-treex-pml       - create and install new Treex::PML packages"
echo 
echo "  make sync-www            - rsync WWW source tree with the testbed ($(REMOTE_WWW))"
echo 
echo "Example: make release test publish   - a fast way how to create a new public TrEd release"
echo
echo
