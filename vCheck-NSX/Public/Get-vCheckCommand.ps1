

Function Get-vCheckCommand {

$moduleName = Split-Path $PSScriptRoot -Parent

	Get-Command -Module $moduleName

}