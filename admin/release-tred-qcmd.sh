#!/bin/bash
# release-tred-qcmd

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# run job-tred-release on ufal server using qcmd
echo "Releasing TrEd using qcmd..."

${LRC_CMD} ${ADMIN_DIR}/qcmd ${LRC_CMD} --command make job-tred-release && \
${LRC_CMD} ${ADMIN_DIR}/qtop && \
less make.[eo]* && \
make sync-www && \
rm make.[eo]* && \

echo "TrEd release done."