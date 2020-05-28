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
    [string[]]$nestedModules = @()
    [string]$modulesFolderPath = "$Path\$ModulesFolder"
    if (-not (Test-Path -Path $modulesFolderPath -PathType Container)) {
        Write-Verbose -Message "$theFName Folder `"$ModulesFolder`" not found in path `"$Path`". The module probably has no nested modules."
    } else {
        Write-Verbose -Message "$theFName Folder `"$ModulesFolder`" found in path `"$Path`". Search for nested modules."
        [System.IO.FileInfo[]]$subModulesAll = Get-ChildItem -Path $modulesFolderPath -Recurse -Filter '*.ps?1'
        if (!$subModulesAll) {
            Write-Verbose -Message "$theFName No nested modules found in folder `"$modulesFolderPath`"! Returning null."
            return
        }
        [System.IO.FileInfo[]]$subModulesManifests = $subModulesAll.Where({$_.Extension -eq '.psd1'})
        Write-Verbose -Message "$theFName Found $($subModulesManifests.Count) submodules of type `"Manifest`"."
        [System.IO.FileInfo[]]$subModulesScripts = $subModulesAll.Where({($_.Extension -eq '.psm1') -and ($_.DirectoryName -notin $subModulesManifests.DirectoryName)})
        Write-Verbose -Message "$theFName Found $($subModulesScripts.Count) submodules of type `"Script`"."
        $nestedModules += $subModulesManifests.FullName.TrimStart($Path)
        $nestedModules += $subModulesScripts.FullName.TrimStart($Path)
    }
    return $nestedModules
}
