# -*- cperl -*-

#encoding iso-8859-2
#ifndef PML_A2T
#define PML_A2T

package PML_A2T;
import PML;
sub first (&@);

=pod

=head1 PML_A2T

PML_A2T.mak - Helper macros for writing an a- to t-layer
transformations over the Prague Dependency Treebank (PDT) 2.0 data

=over 4

=item CreateTFile($a_file?)

Creates and returns empty t-file (FSFile object) linked with a given
a-file.  It associates the newly created file with C<tdata_schema.xml>
PML schema. If no a_file is given, current file is used. Initially,
the newly created t-file contains no trees. Trees can be added using
C<AddNewTTree>.

=cut

sub CreateTFile {
  my ($a_file)=@_;

  $a_file ||= $grp->{FSFile};
  die "CreateTFile: not an a-file\n"
    unless $a_file or SchemaName($a_file) ne 'adata';

  # this is just to have some default, the user should change it if necessary
  my $filename = $a_file->filename();
  unless ($filename=~s/\.a(.pls)?(\.gz)?/.t$1$2/) {
    $filename .= '.t';
  }

  my $fsfile =
    FSFile->create
      (
       name => $filename,
       FS => FSFormat->new({
	  'deepord' => ' N'
	}),
       trees => [],
       backend => 'PMLBackend',
       encoding => $a_file->encoding,
      );

  my $schema_file = Fslib::ResolvePath($fsfile->filename,
				       'tdata_schema.xml',1);
  $fsfile->changeMetaData('schema-url',$schema_file);
  $fsfile->changeMetaData('schema',Fslib::Schema->readFrom($schema_file));

  $fsfile->changeMetaData('references',{ a => $a_file->filename,
					 v => 'vallex.xml'
				       });
  $fsfile->changeMetaData('refnames', { adata => 'a',
					vallex => 'v'
				      });

  if (ref($a_file->appData('fs-part-of'))) {
    push @{ $a_file->appData('fs-part-of') }, $fsfile;
  } else {
    $a_file->changeAppData('fs-part-of', [$fsfile]);
  }
  $fsfile->changeAppData('ref',{a => $a_file});
  $fsfile->changeMetaData('fs-require',[['a',$a_file->filename]]);
  $a_file->changeAppData('tdata',$fsfile);

  return $fsfile;
}

=item AddNewTTree($t_file?)

Creates a new t-tree linked with the current a-tree and appends the
newly created t-tree to a given t-file. Initially the t-tree consists
of the root node alone. More nodes can be added e.g. using
C<PML_T::NewNode($parent)> and linked to a-nodes using
C<PML_A::AddANodeToALexRf> and C<PML_A::AddANodeToAAuxRf>.

If no t-file is given, the t-file currently associated with the
current a-file is used (if any). See also more generic macro
C<InitTTree>.

=cut

sub AddNewTTree {
  shift unless ref($_[0]);
  my ($t_file)=@_;
  my $a_file = $grp->{FSFile};
  die "Current tree is not an a-tree\n" unless $a_file or SchemaName($a_file) ne 'adata';
  $t_file ||= $a_file->appData('tdata');
  die "No t-file" unless ref($t_file);
  my $t_root = $t_file->new_tree($t_file->lastTreeNo+1);
  InitTTree($t_file,$t_root,$root);
}


=item InitTTree($t_file,$t_root,$a_root)

Initialize a given t-root node based on a given a-root node.  Empty
t-root node to be used with this function can be created using either
NewTree or NewTreeAfter macros, or by a direct call to
C<$t_file->new_tree($file_position)>.

=cut

sub InitTTree {
  my ($t_file,$t_root,$a_root)=@_;
  my $refid = $t_file->metaData('refnames')->{adata};
  my $t_schema = Schema($t_file);
  $t_root->{'atree.rf'} = $refid.'#'.$a_root->{id};
  my $type = first {$_->{name} eq 't-root' } $t_schema->node_types;
  $t_root->set_type($t_schema->type($type));
  $t_root->{nodetype}='root';
  $t_root->{deepord}=0;
  $t_root->{id} = $a_root->{id};
  $t_root->{id} =~ s/^a/T/; # T instead of t to aviod collision with PDT IDs
}

sub ANodeToALexRf {
  my ($a_node,$t_node,$t_file)=@_;
  return unless $t_node && $a_node;
  $t_file ||= $grp->{FSFile}->appData('tdata');
  return unless ref($t_file);
  my $refid = $t_file->metaData('refnames')->{adata};
  $t_node->{a}{'lex.rf'}=$refid."#".$a_node->{id};
  @{$t_node->{a}{'aux.rf'}}=grep{ $_ ne $refid."#".$a_node->{id} }
    uniq(ListV($t_node->{a}{'aux.rf'}));
  my$lemma=$this->{'m'}{lemma};
  my%specialEntity;
  %specialEntity=qw!. Period
                    , Comma
                    &amp; Amp
                    - Dash
                    / Slash
                    ( Bracket
                    ) Bracket
                    ; Semicolon
                    : Colon
                    &ast; Ast
                    &verbar; Verbar
                    &percnt; Percnt
                    !;
  if($lemma=~/^.*`([^0-9_-]+)/){
    $lemma=$1;
  }else{
    $lemma=~s/(.+?)[-_`].*$/$1/;
    if($lemma =~/^(?:(?:[ts]v|m)ùj|já|ty|jeho|se)$/){
      $lemma='#PersPron';
    }
    $lemma="#$specialEntity{$lemma}"if exists$specialEntity{$lemma};
  }
  $t_node->{t_lemma}=$lemma;
} #ANodeToALexRf


sub ANodeToAAuxRf {
  my ($a_node,$t_node,$t_file)=@_;
  return unless $t_node && $a_node;
  $t_file ||= $grp->{FSFile}->appData('tdata');
  return unless ref($t_file);
  my $refid = $t_file->metaData('refnames')->{adata};
  AddToList($t_node,'a/aux.rf',$refid.'#'.$a_node->{id});
  @{$t_node->{a}{'aux.rf'}}=uniq(ListV($t_node->{a}{'aux.rf'}));
  delete $t_node->{a}{'lex.rf'}
    if $t_node->attr('a/lex.rf')eq$refid.'#'.$a_node->{id};
}#ANodeToAAuxRf



#ifdef TRED
sub NewTredFile {
  my ($fsfile)=@_;
  die "'$fsfile' is not a FSFile\n" unless UNIVERSAL::isa($fsfile,'FSFile');

  die "File is already opened by TrEd\n" 
    if grep { $_ == $fsfile } @main::openfiles;
  push @main::openfiles, $fsfile;
  main::updatePostponed($grp->{framegroup});
}
#binding-context PML_A_Edit
#bind PML_A2T->new_t_file to 1 menu Create a t-file from scratch for the current a-file
sub new_t_file {
  my $new = CreateTFile($grp->{FSFile});
  print "Created $new as ",$new->filename,"\n";
  NewTredFile($new);
}
#bind PML_A2T->AddNewTTree to 2 menu Create a new t-tree from scratch based on the current a-tree
#endif TRED

=back

=cut

#endif PML_A2T
