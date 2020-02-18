<#
.SYNOPSIS
Generate a random password

.DESCRIPTION
Generate a random password of a specific length (default is 25 characters).

You can specify your own characters to use via the Characters switch.
Otherwise, the script uses the following:

    '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~'

Note: Some of those chars might not be "web safe"

The script will take pipeline input for all the parameters. You can feed it objects
from a CSV file or some other method of choice. Length and UserName can be specified
by name or by datatype (integer and string, respectively); Characters has to be
explicitly defined.

.PARAMETER Length
How many characters to generate

.PARAMETER Characters
Specify the characters to pick from (handy if some of the standard chars aren't "safe")

.PARAMETER UserName
A username field in case you gen a bunch of passwords

.EXAMPLE
New-RandomPassword.ps1

SYEcGwpuQjYIGQ1WnZv2b3D9B

.EXAMPLE
New-RandomPassword -length 5

IyOqy

.EXAMPLE
New-RandomPassword -Characters 'abcdefABCDEF1234'

cCE2A2Daf4fDb2EfbeDe

.EXAMPLE
$a = @()
$a += [pscustomobject] @{ length = 10; UserName = 'user1'; Characters = 'aAbBcCdD12345'}
$a += [pscustomobject] @{ length = 10; UserName = 'user2'}
$a += [pscustomobject] @{ length = 30; UserName = 'user3'}
$a | New-RandomPassword.ps1

#>
[CmdLetBinding()]
param (
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
	[int] $Length = 25,
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $false)]
	[string] $Characters = '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~',
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
	[string] $UserName = ''
)
BEGIN { }

PROCESS {
	[string[]] $ascii = $Characters.ToCharArray() | Sort-Object -unique
	[string] $TempPassword = ''

	For ($loop = 1; $loop -le $length; $loop++) {
		$TempPassword += ($ascii | GET-RANDOM)
	}
	$hash = [ordered] @{
		Password = $TempPassword
	}
	if ($UserName.Length -gt 0) {
		$hash.UserName = $UserName
	}
	New-Object -TypeName PSCustomObject -Property $hash
}

END { }
