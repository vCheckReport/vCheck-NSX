<# Replace HTML Entities in string. Used to stop <br /> tags from being mangled in tables #>

function Format-HTMLEntities {
    param ([string]$content)

    $replace = @{
        "&lt;" = "<";
        "&gt;" = ">";
    }

    foreach ($r in $replace.Keys.GetEnumerator()) {
        $content = $content -replace $r, $replace[$r]
    }
    return $content
}