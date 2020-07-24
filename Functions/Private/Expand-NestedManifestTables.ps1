function Expand-NestedManifestTables {
    [CmdletBinding()]
    param (
        # Input object of type 'System.Collections.Hashtable'
        [Parameter()]
        [System.Collections.Hashtable]
        $InputObject
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string[]]$keysInput = $InputObject.Keys
    if ($keysInput.Count -lt 1) {
        Write-Error -Category InvalidData -Message "$theFName Given table has no keys! Exiting..."
        return
    }

    [hashtable]$outputObject = [hashtable]::new()

    $keysInput.ForEach({
        [string]$keyName = $_
        [string]$keyTypeName = $InputObject.$keyName.GetType().FullName

        switch ($keyTypeName) {
            'System.Collections.Hashtable'  {
                Write-Verbose -Message "$theFName Processing the key `"$keyName`" of type `"$keyTypeName`"..."
                [hashtable]$keyValueHT      = $InputObject.$keyName
                [hashtable]$tableFlatten    = Expand-NestedManifestTables -InputObject $keyValueHT
                $tableFlatten.Keys.ForEach({
                    $outputObject.$_ = $tableFlatten.$_
                })
            }
            'System.String'                 {
                Write-Verbose -Message "$theFName Processing the key `"$keyName`" of type `"$keyTypeName`"..."
                [string]$keyValueStr     = $InputObject.$keyName
                $keyValueStr = $keyValueStr.TrimStart(' ').TrimEnd(' ')
                if  (
                    ($keyValueStr.Length -gt 0) -and `
                    ($keyValueStr -notmatch '^[*]$' )
                )
                {
                    Write-Verbose -Message "$theFName Adding key `"$keyName`" with value `"$keyValueStr`" to output object."
                    $outputObject.$keyName = $InputObject.$keyName
                }
            }
            'System.Object[]'               {
                Write-Verbose -Message "$theFName Processing the key `"$keyName`" of type `"$keyTypeName`"..."
                [System.Object[]]$keyValueObj = $InputObject.$keyName
                if (-not $keyValueObj.Count) {
                    Write-Warning -Message "$theFName The key `"$keyName`" of type `"$keyTypeName`" contains an empty array! Ignoring..."
                }
                else {
                    [string[]]$memberTypes  = $keyValueObj.ForEach({
                        $_.GetType().FullName
                    })
                    [string[]]$memberTypes  = [System.Linq.Enumerable]::Distinct($memberTypes)
                    Write-Verbose -Message "$theFName The key `"$keyName`" of type `"$keyTypeName`" contains $($keyValueObj.Count) objects of types: $($memberTypes -join ', ')."
                    $outputObject.$keyName = $InputObject.$keyName
                }
            }
            Default                         {
                Write-Warning -Message "$theFName Processing of type `"$keyTypeName`" is not implemented yet! Ignoring the key `"$keyName`"..."
            }
        }
    })
    
    Write-Verbose -Message "$theFName End of function."
    return $outputObject
}