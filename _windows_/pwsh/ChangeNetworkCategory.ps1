<#
.SYNOPSIS
    networking, network category, firewall, network connection profile
.DESCRIPTION
    ChangeNetworkCategory.ps1 is a PowerShell script to change the network category of a connection profile.
.PARAMETER category
    specifies the network category to change the connection profile to
.PARAMETER network
    name of the network to change
.EXAMPLE
  PS> ChangeNetworkCategory.ps1 -category Private
    Changes the connection profile of network 'LAN' to network category 'Private'
.EXAMPLE
  PS> ChangeNetworkCategory.ps1 -network "WiFi" -category Public
    Changes the connection profile of network 'WiFi' to network category 'Public'
.NOTES
    This PowerShell script requires Administrator privileges.
#>
#Requires -RunAsAdministrator
param (
    [string][Parameter(Mandatory)][ValidateNotNullOrEmpty()][ValidateSet("Public", "Private")]$category,
    [string][ValidateNotNullOrEmpty()]$network = "LAN"
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

function Log-Operation {
    param([string]$network, [string]$fromCategory, [string]$category)

    Write-Host "INFO - Changing category of network '$network' from '$fromCategory' to '$category'... " -noNewline
}

#
# MAIN
#

try {
    $fromCategory = Get-NetConnectionProfile -name $network | Select -expandProperty NetworkCategory
    Log-Operation -network $network -fromCategory $fromCategory -category $category
    Set-NetConnectionProfile -name $network -networkCategory $category -errorAction Stop
    Log-Status -status $OK
} catch [Exception] {
    Log-Status -status $FAILED
    Write-Error $_ -errorAction Stop
}