# -*- cperl -*-
unshift @INC,"$libDir/contrib" unless (grep($_ eq "$libDir/contrib", @INC));
unshift @INC,"$libDir/contrib/PADT" unless (grep($_ eq "$libDir/contrib/PADT", @INC));
require ArabicRemix;
no integer;


$support_unicode=($Tk::VERSION gt 804.00);

# does the OS or TrEd+Tk support propper arabic rendering
$ArabicRendering=($^O eq 'MSWin32' or $support_unicode);

# if not, at least reverse all non-asci strings
unless ($ArabicRendering) {
  print STDERR "Arabic: Forcing right-to-left\n";
  $TrEd::Convert::lefttoright=0;
}

$TrEd::Config::valueLineReverseLines=1;
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
} elsif ($support_unicode) {
  $TrEd::Convert::outputenc='iso10646-1';
  print STDERR $TrEd::Convert::outputenc,"\n";
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

# reload config
main::read_config();
eval {
  main::reconfigure($grp->{framegroup});
};

# create the value_line
# sub get_value_line_hook {
#   my ($fsfile,$treeNo)=@_;
#   if ($^O ne 'MSWin32') {
#     if (1000*$] >= 5008) { # we've got support for UNICODE in
#       # perl5.8/Tk8004
#       print "Arabic: Skipping remix\n";
#       return undef;        # use the default way to do it
# #       print STDERR "PERLVERSION $]\n";
# #       require Encode;
# #       require TrEd::ConvertArab;
# #       return $no.(
# #		   TrEd::ConvertArab::arabjoin($2));
# #  	             Encode::encode('windows-1256',
# #		       ArabicRemix::remix(Encode::decode('windows-1256',$2))
# #                  )));
#     } else {
#       print "Arabic: Skipping remix\n";
#       return undef;        # use the default way to do it
#     }
#   } else {
#     return [$fsfile->value_line_list($treeNo,1,1)];
# #    my $line=$fsfile->value_line($treeNo,1);
# #    print "Arabic: Using remix\n";
# #    return $line;
# #    return ArabicRemix::remix($line); # use Ota Smrz's remix
#   }
# }

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

#bind afun_auxM to m menu AuxM
sub afun_auxM {AfunAssign('AuxM');}
#bind afun_auxM_Co to Ctrl+m
sub afun_auxM_Co {AfunAssign('AuxM_Co');}
#bind afun_auxM_Ap to M
sub afun_auxM_Ap { AfunAssign('AuxM_Ap');}
#bind afun_auxM_Pa to Ctrl+M
sub afun_auxM_Pa { AfunAssign('AuxM_Pa'); }

#bind afun_auxE to f menu AuxE
sub afun_auxE {AfunAssign('AuxE')}
#bind afun_auxE_Co to Ctrl+f
sub afun_auxE_Co {AfunAssign('AuxE_Co')}
#bind afun_auxE_Ap to F
sub afun_auxE_Ap {AfunAssign('AuxE_Ap')}
#bind afun_auxE_Pa to Ctrl+F
sub afun_auxE_Pa {AfunAssign('AuxE_Pa')}

#bind afun_Ref to r menu Ref
sub afun_Ref {AfunAssign('Ref')}
#bind afun_Ref_Co to Ctrl+r
sub afun_Ref_Co {AfunAssign('Ref_Co')}
#bind afun_Ref_Ap to R
sub afun_Ref_Ap {AfunAssign('Ref_Ap')}
#bind afun_Ref_Pa to Ctrl+R
sub afun_Ref_Pa {AfunAssign('Ref_Pa')}

#bind afun_Ante to t menu Ante
sub afun_Ante {AfunAssign('Ante')}
#bind afun_Ante_Co to Ctrl+t
sub afun_Ante_Co {AfunAssign('Ante_Co')}
#bind afun_Ante_Ap to T
sub afun_Ante_Ap {AfunAssign('Ante_Ap')}
#bind afun_Ante_Pa to Ctrl+T
sub afun_Ante_Pa {AfunAssign('Ante_Pa')}


### remove old PDT bindings used for Czech
#unbind-key Ctrl+Shift+F1
#remove-menu Automatically assign afun to subtree

### rebind PDT bindings used for Czech with Arabic ones
#bind assign_afun_auto Ctrl+Shift+F9 menu Auto-assign analytical function to node
sub assign_afun_auto {
  shift if (@_ and !ref($_[0]));
  my $node = $_[0] || $this;
  return unless ($node && $node->parent() &&
		 ($node->{func} eq '???' or
		  $node->{func} eq ''));


  require Assign_arab_afun;

  my ($ra,$rb,$rc)=Assign_arab_afun::afun($node);
  $node->{afun}=$ra;
#  print STDERR "$node->{lemma} ($ra,$rb,$rc)\n";
}

#bind assign_all_afun_auto to Ctrl+Shift+F10 menu Auto-assign analytical functions to tree
sub assign_all_afun_auto {
  shift if (@_ and !ref($_[0]));
  my $top = $_[0] || $root;
  require Assign_arab_afun;

  my $node = $top;
  while ($node) {
    assign_afun_auto($node);
    $node = NextVisibleNode($node,$top);
  }
}

# bind padt_auto_parse_tree to Ctrl+Shift+F2 menu Parse the current sentence and build a tree
sub padt_auto_parse_tree {
  require Arab_parser;
  Arab_parser::parse_sentence($grp,$root);
}


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

#bind assign_paren to key 2 menu Suffix Paren
sub assign_paren {
  $this->{paren}||='no-paren';
  EditAttribute($this,'paren');
}

#bind assign_arabfa to key 3 menu Suffix ArabFa
sub assign_arabfa {
  $this->{arabfa}||='no-fa';
  EditAttribute($this,'arabfa');
}

#bind assign_arabspec to key 4 menu Suffix ArabSpec
sub assign_arabspec {
  $this->{arabspec}||='no-spec';
  EditAttribute($this,'arabspec');
}

#bind assign_arabclause to key 5 menu Suffix ArabClause
sub assign_arabclause {
  $this->{arabclause}||='no-clause';
  EditAttribute($this,'arabclause');
}

#bind default_ar_attrs to F8 menu Display default attributes
sub default_ar_attrs {
  print "default ar attrs\n\n\n";
  return unless $grp->{FSFile};
  SetDisplayAttrs('${form}',
		'#{custom1}<? join "_", map { "\${$_}" }
                    grep { $this->{$_}=~/./ && $this->{$_}!~/^no-/ }
	            qw(afun parallel paren arabfa arabspec arabclause) ?>');
  SetBalloonPattern("tag:\t\${tag}\nlemma:\t\${lemma}\ngloss:\t\${x_gloss}\ncommentA:\t\${commentA}");
  return 1;
}


# root style hook
# here used only to check if the sentence contains a node with afun=Ante
sub root_style_hook {

}


# node styles to draw extra arrows
sub node_style_hook {
  my ($node,$styles)=@_;

  # Ref
  if ($node->{arabspec} eq 'Ref') {
      my $T;

      $T=<<'TARGET';
[!
    my($ante,$refer);
    my($head)=$this;

    # search for the head of the clause
    until ( (not $head) or ($head->{afun} eq 'Atr' and ($head->{arabclause}!~/^no-|^$/ or $head->{tag}=~/VERB/))
                        or ($head->{afun}=~/^(?:Pred|Pnom)/) ) {
      $head=$head->parent;
      $refer=$head if (not defined $refer and $head->{afun} eq 'Atr'); # attributive pseudo-clause
    }

    # search for an Ante in the subtree, or point to the parent of the $refer or $head
    if ($head) {
      $ante=$head;
      $ante=$ante->following($head) until (not($ante) or $ante->{afun} eq 'Ante');

      $ante or (defined $refer ? $refer->parent : $head->parent);
    }
    else { defined $refer ? $refer->parent : undef; }
!]
TARGET


    # Instructions for TrEd on how to compute a simple 3-point
    # multiline starting at the current node and ending at the node
    # given by $T with middle point just between those two plus 40
    # points either in the horizontal or vertical direction (depending
    # on the direction of a greater distance)
    my $coords=<<COORDS;
n,n,
n + (x$T-n)/2 + (abs(xn-x$T)>abs(yn-y$T)?0:-40),
n + (y$T-n)/2 + (abs(yn-y$T)>abs(xn-x$T) ? 0 : 40),
x$T,y$T
COORDS

    # the ampersand & separates settings for the default line
    # to the parent node and our line
    AddStyle($styles,'Line',
             -coords => 'n,n,p,p&'. # coords for the default edge to parent
                        $coords,    # coords for our line
             -arrow => '&last',
             -dash => '&_',
             -width => '&2',
             -fill => '&#C000D0',   # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );

  }


  # Msd
  if ($node->{arabspec} eq 'Msd') {
      my $T;

      $T=<<'TARGET';
[!
    my $head=$this->parent; # start one node above (the masdar itself might feature the critical tags)
    if ($this->{afun} eq 'Atr') { $head=$head->parent; } # constructs like <_hAfa 'a^sadda _hawfiN>

    # search for the verb, governing masdar or participle
    $head=$head->parent
      until ( (not $head) or ($head->{tag}=~/VERB|NOUN|ADJ/) );

    $head;
!]
TARGET


    # Instructions for TrEd on how to compute a simple 3-point
    # multiline starting at the current node and ending at the node
    # given by $T with middle point just between those two plus 40
    # points either in the horizontal or vertical direction (depending
    # on the direction of a greater distance)
    my $coords=<<COORDS;
n,n,
n + (x$T-n)/2 + (abs(xn-x$T)>abs(yn-y$T)?0:-40),
n + (y$T-n)/2 + (abs(yn-y$T)>abs(xn-x$T) ? 0 : 40),
x$T,y$T
COORDS

    # the ampersand & separates settings for the default line
    # to the parent node and our line
    AddStyle($styles,'Line',
             -coords => 'n,n,p,p&'. # coords for the default edge to parent
                        $coords,    # coords for our line
             -arrow => '&last',
             -dash => '&_',
             -width => '&2',
             -fill => '&#FFA000',   # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );

  }
}
