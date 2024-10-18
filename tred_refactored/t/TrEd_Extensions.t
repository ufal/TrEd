#!/usr/bin/env perl
# tests for TrEd::Extensions

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use lib "$FindBin::Bin/../tredlib/libs/tk"; # we need Tk::DialogReturn

use Tk; # main window, dialogs..

use TrEd::Config;
use TrEd::Utils;
use Treex::PML;

use Test::More;
use Test::Exception;
use Data::Dumper;
use Carp;
use Readonly;
use File::Path qw{remove_tree};
use List::Util; # first sub
use Archive::Zip;


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
    manage_extensions_dialog
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
  _list_of_installed_extensions
  _create_ext_list
  _required_tred_version
  _required_perl_modules
  _required_perl_version
  _find_uninstallable_exts
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
  get_module_version
  compare_module_versions
);

our $module_name;
can_ok($module_name, @private_subs);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


Readonly my $EXT_LIST_PREAMLBE => <<'EOF';
# DO NOT MODIFY THIS FILE
#
# This file only lists installed extensions.
# ! before extension name means the module is disabled
#
EOF

Readonly my $GENERIC_TITLE => 'Test extension:';

$Treex::PML::resourcePath = $FindBin::Bin . '/../resources';
$TrEd::Config::libDir = "tredlib";
TrEd::Config::set_config();


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



sub test_get_extension_list {
    my ($extension_repo, $installed_exts_ref, $repo_extensions_ref) = @_;
    # first test -- list of extensions does not exist
    my $repo = $FindBin::Bin;
    is_deeply(TrEd::Extensions::get_extension_list($repo), [],
        "get_extension_list(): return empty array ref if the list of extensions does not exist in specified repository");

    my $ext_dir_backup = $TrEd::Config::extensionsDir;
    $TrEd::Config::extensionsDir = $FindBin::Bin;
    is(TrEd::Extensions::get_extension_list(), undef,
        "get_extension_list(): return undef if the list of extensions does not exist in default repository");

    $TrEd::Config::extensionsDir = $ext_dir_backup;

    # second test -- list of extensions found 'automatically'
    # in extension directory

    _test_sub_returning_extension_list({
        sub_name            => 'get_extension_list',
        sub_ref             => \&TrEd::Extensions::get_extension_list,
        sub_args            => undef,
        message             => 'return extensions from the list',
        expected_result_ref => $installed_exts_ref,
        returns_reference   => 1,
    });

    # third test -- list of extensions from specified directory
    # -- from repository

    _test_sub_returning_extension_list({
        sub_name            => 'get_extension_list',
        sub_ref             => \&TrEd::Extensions::get_extension_list,
        sub_args            => [$extension_repo],
        message             => 'return extensions from the list, local repository',
        expected_result_ref => $repo_extensions_ref,
        returns_reference   => 1,
    });
}

# helper function for comparing arrays of arrays
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
    my ($repo, $installed_extensions_ref, $exts_in_repo) = @_;
    # test one -- no repository specified
    my @got_extensions = TrEd::Extensions::_repo_extensions_uri_list();
    is_deeply(\@got_extensions, [],
        "_repo_extensions_uri_list: return empty list if there is no repository specified");


    # test two -- repository specified

    # create expected result
    my @accepted_extensions = map { /^!(.*)/ ? $1 : $_; } @{$exts_in_repo};
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

    # test three -- some of the extensions are already installed,
    # tell the function it is so..
    my %installed_extensions;
    @installed_extensions{@{$installed_extensions_ref}}
        = (1) x @{$installed_extensions_ref};
    my $opts_ref = {
        repositories    => [$repo],
        installed       => \%installed_extensions,
        only_upgrades   => 1,
    };

    # create expected result
    @accepted_extensions = @{$installed_extensions_ref};
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


sub _create_ext_list {
    my ($dir, @files) = @_;
    my $extension_list_name = $dir . 'extensions.lst';
    open my $ext_list, '>', $extension_list_name
        or return;
    print $ext_list $EXT_LIST_PREAMLBE;
    print $ext_list join "\n", @files;
    close $ext_list
        or return;
    return 1;
}

sub _delete_ext_list {
    return unlink $TrEd::Config::extensionsDir . 'extensions.lst';
}

sub _create_ext_metafile {
    my ($extension_name, $required_exts_ref, $tred_min_version, $ext_version, $perl_module_deps_ref, $ext_dir, $ext_repo) = @_;
    my $meta_file_name = $ext_dir . '/package.xml';
    my $meta_file;
    if (!open $meta_file, '>', $meta_file_name) {
        carp("Could not create meta xml file for extension $extension_name");
        return;
    }
    print $meta_file '<?xml version="1.0" encoding="UTF-8"?>', "\n",
                     '<tred_extension xmlns="http://ufal.mff.cuni.cz/pdt/pml/" install_size="575649">', "\n",
                     '    <head>', "\n",
                     '        <schema href="tred_extension_schema.xml"/>', "\n",
                     '    </head>', "\n",
                     "    <pkgname>$extension_name</pkgname>\n",
                     "    <repository href=\"$ext_repo\"/>\n",
                     "    <title>$GENERIC_TITLE $extension_name</title>\n",
                     '    <version>' . $ext_version . '</version>', "\n",
                     '    <copyright year="2011">UFAL MFF UK</copyright>', "\n",
                     '    <description>This is a test extension for TrEd.', "\n",
                     '    </description>', "\n";
    if (defined $required_exts_ref || defined $tred_min_version) {
        print $meta_file '    <require>', "\n";
        # dependencies on extensions
        if (defined $required_exts_ref) {
            foreach my $required_ext (@{$required_exts_ref}) {
                print $meta_file '        <extension name="' . $required_ext . '"/>', "\n";
            }
        }
        # minimum TrEd version
        if (defined $tred_min_version) {
            print $meta_file '        <tred min_version="' . $tred_min_version . '"/>', "\n";
        }
        # dependencies on perl modules
        if (defined $perl_module_deps_ref) {
            foreach my $module_name (@{$perl_module_deps_ref}) {
                print $meta_file '        <perl_module name="' . $module_name. '">', "\n";
                print $meta_file '        </perl_module>', "\n";
            }
        }
        print $meta_file '    </require>', "\n";
    }
    print $meta_file '</tred_extension>', "\n";
    close $meta_file
        or carp("Could not close meta xml file for extension $extension_name")
}

