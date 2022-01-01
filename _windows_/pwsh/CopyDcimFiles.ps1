<#
.SYNOPSIS
    file transfer, file copy, file sync, photos, videos, media, backup, digtal camera, smartphone, tablet, drone, DCIM
.DESCRIPTION
    CopyDcimFiles.ps1 is a PowerShell script to copy all or new DCF files (photos, videos, ...) from the DCIM file system of a device (smartphone, tablet, camera, drone, ...) to a Windows computer.

    During the copy process the type of each DCF file (photo, video, sidecar, screenshot, other) is identified and the file is placed in a corresponding folder inside 'targetPath'.
.PARAMETER deviceName
    name of the device with DCIM file system (default: 'Apple iPhone')
.PARAMETER dcimPath
    path to the DCIM folder on the device (default: 'Internal Storage\DCIM')
.PARAMETER dcfFilePrefix
    prefix of DCF files on the device (default: 'IMG_')
.PARAMETER dcfEditFilePrefix
    prefix of edited DCF files on the device (default: 'IMG_E')
.PARAMETER lastDcfFolder
    DCF files with a number greater than 'lastDcfFileNumber' from DCF folders equal to or greater than 'lastDcfFolder' will be copied (default: '000')
.PARAMETER lastDcfFileNumber
    DCF files with a number greater than 'lastDcfFileNumber' from DCF folders equal to or greater than 'lastDcfFolder' will be copied (default: 0000, range: [0000..9999])
.PARAMETER targetPath
    path the DCF files should be copied to - the targetPath folder has to exist
.PARAMETER photosFolder
    name of the folder inside 'targetPath' that will be used for DCF photo files (default: 'photos')
.PARAMETER videosFolder
    name of the folder inside 'targetPath' that will be used for DCF video files (default: 'videos')
.PARAMETER sidecarsFolder
    name of the folder inside 'targetPath' that will be used for DCF sidecar files (default: 'sidecars')
.PARAMETER screenshotsFolder
    name of the folder inside 'targetPath' that will be used for DCF screenshot files (default: 'screenshots')
.PARAMETER othersFolder
    name of the folder inside 'targetPath' that will be used for DCF other files (default: 'others')
.PARAMETER cameraMaker
    name of the camera maker - if set 'cameraMaker' is used to identify photos taken by the device (default: 'Apple')
.PARAMETER cameraModel
    name of the camera model - if set 'cameraModel' is used to identify photos taken by the device (default: '')
.EXAMPLE
  PS> CopyDcimFiles.ps1 -targetPath temp
    Copies all DCF files from device 'Apple iPhone' to folder 'temp'
.EXAMPLE
  PS> CopyDcimFiles.ps1 -targetPath temp -lastDcfFolder 104APPLE -lastDcfFileNumber 4353
    Copies DCF files with a number greater than 4353 from DCF folders equal to or greater than '104APPLE' from device 'Apple iPhone' to folder 'temp'

  PS> CopyDcimFiles.ps1 -targetPath temp -lastDcfFolder 202011__ -lastDcfFileNumber 4353
    Copies DCF files with a number greater than 4353 from DCF folders equal to or greater than '202011__' from device 'Apple iPhone' to folder 'temp'
.NOTES
    The DCIM file system [1] is a JEITA specification defining the directory structure, file naming method, character set, file format, and metadata format. It is the de facto industry standard for digital still cameras. The file format of DCF conforms to the Exif specification, but the DCF specification also allows use of any other file formats.

    According to the standard DCF folders use numbers in the range [100..999] and DCF files use numbers in the range [0001..9999]. By setting 'lastDcfFolder' to '000' (default) and 'lastDcfFileNumber' to 0000 (default) all DCF files will be copied.

    Apple decided to deviate from the specification in recent iOS version and is using a date based folder naming convention.

    CopyDcimFiles.ps1 currently has the following limitations:
      * To copy only files added to the device since the last time CopyDcimFiles.ps1 was used the last DCF folder and DCF file copied need to be noted down. Future versions may use a state file to keep track of the last DCF folder and DCF file copied on a per-device basis.
      * Function Get-TargetFolder requires further work to support file extensions of raw image formats and video file formats from device manufacturers such as Canon, Nikon, GoPro, and DJI.
      * When files from more than 10 DCF folders are copied the DCF file names are not unique any more and DCF files with duplicated file names will be skipped. Future versions may add a feature to include the DCF folder name in the target DCF file name.

    [1] https://en.wikipedia.org/wiki/Design_rule_for_Camera_File_system
