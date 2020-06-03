function Get-RepoName {
    [CmdletBinding()]
    [Alias('RepoName')]
    param (
        [Parameter()]
        # Path to local repository
        [string]
        $Path
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    if ($Path -match '\.psd1$') {
        Write-Verbose -Message "$theFName Given path `"$Path`" is a full path to module manifest."
        [string]$pathParent = Split-Path -Path $Path -Parent
        [string]$outName = Split-Path -Path $pathParent -Leaf
    } elseif ($Path -match '\.\w+$') {
        Write-Verbose -Message "$theFName Given path `"$Path`" is probably a full path to some file."
        [string]$pathParent = Split-Path -Path $Path -Parent
        [string]$outName = Split-Path -Path $pathParent -Leaf
    } else {
        Write-Verbose -Message "$theFName Given path `"$Path`" seems like path to module folder."
        [string]$outName = Split-Path -Path $Path -Leaf
    }
    Write-Verbose -Message "$theFName Repository name is `"$outName`""
    return $outName
}