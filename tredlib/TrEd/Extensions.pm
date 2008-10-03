package TrEd::Extensions;
# pajas@ufal.ms.mff.cuni.cz          02 øíj 2008

use 5.008;
use strict;
use warnings;
use Carp;
use File::Spec;

BEGIN {
  require Exporter;
  require Fslib;

  our @ISA = qw(Exporter);
  our %EXPORT_TAGS = ( 'all' => [ qw(
				      getExtensionsDir
				      initExtensions
				      getExtensionList
				      getExtensionMacroPaths
  ) ] );
  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
  our @EXPORT = qw(  );
  our $VERSION = '0.01';
}

# Preloaded methods go here.

sub getExtensionsDir {
  return $TrEd::Config::extensionsDir;
}

sub getExtensionList {
  my $extension_dir=getExtensionsDir();
  my $path = File::Spec->catfile($extension_dir,'extensions.lst');
  open(my $fh, '<:utf8', $path) || return([]);
  my @extensions = grep { /^!?[[:alnum:]_-]+\s*$/ } <$fh>;
  s/\s+$// for @extensions;
  return \@extensions;
}

sub initExtensions {
  my ($list)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: initExtensions( [ extension_name(s)... ] )');
  }
  my $extension_dir=getExtensionsDir();
  my $res_path = File::Spec->catdir($extension_dir,'resources');
  if (!grep { $_ eq $res_path } Fslib::ResourcePaths()) {
    Fslib::AddResourcePath($res_path);
  }
  for my $name (grep { !/^!/ } @$list) {
    my $dir = File::Spec->catdir($extension_dir,'resources',$name);
    if (-d $dir) {
      Fslib::AddResourcePath($dir);
    }
  }
}
sub getExtensionMacroPaths {
  my ($list)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: configureExtensionMacroPaths( [ extension_name(s)... ] )');
  }
  my $extension_dir=getExtensionsDir();
  return
#  grep { -f $_ }
  map { File::Spec->catfile($extension_dir,'contrib',$_,'contrib.mac') }
  grep { !/^!/ }
  @$list;
}
sub getExtensionMetaData {
  my ($name)=@_;
  my $extension_dir=getExtensionsDir();
  my $metafile =
    File::Spec->catfile($extension_dir,'meta',$name,'package.xml');
  if (-f $metafile) {
    return PMLInstance->load({
      filename => $metafile,
    });
  }
  return;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

TrEd::Extensions - Perl extension for blah blah blah

=head1 SYNOPSIS

   use TrEd::Extensions;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for TrEd::Extensions, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

