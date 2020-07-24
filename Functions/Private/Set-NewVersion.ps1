function Set-NewVersion {
    [CmdletBinding()]
    [Alias('newVer')]
    param (
        # Module version from bound parameters
        [Parameter()]
        [string]
        $ModuleVersion,

        [Parameter()]
        # Old version
        [string]
        $VersionOld
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    if ($ModuleVersion) {
        Write-Verbose -Message "$theFName Module version set in bound parameters. Returning: $ModuleVersion"
        return $ModuleVersion
    }

    if (!$VersionOld.Length) {
        Write-Verbose -Message "$theFName Old version not specified. It seems like this is the first release of the module. Set version to zeroes: 0.0.0.0"
        [string]$versionNew = '0.0.0.0'
        return $versionNew
    }

    # Temporary solution: automatically step up the 'Revision' part of the old version.
    Write-Verbose -Message "$theFName Old version found: $VersionOld"
    [version]$versionObject = $VersionOld<# 
    
    [string[]]$versionPartNames = ($versionObject | Get-Member -MemberType Property).Name

    $versionPartNames.ForEach({
        [string]$partName = $_
        [int]$partValue = $VersionOld.$partName
        Write-Verbose -Message "$theFName  The `"$partName`" part of the old version is: $partValue"
        if ($partValue -lt 0) {
            Write-Verbose -Message "$theFName The `"$partValue`" part of the old version is less than zero. Set to zero."
            $partValue = 0
        }
        Write-Verbose -Message "$theFName Setting new variable:`tName`t$($partName);`tValue:`t$($partValue)"
        New-Variable -Name $partName -Value $partValue
    })
 #> 
    [int]$majorOld              = $versionObject.Major
    [int]$minorOld              = $versionObject.Minor
    [int]$buildOld              = $versionObject.Build
    [int]$revisionOld           = $versionObject.Revision

    switch ($true) {
        {$majorOld -lt 0}       {
            Write-Verbose -Message "$theFName The `"Major`" part of the old version is less than zero. Set to zero."
            $majorNew           = 0
        }
        {$minorOld -lt 0}       {
            Write-Verbose -Message "$theFName The `"Minor`" part of the old version is less than zero. Set to zero."
            $minorNew           = 0
        }
        {$buildOld -lt 0}       {
            Write-Verbose -Message "$theFName The `"Build`" part of the old version is less than zero. Set to zero."
            $buildNew           = 0
        }
        {$revisionOld -lt 0}    {
            Write-Verbose -Message "$theFName The `"Revision`" part of the old version is less than zero. Set to zero."
            $revisionNew        = 0
        }
        Default {
            [int]$majorNew      = $majorOld
            [int]$minorNew      = $minorOld
            [int]$buildNew      = $buildOld
            [int]$revisionNew   = $revisionOld + 1
        }
    }
    
    [version]$versionNew = "$($majorNew).$($minorNew).$($buildNew).$($revisionNew)"

    Write-Verbose -Message "$theFName The new version is set to `"$versionNew`"."
    return $versionNew
}
