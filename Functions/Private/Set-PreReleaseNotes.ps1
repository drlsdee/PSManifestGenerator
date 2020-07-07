function Set-PreReleaseNotes {
    [CmdletBinding()]
    param (
        # Pre-release switch
        [Parameter()]
        [switch]
        $PreRelease,

        # Pre-release notes
        [Parameter()]
        [string]
        $PreReleaseNotes
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [string]$powerShellGetName = 'PowerShellGet'
    [version]$powerShellGetVersionRequired  = '1.6.6'

    if (-not $PreRelease) {
        Write-Verbose -Message "$theFName Parameter `"PreRelease`" is not used. Ignoring."
        return $null
    }

    try     {
        [version]$powerShellGetVersionCurrent   = (Get-PackageProvider -Name $powerShellGetName -ErrorAction Stop).Version
    }
    catch   {
        Write-Warning -Message "$theFName Provider `"$powerShellGetName`" not found!"
        return $null
    }

    if ($powerShellGetVersionCurrent -lt $powerShellGetVersionRequired) {
        Write-Warning -Message "$theFName The current PowerShellGet version `"$powerShellGetVersionCurrent`" is less than required version `"$powerShellGetVersionRequired`" and parameter `"PreRelease`" will not work. Ignoring."
        return $null
    }
    else {
        Write-Verbose -Message "$theFName Current PowerShellGet version is `"$powerShellGetVersionCurrent`"."
    }

    if (-not $PreReleaseNotes) {
        $PreReleaseNotes = 'This is a pre-release. Use it on your own risk.'
    }

    return $PreReleaseNotes

    Write-Verbose -Message "$theFName End of function."
}
