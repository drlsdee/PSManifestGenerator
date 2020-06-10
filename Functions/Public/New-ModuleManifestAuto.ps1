function New-ModuleManifestAuto {
    [CmdletBinding()]
    [Alias('automanifest')]
    param (
        # Specifies the path and file name of the new module manifest. Enter a path and file name with a .psd1 file name extension, such as `$pshome\Modules\MyModule\MyModule.psd1`. This parameter is required.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Path,

        # Specifies a unique identifier for the module. The GUID can be used to distinguish among modules with the same name.
        # If you omit this parameter, the script creates a GUID key in the manifest and generates a GUID for the value.
        [Parameter(ValueFromPipelineByPropertyName)]
        [guid]
        $Guid,

        # Specifies the module author.
        # If you omit this parameter, the script creates an Author key with the name of the current user.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Author,

        # Specifies the email of the module author. This parameter is not necessary, but may be used in the Copyright string.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Contact,

        # Identifies the company or vendor who created the module.
        # If you omit this parameter, the script creates a CompanyName key with a value of "Unknown".
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $CompanyName,

        # URI of your source code management system, e.g. GitHub or local SCM. Default is GitHub.com.
        # This parameter may include or not: protocol (HTTP or HTTPS) and port (if non-standard, e.g. 8080 or 8443, or 3000 for Gitea)
        [Parameter()]
        [uri]
        $SCMUri = 'github.com',

        # The repository owner's name. The parameter will be included in resulting project URI.
        [Parameter()]
        [string]
        $Owner,

        # Specifies the version of the module.
        # This parameter is not required by the cmdlet, but a ModuleVersion key is required in the manifest. If you omit this parameter, the script creates a ModuleVersion key with a value of "1.0".
        [Parameter(ValueFromPipelineByPropertyName)]
        [version]
        $ModuleVersion,

        # This parameter was added in PowerShellGet 1.6.6. A PreRelease string that identifies the module as a prerelease version in online galleries.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $PreRelease,

        # Specifies the minimum version of PowerShell that works with this module. For example, you can enter 1.0, 2.0, or 3.0 as the parameter's value.
        [Parameter(ValueFromPipelineByPropertyName)]
        [version]
        $PowerShellVersion,

        # Specifies modules that must be in the global session state. If the required modules are not in the global session state, Windows PowerShell imports them. If the required modules are not available, the Import-Module command fails.
        # Enter each module name as a string or as a hash table with ModuleName and ModuleVersion keys. The hash table can also have an optional GUID key. You can combine strings and hash tables in the parameter value. For more information, see the examples.
        # In Windows PowerShell 2.0, Import-Module does not import required modules automatically. It just verifies that the required modules are in the global session state.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Object[]]
        $RequiredModules,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $Tags,

        [Parameter(ValueFromPipelineByPropertyName)]
        [uri]
        $ProjectUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [uri]
        $LicenseUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [uri]
        $IconUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $ReleaseNotes,

        # Specifies the Internet address of the HelpInfo XML file for the module. Enter an Uniform Resource Identifier (URI) that starts with "http" or "https".
        # The HelpInfo XML file supports the Updatable Help feature that was introduced in Windows PowerShell 3.0. It contains information about the location of downloadable help files for the module and the version numbers of the newest help files for each supported locale. For information about Updatable Help, see about_Updatable_Help (http://go.microsoft.com/fwlink/?LinkID=235801). For information about the HelpInfo XML file, see "Supporting Updatable Help" in the Microsoft Developer Network (MSDN) library.
        # This parameter was introduced in Windows PowerShell 3.0.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $HelpInfoUri
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

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

    if ($Path.Length -eq 0) {
        Write-Verbose -Message "$theFName Path is not specified! Will work on manifest of this module..."
        [string]$repositoryPath = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
        [string]$repositoryName = Split-Path -Path $repositoryPath -Leaf
        [string]$manifestName = "$($repositoryName).psd1"
        $Path = "$($repositoryPath)\$($manifestName)"
    }
    Write-Verbose -Message "$theFName PowerShell module manifest path: $Path"
    [string]$repositoryPath = Split-Path -Path $Path -Parent

    [hashtable]$manifestData = [hashtable]::new()
    $manifestData.Path = $Path

    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Verbose -Message "$theFName An old manifest found in path: $Path and will be overwritten."
        try {
            Write-Verbose -Message "$theFName Reading old manifest data from file: $Path."
            [hashtable]$manifestDataOld = Import-PowerShellDataFile -Path $Path -ErrorAction Stop
        }
        catch [System.InvalidOperationException] {
            Write-Warning -Message "$theFName EXISTING FILE `"$Path`" IS NOT A VALID DATA FILE!"
        }
        catch {
            throw
        }
        finally {
            if ($manifestDataOld) {
                Write-Verbose -Message "$theFName Filling the manifest data with values from existing file: $Path."
                $moduleManifestKeys.ForEach({
                    [string]$dataKeyNew = $_
                    [string]$dataKeyOld = @($manifestDataOld.Keys.Where({$_ -match $dataKeyNew}))[0]
                    if ($manifestDataOld.$dataKeyOld) {
                        Write-Verbose -Message "$theFName Adding key: `"$dataKeyNew`" from old data with old key `"$dataKeyOld`"..."
                        $manifestData.$dataKeyNew = $manifestDataOld.$dataKeyOld
                    } else {
                        Write-Verbose -Message "$theFName Key `"$dataKeyNew`" not found in old data."
                    }
                })
            } else {
                Write-Verbose -Message "$theFName No valid manifest was found in: $Path."
            }
        }
    } else {
        Write-Verbose -Message "$theFName An old manifest NOT found in path: $Path. Creating new manifest..."
    }

    Write-Verbose -Message "$theFName List public functions..."
    $manifestData.FunctionsToExport = Get-PublicFunctions -Path $repositoryPath
    
    Write-Verbose -Message "$theFName List aliases for public functions..."
    $manifestData.AliasesToExport = Get-AliasesToExport -Path $repositoryPath -Functions $manifestData.FunctionsToExport

    Write-Verbose -Message "$theFName List nested modules..."
    $manifestNestedModules = Get-NestedModules -Path $repositoryPath
    if ($manifestNestedModules) {
        $manifestData.NestedModules = $manifestNestedModules
    }

    Write-Verbose -Message "$theFName Set GUID..."
    if      (
                (-not $manifestData.Guid) -and `
                (-not $Guid)
            )
    {
        $Guid = [guid]::NewGuid().Guid
        $manifestData.Guid = $Guid
        Write-Verbose -Message "$theFName GUID not found neither in old manifest data nor in bound parameters. Guid created: $Guid"
    }
    elseif  (
                (-not $Guid) -and `
                $manifestData.Guid
            )
    {
        $Guid = $manifestData.Guid
        Write-Verbose -Message "$theFName GUID not found in bound parameters but found in old manifest data: $Guid"
    }
    elseif  (
                (-not $manifestData.Guid) -and `
                $Guid
            )
    {
        $manifestData.Guid = $Guid
        Write-Verbose -Message "$theFName GUID not found in old manifest data but found in bound parameters: $Guid"
    }
    elseif  (
                $manifestData.GUID -and `
                $Guid
            )
    {
        $manifestData.GUID = $Guid
        Write-Warning -Message "$theFName GUID found in old manifest data but found also in bound parameters and will be OVERWRITTEN: $Guid"
    }

    Write-Verbose -Message "$theFName Set module description..."
    if (-not $manifestData.Description) {
        Write-Verbose -Message "$theFName Description is not found in old data. Generating from README..."
        $manifestData.Description = New-ModuleDescription -Path $repositoryPath
    } else {
        Write-Verbose -Message "$theFName Description found in old data:`"$($manifestData.Description)`""
    }

    Write-Verbose -Message "$theFName Set PowerShellVersion..."
    if      (
                (-not $manifestData.PowerShellVersion) -and `
                (-not $PowerShellVersion)
            )
    {
        $PowerShellVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
        $manifestData.PowerShellVersion = $PowerShellVersion
        Write-Verbose -Message "$theFName PowerShellVersion not found neither in old manifest data nor in bound parameters. Get from current host: $PowerShellVersion"
    }
    elseif  (
                (-not $manifestData.PowerShellVersion) -and `
                $PowerShellVersion
            )
    {
        $manifestData.PowerShellVersion = $PowerShellVersion
        Write-Verbose -Message "$theFName PowerShellVersion not found in old manifest data but found in bound parameters: $PowerShellVersion"
    }
    elseif  (
                $manifestData.PowerShellVersion -and `
                (-not $PowerShellVersion)
            )
    {
        $PowerShellVersion = $manifestData.PowerShellVersion
        Write-Verbose -Message "$theFName PowerShellVersion not found in bound parameters but found in old manifest data: $PowerShellVersion"
    }
    elseif  ($PowerShellVersion)
    {
        $manifestData.PowerShellVersion = $PowerShellVersion
        Write-Verbose -Message "$theFName PowerShellVersion: $PowerShellVersion"
    }

    Write-Verbose -Message "$theFName Set RootModule..."
    [string]$rootModuleName = Set-RootModule -Path $repositoryPath -ManifestPath $Path -RootModule $manifestData.RootModule
    if ($rootModuleName) {
        $manifestData.RootModule = $rootModuleName
        Write-Verbose -Message "$theFName Root module defined: $rootModuleName"
    }

    if ($CompanyName) {
        Write-Verbose -Message "$theFName Set Company name: $CompanyName"
        $manifestData.CompanyName = $CompanyName
    } else {
        Write-Verbose -Message "$theFName Company name is not set."
    }

    Write-Verbose -Message "$theFName Trying to get some information from commit message..."
    try {
        [hashtable]$commitMessage = Get-CommitMessage -Path $repositoryPath
        $commitMessage.Keys.ForEach({
            Write-Verbose -Message "$theFName Commit message key `"$_`" found: $($commitMessage.$_)"
        })
    }
    catch {
        Write-Warning -Message "$theFName Can't get commit message! Ignoring..."
    }

    Write-Verbose -Message "$theFName Set release notes..."
    if (-not $ReleaseNotes) {
        Write-Verbose -Message "$theFName Getting release notes from commit message..."
        $ReleaseNotes = $commitMessage.Message
    }

    if ($ReleaseNotes) {
        $manifestData.ReleaseNotes = $ReleaseNotes
    } else {
        Write-Verbose -Message "$theFName Release notes not found."
    }

    Write-Verbose -Message "$theFName Set author's name..."
    [string]$moduleAuthor = Set-AuthorsName -Author $Author -OldAuthor $manifestData.Author -CommitAuthor $commitMessage.Author
    if ($moduleAuthor) {
        $Author = $moduleAuthor
        $manifestData.Author = $Author
    }

    if (-not $Contact) {
        $Contact = $commitMessage.Contact
    }

    Write-Verbose -Message "$theFName Set copyright string..."
    [string]$moduleCopyright = New-CopyRight -Path $repositoryPath -Author $Author -Contact $Contact
    if ($moduleCopyright) {
        $manifestData.Copyright = $moduleCopyright
    }

    if      ($Tags) {
        Write-Verbose -Message "$theFName Tags are defined in bound parameters."
        $manifestData.Tags = $Tags
    }
    elseif  ($manifestData.Tags) {
        Write-Verbose -Message "$theFName Tags are not defined in bound parameters but found in old data"
    }
    else {
        Write-Verbose -Message "$theFName Tags are not defined nor in bound parameters neither in old data"
    }

    if      ($ModuleVersion) {
        Write-Verbose -Message "$theFName Module version is defined in bound parameters: `"$ModuleVersion`"."
        $manifestData.ModuleVersion = $ModuleVersion
    }
    elseif  ($manifestData.ModuleVersion) {
        Write-Verbose -Message "$theFName Module version is not defined in bound parameters but found in old data: `"$($manifestData.ModuleVersion)`". Processing..."
        $ModuleVersion = Set-NewVersion -VersionOld $manifestData.ModuleVersion
        $manifestData.ModuleVersion = $ModuleVersion
    }
    else    {
        Write-Verbose -Message "$theFName Module version is not defined in bound parameters nor in old data. Generating new version..."
        $ModuleVersion = Set-NewVersion
    }
    Write-Verbose -Message "$theFName Module version is set to: `"$ModuleVersion`"."

    if      ($ProjectUri) {
        Write-Verbose -Message "$theFName Project URI is defined in bound parameters: `"$ProjectUri`"."
        $manifestData.ProjectUri = $ProjectUri
    }
    elseif ($manifestData.ProjectUri) {
        $ProjectUri = $manifestData.ProjectUri
        Write-Verbose -Message "$theFName Project URI is not defined in bound parameters but found in old data: `"$ProjectUri`"."
    }
    else {
        Write-Verbose -Message "$theFName Project URI is not defined nor in bound parameters neither in old data."
        $ProjectUri = New-ProjectUri -Path $Path -SCMUri $SCMUri -Owner $Owner
        $manifestData.ProjectUri = $ProjectUri
    }
    Write-Verbose -Message "$theFName Project URI is set to: `"$ProjectUri`"."

    if      (
        $PreRelease -or `
        $manifestData.PreRelease
    ) {
        Write-Verbose -Message "$theFName The key `"PreRelease`" is set. Checking version of the PowerShellGet..."
        [version]$powerShellGetVersionTarget = '1.6.6'
        [version]$powerShellGetVersionCurrent = (Get-PackageProvider -Name 'PowerShellGet').Version
        
        if ($powerShellGetVersionCurrent -ge $powerShellGetVersionTarget) {
            Write-Verbose -Message "$theFName Current version of the PowerShellGet is `"$powerShellGetVersionCurrent`" and is greater or equal to required version `"1.6.6`" Filling the key `"PreRelease`" with given value..."
            $manifestData.PreRelease = $PreRelease
        }
        else {
            Write-Warning -Message "$theFName Current version of the PowerShellGet is `"$powerShellGetVersionCurrent`" and is LESS required version `"1.6.6`" Ignoring the key `"PreRelease`"."
            $manifestData.Remove('PreRelease')
        }
    }

    Write-Verbose -Message "$theFName Passing common parameters to `"New-ModuleManifest`"..."
    [string[]]$parameterNamesCommon = @(
        [System.Management.Automation.PSCmdlet]::CommonParameters
        [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    )
    $parameterNamesCommon.ForEach({
        Write-Verbose -Message "$theFName Processing common parameter: $_"
        if ($PSBoundParameters.ContainsKey($_)) {
            $manifestData.$_ = $PSBoundParameters.$_
        }
    })

    $manifestData

    Write-Verbose -Message "$theFName End of function."
}
