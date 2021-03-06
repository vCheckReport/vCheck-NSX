# Start of Settings
# Desired Ntp Server(s) in CSV format, e.g. "123.123.123.123, 10.23.12.123"
$desiredNtpServersCSV = ""
# End of Settings

# Convert the supplied Servers into an array
$desiredNtpServers = @()
# Split the supplied servers on ", " or ","
foreach ($ntpServer in $desiredNtpServersCSV -Split (", |,"))
{
    $desiredNtpServers += $ntpServer
}

# Sort the list
$desiredNtpServers = $desiredNtpServers | Sort-Object

# Reset flag
$displayNTPtable = $false

# NSX Manager NTP Server
$nsxMgrNtpSettings = Get-NsxManagerTimeSettings
$nsxMgrNtpServers = $nsxMgrNtpSettings.ntpserver.string


# Check for the presence of each desired NTP server in the array above
foreach ($desiredNtpServer in $desiredNtpServers)
{
    if (@($nsxMgrNtpServers).Contains($desiredNtpServer) -eq $false)
    {
        $displayNTPtable = $true
    }
}

# If the DisplayNTPtable flag has been set, generate one
if ($displayNTPtable -eq $true)

{
    $NsxManagerNTPtable = New-Object system.Data.DataTable "NSX Manager NTP Servers"

    # Define Columns
    $cols = @()
    $cols += New-Object system.Data.DataColumn "Specified Servers",([string])
    $cols += New-Object system.Data.DataColumn Configured,([string])

    #Add the Columns
    foreach ($col in $cols) {$NsxManagerNTPtable.columns.add($col)}

    # Loop through each defined Server and show output
    foreach ($desiredNtpServer in $desiredNtpServers)
    {
        # Populate a row in the Table
        $row = $NsxManagerNTPtable.NewRow()

        # Enter data in the row
        $row."Specified Servers" = $desiredNtpServer
        $row.Configured = @($nsxMgrNtpServers).Contains($desiredNtpServer)

        # Add the row to the table
        $NsxManagerNTPtable.Rows.Add($row)
    }

    # Display the Backup Frequency Table
    $NsxManagerNTPtable | Select-Object "Specified Servers",Configured
}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Manager NTP Server Setting"
$Header = "NSX Manager NTP Server Setting"
$Comments = "NSX Manager has not been configured with the correct NTP Server Settings"
$Display = "Table"
$Author = "David Hocking"
$PluginVersion = 0.2