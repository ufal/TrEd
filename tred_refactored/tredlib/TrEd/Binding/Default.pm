package TrEd::Binding::Default;

use strict;
use warnings;

our $VERSION = '0.1';

# consider moving keyBindings and macroBindings from TrEd::Macro here...?
# or create TrEd::Binding::Macro

use Carp;
use Tk; # using bind function
use Readonly;
use TrEd::Basics;

my %context_override_binding;

#TODO: do nejakeho TrEd::Config::View alebo do TrEd::Config?
my %default_binding = (
    '<Tab>' => [
        sub {
            main::currentNext( $_[1]->{focusedWindow} );
            Tk->break;
        },
        'select next node',
        'top',
    ],
    '<Shift-ISO_Left_Tab>' => [
        sub { 
            main::currentPrev( $_[1]->{focusedWindow} ); 
            Tk->break; 
        },
        'select previous node',
    ],
    '<Shift-Tab>' => [
        sub { main::currentPrev( $_[1]->{focusedWindow} ); Tk->break; },
        'select previous node',
    ],
    '<period>' => [
        sub { 
            main::onIdleNextTree( $_[1]->{focusedWindow} ); 
        },
        'go to next tree',
    ],
    '<comma>' => [
        sub { main::onIdlePrevTree( $_[1]->{focusedWindow} ); },
        'go to previous tree',
    ],
    '<Next>' => [
        sub { main::onIdleNextTree( $_[1]->{focusedWindow} ); },
        'go to next tree',
    ],
    '<Prior>' => [
        sub { main::onIdlePrevTree( $_[1]->{focusedWindow} ); },
        'go to previous tree',
    ],
    '<greater>' => [
        sub {
            my $fw = $_[1]->{focusedWindow};
            TrEd::Basics::go_to_tree( $fw, $fw->{FSFile}->lastTreeNo );
            Tk->break();
        },
        'go to last tree in file',
    ],
    '<less>' => [
        sub {
            TrEd::Basics::go_to_tree( $_[1]->{focusedWindow}, 0 );
            Tk->break();
        },
        'go to first tree in file',
    ],
    '<KeyPress-Return>' => [
        sub {
            main::editAttrsDialog( $_[1]->{focusedWindow},
                $_[1]->{focusedWindow}->{currentNode} );
            Tk->break();
        },
        'view/edit attributes',
    ],
    '<KeyPress-Left>' => [
        sub {
            my $grp = $_[1];
            if ( main::treeIsVertical($grp) ) {
                main::currentUp($grp);
            }
            else {
                main::treeIsReversed($grp)
                    ? main::currentRight($grp)
                    : main::currentLeft($grp);
            }
            Tk->break();
        },
        'select left sibling',
    ],
    '<Shift-Home>' => [
        sub { main::gotoFirstDisplayedNode( $_[1] ); Tk->break() },
        'select left-most node',
    ],
    '<Shift-End>' => [
        sub { main::gotoLastDisplayedNode( $_[1] ); Tk->break() },
        'select right-most node',
    ],
    '<Shift-Left>' => [
        sub {
            my $grp = $_[1];
            main::currentLeftWholeLevel($grp);
            Tk->break();
        },
        'select previous node on the same level',
    ],
    '<KeyPress-Right>' => [
        sub {
            my $grp = $_[1];
            if ( main::treeIsVertical($grp) ) {
                main::currentDown($grp);
            }
            else {
                main::treeIsReversed($grp)
                    ? main::currentLeft($grp)
                    : main::currentRight($grp);
            }
            Tk->break();
        },
        'select right sibling',
    ],
    '<Shift-Right>' => [
        sub {
            my $grp = $_[1];
            main::currentRightWholeLevel($grp);
            Tk->break();
        },
        'select next node on the same level',
    ],
    '<KeyPress-Up>' => [
        sub {
            my $grp = $_[1];
            if ( main::treeIsVertical($grp) ) {
                main::currentLeft($grp);
            }
            else {
                main::currentUp($grp);
            }
            Tk->break();
        },
        'select parent node',
    ],
    '<Shift-Up>' => [
        sub {
            my $grp = $_[1];
            main::treeIsReversed($grp)
                ? main::currentRightLin($grp)
                : main::currentLeftLin($grp);
            Tk->break();
        },
        'select previous node in linear order',
    ],
    '<KeyPress-Down>' => [
        sub {
            my $grp = $_[1];
            if ( main::treeIsVertical($grp) ) {
                main::currentRight($grp);
            }
            else {
                main::currentDown($grp);
            }
            Tk->break();
        },
        'select first child-node',
    ],
    '<Shift-Down>' => [
        sub {
            my $grp = $_[1];
            main::treeIsReversed($grp)
                ? main::currentLeftLin($grp)
                : main::currentRightLin($grp);
            Tk->break();
        },
        'select next node in linear order',
    ],
    '<Control-Tab>' => [
        sub {
            my $grp = $_[1];
            main::focusNextWindow($grp);
            Tk->break();
        },
        'focus next view',
    ],
    '<Control-Shift-Tab>' => [
        sub {
            my $grp = $_[1];
            main::focusPrevWindow($grp);
            Tk->break();
        },
        'focus previous view',
    ],
    '<Control-Shift-ISO_Left_Tab>' => [
        sub {
            my $grp = $_[1];
            main::focusPrevWindow($grp);
            Tk->break();
        },
        'focus previous view',
    ],
);

