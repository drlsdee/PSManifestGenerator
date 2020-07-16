function Get-NestedModules {
    [CmdletBinding()]
    [Alias('getNesMod')]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path,

        [Parameter()]
        # Nested modules root folder name
        [string]
        $ModulesFolder,

        # The list of all module files of types 'Manifest', 'Script', 'Binary' or 'Cim'.
        [Parameter()]
        [System.IO.FileInfo[]]
        $ModuleFiles,

        # Root module from bound parameters
        [Parameter()]
        [System.IO.FileInfo]
        $RootModule
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [string]$includeFolder = "$($PSScriptRoot)\$($MyInvocation.MyCommand.Name)"
    [string[]]$toolsScripts = [System.IO.Directory]::EnumerateFiles($includeFolder, '*.ps1')
    if ($toolsScripts) {
        $toolsScripts.ForEach({
            Write-Verbose -Message "$theFName Loading script from path: $_"
            . $_
        })
    }

    if (-not $ModuleFiles) {
        Write-Verbose -Message "$theFName List of module files is empty! Exiting."
        return
    }

    [string]$subModulesFolderPath = [System.IO.Path]::Combine($Path, $ModulesFolder)
    if (-not $ModulesFolder) {
        Write-Verbose -Message "$theFName Folder for nested modules is not defined. Search in whole module folder `"$subModulesFolderPath`"..."
        [System.IO.FileInfo[]]$subModuleFilesAll = $ModuleFiles
    } else {
        Write-Verbose -Message "$theFName Search for nested modules in folder `"$subModulesFolderPath`"..."
        [System.IO.FileInfo[]]$subModuleFilesAll = $ModuleFiles.Where({
            $_.DirectoryName -eq $subModulesFolderPath
        })
    }

    if (-not $subModuleFilesAll) {
        Write-Verbose -Message "$theFName Modules are not found! Exiting."
        return
    }

    Write-Verbose -Message "$theFName Found $($subModuleFilesAll.Count) module files total."

    if ($RootModule) {
        [string]$rootModuleScript   = $RootModule.FullName
        [string]$rootModuleManifest = [System.IO.Path]::ChangeExtension($rootModuleScript, 'psd1')
        Write-Verbose -Message "$theFName Root module is defined: `"$rootModuleScript`". Excluding it from module list as well as the module manifest `"$rootModuleManifest`"..."
        $subModuleFilesAll = $subModuleFilesAll.Where({
            $_.FullName -notin @(
                $rootModuleScript
                $rootModuleManifest
            )
        })
    }
    else {
        Write-Verbose -Message "$theFName Root module is NOT defined! Processing whole module list..."
    }

    if (-not $subModuleFilesAll) {
        Write-Verbose -Message "$theFName There are no modules excepting the root module! Exiting."
        return
    }

    [psmoduleinfo[]]$subModulesInfoAll = $subModuleFilesAll.ForEach({
        try {
            Get-Module -Name $_.FullName -ListAvailable
        }
        catch {
            throw
        }
    })

    [psmoduleinfo[]]$subModulesToProcess = Get-ChildModules -ModuleList $subModulesInfoAll

    if ($subModulesToProcess) {
        Write-Verbose -Message "$theFName Processing $($subModulesToProcess.Count) submodules..."
        [System.Object[]]$nestedModulesTable = @()
        $subModulesToProcess.ForEach({
            $nestedModulesTable += (Convert-PSModuleInfoToHashTable -Path $Path -ModuleInfo $_)
        })
        Write-Verbose -Message "$theFName Found $($nestedModulesTable.Count) nested modules. Returning result."
        return $nestedModulesTable
    }

    Write-Verbose -Message "$theFName End of function."
    return
}
