<# Takes Array of HTML colour codes and returns Color object #>

function Get-ChartColours {
    param (
        [string[]]$ChartColours
    )

    foreach ($colour in $ChartColours) {
        [System.Drawing.Color]::FromArgb([Convert]::ToInt32($colour.Substring(0, 2), 16),
        [Convert]::ToInt32($colour.Substring(2, 2), 16),
        [Convert]::ToInt32($colour.Substring(4, 2), 16));
    }
}