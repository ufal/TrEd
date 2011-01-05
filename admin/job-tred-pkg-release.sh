#!/bin/bash
# job-tred-pkg-release

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# run job-tred-pkg-release on ufal server using qrsh
echo "TrEd pkg release..." && \

## $LRC_CMD qrsh -cwd $LRC_CMD --command make job-tred-pkg-no-release && \
cd .. && \
make job-tred-pkg-no-release && \

echo "TrEd pkg release done."