#!/usr/bin/env perl
# tests for TrEd::File

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use lib "$FindBin::Bin/../tredlib/libs/tk";

use TrEd::Config;
#use TrEd::Utils;
use Treex::PML;

use TrEd::Window;

use Test::More;
use Test::Exception;
use Data::Dumper;
use Carp;

use List::Util; # max sub



BEGIN {
  our $module_name = 'TrEd::File';
  our @exported_subs = qw(
    dirname
    filename
  );
  use_ok($module_name, @exported_subs);
}

# test exported functions
our @exported_subs;
can_ok(__PACKAGE__, @exported_subs);


my @private_subs = qw(
    init_backends
    get_backends
    _insert_if_before_exists
    add_backend
    remove_backend
    get_openfiles
    _merge_status
    _new_status
    reload_on_usr2
    _related_files
    _fix_keep_option
    _is_among_primary_files
    _check_for_recovery_and_open
    _should_save_to_recent_files
    open_file
    open_standalone_file
    close_file
    reload_file
    load_file
    open_secondary_files
    close_all_files
    ask_save_file
    save_file
    new_file_from_current
    save_file_as
    do_save_file_as
    ask_save_references
    ask_save_files_and_close
    resume_file
    absolutize_path
    absolutize
    get_secondary_files
    get_secondary_files_recursively
    get_primary_files
    get_primary_files_recursively
);

# test non-exported functions
our $module_name;
can_ok($module_name, @private_subs);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');



my @backends=(
  'FS',
  ImportBackends(
    qw{NTRED
       Storable
       PML
       CSTS
       TrXML
       TEIXML
       PMLTransform
      })
);


### Initialize documents and load related documents recursively
sub _init_fsfile {
  my ($file_name) = @_;
  my $bck = \@backends;
  my $fsfile = Treex::PML::Factory->createDocumentFromFile(
    $file_name,
    {
      encoding => 'utf8',
      backends => $bck,
      recover => 1,
    });
  $fsfile->loadRelatedDocuments(1,sub {});
    # warning: this can be a looong Dump! uncomment only if you're brave enough
#    print Dumper($fsfile);
  return $fsfile;
}

sub test_absolutizePath {
  my $findbin = $FindBin::Bin;
  my @expected_paths = (
      # If the $filename is an absolute path or an absolute URL, it is returned umodified
      {
        "filename"        => "/home/even/though/it/does/not/exist",
        "ref_path"        => "",
        "search_res_path" => 0,
        "expected_result" => "file:///home/even/though/it/does/not/exist",
        "test_name"       => "Absolute filename 1",
      },
      {
        "filename"        => "file://etc/X11/xorg.conf",
        "ref_path"        => "",
        "search_res_path" => 0,
        "expected_result" => "file://etc/X11/xorg.conf",
        "test_name"       => "Absolute filename 2",
      },
      # If it is a relative path and $ref_path is a local path or a file:// URL,
      # the function tries to locate the file relatively to $ref_path and
      # if such a file exists, returns an absolute filename or file:// URL to the file.
      {
        "filename"        => "simple-macro.mac",
        "ref_path"        => "$findbin/test_macros",
        "search_res_path" => 0,
        "expected_result" => "file://$findbin/simple-macro.mac",
        "test_name"       => "Relative filename 1",
      },
      {
        "filename"        => "t/test_macros/include/../simple-macro.mac",
        "ref_path"        => "$findbin",
        "search_res_path" => 0,
        "expected_result" => "$findbin/test_macros/simple-macro.mac",
        "test_name"       => "Relative filename 2",
      },
      #this works strange
      {
        "filename"        => "simple-macro.mac",
        "ref_path"        => "file://$findbin/test_macros",
        "search_res_path" => 0,
        "expected_result" => "simple-macro.mac",
        "test_name"       => "Relative filename 3",
      },
      {
        "filename"        => "t/test_macros/include/../simple-macro.mac",
        "ref_path"        => "file://$findbin",
        "search_res_path" => 0,
        "expected_result" => "file://$findbin/test_macros/simple-macro.mac",
        "test_name"       => "Relative filename 4",
      },
    );
  my $i = 0;
  foreach my $hash (@expected_paths){
    is(TrEd::File::absolutize_path($hash->{'ref_path'}, $hash->{'filename'}, $hash->{'search_res_path'}), $hash->{'expected_result'},
      "absolutizePath(): " . $hash->{'test_name'});
  }
}

