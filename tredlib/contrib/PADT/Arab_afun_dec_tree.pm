# -*- cperl -*-
# This file was automatically generated with /home/pajas/treebank/perl/decision_trees2perl.pl
# by zabokrtsky@quinn.ms.mff.cuni.cz <Thu Feb 27 18:37:16 2003>

package Arab_afun_dec_tree;

use Exporter;
use strict;
use vars qw(@ISA @EXPORT_OK);

BEGIN {
  @ISA=qw(Exporter);
  @EXPORT_OK=qw(evalTree);
}

# 
# C5.0 [Release 1.16]  	Thu Feb 27 17:36:41 2003
# -------------------
# 
#     Options:
# 	Application `thirdseries//pokus'
# 	Pruning confidence level 60%
# 	Cross-validate using 10 folds
# 
# Read 18594 cases (11 attributes) from thirdseries//pokus.data
# 
# 
# [ Fold 0 ]
# 

sub evalTree { 
  my $h=$_[0];

  if ($h->{d_taghead} eq 'DEM_PRON_FS') {
    return ('Atr',3,);
  } elsif ($h->{d_taghead} eq 'SUBJUNC') {
    return ('Adv',19,2);
  } elsif ($h->{d_taghead} eq 'IV3MD') {
    return ('Obj',3,1);
  } elsif ($h->{d_taghead} eq 'POSS_PRON_3MP') {
    return ('Atr',43,2);
  } elsif ($h->{d_taghead} eq 'POSS_PRON_3D') {
    return ('Atr',8,1);
  } elsif ($h->{d_taghead} eq 'POSS_PRON_3MS') {
    return ('Atr',127,4);
  } elsif ($h->{d_taghead} eq 'undef') {
    return ('Coord',1,);
  } elsif ($h->{d_taghead} eq 'IVSUFF_DOspec_ddot3MP') {
    return ('Obj',2,);
  } elsif ($h->{d_taghead} eq 'IVSUFF_DOspec_ddot3MS') {
    return ('Obj',16,2);
  } elsif ($h->{d_taghead} eq 'POSS_PRON_1P') {
    return ('Atr',18,1);
  } elsif ($h->{d_taghead} eq 'DEM_PRON_F') {
    return ('Atr',49,);
  } elsif ($h->{d_taghead} eq 'IV2D') {
    return ('Atr',1,);
  } elsif ($h->{d_taghead} eq 'POSS_PRON_3FS') {
    return ('Atr',95,5);
  } elsif ($h->{d_taghead} eq 'IVSUFF_DOspec_ddot1P') {
    return ('Obj',2,);
  } elsif ($h->{d_taghead} eq 'PVSUFF_DOspec_ddot3MP') {
    return ('Obj',1,);
  } elsif ($h->{d_taghead} eq 'IVSUFF_DOspec_ddot1S') {
    return ('Obj',2,);
  } elsif ($h->{d_taghead} eq 'POSS_PRON_2MP') {
    return ('Atr',2,);
  } elsif ($h->{d_taghead} eq 'IVSUFF_DOspec_ddot3FS') {
    return ('Obj',25,);
  } elsif ($h->{d_taghead} eq 'IV3FP') {
    return ('Obj',1,);
  } elsif ($h->{d_taghead} eq 'PVSUFF_DOspec_ddot3MS') {
    return ('Obj',17,);
  } elsif ($h->{d_taghead} eq 'INTERROG_PART') {
    return ('Obj',2,1);
  } elsif ($h->{d_taghead} eq 'DEM_PRON_MP') {
    return ('Obj',6,2);
  } elsif ($h->{d_taghead} eq 'PRON_2MP') {
    return ('Obj',2,1);
  } elsif ($h->{d_taghead} eq 'PVSUFF_DOspec_ddot1P') {
    return ('Obj',2,1);
  } elsif ($h->{d_taghead} eq 'IV2MP') {
    return ('Atr',3,);
  } elsif ($h->{d_taghead} eq 'PRON_2MS') {
    return ('Obj',2,1);
  } elsif ($h->{d_taghead} eq 'IV2MS') {
    return ('Atr',4,1);
  } elsif ($h->{d_taghead} eq 'PRON_3D') {
    return ('AuxY',4,2);
  } elsif ($h->{d_taghead} eq 'FUT') {
    return ('AuxM',59,);
  } elsif ($h->{d_taghead} eq 'PVSUFF_DOspec_ddot3FS') {
    return ('Obj',22,1);
  } elsif ($h->{d_taghead} eq 'IV1S') {
    return evalSubTree1_S1($h); # [S1]
  } elsif ($h->{d_taghead} eq 'IV3MP') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('Atv',3,1);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
        return ('Atr',2,);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('Atr',4,);
      } elsif ($h->{g_taghead} eq 'IV3MP') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('Atr',2,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',10,2);
      } elsif ($h->{g_taghead} eq 'DEM_PRON_MP') {
        return ('Atr',2,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return ('Obj',9,2);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',4,);
      }
  } elsif ($h->{d_taghead} eq 'POSS_PRON_1S') {
    return evalSubTree1_S2($h); # [S2]
  } elsif ($h->{d_taghead} eq 'PART') {
      if ($h->{d_children} eq '0') {
        return ('AuxY',1,);
      } elsif ($h->{d_children} eq '1') {
        return ('AuxP',3,1);
      } elsif ($h->{d_children} eq 'more') {
        return ('AuxP',2,);
      }
  } elsif ($h->{d_taghead} eq 'PRON_1P') {
      if ($h->{i_lemma} =~ /^(?:Ean|fiy|li|Hawola|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY)$/) {
        return ('Obj',0,);
      } elsif ($h->{i_lemma} eq 'EalaY') {
        return ('Sb',1,);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
        return ('Sb',8,);
      } elsif ($h->{i_lemma} eq 'Ealay') {
        return ('Obj',4,);
      } elsif ($h->{i_lemma} eq 'la') {
        return ('Obj',2,);
      }
  } elsif ($h->{d_taghead} eq 'IV1P') {
      if ($h->{g_taghead} =~ /^(?:PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|NOUN|IV3FS|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Obj',0,);
      } elsif ($h->{g_taghead} eq 'IV1P') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('Obj',6,);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return ('Obj',1,);
      } elsif ($h->{g_taghead} eq 'DEM_PRON_MP') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',2,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return evalSubTree1_S3($h); # [S3]
      }
  } elsif ($h->{d_taghead} eq 'PRON_1S') {
      if ($h->{i_taghead} eq 'empty') {
        return ('Sb',6,1);
      } elsif ($h->{i_taghead} eq 'PREP') {
        return evalSubTree1_S4($h); # [S4]
      }
  } elsif ($h->{d_taghead} eq 'IV3FS') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('Atr',2,1);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
        return ('Obj',3,2);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('Atr',34,);
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return ('Adv',2,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',56,2);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Adv',6,3);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('Atr',4,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return ('Obj',74,10);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',40,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return evalSubTree1_S5($h); # [S5]
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
          if ($h->{g_position} eq 'left') {
            return ('Atr',7,2);
          } elsif ($h->{g_position} eq 'right') {
            return ('Obj',2,);
          }
      }
  } elsif ($h->{d_taghead} eq 'VERB_PERFECT') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|IV2MP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ABBREV|PRON_1P)$/) {
        return ('Pred',0,);
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
        return ('Pred',3,);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('Pred',4,2);
      } elsif ($h->{g_taghead} eq 'IV3MP') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Atr',2,1);
      } elsif ($h->{g_taghead} eq 'DEM_PRON_MS') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('Atr',3,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',345,5);
      } elsif ($h->{g_taghead} eq 'ADJ') {
        return ('Atr',5,2);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
          if ($h->{g_position} eq 'left') {
            return ('Atr',23,1);
          } elsif ($h->{g_position} eq 'right') {
            return ('Obj',3,1);
          }
      } elsif ($h->{g_taghead} eq 'DET') {
          if ($h->{g_position} eq 'left') {
            return ('Atr',50,3);
          } elsif ($h->{g_position} eq 'right') {
            return ('Obj',2,1);
          }
      } elsif ($h->{g_taghead} eq 'IV3MS') {
          if ($h->{g_children} eq '1') {
            return ('Obj',2,);
          } elsif ($h->{g_children} eq 'more') {
            return ('Adv',13,5);
          }
      } elsif ($h->{g_taghead} eq 'NOUN') {
          if ($h->{i_lemma} =~ /^(?:Ean|fiy|li|Hawola|EalaY|Ealay|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|bi|ladaY|qabol|ka|xilAl|la)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Atr',74,3);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',2,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Atr',2,1);
          } elsif ($h->{i_lemma} eq 'Hatspec_tildaaY') {
            return ('Adv',1,);
          }
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return evalSubTree1_S6($h); # [S6]
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
          if ($h->{g_position} eq 'right') {
            return ('Pred',3,1);
          } elsif ($h->{g_position} eq 'left') {
            return evalSubTree1_S7($h); # [S7]
          }
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return evalSubTree1_S8($h); # [S8]
      }
  } elsif ($h->{d_taghead} eq 'NEG_PART') {
      if ($h->{g_position} eq 'right') {
          if ($h->{d_children} eq '0') {
            return ('AuxM',100,3);
          } elsif ($h->{d_children} eq '1') {
            return ('Sb',5,3);
          } elsif ($h->{d_children} eq 'more') {
            return ('Coord',1,);
          }
      } elsif ($h->{g_position} eq 'left') {
          if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|PRON_1P)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return ('Obj',3,1);
          } elsif ($h->{g_taghead} eq 'DET') {
            return ('Atr',2,1);
          } elsif ($h->{g_taghead} eq 'IV3MS') {
            return ('AuxM',1,);
          } elsif ($h->{g_taghead} eq 'IV3FS') {
            return ('AuxC',1,);
          } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
            return ('Obj',6,2);
          } elsif ($h->{g_taghead} eq 'root') {
            return ('Pred',4,);
          } elsif ($h->{g_taghead} eq 'ABBREV') {
            return ('AtrAdv',1,);
          } elsif ($h->{g_taghead} eq 'NOUN') {
            return evalSubTree1_S9($h); # [S9]
          }
      }
  } elsif ($h->{d_taghead} eq 'CONJ') {
      if ($h->{d_children} eq '0') {
        return ('AuxY',496,10);
      } elsif ($h->{d_children} eq 'more') {
        return ('Coord',457,8);
      } elsif ($h->{d_children} eq '1') {
        return evalSubTree1_S10($h); # [S10]
      }
  } elsif ($h->{d_taghead} eq 'PRON_3MP') {
      if ($h->{i_taghead} eq 'PREP') {
          if ($h->{i_lemma} =~ /^(?:fiy|li|Hawola|EalaY|other_lemma|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY)$/) {
            return ('Obj',0,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Obj',2,1);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Atr',4,1);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Adv',5,2);
          } elsif ($h->{i_lemma} eq 'la') {
            return ('Obj',4,);
          }
      } elsif ($h->{i_taghead} eq 'empty') {
          if ($h->{g_position} eq 'right') {
            return ('Sb',6,1);
          } elsif ($h->{g_position} eq 'left') {
            return evalSubTree1_S11($h); # [S11]
          }
      }
  } elsif ($h->{d_taghead} eq 'DEM_PRON_MS') {
      if ($h->{i_lemma} =~ /^(?:Hawola|EalaY|Ealay|baEoda|spec_amperltspec_semicolilay|bayona|ladaY|qabol|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'Ean') {
        return ('Obj',1,);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return ('Sb',1,);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Obj',3,2);
      } elsif ($h->{i_lemma} eq 'maEa') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'ilaY') {
        return ('Adv',1,);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
        return ('Obj',1,);
      } elsif ($h->{i_lemma} eq 'min') {
        return ('Obj',2,1);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Obj',2,);
      } elsif ($h->{i_lemma} eq 'ka') {
        return ('AuxY',1,);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
          if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|ADJ|ABBREV|PRON_1P)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return ('Sb',2,);
          } elsif ($h->{g_taghead} eq 'REL_PRON') {
            return ('Sb',1,);
          } elsif ($h->{g_taghead} eq 'DET') {
            return ('Atr',38,);
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('Atr',1,);
          } elsif ($h->{g_taghead} eq 'NOUN') {
            return ('Atr',3,1);
          } elsif ($h->{g_taghead} eq 'root') {
            return ('Ref',2,1);
          } elsif ($h->{g_taghead} eq 'PREP') {
            return ('Atr',1,);
          } elsif ($h->{g_taghead} eq 'IV3MS') {
              if ($h->{g_position} eq 'left') {
                return ('Obj',2,1);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',3,);
              }
          }
      }
  } elsif ($h->{d_taghead} eq 'FUNC_WORD') {
      if ($h->{g_position} eq 'right') {
          if ($h->{i_taghead} eq 'PREP') {
            return ('AuxC',4,);
          } elsif ($h->{i_taghead} eq 'empty') {
            return ('AuxE',42,6);
          }
      } elsif ($h->{g_position} eq 'left') {
          if ($h->{d_children} eq '1') {
            return ('AuxC',300,3);
          } elsif ($h->{d_children} eq 'more') {
            return ('AuxC',25,);
          } elsif ($h->{d_children} eq '0') {
            return evalSubTree1_S12($h); # [S12]
          }
      }
  } elsif ($h->{d_taghead} eq 'ADJ') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|root|PVSUFF_DOspec_ddot3FS|PREP|ABBREV|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'SUBJUNC') {
        return ('Obj',2,1);
      } elsif ($h->{g_taghead} eq 'IV1S') {
        return ('Atv',1,);
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
        return ('Atr',3,1);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('Atr',3,1);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('Atr',2,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return ('Obj',7,2);
      } elsif ($h->{g_taghead} eq 'PRON_3D') {
        return ('Sb',1,);
      } elsif ($h->{g_taghead} eq 'ADJ') {
        return ('Atr',4,);
      } elsif ($h->{g_taghead} eq 'ADV') {
          if ($h->{g_children} eq '1') {
            return ('Adv',2,);
          } elsif ($h->{g_children} eq 'more') {
            return ('Sb',2,);
          }
      } elsif ($h->{g_taghead} eq 'DET') {
          if ($h->{d_children} eq '0') {
            return ('Adv',2,);
          } elsif ($h->{d_children} eq '1') {
            return ('Atr',9,1);
          } elsif ($h->{d_children} eq 'more') {
            return ('Obj',1,);
          }
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return evalSubTree1_S13($h); # [S13]
      } elsif ($h->{g_taghead} eq 'NOUN') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|EalaY|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('AtrAdv',2,1);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Atr',241,6);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Pnom',1,);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Atr',1,);
          }
      } elsif ($h->{g_taghead} eq 'IV3FS') {
          if ($h->{d_children} eq '0') {
            return ('Atr',3,2);
          } elsif ($h->{d_children} eq '1') {
            return ('Obj',1,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Atv',2,);
          }
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return evalSubTree1_S14($h); # [S14]
      }
  } elsif ($h->{d_taghead} eq 'PRON_3MS') {
      if ($h->{i_taghead} eq 'PREP') {
        return ('Obj',44,7);
      } elsif ($h->{i_taghead} eq 'empty') {
          if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|root|PRON_3D|PVSUFF_DOspec_ddot3FS|ABBREV|PRON_1P)$/) {
            return ('AuxY',0,);
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return ('Sb',12,);
          } elsif ($h->{g_taghead} eq 'ADV') {
            return ('AuxY',1,);
          } elsif ($h->{g_taghead} eq 'REL_PRON') {
            return ('Sb',1,);
          } elsif ($h->{g_taghead} eq 'DET') {
            return ('AuxY',6,1);
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('Sb',2,1);
          } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
            return ('Sb',1,);
          } elsif ($h->{g_taghead} eq 'PREP') {
            return ('Obj',1,);
          } elsif ($h->{g_taghead} eq 'ADJ') {
            return ('AuxY',1,);
          } elsif ($h->{g_taghead} eq 'IV3MS') {
              if ($h->{d_children} eq 'more') {
                return ('Sb',0,);
              } elsif ($h->{d_children} eq '0') {
                return ('Sb',6,1);
              } elsif ($h->{d_children} eq '1') {
                return ('AuxY',2,);
              }
          } elsif ($h->{g_taghead} eq 'NOUN') {
              if ($h->{g_children} eq '1') {
                return ('Atr',4,);
              } elsif ($h->{g_children} eq 'more') {
                return ('AuxY',5,2);
              }
          } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
              if ($h->{g_children} eq 'more') {
                return ('AuxY',16,);
              } elsif ($h->{g_children} eq '1') {
                return evalSubTree1_S15($h); # [S15]
              }
          }
      }
  } elsif ($h->{d_taghead} eq 'IV3MS') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ABBREV|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('Atr',3,2);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('Atr',22,2);
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return ('Adv',6,3);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('Atr',9,4);
      } elsif ($h->{g_taghead} eq 'PRON_3FS') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',48,5);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Adv',3,1);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',61,);
      } elsif ($h->{g_taghead} eq 'ADJ') {
        return ('Atr',1,);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
          if ($h->{g_children} eq '1') {
            return ('Atr',19,2);
          } elsif ($h->{g_children} eq 'more') {
            return ('Obj',8,4);
          }
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return evalSubTree1_S16($h); # [S16]
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return evalSubTree1_S17($h); # [S17]
      }
  } elsif ($h->{d_taghead} eq 'PRON_3FS') {
      if ($h->{g_position} eq 'right') {
        return evalSubTree1_S18($h); # [S18]
      } elsif ($h->{g_position} eq 'left') {
        return evalSubTree1_S19($h); # [S19]
      }
  } elsif ($h->{d_taghead} eq 'PREP') {
      if ($h->{d_children} eq '0') {
        return ('AuxY',17,5);
      } elsif ($h->{d_children} eq '1') {
          if ($h->{i_lemma} =~ /^(?:Ean|fiy|Hawola|Ealay|baEoda|maEa|spec_amperltspec_semicolilay|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('AuxP',0,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('AuxP',2,);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Adv',3,2);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('AuxP',2132,56);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Atr',2,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Adv',5,3);
          }
      } elsif ($h->{d_children} eq 'more') {
        return evalSubTree1_S20($h); # [S20]
      }
  } elsif ($h->{d_taghead} eq 'ABBREV') {
      if ($h->{d_children} eq 'more') {
        return ('Coord',11,1);
      } elsif ($h->{d_children} eq '1') {
          if ($h->{g_children} eq '1') {
            return ('AuxP',4,1);
          } elsif ($h->{g_children} eq 'more') {
            return ('spec_qmarkspec_qmarkspec_qmark',6,);
          }
      } elsif ($h->{d_children} eq '0') {
        return evalSubTree1_S21($h); # [S21]
      }
  } elsif ($h->{d_taghead} eq 'ADV') {
      if ($h->{d_children} eq 'more') {
        return evalSubTree1_S22($h); # [S22]
      } elsif ($h->{d_children} eq '0') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|Ealay|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|bi|ladaY|qabol|ka|xilAl|la)$/) {
            return ('Adv',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('AuxE',1,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Adv',5,3);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('AuxE',2,1);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('AuxE',4,1);
          } elsif ($h->{i_lemma} eq 'min') {
            return evalSubTree1_S23($h); # [S23]
          } elsif ($h->{i_lemma} eq 'Hatspec_tildaaY') {
            return evalSubTree1_S24($h); # [S24]
          } elsif ($h->{i_lemma} eq 'other_lemma') {
              if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ABBREV|PRON_1P)$/) {
                return ('Adv',0,);
              } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
                return ('Adv',35,1);
              } elsif ($h->{g_taghead} eq 'NEG_PART') {
                return ('Adv',1,);
              } elsif ($h->{g_taghead} eq 'DET') {
                return ('Adv',12,3);
              } elsif ($h->{g_taghead} eq 'IV3MS') {
                return ('Adv',20,3);
              } elsif ($h->{g_taghead} eq 'IV3FS') {
                return ('Adv',11,2);
              } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
                return ('Atr',1,);
              } elsif ($h->{g_taghead} eq 'ADJ') {
                return ('Adv',4,2);
              } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
                return evalSubTree1_S25($h); # [S25]
              } elsif ($h->{g_taghead} eq 'NOUN') {
                return evalSubTree1_S26($h); # [S26]
              }
          }
      } elsif ($h->{d_children} eq '1') {
        return evalSubTree1_S27($h); # [S27]
      }
  } elsif ($h->{d_taghead} eq 'REL_PRON') {
      if ($h->{d_children} eq '0') {
          if ($h->{g_position} eq 'left') {
            return ('AuxY',182,1);
          } elsif ($h->{g_position} eq 'right') {
              if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
                return ('Sb',0,);
              } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
                return ('AuxM',2,1);
              } elsif ($h->{g_taghead} eq 'DET') {
                return ('Sb',2,);
              } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
                return ('Adv',1,);
              } elsif ($h->{g_taghead} eq 'NOUN') {
                return ('AuxY',1,);
              }
          }
      } elsif ($h->{d_children} eq 'more') {
        return evalSubTree1_S28($h); # [S28]
      } elsif ($h->{d_children} eq '1') {
        return evalSubTree1_S29($h); # [S29]
      }
  } elsif ($h->{d_taghead} eq 'NOUN_PROP') {
      if ($h->{i_taghead} eq 'PREP') {
        return evalSubTree1_S30($h); # [S30]
      } elsif ($h->{i_taghead} eq 'empty') {
          if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|IV1S|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|ABBREV|PRON_1P)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return ('Sb',44,5);
          } elsif ($h->{g_taghead} eq 'SUBJUNC') {
            return ('Obj',1,);
          } elsif ($h->{g_taghead} eq 'NEG_PART') {
            return ('Atr',1,);
          } elsif ($h->{g_taghead} eq 'undef') {
            return ('Obj',1,);
          } elsif ($h->{g_taghead} eq 'DET') {
            return ('Atr',49,);
          } elsif ($h->{g_taghead} eq 'IV3MS') {
            return ('Sb',11,1);
          } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
            return ('Atr',103,2);
          } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
            return ('Sb',4,1);
          } elsif ($h->{g_taghead} eq 'root') {
            return ('ExD',19,1);
          } elsif ($h->{g_taghead} eq 'PREP') {
            return ('Obj',1,);
          } elsif ($h->{g_taghead} eq 'ADJ') {
            return ('Atr',5,1);
          } elsif ($h->{g_taghead} eq 'NOUN') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',120,4);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',2,);
              }
          } elsif ($h->{g_taghead} eq 'IV3FS') {
              if ($h->{d_children} eq '0') {
                return ('Sb',10,1);
              } elsif ($h->{d_children} eq '1') {
                return ('Obj',2,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Sb',2,);
              }
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return evalSubTree1_S31($h); # [S31]
          }
      }
  } elsif ($h->{d_taghead} eq 'NON_ALPHABETIC_DATA') {
    return evalSubTree1_S32($h); # [S32]
  } elsif ($h->{d_taghead} eq 'DET') {
      if ($h->{g_taghead} =~ /^(?:PRON_1S|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV2D|POSS_PRON_3FS|PART|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|PRON_3D|PVSUFF_DOspec_ddot3FS|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'PRON_3FS') {
        return ('Sb',1,);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('Atr',35,2);
      } elsif ($h->{g_taghead} eq 'IV2MS') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'ABBREV') {
        return ('Atr',3,1);
      } elsif ($h->{g_taghead} eq 'IV1P') {
          if ($h->{i_taghead} eq 'PREP') {
            return ('Adv',2,1);
          } elsif ($h->{i_taghead} eq 'empty') {
            return ('Obj',2,);
          }
      } elsif ($h->{g_taghead} eq 'SUBJUNC') {
        return evalSubTree1_S33($h); # [S33]
      } elsif ($h->{g_taghead} eq 'IV1S') {
          if ($h->{g_children} eq '1') {
            return ('Adv',2,);
          } elsif ($h->{g_children} eq 'more') {
            return ('Obj',3,1);
          }
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
          if ($h->{g_children} eq '1') {
            return ('Obj',4,2);
          } elsif ($h->{g_children} eq 'more') {
            return ('Sb',3,);
          }
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
          if ($h->{i_lemma} =~ /^(?:Ean|fiy|Hawola|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Sb',0,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Sb',23,7);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Sb',1,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Adv',4,2);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Adv',2,);
          }
      } elsif ($h->{g_taghead} eq 'PREP') {
          if ($h->{g_children} eq '1') {
            return ('Atr',18,5);
          } elsif ($h->{g_children} eq 'more') {
            return ('Adv',2,1);
          }
      } elsif ($h->{g_taghead} eq 'ADJ') {
        return evalSubTree1_S34($h); # [S34]
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
          if ($h->{g_position} eq 'right') {
            return ('Sb',2,);
          } elsif ($h->{g_position} eq 'left') {
            return evalSubTree1_S35($h); # [S35]
          }
      } elsif ($h->{g_taghead} eq 'IV3MP') {
          if ($h->{g_position} eq 'right') {
            return ('Sb',2,);
          } elsif ($h->{g_position} eq 'left') {
              if ($h->{i_lemma} =~ /^(?:Ean|li|Hawola|EalaY|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
                return ('Obj',0,);
              } elsif ($h->{i_lemma} eq 'fiy') {
                return ('Adv',4,);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                return ('Obj',2,);
              } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
                return ('Obj',3,);
              } elsif ($h->{i_lemma} eq 'min') {
                return ('Obj',1,);
              } elsif ($h->{i_lemma} eq 'bi') {
                return ('Obj',1,);
              }
          }
      } elsif ($h->{g_taghead} eq 'root') {
          if ($h->{g_position} eq 'right') {
            return ('ExD',6,);
          } elsif ($h->{g_position} eq 'left') {
              if ($h->{i_lemma} =~ /^(?:Ean|fiy|li|Hawola|Ealay|baEoda|maEa|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
                return ('Pnom',0,);
              } elsif ($h->{i_lemma} eq 'EalaY') {
                return ('Obj',1,);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                return ('Pnom',10,3);
              } elsif ($h->{i_lemma} eq 'ilaY') {
                return ('ExD',2,1);
              } elsif ($h->{i_lemma} eq 'min') {
                return ('Pnom',8,);
              } elsif ($h->{i_lemma} eq 'bi') {
                return ('Adv',1,);
              }
          }
      } elsif ($h->{g_taghead} eq 'ADV') {
          if ($h->{i_lemma} =~ /^(?:Ean|li|Hawola|Ealay|baEoda|maEa|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Adv',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',2,);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Atr',1,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
              if ($h->{g_children} eq '1') {
                return ('Adv',4,);
              } elsif ($h->{g_children} eq 'more') {
                return evalSubTree1_S36($h); # [S36]
              }
          }
      } elsif ($h->{g_taghead} eq 'IV3MS') {
          if ($h->{i_taghead} eq 'PREP') {
              if ($h->{i_lemma} =~ /^(?:Hawola|Ealay|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
                return ('Adv',0,);
              } elsif ($h->{i_lemma} eq 'Ean') {
                return ('Obj',1,);
              } elsif ($h->{i_lemma} eq 'fiy') {
                return ('Adv',5,2);
              } elsif ($h->{i_lemma} eq 'li') {
                return ('Obj',4,2);
              } elsif ($h->{i_lemma} eq 'EalaY') {
                return ('Obj',4,1);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                return ('Atr',1,);
              } elsif ($h->{i_lemma} eq 'baEoda') {
                return ('Adv',2,);
              } elsif ($h->{i_lemma} eq 'maEa') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'ilaY') {
                return ('Adv',7,);
              } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
                return ('AuxY',1,);
              } elsif ($h->{i_lemma} eq 'min') {
                return ('Atr',1,);
              } elsif ($h->{i_lemma} eq 'bi') {
                  if ($h->{d_children} eq '1') {
                    return ('Obj',5,2);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',3,);
                  } elsif ($h->{d_children} eq '0') {
                    return evalSubTree1_S37($h); # [S37]
                  }
              }
          } elsif ($h->{i_taghead} eq 'empty') {
            return evalSubTree1_S38($h); # [S38]
          }
      } elsif ($h->{g_taghead} eq 'IV3FS') {
          if ($h->{i_taghead} eq 'PREP') {
              if ($h->{i_lemma} =~ /^(?:Ean|Hawola|Ealay|baEoda|spec_amperltspec_semicolilay|ladaY|qabol|ka|Hatspec_tildaaY|la)$/) {
                return ('Obj',0,);
              } elsif ($h->{i_lemma} eq 'fiy') {
                return ('Adv',9,1);
              } elsif ($h->{i_lemma} eq 'li') {
                return ('Obj',8,2);
              } elsif ($h->{i_lemma} eq 'EalaY') {
                return ('Adv',7,2);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                return ('Atr',1,);
              } elsif ($h->{i_lemma} eq 'maEa') {
                return ('Obj',3,);
              } elsif ($h->{i_lemma} eq 'ilaY') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
                return ('Obj',2,);
              } elsif ($h->{i_lemma} eq 'bayona') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'bi') {
                return ('Obj',11,3);
              } elsif ($h->{i_lemma} eq 'xilAl') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'min') {
                  if ($h->{d_children} eq '0') {
                    return ('Obj',1,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Adv',2,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',2,1);
                  }
              }
          } elsif ($h->{i_taghead} eq 'empty') {
              if ($h->{g_position} eq 'right') {
                return ('Sb',35,);
              } elsif ($h->{g_position} eq 'left') {
                return evalSubTree1_S39($h); # [S39]
              }
          }
      } elsif ($h->{g_taghead} eq 'NOUN') {
          if ($h->{i_taghead} eq 'empty') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',998,31);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',13,1);
              }
          } elsif ($h->{i_taghead} eq 'PREP') {
            return evalSubTree1_S40($h); # [S40]
          }
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
          if ($h->{i_taghead} eq 'PREP') {
              if ($h->{i_lemma} =~ /^(?:Ealay|spec_amperltspec_semicolilay|bayona|ka|la)$/) {
                return ('Adv',0,);
              } elsif ($h->{i_lemma} eq 'Ean') {
                return ('Obj',6,);
              } elsif ($h->{i_lemma} eq 'fiy') {
                return ('Adv',24,1);
              } elsif ($h->{i_lemma} eq 'Hawola') {
                return ('Obj',1,);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                return ('Adv',6,2);
              } elsif ($h->{i_lemma} eq 'baEoda') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'maEa') {
                return ('Obj',2,1);
              } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
                return ('Obj',3,1);
              } elsif ($h->{i_lemma} eq 'min') {
                return ('Adv',7,4);
              } elsif ($h->{i_lemma} eq 'ladaY') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'qabol') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'xilAl') {
                return ('Adv',7,);
              } elsif ($h->{i_lemma} eq 'Hatspec_tildaaY') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'EalaY') {
                return evalSubTree1_S41($h); # [S41]
              } elsif ($h->{i_lemma} eq 'ilaY') {
                  if ($h->{d_children} eq '0') {
                    return ('Adv',2,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Adv',1,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',3,1);
                  }
              } elsif ($h->{i_lemma} eq 'bi') {
                  if ($h->{d_children} eq '0') {
                    return ('Adv',2,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Obj',2,1);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',1,);
                  }
              } elsif ($h->{i_lemma} eq 'li') {
                return evalSubTree1_S42($h); # [S42]
              }
          } elsif ($h->{i_taghead} eq 'empty') {
            return evalSubTree1_S43($h); # [S43]
          }
      } elsif ($h->{g_taghead} eq 'DET') {
          if ($h->{i_taghead} eq 'empty') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',763,6);
              } elsif ($h->{g_position} eq 'right') {
                  if ($h->{d_children} eq '0') {
                    return ('Atr',1,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Sb',2,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Sb',3,1);
                  }
              }
          } elsif ($h->{i_taghead} eq 'PREP') {
            return evalSubTree1_S44($h); # [S44]
          }
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return evalSubTree1_S45($h); # [S45]
      }
  } elsif ($h->{d_taghead} eq 'NOUN') {
      if ($h->{i_taghead} eq 'empty') {
          if ($h->{g_taghead} =~ /^(?:CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|PRON_3MS|IV2D|POSS_PRON_3FS|PART|PRON_3FS|INTERROG_PART|DEM_PRON_MP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PRON_1P)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_taghead} eq 'IV1P') {
            return ('Obj',6,2);
          } elsif ($h->{g_taghead} eq 'PRON_1S') {
            return ('Atr',1,);
          } elsif ($h->{g_taghead} eq 'IV1S') {
            return ('Obj',6,2);
          } elsif ($h->{g_taghead} eq 'IV3MD') {
            return ('Obj',2,1);
          } elsif ($h->{g_taghead} eq 'REL_PRON') {
            return ('Atr',40,3);
          } elsif ($h->{g_taghead} eq 'IVSUFF_DOspec_ddot3MS') {
            return ('Atv',1,);
          } elsif ($h->{g_taghead} eq 'IV3FP') {
            return ('Obj',2,1);
          } elsif ($h->{g_taghead} eq 'DEM_PRON_MS') {
            return ('AuxP',1,);
          } elsif ($h->{g_taghead} eq 'IV2MP') {
            return ('Pnom',2,);
          } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
            return ('Atr',10,1);
          } elsif ($h->{g_taghead} eq 'root') {
            return ('Pnom',13,7);
          } elsif ($h->{g_taghead} eq 'SUBJUNC') {
              if ($h->{d_children} eq '0') {
                return ('Atv',3,);
              } elsif ($h->{d_children} eq '1') {
                return ('Obj',2,1);
              } elsif ($h->{d_children} eq 'more') {
                return ('Ante',1,);
              }
          } elsif ($h->{g_taghead} eq 'NEG_PART') {
            return evalSubTree1_S46($h); # [S46]
          } elsif ($h->{g_taghead} eq 'NOUN') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',926,94);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',14,);
              }
          } elsif ($h->{g_taghead} eq 'ADJ') {
            return evalSubTree1_S47($h); # [S47]
          } elsif ($h->{g_taghead} eq 'ABBREV') {
              if ($h->{g_children} eq '1') {
                return ('Obj',3,);
              } elsif ($h->{g_children} eq 'more') {
                return ('AtrAdv',6,3);
              }
          } elsif ($h->{g_taghead} eq 'IV3FS') {
              if ($h->{g_position} eq 'right') {
                return ('Sb',18,);
              } elsif ($h->{g_position} eq 'left') {
                return evalSubTree1_S48($h); # [S48]
              }
          } elsif ($h->{g_taghead} eq 'PREP') {
              if ($h->{g_children} eq 'more') {
                return ('Sb',2,);
              } elsif ($h->{g_children} eq '1') {
                  if ($h->{d_children} eq '0') {
                    return ('Obj',3,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Obj',2,1);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Adv',1,);
                  }
              }
          } elsif ($h->{g_taghead} eq 'ADV') {
            return evalSubTree1_S49($h); # [S49]
          } elsif ($h->{g_taghead} eq 'DET') {
            return evalSubTree1_S50($h); # [S50]
          } elsif ($h->{g_taghead} eq 'IV3MP') {
              if ($h->{g_position} eq 'right') {
                return ('Sb',3,);
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{g_children} eq '1') {
                    return ('Obj',4,);
                  } elsif ($h->{g_children} eq 'more') {
                      if ($h->{d_children} eq '0') {
                        return ('Adv',0,);
                      } elsif ($h->{d_children} eq '1') {
                        return ('AuxP',4,2);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Adv',3,1);
                      }
                  }
              }
          } elsif ($h->{g_taghead} eq 'IV3MS') {
            return evalSubTree1_S51($h); # [S51]
          } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
              if ($h->{d_children} eq '0') {
                return ('Sb',2,);
              } elsif ($h->{d_children} eq '1') {
                return evalSubTree1_S52($h); # [S52]
              } elsif ($h->{d_children} eq 'more') {
                return evalSubTree1_S53($h); # [S53]
              }
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return evalSubTree1_S54($h); # [S54]
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return evalSubTree1_S55($h); # [S55]
          }
      } elsif ($h->{i_taghead} eq 'PREP') {
        return evalSubTree1_S56($h); # [S56]
      }
  }
}

