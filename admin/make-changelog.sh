#!/bin/bash
# Create changelog from svn log

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh
. ${PYTHON_ENV}/bin/activate

echo "Generating changelog" && \
echo "Updating git..." && \
git pull >> $LOG && \
echo "done" && \

# find the current revision number of svn
# LAST_COMMIT_NO=`svn info ${TRED_SRC_DIR} | grep "Revision:" | cut -d ':' -f 2 | cut -d ' ' -f 2` && \
# 
# if [ -a ${TRED_SRC_DIR}/ChangeLog ]; then
# 	# if ChangeLog exists, we should update it only if it does not already contain the last revision
# 	LAST_COMMIT_IN_CHANGELOG=`grep -c "r$LAST_COMMIT_NO" ${TRED_SRC_DIR}/ChangeLog`
# else
# 	# if ChangeLog does not exist, it needs to be created
# 	LAST_COMMIT_IN_CHANGELOG=0
# fi && \

## echo "LAST_COMMIT_NO = $LAST_COMMIT_NO"
## echo "LAST_COMMIT_IN_CHANGELOG = $LAST_COMMIT_IN_CHANGELOG"

# if [ "$LAST_COMMIT_IN_CHANGELOG" == 0 ]; then
	echo "Transforming git log --> ChangeLog (this takes a while)..." && \
	cd ${TRED_SRC_DIR} && ${GIT_TO_CHANGELOG} > ChangeLog && \
# else
# 	echo "ChangeLog is already up to date."
# fi && \
echo "Done"
