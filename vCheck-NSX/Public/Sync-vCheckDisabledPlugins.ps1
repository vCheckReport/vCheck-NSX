

function Sync-vCheckDisabledPlugins {

<#
    .SYNOPSIS
        Matches the disabled plugins in a target directory with those in a source directory.

    .DESCRIPTION
        I wrote it for when I'm upgrading vCheck.  This will go through the old directory and
		any plugin marked as disabled there will be marked as disabled in the new directory.

    .PARAMETER  OldVcheckDir
        What you you think it is.

    .PARAMETER  NewVcheckDir
        No tricks here.

	.EXAMPLE
        Sync-vCheckDisabledPlugins -OldVcheckDir c:\scripts\vcheck6\vccenter_old_20150218_163057 -NewVcheckDir c:\scripts\vcheck6\vcenter

    .LINK
         https://github.com/alanrenouf/vCheck-vSphere

.NOTES
Recent Comment History
20150128	cmonahan	Initial release.

#>

[cmdletbinding(SupportsShouldProcess=$True)]

param (
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false)] $OldVcheckDir,
[Parameter(Position=1,Mandatory=$true,ValueFromPipeline=$false)] $NewVcheckDir
)

# $WhatIfPreference

$OldVcheckPluginsDir = (Get-ChildItem "$($OldVcheckDir)\Plugins").PsParentPath
$NewVcheckPluginsDir = (Get-ChildItem "$($NewVcheckDir)\Plugins").PsParentPath

$OldDisabled = Get-ChildItem $OldVcheckDir -Recurse | ? { $_ -like "*.disabled" } #| select -First 1
$OldDisabled

foreach ($file in $OldDisabled) {
	Get-ChildItem $NewVcheckDir -Recurse | Where-Object { $_ -match $file.Name } | Select-Object FullName
	Get-ChildItem $NewVcheckDir -Recurse -Filter $file.BaseName | ForEach-Object { Move-Item -Path $_.FullName -Destination ($_.FullName -replace("ps1","ps1.disabled")) }
}

<# Comment History
20150128	cmonahan	Initial release.
#>

} # end function