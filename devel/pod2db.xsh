#!/usr/bin/env xsh2
# -*- mode: cperl; coding: utf8; -*-

my $sectid=0;

foreach //link/@linkend {
  my $sect = //*[starts-with(name(),'sect') and title[.=xsh:current()]];
  unless ($sect and $sect/@id) {
    insert attribute { "id=sect-".($sectid++) } into $sect;
  }
  insert text $sect/@id into .;
}
