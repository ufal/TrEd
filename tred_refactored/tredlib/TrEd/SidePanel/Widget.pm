package TrEd::SidePanel::Widget;

use strict;
use warnings;

our $VERSION = '0.01';
use Scalar::Util qw(weaken);

sub new {
    my ( $class, $tk_widget, $opts ) = @_;
    my $panel       = $opts->{panel};
    my $panel_frame = $panel->frame;
    my $label       = delete $opts->{-label};
    my $self        = bless {
        %$opts,
        widget => $tk_widget,
        shown  => 0,
    }, $class;
    my $button = $panel_frame->Button(
        -text        => $label,
        -anchor      => 'w',
        -relief      => 'flat',
        -foreground  => '#555',
        -borderwidth => 0,
        -pady        => 0,
        -padx        => 0,
        -command     => [ $self, 'toggle' ]
    )->pack( -fill => 'x', -side => 'top' );
    weaken( $self->{button} = $button );
    weaken( $self->{adjuster}
            = $panel_frame->Adjuster( -side => 'top', -widget => $tk_widget )
    );
    weaken( $self->{panel} );
    return $self;
}

sub height {
    my ($self) = @_;
    return 0 unless $self->{shown};
    my $h = $self->widget->height;
    if ( $self->adjuster_packed ) {
        $h += $self->adjuster->reqheight + 18;
    }
    return $h;
}

sub is_shown {
    my ($self) = @_;
    return $self->{shown};
}

sub toggle {
    my ($self) = @_;
    if ( $self->is_shown ) {
        $self->hide;
    }
    else {
        $self->show;
    }
}

sub find_previous_widget {
    my ( $self, $shown ) = @_;
    my @w = $self->panel->widgets;
    if ($shown) {
        @w = grep { $_->is_shown or $_ == $self } @w;
    }
    my $prev;
    for my $w (@w) {
        if ( $w == $self ) {
            return $prev;
        }
        $prev = $w;
    }
    return;
}

sub find_next_widget {
    my ( $self, $shown ) = @_;
    my @w = $self->panel->widgets;
    if ($shown) {
        @w = grep { $_ == $self or $_->is_shown } @w;
    }
    my $prev;
    for my $w (@w) {
        if ( $prev and $prev == $self ) {
            return $w;
        }
        $prev = $w;
    }
    return;
}

sub hide {
    my ($self) = @_;
    return unless $self->is_shown;
    my $h = 0;

    my $adj = $self->adjuster;
    if ( $self->adjuster_packed and $adj->viewable ) {
        $h = $self->widget->reqheight + $adj->reqheight;
    }
    $self->button->configure( -foreground => '#555' );
    $self->unpack_adjuster;
    $self->widget->packForget;
    $self->{shown} = 0;

    #  if ($h) {
    $self->panel->frame->afterIdle(
        sub {
            my $next = $self->find_next_widget(1);
            my $prev = $self->find_previous_widget(1);

#				     my $nearest = $prev || $next;
#				     if ($h and $nearest) {
#				       $nearest->adjuster->delta_height($h) if $nearest->adjuster_packed;
#				     }
            if ( !$next and $prev ) {
                $prev->unpack_adjuster;
                $prev->widget->packConfigure( -expand => 1 );
            }
            $self->panel->equalize_sizes();
        }
    );

    #  }
    return 1;
}

sub show {
    my ($self) = @_;
    return if $self->is_shown;
    $self->button->configure( -foreground => 'black' );
    my $w = $self->widget;
    $w->pack(
        -after  => $self->button,
        -fill   => 'both',
        -expand => 1,
        -side   => 'top'
    );
    my $next = $self->find_next_widget(1);
    my $h    = 0;
    $self->{shown} = 1;

    if ($next) {
        $self->pack_adjuster;
        $h += $self->adjuster->reqheight + 18;
    }
    else {
        my $prev = $self->find_previous_widget(1);
        if ($prev) {
            $prev->pack_adjuster;
            $h += $prev->adjuster->reqheight + 18;
        }
    }
    $w->afterIdle( [ $self->panel, 'equalize_sizes' ] );

#     sub {
# 		  my $nearest = $self->find_previous_widget(1) || $self->find_next_widget(1);
# 		  if ($nearest) {
# 		    my $h = ($nearest->widget->height+$nearest->button->height+$nearest->adjuster->height+18)/2;
# 		    my $reqh = $self->button->height + $w->reqheight + $h;
# 		    $h=$reqh unless $reqh>$h;
# 		    if ($nearest->adjuster_packed) {
# 		      $nearest->adjuster->delta_height(-$h);
# 		    } elsif ($self->adjuster_packed) {
# 		      $self->adjuster->delta_height(-$h);
# 		    }
# 		  }
# 		});
    my $command = $self->{-show_command};
    if ( ref($command) eq 'CODE' ) {
        $command->();
    }
    elsif ( ref($command) eq 'ARRAY' ) {
        my ( $cmd, @args ) = @$command;
        $cmd->(@args);
    }
    return 1;
}

sub pack_adjuster {
    my ($self) = @_;
    return unless $self->is_shown or $self->adjuster_packed;
    $self->adjuster->pack(
        -after  => $self->widget,
        -side   => 'top',
        -expand => 0,
        -fill   => 'x'
    );
}

sub unpack_adjuster {
    my ($self) = @_;
    return unless $self->is_shown and $self->adjuster_packed;
    $self->adjuster->packForget;
}

sub adjuster_packed {
    my ($self) = @_;

    #  return   $self->{adjuster_packed};
    return $self->adjuster->{master} ? 1 : 0;
}

sub data {
    my ($self) = @_;
    return $self->{-data};
}

sub widget {
    my ($self) = @_;
    return $self->{widget};
}

sub button {
    my ($self) = @_;
    return $self->{button};
}

sub panel {
    my ($self) = @_;
    return $self->{panel};
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub adjuster {
    my ($self) = @_;
    return $self->{adjuster};
}

1;
