#!/bin/bash
# Installs Treex::PML on UFAL servers

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

echo "*** Unpacking CPAN distribution " && \
cd ${TREEX_PML_EXPORT} && \
rm -rf Treex-PML-*/ && \
tar xzf Treex-PML-*.tar.gz && \
echo "*** Building from clean CPAN distribution " && \
cd Treex-PML-*/ && \
## toto nejde na lokale
##. /net/work/projects/perl_repo/admin/bin/setup_platform && \
perl ./Build.PL && \
##$(/net/work/projects/perl_repo/admin/bin/perl_build_opts) && \
./Build && ./Build test && \
echo "*** Installing" && \
## toto potom odkomentuj, teraz to kvoli tomu zomrie...
# ./Build install &&  \ 
echo "*** Fixing permissions" && \
find $PERLNETREPO -user $USER -not -perm -g+w -print -exec chmod g+rwX '{}' '+' && \
echo "*** Installed on architecture ${arch}  - don't forget to run 'make install-treex-pml' the other one as" 'well!'
