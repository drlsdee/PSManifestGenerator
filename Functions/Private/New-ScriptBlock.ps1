function New-ScriptBlock {
    [CmdletBinding()]
    param (
        # Parameters
        [Parameter(Mandatory)]
        [psobject[]]
        $Parameters
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [psobject[]]$paramsValid = $Parameters.Where({
        ('Name' -in $_.psobject.Properties.Name) -and `
        ('ValueAsString' -in $_.psobject.Properties.Name) -and `
        ($_.ValueAsString.Length)
    })
    
    if ($paramsValid.Count -eq 0) {
        Write-Warning -Message "$theFName No valid parameters!"
        return
    }

    [string]$keyValueStringJoined = $paramsValid.ForEach({
        Write-Verbose -Message "$theFName Combining key `"$($_.Name)`" and value..."
        "-$($_.Name) $($_.ValueAsString)"
    }) -join ' '

    [string]$scriptBlockString = "New-ModuleManifest $keyValueStringJoined"

    Write-Verbose -Message "$theFName Creating a scriptblock from string: `"$scriptBlockString`"..."

    [scriptblock]$outScriptBlock = [scriptblock]::Create($scriptBlockString)
    Write-Verbose -Message "$theFName End of function."
    return $outScriptBlock
}