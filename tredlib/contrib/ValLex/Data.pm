##############################################
# TrEd::ValLex::Data
##############################################

package TrEd::ValLex::Data;
use strict;
use utf8;

my @abbrev_forms = (
['do+2' => 'do-1[.2]'],
['k+3' => 'k-1[.3]'],
['mezi+4' => 'mezi-1[.4]'],
['mezi+7' => 'mezi-1[.7]'],
['místo+2' => 'místo-2[.2]'],
['nad+7' => 'nad-1[.7]'],
['na+4' => 'na-1[.4]'],
['na+6' => 'na-1[.6]'],
['od+2' => 'od-1[.2]'],
['okolo+2' => 'okolo-1[.2]'],
['o+4' => 'o-1[.4]'],
['o+6' => 'o-1[.6]'],
['podle+2' => 'podle-2[.2]'],
['pod+4' => 'pod-1[.4]'],
['pod+7' => 'pod-1[.7]'],
['po+6' => 'po-1[.6]'],
['proti+3' => 'proti-1[.3]'],
['pro+4' => 'pro-1[.4]'],
['před+7' => 'před-1[.7]'],
['přes+4' => 'přes-1[.4]'],
['při+6' => 'při[.6]'],
['s+7' => 's-1[.7]'],
['u+2' => 'u-1[.2]'],
['včetně+2' => 'včetně-2[.2]'],
['vůči+3' => 'vůči[.3]'],
['v+4' => 'v-1[.4]'],
['v+6' => 'v-1[.6]'],
['za+4' => 'za-1[.4]'],
['za+7' => 'za-1[.7]'],
['z+2' => 'z-1[.2]']
);

sub new {
  my ($self, $file, $cpconvert,$novalidation)=@_;
  my $class = ref($self) || $self;
  my $new = bless [$class->parser_start($file,$novalidation),
		   $file, undef, undef, 0, $cpconvert, []], $class;
  $new->loadListOfUsers();
  return $new;
}

sub conv {
  return $_[0]->[6];
}

sub clients {
  return $_[0]->[7];
}

sub changed {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[5];
}

sub set_change_status {
  my ($self,$status)=@_;
  return undef unless ref($self);
  $self->[5]=$status;
}

sub dispose_node {
}

sub save {
}

sub doc_reload {
}

sub doc_free {
  my ($self)=@_;
  $self->make_clients_forget_data_pointers();
  $self->dispose_node($self->doc());
  $self->set_doc(undef);
}

sub reload {
  my ($self)=@_;
  $self->doc_free();
  $self->doc_reload();
  $self->loadListOfUsers();
  $self->set_change_status(0);
}

sub parser {
  return undef unless ref($_[0]);
  return $_[0]->[0];
}

sub doc {
  return undef unless ref($_[0]);
  return $_[0]->[1];
}

sub file {
  return undef unless ref($_[0]);
  return $_[0]->[2];
}

sub user {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->doc()->documentElement->getAttribute("owner");
}

sub set_file {
  return undef unless ref($_[0]);
  return $_[0]->[2]=$_[1];
}

sub set_user {
  my ($self,$user)=@_;
  return undef unless ref($self);
  return $self->doc()->documentElement->setAttribute("owner",$user);
}

sub set_doc {
  return undef unless ref($_[0]);
  return $_[0]->[1]=$_[1];
}

sub set_parser {
  return undef unless ref($_[0]);
  return $_[0]->[0]=$_[1];
}

sub get_user_info {
  my ($self,$user)=@_;
  return exists($self->[4]->{$user}) ? $self->[4]->{$user} : ["unknown user",0,0];
}

sub user_is_reviewer {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->get_user_info($self->user())->[2];
}

sub user_is_annotator {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->get_user_info($self->user())->[1];
}

sub getUserName {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->conv->decode($self->get_user_info($self->user())->[0]);
}

sub loadListOfUsers {
  my ($self)=@_;
  my $users = {};
  return undef unless ref($self);
  my $doc=$self->doc();
  my ($head)=$doc->documentElement()->getChildElementsByTagName("head");
  if ($head) {
    my ($list)=$head->getChildElementsByTagName("list_of_users");
    if ($list) {
      foreach my $user ($list->getChildElementsByTagName("user")) {
	$users->{$user->getAttribute("user_ID")} =
	  [
	   $user->getAttribute("name"),
	   $user->getAttribute("annotator") eq "YES",
	   $user->getAttribute("reviewer") eq "YES"
	  ]
      }
    }
  }
  $self->[4]=$users;
}

sub getWordNodes {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my ($body)=$doc->documentElement()->getChildElementsByTagName ("body");
  return unless $body;
  return $body->getChildElementsByTagName("word");
}

