# -*- cperl -*-

# This Tred macro defines a new Tred context
# specially tailored for the annotation of grammatemes.

# written by Zdenek Zabokrtsky, March 2003

package TR_Grammatemes;
import TredMacro;

#binding-context TR_Grammatemes

#use strict;
#use vars qw ($root $grp $this);

unshift @INC,"$libDir/contrib" unless (grep($_ eq "$libDir/contrib", @INC));
require Assign_german_grammatemes;
require Assign_czech_grammatemes;

# ---------------------------------------------------
# --------------- color settings --------------------
my %color = (
	     'trlemma' => 'black',
	     'subject' => 'red',
	     'func' => 'black',
	     'memberof' => 'black',
	     'syntgramm' => 'blue',
	     'wordclass' => 'red',
	     'morphgramm' => 'blue',
	     'statusline_key' => 'red',
	     'statusline_caption' => 'darkblue'
	    );

# ----------------------------------------------------------------
# --------------- customizing displayed attributes ---------------

my %relevant_gramms = (
		       'N' => ['number'],  # and determination in German?
		       'V' => ['sentmod','deontmod','tense','aspect'],
		       'ADJ' => ['degcmp'],
		       'ADV' => ['degcmp']
		      );

sub switch_context_hook {
  if ($grp->{FSFile} and GetSpecialPattern('patterns') ne 'force') {
    set_default_attrs();
  }
}

sub file_opened_hook {
  if ($grp->{FSFile} and GetSpecialPattern('patterns') ne 'force') {
    set_default_attrs();
  }
}

sub set_default_attrs {
 SetDisplayAttrs(
		 "#{$color{trlemma}}".
		 '${trlemma}',

		 "#{$color{subject}}".
		 '<? "Subj." if $${subject} ne "" ?>'.
		 "#{$color{func}}".
		 '${func}'.
		 "#{$color{memberof}}".
		 '<?"_\${memberof}" if "$${memberof}" =~ /CO|AP|PA/ ?>'.
		 "#{$color{syntgramm}}".
		 '<? ".\${gram}" if $${gram} ne "" ?>',

		 "#{$color{wordclass}}".
		 '${wordclass}: '.
		 "#{$color{morphgramm}}".
		 (join "",map {
		   my $list=join ".", map {"\\\${$_}"} @{$relevant_gramms{$_}};
		   "<? \"$list\" if \$\${wordclass} eq \"$_\" ?>";
		 } keys %relevant_gramms )
		);
}


# -----------------------------------------------------------------
# -------------- updating the file header -------------------------

#bind update_gramm_file to F7
sub update_gramm_file {
#  if (!GUI() || questionQuery('Automatic file update',
#     "Update file header (necessary for grammateme annotation)?\n",
#     qw{Yes No}) eq 'Yes') {
#    Assign_german_grammatemes::update_file_header;
#    return 1;
  print "updating fs header\n";
  AppendFSHeader(
		 '@P determination',
		 '@L determination|DEF|IND|BARE|NA|???',
		 '@P wordclass',
		 '@L wordclass|V|N|ADJ|ADV|NUM',
		 '@P subject'
		);
#  }
}

# ---------------------------------------------------------------
# --------- automatic assignment of grammatemes  ----------------

#bind assign_czech_grammatemes to F8
sub assign_czech_grammatemes {
#  Assign_german_grammatemes::assign_grammatemes($root);
  Assign_czech_grammatemes::assign_grammatemes($root);
}



# ----------------------------------------------------------------
# --------- keyboard shortcuts for manual annotation -------------

my $attrname='wordclass';

my %gram_values = (
		   'wordclass' => 'V|N|ADJ|ADV|NUM',
		   'gender' => 'ANIM|INAN|FEM|NEUT',  # masc???
		   'number' => 'SG|PL',
		   'degcmp' => 'POS|COMP|SUP',
		   'aspect' => 'PROC|CPL|RES',
		   'verbmod' => 'IND|IMP|CDN',
		   'deontmod' => 'DECL|DEB|HRT|VOL|POSS|PERM|FAC',
		   'sentmod' => 'ENUNC|EXCL|DESID|IMPER|INTER',
		   'tense' => 'SIM|ANT|POST',
		   'determination' => 'DEF|IND|BARE'
		     );

