
###################### Declarations #####################

$Global:IsAdmin=$False
    if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
          new-object Security.Principal.WindowsPrincipal (
             [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
             ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
    {
      $IsAdmin = $True
    } else {
      $IsAdmin = $False
    }

if(!$global:WindowTitlePrefix) {
    # if you're running "elevated" we want to show that ...
    If ($IsAdmin) {
       $global:WindowTitlePrefix = "PowerShell (ADMIN)"
    } else {
       $global:WindowTitlePrefix = "PowerShell"
    }
 }

 $Global:LibPath = $PSScriptRoot.Replace("\Profile", "")


################### Inits ######################

# Dot sourcing private script files
if (Test-Path $Global:LibPath\Profile\private) {
    Get-ChildItem $Global:LibPath\Profile\private -Recurse -Filter "*.ps1" -File | Foreach { 
        . $_.FullName
    }
}

function AddPSDefault([string]$name, $value) {
    if ($PSVersionTable.PSVersion -ge '3.0') {
        if ($PSDefaultParameterValues.Contains($name)) {
            $PSDefaultParameterValues.Remove($name)
        }
        $PSDefaultParameterValues.Add($name, $value)
    }
}

function Read-Profiles {
#Reload all profiles - helpful when editing/testing profiles
Set-Variable -name isDotSourced -value $False -Scope 0
$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
if (!($isDotSourced)) { write-host "You must dot source this function" -fore Red; write-host "`t. Load-Profiles`n`t. re-Profs" -ForegroundColor "Yellow"; return "" }
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | ForEach-Object {
        if(Test-Path $_){
            Write-Host "Loading $_"
            . $_
        }
    } 
}

New-Alias -name re-Profs -value Read-Profiles -Description "Reload profile files (must . source)" -Force

#Defaults
AddPSDefault "Format-Table:AutoSize" {if ($host.Name -eq 'ConsoleHost'){$true}}

#(Attempt to) Keep duplicates out of History
Set-PSReadLineOption –HistoryNoDuplicates:$True

#####################  Actual Work  #####################

#Modules
if (test-path $Global:LibPath\Modules) {
    #I recommend:
    #   changing the owner of the folder to "Administrators" or "Administrator"
    #   and removing read/write from general users (like 'Authenticated Users' or 'Everyone'... or your own account)
    #Just to restrict changes a little - just a little...
    Get-ChildItem $Global:LibPath\Modules *.psm1 -Recurse | ForEach-Object { Import-Module $_.FullName -force }
}

#PSDrives
if (test-path $Global:LibPath\Settings\psdrive.csv) {
    import-csv $Global:LibPath\Settings\psdrive.csv | New-ProfilePSDrive
}

if (Get-Service VMTools -ea SilentlyContinue) {
    New-ProfilePSDrive -name VMHost -Location "\\vmware-host\Shared Folders\$env:username\scripts" -Description "VMHost scripts"
}

## GitHub
if ((Test-Path $env:LOCALAPPDATA\GitHub\shell.ps1) -and ($env:github_git -eq $null)) { 
    #Ok, we have GitHub - let's make a profile psdrive
    New-ProfilePSDrive -name GitHome -Location $env:LOCALAPPDATA\GitHub -Description "Git program and source files"
    #Now I'll parse github's shell.ps1 - pulling out only the code I want
    ##   Anything that sets and environment variable (match $env at the start of a line)
    ##       But not the editor (notmatch EDITOR)
    ##       But not posh_git (notmach posh_git)
    ##   And add the variables needed for the Path statment (match $pGitPath, $appPath, $msBuildPath)
    #and run it as a script expression
    [String]$ShellCodeToRun = ""
    Get-Content $env:LOCALAPPDATA\GitHub\shell.ps1 | Where-Object { 
        (
            (($_.ToString().Trim() -match "^.env") `
            -and ($_ -notmatch "EDITOR") `
            -and ($_ -notmatch "posh_git")) `
            -or ($_.ToString().Trim() -match "^.pGitPath|^.appPath|^.msBuildPath") 
        )
    } | ForEach-Object { $ShellCodeToRun += $_ + ";" }
    if ($ShellCodeToRun.Length -gt 0) { 
        Try {
            Invoke-Expression $ShellCodeToRun 
        }
        Catch {
            write-host "Could not initialize Git!" -ForegroundColor Red -BackgroundColor Black
        }
    }
}

#Path Adjustments
if (Test-Path $Global:LibPath\Settings\Add-ToPath.ini) {
    get-content $Global:LibPath\Settings\Add-ToPath.ini | Add-ToPath
}
if (Test-Path $Global:LibPath\Settings\remove-frompath.ini) {
    get-content $Global:LibPath\Settings\remove-frompath.ini | Remove-FromPath
}

#Only do these next items the first time (initial load)...
if (!($isDotSourced)) { 
    #Create the "standard" aliases for programs
    Set-ProgramAliases
    
    #ShowHeader
    $Global:SnewToIgnore = "prompt", "PSConsoleHostReadline", "posh-git"
    Get-NewCommands
    
    GoHome
}
else { 
    #I hate littering the field with random variables
    remove-item variable:\isDotSourced 
}
