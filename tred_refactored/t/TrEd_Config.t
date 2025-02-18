#!/usr/bin/env perl
# tests for TrEd::Config

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use File::Spec;
use File::Find;
use Cwd;
use TrEd::Utils qw(find_win_home uniq);

#use Data::Dumper;
use Tk qw{};

use Test::More;

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
sub test_set_default_config_file_search_list {
  my $tredhome_backup = $ENV{"TREDHOME"}; 
  $ENV{'TREDHOME'} = "$FindBin::Bin/../tredlib";
  
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
  foreach my $file_name (@TrEd::Config::config_file_search_list) {
    my $fh;
    note("$file_name\n");
    if (defined($file_name) and open($fh,'<',$file_name)) {
      close($fh);
      $config_found = 1;
      last;
    }
  }
  
  ok($config_found == 1, "set_default_config_file_search_list(): config file found and opened sucessfully");
  
  $ENV{'TREDHOME'} = $tredhome_backup;
}

#############################################################
####### Test read_config() and parse_config_line()
#############################################################
sub test_read_parse_config {
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
      'one::tWo'              =>  "one_two",
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
      'one::tWo'              =>  "one_two",
    );
    
    if ($config_fh) {
      print $config_fh "; this is a comment\n";
      print $config_fh "# this is a comment\n";
      foreach my $key (keys(%input_hash)){
        print $config_fh $key . " =  " . $input_hash{$key} . "\n";
      };
      close($config_fh);
    }
    # if sth bails out, we should remove the dummy config file we've created, so eval tests
    eval {
      my $cur_dir = getcwd();
      my $config_file_path = File::Spec->catfile($cur_dir, $dummy_config);
      
      my $used_config = read_config($config_file_path);
      like( $used_config,
            qr/$dummy_config/, 
            "read_config(): Read supplied config file");

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
        is($one::tWo,                               $control_hash{'one::tWo'},
        "read_config(): name with ::");
    };
    unlink($dummy_config);
  }
  @TrEd::Config::config_file_search_list = ();
  is(read_config(), undef, 
      "read_config(): return undef if no config file found");
    
}

sub test_tilde_expand {
  my %test_hash = (
    "~/directory/one" => $ENV{HOME} . "/directory/one",
    "abc~/dir/two"    => "abc" . $ENV{HOME} . "/dir/two",
  );
  foreach my $input (keys(%test_hash)){
    is(TrEd::Config::tilde_expand($input), $test_hash{$input}, 
      "tilde_expand(): expand tilde correctly");
  }
}

sub test_apply_config {
  my @config_options = (
    "vlineheight = value1",
    "vlinealign = value2",
    ";vlinewrap = ignored",
  );
  is(TrEd::Config::apply_config(@config_options), undef,
    "apply_config(): return value");
    
  is($TrEd::Config::valueLineHeight, "value1",
    "apply_config(): value1 set correctly");
  
  is($TrEd::Config::valueLineAlign, "value2",
    "apply_config(): value2 set correctly");
    
  isnt($TrEd::Config::valueLineWrap, "ignored",
    "apply_config(): comment should be ignored");
}

sub test_val_or_def {
  my %confs = (
    "width"   => 50,
  );
  
  is(TrEd::Config::val_or_def(\%confs, "width", 100), 50, 
    "val_or_def(): value from hash preferred");
    
  is(TrEd::Config::val_or_def(\%confs, "height", 100), 100, 
    "val_or_def(): default value chosen if it does not exist in hash");
  
}

