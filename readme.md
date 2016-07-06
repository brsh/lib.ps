My Powershell Library

This sets up my PowerShell environment - including my profile and my "standard" scripts, modules, psdrives, and settings. Of course, to load everything, I still need to manually doctor a main PowerShell Profile file. I use the AllUsersCurrentHost, cuz I'm every user (hmm... reminds me of a song). 

Some of my standard functions (run 'snew' to see a more current list; or 'snew -ModulesToo' to include loaded modules):

Command                   | Alias       | Description
-------                   | -----       | -----------
Find-Commands             | which       | Lists/finds commands with specified text
Find-Files                | find        | Search multiple folders for files
Find-InTextFile           | grep        | Grep with GSAR abilities
Get-CurrentCalendar       | curcal      | Show previous, current, and next months
Get-LoadedModuleFunctions | glmf        | List functions from loaded modules
Get-ModuleDirs            | moddirs     | List the module directories
Get-NewCommands           | snew        | Show this list
Get-ProfilePSDrive        | PfDrive     | Drives created by PS Profile
Get-Profiles              | Profs       | List PowerShell profile files/paths
Get-SplitEnvPath          | ePath       | Display the path environment var
Get-WifiNetworks          | wifi        | List available wifi networks
GoHome                    | cd~         | Return to home directory
New-File                  | touch       | Create an empty file
New-TimestampedFile       | ntf         | Create a new file w/timestamped filename
Read-Profiles             | re-Profs    | Reload profile files (must . source)
Set-CountDown             | tminus      | Pause with a countdown timer
Test-Port                 | pp          | Test a TCP connection on the specified port
Test-ValidEmail           | isEmail     | Returns true if valid email
Test-ValidIPAddress       | isIP        | Tests for valid IP Address
Test-ValidMACAddress      | isMAC       | Returns true if valid MAC Address

My default folder location for scripting is, aptly, C:\Scripts. I keep this library, therefore, in C:\Scripts\libs.ps. For some degree of security, I adjust the permissions so that the Owner is "Administrator" from the local machine - then I remove Write permissions from any non-Administrator user/group. This forces a UAC prompt (or abject failure) if I try to modify anything without Admin elevation. If you're not familiar with NTFS and permissions, I recommend looking into them....

#### To Install:

Download and extract the zip from: https://github.com/brsh/lib.ps/archive/master.zip

Then, pick your preferred Profile file from:

Name                   | Path
----                   | ----
AllUsersAllHosts       | C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
AllUsersCurrentHost    | C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
CurrentUserAllHosts    | C:\Users\bshea\Documents\WindowsPowerShell\profile.ps1
CurrentUserCurrentHost | C:\Users\bshea\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

and add the following:
```
if (test-path C:\Scripts\lib.ps\Profile\profile.ps1) {
    . C:\Scripts\lib.ps\Profile\profile.ps1
}
```
To get my modules, after installing and loading the profile (either restart PowerShell or just dot source the profile.ps1), then run:
```
Get-GitModule.ps1 -url https://github.com/brsh/psSysInfo -Force -ReadOnly
Get-GitModule.ps1 -url https://github.com/brsh/psPrompt -Force -ReadOnly
Get-GitModule.ps1 -url https://github.com/brsh/psOutput -Force -ReadOnly
```
You should also be able to add additional modules just by specifying their urls. For example (should work, but not tested):
```
https://github.com/dahlbyk/posh-git
```

