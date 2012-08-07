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


# Prepare fresh template
echo "Copying template contents to the /Applications/$TRED_APP ..."
cp -R "$MOUNT_POINT/$TRED_APP" "/Applications/$TRED_APP"


# Get TrEd install script
echo "Downloading fresh $INSTALL_SCRIPT script ..."
wget -O "$INSTALL_SCRIPT" "$INSTALL_SCRIPT_URL"
chmod a+x "$INSTALL_SCRIPT"


# Install TrEd to /Applications from bash script
echo "Installing TrEd to /Applications/$TRED_DIR ..."
$INSTALL_SCRIPT --tred-dir "/Applications/$TRED_DIR"


# Copy installed TrEd to the release image
echo "Copying /Applications/$TRED_DIR to $MOUNT_POINT/$TRED_DIR ..."
cp -R "/Applications/$TRED_DIR" "$MOUNT_POINT/$TRED_DIR" || exit 1


# Finalize the release dmg file
echo "Detaching $TEMPLATE ..."
hdiutil detach /dev/disk1

echo "Compressing $TEMPLATE into $RELEASE_FILE ..."
hdiutil convert "$TEMPLATE" -format UDZO -o "$RELEASE_FILE" -ov


# Cleanup
rm "$INSTALL_SCRIPT"
cd "$SAVE_DIR"
