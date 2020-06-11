function Set-ModuleTags {
    [CmdletBinding()]
    param (
        # Tags from bound parameters
        [Parameter()]
        [string[]]
        $Tags,
        
        # Tags from old manifest data
        [Parameter()]
        [string[]]
        $TagsOld
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string[]]$tagsOut =    $Tags + `
                            $TagsOld

    if ($tagsOut.Count) {
        Write-Verbose -Message "$theFName End of function."
        return $tagsOut
    } else {
        Write-Verbose -Message "$theFName Tags are not found!"
        return
    }
}