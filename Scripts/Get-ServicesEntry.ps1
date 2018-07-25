function Get-ServicesEntry {
	param (
		[switch] $tcp = $false,
		[switch] $udp = $false,
		[int] $port = -1,
		[string] $name = ""
	)
	$HostsFile = "$env:windir\System32\drivers\etc\services"

	$results = get-content  $HostsFile | Where-Object { ((-not $_.StartsWith("#")) -and ($_.Trim().Length -gt 0)) }

	if ($tcp) {
		$results = $results | Where-Object { $_ -match "/tcp " }
	} elseif ($udp) {
		$results = $results | Where-Object { $_ -match "/udp " }
	}

	if ($name.Length -gt 0) {
		$results = $results | where-object { $_ -match "^$name" }
	} elseif ($port -gt -1) {
		$results = $results | where-object { $_ -match " $port/" }
	}

	$results | ForEach-Object {
		[bool] $WasPortError = $false
		[string] $ServiceName, [string] $PortTemp, [string] $TheRestTemp = $_.ToString().Trim() -split "\s+"
		try {
			[int] $PortNumber = $PortTemp.Split("/")[0]
		} catch {
			[int] $PortNumber = 0
			$WasPortError = $true
		}
		[string] $PortType = $PortTemp.Split("/")[1]
		[string] $Nick = $TheRestTemp.Split("#")[0].Trim()
		try {
			[string] $Comment = $TheRestTemp.Split("#")[1].Trim()
		} catch {
			[string] $Comment = ""
		} finally {
			if ($WasPortError) { $Comment += " !! Port number misread !!" }
		}

		$InfoHash = @{
			Name       = $ServiceName.Trim()
			PortNumber = $PortNumber
			Protocol   = $PortType.Trim()
			Nickname   = $Nick.Trim()
			Comment    = $Comment.Trim()
		}
		$InfoStack = New-Object -TypeName PSObject -Property $InfoHash

		#Add a (hopefully) unique object type name
		$InfoStack.PSTypeNames.Insert(0, "Services.Information")

		#Sets the "default properties" when outputting the variable... but really for setting the order
		$defaultProperties = @('Name', 'PortNumber', 'Protocol', 'Comment')
		$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’, [string[]]$defaultProperties)
		$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
		$InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers

		$InfoStack
	}
}

