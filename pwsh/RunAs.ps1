<#
.SYNOPSIS
    runas, elevated session, administrator, powershell
.DESCRIPTION
    RunAs.ps1 is a PowerShell script to invoke another PowerShell scripts with elevated priviledges
.PARAMETER script
    name or path to the PowerShell script to run with elevated priviledges
.PARAMETER arguments
    arguments passed to the PowerShell script run with elevated priviledges
.PARAMETER executionPolicy
    the PowerShell executionPolicy used to execution the script (default: 'RemoteSigned')
.PARAMETER userPath
    whether to use ${Env:Path} of the user calling this script (default: $true)
.EXAMPLE
  PS> RunAs.ps1 CfaApps.ps1 -op add -exe "${env:windir}\explorer.exe"
    Runs 'CfaApps.ps1 -op add -exe "${env:windir}\explorer.exe"' with elevated priviledges
.NOTES
    The script is executed [1] in a new window [2] since redirecting output [3] truned out to be tricky.

    [1] https://stackoverflow.com/questions/42171164/error-when-trying-to-run-bat-file-using-runas-administrator-using-powershell
    [2] https://stackoverflow.com/questions/25725925/verb-runas-in-a-start-process-powershell-command-causes-an-error
    [3] https://stackoverflow.com/questions/50765949/redirect-stdout-stderr-from-powershell-script-as-admin-through-start-process
#>
param (
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -isValid $_})]$script,
    [string[]][Parameter(ValueFromRemainingArguments=$true)]$arguments,
    [string][ValidateNotNullOrEmpty()]$executionPolicy = "RemoteSigned",
    [bool]$userPath = $true
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
    param([string]$script, [string]$arguments)

    Write-Host "INFO - Running PowerShell script '$script $arguments' as Administrator... " -noNewline
}

function Get-Command {
    param([bool]$userPath)

    if ($userPath) {
        return "Set-Item -Path Env:Path -Value '${Env:Path}'; $script $arguments; Write-Host '`nPress Enter to close window...' -noNewLine; Read-Host"
    }

    return "$script $arguments; Write-Host '`nPress Enter to close window...' -noNewLine; Read-Host"
}

#
# MAIN
#

$command = Get-Command -userPath $userPath

try {
    Log-Operation -script $script -arguments $arguments
    Start-Process powershell -argumentList "-executionPolicy $executionPolicy", "-command $command" -verb RunAs -wait
    Log-Status -status $OK
} catch [Exception] {
    Log-Status -status $FAILED
    Write-Error $_ -errorAction Stop
}
