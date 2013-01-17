#!/bin/bash

# Paths
TESTBED_WEB=/var/www/tred/testbed
PUBLIC_WEB=ufal.mff.cuni.cz:/home/www/html/tred
LOCAL_COPY=./.release

# Patching
OLD_URL='http://ufallab.ms.mff.cuni.cz:24080/tred/testbed'
NEW_URL='http://ufal.mff.cuni.cz/tred'
PATCH_FILES='install_tred.bash documentation/ar01s02.html'

# Checklists
CHECK_DIRS='documentation extensions releases'
CHECK_FILES='changelog.rss index.html index.html~ install_tred.bash tred-current.tar.gz tred-dep-unix.tar.gz tred.dmg tred-installer.exe tred-installer-perl-included.exe tred-portable.7z documentation/ar01s02.html'


# Check wheter given file or dir exists in testbed web dir.
# Expects two arguments: type of test (-f or -d) and file/dir name.
function check_existence() {
	if [ ! "$1" "$TESTBED_WEB/$2" ]; then
		echo "$TESTBED_WEB/$2 is missing! The release is incomplete!"
		exit 1
	fi
}


# Verify that the release is (moreless) complete.
for DIR in $CHECK_DIRS; do
	check_existence -d "$DIR"
done

for FILE in $CHECK_FILES; do
	check_existence -f "$FILE"
done


# Make sure we are in the same directory as the script file.
SAVE_DIR=`pwd`
cd `dirname $0` || exit 1


# Create local copy of the release.
echo "Making a local copy of the release ..."
if ! mkdir "$LOCAL_COPY"; then
	echo "Unable create $LOCAL_COPY directory ..."
	cd "$SAVE_DIR"
	exit 2
fi

if ! cp -R $TESTBED_WEB/* "$LOCAL_COPY"; then
	cd "$SAVE_DIR"
	exit 2
fi


# Patch local copy (URLs)
echo "Replacing '$OLD_URL' with '$NEW_URL' ..."
OLD_URL=`echo $OLD_URL | sed s/[.]/[.]/g`

for PATCH_FILE in $PATCH_FILES; do
	echo "Patching $PATCH_FILE ..."
	if ! sed -i "s!$OLD_URL!$NEW_URL!g" "$LOCAL_COPY/$PATCH_FILE"; then
		echo "Patching failed!"
		cd "$SAVE_DIR"
		exit 3
	fi
done


# Patch index.html
echo "Patching data in index.html ..."

for FILE in tred.dmg tred.deb tred-fedora.rpm tred-rhel.rpm ; do
	SIZE=`du -shD "$LOCAL_COPY/$FILE" | sed -E 's/^(\S+)\s.*/\1/'`
	echo "    -> size of $FILE ($SIZE) ..."
	if ! sed -i "s/<!--PUBLISH_SIZE_OF_$FILE-->/$SIZE/" "$LOCAL_COPY/index.html"; then
		echo "Patching of index.html failed on record \"$FILE\"!"
		cd "$SAVE_DIR"
		exit 4
	fi
done


# Upload patched release to public web
echo "Uploading release to $PUBLIC_WEB ..."
echo -n "Login name: "; read LOGIN_NAME
if [ "$LOGIN_NAME" != '' ]; then
	rsync -rlHzv --exclude '*~' --exclude .svn --rsh=ssh --chmod=Dug+rwx,o+r,Fug+rwX,o+rX "$LOCAL_COPY/" "${LOGIN_NAME}@${PUBLIC_WEB}/"
fi


# Cleanup
rm -rf "$LOCAL_COPY"
cd "$SAVE_DIR"
