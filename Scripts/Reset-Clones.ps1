## Initializes (or RE-initializes) the Lib.PS Modules and Clones
## This is not intended to init the entire lib.ps .. 
## just the items that live under lib.ps\Moducles and lib.ps\Clones

if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
    new-object Security.Principal.WindowsPrincipal (
       [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
       ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
{
    get-content $LibPath\Settings\Get-Git-Clones.ini | get-GitModule.ps1 -Destination C:\Scripts\lib.ps\Clones\ -ReadOnly -Force
    get-content $LibPath\Settings\Get-GitModule.ini | get-GitModule.ps1 -Destination C:\Scripts\lib.ps\Modules -ReadOnly -Force
} else {
    "Please run this script as an Administrator"
}


