#!/bin/bash
# test-dep-packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# run job-test-packages on lrc
echo "Test dependency packages..." && \

# run make job-test-packages on ufal servers
## $LRC_CMD qrsh -cwd $LRC_CMD --command make job-test-packages && \

cd .. && \
make job-test-packages && \

echo "Testing of packages done."