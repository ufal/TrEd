#!/bin/bash

# This scripts launches the development VM machine, executes the DMG build process,
# uploads the tred.dmg file to the testbed web, and shuts down the VM again.

# Config Variables
LOCK_DIR='.build-tred-dmg-lock'
VM_PATH='/Users/tred/Documents/Virtual Machines.localized/TrEd-devel-osx10.7_64.vmwarevm/TrEd-testbed-osx10.7_64.vmx'
VM_SSH='tred@192.168.43.211'


# Check the VM is not running and there are there is still capacity to run another VM
IS_VM_RUNNING=`vmrun list | grep "$VM_PATH" | wc -l`
TOTAL_RUNNING_VMS=`vmrun list | head -1 | sed 's/[^0-9]//g'`

if [ "$IS_VM_RUNNING" -ne 0 ]; then
    echo "The development VM is already running ..."
    exit 1
fi

if [ "$TOTAL_RUNNING_VMS" -gt 1 ]; then
    echo "Too many running VMS ($TOTAL_RUNNING_VMS). Not enough resources to run another VM on this host."
    exit 2
fi


# Acquire exclusive lock
if mkdir "$LOCK_DIR"; then
    echo "Lock acquired."
    echo "Build tred script executed ..." > "${LOCK_DIR}/reason"
else
    echo "Unable to acquire lock."
    if [ -f "$LOCK_DIR/reason" ]; then
	echo -n "Reason: "
	cat "$LOCK_DIR/reason"
    fi
    exit 3
fi


# Start the VM
echo "Starting the development VM ..."
vmrun start "${VM_PATH}" nogui
sleep 60

# Bulid the tred.dmg image and upload it to the virtualbox server
echo "Executing building process ..."
ssh "${VM_SSH}" '~/tred-release/scripts/make-release.sh && ~/tred-release/scripts/upload.sh'

# Stop the VM
echo "Stopping the development VM ..."
vmrun stop "${VM_PATH}" soft

# Release the lock
rm -rf "$LOCK_DIR"
