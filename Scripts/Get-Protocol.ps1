function Get-Protocol            
{            
    <#
    .Synopsis
        Gets well-known internet protocols
    .Description
        Gets information about well-known internet protocols.  
        
        This information is listed in: 
            $env:windir\System32\drivers\etc\services
            
        This script parses that information and turns it into PowerShell
        objects.         
        
    .Example   
		# Get all of the protocols
        Get-Protocol
        
    .Example
        # Get some well known protocols
        Get-Protocol http, https, ssh, telnet, smtp, pop3
		
	.Example
		# List protocols across a range
		1..139 | Get-Protocol

    .LINK
        http://blog.start-automating.com/updates/Get-Protocol/
		
    #>            
                
    # CmdletBinding points to a parameter set with no parameters, 'All'.            
    # Using this trick, it's possible to have a good default behavior with            
 # no parameters without complex parameter guessing logic            
    [CmdletBinding(DefaultParameterSetName='All')]                
    param(            
    # Get a named protocol            
    [Parameter(Mandatory=$true,            
        Position='0',            
        ValueFromPipelineByPropertyName=$true,            
        ParameterSetName='SpecificProtocols')]            
    [Alias('Name')]            
    [String[]]$Protocol,            
                
    # Get protocols on a port            
    [Parameter(Mandatory=$true,                    
        ValueFromPipeline=$true,            
        ValueFromPipelineByPropertyName=$true,            
        ParameterSetName='SpecificPorts')]                
    [int[]]$Port,            
                
    # Only return TCP protocols
    [Alias('TCP')]
    [switch]$OnlyTCP,            
                
    # Only return UDP protocols            
    [Alias('UDP')]
    [switch]$OnlyUDP            
    )            
                
    #region Parse Services File            
    begin {            
        $servicesFilePath = "$env:windir\System32\drivers\etc\services"            
        # Get-Content cannot read this file as a low-rights, user, so we have to use            
        # [IO.File] to work with it            
            
        # The file was kind enough to give us this line of comments to help us parse it            
        # <service name>  <port number>/<protocol>  [aliases...]   [#<comment>]            
                    
        # Because ReadAllText gives us everything in a big chunk,            
        # we need to -split it up. Then -notlike filters out comments.            
        # BTW: Did you know notice you could -split lines with an operator?            
        $lines =            
            [IO.File]::ReadAllText("$env:windir\System32\drivers\etc\services") -split             
                ([Environment]::NewLine) -notlike "#*"            
            
                    
        $protocols =             
            foreach ($line in $lines) {            
                # Some lines will be blank, and those lines will be caught            
                # by a -not            
                if (-not $line) { continue }             
                            
                # Here, we use multiple assignment.  If you have a list of variables            
                # on the left side of the equals, and a list on the right, PowerShell            
                # will put the items in each matching variable, and the            
                # rest of the items in the last variable.            
                $serviceName, $portAndProtocol, $aliasesAndComments = $line -split "  +"
                            
                # We use multiple assignment once more to take            
                # $portAndProtocol and split it into two unique            
                # variables            
                $portNumber, $protocolName = $portAndProtocol.Split("/")            
                            
                <#
                To get the aliases and the lists, we use a trick of PowerShell 
                operators.  
                
                We force $aliasAndComments to be a list with @().
                Most operators in PowerShell will return the items in a list 
                that match a condition, and an empty list if nothing 
                matches.
                
                $aliases are -notlike "#*", and $comments are, and
                with this operator trickery we can make the lists 
                only contain the matching items, or remain empty.                
                #>

                [string]$aAliases = @($aliasesAndComments) -notlike "#*"
                $aliases = $aAliases.Trim().Split(" ").Trim()
                [String[]]$acomments = @()
                $aComments = @($aliasesAndComments) -like "#*"
                [string]$comments = $aComments
                $comments = $comments.Replace("#", "").Trim()
                            
                <# 
                Now we combine all of these variables into an object.  
                You can use New-Object PSObject -Property @{} to easily
                turn hashtables into objects, which makes working with
                them in PowerShell from then on a lot easier.                
                #>                        
                $result =             
                    New-Object PSObject -Property @{            
                        ServiceName=$serviceName            
                        Port=$portNumber            
                        Protocol=$protocolName            
                        Alias=$aliases            
                        Comment=$comments
                    }             
                                
                <#
                This last little bit is for the PowerShell Engine.  
                
                PowerShell can format objects, but only if they're named something.
                
                To add a typename, you work with a hidden property almost every object
                you see in PowerShell has, .PSObject.  PSObject has a collection
                of typenames, and by adding one, you can make the formatting engine work.                

                #>            
                $result.PSObject.TypeNames.add("Network.Protocol")   
                
            #Sets the "default properties" when outputting the variable... but really for setting the order
            $defaultProperties = @('ServiceName', 'Protocol', 'Port', 'Alias', 'Comment')
            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
            $result | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                
                
                         
                $result            
            }                                        
    }                    
    #endregion            
                
    #region Process Input            
    process {            
        <#
        The way this command works, we already know all of the protocols.
        The trick is turning all of the parameters into useful things to 
        filter that data.
        
        We'll use Where-Object to get the trick done. 
        
        Where-Object will output a batch of objects that match a filter.  
        
        By combining multiple Where-Objects, you can make commands that
        filter output or parse text more effectively.
        
        I call this technique "Wherestacking"     
                
        In this function, we'll use between 0-2 Where-Objects.                                          
        
        Two parameters, -OnlyTCP and -OnlyUDP, exist outside of parameter
        sets.  This is because they're useful in all parameter sets.
        
        The They're technically mutually exclusive, so we need a bunch
        of if/elseifs to get the job done.
        
        Most of the cases will set $filter
        #>            
        $filter = $null                            
        if ($OnlyTCP) {            
            $filter = { $_.Protocol -eq 'TCP' }             
        } elseif ($OnlyUDP) {            
            $filter = { $_.Protocol -eq 'UDP' }             
        }            
                    
        # By checking to see if the filter is defined,            
        # we can save time and not filter            
        if ($Filter) {            
            $filtererdProtocols = $protocols |            
                Where-Object $filter            
        } else {            
            $filtererdProtocols = $protocols            
        }            
                                    
        # If the Parameter Set is "All", we output all of the protocols            
        if ($psCmdlet.ParameterSetName -eq 'All')             
        {            
            Write-Output $filtererdProtocols             
        } elseif ($psCmdlet.ParameterSetName -eq 'SpecificPorts') {            
            # Otherwise, if we're looking for ports, we add another Where-Object            
            # to find ports, and output that.            
            $filtererdProtocols |            
                Where-Object {            
                    $Port -contains $_.Port            
                } |            
                Write-Output            
        } elseif ($psCmdlet.ParameterSetName -eq 'SpecificProtocols') {            
            # Otherwise, if we're looking for protcols, we add another Where-Object            
            # to find ports, and output that.            
            $filtererdProtocols |            
                Where-Object {            
                    $Protocol -contains $_.ServiceName            
                }|            
                Write-Output            
        }                        
    }                  
    #endregion            
}