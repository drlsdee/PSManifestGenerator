function Set-GUID {
    [CmdletBinding()]
    param (
        # New GUID from bound parameters
        [Parameter()]
        [string]
        $Guid,

        # Old GUID from old manifest
        [Parameter()]
        [string]
        $GuidOld
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if      ($GuidOld) {
        Write-Verbose -Message "$theFName GUID found in old manifest data. Returning: $GuidOld"
        return $GuidOld
    }
    elseif  ($Guid) {
        Write-Verbose -Message "$theFName GUID found in bound parameters. Returning: $Guid"
        return $Guid
    }
    else {
        [string]$newGUID = (New-Guid).Guid
        Write-Verbose -Message "$theFName New GUID generated. Returning: `"$newGUID`""
        return $newGUID
    }
}
