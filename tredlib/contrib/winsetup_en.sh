#!/bin/bash
if [ "$OSTYPE" != "cygwin" ]; then 
  echo "This program may only be used to install TrEd in MS Windows environment."
  echo "Read the documentation to get install instructions for other systems."
fi

PATH=.:`pwd`/bin:${PATH}
PERLVERSION="This is perl, v5.6.1 built for MSWin32-x86-multi-thread"

function ask {
  answer=""
  until [ "$answer" = 'y' -o "$answer" = 'n' ]; do       
    read -e -n1 -r -p "$1 [y/n]?" answer 
  done
  if [ "$answer" = 'y' ]; then
    return 0
  else
    return 1  
  fi
}

function mkplbat {
  PERLBIN=`echo "$PERLBIN" | sed 's!^/cygdrive/\(.\)!\1:!' | sed -e 's!/!\\\\\\\\!g'`
  sed "s!_PERLBIN_!$PERLBIN!" < bat | sed "s!_CMD_!${TREDDIR}/$1!g" | sed "s!_TREDDIR_!${TREDDIR}!g" > "${TREDDIR}/$1.bat"
  return $?
}

function findperlbin {
  PERLBIN=`which perl 2>/dev/null`
  if [ -z $PERLBIN ]; then
    PERLBIN=`regtool get '\machine\Software\Perl\BinDir' 2>/dev/null`"/perl.exe"
    if [ ! -x $PERLBIN ]; then
      for d in c d e f g; do 
        if [ -x ${d}:/perl/bin/perl.exe ]; then
          PERLBIN=${d}:/perl/bin/perl.exe
	  return 0
        fi
      done
    fi
  fi
}

