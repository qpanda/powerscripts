PowerScripts
================
A collection of useful scripts for power users.

## PowerShell
### Prerequisites
The PowerShell scripts in **PowerScripts** are unsigned. Ensure the [execution policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) is set to ```Bypass``` or ```RemoteSigned``` to run the scripts. To [change the execution policy for only one PowerShell session](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies#set-a-different-policy-for-one-session) to ```Bypass``` start PowerShell as follows:

        powershell -ExecutionPolicy Bypass

For execution policy ```RemoteSigned``` you may have to use the [```Unblock-File``` cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-7) if you [downloaded the scripts using a browser](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies#manage-signed-and-unsigned-scripts).

### Usage
Use the [```Get-Help``` cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) as follows to get usage information, parameter descriptions, and examples for all PowerShell scripts in **PowerScripts**:

        Get-Help powerscripts\powershell\<name>.ps1
        Get-Help powerscripts\powershell\<name>.ps1 -detailed

### Scripts
#### CopyDcimFiles
[CopyDcimFiles.ps1](powershell/CopyDcimFiles.ps1) is a PowerShell script to copy all or new DCF files (photos, videos, ...) from the [DCIM file system](https://en.wikipedia.org/wiki/Design_rule_for_Camera_File_system) of a device (smartphone, tablet, camera, drone, ...) to a Windows computer.

During the copy process the type of each DCF file (photo, video, sidecar, screenshot, other) is identified and the file is placed in a corresponding folder inside ```targetPath```.

## Compatibility
* All PowerShell scripts were developed and tested with version 5.1.19041.546 on Windows 10 version 2004 (19041.572).

## License
**PowerScripts** is licensed under the MIT license.