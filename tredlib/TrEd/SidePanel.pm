package TrEd::SidePanel;

# pajas@ufal.mff.cuni.cz          15 dub 2008


use strict;
use warnings;
use Carp;
use Tk::Adjuster;

our $VERSION = '0.01';

sub new {
  my ($class,$parent,$opts) = @_;
  $opts||={};
  croak("Usage: ".__PACKAGE__."->new(\$parent_widget)") unless (ref($parent) and UNIVERSAL::isa($parent,'Tk::Widget'));
  return bless {
    %$opts,
    frame => $parent->Frame(),
    widget_names => [],
    widgets => {},
  }, $class;
}

sub widget_names {
  my ($self)=@_;
  return @{$self->{widget_names}};
}

sub widgets {
  my ($self)=@_;
  my $widgets = $self->{widgets};
  return map {$widgets->{$_}} @{$self->{widget_names}};
}

sub widget {
  my ($self, $name)=@_;
  return $self->{widgets}{$name};
}

sub frame {
  my ($self)=@_;
  return $self->{frame};
}

sub add {
  my ($self,$name,$tk_widget,$opts) =@_;
  croak(__PACKAGE__."->add: item named '$name' already exists") if $self->widget($name);
  $opts||={};
  my $before = delete $opts->{-before};
  my $after = delete $opts->{-after};
  if (defined($after) and defined($before)) {
    croak(__PACKAGE__."->add: use either -after or -before, not both");
  }

  $opts->{-label}||=$name;
  $opts->{name}=$name;
  $opts->{panel} = $self;

  my $w = TrEd::SidePanel::Widget->new($tk_widget,$opts);
  if (defined($after) or defined($before)) {
    my $ref = defined($after) ? $after : $before;
    croak(__PACKAGE__."->add: item named '$ref' not found") unless $self->widget($ref);
    @{$self->{widget_names}} = map { $_ eq $ref ? ( defined($after) ? ($_,$name) : ($name,$_) ) : $_ } @{$self->{widget_names}};
  } else {
    push @{$self->{widget_names}}, $name;
  }
  $self->{widgets}{$name}=$w;
  return $w;
}

sub remove {
  my ($self, $name) =@_;
  @{$self->{widget_names}} = grep { $_ ne $name } @{$self->{widget_names}};
  return delete $self->{widgets}{$name};
}

sub is_shown {
  my ($self, $name)=@_;
  my $w=$self->{widgets}{$name};
  return unless $w;
  return $w->is_shown;
}

package TrEd::SidePanel::Widget;
use Scalar::Util qw(weaken);
sub new {
  my ($class,$tk_widget,$opts) = @_;
  my $panel = $opts->{panel};
  my $panel_frame = $panel->frame;
  my $label = delete $opts->{-label};
  my $self = bless {
    %$opts,
    widget => $tk_widget,
    shown => 0,
  }, $class;
  my $button = $panel_frame->Button(
    -text=>$label,
    -anchor=>'w',
    -relief=>'flat',
    -foreground=>'#555',
    -pady => 0,
    -command => [$self,'toggle']
  )->pack(-fill => 'x',-side=>'top');
  weaken($self->{button}=$button);
  weaken($self->{adjuster}=$panel_frame->Adjuster(-side=>'top', -widget=> $tk_widget));
  weaken($self->{panel});
  return $self;
}

sub is_shown {
  my ($self)=@_;
  return $self->{shown};
}

sub toggle {
  my ($self)=@_;
  if ($self->is_shown) {
    $self->hide;
  } else {
    $self->show;
  }
}

sub find_previous_widget {
  my ($self,$shown)=@_;
  my @w = $self->panel->widgets;
  if ($shown) {
    @w = grep { $_->is_shown or $_==$self } @w;
  }
  my $prev;
  for my $w (@w) {
    if ($w == $self) {
      return $prev;
    }
    $prev = $w;
  }
  return;
}

sub find_next_widget {
  my ($self,$shown)=@_;
  my @w = $self->panel->widgets;
  if ($shown) {
    @w = grep { $_==$self or $_->is_shown } @w;
  }
  my $prev;
  for my $w (@w) {
    if ($prev and $prev == $self) {
      return $w;
    }
    $prev = $w;
  }
  return;
}

sub hide {
  my ($self)=@_;
  return unless $self->is_shown;
  my $h=0;
  if ($self->adjuster->viewable) {
    $h=$self->widget->reqheight+$self->adjuster->reqheight;
  }
  $self->button->configure(-foreground=>'#555');
  $self->unpack_adjuster;
  $self->widget->packForget;
  $self->{shown}=0;
  if ($h) {
    $self->panel->frame->afterIdle(sub {
				     my $nearest = $self->find_previous_widget(1) || $self->find_next_widget(1);
				     if ($nearest) {
				       $nearest->adjuster->delta_height($h);
				     }
				   });
  }
  return 1;
}

sub show {
  my ($self)=@_;
  return if $self->is_shown;
  $self->button->configure(-foreground=>'black');
  my $w = $self->widget;
  $w->pack(-after=>$self->button, -fill=>'both', -expand => 1,-side=>'top');
  $self->{shown}=1;
  $self->pack_adjuster;
  $w->afterIdle(sub {
		  unless ($self->adjuster->viewable) {
		    my $nearest = $self->find_previous_widget(1) || $self->find_next_widget(1);
		    if ($nearest) {
		      my $h = $nearest->widget->height/2;
		      my $reqh = $w->reqheight + $self->adjuster->reqheight+18;
		      $h=$reqh if $reqh<$h;
		      $nearest->adjuster->delta_height(-$h);
		    }
		  }
		});
  my $command = $self->{-show_command};
  if (ref($command) eq 'CODE') {
    $command->();
  } elsif (ref($command) eq 'ARRAY') {
    my ($cmd,@args)=@$command;
    $cmd->(@args);
  }
  return 1;
}

sub pack_adjuster {
  my ($self)=@_;
  return unless $self->is_shown;
  $self->adjuster->pack(-after => $self->widget,-side=>'top',-expand => 0,-fill => 'x');
}
sub unpack_adjuster {
  my ($self)=@_;
  return unless $self->is_shown;
  $self->adjuster->packForget;
}

sub data {
  my ($self)=@_;
  return $self->{-data};
}

sub widget {
  my ($self)=@_;
  return $self->{widget};
}

sub button {
  my ($self)=@_;
  return $self->{button};
}

sub panel {
  my ($self)=@_;
  return $self->{panel};
}

sub name {
  my ($self)=@_;
  return $self->{name};
}

sub adjuster {
  my ($self)=@_;
  return $self->{adjuster};
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

TrEd::SidePanel - Perl extension for blah blah blah

=head1 SYNOPSIS

   use TrEd::SidePanel;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for TrEd::SidePanel, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

