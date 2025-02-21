<#
.SYNOPSIS
	Sign one or several files
.DESCRIPTION
	Everybody should sign their code. Yup, they should. Still, it's time consuming
	and not my overall most fun thing to do.

	That said, I'm finally trying to get into the swing of signing. This script is
	a start.

	It will sign code using the either the only code signing cert it finds, or prompt
	for a selection if multiple are in the cert store. It also takes a cert as a
	command line switch, so there's that too.

	And since I'm lazy, it can take an entire directory or directory tree - anything
	you can Get-ChildItem on - you can pipe it thru.

	Note: The TimeStampServer is optional, however, I think the pros outweigh the cons
	so I left it as permanent!

.PARAMETER FullName
	The fullname property of a FileInfo object (or just the FileInfo object)

.PARAMETER FileName
	String path to a file to sign

.PARAMETER Certificate
	A certificate with which to sign

.PARAMETER TimeStampServer
	URI of a timestamp server (will default to verisign)

.EXAMPLE
	Set-SignedCode.ps1 -Certificate (Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0] -FileName '.\this-file.ps1'

	Signs this-file.ps1 with the first code signing cert

.EXAMPLE
	Set-SignedCode.ps1 -FileName '.\this-file.ps1'

	Signs this-file.ps1 with the first code signing cert in the store (or prompts for a selection if more than 1)

.EXAMPLE
	Get-ChildItem .\ -recurse -Filter *.ps1 | Set-SignedCode.ps1

	Signs ALL the ps1 files from here down with the first code signing cert in the store (or prompts for a selection if more than 1)

.EXAMPLE
	Get-ChildItem -Path . -Include *.ps1, *.psm1, *.psd1, *.ps1xml -Recurse | Set-SignedCode.ps1

	Signs all appropriate module files from here down with the first code signing cert in the store (or prompts for a selection if more than 1)

#>

[CmdLetBinding(DefaultParameterSetName = 'FileName')]
param (
	[Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'FileInfo', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
	[System.IO.FileInfo[]] $FullName,
	[Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'FileName', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
	[ValidateScript( { test-path $_ })]
	[string] $FileName,
	[Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
	[Alias('Cert')]
	[System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate,
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
	[ValidateScript( {
			$_ -eq ([uri] $_).AbsoluteURI
		})]
	[string] $TimeStampServer = 'http://timestamp.digicert.com/'
)

BEGIN {
	if ($null -eq $Certificate) {
		try {
			[System.Security.Cryptography.X509Certificates.X509Certificate2[]] $AllCerts = @(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert -ErrorAction Stop)
		} catch {
			Write-Host 'Could not pull certs from the cert store'
			Write-Host $_.Exception.Message
			exit
		}
		[int] $Count = $AllCerts.Count - 1
		if ($Count -gt 0) {
			[int] $a = -1
			do {
				if ($a -ne -1) { Write-Host 'Invalid Response' -ForegroundColor Red }
				write-host ''
				Write-Host 'Select the Cert to use:' -ForegroundColor Yellow
				[int] $i = 0
				$AllCerts | ForEach-Object {
					Write-Host "$(($i).ToString().PadLeft(3)) : $($_.Subject)"
					$i ++
				}
				Write-Host ''
				Write-Host "Enter a number (0 - $($Count)): " -NoNewline
				$a = Read-Host
			} while (($a -lt 0) -or ($a -gt $Count))
			$Certificate = $AllCerts[$a]
		} else {
			$Certificate = $AllCerts[0]
		}
	}
	if ($null -eq $Certificate) {
		Write-Host 'Could not find a Code Signing Cert!' -ForegroundColor Yellow
		Exit
	}
}

PROCESS {
	if ($PSCmdlet.ParameterSetName -eq 'FileName') {
		[string] $FilePath = $Filename
	} else {
		$FilePath = $_.FullName
	}

	Try {
		$retval = Set-AuthenticodeSignature -Certificate $Certificate -FilePath $FilePath -TimestampServer $TimeStampServer
		New-Object -Type PSCustomObject -Property ([ordered] @{
				Status = $retval.Status
				#Message = $retval.StatusMessage
				Path   = $retval.Path
				Signer = $retval.SignerCertificate.Subject
			})
	} catch {
		Write-Host "Could not sign the file: ($FilePath)!" -ForegroundColor Red
		Write-Host $_.Exception.Message -ForegroundColor Yellow
	}
}

#Remnants from when I started all this....
# if ($env:TERM_PROGRAM -match 'vscode') {
# 	try {
# 		Register-EditorCommand -Name SignCurrentScript -DisplayName 'Sign Current Script' -ScriptBlock {
# 			$currentFile = $psEditor.GetEditorContext().CurrentFile.Path
# 			Set-SignedWithMyCert -File $currentFile
# 		}
# 	} catch {
# 		Write-Verbose 'Not running in vscode'
# 	}


