# -*- cperl -*-
# This file was automatically generated with /home/pajas/treebank/perl/decision_trees2perl.pl
# by zabokrtsky@golias.ms.mff.cuni.cz <Thu Mar  6 16:29:16 2003>

package Detect_arab_dependencies;

use Exporter;
use strict;
use vars qw(@ISA @EXPORT_OK);

BEGIN {
  @ISA=qw(Exporter);
  @EXPORT_OK=qw(evalTree);
}

# 
# C5.0 [Release 1.16]  	Wed Mar  5 14:04:20 2003
# -------------------
# 
#     Options:
# 	Application `Ctvrty//pokus1'
# 	Cross-validate using 10 folds
# 
# Read 33106 cases (11 attributes) from Ctvrty//pokus1.data
# 
# 
# [ Fold 0 ]
# 

sub evalTree { 
  my $h=$_[0];

  if ($h->{b_position} eq 'righttmost') {
    return ('none',3192,2);
  } elsif ($h->{b_position} eq 'leftmost') {
    return evalSubTree1_S1($h); # [S1]
  } elsif ($h->{b_position} eq 'middle') {
      if ($h->{immediate_neighbors} eq 'no') {
          if ($h->{a_taghead} =~ /^(?:DEM_PRON_FS|DET|POSS_PRON_2MP)$/) {
            return ('none',0,);
          } elsif ($h->{a_taghead} eq 'IV1P') {
            return ('none',32,12);
          } elsif ($h->{a_taghead} eq 'PRON_1S') {
            return ('none',13,2);
          } elsif ($h->{a_taghead} eq 'NEG_PART') {
            return ('none',186,14);
          } elsif ($h->{a_taghead} eq 'IV3MD') {
            return ('none',1,);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3MP') {
            return ('none',2,);
          } elsif ($h->{a_taghead} eq 'ADV') {
            return ('none',121,18);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3D') {
            return ('none',3,);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3MS') {
            return ('none',19,);
          } elsif ($h->{a_taghead} eq 'undef') {
            return ('right',1,);
          } elsif ($h->{a_taghead} eq 'PRON_3MP') {
            return ('none',22,2);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_1P') {
            return ('none',6,);
          } elsif ($h->{a_taghead} eq 'DEM_PRON_F') {
            return ('none',12,);
          } elsif ($h->{a_taghead} eq 'IV3MP') {
            return ('none',32,13);
          } elsif ($h->{a_taghead} eq 'PRON_3MS') {
            return ('none',78,6);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_1S') {
            return ('none',5,);
          } elsif ($h->{a_taghead} eq 'IV2D') {
            return ('right',2,);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3FS') {
            return ('none',23,);
          } elsif ($h->{a_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('none',1649,381);
          } elsif ($h->{a_taghead} eq 'PVSUFF_DO') {
            return ('none',7,1);
          } elsif ($h->{a_taghead} eq 'IVSUFF_DO') {
            return ('none',9,);
          } elsif ($h->{a_taghead} eq 'PART') {
            return ('none',2,);
          } elsif ($h->{a_taghead} eq 'PRON_3FS') {
            return ('none',48,10);
          } elsif ($h->{a_taghead} eq 'IV3FP') {
            return ('right',3,);
          } elsif ($h->{a_taghead} eq 'PRON_2MP') {
            return ('none',1,);
          } elsif ($h->{a_taghead} eq 'DEM_PRON_MS') {
            return ('none',48,3);
          } elsif ($h->{a_taghead} eq 'NOUN_PROP') {
            return ('none',512,73);
          } elsif ($h->{a_taghead} eq 'PRON_3D') {
            return ('none',6,2);
          } elsif ($h->{a_taghead} eq 'FUT') {
            return ('none',86,);
          } elsif ($h->{a_taghead} eq 'ADJ') {
            return ('none',386,29);
          } elsif ($h->{a_taghead} eq 'ABBREV') {
            return ('none',58,21);
          } elsif ($h->{a_taghead} eq 'PRON_1P') {
            return ('none',11,1);
          } elsif ($h->{a_taghead} eq 'SUBJUNC') {
              if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|ABBREV|PRON_1P)$/) {
                return ('none',0,);
              } elsif ($h->{b_taghead} eq 'IV1P') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'CONJ') {
                return ('left',1,);
              } elsif ($h->{b_taghead} eq 'REL_PRON') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'PRON_3MS') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
                return ('none',3,1);
              } elsif ($h->{b_taghead} eq 'NOUN') {
                return ('right',3,);
              } elsif ($h->{b_taghead} eq 'PREP') {
                return ('right',1,);
              } elsif ($h->{b_taghead} eq 'ADJ') {
                return ('right',1,);
              }
          } elsif ($h->{a_taghead} eq 'IV1S') {
              if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|ABBREV|PRON_1P)$/) {
                return ('none',0,);
              } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'ADV') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'CONJ') {
                return ('left',2,);
              } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
                return ('none',14,2);
              } elsif ($h->{b_taghead} eq 'NOUN') {
                return ('right',4,);
              } elsif ($h->{b_taghead} eq 'PREP') {
                return ('right',6,2);
              } elsif ($h->{b_taghead} eq 'ADJ') {
                return ('right',1,);
              }
          } elsif ($h->{a_taghead} eq 'INTERROG_PART') {
            return evalSubTree1_S2($h); # [S2]
          } elsif ($h->{a_taghead} eq 'DEM_PRON_MP') {
            return evalSubTree1_S3($h); # [S3]
          } elsif ($h->{a_taghead} eq 'CONJ') {
            return evalSubTree1_S4($h); # [S4]
          } elsif ($h->{a_taghead} eq 'REL_PRON') {
              if ($h->{b_det} eq 'nodet') {
                return ('none',137,18);
              } elsif ($h->{b_det} eq 'det') {
                return evalSubTree1_S5($h); # [S5]
              }
          } elsif ($h->{a_taghead} eq 'IV3FS') {
              if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|POSS_PRON_1S|IV2D|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|PRON_2MP|PRON_3D|ABBREV|PRON_1P)$/) {
                return ('right',0,);
              } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'SUBJUNC') {
                return ('right',2,);
              } elsif ($h->{b_taghead} eq 'IV1S') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'NEG_PART') {
                return ('none',3,);
              } elsif ($h->{b_taghead} eq 'IV3MP') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'PRON_3MS') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'IV3MS') {
                return ('none',11,);
              } elsif ($h->{b_taghead} eq 'NOUN') {
                return ('right',53,10);
              } elsif ($h->{b_taghead} eq 'IV3FS') {
                return ('none',17,);
              } elsif ($h->{b_taghead} eq 'DEM_PRON_MS') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
                return ('right',5,);
              } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
                return ('none',8,2);
              } elsif ($h->{b_taghead} eq 'FUT') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'PREP') {
                return ('right',91,20);
              } elsif ($h->{b_taghead} eq 'ADJ') {
                return ('right',1,);
              } elsif ($h->{b_taghead} eq 'ADV') {
                return evalSubTree1_S6($h); # [S6]
              } elsif ($h->{b_taghead} eq 'CONJ') {
                return evalSubTree1_S7($h); # [S7]
              } elsif ($h->{b_taghead} eq 'REL_PRON') {
                return evalSubTree1_S8($h); # [S8]
              } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
                return evalSubTree1_S9($h); # [S9]
              }
          } elsif ($h->{a_taghead} eq 'PREP') {
            return evalSubTree1_S10($h); # [S10]
          } elsif ($h->{a_taghead} eq 'VERB_PERFECT') {
              if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|PRON_1S|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|POSS_PRON_1S|IV2D|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|IV3FP|DEM_PRON_MP|PRON_2MP|PRON_3D|PRON_1P)$/) {
                return ('right',0,);
              } elsif ($h->{b_taghead} eq 'IV1P') {
                return ('right',1,);
              } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
                return ('none',112,18);
              } elsif ($h->{b_taghead} eq 'SUBJUNC') {
                return ('right',2,);
              } elsif ($h->{b_taghead} eq 'IV1S') {
                return ('none',3,1);
              } elsif ($h->{b_taghead} eq 'NEG_PART') {
                return ('none',8,1);
              } elsif ($h->{b_taghead} eq 'ADV') {
                return ('right',28,3);
              } elsif ($h->{b_taghead} eq 'PRON_3MS') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'IV3MS') {
                return ('none',26,4);
              } elsif ($h->{b_taghead} eq 'PART') {
                return ('right',1,);
              } elsif ($h->{b_taghead} eq 'PRON_3FS') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'INTERROG_PART') {
                return ('none',1,);
              } elsif ($h->{b_taghead} eq 'NOUN') {
                return ('right',179,29);
              } elsif ($h->{b_taghead} eq 'DEM_PRON_MS') {
                return ('none',3,);
              } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
                return ('right',24,3);
              } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
                return ('right',91,17);
              } elsif ($h->{b_taghead} eq 'FUT') {
                return ('none',5,);
              } elsif ($h->{b_taghead} eq 'PREP') {
                return ('right',227,24);
              } elsif ($h->{b_taghead} eq 'ADJ') {
                return ('right',9,1);
              } elsif ($h->{b_taghead} eq 'ABBREV') {
                return ('right',2,);
              } elsif ($h->{b_taghead} eq 'REL_PRON') {
                return evalSubTree1_S11($h); # [S11]
              } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
                return evalSubTree1_S12($h); # [S12]
              } elsif ($h->{b_taghead} eq 'IV3FS') {
                return evalSubTree1_S13($h); # [S13]
              } elsif ($h->{b_taghead} eq 'CONJ') {
                return evalSubTree1_S14($h); # [S14]
              }
          } elsif ($h->{a_taghead} eq 'IV3MS') {
              if ($h->{b_det} eq 'det') {
                return ('right',29,1);
              } elsif ($h->{b_det} eq 'nodet') {
                return evalSubTree1_S15($h); # [S15]
              }
          } elsif ($h->{a_taghead} eq 'FUNC_WORD') {
            return evalSubTree1_S16($h); # [S16]
          } elsif ($h->{a_taghead} eq 'NOUN') {
              if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1S|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|undef|POSS_PRON_1P|POSS_PRON_1S|IV2D|POSS_PRON_3FS|POSS_PRON_2MP|DEM_PRON_MP|PRON_2MP)$/) {
                return ('none',0,);
              } elsif ($h->{b_taghead} eq 'IV1P') {
                return ('none',12,);
              } elsif ($h->{b_taghead} eq 'PRON_1S') {
                return ('none',4,);
              } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
                return ('none',246,99);
              } elsif ($h->{b_taghead} eq 'SUBJUNC') {
                return ('none',18,3);
              } elsif ($h->{b_taghead} eq 'NEG_PART') {
                return ('none',70,4);
              } elsif ($h->{b_taghead} eq 'ADV') {
                return ('none',107,8);
              } elsif ($h->{b_taghead} eq 'CONJ') {
                return ('none',580,197);
              } elsif ($h->{b_taghead} eq 'PRON_3MP') {
                return ('none',3,1);
              } elsif ($h->{b_taghead} eq 'DEM_PRON_F') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'IV3MP') {
                return ('right',16,9);
              } elsif ($h->{b_taghead} eq 'PRON_3MS') {
                return ('none',29,);
              } elsif ($h->{b_taghead} eq 'IV3MS') {
                return ('none',143,57);
              } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
                return ('none',692,178);
              } elsif ($h->{b_taghead} eq 'PVSUFF_DO') {
                return ('none',3,);
              } elsif ($h->{b_taghead} eq 'IVSUFF_DO') {
                return ('none',6,);
              } elsif ($h->{b_taghead} eq 'PART') {
                return ('none',5,);
              } elsif ($h->{b_taghead} eq 'PRON_3FS') {
                return ('none',9,1);
              } elsif ($h->{b_taghead} eq 'IV3FP') {
                return ('left',1,);
              } elsif ($h->{b_taghead} eq 'INTERROG_PART') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'DEM_PRON_MS') {
                return ('none',21,);
              } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
                return ('none',182,5);
              } elsif ($h->{b_taghead} eq 'PRON_3D') {
                return ('none',3,);
              } elsif ($h->{b_taghead} eq 'FUT') {
                return ('none',41,);
              } elsif ($h->{b_taghead} eq 'PREP') {
                return ('none',1393,454);
              } elsif ($h->{b_taghead} eq 'ABBREV') {
                return ('none',18,8);
              } elsif ($h->{b_taghead} eq 'PRON_1P') {
                return ('none',2,);
              } elsif ($h->{b_taghead} eq 'IV3FS') {
                return evalSubTree1_S17($h); # [S17]
              } elsif ($h->{b_taghead} eq 'REL_PRON') {
                return evalSubTree1_S18($h); # [S18]
              } elsif ($h->{b_taghead} eq 'ADJ') {
                  if ($h->{b_det} eq 'det') {
                    return ('right',130,17);
                  } elsif ($h->{b_det} eq 'nodet') {
                    return evalSubTree1_S19($h); # [S19]
                  }
              } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
                return evalSubTree1_S20($h); # [S20]
              } elsif ($h->{b_taghead} eq 'NOUN') {
                  if ($h->{a_det} eq 'det') {
                    return ('none',363,31);
                  } elsif ($h->{a_det} eq 'nodet') {
                      if ($h->{b_det} eq 'nodet') {
                        return ('none',472,92);
                      } elsif ($h->{b_det} eq 'det') {
                        return evalSubTree1_S21($h); # [S21]
                      }
                  }
              }
          }
      } elsif ($h->{immediate_neighbors} eq 'yes') {
          if ($h->{a_taghead} =~ /^(?:IV3FP|INTERROG_PART|PRON_2MP)$/) {
            return ('right',0,);
          } elsif ($h->{a_taghead} eq 'DEM_PRON_FS') {
            return ('left',3,);
          } elsif ($h->{a_taghead} eq 'IV1P') {
            return ('right',13,2);
          } elsif ($h->{a_taghead} eq 'VERB_PERFECT') {
            return ('right',485,9);
          } elsif ($h->{a_taghead} eq 'SUBJUNC') {
            return ('right',10,);
          } elsif ($h->{a_taghead} eq 'IV1S') {
            return ('right',12,);
          } elsif ($h->{a_taghead} eq 'IV3MD') {
            return ('right',2,);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3MP') {
            return ('none',37,);
          } elsif ($h->{a_taghead} eq 'CONJ') {
            return ('right',555,220);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3D') {
            return ('none',10,2);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3MS') {
            return ('none',104,1);
          } elsif ($h->{a_taghead} eq 'undef') {
            return ('right',1,);
          } elsif ($h->{a_taghead} eq 'DET') {
            return ('left',1,);
          } elsif ($h->{a_taghead} eq 'PRON_3MP') {
            return ('none',25,4);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_1P') {
            return ('none',17,1);
          } elsif ($h->{a_taghead} eq 'DEM_PRON_F') {
            return ('left',38,);
          } elsif ($h->{a_taghead} eq 'IV3MP') {
            return ('right',29,1);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_1S') {
            return ('none',11,);
          } elsif ($h->{a_taghead} eq 'IV2D') {
            return ('right',1,);
          } elsif ($h->{a_taghead} eq 'IV3MS') {
            return ('right',203,4);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_3FS') {
            return ('none',94,1);
          } elsif ($h->{a_taghead} eq 'PVSUFF_DO') {
            return ('none',62,);
          } elsif ($h->{a_taghead} eq 'POSS_PRON_2MP') {
            return ('none',1,);
          } elsif ($h->{a_taghead} eq 'IVSUFF_DO') {
            return ('none',57,1);
          } elsif ($h->{a_taghead} eq 'PART') {
            return ('right',3,);
          } elsif ($h->{a_taghead} eq 'IV3FS') {
            return ('right',157,3);
          } elsif ($h->{a_taghead} eq 'DEM_PRON_MP') {
            return ('right',4,1);
          } elsif ($h->{a_taghead} eq 'FUT') {
            return ('left',40,);
          } elsif ($h->{a_taghead} eq 'PREP') {
            return ('right',1559,9);
          } elsif ($h->{a_taghead} eq 'ABBREV') {
            return ('none',110,15);
          } elsif ($h->{a_taghead} eq 'PRON_1S') {
            return evalSubTree1_S22($h); # [S22]
          } elsif ($h->{a_taghead} eq 'REL_PRON') {
            return evalSubTree1_S23($h); # [S23]
          } elsif ($h->{a_taghead} eq 'PRON_3FS') {
            return evalSubTree1_S24($h); # [S24]
          } elsif ($h->{a_taghead} eq 'FUNC_WORD') {
            return evalSubTree1_S25($h); # [S25]
          } elsif ($h->{a_taghead} eq 'PRON_3D') {
              if ($h->{b_det} eq 'det') {
                return ('none',2,);
              } elsif ($h->{b_det} eq 'nodet') {
                return ('left',2,);
              }
          } elsif ($h->{a_taghead} eq 'PRON_1P') {
            return evalSubTree1_S26($h); # [S26]
          } elsif ($h->{a_taghead} eq 'NEG_PART') {
            return evalSubTree1_S27($h); # [S27]
          } elsif ($h->{a_taghead} eq 'PRON_3MS') {
            return evalSubTree1_S28($h); # [S28]
          } elsif ($h->{a_taghead} eq 'ADJ') {
              if ($h->{a_det} eq 'det') {
                return ('none',657,67);
              } elsif ($h->{a_det} eq 'nodet') {
                  if ($h->{b_det} eq 'det') {
                    return ('right',14,3);
                  } elsif ($h->{b_det} eq 'nodet') {
                    return ('none',319,66);
                  }
              }
          } elsif ($h->{a_taghead} eq 'ADV') {
              if ($h->{a_position} eq 'leftmost') {
                return ('right',5,);
              } elsif ($h->{a_position} eq 'middle') {
                return evalSubTree1_S29($h); # [S29]
              }
          } elsif ($h->{a_taghead} eq 'DEM_PRON_MS') {
              if ($h->{b_det} eq 'det') {
                return ('left',27,1);
              } elsif ($h->{b_det} eq 'nodet') {
                return evalSubTree1_S30($h); # [S30]
              }
          } elsif ($h->{a_taghead} eq 'NON_ALPHABETIC_DATA') {
            return evalSubTree1_S31($h); # [S31]
          } elsif ($h->{a_taghead} eq 'NOUN_PROP') {
            return evalSubTree1_S32($h); # [S32]
          } elsif ($h->{a_taghead} eq 'NOUN') {
              if ($h->{a_det} eq 'nodet') {
                return ('right',2300,380);
              } elsif ($h->{a_det} eq 'det') {
                  if ($h->{b_det} eq 'det') {
                    return evalSubTree1_S33($h); # [S33]
                  } elsif ($h->{b_det} eq 'nodet') {
                      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|PRON_1S|IV1S|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|undef|POSS_PRON_1P|POSS_PRON_1S|IV2D|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|PRON_3D|ABBREV|PRON_1P)$/) {
                        return ('none',0,);
                      } elsif ($h->{b_taghead} eq 'IV1P') {
                        return ('none',1,);
                      } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
                        return ('none',21,9);
                      } elsif ($h->{b_taghead} eq 'SUBJUNC') {
                        return ('none',1,);
                      } elsif ($h->{b_taghead} eq 'NEG_PART') {
                        return ('none',18,1);
                      } elsif ($h->{b_taghead} eq 'CONJ') {
                        return ('none',98,36);
                      } elsif ($h->{b_taghead} eq 'REL_PRON') {
                        return ('right',62,26);
                      } elsif ($h->{b_taghead} eq 'PRON_3MP') {
                        return ('none',1,);
                      } elsif ($h->{b_taghead} eq 'DEM_PRON_F') {
                        return ('none',1,);
                      } elsif ($h->{b_taghead} eq 'IV3MP') {
                        return ('none',1,);
                      } elsif ($h->{b_taghead} eq 'PRON_3MS') {
                        return ('none',5,);
                      } elsif ($h->{b_taghead} eq 'IV3MS') {
                        return ('none',6,2);
                      } elsif ($h->{b_taghead} eq 'NOUN') {
                        return ('none',77,17);
                      } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
                        return ('none',42,1);
                      } elsif ($h->{b_taghead} eq 'FUT') {
                        return ('none',7,);
                      } elsif ($h->{b_taghead} eq 'ADJ') {
                        return ('none',7,2);
                      } elsif ($h->{b_taghead} eq 'ADV') {
                        return evalSubTree1_S34($h); # [S34]
                      } elsif ($h->{b_taghead} eq 'IV3FS') {
                        return evalSubTree1_S35($h); # [S35]
                      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
                        return evalSubTree1_S36($h); # [S36]
                      } elsif ($h->{b_taghead} eq 'PREP') {
                          if ($h->{a_position} eq 'leftmost') {
                            return ('right',2,);
                          } elsif ($h->{a_position} eq 'middle') {
                            return ('none',455,191);
                          }
                      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
                        return evalSubTree1_S37($h); # [S37]
                      }
                  }
              }
          }
      }
  }
}

