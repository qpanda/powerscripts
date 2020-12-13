<#
.SYNOPSIS
    controlled folder access, security, windows defender, malware protection
.DESCRIPTION
    CfaDirs.ps1 is a PowerShell script to add / remove a directory to / from the list of directories protected by Controlled Folder Access.
.PARAMETER op
    specifies whether to add or remove a directory to / from the list of protected directories (values: 'add', 'remove')
.PARAMETER dir
    name or path to the directory that should be added / removed to / from the list of protected directories
.EXAMPLE
  PS> CfaDirs.ps1 -op add -dir "${env:userprofile}\Dropbox"
    Adds '${env:userprofile}\Dropbox' to the list of directories protected by Controlled Folder Access
.EXAMPLE
  PS> CfaDirs.ps1 -op remove -dir "${env:userprofile}\Dropbox"
    Removes '${env:userprofile}\Dropbox' from the list of directories protected by Controlled Folder Access
.NOTES
    This PowerShell script requires Administrator privileges.
#>
#Requires -RunAsAdministrator
param (
    [string][Parameter(Mandatory)][ValidateNotNullOrEmpty()][ValidateSet('add','remove')]$op,
    [string][Parameter(Mandatory)][ValidateScript({Test-Path -pathType container $_})]$dir
)

#
# CONSTANTS
#

Set-Variable OK -option Constant -value "OK"
Set-Variable FAILED -option Constant -value "FAILED"

Set-Variable ADD -option Constant -value "ADD"
Set-Variable REMOVE -option Constant -value "REMOVE"

#
# FUNCTIONS
#

function Log-Status {
    param([string]$status)

    if ($status -ieq $OK) {
        Write-Host "$status" -foregroundColor green
    } elseif ($status -ieq $FAILED) {
        Write-Host "$status" -foregroundColor red
    } else {
        Write-Host "$status"
    }
}

function Log-Operation {
    param([string]$op, [string]$path)

    if ($op -ieq $ADD) {
        Write-Host "INFO - Adding '$path' to folders protected by controlled folder access... " -noNewline
    } elseif ($op -ieq $REMOVE) {
        Write-Host "INFO - Removing '$path' from folders protected by controlled folder access... " -noNewline
    }
}

function Change-CfaDirs {
    param([string]$op, [string]$path)

    try {
        Log-Operation -op $op -path $path

        if ($op -ieq $ADD) {
            Add-MpPreference -ControlledFolderAccessProtectedFolders $path -errorAction Stop
        } elseif ($op -ieq $REMOVE) {
            Remove-MpPreference -ControlledFolderAccessProtectedFolders $path -errorAction Stop
        }

        Log-Status -status $OK
    } catch [Exception] {
        Log-Status -status $FAILED
        Write-Error $_ -errorAction Stop
    }
}

#
# MAIN
#

Change-CfaDirs -op $op -path (Resolve-Path $dir)