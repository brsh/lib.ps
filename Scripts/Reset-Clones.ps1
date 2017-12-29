
## Initializes (or RE-initializes) the Lib.PS Modules and Clones
## This is not intended to init the entire lib.ps ..
## just the items that live under lib.ps\Modules and lib.ps\Clones

[CmdletBinding(SupportsShouldProcess)]
param (
	[Parameter(Mandatory = $false)]
	[string] $Folder = $LibPath
)

if (-not $Folder) {
	""
	"Folder paramater not specified and the LibPath variable doesn't seem to be initialized."
	"Is Lib.PS cloned/installed? Maybe you forgot the -Folder parameter??"
	""
	return
}

if ($pscmdlet.ShouldProcess("LibPS", "Cloning Repository")) {
	if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
			new-object Security.Principal.WindowsPrincipal (
				[Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
		).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ) {

		if (-not (test-path $Folder\Clones)) {

			"Creating the Clones folder..."
			try {
				mkdir "$Folder\Clones" -ea stop | ForEach-Object { "   $_  -- Success" }
			} catch {
				"Could not create the folder."
				$_.Exception.Message
				return
			}
		}

		if (-not (test-path $Folder\Modules)) {
			"Creating the Modules folder..."
			try {
				mkdir "$Folder\Modules" -ea stop | ForEach-Object { "   $_  -- Success" }
			} catch {
				"Could not create the folder."
				$_.Exception.Message
				return
			}
		}

		"Cloning the default scripts ($Folder\Settings\Get-Git-Clones.ini):"
		get-content $Folder\Settings\Get-Git-Clones.ini | ForEach-Object {
			& $LibPath\Scripts\Get-GitModule.ps1 -URLPath $_ -Destination $Folder\Clones -ReadOnly -Force -Verbose
		}


		"Cloning the default Modules ($Folder\Settings\Get-Git-Modules.ini):"
		get-content $Folder\Settings\Get-Git-Modules.ini | ForEach-Object {
			& $LibPath\Scripts\Get-GitModule.ps1 -URLPath $_ -Destination $Folder\Modules -ReadOnly -Force -Verbose
		}

	} else {
		"Please run this script as an Administrator"
	}


}
