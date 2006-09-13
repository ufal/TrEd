package Tk::CodeText::TrEdStylesheet;

use vars qw($VERSION);
$VERSION = '0.2';

use strict;
use warnings;
use base('Tk::CodeText::Template');

our ($block, $bblock, $nqblock, $nqqblock);
$block  = qr/\{((?:(?> [^{}]* )|(??{ $block }))*)\}/x;
$nqblock  = qr/\{((?:(?> (?:[^{}\'\\]+ | \\. )* )|(??{ $nqblock }))*)\}/x;
$nqqblock  = qr/\{((?:(?> (?:[^{}\"\\]+ | \\. )* )|(??{ $nqqblock }))*)\}/x;

sub new {
  	my ($proto, $rules) = @_;
  	my $class = ref($proto) || $proto;
	my $plain_bg = 'lightgray';
	if (not defined($rules)) {
		$rules =  [
		  ['Text', -foreground => 'brown', -background => $plain_bg],
		  ['Attribute', -foreground => 'darkblue', -background => $plain_bg],
		  ['Style', -foreground => 'darkgreen', -background=>$plain_bg],
		  ['Label', -foreground => 'black', -background => 'darkgrey', underline => 1 ],
		  ['Code', -foreground => 'black' ],
		  ['String', -foreground => 'brown' ],
		  ['QString', -foreground => 'brown' ],
		  ['CAttribute', -foreground => 'darkblue' ],
		  ['CStyle', -foreground => 'darkgreen'],
		  ['QAttribute', -foreground => 'darkblue' ],
		  ['QStyle', -foreground => 'darkgreen'],
		  ['Comment', -foreground => 'gray40' ],
		  ['Variable', -foreground => 'blue'],
		  ['Empty'],
		 ];
	};
	my $self = $class->SUPER::new($rules);
  	bless ($self, $class);
	$self->callbacks({
		'Text' => \&parseText,
		'Label' => \&parseLabel,
		'Code' => \&parseCode,
		'String' => \&parseString,
		'QString' => \&parseQString,

		'QStyle' => \&parseDummy,
		'QAttribute' => \&parseDummy,
		'CStyle' => \&parseDummy,
		'Attribute' => \&parseDummy,
		'Style' => \&parseDummy,
		'CAttribute' => \&parseDummy,
		'Comment' => \&parseDummy,
		'Variable' => \&parseDummy,
	});
	$self->stackPush('Label');
  	return $self;
}

sub parseDummy {
    my ($self, $txt) = @_;
    return $self->parserError($txt); #for debugging your later additions
}

# fix a bug in Template:
sub snippetParse {
  my $hlt = shift;
  my $snip = shift;
  my $attr = shift;
  unless (defined($snip)) { $snip = $hlt->snippet }
  unless (defined($attr)) { $attr = $hlt->stackTop }
  my $out = $hlt->{'out'};
  if (length $snip) {
    push(@$out, length($snip), $attr);
    $hlt->snippet('');
  }
}

sub parseCode {
  my ($self, $text) = @_;
  if ($text =~ s/^([?][>])//) { #code stop
    $self->snippetParse($1);
    $self->stackPull;
    $self->restart unless length $text;
    return $text;
  }
  if ($text =~ s/^(\#.*)//) { #comment
    $self->snippetParse($1, 'Comment');
    return $text;
  }
  if ($text =~ s/^(\'(?:[^\\\'\#\$]+|\\[^\$\#])*)//) { #string start
      $self->stackPush('String');
      $self->snippetParse($1);
    return $text;
  }
  if ($text =~ s/^(\"(?:[^\\\"\#]+|\\[^\$\#])*)//) { #string start
    $self->stackPush('QString');
    $self->snippetParse($1);
    return $text;
  }
  if ($text =~ s/^(\$\$$block)//) { #attribute
    $self->snippetParse($1, 'CAttribute');
    return $text;
  }
  if ($text =~ s/^(\$(?:this|root|grp))//) {
    $self->snippetParse($1, 'Variable');
    return $text;
  }
  if ($text =~ s{^(\\.|[^\\])}{}) {
    $self->snippetParse($1);
    return $text;
  }
  return $self->parserError($text);
}

sub parseLabel {
  my ($self, $text) = @_;
  if ($text =~ s/^([a-zA-Z]+:)//) { #label
    $self->snippetParse($1, 'Label');
    if ($text =~ s/^(\s*)//) {
      $self->snippetParse($1,'Empty');
    }
  }
  $self->stackPush('Text');
  return $self->parseText($text);
}

sub restart {
  my ($self) = @_;
  if ($self->stateCompare(['Text','Label'])) {
    $self->stackPull;
  }
}

sub parseText {
  my ($self, $text) = @_;
  if ($text =~ s/^(\s+)//) { #spaces
    $self->snippetParse($1);
  }
  elsif ($text =~ s/^([<][?])//) { #backticked
    $self->stackPush('Code');
    $self->snippetParse($1);
    
    return $text;
  }
  elsif ($text =~ s/^(\$$block)//) { #attribute
    $self->snippetParse($1, 'Attribute');
  }
  elsif ($text =~ s/^(\#$block)//) { #attribute
    my $style = $1;
    $self->snippetParse($style, 'Style');
  }
  elsif ($text =~ s/^([^<>\#{}\$]+)//) {
    $self->snippetParse($1);
  }
  elsif ($text =~ s/^(.|$)//) {
    $self->snippetParse($1) if length $1;
  }
  else {
    return $self->parserError($text);
  }
  $self->restart unless length $text;
  return $text;
}

sub parseQString {
  my ($self, $text) = @_;
  if ($text =~ s/^((?:[^\\\"\#]+|\\[^\$])+)//) { #string content
    $self->snippetParse($1);
    return $text;
  }
  if ($text =~ s/^(\")//) { #string stop
    $self->snippetParse($1);
    $self->stackPull;
    return $text;
  }
  if ($text =~ s/^(\\\$$nqqblock)//) { #attribute
    $self->snippetParse($1, 'QAttribute');
    return $text;
  }
  if ($text =~ s/^(\\?\#$nqqblock)//) { #attribute
    $self->snippetParse($1, 'QStyle');
    return $text;
  }  
  if ($text =~ s/^([^\\]|\\.)//) {
    $self->snippetParse($1);
    return $text;    
  }
  return $self->parserError($text);
}

sub parseString {
  my ($self, $text) = @_;
  if ($text =~ s/^((?:[^\\\'\#\$]+|\\[^\#\$])+)//) { #string content
    $self->snippetParse($1);
    return $text;
  }
  if ($text =~ s/^(\')//) { #string stop
    $self->snippetParse($1);
    $self->stackPull;
    return $text;
  }
  if ($text =~ s/^(\\?\$$nqblock)//) { #attribute
    $self->snippetParse($1, 'CAttribute');
    return $text;
  }
  if ($text =~ s/^(\\?\#$nqblock)//) { #attribute
    $self->snippetParse($1, 'CStyle');
    return $text;
  }  
  if ($text =~ s/^([^\\]|\\.)//) {
    $self->snippetParse($1);
    return $text;    
  }

  return $self->parserError($text);
}



1;

__END__


=head1 NAME

Tk::CodeText::TrEdStylesheet - a Plugin for TrEd stylesheet syntax highlighting

=head1 SYNOPSIS

 require Tk::CodeText::TrEdStylesheet;
 my $sh = new Tk::CodeText::TrEdStylesheet( [
   ['Text', -foreground => 'brown'],
   ['Attribute', -foreground => 'darkblue'],
   ['Style', -foreground => 'darkgreen'],
   ['Label', -foreground => 'black', underline => 1 ],
   ['Code', -foreground => 'black' ],
   ['String', -foreground => 'brown' ],
   ['QString', -foreground => 'brown' ],
   ['CAttribute', -foreground => 'darkblue' ],
   ['CStyle', -foreground => 'darkgreen'],
   ['Comment', -foreground => 'gray40' ],
   ['Variable', -foreground => 'blue'],
   ['Empty'],
 ]);

=head1 DESCRIPTION

Tk::CodeText::TrEdStylesheet is a plugin module that provides syntax
highlighting for TrEd stylesheets to a Tk::CodeText text widget.

It inherits Tk::CodeText::Template. See also there.

=head1 AUTHOR

Petr Pajas

=cut

=head1 BUGS

Unknown

=cut
