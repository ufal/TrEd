# -*- cperl -*-

#ifndef pdt_vallex_non_gui
#define pdt_vallex_non_gui

package ValLex::NonGUI;

BEGIN { import TredMacro; }

sub new {
  my ($self,$file)=@_;
  require XML::JHXML;
  require ValLex::Data;
  require ValLex::ExtendedJHXML;
  $file ||= $ENV{VALLEX} || FindInResources('vallex.xml');
  return TrEd::ValLex::ExtendedJHXML->new($file);
}

1;

#endif pdt_vallex_non_gui
