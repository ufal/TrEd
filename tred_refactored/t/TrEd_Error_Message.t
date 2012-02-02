#!/usr/bin/env perl
# tests for TrEd::Error::Message

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
#use lib "$FindBin::Bin/../tredlib/libs/tk"; # for Tk::ErrorReport

use Test::More;
use Test::Exception;
use Data::Dumper;

BEGIN {
  our $module_name = 'TrEd::Error::Message';
  our @subs = qw(
    error_message
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

our @subs;
our $module_name;
can_ok($module_name, @subs);

#TODO: Tk GUI testing
sub test__message_box {
#  TrEd::Error::Message::_message_box({}, "title", "message");
}


sub _test_error_message_onerror {
  $TrEd::Error::Message::on_error = sub {
    my ($win_ref, $msg, $nobug) = @_;
    return "Message: $msg, Nobug: $nobug";
  };
  
  my $msg = "message";
  my $nobug = "nobug";
  is(TrEd::Error::Message::error_message({}, $msg, $nobug), "Message: $msg, Nobug: $nobug",
    "error_message(): use callback");
}

sub _test_error_message {
  note("Expected error message:");
  $TrEd::Error::Message::on_error = undef;
  
  my $msg = "message";
  my $nobug = "nobug";
  TrEd::Error::Message::error_message({}, $msg, $nobug);
}

sub test_error_message {
  _test_error_message_onerror();
  _test_error_message();
}



### Run tests



test__message_box();

test_error_message();

done_testing();