# SubTree [S1]

sub evalSubTree1_S1 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|iy|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|hspec_aph2spec_asterA|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusqudos') {
    return ('none',6,);
  } elsif ($h->{a_lemma} eq 'gayor') {
    return ('right',2,);
  } elsif ($h->{a_lemma} eq 'TahorAn') {
    return ('none',4,);
  } elsif ($h->{a_lemma} eq 'kamA') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq '51') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'ilaY') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'bi') {
    return ('none',3,1);
  } elsif ($h->{a_lemma} eq 'kAnspec_plusat') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'min') {
    return ('right',4,);
  } elsif ($h->{a_lemma} eq 'inspec_tildaa') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'bagodAd') {
    return ('none',4,);
  } elsif ($h->{a_lemma} eq 'kulspec_tilda') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq '11') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'qAlspec_plusa') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'ilspec_tildaA') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'fiy') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'fa') {
    return ('left',4,1);
  } elsif ($h->{a_lemma} eq 'wa') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|SUBJUNC|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|IV3FP|INTERROG_PART|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|PRON_3D|ADJ|ABBREV|PRON_1P)$/) {
        return ('left',0,);
      } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
        return ('left',153,25);
      } elsif ($h->{b_taghead} eq 'IV1S') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'NEG_PART') {
        return ('none',7,);
      } elsif ($h->{b_taghead} eq 'ADV') {
        return ('none',8,1);
      } elsif ($h->{b_taghead} eq 'CONJ') {
        return ('none',5,1);
      } elsif ($h->{b_taghead} eq 'REL_PRON') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'IV3MS') {
        return ('left',20,8);
      } elsif ($h->{b_taghead} eq 'PRON_3FS') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('none',12,3);
      } elsif ($h->{b_taghead} eq 'IV3FS') {
        return ('left',12,2);
      } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
        return ('none',11,);
      } elsif ($h->{b_taghead} eq 'FUT') {
        return ('none',3,);
      } elsif ($h->{b_taghead} eq 'PREP') {
        return ('none',36,5);
      }
  } elsif ($h->{a_lemma} eq 'other_lemma') {
      if ($h->{b_det} eq 'det') {
        return ('right',3,);
      } elsif ($h->{b_det} eq 'nodet') {
          if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|PRON_3D|FUT|ADJ|ABBREV|PRON_1P)$/) {
            return ('none',0,);
          } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
            return ('none',5,1);
          } elsif ($h->{b_taghead} eq 'NOUN') {
            return ('none',3,1);
          } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
            return ('right',3,1);
          } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
            return ('right',2,);
          } elsif ($h->{b_taghead} eq 'PREP') {
            return ('right',4,);
          } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
            return evalSubTree1_S38($h); # [S38]
          }
      }
  }
}

