param (
    # Path to target module
    [string]
    $Path = $PSScriptRoot,

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
[string[]]$toolFunctionScripts = (Get-ChildItem -Path $toolFunctionsFolder -File -Recurse -Include '*.ps1').FullName
$toolFunctionScripts.ForEach({
    . $_
})

Import-AllModules -Path $Path -Action Load -Verbose
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

#$parameterObject | New-CustomPSModuleManifest -Verbose
New-ModuleManifestAuto -Verbose -Tags test,123 #-Author 'Dr. L. S. Dee'
#Get-Module -Name PSManifestGenerator | fl
Import-AllModules -Path $Path -Action Unload -Verbose