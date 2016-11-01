#!/bin/bash
# install_tred.sh     pajas@ufal.mff.cuni.cz     2009/01/19 11:03:51
#
# Copyright (c) by Petr Pajas
#
# This script installs most recent TrEd and its Perl/C dependeincies
# to a specified folder.
#
# Run with --help to see more information
#
#

if [ -z "$BASH" ]; then
    echo "Please run this script using bash interpreter, not sh!" 1>&2
    exit 1;
fi

# TRED_HOME_URL is rewritten during release to actual URL of TrEd webpage (build-dep-package.sh)
tred_url="TRED_HOME_URL/tred-current.tar.gz"
tred_dep="TRED_HOME_URL/tred-dep-unix.tar.gz"
tred_svn="svn://anonymous@svn.ms.mff.cuni.cz/svn/TrEd_refactored/tred_refactored"

# readlink -f does not work on Mac OSX, so here is a Perl-based workaround:
readlink_nf () {
    perl -MCwd -e 'print Cwd::abs_path(shift)' "$1"
}

wget --help >/dev/null 2>&1 
if [ $? == 0 ]; then
    HAVE_WGET=1
else
    HAVE_WGET=0
fi

TOOL_DIR="$(dirname $(readlink_nf "$0"))/.."
install_from_cpan="${TOOL_DIR}/install_from_cpan.pl"

#CPAN_DIR=
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

VERSION=0.5
perl=${PERL:-perl}
PRINT_USAGE=0
PRINT_HELP=0
PRINT_VERSION=0
DEBUG=0
QUIET=0
PREFIX=
TRED_DIR=
TRED_TARGET_DIR=
SYSTEM=0
USE_SVN=0
LIBS_ONLY=0
NO_LIBS=0
args=()
while [ $# -gt 0 ]; do
    case "$1" in
	-l|--libs-only) LIBS_ONLY=1; shift; ;;
	-n|--no-libs) NO_LIBS=1; shift; ;;
  -S|--svn) USE_SVN=1; shift; ;;
  -L|--local-dir) LOCAL_DIR=$(readlink_nf "$2"); shift 2; ;;
	-s|--system) SYSTEM=1; shift; ;;
	-P|--perl) perl=$(readlink_nf "$2"); shift 2; ;;
	-p|--prefix) PREFIX=$(readlink_nf "$2"); shift 2; ;;
	-T|--tred-dir) TRED_DIR=$(readlink_nf "$2"); shift 2; ;;
	-t|--tred-prefix) TRED_TARGET_DIR=$(readlink_nf "$2"); shift 2; ;;
#	-c|--cpan-dir) CPAN_DIR=$(readlink_nf "$2"); shift 2; ;;
	-D|--debug) DEBUG=1; shift ;;
	-q|--quiet) QUIET=1; shift ;;
	-u|--usage) PRINT_USAGE=1; shift ;;
	-h|--help) PRINT_HELP=1; shift ;;
	-v|--version) PRINT_VERSION=1; shift ;;
	--) shift ; break ;;
	-*) echo "Unknown command-line option: $1" ; exit 1 ;;
        *) args+=("$1"); shift ;;
    esac
done

eval set -- "${args[@]}"

usage () {
    echo "$0 version $VERSION" 
    cat <<USAGE
$0 [-h|--help]|[-u|--usage]|[-v|--version]
or
$0 [-D|--debug] [-q|--quiet] --prefix <lib_prefix> --tred-prefix <directory_for_tred> [<build_dir>]
USAGE
}