sub test__parse_cmdline_options {
  my %confs = (
    "name1"       => "value1",
    "urls"        => "http://www.url1.com http://www.url2.com http://www.url1.com",
    "zero-length" => "",
  );
  my %expected_confs = %confs;
  
  $TrEd::Config::override_options = undef;
  is(TrEd::Config::_parse_cmdline_options(\%confs), undef, 
    "_parse_cmdline_options(): return value if there were no options specified");
  
  is_deeply(\%confs, \%expected_confs, 
    "_parse_cmdline_options(): configuration hash not modified");
  
  $TrEd::Config::override_options = [
    "name1=value2",
    "Name::SubName=value3",
    "NewName=value4",
    "zero-length\\t-=value5",
    "zero-length\\t=value6",
    "urls\\s+=http://www.newurl.com",
    "urls\\s-=http://www.url1.com",
    "urls\\s=http://www.prependedurl.com",
  ];
  
  %expected_confs = (
    "name1"         => "value2", #overwrite existing value
    "Name::SubName" => "value3", #add new value with '::' do not lowercase it
    "newname"       => "value4", #add new value without '::' -> lowercase
    "zero-length"   => "value6", #prepend new value
    "urls"          => "http://www.prependedurl.com http://www.url2.com http://www.newurl.com"
  );
  
  is(TrEd::Config::_parse_cmdline_options(\%confs), undef, 
    "_parse_cmdline_options(): return value OK");
    
  is_deeply(\%confs, \%expected_confs, 
    "_parse_cmdline_options(): configuration changed accoridng to command-line options");
  
}

sub test__set_treeViewOpts {
  my @treeViewOpts = qw(
    backgroundColor backgroundImage backgroundImageX backgroundImageY
    balanceTree baseXPos baseYPos boxColor clearTextBackground columnSep
    currentBoxColor currentEdgeBoxColor currentNodeColor
    currentNodeHeight currentNodeWidth customColors dashHiddenLines
    displayMode drawBoxes drawEdgeBoxes drawFileInfo drawSentenceInfo
    edgeBoxColor edgeLabelSkipAbove edgeLabelSkipBelow font
    hiddenBoxColor hiddenEdgeBoxColor hiddenLineColor hiddenNodeColor
    highlightAttributes horizStripe labelSep lineArrow lineArrowShape
    lineColor lineDash lineSpacing lineWidth nearestNodeColor noColor
    nodeColor nodeHeight nodeOutlineColor nodeWidth nodeXSkip nodeYSkip
    reverseNodeOrder showHidden skipHiddenLevels skipHiddenParents
    stripeColor textColor textColorHilite textColorShadow
    textColorXHilite useAdditionalEdgeLabelSkip useFSColors vertStripe
    verticalTree xmargin ymargin
  );
  
  my %confs = (
    "xmargin"         => 10,  # try to set new value
    "linespacing"     => 1.5, # try lowercased value
    "displaymode"     => 1,   # try overwrite existing value
    "customcolor8"    => 'overwritten',  # try to overwrite color
    "customcolor10"   => 'newColor',     # try to add new color
    "userName"        => 'value',        # try to set user configuration
    "backgroundimage" => 'tred.ico',     # try setting a background image
  );
  
  my %expected_treeViewOpts = %$TrEd::Config::treeViewOpts;
  $expected_treeViewOpts{"xmargin"} = 10;
  $expected_treeViewOpts{"lineSpacing"} = 1.5;
  $expected_treeViewOpts{"displayMode"} = 1;
  
  # we also need to tweak up nodeHaight and nodeWidth
  $TrEd::Config::treeViewOpts->{'nodeHeight'} = 1;
  $TrEd::Config::treeViewOpts->{'nodeWidth'}  = 1;
  
  # so that currentNodeHeight and -Width are set to nodeHeight/Width + 2 (no idea why + 2)
  $expected_treeViewOpts{"nodeHeight"} = 1;
  $expected_treeViewOpts{"nodeWidth"}  = 1;
  $expected_treeViewOpts{"currentNodeHeight"} = 3;
  $expected_treeViewOpts{"currentNodeWidth"}  = 3;
  
  $TrEd::Config::font = 'newFont';
  $expected_treeViewOpts{'font'}  = 'newFont';
  
  $TrEd::Config::libDir = "$FindBin::RealBin/../tredlib";
  $expected_treeViewOpts{'backgroundImage'}  = $TrEd::Config::libDir . '/' . 'tred.ico';
  
  ##RUN
  TrEd::Config::_set_treeViewOpts(\%confs);
  is_deeply($TrEd::Config::treeViewOpts, \%expected_treeViewOpts, 
    "_set_treeViewOpts(): set all the options correctly");
  
  # undefined background image
  $confs{"backgroundimage"} = undef;
  $expected_treeViewOpts{'backgroundImage'} = undef;
  
  ##RUN
  TrEd::Config::_set_treeViewOpts(\%confs);
  is_deeply($TrEd::Config::treeViewOpts, \%expected_treeViewOpts, 
    "_set_treeViewOpts(): and set also the background");

}

