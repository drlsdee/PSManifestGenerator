function Get-ModuleFilesIncluded {
    [CmdletBinding()]
    param (
        # The list of all module files with valid extensions
        [Parameter()]
        [System.IO.FileInfo[]]
        $ModuleFiles
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if (-not $ModuleFiles) {
        Write-Warning -Message "$theFName List of module files is empty! Exiting."
        return
    }

    [string[]]$moduleFilesExtensionsValid = @(
        '.psd1'
        '.psm1'
        '.dll'
        '.cdxml'
    )

    [System.IO.FileInfo[]]$moduleFilesIncluded = $ModuleFiles.Where({
        $_.Extension -in $moduleFilesExtensionsValid
    })

    if (-not $moduleFilesIncluded) {
        Write-Warning -Message "$theFName No module files of type `'Manifest`', `'Script`', `'Binary`' or `'Cim`' were found! Exiting."
        return
    }
    
    Write-Verbose -Message "$theFName Returning $($moduleFilesIncluded.Count) module files. End of function."
    return $moduleFilesIncluded
}