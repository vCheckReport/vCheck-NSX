# Start of Settings
# Specify regex to filter OUT any clusters connected to the vCenter - otherwise all clusters assumed to be NSX enabled
$exclude = ""
# End of Settings 

# Get clusters from vcenter
$clusters = get-cluster | Where-Object {$_.name -notmatch $exclude}

# Build the table that will hold the health data
$NsxClusterHealthTable = New-Object system.Data.DataTable "NSX Cluster Preparation State"

# Define Columns
$cols = @()
$cols += New-Object system.Data.DataColumn "Cluster Name",([string])
$cols += New-Object system.Data.DataColumn "Feature",([string])
$cols += New-Object system.Data.DataColumn "Host Preparation State",([string])
$cols += New-Object system.Data.DataColumn "Installed",([string])
$cols += New-Object system.Data.DataColumn "Enabled",([string])

#Add the Columns
foreach ($col in $cols) {$NsxClusterHealthTable.columns.add($col)}

foreach ($cluster in $clusters)
{
    # get nsx cluster status from cluster
    $nsxcluster = $cluster | Get-NsxClusterStatus

    foreach ($nsxFeature in $nsxcluster)
    {
        # Populate a row in the Table
        $row = $NsxClusterHealthTable.NewRow()

        # Enter data in the row
        $row."Cluster Name" = $cluster.name
        $row.Feature  = ($nsxFeature.featureId).split('.')[-1]
        $row."Host Preparation State" = if($nsxFeature.status -match 'RED|UNKNOWN' ){"Not Ready"}
        $row.Installed = $nsxFeature.installed
        $row.Enabled = $nsxFeature.enabled
                
        # Add the row to the table
        $NsxClusterHealthTable.Rows.Add($row)
    }
}
# Display the Status Table if there's an issues
$NsxClusterHealthTable | Select-Object "Cluster Name",Feature,"Host Preparation State","Installed","Enabled" | where {$_."Host Preparation State" -eq "Not Ready" -or $_."Installed" -eq "false" -or $_."Enabled" -eq "false"}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Cluster Preparation State"
$Header = "NSX Cluster Preparation State"
$Comments = "NSX cluster(s) are reporting preparation health issues"
$Display = "Table"
$Author = "David Hocking / Adam Baron"
$PluginVersion = 0.2