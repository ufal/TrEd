#!/bin/bash
# release-tred

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# run job-tred-release on ufal server
## $(LRC_CMD) qrsh -cwd $(LRC_CMD) --command make job-tred-release					## runs make job-tred-release on ufal servers
## make sync-www
echo "Releasing and installing TrEd..." && \
cd .. && \
make job-tred-release && \
make sync-www && \
echo "TrEd release and installation done."