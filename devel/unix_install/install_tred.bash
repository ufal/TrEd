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

tred_url="http://ufal.mff.cuni.cz/~pajas/tred/tred-current.tar.gz"
tred_dep="http://ufal.mff.cuni.cz/~pajas/tred/tred-dep-unix.tar.gz"

TOOL_DIR="$(dirname $(readlink -f "$0"))/.."
install_from_cpan="${TOOL_DIR}/install_from_cpan.pl"

CPAN_DIR=
PARSED_OPTS=$(
  getopt -n 'install_tred.sh' --shell bash \
    -o Dqhuvptcs \
    -l system \
    -l prefix: \
    -l tred-prefix: \
    -l cpan-dir: \
    -l debug \
    -l quiet \
    -l help \
    -l usage \
    -l version \
  -- "$@"
)

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$PARSED_OPTS"

VERSION=0.1
PRINT_USAGE=0
PRINT_HELP=0
PRINT_VERSION=0
DEBUG=0
QUIET=0
PREFIX=
TRED_TARGET_DIR=
SYSTEM=0
while true ; do
    case "$1" in
	-s|--system) SYSTEM=1; shift; ;;
	-p|--prefix) PREFIX="$2"; shift 2; ;;
	-t|--tred-prefix) TRED_TARGET_DIR="$2"; shift 2; ;;
	-c|--cpan-dir) CPAN_DIR="$2"; shift 2; ;;
	-D|--debug) DEBUG=1; shift ;;
	-q|--quiet) QUIET=1; shift ;;
	-u|--usage) PRINT_USAGE=1; shift ;;
	-h|--help) PRINT_HELP=1; shift ;;
	-v|--version) PRINT_VERSION=1; shift ;;
#	-o|--output) OUTPUT="$2"; shift 2 ; break ;;
#	-x|--extra) EXTRA="$2";  # will be "" if argument omitted
#          	    shift 2 ;;
	--) shift ; break ;;
	*) echo "Internal error while processing command-line options!" ; exit 1 ;;
    esac
done

usage () {
    echo "$0 version $VERSION" 
    cat <<USAGE
$0 [-h|--help]|[-u|--usage]|[-v|--version]
or
$0 [-D|--debug] [-q|--quiet] --prefix <lib_prefix> --tred-prefix <prefix_for_tred> [<build_dir>]
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
      ./install_tred --tred-prefix ~
          This installs:
            - TrEd into ~/tred/
            - C libraries to ~/dependencies/lib/
            - Perl modules to ~/tred/dependencies/lib/perl5/
            - wrapper start_* scripts to ~/tred/

      ./install_tred --tred-prefix /opt --prefix /usr
          This installs:
            - TrEd into /opt/tred/
            - C libraries to /usr/lib/
            - Perl modules to /usr/lib/perl5/
            - wrapper start_* scripts to /usr/bin/

      ./install_tred --tred-prefix /opt --system
          This installs:
            - TrEd into /opt/tred/
            - C libraries to /usr/lib/
            - Perl modules to $Config{installsitelib}
            - wrapper start_* scripts to /usr/bin/

      ./install_tred --prefix /usr/local
          This installs:
            - TrEd into /usr/local/tred/
            - C libraries to /usr/local/lib/
            - Perl modules to /usr/local/lib/perl5/
            - start_*tred scripts to /usr/local/bin/

  OPTIONS:
      -t|--tred-prefix <dir>
          install TrEd into the subdirectory <dir>/tred/

      -p|--prefix <prefix>
          install dependencies under a given <prefix>
          (defaults to <dir>/tred/dependencies, where
          <dir> is the path provided as --tred-prefix)

      -h|--help    - print this help and exit
      -u|--usage   - print a short usage and exit
      -v|--version - print version and exit

      -D|--debug - turn on debugging output
      -q|--quiet - turn off informative messages


  AUTHOR:
      Copyright by pajas@ufal.mff.cuni.cz
HELP
}

if [ "$PRINT_VERSION" = 1 ]; then echo Version: $VERSION; exit; fi
if [ "$PRINT_HELP" = 1 ]; then help; exit; fi
if [ "$PRINT_USAGE" = 1 ]; then usage; exit; fi

