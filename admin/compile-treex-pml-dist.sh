#!/bin/bash
# compiles Treex::PML library

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Compiling Treex::PML library"

echo "*** Updating from SVN" && \
# If there is any change in local Treex_PML checkout, let the user decide what to do with it...
! ( svn status $TREEX_PML_DIR | cat | grep -q '^[MAC]')
if [ $? -ne 0 ]; then
	echo "Please, review your changes in $TREEX_PML_DIR first, so the svn rep is clean (no conflicts, modifications or additions)"
	exit 1;
fi && \

echo "*** Exporting from SVN to" ${TREEX_PML_EXPORT} && \
(rm -rf ${TREEX_PML_EXPORT} || true )&& \
svn export $TREEX_PML_REPO ${TREEX_PML_EXPORT} >> $LOG && \
cd ${TREEX_PML_EXPORT} && \
echo "*** Updating Version info in all modules" && \
perl ./Build.PL && ./Build version && \
echo "*** Building" && \
perl ./Build.PL && ./Build && ./Build test && \
echo "*** Packaging CPAN distribution" && \
./Build dist && ./Build disttest && \
echo "*** Copying CPAN distribution to" ${TRED_UNIXINST_DIR}/packages_unix/packages && \

# Create directories for packages
(mkdir ${TRED_UNIXINST_DIR}/packages_unix/ 2>/dev/null || true) && \
(mkdir ${TRED_UNIXINST_DIR}/packages_unix/packages/ 2>/dev/null || true) && \

(rm -f ${TRED_UNIXINST_DIR}/packages_unix/packages/Treex-PML-*.tar.gz || true) && \
cp Treex-PML-*.tar.gz ${TRED_UNIXINST_DIR}/packages_unix/packages && \
(chmod -R gu+rwX ${TRED_UNIXINST_DIR}/packages_unix/packages || true) && \
chmod -R gu+rwX ${TREEX_PML_EXPORT} && \

echo "Compiling Treex::PML library done."