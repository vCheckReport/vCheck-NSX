$Title = "Connection settings for NSX"
$Author = "Alan Renouf"
$PluginVersion = 1.20
$Header = "Connection Settings"
$Comments = "Connection Plugin for connecting to NSX"
$Display = "None"
$PluginCategory = "NSX"

# Start of Settings
# Please Specify the address of the NSX Server
$Server = "192.168.0.0"
# End of Settings

# Update settings where there is an override
$Server = Get-vCheckSetting $Title "Server" $Server


function Get-CorePlatform {
    [cmdletbinding()]
    param()
    #Thanks to @Lucd22 (Lucd.info) for this great function!
    $osDetected = $false
    try{
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        Write-Verbose -Message 'Windows detected'
        $osDetected = $true
        $osFamily = 'Windows'
        $osName = $os.Caption
        $osVersion = $os.Version
        $nodeName = $os.CSName
        $architecture = $os.OSArchitecture
    }
    catch{
        Write-Verbose -Message 'Possibly Linux or Mac'
        $uname = "$(uname)"
        if($uname -match '^Darwin|^Linux'){
            $osDetected = $true
            $osFamily = $uname
            $osName = "$(uname -v)"
            $osVersion = "$(uname -r)"
            $nodeName = "$(uname -n)"
            $architecture = "$(uname -p)"
        }
        # Other
        else
        {
            Write-Warning -Message "Kernel $($uname) not covered"
        }
    }
    [ordered]@{
        OSDetected = $osDetected
        OSFamily = $osFamily
        OS = $osName
        Version = $osVersion
        Hostname = $nodeName
        Architecture = $architecture
    }
}

$Platform = Get-CorePlatform
switch ($platform.OSFamily) {
    "Darwin" { 
        $templocation = "/tmp"
        $Outputpath = $templocation
    }
    "Linux" { 
        $Outputpath = $templocation
        $templocation = "/tmp"
    }
    "Windows" { 
        $templocation = "$ENV:Temp"
    }
}

#Add NSX Connection Logic Here!