function New-CopyRight {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        # Path to repo
        [string]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'Year')]
        [ValidatePattern('^\d{4}$')]
        # Year
        [string]
        $Year,

        [Parameter(Mandatory)]
        # Author's name
        [string]
        $Author
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    
    if ($Year) {
        [string]$dateString = $Year
    } elseif ($Path) {
        [string]$dateString = (Get-Item -Path $Path).CreationTime.Year.ToString()
    }
    [string]$copyrightString = "© $dateString $Author. All rights reserved."
    return $copyrightString
}
