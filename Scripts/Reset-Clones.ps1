## Initializes (or RE-initializes) the Lib.PS Modules and Clones
## This is not intended to init the entire lib.ps .. 
## just the items that live under lib.ps\Modules and lib.ps\Clones

if (-not $LibPath) {
    "The LibPath variable doesn't seem to be initialized."
    "Is Lib.PS cloned/installed?"
    return
}

if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
    new-object Security.Principal.WindowsPrincipal (
       [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
       ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
{

    if (-not (test-path $LibPath\Clones)) { 
        
        "Creating the Clones folder..." 
        try {
            mkdir "$LibPath\Clones" -ea stop | ForEach-Object { "   $_  -- Success" }
        }
        catch {
            "Could not create the folder."
            $_.Exception.Message
            return
        }
    }
    
    if (-not (test-path $LibPath\Modules)) { 
        "Creating the Modules folder..."
        try {
            mkdir "$LibPath\Modules" -ea stop | ForEach-Object { "   $_  -- Success" }
        }
        catch {
            "Could not create the folder."
            $_.Exception.Message
            return
        }
    }

    "Cloning the default scripts ($LibPath\Settings\Get-Git-Clones.ini):"
    get-content $LibPath\Settings\Get-Git-Clones.ini | ForEach-Object { "    $_" }
    get-content $LibPath\Settings\Get-Git-Clones.ini | get-GitModule.ps1 -Destination C:\Scripts\lib.ps\Clones -ReadOnly -Force -Verbose
    
    "Cloning the default Modules ($LibPath\Settings\Get-Git-Modules.ini):"
    get-content $LibPath\Settings\Get-Git-Modules.ini | ForEach-Object { "    $_" }
    get-content $LibPath\Settings\Get-Git-Modules.ini | get-GitModule.ps1 -Destination C:\Scripts\lib.ps\Modules -ReadOnly -Force -Verbose

} else {
    "Please run this script as an Administrator"
}


