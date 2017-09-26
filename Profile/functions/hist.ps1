
function Invoke-GuiHistory {
	$pattern = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
	if ($pattern) {
		$pattern = [regex]::Escape($pattern)
	}
	$history = get-history | sort-object ID -Descending | select-object -Property CommandLine -Unique
	if ($pattern) {
		$history = $history -match $pattern
	}

	$command = "$(($history |
	Out-GridView -OutputMode Single -Title 'Current History List. Select a command to run...').CommandLine)"

	if ($command) {
		[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command))
	}
}

set-alias -name hist -value Invoke-GuiHistory -Description "A GUI History command runner" -Force

Set-PSReadlineKeyHandler -Key F7 -BriefDescription HistoryList -Description "Show command history with Out-Gridview" -ScriptBlock { Invoke-GuiHistory }