# Create playground for extensions -- 'extensions' directory, several subdirectories for
# extensions, their meta-information files and extension list file in 'extensions' directory
sub _create_dummy_extensions {
    my ($extensions_ref, $extension_list_ref, $ext_repository, $preinstalled_exts_ref) = @_;

    # the ext dir is created during installation, leave it to the install procedure

    if (!mkdir $ext_repository) {
        carp("Extensions repository directory could not be created, can't run tests!");
        return;
    }

    my $preinst_ext_dir = $TrEd::Config::preinstalledExtensionsDir;
    if (!mkdir $preinst_ext_dir) {
        carp("Preinstalled extensions directory could not be created, can't run tests!");
        return;
    }

    # create preinstalled extensions
    foreach my $extension_name (keys %{$preinstalled_exts_ref}) {
        my $current_extension = $preinstalled_exts_ref->{$extension_name};
        my $ext_dir = $preinst_ext_dir . $extension_name;
        if (mkdir $ext_dir) {
            # dir created
            _create_ext_metafile($extension_name,
                                 $current_extension->{required_exts},
                                 $current_extension->{min_tred_version},
                                 $current_extension->{ext_version},
                                 [], # perl module dependencies
                                 $ext_dir,
                                 $ext_repository);
            if (defined $current_extension->{create_subfolders}) {
                foreach my $subfolder (@{$current_extension->{create_subfolders}}) {
                    mkdir $ext_dir . "/$subfolder";
                }
            }
        }
        else {
            carp("Directory $extension_name could not be created, tests won't return accurate results");
            return;
        }
    }
    # create extensions' list for preinstalled extensions
    if (! defined _create_ext_list($preinst_ext_dir, keys %{$preinstalled_exts_ref}) ) {
        carp("List of extensions could not be created, tests won't return accurate results");
        return;
    }

    # create extensions' repository
    foreach my $extension_name (keys %{$extensions_ref}) {
        my $current_extension = $extensions_ref->{$extension_name};
#        my $ext_dir = $TrEd::Config::extensionsDir . $extension_name;
        my $ext_dir = $ext_repository . $extension_name;
        if (mkdir $ext_dir) {
            # dir created
            _create_ext_metafile($extension_name,
                                 $current_extension->{required_exts},
                                 $current_extension->{min_tred_version},
                                 $current_extension->{ext_version},
                                 $current_extension->{perl_module_deps},
                                 $ext_dir,
                                 $ext_repository);
            if (defined $current_extension->{create_subfolders}) {
                foreach my $subfolder (@{$current_extension->{create_subfolders}}) {
                    mkdir $ext_dir . "/$subfolder";
                }
            }
            my $zip = Archive::Zip->new();
            $zip->addTree( $ext_dir, '' );
            my $status = $zip->writeToFileNamed($ext_repository . '/' . $extension_name . '.zip');
            if ($status != Archive::Zip::AZ_OK) {
                croak("Could not write extensions package: $extension_name");
            }
        }
        else {
            carp("Directory $extension_name could not be created, tests won't return accurate results");
            return;
        }
    }
    # create list of extensions in the repository
    if (! defined _create_ext_list($ext_repository, @{$extension_list_ref}) ) {
        carp("List of extensions could not be created, tests won't return accurate results");
        return;
    }
    return 1;
}

sub _cleanup_dummy_extensions {
    my ($extensions_repo) = @_;
    remove_tree($FindBin::Bin . '/extensions/', {safe => 1});
    remove_tree($extensions_repo, {safe => 1});
    remove_tree($TrEd::Config::preinstalledExtensionsDir, {safe => 1});
}

