#!/bin/bash
# job-test-packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh


echo "Testing packages..." && \

rm -rf test_build && \
mkdir test_build && \
p=`pwd` && \
cd ${TRED_UNIXINST_DIR}/packages_unix && env NO_PREREQ=1 PERLLIB= PERL5LIB= LD_LIBRARY_PATH= ./install -b --prefix $p/test_build && \

echo "Package testing done."


