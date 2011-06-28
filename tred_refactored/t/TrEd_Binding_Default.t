#!/usr/bin/env perl
# tests for TrEd::Binding::Default

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
#use lib "$FindBin::Bin/../tredlib/libs/tk"; # for Tk::ErrorReport

use Test::More;
use Test::Exception;
use Data::Dumper;

use utf8;
use Tk;

use Readonly;

BEGIN {
  our $module_name = 'TrEd::Binding::Default';
  our @subs = qw(
    new
    _resolve_default_binding
    _run_binding
    change_binding
    get_binding
    setup_default_bindings
    get_default_bindings
    get_context_bindings
    binding_valid
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

our @subs;
our $module_name;

can_ok($module_name, @subs);

Readonly my $NO_PREV_BINDING => [ undef, undef ];

my %expected_binding_for = (
    'Tab'     => [
        q{},
        'select next node',
        'top',
    ],
    'Shift-ISO_Left_Tab' => [
        q{},
        'select previous node',
    ],
    'Shift-Tab' => [
        q{},
        'select previous node',
    ],
    'period' => [
        q{},
        'go to next tree',
    ],
    'comma' => [
        q{},
        'go to previous tree',
    ],
    'Next' => [
        q{},
        'go to next tree',
    ],
    'Prior' => [
        q{},
        'go to previous tree',
    ],
    'greater' => [
        q{},
        'go to last tree in file',
    ],
    'less' => [
        q{},
        'go to first tree in file',
    ],
    'KeyPress-Return' => [
        q{},
        'view/edit attributes',
    ],
    'KeyPress-Left' => [
        q{},
        'select left sibling',
    ],
    'Shift-Home' => [
        q{},
        'select left-most node',
    ],
    'Shift-End' => [
        q{},
        'select right-most node',
    ],
    'Shift-Left' => [
        q{},
        'select previous node on the same level',
    ],
    'KeyPress-Right' => [
        q{},
        'select right sibling',
    ],
    'Shift-Right' => [
        q{},
        'select next node on the same level',
    ],
    'KeyPress-Up' => [
        q{},
        'select parent node',
    ],
    'Shift-Up' => [
        q{},
        'select previous node in linear order',
    ],
    'KeyPress-Down' => [
        q{},
        'select first child-node',
    ],
    'Shift-Down' => [
        q{},
        'select next node in linear order',
    ],
    'Control-Tab' => [
        q{},
        'focus next view',
    ],
    'Control-Shift-Tab' => [
        q{},
        'focus previous view',
    ],
    'Control-Shift-ISO_Left_Tab' => [
        q{},
        'focus previous view',
    ],
);


sub test_get_binding {
    my ($tred_ref) = @_;
    foreach my $key (keys %expected_binding_for) {
        my $exp_binding = $expected_binding_for{$key};
        
        my $got_binding = $tred_ref->{default_binding}->get_binding($TrEd::Binding::Default::DEFAULT_CONTEXT, $key);
        # all the default bindings contain code reference
        ok(ref $got_binding->[0] eq 'CODE', "get_binding: $key bound to code reference");
        # check also the name of the binding
        is($got_binding->[1], $exp_binding->[1], 
            "get_binding: $key binding with correct name");
    }
    
    ## edge cases:
    # test also undefined context
    is_deeply($tred_ref->{default_binding}->get_binding(undef, '<Tab>'), [],
        "get_binding: return empty array if there was no context specified");
    # test undefined context & key
    is_deeply($tred_ref->{default_binding}->get_binding(undef, undef), [],
        "get_binding: return empty array if nor context, neither key were specified");
    # test context that does not exist
    is_deeply($tred_ref->{default_binding}->get_binding('not-existing-context', '<Tab>'), [],
        "get_binding: return empty array for non-existing context");
    
    is_deeply($tred_ref->{default_binding}->get_binding($TrEd::Binding::Default::DEFAULT_CONTEXT, undef), [],
        "get_binding: return empty array for non-existing key");
}


sub tk_callback {
    my ($tred_ref, $ret_value) = @_;
    
    my $context = $tred_ref->{focusedWindow}->{macroContext};
    #print "&& __callback called in context $context\n";
    if (defined $context) {
        $tred_ref->{callback_called}->{$context}++;
    }
    #print "returning ".$context . "::" . $ret_value."\n";
    return $context . "::" . $ret_value;
}



sub test_change_binding_tk {
    my ($tred_ref, $new_binding_name, $context, $key_code, $prev_binding, $new_binding, $callback_return_value) = @_;
    
    
    # change binding for specified context
    my $got_prev_binding = $tred_ref->{default_binding}->change_binding($context, $key_code, $new_binding);
    # test return value of change_binding sub
    is(ref $got_prev_binding->[0], ref $prev_binding->[0], 
        "change_binding: check previous binding code reference");
    is($got_prev_binding->[1], $prev_binding->[1], 
        "change_binding: check previous binding name");
    
    # set expected binding
    $expected_binding_for{$key_code} = $new_binding;
    
    
    my $got_binding = $tred_ref->{default_binding}->get_binding($context, $key_code);
    
    # test if binding's code ref was changed correctly
    is(ref $got_binding->[0], 'Tk::Callback', 
        "change_binding & get_binding: $key_code bound to code reference");
    
    # the callback needs to run in desired context, 
    # otherwise its results would apply to another context
    my $context_backup = $tred_ref->{focusedWindow}->{macroContext}; 
    $tred_ref->{focusedWindow} = {
        macroContext    => $context,
    };
    
    is($got_binding->[0]->Call(), $callback_return_value, 
        "change_binding & get_binding: test callback manually");
    
    # set context back to where we were
    $tred_ref->{focusedWindow}->{macroContext} = $context_backup ;
    
    # test if binding's name was changed correctly
    is($got_binding->[1], $expected_binding_for{$key_code}->[1], 
        "change_binding & get_binding: $key_code binding with correct name");
}


sub test_change_binding_code_ref {
    my ($tred_ref, $new_binding_name, $context, $key_code, $prev_binding, $new_binding, $callback_return_value) = @_;
    
    
    # change binding for specified context
    my $got_prev_binding = $tred_ref->{default_binding}->change_binding($context, $key_code, $new_binding);
    # test return value of change_binding sub
    is(ref $got_prev_binding->[0], ref $prev_binding->[0], 
        "change_binding: check previous binding code reference");
    is($got_prev_binding->[1], $prev_binding->[1], 
        "change_binding: check previous binding name");
    
    # set expected binding
    $expected_binding_for{$key_code} = $new_binding;
    
    
    my $got_binding = $tred_ref->{default_binding}->get_binding($context, $key_code);
    
    # test if binding's code ref was changed correctly
    is(ref $got_binding->[0], 'CODE', 
        "change_binding & get_binding: $key_code bound to code reference");
    
    # the callback needs to run in desired context, 
    # otherwise its results would apply to another context
    my $context_backup = $tred_ref->{focusedWindow}->{macroContext}; 
    $tred_ref->{focusedWindow} = {
        macroContext    => $context,
    };
    
    is($got_binding->[0]->({}, $tred_ref, $key_code), $callback_return_value, 
        "change_binding & get_binding: test callback manually");
    
    # set context back to where we were
    $tred_ref->{focusedWindow}->{macroContext} = $context_backup ;
    
    # test if binding's name was changed correctly
    is($got_binding->[1], $expected_binding_for{$key_code}->[1], 
        "change_binding & get_binding: $key_code binding with correct name");
}

sub test_change_binding {
    my ($tred_ref, $new_binding_name, $context) = @_;
    
    my $key_code = 'Tab';

    my $callback_return_value = 'binding callback';
     
    
    my $new_binding = [
        sub {
            my ($mw, $tred_ref) = @_;
            my $context__ = $_[1]->{focusedWindow}->{macroContext} || q{}; 
            
            #print "&& __callback called in context $context__\n";
            #print "increment counter from " .$_[1]->{callback_called}->{$context__}. " to ";
            
            $_[1]->{callback_called}->{$context__}++;
            
            #print $_[1]->{callback_called}->{$context__}. "\n";
            my $modif_cb_return_value = $context__ . q{::} . $callback_return_value;
            #print "returning $modif_cb_return_value\n";
            return $modif_cb_return_value;
        },
        $new_binding_name,
    ];
    # other context
    test_change_binding_code_ref($tred_ref, 
                                 $new_binding_name,
                                 $context, 
                                 $key_code, 
                                 $NO_PREV_BINDING,
                                 $new_binding,
                                 $context . "::" . $callback_return_value);
                                 
    # default context -- *
    my $prev_binding = $tred_ref->{default_binding}->get_binding(
        $TrEd::Binding::Default::DEFAULT_CONTEXT, 
        $key_code
        );
    test_change_binding_code_ref($tred_ref, 
                                 $new_binding_name, 
                                 $TrEd::Binding::Default::DEFAULT_CONTEXT, 
                                 $key_code, 
                                 $prev_binding, 
                                 $new_binding,
                                 $TrEd::Binding::Default::DEFAULT_CONTEXT . "::" . $callback_return_value);
                                 
    
}

sub test_binding_valid {
    my @valid_bindings = (
        [
            sub {},
            'basic type',
        ],
        [
            [
                sub {}
            ],
            'basic array_ref type',
        ],
        [
            [
                'element',
                sub {}
            ],
            'more advanced array_ref',
        ],
        [
            Tk::Callback->new(__PACKAGE__),
            'Tk::Callback',
        ],
    );
    
    foreach my $binding (@valid_bindings) {
        is(TrEd::Binding::Default::binding_valid($binding), 1, 
            "binding_valid: valid binding -- " . $binding->[1]);
    }
    
    my @invalid_bindings = (
        [
            'name',
            sub {},
        ],
        [
            'name',
            [
                sub {}
            ],
        ],
        [
            'name',
            [
                'element',
                sub {}
            ],
        ],
        undef,
        {},
    );
    
    foreach my $binding (@invalid_bindings) {
        is(TrEd::Binding::Default::binding_valid($binding), undef, 
            "binding_valid: refuse invalid binding");
    }
}


sub test_get_default_bindings {
    my ($tred_ref, $new_binding_name) = @_;
    my $default_bindings_ref = $tred_ref->{default_binding}->get_default_bindings();
    
    # test some aspects of the returned hash, so it wouldn't be necessary to compare 
    # the whole hash
    is(ref $default_bindings_ref, 'HASH',
        "get_default_bindings: hash reference returned");
    is(ref $default_bindings_ref->{'<Tab>'}, 'ARRAY',
        "get_default_bindings: array reference returned for one key");
    is($default_bindings_ref->{'<Shift-Tab>'}->[1], $expected_binding_for{'Shift-Tab'}->[1],
        "get_default_bindings: correct/unchanged name for binding <Shift-Tab>");
    is($default_bindings_ref->{'<Tab>'}->[1], $new_binding_name,
        "get_default_bindings: correct/changed name for binding <Tab>");
}

sub test_get_context_bindings {
    my ($tred_ref, $new_binding_name, $context) = @_;
    
    is($tred_ref->{default_binding}->get_context_bindings(), undef,
        "get_context_bindings: return undef if no context specified");
    
    my $context_bindings_ref = $tred_ref->{default_binding}->get_context_bindings($context);
    
    # test some aspects of the returned hash, so it wouldn't be necessary to compare 
    # the whole hash
    is(ref $context_bindings_ref, 'HASH',
        "get_context_bindings: hash reference returned");
    is(ref $context_bindings_ref->{'<Tab>'}, 'ARRAY',
        "get_context_bindings: array reference returned for one key");
    is($context_bindings_ref->{'<Tab>'}->[1], $new_binding_name,
        "get_context_bindings: correct/changed name for binding <Tab>");
}

sub _print_status {
    my ($tred_ref) = @_;
    print "status:\n";
    my $context = $tred_ref->{focusedWindow}->{macroContext};
    print "\tcontext: $context\n";
    print "\tcallback count: ". $tred_ref->{callback_called}->{$context} . "\n";
    
    
}

sub test_run_context_binding {
    my ($tred_ref, $context, $expected_call_count, $report) = @_;
    
    $tred_ref->{focusedWindow} = {
        macroContext    => $context,
    };
    
    #print "before generating event:\n";
    #_print_status($tred_ref);
    
    $tred_ref->{top}->eventGenerate('<KeyPress>', -keysym => 'Tab');
    $tred_ref->{top}->idletasks();
    $tred_ref->{top}->update();
    
    #print "after generating event:\n";
    #_print_status($tred_ref);
    
    my $got_callback_count = undef;
    if (defined $context) {
        $got_callback_count = $tred_ref->{callback_called}->{$context};
    }
    is($got_callback_count, $expected_call_count,
        "_run_binding: $report");
}

sub test_run_binding { 
    my ($tred_ref, $context) = @_;
    
    my $expected_call_count 
        = $tred_ref->{callback_called}->{$TrEd::Binding::Default::DEFAULT_CONTEXT} + 1;
    test_run_context_binding($tred_ref, 
                             $TrEd::Binding::Default::DEFAULT_CONTEXT,
                             $expected_call_count, 
                             "default context callback called correctly");

    my $call_count = exists $tred_ref->{callback_called}->{$context}
                     ? $tred_ref->{callback_called}->{$context}
                     : 0;
                     
    $expected_call_count = $call_count + 1;
    test_run_context_binding($tred_ref, 
                             $context, 
                             $expected_call_count, 
                             "other context callback called correctly");

    test_run_context_binding($tred_ref, 
                             'non-existing-context', 
                             1, 
                             "callback on non-existing context");
                      
    test_run_context_binding($tred_ref, 
                             undef, 
                             undef, 
                             "callback on undefined context");
}

sub test_run_binding_tk_callback { 
    my ($tred_ref, $context) = @_;
    

    my $expected_call_count 
        = $tred_ref->{callback_called}->{$TrEd::Binding::Default::DEFAULT_CONTEXT} + 1;
    test_run_context_binding($tred_ref, 
                             $TrEd::Binding::Default::DEFAULT_CONTEXT,
                             $expected_call_count, 
                             "tk_callback_count");
    
    $expected_call_count = $tred_ref->{callback_called}->{$context} + 1;
    test_run_context_binding($tred_ref, 
                             $context,
                             $expected_call_count, 
                             "context callback called correctly");
                             
    test_run_context_binding($tred_ref, 
                             undef, 
                             undef, 
                             "callback on undefined context");
}

sub test_change_binding_tk__ {
    my ($tred_ref, $new_binding_name, $context) = @_;
    my $key_code = 'Tab';

    my $callback_return_value = 'binding callback';
     
    
    my $new_binding = [
        [\&tk_callback, $tred_ref, $callback_return_value],
        $new_binding_name,
    ];
    
    my $prev_binding = $tred_ref->{default_binding}->get_binding(
        $context, 
        $key_code
        );
    
    #_print_status($tred_ref);
    
    test_change_binding_tk($tred_ref, 
                         $new_binding_name,
                         $context, 
                         $key_code, 
                         $prev_binding,
                         $new_binding,
                         $context . "::" . $callback_return_value);
                         
    $prev_binding = $tred_ref->{default_binding}->get_binding(
        $TrEd::Binding::Default::DEFAULT_CONTEXT, 
        $key_code
        );
    

    #_print_status($tred_ref);
    test_change_binding_tk($tred_ref, 
                         $new_binding_name,
                         $TrEd::Binding::Default::DEFAULT_CONTEXT,
                         $key_code,
                         $prev_binding,
                         $new_binding,
                         $TrEd::Binding::Default::DEFAULT_CONTEXT . "::" . $callback_return_value);
}

# start testing

my %tred;


my $top = Tk::MainWindow->new();


$tred{top} = $top;


$tred{Toolbar} = $top->Frame();
$tred{Toolbar}->pack(-fill=> 'x', -padx=> '1', -pady=> 1);


dies_ok(sub { TrEd::Binding::Default->new() }, "TrEd::Binding::Default->new: missing parameter for constructor");

$tred{default_binding} = TrEd::Binding::Default->new(\%tred);


$top->bindtags(['my',$top,ref($top),$top,$top->toplevel,'all']);
$tred{Toolbar}->bindtags(['my',$tred{Toolbar},ref($tred{Toolbar}),$tred{Toolbar},$tred{Toolbar}->toplevel,'all']);



# set default context
$tred{focusedWindow} = {
    macroContext    => $TrEd::Binding::Default::DEFAULT_CONTEXT,
};

# test various types of bindings, if they are correctly approved/rejected
test_binding_valid();

# set-up default bindings 
is($tred{default_binding}->setup_default_bindings(), undef,
    "setup_default_bindings: test return value");


# test the setup of default bindings
test_get_binding(\%tred);


my $new_binding_name = 'new_binding_name';
my $context = 'other_context';


test_change_binding(\%tred, $new_binding_name, $context);


test_get_default_bindings(\%tred, $new_binding_name);

test_get_context_bindings(\%tred, $new_binding_name, $context);

$tred{top}->update();

note("Testing own callbacks");
test_run_binding(\%tred, $context);


test_change_binding_tk__(\%tred, $new_binding_name, $context);

note("Testing Tk::Callback callbacks");
test_run_binding_tk_callback(\%tred, $context);

done_testing();