<# 
.SYNOPSIS 
    Console Color Sample Sheet
         
.DESCRIPTION 
    Outputs a table of color samples - showing all background and foreground combinations.
 
.EXAMPLE 
    PS C:\> Get-ColorSample

    Writes ... the color samples
#>


function pad ([string] $text, [int16] $i = 2) {
    #Pad the text with spaces
    #based on "column" width
    #left and right padding different depending on even or odd number width
    $i = $i - $text.Length
    $padR = (" " * (1 + ([math]::Ceiling($i /2 ))))
    $padL = (" " * (1 + ([math]::Floor($i /2 ))))
    $retval = "$padL$text$padR"
    $retval
}

function list_it ($yaxis, $xaxis) {
    #Repeatable format
    #Call this with
    #    * background colors across the Y-Axis (the top row)
    #    * foreground colors across the X-Axis (the first column)

    #Text to use as the ... sample text
    $sample = "Sample"

    #Column Sizing
    #Just finds the widest item and sizes the first column appropriately (w 1 extra space for column separation)
    $l = 4
    $f | ForEach-Object {
        if ($_.ToString().Length -gt $l ) { $l = $_.ToString().Length + 1 }
    }

    ##Create the heading row
    #blank out the first column
    write-host " ".PadRight($l, " ") -ForegroundColor $host.ui.rawui.Foregroundcolor -BackgroundColor $host.ui.rawui.backgroundcolor -NoNewline

    #Then cyle through the yaxis colors for their names and column padding
    $yaxis | ForEach-Object {
        #Have to be certain the column is wider than our sample text ("red" is too narrow for "sample", for example)
        $width = $_.ToString().Length
        if ($width -lt $sample.Length) { $width = $sample.Length + 2 }
        Write-Host (pad $_.ToString() $width)  -ForegroundColor $host.ui.rawui.Foregroundcolor -BackgroundColor $host.ui.rawui.backgroundcolor  -NoNewline
    }
    #End the header row
    write-host ""

    #Create the item rows, 1 for each color
    $xaxis | ForEach-Object {
        #First, right the name of the foreground color "normally"
        write-host $_.ToString().PadRight($l, " ")  -ForegroundColor $host.ui.rawui.Foregroundcolor -BackgroundColor $host.ui.rawui.backgroundcolor  -NoNewline

        #Set the foreground color so we can use it in the next foreach loop
        $fg = $_

        #Now, cycle through all the fore-/background combinations
        $yaxis | ForEach-Object {
            #again, make sure our column is wider than the sample (yeah, I could've used an array, but this is simpler, I think
            $width = $_.ToString().Length
            if ($width -lt $sample.Length) { $width = $sample.Length + 2 }
            #And the actual color sample (finally!)
            write-host (pad $sample $width) -ForegroundColor $fg -BackgroundColor $_ -NoNewline
        }
    #End the sample row
    write-host ""
    }
}


function Get-ColorSample {
    <# 
    .SYNOPSIS 
        Console Color Sample Sheet
         
    .DESCRIPTION 
        Outputs a table of color samples - showing all background and foreground combinations.
 
    .EXAMPLE 
        PS C:\> Get-ColorSample

        Writes ... the color samples
    #>


    #Load up all the colors
    #Split them into light and dark so we can have 2 lists
    #    if they ever add "bright" or other colors, could have 3 or more....
    $f = [enum]::GetValues([System.ConsoleColor])
    $fdark = $f | where-object { $_ -match "Dark*" } 
    $flite = $f | Where-Object { $_ -notmatch "Dark" } 

    #Re-bind the colors in our "separated" order
    #basically a sort because sort-object doesn't quite work right against the enum
    #at least, I couldn't figure it out in the 10 minutes I spent on it
    $f = $fdark
    $f += $flite

    #Call the function for dark backgrounds, all foregrounds
    list_it $fdark $f
    write-host " "

    #Call the function for lite backgrounds, all foregrounds
    list_it $flite $f
    write-host " "
}

write-host
get-colorsample