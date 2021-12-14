<#
.SYNOPSIS
    files, user profile
.DESCRIPTION
    HideDotItems.ps1 is a PowerShell script to set dot files and directories in the user's profile directory to hidden.
.EXAMPLE
  PS> HideDotItems.ps1
    Hides dot files and directories located in the user's profile directory
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

#
# MAIN
#

try {
    Log-Operation -message "Setting dot files and directories to hidden... "
    Get-ChildItem -path ${env:USERPROFILE} -filter .* | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
    Log-Status -status $OK
} catch [Exception] {
    Log-Status -status $FAILED
    Write-Error $_ -errorAction Stop
}