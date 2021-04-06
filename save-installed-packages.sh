#!/bin/sh

#### Simple script that creates a list with of all explicitly installed packages on the system 
#### and saves it in the config directory of the system's package manager.

PACMAN_PATH="$(which pacman)"
PACMAN_CONFIG_DIR="/etc/pacman.d/"

OUTPUT_FILENAME="installed_packages.txt"

if [[ -f $PACMAN_PATH ]]; then
    $PACMAN_PATH -Qe > $PACMAN_CONFIG_DIR$OUTPUT_FILENAME
fi
