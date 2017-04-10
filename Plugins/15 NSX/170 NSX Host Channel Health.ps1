# Start of Settings
# Specify regex to filter OUT any clusters connected to the vCenter - otherwise all clusters assumed to be NSX enabled
$exclude = ""
# End of Settings

# Get clusters from vcenter
$clusters = get-cluster | Where-Object {$_.name -notmatch $exclude}

# Get Hosts and Host Names
$nsxHosts = $clusters | Get-VMHost

# Store in array and then trim the names
$nsxHosts = $nsxHosts.id.trimstart("HostSystem-")

# Build the table that will hold the channel health data
$NsxChannelHealthTable = New-Object system.Data.DataTable "NSX Host Channel Health"

# Define Columns
$cols = @()
$cols += New-Object system.Data.DataColumn Host,([string])
$cols += New-Object system.Data.DataColumn "Manager to Firewall Agent",([string])
$cols += New-Object system.Data.DataColumn "Manager to Control Plane",([string])
$cols += New-Object system.Data.DataColumn "Control Plane to Controller",([string])


#Add the Columns
foreach ($col in $cols) {$NsxChannelHealthTable.columns.add($col)}

# Enumerate through each Host and populate the table
foreach ($nsxHost in $nsxHosts)
{
    # Grab the Host's Channel Health Status, use SilentlyContinue to hide any 500 errors caused by polling for All ESXi Hosts, not just those in NSX Clusters
    $nsxHostHealth = (Invoke-NsxRestMethod -erroraction SilentlyContinue -method Get -URI "/api/2.0/vdn/inventory/host/$($nsxHost)/connection/status").hostConnStatus

    # Populate a row in the Table
    $row = $NsxChannelHealthTable.NewRow()

    # Enter data in the row
    $row.Host = $nsxHostHealth.hostName
    $row."Manager to Firewall Agent" = $nsxHostHealth.nsxMgrToFirewallAgentConn
    $row."Manager to Control Plane" = $nsxHostHealth.nsxMgrToControlPlaneAgentConn
    $row."Control Plane to Controller" = $nsxHostHealth.hostToControllerConn

    # Add the row to the table
    $NsxChannelHealthTable.Rows.Add($row)
}

# Display the Status Table
$NsxChannelHealthTable | Select-Object Host,"Manager to Firewall Agent","Manager to Control Plane","Control Plane to Controller" | where {$_."Manager to Firewall Agent" -ne "UP" -or $_."Manager to Control Plane" -ne "UP" -or $_."Control Plane to Controller" -ne "UP"}

# Plugin Outputs
if ($exclude){$exclusionNote = " - Excludes hosts in cluster(s) matching the Regex `'$($exclude)`'"} else {$exclusionNote = ""}
$PluginCategory = "NSX"
$Title = "NSX Host Channel Health"
$Header = "NSX Host Channel Health"
$Comments = "NSX Host(s) are reporting communication channel issues $($exclusionNote)"
$Display = "Table"
$Author = "David Hocking"
$PluginVersion = 0.4