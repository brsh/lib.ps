<#
.SYNOPSIS
A wrapper for sleep that adds text and a counter

.DESCRIPTION
What started as a simple, 4 line sleep wrapper grew into a script. Probably not all that necessary, but I like it. Basically, this writes a status message with a counter, overwriting the line as the counter increments.

As with Start-Sleep, you set the seconds or milliseconds; different, tho: it's just the delay between counts. The added feature is you can set a Status message and the final 'Complete' message.

.PARAMETER StatusMessage
The main text displayed with the counter. Default is 'Please Wait...'

.PARAMETER CompletionMessage
The text displayed when the timer completes. Default is 'Done!'

.PARAMETER Duration
How long the sleep should be. Default is to the count of 10

.PARAMETER Seconds
How many seconds between counts. Default is 1 second

.PARAMETER Milliseconds
How many milliseconds between counts (mutually exclusive with seconds)

.PARAMETER Up
Count Up rather than the default down

.PARAMETER NoAbort
Do not allow Control-C to abort the countdown

.PARAMETER NoSpeedup
Don't allow keys pressed to speed up the countdown (i.e., skip numbers)

.PARAMETER ReturnObject
Returns a boolean value if the script was completed (true) or aborted (false)

.Outputs
If -ReturnObject is set, it returns a Boolean whether the script was completed naturally or aborted

.EXAMPLE
Start-SleepCounter.ps1

Please wait... Done!

.EXAMPLE
Start-SleepCounter.ps1 -StatusMessage 'Taking a break for 30 seconds...' -Duration 30 -Seconds 1 -CompletionMessage 'Back Now!'

Taking a break for 30 seconds... Back Now!

.EXAMPLE
Start-SleepCounter.ps1 -StatusMessage 'Taking a break for 30 seconds...' -Duration 30 -Seconds 1 -CompletionMessage 'Back Now!' -ReturnObject

Taking a break for 30 seconds... Aborted
False

#>


[CmdletBinding(DefaultParameterSetName = 'Seconds')]
param (
	[Parameter(Mandatory = $false)]
	[Alias('Status', 'Text')]
	[string] $StatusMessage = 'Please wait...',
	[Parameter(Mandatory = $false)]
	[Alias('Done')]
	[string] $CompletionMessage = 'Done!',
	[Parameter(Mandatory = $false)]
	[Alias('HowLong', 'Delay', 'Count')]
	[int] $Duration = 10,
	[Parameter(Mandatory = $false, ParameterSetName = 'Seconds')]
	[int] $Seconds = 1,
	[Parameter(Mandatory = $false, ParameterSetName = 'MilliSeconds')]
	[int] $Milliseconds = 0,
	[Switch] $Up = $false,
	[Switch] $NoAbort = $false,
	[Switch] $NoSpeedup = $false,
	[Switch] $ReturnObject = $false
)

[bool] $CurrentControlCAsInput = [console]::TreatControlCAsInput
[console]::TreatControlCAsInput = $true

function Write-StatusLine {
	param ($count)
	Write-Host "`r" -NoNewline
	Write-Host $StatusMessage -NoNewline -ForegroundColor Green
	Write-Host -NoNewLine "$count".PadLeft($Durationlength) -ForegroundColor yellow
}

#Let's keep the message all on one line (not that you'd ever send too long a line ...)
[int] $Durationlength = $Duration.ToString().Length + 2
[int] $screenwidth = $Host.UI.RawUI.WindowSize.Width - $Durationlength
if ($StatusMessage.Length -gt $screenwidth) {
	[int] $CharsToCut = $screenwidth - $Durationlength - 3
	$StatusMessage = $StatusMessage.Substring(0, $CharsToCut) + "..."
}
if ($StatusMessage.Length -gt 0) { $CompletionMessage = " " + $CompletionMessage }
[ConsoleColor] $Color = 'Green'

[int] $b = $Duration + 1

if ($Up) { $b = 0 }

for ($a = $Duration; $a -ge 1; $a--) {
	if ($Up) {
		$b++
	} else {
		$b--
	}
	Write-StatusLine -count $b
	if ([console]::KeyAvailable) {
		$x = [System.Console]::ReadKey($true)

		if (($x.modifiers -band [consolemodifiers]"control") -and ($x.key -eq "C") -and (-not $NoAbort)) {
			$CompletionMessage = " Aborted"
			$Color = 'Red'
			$a = 0
		} else {
			$SleepIt = $NoSpeedup
		}
		$Host.UI.RawUI.FlushInputBuffer()
	} else {
		$SleepIt = $true
	}
	if ($SleepIt) {
		if ($Milliseconds -gt 0) { Start-Sleep -Milliseconds $Milliseconds } else { Start-Sleep -Seconds $Seconds }
	}
}
Write-Host "`r" -NoNewline
Write-Host $StatusMessage -NoNewline -ForegroundColor White
Write-Host $CompletionMessage.PadRight($Durationlength) -ForegroundColor $Color

[console]::TreatControlCAsInput = $CurrentControlCAsInput

if ($ReturnObject) {
	if ($CompletionMessage -match 'Aborted') { $false } else { $true }
}
