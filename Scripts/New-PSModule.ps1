<#
.SYNOPSIS
    Creates PowerShell module skeleton files (psm and psd)

.DESCRIPTION
    Creates a PowerShell module skeleton, complete with manifest and requisite folders (one for the module/manifest and the private subfolder)

.PARAMETER Name
    Name of the script module

.PARAMETER Path
    Parent folder where it will create the script module; it must already exist.

.PARAMETER Author
    Specifies the author (defaults to AD Full Name)

.PARAMETER Description
    Description of the module

.EXAMPLE
     New-PSModule -Name Brontosaurus -Path "$env:ProgramFiles\WindowsPowerShell\Modules" -Author 'Anne Elk' -Description 'This is my module of brontosauruses'
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[ValidateScript( {
			If (Test-Path -Path $_ -PathType Container) {
				$true
			} else {
				Throw "'$_' is not a valid directory."
			}
		})]
	[String]$Path = (($env:PSModulePath).ToString().Split(";") -like "*\Users\*"),

	[Parameter(Mandatory = $false)]
	[string]$Author,

	[Parameter(Mandatory = $true)]
	[string]$Description
)

$Copyright = 'To the extent within my power and possible under law, the author(s) have dedicated all copyright and related and neighboring rights to the public domain worldwide. This is distributed without any warranty.'

Try {
	Write-Verbose "Creating Directories..."
	Write-Verbose "  Creating Root:"
	$ret = New-Item -Path $Path -Name $Name -ItemType Directory
	Write-Verbose "    Created $($ret.FullName)"

	Write-Verbose "  Creating Private:"
	$ret = New-Item -Path $Path\$Name -Name "private" -ItemType Directory
	Write-Verbose "    Created $($ret.FullName)"

	Write-Verbose "  Creating Public:"
	$ret = New-Item -Path $Path\$Name -Name "public" -ItemType Directory
	Write-Verbose "    Created $($ret.FullName)"

	Write-Verbose "  Creating Config:"
	$ret = New-Item -Path $Path\$Name -Name "config" -ItemType Directory
	Write-Verbose "    Created $($ret.FullName)"

	Write-Verbose "  Creating Formats:"
	$ret = New-Item -Path $Path\$Name -Name "formats" -ItemType Directory
	Write-Verbose "    Created $($ret.FullName)"
} Catch {
	"Could not create the directory structure."
	$_.Exception.Message
	return
}

Try {
	write-verbose 'Creating Module File'
	Out-File -FilePath "$Path\$Name\$Name.psm1" -Encoding utf8 -NoClobber
	write-verbose '  Sucess'
} Catch {
	"Could not create the Module file."
	$_.Exception.Message
	return
}

$Template = @"
#region Private Variables
# Current script path
[string] `$ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
#endregion Private Variables

#region Private Helpers

# Dot sourcing private script files
Get-ChildItem `$ScriptPath/private -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. `$_.FullName
}
#endregion Load Private Helpers

[string[]] `$script:showhelp = @()
# Dot sourcing public script files
Get-ChildItem `$ScriptPath/public -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. `$_.FullName

	# From https://www.the-little-things.net/blog/2015/10/03/powershell-thoughts-on-module-design/
	# Find all the functions defined no deeper than the first level deep and export it.
	# This looks ugly but allows us to not keep any uneeded variables from poluting the module.
	([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path `$_.FullName -Raw), [ref] `$null, [ref] `$null)).FindAll( { `$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, `$false) | Foreach {
		Export-ModuleMember `$_.Name
		`$showhelp += `$_.Name
	}
}
#endregion Load public Helpers

if (test-path `$ScriptPath\formats\$($Name).format.ps1xml) {
	Update-FormatData `$ScriptPath\formats\$($Name).format.ps1xml
}

Get-$(${Name})Help


###################################################
## END - Cleanup

#region Module Cleanup
`$ExecutionContext.SessionState.Module.OnRemove = {
	# cleanup when unloading module (if any)
	Get-ChildItem alias: | Where-Object { `$_.Source -match `"$($Name)`" } | Remove-Item
    Get-ChildItem function: | Where-Object { `$_.Source -match `"$($Name)`" } | Remove-Item
    Get-ChildItem variable: | Where-Object { `$_.Source -match `"$($Name)`" } | Remove-Item
}
#endregion Module Cleanup

"@

Try {
	write-verbose 'Populating Module File'
	Add-Content -Path "$Path\$Name\$Name.psm1" -Value $Template
	write-verbose '  Success'
} Catch {
	"Could not add skeleton content to file."
	$_.Exception.Message
	return
}

$HelpTemplate = @"
Function Get-$(${Name})Help {
	<#
	.SYNOPSIS
	List commands available in the $($Name) Module

	.DESCRIPTION
	List all available commands in this module

	.EXAMPLE
	Get-$(${Name})Help
	#>
	Write-Host ""
	Write-Host "Getting available functions..." -ForegroundColor Yellow

	`$all = @()
	`$list = Get-Command -Type function -Module "DeploymentServices" | Where-Object { `$_.Name -in `$script:showhelp}
	`$list | ForEach-Object {
		`$RetHelp = Get-help $_.Name -ShowWindow:`$false -ErrorAction SilentlyContinue
		if (`$RetHelp.Description) {
			`$Infohash = @{
				Command     = `$_.Name
				Description = `$RetHelp.Synopsis
			}
			`$out = New-Object -TypeName psobject -Property `$InfoHash
			`$all += `$out
		}
	}
	`$all | format-table -Wrap -AutoSize | Out-String | Write-Host
}
"@

Try {
	write-verbose 'Creating Help/Information File'
	Add-Content -Path "$Path\$Name\public\Information.ps1" -Value $HelpTemplate
	Write-Verbose '  Success'
} Catch {
	"Could not add skeleton help content to file."
	$_.Exception.Message
	return
}

Try {
	write-verbose 'Creating Manifest'
	New-ModuleManifest -Path "$Path\$Name\$Name.psd1" -RootModule $Name -Author $Author -Description $Description `
		-AliasesToExport $null -FunctionsToExport $null -VariablesToExport $null -CmdletsToExport $null -Copyright $Copyright
	Write-Verbose '  Success'
} Catch {
	"Could not create the manifest."
	$_.Exception.Message
	return
}
