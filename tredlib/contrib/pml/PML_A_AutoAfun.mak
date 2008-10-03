# -*- cperl -*-
## author: Petr Pajas, Zdenek Zabokrtsky
## Time-stamp: <2008-10-02 00:20:04 pajas>

use lib FindMacroDir("auto_afun/AutoAfun");

{
my %LcAfuns = map { lc($_)=>$_ }
  qw(Pred Pnom AuxV Sb Obj Atr Adv AtrAdv AdvAtr Coord AtrObj
     ObjAtr AtrAtr AuxT AuxR AuxP Apos ExD AuxC Atv AtvV AuxO AuxZ
     AuxY AuxG AuxK AuxX AuxS);
my $AutoAfunAtr='afun';

sub afun_info {
  my ($node)=@_;
  return ref($node) ?
    ($node->attr('m/lemma'),$node->attr('m/tag')): #,scalar($node->children())) :
    (undef, undef); #, undef);
}

sub real_parent {
  my ($node)=@_;
  my $last;
  do  {
    $node=$node->parent();
    $last=$node if $node;
  } while ($node and $node->attr('m/tag')!~/^[NVADPC]/);
  return $last;
}

sub normalize_afun {
  my ($afun)=@_;
  if ($afun eq "???" or $afun eq "") {return "Atr"}
  else {  return $LcAfuns{$afun} };
}

sub assign_afun_auto {
  my $node=$_[1] || $this;

  require Assign_afun;
  if (!$node->parent) {
    $node->{$AutoAfunAtr}='AuxS';
    return;
  }
  my ($afun_old,$num1,$num2)=
    Assign_afun::afun( afun_info(real_parent($node)),
		       afun_info($node->parent),
		       afun_info($node),
		     );

  my ($lc_afun, $is_member, $is_parenthesis_root) = $afun_old=~/(^[^_]+)(_co|_ap)?(_pa)?$/i;
  my $afun = $LcAfuns{ lc($lc_afun) };
  if ($afun eq q{}) {
    my ($lemma,$tag) = afun_info($node);
    if ($node->parent->{afun} eq 'AuxS') {
      if ($tag=~/^V/) { $afun = 'Pred' } 
      elsif ($lemma =~ /^[.?!]$/ and !$node->following) {
	$afun = 'AuxK';
      } elsif ($tag =~ /^J\^/ or $lemma=~/,/) {
	$afun = 'Coord';
      } else {
	$afun = 'ExD';
      }
    } elsif ($lemma eq ',') {
      $afun = 'AuxX';
    }
  }
  $node->set_attr($AutoAfunAtr,$afun);
  $node->set_attr('is_member',$is_member ? 1 : 0);
  $node->set_attr('is_parenthesis_root',$is_parenthesis_root ? 1 : 0);
}

sub assign_all_afun_auto {
  my $class=$_[0];
  my $node=$root;
  while ($node) {
    assign_afun_auto($class,$node) if ($node->{afun} eq '' or $node->{afun} eq '???' or $node->{afun} eq '');
    $node=$node->following();
  }
}

sub assign_afun_auto_tree {
  my ($class,$top)=@_;
  $top||=$root;
  my $node=$top;
  while ($node) {
    assign_afun_auto($class,$node);
    $node=$node->following($top);
  }
}
}
1;
