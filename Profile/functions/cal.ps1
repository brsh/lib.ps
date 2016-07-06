function Get-Calendar {
    <# 
    .SYNOPSIS 
        Gets a monthly calendar
 
    .DESCRIPTION 
        Returns a monthly calendar for the Month and Year specified (defaults to the current month). Similar to the Linux/Unix cal command.
 
    .PARAMETER Month
        The month (1-12) to return

    .PARAMETER Year
        The Year (1921 or later) to return

    .EXAMPLE
        PS C:\> Get-Calendar

        Returns the calendar
    
    .EXAMPLE
        PS C:\> Get-Calendar -month 4

        Returns the calendar for April of the current year

    .EXAMPLE
        PS C:\> Get-Calendar -month 3 -year 1971

        Returns the calendar for March, 1971
    #> 
  param(
    [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true)]
    [ValidateRange(1,12)]
    [Int32]$Month = (Get-Date -UFormat %m),
    
    [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true)]
    [ValidateScript({$_ -ge 1921})]
    [Int32]$Year = (Get-Date -UFormat %Y)
  )
  
  begin {
    $arr = @()
    $cal = [Globalization.CultureInfo]::CurrentCulture.Calendar
  }

  process {
    function GenArray  {
        param (
            [int]$Total,
            [int]$Start = 1,
            [char]$Character
        )
        $retval = @()
        $Start..$Total | ForEach-Object {
            if ($Character) {
                $retval += [String](($Character.ToString().PadLeft(2)))
            }
            else {
                $retval += [String](($_.ToString().PadLeft(2)))
            }
        }
        $retval
    }
    function WriteHead{
        $Days = 0..6 | ForEach-Object { ([Globalization.DatetimeFormatInfo]::CurrentInfo.AbbreviatedDayNames[$_]).ToString().SubString(0, 2) }
        Write-Host $Days[0..6]
    }

    $FirstDayOfMonth = [Int32]$cal.GetDayOfWeek([DateTime]([String]$Month + ".1." + [String]$Year))
    if ($FirstDayOfMonth -ne 0) {
        #Month starts on a day other than Sunday
        #Fill in some spaces...
        $Hold = 7 # - $FirstDayOfMonth
        $arr += GenArray -Start (7 - $FirstDayOfMonth + 1) -Total $Hold -Character " "
    }
        
    $LastMonth = $arr.Length
    $arr += GenArray $cal.GetDaysInMonth($Year, $Month)

    #And the start of the next next month
    $NextNextMonthStart = $arr.Length
    if ([Bool]($NextNextMonthStart % 7)) {
        $Year = (get-date).AddMonths(1).ToString("yyyy")
        $Month = (get-date).AddMonths(1).ToString("MM")
        $arr += GenArray (7 - ($NextNextMonthStart % 7)) -Character " "
    }
  }
  end {
    $SubCount = 0
    WriteHead
    for ($i = 0; $i -lt $arr.Length; $i+=1) {
        $subcount += 1
        
        #Now actually output the Date Number
        Write-host $arr[$i] -NoNewline
        Write-Host " " -NoNewline
        #And end the line if we're at the end of a week
        if ($SubCount -eq 7) {
            $SubCount = 0
            write-host ""
        }
    }
  }
}

set-alias -name cal -value Get-Calendar -Description "Show current month calendar" -Force

