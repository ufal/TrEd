package Fslib;

# See the bottom of this file for the POD documentation. Search for the
# string '=head'.

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# Several Perl Routines to handle files in treebank FS format
# See complete help in POD format at the end of this file

use Exporter;
@ISA=(Exporter);
$VERSION = "0.91";
@EXPORT = qw(&ReadAttribs &ReadTree &GetTree &GetTree2 &PrintNode &PrintTree &PrintFS &NewNode 
	     &Parent &LBrother &RBrother &FirstSon &Next &Prev &DeleteTree &DeleteLeaf
	     &Cut &Paste &Set &Get &DrawTree &IsList &ListValues);
@EXPORT_OK = qw($FSTestListValidity &Index &ParseNode &Ord &Value &Hide &SentOrd &Special &AOrd &AValue &AHide &ASentOrd &ASpecial &SetParent &SetLBrother &SetRBrother &SetFirstSon);

use Carp;
use vars qw(
	    $VERSION @EXPORT @EXPORT_OK
	    $field
	    );


# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# Several Perl Routines to parse treebank files in FS format
#

$field='(?:\\\\[\\]\\,]|[^\\,\\]])*';
$parent="_P_";
$firstson="_S_";
$lbrother="_L_";
$rbrother="_R_";
$FSTestListValidity=0;


sub NewNode ($) {
  my $node = shift;
  
  $ {$node}{$firstson}=0;
  $ {$node}{$lbrother}=0;
  $ {$node}{$rbrother}=0;
  $ {$node}{$parent}=0;
  return $node;
}

sub Set ($$$) {
  my ($node,$atribute,$value)=(shift,shift,shift);
  $$node{$atribute}=$value;
}

sub Get ($$) {
  my ($node,$atribute)=(shift,shift);
  return $$node{$atribute};
}

sub Parent ($) {
  my $node = shift;
  return $ {$node}{$parent};
}

sub SetParent ($$) {
  my ($node,$p) = @_;
  $ {$node}{$parent}=$p if ($node);
}

sub LBrother ($) {
  my $node = shift;
  return $ {$node}{$lbrother};
}

sub SetLBrother ($$) {
  my ($node,$p) = @_;
  $ {$node}{$lbrother}=$p if ($node);
}


sub RBrother ($) {
  my $node = shift;
  return $ {$node}{$rbrother};
}

sub SetRBrother ($$) {
  my ($node,$p) = @_;
  $ {$node}{$rbrother}=$p if ($node);
}

sub FirstSon ($) {
  my $node = shift;
  return $ {$node}{$firstson};
}

sub SetFirstSon ($$) {
  my ($node,$p) = @_;
  $ {$node}{$firstson}=$p if ($node);
}

sub Next {
  my ($node,$top) = (shift, shift);
  $top=0 if !$top;

  if (FirstSon($node)) {
    return FirstSon($node);
  }
  while ($node) {
    return 0 if ($node==$top or !Parent($node));
    return RBrother($node) if (RBrother($node));
    $node = Parent($node);
  }
  return 0;
}

sub Prev {
  my ($node,$top) = (shift, shift);
  $top=0 if !$top;
  
  if (LBrother($node)) {
    $node = LBrother($node);
  DIGDOWN: while (FirstSon($node)) {
      $node = FirstSon($node);
    LASTBROTHER: while (RBrother($node)) {
    	$node = RBrother($node);
        next LASTBROTHER;
      }
      next DIGDOWN;
    }
    return $node;
  }
  return 0 if ($node == $top or !Parent($node));
  return Parent($node);
}

sub IsList ($$) {
  my ($attrib, $href)=@_;
  return (index($$href{$attrib}," L")>=0);
}

