package Tk::BindMouseWheel;

# This module actually only adds features to Tk::Widget

sub Tk::Widget::BindMouseWheelVert {
    my($w,$modifier,@tags)= @_;
    $modifier.="-" if ($modifier);
    $w->bind($tags,"<$modifier"."MouseWheel>",
              [ sub { 
		  $_[1]->yview('scroll',-($_[2]/120)*3,'units') 
		}, $w, Tk::Ev("D")
	      ]);
    if ($Tk::platform eq 'unix') {
        $w->bind(@tags,"<$modifier"."4>",
		 [sub {
		    $_[1]->yview('scroll',-3,'units')
		      unless $Tk::strictMotif;
		  },$w]);
        $w->bind(@tags,"<$modifier"."5>",
		 [sub {
		    $_[1]->yview('scroll', 3, 'units')
		      unless $Tk::strictMotif;
		  },$w]);
    }
}

sub Tk::Widget::BindMouseWheelHoriz {
    my($w,$modifier)= @_;
    $modifier.="-" if ($modifier);
    $w->bind("<$modifier"."MouseWheel>",
              [ sub { $_[0]->xview('scroll',-($_[1]/120)*3,'units') }, Tk::Ev("D")]);
    if ($Tk::platform eq 'unix') {
        $w->bind("<$modifier"."4>", sub { $_[0]->xview('scroll', -3, 'units')
				      unless $Tk::strictMotif; });
        $w->bind("<$modifier"."5>", sub { $_[0]->xview('scroll', 3, 'units')
				      unless $Tk::strictMotif; });
    }
}

1;
