function New-RandomPassword {
	param (
		[int] $length = 20,
		[string] $Characters = '!#$%&*+-0123456789?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_abcdefghijklmnopqrstuvwxyz~'
	)
	[string[]] $ascii = $Characters.ToCharArray()
	For ($loop = 1; $loop -le $length; $loop++) {
		$TempPassword += ($ascii | GET-RANDOM)
	}
	$TempPassword
}
