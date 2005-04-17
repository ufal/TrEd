package Assign_afun;

use Decompose_tag; # module for decomposing positional morphological tag
use Special_chars; # module for substituting  special characters with sequences
use AfunDecTree; # decision tree for assigning of the analytical function

map {$most_frequent_lemmas{$_}=1}
  qw[, . být a v se na ten : - který s o ¾e mít z
     i ) do ( pro k za on firma rok tento moci jeho ale cena
     ? svùj &ast; u nebo " já pøi od velký dal¹í spoleènost èeský
     v¹ak jako co Praha muset hodnì po tak mùj podnikatel Kè podnik
     jak jen podle &percnt; jít telefon stát ne¾ trh také v¹echen
     jeden nový koruna malý pøípad první doba jiný 1 èlovìk ÈR kdy¾
     napøíklad daò a¾ zákon práce 02 zbo¾í jen¾ fax 1994 èi výroba
     obchodní dobrý nìkterý aby zahranièní mezi dva tøeba platit];

# ----------- function afun -------------
# afun (g_lemma,g_tag,i_lemma,i_tag,d_lemma,d_tag)
#   meaning of the prefixes of the arguments:
#        g_ the nearest "autosemantic" governing node
#        i_ the immediately governing node
#        d_ the node to be assigned (the dependent node)

sub afun($$$$$$)  {

  #    print STDERR "Assign_afun: ",(join "\t",@_);
  foreach $attr (g_lemma,g_tag,i_lemma,i_tag,d_lemma,d_tag) {
    $attributes{$attr}=shift;
  }

  # only the most frequent lemmas are considered in the decision tree,
  # all the remaining ones must be replaced with string "other"
  foreach $prefix (g,i,d) {
    $attrname="$prefix\_lemma";
    $attributes{$attrname}=~s/^(.+)[-^`'_;]/$1/;
    $attributes{$attrname}="other" unless exists
      $most_frequent_lemmas{$attributes{$attrname}};
  }

  # morphological categories are extracted from the tag
  # and joined to the attribute set

  %attributes=(%attributes,
		 decompose_tag("g_",lc $attributes{g_tag}),
		 decompose_tag("i_",lc $attributes{i_tag}),
		 decompose_tag("d_",lc $attributes{d_tag}));


  # if the immediate governor and the autosemantic governor are identical,
  # then all attributes with prefix i_ are set to value "nic"
  #   print "\n3 (tags): ",join "\t",(map {$attributes{$_}} (g_tag,i_tag,d_tag)),"\n";
  if ($attributes{g_tag} eq $attributes{i_tag})
    {map  {$attributes{$_}="nic"}  grep {m/^i/}  (keys %attributes);}
  @attributes{keys %attributes} = special_chars_off(
						    map {s/N\/A/undef/;$_}
						    (values %attributes));
#   print  "Attributes:\n",join ", ",map {"$_=$attributes{$_}"}
#     ( g_lemma,g_pos,g_subpos,g_case,g_voice,i_lemma,i_pos,i_subpos,
#       i_case,i_voice,d_lemma,d_pos,d_subpos,d_case,d_voice);
#   print STDERR "\n\nAssign_afun: response: ",AfunDecTree::evalTree(\%attributes),"\n\n";

    return AfunDecTree::evalTree(\%attributes);
  }
1;

