package Tk::CodeText::TrEdConfig;

use vars qw($VERSION);
$VERSION = '0.1'; # Initial release;

use strict;
use warnings;
use base('Tk::CodeText::Template');
use List::Util qw(first);

sub new {
  	my ($proto, $rules) = @_;
  	my $class = ref($proto) || $proto;
	my $plain_bg = 'lightgray';
	if (not defined($rules)) {
		$rules =  [
		  ['Text', -foreground => 'red'],
		  ['Option', -foreground => 'darkblue'],
		  ['Value', -foreground => 'black'],
		  ['Quot', -foreground => 'brown'],
		  ['Comment', -foreground => 'gray40'],
		  ['StrongComment', -foreground => 'orange'],
		  ['Equal', -foreground => 'darkgreen'],
		  ['Variable', -foreground => 'darkmagenta'],
		  ['Invalid', -foreground => 'red'],
		  ['Empty'],
		 ];
	};
	my $self = $class->SUPER::new($rules);
  	bless ($self, $class);
	$self->callbacks({
		'Text' => \&parseText,
		'Option' => \&parseDummy,
		'Value' => \&parseDummy,
		'Quot' => \&parseQuot,
		'Comment' => \&parseDummy,
		'StrongComment' => \&parseDummy,
		'Equal' => \&parseDummy,
		'Variable' => \&parseDummy,
		'Invalid' => \&parseDummy,
		'Empty' => \&parseDummy,
	});
	$self->stackPush('Text');
  	return $self;
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

sub parseDummy {
    my ($self, $txt) = @_;
    return $self->parserError($txt); #for debugging your later additions
}

sub parseText {
  my ($self, $text) = @_;

  if ($text =~ /^\s*[;\#]/) {
    $self->snippetParse($text, $text=~/\(DO NOT EDIT\)/ ?
			  'StrongComment' : 'Comment');
    return '';
  }
  if ($text=~s/^ 
      (\s*[a-zA-Z_]+[a-zA-Z_0-9]*(::[a-zA-Z_]+[a-zA-Z_0-9:]*)?) # ($1 ($2))
      (\s*=\s*)                                                 # ($3)
      (?:
        (' (?: [^\\\'] | \\. )* '                               # ($4)
         |
         " (?: [^\\\"] | \\. )* "
        )
        |
        ((?:\s* (?: [^;\\\s] | \\. )+ )*)                       # ($5)
      )
      (\s* ;.* )?                                               # ($6)
    //x) {
    my ($name, $nspart, $eq, $quot, $val, $comm) =
       ($1,    $2,    $3,  $4,    $5,   $6);

    $self->snippetParse($name, $nspart ? 'Variable' : 'Option');
    $self->snippetParse($eq, 'Equal');
    $self->snippetParse($quot, 'Quot') if defined $quot;
    $self->snippetParse($val, 'Value') if defined $val;
    $self->snippetParse($comm, $comm=~/\(DO NOT EDIT\)/ ? 
         'StrongComment' : 'Comment') if defined $comm;
  }
  if (length $text) {
    $self->snippetParse($text, 'Invalid');
  }
  return ''
}

1;

__END__


=head1 NAME

Tk::CodeText::TrEdConfig - a Plugin for TrEd stylesheet syntax highlighting

=head1 SYNOPSIS

 require Tk::CodeText::TrEdConfig;
 my $sh = new Tk::CodeText::TrEdConfig( [
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

Tk::CodeText::TrEdConfig is a plugin module that provides syntax
highlighting for TrEd stylesheets to a Tk::CodeText text widget.

It inherits Tk::CodeText::Template. See also there.

=head1 AUTHOR

Petr Pajas

=cut

=head1 BUGS

Unknown

=cut
