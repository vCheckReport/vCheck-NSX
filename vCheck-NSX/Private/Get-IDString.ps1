function Get-IDString {

    <#
    .SYNOPSIS
        Search $FileContent for name/value pair with IDName and return value
    .DESCRIPTION
        Search $FileContent for name/value pair with IDName and return value
    .PARAMETER Param1

    .INPUTS

    .OUTPUTS

    .EXAMPLE

    .NOTES
        Author: {Name}
        Email: {Email}
        Last Updated: 20170316
        Last Updated By: K. Kirkpatrick (GitHub.com/vScripter)
        Last Update Notes:
        - Moved function as part of conversion to module
        - Renamed variables to remove underscores
        - Kept old parameter names as aliases
    #>

    [OutputType()]
    [cmdletbinding(DefaultParameterSetName = 'defaut')]
    param (
        [parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'default')]
        [Alias('File_content')]
        $FileContent,

        [parameter(
            Position = 1,
            Mandatory = $false,
            ParameterSetName = 'default')]
        [Alias('ID_name')]
        $IDName
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        try {

            if ($FileContent | Select-String -Pattern "\$+$IDName\s*=") {

                $value = (($FileContent | Select-String -pattern "\$+${IDName}\s*=").toString().split("=")[1]).Trim(' "')
                Write-Output $value

            } # end if

        } catch {

            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-IDString
