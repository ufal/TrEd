package TrEd::Utils;
# pajas@ufal.ms.mff.cuni.cz          28 uno 2007

use 5.008;
use strict;
use warnings;

use Carp;
#use Data::Dumper;
use List::Util qw(first min max);
use File::Spec;
use URI::Escape;
use Treex::PML::Schema::CDATA;
require Exporter;

use base qw(Exporter);

use Readonly;

Readonly our $EMPTY_STR => q{};

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use TrEd::Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
  fetch_from_win32_reg
  find_win_home
  applyFileSuffix
  parse_file_suffix
  getNodeByNo
  set_fh_encoding
    
  uniq
    
  $EMPTY_STR
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  );
our $VERSION = '0.03';

#######################################################################################
# Usage         : fetch_from_win32_reg_old('HKEY_LOCAL_MACHINE', q(SOFTWARE\Classes\.html)[, $subkey])
# Purpose       : Read a value from windows registry 
# Returns       : Value from the registry key or undef when the key was not found
# Parameters    : string $registry  -- name of the registry (HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER, etc), 
#                 string $key       -- name of the key (backslash-delimited)
#                 [string $subkey]  -- optional -- subkey name
# Throws        : no exceptions
# Comments      : Requires Win32::Registry; Now obsolete, just for testing purposes, see newer version: fetch_from_win32_reg
# See Also      : fetch_from_win32_reg
sub fetch_from_win32_reg_old {
  my ($registry,$key,$subkey)=@_;
  my ($reg,%data);

  require Win32::Registry;
  {
    no strict;
    ${"::".$registry}->Open($key,$reg);
  }
  if ($reg) {
    $reg->GetValues(\%data);
    return $data{"$subkey"}[2];
  }
  return;
}

######################################################################################
# Usage         : fetch_from_win32_reg('HKEY_LOCAL_MACHINE', q(SOFTWARE\Classes\.html)[, $subkey])
# Purpose       : Read a value from windows registry
# Returns       : Value read or undef when the key was not found
# Parameters    : string $registry  -- name of the registry (HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER, etc), 
#                 string $key       -- name of the key (backslash-delimited)
#                 [string $subkey]  -- optional -- subkey name
# Throws        : no exceptions
# Comments      : Requires Win32::TieRegistry
# See Also      : fetch_from_win32_reg_old, Win32::TieRegistry (cpan)
sub fetch_from_win32_reg {
  my ($registry,$key,$subkey)=@_;

  my $reg_ref;
  my $delimiter = "\\";
  require Win32::TieRegistry;
  import Win32::TieRegistry ( Delimiter=>$delimiter, ArrayValues=>1, DWordsToHex=>1, TiedRef => \$reg_ref, "REG_DWORD");
  my $query = ($registry . $delimiter . $key . $delimiter);
  # if subkey is not defined, we have to use one more delimiter to let the module know, we want the default value
  if(defined($subkey)){
    $query .= $subkey;
  } else {
    $query .= $delimiter;
  }
  # Array returned by the registry reader:
  # array_ref->[0] == value
  # array_ref->[1] == type
  my $value_array_ref = $reg_ref->{$query};
  if (defined $value_array_ref) { 
    # print "key was found.\n";
  } else {
    # print "key not found.\n";
    return;
  }
  # to be coherent with the old version, which returns decimal instead of hexadecimal value   
  return ($value_array_ref->[1] == REG_DWORD()) ? hex($value_array_ref->[0]) : $value_array_ref->[0];
}

######################################################################################
# Usage         : find_win_home()
# Purpose       : Set 'HOME' environment variable on Windows to user's AppData 
# Returns       : nothing
# Parameters    : no
# Throws        : a string; dies if the 'HOME' env variable is not set and AppData could not be read from the registry 
# Comments      : Requires Win32::TieRegistry indirectly
# See Also      : fetch_from_win32_reg, Win32::TieRegistry (cpan)
sub find_win_home {
  # in Windows, if HOME not defined, use user's AppData folder instead
  if ($^O eq "MSWin32" and !exists($ENV{HOME})) {
    my $key = q(Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders);
    my $home = fetch_from_win32_reg
      ('HKEY_CURRENT_USER',
     $key,
       'AppData');
    if (defined($home)) {
      $ENV{HOME} = $home;
    }
    else {
      croak("Couldn't fetch $key from Win32 registry: $^E\n");
    }
  }
}










