<#
.SYNOPSIS
    qpdf, pdf, encryption, password, aes-256
.DESCRIPTION
    PdfPassword.ps1 is a PowerShell script to add password protection (encrypt) to / remove password protection (decrypt) from a PDF file
.PARAMETER op
    specifies whether to add password protection to or remove password protection from the PDF file (values: 'add', 'remove')
.PARAMETER file
    the PDF file to add password protection to or remove password protection from ('infilename' parameter of the QPDF command)
.EXAMPLE
  PS> PdfPassword.ps1 -op add -file test.pdf
    Add password protection to the PDF file 'test.pdf' (the PDF file will be encrypted)
.EXAMPLE
  PS> PdfPassword.ps1 -op remove -file test.pdf
    Remove password protection from the PDF file 'test.pdf' (the PDF file will be decrypted)
.NOTES
    This PowerShell script requires the 'qpdf' [1] command to be on the path.

    This PowerShell script will prompt for a password which will be used for both the user and the owner password of the PDF. When password protecting the PDF file will be encrypted with 256-bit AES encryption.

    [1] https://github.com/qpdf/qpdf
#>
param (
    [string][Parameter(Mandatory)][ValidateNotNullOrEmpty()][ValidateSet('add','remove')]$op,
    [string][ValidateScript({Test-Path -pathType leaf $_})]$file
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
    param([int]$exitCode, [string]$message)

    if ($exitCode -eq 0) {
        Write-Host "OK" -foregroundColor green
    } else {
        Write-Host "FAILED - $message" -foregroundColor red
    }
}

function Log-Operation {
    param([string]$op, [string]$file)

    if ($op -ieq $ADD) {
        Write-Host "INFO - Adding password protection to '$file' (encrypting)... " -noNewline
    } elseif ($op -ieq $REMOVE) {
        Write-Host "INFO - Removing password protection from '$file' (decrypting)... " -noNewline
    }
}

function Get-Password {
    $securePassword = Read-Host -Prompt "Password" -AsSecureString
    $secureCredentials = New-Object PSCredential("user/owner", $securePassword)
    return $secureCredentials.GetNetworkCredential().Password
}

#
# MAIN
#

if ($op -ieq $ADD) {
    qpdf.exe --requires-password $file
    if ($lastExitCode -eq 0) {
        Write-Error "'$file' is already password protected" -category InvalidOperation -errorAction Stop
    }

    $password = Get-Password

    Log-Operation -op $op -file $file
    $message = qpdf.exe --replace-input --encrypt $password $password 256 -- $file 2>&1
    Log-Status -exitCode $lastExitCode -message $message
} elseif ($op -ieq $REMOVE) {
    qpdf.exe --requires-password $file
    if ($lastExitCode -eq 2 -or $lastExitCode -eq 3) {
        Write-Error "'$file' is not password protected" -category InvalidOperation -errorAction Stop
    }

    $password = Get-Password
    
    qpdf.exe --requires-password --password=$password $file
    if ($lastExitCode -eq 0) {
        Write-Error "Invalid password for '$file'" -category InvalidOperation -errorAction Stop
    }
    
    Log-Operation -op $op -file $file
    $message = qpdf.exe --replace-input --decrypt --password=$password $file 2>&1
    Log-Status -exitCode $lastExitCode -message $message
}