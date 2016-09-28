function Get-ModuleDirs {
# Enum the module directories
    write-host "PowerShell Module Directories: " -fore White
    ($env:PSModulePath).Split(";",[StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { 
        $p = @{}
        $p.Path = $_
        $p.Exists = (test-path $_)
        New-Object -TypeName psobject -Property $P
    }
}

New-Alias -Name moddirs -Value Get-ModuleDirs -Description "List the module directories" -force

function Get-Profiles {
    #use to quickly check which (if any) profile slots are inuse
    write-host "PowerShell Profile Scripts: " -fore White
    $profile| Get-Member *Host*| `
        ForEach-Object { $_.name } | `
        ForEach-Object {
            $p=@{}
            $p.Name=$_
            $p.Path=$profile.$_
            $p.Exists=(test-path $profile.$_)
            New-Object -TypeName psobject -property $p
        }
}

New-Alias -name Profs -value Get-Profiles -Description "List PowerShell profile files/paths" -Force

function Get-SplitEnvPath {
  #display system path components in a human-readable format
    #write-host "Directories in the Path: " -fore White
    ($env:Path).Split(";",[StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { 
        $p = @{}
        $p.Path = $_
        $p.Exists = (test-path $_)
        New-Object -TypeName psobject -Property $P
    }
}

new-alias -name ePath -value Get-SplitEnvPath -Description "Display the path environment var" -Force

function Add-ToPath {
<#
    .SYNOPSIS
    Adds directory to the path
    .DESCRIPTION
    Adds a directory (or directories) to the path for the current (or child) instance(s) of PowerShell. The script will take pipeline info and will verify that the directory exists, is not already in the path, and is actually a directory (dropping any file name and extension).
    .PARAMETER Directories (Directory, Dir, Folder, ProviderPath)
    The folder/directory to add to the path
    .EXAMPLE
    Add-ToPath -folder c:\scripts\lib
    .EXAMPLE
    ".", "C:\Scripts\lib" | Add-ToPath
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$True, ValueFromPipeLineByPropertyName=$True, HelpMessage="What folder would you like to add?")]
        [Alias('dir','folder','directory','providerpath')]
        [string[]] $Directories
    )
    
    BEGIN { 
        $CurPath = $env:Path.Split(';')
    }

    PROCESS {
        ForEach ($Directory in $Directories) {
            [String] $Dir = ""
            Switch ($Directory) {
                # Is a normal directory
                { test-path $_ -PathType Container } { $Dir = (Resolve-Path $_).ProviderPath; break; }
                # Is a wildcard - add all subfolders
                { $Directory.EndsWith("*") }         { $Dir = (Resolve-Path $_ | Where-Object { Test-Path $_ -PathType Container }).ProviderPath -join ';'; break; }
                # Is a file, add the parent folder
                { test-path $_ -PathType leaf }      { $Dir = (Resolve-Path (Split-Path $_ -Parent)).ProviderPath; break; }
            }

            if ($Dir.Length -gt 0) {
                if ($CurPath -contains $Dir) {
                    Write-Verbose "$Dir already exists in the path"
                }
                else {
                    $CurPath += $Dir
                    Write-Verbose "Added $Dir to path"
                }
            }
            else { Write-Verbose "$Directory not added to path - it is not a valid directory" }
        }
    }

    END {
        $env:Path = [String]::Join(';', $CurPath)
    }
}

Set-Alias -name PathAdd -Value Add-ToPath -Description "Adds a directory to the path" -Force

function Remove-FromPath {
<#
    .SYNOPSIS
    Removes a directory from the path
    .DESCRIPTION
    Removes a directory (or directories) from the path for the current (or child) instance(s) of PowerShell. The script will take pipeline info and will verify that the directory is already in the path.
    .PARAMETER Directories (Directory, Dir, Folder, ProviderPath)
    The folder/directory to remove from the path
    .EXAMPLE
    Remove-FromPath -folder c:\scripts\lib.ps
    .EXAMPLE
    ".", "C:\Scripts\lib.ps" | Remove-FromPath
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$True, ValueFromPipeLineByPropertyName=$True, HelpMessage="What folder would you like to remove?", Position=0)]
        [Alias('dir','folder','directory','providerpath')]
        [string[]] $Directories,
        [Parameter(Mandatory=$false, Position=1)]
        [Alias('show', 'diff')]
        [Switch] $ShowDifference = $false
    )
    
    BEGIN { 
        $CurPath = ";${env:Path};"
        if ($ShowDifference) { "--Before--"; Get-SplitEnvPath } 
    }

    PROCESS {
        ForEach ($Directory in $Directories) {
            $CurPath = $CurPath -iReplace [regex]::Escape(";${Directory};"), ";"
            Write-Verbose "Tried to remove $Directory from path"
        }
    }

    END {
        $CurPath = $CurPath.Split(';',[StringSplitOptions]::RemoveEmptyEntries)
        $env:Path = [String]::Join(';', $CurPath)
        if ($ShowDifference) { "--After--"; Get-SplitEnvPath } 
    }
}

Set-Alias -name PathDel -Value Remove-FromPath -Description "Removes a directory from the path" -Force

