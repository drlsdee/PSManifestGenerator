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
        Write-Verbose -Message "$theFName GUID is not specified. Calling private function `"Set-GUID`"."
        $Guid = Set-GUID
    }
    Write-Verbose -Message "$theFName GUID is set to $Guid"

    if (!$NestedModules) {
        Write-Verbose -Message "$theFName NestedModules are not specified. Calling private function `"Get-NestedModules`"."
        $NestedModules = Get-NestedModules -Path $Path
    }
    $NestedModules.ForEach({
        Write-Verbose -Message "$theFName Nested module found: `"$_`"."
    })

    if (!$Author.Length) {
        Write-Verbose -Message "$theFName Author is not set. Substitute with current user's name: `"$env:USERNAME`"."
        $Author = $env:USERNAME
    }
    Write-Verbose -Message "$theFName Author is $Author"

    if (!$Copyright) {
        Write-Verbose -Message "$theFName CopyRight is not specified. Calling private function `"New-CopyRight`"."
        $Copyright = New-CopyRight -Path $Path -Author $Author
    }
    Write-Verbose -Message "$theFName Copyright: $Copyright"

    if (!$RootModule) {
        Write-Verbose -Message "$theFName Root module name is not set."
        [string]$rootModuleName = "$(Split-Path -Path $Path -Leaf).psm1"
        if (Test-Path -Path "$Path\$rootModuleName" -PathType Leaf) {
            $RootModule = $rootModuleName
            Write-Verbose -Message "$theFName Root module: $RootModule"
        } else {
            Write-Error -Category ObjectNotFound -Message "$theFName Root module `"$rootModuleName`" expected in path `"$Path\$rootModuleName`" but NOT FOUND!"
            break
        }
    }
    
    if (!$ModuleVersion) {
        Write-Verbose -Message "$theFName Module version is not specified. Calling private function `"Set-NewVersion`"."
        $ModuleVersion = Set-NewVersion
    }
    Write-Verbose -Message "$theFName Module version: $ModuleVersion"
    
    if (!$Description) {
        Write-Verbose -Message "$theFName Module description is not specified. Calling private function `"New-ModuleDescription`" to create description from file `"README.MD`"."
        $Description = New-ModuleDescription -Path $Path
    }
    Write-Verbose -Message "$theFName Description: $Description"

    if (!$PowerShellVersion) {
        Write-Verbose -Message "$theFName PowerShell version is not specified. Getting PowerShell version from current host."
        $PowerShellVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
    }
    Write-Verbose -Message "$theFName PowerShell version set to $PowerShellVersion"

    if (!$FunctionsToExport) {
        Write-Verbose -Message "$theFName FunctionsToExport are not specified. Calling private function `"Get-PublicFunctions`"."
        $FunctionsToExport = Get-PublicFunctions -Path $Path
    }
    $FunctionsToExport.ForEach({
        Write-Verbose -Message "$theFName Public function found: `"$_`"."
    })

    if (!$AliasesToExport) {
        Write-Verbose -Message "$theFName AliasesToExport are not specified. Calling private function `"Get-AliasesToExport`"."
        $AliasesToExport = Get-AliasesToExport -Functions $FunctionsToExport -Path $Path
    }
    $AliasesToExport.ForEach({
        Write-Verbose -Message "$theFName Alias found: `"$_`"."
    })

    if (!$Tags) {
        Write-Verbose -Message "$theFName Tags are not set"
        #$Tags = @('No')
    } else {
        Write-Verbose -Message "$theFName Found $($Tags.Count) tags:"
        $Tags.ForEach({
            Write-Verbose -Message "$theFName Tag: `"$_`""
        })
    }

    if (!$ProjectUri) {
        Write-Verbose -Message "$theFName ProjectUri is not specified. Calling private function `"New-ProjectUri`"."
        $ProjectUri = New-ProjectUri -Path $Path
    }
    Write-Verbose -Message "$theFName Project URI: `"$ProjectUri`""

    if (!$ReleaseNotes) {
        Write-Verbose -Message "$theFName Release notes set to description."
        $ReleaseNotes = $Description
    }
    Write-Verbose -Message "$theFName Release notes: `"$ReleaseNotes`""

    $outObject = New-Object -TypeName PSobject

    #[string[]]$paramsWithValuesNames = Get-CommonParameters -BoundParameters $PSBoundParameters
    [string[]]$paramsWithValuesNames = Get-CommonParameters -BoundParameters $MyInvocation.MyCommand.Parameters

    $MyInvocation.BoundParameters.Keys.ForEach({
        Write-Verbose -Message "$theFName BOUND PARAMETER: `"$_`""
    })

<#     $MyInvocation.MyCommand.Parameters.Keys.ForEach({
        Write-Verbose -Message "$theFName PARAMETER: $_"
    }) #>

    $paramsWithValues = $paramsWithValuesNames.ForEach({Get-Variable -Name $_}).Where({$_.Value})
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
