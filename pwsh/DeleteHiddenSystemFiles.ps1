<#
.SYNOPSIS
    files, clean
.DESCRIPTION
    DeleteHiddenSystemFiles.ps1 is a PowerShell script to delete hidden and system files from a directory.
.PARAMETER dir
    the directory to delete hidden and system files from recursively
.PARAMETER dryRun
    whether to simulate the delete operation (default: $false)
.EXAMPLE
  PS> DeleteHiddenSystemFiles.ps1 -dir "${env:userprofile}\Temp"
    Deletes all hidden and system files recursively from directory '${env:userprofile}\Temp'
.NOTES
    This PowerShell script is useful to remove hidden and system files such as 'desktop.ini' and 'Thumbs.db' created by Windows and '.DS_Store' and '._*' created by macOS recursively from a directory.
#>
param (
    [string][ValidateScript({Test-Path -pathType container $_})]$dir,
    [bool]$dryRun = $false
)

#
# CONSTANTS
#

Set-Variable OK -option Constant -value "OK"
Set-Variable FAILED -option Constant -value "FAILED"
Set-Variable SKIPPED -option Constant -value "SKIPPED"

#
# FUNCTIONS
#

function Log-Status {
    param([string]$status)

    if ($status -ieq $OK) {
        Write-Host "$status" -foregroundColor green
    } elseif ($status -ieq $FAILED) {
        Write-Host "$status" -foregroundColor red
    } elseif ($status -ieq $SKIPPED) {
        Write-Host "$status" -foregroundColor yellow
    } else {
        Write-Host "$status"
    }
}

function Log-Operation {
    param([string]$file)

    Write-Host "INFO - Deleting hidden/system file '$file'... " -noNewline
}

#
# MAIN
#

Get-ChildItem -path (Resolve-Path $dir) -attributes Hidden,System -recurse -file -name | ForEach-Object {
    if ($dryRun) {
        Log-Operation -file (Join-Path -path (Resolve-Path $dir) -childPath $_)
        Log-Status -status $SKIPPED
    } else {
        try {
            Log-Operation -file (Join-Path -path (Resolve-Path $dir) -childPath $_)
            Remove-Item -path (Join-Path -path (Resolve-Path $dir) -childPath $_) -force
            Log-Status -status $OK
        } catch [Exception] {
            Log-Status -status $FAILED
            Write-Error $_ -errorAction Stop
        }
    }
}
