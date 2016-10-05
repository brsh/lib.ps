<#
.SYNOPSIS
    Creates PowerShell module skeleton files (psm and psd)
 
.DESCRIPTION
    Creates a PowerShell module skeleton, complete with manifest and requisite folders (one for the module/manifest and the private subfolder) 

.PARAMETER Name
    Name of the script module

.PARAMETER Path
    Parent folder where it will create the script module; it must already exist.

.PARAMETER Author
    Specifies the author (defaults to AD Full Name)

.PARAMETER Description
    Description of the module

.EXAMPLE
     New-PSModule -Name Brontosaurus -Path "$env:ProgramFiles\WindowsPowerShell\Modules" -Author 'Anne Elk' -Description 'This is my module of brontosauruses'
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Name,
        
    [ValidateScript({
        If (Test-Path -Path $_ -PathType Container) {
            $true
        }
        else {
            Throw "'$_' is not a valid directory."
        }
    })]
    [String]$Path = (($env:PSModulePath).ToString().Split(";") -like "*\Users\*"),

    [Parameter(Mandatory=$false)]
    [string]$Author,

    [Parameter(Mandatory=$true)]
    [string]$Description
)

$Copyright = 'To the extent within my power and possible under law, the author(s) have dedicated all copyright and related and neighboring rights to the public domain worldwide. This is distributed without any warranty.'

Try {
    New-Item -Path $Path -Name $Name -ItemType Directory | Out-Null
    New-Item -Path $Path\$Name -Name "private" -ItemType Directory | Out-Null
}
Catch {
    "Could not create the directory structure."
    $_.Exception.Message
    return
}

Try {
    Out-File -FilePath "$Path\$Name\$Name.psm1" -Encoding utf8 -NoClobber
}
Catch {
    "Could not create the Module file."
    $_.Exception.Message
    return
}

$Template = @'
#region Private Variables
# Current script path
[string]$ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
#endregion Private Variables
 
#region Private Helpers
 
# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter "*.ps1" -File | Foreach { 
    . $_.FullName
}
#endregion Load Private Helpers
'@

Try {
    Add-Content -Path "$Path\$Name\$Name.psm1" -Value $Template
}
Catch {
    "Could not add skeleton content to file."
    $_.Exception.Message
    return
}

Try {
    New-ModuleManifest -Path "$Path\$Name\$Name.psd1" -RootModule $Name -Author $Author -Description $Description `
        -AliasesToExport $null -FunctionsToExport $null -VariablesToExport $null -CmdletsToExport $null -Copyright $Copyright
}
Catch {
    "Could not create the manifest."
    $_.Exception.Message
    return
}
