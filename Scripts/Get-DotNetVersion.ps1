<#PSScriptInfo
.VERSION 1.1
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
    Find Version Numbers for installed .Net Framework(s)

.DESCRIPTION
    Outputs a table of the currently installed versions of the .Net Framework
	(current as of 4.7.2 and Core 2.2.2 and Feb. 20, 2019). It lists the
	Framework/Component Name, the actual version of that Framework/Component,
	and any install Service Pack (if applicable).

    Please note the following:
        1.0 and 1.1 don't exist anymore, so don't look for them
        2.0 covers for versions 1 and 1.1 (which still don't exist; get over it)
        3.5 includes versions 3.0 and 2.0 (and, thence, 1.1 and 1.0 - but really, just let them go already)
        4.0 is deprecated, obfuscated, emulated, and actually the installed version of 4.5, 4.6, 4.7, etc.
		.Net Core has SO MANY .. um .. a lot of components with versions ... and it's getting to be worse than non-Core!

	The .Net Core processing does not work  on PowerShell v2, but c'mon - you're not really running this on v2, are you?

.LINK
    https://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx
	https://dotnet.microsoft.com/download
	https://github.com/brsh/lib.ps

.EXAMPLE
    PS C:\> .\Get-DotNetVersion.ps1

    Name                              Version        SP  Code
	----                              -------        --  ----
	v2.0.50727                        2.0.50727.4927 2   n/a
	v3.0                              3.0.30729.4926 2   n/a
	v3.5                              3.5.30729.4926 1   n/a
	v4.0 Client                       4.7.03190      n/a 461814
	v4.0 Full                         4.7.03190      n/a 461814
	v4.7.2                            4.7.2          n/a 461814
	.NET Command Line Tools (2.1.103) 2.1.103        n/a 60218cecb5
	.NET Core Host                    2.2.2          n/a a4fd7b2c84
	.NET Core SDK                     2.1.2          n/a
	.NET Core SDK                     2.1.103        n/a
	.NET Core RunTime                 2.0.3          n/a
	.NET Core RunTime                 2.0.6          n/a
	.NET Core RunTime                 2.2.1          n/a
	.NET Core RunTime                 2.2.2          n/a
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
			} catch { $Code = "n/a" }
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
		461808 { $Name = "v4.7.2 on Windows 10 U18.04"; $Version = "4.7.2" }
		461814 { $Name = "v4.7.2"; $Version = "4.7.2" }
		528040 { $Name = "v4.8 on Windows 10 U19.05"; $Version = "4.8" }
		528049 { $Name = "v4.8"; $Version = "4.8" }
		{ $_ -gt 528049 } { $Name = "See $($website)"; $Version = "Greater than 4.8" }
		Default { $Name = "Uncertain"; $Version = $_ }
	}
	Out-VersionObject -name $Name -Version $Version -SP "n/a" -Code $Code
}

$core = get-command -Name dotnet.exe -ErrorAction SilentlyContinue
if ($core) {
	$core | ForEach-Object {
		try {
			$result = & $_.Name --info
			if ($result) {
				$result = $result | ForEach-Object { if ($_) { $_ } }
				$CLI = $result | Select-String "Command Line Tools" -Context 3 -List
				if ($CLI) {
					$ver = $CLI[0].Context.PostContext | Select-String "Version"
					$ver = $ver.Line.Split(":")[1].Trim()
					$hash = $CLI[0].Context.PostContext | Select-String "hash"
					$hash = $hash.Line.Split(":")[1].Trim()
					$name = $CLI[0].Line
					if ($name) {
						Out-VersionObject -Name $name -Version $ver -SP "n/a" -Code $hash
					}
				}
				$Frame = $result | Select-String "Framework Host" -Context 0, 3 -List
				if ($Frame) {
					$ver = $Frame[0].Context.PostContext | Select-String "Version"
					$ver = $ver.Line.Split(":")[1].Trim()
					$hash = $Frame[0].Context.PostContext | Select-String "build"
					$hash = $hash.Line.Split(":")[1].Trim()
					$name = $Frame.Line
					if ($name) {
						Out-VersionObject -Name $name.Replace('Microsoft', '').Trim() -Version $ver -SP "n/a" -Code $hash
					}
				}
				$Hostver = $result | Select-String "^Host " -Context 0, 2 -List
				if ($Hostver) {
					$ver = $Hostver[0].Context.PostContext | Select-String "Version"
					$ver = $ver.Line.Split(":")[1].Trim()
					$hash = $Hostver[0].Context.PostContext | Select-String "commit"
					$hash = $hash.Line.Split(":")[1].Trim()
					$name = ".NET Core $($Hostver.Line.Replace(' (useful for support)', '').Replace(':', ''))"
					if ($name) {
						Out-VersionObject -Name $name.Replace('Microsoft', '').Trim() -Version $ver -SP "n/a" -Code $hash
					}
				}
				$SDK = $result | Select-String "dotnet\\sdk]$" -List
				if ($SDK) {
					$sdk | ForEach-Object {
						$ver = ($_.ToString().Trim() -split ' ')[0]
						$name = ".NET Core SDK"
						if ($ver) {
							Out-VersionObject -Name $name -Version $ver -SP "n/a" -Code ''
						}
					}
				}
				$Runtime = $result | Select-String "Microsoft.NETCore.App" -List
				if ($Runtime) {
					$Runtime | ForEach-Object {
						$ver = ($_.ToString().Trim() -split ' ')[1]
						$name = ".NET Core RunTime"
						if ($ver) {
							Out-VersionObject -Name $name -Version $ver -SP "n/a" -Code ''
						}
					}
				}
			}
		} catch {
			Write-Host ''
			Write-Host "Could not process/parse .Net Core via 'dotnet --info'" -ForegroundColor Yellow
			if ($PSVersionTable.PSVersion.Major -eq 2) {
				Write-Host '  Why are you still running PowerShell v2?!?!' -ForegroundColor Red
			}
		}
	}
}