sub ListValues ($$) {
  my ($attrib, $href)=@_;

# pokus o zrychleni
    my $I,$b,$e;
    $b=index($$href{$attrib}," L=");
    if ($b>=0) {
      $e=index($$href{$attrib}," ",$b+1);
      if ($e>=0) {
        return split /\|/,substr($$href{$attrib},$b+3,$e-$b-3);
      } else {
        return split /\|/,substr($$href{$attrib},$b+3);
      }
    } else { return (); }

#  if ($$href{$attrib}=~/ L=([^ ]+)/) { # only lists may have preset values
#    return split /\|/,$1;
#  } else { return (); }
}

sub Special ($$$) {
  my ($node,$href,$defchar)=@_;

  if ($node and $href) {
    foreach (keys(%$href)) {
      return $$node{$_} if (index($$href{$_}," $defchar")>=0);
    }
  }
  return undef;
}

sub ASpecial ($$) {
  my ($href,$defchar)=@_;

  if ($href) {
    foreach (keys(%$href)) {
      return $_ if (index($$href{$_}," $defchar")>=0);
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
  
  if ($$node{$parent} and $node==$ {$$node{$parent}}{$firstson}) {
    $ {$$node{$parent}}{$firstson}=$$node{$rbrother};    
  }
  $ {$$node{$lbrother}}{$rbrother}=$$node{$rbrother} if ($$node{$lbrother}); 
  $ {$$node{$rbrother}}{$lbrother}=$$node{$lbrother} if ($$node{$rbrother}); 
  
  $$node{$parent}=$$node{$lbrother}=$$node{$rbrother}=0;
  return $node;
}

sub Paste ($$$) {
  my ($node,$p,$href)=(shift,shift,shift);
  my $ordnum = Ord($node,$href);

  $b=$$p{$firstson};
  if ($b and $ordnum>Ord($b,$href)) {
    $b=$$b{$rbrother} while ($$b{$rbrother} and $ordnum>Ord($$b{$rbrother},$href));
    $$node{$rbrother}=$$b{$rbrother};
    $ {$$b{$rbrother}}{$lbrother}=$node if ($$b{$rbrother});
    $$b{$rbrother}=$node;
    $$node{$lbrother}=$b;
  } else {
    $$node{$rbrother}=$b;
    $$p{$firstson}=$node;
    $$node{$lbrother}=0;
    $$b{$lbrother}=$node if ($b);
  }
  $$node{$parent}=$p;
}

sub DeleteTree ($) {
#  print "Deleting tree\n";
  $top=$node=shift;
  while ($node) {
    if ($node!=$top
	and !$$node{$firstson}
	and !$$node{$lbrother}
	and !$$node{$rbrother}) {
      $next=$$node{$parent};
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
  if (!$$node{$firstson}) {
    $ {$$node{$rbrother}}{$lbrother}=$$node{$lbrother} if ($$node{$rbrother});

    if ($$node{$lbrother}) {
      $ {$$node{$lbrother}}{$rbrother}=$$node{$rbrother};
    } else {
      $ {$$node{$parent}}{$firstson}=$$node{$rbrother} if $$node{$parent};
    }
#    print " leaf ",$$node{"form"},"\n";
    undef %$node;
    undef $node;
    return 1;
  }
#  print " nothing\n";
  return 0;
}


sub Index ($$) {
  my ($ar,$i) = @_;
  my $result=undef;
  for (my $n=0;$n<=$#$ar;$n++) {
    $result=$n, last if ($ar->[$n] eq $i);
  }
  return $result;
}

sub ReadAttribs  {
  my ($handle,$order,$DO_PRINT,$out) = @_;
  my $outfile = ($out ? $out : \*STDOUT);

  my %result;
  my $count=0;

  while ($_=ReadTree($handle)) {

    s/\r$//o;

    print $outfile $_ if $DO_PRINT==1;
    push @$out, $_ if $DO_PRINT==2; 
    if (/^\@([KPOVNWLH])([A-Z0-9])* ([A-Za-z0-9]+)(?:\|(.*))?/o) {
      $ {$order}[$count++]=$3 if (!defined($result{$3}));
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
  my %node;
  my $pos = 1;
  my $a=0;
  my $v=0;
  my $tmp;
  my @lv;

  NewNode(\%node);
  if ($ {$lr}=~/\G\[/gsco) {
    while ($ {$lr} !~ /\G\]/gsco) {
      $n++,next if ($ {$lr}=~/\G\,/gsco);
      if ($ {$lr}=~/\G([A-Za-z0-9]+)=($field)/gsco) {
	$a=$1;
	$v=$2;
	$tmp=Index($ord,$a);
	$n = $tmp if (defined($tmp));
      } elsif ($ {$lr}=~/\G($field)/gsco) {
	$v=$1;
        $n++ while ( $n<=$#$ord and $attr->{$ord->[$n]}!~/ [PNW]/);
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
      $node{$a}=$v;
    }
  } else { croak $ {$lr}," not node!\n"; }
  return { %node };
}

sub ParseNode2 ($$$) {
  my ($lr,$ord,$attr) = @_;
  my $n = 0;
  my %node;
  my @ats=();
  my $pos = 1;
  my $a=0;
  my $v=0;
  my $tmp;
  my @lv;
  my $nd;
  my $i;
  my $w;

  NewNode(\%node);
  if ($ {$lr}=~/^\[/) {
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
      $node{$a}=$v;
    }
  } else { croak $ {$lr}," not node!\n"; }
  return { %node };
}


sub ReadLine {
  my $handle=shift;

  if (ref($handle) eq 'GLOB') {
    $_=<$handle>;
  } elsif (ref($handle) eq 'ARRAY') {
    $_=shift @$handle;
  } else { $_=''; return $_; }
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
	$ {$curr}{$firstson} = ParseNode2(\$l,$ord,$atr);
	$ { $ {$curr}{ $firstson }}{$parent}=$curr; 
	$curr=$ {$curr}{$firstson};
	next;
      }
      if ( $c eq ')' ) { # Return to parent (go up)
	croak "Error paring tree" if ($curr eq $root);
	$curr=$ {$curr}{$parent};
	next;
      }
      if ( $c eq ',' ) { # Create right brother (go right);
	$ {$curr}{$rbrother} = ParseNode2(\$l,$ord,$atr);
	$ {$ {$curr}{$rbrother}}{$lbrother}=$curr;
	$ {$ {$curr}{$rbrother}}{$parent}=$ {$curr}{$parent}; 
	$curr=$ {$curr}{$rbrother};
	next;
      }
      croak "Unexpected token... `$c'!\n";
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
	$ {$curr}{$firstson} = ParseNode(\$l,$ord,$atr);
	$ { $ {$curr}{ $firstson }}{$parent}=$curr; 
	$curr=$ {$curr}{$firstson};
	next;
      }
      if ( $l=~/\G\)/gsco ) { # Return to parent (go up)
	croak "Error paring tree" if ($curr eq $root);
	$curr=$ {$curr}{$parent};
	next;
      }
      if ( $l=~/\G,/gsco ) { # Create right brother (go right);
	$ {$curr}{$rbrother} = ParseNode(\$l,$ord,$atr);
	$ {$ {$curr}{$rbrother}}{$lbrother}=$curr;
	$ {$ {$curr}{$rbrother}}{$parent}=$ {$curr}{$parent}; 
	$curr=$ {$curr}{$rbrother};
	next;
      }
      $l=~/\G(.)/gsco;
      croak "Unexpected token `$1'!\n";
    }
    croak "Error: Closing parens do not lead to root of the tree." 
	if ($curr != $root);
  }
#    else { croak "** $l\nTree does not begin with `['!\n"; }
#  reset;
  return $root;
}

sub PrintNode($$$$) { # 1st scalar is a reference to the root-node
                     # 2nd scalar is a reference to the ord-array
                     # 3rd scalar is a reference to the attribute-hash
  my ($node,$ord,$atr,$output)=@_;
  my $v;
  my $lastprinted=1;

  if ($node) {
    print $output "[";
    for (my $n=0; $n<=$#$ord; $n++) {
      $v=$ {$node}{$ord->[$n]};
      $v=~s/[,\[\]=\\]/\\$&/go if (defined($v));      
      if (index($atr->{$ord->[$n]}, " O")>=0) {
	print $output "," if $n;
	unless ($lastprinted && index($atr->{$ord->[$n]}," P")>=0) # N could match here too probably
	  { print $output $ord->[$n],"="; }
	$v='-' if ($v eq '' or not defined($v));
	print $output $v;
	$lastprinted=1;
      }
      elsif (defined($node->{$ord->[$n]}) and $node->{$ord->[$n]} ne '') {
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
    if ($ {$curr}{$firstson}) {
#      print $output "\\\n(";
      print $output "(";
      $curr = $ {$curr}{$firstson};
      redo;
    }
    while ($curr && $curr != $root && !($ {$curr}{$rbrother})) {
      print $output ")"; 
      $curr = $ {$curr}{$parent};
    }
    croak "Error: NULL-node within the tree while printing\n" if !$curr;
    last if ($curr == $root || !$curr);
#    print $output ",\\\n";
    print $output ",";
    $curr = $ {$curr}{$rbrother};
    redo;
  }
  print $output "\n";
}

sub DrawTree ($@){
  my $top=shift;
  my $node=$top;
  my $older;
  my $l;
  my @attrs=@_;
  return unless $top;  
  print "(",$$top{"form"},")\n";
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
    print map $$node{$_}." ",@attrs ;
    print "]\n";
    $node=Next($node,$top);
  }   
}

sub PrintFS ($$$$$) {
  my ($FS,$header,$trees,$atord,$attribs)=@_;
  my $t;

  print FO @$header;
  foreach $t (@$trees) {
    PrintTree($t,$atord,$attribs,$FS);
  }
}

1;

__END__

=head1 NAME

Fslib.pm - Simple API for treebank files in .fs format 

=head1 SYNOPSIS

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


=head1 DESCRIPTION

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


=head1 USAGE

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
in the appropriate .fs file. Than $$node{"lemma"} is value of the
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
$$node{$parent} or B<Get>($node,$parent) or even special
function B<Parent>($node). The same holds for the first son, left and right
brothers while you may also prefere to use the B<FirstSon()>, B<LBrother()> and
B<RBrother()> functions respectively. If the node's relative (say
first son) does not exist, the value obtained in either of the mentioned
ways I<is> still I<defined but zero>.

To create a new node, you usually create a new hash and call
B<NewNode()> passing it a reference to the new hash as a parameter.

To modify a node's value for a certain attribute (say 'lemma'), you
symply type C<$$node{"lemma"}="bar"> (supposed you want the value to
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

=head1 REFERENCE

=over 4

=item ReadAttribs (FILE,$aref[,$DO_PRINT[,OUTFILE]])

 Params:

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

==item AOrd, ASentOrd, AValue, AHide ($href)

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

   Does the same as $$node{$attribute}=$value


=item Get($node,$attribute)

 Params: 

   $node      - a reference to a node
   $attribute - attribute

 Return:

   Returns $$node{$attribute}

=item DrawTree($node,@attrs)

 Params: 

   $node      - a reference to a node
   $attrs     - list of attributes to display

 Description:

   Draws a tree on standard output using character graphics. (May be
   particulary useful on systems with no GUI - for real graphical
   representation of FS trees look for Michal Kren's GRAPH.EXE or
   Perl/Tk based program "tred" by Petr Pajas.

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

http://ufal.mff.cuni.cz/local/doc/tools/fs2ps/index.html

http://ufal.mff.cuni.cz/local/doc/tools/2804/index.html

http://ufal.mff.cuni.cz/local/trees/format_fs.html

=cut
