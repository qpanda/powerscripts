#!/bin/zsh
set -eu -o pipefail

###
# SYNOPSIS
#   cp, permissions, file system, home directory
# DESCRIPTION
#   hcpf.zsh is a Zsh script that copies a file into the home directory and
#   sets permissions on the file to be accessible only by the user.
# PARAMETER file
#   path to the file to copy into the home directory
# EXAMPLE
#   $ hcpf.zsh 'a'
#     Copies file 'a' into the home directory and sets permissions
#     appropriately
# NOTE
#   On macOS files and directories that are part of the default profile and are
#   directly under the home directory are accessible only to the user. In
#   addition directories are protected from deletion using ACL. This script
#   sets files copied into the home directory to have the same (consistent)
#   permissions.
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
  echo "usage: hcp.zsh <file>"
  exit 1
fi

if [ ! -f "${1}" ]; then
  echo "ERROR - Source file '${1}' does not exist"
  exit 1
fi

cp -f ${1} ~
chmod -h 'go=-rwx' ~/${1:t}
