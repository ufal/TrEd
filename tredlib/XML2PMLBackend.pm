package XML2PMLBackend;

use IOBackend qw(set_encoding);
use base qw(PMLBackend);

use strict;
use vars qw($xslt_processor $xslt_stylesheet $xslt_processor_opts $encoding);

sub default_settings {
  $xslt_processor = "xsltproc" unless $xslt_processor;
  $xslt_processor_opts = "%s -" unless $xslt_processor_opts;
  $xslt_stylesheet = "/home/pajas/projects/pml/xml2xdata.xsl" unless $xslt_stylesheet;
  $encoding = 'utf-8';
}

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  if ($mode eq 'w') {
    return IOBackend::open_backend($filename,$mode,$encoding);
  } elsif ($mode eq 'r') {
    my $fh = undef;
    my $cmd = $xslt_processor." ".$xslt_processor_opts;
    print STDERR "$cmd\n" if $Fslib::Debug;
    $cmd=~s/\%s/$xslt_stylesheet/g;
    $cmd=~s/\%f/-/g;
    print STDERR "[r $cmd]\n"; # if $Fslib::Debug;
    no integer;
#    $fh = set_encoding(
    $fh = IOBackend::open_pipe($filename,'r',$cmd);
      #,$encoding);
  } else {
    die "unknown mode $mode\n";
  }
}


*read=\&PMLBackend::read;
*write=\&PMLBackend::write;
*close_backend=\&IOBackend::close_backend;

sub test_xslt_processor {
  return 1 if (-x $xslt_processor);
  foreach (split(($^O eq 'MSWin32' ? ';' : ':'),$ENV{PATH})) {
    print STDERR "xslt processor not found at $xslt_processor\n";# if $Fslib::Debug;
    return 1 if -x "$_".($^O eq 'MSWin32' ? "\\" : "/")."$xslt_processor";
  }
  print STDERR "xslt processor not found at $xslt_processor\n";# if $Fslib::Debug;
  return 0;
}

sub test {
  my ($f,$encoding)=@_;
  print STDERR "TESTING $f\n";# if $Fslib::Debug;
  return 0 unless test_xslt_processor();
  print STDERR "FOUND xslt processor $xslt_processor\n";# if $Fslib::Debug;
  if (ref($f)) {
    local $_;
    1 while ($_=$f->getline() and !/\S/);
    return 0 unless (/^\s*<\?xml\s/);
  } else {
    my $fh = IOBackend::open_backend($f,"r",$encoding);
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

BEGIN {
  default_settings();
  print STDERR "xslt processor $xslt_processor\n";# if $Fslib::Debug;
}

1;