# SubTree [S2]

sub evalSubTree1_S2 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',3,);
  }
}

# SubTree [S3]

sub evalSubTree1_S3 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|NSUFF_FEM_SG|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECTspec_plusIVSUFF_SUBJ') {
    return ('right',2,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('none',4,1);
  }
}

# SubTree [S4]

sub evalSubTree1_S4 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'spec_ampergtspec_semicolaw') {
    return ('none',12,3);
  } elsif ($h->{a_lemma} eq 'kamA') {
    return ('none',6,1);
  } elsif ($h->{a_lemma} eq 'wa') {
    return ('none',971,312);
  } elsif ($h->{a_lemma} eq 'munou') {
    return ('none',13,1);
  } elsif ($h->{a_lemma} eq 'lspec_aph2kinspec_tildaa') {
    return ('right',14,3);
  } elsif ($h->{a_lemma} eq 'fa') {
    return ('right',35,16);
  } elsif ($h->{a_lemma} eq 'aw') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|ABBREV|PRON_1P)$/) {
        return ('none',0,);
      } elsif ($h->{b_taghead} eq 'SUBJUNC') {
        return ('none',1,);
      } elsif ($h->{b_taghead} eq 'IV2D') {
        return ('right',1,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('right',1,);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('right',3,);
      } elsif ($h->{b_taghead} eq 'PREP') {
        return ('none',6,);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return ('none',1,);
      }
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return evalSubTree1_S39($h); # [S39]
  }
}

# SubTree [S5]

sub evalSubTree1_S5 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('none',2,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('left',2,);
  }
}

# SubTree [S6]

sub evalSubTree1_S6 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'ilspec_tildaA') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'hunAka') {
    return ('none',2,);
  }
}

# SubTree [S7]

sub evalSubTree1_S7 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolaw') {
    return ('right',5,1);
  } elsif ($h->{b_lemma} eq 'kamA') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'wa') {
    return ('left',33,20);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('none',8,4);
  } elsif ($h->{b_lemma} eq 'munou') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'fa') {
    return ('none',2,1);
  }
}

# SubTree [S8]

sub evalSubTree1_S8 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'ayspec_tilda') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolayspec_tilda') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('none',4,2);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaatiy') {
    return ('none',3,);
  }
}

# SubTree [S9]

sub evalSubTree1_S9 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',11,5);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',23,3);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return ('right',2,);
  }
}

# SubTree [S10]

sub evalSubTree1_S10 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|NSUFF_FEM_SG|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{a_tagtail} eq 'empty') {
    return ('none',2188,313);
  } elsif ($h->{a_tagtail} eq 'CASE_ACC') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|FUNC_WORD|PRON_3D|FUT|ADJ|ABBREV|PRON_1P)$/) {
        return ('right',0,);
      } elsif ($h->{b_taghead} eq 'CONJ') {
        return ('right',7,2);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('none',3,1);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('none',2,1);
      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
        return ('right',1,);
      } elsif ($h->{b_taghead} eq 'PREP') {
        return ('none',4,);
      }
  }
}

# SubTree [S11]

sub evalSubTree1_S11 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|NSUFF_FEM_SG|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT)$/) {
    return ('none',0,);
  } elsif ($h->{a_tagtail} eq 'empty') {
    return ('right',2,);
  } elsif ($h->{a_tagtail} eq 'PVSUFF_SUBJ') {
    return ('none',6,2);
  }
}

# SubTree [S12]

