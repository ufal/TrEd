# -*- cperl -*-
unshift @INC,"$libDir/contrib" unless (grep($_ eq "$libDir/contrib", @INC));
require ArabicRemix;
no integer;

# does the OS or TrEd+Tk support propper arabic rendering
$ArabicRendering=($^O eq 'MSWin32' or 1000*$] >= 5008);

# if not, at least reverse all non-asci strings
unless ($ArabicRendering) {
  print STDERR "Arabic: Forcing right-to-left\n";
  $TrEd::Convert::lefttoright=0;
}

unless ($^O eq 'MSWin32') {
  $TrEd::Config::valueLineReverseLines=1;
}
$TrEd::Config::valueLineAlign='right';

# display nodes in the reversed order
print STDERR "Arabic: Forcing reverseNodeOrder\n";
$main::treeViewOpts->{reverseNodeOrder}=1;
foreach (@{$grp->{framegroup}->{treeWindows}}) {
  $_->treeView->apply_options($main::treeViewOpts);
}

# setup file encodings
if ($^O eq 'MSWin32') {
  $TrEd::Convert::outputenc='windows-1256';
  print STDERR $TrEd::Convert::inputenc,"\n";
} else {
  $TrEd::Convert::outputenc='iso-8859-6';
  print STDERR $TrEd::Convert::outputenc,"\n";
}
$TrEd::Convert::inputenc='windows-1256';

# setup CSTS header
Csts2fs::setupPADTAR();

# align node labels to right for more natural look
$TrEd::TreeView::DefaultNodeStyle{NodeLabel}=
  [-valign => 'top', -halign => 'right'];
$TrEd::TreeView::DefaultNodeStyle{Node}=
  [-textalign => 'right'];

# create the value_line
sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  if ($^O ne 'MSWin32') {
    if (1000*$] >= 5008) { # we've got support for UNICODE in
      # perl5.8/Tk8004
      print "Arabic: Skipping remix\n";
      return undef;        # use the default way to do it
#       print STDERR "PERLVERSION $]\n";
#       require Encode;
#       require TrEd::ConvertArab;
#       return $no.(
#		   TrEd::ConvertArab::arabjoin($2));
#  	             Encode::encode('windows-1256',
#		       ArabicRemix::remix(Encode::decode('windows-1256',$2))
#                  )));
    } else {
      print "Arabic: Skipping remix\n";
      return undef;        # use the default way to do it
    }
  } else {
    return [$fsfile->value_line_list($treeNo,1,1)];
#    my $line=$fsfile->value_line($treeNo,1);
#    print "Arabic: Using remix\n";
#    return $line;
#    return ArabicRemix::remix($line); # use Ota Smrz's remix
  }
}

# if arabic text is not rendered ok, use this function to provide a
# reversed nodelist for both value_line and the tree (since
# reverseNodeOrder is intenden only for the tree)

sub get_nodelist_hook {
  my ($fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  return undef if $ArabicRendering;

  my ($nodes,$current)=$fsfile->nodes($tree_no,$prevcurrent,$show_hidden);
#  print "Arabic: reversing nodelist\n";
  return [[reverse @$nodes],$current];
}

#binding-context Analytic
package Analytic;

#bind afun_auxM to m
sub afun_auxM {AfunAssign('AuxM');}
#bind afun_auxM_Co to Ctrl+m
sub afun_auxM_Co {AfunAssign('AuxM_Co');}
#bind afun_auxM_Ap to M
sub afun_auxM_Ap { AfunAssign('AuxM_Ap');}
#bind afun_auxM_Pa to Ctrl+M
sub afun_auxM_Pa { AfunAssign('AuxM_Pa'); }

#bind afun_auxE to f
sub afun_auxE {AfunAssign('AuxE')}
#bind afun_auxE_Co to Ctrl+f
sub afun_auxE_Co {AfunAssign('AuxE_Co')}
#bind afun_auxE_Ap to F
sub afun_auxE_Ap {AfunAssign('AuxE_Ap')}
#bind afun_auxE_Pa to Ctrl+F
sub afun_auxE_Pa {AfunAssign('AuxE_Pa')}

#bind afun_Ref to r
sub afun_Ref {AfunAssign('Ref')}
#bind afun_Ref_Co to Ctrl+r
sub afun_Ref_Co {AfunAssign('Ref_Co')}
#bind afun_Ref_Ap to R
sub afun_Ref_Ap {AfunAssign('Ref_Ap')}
#bind afun_Ref_Pa to Ctrl+R
sub afun_Ref_Pa {AfunAssign('Ref_Pa')}

#bind afun_Ante to t
sub afun_Ante {AfunAssign('Ante')}
#bind afun_Ante_Co to Ctrl+t
sub afun_Ante_Co {AfunAssign('Ante_Co')}
#bind afun_Ante_Ap to T
sub afun_Ante_Ap {AfunAssign('Ante_Ap')}
#bind afun_Ante_Pa to Ctrl+T
sub afun_Ante_Pa {AfunAssign('Ante_Pa')}


sub AfunAssign {
  my $n;			# used as type "pointer"
  my $fullafun=$_[0] || $sPar1;
  my ($afun,$parallel,$paren)=($fullafun=~/^([^_]*)(?:_(Ap|Co|no-parallel))?(?:_(Pa|no-paren))?/);
  if ($this->{'afun'} ne 'AuxS') {
    if ($this->{'afun'} ne '???') {
      $this->{'afunprev'} = $this->{'afun'};
    }
    $this->{'afun'} = $afun;
    $this->{'parallel'} = $parallel;
    $this->{'paren'} = $paren;

    $iPrevAfunAssigned = $this->{'ord'};
    $this=$this->following;
  }
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:form|afun|parallel|paren|arabfa|arabspec|arabclause|commentA|err1|err2)$/) {
    return "stop";
  }
}

#bind cycle_redraw to key Ctrl+)
sub cycle_redraw {
  use Benchmark;
  my $t = timeit(50, 'Redraw();$grp->{framegroup}->{top}->update();');
  print STDERR "$count loops of other code took:",timestr($t),"n";
}

#bind assign_paren to key 2
sub assign_paren {
  $this->{paren}||='no-paren';
  EditAttribute($this,'paren');
}

#bind assign_arabfa to key 3
sub assign_arabfa {
  $this->{arabfa}||='no-fa';
  EditAttribute($this,'arabfa');
}

#bind assign_arabspec to key 4
sub assign_arabspec {
  $this->{arabspec}||='no-spec';
  EditAttribute($this,'arabspec');
}

#bind assign_arabclause to key 5
sub assign_arabclause {
  $this->{arabclause}||='no-clause';
  EditAttribute($this,'arabclause');
}

#bind default_ar_attrs to F8 menu Display default attributes
sub default_ar_attrs {
  return unless $grp->{FSFile};
  SetDisplayAttrs('${form}',
		'#{custom1}<? join "_", map { "\${$_}" }
                    grep { $node->{$_}=~/./ && $node->{$_}!~/^no-/ }
	            qw(afun parallel paren arabfa arabspec arabclause) ?>');
  SetBalloonPattern("tag:\t\${tag}\nlemma:\t\${lemma}\ngloss:\t\${x_gloss}\ncommentA:\t\${commentA}");
  return 1;
}
