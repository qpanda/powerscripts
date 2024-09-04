<#
.SYNOPSIS
    robocopy, backup, sync
.DESCRIPTION
    RoboSync.ps1 is a PowerShell script that uses Robocopy to mirror a directory tree.
.PARAMETER source
    the source directory
.PARAMETER destination
    the destination directory
.PARAMETER logfile
    path to the logfile (default: '${env:Temp}/robosync.log')
.PARAMETER summary
    whether to show Robocopy summary information upon completion (default: $false)
.EXAMPLE
  PS> RoboSync.ps1 -source a -destination b
    Uses Robocopy to mirror the directory tree 'a' to 'b'
.NOTES
    According to the Robocopy [1] documentation [2] any exit / return code greater than 8 indicates that there was a failure during the copy/sync/mirror operation.

    [1] https://en.wikipedia.org/wiki/Robocopy
    [2] https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
#>
param (
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -pathType container $_})]$source,
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -isValid $_})]$destination,
    [string][ValidateScript({Test-Path -isValid $_})]$logfile = "${env:Temp}/robosync.log",
    [bool]$summary = $false
)

#
# FUNCTIONS
#

function Log-Status {
    param([int]$exitCode)

    if ($exitCode -le 8) {
        Write-Host "OK" -foregroundColor green
    } else {
        Write-Host "FAILED" -foregroundColor red
    }
}

function Log-Operation {
    param([string]$source, [string]$destination)

    Write-Host "INFO - Syncing '$source' to '$destination'... " -noNewline
}

#
# MAIN
#

if (!(Test-Path -pathType container -path $destination)) {
    try {
        $created = New-Item -itemType "directory" -force -path $destination
    } catch [Exception] {
        Write-Error $_ -errorAction Stop
    }
}

Log-Operation -source (Resolve-Path $source) -destination (Resolve-Path $destination)
robocopy (Resolve-Path $source) (Resolve-Path $destination) /e /purge /copy:DAT /dcopy:DAT /xj /xd '$RECYCLE.BIN' /xd 'System Volume Information' /r:3 /w:1 /log:${logfile} /fp /v /ns /x /np | out-null
Log-Status -exitCode $lastExitCode

if ($summary) {
    Get-Content -head 14 ${logfile}
    Get-Content -tail 8 ${logfile}
}