#>
param (
    [string][ValidateNotNullOrEmpty()]$deviceName = "Apple iPhone",
    [string][ValidateScript({(Test-Path -isValid $_) -and (-not [System.IO.Path]::IsPathRooted($_))})]$dcimPath = "Internal Storage\DCIM",
    [string][ValidateNotNullOrEmpty()]$dcfFilePrefix = "IMG_",
    [string][ValidateNotNullOrEmpty()]$dcfEditFilePrefix = "IMG_E",
    [string][ValidateNotNullOrEmpty()]$lastDcfFolder = '000',
    [int][ValidateRange(0,9999)]$lastDcfFileNumber = 0000,
    [string][Parameter(Mandatory=$true)][ValidateScript({Test-Path -pathType container $_})]$targetPath,
    [string][ValidateScript({(Test-Path -isValid $_) -and (-not [System.IO.Path]::IsPathRooted($_))})]$photosFolder = "photos",
    [string][ValidateScript({(Test-Path -isValid $_) -and (-not [System.IO.Path]::IsPathRooted($_))})]$videosFolder = "videos",
    [string][ValidateScript({(Test-Path -isValid $_) -and (-not [System.IO.Path]::IsPathRooted($_))})]$sidecarsFolder = "sidecars",
    [string][ValidateScript({(Test-Path -isValid $_) -and (-not [System.IO.Path]::IsPathRooted($_))})]$screenshotsFolder = "screenshots",
    [string][ValidateScript({(Test-Path -isValid $_) -and (-not [System.IO.Path]::IsPathRooted($_))})]$othersFolder = "others",
    [string]$cameraMaker = "Apple",
    [string]$cameraModel = ""
)

#
# CONSTANTS
#

Set-Variable OK -option Constant -value "OK"
Set-Variable SKIPPED -option Constant -value "SKIPPED"
Set-Variable IGNORED -option Constant -value "IGNORED"
Set-Variable FAILED -option Constant -value "FAILED"

#
# FUNCTIONS
#

function Get-ShellProxy {
    if (-not $global:ShellProxy) {
        $global:ShellProxy = New-Object -com Shell.Application
    }

    $global:ShellProxy
}

function Get-Device {
    param([string]$deviceName)

    $shell = Get-ShellProxy
    $shellItem = $shell.NameSpace(17).self
    $device = $shellItem.GetFolder.items() | where {$_.name -ieq $deviceName}
    return $device
}

function Get-SubFolder {
    param([object]$parent, [string]$path)

    $pathParts = @($path.Split([System.IO.Path]::DirectorySeparatorChar))
    $current = $parent
    foreach ($pathPart in $pathParts) {
        if ($pathPart) {
            $current = $current.GetFolder.items() | where {$_.Name -ieq $pathPart}
        }
    }

    return $current
}

function Is-LastDcfFolder {
    param([string]$lastDcfFolder, [string]$dcfFolder)

    return $dcfFolder -ieq $lastDcfFolder
}

function Is-NewDcfFolder {
    param([string]$lastDcfFolder, [string]$dcfFolder)

    return $dcfFolder -igt $lastDcfFolder
}

function Is-OldDcfFolder {
    param([string]$lastDcfFolder, [string]$dcfFolder)

    return $dcfFolder -ilt $lastDcfFolder
}

function Get-MaxDcfFolder {
    param([string]$maxDcfFolder, [string]$dcfFolder)

    if ($dcfFolder -igt $maxDcfFolder) {
        return $dcfFolder
    }

    return $maxDcfFolder
}

function Is-NewNumberedDcfFile {
    param([string]$dcfFilePrefix, [string]$dcfEditFilePrefix, [int]$lastDcfFileNumber, [string]$dcfFileName)

    if ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\..*") {
        $dcfFileNumber = [int]($dcfFileName.Substring(4, 4))
        return $dcfFileNumber -gt $lastDcfFileNumber
    } elseif ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\..*") {
        $dcfFileNumber = [int]($dcfFileName.Substring(5, 4))
        return $dcfFileNumber -gt $lastDcfFileNumber
    }

    return $false
}

