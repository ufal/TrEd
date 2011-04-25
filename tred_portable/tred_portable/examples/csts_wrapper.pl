#!/usr/bin/perl

#
# This program reads csts from standard input and
# writes it on standard output, precedinig and following it
# with a dummy csts header if no header is found
#

$_=<>;
if (/^\<([A-Za-z]*)/) {
  $firsttag=$1;
} else {
  warn "Line 1 does not begin with a tag, I doubt this is a CSTS file!";
}

@header = split /\n/,<<'EOH';
<csts lang=cs>
<doc file="" id="0">
<a>
<mod>
<txtype>
<genre>mix
<med>
<temp>
<authname>y
<opus>
<id>
</a>
<c>
<p n=0>
<s id="0">
EOH

@footer = split /\n/,<<'EOH';
</c>
</doc>
</csts>
EOH

foreach (@header) {
  /<([A-Za-z]*)/;
  if ($1 eq $firsttag) {
    last;
  } else {
    $add{"</$1>"}=1;
    print "$_\n";
  }
}

print $_;
print while (<>);

foreach (@footer) {
  print "$_\n" if ($add{$_});
}