sub evalSubTree1_S12 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('none',8,);
  } elsif ($h->{b_lemma} eq 'undef') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',38,15);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',35,13);
  } elsif ($h->{b_lemma} eq '‘') {
    return ('right',6,2);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return ('right',2,);
  }
}

# SubTree [S13]

sub evalSubTree1_S13 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{a_lemma} eq 'kAnspec_plusat') {
    return ('right',3,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('none',2,);
  }
}

# SubTree [S14]

sub evalSubTree1_S14 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|tamspec_tildauwz|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|layosspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('left',0,);
  } elsif ($h->{a_lemma} eq 'kAn') {
    return ('left',5,1);
  } elsif ($h->{a_lemma} eq 'kAnspec_plusat') {
    return ('left',4,1);
  } elsif ($h->{a_lemma} eq 'aDAf') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'spec_ampergtspec_semicolakspec_tildaadspec_plusa') {
    return ('left',2,);
  } elsif ($h->{a_lemma} eq 'qAlspec_plusa') {
    return ('none',9,5);
  } elsif ($h->{a_lemma} eq 'qAl') {
    return ('right',4,);
  } elsif ($h->{a_lemma} eq 'kAnspec_plusa') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'spec_ampergtspec_semicolaDAfspec_plusa') {
    return ('left',1,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return evalSubTree1_S40($h); # [S40]
  }
}

# SubTree [S15]

sub evalSubTree1_S15 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM)$/) {
    return ('right',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_PL') {
    return ('right',3,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',7,1);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('right',15,1);
  } elsif ($h->{b_tagtail} eq 'IV3MSspec_plusVERB_IMPERFECT') {
    return ('none',1,);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECT') {
    return ('none',20,);
  } elsif ($h->{b_tagtail} eq 'PVSUFF_SUBJ') {
    return ('none',10,1);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return evalSubTree1_S41($h); # [S41]
  }
}

# SubTree [S16]

sub evalSubTree1_S16 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Alspec_plustijArspec_plusap|baronAmaj|jadiydspec_plusap|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|3|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|fatorspec_plusap|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|Hawola|waziyr|baEoda|kaos|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|spec_rbrace|Aloyawom|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|raspec_rbraceiys|yuwliyuw|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{b_lemma} eq 'Ean') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'yaspec_plustimspec_tilda') {
    return ('right',3,1);
  } elsif ($h->{b_lemma} eq 'Ealay') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'isorAspec_rbraceiyl') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'huwa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolan') {
    return ('none',5,);
  } elsif ($h->{b_lemma} eq 'yaspec_pluskuwn') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'kamA') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'wa') {
    return ('right',47,18);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('none',7,);
  } elsif ($h->{b_lemma} eq 'hu') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'yuspec_plusmokin') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'bi') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('none',10,);
  } elsif ($h->{b_lemma} eq 'kAnspec_plusat') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',32,8);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolilaY') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'inspec_tildaa') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'lA') {
    return ('none',5,1);
  } elsif ($h->{b_lemma} eq 'aDAf') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'humA') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'sa') {
    return ('none',5,);
  } elsif ($h->{b_lemma} eq 'spec_asterspec_aph2lika') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'hiya') {
    return ('none',3,1);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'qAlspec_plusa') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'munou') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'kAnspec_plusa') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Eadad') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Hatspec_tildaaY') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'ilspec_tildaA') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'nA') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('none',10,2);
  } elsif ($h->{b_lemma} eq 'EalaY') {
    return ('none',7,1);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolaDAfspec_plusa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'lspec_aph2kinspec_tildaa') {
    return ('none',4,2);
  } elsif ($h->{b_lemma} eq 'fa') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'hunAka') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'min') {
    return evalSubTree1_S42($h); # [S42]
  } elsif ($h->{b_lemma} eq 'other_lemma') {
      if ($h->{b_det} eq 'det') {
        return ('none',12,2);
      } elsif ($h->{b_det} eq 'nodet') {
        return evalSubTree1_S43($h); # [S43]
      }
  }
}

# SubTree [S17]

sub evalSubTree1_S17 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_PL') {
    return ('right',13,6);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_SG') {
    return ('left',56,32);
  } elsif ($h->{a_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',1,);
  } elsif ($h->{a_tagtail} eq 'empty') {
    return ('none',61,22);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_DU_NOM') {
    return ('right',1,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('right',1,);
  }
}

# SubTree [S18]

sub evalSubTree1_S18 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'ayspec_tilda') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaiyna') {
    return ('right',6,);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaiy') {
    return ('none',25,10);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaspec_asteriy') {
    return ('right',17,8);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolayspec_tilda') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('none',31,2);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaatiy') {
    return ('right',66,21);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
      if ($h->{a_det} eq 'det') {
        return ('right',3,1);
      } elsif ($h->{a_det} eq 'nodet') {
        return ('none',4,);
      }
  }
}

# SubTree [S19]

sub evalSubTree1_S19 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|IV1Pspec_plusVERB_IMPERFECT|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',10,1);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',12,2);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('none',32,11);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('none',2,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_PL_NOM') {
    return ('right',1,);
  }
}

# SubTree [S20]

sub evalSubTree1_S20 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|ilaY|iy|bi|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusqudos') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'miSor') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'Hizob') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'Alspec_plusjumoEspec_plusap') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'diyfiyd') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'Alspec_plussabot') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'bagodAd') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'Aloyawom') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return evalSubTree1_S44($h); # [S44]
  }
}

# SubTree [S21]

sub evalSubTree1_S21 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_DU_NOM') {
    return ('none',2,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_PL') {
    return ('right',8,2);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('none',126,29);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return evalSubTree1_S45($h); # [S45]
  }
}

# SubTree [S22]

sub evalSubTree1_S22 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'iy') {
    return ('left',2,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('none',5,2);
  } elsif ($h->{a_lemma} eq 'spec_tildaa') {
    return ('none',45,);
  }
}

# SubTree [S23]

sub evalSubTree1_S23 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'ayspec_tilda') {
    return ('right',16,);
  } elsif ($h->{a_lemma} eq 'Alspec_tildaaiyna') {
    return ('none',15,1);
  } elsif ($h->{a_lemma} eq 'Alspec_tildaaiy') {
    return ('none',48,1);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('none',16,4);
  } elsif ($h->{a_lemma} eq 'Alspec_tildaaspec_asteriy') {
    return ('none',28,1);
  } elsif ($h->{a_lemma} eq 'spec_ampergtspec_semicolayspec_tilda') {
    return ('right',10,);
  } elsif ($h->{a_lemma} eq 'mA') {
    return ('right',57,14);
  } elsif ($h->{a_lemma} eq 'Alspec_tildaatiy') {
    return ('none',141,);
  }
}

# SubTree [S24]

sub evalSubTree1_S24 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'hA') {
    return ('none',65,10);
  } elsif ($h->{a_lemma} eq 'hiya') {
    return ('left',10,1);
  }
}

# SubTree [S25]

sub evalSubTree1_S25 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{a_lemma} eq 'qad') {
    return ('left',14,2);
  } elsif ($h->{a_lemma} eq 'spec_ampergtspec_semicolan') {
    return ('right',19,);
  } elsif ($h->{a_lemma} eq 'anspec_tildaa') {
    return ('right',17,3);
  } elsif ($h->{a_lemma} eq 'an') {
    return ('right',26,);
  } elsif ($h->{a_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('right',17,4);
  } elsif ($h->{a_lemma} eq 'inspec_tildaa') {
    return ('right',5,2);
  } elsif ($h->{a_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('right',5,2);
  }
}

# SubTree [S26]

sub evalSubTree1_S26 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('left',2,);
  } elsif ($h->{a_lemma} eq 'nA') {
    return ('none',12,4);
  }
}

# SubTree [S27]

sub evalSubTree1_S27 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM)$/) {
    return ('left',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',4,1);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECTspec_plusIVSUFF_SUBJ') {
    return ('left',5,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('right',1,);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECT') {
    return ('left',62,);
  } elsif ($h->{b_tagtail} eq 'PVSUFF_SUBJ') {
    return ('left',2,);
  } elsif ($h->{b_tagtail} eq 'empty') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|CONJ|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|PRON_3D|FUT|ABBREV|PRON_1P)$/) {
        return ('right',0,);
      } elsif ($h->{b_taghead} eq 'ADV') {
        return ('right',3,);
      } elsif ($h->{b_taghead} eq 'REL_PRON') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'POSS_PRON_3FS') {
        return ('right',2,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('left',8,1);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('right',13,4);
      } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
        return ('right',2,);
      } elsif ($h->{b_taghead} eq 'PREP') {
        return ('right',4,1);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return ('right',2,);
      }
  }
}

# SubTree [S28]

sub evalSubTree1_S28 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'huwa') {
    return ('left',18,4);
  } elsif ($h->{a_lemma} eq 'hi') {
    return ('none',16,);
  } elsif ($h->{a_lemma} eq 'hu') {
    return evalSubTree1_S46($h); # [S46]
  }
}

# SubTree [S29]

