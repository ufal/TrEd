package XML2PMLBackend;

require PMLBackend;
use Exporter qw(import);
use IOBackend qw(set_encoding);
use base qw(PMLBackend);
use strict;
use vars qw($xslt_processor $xslt_processor_opts $in_stylesheet $out_stylesheet $in_stylesheet_path $out_stylesheet_path @EXPORT_OK);

sub default_settings {
  $xslt_processor = "xsltproc" unless $xslt_processor;
  $xslt_processor_opts = "%s -" unless $xslt_processor_opts;
  $in_stylesheet ||= "xml2xdata.xsl";
  $in_stylesheet_path ||= Fslib::FindInResources($in_stylesheet);
  $out_stylesheet ||= "xdata2xml.xsl";
  $out_stylesheet_path ||= Fslib::FindInResources($out_stylesheet);
}

*read = \&PMLBackend::read;
*write=\&PMLBackend::write;
*close_backend=\&IOBackend::close_backend;

BEGIN {
  @EXPORT_OK = qw(&test &test_xslt_processor &xslt_commandline &default_settings
		  &open_backend &close_backend &read &write read write);
  default_settings();
  print STDERR "xslt processor $xslt_processor\n" if $Fslib::Debug;
};

sub xslt_commandline {
  my ($cmd, $stylesheet) = @_;

  print STDERR "$cmd\n" if $Fslib::Debug;
  $cmd=~s/\%s/$stylesheet/g;
  $cmd=~s/\%f/-/g;
  return $cmd;
}

*xslt_commandline_in = \&xslt_commandline;
*xslt_commandline_out = \&xslt_commandline;

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  if ($mode eq 'w') {
    my $cmd = xslt_commandline_in($xslt_processor." ".$xslt_processor_opts,$out_stylesheet_path);
    print STDERR "[w $cmd]\n" if $Fslib::Debug;
    my $fh = IOBackend::open_pipe($filename,'w',$cmd);
  } elsif ($mode eq 'r') {
    my $cmd = xslt_commandline_out($xslt_processor." ".$xslt_processor_opts,$in_stylesheet_path);
    print STDERR "[r $cmd]\n" if $Fslib::Debug;
    my $fh = IOBackend::open_pipe($filename,'r',$cmd);
  } else {
    die "unknown mode $mode\n";
  }
}

sub test_xslt_processor {
  return 1 if (-x $xslt_processor);
  foreach (split(($^O eq 'MSWin32' ? ';' : ':'),$ENV{PATH})) {
    return 1 if -x "$_".($^O eq 'MSWin32' ? "\\" : "/")."$xslt_processor";
  }
  print STDERR "xslt processor not found at $xslt_processor\n" if $Fslib::Debug;
  return 0;
}

sub test {
  my ($f,$encoding)=@_;
  return 0 unless test_xslt_processor();
  if (ref($f)) {
    local $_;
    1 while ($_=$f->getline() and !/\S/);
    return 0 unless (/^\s*<\?xml\s/);
    return 1;
  } else {
    my $fh = IOBackend::open_backend($f,"r");
    my $test = $fh && test($fh,$encoding);
    IOBackend::close_backend($fh);
    return $test;
  }
}

1;
