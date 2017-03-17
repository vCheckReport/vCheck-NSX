Function Invoke-HTMLSettings {

	<#
	.DESCRIPTION
		Run through settings for specified file, expects question on one line, and variable/value on following line.
		Outputs settings to HTML file, which accepts input, and can create a configuration file.
	.NOTES
		Updated: 20160830
		Updated By: David Seibel
		Update Notes:
		- Initial creation
	#>

	[CmdletBinding(PositionalBinding = $true)]
	param (
		[parameter(Position = 0)]
		$Filename,
		[parameter(Position = 1)]
		$GB
	)

	PROCESS {

		$file = Get-Content $filename
		$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
		$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber

		if (!(($OriginalLine + 1) -eq $EndLine)) {

			$Line = $OriginalLine
			$PluginInfo = Get-PluginID $Filename
			$PluginName = $PluginInfo.Title

			$htmlOutput = ""
			If ($PluginName.EndsWith(".ps1", 1)) {
				$PluginName = ($PluginName.split("\")[-1]).split(".")[0]
			} # end if

			$htmlOutput += "<table>"

			do {
				$Question = $file[$Line]
				$QuestionWithoutHash = $Question.Replace("# ", "")
				$Line++
				$Split = ($file[$Line]).Split("=")
				$Var = $Split[0].Trim()
				if ($Split.count -gt 1) {
					$CurSet = $Split[1].Trim()
					# Check if the current setting is in speech marks
					$String = $false
					if ($CurSet -match '"') {
						$String = $true
						$CurSet = $CurSet.Replace('"', '').Trim()
					} # end if

					$htmlOutput += "<tr><td>$QuestionWithoutHash</td><td><input name='$Filename|$Question|$Var' type='text' value='$CurSet' size=60 /></td></tr>`n"
				}
			} Until ($Line -ge ($EndLine - 1))

			$htmlOutput += "</table>"
			$PluginConfig += New-Object PSObject -Property @{
				"Details" = $htmlOutput;
				"Header" = $PluginName;
				"PluginID" = $PluginName;
			}

			return $PluginConfig
		} # end if

	} # end PROCESS block

} # end Function Invoke-HTMLSettings