#!/bin/bash

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

PERL_INSTALLER_DL=strawberry-perl.msi

WWW="$1"

function get_strawberry() {
        echo "Downloading Strawberry Perl $DESIRED_PERL_VERSION"
        wget "$DESIRED_PERL_URL" -O $PERL_INSTALLER_DL >> $LOG
}

if [ -z "$VER" ]; then
    VER=`$DIST_DIR/tred/devel/update_version.pl -n ${TRED_SVN_REPO}`
fi


# create NSIS installer for Windows, without Strawberry Perl
echo "Generate Nullsoft Installer for Windows (with Perl inculded)" && \
cd $TRED_STRAWBERRYPERL_DIR/perl && \
get_strawberry && \


cd $TRED_STRAWBERRYPERL_DIR
makensis tred-installer-perl-included.nsi && \
cp "tred-installer-perl-included.exe" "${WWW}/tred-installer-perl-included.exe" && \
# keep history of released versions in subdir releases
mkdir -p "${WWW}/releases/windows" 2>/dev/null && \
cp "tred-installer-perl-included.exe" "${WWW}/releases/windows/tred-installer-perl-included-${VER}.exe"  && \

rm -f perl/$PERL_INSTALLER_DL
