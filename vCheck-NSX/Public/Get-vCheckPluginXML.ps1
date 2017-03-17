
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