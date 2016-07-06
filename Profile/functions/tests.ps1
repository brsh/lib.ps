function Test-Port {
Param([string]$srv,$port=80,$timeout=3000,[switch]$verbose)
 
# Does a TCP connection on specified port (80 by default)
$ErrorActionPreference = "SilentlyContinue"
# Create TCP Client
$tcpclient = new-Object system.Net.Sockets.TcpClient
# Tell TCP Client to connect to machine on Port
$iar = $tcpclient.BeginConnect($srv,$port,$null,$null)
# Set the wait time
$wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)
# Check to see if the connection is done
if(!$wait)
{
    # Close the connection and report timeout
    $tcpclient.Close()
    if($verbose){Write-Host "Connection Timeout"}
    Return "Dead"
}
else
{
    # Close the connection and report the error if there is one
    $error.Clear()
    $tcpclient.EndConnect($iar) | out-Null
    if(!$?){if($verbose){write-host $error[0]};$failed = $true}
    $tcpclient.Close()
}
 
# Return $true if connection Establish else $False
if($failed){return "Failed"}else{return "Alive"}
}
New-Alias -name pp -Value Test-Port -Description "Test a TCP connection on the specified port" -Force

function Test-ValidIPAddress {
    <# 
    .SYNOPSIS 
        Tests for valid IP Address
 
    .DESCRIPTION 
        Validates that the input text is in the correct format of an IP Address. Tests both IPv4 and IPv6. Can test if the ip is alive by using the -IsAlive switch.
 
    .PARAMETER  Text
        The text you expect to be IP Address
 
    .PARAMETER  IsAlive
        Test that the ip is online and accessible via ICMP
    
    .EXAMPLE
        PS C:\> Test-ValidIPv4Address 192.178.1.1

        Returns true because this is a valid IP Address in form
    #> 
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string] $Text,
        [Parameter(Position=1,Mandatory=$false)]
        [Switch] $IsAlive = $false
    )
    try {
        if ($Text -eq [System.Net.IPAddress]::Parse($Text)) {
            if ($IsAlive) {
                Test-Connection $Text -Count 1 -EA Stop -Quiet
            } else {
                $true 
            }
        }
    } Catch {
        $false
    }
}

New-Alias -name isIP -Value Test-ValidIPAddress -Description "Tests for valid IP Address" -force


function Test-ValidMACAddress {
    <# 
    .SYNOPSIS 
        Returns true if valid MAC Address
 
    .DESCRIPTION 
        Validates that the input text is in the correct format of a MAC Address.
 
    .PARAMETER  Text
        The text you expect to be a MAC Address
 
    .EXAMPLE
        PS C:\> Test-ValidMACAddress 82-E4-52-1c-C1-39

        Returns true because this is a valid MAC Address
    #> 
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string] $Text
    )
    $Text -match "^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$"
}

New-Alias -name isMAC -Value Test-ValidMACAddress -Description "Returns true if valid MAC Address" -force


function Test-ValidEmail {
    <# 
    .SYNOPSIS 
        Returns true if valid email
 
    .DESCRIPTION 
        Validates that the input text is in the correct format for email (something@somewhere.domain). Does NOT test that the email address works (can receive/send mail).
 
    .PARAMETER  Text
        The text you expect to be an email address
 
    .EXAMPLE
        PS C:\> Test-ValidEmail me@here.com

        Returns true because this is a valid email address in form (if not in function)
    #> 
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string] $Text
    )
    $Text -match "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$"
}

New-Alias -name isEmail -Value Test-ValidEmail -Description "Returns true if valid email" -force