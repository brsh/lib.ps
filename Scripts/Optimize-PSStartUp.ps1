<#
.SYNOPSIS
    Pre-compile .Net Assemblies
 
.DESCRIPTION
    "The Native Image Generator (Ngen.exe) is a tool that improves the performance of managed applications." So says the MSDN article (see Links). Basically, this script runs Ngen.exe to try to speed up PowerShell startup. Does it work? Well, PowerShell installation is supposed to do it, and it might, but sometimes, this seems to help. And sometimes, it doesn't. Only your hairdresser knows for sure. Use as directed by your physician.

    P.S. This is the fiest script created using my New-PSScript.ps1 script (ooh - lots of 'script' in that sentence). And I deleted most of the skeleton as unnecessary for this script. How's that for handy!

.EXAMPLE
     Optimize-PSStartUp.ps1

.LINK
    https://msdn.microsoft.com/en-us/library/6t9t5wcf(v=vs.110).aspx

#>

if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and (
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ) ) {

    Try {
        "Searching for the most recent Ngen.exe..."
        $Path = Join-Path -Path $env:windir -ChildPath "Microsoft.NET"

	    if($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
	    	$Path = Join-Path -Path $Path -ChildPath "Framework64\"
	    }
	    else {
	    	$Path = Join-Path -Path $Path -ChildPath "Framework\"
        }
        $Ngen = (Get-ChildItem C:\WINDOWS\Microsoft.NET\Framework64 -Filter "ngen.exe" -Recurse | sort LastWriteTime -Descending | Where-Object {$_.Length -gt 0} | Select-Object -First 1).FullName
        "Found $Ngen"

        "Attempting to Optimize Assemblies..."
        [System.AppDomain]::CurrentDomain.GetAssemblies() | ForEach { 
            if ($_.Location) {
                if (test-path $_.Location) { 
                    [string] $Arguments = 'install "'
                    $Arguments += $_.Location
                    $Arguments += '" /nologo /verbose'
                    Start-Process $ngen -ArgumentList $Arguments -Wait -NoNewWindow 
                } 
            }
        }
    }
    Catch {
        "Failed to run/complete optimization."
        $_.Exception.Message
    }

} else {
    "Please run this script as an Administrator"
}