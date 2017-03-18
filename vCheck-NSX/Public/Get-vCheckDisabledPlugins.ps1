

function Get-vCheckDisabledPlugins {

<#
.SYNOPSIS
    Lists the disabled plugins in a target directory.

.DESCRIPTION
    Essentially a stripped down version of Sync-vCheckDisabledPlugins I threw it in case someone found it useful.

.PARAMETER  VcheckDir
    What you you think it is.

.EXAMPLE
    Get-vCheckDisabledPlugins -VcheckDir c:\scripts\vcheck6\vcenter

.LINK
    https://github.com/alanrenouf/vCheck-vSphere

.NOTES

Recent Comment History
20150128    cmonahan    Initial release.

#>

    param ( [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)] $vCheckDir )

    Get-ChildItem (Get-ChildItem "$($vCheckDir)\Plugins").PsParentPath -Recurse | Where-Object { $_ -like "*.disabled" } #| select -First 1


} # end function