# SubTree [S1]

sub evalSubTree1_S1 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',9,1);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('Pred',3,);
  }
}

# SubTree [S2]

sub evalSubTree1_S2 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',4,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('spec_qmarkspec_qmarkspec_qmark',8,3);
  }
}

# SubTree [S3]

sub evalSubTree1_S3 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolan') {
    return ('Obj',2,);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'an') {
    return ('Sb',3,1);
  } elsif ($h->{g_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('ExD',1,);
  }
}

# SubTree [S4]

sub evalSubTree1_S4 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxY',0,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'spec_tildaa') {
    return ('AuxY',23,3);
  }
}

# SubTree [S5]

sub evalSubTree1_S5 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|EAm|li|layosspec_plusa|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atv',0,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusat') {
    return ('Atv',5,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Obj',3,1);
  } elsif ($h->{g_lemma} eq 'qAlspec_plusa') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'qAl') {
    return ('Obj',1,);
  }
}

# SubTree [S6]

sub evalSubTree1_S6 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|EAm|li|layosspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atv',0,);
  } elsif ($h->{g_lemma} eq 'kAn') {
    return ('Atv',11,2);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Adv',5,2);
  } elsif ($h->{g_lemma} eq 'qAlspec_plusa') {
    return ('Obj',2,1);
  } elsif ($h->{g_lemma} eq 'qAl') {
    return ('Obj',2,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusa') {
    return ('Atv',4,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolaDAfspec_plusa') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusat') {
      if ($h->{d_children} eq '0') {
        return ('Adv',1,);
      } elsif ($h->{d_children} eq '1') {
        return ('Atv',3,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Atv',7,1);
      }
  }
}

# SubTree [S7]

sub evalSubTree1_S7 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'kAn') {
    return ('Atr',2,);
  } elsif ($h->{d_lemma} eq 'kAnspec_plusat') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Atr',9,);
  }
}

