function Set-RootModule {
    [CmdletBinding()]
    param (
        # Path to local repository
        [Parameter()]
        [string]
        $Path,

        # Path to manifest file (existing or not)
        [Parameter()]
        [string]
        $ManifestPath,
        
        # RootModule
        [Parameter()]
        [string]
        $RootModule
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if ($ManifestPath) {
        [string]$moduleManifestBaseName = (Split-Path -Path $ManifestPath -Leaf) -replace '\.\w+$'
    } else {
        [string]$moduleManifestBaseName = Split-Path -Path $Path -Leaf
    }
    
    Write-Verbose -Message "$theFName Manifest basename is: $moduleManifestBaseName"

    [System.IO.FileInfo[]]$allFiles = Get-ChildItem -Path $Path -File
    [System.IO.FileInfo[]]$allModuleFiles = $allFiles.Where({
        $_.Extension -in @(
            '.psm1'
            '.dll'
        )
    })

    <# if ($allModuleFiles.Count -eq 0) {
        Write-Warning -Message "$theFName No module files found in path: $Path. Go deeper..."
        [System.IO.FileInfo[]]$allFiles = Get-ChildItem -Path $Path -File -Recurse
        [System.IO.FileInfo[]]$allModuleFiles = $allFiles.Where({
            $_.Extension -in @(
                '.psm1'
                '.dll'
            )
        })
    } #>

    if ($allModuleFiles.Count -eq 0) {
        Write-Error -Category ObjectNotFound -Message "$theFName Module files not found! Something wrong..."
        break
    } elseif ($allModuleFiles.Count -eq 1) {
        [string]$rootModuleBaseName = $allModuleFiles[0].Name
        [string]$rootModuleFullName = $allModuleFiles[0].FullName
        #$rootModuleFullName = [regex]::Replace($rootModuleFullName, $Path, '')
        Write-Verbose -Message "$theFName Only one module file `"$rootModuleBaseName`" found in path: $rootModuleFullName"
        return $rootModuleBaseName
    }

    if ($RootModule.Length -gt 0) {
        Write-Verbose -Message "$theFName RootModule name defined: $RootModule"
        [System.IO.FileInfo[]]$modulesMatchedToRoot = $allModuleFiles.Where({
            $_.Name -match $RootModule
        })
        if ($modulesMatchedToRoot.Count -eq 1) {
            [string]$rootModuleBaseName = $modulesMatchedToRoot[0].Name
            [string]$rootModuleFullName = $modulesMatchedToRoot[0].FullName
            #$rootModuleFullName = [regex]::Replace($rootModuleFullName, $Path, '')
            Write-Verbose -Message "$theFName Only one module file `"$rootModuleBaseName`" found in path: $rootModuleFullName"
            return $rootModuleBaseName
        } else {
            Write-Verbose -Message "$theFName Found $($modulesMatchedToManifest.Count) module files matching to given RootModule name `"$RootModule`"."
        }
    } else {
        Write-Verbose -Message "$theFName RootModule is not set."
    }

    [System.IO.FileInfo[]]$modulesMatchedToManifest = $allModuleFiles.Where({
        $_.BaseName -match $moduleManifestBaseName
    })

    if ($modulesMatchedToManifest.Count -eq 1) {
        [string]$rootModuleBaseName = $modulesMatchedToManifest[0].Name
        [string]$rootModuleFullName = $modulesMatchedToManifest[0].FullName
        #$rootModuleFullName = [regex]::Replace($rootModuleFullName, $Path, '')
        Write-Verbose -Message "$theFName Only one module file `"$rootModuleBaseName`" found in path: $rootModuleFullName"
        return $rootModuleBaseName
    } else {
        Write-Verbose -Message "$theFName Found $($modulesMatchedToManifest.Count) module files matching to manifest name `"$moduleManifestBaseName`"."
    }

    Write-Verbose -Message "$theFName End of function."
    return
}