my %syntgram_values = (
		       'LOC' => 'v|mezi.1|mezi.2|na|za|vedle|pred',
		       'DIR1' => 'v|mezi.1|mezi.2|na|za|vedle|pred',
		       'DIR2' => 'v|mezi.1|mezi.2|na|za|vedle|pred',
		       'DIR3' => 'v|mezi.1|mezi.2|na|za|vedle|pred',
		       'REG' => 'WOUT',
		       'ACMP' => 'WOUT',
		       'BEN' => 'AGST'
		      );

# ---- shortcuts for selecting the attribute to be changed ------------

my %shortcuts = (
		 'wordclass' => 'w', 'sentmod' => 's',
		 'deontmod' => 'm', 'aspect' => 'a',
		 'tense' => 't', 'number' => 'n',
		 'degcmp' => 'd', 'gender' => 'g',
		 'gram' => 'G'
		);

#bind select_wordclass to w
#bind select_sentmod to s
#bind select_deontmod to m
#bind select_aspect to a
#bind select_tense to t
#bind select_number to n
#bind select_determination to r
#bind select_degcmp to d
#bind select_gender to g
#bind select_gram to G

foreach my $attr ('wordclass','sentmod','deontmod','aspect','tense',
		  'number', 'determination', 'degcmp', 'gender', 'gram') {
  eval "
    sub select_$attr {
      \$FileNotSaved=0;
      if (relevant(\"$attr\")) {
         \$attrname='$attr';
         print  \"Attribute $attr selected\n\";
	 RedrawStatusLine();
      }
      else { print \"Irrelevant attribute $attr, wordclass=\$this->{wordclass}\n\" }
      \$Redraw='none';
    }
  ";
}


# ---- shortcuts for assigning a value to the selected attribute ---------

sub set_value {
  my ($index)=@_;
  my $newvalue;
  print "Changing $index\n";
  if ($attrname eq '') {print "no attribute specified\n"}
  elsif ($index eq '?') {  $newvalue="???"  }
  elsif ($attrname eq 'gram') {
    $newvalue=${['NA',(split '\|',$syntgram_values{$this->{func}})]}[$index];
  }
  else {
    $newvalue=${['NA',(split '\|',$gram_values{$attrname})]}[$index];
  }
  if ($newvalue) {
    $this->{$attrname}=$newvalue;
    print "attribute $attrname set to $newvalue\n"
  }
}

#bind set_unknown_value to ?
sub  set_unknown_value { set_value('?') }

#bind value0 to 0
#bind value1 to 1
#bind value2 to 2
#bind value3 to 3
#bind value4 to 4
#bind value5 to 5
#bind value6 to 6
#bind value7 to 7
#bind value8 to 8
#bind value9 to 9

for (my $i=0;$i<10;$i++) {eval "sub value$i { set_value($i) }"}


# ---- shortcut for toggling the subject index ------------

#bind toggle_subject to S
sub toggle_subject {
  if ($this->{subject} ne "1") {
    $this->{subject}="1";
    print "subject marked\n"
  }
  else {
    $this->{subject}="";
    print "subject unmarked\n";
  };
}

# -------- statusline ---------------

sub relevant ($) {
  my ($attrname)=@_;
  return  (
	   $attrname eq "wordclass"
	   or
	   grep {$_ eq $attrname} @{$relevant_gramms{$this->{wordclass}}}
	   or
	   ($attrname eq "gram" and $syntgram_values{$this->{func}})
	  );
}

sub get_status_line_hook {
  return [
	  [ # status line content
	   'Attributes:' => ['caption'],
	   ' ' => [],
	   $shortcuts{'wordclass'} => ['key'],
	   '-wordclass ' => [],
	   (
	    map {(
		  $shortcuts{$_} => ['key'],
		  "-$_ " => []
		  )}
	    (@{$relevant_gramms{$this->{wordclass}}},
	     grep {relevant('gram')} ('gram'))
#	    (grep {relevant($_)} keys %gram_values)
	   ),
	   ' ' => [],

	   "Values:" => ['caption'],
	   ' ' => [],
	   eval {
	     return () unless relevant($attrname);
	     my @values;
	     if ($attrname ne 'gram') {@values=split /\|/,$gram_values{$attrname}}
	     else {@values=split /\|/,$syntgram_values{$this->{func}}};
	     unshift @values, "NA";
	     return map {($_ => ['key'],
			  "-$values[$_] " => []
			  )}
	       (0..$#values);
	   }
	  ],

	  [ # status line styles
	   'caption' => [ -foreground => $color{statusline_caption},
		          -underline => 1],
	   'key' => [ -foreground => $color{statusline_key}]
	  ]
	 ];
}
