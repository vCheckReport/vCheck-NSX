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


Function Export-vCheckSettings {

 <#
.SYNOPSIS
   Retrieves configured vCheck plugin settings and exports them to CSV.

.DESCRIPTION
   Export-vCheckSettings will retrieve the settings from each plugin and export them to a CSV file.
   By default, the CSV file will be created in the vCheck folder named vCheckSettings.csv.
   You can also specify a custom path using -outfile.
   Once the export has been created the settings can then be imported via Import-vCheckSettings.

.PARAMETER outfile
   Full path to CSV file

.EXAMPLE
   Export-vCheckSettings
   Creates vCheckSettings.csv file in default location (vCheck folder)

.EXAMPLE
   Export-vCheckSettings -outfile "E:\vCheck-vCenter01.csv"
   Creates CSV file in custom location E:\vCheck-vCenter01.csv
 #>

    Param
    (
        [Parameter(mandatory=$false)] [String]$outfile = "$vCheckPath\vCheckSettings.csv"
    )

    $Export = @()
    $GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
    $Export = Get-PluginSettings -Filename $GlobalVariables
    Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) {
        $Export += Get-PluginSettings -Filename $plugin.Fullname
    }
    $Export | Select-Object filename, question, var | Export-Csv -NoTypeInformation $outfile
}


Function Export-vCheckSettingsXML {

<#
.SYNOPSIS
   Retrieves configured vCheck plugin settings and exports them to XML.

.DESCRIPTION
   Export-vCheckSettings will retrieve the settings from each plugin and export them to a XML file.
   By default, the XML file will be created in the vCheck folder named vCheckSettings.xml.
   You can also specify a custom path using -outfile.
   Once the export has been created the settings can then be imported via Import-vCheckSettingsXML.

.PARAMETER outfile
   Full path to XML file

.EXAMPLE
   Export-vCheckSettings
   Creates vCheckSettings.xml file in default location (vCheck folder)

.EXAMPLE
   Export-vCheckSettingsXML -outfile "E:\vCheck-vCenter01.xml"
   Creates XML file in custom location E:\vCheck-vCenter01.xml
 #>


    Param
    (
        [Parameter(mandatory=$false)] [String]$outfile = "$vCheckPath\vCheckSettings.xml"
    )

    $Export = @()
    $GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
    $Export = Get-PluginSettings -Filename $GlobalVariables
    Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1 -Recurse)) {
        $Export += Get-PluginSettings -Filename $plugin.Fullname
    }

    $xml = "<vCheck>`n"
    foreach ($e in $Export) {
        $xml += "`t<setting>`n"
        $xml += "`t`t<filename>$($e.Filename)</filename>`n"
        $xml += "`t`t<question>$($e.Question)</question>`n"
        $xml += "`t`t<varname>$($e.VarName)</varname>`n"
        $xml += "`t`t<var>$($e.Var)</var>`n"
        $xml += "`t</setting>`n"
    }
    $xml += "</vCheck>"
    $xml | Out-File -FilePath $outfile -Encoding utf8
}


Function Get-vCheckCommand {

$moduleName = Split-Path $PSScriptRoot -Parent

    Get-Command -Module $moduleName

}


