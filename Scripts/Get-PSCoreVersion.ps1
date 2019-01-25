<#
.SYNOPSIS
Pulls the version of PS Core available on the web and compares it to the running version

.DESCRIPTION
Just a quick function to poll the MS Github site for the current version of PowerShell Core.
Then it compares that version against what's running and let's you know if this is an
older version. Handy, no?

BTW ... PowerShell Core will _always_ be newer than Windows PowerShell, so bear that in mind.

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

function Get-CurVer {
	$PSVersionTable.PSVersion
}

$PSCoreURI = 'https://github.com/powershell/powershell'

if ($PSVersionTable.PSVersion.Major -lt 6) {
	if (-not $Quiet) {
		Write-Host "This is Windows Powershell... PSCore will always be newer than this."
		Write-Host $PSCoreURI
	}
} else {
	#Using this to get rid of the nasty output Invoke-WebRequest gives you in PowerShell on the Mac
	if ($Quiet) {
		$progress = $ProgressPreference
		$ProgressPreference = "SilentlyContinue"
	}

	$JSON = Invoke-WebRequest 'https://api.github.com/repos/powershell/powershell/releases/latest' | ConvertFrom-Json
	if ($PSVersionTable.GitCommitId) {
		if (($JSON.tag_name -replace '\D', '') -notmatch ($PSVersionTable.GitCommitId -replace '\D', '')) {
			Write-Host "New version of PowerShell available! Specifically, $($JSON.tag_name)"
			Write-Host $PSCoreURI
			if ($ReleaseInfo) {
				Write-Host $JSON.body
			}
		} else {
			if (-not $Quiet) {Write-Host 'PowerShell Core is currently up to date.'}
		}
	}
	if ($Quiet) {
		$ProgressPreference = $progress
	}
}
if (-not $NoObject) { $PSVersionTable.PSVersion }
