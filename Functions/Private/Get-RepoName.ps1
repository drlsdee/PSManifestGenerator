function Get-RepoName {
    [CmdletBinding()]
    [Alias('RepoName')]
    param (
        [Parameter()]
        # Path to repo
        [string]
        $Path
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    [string]$repoName = Split-Path -Path $Path -Leaf
    Write-Verbose -Message "$theFName Repository name is `"$repoName`""
    return $repoName
}
