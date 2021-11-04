#!/bin/zsh
set -eu -o pipefail

###
# SYNOPSIS
#   cp, permissions, file system, home directory
# DESCRIPTION
#   hcp.zsh is a Zsh script that copies directories and files into the home
#   directory and sets permissions on copied files and directories directly
#   under the user's home directory to be accessible only by the user.
# PARAMETER from
#   path to the directory to copy into the home directory
# EXAMPLE
#   $ hcp.zsh 'a'
#     Copies the content of directory 'a' recursively into the home directory
#     and sets permissions appropriately
# NOTE
#   On macOS files and directories that are part of the default profile and are
#   directly under the home directory are accessible only to the user. In
#   addition directories are protected from deletion using ACL. This script
#   sets all files and folders copied directly under the home directory to have
#   the same (consistent) permissions.
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
  echo "usage: hcp.zsh <from>"
  exit 1
fi

for item in ${1}/*(DN)
do
  if [[ -d ${item} ]]; then
    cp -rf ${item} ~
    chmod 'go=-rwx' ~/${item:t}
    chmod '=a#' 0 'group:everyone deny delete' ~/${item:t}
  else
    cp -f ${item} ~
    chmod -h 'go=-rwx' ~/${item:t}
  fi
done
