#!/bin/bash

#
# This is a TrEd and ActivePerl installer for Windows
# (intended for use with cygwin bash)
#

# usage: winsetup.sh [-l en|cz] [-p 6|8] [-t] [-r]
# or
# winsetup.sh -h

PATH=.:`pwd`/bin:${PATH}

function debug {
  echo $@
}

INSTLANG=en
INSTPERLVER=8
TREDRC=""

while getopts "l:p:tr:h" o; do
  case "$o" in
     l) INSTLANG="$OPTARG" ;;
     p) INSTPERLVER="$OPTARG" ;;
     t) PACKAGES58="Tk $PACKAGES58" ;;
     r) TREDRC="$OPTARG" ;;
     h) cat <<EOF ;;
usage: winsetup.sh [-l en|cz] [-p 6|8] [-t] [-r tredrc]
       -l language
       -p perl5 sub-version
       -t force Tk804 for perl 5.8
       -r use given file as the default tredrc
or
       winsetup.sh -h for this help
EOF
  esac
done


. "winsetup_${INSTLANG}.msg" || exit 1

if [ "$INSTPERLVER" = 6 ]; then
  REQPERLVER="[68]"
  REQPERLINSTDIR=win32_perl56
  packages_ap56=packages56_win32
  PACKAGES56="$PACKAGES56 $(cat $packages_ap56/packages_list | sed s/-/::/)"
else
  packages_ap58=packages58_win32
  PACKAGES58="$PACKAGES58 $(cat $packages_ap58/packages_list | sed s/-/::/)"
  REQPERLVER="8\.[3-9]|9|1[0-9]"
  REQPERLINSTDIR=win32_perl58
fi

if [ "$OSTYPE" != "cygwin" ]; then 
  echo $MSG000
  echo $MSG001
fi

function ask {
  answer=""
  until [ "$answer" = $MSGYES -o "$answer" = $MSGNO ]; do       
    read -e -n1 -r -p "$1 [$MSGYES/$MSGNO]?" answer 
  done
  if [ "$answer" = $MSGYES ]; then
    return 0
  else
    return 1  
  fi
}

function mkplbat {
  PERLBIN=`echo "$PERLBIN" | sed 's,^/cygdrive/\(.\),\1:,' | sed -e 's,/,\\\\\\\\,g'`
  DOSTREDDIR=`echo "$TREDDIR" | sed 's,^/cygdrive/\(.\),\1:,' | sed -e 's,/,\\\\\\\\,g'`
  sed "s,_PERLBIN_,$PERLBIN,g" < bat | sed "s,_CMD_,${TREDDIR}/$1,g" | sed "s,_TREDDIR_,${DOSTREDDIR},g" > "${TREDDIR}/$1.bat"
  return $?
}

function findperlbin {
  PERLBIN=`which perl 2>/dev/null`
  if [ ! -z "$PERLBIN" ]; then
      "$PERLBIN" -v | grep -q 'MSWin32';
      if [ $? != 0 ]; then
	  PERLBIN=""
      fi
  fi
  if [ -z "$PERLBIN" ]; then
    PERLBIN=`regtool get '\machine\Software\Perl\BinDir' 2>/dev/null`"/perl.exe"
    if [ ! -x "$PERLBIN" ]; then
      for d in c d e f g; do 
        if [ -x "${d}:/perl/bin/perl.exe" ]; then
          PERLBIN="${d}:/perl/bin/perl.exe"
	  return 0
        fi
      done
    fi
  fi
}

function dosdirname {
  dirname="$1"
  dosdirname="${dirname#/cygdrive/}"
  if [ "$dirname" != "$dosdirname" ]; then
    dosdirname="${dosdirname/\//:/}"
  fi
  echo "$dosdirname"
}

function cygdirname {
  dirname="$1"
  if ! echo "$dirname" | grep -q '^/cygdrive/'; then
    cygdirname="/cygdrive/${dirname}";
    cygdirname="${cygdirname/://}"
  else
    cygdirname="$dirname";
  fi
  echo "$cygdirname"
}



function findtreddir {
    TREDDIR=`regtool get '\machine\Software\TrEd\Dir' 2>/dev/null`
    INSTTRED=`dosdirname ${PWD}/tred`
    if [ ! -f "${TREDDIR}/tred" ]; then
      for d in c d e f g; do 
        if [ -f "${d}:/tred/tred" -a ! "${d}:/tred" -ef "$INSTTRED" ]; then
          TREDDIR="${d}:/tred"
          return 0
        fi
      done
    fi
}

function perl_version_current {
  INSTVER=`"$PERLBIN" --version | grep "This is perl,"`
  echo "$INSTVER"
  if "$PERLBIN" --version | grep -E 'This is perl, v5\.'"(${REQPERLVER})"; then
    return 0
  else 
    return 1
  fi
}

