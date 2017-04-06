# Start of Settings
# End of Settings 

# Get clusters from vcenter - bit dirty as it will collect all clusters, not just nsx prepared ones
$clusters = get-cluster 

# get nsx cluster status from clusters
$nsxclusters = $clusters | Get-NsxClusterStatus

# Build the table that will hold the health data
$NsxClusterHealthTable = New-Object system.Data.DataTable "NSX Cluster Preparation State"

# Define Columns
$cols = @()
$cols += New-Object system.Data.DataColumn "Feature",([string])
$cols += New-Object system.Data.DataColumn "Host Preparation State",([string])
$cols += New-Object system.Data.DataColumn "Installed",([string])
$cols += New-Object system.Data.DataColumn "Enabled",([string])

    
#Add the Columns
foreach ($col in $cols) {$NsxClusterHealthTable.columns.add($col)}

foreach ($nsxFeature in $nsxclusters)
{
    # Populate a row in the Table
    $row = $NsxClusterHealthTable.NewRow()

    # Enter data in the row
    $row.Feature  = ($nsxFeature.featureId).split('.')[-1]
    $row."Host Preparation State" = if($nsxFeature.status -match 'RED|UNKNOWN' ){"Not Ready"}
    $row.Installed = $nsxFeature.installed
    $row.Enabled = $nsxFeature.enabled
                
    # Add the row to the table
    $NsxClusterHealthTable.Rows.Add($row)
}

# Display the Status Table if there's an issues
$NsxClusterHealthTable | Select-Object Feature,"Host Preparation State","Installed","Enabled" | where {$_."Host Preparation State" -eq "Not Ready" -or $_."Installed" -eq "false" -or $_."Enabled" -eq "false"}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Cluster Preparation State"
$Header = "NSX Cluster Preparation State"
$Comments = "NSX cluster(s) are reporting preparation health issues"
$Display = "Table"
$Author = "Dave Hocking / Adam Baron"
$PluginVersion = 0.1


