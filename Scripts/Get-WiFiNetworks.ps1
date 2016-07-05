

#Note try : Get-WifiNetwork | select index, ssid, signal, 'radio type' | sort signal -desc | ft -auto
#Doesn't work without the Wireless AutoConfig Service (wlansvc) running... 
#Might someday work on fixing that...

if ($(get-service | where-object { $_.Name -eq "wlansvc" }).Status -eq "Running") { 
    netsh wlan sh net mode=bssid | ForEach-Object -process {
        if ($_ -match '^SSID (\d+) : (.*)$') {
            $current = @{}
            $networks += $current
            $current.Index = $matches[1].trim()
            $current.SSID = $matches[2].trim()
        } 
        else {
            if ($_ -match '^\s+(.*)\s+:\s+(.*)\s*$') {
                $current[$matches[1].trim()] = $matches[2].trim()
            }
        }
    } -begin { $networks = @() } -end { $networks | ForEach-Object { new-object psobject -property $_ } }
 }
 else {
    write-Host "Wireless AutoConfig Service (wlansvc) is not running."
}