# check meta-data in local extension storage
sub test_get_extension_meta_data_per_ext {
    my ($extension_name, $extension_ref) = @_;
    my $extensions_dir = $TrEd::Config::extensionsDir;
    my $data = TrEd::Extensions::get_extension_meta_data($extension_name, $extensions_dir);
    if (!defined $data) {
        croak("Meta-data retrieval not successful");
    }
    is($data->get_member('version'), $extension_ref->{ext_version},
        "get_extension_meta_data: check extension's version ($extension_name)");
    is($data->get_member('pkgname'), $extension_name,
        "get_extension_meta_data: check extension's name ($extension_name)");
    is($data->get_member('title'), "$GENERIC_TITLE $extension_name",
        "get_extension_meta_data: check extension's title ($extension_name)");

    # test requirements of each extension
    my $require_struct = $data->get_member('require');
    if (!defined $require_struct) {
        return;
    };

    my @required_elements = $require_struct->elements();
    foreach my $element (@required_elements) {

        my $container = $element->value(); # calling it container, because it is Treex::PML::Container object

        if ($element->name() eq 'extension') {
            my $required_ext = $container->get_attribute('name');
            # try to find required extension from meta-data among
            # required extensions from config hash
            my $required_ext_listed
                = List::Util::first { $_ eq $required_ext }
                                    @{$extension_ref->{required_exts}};
            ok($required_ext_listed,
               "get_extension_meta_data: check required extension ($extension_name requires $required_ext)");
        }
        elsif ($element->name() eq 'tred') {
            is($container->get_attribute('min_version'),
               $extension_ref->{min_tred_version},
               "get_extension_meta_data: check required version of TrEd ($extension_name)");
        }
    }

}

# check meta-data of all installed extensions
sub test_get_extension_meta_data {
    my ($extensions_ref, $installed_extensions_ref) = @_;

    foreach my $extension_name (@{$installed_extensions_ref}) {
        test_get_extension_meta_data_per_ext($extension_name,
            $extensions_ref->{$extension_name});
    }
}

sub test__ext_not_installed_or_actual {


    my $meta_data_ref = TrEd::Extensions::get_extension_meta_data('example_ext-2',
        $TrEd::Config::extensionsDir);

    my $installed_version = '1.00';
    ok(!TrEd::Extensions::_ext_not_installed_or_actual(undef, $installed_version),
        "_ext_not_installed_or_actual: undefined meta data");

    # in repo = 1.01, installed 1.00 => not up to date
    ok(TrEd::Extensions::_ext_not_installed_or_actual($meta_data_ref, $installed_version),
        "_ext_not_installed_or_actual: extension not up to date");

    # in repo = 1.01, installed = 1.01 => up to date
    $installed_version = '1.01';
    ok(!TrEd::Extensions::_ext_not_installed_or_actual($meta_data_ref, $installed_version),
        "_ext_not_installed_or_actual: extension is up to date");

    # in repo = 1.01, installed = 1.02 => even better than up to date
    $installed_version = '1.02';
    ok(!TrEd::Extensions::_ext_not_installed_or_actual($meta_data_ref, $installed_version),
        "_ext_not_installed_or_actual: installed extension newer than repository version");

    # in repo = 1.01, installed = undef => not installed
    ok(TrEd::Extensions::_ext_not_installed_or_actual($meta_data_ref, undef),
        "_ext_not_installed_or_actual: extension not installed");

}

sub test__uri_list_with_required_exts {
    my ($extensions_ref, $dialog_box, $ext_repo, $installed_exts_ref, $preinstalled_exts_ref) = @_;

    #
    my @all_installed_exts = (@{$installed_exts_ref}, @{$preinstalled_exts_ref});
    my %installed_extensions = map { $_ => $extensions_ref->{$_}{ext_version} }
                                   @all_installed_exts;

    my $opts_ref = {
        install => 1,
        repositories => [$ext_repo],
        installed   => \%installed_extensions,
    };

    my %extension_data;

    my $uri_list_ref = TrEd::Extensions::_uri_list_with_required_exts(
            {   extension_data_ref => \%extension_data,
                opts_ref           => $opts_ref,
                dialog_box         => $dialog_box,
            }
        );
    my @got_uri_list = sort @{$uri_list_ref};

    my @all_extensions = keys %{$extensions_ref};
    my @not_installed_exts = _remove_from_array(\@all_extensions, \@all_installed_exts);
    my @required_ext_uris = sort map { "file://$ext_repo/" . $_  }
                                     @not_installed_exts;

    is_deeply(\@got_uri_list, \@required_ext_uris,
        "_uri_list_with_required_exts: return uri list of required extensions");
    # maybe later add tests for %extension_data
}


sub _init_ext_clean_up_paths {
    my ($clean_up_ext_names_ref) = @_;
    foreach my $ext_name (@{$clean_up_ext_names_ref}) {
        my @new_stylesheet_paths
            = grep { $_ !~ m/$ext_name/ }
                   TrEd::Stylesheet::stylesheet_paths();
        TrEd::Stylesheet::_replace_stylesheet_paths(@new_stylesheet_paths);

        @INC = grep { $_ !~ m/$ext_name/ }
                    @INC;
        @TrEd::Macros::macro_include_paths
            = grep { $_ !~ m/$ext_name/ }
                   @TrEd::Macros::macro_include_paths;
        my @filtered_resource_paths
            = grep { $_ !~ m/$ext_name/ }
                   Treex::PML::ResourcePaths();
        Treex::PML::SetResourcePaths(@filtered_resource_paths);
    }
}