sub evalSubTree1_S29 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('none',100,33);
  } elsif ($h->{a_lemma} eq 'Hatspec_tildaaY') {
    return ('left',2,1);
  } elsif ($h->{a_lemma} eq 'ilspec_tildaA') {
    return ('right',4,);
  } elsif ($h->{a_lemma} eq 'Aloyawom') {
    return ('none',11,);
  } elsif ($h->{a_lemma} eq 'hunAka') {
    return ('none',10,4);
  } elsif ($h->{a_lemma} eq 'jidspec_tilda') {
    return ('none',9,);
  } elsif ($h->{a_lemma} eq 'naHow') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('left',0,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('left',6,1);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('right',2,);
      }
  } elsif ($h->{a_lemma} eq 'xuSuwSspec_plusAF') {
    return evalSubTree1_S47($h); # [S47]
  }
}

# SubTree [S30]

sub evalSubTree1_S30 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'maEa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'min') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq '‘') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'li') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'spec_rbrace') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('none',3,1);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|PREP|ABBREV|PRON_1P)$/) {
        return ('none',0,);
      } elsif ($h->{b_taghead} eq 'CONJ') {
        return ('right',1,);
      } elsif ($h->{b_taghead} eq 'IV3MS') {
        return ('left',2,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('left',1,);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return ('none',1,);
      }
  }
}

# SubTree [S31]

sub evalSubTree1_S31 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|kamA|wa|Alspec_plusdawolspec_plusap|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|Alspec_plusmuqobil|Eadam|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'spec_ddot') {
    return ('none',27,);
  } elsif ($h->{a_lemma} eq 'spec_percnt') {
    return ('none',12,);
  } elsif ($h->{a_lemma} eq '6') {
    return ('left',10,1);
  } elsif ($h->{a_lemma} eq '7') {
    return ('none',25,);
  } elsif ($h->{a_lemma} eq '51') {
    return ('right',21,);
  } elsif ($h->{a_lemma} eq 'έν') {
    return ('right',9,);
  } elsif ($h->{a_lemma} eq 'spec_dot') {
    return ('none',30,);
  } elsif ($h->{a_lemma} eq 'undef') {
    return ('none',130,16);
  } elsif ($h->{a_lemma} eq 'spec_rpar') {
    return ('none',74,1);
  } elsif ($h->{a_lemma} eq '‘') {
    return ('none',150,8);
  } elsif ($h->{a_lemma} eq 'spec_comma') {
    return ('none',8,);
  } elsif ($h->{a_lemma} eq '11') {
    return ('right',9,);
  } elsif ($h->{a_lemma} eq 'spec_rbrace') {
    return ('none',11,1);
  } elsif ($h->{a_lemma} eq 'ζ') {
    return ('none',4,1);
  } elsif ($h->{a_lemma} eq '3') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('right',0,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('left',4,1);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('right',5,);
      }
  } elsif ($h->{a_lemma} eq 'spec_slash') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|NOUN|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|FUNC_WORD|PRON_3D|FUT|PREP|ADJ|ABBREV|PRON_1P)$/) {
        return ('right',0,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('none',10,);
      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
        return ('right',23,);
      }
  } elsif ($h->{a_lemma} eq 'spec_lbrace') {
    return evalSubTree1_S48($h); # [S48]
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return evalSubTree1_S49($h); # [S49]
  } elsif ($h->{a_lemma} eq 'spec_quot') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|undef|PRON_3MP|POSS_PRON_1P|PRON_3MS|POSS_PRON_1S|IV2D|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|PRON_2MP|PRON_3D|PRON_1P)$/) {
        return ('none',0,);
      } elsif ($h->{b_taghead} eq 'PRON_1S') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
        return ('none',9,3);
      } elsif ($h->{b_taghead} eq 'SUBJUNC') {
        return ('none',1,);
      } elsif ($h->{b_taghead} eq 'IV1S') {
        return ('left',1,);
      } elsif ($h->{b_taghead} eq 'NEG_PART') {
        return ('none',10,);
      } elsif ($h->{b_taghead} eq 'ADV') {
        return ('none',4,1);
      } elsif ($h->{b_taghead} eq 'CONJ') {
        return ('none',18,1);
      } elsif ($h->{b_taghead} eq 'REL_PRON') {
        return ('none',12,1);
      } elsif ($h->{b_taghead} eq 'DEM_PRON_F') {
        return ('none',1,);
      } elsif ($h->{b_taghead} eq 'IV3MP') {
        return ('none',1,);
      } elsif ($h->{b_taghead} eq 'IV3MS') {
        return ('left',1,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('none',45,17);
      } elsif ($h->{b_taghead} eq 'IV3FS') {
        return ('left',5,1);
      } elsif ($h->{b_taghead} eq 'DEM_PRON_MS') {
        return ('none',1,);
      } elsif ($h->{b_taghead} eq 'FUNC_WORD') {
        return ('none',29,8);
      } elsif ($h->{b_taghead} eq 'FUT') {
        return ('none',3,);
      } elsif ($h->{b_taghead} eq 'PREP') {
        return ('none',32,3);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return ('none',12,3);
      } elsif ($h->{b_taghead} eq 'ABBREV') {
        return ('none',4,);
      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
        return evalSubTree1_S50($h); # [S50]
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return evalSubTree1_S51($h); # [S51]
      }
  } elsif ($h->{a_lemma} eq 'spec_lpar') {
    return evalSubTree1_S52($h); # [S52]
  }
}

# SubTree [S32]

sub evalSubTree1_S32 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|Alspec_plusmiSoriyspec_tilda|naHow|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|yaspec_pluskuwn|3|kamA|Alspec_plusdawolspec_plusap|madiynspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|b|Alspec_plusabAb|duwlAr|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Hasab|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|Didspec_tilda|binAspec_aph|miloyuwn|Alspec_plusjadiydspec_plusap|hspec_aph2spec_asterA|ka|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|humA|kaos|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|qAlspec_plusa|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|majomuwEspec_plusap|Eadad|ilspec_tildaA|nA|Hajom|ζ|Eadam|wizArspec_plusap|jiniyh|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusduwal|SaHiyfspec_plusap|qiymspec_plusap|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'qad') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'spec_ddot') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Ean') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusmutspec_tildaaHidspec_plusap') {
    return ('right',10,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'huwa') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'lan') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'anspec_tildaa') {
    return ('none',20,);
  } elsif ($h->{b_lemma} eq '6') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusEarabiyspec_tildaspec_plusap') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'hu') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'undef') {
    return ('none',6,);
  } elsif ($h->{b_lemma} eq 'an') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusjumoEspec_plusap') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'yuspec_plusmokin') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'diyfiyd') {
    return ('left',11,);
  } elsif ($h->{b_lemma} eq 'ilaY') {
    return ('none',6,);
  } elsif ($h->{b_lemma} eq 'iy') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'bi') {
    return ('none',25,1);
  } elsif ($h->{b_lemma} eq 'Alspec_plussabot') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'kAn') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'hspec_aph2A') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_rpar') {
    return ('none',13,1);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'maEa') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',27,8);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolilaY') {
    return ('none',6,);
  } elsif ($h->{b_lemma} eq 'min') {
    return ('none',11,1);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaspec_asteriy') {
    return ('none',5,);
  } elsif ($h->{b_lemma} eq 'inspec_tildaa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'bagodAd') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'xilAl') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq '‘') {
    return ('right',31,2);
  } elsif ($h->{b_lemma} eq 'lA') {
    return ('none',7,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolayspec_tilda') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Hawola') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'waziyr') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'baEoda') {
    return ('none',6,);
  } elsif ($h->{b_lemma} eq 'sa') {
    return ('none',4,);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'munou') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'EAm') {
    return ('none',4,1);
  } elsif ($h->{b_lemma} eq 'li') {
    return ('none',17,);
  } elsif ($h->{b_lemma} eq 'kAnspec_plusa') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusspec_dollararikspec_plusAt') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_rbrace') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'Hatspec_tildaaY') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Aloyawom') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'muHamspec_tildaad') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusmuqobil') {
    return ('right',6,);
  } elsif ($h->{b_lemma} eq 'spec_slash') {
    return ('left',22,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('none',42,2);
  } elsif ($h->{b_lemma} eq 'EalaY') {
    return ('none',17,);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'fa') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusmADiy') {
    return ('none',4,2);
  } elsif ($h->{b_lemma} eq 'Alspec_plusduwaliyspec_tilda') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaatiy') {
    return ('none',7,2);
  } elsif ($h->{b_lemma} eq 'wa') {
    return evalSubTree1_S53($h); # [S53]
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaiy') {
      if ($h->{a_det} eq 'det') {
        return ('none',3,1);
      } elsif ($h->{a_det} eq 'nodet') {
        return ('right',4,);
      }
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return evalSubTree1_S54($h); # [S54]
  }
}

# SubTree [S33]

