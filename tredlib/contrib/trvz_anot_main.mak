## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-05-04 14:19:05 pajas>

#
# This file defines default macros for TR annotators for so called
# "Sample File" (VZS).
# Only TredMacro context is present here, but almost all
# attribute are allowed.
#

#include contrib/remote_control.mak
#include contrib/tr_anot_main.mak

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr=~/^(?:lemma|tag|form|afun|ID1|ID2|origf|gap1|gap2|ord|ordtf|afunprev|warning|err1|err2|semPOS|tagauto|lemauto|ordorig|dord|sentord|reserve[1-5]|funcprec|funcaux|funcauto)$/) {
    print STDERR "$atr\n";
    return "stop";
  }
}
