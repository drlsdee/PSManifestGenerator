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
    if (-not (Test-Path -Path $readmePath -PathType Leaf)) {
        [string]$newDescription = 'Description should be here.'
    } else {
        [string[]]$readmeRaw = Get-Content -Path $readmePath
        [string]$newDescription = $readmeRaw.Where({($_.Trim(' ').Length) -and ($_ -notmatch '^#')})[0]
    }
    return $newDescription
}
