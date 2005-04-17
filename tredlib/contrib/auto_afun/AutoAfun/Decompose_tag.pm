package Decompose_tag;

# this module decomposes the PDT positional morphological tag
# and return hash with attribute names and values

use Exporter;
@ISA=(Exporter);
@EXPORT = ('decompose_tag');

BEGIN {
@Position2Name=("pos","subpos","gender","number","case",
		"possgender","possnumber","person","tense",
		"grade","negation","voice");
}

sub decompose_tag($$)
  {
    my $prefix=shift, $tag=shift, $i, %attributes;
    $tag="$tag----------------------------";
    for ($i=0;$i<=$#Position2Name;$i++) {
      $tag=~s/^(.)//;
      $value=$1;
      if ($value eq "-") {$value="N/A"};
#      if ($value eq "?") {$value="spec_qmark"};
      $attributes{"$prefix".$Position2Name[$i]}=$value;
     }
    return %attributes;
}

1;

