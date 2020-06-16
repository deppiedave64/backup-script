#!/bin/sh

#### Simple backup script using Borg
#### By default, back up /etc, /root and /var/log to /mnt/backup
#### Default values can be overriden using env variables (see config)
#### Add additional paths to backup as positional parameters, e.g.
#### $ ./backup.sh /opt/some/dir /opt/another/dir

################
#### Config ####
################

# Set variables to default values if they are unset or empty:
KEEP_DAILY_BACKUPS=${${KEEP_DAILY_BACKUPS}:-7}
KEEP_WEEKLY_BACKUPS=${${KEEP_WEEKLY_BACKUPS}:-4}
KEEP_MONTHLY_BACKUPS=${${KEEP_MONTHLY_BACKUPS}:-6}
BACKUP_DIR=${${BACKUP_DIR}:-"/mnt/backup/"}
BACKUP_PASSPHRASE=${${BACKUP_PASSPHRASE}:-""}

###############
#### Setup ####
###############

# Helper function for printing messages:
info () { printf "\n%s: %s\n" "$(date)" "$*" >&2}

# Print exit message when execution is interrupted:
trap 'info "Backup interrupted"; exit 2' INT TERM

# Check for root status:
if [ "$(id -u)" != "0" ]; then
    info "This script must be run as root!"
    exit 1
fi

# Check if repository exists:
if [ ! -f "${BACKUP_DIR}/config" ] || [ ! -d "${BACKUP_DIR}/data" ]; then
    info "Repo ${BACKUP_DIR} seems to be non-existent. Please create borg repo."
    exit 2
fi


################
#### Backup ####
################

info "Starting backup"

borg create                            \
    --verbose                          \
    --filter AME                       \
    --list                             \
    --stats                            \
    --show-rc                          \
    --compression zstd,1               \
    --exclude-caches                   \
    ${BACKUP_DIR}::'{hostname}-{now}'  \
    /etc                               \
    /root                              \
    /var/log                           \
    $*

backup_exit=$?

#################
#### Pruning ####
#################

borg prune                                 \
    --list                                 \
    --prefix '{hostname}-'                 \
    --show-rc                              \
    --keep-daily   ${KEEP_DAILY_BACKUPS}   \
    --keep-weekly  ${KEEP_WEEKLY_BACKUPS}  \
    --keep-monthly ${KEEP_MONTHLY_BACKUPS} \
    ${BACKUP_DIR}

prune_exit=$?

###################
#### Finishing ####
###################

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}
