<#PSScriptInfo
.VERSION 1.0
.GUID 52a851cf-be7b-4a16-8dea-7cbf836f3c40
.AUTHOR bsheaffer
.COMPANYNAME
.COPYRIGHT
.TAGS
.LICENSEURI https://github.com/brsh/lib.ps/blob/master/LICENSE.md
.PROJECTURI
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
#>

<#
.SYNOPSIS
    Find Version Numbers for .Net Framework

.DESCRIPTION
    Outputs a table of the currently installed versions of the .Net Framework (current as of 4.6.2 and Dec. 8, 2016). It lists the Framework Name, the actual version of that Framework, and any install Service Pack (if applicable).

    Please note the following:
        1.0 and 1.1 don't exist anymore, so don't look for them
        2.0 covers for versions 1 and 1.1 (which still don't exist; get over it)
        3.5 includes versions 3.0 and 2.0 (and, thence, 1.1 and 1.0 - but really, just let them go already)
        4.0 is deprecated, obfuscated, emulated, and actually the installed version of 4.5, 4.6, 4.7, etc.

.LINK
    https://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx

.EXAMPLE
    PS C:\> .\Get-DotNetVersion.ps1

    Name        Version        SP
    ----        -------        --
    v2.0.50727  2.0.50727.4927 2
    v3.0        3.0.30729.4926 2
    v3.5        3.5.30729.4926 1
    v4.0 Client 4.6.01586      n/a
    v4.0 Full   4.6.01586      n/a
    v4.6        4.6.2          n/a
#>


function Out-VersionObject {
	param ( [string] $Name, [string] $Version, [string] $SP, [string] $Code )

	$InfoHash = @{
		Name    = $Name
		Version = $Version
		SP      = $SP
		Code    = $Code
	}

	$InfoStack = New-Object -TypeName PSObject -Property $InfoHash

	#Add a (hopefully) unique object type name
	$InfoStack.PSTypeNames.Insert(0, "DotNet.Version")

	#Sets the "default properties" when outputting the variable... but really for setting the order
	$defaultProperties = @('Name', 'Version', 'SP', 'Code')
	$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’, [string[]]$defaultProperties)
	$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
	$InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers

	$InfoStack
}

[string] $website = 'https://msdn.microsoft.com/en-us/library/hh925568.aspx'
Write-Host "For more information, see ${website}"

# .Net less than 4.0
if (test-path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP') {
	Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\*' | ForEach-Object {
		if ($_.Version) {
			if ($_.SP) { $SP = [string] $_.SP } else { $SP = [string] "n/a" }
			Out-VersionObject -name $_.PSChildName -Version $_.Version -SP $SP -Code 'n/a'
		}
	}
}

# .Net 4.0
if (test-path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4') {
	Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\*' | ForEach-Object {
		if ($_.Version) {
			try {
				$Code = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\$($_.PSChildName)\").Release
			} catch { $Code = "n/a"}
			Out-VersionObject -name "v4.0 $($_.PSChildName)" -Version $_.Version -SP "n/a" -Code $Code
		}
	}
}

# .Net 4.5,  4.6, and 4.7 (so far)
if (test-path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033\') {
	$Code = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033\').Release
	switch ($Code) {
		378389 { $Name = "v4.5"; $Version = "4.5" }
		378675 { $Name = "v4.5 on Windows 8.1"; $Version = "4.5.1" }
		378758 { $Name = "v4.5 on Windows 8, 7SP1, or Vista SP2"; $Version = "4.5.1" }
		379893 { $Name = "v4.5"; $Version = "4.5.2" }
		393295 { $Name = "v4.6 on Windows 10"; $Version = "4.6" }
		393297 { $Name = "v4.6"; $Version = "4.6" }
		394254 { $Name = "v4.6 on Windows 10"; $Version = "4.6.1" }
		394271 { $Name = "v4.6"; $Version = "4.6.1" }
		394802 { $Name = "v4.6 on Windows 10 AU"; $Version = "4.6.2" }
		394806 { $Name = "v4.6"; $Version = "4.6.2" }
		460798 { $Name = "v4.7 on Windows 10 CU"; $Version = "4.7" }
		460805 { $Name = "v4.7"; $Version = "4.7" }
		461308 { $Name = "v4.7.1 on Windows 10 FCU"; $Version = "4.7.1" }
		461310 { $Name = "v4.7.1"; $Version = "4.7.1" }
		{$_ -gt 461310} { $Name = "See $($website)"; $Version = "Greater than 4.7.1" }
		Default { $Name = "Uncertain"; $Version = $_ }
	}
	Out-VersionObject -name $Name -Version $Version -SP "n/a" -Code $Code
}