sub _test_init_extensions_modified_paths {
    my ($installed_ext_list, $extensions_ref, $fn_name) = @_;

    my @paths_to_clean_up = ();

    foreach my $ext_name (@{$installed_ext_list}) {
        my $current_ext = $extensions_ref->{$ext_name};
        if ($current_ext->{create_subfolders}) {
            my $stylesheet_dir_present
                = List::Util::first { $_ =~ m!$ext_name/stylesheets! }
                                    TrEd::Stylesheet::stylesheet_paths();
            my $resources_dir_present
                = List::Util::first { $_ =~ m!$ext_name/resources! }
                                    Treex::PML::ResourcePaths();
            my $include_dir_present
                = List::Util::first { $_ =~ m!$ext_name/libs! }
                                    @INC;
            my $macro_dir_present
                = List::Util::first { $_ =~ m!$ext_name! }
                                    @TrEd::Macros::macro_include_paths;
            # remember that we need to clean it up to perform other tests
            push @paths_to_clean_up, $ext_name;

            # and now test it
            ok($stylesheet_dir_present, "$fn_name: stylesheet dir found for $ext_name");
            ok($resources_dir_present,  "$fn_name: resources dir found for $ext_name");
            ok($include_dir_present,    "$fn_name: include dir found for $ext_name");
            ok($macro_dir_present,      "$fn_name: macro dir found for $ext_name");
        }
    }
    return @paths_to_clean_up;
}

sub _test_init_extensions_not_modified_paths {
    my ($extensions_ref);
    foreach my $ext_name (keys %{$extensions_ref}) {
        my $current_ext = $extensions_ref->{$ext_name};

        my $stylesheet_dir_present
            = List::Util::first { $_ =~ m!$ext_name/stylesheets! }
                                TrEd::Stylesheet::stylesheet_paths();
        my $resources_dir_present
            = List::Util::first { $_ =~ m!$ext_name/resources! }
                                Treex::PML::ResourcePaths();
        my $include_dir_present
            = List::Util::first { $_ =~ m!$ext_name/libs! }
                                @INC;
        my $macro_dir_present
            = List::Util::first { $_ =~ m!$ext_name! }
                                @TrEd::Macros::macro_include_paths;

        # and now test it
        is($stylesheet_dir_present, undef,
            "init_extensions: stylesheet dir not modified for $ext_name");
        is($resources_dir_present, undef,
            "init_extensions: resources dir not modified for $ext_name");
        is($include_dir_present, undef,
            "init_extensions: include dir not modified for $ext_name");
        is($macro_dir_present, undef,
            "init_extensions: macro dir not modified for $ext_name");
    }
}

sub _test_init_extensions_wrapper {
    my ($extensions_ref, $ext_list, $extension_dir) = @_;

    my @paths_to_clean_up = ();

    # run init_extensions
    if (!defined $ext_list && !defined $extension_dir) {
        TrEd::Extensions::init_extensions();
    }
    else {
        TrEd::Extensions::init_extensions($ext_list, $extension_dir);
    }

    # test its effects
    eval {
        @paths_to_clean_up
            = _test_init_extensions_modified_paths($ext_list, $extensions_ref, 'init_extensions');
    };

    # clean up the clobbered paths
    _init_ext_clean_up_paths(\@paths_to_clean_up);

}

sub test_init_extensions {
    my ($extensions_ref, $installed_extensions_ref) = @_;

    note("init_extensions: wrong reference as an argument:");
    TrEd::Extensions::init_extensions({});
    _test_init_extensions_not_modified_paths($extensions_ref);

    my @ext_list = @{$installed_extensions_ref};
    my $extension_dir = $TrEd::Config::extensionsDir;

    note("init_extensions: no arguments:");
    _test_init_extensions_wrapper($extensions_ref, undef, undef);
    note("init_extensions: only list of extensions specified:");
    _test_init_extensions_wrapper($extensions_ref, \@ext_list, undef);
    note("init_extensions: all arguments specified:");
    _test_init_extensions_wrapper($extensions_ref, \@ext_list, $extension_dir);

    note("init_extensions: wrong reference as an argument:");
    TrEd::Extensions::init_extensions(undef, $extension_dir);
    _test_init_extensions_not_modified_paths($extensions_ref);


}

sub test_install_extensions {
    my ($extensions_to_install_ref, $ext_repo, $extensions_ref) = @_;

    # first, try to supply invalid argument
    my $urls_ref = {};
    my $opts_ref;
    dies_ok( sub {TrEd::Extensions::install_extensions($urls_ref, $opts_ref); },
        "install_extensions: first argument is a reference, but other type than expected");

    $urls_ref = [];
    is(TrEd::Extensions::install_extensions($urls_ref, $opts_ref), undef,
        "install_extensions: return undef if not extensions should be installed");

    # quiet installation so we don't need user interaction
    $opts_ref = {
        quiet   => 1,
    };

    my @list_of_uris = map { $ext_repo . $_ }
                           @{$extensions_to_install_ref};

    is(TrEd::Extensions::install_extensions(\@list_of_uris, $opts_ref), 1,
        "install_extensions: install requested extensions");

    # test that the directories and files are really where they should be...
    ok(-d $TrEd::Config::extensionsDir, "install_extensions: directory for extensions created");
    foreach my $extension_name (@{$extensions_to_install_ref}) {
        ok(-d $TrEd::Config::extensionsDir . $extension_name,
            "install_extensions: directory for $extension_name created");
        ok(-f $TrEd::Config::extensionsDir . $extension_name . '/package.xml',
            "install_extensions: meta file for $extension_name created");
        # check also that subfolders exist
        if (exists $extensions_ref->{$extension_name}->{create_subfolders}) {
            my @subfolders = @{$extensions_ref->{$extension_name}->{create_subfolders}};
            foreach my $subfolder (@subfolders) {
                ok(-d $TrEd::Config::extensionsDir . $extension_name . "/$subfolder",
                    "install_extensions: $subfolder subdirectory for $extension_name created");
            }
        }
    }
}