function dosdirname {
  dirname=$1
  dosdirname=${dirname#/cygdrive/}
  if [ ${dirname} != ${dosdirname} ]; then
    dosdirname=${dosdirname/\//:/}
  fi
  echo $dosdirname
}

function findtreddir {
    TREDDIR=`regtool get '\machine\Software\TrEd\Dir' 2>/dev/null`
    INSTTRED=`dosdirname ${PWD}/tred`
    if [ ! -f "${TREDDIR}/tred" ]; then
      for d in c d e f g; do 
        if [ -f ${d}:/tred/tred -a ! ${d}:/tred -ef "$INSTTRED" ]; then
          TREDDIR=${d}:/tred
          return 0
        fi
      done
    fi
}

function perl_version_current {
  INSTVER=`$PERLBIN --version | grep "This is perl."`
  echo $INSTVER
  if [ "$INSTVER" = "$PERLVERSION" ]; then
    return 0
  else 
    return 1
  fi
}

function test_version {
  return `$PERLBIN -e "print ($1 > $2) ? 1 : 0"`
}

function get_version {
  echo `$PPM $* | grep "\[[0-9.]*\]" | sed 's/^.*\[\([0-9.]*\).*$\]/\1/g'`
}

function upgrade_packages {
  for s in $*; do 
    echo
    echo Checking package $s
    QUERY=`$PPM query "^$s\$"`
    if [ -n "$QUERY" ]; then
      $PPM verify --location=packages --upgrade "$s"
    else
      install_packages $s
      echo $s installed.
      echo
    fi
  done
}

function install_packages {
  $PPM install --location=packages $*
}

function upgrade_perl {
  PERLINSTALLDIR=${PERLDIR%/BIN}
  PERLINSTALLDIR=${PERLINSTALLDIR%/bin}
  echo Removing $PERLINSTALLDIR

  $PERLBIN uninst_p500.pl $DOSPERLDIR/p_uninst.dat

  read -e -n1 -r -p "Stisknete libovolnou klavesu pro pokracovani..."

  rm -rf $PERLINSTALLDIR
  echo 
  echo Old version of Perl removed
  install_perl
}

function get_perl_install_dir {
  read -e -p "Zadejte cilovy adresar [c:/perl]: " PERLINSTALLDIR
  if [ -z $PERLINSTALLDIR ]; then
    PERLINSTALLDIR="c:/perl"
  fi
}

function install_perl {
#    APi522e.exe
  test -d "$PERLINSTALLDIR" || mkdir "$PERLINSTALLDIR"
  DIR=$PWD
  echo Extracting package "$DIR/win32_perl/perl561.tgz"
  (cd "$PERLINSTALLDIR" &&\
  tar -xzf "$DIR/win32_perl/perl561.tgz" &&\
  echo "Starting ActiveState Perl installation script"
  "$PERLINSTALLDIR/install.bat") || \
  (echo; echo Unknown error occured during Perl installation!; exit 1)
#  install_packages Tk XML::DOM Text::Iconv
}

echo
echo "-------------------------------------------------------------------------------"
echo
echo This is TrEd installer
ask "Do you want to continue" || exit 0

echo
findperlbin
until [ -n "$PERLBIN" -a  -f "$PERLBIN" -a -x "$PERLBIN" ] && ask "Shell I use perl from $PERLBIN"; do
  echo "No usable perl executable was found on this computer."
  echo "You may continue with automatic installation"
  echo "of ActiveState perl or you may give a valid path"
  echo "to perl executable manually."
  echo
  if ask "Do you want to install ActiveState perl now?"; then
    get_perl_install_dir
    install_perl
#    findperlbin
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else  
    read -e -p "Path to perl binary executable: " PERLBIN
  fi
done

PERLDIR=`dirname $PERLBIN 2>/dev/null`
DOSPERLDIR=`dosdirname $PERLDIR`
PPM="$PERLBIN $DOSPERLDIR/ppm"


echo Checking Perl version.

if perl_version_current; then
  echo Ok.
else 
  echo
  echo TrEd requires different version of perl.
  if ask "Do you wish to upgrade?"; then
    upgrade_perl
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else
    if ask "Continue the installation anyway?"; then
     echo 
     echo "Forced to continue."
     echo "WARNING: Some parts may not work as expected!!"
    else 
     exit 1
    fi
  fi
fi

upgrade_packages Tk Text::Iconv XML::SAX XML::LibXML Tie::IxHash
  
findtreddir

if [ -n "$TREDDIR" -a  -x "$TREDDIR/tred" ]; then
  echo
  echo "TrEd is already installed in $TREDDIR"
  if ask "Do you want to upgrade this installation?"; then
    UPGRADE=1
    if ask "Do you wish the configuration file to be preserved?"; then
      test -f "$TREDDIR/tredlib/tredrc" && \
        mv "$TREDDIR/tredlib/tredrc" "$TREDDIR/tredlib/tredrc.sav"
    else
      rm -f "$TREDDIR/tredlib/tredrc.sav"
    fi  
  else
    echo
    ask "Do you wish to install TrEd to a different directory" || exit 0
    if [ "$OSTYPE" = "cygwin" ]; then
      TREDDIR="c:/tred"
    else 
      TREDDIR="$HOME/tred"
    fi    
    read -e -p "Please, enter the directory name [default: $TREDDIR]: " DIR
    test -z $DIR || TREDDIR=$DIR
  fi
else 
  echo
  ask "Do yo want to install TrEd" || exit 0
  if [ "$OSTYPE" = "cygwin" ]; then
    TREDDIR="c:/tred"
  else 
    TREDDIR="$HOME/tred"
  fi    
  read -e -p "Please, enter path to the destination directory [default $TREDDIR]: " DIR
  test -z $DIR || TREDDIR=$DIR
fi

if [ $OSTYPE = "cygwin" ]; then
  STARTW="start /W"
else
  STATRW=""
fi

echo
echo "Copying TrEd to $TREDDIR"
if ((test -d "${TREDDIR}" || mkdir "${TREDDIR}") && \
    cp -R tred/* "${TREDDIR}"             && \
    cp tred.mac "${TREDDIR}/tredlib"      && \
    mkplbat tred                          && \
    mkplbat btred                         && \
    mkplbat trprint                       && \
    mkplbat any2any); then 
    
    if (test -d "${TREDDIR}/bin" || mkdir "${TREDDIR}/bin"); then
      cp bin/prfile32.exe bin/*.dll bin/gunzip.exe bin/gzip.exe bin/zcat.exe "${TREDDIR}/bin"
    else 
      echo "Cannot create" "${TREDDIR}/bin" "!"
    fi
    test "x$UPGRADE" = "x1" -a -f "${TREDDIR}/tredlib/tredrc.sav" && \
     mv "${TREDDIR}/tredlib/tredrc.sav" "${TREDDIR}/tredlib/tredrc";
    test "x$UPGRADE" != "x1" && "$PERLBIN" trinstall.pl

    echo "Creating Windows registry entry for TrEd"
    regtool add "\\machine\\Software\\TrEd"
    regtool -s set "\\machine\\Software\\TrEd\\Dir" "$TREDDIR" 
    echo
    echo "Installation process successfull. Your desktop should now"
    echo "contain an icon of a weird cat :)"
    echo
else
  echo
  echo "Unexpected error occurred during installation."
  echo
fi
