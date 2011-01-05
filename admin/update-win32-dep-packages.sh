#!/bin/bash
# Downloads ppm packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Updating win32 dependency packages" && \

cd $TRED_PPM_DIR && ./get_packages_tred_58.sh && \
cd $TRED_PPM_DIR && ./get_packages_tred_510.sh && \

echo "Updating win32 dependency packages done."
