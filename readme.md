My Powershell Library

This sets up my PowerShell environment - including my profile and my "standard" scripts and modules. Of course, to load everything, I still need to manually doctor a main PowerShell Profile file. I use the AllUsersCurrentHost, cuz I'm every user (hmm... reminds me of a song). 

My default folder location for scripting is, aptly, C:\Scripts. I keep this library, therefore, in C:\Scripts\libs.ps. For some degree of security, I adjust the permissions so that the Owner is "Administrator" from the local machine - then I remove Write permissions from any non-Administrator user/group. This forces a UAC prompt (or abject failure) if I try to modify anything without Admin elevation. If you're not familiar with NTFS and permissions, I recommend looking into them....

So, to use this pick your profile file:

name                   | path
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

To Install:

Download and extract the zip from: https://github.com/brsh/lib.ps/archive/master.zip

To get my modules, after installing and loading the profile (either restart PowerShell or just dot source the profile.ps1), then run:
```
Get-GitModule.ps1 -url https://github.com/brsh/psSysInfo -Force -ReadOnly
Get-GitModule.ps1 -url https://github.com/brsh/psPrompt -Force -ReadOnly
Get-GitModule.ps1 -url https://github.com/brsh/psOutput -Force -ReadOnly
```
You should also be able to add additional modules just by specifying their urls


