package TrEd::Cipher;

use strict;
use base qw(Exporter);
use vars qw(@EXPORT_OK);

BEGIN {
  @EXPORT_OK = qw(generate_random_block block_to_hex hex_to_block block_xor block_md5
		  Negotiate Authentify save_block);
}

sub generate_random_block {
  my ($length)=@_;
  if ($length <= 0) {
    $length = 1024;
  }
  my $key;
  open my $ur, "/dev/urandom";
  read $ur, $key, $length;
  close $ur;
  my @key = map { int(rand(256))^$_ } unpack "C".$length, $key;
  pack "C".$length, @key;
}

sub block_to_hex {
  my ($key)=@_;
  uc(join "", map sprintf("%02x",$_), unpack "C".length($key), $key);
}

sub hex_to_block {
  my ($hex)=@_;
  pack "C".(length($hex)/2), map hex,$hex=~/(..)/g;
}

sub block_xor {
  my ($b1, $b2) = @_;
  my @b1 = unpack "C".length($b1), $b1;
  my @b2 = unpack "C".length($b1), $b2;

  my @result;
  while (@b1) {
    push @result, (shift(@b1)^shift(@b2));
  }
  return pack "C".scalar(@result), @result;
}

sub block_md5 {
  my ($b)=@_;
  require Digest::MD5;
  uc(Digest::MD5::md5_hex($b));
}

sub Authentify {
  my ($key, $peer, $control)=@_;
  my $rand = generate_random_block(length($key));
  $peer->print("$control AUTH_SIGN=",block_to_hex($rand),"\n");
  $peer->flush();
  my $reply;
  $reply = readline($peer);
  chomp ($reply);
  unless ($reply =~ /^$control AUTH_SIGNED=([0-9ABCDEF]+)$/
	  and $1 eq block_md5(block_xor($key,$rand))) {
    $peer->print("$control AUTH_FAILED\n");
    $peer->flush();
    return 0;
  } else {
    $peer->print("$control AUTH_OK\n");
    $peer->flush();
    return 1;
  }
}

sub Negotiate {
  my ($key, $server, $control)=@_;
  my $reply;
  $reply = readline($server);
  chomp ($reply);
  return 0 unless ($reply =~ /^$control AUTH_SIGN=([0-9ABCDEF]+)$/);
  $server->print("$control AUTH_SIGNED=".
		 block_md5(block_xor($key,hex_to_block($1)))."\n");
  $server->flush();
  $reply = readline($server);
  chomp ($reply);
  return 0 unless $reply eq "$control AUTH_OK";
  return 1;
}

sub save_block {
  my ($block,$filename)=@_;
  use Fcntl;
  local *FH;
  unlink $filename;
  sysopen(FH, $filename, O_WRONLY|O_EXCL|O_CREAT, 0600) || die $!;
  print FH block_to_hex($block)."\n";
  close FH;
}

1;