sub test_get_preinstalled_extensions_dir {
    is(TrEd::Extensions::get_preinstalled_extensions_dir(), $FindBin::Bin . '/preinstalled_extensions/',
        "get_preinstalled_extensions_dir: return correct directory");
}

sub test_get_preinstalled_extension_list {
    my ($preinstalled_exts_ref) = @_;

    my @preinstalled_exts = sort @{TrEd::Extensions::get_preinstalled_extension_list()};
    my @expected_exts = sort keys %{$preinstalled_exts_ref};

    is_deeply(\@preinstalled_exts, \@expected_exts,
        "get_preinstalled_extension_list: find all preinstalled extensions");

    my $except = ['preinstalled_ext_2'];
    @preinstalled_exts = sort @{TrEd::Extensions::get_preinstalled_extension_list($except)};

    my @all_preinstalled_exts = keys %{$preinstalled_exts_ref};
    @expected_exts = _remove_from_array(\@all_preinstalled_exts, $except);

    is_deeply(\@preinstalled_exts, \@expected_exts,
        "get_preinstalled_extension_list: find preinstalled extensions, except specified ones");
}

sub test__list_of_installed_extensions {
    my ($extensions_ref, $preinstalled_exts_ref, $installed_exts_ref) = @_;

    my $opts_ref = {};

    my %extension_data = ();
    my %pre_installed = ();
    my %enable = ();

    my $uri_list_ref = TrEd::Extensions::_list_of_installed_extensions(
            {   extension_data_ref => \%extension_data,
                opts_ref           => $opts_ref,
                pre_installed_ref  => \%pre_installed,
                enable_ref         => \%enable,
            }
        );
    my @got_uri_list = sort @{$uri_list_ref};
    my @expected_uri_list = sort (@{$installed_exts_ref}, keys %{$preinstalled_exts_ref});

    is_deeply(\@got_uri_list, \@expected_uri_list,
        "_list_of_installed_extensions: return all installed and preinstalled extensions");

}


#######################################################################################
# Usage         : _test_prepare_extensions_wrapper($macro_file_cmdline, $ext_list, $extensions_ref, $expected_prepared_exts_ref)
# Purpose       : Test prepare_extensions sub and cleans up paths afterwards
# Returns       : Undef/empty list
# Parameters    : string $macro_dir_present -- simulates cmd line option -m
#                 array_ref $ext_list -- list of names of extensions that should be prepared
#                 hash_ref $extensions_ref -- ref to hash of initial extensions' options
#                 array_ref $expected_prepared_exts_ref -- the expected return value for prepare_extensions sub
# Comments      :
# See Also      : test_prepare_extensions(), _test_init_extensions_modified_paths(), _init_ext_clean_up_paths()
sub _test_prepare_extensions_wrapper {
    my ($macro_file_cmdline, $ext_list, $extensions_ref, $expected_prepared_exts_ref) = @_;

    my @paths_to_clean_up = ();

    eval {

        # run prepare_extensions
        my @prepared_extensions = @{TrEd::Extensions::prepare_extensions($macro_file_cmdline)};
        my @expected_result = @{$expected_prepared_exts_ref};

        is(_compare_arrays(\@prepared_extensions, \@expected_result), 'equal',
            "prepare_extensions: prepared extensions returned correctly");

        # test its effects

        @paths_to_clean_up
            = _test_init_extensions_modified_paths($ext_list, $extensions_ref, 'prepare_extensions');
    };

    # clean up the clobbered paths
    _init_ext_clean_up_paths(\@paths_to_clean_up);
    return;
}

# removes all the elements of second array from first array
sub _remove_from_array {
    my ($first_array_ref, $second_array_ref) = @_;
    my %count = ();
    foreach my $element (@{$first_array_ref}, @{$second_array_ref}) {
        $count{$element}++;
    }
    return grep { $count{$_} == 1 } @{$first_array_ref};
}

