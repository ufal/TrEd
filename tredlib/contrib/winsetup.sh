#!/bin/bash
PATH=.:`pwd`/bin:${PATH}

function ask {
  answer=""
  until [ "$answer" = 'a' -o "$answer" = 'n' ]; do       
    read -e -n1 -r -p "$1 [a/n]?" answer 
  done
  if [ "$answer"='a' ]; then
    return 0
  else
    return 1  
  fi
}

function findperlbin {
  PERLBIN=`which perl 2>/dev/null`
  if [ -z $PERLBIN ]; then
    for d in c d e f g; do 
      if [ -x ${d}:/perl/bin ]; then
        PERLBIN=${d}:/perl/bin
	return 0
      fi
    done
    PERLBIN=`regtool get '\machine\Software\Perl\BinDir'`"/perl"
  fi
}

echo Toto je instalace programu TrEd

ask "Chcete pokracovat" || exit 0;

until [ -f $PERLBIN -a -x $PERLBIN ]; do
  echo "Na vasem pocitaci jsem nenasel instalaci perlu.\n"
  echo "Muzete pokracovat bud instalaci ActiveState perlu"
  echo "nebo musite rucne zadat uplnou cestu k programu 'perl'"
  if test $OSTYPE = "cygwin" &&  ask "Chcete nainstalovat ActiveState Perl"; then
    start /W APi522e.exe
    findperlbin
  else  
    read -e -p "Path to perl binary executable: " PERLBIN
  fi
done

echo "Assuming perl in $PERLBIN. Testing..."

$TKTEST=`$PERLBIN -e 'print eval { require Tk; },"\n"'` || exit 0

if [ "${TKTEST}" = "1" ]; then
    echo "Perl/Tk knihovna je jiz nainstalovana."
    ask "Prejete si provest upgrade knihovny Perl/Tk"    
else
    ask "Chcete nainstalovat knihovnu Perl/Tk"
fi
    
ask "TrEd je jiz nainstalovan. Chete provest aktualizaci?"

