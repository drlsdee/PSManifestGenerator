function Convert-ManifestDataKeyNames {
    [CmdletBinding()]
    param (
        # Input object of type 'System.Collections.Hashtable'
        [Parameter()]
        [System.Collections.Hashtable]
        $InputObject
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    [string[]]$inputKeys = $InputObject.Keys

    if ($inputKeys.Count -lt 1) {
        Write-Warning -Message "$theFName Input table is empty! Exiting..."
        return
    }

    [string[]]$moduleManifestKeys = @(
        'AliasesToExport'
        'Author'
        'ClrVersion'
        'CmdletsToExport'
        'CompanyName'
        'CompatiblePSEditions'
        'Copyright'
        'DefaultCommandPrefix'
        'Description'
        'DotNetFrameworkVersion'
        'DscResourcesToExport'
        'FileList'
        'FormatsToProcess'
        'FunctionsToExport'
        'Guid'
        'HelpInfoUri'
        'IconUri'
        'LicenseUri'
        'ModuleList'
        'ModuleVersion'
        'NestedModules'
        'PassThru'
        'PowerShellHostName'
        'PowerShellHostVersion'
        'PowerShellVersion'
        'PrivateData'
        'ProcessorArchitecture'
        'ProjectUri'
        'ReleaseNotes'
        'RequiredAssemblies'
        'RequiredModules'
        'RootModule'
        'ScriptsToProcess'
        'Tags'
        'TypesToProcess'
        'VariablesToExport'
    )

    [hashtable]$outputObject = [hashtable]::new()
    
    $moduleManifestKeys.ForEach({
        [string]$keyValid = $_
        [string[]]$keysMatching = $inputKeys.Where({
            $_ -match $keyValid
        })
        if      ($keysMatching.Count -eq 0) {
            Write-Verbose -Message "$theFName No keys found matching to `"$keyValid`". Ignoring..."
        }
        elseif  ($keysMatching.Count -gt 1) {
            Write-Warning -Message "$theFName Found $($keysMatching.Count) keys matching to `"$keyValid`"!"
        }
        else    {
            [string]$keySrc = $keysMatching[0]
            Write-Verbose -Message "$theFName Found source key `"$keySrc`" matching to target key: $keyValid"
            if ($InputObject.$keySrc) {
                Write-Verbose -Message "$theFName Adding key: `"$keyValid`" from old data with old key `"$keySrc`"..."
                $outputObject.$keyValid = $InputObject.$keySrc
            }
            else {
                Write-Verbose -Message "$theFName Key `"$keyValid`" not found in old data."
            }
        }
    })
    
    Write-Verbose -Message "$theFName End of function."
    return $outputObject
}