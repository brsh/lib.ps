function New-ProfilePSDrive {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [String] $Name,
        [Parameter(Position=1, Mandatory=$true)]
        [String] $Location,
        [Parameter(Position=2, Mandatory=$false)]
        [String] $Description = ""
    )
    $ReturnTo = $false
    #Check if the drive already exists (can't create it if it does)
    if ($(Get-PSDrive -name $Name -ea SilentlyContinue ) -ne $null) { 
        #Check if we're currently pwd'd to it or a subfolder (we'll want to leave and return to it)
        if ($pwd.Path -match "$($Name):") {
            #Temporarily move to the un-PSDrive'd location
            Set-Location $($pwd.path.Replace("$($Name):", (Get-PSDrive $Name).Root))
            $ReturnTo = $true
        }
        Remove-PSDrive -Name $Name
        
    }
    if ($Description.Length -gt 0) { $Description = "PROF: $($Description)" }
    $null = New-PSDrive -Name $Name -PSProvider FileSystem -Root $Location -Scope Global -ea SilentlyContinue -Description $Description
    if ($ReturnTo) { 
        #Return to the PSDrive'd version
        $null = Set-Location $($pwd.path.Replace((Get-PSDrive $Name).Root, "$($Name):"))
    }
}

function Get-ProfilePSDrive {
    Get-PSDrive | Where-Object { $_.Description -match "PROF:"} | ft Name, Root, Description
}

New-Alias -Name PfDrive -Value Get-ProfilePSDrive -Description "Drives created by PS Profile" -Force
