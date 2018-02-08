
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

	$command = "$(($history | Out-GridView -OutputMode Single -Title 'Current History List. Select a command to run...').CommandLine)"

	if ($command) {
		[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command))
	}
}

set-alias -name hist -value Invoke-GuiHistory -Description "A GUI History command runner" -Force

function Edit-History {
	[string] $HistFile = ''
	try {
		$HistFile = (Get-PSReadlineOption).HistorySavePath
		$HistFile = (Resolve-Path "$env:userprofile\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt").Path
		if (Test-Path $HistFile) {
			& notepad.exe $HistFile
		} else {
			write-host "Path to History file is not valid:" -ForegroundColor Yellow
			write-host "  $HistFile" -ForegroundColor Yellow
		}
	} catch {
		Write-Host "Error accessing PSReadline; maybe it's not present" -ForegroundColor Yellow
	}
}

if (get-module -name PSReadline) {
	#(Attempt to) Keep duplicates out of History
	#Ah - I misunderstood this option
	#It doesn't keep dupes out of History; it keeps them from being returned more than 1ce
	Set-PSReadLineOption -HistoryNoDuplicates:$True

	Set-PSReadlineKeyHandler -Key F7 -BriefDescription HistoryList -Description 'Show command history with Out-Gridview' -ScriptBlock { Invoke-GuiHistory }

	# F1 for help on the command line - naturally
	Set-PSReadlineKeyHandler -Key F1 -BriefDescription CommandHelp -LongDescription 'Open the help window for the current command' -ScriptBlock {
		param($key, $arg)
		#Pulled from https://github.com/lzybkr/PSReadLine/blob/master/PSReadLine/SamplePSReadlineProfile.ps1
		#and https://www.petri.com/let-psreadline-handle-powershell-part-2
		$ast = $null
		$tokens = $null
		$errors = $null
		$cursor = $null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

		$commandAst = $ast.FindAll( {
				$node = $args[0]
				$node -is [System.Management.Automation.Language.CommandAst] -and
				$node.Extent.StartOffset -le $cursor -and
				$node.Extent.EndOffset -ge $cursor
			}, $true) | Select-Object -Last 1

		if ($commandAst -ne $null) {
			$commandName = $commandAst.GetCommandName()
			if ($commandName -ne $null) {
				$command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
				if ($command -is [System.Management.Automation.AliasInfo]) {
					$commandName = $command.ResolvedCommandName
				}

				if ($commandName -ne $null) {
					Get-Help $commandName -ShowWindow
				}
			}
		}
	}
}
