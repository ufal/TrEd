#!/usr/bin/env perl
# tests for TrEd::Cipher

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";

use Test::More 'no_plan';
use Test::Exception;
use Data::Dumper;

BEGIN {
  my $module_name = 'TrEd::Cipher';
  our @subs = qw{
    generate_random_block 
    block_to_hex 
    hex_to_block 
    block_xor 
    block_md5
    Negotiate 
    Authentify 
    save_block
  };
  use_ok($module_name, @subs);
}


our @subs;
can_ok(__PACKAGE__, @subs);

sub test_generate_random_block {
  skip "Only when not on win32", 2 if $^O eq "MSWin32";
  # Okay, we're not going to test how much the block is random, we will believe that it is 
  my $result = TrEd::Cipher::generate_random_block(0);
  is(length($result), 1024, 
    "generate_random_block(): length of generated block OK");
    
  $result =  TrEd::Cipher::generate_random_block(5);
  is(length($result), 5, 
    "generate_random_block(): length of generated block OK");
  
}

sub test_block_to_hex {
  my ($block, $hex) = @_;
  is(TrEd::Cipher::block_to_hex($block), $hex, 
    "block_to_hex(): converts to hexadecimal OK");
}

sub test_hex_to_block {
  my ($hex, $block) = @_;
  is(TrEd::Cipher::hex_to_block($hex), $block, 
    "hex_to_block(): converts from hexadecimal OK");
}

sub test_block_xor {
  my $block1 = "123456789";
  my $block2 = "abcdefghijklmnopqrstuv";
  is(TrEd::Cipher::block_xor($block1, $block2), "PPPPPPPPP[Y_Y[YGIKBFFB", 
    "block_xor(): makes xor correctly");
}

sub test_block_md5 {
  my $data = "Hullabaloo";
  my $expected_md5 = "EC6AA6B91945C75AF2EE11D6BE0AB802";
  is(TrEd::Cipher::block_md5($data), $expected_md5, 
    "block_md5(): md5 calculation went OK");
  
}

sub test_save_block {
  my ($block, $hex) = @_;
  my $file_name = "my_file";
  ok(TrEd::Cipher::save_block($block, $file_name), "save_block(): return value");
  
  ok(open(my $fh, '<', $file_name), "save_block(): file exists");

  my $line = <$fh>;
  is($line, $hex . "\n", 
    "save_block(): file contents OK");
  
  unlink($file_name);
}

my $control='@-NTRED-@-PROTOCOL-@';
my $key = '$control SESSION-KEY=1234567890abcdef';


# TODO: test -- once we should act as a server, for the second time we should act as a client, 
# think of a way to test it
sub test_Authentify {
  
  if ($key =~ /^\Q$control\E SESSION-KEY=([0-9A-Z]+)$/) {
    $key = TrEd::Cipher::hex_to_block($1);
  }
  print "key = |$key|\n";
  my $start_server = 1500;
  my $port = $start_server;
  
  my $max_port = ($port =~ s/-([0-9]+)$// ? $1 : undef);
  
  my $host;
  use Sys::Hostname;
  chomp ($host=hostname()) unless defined $host;
  print "server on host |$host|\n";
  
  my $server;
  while (1) {
    $server = new IO::Socket::INET (LocalHost => $host,
  		      LocalPort => $port,
  		      Proto => 'tcp',
  		      Listen => 5,
  		      Reuse => 1,
  		     );
    last if $server or !defined($max_port) or $port>=$max_port;
    $port++;
  }
  die "Cannot open socket at $host:$port: $!\n" unless $server;
  
  
  my $allow_host;
  
  
  print("Waiting for hub on $host:$port\n");
  
  
  
  $allow_host=~s/\s//g;
  # resolve peer IP
  if ($allow_host) {
    ($allow_host) = (`LC_ALL=C host "$allow_host"` =~ / has address (.*)$/) if ($allow_host =~/[^:.0-9]/);
    print("Awaiting connection from $allow_host\n");
  }
  
  my ($hub,$peer);
  $hub = $server->accept();
  $peer = $hub->peerhost();
  if ($hub and $allow_host and $peer ne $allow_host) {
    print("Denying connection to peer $peer!\n");
    $hub->close();
    undef $hub;
  } elsif ($hub and TrEd::Cipher::Authentify($key, $hub, $control)!=1) {
    $hub->close();
    undef $hub;
  }
}

sub test_Negotiate {
  my $key;
  my $client_key_file = "my.key";
  $key = hex_to_block($key);
  
  my $hubport ||= 1500;
  my $hubname ||= 'lamebook'; # no remote connections by default
  
  my $hub= new IO::Socket::INET (PeerAddr => $hubname,
				 PeerPort => $hubport,
				 Proto => 'tcp'
				);
  die "Can't open socket to $hubname:$hubport. $!\n" unless $hub;
  $hub->autoflush(1);
  $hub->timeout(5);

  print "Negotiating with the hub\n";

  die "Authentification to $hubname:$hubport has been denied.\n"
    unless TrEd::Cipher::Negotiate($key, $hub, $control);
}



### Run Tests

test_generate_random_block();
my $block = " !\"#\$%&'()*+,-./0123456789:;<=>?\@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
my $hex = "202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F";
test_block_to_hex($block, $hex);
test_hex_to_block($hex, $block);
test_block_xor();
test_block_md5();
test_save_block($block, $hex);
