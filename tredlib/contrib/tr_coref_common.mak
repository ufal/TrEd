## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2005-04-07 09:22:36 pajas>

#ifndef tr_coref_common
#define tr_coref_common

package Coref;

use base qw(TredMacro);
import TredMacro;

########################## Default patterns ##########################

#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  if ($grp->{FSFile}) {
    SetDisplayAttrs('mode:Coref',
		    '<? "#{red}" if $${commentA} ne "" ?>${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?><? " #{red}(\${corinfo})" if $${corinfo} =~/\S/ ?>',
                    '${func}<? "_#{custom2}\${reltype}\${memberof}" if "$${memberof}$${reltype}" =~ /CO|AP|PA/ ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>',
		    'text:<? "#{-foreground:green}#{-underline:1}" if $${NG_matching_node} eq "true" ?><? "#{-tag:NG_TOP}#{-tag:LEMMA_".$${trlemma}."}" if ($${NG_matching_node} eq "true" and $${NG_matching_edge} ne "true") ?>${origf}',
		    'style:<? "#{Line-fill:green}" if $${NG_matching_edge} eq "true" ?>',
		    'style:<? "#{Oval-fill:green}" if $${NG_matching_node} eq "true" ?>'
		   );

    SetBalloonPattern(<<'__BALLOON__');
ID:	  ${AID}${TID}
<?
  "fw:\t${fw}\n" if $${fw} ne ""
?>form:	  ${form}
gender:	  ${gender}
number:	  ${number}<?
  "\ncoref:\t  \${coref}" if $${coref} ne ""
?><?
  "\ncortype:\t  \${cortype}" if $${cortype} ne ""
?><?
  "\ncorlemma:  \${corlemma}" if $${corlemma} ne ""
?><?
  "\ncommentA:\t   \${commentA}" if $${commentA} ne ""
?>
__BALLOON__

  }
}

############################### Hooks ##################################

sub sort_attrs_hook {
  my ($ar)=@_;
  @$ar = ((grep {FS()->exists($_)}
	       'trlemma','func','form','coref','cortype','corlemma','gender','number',
	       'memberof','aspect','commentA','corinfo'),
	  sort {uc($a) cmp uc($b)}
	  grep(!/^(?:trlemma|func|form|coref|cortype|corlemma|corinfo|gender|number|commentA|memberof|aspect)$/,@$ar));
  return 1;
}

sub do_edit_attr_hook {
  Tectogrammatic::do_edit_attr_hook(@_);
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:trlemma|corlemma|corinfo|gender|number)$/) {
    return "stop";
  }
}

sub about_file_hook {
  my $msgref=shift;
  if ($root->{TR} and $root->{TR} ne 'hide') {
    $$msgref="Signed by $root->{TR}\n";
  }
}

sub status_line_doubleclick_hook { 
  # status-line field double clicked
  # there is also status_line_click_hook for single clicks

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
	Tectogrammatic::choose_frame();
	last;
      } else {
	if (main::doEditAttr($grp,$this,$1)) {
	  ChangingFile(1);
	}
	last;
      }
    }
  }
}

sub get_status_line_hook {
  # get_status_line_hook may either return a string
  # or a pair [ field-definitions, field-styles ]
  return [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
	   "form: " => [qw(label)],
	   $this->{form} => [qw({form} value)],
	   "     afun: " => [qw(label)],
	   $this->{afun} => [qw({afun} value)],
	   "     tag: " => [qw(label)],
	   $this->{tag} => [qw({tag} value)],
	   "     lemma: " => [qw(label)],
	   $this->{lemma} => [qw({lemma} value)],
	   ($this->{fw} ne "" ?
	    ("     fw: " => [qw(label)],
	     $this->{fw} => [qw({fw} value)]) : ()),
	   "     A/TID: " => [qw(label)],
	   $this->{AID} => [qw({AID} value)],
	   $this->{TID} => [qw({TID} value)],
	   "     AIDREFS: " => [qw(label)],
	   (join ", ",split /\|/,$this->{AIDREFS}) => [qw({AIDREFS} value)],
	   ($this->{framere} ne "" ?
	    ("     frame: " => [qw(label)],
	     $this->{framere} => [qw({FRAME} value)],
	     "     {".$this->{frameid}."}" => [qw({FRAME} value)],
	   ) : ()),
	   ($this->{commentA} ne "" ?
	    ("     [" => [qw()],
	     $this->{commentA} => [qw({commentA})],
	     "]" => [qw()]
	    ) : ())
	  ],

	  # field styles
	  [
	   "label" => [-foreground => 'black' ],
	   "value" => [-underline => 1 ],
	   "{commentA}" => [ -foreground => 'red' ],
	   "bg_white" => [ -background => 'white' ],
	  ]

	 ];
}

################################ Macros ################################

sub open_editor { Tectogrammatic::open_editor(@_) }
sub ChooseFrameNoAssign { Tectogrammatic::choose_frame($this,-no_assign=>1) }
#bind open_editor to Ctrl+Shift+Return menu Zobraz valencni ramce
#bind ChooseFrameNoAssign to Ctrl+Return menu Zobraz valencni ramce pro sloveso


#bind edit_commentA to exclam menu Edit annotator's comment
#bind edit_commentA to exclam
sub edit_commentA {
  if (not FS()->exists('commentA')) {
    ToplevelFrame()->messageBox
      (
       -icon => 'warning',
       -message => 'Sorry, no attribute for annotator\'s comment in this file',
       -title => 'Sorry',
       -type => 'OK'
      );
    $FileNotSaved=0;
    return;
  }
  my $value=$this->{commentA};
  $value=main::QueryString($grp->{framegroup},"Enter comment","commentA",$value);
  if (defined($value)) {
    $this->{commentA}=$value;
  }
}

#bind edit_corinfo to + menu Edit corinfo
sub edit_corinfo {
  if (not FS()->exists('corinfo')) {
    ToplevelFrame()->messageBox
      (
       -icon => 'warning',
       -message => 'Sorry, no attribute for corinfo in this file',
       -title => 'Sorry',
       -type => 'OK'
      );
    $FileNotSaved=0;
    return;
  }
  my $value=$this->{corinfo};
  $value=main::QueryString($grp->{framegroup},"Enter corinfo","corinfo",$value);
  if (defined($value)) {
    $this->{corinfo}=$value;
  }
}


#bind fill_empty_attrs to Space
sub fill_empty_attrs {
  foreach (qw/coref gender number corsnt/) {
    $this->{$_} = '???' if ($this->{$_} eq "");
  }
}

#*get_status_line_hook = Tectogrammatic::get_status_line_hook;
#*status_line_doubleclick_hook = Tectogrammatic::status_line_doubleclick_hook;

#include "coref.mak"

#endif tr_coref_common
