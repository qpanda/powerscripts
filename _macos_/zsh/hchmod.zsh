#!/bin/zsh
set -eu -o pipefail

###
# SYNOPSIS
#   umask, permissions, file system, home directory
# DESCRIPTION
#   hchmod.zsh is a Zsh script that sets directories and files directly under
#   the user's home directory to be accessible only by the user.
# EXAMPLE
#   $ hchmod.zsh
#     Sets directory and file permissions in home directory so that only the
#     user can access them
# NOTE
#   On macOS files and directories that are part of the default profile and are
#   directly under the user's home directory are accessible only to the user.
#   In addition directories are protected from deletion using ACL. This script
#   sets all files and folders (including newly added ones) directly under the
#   home directory to have the same (consistent) permissions.
#   
#   Changing the umask setting of users (to have newly created files and
#   directories get the correct permission) is not recommended. It causes the
#   installation of certain Adobe software to fail.
#   
#   Changing the permissions of the home directory itself is not recommended
#   because it would break access to the Public folder for file sharing (and
#   potentially other features that rely on the default permission of the home
#   directory).
#   
#   Another approach could be setting ACLs with options file_inherit and
#   limit_inherit on the home directory.
###

#
# MAIN
#

find ~ -type d -mindepth 1 -maxdepth 1 -not -name 'Desktop' -not -name 'Documents' -not -name 'Downloads' -not -name '.Trash' -print0 | xargs -0 chmod '=a#' 0 'group:everyone deny delete'
find ~ -type d -mindepth 1 -maxdepth 1 -not -name 'Public' -print0 | xargs -0 chmod 'go=-rwx'
find ~ -not -type d -maxdepth 1 -print0 | xargs -0 chmod -h 'go=-rwx'