# SubTree [S8]

sub evalSubTree1_S8 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolan') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'an') {
    return ('Adv',10,1);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Obj',46,8);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'inspec_tildaa') {
    return ('Obj',3,);
  } elsif ($h->{g_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('Obj',4,);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
      if ($h->{d_children} eq '0') {
        return ('Adv',1,);
      } elsif ($h->{d_children} eq '1') {
        return ('Obj',9,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',29,5);
      }
  }
}

# SubTree [S9]

sub evalSubTree1_S9 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'gayor') {
    return ('Atr',6,1);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'lA') {
    return ('ExD',2,);
  }
}

# SubTree [S10]

sub evalSubTree1_S10 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxC',0,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('AuxC',55,12);
  } elsif ($h->{d_lemma} eq 'munou') {
    return ('AuxP',17,);
  } elsif ($h->{d_lemma} eq 'lspec_aph2kinspec_tildaa') {
    return ('AuxC',3,1);
  } elsif ($h->{d_lemma} eq 'kamA') {
    return evalSubTree1_S57($h); # [S57]
  }
}

# SubTree [S11]

sub evalSubTree1_S11 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('AuxY',0,);
  } elsif ($h->{g_lemma} eq 'bayonspec_plusa') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Sb',2,1);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('AuxY',2,);
  }
}

# SubTree [S12]

sub evalSubTree1_S12 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxY',0,);
  } elsif ($h->{d_lemma} eq 'qad') {
    return ('AuxE',1,);
  } elsif ($h->{d_lemma} eq 'anspec_tildaa') {
    return ('spec_qmarkspec_qmarkspec_qmark',2,1);
  } elsif ($h->{d_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('AuxY',2,);
  }
}

# SubTree [S13]

sub evalSubTree1_S13 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Adv',5,2);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Sb',8,3);
  }
}

# SubTree [S14]

sub evalSubTree1_S14 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atv',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Pnom',2,1);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_NOM') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atv',6,1);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_DU_ACCGEN') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return evalSubTree1_S58($h); # [S58]
  }
}

# SubTree [S15]

sub evalSubTree1_S15 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxY',0,);
  } elsif ($h->{d_lemma} eq 'huwa') {
    return ('AuxY',2,);
  } elsif ($h->{d_lemma} eq 'hu') {
    return ('Sb',3,1);
  }
}

# SubTree [S16]

sub evalSubTree1_S16 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolan') {
    return ('Obj',14,4);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
    return ('Obj',28,9);
  } elsif ($h->{g_lemma} eq 'an') {
    return ('Sb',19,9);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Obj',24,4);
  } elsif ($h->{g_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('Obj',5,);
  }
}

# SubTree [S17]

sub evalSubTree1_S17 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atv',0,);
  } elsif ($h->{d_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'yaspec_pluskuwn') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'yuspec_plusmokin') {
    return ('Obj',2,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return evalSubTree1_S59($h); # [S59]
  }
}

# SubTree [S18]

sub evalSubTree1_S18 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_lemma} eq 'hA') {
    return ('Sb',18,2);
  } elsif ($h->{d_lemma} eq 'hiya') {
      if ($h->{d_children} eq 'more') {
        return ('AuxY',0,);
      } elsif ($h->{d_children} eq '0') {
        return ('AuxY',10,1);
      } elsif ($h->{d_children} eq '1') {
        return ('Sb',3,1);
      }
  }
}

# SubTree [S19]

sub evalSubTree1_S19 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'yaspec_pluskuwn') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'bayonspec_plusa') {
    return ('Atr',2,1);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Obj',4,2);
  } elsif ($h->{g_lemma} eq 'inspec_tildaa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusduwal') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{i_lemma} =~ /^(?:li|Hawola|EalaY|baEoda|ilaY|spec_amperltspec_semicolilaY|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY)$/) {
        return ('Obj',0,);
      } elsif ($h->{i_lemma} eq 'Ean') {
        return ('Obj',3,);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return ('Obj',17,8);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
        return ('Atr',8,);
      } elsif ($h->{i_lemma} eq 'Ealay') {
        return ('Obj',6,);
      } elsif ($h->{i_lemma} eq 'maEa') {
        return ('Obj',2,);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
        return ('Obj',2,1);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Obj',10,);
      } elsif ($h->{i_lemma} eq 'la') {
        return ('Obj',6,1);
      } elsif ($h->{i_lemma} eq 'min') {
          if ($h->{g_taghead} =~ /^(?:PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV2D|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_taghead} eq 'IV1P') {
            return ('Atr',1,);
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return ('Obj',1,);
          } elsif ($h->{g_taghead} eq 'IV3MP') {
            return ('Obj',1,);
          } elsif ($h->{g_taghead} eq 'IV3MS') {
            return ('Obj',2,);
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('Obj',2,1);
          } elsif ($h->{g_taghead} eq 'NOUN') {
            return ('Atr',5,1);
          }
      }
  }
}

# SubTree [S20]

sub evalSubTree1_S20 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|spec_ddot|naHow|Alspec_plustijArspec_plusap|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|qAl|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('AuxP',0,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusqudos') {
    return ('AuxP',1,);
  } elsif ($h->{g_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('AuxP',2,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Obj',5,1);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusat') {
    return ('AuxP',1,);
  } elsif ($h->{g_lemma} eq '‘') {
    return ('Pred',1,);
  } elsif ($h->{g_lemma} eq 'layosspec_plusa') {
    return ('AuxP',1,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusa') {
    return ('Atv',1,);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusduwal') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
    return evalSubTree1_S60($h); # [S60]
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_taghead} =~ /^(?:PRON_1S|IV1S|NEG_PART|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ABBREV|PRON_1P)$/) {
        return ('AuxP',0,);
      } elsif ($h->{g_taghead} eq 'IV1P') {
        return ('AuxP',2,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('AuxP',30,4);
      } elsif ($h->{g_taghead} eq 'SUBJUNC') {
        return ('AuxP',1,);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('AuxP',2,);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('AuxP',11,1);
      } elsif ($h->{g_taghead} eq 'PART') {
        return ('AuxP',1,);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('AuxP',16,1);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',13,3);
      } elsif ($h->{g_taghead} eq 'ADJ') {
        return ('AuxP',1,);
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return evalSubTree1_S61($h); # [S61]
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return evalSubTree1_S62($h); # [S62]
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return evalSubTree1_S63($h); # [S63]
      }
  }
}

# SubTree [S21]

sub evalSubTree1_S21 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('ExD',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('ExD',54,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return evalSubTree1_S64($h); # [S64]
  }
}

# SubTree [S22]

sub evalSubTree1_S22 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Coord',0,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Apos',2,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('Apos',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Coord',6,1);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('Pred',5,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Apos',1,);
  }
}

# SubTree [S23]

sub evalSubTree1_S23 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('AuxY',2,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Adv',4,1);
  }
}

# SubTree [S24]

sub evalSubTree1_S24 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Adv',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('AtrAdv',2,1);
  }
}

# SubTree [S25]

sub evalSubTree1_S25 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('AuxE',2,1);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Atr',12,2);
  }
}

# SubTree [S26]

sub evalSubTree1_S26 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',3,1);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atr',5,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Adv',3,1);
  }
}

# SubTree [S27]

sub evalSubTree1_S27 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_lemma} eq 'xuSuwSspec_plusAF') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Hatspec_tildaaY') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'ilspec_tildaA') {
    return ('AuxP',8,2);
  } elsif ($h->{d_lemma} eq 'jidspec_tilda') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'naHow') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Obj',0,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('Obj',3,);
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return ('Obj',2,1);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',1,);
      }
  } elsif ($h->{d_lemma} eq 'hunAka') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|NOUN|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Obj',0,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('Adv',2,1);
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
        return ('Atv',1,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return ('Obj',3,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pred',1,);
      }
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return evalSubTree1_S65($h); # [S65]
  }
}

# SubTree [S28]

sub evalSubTree1_S28 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Apos',0,);
  } elsif ($h->{g_lemma} eq 'yaspec_pluskuwn') {
    return ('AuxC',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Apos',4,);
  } elsif ($h->{g_lemma} eq 'qAl') {
    return ('Obj',2,);
  } elsif ($h->{g_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolaDAfspec_plusa') {
    return ('Apos',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Apos',0,);
      } elsif ($h->{g_taghead} eq 'IV3MS') {
        return ('Obj',2,1);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Apos',1,);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Apos',1,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('Pnom',3,1);
      }
  }
}

# SubTree [S29]

sub evalSubTree1_S29 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|EAm|qAl|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'taqodiym') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('AuxY',1,);
  } elsif ($h->{g_lemma} eq 'Hasab') {
    return ('Obj',3,);
  } elsif ($h->{g_lemma} eq 'Didspec_tilda') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'kulspec_tilda') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'qAlspec_plusa') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'li') {
    return ('AtrAdv',1,);
  } elsif ($h->{g_lemma} eq 'layosspec_plusa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'Eadam') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'qarAr') {
    return ('AuxY',1,);
  } elsif ($h->{g_lemma} eq 'hunAka') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'spec_lbraceitspec_tildaifAq') {
    return ('AuxY',2,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return evalSubTree1_S66($h); # [S66]
  }
}

# SubTree [S30]

sub evalSubTree1_S30 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|yuwliyuw|qarAr|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'qiTAE') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusa') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'wizArspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'HAl') {
    return ('AtrAdv',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plussiyAHspec_plusap') {
    return ('Atr',7,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusduwal') {
    return ('Sb',2,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{i_lemma} =~ /^(?:Hawola|Ealay|spec_amperltspec_semicolilay|bi|qabol|ka|xilAl|la)$/) {
        return ('Adv',0,);
      } elsif ($h->{i_lemma} eq 'Ean') {
        return ('Obj',4,2);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Obj',9,5);
      } elsif ($h->{i_lemma} eq 'EalaY') {
        return ('Obj',5,1);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
        return ('AtrAdv',3,2);
      } elsif ($h->{i_lemma} eq 'baEoda') {
        return ('Adv',3,);
      } elsif ($h->{i_lemma} eq 'maEa') {
        return ('Atr',6,2);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
        return ('Adv',7,2);
      } elsif ($h->{i_lemma} eq 'bayona') {
        return ('Atr',2,);
      } elsif ($h->{i_lemma} eq 'ladaY') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'Hatspec_tildaaY') {
        return ('Adv',1,);
      } elsif ($h->{i_lemma} eq 'ilaY') {
          if ($h->{g_children} eq '1') {
            return ('Atr',2,);
          } elsif ($h->{g_children} eq 'more') {
            return ('Adv',6,2);
          }
      } elsif ($h->{i_lemma} eq 'min') {
        return evalSubTree1_S67($h); # [S67]
      } elsif ($h->{i_lemma} eq 'fiy') {
        return evalSubTree1_S68($h); # [S68]
      }
  }
}