sub test_absolutize {
  my @input_array = (
    "     ",
    "  ",
    "/home/something/unusual",
    "x:/Documents and Settings/John",
    "t/test_macros/include/../simple-macro.mac",
  );

  my @expected_result = sort(
    "/home/something/unusual",
    "x:/Documents and Settings/John",
    $FindBin::Bin . "/test_macros/include/../simple-macro.mac",
  );

  my @got_result = sort(TrEd::File::absolutize(@input_array));

  is_deeply(\@got_result, \@expected_result,
    "absolutize(): create absolute paths");
}

sub test__related_files {
    my ($fsfile, $fsfile_2) = @_;

    my @pair_list = $fsfile->relatedDocuments();

    my @related_files = TrEd::File::_related_files($fsfile);

#    print Dumper(\@pair_list);
#    print Dumper(\@related_files);
    is("file://" . $related_files[0]->filename(), $pair_list[0]->[1],
        "_related_files(): file name agrees");

    my @expected_primary = $fsfile_2->relatedSuperDocuments();
    my @expected_secondary = $fsfile_2->relatedDocuments();
    my @expected_result = map { $_->[1] . "" } @expected_secondary;
    push @expected_result, map { $_->[0] . "" } @expected_primary;
    @expected_result = sort @expected_result;

    my @got_related_files = map { $_->[0] . "" } TrEd::File::_related_files($fsfile_2);
    @got_related_files = sort @got_related_files;
#    print Dumper(\@expected_result);
#    print Dumper(\@got_related_files);
    is_deeply(\@got_related_files, \@expected_result,
        "_related_files(): file names agree");
}

sub test__fix_keep_option {
    my ($fsfile) = @_;
    my $related_file_name = File::Spec->catfile($FindBin::Bin, "test_files", "sample0.x.gz");
    my %opts = (
        -keep           => 0,
        -keep_related   => 1,
    );
    TrEd::File::_fix_keep_option($fsfile, $related_file_name, \%opts);
    is($opts{-keep}, 1,
        "_fix_keep_option(): -keep option fixed for related file");

    my $unrelated_file_name = File::Spec->catfile($FindBin::Bin, "test_files", "other");;
    %opts = (
        -keep           => 0,
        -keep_related   => 1,
    );
    TrEd::File::_fix_keep_option($fsfile, $unrelated_file_name, \%opts);
    is($opts{-keep}, 0,
        "_fix_keep_option(): -keep option not changed for unrelated file");


    %opts = (
        -keep           => 1,
        -keep_related   => 1,
    );
    TrEd::File::_fix_keep_option($fsfile, $related_file_name, \%opts);
    is($opts{-keep}, 1,
        "_fix_keep_option(): -keep option still 1 for related file if it was 1");


    %opts = (
        -keep           => 0,
        -keep_related   => 0,
    );
    TrEd::File::_fix_keep_option($fsfile, $related_file_name, \%opts);
    is($opts{-keep}, 0,
        "_fix_keep_option(): -keep option still 0 if -keep_related is 0");
}

sub test_get_secondary_files {
  my ($fsfile) = @_;
  my @pair_list = $fsfile->relatedDocuments();

  my @secondary_files = TrEd::File::get_secondary_files($fsfile);

#  print Dumper(\@secondary_files);
  is("file://" . $secondary_files[0]->filename(), $pair_list[0]->[1],
    "get_secondary_files(): file name agrees");
}


