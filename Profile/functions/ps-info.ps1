function Get-ModuleDirs {
# Enum the module directories
    write-host "PowerShell Module Directories: " -fore White
    ($env:PSModulePath).Split(";") | ForEach-Object { write-host "   "$_ -fore "yellow" }
}

New-Alias -Name moddirs -Value Get-ModuleDirs -Description "List the module directories" -force

function Get-Profiles {
    #use to quickly check which (if any) profile slots are inuse
    $profile| Get-Member *Host*| `
    ForEach-Object {$_.name}| `
    ForEach-Object {$p=@{}; `
    $p.name=$_; `
    $p.path=$profile.$_; `
    $p.exists=(test-path $profile.$_); 
    new-object -TypeName psobject -property $p} | Format-Table -auto
    }
New-Alias -name Profs -value Get-Profiles -Description "List PowerShell profile files/paths" -Force


function Get-SplitEnvPath {
  #display system path components in a human-readable format
  $p = @(get-content env:path| ForEach-Object {$_.split(";")})
  "Path"
  "===="
  ForEach ($p1 in $p){
    if ($p1.trim() -gt ""){
      $i+=1;
      "$i : $p1"
      }
    }
  ""
  }
new-alias -name ePath -value Get-SplitEnvPath -Description "Display the path environment var" -Force