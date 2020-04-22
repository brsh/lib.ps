<#
.SYNOPSIS
Generate a random password

.DESCRIPTION
Generate a random password of a specific size (default is 25 characters).

You can specify your own characters to use via the Characters switch.
Otherwise, the script uses the following:

    '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~'

Note: Some of those chars might not be "web safe"

The script will take pipeline input for all the parameters. You can feed it objects
from a CSV file or some other method of choice. Size and UserName can be specified
by name or by datatype (integer and string, respectively); Characters has to be
explicitly defined.

BTW - I discovered a ... bug ... when I called it 'Length' vs 'Size'. With 'Length',
passing just the username value via pipeline caused $Length to equal the length of the
username passed. I looked for suggestions that $Length is a reserved variable, but
didn't find anything. Doesn't mean it's _not_ ... just means I couldn't find it. Oh,
and aliasing 'Size' as 'Length' also broke things... which is just weird cuz it's
an alias!!!

.PARAMETER Size
How many characters to generate (used to be length, but ... weirdness)

.PARAMETER Characters
Specify the characters to pick from (handy if some of the standard chars aren't "safe")

.PARAMETER UserName
A username field in case you gen a bunch of passwords

.EXAMPLE
New-RandomPassword.ps1

SYEcGwpuQjYIGQ1WnZv2b3D9B

.EXAMPLE
New-RandomPassword -Size 5

IyOqy

.EXAMPLE
New-RandomPassword -Characters 'abcdefABCDEF1234'

cCE2A2Daf4fDb2EfbeDe

.EXAMPLE
$a = @()
$a += [pscustomobject] @{ Size = 10; UserName = 'user1'; Characters = 'aAbBcCdD12345'}
$a += [pscustomobject] @{ Size = 10; UserName = 'user2'}
$a += [pscustomobject] @{ Size = 30; UserName = 'user3'}
$a | New-RandomPassword.ps1

#>
[CmdLetBinding()]
param (
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
	[int] $Size = 25,
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $false)]
	[string] $Characters = '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~',
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
	[string] $UserName = ''
)
BEGIN { }

PROCESS {
	[string[]] $ascii = $Characters.ToCharArray() | Sort-Object -unique
	[string] $TempPassword = ''

	For ($loop = 1; $loop -le $Size; $loop++) {
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
