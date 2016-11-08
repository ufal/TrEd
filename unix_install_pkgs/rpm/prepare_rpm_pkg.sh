#!/bin/bash


# Prepare complete directory structure for rpmbuild and copy selected spec file in.
# Arg #1: path to root dir of the rmp workplace
# Arg #2: path to spec file to be copied into the workplace
function prepare_rpmdir() {
	if [ -z "$1" -o ! -f "$2" ]; then
		exit 1
	fi

	echo "Preparing rpm working place ..."
	rm -rf "$1"
	for SUB in BUILD BUILDROOT RPMS SOURCES SPECS SRPMS ; do
		mkdir -p "$1/$SUB"
	done

	cp "$2" "$1/SPECS/tred.spec"
}


# Build the rmp package.
# Arg #1: path to root dir of the rmp workplace
# Arg #2: name of the distro (i.e., 'fedora', 'rhel', ...)
# Arg #3: SVN version number
function build_rpm() {
	echo "Building rpm package ..."
	TRED_SPEC_FILE="$1/SPECS/tred.spec"
	sed -i "s/%SVNVERSION%/$3/g" "$TRED_SPEC_FILE" || exit 1
	rpmbuild -bb --define "_topdir $1" --define "TREDNET $TREDNET" --define "TREDWWW $TREDWWW" "$TRED_SPEC_FILE" || exit 2
	mv "$1/RPMS/noarch/tred-2-$3.noarch.rpm" "./tred-2-$3-$2.noarch.rpm" || exit 3
}


SAVE_DIR=`pwd`
cd `dirname "$0"` || exit 1

# Initialization
SVN_VERSION=`svn info . | grep 'Revision:' | sed -E 's/[^0-9]+//g'`

rm ./*.rpm

TRED_RPM_DIR=`pwd`/tmp
[ ! -z "$TRED_RPM_DIR" ] || exit 2
if [ -d "$TRED_RPM_DIR" ]; then
	rm -rf "$TRED_RPM_DIR"
fi


# Build rpm for every spec file in the specs dir ...
ls -1 ./specs/tred.spec.* | sed 's/^.*[.]//' | while read DISTRO; do
	echo "Preparing RPM package for $DISTRO ..."
	prepare_rpmdir "$TRED_RPM_DIR" "./specs/tred.spec.$DISTRO" || exit 1
	build_rpm "$TRED_RPM_DIR" "$DISTRO" "$SVN_VERSION" || exit 2
done


# Cleanup
echo "Cleaning up ..."
rm -rf "$TRED_RPM_DIR"
cd "$SAVE_DIR"
