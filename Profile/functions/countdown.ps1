function Set-CountDown() {
	param(
		[int]$hours = 0,
		[int]$minutes = 0,
		[int]$seconds = 0,
		[switch]$help)
	$HelpInfo = @'

    Function : CountDown
    By       : xb90 at http://poshtips.com
    Date     : 02/22/2011
    Purpose  : Pauses a script for the specified period of time and displays
               a count-down timer to indicate the time remaining.
    Usage    : Countdown [-Help][-hours n][-minutes n][seconds n]
               where
                      -Help       displays this help
                      -Hours n    specify the number of hours (default=0)
                      -Minutes n  specify the number of minutes (default=0)
                      -Seconds n  specify the number of seconds (default=0)

'@

	if ($help -or (!$hours -and !$minutes -and !$seconds)) {
		Write-Host $HelpInfo
		return
	}
	$startTime = Get-Date
	$endTime = $startTime.addHours($hours)
	$endTime = $endTime.addMinutes($minutes)
	$endTime = $endTime.addSeconds($seconds)
	$timeSpan = New-TimeSpan $startTime $endTime
	Write-Host $([string]::format("`nScript paused for {0:#0}:{1:00}:{2:00}", $hours, $minutes, $seconds)) -BackgroundColor black -ForegroundColor yellow
	while ($timeSpan -gt 0) {
		$timeSpan = New-TimeSpan $(Get-Date) $endTime
		Write-Host "`r".PadRight(40, " ") -NoNewLine
		Write-Host "`r" -NoNewLine
		Write-Host $([string]::Format("`rTime Remaining: {0:d2}:{1:d2}:{2:d2}", `
					$timeSpan.hours, `
					$timeSpan.minutes, `
					$timeSpan.seconds)) `
			-NoNewLine -BackgroundColor black -ForegroundColor yellow
		Start-Sleep 1
	}
	Write-Host ""
}

Set-Alias -name tMinus -value Set-CountDown -Description "Pause with a countdown timer" -Force
