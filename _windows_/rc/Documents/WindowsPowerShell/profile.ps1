Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key Ctrl+u -Function DeleteLineToFirstChar
Set-PSReadLineKeyHandler -Key Ctrl+k -Function DeleteToEnd
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord

function prompt {
  $ok = $?

  Write-Host "[" -noNewLine
  Write-Host "$env:USERNAME" -foregroundColor cyan -noNewLine
  Write-Host "@" -foregroundColor cyan -noNewLine
  Write-Host "$env:COMPUTERNAME" -foregroundColor cyan -noNewLine
  Write-Host ":" -noNewLine
  Write-Host "$(Get-Location | Split-Path -leaf)" -foregroundColor blue -noNewLine
  Write-Host "]" -noNewLine

  if ($ok) {
    Write-Host ">" -foregroundColor green -noNewLine
  } else {
    Write-Host ">" -foregroundColor red -noNewLine
  }

  return " "
}

Set-Alias lls Get-ChildItem
Set-Alias sls Get-ChildItem | Format-Wide
