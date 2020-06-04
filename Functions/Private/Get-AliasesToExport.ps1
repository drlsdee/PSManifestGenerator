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
    Write-Verbose -Message "$theFName Starting function..."
    [string[]]$aliasesToExport = @()
    [System.IO.FileInfo[]]$scriptsAll = Get-ChildItem -Path $Path -File -Filter '*.ps1' -Recurse
    Write-Verbose -Message "$theFName Found $($scriptsAll.Count) scripts in path `"$Path`""
    [System.IO.FileInfo[]]$scriptsFunc = $scriptsAll.Where({$_.BaseName -in $Functions})
    Write-Verbose -Message "$theFName Found $($scriptsFunc.Count) functions in path `"$Path`""
    $scriptsFunc.ForEach({
        [string]$scriptFullName = $_.FullName
        [string]$scriptBaseName = $_.BaseName
        try {
            Get-Command -Name $scriptBaseName -ErrorAction Stop
            Write-Verbose -Message "$theFName Function `"$scriptBaseName`" found in path `"$scriptFullName`". Try to get command..."
        }
        catch {
            Write-Verbose -Message "$theFName Function `"$scriptBaseName`" is not imported. Dot sourcing it from path `"$scriptFullName`"..."
            . $scriptFullName
        }
        try {
            [string]$aliasName = (Get-Alias -Definition $scriptBaseName -ErrorAction Stop).Name
            Write-Verbose -Message "$theFName Found alias `"$aliasName`" for function `"$scriptBaseName`"."
            $aliasesToExport += $aliasName
        } catch {
            Write-Warning -Message "$theFName Function `"$scriptBaseName`" has no aliases!"
        }
    })
    Write-Verbose -Message "$theFName End of function."
    return $aliasesToExport
}
