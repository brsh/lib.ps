
function Invoke-GuiHistory {
	Invoke-Expression "$(( get-history | Out-GridView -PassThru).CommandLine)"
}

set-alias -name hist -value Invoke-GuiHistory -Description "A GUI History command runner" -Force