# SubTree [S31]

sub evalSubTree1_S31 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'undef') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq '‘') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq '11') {
    return ('Atr',7,);
  } elsif ($h->{g_lemma} eq 'ζ') {
    return ('Atr',3,2);
  } elsif ($h->{g_lemma} eq 'spec_slash') {
    return ('Atr',55,22);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return ('Atr',3,1);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_position} eq 'right') {
        return ('Atr',51,);
      } elsif ($h->{g_position} eq 'left') {
          if ($h->{g_children} eq '1') {
            return ('Atr',6,);
          } elsif ($h->{g_children} eq 'more') {
              if ($h->{d_children} eq 'more') {
                return ('ExD',0,);
              } elsif ($h->{d_children} eq '0') {
                return ('ExD',5,2);
              } elsif ($h->{d_children} eq '1') {
                return ('Sb',2,);
              }
          }
      }
  }
}

# SubTree [S32]

sub evalSubTree1_S32 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|kamA|wa|Alspec_plusdawolspec_plusap|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|Alspec_plusmuqobil|Eadam|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxG',0,);
  } elsif ($h->{d_lemma} eq 'spec_ddot') {
    return ('AuxG',18,1);
  } elsif ($h->{d_lemma} eq 'spec_percnt') {
    return ('Atr',11,3);
  } elsif ($h->{d_lemma} eq '6') {
    return ('Adv',9,);
  } elsif ($h->{d_lemma} eq '7') {
    return ('Atr',26,1);
  } elsif ($h->{d_lemma} eq 'έν') {
    return ('AuxP',10,1);
  } elsif ($h->{d_lemma} eq 'spec_quot') {
    return ('AuxG',494,9);
  } elsif ($h->{d_lemma} eq 'spec_comma') {
    return ('AuxG',12,);
  } elsif ($h->{d_lemma} eq '51') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('ExD',0,);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('ExD',1,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',2,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('ExD',24,);
      }
  } elsif ($h->{d_lemma} eq 'spec_dot') {
    return evalSubTree1_S69($h); # [S69]
  } elsif ($h->{d_lemma} eq 'spec_lbrace') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|IV3MD|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('AuxY',0,);
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
        return ('AuxY',1,);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('AuxY',1,);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
        return ('AuxY',1,);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('AuxG',5,3);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('spec_qmarkspec_qmarkspec_qmark',2,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('AuxY',5,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return ('ExD',1,);
      }
  } elsif ($h->{d_lemma} eq 'spec_rpar') {
    return evalSubTree1_S70($h); # [S70]
  } elsif ($h->{d_lemma} eq '‘') {
      if ($h->{d_children} eq '0') {
        return ('AuxG',230,6);
      } elsif ($h->{d_children} eq '1') {
        return ('spec_qmarkspec_qmarkspec_qmark',1,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Coord',6,2);
      }
  } elsif ($h->{d_lemma} eq 'ζ') {
      if ($h->{d_children} eq '1') {
        return ('Coord',0,);
      } elsif ($h->{d_children} eq '0') {
        return ('AuxY',3,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Coord',7,);
      }
  } elsif ($h->{d_lemma} eq 'spec_slash') {
      if ($h->{d_children} eq '1') {
        return ('Apos',0,);
      } elsif ($h->{d_children} eq '0') {
        return ('AuxG',9,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Apos',28,);
      }
  } elsif ($h->{d_lemma} eq '3') {
    return evalSubTree1_S71($h); # [S71]
  } elsif ($h->{d_lemma} eq '11') {
      if ($h->{i_lemma} =~ /^(?:Ean|li|Hawola|EalaY|Ealay|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return ('AdvAtr',1,);
      } elsif ($h->{i_lemma} eq 'baEoda') {
        return ('Adv',5,);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
          if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('Atr',6,);
          } elsif ($h->{g_taghead} eq 'NOUN') {
            return ('Atr',2,);
          } elsif ($h->{g_taghead} eq 'root') {
            return ('spec_qmarkspec_qmarkspec_qmark',1,);
          }
      }
  } elsif ($h->{d_lemma} eq 'spec_rbrace') {
    return evalSubTree1_S72($h); # [S72]
  } elsif ($h->{d_lemma} eq 'spec_lpar') {
      if ($h->{d_children} eq '1') {
        return ('AuxG',2,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Apos',25,2);
      } elsif ($h->{d_children} eq '0') {
          if ($h->{g_position} eq 'left') {
            return ('ExD',34,3);
          } elsif ($h->{g_position} eq 'right') {
            return ('AuxG',20,1);
          }
      }
  } elsif ($h->{d_lemma} eq 'undef') {
      if ($h->{d_children} eq '1') {
        return ('AuxG',0,);
      } elsif ($h->{d_children} eq 'more') {
          if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|PRON_1P)$/) {
            return ('Coord',0,);
          } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
            return ('Coord',2,1);
          } elsif ($h->{g_taghead} eq 'DET') {
            return ('Coord',1,);
          } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('Coord',4,);
          } elsif ($h->{g_taghead} eq 'NOUN') {
            return ('Apos',3,);
          } elsif ($h->{g_taghead} eq 'ABBREV') {
            return ('Coord',7,1);
          }
      } elsif ($h->{d_children} eq '0') {
          if ($h->{g_children} eq '1') {
            return ('spec_qmarkspec_qmarkspec_qmark',8,1);
          } elsif ($h->{g_children} eq 'more') {
            return evalSubTree1_S73($h); # [S73]
          }
      }
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_taghead} =~ /^(?:PRON_1S|CONJ|POSS_PRON_3D|POSS_PRON_3MS|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|DEM_PRON_MP|DEM_PRON_MS|IV2MP|PRON_3D|PVSUFF_DOspec_ddot3FS|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'IV1P') {
        return ('Obj',2,);
      } elsif ($h->{g_taghead} eq 'SUBJUNC') {
        return ('Obj',3,1);
      } elsif ($h->{g_taghead} eq 'IV1S') {
        return ('Adv',2,1);
      } elsif ($h->{g_taghead} eq 'NEG_PART') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'IV3MD') {
        return ('Obj',1,);
      } elsif ($h->{g_taghead} eq 'ADV') {
        return ('Obj',3,2);
      } elsif ($h->{g_taghead} eq 'REL_PRON') {
        return ('Atr',4,2);
      } elsif ($h->{g_taghead} eq 'undef') {
        return ('Obj',2,);
      } elsif ($h->{g_taghead} eq 'IV3MP') {
        return ('Obj',2,);
      } elsif ($h->{g_taghead} eq 'IV2D') {
        return ('Adv',2,);
      } elsif ($h->{g_taghead} eq 'INTERROG_PART') {
        return ('AuxG',1,);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('Atr',32,3);
      } elsif ($h->{g_taghead} eq 'IV2MS') {
        return ('Obj',1,);
      } elsif ($h->{g_taghead} eq 'FUNC_WORD') {
        return ('Obj',20,7);
      } elsif ($h->{g_taghead} eq 'PREP') {
        return ('Obj',3,1);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|Ealay|maEa|bayona|ladaY|qabol|ka|Hatspec_tildaaY|la)$/) {
            return ('Adv',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',8,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Obj',3,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Sb',68,31);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return ('Obj',2,1);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
            return ('AuxY',1,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Obj',2,);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'xilAl') {
            return ('Adv',2,);
          }
      } elsif ($h->{g_taghead} eq 'IV3MS') {
          if ($h->{i_taghead} eq 'PREP') {
            return ('Adv',8,2);
          } elsif ($h->{i_taghead} eq 'empty') {
            return ('Obj',22,11);
          }
      } elsif ($h->{g_taghead} eq 'ADJ') {
          if ($h->{i_lemma} =~ /^(?:Ean|li|Hawola|EalaY|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('AtrAdv',2,1);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Sb',1,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Atr',4,);
          }
      } elsif ($h->{g_taghead} eq 'DET') {
          if ($h->{i_taghead} eq 'PREP') {
              if ($h->{d_children} eq '0') {
                return ('Adv',1,);
              } elsif ($h->{d_children} eq '1') {
                return ('Adv',4,1);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',2,);
              }
          } elsif ($h->{i_taghead} eq 'empty') {
            return evalSubTree1_S74($h); # [S74]
          }
      } elsif ($h->{g_taghead} eq 'NOUN') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|Ealay|baEoda|spec_amperltspec_semicolilay|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Atr',3,1);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('AdvAtr',3,2);
          } elsif ($h->{i_lemma} eq 'maEa') {
            return ('Atr',3,);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Obj',2,1);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Sb',1,);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return evalSubTree1_S75($h); # [S75]
          } elsif ($h->{i_lemma} eq 'other_lemma') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',214,26);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',2,);
              }
          } elsif ($h->{i_lemma} eq 'min') {
            return evalSubTree1_S76($h); # [S76]
          }
      } elsif ($h->{g_taghead} eq 'IV3FS') {
          if ($h->{g_position} eq 'right') {
            return ('Sb',4,2);
          } elsif ($h->{g_position} eq 'left') {
              if ($h->{i_lemma} =~ /^(?:Ean|li|Hawola|Ealay|baEoda|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
                return ('Obj',0,);
              } elsif ($h->{i_lemma} eq 'fiy') {
                return ('Atr',2,1);
              } elsif ($h->{i_lemma} eq 'EalaY') {
                return ('Obj',1,);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                return ('Obj',18,8);
              } elsif ($h->{i_lemma} eq 'maEa') {
                return ('AuxY',1,);
              } elsif ($h->{i_lemma} eq 'ilaY') {
                return ('Adv',3,1);
              } elsif ($h->{i_lemma} eq 'min') {
                return ('Adv',4,2);
              }
          }
      } elsif ($h->{g_taghead} eq 'root') {
          if ($h->{d_children} eq '0') {
            return ('ExD',43,2);
          } elsif ($h->{d_children} eq 'more') {
            return ('Pred',26,6);
          } elsif ($h->{d_children} eq '1') {
              if ($h->{g_position} eq 'left') {
                return ('Pred',4,1);
              } elsif ($h->{g_position} eq 'right') {
                return ('spec_qmarkspec_qmarkspec_qmark',10,1);
              }
          }
      } elsif ($h->{g_taghead} eq 'ABBREV') {
          if ($h->{g_children} eq '1') {
            return ('spec_qmarkspec_qmarkspec_qmark',7,1);
          } elsif ($h->{g_children} eq 'more') {
              if ($h->{d_children} eq '0') {
                return ('Atr',8,);
              } elsif ($h->{d_children} eq '1') {
                return ('Obj',1,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',2,);
              }
          }
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
          if ($h->{d_children} eq '0') {
            return evalSubTree1_S77($h); # [S77]
          } elsif ($h->{d_children} eq '1') {
              if ($h->{g_children} eq '1') {
                return evalSubTree1_S78($h); # [S78]
              } elsif ($h->{g_children} eq 'more') {
                return evalSubTree1_S79($h); # [S79]
              }
          } elsif ($h->{d_children} eq 'more') {
              if ($h->{i_lemma} =~ /^(?:Ean|fiy|li|Hawola|EalaY|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
                return ('Obj',0,);
              } elsif ($h->{i_lemma} eq 'min') {
                return ('Sb',2,);
              } elsif ($h->{i_lemma} eq 'bayona') {
                return ('Pnom',2,1);
              } elsif ($h->{i_lemma} eq 'bi') {
                return ('Adv',1,);
              } elsif ($h->{i_lemma} eq 'other_lemma') {
                  if ($h->{g_children} eq '1') {
                    return ('Obj',23,13);
                  } elsif ($h->{g_children} eq 'more') {
                    return evalSubTree1_S80($h); # [S80]
                  }
              }
          }
      }
  }
}

# SubTree [S33]

sub evalSubTree1_S33 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'IV3FSspec_plusVERB_IMPERFECT') {
    return ('Obj',4,);
  } elsif ($h->{g_tagtail} eq 'IV1Sspec_plusVERB_IMPERFECT') {
    return ('Obj',2,1);
  } elsif ($h->{g_tagtail} eq 'IV3MSspec_plusVERB_IMPERFECT') {
    return ('Sb',2,);
  }
}

# SubTree [S34]

sub evalSubTree1_S34 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plussabot') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Atr',19,2);
  } elsif ($h->{d_lemma} eq 'Alspec_plusduwal') {
    return ('Atr',2,);
  }
}

# SubTree [S35]

sub evalSubTree1_S35 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Obj',3,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',2,);
  }
}

# SubTree [S36]

sub evalSubTree1_S36 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Obj',3,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',5,1);
  }
}

# SubTree [S37]

sub evalSubTree1_S37 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Adv',2,);
  } elsif ($h->{d_tagtail} eq 'NOUN') {
    return ('Obj',3,1);
  }
}

# SubTree [S38]

sub evalSubTree1_S38 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_lbraceiqotiSAd') {
    return ('Sb',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('Sb',6,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusyawom') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusEirAq') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_amperltspec_semicolirohAb') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusabAb') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plussabot') {
    return ('Adv',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusnafoT') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return evalSubTree1_S81($h); # [S81]
  }
}

# SubTree [S39]

sub evalSubTree1_S39 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Sb',9,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('Sb',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_dollararikspec_plusAt') {
    return ('AuxC',2,1);
  } elsif ($h->{d_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return evalSubTree1_S82($h); # [S82]
  }
}

# SubTree [S40]

sub evalSubTree1_S40 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|sibotamobir|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|spec_comma|spec_asterspec_aph2lika|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqudos') {
    return ('Adv',3,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Obj',3,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plustaEAwun') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusyawom') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusdawolspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_amperltspec_semicolirohAb') {
    return ('Atr',3,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqiTAE') {
    return ('AdvAtr',2,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusxArijiyspec_tildaspec_plusap') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusSAdirspec_plusAt') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_dollararikspec_plusAt') {
    return ('Obj',3,2);
  } elsif ($h->{d_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('Atr',4,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusduwal') {
    return ('Atr',3,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusEirAq') {
      if ($h->{i_lemma} =~ /^(?:Hawola|EalaY|other_lemma|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilay|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'Ean') {
        return ('Obj',3,);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Atr',2,1);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
        return ('Adv',3,1);
      } elsif ($h->{i_lemma} eq 'min') {
        return ('Atr',1,);
      }
  } elsif ($h->{d_lemma} eq 'Alspec_plusbilAd') {
    return evalSubTree1_S83($h); # [S83]
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{i_lemma} =~ /^(?:Ealay|baEoda|bayona|qabol|ka|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'Ean') {
        return ('Obj',3,2);
      } elsif ($h->{i_lemma} eq 'Hawola') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'ilaY') {
        return ('Atr',9,4);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
        return ('Atr',9,5);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
        return ('Obj',1,);
      } elsif ($h->{i_lemma} eq 'min') {
        return ('Atr',48,12);
      } elsif ($h->{i_lemma} eq 'ladaY') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'xilAl') {
        return ('Atr',2,1);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return evalSubTree1_S84($h); # [S84]
      } elsif ($h->{i_lemma} eq 'li') {
        return evalSubTree1_S85($h); # [S85]
      } elsif ($h->{i_lemma} eq 'other_lemma') {
          if ($h->{d_children} eq '0') {
            return ('Atr',3,1);
          } elsif ($h->{d_children} eq '1') {
            return ('Atr',2,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Obj',1,);
          }
      } elsif ($h->{i_lemma} eq 'maEa') {
          if ($h->{d_children} eq 'more') {
            return ('Atr',0,);
          } elsif ($h->{d_children} eq '0') {
            return ('Obj',4,2);
          } elsif ($h->{d_children} eq '1') {
            return ('Atr',2,);
          }
      } elsif ($h->{i_lemma} eq 'bi') {
        return evalSubTree1_S86($h); # [S86]
      } elsif ($h->{i_lemma} eq 'EalaY') {
        return evalSubTree1_S87($h); # [S87]
      }
  }
}

# SubTree [S41]

sub evalSubTree1_S41 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MD') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Obj',3,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FD') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Obj',5,2);
  }
}

# SubTree [S42]

sub evalSubTree1_S42 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Obj',6,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Adv',5,2);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return evalSubTree1_S88($h); # [S88]
  }
}

# SubTree [S43]

