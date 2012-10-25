#!/bin/bash
# Prepare TrEd web directory in $WWW

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Preparing TrEd web directory in $WWW" && \

# maybe putting documentation in its own directory would be nice...

mkdir -p "${WWW}/tred/documentation" && \
# remove old ar01*.html
rm -f ${WWW}/tred/documentation/ar01*.html && \
# copy documentation to $WWW/
cp -Rf ${TRED_DIST_DIR}/documentation/{*.html,*.css,pics} ${WWW}/tred/documentation && \
cp -Rf ${TRED_DIST_DIR}/documentation/index.html ${WWW}/tred/ && \

# copy refactoring documentation
mkdir -p "${WWW}/tred/documentation/refactoring" && \
cp -f ${TRED_DIST_DIR}/documentation/refactoring/TrEd_refactoring.pdf ${WWW}/tred/documentation/refactoring && \

##change urls in index.html to point to the directory of that index, should be changed when there is another place for TrEd
xsh2 -P ${WWW}/tred/index.html 'nobackups; rm //*[@class="offline"]; map :i { s{^TRED_HOME_URL/}{} } //@href;' && \

# Fix SVN version in links and text...
SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`
sed -i "s/\(SVN:VERSION)/$SVN_VERSION/g" ${WWW}/tred/index.html

##ATT if we want ActivePerl ppm packages
# we need to run win32_ppm/get_packages_tred_58 a get_packages_tred_510.sh before this is run
${ADMIN_DIR}/create_tred_packages.sh ${DIST_DIR} ${TRED_WININST_DIR} ${WWW}/tred && \
echo ${HOSTNAME} && \
# create RSS from ChangeLog
${CHANGELOG_TO_RSS} ${TRED_DIST_DIR}/ChangeLog > ${RSS} && \

echo "TrEd web directory preparation done."
