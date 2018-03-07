Function Convert-SubnetMask {
	<#
    .SYNOPSIS
        Converts to and from CIDR/SubnetMask
    .DESCRIPTION
		Sometimes you need the CIDR, sometimes you need the Subnet Mask. Sometimes you need to know how many
		ip addresses are contained in a specific CIDR/SubnetMask. Well, here ya go.

		Based on work found on reddit:
			https://www.reddit.com/r/PowerShell/comments/82mxds/inspired_by_latest_shortest_script_challenge_ipv4/
			https://www.reddit.com/r/PowerShell/comments/81x324/shortest_script_challenge_cidr_to_subnet_mask/

		And
			http://www.ryandrane.com/2016/05/getting-ip-network-information-powershell/

    .EXAMPLE
		Convert-SubnetMask -CIDR 24

CIDR             : 24
NumberOfHosts    : 254
BroadcastAddress : 10.0.0.255
NetworkAddress   : 10.0.0.0
Mask             : 255.255.255.0

    .EXAMPLE
		Convert-SubnetMask -Mask '255.255.0.0'

CIDR             : 16
NumberOfHosts    : 65534
BroadcastAddress : 10.0.255.255
NetworkAddress   : 10.0.0.0
Mask             : 255.255.0.0

	.EXAMPLE
		Convert-SubnetMask -Mask '255.255.0.0' -IPAddress '10.10.0.0'

CIDR             : 16
NumberOfHosts    : 65534
BroadcastAddress : 10.10.255.255
NetworkAddress   : 10.10.0.0
Mask             : 255.255.0.0

#>
	[CmdletBinding(DefaultParameterSetName = "CIDR")]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'CIDR', Position = 0)]
		[ValidateScript( { ($_ -le 32) -and ($_ -ge 0) } )]
		[int] $CIDR = 32,
		[Parameter(Mandatory = $true, ParameterSetName = 'MASK', Position = 0)]
		[ValidateScript( { $_ -match [ipaddress] $_ })]
		[Alias('Subnet', 'SubnetMask')]
		[string] $Mask = '255.255.255.255',
		[Parameter(Mandatory = $false, ParameterSetName = 'CIDR', Position = 1)]
		[Parameter(Mandatory = $false, ParameterSetName = 'MASK', Position = 1)]
		[ValidateScript( { $_ -match [ipaddress] $_ })]
		[Alias('Address', 'IP')]
		[ipaddress] $IPAddress = '10.0.0.1'
	)

	[string] $MASKFinal = ''
	[int] $CIDRFinal = ''

	#these 1-liners were found on reddit
	if ($PSCmdlet.ParameterSetName -eq 'CIDR') {
		$CIDRFinal = $CIDR
		try {
			$MASKFinal = ([ipaddress]([uint32]::MaxValue - [math]::Pow(2, 32 - $CIDR) + 1)).IPAddressToString
		} catch {
			$MASKFinal = 'Invalid CIDR Value'
		}
	} elseif ($PSCmdlet.ParameterSetName -eq "MASK") {
		$MASKFinal = $Mask
		try {
			$CIDRFinal = (($Mask.Split('.')| % {[convert]::ToString($_, 2)}) -join '' -replace (0)).Length
		} catch {
			$CIDRFinal = 'Invalid Mask Value'
		}
	} else {
		throw "Invalid parameters!"
	}

	#this part was found http://www.ryandrane.com/2016/05/getting-ip-network-information-powershell/
	# Get Arrays of [Byte] objects, one for each octet in our IP and Mask
	$IPAddressBytes = ([ipaddress]::Parse($IPAddress)).GetAddressBytes()
	$SubnetMaskBytes = ([ipaddress]::Parse($MASKFinal)).GetAddressBytes()

	# Declare empty arrays to hold output
	$NetworkAddressBytes = @()
	$BroadcastAddressBytes = @()
	$WildcardMaskBytes = @()

	# Determine Broadcast / Network Addresses, as well as Wildcard Mask
	for ($i = 0; $i -lt 4; $i++) {
		# Compare each Octet in the host IP to the Mask using bitwise
		# to obtain our Network Address
		$NetworkAddressBytes += $IPAddressBytes[$i] -band $SubnetMaskBytes[$i]

		# Compare each Octet in the subnet mask to 255 to get our wildcard mask
		$WildcardMaskBytes += $SubnetMaskBytes[$i] -bxor 255

		# Compare each octet in network address to wildcard mask to get broadcast.
		$BroadcastAddressBytes += $NetworkAddressBytes[$i] -bxor $WildcardMaskBytes[$i]
	}

	# Create variables to hold our NetworkAddress, WildcardMask, BroadcastAddress
	$NetworkAddress = $NetworkAddressBytes -join '.'
	$BroadcastAddress = $BroadcastAddressBytes -join '.'

	# Now that we have our Network, Widcard, and broadcast information,
	# We need to reverse the byte order in our Network and Broadcast addresses
	[array]::Reverse($NetworkAddressBytes)
	[array]::Reverse($BroadcastAddressBytes)

	# We also need to reverse the array of our IP address in order to get its
	# integer representation
	[array]::Reverse($IPAddressBytes)

	# Next we convert them both to 32-bit integers
	$NetworkAddressInt = [System.BitConverter]::ToUInt32($NetworkAddressBytes, 0)
	$BroadcastAddressInt = [System.BitConverter]::ToUInt32($BroadcastAddressBytes, 0)

	#Calculate the number of hosts in our subnet, subtracting one to account for network address.
	[int] $NumberOfHosts = ($BroadcastAddressInt - $NetworkAddressInt) - 1

	New-Object -TypeName psobject -Property @{
		Mask             = $MASKFinal
		CIDR             = $CIDRFinal
		NetworkAddress   = $NetworkAddress
		BroadcastAddress = $BroadcastAddress
		NumberOfHosts    = $NumberOfHosts
	}
}

