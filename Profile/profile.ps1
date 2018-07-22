
###################### Declarations #####################

$Global:IsAdmin = $False
if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
		new-object Security.Principal.WindowsPrincipal (
			[Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ) {
	$IsAdmin = $True
} else {
	$IsAdmin = $False
}

if ($PSVersionTable.PSVersion.Major -eq 2) {
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}

$Global:LibPath = $PSScriptRoot.Replace("\Profile", "")

################### Inits ######################

# Dot sourcing private function and script files
if (Test-Path $Global:LibPath\Profile\functions) {
	Get-ChildItem $Global:LibPath\Profile\functions -Recurse -Filter "*.ps1" | ForEach-Object {
		if (-not $_.PSIsContainer) {
			. $_.FullName
		}
	}
}
if (Test-Path $Global:LibPath\Profile\scripts) {
	Get-ChildItem $Global:LibPath\Profile\scripts -Recurse -Filter "*.ps1" | ForEach-Object {
		if (-not $_.PSIsContainer) {
			. $_.FullName
		}
	}
}

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
	Set-Variable -name isDotSourced -value $False -Scope 0
	$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
	if (!($isDotSourced)) { write-host "You must dot source this function" -fore Red; write-host "`t. Load-Profiles`n`t. re-Profs" -ForegroundColor "Yellow"; return "" }
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

New-Alias -name re-Profs -value Read-Profiles -Description "Reload profile files (must . source)" -Force

#Defaults
AddPSDefault "Format-Table:AutoSize" {if ($host.Name -eq 'ConsoleHost') {$true}}
AddPSDefault "Get-Help:ShowWindow" $true
AddPSDefault "Out-Default:OutVariable" "__"


#####################  Actual Work  #####################

#Modules
if ($PSVersionTable.PSVersion.Major -gt 2) {
	if (test-path $Global:LibPath\Modules) {
		$env:PSModulePath = $env:PSModulePath + ";$LibPath\Modules"
		Get-ChildItem $Global:LibPath\Modules *.psm1 -Recurse | ForEach-Object { Import-Module $_.FullName -force -ArgumentList $true }
	}
}

#PSDrives
if (test-path $Global:LibPath\Settings\psdrive.csv) {
	import-csv $Global:LibPath\Settings\psdrive.csv | New-ProfilePSDrive
}

if (Get-Service VMTools -ea Ignore) {
	New-ProfilePSDrive -name VMHost -Location "\\vmware-host\Shared Folders\$env:username\scripts" -Description "VMHost scripts"
}

#Path Adjustments
add-topath $libpath
add-topath $libpath\scripts
if (Test-Path $Global:LibPath\Settings\Add-ToPath.ini) {
	# get-content $Global:LibPath\Settings\Add-ToPath.ini | Add-ToPath
	Get-Content $Global:LibPath\Settings\Add-ToPath.ini | ForEach-Object {
		$p = @{}
		$p.Directories = $_.split(",")[0]
		$p.Recurse = [bool] $_.split(",")[1]
		New-Object -TypeName psobject -Property $p
	} | Add-ToPath
}
if (Test-Path $Global:LibPath\Settings\remove-frompath.ini) {
	get-content $Global:LibPath\Settings\remove-frompath.ini | Remove-FromPath
}

## Removes non-existent dirs from path
(Get-SplitEnvPath | Where-Object { -not $_.Exists }).Path | Where-Object { $_ -ne $null } | Remove-FromPath

## Allow higher protocols with invoke-webreq and -restmeth
[System.Enum]::GetValues('Net.SecurityProtocolType') |
    Where-Object { $_ -gt [System.Math]::Max( [Net.ServicePointManager]::SecurityProtocol.value__, [Net.SecurityProtocolType]::Tls.value__ ) } |
    ForEach-Object {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
    }

#Only do these next items the first time (initial load)...
if (!($isDotSourced)) {
	#Create the "standard" aliases for programs
	Set-ProgramAliases

	#ShowHeader
	$Global:SnewToIgnore = "prompt", "PSConsoleHostReadline", "posh-git"
	#Get-NewCommands

	GoHome

	if (test-path $LibPath\Clones\Get-Excuse\Get-Excuse.ps1) { Write-Host $(& $LibPath\Clones\Get-Excuse\Get-Excuse.ps1 -Format) -ForegroundColor Yellow }
	if (test-path $LibPath\Clones\Get-ThisDayInHistory.ps\Get-ThisDayInHistory.ps1) { & $LibPath\Clones\Get-ThisDayInHistory.ps\Get-ThisDayInHistory.ps1 -FormatIt }
} else {
	#I hate littering the field with random variables
	remove-item variable:\isDotSourced
}