# test the prepare_extensions subroutine
sub test_prepare_extensions {
    my ($extensions_ref, $installed_exts_ref, $preinstalled_exts_ref, $disabled_exts_ref) = @_;

    my $extension_dir = $TrEd::Config::extensionsDir;

    my @expected_extensions = ();

    # either the macro file was specified on the command line or not
    foreach my $macro_file_cmdline ('macro.mak', undef) {
        ### a) -- all enabled, just one disabled on the cmd line
        $TrEd::Extensions::enable_extensions = '*';
        $TrEd::Extensions::disable_extensions = 'preinstalled_ext_2';
        # ext_list: installed + preinstalled - preinstalled_ext_2

        # here, the extension disabled in ext.lst is enabled, do not remove it
        my @expected_extensions = _remove_from_array(
                    [@{$installed_exts_ref}, @{$preinstalled_exts_ref}],
                    ['preinstalled_ext_2']);

        my @expected_ret_val = ($installed_exts_ref,
                                ['preinstalled_ext_1', '!preinstalled_ext_2']);

        _test_prepare_extensions_wrapper($macro_file_cmdline,
                                         \@expected_extensions,
                                         $extensions_ref,
                                         \@expected_ret_val);

        ### b) -- all disabled, just one enabled on the cmd line
        $TrEd::Extensions::enable_extensions = 'preinstalled_ext_2';
        $TrEd::Extensions::disable_extensions = '*';
        # ext_list: preinstalled_ext_2
        @expected_extensions = qw {preinstalled_ext_2};
        # all but one are disabled
        my @disabled_extensions = _remove_from_array(
                    [@{$installed_exts_ref}, @{$preinstalled_exts_ref}],
                    ['preinstalled_ext_2']);
        # prepend all disabled with '!' sign (if '!' is not already there)
        @expected_ret_val = ([map { /^!.*/ ? $_ : "!$_" } @{$installed_exts_ref}],
                             ['!preinstalled_ext_1', 'preinstalled_ext_2']);

        _test_prepare_extensions_wrapper($macro_file_cmdline,
                                         \@expected_extensions,
                                         $extensions_ref,
                                         \@expected_ret_val);

        ### c) -- no enabled/disabled specified on the cmd line
        $TrEd::Extensions::enable_extensions = q{};
        $TrEd::Extensions::disable_extensions = q{};
        # ext_list: installed + preinstalled
        @expected_extensions = (@{$installed_exts_ref}, @{$preinstalled_exts_ref});
        @expected_extensions = _remove_from_array(\@expected_extensions, $disabled_exts_ref);

        my @enabled_exts = map { $macro_file_cmdline ? "!$_" : "$_" }
                           _remove_from_array($installed_exts_ref, $disabled_exts_ref);
        @disabled_extensions = map { "!$_" }
                                   @{$disabled_exts_ref};

        @expected_ret_val = ([ @enabled_exts, @disabled_extensions ],
                             [ map { $macro_file_cmdline ? "!$_" : "$_" } @{$preinstalled_exts_ref} ]);

        _test_prepare_extensions_wrapper($macro_file_cmdline,
                     $macro_file_cmdline ? [] : \@expected_extensions,
                     $extensions_ref,
                     \@expected_ret_val);

    }


}

# disable extensions listed in $disabled_exts_ref
sub test_update_extensions_list {
    my ($disable_exts_ref, $installed_exts_ref) = @_;
    foreach my $extension_to_disable (@{$disable_exts_ref}) {
        TrEd::Extensions::update_extensions_list( $extension_to_disable,
                                                  0,
                                                  $TrEd::Config::extensionsDir
                                                );
    }

    my @installed_extensions = sort @{TrEd::Extensions::get_extension_list()};

    my @expected_exts = (_remove_from_array($installed_exts_ref, $disable_exts_ref),
                         map { "!$_" } @{$disable_exts_ref});
    @expected_exts = sort @expected_exts;
    is_deeply(\@installed_extensions, \@expected_exts,
        "update_extensions_list: extension disabled correctly");

}

sub test_uninstall_extension {
    my ($ext_to_remove_ref) = @_;
    # we don't want to use GUI
    my $opts_ref = {
        quiet => 1,
    };

    foreach my $extension_name (@{$ext_to_remove_ref}) {
        note("Uninstall extension $extension_name");
        TrEd::Extensions::uninstall_extension( $extension_name, $opts_ref );
        # test that directory was removed
        ok(!-d $TrEd::Config::extensionsDir . $extension_name,
            "uninstall_extension: directory for $extension_name does not exist any more");
        # and also that removed extension is no longer listed in extensions list
        my $ext_in_ext_list = List::Util::first { $_ =~ $extension_name }
                              @{TrEd::Extensions::get_extension_list()};
        is($ext_in_ext_list, undef,
            "uninstall_extension: $extension_name is no longer listed in the list of extensions");
    }

}

sub _check_uninstallable_hash {
    my ($expected_error_msg_for_ref, $uninstallable_ref, $fn_name) = @_;

    my @uninstallable_keys = keys %{$uninstallable_ref};

    foreach my $required_key (keys %{$expected_error_msg_for_ref}) {
        my $uninstallable_key = List::Util::first { $_ =~ $required_key }
                                                  @uninstallable_keys;
        my @required_patterns = @{$expected_error_msg_for_ref->{$required_key}};
        foreach my $required_pattern (@required_patterns) {
            my $error_msg = $uninstallable_ref->{$uninstallable_key};
            like($error_msg, qr/$required_pattern/,
                "$fn_name: error message for $required_key contains $required_pattern");
        }
    }
    is(keys %{$uninstallable_ref}, keys %{$expected_error_msg_for_ref},
        "$fn_name: all patterns found, nothing left");
}

