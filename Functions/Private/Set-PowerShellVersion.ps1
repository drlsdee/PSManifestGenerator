function Set-PowerShellVersion {
    [CmdletBinding()]
    param (
        # PowerShell version from bound parameters
        [Parameter()]
        [string]
        $PowerShellVersion,

        # PowerShell version from old manifest data
        [Parameter()]
        [string]
        $PowerShellVersionOld
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if      ($PowerShellVersion) {
        Write-Verbose -Message "$theFName PowerShell version found in bound parameters. Returning: $PowerShellVersion"
        return $PowerShellVersion
    }
    elseif  ($PowerShellVersionOld) {
        Write-Verbose -Message "$theFName PowerShell version found in old manifest data. Returning: $PowerShellVersionOld"
        return $PowerShellVersionOld
    }
    else {
        $PowerShellVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
        Write-Verbose -Message "$theFName Getting PowerShell version from current host. Returning: `"$PowerShellVersion`""
        return $PowerShellVersion
    }
}