# -*- cperl -*-

#include <tred.mac>

#binding-context TredMacro;
package TredMacro;

sub file_opened_hook {

    SwitchContext('Analytic');
}

#include <contrib/arabic_common.mak>

#binding-context Analytic
package Analytic;

sub AfunAssign {
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

#bind afun_unset to question menu Arabic: Assign afun ???
sub afun_unset {AfunAssign('???');}

#bind afun_auxM to m menu Arabic: Assign afun AuxM
sub afun_auxM {AfunAssign('AuxM');}
#bind afun_auxM_Co to Ctrl+m
sub afun_auxM_Co {AfunAssign('AuxM_Co');}
#bind afun_auxM_Ap to M
sub afun_auxM_Ap { AfunAssign('AuxM_Ap');}
#bind afun_auxM_Pa to Ctrl+M
sub afun_auxM_Pa { AfunAssign('AuxM_Pa'); }

#bind afun_auxE to f menu Arabic: Assign afun AuxE
sub afun_auxE {AfunAssign('AuxE')}
#bind afun_auxE_Co to Ctrl+f
sub afun_auxE_Co {AfunAssign('AuxE_Co')}
#bind afun_auxE_Ap to F
sub afun_auxE_Ap {AfunAssign('AuxE_Ap')}
#bind afun_auxE_Pa to Ctrl+F
sub afun_auxE_Pa {AfunAssign('AuxE_Pa')}

#bind afun_Ref to r menu Arabic: Assign afun Ref
sub afun_Ref {AfunAssign('Ref')}
#bind afun_Ref_Co to Ctrl+r
sub afun_Ref_Co {AfunAssign('Ref_Co')}
#bind afun_Ref_Ap to R
sub afun_Ref_Ap {AfunAssign('Ref_Ap')}
#bind afun_Ref_Pa to Ctrl+R
sub afun_Ref_Pa {AfunAssign('Ref_Pa')}

#bind afun_Ante to t menu Arabic: Assign afun Ante
sub afun_Ante {AfunAssign('Ante')}
#bind afun_Ante_Co to Ctrl+t
sub afun_Ante_Co {AfunAssign('Ante_Co')}
#bind afun_Ante_Ap to T
sub afun_Ante_Ap {AfunAssign('Ante_Ap')}
#bind afun_Ante_Pa to Ctrl+T
sub afun_Ante_Pa {AfunAssign('Ante_Pa')}

#bind assign_paren to key 2 menu Arabic: Suffix Paren
sub assign_paren {
  $this->{paren}||='no-paren';
  EditAttribute($this,'paren');
}

#bind assign_arabfa to key 3 menu Arabic: Suffix ArabFa
sub assign_arabfa {
  $this->{arabfa}||='no-fa';
  EditAttribute($this,'arabfa');
}

#bind assign_arabspec to key 4 menu Arabic: Suffix ArabSpec
sub assign_arabspec {
  $this->{arabspec}||='no-spec';
  EditAttribute($this,'arabspec');
}

#bind assign_arabclause to key 5 menu Arabic: Suffix ArabClause
sub assign_arabclause {
  $this->{arabclause}||='no-clause';
  EditAttribute($this,'arabclause');
}

# ##################################################################################################
#
# ##################################################################################################

### remove old PDT bindings used for Czech etc.

#unbind-key Ctrl+Shift+F1
#remove-menu Automatically assign afun to subtree
#unbind-key Ctrl+F9
#remove-menu Parse Slovene sentence
#unbind-key Ctrl+Shift+F9
#remove-menu Auto-assign analytical function to node
#unbind-key Ctrl+Shift+F10
#remove-menu Assign Slovene afun
#remove-menu Auto-assign analytical functions to tree

### rebind PDT bindings used for Czech with Arabic ones
#bind assign_afun_auto Ctrl+Shift+F9 menu Arabic: Auto-assign analytical function to node
sub assign_afun_auto {
  shift if (@_ and !ref($_[0]));
  my $node = $_[0] || $this;
  return unless ($node && $node->parent() &&
         ($node->{func} eq '???' or
          $node->{func} eq ''));


  require Assign_arab_afun;

  my ($ra,$rb,$rc)=Assign_arab_afun::afun($node);
  $node->{afun}=$ra;
  print STDERR "$node->{lemma} ($ra,$rb,$rc)\n";
}

sub node_moved_hook {
  #my ($node)=@_;
  #assign_afun_auto($node);
}

#bind assign_all_afun_auto to Ctrl+Shift+F10 menu Arabic: Auto-assign analytical functions to tree
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

# bind padt_auto_parse_tree to Ctrl+Shift+F2 menu Arabic: Parse the current sentence and build a tree
sub padt_auto_parse_tree {
  require Arab_parser;
  Arab_parser::parse_sentence($grp,$root);
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
             -width => '&1',
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
             -width => '&1',
             -fill => '&#FFA000',   # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );

  }
}

# ##################################################################################################
#
# ##################################################################################################

sub enable_attr_hook {

    return 'stop' unless $_[0] =~ /^(?:afun|parallel|paren|arabclause|arabfa|arabspec|comment|commentA|err1|err2)$/;
}

#remove-menu Edit annotator's comment
#bind edit_commentA to exclam menu Arabic: Edit Annotator's Comment
sub edit_commentA {

    my $comment = $grp->{FSFile}->FS->exists('comment') ? 'comment' : $grp->{FSFile}->FS->exists('commentA') ? 'commentA' : undef;

    unless (defined $comment) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => 'Sorry, no attribute for annotator\'s comment in this file',
            -title => 'Sorry',
            -type => 'OK'
        );

        $FileNotSaved = 0;
        return;
    }

    my $value = $this->{$comment};

    $value = main::QueryString($grp->{framegroup}, "Enter comment", $comment, $value);

    $this->{$comment} = $value if defined $value;
}

#remove-menu Display default attributes
#bind default_ar_attrs to F8 menu Arabic: Show / Hide Morphological Tags
sub default_ar_attrs {

    return unless $grp->{FSFile};

    my $pattern = '#{custom2}${tag}';

    my @original = GetDisplayAttrs();

    my @filtered = grep { $_ ne $pattern } @original;

    SetDisplayAttrs( @filtered, @original == @filtered ? $pattern : () );

    ChangingFile(0);

    return 1;
}

#bind invoke_undo BackSpace menu Arabic: Undo Annotation
sub invoke_undo {

    warn 'Undoooooing ;)';

    main::undo($grp);
    $this = $grp->{currentNode};

    ChangingFile(0);
}

#bind annotate_following space menu Arabic: Move to Following ???
sub annotate_following {

    my $node = $this;

    do { $this = $this->following() } while $this and $this->{afun} ne '???';

    $this = $node unless $this->{afun} eq '???';

    ChangingFile(0);
}

#bind annotate_previous Shift+space menu Arabic: Move to Previous ???
sub annotate_previous {

    my $node = $this;

    do { $this = $this->previous() } while $this and $this->{afun} ne '???';

    $this = $node unless $this->{afun} eq '???';

    ChangingFile(0);
}
