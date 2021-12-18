<#
.SYNOPSIS
Enables Windows File Explorer Previews of PS Files

.DESCRIPTION
Seriously... how hard would it be for this to be built-in?!?

'Course, I don't actually _use_ the preview, but maybe I will now!

Anyhoo - Windows File Explorer has a file preview pane (to enable it, go to the View tab, Show, Preview Pane). 
Once these reg values are added, the pane will treat script files as text and display a preview.

.EXAMPLE
Enable-PSExplorerPreview

.LINK
https://tfl09.blogspot.com/2021/12/viewing-powershell-files-in-preview.html
#>

# Define paths
$Path1 = 'Registry::HKEY_CLASSES_ROOT\.ps1'
$Path2 = 'Registry::HKEY_CLASSES_ROOT\.psm1'
$Path3 = 'Registry::HKEY_CLASSES_ROOT\.psd1'

# Set registry values to enable preview
New-ItemProperty -Path $Path1 -Name PerceivedType -PropertyType String  -Value 'text'
New-ItemProperty -Path $Path2 -Name PerceivedType -PropertyType String  -Value 'text'
New-ItemProperty -Path $Path3 -Name PerceivedType -PropertyType String  -Value 'text'