sub evalSubTree1_S33 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|sibotamobir|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|spec_comma|spec_asterspec_aph2lika|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{a_lemma} eq 'Alspec_plustijArspec_plusap') {
    return ('right',7,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusspec_lbraceiqotiSAd') {
    return ('right',5,1);
  } elsif ($h->{a_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('right',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('right',8,);
  } elsif ($h->{a_lemma} eq 'Alspec_plustaEAwun') {
    return ('right',3,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('right',7,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusdawolspec_plusap') {
    return ('none',2,1);
  } elsif ($h->{a_lemma} eq 'Alspec_plusspec_amperltspec_semicolirohAb') {
    return ('right',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusqiTAE') {
    return ('right',5,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusabAb') {
    return ('none',4,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusfilasoTiyniyspec_tildaspec_plusap') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_pluswuzarAspec_aph') {
    return ('none',14,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusEuquwbspec_plusAt') {
    return ('right',2,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('right',424,62);
  } elsif ($h->{a_lemma} eq 'Alspec_plusbilAd') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusxArijiyspec_tildaspec_plusap') {
    return ('none',4,1);
  } elsif ($h->{a_lemma} eq 'Alspec_plusfilasoTiyniyspec_tilda') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusspec_dollararikspec_plusAt') {
    return ('right',10,);
  } elsif ($h->{a_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('right',11,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusduwal') {
    return ('right',10,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return evalSubTree1_S55($h); # [S55]
  } elsif ($h->{a_lemma} eq 'Alspec_plusyawom') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|NOUN|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|FUNC_WORD|PRON_3D|FUT|PREP|ABBREV|PRON_1P)$/) {
        return ('none',0,);
      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
        return ('none',20,);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return ('right',3,);
      }
  } elsif ($h->{a_lemma} eq 'Alspec_plusnafoT') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|NON_ALPHABETIC_DATA|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|NOUN_PROP|FUNC_WORD|PRON_3D|FUT|PREP|ABBREV|PRON_1P)$/) {
        return ('none',0,);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('right',3,);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return ('none',3,);
      }
  }
}

# SubTree [S34]

sub evalSubTree1_S34 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'xuSuwSspec_plusAF') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('none',11,2);
  } elsif ($h->{b_lemma} eq 'Aloyawom') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'jidspec_tilda') {
    return ('right',4,);
  }
}

# SubTree [S35]

sub evalSubTree1_S35 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('left',0,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_SG') {
    return ('left',4,);
  } elsif ($h->{a_tagtail} eq 'empty') {
    return ('none',5,2);
  }
}

# SubTree [S36]

sub evalSubTree1_S36 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('right',6,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('none',16,3);
  } elsif ($h->{a_lemma} eq 'Alspec_plusxArijiyspec_tildaspec_plusap') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusfilasoTiyniyspec_tilda') {
    return ('none',1,);
  }
}

# SubTree [S37]

sub evalSubTree1_S37 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'spec_ddot') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'undef') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'spec_lbrace') {
    return ('none',3,1);
  } elsif ($h->{b_lemma} eq 'spec_rpar') {
    return ('none',13,3);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',67,12);
  } elsif ($h->{b_lemma} eq '‘') {
    return ('right',50,1);
  } elsif ($h->{b_lemma} eq 'spec_comma') {
    return ('right',4,);
  } elsif ($h->{b_lemma} eq 'spec_rbrace') {
    return ('right',6,1);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return evalSubTree1_S56($h); # [S56]
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return evalSubTree1_S57($h); # [S57]
  }
}

# SubTree [S38]

sub evalSubTree1_S38 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq '51') {
    return ('none',23,);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('none',30,);
  } elsif ($h->{b_lemma} eq 'undef') {
    return ('none',24,6);
  } elsif ($h->{b_lemma} eq 'spec_rpar') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',4,);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return ('right',2,);
  }
}

# SubTree [S39]

sub evalSubTree1_S39 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT)$/) {
    return ('none',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('none',3,1);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',2,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('none',53,15);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_PL_NOM') {
    return ('left',1,);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECT') {
    return ('right',21,8);
  } elsif ($h->{b_tagtail} eq 'PVSUFF_SUBJ') {
    return ('right',4,);
  }
}

# SubTree [S40]

sub evalSubTree1_S40 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('left',0,);
  } elsif ($h->{b_lemma} eq 'kamA') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'wa') {
    return ('left',68,39);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('none',8,2);
  } elsif ($h->{b_lemma} eq 'munou') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'lspec_aph2kinspec_tildaa') {
    return ('left',2,);
  } elsif ($h->{b_lemma} eq 'fa') {
    return ('left',7,2);
  }
}

# SubTree [S41]

sub evalSubTree1_S41 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|yaspec_pluskuwn|3|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|iy|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|Didspec_tilda|binAspec_aph|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|ka|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|kaos|Alspec_plusbilAd|spec_comma|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|hspec_aph2spec_asterihi|qAlspec_plusa|EAm|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{b_lemma} eq 'qad') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'Ealay') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'lan') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolaw') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'anspec_tildaa') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq 'kamA') {
    return ('none',3,1);
  } elsif ($h->{b_lemma} eq 'wa') {
    return ('none',37,21);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('none',4,);
  } elsif ($h->{b_lemma} eq 'an') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'ilaY') {
    return ('right',5,);
  } elsif ($h->{b_lemma} eq 'bi') {
    return ('right',14,1);
  } elsif ($h->{b_lemma} eq 'spec_lbrace') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'spec_rpar') {
    return ('none',4,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('none',4,1);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',62,18);
  } elsif ($h->{b_lemma} eq 'maEa') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',42,8);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolilaY') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'min') {
    return ('right',8,3);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaspec_asteriy') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'bagodAd') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'xilAl') {
    return ('right',3,);
  } elsif ($h->{b_lemma} eq '‘') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'lA') {
    return ('none',4,);
  } elsif ($h->{b_lemma} eq 'baEoda') {
    return ('right',5,);
  } elsif ($h->{b_lemma} eq 'sa') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolilay') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'spec_asterspec_aph2lika') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('none',5,3);
  } elsif ($h->{b_lemma} eq 'munou') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'li') {
    return ('right',9,3);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('right',29,12);
  } elsif ($h->{b_lemma} eq 'EalaY') {
    return ('right',8,);
  } elsif ($h->{b_lemma} eq 'lspec_aph2kinspec_tildaa') {
    return ('left',2,);
  } elsif ($h->{b_lemma} eq 'fa') {
    return ('right',1,);
  }
}

# SubTree [S42]

sub evalSubTree1_S42 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|other_lemma|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'qad') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'anspec_tildaa') {
    return ('right',2,);
  }
}

# SubTree [S43]

sub evalSubTree1_S43 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM)$/) {
    return ('right',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',12,4);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECTspec_plusIVSUFF_SUBJ') {
    return ('right',8,2);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',6,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('right',59,21);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_DU_ACCGEN') {
    return ('none',4,);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECT') {
    return ('right',79,14);
  } elsif ($h->{b_tagtail} eq 'PVSUFF_SUBJ') {
    return ('right',49,7);
  }
}

# SubTree [S44]

sub evalSubTree1_S44 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|lam|lan|taqodiym|miSor|daEom|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwaliyspec_tilda|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'baronAmaj') {
    return ('none',4,);
  } elsif ($h->{a_lemma} eq 'majolis') {
    return ('none',3,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'spec_lbraceisom') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plustaEAwun') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'Hizob') {
    return ('right',1,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusdawolspec_plusap') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusnafoT') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('none',91,37);
  } elsif ($h->{a_lemma} eq 'waziyr') {
    return ('right',6,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusxArijiyspec_tildaspec_plusap') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusfilasoTiyniyspec_tilda') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Eadam') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'raspec_rbraceiys') {
    return ('right',7,);
  } elsif ($h->{a_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('none',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusduwal') {
    return ('none',5,);
  } elsif ($h->{a_lemma} eq 'SaHiyfspec_plusap') {
    return ('right',2,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusraspec_rbraceiys') {
      if ($h->{b_det} eq 'det') {
        return ('none',6,2);
      } elsif ($h->{b_det} eq 'nodet') {
        return ('right',13,3);
      }
  }
}

# SubTree [S45]

sub evalSubTree1_S45 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('none',4,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('right',35,13);
  } elsif ($h->{b_lemma} eq 'Alspec_plusxASspec_tildaspec_plusap') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plussiyAHspec_plusap') {
    return ('right',2,);
  }
}

# SubTree [S46]

sub evalSubTree1_S46 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|NSUFF_FEM_SG|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM)$/) {
    return ('none',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',1,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('none',36,6);
  } elsif ($h->{b_tagtail} eq 'VERB_IMPERFECT') {
    return ('none',2,);
  } elsif ($h->{b_tagtail} eq 'PVSUFF_SUBJ') {
    return ('left',8,2);
  }
}

# SubTree [S47]

sub evalSubTree1_S47 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'ilaY') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('none',3,1);
  } elsif ($h->{b_lemma} eq 'maEa') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'baEoda') {
    return ('left',2,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('right',1,);
  }
}

# SubTree [S48]

sub evalSubTree1_S48 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('left',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_PL') {
    return ('left',1,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('left',4,1);
  } elsif ($h->{b_tagtail} eq 'empty') {
      if ($h->{b_det} eq 'det') {
        return ('none',5,1);
      } elsif ($h->{b_det} eq 'nodet') {
        return ('left',9,3);
      }
  }
}

# SubTree [S49]

