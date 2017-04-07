# Start of Settings
# End of Settings
 
# Everything in this script will run at the end of vCheck
If ($VIConnection) {
  $VIConnection | Disconnect-VIServer -Confirm:$false
}

# Disconnect the NSX Server
Disconnect-NsxServer


$Title = "Disconnecting from vCenter / NSX"
$Header = "Disconnects from vCenter / NSX"
$Comments = "Disconnect plugin"
$Display = "None"
$Author = "Alan Renouf / Dave Hocking"
$PluginVersion = 1.1
$PluginCategory = "NSX"
