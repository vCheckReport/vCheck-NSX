<p align="center">
  <img src="https://github.com/vCheckReport/vCheck-NSX/blob/master/Content/nsx-logo-white.png"/>
</p>

<a name="Title">

# vCheck Daily Report for NSX

[![Documentation Status](https://readthedocs.org/projects/vcheck-nsx/badge/?version=latest)](http://vcheck-nsx.readthedocs.io/en/latest/?badge=latest)

[Join the VMware Code and #vCheck channel on slack and ask questions here!](https://code.vmware.com/slack/)

|Navigation|
|-----------------|
|[What is vCheck-NSX](#About)|
|[About](#About)|
|[Features](#Features)|
|[Installing](#Installing)|
|[Enhancements](#Enhancements)|
|[Release Notes](#ReleaseNotes)|
|[Contributing](#Contributing)|
|[Plugins](#Plugins)|
|[Styles](#Styles)|
|[Jobs & Settings](#JobsSettings)|
|[More Info](#More)|


<a name="What">

# What is vCheck-NSX? #
vCheck-NSX is an NSX-focussed reporting tool that can give you a periodic (i.e. Daily) look into the health of your platform.
* This tools is based on the awesome [vCheck-vSphere](https://github.com/alanrenouf/vCheck-vSphere) project
* Initially developed against vSphere 6.0, PowerCLI 6.5 and NSX 6.2.4
* This report REQUIRES [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/) and [PowerNSX](https://github.com/vmware/powernsx) installation
* This plugin also REQUIRES a connection to the vSphere server associated with the NSX Manager
* If you have multiple NSX managers and vCenter Servers, create multiple copies of the vCheck-NSX folder

<a name="About">

# About vCheck
[*Back to top*](#Title)

vCheck is a PowerShell HTML framework script, the script is designed to run as a scheduled task before you get into the office to present you with key information via an email directly to your inbox in a nice easily readable format.

This script picks on the key known issues and potential issues scripted as plugins for various technologies written as Powershell scripts and reports it all in one place so all you do in the morning is check your email.

One of they key things about this report is if there is no issue in a particular place you will not receive that section in the email, for example if there are no datastores with less than 5% free space (configurable) then the disk space section in the virtual infrastructure version of this script, it will not show in the email, this ensures that you have only the information you need in front of you when you get into the office.

This script is not to be confused with an Audit script, although the reporting framework can also be used for auditing scripts too.  I don't want to remind you that you have 5 hosts and what there names are and how many CPUs they have each and every day as you don't want to read that kind of information unless you need it, this script will only tell you about problem areas with your infrastructure.


<a name="Features">

# What is checked for in the NSX version ?
[*Back to top*](#Title)

The following items are included as part of the vCheck NSX download, they are included as vCheck Plugins and can be removed or altered very easily by editing the specific plugin file which contains the data. vCheck Plugins are found under the Plugins folder.

For each check that's written, here's a brief description of what it does.

***
## Connection Plugin for NSX ##
### Function ###
* Uses the nsxMgrCreds.xml file to connect through PowerNSX, to the NSX Manager

### Future Developments ###
* Detect successful connection to NSX Manager - report if not
* Detect presence of PowerNSX - report if not

***
## NSX Manager Resource Util ##
### Function ###
* Check for CPU/RAM/Disk use on the NSX Manager
* Default thresholds for warnings are:
    + CPU > 50%
    + RAM > 75%
    + Disk > 75%

***
## NSX Manager Service Summary ##
### Function ###
* Checks for the running state of the main services on the NSX Manager
    + "NSX Replicator" i.e. Universal Sync Service
    + "NSX Manager"
    + "RabbitMQ"
    + "vPostGres"
    + "SSH Service"
* Compares the running state with the desired state set in the .ps1 file
* Alerts on any deviation from expected state

***
## NSX Manager Low Uptime ##
### Function ###
* Checks the uptime of the NSX Manager and reports if it's less than the desired number of hours
* Can help you spot if the NSX Manager has been restarted in the last x Hours

### Future Developments ###
* Check uptime of NSX controllers and rename this check to "NSX Low Uptime"

***
## NSX Manager SSO and vCenter Connections ##
### Function ###
* Checks for status of SSO and VC connections
* Compares against desired setting in the .ps1
* Alerts on any deviation from expected state

***
## NSX Manager Backup Schedule ##
### Function ###
* Checks the configuration of a backup, i.e. "Is one configured for 'Hourly / Daily / Weekly'? "

### Future Developments ###
* Check for recent backup success
* Check for specific backup schedule

***
## NSX Manager NTP Setting ##
### Function ###
* Checks the NSX Manager for configured NTP servers against the specified entries in the .ps1
* Supports multiple NTP servers

### Future Developments ###
* Confirm NTP configuration is working - detect time drift

***
## NSX Controller Status Summary ##
### Function ###
* Detects the number of deployed, running controllers and compares against the "3" specified in the .ps1
* Checks for the Ping and Activity status of all peers
* Throws warnings for any detected issues
* Handles the detection of Secondary Managers, with no controllers of their own

***
## NSX Controller Upgrade Availability ##
### Function ###
* Detects if NSX Manager is reporting that the controllers can be upgraded

***
## NSX Controller Disk Latency ##
### Function ###
* Detects if the NSX Controllers are warning about poor disk latency

***
## NSX Syslog Settings ##
### Function ###
* Checks for the configuration of the specified syslog server in the .ps1
* NSX Manager only supports a single syslog server, so does this check

### Future Developments ###
* Expand the checks to include NSX Controller syslog configuration

***
## NSX Host Channel Health ##
### Function ###
* Checks the Channel Health for all controllers
    + "Manager to Firewall Agent"
    + "Manager to Control Plane"
    + "Control Plane to Controller"

### Future Developments ###
* Improve the detection of VMhosts that are configured for NSX use

***
## NSX Connectivity Test ##
### Function ###
* NOTHING AS YET, THIS IS CURRENTLY UNDER DEVELOPMENT

### Future Developments ###
* Check VXLAN functionality by automating ping tests

<a name="Installing">

# Installing
[*Back to top*](#Title)

For general guidance on the use of [vCheck-vSphere](https://github.com/alanrenouf/vCheck-vSphere) please see the README file hosted there.

Copy the vCheck folder to the desired location, note the content structure, in particular the Plugins folder.
Before you can use vCheck-NSX, you need to create an NSX credentials XML file.

>Use the following to create a credential interactively, then store it as an XML file

>`    $newPScreds = Get-Credential -message "Enter the NSX manager admin creds here:"`
>`    $newPScreds | Export-Clixml nsxMgrCreds.xml`

>Once you have the file, move it into the root of the "15 NSX" plugins folder overwriting the blank file that's there
*Ensure only authorised users (i.e. Sys Admins) have access to the file*

Having the creds stored as a secure file allows for the automation of vCheck script runs.
If there's a better way to store NSX Manager credentials, I'd like to know.

Once the files are in the correct location and the credentials XML file has been created, you need to start the installer.
Open a PowerCLI window **AS AN ADMINISTRATOR** then run...
`    vCheck.ps1 -config`
...which will start the process of configuring your install. During the process, your system will be tested for the installation of PowerNSX and if needed, an installation process will start.

<a name="Enhancements">

# Enhancements
[*Back to top*](#Title)

* **Report Output** - Make use of table formatting, highlight issues in red

* **Unit Testing / CI** - We are working on full support for [Pester](https://github.com/pester/Pester/blob/master/README.md) tests, which will help automate code validation. We will start small and work to provide as much documentation as we can to help with integration.

* **Module Support** - We are looking at our options to convert some, or all of the plugins to PowerShell modules. This will make things much easier to version and track, individually. Additionally, if we convert vCheck, itself, to a module, we open our options to support publishing to the [PowerShell Gallery](https://www.powershellgallery.com/), or at least providing users and organizations a standard platform to distribute it. Again, these options are currently under review.

* **Settings GUI** - A settings GUI would be a basic form that would allow a user to view/set/change current vCheck configuration settings, without the complexity of settings values from within a file. This initiative is currently in development.

In the meantime, don't hesitate to pop over to the [#vCheck channel on slack](https://code.vmware.com/slack/) and join in on active conversations about anything you see- or don't see- here!

<a name="ReleaseNotes">

# Release Notes
[*Back to top*](#Title)

* 0.1 - This is where it began
* 0.2 - Added support for auto-install of PowerNSX module

<a name="Contributing">

# Contributing
[*Back to top*](#Title)

See out [Contributions](CONTRIBUTING.md) guidelines

<a name="Plugins">

# Plugins
[*Back to top*](#Title)

## Suggested Plugins for Development ##
* A check for update availability to the NSX plugin
* Check for the presence of set routes on DLR/ESG
* Check anti-affinity rules enabled for nsx components
* Check Edge / LS status and report if there is any problem
* Check port group policy is consistent for every VDS used by NSX
* Report IP Pools running out of free IP's
* Check if password is close to expire
* List Major / Critical NSX Manager logs
* Report Major / Critical Edge Events

Some of the above suggestions have been taken from a [VMTN post](https://communities.vmware.com/message/2590709#2590709)

## Plugin Structure
This section describes the basic structure of a vCheck plugin so that you can write your own plugins for either private use, or to contribute to the vCheck project.

### Settings
Your plugin must contain a section for settings. This may be blank, or may contain one or more variables that must be defined for your plugin to determine how it operates.

**Examples**

No Settings
  ```
  # Start of Settings
  # End of Settings
  ```

Settings to define two variables
  ```
  # Start of Settings
  # Comment - presented as part of the setup wizard
  $variable = "value"
  # Second variable
  $variable2 = "value2"
  ...
  # End of Settings
  ```

### Required variables
Each plugin **must** define the following variables:
$Title - The display name of the plugin
$Header - the header of the plugin in the report
$Display - The format of the plugin (See Content section)
$Author - The author's name
$PluginVersion - Version of the plugin
$PluginCategory - The Category of the plugin

### Content
#### Report output
Anything that is written to stdout is included in the report. This should be either an object or hashtable in order to generate the report information.

#### $Display variable
- List
- Table
- Chart - Not currently merged to master

#### Plugin Template
  ```
  # Start of Settings
  # End of Settings

  # generate your report content here. Simple placeholder hashtable for the sake of example
  @{"Plugin"="Awesome"}

  $Title = "Plugin Template"
  $Header =  "Plugin Template"
  $Comments = "Comment about this awesome plugin"
  $Display = "List"
  $Author = "Plugin Author"
  $PluginVersion = 1.0
  $PluginCategory = "NSX"
  ```
## Table Formatting
Since v6.16, vCheck has supported Table formatting rules in plugins. This allows you to define a set of rules for data, in order to provide more richly formatted HTML reports.

### Using Formatting Rules

To use formatting rules, a `$TableFormat` variable must be defined in the module.

The `$TableFormat` variable is a Hastable, with the key being the "column" of the table that the rule should apply to.

The Value of the Hashtable is an array of rule. Each rule is a hashtable, with the Key being the expression to evaluate, and the value containing the formatting options.

### Formatting options

The Formatting options are made up of two comma-separated values:
 1. The scope of the formatting rule - "Row" to apply to the entire row, or "Cell" to only apply to that particular cell.
 2. A pipe-separated HTML attribute, and value. E.g. class|green to apply the "green" class to the HTML element specified in number 1.

### Examples

#### Example 1

Assume you have a CSS class named "green", which you want to apply to any compliant objects. Similarly, you have a "red" class that you wish to use to highlight non-compliant objects. We would define the formatting rules as follows:

`$TableFormat = @{"Compliant" = @(@{ "-eq $true" = "Cell,class|green"; }, @{ "-eq$false" = "Cell,class|red" })}`

Here we can see two rules; the first checks if the value in the Compliant column is equal to $true, in which case it applies the "green" class to the table cell (i.e.
element). The second rule applies when the compliant column is equal to $false, and applied the "red" class.

#### Example 2

Suppose you now want to run a report on Datastores. You wish to highlight datastores with less than 25% free space as "warning", those with free space less than 15% as "critical". To make them stand out more, you want to highlight the entire row on the report. You also wish to highlight datastores with a capacity less than 500GB as silver.

To achieve this, you could use the following:
```
$TableFormat = @{"PercentFree" = @(@{ "-le 25" = "Row,class|warning"; }, @{ "-le 15" = "Row,class|critical" }); "CapacityGB" = @(@{ "-lt 500" = "Cell,style|background-color: silver"})}
 ```
Here we see the rules that apply to two different columns, with rules applied to the values in a fashion similar to Example 1.

<a name="Styles">

# Styles
[*Back to top*](#Title)

Each style *must* implement a function named Get-ReportHTML, as this is what is called by vCheck to generate the HTML report.

An array of plugin results is passed to Get-ReportHTML, which contains the following properties:
* Title
* Author
* Version
* Details
* Display
* TableFormat
* Header
* Comments
* TimeToRun

Additionally, if the style is to define colours to be used by charts, the following variables need to be defined:
* `[string[]] $ChartColours` - Array containing HTML colours without the hash e.g. $ChartColours = @("377C2B", "0A77BA", "1D6325", "89CBE1")
* `[string] $ChartBackground` - HTML colour without the hash. e.g. "FFFFFF"
* `[string] $ChartSize` - YYYxZZZ formatted string - where YYY is horizontal size, and ZZZ is height. E.g. "200x200"

To include image resources, you may call Add-ReportResource, specifying CID and data. As these are not referenced by table formatting rules, this will need to be called with the `-Used $true` parameter.

<a name="JobsSettings">

# Jobs & Settings
[*Back to top*](#Title)

## Job XML Specifications

In order to use the `-Job` parameter, an XML configuration file is used.

The root element is `<vCheck>`, under this there are two elements:
* `<globalVariables>` element specifies the path to the file containing the vCheck settings (by default globalVariables.ps1)
* `<plugins>` element has a semi-colon separated attribute name path, which contains the path(s) to search for plugins contained in child `<plugin>` elements.

Each `<plugin>` element contains the plugin name.

### Config Example
  ```
  <vCheck>
    <globalVariables>GlobalVariables.ps1</globalVariables>
    <plugins path="plugins-vSphere">
       <plugin>00 Connection Plugin for vCenter.ps1</plugin>
       <plugin>03 Datastore Information.ps1</plugin>
       <plugin>11 VMs with over CPU Count LOL WRONG PATH.ps1</plugin>
       <plugin>99 VeryLastPlugin Used to Disconnect.ps1</plugin>
    </plugins>
  </vCheck>
  ```
## Export/Import Settings
This section describes how to import and export your vCheck settings between builds.

These functions were added to vCheckUtils.ps1 in June '14 (first release build TBD)

You can copy a newer version of vCheckUtils.ps1 to your existing build in order to use the new functions.

To utilize the new functions, simply dot source the vCheckUtils.ps1 file in a PowerShell console:
```
PS E:\scripts\vCheck-NSX> . .\vCheckUtils.ps1
```
This should load and list the functions available to you.
We will be focusing on Export-vCheckSettings and Import-vCheckSettings. If you do not see these listed, you will need a newer version of vCheckUtils.ps1.

### Example
Lets assume we have an existing build located at
`E:\Scripts\vCheck-NSX`

First lets rename the folder
`E:\Scripts\vCheck-NSX-old`

Now we can download the latest build, unblock the zip file and unpack to `E:\Scripts` leaving us with two builds in our Scripts directory - `vCheck-NSX-old` and `vCheck-NSX`

Next we'll export the settings from the old build - using PowerShell navigate to `E:\Scripts\vCheck-NSX-old` and dot source `vCheckUtils.ps1`

### Export Settings
Running `Export-vCheckSettings` will by default create a CSV file named `vCheckSettings.csv` in the current directory.
You can also specify a settings file
```
PS E:\scripts\vCheck-NSX-old> Export-vCheckSettings -outfile E:\MyvCheckSettings.csv
```

That's all there is to exporting your vCheck settings. Note that the settings file will be overwritten if you were to run the function again.

### Import Settings
To import your vCheck settings, in PowerShell navigate to the new build at `E:\Scripts\vCheck-NSX` and dot source `vCheckUtils.ps1` once again.

Here we have two options - if we run `Import-vCheckSettings` with no parameters it will expect the `vCheckSettings.csv` file to be in the same directory. If not found it will prompt for the full path to the settings CSV file.
The second option is to specify the path to the settings CSV file when running Import-vCheckSettings
```
PS E:\scripts\vCheck-NSX> Import-vCheckSettings -csvfile E:\MyvCheckSettings.csv
```
If new settings or plugins have been added to the new build you will be asked to answer the questions, similar to running the initial config. During the import, the initial config is disabled, so once the import is complete you are ready to run your new build.

<a name="More">

# More Info
[*Back to top*](#Title)

For more information please read here: http://www.virtu-al.net/vcheck-pluginsheaders/vcheck/

For an example NSX output (doesnt contain all info) click here http://virtu-al.net/Downloads/vCheck/vCheck.htm
