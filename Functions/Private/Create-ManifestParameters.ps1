function Create-ManifestParameters {
    [CmdletBinding()]
    [Alias('newManParams')]
    param (
        [Parameter(Mandatory)]
        #
        [string]
        $Path,
        
        [Parameter()]
        #
        [string[]]
        $NestedModules,
        
        [Parameter()]
        #
        [string]
        $Guid,
        
        [Parameter()]
        #
        [string]
        $Author,
        
        [Parameter()]
        #
        [string]
        $CompanyName,
        
        [Parameter()]
        #
        [string]
        $Copyright,
        
        [Parameter()]
        #
        [string]
        $RootModule,
        
        [Parameter()]
        #
        [string]
        $ModuleVersion,
        
        [Parameter()]
        #
        [string]
        $Description,
        
        [Parameter()]
        #
        [string]
        $ProcessorArchitecture,
        
        [Parameter()]
        #
        [string]
        $PowerShellVersion,
        
        [Parameter()]
        #
        [string]
        $ClrVersion,
        
        [Parameter()]
        #
        [string]
        $DotNetFrameworkVersion,
        
        [Parameter()]
        #
        [string]
        $PowerShellHostName,
        
        [Parameter()]
        #
        [string]
        $PowerShellHostVersion,
        
        [Parameter()]
        #
        [hashtable[]]
        $RequiredModules,
        
        [Parameter()]
        #
        [string[]]
        $TypesToProcess,
        
        [Parameter()]
        #
        [string[]]
        $FormatsToProcess,
        
        [Parameter()]
        #
        [string[]]
        $ScriptsToProcess,
        
        [Parameter()]
        #
        [string[]]
        $RequiredAssemblies,
        
        [Parameter()]
        #
        [string[]]
        $FileList,
        
        [Parameter()]
        #
        [string[]]
        $ModuleList,
        
        [Parameter()]
        #
        [string[]]
        $FunctionsToExport,
        
        [Parameter()]
        #
        [string[]]
        $AliasesToExport,
        
        [Parameter()]
        #
        [string[]]
        $VariablesToExport,
        
        [Parameter()]
        #
        [string[]]
        $CmdletsToExport,
        
        [Parameter()]
        #
        [string[]]
        $DscResourcesToExport,

        [Parameter()]
        #
        [string[]]
        $Tags,
        
        [Parameter()]
        #
        [string]
        $ProjectUri,
        
        [Parameter()]
        #
        [string]
        $LicenseUri,
        
        [Parameter()]
        #
        [string]
        $IconUri,
        
        [Parameter()]
        #
        [string]
        $ReleaseNotes,
        
        [Parameter()]
        #
        [string]
        $HelpInfoUri
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    if ($Path -match '.psd1$') {
        [string]$manifestPath = $Path
        [string]$Path = Split-Path -Path $Path -Parent
    } else {
        [string]$Path = $Path.TrimEnd('\')
        [string]$manifestName = "$(Split-Path -Path $Path -Leaf).psd1"
        [string]$manifestPath = Join-Path -Path $Path -ChildPath $manifestName
    }
    if (!$Guid) {
        $Guid = Set-GUID
    }
    Write-Verbose -Message "$theFName GUID is set to $Guid"
    if (!$NestedModules) {
        $NestedModules = Get-NestedModules -Path $Path
    }
    if (!$Author) {
        $Author = $env:USERNAME
    }
    Write-Verbose -Message "$theFName Author is $Author"
    if (!$Copyright) {
        $Copyright = New-CopyRight -Path $Path -Author $Author
    }
    Write-Verbose -Message "$theFName Copyright: $Copyright"
    if (!$RootModule) {
        $rootModuleName = "$(Split-Path -Path $Path -Leaf).psm1"
        if (Test-Path -Path "$Path\$rootModuleName") {
            $RootModule = $rootModuleName
        }
    }
    Write-Verbose -Message "$theFName Root module: $RootModule"
    if (!$ModuleVersion) {
        $ModuleVersion = '0.0.0.0'
    }
    Write-Verbose -Message "$theFName Module version is `'$ModuleVersion`', but may be changed"
    if (!$Description) {
        $Description = New-ModuleDescription -Path $Path
    }
    Write-Verbose -Message "$theFName Description: $Description"
    if (!$PowerShellVersion) {
        $PowerShellVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
    }
    Write-Verbose -Message "$theFName PS version set to $PowerShellVersion"
    if (!$FunctionsToExport) {
        $FunctionsToExport = Get-PublicFunctions -Path $Path
    }
    if (!$AliasesToExport) {
        $AliasesToExport = Get-AliasesToExport -Functions $FunctionsToExport -Path $Path
    }
    if (!$Tags) {
        Write-Verbose -Message "$theFName Tags are not set"
        $Tags = @('No')
    } else {
        Write-Verbose -Message "Found $($Tags.Count) tags:"
        $Tags.ForEach({
            Write-Verbose -Message "Tag: `"$_`""
        })
    }
    if (!$ProjectUri) {
        $ProjectUri = 'https://github.com'
    }
    Write-Verbose -Message "Project URI: `"$ProjectUri`""
    if (!$ReleaseNotes) {
        $ReleaseNotes = $Description
    }
    Write-Verbose -Message "Release notes set to description: `"$Description`""

    $outObject = New-Object -TypeName PSobject
    $commonParams = Get-CommonParameters
    $paramsWithValues = $MyInvocation.MyCommand.Parameters.Keys.Where({$_ -notin $commonParams}).ForEach({Get-Variable -Name $_}).Where({$_.Value})
    $paramsWithValues.ForEach({
        $outObject | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
    })
    $outObject.Path = $manifestPath
    return $outObject
}
