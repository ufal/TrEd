# -*- cperl -*-
package TFA;
@ISA=qw(Tectogrammatic);
import main;
import TredMacro;
import Tectogrammatic;


#bind ShiftLeft to Ctrl+Left menu posun uzel doleva
#bind ShiftRight to Ctrl+Right menu posun uzel doprava
#bind tfa_focus to F menu tfa = focus
#bind tfa_topic to T menu tfa = topic
#bind tfa_C to C menu tfa = contrast
#bind tfa_NA to A menu tfa = NA
#bind ProjectivizeSubTree to P menu Projectivize subtree
#bind ShiftSTLeft to Alt+Left menu Shift subtree to the left
#bind ShiftSTRight to Alt+Right menu Shift subtree to the right

sub switch_context_hook {

  SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
		  '<? Parent($node) ? "#{custom4}\${tfa}#{default}_" : "" ?>'.
		  '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?>'.
		  '<? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>'
		 );
  SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		    "afun:\t\${afun}\ntag:\t\${tag}");
  $FileNotSaved=0;
  return "1";
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:tfa|err1)$/) {
    return "stop";
  }
}

sub tfa_C {
  $sPar1 = 'C';
  TFAAssign();
}

sub tfa_NA {
  $sPar1 = 'NA';
  TFAAssign();
}

sub ProjectivizeSubTree {

  my $top=ref($_[0]) ? $_[0] : $this;

  my @subtree=Projectivize($top);
  return undef unless @subtree;

  my @all;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);
  splice @all,Index(\@all,$top),1, @subtree;
  NormalizeOrds(\@all);

}

sub Projectivize {

  my ($top) = @_;
  return undef unless ref($top);

  my @subtree;
  my @sons_left;
  my @sons_right;
  my $i = 0;
  my $ord=$grp->{FSFile}->FS->order;

  push @subtree, [$top,1];

  while ($i<=$#subtree) {
    if ($subtree[$i]->[1] == 1) {
        @sons_left=undef;
	@sons_right=undef;
	$node=$subtree[$i]->[0]->firstson;
	  while ($node) {
	    if ($node->{$ord} < $subtree[$i]->[0]->{$ord}) {
	      push @sons_left, [$node,1];
	    }
	    else {
	      push @sons_right, [$node,1];
	    }
	    $node=$node->rbrother;
	  }
        $subtree[$i]->[1]=0;
        splice @subtree,$i+1,0,(sort {$a->[0]->{$ord} <=> $b->[0]->{$ord}} @sons_right);
        splice @subtree,$i,0, (sort {$a->[0]->{$ord} <=> $b->[0]->{$ord}} @sons_left);
      }
      else {
	$i++;
      }
  }

  return map {$_->[0]} @subtree;

}


sub ShiftSTLeft {
  return unless (GetOrd($this)>0);
  if ($main::showHidden) {
    ShiftSubTreeLeft($this);
  } else {
    ShiftSubTreeLeftSkipHidden($this);
  }
}

sub ShiftSTRight {
  return unless (GetOrd($this)>0);
  if ($main::showHidden) {
    ShiftSubTreeRight($this);
  } else {
    ShiftSubTreeRightSkipHidden($this);
  }
}


sub ShiftSubTreeLeft {

  my $top=ref($_[0]) ? $_[0] : $this;

  return undef unless my @subtree=Projectivize($top);

  my @all;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $i=Index(\@all,$top);
  if ($i>1) {
    splice @all,$i,1;
    splice @all,$i-1,0, @subtree;
  }
  else {
    splice @all,$i,1, @subtree;
  }
  NormalizeOrds(\@all);

}

sub ShiftSubTreeRight {

  my $top=ref($_[0]) ? $_[0] : $this;

  return undef unless my @subtree=Projectivize($top);

  my @all;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $i=Index(\@all,$top);
  if ($i<$#all) {
    splice @all,$i,1;
    splice @all,$i+1,0, @subtree;
  }
  else {
    splice @all,$i,1, @subtree;
  }
  NormalizeOrds(\@all);

}


sub ShiftSubTreeLeftSkipHidden {

  my $top=ref($_[0]) ? $_[0] : $this;

  return undef unless my @subtree=Projectivize($top);

  my @all;
  my @allvis;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $node=$root;
  while ($node) {
    push @allvis, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
      $node=$node->following_visible($grp->{FSFile}->FS) if IsHidden($node);
    }
    else {
      $node=$node->following_visible($grp->{FSFile}->FS);
    }
  }
  SortByOrd(\@allvis);

  my $i=Index(\@allvis,$top);
  if ($i>1) {
    splice @all,Index(\@all,$top),1;
    splice @all,Index(\@all,$allvis[$i-1]),0, @subtree;
  }
  else {
    splice @all,Index(\@all,$top),1, @subtree;
  }

  NormalizeOrds(\@all);

}


sub ShiftSubTreeRightSkipHidden {

  my $top=ref($_[0]) ? $_[0] : $this;

  return undef unless my @subtree=Projectivize($top);

  my @all;
  my @allvis;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $node=$root;
  while ($node) {
    push @allvis, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
      $node=$node->following_visible($grp->{FSFile}->FS) if IsHidden($node);
    }
    else {
      $node=$node->following_visible($grp->{FSFile}->FS);
    }
  }
  SortByOrd(\@allvis);

  my $i=Index(\@allvis,$top);
  if ($i<$#allvis) {
    splice @all,Index(\@all,$top),1;
    splice @all,Index(\@all,$allvis[$i+1])+1,0, @subtree;
  }
  else {
    splice @all,Index(\@all,$top),1, @subtree;
  }

  NormalizeOrds(\@all);

}



#  sub ShiftSubTreeLeft {
#    my ($node,$min)=@_;          # min sets the minimum left...
#    my $ord=$grp->{FSFile}->FS->order;     # ... boundary for Ord
#    return unless $node;
#    return 0 if ($node->{$ord} < $min);
#    Projectivize($node);
#    my @all=GetNodes();
#    SortByOrd(\@all);

#    return undef unless (defined($m) and !defined($min) || $m>$min);
#    my $x=max(Index(\@all,leftmost_descendant($node)),0);
#    my $y=max(Index(\@all,rightmost_descendant($node)),0);
#    $all[$x--]->{$ord}=$y;
#    for (my $i=$x;$i<=$y;$i++) { $all[$i]->{$ord}--; }
#    RepasteNode($node);
#  }



#  sub ShiftSubTreeLeftSkipHidden {
#    my ($node,$min)=@_;          # min sets the minimum left...
#    my $ord=$grp->{FSFile}->FS->order;     # ... boundary for Ord
#    return unless $node;

#    Projectivize($node);

#    my @all=GetNodes();
#    SortByOrd(\@all);

#  #  print "$n\n";

#    my @vis=GetVisibleNodes();
#    SortByOrd(\@vis);
#    my $m=Index(\@vis,$node);
#    my $beforethis=$vis[$m-1];

#    my $n=$node->{$ord};
#    return 0 if ($n < $min);

#    return undef unless (defined($m) and !defined($min) || $m>$min);
#    my $x=max(Index(\@all,leftmost_descendant($node)]),0);
#    my $y=max(Index(\@all,rightmost_descendant($node)]),0);
#    for (my $i=$n-1;$i>=$x;$i--) { $all[$i]->{$ord}++; }
#    $node->{$ord}=$x;
#    RepasteNode($node);
#  }



















