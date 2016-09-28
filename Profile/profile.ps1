
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

# Dot sourcing private function and script files
if (Test-Path $Global:LibPath\Profile\functions) {
    Get-ChildItem $Global:LibPath\Profile\functions -Recurse -Filter "*.ps1" -File | Foreach { 
        . $_.FullName
    }
}
if (Test-Path $Global:LibPath\Profile\scripts) {
    Get-ChildItem $Global:LibPath\Profile\scripts -Recurse -Filter "*.ps1" -File | Foreach { 
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
    Get-ChildItem $Global:LibPath\Modules *.psm1 -Recurse | ForEach-Object { Import-Module $_.FullName -force }
}

#PSDrives
if (test-path $Global:LibPath\Settings\psdrive.csv) {
    import-csv $Global:LibPath\Settings\psdrive.csv | New-ProfilePSDrive
}

if (Get-Service VMTools -ea SilentlyContinue) {
    New-ProfilePSDrive -name VMHost -Location "\\vmware-host\Shared Folders\$env:username\scripts" -Description "VMHost scripts"
}

#Path Adjustments
if (Test-Path $Global:LibPath\Settings\Add-ToPath.ini) {
    # get-content $Global:LibPath\Settings\Add-ToPath.ini | Add-ToPath
    Get-Content $Global:LibPath\Settings\Add-ToPath.ini | ForEach-Object { 
        $p=@{}
        $p.Directories = $_.split(",")[0]
        $p.Recurse = [bool] $_.split(",")[1]
        New-Object -TypeName psobject -Property $p 
    } | Add-ToPath
}
if (Test-Path $Global:LibPath\Settings\remove-frompath.ini) {
    get-content $Global:LibPath\Settings\remove-frompath.ini | Remove-FromPath
}

(Get-SplitEnvPath | Where-Object { -not $_.Exists }).Path | Remove-FromPath  ## Removes non-existent dirs from path

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