sub evalSubTree1_S43 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|yuspec_plusmokin|b|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Sb',8,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusyawom') {
    return ('Adv',7,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusEirAq') {
    return ('Obj',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqiTAE') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusjumoEspec_plusap') {
    return ('Adv',5,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusabAb') {
    return ('Sb',4,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plussabot') {
    return ('Adv',12,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusbilAd') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_dollararikspec_plusAt') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plussiyAHspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusduwal') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return evalSubTree1_S89($h); # [S89]
  } elsif ($h->{d_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
      if ($h->{g_position} eq 'left') {
        return ('Obj',3,1);
      } elsif ($h->{g_position} eq 'right') {
        return ('Sb',2,);
      }
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_position} eq 'right') {
        return ('Sb',25,);
      } elsif ($h->{g_position} eq 'left') {
        return evalSubTree1_S90($h); # [S90]
      }
  }
}

# SubTree [S44]

sub evalSubTree1_S44 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusqudos') {
    return ('Atv',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Atr',2,1);
  } elsif ($h->{g_lemma} eq 'Alspec_plustaEAwun') {
    return ('Obj',3,1);
  } elsif ($h->{g_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusEarabiyspec_tildaspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusnafoT') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusSAdirspec_plusAt') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusduwal') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return evalSubTree1_S91($h); # [S91]
  }
}

# SubTree [S45]

sub evalSubTree1_S45 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|6|madiynspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_lbraceiqotiSAd') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusyawom') {
    return ('Atr',2,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusdawolspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusEarabiyspec_tildaspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusEirAq') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_amperltspec_semicolirohAb') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusjumoEspec_plusap') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plussabot') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_amperltspec_semicolisokAn') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('ExD',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusmADiy') {
    return ('Atr',3,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusduwal') {
    return ('Atr',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusduwaliyspec_tilda') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{i_lemma} =~ /^(?:Ean|Hawola|Ealay|baEoda|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'EalaY') {
        return ('Obj',3,1);
      } elsif ($h->{i_lemma} eq 'maEa') {
        return ('Obj',1,);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Obj',4,2);
      } elsif ($h->{i_lemma} eq 'fiy') {
          if ($h->{d_children} eq 'more') {
            return ('Atr',0,);
          } elsif ($h->{d_children} eq '0') {
            return ('Atr',4,);
          } elsif ($h->{d_children} eq '1') {
            return ('Adv',3,1);
          }
      } elsif ($h->{i_lemma} eq 'li') {
          if ($h->{d_children} eq '0') {
            return ('Obj',0,);
          } elsif ($h->{d_children} eq '1') {
            return ('Obj',3,1);
          } elsif ($h->{d_children} eq 'more') {
            return ('Atr',2,1);
          }
      } elsif ($h->{i_lemma} eq 'min') {
          if ($h->{d_children} eq '0') {
            return ('Atr',5,3);
          } elsif ($h->{d_children} eq 'more') {
            return ('Atr',4,);
          } elsif ($h->{d_children} eq '1') {
              if ($h->{g_children} eq '1') {
                return ('Atr',3,1);
              } elsif ($h->{g_children} eq 'more') {
                return ('AtrAdv',3,1);
              }
          }
      } elsif ($h->{i_lemma} eq 'other_lemma') {
          if ($h->{g_children} eq '1') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',32,);
              } elsif ($h->{g_position} eq 'right') {
                return ('AuxE',2,1);
              }
          } elsif ($h->{g_children} eq 'more') {
            return evalSubTree1_S92($h); # [S92]
          }
      }
  }
}

# SubTree [S46]

sub evalSubTree1_S46 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'gayor') {
    return ('Atr',5,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'lA') {
    return ('Sb',5,);
  } elsif ($h->{g_lemma} eq 'layosspec_plusa') {
    return ('Adv',3,2);
  }
}

# SubTree [S47]

sub evalSubTree1_S47 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',5,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Atr',4,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atv',2,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Atr',11,1);
  }
}

# SubTree [S48]

sub evalSubTree1_S48 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|ζ|Alspec_plusmuqobil|spec_slash|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_lemma} eq 'gAlibiyspec_tildaspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Hasab') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'ziyAdspec_plusap') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Obj',106,48);
  } elsif ($h->{d_lemma} eq 'Didspec_tilda') {
    return ('AuxP',2,);
  } elsif ($h->{d_lemma} eq 'fatorspec_plusap') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'waziyr') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'kulspec_tilda') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'majomuwEspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Hajom') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Eadam') {
    return ('Obj',2,);
  } elsif ($h->{d_lemma} eq 'wizArspec_plusap') {
    return ('Sb',3,);
  }
}

# SubTree [S49]

sub evalSubTree1_S49 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_lemma} eq 'naHow') {
    return ('Atr',3,1);
  } elsif ($h->{g_lemma} eq 'hunAka') {
    return ('Sb',9,1);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_children} eq '1') {
        return ('Adv',4,1);
      } elsif ($h->{g_children} eq 'more') {
        return evalSubTree1_S93($h); # [S93]
      }
  }
}

# SubTree [S50]

sub evalSubTree1_S50 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'Didspec_tilda') {
    return ('AuxP',2,);
  } elsif ($h->{d_lemma} eq 'EAm') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'muqAbil') {
    return ('AuxP',5,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_children} eq '1') {
        return ('Atr',18,3);
      } elsif ($h->{g_children} eq 'more') {
        return evalSubTree1_S94($h); # [S94]
      }
  }
}

# SubTree [S51]

sub evalSubTree1_S51 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|CASE_ACC|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_DU_ACCGEN_POSS') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN_POSS') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_DU_NOM') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Obj',3,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return evalSubTree1_S95($h); # [S95]
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return evalSubTree1_S96($h); # [S96]
  } elsif ($h->{d_tagtail} eq 'empty') {
    return evalSubTree1_S97($h); # [S97]
  }
}

# SubTree [S52]

sub evalSubTree1_S52 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',4,2);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Obj',6,2);
  }
}

# SubTree [S53]

sub evalSubTree1_S53 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Obj',20,4);
  } elsif ($h->{g_lemma} eq 'inspec_tildaa') {
    return ('Pnom',1,);
  } elsif ($h->{g_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('Obj',4,);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
    return evalSubTree1_S98($h); # [S98]
  }
}

# SubTree [S54]

sub evalSubTree1_S54 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|lam|Alspec_plusraspec_rbraceiys|lan|miSor|daEom|Alspec_plustaEAwun|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|ζ|Alspec_plusmuqobil|Eadam|spec_slash|fiy|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|Alspec_tildaatiy|hunAka|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_lemma} eq 'baronAmaj') {
    return ('Sb',3,1);
  } elsif ($h->{d_lemma} eq 'ragom') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'majolis') {
    return ('Sb',2,);
  } elsif ($h->{d_lemma} eq 'spec_lbraceisom') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'taqodiym') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'yawom') {
    return ('Adv',7,);
  } elsif ($h->{d_lemma} eq 'madiynspec_plusap') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'gAlibiyspec_tildaspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'Hasab') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'maSAdir') {
    return ('Sb',5,);
  } elsif ($h->{d_lemma} eq 'Didspec_tilda') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'binAspec_aph') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'fatorspec_plusap') {
    return ('Adv',2,);
  } elsif ($h->{d_lemma} eq 'waziyr') {
    return ('Sb',12,);
  } elsif ($h->{d_lemma} eq 'kulspec_tilda') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'EAm') {
    return ('Adv',6,);
  } elsif ($h->{d_lemma} eq 'muqAbil') {
    return ('Adv',2,1);
  } elsif ($h->{d_lemma} eq 'majomuwEspec_plusap') {
    return ('Sb',3,1);
  } elsif ($h->{d_lemma} eq 'Eadad') {
    return ('Sb',2,);
  } elsif ($h->{d_lemma} eq 'Hajom') {
    return ('Sb',2,);
  } elsif ($h->{d_lemma} eq 'wizArspec_plusap') {
    return ('Sb',3,);
  } elsif ($h->{d_lemma} eq 'raspec_rbraceiys') {
    return ('Sb',4,);
  } elsif ($h->{d_lemma} eq 'HAl') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'qarAr') {
    return ('Atr',2,1);
  } elsif ($h->{d_lemma} eq 'SaHiyfspec_plusap') {
    return ('Sb',6,);
  } elsif ($h->{d_lemma} eq 'qiymspec_plusap') {
    return ('Sb',3,1);
  } elsif ($h->{d_lemma} eq 'spec_lbraceitspec_tildaifAq') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_position} eq 'right') {
        return ('Sb',27,3);
      } elsif ($h->{g_position} eq 'left') {
        return evalSubTree1_S99($h); # [S99]
      }
  }
}

# SubTree [S55]

sub evalSubTree1_S55 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq '3') {
    return ('Atr',8,);
  } elsif ($h->{g_lemma} eq 'undef') {
    return ('Atr',4,2);
  } elsif ($h->{g_lemma} eq '‘') {
    return ('Adv',2,1);
  } elsif ($h->{g_lemma} eq '11') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq 'ζ') {
    return ('AuxY',1,);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return evalSubTree1_S100($h); # [S100]
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{d_children} eq '0') {
        return ('Atr',47,5);
      } elsif ($h->{d_children} eq '1') {
          if ($h->{g_children} eq '1') {
            return ('Atr',85,7);
          } elsif ($h->{g_children} eq 'more') {
            return evalSubTree1_S101($h); # [S101]
          }
      } elsif ($h->{d_children} eq 'more') {
        return evalSubTree1_S102($h); # [S102]
      }
  }
}

# SubTree [S56]

sub evalSubTree1_S56 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:spec_ddot|naHow|Alspec_plustijArspec_plusap|jadiydspec_plusap|ragom|Eamaliyspec_tildaspec_plusAt|gayor|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|miSor|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|spec_rpar|Alspec_plusnafoT|maSAdir|spec_quot|spec_amperltspec_semicolilaY|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|aDAf|spec_ampergtspec_semicolayspec_tilda|humA|waziyr|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|EAm|li|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|spec_slash|wizArspec_plusap|jiniyh|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|jidspec_tilda)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_lemma} eq 'ayspec_tilda') {
    return ('Atr',2,1);
  } elsif ($h->{g_lemma} eq 'Alspec_plusqudos') {
    return ('AuxY',1,);
  } elsif ($h->{g_lemma} eq 'baronAmaj') {
    return ('Atr',3,);
  } elsif ($h->{g_lemma} eq 'majolis') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusspec_lbraceiqotiSAd') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'hA') {
    return ('Atv',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'taqodiym') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'daEom') {
    return ('Atr',4,2);
  } elsif ($h->{g_lemma} eq 'Alspec_plusyawom') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'xuSuwSspec_plusAF') {
    return ('Adv',5,);
  } elsif ($h->{g_lemma} eq 'anspec_tildaa') {
    return ('Adv',9,4);
  } elsif ($h->{g_lemma} eq 'yaspec_pluskuwn') {
    return ('Obj',5,3);
  } elsif ($h->{g_lemma} eq 'madiynspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq '51') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'hi') {
    return ('Atr',3,);
  } elsif ($h->{g_lemma} eq 'gAlibiyspec_tildaspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'kAn') {
    return ('Adv',3,1);
  } elsif ($h->{g_lemma} eq 'ziyAdspec_plusap') {
    return ('Atr',4,1);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('Sb',4,1);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusat') {
    return ('Adv',3,);
  } elsif ($h->{g_lemma} eq 'Didspec_tilda') {
    return ('AuxE',1,);
  } elsif ($h->{g_lemma} eq 'min') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'binAspec_aph') {
    return ('Adv',3,1);
  } elsif ($h->{g_lemma} eq 'fatorspec_plusap') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolakspec_tildaadspec_plusa') {
    return ('Adv',3,);
  } elsif ($h->{g_lemma} eq 'Hawola') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq 'kaos') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'mA') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'qAlspec_plusa') {
    return ('Adv',4,1);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusa') {
    return ('Obj',2,1);
  } elsif ($h->{g_lemma} eq 'ilspec_tildaA') {
    return ('Adv',2,);
  } elsif ($h->{g_lemma} eq 'nA') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq 'Eadam') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'raspec_rbraceiys') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'EalaY') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'hunAka') {
    return ('Adv',2,);
  } elsif ($h->{g_lemma} eq 'spec_lbraceitspec_tildaifAq') {
    return ('Adv',1,);
  } elsif ($h->{g_lemma} eq 'yaspec_plustimspec_tilda') {
      if ($h->{d_children} eq '0') {
        return ('Atv',2,);
      } elsif ($h->{d_children} eq '1') {
        return ('Adv',5,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Adv',1,);
      }
  } elsif ($h->{g_lemma} eq '‘') {
      if ($h->{i_lemma} =~ /^(?:Ean|fiy|Hawola|EalaY|other_lemma|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Atr',2,);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Adv',2,1);
      }
  } elsif ($h->{g_lemma} eq 'layosspec_plusa') {
      if ($h->{g_position} eq 'left') {
        return ('Adv',3,1);
      } elsif ($h->{g_position} eq 'right') {
        return ('AuxY',2,);
      }
  } elsif ($h->{g_lemma} eq 'qAl') {
      if ($h->{i_lemma} =~ /^(?:Ean|Hawola|EalaY|other_lemma|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Adv',0,);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return ('Adv',3,1);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Obj',4,1);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Adv',3,);
      }
  } elsif ($h->{g_lemma} eq 'qarAr') {
      if ($h->{g_children} eq '1') {
        return ('Atr',2,);
      } elsif ($h->{g_children} eq 'more') {
        return ('Obj',2,);
      }
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return evalSubTree1_S103($h); # [S103]
  }
}

# SubTree [S57]

sub evalSubTree1_S57 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('AuxC',0,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('AuxC',1,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('AuxC',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('AuxC',2,);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('AuxY',2,);
  }
}

# SubTree [S58]

sub evalSubTree1_S58 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Sb',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Atr',2,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Sb',3,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Obj',4,2);
  }
}

# SubTree [S59]

sub evalSubTree1_S59 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Atv',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Atv',6,2);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Obj',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return evalSubTree1_S104($h); # [S104]
  }
}

# SubTree [S60]

sub evalSubTree1_S60 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_lemma} eq 'Ealay') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'min') {
    return ('Obj',2,);
  } elsif ($h->{d_lemma} eq 'li') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'EalaY') {
    return ('AuxP',2,);
  }
}

# SubTree [S61]

sub evalSubTree1_S61 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|iy|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|spec_quot|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|kaos|sa|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxP',0,);
  } elsif ($h->{d_lemma} eq 'ilaY') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'bi') {
    return ('AuxP',3,1);
  } elsif ($h->{d_lemma} eq 'maEa') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'spec_amperltspec_semicolilaY') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'min') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'baEoda') {
    return ('AuxC',1,);
  } elsif ($h->{d_lemma} eq 'spec_amperltspec_semicolilay') {
    return ('AuxP',4,);
  } elsif ($h->{d_lemma} eq 'fiy') {
    return ('AuxC',1,);
  }
}

# SubTree [S62]

sub evalSubTree1_S62 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxP',0,);
  } elsif ($h->{d_lemma} eq 'Ealay') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'bayonspec_plusa') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'min') {
    return ('AuxP',2,);
  } elsif ($h->{d_lemma} eq 'li') {
    return ('AuxP',2,);
  } elsif ($h->{d_lemma} eq 'bayona') {
    return ('Atr',2,);
  }
}

# SubTree [S63]

sub evalSubTree1_S63 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|kaos|sa|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('AuxP',0,);
  } elsif ($h->{d_lemma} eq 'Ealay') {
    return ('AuxP',2,);
  } elsif ($h->{d_lemma} eq 'bi') {
    return ('AuxP',2,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Apos',2,);
  } elsif ($h->{d_lemma} eq 'min') {
    return ('AuxP',15,3);
  } elsif ($h->{d_lemma} eq 'baEoda') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'spec_amperltspec_semicolilay') {
    return ('AuxP',6,1);
  } elsif ($h->{d_lemma} eq 'la') {
    return ('Pred',1,);
  } elsif ($h->{d_lemma} eq 'li') {
    return ('AuxP',1,);
  } elsif ($h->{d_lemma} eq 'bayona') {
    return ('Atr',2,);
  } elsif ($h->{d_lemma} eq 'fiy') {
    return ('AuxP',4,);
  }
}

# SubTree [S64]

