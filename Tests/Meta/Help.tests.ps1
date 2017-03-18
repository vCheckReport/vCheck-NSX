<#
.NOTES
    Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

#>

$parentPath   = Split-Path $PSScriptRoot -Parent
$projectPath  = Split-Path $parentPath -Parent
$moduleName   = Split-Path $projectPath -Leaf
$manifestPath = "$projectPath\$moduleName\$moduleName.psd1"

# Get module commands
# Remove all versions of the module from the session. Pester can't handle multiple versions.
Get-Module $moduleName | Remove-Module
Import-Module "$projectPath\$moduleName" -Verbose:$false -ErrorAction Stop
$moduleVersion = (Test-ModuleManifest $manifestPath | Select-Object -ExpandProperty Version).ToString()
# using a module spec object is not working with PS v5 (Core & Desktop) at the time of dev; no commands are returned
#$ms = [Microsoft.PowerShell.Commands.ModuleSpecification]@{ ModuleName = $moduleName; RequiredVersion = $moduleVersion }
$commands = Get-Command -Module $moduleName -CommandType Cmdlet, Function, Workflow  # Not alias


function Get-ParametersDefaultFirst {

    Param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Management.Automation.CommandInfo]
        $Command
    )

    BEGIN {

        $Common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable'
        $parameters = @()

    } # end BEGIN

    PROCESS {

        if ($defaultPSetName = $Command.DefaultParameterSet) {

            $defaultParameters = ($Command.ParameterSets | Where-Object Name -eq $defaultPSetName).parameters | Where-Object Name -NotIn $common
            $otherParameters = ($Command.ParameterSets | Where-Object Name -ne $defaultPSetName).parameters | Where-Object Name -NotIn $common

            $parameters += $defaultParameters
            if ($parameters -and $otherParameters) {

                $otherParameters | ForEach-Object {
                    if ($_.Name -notin $parameters.Name) {
                        $parameters += $_
                    }
                } # end ForEach-Object

                $parameters = $parameters | Sort-Object Name

            } # end if ($parameters -and $otherParameters)

        } else {

            $parameters = $Command.ParameterSets.Parameters | Where-Object Name -NotIn $common | Sort-Object Name -Unique

        } # end if/else

        return $parameters

    } # end PROCESS block

    END { } # end END

} # function Get-ParametersDefaultFirst



foreach ($command in $commands) {

    $commandName = $command.Name

    # Get the module name and version of the command. Used in the Describe name.
    #$commandModuleVersion = Get-CommandVersion -CommandInfo $command

    # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
    $Help = Get-Help $ModuleName\$commandName -ErrorAction SilentlyContinue

    if ($Help.Synopsis -like '*`[`<CommonParameters`>`]*') {

        $Help = Get-Help $commandName -ErrorAction SilentlyContinue

    } # end if

    Describe "Test help for $commandName" -Tag 'Help' {

        # If help is not found, synopsis in auto-generated help is the syntax diagram
        It "should not be auto-generated" {
            $Help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
        }

        # Should be a synopsis for every function
        It "gets synopsis for $commandName" {
            $Help.Synopsis | Should Not beNullOrEmpty
        }

        # Should be a description for every function
        It "gets description for $commandName" {
            $Help.Description | Should Not BeNullOrEmpty
        }

        # Should be at least one example
        It "gets example code from $commandName" {
            ($Help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
        }

        # Should be at least one example description
        It "gets example help from $commandName" {
            ($Help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
        }

        Context "Test parameter help for $commandName" {

            $Common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable',
            'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable'

            # Get parameters. When >1 parameter with same name,
            # get parameter from the default parameter set, if any.
            $parameters = Get-ParametersDefaultFirst -Command $command

            $parameterNames = $parameters.Name
            $HelpParameterNames = $Help.Parameters.Parameter.Name | Sort-Object -Unique

            foreach ($parameter in $parameters) {

                $parameterName = $parameter.Name
                $parameterHelp = $Help.parameters.parameter | Where-Object Name -EQ $parameterName

                # Should be a description for every parameter
                It "gets help for parameter: $parameterName : in $commandName" {
                    $parameterHelp.Description.Text | Should Not BeNullOrEmpty
                }

                # Required value in Help should match IsMandatory property of parameter
                It "help for $parameterName parameter in $commandName has correct Mandatory value" {
                    $codeMandatory = $parameter.IsMandatory.toString()
                    $parameterHelp.Required | Should Be $codeMandatory
                }

                # Parameter type in Help should match code
                It "help for $commandName has correct parameter type for $parameterName" {
                    $codeType = $parameter.ParameterType.Name
                    # To avoid calling Trim method on a null object.
                    $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                    $helpType | Should be $codeType
                }

            } # end foreach ($parameter in $parameters)

            foreach ($helpParm in $HelpParameterNames) {
                # Shouldn't find extra parameters in help.
                It "finds help parameter in code: $helpParm" {
                    $helpParm -in $parameterNames | Should Be $true
                }

            } # end foreach ($helpParm in $HelpParameterNames)

        } # end context

    } # end describe "Test help for $commandName"

} # end foreach ($command in $commands)