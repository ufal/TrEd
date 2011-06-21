package TrEd::Filelist::View;

use strict;
use warnings;

#TODO: nedat toto k dialog a tam to potom rozsekat na tie okienka?

# filelist, UI, sidepanel
sub update {
  my ($grp,$fl,$reload)=@_;
  return unless $fl;
  my $win = $grp->{focusedWindow};
  my $view = $grp->{sidePanel} && $grp->{sidePanel}->widget('filelistView');
  return unless ($view and $view->is_shown);
  my $filelistView=$view->data;
  if ($filelistView and ($win->{currentFilelist} == $fl)) {
    update_a_filelist_view($grp,$filelistView,$fl,$win->{currentFileNo},$reload);
  }
}

# filelist, UI
sub update_a_filelist_view {
  my ($grp,$fv,$fl,$pos,$reload)=@_;
  if ($fv->can('Subwidget') and $fv->Subwidget('scrolled')) {
    $fv = $fv->Subwidget('scrolled');
  }
  if ($reload) {
    $fl->expand();
    TrEd::Dialog::Filelist::feedHListWithFilelist($grp,$fv,$fl);
  }
#  if (defined($fl->current)) {
#    $pos=max2(0,$fl->position);
#  }
  $fv->selectionClear();
  if ($fv->{default_style_imagetext} and
      $fv->{last_focused} and $fv->info('exists',$fv->{last_focused})) {
    $fv->itemConfigure($fv->{last_focused}, 0, -style => $fv->{default_style_imagetext});
    $fv->{last_focused}=undef;
  }
  my $path=TrEd::ManageFilelists::filelistEntryPath($fl,$pos);
  if (defined($path) and length($path) and $fv->info('exists',$path)) {
    if ($fv->{focused_style_imagetext}) {
      $fv->itemConfigure($path, 0, -style => $fv->{focused_style_imagetext});
      $fv->{last_focused}=$path;
    }
    $fv->anchorSet($path);
    $fv->see($path);
    $fv->selectionSet($path);
  }
}



1;
