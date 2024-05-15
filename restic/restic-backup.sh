#!/bin/bash
# A simple restic backup script
# Requirements:
# - restic binaries (just install from your distro repositories or check https://restic.net/)
# - restic repository (just exec "restic init -r ${RESTIC_HOME}/restic-repo)
# - change script variables for your enviorment and exec it (./restic-backup.sh)

RESTIC_HOME=/path/to/restic/home
export RESTIC_REPOSITORY=${RESTIC_HOME}/restic-repo
export RESTIC_PASSWORD_FILE=/path/to/repo/password/file
LOG_FILE=${RESTIC_HOME}/restic-$(date +%d%m%Y_%H%M%S).log
CURRENT_DATE=$(date +%d%m%Y_%H%M%S)
BACKUP_SOURCE=/path/to/backup/source
SNAP_RETENTION=15
GROUP_BY=paths
EXCLUDE_FILE="$(mktemp)"
EXCLUDE_LIST="${BACKUP_SOURCE}/.cache/
${BACKUP_SOURCE}/dir1/
${BACKUP_SOURCE}/dir2/
${BACKUP_SOURCE}/dir3/"

## LOG GENERATOR
exec &> >(tee -a "${LOG_FILE}")

echo "$(date) - Starting RESTIC BACKUP

"
                restic version
                for i in ${EXCLUDE_LIST} ; do echo ${i} >> ${EXCLUDE_FILE} ; done
                restic backup --group-by ${GROUP_BY} --exclude-file=${EXCLUDE_FILE} --tag "cron-${CURRENT_DATE}" ${BACKUP_SOURCE}

echo " 

$(date) - Backup DONE.

Current Snapshots:

"

                restic snapshots --group-by ${GROUP_BY}

echo " 

$(date) - Starting integrity check and purge based on defined snapcount: ${SNAP_RETENTION}

$(date) - Checking:

"
                restic check

echo " 

$(date) Cleaning:

"

                restic forget --group-by ${GROUP_BY} --prune --keep-last ${SNAP_RETENTION}
                rm -f $EXCLUDE_FILE

echo "$(date) - Finished RESTIC BACKUP

"
