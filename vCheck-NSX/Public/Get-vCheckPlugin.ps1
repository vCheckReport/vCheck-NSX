
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