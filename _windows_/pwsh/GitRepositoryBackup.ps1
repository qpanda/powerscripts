<#
.SYNOPSIS
    git, backup
.DESCRIPTION
    GitRepositoryBackup.ps1 is a PowerShell script to backup a Git repository as a Git bundle file.
.PARAMETER repositoryUrl
    the URL of the Git repository to backup
.PARAMETER backupDir
    the directory to store the Git bundle in
.PARAMETER logfile
    path to the logfile (default: '${env:Temp}/git-repository-backup.log')
.EXAMPLE
  PS> GitRepositoryBackup.ps1 -repositoryUrl https://github.com/qpanda/powerscripts.git -backupDir ${env:userprofile}\Temp
    Uses Git to clone repository 'https://github.com/qpanda/powerscripts.git' and create a Git bundle 'powerscripts.bundle' in '${env:userprofile}\Temp'
.NOTES
    This PowerShell script requires the 'git' command to be on the path and authentication to the Git repository to be in place.

    To restore the Git repository from the Git bundle use 'git clone <repositoryName>.bundle <repositoryName>.git'.
#>
param (
    [string][Parameter(Mandatory=$true)][ValidateScript({[Uri]::IsWellFormedUriString($_, [UriKind]::Absolute)})]$repositoryUrl,
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -pathType container $_})]$backupDir,
    [string][ValidateScript({Test-Path -isValid $_})]$logfile = "${env:Temp}/git-repository-backup.log"
)

#
# FUNCTIONS
#

function Log-Status {
    param([int]$exitCode)

    if ($exitCode -eq 0) {
        Write-Host "OK" -foregroundColor green
    } else {
        Write-Host "FAILED" -foregroundColor red
        Exit
    }
}

function Log-Operation {
    param([string]$message)

    Write-Host "INFO - $message... " -noNewline
}

#
# MAIN
#

$repositoryName = (Split-Path $repositoryUrl -leaf)
$cloneDirectory = Join-Path -path ${env:Temp} -childPath $repositoryName
$bundleName = "$repositoryName.bundle"

if (Test-Path $cloneDirectory) {
    Remove-Item -path $cloneDirectory -recurse -force
}

Log-Operation -message "Cloning Git repository '$repositoryUrl'"
$process = Start-Process -wait -passThru -noNewWindow -filePath git -argumentList "clone --mirror $repositoryUrl $cloneDirectory" -redirectStandardError $logfile
Log-Status -exitCode $process.exitCode

Log-Operation -message "Creating Git bundle '$bundleName'"
$process = Start-Process -wait -passThru -noNewWindow -workingDirectory $cloneDirectory -filePath git -argumentList "bundle create $bundleName --all" -redirectStandardError $logfile
Log-Status -exitCode $process.exitCode

Move-Item -path (Join-Path -path $cloneDirectory -childPath $bundleName) -destination $backupDir -force

if (Test-Path $cloneDirectory) {
    Remove-Item -path $cloneDirectory -recurse -force
}