package TrEd::ManageFilelist;

use strict;
use warnings;

use Carp;

# filelist
sub filelistFullFileName {
  my ($win, $fn)=@_;
  my $filelist = $win->{currentFilelist};
  return unless ref $filelist;
  _filelistFullFileName($filelist, $filelist->file_at($fn));
}


#######################################################################################
# Usage         : _filelistFullFileName($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object 
#                 string $file_name   -- name of the file list
# Throws        : no exceptions
# Comments      : 
# See Also      : 
# filelist
sub _filelistFullFileName {
  my ($file_list, $file_name) = @_;
  if (not eval { $file_list->isa('Filelist') }) {
    carp 'argument file_list should be a Filelist object';
    return; 
  }
  my $suffix;
  ($file_name, $suffix) = TrEd::Utils::parse_file_suffix($file_name);
  my $full_filename = Treex::PML::ResolvePath($file_list->filename(), $file_name); 
  if (defined $suffix) {
    $full_filename .= $suffix;
  }  
  return $full_filename;
}

# filelist, file current
sub nextOrPrevFile {
  my ($grp_or_win,$delta,$no_recent,$real)=@_;
  my ($grp,$win) = main::grp_win($grp_or_win);
  return 0 if ($delta==0);
  my $op=$grp->{noOpenFileError};
  $grp->{noOpenFileError}=1;
  my $filename;
  my $pos = $win->{currentFileNo}+$delta;
  if ($real and $win->{FSFile}) {
    my $prev_filename= $win->{FSFile}->filename;
    my $f = $filename = filelistFullFileName($win,$pos);
    ($prev_filename) = TrEd::Utils::parse_file_suffix($prev_filename);
    ($f) = TrEd::Utils::parse_file_suffix($f);
    while (Treex::PML::IO::is_same_filename($f, $prev_filename)) {
      $pos+=$delta;
      $f=$filename=filelistFullFileName($win,$pos);
      ($f) = TrEd::Utils::parse_file_suffix($f);
    }
  } else {
    $filename=filelistFullFileName($win,$pos);
  }
  my $result=main::gotoFile($win,$pos,$no_recent);
  my $quiet=0;
  my $response;
  while (ref($result) and $result->{ok}==0) {
    my $trees = $win->{FSFile} ? $win->{FSFile}->lastTreeNo+1 : 0;
    unless ($quiet) {
      $response=
	$win->toplevel->ErrorReport(
	  -title => "Error: open failed",
	  -message => "File is unreadable, empty, corrupted, or does not exist ($trees trees read)!"."\nPossible problem was:",
	  -body => $grp->{lastOpenError},
	  -buttons => ["Try next","Skip broken files","Remove from filelist","Cancel"]
	 );
      last if ($response eq "Cancel");
      $quiet=1 if ($response eq "Skip broken files");
    }
    if ($response eq 'Remove from filelist') {
      my $f=filelistFullFileName($win,$pos);
      main::removeFromFilelist($win,undef,undef,$f);
      if ($delta>0) {
	if ($pos >= $win->{currentFilelist}->file_count()) {
	  $pos = $win->{currentFilelist}->file_count() - 1;
	} else {
	  $pos += $delta - 1;
	}
      } else {
	$pos += $delta;
      }
    } else {
      $pos += $delta;
    }
    $result=main::gotoFile($win,$pos,$no_recent);
  }
  $grp->{noOpenFileError}=$op;
  return ref($result) and $result->{ok};
}

# filelist, file current
sub nextRealFile {
  my ($grp_or_win,$no_recent)=@_;
  return nextOrPrevFile($grp_or_win,1,$no_recent,1);
}
# filelist, file current
sub prevRealFile {
  my ($grp_or_win,$no_recent)=@_;
  return nextOrPrevFile($grp_or_win,-1,$no_recent,1);
}
# filelist, file current
sub nextFile {
  my ($grp_or_win,$no_recent)=@_;
  return nextOrPrevFile($grp_or_win,1,$no_recent);
}
# filelist, file current
sub prevFile {
  my ($grp_or_win,$no_recent)=@_;
  return nextOrPrevFile($grp_or_win,-1,$no_recent);
}


1;
