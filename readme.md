My Powershell Library

This sets up my PowerShell environment - including my profile and my "standard" scripts, modules, psdrives, and settings. Of course, to load everything, I still need to manually doctor a main PowerShell Profile file. I use the AllUsersCurrentHost, cuz I'm every user (hmm... reminds me of a song). 

Some of my standard functions ('snew' shows the current list; or 'snew -ModulesToo' to include loaded modules):

Command                   | Alias       | Description
-------                   | -----       | -----------
Add-ToPath                | PathAdd     | Adds a directory to the path
Find-Commands             | which       | Lists/finds commands with specified text
Find-Files                | find        | Search multiple folders for files
Find-InTextFile           | grep        | Grep with GSAR abilities
Get-Calendar              | cal         | Show current month calendar
Get-CurrentCalendar       | curcal      | Show previous, current, and next months
Get-LoadedModuleFunctions | glmf        | List functions from loaded modules
Get-NewCommands           | snew        | Show this list
Get-ProfilePSDrive        | PfDrive     | Drives created by PS Profile
Get-SplitEnvPath          | ePath       | Display the path environment var
GoHome                    | cd~         | Return to home directory
New-File                  | touch       | Create an empty file
New-TimestampedFile       | ntf         | Create a new file w/timestamped filename
Read-Profiles             | re-Profs    | Reload profile files (must . source)
Remove-FromPath           | PathDel     | Removes a directory from the path
Set-CountDown             | tminus      | Pause with a countdown timer
Test-Port                 | pp          | Test a TCP connection on the specified port

##### Script Folder / Security
My default folder location for scripting is, aptly, C:\Scripts. I keep this library, therefore, in C:\Scripts\libs.ps. For some degree of security, I adjust the permissions so that the Owner is "Administrator" from the local machine - then I remove Write permissions from any non-Administrator user/group. This forces a UAC prompt (or abject failure) if I try to modify anything without Admin elevation. If you're not familiar with NTFS and permissions, I recommend looking into them....

##### Ini Files
Well, they're not truly ini files, more like init files. Within the Settings folder are ini files that configure some of the settings. For example, I use the add-topath.ini file to specify directories to add to the PATH environment variable; and I use the remove-frompath.ini to specify directories to remove. I'm moving more and more of these items to ini files to minimize edits to the scripts themselves. I can add a new dir to the path by changing a ini file rather than edit (and someday, re-sign) the script.

That said, you might want to adjust these ini files as necessary for your environment (assuming there actually is a 'you' out there reading and using this).

#### To Install:

Download and extract the zip from: https://github.com/brsh/lib.ps/archive/master.zip (or clone this thing - your call).

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
Get-Content $libpath\Settings\Get-GitModule.ini | Get-GitModule.ps1 -ReadOnly -Verbose
```
You should also be able to add additional modules just by adding their urls to the ini file. For example (should work, but not tested):
```
https://github.com/dahlbyk/posh-git
```