help () {
    echo "install_tred.sh version $VERSION" 
    usage
    cat <<HELP
  DESCRIPTION:

      This script fetches and installs TrEd and it's dependencies to
      given directory prefixes and creates wrapper scripts start_tred,
      start_btred, start_ntred with the apropriate environment
      variable setting.

  EXAMPLES:
      ./install_tred.bash --tred-dir ~/TrEd
          This installs:
            - TrEd into ~/TrEd/
            - C libraries to ~/TrEd/dependencies/lib/
            - Perl modules to ~/TrEd/dependencies/lib/perl5/
            - wrapper start_* scripts to ~/TrEd/
            Recommended for Mac OS X.

      ./install_tred.bash --tred-prefix ~
            - same as ./install_tred.bash --tred-dir ~/tred

      ./install_tred.bash --tred-dir /opt/tred --prefix /usr
          This installs:
            - TrEd into /opt/tred/
            - C libraries to /usr/lib/        (dangerous for Mac OS X)
            - Perl modules to /usr/lib/perl5/
            - wrapper start_* scripts to /usr/bin/

      ./install_tred.bash --tred-dir /opt/tred --system
          This installs:
            - TrEd into /opt/tred/
            - C libraries to /usr/lib/         (dangerous for Mac OS X)
            - Perl modules to $Config{installsitelib}
            - wrapper start_* scripts to /usr/bin/

      ./install_tred.bash --prefix /usr/local
          This installs:
            - TrEd into /usr/local/tred/
            - C libraries to /usr/local/lib/
            - Perl modules to /usr/local/lib/perl5/
            - start_*tred scripts to /usr/local/bin/

  OPTIONS:
      -P|--perl <executable>
          Use given exectuable as Perl interpreter instad of
          perl from PATH.

      -T|--tred-dir <tred_dir>
          install TrEd into the directory <dir>

      -t|--tred-prefix <dir>
          same as --tred-dir <dir>/tred/

      -p|--prefix <prefix>
          install dependencies under a given <prefix>
          (defaults to <tred_dir>/dependencies, where
          <tred_dir> is the path provided in --tred-dir)

      -l|--libs-only
          install only missing libraries/modules (do not install TrEd)

      -s|--system
          install to system paths (root only)

      -S|--svn
          install TrEd from SVN rather than from a released package.


      -L|--local-dir <dir>
          install TrEd from local directory.

      -h|--help    - print this help and exit
      -u|--usage   - print a short usage and exit
      -v|--version - print version and exit

      -D|--debug - turn on debugging output
      -q|--quiet - turn off informative messages


  AUTHOR:
      Copyright by pajas@ufal.mff.cuni.cz
HELP
}

if ! "$perl" -M5.008.003 -e1; then
    echo
    echo "Wrong Perl version (using $perl)!" 1>&2
    echo "Aborting: TrEd requires Perl >= v5.8.3" 1>&2
    exit 2;
fi

if [ "$PRINT_VERSION" = 1 ]; then echo Version: $VERSION; exit; fi
if [ "$PRINT_HELP" = 1 ]; then help; exit; fi
if [ "$PRINT_USAGE" = 1 ]; then usage; exit; fi

fetch_url () {
    if [ "$HAVE_WGET" == 1 ]; then
	echo "Fetching $1 into $2 using wget..."
	wget -O "$2" "$1"
    else
        echo "Fetching $1 into $2 using File::Fetch..."
        "$perl" -MFile::Fetch -e '
              ($url, $file) = @ARGV;
              $ff = File::Fetch->new(uri => $url);
              die "Error fetching $url\n" unless ref $ff;
              $res = $ff->fetch;
              die $ff->error unless defined $res and length $res;
              $target = $ff->output_file;
              if ($target ne $file) {
                rename $target, $file or die "Cannot rename: $!";
              }
        ' "$1" "$2"
    fi
}


if !([ "x$SYSTEM" = x1 ] && [ "x$LIBS_ONLY" = x1 ]) && [ -z "$PREFIX" ] && [ -z "$TRED_TARGET_DIR" ] && [ -z "$TRED_DIR" ]; then
    cat <<EOF 1>&2
Do not know where to install: please specify install target dir with --tred-dir!
Note: at least parent directories must exist!

EOF
    usage;
    exit 3;
elif [ -n "$TRED_DIR" ] && [ -n "$TRED_TARGET_DIR" ]; then
    cat <<EOF 1>&2
Cannot specify both --tred-prefix and --tred-dir!

EOF
    usage;
    exit 3;
fi

if [ x`uname -s` == xDarwin ] && ( [ "x$PREFIX" == x/usr ] || [ "x$SYSTEM" = x1 ] ); then
    echo The installation script is going to rewrite system libraries.  >&2 
    echo -n 'Are you sure to proceed? (y/n) ' >&2
    until [ x$answer == xy ] || [ x$answer = xn ] ; do
        read answer
    done
    if [ x$answer == xn ] ; then exit 3 ; fi
fi

TRED_BUILD_DIR="$1"
remove_build_dir=0

