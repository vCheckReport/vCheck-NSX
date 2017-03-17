function New-Function {

    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Param1

    .INPUTS

    .OUTPUTS

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    .NOTES
        Author: {Name}
        Email: {Email}
        Last Updated: {Date}
        Last Updated By: {Name}
        Last Update Notes:
            -
    #>

    [OutputType()]
    [cmdletbinding(DefaultParameterSetName = 'defaut')]
    param (
        [parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'default')]
        $Param1
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        foreach ($item in $Param1) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Working on { $Param1 }"
            try {



            } catch {

                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] . $_"

            } # end try/catch

        } # end foreach $item

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function New-Function
