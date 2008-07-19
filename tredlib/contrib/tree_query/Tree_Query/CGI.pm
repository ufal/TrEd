package Tree_Query::CGI;

use strict;
use warnings;
use Fslib;
use PMLInstance;
use PMLSchema;
use Encode;
use Tree_Query::Common ':tredmacro';
use Tree_Query::SQLEvaluator;

my $conf;
{
  my %opts;
  $opts{'config-file'} ||= Fslib::FindInResources('treebase.conf');
  if ($opts{debug}) {
    print STDERR "Reading configuration from $opts{'config-file'}\n";
  }
  my $configs = PMLInstance->load({ filename=>$opts{'config-file'} })->get_root->{configurations};
  my $id = $opts{'server'} || 'base';
  $conf = first { $_->{id} eq $id } map $_->value, grep $_->name eq 'dbi', SeqV($configs);
  die "Didn't find server configuration named '$id'!\nUse $0 --list-servers and then $0 --server <name>\n"
    unless $conf;
}

sub _query_form {
  my $cgi  = shift;		# CGI.pm object
  return (
    $cgi->start_form(-method => 'POST',
		     -action => '/query'),
    $cgi->textarea(-name => 'query',
		   -default => "t-node [ ];>> count()\n",
		   -rows => 10,
		   -columns => 80,
		  ),
    $cgi->br,
    $cgi->submit(),
    $cgi->endform(),
   )
}
{
  my $evaluator;
  sub init_evaluator {
    $evaluator = Tree_Query::SQLEvaluator->new(undef,{connect => $conf});
    $evaluator->connect();
    return $evaluator;
  }
}

sub search {
  my ($query,%opts)=@_;
  my $evaluator = init_evaluator();
  my $results;
  #   if ($opts{'netgraph-query'}) {
  #     $query=ng2pmltq($query); TODO
  #   }
  eval {
    $evaluator->prepare_query($query); # count=>1
    $results = $evaluator->run({
      node_limit => $opts{-limit},
      row_limit => $opts{-limit},
      timeout => $opts{-timeout},
      timeout_callback => sub {
	die "Evaluation of query timed out\n";
      },
    });
  };
  my $err = $@;
  if ($err) {
    $err =~ s/\bat \S+ line \d+.*//s;
    return "$err";
  } else {
    return ($results,$evaluator->{returns_nodes});
  }
}


sub resp_form {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  print(
    $cgi->header(-charset=>'utf-8'),
    $cgi->start_html("PML-TQ Query Form"),
    $cgi->h1("PML-TQ Query Engine"),
    _query_form($cgi),
    $cgi->end_html
   );
  return 200;
}

sub resp_query {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  my $query = $cgi->param('query');
  return resp_form($cgi) unless defined($query) and length($query);
  my ($format,$limit,$timeout) = map $cgi->param($_), qw(format limit timeout);
  $format = 'html' unless (defined($format) and length($format));
  $limit = 100 unless (defined($limit) and length($limit));
  $limit=int($limit);
  $timeout = 30 unless (defined($timeout) and length($timeout));
  $timeout=int($timeout);
  $timeout = 300 if $timeout>300;
  if ($format eq 'html') {
    my ($results,$returns_nodes) = search($query,
					  -limit => $limit,
					  -timeout => $timeout
					 );
    my $server_url = $cgi->url(-base=>1);
    print(
      $cgi->header(-charset=>'utf-8'),
      $cgi->start_html("PML-TQ Query Form"),
      $cgi->h1("PML-TQ Query Engine"),
      _query_form($cgi),
      $cgi->hr()
     );
    if (ref($results) eq 'ARRAY') {
      print $cgi->h2(scalar(@$results)." RESULTS (limit set to $limit)");
      print $cgi->table({-border => undef},
			$cgi->Tr({-align => 'LEFT', -valign => 'TOP'},
				 $returns_nodes
				   ? [ map {
				     my $r=$_;
				     $cgi->td([map $cgi->a({href=>"$server_url/node?type=$r->[2*$_+1]&idx=$r->[2*$_]"}, $r->[2*$_+1].'/'.$r->[2*$_]),
					       0..(@$_/2-1)]) } @$results ]
				     : [ map { $cgi->td($_) } @$results ]
				    )
		       );
    } else {
      print( $cgi->h2("ERROR"), $cgi->font({-size => -1}, $cgi->pre($results)));
    }
    print($cgi->end_html);
  } elsif ($format eq 'text') {
    my ($results,$returns_nodes) = search($query);
    if (ref($results) eq 'ARRAY') {
      print $cgi->header(-type=>'text/plain',
			 -charset=>'utf-8',
			 -pmltq_returns_nodes => $returns_nodes,
			);
      for (@$results) {
	print join("\t",map {
	  Encode::_utf8_off($_);
	  $_
	} @$_)."\n";
      }
    } else {
      print $results;
      return 500;
    }
  } else {
    resp_error($cgi,"Wrong format requested!\n");
    return 500;
  }
  return 200;
}
sub resp_error {
  my ($cgi,$msg)=@_;
  return 500 if !ref $cgi;
  print(
    $cgi->header(-charset=>'utf-8'),
    $msg
   );
  return 200;
}

