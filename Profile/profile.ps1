﻿<#
.SYNOPSIS
	Load All The Lib.PS Things!
.DESCRIPTION
	This is the "master" loader for all things Lib.PS. This sets defaults,
	loads modules, sources scripts and functions... all the stuff that
	Lib.PS includes happens because of this file.

	This is the file you reference in your PowerShell profile. You pick which
	profile via the following:

        write-host "PowerShell Profile Scripts: " -fore White
        $profile | Get-Member *Host* | ForEach-Object {
                $_.name
        } | ForEach-Object {
                $p = @{}
                $p.Name = $_
                $p.Path = $profile.$_
                $p.Exists = (test-path $profile.$_)
                New-Object -TypeName psobject -property $p
		}

	Note: that code is available in the Lib.PS as Get-Profiles (alias as profs).

	Then add this code snippet to the appropriate profile:

		if (test-path C:\Scripts\lib.ps\Profile\profile.ps1) {
			. C:\Scripts\lib.ps\Profile\profile.ps1
		}

	Of course, correct the path to the file if you're not using the default.
	You would also set any command line params in that code too.

	Once this profile is active, you'll have access to the Read-Profiles function
	(aliased as re-profs) which reloads all available profile files (see the
	list from the first code snippet above). Of course, you must . source the
	Read-Profiles function :)

		. read-profiles
		or
		. re-profs


