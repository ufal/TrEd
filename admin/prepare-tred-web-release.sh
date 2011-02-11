#!/bin/bash
# Prepare TrEd web directory in $WWW

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "Preparing TrEd web directory in $WWW" && \

     
##TODO mozno neskor prerobit na tred.new a ten nakoniec premenovat, aby sme si nezmazali web?

# remove old ar01*.html
rm -f ${WWW}/tred/ar01*.html && \
# copy documentation to $WWW/
cp -Rf ${TRED_DIST_DIR}/documentation/{*.html,*.css,pics} ${WWW}/tred/ && \
##TODO comment!
xsh2 -P ${WWW}/tred/index.html 'nobackups; rm //*[@class="offline"]; map :i { s{^http://ufal.mff.cuni.cz/~pajas/tred/}{./} } //@href;' && \

##ATT we need to run win32_ppm/get_packages_tred_58 a get_packages_tred_510.sh before this is run
${ADMIN_DIR}/create_tred_packages.sh ${DIST_DIR} ${TRED_WININST_DIR} ${WWW}/tred && \
echo ${HOSTNAME} && \
# create RSS from ChangeLog
${CHANGELOG_TO_RSS} ${TRED_DIST_DIR}/ChangeLog > ${RSS} && \

echo "TrEd web directory preparation done."