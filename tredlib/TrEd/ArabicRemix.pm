#!/usr/bin/perl -w ############################################### Otakar Smrz, 2001/11/05
#
# ArabicRemix.pm ############################################################## 2004/03/10

package TrEd::ArabicRemix;


sub remix ($;$) {

    my @data = split /([\p{Arabic}\x{064B}-\x{0652}\x{0670}\x{0657}\x{0656}\x{0640}\p{InArabicPresentationFormsA}\p{InArabicPresentationFormsB}]+)/, $_[0];

    for (my $i = 0; $i < @data; $i++) {


	$data[$i] = reverse $data[$i] if $i % 2;
    }

    return join "", reverse @data;
}


sub direction ($) {

    return  1 if $_[0] =~ /\p{Latin}|[0-9\x{0660}-\x{0669}]/;
    return -1 if $_[0] =~ /\p{Arabic}|\p{InArabic}|\p{InArabicPresentationFormsA}|\p{InArabicPresentationFormsB}/;
    return  0;
}


sub remixdir ($;$) {

    my @char = split //, $_[0];

    my $context = 1;
    my @cut = (0);

    my $reverse = $context == 1 ? 0 : 1;

    my ($i, @line);

    for ($i = 0; $i < @char; $i++) {

       if ($context + direction $char[$i] == 0) {

           push @cut, $i;
           $context *= -1;
       }
    }

    push @cut, $i;

    for ($i = 1; $i < @cut; $i++) {

        if ($i % 2 == $reverse and not $_[1]) {

            unshift @line, reverse @char[$cut[$i - 1]..$cut[$i] - 1];
        }
        else {

            unshift @line, @char[$cut[$i - 1]..$cut[$i] - 1];
        }
    }

    return join "", @line;
}


1;
