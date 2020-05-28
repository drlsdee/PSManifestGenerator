function Get-RepoPath {
    [CmdletBinding()]
    [Alias('RepoPath')]
    param ()
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    [string]$repoPath = (Get-Item -Path $PSScriptRoot).Parent.FullName
    Write-Verbose -Message "$theFName Repository path is `"$repoPath`""
    return $repoPath
}