sub _have_file {
  my ($f)=@_;
  my $evaluator = init_evaluator();
  my $schemas = $evaluator->run_sql_query(qq{SELECT "root" FROM "#PML"},{ RaiseError=>1 });
  for my $name (@$schemas) {
    my $n = $name->[0].'__#files';
    next if $n=~/"/;		# just for sure
    my $count = $evaluator->run_sql_query(qq{SELECT count(1) FROM "$n" WHERE "file"=?},
					  {
					    RaiseError=>1, Bind=>[ $f ] }
					 );
    return 1 if $count->[0][0];
  }
  return 0;
}

sub resp_file {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  my $f = $cgi->param('f');
  if ((-r $f) and _have_file($f) and open(my $fh, '<:bytes',$f)) {
    my $mimetype='application/octet-stream';
    my $content_length = (stat($f))[7];
    # print "HTTP/1.1 200 OK\015\012";
    print 'Content-type: ' . $mimetype . "\015\012";
    print 'Content-length: ' . $content_length . "\015\012\015\012";
    my $buffer;
    print $buffer while read $fh, $buffer, 16*1024;
    return 200;
  } else {
    resp_error($cgi,"Object not found!");
    return 404;
  }
}
sub resp_node {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  my ($idx,$type,$format) = map $cgi->param($_), qw(idx type format);
  my $evaluator = init_evaluator();
  my ($f) = eval { $evaluator->idx_to_pos([$idx,$type]) };
  Encode::_utf8_off($f);
  $format = 'html' unless (defined($format) and length($format));
  if ($f) {
    if ($format eq 'text') {
      print($cgi->header(-type=>'text/plain',
			 -charset=>'utf-8'),
	    $f."\r\n");
    } else {
      my $server_url = $cgi->url(-base=>1);
      print $cgi->header(-charset=>'utf-8'),
	$cgi->start_html("Type"),
	  $cgi->a({href=>$server_url.'/file?f='.$f},"$type/$idx");
      $cgi->end_html();
    }
    return 200;
  } else {
    # resp_error($cgi,"Error resolving $type $idx: $@");
    return 404;
  }
}

sub resp_schema {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  my $name = $cgi->param('name');
  my $evaluator = init_evaluator();
  my $results = $evaluator->run_sql_query(qq(SELECT "schema" FROM "#PML" WHERE "root" = ? ),
					  {
					    MaxRows=>1, RaiseError=>1, LongReadLen=> 512*1024, Bind=>[$name] });
  my $mimetype='application/octet-stream';
  if (ref($results) and ref($results->[0]) and $results->[0][0]) {
    Encode::_utf8_off($results->[0][0]);
    my $content_length = length($results->[0][0]);
    print 'Content-type: ' . $mimetype . "\015\012";
    print 'Content-length: ' . $content_length . "\015\012\015\012";
    print $results->[0][0];
    return 200;
  } else {
    print 'Content-type: ' . $mimetype . "\015\012";
    print "Content-length: 0\015\012\015\012";
    return 404;
  }
}
sub resp_type {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  my $type = $cgi->param('type');
  my $format = $cgi->param('format');
  my $evaluator = init_evaluator();
  my $name = eval { $evaluator->get_schema_name_for($type) };
  $name ||= '';
  Encode::_utf8_off($name);
  if ($format eq 'text') {
    print($cgi->header(-type=>'text/plain',
		       -charset=>'utf-8'),
	  $name."\r\n");
  } else {
    print
      $cgi->header(-charset=>'utf-8'),
	$cgi->start_html("Type"),
	  $name,
	    $cgi->end_html();
  }
  return 200;
}
sub resp_nodetypes {
  my $cgi  = shift;		# CGI.pm object
  return 500 if !ref $cgi;
  my $format = $cgi->param('format') || 'html';
  my $evaluator = init_evaluator();
  my $types = $evaluator->get_node_types();
  Encode::_utf8_off($_) for @$types;
  if ($format eq 'text') {
    print($cgi->header(-type=>'text/plain',
		       -charset=>'utf-8'),
	  map "$_\r\n", @$types);
  } else {
    print
      $cgi->header(-charset=>'utf-8'),
      $cgi->start_html("Node Types"),
	$cgi->table({-border => undef},
		      $cgi->Tr({-align => 'LEFT', -valign => 'TOP'},
			       [ map $cgi->td($_), @$types ])),
	    $cgi->end_html();
  }
  return 200;
}


1;
__END__
