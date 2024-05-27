#!/bin/bash
# prerequisities for installing and releasing TrEd

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# Tests whether a perl module is installed on the system and prints preport
function perl_module_presence_test {
    perl -M$1 -e 1 2> /dev/null;
    if [ "$?" -ne "0" ];
    then
        echo "*** Please install package '$1' from CPAN (e.g. perl -MCPAN -e 'install $1' or use your distro-specific way)";
    else
        echo "$1 found, OK.";
    fi
}

# Tests whether a specific version of perl module is installed on the system and prints preport
function perl_module_presence_and_version_test {
    INSTALLED=`perl -M$1 -e "print \". Currently instaled version is \\${$1::VERSION}\";"  2> /dev/null`;
    perl -M$1 -e "die unless \$$1::VERSION eq '$2';"  2> /dev/null;
    if [ "$?" -ne "0" ];
    then
        echo "*** Please install package '$1' version '$2' from CPAN $3$INSTALLED";
    else
        echo "$1 v$2 found, OK.";
    fi
}

# This function downloads 7zip and unpacks it, if the MD5 sum of the downloaded
# package is correct
function get_7zExtra {
	### 7zExtra
	## hm, toto je trocha do kruhu... stahovanie 7z_extra, ktory musime rozbalit pomocou 7zipu
	SEVENZIP_URL="http://sourceforge.net/api/file/index/project-id/14481/mtime/desc/limit/20/rss"
	SEVENZIP_FILE="7z_extra.7z"
	wget -nv ${SEVENZIP_URL} -O web >> $LOG

	NEWEST_SEVENZIP=`grep -o "/.*-extra.7z" web | head -n 1`
	SEVENZIP_URL="http://sourceforge.net/projects/sevenzip/files${NEWEST_SEVENZIP}/download"
	wget -nv $SEVENZIP_URL -O $SEVENZIP_FILE >> $LOG

	SEVENZIP_MD5_LOCAL=`md5sum $SEVENZIP_FILE | cut -d ' ' -f 1`
	SEVENZIP_FILE_SIZE=`du -b $SEVENZIP_FILE | cut -f 1`
	SEVENZIP_MD5_WEB=`grep "$SEVENZIP_FILE_SIZE" web | grep -o 'md5">[0-9a-z]\+<' | cut -d '>' -f 2 | cut -d '<' -f 1`

	if [ "$SEVENZIP_MD5_WEB" == "$SEVENZIP_MD5_LOCAL" ]; then
		echo "MD5 sum ok, extracting 7zip.."
		7z x -o$ADMIN_DIR/7zExtra $SEVENZIP_FILE
		echo "done"
	else
		echo "MD5 sum error, please download and unpack 7zip extra manually to $ADMIN_DIR/7zExtra directory..."
		exit 1;
	fi
	rm $SEVENZIP_FILE
	rm -f web
}


NEEDED_MODULES="Archive::Extract DateTime::Locale parent Class::Load DateTime::TimeZone Class::Singleton Test::Exception DateTime Pod::XML XML::XSH2 XML::RSS File::ShareDir File::Which UNIVERSAL::DOES XML::CompactTree XML::LibXML XML::Writer XML::CompactTree::XS XML::LibXSLT version Pod::Xhtml CGI";
NEEDED_SPECIFIC_MODULES="MyCPAN::Indexer|1.28_10|or~http://backpan.perl.org/authors/id/B/BD/BDFOY/MyCPAN-Indexer-1.28_10.tar.gz MyCPAN::App::DPAN|1.281";
MODULES_PERL_SCRIPT="exit;";
MODULES_PERL_STR="";

# Check for all needed PERL modules
for MODULE in $NEEDED_MODULES
do
	perl_module_presence_test $MODULE;
	MODULES_PERL_STR="-M${MODULE} $MODULES_PERL_STR";
done

