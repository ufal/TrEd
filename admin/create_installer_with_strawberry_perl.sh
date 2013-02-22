#!/bin/bash

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

PERL_URL=http://strawberryperl.com/
PERL_INSTALLER_DL=strawberry-perl.msi

WWW="$1"

function get_strawberry() {
	rm -f web
	wget "$PERL_URL"releases.html -O web >> $LOG
	
	PERL_LINK_REGEXP=download/"$DESIRED_PERL_VERSION"'\..*[0-9]\.msi'
	
	DESIRED_PERL_INSTALLER=`grep -o $PERL_LINK_REGEXP web | head -n 1`
	echo "Downloading Strawberry Perl $DESIRED_PERL_VERSION"
	wget "$PERL_URL$DESIRED_PERL_INSTALLER" -O $PERL_INSTALLER_DL >> $LOG
	
	rm -f web
	
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

