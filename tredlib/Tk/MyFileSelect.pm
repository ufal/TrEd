package Tk::MyFileSelect;
use strict;

use vars qw($VERSION);
$VERSION = '0.001';

use Tk;
use Tk qw(Ev);

require Tk::Frame;
require Tk::Derived;
require Tk::Listbox;
#require Tk::Entry;
use Cwd;

my ($splitchar,$rsplit);

if ( $^O eq 'MSWin32' ) {
  require Win32API::File;
  $splitchar="\\";
  $rsplit="\\\\";
} else {
  $splitchar='/';
  $rsplit='/';
}

use base  qw(Tk::Derived Tk::Frame);
Construct Tk::Widget 'MyFileSelect';

sub ClassInit {
  my ($class,$mw) = @_;
  $class->SUPER::ClassInit($mw);   #... e.g., class bindings here ...
}

sub Populate {
  my ($cw,$args) = @_;
  $cw->{startDir} = my $startDir = delete $args->{-startdir};
  $cw->{selectmode} = my $selectmode =
    exists($args->{-selectmode}) ?
      delete($args->{-selectmode}) : 'browse';

  $cw->SUPER::Populate( $args );

  $cw->ConfigSpecs(-filetypes        => ['PASSIVE', undef, undef, undef]);

  $cw->{fileTypes} = my $fileTypes = delete $args->{-filetypes};
  my(@filetypes) = GetFileTypes($cw->{'fileTypes'});
  $cw->ConfigSpecs(-filter => ['PASSIVE', undef, undef, 
			       defined $cw->{'fileTypes'} ?
			       join(' ', @{ $filetypes[0]->[1] })
			       : '*']);


#    $cw->{entry} = my $entry = $cw->Entry(qw /-state disabled/,
#  					-textvariable => \$cw->{cwd});
#    $entry->pack(qw /-side top -expand yes -pady 0 -fill x/);

  $cw->{'entry'} = my $entry =
    $cw->Menubutton(-indicatoron => 1, -tearoff => 0,
		    -takefocus => 1,
		    -highlightthickness => 2,
		    -relief => 'raised',
		    -bd => 2,
		    -anchor => 'w')
      ->pack(qw /-side top -expand yes -pady 0 -fill x/);

  $cw->{hlist} = my $hlist = 
    $cw->Scrolled('Listbox',
		  %$args,
		  -relief  => 'raised',
		  -selectmode => $selectmode,
		  -scrollbars => 'e');

  $hlist->pack(qw /-side top -expand yes -fill both/);
  $hlist->bind('<Double-1>', [ $cw, 'ChDir' ]);
  $hlist->bind('<Return>', [ $cw, 'ChDir' ]);

  my $driveLetters;
  if ($^O eq 'MSWin32') {
    $cw->{driveLetters} = $driveLetters = $cw->BrowseEntry(
		       -variable => \$cw->{cdrive},
		       -browsecmd => [
				      sub { my ($c,$e,$drive)=@_;
					    $c->ChangeDir($drive);
					  }, $cw
				     ],
		       -state    => 'readonly',
		       -choices  => [ Win32API::File::getLogicalDrives() ])
	->pack(qw /-side top -expand yes -pady 5 -fill x/);
  }

  $cw->{'typeMenuBtn'} = my $typeMenuBtn =
    $cw->Menubutton(-indicatoron => 1, -tearoff => 0,
		    -takefocus => 1,
		    -highlightthickness => 2,
		    -relief => 'raised',
		    -bd => 2,
		    -anchor => 'w')
      ->pack(qw /-side top -expand yes -pady 0 -fill x/);


  $cw->Advertise(filelist => $hlist );
  $cw->Advertise(entry => $entry );
  $cw->Advertise(typeMenuBtn => $typeMenuBtn );
  $cw->Advertise(drivelist => $driveLetters ) if ($driveLetters);

  if (defined $cw->{'fileTypes'}) {
    my $typeMenu = $typeMenuBtn->cget(-menu);
    $typeMenu->delete(0, 'end');
    foreach my $ft (@filetypes) {
      my $title  = $ft->[0];
      my $filter = join(' ', @{ $ft->[1] });
      $typeMenuBtn->command
	(-label => $title,
	 -command => ['SetFilter', $cw, $title, $filter],
	);
    }
    $cw->SetFilter($filetypes[0]->[0], join(' ', @{ $filetypes[0]->[1] }));
    $typeMenuBtn->configure(-state => 'normal');
  } else {
    $cw->configure(-filter => '*');
    $typeMenuBtn->configure(-state => 'disabled',
			    -takefocus => 0);
  }

  $cw->ChangeDir(defined($startDir) ? $startDir : ".");

  $cw;
}