sub test_get_secondary_files_recursively {
  my ($fsfile, $fsfile_2) = @_;

  # first level
  my @pair_list = $fsfile->relatedDocuments();
  my $file_1 = $pair_list[0]->[1];
  # load doc from second level

  @pair_list = $fsfile_2->relatedDocuments();
  my $file_2 = $pair_list[0]->[1];
  # construct expected file list
  my @expected_files = sort($file_1, $file_2);


  my @secondary_files_rec = sort( map { "file://" . $_->filename() } TrEd::File::get_secondary_files_recursively($fsfile) );

  is_deeply(\@secondary_files_rec, \@expected_files,
    "get_secondary_files_recursively(): find all files");

#  $Data::Dumper::Maxdepth = 2;

}

sub test_get_primary_files {
  my ($fsfile_2) = @_;
  my @expected_primary = $fsfile_2->relatedSuperDocuments();
  $Data::Dumper::Maxdepth = 2;
#  print Dumper(\@expected_primary);

  my @primary_files = TrEd::File::get_primary_files($fsfile_2);

#  print Dumper(\@primary_files);
  is_deeply(\@primary_files, \@expected_primary,
    "get_primary_files(): primary file found");
}

sub test__is_among_primary_files {
    my ($fsfile_3) = @_;

    my @expected_primary_files = sort(TrEd::File::get_primary_files_recursively($fsfile_3));

    is(TrEd::File::_is_among_primary_files("", undef), undef,
        "_is_among_primary_files(): return undef if no fsfile was defined");

    foreach my $file_name (map { $_->[0] . "" } @expected_primary_files) {
        my $primary_fsfile = TrEd::File::_is_among_primary_files($file_name, $fsfile_3);
        is('file://' . $primary_fsfile->filename(), $file_name,
            "_is_among_primary_files(): file found correctly ($file_name)");
    }
}

sub test_get_primary_files_recursively {
  my ($fsfile_2, $fsfile_3) = @_;
  my @expected_primary = $fsfile_3->relatedSuperDocuments();

  my @expected_primary_2 = $fsfile_2->relatedSuperDocuments();

  my @expected_primary_rec = sort(@expected_primary, @expected_primary_2);
  $Data::Dumper::Maxdepth = 2;
#  print Dumper(\@expected_primary_rec);

  my @primary_files_rec = sort(TrEd::File::get_primary_files_recursively($fsfile_3));

#  print Dumper(\@primary_files_rec);
  is_deeply(\@primary_files_rec, \@expected_primary_rec,
    "get_primary_files_recursively(): primary files found recursively");
}

# helper function to test removal of backends
sub _test_remove_backend {
    my ($backend_name, $expected_backends_ref) = @_;

    my @got_backends = TrEd::File::remove_backend($backend_name);
    is_deeply(\@got_backends, $expected_backends_ref,
        "remove_backend: removal of $backend_name backend");

    @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, $expected_backends_ref,
        "remove_backend && got_backends: $backend_name backend really removed");

}

# test manipulation with backends
sub test_backends {
    my @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, [],
        "get_backends: empty backends list at the beginning");

    TrEd::File::init_backends();

    my @expected_backends = qw(
        FS
        NTRED
        Storable
        PML
        CSTS
        TrXML
        TEIXML
        PMLTransform
    );
    @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, \@expected_backends,
        "init_backends: correct backends list after init");

    # test removing some backends
    foreach my $backend_name (qw{NTRED TrXML TEIXML}) {
        @expected_backends = grep { $_ ne $backend_name } @expected_backends;
        _test_remove_backend($backend_name, \@expected_backends);
    }

    # now add backends back, plus try to add one that does not exist

    # first, adding without specification of before parameter
    my $backend = 'NTRED';
    push @expected_backends, $backend;
    TrEd::File::add_backend($backend);
    @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, \@expected_backends,
        "add_backend: $backend added at the end of list");

    # Should add TrXML before Storable
    $backend = 'TrXML';
    my $before = 'Storable';
    # Storable now has index 1
    splice @expected_backends, 1, 0, ($backend);
    TrEd::File::add_backend($backend, $before);
    @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, \@expected_backends,
        "add_backend: $backend added before $before backend correctly");

    # Should add TEIXML before non-existing backend
    $backend = 'TEIXML';
    push @expected_backends, $backend;
    TrEd::File::add_backend($backend, 'non-existing');
    @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, \@expected_backends,
        "add_backend: $backend added at the end of list if before is not specified correctly");

    # we can also add backend that does not exist
    $backend = 'not-existing-backend';
    push @expected_backends, $backend;
    TrEd::File::add_backend($backend);
    @got_backends = TrEd::File::get_backends();
    is_deeply(\@got_backends, \@expected_backends,
        "add_backend: not existing backend ($backend) added at the end of list");
}


