<#
.SYNOPSIS
    imagemagick, image processing, conversion, convert, SVG, PNG
.DESCRIPTION
    Svg2Png.ps1 is a PowerShell script to convert all SVG images in a folder to PNG images.
.PARAMETER density
    the 'density' setting for the ImageMagick 'convert' command used to normalize images (default: 150, range: [72..1200]))
.EXAMPLE
  PS> Svg2Png.ps1 -dir "${env:userprofile}\Temp"
    Converts all SVG images in '${env:userprofile}\Temp' to PNG
.EXAMPLE
  PS> Svg2Png.ps1 -dir "${env:userprofile}\Temp" -density 300
    Converts all SVG images in '${env:userprofile}\Temp' to PNG with 300dpi
.NOTES
    This PowerShell script requires ImageMagick [1], more specifically the 'convert' [2] command, to be on the path.

    This PowerShell script has been developed and tested with version 7.0.10-34 of ImageMagick.

    [1] https://imagemagick.org/
    [2] https://imagemagick.org/script/convert.php
#>
param (
    [string][Parameter(Mandatory)][ValidateScript({Test-Path -pathType container $_})]$dir,
    [int][ValidateRange(72,1200)]$density = 150
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
    }
}

function Log-Operation {
    param([string]$svgImage, [string]$pngImage)

    Write-Host "INFO - Converting image '$svgImage' to '$pngImage'... " -noNewline
}

#
# MAIN
#

$path = ${env:Path}
${env:Path} = (${env:Path}.Split(';') | Where-Object { $_ -ne "${env:windir}\System32" }) -join ';'

Get-ChildItem -path $dir -filter *.svg -recurse -file -name | ForEach-Object {
    Log-Operation -svgImage (Join-Path -path $dir -childPath $_) -pngImage (Join-Path -path $dir -childPath ([io.path]::ChangeExtension($_, ".png")))
    convert.exe -density $density (Join-Path -path $dir -childPath $_) (Join-Path -path $dir -childPath ([io.path]::ChangeExtension($_, ".png"))) 2> $null
    Log-Status -exitCode $lastExitCode
}

${env:Path} = $path