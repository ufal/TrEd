#
# Revision: $Revision$
# Checked-in: $Date$
# Time-stamp: <2001-11-20 11:15:03 pajas>
# See the bottom of this file for the POD documentation. Search for the
# string '=head'.

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# Several Perl Routines to handle files in treebank FS format
# See complete help in POD format at the end of this file

package Fslib;

use Exporter;
@ISA=(Exporter);
$VERSION = "1.2";

@EXPORT = qw/&ReadAttribs &ReadTree &GetTree &GetTree2 &PrintNode
	     &PrintTree &PrintFS &NewNode &Parent &LBrother &RBrother
	     &FirstSon &Next &Prev &DeleteTree &DeleteLeaf &Cut &Paste
	     &Set &Get &DrawTree &IsList &ListValues &ImportBackends/;

@EXPORT_OK = qw/$FSTestListValidity &Index &ParseNode &ParseNode2 &Ord
                &Value &Hide &SentOrd &Special &AOrd &AValue &AHide
                &ASentOrd &ASpecial &SetParent &SetLBrother
                &SetRBrother &SetFirstSon/;

use Carp;
use vars qw/$VERSION @EXPORT @EXPORT_OK $field $parent $firstson $lbrother $FSTestListValidity $Debug/;

$Debug=0;
$field='(?:\\\\[\\]\\,]|[^\\,\\]])*';
$parent="_P_";
$firstson="_S_";
$lbrother="_L_";
$rbrother="_R_";
$FSTestListValidity=0;

sub NewNode ($) {
  my $node = shift;
  $node->{$firstson}=0;
  $node->{$lbrother}=0;
  $node->{$rbrother}=0;
  $node->{$parent}=0;
  return $node;
}

sub Set ($$$) {
  shift->setAttribute(shift,shift);
}

sub Get ($$) {
  return shift->getAttribute(shift);
}

sub Parent {
  my ($node) = @_;
  return $node->{$parent};
}

sub SetParent ($$) {
  my ($node,$p) = @_;
  $node->{$parent}=$p if ($node);
}

sub LBrother ($) {
  my $node = shift;
  return $node->{$lbrother};
}

sub SetLBrother ($$) {
  my ($node,$p) = @_;
  $node->{$lbrother}=$p if ($node);
}


sub RBrother ($) {
  my $node = shift;
  return $node->{$rbrother};
}

sub SetRBrother ($$) {
  my ($node,$p) = @_;
  $node->{$rbrother}=$p if ($node);
}

sub FirstSon ($) {
  my $node = shift;
  return $node->{$firstson};
}

sub SetFirstSon ($$) {
  my ($node,$p) = @_;
  $node->{$firstson}=$p if ($node);
}

sub Next {
  my ($node,$top) = (shift, shift);
  $top=0 if !$top;

  if ($node->{$firstson}) {
    return $node->{$firstson};
  }
  while ($node) {
    return 0 if ($node==$top or !$node->{$parent});
    return $node->{$rbrother} if $node->{$rbrother};
    $node = $node->{$parent};
  }
  return 0;
}

sub Prev {
  my ($node,$top) = (shift, shift);
  $top=0 if !$top;
  
  if ($node->{$lbrother}) {
    $node = $node->{$lbrother};
  DIGDOWN: while ($node->{$firstson}) {
      $node = $node->{$firstson};
    LASTBROTHER: while ($node->{$rbrother}) {
    	$node = $node->{$rbrother};
        next LASTBROTHER;
      }
      next DIGDOWN;
    }
    return $node;
  }
  return 0 if ($node == $top or !$node->{$parent});
  return $node->{$parent};
}

sub IsList ($$) {
  my ($attrib, $href)=@_;
  return (index($href->{$attrib}," L")>=0);
}

sub ListValues ($$) {
  my ($attrib, $href)=@_;

# pokus o zrychleni
    my ($I,$b,$e);
    $b=index($href->{$attrib}," L=");
    if ($b>=0) {
      $e=index($href->{$attrib}," ",$b+1);
      if ($e>=0) {
        return split /\|/,substr($href->{$attrib},$b+3,$e-$b-3);
      } else {
	return split /\|/,substr($href->{$attrib},$b+3);
      }
    } else { return (); }

#  if ($href->{$attrib}=~/ L=([^ ]+)/) { # only lists may have preset values
#    return split /\|/,$1;
#  } else { return (); }
}

sub Special ($$$) {
  my ($node,$href,$defchar)=@_;

  if ($node and $href) {
    foreach (keys(%$href)) {
      return $node->getAttribute($_) if (index($href->{$_}," $defchar")>=0);
    }
  }
  return undef;
}

sub ASpecial ($$) {
  my ($href,$defchar)=@_;

  if ($href) {
    foreach (keys(%$href)) {
      return $_ if (index($href->{$_}," $defchar")>=0);
    }
  }
  return undef;
}

sub ASentOrd ($) {
  return ASpecial(shift,'W');
}


sub SentOrd ($$) {
  return Special(shift,shift,'W');
}

sub Ord ($$) {
  return Special(shift,shift,'N');
}

sub AOrd ($) {
  return ASpecial(shift,'N');
}

sub Hide ($$) {
  return Special(shift,shift,'H');
}

sub AHide ($) {
  return ASpecial(shift,'H');
}


sub Value ($$) {
  return Special(shift,shift,'V');
}

sub AValue ($) {
  return ASpecial(shift,'V');
}

sub Cut ($) {
  my $node=shift;
  return $node if (! $node);

  if ($node->{$parent} and $node==$node->{$parent}->{$firstson}) {
    $node->{$parent}->{$firstson}=$node->{$rbrother};
  }
  $node->{$lbrother}->{$rbrother}=$node->{$rbrother} if ($node->{$lbrother});
  $node->{$rbrother}->{$lbrother}=$node->{$lbrother} if ($node->{$rbrother});

  $node->{$parent}=$node->{$lbrother}=$node->{$rbrother}=0;
  return $node;
}

sub Paste ($$$) {
  my ($node,$p,$href)=(shift,shift,shift);
  my $aord=AOrd($href);
  my $ordnum = $node->getAttribute($aord);

  $b=$p->{$firstson};
  if ($b and $ordnum>$b->getAttribute($aord)) {
    $b=$b->{$rbrother} while ($b->{$rbrother} and $ordnum>$b->{$rbrother}->getAttribute($aord));
    $node->{$rbrother}=$b->{$rbrother};
    $b->{$rbrother}->{$lbrother}=$node if ($b->{$rbrother});
    $b->{$rbrother}=$node;
    $node->{$lbrother}=$b;
  } else {
    $node->{$rbrother}=$b;
    $p->{$firstson}=$node;
    $node->{$lbrother}=0;
    $b->{$lbrother}=$node if ($b);
  }
  $node->{$parent}=$p;
}

sub DeleteTree ($) {
#  print "Deleting tree\n";
  $top=$node=shift;
  while ($node) {
    if ($node!=$top
	and !$node->{$firstson}
	and !$node->{$lbrother}
	and !$node->{$rbrother}) {
      $next=$node->{$parent};
    } else {
      $next=Next($node,$top);
    }
    DeleteLeaf($node);
    $node=$next;
  }
}

sub DeleteLeaf ($) {
#  print "Deleting";
  $node=shift;
  if (!$node->{$firstson}) {
    $node->{$rbrother}->{$lbrother}=$node->{$lbrother} if ($node->{$rbrother});

    if ($node->{$lbrother}) {
      $node->{$lbrother}->{$rbrother}=$node->{$rbrother};
    } else {
      $node->{$parent}->{$firstson}=$node->{$rbrother} if $node->{$parent};
    }
#    print " leaf ",$node->getAttribute("form"),"\n";
    undef %$node;
    undef $node;
    return 1;
  }
#  print " nothing\n";
  return 0;
}


sub Index ($$) {
  my ($ar,$i) = @_;
  for (my $n=0;$n<=$#$ar;$n++) {
    return $n if ($ar->[$n] eq $i);
  }
  return undef;
}

## FS format IO backend

sub ReadAttribs  {
  my ($handle,$order,$DO_PRINT,$out) = @_;
  my $outfile = ($out ? $out : \*STDOUT);

  my %result;
  my $count=0;

  while ($_=ReadTree($handle)) {

    s/\r$//o;

    print $outfile $_ if $DO_PRINT==1;
    push @$out, $_ if $DO_PRINT==2; 
    if (/^\@([KPOVNWLH])([A-Z0-9])* ([-_A-Za-z0-9]+)(?:\|(.*))?/o) {
      $order->[$count++]=$3 if (!defined($result{$3}));
      if ($4) {
	$result{$3}.=" $1=$4"; # so we create a list of defchars separated by spaces
      } else {                 # a value-list may follow the equation mark
	$result{$3}.=" $1";
      }
      if ($2) {
	$result{$3}.=" $2"; # we add a special defchar being the color
      }
      next;
    }
    last if (/^\r*$/o);
  }
  return %result;
}