if [ -z "$PREFIX" ] && [ -z "$TRED_TARGET_DIR" ]; then
    cat <<EOF 1>&2
Do not know where to install: please specify a prefix (--prefix)!

EOF
    usage;
    exit 3;
elif [ -z "$PREFIX" ]; then
    if [ "x$SYSTEM" = x1 ]; then
	RUN_TRED_DIR="${TRED_TARGET_DIR}/tred"
    else
	PREFIX="${TRED_TARGET_DIR}/tred/dependencies"
	RUN_TRED_DIR="${TRED_TARGET_DIR}/tred"
    fi
elif [ -z "$TRED_TARGET_DIR" ]; then
    TRED_TARGET_DIR="$PREFIX"
    RUN_TRED_DIR="${PREFIX}/bin"
else
    RUN_TRED_DIR="${PREFIX}/bin"
fi

TRED_DIR="${TRED_TARGET_DIR}/tred"

echo PREFIX: "$PREFIX"
echo TRED_TARGET_DIR: "$TRED_TARGET_DIR"
echo TRED_DIR: "$TRED_DIR"

ACTION=""
fail () {
    echo "$ACTION failed: aborting!" 1>&2
    exit 3;
}

action () {
    ACTION="$@"
    echo "*** $ACTION ..." 1>&2
}

TRED_BUILD_DIR="$1"
remove_build_dir=0
if [ -z "$TRED_BUILD_DIR" ]; then
    TRED_BUILD_DIR="$TRED_DIR/.build"
    remove_build_dir=1
fi

action "Preparing build directory $TRED_BUILD_DIR"
[ -d "$TRED_BUILD_DIR" ] || mkdir -p "$TRED_BUILD_DIR" || fail

pushd "$TRED_BUILD_DIR"

action "Downloading TrEd"
wget -O tred-current.tar.gz "$tred_url" || fail
tred_tar_gz="$PWD/tred-current.tar.gz"

action  "Unpacking TrEd to $TRED_DIR"
[ -d "$TRED_TARGET_DIR" ] || mkdir -p "$TRED_TARGET_DIR" || fail
pushd "$TRED_TARGET_DIR"
tar xzf "$tred_tar_gz" || fail
popd
rm tred-current.tar.gz

action  "Downloading TrEd dependencies"
wget -O tred-dep-unix.tar.gz "$tred_dep"  || fail

action  "Unpacking TrEd dependencies"
tar xzf tred-dep-unix.tar.gz || fail
rm tred-dep-unix.tar.gz

pushd packages_unix

if [ ! -d "$PREFIX" ]; then
    action  "Creating $PREFIX"
    mkdir -p "$PREFIX" || fail
fi

action  "Installing TrEd dependencies"

inst_opts=(--tmp "$TRED_BUILD_DIR/tmp")
if [ -n "$PREFIX" ]; then 
    inst_opts+=(--prefix "$PREFIX")
fi

./install --check-utils "${inst_opts[@]}" || fail

./install -b "${inst_opts[@]}" 2>&1 | tee "${TRED_DIR}/install.log"

cat <<EOF > "$RUN_TRED_DIR"/init_tred_environment
# Setup paths for installed TrEd dependencies
export TRED_DIR="${TRED_TARGET_DIR}/tred"
PATH="${PREFIX%/}/bin:\${PATH}"
EOF
./install --bash-env "${inst_opts[@]}" >> "$RUN_TRED_DIR"/init_tred_environment

popd >/dev/null # packages-unix

popd >/dev/null # "$TRED_BUILD_DIR"

if [ "x$remove_build_dir" = x1 ]; then
    echo "Removing temporary build dir: $TRED_BUILD_DIR"
    rm -fr "$TRED_BUILD_DIR"
fi

for cmd in tred btred ntred; do
    cat <<EOF > "$RUN_TRED_DIR"/"start_$cmd"
#!/bin/sh

. "\$(dirname "\$(readlink -f \$0)")/init_tred_environment"
"\${TRED_DIR}/${cmd}" "\$@"
EOF
    chmod 755 "$RUN_TRED_DIR"/"start_$cmd"
done

echo "Note: all stdout+stderr output from the installation of dependencies is captured in ${TRED_TARGET_DIR}/tred/install.log"
