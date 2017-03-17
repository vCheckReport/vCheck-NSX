
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