function ConvertFrom-SID {
	<#
    .SYNOPSIS
        Security ID to Username
    .DESCRIPTION
        Gets the username for a specified system SID
    .EXAMPLE
        ConvertFrom-sid S-1-5-21-4079184686-3691728653-2528636808-500
  #>
	param([string]$SID = "S-1-0-0")
	$objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
	$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
	$objUser.Value
}

function ConvertTo-SID {
	<#
    .SYNOPSIS
        Username to Security ID
    .DESCRIPTION
        Gets the system SID for a specified username
    .EXAMPLE
        ConvertTo-SID administrator
  #>
	param([string]$ID = "Null SID")
	$objID = New-Object System.Security.Principal.NTAccount($ID)
	$objSID = $objID.Translate([System.Security.Principal.SecurityIdentifier])
	Return $objSID.Value
}

new-alias -name FromSID -value ConvertFrom-SID -Description "Get UserName from SID" -Force
new-alias -name ToSID -value ConvertTo-SID -Description "Get SID from UserName" -Force

Function ConvertTo-URLEncode([string]$InText = "You did not enter any text!") {
	<#
    .SYNOPSIS
        URL EN-code a string
    .DESCRIPTION
        Replaces "special characters" with their URL-clean codes
    .EXAMPLE
        ConvertTo-URLEncode "This is a string;+^"
  #>
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.web")
	[System.Web.HttpUtility]::UrlEncode($InText)
}

Function ConvertFrom-URLEncode([string]$InText = "You+did+not+enter+any+text!") {
	<#
    .SYNOPSIS
        URL DE-code a string
    .DESCRIPTION
        Replaces URL-clean codes with the ASCII "special characters"
    .EXAMPLE
        ConvertFrom-URLEncode "This%20is%20a%20string%3b%2b%5e"
  #>
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.web")
	[System.Web.HttpUtility]::UrlDecode($InText)
}

New-Alias -name "URLEncode" -Value ConvertTo-URLEncode -Description "URL encode a string" -Force
New-Alias -name "URLDecode" -Value ConvertFrom-URLEncode -Description "URL decode a string" -Force

Function ConvertTo-Fahrenheit([decimal]$celsius) {
	<#
    .SYNOPSIS
        Degrees C to F
    .DESCRIPTION
        Simple math to convert temperature
    .EXAMPLE
        ConvertTo-Fahrenheit 100
  #>
	$((1.8 * $celsius) + 32 )
}

Function ConvertTo-Celsius($fahrenheit) {
	<#
    .SYNOPSIS
        Degrees F to C
    .DESCRIPTION
        Simple math to convert temperature
    .EXAMPLE
        ConvertTo-Celsius 32
  #>
	$( (($fahrenheit - 32) / 9) * 5 )
}

New-Alias -name "ToF" -Value ConvertTo-Fahrenheit -Description "Convert degrees C to F" -Force
New-Alias -name "ToC" -Value ConvertTo-Celsius -Description "Convert degrees F to C" -Force


Function Convert-AddressToName($addr) {
	<#
    .SYNOPSIS
        DNS ip to name lookup
    .DESCRIPTION
        Uses DNS to get the name(s) for a specific ip address
    .EXAMPLE
        Convert-AddressToName 127.0.0.1
  #>
	[system.net.dns]::GetHostByAddress($addr)
}

Function Convert-NameToAddress($addr) {
	<#
    .SYNOPSIS
        DNS name to ip lookup
    .DESCRIPTION
        Uses DNS to get the ip address(es) for a specific computername
    .EXAMPLE
        Convert-NameToAddress myVM
  #>
	[system.net.dns]::GetHostByName($addr)
}

New-Alias -name "n2a" -value Convert-NameToAddress -Description "Get IP Address from DNS by Host Name" -Force
New-Alias -name "a2n" -value Convert-AddressToName -Description "Get Host Name from DNS by IP Address" -Force

