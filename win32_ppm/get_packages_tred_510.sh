#!/bin/sh

UWINNIPEG="http://cpan.uwinnipeg.ca/PPMPackages/10xx/"
ACTIVESTATE="http://ppm4.activestate.com/MSWin32-x86/5.10/1000/"
TROUCHELLE="http://trouchelle.com/ppm10/"
BRIBES="http://www.bribes.org/perl/ppm"
UFAL="http://ufal.mff.cuni.cz/~pajas/ppms510"
# LOCAL="file:///home/pajas/projects/ppm/my-ap510"

REPOSITORY="$UFAL,$ACTIVESTATE,$UWINNIPEG,$TROUCHELLE,$BRIBES"

PLATFORM="MSWin32-x86-multi-thread-5.10"
PACKAGES_LIST=$PWD/../tred/devel/winsetup/packages_list_510
PACKAGES=`cat $PACKAGES_LIST |grep -v '^!'`

mkdir 510 2> /dev/null
cd 510
rm -f *.ppd *.zip *.tar.gz *.dll install_* *.zip *.[1-9]
xsh2 -al ../wgetppm.xsh "$PLATFORM" "$REPOSITORY" $PACKAGES

../fix_local_install

../make_repo_package_list "MSWin32-x86-multi-thread-5.10"

cp ../doc/README .
cp "$PACKAGES_LIST" packages_list
