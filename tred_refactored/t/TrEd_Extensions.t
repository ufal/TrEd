#!/usr/bin/env perl
# tests for TrEd::ArabicRemix

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";

#use TrEd::Config;

use Test::More;
use Test::Exception;
use Data::Dumper;

BEGIN {
  our $module_name = 'TrEd::Extensions';
  our @exported_subs = qw(
    get_extensions_dir
    init_extensions
    get_extension_list
    get_extension_macro_paths
    get_extension_sample_data_paths
    get_extension_doc_paths
    get_preinstalled_extensions_dir
    get_preinstalled_extension_list
    get_extension_template_paths
    get_extension_subpaths
    manage_extensions_2
  );
  use_ok($module_name, @exported_subs);
}

our @exported_subs;
can_ok(__PACKAGE__, @exported_subs);


  
my @private_subs = qw(
  short_name
  _repo_extensions_uri_list
  _update_progressbar
  cmp_revisions
  _version_ok
  _ext_not_installed_or_actual
  _resolve_missing_dependency
  _add_required_exts
  _fill_required_by
  _uri_list_with_required_exts
  _uri_list_with_preinstalled_exts
  _create_uri_list
  _required_tred_version
  _required_perl_modules
  _required_perl_version
  _find_all_requirements
  _dependencies_of_req_exts
  _set_extension_icon
  _set_name_desc_copyright
  _fmt_size
  _set_ext_size
  _required_by
  _requires
  _upgrade_install_checkbutton
  _enable_checkbutton
  _uninstall_button
  _any_enter_text
  _any_enter_frame
  _any_enter_image
  _any_leave_text
  _any_leave_frame
  _any_leave_image
  _create_checkbutton
  _add_pane_items
  _populate_extension_pane
  _install_ext_button
  _update_install_new_button
  _repo_ok_or_forced
  _add_repo
  _remove_repo
  manage_repositories
  update_extensions_list
  _load_extension_file
  _force_reinstall
  _report_install_error
  _install_extension_from_zip
  install_extensions
  uninstall_extension
  _contrib_macro_paths
  get_extension_meta_data
  _inst_file
  _inst_version
  get_module_version
  compare_module_versions
);

our $module_name;
can_ok($module_name, @private_subs);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');




sub test_short_name {
    my $url = 'http://www.tred.com/extensions/dummy_extension.ext';
    my $expected_short_name = 'dummy_extension.ext';
    # $pkg_name is blessed and it is an URI object
    my $pkg_name = URI->new($url);
    is(TrEd::Extensions::short_name($pkg_name), $expected_short_name,
        "short_name: URI -> shortname");
    # $pkg_name is blessed, but not an URI object
    $pkg_name = bless {};
    is(TrEd::Extensions::short_name($pkg_name), $pkg_name,
        "short_name: non-URI blessed reference -> shortname");
    
    # $pkg_name is not blessed, just a string
    $pkg_name = $url;
    TrEd::Extensions::short_name($pkg_name);
    is(TrEd::Extensions::short_name($pkg_name), $pkg_name,
        "short_name: string -> shortname");
    
}

sub test_get_extensions_dir {
    is(TrEd::Extensions::get_extensions_dir(), $TrEd::Config::extensionsDir,
        "get_extensions_dir: correct directory");
}

sub _create_ext_list {
    my (@files) = @_;
    open my $ext_list, '>', $TrEd::Config::extensionsDir . 'extensions.lst'
        or return;
    print $ext_list join "\n", @files;
    close $ext_list
        or return;
    return 1; 
}

sub _delete_ext_list {
    return unlink $TrEd::Config::extensionsDir . 'extensions.lst';    
}

sub test_get_extension_list {
    # first test -- list of extensions does not exist
    my $repo = $FindBin::Bin;
    is_deeply(TrEd::Extensions::get_extension_list($repo), [],
        "get_extension_list(): return empty array ref if the list of extensions does not exist in specified repository");
    
    my $repo_backup = $TrEd::Config::extensionsDir;
    $TrEd::Config::extensionsDir = $FindBin::Bin;
    is(TrEd::Extensions::get_extension_list(), undef,
        "get_extension_list(): return undef if the list of extensions does not exist in default repository");
    
    $TrEd::Config::extensionsDir = $repo_backup;
    
    # second test -- list of extensions found 'automatically'
    my @expected_extensions = qw{example_ext_1 !example_ext_3 example_ext-2};
    
    _test_sub_returning_extension_list({
        sub_name            => 'get_extension_list',
        sub_ref             => \&TrEd::Extensions::get_extension_list,
        sub_args            => undef,
        message             => 'return extensions from the list',
        expected_result_ref => \@expected_extensions,
        returns_reference   => 1,
    });
    
    # third test -- list of extensions from specified directory
    @expected_extensions = qw{
        example_ext_1 
        example_ext-2
        !example_ext_3
    };
    $repo = $TrEd::Config::extensionsDir;
    
    _test_sub_returning_extension_list({
        sub_name            => 'get_extension_list',
        sub_ref             => \&TrEd::Extensions::get_extension_list,
        sub_args            => [$repo],
        message             => 'return extensions from the list, local repository',
        expected_result_ref => \@expected_extensions,
        returns_reference   => 1,
    });
}

