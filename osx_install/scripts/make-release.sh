#!/bin/bash

SIGNATURE=$1

# Jump to releasing directory ...
SAVE_DIR=`pwd`
cd `dirname $0` || exit 1
SCRIPT_DIR=`pwd`
. .config


# Attach the template file
# if [ -e "$MOUNT_DISK" ]; then
#     hdiutil detach "$MOUNT_DISK"
# fi

# detaching disk (if it is not detached it generates empty TrEd application envelope)
MOUNTED=`df | grep "$MOUNT_POINT" | cut -d" " -f1`
if [ -d "$MOUNT_POINT" ]; then
  echo "Warning: Detaching '$MOUNT_POINT' mount point. (it wasn't probably detached within prevoius release)"
  hdiutil detach $MOUNTED || exit 9
fi

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
if [ ! -z  $INSTALL_SCRIPT_URL ]; then
	echo "Downloading fresh $INSTALL_SCRIPT script ..."
	wget -O "$INSTALL_SCRIPT" "$INSTALL_SCRIPT_URL" || exit 3
	chmod a+x "$INSTALL_SCRIPT" || exit 3
elif [ ! -z $INSTALL_SCRIPT_DIR  ]; then
	cd $INSTALL_SCRIPT_DIR
else
	exit 3
fi

# Install TrEd to $APPLICATIONS from bash script
echo "Installing TrEd to $APPLICATIONS/$TRED_DIR ..."

if [ -z $INSTALL_SCRIPT_DIR  ]; then
	$INSTALL_SCRIPT --tred-dir "$APPLICATIONS/$TRED_DIR" || exit 4
else
  mkdir "$TRED_INSTALL_CLIB"
	$INSTALL_SCRIPT -L $INSTALL_SCRIPT_DIR --tred-dir "$APPLICATIONS/$TRED_INSTALL_DIR" --c-prefix "$TRED_INSTALL_CLIB"|| exit 4
fi

if [ $SIGNATURE -eq 1 ];then
# The code needs to be signed so it runs on Mountain Lion without obstacles
  echo "Sign the code with UFAL certificate ..."
  security unlock-keychain -p tred
  codesign -f -s "$SIGN_CERT_SHA1" -r='designated => anchor apple generic and identifier "cz.cuni.mff.ufal.tred"' -v "$APPLICATIONS/$TRED_INSTALL_APP" || exit 5
else
  echo "Skipping signature..."
fi

# Copy installed TrEd and its signature to the release image
echo "Copying $APPLICATIONS/$TRED_INSTALL_DIR to $MOUNT_POINT/$TRED_DIR ..."
cp -R "$APPLICATIONS/$TRED_INSTALL_DIR" "$MOUNT_POINT/$TRED_DIR" || exit 6
if [ $SIGNATURE -eq 1 ];then
  cp -R "$APPLICATIONS/$TRED_INSTALL_APP/Contents/_CodeSignature" "$MOUNT_POINT/$TRED_APP/Contents/_CodeSignature" || exit 6
fi
cp "$APPLICATIONS/$TRED_INSTALL_APP/Contents/MacOS/TrEd" "$MOUNT_POINT/$TRED_APP/Contents/MacOS/TrEd" || exit 6


# Finalize the release dmg file
echo "Detaching $TEMPLATE from $MOUNT_DISK"
hdiutil detach $MOUNT_DISK || exit 7


echo "Compressing $SCRIPT_DIR/$TEMPLATE into $INSTALL_SCRIPT_DIR/$RELEASE_FILE ..."
hdiutil convert "$SCRIPT_DIR/$TEMPLATE" -format UDZO -o "$INSTALL_SCRIPT_DIR/$RELEASE_FILE" -ov || exit 8


# Cleanup
if [ -z  $INSTALL_SCRIPT_URL ]; then
    rm "$INSTALL_SCRIPT"
fi
cd "$SAVE_DIR"
