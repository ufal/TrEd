## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-06-05 11:26:01 pajas>


package TR_Correction;
@ISA=qw(Tectogrammatic TredMacro main);
import Tectogrammatic;
import TredMacro;
import main;

# permitting all attributes modification
sub enable_attr_hook {
  return;
}

