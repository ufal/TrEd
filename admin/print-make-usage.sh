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
echo "  make testbed-status      - connect to testbed server and check its status"
echo "  make testbed-clear       - clear snapshots from the testbed after testing"
echo
echo
echo "Example: make release test publish   - a fast way how to create a new public TrEd release"
echo
echo "Notes:"
echo "  - It's better to check testbed status before every testing."
echo "  - It's polite to clear testbed after successful testing."
echo
