PowerScripts
================
A collection of useful scripts for power users.

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

## Compatibility
* All PowerShell scripts were developed and tested with version 5.1.19041.546 on Windows 10 version 2004 (19041.572).

## License
**PowerScripts** is licensed under the MIT license.