#######################################################################################
# Usage         : parse_file_suffix($filename)
# Purpose       : Split file name into file name itself and its suffix  
# Returns       : List which contains file name and its suffix, if there is no suffix, 
#                 second list element is undef
# Parameters    : scalar $filename -- name of the file
# Throws        : no exceptions
# Comments      : File suffix can be of the following forms:
#                 a) 1 or 2 #-signs, upper-case characters or numbers, and optionally followed by 
#                     optional dash, full stop and at least one number
#                 b) 2 #-signs, at least one number, full stop, followed by 
#                     one non-numeric not-# character and any number of not-# chars
#                 c) 1 #-sign followed by any number of not-# characters
# See Also      : 
sub parse_file_suffix {
  my ($filename) = @_;
  # 
  return if (!defined $filename);
  if ($filename =~ s/(##?[0-9A-Z]+(?:-?\.[0-9]+)?)$// ) {
    return ($filename, $1);
  }
  elsif ($filename =~ m{^ 
                        (.*)               # file name with any characters followed by
                        (\#\#[0-9]+\.)       # 2x#, at least one number and full stop
                        ([^0-9\#][^\#]*)     # followed by one non-numeric not-# character and any number of not-# chars
                        $
                        }x and 
         Treex::PML::Schema::CDATA->check_string_format($3, 'ID')) {
    return ($1, $2 . $3);
  }
  elsif ($filename =~ m{^
                        (.*)        # file name with any characters followed by
                        \#          # one hash followed by
                        ([^\#]+)     # any number of not-# characters
                        $    
                        }x and 
          Treex::PML::Schema::CDATA->check_string_format($2, 'ID')) {
    return ($1, '#' . $2);
  }
  else {
    return ($filename, undef);
  }
}

#TODO: document & test this unclear function
sub _find_tree_no {
    my ($fsfile, $root, $list) = @_;
    my $n = undef;
    # hm, we have a node, but don't know to which tree
    # it belongs
    my $trees_type = $fsfile->metaData('pml_trees_type');
    my $root_type  = $root->type();
    #TODO: empty? or defined???
    if ( $trees_type and $root_type ) {
        my $trees_type_is = $trees_type->get_decl_type();
        my %paths;
        my $is_sequence;
        my $found;
        my @elements;
        if ( $trees_type_is == Treex::PML::Schema::PML_LIST_DECL() ) {
            @elements = [ 'LM', $trees_type->get_content_decl() ];
        }
        elsif ( $trees_type_is == Treex::PML::Schema::PML_SEQUENCE_DECL() ) {
            # Treex::PML::Schema::Element::get_name(), 
            #           ::Schema::Decl::get_content_decl()
            @elements = map { [ $_->get_name(), $_->get_content_decl() ] }
                        $trees_type->get_elements();
            $is_sequence = 1;
        }
        else {
            return -1;
        }
        
        for my $el (@elements) {
            $paths{ $el->[0] } = [
                $trees_type->get_schema->find_decl(
                    sub {
                        $_[0] == $root_type;
                    },
                    $el->[1],
                    {}
                )
            ];
            if (@{ $paths{ $el->[0] } }) {
                $found = 1;
            }
        }
        return -1 if !$found;
    TREE:
        for my $i ( 0 .. $#$list ) {
            my $tree = $list->[$i];
            my $paths
                = $is_sequence
                ? $paths{ $tree->{'#name'} }
                : $paths{LM};
            for my $p ( @{ $paths || [] } ) {
                for my $value ( $tree->all($p) ) {
                    if ( $value == $root ) {
                        $n = $i;
                        last TREE;
                    }
                }
            }
        }
    }
    return $n;
}

#TODO: could be renamed to use _, but it is used in Vallex extension
#######################################################################################
# Usage         : applyFileSuffix($win, $goto)
# Purpose       : Set current tree and node positions to positions described by 
#                 $goto suffix in file displayed in $win window 
# Returns       : 1 if the new position was found and set, 0 otherwise
# Parameters    : TrEd::Window $win -- reference to TrEd::Window object 
#                 string $goto      -- suffix of the file (or a position in the file)
# Throws        : no exceptions
# Comments      : Possible suffix formats:
#                   ##123.2 -- tree number 123 (if counting from 1) and its second node
#                   #123.3 -- tree whose $root->{form} equals to #123 and its third node
#                           (only hint found in Treex/PML/Backend/CSTS/Csts2fs.pm)
#                   #a123 -- finds node with id #a123 and the tree it belongs to
#                 The node's id can also be placed after the '.', e.g. ##123.#a123, in 
#                 which case the sub searches for node with id #a123 inside tree no 123
#
#                 Sets $win->{treeNo} and $win->{currentNode} if appropriate.
# See Also      : parse_file_suffix()
sub applyFileSuffix {
    my ( $win, $goto ) = @_;
    return if ( !defined $win );
    my $fsfile = $win->{FSFile};
    return if !( defined $fsfile && defined $goto && $goto ne $EMPTY_STR );

    if ( $goto =~ m/^##([0-9]+)/ ) {
        # handle cases like '##123'
        my $no = int( $1 - 1 );
        $win->{treeNo} = min( max( 0, $no ), $fsfile->lastTreeNo() );
        return 0 if $win->{treeNo} != $no;
    }
    elsif ( $goto =~ /^#([0-9]+)/ ) {
        # handle cases like '#123'
        # this is PDT 1.0-specific code, sorry
        my $no;
        for ( my $i = 0; $i <= $fsfile->lastTreeNo(); $i++ ) {
            if ( $fsfile->treeList()->[$i]->{form} eq "#$1" ) {
                $no = $i;
                last;
            }
        }
        return 0 if (!defined $no);
        $win->{treeNo} = $no;
    }
    elsif ( $goto =~ /^#([^#]+)$/ ) {
        # handle cases like '#a123'
        my $id = $1;
        if ( Treex::PML::Schema::CDATA->check_string_format( $id, 'ID' ) ) {
            my $id_hash = $fsfile->appData('id-hash');
            if ( UNIVERSAL::isa( $id_hash, 'HASH' )
                && exists $id_hash->{$id} )
            {
                my $node = $id_hash->{$id};

                # we would like to use Treex::PML::Index() here, but can't
                # and why we can not?
                my $list = $fsfile->treeList();
                my $root = UNIVERSAL::can( $node, 'root' ) && $node->root();
                my $n    = defined($root) && first {
                    $list->[$_] == $root;
                } 0 .. $#$list;
                
                if ( defined $root and !defined($n) ) {
                    $n = _find_tree_no($fsfile, $root, $list);
                    # exit from _find_tree_no() function
                    if (!defined $n || $n == -1) {
                        return 0;
                    }
                }
                if ( defined($n) ) {
                    $win->{treeNo}      = $n;
                    $win->{currentNode} = $node;
                    return 1;
                }
                else {
                    return 0;
                }
            }
        }
    }

    # new: we're the dot in .[0-9]+ (TM)
    if ( $goto =~ /\.([0-9]+)$/ ) {
        my $root = getNodeByNo( $win, $1 );
        if ($root) {
            $win->{currentNode} = $root;
            return 1;
        }
        else {
            return 0;
        }
    }
    elsif ( $goto =~ /\.([^0-9#][^#]*)$/ ) {
        my $id = $1;
        if ( Treex::PML::Schema::CDATA->check_string_format( $id, 'ID' ) ) {
            my $id_hash = $fsfile->appData('id-hash');
            if ( UNIVERSAL::isa( $id_hash, 'HASH' )
                 && exists( $id_hash->{$id} ) )
            {
                return 1
                    if ( $win->{currentNode} = $id_hash->{$id} ); # assignment
            }
            else {
                return 0;
            }
        }
    }
    return 1;

    # hey, caller, you should redraw after this!
}

#TODO: this does not belong here!
sub getNodeByNo {
  my ($win,$no)=@_;
  my $root=$win->{FSFile}->treeList->[$win->{treeNo}];
  my $i=$no;
  while ($root and $i>0) {
    $i--;
    $root=$root->following();
  }
  return $root;
}

#TODO: do Convert?
#######################################################################################
# Usage         : set_fh_encoding($handle, ':utf8', "file_name")
# Purpose       : Set encoding on a file handle  
# Returns       : nothing
# Parameters    : filehandle $fh    -- filehandle, 
#                 string $encoding  -- same encoding, as is accepted by open/binmode functions, e.g. ":encoding(utf8)"
#                 string $what      -- name of the flush (so we can report error if any occurs)
# Throws        : a string; When binmode or flush call fails
# Comments      : Be careful, don't use :utf8 on input files and STDIN (http://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8);
#                 It seems that the third parameter is not used in the sub, why is it here?
# See Also      : binmode (perldoc)
sub set_fh_encoding {
  my ($fh, $enc, $what)=@_;
  return unless $enc;
  $fh->flush()
    or croak("Could not flush $what");
  # first get rid of all I/O layers
  binmode($fh)
    or croak("Could not set binmode on $what");
  
  if ($enc =~ /^:/) {
    binmode($fh,$enc)
      or croak("Could not use binmode to set encoding to $enc on $what");
  } else {
    binmode($fh,":encoding($enc)")
      or croak("Could not use binmode to set encoding to $enc on $what");
  }
}


#######################################################################################
# Usage         : uniq(@array)
# Purpose       : Remove duplicit elements from array
# Returns       : Array without repeating elements
# Parameters    : array @arr  -- array to be uniqued
# Throws        : no exception
# Comments      : Preserves type and order of elements, as suggested by Perl best practices
sub uniq {
    # seen -- track keys already seen elements
    my %seen;
    # return only those not yet seen
    return grep { !( $seen{$_}++ ) } @_;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

TrEd::Utils - Perl extension for blah blah blah

=head1 SYNOPSIS

   use TrEd::Utils;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for TrEd::Utils, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

