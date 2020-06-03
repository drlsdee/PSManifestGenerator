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

function Load-Modules {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Load or unload
        [switch]
        $Unload
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Search for modules in `"$PSScriptRoot`""

    [System.Management.Automation.PSModuleInfo[]]$modulesAll = Get-Module -Name $PSScriptRoot -ListAvailable -Refresh
    Write-Verbose "Found $($modulesAll.Count) modules:"
    $modulesAll.ForEach({
        Write-Verbose -Message "$theFName Module found: `"$($_.Path)`""
    })

    if ($Unload) {
        $modulesAll.ForEach({
            if (-not (Get-Module -Name $_.Name)) {
                Write-Warning -Message "$theFName Module with name `"$($_.Name)`" not loaded."
            } else {
                Remove-Module -Name $_.Name
            }
        })
    } else {
        $modulesAll.ForEach({
            if (-not (Test-Path -Path $_.Path -PathType Leaf)) {
                Write-Warning -Message "$theFName Module not found at path `"$($_.Path)`"!"
            } else {
                Import-Module -Name $_.Path
            }
        })
    }
}

function Restore-BackupManifests {
    [CmdletBinding()]
    param (
        [Parameter()]
        # Path to target module folder
        [string]
        $Path
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Given path is `"$Path`""
    [System.IO.FileInfo[]]$moduleFilesAll = Get-ChildItem -Path $Path -File
    [System.IO.FileInfo[]]$moduleManifests = $moduleFilesAll.Where({$_.Extension -eq '.psd1'})
    [System.IO.FileInfo[]]$moduleManifestBackups = $moduleFilesAll.Where({$_.Extension -eq '.old'})
    [System.IO.FileInfo[]]$backupsToRestore = $moduleManifestBackups.Where({$_.BaseName.TrimEnd('.psd1') -notin $moduleManifests.BaseName})
    Write-Verbose -Message "$theFName Found $($backupsToRestore.Count) manifest backups to restore."
    [System.IO.FileInfo[]]$backupsToRemove = $moduleManifestBackups.Where({$_.BaseName.TrimEnd('.psd1') -in $moduleManifests.BaseName})
    Write-Verbose -Message "$theFName Found $($backupsToRemove.Count) unnecessary manifest backups."
    $backupsToRestore.ForEach({
        Write-Verbose -Message "$theFName Restoring backup of manifest `"$($_.FullName)`"..."
        [string]$newName = $_.FullName -replace '\.old$'
        Move-Item -Path $_.FullName -Destination $newName -Force
    })
    [System.IO.FileInfo[]]$backupsToRemove = $moduleManifestBackups.Where({$_.BaseName.TrimEnd('.psd1') -in $moduleManifests.BaseName})
    $backupsToRemove.ForEach({
        Write-Verbose -Message "$theFName Removing unnecessary backup of manifest `"$($_.FullName)`"..."
        Remove-Item -Path $_.FullName -Force
    })
}

function Start-ManifestGeneration {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        # Path to target module
        [string]
        $Path = $PSScriptRoot,

        [Parameter(ValueFromPipelineByPropertyName)]
        # GUID
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
        $HelpInfoUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Increment major version
        [switch]
        $Major,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Increment minor version
        [switch]
        $Minor,

        [Parameter(ValueFromPipelineByPropertyName)]
        # Set build number
        [string]
        $Build
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    if (-not $Path) {
        $Path = $PSScriptRoot
        Write-Verbose -Message "$theFName Path is empty. Set to `"$Path`""
    } else {
        Write-Verbose -Message "$theFName Given path is `"$Path`""
    }
    Write-Verbose -Message "$theFName Loading modules from `"$Path`"..."
    Load-Modules
    Write-Verbose -Message "$theFName Get module info from `"$Path`"..."
    Get-Module -Name PSManifestGenerator
    Write-Verbose -Message "$theFName Run module from `"$Path`"..."
    try {
        <# New-CustomPSModuleManifest  -Path $Path `
                                    -Guid $Guid `
                                    -Author $Author `
                                    -CompanyName $CompanyName `
                                    -ModuleVersion $ModuleVersion `
                                    -PowerShellVersion $PowerShellVersion `
                                    -RequiredModules $RequiredModules `
                                    -Tags $Tags `
                                    -ProjectUri $ProjectUri `
                                    -LicenseUri $LicenseUri `
                                    -IconUri $IconUri `
                                    -ReleaseNotes $ReleaseNotes  `
                                    -HelpInfoUri $HelpInfoUri `
                                    -Major:$Major `
                                    -Minor:$Minor `
                                    -Build $Build `
                                    -Verbose:$Verbose #>
        #
        [string[]]$givenParamNames = $PSBoundParameters.Keys.Where({
            $_ -notin [string[]]@([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
        })
        $givenParamValues = New-Object -TypeName psobject
        if ($givenParamNames.Count) {
            $PSBoundParameters.Keys.ForEach({
                Write-Verbose -Message "$theFName Bound parameter `"$_`" found with value `"$($PSBoundParameters.$_)`"."
                $givenParamValues | Add-Member -MemberType NoteProperty -Name $_ -Value $PSBoundParameters.$_
            })
            Write-Verbose -Message "$theFName Start command `"New-CustomPSModuleManifest`" with parameters: $($givenParamNames -join ',')"
            $givenParamValues | New-CustomPSModuleManifest -Verbose:$Verbose
        } else {
            Write-Warning -Message "$theFName Parameters are not set! Try to use default values..."
            New-CustomPSModuleManifest -Path $Path -Verbose
        }
    } catch {
        Write-Warning -Message "$theFName SOMETHING WRONG! "
    } finally {
        Write-Verbose -Message "$theFName Unloading modules from `"$Path`"..."
        Load-Modules -Unload
        Restore-BackupManifests -Path $Path
    }
}
if ($PSBoundParameters.Keys.Count) {
    $scriptParameters = New-Object -TypeName psobject
    $PSBoundParameters.Keys.Where({
        $_ -notin [string[]]@([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
    }).ForEach({
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Bound parameter `"$_`" found with value `"$($PSBoundParameters.$_)`"."
        $scriptParameters | Add-Member -MemberType NoteProperty -Name $_ -Value $PSBoundParameters.$_
    })
    $scriptParameters | Start-ManifestGeneration -Verbose:$Verbose
} else {
    Write-Warning -Message "[$($MyInvocation.MyCommand.Name)]: Parameters are not set! Try to use default values..."
    Start-ManifestGeneration -Verbose
}
