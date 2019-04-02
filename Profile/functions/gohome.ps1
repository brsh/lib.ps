function GoHome {
	<#
    .SYNOPSIS
        Set "home" scripts directory

    .DESCRIPTION
        Sets and/or moves to my working Scripts folder - either personal or shared - as a PSDrive called "Scripts:". Assumes personal is under the current user's profile ("My Documents\Scripts") and shared is under the root of the main hard drive ("C:\Scripts").

        This function will create the folder, if necessary - but it asks first.

        The switch parameter allows switching between personal and shared, so that the Scripts PSDrive "root" is always where I'm working that session. Defaults to local.

    .PARAMETER  Switch
        Switches between personal and shared

    .EXAMPLE
        PS C:\> gohome

        Essentially "cd ~\Scripts" where ~ is either the user's home folder or the root of "C:"

    .EXAMPLE
        PS C:\> gohome -switch

        Switches the Scripts PSDrive to the other location (if currently personal, switches to shared; if shared, switches to personal
    #>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $False)]
		[switch]$Switch = $false
	)

	$local = "$($env:USERPROFILE)\Documents\Scripts"
	$global = "$($env:SystemDrive)\Scripts"

	# first test if the Scripts PSDrive exists
	if (Test-Path scripts:) {
		$myScriptsDir = $(Get-PSDrive Scripts).Root
		#Test is Switch is set
		if ( $Switch ) {
			#And switch
			if ($myScriptsDir -eq $local) {
				$myScriptsDir = $global
			} else {
				$myScriptsDir = $local
			}
		}
	} else {
		#It's new - default to local
		$myScriptsDir = $global
	}

	#Test for it and create it if necessary
	if (!(Test-Path $myScriptsDir)) {
		Write-Host "Creating default scripts directory ($myScriptsDir)" -back black -fore green
		New-Item -Path $myScriptsDir -Type directory -Confirm
	}
	Write-Verbose  "Scripts: is $($myScriptsDir)"
	New-ProfilePSDrive -Name Scripts -Location $myScriptsDir -Description "Default working directory for Scripts"
	Set-Location Scripts:\
}

New-Alias -name "cd~" -value GoHome -Description "Return to home directory" -Force
