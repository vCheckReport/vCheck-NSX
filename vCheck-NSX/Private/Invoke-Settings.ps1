Function Invoke-Settings {

    <#
    .DESCRIPTION
        Run through settings for specified file, expects question on one line, and variable/value on following line
    .NOTES
        Updated: 20150428
        Updated By: Kevin Kirkpatrick (@vScripter - Twitter/GitHub)
        Update Notes:
        - Remove Write-Host in favor of Write-Warning; this was based on setting the color of Write-Host to 'warning' colors
        - converted function to advanced function
        - moved parameters out of function declaration and into the param declaration
        - moved all code into the PROCESS block
        - improved code spacing for improved readability
        - added comment based help section for notes/comments
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

            $Array = @()
            $Line = $OriginalLine
            $PluginName = (Get-PluginID $Filename).Title

            If ($PluginName.EndsWith(".ps1", 1)) {

                $PluginName = ($PluginName.split("\")[-1]).split(".")[0]

            } # end if

            Write-Warning -Message "`n$PluginName"

            do {

                $Question = $file[$Line]
                $Line++
                $Split = ($file[$Line]).Split("=")
                $Var = $Split[0]
                $CurSet = $Split[1].Trim()

                # Check if the current setting is in speech marks
                $String = $false
                if ($CurSet -match '"') {
                    $String = $true
                    $CurSet = $CurSet.Replace('"', '').Trim()
                } # end if

                $NewSet = Read-Host "$Question [$CurSet]"

                If (-not $NewSet) {
                    $NewSet = $CurSet
                } # end if

                If ($String) {
                    $Array += $Question
                    $Array += "$Var= `"$NewSet`""
                } Else {
                    $Array += $Question
                    $Array += "$Var= $NewSet"
                } # end if/else

                $Line++

            } Until ($Line -ge ($EndLine - 1))

            $Array += "# End of Settings"

            $out = @()
            $out = $File[0..($OriginalLine - 1)]
            $out += $array
            $out += $File[$Endline..($file.count - 1)]

            if ($GB) {
                $out[$SetupLine] = '$SetupWizard = $False'
            }  # end if

            $out | Out-File $Filename

        } # end if

    } # end PROCESS block

} # end Function Invoke-Settings