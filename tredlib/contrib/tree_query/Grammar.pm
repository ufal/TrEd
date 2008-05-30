package Tree_Query::Grammar;
use Parse::RecDescent;

{ my $ERRORS;


package Parse::RecDescent::Tree_Query::Grammar;
use strict;
use vars qw($skip $AUTOLOAD  );
@Parse::RecDescent::Tree_Query::Grammar::ISA = ();
$skip = '\s*';

      $skip = '\s*(?:[#][^\n]*\s*)?';

      {
	package Tree_Query::ParserError;
	use overload '""' => \&as_text;
	sub new {
	  my $class=shift;
	  my $array_ref = shift;
	  bless $array_ref, $class;
	}
	sub as_text {
	  my $self = shift;
	  return 'Parse error at line '.$self->line.': '.$self->message;
	}
	sub message { return $_[0]->[0] }
	sub line    { return $_[0]->[1] }
      }

      sub report_error {
        my $thisparser = shift;
        die Tree_Query::ParserError->new($thisparser->{errors}[0]);
      }
      sub new_node {
        my ($hash,$children)=@_;
        my $new = FSNode->new($hash,1);
        if ($children) {
          if (ref($children) eq 'ARRAY') {
             for (reverse @$children) {
                if (ref($_) eq 'FSNode') {
                  $_->paste_on($new)
                } else {
                   warn "new_node: child of $hash->{'#name'} is not a node:\n".
                        Data::Dumper::Dumper([$_]);
                }
             }
          } else {
            warn "new_node: 2nd argument of constructor to $hash->{'#name'} is not an ARRAYref:\n".
            Data::Dumper::Dumper([$children]);
          }
        }
        return $new;
      }
      sub new_struct {
        return Fslib::Struct->new($_[0],1);
      }
      sub new_relation {
        my ($type,$opts)=@_;
	return Fslib::Seq->new([
          Fslib::Seq::Element->new( 
            $type => Fslib::Container->new(undef,$opts)
          )
        ]);
      }
    ;


{
local $SIG{__WARN__} = sub {0};
# PRETEND TO BE IN Parse::RecDescent NAMESPACE
*Parse::RecDescent::Tree_Query::Grammar::AUTOLOAD	= sub
{
	no strict 'refs';
	$AUTOLOAD =~ s/^Parse::RecDescent::Tree_Query::Grammar/Parse::RecDescent/;
	goto &{$AUTOLOAD};
}
}

push @Parse::RecDescent::Tree_Query::Grammar::ISA, 'Parse::RecDescent';
# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::test
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"test"};
	
	Parse::RecDescent::_trace(q{Trying rule: [test]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{test},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{simple_test, or subquery, or ref});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [simple_test]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{test});
		%item = (__RULE__ => q{test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [simple_test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::simple_test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [simple_test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [simple_test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{simple_test}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [simple_test]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [subquery]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{test});
		%item = (__RULE__ => q{test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [subquery]},
				  Parse::RecDescent::_tracefirst($text),
				  q{test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::subquery($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [subquery]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [subquery]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{subquery}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [subquery]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [ref]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{test});
		%item = (__RULE__ => q{test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [ref]},
				  Parse::RecDescent::_tracefirst($text),
				  q{test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::ref($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [ref]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [ref]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{ref}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [ref]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{test},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{test},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{test},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::XMLNAME
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"XMLNAME"};
	
	Parse::RecDescent::_trace(q{Trying rule: [XMLNAME]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{XMLNAME},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/$\{PMLSchema::CDATA::Name\}/o});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/$\{PMLSchema::CDATA::Name\}/o]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{XMLNAME},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{XMLNAME});
		%item = (__RULE__ => q{XMLNAME});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/$\{PMLSchema::CDATA::Name\}/o]}, Parse::RecDescent::_tracefirst($text),
					  q{XMLNAME},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:${PMLSchema::CDATA::Name})//o)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/$\{PMLSchema::CDATA::Name\}/o]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{XMLNAME},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{XMLNAME},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{XMLNAME},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{XMLNAME},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{XMLNAME},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::occurrences
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"occurrences"};
	
	Parse::RecDescent::_trace(q{Trying rule: [occurrences]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{occurrences},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{NUMBER});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [NUMBER 'x' <commit>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{occurrences});
		%item = (__RULE__ => q{occurrences});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{occurrences},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{occurrences},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: ['x']},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'x'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\Ax//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = new_struct({ min=>$item[1], max=>$item[1] }) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [NUMBER 'x' <commit>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [NUMBER /[-+]/ <commit> 'x']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{occurrences});
		%item = (__RULE__ => q{occurrences});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{occurrences},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{occurrences},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/[-+]/]}, Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/[-+]/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:[-+])//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying terminal: ['x']},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'x'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\Ax//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = new_struct({ ($item[2] eq '-' ? 'max' : 'min') =>$item[1] }) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [NUMBER /[-+]/ <commit> 'x']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [NUMBER '..' <commit> NUMBER 'x']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{occurrences});
		%item = (__RULE__ => q{occurrences});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{occurrences},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{occurrences},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: ['..']},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'..'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\.\.//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{occurrences},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{NUMBER})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{occurrences},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: ['x']},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'x'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\Ax//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = new_struct({ min=>$item[1], max=>$item[4] }) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [NUMBER '..' <commit> NUMBER 'x']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error?:...> <reject>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		
		my $_savetext;
		@item = (q{occurrences});
		%item = (__RULE__ => q{occurrences});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error?:...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if ($commit) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{>>Rejecting production<< (found <reject>)},
					 Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		undef $return;
		

		$_tok = undef;
		
		last unless defined $_tok;


		Parse::RecDescent::_trace(q{>>Matched production: [<error?:...> <reject>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{occurrences},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{occurrences},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{occurrences},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{occurrences},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::and_clause
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"and_clause"};
	
	Parse::RecDescent::_trace(q{Trying rule: [and_clause]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{and_clause},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{'('});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['(' <leftop: test /,|and/ test> ')']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{and_clause});
		%item = (__RULE__ => q{and_clause});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['(']},
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\(//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying operator: [<leftop: test /,|and/ test>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{and_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{<leftop: test /,|and/ test>})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{and_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{test})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{and_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{test}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying terminal: [/,|and/]}, Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/,|and/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:,|and)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

			pop @item;
			if (defined $1) {push @item, $item{__DIRECTIVE1__}=$1; $backtrack=1;}
			
		Parse::RecDescent::_trace(q{Trying subrule: [test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{and_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{test})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{and_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{test}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: test /,|and/ test>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{and_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: test /,|and/ test>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{__DIRECTIVE1__}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying terminal: [')']},
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{')'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_node({ '#name' => 'and'}, $item[2]) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: ['(' <leftop: test /,|and/ test> ')']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{and_clause},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{and_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{and_clause},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{and_clause},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::literal
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"literal"};
	
	Parse::RecDescent::_trace(q{Trying rule: [literal]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{literal},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{NUMBER, or STRING});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [NUMBER]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{literal});
		%item = (__RULE__ => q{literal});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{literal},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{literal},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [NUMBER]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [STRING]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{literal});
		%item = (__RULE__ => q{literal});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [STRING]},
				  Parse::RecDescent::_tracefirst($text),
				  q{literal},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::STRING($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [STRING]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{literal},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [STRING]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{STRING}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [STRING]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{literal},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{literal},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{literal},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{literal},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::subquery
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"subquery"};
	
	Parse::RecDescent::_trace(q{Trying rule: [subquery]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{subquery},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{occurrences});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [occurrences RELATION node]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{subquery});
		%item = (__RULE__ => q{subquery});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [occurrences]},
				  Parse::RecDescent::_tracefirst($text),
				  q{subquery},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::occurrences($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [occurrences]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{subquery},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [occurrences]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{occurrences}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying repeated subrule: [RELATION]},
				  Parse::RecDescent::_tracefirst($text),
				  q{subquery},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{RELATION})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::RELATION, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [RELATION]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{subquery},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [RELATION]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{RELATION(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying subrule: [node]},
				  Parse::RecDescent::_tracefirst($text),
				  q{subquery},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{node})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::node($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [node]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{subquery},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [node]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{node}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[3]; 
                $return->{'#name'}='subquery';
                $return->{relation}=$item[2][0];
                $return->{occurrences}=$item[1];
                1;
              };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [occurrences RELATION node]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{subquery},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{subquery},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{subquery},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{subquery},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_parse_query
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"_alternation_1_of_production_1_of_rule_parse_query"};
	
	Parse::RecDescent::_trace(q{Trying rule: [_alternation_1_of_production_1_of_rule_parse_query]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{_alternation_1_of_production_1_of_rule_parse_query},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{';'});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [';']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_parse_query});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_parse_query});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [';']},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\;//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [';']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{_alternation_1_of_production_1_of_rule_parse_query},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{_alternation_1_of_production_1_of_rule_parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{_alternation_1_of_production_1_of_rule_parse_query},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{_alternation_1_of_production_1_of_rule_parse_query},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::expression
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"expression"};
	
	Parse::RecDescent::_trace(q{Trying rule: [expression]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{expression},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{<leftop: term OP term>});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<leftop: term OP term>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{expression});
		%item = (__RULE__ => q{expression});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying operator: [<leftop: term OP term>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [term]},
				  Parse::RecDescent::_tracefirst($text),
				  q{expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{term})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::term($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [term]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [term]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{term}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying subrule: [OP]},
				  Parse::RecDescent::_tracefirst($text),
				  q{expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{OP})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::OP($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [OP]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [OP]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{OP}} = $_tok;
		push @item, $_tok;
		
		}

			$backtrack=1;
			
			
		Parse::RecDescent::_trace(q{Trying subrule: [term]},
				  Parse::RecDescent::_tracefirst($text),
				  q{expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{term})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::term($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [term]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [term]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{term}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: term OP term>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: term OP term>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{__DIRECTIVE1__}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { @{$item[1]}>1 ? ['EXP',@{$item[1]}] : $item[1][0] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [<leftop: term OP term>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{expression},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{expression},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{expression},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::not_clause
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"not_clause"};
	
	Parse::RecDescent::_trace(q{Trying rule: [not_clause]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{not_clause},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{'!'});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['!' test, or or_clause, or and_clause]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{not_clause});
		%item = (__RULE__ => q{not_clause});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['!']},
					  Parse::RecDescent::_tracefirst($text),
					  q{not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\!//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying subrule: [_alternation_1_of_production_1_of_rule_not_clause]},
				  Parse::RecDescent::_tracefirst($text),
				  q{not_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{test, or or_clause, or and_clause})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_not_clause($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [_alternation_1_of_production_1_of_rule_not_clause]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{not_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [_alternation_1_of_production_1_of_rule_not_clause]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{_alternation_1_of_production_1_of_rule_not_clause}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {  $return = $item[2];
                 if ($return->{'#name'} eq 'and') {
                   $return->{'#name'} = 'not';
                 } else {
                   $return = new_node({ '#name' => 'not'}, [$return])
                 }
              };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: ['!' test, or or_clause, or and_clause]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{not_clause},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{not_clause},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{not_clause},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::CMP
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"CMP"};
	
	Parse::RecDescent::_trace(q{Trying rule: [CMP]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{CMP},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/=|~\\*?|[<>]=?|in/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/=|~\\*?|[<>]=?|in/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{CMP},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{CMP});
		%item = (__RULE__ => q{CMP});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/=|~\\*?|[<>]=?|in/]}, Parse::RecDescent::_tracefirst($text),
					  q{CMP},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:=|~\*?|[<>]=?|in)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/=|~\\*?|[<>]=?|in/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{CMP},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{CMP},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{CMP},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{CMP},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{CMP},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_not_clause
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"_alternation_1_of_production_1_of_rule_not_clause"};
	
	Parse::RecDescent::_trace(q{Trying rule: [_alternation_1_of_production_1_of_rule_not_clause]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{_alternation_1_of_production_1_of_rule_not_clause},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{test, or or_clause, or and_clause});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [test]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_not_clause});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_not_clause});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_not_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_not_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{test}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [test]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [or_clause]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_not_clause});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_not_clause});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [or_clause]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_not_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::or_clause($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [or_clause]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_not_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [or_clause]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{or_clause}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [or_clause]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [and_clause]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_not_clause});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_not_clause});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [and_clause]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_not_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::and_clause($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [and_clause]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_not_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [and_clause]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{and_clause}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [and_clause]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{_alternation_1_of_production_1_of_rule_not_clause},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{_alternation_1_of_production_1_of_rule_not_clause},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::parse_test
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"parse_test"};
	
	Parse::RecDescent::_trace(q{Trying rule: [parse_test]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{parse_test},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{test});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [test /\\Z/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_test});
		%item = (__RULE__ => q{parse_test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{test}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/\\Z/]}, Parse::RecDescent::_tracefirst($text),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/\\Z/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:\Z)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [test /\\Z/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_test});
		%item = (__RULE__ => q{parse_test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { report_error($thisparser); };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{parse_test},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{parse_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{parse_test},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{parse_test},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::simple_test
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"simple_test"};
	
	Parse::RecDescent::_trace(q{Trying rule: [simple_test]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{simple_test},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{predicate, or or_clause, or not_clause, or and_clause});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [predicate]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{simple_test});
		%item = (__RULE__ => q{simple_test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [predicate]},
				  Parse::RecDescent::_tracefirst($text),
				  q{simple_test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::predicate($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [predicate]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{simple_test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [predicate]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{predicate}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [predicate]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [or_clause]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{simple_test});
		%item = (__RULE__ => q{simple_test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [or_clause]},
				  Parse::RecDescent::_tracefirst($text),
				  q{simple_test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::or_clause($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [or_clause]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{simple_test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [or_clause]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{or_clause}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [or_clause]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [not_clause]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{simple_test});
		%item = (__RULE__ => q{simple_test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [not_clause]},
				  Parse::RecDescent::_tracefirst($text),
				  q{simple_test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::not_clause($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [not_clause]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{simple_test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [not_clause]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{not_clause}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [not_clause]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [and_clause]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		$text = $_[1];
		my $_savetext;
		@item = (q{simple_test});
		%item = (__RULE__ => q{simple_test});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [and_clause]},
				  Parse::RecDescent::_tracefirst($text),
				  q{simple_test},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::and_clause($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [and_clause]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{simple_test},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [and_clause]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{and_clause}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [and_clause]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{simple_test},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{simple_test},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{simple_test},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{simple_test},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::parse_node
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"parse_node"};
	
	Parse::RecDescent::_trace(q{Trying rule: [parse_node]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{parse_node},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{child, or opt_child});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [child, or opt_child /\\Z/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_node});
		%item = (__RULE__ => q{parse_node});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [_alternation_1_of_production_1_of_rule_parse_node]},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_node},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_parse_node($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [_alternation_1_of_production_1_of_rule_parse_node]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_node},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [_alternation_1_of_production_1_of_rule_parse_node]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{_alternation_1_of_production_1_of_rule_parse_node}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/\\Z/]}, Parse::RecDescent::_tracefirst($text),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/\\Z/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:\Z)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [child, or opt_child /\\Z/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_node});
		%item = (__RULE__ => q{parse_node});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { report_error($thisparser); };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{parse_node},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{parse_node},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{parse_node},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::ref
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"ref"};
	
	Parse::RecDescent::_trace(q{Trying rule: [ref]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{ref},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{RELATION, or EXTRA_RELATION});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [RELATION, or EXTRA_RELATION VARIABLE]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{ref});
		%item = (__RULE__ => q{ref});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying repeated subrule: [RELATION, or EXTRA_RELATION]},
				  Parse::RecDescent::_tracefirst($text),
				  q{ref},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_ref, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [RELATION, or EXTRA_RELATION]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{ref},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [_alternation_1_of_production_1_of_rule_ref]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{_alternation_1_of_production_1_of_rule_ref(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying subrule: [VARIABLE]},
				  Parse::RecDescent::_tracefirst($text),
				  q{ref},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{VARIABLE})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::VARIABLE($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [VARIABLE]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{ref},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [VARIABLE]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{VARIABLE}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = new_node({ '#name' => 'ref', target=>$item[2], relation=>$item[1][0] });
         };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [RELATION, or EXTRA_RELATION VARIABLE]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{ref},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{ref},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{ref},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::opt_child
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"opt_child"};
	
	Parse::RecDescent::_trace(q{Trying rule: [opt_child]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{opt_child},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{'?'});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['?' <commit> RELATION node]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{opt_child});
		%item = (__RULE__ => q{opt_child});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['?']},
					  Parse::RecDescent::_tracefirst($text),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\?//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying repeated subrule: [RELATION]},
				  Parse::RecDescent::_tracefirst($text),
				  q{opt_child},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{RELATION})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::RELATION, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [RELATION]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{opt_child},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [RELATION]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{RELATION(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying subrule: [node]},
				  Parse::RecDescent::_tracefirst($text),
				  q{opt_child},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{node})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::node($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [node]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{opt_child},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [node]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{node}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[4]; $return->{optional}=1; $return->{relation}=$item[3][0]; 1 };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: ['?' <commit> RELATION node]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{opt_child},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{opt_child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{opt_child},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{opt_child},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::EXTRA_RELATION
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"EXTRA_RELATION"};
	
	Parse::RecDescent::_trace(q{Trying rule: [EXTRA_RELATION]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{EXTRA_RELATION},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/depth-first-precedes|depth-first-follows|order-precedes|order-follows/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/depth-first-precedes|depth-first-follows|order-precedes|order-follows/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{EXTRA_RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{EXTRA_RELATION});
		%item = (__RULE__ => q{EXTRA_RELATION});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/depth-first-precedes|depth-first-follows|order-precedes|order-follows/]}, Parse::RecDescent::_tracefirst($text),
					  q{EXTRA_RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:depth-first-precedes|depth-first-follows|order-precedes|order-follows)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{EXTRA_RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_relation($item[1]) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [/depth-first-precedes|depth-first-follows|order-precedes|order-follows/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{EXTRA_RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{EXTRA_RELATION},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{EXTRA_RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{EXTRA_RELATION},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{EXTRA_RELATION},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::flat_expression
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"flat_expression"};
	
	Parse::RecDescent::_trace(q{Trying rule: [flat_expression]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{flat_expression},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	my  ($start,$t);


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<rulevar: ($start,$t)>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{flat_expression});
		%item = (__RULE__ => q{flat_expression});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{>>Rejecting production<< (found <rulevar: ($start,$t)>)},
					 Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		undef $return;
		

		$_tok = undef;
		
		last unless defined $_tok;


		Parse::RecDescent::_trace(q{>>Matched production: [<rulevar: ($start,$t)>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<leftop: term OP term>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{flat_expression});
		%item = (__RULE__ => q{flat_expression});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { ($start,$t)=($thisoffset,$text) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		

		Parse::RecDescent::_trace(q{Trying operator: [<leftop: term OP term>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{flat_expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{<leftop: term OP term>})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [term]},
				  Parse::RecDescent::_tracefirst($text),
				  q{flat_expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{term})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::term($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [term]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{flat_expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [term]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{term}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying subrule: [OP]},
				  Parse::RecDescent::_tracefirst($text),
				  q{flat_expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{OP})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::OP($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [OP]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{flat_expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [OP]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{OP}} = $_tok;
		push @item, $_tok;
		
		}

			$backtrack=1;
			
			
		Parse::RecDescent::_trace(q{Trying subrule: [term]},
				  Parse::RecDescent::_tracefirst($text),
				  q{flat_expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{term})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::term($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [term]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{flat_expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [term]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{term}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: term OP term>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{flat_expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: term OP term>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{__DIRECTIVE1__}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=substr($t,0,$thisoffset-$start); $return=~s/^\s*//; 1 };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [<leftop: term OP term>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{flat_expression},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{flat_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{flat_expression},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{flat_expression},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_ref
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"_alternation_1_of_production_1_of_rule_ref"};
	
	Parse::RecDescent::_trace(q{Trying rule: [_alternation_1_of_production_1_of_rule_ref]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{_alternation_1_of_production_1_of_rule_ref},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{RELATION, or EXTRA_RELATION});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [RELATION]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_ref});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_ref});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [RELATION]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_ref},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::RELATION($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [RELATION]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_ref},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [RELATION]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{RELATION}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [RELATION]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [EXTRA_RELATION]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_ref});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_ref});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [EXTRA_RELATION]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_ref},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::EXTRA_RELATION($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [EXTRA_RELATION]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_ref},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [EXTRA_RELATION]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{EXTRA_RELATION}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [EXTRA_RELATION]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{_alternation_1_of_production_1_of_rule_ref},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{_alternation_1_of_production_1_of_rule_ref},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::var_def
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"var_def"};
	
	Parse::RecDescent::_trace(q{Trying rule: [var_def]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{var_def},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{VARIABLE});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [VARIABLE ':=' <commit> '[']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{var_def});
		%item = (__RULE__ => q{var_def});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [VARIABLE]},
				  Parse::RecDescent::_tracefirst($text),
				  q{var_def},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::VARIABLE($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [VARIABLE]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{var_def},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [VARIABLE]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{VARIABLE}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [':=']},
					  Parse::RecDescent::_tracefirst($text),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{':='})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\:\=//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying terminal: ['[']},
					  Parse::RecDescent::_tracefirst($text),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'['})->at($text);
		$_savetext = $text;

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\[//)
		{
			$text = $_savetext;
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		$text = $_savetext;

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [VARIABLE ':=' <commit> '[']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{var_def},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{var_def},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{var_def},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{var_def},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::OP
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"OP"};
	
	Parse::RecDescent::_trace(q{Trying rule: [OP]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{OP},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/[-+*~]|div|mod/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/[-+*~]|div|mod/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{OP},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{OP});
		%item = (__RULE__ => q{OP});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/[-+*~]|div|mod/]}, Parse::RecDescent::_tracefirst($text),
					  q{OP},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:[-+*~]|div|mod)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/[-+*~]|div|mod/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{OP},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{OP},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{OP},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{OP},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{OP},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_parse_node
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"_alternation_1_of_production_1_of_rule_parse_node"};
	
	Parse::RecDescent::_trace(q{Trying rule: [_alternation_1_of_production_1_of_rule_parse_node]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{_alternation_1_of_production_1_of_rule_parse_node},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{child, or opt_child});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [child]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_parse_node});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_parse_node});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [child]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_parse_node},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::child($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [child]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_parse_node},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [child]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{child}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [child]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [opt_child]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_parse_node});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_parse_node});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [opt_child]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_parse_node},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::opt_child($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [opt_child]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_parse_node},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [opt_child]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{opt_child}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [opt_child]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{_alternation_1_of_production_1_of_rule_parse_node},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{_alternation_1_of_production_1_of_rule_parse_node},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::arguments
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"arguments"};
	
	Parse::RecDescent::_trace(q{Trying rule: [arguments]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{arguments},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{<leftop: argument ',' argument>});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<leftop: argument ',' argument>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{arguments});
		%item = (__RULE__ => q{arguments});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying operator: [<leftop: argument ',' argument>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{arguments},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [argument]},
				  Parse::RecDescent::_tracefirst($text),
				  q{arguments},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{argument})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::argument($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [argument]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{arguments},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [argument]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{argument}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying terminal: [',']},
					  Parse::RecDescent::_tracefirst($text),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{','})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\,//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

			pop @item;
			
			
		Parse::RecDescent::_trace(q{Trying subrule: [argument]},
				  Parse::RecDescent::_tracefirst($text),
				  q{arguments},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{argument})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::argument($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [argument]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{arguments},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [argument]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{argument}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: argument ',' argument>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{arguments},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: argument ',' argument>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{__DIRECTIVE1__}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [<leftop: argument ',' argument>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{arguments},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{arguments},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{arguments},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{arguments},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::type
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"type"};
	
	Parse::RecDescent::_trace(q{Trying rule: [type]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{type},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{XMLNAME});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [XMLNAME /\\$|\\[/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [XMLNAME]},
				  Parse::RecDescent::_tracefirst($text),
				  q{type},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::XMLNAME($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [XMLNAME]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{type},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [XMLNAME]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{XMLNAME}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/\\$|\\[/]}, Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/\\$|\\[/})->at($text);
		$_savetext = $text;

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:\$|\[)//)
		{
			$text = $_savetext;
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		$text = $_savetext;

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [XMLNAME /\\$|\\[/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{type},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{type},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{type},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::conditions
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"conditions"};
	
	Parse::RecDescent::_trace(q{Trying rule: [conditions]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{conditions},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{condition});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [condition /,?\\s*]/ <commit>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{conditions});
		%item = (__RULE__ => q{conditions});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [condition]},
				  Parse::RecDescent::_tracefirst($text),
				  q{conditions},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::condition($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [condition]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{conditions},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [condition]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{condition}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/,?\\s*]/]}, Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/,?\\s*]/})->at($text);
		$_savetext = $text;

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:,?\s*])//)
		{
			$text = $_savetext;
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		$text = $_savetext;

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = [$item[1]] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [condition /,?\\s*]/ <commit>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [condition /and|,/ <commit> conditions]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{conditions});
		%item = (__RULE__ => q{conditions});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [condition]},
				  Parse::RecDescent::_tracefirst($text),
				  q{conditions},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::condition($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [condition]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{conditions},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [condition]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{condition}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/and|,/]}, Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/and|,/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:and|,)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [conditions]},
				  Parse::RecDescent::_tracefirst($text),
				  q{conditions},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{conditions})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::conditions($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [conditions]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{conditions},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [conditions]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{conditions}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = [$item[1],@{$item[4]}] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [condition /and|,/ <commit> conditions]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		
		my $_savetext;
		@item = (q{conditions});
		%item = (__RULE__ => q{conditions});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{conditions},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{conditions},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{conditions},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{conditions},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_simple_attribute
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"_alternation_1_of_production_1_of_rule_simple_attribute"};
	
	Parse::RecDescent::_trace(q{Trying rule: [_alternation_1_of_production_1_of_rule_simple_attribute]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{_alternation_1_of_production_1_of_rule_simple_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{'/'});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['/' XMLNAME]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{_alternation_1_of_production_1_of_rule_simple_attribute});
		%item = (__RULE__ => q{_alternation_1_of_production_1_of_rule_simple_attribute});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['/']},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\///)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying subrule: [XMLNAME]},
				  Parse::RecDescent::_tracefirst($text),
				  q{_alternation_1_of_production_1_of_rule_simple_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{XMLNAME})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::XMLNAME($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [XMLNAME]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{_alternation_1_of_production_1_of_rule_simple_attribute},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [XMLNAME]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{XMLNAME}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: ['/' XMLNAME]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{_alternation_1_of_production_1_of_rule_simple_attribute},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{_alternation_1_of_production_1_of_rule_simple_attribute},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::ref_attribute
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"ref_attribute"};
	
	Parse::RecDescent::_trace(q{Trying rule: [ref_attribute]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{ref_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{VARIABLE});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		local $skip = defined($skip) ? $skip : $Parse::RecDescent::skip;
		Parse::RecDescent::_trace(q{Trying production: [VARIABLE <skip: ''> '.' simple_attribute]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{ref_attribute});
		%item = (__RULE__ => q{ref_attribute});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [VARIABLE]},
				  Parse::RecDescent::_tracefirst($text),
				  q{ref_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::VARIABLE($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [VARIABLE]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{ref_attribute},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [VARIABLE]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{VARIABLE}} = $_tok;
		push @item, $_tok;
		
		}

		

		Parse::RecDescent::_trace(q{Trying directive: [<skip: ''>]},
					Parse::RecDescent::_tracefirst($text),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { my $oldskip = $skip; $skip= ''; $oldskip };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying terminal: ['.']},
					  Parse::RecDescent::_tracefirst($text),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'.'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\.//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying subrule: [simple_attribute]},
				  Parse::RecDescent::_tracefirst($text),
				  q{ref_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{simple_attribute})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::simple_attribute($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [simple_attribute]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{ref_attribute},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [simple_attribute]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{simple_attribute}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { ['REF_ATTR',$item[1],$item[4]] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [VARIABLE <skip: ''> '.' simple_attribute]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{ref_attribute},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{ref_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{ref_attribute},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{ref_attribute},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::parse_expression
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"parse_expression"};
	
	Parse::RecDescent::_trace(q{Trying rule: [parse_expression]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{parse_expression},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{expression});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [expression /\\Z/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_expression});
		%item = (__RULE__ => q{parse_expression});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [expression]},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_expression},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::expression($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [expression]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_expression},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [expression]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{expression}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [/\\Z/]}, Parse::RecDescent::_tracefirst($text),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/\\Z/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:\Z)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [expression /\\Z/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_expression});
		%item = (__RULE__ => q{parse_expression});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { report_error($thisparser); };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{parse_expression},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{parse_expression},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{parse_expression},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{parse_expression},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::function
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"function"};
	
	Parse::RecDescent::_trace(q{Trying rule: [function]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{function},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{FUNC});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		local $skip = defined($skip) ? $skip : $Parse::RecDescent::skip;
		Parse::RecDescent::_trace(q{Trying production: [FUNC <skip: ''> '(' <skip: '\s*(?:[#][^\n]*\s*)?'> arguments ')']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{function});
		%item = (__RULE__ => q{function});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [FUNC]},
				  Parse::RecDescent::_tracefirst($text),
				  q{function},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::FUNC($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [FUNC]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{function},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [FUNC]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{FUNC}} = $_tok;
		push @item, $_tok;
		
		}

		

		Parse::RecDescent::_trace(q{Trying directive: [<skip: ''>]},
					Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { my $oldskip = $skip; $skip= ''; $oldskip };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying terminal: ['(']},
					  Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'('})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\(//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<skip: '\s*(?:[#][^\n]*\s*)?'>]},
					Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { my $oldskip = $skip; $skip= '\s*(?:[#][^\n]*\s*)?'; $oldskip };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE2__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying repeated subrule: [arguments]},
				  Parse::RecDescent::_tracefirst($text),
				  q{function},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{arguments})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::arguments, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [arguments]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{function},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [arguments]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{arguments(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying terminal: [')']},
					  Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{')'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { ['FUNC', $item[1],$item[5][0] ] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [FUNC <skip: ''> '(' <skip: '\s*(?:[#][^\n]*\s*)?'> arguments ')']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{function},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{function},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{function},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{function},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::VARIABLE
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"VARIABLE"};
	
	Parse::RecDescent::_trace(q{Trying rule: [VARIABLE]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{VARIABLE},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/\\$[[:alpha:]_][[:alnum:]_]*/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/\\$[[:alpha:]_][[:alnum:]_]*/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{VARIABLE},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{VARIABLE});
		%item = (__RULE__ => q{VARIABLE});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/\\$[[:alpha:]_][[:alnum:]_]*/]}, Parse::RecDescent::_tracefirst($text),
					  q{VARIABLE},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:\$[[:alpha:]_][[:alnum:]_]*)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{VARIABLE},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[1]; $return=~s/^\$//; 1 };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [/\\$[[:alpha:]_][[:alnum:]_]*/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{VARIABLE},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{VARIABLE},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{VARIABLE},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{VARIABLE},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{VARIABLE},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::simple_attribute
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"simple_attribute"};
	
	Parse::RecDescent::_trace(q{Trying rule: [simple_attribute]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{simple_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{XMLNAME});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [XMLNAME '/']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{simple_attribute});
		%item = (__RULE__ => q{simple_attribute});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [XMLNAME]},
				  Parse::RecDescent::_tracefirst($text),
				  q{simple_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::XMLNAME($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [XMLNAME]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{simple_attribute},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [XMLNAME]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{XMLNAME}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying repeated subrule: ['/']},
				  Parse::RecDescent::_tracefirst($text),
				  q{simple_attribute},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{'/'})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_simple_attribute, 0, 100000000, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: ['/']>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{simple_attribute},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [_alternation_1_of_production_1_of_rule_simple_attribute]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{_alternation_1_of_production_1_of_rule_simple_attribute(s?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { ['ATTR',$item[1],@{$item[2]}] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [XMLNAME '/']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{simple_attribute},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{simple_attribute},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{simple_attribute},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{simple_attribute},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::node
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"node"};
	
	Parse::RecDescent::_trace(q{Trying rule: [node]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{node},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{type});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [type var_def '[' <commit> conditions /,?\\s*]/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{node});
		%item = (__RULE__ => q{node});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying repeated subrule: [type]},
				  Parse::RecDescent::_tracefirst($text),
				  q{node},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::type, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [type]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{node},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [type]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{type(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying repeated subrule: [var_def]},
				  Parse::RecDescent::_tracefirst($text),
				  q{node},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{var_def})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::var_def, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [var_def]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{node},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [var_def]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{var_def(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying terminal: ['[']},
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'['})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\[//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying repeated subrule: [conditions]},
				  Parse::RecDescent::_tracefirst($text),
				  q{node},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{conditions})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::conditions, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [conditions]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{node},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [conditions]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{conditions(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying terminal: [/,?\\s*]/]}, Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/,?\\s*]/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:,?\s*])//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_node({ '#name' => 'node', 'node-type' => $item[1][0], name => $item[2][0]}, $item[5][0]) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [type var_def '[' <commit> conditions /,?\\s*]/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		
		my $_savetext;
		@item = (q{node});
		%item = (__RULE__ => q{node});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{node},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{node},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{node},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{node},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::STRING
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"STRING"};
	
	Parse::RecDescent::_trace(q{Trying rule: [STRING]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{STRING},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/'([^'\\\\]+|\\\\.)*'/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/'([^'\\\\]+|\\\\.)*'/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{STRING},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{STRING});
		%item = (__RULE__ => q{STRING});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/'([^'\\\\]+|\\\\.)*'/]}, Parse::RecDescent::_tracefirst($text),
					  q{STRING},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:'([^'\\]+|\\.)*')//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/'([^'\\\\]+|\\\\.)*'/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{STRING},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{STRING},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{STRING},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{STRING},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{STRING},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::FUNC
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"FUNC"};
	
	Parse::RecDescent::_trace(q{Trying rule: [FUNC]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{FUNC},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{FUNC},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{FUNC});
		%item = (__RULE__ => q{FUNC});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr/]}, Parse::RecDescent::_tracefirst($text),
					  q{FUNC},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{FUNC},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{FUNC},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{FUNC},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{FUNC},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{FUNC},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::term
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"term"};
	
	Parse::RecDescent::_trace(q{Trying rule: [term]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{term},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{'(', or function, or simple_attribute, or ref_attribute, or literal});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['(' <commit> expression ')']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{term});
		%item = (__RULE__ => q{term});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['(']},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\(//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [expression]},
				  Parse::RecDescent::_tracefirst($text),
				  q{term},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{expression})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::expression($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [expression]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{term},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [expression]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{expression}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [')']},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{')'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[3] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: ['(' <commit> expression ')']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [function]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{term});
		%item = (__RULE__ => q{term});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [function]},
				  Parse::RecDescent::_tracefirst($text),
				  q{term},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::function($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [function]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{term},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [function]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{function}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [function]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [simple_attribute]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{term});
		%item = (__RULE__ => q{term});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [simple_attribute]},
				  Parse::RecDescent::_tracefirst($text),
				  q{term},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::simple_attribute($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [simple_attribute]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{term},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [simple_attribute]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{simple_attribute}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [simple_attribute]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [ref_attribute]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		$text = $_[1];
		my $_savetext;
		@item = (q{term});
		%item = (__RULE__ => q{term});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [ref_attribute]},
				  Parse::RecDescent::_tracefirst($text),
				  q{term},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::ref_attribute($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [ref_attribute]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{term},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [ref_attribute]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{ref_attribute}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [ref_attribute]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [literal]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[4];
		$text = $_[1];
		my $_savetext;
		@item = (q{term});
		%item = (__RULE__ => q{term});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [literal]},
				  Parse::RecDescent::_tracefirst($text),
				  q{term},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::literal($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [literal]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{term},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [literal]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{literal}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=$item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [literal]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[5];
		
		my $_savetext;
		@item = (q{term});
		%item = (__RULE__ => q{term});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{term},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{term},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{term},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{term},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::argument
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"argument"};
	
	Parse::RecDescent::_trace(q{Trying rule: [argument]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{argument},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{expression, or VARIABLE});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [expression]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [expression]},
				  Parse::RecDescent::_tracefirst($text),
				  q{argument},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::expression($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [expression]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{argument},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [expression]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{expression}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [expression]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [VARIABLE]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [VARIABLE]},
				  Parse::RecDescent::_tracefirst($text),
				  q{argument},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::VARIABLE($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [VARIABLE]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{argument},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [VARIABLE]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{VARIABLE}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { '$'.$item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [VARIABLE]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{argument},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{argument},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{argument},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::predicate
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"predicate"};
	
	Parse::RecDescent::_trace(q{Trying rule: [predicate]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{predicate},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{flat_expression});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [flat_expression CMP <commit> flat_expression]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{predicate});
		%item = (__RULE__ => q{predicate});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [flat_expression]},
				  Parse::RecDescent::_tracefirst($text),
				  q{predicate},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::flat_expression($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [flat_expression]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{predicate},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [flat_expression]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{flat_expression}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying subrule: [CMP]},
				  Parse::RecDescent::_tracefirst($text),
				  q{predicate},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{CMP})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::CMP($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [CMP]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{predicate},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [CMP]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{CMP}} = $_tok;
		push @item, $_tok;
		
		}

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [flat_expression]},
				  Parse::RecDescent::_tracefirst($text),
				  q{predicate},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{flat_expression})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::flat_expression($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [flat_expression]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{predicate},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [flat_expression]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{flat_expression}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_node({ '#name' => 'test', a=>$item[1], operator=>$item[2], b=>$item[4] }) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [flat_expression CMP <commit> flat_expression]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{predicate},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{predicate},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{predicate},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{predicate},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::RELATION
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"RELATION"};
	
	Parse::RecDescent::_trace(q{Trying rule: [RELATION]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{RELATION},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/descendant|ancestor/, or /child|parent|descendant|ancestor/, or /$\{Tree_Query::user_defined\}/o});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		local $skip = defined($skip) ? $skip : $Parse::RecDescent::skip;
		Parse::RecDescent::_trace(q{Trying production: [/descendant|ancestor/ <skip:''> '\{' <commit> <skip:'\s*(?:[#][^\n]*\s*)?'> NUMBER ',' NUMBER '\}']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{RELATION});
		%item = (__RULE__ => q{RELATION});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/descendant|ancestor/]}, Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:descendant|ancestor)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<skip:''>]},
					Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { my $oldskip = $skip; $skip=''; $oldskip };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying terminal: ['\{']},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'\{'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\{//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE2__}=$_tok;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<skip:'\s*(?:[#][^\n]*\s*)?'>]},
					Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { my $oldskip = $skip; $skip='\s*(?:[#][^\n]*\s*)?'; $oldskip };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE3__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{RELATION},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{NUMBER})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{RELATION},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [',']},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{','})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\,//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying subrule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($text),
				  q{RELATION},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{NUMBER})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::NUMBER($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [NUMBER]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{RELATION},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [NUMBER]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{NUMBER}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: ['\}']},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'\}'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\}//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING3__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_relation($item[1],{min_length=>$item[6],max_length=>$item[8]}) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [/descendant|ancestor/ <skip:''> '\{' <commit> <skip:'\s*(?:[#][^\n]*\s*)?'> NUMBER ',' NUMBER '\}']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/child|parent|descendant|ancestor/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{RELATION});
		%item = (__RULE__ => q{RELATION});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/child|parent|descendant|ancestor/]}, Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:child|parent|descendant|ancestor)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_relation($item[1]) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [/child|parent|descendant|ancestor/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/$\{Tree_Query::user_defined\}/o]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{RELATION});
		%item = (__RULE__ => q{RELATION});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/$\{Tree_Query::user_defined\}/o]}, Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:${Tree_Query::user_defined})//o)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_relation('user-defined',{label => $item[1]}) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [/$\{Tree_Query::user_defined\}/o]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{RELATION},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{RELATION},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{RELATION},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{RELATION},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::NUMBER
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"NUMBER"};
	
	Parse::RecDescent::_trace(q{Trying rule: [NUMBER]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{NUMBER},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{/-?[0-9]+(\\.[0-9]+)?/});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/-?[0-9]+(\\.[0-9]+)?/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{NUMBER},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{NUMBER});
		%item = (__RULE__ => q{NUMBER});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/-?[0-9]+(\\.[0-9]+)?/]}, Parse::RecDescent::_tracefirst($text),
					  q{NUMBER},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:-?[0-9]+(\.[0-9]+)?)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/-?[0-9]+(\\.[0-9]+)?/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{NUMBER},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{NUMBER},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{NUMBER},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{NUMBER},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{NUMBER},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::parse_query
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"parse_query"};
	
	Parse::RecDescent::_trace(q{Trying rule: [parse_query]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{parse_query},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{<leftop: node ';' node>});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<leftop: node ';' node> ';' /\\Z/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_query});
		%item = (__RULE__ => q{parse_query});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying operator: [<leftop: node ';' node>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_query},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [node]},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_query},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{node})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::node($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [node]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_query},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [node]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{node}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying terminal: [';']},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{';'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\;//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

			pop @item;
			
			
		Parse::RecDescent::_trace(q{Trying subrule: [node]},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_query},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{node})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::node($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [node]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_query},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [node]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{node}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: node ';' node>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_query},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: node ';' node>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{__DIRECTIVE1__}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying repeated subrule: [';']},
				  Parse::RecDescent::_tracefirst($text),
				  q{parse_query},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{';'})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::_alternation_1_of_production_1_of_rule_parse_query, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [';']>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{parse_query},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [_alternation_1_of_production_1_of_rule_parse_query]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{_alternation_1_of_production_1_of_rule_parse_query(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying terminal: [/\\Z/]}, Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/\\Z/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:\Z)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return=new_node({},$item[1]); 1 };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [<leftop: node ';' node> ';' /\\Z/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{parse_query});
		%item = (__RULE__ => q{parse_query});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { report_error($thisparser); };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{parse_query},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{parse_query},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{parse_query},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{parse_query},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::or_clause
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"or_clause"};
	
	Parse::RecDescent::_trace(q{Trying rule: [or_clause]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{or_clause},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{'('});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['(' <leftop: test 'or' test> ')']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{or_clause});
		%item = (__RULE__ => q{or_clause});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['(']},
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\(//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying operator: [<leftop: test 'or' test>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{or_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{<leftop: test 'or' test>})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{or_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{test})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{or_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{test}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying terminal: ['or']},
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'or'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\Aor//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

			pop @item;
			
			
		Parse::RecDescent::_trace(q{Trying subrule: [test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{or_clause},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{test})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{or_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{test}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: test 'or' test>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{or_clause},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: test 'or' test>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{__DIRECTIVE1__}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying terminal: [')']},
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{')'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING3__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { new_node({ '#name' => 'or' }, $item[2]) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: ['(' <leftop: test 'or' test> ')']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{or_clause},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{or_clause},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{or_clause},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{or_clause},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::child
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"child"};
	
	Parse::RecDescent::_trace(q{Trying rule: [child]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{child},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{RELATION});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [RELATION node]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{child},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{child});
		%item = (__RULE__ => q{child});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying repeated subrule: [RELATION]},
				  Parse::RecDescent::_tracefirst($text),
				  q{child},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::Tree_Query::Grammar::RELATION, 0, 1, $_noactions,$expectation,sub { \@arg }))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [RELATION]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{child},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [RELATION]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{RELATION(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying subrule: [node]},
				  Parse::RecDescent::_tracefirst($text),
				  q{child},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{node})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::node($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [node]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{child},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [node]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{node}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{child},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[2]; $return->{relation}=$item[1][0]; 1 };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [RELATION node]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{child},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{child},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{child},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{child},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::Tree_Query::Grammar::condition
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"condition"};
	
	Parse::RecDescent::_trace(q{Trying rule: [condition]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{condition},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
    my $expectation = new Parse::RecDescent::Expectation(q{simple_test, or opt_child, or subquery, or child, or ref});
	$expectation->at($_[1]);
	
	my $thisoffset;
	tie $thisoffset, q{Parse::RecDescent::OffsetCounter}, \$text, $thisparser;
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [simple_test]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{condition});
		%item = (__RULE__ => q{condition});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [simple_test]},
				  Parse::RecDescent::_tracefirst($text),
				  q{condition},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::simple_test($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [simple_test]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{condition},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [simple_test]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{simple_test}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [simple_test]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [opt_child]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{condition});
		%item = (__RULE__ => q{condition});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [opt_child]},
				  Parse::RecDescent::_tracefirst($text),
				  q{condition},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::opt_child($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [opt_child]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{condition},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [opt_child]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{opt_child}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [opt_child]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [subquery]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{condition});
		%item = (__RULE__ => q{condition});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [subquery]},
				  Parse::RecDescent::_tracefirst($text),
				  q{condition},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::subquery($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [subquery]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{condition},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [subquery]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{subquery}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [subquery]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [child]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		$text = $_[1];
		my $_savetext;
		@item = (q{condition});
		%item = (__RULE__ => q{condition});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [child]},
				  Parse::RecDescent::_tracefirst($text),
				  q{condition},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::child($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [child]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{condition},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [child]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{child}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $return = $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		
		


		Parse::RecDescent::_trace(q{>>Matched production: [child]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [ref]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[4];
		$text = $_[1];
		my $_savetext;
		@item = (q{condition});
		%item = (__RULE__ => q{condition});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [ref]},
				  Parse::RecDescent::_tracefirst($text),
				  q{condition},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::Tree_Query::Grammar::ref($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [ref]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{condition},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [ref]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{ref}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [ref]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{condition},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{condition},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{condition},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{condition},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}
}
package Tree_Query::Grammar; sub new { my $self = bless( {
                 '_AUTOTREE' => undef,
                 'localvars' => '',
                 'startcode' => '',
                 '_check' => {
                               'thisoffset' => 1,
                               'itempos' => '',
                               'prevoffset' => '',
                               'prevline' => '',
                               'prevcolumn' => '',
                               'thiscolumn' => ''
                             },
                 'namespace' => 'Parse::RecDescent::Tree_Query::Grammar',
                 '_AUTOACTION' => undef,
                 'rules' => {
                              'test' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'simple_test',
                                                              'subquery',
                                                              'ref'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'simple_test',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -93
                                                                                           }, 'Parse::RecDescent::Subrule' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '1',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'subquery',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -92
                                                                                           }, 'Parse::RecDescent::Subrule' )
                                                                                  ],
                                                                       'line' => -92
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '2',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'ref',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -91
                                                                                           }, 'Parse::RecDescent::Subrule' )
                                                                                  ],
                                                                       'line' => -91
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'test',
                                                 'vars' => '',
                                                 'line' => -93
                                               }, 'Parse::RecDescent::Rule' ),
                              'XMLNAME' => bless( {
                                                    'impcount' => 0,
                                                    'calls' => [],
                                                    'changed' => 0,
                                                    'opcount' => 0,
                                                    'prods' => [
                                                                 bless( {
                                                                          'number' => '0',
                                                                          'strcount' => 0,
                                                                          'dircount' => 0,
                                                                          'uncommit' => undef,
                                                                          'error' => undef,
                                                                          'patcount' => 1,
                                                                          'actcount' => 0,
                                                                          'items' => [
                                                                                       bless( {
                                                                                                'pattern' => '${PMLSchema::CDATA::Name}',
                                                                                                'hashname' => '__PATTERN1__',
                                                                                                'description' => '/$\\{PMLSchema::CDATA::Name\\}/o',
                                                                                                'lookahead' => 0,
                                                                                                'rdelim' => '/',
                                                                                                'line' => 0,
                                                                                                'mod' => 'o',
                                                                                                'ldelim' => '/'
                                                                                              }, 'Parse::RecDescent::Token' )
                                                                                     ],
                                                                          'line' => undef
                                                                        }, 'Parse::RecDescent::Production' )
                                                               ],
                                                    'name' => 'XMLNAME',
                                                    'vars' => '',
                                                    'line' => 0
                                                  }, 'Parse::RecDescent::Rule' ),
                              'occurrences' => bless( {
                                                        'impcount' => 0,
                                                        'calls' => [
                                                                     'NUMBER'
                                                                   ],
                                                        'changed' => 0,
                                                        'opcount' => 0,
                                                        'prods' => [
                                                                     bless( {
                                                                              'number' => '0',
                                                                              'strcount' => 1,
                                                                              'dircount' => 1,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 1,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'NUMBER',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -34
                                                                                                  }, 'Parse::RecDescent::Subrule' ),
                                                                                           bless( {
                                                                                                    'pattern' => 'x',
                                                                                                    'hashname' => '__STRING1__',
                                                                                                    'description' => '\'x\'',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -34
                                                                                                  }, 'Parse::RecDescent::Literal' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__DIRECTIVE1__',
                                                                                                    'name' => '<commit>',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -34,
                                                                                                    'code' => '$commit = 1'
                                                                                                  }, 'Parse::RecDescent::Directive' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__ACTION1__',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -33,
                                                                                                    'code' => '{ $return = new_struct({ min=>$item[1], max=>$item[1] }) }'
                                                                                                  }, 'Parse::RecDescent::Action' )
                                                                                         ],
                                                                              'line' => undef
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '1',
                                                                              'strcount' => 1,
                                                                              'dircount' => 1,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 1,
                                                                              'actcount' => 1,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'NUMBER',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -32
                                                                                                  }, 'Parse::RecDescent::Subrule' ),
                                                                                           bless( {
                                                                                                    'pattern' => '[-+]',
                                                                                                    'hashname' => '__PATTERN1__',
                                                                                                    'description' => '/[-+]/',
                                                                                                    'lookahead' => 0,
                                                                                                    'rdelim' => '/',
                                                                                                    'line' => -32,
                                                                                                    'mod' => '',
                                                                                                    'ldelim' => '/'
                                                                                                  }, 'Parse::RecDescent::Token' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__DIRECTIVE1__',
                                                                                                    'name' => '<commit>',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -32,
                                                                                                    'code' => '$commit = 1'
                                                                                                  }, 'Parse::RecDescent::Directive' ),
                                                                                           bless( {
                                                                                                    'pattern' => 'x',
                                                                                                    'hashname' => '__STRING1__',
                                                                                                    'description' => '\'x\'',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -32
                                                                                                  }, 'Parse::RecDescent::Literal' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__ACTION1__',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -31,
                                                                                                    'code' => '{ $return = new_struct({ ($item[2] eq \'-\' ? \'max\' : \'min\') =>$item[1] }) }'
                                                                                                  }, 'Parse::RecDescent::Action' )
                                                                                         ],
                                                                              'line' => -32
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '2',
                                                                              'strcount' => 2,
                                                                              'dircount' => 1,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 1,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'NUMBER',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -30
                                                                                                  }, 'Parse::RecDescent::Subrule' ),
                                                                                           bless( {
                                                                                                    'pattern' => '..',
                                                                                                    'hashname' => '__STRING1__',
                                                                                                    'description' => '\'..\'',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -30
                                                                                                  }, 'Parse::RecDescent::Literal' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__DIRECTIVE1__',
                                                                                                    'name' => '<commit>',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -30,
                                                                                                    'code' => '$commit = 1'
                                                                                                  }, 'Parse::RecDescent::Directive' ),
                                                                                           bless( {
                                                                                                    'subrule' => 'NUMBER',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -30
                                                                                                  }, 'Parse::RecDescent::Subrule' ),
                                                                                           bless( {
                                                                                                    'pattern' => 'x',
                                                                                                    'hashname' => '__STRING2__',
                                                                                                    'description' => '\'x\'',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -30
                                                                                                  }, 'Parse::RecDescent::Literal' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__ACTION1__',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -29,
                                                                                                    'code' => '{ $return = new_struct({ min=>$item[1], max=>$item[4] }) }'
                                                                                                  }, 'Parse::RecDescent::Action' )
                                                                                         ],
                                                                              'line' => -30
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '3',
                                                                              'strcount' => 0,
                                                                              'dircount' => 2,
                                                                              'uncommit' => 0,
                                                                              'error' => 1,
                                                                              'patcount' => 0,
                                                                              'actcount' => 0,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'msg' => '',
                                                                                                    'hashname' => '__DIRECTIVE1__',
                                                                                                    'commitonly' => '?',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -28
                                                                                                  }, 'Parse::RecDescent::Error' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__DIRECTIVE2__',
                                                                                                    'name' => '<reject>',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -28
                                                                                                  }, 'Parse::RecDescent::UncondReject' )
                                                                                         ],
                                                                              'line' => -28
                                                                            }, 'Parse::RecDescent::Production' )
                                                                   ],
                                                        'name' => 'occurrences',
                                                        'vars' => '',
                                                        'line' => -34
                                                      }, 'Parse::RecDescent::Rule' ),
                              'and_clause' => bless( {
                                                       'impcount' => 0,
                                                       'calls' => [
                                                                    'test'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 2,
                                                                             'dircount' => 1,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 1,
                                                                             'actcount' => 1,
                                                                             'op' => [],
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'pattern' => '(',
                                                                                                   'hashname' => '__STRING1__',
                                                                                                   'description' => '\'(\'',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -86
                                                                                                 }, 'Parse::RecDescent::Literal' ),
                                                                                          bless( {
                                                                                                   'expected' => '<leftop: test /,|and/ test>',
                                                                                                   'min' => 1,
                                                                                                   'name' => '',
                                                                                                   'max' => 100000000,
                                                                                                   'leftarg' => bless( {
                                                                                                                         'subrule' => 'test',
                                                                                                                         'matchrule' => 0,
                                                                                                                         'implicit' => undef,
                                                                                                                         'argcode' => undef,
                                                                                                                         'lookahead' => 0,
                                                                                                                         'line' => -86
                                                                                                                       }, 'Parse::RecDescent::Subrule' ),
                                                                                                   'rightarg' => bless( {
                                                                                                                          'subrule' => 'test',
                                                                                                                          'matchrule' => 0,
                                                                                                                          'implicit' => undef,
                                                                                                                          'argcode' => undef,
                                                                                                                          'lookahead' => 0,
                                                                                                                          'line' => -86
                                                                                                                        }, 'Parse::RecDescent::Subrule' ),
                                                                                                   'hashname' => '__DIRECTIVE1__',
                                                                                                   'type' => 'leftop',
                                                                                                   'op' => bless( {
                                                                                                                    'pattern' => ',|and',
                                                                                                                    'hashname' => '__PATTERN1__',
                                                                                                                    'description' => '/,|and/',
                                                                                                                    'lookahead' => 0,
                                                                                                                    'rdelim' => '/',
                                                                                                                    'line' => -86,
                                                                                                                    'mod' => '',
                                                                                                                    'ldelim' => '/'
                                                                                                                  }, 'Parse::RecDescent::Token' )
                                                                                                 }, 'Parse::RecDescent::Operator' ),
                                                                                          bless( {
                                                                                                   'pattern' => ')',
                                                                                                   'hashname' => '__STRING2__',
                                                                                                   'description' => '\')\'',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -86
                                                                                                 }, 'Parse::RecDescent::Literal' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -85,
                                                                                                   'code' => '{ new_node({ \'#name\' => \'and\'}, $item[2]) }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'and_clause',
                                                       'vars' => '',
                                                       'line' => -86
                                                     }, 'Parse::RecDescent::Rule' ),
                              'literal' => bless( {
                                                    'impcount' => 0,
                                                    'calls' => [
                                                                 'NUMBER',
                                                                 'STRING'
                                                               ],
                                                    'changed' => 0,
                                                    'opcount' => 0,
                                                    'prods' => [
                                                                 bless( {
                                                                          'number' => '0',
                                                                          'strcount' => 0,
                                                                          'dircount' => 0,
                                                                          'uncommit' => undef,
                                                                          'error' => undef,
                                                                          'patcount' => 0,
                                                                          'actcount' => 0,
                                                                          'items' => [
                                                                                       bless( {
                                                                                                'subrule' => 'NUMBER',
                                                                                                'matchrule' => 0,
                                                                                                'implicit' => undef,
                                                                                                'argcode' => undef,
                                                                                                'lookahead' => 0,
                                                                                                'line' => -26
                                                                                              }, 'Parse::RecDescent::Subrule' )
                                                                                     ],
                                                                          'line' => undef
                                                                        }, 'Parse::RecDescent::Production' ),
                                                                 bless( {
                                                                          'number' => '1',
                                                                          'strcount' => 0,
                                                                          'dircount' => 0,
                                                                          'uncommit' => undef,
                                                                          'error' => undef,
                                                                          'patcount' => 0,
                                                                          'actcount' => 0,
                                                                          'items' => [
                                                                                       bless( {
                                                                                                'subrule' => 'STRING',
                                                                                                'matchrule' => 0,
                                                                                                'implicit' => undef,
                                                                                                'argcode' => undef,
                                                                                                'lookahead' => 0,
                                                                                                'line' => -25
                                                                                              }, 'Parse::RecDescent::Subrule' )
                                                                                     ],
                                                                          'line' => -26
                                                                        }, 'Parse::RecDescent::Production' )
                                                               ],
                                                    'name' => 'literal',
                                                    'vars' => '',
                                                    'line' => -26
                                                  }, 'Parse::RecDescent::Rule' ),
                              'subquery' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [
                                                                  'occurrences',
                                                                  'RELATION',
                                                                  'node'
                                                                ],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'subrule' => 'occurrences',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -42
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'subrule' => 'RELATION',
                                                                                                 'expected' => undef,
                                                                                                 'min' => 0,
                                                                                                 'argcode' => undef,
                                                                                                 'max' => 1,
                                                                                                 'matchrule' => 0,
                                                                                                 'repspec' => '?',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -42
                                                                                               }, 'Parse::RecDescent::Repetition' ),
                                                                                        bless( {
                                                                                                 'subrule' => 'node',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -42
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -41,
                                                                                                 'code' => '{ $return=$item[3]; 
                $return->{\'#name\'}=\'subquery\';
                $return->{relation}=$item[2][0];
                $return->{occurrences}=$item[1];
                1;
              }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'subquery',
                                                     'vars' => '',
                                                     'line' => -42
                                                   }, 'Parse::RecDescent::Rule' ),
                              '_alternation_1_of_production_1_of_rule_parse_query' => bless( {
                                                                                               'impcount' => 0,
                                                                                               'calls' => [],
                                                                                               'changed' => 0,
                                                                                               'opcount' => 0,
                                                                                               'prods' => [
                                                                                                            bless( {
                                                                                                                     'number' => '0',
                                                                                                                     'strcount' => 1,
                                                                                                                     'dircount' => 0,
                                                                                                                     'uncommit' => undef,
                                                                                                                     'error' => undef,
                                                                                                                     'patcount' => 0,
                                                                                                                     'actcount' => 0,
                                                                                                                     'items' => [
                                                                                                                                  bless( {
                                                                                                                                           'pattern' => ';',
                                                                                                                                           'hashname' => '__STRING1__',
                                                                                                                                           'description' => '\';\'',
                                                                                                                                           'lookahead' => 0,
                                                                                                                                           'line' => 195
                                                                                                                                         }, 'Parse::RecDescent::Literal' )
                                                                                                                                ],
                                                                                                                     'line' => undef
                                                                                                                   }, 'Parse::RecDescent::Production' )
                                                                                                          ],
                                                                                               'name' => '_alternation_1_of_production_1_of_rule_parse_query',
                                                                                               'vars' => '',
                                                                                               'line' => 195
                                                                                             }, 'Parse::RecDescent::Rule' ),
                              'expression' => bless( {
                                                       'impcount' => 0,
                                                       'calls' => [
                                                                    'term',
                                                                    'OP'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 0,
                                                                             'dircount' => 1,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 0,
                                                                             'actcount' => 1,
                                                                             'op' => [],
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'expected' => '<leftop: term OP term>',
                                                                                                   'min' => 1,
                                                                                                   'name' => '',
                                                                                                   'max' => 100000000,
                                                                                                   'leftarg' => bless( {
                                                                                                                         'subrule' => 'term',
                                                                                                                         'matchrule' => 0,
                                                                                                                         'implicit' => undef,
                                                                                                                         'argcode' => undef,
                                                                                                                         'lookahead' => 0,
                                                                                                                         'line' => -67
                                                                                                                       }, 'Parse::RecDescent::Subrule' ),
                                                                                                   'rightarg' => bless( {
                                                                                                                          'subrule' => 'term',
                                                                                                                          'matchrule' => 0,
                                                                                                                          'implicit' => undef,
                                                                                                                          'argcode' => undef,
                                                                                                                          'lookahead' => 0,
                                                                                                                          'line' => -67
                                                                                                                        }, 'Parse::RecDescent::Subrule' ),
                                                                                                   'hashname' => '__DIRECTIVE1__',
                                                                                                   'type' => 'leftop',
                                                                                                   'op' => bless( {
                                                                                                                    'subrule' => 'OP',
                                                                                                                    'matchrule' => 0,
                                                                                                                    'implicit' => undef,
                                                                                                                    'argcode' => undef,
                                                                                                                    'lookahead' => 0,
                                                                                                                    'line' => -67
                                                                                                                  }, 'Parse::RecDescent::Subrule' )
                                                                                                 }, 'Parse::RecDescent::Operator' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -66,
                                                                                                   'code' => '{ @{$item[1]}>1 ? [\'EXP\',@{$item[1]}] : $item[1][0] }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'expression',
                                                       'vars' => '',
                                                       'line' => -67
                                                     }, 'Parse::RecDescent::Rule' ),
                              'not_clause' => bless( {
                                                       'impcount' => 1,
                                                       'calls' => [
                                                                    '_alternation_1_of_production_1_of_rule_not_clause'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 1,
                                                                             'dircount' => 0,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 0,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'pattern' => '!',
                                                                                                   'hashname' => '__STRING1__',
                                                                                                   'description' => '\'!\'',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -83
                                                                                                 }, 'Parse::RecDescent::Literal' ),
                                                                                          bless( {
                                                                                                   'subrule' => '_alternation_1_of_production_1_of_rule_not_clause',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => 'test, or or_clause, or and_clause',
                                                                                                   'argcode' => undef,
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -83
                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -82,
                                                                                                   'code' => '{  $return = $item[2];
                 if ($return->{\'#name\'} eq \'and\') {
                   $return->{\'#name\'} = \'not\';
                 } else {
                   $return = new_node({ \'#name\' => \'not\'}, [$return])
                 }
              }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'not_clause',
                                                       'vars' => '',
                                                       'line' => -83
                                                     }, 'Parse::RecDescent::Rule' ),
                              'CMP' => bless( {
                                                'impcount' => 0,
                                                'calls' => [],
                                                'changed' => 0,
                                                'opcount' => 0,
                                                'prods' => [
                                                             bless( {
                                                                      'number' => '0',
                                                                      'strcount' => 0,
                                                                      'dircount' => 0,
                                                                      'uncommit' => undef,
                                                                      'error' => undef,
                                                                      'patcount' => 1,
                                                                      'actcount' => 0,
                                                                      'items' => [
                                                                                   bless( {
                                                                                            'pattern' => '=|~\\*?|[<>]=?|in',
                                                                                            'hashname' => '__PATTERN1__',
                                                                                            'description' => '/=|~\\\\*?|[<>]=?|in/',
                                                                                            'lookahead' => 0,
                                                                                            'rdelim' => '/',
                                                                                            'line' => -8,
                                                                                            'mod' => '',
                                                                                            'ldelim' => '/'
                                                                                          }, 'Parse::RecDescent::Token' )
                                                                                 ],
                                                                      'line' => undef
                                                                    }, 'Parse::RecDescent::Production' )
                                                           ],
                                                'name' => 'CMP',
                                                'vars' => '',
                                                'line' => -8
                                              }, 'Parse::RecDescent::Rule' ),
                              '_alternation_1_of_production_1_of_rule_not_clause' => bless( {
                                                                                              'impcount' => 0,
                                                                                              'calls' => [
                                                                                                           'test',
                                                                                                           'or_clause',
                                                                                                           'and_clause'
                                                                                                         ],
                                                                                              'changed' => 0,
                                                                                              'opcount' => 0,
                                                                                              'prods' => [
                                                                                                           bless( {
                                                                                                                    'number' => '0',
                                                                                                                    'strcount' => 0,
                                                                                                                    'dircount' => 0,
                                                                                                                    'uncommit' => undef,
                                                                                                                    'error' => undef,
                                                                                                                    'patcount' => 0,
                                                                                                                    'actcount' => 0,
                                                                                                                    'items' => [
                                                                                                                                 bless( {
                                                                                                                                          'subrule' => 'test',
                                                                                                                                          'matchrule' => 0,
                                                                                                                                          'implicit' => undef,
                                                                                                                                          'argcode' => undef,
                                                                                                                                          'lookahead' => 0,
                                                                                                                                          'line' => 1
                                                                                                                                        }, 'Parse::RecDescent::Subrule' )
                                                                                                                               ],
                                                                                                                    'line' => undef
                                                                                                                  }, 'Parse::RecDescent::Production' ),
                                                                                                           bless( {
                                                                                                                    'number' => '1',
                                                                                                                    'strcount' => 0,
                                                                                                                    'dircount' => 0,
                                                                                                                    'uncommit' => undef,
                                                                                                                    'error' => undef,
                                                                                                                    'patcount' => 0,
                                                                                                                    'actcount' => 0,
                                                                                                                    'items' => [
                                                                                                                                 bless( {
                                                                                                                                          'subrule' => 'or_clause',
                                                                                                                                          'matchrule' => 0,
                                                                                                                                          'implicit' => undef,
                                                                                                                                          'argcode' => undef,
                                                                                                                                          'lookahead' => 0,
                                                                                                                                          'line' => 1
                                                                                                                                        }, 'Parse::RecDescent::Subrule' )
                                                                                                                               ],
                                                                                                                    'line' => 1
                                                                                                                  }, 'Parse::RecDescent::Production' ),
                                                                                                           bless( {
                                                                                                                    'number' => '2',
                                                                                                                    'strcount' => 0,
                                                                                                                    'dircount' => 0,
                                                                                                                    'uncommit' => undef,
                                                                                                                    'error' => undef,
                                                                                                                    'patcount' => 0,
                                                                                                                    'actcount' => 0,
                                                                                                                    'items' => [
                                                                                                                                 bless( {
                                                                                                                                          'subrule' => 'and_clause',
                                                                                                                                          'matchrule' => 0,
                                                                                                                                          'implicit' => undef,
                                                                                                                                          'argcode' => undef,
                                                                                                                                          'lookahead' => 0,
                                                                                                                                          'line' => 1
                                                                                                                                        }, 'Parse::RecDescent::Subrule' )
                                                                                                                               ],
                                                                                                                    'line' => 1
                                                                                                                  }, 'Parse::RecDescent::Production' )
                                                                                                         ],
                                                                                              'name' => '_alternation_1_of_production_1_of_rule_not_clause',
                                                                                              'vars' => '',
                                                                                              'line' => 1
                                                                                            }, 'Parse::RecDescent::Rule' ),
                              'parse_test' => bless( {
                                                       'impcount' => 0,
                                                       'calls' => [
                                                                    'test'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 0,
                                                                             'dircount' => 0,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 1,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'subrule' => 'test',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => undef,
                                                                                                   'argcode' => undef,
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -130
                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                          bless( {
                                                                                                   'pattern' => '\\Z',
                                                                                                   'hashname' => '__PATTERN1__',
                                                                                                   'description' => '/\\\\Z/',
                                                                                                   'lookahead' => 0,
                                                                                                   'rdelim' => '/',
                                                                                                   'line' => -130,
                                                                                                   'mod' => '',
                                                                                                   'ldelim' => '/'
                                                                                                 }, 'Parse::RecDescent::Token' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -130,
                                                                                                   'code' => '{ $item[1] }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' ),
                                                                    bless( {
                                                                             'number' => '1',
                                                                             'strcount' => 0,
                                                                             'dircount' => 0,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 0,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -129,
                                                                                                   'code' => '{ report_error($thisparser); }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => -129
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'parse_test',
                                                       'vars' => '',
                                                       'line' => -130
                                                     }, 'Parse::RecDescent::Rule' ),
                              'simple_test' => bless( {
                                                        'impcount' => 0,
                                                        'calls' => [
                                                                     'predicate',
                                                                     'or_clause',
                                                                     'not_clause',
                                                                     'and_clause'
                                                                   ],
                                                        'changed' => 0,
                                                        'opcount' => 0,
                                                        'prods' => [
                                                                     bless( {
                                                                              'number' => '0',
                                                                              'strcount' => 0,
                                                                              'dircount' => 0,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 0,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'predicate',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -95
                                                                                                  }, 'Parse::RecDescent::Subrule' )
                                                                                         ],
                                                                              'line' => undef
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '1',
                                                                              'strcount' => 0,
                                                                              'dircount' => 0,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 0,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'or_clause',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -95
                                                                                                  }, 'Parse::RecDescent::Subrule' )
                                                                                         ],
                                                                              'line' => -95
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '2',
                                                                              'strcount' => 0,
                                                                              'dircount' => 0,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 0,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'not_clause',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -95
                                                                                                  }, 'Parse::RecDescent::Subrule' )
                                                                                         ],
                                                                              'line' => -95
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '3',
                                                                              'strcount' => 0,
                                                                              'dircount' => 0,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 0,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'subrule' => 'and_clause',
                                                                                                    'matchrule' => 0,
                                                                                                    'implicit' => undef,
                                                                                                    'argcode' => undef,
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -95
                                                                                                  }, 'Parse::RecDescent::Subrule' )
                                                                                         ],
                                                                              'line' => -95
                                                                            }, 'Parse::RecDescent::Production' )
                                                                   ],
                                                        'name' => 'simple_test',
                                                        'vars' => '',
                                                        'line' => -95
                                                      }, 'Parse::RecDescent::Rule' ),
                              'parse_node' => bless( {
                                                       'impcount' => 0,
                                                       'calls' => [
                                                                    '_alternation_1_of_production_1_of_rule_parse_node'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 0,
                                                                             'dircount' => 0,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 1,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'subrule' => '_alternation_1_of_production_1_of_rule_parse_node',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => 'child, or opt_child',
                                                                                                   'argcode' => undef,
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -133
                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                          bless( {
                                                                                                   'pattern' => '\\Z',
                                                                                                   'hashname' => '__PATTERN1__',
                                                                                                   'description' => '/\\\\Z/',
                                                                                                   'lookahead' => 0,
                                                                                                   'rdelim' => '/',
                                                                                                   'line' => -133,
                                                                                                   'mod' => '',
                                                                                                   'ldelim' => '/'
                                                                                                 }, 'Parse::RecDescent::Token' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -133,
                                                                                                   'code' => '{ $item[1] }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' ),
                                                                    bless( {
                                                                             'number' => '1',
                                                                             'strcount' => 0,
                                                                             'dircount' => 0,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 0,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -132,
                                                                                                   'code' => '{ report_error($thisparser); }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => -132
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'parse_node',
                                                       'vars' => '',
                                                       'line' => -133
                                                     }, 'Parse::RecDescent::Rule' ),
                              'ref' => bless( {
                                                'impcount' => 1,
                                                'calls' => [
                                                             '_alternation_1_of_production_1_of_rule_ref',
                                                             'VARIABLE'
                                                           ],
                                                'changed' => 0,
                                                'opcount' => 0,
                                                'prods' => [
                                                             bless( {
                                                                      'number' => '0',
                                                                      'strcount' => 0,
                                                                      'dircount' => 0,
                                                                      'uncommit' => undef,
                                                                      'error' => undef,
                                                                      'patcount' => 0,
                                                                      'actcount' => 1,
                                                                      'items' => [
                                                                                   bless( {
                                                                                            'subrule' => '_alternation_1_of_production_1_of_rule_ref',
                                                                                            'expected' => 'RELATION, or EXTRA_RELATION',
                                                                                            'min' => 0,
                                                                                            'argcode' => undef,
                                                                                            'max' => 1,
                                                                                            'matchrule' => 0,
                                                                                            'repspec' => '?',
                                                                                            'lookahead' => 0,
                                                                                            'line' => -102
                                                                                          }, 'Parse::RecDescent::Repetition' ),
                                                                                   bless( {
                                                                                            'subrule' => 'VARIABLE',
                                                                                            'matchrule' => 0,
                                                                                            'implicit' => undef,
                                                                                            'argcode' => undef,
                                                                                            'lookahead' => 0,
                                                                                            'line' => -102
                                                                                          }, 'Parse::RecDescent::Subrule' ),
                                                                                   bless( {
                                                                                            'hashname' => '__ACTION1__',
                                                                                            'lookahead' => 0,
                                                                                            'line' => -101,
                                                                                            'code' => '{ $return = new_node({ \'#name\' => \'ref\', target=>$item[2], relation=>$item[1][0] });
         }'
                                                                                          }, 'Parse::RecDescent::Action' )
                                                                                 ],
                                                                      'line' => undef
                                                                    }, 'Parse::RecDescent::Production' )
                                                           ],
                                                'name' => 'ref',
                                                'vars' => '',
                                                'line' => -102
                                              }, 'Parse::RecDescent::Rule' ),
                              'opt_child' => bless( {
                                                      'impcount' => 0,
                                                      'calls' => [
                                                                   'RELATION',
                                                                   'node'
                                                                 ],
                                                      'changed' => 0,
                                                      'opcount' => 0,
                                                      'prods' => [
                                                                   bless( {
                                                                            'number' => '0',
                                                                            'strcount' => 1,
                                                                            'dircount' => 1,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'pattern' => '?',
                                                                                                  'hashname' => '__STRING1__',
                                                                                                  'description' => '\'?\'',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -98
                                                                                                }, 'Parse::RecDescent::Literal' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__DIRECTIVE1__',
                                                                                                  'name' => '<commit>',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -98,
                                                                                                  'code' => '$commit = 1'
                                                                                                }, 'Parse::RecDescent::Directive' ),
                                                                                         bless( {
                                                                                                  'subrule' => 'RELATION',
                                                                                                  'expected' => undef,
                                                                                                  'min' => 0,
                                                                                                  'argcode' => undef,
                                                                                                  'max' => 1,
                                                                                                  'matchrule' => 0,
                                                                                                  'repspec' => '?',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -98
                                                                                                }, 'Parse::RecDescent::Repetition' ),
                                                                                         bless( {
                                                                                                  'subrule' => 'node',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -98
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -97,
                                                                                                  'code' => '{ $return=$item[4]; $return->{optional}=1; $return->{relation}=$item[3][0]; 1 }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => undef
                                                                          }, 'Parse::RecDescent::Production' )
                                                                 ],
                                                      'name' => 'opt_child',
                                                      'vars' => '',
                                                      'line' => -98
                                                    }, 'Parse::RecDescent::Rule' ),
                              'EXTRA_RELATION' => bless( {
                                                           'impcount' => 0,
                                                           'calls' => [],
                                                           'changed' => 0,
                                                           'opcount' => 0,
                                                           'prods' => [
                                                                        bless( {
                                                                                 'number' => '0',
                                                                                 'strcount' => 0,
                                                                                 'dircount' => 0,
                                                                                 'uncommit' => undef,
                                                                                 'error' => undef,
                                                                                 'patcount' => 1,
                                                                                 'actcount' => 1,
                                                                                 'items' => [
                                                                                              bless( {
                                                                                                       'pattern' => 'depth-first-precedes|depth-first-follows|order-precedes|order-follows',
                                                                                                       'hashname' => '__PATTERN1__',
                                                                                                       'description' => '/depth-first-precedes|depth-first-follows|order-precedes|order-follows/',
                                                                                                       'lookahead' => 0,
                                                                                                       'rdelim' => '/',
                                                                                                       'line' => -13,
                                                                                                       'mod' => '',
                                                                                                       'ldelim' => '/'
                                                                                                     }, 'Parse::RecDescent::Token' ),
                                                                                              bless( {
                                                                                                       'hashname' => '__ACTION1__',
                                                                                                       'lookahead' => 0,
                                                                                                       'line' => -12,
                                                                                                       'code' => '{ new_relation($item[1]) }'
                                                                                                     }, 'Parse::RecDescent::Action' )
                                                                                            ],
                                                                                 'line' => undef
                                                                               }, 'Parse::RecDescent::Production' )
                                                                      ],
                                                           'name' => 'EXTRA_RELATION',
                                                           'vars' => '',
                                                           'line' => -13
                                                         }, 'Parse::RecDescent::Rule' ),
                              'flat_expression' => bless( {
                                                            'impcount' => 0,
                                                            'calls' => [
                                                                         'term',
                                                                         'OP'
                                                                       ],
                                                            'changed' => 0,
                                                            'opcount' => 0,
                                                            'prods' => [
                                                                         bless( {
                                                                                  'number' => '0',
                                                                                  'strcount' => 0,
                                                                                  'dircount' => 1,
                                                                                  'uncommit' => undef,
                                                                                  'error' => undef,
                                                                                  'patcount' => 0,
                                                                                  'actcount' => 0,
                                                                                  'items' => [
                                                                                               bless( {
                                                                                                        'hashname' => '__DIRECTIVE1__',
                                                                                                        'name' => '<rulevar: ($start,$t)>',
                                                                                                        'lookahead' => 0,
                                                                                                        'line' => -71
                                                                                                      }, 'Parse::RecDescent::UncondReject' )
                                                                                             ],
                                                                                  'line' => undef
                                                                                }, 'Parse::RecDescent::Production' ),
                                                                         bless( {
                                                                                  'number' => '1',
                                                                                  'strcount' => 0,
                                                                                  'dircount' => 1,
                                                                                  'uncommit' => undef,
                                                                                  'error' => undef,
                                                                                  'patcount' => 0,
                                                                                  'actcount' => 2,
                                                                                  'op' => [],
                                                                                  'items' => [
                                                                                               bless( {
                                                                                                        'hashname' => '__ACTION1__',
                                                                                                        'lookahead' => 0,
                                                                                                        'line' => -70,
                                                                                                        'code' => '{ ($start,$t)=($thisoffset,$text) }'
                                                                                                      }, 'Parse::RecDescent::Action' ),
                                                                                               bless( {
                                                                                                        'expected' => '<leftop: term OP term>',
                                                                                                        'min' => 1,
                                                                                                        'name' => '',
                                                                                                        'max' => 100000000,
                                                                                                        'leftarg' => bless( {
                                                                                                                              'subrule' => 'term',
                                                                                                                              'matchrule' => 0,
                                                                                                                              'implicit' => undef,
                                                                                                                              'argcode' => undef,
                                                                                                                              'lookahead' => 0,
                                                                                                                              'line' => -70
                                                                                                                            }, 'Parse::RecDescent::Subrule' ),
                                                                                                        'rightarg' => bless( {
                                                                                                                               'subrule' => 'term',
                                                                                                                               'matchrule' => 0,
                                                                                                                               'implicit' => undef,
                                                                                                                               'argcode' => undef,
                                                                                                                               'lookahead' => 0,
                                                                                                                               'line' => -70
                                                                                                                             }, 'Parse::RecDescent::Subrule' ),
                                                                                                        'hashname' => '__DIRECTIVE1__',
                                                                                                        'type' => 'leftop',
                                                                                                        'op' => bless( {
                                                                                                                         'subrule' => 'OP',
                                                                                                                         'matchrule' => 0,
                                                                                                                         'implicit' => undef,
                                                                                                                         'argcode' => undef,
                                                                                                                         'lookahead' => 0,
                                                                                                                         'line' => -70
                                                                                                                       }, 'Parse::RecDescent::Subrule' )
                                                                                                      }, 'Parse::RecDescent::Operator' ),
                                                                                               bless( {
                                                                                                        'hashname' => '__ACTION2__',
                                                                                                        'lookahead' => 0,
                                                                                                        'line' => -69,
                                                                                                        'code' => '{ $return=substr($t,0,$thisoffset-$start); $return=~s/^\\s*//; 1 }'
                                                                                                      }, 'Parse::RecDescent::Action' )
                                                                                             ],
                                                                                  'line' => -70
                                                                                }, 'Parse::RecDescent::Production' )
                                                                       ],
                                                            'name' => 'flat_expression',
                                                            'vars' => 'my  ($start,$t);
',
                                                            'line' => -71
                                                          }, 'Parse::RecDescent::Rule' ),
                              '_alternation_1_of_production_1_of_rule_ref' => bless( {
                                                                                       'impcount' => 0,
                                                                                       'calls' => [
                                                                                                    'RELATION',
                                                                                                    'EXTRA_RELATION'
                                                                                                  ],
                                                                                       'changed' => 0,
                                                                                       'opcount' => 0,
                                                                                       'prods' => [
                                                                                                    bless( {
                                                                                                             'number' => '0',
                                                                                                             'strcount' => 0,
                                                                                                             'dircount' => 0,
                                                                                                             'uncommit' => undef,
                                                                                                             'error' => undef,
                                                                                                             'patcount' => 0,
                                                                                                             'actcount' => 0,
                                                                                                             'items' => [
                                                                                                                          bless( {
                                                                                                                                   'subrule' => 'RELATION',
                                                                                                                                   'matchrule' => 0,
                                                                                                                                   'implicit' => undef,
                                                                                                                                   'argcode' => undef,
                                                                                                                                   'lookahead' => 0,
                                                                                                                                   'line' => 1
                                                                                                                                 }, 'Parse::RecDescent::Subrule' )
                                                                                                                        ],
                                                                                                             'line' => undef
                                                                                                           }, 'Parse::RecDescent::Production' ),
                                                                                                    bless( {
                                                                                                             'number' => '1',
                                                                                                             'strcount' => 0,
                                                                                                             'dircount' => 0,
                                                                                                             'uncommit' => undef,
                                                                                                             'error' => undef,
                                                                                                             'patcount' => 0,
                                                                                                             'actcount' => 0,
                                                                                                             'items' => [
                                                                                                                          bless( {
                                                                                                                                   'subrule' => 'EXTRA_RELATION',
                                                                                                                                   'matchrule' => 0,
                                                                                                                                   'implicit' => undef,
                                                                                                                                   'argcode' => undef,
                                                                                                                                   'lookahead' => 0,
                                                                                                                                   'line' => 1
                                                                                                                                 }, 'Parse::RecDescent::Subrule' )
                                                                                                                        ],
                                                                                                             'line' => 1
                                                                                                           }, 'Parse::RecDescent::Production' )
                                                                                                  ],
                                                                                       'name' => '_alternation_1_of_production_1_of_rule_ref',
                                                                                       'vars' => '',
                                                                                       'line' => 1
                                                                                     }, 'Parse::RecDescent::Rule' ),
                              'var_def' => bless( {
                                                    'impcount' => 0,
                                                    'calls' => [
                                                                 'VARIABLE'
                                                               ],
                                                    'changed' => 0,
                                                    'opcount' => 0,
                                                    'prods' => [
                                                                 bless( {
                                                                          'number' => '0',
                                                                          'strcount' => 2,
                                                                          'dircount' => 1,
                                                                          'uncommit' => undef,
                                                                          'error' => undef,
                                                                          'patcount' => 0,
                                                                          'actcount' => 1,
                                                                          'items' => [
                                                                                       bless( {
                                                                                                'subrule' => 'VARIABLE',
                                                                                                'matchrule' => 0,
                                                                                                'implicit' => undef,
                                                                                                'argcode' => undef,
                                                                                                'lookahead' => 0,
                                                                                                'line' => -117
                                                                                              }, 'Parse::RecDescent::Subrule' ),
                                                                                       bless( {
                                                                                                'pattern' => ':=',
                                                                                                'hashname' => '__STRING1__',
                                                                                                'description' => '\':=\'',
                                                                                                'lookahead' => 0,
                                                                                                'line' => -117
                                                                                              }, 'Parse::RecDescent::Literal' ),
                                                                                       bless( {
                                                                                                'hashname' => '__DIRECTIVE1__',
                                                                                                'name' => '<commit>',
                                                                                                'lookahead' => 0,
                                                                                                'line' => -117,
                                                                                                'code' => '$commit = 1'
                                                                                              }, 'Parse::RecDescent::Directive' ),
                                                                                       bless( {
                                                                                                'pattern' => '[',
                                                                                                'hashname' => '__STRING2__',
                                                                                                'description' => '\'[\'',
                                                                                                'lookahead' => 1,
                                                                                                'line' => -117
                                                                                              }, 'Parse::RecDescent::Literal' ),
                                                                                       bless( {
                                                                                                'hashname' => '__ACTION1__',
                                                                                                'lookahead' => 0,
                                                                                                'line' => -116,
                                                                                                'code' => '{ $return = $item[1] }'
                                                                                              }, 'Parse::RecDescent::Action' )
                                                                                     ],
                                                                          'line' => undef
                                                                        }, 'Parse::RecDescent::Production' )
                                                               ],
                                                    'name' => 'var_def',
                                                    'vars' => '',
                                                    'line' => -117
                                                  }, 'Parse::RecDescent::Rule' ),
                              'OP' => bless( {
                                               'impcount' => 0,
                                               'calls' => [],
                                               'changed' => 0,
                                               'opcount' => 0,
                                               'prods' => [
                                                            bless( {
                                                                     'number' => '0',
                                                                     'strcount' => 0,
                                                                     'dircount' => 0,
                                                                     'uncommit' => undef,
                                                                     'error' => undef,
                                                                     'patcount' => 1,
                                                                     'actcount' => 0,
                                                                     'items' => [
                                                                                  bless( {
                                                                                           'pattern' => '[-+*~]|div|mod',
                                                                                           'hashname' => '__PATTERN1__',
                                                                                           'description' => '/[-+*~]|div|mod/',
                                                                                           'lookahead' => 0,
                                                                                           'rdelim' => '/',
                                                                                           'line' => -6,
                                                                                           'mod' => '',
                                                                                           'ldelim' => '/'
                                                                                         }, 'Parse::RecDescent::Token' )
                                                                                ],
                                                                     'line' => undef
                                                                   }, 'Parse::RecDescent::Production' )
                                                          ],
                                               'name' => 'OP',
                                               'vars' => '',
                                               'line' => -6
                                             }, 'Parse::RecDescent::Rule' ),
                              '_alternation_1_of_production_1_of_rule_parse_node' => bless( {
                                                                                              'impcount' => 0,
                                                                                              'calls' => [
                                                                                                           'child',
                                                                                                           'opt_child'
                                                                                                         ],
                                                                                              'changed' => 0,
                                                                                              'opcount' => 0,
                                                                                              'prods' => [
                                                                                                           bless( {
                                                                                                                    'number' => '0',
                                                                                                                    'strcount' => 0,
                                                                                                                    'dircount' => 0,
                                                                                                                    'uncommit' => undef,
                                                                                                                    'error' => undef,
                                                                                                                    'patcount' => 0,
                                                                                                                    'actcount' => 0,
                                                                                                                    'items' => [
                                                                                                                                 bless( {
                                                                                                                                          'subrule' => 'child',
                                                                                                                                          'matchrule' => 0,
                                                                                                                                          'implicit' => undef,
                                                                                                                                          'argcode' => undef,
                                                                                                                                          'lookahead' => 0,
                                                                                                                                          'line' => 1
                                                                                                                                        }, 'Parse::RecDescent::Subrule' )
                                                                                                                               ],
                                                                                                                    'line' => undef
                                                                                                                  }, 'Parse::RecDescent::Production' ),
                                                                                                           bless( {
                                                                                                                    'number' => '1',
                                                                                                                    'strcount' => 0,
                                                                                                                    'dircount' => 0,
                                                                                                                    'uncommit' => undef,
                                                                                                                    'error' => undef,
                                                                                                                    'patcount' => 0,
                                                                                                                    'actcount' => 0,
                                                                                                                    'items' => [
                                                                                                                                 bless( {
                                                                                                                                          'subrule' => 'opt_child',
                                                                                                                                          'matchrule' => 0,
                                                                                                                                          'implicit' => undef,
                                                                                                                                          'argcode' => undef,
                                                                                                                                          'lookahead' => 0,
                                                                                                                                          'line' => 1
                                                                                                                                        }, 'Parse::RecDescent::Subrule' )
                                                                                                                               ],
                                                                                                                    'line' => 1
                                                                                                                  }, 'Parse::RecDescent::Production' )
                                                                                                         ],
                                                                                              'name' => '_alternation_1_of_production_1_of_rule_parse_node',
                                                                                              'vars' => '',
                                                                                              'line' => 1
                                                                                            }, 'Parse::RecDescent::Rule' ),
                              'arguments' => bless( {
                                                      'impcount' => 0,
                                                      'calls' => [
                                                                   'argument'
                                                                 ],
                                                      'changed' => 0,
                                                      'opcount' => 0,
                                                      'prods' => [
                                                                   bless( {
                                                                            'number' => '0',
                                                                            'strcount' => 1,
                                                                            'dircount' => 1,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'op' => [],
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'expected' => '<leftop: argument \',\' argument>',
                                                                                                  'min' => 1,
                                                                                                  'name' => '',
                                                                                                  'max' => 100000000,
                                                                                                  'leftarg' => bless( {
                                                                                                                        'subrule' => 'argument',
                                                                                                                        'matchrule' => 0,
                                                                                                                        'implicit' => undef,
                                                                                                                        'argcode' => undef,
                                                                                                                        'lookahead' => 0,
                                                                                                                        'line' => -48
                                                                                                                      }, 'Parse::RecDescent::Subrule' ),
                                                                                                  'rightarg' => bless( {
                                                                                                                         'subrule' => 'argument',
                                                                                                                         'matchrule' => 0,
                                                                                                                         'implicit' => undef,
                                                                                                                         'argcode' => undef,
                                                                                                                         'lookahead' => 0,
                                                                                                                         'line' => -48
                                                                                                                       }, 'Parse::RecDescent::Subrule' ),
                                                                                                  'hashname' => '__DIRECTIVE1__',
                                                                                                  'type' => 'leftop',
                                                                                                  'op' => bless( {
                                                                                                                   'pattern' => ',',
                                                                                                                   'hashname' => '__STRING1__',
                                                                                                                   'description' => '\',\'',
                                                                                                                   'lookahead' => 0,
                                                                                                                   'line' => -48
                                                                                                                 }, 'Parse::RecDescent::Literal' )
                                                                                                }, 'Parse::RecDescent::Operator' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -47,
                                                                                                  'code' => '{ $item[1] }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => undef
                                                                          }, 'Parse::RecDescent::Production' )
                                                                 ],
                                                      'name' => 'arguments',
                                                      'vars' => '',
                                                      'line' => -48
                                                    }, 'Parse::RecDescent::Rule' ),
                              'type' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'XMLNAME'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 1,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'XMLNAME',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -120
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'pattern' => '\\$|\\[',
                                                                                             'hashname' => '__PATTERN1__',
                                                                                             'description' => '/\\\\$|\\\\[/',
                                                                                             'lookahead' => 1,
                                                                                             'rdelim' => '/',
                                                                                             'line' => -120,
                                                                                             'mod' => '',
                                                                                             'ldelim' => '/'
                                                                                           }, 'Parse::RecDescent::Token' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -119,
                                                                                             'code' => '{ $return = $item[1] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'type',
                                                 'vars' => '',
                                                 'line' => -120
                                               }, 'Parse::RecDescent::Rule' ),
                              'conditions' => bless( {
                                                       'impcount' => 0,
                                                       'calls' => [
                                                                    'condition',
                                                                    'conditions'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 0,
                                                                             'dircount' => 1,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 1,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'subrule' => 'condition',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => undef,
                                                                                                   'argcode' => undef,
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -114
                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                          bless( {
                                                                                                   'pattern' => ',?\\s*]',
                                                                                                   'hashname' => '__PATTERN1__',
                                                                                                   'description' => '/,?\\\\s*]/',
                                                                                                   'lookahead' => 1,
                                                                                                   'rdelim' => '/',
                                                                                                   'line' => -114,
                                                                                                   'mod' => '',
                                                                                                   'ldelim' => '/'
                                                                                                 }, 'Parse::RecDescent::Token' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__DIRECTIVE1__',
                                                                                                   'name' => '<commit>',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -114,
                                                                                                   'code' => '$commit = 1'
                                                                                                 }, 'Parse::RecDescent::Directive' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -114,
                                                                                                   'code' => '{ $return = [$item[1]] }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' ),
                                                                    bless( {
                                                                             'number' => '1',
                                                                             'strcount' => 0,
                                                                             'dircount' => 1,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 1,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'subrule' => 'condition',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => undef,
                                                                                                   'argcode' => undef,
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -113
                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                          bless( {
                                                                                                   'pattern' => 'and|,',
                                                                                                   'hashname' => '__PATTERN1__',
                                                                                                   'description' => '/and|,/',
                                                                                                   'lookahead' => 0,
                                                                                                   'rdelim' => '/',
                                                                                                   'line' => -113,
                                                                                                   'mod' => '',
                                                                                                   'ldelim' => '/'
                                                                                                 }, 'Parse::RecDescent::Token' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__DIRECTIVE1__',
                                                                                                   'name' => '<commit>',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -113,
                                                                                                   'code' => '$commit = 1'
                                                                                                 }, 'Parse::RecDescent::Directive' ),
                                                                                          bless( {
                                                                                                   'subrule' => 'conditions',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => undef,
                                                                                                   'argcode' => undef,
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -113
                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -113,
                                                                                                   'code' => '{ $return = [$item[1],@{$item[4]}] }'
                                                                                                 }, 'Parse::RecDescent::Action' )
                                                                                        ],
                                                                             'line' => -113
                                                                           }, 'Parse::RecDescent::Production' ),
                                                                    bless( {
                                                                             'number' => '2',
                                                                             'strcount' => 0,
                                                                             'dircount' => 1,
                                                                             'uncommit' => 0,
                                                                             'error' => 1,
                                                                             'patcount' => 0,
                                                                             'actcount' => 0,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'msg' => '',
                                                                                                   'hashname' => '__DIRECTIVE1__',
                                                                                                   'commitonly' => '',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => -112
                                                                                                 }, 'Parse::RecDescent::Error' )
                                                                                        ],
                                                                             'line' => -112
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'conditions',
                                                       'vars' => '',
                                                       'line' => -114
                                                     }, 'Parse::RecDescent::Rule' ),
                              '_alternation_1_of_production_1_of_rule_simple_attribute' => bless( {
                                                                                                    'impcount' => 0,
                                                                                                    'calls' => [
                                                                                                                 'XMLNAME'
                                                                                                               ],
                                                                                                    'changed' => 0,
                                                                                                    'opcount' => 0,
                                                                                                    'prods' => [
                                                                                                                 bless( {
                                                                                                                          'number' => '0',
                                                                                                                          'strcount' => 1,
                                                                                                                          'dircount' => 0,
                                                                                                                          'uncommit' => undef,
                                                                                                                          'error' => undef,
                                                                                                                          'patcount' => 0,
                                                                                                                          'actcount' => 0,
                                                                                                                          'items' => [
                                                                                                                                       bless( {
                                                                                                                                                'pattern' => '/',
                                                                                                                                                'hashname' => '__STRING1__',
                                                                                                                                                'description' => '\'/\'',
                                                                                                                                                'lookahead' => 0,
                                                                                                                                                'line' => 1
                                                                                                                                              }, 'Parse::RecDescent::Literal' ),
                                                                                                                                       bless( {
                                                                                                                                                'subrule' => 'XMLNAME',
                                                                                                                                                'matchrule' => 0,
                                                                                                                                                'implicit' => undef,
                                                                                                                                                'argcode' => undef,
                                                                                                                                                'lookahead' => 0,
                                                                                                                                                'line' => 1
                                                                                                                                              }, 'Parse::RecDescent::Subrule' )
                                                                                                                                     ],
                                                                                                                          'line' => undef
                                                                                                                        }, 'Parse::RecDescent::Production' )
                                                                                                               ],
                                                                                                    'name' => '_alternation_1_of_production_1_of_rule_simple_attribute',
                                                                                                    'vars' => '',
                                                                                                    'line' => 1
                                                                                                  }, 'Parse::RecDescent::Rule' ),
                              'ref_attribute' => bless( {
                                                          'impcount' => 0,
                                                          'calls' => [
                                                                       'VARIABLE',
                                                                       'simple_attribute'
                                                                     ],
                                                          'changed' => 0,
                                                          'opcount' => 0,
                                                          'prods' => [
                                                                       bless( {
                                                                                'number' => '0',
                                                                                'strcount' => 1,
                                                                                'dircount' => 1,
                                                                                'uncommit' => undef,
                                                                                'error' => undef,
                                                                                'patcount' => 0,
                                                                                'actcount' => 1,
                                                                                'items' => [
                                                                                             bless( {
                                                                                                      'subrule' => 'VARIABLE',
                                                                                                      'matchrule' => 0,
                                                                                                      'implicit' => undef,
                                                                                                      'argcode' => undef,
                                                                                                      'lookahead' => 0,
                                                                                                      'line' => -54
                                                                                                    }, 'Parse::RecDescent::Subrule' ),
                                                                                             bless( {
                                                                                                      'hashname' => '__DIRECTIVE1__',
                                                                                                      'name' => '<skip: \'\'>',
                                                                                                      'lookahead' => 0,
                                                                                                      'line' => -54,
                                                                                                      'code' => 'my $oldskip = $skip; $skip= \'\'; $oldskip'
                                                                                                    }, 'Parse::RecDescent::Directive' ),
                                                                                             bless( {
                                                                                                      'pattern' => '.',
                                                                                                      'hashname' => '__STRING1__',
                                                                                                      'description' => '\'.\'',
                                                                                                      'lookahead' => 0,
                                                                                                      'line' => -54
                                                                                                    }, 'Parse::RecDescent::Literal' ),
                                                                                             bless( {
                                                                                                      'subrule' => 'simple_attribute',
                                                                                                      'matchrule' => 0,
                                                                                                      'implicit' => undef,
                                                                                                      'argcode' => undef,
                                                                                                      'lookahead' => 0,
                                                                                                      'line' => -54
                                                                                                    }, 'Parse::RecDescent::Subrule' ),
                                                                                             bless( {
                                                                                                      'hashname' => '__ACTION1__',
                                                                                                      'lookahead' => 0,
                                                                                                      'line' => -53,
                                                                                                      'code' => '{ [\'REF_ATTR\',$item[1],$item[4]] }'
                                                                                                    }, 'Parse::RecDescent::Action' )
                                                                                           ],
                                                                                'line' => undef
                                                                              }, 'Parse::RecDescent::Production' )
                                                                     ],
                                                          'name' => 'ref_attribute',
                                                          'vars' => '',
                                                          'line' => -54
                                                        }, 'Parse::RecDescent::Rule' ),
                              'parse_expression' => bless( {
                                                             'impcount' => 0,
                                                             'calls' => [
                                                                          'expression'
                                                                        ],
                                                             'changed' => 0,
                                                             'opcount' => 0,
                                                             'prods' => [
                                                                          bless( {
                                                                                   'number' => '0',
                                                                                   'strcount' => 0,
                                                                                   'dircount' => 0,
                                                                                   'uncommit' => undef,
                                                                                   'error' => undef,
                                                                                   'patcount' => 1,
                                                                                   'actcount' => 1,
                                                                                   'items' => [
                                                                                                bless( {
                                                                                                         'subrule' => 'expression',
                                                                                                         'matchrule' => 0,
                                                                                                         'implicit' => undef,
                                                                                                         'argcode' => undef,
                                                                                                         'lookahead' => 0,
                                                                                                         'line' => -127
                                                                                                       }, 'Parse::RecDescent::Subrule' ),
                                                                                                bless( {
                                                                                                         'pattern' => '\\Z',
                                                                                                         'hashname' => '__PATTERN1__',
                                                                                                         'description' => '/\\\\Z/',
                                                                                                         'lookahead' => 0,
                                                                                                         'rdelim' => '/',
                                                                                                         'line' => -127,
                                                                                                         'mod' => '',
                                                                                                         'ldelim' => '/'
                                                                                                       }, 'Parse::RecDescent::Token' ),
                                                                                                bless( {
                                                                                                         'hashname' => '__ACTION1__',
                                                                                                         'lookahead' => 0,
                                                                                                         'line' => -127,
                                                                                                         'code' => '{ $item[1] }'
                                                                                                       }, 'Parse::RecDescent::Action' )
                                                                                              ],
                                                                                   'line' => undef
                                                                                 }, 'Parse::RecDescent::Production' ),
                                                                          bless( {
                                                                                   'number' => '1',
                                                                                   'strcount' => 0,
                                                                                   'dircount' => 0,
                                                                                   'uncommit' => undef,
                                                                                   'error' => undef,
                                                                                   'patcount' => 0,
                                                                                   'actcount' => 1,
                                                                                   'items' => [
                                                                                                bless( {
                                                                                                         'hashname' => '__ACTION1__',
                                                                                                         'lookahead' => 0,
                                                                                                         'line' => -126,
                                                                                                         'code' => '{ report_error($thisparser); }'
                                                                                                       }, 'Parse::RecDescent::Action' )
                                                                                              ],
                                                                                   'line' => -126
                                                                                 }, 'Parse::RecDescent::Production' )
                                                                        ],
                                                             'name' => 'parse_expression',
                                                             'vars' => '',
                                                             'line' => -127
                                                           }, 'Parse::RecDescent::Rule' ),
                              'function' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [
                                                                  'FUNC',
                                                                  'arguments'
                                                                ],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 2,
                                                                           'dircount' => 2,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'subrule' => 'FUNC',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -51
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__DIRECTIVE1__',
                                                                                                 'name' => '<skip: \'\'>',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -51,
                                                                                                 'code' => 'my $oldskip = $skip; $skip= \'\'; $oldskip'
                                                                                               }, 'Parse::RecDescent::Directive' ),
                                                                                        bless( {
                                                                                                 'pattern' => '(',
                                                                                                 'hashname' => '__STRING1__',
                                                                                                 'description' => '\'(\'',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -51
                                                                                               }, 'Parse::RecDescent::Literal' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__DIRECTIVE2__',
                                                                                                 'name' => '<skip: \'\\s*(?:[#][^\\n]*\\s*)?\'>',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -51,
                                                                                                 'code' => 'my $oldskip = $skip; $skip= \'\\s*(?:[#][^\\n]*\\s*)?\'; $oldskip'
                                                                                               }, 'Parse::RecDescent::Directive' ),
                                                                                        bless( {
                                                                                                 'subrule' => 'arguments',
                                                                                                 'expected' => undef,
                                                                                                 'min' => 0,
                                                                                                 'argcode' => undef,
                                                                                                 'max' => 1,
                                                                                                 'matchrule' => 0,
                                                                                                 'repspec' => '?',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -51
                                                                                               }, 'Parse::RecDescent::Repetition' ),
                                                                                        bless( {
                                                                                                 'pattern' => ')',
                                                                                                 'hashname' => '__STRING2__',
                                                                                                 'description' => '\')\'',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -51
                                                                                               }, 'Parse::RecDescent::Literal' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -50,
                                                                                                 'code' => '{ [\'FUNC\', $item[1],$item[5][0] ] }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'function',
                                                     'vars' => '',
                                                     'line' => -51
                                                   }, 'Parse::RecDescent::Rule' ),
                              'VARIABLE' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 1,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'pattern' => '\\$[[:alpha:]_][[:alnum:]_]*',
                                                                                                 'hashname' => '__PATTERN1__',
                                                                                                 'description' => '/\\\\$[[:alpha:]_][[:alnum:]_]*/',
                                                                                                 'lookahead' => 0,
                                                                                                 'rdelim' => '/',
                                                                                                 'line' => -23,
                                                                                                 'mod' => '',
                                                                                                 'ldelim' => '/'
                                                                                               }, 'Parse::RecDescent::Token' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -22,
                                                                                                 'code' => '{ $return=$item[1]; $return=~s/^\\$//; 1 }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'VARIABLE',
                                                     'vars' => '',
                                                     'line' => -23
                                                   }, 'Parse::RecDescent::Rule' ),
                              'simple_attribute' => bless( {
                                                             'impcount' => 1,
                                                             'calls' => [
                                                                          'XMLNAME',
                                                                          '_alternation_1_of_production_1_of_rule_simple_attribute'
                                                                        ],
                                                             'changed' => 0,
                                                             'opcount' => 0,
                                                             'prods' => [
                                                                          bless( {
                                                                                   'number' => '0',
                                                                                   'strcount' => 0,
                                                                                   'dircount' => 0,
                                                                                   'uncommit' => undef,
                                                                                   'error' => undef,
                                                                                   'patcount' => 0,
                                                                                   'actcount' => 1,
                                                                                   'items' => [
                                                                                                bless( {
                                                                                                         'subrule' => 'XMLNAME',
                                                                                                         'matchrule' => 0,
                                                                                                         'implicit' => undef,
                                                                                                         'argcode' => undef,
                                                                                                         'lookahead' => 0,
                                                                                                         'line' => -57
                                                                                                       }, 'Parse::RecDescent::Subrule' ),
                                                                                                bless( {
                                                                                                         'subrule' => '_alternation_1_of_production_1_of_rule_simple_attribute',
                                                                                                         'expected' => '\'/\'',
                                                                                                         'min' => 0,
                                                                                                         'argcode' => undef,
                                                                                                         'max' => 100000000,
                                                                                                         'matchrule' => 0,
                                                                                                         'repspec' => 's?',
                                                                                                         'lookahead' => 0,
                                                                                                         'line' => -57
                                                                                                       }, 'Parse::RecDescent::Repetition' ),
                                                                                                bless( {
                                                                                                         'hashname' => '__ACTION1__',
                                                                                                         'lookahead' => 0,
                                                                                                         'line' => -56,
                                                                                                         'code' => '{ [\'ATTR\',$item[1],@{$item[2]}] }'
                                                                                                       }, 'Parse::RecDescent::Action' )
                                                                                              ],
                                                                                   'line' => undef
                                                                                 }, 'Parse::RecDescent::Production' )
                                                                        ],
                                                             'name' => 'simple_attribute',
                                                             'vars' => '',
                                                             'line' => -57
                                                           }, 'Parse::RecDescent::Rule' ),
                              'node' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'type',
                                                              'var_def',
                                                              'conditions'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 1,
                                                                       'dircount' => 1,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 1,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'type',
                                                                                             'expected' => undef,
                                                                                             'min' => 0,
                                                                                             'argcode' => undef,
                                                                                             'max' => 1,
                                                                                             'matchrule' => 0,
                                                                                             'repspec' => '?',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -124
                                                                                           }, 'Parse::RecDescent::Repetition' ),
                                                                                    bless( {
                                                                                             'subrule' => 'var_def',
                                                                                             'expected' => undef,
                                                                                             'min' => 0,
                                                                                             'argcode' => undef,
                                                                                             'max' => 1,
                                                                                             'matchrule' => 0,
                                                                                             'repspec' => '?',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -124
                                                                                           }, 'Parse::RecDescent::Repetition' ),
                                                                                    bless( {
                                                                                             'pattern' => '[',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'[\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -124
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'name' => '<commit>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -124,
                                                                                             'code' => '$commit = 1'
                                                                                           }, 'Parse::RecDescent::Directive' ),
                                                                                    bless( {
                                                                                             'subrule' => 'conditions',
                                                                                             'expected' => undef,
                                                                                             'min' => 0,
                                                                                             'argcode' => undef,
                                                                                             'max' => 1,
                                                                                             'matchrule' => 0,
                                                                                             'repspec' => '?',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -124
                                                                                           }, 'Parse::RecDescent::Repetition' ),
                                                                                    bless( {
                                                                                             'pattern' => ',?\\s*]',
                                                                                             'hashname' => '__PATTERN1__',
                                                                                             'description' => '/,?\\\\s*]/',
                                                                                             'lookahead' => 0,
                                                                                             'rdelim' => '/',
                                                                                             'line' => -124,
                                                                                             'mod' => '',
                                                                                             'ldelim' => '/'
                                                                                           }, 'Parse::RecDescent::Token' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -123,
                                                                                             'code' => '{ new_node({ \'#name\' => \'node\', \'node-type\' => $item[1][0], name => $item[2][0]}, $item[5][0]) }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '1',
                                                                       'strcount' => 0,
                                                                       'dircount' => 1,
                                                                       'uncommit' => 0,
                                                                       'error' => 1,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'msg' => '',
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'commitonly' => '',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -122
                                                                                           }, 'Parse::RecDescent::Error' )
                                                                                  ],
                                                                       'line' => -122
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'node',
                                                 'vars' => '',
                                                 'line' => -124
                                               }, 'Parse::RecDescent::Rule' ),
                              'STRING' => bless( {
                                                   'impcount' => 0,
                                                   'calls' => [],
                                                   'changed' => 0,
                                                   'opcount' => 0,
                                                   'prods' => [
                                                                bless( {
                                                                         'number' => '0',
                                                                         'strcount' => 0,
                                                                         'dircount' => 0,
                                                                         'uncommit' => undef,
                                                                         'error' => undef,
                                                                         'patcount' => 1,
                                                                         'actcount' => 0,
                                                                         'items' => [
                                                                                      bless( {
                                                                                               'pattern' => '\'([^\'\\\\]+|\\\\.)*\'',
                                                                                               'hashname' => '__PATTERN1__',
                                                                                               'description' => '/\'([^\'\\\\\\\\]+|\\\\\\\\.)*\'/',
                                                                                               'lookahead' => 0,
                                                                                               'rdelim' => '/',
                                                                                               'line' => -4,
                                                                                               'mod' => '',
                                                                                               'ldelim' => '/'
                                                                                             }, 'Parse::RecDescent::Token' )
                                                                                    ],
                                                                         'line' => undef
                                                                       }, 'Parse::RecDescent::Production' )
                                                              ],
                                                   'name' => 'STRING',
                                                   'vars' => '',
                                                   'line' => -4
                                                 }, 'Parse::RecDescent::Rule' ),
                              'FUNC' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 1,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => 'descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr',
                                                                                             'hashname' => '__PATTERN1__',
                                                                                             'description' => '/descendants|lbrother|rbrother|sons|depth|lower|upper|length|substr/',
                                                                                             'lookahead' => 0,
                                                                                             'rdelim' => '/',
                                                                                             'line' => -10,
                                                                                             'mod' => '',
                                                                                             'ldelim' => '/'
                                                                                           }, 'Parse::RecDescent::Token' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'FUNC',
                                                 'vars' => '',
                                                 'line' => -10
                                               }, 'Parse::RecDescent::Rule' ),
                              'term' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'expression',
                                                              'function',
                                                              'simple_attribute',
                                                              'ref_attribute',
                                                              'literal'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 2,
                                                                       'dircount' => 1,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => '(',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'(\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -64
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'name' => '<commit>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -64,
                                                                                             'code' => '$commit = 1'
                                                                                           }, 'Parse::RecDescent::Directive' ),
                                                                                    bless( {
                                                                                             'subrule' => 'expression',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -64
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'pattern' => ')',
                                                                                             'hashname' => '__STRING2__',
                                                                                             'description' => '\')\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -64
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -64,
                                                                                             'code' => '{ $return=$item[3] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '1',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'function',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -63
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -63,
                                                                                             'code' => '{ $return=$item[1] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => -63
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '2',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'simple_attribute',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -62
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -62,
                                                                                             'code' => '{ $return=$item[1] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => -62
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '3',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'ref_attribute',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -61
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -61,
                                                                                             'code' => '{ $return=$item[1] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => -61
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '4',
                                                                       'strcount' => 0,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'literal',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => -60
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -60,
                                                                                             'code' => '{ $return=$item[1] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => -60
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '5',
                                                                       'strcount' => 0,
                                                                       'dircount' => 1,
                                                                       'uncommit' => 0,
                                                                       'error' => 1,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'msg' => '',
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'commitonly' => '',
                                                                                             'lookahead' => 0,
                                                                                             'line' => -59
                                                                                           }, 'Parse::RecDescent::Error' )
                                                                                  ],
                                                                       'line' => -59
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'term',
                                                 'vars' => '',
                                                 'line' => -64
                                               }, 'Parse::RecDescent::Rule' ),
                              'argument' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [
                                                                  'expression',
                                                                  'VARIABLE'
                                                                ],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'subrule' => 'expression',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -45
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -45,
                                                                                                 'code' => '{ $item[1] }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '1',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'subrule' => 'VARIABLE',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -44
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -44,
                                                                                                 'code' => '{ \'$\'.$item[1] }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => -44
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'argument',
                                                     'vars' => '',
                                                     'line' => -45
                                                   }, 'Parse::RecDescent::Rule' ),
                              'predicate' => bless( {
                                                      'impcount' => 0,
                                                      'calls' => [
                                                                   'flat_expression',
                                                                   'CMP'
                                                                 ],
                                                      'changed' => 0,
                                                      'opcount' => 0,
                                                      'prods' => [
                                                                   bless( {
                                                                            'number' => '0',
                                                                            'strcount' => 0,
                                                                            'dircount' => 1,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'flat_expression',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -74
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'subrule' => 'CMP',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -74
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__DIRECTIVE1__',
                                                                                                  'name' => '<commit>',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -74,
                                                                                                  'code' => '$commit = 1'
                                                                                                }, 'Parse::RecDescent::Directive' ),
                                                                                         bless( {
                                                                                                  'subrule' => 'flat_expression',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -74
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -73,
                                                                                                  'code' => '{ new_node({ \'#name\' => \'test\', a=>$item[1], operator=>$item[2], b=>$item[4] }) }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => undef
                                                                          }, 'Parse::RecDescent::Production' )
                                                                 ],
                                                      'name' => 'predicate',
                                                      'vars' => '',
                                                      'line' => -74
                                                    }, 'Parse::RecDescent::Rule' ),
                              'RELATION' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [
                                                                  'NUMBER'
                                                                ],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 3,
                                                                           'dircount' => 3,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 1,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'pattern' => 'descendant|ancestor',
                                                                                                 'hashname' => '__PATTERN1__',
                                                                                                 'description' => '/descendant|ancestor/',
                                                                                                 'lookahead' => 0,
                                                                                                 'rdelim' => '/',
                                                                                                 'line' => -20,
                                                                                                 'mod' => '',
                                                                                                 'ldelim' => '/'
                                                                                               }, 'Parse::RecDescent::Token' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__DIRECTIVE1__',
                                                                                                 'name' => '<skip:\'\'>',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -20,
                                                                                                 'code' => 'my $oldskip = $skip; $skip=\'\'; $oldskip'
                                                                                               }, 'Parse::RecDescent::Directive' ),
                                                                                        bless( {
                                                                                                 'pattern' => '{',
                                                                                                 'hashname' => '__STRING1__',
                                                                                                 'description' => '\'\\{\'',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -20
                                                                                               }, 'Parse::RecDescent::Literal' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__DIRECTIVE2__',
                                                                                                 'name' => '<commit>',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -19,
                                                                                                 'code' => '$commit = 1'
                                                                                               }, 'Parse::RecDescent::Directive' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__DIRECTIVE3__',
                                                                                                 'name' => '<skip:\'\\s*(?:[#][^\\n]*\\s*)?\'>',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -19,
                                                                                                 'code' => 'my $oldskip = $skip; $skip=\'\\s*(?:[#][^\\n]*\\s*)?\'; $oldskip'
                                                                                               }, 'Parse::RecDescent::Directive' ),
                                                                                        bless( {
                                                                                                 'subrule' => 'NUMBER',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -19
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'pattern' => ',',
                                                                                                 'hashname' => '__STRING2__',
                                                                                                 'description' => '\',\'',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -19
                                                                                               }, 'Parse::RecDescent::Literal' ),
                                                                                        bless( {
                                                                                                 'subrule' => 'NUMBER',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -19
                                                                                               }, 'Parse::RecDescent::Subrule' ),
                                                                                        bless( {
                                                                                                 'pattern' => '}',
                                                                                                 'hashname' => '__STRING3__',
                                                                                                 'description' => '\'\\}\'',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -19
                                                                                               }, 'Parse::RecDescent::Literal' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -18,
                                                                                                 'code' => '{ new_relation($item[1],{min_length=>$item[6],max_length=>$item[8]}) }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '1',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 1,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'pattern' => 'child|parent|descendant|ancestor',
                                                                                                 'hashname' => '__PATTERN1__',
                                                                                                 'description' => '/child|parent|descendant|ancestor/',
                                                                                                 'lookahead' => 0,
                                                                                                 'rdelim' => '/',
                                                                                                 'line' => -17,
                                                                                                 'mod' => '',
                                                                                                 'ldelim' => '/'
                                                                                               }, 'Parse::RecDescent::Token' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -16,
                                                                                                 'code' => '{ new_relation($item[1]) }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => -17
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '2',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 1,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'pattern' => '${Tree_Query::user_defined}',
                                                                                                 'hashname' => '__PATTERN1__',
                                                                                                 'description' => '/$\\{Tree_Query::user_defined\\}/o',
                                                                                                 'lookahead' => 0,
                                                                                                 'rdelim' => '/',
                                                                                                 'line' => -15,
                                                                                                 'mod' => 'o',
                                                                                                 'ldelim' => '/'
                                                                                               }, 'Parse::RecDescent::Token' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => -14,
                                                                                                 'code' => '{ new_relation(\'user-defined\',{label => $item[1]}) }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => -15
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'RELATION',
                                                     'vars' => '',
                                                     'line' => -20
                                                   }, 'Parse::RecDescent::Rule' ),
                              'NUMBER' => bless( {
                                                   'impcount' => 0,
                                                   'calls' => [],
                                                   'changed' => 0,
                                                   'opcount' => 0,
                                                   'prods' => [
                                                                bless( {
                                                                         'number' => '0',
                                                                         'strcount' => 0,
                                                                         'dircount' => 0,
                                                                         'uncommit' => undef,
                                                                         'error' => undef,
                                                                         'patcount' => 1,
                                                                         'actcount' => 0,
                                                                         'items' => [
                                                                                      bless( {
                                                                                               'pattern' => '-?[0-9]+(\\.[0-9]+)?',
                                                                                               'hashname' => '__PATTERN1__',
                                                                                               'description' => '/-?[0-9]+(\\\\.[0-9]+)?/',
                                                                                               'lookahead' => 0,
                                                                                               'rdelim' => '/',
                                                                                               'line' => -2,
                                                                                               'mod' => '',
                                                                                               'ldelim' => '/'
                                                                                             }, 'Parse::RecDescent::Token' )
                                                                                    ],
                                                                         'line' => undef
                                                                       }, 'Parse::RecDescent::Production' )
                                                              ],
                                                   'name' => 'NUMBER',
                                                   'vars' => '',
                                                   'line' => -2
                                                 }, 'Parse::RecDescent::Rule' ),
                              'parse_query' => bless( {
                                                        'impcount' => 0,
                                                        'calls' => [
                                                                     'node',
                                                                     '_alternation_1_of_production_1_of_rule_parse_query'
                                                                   ],
                                                        'changed' => 0,
                                                        'opcount' => 0,
                                                        'prods' => [
                                                                     bless( {
                                                                              'number' => '0',
                                                                              'strcount' => 1,
                                                                              'dircount' => 1,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 1,
                                                                              'actcount' => 1,
                                                                              'op' => [],
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'expected' => '<leftop: node \';\' node>',
                                                                                                    'min' => 1,
                                                                                                    'name' => '',
                                                                                                    'max' => 100000000,
                                                                                                    'leftarg' => bless( {
                                                                                                                          'subrule' => 'node',
                                                                                                                          'matchrule' => 0,
                                                                                                                          'implicit' => undef,
                                                                                                                          'argcode' => undef,
                                                                                                                          'lookahead' => 0,
                                                                                                                          'line' => 57
                                                                                                                        }, 'Parse::RecDescent::Subrule' ),
                                                                                                    'rightarg' => bless( {
                                                                                                                           'subrule' => 'node',
                                                                                                                           'matchrule' => 0,
                                                                                                                           'implicit' => undef,
                                                                                                                           'argcode' => undef,
                                                                                                                           'lookahead' => 0,
                                                                                                                           'line' => 57
                                                                                                                         }, 'Parse::RecDescent::Subrule' ),
                                                                                                    'hashname' => '__DIRECTIVE1__',
                                                                                                    'type' => 'leftop',
                                                                                                    'op' => bless( {
                                                                                                                     'pattern' => ';',
                                                                                                                     'hashname' => '__STRING1__',
                                                                                                                     'description' => '\';\'',
                                                                                                                     'lookahead' => 0,
                                                                                                                     'line' => 57
                                                                                                                   }, 'Parse::RecDescent::Literal' )
                                                                                                  }, 'Parse::RecDescent::Operator' ),
                                                                                           bless( {
                                                                                                    'subrule' => '_alternation_1_of_production_1_of_rule_parse_query',
                                                                                                    'expected' => '\';\'',
                                                                                                    'min' => 0,
                                                                                                    'argcode' => undef,
                                                                                                    'max' => 1,
                                                                                                    'matchrule' => 0,
                                                                                                    'repspec' => '?',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -137
                                                                                                  }, 'Parse::RecDescent::Repetition' ),
                                                                                           bless( {
                                                                                                    'pattern' => '\\Z',
                                                                                                    'hashname' => '__PATTERN1__',
                                                                                                    'description' => '/\\\\Z/',
                                                                                                    'lookahead' => 0,
                                                                                                    'rdelim' => '/',
                                                                                                    'line' => -137,
                                                                                                    'mod' => '',
                                                                                                    'ldelim' => '/'
                                                                                                  }, 'Parse::RecDescent::Token' ),
                                                                                           bless( {
                                                                                                    'hashname' => '__ACTION1__',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -136,
                                                                                                    'code' => '{ $return=new_node({},$item[1]); 1 }'
                                                                                                  }, 'Parse::RecDescent::Action' )
                                                                                         ],
                                                                              'line' => undef
                                                                            }, 'Parse::RecDescent::Production' ),
                                                                     bless( {
                                                                              'number' => '1',
                                                                              'strcount' => 0,
                                                                              'dircount' => 0,
                                                                              'uncommit' => undef,
                                                                              'error' => undef,
                                                                              'patcount' => 0,
                                                                              'actcount' => 1,
                                                                              'items' => [
                                                                                           bless( {
                                                                                                    'hashname' => '__ACTION1__',
                                                                                                    'lookahead' => 0,
                                                                                                    'line' => -135,
                                                                                                    'code' => '{ report_error($thisparser); }'
                                                                                                  }, 'Parse::RecDescent::Action' )
                                                                                         ],
                                                                              'line' => -135
                                                                            }, 'Parse::RecDescent::Production' )
                                                                   ],
                                                        'name' => 'parse_query',
                                                        'vars' => '',
                                                        'line' => 57
                                                      }, 'Parse::RecDescent::Rule' ),
                              'or_clause' => bless( {
                                                      'impcount' => 0,
                                                      'calls' => [
                                                                   'test'
                                                                 ],
                                                      'changed' => 0,
                                                      'opcount' => 0,
                                                      'prods' => [
                                                                   bless( {
                                                                            'number' => '0',
                                                                            'strcount' => 3,
                                                                            'dircount' => 1,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'op' => [],
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'pattern' => '(',
                                                                                                  'hashname' => '__STRING1__',
                                                                                                  'description' => '\'(\'',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -89
                                                                                                }, 'Parse::RecDescent::Literal' ),
                                                                                         bless( {
                                                                                                  'expected' => '<leftop: test \'or\' test>',
                                                                                                  'min' => 1,
                                                                                                  'name' => '',
                                                                                                  'max' => 100000000,
                                                                                                  'leftarg' => bless( {
                                                                                                                        'subrule' => 'test',
                                                                                                                        'matchrule' => 0,
                                                                                                                        'implicit' => undef,
                                                                                                                        'argcode' => undef,
                                                                                                                        'lookahead' => 0,
                                                                                                                        'line' => -89
                                                                                                                      }, 'Parse::RecDescent::Subrule' ),
                                                                                                  'rightarg' => bless( {
                                                                                                                         'subrule' => 'test',
                                                                                                                         'matchrule' => 0,
                                                                                                                         'implicit' => undef,
                                                                                                                         'argcode' => undef,
                                                                                                                         'lookahead' => 0,
                                                                                                                         'line' => -89
                                                                                                                       }, 'Parse::RecDescent::Subrule' ),
                                                                                                  'hashname' => '__DIRECTIVE1__',
                                                                                                  'type' => 'leftop',
                                                                                                  'op' => bless( {
                                                                                                                   'pattern' => 'or',
                                                                                                                   'hashname' => '__STRING2__',
                                                                                                                   'description' => '\'or\'',
                                                                                                                   'lookahead' => 0,
                                                                                                                   'line' => -89
                                                                                                                 }, 'Parse::RecDescent::Literal' )
                                                                                                }, 'Parse::RecDescent::Operator' ),
                                                                                         bless( {
                                                                                                  'pattern' => ')',
                                                                                                  'hashname' => '__STRING3__',
                                                                                                  'description' => '\')\'',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -89
                                                                                                }, 'Parse::RecDescent::Literal' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -88,
                                                                                                  'code' => '{ new_node({ \'#name\' => \'or\' }, $item[2]) }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => undef
                                                                          }, 'Parse::RecDescent::Production' )
                                                                 ],
                                                      'name' => 'or_clause',
                                                      'vars' => '',
                                                      'line' => -89
                                                    }, 'Parse::RecDescent::Rule' ),
                              'child' => bless( {
                                                  'impcount' => 0,
                                                  'calls' => [
                                                               'RELATION',
                                                               'node'
                                                             ],
                                                  'changed' => 0,
                                                  'opcount' => 0,
                                                  'prods' => [
                                                               bless( {
                                                                        'number' => '0',
                                                                        'strcount' => 0,
                                                                        'dircount' => 0,
                                                                        'uncommit' => undef,
                                                                        'error' => undef,
                                                                        'patcount' => 0,
                                                                        'actcount' => 1,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'subrule' => 'RELATION',
                                                                                              'expected' => undef,
                                                                                              'min' => 0,
                                                                                              'argcode' => undef,
                                                                                              'max' => 1,
                                                                                              'matchrule' => 0,
                                                                                              'repspec' => '?',
                                                                                              'lookahead' => 0,
                                                                                              'line' => -104
                                                                                            }, 'Parse::RecDescent::Repetition' ),
                                                                                     bless( {
                                                                                              'subrule' => 'node',
                                                                                              'matchrule' => 0,
                                                                                              'implicit' => undef,
                                                                                              'argcode' => undef,
                                                                                              'lookahead' => 0,
                                                                                              'line' => -104
                                                                                            }, 'Parse::RecDescent::Subrule' ),
                                                                                     bless( {
                                                                                              'hashname' => '__ACTION1__',
                                                                                              'lookahead' => 0,
                                                                                              'line' => -104,
                                                                                              'code' => '{ $return = $item[2]; $return->{relation}=$item[1][0]; 1 }'
                                                                                            }, 'Parse::RecDescent::Action' )
                                                                                   ],
                                                                        'line' => undef
                                                                      }, 'Parse::RecDescent::Production' )
                                                             ],
                                                  'name' => 'child',
                                                  'vars' => '',
                                                  'line' => -104
                                                }, 'Parse::RecDescent::Rule' ),
                              'condition' => bless( {
                                                      'impcount' => 0,
                                                      'calls' => [
                                                                   'simple_test',
                                                                   'opt_child',
                                                                   'subquery',
                                                                   'child',
                                                                   'ref'
                                                                 ],
                                                      'changed' => 0,
                                                      'opcount' => 0,
                                                      'prods' => [
                                                                   bless( {
                                                                            'number' => '0',
                                                                            'strcount' => 0,
                                                                            'dircount' => 0,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'simple_test',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -110
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -110,
                                                                                                  'code' => '{ $return = $item[1] }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => undef
                                                                          }, 'Parse::RecDescent::Production' ),
                                                                   bless( {
                                                                            'number' => '1',
                                                                            'strcount' => 0,
                                                                            'dircount' => 0,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'opt_child',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -109
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -109,
                                                                                                  'code' => '{ $return = $item[1] }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => -109
                                                                          }, 'Parse::RecDescent::Production' ),
                                                                   bless( {
                                                                            'number' => '2',
                                                                            'strcount' => 0,
                                                                            'dircount' => 0,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'subquery',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -108
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -108,
                                                                                                  'code' => '{ $return = $item[1] }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => -108
                                                                          }, 'Parse::RecDescent::Production' ),
                                                                   bless( {
                                                                            'number' => '3',
                                                                            'strcount' => 0,
                                                                            'dircount' => 0,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'child',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -107
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -107,
                                                                                                  'code' => '{ $return = $item[1] }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => -107
                                                                          }, 'Parse::RecDescent::Production' ),
                                                                   bless( {
                                                                            'number' => '4',
                                                                            'strcount' => 0,
                                                                            'dircount' => 0,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 0,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'ref',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => -106
                                                                                                }, 'Parse::RecDescent::Subrule' )
                                                                                       ],
                                                                            'line' => -106
                                                                          }, 'Parse::RecDescent::Production' )
                                                                 ],
                                                      'name' => 'condition',
                                                      'vars' => '',
                                                      'line' => -110
                                                    }, 'Parse::RecDescent::Rule' )
                            }
               }, 'Parse::RecDescent' );
}