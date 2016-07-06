
function Get-LoadedModuleFunctions {
    param(
        [Parameter(Mandatory=$false)]
        [alias("get","list")]
        [switch] $GetList,
    
        [Parameter(Position=0,Mandatory=$false)]
        [string] $Module = "ALL"
    )

    #An array to skip certain default functions (I load prompt; MS loads readline)
    #BUT, we only want to ignore these if we're looking at the "All" (or general) listing
    #$ToIgnore = "prompt", "PSConsoleHostReadline"
    $ToIgnore = $Global:SnewToIgnore
    $ProcessIgnore = $true

    #Pull all the script modules currently loaded
    $list = get-Module | Where-Object { $_.ModuleType -match "Script" }

    #If we're looking for the list, just give it and exit
    #This is redundant functionality to get-module, really, but handy to have in the functioin
    if ($GetList) { $list | ft -AutoSize Name,ModuleType,Version; break }

    #Check if we're looking for somthing specific or all modules
    #if specific, we want to limit the $list to that object and process ALL functions, even the generally ignored items
    if ($Module -notmatch "ALL") { $list = $list | Where-Object { $_.Name -eq "$Module" }; $ProcessIgnore = $false }

    #Now, let's process the modules and get their functions!
    $list | ForEach-Object {
        #Quick holder for the module name
        $which = $_.Name

        #Cycle through the functions which exist in the module
        Get-Command -Type function | Where-Object { $_.Source -match "$which" } | ForEach-Object {
            #Set the Skip to false so we don't skip the processing
            $Skip = $false
            #Now, test if we should test for ignored functions or modules
            #and set Skip as appropriate
            if ($ProcessIgnore) { 
                #if ($ToIgnore -contains $_.Name) { $Skip = $True} 
                if ($ToIgnore.Contains($_.Name)) { $Skip = $True} 
                if ($ToIgnore.Contains($_.Source)) { $Skip = $True} 
            }
        
            #Now, based on whether we skip or not
            If (-not $Skip) {
                #Create the infohash for the object with the info we want
                $InfoHash =  @{
                    Alias = $(get-alias -definition $_.Name -ea SilentlyContinue)
                    Command = $_.Name
                    Description = $(Get-help $_.Name).Synopsis
                    Module = $_.Source
                    HelpURI = $_.HelpUri
                    Version = $_.Version
                }
                $InfoStack = New-Object -TypeName PSObject -Property $InfoHash

                #Add a (hopefully) unique object type name
                $InfoStack.PSTypeNames.Insert(0,"Cmd.Information")

                #Sets the "default properties" when outputting the variable... but really for setting the order
                $defaultProperties = @('Command', 'Alias', 'Module', 'Description')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                #And output
                $InfoStack
            }
        }
    }
}

New-Alias -name glmf -Value Get-LoadedModuleFunctions -Description "List functions from loaded modules" -force

Function Get-NewCommands {
    # Displays a list of aliases that have descriptions
    # Each alias in this file is created with descriptions,
    # Hence, this shows the list of aliases in this file
    # (maybe more!)
	param (
		[switch] $ModulesToo = $false
	)
    $CommandWidth=25
    $AliasWidth=12

    $retval = Get-Alias | where-object { $_.Description } 
    
    $retval | Sort-Object ResolvedCommandName -unique | `
        format-table @{Expression={$_.ResolvedCommandName};Label="Command";width=$CommandWidth},@{Expression={$_.Name};Label="Alias";width=$AliasWidth},@{Expression={$_.Description};Label="Description"} 
	if ($ModulesToo) {
		Get-LoadedModuleFunctions -Module all | sort command | 
			format-table @{Expression={$_.Command};Label="Command";width=$CommandWidth},@{Expression={$_.Alias};Label="Alias";width=$AliasWidth}, @{Expression={$_.Module};Label="Module";width=15}, Description 
	}
}

New-Alias -name snew -value Get-NewCommands -Description "Show this list" -Force

