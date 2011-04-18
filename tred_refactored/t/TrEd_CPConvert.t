#!/usr/bin/env perl
# tests for TrEd::CPConvert

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";


use Test::More 'no_plan';
use Test::Exception;
use Encode qw(from_to);
#use Data::Dumper;

BEGIN {
  our $module_name = 'TrEd::CPConvert';
  our @subs = qw(
    encoding_to
    decoding_to
    encode
    decode
  );
  use_ok($module_name, @subs);
}

our @subs;
our $module_name;
can_ok($module_name, @subs);


sub test_encoding_to {
  my ($converter, $encoding_to) = @_;
  is($converter->encoding_to(), $encoding_to, 
    "encoding_to(): return correct encoding");
}

sub test_decoding_to {
  my ($converter, $decoding_to) = @_;
  is($converter->decoding_to(), $decoding_to, 
    "decoding_to(): return correct encoding");
}

sub test_decode {
  my ($converter, $encoding_1, $encoding_3) = @_;
  my $recoded = "èe¹tina mìlké nù¾ky má";
  my $expected = $recoded;
  
  # convert from first encoding to second encoding
  from_to($expected, $encoding_1, $encoding_3);
  
  is($converter->decode($recoded), $expected,
    "decode(): convert between non-utf-8 encodings");
}

sub test_decode_utf8 {
  my ($converter) = @_;
  my $recoded = "èe¹tina mìlké nù¾ky má";
  from_to($recoded, "iso-8859-2", "utf-8");
  my $expected = $recoded;
  
  is($converter->decode($recoded), $expected,
    "decode(): convert between utf-8 encodings");
}


sub test_encode {
  my ($converter, $encoding_1, $encoding_2) = @_;
  my $recoded = "èe¹tina mìlké nù¾ky má";
  my $expected = $recoded;
  
  # convert from second encoding to first encoding
  from_to($expected, $encoding_2, $encoding_1);
  
  is($converter->encode($recoded), $expected, 
    "encode(): between non-utf-8 encodings");
}

sub test_encode_utf8 {
  my ($converter) = @_;
  my $recoded = "èe¹tina mìlké nù¾ky má";
  from_to($recoded, "iso-8859-2", "utf-8");
  my $expected = $recoded;
  
  is($converter->encode($recoded), $expected, 
    "encode(): between utf-8 encodings");
}

#################
### Run Tests ###
#################

my $encoding_1 = 'iso-8859-2';
my $encoding_2 = 'utf-8';
my $encoding_3 = 'cp1250';

my $converter = TrEd::CPConvert->new($encoding_1, $encoding_3);
test_encoding_to($converter, $encoding_1);
test_decoding_to($converter, $encoding_3);

test_decode($converter, $encoding_1, $encoding_3);
test_encode($converter, $encoding_1, $encoding_3);

$converter = TrEd::CPConvert->new($encoding_2, $encoding_2);
test_decode_utf8($converter);
test_encode_utf8($converter);