sub evalSubTree1_S49 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|spec_lbraceisom|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|xuSuwSspec_plusAF|TahorAn|yaspec_pluskuwn|3|kamA|Alspec_plusdawolspec_plusap|madiynspec_plusap|7|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|ladaY|bayonspec_plusa|if|aw|yuspec_plusmokin|Alspec_plusabAb|diyfiyd|iy|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_pluswuzarAspec_aph|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|Alspec_plusnafoT|maSAdir|Alspec_plusduwaliyspec_tildaspec_plusap|binAspec_aph|Alspec_tildaaspec_asteriy|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|Hawola|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|11|hiya|Alspec_plusxASspec_tildaspec_plusap|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|spec_tildaa|Alspec_plusSAdirspec_plusAt|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|Alspec_plusmuqobil|Eadam|wizArspec_plusap|jiniyh|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|SaHiyfspec_plusap|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('right',0,);
  } elsif ($h->{b_lemma} eq 'spec_ddot') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'naHow') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'Ean') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusspec_lbraceiqotiSAd') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'huwa') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolan') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'lam') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'yawom') {
    return ('none',3,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusqimspec_tildaspec_plusap') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusyawom') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_percnt') {
    return ('right',8,);
  } elsif ($h->{b_lemma} eq 'anspec_tildaa') {
    return ('none',9,);
  } elsif ($h->{b_lemma} eq 'wa') {
    return ('none',18,7);
  } elsif ($h->{b_lemma} eq '6') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusEarabiyspec_tildaspec_plusap') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'alof') {
    return ('right',10,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusEirAq') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'έν') {
    return ('right',11,4);
  } elsif ($h->{b_lemma} eq 'spec_dot') {
    return ('right',3,1);
  } elsif ($h->{b_lemma} eq 'undef') {
    return ('none',6,4);
  } elsif ($h->{b_lemma} eq 'an') {
    return ('right',5,2);
  } elsif ($h->{b_lemma} eq 'maloyuwn') {
    return ('right',7,1);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolalof') {
    return ('right',9,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusjumoEspec_plusap') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'b') {
    return ('none',12,);
  } elsif ($h->{b_lemma} eq 'duwlAr') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'ilaY') {
    return ('right',5,2);
  } elsif ($h->{b_lemma} eq 'bi') {
    return ('right',7,1);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaiy') {
    return ('right',4,);
  } elsif ($h->{b_lemma} eq 'Hasab') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'kAn') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'EAmspec_plusAF') {
    return ('right',6,);
  } elsif ($h->{b_lemma} eq 'w') {
    return ('none',9,4);
  } elsif ($h->{b_lemma} eq 'spec_lbrace') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'ziyAdspec_plusap') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'spec_rpar') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'spec_ampergtspec_semicolanspec_tildaa') {
    return ('none',6,);
  } elsif ($h->{b_lemma} eq 'kAnspec_plusat') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'maEa') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'spec_quot') {
    return ('none',30,10);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolilaY') {
    return ('none',6,2);
  } elsif ($h->{b_lemma} eq 'Didspec_tilda') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'min') {
    return ('right',17,1);
  } elsif ($h->{b_lemma} eq 'miloyuwn') {
    return ('right',13,);
  } elsif ($h->{b_lemma} eq 'xilAl') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq '‘') {
    return ('right',11,1);
  } elsif ($h->{b_lemma} eq 'humA') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'waziyr') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'spec_comma') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'kulspec_tilda') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'biloyuwn') {
    return ('right',19,);
  } elsif ($h->{b_lemma} eq 'la') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'mA') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'li') {
    return ('none',25,7);
  } elsif ($h->{b_lemma} eq 'muqAbil') {
    return ('none',5,);
  } elsif ($h->{b_lemma} eq 'bayona') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'spec_amperltspec_semicolinspec_tildaa') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'qabol') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'spec_rbrace') {
    return ('right',4,);
  } elsif ($h->{b_lemma} eq 'Hatspec_tildaaY') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'Aloyawom') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'ζ') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'spec_slash') {
    return ('right',5,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('none',21,7);
  } elsif ($h->{b_lemma} eq 'EalaY') {
    return ('none',11,1);
  } elsif ($h->{b_lemma} eq 'raspec_rbraceiys') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'spec_lpar') {
    return ('right',5,2);
  } elsif ($h->{b_lemma} eq 'Alspec_plusduwaliyspec_tilda') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq 'qiymspec_plusap') {
    return ('none',2,1);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaatiy') {
    return ('right',2,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|PRON_3MS|POSS_PRON_1S|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|FUNC_WORD|PRON_3D|FUT|PRON_1P)$/) {
        return ('right',0,);
      } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
        return ('none',8,2);
      } elsif ($h->{b_taghead} eq 'ADV') {
        return ('none',5,2);
      } elsif ($h->{b_taghead} eq 'IV3MP') {
        return ('right',2,);
      } elsif ($h->{b_taghead} eq 'IV2D') {
        return ('none',2,);
      } elsif ($h->{b_taghead} eq 'IV3MS') {
        return ('none',4,2);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('right',180,98);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return ('right',99,33);
      } elsif ($h->{b_taghead} eq 'IV3FS') {
        return ('right',4,1);
      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
        return ('left',10,2);
      } elsif ($h->{b_taghead} eq 'PREP') {
        return ('right',2,);
      } elsif ($h->{b_taghead} eq 'ABBREV') {
        return ('right',10,4);
      } elsif ($h->{b_taghead} eq 'ADJ') {
        return evalSubTree1_S58($h); # [S58]
      }
  }
}

# SubTree [S50]

sub evalSubTree1_S50 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusspec_lbraceitspec_tildaiHAd') {
    return ('left',3,);
  } elsif ($h->{b_lemma} eq 'Hizob') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_plusEirAq') {
    return ('none',4,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
    return ('none',11,3);
  } elsif ($h->{b_lemma} eq 'Aloyawom') {
    return ('left',1,);
  }
}

# SubTree [S51]

sub evalSubTree1_S51 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('left',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('left',34,13);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',6,2);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('left',62,18);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('none',5,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_PL') {
      if ($h->{b_det} eq 'det') {
        return ('none',8,1);
      } elsif ($h->{b_det} eq 'nodet') {
        return ('left',6,2);
      }
  }
}

# SubTree [S52]

sub evalSubTree1_S52 { 
  my $h=$_[0];

  if ($h->{b_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|kamA|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|muHamspec_tildaad|nA|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{b_lemma} eq '3') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'wa') {
    return ('none',1,);
  } elsif ($h->{b_lemma} eq '51') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'undef') {
    return ('none',12,);
  } elsif ($h->{b_lemma} eq 'if') {
    return ('none',22,);
  } elsif ($h->{b_lemma} eq 'Alspec_tildaaiy') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'kaos') {
    return ('right',1,);
  } elsif ($h->{b_lemma} eq 'fiy') {
    return ('left',1,);
  } elsif ($h->{b_lemma} eq 'Alspec_pluswilAyspec_plusAt') {
    return ('none',2,);
  } elsif ($h->{b_lemma} eq 'other_lemma') {
      if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|VERB_PERFECT|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|ADV|CONJ|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|IV3FS|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|FUNC_WORD|PRON_3D|FUT|PREP|ADJ|PRON_1P)$/) {
        return ('right',0,);
      } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
        return ('right',27,16);
      } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
        return ('none',8,1);
      } elsif ($h->{b_taghead} eq 'ABBREV') {
        return ('right',2,);
      } elsif ($h->{b_taghead} eq 'NOUN') {
        return evalSubTree1_S59($h); # [S59]
      }
  }
}

# SubTree [S53]

sub evalSubTree1_S53 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|Alspec_plusHukuwmspec_plusap|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|Alspec_plusraspec_rbraceiys|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusqudos') {
    return ('left',2,);
  } elsif ($h->{a_lemma} eq 'diyfiyd') {
    return ('none',3,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return ('left',30,14);
  } elsif ($h->{a_lemma} eq 'yuwliyuw') {
    return ('none',1,);
  }
}

# SubTree [S54]

sub evalSubTree1_S54 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_PL') {
    return ('none',1,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_SG') {
    return ('none',19,1);
  } elsif ($h->{a_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('right',1,);
  } elsif ($h->{a_tagtail} eq 'empty') {
      if ($h->{a_det} eq 'det') {
        return ('none',70,27);
      } elsif ($h->{a_det} eq 'nodet') {
          if ($h->{b_taghead} =~ /^(?:DEM_PRON_FS|IV1P|PRON_1S|SUBJUNC|IV1S|NEG_PART|IV3MD|POSS_PRON_3MP|POSS_PRON_3D|POSS_PRON_3MS|REL_PRON|undef|PRON_3MP|POSS_PRON_1P|DEM_PRON_F|IV3MP|PRON_3MS|POSS_PRON_1S|IV2D|IV3MS|POSS_PRON_3FS|PVSUFF_DO|POSS_PRON_2MP|IVSUFF_DO|PART|PRON_3FS|IV3FP|INTERROG_PART|DEM_PRON_MP|PRON_2MP|DEM_PRON_MS|FUNC_WORD|PRON_3D|FUT|ABBREV|PRON_1P)$/) {
            return ('left',0,);
          } elsif ($h->{b_taghead} eq 'VERB_PERFECT') {
            return ('none',12,4);
          } elsif ($h->{b_taghead} eq 'ADV') {
            return ('none',4,1);
          } elsif ($h->{b_taghead} eq 'CONJ') {
            return ('none',2,);
          } elsif ($h->{b_taghead} eq 'NON_ALPHABETIC_DATA') {
            return ('left',57,24);
          } elsif ($h->{b_taghead} eq 'NOUN') {
            return ('none',37,4);
          } elsif ($h->{b_taghead} eq 'IV3FS') {
            return ('left',5,2);
          } elsif ($h->{b_taghead} eq 'NOUN_PROP') {
            return ('left',90,30);
          } elsif ($h->{b_taghead} eq 'PREP') {
            return ('none',4,1);
          } elsif ($h->{b_taghead} eq 'ADJ') {
              if ($h->{b_det} eq 'det') {
                return ('none',10,2);
              } elsif ($h->{b_det} eq 'nodet') {
                return ('left',3,1);
              }
          }
      }
  }
}

