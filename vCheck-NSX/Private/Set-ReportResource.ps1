Function Set-ReportResource {
    param (
        $cid
    )

    # Increment use
    ($global:ReportResources[$cid].Uses)++
}