.EXAMPLE
	PS C:\> . c:\Scripts\lib.ps\Profile\profile.ps1

	Loads the profile in the current session (assuming it wasn't loaded automatically)
.PARAMETER NoExcuses
	Doesn't run the Get-Excuses script at PowerShell console start
.PARAMETER NoDayInHistory
	Doesn't run the Get-ThisDayInHistory script at PowerShell console start
.PARAMETER IsDebug
    Displays timing information as the profile loads. Handy for troubleshooting slowdowns
#>
param (
	[switch] $NoExcuses = $false,
	[switch] $NoDayInHistory = $false,
	[switch] $IsDebug = $false
)
###################### Declarations #####################


[string] $Activity = 'Startup'
[string] $SubActivity = ''
[int] $counter = 0
[int] $TotalPercent = 0


Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

function Write-DebugMessage {
	param (
		[string[]] $Message
	)
	[string] $now = (Get-Date).TimeOfDay.ToString()
	[int] $i = 0
	foreach ($line in $Message) {
		if ($i -eq 0) {
			Write-Host $now -NoNewline -ForegroundColor Cyan
		} else {
			Write-Host (' ' * $now.length) -NoNewline -ForegroundColor Cyan
		}
		Write-Host " $line" -ForegroundColor Magenta
		$i += 1
	}
}

$Activity = 'IsAdmin: Testing'
$TotalPercent += 10
Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity
if ($IsDebug) { Write-DebugMessage $Activity }

$Global:IsAdmin = $False
if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
		New-Object Security.Principal.WindowsPrincipal (
			[Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ) {
	$Global:IsAdmin = $True
} else {
	$Global:IsAdmin = $False
}
if ($IsDebug) { Write-DebugMessage "IsAdmin: $Global:IsAdmin" }

if ($PSVersionTable.PSVersion.Major -eq 2) {
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}

$Global:LibPath = $PSScriptRoot.Replace("\Profile", "")

################### Inits ######################

$Activity = 'Init Functions...'
$TotalPercent += 10
Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

# Dot sourcing private function and script files
if (Test-Path $Global:LibPath\Profile\functions) {
	Write-Progress -Id 1 -Activity 'Sourcing Functions...' -PercentComplete 0 -Status 'Starting'

	$counter = 0
	$functions = Get-ChildItem $Global:LibPath\Profile\functions -Recurse -Filter "*.ps1"
	$functions | ForEach-Object {
		if (-not $_.PSIsContainer) {
			$counter ++
			$SubActivity = "Functions: Dot Sourcing $($_.Name)"
			if ($IsDebug) { Write-DebugMessage $SubActivity }
			Write-Progress -Id 1 -Activity 'Sourcing Functions...' -PercentComplete (($Counter / $functions.count) * 100) -Status $SubActivity
			. $_.FullName
		}
	}
	Write-Progress -Id 1 -Activity 'Sourcing Functions...' -Completed
}

$Activity = 'Init Scripts...'
$TotalPercent += 10
Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

if (Test-Path $Global:LibPath\Profile\scripts) {
	Write-Progress -Id 1 -Activity 'Sourcing Scripts...' -PercentComplete 0 -Status 'Starting'

	$counter = 0

	$functions = Get-ChildItem $Global:LibPath\Profile\scripts -Recurse -Filter "*.ps1"
	$functions | ForEach-Object {
		if (-not $_.PSIsContainer) {
			$counter ++
			$SubActivity = "Scripts: Dot Sourcing $($_.Name)"
			if ($IsDebug) { Write-DebugMessage $SubActivity }
			Write-Progress -Id 1 -Activity 'Sourcing Functions...' -PercentComplete (($Counter / $functions.count) * 100) -Status $SubActivity
			. $_.FullName
		}
	}
	Write-Progress -Id 1 -Activity 'Sourcing Scripts...' -Completed
}

$Activity = 'Init PSDefaults...'
$TotalPercent += 10
Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

function AddPSDefault([string]$name, $value) {
	if ($PSVersionTable.PSVersion -ge '3.0') {
		if ($PSDefaultParameterValues.Contains($name)) {
			$PSDefaultParameterValues.Remove($name)
		}
		$PSDefaultParameterValues.Add($name, $value)
	}
}

function Read-Profiles {
	#Reload all profiles - helpful when editing/testing profiles
	Set-Variable -Name isDotSourced -Value $False -Scope 0
	$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
	if (!($isDotSourced)) { Write-Host "You must dot source this function" -fore Red; Write-Host "`t. Load-Profiles`n`t. re-Profs" -ForegroundColor "Yellow"; return "" }
	@(
		$Profile.AllUsersAllHosts,
		$Profile.AllUsersCurrentHost,
		$Profile.CurrentUserAllHosts,
		$Profile.CurrentUserCurrentHost
	) | ForEach-Object {
		if (Test-Path $_) {
			Write-Host "Loading $_"
			. $_
		}
	}
}

New-Alias -Name re-Profs -Value Read-Profiles -Description "Reload profile files (must . source)" -Force

#Defaults
AddPSDefault "Format-Table:AutoSize" { if ($host.Name -eq 'ConsoleHost') { $true } }
AddPSDefault "Get-Help:ShowWindow" $true
AddPSDefault "Out-Default:OutVariable" "__"


#####################  Actual Work  #####################

#Modules
$Activity = 'Init Modules...'
$TotalPercent += 10
Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

if ($PSVersionTable.PSVersion.Major -gt 2) {
	if (Test-Path $Global:LibPath\Modules) {
		Write-Progress -Id 1 -Activity 'Importing Modules...' -PercentComplete 0 -Status 'Starting'

		$counter = 0

		$env:PSModulePath = $env:PSModulePath + ";$LibPath\Modules"
		$functions = Get-ChildItem $Global:LibPath\Modules *.psd1 -Recurse
		$functions | ForEach-Object {
			$counter ++
			$SubActivity = "Modules: Importing $($_.Name)"
			if ($IsDebug) { Write-DebugMessage $SubActivity }
			Write-Progress -Id 1 -Activity 'Importing Modules...' -PercentComplete (($Counter / $functions.count) * 100) -Status $SubActivity

			Import-Module $_.FullName -Force -ArgumentList $true
		}
		Write-Progress -Id 1 -Activity 'Importing Modules...' -Completed
	}
}

#PSDrives
if (Test-Path $Global:LibPath\Settings\psdrive.csv) {
	$Activity = 'Init PSDrives...'
	$TotalPercent += 10
	Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

	if ($IsDebug) { Write-DebugMessage "PSDrives: Creating from CSV" }
	Import-Csv $Global:LibPath\Settings\psdrive.csv | New-ProfilePSDrive
}

if (Get-Service VMTools -ea Ignore) {
	if ($IsDebug) { Write-DebugMessage "PSDrives: VMWare Shared Folders" }
	New-ProfilePSDrive -name VMHost -Location "\\vmware-host\Shared Folders\$env:username\scripts" -Description "VMHost scripts"
}

#Path Adjustments
$Activity = 'Init Paths...'
$TotalPercent += 10
Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

if ($IsDebug) { Write-DebugMessage "Paths: Adding LibPath and Scripts" }
add-topath $libpath
add-topath $libpath\scripts
if (Test-Path $Global:LibPath\Settings\Add-ToPath.ini) {
	# get-content $Global:LibPath\Settings\Add-ToPath.ini | Add-ToPath
	Get-Content $Global:LibPath\Settings\Add-ToPath.ini | ForEach-Object {
		$p = @{ }
		$p.Directories = $_.split(",")[0]
		$p.Recurse = [bool] $_.split(",")[1]
		if ($IsDebug) { Write-DebugMessage "Paths: Adding from file $($p.Directories)" }
		New-Object -TypeName psobject -Property $p
	} | Add-ToPath
}
if (Test-Path $Global:LibPath\Settings\Remove-FromPath.ini) {
	if ($IsDebug) { Write-DebugMessage "Paths: Removing" }
	Get-Content $Global:LibPath\Settings\Remove-FromPath.ini | Remove-FromPath
}

## Removes non-existent dirs from path
(Get-SplitEnvPath | Where-Object { -not $_.Exists }).Path | Where-Object { $_ -ne $null } | Remove-FromPath

if ($PSVersionTable.PSVersion.Major -lt 6) {
	$Activity = 'Init SSL/TLS...'
	$TotalPercent += 10
	Write-Progress -Id 0 -Activity 'Initializing Profile...' -PercentComplete $TotalPercent -Status $Activity

	## Allow higher protocols with invoke-webreq and -restmeth
	if ($IsDebug) { Write-DebugMessage "SSL/TLS: Setting available protocols" }
	[System.Enum]::GetValues('Net.SecurityProtocolType') |
		Where-Object { $_ -gt [System.Math]::Max( [Net.ServicePointManager]::SecurityProtocol.value__, [Net.SecurityProtocolType]::Tls.value__ ) } |
			ForEach-Object {
				[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
			}
} else {
	#Test PSCore version
	if (Test-Path "${libpath}\scripts\Get-PSCoreVersion.ps1") {
		Invoke-Expression "$libpath\scripts\Get-PSCoreVersion.ps1 -noobject"
	}
}

#Only do these next items the first time (initial load)...
if (!($isDotSourced)) {
	#ShowHeader
	$Global:SnewToIgnore = "prompt", "PSConsoleHostReadline", "posh-git"
	#Get-NewCommands

	GoHome

	if (-not $NoExcuses) {
		if ($IsDebug) { Write-DebugMessage "Get-Excuse: Running" }
		if (Test-Path $LibPath\Clones\Get-Excuse\Get-Excuse.ps1) { Write-Host $(& $LibPath\Clones\Get-Excuse\Get-Excuse.ps1 -Format) -ForegroundColor Yellow }
	}
	if (-not $NoDayInHistory) {
		if ($IsDebug) { Write-DebugMessage "Get-ThisDayInHistory: Running" }
		if (Test-Path $LibPath\Clones\Get-ThisDayInHistory.ps\Get-ThisDayInHistory.ps1) { & $LibPath\Clones\Get-ThisDayInHistory.ps\Get-ThisDayInHistory.ps1 -FormatIt }
	}
} else {
	#I hate littering the field with random variables
	Remove-Item variable:\isDotSourced
}
Write-Progress -Id 0 -Activity 'Initializing Profile...' -Completed
