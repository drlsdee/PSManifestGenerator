function New-ModuleDescription {
    [CmdletBinding()]
    [Alias('newDesc')]
    param (
        [Parameter(Mandatory)]
        # Path to local repo
        [string]
        $Path
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"

    [string]$readmePath = "$Path\readme.md"
    
    #if (-not (Test-Path -Path $readmePath -PathType Leaf)) {
    if (-not ([System.IO.File]::Exists($readmePath))) {
        Write-Verbose -Message "$theFName Readme file not found. Set dummy description."
        [string]$newDescription = 'Description should be here.'
    } else {
        #[string[]]$readmeRaw = Get-Content -Path $readmePath
        [string[]]$readmeRaw = [System.IO.File]::ReadAllLines($readmePath)
        [string]$newDescription = $readmeRaw.Where({($_.Trim(' ').Length) -and ($_ -notmatch '^#')})[0]
        Write-Verbose -Message "$theFName Reading the module description from README.MD"
    }
    return $newDescription
}
