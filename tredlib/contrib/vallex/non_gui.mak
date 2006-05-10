# -*- cperl -*-

#ifndef pdt_vallex_non_gui
#define pdt_vallex_non_gui

package ValLex::NonGUI;

use base qw(TredMacro);
import TredMacro;

sub new {
  my ($self,$file)=@_;
  require XML::JHXML;
  require ValLex::Data;
  require ValLex::ExtendedJHXML;
  require ValLex::DummyConv;
  $file ||= $ENV{VALLEX} || FindInResources('vallex.xml');
  return TrEd::ValLex::ExtendedJHXML->new($file, TrEd::ValLex::DummyConv->new(), 1);
}

1;

#endif pdt_vallex_non_gui
