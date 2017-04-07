# Start of Settings
# End of Settings

<#
Test Multicast Group Connectivity in a Transport Zone
Example 7-35. Test multicast group connectivity in transport zone
Request:
POST https://NSX-Manager-IP-Address/api/2.0/vdn/scopes/scopeId/conn-check/multicast
Request Body:
<testParameters>
<gateway>172.23.233.1</gateway>
<packetSizeMode>0</packetSizeMode> <!-- mode : 0 => vxlan standard packet size, 1 =>
minimum packet size, 2 => customized packet size. --!>
<packetSize>1600</packetSize> <!-- applicable only if customized packet size is
selected. --!>
<sourceHost>
<hostId>host-9</hostId>
<switchId>dvs-22</switchId>
<vlanId>54</vlanId>
</sourceHost>
<destinationHost>
<hostId>host-92</hostId>
<switchId>dvs-22</switchId>
<vlanId>54</vlanId>
</destinationHost>
</testParameters>



Performing Ping Test
You can perform a point to point connectivity test between two hosts across which a logical switch spans.
Example 7-37. Perform point to point test
Request:
POST https://NSX-Manager-IP-Address/api/2.0/vdn/virtualwires/virtualWireId/conn-check/p2p
Request Body:
<testParameters>
<gateway>172.23.233.1</gateway>
<packetSizeMode>0</packetSizeMode> <!-- mode : 0 => vxlan standard packet size, 1 =>
minimum packet size, 2 => customized packet size. --!>
<packetSize>1600</packetSize> <!-- applicable only if customized packet size is
selected. --!>
<sourceHost>
<hostId>host-9</hostId>
<switchId>dvs-22</switchId>
<vlanId>54</vlanId>
</sourceHost>
<destinationHost>
<hostId>host-92</hostId>
<switchId>dvs-22</switchId>
<vlanId>54</vlanId>
</destinationHost>
</testParameters>
#>

# EVERYTHING BELOW HERE NEEDS WORK
# ---------------------------------

# Get Hosts and Host Names
$nsxHosts =

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
    # Grab the Host's Channel Health Status
    $nsxHostHealth = (Invoke-NsxRestMethod -method Get -URI "/api/2.0/vdn/inventory/host/$($nsxHost)/connection/status").hostConnStatus

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
$NsxChannelHealthTable | Select-Object Name,"Manager to Firewall Agent","Manager to Control Plane","Control Plane to Controller"


# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Connectivity Tests"
$Header = "NSX COnnectivity Tests"
$Comments = "NSX Host(s) are reporting connectivity issues"
$Display = "Table"
$Author = "Dave Hocking"
$PluginVersion = 0.1


