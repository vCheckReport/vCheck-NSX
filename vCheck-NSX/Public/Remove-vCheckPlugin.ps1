
function Remove-vCheckPlugin {

<#
.SYNOPSIS
   Removes a vCheck plugin.

.DESCRIPTION
   Remove-vCheckPlugin Uninstalls a vCheck Plugin.

   Basically, just looks for the plugin name and deletes the file. Sure, you could just delete the ps1 file from the plugins folder, but what fun is that?

.PARAMETER name
   Name of the plugin.

.EXAMPLE
   Remove via pipeline
   Get-vCheckPlugin "Plugin name" | Remove-vCheckPlugin

.EXAMPLE
   Remove Plugin by name
   Remove-vCheckPlugin "Plugin name"
#>

    [CmdletBinding(DefaultParametersetName="name",SupportsShouldProcess=$true,ConfirmImpact="High")]
    Param
    (
        [Parameter(parameterSetName="name",Position=0,mandatory=$true)] [String]$name,
        [Parameter(parameterSetName="object",Position=0,mandatory=$true,ValueFromPipeline=$true)] [PSObject]$pluginobject
    )
    Process
    {
        if($name)
        {
            Get-vCheckPlugin $name | Remove-vCheckPlugin
        }
        elseif ($pluginObject)
        {
           Remove-Item -path $pluginObject.location -confirm:$false
        }
    }
}