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
        $ModulesFolder = 'NestedModules'
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string[]]$nestedModules = @()

    [string]$modulesFolderPath = "$Path\$ModulesFolder"

    if (-not (Test-Path -Path $modulesFolderPath -PathType Container)) {
        Write-Verbose -Message "$theFName Folder `"$ModulesFolder`" not found in path `"$Path`". The module probably has no nested modules. Exiting..."
        return
    } else {
        Write-Verbose -Message "$theFName Folder `"$ModulesFolder`" found in path `"$Path`". Search for nested modules."
        [System.IO.FileInfo[]]$subModuleFilesAll = Get-ChildItem -Path $modulesFolderPath -Recurse -File
        [System.IO.FileInfo[]]$subModulesAll = $subModuleFilesAll.Where({
            $_.Extension -in @('.psm1', '.psd1', '.dll')
        })
        if (!$subModulesAll) {
            Write-Verbose -Message "$theFName No nested modules found in folder `"$modulesFolderPath`"! Exiting..."
            return
        }
        [System.IO.FileInfo[]]$subModulesManifests = $subModulesAll.Where({$_.Extension -eq '.psd1'})
        Write-Verbose -Message "$theFName Found $($subModulesManifests.Count) submodules of type `"Manifest`"."
        
        [System.IO.FileInfo[]]$subModulesScripts = $subModulesAll.Where({($_.Extension -eq '.psm1') -and ($_.BaseName -notin $subModulesManifests.BaseName)})
        Write-Verbose -Message "$theFName Found $($subModulesScripts.Count) submodules of type `"Script`"."
        
        $nestedModules += $subModulesManifests.FullName.TrimStart($Path)
        $nestedModules += $subModulesScripts.FullName.TrimStart($Path)
    }
    Write-Verbose -Message "$theFName End of function."
    return $nestedModules
}
