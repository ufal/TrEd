## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-04-12 18:41:29 pajas>

#
# This file defines default macros for TR annotators for so called
# "Sample File" (VZS).
# Only TredMacro context is present here, but almost all
# attribute are allowed.
#

#include remote_control.mak
#include tr_anot_main.mak

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:func|coref|commentA|reltype|aspect|tfa|err1|degcmp|iterativeness|verbmod|deontmod|sentmod|gram|memberof|phraseme|del|quoted|dsp|cornum|sorsnt|antec|parenthesis)$/) {
    return "stop";
  }
}
