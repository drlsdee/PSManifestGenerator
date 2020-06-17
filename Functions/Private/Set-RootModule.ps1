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
        #[string]$moduleManifestBaseName = (Split-Path -Path $ManifestPath -Leaf) -replace '\.\w+$'
        [string]$moduleManifestBaseName = [System.IO.Path]::GetFileNameWithoutExtension($ManifestPath)
        Write-Verbose -Message "$theFName Manifest basename from full path: $moduleManifestBaseName"
    } else {
        #[string]$moduleManifestBaseName = Split-Path -Path $Path -Leaf
        [string]$moduleManifestBaseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        Write-Verbose -Message "$theFName Manifest basename from folder name: $moduleManifestBaseName"
    }
    
    Write-Verbose -Message "$theFName Manifest basename is: $moduleManifestBaseName"

    [System.IO.FileInfo[]]$allFiles = Get-ChildItem -Path $Path -File
    [System.IO.FileInfo[]]$allModuleFiles = $allFiles.Where({
        $_.Extension -in @(
            '.psm1'
            '.dll'
            '.psd1'
            '.cdxml'
        )
    })

    if ($allModuleFiles.Count -eq 0)
    {
        Write-Warning -Message "$theFName Module files are not found! Something wrong..."
        return
    }
    elseif ($allModuleFiles.Count -eq 1)
    {
        [string]$rootModuleBaseName = $allModuleFiles[0].Name
        [string]$rootModuleFullName = $allModuleFiles[0].FullName
        #$rootModuleFullName = [regex]::Replace($rootModuleFullName, $Path, '')
        Write-Verbose -Message "$theFName Only one module file `"$rootModuleBaseName`" found in path: $rootModuleFullName"
        return $rootModuleBaseName
    }

    if ($RootModule.Length -eq 0) {
        Write-Verbose -Message "$theFName RootModule is not set."
    }
    else {
        Write-Verbose -Message "$theFName RootModule name defined: $RootModule"
        [System.IO.FileInfo[]]$modulesMatchedToRoot = $allModuleFiles.Where({
            $_.Name -match $RootModule
        })
        if ($modulesMatchedToRoot.Count -eq 1) {
            [string]$rootModuleBaseName = $modulesMatchedToRoot[0].Name
            [string]$rootModuleFullName = $modulesMatchedToRoot[0].FullName
            Write-Verbose -Message "$theFName Only one module file `"$rootModuleBaseName`" found in path: $rootModuleFullName"
            return $rootModuleBaseName
        } else {
            Write-Verbose -Message "$theFName Found $($modulesMatchedToManifest.Count) module files matching to given RootModule name `"$RootModule`"."
        }
    }

    [System.IO.FileInfo[]]$modulesMatchedToManifest = $allModuleFiles.Where({
        $_.BaseName -match $moduleManifestBaseName
    })

    if ($modulesMatchedToManifest.Count -eq 1) {
        [string]$rootModuleBaseName = $modulesMatchedToManifest[0].Name
        [string]$rootModuleFullName = $modulesMatchedToManifest[0].FullName
        Write-Verbose -Message "$theFName Only one module file `"$rootModuleBaseName`" found in path: $rootModuleFullName"
        return $rootModuleBaseName
    } else {
        Write-Verbose -Message "$theFName Found $($modulesMatchedToManifest.Count) module files matching to manifest name `"$moduleManifestBaseName`". Try to find exact matches..."
        [System.IO.FileInfo[]]$matchedBaseNameExact = $modulesMatchedToManifest.Where({
            $_.BaseName -eq $moduleManifestBaseName
        })
    }

    if ($matchedBaseNameExact.Count -eq 1)
    {
        Write-Verbose -Message "$theFName Root module probably found: $($matchedBaseNameExact[0].Name)"
        $RootModule = $matchedBaseNameExact[0].Name
    }
    elseif ($matchedBaseNameExact.Count -gt 1)
    {
        Write-Verbose -Message "$theFName Found $($matchedBaseNameExact.Count) module files with basenames exactly mathcing to `"$($matchedBaseNameExact[0].BaseName)`"."
        if ($matchedBaseNameExact.Extension -contains '.psd1')
        {
            $RootModule = $matchedBaseNameExact.Where({
                $_.Extension -eq '.psd1'
            })
            Write-Verbose -Message "$theFName Module manifest found: $RootModule"
        }
        elseif ($matchedBaseNameExact.Extension -contains '.psm1') {
            $RootModule = $matchedBaseNameExact.Where({
                $_.Extension -eq '.psm1'
            })
            Write-Verbose -Message "$theFName Module script found: $RootModule"
        }
        elseif ($matchedBaseNameExact.Extension -contains '.dll') {
            $RootModule = $matchedBaseNameExact.Where({
                $_.Extension -eq '.dll'
            })
            Write-Verbose -Message "$theFName Binary module found: $RootModule"
        }
        elseif ($matchedBaseNameExact.Extension -contains '.cdxml') {
            $RootModule = $matchedBaseNameExact.Where({
                $_.Extension -eq '.cdxml'
            })
            Write-Verbose -Message "$theFName CIM module found: $RootModule"
        }
        else {
            Write-Verbose -Message "$theFName There are no files that looks like a root module. Exiting."
            return
        }
    }

    Write-Verbose -Message "$theFName End of function."
    return $RootModule
}