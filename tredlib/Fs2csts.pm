package Fs2csts;

use Fslib;

%TRt = (
	gender_ANIM => 'M',
	gender_INAN => 'I',
	gender_FEM => 'F',
	gender_NEUT => 'N',
	gender_NA => '-',
	number_SG => 'S',
	number_PL => 'P',
	number_NA => '-',
	degcmp_POS => '1',
	degcmp_COMP => '2',
	degcmp_SUP => '3',
	degcmp_NA => '-',
	tense_SIM => 'S',
	tense_POST => 'P',
	tense_ANT => 'A',
	tense_NA => '-',
	aspect_PROC => 'P',
	aspect_CPL => 'C',
	aspect_RES => 'R',
	aspect_NA => '-',
	iterativeness_IT1 => '1',
	iterativeness_IT0 => '0',
	iterativeness_NA => '-',
	verbmod_IND => 'I',
	verbmod_IMP => 'M',
	verbmod_CDN => 'C',
	verbmod_NA => '-',
	deontmod_DECL => 'D',
	deontmod_DEB => 'B',
	deontmod_HRT => 'H',
	deontmod_VOL => 'V',
	deontmod_POSS => 'S',
	deontmod_PERM => 'P',
	deontmod_FAC => 'F',
	deontmod_NA => '-',
	sentmod_ENUNC => '.',
	sentmod_EXCL => '!',
	sentmod_DESID => 'D',
	sentmod_IMPER => 'M',
	sentmod_INTER => '?',
	sentmod_NA => '-',
       );

sub make_TRt {
  my ($node,$machine)=@_;
  my $result="";
  foreach (qw(gender degcmp number tense aspect iterativeness verbmod deontmod sentmod)) {
    if (exists($TRt{$_."_".$node->{$_}})) {
       $result.=$TRt{$_."_".$node->{$_}};
     } else {
       $result.="X";
     }
  }
}

sub make_gap {
  my ($gap)=@_;
  $gap=~s/(.)\</$1\n\</g;
  if ($gap ne "") {
    $gap.="\n";
  }
  return $gap;
}

sub print_split_attr {
  my ($fileref,$value,$tag)=@_;
  return if $value eq "";
  foreach (split(/\|/,$value)) {
    print $fileref "<$tag>",$_;
  }
}

sub print_split_attr_with_num_attr {
  my ($fileref,$node,$attr,$num,$tag,$at)=@_;
  return if $node->{$attr} eq "";

  my @t=split(/\|/,$node->{$attr});
  my @tw=split(/\|/,$node->{$num});
  for (my $i=0;$i<=$#t;$i++) {
    if ($tw[$i]=~/(\d+)/) {
      print $fileref "<$tag $at=$1>",$t[$i];
    } else {
      print $fileref "<$tag>",$t[$i];
    }
  }
}

