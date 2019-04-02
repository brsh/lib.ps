function New-File($file) { "" | Out-File $file -Encoding ASCII }

New-Alias -name touch -value New-File -Description "Create an empty file" -Force

function New-TimestampedFile() {
	Param
	(
  [string]$Folder = "",
  [string]$Prefix = "temp",
  [string]$Type = "log",
		[switch]$Help
	)
	$HelpInfo = @'

    Function : NewTimestampedFile
    By       : xb90 at http://poshtips.com
    Date     : 02/23/2011
    Purpose  : Creates a unique timestamp-signature text file.
    Usage    : NewTempFile [-Help][-folder <text>][-prefix <text>][-type <text>]
               where
                      -Help       displays this help
                      -Folder     specify a subfolder or complete path
                                  where the new file will be created
                      -Prefix     a text string that will be used as the
                                  the new file prefix (default=TEMP)
                      -Type       the filetype to use (default=LOG)
    Details  : This function will create a new file and any folder (if specified)
               and return the name of the file.
               If no parameters are passed, a default file will be created in the
               current directory. Example:
                                           temp_20110223-164621-0882.log
'@
	if ($help) {
		Write-Host $HelpInfo
		return
	}

	#create the folder (if needed) if it does not already exist
	if ($folder -ne "") {
		if (!(Test-Path $folder)) {
			Write-Host "creating new folder `"$folder`"..." -back black -fore yellow
			New-Item $folder -type directory | Out-Null
		}
		if (!($folder.EndsWith("\"))) {
			$folder += "\"
		}
	}

	#generate a unique file name (with path included)
	$x = Get-Date
	$TempFile = [string]::format("{0}_{1}{2:d2}{3:d2}-{4:d2}{5:d2}{6:d2}-{7:d4}.{8}",
		$Prefix,
		$x.year, $x.month, $x.day, $x.hour, $x.minute, $x.second, $x.millisecond,
		$Type)
	$TempFilePath = [string]::format("{0}{1}", $folder, $TempFile)

	#create the new file
	if (!(Test-Path $TempFilePath)) {
		New-Item -path $TempFilePath -type file | Out-Null
	} else {
		throw "File `"$TempFilePath`" Already Exists! (Really weird, since this is a timestamp!)"
	}

	return $TempFilePath
}
New-Alias -Name ntf -value New-TimestampedFile -Description "Create a new file w/timestamped filename" -Force
