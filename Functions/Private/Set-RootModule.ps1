function Set-RootModule {
    [CmdletBinding()]
    param (
        # Path to local repository
        [Parameter()]
        [string]
        $Path,

        # The list of all module files of types 'Manifest', 'Script', 'Binary' or 'Cim'.
        [Parameter()]
        [System.IO.FileInfo[]]
        $ModuleFiles,
        
        # RootModule from bound parameters or old manifest data
        [Parameter()]
        [string]
        $RootModule
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if  (-not $ModuleFiles)
    {
        Write-Verbose -Message "$theFName No module files were found. Returning null."
        return
    }
    elseif ($ModuleFiles.Count -eq 1) {
        [System.IO.FileInfo]$rootModuleFile = $ModuleFiles[0]
        Write-Verbose -Message "$theFName Found only one module file `"$($rootModuleFile.Name)`" in path `"$($rootModuleFile.FullName)`". Returning this."
        return $rootModuleFile
    }

    Write-Verbose -Message "$theFName Found $($ModuleFiles.Count) module files of type other than `'Manifest`'."

    if  ($RootModule)
    {
        Write-Verbose -Message "$theFName Root module name is defined in bound parameters: $RootModule"
        if ([System.IO.Path]::GetExtension($RootModule) -eq '.psd1') {
            Write-Warning -Message "$theFName Predefined root module name is the name of module manifest! Anyway we'll ignore this and will search for matches with BaseName."
        }
        [string]$rootModuleBaseName = [System.IO.Path]::GetFileNameWithoutExtension($RootModule)
    }
    else {
        Write-Verbose -Message "$theFName Root module name is not set. Assume that root module name is equal to module's folder name."
        [string]$rootModuleBaseName = Split-Path -Path $Path -Leaf
    }

    Write-Verbose -Message "$theFName The BaseName for the root module should be `"$rootModuleBaseName`"."

    $ModuleFiles = $ModuleFiles.Where({
        $_.BaseName -eq $rootModuleBaseName
    })

    if  (-not $ModuleFiles) {
        Write-Verbose -Message "$theFName No module files with BaseName matching to `"$rootModuleBaseName`" were found. Returning null."
        return
    }

    if ($ModuleFiles.Count -eq 1) {
        Write-Verbose -Message "$theFName Found only one module file `"$($rootModuleFile.Name)`" in path `"$($rootModuleFile.FullName)`". Returning this."
        [System.IO.FileInfo]$rootModuleFile = $ModuleFiles[0]
        return $rootModuleFile
    }

    Write-Verbose -Message "$theFName Found $($ModuleFiles.Count) modules matching to BaseName `"$rootModuleBaseName`". Try to search exact match with root module name from bound parameters..."
    $ModuleFiles = $ModuleFiles.Where({
        ($_.Name -eq $RootModule) -and `
        ($_.DirectoryName -eq $Path)
    })

    if  (-not $ModuleFiles)
    {
        Write-Verbose -Message "$theFName Root module not found. End of function."
        return
    }

    [System.IO.FileInfo]$moduleToReturn = $ModuleFiles[0]

    Write-Verbose -Message "$theFName Root module `"$($moduleToReturn.BaseName)`" found in path `"$($moduleToReturn.FullName)`".End of function."
    return $moduleToReturn
}
