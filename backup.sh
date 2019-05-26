#!/bin/bash

################
#### Config ####
################

DAILY=7
WEEKLY=4
BACKUP_DIR="/mnt/backup/"
USER="david"

###############
#### Setup ####
###############

# Check for root status:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root."
    exit 1
fi

###############################
#### Backup root partition ####
###############################

# Check wether backup directory exists:
if [ ! -d "${BACKUP_DIR}backup_root" ]; then
    echo "Directory ${BACKUP_DIR}backup_root does not exist."
    exit 1
fi

# Run backup:
current_time=$(date +'%Y-%m-%d-%H-%M')
borg create ${BACKUP_DIR}backup_root::${current_time} /bin /etc /lib /lib64 /opt /sbin /usr

# Delete old backups:
borg prune ${BACKUP_DIR}backup_root --keep-daily=${DAILY} --keep-weekly=${WEEKLY}

###############################
#### Backup home partition ####
###############################

# Check wether backup directory exists:
if [ ! -d "${BACKUP_DIR}backup_home" ]; then
    echo "Directory ${BACKUP_DIR}backup_home does not exist."
    exit 1
fi

# Check wether file with excludes patterns exists:
if [ ! -f "/home/${USER}/.backup_exclude" ]; then
    echo "Exclude file /home/${USER}/.backup_exclude does not exist."
    exit 1
fi

# Run backup
current_time=$(date +'%Y-%m-%d-%H-%M')
borg create ${BACKUP_DIR}backup_home::${current_time} /home/${USER} --exclude-from /home/${USER}/.backup_exclude

# Delete old backups:
borg prune ${BACKUP_DIR}backup_home --keep-daily=${DAILY} --keep-weekly=${WEEKLY}