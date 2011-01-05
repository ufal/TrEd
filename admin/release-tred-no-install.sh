#!/bin/bash
# release-tred-no-install

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# run job-tred-release-no-install on ufal server
echo "Releasing TrEd without installing it..." && \

## $LRC_CMD qrsh -cwd $LRC_CMD --command make job-tred-release-no-install && \

cd .. && \
make job-tred-release-no-install && \

echo "TrEd release done."
