#!/bin/bash
# installs TrEd on to $INSTALL_BASE

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Installing TrEd to $INSTALL_BASE"

echo "Creating sandbox"
# Create dirs if they do not already exist
mkdir $INSTALL_LIB 2> /dev/null
mkdir $INSTALL_DOC 2> /dev/null
mkdir $INSTALL_SHARE 2> /dev/null
mkdir $INSTALL_BIN 2> /dev/null

# Remove old directories and prepare tred.new subdirectories in install paths
for d in ${INSTALL_LIB} ${INSTALL_DOC} ${INSTALL_SHARE}; do \
	test ! -d $d/tred.new/ || rm -rf $d/tred.new; \
	test ! -d $d/tred.old/ || rm -rf $d/tred.old; \
	mkdir $d/tred.new; \
done

echo "Copy libraries to $INSTALL_LIB"
# Copy TrEd libraries to $INSTALL_LIB
# Copy contents of tred/tredlib to install_dir/tred.new
cp -R ${TRED_DIST_DIR}/tredlib/* ${INSTALL_LIB}/tred.new/ && \
chmod -R g+rwX ${INSTALL_LIB}/tred.new/ && \
chmod a-w ${INSTALL_LIB}/tred.new/tredrc && \

echo "Copy documentation to $INSTALL_DOC"
# Copy documentation and examples to $INSTALL_DOC
cp -R ${TRED_DIST_DIR}/documentation/* ${INSTALL_DOC}/tred.new/ && \
cp -R ${TRED_DIST_DIR}/examples ${INSTALL_DOC}/tred.new/ && \
cp -R ${TRED_DIST_DIR}/ChangeLog ${TRED_DIST_DIR}/README ${INSTALL_DOC}/tred.new/ && \
chmod -R g+rwX ${INSTALL_DOC}/tred.new/ && \

# Remove temporary files and version system files
# Remove (svn and cvs) versioning meta-information from install_dir/doc/tred.new (leaving the directories)
cd ${INSTALL_DOC}/tred.new/ && rm -rf `find . | grep '/CVS/'`; rm -rf `find . | grep '/\.svn/'` && \
# Remove temporary files ending with '~' or starting with '#'
find ${INSTALL_LIB}/tred.new ${INSTALL_DOC}/tred.new '(' -name '*~' -or -name '*#*' ')' -exec rm -f '{}' ';' && \

echo "Copy resources to $INSTALL_SHARE"
# Copy resources to $INSTALL_SHARE
cp ${TRED_DIST_DIR}/resources/* ${INSTALL_SHARE}/tred.new/ && \
chmod -R g+rwX ${INSTALL_SHARE}/tred.new/ && \

echo "Copy executables to $INSTALL_BIN" && \
## copy executables to $INSTALL_BIN
cp ${TRED_DIST_DIR}/tred ${TRED_DIST_DIR}/btred ${TRED_DIST_DIR}/ntred ${TRED_DIST_DIR}/jtred ${TRED_DIST_DIR}/any2any ${TRED_DIST_DIR}/examples/fsdiff.pl ${INSTALL_BIN}  && \

echo "Install TrEd from sandbox"
# Rename current /tred dir from install_dir/lib, /doc and /share to tred.old directories
for d in ${INSTALL_LIB} ${INSTALL_DOC} ${INSTALL_SHARE}; do \
	test ! -d $d/tred/ || mv $d/tred $d/tred.old; \
	mv $d/tred.new $d/tred; \
done && \

echo "Clean up the sandbox"
# Remove tred.old directories from ${INSTALL_LIB}, ${INSTALL_DOC}, ${INSTALL_SHARE}
for d in ${INSTALL_LIB} ${INSTALL_DOC} ${INSTALL_SHARE}; do \
	test ! -d $d/tred.old/ || rm -rf $d/tred.old; \
done

echo "Installing TrEd done."