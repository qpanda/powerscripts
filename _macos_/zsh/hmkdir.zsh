#!/bin/zsh
set -eu -o pipefail

###
# SYNOPSIS
#   mkdir, permissions, file system, home directory
# DESCRIPTION
#   hmkdir.zsh is a Zsh script to create directories with appropriate
#   permissions in the home directory.
# PARAMETER dir
#   name of the directory to create under the home directory
# EXAMPLE
#   $ hmkdir.zsh 'a'
#     Creates directory '~/a' and sets permissions appropriately
# NOTE
#   On macOS files and directories that are part of the default profile and are
#   directly under the home directory are accessible only to the user. In
#   addition directories are protected from deletion using ACL. This script
#   creates new directories directly under the home directory with the same
#   (consistent) permissions.
#   
#   Changing the umask setting of users (to have newly added files and
#   directories get the correct permission) is not recommended. It causes the
#   installation of certain Adobe software to fail.
#   
#   Another approach could be setting ACLs with options file_inherit and
#   limit_inherit on the home directory.
###

#
# MAIN
#

if [ $# -ne 1 ]; then
  echo "usage: hmkdir.zsh <dir>"
  exit 1
fi

mkdir -p ~/${1}
chmod 'go=-rwx' ~/${1}
chmod '=a#' 0 'group:everyone deny delete' ~/${1}
