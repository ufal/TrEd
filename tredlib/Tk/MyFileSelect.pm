package Tk::MyFileSelect;
use strict;

use vars qw($VERSION);
$VERSION = '0.001';

use Tk qw(Ev);

require Tk::Frame;
require Tk::Derived;
require Tk::Listbox;
use File::Spec::Functions;
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
  
  #... e.g., class bindings here ...

  $class->SUPER::ClassInit($mw);
}

sub Populate {
    my ($cw,$args) = @_;
    my $startDir= delete $args->{-startdir};
    
    $cw->SUPER::Populate( $args );
    $cw->ConfigSpecs(
		     -showhidden     => [qw/PASSIVE showHidden ShowHidden 0/],
		    );

    my $hlist = $cw->Scrolled('Listbox',-relief  => 'raised',-scrollbars => 'e');
    $hlist->pack(-side => 'top', -fill => 'x');
    $hlist->bind('<Double-1>', [ $cw, 'ChDir' ]);  
    $hlist->bind('<Return>', [ $cw, 'ChDir' ]);  

    $cw->Advertise(filelist => $hlist );
    $cw->ChangeDir(defined($startDir) ? $startDir : ".");
}

sub ReadDir {
  my ($cw,$dir)=@_;

  $cw->Subwidget('filelist')->delete(0,'end');
  if ($dir=~/^(?:[a-z]:)?(?:$rsplit)?$/i and $^O eq 'MSWin32') {
    $cw->Subwidget('filelist')->insert('end', Win32API::File::getLogicalDrives());
  }

#  my $sdir=($dir=~/^[A-Z]:$/i) ? "$dir/" : $dir;
  opendir(DIR, $dir) || warn "can't opendir $dir: $!";
  $cw->Subwidget('filelist')->insert('end', map { -d "$dir$splitchar$_" ? "$_$splitchar" : "$_" } sort(readdir(DIR)));
  closedir DIR;
  return 1;
}


sub ChangeDir {
  my ($cw,$dir)=@_;

  $cw->{cwd}=$dir;
  $cw->{cwd}=getcwd() unless defined($cw->{cwd});
  $cw->{cwd}.=$splitchar unless ($cw->{cwd}=~/$rsplit$/);
#  $dir=canonpath($dir);
  $dir=$cw->{cwd}.$dir unless ($dir=~/^$rsplit/);

  $dir=~s!/!$splitchar!g;
  $dir=~s!$rsplit\.$rsplit!$splitchar!g;
  $dir=~s!^$rsplit\.\.$rsplit!$splitchar!g;
  $dir=~s!$rsplit(?:[^.$rsplit]|\.[^.]|[^.]\.)+$rsplit\.\.$rsplit!$splitchar!g;

  print STDERR "In ",$cw->{cwd}," trying $dir\n";

#  if (-d $dir) {
    $cw->{cwd}=$dir;
#  }

  $cw->ReadDir($cw->{cwd});
}

sub ChDir {
  my ($cw)=@_;
  
  $cw->ChangeDir($cw->Subwidget('filelist')->get('active'));   

}

1;

__END__

=cut