sub test__set_font_encoding {
  my $outputenc_backup = $TrEd::Convert::outputenc;
  $TrEd::Convert::outputenc = undef;
  is(TrEd::Config::_set_font_encoding(), $Tk::VERSION < 804 ? "iso8859-2" : "iso10646-1", 
    "_set_font_encoding(): return correct encoding if no outputenc is defined");
  
  
  $TrEd::Convert::outputenc = 'utf8';
  is(TrEd::Config::_set_font_encoding(), $TrEd::Convert::outputenc, 
    "_set_font_encoding(): return correct encoding if outputenc is defined");
  
  # set original value back
  $TrEd::Convert::outputenc = $outputenc_backup;
}


sub test__set_fonts {
  # other encoding
  $TrEd::Convert::outputenc = 'utf8';
  is(TrEd::Config::_set_fonts({}), undef, 
    "_set_fonts(): return value");
  
  is($TrEd::Config::font, '-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-' . $TrEd::Convert::outputenc, 
    "_set_fonts(): set font if no font is set in configuration");
    
  is($TrEd::Config::vLineFont, '-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-' . $TrEd::Convert::outputenc, 
    "_set_fonts(): set vLineFont if no vlinefont is set in configuration");
    
  is($TrEd::Config::guiFont, undef, 
    "_set_fonts(): set guiFont if no guifont is set in configuration");
  
  for my $name (qw(small small_bold heading fixed default bold italic)) {
    is($TrEd::Config::c_fonts{$name}, undef, 
    "_set_fonts(): set c_fonts{$name} if no guifont_$name is set in configuration");
  }
  
  # encoding iso-10646-1
  $TrEd::Convert::outputenc = 'iso-10646-1';
  TrEd::Config::_set_fonts({});
  
  is($TrEd::Config::font, '{Arial Unicode Ms} 10', 
    "_set_fonts(): set font if no font is set in configuration");
    
  is($TrEd::Config::vLineFont, '{Arial Unicode Ms} 10', 
    "_set_fonts(): set vLineFont if no vlinefont is set in configuration");
    
  is($TrEd::Config::guiFont, undef, 
    "_set_fonts(): set guiFont if no guifont is set in configuration");
  
  for my $name (qw(small small_bold heading fixed default bold italic)) {
    is($TrEd::Config::c_fonts{$name}, undef, 
    "_set_fonts(): set c_fonts{$name} if no guifont_$name is set in configuration");
  }
  
  # setting font from %confs
  my %confs = (
    'font'          => "-*-arial-*-*",
    'vlinefont'     => "-*-vlinefont-*-*",
    'guifont'       => "-*-guifont-*-*",
    'guifont_small' => "-*-guifont-small-*-*",
  );
  TrEd::Config::_set_fonts(\%confs);
  
  is($TrEd::Config::font, '-*-arial-iso10646-1', 
    "_set_fonts(): set font if font is set in configuration");
    
  is($TrEd::Config::vLineFont, $confs{'vlinefont'}, 
    "_set_fonts(): set vLineFont if vlinefont is set in configuration");
    
  is($TrEd::Config::guiFont, $confs{'guifont'}, 
    "_set_fonts(): set guiFont if guifont is set in configuration");
  
  is($TrEd::Config::c_fonts{'small'}, $confs{'guifont_small'}, 
    "_set_fonts(): set c_fonts{small} if guifont_small is set in configuration");
  
  for my $name (qw(small_bold heading fixed default bold italic)) {
    is($TrEd::Config::c_fonts{$name}, undef, 
    "_set_fonts(): set c_fonts{$name} if guifont_$name is set in configuration");
  }
}

