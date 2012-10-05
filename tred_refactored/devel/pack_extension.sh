#!/bin/bash

#PATH=$PATH:/net/work/projects/pml/toolkit/bin:/home/pajas/bin

package_dir=$1
target_dir=$2
tooldir=`dirname $(readlink -fen $0)`

function make_zip () {
    z="$1"
    d="$2"
    pushd "$d" > /dev/null
    if [ $? != 0 ]; then
	echo "Cannot change dir to $d !"
	exit 6;
    fi
    rm -f "$z"
    
    touch "$z"
    if 
	! zip -9 \
	    "${z}.part" \
	    `find -L -not -wholename "*/.svn*"` \
	    -x '*~' \
	    -x '#*' 	
    then
	rm "$z"
	rm "${z}.part"
	echo "Failed to create package $z!"
	exit 6;
    fi
    chmod --reference="$z" "${z}.part"
    mv "${z}.part" "$z"
    popd > /dev/null
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

icon=`perl -ne 'print $1 if m{<icon>([^<]+)</icon>}' "$meta" /dev/null`
echo "Icon $icon"


size=
s=`du -sb --exclude '*/.svn*' --exclude '*~' --exclude '#*' "$package_dir"|cut -f1`
while [ $s != "$size" ]; do
    size=$s
    echo "Updating package size to: $size"
perl -MXML::LibXML -e '
  ($f,$size)=@ARGV;
  $p=XML::LibXML->new->parse_file($f);
  if ($p->documentElement->getAttribute("install_size")!=$size) {
    $p->documentElement->setAttribute("install_size","$size");
    rename $f, $f."~";
    $p->toFile($f);
  }
' "$meta" $size;
  s=`du -sb --exclude '*/.svn*' --exclude '*~' --exclude '#*' "$package_dir"|cut -f1`
done


if which pml_validate 2>/dev/null && pml_validate -c; then 
    if ! pml_validate -p "$tooldir/../resources" "$meta"; then
	which pml_validate
	echo pml_validate -p "$tooldir/../resources" "$meta"
	echo "Package meta file $meta is not a valid PML tred_package instance!"
	exit 5;
    fi
else 
    echo "WARNING: will not validate package.xml (PML validator pml_validate not found in PATH or not working)"
fi

zip="$(readlink -fen "$target_dir")/${name}.zip"

if [ -f "$target_dir/${name}/package.xml" ]; then

    if [ -f "${zip}" ]; then
	tmp_dir=`mktemp -d`
	if [ ! -d "$tmp_dir" ]; then
	    echo "FAILED to create a temporary dir; exiting"
	    exit 100;
	fi
	
	mkdir "$tmp_dir/orig" || exit 100;
	pushd "$tmp_dir/orig" > /dev/null || exit 100;
	unzip "$zip" > /dev/null
	sed -i 's, install_size="[0-9]*",,g' package.xml
	popd > /dev/null

	make_zip "$tmp_dir/new.zip" "$package_dir" >/dev/null

	mkdir "$tmp_dir/new" || exit 100;
	pushd "$tmp_dir/new" > /dev/null || exit 100;
	unzip "$tmp_dir/new.zip" > /dev/null
	sed -i 's, install_size="[0-9]*",,g' package.xml
	popd > /dev/null

	up_to_date=1
	if diff -Nur "$tmp_dir/orig" "$tmp_dir/new" |grep -q .; then
	    up_to_date=0;
	fi
	rm -rf "$tmp_dir"	
	if [ $up_to_date = 1 ]; then
	    echo PACKAGE "$zip" IS UP-TO-DATE
	    exit;	    
	fi
	#zipmd5=`md5sum "$zip" |cut -f1 -d' '`
	#zipmd5_tmp=`md5sum "${zip}.tmp" |cut -f1 -d' '`
# 	rm -f "${zip}.tmp";
	

# 	if [ "$zipmd5" = "$zipmd5_tmp" ]; then
# 	    echo PACKAGE "$zip" IS UP-TO-DATE
# 	    exit;
# 	fi
	
    fi

# Disable upgrading package version. Versions are managed by maintainers only!
#    script='print $1 if m{<version>([0-9.]+)</version>}'
#    prev_ver=`perl -ne "$script" "$target_dir/$name/package.xml" /dev/null`
#    pkg_ver=`perl -ne "$script" "$meta"`
#    if [[ -n "$prev_ver" && -n "$pkg_ver" && "$prev_ver" != "$pk_ver" ]]; then
#	echo UPGRADING PACKAGE VERSION IN "$meta"
#	perl -pi~ -e 's{(<version>(?:\d+\.)*)(\d+)(</version>)}{$1.($2+1).$3}e' "$meta"
 #   fi

fi

shopt -s nullglob
if [ ! -d "$target_dir"/"$name" ]; then
    mkdir "$target_dir"/"$name"
fi
cp "$meta" "$target_dir/$name"

if [ -f "$name/$icon" ]; then
    echo "Copying icon $name/$icon"
    cp --parents "$name/$icon" "$target_dir"
fi

if [ -d "$name/documentation" ]; then
    echo "Copying documentation $name/$icon"
    cp -r "$name/documentation" "$target_dir/$name"
fi

echo Creating "$zip"
make_zip "$zip" "$package_dir"

zip_size=`du -sb "$zip"|cut -f1`
echo "Zip size: $zip_size"
perl -MXML::LibXML -e '
  $f=shift;
  print "File: $f\n";
  $p=XML::LibXML->new->parse_file($f);
  $p->documentElement->setAttribute("package_size","'$zip_size'");
  $p->toFile($f);
' "$target_dir/$name/package.xml"

ext_list="$target_dir/extensions.lst"
if ! [ -f "$ext_list" ] || ! grep -Eq "^\!?$name *\$" "$ext_list"; then
    echo "Adding $name to $ext_list"
    echo "$name" >> "$ext_list";
fi

echo "Package $zip successfully created!"