Readonly our $DEFAULT_CONTEXT => q{*};

#######################################################################################
# Usage         : TrEd::Binding::Default->new($grp_ref)
# Purpose       : Create default binding object
# Returns       : Blessed reference to TrEd::Binding::Default object
# Parameters    : string $grp_ref -- reference to hash contining TrEd's configuration
# Throws        : Croaks if $grp_ref is not a reference 
sub new {
    my ($class, $grp_ref) = @_;
    if (!ref $grp_ref) {
        croak("Default binding constructor needs reference toTrEd hash");
    }    
      
    my $obj = {
#        vertical_key_arrow_map      => \%vertical_key_arrow_map,
#        context_override_binding    => \%context_override_binding,
#        default_binding             => \%default_binding,
        grp_ref                     => $grp_ref,
    };
    return bless $obj, $class;
}

#######################################################################################
# Usage         : $default_binding->_resolve_default_binding($context, $key)
# Purpose       : Resolve default binding for key $key in context $context
# Returns       : Reference to array which specifies the binding
# Parameters    : string $context --  name of the context
#                 string $key     -- string representation of key
# Throws        : no exception
# Comments      : For the specification of returned array ref see documentation for
#                 change_binding subroutine
# See Also      : _run_binding()
sub _resolve_default_binding {
    my ( $self, $context, $key ) = @_;
    my $key2    = $key;
    $key2 =~ s/^<KeyPress-/</;
    my $binding = (
        defined $context && $context_override_binding{$context}
            && ( $context_override_binding{$context}{$key}
                || $context_override_binding{$context}{$key2} 
               )
        )
        || $default_binding{$key}
        || $default_binding{$key2};
    return $binding;
}

#######################################################################################
# Usage         : TrEd::Binding::Default::_run_binding($mw, $default_binding, $key, @args)
# Purpose       : Run binding for key $key in current context
# Returns       : Undef/empty list
# Parameters    : Tk::Widget ref $mw -- reference to Tk::Widget to which the binding is attached
#                 TrEd::Binding::Default ref $default_binding -- default binding object
#                 string $key        -- string representation of key event
#                 list @args         -- extra arguments to pass to callback
# Throws        : no exception
# Comments      : This obscure order of parameters is used because it is a Tk callback
# See Also      : _resolve_default_binding(), get_binding()
#sub default_binding
sub _run_binding {
    my ( $mw, $default_binding, $key, @args ) = @_;
    my $grp_ref = $default_binding->{grp_ref};
    #TODO: sth like TrEd::Context->current_context() would be nicer, but we need $grp anyway...
    my $context = $grp_ref->{focusedWindow}->{macroContext};
    
    my $binding = $default_binding->_resolve_default_binding( $context, $key );
    if ( ref( $binding->[0] ) eq 'CODE' ) {
        $binding->[0]->( $mw, $grp_ref, $key, @args );
    }
    elsif ( ref( $binding->[0] ) eq 'Tk::Callback' ) {
        $binding->[0]->Call( $mw, $grp_ref, $key, @args );
    }
    return;
}

