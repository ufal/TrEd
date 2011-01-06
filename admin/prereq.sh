#!/bin/bash
# prerequisities for installing and releasing TrEd

EXTDIR=`dirname $(readlink -fen $0)`
. "$EXTDIR"/env.sh

# Tests whether a perl module is installed on the system and prints preport
function perl_module_presence_test {
    perl -M$1 -e 1 2> /dev/null;
    if [ "$?" -ne "0" ]; 
    then
        echo "Please install package '$1' from CPAN (e.g. perl -MCPAN -e 'install $1' or use your distro-specific way)";
	exit 1;
    else
        echo "$1 found, OK.";
    fi
}


# This funcition downloads current version of svn2cl script from web, 
# compares its MD5 sum to the MD5 sum found on the web and 
# unpacks it, if the MD5 sum is correct
function get_svn2cl {
	### svn2cl
	SVN2CL_URL="http://arthurdejong.org/svn2cl/"
	SVN2CL_FILE_DL="svn2cl.tar.gz"
	wget ${SVN2CL_URL}downloads.html -O web >> $LOG

	NEWEST_SVN2CL=`grep -o "svn2cl-[0-9.]\+tar.gz" web | head -n 1`
	wget -nv ${SVN2CL_URL}${NEWEST_SVN2CL} -O $SVN2CL_FILE_DL >> $LOG
	wget -nv ${SVN2CL_URL}${NEWEST_SVN2CL}.md5 -O ${SVN2CL_FILE_DL}.md5 >> $LOG

	SVN2CL_MD5_WEB=`cut -d ' ' -f 1 $SVN2CL_FILE_DL.md5`
	SVN2CL_MD5_LOCAL=`md5sum $SVN2CL_FILE_DL | cut -d ' ' -f 1`

	if [ "$SVN2CL_MD5_WEB" == "$SVN2CL_MD5_LOCAL" ]; then
		echo "MD5 sum ok, extracting svn2cl.."
		tar xvzf $SVN2CL_FILE_DL -C $ADMIN_DIR
		# remove the version of the svn2cl from dir name
		mv ${ADMIN_DIR}/svn2cl*/ ${ADMIN_DIR}/svn2cl
		echo "done"
	else
		echo "MD5 sum error, please download and unpack svn2cl to dir $ADMIN_DIR/svn2cl manually..."
		exit 1;
	fi
	rm $SVN2CL_FILE_DL
	rm -f web
	rm -f ${SVN2CL_FILE_DL}.md5
}

# This function downloads 7zip and unpacks it, if the MD5 sum of the downloaded
# package is correct
function get_7zExtra {
	### 7zExtra
	## hm, toto je trocha do kruhu... stahovanie 7z_extra, ktory musime rozbalit pomocou 7zipu
	SEVENZIP_URL="http://sourceforge.net/api/file/index/project-id/14481/mtime/desc/limit/20/rss"
	SEVENZIP_FILE="7z_extra.7z"
	wget -nv ${SEVENZIP_URL} -O web >> $LOG

	NEWEST_SEVENZIP=`grep -o "/.*_extra.7z" web | head -n 1`
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


perl_module_presence_test 'Pod::XML';
perl_module_presence_test 'XML::XSH2';
perl_module_presence_test 'XML::RSS';       #for changelog2rss script


if [ -x "$SVN_TO_CHANGELOG" ]; then
	echo "svn2cl found, OK."
else
	get_svn2cl
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
	echo "Please, fix your xsh2 link (UFAL: link a startup script, others: make a symlink xsh2 which will point to xsh)"
	     exit 1;
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
