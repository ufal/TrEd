# test macro file no 5
# Test encoding setting -- iso-8859-2

#encoding iso-8859-2

package TredMacro;

#use vars (qw{$this});



package encode_test;

#binding-context encode_test

## This is a long commentary. If it is not here, the characters with diacritics are 
## not decoded correctly and some macro functions would not work correctly.
## We have to read whole script in binary mode and then decode it... but the whole macro system is 
## probably going to be rewritten, so I am not going to rewrite it right now.

## Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam sollicitudin rhoncus magna, 
## in volutpat diam mollis vitae. Cum sociis natoque penatibus et magnis dis parturient montes, 
## nascetur ridiculus mus. Nunc tortor massa, egestas eu ultrices id, molestie vitae purus. 
## Praesent sed quam massa, ut tempor tellus. Nullam felis enim, ornare tempor ornare a, 
## malesuada vel orci. Suspendisse iaculis blandit urna vitae tincidunt. Maecenas iaculis fermentum nulla, 
## non luctus quam cursus vitae. Vivamus vel accumsan enim. Aenean ut placerat velit. 
## Mauris suscipit rutrum nulla id placerat. Cum sociis natoque penatibus et magnis dis 
## parturient montes, nascetur ridiculus mus. Sed iaculis ipsum id ipsum posuere suscipit. 
## Nam lectus augue, consequat vitae ullamcorper sed, porttitor in libero. 
## Duis convallis eleifend urna, in malesuada sapien adipiscing ac. Praesent nec libero sed metus 
## consequat egestas non malesuada nunc. Etiam ut ornare arcu. Pellentesque in dolor elit, 
## ut accumsan justo. Pellentesque nibh erat, interdum ac sollicitudin eu, placerat a risus.


sub macro5_fn {
	print "¾lu»ouèký kùò úpìl ïábelské ódy\n";
}

sub macro5_return {
	return 5;
}

sub fn_from_pdt20_ext {
	my ($lemma) = @_;
	if($lemma=~/^.*`([^0-9_-]+)/){
		$lemma=$1;
	}else{
		$lemma=~s/(.+?)[-_`].*$/$1/;
		if($lemma =~/^(?:(?:[ts]v|m)ùj|já|ty|jeho|se)$/){
			# print ">>>!!!$lemma to pers pron!!!<<<\n";
			return 1;
		} else {
			return 0;
		}
	}
}

sub repeater_hook {
	my ($arg) = @_;
	return $arg;
}


return 2;