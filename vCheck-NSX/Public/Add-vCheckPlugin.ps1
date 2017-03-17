
function Add-vCheckPlugin {

<#
.SYNOPSIS
   Installs a vCheck plugin from the Virtu-Al.net repository.

.DESCRIPTION
   Add-vCheckPlugin downloads and installs a vCheck Plugin (currently by name) from the Virtu-Al.net repository.

   The downloaded file is saved in your vCheck plugins folder, which automatically adds it to your vCheck report. vCheck plugins may require
   configuration prior to use, so be sure to open the ps1 file of the plugin prior to running your next report.

.PARAMETER name
   Name of the plugin.

.EXAMPLE
   Install via pipeline from Get-vCheckPlugins
   Get-vCheckPlugin "Plugin name" | Add-vCheckPlugin

.EXAMPLE
   Install Plugin by name
   Add-vCheckPlugin "Plugin name"
#>

    [CmdletBinding(DefaultParametersetName="name")]
    Param
    (
        [Parameter(parameterSetName="name",Position=0,mandatory=$true)] [String]$name,
        [Parameter(parameterSetName="object",Position=0,mandatory=$true,ValueFromPipeline=$true)] [PSObject]$pluginobject
    )
    Process
    {
        if($name)
        {
            Get-vCheckPlugin $name | Add-vCheckPlugin
        }
        elseif ($pluginObject)
        {
            Add-Type -AssemblyName System.Web
            $filename = $pluginObject.location.split("/")[-2,-1] -join "/"
            $filename = [System.Web.HttpUtility]::UrlDecode($filename)
            try
            {
                Write-Warning "Downloading File..."
                $webClient = new-object system.net.webclient
                $webClient.DownloadFile($pluginObject.location,"$vCheckPath\Plugins\$filename")
                Write-Warning "The plugin `"$($pluginObject.name)`" has been installed to $vCheckPath\Plugins\$filename"
                Write-Warning "Be sure to check the plugin for additional configuration options."

            }
            catch [System.Net.WebException]
            {
                write-error $_.Exception.ToString()
                return
            }
        }
    }

} # end function Add-vCheckPlugin