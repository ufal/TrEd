# -*- cperl -*-
#encoding iso-8859-2

# ------------ QUOTATION start ------------------

my $quottypes='primarec|citace|metauziti|nazev|rceni|zargon|nespisovne|nedoslov|metafora|ironie|jiny';
my @rotate_colors = ('#CCFF99','#CCFFFF','#FFCCCC','#9999CC');
my $last_color;
my $quot_laststart; # posledni ouvozovkovany strom

#bind initquot to Ctrl+i
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

#bind newquot to Ctrl+n
sub newquot { # nahodi a ouvozovkuje novy podstrom
  print STDERR "newquot\n";
  return unless $grp->{FSFile};
  initquot() unless exists $grp->{FSFile}->FS->defs->{quot_start};
  my $selection = [$this->{quot_type} || 'primarec'];
  listQuery('Select quotation type','browse',[split /\|/,$quottypes],$selection) || return;
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

#bind joinquot to Ctrl+j
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

#bind remquot to Ctrl+r
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


