function Get-NestedModules {
    [CmdletBinding()]
    [Alias('getNesMod')]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path,

        [Parameter(DontShow)]
        # Nested modules root folder name
        [string]
        $ModulesFolder,

        # Root module from bound parameters
        [Parameter(DontShow)]
        [string]
        $RootModule
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [string]$includeFolder = "$($PSScriptRoot)\$($MyInvocation.MyCommand.Name)"
    [string[]]$toolsScripts = [System.IO.Directory]::GetFiles($includeFolder, '*.ps1')
    if ($toolsScripts) {
        $toolsScripts.ForEach({
            Write-Verbose -Message "$theFName Loading script from path: $_"
            . $_
        })
    }

    [string]$subModulesFolderPath = [System.IO.Path]::Combine($Path, $ModulesFolder)
    if (-not $ModulesFolder) {
        Write-Verbose -Message "$theFName Folder for nested modules is not defined. Search in whole module folder..."
    }
    Write-Verbose -Message "$theFName Search for nested modules in folder `"$subModulesFolderPath`"..."

    [string[]]$moduleExtensions = @(
        '.psm1'
        '.psd1'
        '.dll'
        '.cdxml'
    )

    if (-not $RootModule) {
        Write-Verbose -Message "$theFName Root module name is not defined. Set to root module folder's name..."
        [string]$rootModuleName = [System.IO.Path]::GetFileName($Path)
        <# [string[]]$rootModuleFileNames = $moduleExtensions.ForEach({
            "$($rootModuleName)$($_)"
        }) #>
    } else {
        Write-Verbose -Message "$theFName Root module is set: $RootModule"
        [string]$rootModuleName = [System.IO.Path]::GetFileNameWithoutExtension($RootModule)
        #[string[]]$rootModuleFileNames = @($RootModule)
    }

    [string[]]$rootModuleFileNames = $moduleExtensions.ForEach({
        "$($rootModuleName)$($_)"
    })

    $rootModuleFileNames.ForEach({
        Write-Verbose -Message "$theFName Possible filename of root module: $_"
    })

    [System.IO.FileInfo[]]$filesAll = Get-ChildItem -Path $subModulesFolderPath -File -Recurse
    [System.IO.FileInfo[]]$moduleFilesAll = $filesAll.Where({
        $_.Extension -in $moduleExtensions
    })
    if ($moduleFilesAll.Count -eq 0) {
        Write-Verbose -Message "$theFName There are no module files in folder `"$subModulesFolderPath`". Exiting."
        return
    }

    [System.IO.FileInfo[]]$subModuleFilesAll = $moduleFilesAll.Where({
        $_.Name -notin $rootModuleFileNames
    })
    if ($subModuleFilesAll.Count -eq 0) {
        Write-Verbose -Message "$theFName There are no submodule files in folder `"$subModulesFolderPath`". Exiting."
        return
    }

    Write-Verbose -Message "$theFName There are $($subModuleFilesAll.Count) submodule files in folder `"$subModulesFolderPath`". Continue..."

    [psmoduleinfo[]]$subModulesInfoAll = @()
    $subModuleFilesAll.ForEach({
        [System.IO.FileInfo]$subModuleFile = $_
        try {
            Write-Verbose -Message "$theFName Trying to get info about module file `"$($subModuleFile.BaseName)`" from location `"$($subModuleFile.FullName)`"..."
            [psmoduleinfo]$subModuleInfo = Get-Module -Name $_.FullName -ListAvailable -ErrorAction Stop
            $subModulesInfoAll += $subModuleInfo
        }
        catch {
            throw
        }
    })

    if (-not $subModulesInfoAll) {
        Write-Verbose -Message "$theFName Can not get info about nested modules. Returning null."
        return
    }
    Write-Verbose -Message "$theFName Found $($subModulesInfoAll.Count) submodules total."

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
<# 
[System.Object[]]$nestedModulesNfs = Get-NestedModules -Verbose -Path C:\Users\Administrator\Gitea\NFS
$nestedModulesNfs | Format-List
$nestedModulesNfs.Count
 #>