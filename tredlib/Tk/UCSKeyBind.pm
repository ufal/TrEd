package Tk::UCSKeyBind;

sub _UCSEntryClassInit  {
  my ($class,$mw) = @_;
  &_OldEntryClassInit(@_);
  foreach (keys %letter_plus_caron) {
    $mw->bind($class,"<dead_caron>$_", ['Insert',$letter_plus_caron{$_}]);
  }
}

sub _UCSTextClassInit  {
  my ($class,$mw) = @_;
  &_OldTextClassInit(@_);
  foreach (keys %letter_plus_caron) {
    $mw->bind($class,"<dead_caron>$_", ['InsertKeypress',$letter_plus_caron{$_}]);
  }
}


BEGIN {

  %letter_plus_caron = {
	  "C" => "\x{010C}",
	  "D" => "\x{010E}",
	  "E" => "\x{011A}",
	  "L" => "\x{013D}",
	  "N" => "\x{0147}",
	  "R" => "\x{0158}",
	  "S" => "\x{0160}",
	  "T" => "\x{0164}",
	  "Z" => "\x{017D}",
	  "c" => "\x{010D}",
	  "d" => "\x{010F}",
	  "e" => "\x{011B}",
	  "l" => "\x{013E}",
	  "n" => "\x{0148}",
	  "r" => "\x{0159}",
	  "s" => "\x{0161}",
	  "t" => "\x{0165}",
	  "z" => "\x{017E}"
	   };

  *_OldEntryClassInit=*Tk::Entry::ClassInit;
  *Tk::Entry::ClassInit=*_UCSEntryClassInit;

  *_OldTextClassInit=*Tk::Text::ClassInit;
  *Tk::Text::ClassInit=*_UCSTextClassInit;
}

1;
