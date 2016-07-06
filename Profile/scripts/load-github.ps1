## GitHub
if ((Test-Path $env:LOCALAPPDATA\GitHub\shell.ps1) -and ($env:github_git -eq $null)) { 
    #Ok, we have GitHub - let's make a profile psdrive
    New-ProfilePSDrive -name GitHome -Location $env:LOCALAPPDATA\GitHub -Description "Git program and source files"
    #Now I'll parse github's shell.ps1 - pulling out only the code I want
    ##   Anything that sets and environment variable (match $env at the start of a line)
    ##       But not the editor (notmatch EDITOR)
    ##       But not posh_git (notmach posh_git)
    ##   And add the variables needed for the Path statment (match $pGitPath, $appPath, $msBuildPath)
    #and run it as a script expression
    [String]$ShellCodeToRun = ""
    Get-Content $env:LOCALAPPDATA\GitHub\shell.ps1 | Where-Object { 
        (
            (($_.ToString().Trim() -match "^.env") `
            -and ($_ -notmatch "EDITOR") `
            -and ($_ -notmatch "posh_git")) `
            -or ($_.ToString().Trim() -match "^.pGitPath|^.appPath|^.msBuildPath") 
        )
    } | ForEach-Object { $ShellCodeToRun += $_ + ";" }
    if ($ShellCodeToRun.Length -gt 0) { 
        Try {
            Invoke-Expression $ShellCodeToRun 
        }
        Catch {
            write-host "Could not initialize Git!" -ForegroundColor Red -BackgroundColor Black
        }
    }
}