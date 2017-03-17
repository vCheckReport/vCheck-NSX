
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