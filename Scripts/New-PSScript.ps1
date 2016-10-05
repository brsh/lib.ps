<#
.SYNOPSIS
    Creates PowerShell script skeleton file (ps1)
 
.DESCRIPTION
    Creates a PowerShell script skeleton, complete with initial Comment Help section and basic param options. 

.PARAMETER Name
    Name of the script

.PARAMETER Path
    Parent folder where it will create the script; it must already exist.

.PARAMETER Author
    Specifies the author (defaults to AD Full Name)

.PARAMETER Description
    Description of the module

.EXAMPLE
     New-PSScript -Name "Brontosaurus" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses'

.EXAMPLE
     New-PSScript -Name "Brontosaurus.PS1" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses'
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Alias('FileName')]
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        If (Test-Path -Path $_ -PathType Container) {
            $true
        }
        else {
            Throw "'$_' is not a valid directory."
        }
    })]
    [Alias('Directory','Folder')]
    [String]$Path = ($pwd.ProviderPath),
    [Parameter(Mandatory=$false)]
    [string]$Synopsis
)

if (-not $Name.ToUpper().EndsWith(".PS1")) { $Name = $Name.Trim() + ".ps1" }

Try {
    Out-File -FilePath "$Path\$Name" -Encoding utf8 -NoClobber
}
Catch {
    "Unable to create file in the path specified."
    $_.Exception.Message
    return
}

$Template = @"
<#
.SYNOPSIS
    $Synopsis
 
.DESCRIPTION
    Description

.PARAMETER Name
    Parameter Description

.EXAMPLE
     $Name -Parameter

#>
"@

Try {
    Add-Content -Path "$Path\$Name" -Value $Template
}
Catch {
    "Could not add skeleton Help content to file."
    $_.Exception.Message
    return
}

$Template = @'


[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="This should be helpful")]
    [Alias('Brand', 'Label', 'Term', 'Alias', 'Designation')]
    [string] $Name
)

BEGIN { }

PROCESS { }

END { }

'@

Try {
    Add-Content -Path "$Path\$Name" -Value $Template
}
Catch {
    "Could not add skeleton content to file."
    $_.Exception.Message
    return
}