sub test__set_resource_path {
  my $separator = ($^O eq "MSWin32") ? ',' : ':';
  my $default_share_dir = "/home/john/share/tred";
  $Treex::PML::resourcePath = "/home/john/.tred.d/" . $separator . "/home/john/.local/.tred.d/";
  
  my $home_backup = $ENV{HOME};
  $ENV{HOME} = "/home/john";
  
  my $default_resource_path = $ENV{HOME} . "/.tred.d" . $separator . $default_share_dir;
  my $expected_res_path = join($separator, ($default_resource_path, $Treex::PML::resourcePath));
  
  TrEd::Config::_set_resource_path({}, $default_share_dir);
  is($Treex::PML::resourcePath, $expected_res_path,
    "_set_resource_path(): set Treex::PML::resourcePath correctly");
  
  # init Treex::PML::resourcePath again
  $Treex::PML::resourcePath = "/home/john/.tred.d/" . $separator . "/home/john/.local/.tred.d/";
  # resourcepath in configuration set
  my %confs = (
    'resourcepath'  => $separator ."~/.tred.d/" . $separator . "~/tred.resources" . $separator,
  );
  # another kind of share dir -- does not end with "/share/tred"
  $default_share_dir = "/home/tred/";
  
  # prepare expected results
  $default_resource_path = $ENV{HOME} . "/.tred.d" . $separator . "${default_share_dir}resources";
  my $conf_res_paths = $ENV{HOME} . "/.tred.d/" . $separator . $ENV{HOME} . "/tred.resources";
  $expected_res_path = join($separator, ($default_resource_path, $conf_res_paths, $Treex::PML::resourcePath));
  my @expected_paths = sort(TrEd::Utils::uniq(split($separator, $expected_res_path)));
  
  TrEd::Config::_set_resource_path(\%confs, $default_share_dir);
  my @got_paths = sort(split($separator, $Treex::PML::resourcePath));
  is_deeply(\@got_paths, \@expected_paths, 
    "_set_resource_path(): set Treex::PML::resourcePath correctly when configuration is set");
  
  $ENV{HOME} = $home_backup;
}

sub _compare_print_options {
  my ($confs_ref, $expected_printOptions_ref, $msg) = @_;
  if(!defined($msg)) {
    $msg = "";
  }
  
  TrEd::Config::_set_print_options($confs_ref);
  
  my $ttf_font_found = 0;
  
  # look for *.ttf files in directories from ttFontPath
  find( sub { if($_ =~ /\.ttf$/i) { $ttf_font_found = 1 } }, 
        split(/,/, $TrEd::Config::printOptions->{'ttFontPath'}) );
  
  is($ttf_font_found, 1, 
    "_set_print_options(): TTF fonts found; $msg");
  
  # We've already tested ttFontPath and if we don't want to copy the same logic as _set_print_options
  # uses, we just set ttFontPath to undef 
  $TrEd::Config::printOptions->{'ttFontPath'} = undef;
  
  is_deeply($TrEd::Config::printOptions, $expected_printOptions_ref, 
    "_set_print_options(): set fonts correctly according to configuration hash; $msg");
}

