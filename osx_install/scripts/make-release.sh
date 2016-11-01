#!/bin/bash

# Jump to releasing directory ...
SAVE_DIR=`pwd`
cd `dirname $0` || exit 1

. .config


# Attach the template file
# if [ -e "$MOUNT_DISK" ]; then
#     hdiutil detach "$MOUNT_DISK"
# fi

echo "Attaching $TEMPLATE ..."
MOUNT_DISK=`hdiutil attach "$TEMPLATE"|grep "$MOUNT_POINT"|cut -f1`

if [ ! -d "$MOUNT_POINT" ]; then
    echo "Unable to mount ${TEMPLATE}!"
    exit 1
fi


# Cleanups ...
echo "Removing old files ..."
if [ -z  $INSTALL_SCRIPT_URL ]; then
	rm -rf "$INSTALL_SCRIPT"
fi
rm -rf "$APPLICATIONS/$TRED_INSTALL_APP"
rm -rf "$MOUNT_POINT/$TRED_DIR"
rm -rf "$MOUNT_POINT/$TRED_APP/Contents/_CodeSignature"


# Prepare fresh template
echo "Copying template contents to the $APPLICATIONS/$TRED_INSTALL_APP ..."
cp -R "$MOUNT_POINT/$TRED_APP" "$APPLICATIONS/$TRED_INSTALL_APP" || exit 2


# Get TrEd install script
if [ -z  $INSTALL_SCRIPT_URL ]; then
	echo "Downloading fresh $INSTALL_SCRIPT script ..."
	wget -O "$INSTALL_SCRIPT" "$INSTALL_SCRIPT_URL" || exit 3
	chmod a+x "$INSTALL_SCRIPT" || exit 3
elif [ -z $INSTALL_SCRIPT_DIR  ]; then
	cd $INSTALL_SCRIPT_DIR
else
	exit 3
fi

# Install TrEd to $APPLICATIONS from bash script
echo "Installing TrEd to $APPLICATIONS/$TRED_DIR ..."

elif [ ! -z $INSTALL_SCRIPT_DIR  ]; then
	$INSTALL_SCRIPT --tred-dir "$APPLICATIONS/$TRED_DIR" || exit 4
else
	$INSTALL_SCRIPT -L $INSTALL_SCRIPT_DIR --tred-dir "$APPLICATIONS/$TRED_DIR" || exit 4
fi

# The code needs to be signed so it runs on Mountain Lion without obstacles
echo "Sign the code with UFAL certificate ..."
echo "\t> SKIPPING"
# security unlock-keychain -p tred
# codesign -f -s "$SIGN_CERT_SHA1" -r='designated => anchor apple generic and identifier "cz.cuni.mff.ufal.tred"' -v "$APPLICATIONS/$TRED_APP" || exit 5


# Copy installed TrEd and its signature to the release image
echo "Copying $APPLICATIONS/$TRED_DIR to $MOUNT_POINT/$TRED_DIR ..."
cp -R "$APPLICATIONS/$TRED_DIR" "$MOUNT_POINT/$TRED_DIR" || exit 6
cp -R "$APPLICATIONS/$TRED_INSTALL_APP/Contents/_CodeSignature" "$MOUNT_POINT/$TRED_APP/Contents/_CodeSignature" || exit 6
cp "$APPLICATIONS/$TRED_INSTALL_APP/Contents/MacOS/TrEd" "$MOUNT_POINT/$TRED_APP/Contents/MacOS/TrEd" || exit 6


# Finalize the release dmg file
echo "Detaching $TEMPLATE ..."
hdiutil detach /dev/disk1 || exit 7

echo "Compressing $TEMPLATE into $RELEASE_FILE ..."
hdiutil convert "$TEMPLATE" -format UDZO -o "$RELEASE_FILE" -ov || exit 8


# Cleanup
if [ -z  $INSTALL_SCRIPT_URL ]; then
    rm "$INSTALL_SCRIPT"
fi
cd "$SAVE_DIR"
