package Arab_special_chars;

# this module consists of two functions for
# substituting special characters with sequences of non-spec.chars
# and vice versa

# it is purposed for data preprocessing for c4.5


use Exporter;
@ISA=(Exporter);
@EXPORT = ('special_chars_on','special_chars_off');


BEGIN {
%Char2Sequence=("\#","spec_hash",
    "\\|", "spec_pipe",
    "\\-", "undef",
    '\\"', "spec_quot",
    "\\+", "spec_plus",
    "\\*", "spec_aster",
    "\\,", "spec_comma",
    "\\.", "spec_dot",
    "\\!", "spec_exmark",
    "\\:", "spec_ddot",
    "\\;", "spec_semicol",
    "\\=", "spec_eq",
    "\\?", "spec_qmark",
    "\\^", "spec_head",
    "\\~", "spec_tilda",
    "\\}", "spec_rbrace",
    "\\{", "spec_lbrace",
    "\\(", "spec_lpar",
    "\\)", "spec_rpar",
    "\\[", "spec_lpar",
    "\\]", "spec_rpar",
    "\\&", "spec_amper",
    "\\'", "spec_aph",
    "\\`", "spec_aph2",
    "\\\"", "spec_quot",
    "\\%", "spec_percnt",
    "\\\\","spec_backslash",
    "\\\/","spec_slash",
    "\\#", "spec_cross",
    "\\\$", "spec_dollar",
    "\\@", "spec_at" );

foreach $ch (keys %Char2Sequence)
  {   $Sequence2Char{$Char2Sequence{$ch}}=$ch;
      $Sequence2Char{$Char2Sequence{$ch}}=~s/\\//g;
};

#print STDERR "Translation table for special characters initialized.\n";
}

sub special_chars_off
  {
    my $x,$l,$o;
    return map {
      $o=$_;
      foreach $x (keys %Char2Sequence) {
	$l=$Char2Sequence{$x};
	$o=~s/$x/$l/g;
	$o="empty" if ($o=~m/^\s+$/);
      };
      $o;}  @_;
}

sub special_chars_on
  {
    my $x,$l,$o;
    return map {
      $o=$_;
      foreach $x (keys %Sequence2Char) {
	$l=$Sequence2Char{$x};
	$o=~s/$x/$l/g;
      };
      $o;}  @_;
}




1;