sub test__set_print_options {
  # we need this default options, they are used in printOptions
  my %defaultPrintConfig = (
    printOnePerFile => ['-oneTreePerFile',0],
    printTo => [undef,'printer'],
    printFormat => ['-format','PS'],
    printFileExtension => [undef,'ps'],
    printSentenceInfo => ['-sentenceInfo', 0],
    printFileInfo => ['-fileInfo', 0],
    printImageMagickResolution => ['-imageMagickResolution', 80],
    printNoRotate=> ['-noRotate',0],
    printColors => ['-colors', 1],
    ttFont=> ['-ttFontName',"Arial"],
    ttFontPath => ['-ttFontPath', undef],
    psFontFile => ['-psFontFile', undef],
    psFontAFMFile => ['-psFontAFMFile', undef],
    psFontSize => ['-fontSize', (($^O=~/^MS/) ? 14 : 12)],
    prtFmtWidth => ['-fmtWidth', 595],
    prtFmtHeight => ['-fmtHeight', 842],
    prtVMargin => ['-vMargin', '3c'],
    prtHMargin => ['-hMargin', '2c'],
    psMedia => ['-psMedia', 'A4'],
    psFile => [undef, undef],
    maximizePrintSize => ['-maximize', 0],
    defaultPrintCommand => ['-command', (($^O eq 'MSWin32') ? 'prfile32.exe /-' : 'lpr')],
  );
  
  # change one string and one numeric value (overwrite defaults)
  my %confs = (
    'defaultprintcommand' => 'other_print',
    'printsentenceinfo'   => 1,
  );
  
  # construct expected printOptions hash
  my %expected_printOptions;
  foreach my $opt_name (keys(%defaultPrintConfig)) {
    $expected_printOptions{$opt_name} = $defaultPrintConfig{$opt_name}->[1];
  };
  
  $expected_printOptions{'defaultPrintCommand'} = 'other_print';
  $expected_printOptions{'printSentenceInfo'} = 1;
  
  # find out the default font
  $TrEd::Config::libDir = "$FindBin::Bin/../tredlib";
  my $default_font; 
  if (!defined($Tk::VERSION) or $Tk::VERSION >= 804) {
    $default_font = "n019003l.pfa";
  } 
  else {
    $default_font = "ariam___.pfa";
  }
  
  
  # psFontFile
  #
  ## 1) psFontFile defined in $printOptions 
  ### a) length = 0; 
  $confs{'psfontfile'} = "";
  $expected_printOptions{'psFontFile'} = "$TrEd::Config::libDir/fonts/$default_font";
  
  # find out expected AFM font
  my $AFM_font = "$TrEd::Config::libDir/fonts/$default_font";
  $AFM_font =~ s/\.pfa/\.afm/;
  
  if (-f $AFM_font) {
    $expected_printOptions{'psFontAFMFile'} = $AFM_font;
  } 
  else {
    $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
  }
  
  _compare_print_options(\%confs, \%expected_printOptions, "psFontFile defined, but length = 0");
  
  ### b) $confs{'psFontFile'} pointing to existing file 
  my $fake_font_name = "fake_font.pfa";
  my $fake_font_created = open(my $fake_font, '>', $fake_font_name);
  
  $AFM_font = $fake_font_name;
  $AFM_font =~ s/\.pfa/\.afm/;
  my $fake_AFM_created = open(my $fake_AFM, '>', $AFM_font);
  
  if($fake_font_created and $fake_AFM_created) {
    ## here is the difference between the previous and current test case
    $confs{'psfontfile'} = $fake_font_name;
    $expected_printOptions{'psFontFile'} = $fake_font_name;
    
    if (-f $AFM_font) {
      $expected_printOptions{'psFontAFMFile'} = $AFM_font;
    } 
    else {
      $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
    }
    # in case of death, we have to clean up files we've created
    eval {
      _compare_print_options(\%confs, \%expected_printOptions, "psfontfile pointing to existing file");
    };
    unlink($fake_AFM);
    unlink($fake_font);
  }
  
  ### c) existing, but must add $libDir before -> psFontFile = $libDir/fonts/n019003l.pfa
  $confs{'psfontfile'} = "fonts/$default_font";
  $expected_printOptions{'psFontFile'} = "$TrEd::Config::libDir/" . $confs{'psfontfile'};
  
  # find out expected AFM font
  $AFM_font = "$TrEd::Config::libDir/" . $confs{'psfontfile'};
  $AFM_font =~ s/\.pfa/\.afm/;
  if (-f $AFM_font) {
    $expected_printOptions{'psFontAFMFile'} = $AFM_font;
  } 
  else {
    $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
  }
  
  _compare_print_options(\%confs, \%expected_printOptions, "psfontfile pointing to existing file, but libDir must be prepended");
  
  ### d) file that does not exist and adding $libDir does not help neither
  $confs{'psfontfile'} = "fonts/non_existing_font.pfa";
  $expected_printOptions{'psFontFile'} = $confs{'psfontfile'};
  
  # find out expected AFM font
  $expected_printOptions{'psFontAFMFile'} = "fonts/afm/non_existing_font.afm";
  
  _compare_print_options(\%confs, \%expected_printOptions, "psfontfile pointing to file that does not exist");
  
  
  ## 2) psFontFile not defined
  $confs{'psfontfile'} = undef;
  
  $expected_printOptions{'psFontFile'} = "$TrEd::Config::libDir/fonts/$default_font";
  
  # find out expected AFM font
  $AFM_font = "$TrEd::Config::libDir/fonts/$default_font";
  $AFM_font =~ s/\.pfa/\.afm/;
  
  if (-f $AFM_font) {
    $expected_printOptions{'psFontAFMFile'} = $AFM_font;
  } 
  else {
    $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
  }
  
  _compare_print_options(\%confs, \%expected_printOptions, "psFontFile defined, but length = 0");
  
  
  # psFontAFMFile
  #
  ## 1) psFontAFMFile defined in $printOptions
  ### a) length = 0;
  $confs{'psfontafmfile'} = "";
  $confs{'psfontfile'} = undef;
  
  $expected_printOptions{'psFontFile'} = "$TrEd::Config::libDir/fonts/$default_font";
  
  # find out expected AFM font
  $AFM_font = "$TrEd::Config::libDir/fonts/$default_font";
  $AFM_font =~ s/\.pfa/\.afm/;
  
  if (-f $AFM_font) {
    $expected_printOptions{'psFontAFMFile'} = $AFM_font;
  } 
  else {
    $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
  }
  
  _compare_print_options(\%confs, \%expected_printOptions, "psFontFile defined, but length = 0");
  
  ### b) existing as is
  $confs{'psfontfile'} = undef;
  $expected_printOptions{'psFontFile'} = "$TrEd::Config::libDir/fonts/$default_font";
  
  
  # find out expected AFM font
  $AFM_font = "$TrEd::Config::libDir/fonts/$default_font";
  $AFM_font =~ s/\.pfa/\.afm/;
  $confs{'psfontafmfile'} = $AFM_font;
  
  if (-f $AFM_font) {
    $expected_printOptions{'psFontAFMFile'} = $AFM_font;
  } 
  else {
    $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
  }
  
  _compare_print_options(\%confs, \%expected_printOptions, "psFontFile defined, but length = 0");
  
  # c) existing, but must add $libDir before
  $confs{'psfontfile'} = undef;
  $expected_printOptions{'psFontFile'} = "$TrEd::Config::libDir/fonts/$default_font";
  
  
  # find out expected AFM font
  $AFM_font = "fonts/$default_font";
  $AFM_font =~ s/\.pfa/\.afm/;
  $confs{'psfontafmfile'} = $AFM_font;
  
  if (-f $AFM_font) {
    $expected_printOptions{'psFontAFMFile'} = $AFM_font;
  } 
  else {
    $expected_printOptions{'psFontAFMFile'} = "$TrEd::Config::libDir/$AFM_font";
  }
  
  _compare_print_options(\%confs, \%expected_printOptions, "psFontFile defined, but length = 0");
  
  
  ## these have been already tried when testing psFontFile
  ## 2) psFontAFMFile not defined
  ### a) psFontFile with afm ending is in the same dir
  ### b) is in afm subdir (undefining Tk::VERSION should be enough for this)
}