sub ReadDir {
  my ($cw,$dir)=@_;

  $cw->Subwidget('filelist')->delete(0,'end');
  if ($^O eq 'MSWin32') {
    $dir="$1$splitchar." if ($dir=~/^([a-z]:)(?:$rsplit)?$/i);
  }
  local *DIR;
  my $flt = join('$|', split(' ', $cw->cget(-filter)) );
  $flt =~ s!([\.\+])!\\$1!g;
  $flt =~ s!\*!.*!g;
  opendir(DIR, $dir) || warn "can't opendir $dir: $!";
  my @all=grep { $_ ne "." } readdir(DIR);
  @all= (sort(map { "$_$splitchar" } grep { -d "$dir$splitchar$_" } @all),
	 sort grep { ! -d "$dir$splitchar$_" and $_ =~ m!${flt}$! } @all);
  $cw->Subwidget('filelist')->insert('end', @all);
  closedir DIR;
  return 1;
}

sub getSelectedFiles {
  my ($cw)=@_;
  return map { $cw->getCWD.$cw->{hlist}->get($_) } $cw->{hlist}->curselection;
}

sub getCWD {
  my ($cw)=@_;
  return $cw->{cwd};
}

sub ChangeDir {
  my ($cw,$dir)=@_;

  $cw->{cwd}=getcwd() unless defined($cw->{cwd});
  $cw->{cwd}.=$splitchar unless ($cw->{cwd}=~/$rsplit$/);
  $dir=$cw->{cwd}.$dir unless ($dir=~/^$rsplit/ or $dir=~/^[a-z]:|^$rsplit/i and $^O eq 'MSWin32');

  $dir=~s!/!$splitchar!g;
  $dir=~s!$rsplit\.$rsplit!$splitchar!g;
  $dir=~s!^$rsplit\.\.$rsplit!$splitchar!g;
  $dir=~s!$rsplit(?:[^.$rsplit]|\.[^.]|[^.]\.)+$rsplit\.\.$rsplit!$splitchar!g;

  if (-d $dir) {
    $cw->{cwd}=$dir;
    $cw->ReadDir($cw->{cwd});
    $cw->UpdateEntry($cw->{cwd});
  }
}

sub ChDir {
  my ($cw)=@_;

  $cw->ChangeDir($cw->Subwidget('filelist')->get('active'));
}

sub UpdateEntry {
  my ($cw,$dir)=@_;

  if (defined $cw->{'entry'}) {
    my $entries = $cw->{entry}->cget(-menu);
    $entries->delete(0, 'end');
    my $i=-1;
    my @subs;
    if ($^O eq 'MSWin32') {
      unshift @subs, Win32API::File::getLogicalDrives();
      unshift @subs, undef;
    }
    unshift (@subs,substr $dir,0,$i+1) 
      while (($i=index($dir,$splitchar,$i+1))>=0);
    foreach (@subs) {
      if (defined($_)) {
	$entries->command
	  (-label => $_,
	   -command => ['ChangeDir', $cw, $_]
	  );
      } else {
	$entries->separator();
      }
    }
    $cw->{'entry'}->configure(-text => $dir);
  }
}

# This proc gets called whenever data(filter) is set
#
sub SetFilter {
    my($w, $title, $filter) = @_;
    $w->configure(-filter => $filter);
    $w->{'typeMenuBtn'}->configure(-text => $title,
				   -indicatoron => 1);
    $w->ChangeDir("");
}

# tkFDGetFileTypes --
#
#       Process the string given by the -filetypes option of the file
#       dialogs. Similar to the C function TkGetFileFilters() on the Mac
#       and Windows platform.
#
sub GetFileTypes {
    my $in = shift;
    my %fileTypes;
    foreach my $t (@$in) {
        if (@$t < 2  || @$t > 3) {
	    require Carp;
	    Carp::croak("bad file type \"$t\", should be \"typeName [extension ?extensions ...?] ?[macType ?macTypes ...?]?\"");
        }
	push @{ $fileTypes{$t->[0]} }, (ref $t->[1] eq 'ARRAY'
					? @{ $t->[1] }
					: $t->[1]);
    }

    my @types;
    my %hasDoneType;
    my %hasGotExt;
    foreach my $t (@$in) {
        my $label = $t->[0];
        my @exts;

        next if (exists $hasDoneType{$label});

        my $name = "$label (";
	my $sep = '';
        foreach my $ext (@{ $fileTypes{$label} }) {
            next if ($ext eq '');
            $ext =~ s/^\./*./;
            if (!exists $hasGotExt{$label}->{$ext}) {
                $name .= "$sep$ext";
                push @exts, $ext;
                $hasGotExt{$label}->{$ext}++;
            }
            $sep = ',';
        }
        $name .= ')';
        push @types, [$name, \@exts];

        $hasDoneType{$label}++;
    }

    return @types;
}


1;

__END__

=cut

