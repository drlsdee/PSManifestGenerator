function Set-GUID {
    [CmdletBinding()]
    param ()
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    [string]$newGUID = (New-Guid).Guid
    Write-Verbose -Message "$theFName New GUID generated: `"$newGUID`""
    return $newGUID
}