sub _compare_arrays {
    my ($array_1_ref, $array_2_ref) = @_;
    my $desired_n = scalar @{$array_1_ref};
    my $n = 0;
    
    #print "comparing ";
    #print Dumper($array_1_ref);
    #print Dumper($array_2_ref);
        
    foreach my $el_1 (@{$array_1_ref}) {
        foreach my $el_2 (@{$array_2_ref}) {
            if (ref $el_2 && ref $el_1) {
                my $other_n = scalar @{$el_1}; 
                if (_compare_arrays($el_1, $el_2, $other_n) eq 'equal') {
                    $n++;
                    #print "subarrays equal\n";
                }
                else {
                    #print "subarrays not equal, keep searching\n";
                    #return 'not';
                }
            }
            elsif ($el_2 eq $el_1) {
                #print "found equals $el_2 = $el_1\n";
                $n++;
            }
        }
    }
    if ($desired_n == $n && scalar @$array_2_ref == $desired_n) {
        #print "arrays equal\n";
        return 'equal';
    }
    else {
        #print "arrays NOT equal\n";
        return 'not';    
    }
}

sub _test_sub_returning_extension_list {
    my ($args_ref) = @_;
    my $sub_name            = $args_ref->{sub_name};
    my $sub_ref             = $args_ref->{sub_ref};
    my $sub_args            = $args_ref->{sub_args};
    my $message             = $args_ref->{message};
    my $expected_result_ref = $args_ref->{expected_result_ref};
    my $returns_reference   = $args_ref->{returns_reference};
    
    
    my @got_extensions;
    if (!defined $sub_args) {
        @got_extensions = sort $returns_reference ? @{$sub_ref->()}
                                                  : $sub_ref->();
    }
    else {
        my @args = @{$sub_args};
        @got_extensions = sort $returns_reference ? @{ $sub_ref->(@args) }
                                                  : $sub_ref->(@args);
    }
    my @expected_extensions = sort @{$expected_result_ref};
    #print Dumper(\@got_extensions);
    #print Dumper(\@expected_extensions);
    is(_compare_arrays(\@got_extensions, \@expected_extensions), 'equal', 
       "$sub_name: $message");
}

sub test__repo_extensions_uri_list {
    # test one -- no repository specified
    my @got_extensions = TrEd::Extensions::_repo_extensions_uri_list();
    is_deeply(\@got_extensions, [], 
        "_repo_extensions_uri_list: return empty list if there is no repository specified");
    
    
    # test two -- repository specified
    my $repo = $TrEd::Config::extensionsDir;
    
    # create expected result
    my @accepted_extensions = qw{example_ext_1 example_ext_3 example_ext-2};
    my @expected_result;
    foreach my $extension_name (@accepted_extensions) {
        my $new_item = [
            'file://' . $repo,
            $extension_name,
            'file://' . $repo .q{/}. $extension_name,
        ];
        push @expected_result, $new_item;
    }
    
    _test_sub_returning_extension_list({
        sub_name            => '_repo_extensions_uri_list',
        sub_ref             => \&TrEd::Extensions::_repo_extensions_uri_list,
        sub_args            => [{repositories => [$repo]}],
        message             => 'return correct list',
        expected_result_ref => \@expected_result,
        returns_reference   => 0,
    });
    
    # test three -- also test as if some of the extensions are already installed
    my $installed_extensions = {
        'example_ext_1' => 1,
        'example_ext_3' => 1,
    };
    my $opts_ref = {
        repositories    => [$repo],
        installed       => $installed_extensions,
        only_upgrades   => 1,
    };
    
    # create expected result
    @accepted_extensions = qw{example_ext_1 example_ext_3};
    @expected_result = ();
    foreach my $extension_name (@accepted_extensions) {
        my $new_item = [
            'file://' . $repo,
            $extension_name,
            'file://' . $repo .q{/}. $extension_name,
        ];
        push @expected_result, $new_item;
    };
    
    _test_sub_returning_extension_list({
        sub_name            => '_repo_extensions_uri_list',
        sub_ref             => \&TrEd::Extensions::_repo_extensions_uri_list,
        sub_args            => [$opts_ref],
        message             => 'return correct list in upgrade mode',
        expected_result_ref => \@expected_result,
        returns_reference   => 0,
    });
}

