#!/bin/sh

UWINNIPEG="http://theoryx5.uwinnipeg.ca/ppms"
ACTIVESTATE="http://ppm4.activestate.com/MSWin32-x86/5.8/822"
TCOOL="http://ppm.tcool.org/archives"
BRIBES="http://www.bribes.org/perl/ppm"
TROUCHELLE="http://trouchelle.com/ppm/"
UFAL="http://ufal.mff.cuni.cz/~pajas/ppms"
# LOCAL="file:///home/pajas/projects/ppm/ppm.activestate.com/PPMPackages/zips/8xx-builds-only/Windows"

REPOSITORY="$UFAL,$ACTIVESTATE,$BRIBES,$TCOOL,$UWINNIPEG,$TROUCHELLE"

PLATFORM="MSWin32-x86-multi-thread-5.8"
PACKAGES_LIST=$PWD/../tred/devel/winsetup/packages_list_58
PACKAGES=`cat $PACKAGES_LIST |grep -v '^!'`

cd 58
rm -f *.ppd *.tar.gz *.dll install_* *.zip *.[1-9]
xsh2 -al ../wgetppm.xsh "$PLATFORM" "$REPOSITORY" $PACKAGES

../fix_local_install

../make_repo_package_list

cp ../doc/README .
cp "$PACKAGES_LIST" packages_list
rm *~
