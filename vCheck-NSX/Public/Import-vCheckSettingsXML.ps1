
Function Import-vCheckSettingsXML {

 <#
.SYNOPSIS
   Retreives settings from XML and applies them to vCheck.

.DESCRIPTION
   Import-vCheckSettingsXML will retrieve the settings exported via Export-vCheckSettingsXML, or via .\vCheck.ps1 -GUIConfig
   and apply them to the current vCheck folder.
   By default, the XML file is expected to be located in the vCheck folder named vCheckSettings.csv.
   You can also specify a custom path using -xmlfile.
   If the XML file is not found you will be asked to provide the path.
   The Setup Wizard will be disabled.
   You will be asked any questions not found in the export. This would occur for new settings introduced
   enabling a quick update between versions.

.PARAMETER csvfile
   Full path to XML file

.EXAMPLE
   Import-vCheckSettingsXML
   Imports settings from vCheckSettings.xml file in default location (vCheck folder)

.EXAMPLE
   Import-vCheckSettingsXML -xmlfile "E:\vCheck-vCenter01.xml"
   Imports settings from XML file in custom location E:\vCheck-vCenter01.xml
 #>

	Param
    (
        [Parameter(mandatory=$false)] [String]$xmlFile = "$vCheckPath\vCheckSettings.xml"
    )

	If (!(Test-Path $xmlFile)) {
		$xmlFile = Read-Host "Enter full path to settings XML file you want to import"
	}
	$Import = [xml](Get-Content $xmlFile)
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$settings = $Import.vCheck.Setting | Where-Object {($_.filename).Split("\")[-1] -eq ($GlobalVariables).Split("\")[-1]}
	Set-PluginSettings -Filename $GlobalVariables -Settings $settings -GB
	Foreach ($plugin in (Get-ChildItem -Path "$vCheckPath\Plugins\" -Filter "*.ps1" -Recurse)) {
		$settings = $Import.vCheck.Setting | Where-Object {($_.filename).Split("\")[-1] -eq ($plugin.Fullname).Split("\")[-1]}
		Set-PluginSettings -Filename $plugin.Fullname -Settings $settings
	}
	Write-Warning "`nImport Complete!`n"
}