#!/usr/bin/perl
# $Id: changelog2rss.pl,v 1.6 2004/10/29 08:31:03 misc Exp $
#
# TODO
#  - real config file
#  - add some logging and debug stuff
#  - do something with summary
# based on code from pascal terjan ( mainly all rss stuff )

$config{RSS_TITLE}="TrEd ChangeLog";
$config{RSS_LINK}="http://pajas.matfyz.cz/tred";
$config{MAX_SIZE}=50;
$config{MAX_TITLE_LENGTH}=60;
#$config{RSS_FILE}="/home/pajas/WWW/tred/changelog.rss";
$config{RSS_DESCRIPTION}="Tree Editor - TrEd";
$config{RSS_COPYRIGHT}="Copyright 2005, Petr Pajas";
$config{DEFAULT_URL}="http://pajas.matfyz.cz/tred";

# $config{LOCK}="$ENV{HOME}/tmp/lock.rss";
# $config{LOCK_TIMEOUT}=60;

#$config{MESSAGE_TITLE}='';
#$config{MESSAGE_DESC}='I ploped';

$url = $config{DEFAULT_URL} if not $url;

use XML::RSS;
use CGI;


my $counter=0;
# while ( -f $config{LOCK} and $counter < $config{LOCK_TIMEOUT} ) { sleep 1; $counter++; };

# die "Cannot grab lock " if -f $config{LOCK};

# `touch $config{LOCK}`;


my $rss = new XML::RSS(version=>'2.0', encoding=>"UTF-8");
$pubdate = `date -R`;
chomp $pubdate;
$rss->channel(
	      title        => $config{RSS_TITLE},
	      link         => $config{RSS_LINK},
	      language     => "en",
	      description  => $config{RSS_DESCRIPTION},
	      copyright    => $config{RSS_COPYRIGHT},
	      #pubDate      => $pubdate,
	      lastBuildDate      => $pubdate,
	      strict => 1
	     );

my $cgi = new CGI;
use Data::Dumper;
$items = 0;

sub get_title {
  my ($desc)=@_;
  return $cgi->escapeHTML((length($desc)>$config{MAX_TITLE_LENGTH} ?
			   substr($desc,0,$config{MAX_TITLE_LENGTH})."..." : $desc));
}

my $guid;


while (<>) {
  if (/^(\d+:\d+:\d+) (\d+-\d+-\d+)\s+([^\<]*?)\s+\<|^(\d+-\d+-\d+)\s+(\d+:\d+)(?: \+\d\d\d\d)?(?: (\[.*?\]))?\s+(.*)/) {
    $items ++;

    $rev = $6;
    $author = $cgi->escapeHTML($3 || $7);
    {
      my $time = $1 || $5;
      my $date = $2 || $4;

      # print STDERR "Match: $author rev: $rev, time: $time, date: $date\n";

      my @time = split /:/, $time;
      my @date = split /-/, $date;

      use Time::Local;
      use POSIX qw(strftime setlocale LC_TIME);
      setlocale(LC_TIME,'C');
      $pubdate = $cgi->escapeHTML(
        strftime("%a, %d %b %Y %H:%M:%S %z",
				  gmtime(timegm(@time[2,1,0],$date[2],$date[1]-1,$date[0]))));
      $guid =  strftime("change_%y%m%d_%H%M%S",
			gmtime(timegm(@time[2,1,0],$date[2],$date[1]-1,$date[0])));
    }

    if ($item) {
      $rss->add_item(%$item);
      #print STDERR Dumper($item);
      undef $item;
    }
    last if ($items > $config{MAX_SIZE});
  } elsif (/^\t\*(?: (\[.*?\]) )?([^:]*)(?::\s+(.*))?$/) {

    if ($item) {
      $rss->add_item(%$item);
      #print STDERR Dumper($item);
    }
    $rev=$1 if $1;
    my $files = $2;
    my $desc = $3;
    while (!defined($desc) and $_=<> and $_=~m/^\t([^:]*)(?::\s+(.*))?$/) {
      $files.=$1;
      $desc = $2;
    }

    # print STDERR "REV: $rev\n  Files: $files\n  Desc: $desc\n";

    $files = $cgi->escapeHTML($files);

    my $title = get_title($desc);
    $desc = $cgi->escapeHTML($desc);

    print STDERR "Guid: $guid ($pubdate)\n";
    $item = {
	     title => $title,
             guid => $guid,
	     creator  => $author,
	     pubDate => $pubdate,
	     description => ($rev ? <<"EOF" : "") .
<b>Revision: </b> $rev<br /><br />
EOF
<<"EOF",
<b>Files:</b> $files<br /><br />
<b>Change description:</b><br />
$desc
EOF
	    }
  } elsif  (/^\t(.*)/) {
    if ($item) {
      my $desc = $1;
      $item->{title} = get_title($1) unless ($item->{title}=~/\S/);
      $item->{description} .= "<br />\n".$cgi->escapeHTML($desc);
    }
  } elsif (/\S/) {
     print STDERR "IGNORING: $_\n";
  }
}

if ($item) {
  $rss->add_item(%$item);
  #print STDERR Dumper($item);
}

if ($config{RSS_FILE}) {
  unlink $config{RSS_FILE};
  $rss->save($config{RSS_FILE});
  # unlink($config{LOCK});
} else {
  print $rss->as_string();
}