sub getFrameNodes {
  my ($self,$word)=@_;
  return unless ref($word);
  my ($vf)=$word->getChildElementsByTagName ("valency_frames");
  return unless $vf;
  return $vf->getChildElementsByTagName ("frame");
}

sub getFrameElementNodes {
  my ($self,$frame)=@_;
  return unless ref($frame);
  my ($fe)=$frame->getChildElementsByTagName ("frame_elements");
  return unless $fe;
  return $fe->getChildElementsByTagName ("element");
}

=item getWordNodes

  return $slen words before and after given word
  suppose the lexicon is sorted alphabetically

=cut

sub getWordSubList {
  my ($self,$item,$slen,$posfilter)=@_;
  my $doc=$self->doc();
  return unless $doc;
  use locale;
  my @words=();
  my $docel=$doc->documentElement();
  my ($milestone,$after,$before,$i);
  if (ref($item)) {
    $milestone = $item;
    $before = $slen;
    $after = $slen;
  } elsif ($item eq "") {
    $milestone = $self->getFirstWordNode();
    $after = 2*$slen;
    $before = 0;
  } else {
    # search by lemma
    my $word = $self->getFirstWordNode();
    my $i=0;
    WORD: while ($word) {
      last if ($i++ % $slen == 0 &&
	       $item le $self->conv()->decode($word->getAttribute ("lemma")));
      $word = $word->findNextSibling('word') || last;
    }
    $milestone = $word;
    $before = $slen + $slen/2;
    $after = $slen/2;
  }
  # get before list
  $i=0;
  $posfilter=~s/\*/ANVD/;
  my $word = $milestone;
  while ($word and $i<$before) {
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    if (index(uc($posfilter),uc($pos))>=0) {
      my $id = $self->conv()->decode($word->getAttribute ("word_ID"));
      my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
      my $reviewed = $self->wordReviewed($word);
      unshift @words, [$word,$id,$lemma,$pos,$reviewed];
      $i++;
    }
    $word=$word->findPreviousSibling('word');
  }

  # get after list
  $i=0;
  $word=$milestone->nextSibling();
  while ($word and $word->nodeName eq 'word' and $i<$after) {
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    if (index(uc($posfilter),uc($pos))>=0) {
      my $id = $self->conv()->decode($word->getAttribute ("word_ID"));
      my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
      my $reviewed = $self->wordReviewed($word);
      push @words, [$word,$id,$lemma,$pos,$reviewed];
      $i++;
    }
    $word=$word->findNextSibling('word');
  }
  return			# sort { $a->[2] cmp $b->[2] }
    @words;
}

sub wordReviewed {
  my ($self, $word)=@_;
  return (grep { $_->getAttribute('status') eq 'active' }
    $self->getFrameNodes($word))==0;
}

sub getWordList {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my @words=();
  my $docel=$doc->documentElement();
  my $word = $self->getFirstWordNode();
  while ($word) {
    my $id = $self->conv()->decode($word->getAttribute ("word_ID"));
    my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    my $reviewed = $self->wordReviewed($word);
    push @words, [$word,$id,$lemma,$pos,$reviewed];
    $word=$word->nextSibling();
    while ($word) {
      last if ($word->nodeName() eq 'word');
      $word=$word->nextSibling();
    }
  }
  return # sort { $a->[2] cmp $b->[2] }
    @words;
}

sub getFrame {
  my ($self,$frame)=@_;

  my $id = $self->conv->decode($frame->getAttribute("frame_ID"));
  my $status = $self->conv->decode($frame->getAttribute("status"));
  my $elements = $self->getFrameElementString($frame);
  my $example=$self->getFrameExample($frame);
  my $note=$self->getSubElementNote($frame);
  $note=~s/\n/;/g;
  my ($local_event)=$frame->getDescendantElementsByTagName("local_event");
  my $auth="NA";
  $auth=$self->conv->decode($local_event->getAttribute("author")) if ($local_event);
  
  return [$frame,$id,$elements,$status,$example,$auth,$note];
}

sub getSuperFrameList {
  my ($self,$word)=@_;
  use Tie::IxHash;
  tie my %super, 'Tie::IxHash';
  return unless $word;
  my $base;
  my $nosuper=0;
  my $pos=$self->getPOS($word);
  my @frames=$self->getFrameNodes($word);
  my (@active,@obsolete);
  foreach (@frames) {
    if ($self->getFrameStatus($_) =~ /substituted|obsolete|deleted/) {
      push @obsolete,$_;
    } else {
      push @active,$_;
    }
  }
  if ($pos eq 'N') {
    foreach (@active,@obsolete) {
      $super{$nosuper++}=[$self->getFrame($_)];
    }
    return \%super;
  }
  foreach my $frame (@active) {
    $base="";
    my @element_nodes=$self->getFrameElementNodes($frame);
    foreach my $element (
			 (
			  grep { 
			    $_->getAttribute('type') eq 'oblig'
			  }
			  @element_nodes),
			 (grep {
			   $_->getAttribute('type') ne 'oblig' and # but
			     $_->getAttribute('functor') =~
			       /^(?:---|ACT|PAT|EFF|ORIG|ADDR)$/
			     } @element_nodes)
			 # this is in two greps so that we
			 # do not have to sort it
			) {
      $base.=$self->getOneFrameElementString($element)." ";
    }
    $base="$frame" if $base eq '';
    if (exists $super{$base}) {
      push @{$super{$base}},$self->getFrame($frame);
    } else {
      $super{$base}=[$self->getFrame($frame)];
    }
  }
  foreach (@obsolete) {
    $super{$nosuper++}=[$self->getFrame($_)];
  }
  return \%super;
}

