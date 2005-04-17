# -*- cperl -*-
#encoding iso-8859-2

# ------------ QUOTATION start ------------------

my $quottypes='primarec|citace|metauziti|nazev|rceni|zargon|nespisovne|nedoslov|metafora|ironie|jiny';
my @rotate_colors = ('#CCFF99','#CCFFFF','#FFCCCC','#9999CC');
my $last_color;
my $quot_laststart; # posledni ouvozovkovany strom

#bind initquot to Ctrl+i menu Initialize Quotation mode attributes
sub initquot { # pridat atributy pro anotovani uvozovek a nastavit zobrazovaci styl
  print STDERR "initquot\n";
  AppendFSHeader(
		 '@P quot_start',
		 '@L quot_type|'.$quottypes,
		 '@P quot_member',
		 '@P quot_color'
		);
  SetDisplayAttrs(
		  '#{black}${trlemma}#{red} ${quot_type}',
		  '#{black}${func}<? "_\${memberof}" if $${memberof}=~/(CO|AP|PA)/ ?>',
		  'style:<? "#{Oval-fill:".$${quot_color}."}" if $${quot_member} ?>',
		  'style:<? "#{Node-addheight:8}#{Node-addwidth:8}" if $${quot_member} ?>',
		  'text:<? "#{-background:".$${quot_color}."}" if $${quot_member} ?>${origf}'
		 );
}

#bind newquot to Ctrl+n menu Create new quotation set at current subtree
sub newquot { # nahodi a ouvozovkuje novy podstrom
  print STDERR "newquot\n";
  return unless $grp->{FSFile};
  initquot() unless exists $grp->{FSFile}->FS->defs->{quot_start};
  my $selection = [$this->{quot_type} || 'primarec'];
  ListQuery('Select quotation type','browse',[split /\|/,$quottypes],$selection) || return;
  $this->{quot_type}=$selection->[0];
  $last_color=shift @rotate_colors;
  push @rotate_colors,$last_color;
  $quot_laststart=$this->{TID} || $this->{AID};
  $this->{quot_start}='first';
  foreach my $node ($this,$this->descendants) {
    $node->{quot_member}=1;
    $node->{quot_color}=$last_color;
  }
}

#bind joinquot to Ctrl+j menu Exclude current subtree from the last quotation set
sub joinquot { # ouvozovkuje podstrom a pripoji k poslednimu nahozenemu
  print STDERR "joinquot\n";
  return unless $grp->{FSFile};
  initquot() unless exists $grp->{FSFile}->FS->defs->{quot_start};

  $this->{quot_start}=$quot_laststart;
  foreach my $node ($this,$this->descendants) {
    $node->{quot_member}=1;
    $node->{quot_color}=$last_color;
  }
}

#bind remquot to Ctrl+r menu Unquote current subtree or it's part
sub remquot { # oduvozovkuje cely ouvozovkovany podstrom, nebo jeho cast
  print STDERR "delquot\n";
  return unless $grp->{FSFile};
  initquot() unless exists $grp->{FSFile}->FS->defs->{quot_start};

  if ($this->{quot_start}){ # oduvozovkuje cely ouvozovkovany podstrom
    foreach my $node ($this,$this->descendants) {
      $node->{quot_member}='';
      $node->{quot_start}='';
      $node->{quot_color}='';
    }
  }
  elsif ($this->{quot_member}) { # oduvozovkuje jen cast ouvozovkovaneho podstromu
    foreach my $node ($this,$this->descendants) {
      $node->{quot_member}='';
      $node->{quot_start}='';
      $node->{quot_color}='';
    }
    $this->{quot_start}='unquot';
  }
}

#bind getback to Ctrl+b menu Select quotation set of the current node as current
sub getback { # umozni vratit se k ouvozovkovanemu stromu a neco dalsiho k nemu pripojit,
  # i kdyz uz mezitim bylo pouzito Ctrl+n (tzn. nacucne se barva a quot_start)
  print STDERR "Nacucavani\n";
  if ($this->{quot_member}) {
    $last_color=$this->{quot_color};
    my $quot_root=$this;
    $quot_root=$quot_root->parent while ($parent and not $quot_root->{quot_start});
    if ($quot_root->{quot_start} eq "first") {
      $quot_laststart=$this->{TID} || $this->{AID};
    }
    elsif ($quot_root->{quot_start}) {
      $quot_laststart=$quot_root->{quot_start};
    }
  }
}
