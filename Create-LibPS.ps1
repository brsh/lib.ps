<#

.SYNOPSIS
    Clone and init the lib.ps

.DESCRIPTION
    Tries to create and clone all the pieces of my lib.ps, putting everything in the proper place and sourcing as appropriate.

    Of course, it's not perfect and has not been tested in every conceivable configuration. It will throw errors, but they should be non-fatal.

    You will want to start a new instance of PowerShell and abandon the one you ran the script in :)

.EXAMPLE
    PS C:\> Create-LibPS.ps1

    Full on default mode

.EXAMPLE
    PS C:\> Create-LibPS.ps1 -Folder c:\MyScripts

    Save the library to C:\MyScripts rather than the default C:\Scripts

.EXAMPLE
    PS C:\> Create-LibPS.ps1 -WhatIf

    Don't do anything, but show me what you might have done...
#>



[CmdletBinding(SupportsShouldProcess)]
param (
	[Parameter(Mandatory = $false)]
	[string] $Folder = "C:\Scripts"
)

#For Writing/Troubleshooting purposes (and because I forget to set it at runtime)
$VerbosePreference = "Continue"
#$VerbosePreference="SilentlyContinue"

Function Read-Profiles {
	#Reload all profiles - helpful when editing/testing profiles
	Set-Variable -name isDotSourced -value $False -Scope 0
	$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
	if (!($isDotSourced)) {
		write-host "You must dot source this function" -fore Red; write-host "`t. Load-Profiles`n`t. re-Profs"
		-ForegroundColor "Yellow"; return ""
	}
	@(
		$Profile.AllUsersAllHosts,
		$Profile.AllUsersCurrentHost,
		$Profile.CurrentUserAllHosts,
		$Profile.CurrentUserCurrentHost
	) | ForEach-Object {
		if (Test-Path $_) {
			Write-Host "Re-loading $_"
			. $_
		}
	}
}

