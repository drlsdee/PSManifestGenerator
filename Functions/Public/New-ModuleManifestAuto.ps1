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
        [switch]
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

    if (-not $Path) {
        Write-Verbose -Message "$theFName Path is not specified! Will work on manifest of this module..."
        $Path = [System.IO.Path]::GetFullPath("$PSScriptRoot\..\..")
    }
    Write-Verbose -Message "$theFName RESOLVING REPOSITORY PATH FROM `"$Path`"..."
    $repositoryPath = Convert-ModuleManifestPath -Path $Path -ReturnType Folder
    Write-Verbose -Message "$theFName Repository path: $repositoryPath"

    Write-Verbose -Message "$theFName RESOLVING MANIFEST PATH FROM `"$Path`"..."
    $Path           = Convert-ModuleManifestPath -Path $Path -ReturnType File
    Write-Verbose -Message "$theFName PowerShell module manifest path: $Path"
    [string]$repositoryPath = Split-Path -Path $Path -Parent

    [System.IO.FileInfo[]]$moduleFilesInventory = Get-ModuleFilesInventory  -Path $repositoryPath
    [System.IO.FileInfo[]]$moduleFilesIncluded  = Get-ModuleFilesIncluded   -ModuleFiles $moduleFilesInventory

    [hashtable]$manifestData = [hashtable]::new()

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
                Write-Verbose -Message "$theFName Flattening tables..."
                $manifestDataOld = Expand-NestedManifestTables -InputObject $manifestDataOld
                Write-Verbose -Message "$theFName Filling the manifest data with values from existing file: $Path."
                $manifestData = Convert-ManifestDataKeyNames -InputObject $manifestDataOld
            } else {
                Write-Verbose -Message "$theFName No valid manifest was found in: $Path."
            }
        }
    } else {
        Write-Verbose -Message "$theFName An old manifest NOT found in path: $Path. Creating new manifest..."
    }
    $manifestData.Path = $Path

    Write-Verbose -Message "$theFName List public functions..."
    [System.IO.FileInfo[]]$publicFunctions  = Get-PublicFunctions -Path $repositoryPath -ModuleFiles $moduleFilesInventory
    $manifestData.FunctionsToExport         = $publicFunctions.BaseName
    
    Write-Verbose -Message "$theFName List aliases for public functions..."
    $manifestData.AliasesToExport = Get-AliasesToExport -PublicFunctions $publicFunctions

    Write-Verbose -Message "$theFName Set RootModule..."
    $rootModuleFileInfo = Set-RootModule -Path $repositoryPath -ModuleFiles $moduleFilesIncluded -RootModule $manifestData.RootModule
    if ($rootModuleFileInfo.Extension -ne '.psd1') {
        $manifestData.RootModule = $rootModuleFileInfo.Name
        Write-Verbose -Message "$theFName Root module defined: $($manifestData.RootModule)"
    }
    else {
        Write-Verbose -Message "$theFName Root module of type `"Manifest`" $($rootModuleFileInfo.Name) found in path `"$($rootModuleFileInfo.FullName)`" but will not be included in this manifest."
    }

    Write-Verbose -Message "$theFName List nested modules..."
    $manifestNestedModules = Get-NestedModules -Path $repositoryPath -ModuleFiles $moduleFilesIncluded -RootModule $rootModuleFileInfo
    if ($manifestNestedModules) {
        $manifestData.NestedModules = $manifestNestedModules
    }

    Write-Verbose -Message "$theFName Set GUID..."
    $manifestData.Guid = Set-GUID -Guid $Guid -GuidOld $manifestData.Guid

    Write-Verbose -Message "$theFName Set module description..."
    if (-not $manifestData.Description) {
        Write-Verbose -Message "$theFName Description is not found in old data. Generating from README..."
        $manifestData.Description = New-ModuleDescription -Path $repositoryPath
    } else {
        Write-Verbose -Message "$theFName Description found in old data:`"$($manifestData.Description)`""
    }

    Write-Verbose -Message "$theFName Set PowerShellVersion..."
    $manifestData.PowerShellVersion = Set-PowerShellVersion -PowerShellVersion $PowerShellVersion -PowerShellVersionOld $manifestData.PowerShellVersion

    if ($CompanyName) {
        Write-Verbose -Message "$theFName Set Company name: $CompanyName"
        $manifestData.CompanyName = $CompanyName
    } else {
        Write-Verbose -Message "$theFName Company name is not set."
    }

    Write-Verbose -Message "$theFName Trying to get some information from commit message..."
    [hashtable]$commitMessage = Get-CommitMessage -Path $repositoryPath
    $commitMessage.Keys.ForEach({
        Write-Verbose -Message "$theFName Commit message key `"$_`" found: $($commitMessage.$_)"
    })

    Write-Verbose -Message "$theFName Set release notes..."
    if (-not $ReleaseNotes) {
        Write-Verbose -Message "$theFName Getting release notes from commit message..."
        $ReleaseNotes = $commitMessage.Message
    }
    $manifestData.ReleaseNotes = $ReleaseNotes

    Write-Verbose -Message "$theFName Set author's name..."
    $manifestData.Author = Set-AuthorsName -Author $Author -OldAuthor $manifestData.Author -CommitAuthor $commitMessage.Author

    Write-Verbose -Message "$theFName Set copyright string..."
    $manifestData.Copyright = New-CopyRight -Path $repositoryPath -Author $manifestData.Author -Contact $Contact -CommitContact $commitMessage.Contact

    Write-Verbose -Message "$theFName Set module tags..."
    $manifestData.Tags = Set-ModuleTags -Tags $Tags -TagsOld $manifestData.Tags

    Write-Verbose -Message "$theFName Set project URI..."
    $manifestData.ProjectUri = New-ProjectUri -Path $Path -ProjectUri $ProjectUri -OriginURI $commitMessage.URI -SCMUri $SCMUri -Owner $Owner

    Write-Verbose -Message "$theFName Set pre-release notes..."
    $manifestData.PreRelease = Set-PreReleaseNotes -PreRelease:$PreRelease -PreReleaseNotes $commitMessage.Message

    Write-Verbose -Message "$theFName Set module version..."
    $manifestData.ModuleVersion = Set-NewVersion -ModuleVersion $ModuleVersion -VersionOld $manifestData.ModuleVersion
    Write-Verbose -Message "$theFName Module version is set to: `"$($manifestData.ModuleVersion)`"."

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

    Write-Verbose -Message "$theFName Now do some cleanup..."
    [string[]]$keysEmpty = $manifestData.Keys.Where({-not $manifestData.$_})
    $keysEmpty.ForEach({
        Write-Verbose -Message "$theFName The key `"$_`" does not contains value! Removing..."
        $manifestData.Remove($_)
    })

    Write-Verbose -Message "$theFName The manifest data table is created. Now run it!"

    New-ModuleManifest @manifestData
    $manifestData

    Write-Verbose -Message "$theFName End of function."
}
