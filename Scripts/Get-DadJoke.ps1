<#
.SYNOPSIS
Uses the icanhazdadjoke.com api to .. get a dad joke

.DESCRIPTION
Sometimes, you just need a dad joke. Whether to remind you of your own father
or just cuz to remember a time before you were all groan up #dadjoke

.PARAMETER Search
A string to search for

.EXAMPLE
get-dadjoke
Returns a dad joke

.EXAMPLE
get-dadjoke -search 'hipster'

Returns any dad jokes with the word hipster

.LINK
http://icanhazdadjoke.com
#>
param (
	[string] $Search = ''
)
$URI = 'https://icanhazdadjoke.com'

if ($Search.Trim().Length -gt 0) {
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.web")
	$URI = "$URI/search?term=$([System.Web.HttpUtility]::UrlEncode($Search))"
	Write-Host $URI
}

$headers = @{
	'accept'     = 'text/plain'
	'User-Agent' = 'PowerShell Script for Fun (https://github.com/brsh/lib.ps) - thanks for the chuckles'
}
(Invoke-WebRequest -UseBasicParsing -Uri $URI -Headers $Headers).Content
