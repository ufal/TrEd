#!/usr/bin/env perl
# tests for TrEd::SidePanel

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More;

use Data::Dumper;

BEGIN {
  my $module_name = 'TrEd::SidePanel';
  use_ok($module_name);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my $top = Tk::MainWindow->new();
my $bodyPane = $top->Panedwindow();
my $sidepanel = TrEd::SidePanel->new($bodyPane);

#print Dumper($sidepanel);
#print Dumper(\%TrEd::SidePanel::);
#  
#print STDERR "tak jo, no...\n";
#$sidepanel->widget_names;
#$sidepanel->widgets;
#$sidepanel->widget;
#$sidepanel->frame;
#$sidepanel->add;
#$sidepanel->remove;
#$sidepanel->is_shown;
#$sidepanel->equalize_sizes;
#$sidepanel->update_attribute_view;
#$sidepanel->toggle_attribute_view_hide_empty;
#$sidepanel->init_node_attributes;
#$sidepanel->init_browse_filesystem;
#$sidepanel->init_filelist_view;
#$sidepanel->init_macro_list;

done_testing();