function ConvertFrom-RomanNumeral {
	<#
    .SYNOPSIS
        Convert a Roman numeral to a number
    .DESCRIPTION
        Converts a Roman numeral - in the range of I..MMMCMXCIX - to a number. Found at https://stackoverflow.com/questions/267399/how-do-you-match-only-valid-roman-numerals-with-a-regular-expression
    .EXAMPLE
        ConvertFrom-RomanNumeral -Numeral MMXIV
    .EXAMPLE
        "MMXIV" | ConvertFrom-RomanNumeral
  #>
	[CmdletBinding()]
	[OutputType([int])]
	Param (
		[Parameter(Mandatory = $true,
			HelpMessage = "Enter a roman numeral in the range I..MMMCMXCIX",
			ValueFromPipeline = $true,
			Position = 0)]
		[ValidatePattern("^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$")]
		[string] $Numeral
	)
	Begin {
		$RomanToDecimal = [ordered]@{
			M  = 1000
			CM = 900
			D  = 500
			CD = 400
			C  = 100
			XC = 90
			L  = 50
			X  = 10
			IX = 9
			V  = 5
			IV = 4
			I  = 1
		}
	}
	Process {
		$roman = $Numeral + " "
		$value = 0

		do {
			foreach ($key in $RomanToDecimal.Keys) {
				if ($key.Length -eq 1) {
					if ($key -match $roman.Substring(0, 1)) {
						$value += $RomanToDecimal.$key
						$roman = $roman.Substring(1)
						break
					}
				} else {
					if ($key -match $roman.Substring(0, 2)) {
						$value += $RomanToDecimal.$key
						$roman = $roman.Substring(2)
						break
					}
				}
			}
		} until ($roman -eq " ")
		$value
	}
	End {
	}
}

New-Alias -name "FromRoman" -value ConvertFrom-RomanNumeral -Description "Convert from a roman numeral" -Force

function ConvertTo-RomanNumeral {
	<#
    .SYNOPSIS
        Convert a number to a Roman numeral
    .DESCRIPTION
        Converts a number - in the range of 1 to 3,999 - to a Roman numeral. Found at https://stackoverflow.com/questions/267399/how-do-you-match-only-valid-roman-numerals-with-a-regular-expression
    .EXAMPLE
        ConvertTo-RomanNumeral -Number (Get-Date).Year
    .EXAMPLE
        (Get-Date).Year | ConvertTo-RomanNumeral
  #>
	[CmdletBinding()]
	[OutputType([string])]
	Param (
		[Parameter(Mandatory = $true,
			HelpMessage = "Enter an integer in the range 1 to 3,999",
			ValueFromPipeline = $true,
			Position = 0)]
		[ValidateRange(1, 4999)] [int] $Number
	)
	Begin {
		$DecimalToRoman = @{
			Ones      = "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX";
			Tens      = "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC";
			Hundreds  = "", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM";
			Thousands = "", "M", "MM", "MMM", "MMMM"
		}
		$column = @{Thousands = 0; Hundreds = 1; Tens = 2; Ones = 3}
	}
	Process {
		[int[]]$digits = $Number.ToString().PadLeft(4, "0").ToCharArray() | ForEach-Object { [Char]::GetNumericValue($_) }
		$RomanNumeral = ""
		$RomanNumeral += $DecimalToRoman.Thousands[$digits[$column.Thousands]]
		$RomanNumeral += $DecimalToRoman.Hundreds[$digits[$column.Hundreds]]
		$RomanNumeral += $DecimalToRoman.Tens[$digits[$column.Tens]]
		$RomanNumeral += $DecimalToRoman.Ones[$digits[$column.Ones]]

		$RomanNumeral
	}
	End {
	}
}

New-Alias -name "ToRoman" -value ConvertTo-RomanNumeral -Description "Convert to a roman numeral" -Force

Function ConvertTo-Ordinal {
	<#
    .SYNOPSIS
        Add a suffix to numeral
    .DESCRIPTION
        Adds the ordinal (??) suffix to a number. Handy for denoting the 1st, 2nd, or 3rd... etc. ... of something. Defaults to the current day.
    .EXAMPLE
        ConvertTo-Ordinal -Number (Get-Date).Day
    .EXAMPLE
        PS > "The $(ConvertTo-Ordinal (Get-Date).Day) day of the $(ConvertTo-Ordinal (Get-Date).ToString("%M")) month of the $(ConvertTo-Ordinal (Get-Date).Year) year"

        The 25th day of the 3rd month of the 2016th year
  #>
	[CmdletBinding()]
	[OutputType([string])]
	Param (
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
		[int]$Number = (Get-Date).Day
	)
	Switch ($Number % 100) {
		11 { $suffix = "th" }
		12 { $suffix = "th" }
		13 { $suffix = "th" }
		default {
			Switch ($Number % 10) {
				1 { $suffix = "st" }
				2 { $suffix = "nd" }
				3 { $suffix = "rd" }
				default { $suffix = "th"}
			}
		}
	}
 "$Number$suffix"
}