for MODULEVERSION in $NEEDED_SPECIFIC_MODULES
do
	MODULE=`echo $MODULEVERSION|cut -f1 -d'|'`;
	VERSION=`echo $MODULEVERSION|cut -f2 -d'|'`;
	NOTE=`echo $MODULEVERSION|cut -f3 -d'|'|tr '~' ' '`;
	perl_module_presence_and_version_test $MODULE $VERSION "$NOTE";
	MODULES_PERL_STR="-M${MODULE} $MODULES_PERL_STR";
	MODULES_PERL_SCRIPT="die unless \$$MODULE::VERSION eq '$VERSION'; $MODULES_PERL_SCRIPT";
done


# If any of the modules is missing, exit.
perl $MODULES_PERL_STR -e NEEDED_SPECIFIC_MODULES 2> /dev/null;
if [ "$?" -ne "0" ];
then
	echo "Please install required packages from CPAN.";
	echo "Note: You might need to configure your CPAN first, install new version of Module::Build and several libraries, namely:"
	echo "libxml2-dev, libxslt1-dev and zlib1g-dev, libgdbm-dev"
	exit 1;
else
	echo "All CPAN modules found, OK."
fi


if [ ! -x "$PYTHON_ENV/bin/activate" ]; then
	python -m venv ${PYTHON_ENV}
fi
. ${PYTHON_ENV}/bin/activate


if [ -x "$GIT_TO_CHANGELOG" ]; then
	echo "git-changelog found, OK."
else
	pip install git-changelog
fi

BIN_7Z=`which 7z`
if [ -x "$BIN_7Z" ]; then
	echo "7z found, OK."
else
	echo "Please, install 7z."
	     exit 1;
fi

if [ -d "$ADMIN_DIR/7zExtra" ]; then
	echo "7zExtra found, OK."
else
	get_7zExtra
fi

XSH2=`which xsh2`
if [ -x "$XSH2" ]; then
	echo "xsh2 found, OK."
else
	echo "Please, fix your xsh2 link (UFAL: link a startup script, others: make a symlink xsh2 which will point to xsh)."
	     exit 1;
fi

NSIS=`which makensis`
if [ -x "$NSIS" ]; then
	echo "makensis found, OK."
else
	echo "Please, install Nullsoft Scriptable Install System >= 2.46."
	     exit 1;
fi

NSIS_VERSION=`makensis -VERSION`
if [ $NSIS_VERSION \< "v2.46" ]; then
	echo "Please, install Nullsoft Scriptable Install System >= 2.46.";
else
	echo "NSIS version ok.";
fi;

XSLTPROC=`which xsltproc`
if [ -x "$XSLTPROC" ]; then
	echo "xsltproc found, OK."
else
	echo "Please, install xsltproc."
	     exit 1;
fi

# The debuild tool required for deb package creation
DEBUILD=`which debuild`
if [ -x "$DEBUILD" ]; then
	echo "debuild found, OK."
else
	echo "debuild is missing!"
	echo "please run 'apt-get install dpkg-dev debhelper devscripts fakeroot' ..."
	exit 1
fi

# The debuild tool required for deb package creation
RPMBUILD=`which rpmbuild`
if [ -x "$RPMBUILD" ]; then
	echo "rpmbuild found, OK."
else
	echo "rpmbuild is missing!"
	echo "please run 'apt-get install rpm' ..."
	exit 1
fi


## create or update Treex-PML directory
if [ -d "$TREEX_PML_DIR" ];then
	cd $TREEX_PML_DIR
	echo "Updating Treex::PML checkout directory"
	svn up >> $LOG
	echo "Done"
else
	echo "No directory for Treex::PML found, creating a new one and making a fresh checkout"
	mkdir $TREEX_PML_DIR 2>/dev/null
	svn co $TREEX_PML_REPO $TREEX_PML_DIR >> $LOG
	echo "Done"
fi

## create or update unix_install directory
if [ -d "$TRED_UNIXINST_DIR" ]; then
	cd $TRED_UNIXINST_DIR
	echo "Updating unix_install checkout directory"
	svn up >> $LOG
	echo "Done"
else
	echo "No directory unix_install found, creating a new one and making a fresh checkout"
	mkdir $TRED_UNIXINST_DIR 2>/dev/null
	svn co $TRED_SVN_REPO/devel/unix_install $TRED_UNIXINST_DIR >> $LOG
	echo "Done"
fi

