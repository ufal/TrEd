#!/usr/bin/env xsh2
# -*- mode: cperl; coding: utf8; -*-

## Takes care of cross-references in file (plus handles URLs starting with 'http://' correctly)

my $sectid=0;

foreach //link/@linkend {
  my $sect = //*[starts-with(name(),'sect') and title[.=xsh:current()]];
  if ($sect) {
    unless ($sect and $sect/@id) {
      insert attribute { "id=sect-".($sectid++) } into $sect;
    }
  } else {
    my $current = string(.);
    perl {
      if($current =~ /http:\/\//){
        # print STDERR "URL: $current\n";
      } else { 
        print STDERR "Section: $current not found\n";
      }
    }
  }
  insert text $sect/@id into .;
}