#######################################################################################
# Usage         : $default_binding->change_binding($context, $key, $new_binding)
# Purpose       : Change the default binding for key $key in context $context to 
#                 $new_binding
# Returns       : Reference to array which contains configuration of previous binding
# Parameters    : string $context        -- name of the context
#                 string $key            -- string representation of key
#                 array_ref $new_binding -- specification of new binding
# Throws        : croaks if the $new_binding is not a valid binding
# Comments      : The new binding can be specified in an array reference with 
#                 two elements: 
#                   1. a) code reference
#                      b) array reference (as used for Tk callbacks). 
#                         In this case, new Tk::Callback is created.
#                   2. string description of performed action 
#                 To change default binding, string '*' can be used as context name
# See Also      : get_binding(), default_binding()
#sub change_default_binding
sub change_binding {
    my ( $self, $context, $key, $new_binding ) = @_;
    
    if (0) {#!binding_valid($new_binding)) {
        croak "Invalid binding for context $context, key <$key> , must be [code, description]!";
    }
    
    my $binding;
    if ( $context && $context eq $DEFAULT_CONTEXT ) {
        $binding = $default_binding{"<$key>"}
                 || $default_binding{"<KeyPress-$key>"};
        return if ! $binding;
    }
    else {
        $binding 
            = $context_override_binding{$context}{"<KeyPress-$key>"}
            || ( 
                 $context_override_binding{$context}{"<$key>"} ||= [] 
               );
    }
    my $prev_binding = [ @{$binding}[ 0, 1 ] ];
    if ( ref($new_binding) eq 'ARRAY' ) {
        if ( ref( $new_binding->[0] ) eq 'ARRAY' ) {
            $binding->[0] = Tk::Callback->new( $new_binding->[0] );
        }
        else {
            $binding->[0] = $new_binding->[0];
        }
        $binding->[1] = $new_binding->[1];
    }
    return $prev_binding;
}

#######################################################################################
# Usage         : $default_bindings->get_binding($grp_ref, $context, $key)
# Purpose       : Find default binding for key $key in context $context
# Returns       : Reference to (possibly empty) array which contains two elements: 
#                   1. code ref (a callback) for specified key and context
#                   2. description of performed action
# Parameters    : string $context -- name of the context
#                 string $key     -- string description of key used to invoke callback 
# Throws        : no exception
# Comments      : 
# See Also      : change_binding(), _run_binding()
#sub get_default_binding {
sub get_binding {
    my ( $self, $context, $key ) = @_;
    return [] if (!defined $key);
    my $binding;
    if ( $context && $context eq $DEFAULT_CONTEXT ) {
        $binding = $default_binding{"<KeyPress-$key>"} 
               || $default_binding{"<$key>"};
    }
    elsif ( $context && $context_override_binding{$context} ) {
        my $context_override_binding = $context_override_binding{$context};
        $binding = $context_override_binding->{"<KeyPress-$key>"}
                 || $context_override_binding->{"<$key>"};
    }
    return $binding ? [ @{$binding}[ 0, 1 ] ] : [];
}


#######################################################################################
# Usage         : $default_binding->setup_default_bindings()
# Purpose       : Create default bindings for TrEd (mainly its toolbar) using 'my' bindtag
# Returns       : Undef/empty list
# Parameters    : no
# Throws        : no exception
# Comments      : The default bindings are stored in an multi-dimensional array in this
#                 source code file.
# See Also      : get_binding(), change_binding()
sub setup_default_bindings {
    my ($self) = @_;

    # setup default binding
    while ( my ( $key, $def ) = each %default_binding ) {
        $self->{grp_ref}->{ $def->[2] || 'Toolbar' }
            ->bind( 'my', $key => [ \&_run_binding, $self, $key  ] );
    }
    return;
}

