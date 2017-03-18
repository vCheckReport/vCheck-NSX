<# Takes an array of content, and returns HTML table with header column #>

Function Get-HTMLList {
    param ([array]$content)

    if ($content.count -gt 0) {
        # Create XML doc from HTML. Remove colgroup and header row
        if ($content.count -gt 1) {
            [xml]$XMLTable = $content | ConvertTo-HTML -Fragment
            $XMLTable.table.RemoveChild($XMLTable.table.colgroup) | out-null
            $XMLTable.table.RemoveChild($XMLTable.table.tr[0]) | out-null
            $XMLTable.table.SetAttribute("width", "100%")
        } else {
            [xml]$XMLTable = $content | ConvertTo-HTML -Fragment -As List
        }

        # Replace the first column td with th
        for ($i = 0; $i -lt $XMLTable.table.tr.count; $i++) {
            $node = $XMLTable.table.tr[$i].SelectSingleNode("/table/tr[$($i + 1)]/td[1]")
            $elem = $XMLTable.CreateElement("th")
            $elem.InnerText = $node."#text"
            $trNode = $XMLTable.SelectSingleNode("/table/tr[$($i + 1)]")
            $trNode.ReplaceChild($elem, $node) | Out-Null
        }

        # If only one column, fix up the table header
        if (($content | Get-Member -MemberType Properties).count -eq 1)
        {
            $XMLTable.table.tr[0].th = (($content | Get-Member -MemberType Properties) | Select-Object -ExpandProperty Name -First 1).ToString()
        }

        return (Format-HTMLEntities ([string]($XMLTable.OuterXml)))
    }
}