function Get-CurrentCalendar {
    <# 
    .SYNOPSIS 
        Get the previous, current, and next month
 
    .DESCRIPTION 
        Outputs a month calendar of the last, current, and next month with today's date highlighted.
 
    .EXAMPLE
        PS C:\> Get-CurrentCalendar

        Returns the calendar
    #> 
    function GenArray  {
        param (
            [int]$End,
            [int]$Start = 1
        )
        $retval = @()
        $Start..$End | ForEach-Object {
            $retval += [String](($_.ToString().PadLeft(2)))
        }
        $retval
    }
    function WriteHead {
        $Days = 0..6 | ForEach-Object { ([Globalization.DatetimeFormatInfo]::CurrentInfo.AbbreviatedDayNames[$_]).ToString().SubString(0, 2) }
        Write-Host $Days[0..6] -ForegroundColor Green -BackgroundColor Black
    }
    
    $arr = @()
    $cal = [Globalization.CultureInfo]::CurrentCulture.Calendar
    
    $ColorBackDefault = $host.ui.RawUI.BackgroundColor
    $ColorForeFurthest = [System.ConsoleColor]"DarkGray"
    $ColorBackFurthest = $ColorBackDefault
    $ColorForeNotCurrent = [System.ConsoleColor]"DarkCyan"
    $ColorBackNotCurrent = $ColorBackDefault
    $ColorForeToday = [System.ConsoleColor]"Yellow"
    $ColorBackToday = [System.ConsoleColor]"Black"
    $ColorForeCurrentPast = [System.ConsoleColor]"Gray"
    $ColorBackCurrentPast = $ColorBackDefault
    $ColorForeCurrentNext = [System.ConsoleColor]"White"
    $ColorBackCurrentNext = $ColorBackDefault
    
    ##Assemble the Calendar by putting months together
    #Previous Month
    $Year = (get-date).AddMonths(-1).ToString("yyyy")
    $Month = (get-date).AddMonths(-1).ToString("MM")
    
    #On what day does the first of this month fall?
    $FirstDayOfMonth = [Int32]$cal.GetDayOfWeek([DateTime]([String]$Month + ".1." + [String]$Year))
    if ($FirstDayOfMonth -ne 0) {
        #Month starts on a day other than Sunday
        #Fill in the end of the previous previous month
        $HoldYear = (get-date).AddMonths(-2).ToString("yyyy")
        $HoldMonth = (get-date).AddMonths(-2).ToString("MM")
        $Hold = [int]$cal.GetDaysInMonth($HoldYear, $HoldMonth)
        $arr += GenArray -Start ($Hold - $FirstDayOfMonth + 1) -End $Hold
    }
        
    $LastMonth = $arr.Length
    $arr += GenArray -End $cal.GetDaysInMonth($Year, $Month)
    
    #Current Month
    $Year = (get-date).ToString("yyyy")
    $Month = (get-date).ToString("MM")
    
    $CurrMonthStart = $arr.Length
    $arr += GenArray -End $cal.GetDaysInMonth($Year, $Month)
    
    #Next Month
    $Year = (get-date).AddMonths(1).ToString("yyyy")
    $Month = (get-date).AddMonths(1).ToString("MM")
    
    $NextMonthStart = $arr.Length
    $arr += GenArray -End $cal.GetDaysInMonth($Year, $Month)
    
    #And the start of the next next month, if necessary
    $NextNextMonthStart = $arr.Length
    if ([Bool]($NextNextMonthStart % 7)) {
        $Year = (get-date).AddMonths(2).ToString("yyyy")
        $Month = (get-date).AddMonths(2).ToString("MM")
        $arr += GenArray -End (7 - ($NextNextMonthStart % 7))
    }
    
    #Put it all together for output with color
    $SubCount = 0
    write-host "" (get-date -u "%a - %b %d, %Y")
    WriteHead
    for ($i = 0; $i -lt $arr.Length; $i+=1) {
        $subcount += 1
        if ((($LastMonth -gt 0) -and ($i -lt $LastMonth)) -or ($i -ge $NextNextMonthStart)) {
            #Set Color for the oldest and "futurist" months in the list
            $Color = $ColorForeFurthest
            $ColorBack = $ColorBackFurthest
        }
        elseif (($i -lt $CurrMonthStart) -or ($i -ge $NextMonthStart)) {
            #Set Color for Last Month and Next Month
            $Color = $ColorForeNotCurrent
            $ColorBack = $ColorBackNotCurrent
        }
        else {
            #We are in current month - test for today and color it, plus the previous and upcoming days
            $TodaysDate = (get-date -UFormat %d).ToString().PadLeft(2)
            Switch ($arr[$i]) {
                { $_ -eq $TodaysDate } { $Color = $ColorForeToday; $ColorBack = $ColorBackToday; break }
                { $_ -lt $TodaysDate } { $Color = $ColorForeCurrentPast; $ColorBack = $ColorBackCurrentPast; break }
                default { $Color = $ColorForeCurrentNext; $ColorBack = $ColorBackCurrentNext; break }
            }
        }
        #Now actually output the Date Number
        Write-host $arr[$i] -NoNewline -ForegroundColor $Color -BackgroundColor $ColorBack
        Write-Host " " -NoNewline
        #And end the line if we're at the end of a week
        if ($SubCount -eq 7) {
            $SubCount = 0
            write-host ""
        }
    }
    WriteHead
}

set-alias -name curcal -value Get-CurrentCalendar -Description "Show last, current, and next months" -Force
