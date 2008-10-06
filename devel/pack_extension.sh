#!/bin/bash

package_dir=$1
target_dir=$2
tooldir=`dirname $0`

if [ -z "$package_dir" ]; then
    echo "Usage: $0 <path_to_/package_dir> [target_dir]"
    echo "Creates package_dir.zip from the given package_dir in the target (or current) directory"
    exit 1;
fi

if [ -z "$dir" ]; then
    target_dir=.
fi

name=`basename $package_dir`

if [ ! -d "$package_dir" ]; then
    echo "Didn't find package directory $dir"
    exit 2;
fi
if [ ! -d "$target_dir" ]; then
    echo "Didn't find target directory $dir"
    exit 3;
fi

meta="$package_dir/package.xml"
if [ ! -r "$meta" ]; then
    echo "Didn't find package meta file in $package_dir/$meta"
    echo 4;
fi

if ! validate_pml_stream -p "$tooldir/../resources" "$package_dir/$meta"; then
    echo "Package meta file $package_dir/$meta is not a valid PML tred_package instance!"
    echo 5;
fi
  
shopt -s nullglob
zip="$(readlink -fen "$target_dir")/${name}.zip"
echo Creating "$zip"
cd "$package_dir";
if [ $? != 0 ]; then
    echo "Cannot change dir to $package_dir !"
    echo 6;
fi

rm -f "$zip"

if 
 ! zip -r -9 \
  "${zip}" \
  * \
  -x '*~' -x '#*' -x '.svn' -x '*.svn-base' 
then
    echo "Failed to create package $zip!"
    echo 6;
fi

ext_list="$target_dir/extensions.lst"
if [ -f "$ext_list" ] || ! grep -q "^$package_name *\$" "$ext_list"; then
    echo "Adding $name to $ext_list"
    echo "$name" >> "$ext_list";
fi

echo "Package $zip successfully created!"
