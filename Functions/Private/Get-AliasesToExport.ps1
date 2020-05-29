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
    [System.IO.FileInfo[]]$scriptsAll = Get-ChildItem -Path $Path -File -Filter '*.ps1' -Recurse
    Write-Verbose -Message "$theFName Found $($scriptsAll.Count) scripts in path `"$Path`""
    [System.IO.FileInfo[]]$scriptsFunc = $scriptsAll.Where({$_.BaseName -in $Functions})
    Write-Verbose -Message "$theFName Found $($scriptsFunc.Count) functions in path `"$Path`""
    $scriptsFunc.ForEach({
        [string]$scriptFullName = $_.FullName
        [string]$scriptBaseName = $_.BaseName
        try {
            Get-Command -Name $scriptBaseName -ErrorAction Stop
        }
        catch {
            Write-Verbose -Message "$theFName Function `"$scriptBaseName`" is not imported. Dot sourcing it from path `"$scriptFullName`"..."
            . $scriptFullName
        }
        try {
            $aliasesToExport += (Get-Alias -Definition $scriptBaseName -ErrorAction Stop)
        } catch {
            Write-Warning -Message "$theFName Function `"$scriptBaseName`" has no aliases!"
        }
    })
    return $aliasesToExport
}