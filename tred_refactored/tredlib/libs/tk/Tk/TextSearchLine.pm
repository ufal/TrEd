package Tk::TextSearchLine;
# pajas@ufal.mff.cuni.cz          02 led 2008

use 5.008;
use strict; 
use warnings;
use Carp;
use Tk;
use Tk::Text;

our $VERSION = '0.01';

# Preloaded methods go here.
sub Tk::Text::TextSearchLine {
  my ($text,%opts)=@_;
  my $parent = delete $opts{-parent} || $text->parent;
  my $sf = $parent->Frame;
  my $label = delete $opts{-label} || '~Search:';
  my $underline = index($label,'~');
  $label=~s/\~(.)/$1/ if defined $underline;
  my $key = lc($1);
  $sf->Label($underline>=0 ? (-underline => $underline) : (),
	     -text => $label
	    )->pack(qw(-side left));
  my $next_img = delete $opts{'-next_img'};
  my $prev_img = delete $opts{'-prev_img'};
  my $qs = $sf->Entry(
    -validate => 'key',
    -validatecommand =>
      [sub {
	 my ($text,$value)=@_;
	 return 1 unless defined $value and length $value;
	 $text->tagRemove('sel','0.0','end');
	 $text->tagRemove('match','0.0','end');
	 my $new = $text->search(qw(-forward -exact -nocase -- ), $value, 'insert');
	 if ($new) {
	   $text->SetCursor($new);
	   $text->tagAdd('sel',$new, $new.' + '.length($value).' chars');
	   $text->tagAdd('match',$new, $new.' + '.length($value).' chars');
	   return 1;
	 } else {
	   return undef;
	 }
       },$text],
     %opts
     );
  my $find_next = sub {
    my ($w,$text,$qs,$dir)=@_;
    $qs->focus;
    $text->FindNext($dir,qw(-exact -nocase), $qs->get());
    $text->tagRemove('match','0.0','end');
    eval { $text->tagAdd('match','sel.first','sel.last'); };
  };

  my $next_but = $sf->Button(
    $next_img ? (-image => $next_img) : (-text => '>'),
    -height=>$sf->reqheight-4,
    -command => [$find_next,$qs,$text,$qs,'-forward'],
   )->pack(qw(-side right -expand 0));
  my $prev_but = $sf->Button(
    $prev_img ? (-image => $prev_img) : (-text => '<'),
    -height=>$sf->reqheight-4,
    -command => [$find_next,$qs,$text,$qs,'-backward'],
  )->pack(qw(-side right -expand 0));
  $qs->pack(qw(-side right -expand 1 -fill x));

  my $top = $text->toplevel;
  $top->bind('<Alt-'.$key.'>', [$qs,'focus']) if defined $key and length $key;
  $text->tagConfigure('match',-background=>'green',-underline=>1);
  $top->bind('<F3>', [$find_next,$text,$qs,'-forward']);
  $top->bind('<Control-n>', [$find_next,$text,$qs,'-forward']);
  $top->bind('<Control-p>', [$find_next,$text,$qs,'-backward']);

  $qs->bind('<Return>',[$text,'focus']);
  my $b = $sf->Balloon();
  $b->attach($next_but,'Find next (Ctrl+n)');
  $b->attach($prev_but,'Find next (Ctrl+p)');
  return $sf;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Tk::TextSearchLine - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Tk::TextSearchLine;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Tk::TextSearchLine, 
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

