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
    [version]$versionObject = $VersionOld
    
    [string[]]$versionPartNames = ($versionObject | Get-Member -MemberType Property).Name

    $versionPartNames.ForEach({
        [string]$partName = $_
        [int]$partValue = $VersionOld.$partName
        if ($partValue -lt 0) {
            Write-Verbose -Message "$theFName The `"$partValue`" part of the old version is less than zero. Set to zero."
            $partValue = 0
        }
        New-Variable -Name $partName -Value $partValue
    })

    $Revision++
    [version]$versionNew = "$($Major).$($Minor).$($Build).$($Revision)"

    Write-Verbose -Message "$theFName The new version is set to `"$versionNew`"."
    return $versionNew
}
