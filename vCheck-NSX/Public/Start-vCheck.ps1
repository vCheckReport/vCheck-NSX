
function Start-vCheck {

    <#
.SYNOPSIS
   vCheck is a PowerShell HTML framework script, designed to run as a scheduled
   task before you get into the office to present you with key information via
   an email directly to your inbox in a nice easily readable format.
.DESCRIPTION
   vCheck Daily Report for vSphere

   vCheck is a PowerShell HTML framework script, the script is designed to run
   as a scheduled task before you get into the office to present you with key
   information via an email directly to your inbox in a nice easily readable format.

   This script picks on the key known issues and potential issues scripted as
   plugins for various technologies written as powershell scripts and reports
   it all in one place so all you do in the morning is check your email.

   One of they key things about this report is if there is no issue in a particular
   place you will not receive that section in the email, for example if there are
   no datastores with less than 5% free space (configurable) then the disk space
   section in the virtual infrastructure version of this script, it will not show
   in the email, this ensures that you have only the information you need in front
   of you when you get into the office.

   This script is not to be confused with an Audit script, although the reporting
   framework can also be used for auditing scripts too. I dont want to remind you
   that you have 5 hosts and what there names are and how many CPUs they have each
   and every day as you dont want to read that kind of information unless you need
   it, this script will only tell you about problem areas with your infrastructure.

.NOTES
   File Name  : vCheck.ps1
   Author     : Alan Renouf - @alanrenouf
   Version    : 6.24

   Thanks to all who have commented on my blog to help improve this project
   all beta testers and previous contributors to this script.

.LINK
   http://www.virtu-al.net/vcheck-pluginsheaders/vcheck
.LINK
   https://github.com/alanrenouf/vCheck-vSphere/

.INPUTS
   No inputs required
.OUTPUTS
   HTML formatted email, Email with attachment, HTML File

.PARAMETER config
   If this switch is set, run the setup wizard

.PARAMETER Outputpath
   This parameter specifies the output location for files.

.PARAMETER job
   This parameter lets you specify an xml config file for this invokation
#>


    [CmdletBinding()]
    param (
        [Switch]$config,

        [Switch]$GUIConfig,

        [ValidateScript({ Test-Path $_ -PathType 'Container' })]
        [string]$Outputpath=$Env:TEMP,

        [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
        [string]$job
    )

	 #Requires -Version 3.0

    $vCheckVersion = "6.23"
    $Date = Get-Date

	# Setup all paths required for script to run
    #$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)
    #$PluginsFolder = $ScriptPath + "\Plugins\"
	$ScriptPath = $PSScriptRoot
	$PluginsFolder = "$PSScriptRoot\..\Plugins"




    #region Internationalization
    ################################################################################
    #                             Internationalization                             #
    ################################################################################
    $lang = DATA {
        ConvertFrom-StringData @'
      setupMsg01  =
      setupMsg02  = Welcome to vCheck by Virtu-Al http://virtu-al.net
      setupMsg03  = =================================================
      setupMsg04  = This is the first time you have run this script or you have re-enabled the setup wizard.
      setupMsg05  =
      setupMsg06  = To re-run this wizard in the future please use vCheck.ps1 -Config
      setupMsg07  = To get usage information, please use Get-Help vCheck.ps1
      setupMsg08  =
      setupMsg09  = Please complete the following questions or hit Enter to accept the current setting
      setupMsg10  = After completing this wizard the vCheck report will be displayed on the screen.
      setupMsg11  =
      configMsg01 = After you have exported the new settings from the configuration interface,
      configMsg02  = import the settings CSV file using Import-vCheckSettings -csvfile C:\\path\\to\\vCheckSettings.csv
      configMsg03  = NOTE: If vCheckSettings.csv is stored in the vCheck folder, simply run Import-vCheckSettings
      resFileWarn = Image File not found for {0}!
      pluginInvalid = Plugin does not exist: {0}
      pluginpathInvalid = Plugin path "{0}" is invalid, defaulting to {1}
      gvInvalid   = Global Variables path invalid in job specification, defaulting to {0}
      varUndefined = Variable `${0} is not defined in GlobalVariables.ps1
      pluginActivity = Evaluating plugins
      pluginStatus = [{0} of {1}] {2}
      Complete = Complete
      pluginBegin = \nBegin Plugin Processing
      pluginStart  = ..start calculating {0} by {1} v{2} [{3} of {4}]
      pluginEnd    = ..finished calculating {0} by {1} v{2} [{3} of {4}]
      repTime     = This report took {0} minutes to run all checks, completing on {1} at {2}
      repPRTitle = Plugin Report
      repTTRTitle = Time to Run
      slowPlugins = The following plugins took longer than {0} seconds to run, there may be a way to optimize these or remove them if not needed
      emailSend   = ..Sending Email
      emailAtch   = vCheck attached to this email
      HTMLdisp    = ..Displaying HTML results
'@
    }

    Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable lang -ErrorAction SilentlyContinue

    #endregion Internationalization
    #region initialization
    ################################################################################
    #                                Initialization                                #
    ################################################################################


    # if we have the job parameter set, get the paths from the config file.
    if ($job) {
        [xml]$jobConfig = Get-Content $job

        # Use GlobalVariables path if it is valid, otherwise use default
        if (Test-Path $jobConfig.vCheck.globalVariables) {
            $GlobalVariables = (Get-Item $jobConfig.vCheck.globalVariables).FullName
        } else {
            $GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"
            Write-Warning ($lang.gvInvalid -f $GlobalVariables)
        }

        # Get Plugin paths
        $PluginPaths = @()
        if ($jobConfig.vCheck.plugins.path) {
            foreach ($PluginPath in ($jobConfig.vCheck.plugins.path -split ";")) {
                if (Test-Path $PluginPath) {
                    $PluginPaths += (Get-Item $PluginPath).Fullname
                    $PluginPaths += Get-Childitem $PluginPath -Recurse | ?{ $_.PSIsContainer } | Select-Object -ExpandProperty FullName
                } else {
                    $PluginPaths += $ScriptPath + "\Plugins"
                    Write-Warning ($lang.pluginpathInvalid -f $PluginPath, ($ScriptPath + "\Plugins"))
                }
            }
            $PluginPaths = $PluginPaths | Sort-Object -unique

            # Get all plugins and test they are correct
            $vCheckPlugins = @()
            foreach ($plugin in $jobConfig.vCheck.plugins.plugin) {
                $testedPaths = 0
                foreach ($PluginPath in $PluginPaths) {
                    $testedPaths++
                    if (Test-Path ("{0}\{1}" -f $PluginPath, $plugin)) {
                        $vCheckPlugins += Get-Item ("{0}\{1}" -f $PluginPath, $plugin)
                        break;
                    }
                    # Plugin not found in any search path
                    elseif ($testedPaths -eq $PluginPaths.Count) {
                        Write-Warning ($lang.pluginInvalid -f $plugin)
                    }
                }
            }
        }
        # if no valid plugins specified, fall back to default
        if (!$vCheckPlugins) {
            $vCheckPlugins = Get-ChildItem -Path $PluginsFolder -filter "*.ps1" -Recurse | Sort-Object FullName
        }
    } else {
        $ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
        $vCheckPlugins = @(Get-ChildItem -Path $PluginsFolder -filter "*.ps1" -Recurse | Where-Object { $_.Directory -match "initialize" } | Sort-Object $ToNatural)
        $PluginsSubFolder = Get-ChildItem -Path $PluginsFolder | Where-Object { ($_.PSIsContainer) -and ($_.Name -notmatch "initialize") -and ($_.Name -notmatch "finish") }
        $vCheckPlugins += $PluginsSubFolder | % { Get-ChildItem -Path $_.FullName -filter "*.ps1" | Sort-Object $ToNatural }
        $vCheckPlugins += Get-ChildItem -Path $PluginsFolder -filter "*.ps1" -Recurse | Where-Object { $_.Directory -match "finish" } | Sort-Object $ToNatural
        $GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"
    }

    ## Determine if the setup wizard needs to run
    $file = Get-Content $GlobalVariables
    $Setup = ($file | Select-String -Pattern '# Set the following to true to enable the setup wizard for first time run').LineNumber
    $SetupLine = $Setup++
    $SetupSetting = Invoke-Expression (($file[$SetupLine]).Split("="))[1]


    ## Include GlobalVariables and validate settings (at the moment just check they exist)
    . $GlobalVariables

    $vcvars = @("SetupWizard", "reportHeader", "SMTPSRV", "EmailFrom", "EmailTo", "EmailSubject", "DisplaytoScreen", "SendEmail", "SendAttachment", "TimeToRun", "PluginSeconds", "Style", "Date")
    foreach ($vcvar in $vcvars) {
        if (!($(Get-Variable -Name "$vcvar" -Erroraction 'SilentlyContinue'))) {
        Write-Error ($lang.varUndefined -f $vcvar)
    }
}

# Create empty array of resources (i.e. Images)
$global:ReportResources = @{ }

## Set the StylePath and include it
$StylePath = $ScriptPath + "\Styles\" + $Style
if (!(Test-Path ($StylePath))) {
    # The path is not valid
    # Use the default style
    Write-Warning "Style path ($($StylePath)) is not valid"
    $StylePath = $ScriptPath + "\Styles\VMware"
    Write-Warning "Using $($StylePath)"
}

# Import the Style
. ("$($StylePath)\Style.ps1")


if ($SetupSetting -or $config -or $GUIConfig) {
    #Clear-Host

    ($lang.GetEnumerator() | Where-Object { $_.Name -match "setupMsg[0-9]*" } | Sort-Object Name) | ForEach-Object {
        Write-Warning -Message "$($_.value)"
    }

    if ($GUIConfig) {
        $PluginResult = @()

        # Set the output filename
        if (-not (Test-Path -PathType Container $Outputpath)) {
            New-Item $Outputpath -type directory | Out-Null
        }
        $Filename = ("{0}\{1}_vCheck-Config_{2}.html" -f $Outputpath, $Server, (Get-Date -Format "yyyyMMdd_HHmm"))

        #$configHTML = "<table>"
        #$configHTML += Invoke-HTMLSettings -Filename $GlobalVariables
        $PluginResult += Invoke-HTMLSettings -Filename $GlobalVariables
        Foreach ($plugin in $vCheckPlugins) {
            #$configHTML += Invoke-HTMLSettings -Filename $plugin.Fullname
            $PluginResult += Invoke-HTMLSettings -Filename $plugin.Fullname
        }

        # Run Style replacement
        $MyConfig = Get-ReportHTML
        # Always generate the report with embedded images
        $embedConfig = $MyConfig
        # Loop over all CIDs and replace them
        Foreach ($cid in $global:ReportResources.Keys) {
            $embedConfig = $embedConfig -replace ("cid:{0}" -f $cid), (Get-ReportResource $cid -ReturnType "embed")
        }

        $embedConfig | Out-File $Filename
        Invoke-Item $Filename
        ($lang.GetEnumerator() | Where-Object { $_.Name -match "configMsg[0-9]*" } | Sort-Object Name) | ForEach-Object {
            Write-Warning -Message "$($_.value)"
        }

    } elseif ($config) {
        Invoke-Settings -Filename $GlobalVariables -GB $true
        Foreach ($plugin in $vCheckPlugins) {
            Invoke-Settings -Filename $plugin.Fullname
        }
    }
}

#endregion initialization
if (-not $GUIConfig) {

    #region scriptlogic
    ################################################################################
    #                                 Script logic                                 #
    ################################################################################
    # Start generating the report
    $PluginResult = @()

    Write-Warning -Message $lang.pluginBegin

    # Loop over all enabled plugins
    $p = 0
    $vCheckPlugins | Foreach {
        $TableFormat = $null
        $PluginInfo = Get-PluginID $_.Fullname
        $p++
        Write-CustomOut ($lang.pluginStart -f $PluginInfo["Title"], $PluginInfo["Author"], $PluginInfo["Version"], $p, $vCheckPlugins.count)
        $pluginStatus = ($lang.pluginStatus -f $p, $vCheckPlugins.count, $_.Name)
        Write-Progress -ID 1 -Activity $lang.pluginActivity -Status $pluginStatus -PercentComplete (100 * $p/($vCheckPlugins.count))
        $TTR = [math]::round((Measure-Command { $Details = @(. $_.FullName)}).TotalSeconds, 2)

        Write-CustomOut ($lang.pluginEnd -f $PluginInfo["Title"], $PluginInfo["Author"], $PluginInfo["Version"], $p, $vCheckPlugins.count)
        # Do a replacement for [count] for number of items returned in $header
        $Header = $Header -replace "\[count\]", $Details.count

        $PluginResult += New-Object PSObject -Property @{
            "Title" = $Title;
            "Author" = $PluginInfo["Author"];
            "Version" = $PluginInfo["Version"];
            "Details" = $Details;
            "Display" = $Display;
            "TableFormat" = $TableFormat;
            "Header" = $Header;
            "Comments" = $Comments;
            "TimeToRun" = $TTR;
        }
    }
    Write-Progress -ID 1 -Activity $lang.pluginActivity -Status $lang.Complete -Completed

    # Add report on plugins
    if ($reportOnPlugins) {
        $Comments = "Plugins in numerical order"
        $Plugins = @()
        foreach ($Plugin in (Get-ChildItem $PluginsFolder -Include *.ps1, *.ps1.disabled -Recurse)) {
            $Plugins += New-Object PSObject -Property @{
                "Name" = (Get-PluginID  $Plugin.FullName).Title;
                "Enabled" = (($vCheckPlugins | Select-Object -ExpandProperty FullName) -Contains $plugin.FullName)
            }
        }

        if ($ListEnabledPluginsFirst) {
            $Plugins = $Plugins | Sort-Object -property @{ Expression = "Enabled"; Descending = $true }
            $Comments = "Plugins in numerical order, enabled plugins listed first"
        }

        $PluginResult += New-Object PSObject -Property @{
            "Title" = $lang.repPRTitle;
            "Author" = "vCheck";
            "Version" = $vCheckVersion;
            "Details" = $Plugins;
            "Display" = "Table";
            "TableFormat" = $null;
            "Header" = $lang.repPRTitle;
            "Comments" = $Comments;
            "TimeToRun" = 0;
        }
    }

    # Add Time to Run detail for plugins - if specified in GlobalVariables.ps1
    if ($TimeToRun) {
        $Finished = Get-Date
        $PluginResult += New-Object PSObject -Property @{
            "Title" = $lang.repTTRTitle;
            "Author" = "vCheck";
            "Version" = $vCheckVersion;
            "Details" = ($PluginResult | Where-Object { $_.TimeToRun -gt $PluginSeconds } | Select-Object Title, TimeToRun | Sort-Object TimeToRun -Descending);
            "Display" = "List";
            "TableFormat" = $null;
            "Header" = ($lang.repTime -f [math]::round(($Finished - $Date).TotalMinutes, 2), ($Finished.ToLongDateString()), ($Finished.ToLongTimeString()));
            "Comments" = ($lang.slowPlugins -f $PluginSeconds);
            "TimeToRun" = 0;
        }
    }

    #endregion scriptlogic

    #region output
    ################################################################################
    #                                    Output                                    #
    ################################################################################
    # Loop over plugin results and generate HTML from style
    $emptyReport = $true
    $p = 1
    Foreach ($pr in $PluginResult) {
        If ($pr.Details) {
            $emptyReport = $false
            switch ($pr.Display) {
                "List"  {
                    $pr.Details = Get-HTMLList $pr.Details
                }
                "Table" {
                    $pr.Details = Get-HTMLTable $pr.Details $pr.TableFormat
                }
                "Chart" {
                    $pr.Details = Get-HTMLChart "plugin$($p)" $pr.Details
                }
                default {
                    $pr.Details = $null
                }
            }
            $pr | Add-Member -Type NoteProperty -Name pluginID -Value "plugin-$p"
            $p++
        }
        if ($pr.Details -ne $null) {
            $emptyReport = $false
        }
    }

    # Run Style replacement
    $MyReport = Get-ReportHTML

    # Set the output filename
    if (-not (Test-Path -PathType Container $Outputpath)) {
        New-Item $Outputpath -type directory | Out-Null
    }
    $Filename = ("{0}\{1}_vCheck_{2}.htm" -f $Outputpath, $Server, (Get-Date -Format "yyyyMMdd_HHmm"))

    # Always generate the report with embedded images
    $embedReport = $MyReport
    # Loop over all CIDs and replace them
    Foreach ($cid in $global:ReportResources.Keys) {
        $embedReport = $embedReport -replace ("cid:{0}" -f $cid), (Get-ReportResource $cid -ReturnType "embed")
    }
    $embedReport | Out-File -encoding ASCII -filepath $Filename

    # Display to screen
    if ($DisplayToScreen -and (!($emptyReport -and !$DisplayReportEvenIfEmpty))) {
        Write-CustomOut $lang.HTMLdisp
        Invoke-Item $Filename
    }

    # Generate email
    if ($SendEmail -and (!($emptyReport -and !$EmailReportEvenIfEmpty))) {
        Write-CustomOut $lang.emailSend
        $msg = New-Object System.Net.Mail.MailMessage ($EmailFrom, $EmailTo)
        # If CC address specified, add
        If ($EmailCc -ne "") {
            $msg.CC.Add($EmailCc)
        }
        $msg.subject = $EmailSubject

        # if send attachment, just send plaintext email with HTML report attached
        If ($SendAttachment) {
            $msg.Body = $lang.emailAtch
            $attachment = new-object System.Net.Mail.Attachment $Filename
            $msg.Attachments.Add($attachment)
        }
        # Otherwise send the HTML email
        else {
            $msg.IsBodyHtml = $true;
            $html = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($MyReport, $null, 'text/html')
            $msg.AlternateViews.Add($html)

            # Loop over all CIDs and replace them
            Foreach ($cid in $global:ReportResources.Keys) {
                if ($global:ReportResources[$cid].Uses -gt 0) {
                    $lr = (Get-ReportResource $cid -ReturnType "linkedresource")
                    $html.LinkedResources.Add($lr);
                }
            }
        }
        # Send the email
        $smtpClient = New-Object System.Net.Mail.SmtpClient

        # Find the VI Server and port from the global settings file
        $smtpClient.Host = ($SMTPSRV -Split ":")[0]
        if (($SMTPSRV -split ":")[1]) {
            $smtpClient.Port = ($SMTPSRV -split ":")[1]
        }

        if ($EmailSSL -eq $true) {
            $smtpClient.EnableSsl = $true
        }
        $smtpClient.UseDefaultCredentials = $true;
        $smtpClient.Send($msg)
        If ($SendAttachment) {
            $attachment.Dispose()
        }
        $msg.Dispose()
    }

    # Run EndScript once everything else is complete
    if (Test-Path ($ScriptPath + "\EndScript.ps1")) {
        . ($ScriptPath + "\EndScript.ps1")
    }

    #endregion output
}


} # end function Start-vCheck