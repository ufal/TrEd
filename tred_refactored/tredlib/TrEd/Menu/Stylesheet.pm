package TrEd::Menu::Stylesheet;

use strict;
use warnings;

use TrEd::Utils;
use TrEd::Basics qw{$EMPTY_STR};

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
# Usage         : update_context_list($grp)
# Purpose       : Update list of contexts in context menu, set $grp->{selectedContext}
#                 according to allowed contexts and switch context
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : No exception
# Comments      : 
# See Also      : is_focused(), fsfileDisplayingWindows()
sub update {
    my ($self, $grp) = @_;
    return if $self->dont_update();
    if ( ref( $self->{menu} ) ) {
        $self->{menu}
            ->configure( -options => $self->get_menu_list($grp) );
    }
}

#TODO: mali by sme nahradit $grp->{stylesheets} za parameter @stylesheets alebo volanie TrEd::Stylesheet::get_shitz
# podobne pre $context a 
sub get_menu_list {
    my ( $self, $grp, $all ) = @_;
    my $context = $grp->{focusedWindow}->{macroContext};
    undef $context if $context eq 'TredMacro';
    my $match;
    return [   TrEd::Utils::STYLESHEET_FROM_FILE(),
               TrEd::Utils::NEW_STYLESHEET(),
               TrEd::Utils::DELETE_STYLESHEET(),
               grep {
                   if ( $all or !defined($context) ) {
                       1;
                   }
                   else {       # TrEd::Stylesheet::get_stylesheet_context($_)?
                       $match = $grp->{stylesheets}{$_}{context} || $EMPTY_STR;
                       chomp $match;
                       $match = '.*' if (!$match =~ /\S/);
                       $context =~ /^${match}$/x ? 1 : 0;
                   }
               } sort keys %{ $grp->{stylesheets} }
           ];
}

#sub updateStylesheetMenu {
#  my ($grp)=@_;
#  return if $grp->{noUpdateStylesheetMenu};
#  if (ref($grp->{StylesheetMenu})) {
#    $grp->{StylesheetMenu}->configure(-options => getStylesheetMenuList($grp));
#  }
#}
#
#sub getStylesheetMenuList {
#  my ($grp,$all)=@_;
#  my $context=$grp->{focusedWindow}->{macroContext};
#  undef $context if $context eq 'TredMacro';
#  my $match;
#  [TrEd::Utils::STYLESHEET_FROM_FILE(),TrEd::Utils::NEW_STYLESHEET(),TrEd::Utils::DELETE_STYLESHEET(),
#   grep { 
#     if ($all or !defined($context)) { 1 } else {
#       $match = $grp->{stylesheets}{$_}{context} || $EMPTY_STR;
#       chomp $match;
#       $match = '.*' if (!$match =~ m/\S/);
#       $context =~ /^${match}$/x ? 1 : 0;
#     }
#   } sort keys %{$grp->{stylesheets}}];
#}

1;