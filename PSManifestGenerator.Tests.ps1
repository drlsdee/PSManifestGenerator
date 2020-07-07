#Import-Module -Name PSScriptAnalyzer -Force

[string[]]$dirsAll = [System.IO.Directory]::EnumerateDirectories($PSScriptRoot)
[string]$classesDir = "$PSScriptRoot\Classes"
[string]$functionsDir = "$PSScriptRoot\Functions"
[string[]]$classessAll = @()
[string[]]$functionsAll = @()
if ($dirsAll.Contains($classesDir)) {
    [string[]]$classessAll = @(
        [System.IO.Directory]::EnumerateFiles($classesDir, '*.ps1', 'AllDirectories')
    )
}

if ($dirsAll.Contains($functionsDir)) {
    [string[]]$functionsAll = @(
        [System.IO.Directory]::EnumerateFiles($functionsDir, '*.ps1', 'AllDirectories')
    )
}

[string]$theModuleName = [System.IO.Path]::GetFileName($PSScriptRoot)

[string]$manifestPath = [System.IO.Path]::Combine($PSScriptRoot, "$($theModuleName).psd1")

[string[]]$moduleExtensions = @(
    '.psm1'
    '.psd1'
    '.xaml'
    '.cdxml'
    '.dll'
    '.exe'
)
[string[]]$moduleFiles = $moduleExtensions.ForEach({
    [System.IO.Directory]::EnumerateFiles($PSScriptRoot, "*$($_)")
})
[string[]]$moduleBaseNames = $moduleFiles.ForEach({
    [System.IO.Path]::GetFileNameWithoutExtension($_)
}) | Select-Object -Unique

Describe "General tests for the module $theModuleName" {
    Context "Module $theModuleName Inventory" {
        It "At least one module file should exist" {
            $moduleFiles.Count -gt 0 | Should Be $true
        }
        
        It "At least one of module files should have the basename equal to the $theModuleName" {
            $moduleBaseNames.Count -gt 0 | Should Be $true
        }
    }

    Context "Check every script of the module $theModuleName" {
        $classessAll.ForEach({
            It "Importing the class $([System.IO.Path]::GetFileNameWithoutExtension($_))" {
                . $_ | Should Be $null
            }
        })

        $functionsAll.ForEach({
            It "Running the function $([System.IO.Path]::GetFileNameWithoutExtension($_))" {
                & $_ | Should Be $null
            }
        })
    }

    if ([System.IO.File]::Exists($manifestPath)) {
        Context "Checking the manifest of the module $theModuleName" {
            It "Importing the manifest $theModuleName" {
            Import-PowerShellDataFile -Path $manifestPath | Should Be System.Collections.Hashtable
            }

            [hashtable]$psData = Import-PowerShellDataFile -Path $manifestPath

            It "The Manifest contains keys" {
                $psData.Keys.Count -gt 0 | Should Be $true
            }

            It "The Manifest's root module is not the manifest or .ps1 script" {
                if ($psData.ContainsKey('RootModule')) {
                    [string]$rootModuleExt = [System.IO.Path]::GetExtension($psData.RootModule)
                    ($rootModuleExt -in $moduleExtensions) -and `
                    ($rootModuleExt -ne '.psd1') | Should Be $true
                }
            }
        }
    }

    Context "Trying to import the module $theModuleName" {
        It "Get information about the module $theModuleName" {
            Get-Module -Name $PSScriptRoot -ListAvailable | Should Be $true
        }

        It "Check if the module $theModuleName can be loaded" {
            Import-Module -Name $PSScriptRoot -Force | Should Be $null
        }

        It "Check if the module $theModuleName can be UNloaded" {
            Remove-Module -Name $theModuleName -Force | Should Be $null
        }
    }
}