function Get-MaxDcfFileNumber {
    param([string]$dcfFilePrefix, [string]$dcfEditFilePrefix, [int]$maxDcfFileNumber, [string]$dcfFileName)

    if ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\..*") {
        $dcfFileNumber = [int]($dcfFileName.Substring(4, 4))
        if ($dcfFileNumber -gt $maxDcfFileNumber) {
            return $dcfFileNumber
        }
    } elseif ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\..*") {
        $dcfFileNumber = [int]($dcfFileName.Substring(5, 4))
        if ($dcfFileNumber -gt $maxDcfFileNumber) {
            return $dcfFileNumber
        }
    }

    return $maxDcfFileNumber
}


function Is-NonNumberedDcfFile {
    param([string]$dcfFilePrefix, [string]$dcfEditFilePrefix, [string]$dcfFileName)

    if ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\..*") {
        return $false
    } elseif ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\..*") {
        return $false
    }

    return $true
}

function Create-Folder {
    param([string]$folderPath)

    if (-not (Test-Path $folderPath)) {
        $created = New-Item -itemtype directory -path $folderPath
    }
}

function Get-Folder {
    param([string]$folderPath)

    $shell = Get-ShellProxy
    return $shell.Namespace($folderPath).self.GetFolder
}

function Create-TargetFolder {
  param([string]$targetPath, [string]$folderName)

    $targetFolderPath = Join-Path -path $targetPath -childPath $folderName
    Create-Folder -folderPath $targetFolderPath
    $targetFolder = Get-Folder -folderPath $targetFolderPath

    return $targetFolder
}

function Get-TargetFolder {
    param([string]$dcfFileName, [string]$dcfFilePrefix, [object]$targetPhotosFolder, [object]$targetVideosFolder, [object]$targetSidecarsFolder, [object]$targetScreenshotsFolder, [object]$targetOthersFolder)

    if (($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.JPG") -or ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.HEIC") -or ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.TIF")  -or ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.DNG")) {
        return $targetPhotosFolder
    } elseif ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.MOV") {
        return $targetVideosFolder
    } elseif (($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\.JPG") -or ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\.HEIC") -or ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\.TIF")  -or ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\.DNG") -or ($dcfFileName -imatch "${dcfEditFilePrefix}\d{4}\.MOV") -or ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.AAE")) {
        return $targetSidecarsFolder
    } elseif ($dcfFileName -imatch "${dcfFilePrefix}\d{4}\.PNG") {
        return $targetScreenshotsFolder
    }

    return $targetOthersFolder
}

function Copy-File {
    param([object]$file, [object]$targetFolder)

    if ($targetFolder.ParseName($file.Name)) {
        return $SKIPPED
    } else {
        $targetFolder.CopyHere($file)
        if (!$targetFolder.ParseName($file.Name)) {
            return $FAILED
        } else {
            return $OK
        }
    }
}

function Move-File {
    param([object]$file, [object]$targetFolder)

    if ($targetFolder.ParseName($file.Name)) {
        return $SKIPPED
    } else {
        $targetFolder.MoveHere($file)
        if (!$targetFolder.ParseName($file.Name)) {
            return $FAILED
        } else {
            return $OK
        }
    }
}

function Log-DeviceFileCopy {
    param([string]$deviceName, [string]$dcimPath, [string]$dcfFolderName, [string]$dcfFileName, [string]$targetFolderPath)

    $sourceFile = Join-Path -path $deviceName -childPath $dcimPath | Join-Path -childPath $dcfFolderName | Join-Path -childPath $dcfFileName
    $targetFile = Join-Path -path $targetFolderPath -childPath $dcfFileName

    Write-Host "DEBUG - Copying DCF file '$sourceFile' to '$targetFile'... " -noNewline
}

function Log-LocalFileMove {
    param([string]$sourceFolderName, [string]$sourceFileName, [string]$targetFolderName, [string]$targetFileName)

    $sourceFile = Join-Path -path $sourceFolderName -childPath $sourceFileName
    $targetFile = Join-Path -path $targetFolderName -childPath $targetFileName

  Write-Host "DEBUG - Moving DCF file '$sourceFile' to '$targetFile'... " -noNewline
}

