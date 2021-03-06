function New-CopyRight {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        # Path to repo
        [string]
        $Path,

        [Parameter()]
        [ValidatePattern('^\d{4}$')]
        # Year of copyright
        [string]
        $Year,

        [Parameter(Mandatory)]
        # Author's name
        [string]
        $Author,

        # Specifies the email of the module author. This parameter is not necessary, but may be used in the Copyright string.
        [Parameter()]
        [string]
        $Contact,

        # Contact from the current commit message, if present
        [Parameter()]
        [string]
        $CommitContact
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    
    if ($Year) {
        [string]$dateString = $Year
    } else {
        [string]$dateString = (Get-Item -Path $Path).CreationTime.Year.ToString()
    }

    Write-Verbose -Message "$theFName Date of copyright: $dateString"

    if (-not $Contact) {
        $Contact = $CommitContact
    }

    if  (
            ($Contact.Trim(' ').Length -gt 0) -and `
            ($Contact -notmatch '[<>()]')
        )
    {
        $Contact = "`<$($Contact)`>"
    }

    [string]$authorAndDate = @(
        $dateString
        $Author
        $Contact
    ) -join ' '

    [string]$copyrightString = "(c) $authorAndDate. All rights reserved."
    
    Write-Verbose -Message "$theFName End of function."
    return $copyrightString
}
