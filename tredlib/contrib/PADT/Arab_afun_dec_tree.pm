# -*- cperl -*-
# This file was automatically generated with decision_trees2perl.pl
# by smrz@golias.ms.mff.cuni.cz <Thu Jun 10 10:39:13 2004>

package Arab_afun_dec_tree;

use Exporter;
use strict;
use vars qw(@ISA @EXPORT_OK);

BEGIN {
  @ISA=qw(Exporter);
  @EXPORT_OK=qw(evalTree);
}

#
# C5.0 [Release 1.16]   Thu Jun 10 08:38:09 2004
# -------------------
#
#     Options:
#   Application `new/exp'
#   Pruning confidence level 60%
#   Cross-validate using 10 folds
#
# Read 63090 cases (16 attributes) from new/exp.data
#
#
# [ Fold 0 ]
#

sub evalTree {
  my $h=$_[0];

  if ($h->{g_voice} eq 'empty') {
      if ($h->{d_pos} =~ /^(?:F|T|X|Q|I|empty)$/) {
        return ('Atr',0,);
      } elsif ($h->{d_pos} eq 'S') {
        return ('AuxY',1,);
      } elsif ($h->{d_pos} eq 'A') {
        return ('Atr',4,);
      } elsif ($h->{d_pos} eq 'undef') {
        return ('AuxY',1,);
      } elsif ($h->{d_pos} eq 'P') {
        return ('AuxP',4,1);
      } elsif ($h->{d_pos} eq 'Y') {
        return ('Atr',2,);
      } elsif ($h->{d_pos} eq 'V') {
        return ('Atr',2,1);
      } elsif ($h->{d_pos} eq 'Z') {
        return ('Atr',3,);
      } elsif ($h->{d_pos} eq 'D') {
        return ('Adv',1,);
      } elsif ($h->{d_pos} eq 'C') {
        return ('Coord',2,1);
      } elsif ($h->{d_pos} eq 'G') {
        return ('AuxG',5,);
      } elsif ($h->{d_pos} eq 'N') {
          if ($h->{g_children} eq '1') {
            return ('Atr',17,);
          } elsif ($h->{g_children} eq 'more') {
              if ($h->{d_defin} =~ /^(?:D|X|undef|empty)$/) {
                return ('AdvAtr',0,);
              } elsif ($h->{d_defin} eq 'R') {
                return ('AdvAtr',4,2);
              } elsif ($h->{d_defin} eq 'I') {
                return ('Atr',2,);
              }
          }
      }
  } elsif ($h->{g_voice} eq 'P') {
      if ($h->{d_pos} =~ /^(?:T|X|Y|I|empty)$/) {
        return ('AuxP',0,);
      } elsif ($h->{d_pos} eq 'F') {
        return ('AuxM',2,1);
      } elsif ($h->{d_pos} eq 'S') {
        return ('AuxY',4,1);
      } elsif ($h->{d_pos} eq 'undef') {
        return ('Obj',2,1);
      } elsif ($h->{d_pos} eq 'P') {
        return ('AuxP',26,);
      } elsif ($h->{d_pos} eq 'Z') {
        return ('Sb',1,);
      } elsif ($h->{d_pos} eq 'Q') {
        return ('Sb',4,);
      } elsif ($h->{d_pos} eq 'D') {
        return ('Adv',5,1);
      } elsif ($h->{d_pos} eq 'G') {
        return ('AuxG',3,);
      } elsif ($h->{d_pos} eq 'A') {
          if ($h->{d_children} eq '0') {
            return ('Obj',0,);
          } elsif ($h->{d_children} eq '1') {
            return ('Obj',2,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Pnom',2,1);
          }
      } elsif ($h->{d_pos} eq 'C') {
          if ($h->{d_children} eq '1') {
            return ('AuxC',8,);
          } elsif ($h->{d_children} eq '0') {
            return ('AuxY',3,);
          } elsif ($h->{d_children} eq 'more') {
            return ('AuxC',7,2);
          }
      } elsif ($h->{d_pos} eq 'V') {
          if ($h->{g_children} eq '1') {
            return ('Sb',6,);
          } elsif ($h->{g_children} eq 'more') {
              if ($h->{d_subpos} =~ /^(?:N|undef|D|C|R|empty)$/) {
                return ('Adv',0,);
              } elsif ($h->{d_subpos} eq 'P') {
                return ('Adv',6,2);
              } elsif ($h->{d_subpos} eq 'I') {
                return ('Obj',2,);
              }
          }
      } elsif ($h->{d_pos} eq 'N') {
          if ($h->{g_verbmod} =~ /^(?:D|empty|root)$/) {
            return ('Sb',0,);
          } elsif ($h->{g_verbmod} eq 'S') {
            return ('Obj',2,1);
          } elsif ($h->{g_verbmod} eq 'I') {
              if ($h->{d_children} eq '1') {
                return ('Pnom',3,1);
              } elsif ($h->{d_children} eq '0') {
                return ('Sb',2,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Sb',2,);
              }
          } elsif ($h->{g_verbmod} eq 'undef') {
              if ($h->{g_children} eq '1') {
                return ('Sb',4,);
              } elsif ($h->{g_children} eq 'more') {
                  if ($h->{d_case} =~ /^(?:3|empty|2)$/) {
                    return ('Adv',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('Atv',1,);
                  } elsif ($h->{d_case} eq '4') {
                    return ('Adv',7,2);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('Sb',3,1);
                  }
              }
          }
      }
  } elsif ($h->{g_voice} eq 'root') {
      if ($h->{d_pos} eq 'T') {
        return ('Pred',0,);
      } elsif ($h->{d_pos} eq 'Y') {
        return ('ExD',95,1);
      } elsif ($h->{d_pos} eq 'V') {
        return ('Pred',1589,14);
      } elsif ($h->{d_pos} eq 'Z') {
        return ('ExD',57,3);
      } elsif ($h->{d_pos} eq 'I') {
        return ('Sb',1,);
      } elsif ($h->{d_pos} eq 'A') {
          if ($h->{d_children} eq '1') {
            return ('ExD',1,);
          } elsif ($h->{d_children} eq '0') {
            return ('ExD',2,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Pnom',8,3);
          }
      } elsif ($h->{d_pos} eq 'undef') {
          if ($h->{g_position} eq 'left') {
            return ('ExD',4,2);
          } elsif ($h->{g_position} eq 'right') {
            return ('Pred',3,);
          }
      } elsif ($h->{d_pos} eq 'P') {
          if ($h->{d_children} eq '1') {
            return ('AuxP',30,2);
          } elsif ($h->{d_children} eq '0') {
            return ('AuxE',1,);
          } elsif ($h->{d_children} eq 'more') {
            return ('PredP',34,22);
          }
      } elsif ($h->{d_pos} eq 'Q') {
          if ($h->{d_children} eq '1') {
            return ('ExD',9,);
          } elsif ($h->{d_children} eq '0') {
            return ('ExD',6,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Pnom',7,);
          }
      } elsif ($h->{d_pos} eq 'empty') {
          if ($h->{d_children} eq '1') {
            return ('ExD',7,);
          } elsif ($h->{d_children} eq '0') {
            return ('AuxK',1,);
          } elsif ($h->{d_children} eq 'more') {
            return ('ExD',2,1);
          }
      } elsif ($h->{d_pos} eq 'S') {
          if ($h->{d_subpos} =~ /^(?:N|P|C|I|empty)$/) {
            return ('Pnom',0,);
          } elsif ($h->{d_subpos} eq 'undef') {
            return ('Sb',2,1);
          } elsif ($h->{d_subpos} eq 'D') {
              if ($h->{g_position} eq 'left') {
                return ('Sb',4,2);
              } elsif ($h->{g_position} eq 'right') {
                return ('ExD',2,);
              }
          } elsif ($h->{d_subpos} eq 'R') {
              if ($h->{d_children} eq '0') {
                return ('Pnom',0,);
              } elsif ($h->{d_children} eq '1') {
                return ('ExD',4,2);
              } elsif ($h->{d_children} eq 'more') {
                return ('Pnom',11,6);
              }
          }
      } elsif ($h->{d_pos} eq 'X') {
          if ($h->{d_children} eq '1') {
            return ('Pred',18,10);
          } elsif ($h->{d_children} eq '0') {
              if ($h->{g_position} eq 'left') {
                return ('AuxK',1304,122);
              } elsif ($h->{g_position} eq 'right') {
                return ('ExD',60,);
              }
          } elsif ($h->{d_children} eq 'more') {
              if ($h->{g_position} eq 'left') {
                return ('ExD',77,37);
              } elsif ($h->{g_position} eq 'right') {
                return ('Pred',25,6);
              }
          }
      } elsif ($h->{d_pos} eq 'D') {
          if ($h->{g_position} eq 'right') {
            return ('AuxP',5,2);
          } elsif ($h->{g_position} eq 'left') {
              if ($h->{d_children} eq '1') {
                return ('Pred',6,3);
              } elsif ($h->{d_children} eq '0') {
                return ('ExD',3,1);
              } elsif ($h->{d_children} eq 'more') {
                return ('Pred',6,3);
              }
          }
      } elsif ($h->{d_pos} eq 'C') {
          if ($h->{d_children} eq '0') {
            return ('AuxY',1049,);
          } elsif ($h->{d_children} eq 'more') {
            return ('Coord',240,7);
          } elsif ($h->{d_children} eq '1') {
              if ($h->{g_position} eq 'left') {
                return ('AuxC',7,4);
              } elsif ($h->{g_position} eq 'right') {
                return ('Coord',20,6);
              }
          }
      } elsif ($h->{d_pos} eq 'G') {
          if ($h->{g_position} eq 'left') {
            return ('AuxK',285,16);
          } elsif ($h->{g_position} eq 'right') {
              if ($h->{g_children} eq '1') {
                return ('AuxK',8,);
              } elsif ($h->{g_children} eq 'more') {
                return ('AuxG',4,);
              }
          }
      } elsif ($h->{d_pos} eq 'F') {
          if ($h->{g_children} eq '1') {
            return ('AuxY',2,);
          } elsif ($h->{g_children} eq 'more') {
              if ($h->{d_subpos} =~ /^(?:P|D|C|R|empty)$/) {
                return ('Coord',0,);
              } elsif ($h->{d_subpos} eq 'I') {
                return ('ExD',1,);
              } elsif ($h->{d_subpos} eq 'N') {
                  if ($h->{d_children} eq '0') {
                    return ('Coord',0,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Coord',6,1);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Pred',3,1);
                  }
              } elsif ($h->{d_subpos} eq 'undef') {
                  if ($h->{d_children} eq '0') {
                    return ('AuxM',1,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('PredC',7,5);
                  } elsif ($h->{d_children} eq '1') {
                      if ($h->{g_position} eq 'left') {
                        return ('AuxC',8,5);
                      } elsif ($h->{g_position} eq 'right') {
                        return ('AuxP',2,);
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'N') {
          if ($h->{d_case} eq 'empty') {
            return ('ExD',0,);
          } elsif ($h->{d_case} eq '1') {
            return ('ExD',30,4);
          } elsif ($h->{d_case} eq '3') {
            return ('Ante',1,);
          } elsif ($h->{d_case} eq '2') {
              if ($h->{d_defin} =~ /^(?:D|X|undef|empty)$/) {
                return ('Pred',0,);
              } elsif ($h->{d_defin} eq 'R') {
                return ('ExD',2,1);
              } elsif ($h->{d_defin} eq 'I') {
                return ('Pred',3,);
              }
          } elsif ($h->{d_case} eq '4') {
              if ($h->{d_children} eq '0') {
                return ('Adv',1,);
              } elsif ($h->{d_children} eq 'more') {
                return ('Adv',2,1);
              } elsif ($h->{d_children} eq '1') {
                  if ($h->{d_defin} =~ /^(?:D|X|undef|empty)$/) {
                    return ('AuxP',0,);
                  } elsif ($h->{d_defin} eq 'R') {
                    return ('AuxP',2,);
                  } elsif ($h->{d_defin} eq 'I') {
                    return ('ExD',2,1);
                  }
              }
          } elsif ($h->{d_case} eq 'undef') {
              if ($h->{d_children} eq '1') {
                return ('ExD',21,8);
              } elsif ($h->{d_children} eq '0') {
                return ('ExD',7,1);
              } elsif ($h->{d_children} eq 'more') {
                  if ($h->{g_position} eq 'right') {
                    return ('ExD',4,);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{g_children} eq '1') {
                        return ('ExD',2,);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('Pnom',35,11);
                      }
                  }
              }
          }
      }
  } elsif ($h->{g_voice} eq 'undef') {
      if ($h->{d_pos} eq 'T') {
        return ('Obj',5,3);
      } elsif ($h->{d_pos} eq 'I') {
        return ('AuxM',1,);
      } elsif ($h->{d_pos} eq 'empty') {
          if ($h->{g_subpos} =~ /^(?:N|C|D|R|root|empty)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_subpos} eq 'undef') {
            return ('Atr',25,);
          } elsif ($h->{g_subpos} eq 'P') {
            return ('Obj',4,2);
          } elsif ($h->{g_subpos} eq 'I') {
            return ('Obj',1,);
          }
      } elsif ($h->{d_pos} eq 'Q') {
          if ($h->{g_pos} =~ /^(?:T|X|P|Y|Q|D|I|empty|root)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_pos} eq 'S') {
            return ('Atr',2,);
          } elsif ($h->{g_pos} eq 'F') {
            return ('Obj',1,);
          } elsif ($h->{g_pos} eq 'undef') {
            return ('Adv',2,1);
          } elsif ($h->{g_pos} eq 'N') {
            return ('Atr',37,6);
          } elsif ($h->{g_pos} eq 'Z') {
            return ('ExD',2,);
          } elsif ($h->{g_pos} eq 'A') {
              if ($h->{g_position} eq 'left') {
                return ('Obj',7,2);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',2,);
              }
          } elsif ($h->{g_pos} eq 'V') {
              if ($h->{g_position} eq 'left') {
                return ('Obj',17,5);
              } elsif ($h->{g_position} eq 'right') {
                return ('Sb',3,1);
              }
          } elsif ($h->{g_pos} eq 'G') {
              if ($h->{d_children} eq '1') {
                return ('Obj',1,);
              } elsif ($h->{d_children} eq '0') {
                return ('Atr',5,1);
              } elsif ($h->{d_children} eq 'more') {
                return ('Obj',3,);
              }
          }
      } elsif ($h->{d_pos} eq 'G') {
          if ($h->{d_children} eq '1') {
            return ('AuxG',2,);
          } elsif ($h->{d_children} eq '0') {
            return ('AuxG',311,26);
          } elsif ($h->{d_children} eq 'more') {
              if ($h->{g_children} eq '1') {
                return ('Coord',3,);
              } elsif ($h->{g_children} eq 'more') {
                return ('Apos',9,3);
              }
          }
      } elsif ($h->{d_pos} eq 'C') {
          if ($h->{d_children} eq '0') {
            return ('AuxY',468,28);
          } elsif ($h->{d_children} eq 'more') {
            return ('Coord',2386,75);
          } elsif ($h->{d_children} eq '1') {
              if ($h->{g_position} eq 'left') {
                return ('AuxC',404,78);
              } elsif ($h->{g_position} eq 'right') {
                  if ($h->{g_subpos} =~ /^(?:N|C|D|R|root|empty)$/) {
                    return ('AuxC',0,);
                  } elsif ($h->{g_subpos} eq 'undef') {
                    return ('AuxE',6,3);
                  } elsif ($h->{g_subpos} eq 'P') {
                    return ('AuxP',10,4);
                  } elsif ($h->{g_subpos} eq 'I') {
                    return ('AuxC',8,1);
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'X') {
          if ($h->{d_children} eq '1') {
              if ($h->{g_subpos} =~ /^(?:N|C|root|empty)$/) {
                return ('Atr',0,);
              } elsif ($h->{g_subpos} eq 'D') {
                return ('AuxG',1,);
              } elsif ($h->{g_subpos} eq 'P') {
                  if ($h->{g_position} eq 'left') {
                    return ('AuxP',115,70);
                  } elsif ($h->{g_position} eq 'right') {
                    return ('Sb',4,2);
                  }
              } elsif ($h->{g_subpos} eq 'R') {
                  if ($h->{g_children} eq '1') {
                    return ('Atr',5,1);
                  } elsif ($h->{g_children} eq 'more') {
                    return ('ExD',2,1);
                  }
              } elsif ($h->{g_subpos} eq 'undef') {
                  if ($h->{g_pos} =~ /^(?:S|T|undef|P|V|Q|I|G|empty|root)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_pos} eq 'A') {
                    return ('Atr',7,1);
                  } elsif ($h->{g_pos} eq 'N') {
                    return ('Atr',365,110);
                  } elsif ($h->{g_pos} eq 'X') {
                    return ('Atr',304,165);
                  } elsif ($h->{g_pos} eq 'Y') {
                    return ('Adv',1,);
                  } elsif ($h->{g_pos} eq 'Z') {
                    return ('Atr',7,);
                  } elsif ($h->{g_pos} eq 'D') {
                    return ('AuxP',14,9);
                  } elsif ($h->{g_pos} eq 'F') {
                      if ($h->{g_children} eq '1') {
                        return ('Obj',10,7);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('AuxG',5,3);
                      }
                  }
              } elsif ($h->{g_subpos} eq 'I') {
                  if ($h->{g_position} eq 'right') {
                    return ('Sb',4,1);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{g_children} eq '1') {
                        return ('Obj',20,9);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('AuxP',86,50);
                      }
                  }
              }
          } elsif ($h->{d_children} eq '0') {
              if ($h->{g_children} eq 'more') {
                return ('AuxG',2247,597);
              } elsif ($h->{g_children} eq '1') {
                  if ($h->{g_position} eq 'left') {
                    return ('AuxG',1029,231);
                  } elsif ($h->{g_position} eq 'right') {
                      if ($h->{g_pos} =~ /^(?:A|T|undef|P|Q|D|I|G|empty|root)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{g_pos} eq 'S') {
                        return ('AuxG',1,);
                      } elsif ($h->{g_pos} eq 'F') {
                        return ('AuxG',3,1);
                      } elsif ($h->{g_pos} eq 'N') {
                        return ('Atr',7,3);
                      } elsif ($h->{g_pos} eq 'X') {
                        return ('Atr',62,6);
                      } elsif ($h->{g_pos} eq 'Y') {
                        return ('AuxG',2,);
                      } elsif ($h->{g_pos} eq 'V') {
                        return ('AuxG',1,);
                      } elsif ($h->{g_pos} eq 'Z') {
                        return ('Atr',12,2);
                      }
                  }
              }
          } elsif ($h->{d_children} eq 'more') {
              if ($h->{g_pos} =~ /^(?:T|P|Q|I|G|empty|root)$/) {
                return ('Atr',0,);
              } elsif ($h->{g_pos} eq 'A') {
                return ('Atr',4,1);
              } elsif ($h->{g_pos} eq 'F') {
                return ('Obj',30,5);
              } elsif ($h->{g_pos} eq 'undef') {
                return ('Obj',1,);
              } elsif ($h->{g_pos} eq 'Y') {
                return ('Coord',18,3);
              } elsif ($h->{g_pos} eq 'S') {
                  if ($h->{g_children} eq '1') {
                    return ('Atr',4,1);
                  } elsif ($h->{g_children} eq 'more') {
                    return ('Adv',4,2);
                  }
              } elsif ($h->{g_pos} eq 'N') {
                  if ($h->{g_position} eq 'left') {
                    return ('Atr',255,83);
                  } elsif ($h->{g_position} eq 'right') {
                    return ('Sb',3,1);
                  }
              } elsif ($h->{g_pos} eq 'Z') {
                  if ($h->{g_children} eq '1') {
                    return ('ExD',4,1);
                  } elsif ($h->{g_children} eq 'more') {
                    return ('Atr',4,2);
                  }
              } elsif ($h->{g_pos} eq 'D') {
                  if ($h->{g_children} eq '1') {
                    return ('Atr',6,4);
                  } elsif ($h->{g_children} eq 'more') {
                    return ('ExD',2,1);
                  }
              } elsif ($h->{g_pos} eq 'X') {
                  if ($h->{g_position} eq 'right') {
                    return ('Sb',15,11);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{g_children} eq '1') {
                        return ('Apos',63,47);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('Atr',50,30);
                      }
                  }
              } elsif ($h->{g_pos} eq 'V') {
                  if ($h->{g_position} eq 'right') {
                    return ('Sb',6,1);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                        return ('Obj',0,);
                      } elsif ($h->{g_subpos} eq 'P') {
                        return ('Sb',41,28);
                      } elsif ($h->{g_subpos} eq 'I') {
                        return ('Obj',51,27);
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'F') {
          if ($h->{g_position} eq 'left') {
              if ($h->{d_subpos} =~ /^(?:P|D|C|R|empty)$/) {
                return ('AuxC',0,);
              } elsif ($h->{d_subpos} eq 'I') {
                return ('Obj',2,);
              } elsif ($h->{d_subpos} eq 'undef') {
                  if ($h->{d_children} eq '1') {
                    return ('AuxC',610,20);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('AuxC',79,5);
                  } elsif ($h->{d_children} eq '0') {
                      if ($h->{g_pos} =~ /^(?:A|S|T|undef|X|P|Y|Q|D|I|G|empty|root)$/) {
                        return ('AuxY',0,);
                      } elsif ($h->{g_pos} eq 'F') {
                        return ('AuxY',3,1);
                      } elsif ($h->{g_pos} eq 'N') {
                        return ('Atr',1,);
                      } elsif ($h->{g_pos} eq 'V') {
                        return ('AuxE',2,1);
                      } elsif ($h->{g_pos} eq 'Z') {
                        return ('Atr',1,);
                      }
                  }
              } elsif ($h->{d_subpos} eq 'N') {
                  if ($h->{g_pos} =~ /^(?:A|T|undef|X|P|Z|Q|I|G|empty|root)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_pos} eq 'S') {
                    return ('ExD',2,1);
                  } elsif ($h->{g_pos} eq 'F') {
                    return ('Obj',13,4);
                  } elsif ($h->{g_pos} eq 'N') {
                    return ('Atr',42,3);
                  } elsif ($h->{g_pos} eq 'Y') {
                    return ('AtrAdv',1,);
                  } elsif ($h->{g_pos} eq 'D') {
                    return ('Obj',1,);
                  } elsif ($h->{g_pos} eq 'V') {
                      if ($h->{d_children} eq '0') {
                        return ('AuxY',2,);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Obj',4,2);
                      } elsif ($h->{d_children} eq '1') {
                          if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                            return ('Obj',0,);
                          } elsif ($h->{g_subpos} eq 'P') {
                            return ('Obj',4,2);
                          } elsif ($h->{g_subpos} eq 'I') {
                            return ('Atr',4,3);
                          }
                      }
                  }
              }
          } elsif ($h->{g_position} eq 'right') {
              if ($h->{d_children} eq 'more') {
                return ('AuxE',13,4);
              } elsif ($h->{d_children} eq '1') {
                  if ($h->{d_subpos} =~ /^(?:P|D|C|R|empty)$/) {
                    return ('AuxE',0,);
                  } elsif ($h->{d_subpos} eq 'N') {
                    return ('AuxM',5,2);
                  } elsif ($h->{d_subpos} eq 'undef') {
                    return ('AuxE',22,4);
                  } elsif ($h->{d_subpos} eq 'I') {
                    return ('AuxM',1,);
                  }
              } elsif ($h->{d_children} eq '0') {
                  if ($h->{g_subpos} =~ /^(?:N|C|R|root|empty)$/) {
                    return ('AuxM',0,);
                  } elsif ($h->{g_subpos} eq 'D') {
                    return ('AuxY',1,);
                  } elsif ($h->{g_subpos} eq 'I') {
                    return ('AuxM',472,18);
                  } elsif ($h->{g_subpos} eq 'P') {
                      if ($h->{d_subpos} =~ /^(?:P|D|C|I|R|empty)$/) {
                        return ('AuxE',0,);
                      } elsif ($h->{d_subpos} eq 'N') {
                        return ('AuxM',10,);
                      } elsif ($h->{d_subpos} eq 'undef') {
                        return ('AuxE',50,19);
                      }
                  } elsif ($h->{g_subpos} eq 'undef') {
                      if ($h->{d_subpos} =~ /^(?:P|D|C|I|R|empty)$/) {
                        return ('AuxM',0,);
                      } elsif ($h->{d_subpos} eq 'N') {
                        return ('AuxM',25,5);
                      } elsif ($h->{d_subpos} eq 'undef') {
                          if ($h->{g_pos} =~ /^(?:A|T|X|P|Y|V|Z|Q|D|I|G|empty|root)$/) {
                            return ('AuxE',0,);
                          } elsif ($h->{g_pos} eq 'S') {
                            return ('AuxE',1,);
                          } elsif ($h->{g_pos} eq 'F') {
                            return ('AuxY',5,2);
                          } elsif ($h->{g_pos} eq 'undef') {
                            return ('AuxM',1,);
                          } elsif ($h->{g_pos} eq 'N') {
                            return ('AuxE',11,5);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'undef') {
          if ($h->{g_verbmod} =~ /^(?:S|D|empty|root)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_verbmod} eq 'I') {
              if ($h->{g_position} eq 'left') {
                return ('ExD',2,1);
              } elsif ($h->{g_position} eq 'right') {
                return ('AuxP',2,1);
              }
          } elsif ($h->{g_verbmod} eq 'undef') {
              if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                return ('Atr',0,);
              } elsif ($h->{d_defin} eq 'X') {
                return ('AuxY',8,4);
              } elsif ($h->{d_defin} eq 'undef') {
                  if ($h->{g_subpos} =~ /^(?:N|C|D|root|empty)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_subpos} eq 'undef') {
                    return ('Atr',164,39);
                  } elsif ($h->{g_subpos} eq 'R') {
                    return ('Atr',1,);
                  } elsif ($h->{g_subpos} eq 'I') {
                      if ($h->{d_children} eq '1') {
                        return ('Sb',0,);
                      } elsif ($h->{d_children} eq '0') {
                        return ('Atr',2,1);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Sb',4,2);
                      }
                  } elsif ($h->{g_subpos} eq 'P') {
                      if ($h->{g_position} eq 'right') {
                        return ('AuxP',4,1);
                      } elsif ($h->{g_position} eq 'left') {
                          if ($h->{d_children} eq '1') {
                            return ('Obj',7,5);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Sb',6,2);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',7,4);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'P') {
          if ($h->{d_children} eq '1') {
            return ('AuxP',14504,817);
          } elsif ($h->{d_children} eq '0') {
              if ($h->{g_pos} =~ /^(?:A|T|P|Y|I|G|empty|root)$/) {
                return ('AuxY',0,);
              } elsif ($h->{g_pos} eq 'S') {
                return ('AuxY',5,);
              } elsif ($h->{g_pos} eq 'F') {
                return ('AuxY',2,);
              } elsif ($h->{g_pos} eq 'undef') {
                return ('Adv',1,);
              } elsif ($h->{g_pos} eq 'N') {
                return ('AuxY',18,7);
              } elsif ($h->{g_pos} eq 'Z') {
                return ('spec_qmarkspec_qmarkspec_qmark',1,);
              } elsif ($h->{g_pos} eq 'Q') {
                return ('Atr',4,1);
              } elsif ($h->{g_pos} eq 'D') {
                return ('AuxY',3,);
              } elsif ($h->{g_pos} eq 'X') {
                  if ($h->{g_position} eq 'left') {
                    return ('ExD',2,1);
                  } elsif ($h->{g_position} eq 'right') {
                    return ('AuxM',2,1);
                  }
              } elsif ($h->{g_pos} eq 'V') {
                  if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                    return ('AuxP',0,);
                  } elsif ($h->{g_subpos} eq 'P') {
                    return ('AuxP',3,1);
                  } elsif ($h->{g_subpos} eq 'I') {
                    return ('AuxE',4,2);
                  }
              }
          } elsif ($h->{d_children} eq 'more') {
              if ($h->{d_case} =~ /^(?:1|3|empty|2)$/) {
                return ('AuxP',0,);
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{g_pos} =~ /^(?:S|T|undef|Y|Z|Q|D|I|G|empty|root)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_pos} eq 'A') {
                    return ('Atr',1,);
                  } elsif ($h->{g_pos} eq 'F') {
                    return ('Obj',1,);
                  } elsif ($h->{g_pos} eq 'N') {
                    return ('Pred',3,1);
                  } elsif ($h->{g_pos} eq 'X') {
                    return ('Atr',3,);
                  } elsif ($h->{g_pos} eq 'V') {
                    return ('Obj',1,);
                  } elsif ($h->{g_pos} eq 'P') {
                    return evalSubTree1_S1($h); # [S1]
                  }
              } elsif ($h->{d_case} eq 'undef') {
                return evalSubTree1_S2($h); # [S2]
              }
          }
      } elsif ($h->{d_pos} eq 'Y') {
          if ($h->{g_subpos} =~ /^(?:N|C|D|R|root|empty)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_subpos} eq 'P') {
            return ('Coord',4,1);
          } elsif ($h->{g_subpos} eq 'I') {
            return ('AuxP',3,1);
          } elsif ($h->{g_subpos} eq 'undef') {
              if ($h->{d_children} eq '1') {
                return ('Atr',7,2);
              } elsif ($h->{d_children} eq 'more') {
                  if ($h->{g_children} eq '1') {
                    return ('Coord',10,3);
                  } elsif ($h->{g_children} eq 'more') {
                    return ('Atr',9,3);
                  }
              } elsif ($h->{d_children} eq '0') {
                  if ($h->{g_pos} =~ /^(?:A|S|F|T|P|V|Z|Q|D|I|G|empty|root)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_pos} eq 'undef') {
                    return ('spec_qmarkspec_qmarkspec_qmark',1,);
                  } elsif ($h->{g_pos} eq 'N') {
                    return ('Atr',4,1);
                  } elsif ($h->{g_pos} eq 'X') {
                      if ($h->{g_position} eq 'left') {
                        return ('Atr',20,5);
                      } elsif ($h->{g_position} eq 'right') {
                        return ('spec_qmarkspec_qmarkspec_qmark',3,);
                      }
                  } elsif ($h->{g_pos} eq 'Y') {
                      if ($h->{g_position} eq 'right') {
                        return ('Atr',13,);
                      } elsif ($h->{g_position} eq 'left') {
                          if ($h->{g_children} eq '1') {
                            return ('Atr',2,);
                          } elsif ($h->{g_children} eq 'more') {
                            return ('AuxY',7,);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'D') {
          if ($h->{d_children} eq 'more') {
              if ($h->{g_pos} =~ /^(?:A|T|undef|P|Y|Z|Q|D|I|G|empty|root)$/) {
                return ('Adv',0,);
              } elsif ($h->{g_pos} eq 'S') {
                return ('AuxP',1,);
              } elsif ($h->{g_pos} eq 'F') {
                return ('Obj',7,3);
              } elsif ($h->{g_pos} eq 'N') {
                return ('Apos',6,3);
              } elsif ($h->{g_pos} eq 'X') {
                return ('Coord',1,);
              } elsif ($h->{g_pos} eq 'V') {
                  if ($h->{d_case} =~ /^(?:1|3|empty|2)$/) {
                    return ('Adv',0,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('Adv',6,3);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                        return ('Atv',0,);
                      } elsif ($h->{g_subpos} eq 'P') {
                        return ('Atv',10,5);
                      } elsif ($h->{g_subpos} eq 'I') {
                        return ('Coord',2,1);
                      }
                  }
              }
          } elsif ($h->{d_children} eq '1') {
              if ($h->{d_case} =~ /^(?:1|3|empty|2)$/) {
                return ('Adv',0,);
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{g_subpos} =~ /^(?:N|C|D|R|root|empty)$/) {
                    return ('Adv',0,);
                  } elsif ($h->{g_subpos} eq 'undef') {
                    return ('Adv',8,3);
                  } elsif ($h->{g_subpos} eq 'I') {
                    return ('Adv',10,);
                  } elsif ($h->{g_subpos} eq 'P') {
                      if ($h->{g_position} eq 'left') {
                        return ('Atv',24,7);
                      } elsif ($h->{g_position} eq 'right') {
                        return ('Adv',5,2);
                      }
                  }
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{g_pos} =~ /^(?:S|T|undef|P|Y|Q|D|I|G|empty|root)$/) {
                    return ('AuxP',0,);
                  } elsif ($h->{g_pos} eq 'A') {
                    return ('Adv',2,);
                  } elsif ($h->{g_pos} eq 'F') {
                    return ('Obj',10,3);
                  } elsif ($h->{g_pos} eq 'X') {
                    return ('AuxP',4,2);
                  } elsif ($h->{g_pos} eq 'Z') {
                    return ('AuxC',2,1);
                  } elsif ($h->{g_pos} eq 'N') {
                      if ($h->{g_children} eq '1') {
                        return ('Atr',2,1);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('AuxC',7,4);
                      }
                  } elsif ($h->{g_pos} eq 'V') {
                      if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                        return ('AuxP',0,);
                      } elsif ($h->{g_subpos} eq 'I') {
                        return ('AuxP',20,10);
                      } elsif ($h->{g_subpos} eq 'P') {
                          if ($h->{g_children} eq '1') {
                            return ('Obj',2,1);
                          } elsif ($h->{g_children} eq 'more') {
                            return ('Adv',27,18);
                          }
                      }
                  }
              }
          } elsif ($h->{d_children} eq '0') {
              if ($h->{g_pos} =~ /^(?:P|Y|Q|D|I|G|empty|root)$/) {
                return ('Adv',0,);
              } elsif ($h->{g_pos} eq 'A') {
                return ('Adv',14,7);
              } elsif ($h->{g_pos} eq 'S') {
                return ('Adv',2,1);
              } elsif ($h->{g_pos} eq 'T') {
                return ('Adv',1,);
              } elsif ($h->{g_pos} eq 'undef') {
                return ('AuxE',1,);
              } elsif ($h->{g_pos} eq 'V') {
                return ('Adv',176,23);
              } elsif ($h->{g_pos} eq 'Z') {
                return ('Atr',1,);
              } elsif ($h->{g_pos} eq 'F') {
                  if ($h->{d_case} =~ /^(?:1|3|empty|2)$/) {
                    return ('AuxE',0,);
                  } elsif ($h->{d_case} eq 'undef') {
                    return ('AuxY',4,1);
                  } elsif ($h->{d_case} eq '4') {
                      if ($h->{g_position} eq 'left') {
                        return ('Adv',2,);
                      } elsif ($h->{g_position} eq 'right') {
                        return ('AuxE',5,);
                      }
                  }
              } elsif ($h->{g_pos} eq 'X') {
                  if ($h->{g_position} eq 'left') {
                    return ('Adv',15,5);
                  } elsif ($h->{g_position} eq 'right') {
                      if ($h->{d_case} =~ /^(?:1|3|empty|2)$/) {
                        return ('AuxM',0,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Adv',2,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('AuxM',12,8);
                      }
                  }
              } elsif ($h->{g_pos} eq 'N') {
                  if ($h->{g_position} eq 'right') {
                      if ($h->{d_case} =~ /^(?:1|3|empty|2)$/) {
                        return ('Adv',0,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Adv',2,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('AuxE',6,3);
                      }
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{d_defin} =~ /^(?:D|X|empty)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{d_defin} eq 'undef') {
                        return ('Atr',32,14);
                      } elsif ($h->{d_defin} eq 'R') {
                        return ('Adv',1,);
                      } elsif ($h->{d_defin} eq 'I') {
                          if ($h->{g_children} eq '1') {
                            return ('Atr',11,7);
                          } elsif ($h->{g_children} eq 'more') {
                            return ('Adv',21,7);
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'S') {
          if ($h->{d_case} =~ /^(?:3|empty)$/) {
            return ('Atr',0,);
          } elsif ($h->{d_case} eq '1') {
            return ('Sb',1,);
          } elsif ($h->{d_case} eq '2') {
            return ('Atr',1015,65);
          } elsif ($h->{d_case} eq '4') {
              if ($h->{g_pos} =~ /^(?:A|S|F|T|undef|X|P|Y|Z|Q|D|I|G|empty|root)$/) {
                return ('Obj',0,);
              } elsif ($h->{g_pos} eq 'N') {
                return ('Atr',2,1);
              } elsif ($h->{g_pos} eq 'V') {
                  if ($h->{g_children} eq 'more') {
                    return ('Obj',309,21);
                  } elsif ($h->{g_children} eq '1') {
                      if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                        return ('Obj',0,);
                      } elsif ($h->{g_subpos} eq 'P') {
                        return ('Atr',28,16);
                      } elsif ($h->{g_subpos} eq 'I') {
                        return ('Obj',13,);
                      }
                  }
              }
          } elsif ($h->{d_case} eq 'undef') {
              if ($h->{d_subpos} =~ /^(?:N|P|C|I|empty)$/) {
                return ('AuxY',0,);
              } elsif ($h->{d_subpos} eq 'D') {
                  if ($h->{g_subpos} =~ /^(?:C|D|root|empty)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_subpos} eq 'N') {
                    return ('Atr',1,);
                  } elsif ($h->{g_subpos} eq 'P') {
                    return ('Sb',10,2);
                  } elsif ($h->{g_subpos} eq 'R') {
                    return ('Sb',2,);
                  } elsif ($h->{g_subpos} eq 'undef') {
                      if ($h->{g_pos} =~ /^(?:S|T|P|Y|V|Z|Q|I|G|empty|root)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{g_pos} eq 'A') {
                        return ('Atr',4,);
                      } elsif ($h->{g_pos} eq 'F') {
                        return ('AuxE',2,1);
                      } elsif ($h->{g_pos} eq 'undef') {
                        return ('Atr',1,);
                      } elsif ($h->{g_pos} eq 'N') {
                        return ('Atr',283,7);
                      } elsif ($h->{g_pos} eq 'X') {
                        return ('Atr',6,1);
                      } elsif ($h->{g_pos} eq 'D') {
                        return ('Obj',2,);
                      }
                  } elsif ($h->{g_subpos} eq 'I') {
                      if ($h->{g_position} eq 'right') {
                        return ('Sb',10,1);
                      } elsif ($h->{g_position} eq 'left') {
                          if ($h->{d_children} eq 'more') {
                            return ('Obj',0,);
                          } elsif ($h->{d_children} eq '1') {
                            return ('Sb',2,);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Obj',4,1);
                          }
                      }
                  }
              } elsif ($h->{d_subpos} eq 'undef') {
                  if ($h->{g_children} eq '1') {
                      if ($h->{g_pos} =~ /^(?:S|T|undef|P|Y|Z|Q|I|G|empty|root)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{g_pos} eq 'A') {
                        return ('AuxY',3,);
                      } elsif ($h->{g_pos} eq 'X') {
                        return ('AuxY',1,);
                      } elsif ($h->{g_pos} eq 'V') {
                        return ('Sb',3,1);
                      } elsif ($h->{g_pos} eq 'D') {
                        return ('AuxY',2,);
                      } elsif ($h->{g_pos} eq 'F') {
                          if ($h->{d_children} eq '1') {
                            return ('Sb',0,);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Sb',23,8);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',2,1);
                          }
                      } elsif ($h->{g_pos} eq 'N') {
                          if ($h->{g_position} eq 'left') {
                            return ('Atr',21,);
                          } elsif ($h->{g_position} eq 'right') {
                            return ('AuxY',3,1);
                          }
                      }
                  } elsif ($h->{g_children} eq 'more') {
                      if ($h->{g_position} eq 'right') {
                        return ('Sb',279,59);
                      } elsif ($h->{g_position} eq 'left') {
                          if ($h->{d_children} eq '1') {
                            return ('Sb',3,1);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',1,);
                          } elsif ($h->{d_children} eq '0') {
                              if ($h->{g_subpos} =~ /^(?:N|C|D|R|root|empty)$/) {
                                return ('AuxY',0,);
                              } elsif ($h->{g_subpos} eq 'undef') {
                                return ('AuxY',33,4);
                              } elsif ($h->{g_subpos} eq 'P') {
                                return ('AuxY',11,3);
                              } elsif ($h->{g_subpos} eq 'I') {
                                return ('Sb',4,1);
                              }
                          }
                      }
                  }
              } elsif ($h->{d_subpos} eq 'R') {
                  if ($h->{g_position} eq 'right') {
                      if ($h->{d_children} eq '1') {
                        return ('Sb',28,1);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Adv',2,1);
                      } elsif ($h->{d_children} eq '0') {
                          if ($h->{g_subpos} =~ /^(?:N|C|D|R|root|empty)$/) {
                            return ('Sb',0,);
                          } elsif ($h->{g_subpos} eq 'undef') {
                            return ('Sb',2,);
                          } elsif ($h->{g_subpos} eq 'P') {
                            return ('AuxM',4,1);
                          } elsif ($h->{g_subpos} eq 'I') {
                            return ('Adv',6,3);
                          }
                      }
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{d_children} eq '0') {
                        return ('AuxY',508,9);
                      } elsif ($h->{d_children} eq 'more') {
                          if ($h->{g_pos} =~ /^(?:A|S|T|undef|X|P|Y|Z|Q|D|I|G|empty|root)$/) {
                            return ('Obj',0,);
                          } elsif ($h->{g_pos} eq 'F') {
                            return ('Apos',5,2);
                          } elsif ($h->{g_pos} eq 'N') {
                            return ('Atr',4,);
                          } elsif ($h->{g_pos} eq 'V') {
                            return ('Obj',13,7);
                          }
                      } elsif ($h->{d_children} eq '1') {
                          if ($h->{g_pos} =~ /^(?:A|T|undef|P|Y|Q|I|G|empty|root)$/) {
                            return ('Atr',0,);
                          } elsif ($h->{g_pos} eq 'S') {
                            return ('Atr',1,);
                          } elsif ($h->{g_pos} eq 'F') {
                            return ('Sb',2,);
                          } elsif ($h->{g_pos} eq 'V') {
                            return ('Obj',44,17);
                          } elsif ($h->{g_pos} eq 'Z') {
                            return ('Atr',3,1);
                          } elsif ($h->{g_pos} eq 'D') {
                            return ('Obj',2,1);
                          } elsif ($h->{g_pos} eq 'N') {
                              if ($h->{g_children} eq '1') {
                                return ('Atr',49,15);
                              } elsif ($h->{g_children} eq 'more') {
                                return ('AuxY',25,14);
                              }
                          } elsif ($h->{g_pos} eq 'X') {
                              if ($h->{g_children} eq '1') {
                                return ('Obj',2,);
                              } elsif ($h->{g_children} eq 'more') {
                                return ('Atr',4,2);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'A') {
          if ($h->{g_subpos} =~ /^(?:C|D|root|empty)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_subpos} eq 'R') {
            return ('Atr',5,);
          } elsif ($h->{g_subpos} eq 'N') {
              if ($h->{d_defin} =~ /^(?:D|R|empty)$/) {
                return ('Atr',0,);
              } elsif ($h->{d_defin} eq 'X') {
                return ('Atr',13,);
              } elsif ($h->{d_defin} eq 'undef') {
                return ('Atr',11,);
              } elsif ($h->{d_defin} eq 'I') {
                return ('Adv',1,);
              }
          } elsif ($h->{g_subpos} eq 'I') {
              if ($h->{d_case} =~ /^(?:empty|2)$/) {
                return ('Sb',0,);
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{d_defin} =~ /^(?:undef|I|empty)$/) {
                    return ('Sb',0,);
                  } elsif ($h->{d_defin} eq 'D') {
                    return ('Sb',4,);
                  } elsif ($h->{d_defin} eq 'X') {
                    return ('Sb',1,);
                  } elsif ($h->{d_defin} eq 'R') {
                    return ('Atv',3,1);
                  }
              } elsif ($h->{d_case} eq '3') {
                  if ($h->{g_position} eq 'left') {
                    return ('Obj',4,);
                  } elsif ($h->{g_position} eq 'right') {
                    return ('Ante',2,1);
                  }
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{g_verbmod} =~ /^(?:S|D|empty|root)$/) {
                    return ('Sb',0,);
                  } elsif ($h->{g_verbmod} eq 'undef') {
                    return ('Sb',54,24);
                  } elsif ($h->{g_verbmod} eq 'I') {
                    return ('Pnom',2,1);
                  }
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{d_children} eq 'more') {
                    return ('Adv',0,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('Atv',5,1);
                  } elsif ($h->{d_children} eq '0') {
                      if ($h->{g_verbmod} =~ /^(?:D|empty|root)$/) {
                        return ('Adv',0,);
                      } elsif ($h->{g_verbmod} eq 'S') {
                        return ('Obj',1,);
                      } elsif ($h->{g_verbmod} eq 'undef') {
                        return ('Adv',13,1);
                      } elsif ($h->{g_verbmod} eq 'I') {
                        return ('Adv',4,);
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'P') {
              if ($h->{d_case} =~ /^(?:empty|2)$/) {
                return ('Sb',0,);
              } elsif ($h->{d_case} eq '1') {
                  if ($h->{d_children} eq '1') {
                    return ('Sb',11,4);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',8,2);
                  } elsif ($h->{d_children} eq '0') {
                      if ($h->{d_defin} =~ /^(?:undef|I|empty)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{d_defin} eq 'D') {
                        return ('Sb',2,);
                      } elsif ($h->{d_defin} eq 'X') {
                        return ('Atr',3,);
                      } elsif ($h->{d_defin} eq 'R') {
                        return ('Pnom',3,2);
                      }
                  }
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{d_children} eq '1') {
                    return ('Atv',17,3);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Atv',1,);
                  } elsif ($h->{d_children} eq '0') {
                      if ($h->{g_children} eq '1') {
                        return ('Pnom',5,2);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('Adv',15,5);
                      }
                  }
              } elsif ($h->{d_case} eq '3') {
                  if ($h->{g_position} eq 'right') {
                    return ('Sb',4,);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{d_children} eq 'more') {
                        return ('Obj',0,);
                      } elsif ($h->{d_children} eq '1') {
                        return ('Atr',2,1);
                      } elsif ($h->{d_children} eq '0') {
                        return ('Obj',3,1);
                      }
                  }
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                    return ('Sb',0,);
                  } elsif ($h->{d_defin} eq 'X') {
                    return ('Sb',22,10);
                  } elsif ($h->{d_defin} eq 'undef') {
                      if ($h->{g_children} eq '1') {
                        return ('Obj',12,5);
                      } elsif ($h->{g_children} eq 'more') {
                          if ($h->{d_children} eq '1') {
                            return ('Sb',30,17);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Obj',6,4);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Atv',11,6);
                          }
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'undef') {
              if ($h->{g_position} eq 'right') {
                  if ($h->{d_defin} =~ /^(?:D|R|empty)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{d_defin} eq 'X') {
                    return ('Atr',14,2);
                  } elsif ($h->{d_defin} eq 'I') {
                    return ('AuxY',1,);
                  } elsif ($h->{d_defin} eq 'undef') {
                      if ($h->{g_pos} =~ /^(?:A|S|F|T|undef|P|Y|V|Q|D|I|G|empty|root)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{g_pos} eq 'X') {
                        return ('Obj',3,1);
                      } elsif ($h->{g_pos} eq 'Z') {
                        return ('Atr',1,);
                      } elsif ($h->{g_pos} eq 'N') {
                          if ($h->{d_children} eq 'more') {
                            return ('Sb',0,);
                          } elsif ($h->{d_children} eq '1') {
                            return ('Sb',3,);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Atr',2,1);
                          }
                      }
                  }
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{g_pos} =~ /^(?:T|P|V|I|empty|root)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_pos} eq 'A') {
                    return ('Atr',67,9);
                  } elsif ($h->{g_pos} eq 'S') {
                    return ('Adv',1,);
                  } elsif ($h->{g_pos} eq 'N') {
                    return ('Atr',3509,51);
                  } elsif ($h->{g_pos} eq 'Y') {
                    return ('Atr',1,);
                  } elsif ($h->{g_pos} eq 'Z') {
                    return ('Atr',167,);
                  } elsif ($h->{g_pos} eq 'Q') {
                    return ('Atr',3,1);
                  } elsif ($h->{g_pos} eq 'D') {
                    return ('Sb',6,3);
                  } elsif ($h->{g_pos} eq 'G') {
                    return ('Obj',2,1);
                  } elsif ($h->{g_pos} eq 'undef') {
                      if ($h->{d_children} eq '1') {
                        return ('Atr',2,1);
                      } elsif ($h->{d_children} eq '0') {
                        return ('Atr',8,);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Atv',1,);
                      }
                  } elsif ($h->{g_pos} eq 'F') {
                      if ($h->{d_case} =~ /^(?:3|empty|2)$/) {
                        return ('Obj',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Atr',2,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Obj',1,);
                      } elsif ($h->{d_case} eq 'undef') {
                          if ($h->{d_children} eq '0') {
                            return ('Obj',0,);
                          } elsif ($h->{d_children} eq '1') {
                            return ('ExD',4,2);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',18,5);
                          }
                      }
                  } elsif ($h->{g_pos} eq 'X') {
                      if ($h->{d_children} eq '0') {
                        return ('Atr',102,4);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Atr',6,3);
                      } elsif ($h->{d_children} eq '1') {
                          if ($h->{d_defin} =~ /^(?:D|R|empty)$/) {
                            return ('Atr',0,);
                          } elsif ($h->{d_defin} eq 'X') {
                            return ('Atr',13,);
                          } elsif ($h->{d_defin} eq 'I') {
                            return ('Sb',1,);
                          } elsif ($h->{d_defin} eq 'undef') {
                              if ($h->{g_children} eq '1') {
                                return ('Adv',6,3);
                              } elsif ($h->{g_children} eq 'more') {
                                return ('Obj',6,4);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'Z') {
          if ($h->{g_subpos} =~ /^(?:C|D|root|empty)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_subpos} eq 'N') {
            return ('Atr',1,);
          } elsif ($h->{g_subpos} eq 'R') {
            return ('ExD',3,2);
          } elsif ($h->{g_subpos} eq 'I') {
              if ($h->{g_children} eq '1') {
                return ('Obj',15,1);
              } elsif ($h->{g_children} eq 'more') {
                  if ($h->{g_position} eq 'right') {
                    return ('Sb',44,1);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{d_case} =~ /^(?:3|empty|2)$/) {
                        return ('Sb',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Sb',8,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Obj',3,);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('Sb',75,28);
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'undef') {
              if ($h->{g_pos} =~ /^(?:T|P|Y|V|I|empty|root)$/) {
                return ('Atr',0,);
              } elsif ($h->{g_pos} eq 'A') {
                return ('Atr',26,5);
              } elsif ($h->{g_pos} eq 'S') {
                return ('Atr',1,);
              } elsif ($h->{g_pos} eq 'undef') {
                return ('Atr',16,1);
              } elsif ($h->{g_pos} eq 'Z') {
                return ('Atr',533,10);
              } elsif ($h->{g_pos} eq 'Q') {
                return ('Atr',4,);
              } elsif ($h->{g_pos} eq 'D') {
                return ('ExD',2,1);
              } elsif ($h->{g_pos} eq 'G') {
                return ('Obj',3,2);
              } elsif ($h->{g_pos} eq 'F') {
                  if ($h->{g_children} eq '1') {
                    return ('Sb',11,4);
                  } elsif ($h->{g_children} eq 'more') {
                    return ('Ante',3,1);
                  }
              } elsif ($h->{g_pos} eq 'N') {
                  if ($h->{g_position} eq 'left') {
                    return ('Atr',895,31);
                  } elsif ($h->{g_position} eq 'right') {
                      if ($h->{g_children} eq '1') {
                        return ('Atr',2,);
                      } elsif ($h->{g_children} eq 'more') {
                          if ($h->{d_defin} =~ /^(?:D|I|empty)$/) {
                            return ('Sb',0,);
                          } elsif ($h->{d_defin} eq 'X') {
                            return ('Sb',4,);
                          } elsif ($h->{d_defin} eq 'undef') {
                            return ('Sb',10,2);
                          } elsif ($h->{d_defin} eq 'R') {
                            return ('Atr',1,);
                          }
                      }
                  }
              } elsif ($h->{g_pos} eq 'X') {
                  if ($h->{d_defin} =~ /^(?:D|R|empty)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{d_defin} eq 'undef') {
                    return ('Atr',283,59);
                  } elsif ($h->{d_defin} eq 'I') {
                    return ('Atr',1,);
                  } elsif ($h->{d_defin} eq 'X') {
                      if ($h->{d_children} eq 'more') {
                        return ('Obj',2,1);
                      } elsif ($h->{d_children} eq '1') {
                          if ($h->{g_children} eq '1') {
                            return ('Obj',2,);
                          } elsif ($h->{g_children} eq 'more') {
                            return ('ExD',2,1);
                          }
                      } elsif ($h->{d_children} eq '0') {
                          if ($h->{g_position} eq 'left') {
                            return ('Adv',7,3);
                          } elsif ($h->{g_position} eq 'right') {
                            return ('Atr',3,1);
                          }
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'P') {
              if ($h->{g_children} eq '1') {
                  if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{d_defin} eq 'X') {
                    return ('Atr',14,7);
                  } elsif ($h->{d_defin} eq 'undef') {
                    return ('Sb',6,3);
                  }
              } elsif ($h->{g_children} eq 'more') {
                  if ($h->{d_defin} eq 'empty') {
                    return ('Sb',0,);
                  } elsif ($h->{d_defin} eq 'D') {
                    return ('Sb',2,);
                  } elsif ($h->{d_defin} eq 'undef') {
                    return ('Sb',163,23);
                  } elsif ($h->{d_defin} eq 'R') {
                    return ('Obj',3,2);
                  } elsif ($h->{d_defin} eq 'I') {
                    return ('Adv',1,);
                  } elsif ($h->{d_defin} eq 'X') {
                      if ($h->{d_case} =~ /^(?:3|empty|2)$/) {
                        return ('Sb',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Sb',3,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Adv',2,);
                      } elsif ($h->{d_case} eq 'undef') {
                          if ($h->{d_children} eq '1') {
                            return ('Sb',19,3);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Sb',8,2);
                          } elsif ($h->{d_children} eq '0') {
                              if ($h->{g_position} eq 'left') {
                                return ('Adv',58,24);
                              } elsif ($h->{g_position} eq 'right') {
                                return ('Sb',6,);
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'N') {
          if ($h->{g_subpos} =~ /^(?:root|empty)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_subpos} eq 'C') {
            return ('Atv',1,);
          } elsif ($h->{g_subpos} eq 'D') {
              if ($h->{g_children} eq '1') {
                return ('Atr',5,);
              } elsif ($h->{g_children} eq 'more') {
                return ('AuxP',2,1);
              }
          } elsif ($h->{g_subpos} eq 'R') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',96,9);
              } elsif ($h->{g_position} eq 'right') {
                  if ($h->{d_children} eq '0') {
                    return ('Sb',0,);
                  } elsif ($h->{d_children} eq '1') {
                    return ('ExD',3,2);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Sb',3,1);
                  }
              }
          } elsif ($h->{g_subpos} eq 'N') {
              if ($h->{g_position} eq 'right') {
                return ('Sb',7,1);
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{d_children} eq '0') {
                    return ('Atr',23,2);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Sb',6,2);
                  } elsif ($h->{d_children} eq '1') {
                      if ($h->{d_defin} =~ /^(?:D|I|empty)$/) {
                        return ('Sb',0,);
                      } elsif ($h->{d_defin} eq 'X') {
                        return ('Atr',3,);
                      } elsif ($h->{d_defin} eq 'undef') {
                        return ('Sb',10,3);
                      } elsif ($h->{d_defin} eq 'R') {
                        return ('Sb',1,);
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'P') {
              if ($h->{d_case} eq 'empty') {
                return ('Sb',0,);
              } elsif ($h->{d_case} eq '1') {
                return ('Sb',243,34);
              } elsif ($h->{d_case} eq '3') {
                  if ($h->{g_position} eq 'left') {
                    return ('Obj',25,5);
                  } elsif ($h->{g_position} eq 'right') {
                    return ('Sb',11,1);
                  }
              } elsif ($h->{d_case} eq '2') {
                  if ($h->{d_defin} =~ /^(?:D|undef|empty)$/) {
                    return ('Adv',0,);
                  } elsif ($h->{d_defin} eq 'X') {
                    return ('Adv',4,2);
                  } elsif ($h->{d_defin} eq 'R') {
                    return ('spec_qmarkspec_qmarkspec_qmark',2,1);
                  } elsif ($h->{d_defin} eq 'I') {
                    return ('Obj',2,1);
                  }
              } elsif ($h->{d_case} eq 'undef') {
                  if ($h->{g_children} eq 'more') {
                    return ('Sb',1430,557);
                  } elsif ($h->{g_children} eq '1') {
                      if ($h->{g_position} eq 'right') {
                        return ('Sb',2,);
                      } elsif ($h->{g_position} eq 'left') {
                          if ($h->{d_children} eq '1') {
                            return ('Obj',94,54);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Atr',23,13);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',63,34);
                          }
                      }
                  }
              } elsif ($h->{d_case} eq '4') {
                  if ($h->{g_position} eq 'right') {
                    return ('Sb',35,2);
                  } elsif ($h->{g_position} eq 'left') {
                      if ($h->{d_defin} =~ /^(?:undef|empty)$/) {
                        return ('Obj',0,);
                      } elsif ($h->{d_defin} eq 'D') {
                        return ('Adv',8,);
                      } elsif ($h->{d_defin} eq 'X') {
                        return ('Obj',22,7);
                      } elsif ($h->{d_defin} eq 'R') {
                          if ($h->{g_children} eq '1') {
                            return ('Obj',5,1);
                          } elsif ($h->{g_children} eq 'more') {
                              if ($h->{d_children} eq '0') {
                                return ('Obj',0,);
                              } elsif ($h->{d_children} eq '1') {
                                return ('Adv',27,9);
                              } elsif ($h->{d_children} eq 'more') {
                                return ('Obj',14,2);
                              }
                          }
                      } elsif ($h->{d_defin} eq 'I') {
                          if ($h->{d_children} eq '0') {
                            return ('Pnom',26,18);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',53,21);
                          } elsif ($h->{d_children} eq '1') {
                              if ($h->{g_children} eq '1') {
                                return ('Obj',12,5);
                              } elsif ($h->{g_children} eq 'more') {
                                return ('Atv',92,43);
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'undef') {
              if ($h->{g_position} eq 'right') {
                  if ($h->{g_pos} =~ /^(?:T|P|V|empty|root)$/) {
                    return ('Sb',0,);
                  } elsif ($h->{g_pos} eq 'A') {
                    return ('Sb',23,1);
                  } elsif ($h->{g_pos} eq 'S') {
                    return ('Sb',2,);
                  } elsif ($h->{g_pos} eq 'Y') {
                    return ('Atr',3,2);
                  } elsif ($h->{g_pos} eq 'Q') {
                    return ('Sb',8,);
                  } elsif ($h->{g_pos} eq 'D') {
                    return ('Obj',16,9);
                  } elsif ($h->{g_pos} eq 'I') {
                    return ('Atr',1,);
                  } elsif ($h->{g_pos} eq 'F') {
                      if ($h->{d_children} eq 'more') {
                        return ('AuxP',0,);
                      } elsif ($h->{d_children} eq '1') {
                        return ('AuxP',4,2);
                      } elsif ($h->{d_children} eq '0') {
                        return ('Sb',2,);
                      }
                  } elsif ($h->{g_pos} eq 'undef') {
                      if ($h->{g_children} eq '1') {
                        return ('Atr',2,);
                      } elsif ($h->{g_children} eq 'more') {
                        return ('Sb',4,2);
                      }
                  } elsif ($h->{g_pos} eq 'Z') {
                      if ($h->{d_children} eq 'more') {
                        return ('Atr',0,);
                      } elsif ($h->{d_children} eq '1') {
                        return ('Sb',3,1);
                      } elsif ($h->{d_children} eq '0') {
                        return ('Atr',10,);
                      }
                  } elsif ($h->{g_pos} eq 'N') {
                      if ($h->{g_children} eq 'more') {
                        return ('Sb',77,13);
                      } elsif ($h->{g_children} eq '1') {
                          if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                            return ('Sb',0,);
                          } elsif ($h->{d_defin} eq 'X') {
                            return ('Sb',4,);
                          } elsif ($h->{d_defin} eq 'undef') {
                            return ('Atr',3,1);
                          }
                      }
                  } elsif ($h->{g_pos} eq 'G') {
                      if ($h->{d_children} eq '0') {
                        return ('Obj',0,);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Sb',3,1);
                      } elsif ($h->{d_children} eq '1') {
                          if ($h->{d_case} =~ /^(?:1|3|undef|empty)$/) {
                            return ('Obj',0,);
                          } elsif ($h->{d_case} eq '4') {
                            return ('Obj',3,1);
                          } elsif ($h->{d_case} eq '2') {
                            return ('Atr',4,2);
                          }
                      }
                  } elsif ($h->{g_pos} eq 'X') {
                      if ($h->{d_case} =~ /^(?:empty|2)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Sb',1,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Sb',2,1);
                      } elsif ($h->{d_case} eq '3') {
                        return ('Obj',2,);
                      } elsif ($h->{d_case} eq 'undef') {
                          if ($h->{d_children} eq '1') {
                            return ('Sb',48,25);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Atr',35,16);
                          } elsif ($h->{d_children} eq 'more') {
                              if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                                return ('Sb',0,);
                              } elsif ($h->{d_defin} eq 'X') {
                                return ('Atr',5,1);
                              } elsif ($h->{d_defin} eq 'undef') {
                                return ('Sb',9,2);
                              }
                          }
                      }
                  }
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{g_pos} =~ /^(?:P|V|empty|root)$/) {
                    return ('Atr',0,);
                  } elsif ($h->{g_pos} eq 'T') {
                    return ('Atr',2,1);
                  } elsif ($h->{g_pos} eq 'N') {
                    return ('Atr',6655,514);
                  } elsif ($h->{g_pos} eq 'Z') {
                    return ('Atr',92,9);
                  } elsif ($h->{g_pos} eq 'Q') {
                    return ('Atr',92,);
                  } elsif ($h->{g_pos} eq 'I') {
                    return ('Atr',1,);
                  } elsif ($h->{g_pos} eq 'G') {
                    return ('Atr',4,1);
                  } elsif ($h->{g_pos} eq 'S') {
                      if ($h->{g_children} eq 'more') {
                        return ('ExD',2,1);
                      } elsif ($h->{g_children} eq '1') {
                          if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                            return ('Atr',0,);
                          } elsif ($h->{d_defin} eq 'X') {
                            return ('Obj',2,1);
                          } elsif ($h->{d_defin} eq 'undef') {
                            return ('Atr',2,);
                          }
                      }
                  } elsif ($h->{g_pos} eq 'undef') {
                      if ($h->{d_case} eq 'empty') {
                        return ('Atr',0,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Obj',4,2);
                      } elsif ($h->{d_case} eq '3') {
                        return ('Atr',2,1);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('Atr',18,3);
                      } elsif ($h->{d_case} eq '2') {
                        return ('Atr',9,4);
                      } elsif ($h->{d_case} eq '1') {
                          if ($h->{d_children} eq '1') {
                            return ('Sb',2,);
                          } elsif ($h->{d_children} eq '0') {
                            return ('Atr',1,);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Atr',2,1);
                          }
                      }
                  } elsif ($h->{g_pos} eq 'Y') {
                      if ($h->{g_children} eq '1') {
                        return ('Obj',4,1);
                      } elsif ($h->{g_children} eq 'more') {
                          if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                            return ('Atr',0,);
                          } elsif ($h->{d_defin} eq 'X') {
                            return ('Atr',2,);
                          } elsif ($h->{d_defin} eq 'undef') {
                            return ('AtrAdv',4,2);
                          }
                      }
                  } elsif ($h->{g_pos} eq 'A') {
                      if ($h->{d_case} eq 'empty') {
                        return ('Atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Atr',19,4);
                      } elsif ($h->{d_case} eq '3') {
                        return ('Atr',13,1);
                      } elsif ($h->{d_case} eq 'undef') {
                        return ('Atr',208,16);
                      } elsif ($h->{d_case} eq '2') {
                        return ('Atr',20,);
                      } elsif ($h->{d_case} eq '4') {
                          if ($h->{d_defin} =~ /^(?:undef|empty)$/) {
                            return ('Adv',0,);
                          } elsif ($h->{d_defin} eq 'D') {
                            return ('Adv',1,);
                          } elsif ($h->{d_defin} eq 'X') {
                            return ('Adv',1,);
                          } elsif ($h->{d_defin} eq 'R') {
                            return ('Adv',4,);
                          } elsif ($h->{d_defin} eq 'I') {
                              if ($h->{d_children} eq 'more') {
                                return ('Atv',0,);
                              } elsif ($h->{d_children} eq '1') {
                                return ('Atv',4,1);
                              } elsif ($h->{d_children} eq '0') {
                                return ('Atr',5,3);
                              }
                          }
                      }
                  } elsif ($h->{g_pos} eq 'F') {
                      if ($h->{d_defin} eq 'empty') {
                        return ('Obj',0,);
                      } elsif ($h->{d_defin} eq 'D') {
                        return ('Sb',5,);
                      } elsif ($h->{d_defin} eq 'X') {
                        return ('Sb',37,15);
                      } elsif ($h->{d_defin} eq 'R') {
                        return ('Obj',2,1);
                      } elsif ($h->{d_defin} eq 'I') {
                          if ($h->{d_case} =~ /^(?:undef|empty|2)$/) {
                            return ('Sb',0,);
                          } elsif ($h->{d_case} eq '1') {
                            return ('Obj',2,);
                          } elsif ($h->{d_case} eq '4') {
                            return ('Sb',2,);
                          } elsif ($h->{d_case} eq '3') {
                            return ('Sb',2,);
                          }
                      } elsif ($h->{d_defin} eq 'undef') {
                          if ($h->{d_children} eq '0') {
                            return ('Pnom',6,4);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',92,36);
                          } elsif ($h->{d_children} eq '1') {
                              if ($h->{g_children} eq '1') {
                                return ('Obj',25,13);
                              } elsif ($h->{g_children} eq 'more') {
                                return ('Sb',6,2);
                              }
                          }
                      }
                  } elsif ($h->{g_pos} eq 'X') {
                      if ($h->{d_case} =~ /^(?:empty|2)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Sb',10,3);
                      } elsif ($h->{d_case} eq '3') {
                        return ('Atr',7,2);
                      } elsif ($h->{d_case} eq '4') {
                          if ($h->{g_children} eq '1') {
                            return ('Atr',33,1);
                          } elsif ($h->{g_children} eq 'more') {
                              if ($h->{d_children} eq '1') {
                                return ('Adv',5,3);
                              } elsif ($h->{d_children} eq '0') {
                                return ('Atr',19,2);
                              } elsif ($h->{d_children} eq 'more') {
                                return ('Atv',1,);
                              }
                          }
                      } elsif ($h->{d_case} eq 'undef') {
                          if ($h->{g_children} eq '1') {
                              if ($h->{d_children} eq '1') {
                                return ('Atr',271,84);
                              } elsif ($h->{d_children} eq '0') {
                                return ('Atr',51,12);
                              } elsif ($h->{d_children} eq 'more') {
                                  if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                                    return ('Obj',0,);
                                  } elsif ($h->{d_defin} eq 'X') {
                                    return ('Atr',17,9);
                                  } elsif ($h->{d_defin} eq 'undef') {
                                    return ('Obj',49,28);
                                  }
                              }
                          } elsif ($h->{g_children} eq 'more') {
                              if ($h->{d_children} eq '0') {
                                return ('Atr',71,20);
                              } elsif ($h->{d_children} eq '1') {
                                  if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                                    return ('Atr',0,);
                                  } elsif ($h->{d_defin} eq 'X') {
                                    return ('Sb',19,11);
                                  } elsif ($h->{d_defin} eq 'undef') {
                                    return ('Atr',87,29);
                                  }
                              } elsif ($h->{d_children} eq 'more') {
                                  if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                                    return ('Atr',0,);
                                  } elsif ($h->{d_defin} eq 'X') {
                                    return ('Atr',12,5);
                                  } elsif ($h->{d_defin} eq 'undef') {
                                    return ('Sb',24,15);
                                  }
                              }
                          }
                      }
                  } elsif ($h->{g_pos} eq 'D') {
                      if ($h->{d_case} eq 'empty') {
                        return ('Atr',0,);
                      } elsif ($h->{d_case} eq '1') {
                        return ('Atr',1,);
                      } elsif ($h->{d_case} eq '4') {
                        return ('Sb',3,1);
                      } elsif ($h->{d_case} eq '3') {
                        return ('Atr',3,);
                      } elsif ($h->{d_case} eq '2') {
                        return ('Atr',7,);
                      } elsif ($h->{d_case} eq 'undef') {
                          if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                            return ('Atr',0,);
                          } elsif ($h->{d_defin} eq 'X') {
                              if ($h->{g_children} eq '1') {
                                return ('Adv',10,5);
                              } elsif ($h->{g_children} eq 'more') {
                                return ('Atr',12,5);
                              }
                          } elsif ($h->{d_defin} eq 'undef') {
                              if ($h->{d_children} eq '0') {
                                return ('Adv',2,1);
                              } elsif ($h->{d_children} eq 'more') {
                                return ('Sb',17,7);
                              } elsif ($h->{d_children} eq '1') {
                                  if ($h->{g_children} eq '1') {
                                    return ('Atr',12,6);
                                  } elsif ($h->{g_children} eq 'more') {
                                    return ('Sb',3,1);
                                  }
                              }
                          }
                      }
                  }
              }
          } elsif ($h->{g_subpos} eq 'I') {
              if ($h->{g_position} eq 'right') {
                return ('Sb',298,28);
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{d_case} eq 'empty') {
                    return ('Obj',0,);
                  } elsif ($h->{d_case} eq '1') {
                    return ('Sb',97,9);
                  } elsif ($h->{d_case} eq '4') {
                    return ('Obj',207,83);
                  } elsif ($h->{d_case} eq '3') {
                    return ('Obj',25,5);
                  } elsif ($h->{d_case} eq '2') {
                      if ($h->{g_verbmod} =~ /^(?:D|empty|root)$/) {
                        return ('Adv',0,);
                      } elsif ($h->{g_verbmod} eq 'S') {
                        return ('Pnom',1,);
                      } elsif ($h->{g_verbmod} eq 'undef') {
                        return ('Sb',3,);
                      } elsif ($h->{g_verbmod} eq 'I') {
                        return ('Adv',3,);
                      }
                  } elsif ($h->{d_case} eq 'undef') {
                      if ($h->{g_children} eq '1') {
                          if ($h->{g_verbmod} =~ /^(?:empty|root)$/) {
                            return ('Obj',0,);
                          } elsif ($h->{g_verbmod} eq 'S') {
                            return ('Sb',2,);
                          } elsif ($h->{g_verbmod} eq 'D') {
                            return ('Obj',2,);
                          } elsif ($h->{g_verbmod} eq 'undef') {
                            return ('Obj',154,45);
                          } elsif ($h->{g_verbmod} eq 'I') {
                            return ('Obj',16,2);
                          }
                      } elsif ($h->{g_children} eq 'more') {
                          if ($h->{g_verbmod} =~ /^(?:empty|root)$/) {
                            return ('Sb',0,);
                          } elsif ($h->{g_verbmod} eq 'S') {
                            return ('Sb',5,1);
                          } elsif ($h->{g_verbmod} eq 'D') {
                            return ('Obj',5,1);
                          } elsif ($h->{g_verbmod} eq 'I') {
                            return ('Obj',43,19);
                          } elsif ($h->{g_verbmod} eq 'undef') {
                              if ($h->{d_children} eq '1') {
                                return ('Sb',457,236);
                              } elsif ($h->{d_children} eq '0') {
                                  if ($h->{d_defin} =~ /^(?:R|I|empty)$/) {
                                    return ('Sb',0,);
                                  } elsif ($h->{d_defin} eq 'D') {
                                    return ('Sb',1,);
                                  } elsif ($h->{d_defin} eq 'X') {
                                    return ('Sb',108,33);
                                  } elsif ($h->{d_defin} eq 'undef') {
                                    return ('Obj',22,13);
                                  }
                              } elsif ($h->{d_children} eq 'more') {
                                  if ($h->{d_defin} =~ /^(?:D|R|I|empty)$/) {
                                    return ('Obj',0,);
                                  } elsif ($h->{d_defin} eq 'X') {
                                    return ('Sb',58,26);
                                  } elsif ($h->{d_defin} eq 'undef') {
                                    return ('Obj',140,65);
                                  }
                              }
                          }
                      }
                  }
              }
          }
      } elsif ($h->{d_pos} eq 'V') {
          if ($h->{g_pos} =~ /^(?:T|P|I|G|empty|root)$/) {
            return ('Atr',0,);
          } elsif ($h->{g_pos} eq 'undef') {
            return ('Atr',9,3);
          } elsif ($h->{g_pos} eq 'Y') {
            return ('Obj',1,);
          } elsif ($h->{g_pos} eq 'Z') {
            return ('Atr',41,2);
          } elsif ($h->{g_pos} eq 'Q') {
            return ('Atr',3,);
          } elsif ($h->{g_pos} eq 'A') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',37,15);
              } elsif ($h->{g_position} eq 'right') {
                  if ($h->{d_children} eq '1') {
                    return ('Sb',3,);
                  } elsif ($h->{d_children} eq '0') {
                    return ('Atr',2,1);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',1,);
                  }
              }
          } elsif ($h->{g_pos} eq 'F') {
              if ($h->{g_position} eq 'right') {
                return ('Pred',2,);
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{g_subpos} =~ /^(?:P|C|D|R|root|empty)$/) {
                    return ('Obj',0,);
                  } elsif ($h->{g_subpos} eq 'N') {
                    return ('Atr',2,1);
                  } elsif ($h->{g_subpos} eq 'undef') {
                    return ('Obj',827,224);
                  } elsif ($h->{g_subpos} eq 'I') {
                    return ('Atr',4,1);
                  }
              }
          } elsif ($h->{g_pos} eq 'D') {
              if ($h->{g_children} eq '1') {
                return ('Adv',23,12);
              } elsif ($h->{g_children} eq 'more') {
                  if ($h->{d_children} eq '1') {
                    return ('Adv',3,1);
                  } elsif ($h->{d_children} eq '0') {
                    return ('AuxM',1,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',7,3);
                  }
              }
          } elsif ($h->{g_pos} eq 'S') {
              if ($h->{g_children} eq '1') {
                return ('Atr',164,11);
              } elsif ($h->{g_children} eq 'more') {
                  if ($h->{d_subpos} =~ /^(?:N|undef|D|C|R|empty)$/) {
                    return ('Pred',0,);
                  } elsif ($h->{d_subpos} eq 'I') {
                    return ('Atr',34,20);
                  } elsif ($h->{d_subpos} eq 'P') {
                      if ($h->{g_position} eq 'left') {
                        return ('Atr',15,7);
                      } elsif ($h->{g_position} eq 'right') {
                        return ('Pred',11,3);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'X') {
              if ($h->{g_position} eq 'left') {
                return ('Atr',70,22);
              } elsif ($h->{g_position} eq 'right') {
                  if ($h->{d_children} eq '1') {
                    return ('Pred',3,1);
                  } elsif ($h->{d_children} eq '0') {
                    return ('Atr',1,);
                  } elsif ($h->{d_children} eq 'more') {
                      if ($h->{d_subpos} =~ /^(?:N|undef|D|C|R|empty)$/) {
                        return ('Pred',0,);
                      } elsif ($h->{d_subpos} eq 'P') {
                        return ('Pred',4,);
                      } elsif ($h->{d_subpos} eq 'I') {
                        return ('Obj',3,1);
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'N') {
              if ($h->{g_position} eq 'right') {
                  if ($h->{d_children} eq '1') {
                    return ('Adv',1,);
                  } elsif ($h->{d_children} eq '0') {
                    return ('AuxM',3,);
                  } elsif ($h->{d_children} eq 'more') {
                    return ('Obj',5,3);
                  }
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{d_children} eq 'more') {
                    return ('Atr',595,37);
                  } elsif ($h->{d_children} eq '1') {
                      if ($h->{d_verbmod} =~ /^(?:S|empty)$/) {
                        return ('Atr',0,);
                      } elsif ($h->{d_verbmod} eq 'D') {
                        return ('Adv',1,);
                      } elsif ($h->{d_verbmod} eq 'undef') {
                        return ('Atr',384,26);
                      } elsif ($h->{d_verbmod} eq 'I') {
                        return ('Atr',30,);
                      }
                  } elsif ($h->{d_children} eq '0') {
                      if ($h->{g_children} eq '1') {
                        return ('Atr',11,);
                      } elsif ($h->{g_children} eq 'more') {
                          if ($h->{d_subpos} =~ /^(?:N|undef|D|C|R|empty)$/) {
                            return ('AuxY',0,);
                          } elsif ($h->{d_subpos} eq 'P') {
                            return ('Atr',5,2);
                          } elsif ($h->{d_subpos} eq 'I') {
                            return ('AuxY',8,2);
                          }
                      }
                  }
              }
          } elsif ($h->{g_pos} eq 'V') {
              if ($h->{g_position} eq 'right') {
                  if ($h->{g_subpos} =~ /^(?:N|undef|C|D|R|root|empty)$/) {
                    return ('Adv',0,);
                  } elsif ($h->{g_subpos} eq 'I') {
                    return ('Adv',16,4);
                  } elsif ($h->{g_subpos} eq 'P') {
                      if ($h->{d_children} eq '1') {
                        return ('ExD',1,);
                      } elsif ($h->{d_children} eq '0') {
                        return ('Adv',2,1);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Atr',5,3);
                      }
                  }
              } elsif ($h->{g_position} eq 'left') {
                  if ($h->{g_verbmod} =~ /^(?:D|empty|root)$/) {
                    return ('Obj',0,);
                  } elsif ($h->{g_verbmod} eq 'S') {
                    return ('Atr',3,2);
                  } elsif ($h->{g_verbmod} eq 'I') {
                      if ($h->{d_children} eq '0') {
                        return ('Atr',1,);
                      } elsif ($h->{d_children} eq 'more') {
                        return ('Adv',13,7);
                      } elsif ($h->{d_children} eq '1') {
                          if ($h->{d_verbmod} eq 'empty') {
                            return ('Adv',0,);
                          } elsif ($h->{d_verbmod} eq 'S') {
                            return ('Obj',3,2);
                          } elsif ($h->{d_verbmod} eq 'D') {
                            return ('Sb',1,);
                          } elsif ($h->{d_verbmod} eq 'undef') {
                            return ('Adv',2,);
                          } elsif ($h->{d_verbmod} eq 'I') {
                            return ('Atv',1,);
                          }
                      }
                  } elsif ($h->{g_verbmod} eq 'undef') {
                      if ($h->{g_subpos} =~ /^(?:N|undef|D|R|root|empty)$/) {
                        return ('Obj',0,);
                      } elsif ($h->{g_subpos} eq 'C') {
                        return ('AuxP',1,);
                      } elsif ($h->{g_subpos} eq 'I') {
                          if ($h->{d_subpos} =~ /^(?:N|undef|D|C|R|empty)$/) {
                            return ('Adv',0,);
                          } elsif ($h->{d_subpos} eq 'P') {
                              if ($h->{g_children} eq '1') {
                                return ('Sb',8,3);
                              } elsif ($h->{g_children} eq 'more') {
                                  if ($h->{d_children} eq '0') {
                                    return ('Adv',0,);
                                  } elsif ($h->{d_children} eq '1') {
                                    return ('AuxP',15,10);
                                  } elsif ($h->{d_children} eq 'more') {
                                    return ('Adv',17,11);
                                  }
                              }
                          } elsif ($h->{d_subpos} eq 'I') {
                              if ($h->{g_children} eq '1') {
                                return ('Obj',7,1);
                              } elsif ($h->{g_children} eq 'more') {
                                  if ($h->{d_verbmod} eq 'empty') {
                                    return ('Adv',0,);
                                  } elsif ($h->{d_verbmod} eq 'S') {
                                    return ('Adv',1,);
                                  } elsif ($h->{d_verbmod} eq 'D') {
                                    return ('Sb',2,);
                                  } elsif ($h->{d_verbmod} eq 'undef') {
                                    return ('Adv',49,20);
                                  } elsif ($h->{d_verbmod} eq 'I') {
                                    return ('Obj',4,3);
                                  }
                              }
                          }
                      } elsif ($h->{g_subpos} eq 'P') {
                          if ($h->{d_children} eq '0') {
                            return ('Adv',5,3);
                          } elsif ($h->{d_children} eq 'more') {
                            return ('Obj',315,137);
                          } elsif ($h->{d_children} eq '1') {
                              if ($h->{d_voice} eq 'empty') {
                                return ('Atv',0,);
                              } elsif ($h->{d_voice} eq 'P') {
                                return ('Obj',2,);
                              } elsif ($h->{d_voice} eq 'undef') {
                                  if ($h->{d_subpos} =~ /^(?:N|undef|D|C|R|empty)$/) {
                                    return ('Atv',0,);
                                  } elsif ($h->{d_subpos} eq 'I') {
                                    return ('Atv',45,18);
                                  } elsif ($h->{d_subpos} eq 'P') {
                                      if ($h->{g_children} eq '1') {
                                        return ('Atr',13,9);
                                      } elsif ($h->{g_children} eq 'more') {
                                        return ('Atv',59,42);
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

# SubTree [S1]

sub evalSubTree1_S1 {
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:qayoda|Dimona|qabola|dAxila|duwna|Eaqiba|biaoni|spec_amperltspec_semicolizAspec_apha|spec_ampergtspec_semicolavonAspec_apha|TiwAla|xilAla|Hiyna|bispec_amperltspec_semicolizAspec_aphi|naHowa|amAm|spec_amperltspec_semicolilay|bayona|baEoda|Einodspec_plusa|bayoni|minspec_plusman|xArija|qabol|munospec_asteru|EalaY|la|Hatspec_tildaaY|ka|tujAha|>amAma|HawAlaY|fawora|wasoTa|spec_amperltspec_semicolilaY|ivora|Hawola|xalofa|Dimon|mivola|jarspec_tildaAspec_aph|spec_amperltspec_semicolizAspec_aph|fiy|<ilaY|xilAl|Eabora|bilA|Einoda|quroba|amspec_tildaA|ilay|dAxil|EadA|Ean|bispec_dollaraspec_ampergtspec_semicoloni|ladaY|aroq|spec_ampergtspec_semicolavonAspec_aph|spec_ampergtspec_semicolamAm|li|ilaY|bayonspec_plusi|fawoqa|qurob|HawAlay|spec_ampergtspec_semicolamspec_tildaA|Ealay|maEa|HiyAla|empty|bisabab|bi|spec_ampergtspec_semicolamAma|min|fawoq|spec_amperltspec_semicolivora|spec_dollararoq|Didspec_tildaa|laday|taHota)$/) {
    return ('Atr',0,);
  } elsif ($h->{i_lemma} eq 'bayonspec_plusa') {
    return ('Atr',17,9);
  } elsif ($h->{i_lemma} eq 'taHotspec_plusa') {
    return ('Obj',3,);
  }
}

# SubTree [S2]

sub evalSubTree1_S2 {
  my $h=$_[0];

  if ($h->{i_lemma} =~ /^(?:Dimona|dAxila|duwna|Eaqiba|biaoni|spec_amperltspec_semicolizAspec_apha|spec_ampergtspec_semicolavonAspec_apha|TiwAla|xilAla|Hiyna|bispec_amperltspec_semicolizAspec_aphi|naHowa|amAm|Einodspec_plusa|xArija|qabol|munospec_asteru|Hatspec_tildaaY|>amAma|fawora|wasoTa|ivora|xalofa|Dimon|jarspec_tildaAspec_aph|spec_amperltspec_semicolizAspec_aph|Einoda|quroba|amspec_tildaA|ilay|dAxil|bayonspec_plusa|EadA|bispec_dollaraspec_ampergtspec_semicoloni|aroq|spec_ampergtspec_semicolamAm|bayonspec_plusi|fawoqa|qurob|HawAlay|spec_ampergtspec_semicolamspec_tildaA|HiyAla|bisabab|taHotspec_plusa|fawoq|spec_amperltspec_semicolivora|spec_dollararoq|Didspec_tildaa|taHota)$/) {
    return ('AuxP',0,);
  } elsif ($h->{i_lemma} eq 'qayoda') {
    return ('Obj',2,);
  } elsif ($h->{i_lemma} eq 'qabola') {
    return ('AuxP',1,);
  } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilay') {
    return ('AuxP',61,2);
  } elsif ($h->{i_lemma} eq 'bayona') {
    return ('Atr',17,6);
  } elsif ($h->{i_lemma} eq 'baEoda') {
    return ('AuxC',31,14);
  } elsif ($h->{i_lemma} eq 'bayoni') {
    return ('PredP',3,);
  } elsif ($h->{i_lemma} eq 'minspec_plusman') {
    return ('Atr',2,);
  } elsif ($h->{i_lemma} eq 'EalaY') {
    return ('AuxP',84,21);
  } elsif ($h->{i_lemma} eq 'la') {
    return ('Obj',17,10);
  } elsif ($h->{i_lemma} eq 'ka') {
    return ('AuxP',15,5);
  } elsif ($h->{i_lemma} eq 'tujAha') {
    return ('AuxP',2,);
  } elsif ($h->{i_lemma} eq 'HawAlaY') {
    return ('Obj',2,);
  } elsif ($h->{i_lemma} eq 'spec_amperltspec_semicolilaY') {
    return ('AuxP',32,3);
  } elsif ($h->{i_lemma} eq 'Hawola') {
    return ('AuxP',1,);
  } elsif ($h->{i_lemma} eq 'mivola') {
    return ('Apos',7,);
  } elsif ($h->{i_lemma} eq 'fiy') {
    return ('AuxP',179,82);
  } elsif ($h->{i_lemma} eq '<ilaY') {
    return ('Coord',3,);
  } elsif ($h->{i_lemma} eq 'xilAl') {
    return ('AuxP',4,);
  } elsif ($h->{i_lemma} eq 'Eabora') {
    return ('AuxP',2,);
  } elsif ($h->{i_lemma} eq 'bilA') {
    return ('AtrAdv',3,);
  } elsif ($h->{i_lemma} eq 'Ean') {
    return ('AuxP',10,);
  } elsif ($h->{i_lemma} eq 'ladaY') {
    return ('Obj',3,);
  } elsif ($h->{i_lemma} eq 'spec_ampergtspec_semicolavonAspec_aph') {
    return ('AuxP',3,);
  } elsif ($h->{i_lemma} eq 'li') {
    return ('AuxP',89,14);
  } elsif ($h->{i_lemma} eq 'ilaY') {
    return ('AuxP',10,2);
  } elsif ($h->{i_lemma} eq 'Ealay') {
    return ('AuxP',71,18);
  } elsif ($h->{i_lemma} eq 'maEa') {
    return ('Coord',9,4);
  } elsif ($h->{i_lemma} eq 'bi') {
    return ('AuxP',134,19);
  } elsif ($h->{i_lemma} eq 'spec_ampergtspec_semicolamAma') {
    return ('Obj',2,);
  } elsif ($h->{i_lemma} eq 'min') {
    return ('AuxP',333,130);
  } elsif ($h->{i_lemma} eq 'laday') {
    return ('Obj',26,4);
  } elsif ($h->{i_lemma} eq 'empty') {
      if ($h->{g_pos} =~ /^(?:T|I|empty|root)$/) {
        return ('AuxP',0,);
      } elsif ($h->{g_pos} eq 'A') {
        return ('AuxP',9,3);
      } elsif ($h->{g_pos} eq 'F') {
        return ('Obj',27,7);
      } elsif ($h->{g_pos} eq 'undef') {
        return ('AuxP',2,);
      } elsif ($h->{g_pos} eq 'N') {
        return ('AuxP',147,40);
      } elsif ($h->{g_pos} eq 'X') {
        return ('AuxP',16,7);
      } elsif ($h->{g_pos} eq 'P') {
        return ('Obj',6,4);
      } elsif ($h->{g_pos} eq 'Y') {
        return ('AtrAdv',1,);
      } elsif ($h->{g_pos} eq 'V') {
        return ('AuxP',243,43);
      } elsif ($h->{g_pos} eq 'Z') {
        return ('AuxP',3,1);
      } elsif ($h->{g_pos} eq 'Q') {
        return ('Atr',1,);
      } elsif ($h->{g_pos} eq 'D') {
        return ('AuxP',6,4);
      } elsif ($h->{g_pos} eq 'G') {
        return ('AuxP',1,);
      } elsif ($h->{g_pos} eq 'S') {
          if ($h->{g_children} eq '1') {
            return ('Atr',5,3);
          } elsif ($h->{g_children} eq 'more') {
            return ('PredP',2,1);
          }
      }
  }
}

# Evaluation on hold-out data (6309 cases):
#
#       Decision Tree
#     ----------------
#     Size      Errors
#
#      672  939(14.9%)   <<
#
#
# [ Fold 1 ]
#

1;
