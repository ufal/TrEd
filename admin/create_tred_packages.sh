#!/bin/bash

if [ "x$1" = "x-h" -o $# = 0 ]; then
    echo "Usage: $0 source-dir win32-dir dest-dir [version]"
    echo
    echo "Example: $0 /net/work/projects/tred/dist /net/work/projects/tred/win32_install /home/pajas/WWW/tred"
    exit 1;
fi

ulimit -s 8192 # for 7zip

REPO="https://svn.ms.mff.cuni.cz/svn/TrEd/trunk"

DIR="$1"
WININST="$2"
WWW="$3"

SFX=$(dirname $0)/7zExtra/7zS.sfx

if [ -z "$VER" ]; then
    VER=`$DIR/tred/devel/update_version.pl -n`
fi

cd "$DIR"
echo $VER;
PKG="tred-${VER}.tar.gz"
WINPKG="tred_wininst_${VER}"
DATE="$(LANG=C date)"

# update revision numbers in tred and btred
perl -pi -e 's/our \$VERSION = "SVN_VERSION"/our \$VERSION = "'$VER'"/g' tred/tredlib/TrEd/Version.pm

perl -pi~ -e "s/tred-(?:current|[0-9.]+?)\\.tar\\.gz/${PKG}/g; s/tred_wininst_(?:en|[0-9.]+?)((?:_noAP|_small)?\\.(?:exe|7z))/${WINPKG}\$1/g; s/Current version:.*</Current version: ${VER} (release date ${DATE})</g" ${WWW}/index.html

shopt -s extglob

# create source tar.gz package
tar czhf "${WWW}/${PKG}" tred
chmod 664 "${WWW}/${PKG}"

opts_7zip="-m0=BCJ2 -m1=LZMA:d25:fb255 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3 -mx"

# cleanup
rm -f "${WWW}/${WINPKG}_noAP.7z";
rm -f "${WWW}/${WINPKG}_noAP.exe";
rm -f "${WWW}/${WINPKG}_small.7z";
rm -f "${WWW}/${WINPKG}_small.exe";
rm -f "${WWW}/${WINPKG}.7z";
rm -f "${WWW}/${WINPKG}.exe";

function append_package() {
    eval "extra_opts=($1)"; shift
    package="$1"; shift
    7za a -l '-xr!.svn' "${extra_opts[@]}" $opts_7zip \
	-t7z "${package}.7z" "$@"
    cat "$SFX" "$DIR"/tred/devel/winsetup/sfx.cfg "${package}.7z" > "${package}.exe"    
    chmod 664 "${package}.7z" "${package}.exe"
}

# create Win32 packages
cd "${WININST}"

append_package "'-xr!*::*' '-xr!ActivePerl*.msi'" "${WWW}/${WINPKG}_small" !(packages_unix|extensions|backup)

cp "${WWW}/${WINPKG}_small.7z" "${WWW}/${WINPKG}_noAP.7z";
append_package '' "${WWW}/${WINPKG}_noAP" extensions;

cp "${WWW}/${WINPKG}_noAP.7z" "${WWW}/${WINPKG}.7z";
append_package '' "${WWW}/${WINPKG}" activeperl58_win32;

# update download sizes on the web-page
perl -pi~ -e "s{\(SIZE_OF:(.*?)\)}{ my \$file='${WWW}/'.\$1; my (\$size)=split /\\s/,\`du --si \$file\`,2; '('.\$size.')'}eg;" ${WWW}/index.html

# links
cd "${WWW}"
rm -f tred-current.tar.gz
ln "${PKG}" tred-current.tar.gz
rm -f tred_wininst_en.exe
rm -f tred_wininst_en.7z
ln "${WINPKG}.7z" tred_wininst_en.7z
ln "${WINPKG}.exe" tred_wininst_en.exe