sub test_statuses {

    my %status1_cont = (
        ok          => 1,
        warnings    => ['warn_1_1', 'warn_1_2'],
        error       => 'no_error',
        report      => 'report_1',
    );

    my $status1 = TrEd::File::_new_status(%status1_cont);

    my %status2_cont = (
        ok          => 3,
        warnings    => ['warn_2_1', 'warn_2_2'],
        error       => 'error_3',
        report      => 'report_2',
    );

    my $status2 = TrEd::File::_new_status(%status2_cont);

    my %status3_cont = (
        ok          => 0,
        warnings    => ['warn_3_1', 'warn_3_2'],
        error       => 'error_0',
        report      => 'report_3',
    );

    my $status3 = TrEd::File::_new_status(%status3_cont);

    ## product of merging s1 and s1
    my %expected_status1_cont = (
        ok          => $status1->{ok},
        warnings    => [ @{$status1->{warnings}}, @{$status1->{warnings}} ],
        error       => $status1->{error} . "\n" . $status1->{error},
        report      => $status1->{report} . "\n" . $status1->{report},
    );

    my $expected_status1 = TrEd::File::_new_status(%expected_status1_cont);

    TrEd::File::_merge_status($status1, $status1);

    is_deeply($status1, $expected_status1,
        "_merge_status: merge two successful statuses");

    ## product of merging s1 and s2
    my %expected_status2_cont = (
        ok          => $status2->{ok},
        warnings    => [ @{$status1->{warnings}}, @{$status2->{warnings}} ],
        error       => $status1->{error} . "\n" . $status2->{error},
        report      => $status1->{report} . "\n" . $status2->{report},
    );

    my $expected_status2 = TrEd::File::_new_status(%expected_status2_cont);

    TrEd::File::_merge_status($status1, $status2);

    is_deeply($status1, $expected_status2,
        "_merge_status: merge one successful and one not successful status");

    ## product of merging s3 and s1

    # we need successful status once more, recreate original values
    $status1 = TrEd::File::_new_status(%status1_cont);

    my %expected_status3_cont = (
        ok          => $status3->{ok},
        warnings    => [ @{$status3->{warnings}}, @{$status1->{warnings}} ],
        error       => $status3->{error} . "\n" . $status1->{error},
        report      => $status3->{report} . "\n" . $status1->{report},
    );

    my $expected_status3 = TrEd::File::_new_status(%expected_status3_cont);

    TrEd::File::_merge_status($status3, $status1);

    is_deeply($status3, $expected_status3,
        "_merge_status: merge one unsuccessful and one successful status");

    ## finally, merge two not successful statuses -- s2 and s3
    my %expected_status4_cont = (
        ok          => List::Util::max($status2->{ok}, $status3->{ok}),
        warnings    => [ @{$status2->{warnings}}, @{$status3->{warnings}} ],
        error       => $status2->{error} . "\n" . $status3->{error},
        report      => $status2->{report} . "\n" . $status3->{report},
    );

    my $expected_status4 = TrEd::File::_new_status(%expected_status4_cont);

    TrEd::File::_merge_status($status2, $status3);

    is_deeply($status2, $expected_status4,
        "_merge_status: merge two unsuccessful statuses");

}

sub _test_init_app_data {
    my ($fsfile, $expected_appdata_ref) = @_;

    TrEd::File::init_app_data($fsfile);

    # test initialized fields
    foreach my $app_data_field (keys %{$expected_appdata_ref}) {
        is_deeply($fsfile->appData($app_data_field),
                  $expected_appdata_ref->{$app_data_field},
                  "init_app_data(): $app_data_field initialized correctly");
    }
}

