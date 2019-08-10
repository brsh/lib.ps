<#
	.SYNOPSIS
	Create a toast notification

	.DESCRIPTION
	This script writes a notification to the Windows Toast system (or balloon
	system it that's what you first called it as). Just a quick pop-up
	message down in the bottom right of the screen. On Windows 10, it'll also
	keep the message on the Action Bar (or whatever it's called these days).

	Toasts can include an image for Error, Info, Warning, or no image at all.

	By default, it'll include the icon for PowerShell, but you can supply a
	path to any valid available icon if you want something different. I'd
	recommend testing the path first cuz there's no guarantee they all
	work.

	Of course, it was after writing some of this on my own that I stumbled
	on Boe Prox's version. Oh well. I kept some of mine, added some of his.
	There is nothing new under the sun ;)

	.EXAMPLE
	Send-ToastMessage.ps1 -Type Warning -Message 'The script completed with errors' -Title 'ScriptOfTheAges'

	.LINK
	https://github.com/proxb/PowerShell_Scripts/blob/master/Invoke-BalloonTip.ps1
	#>

[CmdletBinding()]

param (
	[ValidateSet('Info', 'Error', 'Warning', 'None')]
	[string] $Type = 'None',
	[string] $Message = 'Hello World',
	[string] $Title = 'Attention',
	[string] $PathToSourceIcon = (Get-Process -id $pid).Path
)
if ($PSVersionTable.PSVersion.Major -eq '6') {
	Write-Host "Sorry, Windows Forms don't work in PS Core :("
} else {
	Add-Type -AssemblyName System.Windows.Forms

	If (-NOT $global:toast) {
		$global:toast = New-Object System.Windows.Forms.NotifyIcon

		#Mouse double click on icon to dispose
		[void](Register-ObjectEvent -InputObject $toast -EventName MouseClick -SourceIdentifier IconClicked -Action {
				Write-Verbose 'Disposing of toast'
				$global:toast.dispose()
				Unregister-Event -SourceIdentifier IconClicked
				Remove-Job -Name IconClicked
				Remove-Variable -Name toast -Scope Global
			})
	}

	if (Test-Path $PathToSourceIcon -ErrorAction SilentlyContinue) {
		$toast.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PathToSourceIcon)
	} else {
		Write-Verbose "Path to Icon not found: $PathToSourceIcon"
		$toast.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid).Path)
	}

	$toast.BalloonTipIcon = switch ($Type.Substring(0, 1)) {
		'W' { [System.Windows.Forms.ToolTipIcon]::Warning; break }
		'I' { [System.Windows.Forms.ToolTipIcon]::Info; break }
		'E' { [System.Windows.Forms.ToolTipIcon]::Error; break }
		'N' { [System.Windows.Forms.ToolTipIcon]::None; break }
	}

	$toast.BalloonTipText = $Message
	$toast.BalloonTipTitle = $Title
	$toast.Visible = $true

	#Note: the 5000 is "how long to display the toast"
	#* But... This parameter is deprecated as of Windows Vista. Notification display times are now based on system accessibility settings.
	$toast.ShowBalloonTip(5000)
}