# SubTree [S55]

sub evalSubTree1_S55 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('right',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',6,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('none',3,);
  }
}

# SubTree [S56]

sub evalSubTree1_S56 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_SG') {
    return ('left',3,1);
  } elsif ($h->{a_tagtail} eq 'empty') {
    return ('none',3,1);
  }
}

# SubTree [S57]

sub evalSubTree1_S57 { 
  my $h=$_[0];

  if ($h->{a_lemma} =~ /^(?:ayspec_tilda|Alspec_plusqudos|qad|Alspec_plusmiSoriyspec_tilda|spec_ddot|naHow|Ean|Alspec_plustijArspec_plusap|yaspec_plustimspec_tilda|baronAmaj|jadiydspec_plusap|Ealay|isorAspec_rbraceiyl|Alspec_plusmutspec_tildaaHidspec_plusap|ragom|majolis|Alspec_plusspec_lbraceiqotiSAd|Alspec_plusspec_lbraceitspec_tildaiHAd|Eamaliyspec_tildaspec_plusAt|gayor|hA|huwa|spec_ampergtspec_semicolan|spec_lbraceisom|lam|lan|taqodiym|miSor|daEom|Alspec_plustaEAwun|yawom|Alspec_plusspec_ampergtspec_semicolamoriykiyspec_tildaspec_plusap|spec_ampergtspec_semicolaw|Hizob|Alspec_plusqimspec_tildaspec_plusap|Alspec_plusyawom|spec_percnt|xuSuwSspec_plusAF|TahorAn|anspec_tildaa|yaspec_pluskuwn|3|kamA|wa|Alspec_plusdawolspec_plusap|6|madiynspec_plusap|Alspec_plusEarabiyspec_tildaspec_plusap|7|alof|spec_dollararikspec_plusAt|hum|51|Alspec_plusEirAq|hi|gAlibiyspec_tildaspec_plusap|έν|spec_dot|qiTAE|Alspec_tildaaiyna|hu|undef|Alspec_plusspec_amperltspec_semicolirohAb|sibotamobir|Alspec_plusqiTAE|an|ladaY|maloyuwn|bayonspec_plusa|if|spec_ampergtspec_semicolalof|aw|Alspec_plusjumoEspec_plusap|yuspec_plusmokin|b|Alspec_plusabAb|duwlAr|diyfiyd|ilaY|iy|bi|Alspec_plussabot|Alspec_plusfilasoTiyniyspec_tildaspec_plusap|Alspec_tildaaiy|Hasab|kAn|EAmspec_plusAF|Alspec_pluswuzarAspec_aph|w|spec_lbrace|Alspec_plusEirAqiyspec_tilda|Alspec_plusisorAspec_rbraceiyliyspec_tildaspec_plusap|hspec_aph2A|Alspec_plusEuquwbspec_plusAt|ziyAdspec_plusap|spec_rpar|spec_ampergtspec_semicolanspec_tildaa|Alspec_plusnafoT|maSAdir|kAnspec_plusat|Alspec_plusduwaliyspec_tildaspec_plusap|maEa|spec_quot|spec_amperltspec_semicolilaY|Didspec_tilda|binAspec_aph|min|Alspec_tildaaspec_asteriy|miloyuwn|Alspec_plusjadiydspec_plusap|inspec_tildaa|hspec_aph2spec_asterA|bagodAd|ka|xilAl|‘|lA|fatorspec_plusap|aDAf|tamspec_tildauwz|spec_ampergtspec_semicolakspec_tildaadspec_plusa|spec_ampergtspec_semicolayspec_tilda|humA|Hawola|waziyr|baEoda|kaos|sa|spec_amperltspec_semicolilay|Alspec_plusbilAd|spec_comma|spec_asterspec_aph2lika|waDoE|Alspec_plusxArijiyspec_tildaspec_plusap|kulspec_tilda|11|hiya|biloyuwn|Alspec_plusxASspec_tildaspec_plusap|la|mA|hspec_aph2spec_asterihi|qAlspec_plusa|munou|EAm|li|Alspec_plusmiSoriyspec_tildaspec_plusap|qAl|layosspec_plusa|kAnspec_plusa|Alspec_plusfilasoTiyniyspec_tilda|muqAbil|bayona|spec_tildaa|Alspec_plusSAdirspec_plusAt|spec_amperltspec_semicolinspec_tildaa|qabol|Eidspec_tildaspec_plusap|Alspec_plusspec_dollararikspec_plusAt|majomuwEspec_plusap|Eadad|spec_rbrace|Hatspec_tildaaY|ilspec_tildaA|Aloyawom|nA|muHamspec_tildaad|Hajom|ζ|Alspec_plusmuqobil|Eadam|spec_slash|wizArspec_plusap|fiy|jiniyh|EalaY|raspec_rbraceiys|spec_lpar|spec_ampergtspec_semicolaDAfspec_plusa|yuwliyuw|lspec_aph2kinspec_tildaa|HAl|Alspec_pluswilAyspec_plusAt|kAmob|Alspec_plussiyAHspec_plusap|qarAr|fa|hspec_aph2ihi|Alspec_plusmADiy|Alspec_plusduwal|Alspec_plusduwaliyspec_tilda|SaHiyfspec_plusap|qiymspec_plusap|Alspec_tildaatiy|spec_lbraceitspec_tildaifAq|hunAka|jidspec_tilda)$/) {
    return ('none',0,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusHukuwmspec_plusap') {
    return ('none',1,);
  } elsif ($h->{a_lemma} eq 'Alspec_plusraspec_rbraceiys') {
    return ('right',4,);
  } elsif ($h->{a_lemma} eq 'other_lemma') {
    return evalSubTree1_S60($h); # [S60]
  }
}

# SubTree [S58]

sub evalSubTree1_S58 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('right',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',4,1);
  } elsif ($h->{b_tagtail} eq 'NSUFF_MASC_SG_ACC_INDEF') {
    return ('none',3,);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('right',12,5);
  }
}

# SubTree [S59]

sub evalSubTree1_S59 { 
  my $h=$_[0];

  if ($h->{b_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|NSUFF_FEM_PL|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|NSUFF_MASC_PL_ACCGEN|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('left',0,);
  } elsif ($h->{b_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',4,1);
  } elsif ($h->{b_tagtail} eq 'empty') {
    return ('left',7,3);
  }
}

# SubTree [S60]

sub evalSubTree1_S60 { 
  my $h=$_[0];

  if ($h->{a_tagtail} =~ /^(?:IV3FSspec_plusVERB_IMPERFECT|NSUFF_MASC_DU_NOM|NSUFF_FEM_DU_ACCGEN|NSUFF_FEM_DU_NOM_POSS|IV1Sspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_ACCGEN_POSS|VERB_IMPERFECTspec_plusIVSUFF_SUBJ|CASE_ACC|NSUFF_MASC_PL_ACCGEN_POSS|NSUFF_MASC_SG_ACC_INDEF|NSUFF_MASC_DU_NOM_POSS|CASE_DEF_GEN|IV3MSspec_plusVERB_IMPERFECT|NSUFF_FEM_DU_NOM|IV3MPspec_plusVERB_IMPERFECTspec_plusIVSUFF_SUBJ|NSUFF_MASC_DU_ACCGEN_POSS|NSUFF_MASC_DU_ACCGEN|IV2MSspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM_POSS|IV1Pspec_plusVERB_IMPERFECT|NSUFF_MASC_PL_NOM|VERB_IMPERFECT|PVSUFF_SUBJ)$/) {
    return ('none',0,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_PL') {
    return ('right',1,);
  } elsif ($h->{a_tagtail} eq 'NSUFF_FEM_SG') {
    return ('right',4,1);
  } elsif ($h->{a_tagtail} eq 'empty') {
    return ('none',28,9);
  } elsif ($h->{a_tagtail} eq 'NSUFF_MASC_PL_ACCGEN') {
    return ('none',1,);
  }
}

# Evaluation on hold-out data (3310 cases):
# 
# 	    Decision Tree   
# 	  ----------------  
# 	  Size      Errors  
# 
# 	   776  573(17.3%)   <<
# 
# 
# [ Fold 1 ]
# 

1;