sub getFrameList {
  my ($self,$word)=@_;
  return unless $word;
  return map { $self->getFrame($_) } $self->getFrameNodes($word);
}

sub getNormalFrameList {
  my ($self,$word)=@_;
  return unless $word;
  my @frames=$self->getFrameNodes($word);
  my (@active,@obsolete);
  foreach (@frames) {
    if ($self->getFrameStatus($_) =~ /substituted|obsolete|deleted/) {
      push @obsolete,$_;
    } else {
      push @active,$_;
    }
  }
  return map { $self->getFrame($_) } @active,@obsolete;
}

sub getOneFrameElementString {
  my ($self,$element)=@_;

  my $functor = $self->conv->decode($element->getAttribute ("functor"));
  $functor = '' if $functor eq '---';
  my $type = $self->conv->decode($element->getAttribute("type"));
  my $forms = $self->getFrameElementFormsString($element);
  return ($type eq "oblig" ? "" : "?")."$functor($forms)";
}

sub getFrameElementString {
  my ($self,$frame)=@_;
  return unless $frame;
  my @elements;
  my @element_nodes=$self->getFrameElementNodes($frame);

  foreach my $element (
		       (grep { $_->getAttribute('type') eq 'oblig' }
			@element_nodes)
		      ) {
    push @elements,$self->getOneFrameElementString($element);
  }
  push @elements, "  " if @elements;
  foreach my $element (
		       (grep { $_->getAttribute('type') eq 'non-oblig' }
			@element_nodes
		       )
		      ) {
    push @elements,$self->getOneFrameElementString($element);
  }
  if (@elements) {
    return join("  ", @elements);
  } else {
    return "EMPTY";
  }
}

sub getFirstWordNode {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  my $body=$docel->firstChild();
  while ($body) {
    last if ($body->nodeName() eq 'body');
    $body=$body->nextSibling();
  }
  die "didn't find vallency_lexicon body?" unless $body;
  my @w;
  my $n=$body->firstChild();
  while ($n) {
    last if ($n->nodeName() eq 'word');
    $n=$n->nextSibling();
  }
  return $n;
}

sub serializeFormNodes {
  my ($node)=@_;
  my $ret = "";
  foreach my $element (grep { $_->isElementNode } $node->childNodes) {
    if ($element->nodeName() eq 'parentpos') {
      $ret.='&';
    } else {
      $ret .= "," if $ret ne "" and $ret !~ /\&$/;
      $ret .= serializeForm($element);
    }
  }
  return $ret;
}

sub serializeForm {
  my ($node)=@_;

  if ($node->nodeName() eq 'form') {
    if ($node->getChildElementsByTagName('elided')) {
      return "!";
    } elsif ($node->getChildElementsByTagName('typical')) {
      return "*";
    } elsif ($node->getChildElementsByTagName('state')) {
      return "=";
    } elsif ($node->getChildElementsByTagName('recip')) {
      return "%";
    } else {
      return serializeFormNodes($node);
    }
  } elsif ($node->nodeName() eq 'parent') {
    my $ret="^".serializeFormNodes($node);
  } elsif ($node->nodeName() eq 'node') {
    my $ret;
    if ($node->getAttribute('form')) {
      $ret = '"'.$node->getAttribute('form').'"';
    } else {
      $ret = $node->getAttribute('lemma');
    }
    my $morph="";
    $morph='~' if $node->getAttribute('neg') eq "negative";
    $morph.= join "",map { $node->getAttribute($_) } qw(pos gen num case);
    $morph.='@'.$node->getAttribute('deg') if $node->getAttribute('deg') ne "";
    $morph.='#' if $node->getAttribute('agreement') == 1;
    foreach (1..15) {
      if (my $tag = $node->getAttribute('tagpos'.$_)) {
	$morph.="\$$_\<${tag}\>";
      }
    }
    my $inherits = $node->getAttribute('inherits');
    $ret.=($inherits==1 ? '.' : ':').$morph if ($inherits==1 or $morph ne "");
    if ($node->getChildElementsByTagName('node')) {
      $ret.="[".join(",",map { serializeForm($_) } $node->getChildElementsByTagName('node'))."]";
    }
    return $ret;
  } elsif (!$node->nodeName() eq 'parentpos') {
    die "Can't serialize unknown node-type ",$node->nodeName(),"\n";
  }
}

