PowerScripts
================
A collection of useful scripts and run commands / dot files for power users on Windows and macOS.

## PowerShell
### Prerequisites
The PowerShell scripts in **PowerScripts** are not signed. Ensure the [execution policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) is set to ```Bypass``` or ```RemoteSigned``` to run the scripts. To [change the execution policy to ```Bypass``` for only one PowerShell session](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies#set-a-different-policy-for-one-session) start PowerShell as follows:

    > powershell -ExecutionPolicy Bypass

For execution policy ```RemoteSigned``` you may have to use the [```Unblock-File``` cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-7) if you [downloaded the scripts using a browser](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies#manage-signed-and-unsigned-scripts).

### Usage
Use the following [```Get-Help``` cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) commands to get usage information, parameter descriptions, examples, and additional information for all PowerShell scripts in **PowerScripts**:

    > Get-Help powerscripts\pwsh\<name>.ps1
    > Get-Help powerscripts\pwsh\<name>.ps1 -detailed
    > Get-Help powerscripts\pwsh\<name>.ps1 -examples
    > Get-Help powerscripts\pwsh\<name>.ps1 -full

### Scripts
#### CopyDcimFiles
[```CopyDcimFiles.ps1```](pwsh/CopyDcimFiles.ps1) is a PowerShell script to copy all or new DCF files (photos, videos, ...) from the [DCIM file system](https://en.wikipedia.org/wiki/Design_rule_for_Camera_File_system) of a device (smartphone, tablet, camera, drone, ...) to a Windows computer.

During the copy process the type of each DCF file (photo, video, sidecar, screenshot, other) is identified and the file is placed in a corresponding folder inside ```targetPath```.

#### CfaApps
[```CfaApps.ps1```](pwsh/CfaApps.ps1) is a PowerShell script to add / remove an executable or all executables in a directory to / from the list of applications allowed to access folders protected by [Controlled Folder Access](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/controlled-folders).

> **Note:** This PowerShell script requires ```Administrator``` privileges.

#### CfaDirs
[```CfaDirs.ps1```](pwsh/CfaDirs.ps1) is a PowerShell script to add / remove a directory to / from the list of directories protected by [Controlled Folder Access](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/controlled-folders).

> **Note:** This PowerShell script requires ```Administrator``` privileges.

#### ChangeNetworkCategory
[```ChangeNetworkCategory.ps1```](pwsh/ChangeNetworkCategory.ps1) is a PowerShell script to change the network category of a [connection profile](https://docs.microsoft.com/en-us/powershell/module/netconnection/?view=win10-ps).

> **Note:** This PowerShell script requires ```Administrator``` privileges.

#### NormalizeImageWidth
[```NormalizeImageWidth.ps1```](pwsh/NormalizeImageWidth.ps1) is a PowerShell script to normalize the width of all images in a folder.

The script first determines the width of the widest image and then adjusts all other images to have the same width.

> **Note:** This PowerShell script requires [ImageMagick](https://imagemagick.org/), more specifically the [```identify```](https://imagemagick.org/script/identify.php) and [```mogrify```](https://imagemagick.org/script/mogrify.php) commands, to be on the path.

> **Note:** This PowerShell script has been developed and tested with version 7.0.10-34 of ImageMagick.

#### Svg2Png
[```Svg2Png.ps1```](pwsh/Svg2Png.ps1) is a PowerShell script to convert all SVG images in a folder to PNG images.

> **Note:** This PowerShell script requires [ImageMagick](https://imagemagick.org/), more specifically the [```convert```](https://imagemagick.org/script/convert.php) command, to be on the path.

> **Note:** This PowerShell script has been developed and tested with version 7.0.10-34 of ImageMagick.

#### RoboSync
[```RoboSync.ps1```](pwsh/RoboSync.ps1) is a PowerShell script that uses [Robocopy](https://en.wikipedia.org/wiki/Robocopy) to mirror a directory tree.

#### DeleteHiddenSystemFiles
[```DeleteHiddenSystemFiles.ps1```](pwsh/DeleteHiddenSystemFiles.ps1) is a PowerShell script to delete hidden and system files from a directory.

#### RunAs
[```RunAs.ps1```](pwsh/RunAs.ps1) is a PowerShell script to invoke another PowerShell scripts with elevated priviledges.

## Zsh
### Usage
Invoke Zsh scripts without arguments to get usage information. Use the following ```sed``` command to get parameter descriptions, examples, and additional information for all Zsh scripts in **PowerScripts**:

    $ sed -n '/###/,/###/p' powerscripts\zsh\<name>.zsh

### Scripts
#### rsync
[```rsync.zsh```](zsh/rsync.zsh) is a Zsh script that uses rsync to mirror a directory tree.

## Run Commands / Dot Files
### Description
The [```rc```](rc/) folder contains various [run commands](https://en.wikipedia.org/wiki/Run_commands) / [dot files](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory#Unix_and_Unix-like_environments) for command line shells and tools.

### Zsh
To show Git branch and action information in an additional right hand side prompt in Zsh add the following lines to the [```.zshrc```](rc/_macos_/.zshrc) file.

    setopt PROMPT_SUBST
    
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' formats '[%F{green}%b%f]'
    zstyle ':vcs_info:git:*' actionformats '[%F{red}%a%f|%F{green}%b%f]'
    
    export RPROMPT='${vcs_info_msg_0_}'

    autoload -U vcs_info && precmd_vcs_info() {vcs_info} && precmd_functions+=(precmd_vcs_info)

### Powershell
To get Git command auto completion install [posh-git](https://github.com/dahlbyk/posh-git) and then add the following lines to the [```profile.ps1```](rc/_windows_/profile.ps1) file.

    Import-Module posh-git

## Compatibility
* All PowerShell scripts were developed and tested with version 5.1.19041.546 on Windows 10 version 2004 (19041.572).
* All Zsh scripts were developed and tested with version 5.8 on macOS Big Sur 11.1.

## License
**PowerScripts** is licensed under the MIT license.