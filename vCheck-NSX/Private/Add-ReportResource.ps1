function Add-ReportResource {

    <#
        .SYNOPSIS
            Adds a resource to the resource array, to be included in report. At the moment, only "File" types are supported- this will be expanded to include SystemIcons and raw byte data (so images can be packaged completely in styles if desired
        .DESCRIPTION
            Adds a resource to the resource array, to be included in report. At the moment, only "File" types are supported- this will be expanded to include SystemIcons and raw byte data (so images can be packaged completely in styles if desired
    #>

    param (
        $cid,
        $ResourceData,
        [ValidateSet("File", "SystemIcons", "Base64")]
        $Type = "File",
        $Used = $false
    )

    # If cid does not exist, add it
    if ($global:ReportResources.Keys -notcontains $cid) {
        $global:ReportResources.Add($cid, @{
            "Data" = ("{0}|{1}" -f $Type, $ResourceData);
            "Uses" = 0
        })
    }

    # Update uses count if $Used set (Should normally be incremented with Set-ReportResource)
    # Useful for things like headers where they are always required.
    if ($Used) {
        ($global:ReportResources[$cid].Uses)++
    }

} # end function Add-ReportResource