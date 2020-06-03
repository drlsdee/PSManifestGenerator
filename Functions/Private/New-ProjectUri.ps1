function New-ProjectUri {
    [CmdletBinding()]
    param (
        # Path to local repository
        [Parameter(Mandatory)]
        [string]
        $Path,

        # URI of your source code management system, e.g. GitHub or local SCM. Default is GitHub.com.
        # This parameter may include or not: protocol (HTTP or HTTPS) and port (if non-standard, e.g. 8080 or 8443, or 3000 for Gitea)
        [Parameter()]
        [uri]
        $SCMUri = 'github.com',

        # The repository owner's name. The parameter will be included in resulting project URI.
        [Parameter()]
        [string]
        $Owner,

        # Protocol type, HTTPS is default.
        [Parameter()]
        [ValidateSet('HTTP', 'HTTPS')]
        [string]
        $Protocol = 'HTTPS',

        # Port number. May be equal to zero, if you use default ports (HTTP:80, HTTPS:443).
        [Parameter()]
        [ValidateRange(0,65535)]
        [int64]
        $Port
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if (-not (Get-Command -Name 'Get-RepoName' -ErrorAction Ignore)) {
        Write-Warning -Message "$theFName Function `"Get-RepoName`" is not imported! Try to search here: `"$PSScriptRoot\Get-RepoName.ps1`"..."
        . $PSScriptRoot\Get-RepoName.ps1
    }
    [string]$repoName = Get-RepoName -Path $Path

    # Get owner's name if not set
    if (-not $Owner) {
        Write-Warning -Message "$theFName Owner's name is not set! Will be substituted with username of the current user: $($env:USERNAME)"
        $Owner = $env:USERNAME
    }

    [string]$localPath = "$Owner/$repoName"

    $outURI = [System.UriBuilder]::new()

    # Parse given SCM URI:
    
    switch ($true) {
        {($SCMUri.Port)} {
            $Port = $SCMUri.Port
            Write-Verbose -Message "$theFName Given SCM URI `"$SCMUri`" already includes port number: $Port. Previous value will be ignored!"
        }
        {($SCMUri.Scheme)} {
            $Protocol = $SCMUri.Scheme
            Write-Verbose -Message "$theFName Given SCM URI `"$SCMUri`" already includes protocol type: $($Protocol.ToUpper()). Previous value will be ignored!"
        }
        {($SCMUri.Segments.Count -ge 3) -and ($SCMUri.Segments[-1].Trim('/') -eq $repoName)} {
            Write-Verbose -Message "$theFName Given SCM URI `"$SCMUri`" already includes path with $($SCMUri.Segments.Count) segments and last segment `"$($SCMUri.Segments[-1])`" is equal to repository name `"$repoName`"! Did you passed me the full URI to your repository?"
            $localPath = $SCMUri.LocalPath
        }
        {($SCMUri.Segments.Count) -and ($SCMUri.Segments[-1].Trim('/') -ne $repoName)} {
            Write-Verbose -Message "$theFName Given SCM URI `"$SCMUri`" already includes path with $($SCMUri.Segments.Count) segments but last segment `"$($SCMUri.Segments[-1].Trim('/'))`" is NOT EQUAL to repository name `"$repoName`"! Ignoring..."
        }
        Default {}
    }

    if (($Port -eq 80 -and $Protocol -eq 'HTTP') -or ($Port -eq 443 -and $Protocol -eq 'HTTPS')) {
        Write-Verbose -Message "$theFName Given port `"$Port`" is default for protocol `"$Protocol`". Ignoring..."
        $Port = 0
    }

    [string]$SCMHostName = [regex]::Match($SCMUri, '\w+(\.\w+)+').Value
    Write-Verbose -Message "$theFName SCM host name: `"$SCMHostName`""

    # Build path to repo (relative from SCM hostname)
    #[string]$localPath = "$Owner/$repoName"
    Write-Verbose -Message "$theFName Relative path to repository on SCM:`"$localPath`""

    $outURI.Host = $SCMHostName
    if ($Port) {
        $outURI.Port = $Port
    }
    $outURI.Scheme = $Protocol
    $outURI.Path = $localPath
    
    [string]$outURIString = $outURI.Uri.AbsoluteUri

    Write-Verbose -Message "$theFName End of function."
    return $outURIString
}
<# 
New-ProjectUri -Path 'C:\Users\Administrator\Gitea\PSManifestGenerator\.git' -Verbose -SCMUri 'gitea00.mmc.local' -Port 3000 -Owner 'mmc.local' -Protocol HTTP
New-ProjectUri -Path 'C:\Users\Administrator\Gitea\PSManifestGenerator\.git' -Verbose -Port 443 -Owner 'drlsdee'
New-ProjectUri -Path 'C:\Users\Administrator\Gitea\wixscript\.git' -Verbose -SCMUri 'https://github.com/drlsdee/wixscript/'
 #>