<#
.SYNOPSIS
Pulls the version of PS 'Core' available on the web and compares it to the running version

.DESCRIPTION
Just a quick function to poll the MS Github site for the current version of PowerShell 'Core'.
Then it compares that version against what's running and let's you know if this is an
older version. Handy, no?

BTW ... PowerShell 'Core' will _always_ be newer than Windows PowerShell, so bear that in mind.

Also, with PowerShell 7, Microsoft has dropped the 'Core' postfix. I, however, am leaving it
in this script to maintain the "separation" between Windows PowerShell and "Core". Just a
little differentiation between friends.

.PARAMETER Quiet
Don't show the Progress Bar as it queries the website

.PARAMETER ReleaseInfo
Show the release info / change log provided from the url

.PARAMETER NoObject
Don't output the version object

.LINK
http://www.virtu-al.net/2017/03/27/powershell-core-date/
#>

param (
	[switch] $Quiet = $false,
	[switch] $ReleaseInfo = $false,
	[switch] $NoObject = $false
)

$PSCoreURI = 'https://github.com/powershell/powershell'

if ($PSVersionTable.PSVersion.Major -lt 6) {
	if (-not $Quiet) {
		Write-Host "This is Windows Powershell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) - PS 'Core' will always be newer than this." -ForegroundColor White
		Write-Host "  PS 'Core' is available at $PSCoreURI" -ForegroundColor Green
	}
} else {
	#Using this to get rid of the nasty output Invoke-WebRequest gives you in PowerShell on the Mac
	if ($Quiet) {
		$progress = $ProgressPreference
		$ProgressPreference = "SilentlyContinue"
	}

	Write-Host "Current Version of PowerShell 'Core' is $($PSVersionTable.PSVersion.ToString())"  -ForegroundColor White
	if (($PSVersionTable.PSVersion -match 'rc') -or ($PSVersionTable.PSVersion -match 'preview')) {
		Write-Host "  This is not a release version"  -ForegroundColor Yellow
	}
	$JSON = Invoke-WebRequest 'https://api.github.com/repos/powershell/powershell/releases/latest' | ConvertFrom-Json
	if ($PSVersionTable.GitCommitId) {
		if (($JSON.tag_name -replace '\D', '') -notmatch ($PSVersionTable.GitCommitId -replace '\D', '')) {
			Write-Host "Latest official PowerShell release version is $($JSON.tag_name)"  -ForegroundColor White
			Write-Host "  $PSCoreURI" -ForegroundColor Green
			Write-Host 'One Line Install: iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"' -ForegroundColor White
			if ($ReleaseInfo) {
				Write-Host ''
				Write-Host $JSON.body
			}
		} else {
			if (-not $Quiet) { Write-Host "  PowerShell 'Core' is currently up to date." -ForegroundColor Green }
		}
	}
	if ($Quiet) {
		$ProgressPreference = $progress
	}
}
if (-not $NoObject) { $PSVersionTable.PSVersion } else { write-host '' }

if ($ReleaseInfo) {
	Write-Host ''
	Write-Host $JSON.body
}
