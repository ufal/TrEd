#!/bin/bash
# Create changelog from git log

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh
. ${PYTHON_ENV}/bin/activate

echo "Generating changelog" && \
echo "Updating git..." && \
git pull >> $LOG && \
echo "done" && \
echo "Transforming git log --> ChangeLog (this takes a while)..." && \
cd ${TRED_SRC_DIR} && ${GIT_TO_CHANGELOG} > ChangeLog && \
echo "Done"
