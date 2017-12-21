
function Get-HTMLResponseCodes {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$false,Position=0)]
		[Alias('Code', 'String', 'Text', 'Response')]
		[string] $Search
	)
	$codes = [enum]::getnames([system.net.httpstatuscode])
	if ($Search) { $codes = $codes | Where-Object { ($_ -match $Search) -or ($([int][system.net.httpstatuscode]::$_) -match $Search) } }
	if ($codes) {
		$codes | ForEach-Object { write-host "$([int][system.net.httpstatuscode]::$_) $_" }
	} else { "None found." }
}

set-alias -name htmlcodes -value Get-HTMLResponseCodes -Description "Enum various HTML response codes (200 - ok)" -Force

function Get-DataTypes {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$false,Position=0)]
		[Alias('Code', 'String', 'Text', 'Response')]
		[string] $Search
	)
	$types = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get.GetEnumerator()
	if ($Search) { $types = $types | Where-Object { $_.Key -match $Search } }
	$types | Sort-Object key | Select-Object key | ForEach-Object { $_.key.ToString().Trim() }
}

set-alias -name types -value Get-DataTypes -Description "Enum the data types" -Force

function Get-HtmlColors {
	Add-Type -AssemblyName PresentationFramework
	[System.Windows.Media.Colors].GetProperties() | Select-Object Name, @{n="Hex";e={$_.GetValue($null).ToString()}}
}

set-alias -name htmlcolors -value Get-HtmlColors -Description "Enum colors by name and hex code" -Force