if [ "x$SYSTEM" = x1 ] && [ "x$LIBS_ONLY" = x1 ] && [ -z "$PREFIX" ] && [ -z "$TRED_TARGET_DIR" ] && [ -z "$TRED_DIR" ]; then
   if [ -z "$TRED_BUILD_DIR" ]; then
      TRED_BUILD_DIR=$(mktemp -d)
      TRED_DIR="/usr/local"
      remove_build_dir=1
   else
      TRED_DIR="$TRED_BUILD_DIR"
   fi
fi

if [ -n "$TRED_TARGET_DIR" ]; then
    TRED_DIR="${TRED_TARGET_DIR}/tred"
fi

if [ -z "$PREFIX" ]; then
    if [ "x$SYSTEM" != x1 ]; then
	PREFIX="${TRED_DIR}/dependencies"
    fi
    RUN_TRED_DIR="${TRED_DIR}/bin"
elif [ -z "$TRED_DIR" ]; then
    TRED_TARGET_DIR="$PREFIX"
    TRED_DIR="${TRED_TARGET_DIR}/tred"
    RUN_TRED_DIR="${PREFIX}/bin"
else
    RUN_TRED_DIR="${PREFIX}/bin"
fi


echo PREFIX: "$PREFIX"
if [ ! "x$LIBS_ONLY" = "x1" ]; then
    echo TRED_DIR: "$TRED_DIR"
fi
echo RUN_TRED_DIR: "$RUN_TRED_DIR"

ACTION=""
fail () {
    echo "$ACTION failed: aborting!" 1>&2
    exit 3;
}

if [ "x$USE_SVN" = x1 ]; then
    ACTION="Testing that 'svn' command works..."
    svn help >/dev/null 2>&1 || fail
fi

action () {
    ACTION="$@"
    echo "*** $ACTION ..." 1>&2
}

if [ -n "$TRED_BUILD_DIR" ]; then
    TRED_BUILD_DIR=$(readlink_nf "$TRED_BUILD_DIR")
else
    TRED_BUILD_DIR="$TRED_DIR/.build"
    remove_build_dir=1
fi

action "Preparing build directory $TRED_BUILD_DIR"
[ -d "$TRED_BUILD_DIR" ] || mkdir -p "$TRED_BUILD_DIR" || fail

pushd "$TRED_BUILD_DIR"

if [ "x$LIBS_ONLY" = x1 ]; then
    echo "Skipping TrEd installation (--libs-only)"
elif [ "x$USE_SVN" = x1 ]; then
    [ -d "$TRED_DIR" ] || mkdir -p "$TRED_DIR" || fail
    pushd "$TRED_DIR"
    if [ -d .svn ]; then
	echo
	echo "Found ${TRED_DIR}/.svn, trying SVN Update"
	action "Updating existing working copy of TrEd from SVN"
	svn up || fail
    else
	action "Checking out TrEd from SVN"
	svn co "$tred_svn" . || fail
    fi
    popd
