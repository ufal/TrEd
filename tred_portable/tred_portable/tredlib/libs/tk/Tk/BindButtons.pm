package Tk::BindButtons;
# pajas@ufal.mff.cuni.cz          14 èen 2007

use strict;

# this package actually adds a method to Tk::Widget

# a private helper routine
my $_descendant_widgets;
$_descendant_widgets = sub {
  return ($_[0],map {$_descendant_widgets->($_)} $_[0]->children);
};

sub Tk::Widget::BindButtons {
  my ($w,@subwidgets)=@_;
  my $top=$w->toplevel;
  my %bind;
  foreach my $button (grep { ref($_) and ($_->isa('Tk::Button') or $_->isa('Tk::Label')) } $_descendant_widgets->($w)) {
    my $ul=$button->cget('-underline');
    if (defined($ul) and $ul>=0) {
      my $text=$button->cget('-text');
      my $key=lc(substr($text,$ul,1));
      $bind{$key}=$button;
    }
  }
  if ($w->isa('Tk::Dialog') or $w->isa('Tk::DialogBox')) {
    unshift @subwidgets, $w->Subwidget('bottom');
  }
  my %seen;
  foreach my $button (grep {
    ref($_) and $_->isa('Tk::Button') }
		      map { $_descendant_widgets->($_) }
		      grep defined, @subwidgets ) {
    next if $seen{$button};
    $seen{$button}=1;
    my $text=$button->cget('-text');
    next if $button->cget('-underline')>=0;
    for my $i (0..length($text)) {
      my $key=lc(substr($text,$i,1));
      if ($key=~/[a-zA-Z.]/ and !exists($bind{$key})) {
	$button->configure(-underline=>$i);
	$bind{$key}=$button;
	last;
      }
    }
  }
  for my $key (keys(%bind)) {
    my $button = $bind{$key};
    next unless $button->isa('Tk::Button');
    next if $key !~ /^[a-zA-Z.]$/i;
    $key=~s/^\.$/period/;
    $top->bind("<Alt-$key>", [sub { $_[1]->flash; $_[1]->invoke; },$button]);
  }
}

1;
__END__

=head1 NAME

Tk::BindButtons - automatically create keyboard shortcuts for Tk buttons

=head1 SYNOPSIS

   $dialog->BindButtons();

=head1 DESCRIPTION

This function finds all buttons with -underline option set and creates
a corresponding Alt+key keyboard binding. For Dialog or DialogBox
widgets this function also automatically underlines the dialog buttons
and creates the corresponding bindings (using the first letter that is
not occupied by buttons or labels inside the dialog).

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

