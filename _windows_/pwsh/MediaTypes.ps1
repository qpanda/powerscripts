<#
.SYNOPSIS
    file transfer, file copy, file sync, photos, videos, media, backup, digtal camera, smartphone, tablet, drone, DCIM
.DESCRIPTION
    MediaTypes.ps1 is a PowerShell script to separate DCF files (photos, videos, ...) by type
.PARAMETER dcfFilePrefix
    prefix of DCF files (default: 'IMG_')
.PARAMETER dcfEditFilePrefix
    prefix of edited DCF (default: 'IMG_E')
.PARAMETER photosFolder
    name of the folder for photo files (default: 'Photos')
.PARAMETER videosFolder
    name of the folder for video files (default: 'Videos')
.PARAMETER screenshotsFolder
    name of the folder for screenshot files (default: 'Screenshots')
.PARAMETER sidecarsFolder
    name of the folder for sidecar files (default: 'Sidecars')
.PARAMETER appsFolder
    name of the folder for app files (default: 'Apps')
.EXAMPLE
  PS> MediaTypes.ps1
    Separates DCF files in current folder by type and moves them to the respective sub-folder
.NOTES
    The DCIM file system [1] is a JEITA specification defining the directory structure, file naming method, character set, file format, and metadata format. It is the de facto industry standard for digital still cameras. The file format of DCF conforms to the Exif specification, but the DCF specification also allows use of any other file formats.

    Function Get-TargetFolder requires further work to support file extensions of raw image formats and video file formats from device manufacturers such as Canon, Nikon, GoPro, and DJI.

    [1] https://en.wikipedia.org/wiki/Design_rule_for_Camera_File_system
#>
param (
    [string][ValidateNotNullOrEmpty()]$dcfFilePrefix = "IMG_",
    [string][ValidateNotNullOrEmpty()]$dcfEditFilePrefix = "IMG_E",
    [string][ValidateScript({Test-Path -isValid $_})]$photosFolder = "Photos",
    [string][ValidateScript({Test-Path -isValid $_})]$videosFolder = "Videos",
    [string][ValidateScript({Test-Path -isValid $_})]$screenshotsFolder = "Screenshots",
    [string][ValidateScript({Test-Path -isValid $_})]$sidecarsFolder = "Sidecars",
    [string][ValidateScript({Test-Path -isValid $_})]$appsFolder = "Apps"
)

#
# FUNCTIONS
#

function Create-Folder {
    param([string]$folderPath)

    if (-not (Test-Path $folderPath)) {
        $created = New-Item -itemtype directory -path $folderPath
    }
}

function Get-TargetPath {
    param([string]$filename)

    if (($filename -imatch "${dcfFilePrefix}\d{4}\.JPG") -or ($filename -imatch "${dcfFilePrefix}\d{4}\.HEIC") -or ($filename -imatch "${dcfFilePrefix}\d{4}\.TIF") -or ($filename -imatch "${dcfFilePrefix}\d{4}\.DNG")) {
        return $photosPath
    } elseif ($filename -imatch "${dcfFilePrefix}\d{4}\.MOV") {
        return $videosPath
    } elseif (($filename -imatch "${dcfEditFilePrefix}\d{4}\.JPG") -or ($filename -imatch "${dcfEditFilePrefix}\d{4}\.HEIC") -or ($filename -imatch "${dcfEditFilePrefix}\d{4}\.TIF")  -or ($filename -imatch "${dcfEditFilePrefix}\d{4}\.DNG") -or ($filename -imatch "${dcfEditFilePrefix}\d{4}\.MOV") -or ($filename -imatch "${dcfFilePrefix}\d{4}\.AAE")) {
        return $sidecarsPath
    } elseif ($filename -imatch "${dcfFilePrefix}\d{4}\.PNG") {
        return $screenshotsPath
    }

    return $appsPath
}

#
# MAIN
#

$itemsPath = Resolve-Path .

$photosPath = Join-Path -path $itemsPath -childPath $photosFolder
$videosPath = Join-Path -path $itemsPath -childPath $videosFolder
$screenshotsPath = Join-Path -path $itemsPath -childPath $screenshotsFolder
$sidecarsPath = Join-Path -path $itemsPath -childPath $sidecarsFolder
$appsPath = Join-Path -path $itemsPath -childPath $appsFolder

Create-Folder -folderPath $photosPath
Create-Folder -folderPath $videosPath
Create-Folder -folderPath $screenshotsPath
Create-Folder -folderPath $sidecarsPath
Create-Folder -folderPath $appsPath

$items = @(Get-ChildItem -path $itemsPath -file | Sort-Object -property Name)
foreach ($item in $items) {
    $targetPath = Get-TargetPath -filename $item.Name
    Move-Item -path $item.FullName -destination $targetPath
}