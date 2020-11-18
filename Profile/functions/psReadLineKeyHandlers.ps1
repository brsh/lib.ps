using namespace System.Management.Automation
using namespace System.Management.Automation.Language

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

if (((Get-Module -Name PSReadline).Version.Major -ge 2) -and ((Get-Module -Name PSReadline).Version.Minor -ge 1)) {
	Set-PSReadLineOption -PredictionSource History
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

	Set-PSReadlineKeyHandler -Key Ctrl+Shift+c -BriefDescription CopyCurrentCLI -LongDescription "Copies all text on the current command line to the clipboard" -ScriptBlock {
		# Get current command on the command line
		$line = $null
		try {
			[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $null)
			if ($PSVersionTable.PSVersion.Major -lt 6) {
				Set-Clipboard $line
				Write-Host "`n  Copied current command line to the clipboard    " -ForegroundColor Green
			} else {
				Write-Host "`n  Can't copy to the clipboard on PS Core (yet) without OS specific options" -ForegroundColor Red
			}
		} catch {
			Write-Host "`n  Couldn't copy current command to the clipboard  " -ForegroundColor Red
		}
		[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($line.ToString())
	}

	Set-PSReadlineKeyHandler -Key Alt+w -BriefDescription SaveInHistory -LongDescription "Save current line in history but do not execute" -ScriptBlock {
		param($key, $arg)   # The arguments are ignored in this example

		# GetBufferState gives us the command line (with the cursor position)
		$line = $null
		$cursor = $null
		[PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)

		# AddToHistory saves the line in history, but does not execute the line.
		[PSConsoleUtilities.PSConsoleReadLine]::AddToHistory($line)

		# RevertLine is like pressing Escape.
		[PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
	}

	#region Smart Insert/Delete

	# The next four key handlers are designed to make entering matched quotes
	# parens, and braces a nicer experience.  I'd like to include functions
	# in the module that do this, but this implementation still isn't as smart
	# as ReSharper, so I'm just providing it as a sample.

	# Set-PSReadLineKeyHandler -Key '"', "'" `
	# 	-BriefDescription SmartInsertQuote `
	# 	-LongDescription "Insert paired quotes if not already on a quote" `
	# 	-ScriptBlock {
	# 	param($key, $arg)

	# 	$quote = $key.KeyChar

	# 	$selectionStart = $null
	# 	$selectionLength = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

	# 	$line = $null
	# 	$cursor = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

	# 	# If text is selected, just quote it without any smarts
	# 	if ($selectionStart -ne -1) {
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
	# 		return
	# 	}

	# 	$ast = $null
	# 	$tokens = $null
	# 	$parseErrors = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

	# 	function FindToken {
	# 		param($tokens, $cursor)

	# 		foreach ($token in $tokens) {
	# 			if ($cursor -lt $token.Extent.StartOffset) { continue }
	# 			if ($cursor -lt $token.Extent.EndOffset) {
	# 				$result = $token
	# 				$token = $token -as [StringExpandableToken]
	# 				if ($token) {
	# 					$nested = FindToken $token.NestedTokens $cursor
	# 					if ($nested) { $result = $nested }
	# 				}

	# 				return $result
	# 			}
	# 		}
	# 		return $null
	# 	}

	# 	$token = FindToken $tokens $cursor

	# 	# If we're on or inside a **quoted** string token (so not generic), we need to be smarter
	# 	if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
	# 		# If we're at the start of the string, assume we're inserting a new string
	# 		if ($token.Extent.StartOffset -eq $cursor) {
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
	# 			return
	# 		}

	# 		# If we're at the end of the string, move over the closing quote if present.
	# 		if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
	# 			return
	# 		}
	# 	}

	# 	if ($null -eq $token) {
	# 		if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
	# 			# Odd number of quotes before the cursor, insert a single quote
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
	# 		} else {
	# 			# Insert matching quotes, move cursor to be in between the quotes
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
	# 		}
	# 		return
	# 	}

	# 	if ($token.Extent.StartOffset -eq $cursor) {
	# 		if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier) {
	# 			$end = $token.Extent.EndOffset
	# 			$len = $end - $cursor
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
	# 		}
	# 		return
	# 	}

	# 	# We failed to be smart, so just insert a single quote
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
	# }

	# Set-PSReadLineKeyHandler -Key '(', '{', '[' `
	# 	-BriefDescription InsertPairedBraces `
	# 	-LongDescription "Insert matching braces" `
	# 	-ScriptBlock {
	# 	param($key, $arg)

	# 	$closeChar = switch ($key.KeyChar) {
	# 		<#case#> '(' { [char]')'; break }
	# 		<#case#> '{' { [char]'}'; break }
	# 		<#case#> '[' { [char]']'; break }
	# 	}

	# 	[Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
	# 	$line = $null
	# 	$cursor = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
	# }

	# Set-PSReadLineKeyHandler -Key ')', ']', '}' `
	# 	-BriefDescription SmartCloseBraces `
	# 	-LongDescription "Insert closing brace or skip" `
	# 	-ScriptBlock {
	# 	param($key, $arg)

	# 	$line = $null
	# 	$cursor = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

	# 	if ($line[$cursor] -eq $key.KeyChar) {
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
	# 	} else {
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
	# 	}
	# }

	# Set-PSReadLineKeyHandler -Key Backspace `
	# 	-BriefDescription SmartBackspace `
	# 	-LongDescription "Delete previous character or matching quotes/parens/braces" `
	# 	-ScriptBlock {
	# 	param($key, $arg)

	# 	$line = $null
	# 	$cursor = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

	# 	if ($cursor -gt 0) {
	# 		$toMatch = $null
	# 		if ($cursor -lt $line.Length) {
	# 			switch ($line[$cursor]) {
	# 				<#case#> '"' { $toMatch = '"'; break }
	# 				<#case#> "'" { $toMatch = "'"; break }
	# 				<#case#> ')' { $toMatch = '('; break }
	# 				<#case#> ']' { $toMatch = '['; break }
	# 				<#case#> '}' { $toMatch = '{'; break }
	# 			}
	# 		}

	# 		if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
	# 		} else {
	# 			[Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
	# 		}
	# 	}
	# }

	#endregion Smart Insert/Delete

	# This doesn't work with ConEmu at the moment ... prolly easily fixable...
	# Set-PSReadLineKeyHandler -Key 'Alt+(' `
	# 	-BriefDescription ParenthesizeSelection `
	# 	-LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
	# 	-ScriptBlock {
	# 	param($key, $arg)

	# 	$selectionStart = $null
	# 	$selectionLength = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

	# 	$line = $null
	# 	$cursor = $null
	# 	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	# 	if ($selectionStart -ne -1) {
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
	# 	} else {
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
	# 		[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
	# 	}
	# }

	# This example will replace any aliases on the command line with the resolved commands.
	Set-PSReadLineKeyHandler -Key "Alt+%" `
		-BriefDescription ExpandAliases `
		-LongDescription "Replace all aliases with the full command" `
		-ScriptBlock {
		param($key, $arg)

		$ast = $null
		$tokens = $null
		$errors = $null
		$cursor = $null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

		$startAdjustment = 0
		foreach ($token in $tokens) {
			if ($token.TokenFlags -band [TokenFlags]::CommandName) {
				$alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
				if ($alias -ne $null) {
					$resolvedCommand = $alias.ResolvedCommandName
					if ($resolvedCommand -ne $null) {
						$extent = $token.Extent
						$length = $extent.EndOffset - $extent.StartOffset
						[Microsoft.PowerShell.PSConsoleReadLine]::Replace(
							$extent.StartOffset + $startAdjustment,
							$length,
							$resolvedCommand)

						# Our copy of the tokens won't have been updated, so we need to
						# adjust by the difference in length
						$startAdjustment += ($resolvedCommand.Length - $length)
					}
				}
			}
		}
	}
}
