# -*- cperl -*-
# $Id$

package Annalytic;

# ---- macros added by Zdenek Zabokrtsky for SDT purposes ----

#bind parse_slovene_sentence to Ctrl+F9
require SDT::Slovene_parser;
sub parse_slovene_sentence {
  Slovene_parser::run_parser($root,$grp);
}

#bind assign_slovene_afun to Ctrl+F10
require SDT::Slovene_parser;
sub assign_slovene_afun{
  Assign_slovene_afun::afuns_to_tree($root);
}
