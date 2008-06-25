#!/usr/bin/env perl
# grammar.pl     pajas@ufal.ms.mff.cuni.cz     2008/05/28 15:37:23

use warnings;
use strict;
$|=1;
use Data::Dumper;
use Benchmark;


use lib qw(/home/pajas/tred-devel/tredlib/libs/pml-base);
use lib qw(/home/pajas/tred-devel/tredlib/libs/fslib);

use Fslib;
use PMLSchema;
if ($ARGV[0] eq '-T') {
  $::RD_TRACE=1;
  shift;
}
BEGIN { require 'Grammar.pm'; }

$Tree_Query::user_defined = 'echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_text|coref_gram|compl';

my $string=$ARGV[0];
if (!@ARGV or $string eq '-') {
  local $/;
  $string=<STDIN>;
}
shift;

$Tree_Query::user_defined = 'echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_text|coref_gram|compl';

my $t0 = new Benchmark;
my $parser = Tree_Query::Grammar->new() or die "Cannot create parser\n";
my $t1 = new Benchmark;
my $time = timestr(timediff($t1,$t0));
print "creating parser took: $time\n";

use Data::Dumper;
my $what = shift || 'query';
$what='parse_'.$what;
print "$what\n";
$t0 = new Benchmark;
my $result = $parser->$what($string);
$t1 = new Benchmark;
$time = timestr(timediff($t1,$t0));
print "parsing $what took: $time\n";

print Dumper($result);



__END__

=head1 NAME

grammar.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for grammar.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

Petr Pajas, E<lt>pajas@stain.ms.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
