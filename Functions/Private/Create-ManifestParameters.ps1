function Create-ManifestParameters {
    [CmdletBinding()]
    [Alias('newManParams')]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        #
        [string]
        $Path,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $NestedModules,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $Guid,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $Author,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $CompanyName,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $Copyright,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $RootModule,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ModuleVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $Description,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ProcessorArchitecture,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $PowerShellVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ClrVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $DotNetFrameworkVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $PowerShellHostName,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $PowerShellHostVersion,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [hashtable[]]
        $RequiredModules,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $TypesToProcess,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $FormatsToProcess,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $ScriptsToProcess,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $RequiredAssemblies,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $FileList,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $ModuleList,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $FunctionsToExport,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $AliasesToExport,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $VariablesToExport,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $CmdletsToExport,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $DscResourcesToExport,

        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string[]]
        $Tags,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ProjectUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $LicenseUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $IconUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $ReleaseNotes,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        #
        [string]
        $HelpInfoUri
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    @($PSBoundParameters.Keys).Where({$PSBoundParameters.$_}).ForEach({
        Write-Verbose -Message "$theFName Bound parameter `"$_`" found with value `"$($PSBoundParameters.$_)`""
    })
    if ($Path -match '.psd1$') {
        Write-Verbose -Message "$theFName Given path `"$Path`" is full path to module manifest."
        [string]$manifestPath = $Path
        [string]$Path = Split-Path -Path $Path -Parent
    } else {
        [string]$Path = $Path.TrimEnd('\')
        [string]$manifestName = "$(Split-Path -Path $Path -Leaf).psd1"
        [string]$manifestPath = Join-Path -Path $Path -ChildPath $manifestName
        Write-Verbose -Message "$theFName Given path `"$Path`" is probably a path to module folder. Manifest will be created in path `"$manifestPath`"."
    }
    if (!$Guid.Length) {
        $Guid = Set-GUID
    }
    Write-Verbose -Message "$theFName GUID is set to $Guid"
    if (!$NestedModules) {
        $NestedModules = Get-NestedModules -Path $Path
    }
    if (!$Author.Length) {
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
        Write-Verbose -Message "$theFName Found $($Tags.Count) tags:"
        $Tags.ForEach({
            Write-Verbose -Message "$theFName Tag: `"$_`""
        })
    }
    if (!$ProjectUri) {
        $ProjectUri = New-ProjectUri -Path $Path
    }
    Write-Verbose -Message "$theFName Project URI: `"$ProjectUri`""
    if (!$ReleaseNotes) {
        $ReleaseNotes = $Description
    }
    Write-Verbose -Message "$theFName Release notes set to description: `"$Description`""

    $outObject = New-Object -TypeName PSobject

    $paramsWithValues = (Get-CommonParameters -BoundParameters $PSBoundParameters).ForEach({Get-Variable -Name $_}).Where({$_.Value})
    $paramsWithValues.ForEach({
        [string]$parameterName = $_.Name
        [string]$parameterValue = ConvertTo-ParameterString -InputParameter $_.Value
        if ($parameterValue.Length) {
            Write-Verbose -Message "$theFName Adding parameter `"$parameterName`" with string value `"$parameterValue`"..."
            $outObject | Add-Member -MemberType NoteProperty -Name $parameterName -Value $parameterValue
        } else {
            Write-Warning -Message "$theFName Parameter `"$parameterName`" is empty!"
        }
    })
    $outObject.Path = $manifestPath
    Write-Verbose -Message "$theFName End of function."
    return $outObject
}
