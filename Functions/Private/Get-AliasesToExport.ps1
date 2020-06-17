function Get-AliasesToExport {
    [CmdletBinding()]
    [Alias('newAls')]
    param (
        # The list of all module files with valid extensions
        [Parameter()]
        [System.IO.FileInfo[]]
        $PublicFunctions
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [string[]]$aliasesToExport = @()

    if (-not $PublicFunctions) {
        Write-Warning -Message "$theFName No public functions specified! Exiting."
        return
    }

    $PublicFunctions.ForEach({
        [System.IO.FileInfo]$functionScript = $_
        [string]$scriptFullName = $functionScript.FullName
        [string]$scriptBaseName = $functionScript.BaseName

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
