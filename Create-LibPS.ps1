[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory=$false)]
    [string] $Folder = "C:\Scripts"
)

#For Writing/Troubleshooting purposes (and because I forget to set it at runtime)
$VerbosePreference="Continue"
#$VerbosePreference="SilentlyContinue"

Function Remove-InvalidFileNameChars {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String] $Text
    )
    #Let's remove invalid filesystem characters and ones we just don't like in filenames
    $invalidChars = ([IO.Path]::GetInvalidFileNameChars() + "," + ";") -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    $Text = $Text -replace $re
    return $Text
}

$Folder = Remove-InvalidFileNameChars $Folder

try {
    [System.Management.Automation.PathInfo] $FolderInfo = Resolve-Path $Folder -ErrorAction Stop
    [String] $HomeFolder = $FolderInfo.ProviderPath
}
catch { $HomeFolder = $Folder }

if (-not $(Test-Path $HomeFolder -ErrorAction SilentlyContinue)) {
    $Title = "The Folder, $HomeFolder, does not exist. Create it?"
    $Info = "Would you like to continue?"

    $Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    [int] $DefaultChoice = 0
    $Response =  $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

    switch($Response) {
        0 { try { $null = new-item $HomeFolder -ItemType "Directory" -ErrorAction Stop } catch { "Couldn't create path $HomeFolder"; "$_"; exit }; break }
        1 { "Terminating script"; exit; break }
    }
}

Try {
    if ($pscmdlet.ShouldProcess($HomeFolder, "Set-Location")) {
        Set-Location $HomeFolder -ErrorAction Stop
    }
}
catch {
    "Couldn't change directory to the new location $HomeFolder. Terminating script."
    exit
 }

if ($pscmdlet.ShouldProcess("LibPS", "Cloning Repository")) {
    "Testing if git is in the path"
    $git = (get-command git.exe -ErrorAction SilentlyContinue).Source
    if (-not ($git)) {
        "Can't find git in path; trying GitHub's weird location..."
        $git = (get-command (Resolve-Path "C:\Users\*\AppData\Local\GitHub\PortableGit_*\cmd\git.exe" | Select-Object -First 1).Path -ErrorAction SilentlyContinue).Source
        if (-not ($git)) {
            "Can't find git; terminating script"
            exit
        }
    }

    "Cloning Main Lib.PS"
    $retval = Start-Process $git -ArgumentList "clone https://github.com/brsh/lib.ps" -Wait -NoNewWindow
    #. .\lib.ps\profile\profile.ps1
}

#if ($pscmdlet.ShouldProcess("Standard Modules/Scripts", "Cloning Sub-Repositories")) {
#    if (test-path ".\lib.ps\Scripts\Reset-Clones.ps1") {
#        .\lib.ps\Scripts\Reset-Clones.ps1
#    }
#}




