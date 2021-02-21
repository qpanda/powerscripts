#!/bin/zsh
set -eu -o pipefail

###
# SYNOPSIS
#   rsync, backup, sync
# DESCRIPTION
#   rsync.zsh is a Zsh script that uses rsync to mirror a directory tree.
# PARAMETER source
#   the source directory
# PARAMETER destination
#   the destination directory
# PARAMETER logfile
#   path to the logfile (default: '${TMPDIR}/rsync.log')
# EXAMPLE
#   $ rsync.ps1 a b
#     Uses rsync to mirror the directory tree 'a' to 'b'
###

#
# CONSTANTS
#

NONE='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
LOG_FILE=${TMPDIR}/rsync.log

#
# MAIN
#

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
  echo "usage: rsync.zsh <source> <destination> [<logfile>]"
  exit 1
fi

if [ ! -d "${1}" ]; then
  echo "ERROR - Source directory '${1}' does not exist"
  exit 1
fi

if [ $# -eq 3 ]; then
  LOG_FILE=${3}
fi

mkdir -p ${2}

echo -n "INFO - Syncing '${1}' to '${2}'... "
if rsync -rth --delete --delete-excluded --delete-during --stats --exclude '.DS_Store' --exclude $'Icon\r' --exclude '._*' --exclude 'Thumbs.db' --exclude '~$*' --exclude '.TemporaryItems' --exclude '.DocumentRevisions-V100' --exclude '.Spotlight-V100' --exclude '.Trashes' --exclude '.fseventsd' --log-file=${LOG_FILE} "${1}/" "${2}" 1>${LOG_FILE} 2>&1; then
  echo "${GREEN}OK${NONE}"
else
  echo "${RED}FAILED${NONE}"
fi