sub test_init_app_data {
    my ($fsfile, $fsfile_2) = @_;

    my %expected_app_data = (
        'undostack'     => [],
        'undo'          => -1,
        'lockinfo'      => undef,
        'fs-part-of'    => [],
        'ref'           => $fsfile->appData('ref'),
    );


    _test_init_app_data($fsfile, \%expected_app_data);

    %expected_app_data = (
        'undostack'     => [],
        'undo'          => -1,
        'lockinfo'      => undef,
        'fs-part-of'    => $fsfile_2->appData('fs-part-of'),
        'ref'           => $fsfile_2->appData('ref'),
    );

    _test_init_app_data($fsfile_2, \%expected_app_data);
}

## create the illusion of main:
my %hooks_run = ();
sub doEvalHook {
    my ($win, $hook_name) = @_;

    if (exists $hooks_run{$hook_name}) {
        $hooks_run{$hook_name} = $hooks_run{$hook_name} + 1;
    }
    else {
        $hooks_run{$hook_name} = 1;
    }
    return;
}

# so it does not call Tk functions
our $insideEval = 1;

my $sub_update_title_and_buttons = 0;
my $sub_unhide_current_node = 0;
my $sub_get_nodes_win = 0;
my $sub_redraw_win = 0;
my $sub_center_to = 0;
my $sub_fsfileDisplayingWindows = 0;
my $sub_set_window_file = 0;
my $sub_updatePostponed = 0;
my $sub_switchContext = 0;

sub update_title_and_buttons {
    $sub_update_title_and_buttons++;
    return;
}

sub unhide_current_node {
    $sub_unhide_current_node++;
    return;
}

sub get_nodes_win {
    $sub_get_nodes_win++;
    return;
}

sub redraw_win {
    $sub_redraw_win++;
    return;
}

sub centerTo {
    $sub_center_to++;
    return;
}

sub fsfileDisplayingWindows {
    $sub_fsfileDisplayingWindows++;
    return;
}

sub set_window_file {
    $sub_set_window_file++;
    return;
}

sub updatePostponed {
    $sub_updatePostponed++;
    return;
}

sub switchContext {
    $sub_switchContext++;
    return;
}

sub grp_win {
    my ($grp_ref) = @_;
    return ($grp_ref, $grp_ref->{focusedWindow});
}

sub autosave_filename {
    return;
}

sub cast_to_grp {
    my ($grp) = @_;
    return $grp;
}

sub _clear_err {
    undef $!;
    undef $@;
}

sub _last_err {
    return;
}

sub __debug {
    return;
}

