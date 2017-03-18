
Function Get-PluginSettings {

<#
.SYNOPSIS
   Returns settings from vCheck plugins.

.DESCRIPTION
   Get-PluginSettings will return an array of settings contained
   within a supplied plugin. Used by Export-vCheckSettings.

.PARAMETER filename
   Full path to plugin file
 #>

    Param
    (
        [Parameter(mandatory=$true)] [String]$filename
    )
    $psettings = @()
    $file = Get-Content $filename
    $OriginalLine = ($file | Select-String -SimpleMatch "# Start of Settings").LineNumber
    $EndLine = ($file | Select-String -SimpleMatch "# End of Settings").LineNumber
    if (!(($OriginalLine +1) -eq $EndLine)) {
        $Line = $OriginalLine
        do {
            $Question = $file[$Line]
            $Line++
            $Split = ($file[$Line]).Split("=")
            $Var = $Split[0]
            $CurSet = $Split[1]
            $settings = @{}
            $settings.filename = $filename
            $settings.question = $Question
            $settings.varname = $Var.Trim()
            $settings.var = $CurSet.Trim()
            $currentsetting = New-Object -TypeName PSObject -Prop $settings
            $psettings += $currentsetting
            $Line++
        } Until ( $Line -ge ($EndLine -1) )
    }
    $psettings
}