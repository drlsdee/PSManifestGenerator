function New-CustomPSModuleManifest {
    [CmdletBinding()]
    [Alias('customManifest')]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path,

        [Parameter()]
        #
        [string]
        $Tags,
        
        [Parameter()]
        #
        [string]
        $ProjectUri,
        
        [Parameter()]
        #
        [string]
        $LicenseUri,
        
        [Parameter()]
        #
        [string]
        $IconUri,
        
        [Parameter()]
        #
        [string]
        $ReleaseNotes,
        
        [Parameter()]
        #
        [string]
        $HelpInfoUri,

        [Parameter()]
        # Old version
        [string]
        $VersionOld,

        [Parameter()]
        # Major
        [switch]
        $Major,

        [Parameter()]
        # Minor
        [switch]
        $Minor,

        [Parameter()]
        # Build
        [string]
        $Build
    )

    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"

    [string]$myModuleName = Get-RepoName -Path $Path
    [string]$myModuleFilePath = "$Path\$myModuleName.psm1"
    [string]$myModuleManifestPath = "$Path\$myModuleName.psd1"
    
    Write-Verbose -Message "$theFName Checking if module file exists..."
    if (-not (Test-Path -Path $myModuleFilePath -PathType Leaf)) {
        Write-Error -Category ObjectNotFound -Message "$theFName Module file `"$myModuleFilePath`" NOT FOUND! Exiting..."
        break
    } else {
        Write-Verbose -Message "$theFName Module file `"$myModuleFilePath`" found. Continue."
    }

    $manifestDataNew = Create-ManifestParameters -Path $Path `
                    -Tags $Tags `
                    -ProjectUri $ProjectUri `
                    -LicenseUri $LicenseUri `
                    -IconUri $IconUri `
                    -ReleaseNotes $ReleaseNotes `
                    -HelpInfoUri $HelpInfoUri

    Write-Verbose -Message "$theFName Checking if MANIFEST file exists..."
    if (-not (Test-Path -Path $myModuleManifestPath -PathType Leaf)) {
        Write-Verbose -Message "$theFName Manifest file `"$myModuleManifestPath`" not found. New manifest will be created."
        $manifestDataNew.ModuleVersion = Set-NewVersion -Major:$Major -Minor:$Minor -Build $Build
        if ($Tags) {
        New-ModuleManifest    -Path              $manifestDataNew.Path `
                              -NestedModules     $manifestDataNew.NestedModules `
                              -Guid              $manifestDataNew.Guid `
                              -Author            $manifestDataNew.Author `
                              -CompanyName       $manifestDataNew.CompanyName `
                              -Copyright         $manifestDataNew.Copyright `
                              -RootModule        $manifestDataNew.RootModule `
                              -ModuleVersion     $manifestDataNew.ModuleVersion `
                              -Description       $manifestDataNew.Description `
                              -PowerShellVersion $manifestDataNew.PowerShellVersion `
                              -FunctionsToExport $manifestDataNew.FunctionsToExport `
                              -AliasesToExport   $manifestDataNew.AliasesToExport `
                              -ProjectUri        $manifestDataNew.ProjectUri `
                              -ReleaseNotes      $manifestDataNew.ReleaseNotes `
                              -Tags              $manifestDataNew.Tags
        } else {
        New-ModuleManifest    -Path              $manifestDataNew.Path `
                              -NestedModules     $manifestDataNew.NestedModules `
                              -Guid              $manifestDataNew.Guid `
                              -Author            $manifestDataNew.Author `
                              -CompanyName       $manifestDataNew.CompanyName `
                              -Copyright         $manifestDataNew.Copyright `
                              -RootModule        $manifestDataNew.RootModule `
                              -ModuleVersion     $manifestDataNew.ModuleVersion `
                              -Description       $manifestDataNew.Description `
                              -PowerShellVersion $manifestDataNew.PowerShellVersion `
                              -FunctionsToExport $manifestDataNew.FunctionsToExport `
                              -AliasesToExport   $manifestDataNew.AliasesToExport `
                              -ProjectUri        $manifestDataNew.ProjectUri `
                              -ReleaseNotes      $manifestDataNew.ReleaseNotes
        }
        if (-not (Test-Path -Path $manifestDataNew.Path -PathType Leaf)) {
            Write-Error -Category ObjectNotFound -Message "$theFName New manifest not found at path `"$($manifestDataNew.Path)`"! Something wrong..."
        break
        } else {
            Write-Verbose -Message "$theFName Module manifest successfully created."
        }
    } else {
        Write-Verbose -Message "$theFName Manifest file `"$myModuleManifestPath`" found. Continue with updating the manifest."
        $manifestDataOld = Import-PowerShellDataFile -Path $myModuleManifestPath
        $oldValueNames = $manifestDataOld.Keys
        Write-Verbose -Message "$theFName Found $($oldValueNames.Count) old values"

        $oldValueNames.Where({
            ($_ -notin @('privatedata')) -and `
            ($manifestDataOld.$_ -ne $null) -and `
            ($manifestDataOld.$_ -notmatch '[*]') -and `
            ($manifestDataOld.$_ -notmatch 'unknown')
        }).ForEach({
            Write-Verbose -Message "$theFName Old value found: $_; value is `"$($manifestDataOld.$_)`""
            $manifestDataNew.$_ = $manifestDataOld.$_
        })
        $manifestDataNew.ModuleVersion = Set-NewVersion -Major:$Major -Minor:$Minor -Build $Build -VersionOld $manifestDataOld.ModuleVersion
        Write-Verbose -Message "$theFName Now we will remove the old manifest and will create new with given parameters!"
        [string]$backupManifest = "$($manifestDataNew.Path).old"
        Move-Item -Path $manifestDataNew.Path -Destination $backupManifest -Force
        if (-not (Test-Path -Path $backupManifest -PathType Leaf)) {
            Write-Warning -Message "$theFName Backup of old manifest should be at path `"$backupManifest`", but NOT FOUND!"
        }

        if ($Tags) {
        New-ModuleManifest    -Path              $manifestDataNew.Path `
                              -NestedModules     $manifestDataNew.NestedModules `
                              -Guid              $manifestDataNew.Guid `
                              -Author            $manifestDataNew.Author `
                              -CompanyName       $manifestDataNew.CompanyName `
                              -Copyright         $manifestDataNew.Copyright `
                              -RootModule        $manifestDataNew.RootModule `
                              -ModuleVersion     $manifestDataNew.ModuleVersion `
                              -Description       $manifestDataNew.Description `
                              -PowerShellVersion $manifestDataNew.PowerShellVersion `
                              -FunctionsToExport $manifestDataNew.FunctionsToExport `
                              -AliasesToExport   $manifestDataNew.AliasesToExport `
                              -ProjectUri        $manifestDataNew.ProjectUri `
                              -ReleaseNotes      $manifestDataNew.ReleaseNotes `
                              -Tags              $manifestDataNew.Tags
        } else {
        New-ModuleManifest    -Path              $manifestDataNew.Path `
                              -NestedModules     $manifestDataNew.NestedModules `
                              -Guid              $manifestDataNew.Guid `
                              -Author            $manifestDataNew.Author `
                              -CompanyName       $manifestDataNew.CompanyName `
                              -Copyright         $manifestDataNew.Copyright `
                              -RootModule        $manifestDataNew.RootModule `
                              -ModuleVersion     $manifestDataNew.ModuleVersion `
                              -Description       $manifestDataNew.Description `
                              -PowerShellVersion $manifestDataNew.PowerShellVersion `
                              -FunctionsToExport $manifestDataNew.FunctionsToExport `
                              -AliasesToExport   $manifestDataNew.AliasesToExport `
                              -ProjectUri        $manifestDataNew.ProjectUri `
                              -ReleaseNotes      $manifestDataNew.ReleaseNotes
        }
        if (-not (Test-Path -Path $manifestDataNew.Path -PathType Leaf)) {
            Write-Error -Category ObjectNotFound -Message "$theFName New manifest not found at path `"$($manifestDataNew.Path)`"! Something wrong..."
        break
        } else {
            Write-Verbose -Message "$theFName Module manifest successfully updated. Removing backup."
            Remove-Item -Path $backupManifest -Force
        }
    }
}