#######################################################################################
# Usage         : $default_binding->get_default_bindings()
# Purpose       : Return reference to hash of default bindings
# Returns       : Reference to hash of default bindings
# Parameters    : no
# Throws        : no exception
# Comments      : The format of returned bindings hash is as follows:
#                   "<key-pressed>" => [
#                                           sub {},
#                                           "action description",
#                                           "name_of_affected_widget" -- optional 
#                                       ]
# See Also      : get_binding(), change_binding()
sub get_default_bindings {
    my ($self) = @_;
    return \%default_binding;
}

#######################################################################################
# Usage         : $default_binding->get_context_bindings($context)
# Purpose       : Return reference to hash of bindings for specified $context
# Returns       : Reference to hash of context-specific bindings
# Parameters    : string $context -- name of the context
# Throws        : no exception
# Comments      : The format of returned bindings hash is as follows:
#                   "<key-pressed>" => [
#                                           sub {},
#                                           "action description",
#                                           "name_of_affected_widget" -- optional 
#                                       ]
# See Also      : get_binding(), change_binding()
sub get_context_bindings {
    my ($self, $context) = @_;
    return if (!defined $context);
    return $context_override_binding{$context};
}

#######################################################################################
# Usage         : binding_valid($binding_ref)
# Purpose       : Test whether the $binding_ref is a valid binding for purposes of 
#                 TrEd's bindings functionality
# Returns       : 1 if $binding_ref can be used as argument of change_binding() subroutine,
#                 0 otherwise
# Parameters    : array_ref $binding_ref -- binding specification
# Throws        : no exception
# Comments      : For correct binding format, see documentation for change_binding() subroutine
# See Also      : get_binding(), change_binding()
sub binding_valid {
    my ($binding_ref) = @_;
    return if (! defined $binding_ref);
    if (ref $binding_ref eq 'ARRAY' 
        && (ref $binding_ref->[0] eq 'CODE' 
            || ref($binding_ref->[0]) eq 'ARRAY' 
                && scalar grep { ref eq 'CODE' } @{$binding_ref->[0]}[0,1]
            )
       )
    { 
        return 1;
    }
    else {
        return;
    }
}

1;

__END__

=head1 NAME


TrEd::Binding::Default - Setting, changing and resolving TrEd's default key bindings subroutines


=head1 VERSION

This documentation refers to 
TrEd::Binding::Default version 0.1.


=head1 SYNOPSIS



=head1 DESCRIPTION

The key bindings in TrEd's GUI use the bindings system provided by Tk library. 
To manage the bindings, this module has been created. 
The bindings configuration is stored in two hashes. The first one stores default bindings 
and it is used for special context called "*". Besides the default beindings, 
there also exist context specific bindings which are stored separately in the second hash. 

The hashes used to store the bindings have following structure:

The key of the hash is the identification of the key used to invoke the action, 
e.g. <Tab>', '<Shift-ISO_Left_Tab>', '<period>', '<Shift-Home>', etc.

The value of the hash is a reference to array, which contains 2 or 3 elements, the last one 
is optional.
The 1st element is a code reference, i.e. the action invoked by the key (combination)
The 2nd element is a name of the action.
The 3rd element is a name of the widget, to which the binding applies. It has to be one of the 
widgets stored in $grp_ref (e.g. 'Toolbar' for $grp_ref->{Toolbar}), 
since the binding is created by calling the bind subroutine on one of these Tk objects. 

The hash used to store context specific information has one more level which divides
the bindings in specific contexts.

=head1 SUBROUTINES/METHODS

=over 4 



=back


=head1 DIAGNOSTICS

Croaks "Default binding constructor needs reference toTrEd hash" if the constructor's argument is not a reference
Croaks "Invalid binding for context $context, key <$key> , must be [code, description]!" if the binding given to 
change_binding subroutine can not be used properly.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.

=head1 DEPENDENCIES

CPAN modules:
Tk,
Readonly

TrEd modules:


Standard Perl modules:
Carp

=head1 INCOMPATIBILITIES

No known incompatibilities.


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
