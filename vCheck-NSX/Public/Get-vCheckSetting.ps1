function Get-vCheckSeting {

    <#
    .SYNOPSIS
        Placeholder for now, just return the setting passed to it. Eventually this will be used for new settings handling
    .DESCRIPTION
        Placeholder for now, just return the setting passed to it. Eventually this will be used for new settings handling
    .PARAMETER Module

    .PARAMETER Setting

    .INPUTS

    .OUTPUTS

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
        [System.String]
        $Module,

        [parameter(
            Position = 1,
            Mandatory = $false,
            ParameterSetName = 'default')]
        [System.String]
        $Setting
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        $default

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-vCheckSeting