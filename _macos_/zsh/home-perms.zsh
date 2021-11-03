#!/bin/zsh
set -eu -o pipefail

###
# SYNOPSIS
#   umask, permissions, file system, home directory
# DESCRIPTION
#   home-perms.zsh is a Zsh script that sets directories and files directly under the user's home directory to be accessible only by the user.
# EXAMPLE
#   $ home-perms.zsh
#     Sets directory and file permissions in home directory
###

#
# MAIN
#

find ~ -type d -maxdepth 1 -print0 | xargs -0 chmod '=a#' 0 'group:everyone deny delete'
find ~ -type d -maxdepth 1 -print0 | xargs -0 chmod 'go=-rwx'
find ~ -type f -maxdepth 1 -print0 | xargs -0 chmod 'go=-rwx'