sub evalSubTree1_S64 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'w') {
    return ('AuxY',5,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('Atr',8,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('ExD',1,);
      } elsif ($h->{g_taghead} eq 'ABBREV') {
        return ('Atr',3,);
      }
  }
}

# SubTree [S65]

sub evalSubTree1_S65 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return evalSubTree1_S105($h); # [S105]
  } elsif ($h->{d_tagtail} eq 'empty') {
    return evalSubTree1_S106($h); # [S106]
  }
}

# SubTree [S66]

sub evalSubTree1_S66 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',3,1);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('AuxY',1,);
  } elsif ($h->{g_tagtail} eq 'ADJspec_plusNSUFF_FEM_SG') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Atr',3,1);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ') {
    return ('Obj',2,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'IV3MSspec_plusVERB_IMPERFECT') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
      if ($h->{i_taghead} eq 'PREP') {
        return ('Obj',4,1);
      } elsif ($h->{i_taghead} eq 'empty') {
        return ('Adv',2,1);
      }
  } elsif ($h->{g_tagtail} eq 'empty') {
      if ($h->{i_lemma} =~ /^(?:Ean|Hawola|EalaY|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'fiy') {
        return ('AtrAdv',2,1);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Obj',1,);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
        return ('Atr',15,5);
      } elsif ($h->{i_lemma} eq 'min') {
        return ('Atr',2,);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Adv',1,);
      }
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
      if ($h->{i_taghead} eq 'PREP') {
        return ('Obj',4,2);
      } elsif ($h->{i_taghead} eq 'empty') {
        return ('AuxC',2,1);
      }
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
      if ($h->{g_position} eq 'right') {
        return ('Sb',4,);
      } elsif ($h->{g_position} eq 'left') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|Ealay|baEoda|maEa|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Adv',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',2,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Obj',10,1);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Obj',2,1);
          }
      }
  }
}

# SubTree [S67]

sub evalSubTree1_S67 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'sibotamobir') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'bagodAd') {
    return ('Atr',2,1);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_children} eq '1') {
        return ('Atr',8,);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',3,1);
      }
  }
}

# SubTree [S68]

sub evalSubTree1_S68 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',5,3);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_NOM') {
    return ('AtrAdv',1,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Adv',4,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Adv',5,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('AdvAtr',2,1);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Adv',4,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('AdvAtr',3,1);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_MASC_DU_ACCGEN') {
    return ('Adv',3,);
  } elsif ($h->{g_tagtail} eq 'NOUN_PROP') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'ADJ') {
    return ('AdvAtr',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Adv',4,);
  } elsif ($h->{g_tagtail} eq 'empty') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Adv',0,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('Adv',2,);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('AdvAtr',4,1);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Adv',7,2);
      }
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return evalSubTree1_S107($h); # [S107]
  }
}

# SubTree [S69]

sub evalSubTree1_S69 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('AuxK',0,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('ExD',3,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('AuxG',6,1);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('AuxK',465,8);
  }
}

# SubTree [S70]

sub evalSubTree1_S70 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('AuxG',0,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('AuxG',2,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('AuxG',3,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('AuxG',52,16);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('ExD',27,);
  }
}

# SubTree [S71]

sub evalSubTree1_S71 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'undef') {
    return ('Adv',4,);
  } elsif ($h->{g_lemma} eq 'w') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'kaos') {
    return ('AdvAtr',1,);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{d_children} eq '0') {
        return ('Atr',3,);
      } elsif ($h->{d_children} eq '1') {
        return ('Atr',2,);
      } elsif ($h->{d_children} eq 'more') {
        return ('AdvAtr',1,);
      }
  }
}

# SubTree [S72]

sub evalSubTree1_S72 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('AuxY',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('AuxY',3,1);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('AuxG',2,);
  } elsif ($h->{g_tagtail} eq 'NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('AuxY',1,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('AuxY',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
      if ($h->{d_children} eq 'more') {
        return ('AuxY',0,);
      } elsif ($h->{d_children} eq '0') {
        return ('AuxY',5,1);
      } elsif ($h->{d_children} eq '1') {
        return ('spec_qmarkspec_qmarkspec_qmark',2,);
      }
  }
}

# SubTree [S73]

sub evalSubTree1_S73 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('AuxG',0,);
  } elsif ($h->{g_lemma} eq '51') {
    return ('AuxG',27,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|DEM_PRON_MS|IV2MP|IV2MS|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('AuxG',0,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('AuxG',3,);
      } elsif ($h->{g_taghead} eq 'NOUN_PROP') {
        return ('AuxG',4,);
      } elsif ($h->{g_taghead} eq 'root') {
        return ('AuxK',41,3);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
          if ($h->{g_position} eq 'left') {
            return ('Atr',3,);
          } elsif ($h->{g_position} eq 'right') {
            return ('AuxG',3,1);
          }
      }
  }
}

# SubTree [S74]

sub evalSubTree1_S74 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('Atr',9,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusyawom') {
    return ('AuxY',1,);
  } elsif ($h->{g_lemma} eq 'Alspec_plusnafoT') {
    return ('AuxP',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Atr',61,7);
  } elsif ($h->{g_lemma} eq 'Alspec_plusduwal') {
    return ('Atr',2,);
  }
}

# SubTree [S75]

sub evalSubTree1_S75 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Adv',7,3);
  }
}

# SubTree [S76]

sub evalSubTree1_S76 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Sb',3,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',2,1);
  }
}

# SubTree [S77]

sub evalSubTree1_S77 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'έν') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'undef') {
    return ('Adv',9,);
  } elsif ($h->{g_lemma} eq 'ζ') {
    return ('Atr',3,);
  } elsif ($h->{g_lemma} eq 'spec_slash') {
    return ('Atr',6,2);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{i_lemma} =~ /^(?:Ean|fiy|li|Hawola|EalaY|Ealay|baEoda|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|min|bayona|bi|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'other_lemma') {
        return ('Atr',101,19);
      } elsif ($h->{i_lemma} eq 'maEa') {
        return ('Obj',2,);
      } elsif ($h->{i_lemma} eq 'ilaY') {
        return ('Atr',1,);
      }
  }
}

# SubTree [S78]

sub evalSubTree1_S78 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('spec_qmarkspec_qmarkspec_qmark',0,);
  } elsif ($h->{g_lemma} eq 'έν') {
    return ('Atr',7,2);
  } elsif ($h->{g_lemma} eq 'spec_lbrace') {
    return ('spec_qmarkspec_qmarkspec_qmark',2,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('spec_qmarkspec_qmarkspec_qmark',42,25);
  } elsif ($h->{g_lemma} eq '‘') {
    return ('spec_qmarkspec_qmarkspec_qmark',1,);
  } elsif ($h->{g_lemma} eq 'spec_rbrace') {
    return ('spec_qmarkspec_qmarkspec_qmark',1,);
  }
}

# SubTree [S79]

sub evalSubTree1_S79 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq '‘') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'ζ') {
    return ('Sb',3,);
  } elsif ($h->{g_lemma} eq 'spec_slash') {
    return ('Atr',1,);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return ('Atr',21,10);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{i_taghead} eq 'PREP') {
        return ('Atr',2,1);
      } elsif ($h->{i_taghead} eq 'empty') {
          if ($h->{g_position} eq 'left') {
            return ('AuxP',24,17);
          } elsif ($h->{g_position} eq 'right') {
            return ('Sb',3,1);
          }
      }
  }
}

# SubTree [S80]

sub evalSubTree1_S80 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'spec_lpar') {
    return ('Adv',4,2);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_position} eq 'left') {
        return ('Atr',10,5);
      } elsif ($h->{g_position} eq 'right') {
        return ('Sb',2,1);
      }
  } elsif ($h->{g_lemma} eq 'ζ') {
      if ($h->{g_position} eq 'left') {
        return ('Obj',4,2);
      } elsif ($h->{g_position} eq 'right') {
        return ('ExD',3,1);
      }
  }
}

# SubTree [S81]

sub evalSubTree1_S81 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('Sb',5,);
  } elsif ($h->{g_lemma} eq 'yaspec_pluskuwn') {
    return ('Sb',3,1);
  } elsif ($h->{g_lemma} eq 'yuspec_plusmokin') {
    return ('Sb',2,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return evalSubTree1_S108($h); # [S108]
  }
}

# SubTree [S82]

sub evalSubTree1_S82 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROPspec_plusNSUFF_FEM_SG') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN') {
    return ('Obj',21,5);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Sb',4,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
    return ('Adv',2,1);
  } elsif ($h->{d_tagtail} eq 'ADJ') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
      if ($h->{d_children} eq '0') {
        return ('Obj',10,5);
      } elsif ($h->{d_children} eq '1') {
        return ('Obj',10,2);
      } elsif ($h->{d_children} eq 'more') {
        return ('Sb',6,1);
      }
  }
}

# SubTree [S83]

sub evalSubTree1_S83 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('AtrAdv',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',2,1);
  }
}

# SubTree [S84]

sub evalSubTree1_S84 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',9,3);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Adv',5,1);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('AtrAdv',2,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',39,18);
  }
}

# SubTree [S85]

sub evalSubTree1_S85 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Atr',20,8);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Obj',3,2);
  } elsif ($h->{d_tagtail} eq 'ADJspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN') {
    return ('Atr',34,11);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Atr',2,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
    return ('Obj',4,1);
  }
}

# SubTree [S86]

sub evalSubTree1_S86 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',6,1);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
      if ($h->{g_children} eq '1') {
        return ('Atr',2,);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',4,1);
      }
  }
}

# SubTree [S87]

sub evalSubTree1_S87 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_DU_ACCGEN') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
    return ('Atr',3,1);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return evalSubTree1_S109($h); # [S109]
  } elsif ($h->{d_tagtail} eq 'NOUN') {
      if ($h->{d_children} eq '1') {
        return ('Obj',4,1);
      } elsif ($h->{d_children} eq 'more') {
        return ('Pnom',1,);
      } elsif ($h->{d_children} eq '0') {
        return evalSubTree1_S110($h); # [S110]
      }
  }
}

# SubTree [S88]

sub evalSubTree1_S88 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Obj',4,2);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN') {
    return ('Adv',3,);
  }
}

# SubTree [S89]

sub evalSubTree1_S89 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Sb',3,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Sb',2,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Obj',1,);
  }
}

# SubTree [S90]

sub evalSubTree1_S90 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|EAm|li|layosspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_lemma} eq 'kAn') {
    return ('Sb',3,);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusat') {
    return ('Sb',2,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolakspec_tildaadspec_plusa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'qAlspec_plusa') {
    return ('Sb',4,);
  } elsif ($h->{g_lemma} eq 'qAl') {
    return ('Sb',5,1);
  } elsif ($h->{g_lemma} eq 'kAnspec_plusa') {
    return ('Ante',1,);
  } elsif ($h->{g_lemma} eq 'spec_ampergtspec_semicolaDAfspec_plusa') {
    return ('Sb',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return evalSubTree1_S111($h); # [S111]
  }
}

# SubTree [S91]

sub evalSubTree1_S91 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|sibotamobir|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqudos') {
    return ('Atr',3,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_lbraceiqotiSAd') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('Atr',3,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('Adv',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusdawolspec_plusap') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusEirAq') {
    return ('Adv',5,3);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_amperltspec_semicolirohAb') {
    return ('Obj',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusqiTAE') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusnafoT') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plusbilAd') {
    return ('Atr',5,2);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_amperltspec_semicolisokAn') {
    return ('Atr',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusSAdirspec_plusAt') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusspec_dollararikspec_plusAt') {
    return ('Atr',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('AtrAdv',2,1);
  } elsif ($h->{d_lemma} eq 'Alspec_plussiyAHspec_plusap') {
    return ('Atr',2,);
  } elsif ($h->{d_lemma} eq 'Alspec_plusduwal') {
    return ('Atr',2,1);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{i_lemma} =~ /^(?:Hawola|other_lemma|baEoda|spec_amperltspec_semicolilay|ladaY|ka|xilAl|Hatspec_tildaaY|la)$/) {
        return ('Atr',0,);
      } elsif ($h->{i_lemma} eq 'li') {
        return ('Atr',34,8);
      } elsif ($h->{i_lemma} eq 'EalaY') {
        return ('Atr',13,6);
      } elsif ($h->{i_lemma} eq 'Ealay') {
        return ('Obj',1,);
      } elsif ($h->{i_lemma} eq 'maEa') {
        return ('Atr',5,1);
      } elsif ($h->{i_lemma} eq 'ilaY') {
        return ('Atr',2,1);
      } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
        return ('Adv',2,);
      } elsif ($h->{i_lemma} eq 'bayona') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'bi') {
        return ('Atr',8,2);
      } elsif ($h->{i_lemma} eq 'qabol') {
        return ('Atr',1,);
      } elsif ($h->{i_lemma} eq 'Ean') {
          if ($h->{g_children} eq '1') {
            return ('Atr',7,2);
          } elsif ($h->{g_children} eq 'more') {
            return ('Obj',3,1);
          }
      } elsif ($h->{i_lemma} eq 'min') {
          if ($h->{g_children} eq '1') {
            return ('Obj',9,4);
          } elsif ($h->{g_children} eq 'more') {
            return ('Atr',5,);
          }
      } elsif ($h->{i_lemma} eq 'fiy') {
          if ($h->{d_children} eq 'more') {
            return ('Obj',1,);
          } elsif ($h->{d_children} eq '1') {
            return evalSubTree1_S112($h); # [S112]
          } elsif ($h->{d_children} eq '0') {
            return evalSubTree1_S113($h); # [S113]
          }
      }
  }
}

# SubTree [S92]

sub evalSubTree1_S92 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'ADJspec_plusNSUFF_FEM_SG') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Atr',3,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_DU_ACCGEN') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
    return ('Adv',2,);
  } elsif ($h->{d_tagtail} eq 'ADJ') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
      if ($h->{g_position} eq 'left') {
        return ('Sb',3,);
      } elsif ($h->{g_position} eq 'right') {
        return ('Atr',3,1);
      }
  } elsif ($h->{d_tagtail} eq 'NOUN') {
    return evalSubTree1_S114($h); # [S114]
  }
}

# SubTree [S93]

sub evalSubTree1_S93 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Sb',3,1);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Adv',2,);
  }
}

# SubTree [S94]

sub evalSubTree1_S94 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Adv',3,1);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('Atr',5,1);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Adv',2,);
  } elsif ($h->{g_tagtail} eq 'NOUN_PROP') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'ADJ') {
    return ('Atr',2,1);
  }
}

# SubTree [S95]

sub evalSubTree1_S95 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'yuspec_plusmokin') {
    return ('Sb',2,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Obj',18,9);
  }
}

# SubTree [S96]

sub evalSubTree1_S96 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('Adv',2,);
  } elsif ($h->{g_lemma} eq 'yaspec_pluskuwn') {
    return ('Atr',3,2);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Obj',22,13);
  }
}

# SubTree [S97]

sub evalSubTree1_S97 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('Sb',12,1);
  } elsif ($h->{g_lemma} eq 'yaspec_pluskuwn') {
    return ('Sb',6,1);
  } elsif ($h->{g_lemma} eq 'yuspec_plusmokin') {
    return ('Sb',4,1);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{g_children} eq '1') {
        return ('Obj',8,2);
      } elsif ($h->{g_children} eq 'more') {
        return ('Sb',67,24);
      }
  }
}

# SubTree [S98]

sub evalSubTree1_S98 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Pnom',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Pnom',3,1);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Obj',9,5);
  }
}

# SubTree [S99]

sub evalSubTree1_S99 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_DU_NOM') {
    return ('Sb',2,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN_POSS') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Obj',2,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_NOM') {
    return ('Sb',3,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_DU_NOM_POSS') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_DU_ACCGEN') {
    return ('Atv',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_NOM_POSS') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return evalSubTree1_S115($h); # [S115]
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return evalSubTree1_S116($h); # [S116]
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return evalSubTree1_S117($h); # [S117]
  } elsif ($h->{d_tagtail} eq 'empty') {
    return evalSubTree1_S118($h); # [S118]
  }
}

# SubTree [S100]

sub evalSubTree1_S100 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'spec_dollararikspec_plusAt') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'maloyuwn') {
    return ('Adv',1,);
  } elsif ($h->{d_lemma} eq 'kaos') {
    return ('Obj',2,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_position} eq 'left') {
        return ('Atr',5,1);
      } elsif ($h->{g_position} eq 'right') {
        return ('Adv',4,1);
      }
  }
}

