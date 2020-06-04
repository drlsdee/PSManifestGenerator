function New-ScriptBlock {
    [CmdletBinding()]
    param (
        # Parameters as PSCustomObject
        [Parameter(Mandatory)]
        [psobject]
        $Parameters
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    [string[]]$paramNames = $Parameters.PSObject.Properties.Name
    [string[]]$paramsValid = $paramNames.Where({
        ($Parameters.$_.GetType().FullName -eq 'System.String') -and `
        ($null -ne $Parameters.$_)
    })
    
    if ($paramsValid.Count -eq 0) {
        Write-Warning -Message "$theFName No valid parameters!"
        return
    }

    [string]$keyValueStringJoined = $paramsValid.ForEach({
        Write-Verbose -Message "$theFName Combining key `"$($_)`" and value `"$($Parameters.$_)`"..."
        "-$($_) `"$($Parameters.$_)`""
    }) -join ' '

    [string]$scriptBlockString = "New-ModuleManifest $keyValueStringJoined"

    Write-Verbose -Message "$theFName Creating a scriptblock from string: `"$scriptBlockString`"..."

    [scriptblock]$outScriptBlock = [scriptblock]::Create($scriptBlockString)
    Write-Verbose -Message "$theFName End of function."
    return $outScriptBlock
}