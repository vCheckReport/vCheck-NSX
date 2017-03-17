

Function Get-vCheckVariablesSettings {

<#
    .SYNOPSIS
        Lists the variables in vCheck plugin files.

    .DESCRIPTION
        Plugin file will be scanned as a text file and any variables in between the "Start of Settings"
		and "End of Settings" section markers will be sent out the pipeline.  Files can be sent in
		via the pipeline or individually with a loop.  If using the "-Verbose" option for troubleshooting
		then using a loop is recommended.

    .PARAMETER  PluginFile
        The file to be processed.  Can be passed as text, a file object, or a set of files, such as
		"Get-ChildItem *.ps1".

    .EXAMPLE
        Simple
		Get-vCheckVariablesSettings -PluginFile "c:\scripts\vcheck6\vcenter\Plugins\20 Cluster\75 DRS Rules.ps1"

		Recursed
		Get-ChildItem -Path E:\vCheckLatestTesting -File -Filter *.ps1 -Recurse | % { Get-vCheckVariablesSettings -PluginFile $_.FullName }

    .INPUTS
        System.IO.FileInfo

    .OUTPUTS
        File		Selected.System.Management.Automation.PSCustomObject	The 'Fullname' property from the plugin file.
		Variable	Selected.System.Management.Automation.PSCustomObject	The text of the variable assignment from the plugin file.

    .NOTES
        With multiple vCheck directories to upgrade I needed an easy to pull the variables used
		in the old vCheck installation to go into the new version.

        Recent Comment History
20150127	cmonahan	Initial release.

    .LINK
        https://github.com/alanrenouf/vCheck-vSphere



#>

[CmdletBinding()]
param (
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)] $PluginFile
)

#begin {
	Write-Verbose "Started $PluginFile"

	if (Test-Path $PluginFile) {
		$PluginFile = Get-ChildItem $PluginFile
		$contents = Get-Content $PluginFile
		$end = $contents.length }
	else { throw "Value passed to File parameter is not a file."  }

	$i=0

#} # end begin block

#process {

	while ( ($i -lt $end) -and ($contents[$i] -notmatch "Start of Settings") ) { $i++ }

	while ( ($i -lt $end) -and ($contents[$i] -notmatch "End of Settings")   ) {
		if ($contents[$i] -match "`=") { "" | Select-Object @{n='File';e={$PluginFile.fullname}},@{n='Variable';e={$contents[$i]}}; $i++ }
		else { $i++ }
	}

#} #end process block

#end {
	Write-Verbose "Ended $PluginFile"
#} #end end block

<#
Recent Comment History
20150127	cmonahan	Initial release.
#>

} # end function