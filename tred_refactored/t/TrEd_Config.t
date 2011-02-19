#!/usr/bin/env perl
# tests for TrEd::Config

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use File::Spec;
use Cwd;

use Test::More 'no_plan';#tests => 19;

BEGIN {
  my $module_name = 'TrEd::Config';
  our @subs = qw(
    read_config
    apply_config
    set_default_config_file_search_list
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);

{
  no warnings "once";
  $TrEd::Config::quiet = 1;
}

#############################################################
####### Test set_default_config_file_search_list()
#############################################################
set_default_config_file_search_list();
# test that at least sth is set
ok(scalar(@TrEd::Config::config_file_search_list) > 0, "set_default_config_file_search_list(): config_file_search_list not empty");
# tredrc string should be in the first element of the array
like( $TrEd::Config::config_file_search_list[0], 
      qr/tredrc/,
      "set_default_config_file_search_list(): config_file_search_list contains path to tredrc");

# test if a tredrc can be found and opened 
# (since it is in tredlib directory in svn, we're able to test it)
my $config_found = 0;
foreach my $f (@TrEd::Config::config_file_search_list) {
  my $fh;
  if (defined($f) and open($fh,'<',$f)) {
    close($fh);
    $config_found = 1;
    last;
  }
}
ok($config_found == 1, "set_default_config_file_search_list(): config file found and opened sucessfully");

#############################################################
####### Test read_config()
#############################################################
SKIP: {
  my $dummy_config = "test_tredrc";
  my $config_fh;

  skip "Could not create dummy config file", 15 if !(open($config_fh, ">", $dummy_config));
  my $comment1 = "; this is a comment = should not be taken into account"; 
  my $comment2 = "# this is another comment = also shouldn't be in result";
  
  ##TODO: toto sa asi nesprava dobre (v povodnom programe), 
  ## mozno vymysli novy reg exp
  my %input_hash = (
    # double quoted tests:
    'hintWait'              =>  '"aba"',
    'hintForeground'        =>  '"ab\\"',
    '0not_Accepted_key'     =>  "does not matter",
    'hintBackgROund'        =>  '"\\"a"',
    # signle quoted tests:
    'toolbarhintwait'       =>  "'aa''",
    'toolbarhintforeground' =>  "'aa;b",
    'toolbarhintbackground' =>  "'a\\'a", # one backslash
    'activetextcolor'       =>  "'a;;'",
    'stippleinactivewindows'=>  "'a\\\\\\", # 3 backslashes
    'highlightwindowcolor'  =>  "';a\\'",
    # unquoted tests:    
    'highlightwindowwidth'  =>  "ba;aa",
    'vlineheight'           =>  "b'\\a'", # one backslash, should be eaten?
    'vlinealign'            =>  "b\\;ab", # one backslash, cancel commentary
    'vlinewrap'             =>  "bab\\ ", # one backslash, leave escaped whitespace
    'vlinereverselines'     =>  "c:\\\\documents and settings\\\\space in folder name is a great invention\\\\my file.txt",
  ); 
  
  my %control_hash = (
    # double quoted tests:
    'hintwait'              =>  "aba",
    'hintforeground'        =>  "ab",
    'hintbackground'        =>  '"a',
    # signle quoted tests:
    'toolbarhintwait'       =>  "aa",
    'toolbarhintforeground' =>  "'aa",
    'toolbarhintbackground' =>  "'a'a",
    'activetextcolor'       =>  "a;;",
    'stippleinactivewindows'=>  "'a\\", # just one backslash
    'highlightwindowcolor'  =>  "'",
    # unquoted tests:
    'highlightwindowwidth'  =>  "ba",
    'vlineheight'           =>  "b'a'",
    'vlinealign'            =>  "b;ab",
    'vlinewrap'             =>  "bab ",
    'vlinereverselines'     =>  "c:\\documents and settings\\space in folder name is a great invention\\my file.txt",
  );
  
  print $config_fh "; this is a comment\n";
  print $config_fh "# this is a comment\n";
  foreach my $key (keys(%input_hash)){
    print $config_fh $key . " =  " . $input_hash{$key} . "\n";
  };
  close($config_fh);
  
  my $cur_dir = getcwd();
  my $config_file_path = File::Spec->catfile($cur_dir, $dummy_config);
  
  my $used_config = read_config($config_file_path);
  like( $used_config,
        qr/$dummy_config/, 
        "read_config(): Read supplied config file");
  {
    no warnings "once";
    # 3 double quoted string tests:
    is($TrEd::Config::canvasBalloonInitWait,    $control_hash{'hintwait'}, 
    "read_config(): using double quotes in config file");
    is($TrEd::Config::canvasBalloonForeground,  $control_hash{'hintforeground'},
    "read_config(): escaping double quote at the end of double-quoted string");
    is($TrEd::Config::canvasBalloonBackground,  $control_hash{'hintbackground'},
    "read_config(): escaping double quote in the middle of double-quoted string");
    # 6 single quoted string tests:
    is($TrEd::Config::toolbarBalloonInitWait,   $control_hash{'toolbarhintwait'},
    "read_config(): using single quotes in config file, ignore other text");
    is($TrEd::Config::toolbarBalloonForeground, $control_hash{'toolbarhintforeground'},
    "read_config(): commentary with unpaired single quote");
    is($TrEd::Config::toolbarBalloonBackground, $control_hash{'toolbarhintbackground'},
    "read_config(): escaping single quote in the middle of single-quoted string");
    is($TrEd::Config::activeTextColor,          $control_hash{'activetextcolor'},
    "read_config(): don't treat comments in quotes as comments");
    is($TrEd::Config::stippleInactiveWindows,   $control_hash{'stippleinactivewindows'},
    "read_config(): 1 backslash from 3");
    is($TrEd::Config::highlightWindowColor,     $control_hash{'highlightwindowcolor'},
    "read_config(): don't let comments with quotes confuse us");
    # 5 unquoted string tests:
    is($TrEd::Config::highlightWindowWidth,     $control_hash{'highlightwindowwidth'},
    "read_config(): treat comments correctly");
    is($TrEd::Config::valueLineHeight,          $control_hash{'vlineheight'},
    "read_config(): eating one backslash");
    is($TrEd::Config::valueLineAlign,           $control_hash{'vlinealign'},
    "read_config(): escaped comment");
    is($TrEd::Config::valueLineWrap,            $control_hash{'vlinewrap'},
    "read_config(): don't delete escaped whitespace at the end");
    is($TrEd::Config::valueLineReverseLines,    $control_hash{'vlinereverselines'},
    "read_config(): windows path using spaces and backslashes");
  }
  
  unlink($dummy_config);
}

