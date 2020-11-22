<#
.SYNOPSIS
	imagemagick, image processing, normalization, identify, mogrify
.DESCRIPTION
    NormalizeImageWidth.ps1 is a PowerShell script to normalize the width of all images in a folder.
    
    The script first determines the width of the widest image and then adjusts all other images to have the same width.
.PARAMETER dir
    name or path to the directory containing the images to normalize
.PARAMETER gravity
    the 'gravity' setting for the ImageMagick 'mogrify' command used to normalize images (default: 'Center')
.PARAMETER background
	the 'background' setting for the ImageMagick 'mogrify' command used to normalize images (default: 'white')
.EXAMPLE
  PS> NormalizeImageWidth.ps1 -dir "${env:userprofile}\Temp"
	Normalizes all images in '${env:userprofile}\Temp' to the width of the widest image
.EXAMPLE
  PS> NormalizeImageWidth.ps1 -dir "${env:userprofile}\Temp" -background black
	Normalizes all images in '${env:userprofile}\Temp' to the width of the widest image using a background of 'black'
.NOTES
    This PowerShell script requires ImageMagick [1], more specifically the 'identify' [2] and 'mogrify' [3] commands, to be on the path.
    
    [1] https://imagemagick.org/
    [2] https://imagemagick.org/script/identify.php
    [3] https://imagemagick.org/script/mogrify.php
#>
param (
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -pathType container $_})]$dir,
    [string][ValidateNotNullOrEmpty()][ValidateSet("Center", "East", "NorthEast", "North", "NorthWest", "SouthEast", "South", "SouthWest", "West")]$gravity = "Center",
    [string][ValidateNotNullOrEmpty()]$background = "white"
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

    Write-Host "INFO - Normalizing image '$image' to dimensions '${imageWidth}x${imageHeight}'... " -noNewline
}

function Get-MaxImageWidth {
	param([string]$dir)

    $maxImageWidth = 0
    Get-ChildItem -path $dir -recurse -file -name | ForEach-Object {
        $imageWidth = identify.exe -ping -format %w (Join-Path -path $dir -childPath $_) 2>$null
        if ($lastExitCode -eq 0 -and $imageWidth -gt $maxImageWidth) {
            $maxImageWidth = $imageWidth
        }
    }

    return $maxImageWidth
}

function Normalize-ImageWidth {
	param([string]$dir, [int]$imageWidth)

    Get-ChildItem -path $dir -recurse -file -name | ForEach-Object {
        $imageHeight = identify.exe -ping -format %h (Join-Path -path $dir -childPath $_) 2>$null
        if ($lastExitCode -eq 0) {
            Log-Operation -image (Join-Path -path $dir -childPath $_) -imageWidth $imageWidth -imageHeight $imageHeight
            mogrify.exe -gravity $gravity -background $background -extent ${imageWidth}x${imageHeight} (Join-Path -path $dir -childPath $_)
            Log-Status -exitCode $lastExitCode
        }
    }
}

#
# MAIN
#

$maxImageWidth = Get-MaxImageWidth -dir (Resolve-Path $dir)
Normalize-ImageWidth -dir (Resolve-Path $dir) -imageWidth $maxImageWidth