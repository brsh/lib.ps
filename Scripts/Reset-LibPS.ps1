<#
.SYNOPSIS
Resets/Re-Pulls LibPS from Github

.DESCRIPTION
I tend to do my developing on my working box - but do the actual update of the repo from a clean system.
(This is mostly because the working box is not allowed access to publish to the repo for various reasons).

This script abandons the changes (because they've already manually be copied to the clean box), and pulls
the 'official' version of the lib.ps without requiring a full delete/recreate.

All this does is wrap 'git reset --hard HEAD', 'git clean -df', and 'git pull' in a nice confirmation.

.PARAMETER Force
Required - this script will remove/change stuff. You gotta want it.

.EXAMPLE
Reset-LibPS.ps1 -Force

#>


[CmdletBinding()]
param (
	[Parameter(Mandatory = $false)]
	[Alias('Clobber')]
	[switch] $Force = $false
)

[System.Management.Automation.PathInfo] $CurrentDirectory = Get-Location
[bool] $DoIt = $false
[bool] $LetsDoThisThing = $false
[bool] $TestGit = $false
[bool] $TestLibPath = $false
$Escape = "$([char]27)"

## Tests
# test for git
try {
	$Git = (Get-Command git.exe -ErrorAction Stop).Source
	if ($Git) {
		$TestGit = $true
	}
} catch {
	$TestGit = $false
	Write-Host "Git.exe not found. You need git or this will not work." -ForegroundColor Red
	Write-Host "  Hint: Git should be in your path or local" -ForegroundColor Yellow
}

if ($LibPath) {
	try {
		Set-Location $LibPath -ErrorAction Stop
		$TestLibPath = $true
	} catch {
		$TestLibPath = $false
		Write-Host "Could not change dir to $($LibPath). What's up with that??" -ForegroundColor Red
		$_
	}
} else {
	$TestLibPath = $false
	Write-Host "LibPath variable not defined. Do you even Lib.PS, bro?" -ForegroundColor Red
	Write-Host "  Hint: Check your profile or use the Create-LibPS script..." -ForegroundColor Yellow
}

if (-not $Force) {
	Write-Host "This WILL reset Lib.PS!! You have to want it!" -ForegroundColor Red
	Write-Host "  Hint: Use the -Force option" -ForegroundColor Yellow
}

#Is this trip really happening?
if (($TestGit) -and ($TestLibPath) -and ($Force)) { $DoIt = $true}

if ($DoIt) {
	Write-Host ""
	try {
		Write-Host "This is what you'll be giving up:" -ForegroundColor Yellow
		write-host ""
		& $Git status
		write-host ""
	} catch {
		$DoIt = $false
		write-host ""
		Write-Host "Couldn't pull git status..." -ForegroundColor Red
		$_
		write-host ""
	}

	[string] $Title = "$Escape[0;91mThis WILL Reset Lib.PS!!!$Escape[0m"
	[string] $Info = "$Escape[1;33m`nAre you absolutely certain?$Escape[0m"

	$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
	[int] $DefaultChoice = 1
	$Response = $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

	switch ($Response) {
		0 { Write-Host "`nLet's do this thing!" -ForegroundColor Red; $LetsDoThisThing = $true }
		1 { Write-Host "`nOf course not, you're a sensible person" -ForegroundColor Green; $LetsDoThisThing = $false }
	}

	if ($LetsDoThisThing) {
		try {
			Write-Host ""
			Write-Host "Attempting reset..."
			& $Git reset --hard HEAD
			& $git clean -df
			& $Git pull
		} catch {
			Write-Host ""
			Write-Host "Could not reset or pull? That's not good" -ForegroundColor Red
			$_
		}
	}

}

try {
	Set-Location $CurrentDirectory.Path
} catch {
	Write-Host "Couldn't return to the previous directory. Weird, huh?" -ForegroundColor Red
	$_
}
Write-Host ""
Write-Host "All done." -ForegroundColor Green
Write-Host ""
