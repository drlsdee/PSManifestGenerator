function Get-PublicFunctions {
    [CmdletBinding()]
    [Alias('getNesFn')]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path,

        # The list of all module files with valid extensions
        [Parameter()]
        [System.IO.FileInfo[]]
        $ModuleFiles,

        [Parameter(DontShow)]
        # Functions root folder name
        [string]
        $Functions = 'Functions',

        [Parameter(DontShow)]
        # Public functions folder name
        [string]
        $Public = 'Public'
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if (-not $ModuleFiles) {
        Write-Warning -Message "$theFName List of module files is empty! Exiting."
        return
    }

    [System.IO.FileInfo[]]$ps1ScriptFilesAll = $ModuleFiles.Where({
        $_.Extension -eq '.ps1'
    })

    if (-not $ps1ScriptFilesAll) {
        Write-Warning -Message "$theFName There are no .PS1 scripts found in $($ModuleFiles.Count) module files! Exiting."
        return
    }

    [string]$pathToFunctionsPublic  = [System.IO.Path]::Combine($Path, $Functions, $Public)
    [string]$pathToFunctionsAll     = [System.IO.Path]::Combine($Path, $Functions)

    if      (-not [System.IO.Directory]::Exists($pathToFunctionsPublic))
    {
        Write-Verbose -Message "$theFName Default directory for all function scripts `"$pathToFunctionsAll`" does not exists! Will search in module's root folder: $Path"
        [string]$pathToSearch = $Path
    }
    elseif  (-not [System.IO.Directory]::Exists($pathToFunctionsPublic))
    {
        Write-Verbose -Message "$theFName Default directory for all function scripts `"$pathToFunctionsPublic`" does not exists! Will search in the folder for all functions: $pathToFunctionsAll"
        [string]$pathToSearch = $pathToFunctionsAll
    }
    else
    {
        Write-Verbose -Message "$theFName Search in the default directory for all function scripts: $pathToFunctionsPublic"
        [string]$pathToSearch = $pathToFunctionsPublic
    }

    [System.IO.FileInfo[]]$functionScripts = $ps1ScriptFilesAll.Where({
        $_.DirectoryName -eq $pathToSearch
    })

    if (-not $functionScripts) {
        Write-Warning -Message "$theFName There are no function to export! Exiting."
        return
    }

    [string[]]$functionsPublic = $functionScripts.BaseName

    Write-Verbose -Message "$theFName Found $($functionsPublic.Count) scripts in path `"$pathToSearch`"."
    return $functionsPublic
}