# SubTree [S101]

sub evalSubTree1_S101 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_DU_NOM_POSS') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',4,2);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atr',4,2);
  } elsif ($h->{d_tagtail} eq 'empty') {
      if ($h->{g_position} eq 'left') {
        return ('Atr',26,7);
      } elsif ($h->{g_position} eq 'right') {
        return ('Obj',3,2);
      }
  }
}

# SubTree [S102]

sub evalSubTree1_S102 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|Alspec_tildaatiy|hunAka|jidspec_tilda)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_lemma} eq 'ziyAdspec_plusap') {
    return ('AtrAtr',1,);
  } elsif ($h->{d_lemma} eq 'waziyr') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'biloyuwn') {
    return ('Atr',3,);
  } elsif ($h->{d_lemma} eq 'raspec_rbraceiys') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'qiymspec_plusap') {
    return ('Sb',1,);
  } elsif ($h->{d_lemma} eq 'spec_lbraceitspec_tildaifAq') {
    return ('Atr',1,);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_children} eq 'more') {
        return ('Sb',12,8);
      } elsif ($h->{g_children} eq '1') {
        return evalSubTree1_S119($h); # [S119]
      }
  }
}

# SubTree [S103]

sub evalSubTree1_S103 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|lam|Alspec_plusraspec_rbraceiys|lan|miSor|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|hum|51|Alspec_plusEirAq|hi|έν|spec_dot|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|baEoda|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|ζ|Alspec_plusmuqobil|spec_slash|fiy|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|Alspec_tildaatiy|hunAka|jidspec_tilda)$/) {
    return ('Adv',0,);
  } elsif ($h->{d_lemma} eq 'naHow') {
    return ('Adv',4,2);
  } elsif ($h->{d_lemma} eq 'baronAmaj') {
    return ('Obj',4,2);
  } elsif ($h->{d_lemma} eq 'majolis') {
    return ('Atr',3,);
  } elsif ($h->{d_lemma} eq 'taqodiym') {
    return ('Obj',5,2);
  } elsif ($h->{d_lemma} eq 'Hizob') {
    return ('Atr',3,);
  } elsif ($h->{d_lemma} eq 'spec_dollararikspec_plusAt') {
    return ('Obj',6,1);
  } elsif ($h->{d_lemma} eq 'gAlibiyspec_tildaspec_plusap') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'qiTAE') {
    return ('Obj',5,3);
  } elsif ($h->{d_lemma} eq 'maSAdir') {
    return ('Obj',3,1);
  } elsif ($h->{d_lemma} eq 'binAspec_aph') {
    return ('Obj',6,1);
  } elsif ($h->{d_lemma} eq 'fatorspec_plusap') {
    return ('Adv',3,);
  } elsif ($h->{d_lemma} eq 'waziyr') {
    return ('Obj',3,1);
  } elsif ($h->{d_lemma} eq 'majomuwEspec_plusap') {
    return ('Obj',1,);
  } elsif ($h->{d_lemma} eq 'Eadam') {
    return ('Obj',6,1);
  } elsif ($h->{d_lemma} eq 'wizArspec_plusap') {
    return ('Obj',4,2);
  } elsif ($h->{d_lemma} eq 'raspec_rbraceiys') {
    return ('Atr',4,);
  } elsif ($h->{d_lemma} eq 'HAl') {
    return ('Adv',10,1);
  } elsif ($h->{d_lemma} eq 'SaHiyfspec_plusap') {
    return ('Atr',2,1);
  } elsif ($h->{d_lemma} eq 'qiymspec_plusap') {
    return ('Atr',8,3);
  } elsif ($h->{d_lemma} eq 'spec_lbraceitspec_tildaifAq') {
    return ('Obj',2,1);
  } elsif ($h->{d_lemma} eq 'ragom') {
      if ($h->{d_children} eq 'more') {
        return ('AuxY',0,);
      } elsif ($h->{d_children} eq '0') {
        return ('AuxY',5,);
      } elsif ($h->{d_children} eq '1') {
        return ('Adv',2,);
      }
  } elsif ($h->{d_lemma} eq 'Eamaliyspec_tildaspec_plusAt') {
      if ($h->{g_children} eq '1') {
        return ('Obj',3,);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',3,1);
      }
  } elsif ($h->{d_lemma} eq 'spec_lbraceisom') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('Atr',4,1);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',3,);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Adv',1,);
      }
  } elsif ($h->{d_lemma} eq 'daEom') {
      if ($h->{d_children} eq '0') {
        return ('Obj',0,);
      } elsif ($h->{d_children} eq '1') {
        return ('Atr',3,1);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',2,);
      }
  } elsif ($h->{d_lemma} eq 'madiynspec_plusap') {
      if ($h->{g_children} eq '1') {
        return ('AtrAdv',2,1);
      } elsif ($h->{g_children} eq 'more') {
        return ('AdvAtr',4,2);
      }
  } elsif ($h->{d_lemma} eq 'Hasab') {
      if ($h->{d_children} eq 'more') {
        return ('AuxY',0,);
      } elsif ($h->{d_children} eq '0') {
        return ('AuxY',10,);
      } elsif ($h->{d_children} eq '1') {
        return ('Adv',4,1);
      }
  } elsif ($h->{d_lemma} eq 'ziyAdspec_plusap') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|DET|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Obj',0,);
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
        return ('Obj',2,);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Obj',2,1);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Adv',1,);
      }
  } elsif ($h->{d_lemma} eq 'kaos') {
      if ($h->{g_children} eq '1') {
        return ('Obj',6,1);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',2,);
      }
  } elsif ($h->{d_lemma} eq 'waDoE') {
    return evalSubTree1_S120($h); # [S120]
  } elsif ($h->{d_lemma} eq 'kulspec_tilda') {
      if ($h->{g_children} eq '1') {
        return ('Obj',2,1);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',4,1);
      }
  } elsif ($h->{d_lemma} eq 'Hajom') {
      if ($h->{g_taghead} =~ /^(?:IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|IV3MP|IV2D|IV3MS|POSS_PRON_3FS|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|IV2MS|FUNC_WORD|root|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('Atr',0,);
      } elsif ($h->{g_taghead} eq 'DET') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('Obj',2,1);
      } elsif ($h->{g_taghead} eq 'NOUN') {
        return ('Atr',3,);
      } elsif ($h->{g_taghead} eq 'IV3FS') {
        return ('Obj',1,);
      }
  } elsif ($h->{d_lemma} eq 'qarAr') {
      if ($h->{g_children} eq '1') {
        return ('Obj',2,1);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',3,1);
      }
  } elsif ($h->{d_lemma} eq 'other_lemma') {
      if ($h->{g_taghead} =~ /^(?:PRON_1S|NEG_PART|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|IVSUFF_DOspec_ddot3MS|POSS_PRON_1P|PRON_3MS|POSS_PRON_3FS|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|DEM_PRON_MS|IV2MP|NOUN_PROP|FUNC_WORD|PRON_3D|PVSUFF_DOspec_ddot3FS|PREP|ABBREV|PRON_1P)$/) {
        return ('Adv',0,);
      } elsif ($h->{g_taghead} eq 'IV1P') {
        return ('Adv',6,3);
      } elsif ($h->{g_taghead} eq 'SUBJUNC') {
        return ('Adv',3,);
      } elsif ($h->{g_taghead} eq 'IV1S') {
        return ('Adv',4,2);
      } elsif ($h->{g_taghead} eq 'IV3MD') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'IV3MP') {
        return ('Obj',10,3);
      } elsif ($h->{g_taghead} eq 'IV2D') {
        return ('Adv',1,);
      } elsif ($h->{g_taghead} eq 'PART') {
        return ('Obj',1,);
      } elsif ($h->{g_taghead} eq 'IV2MS') {
        return ('Obj',1,);
      } elsif ($h->{g_taghead} eq 'root') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|other_lemma|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Adv',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',2,1);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('ExDspec_pipeAdv',1,);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('ExDspec_pipeAdv',1,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Pnom',2,1);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Adv',3,1);
          }
      } elsif ($h->{g_taghead} eq 'ADV') {
          if ($h->{d_children} eq '0') {
            return ('Obj',0,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Obj',3,1);
          } elsif ($h->{d_children} eq '1') {
            return evalSubTree1_S121($h); # [S121]
          }
      } elsif ($h->{g_taghead} eq 'IV3MS') {
          if ($h->{i_lemma} =~ /^(?:Hawola|other_lemma|Ealay|bayona|ladaY|qabol|ka|Hatspec_tildaaY|la)$/) {
            return ('Obj',0,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',22,3);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Obj',13,4);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Obj',5,1);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',2,);
          } elsif ($h->{i_lemma} eq 'maEa') {
            return ('Obj',2,1);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Obj',5,1);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
            return ('Obj',4,2);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Obj',5,1);
          } elsif ($h->{i_lemma} eq 'xilAl') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
              if ($h->{g_children} eq '1') {
                return ('Obj',3,);
              } elsif ($h->{g_children} eq 'more') {
                return ('Adv',2,);
              }
          } elsif ($h->{i_lemma} eq 'bi') {
              if ($h->{d_children} eq '0') {
                return ('Adv',1,);
              } elsif ($h->{d_children} eq '1') {
                return ('Adv',10,5);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',5,);
              }
          }
      } elsif ($h->{g_taghead} eq 'NON_ALPHABETIC_DATA') {
          if ($h->{i_lemma} =~ /^(?:Hawola|baEoda|spec_amperltspec_semicolilay|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Obj',0,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',7,2);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Obj',7,2);
          } elsif ($h->{i_lemma} eq 'EalaY') {
            return ('Obj',5,1);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Adv',3,1);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'maEa') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Atr',2,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Atr',8,4);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Sb',1,);
          } elsif ($h->{i_lemma} eq 'bi') {
              if ($h->{g_children} eq '1') {
                return ('Obj',3,2);
              } elsif ($h->{g_children} eq 'more') {
                return ('Adv',7,3);
              }
          }
      } elsif ($h->{g_taghead} eq 'ADJ') {
          if ($h->{i_lemma} =~ /^(?:Ean|Hawola|EalaY|other_lemma|Ealay|baEoda|maEa|ilaY|spec_amperltspec_semicolilaY|spec_amperltspec_semicolilay|bayona|ladaY|qabol|ka|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('AdvAtr',2,1);
          } elsif ($h->{i_lemma} eq 'min') {
            return ('Atr',3,1);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Adv',3,1);
          } elsif ($h->{i_lemma} eq 'li') {
              if ($h->{d_children} eq '0') {
                return ('Atr',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('Atr',4,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',2,);
              }
          }
      } elsif ($h->{g_taghead} eq 'VERB_PERFECT') {
          if ($h->{i_lemma} =~ /^(?:bayona|Hatspec_tildaaY|la)$/) {
            return ('Adv',0,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return ('Obj',13,1);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',37,11);
          } elsif ($h->{i_lemma} eq 'Hawola') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Adv',3,1);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',5,);
          } elsif ($h->{i_lemma} eq 'maEa') {
            return ('Adv',3,1);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Obj',7,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Adv',32,13);
          } elsif ($h->{i_lemma} eq 'ladaY') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'qabol') {
            return ('Adv',4,);
          } elsif ($h->{i_lemma} eq 'ka') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'xilAl') {
            return ('Adv',7,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return evalSubTree1_S122($h); # [S122]
          } elsif ($h->{i_lemma} eq 'min') {
              if ($h->{d_children} eq '0') {
                return ('AuxY',2,);
              } elsif ($h->{d_children} eq '1') {
                return ('Adv',13,3);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',2,1);
              }
          } elsif ($h->{i_lemma} eq 'li') {
            return evalSubTree1_S123($h); # [S123]
          } elsif ($h->{i_lemma} eq 'EalaY') {
              if ($h->{d_children} eq '0') {
                return ('Obj',0,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',7,);
              } elsif ($h->{d_children} eq '1') {
                return evalSubTree1_S124($h); # [S124]
              }
          }
      } elsif ($h->{g_taghead} eq 'DET') {
          if ($h->{i_lemma} =~ /^(?:spec_amperltspec_semicolilay|ladaY|qabol|la)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return ('Obj',7,1);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Atr',31,17);
          } elsif ($h->{i_lemma} eq 'Hawola') {
            return ('Atr',4,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Atr',3,);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Atr',3,1);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'maEa') {
            return ('Obj',3,2);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Pnom',1,);
          } elsif ($h->{i_lemma} eq 'ka') {
            return ('Atv',1,);
          } elsif ($h->{i_lemma} eq 'xilAl') {
            return ('AtrAdv',2,1);
          } elsif ($h->{i_lemma} eq 'Hatspec_tildaaY') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'ilaY') {
              if ($h->{d_children} eq '0') {
                return ('Obj',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('Atr',2,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',4,2);
              }
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
              if ($h->{d_children} eq '0') {
                return ('Obj',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('Atr',2,1);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',2,);
              }
          } elsif ($h->{i_lemma} eq 'min') {
            return evalSubTree1_S125($h); # [S125]
          } elsif ($h->{i_lemma} eq 'li') {
            return evalSubTree1_S126($h); # [S126]
          } elsif ($h->{i_lemma} eq 'EalaY') {
              if ($h->{g_children} eq 'more') {
                return ('Obj',5,2);
              } elsif ($h->{g_children} eq '1') {
                  if ($h->{d_children} eq '0') {
                    return ('Atr',0,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Atr',12,4);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',4,1);
                  }
              }
          } elsif ($h->{i_lemma} eq 'bi') {
            return evalSubTree1_S127($h); # [S127]
          }
      } elsif ($h->{g_taghead} eq 'IV3FS') {
          if ($h->{i_lemma} =~ /^(?:Hawola|maEa|ladaY|xilAl|Hatspec_tildaaY|la)$/) {
            return ('Obj',0,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return ('Adv',3,1);
          } elsif ($h->{i_lemma} eq 'fiy') {
            return ('Adv',11,2);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',3,);
          } elsif ($h->{i_lemma} eq 'ilaY') {
            return ('Obj',3,1);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return ('Obj',5,);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
            return ('Obj',2,);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'bi') {
            return ('Adv',23,9);
          } elsif ($h->{i_lemma} eq 'qabol') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'ka') {
            return ('Atv',1,);
          } elsif ($h->{i_lemma} eq 'li') {
              if ($h->{d_children} eq '0') {
                return ('Adv',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('Adv',5,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',2,);
              }
          } elsif ($h->{i_lemma} eq 'min') {
              if ($h->{d_children} eq '0') {
                return ('AuxY',1,);
              } elsif ($h->{d_children} eq '1') {
                return ('Obj',5,2);
              } elsif ($h->{d_children} eq 'more') {
                return ('Adv',5,2);
              }
          } elsif ($h->{i_lemma} eq 'EalaY') {
              if ($h->{g_children} eq '1') {
                return ('Obj',5,);
              } elsif ($h->{g_children} eq 'more') {
                return evalSubTree1_S128($h); # [S128]
              }
          }
      } elsif ($h->{g_taghead} eq 'NOUN') {
          if ($h->{i_lemma} =~ /^(?:qabol|Hatspec_tildaaY)$/) {
            return ('Atr',0,);
          } elsif ($h->{i_lemma} eq 'li') {
            return ('Atr',76,30);
          } elsif ($h->{i_lemma} eq 'Hawola') {
            return ('Atr',5,);
          } elsif ($h->{i_lemma} eq 'other_lemma') {
            return ('Atr',6,3);
          } elsif ($h->{i_lemma} eq 'Ealay') {
            return ('Obj',1,);
          } elsif ($h->{i_lemma} eq 'baEoda') {
            return ('Adv',2,);
          } elsif ($h->{i_lemma} eq 'maEa') {
            return ('Obj',6,4);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
            return ('Obj',6,3);
          } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
            return ('Obj',3,1);
          } elsif ($h->{i_lemma} eq 'bayona') {
            return ('Atr',1,);
          } elsif ($h->{i_lemma} eq 'ladaY') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'ka') {
            return ('Atr',3,2);
          } elsif ($h->{i_lemma} eq 'xilAl') {
            return ('Adv',1,);
          } elsif ($h->{i_lemma} eq 'la') {
            return ('Sb',1,);
          } elsif ($h->{i_lemma} eq 'Ean') {
            return evalSubTree1_S129($h); # [S129]
          } elsif ($h->{i_lemma} eq 'ilaY') {
              if ($h->{d_children} eq '0') {
                return ('Obj',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('Atr',2,1);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',4,2);
              }
          } elsif ($h->{i_lemma} eq 'fiy') {
              if ($h->{d_children} eq '0') {
                return ('Atr',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('Atr',47,20);
              } elsif ($h->{d_children} eq 'more') {
                return evalSubTree1_S130($h); # [S130]
              }
          } elsif ($h->{i_lemma} eq 'EalaY') {
              if ($h->{g_children} eq 'more') {
                return ('Obj',20,8);
              } elsif ($h->{g_children} eq '1') {
                  if ($h->{d_children} eq '0') {
                    return ('Obj',0,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Adv',2,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',2,);
                  }
              }
          } elsif ($h->{i_lemma} eq 'min') {
              if ($h->{d_children} eq '0') {
                return ('AuxY',7,2);
              } elsif ($h->{d_children} eq '1') {
                return evalSubTree1_S131($h); # [S131]
              } elsif ($h->{d_children} eq 'more') {
                return evalSubTree1_S132($h); # [S132]
              }
          } elsif ($h->{i_lemma} eq 'bi') {
              if ($h->{g_children} eq '1') {
                  if ($h->{d_children} eq '0') {
                    return ('Obj',1,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Atr',5,2);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',2,);
                  }
              } elsif ($h->{g_children} eq 'more') {
                  if ($h->{d_children} eq '0') {
                    return ('Obj',2,1);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Atr',6,1);
                  } elsif ($h->{d_children} eq '1') {
                    return evalSubTree1_S133($h); # [S133]
                  }
              }
          }
      }
  }
}

# SubTree [S104]

sub evalSubTree1_S104 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atv',0,);
  } elsif ($h->{g_lemma} eq 'kAn') {
    return ('Atv',5,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Atv',3,);
  } elsif ($h->{g_lemma} eq 'qAl') {
    return ('Obj',1,);
  }
}

# SubTree [S105]

sub evalSubTree1_S105 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|ADJ)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Adv',3,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('AuxE',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('AuxY',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Atv',4,);
  } elsif ($h->{g_tagtail} eq 'root') {
    return ('ExD',2,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FP') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return evalSubTree1_S134($h); # [S134]
  }
}

