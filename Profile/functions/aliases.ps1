Function Set-ProgramAliases {
	#Create aliases for a list of applications
	#Searches directory for multiple versions
	#Adds aliases for each version...

	# The list is in
	#     "alias | program | path"
	# format
	# Separator is the pipe | symbol
	# Each line ends in a comma if it's not the end...
	#    kinda,
	#    like,
	#    this
	$PgmList = (
		"word | winword.exe | c:\progra*\micro*office*",
		"excel | excel.exe | c:\progra*\micro*office*",
		"primal | PrimalScript.exe | c:\progra*\sapien*",
		"sublime | sublime_text.exe | c:\progra*\Sublime*"
	)

	#Now, cycle through each item and search for the correct path(s)
	ForEach ($item in $PgmList) {
		$name = $item.split("|")[0].trim()
		try {
			$found = Find-Files $item.split("|")[2].trim() $item.split("|")[1].trim() | Add-Member -ErrorAction Stop -MemberType ScriptProperty -Name ProductName -value { $this.VersionInfo.ProductName } -PassThru | Add-Member -ErrorAction Stop -MemberType ScriptProperty -Name Version -value { $this.VersionInfo.ProductVersion } -PassThru | Sort-Object -property @{Expression = {$_.Version}; Ascending = $False}
			#Now, if amything was found, test if the alias exists
			#Create it if it doesn't
			ForEach ($file in $found) {
				#We have some redundant copies in an Updates folder causing problems... this ignores them
				if (-not $file.Fullname.Contains("Updates")) {
					if (!(test-path Alias:\$name)) {
						set-alias -name $name -value $file.Fullname -Description $file.ProductName -scope Global
					}
					#Otherwise, (alias exists) create a new alias with the product version
					else {
						try {
							$name += $file.Version.split(".")[0].trim()
							#But only 1 for each additional major version (so 14.533 and 14.255 will only create 1 alias)
							if (!(test-path Alias:\$name)) {
								set-alias -name $name -value $file.Fullname -Description $file.ProductName -scope Global
							}
						} Catch {
							#Nothing to do here...
						}
					}
				}
			}
		} catch { }
	}
}
