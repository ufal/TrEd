# -*- cperl -*-
# $Id$

package Analytic;

# ---- macros added by Zdenek Zabokrtsky for SDT purposes ----

#bind parse_slovene_sentence to Ctrl+F9 menu Parse Slovene sentence
require SDT::Slovene_parser;
sub parse_slovene_sentence {
  Slovene_parser::run_parser($root,$grp);
}

#bind assign_slovene_afun to Ctrl+F10 menu Assign Slovene afun
require SDT::Assign_slovene_afun;
sub assign_slovene_afun{
  Assign_slovene_afun::afuns_to_tree($root);
}
