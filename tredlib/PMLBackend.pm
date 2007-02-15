package PMLBackend;

use Fslib;
use IOBackend qw(close_backend);
use strict;
use warnings;

use PMLInstance qw( :all :diagnostics $DEBUG );

use constant EMPTY => q{};

use Carp;

use vars qw(@pmlformat @pmlpatterns $pmlhint $encoding $config $config_file $allow_no_trees);


$encoding='utf-8';
@pmlformat = ();
@pmlpatterns = ();
$pmlhint=EMPTY;
$config = undef;
$config_file = 'pmlbackend_conf.xml';
$allow_no_trees = 0;

sub configure {
  return 0 unless eval { 
    require XML::LibXSLT;
  };

  $config_file = Fslib::FindInResources($config_file);
  if (-f $config_file) {
    _debug("config file: $config_file\n");
    $config = PMLInstance->load({filename => $config_file});
  }
  return $config;
}


###################

=item open_backend (filename,mode)

Only reading is supported now!

=cut

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  my $fh = IOBackend::open_backend($filename,$mode) # discard encoding
    || die "Cannot open $filename for ".($mode eq 'w' ? 'writing' : 'reading').": $!";
  return $fh;
}

sub index_fs_by_id {
  my ($fsfile) = @_;
  my %index;
  foreach my $node ($fsfile->trees) {
    while ($node) {
      $index{$node->{id}}=$node if $node->{id} ne EMPTY;
    } continue {
      $node=$node->following;
    }
  }
  return \%index;
}

sub xml_parser {
  my $parser = XML::LibXML->new();
  $parser->keep_blanks(0);
  $parser->line_numbers(1);
  $parser->load_ext_dtd(0);
  $parser->validation(0);
  return $parser;
}


=pod

=item read (handle_ref,fsfile)

=cut

sub read ($$) {
  my ($input, $fsfile)=@_;
  return unless ref($fsfile);

  my $ctxt = PMLInstance->load({fh => $input, filename => $fsfile->filename, config => $config });
  $ctxt->convert_to_fsfile( $fsfile );
  my $status = $ctxt->get_status;
  if ($status and 
      !($allow_no_trees or defined($ctxt->get_trees))) {
    _die("No trees found in the PMLInstance!");
  }
  return $status
}


=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  my ($fh,$fsfile)=@_;
  my $ctxt = PMLInstance->convert_from_fsfile( $fsfile );
  $ctxt->save({ fh => $fh, config => $config });
}


=pod

=item test (filehandle | filename, encoding?)

=cut

sub test {
  my ($f,$encoding)=@_;

  if (ref($f)) {
    local $_;
    1 while ($_=$f->getline() and !/\S/);
    if ($config) {
      # see <, assume XML
      return 1 if (/^\s*</);
    } else {
      # only accept PML instances
      # return 0 unless (/^\s*<\?xml\s/);
      do {{
        return 1 if m{xmlns(?::[[:alnum:]]+)?=([\'\"])http://ufal.mff.cuni.cz/pdt/pml/\1};
      }} while ($_=$f->getline() and (!/\S/ or /^\s*<?[^>]+?>\s*$/ or !/[>]/));
      return m{<[^>]+xmlns(?::[[:alnum:]]+)?=([\'\"])http://ufal.mff.cuni.cz/pdt/pml/\1} ? 1 : 0;
    }
  } else {
    my $fh = IOBackend::open_backend($f,"r");
    my $test = $fh && test($fh,$encoding);
    IOBackend::close_backend($fh);
    return $test;
  }
}


######################################################


################### 
# INIT
###################
package PMLBackend;
eval {
  configure();
};
_warn $@ if $@;

1;
