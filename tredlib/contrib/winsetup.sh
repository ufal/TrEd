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
  PERLBIN=`which perl`
  if [ -z $PERLBIN ]; then
    for d in c d e f g; do 
      if [ -x ${d}:/perl/bin ]; then
        PERLBIN=${d}:/perl/bin
	return 0
      fi
    done
    PERLBIN=`regtool get '\machine\Software\Perl\BinDir'`
    if [ -x "${PERLBIN}" ]; then
      return 0
    else
      return 1
    fi
  fi
}

echo Toto je instalace programu TrEd

ask "Chcete pokracovat" || exit 0;

findperlbin

echo $PERLBIN

ask "Chcete nainstalovat ActiveState Perl"

ask "Chcete instalovat ci upgradovat PerlTk"

ask "TrEd je jiz nainstalovan. Chete provest aktualizaci?"

