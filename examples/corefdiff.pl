#!/usr/bin/perl

use strict;
use Getopt::Std;
use vars qw($opt_v $opt_V $opt_h $opt_D $opt_r $opt_n $opt_t);
getopts('rvVhD');

$opt_v ||= $opt_V;

my @files;
if ($^O eq 'MSWin32') {
  @files=map glob, @ARGV;
} else {
  @files = @ARGV;
}

if ($opt_h || !@files) {
  print <<EOL;
  Find differences in correference annotation of two given fs-files

  Usage: corefdiff.pl file1, file2, ...

  -n print total number of differences for each node
  -t print total number of differences for each tree
  -r detailed report (show also trlemma+func+ord)
  -v verbose
  -V extra verbose
  -D turn Fslib debugging messages ON

  -h print this help

EOL
}

use FindBin;
my $libDir;
my $rb=$FindBin::RealBin;
if (exists $ENV{TREDHOME}) {
  $libDir=$ENV{TREDHOME};
} elsif (-d "$rb/tredlib") {
  $libDir="$rb/tredlib";
} elsif (-d "$rb/../lib/tredlib") {
  $libDir="$rb/../lib/tredlib";
} elsif (-d "$rb/../lib/tred") {
  $libDir="$rb/../lib/tred";
}
print STDERR "Trying $libDir\n" if ($libDir and $opt_V);
unshift @INC,"$libDir";

use Fslib;

my @backends=('FSBackend',ImportBackends(qw(TrXMLBackend CSTS_SGML_SP_Backend)));
$CSTS_SGML_SP_Backend::doctype = "$libDir/csts.doctype";
$Fslib::Debug=$opt_D;

my @fs;
my $filecount=scalar(@files);
my $fileno;
my $differences=0;
my $total_nodes=0;
my $diffs_in_node=0;
my $diffs_in_tree=0;

foreach my $f (@files) {
  $fileno++;
  print STDERR "Reading $f\t($fileno/$filecount)\n" if $opt_v;

  my $fs = FSFile->newFSFile($f,'iso-8859-2',@backends);

  $fs->lastTreeNo<0 && die "$f: empty or corrupt file!\n";
  push @fs,$fs;
}

print STDERR "Checking tree counts...\n" if $opt_v;
my $last_tree=check_tree_counts(\@fs);
print STDERR "Collecting nodes...\n" if $opt_v;
my %n;
foreach my $f (@fs) {
  $n{$f->filename} = get_nodes($f);
}

for (my $tree_no; $tree_no<=$last_tree; $tree_no++) {
  print STDERR "Comparing tree ##".($tree_no+1)."\n" if $opt_v;
  $diffs_in_tree=0;
  my $node=$fs[0]->tree($tree_no)->following_visible($fs[0]->FS);
  my $id;
  while ($node) {
    $diffs_in_node=0;
    $total_nodes++;
    $id=get_ID($node);
    print STDERR "Comparing node $id\n" if $opt_V;
    check_nodes($id,\%n);
    print STDERR "Ok, node ID's match with other attributes.\n" if $opt_V;
    my %corefs;
    foreach my $f (@fs) {
      foreach (get_corefs($n{$f->filename}{$id})) {
	print STDERR "Node ".$f->filename."#[id=$id]: coref $_\n" if $opt_v;
	if (! exists($corefs{$_}) ) {
	  $corefs{$_} = [$f->filename];
	} else {
	  push @{$corefs{$_}}, $f->filename;
	}
      }
    }

    foreach (keys(%corefs)) {
      print STDERR "Checking coref $_\n" if $opt_V;
      my @corefs=@{$corefs{$_}};
      if (@corefs < @fs) {
	print "##".($tree_no+1)." ".report_node($n{$fs[0]->filename()}{$id}).
	  ": coreference ";
	do {
	  my $c=$_;
	  $c=~s/^(?:[^.]*)\.//; # get rid of the prefix
	  print report_node($n{$fs[0]->filename()}{$c});
	};
	print " only in: ", join(" ",@corefs),"\n";
	$differences++;
	$diffs_in_tree++;
	$diffs_in_node++;
      }
    }
    print "$diffs_in_node ".differences($diffs_in_node)." in node ".report_node($n{$fs[0]->filename()}{$id})."\n\n"
          if ($diffs_in_node and $opt_n);
    $node=$node->following_visible($fs[0]->FS);
  }
  print "$diffs_in_tree ".differences($diffs_in_tree)." in tree ##".($tree_no+1)."\n\n"
    if ($diffs_in_tree and $opt_t);
}