sub test_open_file {
    # create fake main objects

    my $win = TrEd::Window->new();
    my %grp = (
        focusedWindow => $win,
    );

    my $raw_file_name = File::Spec->catfile($FindBin::Bin, "test_files", "sample0.t.gz");
    my %opts = (
        '-keep_related' => 1,
    );

    # note: also opens secondary files
    my ($fsfile, $status) = TrEd::File::open_file(\%grp, $raw_file_name, %opts);

    # lock files exist for all of the opened files
    my @files = qw{
        sample0.t.gz
        sample0.a.gz
        sample0.x.gz
    };
    my @lockfiles
        = map { File::Spec->catfile($FindBin::Bin, "test_files", $_ . '.lock'); }
          @files;

    foreach my $lockfile (@lockfiles) {
        my $short_name = TrEd::File::filename($lockfile);
        $short_name =~ s/\.lock//;
        ok(-f $lockfile, "open_file(): file $short_name locked");
        # temporary
        unlink $lockfile;
    }

    # opened file added to recent files
    # (secondary files are not added to recent files)
    my @recent_files = TrEd::RecentFiles::recent_files();
    is($recent_files[0], $raw_file_name,
        "open_file(): file added to recent files");

    # prislusne rutiny prebehli zelany-pocet-krat
    is($sub_update_title_and_buttons, 1,
        "open_file(): program title and buttons updated once");

    is($sub_unhide_current_node, 1,
        "open_file(): new current node unhidden once");

    is($sub_get_nodes_win, 2,
        "open_file(): get nodes in windows twice (for hooks)");

    is($sub_redraw_win, 1,
        "open_file(): redraw window once");

    is($sub_center_to, 1,
        "open_file(): center to new current node once");

    is($sub_set_window_file, 1,
        "open_file(): set new window file once");

    is($sub_updatePostponed, 3,
        "open_file(): run updatePostponed for each opened file");

    is($sub_switchContext, 0,
        "open_file(): no hooks active, thus no switchContext run");

    # prislusne hooks prebehli
    my %expected_run_count = (
        open_file_hook      => 3,
        get_backends_hook   => 3,
        file_opened_hook    => 3,
        guess_context_hook  => 3,
    );

    foreach my $hook_name (keys %expected_run_count) {
        is($hooks_run{$hook_name}, $expected_run_count{$hook_name},
            "open_file(): hook $hook_name run correct number of times");
    };

    # test @openfiles
    my @names_of_opened_files = sort map { $_->filename() } @TrEd::File::openfiles;
    my @expected_openfiles = sort
        map { File::Spec->catfile($FindBin::Bin, "test_files", $_ ) }
        @files;

    is_deeply(\@names_of_opened_files, \@expected_openfiles,
        "open_file(): openfiles contain all of the opened files");

}


####################################### testy samotne ###################################


test_backends();

test_statuses();

# logicky synopsi postup by bol asi takyto:

# open_file, open_standalone_file, open_secondary_files,
# loadFile?
# test get_openfiles a podobne veci, ktore vyzaduju otvorene subory
# napr get primary, secondary files...
# test reload_file
# maybe change something (or mimic it)
# and test basic saving (without user interaction)
# test close_file, close_all_files

## test dirname and filename, z byvaleho Convert

my $path = "/etc/X11/xorg.conf";

my $dir = TrEd::File::dirname($path);
is($dir, "/etc/X11/",
  "dirname(): extract directory from path");

my $file = TrEd::File::filename($path);
is($file, "xorg.conf",
  "filename(): extract filename from path");


$path = 'hatlatitla';
$dir = TrEd::File::dirname($path);
is($dir, "./",
  "dirname(): return current directory if there is no slash in path");

$file = TrEd::File::filename($path);
is($file, $path,
  "filename(): return whole string if there is no slash in path");


########## z byvaleho Basics

{
    # testing with hand-crafted fsfile
    my $sample_file = File::Spec->catfile($FindBin::Bin, "test_files", "sample0.t.gz");
    my $fsfile = _init_fsfile($sample_file);


    test_absolutizePath();

    test_absolutize();

    test_get_secondary_files($fsfile);

    ## Get ref to Treex::PML::Document for files loaded with loadRelatedDocuments()
    my @secondary_files = $fsfile->relatedDocuments();
    my $id = $secondary_files[0]->[0];
    my $fsfile_2 = $fsfile->referenceObjectHash()->{$id};

    my @secondary_files_2 = $fsfile_2->relatedDocuments();
    $id = $secondary_files_2[0]->[0];
    my $fsfile_3 = $fsfile_2->referenceObjectHash()->{$id};

    test_get_secondary_files_recursively($fsfile, $fsfile_2);

    test_get_primary_files($fsfile_2);

    test_get_primary_files_recursively($fsfile_2, $fsfile_3);

    test__is_among_primary_files($fsfile_3);

    test__related_files($fsfile, $fsfile_2);

    test__fix_keep_option($fsfile_2);

    test_init_app_data($fsfile, $fsfile_2);



    undef $fsfile;
    undef $fsfile_2;
    undef $fsfile_3;
}
{
    $TrEd::Config::libDir = "tredlib";
    TrEd::Config::set_config();

    # okay, we're out of previous scope, previous fsfiles should be closed
    test_open_file();
}
done_testing();