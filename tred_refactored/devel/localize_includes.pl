#!/usr/bin/perl

my @files = @ARGV || <>;

my %files;
foreach  my $file (@files) {
  chomp $file;
  $file=~s{^\./}{};
  my ($base)= $file=~m{([^/]+)$};
  next if $base eq "";
  if (exists($files{$base})) {
    # duplicite key: mark as not to be used
    $files{$base}=undef;
  } else {
    $files{$base}=$file;
  }
}

foreach my $file (@files) {
  chomp $file;
  my ($dir)= $file=~m{^(.*/)};
#  print "Probing $file in $dir\n";

  open my $f, $file;
  binmode $f;
  my @code = <$f>;
  close $f;
  @changes=();
  my $line = 1;
  foreach (@code) {
    if (/^# *(?:if)?include +<([^>]+)>/) {
      my $inc = $1;
      next if $inc eq 'tred.mac';
      $inc=~s{^contrib/(\Q$dir\E)?}{};
      unless (-f $inc) {
	my $try=$dir.$inc;
	if (-f $try) {
#	  print "Found $inc as $try\n";
	  s/^(# *(?:if)?include +)<([^>]+)>/$1"$inc"/;
	  push @changes,$line;
	} elsif($files{$inc} ne "") {
	  s{^(# *(?:if)?include +)<([^>]+)>}{$1<contrib/$files{$inc}>};
	  print "$file:$line: Fuzzy match of $inc as $files{$inc}\n";
	  push @changes,$line;
	} elsif($inc=~m{/([^/]+)$} and $files{$1} ne "") {
	  my $b=$1;
	  s{^(# *(?:if)?include +)<([^>]+)>}{$1<contrib/$files{$b}>};
	  print "$file:$line: Possible match of $inc as $files{$b}\n";
	  push @changes,$line;
	} else {
	  print "$file:$line: Didn't find $inc as $try\n";
	}
      } else {
	print "OK: $inc for $file ($dir)\n";
      }
    }
  } continue {
    $line ++;
  };
  if (@changes) {
    print "Modifying file $file\n";
    foreach (@changes) {
      print $code[$_-1];
    }
    open my $f, ">",$file;
    binmode $f;
    print $f @code;
    close $f;
  }
}
