function Set-AuthorsName {
    [CmdletBinding()]
    param (
        # Specifies the module author.
        # If you omit this parameter, the script creates an Author key with the name of the current user.
        [Parameter()]
        [string]
        $Author,

        # Author's name from old manifest data.
        [Parameter()]
        [string]
        $OldAuthor,

        # Author's name from current commit message
        [Parameter()]
        [string]
        $CommitAuthor
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."

    if      (
                ($Author.Length -eq 0) -and `
                ($OldAuthor.Length -eq 0) -and `
                ($CommitAuthor.Length -eq 0)
            )
    {
        $Author = $env:USERNAME
        Write-Verbose -Message "$theFName Author's name is not set! Creating key with the name of the current user: $Author"
    }
    elseif  (
                ($Author.Length -eq 0) -and `
                ($OldAuthor.Length -gt 0)
            )
    {
        $Author = $OldAuthor
        Write-Verbose -Message "$theFName Author's name not found in bound parameters but found in old manifest data: $Author"
    }
    elseif  (
                ($Author.Length -eq 0) -and `
                ($OldAuthor.Length -eq 0) -and `
                ($CommitAuthor.Length -gt 0)
            )
    {
        $Author = $CommitAuthor
        Write-Verbose -Message "$theFName Author's name not found neither in bound parameters nor in  old manifest data but found in the last commit message: $Author"
    }
    elseif  (
                $Author.Length -gt 0
            )
    {
        Write-Verbose -Message "$theFName Author's name found. Author's name from old data will be ignored. New author's name: $Author"
    }

    Write-Verbose -Message "$theFName End of function."
    return $Author
}