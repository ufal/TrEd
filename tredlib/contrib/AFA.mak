# -*- cperl -*-
## author: Petr Pajas, Zdenek Zabokrtsky
## Time-stamp: <2003-06-27 15:33:18 pajas>

unshift @INC,"$main::libDir/contrib" unless (grep($_ eq "$main::libDir/contrib", @INC));
require AFA;

my %advfunc;
my %ntime;
my %nplace;
my %npprep = (
	      'z2' => 'DIR1',
	      'do2' => 'DIR3',
	      'od2' => 'DIR1',
	      'na6' => 'LOC',
	      'na4' => 'DIR3',
	      'pøed7' => 'LOC',
	      'pøed4' => 'DIR3',
	      'za7' => 'LOC',
	      'v6' => 'LOC',
	      'za4' => 'DIR3',
	      'za7' => 'LOC'
	     );
my %ntprep = (
	      'z2' => 'TSIN',
	      'do2' => 'TTILL',
	      'od2' => 'TSIN',
	      'na4' => 'TFHL',
	      'pøed7' => 'TWHEN',
	      'v6' => 'TWHEN',
	      'za4' => 'THL',
	      'po4' => 'TFHL'
	     );

do {
  local *F;
  open F,"<$libDir/contrib/adverb2functor.lex" || warn "cannot open $libDir/contrib/adverb2functor.lex: $!";
  my ($key,$func,$num,$of);
  while (<F>) {
    s/[\r\n]//g;
    ($lemma,$func,$num,$of)=split "\t",$_;
    $advfunc{$lemma}=[ $func,$num,$of ];
  }
  close F;
  open F,"<$libDir/contrib/noun_time.list" || warn "cannot open $libDir/contrib/noun_time.list: $!";
  while (<F>) {
    /(\S+)/;
    $_=$1;
    $ntime{$_}=1;
  }
  close F;
  open F,"<$libDir/contrib/noun_place.list" || warn "cannot open $libDir/contrib/noun_place.list: $!";
  while (<F>) {
    /(\S+)/;
    $_=$1;
    $nplace{$_}=1;
  }
  close F;
};

sub after_edit_attr_hook {
  my ($node,$attr,$result)=@_;
  if ($attr eq 'func' and $result) {
    $node->{funcaux}='';
  }
}

sub after_edit_node_hook {
  my ($node,$result)=@_;
  if ($result) {
    $node->{funcaux}='';
  }
}

#bind clear_funcaux to Space menu Clear functor color
sub clear_funcaux {
  my $node=$_[1] || $this;
  $node->{funcaux}='';
}

#bind assign_func_auto to F9 menu Auto-assign functor to node
sub assign_func_auto {
  my $node=$_[1] || $this;
  foreach (qw/funcauto funcprec funcaux/) {
    $node->{$_}='';
  }
  $node->{funcaux}='black';
  if ($node->{afun}=~/Coord/) {
    if ($node->{lemma} eq 'a-1') {
      $node->{func}='CONJ';
    } elsif ($node->{lemma} eq 'v¹ak') {
      $node->{func}='PREC';
    } elsif ($node->{lemma} eq 'ale') {
      $node->{func}='ADVS';
    } elsif ($node->{lemma} eq ',') {
      $node->{func}='CONJ';
    } elsif ($node->{lemma} eq 'nebo') {
      $node->{func}='DISJ';
    } else {
      $node->{func}='CONJ';
    }
    $node->{funcauto}=$node->{func};
    $node->{funcaux}="#{custom5}";
  } elsif ($node->{afun}=~/Apos/) {
    $node->{func}='APPS';
    $node->{funcaux}="#{custom5}";
    $node->{funcauto}=$node->{func};
  }
  return if IsHidden($node)
    || $node eq $root ||
    $node->{afun}=~/Coord|Apos/i || index($node->{ord},'.')>=0;
  my $p=$node->parent;
  $p=$p->parent while ($p and $p->{afun}=~/Coord|Apos/i);
  my $na=$node->{afun};
  my $pa=$p->{afun};
  $na=~s/_.*//g;
  $pa=~s/_.*//g;
  my $prec;
  $node->{funcauto}="???";
  
  if ($node->{tag}=~/^D/ and exists($advfunc{$node->{trlemma}})) {
    my $af=$advfunc{$node->{trlemma}};
    $node->{funcauto}=$af->[0];
    $prec=$af->[2]."/".($af->[2]-$af->[1]);
    $node->{reserve2}='ADVFUNC';
  } elsif ($node->{tag}=~m/^N...(.)/ and 
	   exists($ntime{$node->{trlemma}}) and
	   $af=$ntprep{$node->{fw}.$1}) {
    $node->{funcauto}=$af;
    $prec="10/2";
    $node->{reserve2}='ADVTIME';
  } elsif ($node->{tag}=~m/^N...(.)/ and 
	   exists($nplace{$node->{trlemma}}) and
	   $af=$npprep{$node->{fw}.$1}) {
    $node->{funcauto}=$af;
    $node->{reserve2}='ADVPLACE';
    $prec="10/2";
  } else {
    ($node->{funcauto},$prec)=AFA::AutoFunctor($p->{tag},$node->{tag},$pa,$na,$node->{fw});
    if ($node->{funcauto} eq '') {
      $node->{funcauto} = '???';
    }
  }
  $node->{funcprec}=$prec;
  $prec=~m!([0-9.]+)/([0-9.]+)!;
  eval { $prec=100*($1-$2)/$1; };
  $prec=~s/(\.[0-9][0-9]).*$/\1/;
  $node->{funcaux} = $prec>90 ? "#{custom4}" : ( $prec<50 ? "#{custom6}" : "#{custom5}");
  $node->{func}=$node->{funcauto} if ($node->{funcauto});
}

sub assign_func_auto_node {
  my $class=$_[0];
  my $node=$_[1] || $this;
  assign_func_auto($class,$node) if ($node->{func} eq '???' or
				     $node->{func} eq '');
}

#bind assign_all_func_auto to F10 menu Auto-assign functors to tree
sub assign_all_func_auto {
  my $class=$_[0];
  my $node=$root;
  while ($node) {
    assign_func_auto($class,$node) if ($node->{func} eq '???' or
                                       $node->{func} eq '');
    $node=NextVisibleNode($node);
  }
}