sub test_cmp_revisions {
    # test one -- undefined revisions
    my $rev_1 = '1.1';
    my $rev_2 = '1.2';
    is(TrEd::Extensions::cmp_revisions(undef, undef), undef,
        "cmp_revisions: return undef if at least one of the revisions is not defined");
    is(TrEd::Extensions::cmp_revisions(undef, $rev_1), undef,
        "cmp_revisions: return undef if at least one of the revisions is not defined");
    is(TrEd::Extensions::cmp_revisions($rev_1, undef), undef,
        "cmp_revisions: return undef if at least one of the revisions is not defined");
        
    # test two -- one digit revision parts
    is(TrEd::Extensions::cmp_revisions($rev_1, $rev_2), -1,
        "cmp_revisions: return -1 if the first one ($rev_1) is smaller than $rev_2");
    is(TrEd::Extensions::cmp_revisions($rev_2, $rev_1), 1,
        "cmp_revisions: return 1 if the first one ($rev_2) is greater than $rev_1");
    is(TrEd::Extensions::cmp_revisions($rev_2, $rev_2), 0,
        "cmp_revisions: return 0 if the revisions are equal ($rev_2)");
    
    # test three -- one vs more digits
    $rev_1 = '1.256';
    $rev_2 = '1.1024';
    is(TrEd::Extensions::cmp_revisions($rev_1, $rev_2), -1,
        "cmp_revisions: return -1 if the first one ($rev_1) is smaller than $rev_2");
    is(TrEd::Extensions::cmp_revisions($rev_2, $rev_1), 1,
        "cmp_revisions: return 1 if the first one ($rev_2) is greater than $rev_1");
    is(TrEd::Extensions::cmp_revisions($rev_2, $rev_2), 0,
        "cmp_revisions: return 0 if the revisions are equal ($rev_2)");
}

sub test__version_ok {
    
    # test one -- standard interval
    my $required_ver_ref = {
        min_version => '1.0',
        max_version => '1.5',
    };
    
    ok(!TrEd::Extensions::_version_ok('0.95', $required_ver_ref), "_version_ok: my version too low");
    ok(TrEd::Extensions::_version_ok('1.0', $required_ver_ref), "_version_ok: my version is on the lower boundary");
    ok(TrEd::Extensions::_version_ok('1.2', $required_ver_ref), "_version_ok: my version is in the middle of the interval");
    ok(TrEd::Extensions::_version_ok('1.5', $required_ver_ref), "_version_ok: my version is on the upper boundary");
    ok(!TrEd::Extensions::_version_ok('1.6', $required_ver_ref), "_version_ok: my version is bigger than allowed");
    
    # test two -- no lower boundary
    $required_ver_ref = {
        max_version => '1.5',
    };
    ok(TrEd::Extensions::_version_ok('0', $required_ver_ref), "_version_ok: my version is less than upper boundary");
    ok(TrEd::Extensions::_version_ok('1.5', $required_ver_ref), "_version_ok: my version is on the upper boundary");
    ok(!TrEd::Extensions::_version_ok('1.6', $required_ver_ref), "_version_ok: my version is bigger than allowed");
    
    # test two -- no upper boundary
    $required_ver_ref = {
        min_version => '1.0',
    };
    ok(!TrEd::Extensions::_version_ok('0', $required_ver_ref), "_version_ok: my version too low");
    ok(TrEd::Extensions::_version_ok('1.0', $required_ver_ref), "_version_ok: my version is on the lower boundary");
    ok(TrEd::Extensions::_version_ok('1.25', $required_ver_ref), "_version_ok: my version is greater than requred min");
    
    # test 3 -- no limits
    ok(TrEd::Extensions::_version_ok('0', {}), "_version_ok: without limits -- version allowed");
    ok(TrEd::Extensions::_version_ok('15.00', {}), "_version_ok: without limits -- version allowed");
    
}

#################
### Run Tests ###
#################

$TrEd::Config::extensionsDir = $FindBin::Bin . '/extensions/';


test_short_name();

test_get_extensions_dir();

test_get_extension_list();

test__repo_extensions_uri_list();

test_cmp_revisions();

test__version_ok();


#test_init_extensions();
#
#
#test_get_extension_macro_paths();
#
#test_manage_extensions();
#
#test_get_extension_sample_data_paths();
#
#test_get_extension_doc_paths();
#
#test_get_preinstalled_extensions_dir();
#
#test_get_preinstalled_extension_list();
#
#test_get_extension_template_paths();
#
#test_get_extension_subpaths(); 

done_testing();