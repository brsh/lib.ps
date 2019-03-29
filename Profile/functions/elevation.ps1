function Start-ElevatedSession {
	param (
		[string] $File = ''
	)
	# Open a new elevated powershell window (or tab if using ConEMU)
	if ( $Global:IsAdmin) {
		Write-Warning 'Session is already elevated'
	} else {
		[string] $PowerShellExe = 'powershell.exe'
		if ($PSVersionTable.PSVersion.Major -ge 6) {
			$PowerShellExe = 'pwsh.exe'
		}
		[string] $CommandToRun = "& {Set-Location $PWD"
		if ($File.Length -gt 0) {
			$CommandToRun = "${CommandToRun}; Write-Host -ForegroundColor Yellow `"Running: $File`"; Write-Host `" `"; $file"
		}
		$CommandToRun = "${CommandToRun}}"
		if ($env:ConEmuPID) {
			ConEmuC.exe /c $PowerShellExe -NoExit -Command "$CommandToRun" -new_console:a
		} elseif ($host.Name -match 'ISE') {
			Start-Process PowerShell_ISE.exe -Verb RunAs
		} else {
			Start-Process $PowerShellExe -Verb RunAs -ArgumentList $("-NoExit -Command $CommandToRun")
		}
	}
}

Set-Alias -Name su -Value Start-ElevatedSession

function Start-ElevatedProcess {
	$File, [string] $Arguments = $args
	if ($File -match '.ps1$') {
		[System.IO.FileInfo] $PS1File = get-item $file
		Start-ElevatedSession -File $PS1File.FullName
	} else {
		$psi = New-Object System.Diagnostics.ProcessStartInfo $File
		$psi.Arguments = $Arguments
		$psi.Verb = 'RunAs'

		$psi.WorkingDirectory = Get-Location
		[System.Diagnostics.Process]::Start($psi)
	}
}

Set-Alias -Name sudo -Value Start-ElevatedProcess