function Log-FileStatus {
    param([string]$status)

    if ($status -ieq $OK) {
            Write-Host "$status" -foregroundColor green
    } elseif ($status -ieq $SKIPPED) {
            Write-Host "$status" -foregroundColor yellow
    } elseif ($status -ieq $IGNORED) {
            Write-Host "$status" -foregroundColor cyan
    } elseif ($status -ieq $FAILED) {
            Write-Host "$status" -foregroundColor red
    } else {
            Write-Host "$status"
    }
}

function Log-DeviceFolderCopy {
    param([string]$deviceName, [string]$dcimPath, [string]$dcfFolderName, [string]$message)

    $sourceFolder = Join-Path -path $deviceName -childPath $dcimPath | Join-Path -childPath $dcfFolderName
    Write-Host "INFO - $message '$sourceFolder'"
}

function Log-LocalFolderMove {
    param([string]$sourceFolderName, [string]$targetFolderName)

    Write-Host "INFO - Moving non-camera files from '$sourceFolderName' to '$targetFolderName'"
}

function Log-MaxDcfFolderAndFileNumber {
    param([string]$maxDcfFolder, [int]$maxDcfFileNumber)

    Write-Host "INFO - Copied DCF files up to and including dcfFolder '$maxDcfFolder' and dcfFileNumber '$maxDcfFileNumber'"
}

#
# MAIN
#

$device = Get-Device -deviceName $deviceName
if (!$device) {
    Write-Error "Unable to access device '$deviceName' (ensure the device is connected)" -category DeviceError -errorAction Stop
}

$dcimFolder = Get-SubFolder -parent $device -path $dcimPath
if (!$dcimFolder) {
    Write-Error "Unable to access DCIM folder '$dcimPath' on device '$deviceName' (ensure access has been granted)" -category ReadError -errorAction Stop
}

$targetPath = Resolve-Path $targetPath
$targetPhotosFolder = Create-TargetFolder -targetPath $targetPath -folderName $photosFolder
$targetVideosFolder = Create-TargetFolder -targetPath $targetPath -folderName $videosFolder
$targetSidecarsFolder = Create-TargetFolder -targetPath $targetPath -folderName $sidecarsFolder
$targetScreenshotsFolder = Create-TargetFolder -targetPath $targetPath -folderName $screenshotsFolder
$targetOthersFolder = Create-TargetFolder -targetPath $targetPath -folderName $othersFolder

$maxDcfFolder = $lastDcfFolder
$maxDcfFileNumber = $lastDcfFileNumber

