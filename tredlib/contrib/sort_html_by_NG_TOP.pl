#!/usr/bin/perl

use XML::LibXML;

my $parser=XML::LibXML->new();

my $doc = $parser->parse_html_file($ARGV[0]);

die "Parsing $ARGV[0] failed.\n" unless $doc;

my @p=$doc->findnodes('//body/p');
my %keys;
foreach (@p) {
  $keys{$_} = $_->findvalue('string(.//span[@class="NG_TOP"])');
}

use locale;
use POSIX qw(locale_h);
setlocale(LC_NUMERIC,"C");
setlocale(LC_COLLATE,"cs_CZ");

foreach (sort { lc($keys{$a}) cmp lc($keys{$b}) } @p) {
  $_->parentNode->appendChild($_);
}

rename $ARGV[0], "$ARGV[0]~";
open OUT, ">$ARGV[0]";
print OUT $doc->toStringHTML();
close OUT;
