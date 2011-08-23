package TrEd::Menu::Stylesheet;

use strict;
use warnings;

use TrEd::Utils qw{$EMPTY_STR};

use TrEd::Stylesheet;

use Tk;

use Carp;

# TrEd::Utils exported updateStylesheetMenu and getStylesheetMenuList
# although I think it is not necessary, so no exporting from here for now

sub new {
    my ($class, $grp) = @_;
    if (!ref $grp) {
        croak("Stylesheet menu constructor needs reference to TrEd hash");
    }
    my $menu = $grp->{Toolbar}->
        Optionmenu(-options=> [],
                    -font           => 'C_small',
                    -textvariable   => \$grp->{selectedStylesheet},
                    -command        => [\&_switch_stylesheet_callback, $grp], #option value is appended to args
                    -relief         => 'groove', #$menubarRelief,
                    -borderwidth=> 2)->pack(qw/-side right -padx 3/);
    $menu->menu->bind("<KeyPress>", [\&main::NavigateMenuByFirstKey,Tk::Ev('K')]);
    my $obj = {
        menu      => $menu,
        no_update => undef,
    };
    return bless $obj, $class;
}

sub _switch_stylesheet_callback {
    my ($grp,$stylesheet) = @_;
    main::switchStylesheet($grp, $stylesheet);
}

sub get_menu {
    my ($self) = @_;
    return $self->{menu};
}

sub dont_update {
    my ($self) = @_;
    return $self->{no_update};
}

sub set_dont_update {
    my ($self, $no_update) = @_;
    $self->{no_update} = $no_update;
}

#######################################################################################
# Usage         : update($grp)
# Purpose       : ...
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : No exception
# Comments      :
# See Also      : ...
sub update {
    my ($self, $grp) = @_;
    return if $self->dont_update();
    if ( ref( $self->{menu} ) ) {
        $self->{menu}
            ->configure( -options => $self->get_menu_list($grp) );
    }
}

# podobne pre $context a
sub get_menu_list {
    my ( $self, $grp, $all ) = @_;
    my $context = $grp->{focusedWindow}->{macroContext};
    if (defined $context && $context eq 'TredMacro') {
        undef $context;
    }
    my $match;
    return [   TrEd::Stylesheet::STYLESHEET_FROM_FILE(),
               TrEd::Stylesheet::NEW_STYLESHEET(),
               TrEd::Stylesheet::DELETE_STYLESHEET(),
               grep {
                   if ( $all or !defined($context) ) {
                       1;
                   }
                   else {       # TrEd::Stylesheet::get_stylesheet_context($_)?
                       $match = $grp->{stylesheets}{$_}{context} || $EMPTY_STR;
                       chomp $match;
                       if (!$match =~ /\S/) {
                        $match = '.*';
                       }
                       $context =~ /^${match}$/x ? 1 : 0;
                   }
               } sort keys %{ $grp->{stylesheets} }
           ];
}

1;