sub test_dependencies_perl_module {
    my ($ext_repository) = @_;

    note("Test finding dependencies: Perl module which is not installed/does not exist");

    my %enable = ();
    my %extension_data = ();
    my %pre_installed = ();
    my $opts_ref = {
        install => 1,
        repositories => [$ext_repository],
    };

    my $ext_list_ref = TrEd::Extensions::_create_ext_list(
            {   pre_installed_ref  => \%pre_installed,
                extension_data_ref => \%extension_data,
                enable_ref         => \%enable,
                opts_ref           => $opts_ref,
            }
        );

    # make example_ext_2 uninstallable -- dependent on perl module that does not exist
    my @module_dep = (
        'perl_module',
        {
            '#content'  => [],
            'name'      => 'Module::Does::Not::Exist',
        }
    );
    push @{$extension_data{'file://' . $ext_repository . '/example_ext-2'}{'require'}[0]},
         \@module_dep;

    my $uninstallable_ref
            = TrEd::Extensions::_find_uninstallable_exts( $ext_list_ref, \%extension_data );
    my %expected_error_msg_for = (
        'example_ext-2' => ['Module::Does::Not::Exist', 'Requires Perl Modules'],
    );
    _check_uninstallable_hash(\%expected_error_msg_for, $uninstallable_ref, '_find_uninstallable_exts');



    TrEd::Extensions::_dependencies_of_req_exts( $ext_list_ref, $uninstallable_ref );
    %expected_error_msg_for = (
        'example_ext-2'         => ['Module::Does::Not::Exist', 'Requires Perl Modules'],
        'preinstalled_ext_1'    => ['Depends on uninstallable', 'example_ext_1', 'example_ext-2'],
        'example_ext_1'         => ['Depends on uninstallable', 'example_ext-2'],
        'example_ext_3'         => ['Depends on uninstallable', 'example_ext_1', 'example_ext-2'],
    );
    _check_uninstallable_hash(\%expected_error_msg_for, $uninstallable_ref, '_dependencies_of_req_exts');
}

sub test_dependencies_tred_version {
    my ($ext_repository) = @_;

    note("Test finding dependencies: min TrEd version");

    my %enable = ();
    my %extension_data = ();
    my %pre_installed = ();
    my $opts_ref = {
        install => 1,
        repositories => [$ext_repository],
    };

    my $ext_list_ref = TrEd::Extensions::_create_ext_list(
            {   pre_installed_ref  => \%pre_installed,
                extension_data_ref => \%extension_data,
                enable_ref         => \%enable,
                opts_ref           => $opts_ref,
            }
        );

    # make example_ext_2 uninstallable -- dependent on tred version that does not exist
    my $min_version = '100.0'; #460kB should be enough for everyone!
    $extension_data{'file://' . $ext_repository . '/example_ext-2'}{'require'}[0][0][1]{min_version} = $min_version;

    # make it work on DEV_VERSION
    if ($TrEd::Version::VERSION eq 'DEV_VERSION') {
        $TrEd::Version::VERSION = '1.4600';
    }

    my $uninstallable_ref
            = TrEd::Extensions::_find_uninstallable_exts( $ext_list_ref, \%extension_data );
    my %expected_error_msg_for = (
        'example_ext-2' => ['Requires TrEd at least', $min_version],
    );
    _check_uninstallable_hash(\%expected_error_msg_for, $uninstallable_ref, '_find_uninstallable_exts');



    TrEd::Extensions::_dependencies_of_req_exts( $ext_list_ref, $uninstallable_ref );
    %expected_error_msg_for = (
        'example_ext-2'         => ['Requires TrEd at least', $min_version],
        'preinstalled_ext_1'    => ['Depends on uninstallable', 'example_ext_1', 'example_ext-2'],
        'example_ext_1'         => ['Depends on uninstallable', 'example_ext-2'],
        'example_ext_3'         => ['Depends on uninstallable', 'example_ext_1', 'example_ext-2'],
    );
    _check_uninstallable_hash(\%expected_error_msg_for, $uninstallable_ref, '_dependencies_of_req_exts');
}


sub test_dependencies_unknown_ext {
    # this won't work without user interaction in current implememntation
    # because we can't add extension dependency from outside the module
    # and adding it the standard way fires up a window that asks user
    # what to do
}

sub _test_get_extension_generic_paths {
    my ($got_paths_ref, $expected_list_ref, $fn_name, $subpath) = @_;

    my @got_paths = sort @{$got_paths_ref};
    my @expected_list = sort
                        map { $TrEd::Config::extensionsDir . $_ . "/$subpath" }
                        @{$expected_list_ref};
    is_deeply(\@got_paths, \@expected_list,
        "$fn_name: found correct paths");
}

sub test_get_extension_sample_data_paths {
    my ($extension_list_ref, $expected_list_ref) = @_;
    my @sample_paths
        = get_extension_sample_data_paths( $extension_list_ref,
                                           $TrEd::Config::extensionsDir );
    _test_get_extension_generic_paths(\@sample_paths,
                                      $expected_list_ref,
                                      'get_extension_sample_data_paths',
                                      'sample');
}


sub test_get_extension_doc_paths {
    my ($extension_list_ref, $expected_list_ref) = @_;
    my @sample_paths
        = get_extension_doc_paths( $extension_list_ref,
                                   $TrEd::Config::extensionsDir );
    _test_get_extension_generic_paths(\@sample_paths,
                                      $expected_list_ref,
                                      'get_extension_doc_paths',
                                      'documentation');
}

sub test_get_extension_template_paths {
    my ($extension_list_ref, $expected_list_ref) = @_;
    my @sample_paths
        = get_extension_template_paths( $extension_list_ref,
                                        $TrEd::Config::extensionsDir );
    _test_get_extension_generic_paths(\@sample_paths,
                                      $expected_list_ref,
                                      'get_extension_template_paths',
                                      'templates');
}

sub test_get_extension_macro_paths {
    my ($extension_list_ref, $expected_list_ref) = @_;
    open my $dummy_file, '>',
        $TrEd::Config::extensionsDir . 'example_ext_3/contrib/contrib.mac';
    my @sample_paths
        = get_extension_macro_paths( $extension_list_ref,
                                     $TrEd::Config::extensionsDir );
    _test_get_extension_generic_paths(\@sample_paths,
                                      ['example_ext_3'],
                                      'get_extension_macro_paths',
                                      'contrib/contrib.mac');
}
#################
### Run Tests ###
#################

