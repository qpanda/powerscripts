<#
.SYNOPSIS
    imagemagick, image processing, minimum, identify, mogrify
.DESCRIPTION
    MinimumImageWidth.ps1 is a PowerShell script to set the minimum width of all images in a folder.
.PARAMETER dir
    name or path to the directory containing images to set to the minimum width
.PARAMETER gravity
    the 'gravity' setting for the ImageMagick 'mogrify' command used to set minimum image width (default: 'Center')
.PARAMETER background
    the 'background' setting for the ImageMagick 'mogrify' command used to set minimum image width (default: 'white')
.PARAMETER minWidth
    the minimum width to set images to (default: 800, range: [1..10000])
.EXAMPLE
  PS> MinimumImageWidth.ps1 -dir "${env:userprofile}\Temp"
    Sets minimum width of all images in '${env:userprofile}\Temp' to 800
.EXAMPLE
  PS> MinimumImageWidth.ps1 -dir "${env:userprofile}\Temp" -minWidth 1000
    Sets minimum width of all images in '${env:userprofile}\Temp' to 1000
.EXAMPLE
  PS> MinimumImageWidth.ps1 -dir "${env:userprofile}\Temp" -background black
    Sets minimum width of all images in '${env:userprofile}\Temp' using a background of 'black' to 800
.NOTES
    This PowerShell script requires ImageMagick [1], more specifically the 'identify' [2] and 'mogrify' [3] commands, to be on the path.

    This PowerShell script has been developed and tested with version 7.0.10-34 of ImageMagick.

    [1] https://imagemagick.org/
    [2] https://imagemagick.org/script/identify.php
    [3] https://imagemagick.org/script/mogrify.php
#>
param (
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -pathType container $_})]$dir,
    [string][ValidateNotNullOrEmpty()][ValidateSet("Center", "East", "NorthEast", "North", "NorthWest", "SouthEast", "South", "SouthWest", "West")]$gravity = "Center",
    [string][ValidateNotNullOrEmpty()]$background = "white",
    [int][ValidateRange(1,10000)]$minWidth = 800
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
    param([string]$image, [int]$imageWidth, [int]$imageHeight)

    Write-Host "INFO - Setting image '$image' to dimensions '${imageWidth}x${imageHeight}'... " -noNewline
}

function Set-ImageWidth {
    param([string]$dir, [int]$minWidth)

    Get-ChildItem -path $dir -recurse -file -name | ForEach-Object {
        $imageWidth = [int](identify.exe -ping -format %w (Join-Path -path $dir -childPath $_) 2>$null)
        $imageHeight = [int](identify.exe -ping -format %h (Join-Path -path $dir -childPath $_) 2>$null)
        if ($imageWidth -ne 0 -and $imageHeight -ne 0 -and $imageWidth -lt $minWidth) {
            Log-Operation -image (Join-Path -path $dir -childPath $_) -imageWidth $minWidth -imageHeight $imageHeight
            mogrify.exe -gravity $gravity -background $background -extent ${minWidth}x${imageHeight} (Join-Path -path $dir -childPath $_)
            Log-Status -exitCode $lastExitCode
        }
    }
}

#
# MAIN
#

Set-ImageWidth -dir $dir -minWidth $minWidth