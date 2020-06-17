function Get-PublicFunctions {
    [CmdletBinding()]
    [Alias('getNesFn')]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path,

        [Parameter(DontShow)]
        # Functions root folder name
        [string]
        $Functions = 'Functions',

        [Parameter(DontShow)]
        # Public functions folder name
        [string]
        $Public = 'Public'
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Given path is `"$Path`""
<#     
    [string]$functionsPathAll = "$Path\$Functions"
    Write-Verbose -Message "$theFName Expecting functions folder at path `"$functionsPathAll`""
    [string]$functionsPathPublic = "$Path\$Functions\$Public"
    Write-Verbose -Message "$theFName Expecting PUBLIC functions folder at path `"$functionsPathPublic`""
    [string]$pathToSearch = $functionsPathPublic
    if (-not (Test-Path -Path $functionsPathPublic -PathType Container)) {
        [string]$pathToSearch = $functionsPathAll
        Write-Verbose -Message "$theFName Public functions folder not found in path `"$functionsPathPublic`". Try to search in `"$pathToSearch`"..."
    } elseif (-not (Test-Path -Path $functionsPathAll -PathType Container)) {
        [string]$pathToSearch = $Path
        Write-Verbose -Message "$theFName Public functions folder not found in path `"$functionsPathAll`". Try to search in `"$pathToSearch`"..."
    }
 #>
    [string]$pathToFunctions    = [System.IO.Path]::Combine($Path, $Functions)
    [string]$pathToSearch       = [System.IO.Path]::Combine($Path, $Functions, $Public)
    Write-Verbose -Message "$theFName Default path to search for public functions: $pathToSearch"
    
    if (-not [System.IO.Directory]::Exists($pathToFunctions)) {
        Write-Verbose -Message "$theFName It seems like the folder `"$pathToFunctions`" does not exists! All functions found in all submodules will be declared as public. Exiting."
        return
    }
    
    if (-not [System.IO.Directory]::Exists($pathToSearch)) {
        Write-Verbose -Message "$theFName It seems like the folder `"$pathToSearch`" does not exists. I'll try to search for functions in folder `"$pathToFunctions`"..."
        $pathToSearch = $pathToFunctions
    }

    [System.IO.FileInfo[]]$functionsPublicFiles = Get-ChildItem -Path $pathToSearch -File -ErrorAction Stop
    $functionsPublicFiles = $functionsPublicFiles.Where({
        $_.Extension -eq '.ps1'
    })

    #[string[]]$functionsPublic = (Get-ChildItem -Path $pathToSearch -File -Filter '*.ps1').BaseName
    [string[]]$functionsPublic = $functionsPublicFiles.BaseName

    if ($functionsPublic.Count -eq 0) {
        Write-Error -Category ObjectNotFound -Message "$theFName There are no functions in path `"$pathToSearch`"!"
        break
    }
    else {
        Write-Verbose -Message "$theFName Found $($functionsPublic.Count) scripts in path `"$pathToSearch`"."
        return $functionsPublic
    }
}
