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

.EXAMPLE
Start-SleepCounter.ps1

Please wait... Done!

.EXAMPLE
Start-SleepCounter.ps1 -StatusMessage 'Taking a break for 30 seconds...' -Duration 30 -Seconds 1 -CompletionMessage 'Back Now!'

Taking a break for 30 seconds... Back Now!

#>


[CmdletBinding(DefaultParameterSetName='Seconds')]
param (
    [Parameter(Mandatory=$false)]
    [Alias('Status', 'Text')]
    [string] $StatusMessage = 'Please wait...',
    [Parameter(Mandatory=$false)]
    [Alias('Done')]
    [string] $CompletionMessage = 'Done!',
    [Parameter(Mandatory=$false)]
    [Alias('HowLong', 'Delay', 'Count')]
    [int] $Duration = 10,
    [Parameter(Mandatory=$false,ParameterSetName='Seconds')]
    [int] $Seconds = 1,
    [Parameter(Mandatory=$false,ParameterSetName='MilliSeconds')]
    [int] $Milliseconds = 0
)

#Let's keep the message all on one line (not that you'd ever send too long a line ...)
[int] $Durationlength = $Duration.ToString().Length + 2
[int] $screenwidth = $Host.UI.RawUI.WindowSize.Width - $Durationlength
if ($StatusMessage.Length -gt $screenwidth) {
    [int] $CharsToCut = $screenwidth - $Durationlength - 3
    $StatusMessage = $StatusMessage.Substring(0, $CharsToCut) + "..."
}
if ($StatusMessage.Length -gt 0) { $CompletionMessage = " " + $CompletionMessage }

for ($a=0; $a -le $Duration; $a++) {
    Write-Host "`r" -NoNewline
    Write-Host $StatusMessage -NoNewline -ForegroundColor Green
    Write-Host -NoNewLine "$a".PadLeft($Durationlength) -ForegroundColor yellow
    if ($Milliseconds -gt 0) { Start-Sleep -Milliseconds $Milliseconds } else { Start-Sleep -Seconds $Seconds }
}
Write-Host "`r" -NoNewline
Write-Host $StatusMessage -NoNewline -ForegroundColor White
Write-Host $CompletionMessage.PadRight($Durationlength) -ForegroundColor Green