elif [ ! -z "$LOCAL_DIR" ]; then
    cd "$LOCAL_DIR"
    tred_tar_gz="$PWD/tred-current.tar.gz"
    action  "Unpacking TrEd to $TRED_DIR"
    [ -d "$TRED_DIR" ] || mkdir -p "$TRED_DIR" || fail
    pushd "$TRED_DIR"
    mkdir _tmp ||fail
    pushd _tmp ||fail
    tar xzf "$tred_tar_gz" || fail
    popd
    mv _tmp/tred/* . || fail
    rm -rf _tmp || fail
    popd
    rm "$tred_tar_gz"  
else
    action "Downloading TrEd"
    fetch_url "$tred_url" tred-current.tar.gz|| fail
    tred_tar_gz="$PWD/tred-current.tar.gz"
    action  "Unpacking TrEd to $TRED_DIR"
    [ -d "$TRED_DIR" ] || mkdir -p "$TRED_DIR" || fail
    pushd "$TRED_DIR"
    mkdir _tmp ||fail
    pushd _tmp ||fail
    tar xzf "$tred_tar_gz" || fail
    popd
    mv _tmp/tred/* . || fail
    rm -rf _tmp || fail
    popd
    rm "$tred_tar_gz"
fi

action "Creating directory for start scripts: $RUN_TRED_DIR"
mkdir -p "$RUN_TRED_DIR" || fail

if [ "x$NO_LIBS" != x1 ]; then

    action  "Downloading TrEd dependencies"
    fetch_url "$tred_dep" tred-dep-unix.tar.gz || fail
    
    action  "Unpacking TrEd dependencies"
    tar xzf tred-dep-unix.tar.gz || fail
    rm tred-dep-unix.tar.gz
    pushd packages_unix

    if [ -n "$PREFIX" ] && [ ! -d "$PREFIX" ]; then
	action  "Creating $PREFIX"
	mkdir -p "$PREFIX" || fail
    fi

    action  "Installing TrEd dependencies"    
    mkdir -p "$TRED_BUILD_DIR/tmp"
    inst_opts=(--tmp "$TRED_BUILD_DIR/tmp")
    if [ -n "$PREFIX" ]; then 
	inst_opts+=(--prefix "$PREFIX")
    fi
    if [ "x$SYSTEM" != x1 ]; then
	inst_opts+=(-b)
    fi

    "$perl" install --check-utils "${inst_opts[@]}" || fail
    
    set -o pipefail
    "$perl" install --quiet "${inst_opts[@]}" 2>&1 | tee "${TRED_DIR}/install.log" || fail

    cat <<EOF > "$RUN_TRED_DIR"/init_tred_environment
# Setup paths for installed TrEd dependencies
export TRED_DIR="${TRED_DIR}"
EOF
    if [ -n "$PREFIX" ]; then
	cat <<EOF >> "$RUN_TRED_DIR"/init_tred_environment
export TRED_DEPENDENCIES="${PREFIX%/}"
PATH="\${TRED_DEPENDENCIES}/bin:\${PATH}"
EOF
   fi
    "$perl" install --bash-env "${inst_opts[@]}" | sed "s|${PREFIX}|\${TRED_DEPENDENCIES}|g" \
	>> "$RUN_TRED_DIR"/init_tred_environment

    popd >/dev/null # packages-unix
fi

popd >/dev/null # "$TRED_BUILD_DIR"

if [ "x$remove_build_dir" = x1 ]; then
    echo "Removing temporary build dir: $TRED_BUILD_DIR"
    rm -fr "$TRED_BUILD_DIR"
fi

if [ "x$LIBS_ONLY" != x1 ]; then

    for cmd in tred btred ntred; do
	echo "Creating start script for $cmd:"  "$RUN_TRED_DIR"/"start_$cmd"
	cat <<EOF > "$RUN_TRED_DIR"/"start_$cmd"
#!/bin/sh

. "\$(dirname "\$("$perl" -MCwd -e 'print Cwd::abs_path(shift)' \$0)")/init_tred_environment"
"$perl" "\${TRED_DIR}/${cmd}" "\$@"
EOF
        chmod 755 "$RUN_TRED_DIR"/"start_$cmd"
    done
    if [ "x$USE_SVN" = x1 ]; then
	echo
	echo "Creating script ${RUN_TRED_DIR}/upgrade_tred"
	cat <<EOF > "$RUN_TRED_DIR"/"upgrade_tred"
#!/bin/bash
. "\$(dirname "\$("$perl" -MCwd -e 'print Cwd::abs_path(shift)' \$0)")/init_tred_environment"
if [ -n "$TRED_DIR" ] && [ -n "$TRED_DEPENDENCIES" ]; then
  cd "$TRED_DIR" || exit 1
  svn up || exit 2
  bash devel/unix_install/install_tred.bash --libs-only --tred-dir "\$TRED_DIR" --prefix "\$TRED_DEPENDENCIES" "$@" || exit 3
else
  echo "Error: init_tred_environment failed to set up TRED_DIR and TRED_DEPENDENCIES paths, aborting!"
  exit 1
fi
EOF
        chmod 755 "$RUN_TRED_DIR"/"upgrade_tred"
    fi

fi


echo
echo "NOTE: The installation of dependencies is logged in ${TRED_DIR}/install.log"
echo
echo
echo "************************************************************"
echo "*             INSTALLATION IS NOW COMPLETE                 *"
echo "************************************************************"
echo
echo
echo "You can type ${RUN_TRED_DIR}/start_tred to start TrEd."
echo
