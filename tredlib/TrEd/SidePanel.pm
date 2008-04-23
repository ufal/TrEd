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

sub equalize_sizes {
  my ($self)=@_;
  my @shown = grep { $_->is_shown } $self->widgets;
  return unless @shown;
  my $height = $self->frame->height;
  $height -= $_->button->height for $self->widgets;
  $height=0 if $height<0;
  my $equal_size = $height/@shown;
  for my $w (@shown) {
    next unless $w->adjuster_packed;
    $w->adjuster->delta_height($equal_size-$w->height)
  }
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
    -borderwidth => 0,
    -pady => 0,
    -padx => 0,
    -command => [$self,'toggle']
  )->pack(-fill => 'x',-side=>'top');
  weaken($self->{button}=$button);
  weaken($self->{adjuster}=$panel_frame->Adjuster(-side=>'top', -widget=> $tk_widget));
  weaken($self->{panel});
  return $self;
}

sub height {
  my ($self)=@_;
  return 0 unless $self->{shown};
  my $h =  $self->widget->height;
  if ($self->adjuster_packed) {
    $h+=$self->adjuster->reqheight+18;
  }
  return $h;
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

  my $adj = $self->adjuster;
  if ($self->adjuster_packed and $adj->viewable) {
    $h=$self->widget->reqheight+$adj->reqheight;
  }
  $self->button->configure(-foreground=>'#555');
  $self->unpack_adjuster;
  $self->widget->packForget;
  $self->{shown}=0;
#  if ($h) {
    $self->panel->frame->afterIdle(sub {
				     my $next = $self->find_next_widget(1);
				     my $prev=$self->find_previous_widget(1);
#				     my $nearest = $prev || $next;
#				     if ($h and $nearest) {
#				       $nearest->adjuster->delta_height($h) if $nearest->adjuster_packed;
#				     }
				     if (!$next and $prev) {
				       $prev->unpack_adjuster;
				       $prev->widget->packConfigure(-expand=>1);
				     }
				     $self->panel->equalize_sizes();
				   });
#  }
  return 1;
}

sub show {
  my ($self)=@_;
  return if $self->is_shown;
  $self->button->configure(-foreground=>'black');
  my $w = $self->widget;
  $w->pack(-after=>$self->button, -fill=>'both', -expand => 1,-side=>'top');
  my $next = $self->find_next_widget(1);
  my $h=0;
  $self->{shown}=1;
  if ($next) {
    $self->pack_adjuster;
    $h+=$self->adjuster->reqheight+18;
  } else {
    my $prev=$self->find_previous_widget(1);
    if ($prev) {
      $prev->pack_adjuster;
      $h+=$prev->adjuster->reqheight+18;
    }
  }
  $w->afterIdle([$self->panel,'equalize_sizes']);
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
  return unless $self->is_shown or $self->adjuster_packed;
  $self->adjuster->pack(-after => $self->widget,-side=>'top',-expand => 0,-fill => 'x');
}
sub unpack_adjuster {
  my ($self)=@_;
  return unless $self->is_shown and $self->adjuster_packed;
  $self->adjuster->packForget;
}
sub adjuster_packed {
  my ($self)=@_;
  #  return   $self->{adjuster_packed};
  return $self->adjuster->{master} ? 1 : 0;
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