sub applyFormAbbrevs {
  my ($form) = @_;
  foreach (@abbrev_forms) {
    my ($k,$v) = @$_;
    $form =~ s/\b\Q$v\E/$k/g;
  }
  return $form;
}

sub expandFormAbbrevs {
  my ($form) = @_;
  foreach (@abbrev_forms) {
    my ($k,$v) = @$_;
    $form =~ s/\b\Q$k\E/$v/g;
  }
  return $form;
}

sub parseFormPart {
  my ($self,$form,$nested,$dom) = @_;
  my $lem='(?:[-[:alnum:]]|\\\\.)+';
  my $pos='';
  if ($form =~
      m{^(\^? #1
	  ( "$lem" | $lem | (?:{ $lem (?: , $lem )* (?: , ...)?}) )? # $2: lemma
	  (                  # $3
            ([.:])           # $4
	    (~)?             # $5
 	    ([adinjvufsc])?   # $6 pos
	    ([FMIN])?        # $7 gen
            ([PS])?          # $8 num
            ([1-7])?         # $9 case
            (?: @([1-3]))?   # $10 deg
            (\#)?            # $11
	    ((?: \$ (?:\d|1[01234]) [<]  (?:[^][>()\{\};,]|\\[,;*!%=~\#])+  [>]  )*) # $12
          )?                 #
          | ([*!%=])         # $13 typical,elided,recip,state
         )                   #
         ( [][&,;].* | $ ) # $14 <3> tokens to parse
      }x and $1 ne "" and $1 ne "^" and $3 ne ":") {
    my ($match,$lemma,$sep,$neg,$pos,$gen,$num,$case,$deg,$agreement,$tagpos,$special,$next) =
       ($1,    $2,    $4,  $5,  $6,  $7,  $8,  $9,   $10, $11,      ,$12    ,$13,     $14);
    if ($special ne "") {
      if ($next=~/^\[/) {
	die "Can't use [ ] after '$special'\n";
      } elsif ($nested) {
	die "Can't use '$special' within [ ]\n";
      }
      my %map = ('*' => 'typical', '!' => 'elided', '%' => 'recip', '=' => 'state');
      if ($dom) {
	$dom->appendChild($self->doc()->createElement($map{$special}));
      }
      return $next;
    }
    my $node;
    if ($dom) {
      if ($match =~ /^\^/) {
	$node = $self->doc()->createElement('parent');
	$dom->appendChild($node);
	$dom = $node;
      }
      $node = $self->doc()->createElement('node');
      $dom->appendChild($node);
      if ($lemma =~ /^"(.*)"$/) {
	$node->setAttribute('form',$1) if $1;
      } elsif ($lemma ne "") {
	$node->setAttribute('lemma',$lemma);
      }
      $node->setAttribute('neg','negative') if $neg ne "";
      $node->setAttribute('pos',$pos) if $pos ne "";
      $node->setAttribute('gen',$gen) if $gen ne "";
      $node->setAttribute('num',$num) if $num ne "";
      $node->setAttribute('case',$case) if $case ne "";
      $node->setAttribute('deg',$deg) if $deg ne "";
      $node->setAttribute('agreement','1') if $agreement ne "";
      $node->setAttribute('inherits','1') if $sep eq ".";
      if ($tagpos) {
	foreach my $tag (split /\$/,$tagpos) {
	  next if $tag eq "";
	  if ($tag =~ /^(\d+)\<(.*)\>$/) {
	    my ($pos,$value)=($1,$2);
	    $node->setAttribute('tagpos'.$pos,$value);
	  } else {
	    die "Can't parse tag: $tag\n";
	  }
	}
      }
    }
    if ($next =~ s/^\[//) {
      unless ($next =~ /^\&/) {
	do {{
	  $next = $self->parseFormPart($next,1,$node);
	}} while ($next =~ s/^,//);
      }
      if ($next =~ s/^\&//) {
	$dom->appendChild($self->doc()->createElement('parentpos')) if $dom;
	unless ($next =~ /^\]/) {
	  do {{
	    $next = $self->parseFormPart($next,1,$node);
	  }} while ($next =~ s/^,//);
	}
      }
      if ($next =~ s/^\]//) {
	return $next;
      } else {
	die "Expected ] or , near '$next'\n";
      }
    } else {
      return $next;
    }
  } else {
    die "Form syntax error near '$form'\n";
  }
}

sub parseSerializedFrame {
  my ($self, $elements, $dom)=@_;
  $elements = expandFormAbbrevs($self->conv->encode($elements));
  return 1 if ($elements=~/^\s*EMPTY\s*$/);
  my $func = '|ACT|PAT|ADDR|EFF|ORIG|ACMP|ADVS|AIM|APP|APPS|AUTH|ATT|BEN|CAUS|CNCS|COMPL|COND|CONJ|CONFR|CONTRA|CONTRD|CPR|CRIT|CSQ|CTERF|DENOM|DES|DIFF|DIR1|DIR2|DIR3|DISJ|CPHR|DPHR|ETHD|EXT|FPHR|GRAD|HER|ID|INTF|INTT|LOC|MANN|MAT|MEANS|MOD|NA|NORM|OPER|PAR|PARTL|PN|PREC|PRED|REAS|REG|RESL|RESTR|RHEM|RSTR|SUBS|TFHL|TFRWH|THL|THO|TOWH|TPAR|TSIN|TTILL|TWHEN|VOC|VOCAT';
  my @members = grep { $_ ne "" } split /\s+/,$elements;
  unless (@members) {
    warn "No members in $elements\n";
    return undef;
  }
  my ($eldom,$formdom);
  foreach my $member (@members) {
    if ($member =~ /^(\?)?($func)\(([^)]*)\)$/) {
      my ($type,$functor,$forms) = ($1,$2,$3);
      $functor = '---' if $functor eq "";
      if ($dom) {
	$eldom = $self->doc()->createElement('element');
	$dom->appendChild($eldom);
	$eldom->setAttribute('functor',$functor);
	$eldom->setAttribute('type',$type eq "?" ? 'non-oblig' : 'oblig');
      }
      my @forms = $forms=~m/\G((?:\\.|[^\\;]+)+)(?:;|$)/g;
      return undef unless $forms eq join(";",@forms);
      foreach my $form (@forms) {
	if ($dom) {
	  $formdom = $self->doc()->createElement('form');
	  $eldom->appendChild($formdom);
	}
	unless ($form=~/^\&/) {
	  do {{
	    $form = eval { $self->parseFormPart($form,0,$formdom) };
	    if ($@) {
	      warn $@;
	      return undef;
	    }
	  }} while ($form =~ s/^,//);
	}
	if ($form =~ s/^\&//) {
	  $formdom->appendChild($self->doc()->createElement('parentpos')) if $dom;
	  if ($form ne "") {
	    do {{
	      $form = eval { $self->parseFormPart($form,0,$formdom) };
	      if ($@) {
		warn $@;
		return undef;
	      }
	    }} while ($form =~ s/^,//);
	  }
	}

	if ($form ne "") {
	  warn "Unexpected tokens near '$form'\n";
	  return undef;
	}
      }
    } else {
      warn "Invalid element '$member'\n";
      return undef;
    }
  }
  if ($dom) {
    print $dom->toString();
  }
  return 1;
}

sub getFrameElementFormsString {
  my ($self,$element)=@_;
  return unless $element;
  my @forms;
  foreach my $form ($element->getChildElementsByTagName("form")) {
    push @forms,$self->conv->decode(applyFormAbbrevs(serializeForm($form)));
  }
  return join ";",@forms;
}

sub getFrameExample {
  my ($self,$frame)=@_;
  return unless $frame;
  $self->normalize_ws($frame);
  my ($example)=$frame->getChildElementsByTagName("example");
  if ($example) {
    my $text=$example->firstChild;
    if ($text and $text->isTextNode) {
      my $data=$text->getData();
      $data=~s/^\s+//;
      $data=~s/\s*;\s*/\n/g;
      $data=~s/[\s\n]+$//g;
      $data=$self->conv->decode($data);
      return $data;
    }
  }
  return "";
}

sub getElementText {
  my ($self,$element)=@_;
  return unless $element;
  $self->normalize_ws($element);
  my $text=$element->firstChild;
  if ($text and $text->isTextNode) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/[\s\n]+$//g;
    return $self->conv->decode($data);
  }
  return "";
}

sub getSubElementNote {
  my ($self,$elem)=@_;
  return unless $elem;
  $self->normalize_ws($elem);
  my ($note)=$elem->getChildElementsByTagName("note");
  return "" unless $note;
  my $text=$note->firstChild;
  if ($text and $text->isTextNode) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/\s*;\s*/\n/g;
    $data=~s/[\s\n]+$//g;
    return $self->conv->decode($data);
  }
  return "";
}

sub getSubElementProblemsList {
  my ($self,$elem)=@_;
  return unless $elem;
  my @problems=();
  my ($problems_e)=$elem->getChildElementsByTagName("problems");
  return "" unless $problems_e;
  foreach my $problem ($problems_e->getChildElementsByTagName("problem")) {
    my $author = $self->conv->decode($problem->getAttribute ("author"));
    my $solved = $self->conv->decode($problem->getAttribute ("solved"));
    my $text = $self->getElementText($problem);
    push @problems, [$problem,$text,$author,$solved];
  }
  return @problems;
}

sub findWord {
  my ($self,$find,$nearest)=@_;
  foreach my $word ($self->getWordNodes()) {
    my $lemma = $self->conv->decode($word->getAttribute("lemma"));
    return $word if (($nearest and index($lemma,$find)==0) or $lemma eq $find);
  }
  return undef;
}

sub searchFrameMatching {
  my ($self,$find,$posfilter,$word,$frame,$is_regexp) = @_;
  $word ||= $self->getFirstWordNode();
  $posfilter=~s/\*/ANVD/;
  while ($word) {
    next unless 1+index(uc($posfilter),uc($self->conv()->decode($word->getAttribute ("POS"))));
    foreach my $entry ($self->getNormalFrameList($word)) {
      if ($frame) {
	# skip up to frame $frame
	next if (!$entry->[0]->isSameNode($frame));
	undef $frame;
	next;
      }
      next if ($entry->[3] =~ /^(?:deleted|obsolete|substituted)$/);
      my $text =$entry->[2].($entry->[6].$entry->[4] ? "\n" : "").
	($entry->[6] ? "(".$entry->[6].") " : "").
	  $entry->[4]." (".$entry->[5].")";
      return $entry->[0]
	if ($is_regexp and $text =~ m/$find/
	    or !$is_regexp and index($text,$find)>=0);
    }
    undef $frame;
  } continue {
    $word = $word->findNextSibling('word');
  }
}

sub findWordAndPOS {
  my ($self,$find,$pos)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  foreach my $word ($self->getWordNodes()) {
    my $lemma = $self->conv->decode($word->getAttribute("lemma"));
    my $POS = $self->conv->decode($word->getAttribute ("POS"));
    return $word if ($lemma eq $find and $POS eq $pos);
  }
  return undef;
}

sub getForbiddenIds {
  my ($self)=@_;
  my $doc=$self->doc();
  return {} unless $doc;
  my $docel=$doc->documentElement();
  my ($tail)=$docel->getChildElementsByTagName("tail");
  return {} unless $tail;
  my %ids;
  foreach my $ignore ($tail->getChildElementsByTagName("forbid")) {
    $ids{$self->conv->decode($ignore->getAttribute("forbidden_ID"))}=1;
  }
  return \%ids;
}

sub generateNewWordId {
  my ($self,$lemma,$pos)=@_;
  my $i=0;
  my $forbidden=$self->getForbiddenIds();
  foreach ($self->getWordList) {
    return undef if ($_->[2] eq $lemma and $_->[3] eq $pos);
    if ($_->[1]=~/^w-([0-9]+)/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  my $user=$self->user;
  $i++ while ($forbidden->{"w-$i-$user"});
  return "w-$i-$user";
}

sub addWord {
  my ($self,$lemma,$pos)=@_;
  return unless $lemma ne "";
  my $new_id = $self->generateNewWordId($lemma,$pos);
  return unless defined($new_id);

  my $doc=$self->doc();
  my $root=$doc->documentElement();
  my ($body)=$root->getChildElementsByTagName("body");
  return unless $body;
  # find alphabetic position
  my $n=$self->getFirstWordNode();
  use locale;

  while ($n) {
    last if $lemma le $self->conv->decode($n->getAttribute("lemma"));
    # don't allow more then 1 lemma/pos pair
    $n=$n->nextSibling();
    while ($n && $n->nodeName ne 'word') {
      $n=$n->nextSibling();
    }
  }
  my $word=$doc->createElement("word");
  if ($n) {
    print "insert before\n";
    $body->insertBefore($word,$n);
  } else {
    print "append\n";
    $body->appendChild($word);
  }
  $word->setAttribute("lemma",$self->conv->encode($lemma));
  $word->setAttribute("POS",$pos);
  $word->setAttribute("word_ID",$new_id);

  my $valency_frames=$doc->createElement("valency_frames");
  $word->appendChild($valency_frames);
  $self->set_change_status(1);
  print "Added $word\n";
  return $word;
}

sub getPOS {
  my ($self,$word)=@_;
  return unless ref($word);
  return $self->conv->decode($word->getAttribute("POS"));
}

sub getLemma {
  my ($self,$word)=@_;
  return unless ref($word);
  return $self->conv->decode($word->getAttribute("lemma"));
}

sub addFrameLocalHistory {
  my ($self,$frame,$type)=@_;
  return unless $frame;
  my $doc=$self->doc();

  my ($local_history)=$frame->getChildElementsByTagName("local_history");
  unless ($local_history) {
    $local_history=$doc->createElement("local_history");
    $frame->appendChild($local_history);
  }

  my $local_event=$doc->createElement("local_event");
  $local_history->appendChild($local_event);
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  $local_event->setAttribute("time_stamp",sprintf('%d.%d.%d %02d:%02d:%02d',
						 $mday,$mon+1,1900+$year,$hour,$min,$sec));
  $local_event->setAttribute("type_of_event",$type);
  $local_event->setAttribute("author",$self->user());
  $self->set_change_status(1);
  return $local_event;
}

sub changeFrameStatus {
  my ($self,$frame,$status,$action)=@_;
  $frame->setAttribute('status',$status);
  $self->addFrameLocalHistory($frame,$action);
  $self->set_change_status(1);
}

sub substituteFrame {
  my ($self,$word,$frame,$elements,$note,$example,$problem)=@_;
  return unless ($frame);
  my $new=$self->addFrame($frame,$word,$elements,$note,$example,$problem,$self->user());
  return unless $new;
  $self->changeFrameStatus($frame,"substituted","obsolete");
  my $subst=$frame->getAttribute("substituted_with");
  my $new_id=$new->getAttribute("frame_ID");
  $subst= $subst eq "" ? $new_id : "$subst $new_id";
  $frame->setAttribute("substituted_with",$subst);
  $self->set_change_status(1);
  return $new;
}

sub generateNewFrameId {
  my ($self,$word)=@_;
  my $i=0;
#  my $w=0;
  my $wid=$word->getAttribute("word_ID");
  my $forbidden=$self->getForbiddenIds();
#  $w=$1 if ($wid=~/^.-(.+)/);
  foreach ($self->getFrameList($word)) {
    if ($_->[1]=~/-(\d+)\D*$/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  my $user=$self->user;
  $i++ while ($forbidden->{"f-$wid-$i-$user"});
  return "f-$wid-$i-$user";
}

sub addFrame {
  my ($self,$before,$word,$elements,$note,$example,$problem,$author)=@_;
  return unless $word and $elements;

  my $new_id = $self->generateNewFrameId($word);
  my $doc=$self->doc();
  my ($valency_frames)=$word->getChildElementsByTagName("valency_frames");
  return unless $valency_frames;

  # try parse elements
  my $elems=$doc->createElement("frame_elements");
  $doc->documentElement()->appendChild($elems);
  unless ($self->parseSerializedFrame($elements,$elems)) {
    $doc->documentElement()->removeChild($elems);
    $self->dispose_node($elems);
    return;
  }
  $doc->documentElement()->removeChild($elems);

  my $frame=$doc->createElement("frame");
  if (ref($before)) {
    $valency_frames->insertBefore($frame,$before);
  } else {
    $valency_frames->appendChild($frame);
  }
  $frame->setAttribute("frame_ID",$new_id);
  $frame->setAttribute("status","active");

  my $ex=$doc->createElement("example");
  $frame->appendChild($ex);
  $ex->addText($self->conv->encode($example));

  if ($note ne "") {
    my $not=$doc->createElement("note");
    $frame->appendChild($not);
    $not->addText($self->conv->encode($note));
  }
  if ($problem ne "") {
    my $problems=$doc->createElement("problems");
    $frame->appendChild($problems);

    my $probl=$doc->createElement("problem");
    $problems->appendChild($probl);
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
  }
  $frame->appendChild($elems);
  $self->addFrameLocalHistory($frame,"create");
  $self->set_change_status(1);
  return $frame;
}

sub modifyFrame {
  my ($self,$frame,$elements,$note,$example,$problem,$author)=@_;
  return unless $frame and $elements ne "";
  my $doc=$self->doc();

  # try parse elements
  my $elems=$doc->createElement("frame_elements");
  $doc->documentElement()->appendChild($elems);
  unless ($self->parseSerializedFrame($elements,$elems)) {
    $doc->documentElement()->removeChild($elems);
    $self->dispose_node($elems);
    return;
  }
  $doc->documentElement()->removeChild($elems);

  my ($old_ex)=$frame->getChildElementsByTagName("example");
  my $ex=$doc->createElement("example");
  if ($old_ex) {
    $frame->replaceChild($ex,$old_ex);
    $self->dispose_node($old_ex);
  } else {
    $frame->insertBefore($ex,$frame->firstChild);
  }
  $ex->addText($self->conv->encode($example));
  undef $old_ex;

  my ($old_note)=$frame->getChildElementsByTagName("note");
  if ($note ne "") {
    my $not=$doc->createElement("note");
    if ($old_note) {
      $frame->replaceChild($not,$old_note);
      $self->dispose_node($old_note);
    } else {
      $frame->insertAfter($not,$ex);
    }
    $not->addText($self->conv->encode($note));
  } elsif ($old_note) {
    $frame->removeChild($old_note);
    $self->dispose_node($old_note);
  }
  undef $old_note;
  my ($old_elems)=$frame->getChildElementsByTagName("frame_elements");
  my ($problems)=$frame->getChildElementsByTagName("problems");
  if ($problem ne "") {
    unless ($problems) {
      $problems=$doc->createElement("problems");
      if ($old_elems) {
	$frame->insertBefore($problems,$old_elems);
      } else {
	$frame->appendChild($problems);
      }
    }
    my $probl=$doc->createElement("problem");
    $problems->appendChild($probl);
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
  }

  $frame->replaceChild($elems,$old_elems);
  $self->dispose_node($old_elems);
  undef $old_elems;

  $self->addFrameLocalHistory($frame,"modify");
  $self->set_change_status(1);
  return $frame;
}

sub moveFrameBefore {
  my ($self,$frame,$refframe)=@_;
  my $parent=$frame->getParentNode();
  if ($parent and $refframe) {
    $parent->removeChild($frame);
    $parent->insertBefore($frame, $refframe);
  }
}

sub moveFrameAfter {
  my ($self,$frame,$refframe)=@_;
  my $parent=$frame->getParentNode();
  if ($parent and $refframe) {
    $parent->removeChild($frame);
    $parent->insertAfter($frame, $refframe);
  }
}


=item findNextFrame ($refframe, $status)

  Searches for the next frame following $refframe with the given $status

=cut

sub findNextFrame {
  my ($self,$frame, $status, $posfilter)=@_;
  my $word;
  $posfilter=~s/\*/ANVD/;
  unless ($frame) {
    $word=$self->getFirstWordNode();
    ($frame)=$self->getFrameNodes($word);
  } else {
    $word=$self->getWordForFrame($frame);
    $frame=$frame->findNextSibling('frame');
  }
  while ($word) {
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    if (index(uc($posfilter),uc($pos))>=0) {
      while ($frame) {
	return $frame if $self->getFrameStatus($frame) =~ $status;
	$frame = $frame->findNextSibling('frame');
      }
    }
    $word = $word->findNextSibling('word');
    ($frame)=$self->getFrameNodes($word);
  }

}

sub findPrevFrame {
  my ($self,$frame, $status, $posfilter)=@_;
  my $word;
  $posfilter=~s/\*/ANVD/;
  return $self->findNextFrame() unless ($frame);

  $word=$self->getWordForFrame($frame);
  $frame=$frame->findPreviousSibling('frame');

  while ($word) {
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    if (index(uc($posfilter),uc($pos))>=0) {
      while ($frame) {
	return $frame if $self->getFrameStatus($frame) =~ $status;
	$frame = $frame->findPreviousSibling('frame');
      }
    }
    $word = $word->findPreviousSibling('word');
    do {
      my @frames=$self->getFrameNodes($word);
      $frame=$frames[$#frames];
    };
  }

}


sub getWordForFrame {
  my ($self,$frame)=@_;
  return $frame->getParentNode()->getParentNode();
}

sub getFrameId {
  my ($self,$frame)=@_;
  return undef unless $frame;
  return $self->conv->decode($frame->getAttribute("frame_ID"));
}

sub getWordId {
  my ($self,$word)=@_;
  return undef unless $word;
  return $self->conv->decode($word->getAttribute("word_ID"));
}

sub getSubstitutingFrame {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("substituted_with"));
}

sub getFrameStatus {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("status"));
}

sub getFrameUsed {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("used"));
}

sub getFrameHereditaryUsed {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("hereditary_used"));
}

sub isEqual {
  my ($self,$a,$b)=@_;
  return $a == $b;
}

sub normalize_ws {
}

sub register_client {
  my ($self,$client)=@_;
  my $clients=$self->clients();
  unless (grep {$_ == $client} @$clients) {
    push @$clients,$client;
  }
}

sub unregister_client {
  my ($self,$client)=@_;
  my $clients=$self->clients();
  @$clients=grep {$_ != $client} @$clients;
}

sub make_clients_forget_data_pointers {
  my ($self)=@_;
  my $clients=$self->clients();
  foreach my $client (@$clients) {
    $client->forget_data_pointers();
  }
}

sub DESTROY {
  my ($self)=@_;
  $self->set_parser(undef);
  $self->make_clients_forget_data_pointers();
}

##############################################
# TrEd::ValLex::Data
##############################################
#
# Any object storing pointers to data elements
# must implement this interface for proper
# deallocation
#
##############################################

package TrEd::ValLex::DataClient;

sub data {
}

sub register_as_data_client {
  if ($_[0]->data()) {
    $_[0]->data()->register_client($_[0]);
  }
}

sub unregister_data_client {
  if ($_[0]->data()) {
    $_[0]->data()->unregister_client($_[0]);
  }
}

sub forget_data_pointers {
}

sub destroy {
  my ($self)=@_;
  $_[0]->unregister_data_client();
}

1;
