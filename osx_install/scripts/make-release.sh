#!/bin/bash

# Jump to releasing directory ...
SAVE_DIR=`pwd`
cd `dirname $0` || exit 1

. .config


# Attach the template file
if [ -e "$MOUNT_DISK" ]; then
    hdiutil detach "$MOUNT_DISK"
fi

echo "Attaching $TEMPLATE ..."
hdiutil attach "$TEMPLATE"

if [ ! -d "$MOUNT_POINT" ]; then
    echo "Unable to mount ${TEMPLATE}!"
    exit 1
fi


# Cleanups ...
echo "Removing old files ..."
rm -rf "$INSTALL_SCRIPT"
rm -rf "/Applications/$TRED_APP"
rm -rf "$MOUNT_POINT/$TRED_DIR"
rm -rf "$MOUNT_POINT/$TRED_APP/Contents/_CodeSignature"


# Prepare fresh template
echo "Copying template contents to the /Applications/$TRED_APP ..."
cp -R "$MOUNT_POINT/$TRED_APP" "/Applications/$TRED_APP" || exit 2


# Get TrEd install script
echo "Downloading fresh $INSTALL_SCRIPT script ..."
wget -O "$INSTALL_SCRIPT" "$INSTALL_SCRIPT_URL" || exit 3
chmod a+x "$INSTALL_SCRIPT" || exit 3


# Install TrEd to /Applications from bash script
echo "Installing TrEd to /Applications/$TRED_DIR ..."
$INSTALL_SCRIPT --tred-dir "/Applications/$TRED_DIR" || exit 4

# The code needs to be signed so it runs on Mountain Lion without obstacles
echo "Sign the code with UFAL certificate ..."
security unlock-keychain -p tred
codesign -f -s "$SIGN_CERT_SHA1" -r='designated => anchor apple generic and identifier "cz.cuni.mff.ufal.tred"' -v "/Applications/$TRED_APP" || exit 5


# Copy installed TrEd and its signature to the release image
echo "Copying /Applications/$TRED_DIR to $MOUNT_POINT/$TRED_DIR ..."
cp -R "/Applications/$TRED_DIR" "$MOUNT_POINT/$TRED_DIR" || exit 6
cp -R "/Applications/$TRED_APP/Contents/_CodeSignature" "$MOUNT_POINT/$TRED_APP/Contents/_CodeSignature" || exit 6
cp "/Applications/$TRED_APP/Contents/MacOS/TrEd" "$MOUNT_POINT/$TRED_APP/Contents/MacOS/TrEd" || exit 6


# Finalize the release dmg file
echo "Detaching $TEMPLATE ..."
hdiutil detach /dev/disk1 || exit 7

echo "Compressing $TEMPLATE into $RELEASE_FILE ..."
hdiutil convert "$TEMPLATE" -format UDZO -o "$RELEASE_FILE" -ov || exit 8


# Cleanup
rm "$INSTALL_SCRIPT"
cd "$SAVE_DIR"
