<#
.SYNOPSIS
    controlled folder access, security, windows defender, malware protection
.DESCRIPTION
    CfaApps.ps1 is a PowerShell script to add / remove an executable or all executables in a directory to / from the list of applications allowed to access folders protected by Controlled Folder Access.
.PARAMETER op
    specifies whether to add or remove an executable or all executables in a directory to / from the list of allowed applications (values: 'add', 'remove')
.PARAMETER exe
    name or path to the executable that should be added / removed to / from the list of allowed applications
.PARAMETER dir
    name or path to the directory
.EXAMPLE
  PS> CfaApps.ps1 -op add -exe "${env:windir}\explorer.exe"
    Adds '${env:windir}\explorer.exe' to the list of applications allowed to access folders protected by Controlled Folder Access
.EXAMPLE
  PS> CfaApps.ps1 -op add -dir "${env:ProgramFiles}\Adobe"
    Adds all executables in directory '${env:ProgramFiles}\Adobe' and all its subdirectories to the list of applications allowed to access folders protected by Controlled Folder Access
.EXAMPLE
  PS> CfaApps.ps1 -op remove -exe "${env:windir}\System32\RuntimeBroker.exe"
    Remove '${env:windir}\System32\RuntimeBroker.exe' from the list of applications allowed to access folders protected by Controlled Folder Access
.NOTES
    This PowerShell script requires Administrator privileges.
#>
#Requires -RunAsAdministrator
param (
    [string][Parameter(Mandatory)][ValidateNotNullOrEmpty()][ValidateSet('add','remove')]$op,
    [string][ValidateScript({Test-Path -pathType leaf $_})]$exe,
    [string][ValidateScript({Test-Path -pathType container $_})]$dir
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
        Write-Host "INFO - Adding '$path' to allowed applications for controlled folder access... " -noNewline
    } elseif ($op -ieq $REMOVE) {
        Write-Host "INFO - Removing '$path' from allowed applications for controlled folder access... " -noNewline
    }
}

function Change-CfaApps {
    param([string]$op, [string]$path)

    try {
        Log-Operation -op $op -path $path

        if ($op -ieq $ADD) {
            Add-MpPreference -ControlledFolderAccessAllowedApplications $path -errorAction Stop
        } elseif ($op -ieq $REMOVE) {
            Remove-MpPreference -ControlledFolderAccessAllowedApplications $path -errorAction Stop
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

if (-not $exe -and -not $dir) {
    Write-Error "Either parameter '-exe' or '-dir' needs to be specified" -category InvalidArgument -errorAction Stop
}

if ($exe -and $dir) {
    Write-Error "Only one of the parameters '-exe' or '-dir' can be used" -category InvalidArgument -errorAction Stop
}

if ($exe) {
    Change-CfaApps -op $op -path (Resolve-Path $exe)
} elseif ($dir) {
    Get-ChildItem -path (Resolve-Path $dir) -filter *.exe -recurse -file -name | ForEach-Object {
        Change-CfaApps -op $op -path (Join-Path -path (Resolve-Path $dir) -childPath $_)
    }
}