print "\n$differences ".differences($differences)." in $total_nodes nodes\n";

sub check_nodes {
  my ($id,$n)=@_;
  my %values;
  my @files=keys %$n;
  foreach my $file (@files) {
    foreach (qw(trlemma func ord)) {
      if (exists($values{$_})) {
	if ($values{$_} ne $n->{$file}{$id}->{$_}) {
	  print STDERR "Error: nodes id=$id from $file and $files[0] differ in $_\n";
	  print STDERR "Aborting!\n";
	  exit 1;
	}
      } else {
	$values{$_} = $n->{$file}{$id}->{$_};
      }
    }
  }
}

sub get_corefs {
  my ($node)=@_;
  my @coref=split /\|/,$node->{coref};
  my @cortype=split /\|/,$node->{cortype};
  return map { $cortype[$_].'.'.$coref[$_] } 0..$#coref;
}

sub get_ID {
  my ($node)=@_;
  return $node->{AID} ne "" ? $node->{AID} : $node->{TID};
}

sub get_nodes {
  my ($f)=@_;
  my %nodes;
  my $id;

  for (my $treeno; $treeno<=$f->lastTreeNo(); $treeno++) {
    my $node=$f->tree($treeno)->following_visible($f->FS);
    while ($node) {
      $id=get_ID($node);
      if ($id eq "") {
	# ERROR
	my $msg="found node without ID: ".$f->filename."##".($treeno+1);
	foreach (qw(ord trlemma func)) {
	  $msg.=" $_=".$node->{$_};
	}
	print STDERR "$msg\n";
	print STDERR "Aborting!\n";
	exit 1;
      } elsif (exists($nodes{$id})) {
	print "Error: Duplicate ID $id in ",$f->filename,"\n";
	print STDERR "Aborting!\n";
	exit 1;
      }else {
	$nodes{$id}=$node;
      }
      $node=$node->following_visible($f->FS);
    }
  }
  return \%nodes;
}

sub check_tree_counts {
  my ($fsfiles)=@_;
  my $lasttree;
  foreach my $f (@$fsfiles) {
    if (defined($lasttree)) {
      unless ($lasttree == $f->lastTreeNo()) {
	print STDERR "Different number of sentences in the input files!\n";
	print STDERR "Aborting!\n";
	exit 1;
      }
    } else {
      $lasttree = $f->lastTreeNo();
    }
  }

  for (my $i=0; $i<=$lasttree; $i++) {
    my $count=undef;
    foreach my $f (@$fsfiles) {
      if (defined($count)) {
	unless ($count == count_nodes($f,$i)) {
	  print STDERR "Different number of visible nodes in sentence no. ##".($i+1)."!\n";
	  print STDERR "Aborting!\n";
	  exit 1;
	}
      } else {
	$count = count_nodes($f,$i);
      }
    }
  }
  return $lasttree;
}

sub count_nodes {
  my ($f,$treeno)=@_;
  my $node=$f->tree($treeno);
  my $i=0;
  while ($node) {
    $i++;
    $node=$node->following_visible($f->FS);
  }
}

sub report_node {
  my ($node)=@_;
  if ($opt_r) {
    return get_ID($node)." ($node->{trlemma}.$node->{func}.$node->{ord})";
  } else {
    return get_ID($node);
  }
}

sub differences {
  return 'difference'.($_[0]>1 ? 's' : '');
}
