<#
.SYNOPSIS
Pull code from snippet library

.DESCRIPTION
The PowerShell ISE has code Snippets that ease script creation (hit Cntrl-J to see the list). And, since Snippets are an ISE feature, the ISE PS console has a few Snippet related commands (Get-ISESnippet, Import-ISESnippet, New-ISESnippet)... which aren't available outside of the ISE. Yeah, that makes sense, but sometimes you want to see sample code when you're just sitting at a normal PS console.

This script searches the default "user" Snippet location ($env:UserProfile\Documents\WindowsPowerShell\Snippets) and my Lib.PS Snippet location and outputs any Snippets that match the search terms (or all of them if no search is specified).

Of course, to use the Lib.PS Snippets, you have to enter 'Import-IseSnippet [PathToLib.PS]\Snippets' either each time you start ISE via the ISE Console or once via the ISE's profile (try $env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1).

.PARAMETER Name
Search/Filter by Snippet Name

.PARAMETER Title
Search/Filter by Snippet Title

.PARAMETER Description
Search/Filter by Snippet Description

.PARAMETER Code
Search/Filter by Snippet Code

.EXAMPLE
Get-Snippet.ps1

Lists all Snippets

.EXAMPLE
Get-Snippet.ps1 -Name Admin

Lists Snippets with 'Admin' in the filename

.EXAMPLE
Get-Snippet.ps1 -Code Start-Sleep

Lists Snippets with 'Start-Sleep' in the code
#>


[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $Name,
    [Parameter(Mandatory=$false)]
    [string] $Title,
    [Parameter(Mandatory=$false)]
    [String] $Description,
    [Parameter(Mandatory=$false)]
    [String] $Code
)

BEGIN {
    function AddPathToSearch {
        param (
            [string] $Path = $pwd
        )
        if (Test-Path $Path) {
            $script:SnippetPath = $script:SnippetPath + $Path
        }
    }

    [string[]] $script:SnippetPath = @()

    AddPathToSearch -Path "$env:UserProfile\Documents\WindowsPowerShell\Snippets\"
    AddPathToSearch -Path "$LibPath\Snippets"

    if ($script:SnippetPath) {
            $Snippets += Get-ChildItem $script:SnippetPath -Filter "*.ps1xml" -Recurse -ErrorAction SilentlyContinue
    }
    [bool] $DoIt = $true
}

PROCESS {
    if ($Snippets) {
        if ($name) {
            $Snippets = $Snippets | Where-Object { $_.Name -match "$Name" }
        }
        $Snippets | ForEach-Object {
            [bool] $DoIt = $true
            try {
                $b = [xml] (Get-Content $_.FullName -ErrorAction Stop)
            }
            Catch {
                $b = [XML] "
                    <Snippets>
                        <Snippet>
                            <Header>
                                <Title>Not a Valid XML File</Title>
                                <Description>Not a Valid XML File</Description>
                                <Author>Not a Valid XML File</Author>
                            </Header>
                            <Code>
                                <Script Language='PowerShell'>Not a Valid XML File</Script>
                            </Code>
                        </Snippet>
                    </Snippets>
                "
            }

            if ($Title) { if (-not ($b.Snippets.Snippet.Header.Title -match $Title)) { $DoIt = $false } }
            if ($Description) { if (-not ($b.Snippets.Snippet.Header.Description -match $Description)) { $DoIt = $false } }
            if ($Code) { if (-not ($b.Snippets.Snippet.Code.Script.'#cdata-section' -match $Code)) { $DoIt = $false } }

            if ($DoIt) {
                $InfoHash =  @{
                    Name = $_.Name
                    FullName = $_.FullName
                    BaseName = $_.BaseName
                    Folder = $_.Directory.Fullname
                    Title = $b.Snippets.Snippet.Header.Title
                    Description = $b.Snippets.Snippet.Header.Description
                    Author = $b.Snippets.Snippet.Header.Author
                    Code = $b.Snippets.Snippet.Code.Script.'#cdata-section'
                    Language = $b.Snippets.Snippet.Code.Script.Language
                }
                $InfoStack = New-Object -TypeName PSObject -Property $InfoHash

                #Add a (hopefully) unique object type name
                $InfoStack.PSTypeNames.Insert(0,"Snippet.Information")

                #Sets the "default properties" when outputting the variable... but really for setting the order
                $defaultProperties = @('Title', 'Name', 'Folder', 'Description', 'Code')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                $InfoStack
            }
        }
    }

}

END { }

