# Copyright (c) 2004 Petr Pajas. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Tk::ImgButton;

use vars qw($VERSION);
$VERSION = '0.1'; # $Id$

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
	-balloon -balloonmsg -underline);
 $cw->SUPER::InitObject($args);
 # Advertised subwidgets:  entry.
 my $c = $cw->Compound();
 $c->Space(-width => $opts{-padleft}) if exists $opts{-padleft};
 $c->Image(-image => $opts{-image}) if exists $opts{-image};
 $c->Space(-width => $opts{-padmiddle}) if exists $opts{-image} and exists $opts{-padmiddle};
 $c->Text(-text => $opts{-text},
	   (exists($opts{-underline}) ? (-underline => $opts{-underline}) : ())
	  ) if exists $opts{-text};
 $c->Space(-width => $opts{-padright}) if exists $opts{-padright};
 $cw->configure(-image => $c);
 $opts{-balloon}->attach($cw,-balloonmsg=>
			 $opts{-balloonmsg})  if (ref $opts{-balloon});
}

1;
