# Checks for pwsh 7.2 and loads some defaults if necessary
if (($PSVersionTable.PSVersion.Major -ge 7) -and ($PSVersionTable.PSVersion.Minor -ge 2)) {
	if ($null -ne $PSStyle) {
		$PSStyle.Progress.UseOSCIndicator = 1
		if (-not (Get-ExperimentalFeature PSAnsiRenderingFileInfo).Enabled) {
			$null = Enable-ExperimentalFeature PSAnsiRenderingFileInfo 2>&1
		}
		$Previous = $ErrorActionPreference
		$ErrorActionPreference = 'SilentlyContinue'
		$PSStyle.FileInfo.Extension.Item('.zip') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Item('.tgz') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Item('.gz') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Item('.tar') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Item('.nupkg') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Item('.cab') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Item('.7z') = $PSStyle.Foreground.Green
		$PSStyle.FileInfo.Extension.Add('.csv', $PSStyle.Foreground.BrightMagenta)
		$PSStyle.FileInfo.Extension.Add('.txt', $PSStyle.Foreground.BrightMagenta)
		$PSStyle.FileInfo.Extension.Add('.yml', $PSStyle.Foreground.BrightMagenta)
		$PSStyle.FileInfo.Extension.Add('.yaml', $PSStyle.Foreground.BrightMagenta)
		$PSStyle.FileInfo.Extension.Add('.sh', $PSStyle.Foreground.BrightYellow)
		$PSStyle.FileInfo.Extension.Add('.png', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.jpg', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.jpeg', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.gif', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.bmp', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.tif', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.tiff', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.webp', $PSStyle.Foreground.Cyan)
		$PSStyle.FileInfo.Extension.Add('.msi', $PSStyle.Foreground.BrightGreen)
		$PSStyle.FileInfo.Extension.Add('.doc', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.docx', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.docm', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.dot', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.dotx', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.xls', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.xlsx', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.xla', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.xlsm', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.xlt', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.xltm', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.ppt', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.pptx', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.pot', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.potm', $PSStyle.Foreground.BrightBlue)
		$PSStyle.FileInfo.Extension.Add('.pdf', $PSStyle.Foreground.BrightBlue)
		$ErrorActionPreference = $Previous
		Remove-Variable Previous -ErrorAction SilentlyContinue
	}
}
