function Write-CustomOut {

    <#
    .SYNOPSIS
        Use this function to write output to the console as well as a log file in a consistent manner
    .DESCRIPTION
        Use this function to write output to the console as well as a log file in a consistent manner.

        This code was copied from the 'Write-Log' function developed by Kevin Kirkpatrick (https://github.com/vScripter).

        This makes it easy to add meaningful output to your script/function while at the same time providing a means to send output to a log file.

        The default mode options are listed below, but can be easily expanded, if necessary. If you edit and add more mode options, be sure to update
        the code to include the new range of options.

        You can also specify values to two global variables that this function will look for; one for the Log File and one for the Mode. Those variable names are:
        $Global:LogMode
        $Global:LogFile

        If these variables exist, and are valid, any default values will be ignored.

        Use the -InternalOutput parameter to dispaly verbose messages specific to the Write-Log function/processing

        If no log file is specified at the time the function is called, the log file will default to the user-specific 'AppData' directory. By default, this is set
        to: C:\Users\%USERNAME%\AppData\Roaming. The file will be named 'vCheck-Log-Output_yyyyMMdd.log'; where 'yyyyMMdd' represends a four character year,
        two character month and two character day.

        NOTE: All output appends to log files, by deault. If you wish to have different behavior, you will need to write in that level of detail into your script/function

        Mode Definitions
        0 - Only log to file
        1 - Log to file; log to console using Write-Output
        2 - Log to file; log to console using Write-Verbose
        3 - Only log to console using Write-Ouput
        4 - Only log to console using Write-Verbose
        5 - Log to file; log to console using Write-Verbose; write debug message using Write-Debug
        6 - Log to file; log to console using Write-Warning
        7 - only log to console using Write-Warning
        8 - Log to file; log to console using Write-Warning; write debug message using Write-Debug

    .PARAMETER  Message
        Message you wish to log
    .PARAMETER LogFile
        Log file path; include the actual log file name and extension
    .PARAMETER Mode
        Log mode; see help for mode definitions
    .PARAMETER InternalOutput
        Use this switch to display output specific to the operations of this function
    .OUTPUTS
        System.String
    .EXAMPLE
        Write-Log 'Script log text will get sent to file'

        [2015-06-24|06:41:51-PST] Script log text will get sent to file
    .NOTES
        Author: Kevin Kirkpatrick
        Email: kevin@vmotioned.com
        Last Updated: 20170316
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added to vCheck
        - Modified log file name to be more specific to vCheck
    #>

    [OutPutType([System.String])]
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(Position = 0, Mandatory = $false)]
        [Alias('Details')]
        [System.String]
        $Message,

        [parameter(Position = 1, Mandatory = $false)]
        [System.String]
        $LogFile = "$($ENV:APPDATA)\vCheck-Log-Output_$($(Get-Date).ToString('yyyyMMdd')).log",

        [parameter(Position = 2, Mandatory = $false)]
        [validatepattern('[0-8]')]
        $Mode = 3,

        [Switch]
        $InternalOutput
    )

    BEGIN {

        # assign the mode range regex to a variable
        $modeRangeRegEx = $null
        $modeRangeRegEx = '[0-8]'


        # run a check to see if path to the specified log file exists, if not, fall back to the default path
        if (-not (Test-Path -LiteralPath (Split-Path -LiteralPath $LogFile) -PathType Container)) {

            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Specified log path not found; using default path"

            <# manually setting this here, even though it's specified as the default value for the -LogFile parameter b/c we want to write the log,
            even if a path #>
            $defaultLogPath = "$($ENV:APPDATA)\vCheck-Log-Output_$($(Get-Date).ToString('yyyyMMdd')).log"
            $LogFile        = $defaultLogPath

        } # end if


        if ($Global:LogMode -match $modeRangeRegEx) {

            if ($InternalOutput) {
                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Global Log Mode found. Setting mode to {$($Global:LogMode)}"
            }

            $Mode = $Global:LogMode

        } elseif ($Global:LogMode -and $Global:LogMode -notmatch $modeRangeRegEx) {

            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Global Log Mode found, but the value assigned is not a valid mode {$($Global:LogMode)}. Using default/selected Mode {$Mode}"

        } # end if/elseif


        if ($Global:LogFile -and (Test-Path -LiteralPath (Split-Path $Global:LogFile) -PathType Container)) {

            if ($InternalOutput) {
                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Global Log File found. Setting log file to {$($Global:LogFile)}"
            }

            $LogFile = $Global:LogFile

        } elseif ($Global:LogFile -and (-not (Test-Path -LiteralPath (Split-Path $Global:LogFile) -PathType Container))) {

            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Global Log file found, but it cannot be accessed at {$($Global:LogFile)}. Using default/selected LogFile {$LogFile}"

        } # end if/elseif


        $transcriptTimeStamp = $null
        $messageString = $null

        <# Use the 's' DateTime specifier to append a 'sortable' datetime to the transcript file name.
        This guarantees a unique file name for each second. #>

        $transcriptTimeStamp = (Get-Date).ToString('s').Replace('T', '|')

        # grab the time zone and use a switch block to assign time zone code
        $timeZoneQuery = [System.TimeZoneInfo]::Local
        $timeZone = $null

        switch -wildcard ($timeZoneQuery) {

            '*Eastern*' {
                $timeZone = 'EST'
            }
            '*Central*' {
                $timeZone = 'CST'
            }
            '*Pacific*' {
                $timeZone = 'PST'
            }

        } # end switch

        $transcriptTimeStamp = "$($transcriptTimeStamp)-$timeZone"

        $messageString = "[$transcriptTimeStamp] $Message"


    } # end BEGIN block

    PROCESS {

        switch ($Mode) {

            0 {

                # Only log to file
                if ($InternalOutput) {
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][To File] Writing message {$messageString} to log file {$((Resolve-Path $LogFile).Path)}"
                }

                try {

                    Write-Output  $messageString | Out-File -FilePath $LogFile -Append

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not write to log file {$LogFile}. $_"

                } # end try/catch

            } # end 0


            1 {

                # Log to file; log to console using Write-Output
                if ($InternalOutput) {
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][To File] Writing message {$messageString} to log file {$((Resolve-Path $LogFile).Path)}"
                }

                Write-Output -Message $messageString

                try {

                    Write-Output  $messageString | Out-File -FilePath $LogFile -Append

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not write to log file {$LogFile}. $_"

                } # end try/catch

            } # end 1


            2 {

                # Log to file; log to console using Write-Verbose
                if ($InternalOutput) {
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][To File] Writing message {$messageString} to log file {$((Resolve-Path $LogFile).Path)}"
                }

                Write-Verbose -Message $messageString

                try {

                    Write-Output  $messageString | Out-File -FilePath $LogFile -Append

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not write to log file {$LogFile}. $_"

                } # end try/catch

            } # end 2


            3 {

                # Only log to console using Write-Ouput

                Write-Output  $messageString

            } # end 3


            4 {

                # Only log to console using Write-Verbose
                Write-Verbose -Message $messageString

            } # end 4


            5 {

                # Log to file; log to console using Write-Verbose; log to console using Write-Debug
                if ($InternalOutput) {
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][To File] Writing message {$messageString} to log file {$((Resolve-Path $LogFile).Path)}"
                }

                Write-Verbose -Message $messageString
                Write-Debug -Message $messageString

                try {

                    Write-Output  $messageString | Out-File -FilePath $LogFile -Append

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not write to log file {$LogFile}. $_"

                } # end try/catch

            } # end 5


            6 {

                # Log to file; log to console using Write-Warning
                if ($InternalOutput) {
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][To File] Writing message {$messageString} to log file {$((Resolve-Path $LogFile).Path)}"
                }

                Write-Warning -Message $messageString

                try {

                    Write-Output  $messageString | Out-File -FilePath $LogFile -Append

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not write to log file {$LogFile}. $_"

                } # end try/catch

            } # end 6


            7 {

                # only log to console using Write-Warning
                Write-Warning -Message $messageString

            } # end 7


            8 {

                # Log to file; log to console using Write-Warning; log to console using Write-Debug
                if ($InternalOutput) {
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][To File] Writing message {$messageString} to log file {$((Resolve-Path $LogFile).Path)}"
                }

                Write-Warning -Message $messageString
                Write-Debug -Message $messageString

                try {

                    Write-Output  $messageString | Out-File -FilePath $LogFile -Append

                } catch {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not write to log file {$LogFile}. $_"

                } # end try/catch

            } # end 8


            9 {

                # only log to console using Write-Debug
                Write-Debug -Message $messageString

            } # end 9


        } # end switch $Mode

    } # end PROCESS block

    END {

        if ($InternalOutput) {
            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"
        }

    } # end END block

} # end function Write-CustomOut