function Get-vCheckPlugin {

    <#
.SYNOPSIS
   Retrieves installed vCheck plugins and available plugins from the Virtu-Al.net repository.

.DESCRIPTION
   Get-vCheckPlugin parses your vCheck plugins folder, as well as searches the online plugin respository in Virtu-Al.net.
   After finding the plugin you are looking for, you can download and install it with Add-vCheckPlugin. Get-vCheckPlugins
   also supports finding a plugin by name. Future version will support categories (e.g. Datastore, Security, vCloud)

.PARAMETER name
   Name of the plugin.

.PARAMETER proxy
   URL for proxy usage.

.PARAMETER proxy_user
   username for proxy auth.

.PARAMETER proxy_password
   password for proxy auth.

.PARAMETER proxy_domain
   domain for proxy auth.

.EXAMPLE
   Get list of all vCheck Plugins
   Get-vCheckPlugin

.EXAMPLE
   Get plugin by name
   Get-vCheckPlugin PluginName

.EXAMPLE
   Get plugin by name using proxy
   Get-vCheckPlugin PluginName -proxy "http://127.0.0.1:3128"

.EXAMPLE
   Get plugin by name using proxy with auth (domain optional depending on your proxy auth)
   Get-vCheckPlugin PluginName -proxy "http://127.0.0.1:3128" -proxy_user "username" -proxy_pass "password -proxy_domain "domain"

.EXAMPLE
   Get plugin information
   Get-vCheckPlugins PluginName
 #>

    [CmdletBinding()]
    Param
    (
        [Parameter(mandatory = $false)] [String]$Name,
        [Parameter(mandatory = $false)] [String]$Proxy,
        [Parameter(mandatory = $false)] [String]$proxy_user,
        [Parameter(mandatory = $false)] [String]$proxy_pass,
        [Parameter(mandatory = $false)] [String]$proxy_domain,
        [Parameter(mandatory = $false)] [Switch]$installed,
        [Parameter(mandatory = $false)] [Switch]$notinstalled,
        [Parameter(mandatory = $false)] [Switch]$pendingupdate,
        [Parameter(mandatory = $false)] [String]$category
    )

    Process {

        $pluginObjectList = @()

        foreach ($localPluginFile in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) {
            $localPluginContent = Get-Content $localPluginFile

            if ($localPluginContent | Select-String -SimpleMatch "title") {
                $localPluginName = ($localPluginContent | Select-String -SimpleMatch "Title").toString().split("`"")[1]
            }
            if($localPluginContent | Select-String -SimpleMatch "description") {
                $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "description").toString().split("`"")[1]
            }
            elseif ($localPluginContent | Select-String -SimpleMatch "comments") {
                $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "comments").toString().split("`"")[1]
            }
            if ($localPluginContent | Select-String -SimpleMatch "author") {
                $localPluginAuthor = ($localPluginContent | Select-String -SimpleMatch "author").toString().split("`"")[1]
            }
            if ($localPluginContent | Select-String -SimpleMatch "PluginVersion") {
                $localPluginVersion = @($localPluginContent | Select-String -SimpleMatch "PluginVersion")[0].toString().split(" ")[-1]
            }
            if ($localPluginContent | Select-String -SimpleMatch "PluginCategory") {
                $localPluginCategory = @($localPluginContent | Select-String -SimpleMatch "PluginCategory")[0].toString().split("`"")[1]
            }

            $pluginObject = New-Object PSObject
            $pluginObject | Add-Member -MemberType NoteProperty -Name name -value $localPluginName
            $pluginObject | Add-Member -MemberType NoteProperty -Name description -value $localPluginDesc
            $pluginObject | Add-Member -MemberType NoteProperty -Name author -value $localPluginAuthor
            $pluginObject | Add-Member -MemberType NoteProperty -Name version -value $localPluginVersion
            $pluginObject | Add-Member -MemberType NoteProperty -Name category -Value $localPluginCategory
            $pluginObject | Add-Member -MemberType NoteProperty -Name status -value "Installed"
            $pluginObject | Add-Member -MemberType NoteProperty -Name location -Value $LocalpluginFile.FullName
            $pluginObjectList += $pluginObject
        }

        if (!$installed) {
            try {
                $webClient = new-object system.net.webclient
                if ($proxy) {
                    $proxyURL = new-object System.Net.WebProxy $proxy
                    if (($proxy_user) -and ($proxy_pass)) {
                        $proxyURL.UseDefaultCredentials = $false
                        $proxyURL.Credentials = New-Object Net.NetworkCredential("$proxy_user","$proxy_pass")
                    }
                    elseif (($proxy_user) -and ($proxy_pass) -and ($proxy_domain)) {
                        $proxyURL.UseDefaultCredentials = $false
                        $proxyURL.Credentials = New-Object Net.NetworkCredential("$proxy_user","$proxy_pass","$proxy_domain")
                    }
                    else {
                        $proxyURL.UseDefaultCredentials = $true
                    }
                    $webclient.proxy = $proxyURL
                }
                $response = $webClient.openread($pluginXMLURL)
                $streamReader = new-object system.io.streamreader $response
                [xml]$plugins = $streamReader.ReadToEnd()

                foreach ($plugin in $plugins.pluginlist.plugin) {
                    $pluginObjectList | Where-Object {$_.name -eq $plugin.name -and [double]$_.version -lt [double]$plugin.version}|
                    Foreach-Object {
                        $_.status = "New Version Available - " + $plugin.version
                    }
                    if (!($pluginObjectList | Where-Object {$_.name -eq $plugin.name})) {
                        $pluginObject = New-Object PSObject
                        $pluginObject | Add-Member -MemberType NoteProperty -Name name -value $plugin.name
                        $pluginObject | Add-Member -MemberType NoteProperty -Name description -value $plugin.description
                        $pluginObject | Add-Member -MemberType NoteProperty -Name author -value $plugin.author
                        $pluginObject | Add-Member -MemberType NoteProperty -Name version -value $plugin.version
                        $pluginObject | Add-Member -MemberType NoteProperty -Name category -Value $plugin.category
                        $pluginObject | Add-Member -MemberType NoteProperty -Name status -value "Not Installed"
                        $pluginObject | Add-Member -MemberType NoteProperty -name location -value $plugin.href
                        $pluginObjectList += $pluginObject
                    }
                }
            }
            catch [System.Net.WebException] {
                write-error $_.Exception.ToString()
                return
            }

        }

        if ($name){

            $pluginObjectList | Where-Object {$_.name -eq $name}

        } Else {

            if ($category){

                $pluginObjectList | Where-Object {$_.Category -eq $category}

            } Else {

                if($notinstalled){

                    $pluginObjectList | Where-Object {$_.status -eq "Not Installed"}

                } elseif($pendingupdate) {

                    $pluginObjectList | Where-Object {$_.status -like "New Version Available*"}

                } Else {

                    $pluginObjectList

                } # end if/else

            } # end if/else

        } # end if/else

    } # end process block

} # end function Get-vCheckPlugin


function Get-vCheckPluginXML {

<#
.SYNOPSIS
   Geberates plugins XML file from local plugins

.DESCRIPTION
   Designed to be run after plugin changes are commited, in order to generate
   the plugin.xml file that the plugin update check uses.

.PARAMETER outputFile
   Path to the xml file. Defaults to temp directory
#>

   param
   (
      $outputFile = "$($env:temp)\plugins.xml"
   )
   # create XML and root node
   $xml = New-Object xml
   $root = $xml.CreateElement("pluginlist")
   [void]$xml.AppendChild($root)

       foreach ($localPluginFile in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1 -Recurse))
       {
          $localPluginContent = Get-Content $localPluginFile

          if ($localPluginContent | Select-String -SimpleMatch "title")
          {
              $localPluginName = ($localPluginContent | Select-String -SimpleMatch "Title").toString().split("`"")[1]
          }
          if($localPluginContent | Select-String -SimpleMatch "description")
          {
              $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "description").toString().split("`"")[1]
          }
          elseif ($localPluginContent | Select-String -SimpleMatch "comments")
          {
              $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "comments").toString().split("`"")[1]
          }
          if ($localPluginContent | Select-String -SimpleMatch "author")
          {
              $localPluginAuthor = ($localPluginContent | Select-String -SimpleMatch "author").toString().split("`"")[1]
          }
          if ($localPluginContent | Select-String -SimpleMatch "PluginVersion")
          {
              $localPluginVersion = @($localPluginContent | Select-String -SimpleMatch "PluginVersion")[0].toString().split(" ")[-1]
          }
          if ($localPluginContent | Select-String -SimpleMatch "PluginCategory")
          {
              $localPluginCategory = @($localPluginContent | Select-String -SimpleMatch "PluginCategory")[0].toString().split("`"")[1]
          }

          $pluginXML = $xml.CreateElement("plugin")
          $elem=$xml.CreateElement("name")
          $elem.InnerText=$localPluginName
          [void]$pluginXML.AppendChild($elem)

          $elem=$xml.CreateElement("description")
          $elem.InnerText=$localPluginDesc
          [void]$pluginXML.AppendChild($elem)

          $elem=$xml.CreateElement("author")
          $elem.InnerText=$localPluginAuthor
          [void]$pluginXML.AppendChild($elem)

          $elem=$xml.CreateElement("version")
          $elem.InnerText=$localPluginVersion
          [void]$pluginXML.AppendChild($elem)

          $elem=$xml.CreateElement("category")
          $elem.InnerText=$localPluginCategory
          [void]$pluginXML.AppendChild($elem)

          $elem=$xml.CreateElement("href")
          $elem.InnerText= ($pluginURL -f $localPluginCategory, $localPluginFile.Directory.Name, $localPluginFile.Name)
          [void]$pluginXML.AppendChild($elem)

          [void]$root.AppendChild($pluginXML)
       }

   $xml.save($outputFile)
}



Function Import-vCheckSettings {

<#
.SYNOPSIS
   Retreives settings from CSV and applies them to vCheck.

.DESCRIPTION
   Import-vCheckSettings will retrieve the settings exported via Export-vCheckSettings and apply them to the
   current vCheck folder.
   By default, the CSV file is expected to be located in the vCheck folder named vCheckSettings.csv.
   You can also specify a custom path using -csvfile.
   If the CSV file is not found you will be asked to provide the path.
   The Setup Wizard will be disabled.
   You will be asked any questions not found in the export. This would occur for new settings introduced
   enabling a quick update between versions.

.PARAMETER csvfile
   Full path to CSV file

.EXAMPLE
   Import-vCheckSettings
   Imports settings from vCheckSettings.csv file in default location (vCheck folder)

.EXAMPLE
   Import-vCheckSettings -outfile "E:\vCheck-vCenter01.csv"
   Imports settings from CSV file in custom location E:\vCheck-vCenter01.csv
 #>

    Param
    (
        [Parameter(mandatory=$false)] [String]$csvfile = "$vCheckPath\vCheckSettings.csv"
    )

    If (!(Test-Path $csvfile)) {
        $csvfile = Read-Host "Enter full path to settings CSV file you want to import"
    }
    $Import = Import-Csv $csvfile
    $GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
    $settings = $Import | Where-Object {($_.filename).Split("\")[-1] -eq ($GlobalVariables).Split("\")[-1]}
    Set-PluginSettings -Filename $GlobalVariables -Settings $settings -GB
    Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) {
        $settings = $Import | Where-Object {($_.filename).Split("\")[-1] -eq ($plugin.Fullname).Split("\")[-1]}
        Set-PluginSettings -Filename $plugin.Fullname -Settings $settings
    }
    Write-Warning "`nImport Complete!`n"
}


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
