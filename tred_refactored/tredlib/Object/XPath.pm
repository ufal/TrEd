package Object::XPath;
use XML::XPath;

# [ {id|name|value|parent|children|lbrother|rbrother => sub}, root, $data ]
sub new {
  my ($class, $root, $node, $handlers) = @_;
  $class = ref($class) if ref($class);
  return bless [$handlers,$root,$node], $class;
}

sub find {
    my $node = shift;
    my ($path,$node2) = @_;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new(); # new is v. lightweight
    return $xp->find($path, $node2 || $node);
}

sub findvalue {
    my $node = shift;
    my ($path,$node2) = @_;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new();
    return $xp->findvalue($path, $node2 || $node);
}

sub findnodes {
    my $node = shift;
    my ($path,$node2) = @_;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new();
    return map $_->object, $xp->findnodes($path, $node2 || $node);
}

sub matches {
    my $node = shift;
    my ($path, $context) = @_;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new();
    return $xp->matches($node, $path, $context);
}

sub object {
  return $_[0][2]
}

sub wrap {
  my ($self, $object)=@_;
  return () unless $_[1];
  $self->new($self->[1],$object,$self->[0]);
}

sub getLocalName {
  my ($self)=@_;
  &{$self->[0]{name}}($self->[2]);
}

sub getName {
  my ($self)=@_;
  &{$self->[0]{name}}($self->[2]);
}

sub string_value {
  my ($self)=@_;
  &{$self->[0]{value}}($self->[2]);
}

*getValue = *string_value;

sub getElementById {
  my ($self,$id)=@_;
  $self->wrap(&{$self->[0]{id}}($self->[1],$id));
}

sub getRootNode {
  my ($self)=@_;
  $self->wrap($self->[1]);
}

sub getParentNode {
  my ($self)=@_;
  $self->wrap(&{$self->[0]{parent}}($self->object));
}

sub getAttributes {
  my ($self) = @_;
  my $attribs = &{$self->[0]{attributes}}($self->object);
  my @attribs = map { Object::XPath::Attribute->new($self,$_,$attribs->{$_}) }
    keys %$attribs;
  return wantarray ? @attribs : \@attribs;
}

sub get_global_pos {
  my ($self)=@_;
  &{$self->[0]{pos}}($self->[2]);
}

sub getChildNodes {
  my ($self)=@_;
  my @children =
    map $self->wrap($_), &{$self->[0]{children}}($self->object);
  wantarray ? @children : \@children;
}


sub getNextSibling {
  my ($self)=@_;
  $self->wrap(&{$self->[0]{rbrother}}($self->object));
}

sub getPreviousSibling {
  my ($self)=@_;
  $self->wrap(&{$self->[0]{lbrother}}($self->object));
}

sub isElementNode {

  $_[0]->isa(__PACKAGE__) ? 1 : 0;
}

sub getNamespaces { return wantarray ? () : []; }
sub isTextNode { 0 }
sub isPINode { 0 }
sub isCommentNode { 0 }
sub getNamespace { undef }

package Object::XPath::Attribute;

sub new { # node, name, value
  my $class = shift;
  return bless [@_],$class;
}

sub getElementById { $_[0][0]->getElementById($_[1]) }
sub getLocalName { $_[0][1] }
*getName = *getLocalName;
sub string_value { $_[0][2] }
*getValue = *string_value;

sub getRootNode { $_[0][0]->getRootNode() }
sub getParentNode { $_[0][0] }
sub getNamespace { undef }

1;
