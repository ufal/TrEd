#!/usr/bin/env xsh2
# -*- mode: cperl; coding: utf8; -*-

my $sectid=0;

foreach //link/@linkend {
  my $sect = //*[starts-with(name(),'sect') and title[.=xsh:current()]];
  if ($sect) {
    unless ($sect and $sect/@id) {
      insert attribute { "id=sect-".($sectid++) } into $sect;
    }
  } else {
    echo :e "Section:" string(.) "not found";
  }
  insert text $sect/@id into .;
}
