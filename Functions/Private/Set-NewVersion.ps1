function Set-NewVersion {
    [CmdletBinding()]
    [Alias('newVer')]
    param (
        [Parameter()]
        # Old version
        [string]
        $VersionOld,

        [Parameter()]
        # Major
        [switch]
        $Major,

        [Parameter()]
        # Minor
        [switch]
        $Minor,

        [Parameter()]
        # Build
        [int]
        $Build
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    if (!$VersionOld) {
        Write-Verbose -Message "$theFName Old version not specified. Set to zeroes: 0.0.0.0"
        [string]$versionNew = '0.0.0.0'
        return $versionNew
    }
    Write-Verbose -Message "$theFName Old version is: `"$VersionOld`"."
    [version]$VersionObj  = $VersionOld
    [int]$numberMajor     = $VersionObj.Major
    Write-Verbose -Message "$theFName Old major number is: `"$numberMajor`"."
    [int]$numberMinor     = $VersionObj.Minor
    Write-Verbose -Message "$theFName Old major number is: `"$numberMinor`"."
    Write-Verbose -Message "$theFName Given build number is: `"$Build`"."
    if ($Build -gt $VersionObj.Build) {
        [int]$numberBuild = $Build
        Write-Verbose -Message "$theFName Build number is: `"$numberBuild`"."
    } elseif ($VersionObj.Build) {
        [int]$numberBuild = $VersionObj.Build + 1
        Write-Verbose -Message "$theFName Old build number is: `"$($VersionObj.Build)`". New build number will be incremented: `"$numberBuild`""
    } else {
        $numberBuild = 0
        Write-Verbose -Message "$theFName Build number is not set: `"$numberBuild`"."
    }
    [int]$numberRevision = $VersionObj.Revision

    switch ($true) {
        {$Major}    {
            $numberMajor++
            Write-Verbose -Message "$theFName Incrementing MAJOR number. New value is: `"$numberMajor`". Minor and revision will be zeroed."
            $numberMinor = 0
            $numberRevision = 0
        }
        {$Minor}    {
            $numberMinor++
            Write-Verbose -Message "$theFName Incrementing MINOR number. New value is: `"$numberMinor`". Revision will be zeroed."
            $numberRevision = 0
        }
        Default {
            $numberRevision++
            Write-Verbose -Message "$theFName Incrementing REVISION number. New value is: `"$numberRevision`". Major, minor and build are not touched."
        }
    }
    [string]$versionNew = "$numberMajor.$numberMinor.$numberBuild.$numberRevision"
    Write-Verbose -Message "$theFName new version is set to `"$versionNew`"."
    return $versionNew
}
