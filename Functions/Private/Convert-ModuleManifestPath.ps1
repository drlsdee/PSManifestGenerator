function Convert-ModuleManifestPath {
    [CmdletBinding()]
    param (
        # Given path: to module's root folder, to module manifest or to any other file.
        # If this path is the path to any PowerShell data file (or any other file with extension '.psd1'), the function returns this path immediately
        [Parameter(Mandatory)]
        [string]
        $Path,

        # What to return: folder or manifest path
        [Parameter()]
        [ValidateSet('File', 'Folder')]
        [string]
        $ReturnType
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if      ([System.IO.Path]::GetExtension($Path))
    {
        Write-Verbose -Message "$theFName Given path `"$Path`" is probably the path to some file."
        [string]$manifestFolderPath = [System.IO.Path]::GetDirectoryName($Path)
        $manifestFolderPath = Resolve-Path -Path $manifestFolderPath
        Write-Verbose -Message "$theFName Full path to target directory: $manifestFolderPath"
        if  ([System.IO.Path]::GetExtension($Path) -eq '.psd1')
        {
            Write-Verbose -Message "$theFName Given path is the path to PowerShell data file."
            [string]$manifestFileName = [System.IO.Path]::GetFileName($Path)
        }
        else
        {
            Write-Warning -Message "$theFName Given path is probably the path to some file but not PowerShell data file. Converting..."
            [string]$fileNameClean = [System.IO.Path]::GetFileNameWithoutExtension($Path)
            if ($fileNameClean -match '\.') {
                Write-Verbose -Message "$theFName Filename `"$fileNameClean`" has multiple extensions. Cleaning up..."
                [string[]]$fileNameSplitted = ($fileNameClean -split '\.')
                $fileNameSplitted = $fileNameSplitted.ForEach({
                    $_.Trim(' ')
                }).Where({$_})
                $fileNameClean = $fileNameSplitted[0]
            }
            [string]$manifestFileName = "$($fileNameClean).psd1"
            Write-Verbose -Message "$theFName Filename for new manifest: $manifestFileName"
        }
    }
    else
    {
        Write-Verbose -Message "$theFName Given path is a path to directory! The function returns a path to a new manifest with basename the same as the folder's basename."
        [string]$manifestFolderPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
        Write-Verbose -Message "$theFName Manifest folder path: $manifestFolderPath"
        $fileNameClean = [System.IO.Path]::GetFileName($manifestFolderPath)
        [string]$manifestFileName = "$($fileNameClean).psd1"
        Write-Verbose -Message "$theFName Filename for new manifest: $manifestFileName"
    }

    $Path = [System.IO.Path]::Combine($manifestFolderPath, $manifestFileName)

    switch ($ReturnType) {
        'File'      {
            Write-Verbose -Message "$theFName End of function. Returning path to module manifest: $Path"
            return $Path
        }
        'Folder'    {
            Write-Verbose -Message "$theFName End of function. Returning path to module folder: $manifestFolderPath"
            return $manifestFolderPath
        }
    }
}