#!/bin/bash
PATH=.:`pwd`/bin:${PATH}

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
  sed "s!_PERLBIN_!$PERLBIN!" < pl2bat > "${TREDDIR}/$1.bat" && \
  cat "${TREDDIR}/$1" pl2batend >> "${TREDDIR}/$1.bat"
  return $?
}

function findperlbin {
  PERLBIN=`which perl 2>/dev/null`
  if [ -z $PERLBIN ]; then
    test $OSTYPE = "cygwin" || return 1
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

function findtreddir {
  TREDDIR=`which perl 2>/dev/null`
  if [ -z $TREDDIR ]; then
    test $OSTYPE = "cygwin" || return 1
    TREDDIR=`regtool get '\machine\Software\TrEd\Dir' 2>/dev/null`
    if [ ! -x ${TREDDIR}/tred ]; then
      for d in c d e f g; do 
        if [ -x ${d}:/tred/tred ]; then
          TREDDIR=${d}:/tred
	  return 0
        fi
      done
    fi
  fi
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
  if test $OSTYPE = "cygwin" &&  ask "Chcete nainstalovat ActiveState Perl"; then
    APi522e.exe
    findperlbin
  else  
    read -e -p "Path to perl binary executable: " PERLBIN
  fi
done

PERLDIR=`dirname $PERLBIN 2>/dev/null`

echo -n "Ocekavam perl v $PERLBIN. Probiha test..."

TKTEST=`$PERLBIN -e 'print eval { require Tk; },"\n"'` || exit 0

echo " hotovo."
echo

if [ $OSTYPE = "cygwin" ]; then

  if [ "${TKTEST}" = "1" ]; then
    echo "Perl/Tk knihovna je jiz nainstalovana."
    #ask "Prejete si provest upgrade knihovny Perl/Tk"
    false
  else
    ask "Chcete nainstalovat knihovnu Perl/Tk"
  fi

  if [ $? -eq 0 ]; then

    if [ "${TKTEST}" = "1" ]; then
      echo $?
      echo "Pokus o odstraneni stavajici verze Perl/Tk"
      test "${TKTEST}" = "1" &&  $PERLBIN $PERLDIR/ppm remove Tk
    fi

    echo
    echo "Instalace aktualni verze Perl/Tk"
    cd PerlTk-cz
    $PERLBIN $PERLDIR/ppm install Tk.ppd ||\
      ( echo "Chyba pri instalaci Tk knihovny"; exit 1 )
  fi
else
  echo 
  echo "TrEd vyzaduje knihovnu Tk."
  echo "Nainstalujte Tk knihovnu a spustte tento skript znovu."
  exit 1

fi
  
findtreddir

if [ -n "$TREDDIR" -a  -x "$TREDDIR/tred" ]; then
  UPGRADE=1
  echo
  echo "TrEd je jiz nainstalovan v adresari $TREDDIR"
  if ask "Chcete provest upgrade v tomto adresari"; then
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
if ((test $UPGRADE = 1 || mkdir "${TREDDIR}") && \
    cp -R tred/* "${TREDDIR}"             && \
    cp tred.mac "${TREDDIR}/tredlib"      && \
    mkplbat tred                          && \
    mkplbat btred                         && \
    mkplbat trprint                       && \
    mkplbat any2any                       && \
    (test $UPGRADE = 1 -a -f "${TREDDIR}/tredlib/tredrc.sav" && \
     mv "${TREDDIR}/tredlib/tredrc.sav" "${TREDDIR}/tredlib/tredrc"
    ) && \
    (test $UPGRADE = 1 || "$PERLBIN" trinstall.pl)); then
  echo "Upravuji polozku TrEdu v registrech Windows
  regtool -s set '\machine\Software\TrEd\Dir' $TREDDIR 
  echo
  echo "Instalace je uspesne dokoncena. Zkontrolujte, ze na plose pribyla"
  echo "ikona s obrazkem sileneho zvirete"
  echo

else
  echo
  echo Behem instalace doslo k chybe.
  echo
fi