Function Remove-InvalidFileNameChars {
	param(
		[Parameter(Mandatory = $true, Position = 0)]
		[String] $Text
	)
	#Let's remove invalid filesystem characters and ones we just don't like in filenames
	$invalidChars = ([IO.Path]::GetInvalidFileNameChars() + "," + ";") -join ''
	$invalidChars = $invalidChars.Replace("\", "")
	$invalidChars = $invalidChars.Replace(":", "")
	$invalidChars = $invalidChars.Replace(" ", "")
	$re = "[{0}]" -f [RegEx]::Escape($invalidChars)
	$Text = $Text -replace $re
	return $Text
}

$Folder = Remove-InvalidFileNameChars $Folder

try {
	[System.Management.Automation.PathInfo] $FolderInfo = Resolve-Path $Folder -ErrorAction Stop
	[String] $HomeFolder = $FolderInfo.ProviderPath
} catch { $HomeFolder = $Folder }

if (-not $(Test-Path $HomeFolder -ErrorAction SilentlyContinue)) {
	$Title = "The Folder, $HomeFolder, does not exist. Create it?"
	$Info = "Would you like to continue?"

	$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
	[int] $DefaultChoice = 0
	$Response = $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

	switch ($Response) {
		0 { try { $HomeFolder = (new-item $HomeFolder -ItemType "Directory" -ErrorAction Stop).FullName } catch { "Couldn't create path $HomeFolder"; "$_"; exit }; break }
		1 { "Terminating script"; exit; break }
	}
}

Try {
	if ($pscmdlet.ShouldProcess($HomeFolder, "Set-Location")) {
		Set-Location $HomeFolder -ErrorAction Stop
	}
} catch {
	"Couldn't change directory to the new location $HomeFolder. Terminating script."
	exit
}

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

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.FileName = $git
[string] $output = ""

if ($pscmdlet.ShouldProcess("LibPS", "Cloning Repository")) {
	if (Test-Path $HomeFolder\Lib.PS -ErrorAction SilentlyContinue) {
		$Title = "Lib.PS is already installed under $HomeFolder. This will overwrite and reset it!"
		$Info = "Would you like to continue?"

		$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
		[int] $DefaultChoice = 1
		$Response = $host.UI.PromptForChoice($Title , $Info, $Options, $DefaultChoice)

		switch ($Response) {
			0 {
				try {
					set-location $HomeFolder\lib.ps
					[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
					"Starting git fetch..."
					$pinfo.Arguments = "fetch --all"
					$p = New-Object System.Diagnostics.Process
					$p.StartInfo = $pinfo
					$p.Start() | Out-Null
					$p.WaitForExit()
					$output = ""
					$output = $p.StandardError.ReadToEnd()
					if ($output -ne "") { throw "Error running 'git fetch --all'"}
					#$retval = Start-Process $git -ArgumentList "fetch --all" -Wait -NoNewWindow
					"Starting git reset..."
					$pinfo.Arguments = "reset --hard origin/master"
					$p = New-Object System.Diagnostics.Process
					$p.StartInfo = $pinfo
					$p.Start() | Out-Null
					$p.WaitForExit()
					$output = ""
					$output = $p.StandardError.ReadToEnd()
					if ($output -ne "") { throw "Error running 'git reset --hard origin/master'"}
					#$retval = Start-Process $git -ArgumentList "reset --hard origin/master" -Wait -NoNewWindow
					"Starting git pull..."
					$pinfo.Arguments = "pull origin master"
					$p = New-Object System.Diagnostics.Process
					$p.StartInfo = $pinfo
					$p.Start() | Out-Null
					$p.WaitForExit()
					$output = ""
					$output = $p.StandardError.ReadToEnd()
					#if ($output -ne "") { throw "Error running 'git pull origin master'"}
					#(fricken 'up-to-date' repo 'error')
					#$retval = Start-Process $git -ArgumentList "pull origin master" -Wait -NoNewWindow
				} catch {
					"Couldn't update/reset Lib.PS. Terminating script"
					"Git error was: $($output)"
					$_.Exception.Message
					exit
				} break
			}
			1 { "Terminating script"; exit; break }
		}
	} else {
		"Cloning Main Lib.PS"
		$retval = Start-Process $git -ArgumentList "clone https://github.com/brsh/lib.ps" -Wait -NoNewWindow
	}
}

if ($pscmdlet.ShouldProcess($PROFILE, "Adjusting default profile")) {
	try {
		"Updating your personal profile: $profile"
		$loadtext = @"
if (test-path $HomeFolder\lib.ps\Profile\profile.ps1) {
    . $HomeFolder\lib.ps\Profile\profile.ps1
}
"@
		[bool] $DoUpdateProfile = $true
		$profile | Get-Member *Host* | ForEach-Object { $_.name } |
			ForEach-Object {
			if (test-path ($profile).$_) {
				if (Get-Content ($profile).$_ | Where-Object { $_.Contains("lib.ps") }) {
					"Lib.ps exists in ($profile).$_ - Skipping."
					"You might want to adjust the profile manually by adjusting with the following:"
					$loadtext
					$DoUpdateProfile = $false
				}
			}
		}
		if ($DoUpdateProfile) {
			if (-not (test-path $profile)) { $null = New-item –type file –force $profile }
			$loadtext | Out-File -Append -FilePath $profile -Force
		}
	} Catch {
		"Couldn't update $profile"
		$_
		"You will need to adjust the profile manually by adding the following:"
		$loadtext
	}
	. Read-Profiles
}

if ($pscmdlet.ShouldProcess("Standard Modules/Scripts", "Cloning Sub-Repositories")) {
	if (test-path ".\lib.ps\Scripts\Reset-Clones.ps1") {
		.\lib.ps\Scripts\Reset-Clones.ps1 -Folder $HomeFolder\lib.ps
	}
	Set-Location ..
}



