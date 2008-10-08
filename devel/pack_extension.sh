#!/bin/bash

package_dir=$1
target_dir=$2
tooldir=`dirname $(readlink -fen $0)`

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
    echo 4;
fi

if ! validate_pml_stream -p "$tooldir/../resources" "$meta"; then
    echo "Package meta file $meta is not a valid PML tred_package instance!"
    echo 5;
fi

script='print $1 if m{<version>([0-9.]+)</version>}'
prev_ver=`perl -ne "$script" "$target_dir/$name/package.xml" /dev/null`
pkg_ver=`perl -ne "$script" "$meta"`

if [[ -n "$prev_ver" && -n "$pkg_ver" && "$prev_ver" != "$pk_ver" ]]; then
  echo UPGRADING PACKAGE VERSION IN "$meta"
  perl -pi~ -e 's{(<version>(?:\d+\.)*)(\d+)(</version>)}{$1.($2+1).$3}e' "$meta"
fi

shopt -s nullglob
if [ ! -d "$target_dir"/"$name" ]; then
    mkdir "$target_dir"/"$name"
fi
cp "$meta" "$target_dir/$name"

zip="$(readlink -fen "$target_dir")/${name}.zip"
echo Creating "$zip"
pushd "$package_dir";
if [ $? != 0 ]; then
    echo "Cannot change dir to $package_dir !"
    echo 6;
fi

rm -f "$zip"

if 
 ! zip -9 \
  "${zip}" \
  `find -L -not -wholename "*/.svn*"` \
  -x '*~' \
  -x '#*' 

then
    echo "Failed to create package $zip!"
    echo 6;
fi
popd

ext_list="$target_dir/extensions.lst"
if ! [ -f "$ext_list" ] || ! grep -Eq "^\!?$name *\$" "$ext_list"; then
    echo "Adding $name to $ext_list"
    echo "$name" >> "$ext_list";
fi

echo "Package $zip successfully created!"
