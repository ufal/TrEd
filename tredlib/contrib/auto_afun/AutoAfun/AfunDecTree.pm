# -*- cperl -*-
# This file was automatically generated with /home/pajas/treebank/perl/decision_trees2perl.pl
# by zabokrtsky@quinn.ms.mff.cuni.cz <Fri Mar 22 16:21:16 2002>

package AfunDecTree;

use Exporter;
use strict;
use vars qw(@ISA @EXPORT_OK);

BEGIN {
  @ISA=qw(Exporter);
  @EXPORT_OK=qw(evalTree);
}

#
# C5.0 [Release 1.16]  	Tue Feb 26 14:59:00 2002
# -------------------
#
#     Options:
# 	Application `no_coord'
#
# Read 1130083 cases (15 attributes) from no_coord.data
#

sub evalTree {
  my $h=$_[0];

  if ($h->{d_pos} eq 'x') {
    return ('atr',48,12);
  } elsif ($h->{d_pos} eq 'i') {
      if ($h->{g_pos} eq 'p') {
        return ('atr',0,);
      } elsif ($h->{g_pos} eq 'n') {
        return ('atr',36,6);
      } elsif ($h->{g_pos} eq 'a') {
        return ('adv',2,1);
      } elsif ($h->{g_pos} eq 'z') {
        return ('exd',20,6);
      } elsif ($h->{g_pos} eq 'c') {
        return ('atr',11,);
      } elsif ($h->{g_pos} eq 'd') {
        return ('adv',2,1);
      } elsif ($h->{g_pos} eq 'v') {
          if ($h->{i_voice} eq 'nic') {
            return ('exd_pa',24,12);
          } elsif ($h->{i_voice} eq 'undef') {
            return ('exd',3,);
          }
      }
  } elsif ($h->{d_pos} eq 'r') {
      if ($h->{d_case} eq '5') {
        return ('auxp',0,);
      } elsif ($h->{d_case} eq '2') {
        return ('auxp',24047,97);
      } elsif ($h->{d_case} eq '3') {
        return ('auxp',7040,72);
      } elsif ($h->{d_case} eq '4') {
        return ('auxp',23347,61);
      } elsif ($h->{d_case} eq '6') {
        return ('auxp',41843,67);
      } elsif ($h->{d_case} eq '7') {
        return ('auxp',12219,78);
      } elsif ($h->{d_case} eq 'undef') {
          if ($h->{i_voice} eq 'nic') {
            return ('adv',7,4);
          } elsif ($h->{i_voice} eq 'undef') {
            return ('auxp',218,);
          }
      } elsif ($h->{d_case} eq '1') {
          if ($h->{g_pos} =~ /^(?:p|c)$/) {
            return ('atr',0,);
          } elsif ($h->{g_pos} eq 'v') {
            return ('auxp',14,1);
          } elsif ($h->{g_pos} eq 'n') {
            return ('atr',145,35);
          } elsif ($h->{g_pos} eq 'z') {
            return ('auxp',25,7);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxp',1,);
          } elsif ($h->{g_pos} eq 'a') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                return ('auxp',0,);
              } elsif ($h->{g_subpos} eq 'a') {
                return ('auxp',3,);
              } elsif ($h->{g_subpos} eq 'u') {
                return ('atr',4,1);
              }
          }
      } elsif ($h->{d_case} eq 'x') {
          if ($h->{g_voice} eq 'p') {
            return ('atr',0,);
          } elsif ($h->{g_voice} eq 'a') {
            return ('auxp',8,4);
          } elsif ($h->{g_voice} eq 'undef') {
              if ($h->{i_voice} eq 'nic') {
                return ('atr',215,59);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('auxp',4,);
              }
          }
      }
  } elsif ($h->{d_pos} eq 'j') {
      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
        return ('coord',0,);
      } elsif ($h->{d_subpos} eq 'spec_aster') {
          if ($h->{i_subpos} =~ /^(?:spec_at|t|f|v|x|i)$/) {
            return ('atr',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('coord',1,);
          } elsif ($h->{i_subpos} eq 'r') {
            return ('coord',5,);
          } elsif ($h->{i_subpos} eq 'spec_head') {
            return ('adv',5,2);
          } elsif ($h->{i_subpos} eq 'spec_aster') {
            return ('auxg',13,2);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('exd',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('coord',7,1);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('adv',1,);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('exd',9,1);
              }
          } elsif ($h->{i_subpos} eq 'nic') {
              if ($h->{g_pos} =~ /^(?:p|z)$/) {
                return ('atr',0,);
              } elsif ($h->{g_pos} eq 'v') {
                return ('adv',10,2);
              } elsif ($h->{g_pos} eq 'a') {
                return ('adv',5,1);
              } elsif ($h->{g_pos} eq 'c') {
                return ('atr',48,16);
              } elsif ($h->{g_pos} eq 'd') {
                return ('adv',3,);
              } elsif ($h->{g_pos} eq 'n') {
                  if ($h->{g_case} =~ /^(?:5|undef)$/) {
                    return ('coord',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('atr',17,5);
                  } elsif ($h->{g_case} eq '2') {
                    return ('coord',4,);
                  } elsif ($h->{g_case} eq '3') {
                    return ('coord_pa',1,);
                  } elsif ($h->{g_case} eq '4') {
                    return ('coord',2,);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord',5,1);
                  } elsif ($h->{g_case} eq '7') {
                    return ('coord',2,);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('coord',2,);
                  }
              }
          }
      } elsif ($h->{d_subpos} eq 'spec_head') {
          if ($h->{i_pos} =~ /^(?:x|i)$/) {
            return ('coord',0,);
          } elsif ($h->{i_pos} eq 'r') {
            return ('coord',3381,124);
          } elsif ($h->{i_pos} eq 't') {
              if ($h->{g_pos} eq 'c') {
                return ('coord',0,);
              } elsif ($h->{g_pos} eq 'v') {
                return ('coord',24,6);
              } elsif ($h->{g_pos} eq 'n') {
                return ('auxy',9,3);
              } elsif ($h->{g_pos} eq 'p') {
                return ('coord',1,);
              } elsif ($h->{g_pos} eq 'a') {
                return ('auxy',1,);
              } elsif ($h->{g_pos} eq 'z') {
                return ('coord',5,);
              } elsif ($h->{g_pos} eq 'd') {
                return ('auxz',3,1);
              }
          } elsif ($h->{i_pos} eq 'j') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('coord',0,);
              } elsif ($h->{i_lemma} eq 'aby') {
                return ('coord',135,1);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('coord',293,43);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('coord',1888,712);
              } elsif ($h->{i_lemma} eq '¾e') {
                return ('coord',816,8);
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                return ('coord',177,3);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('coord',44,19);
              } elsif ($h->{i_lemma} eq 'jako') {
                  if ($h->{g_voice} eq 'p') {
                    return ('coord',3,1);
                  } elsif ($h->{g_voice} eq 'a') {
                    return ('coord_ap',24,10);
                  } elsif ($h->{g_voice} eq 'undef') {
                    return ('coord',55,4);
                  }
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('auxy',0,);
                  } elsif ($h->{d_lemma} eq 'nebo') {
                    return ('coord',4,);
                  } elsif ($h->{d_lemma} eq 'ale') {
                    return ('coord',2,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('auxy',363,75);
                  }
              } elsif ($h->{i_lemma} eq 'nebo') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('auxy',0,);
                  } elsif ($h->{d_lemma} eq 'èi') {
                    return ('coord',11,);
                  } elsif ($h->{d_lemma} eq 'ale') {
                    return ('coord',2,);
                  } elsif ($h->{d_lemma} eq 'nebo') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('coord',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('coord',15,4);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('auxy',2,);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{g_case} =~ /^(?:3|5|x)$/) {
                        return ('auxy',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('coord',18,8);
                      } elsif ($h->{g_case} eq '2') {
                        return ('coord',7,1);
                      } elsif ($h->{g_case} eq '4') {
                        return ('auxy',5,2);
                      } elsif ($h->{g_case} eq '6') {
                        return ('coord',2,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('auxy',4,1);
                      } elsif ($h->{g_case} eq 'undef') {
                        return ('auxy',146,47);
                      }
                  }
              }
          } elsif ($h->{i_pos} eq 'nic') {
              if ($h->{g_pos} eq 'n') {
                return ('coord',11622,3902);
              } elsif ($h->{g_pos} eq 'z') {
                return ('coord',10317,75);
              } elsif ($h->{g_pos} eq 'v') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('coord',0,);
                  } elsif ($h->{d_lemma} eq 'v¹ak') {
                    return ('auxy',654,68);
                  } elsif ($h->{d_lemma} eq 'èi') {
                    return ('coord',283,10);
                  } elsif ($h->{d_lemma} eq 'nebo') {
                    return ('coord',584,15);
                  } elsif ($h->{d_lemma} eq 'ale') {
                    return ('coord',733,76);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('coord',7281,1163);
                  }
              } elsif ($h->{g_pos} eq 'c') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{d_lemma} eq 'èi') {
                    return ('coord',4,);
                  } elsif ($h->{d_lemma} eq 'nebo') {
                    return ('coord',3,);
                  } elsif ($h->{d_lemma} eq 'ale') {
                    return ('coord',1,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('auxz',159,58);
                  }
              } elsif ($h->{g_pos} eq 'a') {
                  if ($h->{g_lemma} =~ /^(?:zákon|hodnì|zbo¾í|rok|tento|pøípad|telefon|fax|02|v¹echen|podnik|1994|mít|muset|výroba|kè|firma|a|který|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                    return ('coord',0,);
                  } elsif ($h->{g_lemma} eq 'dal¹í') {
                    return ('auxz',7,2);
                  } elsif ($h->{g_lemma} eq 'dobrý') {
                    return ('coord',4,2);
                  } elsif ($h->{g_lemma} eq 'èeský') {
                    return ('auxz',4,);
                  } elsif ($h->{g_lemma} eq 'zahranièní') {
                    return ('auxz',2,);
                  } elsif ($h->{g_lemma} eq 'nový') {
                    return ('coord',1,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('coord',550,154);
                  } elsif ($h->{g_lemma} eq 'jiný') {
                    return ('auxz',7,);
                  } elsif ($h->{g_lemma} eq 'malý') {
                      if ($h->{g_case} =~ /^(?:3|4|5|7|x|undef)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('coord',3,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('auxz',1,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('auxz',4,);
                      }
                  }
              } elsif ($h->{g_pos} eq 'p') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{d_lemma} eq 'v¹ak') {
                    return ('coord',1,);
                  } elsif ($h->{d_lemma} eq 'èi') {
                    return ('coord',1,);
                  } elsif ($h->{d_lemma} eq 'nebo') {
                    return ('coord',27,);
                  } elsif ($h->{d_lemma} eq 'ale') {
                    return ('coord',7,);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|pøípad|telefon|èeský|zahranièní|malý|fax|02|podnik|nový|1994|mít|muset|výroba|kè|firma|a|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|trh|jít|1|napøíklad|èlovìk|být)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{g_lemma} eq 'tento') {
                        return ('auxz',3,);
                      } elsif ($h->{g_lemma} eq 'v¹echen') {
                        return ('coord',6,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('auxz',114,17);
                      } elsif ($h->{g_lemma} eq 'který') {
                        return ('coord',4,);
                      } elsif ($h->{g_lemma} eq 'nìkterý') {
                        return ('coord_pa',1,);
                      } elsif ($h->{g_lemma} eq 'já') {
                        return ('auxz',57,4);
                      } elsif ($h->{g_lemma} eq 'ten') {
                          if ($h->{g_case} =~ /^(?:5|x|undef)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('auxy',143,82);
                          } elsif ($h->{g_case} eq '2') {
                            return ('coord',30,8);
                          } elsif ($h->{g_case} eq '3') {
                            return ('auxz',23,8);
                          } elsif ($h->{g_case} eq '4') {
                            return ('auxy',222,44);
                          } elsif ($h->{g_case} eq '6') {
                            return ('coord',41,10);
                          } elsif ($h->{g_case} eq '7') {
                            return ('auxz',35,15);
                          }
                      }
                  }
              } elsif ($h->{g_pos} eq 'd') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{g_lemma} eq 'hodnì') {
                    return ('coord',30,8);
                  } elsif ($h->{g_lemma} eq 'napøíklad') {
                    return ('coord_ap',38,4);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{d_lemma} eq 'v¹ak') {
                        return ('auxy',6,1);
                      } elsif ($h->{d_lemma} eq 'ale') {
                        return ('coord',7,4);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('auxz',460,149);
                      } elsif ($h->{d_lemma} eq 'èi') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('coord_ap',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('coord_ap',10,2);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('coord',3,);
                          }
                      } elsif ($h->{d_lemma} eq 'nebo') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('coord',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('coord_ap',12,5);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('coord',5,1);
                          }
                      }
                  }
              }
          } elsif ($h->{i_pos} eq 'z') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|aby|ale|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('coord',0,);
              } elsif ($h->{i_lemma} eq 'spec_dot') {
                return ('coord',3,);
              } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                return ('coord',3,1);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('coord',4,1);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('coord_ap',82,15);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                  if ($h->{g_pos} =~ /^(?:a|c|d)$/) {
                    return ('coord_ap',0,);
                  } elsif ($h->{g_pos} eq 'v') {
                    return ('coord_ap',117,6);
                  } elsif ($h->{g_pos} eq 'n') {
                    return ('coord_ap',23,5);
                  } elsif ($h->{g_pos} eq 'p') {
                    return ('coord_ap',4,1);
                  } elsif ($h->{g_pos} eq 'z') {
                    return ('coord',201,63);
                  }
              } elsif ($h->{i_lemma} eq 'undef') {
                  if ($h->{g_pos} eq 'p') {
                    return ('coord_ap',0,);
                  } elsif ($h->{g_pos} eq 'v') {
                    return ('coord_ap',152,19);
                  } elsif ($h->{g_pos} eq 'n') {
                    return ('coord_ap',50,7);
                  } elsif ($h->{g_pos} eq 'a') {
                    return ('coord_ap',3,1);
                  } elsif ($h->{g_pos} eq 'z') {
                    return ('coord',93,41);
                  } elsif ($h->{g_pos} eq 'c') {
                    return ('coord_ap',1,);
                  } elsif ($h->{g_pos} eq 'd') {
                    return ('coord_ap',2,);
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{g_voice} eq 'p') {
                    return ('coord_ap',10,2);
                  } elsif ($h->{g_voice} eq 'undef') {
                    return ('coord',583,104);
                  } elsif ($h->{g_voice} eq 'a') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('coord',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('coord',150,60);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return evalSubTree1_S1($h); # [S1]
                      }
                  }
              }
          }
      } elsif ($h->{d_subpos} eq 'spec_comma') {
          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
            return ('auxc',0,);
          } elsif ($h->{d_lemma} eq 'aby') {
            return ('auxc',1715,1);
          } elsif ($h->{d_lemma} eq '¾e') {
            return ('auxc',8830,12);
          } elsif ($h->{d_lemma} eq 'kdy¾') {
            return ('auxc',1214,3);
          } elsif ($h->{d_lemma} eq 'jako') {
              if ($h->{g_pos} eq 'n') {
                return ('auxy',1361,161);
              } elsif ($h->{g_pos} eq 'z') {
                return ('auxc',56,6);
              } elsif ($h->{g_pos} eq 'c') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_rbrace|b|c|d|e|f|spec_hash|g|i|j|k|m|n|o|p|2|q|4|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('auxy',0,);
                  } elsif ($h->{g_subpos} eq 'spec_eq') {
                    return ('auxy',1,);
                  } elsif ($h->{g_subpos} eq 'a') {
                    return ('auxc',7,1);
                  } elsif ($h->{g_subpos} eq 'h') {
                    return ('auxy',1,);
                  } elsif ($h->{g_subpos} eq 'l') {
                    return ('auxy',33,1);
                  } elsif ($h->{g_subpos} eq 'r') {
                    return ('auxy',24,);
                  }
              } elsif ($h->{g_pos} eq 'd') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                    return ('auxc',0,);
                  } elsif ($h->{g_lemma} eq 'hodnì') {
                    return ('auxc',2,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('auxc',330,14);
                  } elsif ($h->{g_lemma} eq 'napøíklad') {
                    return ('auxy',19,);
                  }
              } elsif ($h->{g_pos} eq 'v') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('auxc',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('auxc',14,1);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('auxc',3,);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('auxc',6,);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('auxy',85,38);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_case} =~ /^(?:1|2|x)$/) {
                        return ('auxc',0,);
                      } elsif ($h->{i_case} eq '3') {
                        return ('apos',1,);
                      } elsif ($h->{i_case} eq '4') {
                        return ('apos',1,);
                      } elsif ($h->{i_case} eq '6') {
                        return ('apos',2,);
                      } elsif ($h->{i_case} eq 'nic') {
                        return ('auxc',299,23);
                      } elsif ($h->{i_case} eq '7') {
                        return ('apos',1,);
                      } elsif ($h->{i_case} eq 'undef') {
                        return ('auxy',37,18);
                      }
                  }
              } elsif ($h->{g_pos} eq 'p') {
                  if ($h->{i_voice} eq 'undef') {
                    return ('auxy',11,1);
                  } elsif ($h->{i_voice} eq 'nic') {
                      if ($h->{g_case} =~ /^(?:5|x|undef)$/) {
                        return ('auxc',0,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('auxy',5,1);
                      } elsif ($h->{g_case} eq '3') {
                        return ('auxc',2,1);
                      } elsif ($h->{g_case} eq '4') {
                        return ('auxy',24,11);
                      } elsif ($h->{g_case} eq '6') {
                        return ('auxc',5,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('auxc',1,);
                      } elsif ($h->{g_case} eq '1') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y)$/) {
                            return ('auxc',0,);
                          } elsif ($h->{g_subpos} eq 'd') {
                            return ('auxy',14,6);
                          } elsif ($h->{g_subpos} eq 'z') {
                            return ('auxc',6,1);
                          }
                      }
                  }
              } elsif ($h->{g_pos} eq 'a') {
                  if ($h->{i_voice} eq 'undef') {
                    return ('auxy',3,);
                  } elsif ($h->{i_voice} eq 'nic') {
                      if ($h->{g_case} =~ /^(?:5|x)$/) {
                        return ('auxc',0,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('auxc',9,);
                      } elsif ($h->{g_case} eq '3') {
                        return ('auxc',2,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('auxc',13,1);
                      } elsif ($h->{g_case} eq '7') {
                        return ('auxc',17,1);
                      } elsif ($h->{g_case} eq 'undef') {
                        return ('auxc',1,);
                      } elsif ($h->{g_case} eq '1') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|hodnì|zbo¾í|rok|tento|pøípad|telefon|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{g_lemma} eq 'dobrý') {
                            return ('auxc',3,);
                          } elsif ($h->{g_lemma} eq 'èeský') {
                            return ('auxy',1,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('auxy',115,54);
                          }
                      } elsif ($h->{g_case} eq '4') {
                          if ($h->{g_lemma} =~ /^(?:zákon|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                            return ('auxc',0,);
                          } elsif ($h->{g_lemma} eq 'dal¹í') {
                            return ('auxy',1,);
                          } elsif ($h->{g_lemma} eq 'dobrý') {
                            return ('auxy',5,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('auxc',83,35);
                          }
                      }
                  }
              }
          } elsif ($h->{d_lemma} eq 'other') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|x|i)$/) {
                return ('auxc',0,);
              } elsif ($h->{i_subpos} eq 'r') {
                return ('coord',44,4);
              } elsif ($h->{i_subpos} eq 't') {
                return ('auxc',5,1);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('coord',1,);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                return ('auxc',314,91);
              } elsif ($h->{i_subpos} eq 'spec_aster') {
                return ('auxz',1,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|ale|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('auxc',0,);
                  } elsif ($h->{i_lemma} eq 'aby') {
                    return ('auxc',1,);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('auxc',4,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('auxc',7,1);
                  } elsif ($h->{i_lemma} eq '¾e') {
                    return ('auxc',2,);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('auxz',4,);
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{g_pos} =~ /^(?:a|c|d)$/) {
                    return ('auxc',0,);
                  } elsif ($h->{g_pos} eq 'v') {
                    return ('auxc',40,4);
                  } elsif ($h->{g_pos} eq 'n') {
                    return ('auxc',6,2);
                  } elsif ($h->{g_pos} eq 'p') {
                    return ('auxc',4,);
                  } elsif ($h->{g_pos} eq 'z') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('coord',0,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('auxc',3,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('auxc',2,);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('coord',59,21);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{g_pos} eq 'v') {
                    return ('auxc',3783,423);
                  } elsif ($h->{g_pos} eq 'p') {
                    return ('auxc',100,1);
                  } elsif ($h->{g_pos} eq 'a') {
                    return ('auxc',630,15);
                  } elsif ($h->{g_pos} eq 'z') {
                    return ('auxc',174,43);
                  } elsif ($h->{g_pos} eq 'd') {
                    return ('auxc',914,60);
                  } elsif ($h->{g_pos} eq 'c') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_rbrace|b|c|d|e|f|spec_hash|g|h|i|j|k|m|n|o|p|2|q|4|s|5|6|u|7|8|w|z)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{g_subpos} eq 'spec_eq') {
                        return ('auxz',23,1);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('auxc',3,1);
                      } elsif ($h->{g_subpos} eq 'l') {
                        return ('coord',6,2);
                      } elsif ($h->{g_subpos} eq 'r') {
                        return ('auxc',2,1);
                      } elsif ($h->{g_subpos} eq 'v') {
                        return ('auxc',1,);
                      } elsif ($h->{g_subpos} eq 'y') {
                        return ('coord',2,1);
                      }
                  } elsif ($h->{g_pos} eq 'n') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|tento|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|velký|obchodní|podnikatel|k|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('auxc',0,);
                      } elsif ($h->{g_lemma} eq 'rok') {
                        return ('coord',24,6);
                      } elsif ($h->{g_lemma} eq 'pøípad') {
                        return ('auxc',5,1);
                      } elsif ($h->{g_lemma} eq 'koruna') {
                        return ('coord',3,2);
                      } elsif ($h->{g_lemma} eq 'doba') {
                        return ('auxc',18,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_case} =~ /^(?:5|undef)$/) {
                            return ('auxc',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('auxc',106,63);
                          } elsif ($h->{g_case} eq '2') {
                            return ('auxc',82,54);
                          } elsif ($h->{g_case} eq '3') {
                            return ('auxc',13,7);
                          } elsif ($h->{g_case} eq '4') {
                            return ('auxc',124,48);
                          } elsif ($h->{g_case} eq '6') {
                            return ('auxz',38,21);
                          } elsif ($h->{g_case} eq '7') {
                            return ('coord',36,21);
                          } elsif ($h->{g_case} eq 'x') {
                            return ('coord',9,2);
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'z') {
      if ($h->{d_lemma} =~ /^(?:dal¹í|na|dobrý|daò|zbo¾í|aby|tento|pøípad|telefon|èeský|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|rok|ale|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z)$/) {
        return ('auxk',0,);
      } elsif ($h->{d_lemma} eq 'spec_qmark') {
          if ($h->{g_pos} eq 'v') {
            return ('auxk',89,11);
          } elsif ($h->{g_pos} eq 'n') {
            return ('auxg',28,11);
          } elsif ($h->{g_pos} eq 'p') {
            return ('auxg',1,);
          } elsif ($h->{g_pos} eq 'a') {
            return ('auxg',6,2);
          } elsif ($h->{g_pos} eq 'z') {
            return ('auxk',1654,2);
          } elsif ($h->{g_pos} eq 'c') {
            return ('auxg',4,);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxg',4,2);
          }
      } elsif ($h->{d_lemma} eq 'spec_quot') {
          if ($h->{g_pos} eq 'v') {
            return ('auxg',4417,20);
          } elsif ($h->{g_pos} eq 'n') {
            return ('auxg',3067,14);
          } elsif ($h->{g_pos} eq 'p') {
            return ('auxg',47,);
          } elsif ($h->{g_pos} eq 'a') {
            return ('auxg',849,);
          } elsif ($h->{g_pos} eq 'c') {
            return ('auxg',27,);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxg',144,);
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_voice} eq 'nic') {
                return ('exd',22,2);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('auxg',676,3);
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_dot') {
          if ($h->{g_pos} eq 'v') {
            return ('auxg',523,97);
          } elsif ($h->{g_pos} eq 'n') {
            return ('auxg',4136,32);
          } elsif ($h->{g_pos} eq 'p') {
            return ('auxg',30,);
          } elsif ($h->{g_pos} eq 'a') {
            return ('auxg',998,4);
          } elsif ($h->{g_pos} eq 'c') {
            return ('auxg',3266,5);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxg',626,);
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_voice} eq 'nic') {
                return ('auxk',53730,50);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('auxg',107,20);
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_amperastspec_semicol') {
          if ($h->{g_pos} =~ /^(?:p|a)$/) {
            return ('auxg',0,);
          } elsif ($h->{g_pos} eq 'v') {
            return ('auxg',273,);
          } elsif ($h->{g_pos} eq 'c') {
            return ('auxg',16,);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxg',2,);
          } elsif ($h->{g_pos} eq 'n') {
              if ($h->{i_voice} eq 'nic') {
                return ('auxg',35,4);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('atr',5,1);
              }
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_voice} eq 'nic') {
                return ('exd',133,54);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('auxg',104,1);
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_rpar') {
          if ($h->{i_voice} eq 'undef') {
            return ('auxg',2246,143);
          } elsif ($h->{i_voice} eq 'nic') {
              if ($h->{g_pos} eq 'v') {
                return ('auxg',970,218);
              } elsif ($h->{g_pos} eq 'p') {
                return ('auxg',5,);
              } elsif ($h->{g_pos} eq 'z') {
                return ('exd',822,2);
              } elsif ($h->{g_pos} eq 'd') {
                return ('auxg',128,7);
              } elsif ($h->{g_pos} eq 'n') {
                  if ($h->{g_lemma} =~ /^(?:dal¹í|dobrý|hodnì|tento|telefon|èeský|zahranièní|malý|02|v¹echen|nový|1994|mít|muset|výroba|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|jít|1|napøíklad|já|být|ten)$/) {
                    return ('exd',0,);
                  } elsif ($h->{g_lemma} eq 'zákon') {
                    return ('auxg',4,2);
                  } elsif ($h->{g_lemma} eq 'zbo¾í') {
                    return ('auxg',2,);
                  } elsif ($h->{g_lemma} eq 'rok') {
                    return ('exd',4,1);
                  } elsif ($h->{g_lemma} eq 'pøípad') {
                    return ('exd',1,);
                  } elsif ($h->{g_lemma} eq 'fax') {
                    return ('auxg',1,);
                  } elsif ($h->{g_lemma} eq 'podnik') {
                    return ('exd',2,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('exd',1543,299);
                  } elsif ($h->{g_lemma} eq 'kè') {
                    return ('auxg',8,);
                  } elsif ($h->{g_lemma} eq 'firma') {
                    return ('exd',3,);
                  } elsif ($h->{g_lemma} eq 'trh') {
                    return ('exd',2,);
                  } elsif ($h->{g_lemma} eq 'èlovìk') {
                    return ('auxg',2,1);
                  }
              } elsif ($h->{g_pos} eq 'a') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_subpos} eq 'a') {
                    return ('auxg',154,32);
                  } elsif ($h->{g_subpos} eq 'c') {
                    return ('exd',1,);
                  } elsif ($h->{g_subpos} eq 'g') {
                    return ('auxg',4,);
                  } elsif ($h->{g_subpos} eq '2') {
                    return ('auxg',2,);
                  } elsif ($h->{g_subpos} eq 'u') {
                    return ('exd',3,);
                  }
              } elsif ($h->{g_pos} eq 'c') {
                  if ($h->{g_case} =~ /^(?:2|3|5|6|7|x)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('exd',8,3);
                  } elsif ($h->{g_case} eq '4') {
                    return ('exd',3,1);
                  } elsif ($h->{g_case} eq 'undef') {
                    return ('auxg',462,12);
                  }
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_ddot') {
          if ($h->{g_pos} eq 'p') {
            return ('apos',12,4);
          } elsif ($h->{g_pos} eq 'c') {
            return ('auxg',434,10);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxg',36,7);
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_voice} eq 'nic') {
                return ('apos',1997,1396);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('coord',300,160);
              }
          } elsif ($h->{g_pos} eq 'n') {
              if ($h->{i_case} =~ /^(?:1|x)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('auxg',3,1);
              } elsif ($h->{i_case} eq '3') {
                return ('apos',1,);
              } elsif ($h->{i_case} eq '4') {
                return ('coord',8,4);
              } elsif ($h->{i_case} eq '6') {
                return ('auxg',2,);
              } elsif ($h->{i_case} eq '7') {
                return ('apos',1,);
              } elsif ($h->{i_case} eq 'undef') {
                return ('auxg',216,67);
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{g_case} eq 'undef') {
                    return ('coord',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('auxg',198,74);
                  } elsif ($h->{g_case} eq '2') {
                    return ('coord',37,18);
                  } elsif ($h->{g_case} eq '3') {
                    return ('coord',6,2);
                  } elsif ($h->{g_case} eq '4') {
                    return ('coord',46,28);
                  } elsif ($h->{g_case} eq '5') {
                    return ('auxg',1,);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord',50,18);
                  } elsif ($h->{g_case} eq '7') {
                    return ('coord',36,11);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('auxg',24,4);
                  }
              }
          } elsif ($h->{g_pos} eq 'a') {
              if ($h->{g_case} =~ /^(?:5|6|7|undef)$/) {
                return ('auxg',0,);
              } elsif ($h->{g_case} eq '2') {
                return ('apos',1,);
              } elsif ($h->{g_case} eq '3') {
                return ('auxg',1,);
              } elsif ($h->{g_case} eq '4') {
                return ('coord_pa',2,1);
              } elsif ($h->{g_case} eq 'x') {
                return ('auxg',1,);
              } elsif ($h->{g_case} eq '1') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('exd',10,4);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('apos',4,2);
                  }
              }
          } elsif ($h->{g_pos} eq 'v') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|x|spec_aster)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('auxg',20,11);
              } elsif ($h->{i_subpos} eq 't') {
                return ('auxg',2,);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('coord',4,);
              } elsif ($h->{i_subpos} eq 'i') {
                return ('auxg',1,);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                return ('auxg',90,8);
              } elsif ($h->{i_subpos} eq 'r') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('coord',0,);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('apos',1,);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('apos',2,1);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{g_voice} eq 'p') {
                        return ('coord',1,);
                      } elsif ($h->{g_voice} eq 'a') {
                        return ('coord',64,14);
                      } elsif ($h->{g_voice} eq 'undef') {
                        return ('apos',11,4);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('auxg',2,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('auxg',2,);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('coord_ap',11,2);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                        return ('auxg',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('auxg',20,);
                      } elsif ($h->{g_subpos} eq 'f') {
                        return ('auxg',3,);
                      } elsif ($h->{g_subpos} eq 'i') {
                        return ('auxg',4,);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('coord',93,42);
                      } elsif ($h->{g_subpos} eq 's') {
                        return ('auxg',1,);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('auxg',484,193);
                  } elsif ($h->{g_subpos} eq 'f') {
                    return ('auxg',50,24);
                  } elsif ($h->{g_subpos} eq 'i') {
                    return ('auxg',18,5);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('auxg',26,11);
                  } elsif ($h->{g_subpos} eq 'p') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('coord',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('auxg',17,4);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('auxg',2,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('coord',322,190);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('auxg',2,);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('auxg',31,18);
                      }
                  }
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_amperpercntspec_semicol') {
          if ($h->{g_voice} eq 'p') {
            return ('adv',10,1);
          } elsif ($h->{g_voice} eq 'undef') {
              if ($h->{g_pos} eq 'n') {
                return ('atr',57,3);
              } elsif ($h->{g_pos} eq 'p') {
                return ('atr',1,);
              } elsif ($h->{g_pos} eq 'c') {
                return ('atr',537,43);
              } elsif ($h->{g_pos} eq 'd') {
                return ('atr',10,2);
              } elsif ($h->{g_pos} eq 'v') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('obj',2,);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('atr',6,1);
                  }
              } elsif ($h->{g_pos} eq 'a') {
                  if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_pos} eq 'nic') {
                    return ('obj',1,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('atr',2,);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('auxg',2,1);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('adv',2,);
                  }
              } elsif ($h->{g_pos} eq 'z') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('atr',6,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('exd',12,2);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('exd',5,1);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('exd',3,1);
                  }
              }
          } elsif ($h->{g_voice} eq 'a') {
              if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                return ('adv',0,);
              } elsif ($h->{i_pos} eq 'z') {
                return ('atr',8,);
              } elsif ($h->{i_pos} eq 'r') {
                return ('adv',35,10);
              } elsif ($h->{i_pos} eq 'nic') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('sb',7,4);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('adv',3,1);
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('atr',4,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('exd',3,1);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('obj',2,);
                      }
                  }
              }
          }
      } elsif ($h->{d_lemma} eq 'undef') {
          if ($h->{g_pos} eq 'p') {
            return ('auxg',42,10);
          } elsif ($h->{g_pos} eq 'a') {
            return ('auxg',330,36);
          } elsif ($h->{g_pos} eq 'd') {
            return ('auxg',209,13);
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|aby|spec_amperpercntspec_semicol|po|za|od|pro|mezi|k|pøi|kdy¾|o|s|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('coord',161,103);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('auxg',6,1);
              } elsif ($h->{i_lemma} eq 'spec_dot') {
                return ('pred',2,);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('auxg',17,9);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('auxg',68,30);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('auxg',2,);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('auxg',178,37);
              } elsif ($h->{i_lemma} eq '¾e') {
                return ('apos',1,);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('auxk',2578,725);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('coord_ap',2,1);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('coord',162,51);
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                return ('coord',22,12);
              }
          } elsif ($h->{g_pos} eq 'c') {
              if ($h->{i_pos} =~ /^(?:x|i|z|t)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('auxg',265,79);
              } elsif ($h->{i_pos} eq 'j') {
                return ('coord',2,1);
              } elsif ($h->{i_pos} eq 'r') {
                return ('apos',2,);
              }
          } elsif ($h->{g_pos} eq 'v') {
              if ($h->{i_voice} eq 'undef') {
                return ('auxg',1364,202);
              } elsif ($h->{i_voice} eq 'nic') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                    return ('apos',0,);
                  } elsif ($h->{g_subpos} eq 'e') {
                    return ('auxg',6,);
                  } elsif ($h->{g_subpos} eq 'f') {
                    return ('apos',81,44);
                  } elsif ($h->{g_subpos} eq 'i') {
                    return ('auxg',22,4);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('apos',361,177);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('auxg',46,24);
                  } elsif ($h->{g_subpos} eq 'b') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('apos',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('apos',48,21);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('auxg',6,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('apos',360,197);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('auxg',9,3);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('auxg',154,82);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'n') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|po|za|od|pro|mezi|k|pøi|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('auxg',6,3);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('auxg',9,1);
              } elsif ($h->{i_lemma} eq 'spec_dot') {
                return ('auxg',1,);
              } elsif ($h->{i_lemma} eq 'aby') {
                return ('auxg',2,);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('auxg',4,);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('auxg',80,1);
              } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                return ('coord',2,);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('auxg',3,);
              } elsif ($h->{i_lemma} eq '¾e') {
                return ('apos',5,2);
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                return ('auxg',1,);
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{g_case} eq 'undef') {
                    return ('auxg',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('auxg',601,285);
                  } elsif ($h->{g_case} eq '2') {
                    return ('coord',317,114);
                  } elsif ($h->{g_case} eq '3') {
                    return ('coord',33,16);
                  } elsif ($h->{g_case} eq '4') {
                    return ('coord',143,79);
                  } elsif ($h->{g_case} eq '5') {
                    return ('auxg',2,);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord',240,83);
                  } elsif ($h->{g_case} eq '7') {
                    return ('coord',87,49);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('auxg',220,67);
                  }
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                  if ($h->{g_case} =~ /^(?:5|7|x|undef)$/) {
                    return ('apos_ap',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('coord_ap',2,);
                  } elsif ($h->{g_case} eq '2') {
                    return ('apos_ap',1,);
                  } elsif ($h->{g_case} eq '3') {
                    return ('apos_ap',1,);
                  } elsif ($h->{g_case} eq '4') {
                    return ('apos_ap',2,);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord_ap',2,);
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{g_case} =~ /^(?:5|undef)$/) {
                    return ('coord',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('coord',34,8);
                  } elsif ($h->{g_case} eq '2') {
                    return ('auxg',19,4);
                  } elsif ($h->{g_case} eq '3') {
                    return ('auxg',2,);
                  } elsif ($h->{g_case} eq '4') {
                    return ('auxg',31,10);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord',6,3);
                  } elsif ($h->{g_case} eq '7') {
                    return ('coord',4,2);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('coord',12,1);
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_case} eq 'nic') {
                    return ('auxg',0,);
                  } elsif ($h->{i_case} eq '1') {
                    return ('auxg',1,);
                  } elsif ($h->{i_case} eq '2') {
                    return ('auxg',31,12);
                  } elsif ($h->{i_case} eq '3') {
                    return ('apos',4,);
                  } elsif ($h->{i_case} eq '4') {
                    return ('coord',19,12);
                  } elsif ($h->{i_case} eq '7') {
                    return ('apos',9,3);
                  } elsif ($h->{i_case} eq 'x') {
                    return ('auxg',1,);
                  } elsif ($h->{i_case} eq 'undef') {
                    return ('auxg',176,61);
                  } elsif ($h->{i_case} eq '6') {
                      if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                        return ('coord',0,);
                      } elsif ($h->{i_subpos} eq 'r') {
                        return ('apos',15,9);
                      } elsif ($h->{i_subpos} eq 'v') {
                        return ('coord',8,2);
                      }
                  }
              }
          }
      } elsif ($h->{d_lemma} eq 'other') {
          if ($h->{g_pos} eq 'p') {
            return ('auxg',3,);
          } elsif ($h->{g_pos} eq 'a') {
            return ('auxg',61,5);
          } elsif ($h->{g_pos} eq 'c') {
            return ('auxg',252,32);
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('auxg',8,4);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('auxk',1,);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('coord_ap',7,4);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('auxg',25,11);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('auxk',852,139);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('coord',12,5);
              }
          } elsif ($h->{g_pos} eq 'd') {
              if ($h->{i_voice} eq 'nic') {
                return ('auxg',9,);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('coord',3,1);
              }
          } elsif ($h->{g_pos} eq 'n') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|nový|1994|mít|muset|a|který|jiný|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|být|ten)$/) {
                return ('auxg',0,);
              } elsif ($h->{g_lemma} eq 'rok') {
                return ('coord',8,);
              } elsif ($h->{g_lemma} eq 'podnik') {
                return ('coord_pa',1,);
              } elsif ($h->{g_lemma} eq 'výroba') {
                return ('auxg',1,);
              } elsif ($h->{g_lemma} eq 'kè') {
                return ('auxp',3,1);
              } elsif ($h->{g_lemma} eq 'firma') {
                return ('coord',8,2);
              } elsif ($h->{g_lemma} eq 'koruna') {
                return ('auxg',1,);
              } elsif ($h->{g_lemma} eq 'èlovìk') {
                return ('auxg',1,);
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|spec_amperpercntspec_semicol|po|za|jako|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('coord',2,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('coord',4,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('auxg',50,15);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('auxg',462,183);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('coord_ap',4,1);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('coord',12,3);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('apos',1,);
                  }
              }
          } elsif ($h->{g_pos} eq 'v') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|spec_amperpercntspec_semicol|po|za|jako|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('auxg',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('auxg',2,1);
              } elsif ($h->{i_lemma} eq 'aby') {
                return ('sb',1,);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('obj',3,1);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('coord_ap',2,1);
              } elsif ($h->{i_lemma} eq '¾e') {
                return ('auxg',2,);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('auxg',137,75);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('coord_ap',5,1);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('coord',1,);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('coord',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('coord',6,2);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('auxk',2,);
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('coord_ap',1,);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('exd',5,3);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{g_voice} eq 'p') {
                        return ('auxg',1,);
                      } elsif ($h->{g_voice} eq 'a') {
                        return ('auxg',27,11);
                      } elsif ($h->{g_voice} eq 'undef') {
                        return ('pred',3,1);
                      }
                  }
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_lpar') {
          if ($h->{i_voice} eq 'undef') {
            return ('auxg',1492,476);
          } elsif ($h->{i_voice} eq 'nic') {
              if ($h->{g_pos} eq 'z') {
                return ('exd',821,15);
              } elsif ($h->{g_pos} eq 'd') {
                return ('auxg',137,11);
              } elsif ($h->{g_pos} eq 'v') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|spec_hash|g|h|j|k|l|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('auxg',650,276);
                  } elsif ($h->{g_subpos} eq 'e') {
                    return ('auxg',1,);
                  } elsif ($h->{g_subpos} eq 'f') {
                    return ('apos',43,15);
                  } elsif ($h->{g_subpos} eq 'i') {
                    return ('auxg',88,5);
                  } elsif ($h->{g_subpos} eq 'm') {
                    return ('exd',1,);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('auxg',416,205);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('auxg',66,32);
                  }
              } elsif ($h->{g_pos} eq 'p') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_subpos} eq 'd') {
                    return ('apos',5,2);
                  } elsif ($h->{g_subpos} eq 'z') {
                    return ('auxg',2,);
                  }
              } elsif ($h->{g_pos} eq 'a') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_subpos} eq 'a') {
                    return ('auxg',156,51);
                  } elsif ($h->{g_subpos} eq 'c') {
                    return ('exd',1,);
                  } elsif ($h->{g_subpos} eq 'g') {
                    return ('apos',9,3);
                  } elsif ($h->{g_subpos} eq '2') {
                    return ('auxg',2,);
                  } elsif ($h->{g_subpos} eq 'u') {
                    return ('exd',3,);
                  }
              } elsif ($h->{g_pos} eq 'c') {
                  if ($h->{g_case} =~ /^(?:2|3|5|6|7|x)$/) {
                    return ('auxg',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('exd',8,3);
                  } elsif ($h->{g_case} eq '4') {
                    return ('exd',3,1);
                  } elsif ($h->{g_case} eq 'undef') {
                    return ('auxg',432,14);
                  }
              } elsif ($h->{g_pos} eq 'n') {
                  if ($h->{g_lemma} =~ /^(?:dal¹í|dobrý|hodnì|zbo¾í|tento|telefon|èeský|zahranièní|malý|02|v¹echen|nový|1994|mít|muset|a|který|jiný|velký|obchodní|podnikatel|k|doba|první|nìkterý|jít|1|napøíklad|já|být|ten)$/) {
                    return ('exd',0,);
                  } elsif ($h->{g_lemma} eq 'zákon') {
                    return ('exd',5,2);
                  } elsif ($h->{g_lemma} eq 'rok') {
                    return ('exd',4,1);
                  } elsif ($h->{g_lemma} eq 'pøípad') {
                    return ('apos',1,);
                  } elsif ($h->{g_lemma} eq 'fax') {
                    return ('auxg',1,);
                  } elsif ($h->{g_lemma} eq 'výroba') {
                    return ('apos',1,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('exd',1851,583);
                  } elsif ($h->{g_lemma} eq 'kè') {
                    return ('auxg',9,);
                  } elsif ($h->{g_lemma} eq 'firma') {
                    return ('exd',5,2);
                  } elsif ($h->{g_lemma} eq 'koruna') {
                    return ('exd',1,);
                  } elsif ($h->{g_lemma} eq 'trh') {
                    return ('exd',2,);
                  } elsif ($h->{g_lemma} eq 'èlovìk') {
                    return ('exd',2,);
                  } elsif ($h->{g_lemma} eq 'podnik') {
                      if ($h->{g_case} =~ /^(?:2|3|4|5|7|x|undef)$/) {
                        return ('apos',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('apos',2,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('exd',2,);
                      }
                  }
              }
          }
      } elsif ($h->{d_lemma} eq 'spec_comma') {
          if ($h->{i_case} eq 'x') {
            return ('auxx',0,);
          } elsif ($h->{i_case} eq '2') {
            return ('auxx',324,72);
          } elsif ($h->{i_case} eq '3') {
            return ('auxx',70,16);
          } elsif ($h->{i_case} eq '6') {
            return ('auxx',293,89);
          } elsif ($h->{i_case} eq '7') {
            return ('auxx',186,60);
          } elsif ($h->{i_case} eq '1') {
              if ($h->{g_voice} eq 'p') {
                return ('coord',0,);
              } elsif ($h->{g_voice} eq 'a') {
                return ('auxx',2,);
              } elsif ($h->{g_voice} eq 'undef') {
                return ('coord',2,);
              }
          } elsif ($h->{i_case} eq '4') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('auxx',0,);
              } elsif ($h->{g_lemma} eq 'dobrý') {
                return ('coord',1,);
              } elsif ($h->{g_lemma} eq 'v¹echen') {
                return ('auxx',1,);
              } elsif ($h->{g_lemma} eq 'mít') {
                return ('auxx',4,);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('auxx',1,);
              } elsif ($h->{g_lemma} eq 'jít') {
                return ('coord',10,3);
              } elsif ($h->{g_lemma} eq 'být') {
                return ('auxx',15,5);
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{g_pos} =~ /^(?:p|c)$/) {
                    return ('auxx',0,);
                  } elsif ($h->{g_pos} eq 'v') {
                    return ('auxx',117,33);
                  } elsif ($h->{g_pos} eq 'n') {
                    return ('auxx',55,31);
                  } elsif ($h->{g_pos} eq 'a') {
                    return ('coord',8,2);
                  } elsif ($h->{g_pos} eq 'z') {
                    return ('coord',12,3);
                  } elsif ($h->{g_pos} eq 'd') {
                    return ('coord',1,);
                  }
              }
          } elsif ($h->{i_case} eq 'nic') {
              if ($h->{g_pos} eq 'v') {
                return ('auxx',19794,2125);
              } elsif ($h->{g_pos} eq 'a') {
                return ('auxx',1695,55);
              } elsif ($h->{g_pos} eq 'z') {
                return ('coord',3689,506);
              } elsif ($h->{g_pos} eq 'd') {
                return ('auxx',1407,44);
              } elsif ($h->{g_pos} eq 'n') {
                  if ($h->{g_case} eq 'undef') {
                    return ('auxx',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('auxx',1059,510);
                  } elsif ($h->{g_case} eq '2') {
                    return ('coord',433,255);
                  } elsif ($h->{g_case} eq '3') {
                    return ('coord',73,50);
                  } elsif ($h->{g_case} eq '4') {
                    return ('coord',379,148);
                  } elsif ($h->{g_case} eq '5') {
                    return ('auxx',21,);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord',159,78);
                  } elsif ($h->{g_case} eq '7') {
                    return ('coord',203,109);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('auxx',417,70);
                  }
              } elsif ($h->{g_pos} eq 'p') {
                  if ($h->{g_case} =~ /^(?:5|x|undef)$/) {
                    return ('auxx',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('auxx',36,8);
                  } elsif ($h->{g_case} eq '2') {
                    return ('coord',10,6);
                  } elsif ($h->{g_case} eq '3') {
                    return ('auxx',12,3);
                  } elsif ($h->{g_case} eq '4') {
                    return ('auxx',36,15);
                  } elsif ($h->{g_case} eq '6') {
                    return ('coord',11,);
                  } elsif ($h->{g_case} eq '7') {
                    return ('auxx',18,8);
                  }
              } elsif ($h->{g_pos} eq 'c') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|v¹echen|podnik|nový|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|nìkterý|trh|jít|napøíklad|já|èlovìk|být|ten)$/) {
                    return ('auxx',0,);
                  } elsif ($h->{g_lemma} eq '02') {
                    return ('coord',41,);
                  } elsif ($h->{g_lemma} eq '1994') {
                    return ('auxx',5,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('auxx',519,48);
                  } elsif ($h->{g_lemma} eq 'první') {
                    return ('auxx',1,);
                  } elsif ($h->{g_lemma} eq '1') {
                    return ('auxx',3,);
                  }
              }
          } elsif ($h->{i_case} eq 'undef') {
              if ($h->{i_pos} eq 'nic') {
                return ('auxx',0,);
              } elsif ($h->{i_pos} eq 'x') {
                return ('auxx',1,);
              } elsif ($h->{i_pos} eq 'i') {
                return ('auxx',9,);
              } elsif ($h->{i_pos} eq 'j') {
                return ('auxx',28459,751);
              } elsif ($h->{i_pos} eq 'r') {
                return ('auxx',2,);
              } elsif ($h->{i_pos} eq 't') {
                return ('auxx',601,4);
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('auxx',0,);
                  } elsif ($h->{i_lemma} eq 'spec_dot') {
                    return ('auxx',26,2);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('coord_ap',73,11);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('auxx',3587,261);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                      if ($h->{g_pos} =~ /^(?:c|d)$/) {
                        return ('coord_ap',0,);
                      } elsif ($h->{g_pos} eq 'v') {
                        return ('coord_ap',49,10);
                      } elsif ($h->{g_pos} eq 'n') {
                        return ('coord_ap',15,7);
                      } elsif ($h->{g_pos} eq 'p') {
                        return ('coord_ap',2,1);
                      } elsif ($h->{g_pos} eq 'a') {
                        return ('coord_ap',1,);
                      } elsif ($h->{g_pos} eq 'z') {
                        return ('coord',299,169);
                      }
                  } elsif ($h->{i_lemma} eq 'undef') {
                      if ($h->{g_pos} eq 'd') {
                        return ('auxx',0,);
                      } elsif ($h->{g_pos} eq 'v') {
                        return ('coord_ap',62,27);
                      } elsif ($h->{g_pos} eq 'n') {
                        return ('auxx',54,11);
                      } elsif ($h->{g_pos} eq 'p') {
                        return ('auxx',5,2);
                      } elsif ($h->{g_pos} eq 'a') {
                        return ('coord_ap',1,);
                      } elsif ($h->{g_pos} eq 'z') {
                        return ('coord',94,53);
                      } elsif ($h->{g_pos} eq 'c') {
                        return ('auxx',6,);
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{g_case} =~ /^(?:2|3|5|7)$/) {
                        return ('auxx',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('auxx',43,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('coord',9,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('auxx',2,);
                      } elsif ($h->{g_case} eq 'x') {
                        return ('auxx',8,1);
                      } elsif ($h->{g_case} eq 'undef') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('auxx',0,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                            return ('coord',2,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('auxx',8,);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('auxx',2,);
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 't') {
      if ($h->{g_voice} eq 'p') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
            return ('auxy',0,);
          } elsif ($h->{i_lemma} eq 'ale') {
            return ('auxy',1,);
          } elsif ($h->{i_lemma} eq 'other') {
            return ('auxz',4,);
          } elsif ($h->{i_lemma} eq 'nic') {
            return ('auxy',35,21);
          } elsif ($h->{i_lemma} eq 'kdy¾') {
            return ('auxz',1,);
          }
      } elsif ($h->{g_voice} eq 'undef') {
          if ($h->{i_case} =~ /^(?:1|3|7|x)$/) {
            return ('auxz',0,);
          } elsif ($h->{i_case} eq '2') {
            return ('atr',5,1);
          } elsif ($h->{i_case} eq '4') {
            return ('atr',6,3);
          } elsif ($h->{i_case} eq '6') {
            return ('atr',4,2);
          } elsif ($h->{i_case} eq 'nic') {
              if ($h->{g_pos} eq 'n') {
                return ('auxz',2163,162);
              } elsif ($h->{g_pos} eq 'p') {
                return ('auxz',157,8);
              } elsif ($h->{g_pos} eq 'a') {
                return ('auxz',196,27);
              } elsif ($h->{g_pos} eq 'z') {
                return ('exd',116,54);
              } elsif ($h->{g_pos} eq 'c') {
                return ('auxz',720,19);
              } elsif ($h->{g_pos} eq 'd') {
                return ('auxz',513,106);
              } elsif ($h->{g_pos} eq 'v') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('auxc',6,2);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('auxc',8,2);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('auxz',150,72);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('auxc',1,);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('pnom',3,2);
                  }
              }
          } elsif ($h->{i_case} eq 'undef') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|e|h|j|k|l|m|o|p|2|q|4|r|s|6|u|7|8|v|w|y|z)$/) {
                return ('exd',0,);
              } elsif ($h->{g_subpos} eq 'a') {
                return ('auxz',9,3);
              } elsif ($h->{g_subpos} eq 'b') {
                return ('exd',5,1);
              } elsif ($h->{g_subpos} eq 'c') {
                return ('auxz',1,);
              } elsif ($h->{g_subpos} eq 'd') {
                return ('exd',13,3);
              } elsif ($h->{g_subpos} eq 'spec_hash') {
                return ('exd',208,72);
              } elsif ($h->{g_subpos} eq 'g') {
                return ('auxz',5,2);
              } elsif ($h->{g_subpos} eq 'i') {
                return ('exd_pa',1,);
              } elsif ($h->{g_subpos} eq '5') {
                return ('auxz',2,);
              } elsif ($h->{g_subpos} eq 'f') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|po|za|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'aby') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('auxy',8,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('auxz',2,);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('exd',2,1);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('auxz',14,5);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('auxc',2,);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('exd',4,1);
                  }
              } elsif ($h->{g_subpos} eq 'n') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('atr',7,3);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('auxz',4,2);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('auxz',2,);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('exd_pa',1,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('atr',8,5);
                  } elsif ($h->{i_lemma} eq 'v¹ak') {
                    return ('auxy',1,);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('exd',2,1);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|z|r)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('auxz',27,9);
                      } elsif ($h->{i_pos} eq 't') {
                        return ('atr',3,2);
                      }
                  }
              }
          }
      } elsif ($h->{g_voice} eq 'a') {
          if ($h->{i_case} =~ /^(?:1|7|x)$/) {
            return ('auxy',0,);
          } elsif ($h->{i_case} eq '2') {
            return ('adv',2,1);
          } elsif ($h->{i_case} eq '3') {
            return ('obj',1,);
          } elsif ($h->{i_case} eq '6') {
            return ('adv',3,1);
          } elsif ($h->{i_case} eq '4') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('obj',0,);
              } elsif ($h->{g_subpos} eq 'b') {
                return ('auxz',3,1);
              } elsif ($h->{g_subpos} eq 'p') {
                return ('adv',2,1);
              }
          } elsif ($h->{i_case} eq 'nic') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('auxy',0,);
              } elsif ($h->{g_subpos} eq 'p') {
                return ('auxy',383,165);
              } elsif ($h->{g_subpos} eq 'b') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('auxc',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('auxy',47,20);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('auxc',28,6);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('auxc',597,350);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('auxy',28,9);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('auxy',250,140);
                  }
              }
          } elsif ($h->{i_case} eq 'undef') {
              if ($h->{i_pos} =~ /^(?:nic|x|i|r)$/) {
                return ('auxz',0,);
              } elsif ($h->{i_pos} eq 't') {
                return ('auxy',16,3);
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('auxz',4,2);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('auxz',5,1);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',2,1);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('exd',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('auxc',20,11);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('exd',12,6);
                      }
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',31,14);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('auxc',15,8);
                      } elsif ($h->{i_lemma} eq 'ale') {
                        return ('auxy',22,7);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('auxz',99,44);
                      } elsif ($h->{i_lemma} eq 'èi') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                            return ('exd',1,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('auxc',3,1);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('auxy',4,1);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('auxz',1,);
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'a') {
      if ($h->{g_voice} eq 'p') {
          if ($h->{i_subpos} =~ /^(?:spec_at|t|f|v|x|i|spec_aster)$/) {
            return ('obj',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('adv',3,1);
          } elsif ($h->{i_subpos} eq 'spec_head') {
            return ('atr',31,7);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                return ('sb_ap',0,);
              } elsif ($h->{d_subpos} eq 'a') {
                return ('sb_ap',5,3);
              } elsif ($h->{d_subpos} eq 'g') {
                return ('atr',2,);
              }
          } elsif ($h->{i_subpos} eq 'nic') {
              if ($h->{d_case} =~ /^(?:5|6|undef)$/) {
                return ('sb',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb',30,10);
              } elsif ($h->{d_case} eq '2') {
                return ('exd',1,);
              } elsif ($h->{d_case} eq '3') {
                return ('obj',7,1);
              } elsif ($h->{d_case} eq '4') {
                return ('atr',1,);
              } elsif ($h->{d_case} eq '7') {
                return ('obj',10,1);
              } elsif ($h->{d_case} eq 'x') {
                return ('sb',1,);
              }
          } elsif ($h->{i_subpos} eq 'r') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                return ('obj',0,);
              } elsif ($h->{d_lemma} eq 'dobrý') {
                return ('obj',1,);
              } elsif ($h->{d_lemma} eq 'èeský') {
                return ('exd',1,);
              } elsif ($h->{d_lemma} eq 'jiný') {
                return ('adv',6,);
              } elsif ($h->{d_lemma} eq 'other') {
                  if ($h->{i_case} =~ /^(?:1|2|3|nic|x|undef)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_case} eq '4') {
                    return ('obj',29,6);
                  } elsif ($h->{i_case} eq '6') {
                    return ('exd',4,1);
                  } elsif ($h->{i_case} eq '7') {
                    return ('obj',2,);
                  }
              }
          }
      } elsif ($h->{g_voice} eq 'a') {
          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
            return ('pnom',0,);
          } elsif ($h->{g_lemma} eq 'jít') {
              if ($h->{i_pos} =~ /^(?:x|i|z|t)$/) {
                return ('adv',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('sb',5,);
              } elsif ($h->{i_pos} eq 'j') {
                return ('obj',3,2);
              } elsif ($h->{i_pos} eq 'r') {
                return ('adv',14,6);
              }
          } elsif ($h->{g_lemma} eq 'muset') {
              if ($h->{i_case} =~ /^(?:1|3|4|7|x)$/) {
                return ('atr',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('adv',2,);
              } elsif ($h->{i_case} eq '6') {
                return ('exd',1,);
              } elsif ($h->{i_case} eq 'nic') {
                return ('sb',18,);
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('atr',5,1);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('sb_ap',3,1);
                  }
              }
          } elsif ($h->{g_lemma} eq 'mít') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|¾e|od|spec_lpar|pro|mezi|k|pøi|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('sb',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('atv',1,);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('atr',3,1);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('sb_ap',4,1);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('exd',1,);
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                return ('exd_pa',1,);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('exd_ap',1,);
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|nic|f|x|i|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'r') {
                    return ('adv',34,10);
                  } elsif ($h->{i_subpos} eq 't') {
                    return ('atr',3,1);
                  } elsif ($h->{i_subpos} eq 'v') {
                    return ('exd',3,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('atr',29,14);
                  }
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{d_case} =~ /^(?:2|3|5|6|7|x)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('atvv',6,3);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('atvv',25,10);
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_lemma} eq 'dal¹í') {
                        return ('exd',2,);
                      } elsif ($h->{d_lemma} eq 'velký') {
                        return ('sb',2,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('sb',71,7);
                      } elsif ($h->{d_lemma} eq 'jiný') {
                        return ('exd',1,);
                      }
                  }
              }
          } elsif ($h->{g_lemma} eq 'být') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|x|i|spec_aster)$/) {
                return ('pnom',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',12,6);
              } elsif ($h->{i_subpos} eq 't') {
                return ('atr',5,2);
              } elsif ($h->{i_subpos} eq 'nic') {
                return ('pnom',6341,102);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('exd',3,);
              } elsif ($h->{i_subpos} eq 'r') {
                  if ($h->{i_case} =~ /^(?:1|nic|undef)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_case} eq '2') {
                    return ('exd',23,9);
                  } elsif ($h->{i_case} eq '3') {
                    return ('adv',3,1);
                  } elsif ($h->{i_case} eq '4') {
                    return ('adv',24,7);
                  } elsif ($h->{i_case} eq '6') {
                    return ('adv',11,3);
                  } elsif ($h->{i_case} eq '7') {
                    return ('adv',9,4);
                  } elsif ($h->{i_case} eq 'x') {
                    return ('atr',1,);
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('pnom_ap',16,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('pnom_ap',7,2);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('pnom',132,29);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('pnom_ap',0,);
                      } elsif ($h->{d_subpos} eq 'a') {
                        return ('pnom_ap',18,4);
                      } elsif ($h->{d_subpos} eq 'g') {
                        return ('atr',3,);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{d_case} eq '5') {
                    return ('pnom',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('pnom',493,64);
                  } elsif ($h->{d_case} eq '3') {
                    return ('obj',3,1);
                  } elsif ($h->{d_case} eq '4') {
                    return ('pnom',2,1);
                  } elsif ($h->{d_case} eq '6') {
                    return ('atr',5,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('sb',3,1);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('pnom',3,);
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('exd',3,1);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('atr',5,2);
                      }
                  } elsif ($h->{d_case} eq '7') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('pnom',0,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('pnom',5,1);
                      } elsif ($h->{i_lemma} eq 'èi') {
                        return ('exd',4,2);
                      }
                  }
              }
          } elsif ($h->{g_lemma} eq 'other') {
              if ($h->{i_pos} eq 'x') {
                return ('obj',0,);
              } elsif ($h->{i_pos} eq 'i') {
                return ('atr',2,);
              } elsif ($h->{i_pos} eq 't') {
                return ('atr',7,1);
              } elsif ($h->{i_pos} eq 'nic') {
                  if ($h->{d_case} eq '5') {
                    return ('sb',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('sb',723,276);
                  } elsif ($h->{d_case} eq '2') {
                    return ('obj',10,5);
                  } elsif ($h->{d_case} eq '3') {
                    return ('obj',72,12);
                  } elsif ($h->{d_case} eq '6') {
                    return ('exd_pa',2,1);
                  } elsif ($h->{d_case} eq '7') {
                    return ('obj',70,9);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('sb',26,10);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|na|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_lemma} eq 'dal¹í') {
                        return ('obj',11,6);
                      } elsif ($h->{d_lemma} eq 'dobrý') {
                        return ('obj',2,1);
                      } elsif ($h->{d_lemma} eq 'èeský') {
                        return ('exd',1,);
                      } elsif ($h->{d_lemma} eq 'velký') {
                        return ('exd',3,1);
                      } elsif ($h->{d_lemma} eq 'nový') {
                        return ('exd',2,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('obj',96,27);
                      } elsif ($h->{d_lemma} eq 'jiný') {
                        return ('exd',4,1);
                      }
                  } elsif ($h->{d_case} eq 'undef') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|d|e|f|g|h|i|j|k|spec_aster|l|m|n|spec_comma|1|p|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('atvv',0,);
                      } elsif ($h->{d_subpos} eq 'c') {
                        return ('atvv',107,31);
                      } elsif ($h->{d_subpos} eq 'o') {
                        return ('obj',2,1);
                      } elsif ($h->{d_subpos} eq '2') {
                        return ('obj',3,1);
                      }
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('atr',11,6);
                      } elsif ($h->{i_lemma} eq 'ale') {
                        return ('exd',12,6);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('atr',386,206);
                      } elsif ($h->{i_lemma} eq 'v¹ak') {
                        return ('exd',1,);
                      } elsif ($h->{i_lemma} eq 'èi') {
                        return ('atr',21,4);
                      }
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('exd',0,);
                      } elsif ($h->{d_subpos} eq 'a') {
                        return ('exd',21,7);
                      } elsif ($h->{d_subpos} eq 'c') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('adv',8,3);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('obj',7,2);
                          }
                      }
                  }
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('atr',16,7);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',2,);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('atr',24,12);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj_ap',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('obj_ap',4,1);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('atr',2,);
                      }
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                      if ($h->{d_case} =~ /^(?:3|6)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('exd_ap',1,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('obj',11,6);
                      } elsif ($h->{d_case} eq '5') {
                        return ('exd',1,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('adv_ap',3,2);
                      } elsif ($h->{d_case} eq 'x') {
                        return ('sb_ap',6,3);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('exd',3,1);
                      } elsif ($h->{d_case} eq '1') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('sb_ap',0,);
                          } elsif ($h->{d_lemma} eq 'dobrý') {
                            return ('exd',1,);
                          } elsif ($h->{d_lemma} eq 'velký') {
                            return ('sb_ap',1,);
                          } elsif ($h->{d_lemma} eq 'jiný') {
                            return ('exd',3,1);
                          } elsif ($h->{d_lemma} eq 'other') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('sb_ap',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj',24,17);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('sb_ap',16,11);
                              }
                          }
                      }
                  }
              } elsif ($h->{i_pos} eq 'r') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|na|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|spec_amperpercntspec_semicol|02|podnik|za|mít|kè|¾e|koruna|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_lemma} eq 'dal¹í') {
                    return ('exd',11,2);
                  } elsif ($h->{d_lemma} eq 'èeský') {
                    return ('exd',2,);
                  } elsif ($h->{d_lemma} eq 'zahranièní') {
                    return ('exd',1,);
                  } elsif ($h->{d_lemma} eq 'obchodní') {
                    return ('exd',1,);
                  } elsif ($h->{d_lemma} eq 'malý') {
                    return ('adv',9,2);
                  } elsif ($h->{d_lemma} eq 'dobrý') {
                      if ($h->{i_case} =~ /^(?:1|2|nic|x|undef)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_case} eq '3') {
                        return ('adv',5,3);
                      } elsif ($h->{i_case} eq '4') {
                        return ('obj',11,2);
                      } elsif ($h->{i_case} eq '6') {
                        return ('exd',2,);
                      } elsif ($h->{i_case} eq '7') {
                        return ('adv',3,1);
                      }
                  } elsif ($h->{d_lemma} eq 'velký') {
                      if ($h->{i_case} =~ /^(?:1|nic|7|x|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_case} eq '2') {
                        return ('exd',2,);
                      } elsif ($h->{i_case} eq '3') {
                        return ('obj',2,1);
                      } elsif ($h->{i_case} eq '4') {
                        return ('adv',2,);
                      } elsif ($h->{i_case} eq '6') {
                        return ('adv',2,);
                      }
                  } elsif ($h->{d_lemma} eq 'jiný') {
                      if ($h->{i_case} =~ /^(?:1|nic|x|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_case} eq '2') {
                        return ('adv',12,3);
                      } elsif ($h->{i_case} eq '3') {
                        return ('exd',1,);
                      } elsif ($h->{i_case} eq '4') {
                        return ('adv',82,5);
                      } elsif ($h->{i_case} eq '6') {
                        return ('exd',3,);
                      } elsif ($h->{i_case} eq '7') {
                        return ('adv',2,);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_case} =~ /^(?:1|nic|undef)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_case} eq '3') {
                        return ('exd',29,12);
                      } elsif ($h->{i_case} eq '4') {
                        return ('obj',314,67);
                      } elsif ($h->{i_case} eq 'x') {
                        return ('atr',1,);
                      } elsif ($h->{i_case} eq '2') {
                          if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_subpos} eq 'r') {
                            return ('adv',54,24);
                          } elsif ($h->{i_subpos} eq 'v') {
                            return ('exd',2,);
                          }
                      } elsif ($h->{i_case} eq '6') {
                          if ($h->{d_case} =~ /^(?:1|2|3|4|5|7|undef)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_case} eq '6') {
                            return ('exd',46,24);
                          } elsif ($h->{d_case} eq 'x') {
                            return ('adv',7,);
                          }
                      } elsif ($h->{i_case} eq '7') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('adv',2,);
                          } elsif ($h->{d_subpos} eq 'a') {
                              if ($h->{d_case} =~ /^(?:1|2|3|4|5|6|undef)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_case} eq '7') {
                                return ('exd',23,13);
                              } elsif ($h->{d_case} eq 'x') {
                                return ('adv',3,1);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_voice} eq 'undef') {
          if ($h->{g_pos} eq 'c') {
            return ('atr',462,63);
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|aby|spec_amperpercntspec_semicol|po|za|jako|¾e|od|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('exd',0,);
              } elsif ($h->{i_lemma} eq 'spec_dot') {
                return ('exd_ap',1,);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('exd',24,2);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('exd',15,7);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('exd',162,13);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('exd_ap',9,2);
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                return ('exd',1,);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('exd',186,20);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('exd',2,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                  if ($h->{d_case} =~ /^(?:2|3|4|5|6|7)$/) {
                    return ('exd_ap',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('sb',16,8);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('exd_ap',5,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('exd',1,);
                  }
              } elsif ($h->{i_lemma} eq 'nebo') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_subpos} eq 'a') {
                    return ('exd',8,2);
                  } elsif ($h->{d_subpos} eq 'c') {
                    return ('exd_pa',2,1);
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_pos} =~ /^(?:nic|x|i)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('exd',169,40);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('atr',1,);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('exd',59,);
                  } elsif ($h->{i_pos} eq 't') {
                    return ('atr',6,2);
                  }
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                  if ($h->{d_case} =~ /^(?:2|3|4|5|6|x)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('sb',3,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('exd',2,);
                  }
              }
          } elsif ($h->{g_pos} eq 'a') {
              if ($h->{i_subpos} =~ /^(?:spec_at|t|f|x|i|spec_aster)$/) {
                return ('adv',0,);
              } elsif ($h->{i_subpos} eq 'nic') {
                return ('atr',293,48);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('atr',3,1);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('exd',3,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('adv',45,16);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('adv',5,2);
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('atr',5,2);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('atr',3,1);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('exd',5,1);
                  }
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_subpos} eq 'a') {
                    return ('atr',24,4);
                  } elsif ($h->{d_subpos} eq 'c') {
                    return ('adv',1,);
                  } elsif ($h->{d_subpos} eq 'g') {
                    return ('atr',1,);
                  } elsif ($h->{d_subpos} eq '2') {
                    return ('adv',2,);
                  }
              } elsif ($h->{i_subpos} eq 'r') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_subpos} eq 'g') {
                    return ('atr',4,);
                  } elsif ($h->{d_subpos} eq '2') {
                    return ('adv',1,);
                  } elsif ($h->{d_subpos} eq 'a') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('exd',0,);
                      } elsif ($h->{d_lemma} eq 'dobrý') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'zahranièní') {
                        return ('exd',1,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('exd',32,15);
                      } elsif ($h->{d_lemma} eq 'jiný') {
                        return ('adv',2,);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'd') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|x|i|spec_aster)$/) {
                return ('atr',0,);
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                return ('adv',10,7);
              } elsif ($h->{i_subpos} eq 't') {
                return ('atr',5,);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('exd',1,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_subpos} eq 'a') {
                    return ('exd',31,2);
                  } elsif ($h->{d_subpos} eq 'c') {
                    return ('adv',2,);
                  } elsif ($h->{d_subpos} eq 'g') {
                    return ('exd',2,);
                  }
              } elsif ($h->{i_subpos} eq 'r') {
                  if ($h->{d_case} =~ /^(?:1|3|5)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('adv',2,1);
                  } elsif ($h->{d_case} eq '4') {
                    return ('exd',7,2);
                  } elsif ($h->{d_case} eq '6') {
                    return ('adv',1,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('atr',1,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('coord_ap',2,1);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('adv_pa',1,);
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|fax|v¹echen|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_lemma} eq 'èeský') {
                    return ('atr_ap',2,);
                  } elsif ($h->{d_lemma} eq 'velký') {
                    return ('exd',3,1);
                  } elsif ($h->{d_lemma} eq 'malý') {
                    return ('atr',3,1);
                  } elsif ($h->{d_lemma} eq 'nový') {
                    return ('atr_ap',1,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('atr',135,69);
                  } elsif ($h->{d_lemma} eq 'jiný') {
                    return ('sb_ap',3,2);
                  }
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('atr',24,9);
                  } elsif ($h->{g_subpos} eq 'g') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('exd',1,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('atr',6,1);
                      } elsif ($h->{i_lemma} eq 'èi') {
                        return ('exd',2,);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'n') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|x|i|spec_aster)$/) {
                return ('atr',0,);
              } elsif ($h->{i_subpos} eq 'r') {
                return ('atr',221,71);
              } elsif ($h->{i_subpos} eq 't') {
                return ('atr',20,);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                return ('atr',6096,99);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('exd',7,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('atr',78,12);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('atr_pa',12,5);
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('atr_ap',11,2);
                  } elsif ($h->{i_lemma} eq 'spec_dot') {
                    return ('atr',4,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('atr',538,26);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('atr',9,1);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('atr_ap',82,7);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('atr',728,83);
                  }
              } elsif ($h->{i_subpos} eq 'v') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_lemma} eq 'zahranièní') {
                    return ('exd',1,);
                  } elsif ($h->{d_lemma} eq 'velký') {
                    return ('atr',4,2);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('exd',11,4);
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|d|e|f|h|i|j|k|spec_aster|l|n|o|spec_comma|1|p|q|4|r|s|5|t|6|7|8|v|w|9|x|y|z)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_subpos} eq 'c') {
                    return ('atv',50,9);
                  } elsif ($h->{d_subpos} eq 'g') {
                    return ('atr',2869,38);
                  } elsif ($h->{d_subpos} eq 'm') {
                    return ('atr',8,1);
                  } elsif ($h->{d_subpos} eq '2') {
                    return ('atr',44,);
                  } elsif ($h->{d_subpos} eq 'u') {
                    return ('atr',1833,1);
                  } elsif ($h->{d_subpos} eq 'a') {
                      if ($h->{d_case} eq 'undef') {
                        return ('atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('atr',25699,127);
                      } elsif ($h->{d_case} eq '3') {
                        return ('atr',3867,3);
                      } elsif ($h->{d_case} eq '4') {
                        return ('atr',20196,123);
                      } elsif ($h->{d_case} eq '5') {
                        return ('atr',20,);
                      } elsif ($h->{d_case} eq '6') {
                        return ('atr',12373,16);
                      } elsif ($h->{d_case} eq '7') {
                        return ('atr',8996,21);
                      } elsif ($h->{d_case} eq 'x') {
                        return ('atr',2549,41);
                      } elsif ($h->{d_case} eq '2') {
                          if ($h->{g_case} =~ /^(?:5|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('exd',121,50);
                          } elsif ($h->{g_case} eq '2') {
                            return ('atr',33036,122);
                          } elsif ($h->{g_case} eq '3') {
                            return ('exd',12,5);
                          } elsif ($h->{g_case} eq '4') {
                            return ('exd',72,19);
                          } elsif ($h->{g_case} eq '6') {
                            return ('exd',51,24);
                          } elsif ($h->{g_case} eq '7') {
                            return ('exd',30,8);
                          } elsif ($h->{g_case} eq 'x') {
                            return ('atr',224,1);
                          }
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'p') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|i|m|n|o|2|r|u|7|8|v|y)$/) {
                return ('atr',0,);
              } elsif ($h->{g_subpos} eq 'h') {
                return ('atv',9,2);
              } elsif ($h->{g_subpos} eq 'j') {
                return ('atv',1,);
              } elsif ($h->{g_subpos} eq 'k') {
                return ('atr',5,1);
              } elsif ($h->{g_subpos} eq 'l') {
                return ('atr',40,2);
              } elsif ($h->{g_subpos} eq 's') {
                return ('atr_pa',2,);
              } elsif ($h->{g_subpos} eq '5') {
                return ('obj',3,2);
              } elsif ($h->{g_subpos} eq '6') {
                return ('atr',1,);
              } elsif ($h->{g_subpos} eq 'w') {
                return ('atr',127,3);
              } elsif ($h->{g_subpos} eq 'z') {
                return ('atr',186,6);
              } elsif ($h->{g_subpos} eq 'p') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|èlovìk|být|ten)$/) {
                    return ('atv',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('atv',21,4);
                  } elsif ($h->{g_lemma} eq 'já') {
                    return ('atr',19,4);
                  }
              } elsif ($h->{g_subpos} eq 'q') {
                  if ($h->{d_case} =~ /^(?:1|3|5|6|7|x|undef)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr',11,2);
                  } elsif ($h->{d_case} eq '4') {
                    return ('atv',3,);
                  }
              } elsif ($h->{g_subpos} eq 'd') {
                  if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_pos} eq 'nic') {
                    return ('atr',193,32);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('atr_ap',2,);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('obj',2,1);
                  } elsif ($h->{i_pos} eq 'j') {
                      if ($h->{d_case} =~ /^(?:3|5|6|7|x)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',1,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('atr',4,1);
                      } elsif ($h->{d_case} eq '1') {
                          if ($h->{g_case} =~ /^(?:1|2|5|x|undef)$/) {
                            return ('sb',0,);
                          } elsif ($h->{g_case} eq '3') {
                            return ('sb',1,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('atv',2,);
                          } elsif ($h->{g_case} eq '6') {
                            return ('sb',3,);
                          } elsif ($h->{g_case} eq '7') {
                            return ('exd',3,1);
                          }
                      } elsif ($h->{d_case} eq '4') {
                          if ($h->{g_case} =~ /^(?:1|2|3|5|7|x|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('atr',6,1);
                          } elsif ($h->{g_case} eq '6') {
                            return ('exd',2,);
                          }
                      }
                  }
              } elsif ($h->{g_subpos} eq '4') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|f|v|x|i|spec_aster)$/) {
                    return ('atv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('atv_pa',1,);
                  } elsif ($h->{i_subpos} eq 'nic') {
                    return ('atv',20,1);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_case} =~ /^(?:2|3|5|6|7|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('exd',2,);
                      } elsif ($h->{g_case} eq '4') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|8|v|w|9|x|y|z)$/) {
                            return ('atr',0,);
                          } elsif ($h->{d_subpos} eq 'a') {
                            return ('atv',2,);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('atr',1,);
                          } elsif ($h->{d_subpos} eq 'u') {
                            return ('atr',2,);
                          }
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'v') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('pnom',0,);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('sb',1,);
              } elsif ($h->{g_lemma} eq 'jít') {
                return ('obj',1,);
              } elsif ($h->{g_lemma} eq 'být') {
                return ('pnom',394,12);
              } elsif ($h->{g_lemma} eq 'mít') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('obj',3,1);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('exd',7,3);
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|t|f|x|i|spec_aster)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_subpos} eq 'v') {
                    return ('exd',5,1);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('atr',71,25);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('exd',0,);
                      } elsif ($h->{d_subpos} eq 'a') {
                        return ('exd',5,);
                      } elsif ($h->{d_subpos} eq 'c') {
                        return ('adv',5,1);
                      }
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|e|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_subpos} eq 'i') {
                        return ('exd_ap',2,);
                      } elsif ($h->{g_subpos} eq 'f') {
                          if ($h->{d_case} =~ /^(?:3|5|6)$/) {
                            return ('atr',0,);
                          } elsif ($h->{d_case} eq '1') {
                            return ('sb',2,1);
                          } elsif ($h->{d_case} eq '2') {
                            return ('atr',2,1);
                          } elsif ($h->{d_case} eq '4') {
                            return ('atr',6,3);
                          } elsif ($h->{d_case} eq '7') {
                            return ('obj',2,);
                          } elsif ($h->{d_case} eq 'x') {
                            return ('exd_ap',3,2);
                          } elsif ($h->{d_case} eq 'undef') {
                            return ('adv',1,);
                          }
                      }
                  } elsif ($h->{i_subpos} eq 'r') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|na|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_lemma} eq 'dal¹í') {
                        return ('exd',3,1);
                      } elsif ($h->{d_lemma} eq 'dobrý') {
                        return ('adv',5,2);
                      } elsif ($h->{d_lemma} eq 'velký') {
                        return ('exd',1,);
                      } elsif ($h->{d_lemma} eq 'malý') {
                        return ('exd',3,1);
                      } elsif ($h->{d_lemma} eq 'jiný') {
                        return ('adv',12,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{i_case} =~ /^(?:1|nic|x|undef)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_case} eq '3') {
                            return ('obj',1,);
                          } elsif ($h->{i_case} eq '4') {
                            return ('obj',42,17);
                          } elsif ($h->{i_case} eq '6') {
                            return ('exd',11,6);
                          } elsif ($h->{i_case} eq '7') {
                            return ('obj',10,6);
                          } elsif ($h->{i_case} eq '2') {
                              if ($h->{d_case} =~ /^(?:1|5|6|7|x|undef)$/) {
                                return ('exd',0,);
                              } elsif ($h->{d_case} eq '2') {
                                return ('exd',18,9);
                              } elsif ($h->{d_case} eq '3') {
                                return ('atr',1,);
                              } elsif ($h->{d_case} eq '4') {
                                return ('atr',2,);
                              }
                          }
                      }
                  } elsif ($h->{i_subpos} eq 'nic') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|1994|jako|muset|výroba|firma|který|a|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_lemma} eq 'dal¹í') {
                        return ('sb',3,2);
                      } elsif ($h->{d_lemma} eq 'èeský') {
                        return ('atr',3,1);
                      } elsif ($h->{d_lemma} eq 'nový') {
                        return ('exd',3,1);
                      } elsif ($h->{d_lemma} eq 'jiný') {
                        return ('exd',3,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_subpos} eq 'e') {
                            return ('atr',1,);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('obj',131,46);
                          } elsif ($h->{g_subpos} eq 'i') {
                              if ($h->{d_case} =~ /^(?:5|7|undef)$/) {
                                return ('atr',0,);
                              } elsif ($h->{d_case} eq '1') {
                                return ('sb_ap',2,1);
                              } elsif ($h->{d_case} eq '2') {
                                return ('atr_ap',6,4);
                              } elsif ($h->{d_case} eq '3') {
                                return ('atr_ap',3,2);
                              } elsif ($h->{d_case} eq '4') {
                                return ('obj',4,2);
                              } elsif ($h->{d_case} eq '6') {
                                return ('atr',1,);
                              } elsif ($h->{d_case} eq 'x') {
                                return ('atr',1,);
                              }
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'n') {
      if ($h->{g_pos} eq 'n') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|spec_rpar|aby|po|za|od|mezi|k|pøi|spec_amperastspec_semicol)$/) {
            return ('atr',0,);
          } elsif ($h->{i_lemma} eq 'na') {
            return ('atr',8,2);
          } elsif ($h->{i_lemma} eq 'nebo') {
            return ('atr',521,69);
          } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
            return ('atr',14,);
          } elsif ($h->{i_lemma} eq 'jako') {
            return ('exd',28,9);
          } elsif ($h->{i_lemma} eq 'other') {
            return ('atr',40275,3731);
          } elsif ($h->{i_lemma} eq '¾e') {
            return ('atr',1,);
          } elsif ($h->{i_lemma} eq 'spec_lpar') {
            return ('atr_ap',749,32);
          } elsif ($h->{i_lemma} eq 'pro') {
            return ('atr',3,1);
          } elsif ($h->{i_lemma} eq 'kdy¾') {
            return ('atv_ap',1,);
          } elsif ($h->{i_lemma} eq 'spec_comma') {
            return ('atr',2236,782);
          } elsif ($h->{i_lemma} eq 'o') {
            return ('atr',2,);
          } elsif ($h->{i_lemma} eq 's') {
            return ('atr',6,1);
          } elsif ($h->{i_lemma} eq 'v¹ak') {
            return ('sb',2,1);
          } elsif ($h->{i_lemma} eq 'u') {
            return ('atr',1,);
          } elsif ($h->{i_lemma} eq 'v') {
            return ('atr',22,7);
          } elsif ($h->{i_lemma} eq 'èi') {
            return ('atr',441,27);
          } elsif ($h->{i_lemma} eq 'z') {
            return ('atr',5,);
          } elsif ($h->{i_lemma} eq 'do') {
            return ('atr',1,);
          } elsif ($h->{i_lemma} eq 'spec_ddot') {
              if ($h->{d_case} =~ /^(?:3|5|6|undef)$/) {
                return ('atr_ap',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('atr_ap',11,5);
              } elsif ($h->{d_case} eq '2') {
                return ('atr_ap',16,1);
              } elsif ($h->{d_case} eq '4') {
                return ('atr_ap',8,1);
              } elsif ($h->{d_case} eq '7') {
                return ('atr_ap',1,);
              } elsif ($h->{d_case} eq 'x') {
                return ('atr',22,5);
              }
          } elsif ($h->{i_lemma} eq 'spec_dot') {
              if ($h->{g_case} =~ /^(?:2|5|6|7|undef)$/) {
                return ('atr',0,);
              } elsif ($h->{g_case} eq '3') {
                return ('atr',2,);
              } elsif ($h->{g_case} eq '4') {
                return ('atr',4,);
              } elsif ($h->{g_case} eq 'x') {
                return ('obj',4,);
              } elsif ($h->{g_case} eq '1') {
                  if ($h->{d_case} =~ /^(?:1|3|4|5|6|7|undef)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr_ap',3,1);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('atr',2,);
                  }
              }
          } elsif ($h->{i_lemma} eq 'ale') {
              if ($h->{d_case} =~ /^(?:5|undef)$/) {
                return ('atr',0,);
              } elsif ($h->{d_case} eq '2') {
                return ('atr',61,4);
              } elsif ($h->{d_case} eq '3') {
                return ('atr',1,);
              } elsif ($h->{d_case} eq '6') {
                return ('atr',6,);
              } elsif ($h->{d_case} eq '7') {
                return ('atr',4,1);
              } elsif ($h->{d_case} eq 'x') {
                return ('atr',3,);
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{g_case} =~ /^(?:3|5|7|x|undef)$/) {
                    return ('sb',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('atv',6,2);
                  } elsif ($h->{g_case} eq '2') {
                    return ('sb',1,);
                  } elsif ($h->{g_case} eq '4') {
                    return ('sb',5,1);
                  } elsif ($h->{g_case} eq '6') {
                    return ('sb',2,1);
                  }
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{g_case} =~ /^(?:5|6|7|x|undef)$/) {
                    return ('atv',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('adv',1,);
                  } elsif ($h->{g_case} eq '2') {
                    return ('obj',2,1);
                  } elsif ($h->{g_case} eq '3') {
                    return ('obj',1,);
                  } elsif ($h->{g_case} eq '4') {
                    return ('atv',5,2);
                  }
              }
          } elsif ($h->{i_lemma} eq 'undef') {
              if ($h->{d_case} =~ /^(?:5|undef)$/) {
                return ('atr',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('atr',601,102);
              } elsif ($h->{d_case} eq '3') {
                return ('atr_ap',7,3);
              } elsif ($h->{d_case} eq '4') {
                return ('atr_ap',14,5);
              } elsif ($h->{d_case} eq '6') {
                return ('atr',26,13);
              } elsif ($h->{d_case} eq '7') {
                return ('atr_ap',20,2);
              } elsif ($h->{d_case} eq 'x') {
                return ('atr',206,90);
              } elsif ($h->{d_case} eq '2') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|který|a|jiný|spec_lpar|pro|doba|k|kdy¾|o|jít|trh|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('atr_ap',0,);
                  } elsif ($h->{d_lemma} eq 'podnik') {
                    return ('atr_ap',1,);
                  } elsif ($h->{d_lemma} eq 'rok') {
                    return ('atr',13,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('atr_ap',223,45);
                  } elsif ($h->{d_lemma} eq 'firma') {
                    return ('atr_ap',1,);
                  } elsif ($h->{d_lemma} eq 'podnikatel') {
                    return ('atr_ap',4,);
                  } elsif ($h->{d_lemma} eq 'èlovìk') {
                    return ('atr_ap',2,1);
                  }
              }
          } elsif ($h->{i_lemma} eq 'nic') {
              if ($h->{d_case} eq 'undef') {
                return ('atr',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('atr',15344,1006);
              } elsif ($h->{d_case} eq '2') {
                return ('atr',57799,1347);
              } elsif ($h->{d_case} eq '3') {
                return ('atr',763,49);
              } elsif ($h->{d_case} eq '4') {
                return ('atr',1003,232);
              } elsif ($h->{d_case} eq '5') {
                return ('atr',26,3);
              } elsif ($h->{d_case} eq '7') {
                return ('atr',1369,81);
              } elsif ($h->{d_case} eq 'x') {
                return ('atr',9525,426);
              } elsif ($h->{d_case} eq '6') {
                  if ($h->{g_case} =~ /^(?:5|undef)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_case} eq '1') {
                    return ('auxp',38,6);
                  } elsif ($h->{g_case} eq '2') {
                    return ('auxp',37,14);
                  } elsif ($h->{g_case} eq '3') {
                    return ('auxp',5,1);
                  } elsif ($h->{g_case} eq '4') {
                    return ('auxp',38,8);
                  } elsif ($h->{g_case} eq '6') {
                    return ('atr',175,16);
                  } elsif ($h->{g_case} eq '7') {
                    return ('auxp',12,1);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('atr',4,);
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'c') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|aby|po|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
            return ('atr',0,);
          } elsif ($h->{i_lemma} eq 'nebo') {
            return ('atr',5,);
          } elsif ($h->{i_lemma} eq 'spec_dot') {
            return ('obj',1,);
          } elsif ($h->{i_lemma} eq 'ale') {
            return ('atr',1,);
          } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
            return ('atr',145,2);
          } elsif ($h->{i_lemma} eq 'za') {
            return ('atr',1,);
          } elsif ($h->{i_lemma} eq 'jako') {
            return ('exd',3,);
          } elsif ($h->{i_lemma} eq 'nic') {
            return ('atr',7137,52);
          } elsif ($h->{i_lemma} eq 'spec_lpar') {
            return ('atr_ap',6,);
          } elsif ($h->{i_lemma} eq 'èi') {
            return ('atr',6,);
          } elsif ($h->{i_lemma} eq 'undef') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_rbrace|a|b|c|d|e|f|spec_hash|g|h|i|j|k|m|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('atr_ap',0,);
              } elsif ($h->{g_subpos} eq 'spec_eq') {
                return ('obj',4,2);
              } elsif ($h->{g_subpos} eq 'l') {
                return ('atr_ap',5,);
              } elsif ($h->{g_subpos} eq 'n') {
                return ('atradv_ap',1,);
              }
          } elsif ($h->{i_lemma} eq 'other') {
              if ($h->{g_subpos} =~ /^(?:spec_rbrace|b|c|d|e|f|spec_hash|g|i|j|k|m|p|2|q|4|s|5|6|u|7|8|z)$/) {
                return ('atr',0,);
              } elsif ($h->{g_subpos} eq 'spec_qmark') {
                return ('atr',9,);
              } elsif ($h->{g_subpos} eq 'spec_eq') {
                return ('atr',194,29);
              } elsif ($h->{g_subpos} eq 'a') {
                return ('atr',35,1);
              } elsif ($h->{g_subpos} eq 'h') {
                return ('atr',7,);
              } elsif ($h->{g_subpos} eq 'l') {
                return ('atr',647,17);
              } elsif ($h->{g_subpos} eq 'n') {
                return ('atr',40,4);
              } elsif ($h->{g_subpos} eq 'o') {
                return ('atr',5,2);
              } elsif ($h->{g_subpos} eq 'w') {
                return ('atr',2,);
              } elsif ($h->{g_subpos} eq 'y') {
                return ('atr',14,2);
              } elsif ($h->{g_subpos} eq 'r') {
                  if ($h->{d_case} =~ /^(?:1|3|4|5|undef)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr',26,11);
                  } elsif ($h->{d_case} eq '6') {
                    return ('adv',35,14);
                  } elsif ($h->{d_case} eq '7') {
                    return ('atr',1,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('adv',2,1);
                  }
              } elsif ($h->{g_subpos} eq 'v') {
                  if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('exd_pa',2,1);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('adv',52,12);
                  }
              }
          } elsif ($h->{i_lemma} eq 'spec_comma') {
              if ($h->{d_case} =~ /^(?:3|4|5|6|7|x|undef)$/) {
                return ('atr',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('exd',17,4);
              } elsif ($h->{d_case} eq '2') {
                  if ($h->{g_case} =~ /^(?:2|3|5|6|x)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_case} eq '4') {
                    return ('atr_ap',2,);
                  } elsif ($h->{g_case} eq '7') {
                    return ('atr',2,);
                  } elsif ($h->{g_case} eq 'undef') {
                    return ('atr_ap',2,);
                  } elsif ($h->{g_case} eq '1') {
                      if ($h->{g_subpos} =~ /^(?:spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|g|h|i|j|k|l|m|o|p|2|q|4|r|s|5|6|u|7|8|v|w|z)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_subpos} eq 'spec_qmark') {
                        return ('atr',3,);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('atr',3,);
                      } elsif ($h->{g_subpos} eq 'n') {
                        return ('atr_ap',3,);
                      } elsif ($h->{g_subpos} eq 'y') {
                        return ('atr',1,);
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'z') {
          if ($h->{i_voice} eq 'nic') {
              if ($h->{d_case} eq 'undef') {
                return ('exd',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('exd',6955,100);
              } elsif ($h->{d_case} eq '2') {
                return ('exd',105,34);
              } elsif ($h->{d_case} eq '3') {
                return ('exd',63,);
              } elsif ($h->{d_case} eq '4') {
                return ('exd',123,6);
              } elsif ($h->{d_case} eq '5') {
                return ('exd',9,);
              } elsif ($h->{d_case} eq '7') {
                return ('exd',83,7);
              } elsif ($h->{d_case} eq '6') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_lemma} eq 'pøípad') {
                    return ('auxp',2,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('exd',8,3);
                  }
              } elsif ($h->{d_case} eq 'x') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('exd_pa',0,);
                  } elsif ($h->{d_lemma} eq 'kè') {
                    return ('exd',2,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('exd_pa',870,419);
                  }
              }
          } elsif ($h->{i_voice} eq 'undef') {
              if ($h->{i_pos} =~ /^(?:nic|i)$/) {
                return ('exd',0,);
              } elsif ($h->{i_pos} eq 'x') {
                return ('exd',1,);
              } elsif ($h->{i_pos} eq 'r') {
                return ('exd',2301,315);
              } elsif ($h->{i_pos} eq 't') {
                return ('sb',3,2);
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|aby|tento|spec_quot|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|k|kdy¾|o|jít|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_lemma} eq 'zbo¾í') {
                    return ('exd_ap',2,);
                  } elsif ($h->{d_lemma} eq 'pøípad') {
                    return ('exd_ap',1,);
                  } elsif ($h->{d_lemma} eq 'telefon') {
                    return ('atr',2,1);
                  } elsif ($h->{d_lemma} eq 'podnik') {
                    return ('sb',3,1);
                  } elsif ($h->{d_lemma} eq 'kè') {
                    return ('atr',1,);
                  } elsif ($h->{d_lemma} eq 'rok') {
                    return ('exd',3,);
                  } elsif ($h->{d_lemma} eq 'fax') {
                    return ('atr',29,3);
                  } elsif ($h->{d_lemma} eq 'výroba') {
                    return ('exd_ap',2,1);
                  } elsif ($h->{d_lemma} eq 'podnikatel') {
                    return ('exd',4,2);
                  } elsif ($h->{d_lemma} eq 'doba') {
                    return ('exd_ap',4,2);
                  } elsif ($h->{d_lemma} eq 'èlovìk') {
                    return ('sb',4,1);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|nebo|aby|ale|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_lemma} eq 'spec_rpar') {
                        return ('sb',1,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('exd_ap',1280,502);
                      } elsif ($h->{i_lemma} eq 'spec_dot') {
                        return ('exd_ap',16,9);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('exd',1007,462);
                      } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                        return ('atr',1,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('exd',212,29);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('exd_ap',93,18);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('exd',2718,834);
                      } elsif ($h->{i_lemma} eq 'spec_amperastspec_semicol') {
                        return ('exd',4,);
                      }
                  } elsif ($h->{d_lemma} eq 'firma') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('sb',0,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('exd_ap',3,);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('sb',7,3);
                      }
                  } elsif ($h->{d_lemma} eq 'trh') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('sb',11,6);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('exd',7,);
                      }
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_subpos} eq 'spec_aster') {
                    return ('atr_pa',1,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                      if ($h->{d_case} =~ /^(?:3|5|6|7|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('exd',23,4);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',6,1);
                      } elsif ($h->{d_case} eq '4') {
                        return ('exd',6,);
                      } elsif ($h->{d_case} eq 'x') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('atr',0,);
                          } elsif ($h->{i_lemma} eq 'jako') {
                            return ('sb_ap',2,1);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('atr',21,1);
                          }
                      }
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{d_case} eq 'undef') {
                        return ('exd',0,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('exd',167,67);
                      } elsif ($h->{d_case} eq '3') {
                        return ('exd',47,1);
                      } elsif ($h->{d_case} eq '4') {
                        return ('exd',324,74);
                      } elsif ($h->{d_case} eq '5') {
                        return ('exd',4,1);
                      } elsif ($h->{d_case} eq '7') {
                        return ('exd',120,21);
                      } elsif ($h->{d_case} eq '1') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('sb',0,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('exd',103,28);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('sb',192,41);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('sb',2402,1111);
                          } elsif ($h->{i_lemma} eq 'v¹ak') {
                            return ('sb',43,7);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('exd',58,17);
                          }
                      } elsif ($h->{d_case} eq '6') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('exd',0,);
                          } elsif ($h->{d_lemma} eq 'pøípad') {
                            return ('auxp',2,);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('exd',61,12);
                          } elsif ($h->{d_lemma} eq 'èlovìk') {
                            return ('exd',1,);
                          }
                      } elsif ($h->{d_case} eq 'x') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('sb',0,);
                          } elsif ($h->{d_lemma} eq 'kè') {
                            return ('atr',2,);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('sb',114,62);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'p') {
          if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
            return ('atr',0,);
          } elsif ($h->{i_pos} eq 'z') {
              if ($h->{d_case} =~ /^(?:3|5|7|undef)$/) {
                return ('sb',0,);
              } elsif ($h->{d_case} eq '2') {
                return ('exd',1,);
              } elsif ($h->{d_case} eq '4') {
                return ('exd_ap',3,1);
              } elsif ($h->{d_case} eq '6') {
                return ('auxp',1,);
              } elsif ($h->{d_case} eq 'x') {
                return ('sb_ap',1,);
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('sb',0,);
                  } elsif ($h->{g_subpos} eq 'd') {
                    return ('sb',11,3);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('atr',4,);
                  } elsif ($h->{g_subpos} eq '4') {
                    return ('sb_ap',1,);
                  }
              }
          } elsif ($h->{i_pos} eq 'nic') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|f|spec_hash|g|i|m|n|o|2|r|s|5|u|8|v|w|y)$/) {
                return ('atv',0,);
              } elsif ($h->{g_subpos} eq 'e') {
                return ('atv',3,);
              } elsif ($h->{g_subpos} eq 'h') {
                return ('atv',9,);
              } elsif ($h->{g_subpos} eq 'j') {
                return ('atv',2,);
              } elsif ($h->{g_subpos} eq 'k') {
                return ('atv',4,);
              } elsif ($h->{g_subpos} eq 'l') {
                return ('atr',6,1);
              } elsif ($h->{g_subpos} eq 'q') {
                return ('atv',4,1);
              } elsif ($h->{g_subpos} eq '4') {
                return ('atv',65,2);
              } elsif ($h->{g_subpos} eq '6') {
                return ('atv',2,);
              } elsif ($h->{g_subpos} eq '7') {
                  if ($h->{d_case} =~ /^(?:2|3|4|5|6|x|undef)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('sb',2,1);
                  } elsif ($h->{d_case} eq '7') {
                    return ('obj',15,9);
                  }
              } elsif ($h->{g_subpos} eq 'z') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('atr',7,3);
                  } elsif ($h->{g_lemma} eq 'nìkterý') {
                    return ('atv',2,);
                  }
              } elsif ($h->{g_subpos} eq 'p') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|èlovìk|být|ten)$/) {
                    return ('atv',0,);
                  } elsif ($h->{g_lemma} eq 'já') {
                    return ('atr',22,5);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{g_case} =~ /^(?:2|6|7|undef)$/) {
                        return ('atv',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atv',4,1);
                      } elsif ($h->{g_case} eq '3') {
                        return ('atv',3,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('atv',32,1);
                      } elsif ($h->{g_case} eq '5') {
                        return ('atr',5,);
                      } elsif ($h->{g_case} eq 'x') {
                        return ('atr',1,);
                      }
                  }
              } elsif ($h->{g_subpos} eq 'd') {
                  if ($h->{d_case} =~ /^(?:5|undef)$/) {
                    return ('atv',0,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('atv',20,9);
                  } elsif ($h->{d_case} eq '6') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('auxg',1,);
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{g_case} =~ /^(?:2|3|5|6|x|undef)$/) {
                        return ('atr_ap',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atr_ap',1,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('atr_ap',5,1);
                      } elsif ($h->{g_case} eq '7') {
                        return ('exd',2,);
                      }
                  } elsif ($h->{d_case} eq '7') {
                      if ($h->{g_case} =~ /^(?:2|3|5|6|7|x|undef)$/) {
                        return ('adv_ap',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('adv_ap',2,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('pnom_ap',2,1);
                      }
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{g_case} =~ /^(?:3|5|6|x|undef)$/) {
                        return ('exd',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atv',9,2);
                      } elsif ($h->{g_case} eq '2') {
                        return ('exd',1,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('exd',3,);
                      } elsif ($h->{g_case} eq '4') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být)$/) {
                            return ('sb_ap',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('exd',2,);
                          } elsif ($h->{g_lemma} eq 'ten') {
                            return ('sb_ap',8,1);
                          }
                      }
                  }
              }
          } elsif ($h->{i_pos} eq 'r') {
              if ($h->{i_case} =~ /^(?:1|nic|x|undef)$/) {
                return ('atr',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('atr',180,11);
              } elsif ($h->{i_case} eq '3') {
                return ('atr',1,);
              } elsif ($h->{i_case} eq '4') {
                return ('atr',20,10);
              } elsif ($h->{i_case} eq '7') {
                return ('atr',15,3);
              } elsif ($h->{i_case} eq '6') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|k|m|n|o|2|q|r|6|u|7|8|v|y)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_subpos} eq 'l') {
                    return ('atr',7,2);
                  } elsif ($h->{g_subpos} eq '4') {
                    return ('atr',3,);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('atr',1,);
                  } elsif ($h->{g_subpos} eq '5') {
                    return ('atv',4,1);
                  } elsif ($h->{g_subpos} eq 'w') {
                    return ('atr',5,2);
                  } elsif ($h->{g_subpos} eq 'z') {
                    return ('atr',14,8);
                  } elsif ($h->{g_subpos} eq 'p') {
                      if ($h->{g_case} =~ /^(?:3|4|5|7|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atr',2,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('adv',2,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('atv',4,1);
                      }
                  } elsif ($h->{g_subpos} eq 'd') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být)$/) {
                        return ('exd',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('exd',5,);
                      } elsif ($h->{g_lemma} eq 'ten') {
                          if ($h->{g_case} =~ /^(?:5|x|undef)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('atr',4,);
                          } elsif ($h->{g_case} eq '2') {
                            return ('adv',1,);
                          } elsif ($h->{g_case} eq '3') {
                            return ('exd',1,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('exd',6,3);
                          } elsif ($h->{g_case} eq '6') {
                            return ('adv',2,1);
                          } elsif ($h->{g_case} eq '7') {
                            return ('adv',5,2);
                          }
                      }
                  }
              }
          } elsif ($h->{i_pos} eq 'j') {
              if ($h->{d_case} =~ /^(?:5|undef)$/) {
                return ('atr',0,);
              } elsif ($h->{d_case} eq '2') {
                return ('atr',25,4);
              } elsif ($h->{d_case} eq '3') {
                return ('atr',1,);
              } elsif ($h->{d_case} eq '6') {
                return ('atr',7,);
              } elsif ($h->{d_case} eq '7') {
                return ('atr',12,4);
              } elsif ($h->{d_case} eq 'x') {
                return ('sb',2,);
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|i|j|k|m|n|o|2|q|r|s|5|6|u|7|8|v|y)$/) {
                    return ('atv',0,);
                  } elsif ($h->{g_subpos} eq 'd') {
                    return ('obj',22,9);
                  } elsif ($h->{g_subpos} eq 'h') {
                    return ('atv',3,);
                  } elsif ($h->{g_subpos} eq 'l') {
                    return ('atr',4,);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('atv',5,1);
                  } elsif ($h->{g_subpos} eq '4') {
                    return ('atv',4,);
                  } elsif ($h->{g_subpos} eq 'w') {
                    return ('atr',2,1);
                  } elsif ($h->{g_subpos} eq 'z') {
                    return ('atr',2,1);
                  }
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                    return ('sb',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',15,2);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|k|l|m|n|o|p|2|r|s|5|6|u|7|8|v|w|y)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_subpos} eq 'q') {
                        return ('atv',2,);
                      } elsif ($h->{g_subpos} eq 'z') {
                        return ('sb',3,2);
                      } elsif ($h->{g_subpos} eq 'd') {
                          if ($h->{g_case} =~ /^(?:5|x|undef)$/) {
                            return ('sb',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('sb',12,4);
                          } elsif ($h->{g_case} eq '2') {
                            return ('exd',11,2);
                          } elsif ($h->{g_case} eq '3') {
                            return ('sb',2,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('sb',6,1);
                          } elsif ($h->{g_case} eq '6') {
                            return ('sb',7,3);
                          } elsif ($h->{g_case} eq '7') {
                            return ('sb',17,4);
                          }
                      } elsif ($h->{g_subpos} eq '4') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('atv',0,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('atv',5,);
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{g_case} =~ /^(?:2|3|5|6|7|undef)$/) {
                                return ('sb',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('atv',2,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('sb',2,);
                              } elsif ($h->{g_case} eq 'x') {
                                return ('sb',1,);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'a') {
          if ($h->{g_lemma} =~ /^(?:zákon|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|fax|02|v¹echen|podnik|1994|mít|muset|výroba|kè|firma|a|který|koruna|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
            return ('adv',0,);
          } elsif ($h->{g_lemma} eq 'dal¹í') {
            return ('atr',21,2);
          } elsif ($h->{g_lemma} eq 'zahranièní') {
            return ('exd',4,);
          } elsif ($h->{g_lemma} eq 'nový') {
            return ('atr',3,1);
          } elsif ($h->{g_lemma} eq 'obchodní') {
            return ('exd_pa',1,);
          } elsif ($h->{g_lemma} eq 'jiný') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('exd',0,);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('exd',61,5);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('atr',1,);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('atr',3,);
              }
          } elsif ($h->{g_lemma} eq 'velký') {
              if ($h->{i_pos} =~ /^(?:x|i|z|t)$/) {
                return ('exd',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('adv',8,2);
              } elsif ($h->{i_pos} eq 'j') {
                return ('exd',44,5);
              } elsif ($h->{i_pos} eq 'r') {
                return ('adv',50,21);
              }
          } elsif ($h->{g_lemma} eq 'dobrý') {
              if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                return ('adv',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('adv',5,);
              } elsif ($h->{i_pos} eq 'z') {
                return ('adv',2,);
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{d_case} =~ /^(?:2|3|5|6|7|undef)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('exd',18,1);
                  } elsif ($h->{d_case} eq '4') {
                    return ('exd',2,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('adv',2,);
                  }
              } elsif ($h->{i_pos} eq 'r') {
                  if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'r') {
                    return ('adv',34,8);
                  } elsif ($h->{i_subpos} eq 'v') {
                    return ('atr',4,2);
                  }
              }
          } elsif ($h->{g_lemma} eq 'malý') {
              if ($h->{i_case} =~ /^(?:1|7)$/) {
                return ('exd',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('atr',3,);
              } elsif ($h->{i_case} eq '3') {
                return ('adv',2,1);
              } elsif ($h->{i_case} eq '4') {
                return ('obj',3,1);
              } elsif ($h->{i_case} eq '6') {
                return ('exd',8,3);
              } elsif ($h->{i_case} eq 'x') {
                return ('exd',1,);
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{d_case} =~ /^(?:2|3|4|5|6|x|undef)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('atr',3,1);
                  } elsif ($h->{d_case} eq '7') {
                    return ('adv',4,);
                  }
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('exd',21,3);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('adv',2,);
                  }
              }
          } elsif ($h->{g_lemma} eq 'other') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|spec_rpar|aby|spec_amperpercntspec_semicol|po|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|u|v|do|spec_amperastspec_semicol)$/) {
                return ('adv',0,);
              } elsif ($h->{i_lemma} eq 'na') {
                return ('obj',1,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('obj_ap',3,);
              } elsif ($h->{i_lemma} eq 'spec_dot') {
                return ('adv_ap',2,);
              } elsif ($h->{i_lemma} eq 'za') {
                return ('adv',2,1);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('exd',68,1);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('obj_ap',53,23);
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                return ('obj',5,1);
              } elsif ($h->{i_lemma} eq 'z') {
                return ('adv',1,);
              } elsif ($h->{i_lemma} eq 'ale') {
                  if ($h->{d_case} =~ /^(?:2|5|6|x|undef)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('obj',2,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('obj',2,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('adv',4,);
                  }
              } elsif ($h->{i_lemma} eq 'nebo') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_subpos} eq 'g') {
                    return ('obj',6,);
                  } elsif ($h->{g_subpos} eq 'a') {
                      if ($h->{d_case} =~ /^(?:5|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('obj',4,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',3,);
                      } elsif ($h->{d_case} eq '3') {
                        return ('adv',4,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('adv',2,);
                      } elsif ($h->{d_case} eq '6') {
                        return ('adv',6,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('adv',24,10);
                      } elsif ($h->{d_case} eq 'x') {
                        return ('obj',2,);
                      }
                  }
              } elsif ($h->{i_lemma} eq 'undef') {
                  if ($h->{d_case} =~ /^(?:5|undef)$/) {
                    return ('obj_ap',0,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('obj_ap',3,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('obj_ap',3,);
                  } elsif ($h->{d_case} eq '6') {
                    return ('adv_ap',2,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('obj_ap',4,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('atr',9,5);
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{g_case} =~ /^(?:2|3|5|6|7|x|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('adv',3,1);
                      } elsif ($h->{g_case} eq '4') {
                        return ('obj_ap',2,);
                      }
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('atr',3,);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('adv_ap',2,);
                      }
                  }
              } elsif ($h->{i_lemma} eq 'èi') {
                  if ($h->{g_case} =~ /^(?:3|5|7|undef)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_case} eq '2') {
                    return ('obj',10,2);
                  } elsif ($h->{g_case} eq '6') {
                    return ('obj',3,);
                  } elsif ($h->{g_case} eq 'x') {
                    return ('atr',2,);
                  } elsif ($h->{g_case} eq '1') {
                      if ($h->{d_case} =~ /^(?:1|5|undef)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('adv',8,2);
                      } elsif ($h->{d_case} eq '3') {
                        return ('obj',8,2);
                      } elsif ($h->{d_case} eq '4') {
                        return ('obj',11,2);
                      } elsif ($h->{d_case} eq '6') {
                        return ('obj',2,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('adv',6,);
                      } elsif ($h->{d_case} eq 'x') {
                        return ('adv',2,1);
                      }
                  } elsif ($h->{g_case} eq '4') {
                      if ($h->{d_case} =~ /^(?:2|3|4|5|6|x|undef)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('exd',2,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('obj',4,);
                      }
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{d_case} =~ /^(?:5|undef)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('exd',31,6);
                  } elsif ($h->{d_case} eq '6') {
                    return ('adv',2,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('exd',5,3);
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{g_case} =~ /^(?:3|4|5|6|x|undef)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('obj',12,2);
                      } elsif ($h->{g_case} eq '2') {
                        return ('atr',3,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('adv',7,);
                      }
                  } elsif ($h->{d_case} eq '3') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('adv_ap',4,2);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('obj',4,);
                      }
                  } elsif ($h->{d_case} eq '7') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('obj',16,6);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('adv_ap',2,);
                      }
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('obj',15,2);
                      } elsif ($h->{g_subpos} eq 'a') {
                          if ($h->{g_case} =~ /^(?:3|5|6|7|x|undef)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('adv',8,3);
                          } elsif ($h->{g_case} eq '2') {
                            return ('obj',4,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('adv',2,);
                          }
                      }
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|nic|f|x|i|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',136,9);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                    return ('atr',6,);
                  } elsif ($h->{i_subpos} eq 't') {
                    return ('atr',2,1);
                  } elsif ($h->{i_subpos} eq 'v') {
                      if ($h->{i_case} =~ /^(?:1|nic|x|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_case} eq '2') {
                        return ('adv',68,29);
                      } elsif ($h->{i_case} eq '3') {
                        return ('adv',28,9);
                      } elsif ($h->{i_case} eq '4') {
                        return ('adv',8,);
                      } elsif ($h->{i_case} eq '6') {
                        return ('adv',112,16);
                      } elsif ($h->{i_case} eq '7') {
                        return ('obj',59,14);
                      }
                  } elsif ($h->{i_subpos} eq 'r') {
                      if ($h->{i_case} =~ /^(?:nic|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_case} eq '1') {
                        return ('adv',1,);
                      } elsif ($h->{i_case} eq '2') {
                        return ('adv',684,200);
                      } elsif ($h->{i_case} eq '3') {
                        return ('adv',209,52);
                      } elsif ($h->{i_case} eq '6') {
                        return ('adv',1046,212);
                      } elsif ($h->{i_case} eq 'x') {
                        return ('obj',2,1);
                      } elsif ($h->{i_case} eq '4') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'a') {
                            return ('adv',558,199);
                          } elsif ($h->{g_subpos} eq 'c') {
                            return ('adv',12,7);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('obj',102,42);
                          }
                      } elsif ($h->{i_case} eq '7') {
                          if ($h->{d_case} =~ /^(?:1|2|3|4|5|undef)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_case} eq '6') {
                            return ('auxp',10,);
                          } elsif ($h->{d_case} eq 'x') {
                            return ('obj',9,3);
                          } elsif ($h->{d_case} eq '7') {
                            return evalSubTree1_S2($h); # [S2]
                          }
                      }
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'c') {
                        return ('obj',23,7);
                      } elsif ($h->{g_subpos} eq 'u') {
                        return ('atr',24,);
                      } elsif ($h->{g_subpos} eq 'a') {
                          if ($h->{d_case} =~ /^(?:5|undef)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_case} eq '2') {
                            return ('obj',82,41);
                          } elsif ($h->{d_case} eq '3') {
                            return ('obj',43,10);
                          } elsif ($h->{d_case} eq 'x') {
                            return ('obj',16,6);
                          } elsif ($h->{d_case} eq '1') {
                              if ($h->{g_case} =~ /^(?:3|5|x|undef)$/) {
                                return ('exd',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('exd',18,10);
                              } elsif ($h->{g_case} eq '2') {
                                return ('adv',2,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('adv',4,2);
                              } elsif ($h->{g_case} eq '6') {
                                return ('obj',2,);
                              } elsif ($h->{g_case} eq '7') {
                                return ('exd',2,);
                              }
                          } elsif ($h->{d_case} eq '4') {
                              if ($h->{g_case} =~ /^(?:5|7|x|undef)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('adv',35,18);
                              } elsif ($h->{g_case} eq '2') {
                                return ('obj',13,);
                              } elsif ($h->{g_case} eq '3') {
                                return ('adv_ap',2,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('adv',16,9);
                              } elsif ($h->{g_case} eq '6') {
                                return ('adv',7,2);
                              }
                          } elsif ($h->{d_case} eq '6') {
                              if ($h->{g_case} =~ /^(?:3|5|6|7|x|undef)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('adv',19,7);
                              } elsif ($h->{g_case} eq '2') {
                                return ('obj',9,4);
                              } elsif ($h->{g_case} eq '4') {
                                return ('obj',2,);
                              }
                          } elsif ($h->{d_case} eq '7') {
                              if ($h->{g_case} =~ /^(?:5|undef)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('adv',77,33);
                              } elsif ($h->{g_case} eq '2') {
                                return ('obj',56,23);
                              } elsif ($h->{g_case} eq '3') {
                                return ('adv',1,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('adv',35,17);
                              } elsif ($h->{g_case} eq '6') {
                                return ('adv',28,12);
                              } elsif ($h->{g_case} eq '7') {
                                return ('adv',27,13);
                              } elsif ($h->{g_case} eq 'x') {
                                return ('atr',7,);
                              }
                          }
                      } elsif ($h->{g_subpos} eq 'g') {
                          if ($h->{d_case} =~ /^(?:5|undef)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_case} eq '1') {
                            return ('sb',2,);
                          } elsif ($h->{d_case} eq '2') {
                            return ('obj',47,15);
                          } elsif ($h->{d_case} eq '3') {
                            return ('adv',7,1);
                          } elsif ($h->{d_case} eq '4') {
                            return ('obj',95,6);
                          } elsif ($h->{d_case} eq '6') {
                            return ('adv',8,2);
                          } elsif ($h->{d_case} eq 'x') {
                            return ('adv',3,1);
                          } elsif ($h->{d_case} eq '7') {
                              if ($h->{g_case} =~ /^(?:3|5|7|x|undef)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('adv',13,6);
                              } elsif ($h->{g_case} eq '2') {
                                return ('obj',2,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('obj',6,);
                              } elsif ($h->{g_case} eq '6') {
                                return ('adv',8,2);
                              }
                          }
                      }
                  }
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{d_case} =~ /^(?:5|undef)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('obj',310,16);
                  } elsif ($h->{d_case} eq '6') {
                    return ('auxp',33,5);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('adv',33,10);
                      } elsif ($h->{g_subpos} eq 'c') {
                        return ('adv',4,2);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('obj',497,14);
                      } elsif ($h->{g_subpos} eq '2') {
                        return ('atr',1,);
                      } elsif ($h->{g_subpos} eq 'u') {
                        return ('atr',2,);
                      }
                  } elsif ($h->{d_case} eq '7') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'a') {
                        return ('obj',907,390);
                      } elsif ($h->{g_subpos} eq 'c') {
                        return ('obj',6,3);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('adv',84,39);
                      } elsif ($h->{g_subpos} eq 'u') {
                        return ('atr',1,);
                      }
                  } elsif ($h->{d_case} eq 'x') {
                      if ($h->{g_case} eq '5') {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atr',47,29);
                      } elsif ($h->{g_case} eq '2') {
                        return ('obj',19,10);
                      } elsif ($h->{g_case} eq '3') {
                        return ('adv',3,2);
                      } elsif ($h->{g_case} eq '4') {
                        return ('obj',14,8);
                      } elsif ($h->{g_case} eq '6') {
                        return ('obj',6,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('obj',4,2);
                      } elsif ($h->{g_case} eq 'x') {
                        return ('atr',115,6);
                      } elsif ($h->{g_case} eq 'undef') {
                        return ('atr',2,);
                      }
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_subpos} eq 'c') {
                        return ('sb',14,2);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('obj',6,2);
                      } elsif ($h->{g_subpos} eq '2') {
                        return ('atr',5,);
                      } elsif ($h->{g_subpos} eq 'u') {
                        return ('atr',11,3);
                      } elsif ($h->{g_subpos} eq 'a') {
                          if ($h->{g_case} =~ /^(?:5|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('atr',195,59);
                          } elsif ($h->{g_case} eq '2') {
                            return ('adv',22,14);
                          } elsif ($h->{g_case} eq '3') {
                            return ('obj',2,1);
                          } elsif ($h->{g_case} eq '4') {
                            return ('adv',19,11);
                          } elsif ($h->{g_case} eq '6') {
                            return ('adv',8,5);
                          } elsif ($h->{g_case} eq '7') {
                            return ('obj',4,2);
                          } elsif ($h->{g_case} eq 'x') {
                            return ('atr',121,22);
                          }
                      }
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|k|kdy¾|o|jít|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_lemma} eq 'zákon') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'rok') {
                        return ('adv',24,3);
                      } elsif ($h->{d_lemma} eq 'doba') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'trh') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'èlovìk') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_subpos} eq 'c') {
                            return ('obj',37,1);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('obj',64,10);
                          } elsif ($h->{g_subpos} eq 'u') {
                            return ('atr',8,);
                          } elsif ($h->{g_subpos} eq 'a') {
                              if ($h->{g_case} =~ /^(?:5|undef)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('obj',53,18);
                              } elsif ($h->{g_case} eq '2') {
                                return ('atr',38,15);
                              } elsif ($h->{g_case} eq '3') {
                                return ('obj',2,1);
                              } elsif ($h->{g_case} eq '4') {
                                return ('obj',10,3);
                              } elsif ($h->{g_case} eq '6') {
                                return ('obj',8,3);
                              } elsif ($h->{g_case} eq '7') {
                                return ('obj',8,3);
                              } elsif ($h->{g_case} eq 'x') {
                                return ('atr',12,2);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'd') {
          if ($h->{d_case} =~ /^(?:5|undef)$/) {
            return ('atr',0,);
          } elsif ($h->{d_case} eq 'x') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('atr',0,);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('sb',2,);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('exd',4,);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('atr',48,26);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('sb_ap',7,3);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('sb',4,1);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('adv',1,);
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('exd',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('sb',5,2);
                  } elsif ($h->{g_subpos} eq 'g') {
                      if ($h->{i_case} =~ /^(?:1|nic|x)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_case} eq '2') {
                        return ('adv',5,1);
                      } elsif ($h->{i_case} eq '3') {
                        return ('exd',1,);
                      } elsif ($h->{i_case} eq '4') {
                        return ('adv',1,);
                      } elsif ($h->{i_case} eq '6') {
                        return ('exd',8,1);
                      } elsif ($h->{i_case} eq '7') {
                        return ('adv',2,1);
                      } elsif ($h->{i_case} eq 'undef') {
                        return ('exd',6,1);
                      }
                  }
              }
          } elsif ($h->{d_case} eq '1') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('exd',0,);
              } elsif ($h->{g_subpos} eq 'b') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('sb_ap',2,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('sb',27,1);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('sb_ap',7,3);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('exd',7,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('sb',62,15);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('sb_ap',391,199);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('sb_ap',6,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('sb',32,6);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('sb',11,3);
                  }
              } elsif ($h->{g_subpos} eq 'g') {
                  if ($h->{i_voice} eq 'nic') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_lemma} eq 'hodnì') {
                        return ('exd_pa',2,1);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('sb',30,17);
                      }
                  } elsif ($h->{i_voice} eq 'undef') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('exd',279,23);
                      } elsif ($h->{i_pos} eq 'z') {
                        return evalSubTree1_S3($h); # [S3]
                      }
                  }
              }
          } elsif ($h->{d_case} eq '2') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                return ('atr',0,);
              } elsif ($h->{g_lemma} eq 'hodnì') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|t|f|x|i|spec_aster)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('adv',14,8);
                  } elsif ($h->{i_subpos} eq 'r') {
                    return ('adv',4,2);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                    return ('atr',4,1);
                  } elsif ($h->{i_subpos} eq 'nic') {
                    return ('atr',361,1);
                  } elsif ($h->{i_subpos} eq 'v') {
                    return ('adv',3,1);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('atr',43,3);
                  }
              } elsif ($h->{g_lemma} eq 'napøíklad') {
                  if ($h->{i_case} =~ /^(?:1|3|4|6|7|x)$/) {
                    return ('atr_ap',0,);
                  } elsif ($h->{i_case} eq '2') {
                    return ('adv_ap',7,2);
                  } elsif ($h->{i_case} eq 'nic') {
                    return ('atr_ap',26,6);
                  } elsif ($h->{i_case} eq 'undef') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'ale') {
                        return ('exd',3,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('atr',6,);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('atr',2,);
                      } elsif ($h->{i_lemma} eq 'èi') {
                        return ('adv',2,1);
                      }
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|t|f|x|i|spec_aster)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',12,);
                  } elsif ($h->{i_subpos} eq 'nic') {
                    return ('atr',552,242);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('atr',93,25);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('adv_ap',1,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('atr',5,1);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('adv_ap',3,1);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('atr',11,4);
                      }
                  } elsif ($h->{i_subpos} eq 'v') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('atr_ap',4,2);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('adv',5,1);
                      }
                  } elsif ($h->{i_subpos} eq 'r') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('adv',80,24);
                      } elsif ($h->{g_subpos} eq 'b') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_lemma} eq 'koruna') {
                            return ('exd',1,);
                          } elsif ($h->{d_lemma} eq 'rok') {
                            return ('atr_ap',4,1);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('adv',47,27);
                          } elsif ($h->{d_lemma} eq 'doba') {
                            return ('adv_ap',2,1);
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '3') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                return ('adv',0,);
              } elsif ($h->{g_lemma} eq 'hodnì') {
                return ('exd',8,2);
              } elsif ($h->{g_lemma} eq 'napøíklad') {
                return ('obj_ap',4,1);
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|¾e|od|spec_lpar|pro|mezi|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('exd',5,);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('adv',64,34);
                  } elsif ($h->{i_lemma} eq 'k') {
                    return ('adv',1,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('atr',2,);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('obj',2,);
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',54,16);
                      } elsif ($h->{i_pos} eq 'j') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('obj',14,5);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('adv',9,4);
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '4') {
              if ($h->{i_voice} eq 'nic') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('obj_ap',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('obj_ap',257,110);
                  } elsif ($h->{g_subpos} eq 'g') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'hodnì') {
                        return ('adv',4,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('obj',22,10);
                      }
                  }
              } elsif ($h->{i_voice} eq 'undef') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_subpos} eq 'g') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('adv',2,);
                      } elsif ($h->{i_lemma} eq 'jako') {
                        return ('exd',14,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('adv',249,69);
                      } elsif ($h->{i_lemma} eq 'o') {
                        return ('adv',1,);
                      }
                  } elsif ($h->{g_subpos} eq 'b') {
                      if ($h->{i_case} =~ /^(?:1|2|3|6|nic|7|x)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_case} eq '4') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('adv',90,56);
                          } elsif ($h->{g_lemma} eq 'napøíklad') {
                            return ('obj_ap',7,3);
                          }
                      } elsif ($h->{i_case} eq 'undef') {
                          if ($h->{i_subpos} =~ /^(?:spec_at|r|t|nic|f|v|x|i|spec_aster)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_subpos} eq 'spec_comma') {
                            return ('exd',2,);
                          } elsif ($h->{i_subpos} eq 'spec_head') {
                            return ('obj',53,15);
                          } elsif ($h->{i_subpos} eq 'spec_ddot') {
                            return evalSubTree1_S4($h); # [S4]
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '6') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'g') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                    return ('exd',0,);
                  } elsif ($h->{g_lemma} eq 'hodnì') {
                      if ($h->{i_case} =~ /^(?:1|2|3|4|7|x)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_case} eq '6') {
                        return ('exd',40,9);
                      } elsif ($h->{i_case} eq 'nic') {
                        return ('atr',5,);
                      } elsif ($h->{i_case} eq 'undef') {
                        return ('adv',4,1);
                      }
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|spec_ddot|t|f|x|i|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('exd',2,1);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('auxp',1,);
                      } elsif ($h->{i_subpos} eq 'v') {
                        return ('exd',9,3);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('obj',7,2);
                      } elsif ($h->{i_subpos} eq 'r') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_lemma} eq 'pøípad') {
                            return ('exd',7,2);
                          } elsif ($h->{d_lemma} eq 'rok') {
                            return ('exd',9,2);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('adv',105,52);
                          } elsif ($h->{d_lemma} eq 'doba') {
                            return ('exd',3,1);
                          }
                      }
                  }
              } elsif ($h->{g_subpos} eq 'b') {
                  if ($h->{i_case} =~ /^(?:1|2|4|7|x)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_case} eq '3') {
                    return ('auxp',1,);
                  } elsif ($h->{i_case} eq 'nic') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('atr',26,15);
                      } elsif ($h->{g_lemma} eq 'napøíklad') {
                        return ('adv_ap',4,1);
                      }
                  } elsif ($h->{i_case} eq 'undef') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('atr',5,1);
                      } elsif ($h->{i_pos} eq 'z') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('obj_ap',3,1);
                          } elsif ($h->{g_lemma} eq 'napøíklad') {
                            return ('atr',3,);
                          }
                      }
                  } elsif ($h->{i_case} eq '6') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_lemma} eq 'napøíklad') {
                        return ('atr_ap',15,7);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|firma|který|a|jiný|spec_lpar|podnikatel|pro|k|kdy¾|o|jít|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_lemma} eq 'pøípad') {
                            return ('adv_ap',1,);
                          } elsif ($h->{d_lemma} eq 'rok') {
                            return ('adv_ap',3,2);
                          } elsif ($h->{d_lemma} eq 'výroba') {
                            return ('atr_ap',1,);
                          } elsif ($h->{d_lemma} eq 'doba') {
                            return ('adv_ap',5,);
                          } elsif ($h->{d_lemma} eq 'trh') {
                            return ('adv',1,);
                          } elsif ($h->{d_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'r') {
                                return ('adv',143,80);
                              } elsif ($h->{i_subpos} eq 'v') {
                                return ('adv_ap',23,13);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '7') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('adv',0,);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('atr',4,);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('adv_ap',3,);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('auxp',1,);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('adv',3,1);
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'hodnì') {
                    return ('atr',2,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('adv',89,59);
                  } elsif ($h->{g_lemma} eq 'napøíklad') {
                    return ('obj_ap',4,2);
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('pnom',6,4);
                  } elsif ($h->{g_subpos} eq 'g') {
                    return ('obj_ap',2,);
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'hodnì') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('adv',12,5);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('exd',5,);
                      }
                  } elsif ($h->{g_lemma} eq 'napøíklad') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('obj',2,);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv_ap',3,2);
                      }
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_case} =~ /^(?:1|2|4|6|nic|x)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_case} eq '3') {
                        return ('auxp',1,);
                      } elsif ($h->{i_case} eq '7') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('adv',46,25);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return evalSubTree1_S5($h); # [S5]
                          }
                      } elsif ($h->{i_case} eq 'undef') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('exd',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('adv',10,2);
                          } elsif ($h->{g_subpos} eq 'g') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                                return ('exd',0,);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                return ('exd',17,1);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                return ('adv',3,1);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'v') {
          if ($h->{d_case} eq 'undef') {
            return ('sb',0,);
          } elsif ($h->{d_case} eq '5') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('exd_pa',0,);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('exd',4,2);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('exd_pa',46,7);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('exd',4,1);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('obj',2,);
              }
          } elsif ($h->{d_case} eq '3') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('adv',0,);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('adv',23,1);
              } elsif ($h->{g_lemma} eq 'být') {
                return ('adv',347,44);
              } elsif ($h->{g_lemma} eq 'mít') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('obj',2,1);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('adv_ap',2,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('adv',110,13);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('obj',3,);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('obj',2,);
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_pos} =~ /^(?:x|i)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_pos} eq 'nic') {
                    return ('obj',3488,176);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('obj',615,190);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('obj_ap',146,64);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('adv',3173,1305);
                  } elsif ($h->{i_pos} eq 't') {
                    return ('adv',3,2);
                  }
              } elsif ($h->{g_lemma} eq 'jít') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('adv',35,12);
                  } elsif ($h->{d_lemma} eq 'podnikatel') {
                    return ('obj',2,);
                  }
              }
          } elsif ($h->{d_case} eq '6') {
              if ($h->{i_case} =~ /^(?:1|x)$/) {
                return ('adv',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('adv',2,1);
              } elsif ($h->{i_case} eq '3') {
                return ('auxp',23,);
              } elsif ($h->{i_case} eq '6') {
                return ('adv',21885,2395);
              } elsif ($h->{i_case} eq 'nic') {
                return ('auxp',601,21);
              } elsif ($h->{i_case} eq '7') {
                return ('auxp',286,);
              } elsif ($h->{i_case} eq '4') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('obj',4,2);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('adv',3,1);
                  }
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|t|nic|f|v|x|i)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('adv',765,239);
                  } elsif ($h->{i_subpos} eq 'spec_aster') {
                    return ('adv',2,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('adv_ap',0,);
                      } elsif ($h->{i_lemma} eq 'jako') {
                        return ('adv_ap',4,1);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('adv',3,1);
                      } elsif ($h->{i_lemma} eq 'kdy¾') {
                        return ('exd',1,);
                      }
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('adv_ap',20,7);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('adv_ap',14,1);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('adv',123,52);
                      }
                  }
              }
          } elsif ($h->{d_case} eq '4') {
              if ($h->{i_case} =~ /^(?:3|x)$/) {
                return ('obj',0,);
              } elsif ($h->{i_case} eq '1') {
                return ('adv',2,1);
              } elsif ($h->{i_case} eq '2') {
                return ('auxp',86,);
              } elsif ($h->{i_case} eq '6') {
                return ('adv',16,1);
              } elsif ($h->{i_case} eq '7') {
                return ('adv',3,1);
              } elsif ($h->{i_case} eq '4') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('adv',196,47);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('adv',31,3);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('adv',8021,3262);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('obj',774,63);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('adv',651,43);
                  }
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|aby|tento|spec_quot|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|k|kdy¾|o|jít|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_lemma} eq 'zbo¾í') {
                    return ('obj',77,);
                  } elsif ($h->{d_lemma} eq 'pøípad') {
                    return ('obj',55,3);
                  } elsif ($h->{d_lemma} eq 'telefon') {
                    return ('obj',12,);
                  } elsif ($h->{d_lemma} eq 'podnik') {
                    return ('obj',21,1);
                  } elsif ($h->{d_lemma} eq 'koruna') {
                    return ('obj',12,);
                  } elsif ($h->{d_lemma} eq 'zákon') {
                    return ('obj',111,);
                  } elsif ($h->{d_lemma} eq 'rok') {
                    return ('adv',185,33);
                  } elsif ($h->{d_lemma} eq 'fax') {
                    return ('obj',5,);
                  } elsif ($h->{d_lemma} eq 'výroba') {
                    return ('obj',38,);
                  } elsif ($h->{d_lemma} eq 'firma') {
                    return ('obj',49,);
                  } elsif ($h->{d_lemma} eq 'podnikatel') {
                    return ('obj',16,);
                  } elsif ($h->{d_lemma} eq 'trh') {
                    return ('obj',37,);
                  } elsif ($h->{d_lemma} eq 'èlovìk') {
                    return ('obj',61,);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('obj',3037,17);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('adv',6,1);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('adv',62,14);
                      } elsif ($h->{g_lemma} eq 'muset') {
                          if ($h->{g_voice} eq 'p') {
                            return ('obj',0,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',6,1);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv',3,);
                          }
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',42,12);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',17505,509);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',6725,75);
                          }
                      }
                  } elsif ($h->{d_lemma} eq 'doba') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('obj',5,);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('adv',1,);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('adv',11,);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',3,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',56,19);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',17,4);
                          }
                      }
                  }
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|nic|f|v|x|i)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',29,10);
                  } elsif ($h->{i_subpos} eq 't') {
                    return ('obj',6,2);
                  } elsif ($h->{i_subpos} eq 'spec_aster') {
                    return ('obj',1,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('obj',260,15);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('obj',8,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('obj',3527,436);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('obj',139,1);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('adv',85,26);
                      }
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('obj_ap',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('obj_ap',101,4);
                      } elsif ($h->{i_lemma} eq 'spec_dot') {
                        return ('exd',4,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('obj_ap',234,34);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('obj',4,1);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('obj_ap',105,15);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('obj',403,125);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('obj',142,37);
                          } elsif ($h->{g_subpos} eq 'i') {
                            return ('obj',4,1);
                          } elsif ($h->{g_subpos} eq 's') {
                            return ('adv',9,2);
                          } elsif ($h->{g_subpos} eq 'p') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                                return ('obj_ap',0,);
                              } elsif ($h->{g_lemma} eq 'mít') {
                                return ('obj',1,);
                              } elsif ($h->{g_lemma} eq 'other') {
                                return ('obj_ap',137,68);
                              } elsif ($h->{g_lemma} eq 'být') {
                                return ('exd',2,);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq 'x') {
              if ($h->{i_pos} =~ /^(?:x|i)$/) {
                return ('sb',0,);
              } elsif ($h->{i_pos} eq 'r') {
                return ('adv',1079,120);
              } elsif ($h->{i_pos} eq 't') {
                return ('atr',6,);
              } elsif ($h->{i_pos} eq 'nic') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_lemma} eq 'kè') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('obj',6,1);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('pnom',2,);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('sb',98,17);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('sb',21,2);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('obj',2,1);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('sb',191,27);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'p') {
                            return ('sb',64,39);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('sb',1252,479);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',147,67);
                          }
                      }
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                    return ('sb',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',6,1);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_lemma} eq 'kè') {
                        return ('atr',4,);
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',10,6);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('sb',288,133);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',26,11);
                          }
                      }
                  }
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb_ap',0,);
                  } elsif ($h->{d_lemma} eq 'kè') {
                    return ('atr',3,);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('sb',118,68);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('sb',33,15);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                          if ($h->{g_voice} eq 'p') {
                            return ('sb_ap',7,3);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('sb_ap',163,57);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj_ap',9,1);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('atr',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('atr',8,2);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('obj_ap',1,);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('obj_ap',2,);
                              }
                          } elsif ($h->{g_lemma} eq 'být') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('atr',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('sb_ap',2,1);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('atr',2,);
                              }
                          }
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('sb',0,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                            return ('obj',2,1);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('obj',1,);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('sb',53,11);
                          } elsif ($h->{g_lemma} eq 'other') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                                return ('sb_ap',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('atr',41,27);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('adv',6,3);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('sb_ap',23,14);
                              } elsif ($h->{g_subpos} eq 's') {
                                return ('sb_ap',4,2);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '1') {
              if ($h->{i_subpos} =~ /^(?:f|v|x|i)$/) {
                return ('sb',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',180,41);
              } elsif ($h->{i_subpos} eq 'spec_at') {
                return ('sb',4,);
              } elsif ($h->{i_subpos} eq 't') {
                return ('sb',4,);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                return ('sb',6890,597);
              } elsif ($h->{i_subpos} eq 'spec_aster') {
                return ('sb',2,);
              } elsif ($h->{i_subpos} eq 'r') {
                  if ($h->{i_case} =~ /^(?:3|nic|undef)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_case} eq '2') {
                    return ('adv',2,);
                  } elsif ($h->{i_case} eq '4') {
                    return ('adv',9,5);
                  } elsif ($h->{i_case} eq '6') {
                    return ('adv',2,1);
                  } elsif ($h->{i_case} eq '7') {
                    return ('obj',2,);
                  } elsif ($h->{i_case} eq 'x') {
                    return ('sb',2,);
                  } elsif ($h->{i_case} eq '1') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('sb',7,3);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('exd_pa',2,1);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('sb',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('sb',2771,22);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('sb',671,5);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('sb',35454,557);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('sb',89,5);
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{g_voice} eq 'p') {
                        return ('sb',0,);
                      } elsif ($h->{g_voice} eq 'a') {
                        return ('sb',10352,1759);
                      } elsif ($h->{g_voice} eq 'undef') {
                        return ('pnom',104,9);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|k|kdy¾|o|jít|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb_ap',0,);
                  } elsif ($h->{d_lemma} eq 'pøípad') {
                    return ('sb_ap',1,);
                  } elsif ($h->{d_lemma} eq 'telefon') {
                    return ('sb',1,);
                  } elsif ($h->{d_lemma} eq 'podnik') {
                    return ('sb_ap',3,1);
                  } elsif ($h->{d_lemma} eq 'rok') {
                    return ('adv_ap',1,);
                  } elsif ($h->{d_lemma} eq 'fax') {
                    return ('atr',16,);
                  } elsif ($h->{d_lemma} eq 'výroba') {
                    return ('sb',2,);
                  } elsif ($h->{d_lemma} eq 'firma') {
                    return ('sb_ap',9,1);
                  } elsif ($h->{d_lemma} eq 'podnikatel') {
                    return ('sb_ap',5,);
                  } elsif ($h->{d_lemma} eq 'doba') {
                    return ('sb_ap',5,1);
                  } elsif ($h->{d_lemma} eq 'trh') {
                    return ('sb_ap',2,);
                  } elsif ($h->{d_lemma} eq 'zákon') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('sb_ap',2,);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('adv_ap',2,1);
                      }
                  } elsif ($h->{d_lemma} eq 'èlovìk') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('sb_ap',6,2);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('sb',2,);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('sb_ap',93,4);
                      } elsif ($h->{i_lemma} eq 'spec_dot') {
                        return ('sb',8,4);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('sb_ap',477,109);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('sb_ap',354,40);
                      } elsif ($h->{i_lemma} eq 'other') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                            return ('sb',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('sb',18,9);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('sb',1,);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('exd',5,1);
                          } elsif ($h->{g_subpos} eq 's') {
                            return ('sb',3,);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('sb_ap',0,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('sb_ap',11,);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('obj',5,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('sb_ap',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('sb_ap',37,11);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('sb_ap',6,3);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('sb',30,13);
                              }
                          } elsif ($h->{g_lemma} eq 'být') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('sb',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('sb',396,167);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('sb_ap',69,26);
                              }
                          } elsif ($h->{g_lemma} eq 'other') {
                              if ($h->{g_voice} eq 'p') {
                                return ('sb_ap',49,13);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('sb_ap',1284,636);
                              } elsif ($h->{g_voice} eq 'undef') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|e|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('sb_ap',0,);
                                  } elsif ($h->{g_subpos} eq 'f') {
                                    return ('sb_ap',29,16);
                                  } elsif ($h->{g_subpos} eq 'i') {
                                    return ('exd',10,);
                                  }
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '2') {
              if ($h->{i_case} =~ /^(?:1|3|x)$/) {
                return ('adv',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('adv',11719,1188);
              } elsif ($h->{i_case} eq '6') {
                return ('adv',2,1);
              } elsif ($h->{i_case} eq '7') {
                return ('adv',4,2);
              } elsif ($h->{i_case} eq '4') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('auxp',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('auxp',61,22);
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('auxp',5,2);
                      } elsif ($h->{g_subpos} eq 'f') {
                        return ('auxp',1,);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('adv',4,);
                      }
                  }
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('adv',2,);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('auxp',1,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('obj',14,4);
                      } elsif ($h->{g_subpos} eq 'f') {
                        return ('adv',2,1);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('adv',18,6);
                      }
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|k|kdy¾|o|jít|trh|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_lemma} eq 'pøípad') {
                        return ('sb',2,1);
                      } elsif ($h->{d_lemma} eq 'podnik') {
                        return ('sb',2,1);
                      } elsif ($h->{d_lemma} eq 'koruna') {
                        return ('obj',3,);
                      } elsif ($h->{d_lemma} eq 'rok') {
                        return ('adv',53,6);
                      } elsif ($h->{d_lemma} eq 'fax') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'výroba') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'firma') {
                        return ('obj',2,);
                      } elsif ($h->{d_lemma} eq 'podnikatel') {
                        return ('obj',4,1);
                      } elsif ($h->{d_lemma} eq 'doba') {
                        return ('obj',2,);
                      } elsif ($h->{d_lemma} eq 'èlovìk') {
                        return ('obj',11,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',115,54);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',1340,391);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',374,49);
                          }
                      }
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_lemma} eq 'rok') {
                        return ('pnom',1,);
                      } elsif ($h->{d_lemma} eq 'firma') {
                        return ('atr_ap',1,);
                      } elsif ($h->{d_lemma} eq 'èlovìk') {
                        return ('sb',2,);
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('pnom',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('pnom',155,109);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('sb',14,5);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('adv',28,16);
                          }
                      }
                  }
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_pos} =~ /^(?:nic|x|i|r)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_pos} eq 't') {
                    return ('atr',4,);
                  } elsif ($h->{i_pos} eq 'z') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|aby|ale|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'spec_dot') {
                        return ('obj_ap',2,);
                      } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                        return ('atr',24,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('atr',2,);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('adv_ap',48,27);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('obj_ap',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('obj_ap',10,3);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('atr',3,1);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('adv_ap',3,);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('obj',1,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('adv_ap',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('atr',3,1);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('sb_ap',2,);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv_ap',4,2);
                              }
                          } elsif ($h->{g_lemma} eq 'other') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj',69,43);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('obj_ap',16,9);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv',50,28);
                              } elsif ($h->{g_subpos} eq 's') {
                                return ('adv_ap',2,1);
                              }
                          } elsif ($h->{g_lemma} eq 'být') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('pnom',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('adv',22,15);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('pnom',8,3);
                              }
                          }
                      } elsif ($h->{i_lemma} eq 'undef') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('atr',0,);
                          } elsif ($h->{d_lemma} eq 'koruna') {
                            return ('atr',1,);
                          } elsif ($h->{d_lemma} eq 'rok') {
                            return ('atr',7,);
                          } elsif ($h->{d_lemma} eq 'firma') {
                            return ('obj_ap',1,);
                          } elsif ($h->{d_lemma} eq 'other') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                                return ('atr',0,);
                              } elsif ($h->{g_lemma} eq 'mít') {
                                return ('adv_ap',2,);
                              } elsif ($h->{g_lemma} eq 'být') {
                                return ('adv_ap',5,2);
                              } elsif ($h->{g_lemma} eq 'other') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('atr',0,);
                                  } elsif ($h->{g_subpos} eq 'b') {
                                    return ('atr',23,10);
                                  } elsif ($h->{g_subpos} eq 'f') {
                                    return ('obj_ap',4,2);
                                  } elsif ($h->{g_subpos} eq 'i') {
                                    return ('obj_ap',1,);
                                  } elsif ($h->{g_subpos} eq 'p') {
                                    return ('obj_ap',24,12);
                                  } elsif ($h->{g_subpos} eq 's') {
                                    return ('adv_ap',1,);
                                  }
                              }
                          }
                      }
                  } elsif ($h->{i_pos} eq 'j') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('atr',0,);
                          } elsif ($h->{i_lemma} eq 'jako') {
                            return ('exd',9,4);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('atr',46,1);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('obj',1,);
                          }
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                            return ('atr',26,8);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('adv',6,1);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return evalSubTree1_S6($h); # [S6]
                          } elsif ($h->{g_lemma} eq 'být') {
                            return evalSubTree1_S7($h); # [S7]
                          } elsif ($h->{g_lemma} eq 'other') {
                            return evalSubTree1_S8($h); # [S8]
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '7') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('adv',0,);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('adv',26,5);
              } elsif ($h->{g_lemma} eq 'jít') {
                return ('adv',70,8);
              } elsif ($h->{g_lemma} eq 'být') {
                  if ($h->{i_case} =~ /^(?:1|2|3|6|x)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{i_case} eq '4') {
                    return ('auxp',3,);
                  } elsif ($h->{i_case} eq 'nic') {
                    return ('pnom',3481,110);
                  } elsif ($h->{i_case} eq '7') {
                    return ('adv',396,34);
                  } elsif ($h->{i_case} eq 'undef') {
                    return ('pnom',316,123);
                  }
              } elsif ($h->{g_lemma} eq 'mít') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('auxp',2,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('adv',111,10);
                  } elsif ($h->{i_lemma} eq 'nic') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('auxp',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('adv',23,8);
                      } elsif ($h->{g_subpos} eq 'f') {
                        return ('auxp',1,);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('auxp',25,8);
                      }
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|spec_amperpercntspec_semicol|po|za|od|pro|mezi|k|pøi|kdy¾|o|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('adv_ap',19,7);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('adv',99,35);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('adv',47,16);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('adv_ap',31,13);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('adv_ap',3,2);
                  } elsif ($h->{i_lemma} eq '¾e') {
                    return ('exd',2,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('adv',178,108);
                  } elsif ($h->{i_lemma} eq 's') {
                    return ('obj',1,);
                  } elsif ($h->{i_lemma} eq 'v¹ak') {
                    return ('adv',1,);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('adv',69,24);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                      if ($h->{g_voice} eq 'p') {
                        return ('obj_ap',12,2);
                      } elsif ($h->{g_voice} eq 'a') {
                        return ('adv_ap',17,6);
                      } elsif ($h->{g_voice} eq 'undef') {
                        return ('obj_ap',3,1);
                      }
                  } elsif ($h->{i_lemma} eq 'nic') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|aby|tento|spec_quot|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|k|kdy¾|o|jít|trh|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_lemma} eq 'pøípad') {
                        return ('obj',14,1);
                      } elsif ($h->{d_lemma} eq 'telefon') {
                        return ('obj',1,);
                      } elsif ($h->{d_lemma} eq 'podnik') {
                        return ('adv',2,1);
                      } elsif ($h->{d_lemma} eq 'koruna') {
                        return ('adv',3,1);
                      } elsif ($h->{d_lemma} eq 'zákon') {
                        return ('adv',32,7);
                      } elsif ($h->{d_lemma} eq 'rok') {
                        return ('adv',13,1);
                      } elsif ($h->{d_lemma} eq 'fax') {
                        return ('adv',2,);
                      } elsif ($h->{d_lemma} eq 'výroba') {
                        return ('adv',3,1);
                      } elsif ($h->{d_lemma} eq 'firma') {
                        return ('obj',4,);
                      } elsif ($h->{d_lemma} eq 'podnikatel') {
                        return ('obj',4,);
                      } elsif ($h->{d_lemma} eq 'doba') {
                        return ('adv',14,1);
                      } elsif ($h->{d_lemma} eq 'èlovìk') {
                        return ('obj',3,);
                      } elsif ($h->{d_lemma} eq 'zbo¾í') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',2,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',1,);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',5,1);
                          }
                      } elsif ($h->{d_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'p') {
                            return ('obj',987,420);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',2982,1183);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv',814,286);
                          }
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_case} =~ /^(?:1|6|nic|x)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_case} eq '3') {
                        return ('auxp',15,);
                      } elsif ($h->{i_case} eq '4') {
                        return ('auxp',21,);
                      } elsif ($h->{i_case} eq '2') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('auxp',2,);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('exd',1,);
                          } elsif ($h->{g_subpos} eq 's') {
                            return ('adv',2,);
                          }
                      } elsif ($h->{i_case} eq '7') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',259,76);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',3257,1091);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',783,389);
                          }
                      } elsif ($h->{i_case} eq 'undef') {
                          if ($h->{i_pos} =~ /^(?:nic|x|i|r)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_pos} eq 'z') {
                            return ('obj_ap',2,);
                          } elsif ($h->{i_pos} eq 't') {
                            return ('obj',4,);
                          } elsif ($h->{i_pos} eq 'j') {
                            return evalSubTree1_S9($h); # [S9]
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'p') {
      if ($h->{g_pos} eq 'c') {
          if ($h->{d_case} =~ /^(?:5|undef)$/) {
            return ('atr',0,);
          } elsif ($h->{d_case} eq '1') {
            return ('atr',5,3);
          } elsif ($h->{d_case} eq '2') {
            return ('atr',311,11);
          } elsif ($h->{d_case} eq '3') {
            return ('atr',2,1);
          } elsif ($h->{d_case} eq 'x') {
            return ('atr',6,);
          } elsif ($h->{d_case} eq '4') {
              if ($h->{g_case} =~ /^(?:1|2|3|5|6|7|x)$/) {
                return ('auxy',0,);
              } elsif ($h->{g_case} eq '4') {
                return ('atr',4,1);
              } elsif ($h->{g_case} eq 'undef') {
                return ('auxy',5,);
              }
          } elsif ($h->{d_case} eq '6') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|7|u|v|w|x|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{d_subpos} eq '6') {
                return ('atr',3,1);
              } elsif ($h->{d_subpos} eq '8') {
                return ('atr',1,);
              } elsif ($h->{d_subpos} eq '9') {
                return ('adv',2,);
              }
          } elsif ($h->{d_case} eq '7') {
              if ($h->{i_voice} eq 'nic') {
                return ('atr',4,1);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('adv',9,2);
              }
          }
      } elsif ($h->{g_pos} eq 'z') {
          if ($h->{i_subpos} =~ /^(?:spec_at|f|x|spec_aster)$/) {
            return ('exd',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('exd',4,1);
          } elsif ($h->{i_subpos} eq 'r') {
            return ('exd',148,23);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
            return ('exd',103,36);
          } elsif ($h->{i_subpos} eq 't') {
            return ('exd',1,);
          } elsif ($h->{i_subpos} eq 'nic') {
            return ('exd',110,7);
          } elsif ($h->{i_subpos} eq 'v') {
            return ('exd',1,);
          } elsif ($h->{i_subpos} eq 'i') {
            return ('atr',1,);
          } elsif ($h->{i_subpos} eq 'spec_head') {
              if ($h->{d_case} =~ /^(?:6|undef)$/) {
                return ('exd',0,);
              } elsif ($h->{d_case} eq '2') {
                return ('exd',4,1);
              } elsif ($h->{d_case} eq '3') {
                return ('obj',5,2);
              } elsif ($h->{d_case} eq '5') {
                return ('exd',1,);
              } elsif ($h->{d_case} eq '7') {
                return ('exd',22,7);
              } elsif ($h->{d_case} eq 'x') {
                return ('exd',1,);
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_lemma} eq 'tento') {
                    return ('sb',1,);
                  } elsif ($h->{d_lemma} eq 'nìkterý') {
                    return ('exd',3,1);
                  } elsif ($h->{d_lemma} eq 'ten') {
                    return ('sb',68,21);
                  } elsif ($h->{d_lemma} eq 'v¹echen') {
                    return ('sb',7,3);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('exd',48,17);
                  } elsif ($h->{d_lemma} eq 'který') {
                    return ('sb',2,);
                  } elsif ($h->{d_lemma} eq 'já') {
                    return ('exd',29,11);
                  }
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|i|j|k|spec_aster|m|n|o|spec_comma|1|2|r|5|t|u|v|9|x|y)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('exd',8,2);
                  } elsif ($h->{d_subpos} eq 'h') {
                    return ('obj',1,);
                  } elsif ($h->{d_subpos} eq 'l') {
                    return ('obj',1,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('obj',8,);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('exd',16,);
                  } elsif ($h->{d_subpos} eq '4') {
                    return ('exd',4,1);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('exd',2,);
                  } elsif ($h->{d_subpos} eq '6') {
                    return ('exd',1,);
                  } elsif ($h->{d_subpos} eq '7') {
                    return ('auxr',17,5);
                  } elsif ($h->{d_subpos} eq '8') {
                    return ('exd',1,);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('exd',4,);
                  } elsif ($h->{d_subpos} eq 'z') {
                    return ('obj',1,);
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'n') {
          if ($h->{i_pos} =~ /^(?:x|i)$/) {
            return ('atr',0,);
          } elsif ($h->{i_pos} eq 'r') {
            return ('atr',771,115);
          } elsif ($h->{i_pos} eq 't') {
            return ('atr',4,1);
          } elsif ($h->{i_pos} eq 'z') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                return ('atr',0,);
              } elsif ($h->{d_lemma} eq 'tento') {
                return ('atr',2,);
              } elsif ($h->{d_lemma} eq 'nìkterý') {
                return ('atr',2,1);
              } elsif ($h->{d_lemma} eq 'ten') {
                return ('atr_ap',13,7);
              } elsif ($h->{d_lemma} eq 'other') {
                return ('atr',21,8);
              } elsif ($h->{d_lemma} eq 'který') {
                return ('sb',18,1);
              } elsif ($h->{d_lemma} eq 'já') {
                return ('atr_ap',3,);
              } elsif ($h->{d_lemma} eq 'v¹echen') {
                  if ($h->{d_case} =~ /^(?:5|6|7|x|undef)$/) {
                    return ('atr_ap',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('exd_pa',3,2);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr_ap',3,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('adv_ap',2,1);
                  }
              }
          } elsif ($h->{i_pos} eq 'nic') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|i|spec_aster|m|n|o|spec_comma|2|r|t|u|v|x|y)$/) {
                return ('atr',0,);
              } elsif ($h->{d_subpos} eq 'e') {
                return ('adv',1,);
              } elsif ($h->{d_subpos} eq 'h') {
                return ('atr',8,);
              } elsif ($h->{d_subpos} eq 'j') {
                return ('atr',122,4);
              } elsif ($h->{d_subpos} eq 'k') {
                return ('atr',1,);
              } elsif ($h->{d_subpos} eq '1') {
                return ('atr',460,9);
              } elsif ($h->{d_subpos} eq 'p') {
                return ('atr',77,5);
              } elsif ($h->{d_subpos} eq '4') {
                return ('atr',423,7);
              } elsif ($h->{d_subpos} eq 's') {
                return ('atr',6336,15);
              } elsif ($h->{d_subpos} eq '5') {
                return ('atr',1,);
              } elsif ($h->{d_subpos} eq '7') {
                return ('atr',59,8);
              } elsif ($h->{d_subpos} eq '8') {
                return ('atr',3441,5);
              } elsif ($h->{d_subpos} eq 'w') {
                return ('atr',546,);
              } elsif ($h->{d_subpos} eq '9') {
                return ('atr',1,);
              } elsif ($h->{d_subpos} eq 'z') {
                return ('atr',1541,7);
              } elsif ($h->{d_subpos} eq 'q') {
                  if ($h->{d_case} =~ /^(?:3|5|6|x|undef)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('exd',2,1);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr',3,1);
                  } elsif ($h->{d_case} eq '4') {
                    return ('exd',2,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('adv',5,1);
                  }
              } elsif ($h->{d_subpos} eq '6') {
                  if ($h->{d_case} =~ /^(?:1|5|6|7|x|undef)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr',8,1);
                  } elsif ($h->{d_case} eq '3') {
                    return ('exd',2,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('obj',1,);
                  }
              } elsif ($h->{d_subpos} eq 'l') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_lemma} eq 'v¹echen') {
                    return ('atr',1047,8);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{d_case} =~ /^(?:5|undef)$/) {
                        return ('atv',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('atv',245,55);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',48,1);
                      } elsif ($h->{d_case} eq '3') {
                        return ('atr',3,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('atr',67,8);
                      } elsif ($h->{d_case} eq '6') {
                        return ('atr',20,1);
                      } elsif ($h->{d_case} eq '7') {
                        return ('atr',8,);
                      } elsif ($h->{d_case} eq 'x') {
                        return ('atr',4,1);
                      }
                  }
              } elsif ($h->{d_subpos} eq 'd') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_lemma} eq 'tento') {
                    return ('atr',4689,1);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('atr',1044,19);
                  } elsif ($h->{d_lemma} eq 'ten') {
                      if ($h->{d_case} =~ /^(?:5|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',320,21);
                      } elsif ($h->{d_case} eq '3') {
                        return ('atr',34,1);
                      } elsif ($h->{d_case} eq '6') {
                        return ('atr',143,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('atr',74,1);
                      } elsif ($h->{d_case} eq '1') {
                          if ($h->{g_case} =~ /^(?:5|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('atr',189,7);
                          } elsif ($h->{g_case} eq '2') {
                            return ('auxy',4,1);
                          } elsif ($h->{g_case} eq '3') {
                            return ('auxy',1,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('auxy',3,1);
                          } elsif ($h->{g_case} eq '6') {
                            return ('atr',2,1);
                          } elsif ($h->{g_case} eq '7') {
                            return ('auxy',9,2);
                          } elsif ($h->{g_case} eq 'x') {
                            return ('atr',1,);
                          }
                      } elsif ($h->{d_case} eq '4') {
                          if ($h->{g_case} =~ /^(?:5|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('atr',1,);
                          } elsif ($h->{g_case} eq '2') {
                            return ('auxy',19,);
                          } elsif ($h->{g_case} eq '3') {
                            return ('auxy',3,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('atr',198,16);
                          } elsif ($h->{g_case} eq '6') {
                            return ('auxy',14,1);
                          } elsif ($h->{g_case} eq '7') {
                            return ('auxy',10,);
                          } elsif ($h->{g_case} eq 'x') {
                            return ('auxy',1,);
                          }
                      }
                  }
              }
          } elsif ($h->{i_pos} eq 'j') {
              if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                return ('sb',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',7,3);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_lemma} eq 'tento') {
                    return ('atr',13,);
                  } elsif ($h->{d_lemma} eq 'nìkterý') {
                    return ('atr',7,1);
                  } elsif ($h->{d_lemma} eq 'v¹echen') {
                    return ('atr',19,5);
                  } elsif ($h->{d_lemma} eq 'já') {
                    return ('atr',8,2);
                  } elsif ($h->{d_lemma} eq 'který') {
                      if ($h->{d_case} =~ /^(?:2|3|5|6|x|undef)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('sb',372,1);
                      } elsif ($h->{d_case} eq '4') {
                        return ('obj',15,2);
                      } elsif ($h->{d_case} eq '7') {
                        return ('adv',3,1);
                      }
                  } elsif ($h->{d_lemma} eq 'ten') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('atr',5,3);
                      } elsif ($h->{i_lemma} eq 'ale') {
                        return ('auxy',3,1);
                      } elsif ($h->{i_lemma} eq 'èi') {
                        return ('atr',18,);
                      } elsif ($h->{i_lemma} eq 'other') {
                          if ($h->{d_case} =~ /^(?:5|6|x|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{d_case} eq '1') {
                            return ('auxy',5,2);
                          } elsif ($h->{d_case} eq '2') {
                            return ('atr',9,2);
                          } elsif ($h->{d_case} eq '3') {
                            return ('atr',3,);
                          } elsif ($h->{d_case} eq '4') {
                            return ('auxy',13,4);
                          } elsif ($h->{d_case} eq '7') {
                            return ('auxy',16,10);
                          }
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|i|spec_aster|m|n|o|spec_comma|1|2|r|t|u|v|9|x|y)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_subpos} eq 'd') {
                        return ('atr',30,4);
                      } elsif ($h->{d_subpos} eq 'h') {
                        return ('obj',2,);
                      } elsif ($h->{d_subpos} eq 'k') {
                        return ('atr',1,);
                      } elsif ($h->{d_subpos} eq 'l') {
                        return ('atr',2,1);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('atr',9,4);
                      } elsif ($h->{d_subpos} eq 'q') {
                        return ('exd',3,1);
                      } elsif ($h->{d_subpos} eq '4') {
                        return ('atr',3,1);
                      } elsif ($h->{d_subpos} eq 's') {
                        return ('atr',51,);
                      } elsif ($h->{d_subpos} eq '5') {
                        return ('atr',8,);
                      } elsif ($h->{d_subpos} eq '6') {
                        return ('atradv',2,1);
                      } elsif ($h->{d_subpos} eq '7') {
                        return ('auxr',10,3);
                      } elsif ($h->{d_subpos} eq '8') {
                        return ('atr',8,);
                      } elsif ($h->{d_subpos} eq 'w') {
                        return ('atr',4,);
                      } elsif ($h->{d_subpos} eq 'z') {
                        return ('atr',13,3);
                      } elsif ($h->{d_subpos} eq 'j') {
                          if ($h->{d_case} =~ /^(?:2|5|6|x|undef)$/) {
                            return ('sb',0,);
                          } elsif ($h->{d_case} eq '1') {
                            return ('sb',12,);
                          } elsif ($h->{d_case} eq '3') {
                            return ('adv',1,);
                          } elsif ($h->{d_case} eq '4') {
                            return ('obj',2,);
                          } elsif ($h->{d_case} eq '7') {
                            return ('adv',1,);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'a') {
          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|n|o|p|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
            return ('auxt',0,);
          } elsif ($h->{g_subpos} eq 'm') {
            return ('auxt',2,);
          } elsif ($h->{g_subpos} eq '2') {
            return ('atr',1,);
          } elsif ($h->{g_subpos} eq 'c') {
              if ($h->{d_case} =~ /^(?:5|6|x|undef)$/) {
                return ('auxt',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb',2,);
              } elsif ($h->{d_case} eq '2') {
                return ('obj',16,);
              } elsif ($h->{d_case} eq '4') {
                return ('obj',3,);
              } elsif ($h->{d_case} eq '7') {
                return ('obj',11,2);
              } elsif ($h->{d_case} eq '3') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|i|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|u|8|v|9|x|y|z)$/) {
                    return ('auxt',0,);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('adv',2,);
                  } elsif ($h->{d_subpos} eq 'h') {
                    return ('obj',2,);
                  } elsif ($h->{d_subpos} eq 'j') {
                    return ('obj',2,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('obj',2,);
                  } elsif ($h->{d_subpos} eq '7') {
                    return ('auxt',59,5);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('obj',1,);
                  }
              }
          } elsif ($h->{g_subpos} eq 'g') {
              if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                return ('auxt',0,);
              } elsif ($h->{i_pos} eq 'j') {
                return ('atr',3,);
              } elsif ($h->{i_pos} eq 'z') {
                return ('obj',1,);
              } elsif ($h->{i_pos} eq 'r') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_lemma} eq 'ten') {
                    return ('obj',10,3);
                  } elsif ($h->{d_lemma} eq 'v¹echen') {
                    return ('obj',2,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('adv',17,5);
                  } elsif ($h->{d_lemma} eq 'já') {
                    return ('adv',4,);
                  }
              } elsif ($h->{i_pos} eq 'nic') {
                  if ($h->{d_case} =~ /^(?:5|6|7|x|undef)$/) {
                    return ('auxt',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('atr',4,1);
                  } elsif ($h->{d_case} eq '2') {
                    return ('adv',2,1);
                  } elsif ($h->{d_case} eq '3') {
                    return ('obj',15,4);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|i|j|k|spec_aster|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|u|8|v|9|x|y)$/) {
                        return ('auxt',0,);
                      } elsif ($h->{d_subpos} eq 'h') {
                        return ('obj',2,);
                      } elsif ($h->{d_subpos} eq 'l') {
                        return ('obj',3,1);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('obj',4,);
                      } elsif ($h->{d_subpos} eq '7') {
                        return ('auxt',359,32);
                      } elsif ($h->{d_subpos} eq 'w') {
                        return ('obj',4,);
                      } elsif ($h->{d_subpos} eq 'z') {
                        return ('obj',2,);
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'a') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|x|i|spec_aster)$/) {
                return ('adv',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',27,2);
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                return ('exd',3,1);
              } elsif ($h->{i_subpos} eq 't') {
                return ('exd',1,);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('adv',3,1);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_lemma} eq 'ten') {
                    return ('adv',2,1);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('atr',5,);
                  } elsif ($h->{d_lemma} eq 'který') {
                    return ('sb',7,1);
                  } elsif ($h->{d_lemma} eq 'já') {
                    return ('adv',1,);
                  }
              } elsif ($h->{i_subpos} eq 'r') {
                  if ($h->{d_case} =~ /^(?:1|5|x|undef)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('adv',14,6);
                  } elsif ($h->{d_case} eq '7') {
                    return ('obj',26,9);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|i|j|k|spec_aster|m|n|o|spec_comma|1|2|r|s|t|7|u|8|v|9|x|y)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_subpos} eq 'd') {
                        return ('adv',35,11);
                      } elsif ($h->{d_subpos} eq 'h') {
                        return ('adv',1,);
                      } elsif ($h->{d_subpos} eq 'l') {
                        return ('adv',2,1);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('adv',6,2);
                      } elsif ($h->{d_subpos} eq 'q') {
                        return ('adv',2,);
                      } elsif ($h->{d_subpos} eq '4') {
                        return ('obj',5,);
                      } elsif ($h->{d_subpos} eq '5') {
                        return ('obj',8,2);
                      } elsif ($h->{d_subpos} eq '6') {
                        return ('adv',3,1);
                      } elsif ($h->{d_subpos} eq 'w') {
                        return ('adv',2,);
                      } elsif ($h->{d_subpos} eq 'z') {
                        return ('adv',17,2);
                      }
                  } elsif ($h->{d_case} eq '6') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_lemma} eq 'ten') {
                        return ('obj',5,2);
                      } elsif ($h->{d_lemma} eq 'v¹echen') {
                        return ('adv',1,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('adv',10,1);
                      } elsif ($h->{d_lemma} eq 'který') {
                        return ('obj',1,);
                      }
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|t|7|u|8|v|w|x|y|z)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('adv',39,19);
                      } elsif ($h->{d_subpos} eq '5') {
                        return ('atr',51,10);
                      } elsif ($h->{d_subpos} eq '6') {
                        return ('adv',6,);
                      } elsif ($h->{d_subpos} eq '9') {
                        return ('atr',14,3);
                      } elsif ($h->{d_subpos} eq 'd') {
                          if ($h->{g_case} =~ /^(?:2|3|5|7|x|undef)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('adv',10,5);
                          } elsif ($h->{g_case} eq '4') {
                            return ('atr',4,1);
                          } elsif ($h->{g_case} eq '6') {
                            return ('adv',1,);
                          }
                      }
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|i|k|spec_aster|m|n|o|spec_comma|1|2|r|5|t|u|v|9|x|y)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_subpos} eq 'h') {
                    return ('obj',5,);
                  } elsif ($h->{d_subpos} eq 'j') {
                    return ('obj',1,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('obj',58,4);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('adv',17,);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('atr',15,4);
                  } elsif ($h->{d_subpos} eq '6') {
                    return ('obj_pa',2,1);
                  } elsif ($h->{d_subpos} eq '7') {
                    return ('auxt',13,5);
                  } elsif ($h->{d_subpos} eq '8') {
                    return ('atr',19,6);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('obj',8,4);
                  } elsif ($h->{d_subpos} eq 'l') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_lemma} eq 'v¹echen') {
                        return ('atr',21,3);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('atv',9,);
                      }
                  } elsif ($h->{d_subpos} eq '4') {
                      if ($h->{d_case} =~ /^(?:2|4|5|6|7|x|undef)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('sb',2,);
                      } elsif ($h->{d_case} eq '3') {
                        return ('obj',3,);
                      }
                  } elsif ($h->{d_subpos} eq 'z') {
                      if ($h->{d_case} =~ /^(?:2|3|5|6|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('atr',3,1);
                      } elsif ($h->{d_case} eq '4') {
                        return ('atr',3,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('obj',4,);
                      }
                  } elsif ($h->{d_subpos} eq 'd') {
                      if ($h->{d_case} =~ /^(?:5|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('atr',20,5);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',10,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('atr',4,2);
                      } elsif ($h->{d_case} eq '6') {
                        return ('atr',1,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('adv',42,14);
                      } elsif ($h->{d_case} eq '3') {
                          if ($h->{g_case} =~ /^(?:2|5|6|7|x|undef)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('obj',3,);
                          } elsif ($h->{g_case} eq '3') {
                            return ('atr',4,1);
                          } elsif ($h->{g_case} eq '4') {
                            return ('obj',1,);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'd') {
          if ($h->{d_case} eq 'undef') {
            return ('auxy',0,);
          } elsif ($h->{d_case} eq '2') {
            return ('atr',70,25);
          } elsif ($h->{d_case} eq '3') {
            return ('exd',17,10);
          } elsif ($h->{d_case} eq '5') {
            return ('atr',2,);
          } elsif ($h->{d_case} eq '7') {
            return ('adv',116,9);
          } elsif ($h->{d_case} eq 'x') {
            return ('atr',1,);
          } elsif ($h->{d_case} eq '6') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'b') {
                return ('adv_ap',5,3);
              } elsif ($h->{g_subpos} eq 'g') {
                return ('adv',5,);
              }
          } elsif ($h->{d_case} eq '1') {
              if ($h->{i_subpos} =~ /^(?:spec_at|t|f|v|x|i|spec_aster)$/) {
                return ('exd',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',19,1);
              } elsif ($h->{i_subpos} eq 'r') {
                return ('exd',1,);
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                return ('sb_ap',2,);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                return ('sb',2,);
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|k|spec_aster|m|n|o|spec_comma|1|2|r|s|5|t|6|7|u|8|v|9|x|y)$/) {
                    return ('auxy',0,);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('auxy',25,10);
                  } elsif ($h->{d_subpos} eq 'l') {
                    return ('adv_ap',3,2);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('adv',4,1);
                  } elsif ($h->{d_subpos} eq '4') {
                    return ('sb',6,);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('atr',2,);
                  } elsif ($h->{d_subpos} eq 'z') {
                    return ('sb_ap',3,1);
                  } elsif ($h->{d_subpos} eq 'p') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('sb',2,);
                      } elsif ($h->{d_lemma} eq 'já') {
                        return ('sb_ap',2,);
                      }
                  }
              }
          } elsif ($h->{d_case} eq '4') {
              if ($h->{i_subpos} =~ /^(?:spec_at|spec_ddot|t|f|x|i|spec_aster)$/) {
                return ('adv',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',3,);
              } elsif ($h->{i_subpos} eq 'r') {
                return ('adv',63,8);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('auxy',1,);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                return ('auxy',2,);
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|i|j|k|spec_aster|m|n|o|spec_comma|1|2|r|s|5|t|6|u|8|v|w|9|x|y)$/) {
                    return ('auxy',0,);
                  } elsif ($h->{d_subpos} eq 'h') {
                    return ('atr',1,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('obj',1,);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('adv',9,1);
                  } elsif ($h->{d_subpos} eq '4') {
                    return ('obj',1,);
                  } elsif ($h->{d_subpos} eq '7') {
                    return ('auxr',3,1);
                  } elsif ($h->{d_subpos} eq 'z') {
                    return ('obj_ap',2,);
                  } elsif ($h->{d_subpos} eq 'l') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('adv_ap',2,1);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('adv',2,);
                      }
                  } elsif ($h->{d_subpos} eq 'd') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('auxy',0,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('atr',2,1);
                      } elsif ($h->{d_lemma} eq 'ten') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('auxy',29,5);
                          } elsif ($h->{g_lemma} eq 'napøíklad') {
                            return ('atr_ap',2,1);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'p') {
          if ($h->{i_subpos} =~ /^(?:spec_at|t|f|v|x|i|spec_aster)$/) {
            return ('atr',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('apos',2,1);
          } elsif ($h->{i_subpos} eq 'r') {
            return ('atr',111,11);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
            return ('sb',7,3);
          } elsif ($h->{i_subpos} eq 'spec_head') {
              if ($h->{d_case} =~ /^(?:5|6|7|x|undef)$/) {
                return ('sb',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb',41,4);
              } elsif ($h->{d_case} eq '2') {
                return ('atr',2,);
              } elsif ($h->{d_case} eq '3') {
                return ('exd',3,1);
              } elsif ($h->{d_case} eq '4') {
                return ('obj',10,3);
              }
          } elsif ($h->{i_subpos} eq 'nic') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|spec_aster|m|n|o|spec_comma|1|2|r|5|t|7|u|v|w|9|x|y)$/) {
                return ('atr',0,);
              } elsif ($h->{d_subpos} eq 'k') {
                return ('atr',1,);
              } elsif ($h->{d_subpos} eq 'p') {
                return ('obj',3,2);
              } elsif ($h->{d_subpos} eq 'q') {
                return ('exd',17,3);
              } elsif ($h->{d_subpos} eq '4') {
                return ('auxc',4,2);
              } elsif ($h->{d_subpos} eq 's') {
                return ('atr',6,);
              } elsif ($h->{d_subpos} eq '6') {
                return ('atr',2,1);
              } elsif ($h->{d_subpos} eq '8') {
                return ('atr',2,);
              } elsif ($h->{d_subpos} eq 'z') {
                return ('atr',1,);
              } elsif ($h->{d_subpos} eq 'd') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|trh|jít|1|napøíklad|já|èlovìk|být)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_lemma} eq 'v¹echen') {
                    return ('atr',24,);
                  } elsif ($h->{g_lemma} eq 'nìkterý') {
                    return ('auxy',1,);
                  } elsif ($h->{g_lemma} eq 'ten') {
                    return ('auxy',5,);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_lemma} eq 'ten') {
                        return ('auxy',3,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('atr',39,1);
                      }
                  }
              } elsif ($h->{d_subpos} eq 'l') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('atv',0,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('atv',92,11);
                  } elsif ($h->{d_lemma} eq 'v¹echen') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|èlovìk|být)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_lemma} eq 'tento') {
                        return ('atr',1,);
                      } elsif ($h->{g_lemma} eq 'který') {
                        return ('atv',2,);
                      } elsif ($h->{g_lemma} eq 'já') {
                        return ('atr',12,2);
                      } elsif ($h->{g_lemma} eq 'ten') {
                        return ('atr',51,10);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|l|m|n|o|2|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('atv',0,);
                          } elsif ($h->{g_subpos} eq 'd') {
                            return ('atr',1,);
                          } elsif ($h->{g_subpos} eq 'k') {
                            return ('atr',2,);
                          } elsif ($h->{g_subpos} eq 'q') {
                            return ('atr',10,5);
                          } elsif ($h->{g_subpos} eq 'p') {
                              if ($h->{g_case} =~ /^(?:1|2|5|6|7|x|undef)$/) {
                                return ('atv',0,);
                              } elsif ($h->{g_case} eq '3') {
                                return ('atr',2,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('atv',9,1);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'v') {
          if ($h->{d_case} eq 'undef') {
            return ('obj',0,);
          } elsif ($h->{d_case} eq '5') {
            return ('sb_ap',2,1);
          } elsif ($h->{d_case} eq '2') {
              if ($h->{i_case} =~ /^(?:1|3|4|6|7|x)$/) {
                return ('adv',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('adv',1472,187);
              } elsif ($h->{i_case} eq 'undef') {
                return ('atr',34,18);
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',224,14);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',12,5);
                  }
              }
          } elsif ($h->{d_case} eq '1') {
              if ($h->{i_subpos} =~ /^(?:spec_at|f|v|x|i|spec_aster)$/) {
                return ('sb',0,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                return ('exd',15,1);
              } elsif ($h->{i_subpos} eq 'r') {
                return ('obj',3,2);
              } elsif ($h->{i_subpos} eq 't') {
                return ('sb',2,1);
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|h|i|j|spec_aster|m|n|o|spec_comma|2|r|5|t|6|7|u|8|v|9|x|y)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('sb',43,13);
                  } elsif ($h->{d_subpos} eq 'e') {
                    return ('sb',1,);
                  } elsif ($h->{d_subpos} eq 'l') {
                    return ('atr',17,6);
                  } elsif ($h->{d_subpos} eq '1') {
                    return ('atr',2,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('sb',32,3);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('exd',7,2);
                  } elsif ($h->{d_subpos} eq '4') {
                    return ('sb',9,1);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('atr',9,);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('sb',11,3);
                  } elsif ($h->{d_subpos} eq 'k') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('sb',14,3);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('exd',3,1);
                      }
                  } elsif ($h->{d_subpos} eq 'z') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_lemma} eq 'nìkterý') {
                        return ('atr',7,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('sb',13,1);
                      }
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|spec_aster|m|n|o|spec_comma|2|r|5|t|6|7|u|v|9|x|y)$/) {
                    return ('sb_ap',0,);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('sb_ap',43,8);
                  } elsif ($h->{d_subpos} eq 'k') {
                    return ('sb',2,1);
                  } elsif ($h->{d_subpos} eq '1') {
                    return ('atr',1,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('sb_ap',19,6);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('sb_ap',5,1);
                  } elsif ($h->{d_subpos} eq '4') {
                    return ('sb',3,1);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('exd',5,1);
                  } elsif ($h->{d_subpos} eq '8') {
                    return ('obj',4,2);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('sb',2,1);
                  } elsif ($h->{d_subpos} eq 'l') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{d_lemma} eq 'v¹echen') {
                        return ('sb_ap',6,2);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('atv',2,);
                      }
                  } elsif ($h->{d_subpos} eq 'z') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('sb_ap',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('sb_ap',1,);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('sb_ap',1,);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('pnom_ap',5,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('sb_ap',0,);
                          } elsif ($h->{d_lemma} eq 'nìkterý') {
                            return ('sb',3,2);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('sb_ap',4,);
                          }
                      }
                  }
              } elsif ($h->{i_subpos} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('sb',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('sb',799,7);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('sb',124,8);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('sb',53,2);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|h|i|spec_aster|m|n|o|spec_comma|1|2|r|s|5|t|6|7|u|8|v|9|x|y)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_subpos} eq 'd') {
                        return ('sb',1630,66);
                      } elsif ($h->{d_subpos} eq 'e') {
                        return ('sb',210,);
                      } elsif ($h->{d_subpos} eq 'j') {
                        return ('sb',252,2);
                      } elsif ($h->{d_subpos} eq 'k') {
                        return ('sb',334,3);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('sb',332,9);
                      } elsif ($h->{d_subpos} eq 'q') {
                        return ('sb',280,11);
                      } elsif ($h->{d_subpos} eq '4') {
                        return ('sb',4167,8);
                      } elsif ($h->{d_subpos} eq 'w') {
                        return ('sb',296,6);
                      } elsif ($h->{d_subpos} eq 'z') {
                        return ('sb',319,11);
                      } elsif ($h->{d_subpos} eq 'l') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('sb',0,);
                          } elsif ($h->{d_lemma} eq 'v¹echen') {
                            return ('sb',206,3);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('atvv',173,3);
                          }
                      }
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{g_voice} eq 'p') {
                        return ('sb',0,);
                      } elsif ($h->{g_voice} eq 'undef') {
                        return ('pnom',40,2);
                      } elsif ($h->{g_voice} eq 'a') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('sb',0,);
                          } elsif ($h->{d_lemma} eq 'tento') {
                            return ('sb',9,2);
                          } elsif ($h->{d_lemma} eq 'nìkterý') {
                            return ('sb',15,2);
                          } elsif ($h->{d_lemma} eq 'ten') {
                            return ('sb',1766,230);
                          } elsif ($h->{d_lemma} eq 'v¹echen') {
                            return ('sb',99,14);
                          } elsif ($h->{d_lemma} eq 'který') {
                            return ('sb',613,1);
                          } elsif ($h->{d_lemma} eq 'já') {
                            return ('sb',33,);
                          } elsif ($h->{d_lemma} eq 'other') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|h|i|spec_aster|m|n|o|spec_comma|1|2|r|5|t|6|7|u|v|9|x|y)$/) {
                                return ('sb',0,);
                              } elsif ($h->{d_subpos} eq 'd') {
                                return ('pnom',57,14);
                              } elsif ($h->{d_subpos} eq 'e') {
                                return ('sb',230,);
                              } elsif ($h->{d_subpos} eq 'j') {
                                return ('sb',37,1);
                              } elsif ($h->{d_subpos} eq 'k') {
                                return ('sb',63,11);
                              } elsif ($h->{d_subpos} eq 'l') {
                                return ('atvv',19,2);
                              } elsif ($h->{d_subpos} eq 'p') {
                                return ('sb',40,4);
                              } elsif ($h->{d_subpos} eq 'q') {
                                return ('sb',159,38);
                              } elsif ($h->{d_subpos} eq '4') {
                                return ('pnom',89,6);
                              } elsif ($h->{d_subpos} eq 's') {
                                return ('pnom',3,);
                              } elsif ($h->{d_subpos} eq '8') {
                                return ('adv',1,);
                              } elsif ($h->{d_subpos} eq 'w') {
                                return ('sb',63,19);
                              } elsif ($h->{d_subpos} eq 'z') {
                                return ('sb',62,24);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '7') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('adv',0,);
              } elsif ($h->{g_lemma} eq 'mít') {
                return ('adv',70,2);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('adv',2,);
              } elsif ($h->{g_lemma} eq 'jít') {
                return ('adv',5,1);
              } elsif ($h->{g_lemma} eq 'být') {
                  if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('atr',8,4);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('pnom_ap',1,);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('adv',84,2);
                  } elsif ($h->{i_pos} eq 'nic') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('pnom',0,);
                      } elsif ($h->{d_lemma} eq 'tento') {
                        return ('adv',1,);
                      } elsif ($h->{d_lemma} eq 'v¹echen') {
                        return ('pnom',2,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('pnom',108,13);
                      } elsif ($h->{d_lemma} eq 'který') {
                        return ('pnom',12,);
                      } elsif ($h->{d_lemma} eq 'ten') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('adv',33,15);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('pnom',1,);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('pnom',2,);
                          }
                      }
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('adv',2,);
                  } elsif ($h->{i_pos} eq 'j') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_lemma} eq 'ten') {
                        return ('exd',12,7);
                      } elsif ($h->{d_lemma} eq 'v¹echen') {
                        return ('obj',2,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('atr',14,4);
                      }
                  } elsif ($h->{i_pos} eq 'nic') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|h|i|spec_aster|m|n|o|spec_comma|1|2|r|5|t|7|u|8|v|9|x|y)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_subpos} eq 'd') {
                        return ('adv',419,59);
                      } elsif ($h->{d_subpos} eq 'e') {
                        return ('adv',45,3);
                      } elsif ($h->{d_subpos} eq 'j') {
                        return ('adv',56,14);
                      } elsif ($h->{d_subpos} eq 'k') {
                        return ('obj',2,);
                      } elsif ($h->{d_subpos} eq 'l') {
                        return ('adv',1,);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('obj',56,21);
                      } elsif ($h->{d_subpos} eq '4') {
                        return ('adv',119,30);
                      } elsif ($h->{d_subpos} eq 's') {
                        return ('exd',1,);
                      } elsif ($h->{d_subpos} eq 'q') {
                          if ($h->{g_voice} eq 'p') {
                            return ('obj',4,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',15,6);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv',13,4);
                          }
                      } elsif ($h->{d_subpos} eq '6') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',0,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',2,);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',2,);
                          }
                      } elsif ($h->{d_subpos} eq 'w') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('adv',2,);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('adv',3,1);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('obj',1,);
                          } elsif ($h->{g_subpos} eq 's') {
                            return ('obj',8,1);
                          }
                      } elsif ($h->{d_subpos} eq 'z') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_lemma} eq 'nìkterý') {
                            return ('obj',2,);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('adv',9,3);
                          }
                      }
                  } elsif ($h->{i_pos} eq 'r') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|spec_aster|m|n|o|spec_comma|1|2|r|t|7|u|8|v|x|y)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_subpos} eq 'k') {
                        return ('obj',7,3);
                      } elsif ($h->{d_subpos} eq 's') {
                        return ('exd',1,);
                      } elsif ($h->{d_subpos} eq '6') {
                        return ('adv',47,2);
                      } elsif ($h->{d_subpos} eq 'w') {
                        return ('obj',3,);
                      } elsif ($h->{d_subpos} eq 'd') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('obj',76,21);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('obj',75,30);
                          } elsif ($h->{g_subpos} eq 'i') {
                            return ('obj',3,);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('adv',81,24);
                          } elsif ($h->{g_subpos} eq 's') {
                            return ('adv',8,4);
                          }
                      } elsif ($h->{d_subpos} eq 'l') {
                          if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_subpos} eq 'r') {
                            return ('adv',3,);
                          } elsif ($h->{i_subpos} eq 'v') {
                            return ('obj',8,2);
                          }
                      } elsif ($h->{d_subpos} eq 'q') {
                          if ($h->{g_voice} eq 'p') {
                            return ('obj',1,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',4,);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',6,);
                          }
                      } elsif ($h->{d_subpos} eq '4') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',2,1);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',48,15);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',7,1);
                          }
                      } elsif ($h->{d_subpos} eq '5') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',3,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',149,61);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',52,15);
                          }
                      } elsif ($h->{d_subpos} eq '9') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',5,1);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',56,24);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',11,2);
                          }
                      } elsif ($h->{d_subpos} eq 'z') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_lemma} eq 'nìkterý') {
                            return ('exd',3,1);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('obj',12,);
                          }
                      } elsif ($h->{d_subpos} eq 'p') {
                          if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_subpos} eq 'v') {
                            return ('obj',8,1);
                          } elsif ($h->{i_subpos} eq 'r') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj',13,6);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('obj',6,1);
                              } elsif ($h->{g_subpos} eq 'i') {
                                return ('adv',2,);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv',16,4);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq 'x') {
              if ($h->{i_voice} eq 'nic') {
                  if ($h->{g_voice} eq 'p') {
                    return ('sb',0,);
                  } elsif ($h->{g_voice} eq 'undef') {
                    return ('atr',2,);
                  } elsif ($h->{g_voice} eq 'a') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|2|q|r|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_subpos} eq '1') {
                        return ('adv',1,);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('sb',1,);
                      } elsif ($h->{d_subpos} eq '4') {
                        return ('sb',30,5);
                      } elsif ($h->{d_subpos} eq 's') {
                        return ('pnom',2,);
                      }
                  }
              } elsif ($h->{i_voice} eq 'undef') {
                  if ($h->{i_case} =~ /^(?:1|3|4|nic|7)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_case} eq '2') {
                    return ('atr',2,);
                  } elsif ($h->{i_case} eq '6') {
                    return ('adv',1,);
                  } elsif ($h->{i_case} eq 'x') {
                    return ('adv',1,);
                  } elsif ($h->{i_case} eq 'undef') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('atr',34,);
                      } elsif ($h->{i_pos} eq 'z') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('atr',0,);
                          } elsif ($h->{d_subpos} eq 'p') {
                            return ('obj_ap',2,);
                          } elsif ($h->{d_subpos} eq 's') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                                return ('atr',0,);
                              } elsif ($h->{g_lemma} eq 'mít') {
                                return ('sb',2,);
                              } elsif ($h->{g_lemma} eq 'other') {
                                return ('atr',5,1);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '3') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('obj',0,);
              } elsif ($h->{g_lemma} eq 'mít') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('adv',28,2);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('obj',4,2);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('obj',1,);
                  }
              } elsif ($h->{g_lemma} eq 'muset') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('obj',3,);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('adv',7,);
                  }
              } elsif ($h->{g_lemma} eq 'jít') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('obj',32,6);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('adv',5,1);
                  }
              } elsif ($h->{g_lemma} eq 'být') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('obj_ap',1,);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('atr',3,1);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',62,5);
                      }
                  } elsif ($h->{i_lemma} eq 'nic') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_lemma} eq 'ten') {
                        return ('sb',90,3);
                      } elsif ($h->{d_lemma} eq 'v¹echen') {
                        return ('adv',1,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('obj',41,17);
                      } elsif ($h->{d_lemma} eq 'který') {
                        return ('adv',8,4);
                      } elsif ($h->{d_lemma} eq 'já') {
                        return ('adv',35,15);
                      }
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|i|spec_aster|m|n|o|spec_comma|1|2|r|t|u|v|x|y)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_subpos} eq 'e') {
                    return ('obj',9,);
                  } elsif ($h->{d_subpos} eq 'h') {
                    return ('obj',747,65);
                  } elsif ($h->{d_subpos} eq 'j') {
                    return ('obj',71,8);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('obj',15,2);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('atr',1,);
                  } elsif ($h->{d_subpos} eq '5') {
                    return ('adv',113,42);
                  } elsif ($h->{d_subpos} eq '8') {
                    return ('exd',1,);
                  } elsif ($h->{d_subpos} eq 'z') {
                    return ('obj',37,8);
                  } elsif ($h->{d_subpos} eq 'k') {
                      if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|t|f|x|i|spec_head|spec_aster)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_subpos} eq 'r') {
                        return ('obj',2,);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('exd',3,1);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('obj',26,3);
                      } elsif ($h->{i_subpos} eq 'v') {
                        return ('adv',1,);
                      }
                  } elsif ($h->{d_subpos} eq 'l') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|f|x|i|spec_aster)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('exd',1,);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('obj',20,);
                      } elsif ($h->{i_subpos} eq 'v') {
                        return ('adv',2,);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('obj',2,1);
                      }
                  } elsif ($h->{d_subpos} eq 'p') {
                      if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_pos} eq 'nic') {
                        return ('obj',1137,75);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('obj',10,1);
                      } elsif ($h->{i_pos} eq 'z') {
                        return ('obj_ap',3,);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',54,3);
                      }
                  } elsif ($h->{d_subpos} eq '6') {
                      if ($h->{i_pos} =~ /^(?:x|i|z|t)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_pos} eq 'nic') {
                        return ('obj',6,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('obj',4,1);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',15,2);
                      }
                  } elsif ($h->{d_subpos} eq '7') {
                      if ($h->{i_voice} eq 'nic') {
                        return ('auxt',2684,1447);
                      } elsif ($h->{i_voice} eq 'undef') {
                        return ('adv',3,);
                      }
                  } elsif ($h->{d_subpos} eq '9') {
                      if ($h->{g_voice} eq 'p') {
                        return ('adv',5,);
                      } elsif ($h->{g_voice} eq 'a') {
                        return ('adv',49,20);
                      } elsif ($h->{g_voice} eq 'undef') {
                        return ('obj',4,);
                      }
                  } elsif ($h->{d_subpos} eq 'd') {
                      if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_pos} eq 'nic') {
                        return ('obj',167,5);
                      } elsif ($h->{i_pos} eq 'z') {
                        return ('obj_ap',1,);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',315,121);
                      } elsif ($h->{i_pos} eq 'j') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('exd',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('atr',2,);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('exd',2,);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('exd',1,);
                          }
                      }
                  } elsif ($h->{d_subpos} eq 'w') {
                      if ($h->{i_voice} eq 'nic') {
                        return ('obj',22,1);
                      } elsif ($h->{i_voice} eq 'undef') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',0,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv',4,);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',3,1);
                          }
                      }
                  } elsif ($h->{d_subpos} eq '4') {
                      if ($h->{i_voice} eq 'nic') {
                        return ('obj',122,5);
                      } elsif ($h->{i_voice} eq 'undef') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('obj',2,);
                          } elsif ($h->{d_lemma} eq 'který') {
                              if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'r') {
                                return ('adv',4,);
                              } elsif ($h->{i_subpos} eq 'v') {
                                  if ($h->{g_voice} eq 'p') {
                                    return ('adv',2,);
                                  } elsif ($h->{g_voice} eq 'a') {
                                    return ('obj',19,7);
                                  } elsif ($h->{g_voice} eq 'undef') {
                                    return ('adv',3,1);
                                  }
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '6') {
              if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                return ('adv',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('atr',1,);
              } elsif ($h->{i_pos} eq 'j') {
                return ('atr',15,5);
              } elsif ($h->{i_pos} eq 'z') {
                return ('atr',1,);
              } elsif ($h->{i_pos} eq 'r') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('adv',60,3);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('adv',10,);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('adv',10,);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('adv',233,7);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'v') {
                        return ('adv',80,);
                      } elsif ($h->{i_subpos} eq 'r') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_lemma} eq 'tento') {
                            return ('adv',4,1);
                          } elsif ($h->{d_lemma} eq 'nìkterý') {
                            return ('adv',4,);
                          } elsif ($h->{d_lemma} eq 'ten') {
                            return ('obj',541,105);
                          } elsif ($h->{d_lemma} eq 'v¹echen') {
                            return ('obj',9,2);
                          } elsif ($h->{d_lemma} eq 'který') {
                            return ('adv',96,43);
                          } elsif ($h->{d_lemma} eq 'já') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj',11,4);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv',6,2);
                              }
                          } elsif ($h->{d_lemma} eq 'other') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|r|t|7|u|v|x|y)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_subpos} eq 'd') {
                                return ('obj',3,1);
                              } elsif ($h->{d_subpos} eq 'e') {
                                return ('obj',8,1);
                              } elsif ($h->{d_subpos} eq 'p') {
                                return ('obj',6,1);
                              } elsif ($h->{d_subpos} eq 'q') {
                                return ('obj',39,8);
                              } elsif ($h->{d_subpos} eq '4') {
                                return ('adv',8,1);
                              } elsif ($h->{d_subpos} eq 's') {
                                return ('exd',1,);
                              } elsif ($h->{d_subpos} eq '5') {
                                return ('adv',315,92);
                              } elsif ($h->{d_subpos} eq '8') {
                                return ('adv',7,3);
                              } elsif ($h->{d_subpos} eq 'w') {
                                return ('obj',17,7);
                              } elsif ($h->{d_subpos} eq '9') {
                                return ('adv',324,57);
                              } elsif ($h->{d_subpos} eq '6') {
                                  if ($h->{g_voice} eq 'p') {
                                    return ('adv',0,);
                                  } elsif ($h->{g_voice} eq 'a') {
                                    return ('adv',40,14);
                                  } elsif ($h->{g_voice} eq 'undef') {
                                    return ('obj',6,2);
                                  }
                              } elsif ($h->{d_subpos} eq 'z') {
                                  if ($h->{g_voice} eq 'p') {
                                    return ('adv',1,);
                                  } elsif ($h->{g_voice} eq 'a') {
                                    return ('obj',15,2);
                                  } elsif ($h->{g_voice} eq 'undef') {
                                    return ('adv',3,1);
                                  }
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{d_case} eq '4') {
              if ($h->{i_voice} eq 'nic') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|i|spec_aster|m|n|o|spec_comma|1|2|r|s|t|u|v|9|x|y)$/) {
                    return ('auxt',0,);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('obj',1221,43);
                  } elsif ($h->{d_subpos} eq 'e') {
                    return ('obj',52,);
                  } elsif ($h->{d_subpos} eq 'h') {
                    return ('obj',576,3);
                  } elsif ($h->{d_subpos} eq 'j') {
                    return ('obj',73,3);
                  } elsif ($h->{d_subpos} eq 'k') {
                    return ('obj',23,1);
                  } elsif ($h->{d_subpos} eq 'l') {
                    return ('obj',127,6);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('obj',1640,8);
                  } elsif ($h->{d_subpos} eq 'q') {
                    return ('obj',505,14);
                  } elsif ($h->{d_subpos} eq '4') {
                    return ('obj',1412,6);
                  } elsif ($h->{d_subpos} eq '5') {
                    return ('coord',1,);
                  } elsif ($h->{d_subpos} eq '6') {
                    return ('obj',25,3);
                  } elsif ($h->{d_subpos} eq '8') {
                    return ('obj',5,);
                  } elsif ($h->{d_subpos} eq 'w') {
                    return ('obj',252,7);
                  } elsif ($h->{d_subpos} eq 'z') {
                    return ('obj',238,7);
                  } elsif ($h->{d_subpos} eq '7') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('auxt',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('auxr',162,13);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('auxr',64,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('auxt',15262,4329);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('auxr',3,);
                      }
                  }
              } elsif ($h->{i_voice} eq 'undef') {
                  if ($h->{i_case} =~ /^(?:1|nic|x)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_case} eq '3') {
                    return ('auxy',4,);
                  } elsif ($h->{i_case} eq '6') {
                    return ('auxy',19,3);
                  } elsif ($h->{i_case} eq '7') {
                    return ('auxy',5,);
                  } elsif ($h->{i_case} eq '2') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|4|r|s|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('auxy',0,);
                      } elsif ($h->{d_subpos} eq 'd') {
                        return ('auxy',10,);
                      } elsif ($h->{d_subpos} eq 'q') {
                        return ('auxp',1,);
                      } elsif ($h->{d_subpos} eq '5') {
                        return ('adv',2,1);
                      }
                  } elsif ($h->{i_case} eq '4') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('adv',1,);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('obj',94,5);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('adv',176,12);
                      } elsif ($h->{g_lemma} eq 'mít') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|e|f|g|h|i|j|k|spec_aster|m|n|o|spec_comma|1|p|2|r|s|t|7|u|8|v|x|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_subpos} eq 'd') {
                            return ('obj',34,12);
                          } elsif ($h->{d_subpos} eq 'l') {
                            return ('adv',2,);
                          } elsif ($h->{d_subpos} eq 'q') {
                            return ('adv',1,);
                          } elsif ($h->{d_subpos} eq '4') {
                            return ('adv',6,2);
                          } elsif ($h->{d_subpos} eq '5') {
                            return ('obj',7,3);
                          } elsif ($h->{d_subpos} eq '6') {
                            return ('adv',1,);
                          } elsif ($h->{d_subpos} eq 'w') {
                            return ('adv',1,);
                          } elsif ($h->{d_subpos} eq '9') {
                            return ('adv',2,);
                          }
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|i|spec_aster|m|n|o|spec_comma|1|2|r|t|7|u|v|x|y)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_subpos} eq 'd') {
                            return ('obj',299,97);
                          } elsif ($h->{d_subpos} eq 'e') {
                            return ('obj',5,1);
                          } elsif ($h->{d_subpos} eq 'h') {
                            return ('adv',11,2);
                          } elsif ($h->{d_subpos} eq 'j') {
                            return ('adv',1,);
                          } elsif ($h->{d_subpos} eq 'k') {
                            return ('obj',5,1);
                          } elsif ($h->{d_subpos} eq 'l') {
                            return ('adv',18,6);
                          } elsif ($h->{d_subpos} eq 'p') {
                            return ('adv',60,18);
                          } elsif ($h->{d_subpos} eq 'q') {
                            return ('obj',37,9);
                          } elsif ($h->{d_subpos} eq 's') {
                            return ('obj',1,);
                          } elsif ($h->{d_subpos} eq '6') {
                            return ('adv',67,31);
                          } elsif ($h->{d_subpos} eq '8') {
                            return ('obj',17,1);
                          } elsif ($h->{d_subpos} eq 'w') {
                            return ('obj',11,3);
                          } elsif ($h->{d_subpos} eq '9') {
                            return ('obj',66,29);
                          } elsif ($h->{d_subpos} eq 'z') {
                            return ('obj',18,6);
                          } elsif ($h->{d_subpos} eq '5') {
                              if ($h->{g_voice} eq 'p') {
                                return ('adv',9,4);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('adv',184,86);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('obj',39,14);
                              }
                          } elsif ($h->{d_subpos} eq '4') {
                              if ($h->{g_voice} eq 'p') {
                                return ('adv',10,);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('obj',19,8);
                              } elsif ($h->{g_voice} eq 'a') {
                                return evalSubTree1_S10($h); # [S10]
                              }
                          }
                      }
                  } elsif ($h->{i_case} eq 'undef') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|nic|f|v|x|i|spec_aster)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('exd',5,2);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('obj_ap',56,23);
                      } elsif ($h->{i_subpos} eq 't') {
                        return ('atr',6,);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|f|g|i|spec_aster|m|n|o|spec_comma|1|2|r|t|u|v|9|x|y)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_subpos} eq 'e') {
                            return ('obj',1,);
                          } elsif ($h->{d_subpos} eq 'h') {
                            return ('obj',5,1);
                          } elsif ($h->{d_subpos} eq 'j') {
                            return ('obj',1,);
                          } elsif ($h->{d_subpos} eq 'k') {
                            return ('obj',1,);
                          } elsif ($h->{d_subpos} eq 'p') {
                            return ('obj',23,3);
                          } elsif ($h->{d_subpos} eq 'q') {
                            return ('obj',8,2);
                          } elsif ($h->{d_subpos} eq 's') {
                            return ('atr',5,1);
                          } elsif ($h->{d_subpos} eq '5') {
                            return ('obj',2,);
                          } elsif ($h->{d_subpos} eq '6') {
                            return ('obj',7,1);
                          } elsif ($h->{d_subpos} eq '8') {
                            return ('atr',23,1);
                          } elsif ($h->{d_subpos} eq 'w') {
                            return ('obj',4,1);
                          } elsif ($h->{d_subpos} eq '4') {
                              if ($h->{g_voice} eq 'p') {
                                return ('obj',0,);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('obj',5,1);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('atr',2,1);
                              }
                          } elsif ($h->{d_subpos} eq '7') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_lemma} eq 'mít') {
                                return ('atr',2,1);
                              } elsif ($h->{g_lemma} eq 'other') {
                                return ('obj',15,8);
                              } elsif ($h->{g_lemma} eq 'být') {
                                return ('auxr',1,);
                              }
                          } elsif ($h->{d_subpos} eq 'z') {
                            return evalSubTree1_S11($h); # [S11]
                          } elsif ($h->{d_subpos} eq 'd') {
                            return evalSubTree1_S12($h); # [S12]
                          } elsif ($h->{d_subpos} eq 'l') {
                              if ($h->{g_voice} eq 'p') {
                                return ('atr',0,);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('atr',5,);
                              } elsif ($h->{g_voice} eq 'a') {
                                return evalSubTree1_S13($h); # [S13]
                              }
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'd') {
      if ($h->{g_pos} eq 'c') {
          if ($h->{i_subpos} =~ /^(?:spec_at|f|v|x|i|spec_aster)$/) {
            return ('auxz',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('exd',2,);
          } elsif ($h->{i_subpos} eq 'r') {
            return ('adv',3,1);
          } elsif ($h->{i_subpos} eq 't') {
            return ('auxz',1,);
          } elsif ($h->{i_subpos} eq 'spec_head') {
            return ('adv',2,1);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|po|za|jako|other|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('exd',0,);
              } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                return ('atradv',2,1);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('exd',2,);
              }
          } elsif ($h->{i_subpos} eq 'nic') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                return ('auxz',0,);
              } elsif ($h->{d_subpos} eq 'b') {
                return ('auxz',964,169);
              } elsif ($h->{d_subpos} eq 'g') {
                  if ($h->{g_subpos} =~ /^(?:spec_rbrace|b|c|d|e|f|spec_hash|g|h|i|j|k|m|p|2|q|4|s|5|6|u|7|8|w|z)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{g_subpos} eq 'spec_qmark') {
                    return ('adv',1,);
                  } elsif ($h->{g_subpos} eq 'spec_eq') {
                    return ('auxz',146,55);
                  } elsif ($h->{g_subpos} eq 'a') {
                    return ('adv',11,3);
                  } elsif ($h->{g_subpos} eq 'n') {
                    return ('auxz',36,14);
                  } elsif ($h->{g_subpos} eq 'o') {
                    return ('adv',1,);
                  } elsif ($h->{g_subpos} eq 'r') {
                    return ('adv',5,);
                  } elsif ($h->{g_subpos} eq 'v') {
                    return ('adv',23,7);
                  } elsif ($h->{g_subpos} eq 'y') {
                    return ('auxz',10,1);
                  } elsif ($h->{g_subpos} eq 'l') {
                      if ($h->{g_case} =~ /^(?:3|5|6|x|undef)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('adv',10,2);
                      } elsif ($h->{g_case} eq '2') {
                        return ('adv',6,1);
                      } elsif ($h->{g_case} eq '4') {
                        return ('auxz',7,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('adv',8,2);
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'n') {
          if ($h->{i_case} =~ /^(?:1|x)$/) {
            return ('auxz',0,);
          } elsif ($h->{i_case} eq '2') {
            return ('apos',7,1);
          } elsif ($h->{i_case} eq '3') {
            return ('auxz',1,);
          } elsif ($h->{i_case} eq '6') {
            return ('coord',6,2);
          } elsif ($h->{i_case} eq '7') {
            return ('auxp',19,5);
          } elsif ($h->{i_case} eq '4') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|v¹ak|èi|do|ten|zákon|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                return ('atr',0,);
              } elsif ($h->{d_lemma} eq 'napøíklad') {
                return ('apos',1,);
              } elsif ($h->{d_lemma} eq 'hodnì') {
                return ('atr',17,5);
              } elsif ($h->{d_lemma} eq 'other') {
                return ('coord',7,2);
              }
          } elsif ($h->{i_case} eq 'nic') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|v¹ak|èi|do|ten|zákon|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                return ('auxz',0,);
              } elsif ($h->{d_lemma} eq 'napøíklad') {
                return ('auxz',357,72);
              } elsif ($h->{d_lemma} eq 'hodnì') {
                return ('atr',81,13);
              } elsif ($h->{d_lemma} eq 'other') {
                return ('auxz',5802,1059);
              }
          } elsif ($h->{i_case} eq 'undef') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|v¹ak|èi|do|ten|zákon|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                return ('adv',0,);
              } elsif ($h->{d_lemma} eq 'napøíklad') {
                return ('auxz',12,6);
              } elsif ($h->{d_lemma} eq 'hodnì') {
                  if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('atr',17,4);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('exd',6,3);
                  }
              } elsif ($h->{d_lemma} eq 'other') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|po|za|nic|od|pro|mezi|k|pøi|kdy¾|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('exd_ap',3,1);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('auxy',37,10);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',2,1);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('coord',2,1);
                  } elsif ($h->{i_lemma} eq '¾e') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq 'v¹ak') {
                    return ('auxy',4,1);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('exd',18,11);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                      if ($h->{g_case} =~ /^(?:3|5|7|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atr',8,3);
                      } elsif ($h->{g_case} eq '2') {
                        return ('adv',7,4);
                      } elsif ($h->{g_case} eq '4') {
                        return ('atr',7,4);
                      } elsif ($h->{g_case} eq '6') {
                        return ('adv',2,1);
                      } elsif ($h->{g_case} eq 'x') {
                        return ('atr',1,);
                      }
                  } elsif ($h->{i_lemma} eq 'undef') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('atr',0,);
                      } elsif ($h->{d_subpos} eq 'b') {
                        return ('auxz',6,3);
                      } elsif ($h->{d_subpos} eq 'g') {
                        return ('atr',18,5);
                      }
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('coord_ap',0,);
                      } elsif ($h->{d_subpos} eq 'b') {
                        return ('coord_ap',2,);
                      } elsif ($h->{d_subpos} eq 'g') {
                        return ('exd_ap',2,1);
                      }
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|telefon|èeský|zahranièní|malý|fax|02|v¹echen|nový|1994|mít|muset|výroba|kè|a|který|jiný|koruna|velký|obchodní|podnikatel|k|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_lemma} eq 'pøípad') {
                        return ('atr',1,);
                      } elsif ($h->{g_lemma} eq 'podnik') {
                        return ('auxz',2,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('atr',91,58);
                      } elsif ($h->{g_lemma} eq 'firma') {
                        return ('exd',2,);
                      } elsif ($h->{g_lemma} eq 'doba') {
                        return ('adv',2,);
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|nic|f|v|x)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('atr',1,);
                      } elsif ($h->{i_subpos} eq 'i') {
                        return ('adv',1,);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('adv',350,214);
                      } elsif ($h->{i_subpos} eq 'spec_aster') {
                        return ('auxz',1,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{d_subpos} eq 'b') {
                            return ('auxy',10,2);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('adv',2,);
                          }
                      } elsif ($h->{i_subpos} eq 't') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('auxz',0,);
                          } elsif ($h->{d_subpos} eq 'b') {
                            return ('auxz',9,2);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('coord',3,2);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'a') {
          if ($h->{i_subpos} =~ /^(?:spec_at|f|x|i|spec_aster)$/) {
            return ('adv',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('exd',43,7);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
            return ('adv',18,10);
          } elsif ($h->{i_subpos} eq 't') {
            return ('auxz',1,);
          } elsif ($h->{i_subpos} eq 'nic') {
            return ('adv',7082,572);
          } elsif ($h->{i_subpos} eq 'v') {
            return ('adv',2,1);
          } elsif ($h->{i_subpos} eq 'r') {
              if ($h->{i_case} =~ /^(?:1|3|nic|x|undef)$/) {
                return ('adv',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('auxp',2,);
              } elsif ($h->{i_case} eq '4') {
                return ('adv',10,);
              } elsif ($h->{i_case} eq '6') {
                return ('adv',2,1);
              } elsif ($h->{i_case} eq '7') {
                return ('auxp',5,1);
              }
          } elsif ($h->{i_subpos} eq 'spec_head') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{d_subpos} eq 'g') {
                return ('adv',116,2);
              } elsif ($h->{d_subpos} eq 'b') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('adv',8,2);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('exd',1,);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('auxz',1,);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{g_case} =~ /^(?:5|undef)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('auxz',8,3);
                      } elsif ($h->{g_case} eq '3') {
                        return ('auxy',1,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('obj',1,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('auxz',1,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('adv',2,);
                      } elsif ($h->{g_case} eq 'x') {
                        return ('auxy',1,);
                      } elsif ($h->{g_case} eq '1') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('auxz',0,);
                          } elsif ($h->{g_subpos} eq 'a') {
                            return ('adv',4,2);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('auxz',2,);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'z') {
          if ($h->{i_case} =~ /^(?:1|2|3|x)$/) {
            return ('exd',0,);
          } elsif ($h->{i_case} eq '4') {
            return ('exd',5,1);
          } elsif ($h->{i_case} eq '6') {
            return ('exd',1,);
          } elsif ($h->{i_case} eq 'nic') {
            return ('exd',699,137);
          } elsif ($h->{i_case} eq '7') {
            return ('auxp',12,);
          } elsif ($h->{i_case} eq 'undef') {
              if ($h->{i_pos} =~ /^(?:nic|x|r)$/) {
                return ('exd',0,);
              } elsif ($h->{i_pos} eq 'i') {
                return ('adv',1,);
              } elsif ($h->{i_pos} eq 'z') {
                return ('exd',498,73);
              } elsif ($h->{i_pos} eq 't') {
                return ('adv',16,9);
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|v¹ak|èi|do|ten|zákon|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_lemma} eq 'napøíklad') {
                    return ('auxy',10,6);
                  } elsif ($h->{d_lemma} eq 'hodnì') {
                    return ('exd',16,3);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('exd',30,15);
                      } elsif ($h->{i_lemma} eq 'aby') {
                        return ('auxz',1,);
                      } elsif ($h->{i_lemma} eq 'jako') {
                        return ('exd',1,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('exd',622,305);
                      } elsif ($h->{i_lemma} eq '¾e') {
                        return ('auxz',4,1);
                      } elsif ($h->{i_lemma} eq 'kdy¾') {
                        return ('auxz',3,);
                      } elsif ($h->{i_lemma} eq 'ale') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{d_subpos} eq 'b') {
                            return ('auxy',252,68);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('exd',51,9);
                          }
                      } elsif ($h->{i_lemma} eq 'v¹ak') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{d_subpos} eq 'b') {
                            return ('auxy',55,13);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('exd',16,6);
                          }
                      } elsif ($h->{i_lemma} eq 'èi') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_subpos} eq 'b') {
                            return ('auxz',5,3);
                          } elsif ($h->{d_subpos} eq 'g') {
                            return ('adv',7,3);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'p') {
          if ($h->{i_case} =~ /^(?:1|2|3|4|6|x)$/) {
            return ('auxz',0,);
          } elsif ($h->{i_case} eq '7') {
            return ('auxp',1,);
          } elsif ($h->{i_case} eq 'undef') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|h|i|j|k|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y)$/) {
                return ('exd',0,);
              } elsif ($h->{g_subpos} eq 'd') {
                return ('exd',60,26);
              } elsif ($h->{g_subpos} eq 'l') {
                return ('adv',3,1);
              } elsif ($h->{g_subpos} eq 'p') {
                return ('adv',3,1);
              } elsif ($h->{g_subpos} eq 'z') {
                return ('adv',1,);
              }
          } elsif ($h->{i_case} eq 'nic') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                return ('auxz',0,);
              } elsif ($h->{d_subpos} eq 'b') {
                return ('auxz',358,58);
              } elsif ($h->{d_subpos} eq 'g') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_lemma} eq 'hodnì') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('atr',13,3);
                      } elsif ($h->{g_lemma} eq 'ten') {
                        return ('exd',6,1);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|i|j|m|n|o|2|q|4|r|u|7|8|v|y)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'h') {
                        return ('atv',1,);
                      } elsif ($h->{g_subpos} eq 'k') {
                        return ('auxz',1,);
                      } elsif ($h->{g_subpos} eq 'l') {
                        return ('adv',23,11);
                      } elsif ($h->{g_subpos} eq 's') {
                        return ('adv',1,);
                      } elsif ($h->{g_subpos} eq '5') {
                        return ('adv',2,1);
                      } elsif ($h->{g_subpos} eq '6') {
                        return ('auxz',1,);
                      } elsif ($h->{g_subpos} eq 'z') {
                        return ('exd',4,2);
                      } elsif ($h->{g_subpos} eq 'w') {
                          if ($h->{g_case} =~ /^(?:2|3|5|7|x|undef)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('adv',2,);
                          } elsif ($h->{g_case} eq '4') {
                            return ('atr',7,4);
                          } elsif ($h->{g_case} eq '6') {
                            return ('auxz',1,);
                          }
                      } elsif ($h->{g_subpos} eq 'd') {
                          if ($h->{g_case} =~ /^(?:2|5|x|undef)$/) {
                            return ('auxz',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('auxz',6,3);
                          } elsif ($h->{g_case} eq '3') {
                            return ('coord',1,);
                          } elsif ($h->{g_case} eq '6') {
                            return ('coord',1,);
                          } elsif ($h->{g_case} eq '7') {
                            return ('exd',13,7);
                          } elsif ($h->{g_case} eq '4') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_lemma} eq 'other') {
                                return ('adv',3,);
                              } elsif ($h->{g_lemma} eq 'ten') {
                                return ('adv_ap',3,2);
                              }
                          }
                      } elsif ($h->{g_subpos} eq 'p') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|èlovìk|být|ten)$/) {
                            return ('auxz',0,);
                          } elsif ($h->{g_lemma} eq 'já') {
                            return ('atr',5,2);
                          } elsif ($h->{g_lemma} eq 'other') {
                              if ($h->{g_case} =~ /^(?:2|3|5|6|7|x|undef)$/) {
                                return ('auxz',0,);
                              } elsif ($h->{g_case} eq '1') {
                                return ('auxz',6,2);
                              } elsif ($h->{g_case} eq '4') {
                                return ('adv',3,2);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'd') {
          if ($h->{i_voice} eq 'nic') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'g') {
                return ('adv',1506,327);
              } elsif ($h->{g_subpos} eq 'b') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{g_lemma} eq 'napøíklad') {
                    return ('adv_ap',8,6);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('auxz',0,);
                      } elsif ($h->{d_subpos} eq 'b') {
                        return ('auxz',853,335);
                      } elsif ($h->{d_subpos} eq 'g') {
                        return ('adv',112,37);
                      }
                  }
              }
          } elsif ($h->{i_voice} eq 'undef') {
              if ($h->{i_case} =~ /^(?:1|2|3|6|nic|x)$/) {
                return ('exd',0,);
              } elsif ($h->{i_case} eq '4') {
                return ('adv',4,1);
              } elsif ($h->{i_case} eq '7') {
                return ('auxp',2,);
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|t|nic|f|v|x|i)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('exd',55,5);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                    return ('adv',10,4);
                  } elsif ($h->{i_subpos} eq 'spec_aster') {
                    return ('auxz',1,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_lemma} eq 'hodnì') {
                        return ('auxz',1,);
                      } elsif ($h->{g_lemma} eq 'napøíklad') {
                        return ('obj',3,2);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('exd',3,);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('adv',9,3);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('adv',6,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_subpos} eq 'b') {
                                return ('exd',4,2);
                              } elsif ($h->{d_subpos} eq 'g') {
                                return ('adv',4,);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'v') {
          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|v¹ak|èi|do|ten|zákon|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
            return ('adv',0,);
          } elsif ($h->{d_lemma} eq 'velký') {
            return ('adv',1,);
          } elsif ($h->{d_lemma} eq 'napøíklad') {
              if ($h->{i_case} =~ /^(?:1|3|x)$/) {
                return ('auxy',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('apos',5,);
              } elsif ($h->{i_case} eq '4') {
                return ('apos',6,);
              } elsif ($h->{i_case} eq '6') {
                return ('apos',3,);
              } elsif ($h->{i_case} eq 'nic') {
                return ('auxy',246,109);
              } elsif ($h->{i_case} eq '7') {
                return ('apos',1,);
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{g_voice} eq 'p') {
                    return ('auxy',2,);
                  } elsif ($h->{g_voice} eq 'a') {
                    return ('auxz',43,11);
                  } elsif ($h->{g_voice} eq 'undef') {
                    return ('auxy',5,2);
                  }
              }
          } elsif ($h->{d_lemma} eq 'hodnì') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|po|za|jako|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('adv',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('obj_ap',3,);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('obj',4,2);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('sb',1,);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('sb_ap',4,1);
              } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                return ('atr',1,);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('obj_ap',2,);
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                return ('obj_ap',15,11);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('adv',2,);
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('obj',9,);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('obj',5,);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('adv',10,2);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('obj',28,15);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',49,12);
                      }
                  }
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('obj',58,17);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('sb',4,1);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('adv',714,346);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('sb',2,1);
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('sb',95,51);
                      } elsif ($h->{g_subpos} eq 'f') {
                        return ('adv',2,);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('adv',21,11);
                      }
                  }
              }
          } elsif ($h->{d_lemma} eq 'other') {
              if ($h->{i_case} =~ /^(?:1|x)$/) {
                return ('adv',0,);
              } elsif ($h->{i_case} eq '4') {
                return ('adv',34,19);
              } elsif ($h->{i_case} eq 'nic') {
                return ('adv',35172,4817);
              } elsif ($h->{i_case} eq '7') {
                return ('auxp',216,12);
              } elsif ($h->{i_case} eq '2') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                    return ('auxp',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('adv',9,4);
                  } elsif ($h->{g_subpos} eq 'f') {
                    return ('apos',1,);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('auxp',7,2);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('auxp',1,);
                  }
              } elsif ($h->{i_case} eq '3') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('auxz',0,);
                  } elsif ($h->{d_subpos} eq 'b') {
                    return ('apos',4,2);
                  } elsif ($h->{d_subpos} eq 'g') {
                    return ('adv',4,2);
                  }
              } elsif ($h->{i_case} eq '6') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_subpos} eq 'g') {
                    return ('adv',4,1);
                  } elsif ($h->{d_subpos} eq 'b') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('coord',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('apos',6,4);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('coord',2,1);
                      }
                  }
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{i_pos} =~ /^(?:nic|x)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_pos} eq 'i') {
                    return ('adv',2,);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('auxz',1,);
                  } elsif ($h->{i_pos} eq 't') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('auxy',0,);
                      } elsif ($h->{d_subpos} eq 'g') {
                        return ('adv',3,);
                      } elsif ($h->{d_subpos} eq 'b') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('auxy',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('auxy',8,2);
                          } elsif ($h->{g_subpos} eq 'f') {
                            return ('auxz',4,2);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('auxz',5,2);
                          }
                      }
                  } elsif ($h->{i_pos} eq 'z') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('adv_ap',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('adv_ap',31,8);
                      } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                        return ('auxz',5,2);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('adv',2,1);
                      } elsif ($h->{i_lemma} eq 'undef') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('adv_ap',0,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                            return ('auxz',3,1);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('adv_ap',34,19);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('adv_ap',1,);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('auxz',7,4);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                          if ($h->{g_voice} eq 'p') {
                            return ('auxz',4,2);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('adv_ap',22,11);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv_ap',2,1);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('auxz',1,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('adv',219,142);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('obj',3,1);
                          } elsif ($h->{g_lemma} eq 'být') {
                              if ($h->{g_voice} eq 'p') {
                                return ('exd',0,);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('exd',33,23);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('adv',3,);
                              }
                          } elsif ($h->{g_lemma} eq 'mít') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('adv_ap',0,);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('adv_ap',1,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                    return ('obj',0,);
                                  } elsif ($h->{d_subpos} eq 'b') {
                                    return ('exd',4,2);
                                  } elsif ($h->{d_subpos} eq 'g') {
                                    return ('obj',3,2);
                                  }
                              } elsif ($h->{g_subpos} eq 'p') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                    return ('adv_ap',0,);
                                  } elsif ($h->{d_subpos} eq 'b') {
                                    return ('adv_ap',2,);
                                  } elsif ($h->{d_subpos} eq 'g') {
                                    return ('adv',3,1);
                                  }
                              }
                          }
                      }
                  } elsif ($h->{i_pos} eq 'j') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_subpos} eq 'g') {
                          if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_subpos} eq 'spec_head') {
                            return ('adv',589,127);
                          } elsif ($h->{i_subpos} eq 'spec_comma') {
                            return evalSubTree1_S14($h); # [S14]
                          }
                      } elsif ($h->{d_subpos} eq 'b') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('adv',50,23);
                          } elsif ($h->{i_lemma} eq 'aby') {
                            return ('coord',1,);
                          } elsif ($h->{i_lemma} eq 'jako') {
                            return ('exd',14,4);
                          } elsif ($h->{i_lemma} eq 'kdy¾') {
                            return ('auxz',26,8);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('auxz',58,36);
                          } elsif ($h->{i_lemma} eq '¾e') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('coord',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('coord',8,4);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('coord',3,1);
                              } elsif ($h->{g_subpos} eq 'i') {
                                return ('coord',2,1);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('exd',7,2);
                              }
                          } elsif ($h->{i_lemma} eq 'v¹ak') {
                              if ($h->{g_voice} eq 'p') {
                                return ('adv',1,);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('auxy',6,2);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('adv',2,1);
                              }
                          } elsif ($h->{i_lemma} eq 'ale') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                                return ('auxy',0,);
                              } elsif ($h->{g_lemma} eq 'mít') {
                                return ('auxz',2,);
                              } elsif ($h->{g_lemma} eq 'jít') {
                                return ('auxp',1,);
                              } elsif ($h->{g_lemma} eq 'být') {
                                return ('auxy',22,7);
                              } elsif ($h->{g_lemma} eq 'other') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('auxy',0,);
                                  } elsif ($h->{g_subpos} eq 'b') {
                                    return ('exd',19,9);
                                  } elsif ($h->{g_subpos} eq 'f') {
                                    return ('exd',5,3);
                                  } elsif ($h->{g_subpos} eq 'p') {
                                    return ('auxy',20,6);
                                  } elsif ($h->{g_subpos} eq 's') {
                                    return ('apos',1,);
                                  }
                              }
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                return ('auxy',64,19);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{g_lemma} eq 'muset') {
                                    return ('auxz',5,3);
                                  } elsif ($h->{g_lemma} eq 'jít') {
                                    return ('auxz',6,1);
                                  } elsif ($h->{g_lemma} eq 'být') {
                                    return ('adv',108,73);
                                  } elsif ($h->{g_lemma} eq 'mít') {
                                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                        return ('auxz',0,);
                                      } elsif ($h->{g_subpos} eq 'b') {
                                        return ('auxz',12,6);
                                      } elsif ($h->{g_subpos} eq 'f') {
                                        return ('adv',2,);
                                      } elsif ($h->{g_subpos} eq 'p') {
                                        return ('adv',9,6);
                                      }
                                  } elsif ($h->{g_lemma} eq 'other') {
                                      if ($h->{g_voice} eq 'p') {
                                        return ('auxz',43,21);
                                      } elsif ($h->{g_voice} eq 'a') {
                                        return ('adv',366,221);
                                      } elsif ($h->{g_voice} eq 'undef') {
                                        return ('adv',87,41);
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'v') {
      if ($h->{g_pos} eq 'c') {
          if ($h->{d_voice} eq 'a') {
            return ('atr',65,13);
          } elsif ($h->{d_voice} eq 'p') {
              if ($h->{g_case} =~ /^(?:2|3|5|6|7|x)$/) {
                return ('atv',0,);
              } elsif ($h->{g_case} eq '1') {
                return ('atr',3,1);
              } elsif ($h->{g_case} eq '4') {
                return ('atv',4,1);
              } elsif ($h->{g_case} eq 'undef') {
                return ('atv',6,1);
              }
          } elsif ($h->{d_voice} eq 'undef') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|c|d|e|f|spec_hash|g|h|i|j|k|m|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('atr',0,);
              } elsif ($h->{g_subpos} eq 'a') {
                return ('atr',2,);
              } elsif ($h->{g_subpos} eq 'l') {
                return ('atv',2,);
              } elsif ($h->{g_subpos} eq 'n') {
                return ('atr',1,);
              }
          }
      } elsif ($h->{g_pos} eq 'p') {
          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|e|f|spec_hash|g|i|m|n|o|2|r|5|6|u|7|v|y)$/) {
            return ('atr',0,);
          } elsif ($h->{g_subpos} eq 'h') {
            return ('obj',2,1);
          } elsif ($h->{g_subpos} eq 'j') {
            return ('atv',2,);
          } elsif ($h->{g_subpos} eq 'k') {
            return ('atr',3,1);
          } elsif ($h->{g_subpos} eq 's') {
            return ('atr',2,1);
          } elsif ($h->{g_subpos} eq '8') {
            return ('atr',1,);
          } elsif ($h->{g_subpos} eq 'z') {
            return ('atr',83,2);
          } elsif ($h->{g_subpos} eq 'l') {
              if ($h->{d_voice} eq 'p') {
                return ('atr',5,1);
              } elsif ($h->{d_voice} eq 'a') {
                return ('atr',76,);
              } elsif ($h->{d_voice} eq 'undef') {
                return ('exd',2,);
              }
          } elsif ($h->{g_subpos} eq 'p') {
              if ($h->{i_voice} eq 'nic') {
                return ('atr',24,2);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('adv_ap',2,);
              }
          } elsif ($h->{g_subpos} eq 'q') {
              if ($h->{i_voice} eq 'nic') {
                return ('adv',6,);
              } elsif ($h->{i_voice} eq 'undef') {
                return ('atv',2,1);
              }
          } elsif ($h->{g_subpos} eq '4') {
              if ($h->{d_voice} eq 'p') {
                return ('atv',11,1);
              } elsif ($h->{d_voice} eq 'a') {
                return ('atr',4,1);
              } elsif ($h->{d_voice} eq 'undef') {
                return ('atv',2,);
              }
          } elsif ($h->{g_subpos} eq 'd') {
              if ($h->{i_pos} =~ /^(?:x|i|r)$/) {
                return ('atr',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('atr',854,17);
              } elsif ($h->{i_pos} eq 'j') {
                return ('atr',1759,78);
              } elsif ($h->{i_pos} eq 't') {
                return ('atr',4,1);
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('atr_ap',13,);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('atr_ap',3,);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('atr',81,2);
                  } elsif ($h->{i_lemma} eq 'undef') {
                      if ($h->{g_case} =~ /^(?:1|2|3|5|x|undef)$/) {
                        return ('atr_ap',0,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('atr_ap',4,1);
                      } elsif ($h->{g_case} eq '6') {
                        return ('atr_ap',1,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('atr',2,);
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'w') {
              if ($h->{d_voice} eq 'p') {
                return ('atr',0,);
              } elsif ($h->{d_voice} eq 'a') {
                return ('atr',18,);
              } elsif ($h->{d_voice} eq 'undef') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('auxv',1,);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('atr',2,);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('adv',2,);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('exd',2,);
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'z') {
          if ($h->{i_subpos} =~ /^(?:spec_at|f|v|x|i|spec_aster)$/) {
            return ('pred',0,);
          } elsif ($h->{i_subpos} eq 'r') {
            return ('exd',1,);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
            return ('pred',7181,683);
          } elsif ($h->{i_subpos} eq 'nic') {
            return ('pred',41636,248);
          } elsif ($h->{i_subpos} eq 'spec_head') {
            return ('pred',17124,438);
          } elsif ($h->{i_subpos} eq 't') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
                return ('pred',0,);
              } elsif ($h->{d_lemma} eq 'mít') {
                return ('pred',6,3);
              } elsif ($h->{d_lemma} eq 'muset') {
                return ('pred',2,);
              } elsif ($h->{d_lemma} eq 'other') {
                return ('pred',50,18);
              } elsif ($h->{d_lemma} eq 'jít') {
                return ('exd',6,);
              } elsif ($h->{d_lemma} eq 'být') {
                return ('pred',25,12);
              }
          } elsif ($h->{i_subpos} eq 'spec_comma') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|ale|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('pred',0,);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('pred',259,123);
              } elsif ($h->{i_lemma} eq '¾e') {
                return ('exd',137,49);
              } elsif ($h->{i_lemma} eq 'jako') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('pred',0,);
                  } elsif ($h->{d_subpos} eq 'b') {
                    return ('exd',2,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('pred',24,10);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('exd',1,);
                  }
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_subpos} eq 'b') {
                    return ('pred',48,31);
                  } elsif ($h->{d_subpos} eq 'f') {
                    return ('exd',3,);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('adv',26,15);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('adv',1,);
                  }
              } elsif ($h->{i_lemma} eq 'aby') {
                  if ($h->{d_voice} eq 'p') {
                    return ('pred',0,);
                  } elsif ($h->{d_voice} eq 'undef') {
                    return ('exd',2,);
                  } elsif ($h->{d_voice} eq 'a') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
                        return ('pred',0,);
                      } elsif ($h->{d_lemma} eq 'mít') {
                        return ('exd',1,);
                      } elsif ($h->{d_lemma} eq 'muset') {
                        return ('exd',1,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('pred',24,12);
                      } elsif ($h->{d_lemma} eq 'být') {
                        return ('exd',6,3);
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'n') {
          if ($h->{d_case} =~ /^(?:1|2|3|5|6|7|x)$/) {
            return ('atr',0,);
          } elsif ($h->{d_case} eq '4') {
            return ('atv',13,);
          } elsif ($h->{d_case} eq 'undef') {
              if ($h->{i_pos} =~ /^(?:x|i)$/) {
                return ('atr',0,);
              } elsif ($h->{i_pos} eq 'nic') {
                return ('atr',11659,470);
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('atr_ap',20,6);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('atr_ap',39,19);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('atr',9,);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('atr_ap',19,5);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('atr',358,45);
                  }
              } elsif ($h->{i_pos} eq 'r') {
                  if ($h->{d_voice} eq 'p') {
                    return ('apos',0,);
                  } elsif ($h->{d_voice} eq 'a') {
                    return ('apos',11,4);
                  } elsif ($h->{d_voice} eq 'undef') {
                    return ('atr',3,);
                  }
              } elsif ($h->{i_pos} eq 't') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_lemma} eq 'mít') {
                    return ('adv',2,1);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('atr',13,5);
                  } elsif ($h->{d_lemma} eq 'být') {
                    return ('auxv',1,);
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|d|g|h|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_subpos} eq 'b') {
                    return ('atr',2044,96);
                  } elsif ($h->{d_subpos} eq 'c') {
                    return ('auxv',20,1);
                  } elsif ($h->{d_subpos} eq 'e') {
                    return ('exd',3,1);
                  } elsif ($h->{d_subpos} eq 'f') {
                    return ('atr',372,22);
                  } elsif ($h->{d_subpos} eq 'p') {
                    return ('atr',1342,68);
                  } elsif ($h->{d_subpos} eq 's') {
                    return ('atr',226,13);
                  } elsif ($h->{d_subpos} eq 'i') {
                      if ($h->{g_case} =~ /^(?:3|5|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('pred_pa',4,1);
                      } elsif ($h->{g_case} eq '2') {
                        return ('exd',1,);
                      } elsif ($h->{g_case} eq '6') {
                        return ('atr',3,);
                      } elsif ($h->{g_case} eq '7') {
                        return ('atr',5,);
                      } elsif ($h->{g_case} eq '4') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('atr',0,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('atr',2,);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('pred',3,2);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'a') {
          if ($h->{d_voice} eq 'p') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'c') {
                return ('obj',3,);
              } elsif ($h->{g_subpos} eq 'g') {
                return ('atr',3,1);
              } elsif ($h->{g_subpos} eq 'a') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('atr',5,1);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('adv',5,);
                  }
              }
          } elsif ($h->{d_voice} eq 'a') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|n|o|p|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'm') {
                return ('obj',1,);
              } elsif ($h->{g_subpos} eq '2') {
                return ('atr',1,);
              } elsif ($h->{g_subpos} eq 'u') {
                return ('atr',1,);
              } elsif ($h->{g_subpos} eq 'c') {
                  if ($h->{i_voice} eq 'undef') {
                    return ('obj',36,3);
                  } elsif ($h->{i_voice} eq 'nic') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
                        return ('auxv',0,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('obj',4,);
                      } elsif ($h->{d_lemma} eq 'být') {
                        return ('auxv',23,);
                      }
                  }
              } elsif ($h->{g_subpos} eq 'g') {
                  if ($h->{i_pos} =~ /^(?:x|i|r|t)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('obj',18,6);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('obj_ap',1,);
                  } elsif ($h->{i_pos} eq 'nic') {
                      if ($h->{g_case} =~ /^(?:5|6|7|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atr',4,1);
                      } elsif ($h->{g_case} eq '2') {
                        return ('obj',4,1);
                      } elsif ($h->{g_case} eq '3') {
                        return ('atr',1,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('obj',4,1);
                      }
                  }
              } elsif ($h->{g_subpos} eq 'a') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|f|v|x|i|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('adv',167,17);
                  } elsif ($h->{i_subpos} eq 't') {
                    return ('adv',4,1);
                  } elsif ($h->{i_subpos} eq 'nic') {
                    return ('atr',135,36);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('atr',37,15);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                      if ($h->{g_case} =~ /^(?:3|5|6|7|x|undef)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('pred_pa',1,);
                      } elsif ($h->{g_case} eq '4') {
                        return ('atr',4,);
                      } elsif ($h->{g_case} eq '1') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                            return ('adv_ap',0,);
                          } elsif ($h->{g_lemma} eq 'nový') {
                            return ('atr',2,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('adv_ap',3,1);
                          }
                      }
                  }
              }
          } elsif ($h->{d_voice} eq 'undef') {
              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|d|g|h|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                return ('obj',0,);
              } elsif ($h->{d_subpos} eq 'c') {
                return ('auxv',5,1);
              } elsif ($h->{d_subpos} eq 'e') {
                return ('exd_pa',2,1);
              } elsif ($h->{d_subpos} eq 'i') {
                return ('pred_pa',5,2);
              } elsif ($h->{d_subpos} eq 'f') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|koruna|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'dobrý') {
                    return ('adv',5,1);
                  } elsif ($h->{g_lemma} eq 'malý') {
                    return ('adv',1,);
                  } elsif ($h->{g_lemma} eq 'velký') {
                    return ('exd',2,);
                  } elsif ($h->{g_lemma} eq 'jiný') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('exd',2,);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('adv',10,2);
                      } elsif ($h->{i_lemma} eq '¾e') {
                        return ('exd',1,);
                      }
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|t|f|v|x|i|spec_aster)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('obj',18,);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('obj',429,23);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('obj',50,2);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'a') {
                            return ('adv',12,2);
                          } elsif ($h->{g_subpos} eq 'c') {
                            return ('obj',2,);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'd') {
          if ($h->{i_subpos} =~ /^(?:spec_at|f|v|x|i|spec_aster)$/) {
            return ('adv',0,);
          } elsif ($h->{i_subpos} eq 'spec_comma') {
            return ('adv',252,47);
          } elsif ($h->{i_subpos} eq 'r') {
            return ('adv',1,);
          } elsif ($h->{i_subpos} eq 't') {
            return ('exd_pa',2,1);
          } elsif ($h->{i_subpos} eq 'spec_ddot') {
              if ($h->{d_voice} eq 'p') {
                return ('adv_ap',1,);
              } elsif ($h->{d_voice} eq 'undef') {
                return ('atr',3,1);
              } elsif ($h->{d_voice} eq 'a') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('pred',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('pred',2,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('adv_ap',3,1);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('pred',12,4);
                  }
              }
          } elsif ($h->{i_subpos} eq 'nic') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                return ('pred',0,);
              } elsif ($h->{g_lemma} eq 'napøíklad') {
                  if ($h->{d_voice} eq 'p') {
                    return ('pred_ap',1,);
                  } elsif ($h->{d_voice} eq 'undef') {
                    return ('sb_ap',2,1);
                  } elsif ($h->{d_voice} eq 'a') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
                        return ('atr_ap',0,);
                      } elsif ($h->{d_lemma} eq 'mít') {
                        return ('atr_ap',1,);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('atr_ap',4,2);
                      } elsif ($h->{d_lemma} eq 'být') {
                        return ('pred_ap',3,);
                      }
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{d_voice} eq 'p') {
                    return ('adv',8,6);
                  } elsif ($h->{d_voice} eq 'undef') {
                    return ('obj',62,43);
                  } elsif ($h->{d_voice} eq 'a') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('pred',0,);
                      } elsif ($h->{g_subpos} eq 'g') {
                        return ('pred',92,35);
                      } elsif ($h->{g_subpos} eq 'b') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_subpos} eq 'b') {
                            return ('pred',183,117);
                          } elsif ($h->{d_subpos} eq 'p') {
                            return evalSubTree1_S15($h); # [S15]
                          }
                      }
                  }
              }
          } elsif ($h->{i_subpos} eq 'spec_head') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                return ('pred',0,);
              } elsif ($h->{g_lemma} eq 'hodnì') {
                return ('atr',1,);
              } elsif ($h->{g_lemma} eq 'napøíklad') {
                return ('atr',2,);
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('pred',0,);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('pred',2,1);
                  } elsif ($h->{i_lemma} eq 'v¹ak') {
                    return ('sb',1,);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('sb',2,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                      if ($h->{d_voice} eq 'undef') {
                        return ('pred',0,);
                      } elsif ($h->{d_voice} eq 'p') {
                        return ('pred',2,);
                      } elsif ($h->{d_voice} eq 'a') {
                        return ('obj',4,2);
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{d_voice} eq 'p') {
                        return ('pred',2,);
                      } elsif ($h->{d_voice} eq 'undef') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('atr',7,4);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('adv',3,1);
                          }
                      } elsif ($h->{d_voice} eq 'a') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('pred',0,);
                          } elsif ($h->{g_subpos} eq 'g') {
                            return ('pred',18,4);
                          } elsif ($h->{g_subpos} eq 'b') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_subpos} eq 'b') {
                                return ('adv',18,7);
                              } elsif ($h->{d_subpos} eq 'p') {
                                return ('obj',6,2);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_pos} eq 'v') {
          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
            return ('obj',0,);
          } elsif ($h->{d_lemma} eq 'mít') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_amperpercntspec_semicol|po|za|od|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('obj',0,);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('adv',7,3);
              } elsif ($h->{i_lemma} eq 'spec_dot') {
                return ('obj',1,);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('adv',3,);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('atr',6,);
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                return ('adv',37,4);
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                return ('obj',4,2);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('adv',1,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                    return ('adv_ap',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('sb',2,1);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('adv_ap',3,1);
                  }
              } elsif ($h->{i_lemma} eq 'aby') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('adv',1,);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('adv',1,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('adv',23,9);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',5,);
                  }
              } elsif ($h->{i_lemma} eq 'ale') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',27,3);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',3,);
                  }
              } elsif ($h->{i_lemma} eq 'undef') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_subpos} eq 'b') {
                    return ('obj',5,3);
                  } elsif ($h->{g_subpos} eq 'i') {
                    return ('obj_ap',1,);
                  } elsif ($h->{g_subpos} eq 'p') {
                    return ('adv',4,2);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('pred',2,1);
                  }
              } elsif ($h->{i_lemma} eq '¾e') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('obj',3,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',350,51);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',31,3);
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('obj',1,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',38,11);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',3,1);
                  }
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('obj',57,2);
                  } elsif ($h->{g_lemma} eq 'muset') {
                    return ('obj',57,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',278,46);
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('sb',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('sb',25,4);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('pred_pa',3,1);
                      }
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|nic|f|v|x|i|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('adv',202,28);
                  } elsif ($h->{i_subpos} eq 't') {
                    return ('adv',45,1);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('obj',2,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('obj',133,45);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('adv',2,);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('sb',16,9);
                      } elsif ($h->{g_lemma} eq 'mít') {
                          if ($h->{g_voice} eq 'p') {
                            return ('obj',0,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',7,1);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv',2,);
                          }
                      }
                  }
              }
          } elsif ($h->{d_lemma} eq 'muset') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                return ('obj',0,);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('adv',3,1);
              } elsif ($h->{g_lemma} eq 'mít') {
                  if ($h->{g_voice} eq 'p') {
                    return ('sb',0,);
                  } elsif ($h->{g_voice} eq 'a') {
                    return ('sb',2,1);
                  } elsif ($h->{g_voice} eq 'undef') {
                    return ('adv',2,1);
                  }
              } elsif ($h->{g_lemma} eq 'být') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|od|spec_lpar|pro|mezi|k|pøi|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('adv_ap',1,);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('sb',1,);
                  } elsif ($h->{i_lemma} eq 'other') {
                    return ('adv',10,3);
                  } elsif ($h->{i_lemma} eq '¾e') {
                    return ('sb',24,6);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('sb',6,3);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('adv',3,1);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('sb',1,);
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|undef|spec_amperpercntspec_semicol|po|za|od|spec_lpar|pro|mezi|k|pøi|o|s|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                    return ('sb_ap',3,1);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('sb',3,1);
                  } elsif ($h->{i_lemma} eq 'aby') {
                    return ('adv',4,1);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('obj',10,1);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq '¾e') {
                    return ('obj',96,17);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('obj',67,14);
                  } elsif ($h->{i_lemma} eq 'kdy¾') {
                    return ('adv',8,);
                  } elsif ($h->{i_lemma} eq 'v¹ak') {
                    return ('obj',3,1);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                      if ($h->{g_voice} eq 'undef') {
                        return ('obj',0,);
                      } elsif ($h->{g_voice} eq 'p') {
                        return ('adv',2,);
                      } elsif ($h->{g_voice} eq 'a') {
                        return ('obj',16,3);
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|nic|f|v|x|i|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('adv',21,);
                      } elsif ($h->{i_subpos} eq 't') {
                        return ('adv',1,);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                          if ($h->{g_voice} eq 'p') {
                            return ('sb',1,);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',24,7);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv',2,);
                          }
                      }
                  }
              }
          } elsif ($h->{d_lemma} eq 'jít') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|spec_amperpercntspec_semicol|po|za|od|spec_lpar|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('obj',0,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                return ('sb_ap',2,1);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('adv',1,);
              } elsif ($h->{i_lemma} eq 'aby') {
                return ('adv',4,1);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('obj',3,);
              } elsif ($h->{i_lemma} eq 'undef') {
                return ('obj',2,1);
              } elsif ($h->{i_lemma} eq 'jako') {
                return ('adv',1,);
              } elsif ($h->{i_lemma} eq 'kdy¾') {
                return ('adv',16,1);
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                return ('obj',1,);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('obj',1,);
              } elsif ($h->{i_lemma} eq '¾e') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('obj',0,);
                  } elsif ($h->{g_lemma} eq 'mít') {
                    return ('adv',1,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',109,22);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',9,1);
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('pred',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('obj',3,1);
                  } elsif ($h->{g_lemma} eq 'být') {
                    return ('sb',2,1);
                  }
              } elsif ($h->{i_lemma} eq 'nic') {
                  if ($h->{d_voice} eq 'p') {
                    return ('obj',0,);
                  } elsif ($h->{d_voice} eq 'undef') {
                    return ('obj',70,5);
                  } elsif ($h->{d_voice} eq 'a') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('adv',1,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('obj',40,15);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('pred_pa',5,2);
                      }
                  }
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|nic|f|v|x|i|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('adv',99,17);
                  } elsif ($h->{i_subpos} eq 't') {
                    return ('adv',19,1);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('obj',1,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('obj',20,8);
                      } elsif ($h->{g_lemma} eq 'být') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('sb',4,1);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('adv',2,);
                          }
                      }
                  }
              }
          } elsif ($h->{d_lemma} eq 'other') {
              if ($h->{d_voice} eq 'p') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{g_lemma} eq 'jít') {
                    return ('adv',6,1);
                  } elsif ($h->{g_lemma} eq 'mít') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|f|v|x|i|spec_aster)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('adv',5,);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('atv',3,1);
                      } elsif ($h->{i_subpos} eq 't') {
                        return ('adv',1,);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('obj',284,17);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('obj',12,4);
                      }
                  } elsif ($h->{g_lemma} eq 'muset') {
                      if ($h->{i_voice} eq 'nic') {
                        return ('obj',85,1);
                      } elsif ($h->{i_voice} eq 'undef') {
                        return ('adv',9,2);
                      }
                  } elsif ($h->{g_lemma} eq 'být') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|f|v|x|i|spec_aster)$/) {
                        return ('pnom',0,);
                      } elsif ($h->{i_subpos} eq 't') {
                        return ('adv',11,5);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('pnom',1835,25);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('pnom',93,19);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|ale|undef|spec_amperpercntspec_semicol|po|za|jako|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('sb',0,);
                          } elsif ($h->{i_lemma} eq 'aby') {
                            return ('sb',16,1);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('adv',27,3);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('sb',20,);
                          } elsif ($h->{i_lemma} eq 'kdy¾') {
                            return ('adv',2,);
                          }
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('pnom',0,);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('sb_ap',2,);
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                            return ('pnom',5,2);
                          }
                      }
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{i_pos} =~ /^(?:x|i)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',2,1);
                      } elsif ($h->{i_pos} eq 't') {
                        return ('adv',17,);
                      } elsif ($h->{i_pos} eq 'z') {
                          if ($h->{g_voice} eq 'p') {
                            return ('pred',2,1);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',38,21);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('adv_ap',1,);
                          }
                      } elsif ($h->{i_pos} eq 'nic') {
                          if ($h->{g_voice} eq 'p') {
                            return ('adv',4,2);
                          } elsif ($h->{g_voice} eq 'a') {
                            return ('obj',384,104);
                          } elsif ($h->{g_voice} eq 'undef') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_subpos} eq 'e') {
                                return ('pnom',2,);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('obj',22,9);
                              } elsif ($h->{g_subpos} eq 'i') {
                                return ('pnom',1,);
                              }
                          }
                      } elsif ($h->{i_pos} eq 'j') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|undef|spec_amperpercntspec_semicol|po|za|jako|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('adv',12,4);
                          } elsif ($h->{i_lemma} eq 'aby') {
                            return ('obj',61,18);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('obj',14,4);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('obj',200,34);
                          } elsif ($h->{i_lemma} eq 'kdy¾') {
                            return ('adv',23,2);
                          } elsif ($h->{i_lemma} eq 'v¹ak') {
                            return ('pred',1,);
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                return ('adv',117,15);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                return ('obj',130,57);
                              }
                          } elsif ($h->{i_lemma} eq 'èi') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('adv',3,1);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('obj',3,1);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('sb',1,);
                              } elsif ($h->{g_subpos} eq 's') {
                                return ('adv',1,);
                              }
                          }
                      }
                  }
              } elsif ($h->{d_voice} eq 'undef') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|d|g|h|j|k|spec_aster|l|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_subpos} eq 'c') {
                    return ('adv',1,);
                  } elsif ($h->{d_subpos} eq 'm') {
                    return ('adv',3,2);
                  } elsif ($h->{d_subpos} eq 'i') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('pred_pa',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('pnom_ap',3,1);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('adv',1,);
                      } elsif ($h->{i_lemma} eq 'ale') {
                        return ('obj',2,1);
                      } elsif ($h->{i_lemma} eq 'nic') {
                        return ('pred_pa',117,35);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('exd_pa',2,1);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('obj',13,1);
                      } elsif ($h->{i_lemma} eq 'other') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('obj',12,2);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('adv',3,1);
                          }
                      }
                  } elsif ($h->{d_subpos} eq 'e') {
                      if ($h->{i_pos} =~ /^(?:x|i)$/) {
                        return ('atvv',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('exd',10,3);
                      } elsif ($h->{i_pos} eq 'z') {
                        return ('atvv',2,);
                      } elsif ($h->{i_pos} eq 'r') {
                        return ('adv',4,1);
                      } elsif ($h->{i_pos} eq 't') {
                        return ('auxp',1,);
                      } elsif ($h->{i_pos} eq 'nic') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('atvv',0,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('auxy',1,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('atvv',52,34);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('auxy',2,);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('auxy',9,6);
                          } elsif ($h->{g_lemma} eq 'mít') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('auxp',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('atvv',2,1);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('auxp',1,);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('auxy',3,1);
                              }
                          }
                      }
                  } elsif ($h->{d_subpos} eq 'f') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('obj',1809,53);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('obj',1250,52);
                      } elsif ($h->{g_lemma} eq 'jít') {
                          if ($h->{i_pos} =~ /^(?:x|i|r|t)$/) {
                            return ('sb',0,);
                          } elsif ($h->{i_pos} eq 'j') {
                            return ('adv',2,);
                          } elsif ($h->{i_pos} eq 'z') {
                            return ('obj_ap',1,);
                          } elsif ($h->{i_pos} eq 'nic') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('sb',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('sb',18,7);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('obj',5,2);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv',23,12);
                              }
                          }
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{i_subpos} =~ /^(?:spec_at|r|f|v|x|i|spec_aster)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_subpos} eq 't') {
                            return ('adv',22,1);
                          } elsif ($h->{i_subpos} eq 'nic') {
                            return ('obj',7722,1349);
                          } elsif ($h->{i_subpos} eq 'spec_head') {
                            return ('obj',918,170);
                          } elsif ($h->{i_subpos} eq 'spec_comma') {
                            return evalSubTree1_S16($h); # [S16]
                          } elsif ($h->{i_subpos} eq 'spec_ddot') {
                            return evalSubTree1_S17($h); # [S17]
                          }
                      } elsif ($h->{g_lemma} eq 'být') {
                          if ($h->{g_voice} eq 'p') {
                            return ('sb',0,);
                          } elsif ($h->{g_voice} eq 'undef') {
                              if ($h->{i_voice} eq 'nic') {
                                return ('pnom',4,);
                              } elsif ($h->{i_voice} eq 'undef') {
                                return ('obj',2,1);
                              }
                          } elsif ($h->{g_voice} eq 'a') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|r|f|v|x|i|spec_aster)$/) {
                                return ('sb',0,);
                              } elsif ($h->{i_subpos} eq 't') {
                                return ('obj',17,3);
                              } elsif ($h->{i_subpos} eq 'nic') {
                                return ('sb',1353,68);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                return ('sb',275,15);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                return evalSubTree1_S18($h); # [S18]
                              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                                return evalSubTree1_S19($h); # [S19]
                              }
                          }
                      }
                  }
              } elsif ($h->{d_voice} eq 'a') {
                  if ($h->{i_voice} eq 'nic') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('pred_pa',64,23);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('pred_pa',23,11);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('pred_pa',11,1);
                      } elsif ($h->{g_lemma} eq 'být') {
                        return ('pred_pa',225,103);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_voice} eq 'a') {
                            return ('obj',1566,628);
                          } elsif ($h->{g_voice} eq 'undef') {
                            return ('obj',197,78);
                          } elsif ($h->{g_voice} eq 'p') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                return ('auxv',0,);
                              } elsif ($h->{d_subpos} eq 'b') {
                                return ('auxv',59,22);
                              } elsif ($h->{d_subpos} eq 'p') {
                                return ('pred_pa',34,13);
                              }
                          }
                      }
                  } elsif ($h->{i_voice} eq 'undef') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('adv',45,3);
                      } elsif ($h->{g_lemma} eq 'muset') {
                          if ($h->{i_pos} =~ /^(?:nic|x|i|r)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_pos} eq 'j') {
                            return ('adv',130,11);
                          } elsif ($h->{i_pos} eq 'z') {
                            return ('sb',7,2);
                          } elsif ($h->{i_pos} eq 't') {
                            return ('adv',21,2);
                          }
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return evalSubTree1_S20($h); # [S20]
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_amperpercntspec_semicol|po|za|nic|od|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_lemma} eq 'spec_ddot') {
                            return ('obj_ap',43,19);
                          } elsif ($h->{i_lemma} eq 'spec_dot') {
                            return ('obj',1,);
                          } elsif ($h->{i_lemma} eq 'aby') {
                            return ('adv',765,324);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('obj',228,45);
                          } elsif ($h->{i_lemma} eq 'jako') {
                            return ('adv',25,3);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('obj',2700,519);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('atr',16,6);
                          } elsif ($h->{i_lemma} eq 'kdy¾') {
                            return ('adv',595,27);
                          } elsif ($h->{i_lemma} eq 'v¹ak') {
                            return ('obj',47,13);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('obj',40,21);
                          } elsif ($h->{i_lemma} eq 'undef') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj_ap',20,14);
                              } elsif ($h->{g_subpos} eq 'f') {
                                return ('atr',2,);
                              } elsif ($h->{g_subpos} eq 'i') {
                                return ('obj',2,);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('obj',18,13);
                              }
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                              if ($h->{g_voice} eq 'p') {
                                return ('adv',8,1);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('obj',320,99);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('obj',33,13);
                              }
                          } elsif ($h->{i_lemma} eq 'nebo') {
                              if ($h->{g_voice} eq 'p') {
                                return ('sb',8,1);
                              } elsif ($h->{g_voice} eq 'a') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{d_subpos} eq 'b') {
                                    return ('adv',33,14);
                                  } elsif ($h->{d_subpos} eq 'p') {
                                    return ('obj',25,13);
                                  }
                              } elsif ($h->{g_voice} eq 'undef') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|e|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{g_subpos} eq 'f') {
                                    return ('adv',17,10);
                                  } elsif ($h->{g_subpos} eq 'i') {
                                    return ('obj',2,1);
                                  }
                              }
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|nic|f|v|x|i|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                return ('adv',1436,163);
                              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                                return ('pred',1,);
                              } elsif ($h->{i_subpos} eq 't') {
                                return ('adv',217,11);
                              } elsif ($h->{i_subpos} eq 'r') {
                                  if ($h->{i_case} =~ /^(?:1|3|6|nic|7|x|undef)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{i_case} eq '2') {
                                    return ('adv',7,);
                                  } elsif ($h->{i_case} eq '4') {
                                    return ('pred_pa',2,1);
                                  }
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                  if ($h->{g_voice} eq 'p') {
                                    return ('adv',45,21);
                                  } elsif ($h->{g_voice} eq 'a') {
                                    return ('obj',1288,575);
                                  } elsif ($h->{g_voice} eq 'undef') {
                                    return ('obj',192,66);
                                  }
                              }
                          }
                      } elsif ($h->{g_lemma} eq 'být') {
                          if ($h->{i_pos} =~ /^(?:nic|x|i|r)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_pos} eq 't') {
                            return ('adv',59,8);
                          } elsif ($h->{i_pos} eq 'j') {
                            return evalSubTree1_S21($h); # [S21]
                          } elsif ($h->{i_pos} eq 'z') {
                            return evalSubTree1_S22($h); # [S22]
                          }
                      }
                  }
              }
          } elsif ($h->{d_lemma} eq 'být') {
              if ($h->{i_case} =~ /^(?:1|4|x)$/) {
                return ('auxv',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('apos',7,1);
              } elsif ($h->{i_case} eq '3') {
                return ('apos',1,);
              } elsif ($h->{i_case} eq '6') {
                return ('apos',2,);
              } elsif ($h->{i_case} eq '7') {
                return ('apos',1,);
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                    return ('auxv',0,);
                  } elsif ($h->{g_subpos} eq 'f') {
                    return ('auxv',2042,80);
                  } elsif ($h->{g_subpos} eq 'i') {
                    return ('obj',5,2);
                  } elsif ($h->{g_subpos} eq 's') {
                    return ('auxv',4725,11);
                  } elsif ($h->{g_subpos} eq 'p') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|d|e|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('auxv',0,);
                      } elsif ($h->{d_subpos} eq 'b') {
                        return ('auxv',2407,249);
                      } elsif ($h->{d_subpos} eq 'c') {
                        return ('auxv',6340,1);
                      } elsif ($h->{d_subpos} eq 'f') {
                        return ('obj',396,21);
                      } elsif ($h->{d_subpos} eq 'p') {
                        return ('obj',63,30);
                      }
                  } elsif ($h->{g_subpos} eq 'b') {
                      if ($h->{d_voice} eq 'p') {
                        return ('obj',0,);
                      } elsif ($h->{d_voice} eq 'a') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_lemma} eq 'mít') {
                            return ('pred_pa',5,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('sb',1,);
                          } elsif ($h->{g_lemma} eq 'other') {
                            return ('obj',293,93);
                          } elsif ($h->{g_lemma} eq 'jít') {
                            return ('adv',2,1);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('pred_pa',46,27);
                          }
                      } elsif ($h->{d_voice} eq 'undef') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|g|h|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_subpos} eq 'i') {
                            return ('adv',2,1);
                          } elsif ($h->{d_subpos} eq 'f') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_lemma} eq 'mít') {
                                return ('obj',87,1);
                              } elsif ($h->{g_lemma} eq 'muset') {
                                return ('obj',148,1);
                              } elsif ($h->{g_lemma} eq 'other') {
                                return ('obj',368,8);
                              } elsif ($h->{g_lemma} eq 'být') {
                                return ('sb',9,);
                              }
                          }
                      }
                  }
              } elsif ($h->{i_case} eq 'undef') {
                  if ($h->{d_voice} eq 'p') {
                    return ('obj',0,);
                  } elsif ($h->{d_voice} eq 'undef') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|d|e|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('auxv',0,);
                      } elsif ($h->{d_subpos} eq 'c') {
                        return ('auxv',55,1);
                      } elsif ($h->{d_subpos} eq 'f') {
                          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
                            return ('obj',0,);
                          } elsif ($h->{g_lemma} eq 'muset') {
                            return ('obj',3,);
                          } elsif ($h->{g_lemma} eq 'být') {
                            return ('sb',5,1);
                          } elsif ($h->{g_lemma} eq 'mít') {
                              if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                                return ('auxv',0,);
                              } elsif ($h->{i_pos} eq 'j') {
                                return ('auxv',5,1);
                              } elsif ($h->{i_pos} eq 'z') {
                                return ('obj',2,);
                              }
                          } elsif ($h->{g_lemma} eq 'other') {
                              if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                                return ('obj',0,);
                              } elsif ($h->{i_pos} eq 'j') {
                                return ('obj',21,9);
                              } elsif ($h->{i_pos} eq 'z') {
                                return ('sb_ap',2,1);
                              }
                          }
                      }
                  } elsif ($h->{d_voice} eq 'a') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_lemma} eq 'mít') {
                        return ('adv',68,16);
                      } elsif ($h->{g_lemma} eq 'muset') {
                        return ('adv',32,5);
                      } elsif ($h->{g_lemma} eq 'jít') {
                        return ('adv',14,4);
                      } elsif ($h->{g_lemma} eq 'být') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|spec_amperpercntspec_semicol|po|za|nic|od|pro|mezi|k|pøi|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_lemma} eq 'spec_ddot') {
                            return ('adv_ap',2,1);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('atr',1,);
                          } elsif ($h->{i_lemma} eq 'aby') {
                            return ('adv',20,10);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('sb',7,3);
                          } elsif ($h->{i_lemma} eq 'undef') {
                            return ('sb_ap',2,1);
                          } elsif ($h->{i_lemma} eq 'jako') {
                            return ('adv_ap',1,);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('sb',108,15);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('atr',3,1);
                          } elsif ($h->{i_lemma} eq 'kdy¾') {
                            return ('adv',24,2);
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                            return ('sb',10,6);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('sb',2,1);
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|nic|f|v|x|i|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                return ('adv',114,15);
                              } elsif ($h->{i_subpos} eq 't') {
                                return ('adv',25,2);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                    return ('sb',0,);
                                  } elsif ($h->{d_subpos} eq 'b') {
                                    return ('adv',34,20);
                                  } elsif ($h->{d_subpos} eq 'p') {
                                    return ('sb',11,3);
                                  }
                              }
                          }
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_amperpercntspec_semicol|po|za|nic|od|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_lemma} eq 'spec_ddot') {
                            return ('obj_ap',21,5);
                          } elsif ($h->{i_lemma} eq 'spec_dot') {
                            return ('obj',2,);
                          } elsif ($h->{i_lemma} eq 'aby') {
                            return ('adv',56,19);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('obj',70,13);
                          } elsif ($h->{i_lemma} eq 'jako') {
                            return ('adv',18,1);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('obj',1182,199);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('atr',3,);
                          } elsif ($h->{i_lemma} eq 'kdy¾') {
                            return ('adv',72,2);
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                            return ('obj',149,48);
                          } elsif ($h->{i_lemma} eq 'v¹ak') {
                            return ('obj',19,1);
                          } elsif ($h->{i_lemma} eq 'undef') {
                              if ($h->{g_voice} eq 'p') {
                                return ('sb_ap',2,1);
                              } elsif ($h->{g_voice} eq 'a') {
                                return ('obj',15,10);
                              } elsif ($h->{g_voice} eq 'undef') {
                                return ('pred',1,);
                              }
                          } elsif ($h->{i_lemma} eq 'èi') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{d_subpos} eq 'b') {
                                return ('obj',9,2);
                              } elsif ($h->{d_subpos} eq 'p') {
                                return ('atr',2,1);
                              }
                          } elsif ($h->{i_lemma} eq 'nebo') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{d_subpos} eq 'b') {
                                return ('obj',13,6);
                              } elsif ($h->{d_subpos} eq 'p') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('auxv',0,);
                                  } elsif ($h->{g_subpos} eq 'b') {
                                    return ('auxv',2,);
                                  } elsif ($h->{g_subpos} eq 'p') {
                                    return ('adv',2,);
                                  } elsif ($h->{g_subpos} eq 's') {
                                    return ('auxv',2,);
                                  }
                              }
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:r|nic|f|v|x|i|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'spec_at') {
                                return ('pred_pa',1,);
                              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                                return ('pred',1,);
                              } elsif ($h->{i_subpos} eq 't') {
                                return ('adv',58,5);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                return ('obj',396,156);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                  if ($h->{g_voice} eq 'p') {
                                    return ('adv',20,);
                                  } elsif ($h->{g_voice} eq 'a') {
                                    return ('adv',293,38);
                                  } elsif ($h->{g_voice} eq 'undef') {
                                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                        return ('obj',0,);
                                      } elsif ($h->{d_subpos} eq 'p') {
                                        return ('adv',6,1);
                                      } elsif ($h->{d_subpos} eq 'b') {
                                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|e|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                            return ('obj',0,);
                                          } elsif ($h->{g_subpos} eq 'f') {
                                            return ('obj',36,14);
                                          } elsif ($h->{g_subpos} eq 'i') {
                                            return ('adv',4,1);
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
  } elsif ($h->{d_pos} eq 'c') {
      if ($h->{g_voice} eq 'p') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|ale|po|za|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
            return ('sb',0,);
          } elsif ($h->{i_lemma} eq 'spec_ddot') {
            return ('adv',3,1);
          } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
            return ('atr',6,);
          } elsif ($h->{i_lemma} eq 'jako') {
            return ('exd',1,);
          } elsif ($h->{i_lemma} eq 'spec_lpar') {
            return ('sb_ap',4,1);
          } elsif ($h->{i_lemma} eq 'nebo') {
              if ($h->{d_case} =~ /^(?:2|3|4|5|6|7|x)$/) {
                return ('sb',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb',2,);
              } elsif ($h->{d_case} eq 'undef') {
                return ('adv',2,);
              }
          } elsif ($h->{i_lemma} eq 'undef') {
              if ($h->{d_case} =~ /^(?:2|3|4|5|6|7|x)$/) {
                return ('adv',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb_ap',3,);
              } elsif ($h->{d_case} eq 'undef') {
                return ('adv',6,2);
              }
          } elsif ($h->{i_lemma} eq 'spec_comma') {
              if ($h->{d_case} =~ /^(?:2|4|5|6|7|x)$/) {
                return ('sb_ap',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb_ap',6,);
              } elsif ($h->{d_case} eq '3') {
                return ('exd_ap',1,);
              } elsif ($h->{d_case} eq 'undef') {
                return ('exd',8,4);
              }
          } elsif ($h->{i_lemma} eq 'other') {
              if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                return ('adv',0,);
              } elsif ($h->{i_pos} eq 'r') {
                return ('adv',145,48);
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{d_case} =~ /^(?:3|5|6|7|x)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('sb',12,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('adv',1,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('exd',2,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('sb',47,19);
                  }
              }
          } elsif ($h->{i_lemma} eq 'nic') {
              if ($h->{d_case} =~ /^(?:2|5|6|x)$/) {
                return ('sb',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb',77,3);
              } elsif ($h->{d_case} eq '3') {
                return ('obj',2,);
              } elsif ($h->{d_case} eq '4') {
                return ('adv',11,);
              } elsif ($h->{d_case} eq '7') {
                return ('adv',5,);
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|spec_comma|1|p|2|q|4|r|s|5|t|6|7|8|w|9|x|y|z)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                    return ('sb',118,21);
                  } elsif ($h->{d_subpos} eq 'o') {
                    return ('adv',12,);
                  } elsif ($h->{d_subpos} eq 'u') {
                    return ('adv',1,);
                  } elsif ($h->{d_subpos} eq 'v') {
                    return ('adv',23,1);
                  }
              }
          }
      } elsif ($h->{g_voice} eq 'undef') {
          if ($h->{g_pos} eq 'c') {
            return ('atr',2808,65);
          } elsif ($h->{g_pos} eq 'p') {
              if ($h->{i_case} =~ /^(?:1|3|7|x)$/) {
                return ('atr',0,);
              } elsif ($h->{i_case} eq '2') {
                return ('atr',3,1);
              } elsif ($h->{i_case} eq '4') {
                return ('atr',6,2);
              } elsif ($h->{i_case} eq '6') {
                return ('atv',1,);
              } elsif ($h->{i_case} eq 'undef') {
                return ('atr',2,1);
              } elsif ($h->{i_case} eq 'nic') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|pøípad|telefon|èeský|zahranièní|malý|fax|02|podnik|nový|1994|mít|muset|výroba|kè|firma|a|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|èlovìk|být)$/) {
                    return ('atr',0,);
                  } elsif ($h->{g_lemma} eq 'tento') {
                    return ('atr',1,);
                  } elsif ($h->{g_lemma} eq 'v¹echen') {
                    return ('atr',5,1);
                  } elsif ($h->{g_lemma} eq 'který') {
                    return ('atv',10,);
                  } elsif ($h->{g_lemma} eq 'já') {
                    return ('atr',9,);
                  } elsif ($h->{g_lemma} eq 'ten') {
                    return ('atr',20,7);
                  } elsif ($h->{g_lemma} eq 'other') {
                      if ($h->{g_case} =~ /^(?:3|4|5|6|7|x|undef)$/) {
                        return ('atv',0,);
                      } elsif ($h->{g_case} eq '1') {
                        return ('atv',3,);
                      } elsif ($h->{g_case} eq '2') {
                        return ('atr',2,);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'z') {
              if ($h->{i_subpos} =~ /^(?:t|f|x|i)$/) {
                return ('exd',0,);
              } elsif ($h->{i_subpos} eq 'spec_at') {
                return ('atr',1,);
              } elsif ($h->{i_subpos} eq 'r') {
                return ('exd',207,44);
              } elsif ($h->{i_subpos} eq 'nic') {
                return ('exd',1173,40);
              } elsif ($h->{i_subpos} eq 'v') {
                return ('exd',12,);
              } elsif ($h->{i_subpos} eq 'spec_comma') {
                  if ($h->{d_case} =~ /^(?:3|4|5|6|7|x)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr',2,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('exd',86,6);
                  }
              } elsif ($h->{i_subpos} eq 'spec_head') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{d_lemma} eq '02') {
                    return ('atr',1,);
                  } elsif ($h->{d_lemma} eq 'první') {
                    return ('exd',2,);
                  } elsif ($h->{d_lemma} eq '1') {
                    return ('auxg',9,3);
                  } elsif ($h->{d_lemma} eq '1994') {
                    return ('atr',1,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('exd',300,42);
                  }
              } elsif ($h->{i_subpos} eq 'spec_aster') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{d_lemma} eq '1') {
                    return ('atr',3,);
                  } elsif ($h->{d_lemma} eq 'other') {
                    return ('pnom',27,1);
                  }
              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|nebo|spec_dot|aby|ale|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('exd',0,);
                  } elsif ($h->{i_lemma} eq 'spec_rpar') {
                    return ('exd_ap',2,);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',13,);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('exd_ap',10,3);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('exd',455,27);
                  } elsif ($h->{i_lemma} eq 'spec_ddot') {
                      if ($h->{d_case} =~ /^(?:2|3|4|5|6|x)$/) {
                        return ('exd',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('exd_ap',5,2);
                      } elsif ($h->{d_case} eq '7') {
                        return ('adv',1,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('exd',384,117);
                      }
                  } elsif ($h->{i_lemma} eq 'undef') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('exd',0,);
                      } elsif ($h->{d_lemma} eq '1') {
                        return ('atr',10,5);
                      } elsif ($h->{d_lemma} eq '1994') {
                        return ('atr',6,1);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('exd',241,77);
                      }
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('exd',0,);
                      } elsif ($h->{d_lemma} eq '02') {
                        return ('atr',3,);
                      } elsif ($h->{d_lemma} eq '1') {
                        return ('obj',6,2);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('exd',29,16);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'd') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'b') {
                  if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|já|èlovìk|být|ten)$/) {
                    return ('adv',0,);
                  } elsif ($h->{g_lemma} eq 'other') {
                    return ('adv',129,92);
                  } elsif ($h->{g_lemma} eq 'napøíklad') {
                    return ('sb_ap',8,1);
                  }
              } elsif ($h->{g_subpos} eq 'g') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|po|za|¾e|od|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'nebo') {
                    return ('exd',1,);
                  } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq 'jako') {
                    return ('exd',1,);
                  } elsif ($h->{i_lemma} eq 'spec_lpar') {
                    return ('adv_ap',2,);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|spec_ddot|t|nic|f|v|x|i)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('adv',199,17);
                      } elsif ($h->{i_subpos} eq 'r') {
                        return ('adv',134,9);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('adv',5,);
                      } elsif ($h->{i_subpos} eq 'spec_aster') {
                        return ('atr',6,);
                      }
                  } elsif ($h->{i_lemma} eq 'nic') {
                      if ($h->{d_case} =~ /^(?:1|3|4|5|6|7|x)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('atr',3,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('adv',30,4);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'n') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|po|za|jako|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
                return ('atr',0,);
              } elsif ($h->{i_lemma} eq 'nebo') {
                return ('atr',44,);
              } elsif ($h->{i_lemma} eq 'ale') {
                return ('atr',3,);
              } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                return ('atr',32,11);
              } elsif ($h->{i_lemma} eq 'other') {
                return ('atr',1851,225);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('atr',16872,599);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('atr_ap',32,1);
              } elsif ($h->{i_lemma} eq 'v¹ak') {
                return ('atr',1,);
              } elsif ($h->{i_lemma} eq 'èi') {
                return ('atr',17,);
              } elsif ($h->{i_lemma} eq 'spec_ddot') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|e|f|g|h|i|j|k|spec_aster|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                    return ('atr',504,92);
                  } elsif ($h->{d_subpos} eq 'd') {
                    return ('atr_ap',1,);
                  } elsif ($h->{d_subpos} eq 'l') {
                    return ('atr_ap',6,1);
                  }
              } elsif ($h->{i_lemma} eq 'undef') {
                  if ($h->{d_case} =~ /^(?:3|5|7|x)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('atr_ap',4,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('atr_ap',10,5);
                  } elsif ($h->{d_case} eq '4') {
                    return ('atr_ap',1,);
                  } elsif ($h->{d_case} eq '6') {
                    return ('atr',1,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('atr',546,102);
                  }
              } elsif ($h->{i_lemma} eq 'spec_comma') {
                  if ($h->{d_case} =~ /^(?:5|x)$/) {
                    return ('atr',0,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('atr',2,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('atr',13,3);
                  } elsif ($h->{d_case} eq '6') {
                    return ('atr',6,1);
                  } elsif ($h->{d_case} eq '7') {
                    return ('atr',3,);
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                        return ('atr_ap',0,);
                      } elsif ($h->{d_subpos} eq 'l') {
                        return ('exd_pa',1,);
                      } elsif ($h->{d_subpos} eq 'n') {
                        return ('atr',3,1);
                      } elsif ($h->{d_subpos} eq 'r') {
                        return ('atr_ap',5,2);
                      }
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('atr_ap',0,);
                      } elsif ($h->{g_lemma} eq 'other') {
                        return ('atr_ap',5,);
                      } elsif ($h->{g_lemma} eq 'firma') {
                        return ('atr',2,);
                      }
                  } elsif ($h->{d_case} eq 'undef') {
                      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|èeský|zahranièní|malý|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                        return ('atr',0,);
                      } elsif ($h->{g_lemma} eq 'telefon') {
                        return ('atr',4,);
                      } elsif ($h->{g_lemma} eq 'fax') {
                        return ('atr',4,);
                      } elsif ($h->{g_lemma} eq 'other') {
                          if ($h->{g_case} =~ /^(?:3|5|undef)$/) {
                            return ('atr',0,);
                          } elsif ($h->{g_case} eq '1') {
                            return ('exd',40,12);
                          } elsif ($h->{g_case} eq '2') {
                            return ('atr',28,11);
                          } elsif ($h->{g_case} eq '4') {
                            return ('atr',51,20);
                          } elsif ($h->{g_case} eq '6') {
                            return ('exd',10,2);
                          } elsif ($h->{g_case} eq '7') {
                            return ('atr',13,3);
                          } elsif ($h->{g_case} eq 'x') {
                            return ('atr',64,12);
                          }
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'v') {
              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
                return ('obj',0,);
              } elsif ($h->{g_lemma} eq 'muset') {
                return ('sb',5,2);
              } elsif ($h->{g_lemma} eq 'jít') {
                return ('obj',3,1);
              } elsif ($h->{g_lemma} eq 'být') {
                  if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{i_pos} eq 'nic') {
                    return ('pnom',24,4);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('obj',2,);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('pnom',2,);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('adv',2,);
                  }
              } elsif ($h->{g_lemma} eq 'mít') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|t|f|v|x|i|spec_aster)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('adv',3,1);
                  } elsif ($h->{i_subpos} eq 'r') {
                    return ('atr',3,1);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                    return ('obj_ap',1,);
                  } elsif ($h->{i_subpos} eq 'nic') {
                    return ('obj',22,3);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{d_case} =~ /^(?:1|2|3|5|6|7|x)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('exd',5,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('obj',6,);
                      }
                  }
              } elsif ($h->{g_lemma} eq 'other') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_lemma} eq '02') {
                    return ('atr',5,);
                  } elsif ($h->{d_lemma} eq '1') {
                    return ('adv',7,4);
                  } elsif ($h->{d_lemma} eq 'první') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|spec_hash|g|h|i|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'e') {
                        return ('adv',2,1);
                      } elsif ($h->{g_subpos} eq 'f') {
                        return ('exd',6,3);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{g_subpos} eq 'e') {
                        return ('adv',2,1);
                      } elsif ($h->{g_subpos} eq 'f') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|po|za|jako|od|pro|mezi|k|pøi|kdy¾|s|v¹ak|u|v|z|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('adv',4,2);
                          } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                            return ('atr',5,);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('exd',1,);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('obj_ap',10,2);
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                            return ('obj',5,3);
                          } elsif ($h->{i_lemma} eq 'o') {
                            return ('adv',1,);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('adv',1,);
                          } elsif ($h->{i_lemma} eq 'do') {
                            return ('adv',1,);
                          } elsif ($h->{i_lemma} eq 'spec_ddot') {
                              if ($h->{d_case} =~ /^(?:1|2|3|5|6|7|x)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_case} eq '4') {
                                return ('obj_ap',2,);
                              } elsif ($h->{d_case} eq 'undef') {
                                return ('adv',9,2);
                              }
                          } elsif ($h->{i_lemma} eq 'nebo') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{d_subpos} eq 'spec_eq') {
                                return ('obj',4,);
                              } elsif ($h->{d_subpos} eq 'a') {
                                return ('obj',1,);
                              } elsif ($h->{d_subpos} eq 'l') {
                                return ('exd',1,);
                              } elsif ($h->{d_subpos} eq 'n') {
                                return ('adv',2,);
                              } elsif ($h->{d_subpos} eq 'v') {
                                return ('adv',1,);
                              }
                          } elsif ($h->{i_lemma} eq 'undef') {
                              if ($h->{d_case} =~ /^(?:1|3|5|6|7|x)$/) {
                                return ('obj',0,);
                              } elsif ($h->{d_case} eq '2') {
                                return ('atr',1,);
                              } elsif ($h->{d_case} eq '4') {
                                return ('obj_ap',3,);
                              } elsif ($h->{d_case} eq 'undef') {
                                return ('obj',19,8);
                              }
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_subpos} =~ /^(?:spec_at|nic|f|x|i|spec_aster)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_subpos} eq 'r') {
                                return ('adv',172,68);
                              } elsif ($h->{i_subpos} eq 'spec_ddot') {
                                return ('adv',3,1);
                              } elsif ($h->{i_subpos} eq 't') {
                                return ('obj',3,1);
                              } elsif ($h->{i_subpos} eq 'v') {
                                return ('exd',4,1);
                              } elsif ($h->{i_subpos} eq 'spec_head') {
                                return ('obj',56,22);
                              } elsif ($h->{i_subpos} eq 'spec_comma') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                                    return ('obj',0,);
                                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                                    return ('obj',23,9);
                                  } elsif ($h->{d_subpos} eq 'l') {
                                    return ('atr',1,);
                                  } elsif ($h->{d_subpos} eq 'n') {
                                    return ('obj',1,);
                                  } elsif ($h->{d_subpos} eq 'v') {
                                    return ('adv',2,);
                                  }
                              }
                          } elsif ($h->{i_lemma} eq 'nic') {
                              if ($h->{d_case} =~ /^(?:5|6)$/) {
                                return ('obj',0,);
                              } elsif ($h->{d_case} eq '1') {
                                return ('sb',17,5);
                              } elsif ($h->{d_case} eq '2') {
                                return ('obj',3,1);
                              } elsif ($h->{d_case} eq '3') {
                                return ('obj',5,);
                              } elsif ($h->{d_case} eq '4') {
                                return ('obj',115,22);
                              } elsif ($h->{d_case} eq '7') {
                                return ('adv',3,);
                              } elsif ($h->{d_case} eq 'x') {
                                return ('adv',2,1);
                              } elsif ($h->{d_case} eq 'undef') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                                    return ('obj',0,);
                                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                                    return ('obj',156,43);
                                  } elsif ($h->{d_subpos} eq 'o') {
                                    return ('adv',1,);
                                  } elsif ($h->{d_subpos} eq 'v') {
                                    return ('adv',29,);
                                  }
                              }
                          }
                      } elsif ($h->{g_subpos} eq 'i') {
                          if ($h->{d_case} =~ /^(?:1|3|5|6|x)$/) {
                            return ('exd',0,);
                          } elsif ($h->{d_case} eq '2') {
                            return ('adv_ap',1,);
                          } elsif ($h->{d_case} eq '7') {
                            return ('adv',2,);
                          } elsif ($h->{d_case} eq '4') {
                              if ($h->{i_voice} eq 'nic') {
                                return ('obj',4,);
                              } elsif ($h->{i_voice} eq 'undef') {
                                return ('exd',3,);
                              }
                          } elsif ($h->{d_case} eq 'undef') {
                              if ($h->{i_case} =~ /^(?:1|3|6|7|x)$/) {
                                return ('exd',0,);
                              } elsif ($h->{i_case} eq '2') {
                                return ('exd_pa',3,1);
                              } elsif ($h->{i_case} eq '4') {
                                return ('obj',2,);
                              } elsif ($h->{i_case} eq 'nic') {
                                return ('atr',6,1);
                              } elsif ($h->{i_case} eq 'undef') {
                                return evalSubTree1_S23($h); # [S23]
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'a') {
              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|b|d|e|f|spec_hash|h|i|j|k|l|m|n|o|p|q|4|r|s|5|6|7|8|v|w|y|z)$/) {
                return ('adv',0,);
              } elsif ($h->{g_subpos} eq 'c') {
                return ('adv',7,3);
              } elsif ($h->{g_subpos} eq '2') {
                return ('atr',2,);
              } elsif ($h->{g_subpos} eq 'u') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('atr',61,13);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('exd',3,1);
                  }
              } elsif ($h->{g_subpos} eq 'g') {
                  if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|t|f|v|x|i)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'r') {
                    return ('adv',7,1);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                    return ('atr',2,);
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                    return ('obj',1,);
                  } elsif ($h->{i_subpos} eq 'spec_aster') {
                    return ('atr',1,);
                  } elsif ($h->{i_subpos} eq 'nic') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|s|5|t|6|7|u|8|w|9|x|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_subpos} eq 'spec_eq') {
                        return ('obj',27,9);
                      } elsif ($h->{d_subpos} eq 'a') {
                        return ('adv',4,2);
                      } elsif ($h->{d_subpos} eq 'l') {
                        return ('atr',3,1);
                      } elsif ($h->{d_subpos} eq 'n') {
                        return ('adv',8,1);
                      } elsif ($h->{d_subpos} eq 'r') {
                        return ('atr',1,);
                      } elsif ($h->{d_subpos} eq 'v') {
                        return ('adv',3,);
                      } elsif ($h->{d_subpos} eq 'y') {
                        return ('obj',1,);
                      }
                  }
              } elsif ($h->{g_subpos} eq 'a') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_lemma} eq '02') {
                    return ('atr',2,);
                  } elsif ($h->{d_lemma} eq '1994') {
                    return ('atr',1,);
                  } elsif ($h->{d_lemma} eq 'první') {
                      if ($h->{i_voice} eq 'nic') {
                        return ('atr',9,2);
                      } elsif ($h->{i_voice} eq 'undef') {
                        return ('exd',2,);
                      }
                  } elsif ($h->{d_lemma} eq '1') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|r|t|f|v|x|i|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('exd',4,1);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('adv',2,);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('atr',5,1);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('adv',2,);
                      }
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|ale|po|za|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('exd',2,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                        return ('adv',2,);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('adv',22,3);
                      } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                        return ('atr',1,);
                      } elsif ($h->{i_lemma} eq 'jako') {
                        return ('exd',1,);
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                        return ('exd',6,);
                      } elsif ($h->{i_lemma} eq 'v¹ak') {
                        return ('exd',1,);
                      } elsif ($h->{i_lemma} eq 'nic') {
                          if ($h->{d_case} =~ /^(?:5|x)$/) {
                            return ('adv',0,);
                          } elsif ($h->{d_case} eq '1') {
                            return ('atr',13,1);
                          } elsif ($h->{d_case} eq '2') {
                            return ('adv',5,2);
                          } elsif ($h->{d_case} eq '3') {
                            return ('adv',2,1);
                          } elsif ($h->{d_case} eq '6') {
                            return ('adv',2,1);
                          } elsif ($h->{d_case} eq '7') {
                            return ('adv',3,2);
                          } elsif ($h->{d_case} eq 'undef') {
                            return ('adv',375,110);
                          } elsif ($h->{d_case} eq '4') {
                              if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_subpos} eq 'a') {
                                return ('adv',10,);
                              } elsif ($h->{d_subpos} eq 'l') {
                                return ('atr',3,);
                              } elsif ($h->{d_subpos} eq 'n') {
                                return ('adv',17,2);
                              } elsif ($h->{d_subpos} eq 'y') {
                                return ('adv',1,);
                              }
                          }
                      } elsif ($h->{i_lemma} eq 'other') {
                          if ($h->{i_subpos} =~ /^(?:spec_at|t|nic|f|x|i)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_subpos} eq 'r') {
                            return ('adv',70,11);
                          } elsif ($h->{i_subpos} eq 'spec_ddot') {
                            return ('atr',1,);
                          } elsif ($h->{i_subpos} eq 'v') {
                            return ('adv',1,);
                          } elsif ($h->{i_subpos} eq 'spec_comma') {
                              if ($h->{d_case} =~ /^(?:2|3|5|6|7|x)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_case} eq '1') {
                                return ('exd',4,);
                              } elsif ($h->{d_case} eq '4') {
                                return ('adv',9,3);
                              } elsif ($h->{d_case} eq 'undef') {
                                return ('adv',23,4);
                              }
                          } elsif ($h->{i_subpos} eq 'spec_aster') {
                              if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|být|ten)$/) {
                                return ('atr',0,);
                              } elsif ($h->{g_lemma} eq 'other') {
                                return ('atr',5,);
                              } elsif ($h->{g_lemma} eq 'velký') {
                                return ('adv',2,);
                              }
                          } elsif ($h->{i_subpos} eq 'spec_head') {
                              if ($h->{g_case} =~ /^(?:3|5|6|7|x|undef)$/) {
                                return ('adv',0,);
                              } elsif ($h->{g_case} eq '2') {
                                return ('adv',9,);
                              } elsif ($h->{g_case} eq '4') {
                                return ('adv',3,1);
                              } elsif ($h->{g_case} eq '1') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                                    return ('atr',0,);
                                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                                    return ('atr',9,3);
                                  } elsif ($h->{d_subpos} eq 'v') {
                                    return ('adv',2,1);
                                  }
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{g_voice} eq 'a') {
          if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|1|napøíklad|já|èlovìk|ten)$/) {
            return ('adv',0,);
          } elsif ($h->{g_lemma} eq 'muset') {
              if ($h->{d_case} =~ /^(?:3|4|5|6|7|x)$/) {
                return ('sb',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('sb',9,);
              } elsif ($h->{d_case} eq '2') {
                return ('sb',2,1);
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                    return ('sb',16,7);
                  } elsif ($h->{d_subpos} eq 'v') {
                    return ('adv',4,);
                  }
              }
          } elsif ($h->{g_lemma} eq 'jít') {
              if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|po|za|jako|¾e|od|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                return ('obj',0,);
              } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                return ('atr',1,);
              } elsif ($h->{i_lemma} eq 'nic') {
                return ('sb',14,4);
              } elsif ($h->{i_lemma} eq 'spec_lpar') {
                return ('sb_ap',1,);
              } elsif ($h->{i_lemma} eq 'other') {
                  if ($h->{i_case} =~ /^(?:1|3|nic|7|x)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_case} eq '2') {
                    return ('adv',2,);
                  } elsif ($h->{i_case} eq '4') {
                    return ('obj',19,5);
                  } elsif ($h->{i_case} eq '6') {
                    return ('adv',2,1);
                  } elsif ($h->{i_case} eq 'undef') {
                    return ('obj',2,1);
                  }
              }
          } elsif ($h->{g_lemma} eq 'mít') {
              if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                return ('obj',0,);
              } elsif ($h->{d_lemma} eq 'první') {
                return ('obj',2,1);
              } elsif ($h->{d_lemma} eq '1') {
                return ('auxg',4,);
              } elsif ($h->{d_lemma} eq '1994') {
                return ('atr',1,);
              } elsif ($h->{d_lemma} eq 'other') {
                  if ($h->{d_case} eq '5') {
                    return ('obj',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('exd',1,);
                  } elsif ($h->{d_case} eq '3') {
                    return ('adv',1,);
                  } elsif ($h->{d_case} eq '6') {
                    return ('adv',3,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('adv',1,);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('obj',1,);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|t|f|v|x|i|spec_aster)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('adv',2,);
                      } elsif ($h->{i_subpos} eq 'r') {
                        return ('adv',7,3);
                      } elsif ($h->{i_subpos} eq 'spec_ddot') {
                        return ('obj_ap',8,2);
                      } elsif ($h->{i_subpos} eq 'nic') {
                        return ('obj',95,10);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('obj',17,5);
                      }
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{i_pos} =~ /^(?:x|i|r|t)$/) {
                        return ('sb',0,);
                      } elsif ($h->{i_pos} eq 'nic') {
                        return ('sb',52,3);
                      } elsif ($h->{i_pos} eq 'z') {
                        return ('sb_ap',4,);
                      } elsif ($h->{i_pos} eq 'j') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|b|c|d|e|f|g|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                            return ('sb',0,);
                          } elsif ($h->{d_subpos} eq 'h') {
                            return ('sb',1,);
                          } elsif ($h->{d_subpos} eq 'l') {
                            return ('exd_pa',2,);
                          } elsif ($h->{d_subpos} eq 'n') {
                            return ('sb',2,);
                          }
                      }
                  } elsif ($h->{d_case} eq 'undef') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                        return ('obj',0,);
                      } elsif ($h->{d_subpos} eq 'o') {
                        return ('adv',1,);
                      } elsif ($h->{d_subpos} eq 'v') {
                        return ('adv',9,1);
                      } elsif ($h->{d_subpos} eq 'spec_eq') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|po|za|jako|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('sb',2,);
                          } elsif ($h->{i_lemma} eq 'undef') {
                            return ('exd',3,1);
                          } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                            return ('atr',3,);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('obj_ap',3,1);
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                            return ('obj',3,1);
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj',32,11);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv',11,4);
                              }
                          } elsif ($h->{i_lemma} eq 'nic') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('obj',66,14);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('sb',38,17);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{g_lemma} eq 'být') {
              if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                return ('pnom',0,);
              } elsif ($h->{i_pos} eq 'r') {
                  if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'r') {
                    return ('adv',118,46);
                  } elsif ($h->{i_subpos} eq 'v') {
                      if ($h->{i_case} =~ /^(?:1|2|3|nic|x|undef)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_case} eq '4') {
                        return ('adv',2,);
                      } elsif ($h->{i_case} eq '6') {
                        return ('exd',18,3);
                      } elsif ($h->{i_case} eq '7') {
                        return ('adv',2,);
                      }
                  }
              } elsif ($h->{i_pos} eq 'j') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('sb',0,);
                  } elsif ($h->{d_lemma} eq 'první') {
                    return ('pnom',4,1);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{d_case} =~ /^(?:3|5)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('sb',25,10);
                      } elsif ($h->{d_case} eq '2') {
                        return ('adv',2,1);
                      } elsif ($h->{d_case} eq '6') {
                        return ('adv',1,);
                      } elsif ($h->{d_case} eq '7') {
                        return ('pnom',2,1);
                      } elsif ($h->{d_case} eq 'x') {
                        return ('pnom',2,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('sb',63,31);
                      } elsif ($h->{d_case} eq '4') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                            return ('pnom',0,);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('pnom',7,2);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('adv',3,1);
                          }
                      }
                  }
              } elsif ($h->{i_pos} eq 'z') {
                  if ($h->{d_case} =~ /^(?:2|3|5|6|x)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('sb_ap',21,8);
                  } elsif ($h->{d_case} eq '4') {
                    return ('exd_ap',1,);
                  } elsif ($h->{d_case} eq '7') {
                    return ('pnom_ap',1,);
                  } elsif ($h->{d_case} eq 'undef') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                        return ('pnom',0,);
                      } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                        return ('atr',7,1);
                      } elsif ($h->{i_lemma} eq 'other') {
                        return ('obj',11,5);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('sb_ap',2,1);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('pnom',0,);
                          } elsif ($h->{d_lemma} eq '1') {
                            return ('adv',6,2);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('pnom',21,10);
                          }
                      } elsif ($h->{i_lemma} eq 'undef') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('pnom',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('pnom',24,16);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('sb',7,3);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('exd',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('pnom',4,3);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('exd',4,1);
                          }
                      }
                  }
              } elsif ($h->{i_pos} eq 'nic') {
                  if ($h->{d_case} =~ /^(?:3|5|6)$/) {
                    return ('pnom',0,);
                  } elsif ($h->{d_case} eq '2') {
                    return ('adv',2,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('adv',21,5);
                  } elsif ($h->{d_case} eq '7') {
                    return ('pnom',195,2);
                  } elsif ($h->{d_case} eq 'x') {
                    return ('sb',7,3);
                  } elsif ($h->{d_case} eq '1') {
                      if ($h->{d_subpos} =~ /^(?:spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|s|5|t|6|7|u|8|v|w|9|x|z)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_subpos} eq 'spec_qmark') {
                        return ('sb',12,1);
                      } elsif ($h->{d_subpos} eq 'a') {
                        return ('sb',76,9);
                      } elsif ($h->{d_subpos} eq 'd') {
                        return ('sb',3,);
                      } elsif ($h->{d_subpos} eq 'n') {
                        return ('sb',80,23);
                      } elsif ($h->{d_subpos} eq 'r') {
                        return ('pnom',48,14);
                      } elsif ($h->{d_subpos} eq 'y') {
                        return ('sb',10,2);
                      } elsif ($h->{d_subpos} eq 'l') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('pnom',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('pnom',90,43);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('sb',15,5);
                          }
                      }
                  } elsif ($h->{d_case} eq 'undef') {
                      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_rbrace|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|w|9|x|y|z)$/) {
                        return ('sb',0,);
                      } elsif ($h->{d_subpos} eq 'o') {
                        return ('adv',6,);
                      } elsif ($h->{d_subpos} eq 'v') {
                        return ('adv',24,4);
                      } elsif ($h->{d_subpos} eq 'spec_eq') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('sb',0,);
                          } elsif ($h->{d_lemma} eq '1') {
                            return ('adv',8,5);
                          } elsif ($h->{d_lemma} eq 'other') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('sb',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('sb',276,133);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('pnom',120,61);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{g_lemma} eq 'other') {
              if ($h->{d_case} eq '5') {
                return ('adv',0,);
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{i_pos} =~ /^(?:x|i|t)$/) {
                    return ('sb',0,);
                  } elsif ($h->{i_pos} eq 'nic') {
                    return ('sb',624,49);
                  } elsif ($h->{i_pos} eq 'j') {
                    return ('sb',71,21);
                  } elsif ($h->{i_pos} eq 'z') {
                    return ('sb_ap',61,18);
                  } elsif ($h->{i_pos} eq 'r') {
                    return ('exd',1,);
                  }
              } elsif ($h->{d_case} eq 'x') {
                  if ($h->{i_voice} eq 'nic') {
                    return ('obj',14,6);
                  } elsif ($h->{i_voice} eq 'undef') {
                    return ('sb_ap',2,1);
                  }
              } elsif ($h->{d_case} eq '2') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_lemma} eq 'ale') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('obj_ap',1,);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('obj',23,7);
                  } elsif ($h->{i_lemma} eq 'spec_comma') {
                    return ('adv_ap',2,1);
                  } elsif ($h->{i_lemma} eq 'èi') {
                    return ('atr',1,);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{i_subpos} =~ /^(?:spec_at|spec_ddot|t|nic|f|x|i|spec_aster)$/) {
                        return ('adv',0,);
                      } elsif ($h->{i_subpos} eq 'spec_comma') {
                        return ('atr',5,1);
                      } elsif ($h->{i_subpos} eq 'r') {
                        return ('adv',60,23);
                      } elsif ($h->{i_subpos} eq 'v') {
                        return ('exd_pa',3,2);
                      } elsif ($h->{i_subpos} eq 'spec_head') {
                        return ('adv',8,2);
                      }
                  }
              } elsif ($h->{d_case} eq '3') {
                  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                    return ('obj',0,);
                  } elsif ($h->{i_lemma} eq 'undef') {
                    return ('obj_ap',1,);
                  } elsif ($h->{i_lemma} eq 'nic') {
                    return ('obj',19,1);
                  } elsif ($h->{i_lemma} eq 'other') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('obj',3,1);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('adv',7,1);
                      }
                  }
              } elsif ($h->{d_case} eq '6') {
                  if ($h->{i_case} =~ /^(?:1|2|3|4|nic|7|x)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_case} eq '6') {
                      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                        return ('adv',0,);
                      } elsif ($h->{d_lemma} eq 'první') {
                        return ('exd',8,2);
                      } elsif ($h->{d_lemma} eq 'other') {
                        return ('adv',83,16);
                      }
                  } elsif ($h->{i_case} eq 'undef') {
                      if ($h->{i_pos} =~ /^(?:nic|x|i|r|t)$/) {
                        return ('atr',0,);
                      } elsif ($h->{i_pos} eq 'j') {
                        return ('atr',4,1);
                      } elsif ($h->{i_pos} eq 'z') {
                        return ('obj_ap',5,1);
                      }
                  }
              } elsif ($h->{d_case} eq '7') {
                  if ($h->{i_subpos} =~ /^(?:spec_at|t|f|x|i|spec_aster)$/) {
                    return ('adv',0,);
                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                    return ('adv',1,);
                  } elsif ($h->{i_subpos} eq 'spec_ddot') {
                    return ('obj_ap',2,);
                  } elsif ($h->{i_subpos} eq 'v') {
                    return ('exd',1,);
                  } elsif ($h->{i_subpos} eq 'r') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('obj',4,1);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('adv',5,1);
                      }
                  } elsif ($h->{i_subpos} eq 'nic') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('adv',21,5);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('obj',30,14);
                      }
                  } elsif ($h->{i_subpos} eq 'spec_head') {
                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                        return ('adv',0,);
                      } elsif ($h->{g_subpos} eq 'b') {
                        return ('exd',2,);
                      } elsif ($h->{g_subpos} eq 'p') {
                        return ('adv',4,1);
                      }
                  }
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                    return ('obj',0,);
                  } elsif ($h->{d_lemma} eq 'první') {
                    return ('exd',7,3);
                  } elsif ($h->{d_lemma} eq 'other') {
                      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|spec_amperpercntspec_semicol|po|jako|¾e|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
                        return ('obj',0,);
                      } elsif ($h->{i_lemma} eq 'spec_ddot') {
                        return ('obj_ap',3,);
                      } elsif ($h->{i_lemma} eq 'ale') {
                        return ('obj',8,3);
                      } elsif ($h->{i_lemma} eq 'undef') {
                        return ('obj_ap',6,);
                      } elsif ($h->{i_lemma} eq 'za') {
                        return ('obj',1,);
                      } elsif ($h->{i_lemma} eq 'nic') {
                        return ('obj',638,181);
                      } elsif ($h->{i_lemma} eq 'spec_lpar') {
                        return ('adv_ap',1,);
                      } elsif ($h->{i_lemma} eq 'èi') {
                        return ('obj',2,);
                      } elsif ($h->{i_lemma} eq 'nebo') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('obj',3,1);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('adv',5,1);
                          }
                      } elsif ($h->{i_lemma} eq 'spec_comma') {
                          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|z)$/) {
                            return ('adv_ap',0,);
                          } elsif ($h->{d_subpos} eq 'a') {
                            return ('adv_ap',3,1);
                          } elsif ($h->{d_subpos} eq 'n') {
                            return ('adv_ap',10,7);
                          } elsif ($h->{d_subpos} eq 'y') {
                            return ('obj_ap',1,);
                          } elsif ($h->{d_subpos} eq 'l') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj_ap',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('adv',3,1);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('obj_ap',2,);
                              }
                          }
                      } elsif ($h->{i_lemma} eq 'other') {
                          if ($h->{i_pos} =~ /^(?:nic|x|i|z|t)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_pos} eq 'j') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('obj',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|g|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{d_subpos} eq 'a') {
                                    return ('obj',1,);
                                  } elsif ($h->{d_subpos} eq 'h') {
                                    return ('obj',1,);
                                  } elsif ($h->{d_subpos} eq 'l') {
                                    return ('obj',10,6);
                                  } elsif ($h->{d_subpos} eq 'n') {
                                    return ('adv',25,9);
                                  }
                              } elsif ($h->{g_subpos} eq 'p') {
                                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|z)$/) {
                                    return ('obj',0,);
                                  } elsif ($h->{d_subpos} eq 'a') {
                                    return ('obj',6,2);
                                  } elsif ($h->{d_subpos} eq 'l') {
                                    return ('adv',10,5);
                                  } elsif ($h->{d_subpos} eq 'n') {
                                    return ('obj',30,5);
                                  } elsif ($h->{d_subpos} eq 'y') {
                                    return ('obj',1,);
                                  }
                              }
                          } elsif ($h->{i_pos} eq 'r') {
                              if ($h->{d_subpos} =~ /^(?:spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|b|c|d|e|f|g|h|i|j|k|spec_aster|m|o|spec_comma|1|p|2|q|4|s|5|t|6|7|u|8|v|9|x|z)$/) {
                                return ('adv',0,);
                              } elsif ($h->{d_subpos} eq 'a') {
                                return ('adv',24,8);
                              } elsif ($h->{d_subpos} eq 'n') {
                                return ('adv',158,56);
                              } elsif ($h->{d_subpos} eq 'r') {
                                return ('adv',4,);
                              } elsif ($h->{d_subpos} eq 'w') {
                                return ('adv',1,);
                              } elsif ($h->{d_subpos} eq 'y') {
                                return ('adv',21,5);
                              } elsif ($h->{d_subpos} eq 'spec_qmark') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{g_subpos} eq 'b') {
                                    return ('adv',6,2);
                                  } elsif ($h->{g_subpos} eq 'p') {
                                    return ('obj',2,1);
                                  }
                              } elsif ($h->{d_subpos} eq 'l') {
                                  if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                    return ('obj',0,);
                                  } elsif ($h->{g_subpos} eq 'b') {
                                    return ('obj',24,8);
                                  } elsif ($h->{g_subpos} eq 'p') {
                                    return ('adv',10,4);
                                  }
                              }
                          }
                      }
                  }
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|a|b|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|spec_comma|1|p|2|q|4|r|s|5|t|6|7|8|w|9|x|y|z)$/) {
                    return ('adv',0,);
                  } elsif ($h->{d_subpos} eq 'spec_rbrace') {
                    return ('adv',2,1);
                  } elsif ($h->{d_subpos} eq 'u') {
                    return ('adv',1,);
                  } elsif ($h->{d_subpos} eq 'o') {
                      if ($h->{i_voice} eq 'nic') {
                        return ('adv',60,);
                      } elsif ($h->{i_voice} eq 'undef') {
                        return ('exd_pa',2,1);
                      }
                  } elsif ($h->{d_subpos} eq 'v') {
                      if ($h->{i_pos} =~ /^(?:x|i|r|t)$/) {
                        return ('exd',0,);
                      } elsif ($h->{i_pos} eq 'nic') {
                        return ('adv',283,5);
                      } elsif ($h->{i_pos} eq 'j') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
                            return ('exd',0,);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('adv',2,);
                          } elsif ($h->{i_lemma} eq 'other') {
                            return ('exd',16,5);
                          } elsif ($h->{i_lemma} eq 'v¹ak') {
                            return ('exd',1,);
                          }
                      } elsif ($h->{i_pos} eq 'z') {
                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                            return ('adv_ap',0,);
                          } elsif ($h->{g_subpos} eq 'b') {
                            return ('exd',3,1);
                          } elsif ($h->{g_subpos} eq 'p') {
                            return ('adv_ap',4,);
                          }
                      }
                  } elsif ($h->{d_subpos} eq 'spec_eq') {
                      if ($h->{i_voice} eq 'nic') {
                          if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
                            return ('obj',0,);
                          } elsif ($h->{d_lemma} eq '1994') {
                            return ('adv',3,1);
                          } elsif ($h->{d_lemma} eq 'other') {
                            return ('obj',1457,648);
                          } elsif ($h->{d_lemma} eq '1') {
                              if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                return ('auxg',0,);
                              } elsif ($h->{g_subpos} eq 'b') {
                                return ('auxg',17,8);
                              } elsif ($h->{g_subpos} eq 'p') {
                                return ('adv',9,4);
                              }
                          }
                      } elsif ($h->{i_voice} eq 'undef') {
                          if ($h->{i_lemma} =~ /^(?:spec_qmark|spec_rpar|spec_dot|aby|po|za|jako|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|do|spec_amperastspec_semicol)$/) {
                            return ('adv',0,);
                          } elsif ($h->{i_lemma} eq 'na') {
                            return ('adv',1,);
                          } elsif ($h->{i_lemma} eq 'spec_ddot') {
                            return ('adv',544,65);
                          } elsif ($h->{i_lemma} eq 'nebo') {
                            return ('adv',5,2);
                          } elsif ($h->{i_lemma} eq 'ale') {
                            return ('obj',3,1);
                          } elsif ($h->{i_lemma} eq 'spec_amperpercntspec_semicol') {
                            return ('atr',28,);
                          } elsif ($h->{i_lemma} eq '¾e') {
                            return ('sb',1,);
                          } elsif ($h->{i_lemma} eq 'spec_lpar') {
                            return ('obj_ap',46,20);
                          } elsif ($h->{i_lemma} eq 'spec_comma') {
                            return ('exd',56,35);
                          } elsif ($h->{i_lemma} eq 'v') {
                            return ('adv',1,);
                          } elsif ($h->{i_lemma} eq 'èi') {
                            return ('sb',1,);
                          } elsif ($h->{i_lemma} eq 'z') {
                            return ('adv',1,);
                          } elsif ($h->{i_lemma} eq 'undef') {
                            return evalSubTree1_S24($h); # [S24]
                          } elsif ($h->{i_lemma} eq 'other') {
                              if ($h->{i_pos} =~ /^(?:nic|x|i|t)$/) {
                                return ('adv',0,);
                              } elsif ($h->{i_pos} eq 'z') {
                                return evalSubTree1_S25($h); # [S25]
                              } elsif ($h->{i_pos} eq 'j') {
                                  if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i)$/) {
                                    return ('obj',0,);
                                  } elsif ($h->{i_subpos} eq 'spec_head') {
                                    return ('obj',222,114);
                                  } elsif ($h->{i_subpos} eq 'spec_aster') {
                                    return ('atr',12,3);
                                  } elsif ($h->{i_subpos} eq 'spec_comma') {
                                      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                        return ('sb',0,);
                                      } elsif ($h->{g_subpos} eq 'b') {
                                        return ('sb',33,20);
                                      } elsif ($h->{g_subpos} eq 'p') {
                                        return ('adv',11,7);
                                      }
                                  }
                              } elsif ($h->{i_pos} eq 'r') {
                                  if ($h->{i_subpos} =~ /^(?:spec_comma|spec_at|spec_ddot|t|nic|f|x|i|spec_head|spec_aster)$/) {
                                    return ('adv',0,);
                                  } elsif ($h->{i_subpos} eq 'r') {
                                    return ('adv',866,350);
                                  } elsif ($h->{i_subpos} eq 'v') {
                                      if ($h->{i_case} =~ /^(?:1|6|nic|x|undef)$/) {
                                        return ('adv',0,);
                                      } elsif ($h->{i_case} eq '3') {
                                        return ('adv',2,);
                                      } elsif ($h->{i_case} eq '4') {
                                        return ('adv',27,);
                                      } elsif ($h->{i_case} eq '7') {
                                        return ('adv',1,);
                                      } elsif ($h->{i_case} eq '2') {
                                          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
                                            return ('exd',0,);
                                          } elsif ($h->{g_subpos} eq 'b') {
                                            return ('obj',3,);
                                          } elsif ($h->{g_subpos} eq 'p') {
                                            return ('exd',11,2);
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
  }
  return '???';
}

# SubTree [S1]

sub evalSubTree1_S1 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|do|ten|zákon|hodnì|stát|spec_dot|rok|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('coord_ap',0,);
  } elsif ($h->{d_lemma} eq 'èi') {
    return ('coord_ap',2,1);
  } elsif ($h->{d_lemma} eq 'nebo') {
    return ('coord',2,);
  } elsif ($h->{d_lemma} eq 'ale') {
    return ('coord',1,);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('coord_ap',79,38);
  }
}

# SubTree [S2]

sub evalSubTree1_S2 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{d_lemma} eq 'pøípad') {
    return ('adv',1,);
  } elsif ($h->{d_lemma} eq 'telefon') {
    return ('obj',5,);
  } elsif ($h->{d_lemma} eq 'podnik') {
    return ('obj',1,);
  } elsif ($h->{d_lemma} eq 'rok') {
    return ('adv',11,5);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('obj',319,109);
  } elsif ($h->{d_lemma} eq 'doba') {
    return ('obj',1,);
  }
}

# SubTree [S3]

sub evalSubTree1_S3 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('exd_ap',0,);
  } elsif ($h->{d_lemma} eq 'koruna') {
    return ('adv',2,);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('exd_ap',10,4);
  }
}

# SubTree [S4]

sub evalSubTree1_S4 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{i_lemma} eq 'spec_lpar') {
    return ('obj_ap',2,);
  } elsif ($h->{i_lemma} eq 'spec_comma') {
    return ('obj',14,6);
  }
}

# SubTree [S5]

sub evalSubTree1_S5 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{d_lemma} eq 'zákon') {
    return ('adv',1,);
  } elsif ($h->{d_lemma} eq 'rok') {
    return ('exd',6,1);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('adv',73,17);
  }
}

# SubTree [S6]

sub evalSubTree1_S6 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{i_lemma} eq 'nebo') {
    return ('atr',2,);
  } elsif ($h->{i_lemma} eq 'other') {
    return ('adv',13,3);
  } elsif ($h->{i_lemma} eq 'èi') {
    return ('atr',1,);
  }
}

# SubTree [S7]

sub evalSubTree1_S7 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
    return ('atr',0,);
  } elsif ($h->{i_lemma} eq 'nebo') {
    return ('adv',4,1);
  } elsif ($h->{i_lemma} eq 'other') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('atr',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('atr',118,60);
      } elsif ($h->{g_subpos} eq 'f') {
        return ('sb',1,);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('adv',15,3);
      }
  } elsif ($h->{i_lemma} eq 'èi') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('sb',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('atr',5,2);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('sb',3,);
      }
  }
}

# SubTree [S8]

sub evalSubTree1_S8 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|k|kdy¾|o|jít|trh|s|já|u|v|být|z|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{d_lemma} eq 'zbo¾í') {
    return ('obj',2,1);
  } elsif ($h->{d_lemma} eq 'koruna') {
    return ('atr',11,3);
  } elsif ($h->{d_lemma} eq 'zákon') {
    return ('adv',2,1);
  } elsif ($h->{d_lemma} eq 'rok') {
    return ('atr',10,1);
  } elsif ($h->{d_lemma} eq 'výroba') {
    return ('adv',2,1);
  } elsif ($h->{d_lemma} eq 'firma') {
    return ('adv',4,2);
  } elsif ($h->{d_lemma} eq 'podnikatel') {
    return ('obj',1,);
  } elsif ($h->{d_lemma} eq 'doba') {
    return ('adv',2,1);
  } elsif ($h->{d_lemma} eq 'èlovìk') {
    return ('atr',7,1);
  } elsif ($h->{d_lemma} eq 'other') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|j|k|l|n|o|2|q|4|r|5|6|u|7|8|v|w|y|z)$/) {
        return ('adv',0,);
      } elsif ($h->{g_subpos} eq 'f') {
        return ('adv',203,115);
      } elsif ($h->{g_subpos} eq 'm') {
        return ('atr',6,1);
      } elsif ($h->{g_subpos} eq 's') {
        return ('adv',110,48);
      } elsif ($h->{g_subpos} eq 'b') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
            return ('atr',0,);
          } elsif ($h->{i_lemma} eq 'nebo') {
            return ('obj',21,13);
          } elsif ($h->{i_lemma} eq 'ale') {
            return ('obj',10,5);
          } elsif ($h->{i_lemma} eq 'other') {
            return ('atr',399,261);
          } elsif ($h->{i_lemma} eq 'èi') {
            return ('atr',30,18);
          }
      } elsif ($h->{g_subpos} eq 'i') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
            return ('adv',0,);
          } elsif ($h->{i_lemma} eq 'nebo') {
            return ('adv',2,);
          } elsif ($h->{i_lemma} eq 'other') {
            return ('atr',6,3);
          } elsif ($h->{i_lemma} eq 'èi') {
            return ('obj',2,);
          }
      } elsif ($h->{g_subpos} eq 'p') {
          if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
            return ('adv',0,);
          } elsif ($h->{i_lemma} eq 'nebo') {
            return ('atr',9,4);
          } elsif ($h->{i_lemma} eq 'ale') {
            return ('obj',7,4);
          } elsif ($h->{i_lemma} eq 'other') {
            return ('adv',268,144);
          } elsif ($h->{i_lemma} eq 'èi') {
            return ('adv',9,);
          }
      }
  }
}

# SubTree [S9]

sub evalSubTree1_S9 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|èeský|spec_amperpercntspec_semicol|zahranièní|02|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|hodnì|stát|nebo|spec_dot|ale|undef|po|malý|v¹echen|nový|1994|jako|muset|který|a|jiný|spec_lpar|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{d_lemma} eq 'telefon') {
    return ('sb',2,1);
  } elsif ($h->{d_lemma} eq 'podnik') {
    return ('adv',1,);
  } elsif ($h->{d_lemma} eq 'zákon') {
    return ('adv',7,);
  } elsif ($h->{d_lemma} eq 'rok') {
    return ('adv',3,);
  } elsif ($h->{d_lemma} eq 'fax') {
    return ('adv',1,);
  } elsif ($h->{d_lemma} eq 'výroba') {
    return ('obj',3,1);
  } elsif ($h->{d_lemma} eq 'firma') {
    return ('adv',1,);
  } elsif ($h->{d_lemma} eq 'podnikatel') {
    return ('obj',1,);
  } elsif ($h->{d_lemma} eq 'other') {
      if ($h->{g_voice} eq 'p') {
        return ('obj',201,93);
      } elsif ($h->{g_voice} eq 'a') {
        return ('adv',771,318);
      } elsif ($h->{g_voice} eq 'undef') {
          if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|b|c|d|spec_hash|g|h|j|k|l|m|n|o|p|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
            return ('adv',0,);
          } elsif ($h->{g_subpos} eq 'e') {
            return ('adv',4,2);
          } elsif ($h->{g_subpos} eq 'f') {
            return ('adv',150,74);
          } elsif ($h->{g_subpos} eq 'i') {
            return ('obj',3,);
          }
      }
  }
}

# SubTree [S10]

sub evalSubTree1_S10 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('adv',5,1);
  } elsif ($h->{d_lemma} eq 'který') {
    return ('obj',99,46);
  }
}

# SubTree [S11]

sub evalSubTree1_S11 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('atr',0,);
  } elsif ($h->{d_lemma} eq 'nìkterý') {
    return ('atr',4,);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('obj',7,3);
  }
}

# SubTree [S12]

sub evalSubTree1_S12 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{d_lemma} eq 'tento') {
    return ('atr',2,);
  } elsif ($h->{d_lemma} eq 'ten') {
      if ($h->{g_voice} eq 'p') {
        return ('auxy',3,);
      } elsif ($h->{g_voice} eq 'a') {
        return ('obj',18,7);
      } elsif ($h->{g_voice} eq 'undef') {
        return ('obj',5,2);
      }
  } elsif ($h->{d_lemma} eq 'other') {
      if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
        return ('exd',0,);
      } elsif ($h->{i_lemma} eq 'ale') {
        return ('exd',4,);
      } elsif ($h->{i_lemma} eq 'other') {
        return ('atr',2,1);
      } elsif ($h->{i_lemma} eq 'èi') {
        return ('obj',2,);
      }
  }
}

# SubTree [S13]

sub evalSubTree1_S13 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
    return ('atr',0,);
  } elsif ($h->{i_lemma} eq 'èi') {
    return ('atr',2,);
  } elsif ($h->{i_lemma} eq 'other') {
      if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
        return ('obj',0,);
      } elsif ($h->{d_lemma} eq 'v¹echen') {
        return ('obj',8,3);
      } elsif ($h->{d_lemma} eq 'other') {
        return ('atr',2,);
      }
  }
}

# SubTree [S14]

sub evalSubTree1_S14 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('exd',0,);
  } elsif ($h->{i_lemma} eq 'jako') {
    return ('exd',12,2);
  } elsif ($h->{i_lemma} eq '¾e') {
    return ('exd',8,3);
  } elsif ($h->{i_lemma} eq 'other') {
      if ($h->{g_lemma} =~ /^(?:zákon|dal¹í|dobrý|hodnì|zbo¾í|rok|tento|pøípad|telefon|èeský|zahranièní|malý|fax|02|v¹echen|podnik|nový|1994|mít|muset|výroba|kè|firma|a|který|jiný|koruna|velký|obchodní|podnikatel|k|doba|první|nìkterý|trh|jít|1|napøíklad|já|èlovìk|ten)$/) {
        return ('adv',0,);
      } elsif ($h->{g_lemma} eq 'other') {
        return ('exd',3,1);
      } elsif ($h->{g_lemma} eq 'být') {
        return ('adv',12,3);
      }
  } elsif ($h->{i_lemma} eq 'kdy¾') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('adv',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('coord',3,2);
      } elsif ($h->{g_subpos} eq 'f') {
        return ('adv_pa',2,1);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('adv',4,1);
      }
  }
}

# SubTree [S15]

sub evalSubTree1_S15 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|1|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|trh|s|já|u|èlovìk|v|z|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{d_lemma} eq 'mít') {
    return ('pred',3,2);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('adv',72,37);
  } elsif ($h->{d_lemma} eq 'jít') {
    return ('pred',2,1);
  } elsif ($h->{d_lemma} eq 'být') {
    return ('pred',9,3);
  }
}

# SubTree [S16]

sub evalSubTree1_S16 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{i_lemma} eq 'jako') {
    return ('exd',1,);
  } elsif ($h->{i_lemma} eq 'other') {
    return ('adv',93,36);
  } elsif ($h->{i_lemma} eq '¾e') {
    return ('obj',175,21);
  } elsif ($h->{i_lemma} eq 'kdy¾') {
    return ('adv',10,);
  }
}

# SubTree [S17]

sub evalSubTree1_S17 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{i_lemma} eq 'spec_ddot') {
    return ('obj_ap',10,5);
  } elsif ($h->{i_lemma} eq 'spec_lpar') {
    return ('atr',1,);
  } elsif ($h->{i_lemma} eq 'spec_comma') {
    return ('obj',96,19);
  } elsif ($h->{i_lemma} eq 'undef') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('sb_ap',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('sb_ap',8,2);
      } elsif ($h->{g_subpos} eq 'f') {
        return ('obj_ap',1,);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('obj_ap',5,2);
      }
  }
}

# SubTree [S18]

sub evalSubTree1_S18 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|nebo|spec_dot|aby|ale|undef|spec_amperpercntspec_semicol|po|za|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|spec_comma|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{i_lemma} eq 'jako') {
    return ('exd',2,);
  } elsif ($h->{i_lemma} eq 'other') {
    return ('adv',15,3);
  } elsif ($h->{i_lemma} eq '¾e') {
    return ('sb',13,2);
  }
}

# SubTree [S19]

sub evalSubTree1_S19 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|other|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('sb',0,);
  } elsif ($h->{i_lemma} eq 'spec_ddot') {
    return ('sb_ap',5,1);
  } elsif ($h->{i_lemma} eq 'undef') {
    return ('sb_ap',1,);
  } elsif ($h->{i_lemma} eq 'spec_lpar') {
    return ('sb_ap',2,1);
  } elsif ($h->{i_lemma} eq 'spec_comma') {
    return ('sb',41,5);
  }
  return '???';
}

# SubTree [S20]

sub evalSubTree1_S20 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|spec_amperpercntspec_semicol|po|za|jako|nic|od|pro|mezi|k|pøi|o|s|u|v|z|do|spec_amperastspec_semicol)$/) {
    return ('obj_ap',0,);
  } elsif ($h->{i_lemma} eq 'spec_ddot') {
    return ('obj_ap',5,2);
  } elsif ($h->{i_lemma} eq 'nebo') {
    return ('obj',4,2);
  } elsif ($h->{i_lemma} eq 'aby') {
    return ('adv',21,1);
  } elsif ($h->{i_lemma} eq 'ale') {
    return ('atr',1,);
  } elsif ($h->{i_lemma} eq 'undef') {
    return ('obj_ap',9,3);
  } elsif ($h->{i_lemma} eq 'other') {
    return ('adv',183,27);
  } elsif ($h->{i_lemma} eq 'spec_lpar') {
    return ('adv_ap',1,);
  } elsif ($h->{i_lemma} eq 'kdy¾') {
    return ('adv',35,1);
  } elsif ($h->{i_lemma} eq 'v¹ak') {
    return ('pred',1,);
  } elsif ($h->{i_lemma} eq 'èi') {
    return ('pred',2,);
  } elsif ($h->{i_lemma} eq '¾e') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('obj',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('obj',12,4);
      } elsif ($h->{g_subpos} eq 'f') {
        return ('adv',1,);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('adv',2,);
      }
  } elsif ($h->{i_lemma} eq 'spec_comma') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('obj',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('obj',4,1);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('atr',3,);
      }
  }
  return '???';
}

# SubTree [S21]

sub evalSubTree1_S21 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_ddot|spec_dot|undef|spec_amperpercntspec_semicol|po|za|jako|nic|od|spec_lpar|pro|mezi|k|pøi|spec_comma|o|s|v¹ak|u|v|z|do|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{i_lemma} eq 'aby') {
    return ('sb',128,43);
  } elsif ($h->{i_lemma} eq 'ale') {
    return ('sb',20,10);
  } elsif ($h->{i_lemma} eq 'kdy¾') {
    return ('adv',108,8);
  } elsif ($h->{i_lemma} eq 'nebo') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('adv',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('sb',11,5);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('adv',5,);
      }
  } elsif ($h->{i_lemma} eq '¾e') {
      if ($h->{g_voice} eq 'p') {
        return ('sb',0,);
      } elsif ($h->{g_voice} eq 'a') {
        return ('sb',377,64);
      } elsif ($h->{g_voice} eq 'undef') {
        return ('adv',3,);
      }
  } elsif ($h->{i_lemma} eq 'èi') {
      if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
        return ('sb',0,);
      } elsif ($h->{d_subpos} eq 'b') {
        return ('sb',7,3);
      } elsif ($h->{d_subpos} eq 'p') {
        return ('adv',3,);
      }
  } elsif ($h->{i_lemma} eq 'other') {
      if ($h->{i_subpos} =~ /^(?:spec_at|r|spec_ddot|t|nic|f|v|x|i|spec_aster)$/) {
        return ('adv',0,);
      } elsif ($h->{i_subpos} eq 'spec_comma') {
        return ('adv',357,50);
      } elsif ($h->{i_subpos} eq 'spec_head') {
          if ($h->{g_voice} eq 'p') {
            return ('sb',0,);
          } elsif ($h->{g_voice} eq 'a') {
            return ('sb',222,113);
          } elsif ($h->{g_voice} eq 'undef') {
            return ('adv',6,);
          }
      }
  }
  return '???';
}

# SubTree [S22]

sub evalSubTree1_S22 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|nebo|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('sb',0,);
  } elsif ($h->{i_lemma} eq 'other') {
    return ('sb',2,);
  } elsif ($h->{i_lemma} eq 'spec_lpar') {
    return ('sb_ap',3,2);
  } elsif ($h->{i_lemma} eq 'spec_ddot') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('sb_ap',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('sb_ap',18,8);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('adv',2,1);
      }
  } elsif ($h->{i_lemma} eq 'spec_comma') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|f|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('sb',0,);
      } elsif ($h->{g_subpos} eq 'b') {
        return ('sb',24,11);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('atr',13,7);
      }
  } elsif ($h->{i_lemma} eq 'undef') {
      if ($h->{g_subpos} =~ /^(?:spec_qmark|spec_eq|spec_rbrace|a|c|d|e|spec_hash|g|h|i|j|k|l|m|n|o|2|q|4|r|s|5|6|u|7|8|v|w|y|z)$/) {
        return ('sb_ap',0,);
      } elsif ($h->{g_subpos} eq 'f') {
        return ('adv_ap',2,);
      } elsif ($h->{g_subpos} eq 'p') {
        return ('atr',3,);
      } elsif ($h->{g_subpos} eq 'b') {
          if ($h->{d_subpos} =~ /^(?:spec_qmark|spec_ddot|spec_head|spec_at|spec_eq|spec_rbrace|a|c|d|e|f|g|h|i|j|k|spec_aster|l|m|n|o|spec_comma|1|2|q|4|r|s|5|t|6|7|u|8|v|w|9|x|y|z)$/) {
            return ('sb_ap',0,);
          } elsif ($h->{d_subpos} eq 'b') {
            return ('sb',6,4);
          } elsif ($h->{d_subpos} eq 'p') {
            return ('sb_ap',4,);
          }
      }
  }
  return '???';
}

# SubTree [S23]

sub evalSubTree1_S23 { 
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:spec_qmark|na|spec_rpar|spec_dot|aby|ale|spec_amperpercntspec_semicol|po|za|jako|¾e|nic|od|spec_lpar|pro|mezi|k|pøi|kdy¾|o|s|v¹ak|u|v|èi|z|do|spec_amperastspec_semicol)$/) {
    return ('exd',0,);
  } elsif ($h->{i_lemma} eq 'spec_ddot') {
    return ('exd_ap',1,);
  } elsif ($h->{i_lemma} eq 'nebo') {
    return ('exd',2,);
  } elsif ($h->{i_lemma} eq 'undef') {
    return ('exd',4,);
  } elsif ($h->{i_lemma} eq 'other') {
    return ('obj',3,);
  } elsif ($h->{i_lemma} eq 'spec_comma') {
    return ('exd',6,2);
  }
  return "???";
}

# SubTree [S24]

sub evalSubTree1_S24 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|02|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('adv',0,);
  } elsif ($h->{d_lemma} eq '1') {
    return ('exd',2,);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('adv',123,80);
  }
  return "???";
}

# SubTree [S25]

sub evalSubTree1_S25 { 
  my $h=$_[0];

  if ($h->{d_lemma} =~ /^(?:spec_qmark|dal¹í|na|dobrý|spec_rpar|daò|spec_ddot|zbo¾í|aby|tento|spec_quot|pøípad|telefon|èeský|spec_amperpercntspec_semicol|zahranièní|podnik|za|mít|kè|¾e|koruna|velký|obchodní|od|mùj|mezi|pøi|první|nìkterý|on|spec_comma|napøíklad|v¹ak|èi|do|ten|zákon|hodnì|stát|nebo|spec_dot|rok|ale|undef|po|malý|fax|v¹echen|nový|1994|jako|muset|výroba|firma|který|a|jiný|spec_lpar|podnikatel|pro|doba|k|kdy¾|o|jít|trh|s|já|u|èlovìk|v|být|z|spec_amperastspec_semicol)$/) {
    return ('obj',0,);
  } elsif ($h->{d_lemma} eq '02') {
    return ('atr',2,);
  } elsif ($h->{d_lemma} eq '1') {
    return ('sb',5,2);
  } elsif ($h->{d_lemma} eq 'other') {
    return ('obj',21,11);
  }
  return "???";
}

# 
# Evaluation on training data (1130083 cases):
# 
# 	    Decision Tree   
# 	  ----------------  
# 	  Size      Errors  
# 
# 	  3571 99032( 8.8%)   <<
# 
# 
# Evaluation on test data (125507 cases):
# 
# 	    Decision Tree   
# 	  ----------------  
# 	  Size      Errors  
# 
# 	  3571 11404( 9.1%)   <<
# 
# 
# Time: 241.0 secs

1;
