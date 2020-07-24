function Import-AllModules {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Path to local repository
        [string]
        $Path,
        
        [Parameter()]
        [ValidateSet('Load', 'Unload')]
        # Load or unload
        [string]
        $Action
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Search for modules in `"$Path`""

    [System.IO.FileInfo[]]$moduleFilesAll = Get-ChildItem -Path $Path -File
    [System.IO.FileInfo[]]$moduleScriptsAll = $moduleFilesAll.Where({
        ($_.Extension -eq '.psm1')          -and `
        ($_.BaseName -notmatch '\.test')    -and `
        ($_.BaseName -notmatch '\.build')
    })
    [System.IO.FileInfo[]]$moduleManifestsAll = $moduleFilesAll.Where({
        ($_.Extension -eq '.psd1')          -and `
        ($_.BaseName -notmatch '\.test')    -and `
        ($_.BaseName -notmatch '\.build')
    })
    
    [string[]]$moduleManifestNames = $moduleManifestsAll.BaseName
    
    [System.IO.FileInfo[]]$moduleScriptsWOManifest = $moduleScriptsAll.Where({
        $_.BaseName -notin $moduleManifestNames
    })

    [System.IO.FileInfo[]]$modulesAll = @(
        $moduleManifestsAll
        $moduleScriptsWOManifest
    )
    
    Write-Verbose "Found $($modulesAll.Count) modules:"
    $modulesAll.ForEach({
        [string]$modulePath = $_.FullName
        [string]$moduleName = $_.BaseName
        Write-Verbose -Message "$theFName Module path: `"$modulePath`"; module name: `"$moduleName`""
        
        switch ($Action) {
            'Load'      {
                Import-Module -Name $modulePath -Force
            }
            'Unload'    {
                Get-Module -Name $moduleName | Remove-Module -Force
            }
        }
    })
}