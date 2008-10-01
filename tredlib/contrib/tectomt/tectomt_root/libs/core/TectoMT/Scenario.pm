#!/usr/bin/perl

package TectoMT::Scenario;

use vars qw($root $this $grp $SelectedTree);

use 5.008;
use strict;
use warnings;
use Report;
use Class::Std;

use Fslib;
my @backends=('FSBackend',ImportBackends(
    qw(NTREDBackend StorableBackend PMLBackend )));
$Fslib::resourcePath = $ENV{"TMT_ROOT"}."/pml_schemas/";

use TectoMT::Node;
use TectoMT::Bundle;
use TectoMT::Document;

use BlockAliases;

{

    our $VERSION = '0.01';
    my %block_sequence : ATTR;

    sub Expand_block_sequence { # expand aliases (class method used in BUILD)
        my @unexpanded_blocks = @_;
        my @block_names = map {s/.*blocks\///;s/\//::/; s/\.pm//;$_}
            map {s/\/\//\//g;$_}  @unexpanded_blocks;
        my @expanded_block_names; # recursively expandend aliases for blocks and block sequences
        while (@block_names) {
            my $block = shift @block_names;
            if ($BlockAliases::alias{$block}) {
                if (ref($BlockAliases::alias{$block})) {
                    push @block_names, @{$BlockAliases::alias{$block}};
                } else {
                    push @expanded_block_names, $BlockAliases::alias{$block};
                }
            } elsif ($block!~/^[#!]/) {
                push @expanded_block_names, $block;
            }
        }
        return @expanded_block_names;
    }

    sub BUILD {
        my ($self, $ident, $arg_ref) = @_;

        Report::info("Initializing an instance of TectoMT::Scenario ...");

        if ($arg_ref->{blocks}) {

            my @expanded_block_names = Expand_block_sequence(@{$arg_ref->{blocks}});

            Report::info((1+$#expanded_block_names)." block(s) to be used in the scenario: "
                             # .(join " ", @expanded_block_names)
                             ."\n");

            my $i=0;
            foreach my $block_name (@expanded_block_names) {
                $i++;
                Report::info_unfinished("Loading block $block_name ($i/".(0+@expanded_block_names).") ...");
                eval "use $block_name;";
                my $constructor_params="";
                if ($@) {
                    my $generic_blocks_allowed = 1;
                    my $block_filename = $block_name;
                    $block_filename =~ s/::/\//g;
                    $block_filename .= ".pm";
                    if ($generic_blocks_allowed
                            && ! -e $ENV{TMT_ROOT}."/libs/blocks/$block_filename"
                                # never attempt generic blocks if there is the specific block
                                # (compilation of the specific block probably failed due to an error)
                                && $block_name=~/(([A-Z])([A-Z][A-Za-z]+)([A-Z])_to_([A-Z])([A-Z][A-Za-z]+)([A-Z]))/) {
                        my $block_dir = $1;
                        my ($input_sourtarg,$input_lang,$input_layer,$output_sourtarg,$output_lang,$output_layer) = ($2,$3,$4,$5,$6,$7);
                        my $generic_dir = $input_sourtarg."Anylang1".$input_layer."_to_".$output_sourtarg."Anylang2".$output_layer;
                        my $generic_block_name = $block_name;
                        $generic_block_name=~s/$block_dir/$generic_dir/;
                        Report::info("Trying to load generic block $generic_block_name ");
                        #... blockdir:$block_dir genericdir:$generic_dir");
                        eval "use $generic_block_name;";
                        if ($@) {
                            Report::fatal "Can't even use the generic block module!"; # $@
                        } else {
                            $block_name = $generic_block_name;
                            $constructor_params = "{qw(Anylang1)=>qw($input_lang),qw(Anylang2)=>qw($output_lang)}";
                        }
                    } else {
                        Report::fatal "Can't use block $block_name !";
                    }
                }
                Report::info_finish("OK.");
                my $new_block;
                my $string_to_eval = '$new_block = '.$block_name."->new($constructor_params);";
                #	use TAnylang1A_to_TAnylang1W::Target_sentence_by_form_concat;
                #	$new_block = TAnylang1A_to_TAnylang1W::Target_sentence_by_form_concat->new({qw(Anylang1)=>English});

                eval $string_to_eval;
                if ($@) {
                    Report::fatal "TectoMT::Scenario->new: error when initializing block $block_name by evaluating '$string_to_eval'\n".$!;
                }
                push @{$block_sequence{ident $self}}, $new_block;
            }

        } else {
            Report::fatal "TectoMT::Scenario->new:   no blocks specified!";
        }
        Report::info "";
        Report::info "   ALL BLOCKS SUCCESSFULLY LOADED.";
        Report::info "";

    }


    sub apply_on_tmt_documents {
        my $self = shift @_;
        my  @documents = @_;

        if (@documents==0) {
            Report::fatal "No document specified";
        } elsif (grep {not UNIVERSAL::isa($_, "TectoMT::Document")} @documents) {
            Report::fatal "Arguments must be instances of TectoMT::Document";
        }

        my $block_number = 0;
        my $block_total = @{$block_sequence{ident $self}};
        my $doc_total = @documents;
        foreach my $block (@{$block_sequence{ident $self}}) {
            $block_number++;
            my $doc_number = 0;
            foreach my $document (@documents) {
                $doc_number++;
                my $filename = $document->get_fsfile_name();
                Report::info "Applying block $block_number/$block_total ".ref($block)." on document '$filename' ...";
                #	$doc_number/$doc_total
                $block->process_document($document);
            }
        }
    }


    sub apply_on_tmt_files {
        my $self = shift @_;
        my @filenames = @_;
        Report::info "Number of files to be processed by the scenario: ".scalar(@filenames)." \n";
        foreach my $filename (@filenames) {
            Report::info "Processing $filename ...\n";
            my $fsfile = FSFile->newFSFile($filename,"utf8",@backends); # vykopirovano z btredu
            if (not UNIVERSAL::isa($fsfile,"FSFile")) {
                Report::fatal "Did not succeed to open fsfile ($fsfile)";
            }
            my $document = TectoMT::Document->new();
            $document->tie_with_fsfile($fsfile);
            $self->apply_on_tmt_documents($document);
            Report::info "Saving $filename ...\n";
            $fsfile->writeFile($filename);

        }

    }

    sub apply_on_tmt_files_without_save { # ??? praseci, potreba nahradit parametrem konstruktoru!!!
        my $self = shift @_;
        my @filenames = @_;
        Report::info "Number of files to be processed by the scenario: ".scalar(@filenames)." \\
n";
        foreach my $filename (@filenames) {
            Report::info "Processing $filename ...\n";
            my $fsfile = FSFile->newFSFile($filename,"utf8",@backends); # vykopirovano z btredu
            if (not UNIVERSAL::isa($fsfile,"FSFile")) {
                Report::fatal "Did not succeed to open fsfile ($fsfile)";
            }
            my $document = TectoMT::Document->new();
            $document->tie_with_fsfile($fsfile);
            $self->apply_on_tmt_documents($document);
#            Report::info "Saving $filename ...\n";
#            $fsfile->writeFile($filename);

        }

    }



    sub apply_on_fsfile_objects {

        my $self = shift;
        my @fsfiles = @_;
        if (grep {not UNIVERSAL::isa($_,"FSFile")} @fsfiles) {
            Report::fatal "Arguments must be FSFile instances.";
        }

        #    Report::debug ("apply_on_fsfile_objects XXX");

        #my @untied_fsfiles = grep {not defined($_->metaData('pml_root')->{_tmt_document}) } @fsfiles;
        my @untied_fsfiles = grep {not defined($TectoMT::Document::fsfile2tmt_document{$_}) } @fsfiles;
    

        #    foreach my $fsfile (@fsfiles) {
        #      Report::debug "fsfile=".$fsfile."   document=".$fsfile->metaData('pml_root')->{_tmt_document};
        #    }
        if (@untied_fsfiles) {
            Report::info "There are fsfiles without associated TectoMT representation, which is therefore being built now.";
            foreach my $fsfile (@untied_fsfiles) {
                TectoMT::Document->new({'fsfile' => $fsfile});
            }
        }

        #    my @tmt_documents = map {$_->metaData('pml_root')->{_tmt_document}} @fsfiles;
        my @tmt_documents = map {$TectoMT::Document::fsfile2tmt_document{$_}} @fsfiles;
        $self->apply_on_tmt_documents(@tmt_documents);

        # prevention of cyclic references
        foreach my $document (@tmt_documents) {
            $document->untie_from_fsfile;
            Report::info "Disconnecting $document from the underlying fsfile (to prevent cyclic references)."
          }

    }
}
1;

__END__

=head1 NAME

TectoMT::Block


=head1 VERSION

0.0.1

=head1 SYNOPSIS

 use TectoMT::Bundle;
 ??? ??? ??? ???



=head1 DESCRIPTION


?? ?? ?? ?? ?? ???? ?? ???? ?? ???? ?? ??


=head1 METHODS

=head2 Constructor

=over 4

=item my $scenario = TectoMT::Scenario->new({'blocks'=> [ qw(Blocks::Tokenize  Blocks::Lemmatize) ]);

Constructor argument is a reference to a hash containing options. Option 'blocks' specifies
the reference to the array of names of blocks which are to be executed (in the specified order)
when the scenario is applied on a TectoMT::Document object.

=back



=head2 Running the scenario

=over 4

=item $scenario->apply_on_tmt_documents(@documents);

Applies the sequence of blocks on the specified TectoMT::Document objects.

=item $scenario->apply_on_tmt_files(@file_names);

Opens the PML files (corresponding instances of TectoMT::Documents), applies the
translation blocks on them, and saves the files back (under the same names).

=item $scenario->apply_on_fsfile_objects(@fsfiles);

It applies the blocks on the given list of instances of class FSFile
(e.g. $grp->{FSFile} in btred/ntred)

=back



=head1 SEE ALSO

L<TectoMT::Node|TectoMT::Node>,
L<TectoMT::Bundle|TectoMT::Bundle>,
L<TectoMT::Document|TectoMT::Document>,
L<TectoMT::Block|TectoMT::Block>,


=head1 AUTHOR

Zdenek Zabokrtsky <zabokrtsky@ufal.mff.cuni.cz>

=head1 COPYRIGHT

Copyright (c) 2006 by Zdenek Zabokrtsky. This module is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

