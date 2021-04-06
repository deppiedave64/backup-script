#!/bin/sh

#### Simple script that installs the backup script and other files to the system.

CURRENT_PATH=$(dirname $0)
SCRIPT_PATH=${SCRIPT_PATH:-"/usr/bin"}
SYSTEMD_PATH=${SYSTEMD_PATH:-"/etc/systemd/system"}

# Check for root status:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root!"
    exit 1
fi

if [[ -d $SCRIPT_PATH ]]; then
    cp $CURRENT_PATH/backup.sh $SCRIPT_PATH/backup
    cp $CURRENT_PATH/save-installed-packages.sh $SCRIPT_PATH/save-installed-packages
    chmod 755 $SCRIPT_PATH/backup \
              $SCRIPT_PATH/save-installed-packages
    echo "Script files installed to $SCRIPT_PATH"
else
    echo "$SCRIPT_PATH is not a valid path. Exiting!"
    exit 1
fi

if [[ -d $SYSTEMD_PATH ]]; then
    cp $CURRENT_PATH/systemd/* $SYSTEMD_PATH/
    echo "Systemd unit files installed to $SYSTEMD_PATH"
else
    echo "$SYSTEMD_PATH is not a valid path, no unit files installed."
fi