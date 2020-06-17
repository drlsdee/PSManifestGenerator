function Get-ModuleFiles {
    [CmdletBinding()]
    param (
        # Path to local repository
        [Parameter(Mandatory)]
        [string]
        $Path
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string[]]$psModuleExtensions = @(
        '.BAT',
        '.CAT',
        '.CDXML',
        '.CS',
        '.CSS',
        '.DLL',
        '.DYLIB',
        '.JSON',
        '.MD',
        '.MFL',
        '.MOF',
        '.MUI',
        '.NUSPEC',
        '.PDB',
        '.PS1',
        '.PS1XML',
        '.PSD1',
        '.PSM1',
        '.SO',
        '.TXT',
        '.XML',
        '.XSD',
        '.YML'
    )

    [System.IO.FileInfo[]]$filesAll = Get-ChildItem -Path $Path -File -Recurse

    if (-not $filesAll) {
        Write-Warning -Message "$theFName The folder `"$Path`" and its subfolders are empty! Exiting."
        return
    }

    [System.IO.FileInfo[]]$moduleFilesAll = $filesAll.Where({
        $_.Extension -in $psModuleExtensions
    })

    if (-not $moduleFilesAll) {
        Write-Warning -Message "$theFName It looks like there are no module files in folder `"$Path`" and its subfolders. Exiting."
        return
    }

    Write-Verbose -Message "$theFName Found $($moduleFilesAll.Count) module files. End of function."
    return $moduleFilesAll
}