sub test__set_extensions {
  my $default_repos = join "\n",
                      'http://ufal.mff.cuni.cz/tred/extensions/core/',
                      'http://ufal.mff.cuni.cz/tred/extensions/external/';
  # 1 -- $confs_ref->{extensionsdir}'s length = 0
  my %confs = (
    'extensionsdir' => "",
  );
  my $default_share_path = "/home/john/share";
  
  my $expected_extensionsDir = $ENV{'HOME'} . "/.tred.d/extensions";
  my $expected_extensionsRepos = $default_repos;
  my $expected_preinstalledExtDir = File::Spec->catdir($default_share_path, 'tred-extensions');
  
  TrEd::Config::_set_extensions(\%confs, $default_share_path);
  
  is($TrEd::Config::extensionsDir, $expected_extensionsDir, 
    "_set_extensions(): default extensionsDir set correctly");
  
  is($TrEd::Config::extensionRepos, $expected_extensionsRepos, 
    "_set_extensions(): default extensionsRepos set correctly");
  
  is($TrEd::Config::preinstalledExtensionsDir, $expected_preinstalledExtDir, 
    "_set_extensions(): default preinstalledExtensionsDir set correctly");
  
  # 2 -- $confs_ref->{extensionsdir}'s length > 0
  %confs = (
    'extensionsdir' => "/home/john/extensions",
  );
  
  $expected_extensionsDir = "/home/john/extensions";
  $expected_extensionsRepos = $default_repos;
  $expected_preinstalledExtDir = File::Spec->catdir($default_share_path, 'tred-extensions');
  
  TrEd::Config::_set_extensions(\%confs, $default_share_path);
  
  is($TrEd::Config::extensionsDir, $expected_extensionsDir, 
    "_set_extensions(): extensionsDir set correctly from config");
  
  is($TrEd::Config::extensionRepos, $expected_extensionsRepos, 
    "_set_extensions(): default extensionsRepos set correctly");
  
  is($TrEd::Config::preinstalledExtensionsDir, $expected_preinstalledExtDir, 
    "_set_extensions(): default preinstalledExtensionsDir set correctly");
  
  
  # 3 -- $confs_ref->{extensionrepos} is set
  my $repository = "/home/john/extensions/repository";
  %confs = (
    'extensionrepos' => $repository,
  );
  
  $expected_extensionsDir = $ENV{'HOME'} . "/.tred.d/extensions";
  $expected_extensionsRepos = $repository;
  $expected_preinstalledExtDir = File::Spec->catdir($default_share_path, 'tred-extensions');
  
  TrEd::Config::_set_extensions(\%confs, $default_share_path);
  
  is($TrEd::Config::extensionsDir, $expected_extensionsDir, 
    "_set_extensions(): default extensionsDir set correctly");
  
  is($TrEd::Config::extensionRepos, $expected_extensionsRepos, 
    "_set_extensions(): extensionsRepos set correctly from config");
  
  is($TrEd::Config::preinstalledExtensionsDir, $expected_preinstalledExtDir, 
    "_set_extensions(): default preinstalledExtensionsDir set correctly");
  
  # 4 -- $confs_ref->{extensionrepos} is not set -- already tested
  
  # 5 -- $confs_ref->{preinstalledextensionsdir}'s length != 0
  my $preinstalled_ext_dir = "/home/john/preinstalled/extensions";
  %confs = (
    'preinstalledextensionsdir' => $preinstalled_ext_dir,
  );
  
  $expected_extensionsDir = $ENV{'HOME'} . "/.tred.d/extensions";
  $expected_extensionsRepos = $default_repos;;
  $expected_preinstalledExtDir = $preinstalled_ext_dir;
  
  TrEd::Config::_set_extensions(\%confs, $default_share_path);
  
  is($TrEd::Config::extensionsDir, $expected_extensionsDir, 
    "_set_extensions(): default extensionsDir set correctly");
  
  is($TrEd::Config::extensionRepos, $expected_extensionsRepos, 
    "_set_extensions(): default extensionsRepos set correctly");
  
  is($TrEd::Config::preinstalledExtensionsDir, $expected_preinstalledExtDir, 
    "_set_extensions(): preinstalledExtensionsDir set correctly from config");
    
  # 6 -- $confs_ref->{preinstalledextensionsdir}'s length = 0 && $def_share_path =~ m{/share/tred$}
  $default_share_path = "/home/john/share/tred";
  %confs = (
    'preinstalledextensionsdir' => "",
  );
  
  $expected_extensionsDir = $ENV{'HOME'} . "/.tred.d/extensions";
  $expected_extensionsRepos = $default_repos;;
  $expected_preinstalledExtDir = $default_share_path . '-extensions';
  
  TrEd::Config::_set_extensions(\%confs, $default_share_path);
  
  is($TrEd::Config::extensionsDir, $expected_extensionsDir, 
    "_set_extensions(): default extensionsDir set correctly");
  
  is($TrEd::Config::extensionRepos, $expected_extensionsRepos, 
    "_set_extensions(): default extensionsRepos set correctly");
  
  is($TrEd::Config::preinstalledExtensionsDir, $expected_preinstalledExtDir, 
    "_set_extensions(): preinstalledExtensionsDir set correctly from default share path");
  
  # 7 -- $confs_ref->{preinstalledextensionsdir}'s length = 0 && not ($def_share_path =~ m{/share/tred$}) -- already tested
  
}

####################
#### Run tests #####
####################

# we need to set HOME env variable also on Windows at least for tilde_expand() and _set_resource_path();
TrEd::Utils::find_win_home();

test_set_default_config_file_search_list();
test_read_parse_config();
test_tilde_expand();
test_apply_config();
test_val_or_def();
test__parse_cmdline_options();
test__set_treeViewOpts();
test__set_font_encoding();
test__set_fonts();
test__set_resource_path();
test__set_print_options();
test__set_extensions();

done_testing();