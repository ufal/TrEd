#!/bin/bash
if [ "$OSTYPE" != "cygwin" ]; then 
  echo Tento program je urcen vyhradne pro instalaci tredu
  echo v prostredi MS Windows, je mi lito!
fi

PATH=.:`pwd`/bin:${PATH}
PERLVERSION="This is perl, v5.6.1 built for MSWin32-x86-multi-thread"

function ask {
  answer=""
  until [ "$answer" = 'a' -o "$answer" = 'n' ]; do       
    read -e -n1 -r -p "$1 [a/n]?" answer 
  done
  if [ "$answer" = 'a' ]; then
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
    echo Kontroluji verzi baliku $s
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
  echo Odstranuji $PERLINSTALLDIR

  $PERLBIN uninst_p500.pl $DOSPERLDIR/p_uninst.dat

  read -e -n1 -r -p "Stisknete libovolnou klavesu pro pokracovani..."

  rm -rf $PERLINSTALLDIR
  echo 
  echo Stara verze perlu odinstalovana
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
  echo Rozbaluji instalacni balicek "$DIR/win32_perl/perl561.tgz"
  (cd "$PERLINSTALLDIR" &&\
  tar -xzf "$DIR/win32_perl/perl561.tgz" &&\
  echo "Spoustim instalator programu ActiveState Perl"
  "$PERLINSTALLDIR/install.bat") || \
  (echo; echo Nastala chyba pri instalaci perlu!; exit 1)
#  install_packages Tk XML::DOM Text::Iconv
}

echo
echo "-------------------------------------------------------------------------------"
echo
echo Toto je instalace programu TrEd
ask "Chcete pokracovat" || exit 0

echo
findperlbin
until [ -n "$PERLBIN" -a  -f "$PERLBIN" -a -x "$PERLBIN" ] && ask "Pouzit Perl z $PERLBIN"; do
  echo "Na vasem pocitaci nebyla nalezena instalace perlu."
  echo "Muzete pokracovat bud instalaci ActiveState perlu"
  echo "nebo musite rucne zadat uplnou cestu k programu 'perl'"
  echo
  if ask "Chcete nainstalovat ActiveState Perl"; then
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


echo Kontruluji verzi instalovaneho perlu.

if perl_version_current; then
  echo Ok.
else 
  echo
  echo Tato instalace vyzaduje jinou verzi perlu.
  if ask "Prejete si provest aktualizaci?"; then
    upgrade_perl
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else
    if ask "Pokracovat v instalaci?"; then
     echo 
     echo "Pokracuji v instalaci."
     echo "UPOZORNENI: Nektere soucasti nemusi po instalaci fungovat spravne!!"
    else 
     exit 1
    fi
  fi
fi


#echo -n "Ocekavam perl v $PERLBIN. Probiha test..."
#TKTEST=`$PERLBIN -e 'print eval { require Tk; },"\n"'` || exit 0

#echo " hotovo."
#echo

#if [ $OSTYPE = "cygwin" ]; then

#    if [ "${TKTEST}" = "1" ]; then
#      echo "Perl/Tk knihovna je jiz nainstalovana."
#      #ask "Prejete si provest upgrade knihovny Perl/Tk"
#      false
#    else
#      ask "Chcete nainstalovat knihovnu Perl/Tk"
#    fi

#    if [ $? -eq 0 ]; then

#      if [ "${TKTEST}" = "1" ]; then
#        echo $?
#        echo "Pokus o odstraneni stavajici verze Perl/Tk"
#        test "${TKTEST}" = "1" &&  $PPM remove Tk
#      fi

#      echo
#      echo "Instalace aktualni verze Perl/Tk"
#      cd PerlTk-cz
#      $PPM install Tk.ppd ||\
#        ( echo "Chyba pri instalaci Tk knihovny"; exit 1 )
#    fi

#  upgrade_package XML::Parser XML::DOM
  upgrade_packages Tk Text::Iconv XML::SAX XML::LibXML XML::LibXML::Iterator Tie::IxHash

#else
#  if [ "${TKTEST}" != "1" ]; then
#    echo 
#    echo "TrEd vyzaduje knihovnu Tk."
#    echo "Nainstalujte Tk knihovnu a spustte tento skript znovu."
#    exit 1
#  fi
#fi
  
findtreddir

if [ -n "$TREDDIR" -a  -x "$TREDDIR/tred" ]; then
  echo
  echo "TrEd je jiz nainstalovan v adresari $TREDDIR"
  if ask "Chcete provest upgrade v tomto adresari"; then
    UPGRADE=1
    if ask "Chcete zachovat stavajici konfiguracni soubor"; then
      test -f "$TREDDIR/tredlib/tredrc" && \
        mv "$TREDDIR/tredlib/tredrc" "$TREDDIR/tredlib/tredrc.sav"
    else
      rm -f "$TREDDIR/tredlib/tredrc.sav"
    fi  
  else
    echo
    ask "Chcete nainstalovat TrEd do jineho adresare" || exit 0
    if [ "$OSTYPE" = "cygwin" ]; then
      TREDDIR="c:/tred"
    else 
      TREDDIR="$HOME/tred"
    fi    
    read -e -p "Zadejte cilovy adresar [implicitne $TREDDIR]: " DIR
    test -z $DIR || TREDDIR=$DIR
  fi
else 
  echo
  ask "Chcete nainstalovat TrEd" || exit 0
  if [ "$OSTYPE" = "cygwin" ]; then
    TREDDIR="c:/tred"
  else 
    TREDDIR="$HOME/tred"
  fi    
  read -e -p "Zadejte cilovy adresar [implicitne $TREDDIR]: " DIR
  test -z $DIR || TREDDIR=$DIR
fi

if [ $OSTYPE = "cygwin" ]; then
  STARTW="start /W"
else
  STATRW=""
fi

echo
echo "Kopiruji TrEd do adresare $TREDDIR"
if ((test -d "${TREDDIR}" || mkdir "${TREDDIR}") && \
    cp -R tred/* "${TREDDIR}"             && \
    cp tred.mac "${TREDDIR}/tredlib"      && \
    mkplbat tred                          && \
    mkplbat btred                         && \
    mkplbat trprint                       && \
    mkplbat any2any); then 
    
    if (test -d "${TREDDIR}/bin" || mkdir "${TREDDIR}/bin"); then
      cp -f bin/prfile32.exe nsgmls/* bin/prfile32.exe bin/*.dll bin/gunzip.exe bin/gzip.exe bin/zcat.exe "${TREDDIR}/bin"
    else 
      echo Nelze vytvorit adresar "${TREDDIR}/bin"!
    fi
    test "x$UPGRADE" = "x1" -a -f "${TREDDIR}/tredlib/tredrc.sav" && \
     mv "${TREDDIR}/tredlib/tredrc.sav" "${TREDDIR}/tredlib/tredrc";
    test "x$UPGRADE" != "x1" && "$PERLBIN" trinstall.pl

    echo "Upravuji polozku TrEdu v registrech Windows"
    regtool add "\\machine\\Software\\TrEd"
    regtool -s set "\\machine\\Software\\TrEd\\Dir" "$TREDDIR" 
    echo
    echo "Instalace je uspesne dokoncena. Zkontrolujte, ze na plose pribyla"
    echo "ikona s obrazkem sileneho zvirete:)"
    echo
else
  echo
  echo Behem instalace doslo k chybe.
  echo
fi
