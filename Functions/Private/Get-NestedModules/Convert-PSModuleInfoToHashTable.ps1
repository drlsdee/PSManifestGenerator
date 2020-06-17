function Convert-PSModuleInfoToHashTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path,

        # Module info
        [Parameter()]
        [psmoduleinfo]
        $ModuleInfo
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [version]$versionNull = '0.0.0.0'
    [guid]$guidNull = '00000000-0000-0000-0000-000000000000'

    if (-not $ModuleInfo.Path) {
        Write-Warning -Message "$theFName Module `"$($ModuleInfo.Name)`" has not path! Skipping."
        return
    }

    [string]$subModuleName      = $ModuleInfo.Path.Substring($Path.Length).TrimStart('\')
    [guid]$subModuleGuid        = $ModuleInfo.Guid
    [version]$subModuleVersion  = $ModuleInfo.Version
    
    if ($ModuleInfo.ModuleType -ne 'Manifest') {
        Write-Verbose -Message "$theFName Loading of submodules of type `"$($ModuleInfo.ModuleType)`" with defined version and/or GUID is not implemented yet. Returning string: $subModuleName"
        return $subModuleName
    }

    [hashtable]$psModuleTable = @{
        ModuleName = $subModuleName
    }

    switch ($true) {
        {$subModuleGuid -ne $guidNull}          {
            Write-Verbose -Message "$theFName Submodule `"$subModuleName`" has the GUID: $subModuleGuid"
            $psModuleTable.Guid            = $subModuleGuid
        }
        {$subModuleVersion -gt $versionNull}    {
            Write-Verbose -Message "$theFName Submodule `"$subModuleName`" has the version: $subModuleVersion"
            $psModuleTable.ModuleVersion   = $subModuleVersion
        }
    }
    
    if  (
                $psModuleTable.ContainsKey('Guid') -or `
                $psModuleTable.ContainsKey('ModuleVersion')
        )
        {
            Write-Verbose -Message "$theFName Returning hashtable for submodule `"$subModuleName`"..."
            return $psModuleTable
        }
        else    {
            Write-Verbose -Message "$theFName GUID and version not found! Returning string for submodule `"$subModuleName`"..."
            return $subModuleName
        }

    Write-Verbose -Message "$theFName End of function."
}
