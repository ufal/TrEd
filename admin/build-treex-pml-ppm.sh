#!/bin/bash
# Builds Treex::PML PPM packages

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "*** Packaging PPM distribution" && \
cd ${TREEX_PML_EXPORT} && \
rm -rf Treex-PML-*/ && \
tar xzf Treex-PML-*.tar.gz && \
cd Treex-PML-*/ && \
NO_COLONS_IN_FILENAMES=1 perl ./Build.PL && ./Build && ./Build ppd --codebase Treex-PML.tar.gz && \

## ak neexistuju adresare, vytvor 
##     mkdir ${PROJECT_DIR}/win32_ppm/
##     mkdir ${PROJECT_DIR}/win32_ppm/win32_build_script/
## checkoutni do adresara skript pre vyrobu ppm -- uz je ako externalita v svnku lokalnom
##     svn co $WIN32_DIST_REPO ${PROJECT_DIR}/win32_ppm/win32_build_script/
    
perl -I${PROJECT_DIR}/win32_ppm/win32_build_script -MBuildUtils -e 'update_ppd(shift)' Treex-PML && \
pwd && ls && \
tar czf Treex-PML.tar.gz blib/ && \
echo "*** Copying PPM distribution to ppm repositories ${WWW}/{ppms,ppms510}" && \
cat Treex-PML.ppd | sed 's/5\.8/5.10/' > Treex-PML.ppd.5.10 && \

# Create directories for ppm packages
mkdir "${WWW}/ppms" 2> /dev/null || true && \
mkdir "${WWW}/ppms510" 2> /dev/null || true && \

# Copy created packages to $WWW/ppms
cp Treex-PML.tar.gz Treex-PML.ppd ${WWW}/ppms && \
cp Treex-PML.tar.gz ${WWW}/ppms510 && \
cp Treex-PML.ppd.5.10 ${WWW}/ppms510/Treex-PML.ppd && \
(rm -f ${TRED_WININST_DIR}/packages58_win32/Treex-PML*; rm -f ${TRED_WININST_DIR}/packages510_win32/Treex-PML* || true) && \

# Create directories for packages in wininst dir
mkdir ${TRED_WININST_DIR} 2> /dev/null || true && \
mkdir ${TRED_WININST_DIR}/packages58_win32/ 2> /dev/null || true && \
mkdir ${TRED_WININST_DIR}/packages510_win32/ 2> /dev/null || true && \

mkdir ${TRED_PPM_DIR}/58/ 2> /dev/null || true && \
mkdir ${TRED_PPM_DIR}/510/ 2> /dev/null || true && \


cp Treex-PML.tar.gz Treex-PML.ppd ${TRED_WININST_DIR}/packages58_win32/ && \
cp Treex-PML.tar.gz ${TRED_WININST_DIR}/packages510_win32/ && \
cp Treex-PML.ppd.5.10 ${TRED_WININST_DIR}/packages510_win32/Treex-PML.ppd && \

# Create package list in project dir
(cd ${PROJECT_DIR}/win32_ppm/58; ../make_repo_package_list) && \
(cd ${PROJECT_DIR}/win32_ppm/510; ../make_repo_package_list "MSWin32-x86-multi-thread-5.10") && \

# Create package list in $WWW
cd ${WWW}/ppms && ${PROJECT_DIR}/win32_ppm/make_repo_package_list && \
cd ${WWW}/ppms510 && ${PROJECT_DIR}/win32_ppm/make_repo_package_list "MSWin32-x86-multi-thread-5.10" && \

(chmod -R gu+rwX ${WWW}/ppms* ${TRED_WININST_DIR}/packages58_win32/ ${TRED_WININST_DIR}/packages510_win32/ || true) && \

echo "*** Please:" && \
echo "***   - run 'make sync-www' to rsync PPM repositories to" ${REMOTE_WWW} && \
echo "***   - upload " Treex-PML/Treex-PML-*/Treex-PML-*.tar.gz " to CPAN (if needed)"