sub ParseNode ($$$) {
  my ($lr,$ord,$attr) = @_;
  my $n = 0;
  my $node;
  my $pos = 1;
  my $a=0;
  my $v=0;
  my $tmp;
  my @lv;

  $node=FSNode->new();
  if ($$lr=~/\G\[/gsco) {
    while ($$lr !~ /\G\]/gsco) {
      $n++,next if ($$lr=~/\G\,/gsco);
      if ($$lr=~/\G([-_A-Za-z0-9]+)=($field)/gsco) {
	$a=$1;
	$v=$2;
	$tmp=Index($ord,$a);
	$n = $tmp if (defined($tmp));
      } elsif ($$lr=~/\G($field)/gsco) {
	$v=$1;
        $n++ while ( $n<=$#$ord and $attr->getAttribute($ord->[$n])!~/ [PNW]/);
	if ($n>$#$ord) {
	  croak "No more positional attribute for value $v at position ".pos($$lr)." in:\n".$$lr."\n";
	}
	$a=$ord->[$n];

      } 
      $v=~s/\\([,=\[\]\\])/$1/go;
      if ($FSTestListValidity) {
	if (IsList($a,$attr)) {
	  @lv=ListValues($a,$attr);
	  foreach $tmp (split /\|/,$v) {
	    carp("Invalid list value $v of atribute $a at position ".pos($$lr)." in:\n".$$lr."\n" )
	      unless (defined(Index(\@lv,$tmp))); 
	    #(0<grep($_ eq $tmp, @lv)); # this seems to be slower
	  }
	}
      }
      $node->setAttribute($a,$v);
    }
  } else { croak $$lr," not node!\n"; }
  return $node;
}

sub ParseNode2 ($$$) {
  my ($lr,$ord,$attr) = @_;
  my $n = 0;
  my $node;
  my @ats=();
  my $pos = 1;
  my $a=0;
  my $v=0;
  my $tmp;
  my @lv;
  my $nd;
  my $i;
  my $w;

  $node = FSNode->new();
  if ($$lr=~/^\[/) {
    chomp $$lr;
    $i=index($$lr,']');
    $nd=substr($$lr,1,$i-1);
    $$lr=substr($$lr,$i+1);
    @ats=split(',',$nd);
    while (@ats) {
      $w=shift @ats;
      $i=index($w,'=');
      if ($i>=0) {
	$a=substr($w,0,$i);
	$v=substr($w,$i+1);
	$tmp=Index($ord,$a);
	$n = $tmp if (defined($tmp));
      } else {
	$v=$w;
        $n++ while ( $n<=$#$ord and $attr->{$ord->[$n]}!~/ [PNW]/);
	if ($n>$#$ord) {
	  croak "No more positional attribute $n for value $v at position in:\n".$n."\n";
	}
	$a=$ord->[$n];
      }
      #$v=~s/\\([,=\[\]\\])/$1/go;
      if ($FSTestListValidity) {
	if (IsList($a,$attr)) {
	  @lv=ListValues($a,$attr);
	  foreach $tmp (split /\|/,$v) {
	    print("Invalid list value $v of atribute $a no in @lv:\n$nd\n" )
	      unless (defined(Index(\@lv,$tmp))); 
	    #(0<grep($_ eq $tmp, @lv)); # this seems to be slower
	  }
	}
      }
      $n++;
      $v=~s/&comma;/,/g;
      $v=~s/&lsqb;/[/g;
      $v=~s/&rsqb;/]/g;
      $v=~s/&backslash;/\\/g;
      $v=~s/&eq;/=/g;
      $node->setAttribute($a,$v);
    }
  } else { croak $$lr," not node!\n"; }
  return $node;
}


sub ReadLine {
  my $handle=shift;

  if (ref($handle) eq 'ARRAY') {
    $_=shift @$handle;
  } else { $_=<$handle>; return $_; }
  return $_;
}

sub ReadTree {
  my $handle=shift;                # file handle or array reference
  my $l=undef;

  while (ReadLine($handle)) {
    if (s/\\\r*\n//go) { $l.=$_; next; } # if backslashed eol, concatenate
    $l.=$_;
    last;                               # else we have the whole tree
  }
  return $l;
}

sub GetTree2 ($$$) {
  my ($l,$ord,$atr)=@_;
  my $root;
  my $curr;
  my $c;
  if ($l=~/^\[/o) {
    $l=~s/\\,/&comma;/g;
    $l=~s/\\\[/&lsqb;/g;
    $l=~s/\\]/&rsqb;/g;
    $l=~s/\\\\/&backslash;/g;
    $l=~s/\\=/&eq;/g;
    $l=~s/\r//g;
    $curr=$root=ParseNode2(\$l,$ord,$atr);   # create Root

    while ($l) {
      $c = substr($l,0,1);
      $l = substr($l,1);
      if ( $c eq '(' ) { # Create son (go down)
	$curr->{$firstson} = ParseNode2(\$l,$ord,$atr);
	$curr->{$firstson}->{$parent}=$curr; 
	$curr=$curr->{$firstson};
	next;
      }
      if ( $c eq ')' ) { # Return to parent (go up)
	croak "Error paring tree" if ($curr eq $root);
	$curr=$curr->{$parent};
	next;
      }
      if ( $c eq ',' ) { # Create right brother (go right);
	$curr->{$rbrother} = ParseNode2(\$l,$ord,$atr);
	$curr->{$rbrother}->{$lbrother}=$curr;
	$curr->{$rbrother}->{$parent}=$curr->{$parent}; 
	$curr=$curr->{$rbrother};
	next;
      }
      croak "Unexpected token... `$c'!\n$l\n";
    }
    croak "Error: Closing parens do not lead to root of the tree." 
	if ($curr != $root);
  }
#    else { croak "** $l\nTree does not begin with `['!\n"; }
#  reset;
  return $root;
}

sub GetTree ($$$) {
  my ($l,$ord,$atr)=@_;
  my $root;
  my $curr;
  if ($l=~/^\[/o) {
    $curr=$root=ParseNode(\$l,$ord,$atr);   # create Root

    while ($l !~ /\G\r*$/gsco) {
      if ( $l=~/\G\(/gsco ) { # Create son (go down)
	$curr->{$firstson} = ParseNode(\$l,$ord,$atr);
	$curr->{$firstson}->{$parent}=$curr; 
	$curr=$curr->{$firstson};
	next;
      }
      if ( $l=~/\G\)/gsco ) { # Return to parent (go up)
	croak "Error paring tree" if ($curr eq $root);
	$curr=$curr->{$parent};
	next;
      }
      if ( $l=~/\G,/gsco ) { # Create right brother (go right);
	$curr->{$rbrother} = ParseNode(\$l,$ord,$atr);
	$curr->{$rbrother}->{$lbrother}=$curr;
	$curr->{$rbrother}->{$parent}=$curr->{$parent};
	$curr=$curr->{$rbrother};
	next;
      }
      $l=~/\G(.)/gsco;
      croak "Unexpected token `$1'!\n$l\n";
    }
    croak "Error: Closing parens do not lead to root of the tree." 
	if ($curr != $root);
  }
#    else { croak "** $l\nTree does not begin with `['!\n"; }
#  reset;
  return $root;
}

sub PrintNode($$$$) {
  my ($node,			# a reference to the root-node
      $ord,			# a reference to the ord-array
      $atr,			# a reference to the attribute-hash
      $output			# output stream
     )=@_;
  my $v;
  my $lastprinted=1;

  if ($node) {
    print $output "[";
    for (my $n=0; $n<=$#$ord; $n++) {
      $v=$node->getAttribute($ord->[$n]);
      $v=~s/[,\[\]=\\]/\\$&/go if (defined($v));
      if (index($atr->{$ord->[$n]}, " O")>=0) {
	print $output "," if $n;
	unless ($lastprinted && index($atr->{$ord->[$n]}," P")>=0) # N could match here too probably
	  { print $output $ord->[$n],"="; }
	$v='-' if ($v eq '' or not defined($v));
	print $output $v;
	$lastprinted=1;
      }
      elsif (defined($node->getAttribute($ord->[$n])) and $node->getAttribute($ord->[$n]) ne '') {
	print $output "," if $n;
	unless ($lastprinted && index($atr->{$ord->[$n]}," P")>=0) # N could match here too probably
	  { print $output $ord->[$n],"="; }
	print $output $v;
	$lastprinted=1;
      } else {
	$lastprinted=0;
      }
    }
    print $output "]";
  } else {
    print $output "<<NULL>>";
  }
}

sub PrintTree { 
  my ($curr,  # a reference to the root-node
      $rord,  # a reference to the ord-array
      $ratr,  # a reference to the attribute-hash
      $output)=@_;
  my $root=$curr;

  $output=\*STDOUT unless $output;
  while ($curr) {
    PrintNode($curr,$rord,$ratr,$output);
    if ($curr->{$firstson}) {
#      print $output "\\\n(";
      print $output "(";
      $curr = $curr->{$firstson};
      redo;
    }
    while ($curr && $curr != $root && !($curr->{$rbrother})) {
      print $output ")"; 
      $curr = $curr->{$parent};
    }
    croak "Error: NULL-node within the tree while printing\n" if !$curr;
    last if ($curr == $root || !$curr);
#    print $output ",\\\n";
    print $output ",";
    $curr = $curr->{$rbrother};
    redo;
  }
  print $output "\n";
}

sub CreateFSHeader {
  my ($defs, $attlist)=@_;
  my @ad;
  my @result;
  my $l;
  my $vals;
  foreach (@$attlist) {
    @ad=split ' ',$defs->{$_};
    while (@ad) {
      $l='@';
      if ($ad[0]=~/^L=(.*)/) {
	$vals=$1;
	shift @ad;
	$l.="L";
	$l.=shift @ad if ($ad[0]=~/^[A0-3]/);
	$l.=" $_|$vals\n";
      } else {
	$l.=shift @ad;
	$l.=shift @ad if ($ad[0]=~/^[A0-3]/);
	$l.=" $_\n";
      }
      push @result, $l;
    }
  }
  push @result,"\n";
  return @result;
}

## End of Fs-format specific functions

## DrawTree output backend

sub DrawTree ($@){
  my $top=shift;
  my $node=$top;
  my $older;
  my $l;
  my @attrs=@_;
  return unless $top;  
  print "(",$top->getAttribute("form"),")\n";
  $node=FirstSon($top);
  while ($node) {
    $l='';
    $older=Parent($node);
    while ($older and $older!=$top) { 
      if (RBrother($older)) {
	$l='| '.$l;
      } else {
	$l='  '.$l;
      }
      $older=Parent($older);
    }
    $l=" ".$l;
    print $l,"| \n";
    if (RBrother($node)) {
      $l.="+-[ ";
    } else {
      $l.="`-[ ";
    }
    print $l;
    print map $node->getAttribute($_)." ",@attrs ;
    print "]\n";
    $node=Next($node,$top);
  }
}

sub PrintFS ($$$$$) {
  my ($FS,$header,$trees,$atord,$attribs)=@_;
  my $t;

  $FS=\*STDOUT unless $FS;
  print $FS @$header if defined($header);
  foreach $t (@$trees) {
    PrintTree($t,$atord,$attribs,$FS);
  }
}

sub ImportBackends {
  my @backends=();
  foreach my $backend (@_) {
    if (eval { require $backend.".pm"; } ) {
      push @backends,$backend;
    }
  }
  return @backends;
}

############################################################
############################################################


####################
# OO API to FS Lib #
####################

############################################################
#
# FS Node
# =========
#
#

package FSNode;

=pod

=head1 FSNode


FSNode - Simple OO interface to tree structures of Fslib.pm

=head2 REFERENCE

=over 4

=cut

=pod

=item new

Create a new FSNode object. FSNode is basicly a hash reference, which
means that you may simply acces node's attributes as C<$node->getAttribute(attribute)>

=cut

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = {};
  bless $new, $class;
  $new->initialize();
  return $new;
}

=pod

=item initialize

This function inicializes FSNode. It is called by the constructor new.

=cut

sub initialize {
  my $self = shift;
  return undef unless ref($self);
  Fslib::NewNode($self);
  return $new;
}

sub DESTROY {
    my $self = shift;
    return undef unless ref($self);
    %{$self}=();
    return 1;
}

=pod

=item parent

Return node's parent node (C<undef> if none).

=cut

sub parent {
  my ($self) = @_;
  return ref($self) ? Fslib::Parent($self) : undef;
}

=pod

=item lbrother

Return node's left brother node (C<undef> if none).

=cut

sub lbrother {
  my $self = shift;
  return ref($self) ? Fslib::LBrother($self) : undef;
}

=pod

=item rbrother

Return node's right brother node (C<undef> if none).

=cut


sub rbrother {
  my $self = shift;
  return ref($self) ? Fslib::RBrother($self) : undef;
}

=pod

=item firstson

Return node's first dependent node (C<undef> if none).

=cut

sub firstson {
  my $self = shift;
  return ref($self) ? Fslib::FirstSon($self) : undef;
}

=pod

=item following (top?)

Return the next node of the subtree in the order given by structure
(C<undef> if none). If any descendant exists, the first one is
returned. Otherwise, right brother is returned, if any.  If the given
node has neither a descendant nor a right brother, the right brother
of the first (lowest) ancestor for which right brother exists, is
returned.

=cut

sub following {
  my ($self,$top) = @_;
  return ref($self) ? Fslib::Next($self,$top) : undef;
}

=pod

=item following_visible (fsformat,top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none). A node is considered visible if it has
no hidden ancestor. Requires FSFormat object as the first parameter.

=cut

sub following_visible {
  my ($self,$fsformat,$top) = @_;
  return undef unless ref($self);
  my $node=Fslib::Next($self,$top);
  return $node unless ref($fsformat);
  my $hiding;
  while ($node) {
    return $node unless ($hiding=$fsformat->isHidden($node));
#    $node=Fslib::Next($node,$top);
    $node=$hiding->following_right_or_up($top);
  }
}

=pod

=item following_right_or_up (top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none), but not descending.

=cut

sub following_right_or_up {
  my ($self,$top) = @_;
  return undef unless ref($self);

  my $node=$self;
  while ($node) {
    return 0 if ($node==$top or !$node->parent);
    return $node->rbrother if $node->rbrother;
    $node = $node->parent;
  }
}


=pod

=item previous (top?)

Return the previous node of the subtree in the order given by
structure (C<undef> if none). The way of searching described in
C<following> is used here in reversed order.

=cut

sub previous {
  my ($self,$top) = @_;
  return ref($self) ? Fslib::Prev($self,$top) : undef;
}

=pod

=item previous_visible (fsformat,top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none). A node is considered visible if it has
no hidden ancestor. Requires FSFormat object as the first parameter.

=cut

sub previous_visible {
  my ($self,$fsformat,$top) = @_;
  return undef unless ref($self);
  my $node=Fslib::Prev($self,$top);
  my $hiding;
  return $node unless ref($fsformat);
  while ($node) {
    return $node unless ($hiding=$fsformat->isHidden($node));
    $node=Fslib::Prev($hiding,$top);
  }
}


=pod

=item rightmost_descendant (node)

Return the rightmost lowest descendant of the node (or
the node itself if the node is a leaf).

=cut

sub rightmost_descendant {
  my ($self) = @_;
  return undef unless ref($self);
  $node=$self;
 DIGDOWN: while ($node->firstson) {
    $node = $node->firstson;
  LASTBROTHER: while ($node->rbrother) {
      $node = $node->rbrother;
      next LASTBROTHER;
    }
    next DIGDOWN;
  }
  return $node;
}


=pod

=item leftmost_descendant (node)

Return the leftmost lowest descendant of the node (or
the node itself if the node is a leaf).

=cut

sub leftmost_descendant {
  my ($self) = @_;
  return undef unless ref($self);
  $node=$self;
  $node=$node->firstson while ($node->firstson);
  return $node;
}

=pod

=item getAttribute (name)

Return value of the given attribute.

=cut

sub getAttribute {
  my ($self,$name) = @_;
  return $self->{$name};
}

=pod

=item setAttribute (name)

Set value of the given attribute.

=cut

sub setAttribute {
  my ($self,$name,$value) = @_;
  return $self->{$name}=$value;
}


=pod

=back

=cut

############################################################
#
# FS Format
# =========
#
#

package FSFormat;

=pod


=head1 FSFormat

FSFormat - Simple OO interface for FS instance of Fslib.pm

=head2 REFERENCE

=over 4

=cut

=pod

=item new (attributes_hash_ref?, ordered_names_list_ref?, unparsed_header?)

Create a new FS format instance object and C<initialize> it with the
optional values.

=cut

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = [];
  bless $new, $class;
  $new->initialize(@_);
  return $new;
}

=pod

=item initialize (attributes_hash_ref?, ordered_names_list_ref?, unparsed_header?)

Initialize a new FS format instance with given values. See L<"Fslib">
for more information about attribute hash, ordered names list and unparsed headers.

=cut

sub initialize {
  my $self = shift;
  return undef unless ref($self);

  $self->[0] = ref($_[0]) ? $_[0] : { }; # attribs  (hash)
  $self->[1] = ref($_[1]) ? $_[1] : [ ]; # atord    (sorted array)
  $self->[2] = ref($_[2]) ? $_[2] : [ ]; # unparsed (sorted array)
  return $self;
}

=pod

=item addNewAttribute (type, colour, name, list)

Adds a new attribute definition to the FSFormat. Type must be one of
the letters [KPOVNWLH], colour one of characters [A-Z0-9]. If the type
is L, the fourth parameter is a string containing a list of possible
values separated by |.

=cut

sub addNewAttribute {
  my ($self,$type,$color,$name,$list)=@_;
  $self->list->[$self->count()]=$name if (!defined($self->defs->{$name}));
  if ($list) {
    $self->defs->{$name}.=" $type=$list"; # so we create a list of defchars separated by spaces
  } else {                 # a value-list may follow the equation mark
    $self->defs->{$name}.=" $type";
  }
  if ($color) {
    $self->defs->{$name}.=" $color"; # we add a special defchar for color
  }
}

=pod

=item readFrom (source,output?)

Reads FS format instance definition from given source, optionally
echoing the unparsed input on the given output. The obligatory
argument C<source> must be either a GLOB or list reference.
Argument C<output> is optional and if given, it must be a GLOB reference.

=cut

sub readFrom {
  my ($self,$handle,$out) = @_;
  return undef unless ref($self);

  my %result;
  my $count=0;

  while ($_=Fslib::ReadTree($handle)) {
    s/\r$//o;
    if (ref($out)) {
      print $out $_;
    } else {
      push @{$self->unparsed}, $_;
    }
    if (/^\@([KPOVNWLH])([A-Z0-9])* ([-_A-Za-z0-9]+)(?:\|(.*))?/o) {
      $self->list->[$count++]=$3 if (!defined($self->defs->{$3}));
      if ($4) {
	$self->defs->{$3}.=" $1=$4"; # so we create a list of defchars separated by spaces
      } else {                 # a value-list may follow the equation mark
	$self->defs->{$3}.=" $1";
      }
      if ($2) {
	$self->defs->{$3}.=" $2"; # we add a special defchar for color
      }
      next;
    } elsif (/^\r*$/o) {
      last;
    } else {
      return 0;
    }
  }
  return 1;
}

=item writeTo (glob_ref)

Write FS declaration to a given file (file handle open for
reading must be passed as a GLOB reference).

=cut

sub writeTo {
  my ($self,$fileref) = @_;
  return unless ref($self);
  print $fileref Fslib::CreateFSHeader($self->defs,$self->list);
  return 1;
}


=pod

=item sentord, order, value, hide

Return names of special attributes declared in FS format as @W, @N,
@V, @H respectively.

=cut


%Specials = (sentord => 'W', order => 'N', value => 'V', hide => 'H');

sub AUTOLOAD {
  my ($self)=@_;
  return undef unless ref($self);
  my $sub = $AUTOLOAD;
  $sub =~ s/.*:://;
  if (exists($FSFormat::Specials{$sub})) {
    return $self->special($FSFormat::Specials{$sub});
  } else {
    return undef;
  }
}

sub DESTROY {
  my $self = shift;
  return undef unless ref($self);
  $self->[0]=undef;
  $self->[1]=undef;
  $self->[2]=undef;
  $self=undef;
}

=pod

=item isHidden (node)

Return the lowest ancestor-or-self of the given node marked by
C<'hide'> in the FS attribute declared as @H. Return undef, if no such
node exists.

=cut

sub isHidden {
  # Tests if given FSNode node is hidden or not
  # Returns the ancesor that hides it or undef
  my ($self,$node)=@_;
  return unless ref($self) and ref($node);
  my $hid=$self->hide;
  $node=$node->parent while (ref($node) and ($node->getAttribute($hid) ne 'hide'));
  return ($node ? $node : undef);
}

=pod

=item parseFSTree (line)

Parse a given line in FS format (using C<Fslib::GetTree2>) and return
the root of the resulting FS tree as an FSNode object.

=cut

sub parseFSTree {
  my ($self,$line)=@_;
  return undef unless ref($self);
  return Fslib::GetTree2($line,$self->list,$self->defs);
}

=pod

=item defs

Return a reference to the internally stored attribute hash.

=cut

sub defs {
  my $self = shift;
  return ref($self) ? $self->[0] : undef;
}

=pod

=item list

Return a reference to the internally stored attribute names list.

=cut

sub list {
  my $self = shift;
  return ref($self) ? $self->[1] : undef;
}

=pod

=item unparsed

Return a reference to the internally stored unparsed FS header. Note,
that this header must B<not> correspond to the defs and attributes if
any changes are made to the definitions or names at run-time by hand.

=cut

sub unparsed {
  my $self = shift;
  return ref($self) ? $self->[2] : undef;
}

=pod

=item attributes

Return a list of all attribute names (in the order given by FS
instance declaration).

=cut

sub attributes {
  my $self = shift;
  return ref($self) ? @{$self->list} : ();
}

=pod

=item atno (n)

Return the n'th attribute name (in the order given by FS
instance declaration).

=cut

sub atno {
  my ($self,$index) = @_;
  return ref($self) ? $self->list->[$index] : undef;
}

=pod

=item atno (attribute_name)

Return the definition string for the given attribute.

=cut

sub atdef {
  my ($self,$name) = @_;
  return ref($self) ? $self->defs->{$name} : undef;
}

=pod

=item count

Return the number of declared attributes.

=cut

sub count {
  my ($self) = @_;
  return ref($self) ? $#{$self->list}+1 : undef;
}

=pod

=item isList (attribute_name)

Return true if given attribute is assigned a list of all possible
values.

=cut

sub isList {
  my ($self,$attrib)=@_;
  return ref($self) ? Fslib::IsList($attrib,$self->defs) : undef;
}

=pod

=item listValues (attribute_name)

Return the list of all possible values for the given attribute.

=cut

sub listValues {
  my ($self,$attrib)=@_;
  return ref($self) ? Fslib::ListValues($attrib,$self->defs) : undef;
}

=pod

=item color (attribute_name)

Return one of C<Shadow>, C<Hilite> and C<XHilite> depending on the
color assigned to the given attribute in the FS format instance.

=cut

sub color {
  my ($self,$arg) = @_;
  return undef unless ref($self);

  if (index($self->defs->{$arg}," 1")>=0) {
    return "Shadow";
  } elsif (index($self->defs->{$arg}," 2")>=0) {
    return "Hilite";
  } elsif (index($self->defs->{$arg}," 3")>=0) {
    return "XHilite";
  } else {
    return "normal";
  }
}

=pod

=item special (letter)

Return name of a special attribute declared in FS definition with a
given letter. See also L<sentord> and similar.

=cut

sub special {
  my ($self,$defchar)=@_;
  return 
    ref($self) ? Fslib::ASpecial($self->defs,$defchar) : undef;
}

=pod

=item indexOf (attribute_name)

Return index of the given attribute (in the order given by FS
instance declaration).

=cut

sub indexOf {
  my ($self,$arg)=@_;
  return 
    ref($self) ? Fslib::Index($self->list,$arg) : undef;
}

=item exists (attribute_name)

Return index of the given attribute (in the order given by FS
instance declaration).

=cut

sub exists {
  my ($self,$arg)=@_;
  return 
    ref($self) ? defined($self->defs->{$arg}) : undef;
}

=item make_sentence (root_node,separator)

Return a string containing the content of value (special) attributes
of the nodes of the given tree, separted by separator string, sorted by
value of the (special) attribute sentord or (if sentord does not exist) by
(special) attribute order.

=cut

sub make_sentence {
  my ($self,$root,$separator)=@_;
  return undef unless ref($self);
  $separator=' ' unless defined($separator);
  my @nodes=();
  my $sentord = $self->sentord || $self->order;
  my $value = $self->value;
  my $node=$root;
  while ($node) {
    push @nodes,$node;
    $node=$node->following($root);
  }
  return join ($separator,
	       map { $_->getAttribute($value) }
	       sort { $a->getAttribute($sentord) <=> $b->getAttribute($sentord) } @nodes);
}

=pod

=back

=cut



############################################################
#
# FS File
# =========
#
#

package FSFile;

=pod

=head1 FSFile

FSFile - Simple OO interface for FS files.

=head2 SYNOPSIS

  use Fslib;

  open (F,"<trees.fs") ||
    die "Cannot open trees.fs: $!\n";
  my $fs = FSFile->newFSFile(\*F);
  close (F);

  die "File is empty or corrupted!\n" 
    if ($fs->lastTreeNo<0);

  foreach my $tree ($fs->trees) {

    ...    # do something on the trees

  }

  open (F,">trees_out.fs") 
    || die "Cannot open trees.fs: $!\n";
  $fs->writeTo(\*F);
  close (F);

=head2 REFERENCE

=over 4

=cut

=pod

=item new (name?,format?,FS?,hint_pattern?,attribs_pattern?,unparsed_tail?,trees?,save_status?,backend?)

Create a new FS file object and C<initialize> it with the optional values.

=cut

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = [];
  bless $new, $class;
  $new->initialize(@_);
  return $new;
}

sub DESTROY {
  my $self = shift;
  return undef unless ref($self);
  $self->[9]=undef;
  foreach ($self->trees) {
    Fslib::DeleteTree($_);
  }
  $self->[0]=undef;
  $self->[1]=undef;
  $self->[2]=undef;
  $self->[3]=undef;
  $self->[4]=undef;
  $self->[5]=undef;
  $self->[6]=undef;
  $self->[7]=undef;
  $self->[8]=undef;
  $self->[9]=undef;
  $self->[10]=undef;
}

=pod

=item initialize (name?,file_format?,FS?,hint_pattern?,attribs_patterns?,unparsed_tail?,trees?,save_status?,backend?)

Initialize a FS file object. Argument description:

=over 4

=item name (scalar)

File name 

=item file_format (scalar)

File format indentifier (user-defined string). TrEd, for example, uses
C<FS format>, C<gzipped FS format> and C<any non-specific format> strings as identifiers.

=item FS (FSFormat)

FSFormat object associated with the file

=item hint_pattern (scalar)

TrEd's hint pattern definition

=item attribs_patterns (list reference)

TrEd's display attributes pattern definition

=item unparsed_tail (list reference)

The rest of the file, which is not parsed by Fslib, i.e. Graph's embedded macros

=item trees (list reference)

List of FSNode objects representing root nodes of all trees in the FSFiled.

=item save_status (scalar)

File save status indicator, 0=file is saved, 1=file is not saved (TrEd uses this field).

=item backend (scalar)

IO Backend used to open/save the file.

=back

=cut

sub initialize {
  my $self = shift;
  # what will we do here ?

  $self->[0] = $_[0];  # file name   (scalar)
  $self->[1] = $_[1];  # file format (scalar)
  $self->[2] = ref($_[2]) ? $_[2] : FSFormat->new(); # FS format (FSFormat object)
  $self->[3] = $_[3];  # hint pattern
  $self->[4] = ref($_[4]) eq 'ARRAY' ? $_[4] : []; # list of attribute patterns
  $self->[5] = ref($_[5]) eq 'ARRAY' ? $_[5] : []; # unparsed rest of a file
  $self->[6] = ref($_[6]) eq 'ARRAY' ? $_[6] : []; # trees
  $self->[7] = $_[7] ? $_[7] : 0; # notsaved
  $self->[8] = undef; # storage for current tree number
  $self->[9] = undef; # storage fro current node
  $self->[10] = $_[8] ? $_[8] : 'FSBackend'; # backend;

  return ref($self) ? $self : undef;
}

=pod

=item readFile (filename, [backends...])

Read FS declaration and trees from a given file.  The first argument
must be a file-name.  If a list of backend modules is specified,
C<test> methods of the modules are invoked as long as one of them
succeeds. This module is than used as a backend for opening and
parsing the file.
Sets noSaved to zero.

=cut

sub readFile {
  my ($self,$filename) = (shift,shift);
  return unless ref($self);

  @_=qw/FSBackend/ unless @_;
  foreach my $backend (@_) {
    print STDERR "Trying backend $backend: " if $Fslib::Debug;
    if ($ret =
	eval {
	  return $backend->can('test')
	      && $backend->can('read') 
	      && $backend->can('open_backend')
	      && &{"${backend}::test"}($filename);
	}) {
      $self->changeBackend($backend);
      $self->changeFilename($filename);
      print STDERR "success\n" if $Fslib::Debug;
      eval {
	my $fh;
	$fh = &{"${backend}::open_backend"}($filename,"r");
	&{"${backend}::read"}($fh,$self);
	&{"${backend}::close_backend"}($fh);
      };
      print STDERR "$@\n" if $@;
      $self->notSaved(0);
      last;
    }
    print STDERR "fail\n" if $Fslib::Debug;
    print STDERR "$@\n" if $@;
  }
  return $ret;
}

=pod

=item readFrom (glob_ref, [backends...])

Read FS declaration and trees from a given file (file handle open for
reading must be passed as a GLOB reference).  
This function is limited to use FSBackend only.
Sets noSaved to zero.

=cut

sub readFrom {
  my ($self,$fileref) = (shift,shift);
  return unless ref($self);

  my $ret=FSBackend::read($fileref,$self);
  $self->notSaved(0);
  return $ret;
}

=pod

=item writeFile (filename)

Write FS declaration, trees and unparsed tail to a given file. Sets
noSaved to zero.

=cut

sub writeFile {
  my ($self,$filename) = @_;
  return unless ref($self);

  $filename = $self->filename unless (defined($filename) and $filename ne "");

  my $backend=$self->backend || 'FSBackend';
  print STDERR "Writing to $filename using backend $backend\n" if $Fslib::Debug;
  my $ret=eval {
#    require $backend;
    my $fh;
    return( $backend->can('write')
       and $backend->can('open_backend')
       and ($fh=&{"${backend}::open_backend"}($filename,"w"))
       and &{"${backend}::write"}($fh,$self)
       and &{"${backend}::close_backend"}($fh));
  };
  if ($@) {
    print STDERR "Error: $@\n";
    return 0;
  }
  $self->notSaved(0) if $ret;
  return $ret;
}


=item writeTo (glob_ref)

Write FS declaration, trees and unparsed tail to a given file (file handle open for
reading must be passed as a GLOB reference). Sets noSaved to zero.

=cut

sub writeTo {
  my ($self,$fileref) = @_;
  return unless ref($self);

  my $backend=$self->backend || 'FSBackend';
  print STDERR "Writing using backend $backend\n" if $Fslib::Debug;
  my $ret=eval {
#    require $backend;
    return $backend->can('write')  && &{"${backend}::write"}($fileref,$self);
  };
  print STDERR "$@\n" if $@;
  return $ret;
}

=pod

=item newFSFile (filename,[backends...])

Create a new FSFile object based on the content of a given file.
If a list of backend
modules is specified, C<read> methods of the modules are invoked
as long as one of them succeeds to open and parse the file.

=cut

sub newFSFile {
  my ($self,$filename) = (shift,shift);

  my $new=$self->new();
  $new->readFile($filename,@_);
  return $new;
}

=pod

=item filename

Return the FS file's file name.

=cut

sub filename {
  my $self = shift;
  return ref($self) ? $self->[0] : undef;
}

=pod

=item changeFilename (new_filename)

Change the FS file's file name.

=cut

sub changeFilename {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[0]=$val;
}

=pod

=item fileFormat

Return file format indentifier (user-defined string). TrEd, for
example, uses C<FS format>, C<gzipped FS format> and C<any
non-specific format> strings as identifiers.

=cut

sub fileFormat {
  my $self = shift;
  return ref($self) ? $self->[1] : undef;
}

=pod

=item changeFileFormat

Change file format indentifier.

=cut

sub changeFileFormat {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[1]=$val;
}

=pod

=item backend

Return IO backend module name. The default backend is FSBackend, used
to save files in the FS format.

=cut

sub backend {
  my $self = shift;
  return ref($self) ? $self->[10] : undef;
}

=pod

=item changeBackend

Change file backend.

=cut

sub changeBackend {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[10]=$val;
}

=pod

=item FS

Return a reference to the associated FSFormat object.

=cut

sub FS {
  my $self = shift;
  return ref($self) ? $self->[2] : undef;
}

=pod

=item changeFS

Associate FS file with a new FSFormat object.

=cut

sub changeFS {
  my ($self,$val) = @_;
  return undef unless ref($self);
  $self->[2]=$val;
  return $self->[2];
}

=pod

=item hint

Return the Tred's hint pattern declared in the FSFile.

=cut


sub hint {
  my $self = shift;
  return ref($self) ? $self->[3] : undef;
}

=pod

=item changeHint

Change the Tred's hint pattern associated with this FSFile.

=cut

sub changeHint {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[3]=$val;
}

=pod

=item pattern_count

Return the number of display attribute patterns associated with this FSFile.

=cut

sub pattern_count {
  my $self = shift;
  return ref($self) ? scalar(@{ $self->[4] }) : undef;
}

=item pattern (n)

Return n'th the display pattern associated with this FSFile.

=cut

sub pattern {
  my ($self,$index) = @_;
  return ref($self) ? $self->[4]->[$index] : undef;
}

=item patterns

Return a list of display attribute patterns associated with this FSFile.

=cut

sub patterns {
  my $self = shift;
  return ref($self) ? @{$self->[4]} : undef;
}

=pod

=item changePatterns

Change the list of display attribute patterns associated with this FSFile.

=cut

sub changePatterns {
  my $self = shift;
  return unless ref($self);
  return @{$self->[4]}=@_;
}

=pod

=item tail

Return the unparsed tail of the FS file (i.e. Graph's embedded macros).

=cut

sub tail {
  my $self = shift;
  return ref($self) ? @{$self->[5]} : undef;
}

=pod

=item tail

Modify the unparsed tail of the FS file (i.e. Graph's embedded macros).

=cut

sub changeTail {
  my $self = shift;
  return unless ref($self);
  return @{$self->[5]}=@_;
}

=pod

=item trees

Return a list of all trees (i.e. their roots represented by FSNode objects).

=cut

## Two methods to work with trees (for convenience)
sub trees {
  my $self = shift;
  return ref($self) ? @{$self->treeList} : undef;
}

=pod

=item trees

Assign a new list of trees.

=cut

sub changeTrees {
  my $self = shift;
  return unless ref($self);
  return @{$self->treeList}=@_;
}

=pod

=item treeList

Return a reference to the internal array of all trees (e.g. their
roots represented by FSNode objects).

=cut

# returns a reference!!!
sub treeList {
  my $self = shift;
  return ref($self) ? $self->[6] : undef;
}

=pod

=item tree (n)

Return a reference to the tree number n.

=cut

# returns a reference!!!
sub tree {
  my ($self,$n) = @_;
  return ref($self) ? $self->[6]->[$n] : undef;
}


=pod

=item changeTreeList (new_trees)

Associate a new reference to a list of trees with the this FSFile.
The referenced array must be a list of FSNode objects representing all
the new trees.

=cut

sub changeTreeList {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[6]=$val;
}

=pod

=item lastTreeNo

Return number of associated trees minus one.

=cut

sub lastTreeNo {
  my $self = shift;
  return ref($self) ? $#{$self->treeList} : undef;
}

=pod

=item notSaved (value?)

Return/assign file saving status (this is completely user-driven).

=cut

sub notSaved {
  my ($self,$val) = @_;

  return undef unless ref($self);
  return $self->[7]=$val if (defined $val);
  return $self->[7];
}

=item currentTreeNo (value?)

Return/assign index of current tree (this is completely user-driven).

=cut

sub currentTreeNo {
  my ($self,$val) = @_;

  return undef unless ref($self);
  return $self->[8]=$val if (defined $val);
  return $self->[8];
}

=item currentNode (value?)

Return/assign current node (this is completely user-driven).

=cut

sub currentNode {
  my ($self,$val) = @_;

  return undef unless ref($self);
  return $self->[9]=$val if (defined $val);
  return $self->[9];
}

=pod

=item nodes (tree_no, prev_current, include_hidden)

Get list of nodes for given tree. Returns two value list ($nodes,$current),
where $nodes is a reference to a list of nodes for the tree and
current is either root of the tree or the same node as prev_current if
prev_current belongs to the tree. The list is sorted according to
the FS->order attribute and inclusion of hidden nodes depends on the
boolean value of include_hidden.

=cut

sub nodes {
# prepare value line and node list with deleted/saved hidden
# and ordered by real Ord

  my ($fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  my $nodes=[];
  return $nodes unless ref($fsfile);

  my @unsorted=();
  $tree_no=0 if ($tree_no<0);
  $tree_no=$fsfile->lastTreeNo() if ($tree_no>$fsfile->lastTreeNo());

  my $root=$fsfile->treeList->[$tree_no];
  my $node=$root;
  my $current=$root;

  while($node)
  {
    push @unsorted, $node;
    $current=$node if ($prevcurrent eq $node);
    $node=$show_hidden ? $node->following() : $node->following_visible($fsfile->FS);
  }

  my $ord=$fsfile->FS->order();
  @{$nodes}=
    sort { $a->getAttribute($ord) <=> $b->getAttribute($ord) }
      @unsorted;

  # just for sure
  undef @unsorted;
  # this is actually a workaround for TR, where two different nodes
  # may have the same Ord
  return ($nodes,$current);
}

=pod

=item value_line (tree_no)

Return a sentence string for the given tree. Sentence string is a
string of chained value attributes (FS->value) ordered according to
the FS->sentord or FS->order if FS->sentord attribute is not defined.

=cut

sub value_line {
  my ($fsfile,$tree_no,$no_numbers)=@_;
  return unless $fsfile;

  my $node=$fsfile->treeList->[$tree_no];
  my @sent=();

  my $attr=$fsfile->FS->sentord();
  $attr=$fsfile->FS->order() unless (defined($attr));
  while ($node) {
    push @sent,$node unless ($node->getAttribute($val) eq '???' or
			     $node->getAttribute($attr)>=999); # this is TR specific stuff
    $node=$node->following();
  }
  @sent = sort { $a->getAttribute($attr) <=> $b->getAttribute($attr) } @sent;
  $attr=$fsfile->FS->value();
  my $line = $no_numbers ? "" : ($tree_no+1)."/".($fsfile->lastTreeNo+1).": ";
  $line.=join(" ", map { $_->getAttribute($attr) } @sent);
  undef @sent;
  return $line;
}

=pod

=item new_tree (position)

Create a new tree at given position and return pointer to its root.

=cut

sub new_tree {
  my ($self,$pos)=@_;

  my $nr=FSNode->new(); # creating new root
  splice(@{$self->treeList}, $pos, 0, $nr);
  return $nr;

}

=item delete_tree (position)

Delete the tree at given position and return pointer to its root.

=cut

sub delete_tree {
  my ($self,$pos)=@_;
  my ($root)=splice(@{$self->treeList}, $pos, 1);
  return $root;
}

=item destroy_tree (position)

Delete the tree at given position and return pointer to its root.

=cut

sub destroy_tree {
  my ($self,$pos)=@_;
  my $root=$self->delete_tree($pos);
  return 0 unless $root;
  Fslib::DeleteTree($root);
  return 1;
}



=pod

=back

=cut

############################################################
#
# ZBackend
# =========
#
#

package ZBackend;

use Exporter;
@ISA=(Exporter);
$VERSION = "0.1";
@EXPORT = qw(&open_backend &close_backend);
@EXPORT_OK = qw($gzip $zcat);

use IO;

=pod

=head1 ZBackend

ZBackend - generic IO backend for reading/writing gz-compressed files
using either IO::Zlib module or external zcat utility.  Only
open_backend and close_backend functions are implemented as this
backend is meant to be base-class for all other backends which wish to
open gz-compressed files.

=head2 REFERENCE

=over 4

=cut

=pod

=item $ZBackend::zcat

This variable may be used to set-up the zcat external utility. This
utility must be able to compress standard input to standard output. If
empty, this backend tries to open the given file using the IO::Zlib
module.

=item $ZBackend::gzip

This variable may be used to set-up the gzip external utility. This
utility must be able to compress standard input to standard output.
If empty, this backend tries to open the given file using the IO::Zlib
module.

=cut


$ZBackend::zcat = "/bin/zcat" unless $ZBackend::zcat;
$ZBackend::gzip = "/usr/bin/gzip" unless $ZBackend::gzip;

=pod

=item open_backend (filename,mode)

Open given file for reading or writing (depending on mode which may be
one of "r" or "w"); Return the corresponding object based on
File::Handle class. Only files the filename of which ends with `.gz'
are considered to be gz-commpressed. All other files are opened using
IO::File.

=cut

sub open_backend {
  my ($filename, $mode)=@_;
  my $fh = undef;
  if ($filename) {
    if ($filename=~/.gz$/) {
      if (-x $ZBackend::zcat) {
	if ($mode =~/[w\>]/) {
	  eval {
	    $fh = new IO::Pipe();
	    $fh && $fh->writer("$ZBackend::gzip > \"$filename\"");
	  } || return undef;
	} else {
	  eval {
	    $fh = new IO::Pipe();
	    $fh && $fh->reader("$ZBackend::zcat < \"$filename\"");
	  } || return undef;
	}
	return $fh;
      } else {
	eval {
	  require IO::Zlib;
	  $fh = new IO::Zlib();
	} && $fh || return undef;
	$fh->open($filename,$mode."b") || return undef;
      }
    } else {
      eval { $fh = new IO::File(); } || return undef;
      $fh->open($filename,$mode) || return undef;
    }
  }
  return $fh;
}

=pod

=item close_backend (filehandle)

Close given filehandle opened by previous call to C<open_backend>

=cut

sub close_backend {
  my ($fh)=@_;
  return $fh && $fh->close();
}

=pod

=back

=cut


############################################################
#
# FSBackend
# =========
#
#

package FSBackend;

@ISA=qw(ZBackend);
import ZBackend;

=pod

=head1 FSBackend

FSBackend - IO backend for reading/writing FS files using FSFile class.

=head2 REFERENCE

=over 4

=cut

=pod

=item test (filehandle | filename)

Test if given filehandle or filename is in FSFormat. If the argument
is a file-handle the filehandle is supposed to be open by previous
call to C<open_backend>. In this case, the calling application may
need to close the handle and reopen it in order to seek the beginning
of the file after the test has read few characters or lines from it.

=cut

sub test {
  my ($f)=@_;
  if (ref($f)) {
    return $f->getline()=~/^@/;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}

=pod

=item read (handle_ref,fsfile)

Read FS declaration and trees from a given file in FS format (file
handle open for reading must be passed as a GLOB reference).
Return 1 on success 0 on fail.

=cut

sub read {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

  $fsfile->changeFS( FSFormat->new() );
  $fsfile->FS->readFrom($fileref) || return 0;

  my ($root,$l,@rest);
  $fsfile->changeTrees();
  while ($l=Fslib::ReadTree($fileref)) {
    if ($l=~/^\[/) {
      $root=$fsfile->FS->parseFSTree($l);
      push @{$fsfile->treeList}, $root if $root;
    } else { push @rest, $l; }
  }
  $fsfile->changeTail(@rest);

  #parse Rest
  $fsfile->changePatterns( map { /^\/\/Tred:Custom-Attribute:(.*\S)\s+$/ ? $1 : () } $fsfile->tail);
  unless ($fsfile->patterns) {
    my ($peep)=$fsfile->tail;
    $fsfile->changePatterns( map { "\$\{".$fsfile->FS->atno($_)."\}" } 
		    ($peep=~/[,\(]([0-9]+)/g));
  }
  $fsfile->changeHint(join "\n",
		    map { /^\/\/Tred:Balloon-Pattern:(.*\S)\s+$/ ? $1 : () } $fsfile->tail);
  return 1;
}

=pod

=item write (handle_ref,$fsfile)

Write FS declaration, trees and unparsed tail to a given file to a
given file in FS format (file handle open for reading must be passed
as a GLOB reference).

=cut

sub write {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

#  print $fileref @{$fsfile->FS->unparsed};
  $fsfile->FS->writeTo($fileref);
  Fslib::PrintFS($fileref,undef,
		 $fsfile->treeList,
		 $fsfile->FS->list,
		 $fsfile->FS->defs);

  ## Tredish custom attributes:
  $fsfile->changeTail(
		    (grep { $_!~/\/\/Tred:(?:Custom-Attribute|Balloon-Pattern):/ } $fsfile->tail),
		    (map {"//Tred:Custom-Attribute:$_\n"} $fsfile->patterns),
		    (map {"//Tred:Balloon-Pattern:$_\n"}
		     split /\n/,$fsfile->hint)
		   );
  print $fileref $fsfile->tail;
  return 1;
}

=pod

=back

=cut

1;


############################################################
############################################################
############################################################

__END__

=head1 Fslib

Fslib.pm - Simple low-level API for treebank files in .fs format.  See
L<"FSFile">, L<"FSFormat"> and L<"FSNode"> for an object-oriented
abstraction over this module.

=head2 SYNOPSIS

  use Fslib;
  use locale;
  use POSIX qw(locale_h);

  setlocale(LC_ALL,"cs_CZ");
  setlocale(LANG,"czech");

  %attribs = ();
  @atord = ();
  @trees = ();

  # read the header
  %attribs=ReadAttribs(\*STDIN,\@atord,2,\@header);

  # read the raw tree
  while ($_=ReadTree(\*F)) {
    if (/^\[/) {
      $root=GetTree($_,\@atord,\%attribs);  # parse the tree
      push(@trees, $root) if $root;	    # store the structure
    } else { push(@rest, $_); }		    # keep the rest of the file
  }

  # do some changes 
  ...

  # save the tree
  print @header;      # print header
  PrintFS(\*STDOUT,
	  \@header,
	  \@trees,
	  \@atord,
	  \%attribs); # print the trees
  print @rest;	      # print the rest of the file

  # destroy trees and free memory
  foreach (@trees) { DeleteTree($_); }
  undef @header;


=head2 DESCRIPTION

This package has the ambition to be a simple and usable perl API for manipulating the
treebank files in the .fs format (which was designed by Michal Kren
and is the only format supported by his Windows application GRAPH.EXE
used to interractively edit treebank analytical or tectogramatical
trees). See also Dan Zeman's review of this format in czech at

http://ufal.mff.cuni.cz/local/doc/trees/format_fs.html

The Fslib package defines functions for parsing .fs files, extracting
headers, reading trees and representing them in memory using simple
hash structures, manipulate the values of node attributes (either
"directly" or via B<Get> and B<Set> functions) and even modify the structure
of the trees (via B<Cut>, B<Paste> and B<DeleteTree> functions or "directly").


=head2 USAGE

There are many ways to benefit from this package, I note here the most
typical one.
Assume, you want to read the .fs file from the STDIN (or whatever),
then make some changes either to the structure of the trees or to the
values of the attributes (or both) and write it again. (Maybe you
only want to examine the structure, find something of your interest
and write some output about it -- it's up to you). For this purpose
you may use the code similar to the one mentioned in SYNOPSIS of this
document. Let's see how to manage the appropriate tasks (also watch the
example in SYNOPSIS while reading):

=head2 PARSING FS FILES

First you should read the header of the .fs file using
B<ReadAttribs()> function, passing it as parameters the reference to
the input file descriptor (like \*STDIN), reference to an array, that
will contain the list of attribute names positionaly ordered and
storing its return value to a hash. The returned hash will then have the
attribute names as keys and their type character definitions as
values. (see ReadAttribs description for detail).

Note, that no Read... function from this package performs any seeking,
only reads the file on. So, it's expected, that you are at the
beggining of the file when you call ReadAttribs, and that you have
read the header before you parse the trees.

Anyway, having the attribute definitions read you probbably want to
continue and parse the trees. This is done in two steps. First you
call the B<ReadTree()> function (passing it only a reference to the
input file descriptor) to obtain (on return) a scalar (string),
containing a linear representation of the next tree on input in the
.fs format (except for line-breaks). You should store it. Now you
should test, that it was really a tree that was read and not something
else, which may be some environmetal or macro definition for GRAPH.EXE
which is allowed by .fs format. This may be done simply by matching
the result of B<ReadTree()> with the pattern /^\[/ because trees and
only trees begin with the square bracket `['. If it is so, you may
continue by parsing the tree with B<GetTree()>. This function parses
the linear .fs representation of the tree and re-represents it as a
structure of references to perl hashes (this I call a tree node
structure - TNS). For more about TNS's see chapter called MODIFYING
AND EXAMINING TREES and the REFERENCE item Tree Node Structure. On
return of B<GetTree()> you get a reference to the tree's TNS. You may
store it (by pushing it to an array, i.e.) and continue by reading
next tree, or do any other job on it.

When you are finished with reading the trees and also had made all the
changes you wanted, you may want to write the trees back. This is done
using the B<PrintFS()> function (see its description bellow). To
create a corect .fs file, you probably should write back the header
before writing the trees, and also write that messy environmetal stuff
after the trees are written.

=head2 MODIFYING OR EXAMINING TREES

TNS represents both a node and the whole subtree having root in this
node. So whole trees are represented by their roots. TNS is actualy
just a reference to a hash. The keys of the hashes may be either some
of attribute names or some `special' keys, serving to hold the tree
structure. Suppose $node is a TNS and `lemma' is an attribute defined
in the appropriate .fs file. Than $node->getAttribute("lemma") is value of the
attribute for the node represented by TNS $node. You may obtain this
value also as B<Get>($node,"lemma"). From the $node TNS you may
obtain also the node's parent, sons and brothers (both left and
right). This may be done in several equivalent ways. TNS's of a nodes
relatives are stored under values of those `special' keys mentioned
above. These keys are chosen in such a way that they should not colide
with attribute names and are stored in the following scalar variables:

=over 4

=item *

Fslib::$parent

=item *

Fslib::$firstson

=item *

Fslib::$lbrother

=item *

Fslib::$rbrother

=back

(You may change these variables if you want, but note, that modifying
them once the trees are read may lead to problems:-)

So, to obtain $node's parent's TNS you may use either
$node->{$parent} or B<Get>($node,$parent) or even special
function B<Parent>($node). The same holds for the first son, left and right
brothers while you may also prefere to use the B<FirstSon()>, B<LBrother()> and
B<RBrother()> functions respectively. If the node's relative (say
first son) does not exist, the value obtained in either of the mentioned
ways I<is> still I<defined but zero>.

To create a new node, you usually create a new hash and call
B<NewNode()> passing it a reference to the new hash as a parameter.

To modify a node's value for a certain attribute (say 'lemma'), you
symply type C<$node->setAttribute("lemma","bar")> (supposed you want the value to
become 'bar') or use the B<Set()> function like
B<Set>C<($node,"bar");>.

To modify the tree's structure, you may use B<Cut> and B<Paste>
function as described bellow or to delete a whole subtree you may use
the B<DeleteTree> function. This also frees memory used by the TNS.
If you want to delete a subtree of $node, but still keep its root, you may use
a construct like:

  DeleteTree(FirstSon($node)) while(FirstSon($node));

Note, that Cut function also deletes a subree from the tree but
keeps the TNS in memory and returns a reference to it.

There is also a global variable Fslib::$FSTestListValidity, which may
be set to 1 to make Fslib::ParseNode check if value assigned to a list
attribute is one of the possible values declared in FS file
header. Because this may slow the process of parsing significantly
(especially when there is a lot of list attributes) the default value
is 0 (no check is performed).

=head2 REFERENCE

=over 4

=item ReadAttribs (FILE,$aref[,$DO_PRINT[,OUTFILE]])

 Params

   FILE      - file handle reference, like \*STDIN
   $aref     - reference to array
   $DO_PRINT - if 1, read input is also copied to
               $OUTFILE (which must be a filehandle reference, like
               \*STDOUT).
       	       if 0, read input is also stored to the @$OUTFILE
	       array (in this case $OUTFILE is a reference to an array).
   $OUTFILE - output file handle or array reference , \*STDIN if ommited

 Returns:
   A hash, having fs-attribute names as keys
   and strings containing characters identifying
   types as corresponding values
   The characters may be some of following
   (as given by the .fs format):

       K	Key attribute
       P	Positional attribute
       O	Obligatory attribute
       L	List attribute
       N	Numerical attribute
       V	Value atribute (for displaying in GRAPH.EXE)

   The $aref should be on input a reference to
   an empty array. On return the array contains
   the key values of the returned hash (the attributes)
   orderd as thay are defined in FS file, i.e. in
   their positional order.


=item ReadTree (FILE)

 Params:

   FILE - file handle, like STDIN

 Returns:

   A string containing the next tree read form FILE
   in its source form (only with concatenated lines).


=item GetTree ($tree,$aref,$href)

 Params:

   $tree - the source form of a tree with concatenated lines
   $aref - a reference to an array of attributes in their
           positional order (see ReadAttributes)
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   A reference to a tree hash-structure described below.


=item PrintNode ($node,$aref,$href)

 Params:

   $node - a reference to a tree hash-structure
   $aref - a reference to an array of attributes in their
           positional order (see ReadAttributes)
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values
  Returns:

   Unknown.

 Descrption:

   Prints the node structure referenced by $node
   to STDOUT in a source format


=item PrintTree ($node,$aref,$href)

 Params:

   $node - a reference to a tree hash-structure
   $aref - a reference to an array of attributes in their
           positional order (see ReadAttributes)
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   Unknown.

 Descrption:

   Prints the tree having its root-node referenced by $node
   to STDOUT in a source format


=item Parent($node), FirstSon($node), LBrother($node), RBrother($node)

 Params:

   $node - a reference to a tree hash-structure

 Returns:

   Parent, first son, left brother or right brother resp. of
   the node referenced by $node


=item Next($node,[$top]), Prev($node,[$top])

 Params:

   $node - a reference to a tree hash-structure
   $top  - a reference to a tree hash-structure, containing
           the node referenced by $node

 Return:

   Reference to the next or previous node of $node on
   the backtracking way along the tree having its root in $top.
   The $top parameter is NOT obligatory and may be omitted.
   Return zero, if $top of root of the tree reached.


=item Cut($node)

 Params:

   $node - a reference to a node

  Description:

   Cuts (disconnets) $node from its parent and brothers

  Returns:

   $node


=item Paste($node,$newparent,$href)

 Params:

   $node      - a reference to a (cutted or new) node
   $newparent - a reference to the new parent node
   $href      - a reference to a hash, containing attributes as keys
                and corresponding type strigs as values
 Description:

   connetcs $node to $newparent and links it
   with its new brothers, placing it to position
   corresponding to its numerical-argument value
   obtained via call to an Ord function.

 Returns $node

=item Special($node,$href,$defchar)

 Exported with EXPORT_OK

 Params:

   $node    - a reference to a tree hash-structure
   $href    - a reference to a hash, containing attributes as keys
              and corresponding type strigs as values
   $defchar - a type string pattern

 Returns:

   Value of the first $node attribute of type matching $defchar pattern

=item ASpecial($href,$defchar)

 Exported with EXPORT_OK

 Params:

   $href    - a reference to a hash, containing attributes as keys
              and corresponding type strigs as values
   $defchar - a type string pattern

 Returns:

   Name of the first attribute of type matching $defchar pattern

=item AOrd, ASentOrd, AValue, AHide ($href)

 Exported wiht EXPORT_OK

 Params:

   $href    - a reference to a hash, containing attributes as keys
              and corresponding type strigs as values

 Description:

 Are all like Ord, SentOrd, Value, Hide only except for
 they do not get $node as parameter and return attribute
 name rather than its value.


=item Ord($node,$href)

 Exported with EXPORT_OK

 Params:

   $node - a reference to a tree hash-structure
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   $node's ord (value of attribute declared by type character N)
   Same as Special($node,$href,'N')

=item Value($node,$href)

 Exported with EXPORT_OK

 Params:

   $node - a reference to a tree hash-structure
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   $node's value attribut (value of attribute declared by type character V)
   Same as Special($node,$href,'V')

=item SentOrd($node,$href)

 Exported with EXPORT_OK

 Params:

   $node - a reference to a tree hash-structure
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   $node's sentence ord (value of attribute declared by type character W)
   Same as Special($node,$href,'W')

=item Hide($node,$href)

 Exported with EXPORT_OK

 Params:

   $node - a reference to a tree hash-structure
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   "hide" if $node is hidden (actually the value of attribute declared
   by type character H)
   Same as Special($node,$href,'H')


=item IsList($attr,$href)

 Params:

   $attr - an atribute name
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   1 if attribut $attr is declared as a list (L) in hash of attribute defs
   (referenced in) $href
   0 otherwise

=item ListValues($attr,$href)

 Params:

   $attr - an atribute name
   $href - a reference to a hash, containing attributes as keys
           and corresponding type strigs as values

 Returns:

   a list of allowed values for attribute $attr as defined in
   the hash of attribyte defs $href

=item Set($node,$attribute,$value)

 Params:

   $node      - a reference to a node
   $attribute - attribute
   $value     - value to fill $node's $attribute with

 Description:

   Does the same as $node->setAttribute($attribute,$value)


=item Get($node,$attribute)

 Params:

   $node      - a reference to a node
   $attribute - attribute

 Return:

   Returns $node->getAttribute($attribute)

=item DrawTree($node,@attrs)

 Params:

   $node      - a reference to a node
   $attrs     - list of attributes to display

 Description:

   Draws a tree on standard output using character graphics. (May be
   particulary useful on systems with no GUI - for real graphical
   representation of FS trees look for Michal Kren's GRAPH.EXE or
   Perl/Tk based program "tred" by Petr Pajas.

=item ImportBackends(@backends)

 Params:

   @backends  - a list of backend names

 Description:

   Demand to load the given backends and return a list of
   backends for which the demand was fulfilled. These
   backends may then be freely used in FSFile IO calls.

=item THE TREE NODE-STRUCTURE (TNS)

 Description:

 TNS is a normal hash, whose keys are names of attribute
 and whose values are strings, values of the correspoding
 attributes (as they are given in the FS format source).

 In addtion, few other keys and values are added to each node:

   "Parent"    which is a reference to the parent node (or zero if N/A)
   $firstson  a reference to the first son's node (or zero)
   "RBrother"  a reference to the first right brother (or zero)
   $lbrother  a reference to the first left brother (or zero)

 You may initialize a new node by calling NewNode($node),
 where $node is a reference to some (existing and rather empty) hash.

=back

=head1 SEE ALSO

http://ufal.mff.cuni.cz/local/doc/trees/format_fs.html

=cut
