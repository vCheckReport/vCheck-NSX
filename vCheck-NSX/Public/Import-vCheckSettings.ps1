
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