# SubTree [S106]

sub evalSubTree1_S106 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MD') {
    return ('AuxP',1,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Adv',4,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('AuxP',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('AuxC',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
      if ($h->{i_taghead} eq 'PREP') {
        return ('AuxC',2,1);
      } elsif ($h->{i_taghead} eq 'empty') {
        return ('AuxP',3,1);
      }
  }
}

# SubTree [S107]

sub evalSubTree1_S107 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_lemma} eq 'miSor') {
    return ('AtrAdv',3,1);
  } elsif ($h->{d_lemma} eq 'other_lemma') {
    return ('Atr',11,2);
  } elsif ($h->{d_lemma} eq 'diyfiyd') {
      if ($h->{g_children} eq '1') {
        return ('Adv',2,);
      } elsif ($h->{g_children} eq 'more') {
        return ('AtrAdv',2,1);
      }
  }
}

# SubTree [S108]

sub evalSubTree1_S108 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_tagtail} eq 'ADJspec_plusNSUFF_MASC_PL_NOM') {
    return ('Sb',2,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_NOM') {
    return ('Sb',5,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Obj',4,1);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_DU_NOM') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'ADJ') {
    return ('Sb',4,);
  } elsif ($h->{d_tagtail} eq 'NOUN') {
      if ($h->{g_children} eq '1') {
        return ('Obj',6,2);
      } elsif ($h->{g_children} eq 'more') {
        return ('Sb',35,6);
      }
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
      if ($h->{d_children} eq '0') {
        return ('Sb',6,3);
      } elsif ($h->{d_children} eq '1') {
        return ('Adv',4,1);
      } elsif ($h->{d_children} eq 'more') {
        return ('Sb',1,);
      }
  }
}

# SubTree [S109]

sub evalSubTree1_S109 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Obj',3,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',2,1);
  }
}

# SubTree [S110]

sub evalSubTree1_S110 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',2,1);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',2,);
  }
}

# SubTree [S111]

sub evalSubTree1_S111 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Sb',0,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_NOM') {
    return ('Sb',4,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_PL_ACCGEN') {
    return ('Obj',2,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Obj',8,2);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_MASC_DU_NOM') {
    return ('Sb',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROPspec_plusNSUFF_FEM_PL') {
    return ('Obj',1,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return evalSubTree1_S135($h); # [S135]
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
      if ($h->{d_children} eq '0') {
        return ('Adv',12,4);
      } elsif ($h->{d_children} eq '1') {
        return ('Sb',2,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Sb',1,);
      }
  } elsif ($h->{d_tagtail} eq 'ADJ') {
      if ($h->{d_children} eq '0') {
        return ('Obj',0,);
      } elsif ($h->{d_children} eq '1') {
        return ('Adv',2,1);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',3,1);
      }
  } elsif ($h->{d_tagtail} eq 'NOUN') {
      if ($h->{d_children} eq '1') {
        return ('Obj',35,16);
      } elsif ($h->{d_children} eq '0') {
          if ($h->{g_children} eq '1') {
            return ('Obj',3,1);
          } elsif ($h->{g_children} eq 'more') {
            return ('Sb',22,4);
          }
      } elsif ($h->{d_children} eq 'more') {
        return evalSubTree1_S136($h); # [S136]
      }
  }
}

# SubTree [S112]

sub evalSubTree1_S112 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Adv',3,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('AdvAtr',2,1);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('Atr',1,);
  }
}

# SubTree [S113]

sub evalSubTree1_S113 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'NOUN') {
    return ('Adv',5,2);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_PL') {
    return ('AtrAdv',1,);
  } elsif ($h->{d_tagtail} eq 'NOUN_PROP') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
      if ($h->{g_children} eq '1') {
        return ('Atr',2,);
      } elsif ($h->{g_children} eq 'more') {
        return ('Adv',3,1);
      }
  }
}

# SubTree [S114]

sub evalSubTree1_S114 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|qAl|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_lemma} eq 'undef') {
    return ('Atr',2,);
  } elsif ($h->{g_lemma} eq 'ζ') {
    return ('Obj',1,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
      if ($h->{d_children} eq '0') {
        return ('Atr',3,);
      } elsif ($h->{d_children} eq '1') {
        return ('Sb',3,1);
      } elsif ($h->{d_children} eq 'more') {
          if ($h->{g_position} eq 'left') {
            return ('Atr',3,1);
          } elsif ($h->{g_position} eq 'right') {
            return ('Sb',2,);
          }
      }
  }
}

# SubTree [S115]

sub evalSubTree1_S115 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',5,2);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Adv',2,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot1S') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Sb',41,14);
  } elsif ($h->{g_tagtail} eq 'empty') {
      if ($h->{d_children} eq '0') {
        return ('Obj',0,);
      } elsif ($h->{d_children} eq '1') {
        return ('Sb',7,4);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',4,1);
      }
  }
}

# SubTree [S116]

sub evalSubTree1_S116 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',3,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Sb',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Adv',2,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
      if ($h->{d_children} eq '0') {
        return ('Obj',0,);
      } elsif ($h->{d_children} eq '1') {
        return ('Sb',4,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',8,2);
      }
  }
}

# SubTree [S117]

sub evalSubTree1_S117 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MD') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',3,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Atv',19,9);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FD') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
      if ($h->{d_children} eq '0') {
        return ('Obj',2,1);
      } elsif ($h->{d_children} eq '1') {
        return ('Atv',14,6);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',7,3);
      }
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
      if ($h->{d_children} eq '0') {
        return ('Sb',1,);
      } elsif ($h->{d_children} eq '1') {
        return ('Obj',6,1);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',3,);
      }
  }
}

# SubTree [S118]

sub evalSubTree1_S118 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|ADJ)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',2,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Sb',43,15);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Sb',44,19);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FP') {
    return ('Adv',2,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
      if ($h->{d_children} eq '0') {
        return ('Obj',1,);
      } elsif ($h->{d_children} eq '1') {
        return ('Sb',8,4);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',6,2);
      }
  }
}

# SubTree [S119]

sub evalSubTree1_S119 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',4,2);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Adv',1,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('ExD',7,4);
  }
}

# SubTree [S120]

sub evalSubTree1_S120 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'VERB_IMPERFECT') {
    return ('Adv',3,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',2,);
  }
}

# SubTree [S121]

sub evalSubTree1_S121 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Obj',5,2);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',2,);
  }
}

# SubTree [S122]

sub evalSubTree1_S122 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',2,1);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Adv',2,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Obj',2,);
  }
}

# SubTree [S123]

sub evalSubTree1_S123 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Adv',5,2);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Adv',5,2);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
      if ($h->{d_children} eq '0') {
        return ('Adv',0,);
      } elsif ($h->{d_children} eq '1') {
        return ('Adv',3,);
      } elsif ($h->{d_children} eq 'more') {
        return ('Obj',3,1);
      }
  }
}

# SubTree [S124]

sub evalSubTree1_S124 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot2FS') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MD') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Adv',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FD') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',4,1);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot1P') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Adv',6,3);
  }
}

# SubTree [S125]

sub evalSubTree1_S125 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Obj',3,1);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
    return ('Atr',10,3);
  } elsif ($h->{g_tagtail} eq 'ADJ') {
    return ('Atr',2,);
  }
}

# SubTree [S126]

sub evalSubTree1_S126 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Obj',2,1);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('AuxY',1,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Atr',17,5);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
      if ($h->{g_children} eq '1') {
        return ('Obj',3,);
      } elsif ($h->{g_children} eq 'more') {
        return ('Atr',12,4);
      }
  }
}

# SubTree [S127]

sub evalSubTree1_S127 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|empty|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NOUNspec_plusNSUFF_FEM_SG') {
    return ('Obj',5,2);
  } elsif ($h->{g_tagtail} eq 'ADJspec_plusNSUFF_FEM_SG') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'NOUN') {
      if ($h->{g_children} eq '1') {
        return ('Adv',6,3);
      } elsif ($h->{g_children} eq 'more') {
        return ('Atr',7,3);
      }
  }
}

# SubTree [S128]

sub evalSubTree1_S128 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',2,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Obj',2,1);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Adv',6,2);
  }
}

# SubTree [S129]

sub evalSubTree1_S129 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Obj',4,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',5,2);
  }
}

# SubTree [S130]

sub evalSubTree1_S130 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Adv',4,2);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atr',2,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Adv',3,1);
  }
}

# SubTree [S131]

sub evalSubTree1_S131 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Atr',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Obj',3,2);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('AtrAdv',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Atr',13,4);
  }
}

# SubTree [S132]

sub evalSubTree1_S132 { 
  my $h=$_[0];

  if ($h->{d_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|ADJspec_plusNSUFF_MASC_PL_NOM|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_DU_ACCGEN|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_DU_NOM|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJspec_plusNSUFF_FEM_PL|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Obj',0,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',2,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_MASC_DU_ACCGEN_POSS') {
    return ('Atr',1,);
  } elsif ($h->{d_tagtail} eq 'NSUFF_FEM_PL') {
    return ('Adv',1,);
  } elsif ($h->{d_tagtail} eq 'empty') {
    return ('Obj',4,1);
  }
}

# SubTree [S133]

sub evalSubTree1_S133 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|PVSUFF_SUBJspec_ddot3MS|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ|PVSUFF_SUBJspec_ddot3FS)$/) {
    return ('Adv',0,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_SG') {
    return ('Atr',6,4);
  } elsif ($h->{g_tagtail} eq 'NSUFF_FEM_PL') {
    return ('AuxY',1,);
  } elsif ($h->{g_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('Atr',1,);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Adv',9,4);
  }
}

# SubTree [S134]

sub evalSubTree1_S134 { 
  my $h=$_[0];

  if ($h->{g_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|spec_ddot|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|baronAmaj|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|madiynspec_plusap|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|yuspec_plusmokin|b|duwlAr|ilaY|diyfiyd|Alspec_plussabot|Alspec_tildaaiy|Hasab|EAmspec_plusAF|kAn|w|spec_lbrace|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|spec_quot|Didspec_tilda|spec_amperltspec_semicolilaY|min|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|bagodAd|inspec_tildaa|lA|‘|fatorspec_plusap|aDAf|spec_ampergtspec_semicolayspec_tilda|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_asterspec_aph2lika|Alspec_plusxArijiyspec_tildaspec_plusap|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|mA|qAlspec_plusa|EAm|li|layosspec_plusa|kAnspec_plusa|Alspec_plusspec_amperltspec_semicolisokAn|muqAbil|spec_amperltspec_semicolinspec_tildaa|Alspec_plusSAdirspec_plusAt|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|spec_rbrace|Aloyawom|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|raspec_rbraceiys|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|Alspec_pluswilAyspec_plusAt|HAl|yuwliyuw|qarAr|Alspec_plussiyAHspec_plusap|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|hunAka|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('Atv',0,);
  } elsif ($h->{g_lemma} eq 'other_lemma') {
    return ('Adv',9,5);
  } elsif ($h->{g_lemma} eq 'qAl') {
    return ('Atv',2,);
  }
}

# SubTree [S135]

sub evalSubTree1_S135 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|PVSUFF_SUBJspec_ddot3MP|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Sb',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Obj',3,1);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Obj',6,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Sb',23,1);
  }
}

# SubTree [S136]

sub evalSubTree1_S136 { 
  my $h=$_[0];

  if ($h->{g_tagtail} =~ /^(?:NSUFF_MASC_DU_NOM|IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_SG|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|IV3MDspec_plusVERB_IMPERFECT|NEG_PART|NOUNspec_plusNSUFF_MASC_PL_NOM|NOUNspec_plusNSUFF_FEM_SG|CASE_DEF_GEN|NOUNspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_FEM_DU_NOM|NSUFF_MASC_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotI|ADJspec_plusNSUFF_MASC_PL_ACCGEN|NSUFF_MASC_PL_ACCGEN|NOUN_PROPspec_plusNSUFF_FEM_SG|PVSUFF_SUBJspec_ddot2FS|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotD_MOODspec_ddotSJ|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|PVSUFF_SUBJspec_ddot3MD|ADJspec_plusNSUFF_FEM_SG|NOUN_PROPspec_plusNSUFF_MASC_PL_ACCGEN|VERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotFP|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|CASE_GEN|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|NOUN|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotSJ|VERB_IMPERFECTspec_plusIVSUFF_SUBJspec_ddotMP_MOODspec_ddotI|NOUNspec_plusNSUFF_FEM_DU_ACCGEN|NOUNspec_plusNSUFF_FEM_PL|NSUFF_MASC_SG_ACC_INDEF|PVSUFF_SUBJspec_ddot3FD|NOUNspec_plusNSUFF_MASC_DU_ACCGEN|NSUFF_MASC_DU_NOM_POSS|NOUNspec_plusNSUFF_MASC_DU_NOM|IV3MSspec_plusVERB_IMPERFECT|PVSUFF_SUBJspec_ddot1P|NSUFF_MASC_DU_ACCGEN|ADJspec_plusNSUFF_MASC_DU_ACCGEN|NOUN_PROP|IV2MSspec_plusVERB_IMPERFECT|root|PVSUFF_SUBJspec_ddot1S|NSUFF_MASC_PL_NOM_POSS|NOUN_PROPspec_plusNSUFF_FEM_PL|PVSUFF_SUBJspec_ddot3FP|ADJ)$/) {
    return ('Obj',0,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MP') {
    return ('Obj',1,);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3MS') {
    return ('Obj',4,2);
  } elsif ($h->{g_tagtail} eq 'empty') {
    return ('Sb',11,4);
  } elsif ($h->{g_tagtail} eq 'PVSUFF_SUBJspec_ddot3FS') {
    return ('Obj',2,);
  }
}

# Evaluation on hold-out data (1859 cases):
# 
# 	    Decision Tree   
# 	  ----------------  
# 	  Size      Errors  
# 
# 	  1479  314(16.9%)   <<
# 
# 
# [ Fold 1 ]
# 

1;
