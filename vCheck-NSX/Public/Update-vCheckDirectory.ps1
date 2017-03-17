

Function Update-vCheckDirectory {

    <#
    .SYNOPSIS
        Does most of the work upgrading to a new version of vCheck.

    .DESCRIPTION
        This function will:
		  -Backup the current directory by renaming it with the current date
		  -Copy in the new version from a directory you've specified
		  -Save all the variable settings to a text file
		  -Set the same disabled plugins in the new version
		  -Opens the saved variable settings in Notepad

		Then run vCheck.ps1 for the first time to configure it using the
		variables listing open in Notepad as a reference.

    .PARAMETER  CurrentvCheckPath
        Directory to be upgraded.

    .PARAMETER  NewvCheckSource
		Location of the new version downloaded from GitHub.

    .EXAMPLE
        Upgrade-vCheckDirectory -CurrentvCheckPath c:\scripts\vcheck6\vcenter -NewvCheckSource c:\scripts\vcheck6\vcenter\vCheck-vSphere-master

    .NOTES
        If you have multiple directories and some settings like smtp server
	are the same for them all you could upgrade the file(s) in the new
	vCheck version directory and they'll be copied out with each upgrade.

	This is my process for upgrading vCheck with this function.
	  1.  Extract a new, unmodified version of the vCheck to a directory.  For this example "C:\Scripts\vCheck\vCheck-vSphere-master".
	  2.  Load the utility - ". C:\Scripts\vCheck\vCheck-vSphere-master\vCheckUtils.ps1" .
	  3.  Upgrade-vCheckDirectory âCurrentvCheckPath C:\Scripts\vcheck\vcenterprod -NewvCheckSource C:\Scripts\vcheck6\vCheck-vSphere-master
	  4.  The list of plugin variable values is automatically opened in Notepad.
	  5.  Change directory to C:\Scripts\vcheck\vcenterprod .
	  6.  Run vCheck.ps1 .  Input all the prompts for variable values with the ones in the file opened by Notepad.  For the global variable â $EmailFrom = "vcheck-vcenter@monster.com" â I use my own email address until after I done a test run.  Then I change it back to the group email address.
	  7.  After all the variable have been entered vCheck will run.
	  8.  Review the PowerShell console for script errors and the vCheck email report for any problems.
	  9.  If there are not problems set the âEmailFromâ variable in âGlobalVariables.ps1â back to itâs original value.

      Recent Comment History
      20150127	cmonahan	Initial release.

    .LINK
        https://github.com/alanrenouf/vCheck-vSphere



#>

param (
[Parameter(Position=0,Mandatory=$true)] $CurrentvCheckPath,
[Parameter(Position=1,Mandatory=$true)] $NewvCheckSource
)

function Get-Now { (get-date -uformat %Y%m%d) + "_" + (get-date -uformat %H%M%S) }
$TS = Get-Now  # TS means time stamp

# Test that directories exist
if ( !(Test-Path -Path $CurrentvCheckPath) ) { break }
if ( !(Test-Path -Path $NewvCheckSource) )   { break }
$OldvCheckPath = "$($CurrentvCheckPath)_old_$($TS)"
$OldvCheckVariables = "$($OldvCheckPath)\vCheckVariables_$($TS).txt"

# Backup current directory and setup new directory
Move-Item -Path $CurrentvCheckPath -Destination $OldvCheckPath
mkdir $CurrentvCheckPath
robocopy $NewvCheckSource $CurrentvCheckPath /s /e /z /xj /r:2 /w:5 /np

# Save variable settings
Get-ChildItem -Path $OldvCheckPath -Filter *.ps1 -Recurse | % { Get-vCheckVariablesSettings -PluginFile $_.FullName } | Format-Table -AutoSize | Out-File -FilePath $OldvCheckVariables

# Make the disabled plugins match
Sync-vCheckDisabledPlugins -OldVcheckDir $OldvCheckPath -NewVcheckDir $CurrentvCheckPath

# Configure it
notepad $OldvCheckVariables
Write-Output "Locally on the server hosting the vCheck script run vCheck.ps1"

<# Comment History
20150128	cmonahan	Initial release.
#>

} # end function