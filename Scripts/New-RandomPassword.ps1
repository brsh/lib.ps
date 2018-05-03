<#
.SYNOPSIS
Generate a random password

.DESCRIPTION
Generate a random password of a specific length (default is 25 characters).

You can specify your own characters to use via the -Characters switch.
Otherwise, the script uses the following:

    '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~'

.EXAMPLE
New-RandomPassword.ps1

SYEcGwpuQjYIGQ1WnZv2b3D9B

.EXAMPLE
New-RandomPassword -length 5

IyOqy

.EXAMPLE
New-RandomPassword -Characters 'abcdefABCDEF1234'

cCE2A2Daf4fDb2EfbeDe

#>

param (
	[int] $length = 25,
	[string] $Characters = '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~'
)
[string[]] $ascii = $Characters.ToCharArray() | Sort-Object -unique

For ($loop = 1; $loop -le $length; $loop++) {
	$TempPassword += ($ascii | GET-RANDOM)
}
$TempPassword

