<# Takes an array of content, and optional formatRules and generated HTML table #>

Function Get-HTMLTable {
    param ($Content, $FormatRules)

    # Use an XML object for ease of use
    $XMLTable = [xml]($content | ConvertTo-Html -Fragment)
    $XMLTable.table.SetAttribute("width", "100%")

    # If only one column, fix up the table header
    if (($content | Get-Member -MemberType Properties).count -eq 1) {
        $XMLTable.table.tr[0].th = (($content | Get-Member -MemberType Properties) | Select-Object -ExpandProperty Name -First 1).ToString()
    }

    # If format rules are specified
    if ($FormatRules) {
        # Check each cell to see if there are any format rules
        for ($RowN = 1; $RowN -lt $XMLTable.table.tr.count; $RowN++) {
            for ($ColN = 0; $ColN -lt $XMLTable.table.tr[$RowN].td.count; $ColN++) {
                if ($FormatRules.keys -contains $XMLTable.table.tr[0].th[$ColN]) {
                    # Current cell has a rule, test to see if they are valid
                    foreach ($rule in $FormatRules[$XMLTable.table.tr[0].th[$ColN]]) {
                        if ($XMLTable.table.tr[$RowN].td[$ColN]."#text") {
                            $value = $XMLTable.table.tr[$RowN].td[$ColN]."#text"
                        }
                        else {
                            $value = $XMLTable.table.tr[$RowN].td[$ColN]
                        }
                        if ($value -notmatch "^[0-9.]+$") {
                            $value = """$value"""
                        }
                        if (Invoke-Expression ("{0} {1}" -f $value, [string]$rule.Keys)) {
                            # Find what to
                            $RuleScope = ([string]$rule.Values).split(",")[0]
                            $RuleActions = ([string]$rule.Values).split(",")[1].split("|")

                            switch ($RuleScope) {
                                "Row"  {
                                    for ($TRColN = 0; $TRColN -lt $XMLTable.table.tr[$RowN].td.count; $TRColN++) {
                                        $XMLTable.table.tr[$RowN].selectSingleNode("td[$($TRColN + 1)]").SetAttribute($RuleActions[0], $RuleActions[1])
                                    }
                                }
                                "Cell" {
                                    if ($RuleActions[0] -eq "cid") {
                                        # Do Image - create new XML node for img and clear #text
                                        $XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN + 1)]")."#text" = ""
                                        $elem = $XMLTable.CreateElement("img")
                                        $elem.SetAttribute("src", ("cid:{0}" -f $RuleActions[1]))
                                        # Add img size if specified
                                        if ($RuleActions[2] -match "(\d+)x(\d+)") {
                                            $elem.SetAttribute("width", $Matches[1])
                                            $elem.SetAttribute("height", $Matches[2])
                                        }

                                        $XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN + 1)]").AppendChild($elem) | Out-Null
                                        # Increment usage counter (so we don't have .bin attachments)
                                        Set-ReportResource $RuleActions[1]
                                    } else {
                                        $XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN + 1)]").SetAttribute($RuleActions[0], $RuleActions[1])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return (Format-HTMLEntities ([string]($XMLTable.OuterXml)))
}