function test_version {
  return `$PERLBIN -e "print ($1 > $2) ? 1 : 0"`
}

function get_version {
  echo `"$PPM" $* | grep "\[[0-9.]*\]" | sed 's/^.*\[\([0-9.]*\).*$\]/\1/g'`
}

function upgrade_packages {
  if "$PERLBIN" --version | grep -q 'This is perl.* v5\.6'; then
      for s in $PACKAGES56; do 
	echo
	echo $MSG002 $s
	QUERY=`"$PPM" query "^$s\$"`
	if [ -n "$QUERY" ]; then
	  "$PPM" verify --location="$packages_ap56" --upgrade "$s"
	else
	  install_packages "$s"
	  echo
	fi
      done
  else
      echo $MSG003
      "$PPM" rep del tredsetup 2>/dev/null >/dev/null
      "$PPM" rep
      REPS="$($PPM rep | grep -E '^\[[0-9]+\]')"
      REPS=`echo "$REPS" | sed 's/^\[[0-9]*\] *//'`
      OLDIFS="$IFS";
      IFS=$'\n\t\n';
      for rep in $REPS; do
	  IFS="$OLDIFS";
	  "$PPM" rep off $rep 2>/dev/null >/dev/null
      done
      IFS="$OLDIFS";
      "$PPM" rep add tredsetup "$packages_ap58" 2>/dev/null >/dev/null
      "$PPM" rep
      echo $MSGDONE
      for s in $PACKAGES58; do 
	echo
        echo "$MSG004 $s"
	ppd="${s//::/-}";
	if ! "$PPM" install "$ppd" 2>/dev/null >/dev/null; then
          "$PPM" upgrade -install -precious "$ppd"
        fi
      done
      echo $MSG005
      "$PPM" rep del tredsetup 2>/dev/null >/dev/null
      OLDIFS="$IFS";
      IFS=$'\n\t\n';
      for rep in $REPS; do
           IFS="$OLDIFS";
           "$PPM" rep on "$rep" 2>/dev/null >/dev/null
      done
      "$PPM" rep
      IFS="$OLDIFS";
      echo $MSGDONE
  fi
}

function install_packages {
  "$PPM" install --location="$packages_ap58" $*
}

function upgrade_perl {
  PERLINSTALLDIR="${PERLDIR%/BIN}"
  PERLINSTALLDIR="${PERLINSTALLDIR%/bin}"
  if ask "$MSG007 $PERLINSTALLDIR?"; then
      "$PERLBIN" uninst_p500.pl "$DOSPERLDIR/p_uninst.dat" >/dev/null 2>/dev/null
      echo
      echo "$MSG006 $PERLINSTALLDIR"
      read -e -n1 -r -p "$MSG008"
      echo "$MSG009 $PERLINSTALLDIR..."
      rm -rf "$PERLINSTALLDIR"
      echo $MSGDONE
  else
      echo $MSG010
      read -e -n1 -r -p "$MSG011"
      exit 1;
  fi
  echo 
  echo $MSG012
  install_perl
}

function get_perl_install_dir {
  read -e -r -p "$MSG036 c:/perl]: " PERLINSTALLDIR
  if [ -z "$PERLINSTALLDIR" ]; then
    PERLINSTALLDIR="c:/perl"
  fi
}

function install_perl {
  DIR="$PWD"
  if [ ! -f "$DIR/$REQPERLINSTDIR/"perl*.tgz ]; then
      echo "-------------------------------------------------------------------------------"
      echo
      echo "Due to licensing issues we cannot distribute ActivePerl 5.8 together with"
      echo "this setup. Please download and install ActivePerl 5.8 for Windows from:"
      echo
      echo "http://www.activestate.com/Products/Download/Download.plex?id=ActivePerl"
      echo "It is free of charge."
      echo
      echo "When finished, run setup.bat again."
      echo
      echo "Thank you!";
      exit 1;
  fi

  test -d "$PERLINSTALLDIR" || mkdir "$PERLINSTALLDIR"
  echo "$MSG013" "$DIR/$REQPERLINSTDIR"/perl*.tgz
  (cd "$PERLINSTALLDIR" &&\
  tar -xzf "$DIR/$REQPERLINSTDIR/"perl*.tgz &&\
  echo "$MSG014"
  "$PERLINSTALLDIR/install.bat") || \
  (echo; echo "$MSG015"; exit 1)
}

echo
echo "-------------------------------------------------------------------------------"
echo
echo "$MSG016"
ask "$MSG017" || exit 0

echo
findperlbin
until [ -n "$PERLBIN" -a  -f "$PERLBIN" -a -x "$PERLBIN" ] && ask "$MSG018 $(dosdirname $PERLBIN)"; do
  echo "$MSG019"
  echo "$MSG020"
  echo "$MSG021"
  echo
  if ask "$MSG022"; then
    get_perl_install_dir
    install_perl
