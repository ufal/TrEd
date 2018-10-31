#!/bin/bash
# Update distrib directory of TrEd

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Updating distribution directory of TrEd" && \

if [ -e ${TRED_DIST_DIR}.new ]; then
	# directory does exist, which is not ok...
	echo "${TRED_DIST_DIR}.new already exists! Delete it..."
	exit 1;
fi && \

echo "Exporting svn" && \
svn export ${TRED_SVN_REPO} ${TRED_DIST_DIR}.new >> $LOG && \
# updates TrEd version in dist/tred.new/tredlib/TrEd/Version.pm according to svn version to 1.#svn_version#
${TRED_DIST_DIR}.new/devel/update_version.pl ${TRED_SVN_REPO} && \

echo "Updating extensions" && \
# perform pre-updates, update svn, then some post-updates for extension (currently only for tmt) according to extension/.make.d directory
${TRED_EXT_DIR}/update && \

cp ${TRED_SRC_DIR}/ChangeLog ${TRED_DIST_DIR}.new/ && \

echo "Creating manual pages and documentation" && \
# creates tredlib/TrEd/Help.pm
# creates documentation/pod/btred, ntred, contrib... .pod2
# creates documentation/manual/tred_cmd/def.xml
# creates documentation/man/*
# creates html files in documentation/
cd ${TRED_DIST_DIR}.new && devel/make_manual $TRED_HOME_URL && \

echo "Cleaning up" && \
chmod -R g+rwX ${TRED_DIST_DIR}.new && \
chmod a-w ${TRED_DIST_DIR}.new/tredlib/tredrc && \
# rename old tred dist dir to tred.old
if [ -e ${TRED_DIST_DIR} ]; then \
	mv ${TRED_DIST_DIR} ${TRED_DIST_DIR}.old; \
fi && \
mv ${TRED_DIST_DIR}.new ${TRED_DIST_DIR} && \
# remove old tred dist dir
if [ -e ${TRED_DIST_DIR}.old ]; then \
	chmod u+w -R ${TRED_DIST_DIR}.old; \
	rm -rf ${TRED_DIST_DIR}.old; \
fi && \

echo "Updating distrib directory done"
