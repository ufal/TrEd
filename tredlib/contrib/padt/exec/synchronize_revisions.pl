# -*- perl -*- ############################################################# Otakar Smrz, 2006/02/11
#
# synchronize_revisions.pl ############################################################## 2006/02/12

# $Id: synchronize_revisions.pl 481 2008-01-24 16:34:52Z smrz $

our $VERSION = do { q $Revision: 481 $ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };


BEGIN {

    our $libDir = `btred --lib`;

    chomp $libDir;

    eval "use lib '$libDir', '$libDir/libs/fslib', '$libDir/libs/pml-base'";
}

$dirsep = '\\';

@ARGV = glob join " ", @ARGV;

foreach $file (@ARGV) {

    @path = split /\//, $file;

    $name = pop @path;

    ($base, $type) = $name =~ /^(.+)\.(morpho|syntax)\.fs$/;

    @path = ( @path == 0 ? '..' : '.', $type ) if @path < 2;

    if ($type ne $path[-1]) {

        warn "$type <> $path[-1]\t with $file\n";
        next;
    }

    $file[0] = join $dirsep, @path[0 .. @path - 2], 'morpho', $base . '.morpho.fs';
    $file[1] = join $dirsep, @path[0 .. @path - 2], 'morpho', $base . '.syntax.fs';
    $file[2] = join $dirsep, @path[0 .. @path - 2], 'syntax', $base . '.syntax.fs.anno.fs';
    $file[3] = join $dirsep, @path[0 .. @path - 2], 'syntax', $base . '.syntax.fs';

    unless (-f $file[0]) {
          warn "$file[0] not present with $file\n";
          next;
    }

    if (-f $file[1]) {
          warn "$file[1] is blocking with $file\n";
          next;
    }

    if (-f $file[2]) {
          warn "$file[2] is blocking with $file\n";
          next;
    }

    unless (-f $file[3]) {
          warn "$file[3] not present with $file\n";
          next;
    }

    system 'perl -pi.unlines.fs ' . $libdir . 'lines_fs.pl ' . $file[0];

    system 'copy ' . $file[3] . ' ' . $file[2];

    system 'perl -X ' . $libdir . 'SyntaxFS.pl ' . $file[0];

    system 'copy ' . $file[1] . ' ' . $file[3];

    system 'btred -QI ' . $libdir . 'migrate_annotation_syntax.btred ' . $file[3];

    system 'perl -pi.unlines.fs ' . $libdir . 'lines_fs.pl ' . $file[3];
}
