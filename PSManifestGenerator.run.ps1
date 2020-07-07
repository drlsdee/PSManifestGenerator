param (
    # Path to target module
    [string]
    $Path,

    # GUID
    [string]
    $Guid,

    # Author's name
    [string]
    $Author,

    # Company name (not necessary)
    [string]
    $CompanyName,

    # Module version (may be set auto)
    [string]
    $ModuleVersion,

    # PS version (may be set from build host)
    [string]
    $PowerShellVersion,

    #  Not implemented yet
    [hashtable]
    $RequiredModules,

    [string[]]
    $Tags,

    [string]
    $ProjectUri,

    [string]
    $LicenseUri,

    [string]
    $IconUri,

    [string]
    $ReleaseNotes,

    [string]
    $HelpInfoUri,

    # Increment major version
    [switch]
    $Major,

    # Increment minor version
    [switch]
    $Minor,

    # Set build number
    [string]
    $Build
)

if (($Tags.Count -eq 1) -and ($Tags -match ',')) {
    $Tags = ($Tags[0] -split ',').Trim(' ')
}

[string]$toolFunctionsFolder = "$PSScriptRoot\dontPackMe\tools"

[string[]]$toolFunctionScripts = [System.IO.Directory]::EnumerateFiles($toolFunctionsFolder, '*.ps1', 'AllDirectories')
$toolFunctionScripts.ForEach({
    . $_
})

Import-AllModules -Path $PSScriptRoot -Action Load -Verbose
$parameterObject = [psobject]::new()
$PSBoundParameters.Keys.ForEach({
    if ($PSBoundParameters.$_) {
        $parameterObject | Add-Member -MemberType NoteProperty -Name $_ -Value $PSBoundParameters.$_
    }
})
if ($parameterObject.Path) {
    $parameterObject.Path = $Path
} else {
    $parameterObject | Add-Member -MemberType NoteProperty -Name 'Path' -Value $Path
}

New-ModuleManifestAuto @PSBoundParameters
Import-AllModules -Path $PSScriptRoot -Action Unload -Verbose
