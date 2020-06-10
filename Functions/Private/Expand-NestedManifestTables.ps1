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
                [hashtable]$keyValue = $InputObject.$keyName
                [hashtable]$tableFlatten = Expand-NestedManifestTables -InputObject $keyValue
                $tableFlatten.Keys.ForEach({
                    $outputObject.$_ = $tableFlatten.$_
                })
            }
            'System.String'                 {
                Write-Verbose -Message "$theFName Processing the key `"$keyName`" of type `"$keyTypeName`"..."
                [string]$keyValue = $InputObject.$keyName
                $keyValue = $keyValue.TrimStart(' ').TrimEnd(' ')
                if  (
                    ($keyValue.Length -gt 0) -and `
                    ($keyValue -notmatch '^[*]$' )
                )
                {
                    Write-Verbose -Message "$theFName Adding key `"$keyName`" with value `"$keyValue`" to output object."
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