sub write {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

  my @nodes;
  my $node;

  # print the file information from the root node
  my $root = $fsfile->treeList->[0];
  if ($root) {
    my $lang = $root->{cstslang} ? $root->{cstslang} : "cs";
    print $fileref "<csts lang=$lang>\n";
    if ($root->{cstssource} ne "" or $root->{markup} ne "") {
      print $fileref "<h>\n";
      print $fileref "<source>\n";
      print $fileref $root->{cstssource};
      print $fileref "</source>\n";
      print $fileref "</h>\n";
      print $fileref "<markup>\n";
      print $fileref $root->{cstsmarkup};
      print $fileref "</markup>\n";
    }
  }
  my $treeNo=0;
  foreach $root ($fsfile->trees) {
    $treeNo++;
    @nodes=();
    $node=$root->following;
    while ($node) {
      push @nodes,$node;
      $node=$node->following;
    }
    my $sentord=$fsfile->FS->sentord;
    @nodes = sort { $a->{$sentord} <=> $b->{$sentord} } @nodes;
    # print sentence information from root node
    if (ref($root)) {
      if ($treeNo==1 or $root->{doc}.$root->{docid} ne "") {
	print $fileref "</doc>\n" if ($treeNo>1);
	print $fileref "<doc file=\"",$root->{doc},"\" id=\"",
	  int($root->{docid}),"\">\n";
	print $fileref "<a>\n";
	if ($root->{docmarkup} ne "") {
	  print $fileref "<markup>\n";
	  print $fileref $root->{docmarkup};
	  print $fileref "</markup>\n";
	}
	my ($genre,$id,$authname)=("mix",$root->{docid},"y");
	my ($mod,$txtype,$med,$temp,$opus)=
	  $root->{doc}=~m!([^/]*)/([^/]*)/([^/]*)/([^/]*)/([^/]*)!;
	print $fileref "<mod>";
	print $fileref $root->{docmarkup} =~ /\<mod\>([^\<*]*)/ ?
	  $1 : $mod,"\n";
	print $fileref "<txtype>";
	print $fileref $root->{docmarkup} =~ /\<txtype\>([^\<*]*)/ ?
			$1 : $txtype,"\n";
	print $fileref "<genre>";
	print $fileref $root->{docmarkup} =~ /\<genre\>([^\<*]*)/ ?
			$1 : $genre,"\n";
	print $fileref "<verse>$1\n" if $root->{docmarkup} =~ /\<verse\>([^\<*]*)/;
	print $fileref "<med>";
	print $fileref $root->{docmarkup} =~ /\<med\>([^\<*]*)/ ?
			$1 : $med,"\n";
	print $fileref "<authsex>$1\n" if $root->{docmarkup} =~ /\<authsex\>([^\<*]*)/;
	print $fileref "<lang>$1\n" if $root->{docmarkup} =~ /\<lang\>([^\<*]*)/;
	print $fileref "<transsex>$1\n" if $root->{docmarkup} =~ /\<transsex\>([^\<*]*)/;
	print $fileref "<srclang>$1\n" if $root->{docmarkup} =~ /\<srclang\>([^\<*]*)/;
	print $fileref "<temp>";
	print $fileref $root->{docmarkup} =~ /\<temp\>([^\<*]*)/ ?
			$1 : $temp,"\n";
	print $fileref "<firsted>$1\n" if $root->{docmarkup} =~ /\<firsted\>([^\<*]*)/;
	print $fileref "<authname>";
	print $fileref $root->{docmarkup} =~ /\<authname\>([^\<*]*)/ ?
			$1 : $authname,"\n";
	print $fileref "<transname>$1\n" if $root->{docmarkup} =~ /\<transname\>([^\<*]*)/;
	print $fileref "<opus>";
	print $fileref $root->{docmarkup} =~ /\<opus\>([^\<*]*)/ ?
			$1 : $opus,"\n";
	print $fileref "<id>";
	print $fileref $root->{docmarkup} =~ /\<id\>([^\<*]*)/ ?
			$1 : $id,"\n";
	print $fileref "</a>\n";
      }
      if ($treeNo==1 or $root->{chap}) {
	print $fileref "</c>\n" if ($treeNo>1);
	print $fileref "<c>\n";
      }
      if ($root->{para} or $treeNo==1) {
	my $n =	$root->{para}=~/\d+/ ? $& : 0;
	print $fileref "<p n=$n>\n";
      }
#      print $fileref make_gap($root->{gappre});

      if ($root->{form}=~/alt/) {
	print $fileref "<salt id=\"$root->{ID1}\">\n";
      } else {
	print $fileref "<s id=\"$root->{ID1}\">\n";
      }
      print $fileref make_gap($root->{gappost});
    }
    # print node information
    foreach $node (@nodes) {
      print $fileref make_gap($node->{gappre});
      if ($node->{origf} ne $node->{form} or $node->{origfkind} and $node->{origfkind} ne 'same') {
	my @w=split(/\|/,$node->{origf});
	my @k=split(/\|/,$node->{origfkind});
	my $count=$#w > $#k ? $#w : $#k;
	for (my $i=0; $i<=$count; $i++ ) {
	  if ($k[$i] and $k[$i] ne 'same' ) {
	    print $fileref "<w $k[$i]>";
	  } else {
	    print $fileref "<w>";
	  }
	  print $fileref $w[$i],"\n";
	}
      }

      # choosing between f d and fadd
      if (index($node->{ord},'.')>=$[) {
	my $del=$node->{del}=~/^(?:elid|elex|expn)/ ? " ".$node->{del} : "";
	print $fileref "<fadd$del>";
      } else {
	if ($node->{form}=~/^([][!"'()+,-.\/:;=\?`]|&(?:amp|ast|bsol|circ|commat|dollar|gt|lcub|lowbar|lsqb|lt|macron|num|percnt|rcub|rsqb|verbar);)$/) {
	  my $case = $node->{formtype} =~m/^(?:std|gen)/ ? " ".$node->{formtype} : "";
	  print $fileref "<d$case>",$node->{form};
	} else {
	  my $case = $node->{formtype} =~m/^(?:cap|upper|mixed|gen|num|num.gen|gen.phrase|cap.gen.phrase|abbr|cap.abbr|cap.gen|upper.abbr|upper.gen|mixed.abbr)/ ? " ".$node->{formtype} : "";
	  print $fileref "<f$case>",$node->{form};
	}
	print_split_attr($fileref,$node->{punct},'P');
	print $fileref "<Ct>",$node->{alltags} if ($node->{alltags} ne "");
	print_split_attr($fileref,$node->{lemma},'l');
	print $fileref "<R>",$node->{root} if ($node->{root} ne "");
	print $fileref "<E>",$node->{ending} if ($node->{root} ne ""); # this is not a mistake

	print_split_attr_with_num_attr($fileref,$node,'tag','wt','t','w');

	foreach (grep(/lemmaMM_/,$fsfile->FS->attributes)) {
	  /lemmaMM_(.*)$/;
	  my $suf=$1;
	  print_split_attr($fileref,$node->{$_},"MMl src=\"$suf\"");
	  print $fileref "<R>",$node->{"rootMM_$suf"} if ($node->{"rootMM_$suf"} ne "");
	  # this is not a mistake
	  print $fileref "<E>",$node->{"endingMM_$suf"} if ($node->{"rootMM_$suf"} ne "");
	  print_split_attr($fileref,$node->{"tagMM_$suf"},"MMt src=\"$suf\"");
	}
	foreach (grep(/lemmaMD_/,$fsfile->FS->attributes)) {
	  /lemmaMD_(.*)$/;
	  my $suf=$1;
	  print_split_attr_with_num_attr($fileref,$node,"lemmaMD_$suf","wMDl_$suf","MDl src=\"$suf\"",'w');
	  print $fileref "<R>",$node->{"rootMD_$suf"} if ($node->{"rootMD_$suf"} ne "");
	  # this is not a mistake
	  print $fileref "<E>",$node->{"endingMD_$suf"} if ($node->{"rootMD_$suf"} ne "");
	  print_split_attr_with_num_attr($fileref,$node,"tagMD_$suf","wMDt_$suf","MDt src=\"$suf\"",'w');
	}
	print_split_attr($fileref,$node->{afun},'A');
	foreach (grep(/MDA_/,$fsfile->FS->attributes)) {
	  /afunMD_(.*)$/;
	  print_split_attr_with_num_attr($fileref,$node,"afunMD_$1","wMDA_$1","MDA src=\"$1\"",'w');
	}
      }
      my $quot="";
      if ($node->{dsp}=~/(DSPP|DSPI|DSP)/) {
	$quot=" ".lc($1);
      }
      if ($node->{quot} eq 'QUOT') {
	$quot.= $quot ? ".quot" : " quot";
      }
      if (exists($node->{trlemma}) and $node->{trlemma} ne "") {
	print $fileref "<TRl$quot>",$node->{trlemma};
	print $fileref "<T>",$node->{func} if ($node->{func} ne "");
	print $fileref "<grm>",$node->{gram} if ($node->{gram} !~ /^(?:---|\?\?\?)?$/);
	my $TRt=make_TRt($node,0);
	print $fileref "<TRt>",$TRt if ($TRt !~/^X*$/);
	print $fileref "<tfa>",$node->{tfa}  if ($node->{tfa} !~ /^(?:---|\?\?\?)?$/);
	print $fileref "<tfr>",$node->{dord} if ($node->{govTR} ne "");
	print $fileref "<fw>",$node->{fw} if ($node->{fw} ne "");
	print $fileref "<phr>",$node->{phraseme} if ($node->{phraseme} ne "");
	if ($fsfile->FS->order eq 'dord') {
	  print $fileref "<TRg>",int($node->parent->{ord});
	} else {
	  print $fileref "<TRg>",$node->{govTR} if ($node->{govTR} ne "");
	}
	print $fileref "<corl>",$node->{corl} if ($node->{corl} !~ /^(?:---|\?\?\?)?$/);
	print $fileref "<corT>",$node->{corT} if ($node->{corT} !~ /^(?:---|\?\?\?)?$/);
	print $fileref "<corr>",$node->{corr} if ($node->{corr} !~ /^(?:---|\?\?\?)?$/);
	print $fileref "<cors>",$node->{cors} if ($node->{cors} !~ /^(?:---|\?\?\?)?$/);
      }
      foreach (grep(/trlemmaM_/,$fsfile->FS->attributes)) {
	/trlemmaM_(.*)$/;
	print $fileref "<MTRl src=\"$1\">",$node->{$_};
	# actually, all the set of MTRl subelements should be
	# treated the same
      }
      print $fileref "<r>",$node->{ord};
      if ($fsfile->FS->order eq 'dord') {
	print $fileref "<g>",$node->{ordorig};
      } else {
	print $fileref "<g>",int($node->parent->{ord});
      }
      unless (index($node->{ord},'.')>=$[) {
	#not allowed in DTD for some reason
	foreach (grep(/MDg_/,$fsfile->FS->attributes)) {
	  /govMD_(.*)$/;
	  print_split_attr_with_num_attr($fileref,$node,"govMD_$1","wMDg_$1","MDg src=\"$1\"",'w');
	}
      }
      print $fileref "\n";
      print $fileref make_gap($node->{gappost});
    }
    # print file ending
  }
  print $fileref "</c>\n";
  print $fileref "</doc>\n";
  print $fileref "</csts>\n";

  return 1;
}

1;
