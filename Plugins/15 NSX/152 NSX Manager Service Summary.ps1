# Start of Settings
# Desired NSX Manager Universal Sync Service Status
$DesiredNSXReplicatorService = "RUNNING"
# Desired SSH Service Status
$DesiredSshService = "STOPPED"
# End of Settings

# Desired NSX Manager Service Status
$DesiredNSXManagerService = "RUNNING"
# Desired RabbitMQ Service Status
$DesiredRabbitMQService = "RUNNING"
# Desired vPostGres Service Status
$DesiredvPostgresService = "RUNNING"


# Vars to hold service names
$nsxReplictorStr = "NSX Replicator"
$nsxManagerStr = "NSX Manager"
$nsxRabbitMqStr = "RabbitMQ"
$nsxvPostGresStr = "vPostGres"
$nsxSshServiceStr = "SSH Service"

# Gather info from NSX manager
$nsxmgrSummary = Get-NsxManagerComponentSummary

# NSX Manager Service Running Status
$NSXReplicatorService = ($nsxmgrSummary.componentsByGroup.entry.GetEnumerator().components.component | Where-Object {$_.name -eq $nsxReplictorStr}).status
$NSXManagerService = ($nsxmgrSummary.componentsByGroup.entry.GetEnumerator().components.component | Where-Object {$_.name -eq $nsxManagerStr}).status
$RabbitMQService = ($nsxmgrSummary.componentsByGroup.entry.GetEnumerator().components.component | Where-Object {$_.name -eq $nsxRabbitMqStr}).status
$vPostgresService = ($nsxmgrSummary.componentsByGroup.entry.GetEnumerator().components.component | Where-Object {$_.name -eq $nsxvPostGresStr}).status
$SshService = ($nsxmgrSummary.componentsByGroup.entry.GetEnumerator().components.component | Where-Object {$_.name -eq $nsxSshServiceStr}).status

# Check if NSX Manager service status matches desired value, then report
if ($DesiredNSXReplicatorService -ne $NSXReplicatorService -or $DesiredNSXManagerService -ne $NSXManagerService -or $DesiredRabbitMQService -ne $RabbitMQService -or $DesiredvPostgresService -ne $vPostgresService -or $DesiredSshService -ne $SshService)
{
    # Build new table
    $NsxManagerServicesTable = New-Object system.Data.DataTable "NSX Manager Services"

    # Define Columns
    $cols = @()
    $cols += New-Object system.Data.DataColumn "Service Name",([string])
    $cols += New-Object system.Data.DataColumn "Desired State",([string])
    $cols += New-Object system.Data.DataColumn "Actual State",([string])

    #Add the Columns
    foreach ($col in $cols) {$NsxManagerServicesTable.columns.add($col)}

    # Enumerate through each service and populate the table
    #------------------------------------------

    # Populate a row in the Table
    $row = $NsxManagerServicesTable.NewRow()

    # Enter data in the row
    $row."Service Name" = $nsxReplictorStr
    $row."Desired State" = $DesiredNSXReplicatorService
    $row."Actual State" = $NSXReplicatorService

    # Add the row to the table
    $NsxManagerServicesTable.Rows.Add($row)

    #------------------------------------------

    # Populate a row in the Table
    $row = $NsxManagerServicesTable.NewRow()

    # Enter data in the row
    $row."Service Name" = $nsxManagerStr
    $row."Desired State" = $DesiredNSXManagerService
    $row."Actual State" = $NSXManagerService

    # Add the row to the table
    $NsxManagerServicesTable.Rows.Add($row)

    #------------------------------------------

    # Populate a row in the Table
    $row = $NsxManagerServicesTable.NewRow()

    # Enter data in the row
    $row."Service Name" = $nsxRabbitMqStr
    $row."Desired State" = $DesiredRabbitMQService
    $row."Actual State" = $RabbitMQService

    # Add the row to the table
    $NsxManagerServicesTable.Rows.Add($row)

    #------------------------------------------

    # Populate a row in the Table
    $row = $NsxManagerServicesTable.NewRow()

    # Enter data in the row
    $row."Service Name" = $nsxvPostGresStr
    $row."Desired State" = $DesiredvPostgresService
    $row."Actual State" = $vPostgresService

    # Add the row to the table
    $NsxManagerServicesTable.Rows.Add($row)

    #------------------------------------------

    # Populate a row in the Table
    $row = $NsxManagerServicesTable.NewRow()

    # Enter data in the row
    $row."Service Name" = $nsxSshServiceStr
    $row."Desired State" = $DesiredSshService
    $row."Actual State" = $SshService

    # Add the row to the table
    $NsxManagerServicesTable.Rows.Add($row)

    #------------------------------------------

    # Display the services table
    $NsxManagerServicesTable | Select-Object "Service Name","Desired State","Actual State"
}


# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Manager Service Status"
$Header = "NSX Manager Service Status"
$Comments = "One or more of the following NSX Services aren't in an optimal state"
$Display = "Table"
$Author = "David Hocking"
$PluginVersion = 0.2