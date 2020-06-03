function New-CustomPSModuleManifest {
    [CmdletBinding()]
    [Alias('customManifest')]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        # Path to local repository
        [string]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        # The GUID of your module. If not set, will be generated.
        [string]
        $Guid,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Author's name
        [string]
        $Author,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Company name (not necessary)
        [string]
        $CompanyName,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Module version (may be set auto)
        [string]
        $ModuleVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        # PS version (may be set from build host)
        [string]
        $PowerShellVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Not implemented yet
        [hashtable]
        $RequiredModules,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Tags
        [string]
        $Tags,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        # URI of your project
        [string]
        $ProjectUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        # License URI
        [string]
        $LicenseUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        # Icon URI
        [string]
        $IconUri,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        # Release notes. If not set, will be equal to description.
        [string]
        $ReleaseNotes,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        # Help URI.
        [string]
        $HelpInfoUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Old version. Not necessary.
        [string]
        $VersionOld,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Increment major version
        [switch]
        $Major,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Increment minor version
        [switch]
        $Minor,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Build number
        [string]
        $Build
    )

    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"

    [string]$myModuleName = Get-RepoName -Path $Path
    [string]$myModuleFilePath = "$Path\$myModuleName.psm1"
    [string]$myModuleManifestPath = "$Path\$myModuleName.psd1"
    
    Write-Verbose -Message "$theFName Checking if module script exists..."
    if (-not (Test-Path -Path $myModuleFilePath -PathType Leaf)) {
        Write-Error -Category ObjectNotFound -Message "$theFName Module file `"$myModuleFilePath`" NOT FOUND! Exiting..."
        return
    } else {
        Write-Verbose -Message "$theFName Module file `"$myModuleFilePath`" found. Continue."
    }
    
    Write-Verbose -Message "$theFName Checking if module manifest exists..."
    if (Test-Path -Path $myModuleManifestPath -PathType Leaf) {
        Write-Verbose -Message "$theFName Manifest file `"$myModuleManifestPath`" found. Continue with updating the manifest."
        $manifestDataOld = Import-PowerShellDataFile -Path $myModuleManifestPath
        Backup-OldManifest -Path $Path -Action Backup
        Write-Verbose -Message "$theFName Backup of old manifest should be here: `"$($myModuleManifestPath).old`". Now we will remove current manifest!"
        Remove-Item -Path $myModuleManifestPath -Force
    } elseif (Test-Path -Path $myModuleManifestPath -PathType Container) {
        Write-Error -Category ObjectNotFound "$theFName PATH `"$myModuleManifestPath`" IS A CONTAINER! EXITING."
        return
    } else {
        Write-Verbose -Message "$theFName Manifest file `"$myModuleManifestPath`" not found. New manifest wil be created."
        $manifestDataOld = [hashtable]::new()
    }

    [array]$oldValueNamesAll = $manifestDataOld.Keys
    [array]$oldValueNames = $oldValueNamesAll.Where({
        ($_ -notin @('privatedata', 'companyname')) -and `
        ($null -ne $manifestDataOld.$_) -and `
        ($manifestDataOld.$_ -notmatch '[*]') -and `
        ($manifestDataOld.$_ -notmatch 'unknown')
    })
    Write-Verbose -Message "$theFName Found $($oldValueNames.Count) old values."
    if ($oldValueNames.Count) {
        $oldValueNames.ForEach({
            Write-Verbose -Message "$theFName Old parameter found: $_; value is `"$($manifestDataOld.$_)`""
        })
    }

    [string[]]$givenParameterNames = Get-CommonParameters -BoundParameters $PSBoundParameters
    Write-Verbose -Message "$theFName Found $($givenParameterNames.Count) bound parameters: $($givenParameterNames -join ', ')"

    $givenParamValues = New-Object -TypeName psobject
    $givenParamValues | Add-Member -MemberType NoteProperty -Name 'Path' -Value $Path
    
    $versionNew = Set-NewVersion -Major:$Major -Minor:$Minor -Build $Build -VersionOld $manifestDataOld.ModuleVersion
    Write-Verbose -Message "$theFName Manifest will be created with version: $versionNew"

    $givenParamValues | Add-Member -MemberType NoteProperty -Name 'ModuleVersion' -Value $versionNew

    $oldValueNames.Where({$_ -notin @('Path', 'ModuleVersion')}).ForEach({
        Write-Verbose -Message "$theFName Adding old parameter `"$_ `" with value `"$($manifestDataOld.$_)`"..."
        $givenParamValues | Add-Member -MemberType NoteProperty -Name $_ -Value $manifestDataOld.$_
    })

    $givenParameterNames.Where({$_ -ne 'Path'}).ForEach({
        if ($PSBoundParameters.$_) {
            Write-Verbose -Message "$theFName Adding NEW parameter `"$_ `" with value `"$($PSBoundParameters.$_)`"..."
            $givenParamValues | Add-Member -MemberType NoteProperty -Name $_ -Value $PSBoundParameters.$_
        } else {
            Write-Verbose -Message "$theFName Parameter $_ has no value!"
        }
    })

    $manifestDataNew = $givenParamValues | Create-ManifestParameters
    Write-Verbose -Message "$theFName Manifest data object created."

    [scriptblock]$manifestDataScriptBlock = New-ScriptBlock -Parameters $manifestDataNew
    Write-Verbose -Message "$theFName Scriptblock created: $manifestDataScriptBlock"

    Write-Verbose -Message "$theFName GENERATING MANIFEST..."
    $manifestDataScriptBlock.Invoke()
    

    if (-not (Test-Path -Path $manifestDataNew.Path -PathType Leaf)) {
        Write-Error -Category ObjectNotFound -Message "$theFName New manifest not found at path `"$($manifestDataNew.Path)`"! Something wrong..."
    return
    } else {
        Write-Verbose -Message "$theFName Module manifest successfully updated. Removing backup."
        Backup-OldManifest -Path $Path -Action Remove
    }
}
