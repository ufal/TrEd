## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2004-11-01 14:00:06 pajas>

package EN_Tectogrammatic;

use base qw(Tectogrammatic Coref TredMacro);
import TredMacro;
import Tectogrammatic;
import Coref;


sub switch_context_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  if ($grp->{FSFile} and
      GetSpecialPattern('patterns') ne 'force' and
      !$grp->{FSFile}->hint()
     ) {
    default_tr_attrs();
  }
  $FileNotSaved=0;
}

sub upgrade_file {
  my $defs=$grp->{FSFile}->FS->defs;
  unless (exists($defs->{comparison_type})) {
    AppendFSHeader('@P comparison_type',
		   '@L comparison_type|NIL|equal|resembl');
  }
  upgrade_file_to_tid_aidrefs();
}

@en_special_trlemmas=
    #disp  trlemma gender number
    #
    # Predelat na entity: &Comma; &Colon; atd.
    #
    #  display         trlemma             gender  number  func
    ([ 'there',        '&there;',          '???',  '???', '???'   ],
     [ 'PersPron',     '&PersPron;',       '???',  '???', '???'   ],
     [ 'PersPronRefl', '&PersPronRefl;',   '???',  '???', '???'   ],
     [ 'VerbPron',     '&VerbPron;',       '???',  '???', '???'   ],
     [ 'Compar',       '&Compar;',         '???',  '???', '???'   ],
     [ 'one',          '&one;',            '???',  '???', '???'   ],
     [ 'that_way',     '&that_way;',       '???',  '???', '???'   ],
     [ 'Rcp',          '&Rcp;',            '???',  '???', 'PAT'   ],
     [ 'Gen',          '&Gen;',            '???',  '???', 'ACT'   ],
     [ 'Unsp',         '&Unsp;',           '???',  '???', '???'   ],
     [ 'Emp',          '&Emp;',            '???',  '???', 'ACT'   ],
     [ 'Cor',          '&Cor;',            '???',  '???', 'ACT'   ],
     [ 'QCor',         '&QCor;',           '???',  '???', 'ACT'   ]
    );


sub QueryTrlemma {
  local @Tectogrammatic::special_trlemmas = @en_special_trlemmas;
  Tectogrammatic::QueryTrlemma($this,1);
}

sub do_edit_attr_hook {
  my ($atr,$node)=@_;
  if ($atr eq 'trlemma' and $node->{ord}=~/\./) {
    if ($node->{trlemma} =~ /tady|tam/ or
	$node->{func} =~ /DIR[1-3]|LOC/) {
      QuerySemtam($node);
    } elsif ($node->{trlemma} eq 'kdy') {
      QueryKdy($node);
    } else {
      QueryTrlemma($node);
    }
    Redraw();                      # This is because tred does not
                                   # redraw automatically after hooks.
    $FileNotSaved=1;
    return 'stop';
  }
  return 1;
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  return 1;
}

sub node_release_hook {
  my ($node,$target,$mod)=@_;
  print "Mod: $mod\n";
  return 1 unless $mod;
  &Coref::node_release_hook(@_);
}

