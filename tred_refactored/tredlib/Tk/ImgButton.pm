# Copyright (c) 2004 Petr Pajas. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Tk::ImgButton;

use vars qw($VERSION);
$VERSION = '0.1'; # $Id: ImgButton.pm 3499 2008-08-01 16:57:27Z pajas $

use strict;
use base  qw(Tk::Button);
use Tk::widgets qw(Frame Compound);

Construct Tk::Widget 'ImgButton';

sub InitObject
{
 require Tk::Button;
 # LabeledEntry constructor.
 #
 my($cw, $args) = @_;
 my %opts;
 $opts{$_} = delete $args->{$_}
   for grep { exists $args->{$_} }
     qw(-image -text -padleft -padmiddle -padright
	-balloon -balloonmsg -underline -font);
 $cw->SUPER::InitObject($args);

 my $c = $cw->Compound();
 $c->Space(-width => $opts{-padleft}) if exists $opts{-padleft};
 $c->Image(-image => $opts{-image}) if $opts{-image};
 $c->Space(-width => $opts{-padmiddle}) if $opts{-image} and exists $opts{-padmiddle};
 $c->Text(-text => $opts{-text},
	  (exists($opts{-font}) ? (-font => $opts{-font}) : ()),
	   (exists($opts{-underline}) ? (-underline => $opts{-underline}) : ())
	  ) if exists $opts{-text};
 $c->Space(-width => $opts{-padright}) if exists $opts{-padright};
 $cw->configure(-image => $c);

 # Propagate upwards to be retrieveable (in BindButtons).
 $cw->configure($_ => $opts{$_}) for qw/-text -underline/;

 $opts{-balloon}->attach($cw,-balloonmsg=>
			 $opts{-balloonmsg})  if (ref $opts{-balloon});
}

1;
