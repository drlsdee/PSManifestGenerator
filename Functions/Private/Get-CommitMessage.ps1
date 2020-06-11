function Get-CommitMessage {
    [CmdletBinding()]
    param (
        # Path to local repository
        [Parameter(Mandatory)]
        [string]
        $Path
    )
    [string]$theFName = "[$($MyInvocation.MyCommand.Name)]:"
    Write-Verbose -Message "$theFName Starting function..."
    # Checking if Git exists:
    try {
        Write-Verbose -Message "$theFName Checking if Git exists on the system $($env:COMPUTERNAME)..."
        git help | Out-Null
    }
    # if Git not found
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Warning -Message "$theFName It seems like Git not found on the system $($env:COMPUTERNAME)! If Git IS installed, try to check your env:PATH."
        return
    }
    # all other errors (excepting Git's errors on StdErr)
    catch {
        throw
    }

    [hashtable]$tmpCommitHashTable = [hashtable]::new()
    Write-Verbose -Message "$theFName Get current branch: git -C $Path branch"
    [string[]]$branchRaw      = git -C $Path branch

    Write-Verbose -Message "$theFName Getting commit message: git -C $Path show -s"
    [string[]]$commitMsgRaw   = git -C $Path show -s

    Write-Verbose -Message "$theFName Getting commit message: git -C $Path show -s"
    [string]$originURI = git -C $Path config --get remote.origin.url

    switch ($true) {
        {$null -ne $branchRaw}      {
            [string]$branchCurrent = $branchRaw.Where({$_ -match '^\*'}).TrimStart('* ')
            $tmpCommitHashTable.Branch = $branchCurrent
            Write-Verbose -Message "$theFName Current branch found: $branchCurrent"
        }
        {$null -ne $commitMsgRaw}   {
            Write-Verbose -Message "$theFName Commit message found:"
            [string]$authorStringRaw = $commitMsgRaw.Where({$_ -match '^author:'})
            if ($authorStringRaw) {
                [string]$authorFromCommit = $authorStringRaw -replace '^author:\s+(.+)<.+', '$1'
                if ($authorFromCommit) {
                    $tmpCommitHashTable.Author = $authorFromCommit
                    Write-Verbose -Message "$theFName Commit author`s name: $authorFromCommit"
                } else {
                    Write-Verbose -Message "$theFName Commit author`s name not found!"
                }

                [string]$emailFromCommit = [regex]::Match($authorStringRaw, '<.+>').Value.Trim('<>')
                if ($emailFromCommit) {
                    $tmpCommitHashTable.Contact = $emailFromCommit
                    Write-Verbose -Message "$theFName Commit author`s contact: $emailFromCommit"
                } else {
                    Write-Verbose -Message "$theFName Commit author`s contact not found!"
                }
            } else {
                Write-Verbose -Message "$theFName Commit message does not contains field `'Author`'!"
            }

            [string]$dateOfCommit = $commitMsgRaw.Where({$_ -match '^date:\s+'}) -replace '^date:\s+'
            if ($dateOfCommit) {
                $tmpCommitHashTable.Date = $dateOfCommit
                Write-Verbose -Message "$theFName Commit date: $dateOfCommit"
            } else {
                Write-Verbose -Message "$theFName Commit message does not contains field `'Date`'!"
            }

            [string[]]$commitMsgBody = $commitMsgRaw.Where({
                ($_.Trim(' ').Length -gt 0) -and `
                ($_ -notmatch '^commit [a-z0-9]') -and `
                ($_ -notmatch '^author:') -and `
                ($_ -notmatch '^date:')
            })
            if (-not $commitMsgBody) {
                Write-Verbose -Message "$theFName Commit message text not found!"
            } else {
                $commitMsgBody = $commitMsgBody.TrimStart(' ').TrimEnd(' ')
                $commitMsgBody.ForEach({
                    Write-Verbose -Message "$theFName Commit message string $($commitMsgBody.IndexOf($_)): $_"
                })
                if  (
                        ($commitMsgBody.Count -gt 1) -and `
                        ($commitMsgBody[0] -notmatch '[.,;:!?]$')
                    )
                {
                    $commitMsgBody[0] = "$($commitMsgBody[0]):"
                }
                $commitMsgJoined = $commitMsgBody -join ' '
                $tmpCommitHashTable.Message = $commitMsgJoined
            }
        }
        {$null -ne $originURI}      {
            Write-Verbose -Message "$theFName Origin URI found: $originURI"
            $tmpCommitHashTable.URI = $originURI.TrimEnd('.git')
        }
    }

    if ($tmpCommitHashTable) {
        Write-Verbose -Message "$theFName End of function."
        return $tmpCommitHashTable
    } else {
        Write-Verbose -Message "$theFName Can't get commit message and current branch! Returning null."
        return
    }
}
Get-CommitMessage -Verbose -Path $PSScriptRoot