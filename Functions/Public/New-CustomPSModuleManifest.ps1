function New-CustomPSModuleManifest {
    [CmdletBinding()]
    [Alias('customManifest')]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        # Path to local repo
        [string]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        # GUID
        [string]
        $Guid,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Author's name
        [string]
        $Author,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Company name (not necessary)
        [string]
        $CompanyName,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Module version (may be set auto)
        [string]
        $ModuleVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        # PS version (may be set from build host)
        [string]
        $PowerShellVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Not implemented yet
        [hashtable]
        $RequiredModules,

        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $Tags,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ProjectUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $LicenseUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $IconUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ReleaseNotes,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $HelpInfoUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Old version
        [string]
        $VersionOld,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Major
        [switch]
        $Major,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Minor
        [switch]
        $Minor,

        [Parameter(ValueFromPipelineByPropertyName)]
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

    [string[]]$givenParameterNames = $PSBoundParameters.Keys.Where({
        $_ -notin [string[]]@([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
    })
    $givenParamValues = New-Object -TypeName psobject
    $PSBoundParameters.Keys.ForEach({
        $givenParamValues | Add-Member -MemberType NoteProperty -Name $_ -Value $PSBoundParameters.$_
    })
    if (-not ($givenParameterNames.Count -gt 0)) {
        Write-Warning -Message "$theFName Only common parameters found."
        $givenParamValues | Add-Member -MemberType NoteProperty -Name 'Path' -Value $Path
    } else {
        Write-Verbose -Message "$theFName Found bound parameters: $($givenParameterNames -join ', ')"
    }

    $manifestDataNew = $givenParamValues | Create-ManifestParameters

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
            ($_ -notin @('privatedata', 'companyname')) -and `
            ($null -ne $manifestDataOld.$_) -and `
            ($manifestDataOld.$_ -notmatch '[*]') -and `
            ($manifestDataOld.$_ -notmatch 'unknown')
        }).ForEach({
            Write-Verbose -Message "$theFName Old value found: $_; value is `"$($manifestDataOld.$_)`""
            $manifestDataNew.$_ = $manifestDataOld.$_
        })
        $versionNew = Set-NewVersion -Major:$Major -Minor:$Minor -Build $Build -VersionOld $manifestDataOld.ModuleVersion
        Write-Verbose -Message "$theFName New version is set: `"$versionNew`""
        $manifestDataNew.ModuleVersion = $versionNew
        Write-Verbose -Message "$theFName Now we will remove the old manifest and will create new with given parameters!"
        [string]$backupManifest = "$($manifestDataNew.Path).old"
        Move-Item -Path $manifestDataNew.Path -Destination $backupManifest -Force
        if (-not (Test-Path -Path $backupManifest -PathType Leaf)) {
            Write-Warning -Message "$theFName Backup of old manifest should be at path `"$backupManifest`", but NOT FOUND!"
        }

        [string[]]$newPropNames = $manifestDataNew.PSObject.Properties.Name
        $newPropNames.ForEach({
            Write-Verbose -Message "$theFName Property name: $_; value: $($manifestDataNew.$_)"
        })

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
