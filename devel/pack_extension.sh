#!/bin/bash

package_dir=$1
target_dir=$2
tooldir=`dirname $(readlink -fen $0)`

function make_zip () {
    z="$1"
    d="$2"
    pushd "$d";
    if [ $? != 0 ]; then
	echo "Cannot change dir to $d !"
	exit 6;
    fi
    rm -f "$z"
    
    if 
	! zip -9 \
	    "${z}" \
	    `find -L -not -wholename "*/.svn*"` \
	    -x '*~' \
	    -x '#*' 
	
    then
	echo "Failed to create package $z!"
	exit 6;
    fi
    popd
}


if [ -z "$package_dir" ]; then
    echo "Usage: $0 <path_to_/package_dir> [target_dir]"
    echo "Creates package_dir.zip from the given package_dir in the target (or current) directory"
    exit 1;
fi

if [ -z "$target_dir" ]; then
    target_dir=.
fi

name=`basename $package_dir`

if [ ! -d "$package_dir" ]; then
    echo "Didn't find package directory $target_dir"
    exit 2;
fi
if [ ! -d "$target_dir" ]; then
    echo "Didn't find target directory $target_dir"
    exit 3;
fi

meta="$package_dir/package.xml"
if [ ! -r "$meta" ]; then
    echo "Didn't find package meta file in $meta"
    exit 4;
fi

if ! validate_pml_stream -p "$tooldir/../resources" "$meta"; then
    echo "Package meta file $meta is not a valid PML tred_package instance!"
    exit 5;
fi

zip="$(readlink -fen "$target_dir")/${name}.zip"

if [ -f "$target_dir/${name}/package.xml" ]; then

    if [ -f "${zip}" ]; then
	zipmd5=`md5sum "$zip" |cut -f1 -d' '`
	make_zip "${zip}.tmp" "$package_dir" >/dev/null
	zipmd5_tmp=`md5sum "${zip}.tmp" |cut -f1 -d' '`
	rm -f "${zip}.tmp";
	if [ "$zipmd5" = "$zipmd5_tmp" ]; then
	    echo PACKAGE "$zip" IS UP-TO-DATE
	    exit;
	fi
    fi

    script='print $1 if m{<version>([0-9.]+)</version>}'
    prev_ver=`perl -ne "$script" "$target_dir/$name/package.xml" /dev/null`
    pkg_ver=`perl -ne "$script" "$meta"`

    if [[ -n "$prev_ver" && -n "$pkg_ver" && "$prev_ver" != "$pk_ver" ]]; then
	echo UPGRADING PACKAGE VERSION IN "$meta"
	perl -pi~ -e 's{(<version>(?:\d+\.)*)(\d+)(</version>)}{$1.($2+1).$3}e' "$meta"
    fi

fi

shopt -s nullglob
if [ ! -d "$target_dir"/"$name" ]; then
    mkdir "$target_dir"/"$name"
fi
cp "$meta" "$target_dir/$name"

echo Creating "$zip"
make_zip "$zip" "$package_dir"


ext_list="$target_dir/extensions.lst"
if ! [ -f "$ext_list" ] || ! grep -Eq "^\!?$name *\$" "$ext_list"; then
    echo "Adding $name to $ext_list"
    echo "$name" >> "$ext_list";
fi

echo "Package $zip successfully created!"
