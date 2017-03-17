
Function Set-PluginSettings {

 <#
.SYNOPSIS
   Applies settings to vCheck plugins.

.DESCRIPTION
   Set-PluginSettings will apply settings supplied to a given vCheck plugin.
   Used by Export-vCheckSettings.

.PARAMETER filename
   Full path to plugin file

.PARAMETER settings
   Array of settings to apply to plugin

.PARAMETER GB
   Switch to disable Setup Wizard when processing GlobalVariables.ps1
 #>

	Param
    (
        [Parameter(mandatory=$true)] [String]$filename,
		[Parameter(mandatory=$false)] [Array]$settings,
		[Parameter(mandatory=$false)] [Switch]$GB
    )
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -SimpleMatch "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -SimpleMatch "# End of Settings").LineNumber
	$PluginName = ($filename.split("\")[-1]).split(".")[0]
	Write-Warning "`nProcessing - $PluginName"
	if (!(($OriginalLine +1) -eq $EndLine)) {
		$Array = @()
		$Line = $OriginalLine
		do {
			$Question = $file[$Line].Trim()
			$Found = $false
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0].Trim()
			$CurSet = $Split[1].Trim()
			Foreach ($setting in $settings) {
				If ($question -eq $setting.question.Trim()) {
					$NewSet = $setting.var
					$Found = $true
				}
			}
			If (!$Found) {
				# Check if the current setting is in speech marks
				$String = $false
				if ($CurSet -match '"') {
					$String = $true
					$CurSet = $CurSet.Replace('"', '').Trim()
				}
				$NewSet = Read-Host "$Question [$CurSet]"
				If (-not $NewSet) {
					$NewSet = $CurSet
				}
				If ($String) {
					$NewSet = "`"$NewSet`""
				}
			}
            if ($NewSet -ne $CurSet) {
                Write-Warning "Plugin setting changed:"
                Write-Warning "    Plugin:    $PluginName"
                Write-Warning "    Question:  $Question"
                Write-Warning "    Variable:  $Var"
                Write-Warning "    Old Value: $CurSet"
                Write-Warning "    New Value: $NewSet"
            }
			$Array += $Question
			$Array += "$Var = $NewSet"
			$Line ++
		} Until ( $Line -ge ($EndLine -1) )
		$Array += "# End of Settings"

		$out = @()
		$out = $File[0..($OriginalLine -1)]
		$out += $Array
		$out += $File[$Endline..($file.count -1)]
		If ($GB) {
			$Setup = ($file | Select-String -SimpleMatch '# Set the following to true to enable the setup wizard for first time run').LineNumber
			$SetupLine = $Setup ++
			$out[$SetupLine] = '$SetupWizard = $False'
		}
		$out | Out-File -Encoding ASCII $filename
	}
}