#    findperlbin
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else  
    read -e -r -p "$MSG023" PERLBIN
  fi
done


PERLDIR=`dirname "$PERLBIN" 2>/dev/null`
DOSPERLDIR=`dosdirname "$PERLDIR"`
CYGPERLDIR=`cygdirname "$PERLDIR"`
export PATH="$CYGPERLDIR:$PATH"
PPM="$CYGPERLDIR/ppm.bat" #$DOSPERLDIR/ppm.bat


echo "$MSG024"

if perl_version_current; then
  echo "$MSGOK"
else 
  echo
  echo "$MSG025 5.${REQPERLVER}"
  if ask "$MSG026"; then
    upgrade_perl
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else
    if ask "$MSG027"; then
     echo 
     echo "$MSG028"
     echo "$MSG029"
    else 
     exit 1
    fi
  fi
fi

upgrade_packages

findtreddir

if [ -n "$TREDDIR" -a  -x "$TREDDIR/tred" ]; then
  echo
  echo "$MSG030 $TREDDIR"
  if ask "$MSG031"; then
    UPGRADE=1
    if ask "$MSG032"; then
      test -f "$TREDDIR/tredlib/tredrc" && \
        mv "$TREDDIR/tredlib/tredrc" "$TREDDIR/tredlib/tredrc.sav"
    else
      rm -f "$TREDDIR/tredlib/tredrc.sav"
    fi  
  else
    echo
    ask "$MSG033" || exit 0
    if [ "$OSTYPE" = "cygwin" ]; then
      TREDDIR="c:/tred"
    else 
      TREDDIR="$HOME/tred"
    fi    
    read -e -r -p "$MSG034 $TREDDIR]: " DIR
    test -z "$DIR" || TREDDIR="${DIR//\\\\//}"
  fi
else 
  echo
  ask "$MSG035" || exit 0
  if [ "$OSTYPE" = "cygwin" ]; then
    TREDDIR="c:/tred"
  else 
    TREDDIR="$HOME/tred"
  fi    
  read -e -r -p "$MSG036 $TREDDIR]: " DIR
  test -z "$DIR" || TREDDIR="${DIR//\\\\//}"
fi

if [ $OSTYPE = "cygwin" ]; then
  STARTW="start /W"
else
  STATRW=""
fi

echo
echo "$MSG037 $TREDDIR"

if [ "$UPGRADE" = 1 ] && [ -f "${TREDDIR}/tredlib/tredrc.sav" ]; then
  SAVED_TREDRC=1
fi

if ((test -d "${TREDDIR}" || mkdir "${TREDDIR}") && \
    cp -R tred/* "${TREDDIR}"             && \
    ([ ! -f tred.mac ] || cp tred.mac "${TREDDIR}/tredlib")  && \
    ([ ! -d resources ] || \
       ([ -d "${TREDDIR}/resources" ] || mkdir "${TREDDIR}/resources";\
        cp -R resources/* "${TREDDIR}/resources"))  && \
    ([ "$SAVED_TREDRC" = 1  -o "$TREDRC" = "" -o ! -f "$TREDRC" ] || \
     (echo "$MSG044 $TREDRC $MSG045"; cp "$TREDRC" "${TREDDIR}/tredlib/tredrc"))  && \
    mkplbat tred                          && \
    mkplbat btred                         && \
    mkplbat trprint                       && \
    mkplbat any2any); then 
    
    if (test -d "${TREDDIR}/bin" || mkdir "${TREDDIR}/bin"); then
      cp -f bin/prfile32.exe nsgmls/* bin/prfile32.exe bin/*.dll bin/gunzip.exe bin/gzip.exe bin/zcat.exe "${TREDDIR}/bin"
    else 
      echo "$MSG039 ${TREDDIR}/bin !"
    fi
    [ "$SAVED_TREDRC" = 1 ] && \
     mv "${TREDDIR}/tredlib/tredrc.sav" "${TREDDIR}/tredlib/tredrc";
    test "x$UPGRADE" != "x1" && "$PERLBIN" trinstall.pl "$INSTLANG" "${TREDDIR}"

    # change tredrc to read-only so that users have to create
    # their own copy
    attrib +R "${TREDDIR}/tredlib/tredrc"

    echo "$MSG038"
    regtool add "\\machine\\Software\\TrEd" >/dev/null 2>/dev/null
    regtool -s set "\\machine\\Software\\TrEd\\Dir" "$TREDDIR" >/dev/null 2>/dev/null
    echo
    echo "$MSG040"
    echo "$MSG041"
    echo
else
  echo
  echo "$MSG042"
  echo
  read -e -n1 -r -p "$MSG043"
fi