$dcfFolders = @($dcimFolder.GetFolder.items() | Sort-Object -property Name)
foreach ($dcfFolder in $dcfFolders) {
    $maxDcfFolder = Get-MaxDcfFolder -maxDcfFolder $maxDcfFolder -dcfFolder $dcfFolder.Name

    if (Is-LastDcfFolder -lastDcfFolder $lastDcfFolder -dcfFolder $dcfFolder.Name) {
        Log-DeviceFolderCopy -deviceName $deviceName -dcimPath $dcimPath -dcfFolderName $dcfFolder.Name -message "Copying new DCF files from last DCF folder"

        $dcfFiles = @($dcfFolder.GetFolder.items() | Sort-Object -property Name)
        foreach ($dcfFile in $dcfFiles) {
            $maxDcfFileNumber = Get-MaxDcfFileNumber -dcfFilePrefix $dcfFilePrefix -dcfEditFilePrefix $dcfEditFilePrefix -maxDcfFileNumber $maxDcfFileNumber -dcfFileName $dcfFile.Name
            $targetFolder = Get-TargetFolder -dcfFileName $dcfFile.Name -dcfFilePrefix $dcfFilePrefix -targetPhotosFolder $targetPhotosFolder -targetVideosFolder $targetVideosFolder -targetSidecarsFolder $targetSidecarsFolder -targetScreenshotsFolder $targetScreenshotsFolder -targetOthersFolder $targetOthersFolder

            Log-DeviceFileCopy -deviceName $deviceName -dcimPath $dcimPath -dcfFolderName $dcfFolder.Name -dcfFileName $dcfFile.Name -targetFolderPath $targetFolder.self.Path
            if (Is-NewNumberedDcfFile -dcfFilePrefix $dcfFilePrefix -dcfEditFilePrefix $dcfEditFilePrefix -lastDcfFileNumber $lastDcfFileNumber -dcfFileName $dcfFile.Name) {
                # copy new numbered DCF files from last DCF folder
                $status = Copy-File -file $dcfFile -targetFolder $targetFolder
                Log-FileStatus $status
            } elseif (Is-NonNumberedDcfFile -dcfFilePrefix $dcfFilePrefix -dcfEditFilePrefix $dcfEditFilePrefix -dcfFileName $dcfFile.Name) {
                # copy all non numbered DCF files from last DCF folder
                $status = Copy-File -file $dcfFile -targetFolder $targetFolder
                Log-FileStatus $status
            } else {
                # ignore old numbered DCF files from last DCF folder
                Log-FileStatus $IGNORED
            }
        }
    } elseif (Is-NewDcfFolder -lastDcfFolder $lastDcfFolder -dcfFolder $dcfFolder.Name) {
        Log-DeviceFolderCopy -deviceName $deviceName -dcimPath $dcimPath -dcfFolderName $dcfFolder.Name -message "Copying all DCF files from new DCF folder"

        $dcfFiles = @($dcfFolder.GetFolder.items() | Sort-Object -property Name)
        foreach ($dcfFile in $dcfFiles) {
            $maxDcfFileNumber = Get-MaxDcfFileNumber -dcfFilePrefix $dcfFilePrefix -dcfEditFilePrefix $dcfEditFilePrefix -maxDcfFileNumber $maxDcfFileNumber -dcfFileName $dcfFile.Name
            $targetFolder = Get-TargetFolder -dcfFileName $dcfFile.Name -dcfFilePrefix $dcfFilePrefix -targetPhotosFolder $targetPhotosFolder -targetVideosFolder $targetVideosFolder -targetSidecarsFolder $targetSidecarsFolder -targetScreenshotsFolder $targetScreenshotsFolder -targetOthersFolder $targetOthersFolder

            Log-DeviceFileCopy -deviceName $deviceName -dcimPath $dcimPath -dcfFolderName $dcfFolder.Name -dcfFileName $dcfFile.Name -targetFolderPath $targetFolder.self.Path
            $status = Copy-File -file $dcfFile -targetFolder $targetFolder
            Log-FileStatus $status
        }
    } elseif (Is-OldDcfFolder -lastDcfFolder $lastDcfFolder -dcfFolder $dcfFolder.Name) {
        Log-DeviceFolderCopy -deviceName $deviceName -dcimPath $dcimPath -dcfFolderName $dcfFolder.Name -message "Skipping old DCF folder"
    }    else {
        Log-DeviceFolderCopy -deviceName $deviceName -dcimPath $dcimPath -dcfFolderName $dcfFolder.Name -message "Skipping non DCF folder"
    }
}

# Unfortunately Folder.GetDetailsOf() doesn't return extended file details such as 'Camera maker' and 'Camera model' when invoked on a DCIM file system. As a result we have to check all photos after they have been copied to a regular file system and verify whether they were actually taken with '$deviceName' by checking '$cameraMaker' and/or '$cameraModel'
Log-LocalFolderMove -sourceFolderName $targetPhotosFolder.self.Path -targetFolderName $targetOthersFolder.self.Path
$photoFiles = @($targetPhotosFolder.items() | Sort-Object -property Name)
foreach ($photoFile in $photoFiles) {
    if ($cameraMaker -and ($cameraMaker -ieq $targetPhotosFolder.GetDetailsOf($photoFile, 32))) {
        Continue
    }

    if ($cameraModel -and ($cameraModel -ieq $targetPhotosFolder.GetDetailsOf($photoFile, 30))) {
        Continue
    }

    Log-LocalFileMove -sourceFolderName $targetPhotosFolder.self.Path -sourceFileName $photoFile.Name -targetFolderName $targetOthersFolder.Self.Path -targetFileName $photoFile.Name
    $status = Move-File -file $photoFile -targetFolder $targetOthersFolder
    Log-FileStatus -status $status
}

Log-MaxDcfFolderAndFileNumber -maxDcfFolder $maxDcfFolder -maxDcfFileNumber $maxDcfFileNumber
