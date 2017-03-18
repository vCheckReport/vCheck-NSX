<# Get basic information abount a plugin #>

Function Get-PluginID ($Filename) {
    # Get the identifying information for a plugin script
    $file = Get-Content $Filename
    $Title = Get-ID-String $file "Title"
    if (!$Title) { $Title = $Filename }
    $PluginVersion = Get-ID-String $file "PluginVersion"
    $Author = Get-ID-String $file "Author"
    $Ver = "{0:N1}" -f $PluginVersion

    return @{ "Title" = $Title; "Version" = $Ver; "Author" = $Author }
}