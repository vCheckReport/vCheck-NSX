# Start of Settings
# Desired minimum uptime (Hours)
$desiredMinUptime = 48
# End of Settings


# NSX Manager Uptime
$nsxMgrSummary = Get-NsxManagerSystemSummary
$nsxUptimeString = $nsxMgrSummary.uptime

# Split out the NSX Uptime string, using -split instead of .split as this allows multi-char regex splitting
$nsxUptimeSplits = $nsxUptimeString -split ",\ "

# Loop through the splits and detect the number of days/hours/mins
foreach ($split in $nsxUptimeSplits)
{
    # Extract the number of days/hours/minutes
    if ($split -match 'days'){[int]$days = $split.split(" ")[0]}
    if ($split -match 'hours'){[int]$hours = $split.split(" ")[0]}
    if ($split -match 'minutes'){[int]$minutes = $split.split(" ")[0]}
}

# Total up the number of hours.
$nsxUptime = ($days*24)+($hours)+($minutes/60)

# If the uptime doesn't match the desired quantity
if ($nsxUptime -lt $desiredMinUptime)

{
    $NsxManagerUptimeTable = New-Object system.Data.DataTable "NSX Manager Uptime"

    # Define Columns
    $cols = @()
    $cols += New-Object system.Data.DataColumn Name,([string])
    $cols += New-Object system.Data.DataColumn Uptime`(Hr`),([int])
        
    #Add the Columns
    foreach ($col in $cols) {$NsxManagerUptimeTable.columns.add($col)}

    # Populate a row in the Table
    $row = $NsxManagerUptimeTable.NewRow()

    # Enter data in the row
    $row.Name = $nsxMgrSummary.hostName
    $row."Uptime`(hr`)" = $nsxUptime
                    
    # Add the row to the table
    $NsxManagerUptimeTable.Rows.Add($row)
 
    # Display the Backup Frequency Table
    $NsxManagerUptimeTable | Select-Object Name,Uptime`(Hr`)
}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Manager Low Uptime"
$Header = "NSX Manager Low Uptime"
$Comments = "NSX Manager has not met the minimum uptime value of $($desiredMinUptime) hours"
$Display = "Table"
$Author = "Dave Hocking"
$PluginVersion = 0.2