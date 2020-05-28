function Get-AliasesToExport {
    [CmdletBinding()]
    [Alias('newAls')]
    param (
        [Parameter()]
        # Path to target module
        [string]
        $Path,

        [Parameter()]
        # List of functions
        [string[]]
        $Functions
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    $aliasesToExport = @()
    [System.IO.FileInfo[]]$scriptsAll = Get-ChildItem -Path $Path -File -Filter '*.ps1'
    [System.IO.FileInfo[]]$scriptsFunc = $scriptsAll.Where({$_.BaseName -in $Functions})
    $scriptsFunc.ForEach({
        if (Get-Command -Name $_.FullName) {
            try {
                $aliasesToExport += (Get-Alias -Definition $_.BaseName)
            } catch {
                Write-Warning -Message "$theFName Function `"$($_.BaseName)`" has no aliases!"
            }
        } else {
            Write-Warning -Message "$theFName Cannot get command `"$($_.BaseName)`"!"
        }
    })
    return $aliasesToExport
}