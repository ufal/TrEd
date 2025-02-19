#!/usr/bin/env perl
# tests for TrEd::FileLock

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More;

use File::Spec;
use Data::Dumper;

use TrEd::Config;
use Treex::PML;

BEGIN {
  our @subs = qw(
                check_lock 
                lock_file 
                lock_open_file 
                read_lock 
                remove_lock 
                set_fs_lock_info 
                set_lock
              );
  my $module_name = 'TrEd::FileLock';
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


sub test_lock_info {
  my ($lock_info) = @_;
  like($lock_info, qr/$TrEd::Config::userlogin/, "lock info contains user's login name");
  like($lock_info, qr/$ENV{HOSTNAME}/, "lock info contains hostname of the computer");
  like($lock_info, qr/pid $$/, "lock info contains pid of the prcess that locked the file");
  like($lock_info, qr/mtime: [0-9]+/, "lock info contains modification time of locked file");
}

sub test_check_lock {
  my ($args_ref) = @_;
  
  my $ourlockinfo     = $args_ref->{ourlockinfo};
  my $expected_result = $args_ref->{expected_result};
  my $test_msg        = $args_ref->{test_msg};
  
  my $fsfile          = $args_ref->{fsfile};
  my $file_name       = $args_ref->{file_name};
  
  TrEd::FileLock::set_fs_lock_info($fsfile, $ourlockinfo);

  is(TrEd::FileLock::check_lock($fsfile, $file_name), $expected_result, 
    $test_msg);
  
}

my $file_name = File::Spec->catfile($FindBin::Bin, 'test_files', 'sample0.a.gz');

TrEd::Config::set_config();

sub _last_err {
  my ($ret) = grep { defined $_ && $_ ne q{} } ($_[0], "$@", $!);
  return $ret;
}

my @backends=(
  'FS',
  Treex::PML::ImportBackends(
    qw{NTRED
       Storable
       PML
       CSTS
       TrXML
       TEIXML
       PMLTransform
      })
 );

my $fsfile = Treex::PML::Factory->createDocumentFromFile(
                $file_name,
                {
                  backends => \@backends,
                  recover => 1,
                }
              );

# encoding => $TrEd::Convert::inputenc,

my $lock_info = TrEd::FileLock::set_lock($file_name);
test_lock_info($lock_info);


is(read_lock($file_name), $lock_info, 
  "read_lock(): lock read correctly from file");
  
# and now 15 possibilities for check_lock
{
  local $TrEd::Config::noCheckLocks = 1;
  is(TrEd::FileLock::check_lock(undef, $file_name), 'Ignore', 
    'check_lock(): Lock ignored if noCheckLocks is set');
}

# lockinfo not empty && ourlockinfo does not exist
  is(TrEd::FileLock::check_lock($fsfile, $file_name), 'my', 
    'check_lock(): our lock');
    
{
  local $$ = $$ + 1;
  is(TrEd::FileLock::check_lock($fsfile, $file_name), 'locked ' . $lock_info, 
    'check_lock(): locked by some other process id');
}

{
  local $TrEd::Config::userlogin = $TrEd::Config::userlogin . '_the_other';
  is(TrEd::FileLock::check_lock($fsfile, $file_name), 'locked ' . $lock_info, 
    'check_lock(): locked by some other user');
}

{
  local $ENV{HOSTNAME} = (defined $ENV{HOSTNAME} ? $ENV{HOSTNAME} : q{}) . '_the_other';
  is(TrEd::FileLock::check_lock($fsfile, $file_name), 'locked ' . $lock_info, 
    'check_lock(): locked by some other host');
}

note("set also fs lock");
test_check_lock({
  ourlockinfo       => $lock_info,
  expected_result   => 'my',
  test_msg          => 'check_lock(): lock is my, our lock equals to lock file contents',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

my $ourlockinfo = '_not_equal' . $lock_info;
test_check_lock({
  ourlockinfo       => $ourlockinfo,
  expected_result   => "stolen (but not yet changed) $lock_info (previously locked $ourlockinfo)",
  test_msg          => 'check_lock(): our lock differs from lockfile contents, file not changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

$ourlockinfo = 'locked ' . $lock_info;
test_check_lock({
  ourlockinfo       => $ourlockinfo,
  expected_result   => "opened by us ignoring the lock $lock_info, who still owns the lock, but has not saved the file since",
  test_msg          => 'check_lock(): our lock consists of \'locked\' word followed by lock_info, file not changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

$ourlockinfo = 'locked not_equal ' . $lock_info;
test_check_lock({
  ourlockinfo       => $ourlockinfo,
  expected_result   => "opened by us ignoring the lock " . substr($ourlockinfo, 7) . ", but later locked again $lock_info",
  test_msg          => 'check_lock(): our lock consists of \'locked\' word followed by something else than lock_info',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

# change file's modification time 
my $time = time();
utime $time, $time, $file_name;

note("locked, but modified");

test_check_lock({
  ourlockinfo       => $lock_info,
  expected_result   => 'changed by another program',
  test_msg          => 'check_lock(): our lock does not start with \'locked\', it equals to lock file contents, however, the file has been changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

$ourlockinfo = '_not_equal' . $lock_info;
test_check_lock({
  ourlockinfo       => $ourlockinfo,
  expected_result   => "stolen and changed $lock_info (previously locked $ourlockinfo)",
  test_msg          => 'check_lock(): our lock does not start with \'locked\', it differs from lockfile contents, file has been changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

$ourlockinfo = 'locked ' . $lock_info;
test_check_lock({
  ourlockinfo       => $ourlockinfo,
  expected_result   => "opened by us ignoring the lock " . substr($ourlockinfo, 7) . " and later changed by the lock owner",
  test_msg          => 'check_lock(): our lock consists of \'locked\' word followed by lock_info and file has been changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

# empty lock file...
note("Empty lock file");
unlink($file_name . '.lock');

test_check_lock({
  ourlockinfo       => undef,
  expected_result   => "none",
  test_msg          => 'check_lock(): empty lock file, ourlock does not exist',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

# file to previous modification time, so it looks unchanged
my ($mtime) = $lock_info =~ / mtime: (\d+)$/;
utime $mtime, $mtime, $file_name;

test_check_lock({
  ourlockinfo       => 'locked ' . $lock_info,
  expected_result   => "opened by us ignoring a lock $lock_info, who released the lock without making any changes",
  test_msg          => 'check_lock(): empty lock file, ourlockinfo starts with \'locked\', file not changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

test_check_lock({
  ourlockinfo       => $lock_info,
  expected_result   => "originally locked by us but the lock was stolen from us by an unknown thief. The file seems unchanged",
  test_msg          => 'check_lock(): empty lock file, ourlockinfo does not starts with \'locked\', file not changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

note("File modified");
# file's modification time changed
$time = time();
utime $time, $time, $file_name;

test_check_lock({
  ourlockinfo       => 'locked ' . $lock_info,
  expected_result   => "opened by us ignoring a lock $lock_info who released the lock, but the file has changed since",
  test_msg          => 'check_lock(): empty lock file, ourlockinfo starts with \'locked\', file changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

test_check_lock({
  ourlockinfo       => $lock_info,
  expected_result   => "changed by another program and our lock was removed",
  test_msg          => 'check_lock(): empty lock file, ourlockinfo does not starts with \'locked\', file changed',
  fsfile            => $fsfile,
  file_name         => $file_name,
});

done_testing();