my $ext_repository = q{};

eval {

    $TrEd::Config::extensionsDir = $FindBin::Bin . '/extensions/';
    $TrEd::Config::preinstalledExtensionsDir = $FindBin::Bin . '/preinstalled_extensions/';


    my %preinstalled_exts = (
        'preinstalled_ext_1' => {
                                required_exts       => ['example_ext_1', 'example_ext-2'],
                                min_tred_version    => undef,
                                ext_version         => '0.99',
                                create_subfolders   => ['libs',
                                                        'stylesheets',
                                                        'resources',
                                                        'sample',
                                                        ],
                            },
        'preinstalled_ext_2' => {
                                required_exts       => undef,
                                min_tred_version    => undef,
                                ext_version         => '0.95',
                                create_subfolders   => ['libs',
                                                        'stylesheets',
                                                        'resources',
                                                        'documentation'
                                                        ],
                            },
    );


    # extensions in repository
    my %extensions = (
            'example_ext_1' => {
                                    required_exts       => ['example_ext-2'],
                                    min_tred_version    => '1.4567',
                                    ext_version         => '0.01',
                                    create_subfolders   => ['libs',
                                                            'stylesheets',
                                                            'resources',
                                                            'templates',
                                                            'sample',
                                                            'documentation',
                                                            'contrib'],
                                },
            'example_ext-2' => {
                                    required_exts       => undef,
                                    min_tred_version    => '1.4567',
                                    ext_version         => '1.01',
                                    create_subfolders   => ['libs',
                                                            'stylesheets',
                                                            'resources',
                                                            'templates',
                                                            ],
                                },
            'example_ext_3' => {
                                    required_exts       => ['example_ext_1', 'example_ext-2'],
                                    min_tred_version    => undef,
                                    ext_version         => '0.99',
                                    create_subfolders   => ['libs',
                                                            'stylesheets',
                                                            'resources',
                                                            'sample',
                                                            'contrib'
                                                            ],
                                },
            'example_ext_4' => {
                                    perl_module_deps    => ['Data::Dumper'],
                                    required_exts       => undef,
                                    min_tred_version    => undef,
                                    ext_version         => '0.01',
                                },
            %preinstalled_exts,
        );


    my @installed_extensions = (
        'example_ext_1',
        'example_ext-2',
        'example_ext_3',
    );

    my @ext_list_extensions = qw{
            example_ext_1
            !example_ext-2
            example_ext_3
            example_ext_4
            preinstalled_ext_1
            preinstalled_ext_2
        };

    $ext_repository = $FindBin::Bin . '/extensions_repo/';



    note("Creating testing extension directory");
    if (!_create_dummy_extensions(\%extensions, \@ext_list_extensions, $ext_repository, \%preinstalled_exts)){
        done_testing();
        _cleanup_dummy_extensions();
        exit(0);
    }

    note("Try to install extensions");
    test_install_extensions(\@installed_extensions, $ext_repository, \%extensions);

    test_short_name();

    test_get_extensions_dir();

    test_get_extension_list($ext_repository, \@installed_extensions, \@ext_list_extensions);

    test__repo_extensions_uri_list($ext_repository, \@installed_extensions, \@ext_list_extensions);

    test_cmp_revisions();

    test__version_ok();


    test_get_extension_meta_data(\%extensions, \@installed_extensions);

    test__ext_not_installed_or_actual();

    # this is somehow problematic because it might need user interaction
    # or automatic GUI test system
    my $mw = Tk::MainWindow->new();
    my $dialog_box = $mw->DialogBox(
            -title   => 'Dummy dialog',
        );
    my @preinstalled_exts = keys %preinstalled_exts;
    test__uri_list_with_required_exts(\%extensions, $dialog_box, $ext_repository, \@installed_extensions, \@preinstalled_exts);

    test_init_extensions(\%extensions, \@installed_extensions);

    test_get_preinstalled_extensions_dir();

    test_get_preinstalled_extension_list(\%preinstalled_exts);

    test__list_of_installed_extensions(\%extensions, \%preinstalled_exts, \@installed_extensions);

    # disable this extension(s)
    my @disabled_exts = qw{example_ext-2};

    test_update_extensions_list(\@disabled_exts, \@installed_extensions);

    test_prepare_extensions(\%extensions, \@installed_extensions, \@preinstalled_exts, \@disabled_exts);

    test_uninstall_extension(\@disabled_exts);

    # make some extensions uninstallable for various reasons
    test_dependencies_perl_module($ext_repository);
    test_dependencies_tred_version($ext_repository);
    test_dependencies_unknown_ext($ext_repository);

    test_get_extension_sample_data_paths(\@installed_extensions, ['example_ext_1', 'example_ext_3']);
    test_get_extension_doc_paths(\@installed_extensions, ['example_ext_1']);
    test_get_extension_template_paths(\@installed_extensions, ['example_ext_1']);
    test_get_extension_macro_paths(\@installed_extensions);

};

if ($@) {
    carp("\n!!Not all tests run because of following error occured: $@") ;
    fail();
}
note("Cleaning up testing extension directory");
_cleanup_dummy_extensions($ext_repository);

done_testing();