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

    When adding password protection to a PDF file the script will prompt for a password which is used as both the user and owner password. The script always uses 256-bit AES encryption to password protect (encrypt) PDF files.

    When removing password protection from a PDF file the script will prompt for a password which needs to match the user and / or owner password of the PDF.

    Prompting for the password avoids leaking the password into the shell history. But the password is still passsed as a command line argument to QPDF which leaks it into the process table. The added complexity of handling a password file outweighs the benefits for the most common use case, a single user system. It is recommended to use a unique password for each PDF file and, most importantly, not to reuse a password from an important account.

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
    } elseif ($exitCode -eq 2) {
        Write-Host "FAILED" -foregroundColor red
        Write-Error "$message" -category InvalidOperation -errorAction Stop
    } elseif ($exitCode -eq 3) {
        Write-Host "WARNING" -foregroundColor yellow
        Write-Warning "$message"
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
        Write-Error "File '$file' is already password protected (or not a valid PDF)" -category InvalidOperation -errorAction Stop
    }

    $password = Get-Password

    Log-Operation -op $op -file $file
    $message = qpdf.exe --replace-input --encrypt $password $password 256 -- $file 2>&1
    Log-Status -exitCode $lastExitCode -message $message
} elseif ($op -ieq $REMOVE) {
    qpdf.exe --requires-password $file
    if ($lastExitCode -eq 2 -or $lastExitCode -eq 3) {
        Write-Error "File '$file' is not password protected (or not a valid PDF)" -category InvalidOperation -errorAction Stop
    }

    $password = Get-Password

    Log-Operation -op $op -file $file
    $message = qpdf.exe --replace-input --decrypt --password=$password $file 2>&1
    Log-Status -exitCode $lastExitCode -message $message
}