<#
.NOTES
    Ref Links:
        https://github.com/PowerShell/DscResource.Tests/blob/master/Meta.Tests.ps1
        https://github.com/devblackops/powernsx/tree/module-tests
#>
Set-StrictMode -Version latest

# Make sure MetaFixers.psm1 is loaded - it contains Get-TextFilesList
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'MetaFixers.psm1') -Verbose:$false -Force

$projectRoot = (Resolve-Path $PSScriptRoot\..\..).Path
if(-not $projectRoot) {
    $projectRoot = $PSScriptRoot
}

Describe 'Text files formatting' {

    $allTextFiles = Get-TextFilesList $projectRoot

    Context 'Files encoding' {
        It "Doesn't use Unicode encoding" {
            $unicodeFilesCount = 0
            $allTextFiles | ForEach-Object {
                if (Test-FileUnicode $_) {
                    $unicodeFilesCount += 1
                    Write-Warning "File $($_.FullName) contains 0x00 bytes. It's probably uses Unicode and need to be converted to UTF-8. Use Fixer 'Get-UnicodeFilesList `$pwd | ConvertTo-UTF8'."
                } # end if
            } # end foreach
            $unicodeFilesCount | Should Be 0
        } # end It
    } # end context

    Context 'Indentations' {
        It 'Uses spaces for indentation, not tabs' {
            $totalTabsCount = 0
            $allTextFiles | ForEach-Object {
                $fileName = $_.FullName
                (Get-Content $_.FullName -Raw) | Select-String "`t" | ForEach-Object {
                    Write-Warning "There are tab in $fileName. Use Fixer 'Get-TextFilesList `$pwd | ConvertTo-SpaceIndentation'."
                    $totalTabsCount++
                } # end foreach
            } # end foreach
            $totalTabsCount | Should Be 0
        } # end It
    } # end context

} # end describe